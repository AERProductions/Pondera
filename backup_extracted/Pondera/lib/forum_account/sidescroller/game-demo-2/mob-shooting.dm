
mob
	var
		shooting = 0

	set_state()

		// if the player has recently fired, show the "shooting"
		// state, otherwise run the default behavior
		if(shooting)
			icon_state = "[base_state]-shooting"
		else
			..()

	key_down(k)
		..()
		if(k == "x")
			// if you've recently shot, you can't shoot again
			if(shooting) return

			// if the player is holding up or down they'll shoot
			// in that direction, otherwise they shoot in the
			// direction they're facing.
			if(client.keys[controls.up])
				shoot(NORTH)
			else if(client.keys[controls.down])
				shoot(SOUTH)
			else
				shoot(dir)

	proc
		shoot(d)

			// spawn a new bullet that'll move in the specified direction
			new /mob/projectile/bullet(src, d)

			// this will cause the player to show a "shooting"
			// icon_state, it'll also act as a delay to limit
			// how fast the player can shoot
			shooting = 1
			spawn(15 * world.tick_lag) shooting = 0

mob
	projectile
		var
			mob/owner
			damage = 0
			lifetime = 60

		New(mob/m, vx, vy)
			..()

			owner = m

			vel_x = vx
			vel_y = vy

			// passing set_pos() an atom will make this
			// projectile be centered inside that atom.
			set_pos(m)

			spawn(world.tick_lag * lifetime)
				del src

		set_state()

		bump()
			del src

		movement()
			pixel_move(vel_x, vel_y)

			// check to see if the projectile is overlapping a mob
			for(var/mob/m in inside())
				// if the mob is the projectile's owner or if the
				// mob is dead, ignore it
				if(m == owner) continue
				if(m.dead) continue

				// otherwise, hurt the mob and delete the projectile
				m.take_damage(damage)
				del src

		bullet
			pwidth = 4
			pheight = 4
			pixel_x = -14
			pixel_y = -14

			icon_state = "bullet"

			// d is the direction the bullet will move in
			New(mob/m, d)

				// convert the direction to x/y components
				var/dx = 0
				var/dy = 0

				if(d & EAST) dx = 6
				if(d & WEST) dx = -6
				if(d & NORTH) dy = 6
				if(d & SOUTH) dy = -6

				..(m, dx, dy)