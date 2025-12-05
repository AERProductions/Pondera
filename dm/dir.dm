turf/var/borders = 0 // bit-flagged value determining directional
obj/var/borders = 0


turf
	tree4
		icon = 'dmi/64/tree.dmi'
		icon_state = "tree"
		density = 1
		layer = 3
		borders=NORTH
	/*exits
		onewayN
			icon = 'dmi/64/blank.dmi'
			icon_state = "n"
			borders=NORTH
			buildingowner=""
		onewayS
			icon = 'dmi/64/blank.dmi'
			icon_state = "s"
			borders=SOUTH
			buildingowner=""
		onewayE
			icon = 'dmi/64/blank.dmi'
			icon_state = "e"
			borders=EAST
			buildingowner=""
		onewayW
			icon = 'dmi/64/blank.dmi'
			icon_state = "w"
			borders=WEST
			buildingowner=""*/

/*obj
	var/disallow_in = 0
	var/disallow_out = 0
	//house_walls
	//	disallow_in = NORTH
	//	disallow_out = SOUTH

	Cross(atom/movable/O)
		if(disallow_in)
			if(disallow_in & O.dir)
				return 0
			. = ..()

	Uncross(atom/movable/O)
		if(disallow_out)
			if(disallow_out & O.dir)
				return 0
			. = ..()*/

/*atom/movable/Move(nLoc)
	if(isturf(loc) && isturf(nLoc) && get_dist(loc, nLoc) == 1)
		var/nDir = get_dir(loc, nLoc)

		var/turf/T = loc
		if((T.borders & nDir) == nDir)
			return FALSE

		T = nLoc
		nDir = turn(nDir,180)
		if((T.borders & nDir) == nDir)
			return FALSE
	. = ..()
	if(isobj(loc) && isobj(nLoc) && get_dist(loc, nLoc) == 1)
		var/nDir = get_dir(loc, nLoc)

		var/obj/O = loc
		if((O.borders & nDir) == nDir)
			return FALSE

		O = nLoc
		nDir = turn(nDir,180)
		if((O.borders & nDir) == nDir)
			return FALSE
	. = ..()
*/
/*
obj
	Enter(atom/movable/A)
		for(var/atom/movable/B in src)
			if(B.dcin & A.dir)
				return 0 // disallow movement to the turf if any movable objects have the bit flag of their direction turned on
			return ..()
    // otherwise, enter normally

	Exit(atom/movable/A) // repeated for Exiting a turf too
		for(var/atom/movable/B in src)
			if(B.dcout & A.dir)
				return 0
			return ..()
turf
	Enter(atom/movable/A)
		for(var/atom/movable/B in src)
			if(B.dcin & A.dir)
				return 0 // disallow movement to the turf if any movable objects have the bit flag of their direction turned on
			return ..()
    // otherwise, enter normally

	Exit(atom/movable/A) // repeated for Exiting a turf too
		for(var/atom/movable/B in src)
			if(B.dcout & A.dir)
				return 0
			return ..()*/

atom/movable
	var
		dcout = 0 // disallowed directions when they go out
		dcin = 0  // disallowed directions when they come in

//obj
//	narrow_wall
//		dcout = NORTH | SOUTH
//		dcin = NORTH | SOUTH



/*atom/movable/Move(nLoc)
	if(isobj(loc) && isobj(nLoc) && get_dist(loc, nLoc) == 1)
		var/nDir = get_dir(loc, nLoc)
		var/obj/O = loc
		if((O.borders & nDir) == nDir)
			return FALSE

		O = nLoc
		nDir = turn(nDir,180)
		if((O.borders & nDir) == nDir)
			return FALSE
	. = ..()

*/
//  Testing Code/Sample Implementation:

//turf/limited_exit/borders = EAST|NORTH|WEST