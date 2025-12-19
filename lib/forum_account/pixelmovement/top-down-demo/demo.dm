
// File:    top-down-demo\demo.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   A simple example of three-dimensional movment
//   with the SIDE_MAP map format. This demo
//   requires 3D movement, so make sure the line:
//   #define TWO_DIMENSIONAL in _flags.dm is commented
//   out, otherwise this demo won't compile.

world
	view = 6
	map_format = SIDE_MAP

PixelMovement
	debug = 1

atom
	icon = 'top-down-icons.dmi'

mob
	base_state = "mob"

	Login()
		..()

		pwidth = 24
		pheight = 10

		camera.mode = camera.SLIDE
		camera.lag = 48

		src << "Use the arrow keys to move and the space bar to jump."

turf
	icon_state = "floor"

	Click()
		usr.move_to(src)

	New()
		..()

		// make the tiles around the edge of the map tall enough that we can't
		// walk off the edge of the map.
		if(x == 1 || y == 1 || x == world.maxx || y == world.maxy)
			pdepth = 128

	proc
		generate_top()
			if(pdepth > 32) return

			var/obj/o = new()
			o.icon_state = icon_state
			o.pixel_z = pdepth + pz
			overlays += o

	wall
		density = 1
		icon_state = "wall"
		pdepth = 16

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

			generate_top()

		short_wall
			icon_state = "short-wall"
			pdepth = 10
			New()
				..()
				icon_state = "wall-0"
				generate_top()
