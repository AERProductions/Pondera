// UnifiedHeatingSystem.dm
// ============================================================================
// UNIFIED HEATING & LIGHT-EMITTING SYSTEM
// ============================================================================
// Purpose: Consolidate Fire, Torch, Lamp, Forge, Anvil into one cohesive system
// 
// Architecture:
// - HeatingStation (base class) - Temperature management, visual feedback
// - Torch, Lamp, Campfire (stationary light sources)
// - Forge, Anvil (crafting-specific heating)
// - All derive ambient temperature from WeatherParticles.GetAmbientTemperature()
// - All use TemperatureSystem constants (TEMP_HOT/WARM/COOL) from TemperatureSystem.dm
// 
// Key Features:
// - Temperature state machine (HOT → WARM → COOL)
// - Elevation/weather-aware cooling rates
// - Gamified feedback (particles, sound, visual intensity)
// - Unified E-key interaction system
// - Ambient sound management via SoundmobIntegration

// ============================================================================
// HEATING STATION BASE CLASS
// ============================================================================

obj/HeatingStation
	name = "Heating Station"
	icon = 'dmi/64/fire.dmi'
	icon_state = "fire"
	
	var
		// Thermal state (from TemperatureSystem)
		is_lit = FALSE                     // Whether fuel is burning
		fuel_level = 100                   // 0-100, affects burn duration
		
		// Timing and rates
		heat_start_time = 0                // When this object was last heated
		cooling_rate = 1.0                 // Multiplier for cooling (elevation/weather dependent)
		ambient_temperature = 15           // Current ambient from weather system
		
		// Visual and audio
		fire_sound = null                  // Active sound mob reference
		fire_intensity = 0.0               // 0.0-1.0 for visual effects
		
		// Gamification feedback
		active_user = null                 // Player currently using this station
		
		// Station specific
		station_type = "generic"           // "torch", "lamp", "campfire", "forge", "anvil"
		owner = ""                         // Player name who built/placed it
		max_burn_time = 3600               // Ticks before fuel depleted
	
	New(location)
		..()
		loc = location
		// Auto-initialize ambient temperature on creation
		if(initial(location))
			ambient_temperature = GetAmbientTemperature(src.elevel)
			cooling_rate = CalculateCoolingRate()
	
	Del()
		if(fire_sound)
			StopObjectSound(fire_sound)
		..()

// ============================================================================
// TEMPERATURE STATE MANAGEMENT
// ============================================================================

	proc/TryLight(mob/M)
		/// Light the heating station - shows feedback, starts heating loop
		if(!M || !ismob(M))
			return FALSE
		
		if(is_lit)
			M << "<font color='orange'><b>[src.name] is already lit.</b>"
			return FALSE
		
		if(fuel_level < 10)
			M << "<font color='orange'><b>[src.name] has no fuel.</b>"
			return FALSE
		
		is_lit = TRUE
		heat_start_time = world.time
		active_user = M
		
		M << "<font color='gold'><b>You light the [src.name]...</b>"
		VisualFeedback("ignite")
		AudioFeedback("light", 100)
		
		spawn() HeatingLoop()
		return TRUE
	
	proc/TryExtinguish(mob/M)
		/// Extinguish the heating station
		if(!M || !ismob(M))
			return FALSE
		
		if(!is_lit)
			M << "<font color='orange'><b>[src.name] is not lit.</b>"
			return FALSE
		
		is_lit = FALSE
		M << "<font color='gray'><b>You extinguish the [src.name].</b>"
		VisualFeedback("extinguish")
		AudioFeedback("extinguish", 50)
		UpdateIconState()
		return TRUE
	
	proc/GetCurrentTemperature()
		/// Calculate current temperature state and visual intensity
		/// Returns: TEMP_COOL, TEMP_WARM, or TEMP_HOT (from TemperatureSystem)
		
		if(!is_lit)
			fire_intensity = 0.0
			return TEMP_COOL
		
		var/elapsed_ticks = world.time - heat_start_time
		var/adjusted_cooling = cooling_rate * (ambient_temperature / 15.0)  // Normalize to base
		
		// Temperature progression (HOT → WARM → COOL)
		// HOT duration: ~240 ticks, WARM duration: ~120 ticks
		if(elapsed_ticks < (240 / adjusted_cooling))
			fire_intensity = 1.0
			return TEMP_HOT
		else if(elapsed_ticks < (360 / adjusted_cooling))
			fire_intensity = 0.6
			return TEMP_WARM
		else
			fire_intensity = 0.2
			return TEMP_COOL

// ============================================================================
// GAMIFIED VISUAL & AUDIO FEEDBACK
// ============================================================================

	proc/VisualFeedback(feedback_type)
		/// Trigger visual feedback for player and world
		set waitfor = 0
		
		switch(feedback_type)
			if("ignite")
				// Color flash on lighting
				icon += "#ffff00"
				spawn(3) if(src) icon -= "#ffff00"
			
			if("extinguish")
				// Color change on extinguishing
				icon += "#888888"
				spawn(2) if(src) icon -= "#888888"
			
			if("temperature_change")
				// Subtle pulse on temperature change
				spawn(1) if(src) UpdateIconState()
	
	proc/AudioFeedback(sound_type, volume = 100)
		/// Play ambient sound effects
		set waitfor = 0
		
		if(fire_sound && sound_type == "light")
			return  // Already playing
		
		switch(sound_type)
			if("light")
				// Ignition sound + switch to ambient
				if(initial(fire_sound))
					fire_sound = AttachObjectSound(src, "fire", 250, volume)
			
			if("extinguish")
				// Extinguish sound
				if(fire_sound)
					StopObjectSound(fire_sound)
					fire_sound = null
	
	proc/UpdateIntensity()
		/// Update visual intensity based on temperature
		UpdateIconState()
	
	proc/UpdateIconState()
		/// Update icon_state to reflect temperature visually
		var/current_temp = GetCurrentTemperature()
		
		switch(current_temp)
			if(TEMP_HOT)
				icon_state = "[station_type]_hot"
			if(TEMP_WARM)
				icon_state = "[station_type]_warm"
			if(TEMP_COOL)
				icon_state = "[station_type]_cool"
		
		if(!is_lit)
			icon_state = "[station_type]_unlit"

