
// this file just stores all of the definitions for water types for the map generator
// it's stored here so that you don't need to go into backend.dm if you
// want to make changes to any water stuff

map_generator
	water
		tile = /turf/water

		min_size = 3
		max_size = 6

obj
	border
		water
			ramp_chance = 0
			icon = 'abeach.dmi'
			//icon_state = "beach"


turf
	water
		icon = 'gen.dmi'
		icon_state = "water"
		border_type = /obj/border/water
		density = TRUE
		spawn_resources = FALSE

		sfx = list( /obj/snd/sfx/waves
					)

		SetElevation(n)
			elevation = -5

		// paste needed functionality here