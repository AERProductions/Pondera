var
	NOCC = 0 	//1 = no cutting corners
	NOC  = 0 	//1 = no diagnals
	SINV = 1 	//1 = show various levels; 0 will lock the ivisibility settings

	//Used for directional blocking
var/list/dir_to_bitflag = list(1,16,0,4,2,8,0,64,128,32)

	//Elevation location variable
atom/movable/var/elevation/eloc	= null

atom
	var
		elevel = 1 	//Elevation variable
		tbit = 0 	//Turf Entrence Block
		ntbit = 0 	//Turf Exit Block
		hide = 1	//If the elevation should be hidden when under it


	proc

			//Finds the elevation, given the layer
		FindElevation(var/layer) return round(layer / 4,0.25)


			//Finds the level given the elayer
		FindLayer(var/elevel) return (round(elevel-1,0.25) * 4)


			//Finds the invisibility level
		FindInvis(var/elevel) return round(elevel)


			//Checks to see if an atom and a movable atom are within 0.5 levels of each other
		Chk_LevelRange(var/atom/movable/a)
			return (a.elevel <= src.elevel + 0.5 && a.elevel >= src.elevel - 0.5)


		GetDenseObject() ..()	//Just a hook, defined in Elevation_System and Turf_System


		Chk_CC(atom/movable/a)	//Corner Check
			var/d = get_dir(src,a)
			if( NOC  && (d&(d-1)) ) return 0	//If NOC = 1 then the mob can move diagonaly
			if( NOCC && (d&(d-1)) )				//If NOCC = 1 then the mob can't cut corners
				var/turf/T = get_step(src,d)	//Gets the turf that the mob is trying to enter
				return T.Check_CC(d,a)			//Calls Check_CC
			else return 1


		Chk_Enter(atom/movable/A)	//Overarching proc to see if something can enter something else
			if(!A) return 0				//If A doesn't exist then it can't enter
			if(!A.density) return 1		//If A isn't dense then it doesn't matter
			if(!Chk_CC(A)) return 0		//Corner Check
			if(!Chk_LevelRange(A)) return 0		//If it is within 0.5 of the src's elevel
			var/atom/D = GetDenseObject(A)		//Trys to find a reason why it should not allow it
			return (!D || D == A) ? 1 : 0		//If it found a reason then don't let it enter, else let it enter


		Chk_EnterCC(atom/movable/A,d as null)	//Like Chk_Enter() except it also checks all possible places A could enter the atom
			if(!A) return 0
			if(!A.density) return 1

			if(!src.Chk_LevelRange(A))		//If the atom isn't in range of the proc, then looks for an elevation in it that is
				var/chk = 0
				for(var/elevation/e in src)	//For each elevation in the src
					if(e.Chk_Enter(A))		//See if the mob can enter it
						chk = 1				//If it can set chk to 1
						break				//Break out of the loop
				if(!chk) return 0			//If there is no place it can enter, then return 0

			var/atom/D = GetDenseObject(A,d)
			return (!D || D == A) ? 1 : 0


		Chk_Exit(atom/movable/A)	//Checks to see if something can be exited
			var/d = A.dir		//Finds the direction of the exiting atom
			if(Chk_NTbit(d)) return 0	//Checks the exit directional blocking variable
			else return 1


		Chk_Tbit(d)		//Checks to see if a direction is blocked; Returns 1 for no pass
			if(tbit && (d && (dir_to_bitflag[d] & tbit))) return 1	//Checks to see if the direction the atom is moving is blocked
			else return 0


		Chk_NTbit(d)	//Checks to see if an exit direction is blocked
			if(!ntbit) ntbit = tbit		//If the exit variable isn't set, set it to tbit
			if(ntbit && (d && (dir_to_bitflag[d] & ntbit))) return 1
			else return 0
/*

	Entered(atom/movable/A)		//What happens when an atom is entered
		if(!iselevation(A))		//If it is not elevation
			A.elevel = elevel	//Set the elevels equal
			A.layer = FindLayer(elevel) + 2		//Set A's layer to the right level
			if(A.invisibility < 90) //Above 90 is reserved for actual invisibility
				A.invisibility = FindInvis(elevel)	//Set the invisibility
			if(ismob(A) && SINV) A:SetSee_Invis(src)	//Set the what layer can be seen
		..()


	Exited(atom/movable/O)	//When something exits
		if(isobj(O)) 	//Only concerned about objects
			O.elevel = null		//Reset their elevel to null
			O.layer = null		//Reset their layer to null
		..()


*/





//Cutting Corners//

var/list/OppD = list(2,1,0,8,10,9,0,4,6,5) //A list of opposite directions


proc
	Odir(d) return (d?OppD[d]:d)	//Returns the opposite direction

	G_ADiag(d) return d&(d-1)		//Get a direction from a diagonal
	G_NDiag(d) return (d&(d-1))^d 	//Get another direction from a diagonal


atom
	proc
			//Get the turf in the opp dir of d
		get_ostep(d) return get_step(src,Odir(d))


			//Checks to see if something would be cutting corners
		Check_CC(dir,atom/movable/a)

				//d1 and d2 are the two turfs that would block cutting corners
			var/d1=G_NDiag(dir)
			var/d2=G_ADiag(dir)

			return Check_Step(d1,a)&Check_Step(d2,a)


			//Checks to see if a turf can be entered from a direction
		Check_Step(d,atom/movable/a)
			var/turf/t=get_ostep(d)
			return t.Chk_EnterCC(a,d)