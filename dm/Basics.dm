//#include "SwapMaps.dm"
/*

What is taken shall be given too.
[Note: 95-99% of the commentation is not mine, a lot of it is butchered from the find & replace]

*/
var
	bans[0]// global variables for banning people
	partycounter=0// and counting the number of parties
	obj/plant/ueiktree/Treesgs = new//tree const var for growth stages
	obj/Plants/Plantsgs = new//bush const var for growth stages
	//years_found
	//date = "[day] / [month] / [year] O�C | [hour]: [minute1][minute2][ampm]"
//mob/var
//	special_features
//client
//    parent_type = /datum
/*client
	if(bans.Find(src.ckey)) // obviously I didn't want you in my game if you are in that array of banned people
		usr << "Your character has been killed and you have been Removed from the server."
		bans.len++
		del(src) // get out! =]
	else return 0*/
	/*if(findtextEx(key,"Guest-",1))
		src<<"No guests"
		del(src)
	..()*/
/*client
	Move()
		if(!mob.umsl_ObtainMultiLock(list("right leg", "left leg"), 2.0))
			mob.umsl_ObtainMultiLock(list("right leg", "left leg"), 2.0)
		else return ..()
	proc/SetLock()
		if(!mob.umsl_ObtainMultiLock(list("right leg", "left leg"), 2.0))
			//mob.umsl_ObtainMultiLock(list("right leg", "left leg"), 2.0)
		else return ..()*/

mob
	has_reflection = 1
mob/var
	special_features
	//years_found
	//date = "[day] / [month] / [year] O�C | [hour]: [minute1][minute2][ampm]"
