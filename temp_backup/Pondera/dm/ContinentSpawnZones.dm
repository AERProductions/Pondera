/*
	ContinentSpawnZones.dm - Continent-Specific Spawn & Rally Points
	
	Defines the spawn locations for new characters and rally points for revival.
	Integrated with:
	- PortHubSystem: Where players spawn on first login
	- LivesSystemIntegration: Where players respawn on Abjure revival
	- DeathPenaltySystem: Where players appear after character reset
	
	Three Continents:
	1. Story (Kingdom of Freedom): PvE, progression-gated, NPC towns
	2. Sandbox (Creative Sandbox): Peaceful, unlimited building, no conflict
	3. Kingdom (Battlelands): PvP, raiding, territorial warfare
*/

// ============================================================================
// STORY CONTINENT SPAWN ZONES
// ============================================================================

/turf/story_spawn_point
	name = "Story Continent Spawn"
	desc = "A safe starting area for new adventurers in the Kingdom of Freedom"
	icon = 'dmi/64/lghtgrss.dmi'
	icon_state = "grass"
	
	New()
		..()
		// Mark this turf as a story spawn zone
		tag = "story_spawn_zone"

/turf/story_rally_point
	name = "Story Rally Point"
	desc = "A sacred ground where fallen warriors are revived"
	icon = 'dmi/64/lghtgrss.dmi'
	icon_state = "grass"
	
	New()
		..()
		// Mark this turf as a story rally point for revival
		tag = "story_rally_point"

// ============================================================================
// SANDBOX CONTINENT SPAWN ZONES
// ============================================================================

/turf/sandbox_spawn_point
	name = "Sandbox Continent Spawn"
	desc = "Welcome to the creative sandbox. Build freely without pressure"
	icon = 'dmi/64/lghtgrss.dmi'
	icon_state = "grass"
	
	New()
		..()
		tag = "sandbox_spawn_zone"

/turf/sandbox_rally_point
	name = "Sandbox Rally Point"
	desc = "A peaceful gathering place for creative builders"
	icon = 'dmi/64/lghtgrss.dmi'
	icon_state = "grass"
	
	New()
		..()
		tag = "sandbox_rally_point"

// ============================================================================
// KINGDOM (PVP) CONTINENT SPAWN ZONES
// ============================================================================

/turf/kingdom_spawn_point
	name = "Kingdom Continent Spawn"
	desc = "Battlelands entrance - territorial warfare and survival awaits"
	icon = 'dmi/64/drkgrss.dmi'
	icon_state = "grass"
	
	New()
		..()
		tag = "kingdom_spawn_zone"

/turf/kingdom_rally_point
	name = "Kingdom Rally Point"
	desc = "Neutral ground where fallen warriors are revived"
	icon = 'dmi/64/drkgrss.dmi'
	icon_state = "grass"
	
	New()
		..()
		tag = "kingdom_rally_point"

// ============================================================================
// SPAWN ZONE HELPER FUNCTIONS
// ============================================================================

/**
 * GetContinentSpawnPoint(continent_name)
 * Get the spawn location for a continent
 * 
 * Used when:
 * - New player logs in for first time
 * - Player selects continent from port hub
 * - Player hard reset via character death
 * 
 * @param continent_name: "story", "sandbox", or "kingdom"
 * @return turf: The spawn point turf, or port hub center if not found
 */
proc/GetContinentSpawnPoint(continent_name)
	switch(continent_name)
		if("story")
			// Find any story spawn point in the world
			for(var/turf/story_spawn_point/SP in world)
				return SP
		
		if("sandbox")
			for(var/turf/sandbox_spawn_point/SP in world)
				return SP
		
		if("kingdom")
			for(var/turf/kingdom_spawn_point/SP in world)
				return SP
	
	// Fallback to port hub if continent not found
	return GetPortHubCenter()

/**
 * GetContinentRallyPoint(continent_name)
 * Get the rally point (revival location) for a continent
 * 
 * Used when:
 * - Player is revived via Abjure spell
 * - Player respawns after faint
 * 
 * @param continent_name: "story", "sandbox", or "kingdom"
 * @return turf: The rally point turf
 */
proc/GetContinentRallyPoint(continent_name)
	switch(continent_name)
		if("story")
			for(var/turf/story_rally_point/RP in world)
				return RP
		
		if("sandbox")
			for(var/turf/sandbox_rally_point/RP in world)
				return RP
		
		if("kingdom")
			for(var/turf/kingdom_rally_point/RP in world)
				return RP
	
	// Fallback: Return port hub center if rally point not found
	return GetPortHubCenter()

/**
 * ValidateAllContinentSpawns()
 * Verify that all three continents have spawn and rally points
 * Called during initialization to ensure zones exist
 * 
 * @return TRUE if all zones valid, FALSE if missing
 */
proc/ValidateAllContinentSpawns()
	var/all_valid = TRUE
	
	// Check Story
	var/story_spawn = FALSE
	var/story_rally = FALSE
	for(var/turf/story_spawn_point/SP in world)
		story_spawn = TRUE
		break
	for(var/turf/story_rally_point/RP in world)
		story_rally = TRUE
		break
	if(!story_spawn || !story_rally)
		world.log << "⚠️ WARNING: Story continent spawn zones missing"
		all_valid = FALSE
	
	// Check Sandbox
	var/sandbox_spawn = FALSE
	var/sandbox_rally = FALSE
	for(var/turf/sandbox_spawn_point/SP in world)
		sandbox_spawn = TRUE
		break
	for(var/turf/sandbox_rally_point/RP in world)
		sandbox_rally = TRUE
		break
	if(!sandbox_spawn || !sandbox_rally)
		world.log << "⚠️ WARNING: Sandbox continent spawn zones missing"
		all_valid = FALSE
	
	// Check Kingdom
	var/kingdom_spawn = FALSE
	var/kingdom_rally = FALSE
	for(var/turf/kingdom_spawn_point/SP in world)
		kingdom_spawn = TRUE
		break
	for(var/turf/kingdom_rally_point/RP in world)
		kingdom_rally = TRUE
		break
	if(!kingdom_spawn || !kingdom_rally)
		world.log << "⚠️ WARNING: Kingdom continent spawn zones missing"
		all_valid = FALSE
	
	if(all_valid)
		world.log << "✅ All continent spawn zones validated"
	
	return all_valid
