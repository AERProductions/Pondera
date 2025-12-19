/* Darke Mapmaker Demo
	Shadowdarke (shadowdarke@hotmail.com)

This is a small demonstration that uses the sd_MapMaker library
to generate random maps.
*/

world
	maxx=60
	maxy=60
	maxz=1
	view = 6
	loop_checks=0

	New()
		..()
		Maze.map_wall = /turf/wall
		Maze.map_passage = /turf/door
		Maze.map_floor = /turf/floor/type2

		Rogue.map_wall = /turf/wall
		Rogue.map_passage = /turf/door
		Rogue.map_floor = /turf/floor/type2

var
	mapfloor = list(/turf/floor/type1,/turf/floor/type2,/turf/floor/type3)
	sd_MapMaker/FullMaze/Maze = new()
	sd_MapMaker/ClassicRogue/Rogue = new()


area
	luminosity = 1
	icon = 'icons/sd_empty.dmi'
	icon_state = "grid"

turf
	arch
		text = "^"
		icon = 'icons/sd_arch.dmi'

	door
		text = "<font color=#774400>+"
		icon = 'icons/sd_door.dmi'
		density = 1
		opacity = 1

		Enter(O)
			if (ismob(O))
				if (icon_state != "open" && icon_state != "broken")
					open()
			return ..(O)

		verb
			open()
				set src in range(1)
				set desc = "Open the door."
				if (!icon_state)
					icon_state = "open"
					text = "<font color=#774400>="
					density = 0
					opacity = 0
					spawn(500) close()	//auto close it later

			close()
				set src in range(1)
				set desc = "Close the door."
				if (contents.len>0)
					spawn(500) close()	//auto close it later
					return 0
				if (icon_state == "open")
					icon_state = ""
					text = "<font color=#774400>+"
					opacity = 1
					density = 1
					return 1
				else
					return 0

		secret_door
			icon = 'icons/sd_secret.dmi'

	floor
		text = "."
		icon = 'icons/sd_empty.dmi'

		type1
			icon_state = "grid"

		type2
			icon_state = "red"

		type3
			icon_state = "blue"

	wall
		text = "<font bgcolor=#777>#"
		icon = 'icons/sd_brickwall.dmi'
		density = 1
		opacity = 1

obj
	sword	// this is just here to demonstrate random placement
		icon = 'icons/sd_sword.dmi'

mob
	monster	// this is just here to demonstrate random placement
		text = "<font color='green'>@</font>"
		icon = 'icons/sd_monster.dmi'

		New()
			..()
			walk_rand(src)

sd_MapRoom/var/DirCheck = 0

mob
	text = "<font color='yellow'>@</font>"
	icon = 'icons/sd_yellow.dmi'
	sight = 30	// allows you to see everything within range

	Login()
		..()
		loc = locate(11,11,1)
		world << "<B>[src] logs in."

	Logout()
		..()
		del(src)

	verb
/*
		columns()
			set desc = "Removes all lone wall sections."
			set name = "clearcolumns"
			world << "Clearing lone columns. This could be done automatically by setting the <i>clearcolumns</i>  flag."

			for(var/X = 2, X < world.maxx, ++X)
				for(var/Y = 2, Y < world.maxy, ++Y)
				 if(istype(locate(X,Y,1),Maze.map_wall))
				 	if(!isfloor(locate(X-1,Y,1))) continue
				 	if(!isfloor(locate(X+1,Y,1))) continue
				 	if(!isfloor(locate(X,Y-1,1))) continue
				 	if(!isfloor(locate(X,Y+1,1))) continue
				 	new Maze.map_floor(locate(X,Y,1))

		generate()
			set desc = "Generate a new map with the current settings."
			Maze.map_floor = mapfloor[rand(1,length(mapfloor))]	// choose a random floor type for Maze.map_passages
			Maze.map_passage = /turf/door

			world << "[usr] generates a map..."
			Maze.Generate(1,world.maxx,1,world.maxy,1)
*/
		mazematrix()
			var/sd_MapMatrix/matrix = Maze.matrix
			var/sd_mappoint/P
			for(var/Y = matrix.SizY to 1 step -1)
				for(var/X = 1 to matrix.SizX)
					P = matrix.MapGrid[X][Y]
					src << "[P.maptype]\..."
				src << " "

		passages()
			/* This verb demonstrates how to liven up the bare bones map
			by varying the items that were placed. It alters the doors
			placed by the MapMaker to become arches, empty passages, or
			remain as a door. You could use a similar proc to specialize
			walls or floors.
			*/
			set desc = "Make varying passages on an existing map instead of them all being plain ugly doors."
			var/turf/Turf

			// loop through all the map area
			for(var/X = 1, X <= world.maxx, X++)
				for(var/Y = 1, Y <= world.maxx, Y++)
					Turf = locate(X,Y,1)

					if(istype(Turf,Maze.map_passage))	// test if this is a passage
						switch(rand(1,3))
							if(1)	// make it an arch with floorspace underlay
								var/turf/Near = nearfloor(Turf)
								if(Near)
									// make a new arch at Turf
									Turf = new/turf/arch(Turf)
									// give it an underlay to match a near floor tile
									Turf.underlays += Near

							if(2)	// make it a secret door
								var/turf/Near = nearfloor(Turf)
								if(Near)
									// make a new arch at Turf
									Turf = new/turf/door/secret_door(Turf)
									// give it an underlay to match a near floor tile
									Turf.underlays += Near

							else	// default, leave it a door

		populate()
			/* This verb demonstrates how to populate a new map with mobs
			and objects into empty spaces on the map. With some
			modification, you could place torches and paintings on walls
			or any sort of effect you like.
			*/
			set desc = "Randomly place some mobs and objs."

			var/turf/Turf
			for(var/Number = rand(10,20), Number > 0 , Number--)
				do
					// find a random turf
					Turf = locate(rand(1,world.maxx),rand(1,world.maxy),1)
				// keep looking until you find a floor that's empty
				while(!isfloor(Turf) && Turf.contents)
				switch(rand(1,2))
					if(1)	// place a monster
						new/mob/monster(Turf)
					else	// place a sword
						new/obj/sword(Turf)

		say(T as text)
			world << "[usr]:[T]"

		Sight()
			set desc = "Toggles between allseeing mode and normal game vision."
			if(sight)
				sight = 0
			else
				sight = 30

		Density()
			set desc = "Toggles mob density."
			density = !density

		who()
			for(var/mob/M in world)
				if(M.client)
					usr << M

proc
	isfloor(turf/T)
		for(var/X = 1, X <= length(mapfloor), ++X)
			if(istype(T,mapfloor[X])) return 1
		return 0

	nearfloor(turf/T)	// returns an adjacent floor, if any
		var/turf/Turf
		for(var/Dir in list(NORTH,EAST,SOUTH,WEST))
			Turf = get_step(T,Dir)
			if(isfloor(Turf)) return Turf
