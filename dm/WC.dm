var
	stamina				//stamina
	MAXhrankLVL=0	//Maxhranklvl when set to one it stops more lvls...
	MAXCrankLVL=0
	//stack=1
	treelist[0]
	//growstate//Growstate for trees
	//growthstate = "mature"//used on bushes?
	//Lamount=0
	typi=""
mob/var
	tmp
		Carving=0
		Cutting=0			//Defines cutting.

mob/players/proc/CLvl()
	// DEPRECATED - Use UpdateRankExp(RANK_CARVING, exp_amount) instead
	return


mob/players/proc/CSLvl()
	// DEPRECATED - Use UpdateRankExp(RANK_SPROUT_CUTTING, exp_amount) instead
	return
obj
	items
		plant
			Fruit
				layer = 9

				//Pomegranite

				olives
					can_stack=TRUE
					icon='dmi/64/plants.dmi'
					icon_state="olives"
					name = "Olives"

				//Date

			Sprouts
				layer = 9
				//can_stack = TRUE
				/*verb
					Get()
						set category=null
						set popup_menu=1
						set src in oview(1)
						//set hidden = 1
						var/mob/players/M = usr
						if(src.type==/obj/items/questitem)
							var/C=0
							var/obj/items/o
							if(M.quest==0)
								for(o as obj in M.contents)
									if(o.type==/obj/items/questitem&&C==0)
										C=1
										return
									else if(o.type==/obj/items/questitem)
										M << "You don't need that"
										return
								if(C==0)
									src.Move(usr, 1)
									return
							else
								M << "You don't need that"
								return
						else
							var/obj/O = src
							set src in oview(1)
							for(O as obj in view(3)) // only people you can SEE
								if(istype(O,/obj))
									src.Move(usr, 1)
									return
				//else
					//	src.Move(usr)
					Drop()
							//set hidden = 1
						set category=null
						set popup_menu=1
						set src in usr
						if(src.suffix == "Equipped")
							usr << "Un-equip [src] first!"
						else
							src.Move(usr.loc)*/
				ueiksprout
					can_stack = TRUE
					icon='dmi/64/tree.dmi'
					icon_state="usprout1"
					name = "Ueik Sprout"
					density = 1
					mouse_opacity = 1
					//layer = 4
					var/sproutisplanted=0


					/*New()
						// growstate 1, or a baby tree.
						growstate = 1
						// Update the pic of the tree.
						call(plant/ueiktree/proc/UpdateTreePic)(src)*/



					verb
						Plant()
							set popup_menu = 1
							var/mob/players/M = usr
							var/obj/items/plant/Sprouts/F = locate() in M.contents //change to seed
							var/UT
							UT = /obj/plant/ueiktree
							if(M.SHequipped!=1)
								M<<"<font color=#00bfff>Need to hold the shovel to plant the sprout properly.</font>"
								return
							else
								//if(get_dist(src,usr)>1/*&&get_dir(usr,src)==usr.dir*/)
								//	M<<"Stand on the soil to plant the sprout."
								//	return
								if(M.stamina == 0)
									M<<"Low stamina."
									return
								else
									if(F in M.contents&&F.stack_amount>=1)
										//F.RemoveFromStack(1)
										new UT(locate(x,y,z))
										M<<"You plant the [F]."
										UT:growstate=00
										//F:sproutisplanted=1
										F.RemoveFromStack(1)
										M.stamina -= 8
										M.updateST()

									else
										return

		Kindling
			layer = 9
			//can_stack = TRUE
			verb
				/*Get()
					set category=null
					set popup_menu=1
					set src in oview(1)
					//set hidden = 1
					var/mob/players/M = usr
					if(src.type==/obj/items/questitem)
						var/C=0
						var/obj/items/o
						if(M.quest==0)
							for(o as obj in M.contents)
								if(o.type==/obj/items/questitem&&C==0)
									C=1
									return
								else if(o.type==/obj/items/questitem)
									M << "You don't need that"
									return
							if(C==0)
								src.Move(usr, 1)
								return
						else
							M << "You don't need that"
							return
					else
						var/obj/O = src
						set src in oview(1)
						for(O as obj in view(3)) // only people you can SEE
							if(istype(O,/obj))
								src.Move(usr, 1)
								return
				//else
					//	src.Move(usr)
				Drop()
						//set hidden = 1
					set category=null
					set popup_menu=1
					set src in usr
					if(src.suffix == "Equipped")
						usr << "Un-equip [src] first!"
					else
						src.Move(usr.loc)*/
				Create_Novice_Fire()
					set waitfor = 0
					set category=null
					set popup_menu=1
					var/mob/players/M = usr
					var/obj/items/Kindling/ueikkindling/J
					//if(M.char_class!="Builder"&&"GM")
					//	M<<"You need to be a Builder to carve kindling."
					//	return
					/*if(M.char_class!="Builder"&&M in view(1))
						if(M.CKequipped==1)		//Makes sure the person is right beside the tree and facing it.
							if(Carving==1)		//This is saying if usr is already cuttin a tree...
								return
							if(stamina==0)		//Is your stamina to low???
								M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
								return
							for(J in M.contents)
								carve()		//Calls the Cut() proc
								sleep(5)
							..()*/
					//if(M.char_class=="Builder")
					if(M.OKequipped!=1)		//Makes sure the person is right beside the tree and facing it.
						M << "You need to use an Obsidian Knife."
					else
						if(Carving==1)		//This is saying if usr is already cuttin a tree...
							return
						if(stamina==0)		//Is your stamina to low???
							M<<"<font color=#00bfff>You're too tired to do anything!</font>"
							return
						for(J in M.contents)
							if(J.stack_amount>=1)
									//J.RemoveFromStack(1)
								createnovicefire()		//Calls the Cut() proc
								sleep(5)
								return

			ueikkindling
				can_stack = TRUE
				icon = 'dmi/64/tree.dmi'
				icon_state = "kind1"
				name = "Ueik Kindling"
				//var/stack = 1
				logs = 1
				//amount = 1
				mouse_opacity = 1
				//layer = 4

			proc/createnovicefire(mob/Carver)
				set waitfor = 0
				set category=null
				set popup_menu=1
				var/mob/players/M
				M = usr
				var/obj/items/Kindling/ueikkindling/J = locate() in M.contents
				var/Fire//=/obj/Fire
				//Makes the usr become Cutter... Not really neccesary.
				//if(M.Crank<Creq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
					//M<<"<FONT COLOR=RED>You must have a Carving Acuity of at least [Creq] to create a fire.</FONT>"
					//return
				/*if(KindAmount==0)		//Does the tree have logs???
					M<<"It's not worthwhile."
					return	*/			//If no... Return!
				if(M.OKequipped==0)			//Does the usr have a Axe to cut with?
					M<<"<font color=#00bfff>You need an Obsidian Knife equipped.</font>"
					return
				M<<"Carving"			//YAY YOU're CUTTING!!!
				if(M.stamina==0)			//Calling this again... Some screwy stuff could happen.
					M<<"<font color=#00bfff>You are too tired, drink some water.</font>"
					return
				if(Carving==1)
					return
								//Setting this to one because the usr is cutting a tree now.
				sleep(5)				//Sleeps about 2.5 seconds...
				if(M.OKequipped!=1)// Calling this again cause players like to drop axes just to see what will happen while they cut...
					M<<"<font color=#00bfff>You need to use an Obsidian Knife.</font>"
					return
				else
					//if(J.stack_amount>=1)// J.RemoveFromStack(1)
					Carving=1
					M.stamina -= 5	//Depletes one stamina
					if(prob(50))		//Takes the rarity of the tree and your woodcutting lvl
						M<<"<font color=green>You create a fire in front of you!</font>"		//You get "tree being cut" Logs!
						Fire = new/obj/Buildable/Fire(usr.loc)
						locate(Fire) in view(1)
						Fire:buildingowner = ckeyEx("[usr.key]")
						M.CLvl()//Calls the WCLvl() Proc to see if person got lvl...
						Carving=0// Cutting is set to 0 so you are free to move and cut some more.
						//for(J in M.contents)//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
						J.RemoveFromStack(1)//del(src)
						return
					else
						M<<"The material isn't viable for a fire."		//You wernt lucky enough to hit the treee.
						Carving=0
						return

mob
	proc
		exp2lvl(i as num)
			if(i<=5)
				switch(i)
					if(1)return 5*10;if(2)return 2*30;if(3)return 2*70;if(4)return 2*103;if(5)return 2*150
			else return 150

