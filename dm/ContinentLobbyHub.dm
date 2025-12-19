/**
 * CONTINENT LOBBY HUB SYSTEM
 * Central hub area where players spawn on first login
 * Players create character here and select continent via portals
 * 
 * Architecture: Actual map location with on-screen GUI overlays
 * - No dialog menus, no pop-ups
 * - Fullscreen map only, with gameified UI on top
 */

// ============================================================================
// LOBBY AREA TURFS
// ============================================================================

/turf/lobby_base
	name = "Lobby Floor"
	density = 0
	opacity = 0

/turf/lobby_wall
	name = "Wall"
	density = 1
	opacity = 1

// ============================================================================
// LOBBY INITIALIZATION - Create the actual map area
// ============================================================================

/proc/InitializeLobbyHub()
	// Lobby area: Use test.dmm map (100x100 temperate turfs at z=1)
	// Place portals on the map for continent selection
	// IMPORTANT: test.dmm is already included and loaded before this runs
	
	var/turf/T1 = locate(15, 20, 1)
	if(T1)
		var/obj/portal/story_gate/p1 = new(T1)
		world.log << "\[LOBBY\] Story portal placed at (15,20,1)"
		// Store portal reference for gating logic
		world.vars["lobby_story_portal"] = p1
	else
		world.log << "\[WARNING\] Could not place story portal - turf not found"
	
	var/turf/T2 = locate(50, 20, 1)
	if(T2)
		var/obj/portal/sandbox_gate/p2 = new(T2)
		world.log << "\[LOBBY\] Sandbox portal placed at (50,20,1)"
		// Store portal reference for gating logic
		world.vars["lobby_sandbox_portal"] = p2
	else
		world.log << "\[WARNING\] Could not place sandbox portal - turf not found"
	
	var/turf/T3 = locate(85, 20, 1)
	if(T3)
		var/obj/portal/pvp_gate/p3 = new(T3)
		world.log << "\[LOBBY\] PvP portal placed at (85,20,1)"
		// Store portal reference for gating logic
		world.vars["lobby_pvp_portal"] = p3
	else
		world.log << "\[WARNING\] Could not place pvp portal - turf not found"
	
	return 1

/proc/SpawnPlayerInLobby(mob/players/player)
	// Spawn new player in the lobby hub
	if(!player || !player.client) return
	
	// CRITICAL: Place player on actual turf with map (required for on-screen HUDs to work)
	// test.dmm has 100x100 temperate turfs at z=1, starting from (1,1)
	// Place player at safe location (20, 20, 1) away from edges
	
	var/turf/spawn_turf = locate(20, 20, 1)
	
	if(!spawn_turf)
		// If turf doesn't exist, try fallback locations
		world.log << "\[ERROR\] Lobby spawn turf not found at (20,20,1)"
		spawn_turf = locate(50, 50, 1)  // Try center of map
		
		if(!spawn_turf)
			world.log << "\[CRITICAL ERROR\] Cannot spawn player - no valid turfs on map"
			player << "ERROR: Map not loaded. Please reconnect."
			return
	
	// Place player on the turf
	player.loc = spawn_turf
	player.dir = SOUTH
	
	world.log << "\[LOBBY\] Player [player.name] spawned at ([spawn_turf.x],[spawn_turf.y],[spawn_turf.z])"
	
	player << "<font color=gold><b>Welcome to Pondera!</b></font>"
	player << "Create your character using the form on screen."
	player << "Then select a continent by clicking on one of the portals."
	
	// Show character creation GUI overlay (on-screen, not dialog)
	spawn(2)
		if(player && player.client)
			ShowCharacterCreationGUI(player)
