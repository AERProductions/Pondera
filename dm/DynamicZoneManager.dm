/*
	Dynamic Zone Manager - Simplified Working Version
	
	Manages infinite procedural zones with seamless expansion.
	- Zones pre-generate as players approach boundaries
	- Multiplayer: persisted via savefile
	- Single-player: dynamic with optional saving
*/

var/zone_manager/zone_mgr = null
var/list/zone_registry = list()
var/map_mode = "MULTIPLAYER"

zone_manager
	var
		list/active_zones = list()
		list/zone_coords = list()
		generate_distance = 3
		chunk_size = 10
		zone_counter = 0

	New()
		zone_mgr = src
		LoadZoneRegistry()
		SpawnZoneMonitor()

	proc/LoadZoneRegistry()
		var/savefile/F = new("MapSaves/zone_registry.sav")
		if(F)
			F >> zone_registry
		else
			zone_registry = list()

	proc/SaveZoneRegistry()
		var/savefile/F = new("MapSaves/zone_registry.sav")
		F["zones"] = zone_registry

	proc/SpawnZoneMonitor()
		spawn
			while(src)
				sleep(5)
				MonitorPlayerProximity()

	proc/MonitorPlayerProximity()
		for(var/mob/players/M in world)
			if(!M.client) continue
			var/turf/t = M.loc
			if(!istype(t)) continue
			
			var/chunk_x = round(t.x / chunk_size)
			var/chunk_y = round(t.y / chunk_size)
			
			// Pre-generate nearby zones
			for(var/dx = -generate_distance; dx <= generate_distance; dx++)
				for(var/dy = -generate_distance; dy <= generate_distance; dy++)
					RequestZone(chunk_x + dx, chunk_y + dy)

	proc/RequestZone(chunk_x, chunk_y)
		var/zone_key = "[chunk_x],[chunk_y]"
		if(zone_key in zone_coords)
			return zone_coords[zone_key]
		
		// Create new zone
		zone_counter++
		var/new_id = zone_counter
		zone_coords[zone_key] = new_id
		
		var/dynamic_zone/dz = new(new_id, chunk_x, chunk_y)
		active_zones += dz
		
		var/zone_data/zd = new(new_id, chunk_x, chunk_y)
		zone_registry += zd
		SaveZoneRegistry()
		
		return dz

	proc/GetChunkCoords(turf/t)
		return list(round(t.x / chunk_size), round(t.y / chunk_size))

dynamic_zone
	var
		zone_id
		chunk_x
		chunk_y
		list/turfs = list()
		zone_name = ""
		zone_owner = ""
		list/zone_permissions = list()
		terrain_type = "temperate"
		is_dirty = FALSE
		is_loaded = FALSE

	New(id, x, y)
		zone_id = id
		chunk_x = x
		chunk_y = y
		SelectBiome()
		is_dirty = TRUE

	proc/SelectBiome()
		var/check = (chunk_x + chunk_y) % 4
		switch(check)
			if(0) terrain_type = "temperate"
			if(1) terrain_type = "arctic"
			if(2) terrain_type = "desert"
			if(3) terrain_type = "rainforest"

	proc/GenerateZoneTerrain()
		var/start_x = chunk_x * zone_mgr.chunk_size + 1
		var/start_y = chunk_y * zone_mgr.chunk_size + 1
		var/end_x = start_x + zone_mgr.chunk_size - 1
		var/end_y = start_y + zone_mgr.chunk_size - 1
		
		for(var/x = start_x; x <= end_x; x++)
			for(var/y = start_y; y <= end_y; y++)
				var/turf/t = locate(x, y, 2)
				if(!t)
					t = new /turf/temperate(x, y, 2)
				turfs += t
				t.SpawnResource()
		
		is_loaded = TRUE
		is_dirty = FALSE

	proc/SaveToDisk()
		if(!is_dirty) return
		var/save_file = "MapSaves/Zone_[zone_id]_[chunk_x]_[chunk_y].sav"
		var/savefile/F = new(save_file)
		F["id"] = zone_id
		F["x"] = chunk_x
		F["y"] = chunk_y
		F["name"] = zone_name
		F["owner"] = zone_owner
		F["perms"] = zone_permissions
		is_dirty = FALSE

	proc/LoadFromDisk()
		var/save_file = "MapSaves/Zone_[zone_id]_[chunk_x]_[chunk_y].sav"
		var/savefile/F = new(save_file)
		if(!F)
			GenerateZoneTerrain()
			return
		
		zone_name = F["name"]
		zone_owner = F["owner"]
		zone_permissions = F["perms"]
		is_loaded = TRUE

	proc/MarkDirty()
		is_dirty = TRUE

zone_data
	var
		zone_id
		x
		y
		zone_name = ""
		zone_owner = ""
		created_time
		creator = ""
		list/visited_by = list()
		terrain_type = "temperate"

	New(id, cx, cy)
		zone_id = id
		x = cx
		y = cy
		created_time = world.time

proc/InitializeDynamicZones()
	if(!zone_mgr)
		zone_mgr = new /zone_manager()
