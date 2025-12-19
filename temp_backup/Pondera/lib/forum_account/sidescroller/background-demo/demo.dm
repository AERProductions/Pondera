
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
		Background/my_background

	Login()

		src << "This demo may run slowly if you have graphics hardware disabled for BYOND. To enable the use of graphics hardware, in the BYOND pager goto File -> Preferences -> Games and check the third option."
		src << ""

		..()

		pwidth = 24
		pheight = 24

		src << "Use the arrow keys to move and the space bar to jump."

		// The background proc just creates the background image, it doesn't
		// make it displayed. We have to store the return value (which is a
		// datum of type /Background) and call its show() proc to make it shown.
		my_background = background('background.png', REPEAT_X + REPEAT_Y)

		// This will make the background be displayed. You can call the hide()
		// proc later to hide it. You can create many backgrounds and have them
		// all shown at the same time.
		my_background.show()

		camera.lag = 0

	// This proc is automatically called each tick to give you
	// a chance to set the px and py of each background object.
	set_background()
		if(my_background)

			// The background object isn't an atom, but it has px and py vars.
			// These vars set it's position relative to the center of the player's
			// screen. We set their values based on the player's position so the
			// background scrolls as you move.
			my_background.px = -px * 1.2
			my_background.py = -py * 1.2

turf
	ladder
		icon_state = "ladder-2"
		ladder = 1

	wall
		density = 1
		icon_state = "wall"

		// autojoining
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