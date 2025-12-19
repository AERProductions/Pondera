obj
	New(loc)	//Sets the obj elevel, (should be done on the map, this is just backup which defaults to the highest level.
		if(!iselevation(src) && loc) //If it does not have a loc, then it doesn't matter what elevation it is on
			spawn(..())

				/*Un-comment this code  and add it under spawn in the New() obj proc
					if you want elevel to be set for all elevations.
					This does not work if you are using muiltiple floors
				//If there are elevations in the objects loc,
				// put the object on top of them
				for(var/elevation/E in src.loc)
					if(E.elevel > elevel) elevel=E.elevel */

				//Set the elevel to whatever is higher, the
				// turfs elevel or the objects current elevel
				elevel = max(elevel,src.loc.elevel)

				//Objects and mobs are 2 layers above whatever
				// turf or elevation they are on
				layer = FindLayer(elevel) + 2
				invisibility = FindInvis(elevel)
		..()

	proc	//Procs That must be called from a get/drop verb, see the demo for an example
		Fl_Get(mob/m)
			return m.Chk_LevelRange(src) //Makes sure the object is in M's range
			//Removing the elevel value is taken care of in Exit()

		Fl_Drop(mob/m)
			elevel = m.elevel	//Sets the elevel value equal to the mob that dropped it
			layer = m.layer		//Same with the layer
			invisibility = FindInvis(elevel) //Set invisibility, can't use line below because what if the person is invisible?
//			invisibility = m.invisibility	//And invisibility
			return 1			//Returns 1 so that it can be used the same way as Fl_Get()



