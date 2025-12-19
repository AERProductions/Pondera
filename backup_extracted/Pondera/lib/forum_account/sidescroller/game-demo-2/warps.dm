
area
	warp
		layer = MOB_LAYER - 1
		icon_state = "door"

		door_01
		door_02
		door_03

		proc
			warp(mob/m)
				for(var/turf/t in src)

					// if the mob is standing over this tile, skip it
					if(t in m.locs) continue

					// Warp to the first tile in this warp area that this
					// mob isn't standing over. If there are two turfs in
					// this area, using the warp will take you between them.
					m.loc = t

					// if the mob has a camera, center it
					if(m.camera)
						m.camera.center(1)

					// once we've warped, we're done and can stop iterating over turfs
					return

mob
	key_down(k)
		..()

		if(k == "c")

			// you have to be on the map for this to work
			if(!loc)
				return

			var/area/warp/a = loc:loc

			// if you're standing in a warp area, use the warp
			if(istype(a))
				a.warp(src)