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
	
	// Set appearance
	if(!icon)
		src.icon = 'dmi/64/char.dmi'
	if(!icon_state)
		src.icon_state = "Ffriar"
	
	// Hide stat panel
	if(client)
		client.statpanel = ""
		client.eye = src
	
	// Validate world initialization
	if(!CanPlayersLogin())
		world.log << "\[LOGIN\] Player [src.name] rejected - initialization incomplete"
		src << "⚠️ Server is initializing systems. Please reconnect in a moment."
		del(src)
		return
	
	// Mark player as online
	MarkPlayerOnline(src)
	world.log << "\[LOGIN\] Player marked as online"
	
	// Initialize HUD systems
	init_hud()
	world.log << "\[LOGIN\] HUD initialized"
	
	// Call parent Login() - standard login hooks
	..()
	world.log << "\[LOGIN\] Parent Login() called"
	
	// Initialize survival systems
	InitializeHungerThirstSystem()
	IntegrateMarketBoardOnLogin(src)
	world.log << "\[LOGIN\] Systems initialized - player ready on map"