var/global/sl=0
mob/players
	layer = 9
	glide_size = 4
	//step_size = 64
	animate_movement = 1
	step_x = 32
	step_y = 32
	//opaque = 1
	//plane = 2
	//light = /light/circle
	var // player variables
		tmp/list/_listening_soundmobs = null
		tmp/list/_channels_taken = null
		speed = 3
		walk = 0
		run = 0
		pvekills = 0
		pvpkills = 0
		affinity = 0
		gr = 0
		char_class // your class
		nomotion = 0 // talking to a shopkeeper?  you can't move. this lets us know when you shouldn't be able to.
		muted = 0 // no speaking for you.
		cheats = 0
		level // your level?  most likely =] my code isnt that obfuscated
		HP
		MAXHP
		stamina
		MAXstamina
		exp = 0 // yep
		expneeded = 0 // yep yep
		expgive = 0 // pvpexp?
		oldexp = 0 // i think this might be used in the exp meter for calculations, better to make it a variable here than calculate every time
		bankedlucre = 0 // Bank by Ripper man5
		lucre = 0 // money.  buy stuff.
		attackspeed // used in calculating the delay between attacks, affected by weapons
		poisoned = 0 // are you poisoned?  this is boolean
		poisonD // this has to do with how long you were poisoned for
		poisonDMG // this has to do with the damage done each time you are damaged
		inparty=0 // if you are in a party, boolean
		partynumber=0 // which party number are you in?
		awaymessage = "" // your away message
		away = 0 // if you are away, boolean
		location = "" // where you are for the Who tab
		forts[0] // array holding the names of forts you've visited for Warping (not setup)
		Strength = 0 // strength variable
		Spirit = 0 // intelligence
		/*
		//resistances
		fireres = 0
		iceres = 0
		windres = 0
		watres = 0
		earthres = 0
		//Weaknesses
		Firewk = 0
		Icewk = 1
		Windwk = 0
		Watwk = 1
		Earthwk = 0*/
		warpbookgrave = 0; quest = 0; // quest booleans so that you only do them once
		//magi levels
		heatlevel = 0
		shardburstlevel = 0
		watershocklevel = 0
		vitaelevel = 0
		vitae2level = 0
		flamelevel = 0
		icestormlevel = 0
		cascadelightninglevel = 0
		telekinesislevel = 0
		abjurelevel = 0
		cosmoslevel = 0
		rephaselevel = 0
		acidlevel = 0
		bludgeonlevel = 0
		quietuslevel = 0
		panacealevel = 0
		music_off = 0
		music
		medal1
		medal2
		mininglevel = 1
		mexp = 0
		mexpneeded = 5
		mexpgive = 0
		hexp = 0
		hexpneeded = 5
		hexpgive = 0
		huntinglevel = 1
		smithinglevel = 1
		sexp = 0
		sexpneeded = 5
		sexpgive = 0
		searchinglevel = 1
		seexp = 0
		seexpneeded = 5
		seexpgive = 0
		smeltinglevel = 1
		smexp = 0
		smexpneeded = 5
		smexpgive = 0
		destroylevel = 1
		dexp = 0
		dexpneeded = 5
		dexpgive = 0
		fishinglevel = 1
		fexp = 0
		fexpneeded = 5
		fexpgive = 0
		gexp = 0
		gexpneeded = 5
		gexpgive = 0
		Doing = 0
		PickAxe = 0
		liquid = 0
		plantable = 0
		cooking = 0
		growing = 0
		alive = 0
		iron = /obj/items/Ore/iron
		zinc = /obj/items/Ore/zinc
		copper = /obj/items/Ore/copper
		ironbar = 0
		zincbar = 0
		copperbar = 0
		// Character Data Datum - centralized skill/progression storage
		datum/character_data/character
		brank = 0 //buildingrank
		drank = 0 //diggingrank
		frank = 0 //fighting rank?
		hrank = 0 //huntingrank (woodcutting)
		grank = 0 //gardening rank
		smirank = 0 //smithing rank
		smerank = 0 //smelting rank
		smiexp = 0
		smeexp = 0
		buildexp = 0
		fightexp = 0
		digexp = 0
		huntexp = 0
		grankEXP = 0
		grankMAXEXP = 100
		MAXgrankLVL = 0
		msmiexp = 100
		msmeexp = 100
		mhuntexp = 100
		mbuildexp = 100
		mdigexp = 100
		mfightexp = 100
		// Carving, Sprout Cutting, Pole ranks (moved from global in WC.dm)
		Crank = 0
		CrankEXP = 0
		CrankMAXEXP = 10
		CSRank = 0
		CSRankEXP = 0
		CSRankMAXEXP = 10
		PLRank = 0
		PLRankEXP = 0
		PLRankMAXEXP = 100
		hrankEXP = 0
		hrankMAXEXP = 10
		frankEXP = 0
		frankMAXEXP = 100
		crank = 0
		brankEXP = 0
		brankMAXEXP = 100
		drankEXP = 0
		drankMAXEXP = 100
		needrev = 1
		UEB = 0
		UED = 0
		UESME = 0
		UETW = 0
		tutopen = 0
		deedopen = 0
		canbuild = 0
		canpickup = 0
		candrop = 0
		permallow = 0
		SMIopen = 0
		SMEopen = 0
		thirsty=0
		hungry=0
		fed = 0
		hydrated = 0
	/*proc/hungercheck()
		set waitfor=0
		var/randomvalue = rand(1200,2000)
		var/delay = rand(12000,20000)
		var/mob/players/M
		M = usr
		spawn(randomvalue)
			for(M)
				if(M.stamina >= M.MAXstamina)
					sleep(delay)
					M.hungry=1
					return
				else


	proc/thirstcheck()
		var/randomvalue = rand(1200,2000)
		var/mob/players/M
		M = usr
		spawn(randomvalue)*/
		birthdatefed
		birthdatehydrated
		minute

	New()
		..()
		src.updateHP()
		src.updateST()
		if(src.loc==locate(x,y,2))//this doesn't need to scan player location because it is set when they enter locations; As long as they're entering z level 2, they are entering Aldoryn..
			src.location = "Aldoryn"
		//light = new /light/circle(src, 4)
		//src.umsl_ObtainMultiLock(list("right leg", "left leg"), 2.0)
		birthdatefed = world.timeofday
		birthdatehydrated = world.timeofday
		if(client && _autotune_soundmobs)
			for(var/soundmob/soundmob in _autotune_soundmobs)
				listenSoundmob(soundmob)
		//if(!spotlight)
			//client.draw_lighting_plane()
			//return ..()
		//src.remove_spotlight()
		//if(src!=null&&src.loc!=null)
		//this line is presenting an issue (if you comment it out, the shading doesn't go away if you boot up during daytime)
		//minute = time2text(world.timeofday,"mm")
		spawn
			var/mob/players/M
			M = usr
			if(M.poisoned==1) // if you recently got poisoned

				//spawn(0) poisoned(M)
				poisoned(M)//testing if moving this out of the stat panel (which I don't know why it was there to begin with) and removing the additional spawn works.
			else
				return

		spawn while(src!=null)//hunger and thirst
			S
			src.fed = 0
			src.hydrated = 0
			//src<<"[minute] > [birthdatefed]"//compares the current minute to the last set moment
			sleep(6000)//6000

			minute = world.timeofday//sets the time that has passed since last set
			//src<<"[minute] > [birthdatefed]"
			if(src.fed==1)//if they have eaten any items or drank any tonics set to 1
				birthdatefed = world.timeofday//set a new moment in time
				goto S
			if(src.hydrated==1)//if they have eaten any items or drank any tonics set to 1
				birthdatehydrated = world.timeofday
				goto S
			if(src.minute > src.birthdatefed&&src.fed==0)//if the time passed is greater than the last moment set
				src.hungry=1//set these vars that allow the hunger health and thirst stamina ticks to hit
				M << "Your stomach growls, find some thing to eat."
			if(src.minute > src.birthdatehydrated&&src.hydrated==0)//if the time passed is greater than the last moment set
				src.thirsty=1
				M << "You are parched, find something to drink."
			if(src.fed==1)//if the minutes aren't greater than the last set moment, restart
				src.hungry=0//they're not hungry yet
				//src.thirsty=0//they're not thirsty yet
				goto S
			if(src.hydrated==1)//if the minutes aren't greater than the last set moment, restart
				//src.hungry=0//they're not hungry yet
				src.thirsty=0//they're not thirsty yet
				goto S
			if(src:hungry==1) src:HP=src:HP-1//health tick for hunger damage
			else if(src:hungry==0) goto S
			if(src:thirsty==1) src:stamina=src:stamina-1//stamina tick for thirst damage
			else if(src:thirsty==0) goto S
			if(src.HP<=0)//HP check and fall check
				src.HP = 0
				src.checkdeadplayer2()
			if(src.stamina<=0)
				src.stamina = 0
			goto S

			//if(M.hungry==1)
			//	hungercheck(M)

			//else return
			//if(M.thirsty==1)
			//	thirstcheck(M)

			//else return
		//new /light/circle(src, 4)//does this need to be set static so time/light cycle isn't interrupted when a new player joins?
		//light.off()
		//I think loading character breaking sound might have to do with this spawn line creating two sets of sounds
		//call(/world/proc/Spellbookspawner)()
		//spawn() if(client && _autotune_soundmobs) for(var/soundmob/soundmob in _autotune_soundmobs) listenSoundmob(soundmob)

		//src.listenSoundmob(/soundmob)
		//..()
				// we make the lamps have directional light sources,
				// the /light/directional object is defined at the
				// top of this file.
		//mlight.transform = m
		//usr.new /light/circle(src.loc, 3)
		//pvptest=1

	Logout()
	//for(var/mob/players/P)
		//var/light/day_night/L
		//var/list/effect/E
			//winset(src,"default.Bludgeon","is-visible=false")
		//src.umsl_ClearLock("right leg")
		//src.umsl_ClearLock("left leg")
		if(src.Doing==1 || src.Carving==1 || src.Cutting==1 || src.Picking==1 || src.Mining==1)
			src.Doing=0
			src.Carving=0
			src.Cutting=0
			src.Picking=0
			src.Mining=0
		browse_once=0
		leaveparty(src)
		//if(src.light in lighting.lights)
		//	lighting.lights -= src.light//this is the fix I have been looking for! Enables light garbage collection at logout so there are no null runtime errors! Hooray.

		//call(/soundmob/proc/unsetListeners)(_listening_soundmobs)
		for(var/soundmob/soundmob in src._listening_soundmobs)
			if(src in soundmob.listeners)
				soundmob.listeners-=src

		for(var/soundmob/soundmob in src._attached_soundmobs)
			for(var/mob/players/X in soundmob.listeners)
				X:_listening_soundmobs-=soundmob
			soundmob.listeners=new

		_attached_soundmobs = new
		_listening_soundmobs = new
		_autotune_soundmobs = new

		//call(/atom/proc/unsetListener)()
		//sl=0
		//L.RemoveFromStack(src)
		//src.light -= lighting.lights
		//lighting.lights -= src
		//light -= lighting.lights
		world << "<font color = blue><b>[src] dissipated out of this world."
		del(src)
		//return
		//world << "<font color = yellow><b>[usr] dissipated out of this world."


	//Del()
		//if(_listening_soundmobs) for(var/soundmob/soundmob in _listening_soundmobs) unlistenSoundmob(soundmob)

		//..()
	//give em a nice picture
	icon = 'dmi/64/char.dmi'
	Feline
		char_class = "Feline"
		icon_state = "Kitty"
		location = ""
		attackspeed = 8
		level = 1 // your level?  most likely =] my code isnt that obfuscated
		HP = 210 // life
		MAXHP = 210 // maxlife
		stamina = 500 // yadda
		MAXstamina = 500 // yadda yadda
		tempdefense = 0
		tempevade = 10
		exp = 0 // yep
		expneeded = 125 // yep yep
		expgive = 40 // hrmm. never istaminalimented pvp experience.  guess this just stuck around from before i made seperate mob classes for players and enemies
		bankedlucre = 0 // Bank by Ripper man5
		lucre = 0 // mmmmm money.  buy stuff.
		Strength = 2 // strength variable
		Spirit = 6 // intelligence
		drank = 1
		frank = 1
		grank = 1
		//Resistances
		fireres = 0
		iceres = 1
		windres = 1
		watres = 0
		earthres = 1
		poisres = 0
		//Weaknesses
		firewk = 1
		icewk = 0
		windwk = 0
		watwk = 1
		earthwk = 0
		poiswk = 1
		//magi levels
		heatlevel = 0
		shardburstlevel = 0
		watershocklevel = 0
		vitaelevel = 0
		vitae2level = 0
		flamelevel = 0
		icestormlevel = 0
		cascadelightninglevel = 0
		telekinesislevel = 0
		abjurelevel = 1
		cosmoslevel = 0
		rephaselevel = 0
		acidlevel = 0
		bludgeonlevel = 0
		quietuslevel = 0
		panacealevel = 0
		pvpkills = 0
		//UEB = 0
	Landscaper
		char_class = "Landscaper"
		icon_state = "friar"
		location = ""
		attackspeed = 6
		level = 1 // your level?  most likely =] my code isnt that obfuscated
		HP = 310 // life
		MAXHP = 310 // maxlife
		stamina = 500 // yadda
		MAXstamina = 500 // yadda yadda
		tempdefense = 4
		tempevade = 5
		exp = 0 // yep
		expneeded = 125 // yep yep
		expgive = 40 // hrmm. never istaminalimented pvp experience.  guess this just stuck around from before i made seperate mob classes for players and enemies
		bankedlucre = 10 // Bank by Ripper man5
		lucre = 10 // mmmmm money.  buy stuff.
		Strength = 7 // strength variable
		Spirit = 3 // intelligence
		//frank = 1
		drank = 1
		hrank = 1
		grank = 1
		//Resistances
		fireres = 0
		iceres = 0
		windres = 1
		watres = 0
		earthres = 1
		poisres = 1
		//Weaknesses
		firewk = 1
		icewk = 1
		windwk = 0
		watwk = 1
		earthwk = 0
		poiswk = 0
		//magi levels
		heatlevel = 0
		shardburstlevel = 0
		watershocklevel = 0
		vitaelevel = 0
		vitae2level = 0
		flamelevel = 0
		icestormlevel = 0
		cascadelightninglevel = 0
		telekinesislevel = 0
		abjurelevel = 0
		cosmoslevel = 0
		rephaselevel = 0
		acidlevel = 0
		bludgeonlevel = 0
		quietuslevel = 0
		panacealevel = 0
		pvpkills = 0
		//UEB = 0
	Builder
		char_class = "Builder"
		icon_state = "theurgist"
		location = ""
		brank = 1
		hrank = 1
		//frank = 1
		smirank=1
		smerank=1
		buildexp=0
		attackspeed = 5
		level = 1 // your level?  most likely =] my code isnt that obfuscated
		HP = 390 // life
		MAXHP = 390 // maxlife
		stamina = 500 // yadda
		MAXstamina = 500 // yadda yadda
		tempdefense = 5
		tempevade = 3
		//Lamount = 0
		exp = 0 // yep
		expneeded = 135 // yep yep
		expgive = 10 // hrmm. never istaminalimented pvp experience.  guess this just stuck around from before i made seperate mob classes for players and enemies
		bankedlucre = 10 // Bank by Ripper man5
		lucre = 100 // mmmmm money.  buy stuff.
		Strength = 6 // strength variable
		Spirit = 4 // intelligence
		//Resistances
		fireres = 0
		iceres = 0
		windres = 0
		watres = 0
		earthres = 0
		poisres = 0
		//Weaknesses
		firewk = 1
		icewk = 1
		windwk = 1
		watwk = 1
		earthwk = 1
		poiswk = 1
		//magi levels
		heatlevel = 0
		shardburstlevel = 0
		watershocklevel = 0
		vitaelevel = 0
		vitae2level = 0
		flamelevel = 0
		icestormlevel = 0
		cascadelightninglevel = 0
		telekinesislevel = 0
		abjurelevel = 0
		cosmoslevel = 0
		rephaselevel = 0
		acidlevel = 0
		bludgeonlevel = 0
		quietuslevel = 0
		panacealevel = 0
		UEB = 0
		SMIopen = 0
		SMEopen = 0
		pvpkills = 0
	Smithy
		char_class = "Smithy"
		icon_state = "fighter"
		location = ""
		attackspeed = 4
		level = 1 // your level?  most likely =] my code isnt that obfuscated
		HP = 345 // life
		MAXHP = 345 // maxlife
		stamina = 500 // yadda
		MAXstamina = 500 // yadda yadda
		tempdefense = 10
		tempevade = 1
		exp = 0 // yep
		expneeded = 145 // yep yep
		expgive = 50 // hrmm. never istaminalimented pvp experience.  guess this just stuck around from before i made seperate mob classes for players and enemies
		bankedlucre = 10 // Bank by Ripper man5
		lucre = 10 // mmmmm money.  buy stuff.
		Strength = 7 // strength variable
		Spirit = 5 // intelligence
		frank = 1
		hrank = 1
		smirank=1
		smerank=1
		//Resistances
		fireres = 0
		iceres = 1
		windres = 1
		watres = 1
		earthres = 0
		poisres = 1
		//Weaknesses
		firewk = 1
		icewk = 0
		windwk = 0
		watwk = 0
		earthwk = 1
		poiswk = 0
		//magi levels
		heatlevel = 0
		shardburstlevel = 0
		watershocklevel = 0
		vitaelevel = 0
		vitae2level = 0
		flamelevel = 0
		icestormlevel = 0
		cascadelightninglevel = 0
		telekinesislevel = 0
		abjurelevel = 0
		cosmoslevel = 0
		rephaselevel = 0
		acidlevel = 0
		bludgeonlevel = 0
		quietuslevel = 0
		panacealevel = 0
		pvpkills = 0
		//UEB = 0
	Magus
		char_class = "Magus"
		icon_state = "magus"
		location = ""
		attackspeed = 7
		level = 1 // your level?  most likely =] my code isnt that obfuscated
		HP = 365 // life
		MAXHP = 365 // maxlife
		stamina = 500 // yadda
		MAXstamina = 500 // yadda yadda
		tempdefense = 2
		tempevade = 0
		exp = 0 // yep
		expneeded = 155 // yep yep
		expgive = 20 // hrmm. never istaminalimented pvp experience.  guess this just stuck around from before i made seperate mob classes for players and enemies
		bankedlucre = 10 // Bank by Ripper man5
		lucre = 10 // mmmmm money.  buy stuff.
		Strength = 4 // strength variable
		Spirit = 12 // intelligence
		hrank = 1
		frank = 1
		//Resistances
		fireres = 1
		iceres = 0
		windres = 1
		watres = 0
		earthres = 1
		poisres = 0
		//Weaknesses
		firewk = 0
		icewk = 1
		windwk = 0
		watwk = 1
		earthwk = 0
		poiswk = 0
		//magi levels
		heatlevel = 1
		shardburstlevel = 1
		watershocklevel = 1
		vitaelevel = 0
		vitae2level = 0
		flamelevel = 1
		icestormlevel = 1
		cascadelightninglevel = 0
		telekinesislevel = 0
		abjurelevel = 1
		cosmoslevel = 0
		rephaselevel = 1
		acidlevel = 1
		bludgeonlevel = 0
		quietuslevel = 1
		panacealevel = 0
		pvpkills = 0
		//UEB = 0
	// GM
	Special1
		char_class = "GM"
		//icon = 'dmi/64/gm.dmi'
		icon_state = "Kitty"
		location = ""
		attackspeed = 13
		brank=1//building rank
		hrank=1//harvesting rank
		frank=1//fighting rank?
		drank=1//digging rank
		grank=1//gardening rank
		smirank=1//smithing rank
		smerank=1//smelting rank
		buildexp=0
		level = 9999 // your level?  most likely =] my code isnt that obfuscated
		HP = 99999 // life
		MAXHP = 99999 // maxlife
		stamina = 99999 // yadda
		MAXstamina = 99999 // yadda yadda
		tempdefense = 9999
		tempevade = 99
		exp = 0 // yep
		expneeded = 999999 // yep yep
		expgive = 0 // hrmm. never istaminalimented pvp experience.  guess this just stuck around from before i made seperate mob classes for players and enemies
		bankedlucre = 999999 // Bank by Ripper man5
		lucre = 999999 // mmmmm money.  buy stuff.
		Strength = 9999 // strength variable
		Spirit = 9999 // intelligence
		//Resistances
		fireres = 99
		iceres = 99
		windres = 99
		watres = 99
		earthres = 99
		poisres = 99
		//Weaknesses
		firewk = 0
		icewk = 0
		windwk = 0
		watwk = 0
		earthwk = 0
		poiswk = 0
		//magi levels
		heatlevel = 99
		shardburstlevel = 99
		watershocklevel = 99
		vitaelevel = 99
		flamelevel = 99
		icestormlevel = 99
		cascadelightninglevel = 99
		telekinesislevel = 99
		abjurelevel = 99
		cosmoslevel = 99
		rephaselevel = 99
		acidlevel = 99
		bludgeonlevel = 99
		quietuslevel = 99
		panacealevel = 99
		permallow = 0
		pvpkills = 0
		//UEB = 0
		// oh yes...let the abilities roll forth!
		verb
			AVATAR_TEMP() // i used this verb for debugging alot, mostly making books and items from nothing
				set category = "Commands"
				var/obj/items/weapons/sumasamune/J = new(usr)
				usr << "You materialized a [J]."
			AVATAR_TELEPORT()
				set category = "Commands"
				var/_x=input("x location:","Go: x",x) as num
				var/_y=input("y location:","Go: y",y) as num
				var/_z=input("z location:","Go: z",z) as num
				loc=locate(_x,_y,_z)
			AVATAR_TELEPORTPLAYER()
				set category = "Commands"
				var/_x=input("x location:","Go: x",x) as num
				var/_y=input("y location:","Go: y",y) as num
				var/_z=input("z location:","Go: z",z) as num
				for(var/mob/players/m in world) // quit talking.  now.
					if (istype(m,/mob/players))

						m.loc=locate(_x,_y,_z)
			/*AVATAR_JUMPTOMAP(map as text)
				if(!map) map=input("Map name","Map name") as text
				var/swapmap/M=SwapMaps_Find(map)
				if(!M)
					usr << "Map [map] not found."
					return
				loc=locate(round((M.x1+M.x2)/2),round((M.y1+M.y2)/2),M.z1)
			AVATAR_SAVEMAP(map as text)
				//SaveMap(map as text)
				if(!map) map=input("Map name","Map name") as text
				if(!SwapMaps_Save(map))
					usr << "Map [map] not found."
				else
					usr << "Map [map] saved."
			AVATAR_SAVECHUNK()
				if(!loc)
					usr << "You must be on the map to save a chunk with this demo."
					return
				var/_x=round(input("x size:","New map: x size",world.maxx) as num,1)
				var/_y=round(input("y size:","New map: y size",world.maxy) as num,1)
				_x=max(1,min(_x,world.maxx-x+1))
				_y=max(1,min(_y,world.maxy-y+1))
				SwapMaps_SaveChunk("chunk",loc,locate(x+_x-1,y+_y-1,z))
			AVATAR_LOADCHUNK()
				if(!loc)
					usr << "You must be on the map to save a chunk with this demo."
					return
				var/list/L=SwapMaps_GetSize("chunk")
				if(!L)
					usr << "Chunk not found."
					return
				var/_x=max(1,min(x,world.maxx-L[1]+1))
				var/_y=max(1,min(y,world.maxy-L[2]+1))
				var/oldloc=loc
				usr << "Loading chunk at [_x],[_y],[z]"
				SwapMaps_LoadChunk("chunk",locate(_x,_y,z))
				loc=oldloc
			AVATAR_LOADMAP(map as text)
				if(!map) map=input("Map name","Map name") as text
				if(!SwapMaps_Load(map))
					usr << "Map [map] not found."
				else
					usr << "Map [map] loaded."
			AVATAR_MAPTOTXT(map as text)
				if(!map) map=input("Map name","Map name") as text
				if(!fexists("map_[map].sav"))
					usr << "Map [map] has no file."
					return
				var/savefile/S=new("map_[map].sav")
				fdel("map_[map].txt")
				S.ExportText("/",file("map_[map].txt"))
				usr << "Coverted to text: map_[map].txt"
			AVATAR_CREATETEMPLATE(map as text)
				//Template(map as text)
				if(!map) map=input("Template name","Template name") as text
				var/swapmap/M=SwapMaps_CreateFromTemplate(map)
				if(!M)
					usr << "Map template [map] not found."
				else
					usr << "Map [html_encode("\ref[M]")] created."
					usr << "Map is located at [M.x1],[M.y1],[M.z1] - [M.x2],[M.y2],[M.z2]"*/
			/*AVATAR_TAGAREA()
				if(!z) return
				for(var/i in 1 to 3)
					var/w=rand(1,world.maxx)
					var/h=rand(1,world.maxy)
					var/x2=rand(w,world.maxx)
					var/y2=rand(h,world.maxy)
					var/area/A=new
					A.tag="[i]"
					for(var/turf/T in block(locate(x2-w+1,y2-h+1,z),locate(x2,y2,z)))
						A.contents+=T*/
			//AVATAR_GIVEPOWERS(var/mob/players/m in world) // to give people some GM powers
			//	m.verbs+=new/mob/players/gmspells/verb/GM_REBOOT
			//	m.verbs+=new/mob/players/gmspells/verb/GM_KICK
			//	m.verbs+=new/mob/players/gmspells/verb/GM_RESTART
			//AVATAR_TAKEPOWERS(var/mob/players/m in world) // and to take them away
			//	m.verbs-=new/mob/players/gmspells/verb/GM_REBOOT
			//	m.verbs-=new/mob/players/gmspells/verb/GM_KICK
			//	m.verbs-=new/mob/players/gmspells/verb/GM_RESTART
			//	m.verbs-=new/mob/players/Special1/verb/AVATAR_TEMP
			//	m.verbs-=new/mob/players/Special1/verb/AVATAR_GIVEPOWERS
			//	m.verbs-=new/mob/players/Special1/verb/AVATAR_TAKEPOWERS
			//	m.verbs-=new/mob/players/Special1/verb/AVATAR_REBOOT
			//	m.verbs-=new/mob/players/Special1/verb/AVATAR_MUTE
			//	m.verbs-=new/mob/players/Special1/verb/AVATAR_UNMUTE
			//	m.verbs-=new/mob/players/Special1/verb/AVATAR_KICK
			//	m.verbs-=new/mob/players/Special1/verb/AVATAR_RESTART
			//	m.verbs-=new/mob/players/Special1/verb/AVATAR_GOLD
			//	m.verbs-=new/mob/players/Special1/verb/AVATAR_BAN
			//	m.verbs-=new/mob/players/Special1/verb/AVATAR_UNBAN
			//	m.verbs-=new/mob/players/Special1/verb/AVATAR_LEVELUP
			AVATAR_REBOOT() // sometimes it just needs to happen.
				set category = "Commands"
				world.Reboot()
			AVATAR_SHUTDOWN() // sometimes it just needs to happen.
				set category = "Commands"
				TimeSave()
				Save_All()
				shutdown()
				//..()//TestStamp
			AVATAR_TIMESAVE()
				set category = "Commands"
				usr << "Saving Time..."
				TimeSave()
				usr << "Time Saved."
			AVATAR_SEASONSET()
				set category = "Commands"
				usr << "Setting season..."
				call(/world/proc/SetSeason)()//this needs fixed?
				usr << "[global.season]"
			AVATAR_MUTE(var/mob/players/m in world) // quit talking.  now.
				set category = "Commands"
				if (istype(m,/mob/players))
					world << "<font color = yellow>[usr] has removed [m]'s speech."
					m.muted = 1 // you can no longer say things to us
					m.away = 0 // not even say stupid stuff in an away message
				else
					usr << "Cannot remove speech." // yell at myself for trying to mute an enemy
			AVATAR_UNMUTE(var/mob/players/m in world) // ok you can talk now
				set category = "Commands"
				if (istype(m,/mob/players))
					world << "<font color = yellow>[usr] has reunited [m] with speech."
					m.muted = 0 // speak.  you can be heard.
				else
					usr << "Cannot restore speech."
			AVATAR_KICK(var/mob/players/m in world) // this is a threat. you can come back, but quit being stupid
				set category = "Commands"
				if (istype(m,/mob/players))
					world << "<font color = yellow>[m] suddenly fell over in a pool of blood."
					m.muted = 1 // no speak for you!
					m.loc = null // HA! you just get to sit in the game until you relog, everythings black and no one hears you
					m.location = "The Void" // so we can all get a good laugh at your location
				else
					usr << "Cannot kick."
			AVATAR_RESETAFF(var/mob/players/m in world) // this is a threat. you can come back, but quit being stupid
				set category = "Commands"
				if (istype(m,/mob/players))
					world << "<font color = yellow> A bright light from above restores all affinity to neutral. "
					m.affinity = 0 // no speak for you!
					//m.loc = null // HA! you just get to sit in the game until you relog, everythings black and no one hears you
					//m.location = "The Void" // so we can all get a good laugh at your location
				else
					usr << "Cannot reset"
			AVATAR_RESTART(mob/players/M in world,why_quest as message|null) // very useful, move people back to the beginning
				set category = "Commands"//for(M as mob in world)
				if((input("Want to Restart [M]?") in list("Yes","No")) != "Yes")
					return
					if(M.key)
						if(why_quest)

							//if (istype(M,/mob/players))  //how to filter
							//var/fl = locate(pick(412,685),pick(422,692),1)  //story demo
							var/fl = locate(usr.loc)  //story demo
							M = fl//locate()

								//if(m)
							world << "<font color = yellow>[M] appears back at the beginning! [why_quest]"
								//	m.loc = locate(fl)
					//m.location = fl
					//m.nomotion = 0
					//m << sound('mus.ogg',1, 0, 1024)
				//else
					//usr << "Cannot move."
			//AVATAR_GOLD(var/mob/players/m in world, numb as num) // HAXOR!!
			//	if (istype(m,/mob/players))
			//		m.lucre = numb
			//		m << "<font color = yellow>your lucre vanishes, the only thing that remains, [numb]!"
			//		usr << "<font color = yellow>You set [m]'s lucre to [numb]!"
			//	else
			//		usr << "Cannot do that."
			AVATAR_BAN(mob/players/M in world,why_quest as message|null) // yep yep. get out.
				set category = "Commands"
				if(M == usr) // what are you thinking?!
					usr << "<b>You cannot Ban yourself!"
					return
				//lots of if crap to make sure that you want to ban them and send them a message saying why
				if((input("Want to Ban [M]?") in list("Yes","No")) != "Yes")
					return
				if(M.key)
					if(why_quest)
						M << "<b>[src.name] has banned you. Reason:\n[why_quest]."
					else
						M << "<b>[src.name] banned you."
					bans += M.ckey
					world << "<b>[src.name] has banned [M]. (Reason: [why_quest])"
					del(M)
				else
					usr << "Cannot do that."
			AVATAR_UNBAN(key as text) // does this really need explanation? i think not
				set category = "Commands"
				if(!bans.Find(ckey(key)))
					usr << "<b>No one banned with '[key]' this key."
				else
					usr << "<b>User: [key] has been unbanned."
					bans -= ckey(key) // take em off the banned list
			AVATAR_LEVELUP(mob/players/M in world) // more cheating for me.  leveling with a verb is helpful.  this originated for just debugging purposes and then served many uses
				set category = "Commands"
				if (istype(M,/mob/players))
					M.exp+=(M.expneeded-M.exp) // give em the exp they need to level
					checklevel(M) // and then run the function that checks to see if they've leveled yet
					//and tell the involved people what happened
					M << "<font color = yellow>You feel enlightened, as if something has shared its intellect with you."
					usr << "<font color = yellow>You gave [M] a free level!"
				else
					usr << "Cannot do that."
	/*gmspells // yepyep.  sometimes others need to have some of my cool abilities
		verb
			GM_REBOOT()
				world.Reboot()
			GM_KICK(var/mob/players/m in world)
				if (istype(m,/mob/players))
					world << "<font color = yellow>[m] suddenly fell over in a pool of blood."
					m.muted = 1
					m.loc = null
					m.location = "The GM swipes his Singular Umbral Masamune through the air to free it of blood."
				else
					usr << "Cannot kick."
			GM_RESTART(var/mob/players/m in world)
				if (istype(m,/mob/players))
					world << "<font color = yellow>[m] appears back at Town!"
					m.loc = locate(rand(246,261),rand(90,99),1)
					m.location = "Aldoryn"
					m.nomotion = 0
					m << sound('mus.ogg',1, 0, 1024)
				else
					usr << "Cannot move."*/