// ============================================================================
// HEATING LOOP & FUEL MANAGEMENT
// ============================================================================

	proc/HeatingLoop()
		/// Main loop for heating - continues while fuel available
		set waitfor = 0
		set background = 1
		
		while(is_lit && src && fuel_level > 0)
			fuel_level -= 1
			
			// Update visual temperature state every 10 ticks
			if(world.time % 10 == 0)
				UpdateIntensity()
			
			// Fuel low warning
			if(fuel_level == 10)
				AudioFeedback("fuel_low", 80)
				if(active_user)
					active_user << "<font color='orange'><b>Fuel running low in [src.name]!</b>"
			
			// Auto-extinguish when out of fuel
			if(fuel_level <= 0)
				is_lit = FALSE
				if(active_user)
					active_user << "<font color='gray'><b>[src.name] burns out from lack of fuel.</b>"
				VisualFeedback("extinguish")
				AudioFeedback("extinguish", 100)
				UpdateIntensity()
				return
			
			sleep(1)  // One tick per loop iteration

// ============================================================================
// AMBIENT TEMPERATURE INTEGRATION
// ============================================================================

	proc/CalculateCoolingRate()
		/// Calculate how fast this station cools based on elevation and weather
		/// Returns multiplier 0.5-1.5 (lower = cools faster, higher = cools slower)
		
		// Base on elevation (from WeatherParticles.GetAmbientTemperature)
		var/ambient = GetAmbientTemperature(src.elevel)
		
		// Normalize to base temperature (15)
		var/elevation_factor = ambient / 15.0
		
		// Station-specific cooling characteristics
		var/station_factor = 1.0
		switch(station_type)
			if("torch")
				station_factor = 1.3  // Torches cool faster (open flame)
			if("lamp")
				station_factor = 1.1  // Lamps cool moderately
			if("campfire")
				station_factor = 1.0  // Campfires are medium
			if("forge")
				station_factor = 0.8  // Forges retain heat better (enclosed)
			if("anvil")
				station_factor = 1.2  // Anvils cool quickly (large surface)
		
		return elevation_factor * station_factor
	
	proc/RefreshAmbientTemperature()
		/// Called periodically by weather system to update ambient
		ambient_temperature = GetAmbientTemperature(src.elevel)
		cooling_rate = CalculateCoolingRate()

// ============================================================================
// INTERACTION SYSTEM (E-KEY SUPPORT)
// ============================================================================

	verb/Light()
		set popup_menu = 1
		set src in oview(1)
		set category = "Heating"
		TryLight(usr)
	
	verb/Extinguish()
		set popup_menu = 1
		set src in oview(1)
		set category = "Heating"
		TryExtinguish(usr)
	
	verb/Check_Status()
		set popup_menu = 1
		set src in oview(1)
		set category = "Heating"
		
		var/temp_name = ""
		var/temp_color = ""
		var/current_temp = GetCurrentTemperature()
		
		switch(current_temp)
			if(TEMP_HOT)
				temp_name = "Hot"
				temp_color = "#FF4500"
			if(TEMP_WARM)
				temp_name = "Warm"
				temp_color = "#FFD700"
			if(TEMP_COOL)
				temp_name = "Cool"
				temp_color = "#696969"
		
		var/status = "<font color='gold'><b>[src.name] Status:</b></font><br>"
		status += "State: <font color='[is_lit ? "orange" : "gray"]'>[is_lit ? "Lit" : "Unlit"]</font><br>"
		status += "Temperature: <font color='[temp_color]'>[temp_name]</font><br>"
		status += "Fuel: [fuel_level]%<br>"
		status += "Ambient: [ambient_temperature]°<br>"
		
		usr << status

// ============================================================================
// SPECIALIZED HEATING STATIONS
// ============================================================================

obj/HeatingStation/Torch
	name = "Wooden Torch"
	icon_state = "woodentorch_unlit"
	station_type = "torch"
	max_burn_time = 1800  // 90 seconds
	fuel_level = 100

obj/HeatingStation/Lamp
	name = "Oil Lamp"
	icon_state = "lamp_unlit"
	station_type = "lamp"
	max_burn_time = 7200  // 360 seconds (6 minutes)
	fuel_level = 100

obj/HeatingStation/Campfire
	name = "Campfire"
	icon_state = "fire_unlit"
	station_type = "campfire"
	max_burn_time = 14400  // 720 seconds (12 minutes)
	fuel_level = 100

obj/HeatingStation/Forge
	name = "Forge"
	icon = 'dmi/64/fire.dmi'
	icon_state = "forge_unlit"
	station_type = "forge"
	max_burn_time = 3600
	fuel_level = 100

obj/HeatingStation/Anvil
	name = "Anvil"
	icon = 'dmi/64/creation.dmi'
	icon_state = "anvil"
	station_type = "anvil"
	
	// Anvils don't produce heat, but can be used to test heat-treated items
	proc/CheckStatus(mob/user)
		if(user in range(1, src))
			user << "<font color='gray'>You strike the anvil. The sound rings true.</font>"
			return TRUE
		return FALSE
