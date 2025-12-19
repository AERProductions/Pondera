
// File:    pathing.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This file contains pathfinding features. It defines the
//   mob.move_to and mob.move_towards procs which are similar
//   to DM's built-in walk_to and walk_towards procs.

// The /Path datum is used to contain all A* pathfinding code.
// You never need to access this directly, mob.move_to handles
// all the details.
//
// The implementation is almost directly copied from:
//   http://en.wikipedia.org/wiki/A*_search_algorithm
Path
	var
		turf/destination
		mob/mover
		list/tiles

		list/closed
		list/fringe
		list/parent
		turf/current

		list/f_score
		list/g_score
		list/h_score

		limit = 0

	New(mob/m, turf/t)
		mover = m
		destination = t

		compute()

	proc
		// The add proc is called to add a node to the fringe. If the node already
		// exists in the fringe, it's g() and h() values are updated (if appropriate).
		add(turf/t)
			if(!t) return
			if(t.density) return
			if(t in closed) return 0

			var/tentative_g_score = g_score[current] + distance(current, t)
			var/tentative_is_better = 0

			if(!(t in fringe))
				fringe += t
				tentative_is_better = 1
			else if(tentative_g_score < g_score[t])
				tentative_is_better = 1

			if(tentative_is_better)
				parent[t] = current

				g_score[t] = tentative_g_score
				h_score[t] = heuristic(t)
				f_score[t] = g_score[t] + h_score[t]

			return 1

		// this proc controls the distance metric used by the search algorithm.
		distance(turf/a, turf/b)
			return abs(a.x - b.x) + abs(a.y - b.y)

		// the heuristic is simply the distance from the turf to the destination.
		heuristic(turf/t)
			return distance(t, destination)

		compute()

			closed = list()
			fringe = list(mover.loc)
			parent = list()

			f_score = list()
			g_score = list()
			h_score = list()

			g_score[mover.loc] = 0
			h_score[mover.loc] = heuristic(mover.loc)
			f_score[mover.loc] = h_score[mover.loc]

			parent[mover.loc] = null

			var/found_path = 0

			while(fringe.len)

				// if there's a limit to how many turfs you'll check
				if(limit)
					// and if you've reached that limit, stop
					if(closed.len >= limit)
						break

				// find the node with the lowest f-score
				current = fringe[1]

				for(var/turf/t in fringe)
					if(f_score[t] < f_score[current])
						current = t

				// If this node is the destination, we're done.
				if(current == destination)
					found_path = 1
					break

				fringe -= current
				closed += current

				// The in_air flag tells us if the current tile is in the air, or
				// on the ground (there's a dense tile below it). This flags determines
				// who the current node's neighbors are -- if it's on the ground the
				// mob can reach nodes by walking to the side or by jumping, if the node
				// if in the air the mob can only reach nodes by falling.
				var/in_air = 1

				var/turf/t = locate(current.x, current.y - 1, current.z)
				if(t)
					if(t.density)
						in_air = 0
					else
						in_air = 1

						add(t)

				// if the current tile is "in the air", only check the tiles you
				// can fall to (down+left and down+right, down was already added)
				if(in_air)
					t = locate(current.x - 1, current.y, current.z)
					if(t && !t.density)
						add(locate(current.x - 1, current.y - 1, current.z))

					t = locate(current.x + 1, current.y, current.z)
					if(t && !t.density)
						add(locate(current.x + 1, current.y - 1, current.z))

				// if the current tile is on the ground, check the tiles to the
				// sides and tiles you can jump to.
				else
					t = locate(current.x - 1, current.y, current.z)
					add(t)

					t = locate(current.x + 1, current.y, current.z)
					add(t)

					t = locate(current.x, current.y, current.z)

					var/turf/up = locate(current.x, current.y + 1, current.z)
					if(t && !t.density && up && !up.density)

						if(add(locate(current.x - 1, current.y + 1, current.z)))
							add(locate(current.x - 2, current.y + 1, current.z))

						if(add(locate(current.x + 1, current.y + 1, current.z)))
							add(locate(current.x + 2, current.y + 1, current.z))

			// At this point we're outside of the loop and we've
			// either found a path or exhausted all options.

			if(!found_path)
				del src

			// at this point we know a path exists, we just have to identify it.
			// we use the "parent" list to trace the path.
			var/turf/t = destination
			tiles = list()

			while(t)
				tiles.Insert(1, t)
				t = parent[t]

