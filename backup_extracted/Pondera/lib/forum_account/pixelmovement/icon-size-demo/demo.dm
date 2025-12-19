
// File:    icon-size-demo\demo.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   This demo shows that the library supports
//   any value of world.icon_size.

atom
	icon = '48x24.dmi'

world
	icon_size = "48x24"

PixelMovement
	debug = 1

mob
	pwidth = 24
	pheight = 24
	icon_state = "mob"

	set_state()

turf
	icon_state = "floor"

	wall
		density = 1
		icon_state = "wall"
