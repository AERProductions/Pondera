
// File:    mouse-position.dm
// Library: Forum_account.MousePosition
// Author:  Forum_account
//
// Contents:
//   This file defines the client/MouseUpdate proc and the objects
//   needed to make it function. It works by creating two screen
//   objects, each having a faint checkerboard pattern on its icon.
//   The objects cover the entire screen, but as you move the mouse
//   and pass over cells of the checkerboards, the MouseEntered and
//   MouseExited events are called for the objects. This lets us
//   find the position of the mouse cursor with more precision than
//   usual.

client
	proc
		// This is the proc you call to start or stop tracking.
		// The parameters are:
		//
		//   track: either 0 or 1. 1 makes it start tracking, 0 makes it stop
		//   resolution: either 1, 2, 4, 8, or 16. How precise the tracking is
		//   layer: the layer of the objects used to track movement, this should
		//          be higher than any layer you use for any objects in your game
		track_mouse(track = 1, resolution = 4, layer = 10000)

			// start tracking
			if(track)

				// if you're already tracking mouse movements we don't need to do anything
				if(mouse_tracker_a) return

				if(resolution == 16 || resolution == 8 || resolution == 4 || resolution == 2 || resolution == 1)
					mouse_tracker_a = new(src, "a", resolution, layer)
					mouse_tracker_b = new(src, "b", resolution, layer)
				else
					CRASH("Expected the value 1, 2, 4, 8, or 16 for resolution, got '[resolution]' instead.")

			// stop tracking
			else
				// if you're not tracking mouse movements there's nothing to be done
				if(!mouse_tracker_a) return

				screen -= mouse_tracker_a
				screen -= mouse_tracker_b

				del mouse_tracker_a
				del mouse_tracker_b

		// This is the proc that's called when the mouse position
		// is udpated. By default it does nothing, but you can
		// override it in your project to make it do whatever you
		// need it to do.
		MouseUpdate(tx, px, ty, py)

	var
		obj/mouse_tracker/mouse_tracker_a
		obj/mouse_tracker/mouse_tracker_b

mob
	proc
		// This is an alias of client.track_mouse so you can call it
		// for the mob or client. The parameters are the same for both.
		track_mouse(track = 1, resolution = 4, layer = 10000)
			if(client)
				client.track_mouse(track, resolution, layer)

obj/mouse_tracker
	icon = 'mouse-position.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	layer = 10000
	mouse_opacity = 1

	var
		client/client

	New(client/c, which, r, l)
		..()
		layer = l
		icon_state = "[r][which]"

		// use this line to use the debug icon states
		// icon_state = "debug-[r][which]"

		client = c
		client.screen += src

	// Initially I tried to use one screen object and capture both the
	// entered and exited events, but it didn't work as well. Because I
	// use two screen objects, we can get away with only capturing the
	// entered events.
	// MouseExited(location, control, params) update(params)

	MouseDrag(over_object,src_location,over_location,src_control,over_control,params)
		update(params)

	MouseEntered(location, control, params)
		update(params)

	proc
		update(params)

			if(!params) return

			params = params2list(params)

			if(!("screen-loc" in params)) return

			// parse out the values in the "screen-loc" parameter
			var/pos = params["screen-loc"]

			if(!pos) return

			var/comma = findtext(pos, ",")
			var/colon = findtext(pos, ":")

			if(comma < 1) return
			if(colon < 1) return

			var/tx = text2num(copytext(pos, 1, colon))
			var/px = text2num(copytext(pos, colon + 1, comma))

			colon = findtext(pos, ":", comma)

			if(colon < 1) return

			var/ty = text2num(copytext(pos, comma + 1, colon))
			var/py = text2num(copytext(pos, colon + 1))

			client.MouseUpdate(tx, px, ty, py)
