// Pondera World Selection & Character Multi-World Management
// Handles player UI for continent selection and world management

// ============================================================================
// WORLD SELECTION UI - Main menu for choosing continents
// ============================================================================

/proc/ShowWorldSelectionUI(mob/players/player)
	// Display world/continent selection menu
	// Called on first login or via /worlds command
	
	if(!player)
		return 0
	
	var/list/options = list()
	var/list/descriptions = list()
	
	// Build continent list
	for(var/cont_id in continents)
		var/datum/continent/cont = continents[cont_id]
		options += cont.name
		
		var/status_line = ""
		if(cont.allow_pvp)
			status_line = "⚠ PvP Enabled"
		else if(cont.type_flags & CONTINENT_PEACEFUL)
			status_line = "✓ Peaceful"
		else if(cont.type_flags & CONTINENT_CREATIVE)
			status_line = "✓ Creative"
		
		descriptions[cont.name] = "[cont.desc]\n\nStatus: [status_line]"
	
	if(options.len == 0)
		player << "ERROR: No continents available."
		return 0
	
	// Show world selection prompt
	var/choice = input(player, "Select a world to explore:", "World Selection", options[1]) in options
	
	if(!choice)
		return 0  // User canceled
	
	// Find continent ID matching choice and travel
	for(var/cont_id in continents)
		var/datum/continent/cont = continents[cont_id]
		if(cont.name == choice)
			TravelToContinent(player, cont.id)
			return 1
	
	return 0

// ============================================================================
// WORLD INFO COMMAND - Display continent details
// ============================================================================

/mob/players/verb/worldinfo()
	set name = "World Info"
	set category = "Navigation"
	set desc = "View information about continents"
	
	var/datum/continent/cont = GetContinent(src.current_continent)
	if(!cont)
		src << "ERROR: Current continent not found."
		return
	
	var/info = ""
	info += "<B>[cont.name]</B>\n"
	info += "[cont.desc]\n\n"
	info += "<B>Rules:</B>\n"
	info += "PvP Enabled: [cont.allow_pvp ? "YES" : "NO"]\n"
	info += "Building Allowed: [cont.allow_building ? "YES" : "NO"]\n"
	info += "NPCs Present: [cont.npc_spawn ? "YES" : "NO"]\n"
	info += "Creatures Present: [cont.monster_spawn ? "YES" : "NO"]\n"
	info += "Weather: [cont.weather ? "YES" : "NO"]\n"
	
	src << info

// ============================================================================
// CONTINENT STATUS HUD - Optional HUD element
// ============================================================================

/obj/screen_fx/continent_indicator
	// Optional HUD element showing current continent
	name = "continent_indicator"
	icon = null
	layer = 5  // Default HUD layer
	screen_loc = "1,30"  // Top-left corner
	
	var/current_continent = ""
	
	proc/UpdateContinent(continent_id)
		current_continent = continent_id
		var/datum/continent/cont = GetContinent(continent_id)
		if(cont)
			name = cont.name
			// Future: update icon based on continent

// ============================================================================
// CHARACTER DATA INTEGRATION - Multi-world variables
// ============================================================================

// NOTE: These variables should be added to /mob/players in CharacterData.dm:
//
// var
//     // Multi-world system
//     current_continent = CONT_STORY       // Which continent player is on
//     continent_positions = list()         // Saved positions: CONT_STORY = list(x,y,z,dir)
//     stall_owner = ""                     // NPC stall owner name (story)
//     stall_inventory = list()             // Stall items for sale
//     stall_prices = list()                // Item prices in stall
//     stall_profits = 0                    // Accumulated stall profits

// ============================================================================
// PERSISTENCE - Save/Load continent data
// ============================================================================

// NOTE: These additions should be made to _DRCH2.dm Write/Read procs:
//
// WRITE (saving character):
//     W["current_continent"] = character.current_continent
//     W["continent_positions"] = character.continent_positions
//     W["stall_owner"] = character.stall_owner
//     W["stall_inventory"] = character.stall_inventory
//     W["stall_prices"] = character.stall_prices
//     W["stall_profits"] = character.stall_profits
//
// READ (loading character):
//     if("current_continent" in data)
//         character.current_continent = data["current_continent"]
//     else
//         character.current_continent = CONT_STORY
//
//     if("continent_positions" in data)
//         character.continent_positions = data["continent_positions"]
//     else
//         character.continent_positions = list(
//             CONT_STORY: GetContinentSpawnPoint(CONT_STORY),
//             CONT_SANDBOX: GetContinentSpawnPoint(CONT_SANDBOX),
//             CONT_PVP: GetContinentSpawnPoint(CONT_PVP)
//         )
//
//     if("stall_owner" in data)
//         character.stall_owner = data["stall_owner"]
//     if("stall_inventory" in data)
//         character.stall_inventory = data["stall_inventory"]
//     if("stall_prices" in data)
//         character.stall_prices = data["stall_prices"]
//     if("stall_profits" in data)
//         character.stall_profits = data["stall_profits"]

// ============================================================================
// INITIALIZATION - Setup for character on login
// ============================================================================

/proc/InitializeCharacterContinents(mob/players/player)
	// Called when character loads for first time
	// Ensure all continent variables are initialized
	
	if(!player)
		return 0
	
	// Set continent if not already set
	if(!player.current_continent)
		player.current_continent = CONT_STORY
	
	// Initialize position map if needed
	if(!player.continent_positions)
		player.continent_positions = list()
		player.continent_positions[CONT_STORY] = GetContinentSpawnPoint(CONT_STORY)
		player.continent_positions[CONT_SANDBOX] = GetContinentSpawnPoint(CONT_SANDBOX)
		player.continent_positions[CONT_PVP] = GetContinentSpawnPoint(CONT_PVP)
	else
		// Fill in missing continents
		if(!(CONT_STORY in player.continent_positions))
			player.continent_positions[CONT_STORY] = GetContinentSpawnPoint(CONT_STORY)
		if(!(CONT_SANDBOX in player.continent_positions))
			player.continent_positions[CONT_SANDBOX] = GetContinentSpawnPoint(CONT_SANDBOX)
		if(!(CONT_PVP in player.continent_positions))
			player.continent_positions[CONT_PVP] = GetContinentSpawnPoint(CONT_PVP)
	
	// Initialize stall variables if needed
	if(!player.stall_owner)
		player.stall_owner = ""
	if(!player.stall_inventory)
		player.stall_inventory = list()
	if(!player.stall_prices)
		player.stall_prices = list()
	if(!player.stall_profits)
		player.stall_profits = 0
	
	return 1

// ============================================================================
// DEBUG - World system diagnostics
// ============================================================================

/mob/players/verb/debug_worlds()
	set name = "Debug Worlds"
	set category = "Debug"
	set desc = "Display world system diagnostics"
	
	src << DebugContinentStatus()
	src << DebugTravelStatus(src)

/mob/players/verb/teleport_to_continent(continent_id as text)
	set name = "Teleport to Continent"
	set category = "Debug"
	set desc = "Teleport to a continent (debug)"
	if(!(continent_id in continents))
		src << "Unknown continent: [continent_id]"
		return
	
	TravelToContinent(src, continent_id)
