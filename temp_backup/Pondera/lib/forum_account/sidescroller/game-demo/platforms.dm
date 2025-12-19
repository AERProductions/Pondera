
mob
	platform
		icon_state = "moving-platform"

		pwidth = 32
		pheight = 16

		dir = RIGHT

		var
			start_px
			end_px

		New()
			..()

			set_pos(px, py + 16)

			// start_px and end_px determine the platform's range of movement
			start_px = px
			end_px = px + 80

		pixel_move(dpx, dpy)

			var/list/riders = top(1)

			..()

			for(var/mob/m in riders)
				m.pixel_move(move_x, move_y)

		movement()
			// move right
			if(dir == RIGHT)
				pixel_move(2,0)

				// When we reach end_px, start moving the other way
				if(px >= end_px)
					dir = LEFT

			else
				pixel_move(-2,0)
				if(px <= start_px)
					dir = RIGHT

		bump(mob/m, d)
			// if the platform bumped into a mob, try to move that mob out of the way
			if(istype(m))
				if(d == RIGHT)
					// if this causes the mob to move
					if(m.pixel_move(2,0))
						// try making the platform move again
						pixel_move(2,0)
				else
					if(m.pixel_move(-2,0))
						pixel_move(-2,0)