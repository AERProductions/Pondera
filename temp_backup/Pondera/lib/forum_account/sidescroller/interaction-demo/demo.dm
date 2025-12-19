
world
	view = 6

	New()
		SIDESCROLLER_DEBUG = 1
		..()

atom
	icon = 'sidescroller-demo-icons.dmi'

mob
	base_state = "mob"

	var
		invulnerable = 0

	Login()
		..()

		pwidth = 24
		pheight = 24

		src << "Use the arrow keys to move and the space bar to jump. Press X to interact with objects."

	movement()
		..()

		// check if you hit an enemy
		if(client)
			// if you're still temporarily invulnerable then just make the
			// player flicker.
			if(world.time < invulnerable)
				invisibility = !invisibility
			else
				invisibility = 0

				for(var/mob/enemy/e in oview(1,src))
					if(e.inside(src))

						// knock the player away from the enemy.
						knockback(e)

						// make the player invulnerable for one second
						invulnerable = world.time + 10
						break

	key_down(k)
		if(k == "x")
			interact()
		..()

	proc
		interact()
			// front(4) returns a list of all atoms within 4 pixels
			// of your mob in the direction you're facing.
			var/list/f = front(6)

			for(var/mob/m in f)
				m.vel_y += 6

			for(var/turf/door/d in f)
				d.open()

// -- pushable boxes --
mob
	// make the player capable of bumping into boxes
	can_bump(mob/box/b)
		if(istype(b))
			return 1
		else if(ismob(b))
			return 0
		else
			return ..()

	// Every time you try to move, check if there's a box in
	// your way and if there is, try to move it.
	// note: This same code is run for boxes too, so when a box
	//       moves it'll also try to push boxes out of the way.
	//       This automatically makes it work so that a player
	//       can push a whole line of boxes.
	pixel_move(dpx, dpy)

		// we could use the front() proc here, but we
		// want to check the left or right side based
		// on the direction of motion, not on the direction
		// you're facing. If the mob is moving left
		// but facing right, front() would be wrong.
		var/list/front
		if(dpx < 0)
			front = left(-dpx)
		else
			front = right(dpx)

		// try to push the box out of your way
		for(var/mob/box/b in front)
			b.pixel_move(dpx, 0)

		// then perform your move
		..()

	// define the box
	box
		icon_state = "box"
		pwidth = 16
		pheight = 16

		// the box doesn't change icon_state, so we make
		// set_state do nothing
		set_state()

// -- turfs --
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

// -- a door that can open and close --
	door
		density = 1
		icon_state = "door-closed"
		var
			// 0 = closed, 1 = transition, 2 = open
			state = 0

		proc
			open()
				// open() can only work if the door is closed to begin with
				if(state != 0) return

				// switch to the transition state, play an animation,
				// and change the door's density.
				state = 1
				flick("door-opening", src)
				icon_state = "door-open"

				spawn(6 * world.tick_lag)
					state = 2
					density = 0

				spawn(20)
					close()

			close()
				// close() can only work if the door is open to begin with
				if(state != 2) return

				// If there's a mob in the doorway it can't close. Wait one
				// second and try again.
				if(locate(/mob) in inside())
					spawn(10) close()
					return

				// switch to the transition state, play an animation,
				// and change the door's density.
				state = 1
				density = 1
				flick("door-closing", src)
				icon_state = "door-closed"

				spawn(6 * world.tick_lag)
					state = 0