//																Unequip block for Menus(can't unequip/drop tool while using it)
//more to come
	proc
		_unlockChannel(channel)
			if(channel in _channels_taken)
				_channels_taken -= channel
				if(!length(_channels_taken)) _channels_taken = null

		_lockChannel(channel)
			if(!(channel in _channels_taken))
				if(!_channels_taken) _channels_taken = list()
				_channels_taken += channel

		_updateListeningSoundmobs()
			if(_listening_soundmobs)
				for(var/soundmob/soundmob in _listening_soundmobs)
					if(soundmob.attached)
						soundmob.updateListener(src)

		_getAvailableChannel()
			for(var/channel = _channel_reserve_start, channel <= _channel_reserve_end, channel ++)
				if(!(channel in _channels_taken)) return channel

			CRASH("You've managed to use a ridiculous number of channels. You're doing it wrong.")

		listenSoundmob(soundmob/soundmob)
			if(!(soundmob in _listening_soundmobs))
				if(!_listening_soundmobs) _listening_soundmobs = list()
				_listening_soundmobs += soundmob
				soundmob.setListener(src)

		unlistenSoundmob(soundmob/soundmob)
			if(soundmob in _listening_soundmobs)
				var/sound/sound = _listening_soundmobs[soundmob]//_listening_soundmobs[soundmob]
				_channels_taken -= sound.channel

				_listening_soundmobs -= soundmob
				if(!length(_listening_soundmobs)) _listening_soundmobs = null
				soundmob.unsetListener(src)


	proc/UESME()//																Unequip block for Building Menu (can't unequip/drop hammer while using it)
		var/mob/players/M
		M = usr

		if((M.UESME==1))
			M << "You cannot take off the gloves while you're using them..."
			M.GVequipped=1
			return
	proc/UEB()//																Unequip block for Building Menu (can't unequip/drop hammer while using it)
		var/mob/players/M
		M = usr

		if((M.UEB==1))
			M << "You cannot unequip the hammer while you're using it..."
			M.HMequipped=1
			return
	proc/UED()//																Unequip block for Digging Menu (can't unequip/drop shovel while using it)
		var/mob/players/M
		M = usr

		if((M.UED==1))
			M << "You cannot unequip the shovel while you're using it..."
			M.SHequipped=1
			return
	proc/UETW()//																Unequip block for Building Menu (can't unequip/drop hammer while using it)
		var/mob/players/M
		M = usr

		if((M.UETW==1))
			M << "You cannot unequip the Trowel while you're using it..."
			M.TWequipped=1
			return
	proc/Medals()
		if(!src.medal1)// A safety var I made which means if medal 1 = 0 , if it equals 1 you won't learn the medal again
			if(src.lucre <= 100)// If you have $100
				medal1 = 0
				world.SetMedal("Lucre Lover", src)/// Gives you the medal , also saves date and time you were awarded medal
				world << "\green<b>[usr]{[usr.ckey]} Gained the Lucre Lover Test Medal!"
				medal1 = 1//You wont recieve this medal again
		if(!src.medal2)// A safety var I made which means if medal 1 = 0 , if it equals 1 you won't learn the medal again
			if(src.exp <= 1000)// If you have $100
				world.SetMedal("Level Up", src)/// Gives you the medal , also saves date and time you were awarded medal
				world << "\green<b>[usr]{[usr.ckey]} Gained the Level Up Test Medal!"
				medal2 = 1//You wont recieve this medal again

	proc/poisoned(mob/players/P as mob) // you are poisoned dude, this function fires because of that to HURT YOU!
		set waitfor = 0
		if(poisoned==1) // gotta make sure that you are poisoned
			P.poisoned=0 // and make it so that this only fired once for you each time you get poisoned
			while(poisonD>0) // yep, we gonna hurt you now
				P.HP -= poisonDMG // take some damage
				s_damage(P, poisonDMG, "#800080") //show the damage on the screen.  s_damage rules.  thank spuzzum.
				poisonD-- // counting down to 0
				if(P.HP <= 0) // you are dead now dude
					P.poisonD=0 // lets not overkill you
					P.poisoned=0 // you aren't poisoned after death anymore
					P.poisonDMG=0 // just for kicks and checks
					//P.overlays = null // no more poison icon thing over you now
					//WorkStamp
					world << "\green<b>[P] succumbed to poison." // let everyone know how much you suck
					//var/G = round((P.lucre/4),1) // you lose lucre for dying.  shame on you.
					//P << "\yellow<b>Your pouch slipped and spilled [G] Lucre." // we'll tell you how much you lost too so you will learn and not do it again
					//P.lucre-=G // YOINK!
					//P.loc = locate(rand(119,125),rand(92,99),2) // back to the beginning
					//P.location = "Aldoryn" // yep. you are in the first town now, sucka.
					//usr << sound('mus.ogg',1,0,0) // town music
					P.HP = 1 // i guess we'll give you your life back too, man i am so gracious
					call(/mob/players/proc/checkdeadplayer2)(P)
				sleep(10) // gotta wait a sec before we damage you again in this loop
			P.poisonD=0 // i guess your poison time has expired
			P.poisoned=0 // we'll stop the pain now
			P.poisonDMG=0 // no more damage
			//P.overlays = null // good job. we'll take away those green bubbles too
	/*proc/Update(mob/M as mob) // calculations for the meters' visuals
		for(var/obj/meter1/N in M.client.screen)
			N.num = (src.HP/src.MAXHP)*N.width
			N.Update()
		for(var/obj/mmeter1/MM in M.client.screen)
			MM.num = (src.stamina/src.MAXstamina)*MM.width
			MM.Update()
		for(var/obj/xmeter1/MM in M.client.screen)
			MM.num = (src.exp-src.oldexp)/(src.expneeded-src.oldexp)*MM.width
			MM.Update()*/
	proc/JoinParty(var/mob/players/U,var/mob/players/M) // forming a party, eh?
		var/R = (input(M,"Party Formation","Join [U]([U.ckey])'s party?") in list("Yes","No"))
		switch(R) // depends on the input from the invited person
			if("Yes") // yay. lets go kill stuff together
				if(U.inparty==1) // go on into the party now dude, someone already in a party is inviting you
					M << "\red<b>You joined [U]([U.ckey])'s party"
					U << "\red<b>[M]([M.ckey]) joined your party"
					M.inparty=1 // yep. you in a party now.
					M.partynumber = U.partynumber // in fact. you are in HIS (U) party!
				else // you are trying to form a party of your own with another dude, first time, excellent!
					M << "\red<b>You joined [U]([U.ckey])'s party"
					U << "\red<b>[M]([M.ckey]) joined your party"
					U.inparty=1 // now you both are kicking it together
					M.inparty=1 // aren't we having fun?
					var/X = partycounter // gotta know what party# we're on
					U.partynumber = X // yep. you in it.
					M.partynumber = X // so are you.
					partycounter++ // and now the next party gets the next number. wonderful.
			if("No") // DENIED!
				M << "\red<b>You declined [U]([U.ckey])'s invitation to join a party."
				U << "\red<b>[M]([M.ckey]) declined to join the party."
	proc/leaveparty(var/mob/players/M)
		if(M.inparty==1)
			var/mob/players/J
			for(J as mob in world) // lets go through everyone in the world
				if (istype(J,/mob/players)) // and if its a player
					if(J.partynumber==M.partynumber) // and they're in your party
						J << "\red<b>[M]([M.ckey]) left the party." // let them know that you left the party
			M.inparty=0 // no more party
			M.partynumber=0 // yep. no party for you.
		else // you can't leave a party if you aren't in one
			M << "\red<b>You are currently not in a party."


	var/ratelimit=0 // quit spamming!!!!!!! this is used to keep you from typing too much too fast i think
	verb
		//heh. this variable used to be for everyone, now its just for me, the gamemaster
		/*Testamina()
			var/obj/items/weapons/magicdagger/J = new(usr)
			usr << "You got a [J]"*/
		Save()
			set hidden = 1
			set name = "Save"
			set desc = "Save your character."
			usr << "Saving Character..."
			src.client.base_SaveMob()
			usr << "Save Complete"

		Party() // party time!
			//this J list, C var, and M reference looping is so that all the enemies in the world are not in your list to pick from
			set category=null//i hate games that don't do this.  ...like i want to party with a spider, sheesh.  i don't want to see that crap on my list.
			set popup_menu=1//hidden = 1
			var/list/J[1]
			var/C = 1
			var/mob/players/M
			for(M as mob in world)
				if(istype(M,/mob/players))
					J[C] = M
					C++
					J.len++
			M = (input("Party Formation","Invite...") as mob in J) // which one you want to invite?
			if(M!=usr) // making sure it isn't yourself...
				if(M.inparty==0) // making sure they aren't already in a party
					JoinParty(usr,M) // lets run our happy function with the inviter (usr) and invitee (M selected from list J)
				else
					usr << "[M]([M.ckey]) is already partying."
			else
				usr << "You cannot invite yourself."
		LeaveParty() //verb to call the function to get you on out of there.
			set category=null
			set popup_menu=1//hidden = 1
			leaveparty(usr)
		Say(msg as text)
			set category=null
			set popup_menu=1//hidden = 1 // i guess we'll let you speak to people nearby
			var/mob/players/M
			for(M as mob in view(10))
				winset(usr,"default.talk","is-visible=true")
			if(muted==0) // if you aren't muted, of course
				if(length(msg)<=0)
					usr << "<b>Enter a message to say."
					return
				if(length(msg)<=255) // we don't want to read your long spam messages, sheesh.
					if(ratelimit<=5) // gotta make sure that you don't flame us with a ton of messages too quickly too
						for(M as mob in view(20)) // tell everyone nearby your message without your html formatting crap too
							M << "<font color = white><b>[usr]([usr.ckey]) <font color = #e3e3e3>says: [html_encode(msg)]"
						ratelimit++ // counting how much you've been yacking in a period of time
						return
					else // SPAMMER!!!!!
						usr << "<b>You are over the chat entry limit. Stop flooding the chat."
						ratelimit=10
						return
				else
					usr << "<b>Do Not Spam, the limit is 255 characters." // gotta let them know not to spam
					return
			else
				usr << "<font color = yellow> No one hears you, you have been muted. Use manners and modesty to be unmuted." //  =]
				return
		WSay(msg as text)
			set hidden = 1 // yeah, we'll let you talk to the entire world this time. same spamming protection as Say

			if(muted==0)
				if(length(msg)<=0)
					usr << "<b>Enter a message to world say."
					return
				if(length(msg)<=255)
					if(ratelimit<=5)
						world << "<font color=#ff996e><b>[usr]--<font color=#fff4ef>wsays: [html_encode(msg)]"
						ratelimit++
					else
						usr << "<b>You are over the chat entry limit.  Cease and Desist!"
						ratelimit=10
						return
				else
					usr << "<b>Do Not Spam, the limit is 255 characters."
			else
				usr << "<font color = yellow> You are currently mute."
		Whisper()
			set category=null
			//set hidden = 1
			set popup_menu=1//hidden = 1 // oh goodness. we even let you whisper a single person.  same spamming protection junk as Say
			var/list/J[1]
			var/C = 1
			var/mob/players/M
			for(M as mob in world)
				if(istype(M,/mob/players))
					J[C] = M
					C++
					J.len++
			M = (input("Whisper","Who") as mob in J)
			var/msg = input("Whisper","Message") as text
			if (istype(M,/mob/players))
				if(muted==0)
					if(length(msg)<=0)
						usr << "<b>Enter a message to whisper."
						return
					if(length(msg)<=255)
						if(ratelimit<=5)
							M << "<font color = white><b>[usr]([usr.ckey]) <font color = green>whispers: [html_encode(msg)]"
							usr << "<font color = white><b>You whisper [M]([M.ckey])<font color = green>: [html_encode(msg)]"
							ratelimit++
							return
						else
							usr << "<b>You are over the rate limit.  Please wait..."
							ratelimit=10
							return
					else
						usr << "<b>Don't spam, the limit is 255 characters."
						return
				else
					usr << "<font color = yellow> You are currently mute."
					return
			else
				usr << "You whisper to [M] but it does not respond."
				return
		GiveGold() // awe...isn't that nice of you?
			//this J list, C var, and M reference looping is so that all the enemies in the world are not in your list to pick from
			//i hate games that don't do this.  ...like i want to give lucre to a cheesecake, sheesh.  i don't want to see that crap on my list.
			set category=null
			set popup_menu=1//hidden = 1
			var/list/J[1]
			var/C = 1
			var/mob/players/M
			for(M as mob in view(5)) // only people you can SEE
				if(istype(M,/mob/players)) // PEOPLE you can see
					J[C] = M
					C++
					J.len++
			M = (input("Give Lucre","Who") as mob in J) // who??
			var/numb = input("Give Lucre","Amount") as num // how much?!
			if (istype(M,/mob/players)&&numb>0) // gotta check and be sure it is a player, and that you aren't trying to steal their lucre with a negative value
				if(M==usr) // you can't give lucre to yourself
					return // we'll just leave this function without even the grace of telling yourself that (seeing as we don't have a cancel button i think this is a good thing
				if (lucre >= numb) // gotta make sure you have the lucre you want to give
					M.lucre+=numb // let em have it
					lucre-=numb // and take it from you
					//tell everyone what just happened
					M << "\green<b>[usr]([usr.ckey]) gives you a pouch of [numb] Lucre."
					usr << "\green<b>You gave [M]([M.ckey]) a pouch of [numb] Lucre."
					return
				else
					usr << "Your pouch doesn't contain enough lucre to give that amount." // a bit excessive there
					return
		GiveItem() // im sure the recipient will be pleased   needs work
			set category=null
			set popup_menu=1//hidden = 1
			var/list/U[1] // making a lovely list to choose from again
			var/I = 1 // counter
			var/mob/players/M
			for(M as mob in view(5)) // people in your viewrange
				if(istype(M,/mob/players)) // only people allowed
					U[I] = M
					I++
					U.len++
			M = (input("Give Item","Who") in U) // pick one dude
			var/list/J[1]
			var/C = 1
			var/obj/K
			for(K as obj in J) // you can only pick items in your inventory to give
				if (istype(K,/obj/items)) // make sure that it is something i'll let you give away
					J[C] = K
					C++
					J.len++
			K = (input("Give Item","Item") in J) // pick one of em
			if (istype(M,/mob/players)&&( istype(K,/obj/items) )) // gotta keep making extra checks incase some stupid exception comes up
				if(M==usr) // trying to give to yourself?
					return // do nothing

				if(K.suffix == "Equipped") // you can't give people stuff you have equipped
					//usr << "<font color = teal>Remove [K] first!"
					//return
					if(istype(K,/obj/items/tools)&&K.suffix=="Equipped")
						call(/obj/items/tools/verb/Unequip)(K)
					if(istype(K,/obj/items/weapons)&&K.suffix=="Equipped")
						call(/obj/items/weapons/verb/Unequip)(K)
					if(istype(K,/obj/items/shields)&&K.suffix=="Equipped")
						call(/obj/items/shields/verb/Unequip)(K)
					if(istype(K,/obj/items/armors)&&K.suffix=="Equipped")
						call(/obj/items/armors/verb/Unequip)(K)
					K.Move(M) // theirs now
					//tell everyone what happened
					M << "\green<b>[usr]([usr.ckey]) hands you a [K]"
					usr << "\green<b>You handed [M]([M.ckey]) a [K]"
					return
				else // here you go.... have it
					K.Move(M) // theirs now
					//tell everyone what happened
					M << "\green<b>[usr]([usr.ckey]) hands you a [K]"
					usr << "\green<b>You handed [M]([M.ckey]) a [K]"
					return
			else
				usr << "You cannot do that" // an exception was caught and something bad happened.
				return
		Away() // let everyone know that you are away, because we all really care.... riiiiiiiiiight...
			set category=null
			set popup_menu=1
			//set hidden = 1
			if(muted==0) // we don't let mutes set away messages
				if(away==0) // set the message
					var/J = input("[usr] is AFK","Your AFK Message") as text
					if(J=="")
						awaymessage = "Away From Keyboard..."
					awaymessage = J
					away = 1
					usr << "You are now Idle. ([awaymessage])"
					usr.overlays += image('dmi/64/magi.dmi',icon_state="afk")
						//usr.light = new/light/circle(usr,1)
						//usr.light.color = rgb(rand(100,155),rand(100,155),rand(100,155))
				else if(away==1)// no longer away if you click this button and you were away
					away = 0
					usr << "You are no longer Idle."
					//if(away==0)
					//del usr.light
					usr.overlays -= image('dmi/64/magi.dmi',icon_state="afk")
					return
			else // YOU CANT TELL US ANYTHING, MUTE!
				away = 0
				usr << "<font color = red>You seem unable to aquire words.  Cannot use AFK message."
				return
	/*proc/PlayMusic(music)
		var/mob/players/Player = usr
		if(istype(Player, /mob/players))
			Player.music = music
			if(Player.music_off == 0) //off for testing
				Player << sound(Player.music, 1, 0, 755)*/

	proc/GainLevel(var/mob/players/M) // isn't it a great feeling when this fires?
		M << "\green<b>You've become Stronger." // There's the message that inspires the good feeling
		//M.oldexp = M.expneeded // used for the green exp meter
		M.expneeded+=(13*(M.level*M.level)) // my algorithm for costaminauting experience required per level, no longer a secret
		M.updateXP()
		M.level+=1 // yep.  increment that sucker.
		M.client.base_SaveMob()
		//M.updateXP()
		if (M.char_class=="Smithy") // so you are a warrior eh?
			var/Health = (rand(M.level)+(M.level)*9) // well thats how much we increment your HP
			M.MAXHP+=Health
			M.HP+=Health
			M.updateHP()
			M << "\green<b>You gain [Health] Health!"
			var/stamina = (rand(M.level)+(M.level)*4) // and your stamina
			M.MAXstamina+=stamina
			M.stamina+=stamina
			M.updateST()
			M << "\green<b>You gain [stamina] stamina!"
			var/diceST = "1d4+2"
			var/St = roll(diceST)
			M.Strength+=St
			M << "\green<b>You gain [St] Strength!"
			var/diceIT = "1d4"
			var/It = roll(diceIT)
			M.Spirit+=It
			M << "\green<b>You gain [It] Spirit!"
			//M.frank+=1 [M.frank]
			M.updateXP()
			M.client.base_SaveMob()

		//this should be an if-else chain or a switch or something, pretty inefficient checks, but whatever...
	/*	if (M.char_class=="Builder") // so you are a warrior eh?
			var/Health = (rand(M.level)+(M.level)*9) // well thats how much we increment your HP
			M.MAXHP+=Health
			M.HP+=Health
			M.updateHP()
			M << "\green<b>You gain [Health] Health!"
			var/stamina = (rand(M.level)+(M.level)*4) // and your stamina
			M.MAXstamina+=stamina
			M.stamina+=stamina
			M.updateST()
			M << "\green<b>You gain [stamina] stamina!"
			var/diceST = "1d4+2"
			var/St = roll(diceST)
			M.Strength+=St
			M << "\green<b>You gain [St] Strength!"
			var/diceIT = "1d4"
			var/It = roll(diceIT)
			M.Spirit+=It
			M << "\green<b>You gain [It] Spirit!"
			//M.frank+=1 [M.frank]
			M.updateXP()*/
			// yep you age if you are within those levels
			/*if (M.level>9&&M.level<25&&M.icon_state!="Landscaper2")
				M.icon_state = "Landscaper2"
				M << "\green<b>You have aged but you are only spry, with much more aging to do."
			if (M.level>24&&M.level<40&&M.icon_state!="Landscaper3")
				M.icon_state = "Landscaper3"
				M << "\green<b>At such a young age you have much to experience and in your own way."
			if (M.level>39&&M.level<55&&M.icon_state!="Landscaper4")
				M.icon_state = "Landscaper4"
				M << "\green<b>So this is the adventure, or has it just begun?"
			if (M.level>54&&M.level<90&&M.icon_state!="Landscaper5")
				M.icon_state = "Landscaper5"
				M << "\green<b>Your voyage continues and your skin shows your age, but you have retained the strength required to continue experiencing."
			if (M.level>89) // traveler magi
				//M.verbs+=new/mob/players/sspells/verb/Transform
				//M.transformlevel+=1 [M.transformlevel]
				M << "\green<b>So, Journier, you have made it unto your lucreen years, you can do as you please and relax in pubs drunkenly discussing stories gone by - or seek those vast treasures that still lay out of your reach - whatever you so desire."*/
		if (M.char_class=="Feline")
			var/Health = (rand(M.level)+(M.level)*6) // some HP for you
			M.MAXHP+=Health
			M.HP+=Health
			M.updateHP()
			M << "\green<b>You gain [Health] Health!"
			var/stamina = (rand(M.level)+(M.level)*5) // lots of stamina for you
			M.MAXstamina+=stamina
			M.stamina+=stamina
			M.updateST()
			M << "\green<b>You gain [stamina] stamina!"
			var/diceST = "1d4+2"
			var/St = roll(diceST)
			M.Strength+=St
			M << "\green<b>You gain [St] Strength!"
			var/diceIT = "1d4"
			var/It = roll(diceIT)
			M.Spirit+=It
			M << "\green<b>You gain [It] Spirit!"
		//	M.hrank+=1 [M.hrank]
			M.updateXP()
			M.client.base_SaveMob()

		if (M.char_class=="Landscaper")
			var/Health = (rand(M.level)+(M.level)*6) // some HP for you
			M.MAXHP+=Health
			M.HP+=Health
			M.updateHP()
			M << "\green<b>You gain [Health] Health!"
			var/stamina = (rand(M.level)+(M.level)*5) // lots of stamina for you
			M.MAXstamina+=stamina
			M.stamina+=stamina
			M.updateST()
			M << "\green<b>You gain [stamina] stamina!"
			var/diceST = "1d4+2"
			var/St = roll(diceST)
			M.Strength+=St
			M << "\green<b>You gain [St] Strength!"
			var/diceIT = "1d4"
			var/It = roll(diceIT)
			M.Spirit+=It
			M << "\green<b>You gain [It] Spirit!"
		//	M.hrank+=1 [M.hrank]
			M.updateXP()
			M.client.base_SaveMob()
			// yep more aging for the ninjas too
		/*	if (M.level>9&&M.level<25&&M.icon_state!="Blackguard2")
				M.icon_state = "Blackguard2"
				M << "\green<b>You are still very young, Hopefully you have a mentor."
			if (M.level>24&&M.level<40&&M.icon_state!="Blackguard3")
				M.icon_state = "Blackguard3"
				M << "\green<b>Best you can do is keep your eyes on your blind spots and hope you live longer."
			if (M.level>39&&M.level<55&&M.icon_state!="Blackguard4")
				M.icon_state = "Blackguard4"
				M << "\green<b>Only young in this job, you have much to learn."
			if (M.level>54&&M.level<90&&M.icon_state!="Blackguard5")
				M.icon_state = "Blackguard5"
				M << "\green<b>You are at your peak, use it wisely."
			if (M.level>89) // ninja magi
				//M.verbs+=new/mob/players/sspells/verb/Transform
				//M.transformlevel+=1
				M << "\green<b>You may be old but your skills are ever as sharp, just don't get tired."*/


		if (M.char_class=="Magus")
			var/Health = (rand(M.level)+(M.level)*8) // a bit more than the wizard
			M.MAXHP+=Health
			M.HP+=Health
			M.updateHP()
			M << "\green<b>You gain [Health] Health!"
			var/stamina = (rand(M.level)+(M.level)*2) // and a bit less than the wizard
			M.MAXstamina+=stamina
			M.stamina+=stamina
			M.updateST()
			M << "\green<b>You gain [stamina] stamina!"
			var/diceST = "1d4+2"
			var/St = roll(diceST)
			M.Strength+=St
			M << "\green<b>You gain [St] Strength!"
			var/diceIT = "1d4"
			var/It = roll(diceIT)
			M.Spirit+=It
			M << "\green<b>You gain [It] Spirit!"
			//M.frank+=1 [M.frank]
			M.updateXP()
			M.client.base_SaveMob()
			//if (M.char_class=="Builder")
		//	var/obj/warhammers/WarHammer/J = new(M)
		//	M << "You got a [J]"
			// new icons for the mage chick at certain levels
		/*	if (M.level>9&&M.level<25&&M.icon_state!="Sear2")
				M.icon_state = "Sear2"
				M << "\green<b>You are very young, Hopefully you know a wise ol' Builder to aquire knowledge from."
			if (M.level>24&&M.level<40&&M.icon_state!="Sear3")
				M.icon_state = "Sear3"
				M << "\green<b>You are still spry, with much to explore."
			if (M.level>39&&M.level<55&&M.icon_state!="Sear4")
				M.icon_state = "Sear4"
				M << "\green<b>You understand that there are things you have yet to learn, Seeking what you do not know is the true pursuit of wisdom."
			if (M.level>54&&M.level<90&&M.icon_state!="Sear5")
				M.icon_state = "Sear5"
				M << "\green<b>Despite your age you can brew lightning with the best of them."
			if (M.level>89)
				/*M.verbs+=new/mob/players/sspells/verb/magi
				M.spelllevel+=1 [M.spelllevel]*/
				M << "\green<b>You grasp your cane much more firmly now, Ol' Builder...Tread Lightly."*/

		if (M.char_class=="Builder")
			var/Health = (rand(M.level)+(M.level)*6) // a bit less than the warrior
			M.MAXHP+=Health
			M.HP+=Health
			M.updateHP()
			M << "\green<b>You gain [Health] Health!"
			var/stamina = (rand(M.level)+(M.level)*7) // and a bit more than that uneducated fool
			M.MAXstamina+=stamina
			M.stamina+=stamina
			M.updateST()
			M << "\green<b>You gain [stamina] stamina!"
			var/diceST = "1d4+2"
			var/St = roll(diceST)
			M.Strength+=St
			M << "\green<b>You gain [St] Strength!"
			var/diceIT = "1d4"
			var/It = roll(diceIT) // im decently intelligent too, carazy.
			M.Spirit+=It
			// just like everyone else, i get new icons
			M << "\green<b>You gain [It] Spirit!"
			//M.verbs+=new/mob/players/verb/Build
			//M.build.Add("Stone Wall","Wood Floor")
			//M.brank+=1 [M.brank]
			M.updateXP()
			M.client.base_SaveMob()
		/*	if (M.level>9&&M.level<25&&M.icon_state!="Builder2")
				M.icon_state = "Builder2"
				M << "\green<b>You are young and feeble, seek a Master for training."
			if (M.level>24&&M.level<40&&M.icon_state!="Builder3")
				M.icon_state = "Builder3"
				M << "\green<b>You feel more capable, more like an Adult. Train further."
			if (M.level>39&&M.level<55&&M.icon_state!="Builder4")
				M.icon_state = "Builder4"
				M << "\green<b>All of this training has accumulated into a Highly Skilled Warrior. Those that do not know your name, will."
			if (M.level>54&&M.level<90&&M.icon_state!="Builder5")
				M.icon_state = "Builder5"
				M << "\green<b>You are amoung the stronger of the Builders, travel the land from temple to temple seeking ones own peace."
			if (M.level>89)
				M << "\green<b>This traversing has kept you in a persistent physical shape, you grow old but you are still very Capable."
*/

		if (M.char_class=="GM")
			var/diceGMHP = "3d20"
			var/Health = roll(diceGMHP) // i might as well give myself some more life
			M.MAXHP+=Health
			M.HP+=Health
			M.updateHP()
			M << "\green<b>You gain [Health] Health!"
			var/diceGMEN = "2d20"
			var/stamina = roll(diceGMEN) // and lots of mana.  mind over matter.
			M.MAXstamina+=stamina
			M.stamina+=stamina
			M.updateST()
			M << "\green<b>You gain [stamina] stamina!"
			var/diceGMST = "1d20+2"
			var/St = roll(diceGMST)
			M.Strength+=St
			M << "\green<b>You gain [St] Strength!"
			var/diceGMIT = "1d20"
			var/It = roll(diceGMIT)
			M.Spirit+=It
			M << "\green<b>You gain [It] Spirit!"
			M.updateXP()
			/*if (M.level>54&&M.level<90&&M.icon_state!="Original")
				M.icon_state = "Original"
				M << "\green<b>You've become old, you discard un-needed heavy equipment due to fatigue."*/
			M.client.base_SaveMob()


	proc/checklevel() // can i level?
		if (src.expneeded<=src.exp)
			GainLevel(src)
		//M.exp=0
			src.updateXP() // sure you can.  if your experience is greater than or equal to how much you need
			return
		else
			return
		//spelllvlcheck(M)
	var/waiter = 1 // used for delaying attacks, boolean
	verb/attack()
		set hidden = 1// the verb to attack enemies, called with the 5 key on the nustaminaad
		set waitfor = 0
		for(var/mob/players/M in get_step(src,src.dir)) // the enemy you are looking at.
			if(istype(M,/mob/players)&&(waiter>0)) // if it is an enemy and you are allowed to fight now
				Attack(M) // hit em
			else // otherwise
				sleep(attackspeed) // delay based on your attack speed
	Click(mob/players/P)      //When the mob Clicks into another mob
		var/mob/players/J = usr
		if(P.location!=locate(x,y,2)&&J.location!=locate(x,y,2))
			P << "The deceased cannot fight..."
			J << "The deceased cannot fight..."
			return
		if (istype(P,/mob/players)&&(waiter>0))    //If the player is an enemy...pvp!
			J.Attack(P)
		else
			sleep(J.attackspeed)
		if(stamina>MAXstamina)
			stamina=MAXstamina
		if(stamina<0)
			stamina=0
			..()
	Click()
		if (!(src in range(1, usr)))
			var/mob/players/Player = usr // define the player
			var/mob/players/W = src // define the enemy
			if(src in Player.inparty)
				usr<<"Can only fight others outside of your party."
				return
			if(src.loc != locate(x,y,2))
				usr<<"The deceased cannot fight..."
				return
			//if(Player.char_class!="Magus"&&Player.char_class!="Smithy"&&Player.char_class!="GM")
				//Player<<"Magus can attack anyone, Defenders hunt Magus."
				//return
		//	else
				/*if(Player.char_class=="Magus" && W in range(1)) // make sure that the person clicking is right by the emem
					if(istype(W,/mob/players)&&Player.waiter > 0) //When the mob Clicks the enemies
						Player.Attack(W)
					else
						sleep(Player.attackspeed)
				else*/
			if(W in range(1)) // make sure that the person clicking is right by the emem
				if(istype(W,/mob/players)&&Player.waiter > 0) //When the mob Clicks the enemies
					Player.Attack(W)
				else
					sleep(Player.attackspeed)
			/*else
				if(Player.char_class=="GM" && W in range(1)) // make sure that the person clicking is right by the emem
					if(istype(W,/mob/players)&&Player.waiter > 0) //When the mob Clicks the enemies
						Player.Attack(W)
					else
						sleep(Player.attackspeed)*/
		else return
	proc
		Destroy(obj/Buildable/Walls/W) // hit that enemy
			set waitfor = 0
			waiter=0 // you can't attack again yet
			var/damage = round(((rand(usr.tempdamagemin,usr.tempdamagemax))*((Strength/100)+1)),1) // calculate the damage
			var/mob/players/M = usr
			//var/obj/items/tools/WarHammer/O =/obj/items/tools/WarHammer
			var/typi=""
			if(M.stamina>M.MAXstamina)
				M.stamina=M.MAXstamina
			if(M.stamina<0)
				M.stamina=0
			if(M.stamina==0)			//Calling this again... Some screwy stuff could happen.
				waiter=0
				M<<"Your stamina is too low."
				return 0
			//..()
			if(M.stamina<=7)
				waiter=1
				M << "You are too tired, drink some water!"
				return
			if(WHequipped!=1&&typi!="WH")
				waiter=1
				M<<"You must utilize a WarHammer to destroy walls."
				return
			else
				waiter=1
				M.overlays += image('dmi/64/WHoy.dmi',icon_state="[get_dir(M,src)]")
				s_damage(W, damage, "#32cd32") // show the damage on the enemy
				W.HP -= damage // deal the actual damage to their variable
				M.stamina -= 8
				M.updateST()
				M.dexp += 25
				DestroyedWall(W) // checking to see if the enemy is dead, and doing things about it
				M.overlays -= image('dmi/64/WHoy.dmi',icon_state="[get_dir(M,src)]")
				sleep(attackspeed) // wait a time period based on your attack speed
				waiter=1 // you can fight again
				return call(/obj/proc/DestroyingCheck)()
			//..()

	proc/Attack() // hit that enemy
		var/mob/players/M
		M = src
		var/mob/players/J
		J = usr
		var/obj/items/weapons/sumuramasa/S = locate() in M
		J.waiter=0 // you can't attack again yet

		var/damage = round(((rand(J.tempdamagemin,J.tempdamagemax))*((J.Strength/100)+1)),1) // calculate the damage
		if(J.stamina>J.MAXstamina)
			J.stamina=J.MAXstamina
		if(J.stamina<0)
			J.stamina=0
		if(J.stamina==0)			//Calling this again... Some screwy stuff could happen.
			J.waiter=0
			J<<"Your stamina is too low."
			return
		//..()
		if(J.stamina<=0)
			J.waiter=1
			return
		//..()
		if(J.waiter==0)
				//waiter=1
			if(J.WHequipped==1)//WorkStamp need to add all of the weapon overlays!
				J.overlays += image('dmi/64/WHoy.dmi',icon_state="[get_dir(J,M)]")
			if(J.LSequipped==1)
				J.overlays += image('dmi/64/LSoy.dmi',icon_state="[get_dir(J,M)]")
			if(J.char_class=="GM")
				J.overlays += image('dmi/64/GMoy.dmi',icon_state="[get_dir(J,M)]")
			s_damage(M, damage, "#32cd32") // show the damage on the enemy
			if(J.HP<=0)
				//J.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
				call(/mob/players/proc/checkdeadplayer2)(M)
				J.pvpkills += 1
				if(S)
					S:volume += 10
				return
			else
				M.HP -= damage // deal the actual damage to their variable
				M.updateHP()
				J.updateHP()
				J.stamina -= damage
				M.updateST()
				J.updateST()
				checkdeadplayer2(M) // checking to see if the enemy is dead, and doing things about it
				J.overlays -= overlays
				sleep(attackspeed) // wait a time period based on your attack speed
				J.waiter=1 // you can fight again'
				return
			//..()
	proc/checkdeadplayer2(var/mob/players/M)
		if(M.HP <= 0)//&&src.affinity<=-0.1) // if you have less than or equal to 0 HP, you are dead
			world << "<font color = #660000><b>[M] died to [src]"
			//var/G = round((M.lucre/4),1)
			//M << "<font color = lucre>Your pouch slipped and spilled [G] Lucre!"
			//M.lucre-=G
			//M.unlistenSoundmob()
			//_listening_soundmobs -= src
			M -= verbs//do some basic clearing out so they can't do anything (maybe check inventory too)
			M.poisonD=0
			M.poisoned=0
			M.poisonDMG=0
			M.overlays = null
			M.icon = 'dmi/64/blank.dmi'
			M.needrev=1
			M.loc = locate(5,6,1)//locate(rand(100,157),rand(113,46),12)
			M.location = "Sleep"
			M.nomotion = 1
			M.HP = 1
			//usr << sound('mus.ogg',1, 0, 1024)
			/*if(M.location=="Sleep")
				M.HP = M.MAXHP
				return*/
		/*else
			if(M.HP <= 0&&M.affinity>=0)
				world << "<font color = #f8f8ff><b>[M] died to [src] and went to the Holy Light"
				var/G = round((M.lucre/4),1)
				M << "<font color = lucre>Your pouch slipped and spilled [G] Lucre!"
				//M.unlistenSoundmob()
				//_listening_soundmobs -= src
				M.lucre-=G
				M.poisonD=0
				M.poisoned=0
				M.poisonDMG=0
				M.overlays = null
				M.needrev=1
				M.loc = locate(101,159,12)//locate(rand(100,157),rand(113,46),12)
				M.location = "Holy Light"
				//usr << sound('mus.ogg',1, 0, 1024)
				if(M.location=="Holy Light")
							//M.unlistenSoundmob(fb)
							//call(/soundmob/proc/unsetListener)(M)
						//usr << sound('mus.ogg',1, 0, 1024)
					M.HP = M.MAXHP
					return*/
	proc/DestroyedWall(obj/Buildable/Walls/W)
		if(W.HP <= 0) // if the enemy is dead
			var/mob/players/J = usr // get a reference to the player
			if(J.inparty==1) // if the player is in a party, we're going to split the exp up
				//this list stuff finds the people in the party who are nearby to share with
				var/list/V[2]
				var/C = 2
				V[1] = J
				var/plevelsum = level//														?? Needs to be set to dexp (destroyexp)?
				for(var/mob/players/U as mob in oview(20)) // they have to be within 20 squares
					if(istype(U,/mob/players)) // and be a player
						if(U.partynumber==J.partynumber) // and be in your party
							plevelsum+=U.level
							V[C] = U
							C++
							V.len++
							J.expgive*=1.1 // for each added player. increase the total exp given by 10%
				var/Q
				//now we go through all those players, distributing the experience and lucre accordingly
				for(Q=1, Q<V.len, Q++) // give everyone their fair share of the loot
					var/mob/players/L = V[Q]
					var/Lperc = (L.level/plevelsum)
					L.exp += round((J.expgive * Lperc),1)
					//this line was used by me when checking how much was being distributed in what way, now its gone because it works correctly
					//world << "[L] is getting [round((M.expgive * Lperc),1)]exp and [round((M.lucregive *Lperc),1)]lucre"
					checklevel(L) // see if they've leveled up yet
					updateXP()
				del(W) // get rid of that dead one
			else // you aren't in a party
				exp += J.expgive // give you the experience
				checklevel(usr) // see if you leveled
				updateXP()
				del(W) // you are a dead monster now, get lost.

	proc
		heal(mob/players/M)
			set waitfor = 0
			var/staminagive = rand(1,3)
			var/Increase = staminagive
			if(M.stamina==M.MAXstamina)
				return
			else
				M.stamina+=Increase
				updateHP(M)
				usr<<"You've regained [Increase] stamina."
				sleep(50)
	proc
		updateHP(var/N)
			if(!client)
				return
			if(src.HP > src.MAXHP)
				src.HP = src.MAXHP
			if(src.HP < 0)
				src.HP = 0
			HP += N
			HP = min(HP, MAXHP)
			winset(src,"bar1","value=[100 * HP / MAXHP]")
	proc
		updateST(var/N)
			if(!client)
				return
			if(src.stamina > src.MAXstamina)
				src.stamina = src.MAXstamina
			if(src.stamina < 0)
				src.stamina = 0
			stamina += N
			stamina = min(stamina, MAXstamina)
			winset(src,"bar2","value=[100 * stamina / MAXstamina]")
	proc
		updateXP(var/N)
			if(!client)
				return
			if(src.exp>=src.expneeded)
				src.exp = 0
			if(src.exp < 0)
				src.exp = 0
			exp += N
			exp = min(exp, expneeded)//while() instead of if() in case you gain enough exp in one go to gain multiple levels
			while(exp > expneeded)
				exp -= expneeded
        //LEVELUP!
			winset(src,"bar3","value=[100 * exp / expneeded]")
	proc
		updateBXP(var/N)
			if(!client)
				return
			if(src.buildexp>=src.mbuildexp)
				src.buildexp = 0
			if(src.buildexp < 0)
				src.buildexp = 0
			buildexp += N
			buildexp = min(buildexp, mbuildexp)//while() instead of if() in case you gain enough exp in one go to gain multiple levels
			while(buildexp > mbuildexp)
				buildexp -= mbuildexp
        //LEVELUP!
			winset(src,"bar9","value=[100 * buildexp / mbuildexp]")
	proc
		updateDXP(var/N)
			if(!client)
				return
			if(src.digexp>=src.mdigexp)
				src.mdigexp += src.digexp
				src.digexp = 0
				//call(/proc/diglevel)(src)
				//src.mdigexp += (13*(src.drank*src.drank))
			if(src.digexp < 0)
				src.digexp = 0
			digexp += N
			digexp = min(digexp, mdigexp)//while() instead of if() in case you gain enough exp in one go to gain multiple levels
			while(digexp > mdigexp)
				call(/proc/diglevel)(src)
				//digexp -= mdigexp
				//src.drank += 1
        //LEVELUP!
			winset(src,"bar8","value=[100 * digexp / mdigexp]")
	proc
		updateSOXP(var/N)
			if(!client)
				return
			if(src.grankEXP>=src.grankMAXEXP)
				src.grankEXP = 0
			if(src.grankEXP < 0)
				src.grankEXP = 0
			grankEXP += N
			grankEXP = min(grankEXP, grankMAXEXP)//while() instead of if() in case you gain enough exp in one go to gain multiple levels
			while(grankEXP > grankMAXEXP)
				grankEXP -= grankMAXEXP
        //LEVELUP!
			winset(src,"bar12","value=[100 * grankEXP / grankMAXEXP]")
	proc
		updateSMEXP(var/N)
			if(!client)
				return
			if(src.smeexp>=src.msmeexp)
				src.smeexp = 0
			if(src.smeexp < 0)
				src.smeexp = 0
			smeexp += N
			smeexp = min(smeexp, msmeexp)//while() instead of if() in case you gain enough exp in one go to gain multiple levels
			while(smeexp > msmeexp)
				smeexp -= msmeexp
        //LEVELUP!
			winset(src,"bar10","value=[100 * smeexp / msmeexp]")
	proc
		updateSMIXP(var/N)
			if(!client)
				return
			if(src.smiexp>=src.msmiexp)
				src.smiexp = 0
			if(src.smiexp < 0)
				src.smiexp = 0
			smiexp += N
			smiexp = min(smiexp, msmiexp)//while() instead of if() in case you gain enough exp in one go to gain multiple levels
			while(smiexp > msmiexp)
				smiexp -= msmiexp
        //LEVELUP!
			winset(src,"bar11","value=[100 * smiexp / msmiexp]")
		/*updatePXP(var/N)
			if(!client)
				return
			if(src.PLRankEXP>=src.PLRankMAXEXP)
				src.PLRankEXP = 0
			if(src.PLRankEXP < 0)
				src.PLRankEXP = 0
			PLRankEXP += N
			PLRankEXP = min(PLRankEXP, PLRankMAXEXP)//while() instead of if() in case you gain enough exp in one go to gain multiple levels
			while(PLRankEXP > PLRankMAXEXP)
				PLRankEXP -= PLRankMAXEXP
        //LEVELUP!
			winset(src,"bar11","value=[100 * exp / expneeded]")
		updateVXP(var/N)
			if(!client)
				return
			if(src.exp>=src.expneeded)
				src.exp = 0
			if(src.exp < 0)
				src.exp = 0
			exp += N
			exp = min(exp, expneeded)//while() instead of if() in case you gain enough exp in one go to gain multiple levels
			while(exp > expneeded)
				exp -= expneeded
        //LEVELUP!
			winset(src,"bar9","value=[100 * exp / expneeded]")
		updateHXP(var/N)
			if(!client)
				return
			if(src.exp>=src.expneeded)
				src.exp = 0
			if(src.exp < 0)
				src.exp = 0
			exp += N
			exp = min(exp, expneeded)//while() instead of if() in case you gain enough exp in one go to gain multiple levels
			while(exp > expneeded)
				exp -= expneeded
        //LEVELUP!
			winset(src,"bar10","value=[100 * exp / expneeded]")*/

	Stat() // these things get called ALOT in order to update stuff
		set waitfor = 0
		..()
		var/mob/players/M = usr
		//if your rate limit is between 5 and 10, you can't talk, if it is over 0, you decrement it in time
		//this controls the spamming.
		/*if(ratelimit>0)
			sleep(240) // we'll decrement this counter every 10
			M.ratelimit--
			if(ratelimit==5) // ill give you a warning before i slap you down
				M << "<b>If you flood the chat, you will be muted."
			else if(ratelimit>5) // if you cant speak, we're going to wait until you are below 5 before you can again, this tells the time before you can speak again
				M << "<b>Entry Rate limit > [(M.ratelimit)]"*/

		//if(M.poisoned==1) // if you recently got poisoned
			//spawn(0) poisoned(M) // call the poison function

		//M.tempstr = M.Strength
		//statpanel("���Overview���")
		//statpanel("spells")
		//stat(contents)
		statpanel("Inventory")
		stat(contents)
		/*if(contents.len)
			for(var/atom/A in contents)
				if(isobj(A))
					var/obj/O = A
					if(O.stt_container)
						if(O.stt_open)
							stat("--",O)
							stat(O.contents)
							stat("----------")
						else
							stat("+",O)
								// skip to the next item in src.contents
						continue
				stat(A)
		else
			stat("nothing")*/
		//M << output("| [hour]: [minute1][minute2] [ampm] |","Label1")
		//M << output("| [day] / [month] / [year] O�C� |","Label2")
		//M << output("| � [name] � |","Label3")
		//M << output("[HP]/[MAXHP]","Label4")
		//M << output("[stamina]/[MAXstamina]","Label5")
		//M << output(time2text(world.timeofday),"rltime")
		//M << output("|.��� [lucre] |","Label7")
		//M << output("| � [hour]: [minute1][minute2][ampm] � | [day]/[month]/[year] O�C�","ptime")//Tells you the time on a Statpanel.
		//M << output("|[day] / [month] / [year] O�C","ptime")//Tells you the date on a Statpanel.
		//rank
		//M << output("| [drank] |","Label8") // digging rank
		//M << output("| [brank] |","Label9") //building rank
		//M << output("| [smerank] |","Label10") //smelting rank
		//M << output("| [smirank] |","Label11") //smithing rank
		//M << output("| [Crank] |","Label12")
		//M << output("| [grank] |","Label13")
		//M << output("| [vitaelevel] |","Label14")
		//M << output("| [TC2()] |","sunmoon")
		statpanel("|Overview|")
		//stat("=~~~~~~~~~~~~~~~~~~=")
		if (time_of_day == DAY)
			stat("<font color = #f9d71c>...The Sun is overhead...</font>")//It tells you the time.
			goto cont//return
				//oview() << "<font color = green><b>[usr]</b> looks at the Sky."			//And tells everyone in your view that you're looking at the clock.
				//sleep(3)
				//return
		else if(time_of_day == NIGHT)
			stat("<font color = #e3e1D7>...The Moon is overhead...</font>")
			goto cont//return
		//stat("[TC()]")
		//stat("[TC2()]")
		cont
		stat("Pondera Time","[hour]: [minute1][minute2] [ampm]")//Tells you the time on a Statpanel.
		stat("Pondera Date","[day] / [month] / [season] / AM [year]")//Tells you the date on a Statpanel.
		//stat("RL Time","[world.time]")
		//stat("RL Date",time2text(world.timeofday)) dexp (destroy fexp (fishing seexp (Searching
		//stat("<font color = #ffd700>=~~~~~~~~~~~~~~~~~~~~~~~~~~~=</font>")
		//if(M.char_class=="Special1")
		stat("Grid Location","[x]/[y]/[z]")
		stat("<font color = #32cd32>Life</font>","[HP] / [MAXHP]")
		stat("<font color = #6495ed>Stamina</font>","[stamina] / [MAXstamina]")
		stat("<font color = #ffdead>Name</font>",name)
		stat("<font color = #d2691e>Enlistment</font>",char_class)
		stat("<font color = #ffd700>Lucre</font>",lucre)
		//stat("<font color = #4b7bdc>Acuity</font>",level)
		//stat("<font color = #87cefa>Total XP</font>","[exp] / [expneeded] | TNL: [(expneeded-exp)]")
		//stat("<font color = #ff7f50>Strength</font>",Strength)
		//stat("<font color = #f5fffa>Spirit</font>",Spirit)
		//stat("<font color = #cd5c5c>Offense</font>","[round((usr.tempdamagemin*((Strength/100)+1)),1)]-[round((usr.tempdamagemax*((Strength/100)+1)),1)]")
		//stat("<font color = #1e90ff>Defense</font>",tempdefense)
		//stat("<font color = #d8bfd8>Evasion</font>","[tempevade]%")
		stat("<font color = #fdf5e6>Affinity</font>","dark-  [affinity]  +light")
		stat("|-------------------------","<font size = 1>Knowledge Acuity   ---------------------|")
		//stat("�<font color = #dda0dd>Rank Acuity</font>�")
		stat("|<font color = #cd853f>Digging</font>","Acuity: [drank] | XP: [digexp] / [mdigexp] | TNL: [(mdigexp-digexp)]")
		stat("|<font color = #4682b4>Building</font>","Acuity: [brank] | XP: [buildexp] / [mbuildexp] | TNL: [(mbuildexp-buildexp)]")
		stat("|<font color = #5f9ea0>Smelting</font>","Acuity: [smerank] | XP: [smeexp] / [msmeexp] | TNL: [(msmeexp-smeexp)]")
		stat("|<font color = #e6e8fa>Smithing</font>","Acuity: [smirank] | XP: [smiexp] / [msmiexp] | TNL: [(msmiexp-smiexp)]")
		stat("|<font color = #b2a68c>Carving</font>","Acuity: [Crank] | XP: [CrankEXP] / [CrankMAXEXP] | TNL: [(CrankMAXEXP-CrankEXP)]")
		stat("|<font color = #0ed145>Botany</font>","Acuity: [CSRank] | XP: [CSRankEXP] / [CSRankMAXEXP] | TNL: [(CSRankMAXEXP-CSRankEXP)]")
		stat("|<font color = #f08080>Gardening</font>","Acuity: [grank] | XP: [grankEXP] / [grankMAXEXP] | TNL: [(grankMAXEXP-grankEXP)]")
		stat("|<font color = #d3d3d3>Mining</font>","Acuity: [mrank] | XP: [mrankEXP] / [mrankMAXEXP] | TNL: [(mrankMAXEXP-mrankEXP)]")
		stat("|<font color = #f4a460>Harvesting</font>","Acuity: [hrank] | XP: [hrankEXP] / [hrankMAXEXP] | TNL: [(hrankMAXEXP-hrankEXP)]")
		stat("|<font color = #00bfff>Fishing</font>","Acuity: [fishinglevel] | XP: [fexp] / [fexpneeded] | TNL: [(fexpneeded-fexp)]")
		stat("|<font color = #adff2f>Searching</font>","Acuity: [searchinglevel] | XP: [seexp] / [seexpneeded] | TNL: [(seexpneeded-seexp)]")
		if(M.char_class=="Smithy")
			stat("|<font color = #660000>Destroy</font>","Acuity: [destroylevel] | XP: [dexp] / [dexpneeded] | TNL: [(dexpneeded-dexp)]")
		//stat("<font size = 1><font color = #ffd700>=~�<font color = #87ceed>Resistance / Weakness</font>�~=</font>")
		//stat("�<font color = #87ceed>Element Resistance / Weakness</font>�")
		/*stat("<font color = #ff4500>Fire</font>","<center>[fireres]% / <right>[firewk]%")
		stat("<font color = #a5f2f3>Ice</font>","<center>[iceres]% / <right>[icewk]%")
		stat("<font color = #fff0f5>Wind</font>","<center>[windres]% / <right>[windwk]%")
		stat("<font color = #00ffff>Water</font>","<center>[watres]% / <right>[watwk]%")
		stat("<font color = #a0522d>Earth</font>","<center>[earthres]% / <right>[earthwk]%")
		stat("<font color = #98fb98>Poison</font>","<center>[poisres]% / <right>[poiswk]%")*/
		//stat("<font color = #ffd700>=~~~~~~~~~~~~~~~~~~~~~~~~~~~=</font>")
		//src.addHP(src)
