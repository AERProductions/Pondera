//	Kaiochao
//	11 Jan 2014
//	Mouse

//	This provides a datum attached to a client that can be used to get information about
// where the player's mouse is in the screen.

/*	Example of use

client
	MouseMoved()
		mob.transform = matrix(mouse.angle, MATRIX_ROTATE)

*/

mouse/var
	//	Is the mouse currently over the map?
	on_map = FALSE

	//	The pixel position of the mouse in the screen (1,1 is the bottom-left)
	pixel_x = 0
	pixel_y = 0

	//	The position of the mouse relative to the screen's center
	//	Think of it as a vector from the center to the mouse
	delta_x = 0
	delta_y = 0

	//	Angle from the center to the mouse (clock-wise from NORTH)
	angle = 0

client
	var tmp/mouse/mouse = new

	proc/MouseMoved()




//	Don't worry about the implementation below!

client
	//	This is so the mouse is detected in void areas
	//	(opacity shadow, off the edge of the map)
	New()
		..()
		screen += new /obj {
			mouse_opacity = 2
			screen_loc = "SOUTHWEST to NORTHEAST"
			layer = -1.#INF
			name = ""
		}

	MouseEntered(o, l, c, p)
		..()
		mouse.on_map = TRUE
		MouseUpdate(params2list(p)["screen-loc"])

	MouseExited()
		..()
		mouse.on_map = FALSE

	MouseMove(o, l, c, p)
		..()
		MouseUpdate(params2list(p)["screen-loc"])

	MouseDrag(so, oo, sl, ol, sc, oc, p)
		..()
		MouseUpdate(params2list(p)["screen-loc"])

	proc
		MouseUpdate(screen_loc)
			if(!screen_loc) return

			var colons[0]
			var colon_found
			var colon_start = 1
			for()
				colon_found = findtext(screen_loc, ":", colon_start)
				if(colon_found)
					colon_start = colon_found + 1
					colons += colon_found
				else break

			if(!colons.len) return

			var start = 1

			if(colons.len >= 3)
				start = colons[1] + 1
				colons.Cut(1, 2)

			var comma = findtext(screen_loc, ",")

			mouse.pixel_x = (text2num(copytext(screen_loc,     start, colons[1])) - 1) * tile_width()  + text2num(copytext(screen_loc, colons[1] + 1, comma))
			mouse.pixel_y = (text2num(copytext(screen_loc, comma + 1, colons[2])) - 1) * tile_height() + text2num(copytext(screen_loc, colons[2] + 1))

			mouse.delta_x = mouse.pixel_x - MouseCenterX()
			mouse.delta_y = mouse.pixel_y - MouseCenterY()

			//	atan2
			mouse.angle = (mouse.delta_x || mouse.delta_y) && (mouse.delta_x >= 0 ? arccos(mouse.delta_y / sqrt(mouse.delta_x * mouse.delta_x + mouse.delta_y * mouse.delta_y)) : 360 - arccos(mouse.delta_y / sqrt(mouse.delta_x * mouse.delta_x + mouse.delta_y * mouse.delta_y)))

			MouseMoved()

		//	These determine where the center of the screen is.
		//	By default, it halves the client's view size in pixels.
		MouseCenterX()
			return isnum(view) ? (view + 0.5) * tile_width()  : (1 + text2num(copytext(view, 1, findtext(view, "x")))) / 2 * tile_width()

		MouseCenterY()
			return isnum(view) ? (view + 0.5) * tile_height() : (text2num(copytext(view, findtext(view, "x") + 1))) / 2 * tile_height()