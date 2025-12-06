// LightningSystem.dm — Dynamic lightning strikes with particles, sound, and damage

// ==================== LIGHTNING PARTICLE EFFECTS ====================

particles/lightning_strike
	width = 1500
	height = 1500
	count = 150
	spawning = 30
	bound1 = list(-1000, -300, -1000)
	lifespan = 300
	fade = 50
	color = "ffff99"
	position = generator("box", list(-100, -100, 0), list(100, 400, 100))
	gravity = list(0, 0)
	friction = 0.3
	drift = generator("sphere", 0, 2)

particles/lightning_ground_effect
	width = 1500
	height = 1500
	count = 200
	spawning = 40
	bound1 = list(-1000, -300, -1000)
	lifespan = 250
	fade = 60
	color = "ffff66"
	position = generator("box", list(-200, 0, 0), list(200, 50, 50))
	gravity = list(0, -0.1)
	friction = 0.5
	drift = generator("sphere", 0, 1.5)

// ==================== LIGHTNING STRIKE OBJECT ====================

obj/lightning_strike
	screen_loc = "CENTER"
	var
		impact_location = null
		strike_radius = 250
		strike_damage = 35
		strike_stun_duration = 4

	New(location, radius = 250, damage = 35, stun = 4)
		..()
		impact_location = location
		strike_radius = radius
		strike_damage = damage
		strike_stun_duration = stun
		spawn() ExecuteStrike()

	proc/ExecuteStrike()
		set waitfor = 0
		
		// Visual effect: flash
		if(impact_location)
			var/turf/strike_turf = impact_location
			if(!isturf(strike_turf))
				// If it's a movable object, get the turf it's on
				var/atom/A = impact_location
				strike_turf = A.loc
				while(A && !isturf(strike_turf))
					A = strike_turf
					strike_turf = A.loc
			
			if(strike_turf && isturf(strike_turf))
				// Create ground scorch mark
				CreateScorchMark(strike_turf)
				
				// Spawn particles
				var/obj/lightning_visual/visual = new(strike_turf)
				spawn(20) if(visual) del visual
				
				// Apply damage to nearby mobs
				DamageNearbyMobs(strike_turf)
				
				// Apply damage to turfs
				DamageNearbyTurfs(strike_turf)
				
				// Stun notification
				for(var/mob/players/M in view(5, strike_turf))
					M << "<font color='yellow'><b>Lightning strikes nearby!</b>"

	proc/CreateScorchMark(turf/T)
		set waitfor = 0
		if(!T) return
		
		// Create temporary scorch mark on ground
		var/obj/scorch_mark/scorch = new(T)
		spawn(300) if(scorch) del scorch  // Persist for 15 seconds

	proc/DamageNearbyMobs(turf/center)
		set waitfor = 0
		if(!center) return
		
		for(var/mob/M in range(strike_radius, center))
			if(!istype(M, /mob/players)) continue
			
			var/mob/players/P = M
			
			// Stun the player
			P.Stunned = strike_stun_duration
			P << "<font color='red'><b>You are struck by lightning!</b>"
			
			// Apply damage with some variance
			var/damage = strike_damage + rand(-10, 10)
			P.HP -= damage
			
			// Visual feedback
			P.icon += "#ffff00"  // Yellow tint
			spawn(3) if(P) P.icon -= "#ffff00"

	proc/DamageNearbyTurfs(turf/center)
		set waitfor = 0
		if(!center) return
		
		// Scorch random turfs in area
		for(var/turf/T in range(strike_radius / 2, center))
			if(prob(15))  // 15% chance each turf gets damaged
				CreateScorchMark(T)

// ==================== VISUAL LIGHTNING EFFECT ====================

obj/lightning_visual
	screen_loc = "CENTER"
	particles = new/particles/lightning_strike
	
	New(location)
		..()
		loc = location

obj/scorch_mark
	name = "scorched ground"
	icon = 'dmi/64/gen.dmi'
	icon_state = "grass"
	color = "#333333"
	opacity = 0
	density = 0
	layer = 1
	
	New(location)
		..()
		loc = location

// ==================== LIGHTNING WEATHER CONTROLLER ====================

var
	global/lightning_controller/lightning_mgr

