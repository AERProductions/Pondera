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
	// CRITICAL: Validate world initialization before allowing player login
	if(!CanPlayersLogin())
		world.log << "\[LOGIN\] Player [usr] rejected - initialization incomplete"
		usr << "⚠️ Server is initializing systems. Please reconnect in a moment."
		del(src)
		return
	
	// CRASH RECOVERY: Mark player as online for session tracking
	MarkPlayerOnline(src)
	
	..()
	init_hud()
	InitializeHungerThirstSystem()  // Initialize metabolic simulation
	
	// MODERN LOGIN: Show class selection for new characters (if not already selected)
	spawn(10)  // Wait for client to fully render HUD (50ms)
		if(src && client)
			if(!src.character)
				world.log << "\[LOGIN_CLASS\] [src.name]: No character data"
				return
			
			if(!src.character.selected_class)
				world.log << "\[LOGIN_CLASS\] [src.name]: Showing class selection dialog"
				src.login_ui = new /datum/login_ui(src)
				src.login_ui.ShowClassPrompt()
			else
				world.log << "\[LOGIN_CLASS\] [src.name]: Already has class: [src.character.selected_class]"
	
	spawn(0)
		while(src && client)
			update_hud()
			sleep(4)


