/*
	Map Generation — by F0lak
	Handles procedural generation of the game world by placing random blocks of various turfs
	and borders around the map, as well as spawning biome-relevant resources.
	Biome-specific spawning logic is extended in files labelled with the biome_ prefix.
*/

// Helper: return cardinal (N/S/E/W) neighbors of a turf.
proc
	get_cardinal(turf/t)
		var/cardinals[] = new
		if(get_step(t, 1)) cardinals += get_step(t, 1)
		if(get_step(t, 2)) cardinals += get_step(t, 2)
		if(get_step(t, 4)) cardinals += get_step(t, 4)
		if(get_step(t, 8)) cardinals += get_step(t, 8)
		return cardinals

	// Helper: return diagonal neighbors of a turf.
	get_diagonal(turf/t)
		var/diagonals[] = new
		if(get_step(t, 5))  diagonals += get_step(t, 5)
		if(get_step(t, 6))  diagonals += get_step(t, 6)
		if(get_step(t, 9))  diagonals += get_step(t, 9)
		if(get_step(t, 10)) diagonals += get_step(t, 10)
		return diagonals

// Global list of active map generator instances.
var
	map_generators[0]

// Spawn initial terrain: create generators for lakes and hills, apply borders and resource spawning.
proc
	GenerateMap(lakes = 15, hills = 15, continent = "story")
		// Initialize biome registry before first generation
		InitializeBiomeRegistry()
		
		new /map_generator/water(lakes)
		new /map_generator/temperate(hills, continent)

		for(var/map_generator/mg in map_generators)
			mg.EdgeBorder()
		for(var/map_generator/mg in map_generators)
			mg.InsideBorder()
		for(var/turf/t)
			BiomeSpawnResource(t, continent)  // Use BiomeRegistry instead of per-turf SpawnResource()

// Map generator type: creates random terrain blocks at specified size/location.
map_generator

	var
		pos[2]
		size[2]
		turfs[0]
		turf/tile
		turf/center_turf
		continent = "story"  // Which continent/continent mode this generator is for

		min_size = 1
		max_size = 5

	New(n, cont = "story")
		continent = cont
		map_generators += src
		TIMER_END("generation")
		for(var/i, i<n, i++)
			GetTurfs()
		Generate()
		TIMER_END("generation")

	proc
		// Select random turfs within a chunk and add to turfs list.
		GetTurfs()
			size[1] = rand(min_size, max_size)
			size[2] = rand(min_size, max_size)
			pos[1] = rand(1, world.maxx - size[1])
			pos[2] = rand(1, world.maxy - size[2])
			turfs |= (block(locate(pos[1], pos[2], 2), locate(pos[1] + size[1], pos[2] + size[2], 2)))

		// Instantiate turfs and set sound effects at chunk center.
		Generate()
			for(var/turf/t in turfs)
				var newtile = new tile (t)
				if(turfs.Find(newtile) == round(turfs.len/2))
					center_turf = newtile
					if(global.season!="Winter")
						center_turf.SpawnSoundEffects()
					else
						center_turf.SpawnSoundEffectsW()
			for(var/turf/water/t in turfs)
				var newtile = new tile (t)
				if(turfs.Find(newtile) == round(turfs.len/2))
					center_turf = newtile
					if(global.season!="Winter")
						center_turf.SpawnSoundEffectsWAT()
					else
						return

		// Paint borders on edge turfs between different elevations.
		EdgeBorder()
			for(var/turf/t in turfs)
				var dir
				for(var/turf/adjacent in get_cardinal(t))
					if(adjacent.elevation == t.elevation) continue
					else
						dir += get_dir(t, adjacent)
				if(dir && t.border_type)
					CreateBorder(t, dir)

		// Paint interior borders on turfs with same-elevation neighbors.
		InsideBorder()
			for(var/turf/t in turfs)
				var dir = 0
				for(var/turf/adjacent in get_cardinal(t))
					if(adjacent.elevation == t.elevation)
						dir += get_dir(t, adjacent)
					else
						continue

				if(dir == 15)

					for(var/turf/diagonal in get_diagonal(t))
						if(diagonal.elevation == t.elevation) continue
						else if(t.border_type)
							CreateBorder(t, 20 + get_dir(t, diagonal))

		CreateBorder(turf/t, dir)
			var/obj/border/b = locate() in t.vis_contents
			if(b?.dir != dir)
				var/obj/border/new_border = new t.border_type
				new_border.DrawBorder(t, dir)


obj
	border
		density = TRUE
		var
			ramp_chance = 0
			deposit_chance = 0
			deposit_types[0]

		proc
			DrawBorder(turf/t, d)
				dir = d
				icon_state = "[d]"

				if(prob(ramp_chance) && dir < 16)
					icon_state += " ramp"
					density = FALSE

				else if(deposit_types.len && prob(deposit_chance) && dir < 16)
					var/deposit = pick(deposit_types)

					var/obj/new_deposit = new deposit(t)
					new_deposit.icon_state = "[d]"

				t.vis_contents += src
				t.density |= density
				t.spawn_resources = FALSE

turf
	var
		obj/border/border_type
		elevation = 0
		spawn_resources = TRUE
		sfx[0]
		wsfx[0]
		sfxwat[0]



	proc
		SetElevation()
		SpawnResource()
		SpawnSoundEffects()
			if(sfx.len > 0&&global.season!="Winter"&&month!="Tevet")
				var/soundmob/new_sfx = pick(sfx)
				new new_sfx(src)
		SpawnSoundEffectsW()
			if(wsfx.len > 0&&global.season=="Winter")
				var/soundmob/new_wsfx = pick(wsfx)
				new new_wsfx(src)
		SpawnSoundEffectsWAT()
			if(sfxwat.len > 0&&global.season!="Winter"&&month!="Tevet")
				var/soundmob/new_sfxwat = pick(sfxwat)
				new new_sfxwat(src)

	New(turf/newloc)
		//..()
		if(newloc) SetElevation(newloc.elevation)