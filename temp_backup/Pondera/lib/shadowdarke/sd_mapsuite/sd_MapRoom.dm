/* sd_MapRoom is a datum type to track rooms of various sizes and shapes.

sd_MapRoom
	vars
		x, y, z		cordinates of the bottom southwest corner of the room
		width		width of the room
		height		height of the room
		turfs		list of all turfs inside the room. This is null until the Turfs() proc
						is called.

	procs
		New(X,Y=1,Z=1,Width=1,Height=1)
		New(atom/A, Width = 1, Height = 1
			create a new room with a lower left corner at X, Y, Z or atom A, width of
			Width, and height of Height
		Turfs()
			Initializes the room's turfs list and returns a list of all turfs in the room.

		Fill(turftype)
			Replaces in the room with the specified turftype.

		Border(Dirs = 15)
			Returns a list of turfs bordering the room in direction Dirs. Dirs = 15 means
			to return the border in all directions.
*/

sd_MapRoom
	var
		x
		y
		z
		width
		height
		list
			turfs

	New(X,Y=1,Z=1,Width=1,Height=1)
		..()
		if(istype(X,/atom))
			var/atom/A = X
			x = A.x
			y = A.y
			z = A.z
			width = Y
			height = Z
		else
			x = X
			y = Y
			z = Z
			width = Width
			height = Height

	proc
		Turfs()
			/* returns a list of turfs in the room. Override this proc to
				produce rooms of different shapes. */
			if(!turfs || !turfs.len) turfs = block(locate(x,y,z),locate(x+width-1,y+height-1,z))
			return turfs

		Fill(turftype)
			/* Fills the room with a specific turf type and returns the
				list of turfs in the room. */
			if(!(turfs && turfs.len)) Turfs()
			for(var/turf/T in turfs)
				new turftype(T)
			return turfs

		Border(Dirs = 15)
			/* returns a list of turfs around the room.
				Dirs	- filter of directions to check.
							for example Dirs = EAST will return turfs
							that border east side of the room
			*/
			var/list/border

			for(var/turf/T in turfs)
				var
					dir = 1
					D = 1
					turf/T2
				for(var/X in 1 to 8)
					if(dir&Dirs)
						world >> dir
						T2 = get_step(T,dir)
						if(!(T2 in turfs))
							border[T2] = dir
					D = D << 1
					switch(D)
						if(16) dir = NORTHEAST
						if(32) dir = NORTHWEST
						if(64) dir = SOUTHEAST
						if(128) dir = SOUTHWEST
						else dir = D
			return border

		ProtectedZone()
			/* Returns a list of turfs that a passage should not be allowed to pass
				through within the room */