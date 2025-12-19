// MOVE DELAY LIB VERSION 2

//CREATED BY - SNIPER JOE(ITG MASTER)

//A SIMPLE PLUG AND PLAY LIB

// Contact me at JustinElizondo04@aol.com

// VERSION 2, Now added Frozen var

mob
	var
		Moveing = 0 // This is if the mob is moving or not.
		Move_Delay = 2 // This is the amount to wait before moving.
		Frozen = 0 // Set this to 1 to keep the mob from moving

	Move()
		if(src.Moveing || src.Frozen) // If they are moving..
			return // Stop
		else
			src.Moveing = 1	// Set there Moveing to 1.
			..() // Calls the defualt of the Move() proc, which is to move of course :).
			sleep(src.Move_Delay) // Sleeps the Move_Delay's set amount.
			src.Moveing = 0
	Login()
		src << "<font size=-1><font color=green>Improved with  Sniper Joe's Move Delay"
		..()