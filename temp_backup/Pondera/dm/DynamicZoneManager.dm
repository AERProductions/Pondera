/*
	Dynamic Zone Manager - Enhanced with Perlin Noise Biomes & Elevation System
	
	Manages infinite procedural zones with seamless expansion.
	- Zones pre-generate as players approach boundaries
	- Perlin noise-based biome selection for natural clustering
	- Elevation-aware generation (water flows to lowest points)
	- Temperature scales with elevation (higher = colder)
	- Weather system integrated per biome
	- Multiplayer: persisted via savefile
	- Single-player: dynamic with optional saving
*/

var/noise_generator/perlin_noise = null
var/zone_manager/zone_mgr = null
var/list/zone_registry = list()
var/map_mode = "MULTIPLAYER"

// Perlin-like noise generator using seeded random
noise_generator
	var
		seed = 12345
		octaves = 4
		persistence = 0.5
		lacunarity = 2.0
		scale = 50
	
	proc/Hash(x, y)
		// Seeded hash function for consistent noise
		var/n = sin((x + y * 73) * 12.9898) * 43758.5453
		return n - floor(n)
	
	proc/Lerp(a, b, t)
		return a + (b - a) * t
	
	proc/Fade(t)
		return t * t * t * (t * (t * 6 - 15) + 10)
	
	proc/GetNoise(x, y)
		var/value = 0
		var/amplitude = 1
		var/frequency = 1
		var/max_value = 0
		
		for(var/i = 0; i < octaves; i++)
			var/sample_x = (x * frequency) / scale
			var/sample_y = (y * frequency) / scale
			
			var/ix = floor(sample_x)
			var/iy = floor(sample_y)
			var/fx = sample_x - ix
			var/fy = sample_y - iy
			
			var/u = Fade(fx)
			var/v = Fade(fy)
			
			var/n00 = Hash(ix, iy)
			var/n10 = Hash(ix + 1, iy)
			var/n01 = Hash(ix, iy + 1)
			var/n11 = Hash(ix + 1, iy + 1)
			
			var/nx0 = Lerp(n00, n10, u)
			var/nx1 = Lerp(n01, n11, u)
			var/nxy = Lerp(nx0, nx1, v)
			
			value += nxy * amplitude
			max_value += amplitude
			
			amplitude *= persistence
			frequency *= lacunarity
		
		return value / max_value

