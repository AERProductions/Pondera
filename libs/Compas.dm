mob/var/Target
proc
	get_angle_nums(ax,ay,bx,by)
		var/val = sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
		if(!val) return 0
		var/ar = arccos((bx - ax) / val)
		var/deg = round(360 - (by - ay >= 0 ? ar : -ar), 1)
		while(deg > 360) deg -= 360
		while(deg < 0) deg += 360
		return deg

obj
	Navi
		Compas
			icon = 'Compas.dmi'
			icon_state = "Compas"
			layer = 10
			screen_loc = "1,14"
		
		Arrow
			icon = 'Compas.dmi'
			icon_state = "Arrow"
			layer = 11 //Set it above the compas
			screen_loc = "1,14"

// ============================================================================
// COMPASS DISPLAY FUNCTIONS
// ============================================================================

/proc/UpdateCompassArrow(mob/players/M)
	/**
	 * UpdateCompassArrow
	 * Rotate arrow to point toward player's home point
	 */
	if(!M || !M.character || !M.character.home_point) 
		return
	
	var/turf/home = M.character.home_point
	var/player_x = M.x
	var/player_y = M.y
	var/home_x = home.x
	var/home_y = home.y
	
	// Calculate angle to home point
	var/angle = get_angle_nums(player_x, player_y, home_x, home_y)
	
	// Update arrow icon state based on direction
	for(var/obj/Navi/Arrow/arrow in M.client.screen)
		if(angle >= 337.5 || angle < 22.5)
			arrow.icon_state = "arrow_n"
		else if(angle >= 22.5 && angle < 67.5)
			arrow.icon_state = "arrow_ne"
		else if(angle >= 67.5 && angle < 112.5)
			arrow.icon_state = "arrow_e"
		else if(angle >= 112.5 && angle < 157.5)
			arrow.icon_state = "arrow_se"
		else if(angle >= 157.5 && angle < 202.5)
			arrow.icon_state = "arrow_s"
		else if(angle >= 202.5 && angle < 247.5)
			arrow.icon_state = "arrow_sw"
		else if(angle >= 247.5 && angle < 292.5)
			arrow.icon_state = "arrow_w"
		else if(angle >= 292.5 && angle < 337.5)
			arrow.icon_state = "arrow_nw"

/proc/ShowCompass(mob/M)
	/**
	 * ShowCompass
	 * Display compass on player's screen
	 * Called when entering compass range or setting home point
	 */
	if(!M || !M.client || !istype(M, /mob/players)) return
	
	var/mob/players/player = M
	if(!player.character || !player.character.home_point)
		player << "You have not set a home point yet. Use a sundial to set your home point."
		return
	
	// Create compass objects if they don't exist
	var/obj/Navi/Compas/compass = new()
	var/obj/Navi/Arrow/arrow = new()
	
	// Add to client screen
	player.client.screen += compass
	player.client.screen += arrow
	
	// Update arrow direction
	UpdateCompassArrow(player)

/proc/HideCompass(mob/M)
	/**
	 * HideCompass
	 * Remove compass from player's screen
	 */
	if(!M || !M.client) return
	
	for(var/obj/Navi/C in M.client.screen)
		M.client.screen -= C
