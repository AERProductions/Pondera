/*
	COMPLETE LOGIN SYSTEM - All-in-one clean implementation
	
	Replaces fragmented pieces across multiple files:
	- LoginGateway.dm (client/New)
	- HUDManager.dm (mob/players/Login)
	- Basics.dm (mob/players/New)
	- CharacterCreationGUI.dm (if called from login)
	
	Single unified flow:
	1. Client connects → client/New()
	2. Create mob at valid spawn location
	3. Load/initialize character data
	4. Initialize all systems (HUD, hunger, market, etc)
	5. Player spawned and ready for gameplay
	6. NO character creation UI - NPCs handle customization later
*/

// ============================================================================
// STAGE 1: CLIENT CONNECTION
// ============================================================================

/client/New()
	world.log << "\[CLIENT_NEW\] ===== CLIENT CONNECTION START ====="
	world.log << "\[CLIENT_NEW\] Client key: [src.key]"
	world.log << "\[CLIENT_NEW\] World initialized: [world_initialization_complete]"
	
	// Show loading screen immediately when client connects
	ShowLoadingScreenForClient(src)
	
	..()
	
	world.log << "\[CLIENT_NEW\] Parent New() called"
	
	// Only create mob if client doesn't already have one
	if(!mob)
		world.log << "\[CLIENT_NEW\] No mob assigned, calling SpawnPlayerOnConnect()"
		SpawnPlayerOnConnect(src)
		world.log << "\[CLIENT_NEW\] SpawnPlayerOnConnect() returned"
	else
		world.log << "\[CLIENT_NEW\] Client already has mob: [mob]"
	
	world.log << "\[CLIENT_NEW\] ===== CLIENT CONNECTION COMPLETE ====="

/proc/SpawnPlayerOnConnect(client/C)
	if(!C)
		world.log << "\[SPAWN\] ERROR: SpawnPlayerOnConnect called with null client!"
		return
	
	world.log << "\[SPAWN\] ===== SPAWN PLAYER START ====="
	world.log << "\[SPAWN\] Client: [C.key]"
	world.log << "\[SPAWN\] World initialization complete: [world_initialization_complete]"
	
	// Check if world is ready for players
	if(!CanPlayersLogin())
		world.log << "\[SPAWN\] ERROR: CanPlayersLogin() returned FALSE"
		C << "⚠️ Server is initializing. Please reconnect shortly."
		return
	
	world.log << "\[SPAWN\] ✓ World is ready for players"
	
	// CREATE PLAYER MOB AT SPAWN POINT
	world.log << "\[SPAWN\] Creating new mob/players instance..."
	var/mob/players/player = new /mob/players()
	world.log << "\[SPAWN\] ✓ Mob created: [player] (type: [player.type])"
	
	// Find valid spawn location
	var/turf/spawn_turf = locate(50, 50, 1)
	world.log << "\[SPAWN\] Primary spawn turf (50,50,1): [spawn_turf] (type: [spawn_turf?.type])"
	
	if(!spawn_turf)
		spawn_turf = locate(world.maxx / 2, world.maxy / 2, 1)
		world.log << "\[SPAWN\] Fallback spawn turf ([world.maxx/2],[world.maxy/2],1): [spawn_turf]"
	
	if(!spawn_turf)
		world.log << "\[SPAWN\] CRITICAL ERROR: No valid spawn location found!"
		world.log << "\[SPAWN\] World dimensions: [world.maxx]x[world.maxy]x[world.maxz]"
		C << "⚠️ Server error: no spawn location. Report to admin."
		del(player)
		return
	
	world.log << "\[SPAWN\] ✓ Spawn turf valid: [spawn_turf] at ([spawn_turf.x],[spawn_turf.y],[spawn_turf.z])"
	
	// PLACE PLAYER ON MAP
	world.log << "\[SPAWN\] Placing player on map..."
	player.loc = spawn_turf
	world.log << "\[SPAWN\] ✓ Player loc set: [player.loc] at ([player.x],[player.y],[player.z])"
	
	world.log << "\[SPAWN\] Assigning key to player..."
	player.key = C.key
	world.log << "\[SPAWN\] ✓ Key assigned: [player.key]"
	
	world.log << "\[SPAWN\] Assigning client to player..."
	C.mob = player
	world.log << "\[SPAWN\] ✓ Client.mob assigned: [C.mob]"
	
	world.log << "\[SPAWN\] ===== SPAWN PLAYER COMPLETE ====="
	world.log << "\[SPAWN\] Player [player.key] created at ([spawn_turf.x],[spawn_turf.y],[spawn_turf.z])"

// ============================================================================
// STAGE 2: MOB INITIALIZATION - HAPPENS WHEN MOB IS CREATED
// ============================================================================

