#define DEBUG

world
	view = 6

	New()
		SIDESCROLLER_DEBUG = 1
		..()

atom
	icon = 'sidescroller-demo-icons.dmi'

mob
	base_state = "mob"

	Login()
		..()

		pwidth = 24
		pheight = 24

		src << "Click on a tile to move to it. Press 1 to use move_towards, press 2 to use move_to."

		target = new()
		target.icon_state = "target"

	var
		smart_pathing = 1

		obj/target

	key_down(k)
		..()

		if(k == "1")
			smart_pathing = 0
			src << "Using <tt>move_towards</tt>."

		else if(k == "2")
			smart_pathing = 1
			src << "Using <tt>move_to</tt>."

		else if(k == "escape")
			stop()
			src << "Stopped."
			usr.target.loc = null

turf
	Click()
		if(density) return

		usr.target.loc = src

		if(usr.smart_pathing)
			usr.move_to(src)
		else
			usr.move_towards(src)

Path
	compute()
		..()

		world << "Checked [closed.len] turfs to find the path."

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
