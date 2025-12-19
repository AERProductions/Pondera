sd_MapRoom/iso_triangle
	var
		dir

	Turfs()
		var
			a = width/2		// x radius
			b = height
			h = x + a - 0.5	// center x
			k = y
			X
			Y
		if(!dir) dir = rand(1,4)
		if(dir<3)
			a = width
			b = height / 2
			h = x
			k = y + b - 0.5
		for(X = 0 to a)
			Y = abs(b * (1 - X/a))
			switch(dir)
				if(1)	// right
					turfs += block(locate(x+X, k+Y, z),locate(x+X, k-Y, z))
				if(2)	// left
					turfs += block(locate(x+width-X, k+Y, z),locate(x+width-X, k-Y, z))
				if(3)	// up
					turfs += block(locate(h+X, y, z),locate(h+X, y+Y, z))
					if(X) turfs += block(locate(h-X, y, z),locate(h-X, y+Y, z))
				else	// down
					turfs += block(locate(h+X, y+height-Y, z),locate(h+X, y+height, z))
					if(X) turfs += block(locate(h-X, y+height-Y, z),locate(h-X, y+height, z))

		return turfs

