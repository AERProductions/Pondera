
#define DEBUG

// File:    v3.2/demo.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This demo creates a configurable number of mobs that
//   move randomly around the map. This can be used to get
//   an estimate of CPU usage for a specific number of mobs.

var
	const
		MOB_COUNT = 10

world
	view = 6

	New()
		SIDESCROLLER_DEBUG = 1

		..()

		// create mobs placed randomly around the map
		var/area/a = locate(/area/pathing) in world
		for(var/i = 1 to MOB_COUNT)
			new /mob/random(pick(a.contents))

area
	pathing

atom
	icon = 'sidescroller-demo-icons.dmi'

client
	view = "31x20"

mob
	base_state = "mob"

	pwidth = 24
	pheight = 24

	can_bump(mob/m)
		if(istype(m))
			return 0
		return ..()

	random
		action()
			..()

			// path will be set to a non-null value if this mob is
			// in the process of following a path, so we want to only
			// call move_to when path is null.
			if(!path)
				var/area/a = locate(/area/pathing) in world
				move_to(pick(a.contents))

turf
	icon_state = "white"

	ladder
		icon_state = "ladder"
		ladder = 1

	platform
		icon_state = "platform"
		scaffold = 1

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
