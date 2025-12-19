/* sd_MapMaker/FullMaze
	by: Shadowdarke (shadowdarke@hotmail.com)

Important concepts:

* Mazes are divided into 3 types of spaces for purposes of this MapMaker,
nodes, borders, and columns.
	Nodes - Nodes are always open floor space. The spaces on all 4 sides
		of a node are borders, and are diagonal to columns.
	Borders - Borders are the spaces between nodes. They may be a solid wall,
		empty space, or a wall with a passage going through it.
	Columns - Columns are walls, unless cleared as part of a ROOM, or with
		the clearcoloumns setting. When clear_columns is set, columns may
		become empty floor space if all 4 adjacent borders are empty.

* Rooms are special areas of empty floor spaces. If you are using node sizes
	greater than 1x1, rooms will appear distorted. (I don't recomend using
	rooms with larger node sizes.) If you don't want these room areas to
	be created, set room_x or room_y to 0.
*/
sd_MapMaker/FullMaze
	var
		// if room_x or room_y are 0, there will be no rooms
		room_x = 0	// maximum horizontal size of a room
		room_y = 0	// maximum vertical size of a room

		border_x = 1	// horizontal thickness of border spaces
		border_y = 1	// vertical thickness of border spaces

		clear_columns = 0
			/* percent chance that the mapmaker will remove any walls that are
			completely surrounded by empty floors */
		check_passage = 100
			/* percent chance that passages will not be made through borders
				which extend to nowhere */

	BuildMatrix()
		var/SizX = 2 * round((HiX - LoX - border_x + 1)/(node_x + border_x)) + 1
		var/SizY = 2 * round((HiY - LoY - border_y + 1)/(node_y + border_y)) + 1
		matrix = new(SizX,SizY,open_chance, no_deadends, solid_border)
		if(room_x && room_y) makerooms(matrix)

	Matrix2Map()
		// Project the grid onto the real map
		var/sd_mappoint/point
		var/turf/Turf
		var/nodetype
		var/LX,HX,LY,HY,PX,PY
		for(var/X = 1, X <= matrix.SizX, X++)
			for(var/Y = 1, Y <= matrix.SizY, Y++)
				Turf = locate(X,Y,Z)
				point = matrix.MapGrid[X][Y]
				nodetype = ((X&1)*2) + (Y&1)
				/* nodetypes:
					31113	0 - actual node (node_x X node_y)
					20002	1 - horizontal strip (node_x X border_y)
					20002	2 - vertical strip (border_x X node_y)
					31113	3 - column (border_x X border_y)
				*/
				// world << "X:[X] Y:[Y] nodetype:[nodetype]"
				switch(nodetype)
					if(0)	// node
						HX = round(X / 2) * (node_x + border_x)
						LX = HX - node_x + 1
						HY = round(Y / 2) * (node_y + border_y)
						LY = HY - node_y + 1
					if(1)	// horizontal strip
						HX = round(X / 2) * (node_x + border_x)
						LX = HX - node_x + 1
						LY = round(Y / 2) * (node_y + border_y) + 1
						//LY = round(Y/2)*(node_y+1)+1
						HY = LY + border_y - 1
						PX = rand(LX,HX)
						PY = 0
						if((point.maptype == sd_MAP_EMPTY) && prob(passage_chance))
							if(!(prob(check_passage) && (
								(matrix.floorcount(matrix.MapGrid[X-1][Y])>3) || \
								(matrix.floorcount(matrix.MapGrid[X+1][Y])>3)
							)))
								point.maptype = sd_MAP_PASSAGE
					if(2)	// vertical strip
						LX = round(X / 2) * (node_x + border_x) + 1
						//LY = round(Y/2)*(node_y+1)+1
						HX = LX + border_x - 1
