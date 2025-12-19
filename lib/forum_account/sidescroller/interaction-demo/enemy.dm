mob
	enemy
		pwidth = 24
		pheight = 24
		icon_state = "enemy"

		move_speed = 1
		dir = RIGHT

		// when an enemy bumps into a wall, make it turn around
		bump(atom/a, d)
			if(d == LEFT || d == RIGHT)
				turn_around()

		// the enemy's icon_state doesn't change
		set_state()

		action()

			// make the enemy move in the direction it's facing
			move(dir)

			// if it's at the edge of a platform, make the enemy turn around
			if(at_edge())
				turn_around()

