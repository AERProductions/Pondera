sd_MapRoom/rectangle
	// specialized for a more efficient Border() routine
	Border(Dirs)
		if(!(turfs && turfs.len)) Turfs()
		var
			xlo = x
			xhi = x+width
			ylo = y
			yhi = y+height
		if(!(Dirs&NORTH))	yhi--
		if(Dirs&SOUTH)		ylo--
		if(!(Dirs&EAST))	xhi--
		if(Dirs&WEST)		xlo--
		return block(locate(xlo,ylo,z),locate(xhi,yhi,z)) - turfs
