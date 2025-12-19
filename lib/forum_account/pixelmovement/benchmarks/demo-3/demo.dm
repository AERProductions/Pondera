
#define DEBUG

// File:    benchmarks\demo-3\demo.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   A simple example of three-dimensional movment
//   with the ISOMETRIC_MAP map format. This demo
//   requires 3D movement, so make sure the line:
//   #define TWO_DIMENSIONAL in _flags.dm is commented
//   out, otherwise this demo won't compile.

var
	const
		MOB_COUNT = 10

world
	map_format = ISOMETRIC_MAP

	New()
		..()

		for(var/i = 1 to MOB_COUNT)
			var/x = rand(2, maxx - 1)
			var/y = rand(2, maxy - 1)
			new /mob/random(locate(x, y, 1))

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

	random
		action()
			..()

			// path will be set to a non-null value if this mob is
			// in the process of following a path, so we want to only
			// call move_to when path is null.
			if(!path)
				var/x = rand(2, world.maxx - 1)
				var/y = rand(2, world.maxy - 1)
				move_to(locate(x, y, 1))

		// make these mobs jump when they hit something, this helps with pathfinding.
		bump(atom/a)
			if(can_jump())
				jump()

			..()


// the rest of the code is needed for the demo but doesn't really
// have anything to do with how you use the Pixel Movement library.

turf
	icon_state = "floor"

	New()
		..()

		// make the tiles around the edge of the map tall enough that we can't
		// walk off the edge of the map.
		if(x == 1 || y == 1 || x == world.maxx || y == world.maxy)
			pdepth = 128

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