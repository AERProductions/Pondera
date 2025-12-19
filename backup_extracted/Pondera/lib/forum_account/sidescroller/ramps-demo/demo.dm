
world
	view = 6

	New()
		SIDESCROLLER_DEBUG = 1
		..()

atom
	icon = 'sidescroller-demo-icons.dmi'

mob
	base_state = "mob"

	Login()
		loc = locate(2,2,1)

		pwidth = 24
		pheight = 24

		src << "Use the arrow keys to move and the space bar to jump."

	can_bump(obj/o)
		if(istype(o))
			return o.density
		return ..()

turf
	icon_state = "white"

	ladder
		icon_state = "ladder"
		ladder = 1

	wall
		density = 1
		icon_state = "wall"

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

obj
	short_floor
		icon_state = "short-floor"
		density = 1
		pwidth = 16
		pixel_x = -1