//BLABLABNL
		statpanel("Who")
		var/mob/players/m
		var/X //defining the counter
		X=0//setting the counter
		for(m as mob in world)//how to setup a type to filter
			if (istype(m,/mob/players))  //how to filter for a certain type
				X++//adding to a counter
		stat("<center>-----------------<br><font size=1pt>[X] Spirit(s):</font><br>-----------------")
		for(m as mob in world)
			if (istype(m,/mob/players))
				var/ifinparty
				if(ckeyEx("[usr.key]") == world.host)
					ifinparty = "<br><font size=1pt><b>Host/GameMaster</b></font>"
				else if(m.inparty==1)
					ifinparty = "<br><font size=1pt>Party:</font>[m.partynumber]"
					if(m.partynumber==M.partynumber)
						ifinparty = "<br><font size=1pt>Party:</font>[m.partynumber], [m.location]"
				else
					ifinparty = "<br><font size=1pt>Unpartied</font><br>-----------------"
				stat("[m.name]*|[m.ckey]|*<br><font size=1pt>Enlistment:</font> [m.char_class]<br>Location: [m.location]<br><font size=1pt>Acuity:</font> [m.level][ifinparty]")
				if(m.away==1)
					stat("[m.name] is away [m.awaymessage]")
// spells
		//statpanel("Ancient Tomes ")
			//mob/players/m
		M << output("<font size=1%>Ancient Tomes <font size=1%>Bonuses Included","SpellTitle")
		//if its level is greater than 0, show it and info about it, including the calculations with strength/intelligence
		if (heatlevel > 0)
			M << output("Heat Rev: [heatlevel] | stamina Req: [(heatlevel*2)+1] | Damage Dealt: [round(((2+(heatlevel*2))*((Spirit/100)+1)),1)]-[round(((4+(heatlevel*3))*((Spirit/100)+1)),1)]","SpellLabel1")
		if (shardburstlevel > 0)
			M << output("Shard Burst Rev: [shardburstlevel] | stamina Req: [(shardburstlevel*2)+3] | Damage Dealt: [round(((1+(shardburstlevel*3))*((Spirit/100)+1)),1)]-[round(((3+(shardburstlevel*3))*((Spirit/100)+1)),1)]","SpellLabel2")
		if (watershocklevel > 0)
			M << output("Water Shock Rev: [watershocklevel] | stamina Req: [(watershocklevel*2)+5] | Damage Dealt: [1]-[round(((10+(watershocklevel*10.72))*((Spirit/100)+1)),1)]","SpellLabel3")
		if (vitaelevel > 0)
			M << output("Vitae Rev: [vitaelevel] | stamina Req: [(vitaelevel*2)+1] | Health Amount: [round(((2+(vitaelevel*2))*((Spirit/100)+1)),1)]-[round(((4+(vitaelevel*3))*((Spirit/100)+1)),1)]","SpellLabel4")
		if (flamelevel > 0)
			M << output("Flame Rev: [flamelevel] | stamina Req: [(flamelevel*3)+17] | Damage Dealt: [round(((2+(flamelevel*2))*((Spirit/100)+1)),1)]-[round(((4+(flamelevel*3))*((Spirit/100)+1)),1)]","SpellLabel5")
		if (icestormlevel > 0)
			M << output("Ice Storm Rev: [icestormlevel] | stamina Req: [(icestormlevel*3)+20] | Damage Dealt: [round(((3+(icestormlevel*3))*((Spirit/100)+1)),1)]-[round(((4+(icestormlevel*3))*((Spirit/100)+1)),1)]","SpellLabel6")
		if (cascadelightninglevel > 0)
			M << output("Cascade Lightning Rev: [cascadelightninglevel] | stamina Req: [(cascadelightninglevel*3)+23] | Damage Dealt: [1]-[round(((10+(cascadelightninglevel*10.72))*((Spirit/100)+1)),1)]","SpellLabel7")
		var/telestamina = (telekinesislevel*4/2)
		if (telestamina<0) // telekinesis shouldn't show a negative stamina cost as well, because it doesnt give you stamina =]
			telestamina=0
		if (telekinesislevel > 0)
			M << output("Telekinesis Rev: [telekinesislevel] | stamina Req: [telestamina] | Picks up target item","SpellLabel8")
		var/wstamina = (abjurelevel*2-50)
		if (wstamina<0) // nor should warp show negative stamina cost
			wstamina=0
		if (abjurelevel > 0)
			M << output("Abjure Rev: [abjurelevel] | stamina Req: [wstamina] | Revives you from the afterlife.","SpellLabel9")
		if (cosmoslevel > 0)
			M << output("Cosmos Rev: [cosmoslevel] | Health: [15+(cosmoslevel*5)] | stamina Req: [round(((5+(cosmoslevel*3))*((Spirit/100)+1)),1)]-[round(((10+(cosmoslevel*5))*((Spirit/100)+1)),1)] | stamina+: [round(cosmoslevel*4.9,1)]%","SpellLabel10")
		if (rephaselevel > 0)
			M << output("Rephase Rev: [rephaselevel] | stamina Req: [15+(rephaselevel*5)] | stamina Req: [round(((5+(rephaselevel*3))*((Spirit/100)+1)),1)]-[round(((10+(rephaselevel*5))*((Spirit/100)+1)),1)] | Damage Dealt: [round(rephaselevel*9.2,1)]%","SpellLabel11")
		if (acidlevel > 0)
			M << output("Acid Rev: [acidlevel] | stamina Req: [round(14*sqrt(acidlevel),1)] | Damage Dealt: [round(10*(sqrt(acidlevel*((Spirit/100)+1))),1)]-[round(13*(sqrt(acidlevel*((Spirit/100)+1))),1)] | Lasts: [round(4+(acidlevel/2),1)] seconds","SpellLabel12")
		if (bludgeonlevel > 0)
			M << output("Bludgeon Rev: [bludgeonlevel] | stamina Req: [(bludgeonlevel*2)+9] | Damage Dealt: [round(((10+(bludgeonlevel*2))*((Strength/100)+1)),1)]-[round(((16+(bludgeonlevel*3))*((Strength/100)+1)),1)]","SpellLabel13")
		//demi calculations are pretty weird, it has lots of restrictions and stuff
		var/demil = round(((sqrt(quietuslevel*Strength))/2),1)
		var/demih = round(((sqrt(quietuslevel*Strength))/1.4),1)
		if(demil>20) demil = 20
		if(demih>70) demih = 70
		var/dmgred = round(25+(0.5*quietuslevel),1)
		if (dmgred>90) dmgred = 90
		if (quietuslevel > 0)
			M << output("Quietus Rev: [quietuslevel] | stamina Req: [round(24*(sqrt(quietuslevel)),1)] | Damage Dealt: [demil]-[demih]% | Max Reduction: [dmgred]%","SpellLabel14")
		var/dmghealed = round(((panacealevel)*((Spirit/100)+1)),1)
		if (dmghealed>70) dmghealed=70
		if (panacealevel > 0)
			M << output("Panacea Rev: [panacealevel] | stamina Req: [95+(panacealevel*5)] | Health Amount: [dmghealed]% | Relieves of Toxins","SpellLabel15")

