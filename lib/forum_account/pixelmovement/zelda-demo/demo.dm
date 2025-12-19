
// File:    zelda-demo\demo.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   A simple example of how to create some gameplay
//   mechanics from the NES Zelda game, including:
//
//     * screen transitions
//     * enemies with AI
//     * projectile attacks
//     * melee attacks

atom
	icon = 'zelda-icons.dmi'

world
	view = "16x11"
	tick_lag = 0.3

PixelMovement
	debug = 1

mob
	density = 0
	base_state = "link"

	Login()
		..()
		camera.mode = camera.SLIDE

		#ifndef TWO_DIMENSIONAL
		src << "<b>\red This library requires 2D mode, see _flags.dm to change modes.</b>"
		#endif

		src << "Use the arrow keys to move and the space bar to attack."

	// when the player is hit by something, make them get pushed backwards
	proc
		hit(mob/m)
			if(m.dir == NORTH)
				vel_y = 10
			else if(m.dir == SOUTH)
				vel_y = -10
			else if(m.dir == EAST)
				vel_x = 10
			else if(m.dir == WEST)
				vel_x = -10

// ---- start of code for attacking ----

mob
	var
		attacking = 0

	proc
		attack()
			// only attack if you're not already attacking
			if(attacking) return

			// set the attacking flag and make the player stop moving
			attacking = 1
			vel_x = 0
			vel_y = 0

			// show the sword effect
			new /obj/sword(src)

			// damage all enemies in front of the player
			for(var/mob/enemy/e in front(32))
				e.hit(src)

			// clear the attacking flag after 10 ticks (0.25 seconds)
			spawn(10 * world.tick_lag)
				attacking = 0

	// the space bar is the attack key
	key_down(k)
		if(k == "space")
			attack()
		..()

	// you can't move while you're attacking, so we only
	// call ..() if you're not attacking.
	move()
		if(!attacking)
			..()

	// while attacking is set to 1, we show the attacking
	// icon_state, otherwise we do the default behavior.
	set_state()
		if(attacking)
			icon_state = "link-attacking"
		else
			..()

obj
	sword
		icon_state = "sword"

		New(mob/m)
			var/dx = 0
			var/dy = 0

			if(m.dir == NORTH)
				dy = 32
			else if(m.dir == SOUTH)
				dy = -32
			else if(m.dir & EAST)
				dx = 32
			else if(m.dir & WEST)
				dx = -32

			dir = m.dir
			loc = m.loc
			pixel_x = m.step_x + dx
			pixel_y = m.step_y + dy

			spawn(10 * world.tick_lag)
				del src

// ---- end of code for attacking ----


// ---- start of code for enemies ----

mob
	enemy
		decel = 0
		var
			flicker = 0

		// when the enemy is hit, make them flicker
		hit(mob/m)
			flicker = 30

		// we don't need to use the set_state behavior to
		// manage the enemy's icon_state, so we override it and
		// make the proc do nothing.
		set_state()

		octorok
			icon_state = "octorok"

			var
				delay = 0
				steps = 0

			New()
				..()
				new_dir()

			// the enemy will turn when it bumps into something
			bump()
				new_dir()

			proc
				// this is called to make the mob change directions.
				new_dir()
					dir = pick(NORTH, SOUTH, EAST, WEST)
					delay = 20
					steps = rand(1,5) * 32

					// set the mob's velocity according to their direction.
					vel_x = 0
					vel_y = 0
					if(dir == NORTH)
						vel_y = 1
					else if(dir == SOUTH)
						vel_y = -1
					else if(dir == EAST)
						vel_x = 1
					else if(dir == WEST)
						vel_x = -1

				shoot()
					new /mob/projectile/rock(src)

			// the movement proc is where we implement the enemy's AI. We make
			// the enemy move forward a specified number of steps. After making
			// those steps without bumping into something first, it'll shoot,
			// change directions, pause for a little while, then start moving.
			movement()
				// make the mob flicker
				if(flicker > 0)
					flicker -= 1
					invisibility = !invisibility
				else
					invisibility = 0

				// if there's a delay, just decrement it and don't
				// call ..() (calling ..() would make the mob move).
				if(delay > 0)
					delay -= 1
				else
					// decrement the number of steps the mob will take, when this
					// reaches zero make it pick a new direction to move in.
					steps -= 1
					if(steps <= 0)
						shoot()
						new_dir()

					else
						..()

// ---- end of code for enemies ----


// ---- start of code for projectiles ----
mob
	projectile

		// projectiles have a static state, so we override
		// set_state() and make it do nothing, otherwise it'll
		// try to give the mob movement and standing states.
		set_state()

		// m is the mob that shot the projectile
		New(mob/m)
			loc = m.loc
			dir = m.dir

			// set the velocity based on the dir the mob is facing
			if(dir == NORTH)
				vel_y = 6
			else if(dir == SOUTH)
				vel_y = -6
			else if(dir == EAST)
				vel_x = 6
			else if(dir == WEST)
				vel_x = -6

			set_pos(m.px + 8, m.py + 8)

		action()
			// inside() returns the list of atoms inside
			// the projectile's bounding box, so we check
			// for when the player is in that list.
			for(var/mob/m in inside())
				if(m.client)
					m.hit(src)
					del src

		bump()
			del src

		// define the rock projectile and set its icon_state and size.
		rock
			icon_state = "rock"
			pwidth = 16
			pheight = 16
			pixel_x = -8
			pixel_y = -8

// ---- end of code for projectiles ----


// ---- start of code for camera control ----

// We create areas that determine how the camera works.
// In each area the camera's bounds are set. Because the
// minx and maxx, miny and maxy are the same for all areas,
// the camera will not scroll. It'll slide into place when
// you transition from one screen to another, but then it
// stays put, kind of like the original Zelda NES game.
area
	camera
		var
			minx
			maxx
			miny
			maxy

		Entered(mob/m)
			..()
			m.camera.minx = minx
			m.camera.maxx = maxx
			m.camera.miny = miny
			m.camera.maxy = maxy

		// We define six areas because our map has six
		// rooms (3x2).
		_1_1
			// These numbers make the camera centered in each room.
			minx = 288
			maxx = 288
			miny = 192
			maxy = 192

		_2_1
			minx = 800
			maxx = 800
			miny = 192
			maxy = 192

		_3_1
			minx = 1312
			maxx = 1312
			miny = 192
			maxy = 192

		_1_2
			minx = 288
			maxx = 288
			miny = 544
			maxy = 544

		_2_2
			minx = 800
			maxx = 800
			miny = 544
			maxy = 544

		_3_2
			minx = 1312
			maxx = 1312
			miny = 544
			maxy = 544

// ---- end of code for camera control ----


// ---- start of code for turfs ----
turf
	grass
		icon_state = "grass"

	stone
		density = 1
		icon_state = "stone"

	tree
		density = 1
		icon_state = "tree"

	water
		density = 1
		icon_state = "water-15"

		New()
			..()
			var/n = 0
			var/turf/t = locate(x, y + 1, z)
			if(!t || istype(t, type)) n += 1
			t = locate(x + 1, y, z)
			if(!t || istype(t, type)) n += 2
			t = locate(x, y - 1, z)
			if(!t || istype(t, type)) n += 4
			t = locate(x - 1, y, z)
			if(!t || istype(t, type)) n += 8
			icon_state = "water-[n]"

// ---- end of code for turfs ----