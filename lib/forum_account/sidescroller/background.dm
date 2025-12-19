
// File:    background.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This file contains the code for creating background
//   objects. The code for updating the positions of
//   background objects is in pixel-movement.dm

var
	const
		REPEAT_X = 1
		REPEAT_Y = 2

// The /Background object contains the actual object
// and image that are the visual background display, it
// also contains size and position info. To move the
// background you change the px and py vars and the
// set_camera proc adjusts the background accordingly.
Background
	var
		obj/object
		image/image

		width
		height

		px = 0
		py = 0

		mob/owner

		repeat = 0

	New(mob/m, i, scroll_mode)

		owner = m
		repeat = scroll_mode

		var/icon/I = new(i)

		width = I.Width()
		height = I.Height()

		object = new()
		object.animate_movement = 0
		object.layer = 0

		image = new(i, object)
		image.layer = 0

		// depending on the scroll_mode we need to create
		// overlays to cover additional area:
		//
		//                 +---+ +---+---+
		//                 |   | |   |   |
		// +---+ +---+---+ +---+ +---+---+
		// |   | |   |   | |   | |   |   |
		// +---+ +---+---+ +---+ +---+---+
		// none:     X:      Y:    X + Y:
		//
		if(scroll_mode & REPEAT_X)
			var/obj/o = new()
			o.layer = 0
			o.icon = I
			o.pixel_x = width
			image.overlays += o

		if(scroll_mode & REPEAT_Y)
			var/obj/o = new()
			o.layer = 0
			o.icon = I
			o.pixel_y = height
			image.overlays += o

			if(scroll_mode & REPEAT_X)
				var/obj/o2 = new()
				o2.layer = 0
				o2.icon = I
				o2.pixel_x = width
				o2.pixel_y = height
				image.overlays += o2

	Del()
		hide()
		del image
		del object
		..()

	proc
		show()
			if(owner && owner.client)
				owner.client.images += image
				owner.backgrounds += src

		hide()
			if(owner && owner.client)
				owner.client.images -= image
				owner.backgrounds -= src

mob
	var
		list/backgrounds = list()

	proc
		// This creates and returns a new /Background object.
		background(i, scroll_mode = 0)
			if(!client) return

			if(scroll_mode == 0 || scroll_mode == REPEAT_X || scroll_mode == REPEAT_Y || scroll_mode == REPEAT_X | REPEAT_Y)
				return new /Background(src, i, scroll_mode)
			else
				CRASH("[scroll_mode] is an invalid value for scroll_mode. Use zero or the REPEAT_X and REPEAT_Y constants.")

		// This proc exists to be overridden. By default it does
		// nothing but it's called from set_camera to give you a
		// chance to adjust the px/py of backgrounds every time
		// the camera moves.
		set_background()
