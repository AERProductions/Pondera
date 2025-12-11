/**
================================================================================
  Hunger & Thirst System - Environmental Integration
================================================================================

Comprehensive metabolic simulation integrating with:
- Temperature system (extreme cold/heat increases consumption)
- Weather effects (dehydration in deserts, exhaustion in rain)
- Elevation changes (thin air exhaustion, alpine weather effects)
- Biome types (resource availability, water sources)
- Physical activities (running, combat, climbing)

Features:
- Realistic consumption rates modified by environment
- Health & stamina penalty degradation
- Condition-based effects (minor cold, exhaustion, weakness)
- Food/drink messaging integrated with ambient conditions
- Recovery mechanics tied to food quality
- Persistence via VitalState.dm

Design: Modern timer-based system with tick loop, environment aware consumption rates.
Maintains backward compatibility with existing food/drink items.

================================================================================
*/

/**
 * CONSUMPTION RATES (per tick)
 * Affected by: elevel, weather_type, ambient_temp
 */
#define HUNGER_TICK_BASE       1      // Base hunger damage per tick
#define THIRST_TICK_BASE       1      // Base thirst damage per tick
#define HUNGER_CHECK_INTERVAL  100    // Ticks between hunger messages (~10 seconds)
#define THIRST_CHECK_INTERVAL  100    // Ticks between thirst messages (~10 seconds)

/**
 * Consumption modifiers based on environment
 */
#define CONSUMPTION_EXTREME_COLD    1.5  // High altitude/arctic: faster metabolism
#define CONSUMPTION_COLD            1.2  // Mountains/highlands
#define CONSUMPTION_NORMAL          1.0  // Temperate zones
#define CONSUMPTION_HOT             1.4  // Desert/arid: faster dehydration
#define CONSUMPTION_EXTREME_HOT      1.7  // Peak temperatures
#define CONSUMPTION_WATER_FATIGUE   1.3  // In water/swamp: stamina drain

/**
 * Activity modifiers (during movement/combat)
 */
#define ACTIVITY_RUNNING           2.0   // Sprint increases consumption
#define ACTIVITY_WALKING           1.0   // Normal movement
#define ACTIVITY_SWIMMING          1.5   // Water movement
#define ACTIVITY_CLIMBING          1.6   // Elevation changes
#define ACTIVITY_FIGHTING          2.2   // Combat exertion

/**
 * CONDITION THRESHOLDS
 */
#define HUNGER_WARNING_THRESHOLD     200  // Warn at hunger level
#define HUNGER_CRITICAL_THRESHOLD     50  // Critical hunger
#define THIRST_WARNING_THRESHOLD     200  // Warn at thirst level
#define THIRST_CRITICAL_THRESHOLD     50  // Critical thirst

/**
 * CONDITION EFFECTS
 */
#define CONDITION_MINOR_COLD       "minor_cold"        // Elevel > 2.5, ambient_temp < 5°C
#define CONDITION_EXHAUSTION       "exhaustion"        // Stamina < 100
#define CONDITION_WEAKNESS         "weakness"          // HP < 50
#define CONDITION_DEHYDRATION      "dehydration"       // Thirst critical
#define CONDITION_STARVATION       "starvation"        // Hunger critical


/**
 * === HUNGER & THIRST TICK LOOP ===
 * Runs in background, updates hunger/thirst based on environment
 */