lightning_controller
	var
		active_thunderstorm = FALSE
		last_strike_time = 0
		strike_interval = 0  // Ticks between strikes
		strike_chance_per_tick = 0
		zone_id = null

	New()
		..()
		InitializeThunderstorm()

	proc/InitializeThunderstorm()
		active_thunderstorm = FALSE
		last_strike_time = 0
		strike_interval = 100  // Default ~5 seconds between strikes
		strike_chance_per_tick = 5  // 5% chance per tick when storm active

	proc/StartThunderstorm(zone_id_param = 0)
		/**
		 * Initiate a thunderstorm with periodic lightning strikes
		 */
		active_thunderstorm = TRUE
		zone_id = zone_id_param
		spawn() RunThunderstormLoop()

	proc/StopThunderstorm()
		/**
		 * End the thunderstorm
		 */
		active_thunderstorm = FALSE

	proc/RunThunderstormLoop()
		set waitfor = 0
		set background = 1
		
		while(active_thunderstorm)
			// Check if enough time has passed for another strike
			if(world.time >= last_strike_time + strike_interval)
				if(prob(strike_chance_per_tick))
					TriggerRandomLightningStrike()
					last_strike_time = world.time
			
			sleep(10)  // Check every tick

	proc/TriggerRandomLightningStrike(location = null)
		/**
		 * Trigger a lightning strike at random or specific location
		 */
		if(!location)
			// Random location in world
			var/random_x = rand(1, world.maxx)
			var/random_y = rand(1, world.maxy)
			location = locate(random_x, random_y, 2)
		
		if(location)
			TriggerLightningStrike(location)

	proc/TriggerLightningStrike(location, radius = 250, damage = 35, stun = 4)
		/**
		 * Execute a lightning strike at specific location
		 * @param location: Strike center
		 * @param radius: Damage radius
		 * @param damage: Base damage to mobs
		 * @param stun: Stun duration in ticks
		 */
		
		if(!location) return
		
		// Play thunder sound
		PlayThunderSound(location)
		
		// Create lightning visual effect
		var/obj/lightning_strike/strike = new(location, radius, damage, stun)

// ==================== LIGHTNING SOUND SYSTEM ====================

proc/PlayThunderSound(location)
	/**
	 * Play thunder sound - add to SoundManager
	 */
	if(!sound_mgr) return
	
	// Register thunder sound if not already done
	if(!sound_mgr.sound_properties["thunder"])
		sound_mgr.AddCustomSound(
			"thunder",
			'snd/wind.ogg',  // Placeholder - use wind for now
			800,             // Wide radius
			90,              // Loud
			"weather",
			FALSE            // One-shot
		)
	
	// Play the sound
	sound_mgr.PlayEffectSound("thunder", location)

// ==================== BIOME-INTEGRATED THUNDERSTORM SYSTEM ====================

// Called from DynamicZoneManager or WeatherParticles
proc/ApplyThunderstormWeather(weather_type, zone_location, zone_id = 0)
	/**
	 * Apply thunderstorm effects based on weather type
	 * @param weather_type: Weather condition ("hail", "thunderstorm", etc.)
	 * @param zone_location: Location to center storms
	 * @param zone_id: Optional zone identifier
	 */
	
	if(!lightning_mgr)
		lightning_mgr = new /lightning_controller()
	
	switch(weather_type)
		if("hail", "thunderstorm")
			// Start thunderstorm with lightning
			if(!lightning_mgr.active_thunderstorm)
				lightning_mgr.StartThunderstorm(zone_id)
				world.log << "Thunderstorm started in zone [zone_id]"
		else
			// Clear weather - stop any active thunderstorm
			if(lightning_mgr.active_thunderstorm)
				lightning_mgr.StopThunderstorm()
				world.log << "Thunderstorm ended"

// ==================== PLAYER STUN/DAMAGE EXTENSION ====================

mob/players
	var/Stunned = 0  // Stun counter in ticks

	// In movement code or a tick loop:
	proc/UpdateStunStatus()
		if(Stunned > 0)
			Stunned -= 1
			if(Stunned == 0)
				src << "<font color='green'>You recover from the shock!"

// ==================== DYNAMIC ZONE WEATHER ENHANCEMENT ====================

// Lightning is triggered automatically from ApplyBiomeWeather when weather_type == "thunderstorm"
// No additional code needed in dynamic_zone - the weather type selection in DynamicZoneManager
// already includes thunderstorm chances, and ApplyBiomeWeather handles lightning activation.

// ==================== INITIALIZATION ====================

proc/InitLightningSystem()
	/**
	 * Initialize the global lightning controller
	 * Call this during world startup
	 */
	
	if(!lightning_mgr)
		lightning_mgr = new /lightning_controller()
		world.log << "Lightning System initialized"

// Hook into world initialization (already called in world/New via _debugtimer.dm)
world/New()
	..()
	InitLightningSystem()
