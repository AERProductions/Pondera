// WeatherCombatIntegration.dm - Phase 38A: Weather Effects on Combat
// Integrates weather system with combat mechanics
// Cold/hot weather affects stamina drain, wet weather reduces accuracy, storms reduce visibility

// Weather Combat Modifiers (applied per weather type)
var/list/WEATHER_COMBAT_MODIFIERS = list(
	"clear" = list(
		"damage_modifier" = 1.0,      // Normal damage
		"accuracy_modifier" = 1.0,    // Normal accuracy
		"stamina_drain" = 1.0,        // Normal stamina cost
		"visibility" = 100,           // Full visibility
		"combat_bonus" = 0            // No bonus
	),
	"rain" = list(
		"damage_modifier" = 0.9,      // 10% damage penalty
		"accuracy_modifier" = 0.85,   // 15% accuracy penalty (wet conditions)
		"stamina_drain" = 1.1,        // 10% extra stamina drain (slipping hazard)
		"visibility" = 75,            // 75% visibility
		"combat_bonus" = 0
	),
	"snow" = list(
		"damage_modifier" = 0.8,      // 20% damage penalty (cold numbs strikes)
		"accuracy_modifier" = 0.75,   // 25% accuracy penalty (slick surface)
		"stamina_drain" = 1.3,        // 30% extra stamina drain (trudging through snow)
		"visibility" = 50,            // 50% visibility (snow obscures vision)
		"combat_bonus" = 0
	),
	"thunderstorm" = list(
		"damage_modifier" = 0.85,     // 15% damage penalty (lightning danger, slippery)
		"accuracy_modifier" = 0.7,    // 30% accuracy penalty (chaos of storm)
		"stamina_drain" = 1.4,        // 40% extra stamina drain (fighting elements)
		"visibility" = 40,            // 40% visibility (heavy downpour)
		"combat_bonus" = 0
	),
	"fog" = list(
		"damage_modifier" = 0.95,     // 5% damage penalty (minor)
		"accuracy_modifier" = 0.6,    // 40% accuracy penalty (can't see targets)
		"stamina_drain" = 1.05,       // 5% extra stamina (navigating blind)
		"visibility" = 30,            // 30% visibility (fog wall)
		"combat_bonus" = 0            // Ambush bonus possible with high perception
	),
	"dust_storm" = list(
		"damage_modifier" = 0.88,     // 12% damage penalty (dust reduces impact)
		"accuracy_modifier" = 0.65,   // 35% accuracy penalty (dust clouds vision)
		"stamina_drain" = 1.25,       // 25% extra stamina (breathing, visibility)
		"visibility" = 45,            // 45% visibility
		"combat_bonus" = 0
	),
	"hail" = list(
		"damage_modifier" = 0.82,     // 18% damage penalty (hail is painful, distracting)
		"accuracy_modifier" = 0.7,    // 30% accuracy penalty (loud, painful)
		"stamina_drain" = 1.35,       // 35% extra stamina (dodging hail)
		"visibility" = 55,            // 55% visibility (hail blocks view)
		"combat_bonus" = 0
	),
	"drizzle" = list(
		"damage_modifier" = 0.95,     // 5% damage penalty
		"accuracy_modifier" = 0.9,    // 10% accuracy penalty (light rain)
		"stamina_drain" = 1.05,       // 5% extra stamina drain
		"visibility" = 90,            // 90% visibility
		"combat_bonus" = 0
	)
)

// Temperature-based combat effects
var/list/TEMPERATURE_COMBAT_EFFECTS = list()

/proc/InitializeWeatherCombatSystem()
	// Called from InitializationManager during Phase 6
	// Registers weather combat callbacks
	if(!global_seasonal_weather)
		return
	
	// Build temperature effect table
	BuildTemperatureCombatTable()
	
	// Log system initialization
	LogSystemEvent(null, "system", "Weather-Combat Integration initialized (Phase 38A)")

