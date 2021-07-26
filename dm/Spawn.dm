obj/spawns/
	layer = 10
	plane = 10
	spawnpointe1
		name = "Spawn Pointe1"
		/*
			This is the spawner object. Make sure
			to place it on the map!
		*/
		var/spawntype // mob.type it will spawn IE /mob/spawnbaby
		var/max_spawn = 1 // number at which it will generate no new mobs
		var/spawned = 0 // count of mobs spawned

		New()
			set waitfor = 0
			..()
			// initialize the list of mobs to be spawned
			spawn while (src) // More efficient to put in a loop like Deadron's event loop
				src.check_spawn() // start the spawn calls
				sleep(100)		// wait 10 secs
		proc/check_spawn() // called periodically to check to see if
						// any new mobs should be generated
			if(spawned < max_spawn)	// make sure we haven't reached limit
				var/mob/M = new spawntype(src.loc) // generate mob
				M.ownere1 = src
				spawned ++ // increment the counter
				//world << "[src] spits out \the [M.name]!"
				//world << "[src] can produce [max_spawn-spawned] more [M.name]s!"

	spawnpointe2
		name = "Spawn Pointe2"
		/*
			This is the spawner object. Make sure
			to place it on the map!
		*/
		var/spawntype // mob.type it will spawn IE /mob/spawnbaby
		var/max_spawn = 1 // number at which it will generate no new mobs
		var/spawned = 0 // count of mobs spawned

		New()
			set waitfor = 0
			..()
			// initialize the list of mobs to be spawned
			spawn while (src) // More efficient to put in a loop like Deadron's event loop
				src.check_spawn() // start the spawn calls
				sleep(100)		// wait 10 secs
		proc/check_spawn() // called periodically to check to see if
						// any new mobs should be generated
			if(spawned < max_spawn)	// make sure we haven't reached limit
				var/mob/M = new spawntype(src.loc) // generate mob
				M.ownere2 = src
				spawned ++ // increment the counter
				//world << "[src] spits out \the [M.name]!"
				//world << "[src] can produce [max_spawn-spawned] more [M.name]s!"
	spawnpointe3
		name = "Spawn Pointe3"
		/*
			This is the spawner object. Make sure
			to place it on the map!
		*/
		var/spawntype // mob.type it will spawn IE /mob/spawnbaby
		var/max_spawn = 1 // number at which it will generate no new mobs
		var/spawned = 0 // count of mobs spawned

		New()
			set waitfor = 0
			..()
			// initialize the list of mobs to be spawned
			spawn while (src) // More efficient to put in a loop like Deadron's event loop
				src.check_spawn() // start the spawn calls
				sleep(100)		// wait 10 secs
		proc/check_spawn() // called periodically to check to see if
						// any new mobs should be generated
			if(spawned < max_spawn)	// make sure we haven't reached limit
				var/mob/M = new spawntype(src.loc) // generate mob
				M.ownere3 = src
				spawned ++ // increment the counter
				//world << "[src] spits out \the [M.name]!"
				//world << "[src] can produce [max_spawn-spawned] more [M.name]s!"
	spawnpointe4
		name = "Spawn Pointe4"
		/*
			This is the spawner object. Make sure
			to place it on the map!
		*/
		var/spawntype // mob.type it will spawn IE /mob/spawnbaby
		var/max_spawn = 1 // number at which it will generate no new mobs
		var/spawned = 0 // count of mobs spawned

		New()
			set waitfor = 0
			..()
			// initialize the list of mobs to be spawned
			spawn while (src) // More efficient to put in a loop like Deadron's event loop
				src.check_spawn() // start the spawn calls
				sleep(100)		// wait 10 secs
		proc/check_spawn() // called periodically to check to see if
						// any new mobs should be generated
			if(spawned < max_spawn)	// make sure we haven't reached limit
				var/mob/M = new spawntype(src.loc) // generate mob
				M.ownere4 = src
				spawned ++ // increment the counter
				//world << "[src] spits out \the [M.name]!"
				//world << "[src] can produce [max_spawn-spawned] more [M.name]s!"
	spawnpointe5
		name = "Spawn Pointe5"
		/*
			This is the spawner object. Make sure
			to place it on the map!
		*/
		var/spawntype // mob.type it will spawn IE /mob/spawnbaby
		var/max_spawn = 1 // number at which it will generate no new mobs
		var/spawned = 0 // count of mobs spawned

		New()
			set waitfor = 0
			..()
			// initialize the list of mobs to be spawned
			spawn while (src) // More efficient to put in a loop like Deadron's event loop
				src.check_spawn() // start the spawn calls
				sleep(100)		// wait 10 secs
		proc/check_spawn() // called periodically to check to see if
						// any new mobs should be generated
			if(spawned < max_spawn)	// make sure we haven't reached limit
				var/mob/M = new spawntype(src.loc) // generate mob
				M.ownere5 = src
				spawned ++ // increment the counter
				//world << "[src] spits out \the [M.name]!"
				//world << "[src] can produce [max_spawn-spawned] more [M.name]s!"

	spawnpointe6
		name = "Spawn Pointe6"
		/*
			This is the spawner object. Make sure
			to place it on the map!
		*/
		var/spawntype // mob.type it will spawn IE /mob/spawnbaby
		var/max_spawn = 1 // number at which it will generate no new mobs
		var/spawned = 0 // count of mobs spawned

		New()
			set waitfor = 0
			..()
			// initialize the list of mobs to be spawned
			spawn while (src) // More efficient to put in a loop like Deadron's event loop
				src.check_spawn() // start the spawn calls
				sleep(100)		// wait 10 secs
		proc/check_spawn() // called periodically to check to see if
						// any new mobs should be generated
			if(spawned < max_spawn)	// make sure we haven't reached limit
				var/mob/M = new spawntype(src.loc) // generate mob
				M.ownere6 = src
				spawned ++ // increment the counter
				//world << "[src] spits out \the [M.name]!"
				//world << "[src] can produce [max_spawn-spawned] more [M.name]s!"

	spawnpointe7
		name = "Spawn Pointe7"
		/*
			This is the spawner object. Make sure
			to place it on the map!
		*/
		var/spawntype // mob.type it will spawn IE /mob/spawnbaby
		var/max_spawn = 1 // number at which it will generate no new mobs
		var/spawned = 0 // count of mobs spawned

		New()
			set waitfor = 0
			..()
			// initialize the list of mobs to be spawned
			spawn while (src) // More efficient to put in a loop like Deadron's event loop
				src.check_spawn() // start the spawn calls
				sleep(100)		// wait 10 secs
		proc/check_spawn() // called periodically to check to see if
						// any new mobs should be generated
			if(spawned < max_spawn)	// make sure we haven't reached limit
				var/mob/M = new spawntype(src.loc) // generate mob
				M.ownere7 = src
				spawned ++ // increment the counter
				//world << "[src] spits out \the [M.name]!"
				//world << "[src] can produce [max_spawn-spawned] more [M.name]s!"

	spawnpointe8
		name = "Spawn Pointe8"
		/*
			This is the spawner object. Make sure
			to place it on the map!
		*/
		var/spawntype // mob.type it will spawn IE /mob/spawnbaby
		var/max_spawn = 1 // number at which it will generate no new mobs
		var/spawned = 0 // count of mobs spawned

		New()
			set waitfor = 0
			..()
			// initialize the list of mobs to be spawned
			spawn while (src) // More efficient to put in a loop like Deadron's event loop
				src.check_spawn() // start the spawn calls
				sleep(100)		// wait 10 secs
		proc/check_spawn() // called periodically to check to see if
						// any new mobs should be generated
			if(spawned < max_spawn)	// make sure we haven't reached limit
				var/mob/M = new spawntype(src.loc) // generate mob
				M.ownere8 = src
				spawned ++ // increment the counter
				//world << "[src] spits out \the [M.name]!"
				//world << "[src] can produce [max_spawn-spawned] more [M.name]s!"
	spawnpointe9
		name = "Spawn Pointe9"
		/*
			This is the spawner object. Make sure
			to place it on the map!
		*/
		var/spawntype // mob.type it will spawn IE /mob/spawnbaby
		var/max_spawn = 1 // number at which it will generate no new mobs
		var/spawned = 0 // count of mobs spawned

		New()
			set waitfor = 0
			..()
			// initialize the list of mobs to be spawned
			spawn while (src) // More efficient to put in a loop like Deadron's event loop
				src.check_spawn() // start the spawn calls
				sleep(100)		// wait 10 secs
		proc/check_spawn() // called periodically to check to see if
						// any new mobs should be generated
			if(spawned < max_spawn)	// make sure we haven't reached limit
				var/mob/M = new spawntype(src.loc) // generate mob
				M.ownere9 = src
				spawned ++ // increment the counter
				//world << "[src] spits out \the [M.name]!"
				//world << "[src] can produce [max_spawn-spawned] more [M.name]s!"

	spawnpointe10
		name = "Spawn Pointe10"
		/*
			This is the spawner object. Make sure
			to place it on the map!
		*/
		var/spawntype // mob.type it will spawn IE /mob/spawnbaby
		var/max_spawn = 1 // number at which it will generate no new mobs
		var/spawned = 0 // count of mobs spawned

		New()
			set waitfor = 0
			..()
			// initialize the list of mobs to be spawned
			spawn while (src) // More efficient to put in a loop like Deadron's event loop
				src.check_spawn() // start the spawn calls
				sleep(100)		// wait 10 secs
		proc/check_spawn() // called periodically to check to see if
						// any new mobs should be generated
			if(spawned < max_spawn)	// make sure we haven't reached limit
				var/mob/M = new spawntype(src.loc) // generate mob
				M.ownere10 = src
				spawned ++ // increment the counter
				//world << "[src] spits out \the [M.name]!"
				//world << "[src] can produce [max_spawn-spawned] more [M.name]s!"
	spawnpointe11
		name = "Spawn Pointe11"
		/*
			This is the spawner object. Make sure
			to place it on the map!
		*/
		var/spawntype // mob.type it will spawn IE /mob/spawnbaby
		var/max_spawn = 1 // number at which it will generate no new mobs
		var/spawned = 0 // count of mobs spawned

		New()
			set waitfor = 0
			..()
			// initialize the list of mobs to be spawned
			spawn while (src) // More efficient to put in a loop like Deadron's event loop
				src.check_spawn() // start the spawn calls
				sleep(100)		// wait 10 secs
		proc/check_spawn() // called periodically to check to see if
						// any new mobs should be generated
			if(spawned < max_spawn)	// make sure we haven't reached limit
				var/mob/M = new spawntype(src.loc) // generate mob
				M.ownere11 = src
				spawned ++ // increment the counter
				//world << "[src] spits out \the [M.name]!"
				//world << "[src] can produce [max_spawn-spawned] more [M.name]s!"
	spawnpointB2
		name = "Spawn PointB2"
		/*
			This is the spawner object. Make sure
			to place it on the map!
		*/
		var/spawntype2 // mob.type it will spawn IE /mob/spawnbaby
		var/max_spawn = 1 // number at which it will generate no new mobs
		var/spawned = 0 // count of mobs spawned
		/*DblClick()
			set category=null
			set popup_menu = 1
			if(src in range(1, usr))
				Search()
				//M << "The Tree makes a Hallow sound."
				sleep(10)
		proc/Search()
			//set hidden = 1
			set category=null
			set popup_menu = 1
			var/mob/players/M = usr
			var/dice = "1d4"
			var/R = roll(dice)
			if(R<=2)
				sleep(15)
				//if(R.chance(31))
				new /obj/items/Seeds/Raspberryseed(M)
				M << "You find a Raspberry Seed!"
			else
				M << "You inspect the bush..."
				sleep(7)
				M << "Nothing out of the ordinary here."
				return
			if(R>=2)
				sleep(15)
				//if(R.chance(21))
				new /obj/items/Seeds/Blueberryseed(M)
				M << "You find a Blueberry Seed!"
			else
				M << "You search the bush..."
				sleep(7)
				M << "Nothing out of the ordinary here."
				return*/
		New()
			set waitfor = 0
			..()
			// initialize the list of mobs to be spawned
			if(global.season!="Winter")
				spawn while (src) // More efficient to put in a loop like Deadron's event loop
					src.check_spawn() // start the spawn calls
					sleep(100)		// wait 10 secs
			else return

		proc/check_spawn() // called periodically to check to see if
						// any new mobs should be generated
			if(global.season!="Winter"&&(spawned < max_spawn))//&&(hour == 5 && minute1 == 5 && minute2 == 9 && ampm == "am"))	// make sure we haven't reached limit
				var/mob/M = new spawntype2(src.loc) // generate mob
				M.ownerB2 = src
				spawned ++ // increment the counter
				//world << "[src] spits out \the [M.name]!"
				//world << "[src] can produce [max_spawn-spawned] more [M.name]s!"
			/*if(hour == 4 && minute1 == 5 && minute2 == 9 && ampm == "pm")
				for(spawntype2 in world)
					Del()
				..()*/