mob/players/proc
	WCLvl()
		// DEPRECATED - Use UpdateRankExp(RANK_WOODCUTTING, exp_amount) instead
		// This is kept for backward compatibility only
		return

var/global/growstage
//var/global/growstate
obj/plant//Simple right??? Just defining objects, Trees!
		//parent_type = /obj
	icon='dmi/64/tree.dmi'
	//icon_state="mat1"
	//var/growstage

	Cross(atom/movable/O)
		if(disallow_in)
			if(disallow_in & O.dir)
				return 0
			. = ..()

	Uncross(atom/movable/O)
		if(disallow_out)
			if(disallow_out & O.dir)
				return 0
			. = ..()

		//growstate

	UeikTreeH//set the other trees to do the same thing as ueik tree and hybernate after winter -- just copy the icons and set the colors to Ancient and Hallow
		//icon = 'dmi/64/tree.dmi'
		icon_state = "UTH"
		name = "Ueik Tree Hallow"
		density = 0
		layer = 10
		mouse_opacity = 1
		disallow_in = NORTH
		disallow_out = SOUTH
		var/mob/players/M
		DblClick()
			set waitfor = 0
			if(src in range(1, usr))
				Gather_Torch_MaterialH()
				sleep(3)
				return

		proc/Gather_Torch_MaterialH()
			set waitfor = 0
			set popup_menu = 1
			var/mob/players/M = usr
			//var/random/R = new()
			//if(R.chance(31))
				//new /obj/items/WDHNCH(M)
				//sleep(15)
				//M << "The Mature Ueik makes a Hallowed sound as you pluck off a Wooden Haunch."
				//sleep(1)
			if(global.season=="Autumn"||global.season=="Winter")//needs to be fleshed out a bit
				if(prob(40))
					M << "You begin collecting material..."
					sleep(5)
					M << "<font color=#00bfff>You collect Olives from the Hallow Ueik Tree.</font>"
					new /obj/items/plant/Fruit/olives(usr)
					//return
				else if(prob(35))
					M << "You begin collecting material..."
					sleep(5)
					M << "<font color=#00bfff>You pluck off a Wooden Haunch.</font>"
					new /obj/items/WDHNCH(M)
					//return

				else// if(prob(35))
					M << "You begin collecting material..."
					sleep(3)
					M << "The wood collected is not suitable for any use."
					//return
			else if(global.season!="Autumn"||global.season!="Winter")
				if(prob(35))
					M << "You begin collecting material..."
					sleep(5)
					M << "<font color=#00bfff>You pluck off a Wooden Haunch.</font>"
					new /obj/items/WDHNCH(M)
					//return

				else
					M << "You begin collecting material..."
					sleep(3)
					M << "The wood collected is not suitable for any use."
					//return

	UeikTreeA//set the other trees to do the same thing as ueik tree and hybernate after winter -- just copy the icons and set the colors to Ancient and Hallow
		//icon = 'dmi/64/tree.dmi'
		icon_state = "UTA"
		name = "Ueik Tree Ancient"
		density = 0
		layer = 10
		mouse_opacity = 1
		disallow_in = NORTH
		disallow_out = SOUTH
		DblClick()
			set waitfor = 0
			var/mob/players/M = usr
			if(M.OKequipped==1||M.CKequipped==1)
				M << "You begin collecting material..."
				sleep(3)
				Gather_Fir()
				//M << "You begin collecting material..."
				//sleep(3)
				return
			else
				if(src in range(1, usr))
					M << "You begin collecting material..."
					sleep(3)
					Gather_Thorn()
					//M << "You begin collecting material..."
					//sleep(3)
					return

		proc/Gather_Thorn()
			set waitfor = 0
			set popup_menu = 1
			var/mob/players/M = usr
			//var/random/R = new()
			//if(R.chance(31))
				//new /obj/items/WDHNCH(M)
				//sleep(15)
				//M << "The Mature Ueik makes a Hallowed sound as you pluck off a Wooden Haunch."
				//sleep(1)

			if(prob(50))
				M << "<font color=#00bfff>The Ancient Ueik tree is hard as rock but you manage to find a sharp branch on the ground.</font>"
				new /obj/items/UeikThorn(M)
				M << "<font color=#00bfff>You found a Ueik Thorn!</font>"
				return
			else
				//sleep(10)
				M << "The material collected is too brittle to be used."
				return

		proc/Gather_Fir()
			set waitfor = 0
			set popup_menu = 1
			var/mob/players/M = usr
			//var/random/R = new()
			//if(R.chance(31))
				//new /obj/items/WDHNCH(M)
				//sleep(15)
				//M << "The Mature Ueik makes a Hallowed sound as you pluck off a Wooden Haunch."
				//sleep(1)
			if(M.OKequipped==1||M.CKequipped==1)
				if(prob(50))
					M << "<font color=#00bfff>You slice some leather-esque bark from the Ancient Ueik tree.</font>"
					new /obj/items/UeikFir(M)
					return
				else
					//sleep(10)
					M << "The material collected is too brittle to be used."
					return
			else
				M << "You realize a knife of some kind may help retrieve material."
				return
		/*
			set waitfor = 0
			if(src in range(1, usr))
				usr << "<font color=#00bfff>The Ancient Ueik is hard as rock but you manage to find a branch-like thorn on the ground.</font>"
				sleep(5)
				Gather_Ueikthorn()
				sleep(5)
			else
				if(src in range(1, usr))
					Gather_Ueikfir()
					//M << "The Tree makes a Hallow sound."
					sleep(10)
		proc/Gather_Ueikfir()
			set waitfor = 0
			//set hidden = 1
			//var/random/R = new()
			var/mob/players/M = usr
			if((prob(31)) && (Carving==0))
				Carving = 1
				sleep(5)
				new /obj/items/UeikFir(M)
				usr<<"<font color=green>You Slice off some Ueik Fir.</font>"
				Carving = 0
			else
				if((prob(21)) && (Carving==0))
					Carving = 1
					sleep(5)
					usr<<"The material collected is too brittle to serve the purpose."
					Carving = 0
					return
		proc/Gather_Ueikthorn()
			set waitfor = 0
			//set hidden = 1
			//var/random/R = new()
			var/mob/players/M = usr
			if((prob(31)) && (Carving==0))
				Carving = 1
				sleep(5)
				new /obj/items/UeikThorn(M)
				usr<<"<font color=green>You Pick up a Ueik Thorn.</font>"
				Carving = 0
			else
				if((prob(21)) && (Carving==0))
					Carving = 1
					sleep(5)
					usr<<"The material collected is too brittle to serve the purpose."
					Carving = 0
					return*/

obj/items/plant/stump//When you cut down a tree and don't harvest it, leaving a stump and the server reboots, the stump will still be there as a stump, but it functions like a tree
	can_stack = TRUE//Needs to be fixed
	icon = 'dmi/64/tree.dmi'
	icon_state = "ustump"
	name = "Stump"

	/*Click()
		set src in usr
		if(usr.HMequipped==1&&usr.CKequipped==1)
			Create_Bucket()
		else
			usr << "Need to use a Hammer with the Carving Knife."
			return*/
	verb/Create_Ueik_Shingle()
		set src in usr
		var/dice = "1d4"
		var/R = roll(dice)
		if(usr.HMequipped==1&&usr.CKequipped==1)

			if(R>=2)
				new /obj/items/Crafting/Created/UeikShingle(usr)
				usr << "The Ueik Stump is malleable enough that you manage to chop a Ueik Shingle."
				src.RemoveFromStack(1)
				return
			else
				//new obj/items/crafting/created/Vessel()
				usr << "This Stump isn't suitable for a Ueik Shingle and falls apart."
				src.RemoveFromStack(1)
				return
		else
			usr << "Need to use a Hammer with the Carving Knife."
			return
	verb/Create_Fruit_Press()
		set src in usr
		var/dice = "1d4"
		var/R = roll(dice)
		if(usr.HMequipped==1&&usr.CKequipped==1)

			if(R>=3)

				new /obj/items/tools/Containers/FruitPress(usr)
				usr << "The Ueik Stump is malleable enough that you manage to carve and form a fruit press."
				src.RemoveFromStack(1)
				return
			else

				//new obj/items/crafting/created/Vessel()
				usr << "This Stump isn't suitable for a vessel and falls apart."
				src.RemoveFromStack(1)
				return
		else
			usr << "Need to use a Hammer with the Carving Knife."
			return
	verb/Create_Wooden_Torch_Head()
		set src in usr
		var/dice = "1d4"
		var/R = roll(dice)
		if(usr.HMequipped==1&&usr.CKequipped==1)
			if(R>=2)
				new /obj/items/Crafting/Created/WoodenTorchHead(usr)
				usr << "The Ueik Stump is malleable enough that you manage to chop and carve a Wooden Torch Head."
				src.RemoveFromStack(1)
				return
			else
				//new obj/items/crafting/created/Vessel()
				usr << "This Stump isn't suitable for a Wooden Torch Head and falls apart."
				src.RemoveFromStack(1)
				return
		else
			usr << "Need to use a Hammer with the Carving Knife."
			return
	verb/Create_Vessel()
		set src in usr
		var/dice = "1d4"
		var/R = roll(dice)
		if(usr.HMequipped==1&&usr.CKequipped==1)
			if(R>=2)
				new /obj/items/tools/Containers/Vessel(usr)
				usr << "The Ueik Stump is malleable enough that you manage to carve and form a vessel."
				src.RemoveFromStack(1)
				return
			else
				//new obj/items/crafting/created/Vessel()
				usr << "This Stump isn't suitable for a vessel and falls apart."
				src.RemoveFromStack(1)
				return
		else
			usr << "Need to use a Hammer with the Carving Knife."
			return
