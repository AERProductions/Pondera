
// File:    v2.5/demo.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This demo shows how to use the features that are new
//   in version 2.5 of the library. These features include:
//
//    * debugging trace
//
//   This demo also shows how to create variable-height jumps,
//   the longer you hold the jump key the higher you'll do.
//   This doesn't use a new feature, it's just a new example
//   of existing features.

world
	view = 6

atom
	icon = 'sidescroller-demo-icons.dmi'

mob
	base_state = "mob"

	Login()
		..()
		src << "Use the arrow keys to move and the space bar to jump. Tap the space bar to do a small jump, hold it down to jump higher."
		src << ""
		src << "Click to throw grenades. After a grenade disappears its movement log will be shown in the browser. This is a new debugging feature."
		pwidth = 24
		pheight = 24

		// This enables the debugging statpanel, which can
		// be useful for some things but not everything. For
		// example, when movement isn't working, what's the
		// reason? Are the macros not working? Does the program
		// not reckognize the keypress events? Or does it get
		// the keyboard input and the pixel movement procs just
		// aren't working?
		//
		// The debugging statpanel will show you, among other
		// things, what keys you're holding down. This lets you
		// know that the macros are working and that the library
		// is getting the keyboard input ok. To check what movement
		// procs are being called you can use the new debugging
		// trace feature. See the Start_Trace() verb for more.
		SIDESCROLLER_DEBUG = 1

	// this shows how to create variable-height jumps
	var
		boost = 0

	jump()
		vel_y = 6
		boost = 8

		// After you jump, if you continue to hold the jump key
		// you'll continue to accelerate upwards. The boost var
		// is the number of ticks it'll check for. In this case,
		// you'll continue to accelerate upwards for 6 ticks if
		// you keep holding the jump key.

	action()
		// after you jump, for the next 6 ticks you'll
		// be able to continue accelerating upwards (to
		// jump higher) if you keep the jump key held.
		if(boost > 0)
			boost -= 1
			if(client.keys[controls.jump])
				vel_y += 1
			else
				boost = 0
		..()

	bump(atom/a, d)
		..()

		// If you jumped and hit the ceiling, you can't continue
		// to accelerate upwards
		if(d == UP)
			boost = 0

	can_bump(mob/m)
		if(istype(m))
			return 0
		return ..()

	verb
		// After the start_trace() proc is called for a mob, all
		// of its movement related procs (movement, set_pos, bump,
		// pixel_step, etc.) will be logged. When stop trace is
		// called (it's called automatically when the mob is
		// deleted) you'll be shown the trace, which includes the
		// time that each proc was called and the arguments passed
		// to it.
		//
		// This can be useful for tracking down certain kinds of
		// issues. I used it to track down a problem that only occurred
		// in certain cases when the mob's px and py had decimal values.
		// This would have been difficult to find by watching things
		// live, but was easy to see when looking through the log.
		Start_Trace()
			if(!trace)
				world << "Movement trace started..."
				start_trace()

		// After you click "Stop Trace" your movement log
		// will be shown in the browser tab of the interface.
		Stop_Trace()
			if(trace)
				world << "Movement trace ended."
				stop_trace()

turf
	Click()
		// You don't have to trace the movement of the
		// player's mob, you can trace the movement of
		// any mob, even projectiles.
		var/mob/m = new /mob/grenade(usr, src)
		m.start_trace()

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

// this is the grenade implementation from shooter-demo.
mob
	grenade
		pwidth = 8
		pheight = 8

		set_state()
			if(vel_x == 0 && vel_y == 0)
				icon_state = "grenade-still"
			else
				icon_state = "grenade-moving"

		movement()

			..()

			if(on_ground)
				slow_down()

			if(vel_x == 0 && vel_y == 0)
				spawn(10)
					del src

		New(mob/source, atom/target)

			loc = source.loc
			set_pos(source.px + source.pwidth / 2, source.py + source.pheight / 2)

			var/dx = (target.px + target.pwidth / 2) - px
			var/dy = (target.py + target.pheight / 2) - py

			vel_x = dx * 0.1
			vel_y = dy * 0.1

		bump(atom/a, d)
			if(d == RIGHT || d == LEFT)
				vel_x = round(vel_x * -0.5)
			else
				vel_y = round(vel_y * -0.5)