/proc/BuildTemperatureCombatTable()
	// Create temperature ranges with combat effects
	// Temperature scale: 0-30°C (32-86°F)
	
	TEMPERATURE_COMBAT_EFFECTS = list(
		// Extreme Cold (below 5°C / 41°F)
		list(
			"min_temp" = -100,
			"max_temp" = 5,
			"name" = "Extreme Cold",
			"damage_modifier" = 0.7,    // 30% damage penalty (frostbite, numbed extremities)
			"stamina_drain" = 1.5,      // 50% stamina cost increase
			"accuracy_modifier" = 0.65, // 35% accuracy penalty (shaking from cold)
			"effect_message" = "The biting cold saps your strength!"
		),
		// Cold (5-12°C / 41-54°F)
		list(
			"min_temp" = 5,
			"max_temp" = 12,
			"name" = "Cold",
			"damage_modifier" = 0.85,
			"stamina_drain" = 1.25,
			"accuracy_modifier" = 0.85,
			"effect_message" = "The cold makes every movement sluggish."
		),
		// Cool (12-16°C / 54-61°F)
		list(
			"min_temp" = 12,
			"max_temp" = 16,
			"name" = "Cool",
			"damage_modifier" = 0.95,
			"stamina_drain" = 1.1,
			"accuracy_modifier" = 0.95,
			"effect_message" = "Cool conditions keep you alert."
		),
		// Comfortable (16-24°C / 61-75°F)
		list(
			"min_temp" = 16,
			"max_temp" = 24,
			"name" = "Comfortable",
			"damage_modifier" = 1.0,    // Normal
			"stamina_drain" = 1.0,      // Normal
			"accuracy_modifier" = 1.0,  // Normal
			"effect_message" = "Perfect fighting conditions."
		),
		// Warm (24-28°C / 75-82°F)
		list(
			"min_temp" = 24,
			"max_temp" = 28,
			"name" = "Warm",
			"damage_modifier" = 0.95,
			"stamina_drain" = 1.15,     // 15% extra stamina (heat exhaustion)
			"accuracy_modifier" = 0.95,
			"effect_message" = "The heat drains your energy."
		),
		// Hot (28-35°C / 82-95°F)
		list(
			"min_temp" = 28,
			"max_temp" = 35,
			"name" = "Hot",
			"damage_modifier" = 0.85,
			"stamina_drain" = 1.35,     // 35% stamina penalty (severe heat)
			"accuracy_modifier" = 0.88,
			"effect_message" = "Extreme heat exhaustion affects your combat!"
		),
		// Extreme Heat (above 35°C / 95°F)
		list(
			"min_temp" = 35,
			"max_temp" = 100,
			"name" = "Extreme Heat",
			"damage_modifier" = 0.75,   // 25% damage penalty
			"stamina_drain" = 1.5,      // 50% stamina increase
			"accuracy_modifier" = 0.8,
			"effect_message" = "Deadly heat makes combat nearly impossible!"
		)
	)

/proc/GetWeatherCombatModifier(weather_type)
	// Returns combat modifiers for given weather type
	if(!WEATHER_COMBAT_MODIFIERS[weather_type])
		return WEATHER_COMBAT_MODIFIERS["clear"]  // Default to clear
	
	return WEATHER_COMBAT_MODIFIERS[weather_type]

/proc/GetTemperatureCombatEffect(temperature)
	// Find temperature range and return effect data
	for(var/effect_data in TEMPERATURE_COMBAT_EFFECTS)
		if(temperature >= effect_data["min_temp"] && temperature < effect_data["max_temp"])
			return effect_data
	
	// Default to comfortable
	return TEMPERATURE_COMBAT_EFFECTS[4]

/proc/ApplyWeatherToCombatDamage(mob/attacker, mob/defender, var/base_damage)
	// Calculate final damage with weather modifiers
	if(!global_seasonal_weather) return base_damage
	
	var/current_weather = global_seasonal_weather.current_weather
	var/current_temperature = global_seasonal_weather.current_temperature
	
	// Get weather modifier
	var/list/weather_mods = GetWeatherCombatModifier(current_weather)
	var/damage = base_damage * weather_mods["damage_modifier"]
	
	// Get temperature modifier
	var/list/temp_effect = GetTemperatureCombatEffect(current_temperature)
	damage *= temp_effect["damage_modifier"]
	
	return max(1, damage)  // Minimum 1 damage

/proc/ApplyWeatherToAccuracy(mob/attacker, mob/target)
	// Calculate accuracy penalty based on weather
	// Returns value 0.0-1.0 (% chance to hit)
	
	if(!global_seasonal_weather) return 1.0
	
	var/current_weather = global_seasonal_weather.current_weather
	var/current_temperature = global_seasonal_weather.current_temperature
	
	// Get weather modifier
	var/list/weather_mods = GetWeatherCombatModifier(current_weather)
	var/accuracy = weather_mods["accuracy_modifier"]
	
	// Get temperature modifier
	var/list/temp_effect = GetTemperatureCombatEffect(current_temperature)
	accuracy *= temp_effect["accuracy_modifier"]
	
	return min(1.0, max(0.1, accuracy))  // Clamp to 10-100%

/proc/ApplyWeatherToStaminaDrain(mob/character, var/base_stamina_cost)
	// Calculate stamina drain with weather modifiers
	if(!global_seasonal_weather) return base_stamina_cost
	
	var/current_weather = global_seasonal_weather.current_weather
	var/current_temperature = global_seasonal_weather.current_temperature
	
	// Get weather modifier
	var/list/weather_mods = GetWeatherCombatModifier(current_weather)
	var/stamina_cost = base_stamina_cost * weather_mods["stamina_drain"]
	
	// Get temperature modifier
	var/list/temp_effect = GetTemperatureCombatEffect(current_temperature)
	stamina_cost *= temp_effect["stamina_drain"]
	
	// Note: Character-specific modifiers would go here once stats are available
	// For now, just return weather/temperature modified cost
	
	return stamina_cost