/mob/players/proc/HungerThirstTickLoop()
	set background = 1
	set waitfor = 0
	
	var/tick_count = 0
	var/last_elevel = 1.0
	var/last_ambient_temp = 15
	var/last_weather_type = "clear"
	var/last_biome_type = "temperate"
	var/consumption_modifier = 1.0
	
	while(src && src.client)
		tick_count++
		
		// Update environment cache every 10 ticks
		if(tick_count % 10 == 0)
			last_elevel = src.elevel ? src.elevel : 1.0
			last_ambient_temp = src.ambient_temp ? src.ambient_temp : 15
			last_weather_type = "clear"
			last_biome_type = "temperate"
			
			// Get zone biome info
			if(zone_mgr && zone_mgr.active_zones)
				for(var/dynamic_zone/dz in zone_mgr.active_zones)
					var/chunk_center_x = dz.chunk_x * zone_mgr.chunk_size + (zone_mgr.chunk_size / 2)
					var/chunk_center_y = dz.chunk_y * zone_mgr.chunk_size + (zone_mgr.chunk_size / 2)
					var/distance = sqrt((src.x - chunk_center_x) ** 2 + (src.y - chunk_center_y) ** 2)
					if(distance < 50)
						last_biome_type = dz.terrain_type ? dz.terrain_type : "temperate"
						last_weather_type = dz.weather_type ? dz.weather_type : "clear"
						break
		
		// Calculate consumption modifier
		consumption_modifier = 1.0
		
		// SEASONAL INTEGRATION (Phase C WIN #8)
		// Apply seasonal consumption modifier (winter increases hunger, summer decreases)
		var/seasonal_modifier = GetConsumptionRateModifier()
		if(seasonal_modifier)
			consumption_modifier *= seasonal_modifier
		
		// Temperature-based consumption
		if(last_ambient_temp < 5)
			consumption_modifier += 0.5  // Extreme cold
		else if(last_ambient_temp < 10)
			consumption_modifier += 0.2  // Cold
		else if(last_ambient_temp > 30)
			consumption_modifier += 0.4  // Hot (dehydration)
		else if(last_ambient_temp > 35)
			consumption_modifier += 0.7  // Extreme heat
		
		// Elevation-based consumption
		if(last_elevel >= 2.5)
			consumption_modifier += 0.3  // Peak altitude: thin air
		else if(last_elevel >= 2.0)
			consumption_modifier += 0.15 // High mountain
		else if(last_elevel < 1.0)
			consumption_modifier += 0.2  // Water level: swimming
		
		// Biome-specific modifiers
		switch(last_biome_type)
			if("desert")
				consumption_modifier += 0.3  // Desert: rapid dehydration
			if("arctic")
				consumption_modifier += 0.25 // Arctic: cold metabolism
			if("water")
				consumption_modifier += 0.2  // Water/swamp: fatigue
		
		// Weather effects
		switch(last_weather_type)
			if("thunderstorm")
				consumption_modifier += 0.15 // Heavy exertion
			if("rain")
				consumption_modifier += 0.1  // Slight exhaustion
			if("dust_storm")
				consumption_modifier += 0.2  // Dehydration
		
		// Apply hunger/thirst damage
		var/hunger_damage = round(HUNGER_TICK_BASE * consumption_modifier)
		var/thirst_damage = round(THIRST_TICK_BASE * consumption_modifier)
		
		src.hunger_level += hunger_damage
		src.thirst_level += thirst_damage
		
		src.hunger_level = min(src.hunger_level, 1000)
		src.thirst_level = min(src.thirst_level, 1000)
		
		// Apply HP penalty if starving
		if(src.hunger_level > HUNGER_CRITICAL_THRESHOLD)
			src.HP = max(0, src.HP - 1)
			src.updateHP()
		
		// Apply stamina penalty if dying of thirst
		if(src.thirst_level > THIRST_CRITICAL_THRESHOLD)
			src.stamina = max(0, src.stamina - 1)
			src.updateST()
		
		// Send periodic messages
		if(tick_count % HUNGER_CHECK_INTERVAL == 0)
			SendHungerMessage()
		
		if(tick_count % THIRST_CHECK_INTERVAL == 0)
			SendThirstMessage()
		
		sleep(10)  // Tick every 1 second

/mob/players/proc/SendHungerMessage()
	if(!src || !src.client || src.hunger_level < 50) return
	
	var/message = ""
	var/color = "#FFFFFF"
	
	switch(src.hunger_level)
		if(51 to 150)
			message = "You are getting a bit peckish..."
			color = "#FFFF99"
		if(151 to 300)
			message = "Your stomach is rumbling. You should find something to eat."
			color = "#FFCC66"
		if(301 to 500)
			message = "You are quite hungry. Food would be nice."
			color = "#FF9966"
		if(501 to 750)
			message = "<b>You are very hungry!</b> Your hunger is affecting your performance."
			color = "#FF6633"
		if(751 to 1000)
			message = "<b><font color='#FF0000'>You are STARVING! You must eat immediately!</font></b>"
			color = "#FF0000"
	
	if(message)
		src << "<font color='[color]'>[message]</font>"

/mob/players/proc/SendThirstMessage()
	if(!src || !src.client || src.thirst_level < 50) return
	
	var/message = ""
	var/color = "#FFFFFF"
	
	switch(src.thirst_level)
		if(51 to 150)
			message = "You could use a drink..."
			color = "#99CCFF"
		if(151 to 300)
			message = "Your mouth is dry. You should find something to drink."
			color = "#66CCFF"
		if(301 to 500)
			message = "You are quite thirsty. Water would be nice."
			color = "#3399FF"
		if(501 to 750)
			message = "<b>You are very thirsty!</b> Your thirst is sapping your stamina."
			color = "#0066FF"
		if(751 to 1000)
			message = "<b><font color='#0000FF'>You are PARCHED! You must drink immediately!</font></b>"
			color = "#0000FF"
	
	if(message)
		src << "<font color='[color]'>[message]</font>"

