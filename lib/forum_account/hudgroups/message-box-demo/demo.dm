
Font
	TrebuchetMS
		icon = 'trebuchet-8pt.dmi'

		// see fonts.dm for descriptions of these vars
		char_width = list(" " = 4, "a" = 5, "b" = 5, "c" = 5, "d" = 5, "e" = 5, "f" = 4, "g" = 6, "h" = 5, "i" = 2, "j" = 3, "k" = 5, "l" = 1, "m" = 7, "n" = 5, "o" = 5, "p" = 5, "q" = 5, "r" = 3, "s" = 4, "t" = 4, "u" = 5, "v" = 5, "w" = 7, "x" = 5, "y" = 5, "z" = 5, "A" = 5, "B" = 5, "C" = 6, "D" = 6, "E" = 5, "F" = 5, "G" = 6, "H" = 6, "I" = 1, "J" = 4, "K" = 5, "L" = 4, "M" = 7, "N" = 6, "O" = 7, "P" = 5, "Q" = 8, "R" = 6, "S" = 4, "T" = 5, "U" = 6, "V" = 7, "W" = 9, "X" = 6, "Y" = 7, "Z" = 5, "0" = 5, "1" = 3, "2" = 5, "3" = 5, "4" = 5, "5" = 4, "6" = 5, "7" = 5, "8" = 5, "9" = 5, "," = 2, "." = 1, "'" = 1, "\"" = 3, "?" = 4, "(" = 2, ")" = 2, "<" = 4, ">" = 4, "/" = 4, ";" = 2, ":" = 1, "-" = 3, "+" = 5, "=" = 4, "_" = 6, "!" = 1, "@" = 8, "#" = 6, "$" = 4, "%" = 7, "^" = 5, "&" = 7, "*" = 5)
		descent = 2
		spacing = 1
		line_height = 13


MessageBox
	parent_type = /HudGroup

	icon = 'message-box-demo.dmi'
	layer = MOB_LAYER + 5
	font = new /Font/TrebuchetMS()

	var
		HudObject/text_object
		HudObject/ok_button

	New()
		..()

		for(var/x = 0 to 5)
			for(var/y = 0 to 3)
				add(x * 32, y * 32, "[x],[y]")

		// we use the "layer" parameter to make the button
		// and text objects appear at a higher layer than
		// the message box background objects.
		ok_button = add(82, 20, "ok-button", layer = layer + 1)
		text_object = add(32, 100, layer = layer + 1)

	Click(HudObject/object)
		if(object == ok_button)
			hide()

	proc
		show_message(msg)

			// wrap the text so it fits within 128 pixel wide lines
			msg = font.wrap_text(msg, 128)
			text_object.set_text(msg)

			show()

mob
	var
		// each player has a message box
		MessageBox/message_box

	Login()
		..()

		src << "Bump into a dense turf to make a message box appear. Click the message box's OK button to close it."

		// create a message box for this mob
		message_box = new(src)

		// position the message box so it'll be centered
		// at the top of the screen
		message_box.pos(80, 208)

		// we want it to be hidden initially
		message_box.hide()

	Bump(atom/a)
		// show a message
		message_box.show_message("[src] bumped into [a].")

// the rest of this code is needed for the demo but doesn't
// relate to how you'd use the HUD library.
atom
	icon = 'hud-demo-icons.dmi'

turf
	icon_state = "grass"

	water
		density = 1
		icon_state = "water"

	trees
		density = 1
		icon_state = "trees"

	rock
		density = 1
		icon_state = "rock"

mob
	icon_state = "mob"
