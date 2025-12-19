sd_MapRoom/maze
	var
		border_x = 1
		border_y = 1
		node_x = 1
		node_y = 1
		open_chance = 0
		no_deadends = 0
		clear_columns = 0
	Turfs()
		if(!turfs || !turfs.len)
			turfs = list()
			// the +- 1 represents the border of the
			var/SizX = round((width - border_x)/(node_x + border_x))
			var/SizY = round((height - border_y)/(node_y + border_y))
			width = SizX * (node_x + border_x) + node_x
			height = SizY * (node_y + border_y) + node_y
			SizX = 2 * SizX + 3
			SizY = 2 * SizY + 3
			var/sd_MapMatrix/matrix = new(SizX,SizY,open_chance, 0, no_deadends, 0)
			matrix.Connect()

			// Project the grid onto the real map
			var/sd_mappoint/point
			var/nodetype
			var/LX,HX,LY,HY

			// ignore the outside borders
			for(var/X = 2, X < matrix.SizX, X++)
				for(var/Y = 2, Y < matrix.SizY, Y++)
					point = matrix.MapGrid[X][Y]
					nodetype = ((X&1)*2) + (Y&1)
					/* nodetypes:
						31113	0 - actual node (node_x x node_y)
						20002	1 - horizontal strip (node_x x 1)
						20002	2 - vertical strip (1 x node Y)
						31113	3 - horizontal strip (1 x 1)
					*/
					// world << "X:[X] Y:[Y] nodetype:[nodetype]"
					if(point.maptype == sd_MAP_EMPTY)
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
								HY = LY + border_y - 1
							if(2)	// vertical strip
								LX = round(X / 2) * (node_x + border_x) + 1
								HX = LX + border_x - 1
								HY = round(Y / 2) * (node_y + border_y)
								LY = HY - node_y + 1
							if(3)	// single space (column)
								LX = round(X / 2) * (node_x + border_x) + 1
								HX = LX + border_x - 1
								LY = round(Y / 2) * (node_y + border_y) + 1
								HY = LY + border_y - 1
								if(clear_columns) matrix.checkcolumn(point)

						for(var/Xloc = LX, Xloc <=HX, Xloc++)
							for(var/Yloc = LY, Yloc <=HY, Yloc++)
								// world << "[LoX+Xloc-1],[LoY+Yloc-1]"
								turfs += locate(x+Xloc-border_x-1,y+Yloc-border_y-1,z)

		return turfs

	ProtectedZone()
		return block(locate(x+1,y+1,z),locate(x+width-2,y+height-2,z))

	double_wide
		border_x = 2
		border_y = 2
		node_x = 2
		node_y = 2
