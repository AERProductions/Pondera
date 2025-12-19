turf
	New()
		spawn(..())	//Just sets all the elevation and layer variables
			if(elevel) layer=FindLayer(elevel)
			else if(!elevel&&layer) elevel=FindElevation(layer)
			else {elevel=1;layer=FindLayer(elevel)}
		..()

	Enter(atom/movable/A)
		return Chk_Enter(A)

	Exit(atom/movable/A)
		return Chk_Exit(A)

		 //Returns any dense object it finds in the turf
	GetDenseObject(atom/movable/a,d as null)
		if(!d) d = get_dir(src, a)
		if(density || src.Chk_Tbit(d) ) return src
		if(loc.density && src.Chk_LevelRange(a)) return loc
		for(var/obj/O in src)
			if( O.Chk_LevelRange(a) && (O.density || O.Chk_Tbit(d)) )  return O
		for(var/mob/M in src)
			if( M.Chk_LevelRange(a) && (M.density || M.Chk_Tbit(d)) )  return M