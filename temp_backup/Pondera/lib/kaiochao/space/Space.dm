/* A section of the map. Can be copied and pasted somewhere else.

space
	New(turf/corner1, turf/corner2)
		A new space with its corners set to the given corners.

	New(space/space)
		A new space with the same corners as another.

	New(list/turfs)
		A new space containing a given list of turfs.

	Write(savefile/save)
		Called automatically when written to a savefile.
		Copies a space to the savefile.

	Read(savefile/save)
		Called automatically when read from a savefile.
		Copies the saved clipboard to the space's clipboard, ready to be pasted into the world.

	SetCorners(turf/corner1, turf/corner2)
		Sets the corners. Shape includes all turfs in the block.

	SetTurfs(list/turfs)
		Sets the turfs to a list of turfs.
		May be an irregular shape, not necessarily an axis-aligned box.

	LowerCorner()
		Get the turf with the minimum coordinates of the extents of the space.
		For spaces of irregular shapes, this may not be in the space.

	UpperCorner()
		Get the turf with maximum coordinates of the extents of the space.
		For spaces of irregular shapes, this may not be in the space.

	Turfs()
		Get a list of all turfs in the space.

	Width()
		Span of turfs in the x axis.

	Height()
		Span of turfs in the y axis.

	Depth()
		Span of turfs in the z axis.

	Copy()
		Copies the turfs to the space's clipboard.

	Paste(turf/lower)
		Recreates the clipboard at a specified location.
*/

