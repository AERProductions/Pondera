/*mob/var//We need these vars in here to make to code work.
	Drunk=0
	random
client
	North()//Activates when the mob tries to go north.
		if(usr.Drunk)//Checks to see if the mob is drunk or not.
			usr.D_North()//If the mob is drunk, It activates the north drunk proc.
			..()
		else
			..()//If the mob is not drunk, they walk normaly.
	South()//Activates when the mob tries to go south.
		if(usr.Drunk)//Checks to see if the mob is drunk or not.
			usr.D_South()//If the mob is drunk, It activates the south drunk proc.
			..()
		else
			..()//If the mob is not drunk, they walk normaly.
	East()//Activates when the mob tries to go east.
		if(usr.Drunk)//Checks to see if the mob is drunk or not.
			usr.D_East()//If the mob is drunk, It activates the east drunk proc.
			..()
		else
			..()//If the mob is not drunk, they walk normaly.
	West()//Activates when the mob tries to go west.
		if(usr.Drunk)//Checks to see if the mob is drunk or not.
			usr.D_West()//If the mob is drunk, It activates the west drunk proc.
			..()
		else
			..()//If the mob is not drunk, they walk normaly.

mob/proc/DrunkMove()
	if(src.client)//Checks to see if the mob is a PC(Playing Charecter) or an NPC(Non Playing Charecter).
		src.random=rand(1,4)//If the mob is a PC, the it will choose a random number.
		if(src.random == 1){step(src,SOUTH)}//If the random number is one they will step to the north.
		else if(src.random == 2){step(src,NORTH,)}//If the random number is one they will step to the south.
		else if(src.random == 3){step(src,WEST)}//If the random number is one they will step to the east.
		else if(src.random == 4){step(src,EAST)}//If the random number is one they will step to the west.
mob/proc/D_North()
	if(src.client)
		src.random=rand(1)
		if(src.random == 1){step(src,NORTH)}//If the random number is one they will step to the north.
mob/proc/D_South()
	if(src.client)
		src.random=rand(2)
		if(src.random == 2){step(src,SOUTH)}//If the random number is one they will step to the south.
mob/proc/D_West()
	if(src.client)
		src.random=rand(3)
		if(src.random == 3){step(src,WEST)}//If the random number is one they will step to the west.
mob/proc/D_East()
	if(src.client)
		src.random=rand(4)
		if(src.random == 4){step(src,EAST)}//If the random number is one they will step to the east.
		*/
//_________________________________________________________
//A simple verb for the demo to turn the drunk on or off - and a half assed attempt to make the verb into something I can use
/*

area
	insidepub
		Entered(atom/movable/A)
			if(ismob(A))
				var/mob/M=A
				M.verbs-=typesof(/mob/verb/Drunk)
				if(/area/inside){usr.Drunk=1}

		Exited(atom/movable/A)
			if(ismob(A))
				var/mob/M=A
				M.verbs+=typesof(/mob/verb/Drunk)
				if(/area/outside){usr.Drunk=0}

mob/verb/Drunk()
	switch(alert("Have a Drink?","Get Drunk?","Yes","No"))
		if("Yes"){usr.Drunk=1}
		else if("No"){usr.Drunk=0}

*/
//___________________________________________________________
mob/var//We need these vars in here to make to code work.
	Drunk=0
	random
client
	North()//Activates when the mob tries to go north.
		if(usr.Drunk)//Checks to see if the mob is drunk or not.
			usr.D_North()//If the mob is drunk, It activates the north drunk proc.
			..()
		else
			..()//If the mob is not drunk, they walk normaly.
	South()//Activates when the mob tries to go south.
		if(usr.Drunk)//Checks to see if the mob is drunk or not.
			usr.D_South()//If the mob is drunk, It activates the south drunk proc.
			..()
		else
			..()//If the mob is not drunk, they walk normaly.
	East()//Activates when the mob tries to go east.
		if(usr.Drunk)//Checks to see if the mob is drunk or not.
			usr.D_East()//If the mob is drunk, It activates the east drunk proc.
			..()
		else
			..()//If the mob is not drunk, they walk normaly.
	West()//Activates when the mob tries to go west.
		if(usr.Drunk)//Checks to see if the mob is drunk or not.
			usr.D_West()//If the mob is drunk, It activates the west drunk proc.
			..()
		else
			..()//If the mob is not drunk, they walk normaly.
	Northeast()//Activates when the mob tries to go northeast.
		if(usr.Drunk)//Checks to see if the mob is drunk or not.
			usr.DrunkMove()//If the mob is drunk, It activates the Drunk Move proc.
			..()
		else
			..()
	Northwest()//Activates when the mob tries to go northwest.
		if(usr.Drunk)//Checks to see if the mob is drunk or not.
			usr.DrunkMove()//If the mob is drunk, It activates the Drunk Move proc.
			..()
		else
			..()//If the mob is not drunk, they walk normaly.
	Southeast()//Activates when the mob tries to go southeast.
		if(usr.Drunk)//Checks to see if the mob is drunk or not.
			usr.DrunkMove()//If the mob is drunk, It activates the Drunk Move proc.
			..()
		else
			..()//If the mob is not drunk, they walk normaly.
	Southwest()//Activates when the mob tries to go southwest.
		if(usr.Drunk)//Checks to see if the mob is drunk or not.
			usr.DrunkMove()//If the mob is drunk, It activates the Drunk Move proc.
			..()
		else
			..()//If the mob is not drunk, they walk normaly.