/*	Stat() // i think we all know what this does
		..()
		statpanel("Time")
		stat("Total Play-Time   ��","[time]")
		stat("Current Date   ��","[date]")*/

mob/players
	var/mob/players/M
	var/browse_once = 0
	proc
		TC()

			/*if(time_of_day == 1)
				stat("<font color = #fd535e>...The Sun is setting on the horizon...</font>")
				//return
			else
				if(time_of_day == 0)
					stat("<font color = #ffca7c>...The Sun is rising on the horizon...</font>")
					//return
				else*/
			if (time_of_day == DAY)
				stat("<font color = #f9d71c>...The Sun is overhead...</font>")//It tells you the time.
				return
				//oview() << "<font color = green><b>[usr]</b> looks at the Sky."			//And tells everyone in your view that you're looking at the clock.
				//sleep(3)
				//return
			else
				if(time_of_day == NIGHT)
					stat("<font color = #e3e1D7>...The Moon is overhead...</font>")
					return
		/*TC2() //1 = setting 0 = rising 2 = day

			if(browse_once==0)
				browsersc()
			else if(time_of_day == 1)//1 = setting 0 = rising 2 = day
				//usr << browse("<body background color=transparent; scroll=no>;<img src=dusksets.gif height=64 weight=64 scroll=no align=topleft>","default.sunmoon")
				//return
				usr << browse({"<body scroll=no bgcolor=transparent allow_transparency=true background="smbg.gif">
							<img src=dusksets.gif body scroll=no bgcolor=transparent allow_transparency=true></body>"},"<body bgcolor=transparent> body scroll=no;bgcolor=transparent;background-color:transparent;allow_transparency=true")
				return
			else if(time_of_day == 0&&ampm=="am")//1 = setting 0 = rising 2 = day
				//output('imgs/dawnrising.gif',"default.sunmoon")
				//usr << browse("<body background color=transparent; scroll=no>;<img src=dawnrising.gif height=64 weight=64 scroll=no align=topleft>","default.sunmoon")
				//return
				//usr << browse({"<body scroll=no bgcolor=transparent><body scroll=no bgcolor=transparent>
				//		<img src=dawnrising.gif body scroll=no bgcolor=transparent></body>"},"body scroll=no bgcolor=transparent")background="smbg.jpg"
				usr << browse({"<body scroll=no bgcolor=transparent allow_transparency=true background="smbg.gif">
						<img src=dawnrising.gif body scroll=no bgcolor=transparent allow_transparency=true></body>"},"body scroll=no;bgcolor=transparent;background-color:transparent;allow_transparency=true")
				return
			else if (time_of_day == 2)//1 = setting 0 = rising 2 = day
				//output('imgs/sunoverhead.gif',"default.sunmoon")
				//usr << browse("<body background color=transparent; scroll=no>;<img src=sunoverhead.gif height=64 weight=64 scroll=no align=topleft>","default.sunmoon")//It tells you the time.
				//oview() << "<font color = green><b>[usr]</b> looks at the Sky."			//And tells everyone in your view that you're looking at the clock.
				//sleep(3)
				//return
				usr << browse({"<body scroll=no bgcolor=transparent allow_transparency=true background="smbg.gif">
					<img src=sunoverhead.gif body scroll=no bgcolor=transparent allow_transparency=true></body>"},"body scroll=no;bgcolor=transparent;background-color:transparent;allow_transparency=true")
				return
			else if (time_of_day == 3)//1 = setting 0 = rising 2 = day
				//output('imgs/moonoverhead.gif',"default.sunmoon")
				//usr << browse("<body background color=transparent; scroll=no>;<img src=moonoverhead.gif height=64 weight=64 scroll=no align=topleft>","default.sunmoon")//It tells you the time.
				//oview() << "<font color = green><b>[usr]</b> looks at the Sky."			//And tells everyone in your view that you're looking at the clock.
				//sleep(3)
				//return
				usr << browse({"<body scroll=no bgcolor=transparent allow_transparency=true background="smbg.gif">
				<img src=moonoverhead.gif body scroll=no bgcolor=transparent allow_transparency=true></body>"},"body scroll=no;bgcolor=transparent;background-color:transparent;allow_transparency=true")
				return
	// Initialize character data on player creation
	New()
		..()
		// Create character data datum if not already set
		if(!character)
			character = new /datum/character_data()
			character.Initialize()

mob/players/proc
	browsersc()
		var/dusksets = 'imgs/dusksets.gif'
		var/dawnrising = 'imgs/dawnrising.gif'
		var/sunoverhead = 'imgs/sunoverhead.gif'
		var/moonoverhead = 'imgs/moonoverhead.gif'
		var/bg = 'imgs/smbg.gif'
		usr << browse_rsc(dusksets, "dusksets.gif")
		usr << browse_rsc(dawnrising, "dawnrising.gif")
		usr << browse_rsc(sunoverhead, "sunoverhead.gif")
		usr << browse_rsc(moonoverhead, "moonoverhead.gif")
		usr << browse_rsc(bg, "smbg.gif")
		browse_once=1*/

