
// File:    demo\demo.dm
// Library: Forum_account.MousePosition
// Author:  Forum_account
//
// Contents:
//   This file is a demo that shows how to use the client's
//   MouseUpdate proc to make crosshairs that follow the player's
//   mouse cursor.

world
	// Using a higher framerate improves responsiveness.
	fps = 20

mob
	icon_state = "mob"

	var
		// We use a screen object to show the crosshair.
		obj/crosshair = new()

	Login()
		..()

		// Make the crosshairs be a screen object.
		client.screen += crosshair

		// Call the verb to start tracking.
		start_tracking()

	verb
		start_tracking()
			// Tell the library to track the mouse movements for this player.
			track_mouse()

		stop_tracking()
			// Tell the library to stop tracking the mouse movements for this player.
			track_mouse(0)

client
	// The MouseUpdate() proc is called every tick while the player's
	// mouse movements are being tracked. The parameters are the
	// components of a screen_loc string (tx:px,ty:py) that represents
	// the current mouse position.
	MouseUpdate(tx, px, ty, py)

		// we shift the crosshairs by -16 pixels so that its center is
		// at the mouse location.
		mob.crosshair.screen_loc = "[tx]:[px - 16],[ty]:[py - 16]"

obj
	layer = MOB_LAYER + 1
	icon_state = "crosshair"


// other definitions necessary for the demo but not related to mouse tracking:

atom
	icon = 'mouse-position-demo-icons.dmi'

client
	view = 6

turf
	icon_state = "floor"

	wall
		density = 1
		icon_state = "wall-15"

		New()
			..()
			var/n = 0
			var/turf/t = locate(x,y+1,z)
			if(t && istype(t,type)) n += 1
			t = locate(x+1,y,z)
			if(t && istype(t,type)) n += 2
			t = locate(x,y-1,z)
			if(t && istype(t,type)) n += 4
			t = locate(x-1,y,z)
			if(t && istype(t,type)) n += 8
			icon_state = "wall-[n]"

mob
	var
		delay = 0

	Move()
		if(delay) return

		. = ..()

		delay = 1
		spawn(world.tick_lag * 3)
			delay = 0
