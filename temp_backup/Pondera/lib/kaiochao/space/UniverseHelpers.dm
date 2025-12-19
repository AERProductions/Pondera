/* Helper procs for universes.

universe
	Paste(space/space)
		Allocate and paste a space that was just loaded from a savefile.
		Returns the space.

*/

universe
	proc/Paste(space/space)
		if(space)
			Allocate(space)
			space.Paste(space.LowerCorner())
			return space
