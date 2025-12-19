
Font
	TrebuchetMS
		icon = 'trebuchet-8pt.dmi'

		// see fonts.dm for descriptions of these vars
		char_width = list(" " = 4, "a" = 5, "b" = 5, "c" = 5, "d" = 5, "e" = 5, "f" = 4, "g" = 6, "h" = 5, "i" = 2, "j" = 3, "k" = 5, "l" = 1, "m" = 7, "n" = 5, "o" = 5, "p" = 5, "q" = 5, "r" = 3, "s" = 4, "t" = 4, "u" = 5, "v" = 5, "w" = 7, "x" = 5, "y" = 5, "z" = 5, "A" = 5, "B" = 5, "C" = 6, "D" = 6, "E" = 5, "F" = 5, "G" = 6, "H" = 6, "I" = 1, "J" = 4, "K" = 5, "L" = 4, "M" = 7, "N" = 6, "O" = 7, "P" = 5, "Q" = 8, "R" = 6, "S" = 4, "T" = 5, "U" = 6, "V" = 7, "W" = 9, "X" = 6, "Y" = 7, "Z" = 5, "0" = 5, "1" = 3, "2" = 5, "3" = 5, "4" = 5, "5" = 4, "6" = 5, "7" = 5, "8" = 5, "9" = 5, "," = 2, "." = 1, "'" = 1, "\"" = 3, "?" = 4, "(" = 2, ")" = 2, "<" = 4, ">" = 4, "/" = 4, ";" = 2, ":" = 1, "-" = 3, "+" = 5, "=" = 4, "_" = 6, "!" = 1, "@" = 8, "#" = 6, "$" = 4, "%" = 7, "^" = 5, "&" = 7, "*" = 5)
		descent = 2
		spacing = 1
		line_height = 13

mob
	var
		HudObject/text_object
		HudObject/maptext_object

	Login()
		loc = locate(21, 15, 1)

		var/HudGroup/h = new(src)
		h.layer = MOB_LAYER + 5
		h.font = new /Font/TrebuchetMS()

		// format the message so it is wrapped to fit
		// inside a width of 64 pixels.
		var/message = h.font.wrap_text("This is a test to see if on-screen text works.", 64)

		// we use the add() proc's named parameter called text
		// to create an object that has some text attached to it.
		text_object = h.add(0, 64, text = message)

		// we can also create on-screen text using maptext.
		message = "This is a test to see if on-screen maptext works."
		maptext_object = h.add(256, 32, maptext = message, maptext_width = 64, maptext_height = 96)

	verb
		Change_Text()
			text_object.set_text("The text changed.")
			maptext_object.set_maptext("The maptext changed.")

		Move_Text()
			var/px = rand(0, 200)
			var/py = rand(0, 200)

			text_object.pos(px, py)

			px = rand(0, 200)
			py = rand(0, 200)

			maptext_object.pos(px, py)

// the rest of this code is needed for the demo but doesn't
// relate to how you'd use the HUD library.
atom
	icon = 'hud-demo-icons.dmi'

turf
	icon_state = "grass"

	water
		density = 1
		icon_state = "water"

mob
	icon_state = "mob"
