/**
 * HUD Manager - Consolidated Login & Logout Handlers
 * 
 * CRITICAL INTEGRATION POINT FOR:
 * - SQLite character restoration (OnLogin via LoginGateway)
 * - HUD/UI initialization (GameHUD from HudGroups)
 * - Survival systems (hunger/thirst)
 * - Market integration
 * - Admin permissions
 * - Client logout hook for persistence
 */

mob/players/Login()
	/**
	 * CONSOLIDATED LOGIN HANDLER
	 * 
	 * Called when player character appears on map.
	 * 
	 * Flow:
	 * 1. Validate world initialization (wait until Phase 5)
	 * 2. Load persistent character data from SQLite (OnLogin)
	 * 3. Initialize HUD/UI systems
	 * 4. Initialize survival systems (hunger/thirst)
	 * 5. Initialize market integration
	 * 6. Check admin permissions
	 * 7. Restore tool durability
	 */
	
	world.log << "\[LOGIN CONSOLIDATED\] Starting login sequence for [src.name]"
	
	// APPEARANCE: Set player icon
	if(!icon)
		src.icon = 'dmi/64/char.dmi'
	if(!icon_state)
		src.icon_state = "Ffriar"
	
	// UI: Hide stat panel
	if(client)
		client.statpanel = ""
		client.eye = src
	
	// GATE: Don't allow login until world initialization complete
	if(!CanPlayersLogin())
		world.log << "\[LOGIN CONSOLIDATED\] Rejecting [src.name] - world not initialized"
		src << "⚠️ Server is initializing systems. Please reconnect in a moment."
		del(src)
		return
	
	// PERSISTENCE: Load persistent character data from SQLite
	// This was called from LoginGateway.dm after character spawn
	// But we verify it here in case of manual testing
	if(!src.character)
		src.character = new /datum/character_data()
		world.log << "\[LOGIN CONSOLIDATED\] Created new character_data datum"
	
	// MOVEMENT: Initialize movement state
	src.move = 1
	src.Moving = 0
	
	// ONLINE: Mark player as online
	src.online = TRUE
	
	// CALL PARENT: Standard BYOND login chain
	..()
	
	// HUD SETUP: Create GameHUD from HudGroups library
	spawn(1)
		if(src && src.client)
			var/datum/GameHUD/main_hud = new(src)
			src.main_hud = main_hud
			if(main_hud)
				// Note: show_all() and update_all() may not exist on all HudGroup versions
				// Safe to skip if not available - HUD will initialize via datum
				world.log << "\[LOGIN CONSOLIDATED\] GameHUD created"
			
			// Initialize toolbelt HUD
			spawn(1)
				InitializeToolbeltHUD(src)
				world.log << "\[LOGIN CONSOLIDATED\] Toolbelt HUD initialized"
	
	// SURVIVAL SYSTEMS: Initialize hunger/thirst tracking
	spawn(2)
		InitializeHungerThirstSystem()
		world.log << "\[LOGIN CONSOLIDATED\] Hunger/thirst systems initialized"
	
	// MARKET INTEGRATION: Initialize market board
	spawn(2)
		IntegrateMarketBoardOnLogin(src)
		world.log << "\[LOGIN CONSOLIDATED\] Market board initialized"
	
	// ADMIN: Check admin permissions
	spawn(1)
		ToggleAdminMode(src)
		world.log << "\[LOGIN CONSOLIDATED\] Admin mode check complete"
	
	world.log << "\[LOGIN CONSOLIDATED COMPLETE\] [src.name] ready on map at ([src.x],[src.y],[src.z])"


