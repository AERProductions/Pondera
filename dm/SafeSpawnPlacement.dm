/*
	Safe Spawn Placement System
	Ensures players spawn in accessible locations
*/

proc/FindSafeSpawnTurf(turf/preferred = null)
	if(preferred && !preferred.density && !preferred.opacity)
		return preferred
	
	var/turf/center = preferred || locate(world.maxx / 2, world.maxy / 2, 2)
	
	// Spiral search from center
	for(var/radius = 1; radius <= 50; radius++)
		for(var/dx = -radius; dx <= radius; dx++)
			for(var/dy = -radius; dy <= radius; dy++)
				if(abs(dx) < radius && abs(dy) < radius) continue
				
				var/x = center.x + dx
				var/y = center.y + dy
				if(x < 1 || x > world.maxx || y < 1 || y > world.maxy) continue
				
				var/turf/t = locate(x, y, 2)
				if(t && !t.density && !t.opacity)
					return t
	
	return center

proc/ValidateSpawnLocation(turf/t)
	if(!t) return FALSE
	if(t.density || t.opacity) return FALSE
	
	// Check for blocking objects
	for(var/obj/o in t)
		if(o.density) return FALSE
	
	// Ensure accessible neighbors
	var/safe = 0
	for(var/turf/adj in get_cardinal(t))
		if(adj && !adj.density && abs(adj.elevation - t.elevation) <= 1.5)
			safe++
	
	return safe > 0

atom
	var/no_block_spawn = FALSE

mob/players
	var/current_zone_id = 0

	proc/SpawnAtSafeLocation(turf/preferred = null)
		var/turf/safe = FindSafeSpawnTurf(preferred)
		if(!ValidateSpawnLocation(safe))
			// Carve out area
			safe.density = FALSE
			for(var/turf/adj in range(1, safe))
				if(adj.density) adj.density = FALSE
				if(adj.elevation > 2) adj.elevation = 0.5
		
		loc = safe
		world.log << "[key] spawned at ([safe.x], [safe.y])"

	proc/SpawnInZone()
		// Spawn in origin zone (0, 0) by default
		if(!zone_mgr)
			SpawnAtSafeLocation()
			return
		
		var/dynamic_zone/dz = zone_mgr.RequestZone(0, 0)
		if(!dz || !dz.turfs.len)
			SpawnAtSafeLocation()
			return
		
		var/turf/spawn_turf = dz.turfs[rand(1, dz.turfs.len)]
		SpawnAtSafeLocation(spawn_turf)

	verb/TestSpawnSafety()
		set category = "Debug"
		var/turf/t = loc
		src << "Location: ([t.x], [t.y])"
		src << "Safe: [ValidateSpawnLocation(t) ? "YES" : "NO"]"
		src << "Density: [t.density], Opacity: [t.opacity]"
