world
	fps = 25		// 25 frames per second
	icon_size = 32	// 32x32 icon size by default
	view = 8		// show up to 6 tiles outward from center (13x13 view)
turf
	icon = 'Turf.dmi'
	icon_state = ""
mob
	step_size = 8
	Login()
		var/obj/Compas/C = new;var/obj/Arrow/A = new
		src.client.screen += C;src.client.screen += A
		src.loc = locate(10,10,1)
		src.icon = 'Player.dmi'
	Move()
		..()
		var/obj/O = src.Target
		if(O) //If you have a target.
			for(var/obj/Arrow/A in src.client.screen)
				animate(A, transform = turn(matrix(), get_angle_nums(src.x,src.y,O.x,O.y)), time = 3, loop = 1) //Play with the time to have it look cooler
obj
	Box
		icon = 'Turf.dmi'
		icon_state = "Gift"
		DblClick()
			usr.Target = src
