world
	maxx = 25
	maxy = 25

	view = "15x15"

	mob = /mob/player

	New()
		..()
		new/obj/crow(locate(5, 5, 1))
		new/mob/crow(locate(10, 10, 1))

client/perspective = EDGE_PERSPECTIVE
mob
	crow
		icon = 'Crow.dmi'

		New()
			..()

			soundobj(src, 10, 'Crow.ogg', TRUE)
			spawn() movementLoop()

		proc/movementLoop()
			while(src)
				step_rand(src)
				sleep(rand(3, 5))
obj
	crow
		icon = 'Crow.dmi'

		New()
			..()

			soundobj(src.loc, 10, 'Crow.ogg', TRUE)
			//spawn() movementLoop()

		//proc/movementLoop()
			//while(src)
				//step_rand(src)
				//sleep(rand(3, 5))
	crow1
		icon = 'Crow.dmi'

		New()
			..()

			soundobj(src, 10, 'Crow.ogg', TRUE)
			spawn() movementLoop()

		proc/movementLoop()
			while(src)
				step_rand(src)
				sleep(rand(3, 5))
mob
	player/icon = 'Player.dmi'

turf/icon = 'Ground.dmi'