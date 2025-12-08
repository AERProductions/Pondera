// dm/movement.dm — Movement system: input handling, sprint activation, and movement loop.

mob/var
	move
	Moving=0
	MN;MS;ME;MW
	QueN;QueS;QueE;QueW
	Sprinting=0
	MovementSpeed=3
	list/SprintDirs

// Detect double-tap of a direction within spawn(3) ticks to enable sprint.
mob/proc/SprintCheck(var/TapDir)
	if(!src.SprintDirs)	src.SprintDirs=list()
	if(TapDir in src.SprintDirs)
		if(!src.Sprinting)
			src.Sprinting=1
	else
		src.SprintDirs+=TapDir
		spawn(3)	src.SprintDirs-=TapDir// Cancel sprint when no directional input is active.
mob/proc/SprintCancel()
	if(!src.Sprinting)	return
	if(!src.MN && !src.MS && !src.ME && !src.MW)
		src.MovementSpeed=initial(src.MovementSpeed)
		src.Sprinting=0


// Return movement delay for current speed (minimum 1 tick).
mob/proc/GetMovementSpeed()
	var/MovementDelay=src.MovementSpeed
	return	max(1,MovementDelay)

// Clear all directional inputs and cancel sprint.
mob/proc/CancelMovement()
	src.MN=0;src.MS=0;src.MW=0;src.ME=0
	src.SprintCancel()

// Handle bump collisions (cancel movement/sprint on block).
mob/Bump(var/atom/A)
	return ..()
	if(src.Sprinting)
		src.CancelMovement()
		flick("Weak",src)
	return ..()

// Standard move override (hook for future extensions).
mob/Move(var/turf/NewLoc,NewDir)
	return ..()


// Main movement loop: process queued/held directions and step through world.
mob/proc/MovementLoop()
	walk(src,0)
	if(src.Moving)	return;src.Moving=1
	var/FirstStep=1
	while(src.MN || src.ME || src.MW || src.MS || src.QueN || src.QueS || src.QueE || src.QueW)
		if(src.MN || src.QueN)
			if(src.ME || src.QueE)	if(!step(src,NORTHEAST) && !step(src,NORTH))	step(src,EAST)
			else if(src.MW || src.QueW)	if(!step(src,NORTHWEST) && !step(src,NORTH))	step(src,WEST)
			else	step(src,NORTH)
		else	if(src.MS || src.QueS)
			if(src.ME || src.QueE)	if(!step(src,SOUTHEAST) && !step(src,SOUTH))	step(src,EAST)
			else if(src.MW || src.QueW)	if(!step(src,SOUTHWEST) && !step(src,SOUTH))	step(src,WEST)
			else	step(src,SOUTH)
		else	if(src.ME || src.QueE)	step(src,EAST)
		else	if(src.MW || src.QueW)	step(src,WEST)
		src.QueN=0;src.QueS=0;src.QueE=0;src.QueW=0
		InvalidateDeedPermissionCache(src)  // Player moved - invalidate deed permission cache
		if(FirstStep)	{sleep(1);FirstStep=0}
		sleep(src.GetMovementSpeed())
	src.Moving=0

mob/verb
	MoveNorth()
		set hidden=1;set instant=1
		if(src.move)
			src.SprintCheck("North")
		src.MN=1;src.MS=0;QueN=1;src.MovementLoop()

	StopNorth()
		set hidden=1;set instant=1
		if(src.move)
			src.MN=0;src.SprintCancel()

	MoveSouth()
		set hidden=1;set instant=1
		if(src.move)
			src.SprintCheck("South")
			src.MN=0;src.MS=1;QueS=1;src.MovementLoop()

	StopSouth()
		set hidden=1;set instant=1
		if(src.move)
			src.MS=0;src.SprintCancel()

	MoveEast()
		set hidden=1;set instant=1
		if(src.move)
			src.SprintCheck("East")
			src.ME=1;src.MW=0;QueE=1;src.MovementLoop()

	StopEast()
		set hidden=1;set instant=1
		if(src.move)
			src.ME=0;src.SprintCancel()

	MoveWest()
		set hidden=1;set instant=1
		if(src.move)
			src.SprintCheck("West")
			src.ME=0;src.MW=1;QueW=1;src.MovementLoop()

	StopWest()
		set hidden=1;set instant=1
		if(src.move)
			src.MW=0;src.SprintCancel()