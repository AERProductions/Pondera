// EnvironmentalTemperatureSystem.dm
// Elevation-aware environmental temperature with seasonal/biome scaling
// Gating: No shelter + extreme conditions = damage + movement penalty
// Fire/Torch/Brazier mitigate cold; Shelter blocks exposure

#define ENV_TEMP_COMFORTABLE 0
#define ENV_TEMP_COLD 1
#define ENV_TEMP_FREEZING 2
#define ENV_TEMP_HOT 3
#define ENV_TEMP_SCORCHING 4

#define MIN_SAFE_TEMP 5
#define MAX_SAFE_TEMP 25

var/list/active_shelters = list()
var/env_temperature_initialized = FALSE

/mob/players
	var/env_temperature = 15
	var/env_temp_state = ENV_TEMP_COMFORTABLE
	var/in_shelter = FALSE
	var/has_warm_clothing = FALSE
	var/last_cold_damage_time = 0

proc/InitializeEnvironmentalTemperature()
	set background = 1
	set waitfor = 0
	
	if(env_temperature_initialized)
		return
	
	env_temperature_initialized = TRUE
	spawn(1) EnvironmentalTemperatureTick()

proc/EnvironmentalTemperatureTick()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(10)  // Check every ~50ms
		
		for(var/mob/players/M in world.contents)
			if(M && M.client)
				UpdateEnvironmentalTemperature(M)

proc/UpdateEnvironmentalTemperature(mob/players/M)
	if(!M || !M.client)
		return
	
	// Base biome temperature
	var/biome_temp = GetBiomeBaseTemp(M.z)
	
	// Elevation modifier: Higher = colder
	var/elevation_mod = GetElevationTempModifier(M.elevel)
	
	// Seasonal temperature
	var/season_mod = GetSeasonalTempModifier()
	
	// Mitigation bonuses
	var/shelter_bonus = M.in_shelter ? 10 : 0
	var/fire_bonus = HasActiveFire(M.loc) ? 6 : 0
	var/clothing_bonus = M.has_warm_clothing ? 4 : 0
	
	M.env_temperature = biome_temp + elevation_mod + season_mod + shelter_bonus + fire_bonus + clothing_bonus
	
	M.env_temp_state = GetEnvironmentalTempState(M.env_temperature)
	
	// Freezing damage
	if(M.env_temp_state == ENV_TEMP_FREEZING)
		if(world.time - M.last_cold_damage_time > 300)  // Every ~1.5 seconds
			if(M.stamina)
				M.stamina = max(0, M.stamina - 15)
			M.last_cold_damage_time = world.time
			M << "You are freezing!"
			if(M.stamina <= 0)
				M << "You are too exhausted from the cold to continue."
	
	// Scorching damage (less common, slower)
	if(M.env_temp_state == ENV_TEMP_SCORCHING)
		if(world.time - M.last_cold_damage_time > 500)
			if(M.stamina)
				M.stamina = max(0, M.stamina - 5)
			M.last_cold_damage_time = world.time
			M << "You are scorching in the heat!"
	
	// Cold movement penalty
	if(M.env_temp_state == ENV_TEMP_COLD || M.env_temp_state == ENV_TEMP_FREEZING)
		M.MovementSpeed = max(7, M.MovementSpeed + 3)

proc/GetEnvironmentalTempState(temp)
	if(temp < MIN_SAFE_TEMP)
		return ENV_TEMP_FREEZING
	if(temp < 10)
		return ENV_TEMP_COLD
	if(temp > MAX_SAFE_TEMP && temp <= 30)
		return ENV_TEMP_HOT
	if(temp > 30)
		return ENV_TEMP_SCORCHING
	return ENV_TEMP_COMFORTABLE

proc/GetBiomeBaseTemp(z)
	// TODO: Query actual biome from z-level database
	// For now: temperate baseline
	return 15

proc/GetElevationTempModifier(elevel)
	// Simplified: each 0.5 elevation level = 2 degree drop
	// Elevation 1.0 (ground) = 0 modifier
	// Elevation 1.5 (stairs) = -2 modifier
	// Elevation 2.0 (second level) = -4 modifier
	if(elevel <= 1.0)
		return 0
	return -(elevel - 1.0) * 4

proc/GetSeasonalTempModifier()
	// Simplified seasonal cycle
	// Winter: -15 to 0 degrees
	// Spring: +0 to +10 degrees
	// Summer: +10 to +20 degrees
	// Autumn: +0 to -10 degrees
	
	// Use world time to determine season (cycles every ~400 ticks * 4 = 1600 ticks per full year)
	var/season_tick = (world.time / 100) % 4
	
	switch(season_tick)
		if(0)  // Spring
			return 8
		if(1)  // Summer
			return 18
		if(2)  // Autumn
			return 5
		if(3)  // Winter
			return -12
	
	return 0

proc/CanSurviveEnvironment(mob/M)
	if(!M)
		return FALSE
	
	var/mob/players/player = M
	if(!istype(player))
		return TRUE  // NPCs ignore temperature
	
	// Comfortable or hot: always survivable
	if(player.env_temp_state == ENV_TEMP_COMFORTABLE || player.env_temp_state == ENV_TEMP_HOT)
		return TRUE
	
	// Cold: need shelter OR fire
	if(player.env_temp_state == ENV_TEMP_COLD)
		return (player.in_shelter || HasActiveFire(player.loc))
	
	// Freezing: need BOTH shelter AND (fire OR warm clothing)
	if(player.env_temp_state == ENV_TEMP_FREEZING)
		if(!player.in_shelter)
			return FALSE
		return HasActiveFire(player.loc) || player.has_warm_clothing
	
	return TRUE

proc/EnterShelter(mob/players/M)
	if(!M)
		return FALSE
	
	M.in_shelter = TRUE
	M << "You enter the shelter. You feel warmer."
	return TRUE

proc/ExitShelter(mob/players/M)
	if(!M)
		return FALSE
	
	M.in_shelter = FALSE
	M << "You exit the shelter."
	return TRUE

proc/EquipWarmClothing(mob/players/M)
	if(!M)
		return FALSE
	
	M.has_warm_clothing = TRUE
	M << "You put on warm clothing."
	return TRUE

proc/RemoveWarmClothing(mob/players/M)
	if(!M)
		return FALSE
	
	M.has_warm_clothing = FALSE
	M << "You remove warm clothing."
	return TRUE
