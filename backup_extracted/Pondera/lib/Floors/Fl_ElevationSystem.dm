proc
		//Checks to see if something is an elevation
	iselevation(elevation/E)
		if(istype(E)) return 1
		else return 0

elevation
	parent_type = /obj	//The elevation datum is derived from /obj

	var/list/elecontents	//The elevation's contents list

	New()
		elecontents = newlist()		//Create the list
		spawn(..())		//Wait for the standard procedure to finish
			if(elevel) layer = FindLayer(elevel)	//Find its layer if there is an elevel, (best way to do things)
			else if(!elevel && layer) elevel = FindElevation(layer)		//Find elevel if only layer is given, (not recomended)
			else{elevel=1;layer=FindLayer(elevel)}	// If nothing, set to defaults
			if(!invisibility) invisibility = FindInvis(elevel)	//declare its invisibility level
		..()

	Enter(atom/movable/A)
		return Chk_Enter(A)

	Exit(atom/movable/A)
		return Chk_Exit(A)

	Entered(atom/movable/A)	//When it actually enters
		elecontents += A 	// Add A to its contents
		..()

	Exited(atom/movable/A)	//When exited
		elecontents -= A	// Remove A from its contents
		..()

	GetDenseObject(var/atom/movable/a,var/d as null) //Returns a dense object in a elevation
			//If no direction is given, find one (used for directional blocking)
		if(!d) d = get_dir(src, a)

		var/turf/t=src

			//Finds a turf if given something on a turf, (such as an elevation)
		while(!isturf(t)) t = src.loc

			//Returns the src if it is dense or partially dense
		if( src.Chk_LevelRange(a) && (density || src.Chk_Tbit(d)) ) return src

			//Returns a dense object or a partially dense object
			// that is located in turf t
		for(var/obj/O in t)
			if( O.Chk_LevelRange(a) && (O.density || O.Chk_Tbit(d)) )  return O

			//Returns a dense mob or a partially dense mob
			// that is located in turf t
		for(var/mob/M in t)
			if( M.Chk_LevelRange(a) && (M.density || M.Chk_Tbit(d)) )  return M


elevation
		//The dir var of the stairs is the direction for going up.
		// So if stairs are set to north, then the stairs have to be
		// approached going north to go up an elevel and approached
		// going south to go down an elevel
		//This allows for stairs to be a bit easier to place,
		// Instead of having to place stairs carefully, stairs can be
		// placed anywhere and only the elevel has to be set on the map.
		// (the elevel should be set at an intermediate elevel, between
		//  two whole number elevels, ex. (stairs going from elevel
		//  2 - 3 should have an elevel of 2.5)
	ditch
		Enter(atom/movable/e)
			if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
			else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
			else return 0

		Exit(atom/movable/e)
			if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
			else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
			else return 0
	hill
		Enter(atom/movable/e)
			if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
			else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
			else return 0

		Exit(atom/movable/e)
			if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
			else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
			else return 0
	stairs
		Enter(atom/movable/e)
			if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
			else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
			else return 0

		Exit(atom/movable/e)
			if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
			else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
			else return 0
