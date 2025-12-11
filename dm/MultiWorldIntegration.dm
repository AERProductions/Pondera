// MultiWorldIntegration.dm - Phase F: Multi-World System Integration
// Handles character progression continuity across continents

/proc/InitializeMultiWorldSystem()
	if(!continents)
		return
	
	VerifyMultiWorldData()
	world << "MULTI Multi-World Integration Initialized - Character persistence, skill sharing, continent travel"

// ============================================================================
// MULTI-WORLD DATA VERIFICATION
// ============================================================================

/proc/VerifyMultiWorldData()
	// Verify all continents have proper configuration
	if(!continents || continents.len < 3)
		world << "MULTI ERROR: Continents not initialized"
		return 0
	
	// Verify continent data structure
	for(var/cont_id in continents)
		var/datum/continent/cont = continents[cont_id]
		if(!cont)
			world << "MULTI ERROR: Null continent [cont_id]"
			continue
		
		// Ensure port coordinates exist
		if(!cont.port_x) cont.port_x = rand(1, 100)
		if(!cont.port_y) cont.port_y = rand(1, 100)
		if(!cont.port_z) cont.port_z = 1
	
	return 1

// ============================================================================
// CHARACTER PERSISTENCE - Continent Position Tracking
// ============================================================================

/proc/SaveContinentPosition(mob/players/player, continent_id, x, y, z)
	// Save player location for this continent
	if(!player) return 0
	
	if(!player.continent_positions)
		player.continent_positions = list()
	
	player.continent_positions[continent_id] = list(x, y, z)
	return 1

/proc/GetContinentPosition(mob/players/player, continent_id)
	// Get saved position for continent, or return spawn point
	if(!player || !player.continent_positions)
		return GetContinentSpawnPoint(continent_id)
	
	var/pos = player.continent_positions[continent_id]
	if(!pos)
		return GetContinentSpawnPoint(continent_id)
	
	return pos

// GetContinentSpawnPoint is defined in Portals.dm - reuse it

// ============================================================================
// CONTINENT SWITCHING SYSTEM
// ============================================================================

/proc/TravelToContinentAsPlayer(mob/players/player, destination_continent)
	// Switch player to a different continent
	if(!player) return 0
	
	var/datum/continent/dest = GetContinent(destination_continent)
	if(!dest)
		if(player) player << "MULTI ERROR: Destination continent not found"
		return 0
	
	// ANTI-CHEESE: One-way Ascension Mode enforcement
	// If player is locked into Ascension Mode, block travel to other continents
	if(player.character.ascension_locked_in && destination_continent != CONT_ASCENSION)
		player << "<font color=#FF6B6B>ERROR: You have entered Ascension Mode permanently.</font>"
		player << "<font color=#FF6B6B>Your character's ascension progress cannot be exported to other game modes.</font>"
		player << "<font color=#FF6B6B>To play Story/Sandbox/PvP, you must create a new character.</font>"
		return 0
	
	// Save current position before leaving
	SaveContinentPosition(player, player.current_continent, player.x, player.y, player.z)
	
	// Get destination spawn
	var/list/spawn_pos = GetContinentPosition(player, destination_continent)
	if(!spawn_pos || spawn_pos.len < 3)
		spawn_pos = list(dest.port_x, dest.port_y, dest.port_z)
	
	// Move player
	var/turf/destination = locate(spawn_pos[1], spawn_pos[2], spawn_pos[3])
	if(!destination)
		if(player) player << "MULTI ERROR: Could not locate spawn point"
		return 0
	
	player.loc = destination
	player.current_continent = destination_continent
	
	// Display continent-specific message
	switch(destination_continent)
		if(CONT_STORY)
			if(player) player << "MULTI Arrived in Story World (Kingdom of Freedom) - Procedural narrative, NPCs, quests"
		if(CONT_SANDBOX)
			if(player) player << "MULTI Arrived in Sandbox World (Creative Canvas) - Building, peaceful exploration"
		if(CONT_PVP)
			if(player) player << "MULTI Arrived in PvP World (Battlelands) - Territory warfare, raiding, faction conflict"
		if(CONT_ASCENSION)
			if(player) player << "MULTI Arrived in Ascension Realm (Creative Mastery) - All recipes, peaceful exploration"
	
	return 1

// ============================================================================
// CHARACTER PROGRESSION VALIDATION
// ============================================================================

