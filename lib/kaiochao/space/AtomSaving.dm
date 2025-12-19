/* Some considerations for atoms with regards to saving to spaces.

atom
	var
		SavesToSpace()
			Determines whether an atom saves to the space it's in.
			Returns FALSE by default.

	Overrides area's Write() to prevent its contents from being saved to spaces.
*/

#if DM_VERSION < 513
// Save some space in the savefile.
// Before 513, filters would be saved when it didn't need to be.
atom
	Write(savefile/save)
		..()
		if(!length(filters))
			save.dir -= "filters"
#endif

atom
	proc/SavesToSpace()
		return FALSE

area
	var/tmp/saving_to_space = FALSE

	Write(savefile/save)
		if(saving_to_space)
			// Don't save contents at all
			var list/turfs = new
			for(var/turf/turf in src)
				turfs += turf
			contents = null
			..()
			contents += turfs
		else
			..()
