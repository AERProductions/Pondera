/*

*/

sd_MapMatrix
	var
		Z = 0
		SizX = 0
		SizY = 0
		maxX = 0
		maxY = 0
		list/MapGrid[][]
		recurse = 0
		pausecheck = 0
		open_chance
		solid_border
		no_deadends

	New(SX, SY, openchance = 0, nodeadends = 0, solidborder = 1)
		..()
		SizX = SX
		SizY = SY
		open_chance = openchance
		no_deadends = nodeadends
		solid_border = solidborder

		var/list/templist[SizX][SizY]
		MapGrid = templist
		for(var/X = 1, X <= SizX, X++)
			for(var/Y = 1, Y <= SizY, Y++)
				//world << "[X],[Y]"
				MapGrid[X][Y] = new/sd_mappoint(X,Y)	// initilize MapGrid

		maxX = round(SizX/2,1) - 1	// leave room for the border
		maxY = round(SizY/2,1) - 1	// leave room for the border

		// make passages
		var/sd_mappoint/P
		for(var/X = 1, X <= maxX, ++X)
			if(!solid_border)
				P = MapGrid[X*2][1]
				P.maptype = sd_MAP_EMPTY
				P = MapGrid[X*2][SizY]
				P.maptype = sd_MAP_EMPTY

			for(var/Y = 1, Y <= maxY, ++Y)
				// clear definate floor spaces (nodes)
				P = MapGrid[X*2][Y*2]
				P.maptype = sd_MAP_EMPTY
				if((X < maxX) && prob(open_chance))	// make horizontal passages sometimes
					P = MapGrid[X*2+1][Y*2]
					P.maptype = sd_MAP_EMPTY

				if((Y < maxY) && prob(open_chance))	// make veritcal passages sometimes
					P = MapGrid[X*2][Y*2+1]
					P.maptype = sd_MAP_EMPTY

		if(!solid_border)
			for(var/Y = 1, Y <= maxY, ++Y)
				P = MapGrid[1][Y*2]
				P.maptype = sd_MAP_EMPTY
				P = MapGrid[SizX][Y*2]
				P.maptype = sd_MAP_EMPTY

	proc
		Connect()
			// make sure everything connects
			sd_MapReport << "<span class=sd_report>sd_MapMatrix connecting nodes: [maxX]x[maxY]"

			var/list/border = list()	// list of all the borders between
										// linked nodes and unlinked nodes
			var iteration = 0	// how many times the border has been checked
			// where to begin checking linked nodes
			var/sd_mappoint/start = MapGrid[2][2]
			var/sd_mappoint/rn	// RandomBorder from the border list
			var/sd_mappoint/point

			do	// while(border.len)
				iteration++
				// world << matrix.Z
				FillPoints(start)
				border = borderlist()
				if(border.len)
					// world << "."
					// world << "[border] len [border.len]"
					rn = border[rand(1,length(border))]

					rn.maptype = sd_MAP_EMPTY

					if(rn.X > 1)
						point = MapGrid[rn.X-1][rn.Y]
						if(point.link) start = point
					if(rn.X < SizX)
						point = MapGrid[rn.X+1][rn.Y]
						if(point.link) start = point
					if(rn.Y  > 1)
						point = MapGrid[rn.X][rn.Y-1]
						if(point.link) start = point
					if(rn.Y < SizY)
						point = MapGrid[rn.X][rn.Y+1]
						if(point.link) start = point

			while(border.len)
			return iteration

		borderlist()
			//world << "borderlist"
			var/list/border = list()
			var/sd_mappoint/test
			//world << "[maxX],[maxY]"
			for(var/X = 1, X <= maxX, ++X)
				for(var/Y = 1, Y <= maxY, ++Y)
					if(!(++pausecheck%sd_MAP_PAUSE_LIMIT))
						//if(sd_MapReport) world << ":[pausecheck]"
						sleep()
					var count = 2
					//world << "check"
					if(no_deadends)
						count = 0
						//world << "no_deadends"
						var/list/possible = list()
						if(X>1)
							test = MapGrid[X*2-1][Y*2]
							if(test.maptype != sd_MAP_WALL)
								count++
							else
								possible += test
						if(X < maxX)
							test = MapGrid[X*2+1][Y*2]
							if(test.maptype != sd_MAP_WALL)
								count++
							else
								possible += test
						if(Y > 1)
							test = MapGrid[X*2][Y*2-1]
							if(test.maptype != sd_MAP_WALL)
								count++
							else
								possible += test
						if(Y < maxY)
							test = MapGrid[X*2][Y*2+1]
							if(test.maptype != sd_MAP_WALL)
								count++
							else
								possible += test
						//world << "possible.len:[possible.len] ; count:[count]"
						if(count<2) border += possible
					if(count>=2)	// will be 2 if no_deadends is clear
						test = MapGrid[X*2][Y*2]
						if(test.link) continue	// looking for unlinked locations
						if(X>1)
							test = MapGrid[X*2-2][Y*2]
							if(test.link)
								test = MapGrid[X*2-1][Y*2]
								border += test
						if(X<maxX)
							test = MapGrid[X*2+2][Y*2]
							if(test.link)
								test = MapGrid[X*2+1][Y*2]
								border += test
						if(Y>1)
							test = MapGrid[X*2][Y*2-2]
							if(test.link)
								test = MapGrid[X*2][Y*2-1]
								border += test
						if(Y<maxY)
							test = MapGrid[X*2][Y*2+2]
							if(test.link)
								test = MapGrid[X*2][Y*2+1]
								border += test
			//world << "border list: [border.len]"
			return border

		ExtendPoints(sd_mappoint/cent)
			// world << "extending [cent.X],[cent.Y]"
			var/sd_mappoint/adj
			var/sd_mappoint/border
			var/list/adjList = list()
			if(!(++pausecheck%sd_MAP_PAUSE_LIMIT))
				sleep()

			if((cent.X)>2)
				adj = MapGrid[cent.X-2][cent.Y]
				// world << "adj [adj.X],[adj.Y]"
				border = MapGrid[cent.X-1][cent.Y]
				if(!adj.link && (border.maptype!=sd_MAP_WALL))
					adj.link = 1
					adjList += adj

			if((cent.X+2)<=SizX)
				adj = MapGrid[cent.X+2][cent.Y]
				// world << "adj [adj.X],[adj.Y]"
				border = MapGrid[cent.X+1][cent.Y]
				if(!adj.link && (border.maptype!=sd_MAP_WALL))
					adj.link = 1
					adjList += adj

			if((cent.Y)>2)
				adj = MapGrid[cent.X][cent.Y-2]
				// world << "adj [adj.X],[adj.Y]"
				border = MapGrid[cent.X][cent.Y-1]
				if(!adj.link && (border.maptype!=sd_MAP_WALL))
					adj.link = 1
					adjList += adj

			if((cent.Y+2)<=SizY)
				adj = MapGrid[cent.X][cent.Y+2]
				// world << "adj [adj.X],[adj.Y]"
				border = MapGrid[cent.X][cent.Y+1]
				if(!adj.link && (border.maptype!=sd_MAP_WALL))
					adj.link = 1
					adjList += adj

			// world << "adjList len:[adjList.len]"
			return adjList

		FillPoints(sd_mappoint/cent)
			var/list/centList = list(cent)
			var/list/adjList = list()
			var/sd_mappoint/T

			// world << "centList.len:\..."
			while(centList.len)
				// world << "[centList.len], \..."
				for(T in centList)
					T.link = 1
					adjList.Cut() // clear it
				for(T in centList)
					adjList += ExtendPoints(T)
				centList.Cut() // clear it
				centList += adjList
			// world << " "

		checkcolumn(sd_mappoint/P)
			var/sd_mappoint/testsd_mappoint
			if(P.X > 1)
				testsd_mappoint = MapGrid[P.X-1][P.Y]
				if(testsd_mappoint.maptype != sd_MAP_EMPTY)
					return
			if(P.X < (SizX - 1))
				testsd_mappoint = MapGrid[P.X+1][P.Y]
				if(testsd_mappoint.maptype != sd_MAP_EMPTY)
					return
			if(P.Y > 1)
				testsd_mappoint = MapGrid[P.X][P.Y-1]
				if(testsd_mappoint.maptype != sd_MAP_EMPTY)
					return
			if(P.Y < (SizY - 1))
				testsd_mappoint = MapGrid[P.X][P.Y+1]
				if(testsd_mappoint.maptype != sd_MAP_EMPTY)
					return

			// will only get here if there is a floor on all 4 sides
			P.maptype = sd_MAP_EMPTY


		floorcount(sd_mappoint/P)
			var/count = 0
			var/sd_mappoint/testsd_mappoint
			if(P.X > 1)
				testsd_mappoint = MapGrid[P.X-1][P.Y]
				if(testsd_mappoint.maptype == sd_MAP_EMPTY)
					count++
			if(P.X < (SizX - 1))
				testsd_mappoint = MapGrid[P.X+1][P.Y]
				if(testsd_mappoint.maptype == sd_MAP_EMPTY)
					count++
			if(P.Y > 1)
				testsd_mappoint = MapGrid[P.X][P.Y-1]
				if(testsd_mappoint.maptype == sd_MAP_EMPTY)
					count++
			if(P.Y < (SizY - 1))
				testsd_mappoint = MapGrid[P.X][P.Y+1]
				if(testsd_mappoint.maptype == sd_MAP_EMPTY)
					count++
			return count

sd_mappoint
	var
		X as num
		Y as num
		maptype = sd_MAP_WALL
		link = 0

	New(newX = 0,newY = 0)
		X = newX
		Y = newY
