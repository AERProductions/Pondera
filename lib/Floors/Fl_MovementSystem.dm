///The Move Proc///
atom
	movable
		Move(atom/newloc, newdir)
			var{area/area1;area/area2;atom/oldloc;elevation/oldeloc}

			if(!newloc) return 0 	// Move() ignores null destinations so bumping into edge of map has no effect
			if(newdir) dir = newdir 	//If a direction is given, change the atoms direction

			oldloc = loc 	//Save the old loc

			if(isturf(newloc))	 //If moving onto a turf//

				if(loc && newloc && !newdir) dir = get_dir(loc, newloc) //If there is an old loc and a new loc and not a new direction, set the direction
				if(oldloc && !oldloc.Exit(src)) return 0 //If you can't exit the old loc

				var/elevation/e1 = null

					 //For each elevation in the turf
				for(var/elevation/e2 in newloc)
						//If the elevation is in range
					if(e2.Chk_LevelRange(src))
							//If there is no e1, set e2 one to e1
						if(!e1) e1 = e2
							//Else set it to e1 if it's level is greater than the current e1
						else if(e2.elevel > e1.elevel) e1 = e2

				if(e1)
						//if it can move to that elevation, let it move
					if(Move(e1, newdir)) return 1
						//If there is an elevation within range that is dense, dont move.
					else if(e1.Chk_LevelRange(src)) return 0

			else if(iselevation(newloc))
					 //if newdir is not set, get the direction
				if(loc && newloc && !newdir) dir = get_dir(loc, newloc)


				//If you are moving from one elevation to another
			if(iselevation(newloc) && eloc)
				oldeloc = eloc		//Save the old elevation loc
				area1 = oldeloc		//Set area 1 to the old elevation loc

			else area1 = oldloc	//If you are not moving from one elevation to another, set area1 to the old turf loc

			area2 = newloc
				//Find the areas that contain the elevation or turf
			while(area1 && !isarea(area1)) area1 = area1.loc
			while(area2 && !isarea(area2)) area2 = area2.loc

			if(oldloc && !oldloc.Exit(src)) return 0	//old locs dont want the mob to exit, then dont let it
			if(oldeloc && !oldeloc.Exit(src)) return 0

			if(!oldeloc)	//If you were not on an elevation
					//If Area1 exists and it isn't the same as area2, and you started on a turf, and you can't exit area1, return 0
				if(area1 && area1 != area2 && isturf(oldloc) && !area1.Exit(src)) return 0

			if(newloc && !newloc.Enter(src))	//If the new loc doesnt want you to enter, Bump!
				Bump(newloc.GetDenseObject(src))
				return 0
			if(newloc && !newloc.Chk_LevelRange(src))	//If the newloc isnt in range, no move!
				return 0
			if(area2 && area1 != area2 && isturf(newloc) && !area2.Enter(src))	//If the new area doesn't want you to enter, Bump!
				return 0

			if(iselevation(newloc)) //If you are entering an elevation
				if(eloc != oldeloc) return 0 //If you already moved, forget it

					//Move!
				eloc = newloc		//Change eloc
				loc = newloc.loc	//Change turf loc

					//Call Entered() and Exited()
				if(oldeloc) oldeloc.Exited(src)		//For turf
				else if(oldloc) oldloc.Exited(src)	//Or elevation

				if(area1 && area1 != area2) area1.Exited(src)	//And Areas

				eloc.Entered(src, oldeloc) 	// Enter elevation
				if(area2 && area1 != area2 && !isarea(loc))		//Enter area
					area2.Entered(src, oldeloc)

			else	//Else entering a turf
				if(loc != oldloc) return 0	//Cancel if already moved

					//Now we move
				loc = newloc	//Change turf loc

					//Call Enter() and Exit()
				if(oldloc) oldloc.Exited(src)
				if(area1 && area1 != area2 && !isarea(oldloc))
					area1.Exited(src)
				if(loc) loc.Entered(src, oldloc)
				if(area2 && area1 != area2 && !isarea(loc))
					area2.Entered(src, oldloc)

			return 1	//The atom moved, so return 1
