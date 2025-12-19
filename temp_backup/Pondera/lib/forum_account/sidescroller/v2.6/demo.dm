
// File:    v2.6/demo.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This demo creates a conveyor belt. It doesn't have
//   anything to do with version 2.6 of the library, that
//   just happens to be when it was added.

world
	view = 6

var
	const
		CONVEYOR_LEFT = 2

atom
	icon = 'sidescroller-demo-icons.dmi'

mob
	base_state = "mob"

	Login()
		..()
		pwidth = 24
		pheight = 24

	pixel_move(dpx, dpy)

		if(on_ground & CONVEYOR_LEFT)
			dpx -= 1

		..()

obj
	conveyor_left
		icon_state = "conveyor-left"

		New()
			..()
			var/turf/t = loc
			t.flags = CONVEYOR_LEFT

turf
	icon_state = "white"

	ladder
		icon_state = "ladder"
		ladder = 1

	wall
		density = 1
		icon_state = "wall"

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
