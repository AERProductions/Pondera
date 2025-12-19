
world
	view = 6

	New()
		SIDESCROLLER_DEBUG = 1
		..()

atom
	icon = 'sidescroller-demo-icons.dmi'

mob
	base_state = "mob"

	Login()
		..()

		pwidth = 24
		pheight = 24

		src << "Use the arrow keys to move and the space bar to jump."

	key_down(k)
		..()
		if(k == "j")
			if(dir == RIGHT)
				set_pos(px + 8, py)
			else
				set_pos(px - 8, py)

turf
	icon_state = "white"

	ladder
		icon_state = "ladder"
		ladder = 1

	wall
		density = 1
		icon_state = "wall"
