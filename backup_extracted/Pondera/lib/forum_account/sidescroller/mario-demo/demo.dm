
world
	New()
		SIDESCROLLER_DEBUG = 1
		..()

atom
	icon = 'mario.dmi'

client
	view = "16x15"

	New()
		mob = new /mob/player()
		..()

mob
	var
		flicker = 0

	proc
		// this makes the player's icon flicker to indicate they took damage
		flicker(t)
			if(flicker < t)
				flicker = t

	// This is only needed to counteract the April Fool's joke.
	New()
		..()
		overlays = null

	can_bump(mob/m)
		if(istype(m))
			if(m.scaffold)
				return ..()
			return 0
		return ..()

	// We add some new controls. While you're holding down Z
	// you'll move faster. We make X the jump key too.
	key_down(k)
		..()
		if(k == "z")
			move_speed = 6
		else if(k == "x")
			jumped = 1

	key_up(k)
		..()
		if(k == "z")
			move_speed = 4

	// We use the /mob/player and /mob/enemy sub-types to keep
	// things straight. This way enemies only damage players and
	// players only damage enemies.
	player
		base_state = "mario"

		Login()
			loc = locate(3,3,1)

			move_speed = 4

			pwidth = 24
			pheight = 30
			pixel_x = -4

			src << "Use the arrow keys to move. Hold Z to run faster and press X to jump."

		// we'll make gravity lower than the default to increase your hang time
		gravity()
			if(!on_ground)
				vel_y -= 0.7

		jump()
			vel_y = 12

		bump(atom/a, d)
			// If you bump an enemy from its top, it dies.
			// We also make the player bounce upwards a little.
			if(istype(a, /mob/enemy) && d == DOWN)
				vel_y = 6
				a:die()
				return

			// If you bump a turf from below, call its bumped proc.
			// The bumped proc is what makes bricks bounce when we
			// hit them. The bumped proc is defined in tiles.dm.
			if(isturf(a) && d == UP)
				a:bumped(src)

			..()

		// this makes the screen only scroll horizontally
		set_camera()
			..()
			camera.py = 256

		movement()
			..()

			// changing the player's invisibility var creates
			// the flicker effect.
			if(flicker)
				invisibility = !invisibility
				flicker -= 1
			else
				invisibility = 0

mob
	enemy
		var
			dead = 0

		proc
			// each sub-type of enemy can override this proc
			// to define their own death behavior.
			die()

			// This is called when the enemy touches a player.
			// Enemies damage the player by overlapping them,
			// not by bumping into them. This is because mobs
			// aren't dense to each other, so the bump proc
			// doesn't get called when the enemy touches a mob.
			hurt(mob/player/p)

				// We only want to hurt them if they're not still
				// flickering from the last hit.
				if(!p.flicker)
					p.knockback(src)
					p.flicker(40)

		goomba
			icon_state = "goomba"

			pwidth = 32
			pheight = 18

			// Setting scaffold = 1 means that we can walk in front
			// of the enemy but its top behaves like its dense. This
			// lets the player bump into the enemy from above, which
			// is what we need to be able to handle killing enemies
			// by stomping on their heads.
			scaffold = 1

			move_speed = 1
			dir = RIGHT

			// The set_state() proc automatically updates a mob's
			// icon_state to reflect the action it's performing.
			// We override it and define no behavior because we
			// don't need this, we want the goomba's icon_state to
			// be "goomba" until we tell it to change.
			set_state()

			die()
				dead = 1
				icon_state = "goomba-smushed"

				// make it stop moving
				vel_x = 0

				// make its top stop being dense
				scaffold = 0

				spawn(10)
					del src

			bump(atom/a, d)
				// when the enemy bumps into a wall, make them turn around
				if(d == LEFT || d == RIGHT)
					turn_around()

			action()
				// we don't want dead goombas running around!
				if(dead) return

				move(dir)

				// if the enemy is at the edge of a platform make them turn around
				if(at_edge())
					turn_around()

				// hurt all the players that the enemy is touching
				for(var/mob/player/p in inside())
					hurt(p)

				// invoke the default behavior (perform the move)
				..()
