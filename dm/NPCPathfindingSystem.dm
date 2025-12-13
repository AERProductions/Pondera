// dm/NPCPathfindingSystem.dm — Elevation-aware pathfinding for NPCs
// Enables NPCs to navigate multi-level terrain with proper elevation transitions

#define PATHFIND_MAX_DISTANCE 50  // Maximum search radius for pathfinding
#define PATHFIND_TIMEOUT 100      // Ticks before pathfinding times out
#define PATHFIND_UPDATE_FREQ 5    // Ticks between path recalculation

// Global pathfinding system
var/datum/NPCPathfindingSystem/pathfinding_system

// Initialize on world startup
proc/InitializeNPCPathfinding()
	pathfinding_system = new /datum/NPCPathfindingSystem()
	RegisterInitComplete("NPC Pathfinding")

// Get pathfinding system singleton
proc/GetNPCPathfindingSystem()
	if(!pathfinding_system)
		world.log << "ERROR: NPC Pathfinding system not initialized!"
		return null
	return pathfinding_system

// Datum for NPC pathfinding behavior
datum/NPCPathfindingSystem
	var/initialized = FALSE

	New()
		initialized = TRUE

	// Request path from source to target
	// Returns list of turfs to follow, or empty list if path not found
	proc/FindPath(mob/npc, turf/target, var/max_range = PATHFIND_MAX_DISTANCE)
		if(!npc || !target) return list()
		if(abs(npc.x - target.x) + abs(npc.y - target.y) > max_range) return list()

		var/list/path = list()
		var/list/open_set = list()
		var/list/closed_set = list()
		var/list/came_from = list()
		var/list/g_score = list()  // Cost from start
		var/list/f_score = list()  // Estimated total cost

		var/turf/start_turf = isturf(npc.loc) ? npc.loc : null
		if(!start_turf) return list()

		open_set += start_turf
		g_score[start_turf] = 0
		f_score[start_turf] = GetHeuristic(start_turf, target)

		var/iterations = 0
		var/max_iterations = 500  // Prevent infinite loops

		while(open_set.len > 0 && iterations < max_iterations)
			iterations++

			// Find node in open_set with lowest f_score
			var/turf/current = null
			var/current_f = 999999
			for(var/turf/T in open_set)
				if(f_score[T] < current_f)
					current_f = f_score[T]
					current = T

			if(!current) break

			if(current == target)
				// Reconstruct path
				path = ReconstructPath(came_from, current)
				return path

			open_set -= current
			closed_set += current

			// Check all adjacent turfs
			for(var/turf/neighbor in GetWalkableNeighbors(current, npc))
				if(neighbor in closed_set) continue

				var/tentative_g = g_score[current] + GetMovementCost(current, neighbor, npc)

				if(!(neighbor in open_set))
					open_set += neighbor
				else if(tentative_g >= g_score[neighbor])
					continue

				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + GetHeuristic(neighbor, target)

		return list()  // No path found

	// Calculate heuristic distance (Manhattan + elevation consideration)
	proc/GetHeuristic(turf/A, turf/B)
		if(!A || !B) return 999999
		var/horizontal_dist = abs(A.x - B.x) + abs(A.y - B.y)
		var/elevation_penalty = abs(A.z - B.z) * 2  // Penalize z-level changes
		return horizontal_dist + elevation_penalty

	// Get movement cost between two turfs
	proc/GetMovementCost(turf/from, turf/target, mob/npc)
		if(!from || !target || !npc) return 999999

		// Base movement cost
		var/cost = 1.0

		// Terrain-based cost modifiers
		if(target.density) return 999999  // Impassable
		if(target.opacity) cost += 1  // Heavy terrain costs more

		// Elevation transition costs
		var/from_elev = GetTurfElevation(from)
		var/target_elev = GetTurfElevation(target)
		var/elev_diff = abs(target_elev - from_elev)

		if(elev_diff > 0.5)
			// Must use elevation object to transition
			var/has_transition = FALSE
			for(var/elevation/E in target)
				if(E.elevel == target_elev)
					has_transition = TRUE
					break
			if(!has_transition)
				return 999999  // Can't transition without elevation object

		// Elevation changes cost slightly more
		if(elev_diff > 0)
			cost += elev_diff * 0.5

		return cost

	// Get all walkable neighbor turfs for pathfinding
	proc/GetWalkableNeighbors(turf/T, mob/npc)
		var/list/neighbors = list()
		if(!T) return neighbors

		// Check all 4 cardinal directions
		for(var/direction in list(NORTH, SOUTH, EAST, WEST))
			var/turf/neighbor = null
			if(direction == NORTH && T.y < 255)
				neighbor = locate(T.x, T.y + 1, T.z)
			else if(direction == SOUTH && T.y > 1)
				neighbor = locate(T.x, T.y - 1, T.z)
			else if(direction == EAST && T.x < 255)
				neighbor = locate(T.x + 1, T.y, T.z)
			else if(direction == WEST && T.x > 1)
				neighbor = locate(T.x - 1, T.y, T.z)
			
			if(!neighbor) continue

			// Check if neighbor is walkable
			if(CanNPCWalk(neighbor, npc, direction))
				neighbors += neighbor

		return neighbors

	// Check if NPC can walk on a turf
	proc/CanNPCWalk(turf/T, mob/npc, var/direction)
		if(!T || !npc) return FALSE
		if(T.density) return FALSE

		// Check elevation compatibility
		if(!Chk_LevelRange(npc, T))
			return FALSE  // Elevation too different

		// Check for blocking objects
		for(var/obj/O in T)
			if(O.density && O.Chk_LevelRange(npc))
				return FALSE

		// Check for blocking mobs (except self)
		for(var/mob/M in T)
			if(M != npc && M.density && M.Chk_LevelRange(npc))
				return FALSE

		return TRUE

	// Get elevation of a turf
	proc/GetTurfElevation(turf/T)
		if(!T) return 1.0

		// Check for elevation objects on this turf
		for(var/elevation/E in T)
			if(E.elevel)
				return E.elevel

		return 1.0

	// Reconstruct path from A* search
	proc/ReconstructPath(list/came_from, turf/current)
		var/list/path = list()
		var/turf/node = current

		while(came_from[node])
			path.Insert(1, node)
			node = came_from[node]

		path.Insert(1, node)
		return path

	// Helper to check level range
	proc/Chk_LevelRange(atom/A, atom/B)
		if(!A || !B) return FALSE
		var/elev_a = A.elevel || 1.0
		var/elev_b = B.elevel || 1.0
		return abs(elev_a - elev_b) <= 0.5

