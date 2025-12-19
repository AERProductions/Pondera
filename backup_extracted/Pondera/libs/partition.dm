
// File:    partition.dm
// Library: Forum_account.Region
// Author:  Forum_account
//
// Contents:
//   This file contains procs used for splitting turfs within
//   regions into connected groups and for searching these
//   groups for certain types of objects.

var
	Region/region = new()

Region
	var
		list/instance = list()

	proc
		get(turf/source, target_type)

			// this is needed when we call get() from an object's constructor
			if(!world.time)
				sleep(0)

			// convert the source to a turf
			while(source)
				if(isturf(source)) break
				source = source.loc

			for(var/region/r in source.regions)

				var/result = r.get(source, target_type)

				if(result)
					return result

		// Returns a list of all instances of objects of the specified
		// type that exist in the same group as the source atom.
		get_list(turf/source, target_type)

			if(!world.time)
				sleep(0)

			// convert the source to a turf
			while(source)
				if(isturf(source)) break
				source = source.loc

			var/list/l = list()

			for(var/region/r in source.regions)
				l += r.get_list(source, target_type)

			return l

region
	var
		list/parent
		list/rank
		list/sets

	proc
		get(turf/source, target_type)

			// convert the source to a turf
			while(source)
				if(isturf(source)) break
				source = source.loc

			var/list/turfs = group(source)

			if(!turfs) return

			if(ispath(target_type, /turf))
				for(var/turf/t in turfs)
					if(istype(t, target_type))
						return t

			else if(ispath(target_type, /atom/movable))
				for(var/turf/t in turfs)
					for(var/atom/a in t)
						if(istype(a, target_type))
							return a

		// Returns a list of all instances of objects of the specified
		// type that exist in the same group as the source atom.
		get_list(turf/source, target_type)

			// convert the source to a turf
			while(source)
				if(isturf(source)) break
				source = source.loc

			var/list/l = list()

			var/list/turf_group = group(source)

			if(!turf_group) return l

			if(ispath(target_type, /turf))
				for(var/turf/t in turf_group)
					if(istype(t, target_type))
						l += t

			else if(ispath(target_type, /atom/movable))
				for(var/turf/t in turf_group)
					for(var/atom/a in t)
						if(istype(a, target_type))
							l += a
			return l

	proc
		// return the connected set of turfs that t is in.
		group(turf/source)

			// partition()
			// var/turf/set_root = parent[t]
			// return sets[set_root]

			// The nodes we've visited.
			var/list/visited = list()

			// The queue of nodes to expand.
			var/list/queue = list(source)

			// The turfs in our connected component.
			var/list/connected = list()

			while(queue.len)

				// Grab the next node.
				var/turf/node = queue[1]
				queue.Cut(1, 2)

				// And expand it.
				var/list/neighbors = list()
				neighbors += locate(node.x, node.y + 1, node.z)
				neighbors += locate(node.x + 1, node.y, node.z)
				neighbors += locate(node.x, node.y - 1, node.z)
				neighbors += locate(node.x - 1, node.y, node.z)

				// Check for unvisited neighbors
				for(var/turf/t in neighbors)
					if(visited[t]) continue
					visited[t] = 1

					// and add them to the queue if it's also in this region
					if(t in turfs)
						queue += t
						connected += t

			return connected

/*
		// partition the region's turfs into disjoint sets.
		partition()

			// if(parent) return

			// parent[t] is the parent of t
			parent = list()

			// rank[t] is the upper bound on the height of x
			rank = list()

			// group the turfs in this area into disjoint sets
			for(var/turf/t in turfs)
				__make_set(t)

			for(var/turf/t in turfs)

				// join all turfs adjacent to t
				__add(locate(t.x, t.y + 1, t.z), t)
				__add(locate(t.x + 1, t.y, t.z), t)
				__add(locate(t.x, t.y - 1, t.z), t)
				__add(locate(t.x - 1, t.y, t.z), t)

			// build the list of turfs for each set
			sets = list()

			/*
			for(var/turf/t in turfs)
				if(t == parent[t])
					sets[t] = list()
			*/

			for(var/turf/t in turfs)
				if(!sets[parent[t]])
					sets[parent[t]] = list(t)
				else
					sets[parent[t]] += t

		__add(turf/t, turf/root)
			if(!t) return

			// parent[t] will only be defined for turfs that
			// are also in this area.
			if(parent[t])
				__union(t, root)

		__make_set(turf/t)
			parent[t] = t
			rank[t] = 0

		__union(turf/a, turf/b)
			__link(__find_set(a), __find_set(b))

		__link(turf/a, turf/b)
			if(rank[a] > rank[b])
				parent[b] = a
			else
				parent[a] = b
				if(rank[a] == rank[b])
					rank[b] = rank[b] + 1

		__find_set(turf/t)
			if(t != parent[t])
				parent[t] = __find_set(parent[t])
			return parent[t]
*/