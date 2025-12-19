
// File:    v4.2/demo.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This demo shows how to change the way that ladders
//   work. It shows how to change the rules that determine
//   if you're on a ladder. It also shows how to make
//   ladders that you can stand on top of.

#define DEBUG

world
	view = 6

atom
	icon = 'sidescroller-demo-icons.dmi'

mob
	base_state = "mob"

	Login()
		..()

		src << "In this demo you have to be completely within the ladder turf (horizontally) to be able to climb it."
		src << "You can also stand on top of ladders. To climb a down ladder you're standing on, hold the down arrow and press jump."

		pwidth = 24
		pheight = 24

		SIDESCROLLER_DEBUG = 1

	on_ladder()
		for(var/turf/t in locs)
			if(!t.ladder) continue

			// you're only considered to be over the ladder
			// if your mob is completely inside the turf
			// horizontally.
			if(px < t.px) continue
			if(px + pwidth > t.px + t.pwidth) continue

			return 1

		return 0

turf
	icon_state = "white"

	ladder
		icon_state = "ladder"
		ladder = 1

		New()
			..()

			// if there's no ladder turf above this one, make this
			// turf a scaffold so we can stand on top of it.
			var/turf/t = locate(x, y + 1, z)
			if(t && !t.ladder)
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
