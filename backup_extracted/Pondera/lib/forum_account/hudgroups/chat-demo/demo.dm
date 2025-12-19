
Font
	TrebuchetMS
		icon = 'trebuchet-8pt.dmi'

		// see fonts.dm for descriptions of these vars
		char_width = list(" " = 4, "a" = 5, "b" = 5, "c" = 5, "d" = 5, "e" = 5, "f" = 4, "g" = 6, "h" = 5, "i" = 2, "j" = 3, "k" = 5, "l" = 1, "m" = 7, "n" = 5, "o" = 5, "p" = 5, "q" = 5, "r" = 3, "s" = 4, "t" = 4, "u" = 5, "v" = 5, "w" = 7, "x" = 5, "y" = 5, "z" = 5, "A" = 5, "B" = 5, "C" = 6, "D" = 6, "E" = 5, "F" = 5, "G" = 6, "H" = 6, "I" = 1, "J" = 4, "K" = 5, "L" = 4, "M" = 7, "N" = 6, "O" = 7, "P" = 5, "Q" = 8, "R" = 6, "S" = 4, "T" = 5, "U" = 6, "V" = 7, "W" = 9, "X" = 6, "Y" = 7, "Z" = 5, "0" = 5, "1" = 3, "2" = 5, "3" = 5, "4" = 5, "5" = 4, "6" = 5, "7" = 5, "8" = 5, "9" = 5, "," = 2, "." = 1, "'" = 1, "\"" = 3, "?" = 4, "(" = 2, ")" = 2, "<" = 4, ">" = 4, "/" = 4, ";" = 2, ":" = 1, "-" = 3, "+" = 5, "=" = 4, "_" = 6, "!" = 1, "@" = 8, "#" = 6, "$" = 4, "%" = 7, "^" = 5, "&" = 7, "*" = 5)
		descent = 2
		spacing = 1
		line_height = 13

ChatLog
	parent_type = /HudGroup

	icon = 'chat-demo-icons.dmi'
	layer = MOB_LAYER + 5

	New()
		..()

		// create the background for the chat log
		add(-4, -4,
			icon_state = "chat-log",
			width = 6,
			height = 4,
			layer = MOB_LAYER + 4)

	proc
		add_message(txt)

	Maptext
		var
			HudObject/chat_log
			contents = ""

		New(mob/m, not_used)
			..(m)

			chat_log = add(0, 0, maptext_width = 184, maptext_height = 128)

		add_message(txt)
			contents = contents + "\n" + txt
			chat_log.set_maptext("<font color=#000>[contents]")

	Library
		font = new /Font/TrebuchetMS()

		var
			list/lines = list()
			next_line = 1

		New(mob/m, line_count)
			..(m)

			// create a screen object for each line of text
			for(var/i = 1 to line_count)

				// position the objects so that the first one is at the top
				// and the last one is at the bottom
				var/py = (line_count - i) * 16 + 16
				lines += add(0, py)

		add_message(txt)

			// insert line breaks into the string
			txt = font.wrap_text(txt, 184)

			// split the string into a list of strings
			var/list/lines = list()

			var/start = 1
			var/pos = findtext(txt, "\n")

			while(pos > 0)
				lines += copytext(txt, start, pos)
				start = pos + 1
				pos = findtext(txt, "\n", start)

			lines += copytext(txt, start)

			// display each line
			for(var/l in lines)
				add_line(l)

		proc
			// when we add a line of text we have to shift every
			// object up 16 pixels, move the top object to the
			// bottom, and update its text.
			add_line(txt)

				// trim the text so it fits inside the chat log
				txt = font.cut_word(txt, 184)

				// I'm not sure why this is necessary, but it is. without it,
				// when you use the Say verb you'll see the top line of the
				// chat log change its text, then get moved to the bottom.
				spawn()
					// we loop through all lines because we need to reposition them all
					for(var/i = 1 to lines.len)
						var/HudObject/h = lines[i]

						// move the screen object up 16 pixels
						var/py = h.sy - 16

						// if it's sbove the top, wrap it around to the bottom
						if(py < 0)
							py = lines.len * 16 - 16

						// update its position
						h.pos(0, py)

						// if its the next line, update its text too
						if(i == next_line)
							h.set_text(txt)

					// keep track of which line will be used next
					next_line -= 1
					if(next_line < 1)
						next_line = lines.len

mob
	var
		// every mob can have their own chat log

		// Uncomment one of these lines. You can switch
		// which one is used to switch between using maptext
		// and using the library's text feature.
		ChatLog/Maptext/chat_log
		// ChatLog/Library/chat_log

	Login()

		loc = locate(21, 15, 1)

		// create a chat log for this player that holds
		// eight lines of text.
		chat_log = new(src, 8)
		chat_log.pos(8, 8)

		// automatically output some messages to the chat log
		// to show that it works.
		spawn(4)
			chat_log.add_message("Testing:")

		for(var/i = 1 to 10)
			spawn(4 + i * 4) chat_log.add_message("count = [i]")

	verb
		Say(t as text)
			chat_log.add_message("[src]: [t]")

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
