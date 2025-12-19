
// File:    isometric-demo\demo.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   A simple example of three-dimensional movment
//   with the ISOMETRIC_MAP map format. This demo
//   requires 3D movement, so make sure the line:
//   #define TWO_DIMENSIONAL in _flags.dm is commented
//   out, otherwise this demo won't compile.

world
	view = 6
	map_format = ISOMETRIC_MAP

PixelMovement
	debug = 1

atom
	icon = 'isometric-icons.dmi'

mob
	base_state = "mob"
	pdepth = 16

	Login()
		..()
		src << "Use the arrow keys to move and the space bar to jump."

	can_bump(atom/a)
		if(isobj(a))
			return a.density
		return ..()

	set_pos()
		..()

		layer = pz + 4

turf
	icon_state = "floor"

	New()
		..()

		// make the tiles around the edge of the map tall enough that we can't
		// walk off the edge of the map.
		if(x == 1 || y == 1 || x == world.maxx || y == world.maxy)
			pdepth = 128

		layer = pz + 4

	ramp_1
		icon_state = "ramp-1"
		ramp = 16
		ramp_dir = NORTH

	ramp_1_raised
		icon_state = "ramp-1-raised"
		ramp = 16
		ramp_dir = NORTH
		pdepth = 16

	ramp_2
		icon_state = "ramp-2"
		ramp = 16
		ramp_dir = WEST

	wall_8
		density = 1
		icon_state = "wall-8"
		pdepth = 8

	wall_16
		density = 1
		icon_state = "wall-16"
		pdepth = 16

	wall_32
		density = 1
		icon_state = "wall-32"
		pdepth = 32


obj
	bridge_1
		density = 1
		icon_state = "wall-8"
		pdepth = 8
		pixel_z = 24

	ramp_2_elevated
		density = 1
		icon_state = "ramp-2"
		pdepth = 0
		pixel_z = 16

		ramp_dir = WEST
		ramp = 16