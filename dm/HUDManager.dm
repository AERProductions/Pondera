/**
 * HUD Manager - Initialize and manage player UI
 */

mob/players/proc/init_hud()
	if(!client) return
	
	// Create health bar
	var/obj/screen/health_bar/hb = new(src)
	hb.screen_loc = "SOUTHWEST + (10,40)"
	client.add_ui(hb)
	
	// Create stamina bar
	var/obj/screen/stamina_bar/sb = new(src)
	sb.screen_loc = "SOUTHWEST + (10,60)"
	client.add_ui(sb)

mob/players/proc/update_hud()
	if(!client) return
	
	for(var/obj/screen/health_bar/hb in client.ui_list)
		hb.refresh()
	
	for(var/obj/screen/stamina_bar/sb in client.ui_list)
		sb.refresh()

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
		client.statpanel = 0   // Disable all stat panels
		client.eye = src       // Focus camera on player
		client.dir = 2         // Disable input for interface
	
	// CRITICAL: Validate world initialization before allowing player login
	if(!CanPlayersLogin())
		world.log << "\[LOGIN\] Player [src.name] rejected - initialization incomplete"
		src << "⚠️ Server is initializing systems. Please reconnect in a moment."
		del(src)
		return
	
	// CRASH RECOVERY: Mark player as online for session tracking
	MarkPlayerOnline(src)
	world.log << "\[LOGIN\] Player marked as online"
	
	// Initialize HUD systems
	init_hud()
	world.log << "\[LOGIN\] HUD initialized"
	
	// Call parent Login() - IMPORTANT for standard login hooks
	..()
	world.log << "\[LOGIN\] Parent Login() called"
	
	// Initialize hunger/thirst
	InitializeHungerThirstSystem()
	IntegrateMarketBoardOnLogin(src)
	world.log << "\[LOGIN\] Systems initialized"
	
	// Show character creation GUI immediately (player already on map at this point)
	world.log << "\[LOGIN\] Calling ShowCharacterCreationGUI(src)"
	ShowCharacterCreationGUI(src)
	world.log << "\[LOGIN\] GUI shown - returning from Login()"


