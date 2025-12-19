
// File:    pixel-movement.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This file contains the code to handle the actual
//   pixel movement (the pixel_move proc). It also has
//   some related functions.

turf
	var
		ladder = 0

atom
	// we need these vars for turfs and mobs at least. We probably don't
	// need them for areas, but it's easy to define them for all atoms.
	var
		// px/py is your position on the map in pixels
		px = -1
		py = -1

		// the fractional parts of your movements
		_px = 0
		_py = 0

		// pwidth/pheight determine the dimensions of your bounding box
		pwidth = -1
		pheight = -1

		// used for sloped objects, pleft is the height of the object's
		// left side and pright is the height of its right side.
		pleft = 0
		pright = 0

		// ceiling_ramp = 0

		// offset_x/y are used to offset the object's icon to make the
		// image appear within the bounding box.
		// use pixel_x and pixel_y instead now.
		// offset_x = 0
		// offset_y = 0

		// This replaces the "platform" var for turfs. Set scaffold = 1
		// to create objects that you can walk in front of and stand on
		// top of.
		scaffold = 0

		// This is used to define properties of the object that get
		// stored in the mob's on_ground, on_left, on_right, and
		// on_ceiling vars.
		flags = 0

		// These are flags for individual sides of the atom.
		flags_right = 0
		flags_left = 0
		flags_bottom = 0
		flags_top = 0

	New()
		..()

		if(icon_width == -1)
			world.set_icon_size()

		if(pwidth == -1)
			pwidth = icon_width

		if(pheight == -1)
			pheight = icon_height

		if(pleft == 0 && pright == 0)
			pleft = pheight
			pright = pheight
		else
			pheight = max(pleft, pright)

		if(x && y)
			if(istype(src, /atom/movable))
				var/atom/movable/m = src
				px = icon_width * x + m.step_x
				py = icon_height * y + m.step_y
			else
				px = icon_width * x
				py = icon_height * y

	proc
		// Calculates the height of a sloped tile for a given bounding
		// box. The height is the largest py value that the slope has
		// underneath the specified bounding box. You can also think of
		// the height as being the y-value of the point where contact
		// would first be made if you moved the bounding box straight down.
		height(qx,qy,qw,qh)
			if(pright > pleft)
				. = min(icon_height, qx + qw - px)
				. = py + pleft + (.) * (pright - pleft) / pwidth
				. = min(., py + pright)
			else
				. = max(0, qx - px)
				if(. > px + pwidth) return -100
				. = py + pleft + (.) * (pright - pleft) / pwidth
				. = min(., py + pleft)

			. = round(.)

		#ifdef STEPPED_ON
		stepped_on(mob/m)
		stepping_on(mob/m, time)
		stepped_off(mob/m)
		#endif

atom/movable
	step_size = 1
	New()
		..()
		bound_width = pwidth
		bound_height = pheight