Form/TechTree
	/*
	   The form_window variable provides the browse() options that the form will use.
	   We want the form to show up in its own window (not the built-in browser view).
	*/
	form_window = "window=TechTree;titlebar=1;can_scroll=1;can_close=1;can_minimize=1;allow_transparency=true;size=600x800;focus=true;can_resize=1"

	Initialize()
		/*
		   This sets the initial values for the form each time before it is displayed.
		   The browse_rsc() calls sends an image to the player that is used
		   in the web page.
		*/

		usr << browse_rsc('imgs/tech.jpg', "tech.jpg")

	HtmlLayout()
		/*
		   You control the appearance of the form here.

		   We have added an error_text variable to the creating character mob, so we
		   can display an error if the form wasn't filled out correctly and needs to
		   be redisplayed with a message.  The error_text variable can't be part of
		   the form object, because then the form tries to let the player edit it.

		   When you embed a variable such as [name], the html library automatically
		   puts in the HTML for the text field or radio button or whatever is needed.
		   In the case of radio buttons, you place the numbered variables where each
		   should be displayed.

		   The [submit] variable puts in the necessary submit button at that spot.
		   You can also place a [reset] button if you want.

		   There is an image here, which was sent to the player in Initialize()
		   to put it on their system so it would show up on the page.

		   This example puts everything in table to make layout control easier.
		   Some of the table rows are blank to provide extra space between options.
		   You can change the HTML in any way you like for your game.*/

		var/page = {"<style type="text/css">

		 table.c1 {position:absolute; left:0px; top:0px; width:800px; height:px; z-index:0}
		 body {
		  input: focus;
		 }
		 input {
		  background-color: transparent;
		 }
		 :link { color: #767689 }
		 :visited { color: #003DCA }
		</style>
		<table id="Layer1" class="c1" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
		<td><img src="tech.jpg" alt="" border="0"></td>
		</tr>
		</tbody>
		</table>
		"}
		return page

mob/players/verb
	ShowTech()//works!
		//var
			//Form/TechTree/TT_form = new()
		set hidden = 1
		var/tt = 'imgs/tech.jpg'
		src << browse_rsc(tt, "tech.jpg")

			//var/page = {"<style type="text/css">"}
		src << browse(tt, "window=TechTree")
			//return page
		//src.TT_form.DisplayForm()
			//winset(src, "techtree","parent=default; is-visible = true; focus = true")
			/*var/V = winget(src,"techtree","is-visible")

		if (V == "false")
			winshow(src,"techtree",1)
			winset(src,"default","focus=true")
		else if (V == "true")
			winshow(src,"techtree",0)*/
		//winshow(src, "techtree", 1)
	ShowSpells()
		set hidden = 1
		winset(src, "spells","parent=spells; is-visible = true; focus = true")/*
	Vitae()//party spells
		set popup_menu = 1
		call(/mob/players/spells/proc/VitaeS)()
	Vitae2()//party spells
		set popup_menu = 1
		call(/mob/players/spells/proc/Vitae2S)()
	Abjure(var/mob/players/M in world)
				//set category = "Spells"
		set popup_menu = 1
		call(/mob/players/spells/proc/AbjureS)(M)
	Panacea()
				//set category = "Spells"
		set popup_menu = 1
		call(/mob/players/spells/proc/PanaceaS)()
	Bludgeon()
		set popup_menu = 1
		call(/mob/players/spells/proc/BludgeonS)()
	Telekinesis()
		set popup_menu = 1
		call(/mob/players/spells/proc/TelekinesisS)()
	Heat()
		set popup_menu = 1
		call(/mob/players/spells/proc/HeatS)()
	Shardburst()
		set popup_menu = 1
		call(/mob/players/spells/proc/ShardBurstS)()
	Watershock()
		set popup_menu = 1
		call(/mob/players/spells/proc/WatershockS)()
	Flame()
		set popup_menu = 1
		call(/mob/players/spells/proc/FlameS)()
	Icestorm()
		set popup_menu = 1
		call(/mob/players/spells/proc/IceStormS)()
	Cascadelightning()
		set popup_menu = 1
		call(/mob/players/spells/proc/CascadeLightningS)()
	Rephase()
		set popup_menu = 1
		call(/mob/players/spells/proc/RephaseS)()
	Cosmos()
		set popup_menu = 1
		call(/mob/players/spells/proc/CosmosS)()
	Quietus()
		set popup_menu = 1
		call(/mob/players/spells/proc/QuietusS)()
	Acid()
		set popup_menu = 1
		call(/mob/players/spells/proc/AcidS)()*/