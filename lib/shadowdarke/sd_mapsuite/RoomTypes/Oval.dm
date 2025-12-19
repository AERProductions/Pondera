sd_MapRoom/oval
	Turfs()
		var
			a = width/2		// x radius
			b = height/2	// y radius
			h = x + a - 0.5	// center x
			k = y + b - 0.5	// center y
			s
			X
			Y

		for(X = 0 to a)
			s = X/a
			Y = abs(b * sqrt(1 - (s*s)))
			turfs += block(locate(h+X, k-Y, z),locate(h+X, k+Y, z))
			if(X) turfs += block(locate(h-X, k-Y, z),locate(h-X, k+Y, z))

		return turfs

