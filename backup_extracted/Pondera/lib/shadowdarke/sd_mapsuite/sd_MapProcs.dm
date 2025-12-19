/*
sd_GetEmptyTurf(z, minx = 1, miny = 1, maxx = world.maxx,\
	maxy = world.maxy, maxcount = 0, block = 0)

	Finds an empty nondense turf within a block on a specific z level.

	ARGS:
		z	the z level to search
		maxcount	if set, this proc will abort after maxcount failed
					attempts
		block		if set, the proc will check to be sure the turf
					will not block a passage by seeing if the turf is
					blocked on both North and South or both East
					and West
	RETURNS: the found turf or null

sd_PathTurfs(turf/start, turf/end, pathtype, min_width = 1,\
	max_width = 1, jaggedness=0, w_variance = 0, taper = 0)

	Creates a path from start to end. Intended For creating anything
	from a narrow dungeon corridors to winding caverns of varying width.

	ARGS:
		start			- beginning of the path
		end				- end of the path
		pathtype *		- If set, all turfs in this path will be
							replaced by a turf of pathtype
							DEFAULT: null
		min_width *		- minimum width of the path.
							DEFAULT: 1
		max_width *		- maximum width of the path/
							DEFAULT: 1
		jaggedness	*	- percent chance per diagonal step that the
							path will turn.
							DEFAULT: 0
		w_variance *	- percent chance per step that the width of
							the path will fluctuate.
							DEFAULT: 0
		taper *			- if set, the ends of the path will taper off

	RETURNS: list of all turfs in the path
*/

proc
	sd_PathTurfs(turf/start, turf/end, pathtype, min_width = 1,\
		max_width = 1, jaggedness=0, w_variance = 0, taper = 0)
	/* Creates a path from start to end of pathtype.
		ARGS:
			start			- beginning of the path
			end				- end of the path
			pathtype *		- If set, all turfs in this path will be
								replaced by a turf of pathtype
								DEFAULT: null
			min_width *		- minimum width of the path.
								DEFAULT: 1
			max_width *		- maximum width of the path/
								DEFAULT: 1
			jaggedness	*	- percent chance per diagonal step that the
								path will turn.
								DEFAULT: 0
			w_variance *	- percent chance per step that the width of
								the path will fluctuate.
								DEFAULT: 0
			taper *			- if set, the ends of the path will taper off
		RETURNS: list of all turfs in the path. The value associated with
			each turf is the direction the path takes through this turf. */
		var
			d
			turf/loc = start
			dir = get_dir(loc, end)
			width = rand(min_width, max_width)
			w = (width - 1) / 2
			lo = round(w)
			hi = round(w + 0.5)
			list
				effected = list()
				strip

		if(dir&dir-1)	// diagonal
			if(prob(50))
				dir &= 12	// East / west
			else
				dir &= 3	// North / south

		do
			if(dir&3)
				strip = block(locate(max(1,loc.x - lo), loc.y, loc.z), \
					locate(min(loc.x + hi,world.maxx), loc.y, loc.z))
			else
				strip = block(locate(loc.x, max(1, loc.y - lo), loc.z), \
					locate(loc.x, min(loc.y + hi, world.maxy), loc.z))

			// prevent multiple instances of the same turf in effected
			for(var/turf/T in strip)
				effected[T] = dir

			if(prob(w_variance))
				width += pick(-1,1)
				width = max(min_width, min(max_width, width))
				w = (width - 1) / 2
				lo = round(w)
				hi = round(w + 0.5)

			if(taper)
				width = max(min_width, min(max_width,width,get_dist(loc,start),get_dist(loc,end)))

			d = get_dir(loc, end)
			if(!(d&dir))
				dir = d
			else if((d&d-1) && prob(jaggedness))
				if(dir&3)
					dir = d&12
				else
					dir = d&3
			loc = get_step(loc,dir)
		while(dir)
		if(pathtype)
			for(var/turf/T in effected)
				new pathtype(T)
		return effected

	sd_GetEmptyTurf(z, minx = 1, miny = 1, maxx = world.maxx, maxy = world.maxy, maxcount = 0, \
		block = 0)
		/* Finds an /turf on a z level.
			z	the z level to search
			maxcount	if set, this proc will abort after maxcount failed
						attempts
			block		if set, the proc will check to be sure the turf
						will not block a passage by seeing if the turf is
						blocked on both North and South or both East
						and West
		*/
		//world << "sd_GetEmptyTurf([z], [minx], [miny], [maxx], [maxy], [maxcount], [block])"
		var/turf/T
		var/count = 0
		var/list/possibleturfs = block(locate(minx, miny, z), locate(maxx, maxy, z))
		while(possibleturfs.len && !T && count<=maxcount)
			if(maxcount) ++count
			T = pick(possibleturfs)
			possibleturfs -= T
			if(T.density || T.contents.len)
				T = null
				continue
			if(block)
				var/dense = 0
				var/dir = 1
				for(var/x = 1 to 4)
					var/turf/check = get_step(T,dir)
					if(!check || check.density)
						dense |= dir
					dir <<= 1

				if((dense&3)==3 || (dense&12)==12)
					T = null

			sleep()
		return T
