
world
	view = 6

mob
	pwidth = 24
	pheight = 24

	base_state = "mob"

	var
		dead

	Login()
		..()

		src << "Press Space Bar to jump."
		src << "Press X to shoot."
		src << "Press C to use doors."

		// make the camera not scroll horizontally
		camera.minx = 10 * 32 + 4
		camera.maxx = 10 * 32 + 4

		camera.miny = 228

		camera.lag = 32
		camera.mode = camera.SLIDE

		// force the camera into position (comment this line
		// out and run the demo to see the difference it makes).
		camera.center()

		SIDESCROLLER_DEBUG = 1

		// tweak the player's gravity...
		gravity = 0.7

	// ...and jump height
	jump()
		vel_y = 8

	// we override set_pos() to make mobs wrap around
	// the map, this way a mob that moves off the left
	// side of the map will wrap around to the right
	// side, and vice versa.
	set_pos(nx, ny, map_z = -1)

		// handle the case where nx isn't a number, its an atom to center
		// the mob over, in which case we run the default behavior
		if(!isnum(nx))
			return ..()

		// the px values for the left and right boundaries
		var/left = 32 * 3
		var/right = 32 * 17

		// if it's off the left side, wrap around to the right side
		if(nx < left)
			nx = right + nx - left

		// if it's off the right side, wrap around to the left side
		if(nx > right)
			nx = left + nx - right

		// run the default set_pos behavior with the updated position
		..(nx, ny, map_z)

	action()
		// dead mobs can't perform any actions
		if(dead)
			slow_down()
			return
		..()

	// make mobs able to move through each other.
	can_bump(mob/m)
		if(istype(m))
			return 0
		return ..()

	proc
		take_damage()
			if(!dead)
				// make the mob bounce in the air when they take damage
				vel_y = 4

				// one hit kills
				die()

		die()
			// if you're already dead, don't do anything
			if(dead) return

			dead = 1

			// make players (mobs with clients) move back to the start
			if(client)
				src << "Ouch! You died!"

				client.clear_input()
				client.lock_input()

				spawn(10)
					loc = locate(6,2,1)
					dead = 0
					client.unlock_input()

			// make enemies (mobs without clients) get deleted
			else
				spawn(20)
					del src