zone_manager
	var
		list/active_zones = list()
		list/zone_coords = list()
		generate_distance = 3
		chunk_size = 10
		zone_counter = 0
		base_water_level = 1.0
		elevation_scale = 3.0

	New()
		zone_mgr = src
		if(!perlin_noise)
			perlin_noise = new /noise_generator()
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
			
			// Check if player is in a new zone
			var/zone_key = "[chunk_x],[chunk_y]"
			if(zone_key in zone_coords)
				var/zone_id = zone_coords[zone_key]
				// Find the zone object and apply effects
				for(var/dynamic_zone/dz in active_zones)
					if(dz.zone_id == zone_id)
						ApplyZoneEffects(M, dz)
						break
			
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
	
	proc/ApplyZoneEffects(mob/players/M, dynamic_zone/dz)
		/// Apply zone effects when player enters a new zone
		set hidden = 1
		
		if(!M || !dz) return
		
		// Apply temperature-based effects to player
		var/zone_temp = dz.avg_temperature
		
		// Update ambient temperature (affects forge mechanics)
		M.ambient_temp = zone_temp
		
		// Apply biome-specific effects
		dz.ApplyZoneEffectsToPlayer(M)
	
	proc/GenerateElevation(chunk_x, chunk_y)
		// Generate elevation using Perlin noise
		var/noise_x = chunk_x * chunk_size
		var/noise_y = chunk_y * chunk_size
		var/noise_value = perlin_noise.GetNoise(noise_x, noise_y)
		
		// Convert noise (-1 to 1) to elevation (0 to 4)
		var/elevation = ((noise_value + 1) / 2) * elevation_scale
		return elevation

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
		water_type = "fresh"  // Water type: "fresh", "salt", "both"
		base_elevation = 0
		avg_temperature = 15
		humidity = 0.5
		weather_type = "clear"
		is_dirty = FALSE
		is_loaded = FALSE

	New(id, x, y)
		zone_id = id
		chunk_x = x
		chunk_y = y
		GenerateZoneElevation()
		SelectBiomeFromElevation()
		is_dirty = TRUE

	proc/GenerateZoneElevation()
		// Get base elevation from noise generator
		if(zone_mgr && perlin_noise)
			base_elevation = zone_mgr.GenerateElevation(chunk_x, chunk_y)
		else
			base_elevation = 1.0

	proc/SelectBiomeFromElevation()
		// Biome selection based on elevation
		switch(base_elevation)
			if(0 to 0.8)
				// Water/Swamp - Coastal zone (salt water)
				terrain_type = "water"
				water_type = "salt"
				avg_temperature = 18
				humidity = 0.9
			if(0.8 to 1.2)
				// Temperate - Coastal/river region (can have both)
				terrain_type = "temperate"
				water_type = "both"
				avg_temperature = 15
				humidity = 0.6
			if(1.2 to 1.8)
				// Forest/Grassland - Fresh water region
				terrain_type = "temperate"
				water_type = "fresh"
				avg_temperature = 12
				humidity = 0.7
			if(1.8 to 2.4)
				// Highland/Rocky - Fresh water streams
				terrain_type = "arctic"
				water_type = "fresh"
				avg_temperature = 5
				humidity = 0.4
			if(2.4 to 3.0)
				// Mountain - Alpine fresh water
				terrain_type = "arctic"
				water_type = "fresh"
				avg_temperature = -5
				humidity = 0.3
			else
				// Peak - Minimal water
				terrain_type = "arctic"
				water_type = "fresh"
				avg_temperature = -15
				humidity = 0.2
		
		SelectWeatherForBiome()

	proc/SelectWeatherForBiome()
		// Weather based on biome and humidity (with thunderstorm chances)
		var/rand_weather = rand(1, 100)
		
		switch(terrain_type)
			if("water")
				if(rand_weather < 10)
					weather_type = "thunderstorm"
				else if(rand_weather < 40)
					weather_type = "rain"
				else if(rand_weather < 70)
					weather_type = "fog"
				else
					weather_type = "clear"
			if("temperate")
				if(rand_weather < 8)
					weather_type = "thunderstorm"
				else if(rand_weather < 30)
					weather_type = "rain"
				else if(rand_weather < 50)
					weather_type = "cloudy"
				else
					weather_type = "clear"
		
		// Update music theme based on biome and weather
		UpdateZoneMusic()
	
	proc/UpdateZoneMusic()
		/// Update music theme based on zone biome and weather
		set hidden = 1
		
		if(!music_system) return
		
		// Priority: Weather > Biome
		switch(weather_type)
			if("thunderstorm")
				music_system.current_theme = "boss"     // Intense
			if("rain")
				music_system.current_theme = "peaceful" // Moody
			if("fog")
				music_system.current_theme = "peaceful" // Mysterious
			else
				// Use biome-based theme
				switch(terrain_type)
					if("water")
						music_system.current_theme = "exploration"  // Active
					if("temperate")
						music_system.current_theme = "peaceful"     // Calm
					if("arctic")
						music_system.current_theme = "exploration"  // Harsh
					else
						music_system.current_theme = "peaceful"     // Default
	
	proc/GetZoneTemperature()
		/// Get current zone ambient temperature
		return avg_temperature
	
	proc/GetZoneWeatherType()
		/// Get current zone weather
		return weather_type
	
	proc/ApplyZoneEffectsToPlayer(mob/players/M)
		/// Apply zone-specific effects when player enters
		set hidden = 1
		
		if(!M || !M.client) return
		
		// Update player's perception of environment
		M << "<b>Zone [zone_id]:</b> [terrain_type] terrain, [avg_temperature]°C, [weather_type] weather"
		
		// Apply zone music theme
		UpdateZoneMusic()
		
		// Update player's current weather
		UpdateMusicForWeather(weather_type, M)

	proc/GenerateZoneTerrain()
		var/start_x = chunk_x * zone_mgr.chunk_size + 1
		var/start_y = chunk_y * zone_mgr.chunk_size + 1
		var/end_x = start_x + zone_mgr.chunk_size - 1
		var/end_y = start_y + zone_mgr.chunk_size - 1
		
		for(var/x = start_x; x <= end_x; x++)
			for(var/y = start_y; y <= end_y; y++)
				var/turf/t = locate(x, y, 2)
				if(!t)
					// Generate turf with appropriate type based on terrain
					switch(terrain_type)
						if("water")
							t = new /turf/water(x, y, 2)
							t:water_type = water_type  // Apply biome water type to turf
						if("arctic")
							// Use mountain type for arctic/highland terrain
							t = new /turf/mntn(x, y, 2)
						if("desert")
							// Use dark grass for desert
							t = new /turf/drkgrss(x, y, 2)
						else
							// Use light grass for temperate
							t = new /turf/lghtgrss(x, y, 2)
				
				turfs += t
				t.SpawnResource()
		
		// Apply weather effects to nearby players
		ApplyZoneWeatherToNearbyPlayers()
		
		is_loaded = TRUE
		is_dirty = FALSE

	proc/ApplyZoneWeatherToNearbyPlayers()
		// Find all players in this zone and update their weather
		for(var/mob/players/M in world)
			if(!M.client) continue
			
			// Check if player is in this zone's area
			var/zone_min_x = chunk_x * zone_mgr.chunk_size + 1
			var/zone_max_x = chunk_x * zone_mgr.chunk_size + zone_mgr.chunk_size
			var/zone_min_y = chunk_y * zone_mgr.chunk_size + 1
			var/zone_max_y = chunk_y * zone_mgr.chunk_size + zone_mgr.chunk_size
			
			if(M.x >= zone_min_x && M.x <= zone_max_x && M.y >= zone_min_y && M.y <= zone_max_y)
				// Apply this zone's weather
				ApplyBiomeWeather(M, weather_type)

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
		F["elevation"] = base_elevation
		F["temperature"] = avg_temperature
		F["weather"] = weather_type
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
		base_elevation = F["elevation"]
		avg_temperature = F["temperature"]
		weather_type = F["weather"]
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