/*
						LX = round(X/2)*(node_x+1)+1
						HX = LX
*/
						HY = round(Y / 2) * (node_y + border_y)
						LY = HY - node_y + 1
						PX = 0
						PY = rand(LY,HY)
						if((point.maptype == sd_MAP_EMPTY) && prob(passage_chance))
							if(!(prob(check_passage) && (
								(matrix.floorcount(matrix.MapGrid[X][Y-1])>3) || \
								(matrix.floorcount(matrix.MapGrid[X][Y+1])>3)
							)))
								point.maptype = sd_MAP_PASSAGE
					if(3)	// single space (column)
						LX = round(X / 2) * (node_x + border_x) + 1
						HX = LX + border_x - 1
						LY = round(Y / 2) * (node_y + border_y) + 1
						HY = LY + border_y - 1
						if(prob(clear_columns)) matrix.checkcolumn(point)

				for(var/Xloc = LX, Xloc <=HX, Xloc++)
					for(var/Yloc = LY, Yloc <=HY, Yloc++)
						// world << "[LoX+Xloc-1],[LoY+Yloc-1]"
						Turf = locate(LoX+Xloc-1,LoY+Yloc-1,Z)
						switch(point.maptype)
							if(sd_MAP_WALL)
								Turf = new map_wall(Turf)
							if(sd_MAP_EMPTY)
								Turf = new map_floor(Turf)
							if(sd_MAP_PASSAGE)
								if((Xloc == PX) || (Yloc == PY))
									Turf = new map_passage(Turf)
								else
									Turf = new map_wall(Turf)

		HX += LoX-1
		HY += LoY-1
		if(fill_excess)
			var/filler = map_wall
			if(!solid_border) filler = map_floor
			if(HY < HiY)
				for(var/Xloc = LoX, Xloc <= HiX, Xloc++)
					for(var/Yloc = HY+1, Yloc <= HiY, Yloc++)
						Turf = locate(Xloc,Yloc,Z)
						Turf = new filler(Turf)
			if(HX < HiX)
				for(var/Xloc = HX+1, Xloc <= HiX, Xloc++)
					for(var/Yloc = LoY, Yloc <= HiY, Yloc++)
						Turf = locate(Xloc,Yloc,Z)
						Turf = new filler(Turf)

	proc
		makerooms(sd_MapMatrix/matrix)
			var/numX = matrix.SizX/room_x
			var/numY = matrix.SizY/room_y
			var/sd_mappoint/P
			for(var/curX=0, curX<numX, ++curX)
				for(var/curY=0, curY<numY, ++curY)
					switch(rand(1,2))
						if(1)	// rectangular room
							var loX = curX*room_x + rand(1,room_x)
							var hiX = curX*room_x + rand(1,room_x)
							if(loX>hiX)
								var T=loX
								loX=hiX
								hiX=T
							if(loX<2) loX = 2
							if(loX>matrix.SizX-1) loX = matrix.SizX-1
							if(hiX>matrix.SizX-1) hiX = matrix.SizX-1
							var loY = curY*room_y + rand(2,room_y)
							var hiY = curY*room_y + rand(2,room_y)
							if(loY>hiY)
								var T=loY
								loY=hiY
								hiY=T
							if(loY<2) loY = 2
							if(loY>matrix.SizY-1) loY = matrix.SizY-1
							if(hiY>matrix.SizY-1) hiY = matrix.SizY-1
							for(var/X=loX, X<=hiX,++X)
								for(var/Y=loY, Y<=hiY,++Y)
									//world << "[X],[Y]"
									P = matrix.MapGrid[X][Y]
									P.maptype = sd_MAP_EMPTY

						if(2)	// circular room
							var radius = rand(1,min(room_x/2,room_y/2))
							var loX = curX*room_x + rand(radius,room_x-radius)
							var loY = curY*room_y + rand(radius,room_y-radius)
							for(var/X=loX-radius, X<=loX+radius,++X)
								for(var/Y=loY-radius, Y<=loY+radius,++Y)
									//world << "[X],[Y]"
									if((X<2) || (Y<2) || (X>matrix.SizX-1) || (Y>matrix.SizY-1))
										continue
									if(radius>sqrt((X-loX)*(X-loX)+(Y-loY)*(Y-loY)))
										P = matrix.MapGrid[X][Y]
										P.maptype = sd_MAP_EMPTY