mob
	var
		Path/path
		turf/destination
		turf/next_step

		turf/__last_jump_loc
		__jump_delay = 0

		__stuck_counter = 0

	proc
		// The follow_path proc is called from the mob's default movement proc if
		// either path or destination is set to a non-null value (in other words,
		// follow_path is called if move_to or move_towards was called). Because
		// this proc is called from movement, all we need to do is determine what
		// calls to move, jump, or climb (not implemented yet) should be made.
		follow_path()

			// If the mob is following a planned path...
			if(path)

				if(loc == path.destination)
					stop()
					return 1

				// check to see if the mob is "stuck", the stuck counter
				// is reset to zero when the mob advances a tile. If the
				// mob spends 50 ticks at the same tile, they're "stuck".
				__stuck_counter += 1

				if(__stuck_counter > 50)
					__stuck_counter = 0
					path = new(src, path.destination)

					if(!path)
						return 0

				next_step = null
				while(next_step == null)
					if(!path.tiles.len)
						stop()
						return 0

					next_step = path.tiles[1]

					if(loc == next_step)
						var/turf/under = locate(next_step.x, next_step.y - 1, next_step.z)

						// if the next_step has a dense turf below it, that means its a tile
						// you need to step on before we'll remove it from the list. If it's
						// up in the air we'll remove it from the list if you just touch a
						// small part of it.
						if(under && under.density)
							if(on_ground)
								path.tiles.Cut(1,2)
								next_step = null
								__stuck_counter = 0

						else
							path.tiles.Cut(1,2)
							next_step = null
							__stuck_counter = 0

				if(!next_step)
					stop()
					return 0

				// move towards the next step

				// Previously, these if statements had compared your x
				// to the next_step's x. This could cause you to get stuck
				// standing on the edge of an object when your next_step
				// was below you.
				//
				// In the testing I've done, this corrects the problem and
				// improves path following overall.
				if(px < next_step.px)
					move(RIGHT)
					dir = RIGHT
				else if(px + pwidth > next_step.px + next_step.pwidth)
					move(LEFT)
					dir = LEFT
				else
					slow_down()

				if(next_step.y > y)
					if(can_jump())
						__last_jump_loc = loc
						__jump_delay = 30
						jump()

			// if the mob is moving towards a destination...
			else if(destination)

				if(loc == destination)
					stop()
					return 1

				// I made the same changes to these if statements as the ones
				// in the case for following a path.
				if(px < destination.px)
					move(RIGHT)
					dir = EAST
				else if(px + pwidth > destination.px + destination.pwidth)
					move(LEFT)
					dir = WEST
				else
					slow_down()

			else
				return 0

	proc
		// calling the stop proc will halt any movement that was
		// triggered by a call to move_to or move_towards.
		stop()
			destination = null
			next_step = null
			path = null
			__stuck_counter = 0

		// This is the sidescroller equivalent of DM's built-in walk_towards
		// proc. The behavior takes some obstacles into account (it'll try to
		// jump over obstacles) but it doesn't plan a path. It's CPU usage is
		// lower than move_to but the behavior may not be sufficiently smart.
		move_towards(turf/t)

			stop()

			if(istype(t, /atom/movable))
				t = t.loc

			// calling move_towards(null) will stop the current movement but
			// not trigger a new one, so it's just like calling stop().
			if(!t) return 0

			destination = t

			return 1

		// move_to is the sidescroller equivalent of DM's built-in walk_to proc.
		// It uses the A* algorithm to plan a path to the destination and the
		// follow_path proc handles the details of following the path.
		move_to(turf/t)

			stop()

			if(istype(t, /atom/movable))
				t = t.loc

			// calling move_to(null) will stop the current movement but
			// not trigger a new one, so it's just like calling stop().
			if(!t) return 0

			var/turf/a = locate(t.x, t.y - 1, t.z)
			if(!a.density && !a.scaffold)
				a = locate(t.x, t.y - 2, t.z)
				if(!a.density && !a.scaffold)
					return 0

			// Because we're creating a new path we can reset this counter.
			__stuck_counter = 0

			path = new(src, t)

			if(path)
				next_step = path.tiles[1]
				return 1
			else
				stop()
				return 0
