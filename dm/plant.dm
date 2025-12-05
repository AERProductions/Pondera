var
	grank=1			//grank lvl gardening rank
	grankEXP=0		//grank Exp
	grankMAXEXP=10		//Exp till level				//stamina
	MAXgrankLVL=0	//Maxgranklvl when set to one it stops more lvls...
	//bgrowstate
	gardening[1]
	G
	G0[]
	G1[]
	G2[]
	G3[]
	G4[]
	G5[]
	bushlist[0]
mob/var
	tmp
		Picking=0			//Defines cutting.
obj
	items
		Fruit
			can_stack = TRUE
			food = 1
			layer = 11
			/*verb
				Get()
					set category=null
					set popup_menu = 1
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
								else if(o.type==/obj/items/questitem)
									M << "You don't need that"
							if(C==0)
								src.Move(usr)
						else
							M << "You don't need that"
					else
						var/obj/O = src
						set src in oview(1)
						for(O as obj in view(3)) // only people you can SEE
							if(istype(O,/obj))
								src.Move(usr)
								src.stack()
					//else
					//	src.Move(usr)
				Drop()
					set category=null
					set popup_menu=1
					set src in usr
					if(src.suffix == "Equipped")
						usr << "Un-equip [src] first!"
					else
						src.Move(usr.loc)*/
			//food = 1


			Raspberry
				icon='dmi/64/plants.dmi'
				icon_state="rb"
				name = "Raspberry"
				Worth = 7
				food = 1
				////var/stack = 1
				//description = "<b>Raspberry</b>  Restores 10 Health"
				verb/Use()
					set popup_menu = 1
					//set category = "Commands"
					set src in usr
					heal(src,10)
					//src.stack -= 1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Raspberry:</b>  A ripe ruby colored berry; Restores 10 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
			Blueberry
				icon='dmi/64/plants.dmi'
				icon_state="bb"
				name = "Blueberry"
				Worth = 14
				food = 1
				////var/stack = 1
				//description = "<b>Blueberry</b>  A ripe sapphire colored berry; Restores 10 stamina"
				verb/Use()
					set popup_menu = 1
					//set category = "Commands"
					set src in usr
					mana(src,10)
					//src.stack -= 1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Blueberry:</b>  A ripe sapphire colored berry; Restores 10 stamina."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
			proc/heal(var/obj/items/Fruit/J,amount)
				var/mob/players/M
				M = usr
				if (amount > (M.MAXHP-M.HP))
					amount = (M.MAXHP-M.HP)
				M.HP += amount
				M.updateHP()
				M << "You used a [J]; <b>[amount] Health recovered."
				Del(src)
			proc/mana(var/obj/items/Fruit/J,amount)
				var/mob/players/M
				M = usr
				if (amount > (M.MAXstamina-M.stamina))
					amount = (M.MAXstamina-M.stamina)
				M.stamina += amount
				M.updateST()
				M << "You used a [J]; <b>[amount] stamina recovered."
				Del(src)


			RaspberryCluster
				icon='dmi/64/plants.dmi'
				icon_state="rbc"
				name = "Raspberry Cluster"
				Worth = 7
				food = 1
				////var/stack = 1
				//description = "<b>Raspberry Cluster</b>  Restores 100 Health"
				verb/Use()
					set popup_menu = 1
					//set category = "Commands"
					set src in usr
					cheal(src,100)
					//src.stack -= 1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Raspberry Cluster:</b>  A cluster of ripe ruby colored berries; Restores 100 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
			BlueberryCluster
				icon='dmi/64/plants.dmi'
				icon_state="bbc"
				name = "Blueberry Cluster"
				Worth = 14
				food = 1
				////var/stack = 1
				//description = "<b>Blueberry Cluster</b>  A cluster of ripe sapphire colored berries; Restores 100 stamina"
				verb/Use()
					set popup_menu = 1
					//set category = "Commands"
					set src in usr
					cmana(src,100)
					//src.stack -= 1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Blueberry Cluster:</b>  A cluster of ripe sapphire colored berries; Restores 100 stamina."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
			proc/cheal(var/obj/items/Fruit/J,amount)
				var/mob/players/M
				M = usr
				if (amount > (M.MAXHP-M.HP))
					amount = (M.MAXHP-M.HP)
				M.HP += amount
				M.updateHP()
				M << "You used a [J]; <b>[amount] Health recovered."
				Del(src)
			proc/cmana(var/obj/items/Fruit/J,amount)
				var/mob/players/M
				M = usr
				if (amount > (M.MAXstamina-M.stamina))
					amount = (M.MAXstamina-M.stamina)
				M.stamina += amount
				M.updateST()
				M << "You used a [J]; <b>[amount] stamina recovered."
				Del(src)

		Vegetables
			layer = 11
			can_stack = TRUE
			food = 1
			Potato
				icon='dmi/64/vpotato.dmi'
				icon_state="potato"
				name = "Potato"
				Worth = 14
				food = 1
				description = "<b>Potato</b>  A golden brown Potato; Restores 10 Health"
				verb/Use()
					set popup_menu = 1
					//set category = "Commands"
					set src in usr
					heal2(src,10)
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Potato:</b>  A golden brown Potato; Restores 10 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return

			Onion
				icon='dmi/64/vonion.dmi'
				icon_state="onion"
				name = "Onion"
				Worth = 14
				food = 1
				description = "<b>Onion</b>  A crisp stalk of Onion; Restores 10 Health"
				verb/Use()
					set popup_menu = 1
					//set category = "Commands"
					set src in usr
					heal2(src,10)
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Onion:</b>  A crisp stalk of Onion; Restores 10 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
			Carrot
				icon='dmi/64/vcarrots.dmi'
				icon_state="carrot"
				name = "Carrot"
				Worth = 14
				food = 1
				description = "<b>Carrot</b>  A dense Carrot; Restores 10 Health"
				verb/Use()
					set popup_menu = 1
					//set category = "Commands"
					set src in usr
					heal2(src,10)
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Carrot:</b>  A dense Carrot; Restores 10 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
			Tomato
				icon='dmi/64/ftomato.dmi'
				icon_state="tomato"
				name = "Tomato"
				Worth = 14
				food = 1
				description = "<b>Tomato</b>  A juicy red Tomato; Restores 10 Health"
				verb/Use()
					set popup_menu = 1
					//set category = "Commands"
					set src in usr
					heal2(src,10)
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Tomato:</b>  A dense Tomato; Restores 10 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
			Pumpkin
				icon='dmi/64/vpumpkin.dmi'
				icon_state="pumpkin"
				name = "Pumpkin"
				Worth = 14
				food = 1
				description = "<b>Pumpkin</b>  A large Pumpkin; Restores 10 Health"
				verb/Use()
					set popup_menu = 1
					//set category = "Commands"
					set src in usr
					heal2(src,10)
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Pumpkin:</b>  A large Pumpkin; Restores 10 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
		proc/heal2(var/obj/items/Vegetables/J,amount)
			var/mob/players/M
			M = usr
			if (amount > (M.MAXHP-M.HP))
				amount = (M.MAXHP-M.HP)
			M.HP += amount
			M.updateHP()
			M << "You used a [J]; <b>[amount] Health recovered."
			Del(src)

		Grain
			can_stack = TRUE
			food = 1
			layer = 11
			Wheat
				icon='dmi/64/gwheat.dmi'
				icon_state="wheat"
				name = "Wheat"
				Worth = 14
				food = 1
				description = "<b>Wheat</b>  A sheave of Wheat."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Blueberry:</b>  A sheave of Wheat; For grinding or animal consumption."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
			Barley
				icon='dmi/64/gbarley.dmi'
				icon_state="barley"
				name = "Barley"
				Worth = 14
				food = 1
				description = "<b>Barley</b>  A sheave of Barley."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Barley:</b>  A sheave of Barley; For animal consumption."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return

		Seeds
			icon = 'dmi/64/plants.dmi'
			icon_state = "seeds"
			layer = 10
			var/greq
			var/gxpg
			var/Sown
			food = 1
			can_stack = TRUE
			var/obj/Plants/plantbs
			/*verb
				Get()
					set category=null
					set popup_menu = 1
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
								else if(o.type==/obj/items/questitem)
									M << "You don't need that"
							if(C==0)
								src.Move(usr)
						else
							M << "You don't need that"
					else
						var/obj/O = src
						set src in oview(1)
						for(O as obj in view(3)) // only people you can SEE
							if(istype(O,/obj))
								src.Move(usr)
								src.stack()
					//else
					//	src.Move(usr)
				Drop()
					set category=null
					set popup_menu=1
					set src in usr
					if(src.suffix == "Equipped")
						usr << "Un-equip [src] first!"
					else
						src.Move(usr.loc)*/
			Potatoseed
				//icon='dmi/64/vpotato.dmi'
				//icon_state="pts"
				name = "Potato Seed"
				description = "<b>Potato Seed</b>  Plant using a Hoe and Soil to grow Potato."
				density = 0
				food = 1
				greq = 1
				gxpg = 5
				plantbs=/obj/Plants/Vegetables/Potato
			Onionseed
				//icon='dmi/64/vonion.dmi'
				//icon_state="ons"
				name = "Onion Seed"
				description = "<b>Onion Seed</b>  Plant using a Hoe and Soil to grow Onion."
				density = 0
				food = 1
				greq = 2
				gxpg = 10
				plantbs=/obj/Plants/Vegetables/Onion
			Wheatseed
				//icon='dmi/64/gwheat.dmi'
				//icon_state="wts"
				name = "Wheat Seed"
				description = "<b>Wheat Seed</b>  Plant using a Hoe and Soil to grow Wheat."
				density = 0
				food = 1
				greq = 4
				gxpg = 30
				plantbs=/obj/Plants/Grain/Wheat
			Carrotseed
				//icon='dmi/64/vcarrots.dmi'
				//icon_state="crts"
				name = "Carrot Seed"
				description = "<b>Carrot Seed</b>  Plant using a Hoe and Soil to grow Carrot."
				density = 0
				food = 1
				greq = 3
				gxpg = 15
				plantbs=/obj/Plants/Vegetables/Carrot
			Tomatoseed
				name = "Tomato Seed"
				description = "<b>Tomato Seed</b>  Plant using a Hoe and Soil to grow Tomato."
				density = 0
				food = 1
				greq = 4
				gxpg = 20
				plantbs=/obj/Plants/Vegetables/Tomato
			Pumpkinseed
				//icon='dmi/64/vpumpkin.dmi'
				//icon_state="pkns"
				name = "Pumpkin Seed"
				description = "<b>Pumpkin Seed</b>  Plant using a Hoe and Soil to grow Pumpkin."
				density = 0
				food = 1
				greq = 5
				gxpg = 25
				plantbs=/obj/Plants/Vegetables/Pumpkin
			Barleyseed
				//icon='dmi/64/gbarley.dmi'
				//icon_state="bys"
				name = "Barley Seed"
				greq = 5
				description = "<b>Barley Seed</b>  Plant using a Hoe and Soil to grow Barley."
				density = 0
				food = 1
				gxpg = 35
				plantbs=/obj/Plants/Grain/Barley




			Raspberryseed
				icon='dmi/64/plants.dmi'
				icon_state="rbs"
				name = "Raspberry Seed"
				description = "<b>Raspberry Seed</b>  Plant using a Hoe and Soil to grow a Raspberry Bush."
				density = 0
				////var/stack = 1
				greq = 1
				gxpg = 5
				food = 1
				plantbs=/obj/Plants/Bush/Raspberrybush
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Raspberry seed:</b>  A ruby berry seed; Plant in soil."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
			Blueberryseed
				icon='dmi/64/plants.dmi'
				icon_state="bbs"
				name = "Blueberry Seed"
				description = "<b>Blueberry Seed</b>  Plant using a Hoe and Soil to grow a Blueberry Bush."
				density = 0
				greq = 1
				gxpg = 5
				////var/stack = 1
				food = 1
				plantbs=/obj/Plants/Bush/Blueberrybush
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Blueberry seed:</b>  A sapphire berry seed; Plant in soil.."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return



