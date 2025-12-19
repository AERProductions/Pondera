
world
	view = 6

	New()
		SIDESCROLLER_DEBUG = 1
		..()

atom
	icon = 'sidescroller-demo-icons.dmi'

mob
	base_state = "mob"

	var
		weapon = /mob/bullet

	Login()

		loc = locate(2,2,1)

		pwidth = 24
		pheight = 24

		src << "Use the arrow keys to move and the space bar to jump."
		src << "Press 1 and 2 to select weapons."

	can_bump(mob/m)
		if(istype(m))
			return 0
		return ..()

	// weapon toggle
	key_down(k)
		if(k == "1")
			weapon = /mob/bullet
			src << "Click on a tile to shoot."

		else if(k == "2")
			weapon = /mob/grenade
			src << "Click on a tile to throw a grenade."

		..()

mob
	bullet
		pwidth = 4
		pheight = 4

		pixel_x = -14
		pixel_y = -14

		gravity()

		set_state()
			icon_state = "bullet"

		New(mob/source, atom/target)

			loc = source.loc
			set_pos(source.px + source.pwidth / 2, source.py + source.pheight / 2)

			var/dx = (target.px + target.pwidth / 2) - px
			var/dy = (target.py + target.pheight / 2) - py
			var/len = sqrt(dx * dx + dy * dy)

			vel_x = (dx / len) * 12
			vel_y = (dy / len) * 12

		bump()
			del src


	grenade
		pwidth = 8
		pheight = 8

		set_state()
			if(vel_x == 0 && vel_y == 0)
				icon_state = "grenade-still"
			else
				icon_state = "grenade-moving"

		movement()

			..()

			if(on_ground)
				slow_down()

			if(vel_x == 0 && vel_y == 0)
				spawn(10)
					del src

		New(mob/source, atom/target)

			loc = source.loc
			set_pos(source.px + source.pwidth / 2, source.py + source.pheight / 2)

			var/dx = (target.px + target.pwidth / 2) - px
			var/dy = (target.py + target.pheight / 2) - py

			vel_x = dx * 0.1
			vel_y = dy * 0.1

		bump(atom/a, d)
			if(d == RIGHT || d == LEFT)
				vel_x = round(vel_x * -0.5)
			else
				vel_y = round(vel_y * -0.5)

turf
	Click()
		var/mob/m = new usr.weapon(usr, src)
		m.start_trace()

turf
	icon_state = "white"

	ladder
		icon_state = "ladder"
		ladder = 1

	wall
		density = 1
		icon_state = "wall"

		// autojoining
		New()
			..()
			if(type == /turf/wall)
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

		short_floor
			icon_state = "short-floor"
			density = 1
			pwidth = 16

		ramp_1
			density = 1
			pwidth = 32
			pheight = 16

			// The pleft and pright variables are used to create ramps
			pleft = 0
			pright = 16
			icon_state = "ramp-1"

		ramp_3
			density = 1
			pwidth = 32
			pheight = 16
			pleft = 0
			pright = 32
			icon_state = "ramp-3"

		ramp_4
			density = 1
			pwidth = 32
			pheight = 16
			pleft = 32
			pright = 0
			icon_state = "ramp-4"