/mob/players/New()
	world.log << "\[MOB_NEW\] ===== MOB NEW() START ====="
	world.log << "\[MOB_NEW\] src: [src] (type: [src.type])"
	
	..()
	world.log << "\[MOB_NEW\] Parent New() called"
	
	// LEGACY: Update vital stats (from Basics.dm)
	world.log << "\[MOB_NEW\] Calling updateHP()..."
	src.updateHP()
	world.log << "\[MOB_NEW\] ✓ updateHP() complete"
	
	world.log << "\[MOB_NEW\] Calling updateST()..."
	src.updateST()
	world.log << "\[MOB_NEW\] ✓ updateST() complete"
	
	// LEGACY: Poison check and spawn (from Basics.dm)
	world.log << "\[MOB_NEW\] Starting poison check spawn..."
	spawn
		var/mob/players/M = src
		if(M && M.poisoned == 1)
			world.log << "\[MOB_NEW\] Player poisoned, calling poisoned()"
			poisoned(M)
	
	world.log << "\[MOB_NEW\] Poison check queued"
	
	// LEGACY: Hunger/thirst loop (from Basics.dm)
	world.log << "\[MOB_NEW\] Starting hunger/thirst spawn..."
	spawn while(src != null)
		world.log << "\[MOB_NEW\] Hunger/thirst loop starting"
		var/birthdate_fed = world.timeofday
		var/birthdate_hydrated = world.timeofday
		src.fed = 0
		src.hydrated = 0
		sleep(6000)
		
		if(!src)
			world.log << "\[MOB_NEW\] Hunger/thirst loop: mob deleted, exiting"
			return
		
		var/minute = world.timeofday
		
		// Check fed/hydrated loop
		while(src != null)
			if(src.fed == 1)
				birthdate_fed = world.timeofday
				src.hungry = 0
			else if(src.fed == 0 && minute > birthdate_fed)
				src.hungry = 1
				src << "Your stomach growls, find some thing to eat."
			
			if(src.hydrated == 1)
				birthdate_hydrated = world.timeofday
				src.thirsty = 0
			else if(src.hydrated == 0 && minute > birthdate_hydrated)
				src.thirsty = 1
				src << "You are parched, find something to drink."
			
			if(src.hungry == 1)
				src.HP = max(0, src.HP - 1)
			if(src.thirsty == 1)
				src.stamina = max(0, src.stamina - 1)
			
			if(src.HP <= 0)
				src.HP = 0
				world.log << "\[MOB_NEW\] Player dead, calling checkdeadplayer2()"
				src.checkdeadplayer2()
				return
			
			sleep(100)
			minute = world.timeofday
	
	// NEW: Modern initialization systems
	world.log << "\[MOB_NEW\] Starting modern initialization systems"
	
	// Initialize character data datum
	if(!character)
		world.log << "\[MOB_NEW\] Creating character data..."
		character = new /datum/character_data()
		character.Initialize()
		world.log << "\[MOB_NEW\] ✓ Character data initialized"
	
	// Initialize toolbelt (equipment hotbar)
	if(!toolbelt)
		world.log << "\[MOB_NEW\] Creating toolbelt..."
		toolbelt = new /datum/toolbelt(src)
		world.log << "\[MOB_NEW\] ✓ Toolbelt initialized"
	
	// Initialize inventory state
	if(!inventory_state)
		world.log << "\[MOB_NEW\] Creating inventory state..."
		inventory_state = new /datum/inventory_state()
		world.log << "\[MOB_NEW\] ✓ Inventory state initialized"
	
	// Initialize equipment state
	if(!equipment_state)
		world.log << "\[MOB_NEW\] Creating equipment state..."
		equipment_state = new /datum/equipment_state()
		world.log << "\[MOB_NEW\] ✓ Equipment state initialized"
	
	// Initialize character generation data for customization
	if(!chargen_data)
		world.log << "\[MOB_NEW\] Creating chargen data..."
		chargen_data = list()
		world.log << "\[MOB_NEW\] ✓ Chargen data initialized"
	
	// Initialize cheat detection per-player offsets
	world.log << "\[MOB_NEW\] Initializing player security..."
	InitializePlayerSecurity(src)
	world.log << "\[MOB_NEW\] ✓ Player security initialized"
	
	world.log << "\[MOB_NEW\] ===== MOB NEW() COMPLETE ====="

// ============================================================================
// STAGE 3: LOGIN - CALLED AUTOMATICALLY WHEN KEY ASSIGNED
// ============================================================================