mob/players/proc
	GNLvl()
		if(grank>=5)				//Seeing if usr is maxlvl
			MAXgrankLVL=1
			grank=5
			grankMAXEXP = grankEXP					//grank Lvl Proc		for when you gain lvls.
		if(MAXgrankLVL==1)	//If your woodcutting lvl is max... Return, cant gain anymore lvls greedy bastard!
			return
		else					//Else!!!
			if(grankEXP>=grankMAXEXP)		//Does the usr have the req exp for the next lvl?/?
				grankMAXEXP+=exp2lvl(grank)	//If he did then here it adds the next MaxExp to his maxexp for the next lvl gain
				grank++							//grank lvl +1
				src<<"You gain \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hoe'>gardening Acuity!"

				GNLvl()			//Calls the WCLvl() proc again to see if the usr gained two lvls in on one tree or not...
				return



/*mob/players/Landscaper
	verb
		Plant()
			var/mob/players/M = usr
			var/turf/soil/S //change to soil
			var/seed=/obj/Seeds/Raspberryseed
			var/obj/Seeds/Raspberryseed/F = locate() in M.contents //change to seed
			if(M.loc==S&&F in M.contents)
				F.RemoveFromStack(1)
				new seed(locate(x,y,z))
				M.stamina -= 3
				M.updateST()
			else if(M.stamina == 0)
				M<<"Low stamina."
				return*/

var/global/bgrowstage
var/global/vgrowstage
var/global/ggrowstage
obj
	Plants							//Simple right??? Just defining objects, Trees!
		//parent_type = /obj
		icon='dmi/64/plants.dmi'
		//var/bgrowstate//bgrowstate for bushes
		//density = 1
		layer = 9

		//icon_state="rbb"
		//New() FruitAmount=rand(MinFruit,MaxFruit)
		//New() SeedAmount=rand(MinSeed,MaxSeed)		//This makes it so we can make a Minimum log amount and a max log amount
		var										//So each tree doesn't always have the same amount of logs each time...										//So it's random between the set numbers..
			//list/Plants = list()
			obj/items/Vegetables/vegetable
			obj/items/Grain/grain
			obj/items/Fruit/fruit	//Defines the certain log thats going to be made.
			obj/items/Fruit/fruitc
			obj/items/Seeds/seed
			obj/Plants/plantb
			FruitAmount	//Logs in the trees...
			SeedAmount
			Rarity		//Basically how hard is it to hit the tree?
			MinFruit		//Minimum logs in tree
			MaxFruit		//Max logs that can be in tree
			MinSeed		//Minimum logs in tree
			MaxSeed
			GiveXP		//Exp tree gives!
			FruitType		//Log type, What log does the tree give...  Its really just for Text purposes.
			spawntime	//How long does it take for the tree to respawn???
			greq		//grank lvl required to chop tree down...
			bgrowstate
			vgrowstate
			ggrowstate
			VegeType
			VegeAmount
			MinVege
			MaxVege
			GrainType
			GrainAmount
			MinGrain
			MaxGrain

		New()
			..()
			bushlist+=src
		Del()
			bushlist-=src
			..()


		proc/Grow()
		proc/UpdatePlantPic()

