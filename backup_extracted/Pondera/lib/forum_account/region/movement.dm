
// File:    movement.dm
// Library: Forum_account.Region
// Author:  Forum_account
//
// Contents:
//   This file contains the code that makes the region
//   object's Enter, Exit, Entered, and Exited procs work.

mob
	var
		list/__locs

	// Most of this stuff used to be handled in turf/Entered, but I
	// moved it here because I had to handle Enter and Exit here.
	// I didn't like having part of the code in turf/Entered because
	// if you override that proc and don't call ..(), regions won't
	// work. It's common to override mob/Move, but people usually call
	// ..() in Move so people are less likely to break the library.
	Move(turf/new_turf, d = 0, sx = 0, sy = 0)

		// if you're moving pixel-by-pixel we have to handle this a special way
		if(sx || sy)

			// We just support the Entered and Exited procs when you're
			// using pixel movement.

			var/list/old_regions
			var/list/new_regions

			// find the regions you used to be in
			if(__locs)
				old_regions = list()
				for(var/turf/t in __locs)
					for(var/region/r in t.regions)
						old_regions[r] = 1

			. = ..()

			// find the regions you're now in
			if(loc)
				new_regions = list()
				for(var/turf/t in locs)
					for(var/region/r in t.regions)
						new_regions[r] = 1

			if(new_regions)
				if(old_regions)
					// if the old_ and new_regions lists are defined, the
					// regions you're exiting are the regions in old_regions
					// that aren't in new_regions.
					for(var/region/r in old_regions)
						if(new_regions[r]) continue
						r.Exited(src)

					// and if both lists are set, the regions you're entering
					// are the ones you are in, but didn't used to be in.
					for(var/region/r in new_regions)
						if(old_regions[r]) continue
						r.Entered(src)
				else
					// if new_regions is set but old_regions isn't, you're
					// entering every region in the new_regions list.
					for(var/region/r in new_regions)
						r.Entered(src)

			// if old_regions is set and new_regions isn't...
			else if(old_regions)
				// ...you're exiting every region in the old_regions list.
				for(var/region/r in old_regions)
					r.Exited(src)

			__locs = locs

		// otherwise, handle it the tile-by-tile way
		else

			var/turf/old_turf = loc

			// These will be the sets of regions that you're entering
			// or leaving. If both the new_turf and old_turf share a
			// common region, it won't be in either list.
			var/list/old_regions
			var/list/new_regions

			// Find the set of regions you're trying to leave
			if(old_turf && old_turf.regions)
				if(new_turf && new_turf.regions)
					old_regions = old_turf.regions - new_turf.regions
				else
					old_regions = old_turf.regions

			// Call Exit() for each of those regions
			if(old_regions)
				for(var/region/r in old_regions)
					if(!r.Exit(src))
						return 0

			// Find the set of regions you're trying to enter
			if(new_turf && new_turf.regions)
				if(old_turf && old_turf.regions)
					new_regions = new_turf.regions - old_turf.regions
				else
					new_regions = new_turf.regions

			// call Enter() for each of those regions
			if(new_regions)
				for(var/region/r in new_regions)
					if(!r.Enter(src))
						return 0

			// try to perform the move
			. = ..()

			// If the move was successful we also need to call Exited and Entered.
			if(.)
				if(old_regions)
					for(var/region/r in old_regions)
						r.Exited(src)

				if(new_regions)
					for(var/region/r in new_regions)
						r.Entered(src)
