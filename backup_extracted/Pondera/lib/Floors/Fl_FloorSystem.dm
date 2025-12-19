world
	version = 315


var/tele	//The highest elevation in the world

world
	New()
		spawn(..())	//Sets the master elevation
			for(var/turf/T in world) if(T.elevel>tele) tele=T.elevel
			for(var/elevation/E in world) if(E.elevel>tele) tele=E.elevel
		..()