/mob/players/Login()
	world.log << "\[LOGIN\] ===== LOGIN() START ====="
	world.log << "\[LOGIN\] Mob: [src] (key: [key])"
	world.log << "\[LOGIN\] Location: ([x],[y],[z])"
	world.log << "\[LOGIN\] Client: [client]"
	
	// Step 1: Set appearance
	world.log << "\[LOGIN\] Step 1: Setting appearance..."
	if(!icon)
		icon = 'dmi/64/char.dmi'
		world.log << "\[LOGIN\] ✓ Icon set to 'dmi/64/char.dmi'"
	if(!icon_state)
		icon_state = "Ffriar"
		world.log << "\[LOGIN\] ✓ Icon state set to 'Ffriar'"
	
	// Step 2: Hide BYOND stat panel (we use in-game HUD)
	world.log << "\[LOGIN\] Step 2: Hiding BYOND stat panel..."
	if(client)
		client.statpanel = ""
		world.log << "\[LOGIN\] ✓ Stat panel hidden"
	
	// Step 3: Call parent Login() for standard BYOND hooks
	world.log << "\[LOGIN\] Step 3: Calling parent Login()..."
	..()
	world.log << "\[LOGIN\] ✓ Parent Login() complete"
	
	// Step 4: Mark as online for crash recovery
	world.log << "\[LOGIN\] Step 4: Marking player online..."
	MarkPlayerOnline(src)
	world.log << "\[LOGIN\] ✓ Player marked online"
	
	// Step 5: Initialize all game systems
	world.log << "\[LOGIN\] Step 5: Initializing game systems..."
	InitializeAllGameSystems(src)
	world.log << "\[LOGIN\] ✓ Game systems initialized"
	
	// Step 6: Initialize player HUD (stats, inventory, hotbar, currency)
	world.log << "\[LOGIN\] Step 6: Initializing HUD..."
	world.log << "\[LOGIN\] Attempting GameHUDSystem InitializePlayerHUD()..."
	spawn(50)  // Delay to ensure client is fully ready
		if(src && src.client && src.loc)
			world.log << "\[LOGIN\] Calling InitializePlayerHUD([src]) after 50-tick delay..."
			InitializePlayerHUD(src)
			world.log << "\[LOGIN\] ✓ HUD initialized"
		else
			world.log << "\[LOGIN\] ERROR: Cannot init HUD - mob/client/location invalid"
			world.log << "\[LOGIN\]   src=[src], client=[src?.client], loc=[src?.loc]"
	
	// Simple fallback HUD message
	world.log << "\[LOGIN\] Sending welcome message to client..."
	src << "<b><font color='#00BFFF'>Welcome to Pondera!</font></b>"
	src << "<font color='silver'>Arrow keys or WASD to move. Click to interact."
	world.log << "\[LOGIN\] ✓ Welcome message sent"
	
	// Step 7: Queue admin mode check (background, non-blocking)
	world.log << "\[LOGIN\] Step 7: Queueing admin mode check..."
	spawn(0)
		if(src && src.client)
			world.log << "\[LOGIN\] Admin mode check: calling ToggleAdminMode([src])..."
			ToggleAdminMode(src)
			world.log << "\[LOGIN\] ✓ Admin mode check complete"
	
	// DONE - Player is now ready to play
	world.log << "\[LOGIN\] ===== LOGIN() COMPLETE ====="
	world.log << "\[LOGIN\] Player [key] ready for gameplay at ([x],[y],[z])"

/proc/InitializeAllGameSystems(mob/players/player)
	if(!player || !player.client) return
	
	// Market Integration (setup trading UI)
	IntegrateMarketBoardOnLogin(player)
	
	// Main HUD Manager
	if(!player.main_hud && player.client)
		player.main_hud = new /datum/PonderaHUD(player)
	
	world.log << "\[INIT_SYSTEMS\] Completed for [player.key]"

// ============================================================================
// UTILITY PROCS
// ============================================================================

/proc/LoadCharacterFromDatabase(mob/players/player)
	/*
		TODO: Implement SQLite character load
		For now, always creates fresh character
		
		When implemented:
		- Query SQLite by player key
		- Restore character_data (skills, equipment, etc)
		- Return TRUE if loaded, FALSE if new player
	*/
	return FALSE

/proc/SaveCharacterToDatabase(mob/players/player)
	/*
		Delegates to SQLiteIntegration.dm OnLogout() which handles save
	*/
	if(player && player.key)
		OnLogout(player)

// ============================================================================
// LEGACY COMPATIBILITY - STUB CALLS
// ============================================================================

/mob/players/proc/init_hud()
	// Stub - HUD init now done in InitializePlayerHUD()
	return

/mob/players/proc/update_hud()
	// Stub - HUD updates handled by continuous loop in GameHUDSystem.dm
	return

// END OF LOGIN SYSTEM

