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
mob/players/verb/Run()// a run verb
	set hidden = 1//"Verbs"//the name of the tab
	var/mob/players/M
	M = src
	if(!M.run)//if thier run variable isnt 1
		//M<<"You start to run!"//thell them they are running
		M.speed = 2//take away the delay
		M.run = 1//make their run variable = 1
		return//stop here
	else
		//M<<"You start to walk!"//tell them they are walking
		M.speed = 3//restore their old speed
		M.run = 0

mob
	var/c = 0
	var/Ax=0
	var/Az=0
	var/Ay=0
	var/Bx=0
	var/Bz=0
	var/By=0
/*turf
	DblClick (O)
		if(O:density < 1)
			usr.c = 1
			walk_to(usr,O,0,world.tick_lag/TIME_STEP,0)
			sleep(1)
			usr.c = 0*/
client
	Northeast()
		return
	Northwest()
		return
	Southeast()
		return
	Southwest()
		return

//removeafterchanging
var
	Cutting
	Carving
	Picking
	Mining
	//moving = 0
atom/movable
	Move()
		if(istype(src,/mob/players))
			var/mob/players/Z=src
			Z._updateListeningSoundmobs()
			//call(/sound/proc/update)()
			//var/obj/O = Z.Target
			//if(O) //If you have a target.
				//for(var/obj/Navi/Arrow/A in Z.client.screen)
					//animate(A, transform = turn(matrix(), get_angle_nums(src.x,src.y,O.x,O.y)), time = 3, loop = 1)
			if(Z.walk)//if they are frozen then dont let them move
				return
			else//if theyre not froze
				Z.walk = 1//make their froze variable = 1
				..()//do what it would normally do(in this case move)
				sleep(Z.speed)//waits however many ticks you set speed for
				Z.walk = 0//makes them able to move again

			if(Z.Cutting||Z.Carving||Z.Picking||Z.Mining)			//This basically stops the usr from moving when he's cutting.
				return

			if(Z.nomotion==0) // this is used so that you can't talk to shopkeepers a ton and then run around with their GUIs open
				if(Z.away != 0) // if you are away
					Z.away = 0 // now you aren't!
					Z << "You are no longer Idle."
				//if(Z.poisoned==0) // not poisoned anymore?
				//	Z.overlays -= poison  //this is the proper way to remove the poison overlay, turn the poison overlay into an image and call it by name
				//	Z.overlays = null // this is the improper way, as it will remove ALL overlays -- this was made before many overlays were being used
				// problems with lag making me need to be sure that their hp and stamina are within acceptable ranges
				// so this lets them cast a few extra spells by spamming, but whatever...
				if(Z.HP>Z.MAXHP)
					Z.HP=Z.MAXHP
				if(Z.stamina>Z.MAXstamina)
					Z.stamina=Z.MAXstamina
				if(Z.stamina<0)
					Z.stamina=0
			else if(Z.nomotion==1)
				return
		..()




/*
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE //make diagonal and horizontal moves take the same amount of time
	vis_flags = VIS_INHERIT_ID
	var
		move_delay = 0 //how long between self movements this movable should be forced to wait.
		move_dir //= 0 //the direction of the current/last movement
		tmp
			next_move = 0 //the world.time value of the next allowed self movement
			last_move = 0 //the world.time value of the last self movement
			move_flags = 0 //the type of the current/last movement


	Move(/*atom/NewLoc,Dir=0*/)//MOVEMENT
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
				// problems with lag making me need to be sure that their hp and stamina are within acceptable ranges
				// so this lets them cast a few extra spells by spamming, but whatever...
				if(X.HP>X.MAXHP)
					X.HP=X.MAXHP
				if(X.stamina>X.MAXstamina)
					X.stamina=X.MAXstamina
				if(X.stamina<0)
					X.stamina=0
			else
				return // don't even think about moving, chustamina!

		/*var/time = world.time
		if(next_move>time)
			world << "[src] Can't move yet"
			return 0*/
		/*if(!NewLoc) //if the new location is null, treat this as a failed slide and an edge bump.
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
*/
			if(istype(src,/mob/players))
				var/mob/players/Z=src
				Z._updateListeningSoundmobs()
				var/obj/O = Z.Target
				if(O) //If you have a target.
					for(var/obj/Navi/Arrow/A in Z.client.screen)
						animate(A, transform = turn(matrix(), get_angle_nums(src.x,src.y,O.x,O.y)), time = 3, loop = 1) //Play with the time to have it look cooler
*/
/*mob/proc
	Moved(var/D)
		src.moving = 1
		var/T = 0.2
		if(D) T = T*D
		spawn(T) if(src) src.moving = 0
mob/var
	north = 0
	east = 0
	south = 0
	west = 0
	moving = 0
mob/players/verb
	DOWNNORTH()
		set hidden = 1
		set instant = 1
		src.north = 1
	DOWNEAST()
		set hidden = 1
		set instant = 1
		src.east = 1
	DOWNSOUTH()
		set hidden = 1
		set instant = 1
		src.south = 1
	DOWNWEST()
		set hidden = 1
		set instant = 1
		src.west = 1
	UPNORTH()
		set hidden = 1
		set instant = 1
		src.north = 0
	UPEAST()
		set hidden = 1
		set instant = 1
		src.east = 0
	UPSOUTH()
		set hidden = 1
		set instant = 1
		src.south = 0
	UPWEST()
		set hidden = 1
		set instant = 1
		src.west = 0


client
	North()
		if(src.mob.east)
			src.Northeast()
			return
		else if(src.mob.west)
			src.Northwest()
			return
		if(src.mob.moving) return
		src.mob.Moved()
		..()
	East()
		if(src.mob.north)
			src.Northeast()
			return
		else if(src.mob.south)
			src.Southeast()
			return
		if(src.mob.moving) return
		src.mob.Moved()
		..()
	South()
		if(src.mob.east)
			src.Southeast()
			return
		else if(src.mob.west)
			src.Southwest()
			return
		if(src.mob.moving) return
		src.mob.Moved()
		..()
	West()
		if(src.mob.north)
			src.Northwest()
			return
		else if(src.mob.south)
			src.Southwest()
			return
		if(src.mob.moving) return
		src.mob.Moved()
		..()
	Northeast()
		if(src.mob.moving) return
		src.mob.Moved(2)
		..()
	Northwest()
		if(src.mob.moving) return
		src.mob.Moved(2)
		..()
	Southeast()
		if(src.mob.moving) return
		src.mob.Moved(2)
		..()
	Southwest()
		if(src.mob.moving) return
		src.mob.Moved(2)
		..()
*/

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