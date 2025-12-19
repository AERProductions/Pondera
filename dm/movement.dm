// dm/movement_modernized.dm — Phase 13D: Modernized Movement System
// Integrated stamina, hunger, equipment weight penalties with spatial audio

mob/var
	move
	Moving=0
	MN;MS;ME;MW
	QueN;QueS;QueE;QueW
	Sprinting=0
	MovementSpeed=3  // Base delay in ticks
	list/SprintDirs

// Detect double-tap of a direction within spawn(3) ticks to enable sprint
mob/proc/SprintCheck(var/TapDir)
	if(!src.SprintDirs)	src.SprintDirs=list()
	if(TapDir in src.SprintDirs)
		if(!src.Sprinting)
			src.Sprinting=1
	else
		src.SprintDirs+=TapDir
		spawn(3)	src.SprintDirs-=TapDir

// Cancel sprint when no directional input is active
mob/proc/SprintCancel()
	if(!src.Sprinting)	return
	if(!src.MN && !src.MS && !src.ME && !src.MW)
		src.MovementSpeed=initial(src.MovementSpeed)
		src.Sprinting=0

// Calculate movement delay with all modern penalties
// Returns effective delay in ticks (minimum 1, capped to prevent extreme slowdown)
mob/proc/GetMovementSpeed()
	var/base_delay = src.MovementSpeed
	var/stamina_penalty = 0
	var/hunger_penalty = 0
	var/equipment_penalty = 0
	var/sprint_multiplier = 1.0

	// Apply sprint multiplier if sprinting
	if(src.Sprinting)
		sprint_multiplier = 0.7  // Sprint is 30% faster

	// Stamina penalty: 0-3 ticks based on stamina level
	if(istype(src, /mob/players))
		var/mob/players/P = src
		if(P.character)
			var/stamina = P.character.stamina_level
			if(stamina < 30)
				stamina_penalty = 3  // Critically low stamina
			else if(stamina < 50)
				stamina_penalty = 2  // Low stamina
			else if(stamina < 75)
				stamina_penalty = 1  // Moderate stamina depletion

			// Hunger penalty: 0-2 ticks based on hunger level
			var/hunger = P.character.hunger_level
			if(hunger < 30)
				hunger_penalty = 2  // Starving
			else if(hunger < 50)
				hunger_penalty = 1  // Very hungry

			// Equipment penalty: weight affects speed
			// Stub for future armor weight integration
			// equipment_penalty based on equipped item weights

	// Calculate final delay
	var/final_delay = (base_delay + stamina_penalty + hunger_penalty + equipment_penalty) * sprint_multiplier

	// Return with hard caps: minimum 1 tick, maximum 10 ticks
	return max(1, min(10, final_delay))

// Stub: overridden in mob/players for procedural chunk boundary detection
mob/proc/CheckChunkBoundary()
	return

// Clear all directional inputs and cancel sprint
mob/proc/CancelMovement()
	src.MN=0;src.MS=0;src.MW=0;src.ME=0
	src.SprintCancel()

// Handle bump collisions (cancel movement/sprint on block)
mob/Bump(var/atom/A)
	return ..()
	if(src.Sprinting)
		src.CancelMovement()
		flick("Weak",src)
	return ..()

// Standard move override (hook for future extensions)
mob/Move(var/turf/NewLoc,NewDir)
	return ..()

// Play sound effect for movement based on terrain type
mob/proc/PlayMovementSound()
	// Stub: will integrate with sound system
	// Play footsteps on grass, splashing on water, clanking on stone, etc.
	return

// Main movement loop: process queued/held directions and step through world
mob/proc/MovementLoop()
	walk(src,0)
	if(src.Moving)	return;src.Moving=1

	// Block movement if player is fainted
	if(istype(src, /mob/players))
		var/mob/players/player = src
		if(player.character && player.character.is_fainted)
			player << "You cannot move while fainted."
			player.Moving = 0
			return

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

		// Post-movement hooks
		InvalidateDeedPermissionCache(src)  // Deed zone detection
		if(istype(src, /mob/players))
			src.CheckChunkBoundary()  // On-demand chunk loading
			src.PlayMovementSound()  // Spatial audio

		if(FirstStep)	{sleep(1);FirstStep=0}

		// Apply modern movement speed calculation with penalties
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
