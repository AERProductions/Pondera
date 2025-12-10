// WeatherSeasonalIntegration.dm - Phase 37: Seasonal Weather System
// Integrates automatic seasonal weather changes with TimeAdvancementSystem callbacks
// Provides seasonal precipitation, temperature cycles, and environmental effects

#define WEATHER_CLEAR "clear"
#define WEATHER_RAIN "rain"
#define WEATHER_THUNDERSTORM "thunderstorm"
#define WEATHER_SNOW "snow"
#define WEATHER_HAIL "hail"
#define WEATHER_FOG "fog"
#define WEATHER_DUST_STORM "dust_storm"
#define WEATHER_DRIZZLE "drizzle"

// Seasonal weather probabilities
var/list/SEASON_WEATHER_CHANCES = list(
	SEASON_SPRING = list(
		WEATHER_CLEAR = 35,
		WEATHER_DRIZZLE = 30,
		WEATHER_RAIN = 25,
		WEATHER_THUNDERSTORM = 8,
		WEATHER_FOG = 2
	),
	SEASON_SUMMER = list(
		WEATHER_CLEAR = 45,
		WEATHER_DRIZZLE = 15,
		WEATHER_RAIN = 15,
		WEATHER_THUNDERSTORM = 20,
		WEATHER_DUST_STORM = 5
	),
	SEASON_AUTUMN = list(
		WEATHER_CLEAR = 30,
		WEATHER_FOG = 25,
		WEATHER_DRIZZLE = 20,
		WEATHER_RAIN = 20,
		WEATHER_THUNDERSTORM = 5
	),
	SEASON_WINTER = list(
		WEATHER_CLEAR = 35,
		WEATHER_SNOW = 40,
		WEATHER_HAIL = 15,
		WEATHER_FOG = 10
	)
)

// Seasonal temperature baselines (relative units, 0-30 scale)
var/list/SEASON_BASE_TEMPERATURES = list(
	SEASON_SPRING = 16,      // Mild
	SEASON_SUMMER = 24,      // Warm
	SEASON_AUTUMN = 14,      // Cool
	SEASON_WINTER = 8        // Cold
)

// Seasonal temperature variance (random swing)
var/list/SEASON_TEMP_VARIANCE = list(
	SEASON_SPRING = 4,       // ±4 degrees
	SEASON_SUMMER = 6,       // ±6 degrees (hot/cool days)
	SEASON_AUTUMN = 5,       // ±5 degrees (variable)
	SEASON_WINTER = 8        // ±8 degrees (cold/warmer days)
)

// =============================================================================
// SEASONAL WEATHER MANAGER
// =============================================================================

/datum/seasonal_weather_manager
	var
		current_weather = WEATHER_CLEAR
		current_season = SEASON_SPRING
		current_temperature = 16
		weather_change_timer = 0
		weather_change_interval = 300  // ~5 minutes between weather checks
		active = 0

/datum/seasonal_weather_manager/proc/Initialize()
	active = 1
	UpdateWeatherForSeason(season)

/datum/seasonal_weather_manager/proc/UpdateWeatherForSeason(new_season)
	if(!active) return
	
	current_season = new_season
	RollNewWeather()

/datum/seasonal_weather_manager/proc/RollNewWeather()
	// Select weather based on seasonal probabilities
	var/list/chances = SEASON_WEATHER_CHANCES[current_season]
	if(!chances)
		chances = SEASON_WEATHER_CHANCES[SEASON_SPRING]  // Fallback
	
	var/roll = rand(1, 100)
	var/cumulative = 0
	
	for(var/weather_type in chances)
		cumulative += chances[weather_type]
		if(roll <= cumulative)
			SetWeather(weather_type)
			return
	
	// Fallback to clear
	SetWeather(WEATHER_CLEAR)

