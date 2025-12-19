/**
 * HUD Manager - Initialize and manage player UI
 */

mob/players/proc/init_hud()
	if(!client) return
	
	// Note: Modern HUD handled by PonderaHUD system
	// This proc reserved for legacy compatibility

mob/players/proc/update_hud()
	if(!client) return
	
	// Update HUD through proper PonderaHUD systems
	if(main_hud)
		// main_hud.update_all()  // Stub - implement when HUD system fully initialized
		return

mob/players/Login()
	world.log << "\[LOGIN\] mob/players/Login() called for [src.name] at ([src.x],[src.y],[src.z])"
	
	// Set appearance FIRST
	if(!icon)
		src.icon = 'dmi/64/char.dmi'
	if(!icon_state)
		src.icon_state = "Ffriar"
	
	// HIDE BYOND INTERFACE COMPLETELY
	if(client)
		client.statpanel = ""  // Hide stat panel completely

	// CRITICAL: Validate world initialization before allowing player login
	if(!CanPlayersLogin())
		world.log << "\[LOGIN\] Player [src.name] rejected - initialization incomplete"
		src << "⚠️ Server is initializing systems. Please reconnect in a moment."
		del(src)
		return
	
	// CRASH RECOVERY: Mark player as online for session tracking
	MarkPlayerOnline(src)
	world.log << "\[LOGIN\] Player marked as online"
	
	// Call parent Login() - IMPORTANT for standard login hooks
	..()
	world.log << "\[LOGIN\] Parent Login() called"
	
	// CONSOLIDATED FROM BASICS.DM: Admin mode check and role permissions
	spawn(0) ToggleAdminMode(src)  // Check roles and show/hide admin verbs
	world.log << "\[LOGIN\] Admin mode check queued"
	
	// CONSOLIDATED FROM BASICS.DM: Initialize HUD system and character data
	if(!chargen_data)
		chargen_data = list()
		world.log << "\[LOGIN\] Character data initialized"
	
	if(!main_hud && client)
		main_hud = new /datum/PonderaHUD(src)
		world.log << "\[LOGIN\] PonderaHUD created"
	
	// Initialize hunger/thirst
	InitializeHungerThirstSystem()
	IntegrateMarketBoardOnLogin(src)
	world.log << "\[LOGIN\] Systems initialized"
	
	// Initialize IN-GAME HUD (stats, inventory, hotbar, currency)
	// NO character creation UI - player spawns directly into lobby ready to play
	InitializePlayerHUD(src)
	world.log << "\[LOGIN\] In-game HUD initialized - ready to play"


	// CONSOLIDATED: Logout() moved to Basics.dm as canonical implementation
	// Basics.dm Logout() now calls SavePlayerHUDState() before CleanupPlayerSession()


