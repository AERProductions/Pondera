/*mob
	var/c = 0
turf
	DblClick (O)
		if(O:density)
			return
		if(O:type==/mob/enemies)
			return
		else
			usr.c = 1
			walk_to(usr,O)
			sleep(1)
			usr.c = 0
	endif*/

mob
    var/c = 0

turf
	DblClick (O)
		if(O:density < 1)
			usr.c = 1
			walk_to(usr,O,0,world.tick_lag/TIME_STEP,0)
			sleep(1)
			usr.c = 0

#define MOVE_SLIDE 1
#define MOVE_JUMP 2
#define MOVE_TELEPORT 4

#define TILE_WIDTH  64
#define TILE_HEIGHT 64
#define TICK_LAG    4 //set to (10 / world.fps) a define is faster, though
#include "Sound.dm"

//removeafterchanging
var
	Cutting
	Carving
	Picking
	Mining
atom/movable
	appearance_flags = LONG_GLIDE //make diagonal and horizontal moves take the same amount of time
	var
		move_delay = 0 //how long between self movements this movable should be forced to wait.
		move_dir //= 0 //the direction of the current/last movement
		tmp
			next_move = 0 //the world.time value of the next allowed self movement
			last_move = 0 //the world.time value of the last self movement
			move_flags = 0 //the type of the current/last movement

	Move(atom/NewLoc,Dir=0)//MOVEMENT
		//var/mob/players/M
		//_updateAttachedSoundmobListeners()



		if(istype(src,/mob/players))
			var/mob/players/X = src
//			if(X.Cutting||X.Carving||X.Picking||X.Mining)			//This basically stops the usr from moving when he's cutting.
//				return

			if(X.nomotion==0) // this is used so that you can't talk to shopkeepers a ton and then run around with their GUIs open
				if(X.away != 0) // if you are away
					X.away = 0 // now you aren't!
					X << "You are no longer Idle."
				if(X.poisonDMG<=0) // not poisoned anymore?
					X.overlays = null // i guess we can take those poison things off your icon then
				// problems with lag making me need to be sure that their hp and energy are within acceptable ranges
				// so this lets them cast a few extra spells by spamming, but whatever...
				if(X.HP>X.MAXHP)
					X.HP=X.MAXHP
				if(X.energy>X.MAXenergy)
					X.energy=X.MAXenergy
				if(X.energy<0)
					X.energy=0
			else
				return // don't even think about moving, chuenergy!

		var/time = world.time
		if(next_move>time)
			world << "[src] Can't move yet"
			return 0
		if(!NewLoc) //if the new location is null, treat this as a failed slide and an edge bump.
			move_dir = Dir
			move_flags = MOVE_SLIDE
		else if(isturf(loc)&&isturf(NewLoc)) //if this is a movement between two turfs
			var/dx = NewLoc.x - src.x //get the distance delta
			var/dy = NewLoc.y - src.y
			if(z==NewLoc.z&&abs(dx)<=1&&abs(dy)<=1) //if only moving one tile on the same plane, mark the current move as a slide and figure out the move_dir
				move_dir = 0
				move_flags = MOVE_SLIDE
				if(dx>0) move_dir |= EAST
				else if(dx<0) move_dir |= WEST
				if(dy>0) move_dir |= NORTH
				else if(dy<0) move_dir |= SOUTH
			else //jumping between z levels or more than one tile is a jump with no move_dir
				move_dir = 0
				move_flags = MOVE_JUMP
		else //moving into or out of a null location or another atom other than a turf is a teleport with no move_dir
			move_dir = 0
			move_flags = MOVE_TELEPORT
		glide_size = TILE_WIDTH / max(move_delay,TICK_LAG) * TICK_LAG //set the glide size
		//_updateAttachedSoundmobListeners()
		//_updateAttachedSoundobjListeners()
		//call(/mob/proc/_updateListeningSoundmobs)()

		. = ..() //perform the movement
		last_move = time //set the last movement time
		if(.)
			next_move = time+move_delay

			if(istype(src,/mob/players))
				var/mob/players/Z=src
				Z._updateListeningSoundmobs()
				var/obj/O = Z.Target
				if(O) //If you have a target.
					for(var/obj/Navi/Arrow/A in Z.client.screen)
						animate(A, transform = turn(matrix(), get_angle_nums(src.x,src.y,O.x,O.y)), time = 3, loop = 1) //Play with the time to have it look cooler






/*mob
	MouseDrag(atom/M,turf/Y,turf/T)
		if(isturf(Y) && isturf(T)) 		// incase of clashes with statpanels
			if(!Y.density) 			// dont allow them to be fighting to get into a turf
				if(!T.density)
					if (usr == src) 	// checks the owner of the mob is the client
						walk_to(src,T,0,2)
		.=..()*/

/*
mob

	Move()
		if(src.move)
			src.move=0
			..()
			sleep(src.delay)
			src.move=1

	var
		tmp/turf/moveTarget
		tmp/image/myTarget
		tmp/move=1
		delay=2

mob/proc
	walkTo()
		while(src.moveTarget)
			walk_to(src,src.moveTarget,0,0) // This uses BYOND's basic pathfinding.
			sleep(2)                        // Don't be surprised if your mob gets lost
		walk_to(src,src,0,0)                // trying to get to thier target occasionally.

turf

	Click()
		if(!src.density)
			if(usr.moveTarget == src || usr.loc == src)
				usr.moveTarget = null
				usr.client.images=list()
			else
				if(usr.myTarget)
					usr.myTarget.loc = src
					usr << usr.myTarget
				else
					var/image/img = image('dmi/64/cli.dmi',"target")
					usr << img
					img.loc = src
					usr.myTarget = img
				if(!usr.moveTarget)
					usr.moveTarget = src
					usr.walkTo()
				else
					usr.moveTarget = src


	Entered()
		..()
		if(src == usr.moveTarget)
			usr.moveTarget = null
			usr.client.images=list()*/


/*
mob/var/delay=4
mob/var/tmp/move=1

//Simple, short, and sweet.
mob/Move()
	if(src.move)
		src.move=0
		..()
		sleep(src.delay)
		src.move=1*/