//sickle will pick an entire cluster of berries (new item), but berries should be able to be picked one
//by one by hand -- So keep the proc the same for sickle, but add a new item (berry cluster) and
//account for hand picking when no tool is equipped, which provides one berry and no seeds.
//add hand picking to proc, create a new berry cluster item to replace single berry for sickle
//make hand picking get single berry | done!

		proc/Pick(mob/Picker)//pickfruit this probably needs fixed so sickle cuts sprouts and players can pick the fruit without one
			set waitfor = 0
			var/mob/players/M
			M = usr//Makes the usr become Picker... Not really neccesary.
			if(grank<greq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
				M<<"<FONT COLOR=RED>You must have a Gardening Acuity of at least [greq] to pick [FruitType] plant.</FONT>"
				return
			if(SeedAmount==0||FruitAmount==0)		//If log amount being called again...
				M<<"You already picked the [FruitType] plant."
				if(season!="Autumn")
					src.icon_state="picked1"
				else if(season=="Autumn")
					src.icon_state="autpicked"
				Picking=0
				return
			if(M.SKequipped==0)			//Does the usr have a Axe to cut with?
				goto pickone//Picker<<"You need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Sickle to harvest."
				//return
			else if(M.SKequipped==1)
				M<<"You begin to work on the [FruitType] plant with your Sickle."			//YAY YOU're CUTTING!!!
				M.overlays += image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
				if(M.stamina==0||M.stamina<12)			//Calling this again... Some screwy stuff could happen.
					M<<"Your stamina is too low."
					Picking = 0
					return
				if(Picking==1)
					return
				Picking=1				//Setting this to one because the usr is cutting a tree now.
				sleep(10)				//Sleeps about 2.5 seconds...
			//else
				if(M.SKequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
					Picker<<"You need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Sickle to use it on the [FruitType] plant."
					Picking = 0
					return
				if (M.stamina<12)
					M << "Need more stamina to harvest this plant."
					Picking = 0
					return
				else
					M.stamina -= 12	//Depletes one stamina
					M.updateST()
					if(prob(Rarity+grank))		//Takes the rarity of the tree and your woodcutting lvl

						Picker<<"You Finish working the [FruitType] plant and receive [FruitType]!"		//You get "tree being cut" Logs!
						M.overlays -= image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
						new fruitc(usr)			//Remember log=obj/items/Logs/Oak???  Heres where this creates a log into invetory
						new seed(usr)
						grankEXP+=GiveXP				//  Add The exp from tree to you.
						M.GNLvl()						//Calls the WCLvl() Proc to see if person got lvl...
						Picking=0							// Picking is set to 0 so you are free to move and cut some more.
						FruitAmount--
						SeedAmount--							//Depletes one log from the Amount.
						if(FruitAmount==0||SeedAmount==0)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
							Picking = 0
							if(season!="Autumn")
								src.icon_state="picked1"
							else if(season=="Autumn")
								src.icon_state="autpicked"
							M << "Plant has been harvested."
							//src.icon_state="picked"
							//sleep(src.spawntime)		//Waiting the spawntime you set for your trees
							//src.icon_state= initial(icon_state)		//Makes your trees come back to live
							//src.FruitAmount=rand(MinFruit,MaxFruit)			//Redefines new FruitAmounts.
							//src.SeedAmount=rand(MinSeed,MaxSeed)
							//del src
							return
					else
						M.overlays -= image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
						Picker<<"You missed the [FruitType] plant."
						sleep(10)		//You wernt lucky enough to hit the treee.
						Picking=0
						return
			pickone
			if(M.SKequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
				//Picker<<"You need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Sickle to use it on the [FruitType] plant."
				//Picking = 0
				//return
				if(M.stamina==0||M.stamina<3)			//Calling this again... Some screwy stuff could happen.
					M<<"Your stamina is too low."
					Picking = 0
					return
				if(Picking==1)
					return
				Picking=1				//Setting this to one because the usr is cutting a tree now.
				sleep(10)				//Sleeps about 2.5 seconds...
			//else
				if (M.stamina<3)
					M << "Need more stamina to harvest this plant."
					Picking = 0
					return
				else
					M.stamina -= 3	//Depletes one stamina
					M.updateST()
					if(prob(Rarity+grank))		//Takes the rarity of the tree and your woodcutting lvl

						Picker<<"You pick a [FruitType] from the [FruitType] plant!"		//You get "tree being cut" Logs!
						//M.overlays -= image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
						new fruit(usr)			//Remember log=obj/items/Logs/Oak???  Heres where this creates a log into invetory
						//new seed(usr)
						grankEXP+=GiveXP				//  Add The exp from tree to you.
						M.GNLvl()						//Calls the WCLvl() Proc to see if person got lvl...
						Picking=0							// Picking is set to 0 so you are free to move and cut some more.
						FruitAmount--
						//SeedAmount--							//Depletes one log from the Amount.
						if(FruitAmount==0)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
							Picking = 0
							if(season!="Autumn")
								src.icon_state="picked1"
							else if(season=="Autumn")
								src.icon_state="autpicked"
							M << "Plant has been picked clean."
							//src.icon_state="picked"
							//sleep(src.spawntime)		//Waiting the spawntime you set for your trees
							//src.icon_state= initial(icon_state)		//Makes your trees come back to live
							//src.FruitAmount=rand(MinFruit,MaxFruit)			//Redefines new FruitAmounts.
							//src.SeedAmount=rand(MinSeed,MaxSeed)
							//del src
							return
					else
						M.overlays -= image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
						Picker<<"You missed the [FruitType] plant."
						sleep(10)		//You wernt lucky enough to hit the treee.
						Picking=0
						return

	/*Plants
		parent_type = /obj
		var/bgrowstate//bgrowstate for bushes
		density = 1
		plane = 3*/



		Vegetables
			//vgrowstate = 1
			New()
				..()

				if(month == "Shevat"&&src.vgrowstate==1)
					Grow()
				if(src.VegeAmount==null)
					src.VegeAmount = rand(src.MinVege, src.MaxVege)
				if(!SeedAmount)
					src.SeedAmount = rand(src.MinSeed, src.MaxSeed)
			DblClick()		//vegetable click
				set waitfor = 0
				var/mob/players/M = usr
				if(get_dist(src,M)>=2&&get_dir(src,M)<=M.dir)
				//if(!(src in range(2, usr)))
				//if(get_step_away(src,usr,3))
					M<<"You need to be closer to cut."
					return
				else
					if(M.SKequipped==0)//Does the usr have a Axe to cut with?
						M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Sickle equipped."
						return
					else
						if(M.SKequipped==1)//Makes sure the person is right beside the tree and facing it.
							if(Picking==1)//This is saying if usr is already cuttin a tree...
								return
							if(stamina==0)//Is your stamina to low???
								M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
								return
							if((src.vgrowstate==4)||(src.vgrowstate==5))
								PickV(M)//Calls the Pick() proc
								sleep(2)
							else
								if(src.vgrowstate==1)
									M<<"This [VegeType] Plant is just a seedling and too young to be viable to pick."
									return
								if(src.vgrowstate==2)
									M<<"This [VegeType] Plant is just a sappling and therefor isn't viable to pick."
									return
								if(src.vgrowstate==3)
									M<<"This [VegeType] Plant is barely blooming and isn't viable to pick."
									return
								//if(src.bgrowstate==5)
									//M<<"This [FruitType] Plant is too old and brittle to pick."
									//return
								if(src.vgrowstate==6)
									M<<"This [VegeType] Plant is too old and brittle to pick."
									return
								if(src.vgrowstate==7)
									M << "This [VegeType] has already been harvested."
									return
								if(src.vgrowstate==8)
									M << "This [VegeType] was planted out of season."
									return
			proc/PickV(mob/Picker)//vegetable proc
				set waitfor = 0
				var/mob/players/M
				M = usr//Makes the usr become Picker... Not really neccesary.
				if(grank<greq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
					M<<"<FONT COLOR=RED>You must have a Gardening Acuity of at least [greq] to pick [VegeType] plant.</FONT>"
					return
				if(VegeAmount==0)		//Does the tree have logs???
					M<<"It's not worthwhile."
					return
				if(SeedAmount==0)		//Does the tree have logs???
					M<<"It's not worthwhile."
					return				//If no... Return!
				if(M.SKequipped==0)			//Does the usr have a Axe to cut with?
					Picker<<"You need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Sickle to harvest."
					return
				M<<"You begin to work on the [VegeType] plant with your Sickle."			//YAY YOU're CUTTING!!!
				M.overlays += image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
				if(M.stamina==0)			//Calling this again... Some screwy stuff could happen.
					M<<"Your stamina is too low."
					return
				if(Picking==1)
					return
				Picking=1				//Setting this to one because the usr is cutting a tree now.
				sleep(10)				//Sleeps about 2.5 seconds...
				if(VegeAmount==0)		//If log amount being called again...
					M<<"You already picked the [VegeType] plant."
					Picking=0
					return
				if(SeedAmount==0)		//If log amount being called again...
					M<<"You already picked the [VegeType] plant."
					Picking=0
					return
				else
					if(M.SKequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
						Picker<<"You need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Sickle to use it on the [VegeType] plant."
						return
					if (M.stamina==0)
						M << "Low stamina."
					else
						M.stamina -= 3	//Depletes one stamina
						M.updateST()
						if(prob(Rarity+grank))		//Takes the rarity of the tree and your woodcutting lvl
							Picker<<"You Finish working the [VegeType] plant and receive [VegeType]!"		//You get "tree being cut" Logs!
							M.overlays -= image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
							src.icon_state="picked"
							src.vgrowstate = 7
							src.name = "Harvested"
							new vegetable(usr)			//Remember log=obj/items/Logs/Oak???  Heres where this creates a log into invetory
							new seed(usr)
							grankEXP+=GiveXP				//  Add The exp from tree to you.
							M.GNLvl()						//Calls the WCLvl() Proc to see if person got lvl...
							Picking=0							// Picking is set to 0 so you are free to move and cut some more.
							VegeAmount--
							SeedAmount--
													//Depletes one log from the Amount.
							if(VegeAmount==0)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
								//src.icon_state="picked"
								//sleep(src.spawntime)		//Waiting the spawntime you set for your trees
								//src.icon_state= initial(icon_state)		//Makes your trees come back to live
								//src.VegeAmount=rand(MinVege,MaxVege)			//Redefines new FruitAmounts.
								//src.SeedAmount=rand(MinSeed,MaxSeed)
								//del src
								return
						else
							M.overlays -= image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
							Picker<<"You missed the [VegeType] plant."
							sleep(10)		//You wernt lucky enough to hit the treee.
							Picking=0
							return
			Grow()//vegetable growth
				var/randomvalue = rand(240,840)
				spawn(randomvalue)
				//spawn(420) // 420 testing Normaly set to 12000, or twenty min.
				// Cycle the bgrowstate var.
					//if (bgrowstate == 1)
						// chopped down? It is now a stump, no more growth until I implement a random seed
						//src:bgrowstate = 1
						//return
	//				var/obj/Plants/Raspberrybush/R = locate(world)
	//				for(R in world)
					if(src.vgrowstate == 8||src.vgrowstate == 7)
						return
					if (month == "Shevat"&&day>=1||month == "Shevat"&&day<=9)//have to check the month after the || (or) call otherwise it just detects the day

						src:vgrowstate = 1//seed
						if(src.vgrowstate == 8)
							src:vgrowstate=1
					if (month == "Shevat"&&day>=10)

						src:vgrowstate = 2//sappling
						if(src.vgrowstate == 8)
							return
					if (month == "Adar"&&day>=1)

						src:vgrowstate = 3//bloom
						if(src.vgrowstate == 8)
							return
					if (month == "Nisan"&&day>=15)

						src:vgrowstate = 4//ripe
						if(src.vgrowstate == 8)
							return
					if (season == "Summer")

						src:vgrowstate = 4//ripe
						if(src.vgrowstate == 8)
							return

					if (season == "Autumn")

						src:vgrowstate = 5//ripe fall
						if(src.vgrowstate == 8)
							return
					if (season == "Winter")

						src:vgrowstate = 6//old winter
						if(src.vgrowstate == 8)
							return
					//vgrowstate+=1//comment out to remove growing out of season
					//if(vgrowstate>=6)//just a temporary check to make sure growstate doesn't go above the actual amount of stages that exist
						//vgrowstate = 1
					src.UpdatePlantPic()
				//..()
			UpdatePlantPic()//vegetable growth
			//growstates: 1 = Seedling 2=Sappling 3=Bloom 4=Ripe 5=Old
			// Update the bush pic as needed:
			//var/list/P = icon_states(icon)
	//			var/obj/Plants/Raspberrybush/R = locate(world)
				//if(bgrowstate != bstateload)
	//			for(R in world)
				//for(var/obj/Plants/Blueberrybush)
					//src:bgrowstate=bstateload

				//bgrowstate = bstateload
				if (src.vgrowstate == 7)
					src:icon_state = "picked"
					//src:bgrowstate = 1
					src:name = "Picked"//Harvested
					return
				if (src.vgrowstate == 8)
					src:icon_state = "seed"
					//src:bgrowstate = 1
					src:name = "OoS"//Out of Season
					return
				if (src.vgrowstate == 1)

					src:icon_state = "seed1"
					//src:bgrowstate = 1
					src:name = "Seedling"
					//growthstate = "Seedling"
				if (src.vgrowstate == 2)
					src:icon_state = "sapp1"
					//src:bgrowstate = 2
					src:name = "Sappling"
					//growthstate = "Sappling"
				if (src.vgrowstate == 3)
					src:icon_state = "bloo1"
					//src:bgrowstate = 3
					src:name = "Bloom"
					//growthstate = "Bloom"
				if (src.vgrowstate == 4)
					verbs += /obj/Plants/Vegetables/proc/PickV
					// The Apple tree is ripe, so allow apple picking.
					src:icon_state = "ripe1"
					//src:bgrowstate = 4
					src:name = "Ripe"
					//growthstate = "Ripe"
				if (src.vgrowstate == 5)
					//verbs -= /obj/Plants/proc/Pick
					//Tree no longer ripe, take away the pick option.
					src:icon_state = "aut"
					//src:bgrowstate = 5
					//src:name = "Ripe"
				if (src.vgrowstate == 6)
					verbs -= /obj/Plants/Vegetables/proc/PickV
					//Tree no longer ripe, take away the pick option.
					src:icon_state = "wint"
					//src:bgrowstate = 5
					src:name = "Old"

					//growthstate = "Old"
				Grow()

			Potato
				icon = 'dmi/64/vpotato.dmi'
				icon_state = "seed"
				MinVege=2
				MaxVege=5
				MinSeed=1
				MaxSeed=3
				GiveXP=5
				VegeAmount=0
				SeedAmount=0
				vegetable=/obj/items/Vegetables/Potato
				seed=/obj/items/Seeds/Potatoseed   //This is basically saying what log will be made when tree is cut...
				plantb=/obj/Plants/Vegetables/Potato
				Rarity=100
				spawntime=42
				VegeType="Potato"
				greq=1
				//density = 0
				layer = 2
				mouse_opacity = 1
				//disallow_in = NORTH
				//disallow_out = SOUTH

			Onion
				icon = 'dmi/64/vonion.dmi'
				icon_state = "seed"
				MinVege=2
				MaxVege=5
				MinSeed=1
				MaxSeed=3
				GiveXP=5
				VegeAmount=0
				SeedAmount=0
				vegetable=/obj/items/Vegetables/Onion
				seed=/obj/items/Seeds/Onionseed   //This is basically saying what log will be made when tree is cut...
				plantb=/obj/Plants/Vegetables/Onion
				Rarity=100
				spawntime=42
				VegeType="Onion"
				greq=2
				//density = 0
				layer = 2
				mouse_opacity = 1
				//disallow_in = NORTH
				//disallow_out = SOUTH

			Carrot
				icon = 'dmi/64/vcarrots.dmi'
				icon_state = "seed"
				MinVege=2
				MaxVege=5
				MinSeed=1
				MaxSeed=3
				GiveXP=5
				VegeAmount=0
				SeedAmount=0
				vegetable=/obj/items/Vegetables/Carrot
				seed=/obj/items/Seeds/Carrotseed   //This is basically saying what log will be made when tree is cut...
				plantb=/obj/Plants/Vegetables/Carrot
				Rarity=100
				spawntime=42
				VegeType="Carrot"
				greq=3
				//density = 0
				layer = 2
				mouse_opacity = 1
				//disallow_in = NORTH
				//disallow_out = SOUTH
			Tomato
				icon = 'dmi/64/ftomato.dmi'
				icon_state = "seed"
				MinVege=2
				MaxVege=5
				MinSeed=1
				MaxSeed=3
				GiveXP=5
				VegeAmount=0
				SeedAmount=0
				vegetable=/obj/items/Vegetables/Tomato
				seed=/obj/items/Seeds/Tomatoseed   //This is basically saying what log will be made when tree is cut...
				plantb=/obj/Plants/Vegetables/Tomato
				Rarity=100
				spawntime=42
				VegeType="Tomato"
				greq=4
				//density = 0
				layer = 2
				mouse_opacity = 1
				//disallow_in = NORTH
				//disallow_out = SOUTH
			Pumpkin
				icon = 'dmi/64/vpumpkin.dmi'
				icon_state = "seed"
				MinVege=2
				MaxVege=5
				MinSeed=1
				MaxSeed=3
				GiveXP=5
				VegeAmount=0
				SeedAmount=0
				vegetable=/obj/items/Vegetables/Pumpkin
				seed=/obj/items/Seeds/Pumpkinseed   //This is basically saying what log will be made when tree is cut...
				plantb=/obj/Plants/Vegetables/Pumpkin
				Rarity=100
				spawntime=42
				VegeType="Pumpkin"
				greq=5
				//density = 0
				layer = 2
				mouse_opacity = 1
				//disallow_in = NORTH
				//disallow_out = SOUTH



		Grain
			New()
				..()
				if(month=="Shevat"&&ggrowstate==1)
					Grow()
				if(!GrainAmount)
					src.GrainAmount = rand(src.MinGrain, src.MaxGrain)
				if(!SeedAmount)
					src.SeedAmount = rand(src.MinSeed, src.MaxSeed)
			DblClick()//grain click
				set waitfor = 0
				var/mob/players/M = usr
				if(get_dist(src,M)>=2&&get_dir(src,M)<=M.dir)
				//if(!(src in range(2, usr)))
				//if(get_step_away(src,usr,3))
					M<<"You need to be closer to cut."
					return
				else
					if(M.SKequipped==0)//Does the usr have a Axe to cut with?
						M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Sickle equipped."
						return
					else
						if(M.SKequipped==1)//Makes sure the person is right beside the tree and facing it.
							if(Picking==1)//This is saying if usr is already cuttin a tree...
								return
							if(stamina==0)//Is your stamina to low???
								M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
								return
							if((src.ggrowstate==4)||(src.ggrowstate==5))
								PickG(M)//Calls the Pick() proc
								sleep(2)
							else
								if(src.ggrowstate==1)
									M<<"This [GrainType] Plant is just a seedling and too young to be viable to pick."
									return
								if(src.ggrowstate==2)
									M<<"This [GrainType] Plant is just a sappling and therefor isn't viable to pick."
									return
								if(src.ggrowstate==3)
									M<<"This [GrainType] Plant is barely blooming and isn't viable to pick."
									return
								//if(src.bgrowstate==5)
									//M<<"This [FruitType] Plant is too old and brittle to pick."
									//return
								if(src.ggrowstate==6)
									M<<"This [GrainType] Plant is too old and brittle to pick."
									return
								if(src.ggrowstate==7)
									M << "This [GrainType] has already been harvested."
									return
								if(src.ggrowstate==8)
									M << "This [GrainType] was planted out of season."
									return
			proc/PickG(mob/Picker)//grain proc
				set waitfor = 0
				var/mob/players/M
				M = usr//Makes the usr become Picker... Not really neccesary.
				if(grank<greq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
					M<<"<FONT COLOR=RED>You must have a Gardening Acuity of at least [greq] to pick [GrainType] plant.</FONT>"
					return
				if(GrainAmount==0)		//Does the tree have logs???
					M<<"It's not worthwhile."
					return
				if(SeedAmount==0)		//Does the tree have logs???
					M<<"It's not worthwhile."
					return				//If no... Return!
				if(M.SKequipped==0)			//Does the usr have a Axe to cut with?
					Picker<<"You need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Sickle to harvest."
					return
				M<<"You begin to work on the [GrainType] plant with your Sickle."			//YAY YOU're CUTTING!!!
				M.overlays += image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
				if(M.stamina==0)			//Calling this again... Some screwy stuff could happen.
					M<<"Your stamina is too low."
					return
				if(Picking==1)
					return
				Picking=1				//Setting this to one because the usr is cutting a tree now.
				sleep(10)				//Sleeps about 2.5 seconds...
				if(GrainAmount==0)		//If log amount being called again...
					M<<"You already picked the [GrainType] plant."
					Picking=0
					return
				if(SeedAmount==0)		//If log amount being called again...
					M<<"You already picked the [GrainType] plant."
					Picking=0
					return
				else
					if(M.SKequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
						Picker<<"You need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Sickle to use it on the [GrainType] plant."
						return
					if (M.stamina==0)
						M << "Low stamina."
					else
						M.stamina -= 3	//Depletes one stamina
						M.updateST()
						if(prob(Rarity+grank))		//Takes the rarity of the tree and your woodcutting lvl
							Picker<<"You Finish working the [GrainType] plant and receive [GrainType]!"		//You get "tree being cut" Logs!
							M.overlays -= image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
							src.icon_state="picked"
							src.ggrowstate=7
							src.name = "Picked"
							new grain(usr)			//Remember log=obj/items/Logs/Oak???  Heres where this creates a log into invetory
							new seed(usr)
							grankEXP+=GiveXP				//  Add The exp from tree to you.
							M.GNLvl()						//Calls the WCLvl() Proc to see if person got lvl...
							Picking=0							// Picking is set to 0 so you are free to move and cut some more.
							GrainAmount--
							SeedAmount--							//Depletes one log from the Amount.

							if(GrainAmount==0)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
								//src.icon_state="picked"
								//sleep(src.spawntime)		//Waiting the spawntime you set for your trees
								//src.icon_state= initial(icon_state)		//Makes your trees come back to live
								//src.GrainAmount=rand(MinGrain,MaxGrain)			//Redefines new FruitAmounts.
								//src.SeedAmount=rand(MinSeed,MaxSeed)
								//del src
								return
						else
							M.overlays -= image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
							Picker<<"You missed the [GrainType] plant."
							sleep(10)		//You wernt lucky enough to hit the treee.
							Picking=0

			Grow()//grain growth
				var/randomvalue = rand(840,1240)
				spawn(randomvalue)
				//spawn(420) // 420 testing Normaly set to 12000, or twenty min.
				// Cycle the bgrowstate var.
					//if (bgrowstate == 1)
						// chopped down? It is now a stump, no more growth until I implement a random seed
						//src:bgrowstate = 1
					if(src.ggrowstate == 8||src.ggrowstate == 7)
						return
					if (month == "Shevat"&&day>=10||month == "Shevat"&&day<=19)

						src:ggrowstate = 1//seed
						if(src.ggrowstate == 8)
							src.ggrowstate=1
					if (month == "Shevat"&&day>=20)

						src:ggrowstate = 2//sappling
						if(src.ggrowstate == 8)
							return
					if (month == "Adar"&&day>=15)

						src:ggrowstate = 3//bloom
						if(src.ggrowstate == 8)
							return
					if (month == "Av"&&day>=25)

						src:ggrowstate = 4//ripe
						if(src.ggrowstate == 8)
							return

					if (season == "Summer")
						src:ggrowstate = 4//ripe
						if(src.ggrowstate == 8)
							return

					if (season == "Autumn")

						src:ggrowstate = 5//ripe fall
						if(src.ggrowstate == 8)
							return
					if (season == "Winter")

						src:ggrowstate = 6//old winter
						if(src.ggrowstate == 8)
							return
					//bgrowstate+=1//comment out to remove growing out of season
					//if(bgrowstate>=6)//just a temporary check to make sure growstate doesn't go above the actual amount of stages that exist
						//bgrowstate = 1
					src.UpdatePlantPic()
				//..()
			UpdatePlantPic()//grain growth
			//growstates: 1 = Seedling 2=Sappling 3=Bloom 4=Ripe 5=Old
			// Update the bush pic as needed:
			//var/list/P = icon_states(icon)
	//			var/obj/Plants/Raspberrybush/R = locate(world)
				//if(bgrowstate != bstateload)
	//			for(R in world)
				//for(var/obj/Plants/Blueberrybush)
					//src:bgrowstate=bstateload

				//bgrowstate = bstateload
				if (src.ggrowstate == 7)
					src:icon_state = "picked"
					//src:bgrowstate = 1
					src:name = "Picked"
					return
				if (src.ggrowstate == 8)
					src:icon_state = "seed"
					//src:bgrowstate = 1
					src:name = "OoS"
					return
				if (src.ggrowstate == 1)
					src:icon_state = "seed1"
					//src:bgrowstate = 1
					src:name = "Seedling"
					//growthstate = "Seedling"
				if (src.ggrowstate == 2)
					src:icon_state = "sapp1"
					//src:bgrowstate = 2
					src:name = "Sappling"
					//growthstate = "Sappling"
				if (src.ggrowstate == 3)
					src:icon_state = "bloo1"
					//src:bgrowstate = 3
					src:name = "Bloom"
					//growthstate = "Bloom"
				if (src.ggrowstate == 4)
					verbs += /obj/Plants/Grain/proc/PickG
					// The Apple tree is ripe, so allow apple picking.
					src:icon_state = "ripe1"
					//src:bgrowstate = 4
					src:name = "Ripe"
					//growthstate = "Ripe"
				if (src.ggrowstate == 5)
					//verbs -= /obj/Plants/proc/Pick
					//Tree no longer ripe, take away the pick option.
					src:icon_state = "aut"
					//src:bgrowstate = 5
					//src:name = "Ripe"
				if (src.ggrowstate == 6)
					verbs -= /obj/Plants/Grain/proc/PickG
					//Tree no longer ripe, take away the pick option.
					src:icon_state = "wint"
					//src:bgrowstate = 5
					src:name = "Old"
					//growthstate = "Old"
				Grow()

			Wheat
				icon = 'dmi/64/gwheat.dmi'
				icon_state = "seed"
				MinGrain=2
				MaxGrain=5
				MinSeed=1
				MaxSeed=3
				GiveXP=5
				GrainAmount=0
				SeedAmount=0
				grain=/obj/items/Grain/Wheat
				seed=/obj/items/Seeds/Wheatseed   //This is basically saying what log will be made when tree is cut...
				plantb=/obj/Plants/Grain/Wheat
				Rarity=100
				spawntime=42
				GrainType="Wheat"
				greq=4
				//density = 0
				layer = 2
				mouse_opacity = 1
				//disallow_in = NORTH
				//disallow_out = SOUTH

			Barley
				icon = 'dmi/64/gbarley.dmi'
				icon_state = "seed"
				MinGrain=2
				MaxGrain=5
				MinSeed=1
				MaxSeed=3
				GiveXP=5
				GrainAmount=0
				SeedAmount=0
				grain=/obj/items/Grain/Barley
				seed=/obj/items/Seeds/Barleyseed   //This is basically saying what log will be made when tree is cut...
				plantb=/obj/Plants/Grain/Barley
				Rarity=100
				spawntime=42
				GrainType="Barley"
				greq=5
				//density = 0
				layer = 2
				mouse_opacity = 1
				//disallow_in = NORTH
				//disallow_out = SOUTH

		Bush
			disallow_in = NORTH
			disallow_out = SOUTH
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
			New()
				..()

				if(!FruitAmount)
					FruitAmount = rand(MinFruit, MaxFruit)
				if(!SeedAmount)
					SeedAmount = rand(MinSeed, MaxSeed)
			DblClick()
				set waitfor = 0
				var/mob/players/M = usr
				if(get_dist(src,M)>=2&&get_dir(src,M)<=M.dir)
				//if(!(src in range(2, usr)))
				//if(get_step_away(src,usr,3))
					M<<"You need to be closer."
					return
				else
					if(M.SHequipped==1)
						M<<"You dig up the bush."
						del src
						return
					/*if(M.SKequipped==0)			//Does the usr have a Axe to cut with?
						M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Sickle equipped."
						return
					else
						if(M.SKequipped==1)		//Makes sure the person is right beside the tree and facing it.
							if(Picking==1)		//This is saying if usr is already cuttin a tree...
								return*/
					if(stamina==0)		//Is your stamina to low???
						M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
						return
					if((src.bgrowstate==4)||(src.bgrowstate==5))
						Pick(M)		//Calls the Pick() proc
						sleep(2)
						return
					else
						if(src.bgrowstate==1)
							M<<"This [FruitType] Bush is just a seedling and too young to be viable to pick."
							return
						if(src.bgrowstate==2)
							M<<"This [FruitType] Bush is just a sappling and therefor isn't viable to pick."
							return
						if(src.bgrowstate==3)
							M<<"This [FruitType] Bush is barely blooming and isn't viable to pick."
							return
						if(src.bgrowstate==51)
							M<<"This [FruitType] Bush has no fruit to pick."
							return
						if(src.bgrowstate==6)
							M<<"This [FruitType] Bush is too old and brittle to pick."
							return



			Grow()
				var/randomvalue = rand(1240,1840)
				spawn(randomvalue) // Normaly set to 12000, or twenty min.
				// Cycle the bgrowstate var.
					//if (bgrowstate == 1)
						// chopped down? It is now a stump, no more growth until I implement a random seed
						//src:bgrowstate = 1
					//return

					if (month == "Shevat"&&day>=2)

						src:bgrowstate = 6//old from winter

					if (month == "Adar"&&day>=2)

						src:bgrowstate = 2//sappling

					if (month == "Nisan"&&day<16)

						src:bgrowstate = 3//blooming

					if (month == "Nisan"&&day>=16||season == "Summer")

						src:bgrowstate = 4//ripe

					/*if (season == "Summer")

						src:bgrowstate = 4//ripe
						*/

					if (season == "Autumn")

						src:bgrowstate = 5//ripe fall

					if (season == "Autumn"&&month == "Cheshvan")

						src:bgrowstate = 51

					if (season == "Winter")

						src:bgrowstate = 6//old winter

					//bgrowstate+=1//comment out to remove growing out of season
					//if(bgrowstate>=6)//just a temporary check to make sure growstate doesn't go above the actual amount of stages that exist
						//bgrowstate = 1
					src.UpdatePlantPic()
					//..()


			UpdatePlantPic()
			//growstates: 1 = Seedling 2=Sappling 3=Bloom 4=Ripe 5=Old
			// Update the bush pic as needed:

				//bgrowstate = bstateload
				if (src.bgrowstate == 1)
					src:icon_state = "seed1"
					verbs -= /obj/Plants/proc/Pick
					//src:bgrowstate = 1
					src:name = "Bush Seedling"
					//growthstate = "Seedling"
				if (src.bgrowstate == 2)
					src:icon_state = "sapp1"
					verbs -= /obj/Plants/proc/Pick
					//src:bgrowstate = 2
					src:name = "Bush Sappling"
					//growthstate = "Sappling"
				if (src.bgrowstate == 3)
					src:icon_state = "bloo1"
					verbs -= /obj/Plants/proc/Pick
					//src:bgrowstate = 3
					src:name = "Blooming Bush"
					//growthstate = "Bloom"
				if (src.bgrowstate == 4)
					verbs += /obj/Plants/proc/Pick
					// The Apple tree is ripe, so allow apple picking.
					if(FruitType=="Raspberry")
						src:icon_state = "ripe1"
					if(FruitType=="Blueberry")
						src:icon_state = "ripe2"
					//src:bgrowstate = 4
					src:name = "Ripe [FruitType] Bush"
					//growthstate = "Ripe"
				if (src.bgrowstate == 5)
					verbs += /obj/Plants/proc/Pick
					//verbs -= /obj/Plants/proc/Pick
					//Tree no longer ripe, take away the pick option.
					if(FruitType=="Raspberry")
						src:icon_state = "autorg"
					if(FruitType=="Blueberry")
						src:icon_state = "aut2org"
					//src:icon_state = "aut"
					//src:bgrowstate = 5
					src:name = "Fading [FruitType] Bush"
				if (src.bgrowstate == 51)
					verbs -= /obj/Plants/proc/Pick
					src:icon_state = "aut"
					//src:bgrowstate = 3
					src:name = "Hibernating Bush"
				if (src.bgrowstate == 6)
					verbs -= /obj/Plants/proc/Pick
					//Tree no longer ripe, take away the pick option.
					src:icon_state = "wint2"
					//src:bgrowstate = 5
					src:name = "Dormant Bush"
					//growthstate = "Old"
				Grow()

//raspberry bush
			Raspberrybush
				//This makes it so we can make a Minimum log amount and a max log amount
				// bgrowstate is the tree's current 'phase'
				name = "Raspberry Bush"
				icon = 'dmi/64/plants.dmi'
				icon_state = "rbs"
				MinFruit=2
				MaxFruit=5
				MinSeed=1
				MaxSeed=3
				GiveXP=5
				FruitAmount = 0
				SeedAmount = 0
				fruitc=/obj/items/Fruit/RaspberryCluster
				fruit=/obj/items/Fruit/Raspberry
				seed=/obj/items/Seeds/Raspberryseed   //This is basically saying what log will be made when tree is cut...
				plantb=/obj/Plants/Bush/Raspberrybush
				Rarity=100
				spawntime=42
				FruitType="Raspberry"
				greq=1
				//density = 0
				layer = 10
				mouse_opacity = 1
				disallow_in = NORTH||SOUTH
				disallow_out = SOUTH||NORTH





//blueberry bush
			Blueberrybush
				//This makes it so we can make a Minimum log amount and a max log amount
				// bgrowstate is the tree's current 'phase'
				name = "Blueberry Bush"
				icon = 'dmi/64/plants.dmi'
				icon_state = "bbs"
				MinFruit=2
				MaxFruit=5
				MinSeed=1
				MaxSeed=3
				GiveXP=5
				FruitAmount = 0
				SeedAmount = 0
				fruitc=/obj/items/Fruit/BlueberryCluster
				fruit=/obj/items/Fruit/Blueberry
				seed=/obj/items/Seeds/Blueberryseed   //This is basically saying what log will be made when tree is cut...
				plantb=/obj/Plants/Bush/Blueberrybush
				Rarity=100
				spawntime=42
				FruitType="Blueberry"
				greq=1
				//density = 0
				layer = 10
				mouse_opacity = 1
				disallow_in = NORTH||SOUTH
				disallow_out = SOUTH||NORTH
					//seeds = 1


obj
	//var/Sowed
	Soil
		var/Sowed
		var/list/STL[0]//Seed list
		soil
			icon_state = "dirt"
			icon = 'dmi/64/gen.dmi'
			//var/list/STL[0]

			//var/S
			//S = /obj/items/Seeds

			layer = 1
			Sowed = 0
			Click()//does this need to block multiple menu instances opening? Need to test

				Plant()
			verb/Plant()
				 //change to seed


				var/mob/players/M = usr
				//var/obj/items/Seeds/F = locate() in M.contents
				//if (!(src in range(1, usr)))
					//return
				var/obj/DeedToken/dt//remove this section---------------
				dt = locate(oview(src,15))
				if(!dt)
					goto NXT
				for(dt)
					if(M.canbuild==1)
						goto NEXT
					else
						M << "You do not have permission to build"
						return
				NEXT//to disable deeds----------------------------------
				NXT
				if (Sowed==1)
					usr << "Already sown."
					return
				if(M.HOequipped==0)//Checking if the tool is equipped
					M<<"Need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hoe'>Hoe to plant the seed properly."
					return
				if(get_dist(src,M)>=1)//Checking to make sure the user didn't walk away
					M<<"Stand on the spot where you want to plant the seed."
					return
				//if(month != "Shevat")
					//M << "Can only plant in the month of Shevat."
					//return
				if(M.stamina == 0)//Checking user's stamina level
					M<<"Low stamina."
					return

				//if(F)

				var/obj/items/Seeds/S = locate() in M.contents//variable reference to the seed in question
				for(S)//checking for seed object in user contents

					if(istype(S,/obj/items/Seeds))//checking if that reference is indeed the right type of object
						locate(S) in usr.contents//locating the desired object in user contents
						if(M.grank >= S:greq)
							STL.Add(S)//adding that object in user contents to the list
						if(S:greq > M.grank)//compare player gardening rank to the gardening requirement level of the plant
							//usr << "Your gardening acuity is too low to plant [S]."
							STL.Remove(S)
						if(STL.len >=2)//checking if the list contents is greater than or equal to 2

							var/ST = input("Select Seed","Gardening") as anything in STL//If it is greater than or equal to 2, return a list of options

							//usr << ST
								//if(ST)
							if(ST)//if there is a choice made in that list
								//F.RemoveFromStack(1)
								M<<"You plant the [S] at your feet."
								S.Sown = 1
								var/obj/Plants/Vegetables/vs
								var/obj/Plants/Grain/gs
								//M<<"You plant the [src] at your feet."//notify
								if((S.Sown==1)&&(month != "Shevat"))
									new S.plantbs(usr.loc)
									for(vs in view(src,1))
										vs.vgrowstate=8
								if(S.Sown==1&&month != "Shevat"&&istype(gs,/obj/Plants/Grain) in view(src,1))
									new S.plantbs(usr.loc)
									gs.ggrowstate=8
								else if(S.Sown==1&&month=="Shevat")
									new S.plantbs(usr.loc)//plant that choice
									//call(/obj/Plants/Grow)()
									M.grankEXP += S.gxpg
									S.RemoveFromStack(1)//remove from stack
									Sowed = 1//mark soil and sown
									M.stamina -= 8//remove stamina
									M.updateST()
								if(M.MAXgrankLVL==1)
									return
								else
									if(M.grankEXP >= M.grankMAXEXP)
										M.GNLvl()
										return
								//notify
								return//return haha

		richsoil
			icon_state = "richsoil"
			icon = 'dmi/64/gen.dmi'
			layer = 1
			Sowed = 0

			Click()//does this need to block multiple menu instances opening? Need to test

				Plant()
			verb/Plant()
				 //change to seed


				var/mob/players/M = usr
				//var/obj/items/Seeds/F = locate() in M.contents
				//if (!(src in range(1, usr)))
					//return
				var/obj/DeedToken/dt//remove this section---------------
				dt = locate(oview(src,15))
				if(!dt)
					goto NXT
				for(dt)
					if(M.canbuild==1)
						goto NEXT
					else
						M << "You do not have permission to build"
						return
				NEXT//to disable deeds----------------------------------
				NXT
				if (Sowed==1)
					usr << "Already sown."
					return
				if(M.HOequipped==0)//Checking if the tool is equipped
					M<<"Need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hoe'>Hoe to plant the seed properly."
					return
				if(get_dist(src,M)>=1)//Checking to make sure the user didn't walk away
					M<<"Stand on the spot where you want to plant the seed."
					return
				//if(month != "Shevat")
					//M << "Can only plant in the month of Shevat."
					//return
				if(M.stamina == 0)//Checking user's stamina level
					M<<"Low stamina."
					return

				//if(F)

				var/obj/items/Seeds/S = locate() in M.contents//variable reference to the seed in question
				for(S)//checking for seed object in user contents

					if(istype(S,/obj/items/Seeds))//checking if that reference is indeed the right type of object
						locate(S) in usr.contents//locating the desired object in user contents
						if(M.grank >= S:greq)
							STL.Add(S)//adding that object in user contents to the list
						if(S:greq > M.grank)//compare player gardening rank to the gardening requirement level of the plant
							//usr << "Your gardening acuity is too low to plant [S]."
							STL.Remove(S)
						if(STL.len >=2)//checking if the list contents is greater than or equal to 2

							var/ST = input("Select Seed","Gardening") as anything in STL//If it is greater than or equal to 2, return a list of options

							//usr << ST
								//if(ST)
							if(ST)//if there is a choice made in that list
								//F.RemoveFromStack(1)
								M<<"You plant the [S] at your feet."
								S.Sown = 1
								var/obj/Plants/Vegetables/vs
								var/obj/Plants/Grain/gs
								//M<<"You plant the [src] at your feet."//notify
								if((S.Sown==1)&&(month != "Shevat"))
									new S.plantbs(usr.loc)
									for(vs in view(src,1))
										vs.vgrowstate=8
								if(S.Sown==1&&month != "Shevat"&&istype(gs,/obj/Plants/Grain) in view(src,1))
									new S.plantbs(usr.loc)
									gs.ggrowstate=8
								else if(S.Sown==1&&month=="Shevat")
									new S.plantbs(usr.loc)//plant that choice
									//call(/obj/Plants/Grow)()
									M.grankEXP += S.gxpg
									S.RemoveFromStack(1)//remove from stack
									Sowed = 1//mark soil and sown
									M.stamina -= 8//remove stamina
									M.updateST()
								if(M.MAXgrankLVL==1)
									return
								else
									if(M.grankEXP >= M.grankMAXEXP)
										M.GNLvl()
										return
								//notify
								return//return haha


mob/players
	verb
		Sow()
			set waitfor = 0
			set popup_menu = 1
		//	set hidden = 1
			set category=null
			var/mob/players/M = usr
			var/obj/DeedToken/dt//remove this section---------------
			dt = locate(oview(src,15))
			for(dt)
				if(M.canbuild==1)
					goto NEXT
				else
					M << "You do not have permission to build"
					return
			NEXT//to disable deeds----------------------------------
			if(Doing==1)
				usr << "You are currently sowing."
				return
			if (!(src in range(1, usr))) return
			if(M.stamina == 0)
				return
			/*if(src.loc == locate(x,y,2))
				M<<"Can only sow soil in the Combat Area."
				return*/
			else
				if(M.HOequipped!=1)
					M<<"Need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hoe'>Hoe to Sow."
					return
				else
					if(M.HOequipped==1 && season != "Winter")
						if(grank>=4)
							var/a
							M.Doing=1
							M<<"You begin sowing the soil."
							sleep(15)
							a = new/obj/Soil/richsoil(src.loc)
							M<<"You sow rich soil."
							a:buildingowner = ckeyEx("[usr.key]")
							M.stamina -= 5
							M.updateST()
							M.Doing=0
							if(M.MAXgrankLVL==1)
								return
							else
								if(grankEXP >= grankMAXEXP)
									GNLvl()
								else
									grankEXP += 10
									return
						else
							var/a
							M.Doing=1
							M<<"You begin sowing the soil."
							sleep(15)
							a = new/obj/Soil/soil(src.loc)
							M<<"You Finish sowing the soil."
							a:buildingowner = ckeyEx("[usr.key]")
							M.stamina -= 5
							M.updateST()
							M.Doing=0
							if(M.MAXgrankLVL==1)
								return
							else
								if(grankEXP >= grankMAXEXP)
									GNLvl()
								else
									grankEXP += 5
									return
					else
						M << "The ground is too cold and hard."

						/*if(b == "Dirt Road Corner")
							switch(input("Which direction?","Dirt Road")in list("NorthWest Corner","NorthEast Corner","SouthWest Corner","SouthEast Corner"))
								if("NorthWest Corner")
									a = new/turf/NWCRoad(src.loc)
									a:buildingowner = ckeyEx("[usr.key]")
									M.buildexp += 5
								if("NorthEast Corner")
									a = new/turf/NECRoad(src.loc)
									a:buildingowner = ckeyEx("[usr.key]")
									M.buildexp += 5*/
						//call(/proc/buildlevel)(M)





