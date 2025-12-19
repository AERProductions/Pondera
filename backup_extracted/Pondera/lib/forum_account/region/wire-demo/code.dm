
// File:    wire-demo\code.dm
// Library: Forum_account.Region
// Author:  Forum_account
//
// Contents:
//   This file contains turf definitions that are needed for the
//   demo, but don't directly relate to how the library is used.
//   The code that uses the library is in wire-demo\demo.dm.

world
	view = 8

atom
	icon = 'region-demo-icons.dmi'

mob
	icon_state = "mob"

turf
	grass
		icon_state = "grass"

	pavement
		icon_state = "pavement"

	sidewalk
		icon_state = "sidewalk"

	floor
		icon_state = "floor"

	wall
		density = 1
		icon_state = "wall"

	door
		density = 1
		icon_state = "door"

		proc
			open()
				density = 0
				icon_state = "floor"

			close()
				density = 1
				icon_state = "door"

	button
		icon_state = "button-off"

		var
			on = 0

		Entered(mob/m)
			toggle()

		proc
			toggle()
				if(on)
					off()
				else
					on()

			on()
				on = 1
				icon_state = "button-on"

			off()
				on = 0
				icon_state = "button-off"