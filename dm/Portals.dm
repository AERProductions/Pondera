// Pondera Portal & Travel System
// Enables player movement between continents while managing position/inventory

// ============================================================================
// PORTAL OBJECTS - Gateway between continents
// ============================================================================

/obj/portal
	name = "Portal"
	desc = "A shimmering gateway to another realm. Click to enter."
	icon = 'cli.dmi'
	icon_state = "default"
	density = 0
	opacity = 0
	luminosity = 2
	
	var
		destination_continent = CONT_STORY
		is_active = 1
		portal_name = ""  // Display name (optional)
	
	New(x, y, z, destination)
		..()
		src.x = x
		src.y = y
		src.z = z
		destination_continent = destination
		
		var/datum/continent/cont = GetContinent(destination)
		if(cont)
			name = "Portal to [cont.name]"
			portal_name = "Portal to [cont.name]"
		else
			name = "Broken Portal"
			is_active = 0
	
	Entered(atom/movable/A)
		// Auto-travel when entering portal
		if(!istype(A, /mob/players)) return
		if(!is_active) return
		
		TravelToContinent(A, destination_continent)
	
	Click(mob/players/M)
		// Also allow manual click to travel
		if(!is_active)
			M << "This portal is broken."
			return
		
		TravelToContinent(M, destination_continent)

// Specialized portal variants for easy placement
/obj/portal/story_gate
	name = "Portal to Kingdom of Freedom"
	destination_continent = CONT_STORY

/obj/portal/sandbox_gate
	name = "Portal to Creative Sandbox"
	destination_continent = CONT_SANDBOX

/obj/portal/pvp_gate
	name = "Portal to Battlelands"
	destination_continent = CONT_PVP

// ============================================================================
// TRAVEL SYSTEM - Core inter-continental movement
// ============================================================================

/proc/TravelToContinent(mob/players/player, destination_continent)
	// Main travel proc: saves position, moves player, triggers continent effects
	
	if(!player)
		return 0
	
	if(!destination_continent in continents)
		player << "ERROR: Destination continent not found."
		return 0
	
	var/datum/continent/src_cont = GetContinent(player.current_continent)
	var/datum/continent/dest_cont = GetContinent(destination_continent)
	
	if(!dest_cont)
		player << "ERROR: Destination continent not accessible."
		return 0
	
	// Can't travel to same continent (error or no-op)
	if(player.current_continent == destination_continent)
		player << "You are already in [dest_cont.name]."
		return 0
	
	// Save current position before leaving
	if(player.current_continent)
		if(!player.continent_positions)
			player.continent_positions = list()
		
		var/list/pos = list()
		pos["x"] = player.x
		pos["y"] = player.y
		pos["z"] = player.z
		pos["dir"] = player.dir
		player.continent_positions[player.current_continent] = pos
	
	// Announce departure
	if(src_cont)
		player << "You step through the portal, leaving [src_cont.name]..."
	
	// Update player's continent
	player.current_continent = destination_continent
	
	// Get destination position (restored or default port)
	var/list/dest_pos = null
	if(player.continent_positions)
		dest_pos = player.continent_positions[destination_continent]
	
	if(!dest_pos)
		// First visit to this continent, spawn at port
		dest_pos = list()
		dest_pos["x"] = dest_cont.port_x
		dest_pos["y"] = dest_cont.port_y
		dest_pos["z"] = dest_cont.port_z
		dest_pos["dir"] = SOUTH
	
	// Move player (this actually changes player.loc)
	player.x = dest_pos["x"]
	player.y = dest_pos["y"]
	player.z = dest_pos["z"]
	if(dest_pos["dir"]) 
		player.dir = dest_pos["dir"]
	
	// Transition delay (brief delay before arrival message)
	sleep(10)
	
	// Announce arrival
	player << "You emerge in [dest_cont.name]..."
	
	// Trigger continent-specific effects
	OnContinentEntered(player, destination_continent)
	
	// Log travel for diagnostics
	// world << "[player.key] traveled to [destination_continent]"
	
	return 1