mob
	var/atom/ownere1
	Del()
		if (ownere1 && istype(ownere1, /obj/spawns/spawnpointe1))
			var/obj/spawns/spawnpointe1/O = ownere1
			O.spawned -- // make sure its spawner is adjusted!
		..()

	var/atom/ownere2
	Del()
		if (ownere2 && istype(ownere2, /obj/spawns/spawnpointe2))
			var/obj/spawns/spawnpointe2/O = ownere2
			O.spawned -- // make sure its spawner is adjusted!
		..()

	var/atom/ownere3
	Del()
		if (ownere3 && istype(ownere3, /obj/spawns/spawnpointe3))
			var/obj/spawns/spawnpointe3/O = ownere3
			O.spawned -- // make sure its spawner is adjusted!
		..()

	var/atom/ownere4
	Del()
		if (ownere4 && istype(ownere4, /obj/spawns/spawnpointe4))
			var/obj/spawns/spawnpointe4/O = ownere4
			O.spawned -- // make sure its spawner is adjusted!
		..()

	var/atom/ownere5
	Del()
		if (ownere5 && istype(ownere5, /obj/spawns/spawnpointe5))
			var/obj/spawns/spawnpointe5/O = ownere5
			O.spawned -- // make sure its spawner is adjusted!
		..()

	var/atom/ownere6
	Del()
		if (ownere6 && istype(ownere6, /obj/spawns/spawnpointe6))
			var/obj/spawns/spawnpointe6/O = ownere6
			O.spawned -- // make sure its spawner is adjusted!
		..()

	var/atom/ownere7
	Del()
		if (ownere7 && istype(ownere7, /obj/spawns/spawnpointe7))
			var/obj/spawns/spawnpointe7/O = ownere7
			O.spawned -- // make sure its spawner is adjusted!
		..()

	var/atom/ownere8
	Del()
		if (ownere8 && istype(ownere8, /obj/spawns/spawnpointe8))
			var/obj/spawns/spawnpointe8/O = ownere8
			O.spawned -- // make sure its spawner is adjusted!
		..()

	var/atom/ownere9
	Del()
		if (ownere9 && istype(ownere9, /obj/spawns/spawnpointe9))
			var/obj/spawns/spawnpointe9/O = ownere9
			O.spawned -- // make sure its spawner is adjusted!
		..()
	var/atom/ownere10
	Del()
		if (ownere10 && istype(ownere10, /obj/spawns/spawnpointe10))
			var/obj/spawns/spawnpointe10/O = ownere10
			O.spawned -- // make sure its spawner is adjusted!
		..()
	var/atom/ownere11
	Del()
		if (ownere11 && istype(ownere11, /obj/spawns/spawnpointe11))
			var/obj/spawns/spawnpointe11/O = ownere11
			O.spawned -- // make sure its spawner is adjusted!
		..()
	var/atom/ownerB2
	Del()
		if(ownerB2 && istype(ownerB2, /obj/spawns/spawnpointB2))
			var/obj/spawns/spawnpointB2/O = ownerB2
			O.spawned --
		..()


