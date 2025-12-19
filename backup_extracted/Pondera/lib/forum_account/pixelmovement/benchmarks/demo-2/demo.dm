
#define DEBUG

// File:    benchmarks\demo-2\demo.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   This benchmark creates some mobs that wander
//   around the map by repeatedly calling move_to.
//   You can adjust the number of mobs and the distance
//   of their moves to see how performance varies.
//
//   This also includes an example of the mob.watch
//   proc to allow the player to watch from the view
//   of any mob.

var
	const
		MOB_COUNT = 5
		MOVE_RANGE = 10

world
	view = 6
	tick_lag = 0.25

	New()
		rand_seed(1)
		..()

PixelMovement
	debug = 1

client
	perspective = EYE_PERSPECTIVE

atom
	icon = 'basic-icons.dmi'

mob
	icon_state = "mob"

	pwidth = 24
	pheight = 24

	var
		total_cpu = 0
		cpu_count = 0

	// make mobs able to walk through each other
	can_bump(mob/m)
		if(istype(m))
			return 0
		return ..()

	key_down(k)
		if(k == "c")
			// find the next mob in the world after
			// the one you're currently watching and
			// make you follow them.
			var/next = 0
			for(var/mob/m in world)
				if(next)
					watch(m)
					world << "Watching [m]..."
					return

				if(client.eye == m)
					next = 1

			for(var/mob/m in world)
				watch(m)
				world << "Watching [m]..."
				return

	Stat()
		stat("cpu", world.cpu)
		if(world.time > 5)
			total_cpu += world.cpu
			cpu_count += 1

			stat("average", total_cpu / cpu_count)

			stat("average move distance", total_move_dist / total_move_count)

	set_state()

	Login()
		loc = locate(13, 13, 1)
		layer = MOB_LAYER + 1

		camera.mode = camera.SLIDE
		camera.lag = 0

		src << "Use the arrow keys to move. Press C to make your camera follow a different mob."

	mover
		action()
			if(!path)
				var/turf/t = locate(x + rand(-MOVE_RANGE, MOVE_RANGE), y + rand(-MOVE_RANGE, MOVE_RANGE), z)

				if(t)
					total_move_dist += get_dist(src, t)
					total_move_count += 1
					move_to(t)
			..()

		New()
			..()

			move_speed = rand(2,4)
			name = "mover-[rand(1000,9999)]"

			while(vel_x == 0 && vel_y == 0)
				vel_x = rand(-4,4)
				vel_y = rand(-4,4)

turf
	icon_state = "floor"

	wall
		density = 1
		icon_state = "wall"

var
	total_move_dist = 0
	total_move_count = 0

world
	New()
		..()

		var/count = MOB_COUNT

		while(count > 0)

			var/tx = rand(2, world.maxx - 1)
			var/ty = rand(2, world.maxy - 1)

			var/turf/t = locate(tx, ty, 1)

			if(t.density) continue

			new /mob/mover(t)
			count -= 1
