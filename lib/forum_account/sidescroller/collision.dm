
// File:    collision.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This file contains the collision detection and
//   resolution code used by the pixel_move proc.

mob
	var
		// collisions used to be handled entirely in the pixel_move
		// proc, which just used the local variables dpx and dpy to
		// keep track of the move you're trying to perform. because
		// the collision handling is now split across multiple procs,
		// the move_x and move_y vars are used like dpx and dpy to
		// keep track of the move, but across multiple procs instead
		// of just within pixel_move().
		move_x
		move_y

	proc
		check_collision(atom/a)

			if(a.pleft != a.pright)
				ramp_collision(a)
			else
				block_collision(a)

		block_collision(atom/a)

			// this should be unncessary now
			// if(!a.inside4(px + move_x, py + move_y, pwidth, pheight)) continue

			// ix and iy measure how far you are inside the turf in each direction.
			var/ix = 0
			var/iy = 0

			// If you draw pictures showing a mob hitting a dense turf from the left
			// side and label px, move_x, pwidth, and a.px it's easy to see how you
			// compute ix. The same can be done for hitting a dense turf from the right.
			if(move_x > 0)
				ix = px + move_x + pwidth - a.px
			else if(move_x < 0)
				ix = (px + move_x) - (a.px + a.pwidth)

			// Same as the ix calculations except we swap y for x and height for width.
			if(move_y > 0)
				iy = py + move_y + pheight - a.py
			else if(move_y < 0)
				iy = (py + move_y) - (a.py + a.pheight)

			// tx and ty measure the fraction of the move (the move_x,move_y move) that it takes
			// for you to hit the turf in each direction.
			var/tx = (abs(move_x) < 0.00001) ? 1000 : ix / move_x
			var/ty = (abs(move_y) < 0.00001) ? 1000 : iy / move_y

			// We use tx and ty to determine if you first hit the object in the x direction
			// or y direction. We modify move_x and move_y based on how you bumped the turf.

			// if the vertical bump occurred first
			if(ty <= tx)

				// if you're below the object
				if(py + pheight / 2 < a.py + a.pheight / 2)

					// set move_y to the amount that you overlap
					move_y = a.py - (py + pheight)

				else
					move_y = a.py + a.pheight - py

			// otherwise the horizontal bump occurred first
			else
				// if you're to the left of the object
				if(px + pwidth / 2 < a.px + a.pwidth / 2)

					// set move_x to the amount that you overlap
					move_x = a.px - (px + pwidth)

				else
					move_x = a.px + a.pwidth - px

		ramp_collision(atom/a)

			// this should be unncessary now
			// if(!a.inside4(px + move_x, py + move_y, pwidth, pheight)) continue

			// check for bumping the sides
			if(px + pwidth <= a.px)
				if(py < a.py + a.pleft)
					move_x = a.px - (px + pwidth)
					return

			if(px >= a.px + a.pwidth)
				if(py < a.py + a.pright)
					move_x = a.px + a.pwidth - px
					return

			// check for bumping the top and bottom
			var/h = a.height(px + move_x, py + move_y, pwidth, pheight)

			if(py + move_y < h)
				if(py + pheight < a.py)
					vel_y = 0
					move_y = a.py - (py + pheight)
				else
					move_y = h - py
