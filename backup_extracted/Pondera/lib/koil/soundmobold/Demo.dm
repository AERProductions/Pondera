world
	maxx = 25
	maxy = 25

	view = "15x15"

	mob = /mob/player

	New()
		..()

		new/mob/crow(locate(10, 10, 1))
		new/mob/test(locate(10, 10, 1))

client/perspective = EDGE_PERSPECTIVE

mob
	test
		icon = 'Crow.dmi'
		New()
			..()
			soundmob(src, 10, 'Crow.ogg', TRUE)
	crow
		icon = 'Crow.dmi'

		New()
			..()

			soundmob(src, 10, 'Crow.ogg', TRUE)
			spawn() movementLoop()

		proc/movementLoop()
			while(src)
				step_rand(src)
				sleep(rand(3, 5))

	player/icon = 'Player.dmi'

turf/icon = 'Ground.dmi'