/datum/seasonal_weather_manager/proc/SetWeather(new_weather)
	if(current_weather == new_weather)
		return  // No change
	
	var/old_weather = current_weather
	current_weather = new_weather
	
	// Apply effects
	ApplyWeatherEffects(new_weather)
	
	// Notify players
	BroadcastWeatherChange(old_weather, new_weather)

/datum/seasonal_weather_manager/proc/ApplyWeatherEffects(weather_type)
	// Display weather visuals to all players
	for(var/mob/players/M in world)
		if(!M || !M.client) continue
		
		switch(weather_type)
			if(WEATHER_CLEAR)
				M.client.screen -= /particles/snow
				M.client.screen -= /particles/rain
				M.client.screen -= /particles/fog
				M.client.screen -= /particles/dust_storm
				M.client.screen -= /particles/hail
				M.client.screen -= /particles/drizzle
			
			if(WEATHER_RAIN)
				M.client.screen += new /particles/rain
			
			if(WEATHER_SNOW)
				M.client.screen += new /particles/snow
			
			if(WEATHER_THUNDERSTORM)
				M.client.screen += new /particles/rain
				// Lightning spawning handled by DynamicWeatherTick
			
			if(WEATHER_FOG)
				M.client.screen += new /particles/fog
			
			if(WEATHER_DUST_STORM)
				M.client.screen += new /particles/dust_storm
			
			if(WEATHER_HAIL)
				M.client.screen += new /particles/hail
			
			if(WEATHER_DRIZZLE)
				M.client.screen += new /particles/drizzle

/datum/seasonal_weather_manager/proc/BroadcastWeatherChange(old_weather, new_weather)
	var/old_desc = GetWeatherDescription(old_weather)
	var/new_desc = GetWeatherDescription(new_weather)
	
	for(var/mob/players/M in world)
		if(!M || !M.client) continue
		LogSystemEvent(M, "weather_change", "The weather has changed: [old_desc] → [new_desc]")

/datum/seasonal_weather_manager/proc/GetWeatherDescription(weather_type)
	switch(weather_type)
		if(WEATHER_CLEAR)
			return "Clear skies"
		if(WEATHER_RAIN)
			return "Rain"
		if(WEATHER_SNOW)
			return "Snowfall"
		if(WEATHER_THUNDERSTORM)
			return "Thunderstorm"
		if(WEATHER_FOG)
			return "Fog"
		if(WEATHER_DUST_STORM)
			return "Dust storm"
		if(WEATHER_HAIL)
			return "Hail"
		if(WEATHER_DRIZZLE)
			return "Drizzle"
	return "Unknown"

/datum/seasonal_weather_manager/proc/UpdateTemperature()
	var/base_temp = SEASON_BASE_TEMPERATURES[current_season]
	var/variance = SEASON_TEMP_VARIANCE[current_season]
	
	if(!base_temp) base_temp = 16
	if(!variance) variance = 4
	
	// Add daily variance (random fluctuation)
	current_temperature = base_temp + rand(-variance, variance)
	
	// Weather modifiers
	switch(current_weather)
		if(WEATHER_SNOW, WEATHER_HAIL)
			current_temperature -= 5  // Much colder
		if(WEATHER_RAIN, WEATHER_DRIZZLE)
			current_temperature -= 2  // Slightly cooler
		if(WEATHER_CLEAR)
			current_temperature += 2  // Slightly warmer
		if(WEATHER_DUST_STORM)
			current_temperature += 4  // Much warmer
	
	// Clamp temperature (0-30 scale)
	current_temperature = max(0, min(30, current_temperature))

/datum/seasonal_weather_manager/proc/GetCurrentWeather()
	return current_weather

/datum/seasonal_weather_manager/proc/GetCurrentTemperature()
	return current_temperature

/datum/seasonal_weather_manager/proc/IsWeatherType(type)
	return current_weather == type

/datum/seasonal_weather_manager/proc/IsWetWeather()
	return current_weather in list(WEATHER_RAIN, WEATHER_THUNDERSTORM, WEATHER_DRIZZLE, WEATHER_HAIL)

