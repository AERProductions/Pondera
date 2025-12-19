
world
	view = 5

Font
	TrebuchetMS
		icon = 'trebuchet-8pt.dmi'

		// see fonts.dm for descriptions of these vars
		char_width = list(" " = 4, "a" = 5, "b" = 5, "c" = 5, "d" = 5, "e" = 5, "f" = 4, "g" = 6, "h" = 5, "i" = 2, "j" = 3, "k" = 5, "l" = 1, "m" = 7, "n" = 5, "o" = 5, "p" = 5, "q" = 5, "r" = 3, "s" = 4, "t" = 4, "u" = 5, "v" = 5, "w" = 7, "x" = 5, "y" = 5, "z" = 5, "A" = 5, "B" = 5, "C" = 6, "D" = 6, "E" = 5, "F" = 5, "G" = 6, "H" = 6, "I" = 1, "J" = 4, "K" = 5, "L" = 4, "M" = 7, "N" = 6, "O" = 7, "P" = 5, "Q" = 8, "R" = 6, "S" = 4, "T" = 5, "U" = 6, "V" = 7, "W" = 9, "X" = 6, "Y" = 7, "Z" = 5, "0" = 5, "1" = 3, "2" = 5, "3" = 5, "4" = 5, "5" = 4, "6" = 5, "7" = 5, "8" = 5, "9" = 5, "," = 2, "." = 1, "'" = 1, "\"" = 3, "?" = 4, "(" = 2, ")" = 2, "<" = 4, ">" = 4, "/" = 4, ";" = 2, ":" = 1, "-" = 3, "+" = 5, "=" = 4, "_" = 6, "!" = 1, "@" = 8, "#" = 6, "$" = 4, "%" = 7, "^" = 5, "&" = 7, "*" = 5)
		descent = 2
		spacing = 1
		line_height = 13

// The Ally Locator is an on-screen indication of where a party member
// is located. It creates a box with their name and icon and positions
// the box at the edge of your screen so it points towards your ally.
AllyLocator
	parent_type = /HudGroup

	icon = 'party-demo.dmi'
	layer = MOB_LAYER + 5
	font = new /Font/TrebuchetMS()

	var
		mob/player
		mob/ally

	New(mob/p, mob/a)
		..(p)

		player = p
		ally = a

		a.ally_locator = src

		// create the locator's background object
		add(0, 0, "background")

		// create an object representing the mob
		add(0, 0, ally.icon_state)

		// This uses the library's text capabilities:
		//   put the ally's name on the locator. we use the
		//   font's cut_word() proc to make sure the name will
		//   fit in a 24 pixel wide space - if the mob has a
		//   long name it'll return the first few letters so
		//   the caption doesn't run outside of the box.
		// var/ally_name = font.cut_word(ally.name, 24)
		// add(4, 4, text = ally_name)

		// This uses BYOND's built-in maptext:
		var/ally_name = "<font color='#000'>[ally.name]</font>"
		add(4, 2, maptext = ally_name)

		update()

	proc
		update()
			// if your ally is nearby, don't show the locator
			if(get_dist(player, ally) <= 5 || ally.z != player.z)
				hide()
				return

			show()

			// the rest of this proc positions the ally locator
			// so it's at the edge of your screen and points in
			// the direction of your ally.

			// compute a vector to the ally
			var/dx = ally.x - player.x
			var/dy = ally.y - player.y

			// normalize it
			var/l = sqrt(dx * dx + dy * dy)
			dx /= l
			dy /= l

			// figure out how to scale the vector so it touches the
			// edge of your screen
			var/scale = 0

			// if the ally is further away horizontally than vertically,
			// we scale based on dx because it'll hit the left or right
			// edge of the screen first
			if(abs(dx) > abs(dy))
				scale = abs(156 / dx)

			// otherwise it'll hit the top or bottom of the screen first
			// so we scale based on dy.
			else
				scale = abs(156 / dy)

			// add (160, 160) to the vector because that's the center of
			// the screen
			dx = round(160 + scale * dx)
			dy = round(160 + scale * dy)

			// position the ally locator
			pos(dx, dy)

mob
	var
		AllyLocator/ally_locator

	Move()
		. = ..()

		// when a mob moves, force the ally locator to update
		if(.)
			if(ally_locator)
				ally_locator.update()

	Login()
		loc = locate(1, 1, 1)

		var/mob/ally/a = new()
		ally_locator = new(src, a)

mob
	ally
		name = "Mob"

		New()
			loc = locate(21, 16, 1)
			walk_rand(src, 10)

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
