#define DEBUG

mob
	icon_state = "mob"

	var
		Overlay/hat
		Overlay/coat

	Login()
		..()

		// In BYOND, overlays can be difficult to use. Once you've added
		// an overlay to an object it can be difficult to modify. The
		// /Overlay object simplifies how overlays work. The constructor
		// looks like this:
		//
		//     new /Overlay(src, 'icons.dmi', "blue coat")
		//
		// The first parameter is the object that is getting the overlay.
		// The next parameter is the icon and the last is the icon state.
		//
		// You can keep a reference to the /Overlay object so you can
		// modify it later. This file contains a few examples.

		// The coat overlay will automatically match your direction
		coat = new /Overlay(src, 'icons.dmi', "blue coat")
		coat.Layer(MOB_LAYER + 1)

		// The hat overlay will also match your icon_state
		hat = new /Overlay(src, 'hat.dmi')
		hat.Layer(MOB_LAYER + 2)

		// call client.add_macro to create a new macro. The first parameter
		// is the key, the second is the modifiers (ALT, CTRL, SHIFT,
		// RELEASE, and REPEAT)
		client.add_macro("a")
		client.add_macro("a", RELEASE)

		client.add_macro("b", CTRL + ALT)

		/*
		// This creates an animated icon
		var/icon/spin = new()
		for(var/k = 1 to 6)
			spin.Insert(Icon.Rotate('icons.dmi',"box",k * 15), frame = k)
			sleep(1)
		icon = spin
		*/

	macro(k, mod)
		if(mod == 0)
			world << "You pressed [k]."
		if(mod & RELEASE)
			world << "You released [k]."

		if(mod == CTRL + ALT)
			world << "You pressed Ctrl + Alt + [k]."

	verb
		Change_Coat()
			if(coat.IconState() == "blue coat")
				coat.IconState("red coat")
			else
				coat.IconState("blue coat")

		Toggle_Height()
			if(icon_state == "mob")
				icon_state = "short"
			else
				icon_state = "mob"

		Knock_Hat_Off()
			hat.Flick("fall", 9)

		Tilted_Hat()
			// This rotates all icon states in the hat.dmi file. If you use the
			// Toggle_Height verb with a tilted hat the icon state of the overlay
			// will still match and you'll have a tilted hat for a shorter mob.
			hat.Icon(Icon.Rotate('hat.dmi',10))

		Transparent_Hat()
			hat.Icon(Icon.Fade('hat.dmi',0.5))

		Normal_Hat()
			hat.Icon('hat.dmi')


		Text_Test()
			// The second argument to the Text.int proc is the
			// base, which can be between 2 and 16.
			world << Text.int("-35") + 1 // -34
			world << Text.int("35", 16) + 1 // 54
			world << Text.int("100011", 2) // 35

			var/list/words = list("the","quick","brown","fox","jumped","over","the","lazy","dog")

			var/sentence = Text.join(words, " ")

			world << sentence

			world << Text.replace(sentence, "the", "THE")


// The library defines the MouseEvent object. Normally, the third
// parameter in a mouse proc is a text string that lists parameters.
// To use these parameters you need to parse the string. The MouseEvent
// object takes care of that so you can reference the parameters as
// properties of the event object.
//
// These click procs are equivalent
/*
turf
	Click(location,control,params)
    	var/MouseEvent/e = new /MouseEvent(location,control,params)
    	new /obj/marker(e.location, e.icon_x, e.icon_y)
*/
// By declaring MouseEvent/e as the parameter the code looks a little
// cleaner, we just need to call ..() to generate the MouseEvent object.
turf
	Click(MouseEvent/e)
		e = ..()
		new /obj/marker(e.location, e.icon_x, e.icon_y)

obj
	marker
		icon_state = "x"

		New(loc, ix, iy)
			..()
			pixel_x = ix - 16
			pixel_y = iy - 16


atom
	icon = 'icons.dmi'

turf
	icon_state = "grass"

	New()
		..()
		dir = pick(NORTH,SOUTH,EAST,WEST)

	pavement
		icon_state = "pavement"

	sidewalk
		icon_state = "sidewalk"

	brick
		density = 1
		icon_state = "brick"