/datum/seasonal_weather_manager/proc/IsColdWeather()
	return current_weather in list(WEATHER_SNOW, WEATHER_HAIL) || current_temperature <= 8

/datum/seasonal_weather_manager/proc/IsHotWeather()
	return current_weather == WEATHER_DUST_STORM || current_temperature >= 24

// =============================================================================
// GLOBAL WEATHER SYSTEM INSTANCE
// =============================================================================

var/datum/seasonal_weather_manager/global_seasonal_weather

/proc/InitializeSeasonalWeather()
	if(global_seasonal_weather)
		return
	
	global_seasonal_weather = new /datum/seasonal_weather_manager()
	global_seasonal_weather.Initialize()
	
	RegisterInitComplete("seasonal_weather")

// =============================================================================
// ENVIRONMENTAL EFFECT HOOKS
// =============================================================================

/proc/ApplyWeatherToHunger(mob/players/M)
	// Cold/wet weather increases hunger
	if(!M || !global_seasonal_weather) return
	
	var/temp = global_seasonal_weather.GetCurrentTemperature()
	
	// Cold weather increases hunger/thirst
	if(temp <= 8)
		M.hunger_level = min(1000, M.hunger_level + 20)
	// Hot weather increases thirst
	if(temp >= 24)
		M.thirst_level = min(1000, M.thirst_level + 15)

/proc/ApplyWeatherToMovement(mob/players/M)
	// Storms and deep snow reduce movement speed
	if(!M || !global_seasonal_weather) return
	
	var/weather = global_seasonal_weather.GetCurrentWeather()
	
	switch(weather)
		if(WEATHER_SNOW, WEATHER_HAIL)
			M.MovementSpeed = max(6, M.MovementSpeed + 3)  // -30% speed
		if(WEATHER_THUNDERSTORM)
			M.MovementSpeed = max(4, M.MovementSpeed + 2)  // -20% speed
		if(WEATHER_DUST_STORM)
			M.MovementSpeed = max(5, M.MovementSpeed + 2)  // -20% speed

/proc/ApplyWeatherToCombat(mob/players/attacker, mob/players/defender)
	// Weather affects combat effectiveness
	if(!attacker || !global_seasonal_weather) return
	
	var/weather = global_seasonal_weather.GetCurrentWeather()
	var/damage_mod = 1.0
	
	switch(weather)
		if(WEATHER_THUNDERSTORM)
			// Stormy conditions reduce accuracy
			damage_mod = 0.85
		if(WEATHER_RAIN)
			damage_mod = 0.9
		if(WEATHER_DUST_STORM)
			// Dust reduces visibility
			damage_mod = 0.80
		if(WEATHER_SNOW)
			// Snow reduces mobility and accuracy
			damage_mod = 0.88
	
	return damage_mod

/proc/ApplyWeatherToCropping()
	// Weather affects crop growth
	if(!global_seasonal_weather) return
	
	var/weather = global_seasonal_weather.GetCurrentWeather()
	var/temp = global_seasonal_weather.GetCurrentTemperature()
	var/growth_mod = 1.0
	
	switch(weather)
		if(WEATHER_RAIN, WEATHER_DRIZZLE)
			growth_mod = 1.15  // +15% growth with water
		if(WEATHER_THUNDERSTORM)
			growth_mod = 1.1   // +10% (nitrogen from lightning)
		if(WEATHER_DUST_STORM)
			growth_mod = 0.85  // -15% (visibility and damage)
		if(WEATHER_SNOW, WEATHER_HAIL)
			growth_mod = 0.5   // -50% (dormant in cold)
	
	// Temperature effects
	if(temp <= 5)
		growth_mod *= 0.3     // Very cold = minimal growth
	else if(temp >= 25)
		growth_mod *= 0.8     // Too hot = reduced growth
	
	return growth_mod

// =============================================================================
// WEATHER PREDICTION & FORECASTING
// =============================================================================