mob/proc/DrunkMove()
	if(src.client)//Checks to see if the mob is a PC(Playing Charecter) or an NPC(Non Playing Charecter).
		src.random=rand(1,8)//If the mob is a PC, the it will choose a random number.
		if(src.random == 1){step(src,NORTH)}//If the random number is one they will step to the north.
		else if(src.random == 2){step(src,SOUTH,)}//If the random number is one they will step to the south.
		else if(src.random == 3){step(src,EAST)}//If the random number is one they will step to the east.
		else if(src.random == 4){step(src,WEST)}//If the random number is one they will step to the west.
		else if(src.random == 5){step(src,NORTHWEST)}//If the random number is one they will step to the northwest.
		else if(src.random == 6){step(src,NORTHEAST)}//If the random number is one they will step to the northeast.
		else if(src.random == 7){step(src,SOUTHWEST)}//If the random number is one they will step to the southwest.
		else if(src.random == 8){step(src,SOUTHEAST)}//If the random number is one they will step to the southeast.
mob/proc/D_North()
	if(src.client)
		src.random=rand(1,3)
		if(src.random == 1){step(src,NORTH)}//If the random number is one they will step to the north.
		else if(src.random == 2){step(src,NORTHWEST)}//If the random number is one they will step to the northwest.
		else if(src.random == 3){step(src,NORTHEAST)}//If the random number is one they will step to the northeast.
mob/proc/D_South()
	if(src.client)
		src.random=rand(1,3)
		if(src.random == 1){step(src,SOUTH)}//If the random number is one they will step to the south.
		else if(src.random == 2){step(src,SOUTHWEST)}//If the random number is one they will step to the southwest.
		else if(src.random == 3){step(src,SOUTHEAST)}//If the random number is one they will step to the southeast.
mob/proc/D_West()
	if(src.client)
		src.random=rand(1,3)
		if(src.random == 1){step(src,WEST)}//If the random number is one they will step to the west.
		else if(src.random == 2){step(src,SOUTHWEST)}//If the random number is one they will step to the southwest.
		else if(src.random == 3){step(src,NORTHWEST)}//If the random number is one they will step to the northwest.
mob/proc/D_East()
	if(src.client)
		src.random=rand(1,3)
		if(src.random == 1){step(src,EAST)}//If the random number is one they will step to the east.
		else if(src.random == 2){step(src,NORTHEAST)}//If the random number is one they will step to the northeast.
		else if(src.random == 3){step(src,SOUTHEAST)}//If the random number is one they will step to the southeast.
//_________________________________________________________
//A simple verb for the demo to turn the drunk on or off
/*mob/verb/Drunk()
	switch(alert("Get Drunk?","Drink?","Yes","No"))
		if("Yes"){usr.Drunk=1}
		else if("No"){usr.Drunk=0}*/



mob
	PUB
		icon = 'dmi/64/npcs.dmi'
		icon_state = "pub1"
		density = 1
		layer = 3
		layer = 3
		verb
			Talk()
				set hidden = 1
				set src in oview(2)
				switch(alert("Would you like a Drink?","Drink?","Yes","No"))
					if("Yes")		usr.Drunk=1
					else if("No")	usr.Drunk=0
mob
	PUB1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "rsdspb"
		density = 1
		verb
			Talk()
				set hidden = 1
				set src in oview(2)
				switch(alert("Would you like a Drink?","Drink?","Yes","No"))
					if("Yes")		usr.Drunk=1
					else if("No")	usr.Drunk=0