/proc/OnContinentEntered(mob/players/player, continent_id)
	// Called when player arrives in a new continent
	// Can be extended for:
	// - Environment effects (lighting, sounds, particles)
	// - UI updates (continent indicator, weather effects)
	// - Rule notifications (PvP warning in Battlelands, etc)
	
	var/datum/continent/cont = GetContinent(continent_id)
	if(!cont) return
	
	switch(continent_id)
		if(CONT_STORY)
			// Story world: normal colors, ambient soundtrack
			player.client.color = rgb(255, 255, 255)
			// Future: play story world theme music
			// Future: show story progression UI
			
		if(CONT_SANDBOX)
			// Sandbox world: bright, vibrant, creative mood
			player.client.color = rgb(255, 255, 255)
			// Future: play peaceful/creative soundtrack
			// Future: show building UI hints
			
		if(CONT_PVP)
			// PvP world: warning colors, survival mood
			player.client.color = rgb(200, 100, 100)
			player << "\n=== WARNING ==="
			player << "You are entering a dangerous zone. PvP is enabled."
			player << "Your structures and items can be raided."
			player << "=== WARNING ===\n"
			// Future: play intense/survival soundtrack
			// Future: show territory control UI

// ============================================================================
// CONTINENT SWITCHING COMMAND
// ============================================================================

/mob/players/verb/travel()
	set name = "Travel"
	set category = "Navigation"
	set desc = "Travel to another continent via portal"
	
	var/list/continent_names = ListContinents()
	if(!continent_names || continent_names.len == 0)
		src << "ERROR: No continents available."
		return
	
	// Remove current continent from list
	for(var/i = continent_names.len; i >= 1; i--)
		var/name = continent_names[i]
		// Find matching continent ID
		for(var/cont_id in continents)
			var/datum/continent/cont = continents[cont_id]
			if(cont.name == name && cont.id == src.current_continent)
				continent_names.Remove(i)
				break
	
	if(continent_names.len == 0)
		src << "No other continents available."
		return
	
	var/choice = input(src, "Select a continent:", "Travel") in continent_names
	if(!choice) return
	
	// Find continent ID matching choice
	for(var/cont_id in continents)
		var/datum/continent/cont = continents[cont_id]
		if(cont.name == choice)
			TravelToContinent(src, cont.id)
			return

// ============================================================================
// LOCATING CONTINENTS - Utility for saving/loading
// ============================================================================

// NOTE: GetContinentSpawnPoint moved to ContinentSpawnZones.dm (Phase 2 modern system)
// Legacy version below commented out
/*
/proc/GetContinentSpawnPoint(continent_id)
	// Returns a position list for continent spawn
	var/datum/continent/cont = GetContinent(continent_id)
	if(!cont)
		var/list/fallback = list()
		fallback["x"] = 64
		fallback["y"] = 64
		fallback["z"] = 1
		return fallback
	
	var/list/pos = list()
	pos["x"] = cont.port_x
	pos["y"] = cont.port_y
	pos["z"] = cont.port_z
	pos["dir"] = SOUTH
	return pos
*/

/proc/GetContinentPortLocation(continent_id)
	// Get the port town coordinates for a continent
	var/datum/continent/cont = GetContinent(continent_id)
	if(!cont)
		return null
	
	var/list/port = list()
	port["x"] = cont.port_x
	port["y"] = cont.port_y
	port["z"] = cont.port_z
	return port

// ============================================================================
// DEBUG - Travel system diagnostics
// ============================================================================

/proc/DebugTravelStatus(mob/players/player)
	if(!player) return ""
	
	var/output = "=== TRAVEL STATUS ===\n"
	output += "Current Continent: [player.current_continent]\n"
	output += "Saved Positions:\n"
	
	if(!player.continent_positions)
		output += "  (none saved)\n"
	else
		for(var/cont_id in player.continent_positions)
			var/list/pos = player.continent_positions[cont_id]
			output += "  [cont_id]: ([pos["x"]], [pos["y"]], [pos["z"]])\n"
	
	return output