// NPC behavior extension for pathfinding
mob/npcs
	var/list/current_path = list()
	var/path_index = 1
	var/last_pathfind = 0
	var/pathfind_target = null

	// Start NPC movement toward target
	proc/MoveTowardTarget(atom/target)
		if(!target) return

		pathfind_target = target
		var/turf/target_turf = isturf(target.loc) ? target.loc : null
		if(!target_turf) target_turf = isturf(target) ? target : null
		if(!target_turf) return

		// Recalculate path periodically
		if(world.time - last_pathfind > PATHFIND_UPDATE_FREQ * 10)
			var/datum/NPCPathfindingSystem/pf = GetNPCPathfindingSystem()
			current_path = pf.FindPath(src, target_turf, PATHFIND_MAX_DISTANCE)
			path_index = 1
			last_pathfind = world.time

		// Follow path
		if(current_path.len > 0 && path_index <= current_path.len)
			var/turf/next_turf = current_path[path_index]
			var/turf/current_turf = isturf(src.loc) ? src.loc : null
			if(next_turf == current_turf)
				path_index++
			else
				StepTowardTurf(next_turf)

	// Move one step toward target turf
	proc/StepTowardTurf(turf/target)
		if(!target || isturf(src.loc) && src.loc == target) return

		var/direction = get_dir(src, target)
		step(src, direction)

	// Clear pathfinding state
	proc/ClearPath()
		current_path = list()
		path_index = 1
		pathfind_target = null
		last_pathfind = 0
