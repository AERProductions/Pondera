mob
	enemy
		enemy_1
			icon_state = "enemy"

			pwidth = 24
			pheight = 24

			vel_x = 1
			dir = RIGHT

			set_state()

			// when the enemy bumps into a wall, make them turn around
			bump(atom/a, d)
				if(d == LEFT || d == RIGHT)
					turn_around()

			// simple enemy AI - the enemy walks back and forth on its platform,
			// turning around when it reaches the edge or a wall
			action()
				// if you're dead, don't do anything
				if(dead)
					slow_down()
					return

				// if the enemy is at the edge of a platform make them turn around
				if(at_edge())
					turn_around()

				// hurt all the players that the enemy is touching
				for(var/mob/m in inside())
					m.take_damage()
