
atom
	icon = 'sidescroller-demo-icons.dmi'

turf
	icon_state = "white"

	ladder
		icon_state = "ladder"
		ladder = 1

	spikes
		icon_state = "spikes"
		New()
			..()

			var/obj/o = new /obj()
			o.icon_state = "spikes-overlay"
			o.layer = MOB_LAYER + 1
			overlays += o

	// stepped_on is called when you're standing on the top of a tile.
	// We want the player to die when they step on a tile that has spikes
	// on top of it, not when the player steps on the spikes tile.
	stepped_on(mob/m)
		var/turf/t = locate(x,y+1,z)
		if(istype(t,/turf/spikes))
			m.die()

	Entered(mob/m)
		var/obj/o = locate(/obj/checkpoint) in src
		if(m.client && o)
			if(m.saved_location != src)
				flick("checkpoint-flash", o)
				m.saved_location = src
				m << "Checkpoint Reached!"
		..()

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

		ramp_1
			density = 1
			pwidth = 32
			pheight = 16
			pleft = 0
			pright = 16
			icon_state = "ramp-1"

			New()
				..()
				icon_state = "ramp-1"

		ramp_3
			density = 1
			pwidth = 32
			pheight = 16
			pleft = 0
			pright = 32
			icon_state = "ramp-3"

			New()
				..()
				icon_state = "ramp-3"

		ramp_4
			density = 1
			pwidth = 32
			pheight = 16
			pleft = 32
			pright = 0
			icon_state = "ramp-4"

			New()
				..()
				icon_state = "ramp-4"

	finish
		icon_state = "white"

		Entered(mob/m)
			m << "You've reached the end! Congratulations!"

obj
	short_floor
		icon_state = "short-floor"
		density = 1
		pwidth = 16
		pixel_x = -1

obj
	checkpoint
		icon_state = "checkpoint"
		layer = MOB_LAYER + 1