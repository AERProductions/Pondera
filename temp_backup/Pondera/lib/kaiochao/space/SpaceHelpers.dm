/* Helper procs for spaces.

space
	Locate(x, y, z)
		The turf at the given coordinates relative to the lower corner.
		The lower corner is Locate(1, 1, 1).
		The upper corner is Locate(Width(), Height(), Depth()).

	Contains(atom)
		Does this space contain this atom?

	FindWithTag(tag)
		First atom with the given tag contained by this space.

	Duplicate(turf/lower)
		Copy, then paste.

*/

space
	proc/Locate(x, y, z)
		var/turf/lower = LowerCorner()
		var/turf/found = locate(x + lower.x - 1, y + lower.y - 1, z + lower.z - 1)
		return Contains(found) ? found : null

	proc/Contains(atom/atom)
		if(!isloc(atom)) 
			return FALSE
		if(isturf(atom)) 
			return atom in Turfs()
		if(isarea(atom)) 
			return length(atom.contents & Turfs()) > 0
		return get_step(atom, 0) in Turfs()

	proc/FindWithTag(tag)
		var/list/others = new
		var/datum/found
		do
			found = locate(tag)
			if(Contains(found))
				break
			found.tag = null
			others += found
		while(found)
		for(var/datum/other as anything in others)
			other.tag = tag
		return found

	proc/Duplicate(turf/lower)
		Copy()
		Paste(lower)
