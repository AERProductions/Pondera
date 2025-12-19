
// File:    movement.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This file contains the mob's default behavior for our
//   sidescrolling pixel movement system. The pixel movement
//   itself (how collisions are detected and handled) is
//   handled in pixel-movement.dm. This file handles the
//   default behavior for a mob's movement (how they
//   accelerate, how keyboard input is handled, etc.)

var
	const
		// used to set icon states
		STANDING = "standing"
		MOVING = "moving"
		CLIMBING = "climbing"
		JUMPING = "jumping"

		RIGHT = EAST
		LEFT = WEST

mob
	icon_state = "mob"

	var
		on_left = 0
		on_right = 0
		on_ceiling = 0
		on_ground = 0
		on_ladder = 0

		base_state = ""

		// acceleration and deceleration rates
		accel = 1
		decel = 1
		gravity = 1

		move_speed = 5
		climb_speed = 5
		jump_speed = 10
		fall_speed = 20

		moved = 0

		last_x = -1
		last_y = -1
		last_z = -1

	proc
		// a is the atom you're bumping and d is the direction you were
		// moving (UP, DOWN, LEFT, or RIGHT). The default behavior is
		// to set your directional velocity to zero when you bump something.
		bump(atom/a, d)

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: bump: a = [a] (\ref[a]), d = [d]")
			#endif

			if(d == LEFT || d == RIGHT)
				vel_x = 0

				// if the mob is following a path and they bump something,
				// jumping will make them try to jump over it.
				if(destination || path)
					if(can_jump())
						jump()
			else
				vel_y = 0

		// Your icon_state depends on your current situation, like this:
		// if you're on a ladder you're climbing
		// if you're not on the ground (and not on a ladder) you're jumping
		// if you're not moving (and are on the ground and not on a ladder) you're standing
		// otherwise you're moving (walking)
		set_state()
			var/base = base_state ? "[base_state]-" : ""

			if(on_ladder)
				icon_state = base + CLIMBING
			else if(!on_ground)
				icon_state = base + JUMPING
			else if(moved)
				icon_state = base + MOVING
			else
				icon_state = base + STANDING

		can_jump()
			if(on_ladder)
				return 0

			// If the mob is following a path, we limit how frequently
			// they can jump (from the same tile). The reason we do this
			// is because if they get stuck (the pathing isn't perfect!)
			// they might jump repeatedly. With no delay it looks silly.
			if(path || destination)
				if(__last_jump_loc == loc)
					if(__jump_delay > 0)
						__jump_delay -= 1
						return 0

			return on_ground

		jump()
			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: jump:")
			#endif

			vel_y = jump_speed

		drop()
			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: drop:")
			#endif

			dropped = 1

		// this is called when the player is moving and is not on a ladder
		move(d)
			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: move: d = [d]")
			#endif

			moved = d

			// we want to keep the mob's velocity between -5 and 5.
			if(d == RIGHT)
				if(vel_x < move_speed)
					vel_x += accel
					if(vel_x > move_speed)
						vel_x = move_speed
			else if(d == LEFT)
				if(vel_x > -move_speed)
					vel_x -= accel
					if(vel_x < -move_speed)
						vel_x = -move_speed

		// this is called when the mob is moving while hanging on a ladder
		// so we need to consider all four directions.
		climb(d)
			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: climb: d = [d]")
			#endif

			if(d == RIGHT)
				vel_x += accel
				if(vel_x > climb_speed)
					vel_x = climb_speed
			else if(d == LEFT)
				vel_x -= accel
				if(vel_x < -climb_speed)
					vel_x = -climb_speed

			else if(d == UP)
				vel_y += accel
				if(vel_y > climb_speed)
					vel_y = climb_speed
			else if(d == DOWN)
				vel_y -= accel
				if(vel_y < -climb_speed)
					vel_y = -climb_speed

		gravity()
			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: gravity:")
			#endif

			if(on_ladder || on_ground) return

			vel_y -= gravity
			if(vel_y < -fall_speed)
				vel_y = -fall_speed

		on_ladder()
			var/turf/t = center()
			return t.ladder

		// The action proc is called by the mob's default movement proc. It doesn't do
		// anything new, it just splits up the code that was in the movement proc. This
		// is useful because the movement proc was quite long and this also lets you
		// override part of the mob's movement behavior without overriding it all. The
		// movement proc's default behavior calls gravity, set_flags, action, set_state,
		// and pixel_move. If you want to change just the part that is now action, you
		// used to have to override movement and remember to call gravity, set_flags,
		// set_state, and pixel_move. Now you can just override action.
		//
		// To be clear, there are still cases where you'd want to override movement. If
		// you want to create a bullet which travels in a straight line (isn't affected
		// by gravity) and doesn't change icon states, you can just override movement.
		// If you want to change how keyboard input is handled or you want to change the
		// mob's AI, you can override action() but leave movement() alone.
		action(ticks)

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: start action:")
			#endif

			// Calling mob.move_to or mob.move_towards will set either the path
			// or destination variables. If either is set, we want to make the
			// mob move as those commands specify, not as the keyboard input specifies.
			// The follow_path proc is defined in mob-pathing.dm.
			if(path || destination)
				follow_path()

			// if the mob's movement isn't controlled by a call to move_to or
			// move_towards, we use the client's keyboard input to control the mob.
			else if(client)

				// the on_ladder proc determines if we're over a ladder or not.
				// the on_ladder var determines if we're actually hanging on it.
				if(on_ladder())
					if(client.keys[controls.up] || client.keys[controls.down])
						if(!on_ladder)
							vel_y = 0
						on_ladder = 1
				else
					on_ladder = 0

				moved = 0

				// If we're on a ladder we want the arrow keys to move us in
				// all directions. Gravity will not affect you.
				if(on_ladder)
					if(client.keys[controls.right])
						dir = RIGHT
						climb(RIGHT)
					if(client.keys[controls.left])
						dir = LEFT
						climb(LEFT)
					if(client.keys[controls.up])
						climb(UP)
					if(client.keys[controls.down])
						climb(DOWN)

				// If you're not on a ladder, movement is normal.
				else
					if(client.keys[controls.right])
						dir = RIGHT
						move(RIGHT)
					if(client.keys[controls.left])
						dir = LEFT
						move(LEFT)
					if(client.keys[controls.up])
						move(UP)
					if(client.keys[controls.down])
						move(DOWN)

				// by default the jumped var is set to 1 when you press the space bar
				if(jumped)
					jumped = 0
					if(can_jump())
						jump()

				slow_down()

			else
				// the slow_down proc will decrease the mob's movement speed if
				// they're not pressing the key to move in their current direction.
				if(moved)
					moved = 0
				else
					slow_down()

			// end of action()

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: end action:")
			#endif

		check_loc()
			// if your x, y, or z coordinate does not match last_x/y/z then
			// the mob's loc was changed elsewhere in the code. This is ok, we
			// just need to call set_pos to update the mob's px and py vars.
			if(x != last_x || y != last_y || z != last_z)
				camera.px = x * icon_width
				camera.py = y * icon_height
				set_pos(x * icon_width - pixel_x, y * icon_height, z)

		// This proc is automatically called every tick. It checks the
		// mob's current situation and keyboard input and calls a proc
		// to take the appropriate action (jump, move, climb).
		movement(ticks)

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: start movement:")
			#endif

			var/turf/t = loc

			// if you don't have a location you're not on the map so we don't
			// need to worry about movement.
			if(!t)
				#ifdef LIBRARY_DEBUG
				if(trace) trace.event("[world.time]: end movement:")
				#endif
				return

			// This sets the on_ground, on_ceiling, on_left, and on_right flags.
			set_flags()

			// apply the effect of gravity
			gravity()

			// handle the movement action. This will handle the automatic behavior
			// that is triggered by calling move_to or move_towards. If the mob has
			// a client connected (and neither move_to/towards was called) keyboard
			// input will be processed.
			action(ticks)

			// set the mob's icon state
			set_state()

			// perform the movement
			pixel_move(vel_x, vel_y)

			#ifdef LIBRARY_DEBUG
			if(trace) trace.event("[world.time]: end movement:")
			#endif

		slow_down()
			// if you're moving faster than your move_speed, slow down
			// whether you're pressing an arrow key or not.
			if(vel_x > move_speed)
				vel_x -= decel
			else if(vel_x < -move_speed)
				vel_x += decel

			// if you're not pressing left or right, slow down.
			// we want this to happen whether you're on a ladder or not
			else
				if(client)
					if(!client.keys[controls.right] && !client.keys[controls.left])
						if(vel_x > decel)
							vel_x -= decel
						else if(vel_x < -decel)
							vel_x += decel
						else
							vel_x = 0

					// if you are on a ladder also slow down in the y direction.
					if(on_ladder && !client.keys[controls.up] && !client.keys[controls.down])
						if(vel_y > decel)
							vel_y -= decel
						else if(vel_y < -decel)
							vel_y += decel
						else
							vel_y = 0

				// for non-clients we check the moved var
				else if(!moved)
					if(!(moved & EAST) && !(moved & WEST))
						if(vel_x > decel)
							vel_x -= decel
						else if(vel_x < -decel)
							vel_x += decel
						else
							vel_x = 0

		// This proc is called every tick by the default movement proc. It sets
		// the on_ground, on_ceiling, on_left, and on_right flags so you can
		// easily check if the mob is next to a wall or on the ground.
		set_flags()
			on_ground = 0
			on_ceiling = 0
			on_left = 0
			on_right = 0

			// we make use of built-in procs but we also have to check for ramps
			for(var/atom/a in obounds(src, 0, -1, 0, -pheight + 1))
				if(!can_bump(a)) continue

				if(a.pleft != a.pright)
					if(py == a.height(px,py,pwidth,pheight))
						on_ground |= (1 | a.flags | a.flags_top)
				else
					if(py == a.py + a.pheight)
						on_ground |= (1 | a.flags | a.flags_top)

			// this still isn't perfect, but it's better. it's not
			// perfect because the bounding box is only offset, it's
			// not stretched.
			for(var/atom/a in obounds(src, -1, 0, -pwidth + 1, 0))
				// this needs to be fixed
				if(a.pleft != a.pright)
					if(px <= a.px + a.pwidth) continue

				if(can_bump(a))
					on_left |= (1 | a.flags | a.flags_right)

			for(var/atom/a in obounds(src, pwidth, 0, -pwidth + 1, 0))
				if(a.pleft != a.pright)
					if(px >= a.px - pwidth) continue

				if(can_bump(a))
					on_right |= (1 | a.flags | a.flags_left)

			for(var/atom/a in obounds(src, 0, pheight, 0, -pheight + 1))
				if(can_bump(a))
					if(a.pleft != a.pright)
						if(py > a.py - pheight) continue
					on_ceiling |= (1 | a.flags | a.flags_bottom)

client

	// Previously these procs displayed an error message. The reason
	// for doing that was because if client.North was called, it was
	// probably because macros weren't properly defined. The error
	// messages were sometimes shown when they shouldn't have been shown,
	// so the error message was removed.
	// We still want to override these procs so that they do nothing.
	// Input is handled by keyboard.dm, we don't need to use these procs.
	North() return 0
	South() return 0
	East() return 0
	West() return 0
	Southeast() return 0
	Southwest() return 0
	Northeast() return 0
	Northwest() return 0