obj/plant/ueiktree/ueikstump
	name = "Stump"
	icon_state ="ustump"
	growstate = 7
	mature = 1
obj/plant/ueiktree
			// Growstate is the tree's current 'phase'
			//var/growstate//Also grow state for trees?
	var										//So each tree doesn't always have the same amount of logs each time...
		//stack									//So it's random between the set numbers...
		obj/items/Logs/UeikLog/log	//Defines the certain log thats going to be made.
		LogAmount	//Logs in the trees...
		Rarity		//Basically how hard is it to hit the tree?
		MinLog		//Minimum logs in tree
		MaxLog		//Max logs that can be in tree
		GiveXP		//Exp tree gives!
		LogType		//Log type, What log does the tree give...  Its really just for Text purposes.
		spawntime	//How long does it take for the tree to respawn???
		hreq		//hrank lvl required to chop tree down...
		obj/items/plant/sprout
		MinSprout
		MaxSprout
		SproutAmount
		Chance
		SproutType
		CSReq
		GivenXP
		growstate
		mature
	//can_stack = TRUE
	name = "Ueik Tree"
	icon = 'dmi/64/tree.dmi'
	icon_state = "useedling"
	density=0
	mouse_opacity=1
	MinLog=1
	MaxLog=3
	GiveXP=5
	layer = 10
	mature=0//this flag handles if a tree has grown to a mature stage, so that it can carry through winter into the new year
	LogAmount=1
	log=/obj/items/Logs/UeikLog    //This is basically saying what log will be made when tree is cut...
	MinSprout=1
	MaxSprout=5
	SproutAmount=3
	sprout=/obj/items/plant/Sprouts/ueiksprout
	Chance = 89
	SproutType="Ueik"
	CSReq = 0
	//CSRank = 0
	GivenXP=5
	Rarity=89
	spawntime=420
	LogType= "Ueik"
	hreq=1
	disallow_in = NORTH
	disallow_out = SOUTH
			// Why include this line if we're setting it to a baby state
			// later on?
			// Even though the tree won't look like this when the game
			// starts, we need something to see in the map editor.
	DblClick()
		set waitfor = 0
		set popup_menu = 1
		var/mob/players/M = usr
		//if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)
		//if(!(src in range(2, usr)))
		//if(get_step_away(src,usr,3))
			//M<<"You need to be closer to cut."
			//return
		//else//growstates: 0 = Seedling 1 = Sprout 2 = Young 3 = Blooming 4 = Mature 5 = Dormant 6 = Celebration 7 = Stump
			//if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)		//Makes sure the person is right beside the tree and facing it.
		if(src in range(1, usr))
	//if(M.char_class!="Builder")		//Makes sure the person is right beside the tree and facing it.

			if(Cutting==1)		//This is saying if usr is already cuttin a tree...
				M<<"You are already cutting!"
				return
			else if(stamina==0)		//Is your stamina to low???
				M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
				return
			else if(M.GVequipped==1&&growstate==6)
				Celebrate(M)		//Calls the Cut() proc
				sleep(5)
				return
			else if(M.SKequipped==1&&growstate==3||M.SKequipped==1&&growstate==42||M.SKequipped==1&&growstate==43)
				Cut_Sprout(M)		//Calls the Cut() proc
				sleep(5)
				return
			else if(M.SHequipped==1&&growstate==7)
				//Cut(M)		//Calls the Cut() proc
				RemoveStump()
				sleep(5)
				return
			else if(M.SAXequipped==0&&growstate==5||M.SAXequipped==0&&growstate==51||M.SAXequipped==0&&growstate==4||M.SAXequipped==0&&growstate==41||M.SAXequipped==0&&growstate==44)
				Gather_Torch_Material()
				M << "<font color=green>You begin collecting material.</font>"
				sleep(10)
				return
			else if(M.AXequipped==1||M.SAXequipped==1)//&&growstate==4||M.AXequipped==1&&growstate==41)
				Cut(M)		//Calls the Cut() proc
				sleep(5)
				return

			else if(growstate==0)
				M<<"This Tree is still growing and not viable to cut down."
				return
			else if(growstate==1)
				M<<"This Tree is just a sprout and therefor isn't viable to cut down."
				return
			else if(growstate==2)
				M<<"This Tree is just a sappling and therefor isn't viable to cut down."
				return
			else if(growstate==3)
				M<<"This Tree is barely blooming and isn't viable to cut down."
				return
			else if(growstate==5)
				M<<"This Tree is too old and brittle to cut down."
				return
			else if(growstate==51)
				M<<"This Tree is covered in snow and ice and is not viable to cut down."
				return

			else if(M.AXequipped==0&&growstate==4||M.AXequipped==0&&growstate==41||M.AXequipped==0&&growstate==5||M.AXequipped==0&&growstate==51)
				M<<"You need to use your Axe."
				return
			else if(M.SAXequipped==0&&growstate==4||M.SAXequipped==0&&growstate==41||M.SAXequipped==0&&growstate==5||M.SAXequipped==0&&growstate==51)
				M<<"You need to use your Axe."
				return

	New()
		..()
		if(growstate!=7)
			treelist+=src
			if(!LogAmount)
				src.LogAmount = rand(src.MinLog, src.MaxLog)
			if(!SproutAmount)
				src.SproutAmount = rand(src.MinSprout, src.MaxSprout)
		else if(growstate==7||istype(/obj,/obj/plant/ueiktree/ueikstump))
			return
		/*if(!LogAmount)
			src.LogAmount = rand(src.MinLog, src.MaxLog)
		if(!SproutAmount)
			src.SproutAmount = rand(src.MinSprout, src.MaxSprout)*/

	Del()
		treelist-=src
		..()

	proc/Grow()
	proc/UpdateTreePic()
	//New()
		//..()
		//if(growstate == 7)
		//	return
		//growstate = growstage
		//growstage = tstateload//set the ambient value to the loaded save files ambient value. Persistent lighting.
		//LogAmount = LogAmountload
		//SproutAmount = SproutAmountload
		//spawn(1)
			//UpdateTreePic()
		// growstate 1, or a baby tree. sprout sappling bloom mature old
		//LogAmount=rand(MinLog,MaxLog)		//This makes it so we can make a Minimum log amount and a max log amount
		//SproutAmount=rand(MinSprout,MaxSprout)
		//growstate = tstateload
		//growstate = 0
		// Update the pic of the tree.
		//UpdateTreePic()
	Grow()
		var/randomvalue = rand(1200,2000)
		spawn(randomvalue)
		//spawn(420) // Normaly set to 12000, or twenty min.
		// Cycle the growstate var.
			if (growstate == 7||istype(/obj,/obj/plant/ueiktree/ueikstump))
				// chopped down? It is now a stump, no more growth until I implement a random seed
				src:growstate = 7//stump
				//src:growstate = 0//this will make stumps grow new trees
				return//disable to allow stumps to grow into trees again
			//otherwise this is just day and month timing... no errors here
			else if (growstate == 00&&global.season=="Spring"&&mature==0)//for sprouts -- need to make "plant sprout" verb make a ueik tree with growstate as 0 instead of a separate instanced object outside of the tree time spawner
				//for(src)
				src:growstate = 0//new sprout
				//src:growstate = 0//this will make stumps grow new trees
				return
			else if (month=="Shevat"&&growstate!=7&&mature==1)
				src:mature=1
				src:growstate = 44//aftwint
			else if (month=="Adar"&&growstate!=7&&mature==1)
				src:mature=1
				src:growstate = 43//regrow
			else if (month=="Nissan"&&growstate!=7&&mature==1)
				src:mature=1
				src:growstate = 431//regrow2
			else if (month=="Iyar"&&growstate!=7&&mature==1)
				src:mature=1
				src:growstate = 42//bloom
			else if (global.season == "Summer"&&growstate!=7&&mature==1)
				src:mature=1
				src:growstate = 4
			else if (month == "Shevat"&&day<=1&&growstate!=7&&mature==0)//need to set this up so that trees that have grown to a mature stage, stay there instead of reset
