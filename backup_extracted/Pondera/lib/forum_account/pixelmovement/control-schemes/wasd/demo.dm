
// File:    control-schemes\wasd\demo.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   An example of how to use the mob's controls var to change
//   the keys that control the default movement behavior. In this
//   example, the W, A, S, and D keys make the mob move instead of
//   the arrow keys.

//world
	//view = 6

PixelMovement
	debug = 0

//atom
	//icon = 'basic-icons.dmi'

mob
	//base_state = "mob"

	//pwidth = 24
	//pheight = 24

	Login()
		..()

		controls.up = "w"
		controls.down = "s"
		controls.left = "a"
		controls.right = "d"

	//	src << "Use the WASD keys to move."

//turf
//	icon_state = "floor"

//	wall
	//	density = 1
	//	icon_state = "wall"