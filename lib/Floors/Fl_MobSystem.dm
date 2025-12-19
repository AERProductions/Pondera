mob
	invisibility = 0 	//These are used to hide and show and hide the elevels
	see_invisible = 1
	var/invisibleimage = ""
	New() //When the mob is created
		src.see_invisible = FindInvis(tele)	//Set its see_invisible var to the highest level needed to see the whole map
		..()

mob
	proc
			//Sets how much a mob can see
		SetSee_Invis(atom/A)
			var/lvladd = tele	//Defaults the viewible area to see everything

				//This for loops just counts how many open levels
				// are above the mob and then sets their
				// see_invisible var to that
				//This way if you are on the first floor and there
				// is nothing above you, your see_invisible var
				// wont be set to only the first floor
			for(var/elevation/E in src.loc.contents)
				if(iselevation(E) && E.hide)		//If an elevation has hide set to 0, it is not taken into account
					if(E.elevel < src.elevel || E.elevel == src.elevel) continue
					if(E.elevel-elevel < lvladd) lvladd = E.elevel-elevel

			src.see_invisible = FindInvis(elevel+(lvladd-1))
//			src.invisibility = A.invisibility //Redundent

		mInvisible(n=95 as num)
			if(invisibleimage) src << image(invisibleimage,src,,FindLayer(n))
			if(invisibility < 90)
				invisibility = max(min(101,n),90) //Has to be between 90 and 101
			else
				invisibility = FindInvis(elevel) //Has to be called to get the correct level again