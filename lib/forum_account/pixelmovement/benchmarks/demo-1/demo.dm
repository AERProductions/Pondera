
#define DEBUG

// File:    benchmarks\demo-1\demo.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   This benchmark creates mobs that bounce around
//   the map. Change the number of mobs and the
//   framerate to see how performance changes. Also
//   try enabling some flags in _flags.dm to see how
//   performance improves.

var
	const
		BALL_COUNT = 30

world
	view = 6
	fps = 40

PixelMovement
	debug = 1

atom
	icon = 'basic-icons.dmi'

mob
	icon_state = "mob-standing"

	var
		total_cpu = 0
		cpu_count = 0

	Stat()
		stat("cpu", world.cpu)
		if(world.time > 5)
			total_cpu += world.cpu
			cpu_count += 1

			stat("average", total_cpu / cpu_count)

	set_state()

	// make mobs able to walk through each other
	can_bump(mob/m)
		if(istype(m))
			return 0
		return ..()

	Login()
		loc = locate(13, 13, 1)

		pwidth = 24
		pheight = 24

		layer = MOB_LAYER + 1

		src << "Use the arrow keys to move."

		// A handy way to measure performance is to host using Dream Daemon,
		// start the world profiler, then connect a client and have the server
		// automatically delete the client after a specified amount of time.
		// This way you can run many trials to try different configurations and
		// can easily compare the results because the client is always connected
		// for the same amount of time.
		// spawn(100) del src

	ball
		icon_state = "ball"

		pwidth = 12
		pheight = 12

		// these mobs never decelerate
		decel = 0

		bump(atom/a, d)
			if(d == EAST || d == WEST)
				vel_x *= -1
			else if(d == NORTH || d == SOUTH)
				vel_y *= -1

		New()
			..()

			while(vel_x == 0 && vel_y == 0)
				vel_x = rand(-4,4)
				vel_y = rand(-4,4)

turf
	icon_state = "floor"

	wall
		density = 1
		icon_state = "wall"

world
	New()
		rand_seed(1)

		..()

		var/count = BALL_COUNT

		while(count > 0)

			var/tx = rand(2, world.maxx - 1)
			var/ty = rand(2, world.maxy - 1)

			var/turf/t = locate(tx, ty, 1)

			if(t.density) continue

			new /mob/ball(t)
			count -= 1
