/*
	Edge Detection and Zone Expansion
	Pre-generates adjacent zones as players approach boundaries
	Smooths elevation transitions and prevents cliff issues
*/

// Integration with zone monitor - called each tick
proc/MonitorZoneExpansion()
	if(!zone_mgr) return
	zone_mgr.MonitorPlayerProximity()

// Smooth terrain transitions between zones
proc/SmoothZoneTransitions()
	if(!zone_mgr) return
	
	for(var/dynamic_zone/dz in zone_mgr.active_zones)
		for(var/turf/t in dz.turfs)
			// Check adjacent turfs in other zones
			for(var/turf/adj in get_cardinal(t))
				if(!adj) continue
				
				// Smooth elevation difference
				var/diff = abs(adj.elevation - t.elevation)
				if(diff > 1.5)
					var/avg = (adj.elevation + t.elevation) / 2
					t.elevation = avg
					adj.elevation = avg

// Detect and fix figure-8 cliff issues
proc/FixCliffIssues()
	if(!zone_mgr) return
	
	for(var/dynamic_zone/dz in zone_mgr.active_zones)
		for(var/turf/t in dz.turfs)
			if(!t.density) continue
			
			// Check if isolated (surrounded by lower terrain)
			var/lower_count = 0
			for(var/turf/adj in get_cardinal(t))
				if(!adj || adj.elevation < t.elevation)
					lower_count++
			
			// Too isolated = problematic figure-8
			if(lower_count == 4)
				t.elevation -= 0.5  // Lower it

// Expand map seamlessly - called when player nears edge
proc/CheckAndExpandZones()
	if(!zone_mgr) return
	
	for(var/mob/players/M in world)
		if(!M.client) continue
		var/turf/t = M.loc
		if(!istype(t)) continue
		
		var/list/coords = zone_mgr.GetChunkCoords(t)
		var/chunk_x = coords[1]
		var/chunk_y = coords[2]
		
		// Get distance to zone boundaries
		var/start_x = chunk_x * zone_mgr.chunk_size + 1
		var/start_y = chunk_y * zone_mgr.chunk_size + 1
		var/end_x = start_x + zone_mgr.chunk_size - 1
		var/end_y = start_y + zone_mgr.chunk_size - 1
		
		var/dist_edge = min(t.x - start_x, end_x - t.x, t.y - start_y, end_y - t.y)
		
		// Pre-generate if getting close (within 15 turfs)
		if(dist_edge < 15)
			for(var/dx = -2; dx <= 2; dx++)
				for(var/dy = -2; dy <= 2; dy++)
					zone_mgr.RequestZone(chunk_x + dx, chunk_y + dy)

// Integration hook - add to zone monitor loop
proc/ExpandedZoneMonitoring()
	CheckAndExpandZones()
	SmoothZoneTransitions()
	FixCliffIssues()
