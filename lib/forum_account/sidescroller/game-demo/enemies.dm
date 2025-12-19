
#define DEBUG

mob
	bullet
		pwidth = 4
		pheight = 4

		pixel_x = -14
		pixel_y = -14

		icon_state = "bullet"

		New(turf/t, sx, sy, vx, vy)
			loc = t

			set_pos(sx, sy)

			vel_x = vx
			vel_y = vy

		can_bump(atom/a)
			if(isturf(a))
				return a.density
			return 0

		bump(atom/a)
			del src

		movement()
			pixel_move(vel_x,vel_y)

			for(var/mob/m in inside())
				if(m.client)
					m.die()
				del src

			if(!loc)
				del src

turf
	shooter
		icon_state = "shooter"
		dir = WEST

		New()
			..()
			spawn(30) shoot_loop()

		proc
			shoot_loop()

				for(var/angle = 120 to 240 step 20)
					if(dir == WEST)
						new /mob/bullet(src, px + 24, py + 16, cos(angle) * 6, sin(angle) * 6)
					else
						new /mob/bullet(src, px + 8, py + 16, -cos(angle) * 6, sin(angle) * 6)

					sleep(2)

				spawn(20) shoot_loop()

		right
			dir = EAST