/proc/ValidatePlayerMultiWorldState(mob/players/player)
	// Ensure all multi-world variables are properly initialized
	if(!player) return 0
	
	// Initialize continent positions
	if(!player.continent_positions)
		player.continent_positions = list()
	
	// Fill in missing continents
	if(!(CONT_STORY in player.continent_positions))
		player.continent_positions[CONT_STORY] = GetContinentSpawnPoint(CONT_STORY)
	if(!(CONT_SANDBOX in player.continent_positions))
		player.continent_positions[CONT_SANDBOX] = GetContinentSpawnPoint(CONT_SANDBOX)
	if(!(CONT_PVP in player.continent_positions))
		player.continent_positions[CONT_PVP] = GetContinentSpawnPoint(CONT_PVP)
	
	// Ensure current continent is set
	if(!player.current_continent)
		player.current_continent = CONT_STORY
	
	return 1

// ============================================================================
// SKILL PERSISTENCE HELPERS
// ============================================================================
// Skills and recipes persist globally across all continents

/proc/AreSkillsGloballyShared()
	// Phase F principle: Skills learned anywhere apply everywhere
	return 1

/proc/AreRecipesGloballyShared()
	// Phase F principle: Recipes discovered anywhere unlocked everywhere
	return 1

/proc/IsKnowledgeGloballyShared()
	// Phase F principle: Knowledge learned persists globally
	return 1

// ============================================================================
// CROSS-WORLD STALL SYSTEM
// ============================================================================
// Player stalls exist per-continent but profits are shared

/proc/GetGlobalProfits(mob/players/player)
	// Stall profits are shared globally across all continents
	if(!player || !player.character) return 0
	
	// Access stall_profits from character_data
	return player.character.stall_profits || 0

/proc/AddGlobalProfits(mob/players/player, amount)
	// Add profits to global account (earned on any continent)
	if(!player || !player.character || amount <= 0) return 0
	
	// Add to stall_profits (shared across all continents)
	player.character.stall_profits += amount
	return 1

// ============================================================================
// CONTINENT-SPECIFIC RULES APPLICATION
// ============================================================================

/proc/ApplyActiveContinentRules(mob/players/player)
	// Apply continent-specific gameplay rules
	if(!player) return 0
	
	var/datum/continent/cont = GetContinent(player.current_continent)
	if(!cont) return 0
	
	// Rules are enforced in combat/building systems based on continent flags
	// See: IsAllowedToPvP(), IsAllowedToSteal(), IsAllowedToBuild()
	
	return 1

// ============================================================================
// TESTING & DEBUGGING
// ============================================================================

/proc/TestMultiWorldIntegration()
	world << "MULTI Test: Multi-World Integration"
	
	if(!continents || continents.len < 3)
		world << "MULTI TEST FAILED: Not all continents initialized"
		return 0
	
	world << "MULTI  Continents loaded: [continents.len]"
	for(var/cont_id in continents)
		var/datum/continent/c = continents[cont_id]
		world << "MULTI    - [c.id]: [c.name] (Port: [c.port_x], [c.port_y], [c.port_z])"
	
	world << "MULTI  Skills persist globally: [AreSkillsGloballyShared()]"
	world << "MULTI  Recipes persist globally: [AreRecipesGloballyShared()]"
	world << "MULTI  Knowledge persists globally: [IsKnowledgeGloballyShared()]"
	
	world << "MULTI Test Complete"
	return 1

/proc/DebugPlayerMultiWorldState(mob/players/player)
	if(!player) return 0
	
	world << "MULTI Debug: [player.name]'s Multi-World State"
	world << "MULTI  Current Continent: [player.current_continent]"
	world << "MULTI  Position: ([player.x], [player.y], [player.z])"
	
	if(player.continent_positions)
		world << "MULTI  Saved Positions:"
		for(var/cont in player.continent_positions)
			var/list/pos = player.continent_positions[cont]
			if(pos && islist(pos) && pos.len >= 3)
				world << "MULTI    [cont]: ([pos[1]], [pos[2]], [pos[3]])"
	
	return 1

/**
 * Get player's current continent ID (CONTINENT_PEACEFUL/CREATIVE/COMBAT)
 * Used by systems that need continent-specific behavior (e.g., soil degradation)
 */
proc/GetPlayerContinent(mob/player)
	if(!player) return CONTINENT_PEACEFUL
	
	// Check if player has current_continent set
	if(player:current_continent)
		switch(lowertext(player:current_continent))
			if("story", "peaceful")
				return CONTINENT_PEACEFUL
			if("sandbox", "creative")
				return CONTINENT_CREATIVE
			if("pvp", "combat")
				return CONTINENT_COMBAT
	
	// Default to peaceful if unknown
	return CONTINENT_PEACEFUL
