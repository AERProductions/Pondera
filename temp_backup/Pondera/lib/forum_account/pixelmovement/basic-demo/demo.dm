
// File:    basic-demo\demo.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   A simple example of how to use the library.

world
	view = 6

// Enable the library's debugging statpanel
PixelMovement
	debug = 1

atom
	icon = 'basic-icons.dmi'

mob
	base_state = "mob"

	// This defines the size of the mob. The mob's icon
	// is a blue box that's 24 pixels by 24 pixels, so we
	// set your pwidth and pheight to reflect that.
	pwidth = 24
	pheight = 24

	Login()
		..()
		src << "Use the arrow keys to move."

turf
	icon_state = "floor"

	wall
		density = 1
		icon_state = "wall"
