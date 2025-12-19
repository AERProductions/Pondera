
world
	view = 6

	New()
		SIDESCROLLER_DEBUG = 1
		..()

mob
	base_state = "mob"
	var
		turf/saved_location
		dead = 0

	Login()
		..()

		loc = locate(2,2,1)
		saved_location = loc

		pwidth = 24
		pheight = 24

	proc
		die()
			if(dead) return

			if(!client) return

			src << "You died! You will respawn shortly."
			dead = 1
			client.clear_input()
			client.lock_input()

			spawn(20)
				set_pos(32 * saved_location.x, 32 * saved_location.y)

				client.clear_input()
				client.unlock_input()
				dead = 0