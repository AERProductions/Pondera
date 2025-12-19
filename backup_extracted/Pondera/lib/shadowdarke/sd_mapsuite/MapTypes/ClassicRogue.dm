/* sd_MapMaker/ClassicRogue
	by: Shadowdarke (shadowdarke@hotmail.com)

	A classic rogue-like map: several rooms in a loose grid with
		passages between them.
*/
sd_MapMaker/ClassicRogue
	node_x = 10
	node_y = 10
	passage_chance = 100
	no_deadends = 0
	var
		// if room_x or room_y are 0, there will be no rooms
		min_w = 1	// minimum horizontal size of a room
		min_h = 1	// minimum vertical size of a room

		max_w = 10	// maximum horizontal size of a room
		max_h = 10	// maximum vertical size of a room

		path_min = 1	// minimum width of the paths
		path_max = 1	// maximum width ot the paths
		path_vary = 0
		path_jag = 20
		path_taper = 0

		list
			rooms = list()	// list of all room datums
			roomturfs = list()	// list of all room turfs
			passages = list()	// list of all passage turfs
			portals = list()	// list of portals between a room and passage
			roomtypes = list(/sd_MapRoom)	// list of /sd_MapRoom types to pick() from

	BuildMatrix()
		var/SizX = 2 * round((HiX - LoX + 1)/node_x) + 1
		var/SizY = 2 * round((HiY - LoY + 1)/node_y) + 1
		matrix = new(SizX,SizY,open_chance, no_deadends, solid_border)

	Matrix2Map()
		// Project the grid onto the real map
		rooms = list()
		roomturfs = list()
		passages = list()
		portals = list()
		var
			sd_MapRoom/R
			sd_mappoint/P
			list
				endpoint[matrix.maxX*matrix.maxY]
				passage_paths = list()
				empty_paths = list()
				protected_walls = list()
				templist
		rooms = new/list(matrix.maxX*matrix.maxY)


		var/list/mapedges = block(locate(LoX,LoY,Z),locate(LoX,HiY,Z))
		mapedges += block(locate(LoX,LoY,Z),locate(HiX,LoY,Z))
		mapedges += block(locate(HiX,LoY,Z),locate(HiX,HiY,Z))
		mapedges += block(locate(LoX,HiY,Z),locate(HiX,HiY,Z))

		// generate endpoints and rooms
		for(var/X = 1 to matrix.maxX)
			for(var/Y = 1 to matrix.maxY)
				var
					index = X + matrix.maxX * (Y - 1)
					width = rand(min_w,max_w)
					height = rand(min_h,max_h)
					corner_x
					corner_y
					rtype = pick(roomtypes)
				width = min(width,node_x - 2)
				height = min(height,node_y - 2)

				P = new(rand(LoX+node_x*X-width-1,LoX+node_x*(X-1)+1),rand(LoY+node_y*Y-height-1,LoY+node_y*(Y-1)+1))
				if((width <= path_min)||(height <= path_min))	// no room, just a point
					sd_MapReport << "<span class=sd_report>matrix:[X],[Y] endpoint:[P.X],[P.Y] no room"
					endpoint[index] = P
					continue
				if(prob(50))	// one co-ord centered, one random
					corner_x = P.X - round(width/2)
					corner_y = P.Y - rand(1,height) + 1
				else
					corner_x = P.X - rand(1,width) + 1
					corner_y = P.Y - round(height/2)
				corner_x = max(min(corner_x,LoX+node_x*X-width-1),LoX+node_x*(X-1)+1)
				corner_y = max(min(corner_y,LoY+node_y*Y-height-1),LoY+node_y*(Y-1)+1)

				R = new rtype(corner_x, corner_y, Z, width, height)
				roomturfs -= R.Turfs()	// initialize R.turfs and prevent duplicates in roomturfs
				roomturfs += R.turfs	// add to roomturfs list
				protected_walls += R.ProtectedZone()
				var/turf/T = pick(R.turfs - mapedges)
				P.X = T.x
				P.Y = T.y
				endpoint[index] = P
				sd_MapReport << "<span class=sd_report>matrix:[X],[Y] endpoint:[P.X],[P.Y] room:[corner_x],[corner_y] - [corner_x+width-1],[corner_y+height-1]"

		roomturfs -= mapedges

		// make paths
		for(var/X = 1 to matrix.maxX)
			for(var/Y = 1 to matrix.maxY)
				var/sd_mappoint/Start = endpoint[X + matrix.maxX * (Y - 1)]
				var/sd_mappoint/End
				P = matrix.MapGrid[X*2][Y*2+1]
				if(P.maptype != sd_MAP_WALL)
					End = endpoint[X + matrix.maxX*Y]
					if(prob(50))	// swap start and end points 50%
						templist = sd_PathTurfs(locate(Start.X,Start.Y,Z),\
							locate(End.X,End.Y,Z),, path_min, path_max,\
							path_jag, path_vary, path_taper)
					else
						templist = sd_PathTurfs(locate(End.X,End.Y,Z),\
							locate(Start.X,Start.Y,Z),, path_min, path_max,\
							path_jag, path_vary, path_taper)
					if(prob(passage_chance))
						passage_paths -= templist	// prevent duplicates
						passage_paths += templist
					else
						empty_paths -= templist	// prevent duplicates
						empty_paths += templist

				P = matrix.MapGrid[X*2+1][Y*2]
				if(P.maptype != sd_MAP_WALL)
					End = endpoint[X+1 + matrix.maxX * (Y-1)]
					if(prob(50))	// swap start and end points 50%
						templist = sd_PathTurfs(locate(Start.X,Start.Y,Z),\
							locate(End.X,End.Y,Z),, path_min, path_max,\
							path_jag, path_vary, path_taper)
					else
						templist = sd_PathTurfs(locate(End.X,End.Y,Z),\
							locate(Start.X,Start.Y,Z),, path_min, path_max,\
							path_jag, path_vary, path_taper)
					if(prob(passage_chance))
						passage_paths -= templist	// prevent duplicates
						passage_paths += templist
					else
						empty_paths -= templist	// prevent duplicates
						empty_paths += templist

		if(passage_chance)	// make portal list
			// store passage turfs not overlapped by rooms
			passages = passage_paths - roomturfs
			passages -= mapedges
			passages -= protected_walls
			var
				dir = 2
				D = 2
				turf/T2
				list
					possible_walls = list()
					protected_passages = list()
			for(var/X in 1 to 8)
				for(var/turf/T in roomturfs)
					T2 = get_step(T,dir)
					while(T2 in passages)
						var/turf/T3 = get_step(T2,dir)
						if(T3 in passages)
							var/turf/T4 = get_step(T2, turn(dir, 90))
							if(T4 in roomturfs)
								T2 = T3
								continue
							T4 = get_step(T2, turn(dir, -90))
							if(T4 in roomturfs)
								T2 = T3
								continue
							passages -= T2
							portals += T2
						else if(X>4 || (T3 in portals))
							protected_passages[T2] = 1
						else
							possible_walls[T2] = 1
						T2 = null
				D = D << 1
				switch(D)
					if(16) dir = NORTH
					if(32) dir = NORTHEAST
					if(64) dir = NORTHWEST
					if(128) dir = SOUTHEAST
					if(256) dir = SOUTHWEST
					else dir = D
			passages -= (possible_walls - protected_passages)

		empty_paths -= roomturfs
		passages -= empty_paths
		passages += empty_paths
		passages -= mapedges
		passages -= protected_walls

		var/list/final_door_check = portals.Copy()
		while(final_door_check.len)
			var/turf/T = final_door_check[1]
			final_door_check -= T
			if(istype(T))
				var
					count = 0
					turf/T2
					dir = 1
					list/readd = list()
				for(var/X = 1 to 4)
					T2 = get_step(T, dir)
					if(T2 in passages)
						count++
					else if(T2 in roomturfs)
						count++
					else if(!(T2 in final_door_check) && (T2 in portals))
						readd = T2
					dir <<= 1
				if(count > 2)
					portals -= T
					passages += T
					final_door_check += readd


		for(var/turf/T in roomturfs + passages)
			new map_floor(T)

		for(var/turf/T in portals)
			new map_passage(T)

		if(fill_excess)
			var/list/excessturfs = block(locate(LoX,LoY,Z),locate(HiX,HiY,Z))
			excessturfs -= (roomturfs + passages + portals)
			if(solid_border)
				for(var/turf/T in excessturfs)
					new map_wall(T)
			else
				for(var/turf/T in excessturfs)
					new map_floor(T)