mob
	animate_movement = 0

	// movable atoms can have velocities
	var
		vel_x = 0
		vel_y = 0

		#ifdef STEPPED_ON
		list/bottom = list()
		was_on_ground = 0
		#endif

	proc
		// by default you can only bump into dense turfs and platforms
		can_bump(atom/a)

			// we need to handle the scaffold differently whether it's a ramp or not.
			if(a.scaffold)
				if(dropped) return 0

				// If it's not a ramp...
				if(a.pleft == a.pright)
					if(py >= a.py + a.pheight)
						return 1

				// if it is a ramp...
				else
					if(py >= a.height(px, py, pwidth, pheight))
						return 1

			// you can always bump into dense turfs, even if you're not dense
			else if(isturf(a))
				return a.density

			// you can only bump into dense mobs/objs if you're dense too
			else
				return a.density && density

			return 0

		// The pixel_move proc moves a mob by (dpx, dpy) pixels. If this move is invalid (because a
		// dense atom is in your way) the move may be adjusted so that you don't end up inside that atom.
		pixel_move(dpx, dpy)

			bound_width = pwidth
			bound_height = pheight

			// find the integer part of your move
			var/ipx = round(abs(dpx)) * ((dpx < 0) ? -1 : 1)
			var/ipy = round(abs(dpy)) * ((dpy < 0) ? -1 : 1)

			// accumulate the fractional parts of the move
			_px += (dpx - ipx)
			_py += (dpy - ipy)

			// ignore the fractional parts
			dpx = ipx
			dpy = ipy

			// increment the move if the fractions have added up
			while(_px > 0.5)
				_px -= 1
				dpx += 1
			while(_px < -0.5)
				_px += 1
				dpx -= 1

			while(_py > 0.5)
				_py -= 1
				dpy += 1
			while(_py < -0.5)
				_py += 1
				dpy -= 1

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: start pixel_move: dpx = [dpx], dpy = [dpy]")
			#endif

			// We'll use this var later to check if we should "stick" to a ramp below us.
			// The reason we declare the variable here is because the value of dpy might
			// change in this proc but we want to use its initial value.
			var/stick_to_ramp = on_ground && (dpy <= 0)

			move_x = dpx
			move_y = dpy

			var/bumped = 0

			// if you're touching a wall and are trying to move in that
			// direction, we set the bump flag but pre-emptively update
			// the move_x or move_y var so you don't attempt the move.
			//
			// this is done to avoid some glitches, for example:
			//
			//       +---+
			//       |mob|
			//   +---+---+---+---+
			//   |###|###|###|###|
			//   +---+---+---+---+
			//             ^
			//             |
			//
			// if the mob tries to move over 4 pixels and down 4 pixels,
			// they'll end up bumping the left side of the indicated turf
			// which will set move_x = 0, then they'll bump the top of a
			// turf and set their move_y = 0 - the end result is no movement.
			//
			// these changes avoid this behavior by pre-emptively setting
			// move_y = 0 in the situation shown above. the bump flag is
			// set so the bump() proc is still called.
			if(on_left && move_x < 0)
				move_x = 0
				dpx = 0
				bumped |= LEFT
			else if(on_right && move_x > 0)
				move_x = 0
				dpx = 0
				bumped |= RIGHT

			if(on_ground && move_y < 0)
				move_y = 0
				dpy = 0
				bumped |= DOWN
			else if(on_ceiling && move_y > 0)
				move_y = 0
				dpy = 0
				bumped |= UP

			for(var/atom/a in obounds(src, move_x, move_y, abs(move_x), abs(move_y)))

				// if we're not trying to move anymore, we can stop checking for collisions.
				if(move_x == 0 && move_y == 0) break

				// We use the src object's can_bump proc to determine what it can
				// collide with. We might have more complex rules than just "dense
				// objects collide with dense objects". For example, you might want
				// bullets and other projectiles to pass through walls that players
				// cannot.
				if(!can_bump(a)) continue

				// if we can bump it, check for collisions (see collision.dm)
				check_collision(a)

			// stick_to_ramp will be true if you were on the ground before performing this
			// move and if you're not moving upwards (if you're moving upwards you shouldn't
			// stick to the ground).
			if(stick_to_ramp && move_y <= 0)
				// check all turfs within 8 pixels of your bottom (hehe)...
				for(var/turf/t in bottom(8))
					// only check turfs that you can bump and are ramps
					if(!can_bump(t)) continue
					if(t.pleft == t.pright) continue

					// t.height gives you the height of the top of the turf based on your mob.
					// You can think of it as, "if your mob fell straight down, at what height
					// would you hit the ramp". That's the heigh that t.height returns.
					var/h = t.height(px + move_x,py + move_y, pwidth, pheight)

					// by setting dpy to h - py, we're making you move down just enough that
					// you'll end up on the ramp.
					move_y = h - py

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: end pixel_move: dpx = [dpx], dpy = [dpy], move = [move_x], [move_y]")
			#endif

			// at this point we've clipped your move against all nearby tiles, so the move
			// is a valid one at this point (both might be zero) so we can perform it.
			set_pos(px + move_x, py + move_y)

			// if the resulting move was shorter than the attempted move, a bump occurred
			if(dpx > 0 && move_x < dpx)
				bumped |= RIGHT
			else if(dpx < 0 && move_x > dpx)
				bumped |= LEFT

			if(dpy > 0 && move_y < dpy)
				bumped |= UP
			else if(dpy < 0 && move_y > dpy)
				bumped |= DOWN

			// if any bump flags were set, call the bump proc for all atoms you're touching
			// in the flagged directions
			if(bumped & RIGHT)
				for(var/atom/a in right(1))
					if(can_bump(a))
						bump(a, RIGHT)
			else if(bumped & LEFT)
				for(var/atom/a in left(1))
					if(can_bump(a))
						bump(a, LEFT)

			if(bumped & UP)
				for(var/atom/a in top(1))
					if(can_bump(a))
						bump(a, UP)
			else if(bumped & DOWN)
				for(var/atom/a in bottom(1))
					if(can_bump(a))
						bump(a, DOWN)

			return bumped ? 0 : 1

		// set_pos now takes your new px and py values as parameters.
		set_pos(nx, ny, map_z = -1)

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: start set_pos: nx = [nx], ny = [ny], map_z = [map_z]")
			#endif

			// if the first argument is an atom, set the position
			// of src to be centered on the atom.
			if(istype(nx, /atom))
				var/atom/a = nx

				if(istype(a, /turf))
					loc = a
				else
					loc = a.loc

				return set_pos(a.px + (a.pwidth - pwidth) / 2, a.py + (a.pheight - pheight) / 2, a.z)

			if(map_z == -1) map_z = z

			var/moved = (nx != px || ny != py || map_z != z)

			px = round(nx)
			py = round(ny)

			var/tx = round((px + pwidth / 2) / icon_width)
			var/ty = round((py + pheight / 2) / icon_height)

			if(moved)
				var/turf/old_loc = loc
				var/turf/new_loc = locate(tx, ty, map_z)

				if(new_loc != old_loc)
					var/area/old_area = old_loc:loc
					Move(new_loc, dir)
					if(new_loc)
						new_loc.Entered(src)

					// In case Move failed we need to update your loc anyway.
					// If you want to prevent movement, don't do it through Move()
					loc = new_loc

					if(new_loc)
						var/area/new_area = new_loc.loc

						if(old_area != new_area)
							if(old_area) old_area.Exited(src)
							if(new_area) new_area.Entered(src)

					if(!loc)
						if(SIDESCROLLER_DEBUG)
							CRASH("The atom [src] is not on the map. Objects may \"fall off\" the map if the perimeter of the map does not contain dense turfs.")

				step_x = px - x * icon_width
				step_y = py - y * icon_height

			if(client)
				set_camera()
				client.pixel_x = camera.px - px
				client.pixel_y = camera.py - py

			// -- position the /Background objects --
			// set_background is a proc the developer can override to
			// define custom background logic.
			set_background()

			// position all the backgrounds accordingly.
			for(var/Background/bg in backgrounds)

				if(!(bg.image in client.images))
					client.images += bg.image

				bg.object.loc = loc

				// I should also make this take camera position into account
				var/bx = step_x + client.pixel_x + bg.px
				var/by = step_y + client.pixel_y + bg.py

				if(bg.repeat & REPEAT_X)
					while(bx < -bg.width * 1.5)
						bx += bg.width
					while(bx > bg.width * -0.5)
						bx -= bg.width
				else
					..()

				if(bg.repeat & REPEAT_Y)
					while(by < -bg.height * 1.5)
						by += bg.height
					while(by > bg.height * -0.5)
						by -= bg.height
				else
					..()

				bg.object.pixel_x = bx + 16
				bg.object.pixel_y = by + 16
			// -- Done with /Background objects --

			#ifdef STEPPED_ON
			if(moved || on_ground || was_on_ground)

				var/list/_bottom = list()
				for(var/atom/a in obounds(src, 0, -1, 0, -pheight + 1))
					if(!can_bump(a)) continue

					if(a.pleft != a.pright)
						if(py != a.height(px,py,pwidth,pheight))
							continue
					else
						if(py != a.py + a.pheight)
							continue

					_bottom += a

				for(var/atom/a in _bottom)
					if(a in bottom)
						bottom[a] += 1
						a.stepping_on(src, bottom[a])
					else
						bottom[a] = 1
						a.stepped_on(src)

				for(var/atom/a in bottom)
					if(!(a in _bottom))
						bottom -= a
						a.stepped_off(src)
			was_on_ground = on_ground
			#endif

			last_x = x
			last_y = y
			last_z = z

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: end set_pos: nx = [nx], ny = [ny], map_z = [map_z]")
			#endif