/proc/GetWeatherVisibility()
	// Returns visibility percentage (0-100) based on current weather
	// Used for ranged attack penalties
	
	if(!global_seasonal_weather) return 100
	
	var/current_weather = global_seasonal_weather.current_weather
	var/list/weather_mods = GetWeatherCombatModifier(current_weather)
	
	return weather_mods["visibility"]

/proc/ApplyWeatherCombatEnvironment(mob/character)
	// Apply ambient weather effects during combat
	// Called periodically during active combat
	
	if(!global_seasonal_weather || !character) return
	
	var/current_weather = global_seasonal_weather.current_weather
	var/current_temperature = global_seasonal_weather.current_temperature
	
	// Get temperature effect
	var/list/temp_effect = GetTemperatureCombatEffect(current_temperature)
	
	// Apply message to character based on weather/temp
	if(prob(5))  // 5% chance each tick to show environmental message
		character << temp_effect["effect_message"]
	
	// Weather-specific effects - just informational for now
	switch(current_weather)
		if("thunderstorm")
			// Lightning danger message
			if(prob(1))
				character << "A lightning bolt flashes nearby!"
		
		if("snow", "hail")
			// Slipping hazard message
			if(prob(2))
				character << "Your feet slip on the icy ground!"
		
		if("fog")
			// Disorientation in fog
			if(prob(1))
				character << "The thick fog disorients you..."

/proc/CanCombatOccur(mob/attacker, mob/defender)
	// Check if weather permits combat (e.g., extreme conditions)
	// Returns: 1 = combat OK, 0 = weather too severe
	
	if(!global_seasonal_weather) return 1
	
	var/current_temperature = global_seasonal_weather.current_temperature
	
	// Extreme conditions prevent combat entirely
	if(current_temperature < -10 || current_temperature > 45)
		return 0  // Too extreme to fight
	
	return 1

/proc/GetWeatherCombatDescription()
	// Return text description of current weather's combat impact
	if(!global_seasonal_weather) return "Clear skies provide perfect fighting conditions."
	
	var/current_weather = global_seasonal_weather.current_weather
	var/current_temperature = global_seasonal_weather.current_temperature
	var/list/temp_effect = GetTemperatureCombatEffect(current_temperature)
	
	var/description = ""
	
	switch(current_weather)
		if("clear")
			description = "Clear skies provide perfect visibility and fighting conditions."
		if("rain")
			description = "Rain makes the ground slippery and reduces visibility."
		if("snow")
			description = "Snow reduces visibility dramatically and makes movement treacherous."
		if("thunderstorm")
			description = "A raging thunderstorm creates dangerous conditions - lightning strikes and zero visibility!"
		if("fog")
			description = "Thick fog severely limits visibility, making targeted attacks nearly impossible."
		if("dust_storm")
			description = "A dust storm obscures vision and makes breathing difficult."
		if("hail")
			description = "Hail creates a painful distraction and reduces visibility."
		if("drizzle")
			description = "Light rain creates slightly slippery conditions but mostly clear."
	
	description += " Temperature: [temp_effect["name"]] ([current_temperature]°C) - [temp_effect["effect_message"]]"
	
	return description

// Debug/Admin verbs

/mob/verb/ViewWeatherCombatStatus()
	set category = "Debug"
	set name = "View Weather Combat Status"
	
	var/msg = "=== WEATHER COMBAT STATUS ===\n"
	msg += GetWeatherCombatDescription()
	msg += "\n\n=== WEATHER MODIFIERS ===\n"
	
	if(global_seasonal_weather)
		var/list/mods = GetWeatherCombatModifier(global_seasonal_weather.current_weather)
		msg += "Damage: [mods["damage_modifier"]] (x multiplier)\n"
		msg += "Accuracy: [mods["accuracy_modifier"]] (x multiplier)\n"
		msg += "Stamina Drain: [mods["stamina_drain"]] (x multiplier)\n"
		msg += "Visibility: [mods["visibility"]]%\n"
	
	msg += "\n=== TEMPERATURE EFFECTS ===\n"
	var/list/temp = GetTemperatureCombatEffect(global_seasonal_weather ? global_seasonal_weather.current_temperature : 20)
	msg += "Effect: [temp["name"]]\n"
	msg += "Message: [temp["effect_message"]]\n"
	msg += "Damage Mod: [temp["damage_modifier"]]\n"
	msg += "Stamina Drain Mod: [temp["stamina_drain"]]\n"
	msg += "Accuracy Mod: [temp["accuracy_modifier"]]\n"
	
	usr << msg

/mob/verb/TestCombatModifier()
	set category = "Debug"
	set name = "Test Combat Damage Modifier"
	var/base_damage = input("Base damage amount:", "number") as num
	
	var/final_damage = ApplyWeatherToCombatDamage(usr, null, base_damage)
	var/accuracy = ApplyWeatherToAccuracy(usr, null)
	var/stamina = ApplyWeatherToStaminaDrain(usr, 10)
	
	usr << "Base Damage: [base_damage]"
	usr << "Final Damage: [final_damage]"
	usr << "Accuracy: [accuracy*100]%"
	usr << "Stamina Cost: [stamina]"
