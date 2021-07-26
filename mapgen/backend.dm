/*

	Map Generation
	by F0lak

	Handles procedural generation of the game world by placing random
	blocks of various turfs and borders around the map, as well as
	taking care of spawning biome relevant resources on the turfs

	This dm file DOES NOT contain everything needed to make this system function
	Some functionality is extended in other dm files
	dm files that extend functionality are labelled with the biome_ prefix

		Functionality NOT contained in this file:
			- Resource Spawning:
				the function to spawn resources is defined in this file,
				but the actual spawning of resources and their chance to spawn
				are defined in the files labelled with the biome_ prefix


	Any inquiries or assistance in using this system can be directed to F0lak
	at f0lak.haz@gmail.com
	Subject: Pondera Map Generation

	version 1.0 | 12/08/20
		- see documentation
	version 1.1 | 12/11/20
		- added graphics for inside corners
		- added mining deposits to hillsides
		- added ramps to hillsides
		- added fields to customize size of terrain blocks
		- tweaked resource spawning to fix a few glitches
		- changed resource spawning to use a bool 'spawn_resources'
		- added _seed.dm
		- made hillsides modify turf density

*/

proc
	get_cardinal(turf/t)
		var/cardinals[] = new
		if(get_step(t, 1)) cardinals += get_step(t, 1)
		if(get_step(t, 2)) cardinals += get_step(t, 2)
		if(get_step(t, 4)) cardinals += get_step(t, 4)
		if(get_step(t, 8)) cardinals += get_step(t, 8)
		return cardinals

	get_diagonal(turf/t)
		var/diagonals[] = new
		if(get_step(t, 5))  diagonals += get_step(t, 5)
		if(get_step(t, 6))  diagonals += get_step(t, 6)
		if(get_step(t, 9))  diagonals += get_step(t, 9)
		if(get_step(t, 10)) diagonals += get_step(t, 10)
		return diagonals

/*
	The /map_generator type is used to create a random block
	of a specific type of turf at a random location and size
	somewhere on the world map
*/

var
	map_generators[0]

proc
	GenerateMap(lakes = 25, hills = 25)
		new /map_generator/water(lakes)
		new /map_generator/temperate(hills)

		for(var/map_generator/mg in map_generators)
			mg.EdgeBorder()
		for(var/map_generator/mg in map_generators)
			mg.InsideBorder()
		for(var/turf/t)
			t.SpawnResource()

map_generator

	var
		pos[2]	// read as vector2
		size[2]	// read as vector2
		turfs[0] // list of turfs for this chunk
		turf/tile
		turf/center_turf

		min_size = 1
		max_size = 5

	New(n)
		//..()
		map_generators += src

		TIMER_END("generation")

		for(var/i, i<n, i++)
			GetTurfs()

		Generate()

		TIMER_END("generation")

	proc
		GetTurfs()

			size[1] = rand(min_size, max_size)
			size[2] = rand(min_size, max_size)

			pos[1] = rand(1, world.maxx - size[1])
			pos[2] = rand(1, world.maxy - size[2])

			turfs |= (block(locate(pos[1], pos[2], 1), locate(pos[1] + size[1], pos[2] + size[2], 2)))

		Generate()
			for(var/turf/t in turfs)
				var newtile = new tile (t)
				if(turfs.Find(newtile) == round(turfs.len/2))
					center_turf = newtile
					if(global.season!="Winter")
						center_turf.SpawnSoundEffects()
					else
						center_turf.SpawnSoundEffectsW()

		EdgeBorder()
			for(var/turf/t in turfs)
				var dir
				for(var/turf/adjacent in get_cardinal(t))
					if(adjacent.elevation == t.elevation) continue
					else
						dir += get_dir(t, adjacent)

				if(dir && t.border_type)
					CreateBorder(t, dir)

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


	proc
		SetElevation()
		SpawnResource()
		SpawnSoundEffects()
			if(sfx.len > 0&&global.season!="Winter"&&month!="Tevet")
				var/soundmob/new_sfx = pick(sfx)
				new new_sfx(src)
		SpawnSoundEffectsW()
			if(sfx.len > 0&&global.season=="Winter")
				var/soundmob/new_wsfx = pick(wsfx)
				new new_wsfx(src)

	New(turf/newloc)
		//..()
		if(newloc) SetElevation(newloc.elevation)