
#define DEBUG

// File:    v2.4/demo.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This demo shows how to use the features that are new
//   in version 2.4 of the library. These features include:
//
//    * camera modes (slide and follow)
//    * camera lag
//    * camera bounds (minx, maxx, miny, maxy)
//    * stepped_on, stepped_off, and stepping_on procs

world
	view = 6

	New()
		SIDESCROLLER_DEBUG = 1
		..()

// We define three areas to create "rooms" by setting
// the minx, maxx, miny, and maxy of the mob's camera
// when the mob enters the area. By setting minx and
// maxx to the same value we can create areas where the
// camera only scrolls vertically. We can create the
// same effect for horizontal scrolling only by setting
// miny equal to maxy.
area
	var
		minx = 0
		maxx = 2000
		miny = 0
		maxy = 2000

	Entered(mob/m)
		if(m.camera)
			m.camera.minx = minx
			m.camera.maxx = maxx
			m.camera.miny = miny
			m.camera.maxy = maxy

	zone_1
		minx = 224
		maxx = 256
		miny = 224
		maxy = 224

	zone_2
		minx = 224
		maxx = 416
		miny = 448
		maxy = 448

	zone_3
		minx = 320
		maxx = 320
		miny = 736
		maxy = 736

	// Idea:
	// It'd be neat to define an object (ex: /obj/camera) and place
	// them inside these areas. Then, in the area's constructor, use
	// these objects to determine the values for minx, maxx, etc. For
	// example, minx would be set to 32 times the x coordinate of the
	// leftmost camera object in the area. This would let you define
	// the bounds of the camera entirely in the map editor and you
	// wouldn't need to do any work to calculate coordinates (or to
	// re-calculate coordinates when the map changes).

atom
	icon = 'sidescroller-demo-icons.dmi'

mob
	base_state = "mob"

	Login()
		..()
		src << "Use the arrow keys to move and the space bar to jump."

		camera.mode = camera.SLIDE
		camera.lag = 48

		src << "camera.mode = camera.SLIDE"
		src << "camera.lag = 48"

		pwidth = 24
		pheight = 24

	verb
		Toggle_Camera_Mode()
			if(camera.mode == camera.FOLLOW)
				camera.mode = camera.SLIDE
				src << "camera.mode = camera.SLIDE"
			else
				camera.mode = camera.FOLLOW
				src << "camera.mode = camera.FOLLOW"

		Toggle_Camera_Lag()
			if(camera.lag)
				camera.lag = 0
				src << "camera.lag = 0"
			else
				camera.lag = 48
				src << "camera.lag = 48"

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

		ice
			icon_state = "ice"

			// This is called when you first step on top of the turf.
			stepped_on(mob/m)
				m << "You stepped on the ice."

			// This is called when you stop standing on the turf.
			stepped_off(mob/m)
				m << "You stepped off the ice."

			// This is called every tick for as long as you're on top of
			// the turf. The second argument, t, is the number of ticks
			// you've spent on the turf.
			stepping_on(mob/m, t)

				// If we printed a message every time this was called it
				// would spam the player, so instead we'll output a message
				// every 20 ticks.
				if(t % 20 == 0)
					m << "You've been standing on the ice for [t] ticks."