/**
 * === FOOD/DRINK ITEM INTEGRATION ===
 * Modern interface for consuming food/drink
 */
// Note: ACTIVITY_* and CONDITION_* macros already defined above; reusing them

/**
 * CONDITION EFFECTS
 */
/**
 * === FOOD/DRINK ITEM INTEGRATION ===
 * Modern interface for consuming food/drink
 */

/mob/players/proc/ConsumeFoodItem(food_name, nutrition_amount, hydration_amount=0, recovery_hp=0, recovery_stamina=0)
	/**
	 * ConsumeFoodItem()
	 * Modern interface for consuming food/drink
	 * Replaces scattered eat/drink code throughout codebase
	 * 
	 * Integrates with ConsumptionManager for:
	 * - Seasonal quality modifiers
	 * - Biome-based nutrition bonuses
	 * - Environmental impact on food value
	 * 
	 * Usage:
	 *   usr.ConsumeFoodItem("bread", 250, 50, 0, 20)
	 *   usr.ConsumeFoodItem("water", 0, 350, 0, 50)
	 */
	
	// Initialize system if needed
	if(!hunger_state)
		InitializeHungerThirstSystem()
	
	// Get consumable quality from ConsumptionManager
	var/quality = GetConsumableQuality(food_name, src)
	var/env_impact = EnvironmentalImpactOnConsumables(src)
	var/final_quality = quality * env_impact
	
	// Apply food (with quality modifier)
	if(nutrition_amount > 0)
		var/adjusted_nutrition = round(nutrition_amount * final_quality)
		hunger_level = max(0, hunger_level - adjusted_nutrition)
		fed = 1
		if(nutrition_amount > 250)
			src << "<b>That was a satisfying meal.</b>"
		else if(nutrition_amount > 150)
			src << "That was a good snack."
		else
			src << "You ate something."
	
	// Apply drink (with quality modifier)
	if(hydration_amount > 0)
		var/adjusted_hydration = round(hydration_amount * final_quality)
		thirst_level = max(0, thirst_level - adjusted_hydration)
		hydrated = 1
		if(hydration_amount > 250)
			src << "<b>Ahh, that was refreshing!</b>"
		else if(hydration_amount > 150)
			src << "That helped quench your thirst."
		else
			src << "You took a drink."
	
	// Apply recovery (also quality-affected)
	if(recovery_hp > 0)
		var/adjusted_hp = round(recovery_hp * final_quality)
		src.HP = min(src.HP + adjusted_hp, src.MAXHP)
		src.updateHP()
	
	if(recovery_stamina > 0)
		var/adjusted_stamina = round(recovery_stamina * final_quality)
		src.stamina = min(src.stamina + adjusted_stamina, src.MAXstamina)
		src.updateST()
	
	return 1

/mob/players/proc/GetHungerThirstStatus()
	/**
	 * GetHungerThirstStatus()
	 * Returns current hunger/thirst level and condition descriptions
	 */
	if(!hunger_state)
		return "No hunger system active"
	
	var/status = ""
	status += "Hunger Level: [hunger_level]/1000\n"
	status += "Thirst Level: [thirst_level]/1000\n"
	
	// Build condition list
	var/conditions = ""
	if(elevel > 2.5 && ambient_temp < 5)
		conditions += "Chilled. "
	if(stamina < 100)
		conditions += "Exhausted. "
	if(HP < 50)
		conditions += "Weak. "
	if(thirst_level > 750)
		conditions += "Severely Dehydrated. "
	if(hunger_level > 750)
		conditions += "Starving. "
	
	status += "Conditions: [conditions ? conditions : "Fine"]"
	
	return status

/mob/players/proc/InitializeHungerThirstSystem()
	/**
	 * InitializeHungerThirstSystem()
	 * Called during player Login() to set up hunger/thirst tracking
	 */
	
	if(hunger_state)
		return  // Already initialized
	
	hunger_state = 1  // Flag that system is active
	
	// Start the main tick loop in the background
	spawn(0)
		HungerThirstTickLoop()
	
	return 1


