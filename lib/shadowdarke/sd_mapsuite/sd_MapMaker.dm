var
	// These global variables control how the MapMaker behaves.

	sd_MAP_PAUSE_LIMIT = 2000
		/* MAP_PAUSE_LIMIT is the number of mapchecking operations before
		the map routines will sleep. Set this value lower to decrease
		server lag when making maps. Set it higher to make the maps
		faster in real time by sacrificing CPU power. */

	sd_MapReport = null
		/* where to report mapmaking information. If null, no info will be reported */

sd_MapMaker
	var
		open_chance = 0
			// percentage chance that a node border could be open

		passage_chance = 0
			/* percentage chance that open node borders will be a passage
			instead of empty space */

		node_x = 3	// horizontal size of a node
		node_y = 3	// vertical size of a node

		no_deadends = 1
			/* if set, mapmaker will make sure there are no dead ends in the
			new map */

		solid_border = 1
			// If set, the outside map border will be solid walls.
		fill_excess = 1
			/* if set, MapMaker will fill the excess map space (outside the
			nodes, but inside the map zone) with walls (if solid_border
			is set) or empty floor */

		map_wall	// Set this to be the turf TYPE for walls
		map_floor	// Set this to be the turf TYPE for empty floors
		map_passage
			// Set this to be the turf TYPE for passages (i.e. doors)

		LoX
		HiX
		LoY
		HiY
		Z

		/*****************/
		/* internal vars */
		/*****************/
		status		/* Current status of the map making process.
						null - no activity */
		sd_MapMatrix/matrix	// connectivity matrix


	New(LX = 1, HX = world.maxx, LY = 1 as num,\
		HY = world.maxy as num, nZ = 1 as num)
		/*
		FORMAT:
			New(LoX, HiX, LoY, HiY, Z) or
			New(atom/Corner1, atom/Corner2)
			 */

		if(istype(LX,/atom))
			var/atom/A = LX
			LoX = A.x
			LoY = A.y
			Z = A.z
			if(!istype(HX,/atom)) CRASH("sd_MapSuite.Generate(): mismatched arguments")
			A = HX
			HiX = A.x
			HiY = A.y
			if(A.z != Z) CRASH("This version of sd_MapSuite does not support 3 dimensional maps.")
		else
			LoX = LX
			LoY = LY
			HiX = HX
			HiY = HY
			Z = nZ

		// prevent wrong ordered numbers
		if(LoX > HiX)
			var temp = HiX
			HiX = LoX
			LoX = temp
		if(LoY > HiY)
			var temp = HiY
			HiY = LoY
			LoY = temp

		// make sure the coords are valid
		if((LoY < 1) || (LoX < 1) || (HiX > world.maxx) || (HiY > world.maxy)\
		|| (Z < 1) || (Z > world.maxz))
			CRASH("Invalid sd_MakeMazer co-ordinates")

	proc
		Generate()
			/* Generate the maze. */

			if(status)
				sd_MapReport << "<span class=sd_report>Already generating a map. Please wait\
				 until it is finished."
				return 0

			status = "generating"
			// set timers
			var/begin = world.realtime
			var/ticks = world.time

			sd_MapReport << "<span class=sd_report>sd_MazeMaker: [src] ([LoX],[LoY],[Z])-([HiX],[HiY],[Z])"

			BuildMatrix()
			if(matrix)
				matrix.Connect()
				Matrix2Map()
				status = null
				sd_MapReport << "<span class=sd_report>Done with map ([Z])!\nTime:[(world.realtime-begin)/10]s \
					[world.time-ticks+1] ticks"

				return 1
			status = null

		BuildMatrix()
			/* Stub proc generates the connectivity matrix
				and produces forced openings such as the "rooms" in the
				the FullMaze type.
				Override this when you make a custom map type.*/
			status = "building"

		Matrix2Map()
			/* Stub proc for projecting a matrix onto the game map.
				Override this when you make a custom map type.*/
			status = "projecting"
