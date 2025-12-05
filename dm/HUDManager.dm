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
	..()
	init_hud()
	spawn(0)
		while(src && client)
			update_hud()
			sleep(4)


