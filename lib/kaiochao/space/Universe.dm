/* A collection of spaces, capable of creating new spaces that don't overlap.

universe
	Allocate(width, height, depth)
		Returns a new space of the given size that doesn't overlap any other spaces in this universe.

	Close(space/space)
	universe += space
	universe |= space
		Closes a space so that allocated spaces may not overlap it.

	Open(space/space)
	universe -= space
		Opens a space so that allocated spaces may overlap it.

*/

universe
	var/list/spaces

	New()
		..()
		spaces = new

	proc/Close(space/space)
		spaces[space] = TRUE

	proc/operator+=(x)
		src |= x

	proc/operator|=(x)
		if(istype(x, /space))
			Close(x)

	proc/Open(space/space)
		spaces -= space

	proc/operator-=(x)
		if(istype(x, /space))
			Open(x)

	proc/Allocate(width, height, depth)
		// Return a new space of the desired dimensions in this universe.
		// Also takes a space to allocate using its dimensions and returns it.
		// Spaces are given a 1 tile margin.
		var/space/space

		if(istype(width, /space))
			space = width
			width = space.Width()
			height = space.Height()
			depth = space.Depth()

		world.maxx = max(world.maxx, width)
		world.maxy = max(world.maxy, height)
		world.maxz = max(world.maxz, depth)

		var/lower_x = 1
		var/lower_y = 1
		var/lower_z = 1
		var/to_upper_x = width - 1
		var/to_upper_y = height - 1
		var/to_upper_z = depth - 1
		var/upper_x = lower_x + to_upper_x
		var/upper_y = lower_y + to_upper_y
		var/upper_z = lower_z + to_upper_z

		while(spaces.Remove(null))

		var/space/other
		var/lowest_other_upper_y = 1#INF
		var/lowest_other_upper_z = 1#INF
		do
			var/other_lower_x
			var/other_lower_y
			var/other_lower_z
			var/other_upper_x
			var/other_upper_y
			var/other_upper_z
			for(other as anything in spaces)
				var/turf/other_lower = other.LowerCorner()
				var/turf/other_upper = other.UpperCorner()
				other_lower_x = other_lower.x
				other_lower_y = other_lower.y
				other_lower_z = other_lower.z
				other_upper_x = other_upper.x
				other_upper_y = other_upper.y
				other_upper_z = other_upper.z
				if(IsOverlapping(
						lower_x, lower_y, lower_z,
						upper_x, upper_y, upper_z,
						other_lower_x, other_lower_y, other_lower_z,
						other_upper_x, other_upper_y, other_upper_z))
					break
			if(other)
				lower_x = other_upper_x + 2
				upper_x = lower_x + to_upper_x
				lowest_other_upper_y = min(lowest_other_upper_y, other_upper_y)
				lowest_other_upper_z = min(lowest_other_upper_z, other_upper_z)
				if(upper_x > world.maxx)
					lower_x = 1
					upper_x = width
					lower_y = lowest_other_upper_y + 2
					lowest_other_upper_y = 1#INF
					upper_y = lower_y + to_upper_y
					if(upper_y > world.maxy)
						lower_y = 1
						upper_y = height
						lower_z = lowest_other_upper_z + 2
						lowest_other_upper_z = 1#INF
						upper_z = lower_z + to_upper_z
						if(upper_z > world.maxz)
							world.maxz = upper_z
		while(other)

		var/turf/lower = locate(lower_x, lower_y, lower_z)
		var/turf/upper = locate(upper_x, upper_y, upper_z)
		if(space)
			space.SetCorners(lower, upper)
		else
			space = new(lower, upper)
		Close(space)
		return space

	proc/IsOverlapping(x11, y11, z11, x12, y12, z12, x21, y21, z21, x22, y22, z22)
		// 3D AABB-AABB intersection test
		return \
			z11 <= z22 && z12 >= z21 && \
			y11 <= y22 && y12 >= y21 && \
			x11 <= x22 && x12 >= x21