/proc/GetWeatherForecast()
	// Return next 3 weather patterns for planning
	if(!global_seasonal_weather) return list()
	
	var/list/forecast = list()
	for(var/i = 1 to 3)
		forecast += list(
			"type" = global_seasonal_weather.current_weather,
			"temperature" = global_seasonal_weather.current_temperature,
			"season" = global_seasonal_weather.current_season
		)
	
	return forecast

// =============================================================================
// DEBUG VERBS FOR WEATHER TESTING
// =============================================================================

/mob/players/verb/SetWeatherNow()
	set name = "Set Weather (Debug)"
	set category = "Debug"
	
	var/list/options = list(
		WEATHER_CLEAR,
		WEATHER_RAIN,
		WEATHER_SNOW,
		WEATHER_THUNDERSTORM,
		WEATHER_FOG,
		WEATHER_DUST_STORM,
		WEATHER_HAIL,
		WEATHER_DRIZZLE
	)
	
	var/choice = input(src, "Select weather:", "Set Weather") as null|anything in options
	if(choice)
		global_seasonal_weather.SetWeather(choice)
		src << "Weather set to [choice]"

/mob/players/verb/ViewWeatherStatus()
	set name = "View Weather Status (Debug)"
	set category = "Debug"
	
	if(!global_seasonal_weather)
		src << "Weather system not initialized"
		return
	
	var/weather = global_seasonal_weather.GetCurrentWeather()
	var/temp = global_seasonal_weather.GetCurrentTemperature()
	var/season = global_seasonal_weather.current_season
	
	src << "\n<b>═══════════════════════════════════</b>"
	src << "<b>WEATHER STATUS</b>"
	src << "<b>═══════════════════════════════════</b>"
	src << "Season: [season]"
	src << "Current Weather: [weather]"
	src << "Temperature: [temp]°C (0-30 scale)"
	src << "Wet: [global_seasonal_weather.IsWetWeather() ? "Yes" : "No"]"
	src << "Cold: [global_seasonal_weather.IsColdWeather() ? "Yes" : "No"]"
	src << "Hot: [global_seasonal_weather.IsHotWeather() ? "Yes" : "No"]"
	src << "<b>═══════════════════════════════════</b>\n"

/mob/players/verb/RollNewWeather()
	set name = "Roll New Weather (Debug)"
	set category = "Debug"
	
	if(global_seasonal_weather)
		global_seasonal_weather.RollNewWeather()
		src << "New weather rolled for [global_seasonal_weather.current_season]"

// =============================================================================
// WEATHER INTEGRATION WITH TIME SYSTEM
// =============================================================================

/proc/OnSeasonalWeatherTick(new_season)
	// Called by TimeAdvancementSystem on season change
	if(!global_seasonal_weather) return
	
	global_seasonal_weather.UpdateWeatherForSeason(new_season)
	global_seasonal_weather.UpdateTemperature()

/proc/OnDailyWeatherTick()
	// Called daily to update temperature and possibly change weather
	if(!global_seasonal_weather) return
	
	global_seasonal_weather.UpdateTemperature()
	
	// 25% chance of weather change daily
	if(prob(25))
		global_seasonal_weather.RollNewWeather()

// =============================================================================
// PARTICLE DEFINITIONS (Already in WeatherParticles.dm, just documenting)
// =============================================================================

/*
Available particles (defined in WeatherParticles.dm):
- particles/fog - Dense fog with slight drift
- particles/mist - Lighter mist effect
- particles/dust_storm - Tan/brown swirling dust
- particles/hail - White ice particles (fast falling)
- particles/drizzle - Light rain
- particles/clear_weather - No particles (clear)
- particles/rain - Heavy rain (already in Particles-Weather.dm)
- particles/snow - Heavy snow (already in Particles-Weather.dm)

Each particle defines:
- count: Number of particles
- spawning: Rate of spawning
- color: RGB hex color
- gravity: Downward/horizontal forces
- drift: Random movement
- lifespan: How long particles persist
*/
