
// File:    control-schemes\zelda\demo.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   An example of an alternate control scheme where the player
//   can move in 4 directions (no diagonals). The mob's position
//   is shifted to help the player line up with the grid, this way
//   a 32x32 mob can easily line up to fit through a 32 pixel wide
//   opening. This is how movement in the original Zelda works (and
//   in BYOND's Casual Quest).

proc
	// returns the direction represented by the key
	// name (ex: "north", "space", etc.). If the key
	// isn't an arrow key, return 0.
	key2dir(k)
		if(k == K_UP) return NORTH
		else if(k == K_DOWN) return SOUTH
		else if(k == K_RIGHT) return EAST
		else if(k == K_LEFT) return WEST
		return 0

world
	view = 6
	tick_lag = 0.33

PixelMovement
	debug = 1

atom
	icon = 'zelda-icons.dmi'

mob
	icon_state = "link-standing"

	var
		list/move_dir = list()

	key_down(k)
		// when you press an arrow key, add that direction
		// to the end of the move_dir list.
		var/d = key2dir(k)
		if(d)
			move_dir += d
		..()

	key_up(k)
		// when you release an arrow key, remove that
		// direction from the move_dir list.
		var/d = key2dir(k)
		if(d)
			move_dir -= d
		..()

	movement()

		if(!move_dir.len)
			icon_state = "link-standing"
			return

		// the direction you're moving in is the last dir
		// in the list because that's the one that was most
		// recently added (most recently pressed).
		var/d = move_dir[move_dir.len]

		icon_state = "link-moving"
		dir = d

		var/dx = 0
		var/dy = 0

		// move 4 pixels per step
		if(d == NORTH)
			dy = 4
		else if(d == SOUTH)
			dy = -4
		else if(d == EAST)
			dx = 4
		else if(d == WEST)
			dx = -4

		// If you just want 4-directional movement (no diagonal
		// movement) you can skip this next part. The rest of the
		// proc makes the mob adjust to line up with gridlines.
		// This isn't essential to 4-directional movement but it
		// makes it easier for the player to line themselves up
		// with one-tile wide spaces. For example:
		//
		//       #
		//             x
		//   O   #
		//       #
		//
		// For the mob (the "O") to get to the x they'll have to
		// move up exactly 32 pixels to get through the opening.
		// With pixel movement it can be hard to get lined up just
		// right, so games will adjust the player's position to
		// line them up with the opening (the original Zelda does
		// this, so does BYOND's Casual Quest).

		// if you aren't moving horizontally...
		if(!dx)
			// figure out if the mob needs to be moved horizontally
			// to line up with a tile or half tile
			var/ox = px % 16
			if(ox >= 8)
				dx = 4
			else if(ox > 0)
				dx = -4

		// same thing for the other direction...
		if(!dy)
			var/oy = py % 16
			if(oy > 8)
				dy = 4
			else if(oy > 0)
				dy = -4

		// move by the specified amount.
		pixel_move(dx,dy)

turf
	grass
		icon_state = "grass"

	stone
		density = 1
		icon_state = "stone"

	tree
		density = 1
		icon_state = "tree"