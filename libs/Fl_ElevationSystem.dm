// libs/Fl_ElevationSystem.dm — Elevation container and directional transitions (ditch/hill/stairs).

proc
	// Return true if argument is an elevation type.
	iselevation(elevation/E)
		if(istype(E)) return 1
		else return 0

elevation
	parent_type = /obj

	var/list/elecontents

	New()
		elecontents = newlist()
		spawn(..())
			if(elevel) layer = FindLayer(elevel)
			else if(!elevel && layer) elevel = FindElevation(layer)
			else{elevel=1;layer=FindLayer(elevel)}
			if(!invisibility) invisibility = FindInvis(elevel)
		..()

	Enter(atom/movable/A)
		return Chk_Enter(A)

	Exit(atom/movable/A)
		return Chk_Exit(A)

	// Track contents when mob/obj actually enters/exits.
	Entered(atom/movable/A)
		elecontents += A
		..()

	Exited(atom/movable/A)
		elecontents -= A
		..()

	// Return a dense blocking object (object or mob) in this elevation for collision checks.
	GetDenseObject(var/atom/movable/a,var/d as null)
		if(!d) d = get_dir(src, a)
		var/turf/t=src
		while(!isturf(t)) t = src.loc
		if( src.Chk_LevelRange(a) && (density || src.Chk_Tbit(d)) ) return src
		for(var/obj/O in t)
			if( O.Chk_LevelRange(a) && (O.density || O.Chk_Tbit(d)) )  return O
		for(var/mob/M in t)
			if( M.Chk_LevelRange(a) && (M.density || M.Chk_Tbit(d)) )  return M

// Elevation subtypes: ditch/hill/stairs enforce directional enter/exit rules based on elevel changes.
elevation
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
