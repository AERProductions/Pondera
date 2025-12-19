
// File:    intermediate-demo\demo.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   This demo shows how to use some more advanced
//   features of the library to create gameplay
//   elements, including:
//
//    * making non-player mobs move
//    * camera control
//    * debugging tools (the start_trace proc)
//    * ice (that you slide across)
//    * pushable boxes
//    * doors
//    * stepped_on/stepped_off events
//
//   Look for the headings in this file to see the
//   code for each of these features.

world
	view = 6

atom
	icon = 'top-down-icons.dmi'

mob
	base_state = "mob"

	pwidth = 24
	pheight = 24

	Login()
		..()

		src << "Use the arrow keys to move. Press the space bar to open doors (the blue/purple walls)."
		src << "Click on a turf to make the yellow mob move to it."


//  ---- MAKING NON-PLAYER MOBS MOVE ----

mob
	var
		mob/helper

	Login()
		..()

		// when you login, create the helper mob and place
		// them on the map.
		helper = new()
		helper.loc = locate(3,2,1)
		helper.base_state = "yellow-mob"

atom
	// clicking on a turf makes your helper move to that turf
	Click()
		usr.helper.move_towards(src)


//  ---- CAMERA CONTROL ----

mob
	Login()
		..()

		// initialize the mob's camera
		camera.mode = camera.SLIDE
		camera.lag = 48

		src << "camera.mode = camera.SLIDE"
		src << "camera.lag = 48"

	verb
		Toggle_Camera_Mode()
			if(camera.mode == camera.FOLLOW)
				camera.mode = camera.SLIDE
				src << "camera.mode = camera.SLIDE"
			else
				camera.mode = camera.FOLLOW
				src << "camera.mode = camera.FOLLOW"

		Toggle_Camera_Lag()
			if(camera.lag)
				camera.lag = 0
				src << "camera.lag = 0"
			else
				camera.lag = 48
				src << "camera.lag = 48"


//  ---- DEBUGGING TOOLS ----

PixelMovement
	debug = 1

mob
	verb
		Start_Trace()
			if(!trace)
				start_trace()
				src << "movement trace started"

		Stop_Trace()
			if(trace)
				stop_trace()
				src << "movement trace stopped"


//  ---- ICE ----

// Take note of the mob's on_ground value in the debug statpanel
// when the player is standing on ice. The value of ICE (2), gets
// binary ORed with the mob's on_ground var when the mob is on
// top of ice.

var
	const
		ICE = 2

mob
	slow_down()
		// We use this if statement to check if the ICE bit is set in the
		// mob's on_ground var - if you're on ice, you don't slow down
		if(on_ground & ICE)
			return

		// calling ..() runs the default behavior which makes the mob slow
		// down. We only call this if the mob isn't standing on ice.
		..()

turf
	ice
		icon_state = "ice"
		flags_ground = ICE


//  ---- PUSHABLE BOXES ----

mob
	// bumping a box causes it to move in the direction you bumped it
	bump(mob/box/b, d)
		if(istype(b))
			b.move(d)
		else
			..()

	box
		pwidth = 24
		pheight = 24
		move_speed = 2

		icon_state = "box"

		set_state()


//  ---- DOORS ----

mob
	key_down(k)
		if(k == "space")
			// front(8) returns a list of all atoms within 8 pixels
			// of the front of your mob.
			for(var/obj/door/d in front(8))
				d.open()

obj
	door
		icon_state = "door-closed"
		density = 1

		var
			state = 0 // 0 = open, 1 = in transition, 2 = closed

		proc
			open()
				if(state != 0) return

				state = 1
				flick("door-opening", src)
				icon_state = "door-open"

				spawn(8 * world.tick_lag)
					density = 0
					state = 2

				// make the door automatically close after 2 seconds
				spawn(20)
					close()

			close()
				if(state != 2) return

				// if the doorway isn't clear, wait a second and try again
				if(locate(/mob) in inside())
					spawn(10) close()
					return

				state = 1
				density = 1
				flick("door-closing", src)
				icon_state = "door-closed"

				spawn(8 * world.tick_lag)
					state = 0


//  ---- STEPPED_ON / STEPPED_OFF EVENTS ----

turf
	square
		icon_state = "square"

		stepped_on(mob/m)
			m << "You are now standing on the square."

		stepped_off(mob/m)
			m << "You are no longer standing on the square."

		// t is the number of ticks m has spent standing on this turf
		stepping_on(mob/m, t)

			// we output the message every 20 ticks, otherwise we'd spam the player.
			if(t % 20 == 0)
				m << "You have been standing on the square for [t] ticks."


//  ---- MISCELLANEOUS ----

turf
	icon_state = "floor"

	wall
		density = 1
		icon_state = "wall"

		New()
			..()
			var/n = 0
			var/turf/t = locate(x, y + 1, z)
			if(t && istype(t, type)) n += 1
			t = locate(x + 1, y, z)
			if(t && istype(t, type)) n += 2
			t = locate(x, y - 1, z)
			if(t && istype(t, type)) n += 4
			t = locate(x - 1, y, z)
			if(t && istype(t, type)) n += 8
			icon_state = "wall-[n]"

