
// File:    region.dm
// Library: Forum_account.Region
// Author:  Forum_account
//
// Contents:
//   This file contains the definition of the /region type.
//   Regions are like areas, they group turfs into a single
//   entity. The difference is that, unlike areas, regions
//   can overlap - a turf can be a member of many regions.

region
	parent_type = /obj
	layer = MOB_LAYER + 1

	var
		list/turfs

	New()
		..()
		// we only need to keep one instance of the region object, so if the
		// type is already in the list we've already found the single instance.
		if(type in region.instance)

			// add the region to the turf's list
			var/turf/t = loc
			if(t && istype(t))
				var/region/r = region.instance[type]
				r.add(t)

			// delete this region object
			del src

		else
			// store this instance in the global list
			region.instance[type] = src

			// add this region object's loc to the region
			var/turf/t = loc
			if(t && istype(t))
				add(t)

			// we still have the reference from the global list so we can
			// safely set the loc to null, we just want to hide it so the
			// region doesn't come up in view() or oview() calls.
			loc = null

	proc
		add(turf/t)
			if(!istype(t)) return 0
			if(t in turfs) return 0

			if(!t.regions) t.regions = list()
			if(!turfs) turfs = list()

			turfs += t
			t.regions += src

			added(t)

			return 1

		remove(turf/t)
			if(!istype(t)) return 0
			if(!(t in turfs)) return 0

			t.regions -= src
			turfs -= t

			removed(t)

			return 1

		// these can be overriden to add effects that happen
		// when turf are added to or removed from the region
		added(turf/t)
		removed(turf/t)

turf
	var
		// every turf keeps track of what regions it's a part of
		list/regions