space
	var/tmp/turf/lower_corner
	var/tmp/turf/upper_corner
	var/tmp/list/turfs

	// Savefile containing the clipboard
	var/tmp/savefile/clipboard

	// When loaded from a savefile, this is the cd within that savefile of the clipboard
	var/tmp/clipboard_cd = "/clipboard"

	var/width
	var/height
	var/depth

	New(turf/corner1, turf/corner2)
		..()
		if(isturf(corner1, corner2))
			SetCorners(corner1, corner2)
		else if(istype(corner1, /space))
			var/space/space = corner1
			SetTurfs(space.Turfs())
		else if(istype(corner1, /list))
			SetTurfs(corner1)

	Write(savefile/save)
		..()
		save.cd = "clipboard"
		WriteMapTo(save)
		save.cd = ".."

	Read(savefile/save)
		..()
		clipboard = save
		clipboard_cd = "[save.cd]/clipboard"

	proc/SetCorners(turf/corner1, turf/corner2)
		var/turf/lower = locate(
			min(corner1.x, corner2.x),
			min(corner1.y, corner2.y),
			min(corner1.z, corner2.z))
		var/turf/upper = locate(
			max(corner1.x, corner2.x),
			max(corner1.y, corner2.y),
			max(corner1.z, corner2.z))
		if(lower_corner != lower || upper_corner != upper)
			lower_corner = lower
			upper_corner = upper
			if(lower_corner && upper_corner)
				width = 1 + upper_corner.x - lower_corner.x
				height = 1 + upper_corner.y - lower_corner.y
				depth = 1 + upper_corner.z - lower_corner.z
				turfs = block(lower_corner, upper_corner)
			else
				width = height = depth = 0
				turfs = list()

	proc/SetTurfs(list/turfs)
		if(!length(turfs))
			src.turfs = list()
			width = height = depth = 0
			lower_corner = upper_corner = null
			return
		src.turfs = new
		var/lower_x = 1#INF
		var/lower_y = 1#INF
		var/lower_z = 1#INF
		var/upper_x = -1#INF
		var/upper_y = -1#INF
		var/upper_z = -1#INF
		for(var/turf/turf in turfs)
			src.turfs += turf
			lower_x = min(lower_x, turf.x)
			lower_y = min(lower_y, turf.y)
			lower_z = min(lower_z, turf.z)
			upper_x = max(upper_x, turf.x)
			upper_y = max(upper_y, turf.y)
			upper_z = max(upper_z, turf.z)
		lower_corner = locate(lower_x, lower_y, lower_z)
		upper_corner = locate(upper_x, upper_y, upper_z)
		width = 1 + upper_x - lower_x
		height = 1 + upper_y - lower_y
		depth = 1 + upper_z - lower_z

	proc/LowerCorner()
		return lower_corner

	proc/UpperCorner()
		return upper_corner

	proc/Width()
		return width

	proc/Height()
		return height

	proc/Depth()
		return depth

	proc/Turfs()
		return turfs

	proc/Copy()
		// Copy to clipboard
		WriteMapTo(clipboard)

	proc/WriteMapTo(savefile/savefile)
		// Where the space is
		var/turf/lower = LowerCorner()

		if(!(lower && UpperCorner()))
			// Nothing to save
			return

		if(!savefile)
			// Copy to clipboard
			savefile = clipboard = new

		clipboard_cd = savefile.cd

		var/x_offset = lower.x - 1
		var/y_offset = lower.y - 1
		var/z_offset = lower.z - 1

		// Move all non-saved atoms out of the space
		var/list/movable_locs = new
		var/list/turf_to_contents = new
		var/list/turf_to_saved_contents = new

		for(var/turf/turf as anything in Turfs())
			var/list/contents = turf.contents.Copy()
			var/list/saved_contents = new
			for(var/atom/movable/movable as anything in contents)
				if(movable.loc == turf)
					if(movable.SavesToSpace())
						saved_contents += movable
				else
					contents -= movable
				movable_locs[movable] = turf
				movable.loc = null
			if(contents.len)
				turf_to_contents[turf] = contents
			if(saved_contents.len)
				turf_to_saved_contents[turf] = saved_contents

		// Iterate over all turfs in the space by local coordinates
		var/list/area_to_index = new
		for(var/turf/turf as anything in Turfs())
			var/z = turf.z - z_offset
			var/y = turf.y - y_offset
			var/x = turf.x - x_offset
			var/cd = "[num2text(x)]_[num2text(y)]_[num2text(z)]"

			savefile.cd = cd

			// Save the index of the area at this coordinate
			var/area/area = turf.loc
			if(area.SavesToSpace() && area.type != world.area)
				var area_index = area_to_index[area] || (area_to_index[area] = area_to_index.len + 1)
				savefile["area"] << area_index

			// Save the turf at this coordinate
			if(turf.SavesToSpace() && turf.type != world.turf)
				savefile["type"] << turf.type

			// Temporarily return saved contents to this turf
			var/list/saved_contents = turf_to_saved_contents[turf]
			for(var/atom/movable/movable as anything in saved_contents)
				movable.loc = turf

			// Save the turf vars
			savefile.cd = "vars"
			if(turf.SavesToSpace())
				turf.Write(savefile)
			else if(saved_contents)
				savefile["contents"] << saved_contents
			if(!savefile.dir.len)
				savefile.cd = ".."
				savefile.dir -= "vars"
			else
				savefile.cd = ".."

			// Remove the saved contents from the turf
			for(var/atom/movable/movable as anything in turf_to_saved_contents[turf])
				movable.loc = null

			if(!savefile.dir.len)
				savefile.cd = ".."
				savefile.dir -= cd
			else
				savefile.cd = ".."

		// Store all areas in order of index
		var/list/areas = new
		areas.Insert(1, area_to_index)
		for(var/area/area as anything in areas)
			area.saving_to_space++
		if(areas.len)
			savefile["areas"] << areas
		for(var/area/area as anything in areas)
			area.saving_to_space--

		// Return movables back to their previous locs
		for(var/atom/movable/movable in movable_locs)
			movable.loc = movable_locs[movable]

	proc/Paste(turf/lower)
		// Paste map data from clipboard onto the map relative to a lower corner.

		if(!clipboard)
			CRASH("No data to paste.")

		var/old_cd = clipboard.cd

		// Enter the clipboard data directory
		clipboard.cd = clipboard_cd

		// Load areas
		var/list/areas
		var/area/default_area = locate(world.area) || new world.area
		clipboard["areas"] >> areas

		// Where the loaded space goes
		var/x_offset = lower.x - 1
		var/y_offset = lower.y - 1
		var/z_offset = lower.z - 1

		// Load the turf at each coordinate
		for(var/z in 1 to depth) for(var/y in 1 to height) for(var/x in 1 to width)
			// Enter the turf index
			clipboard.cd = "[clipboard_cd]/[x]_[y]_[z]"

			// Load turf
			var/turf_type
			clipboard["type"] >> turf_type
			turf_type = turf_type || world.turf
			var turf/turf = new turf_type(locate(x + x_offset, y + y_offset, z + z_offset))

			// Load area to put turf into
			var/area_index
			clipboard["area"] >> area_index
			if(area_index)
				var/area/area = areas[area_index]
				area.contents += turf
			else
				default_area.contents += turf

			// Load turf vars, if any
			if("vars" in clipboard.dir)
				clipboard.cd = "vars"
				turf.Read(clipboard)
				clipboard.cd = ".."

		// Exit the clipboard
		clipboard.cd = old_cd
