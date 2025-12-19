
// File:    performance-demo\demo.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   This demo includes examples of basic performance
//   enhancements. See optimization.dm for more info.

world
	view = 6

PixelMovement
	debug = 1

atom
	icon = 'top-down-icons.dmi'

client
	New()
		mob = new /mob/player()
		..()

mob
	player
		pwidth = 24
		pheight = 24

		base_state = "mob"

		// To disable jumping we override these procs and
		// make them do nothing.
		// Note: if you enable the TWO_DIMENSIONAL flag these
		// procs will not be defined. You won't need to override
		// them, they just won't exist.
		// can_jump()
		// jump()

mob
	bullet
		pwidth = 4
		pheight = 4
		icon_state = "bullet"

		set_state()

		decel = 0

		New(mob/m, angle)
			..()

			loc = m.loc
			set_pos(m.px + 12, m.py + 12, m.z)

			vel_x = cos(angle) * 8
			vel_y = sin(angle) * 8

		bump(atom/a, d)
			if(d != VERTICAL)
				del src

	shooter
		density = 0
		icon_state = "shooter"

		var
			delay = 0

		New()
			..()
			delay = rand(10,60)

		set_state()

		action()
			..()

			delay -= 1

			if(delay <= 0)

				for(var/a = 0 to 359 step 20)
					spawn(a / 10)
						new /mob/bullet(src, a)

				delay = 140

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
