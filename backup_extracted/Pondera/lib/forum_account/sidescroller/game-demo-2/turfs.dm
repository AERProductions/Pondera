
atom
	icon = 'game-icons.dmi'

turf
	icon_state = "white"

	ladder
		icon_state = "ladder"
		ladder = 1

	wall
		density = 1
		icon_state = "wall"

		New()
			..()
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