obj/spawns/
	spawnpointe1
		//icon = 'dmi/64/ene.dmi'
		//icon_state = "Giu"
		spawntype = /mob/enemies/Giu
	spawnpointe2
		//icon = 'dmi/64/ene.dmi'
		//icon_state = "Gou"
		spawntype = /mob/enemies/Gou
	spawnpointe3
		//icon = 'dmi/64/ene.dmi'
		//icon_state = "Gow"
		spawntype = /mob/enemies/Gow
	spawnpointe4
		//icon = 'dmi/64/ene.dmi'
		//icon_state = "Gowu"
		spawntype = /mob/enemies/Gowu
	spawnpointe5
		//icon = 'dmi/64/ene.dmi'
		//icon_state = "Gowl"
		spawntype = /mob/enemies/Gowl //icons need made ^v Diag frames need made
	spawnpointe6
		//icon = 'dmi/64/ene.dmi'
		//icon_state = "Guwi"
		spawntype = /mob/enemies/Guwi
	spawnpointe7
		//icon = 'dmi/64/ene.dmi'
		//icon_state = "Giuwo"
		spawntype = /mob/enemies/Giuwo
	spawnpointe8
		//icon = 'dmi/64/ene.dmi'
		//icon_state = "Gouwo"
		spawntype = /mob/enemies/Gouwo//up to 8 is available, the rest need icons
	spawnpointe9
		//icon = 'dmi/64/ene.dmi'
		spawntype = /mob/enemies/Gowwi //icons need made
	spawnpointe10
		//icon = 'dmi/64/ene.dmi'
		spawntype = /mob/enemies/Guwwi //icons need made
	spawnpointe11
		//icon = 'dmi/64/ene.dmi'
		spawntype = /mob/enemies/Gowwu //icons need made
	spawnpointB2
		//icon = 'dmi/64/plants.dmi'
		density = 0
		spawntype2 = /mob/insects/PLRButterfly
/*mob
	rabbit
		icon = 'dmi/64/food.dmi'
		icon_state = "rabbit"
		name = "Rabbit"*/