//thinking about adding a grown boolean or a new growstate that tells a tree that it is mature and to lose all of its leaves late winter and regrow them in spring
				src:growstate = 0//seedling
			else if (month == "Shevat"&&day>=9&&growstate!=7&&mature==0||month == "Shevat"&&day<=15&&growstate!=7&&mature==0)

				src:growstate = 1//sprout
			else if (month == "Shevat"&&day>=16&&growstate!=7&&mature==0)

				src:growstate = 2//young
			else if (month == "Adar"&&day>=1&&growstate!=7&&mature==0)

				src:growstate = 3//bloom
			else if (month == "Nisan"&&day>=5&&growstate!=7&&mature==0)//			most growth throughout second month (shevat), blooming month of third month (adar), then mature by end of spring and into summer
				src:mature=1
				src:growstate = 4//Mature
			//if (season == "Summer"&&day>=15)

			else if (global.season == "Summer"&&growstate!=7)
				src:mature=1
				src:growstate = 4

				//src:growstate = 4//Mature
			else if (global.season == "Autumn"&&growstate!=7)
				src:mature=1
				src:growstate = 41//fall mature
			//if (season == "Autumn"&&day>=15)

				//src:growstate = 4//Mature
			else if (month == "Tevet"&&day<=9&&growstate!=7)//&&day<=14)
				src:mature=1
				src:growstate = 51//Dormant
			//if (season == "Winter"&&day>=15)

				//src:growstate = 5//Dormant
			else if (month == "Tevet"&&day==10&&growstate!=7)
				src:mature=1
				src:growstate = 6//Celebration

			else if (month == "Tevet"&&day>=11&&growstate!=7)//&&day<=14)
				src:mature=1
				src:growstate = 52//winter dormant
			//src:growstate+=1//grow the trees (keep this enabled for out of season testing, otherwise, when commenting out, trees will only grow for set months/seasons.
			//if(src.growstate>=8)//just a temporary check to make sure growstate doesn't go above the actual amount of stages that exist
				//src:growstate = 1
			src.UpdateTreePic()


	UpdateTreePic()
		//growstates: 0 = Seedling 1 = Sprout 2 = Young 3 = Blooming 4 = Mature 5 = Dormant 6 = Celebration 7 = Stump
		// Update the tree pic as needed:
		//var/obj/Trees/ueiktree/T
		//T = src
		//label


		if (growstate == 1&&growstate!=7)

			src:icon_state = "usprout1"
			src:verbs -= /obj/plant/ueiktree/proc/RemoveStump
			src:verbs -= /obj/plant/ueiktree/proc/Cut
			src:verbs -= /obj/plant/ueiktree/proc/Cut_Sprout
			src:verbs -= /obj/plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/Celebrate
			src:name = "Ueik Sprout"
			//growstate="sprout"
		else if (growstate == 2&&growstate!=7)
			//for(T)
			src:icon_state = "uyoung2"
			src:verbs -= /obj/plant/ueiktree/proc/RemoveStump
			src:verbs -= /obj/plant/ueiktree/proc/Cut
			src:verbs -= /obj/plant/ueiktree/proc/Cut_Sprout
			src:verbs -= /obj/plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/Celebrate
			src:name = "Young Ueik Tree"
			//growstate="sappling"
		else if (growstate == 3&&growstate!=7)
			src:icon_state = "uflow3"
			src:verbs -= /obj/plant/ueiktree/proc/RemoveStump
			src:verbs -= /obj/plant/ueiktree/proc/Cut
			src:verbs += /obj/plant/ueiktree/proc/Cut_Sprout//can only harvest tree sprouts in the blooming spring
			src:verbs -= /obj/plant/ueiktree/proc/Gather_Torch_Material//can only harvest torch materials from mature/dormant wood
			src:verbs -= /obj/plant/ueiktree/proc/Celebrate
			src:name = "Flowering Ueik Tree"
			//growstate="bloom"
		else if (growstate == 44&&growstate!=7&&mature==1)
			//verbs += plant/ueiktree/proc/Gather_Torch_Material
			//flick('winttree.dmi',src)
			src:verbs -= /obj/plant/ueiktree/proc/RemoveStump
			src:verbs -= /obj/plant/ueiktree/proc/Cut_Sprout
			src:verbs += /obj/plant/ueiktree/proc/Cut
			src:verbs += /obj/plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/Celebrate
			src:icon_state = "umat4aftwint"
			src:name = "Hybernating Mature Ueik Tree"
			//growstate="mature"
		else if (growstate == 43&&growstate!=7&&mature==1)
			//verbs += plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/RemoveStump
			src:verbs += /obj/plant/ueiktree/proc/Cut_Sprout
			src:verbs += /obj/plant/ueiktree/proc/Cut
			src:verbs += /obj/plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/Celebrate
			src:icon_state = "umat4regrow"
			src:name = "Budding Mature Ueik Tree"
			//growstate="mature"
		else if (growstate == 431&&growstate!=7&&mature==1)
			//verbs += plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/RemoveStump
			src:verbs += /obj/plant/ueiktree/proc/Cut_Sprout
			src:verbs += /obj/plant/ueiktree/proc/Cut
			src:verbs += /obj/plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/Celebrate
			src:icon_state = "umat4regrow2"
			src:name = "Budding Mature Ueik Tree"
			//growstate="mature"
		else if (growstate == 42&&growstate!=7&&mature==1)
			//verbs += plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/RemoveStump
			src:verbs += /obj/plant/ueiktree/proc/Cut_Sprout
			src:verbs += /obj/plant/ueiktree/proc/Cut
			src:verbs += /obj/plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/Celebrate
			src:icon_state = "umat4spring"
			src:name = "Blooming Mature Ueik Tree"
			//growstate="mature"
		else if (growstate == 4&&growstate!=7)
			//verbs += plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/RemoveStump
			src:verbs -= /obj/plant/ueiktree/proc/Cut_Sprout
			src:verbs += /obj/plant/ueiktree/proc/Cut
			src:verbs += /obj/plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/Celebrate
			src:icon_state = "umat4"
			src:name = "Mature Ueik Tree"
		else if (growstate == 41&&growstate!=7)
			//verbs += plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/RemoveStump
			src:verbs -= /obj/plant/ueiktree/proc/Cut_Sprout
			src:verbs += /obj/plant/ueiktree/proc/Cut
			src:verbs += /obj/plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/Celebrate
			src:icon_state = "umat4aut"
			//src:name = "Mature Ueik Tree"
			//growstate="mature"
		else if (growstate == 5&&growstate!=7)
			src:icon_state = "udorm5"
			src:verbs -= /obj/plant/ueiktree/proc/RemoveStump
			src:verbs -= /obj/plant/ueiktree/proc/Cut_Sprout
			src:verbs -= /obj/plant/ueiktree/proc/Cut
			src:verbs += /obj/plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/Celebrate
			src:name = "Dormant Ueik Tree"
		else if (growstate == 51&&growstate!=7)
			src:icon_state = "udorm5wint"
			src:verbs -= /obj/plant/ueiktree/proc/RemoveStump
			src:verbs -= /obj/plant/ueiktree/proc/Cut_Sprout
			src:verbs -= /obj/plant/ueiktree/proc/Cut
			src:verbs += /obj/plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/Celebrate
			src:name = "Dormant Ueik Tree"
		else if (growstate == 52&&growstate!=7)
			src:icon_state = "umat4winth"
			src:verbs -= /obj/plant/ueiktree/proc/RemoveStump
			src:verbs -= /obj/plant/ueiktree/proc/Cut_Sprout
			src:verbs -= /obj/plant/ueiktree/proc/Cut
			src:verbs -= /obj/plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/Celebrate
			src:name = "Dormant Ueik Tree"
			//growstate="old"
		else if (growstate == 6&&growstate!=7)
			src:icon_state = "ucele"
			src:verbs -= /obj/plant/ueiktree/proc/RemoveStump
			src:verbs -= /obj/plant/ueiktree/proc/Cut_Sprout
			src:verbs -= /obj/plant/ueiktree/proc/Cut
			src:verbs -= /obj/plant/ueiktree/proc/Gather_Torch_Material
			src:verbs += /obj/plant/ueiktree/proc/Celebrate
			src:name = "Celebration Tree"
			//goto label
		else if (growstate == 7||istype(/obj,/obj/plant/ueiktree/ueikstump))
			src:icon_state ="ustump"
			src:verbs += /obj/plant/ueiktree/proc/RemoveStump
			src:verbs -= /obj/plant/ueiktree/proc/Cut
			src:verbs -= /obj/plant/ueiktree/proc/Cut_Sprout
			src:verbs -= /obj/plant/ueiktree/proc/Gather_Torch_Material
			src:verbs -= /obj/plant/ueiktree/proc/Celebrate
			src:name = "Stump"
			return
			//growstate = "ustump"
			//growstate="old"
		//Grow2()
		if(growstate!=7)
			Grow()
		else if(growstate==7||istype(/obj,/obj/plant/ueiktree/ueikstump)) return
	//..()
	proc
		RemoveStump()

			var/mob/players/M = usr
			//var/J = src
				//if(M.char_class!="Builder"&&"GM")
				//	M<<"You need to be a Builder to carve kindling."
				//	return
			if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)
				//if(!(src in range(2, usr)))
				//if(get_step_away(src,usr,3))
				M<<"<font color=#00bfff>You need to be closer to remove the stump.</font>"
				return
			else
					//if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)		//Makes sure the person is right beside the tree and facing it.
				if(src in range(1, usr))
					if(M.SHequipped==1)		//Makes sure the person is right beside the tree and facing it.
						if(Cutting==1)		//This is saying if usr is already cuttin a tree...
							return
						if(stamina==0)		//Is your stamina to low???
							M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
							return
						else if(growstate==7)
							//Calls the Cut() proc
							new /obj/items/plant/stump(M)
							M<<"<font color=green>You dig up the stump.</font>"
							del(src)
							return//sleep(5)
		Cut(mob/Cutter)
			set waitfor = 0
			var/mob/players/M
			//var/obj/items/Logs/UeikLog/UL = new(src)
			M = usr		//Makes the usr become Cutter... Not really neccesary.
			if(!M.CheckRankRequirement(RANK_WOODCUTTING, hreq))			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
				M<<"<FONT COLOR=RED>You must have a Harvesting Acuity of at least [hreq] to cut [LogType] trees.</FONT>"//eventually at some point I need to actually setup the rank restrictions and add additional higher rank content -- after all the fundamentals are rock solid and bugs squashed
				return
			if(growstate==7||growstage==7||src.icon_state=="ustump")
				Cutter << "This Ueik tree is already cut down."
				return
			if(LogAmount<=0)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
				src.icon_state="ustump"
				growstate=7
				return
			if(LogAmount==0)		//Does the tree have logs???
				M<<"This tree cannot provide more logs."
				return				//If no... Return!
			if(M.AXequipped==0||M.SAXequipped==0)			//Does the usr have a Axe to cut with?
				Cutter<<"<font color=#00bfff>You need an Axe equipped.</font>"
				return
			if(M.stamina<=5)			//Calling this again... Some screwy stuff could happen.
				M<<"<font color=#00bfff>Your stamina is too low.</font>"
				return
			if(Cutting==1)
				return
							//Setting this to one because the usr is cutting a tree now.
			//sleep(10)				//Sleeps about 2.5 seconds...
			if(LogAmount==0)		//If log amount being called again...
				M<<"You already cut the [LogType] tree down."
				Cutting=0
				return
			else
				if(M.AXequipped==0||M.SAXequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
					Cutter<<"<font color=#00bfff>You need to hold an Axe to use it on the [LogType] tree.</font>"
					return
				/*if (M.stamina < 5)
					M << "Low stamina."*/

				else if(M.AXequipped==1||M.SAXequipped==1||growstate==4||growstate==51||growstate==52||growstate==41||growstate==42||growstate==43||growstate==431||growstate==44)
					M<<"<font color=green>You begin to work on the [LogType] tree with your Axe.</font>"			//YAY YOU're CUTTING!!!
					M.overlays += image('dmi/64/axeoy.dmi',icon_state="[get_dir(M,src)]")
					Cutting=1
					sleep(10)
					M.stamina -= 5	//Depletes one stamina
					M.updateST()
					if(prob(Rarity+M.hrank))		//Takes the rarity of the tree and your woodcutting lvl
						Cutter<<"<font color=green>You Finish working the [LogType] tree and receive [LogType] log!</font>"		//You get "tree being cut" Logs!
						M.overlays -= image('dmi/64/axeoy.dmi',icon_state="[get_dir(M,src)]")
						new log(usr)			//Remember log=obj/items/Logs/Oak???  Heres where this creates a log into invetory
						//new UL
						M.UpdateRankExp(RANK_WOODCUTTING, GiveXP)				//  Add The exp from tree to you.
						Cutting=0							// Cutting is set to 0 so you are free to move and cut some more.
						LogAmount--							//Depletes one log from the Amount.
						if(LogAmount<=0)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
							src.icon_state="ustump"
							growstate=7
							//sleep(spawntime)
							Cutting=0		//Waiting the spawntime you set for your trees
							//src.icon_state= initial(icon_state)		//Makes your trees come back to life
							//growstate=1
							//LogAmount=rand(MinLog,MaxLog)			//Redefines new LogAmounts.
							//del(src)
							return
					else
						M.overlays -= image('dmi/64/axeoy.dmi',icon_state="[get_dir(M,src)]")
						Cutter<<"<font color=#00bfff>You missed the tree!</font>"
						//sleep(10)		//You wernt lucky enough to hit the treee.
						Cutting=0
						//sleep(10)
						return


		Celebrate()
			if(get_dist(src,usr)>1)
			//if(!(src in range(2, usr)))
			//if(get_step_away(src,usr,3))
				usr<<"<font color=#00bfff>You need to be closer and wearing gloves to receive your Celebration day gift!</font>"
				return
			else if(growstate==6)
				//if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)		//Makes sure the person is right beside the tree and facing it.
				//if(src in range(1, usr))
				var/mob/players/M
				M = usr
				//var/obj/items/torches/brasshandlamp/BHL = locate(usr.contents)

				if(M.gr==1)
					M<<"You already received your gift for this year!"
					return
				else
					if(src in range(1,M))
						if(M.GVequipped==1)
							M.gr=1
							new/obj/items/torches/brasshandlamp(M)
							M<<"<font color=green>Happy Celebration day! Give thanks and praises to Our Lord, Yeshua, who was born on this fabled day.</font>"
							return

		Cut_Sprout()
			set waitfor = 0
			var/mob/players/M = usr
			var/J = src

			//if(M.char_class!="Builder"&&"GM")
			//	M<<"You need to be a Builder to carve kindling."
			//	return
			if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)
			//if(!(src in range(2, usr)))
			//if(get_step_away(src,usr,3))
				M<<"<font color=#00bfff>You need to be closer to cut.</font>"
				return
			else
				//if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)		//Makes sure the person is right beside the tree and facing it.
				if(src in range(1, usr))
					if(M.SKequipped==1)//Makes sure the person is right beside the tree and facing it.
						if(Cutting==1)//This is saying if usr is already cuttin a tree...
							return
						if(stamina==0)//Is your stamina to low???
							M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
							return
						for(J in M.contents)
							cutsprout()//Calls the Cut() proc
							sleep(5)
						//..()
		cutsprout(mob/Cutter)
			set waitfor = 0
			var/mob/players/M
			M = usr		//Makes the usr become Cutter... Not really neccesary.
			if(M.CSRank<CSReq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
				M<<"<FONT COLOR=GREEN>You must have a Botany rank of at least [CSReq] to cut [SproutType].</FONT>"
				Cutting=0
				return
			if(SproutAmount==0)		//Does the tree have logs???
				M<<"You look around but do not find more sprouts to cut."
				Cutting=0
				return				//If no... Return!
			if(M.SKequipped==0)			//Does the usr have a Axe to cut with?
				M<<"<font color=#00bfff>You need a Sickle equipped.</font>"
				Cutting=0
				return
			M<<"You begin to harvest a [SproutType] sprout."			//YAY YOU're CUTTING!!!
			if(M.stamina==0)			//Calling this again... Some screwy stuff could happen.
				M<<"<font color=#00bfff>You are too tired, drink some water.</font>"
				Cutting=0
				return
			if(Cutting==1)
				return
							//Setting this to one because the usr is cutting a tree now.
			sleep(5)				//Sleeps about 2.5 seconds...
			if(SproutAmount==0)		//If log amount being called again...
				M<<"You already cut the [SproutType] sprout."
				Cutting=0
				return
			else
				if(M.SKequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
					M<<"<font color=#00bfff>You need to use a Sickle.</font>"
					Cutting=0
					return
				/*if (M.stamina < 5)
					M << "Low stamina."*/
				else
					Cutting=1
					M.stamina -= 5	//Depletes one stamina
					if(prob(Chance+M.CSRank))		//Takes the rarity of the tree and your woodcutting lvl
						M<<"You get [SproutType] sprout!"		//You get "tree being cut" Logs!
						new sprout(usr.loc)
						//update()			//Remember log=obj/items/Logs/Oak???  Heres where this creates a log into invetory
						M.UpdateRankExp(RANK_SPROUT_CUTTING, GivenXP)//  Add The exp from tree to you.						//Calls the WCLvl() Proc to see if person got lvl...
						Cutting=0							// Cutting is set to 0 so you are free to move and cut some more.
						SproutAmount--							//Depletes one log from the Amount.
						if(SproutAmount<=0)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
							Cutting=0
							return//del(src)
					else
						M<<"You missed!"		//You wernt lucky enough to hit the treee.
						Cutting=0
						return


		Gather_Torch_Material()
			set waitfor = 0
			set hidden = 1
			var/mob/players/M = usr

			if(global.season=="Spring"&&mature==0)
				M<<"<font color=#00bfff>The Ueik Tree is too green to find viable torchwood...</font>"
				return
			else if(mature==1)

				if(prob(35))
					//M << "You begin collecting material..."
					sleep(5)
					M << "<font color=#00bfff>You pluck off a Wooden Haunch.</font>"
					new /obj/items/WDHNCH(M)
					//return

				else
					//M << "You begin collecting material..."
					sleep(3)
					M << "The wood collected is not suitable for any use."



					//return
			//var/random/R = new()
			//if(growstate==5||growstate==51||growstate==41||growstate==4||growstate==42||growstate==43||growstate==44)
			/*if(prob(31))
				//new /obj/items/WDHNCH(M)
				sleep(15)
				//M << "The Mature Ueik makes a Hallowed sound as you pluck off a Wooden Haunch."
				//sleep(1)
				//if(R.chance(31))
				M << "<font color=green>You pluck off a Wooden Haunch.</font>"
				new /obj/items/WDHNCH(M)
				return
			else
				sleep(10)
				M << "The material collected is too brittle to serve the purpose of a torch."
				return
			if(growstate==42||growstate==43)
				M<<"<font color=#00bfff>The tree is too green to use as a torch...</font>"
				return*/


obj/items/Logs
	//can_stack = TRUE
	layer = 9

	var// Growstate is the tree's current 'phase'
		obj/items/Kindling/kindling
		MinKind
		MaxKind
		KindAmount
		KindType
		obj/Handle/handle
		MinHand
		MaxHand
		HandleAmount
		HandType
		pole = /obj/items/Crafting/Created/Pole
		Handle=/obj/items/Crafting/Created/Handle
		board =/obj/items/Crafting/Created/UeikBoard
		MinBoard
		MaxBoard
		BoardAmount
		BoardType
		MinPole
		MaxPole
		PoleAmount
		PoleType
		obj/items/Crafting/Created/WoodenTorchHead/WTH
		MinHead
		MaxHead
		obj/items/Logs/UeikLog
		HeadAmount
		HeadType
		GivenXP=5
		Chance
		Creq=1

		//stack=1
		//amount=1

	UeikLog
		can_stack = TRUE
		icon='dmi/64/tree.dmi'
		icon_state="UeikLog"
		name = "Ueik Log"
		//stack = 1
		//layer = 4
		logs=1
		//amount = 10
		MinKind=4
		MaxKind=13
		KindType="Ueik"
		KindAmount=1
		kindling=/obj/items/Kindling/ueikkindling
		Handle=/obj/items/Crafting/Created/Handle
		MinHand=4
		MaxHand=8
		HandleAmount=1
		HandType="Ueik"
		pole = /obj/items/Crafting/Created/Pole
		MinPole=1
		MaxPole=3
		PoleAmount=1
		PoleType="Ueik"
		WTH=/obj/items/Crafting/Created/WoodenTorchHead
		MinHead=4
		MaxHead=9
		HeadAmount=1
		HeadType="Ueik"
		Chance=85
		GivenXP=5
		Creq=1
		New()
			..()
			KindAmount=rand(MinKind,MaxKind)	//This makes it so we can make a Minimum log amount and a max log amount
			HandleAmount=rand(MinHand,MaxHand)
			PoleAmount=rand(MinPole,MaxPole)
			HeadAmount=rand(MinHead,MaxHead)
			BoardAmount=rand(MinBoard,MaxBoard)
			//stack()
	verb
		Create_Fire()
			set waitfor = 0
			set category=null
			set popup_menu=1
			var/mob/players/M = usr
			var/obj/items/Logs/UeikLog/J
			//if(M.char_class!="Builder"&&"GM")
			//	M<<"You need to be a Builder to carve kindling."
			//	return
			/*if(M.char_class!="Builder"&&M in view(1))
				if(M.CKequipped==1)		//Makes sure the person is right beside the tree and facing it.
					if(Carving==1)		//This is saying if usr is already cuttin a tree...
						return
					if(stamina==0)		//Is your stamina to low???
						M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
						return
					for(J in M.contents)
						carve()		//Calls the Cut() proc
						sleep(5)
					..()*/
			//if(M.char_class=="Builder")
			if(M.CKequipped==1)		//Makes sure the person is right beside the tree and facing it.
				if(Carving==1)		//This is saying if usr is already cuttin a tree...
					return
				if(stamina==0)		//Is your stamina to low???
					M<<"<font color=#00bfff>You're too tired to do anything!</font>"
					return
				for(J in M.contents)
					if(J.stack_amount>=1)
							//J.RemoveFromStack(1)
						createfire()		//Calls the Cut() proc
						sleep(5)
						return
				//..()
		Carve()
			set waitfor = 0
			set category=null
			set popup_menu=1
			var/mob/players/M = usr
			var/obj/items/Logs/UeikLog/J
			//if(M.char_class!="Builder"&&"GM")
			//	M<<"You need to be a Builder to carve kindling."
			//	return
			/*if(M.char_class!="Builder"&&M in view(1))
				if(M.CKequipped==1)		//Makes sure the person is right beside the tree and facing it.
					if(Carving==1)		//This is saying if usr is already cuttin a tree...
						return
					if(stamina==0)		//Is your stamina to low???
						M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
						return
					for(J in M.contents)
						carve()		//Calls the Cut() proc
						sleep(5)
					..()*/
			//if(M.char_class=="Builder")
			if(M.CKequipped==1)		//Makes sure the person is right beside the tree and facing it.
				if(Carving==1)		//This is saying if usr is already cuttin a tree...
					return
				if(stamina==0)		//Is your stamina to low???
					M<<"<font color=#00bfff>You're too tired to do anything!</font>"
					return
				for(J in M.contents)
					if(J.stack_amount>=1)
							//J.RemoveFromStack(1)
						carve()		//Calls the Cut() proc
						sleep(5)
						return
				//..()
		Carve_Handle()
			set waitfor = 0
			set category=null
			set popup_menu=1
			var/mob/players/M = usr
			var/obj/items/Logs/UeikLog/J
			/*if(M.char_class=="Builder")
				M<<"You need to be a Builder to carve handles."
				return*/
			if(M.CKequipped==1)		//Makes sure the person is right beside the tree and facing it.
				if(Carving==1)		//This is saying if usr is already cuttin a tree...
					return
				if(M.stamina==0)		//Is your stamina to low???
					M<<"<font color=#00bfff>You're too tired to do anything!</font>"
					return
				for(J in M.contents)
					if(J.stack_amount>=1)
						//J.RemoveFromStack(1)
						carveH()		//Calls the Cut() proc
						sleep(5)
						return
				//..()
		Carve_Pole()
			set waitfor = 0
			set category=null
			set popup_menu=1
			var/mob/players/M = usr
			var/obj/items/Logs/UeikLog/J
			/*if(M.char_class=="Builder")
				M<<"You need to be a Builder to carve a pole."
				return*/
			if(M.CKequipped==1)		//Makes sure the person is right beside the tree and facing it.
				if(Carving==1)		//This is saying if usr is already cuttin a tree...
					return
				if(stamina==0)		//Is your stamina to low???
					M<<"<font color=#00bfff>You're too tired to do anything!</font>"
					return
				for(J in M.contents)
					if(J.stack_amount>=1)
						//J.RemoveFromStack(1)
						carveP()		//Calls the Cut() proc
						sleep(5)
						return
				//..()
		Carve_Wooden_Torch_Head()
			set waitfor = 0
			set category=null
			set popup_menu=1
			var/mob/players/M = usr
			var/obj/items/Logs/UeikLog/J
			/*if(M.char_class=="Builder")
				M<<"You need to be a Builder to carve a Wooden Torch Head."
				return*/
			if(M.CKequipped==1)		//Makes sure the person is right beside the tree and facing it.
				if(Carving==1)		//This is saying if usr is already cuttin a tree...
					return
				if(stamina==0)		//Is your stamina to low???
					M<<"<font color=#00bfff>You're too tired to do anything!</font>"
					return
				for(J in M.contents)
					if(J.stack_amount>=1)
						//J.RemoveFromStack(1)
						carveWTH()		//Calls the Cut() proc
						sleep(5)
						return
				//..()
		Saw_Board()
			set waitfor = 0
			set category=null
			set popup_menu=1
			var/mob/players/M = usr
			var/obj/items/Logs/UeikLog/J
			/*if(M.char_class=="Builder")
				M<<"You need to be a Builder to carve a pole."
				return*/
			if(M.SWequipped==1)		//Makes sure the person is right beside the tree and facing it.
				if(Carving==1)		//This is saying if usr is already cuttin a tree...
					return
				if(stamina==0)		//Is your stamina to low???
					M<<"<font color=#00bfff>You're too tired to do anything!</font>"
					return
				for(J in M.contents)
					if(J.stack_amount>=1)
						//J.RemoveFromStack(1)
						sawB()		//Calls the Cut() proc
						sleep(5)
						return
				//..()
	//Kindling
	//	ueikkindling
	//		icon = 'dmi/64/tree.dmi'
	//		icon_state = "kind1"    //This is basically saying what log will be made when tree is cut...
	proc/createfire(mob/Carver)
		set waitfor = 0
		set category=null
		set popup_menu=1
		var/mob/players/M
		var/obj/items/Logs/UeikLog/J
		var/Fire//=/obj/Fire
		M = usr		//Makes the usr become Cutter... Not really neccesary.
		if(M.Crank<Creq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
			M<<"<FONT COLOR=RED>You must have a Carving Acuity of at least [Creq] to create a fire.</FONT>"
			return
		/*if(KindAmount==0)		//Does the tree have logs???
			M<<"It's not worthwhile."
			return	*/			//If no... Return!
		if(M.CKequipped==0)			//Does the usr have a Axe to cut with?
			M<<"<font color=#00bfff>You need a Carving Knife equipped.</font>"
			return
		M<<"You begin to assemble a fire."			//YAY YOU're CUTTING!!!
		if(M.stamina==0)			//Calling this again... Some screwy stuff could happen.
			M<<"<font color=#00bfff>You are too tired, drink some water.</font>"
			return
		if(Carving==1)
			return
		Carving=1//Setting this to one because the usr is cutting a tree now.
		sleep(5)				//Sleeps about 2.5 seconds...
		if(KindAmount==0)		//If log amount being called again...
			M<<"You already carved the log."
			Carver=0
			return
		else
			if(M.CKequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
				M<<"<font color=#00bfff>You need to use a Carving Knife.</font>"
				return
			/*if (M.stamina < 5)
				M << "Low stamina."*/
			else
				//if(J.stack_amount>=1)// J.RemoveFromStack(1)
				M.stamina -= 5	//Depletes one stamina
				if(prob(Chance+M.Crank))		//Takes the rarity of the tree and your woodcutting lvl
					M<<"<font color=green>You create a fire in front of you!</font>"		//You get "tree being cut" Logs!
					Fire = new/obj/Buildable/Fire(usr.loc)
					Fire:buildingowner = "[ckeyEx("usr.key")]"
					//new Fire(usr.loc)
					//Fire:buildingowner = "[M.key]"
					//J.RemoveFromStack(1)//update()			//Remember log=obj/items/Logs/Oak???  Heres where this creates a log into invetory
					M.UpdateRankExp(RANK_CARVING, GivenXP)				//  Add The exp from tree to you.
					Carving=0							// Cutting is set to 0 so you are free to move and cut some more.
					//KindAmount--							//Depletes one log from the Amount.
					//if(KindAmount<=0)
					for(J in M.contents)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
						J.RemoveFromStack(1)//del(src)
						return
							//KindAmount=rand(MinKind,MaxKind)
				else
					M<<"You missed the log!"		//You wernt lucky enough to hit the treee.
					Carving=0
					return
	proc/carve(mob/Carver)
		set waitfor = 0
		set category=null
		set popup_menu=1
		var/mob/players/M
		var/obj/items/Logs/UeikLog/J
		M = usr		//Makes the usr become Cutter... Not really neccesary.
		if(M.Crank<Creq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
			M<<"<FONT COLOR=RED>You must have a Carving Acuity of at least [Creq] to carve [KindType] kindling.</FONT>"
			return
		/*if(KindAmount==0)		//Does the tree have logs???
			M<<"It's not worthwhile."
			return	*/			//If no... Return!
		if(M.CKequipped==0)			//Does the usr have a Axe to cut with?
			M<<"<font color=#00bfff>You need a Carving Knife equipped.</font>"
			return
		M<<"Carving"			//YAY YOU're CUTTING!!!
		if(M.stamina==0)			//Calling this again... Some screwy stuff could happen.
			M<<"<font color=#00bfff>You are too tired, drink some water.</font>"
			return
		if(Carving==1)
			return
		Carving=1				//Setting this to one because the usr is cutting a tree now.
		sleep(5)				//Sleeps about 2.5 seconds...
		if(KindAmount==0)		//If log amount being called again...
			M<<"You already carved the log."
			Carver=0
			return
		else
			if(M.CKequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
				M<<"<font color=#00bfff>You need to use a Carving Knife.</font>"
				return
			/*if (M.stamina < 5)
				M << "Low stamina."*/
			else
				//if(J.stack_amount>=1)// J.RemoveFromStack(1)
				M.stamina -= 5	//Depletes one stamina
				if(prob(Chance+M.Crank))		//Takes the rarity of the tree and your woodcutting lvl
					M<<"<font color=green>You create a [KindType] kindling infront of you!</font>"		//You get "tree being cut" Logs!
					new kindling(usr.loc)
					//J.RemoveFromStack(1)//update()			//Remember log=obj/items/Logs/Oak???  Heres where this creates a log into invetory
					M.UpdateRankExp(RANK_CARVING, GivenXP)//  Add The exp from tree to you.`r`n
					//Calls the WCLvl() Proc to see if person got lvl...
					Carving=0							// Cutting is set to 0 so you are free to move and cut some more.
					KindAmount--							//Depletes one log from the Amount.
					if(KindAmount<=0)
						for(J in M.contents)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
							J.RemoveFromStack(1)//del(src)
							//KindAmount=rand(MinKind,MaxKind)
							return
				else
					M<<"You missed the log!"		//You wernt lucky enough to hit the treee.
					Carving=0
					return
	proc/carveH(mob/Carver)
		set waitfor = 0
		set category=null
		set popup_menu=1
		var/mob/players/M
		var/obj/items/Logs/UeikLog/J
		M = usr		//Makes the usr become Cutter... Not really neccesary.
		if(M.Crank<Creq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
			M<<"<FONT COLOR=RED>You must have a crank lvl of at least [Creq] to carve [HandType] Handles.</FONT>"
			return
		/*if(HandleAmount==0)		//Does the tree have logs???
			M<<"It's not worthwhile."
			return	*/			//If no... Return!
		if(M.CKequipped==0)			//Does the usr have a Axe to cut with?
			M<<"<font color=#00bfff>You need a Carving Knife equipped.</font>"
			return
		M<<"Carving"			//YAY YOU're CUTTING!!!
		if(M.stamina==0)			//Calling this again... Some screwy stuff could happen.
			M<<"<font color=#00bfff>You are too tired, drink some water.</font>"
			return
		if(Carving==1)
			return
		Carving=1				//Setting this to one because the usr is cutting a tree now.
		sleep(5)				//Sleeps about 2.5 seconds...
		if(HandleAmount==0)		//If log amount being called again...
			M<<"You've already carved the log."
			Carver=0
			return
		else
			if(M.CKequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
				M<<"<font color=#00bfff>You need to use a Carving Knife.</font>"
				return
			/*if (M.stamina < 5)
				M << "Low stamina."*/
			else
				M.stamina -= 5	//Depletes one stamina
				if(prob(Chance+M.Crank))		//Takes the rarity of the tree and your woodcutting lvl
					//var/obj/items/Crafting/Created/Handle
					M<<"<font color=green>You create a [HandType] handle infront of you!</font>"		//You get "tree being cut" Logs!
					//Handle += M.contents
					new Handle(usr)
					//update()			//Remember log=obj/items/Logs/Oak???  Heres where this creates a log into invetory
					M.UpdateRankExp(RANK_CARVING, GivenXP)//  Add The exp from tree to you.`r`n
					//Calls the WCLvl() Proc to see if person got lvl...
					Carving=0							// Cutting is set to 0 so you are free to move and cut some more.
					HandleAmount--							//Depletes one log from the Amount.
					if(HandleAmount<=0)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
						for(J in M.contents)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
							J.RemoveFromStack(1)//del(src)
							//HandleAmount=rand(MinHand,MaxHand)
							return
				else
					M<<"You missed the log!"		//You wernt lucky enough to hit the treee.
					Carving=0
					return
	proc/sawB(mob/Carver)
		set waitfor = 0
		set category=null
		set popup_menu=1
		var/mob/players/M
		var/obj/items/Logs/UeikLog/J
		M = usr		//Makes the usr become Cutter... Not really neccesary.
		if(M.Crank<Creq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
			M<<"<FONT COLOR=RED>You must have a Carving Acuity of at least [Creq] to carve [BoardType] Boards.</FONT>"
			return
		if(BoardAmount==0)		//Does the tree have logs???
			M<<"You have cut as many boards as you can out of this piece."
			return				//If no... Return!
		if(M.SWequipped==0)			//Does the usr have a Axe to cut with?
			M<<"<font color=#00bfff>You need a Saw equipped.</font>"
			return
		M<<"Sawing"			//YAY YOU're CUTTING!!!
		if(M.stamina==0)			//Calling this again... Some screwy stuff could happen.
			M<<"<font color=#00bfff>You are too tired, drink some water.</font>"
			return
		if(Carving==1)
			return
		Carving=1				//Setting this to one because the usr is cutting a tree now.
		sleep(5)				//Sleeps about 2.5 seconds...
		if(BoardAmount==0)		//If log amount being called again...
			M<<"You already carved the log."
			Carver=0
			return
		else
			if(M.SWequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
				M<<"<font color=#00bfff>You need to use a Saw.</font>"
				return
			/*if (M.stamina < 5)
				M << "Low stamina."*/
			else
				M.stamina -= 5	//Depletes one stamina
				if(prob(Chance+M.Crank))		//Takes the rarity of the tree and your woodcutting lvl
					M<<"<font color=green>You create a [BoardType] board infront of you!</font>"		//You get "tree being cut" Logs!
					new board(usr)
					//update()			//Remember log=obj/items/Logs/Oak???  Heres where this creates a log into invetory
					M.UpdateRankExp(RANK_CARVING, GivenXP)//  Add The exp from tree to you.`r`n
					//Calls the WCLvl() Proc to see if person got lvl...
					Carving=0							// Cutting is set to 0 so you are free to move and cut some more.
					BoardAmount--							//Depletes one log from the Amount.
					if(BoardAmount<=0)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
						for(J in M.contents)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
							J.RemoveFromStack(1)//del(src)
							//BoardAmount=rand(MinPole,MaxPole)
							return
				else
					M<<"You missed the log!"		//You wernt lucky enough to hit the treee.
					Carving=0
					return
	proc/carveP(mob/Carver)
		set waitfor = 0
		set category=null
		set popup_menu=1
		var/mob/players/M
		var/obj/items/Logs/UeikLog/J
		M = usr		//Makes the usr become Cutter... Not really neccesary.
		if(M.Crank<Creq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
			M<<"<FONT COLOR=RED>You must have a Carving Acuity of at least [Creq] to carve [PoleType] Poles.</FONT>"
			return
		if(PoleAmount==0)		//Does the tree have logs???
			M<<"You have cut as many poles as you can out of this material."
			return				//If no... Return!
		if(M.CKequipped==0)			//Does the usr have a Axe to cut with?
			M<<"<font color=#00bfff>You need a Carving Knife equipped.</font>"
			return
		M<<"Carving"			//YAY YOU're CUTTING!!!
		if(M.stamina==0)			//Calling this again... Some screwy stuff could happen.
			M<<"<font color=#00bfff>You are too tired, drink some water.</font>"
			return
		if(Carving==1)
			return
		Carving=1				//Setting this to one because the usr is cutting a tree now.
		sleep(5)				//Sleeps about 2.5 seconds...
		if(PoleAmount==0)		//If log amount being called again...
			M<<"You already carved the log."
			Carver=0
			return
		else
			if(M.CKequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
				M<<"<font color=#00bfff>You need to use a Carving Knife.</font>"
				return
			/*if (M.stamina < 5)
				M << "Low stamina."*/
			else
				M.stamina -= 5	//Depletes one stamina
				if(prob(Chance+M.Crank))		//Takes the rarity of the tree and your woodcutting lvl
					M<<"<font color=green>You create a [PoleType] pole infront of you!</font>"		//You get "tree being cut" Logs!
					new pole(usr)
					//update()			//Remember log=obj/items/Logs/Oak???  Heres where this creates a log into invetory
					M.UpdateRankExp(RANK_CARVING, GivenXP)//  Add The exp from tree to you.`r`n
					//Calls the WCLvl() Proc to see if person got lvl...
					Carving=0							// Cutting is set to 0 so you are free to move and cut some more.
					PoleAmount--							//Depletes one log from the Amount.
					if(PoleAmount<=0)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
						for(J in M.contents)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
							J.RemoveFromStack(1)//del(src)
							//PoleAmount=rand(MinPole,MaxPole)
							return
				else
					M<<"You missed the log!"		//You wernt lucky enough to hit the treee.
					Carving=0
					return
	proc/carveWTH(mob/Carver)
		set waitfor = 0
		set category=null
		set popup_menu=1
		var/mob/players/M
		var/obj/items/Logs/UeikLog/J
		M = usr		//Makes the usr become Cutter... Not really neccesary.
		if(M.Crank<Creq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
			M<<"<FONT COLOR=RED>You must have a Carving Acuity of at least [Creq] to carve [HeadType] Wooden Torch Head.</FONT>"
			return
		if(HeadAmount==0)		//Does the tree have logs???
			M<<"This material is not viable enough to provide any more handles."
			return				//If no... Return!
		if(M.CKequipped==0)			//Does the usr have a Axe to cut with?
			M<<"<font color=#00bfff>You need a Carving Knife equipped.</font>"
			return
		M<<"Carving"			//YAY YOU're CUTTING!!!
		if(M.stamina==0)			//Calling this again... Some screwy stuff could happen.
			M<<"<font color=#00bfff>You are too tired, drink some water.</font>"
			return
		if(Carving==1)
			return
		Carving=1				//Setting this to one because the usr is cutting a tree now.
		sleep(5)				//Sleeps about 2.5 seconds...
		if(HeadAmount==0)		//If log amount being called again...
			M<<"You already carved the log."
			Carver=0
			return
		else
			if(M.CKequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
				M<<"<font color=#00bfff>You need to use a Carving Knife.</font>"
				return
			/*if (M.stamina < 5)
				M << "Low stamina."*/
			else
				M.stamina -= 5	//Depletes one stamina
				if(prob(Chance+M.Crank))		//Takes the rarity of the tree and your woodcutting lvl
					M<<"<font color=green>You create a [HeadType] Wooden Torch Head infront of you!</font>"		//You get "tree being cut" Logs!
					new WTH(usr)
					//update()			//Remember log=obj/items/Logs/Oak???  Heres where this creates a log into invetory
					M.UpdateRankExp(RANK_CARVING, GivenXP)//  Add The exp from tree to you.`r`n
					//Calls the WCLvl() Proc to see if person got lvl...
					Carving=0							// Cutting is set to 0 so you are free to move and cut some more.
					HeadAmount--							//Depletes one log from the Amount.
					if(HeadAmount<=0)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
						for(J in M.contents)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
							J.RemoveFromStack(1)//del(src)
							//HeadAmount=rand(MinHead,MaxHead)
							return
				else
					M<<"You missed the log!"		//You wernt lucky enough to hit the treee.
					Carving=0
					return

