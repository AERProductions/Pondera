mob/players/var
	mrank=1			//mrank lvl mining rank
	mrankEXP=0		//mrank Exp
	mrankMAXEXP=10		//Exp till level
	MAXmrankLVL=0	//Maxmranklvl when set to one it stops more lvls...
	tmp
		Mining
var
	orelist[0]
obj
	items
		Ore
			can_stack = TRUE
			ore = 1
			layer = 11
			//var/stack = 1
			Tname=""

				//stack()
			/*var
				description
			/*verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << src.description
				return*/
			verb
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
									return
								else if(o.type==/obj/items/questitem)
									M << "You don't need that"
									return
							if(C==0)
								src.Move(usr)
								return
						else
							M << "You don't need that"
							return
					else
						var/obj/O = src
						set src in oview(1)
						for(O as obj in view(3)) // only people you can SEE
							if(istype(O,/obj))
								src.Move(usr)
								return
				Drop()
					set category = null
					set popup_menu=1
					set src in usr
					if(src.suffix == "Equipped")
						usr << "<font color = teal>Un-equip [src] first!"
						return
					else
						src.Move(usr.loc)
						return*/
			iron
				icon = 'dmi/64/build.dmi'
				icon_state = "iron"
				name = "Iron Ore"
				description = "Iron Ore"
				//layer = 6
				Tname="Cool"
				//stack = 1
				ore = 1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #c0c0c0><center><b>Iron Ore:</b> Can be smelted into ingots for metalwork.<br>"
					return
			zinc
				icon = 'dmi/64/build.dmi'
				icon_state = "zinc"
				name = "Zinc Ore"
				description = "Zinc Ore"
				//layer = 6
				Tname="Cool"
				//stack = 1
				ore = 1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>Zinc Ore:</b> Can be smelted into ingots for metalwork.<br>"
					return
			copper
				icon = 'dmi/64/build.dmi'
				icon_state = "copper"
				name = "Copper Ore"
				description = "Copper Ore"
				//layer = 6
				Tname="Cool"
			//	stack = 1
				ore = 1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #b87333><center><b>Copper Ore:</b> Can be smelted into ingots for metalwork.<br>"
					return
			lead
				icon = 'dmi/64/build.dmi'
				icon_state = "lead"
				name = "Lead Ore"
				description = "Lead Ore"
				//layer = 6
				Tname="Cool"
				//stack = 1
				ore = 1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #4682b4><center><b>Lead Ore:</b> Can be smelted into ingots for metalwork.<br>"
					return
			stone
				icon = 'dmi/64/build.dmi'
				icon_state = "stone"
				name = "Stone Ore"
				description = "Stone Ore"//stone needs a tool like chisel to create stone bricks for stone buildings, grinding stones for wheat, statues/etc
			//	stack = 1
				//layer = 6
				Tname="Cool"
				ore = 1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #c0c0c0><center><b>Stone Ore:</b> Can be chiseled for stonework.<br>"
					return
				verb/Create_Shards()
					set src in usr
					var/dice = "1d4"
					var/R = roll(dice)
					if(usr.HMequipped==1)

						if(R>=2)
							new /obj/items/Crafting/Created/StoneAxehead(usr)
							usr << "Using the Hammer, you begin to create shards by hammering the stone at an angle."
							src.RemoveFromStack(1)
							return
						else
							//new obj/items/crafting/created/Vessel()
							usr << "This ore isn't suitable and shatters into pieces."
							src.RemoveFromStack(1)
							return
					else
						usr << "Need to use a Hammer to shard Stone ore."
						return
				verb/Create_Brick()
					set waitfor = 0
					if(Mining==1)		//This is saying if usr is already cuttin a tree...
						usr<<"Already creating."
						return
					else
						givebrk(usr)
						sleep(2)
				proc/givebrk()
					set waitfor = 0
					var/mob/players/M
					M = usr
					var/obj/items/Ore/stone/ST = locate() in M.contents
					//var/obj/items/Crafting/Created/Handle/H = new(usr, 1)
					var/random/R = new()
					//if(stamina<=0)
					//	M<<"You are too tired."
					//	return
					if(M.CHequipped==1)
						if(M.stamina==0)		//Is your stamina to low???
							M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
							return
						else
							for(ST in M.contents)
								//M << "You Begin carving the materials..."
								if(R.chance(81))
									M << "You begin shaping the material..."
									Mining=1
									sleep(2)
									new /obj/items/Crafting/Created/Bricks(M, 3)
									sleep(2)
									M << "You've carved \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='bricks'>Bricks."
									//WH.RemoveFromStack(1) //del src
									Mining=0
									ST.RemoveFromStack(1)
									return
								else
									M<<"The materials fail to create \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='bricks'>Bricks."
									Mining=0
							//else
								//M << "Need a Wooden Haunch to continue..."
					else
						M<<"You need to use a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Chisel'>Chisel to shape the <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Stone ore."
						return

			Gems
				layer = 11
				can_stack=TRUE
				Ruby
					icon='dmi/64/gemstones.dmi'
					icon_state="ruby"
					name="Ruby"
				Sapphire
					icon='dmi/64/gemstones.dmi'
					icon_state="sapphire"
					name="Sapphire"
				Topaz
					icon='dmi/64/gemstones.dmi'
					icon_state="topaz"
					name="Topaz"
				Diamond
					icon='dmi/64/gemstones.dmi'
					icon_state="diamond"
					name="Diamond"
				Quartz
					icon='dmi/64/gemstones.dmi'
					icon_state="quartz"
					name="Quartz"
				Emerald
					icon='dmi/64/gemstones.dmi'
					icon_state="emerald"
					name="Emerald"
				Onyx
					icon='dmi/64/gemstones.dmi'
					icon_state="onyx"
					name="Onyx"
				Tourmaline
					icon='dmi/64/gemstones.dmi'
					icon_state="tourmaline"
					name="Tourmaline"
				Carnelian
					icon='dmi/64/gemstones.dmi'
					icon_state="carnelian"
					name="Carnelian"
				Chrysolite
					icon='dmi/64/gemstones.dmi'
					icon_state="peridot"
					name="Chrysolite"
				LapisLazuli
					icon='dmi/64/gemstones.dmi'
					icon_state="lapislazuli"
					name="LapisLazuli"
				Turquoise
					icon='dmi/64/gemstones.dmi'
					icon_state="turquoise"
					name="Turquoise"
				Beryl
					icon='dmi/64/gemstones.dmi'
					icon_state="beryl"
					name="Beryl"
	//items
		Ingots
			parent_type = /obj/items/thermable
			can_stack = TRUE
			ore = 1
			Tname = ""

			layer = 11
			var
				ingot_type = ""
				IB
				ZB
				CB
				LB
				BB
				BRB
				STLB
				DSTLB
			
			New()
				..()
				// Initialize temperature system for ingot
				if(Tname == "Hot")
					temperature_stage = TEMP_HOT
					spawn(1)
						StartCooling()
				else
					temperature_stage = TEMP_COOL
			/*	description
			New()
				stack()
			verb
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
			proc/FindI()
				for(var/obj/items/Ingots/J)// Ingot
					locate(J)
					if(J:Tname=="Hot")
						return J
			proc/FindS()
				for(var/obj/items/Ingots/Scraps/J)// Scraps
					locate(J)
					if(J:Tname=="Hot")
						return J
			proc
				Temp(obj/items/Ingots/J = FindI(usr))
					set waitfor = 0
					set background = 1
					//set src in usr
					//var/obj/J = src
					//var/mob/players/M
					//J = FindI(M)
				//	M = usr
					//if((CB in M.contents)&&(CB.Tname == "Hot"))
					//if(J in M)
					//while(src)
					for(J)//would be nice if I could get it to set the temp as a suffix and stack accordingly...
						//if(Tname!="Hot"&&J in usr)
							//src.SplitStack(usr, 1)
						if(Tname=="Hot")
							//src.MergeStack()
							//suffix = "Hot"
							name = "[ingot_type] Ingot (Hot)"
							sleep(240)

							Tname = "Warm"
							//suffix = "Warm"
							//if(J in usr)
							//	usr << "[J] is warm."
							name = "[ingot_type] Ingot (Warm)"
							sleep(120)
							Tname = "Cool"
							name = "[ingot_type] Ingot (Cool)"
							//suffix = "Cool"
							//if(J in usr)
							//	usr << "[J] has cooled."
						else return
					//else return
				STemp(obj/items/Ingots/Scraps/J = FindS(usr))
					set waitfor = 0
					set background = 1
					//set src in usr
					//var/obj/J = src
					//var/mob/players/M
					//M = usr
					//if((CB in M.contents)&&(CB.Tname == "Hot"))
					//if(J in M)
					//while(src)
					for(J)
						if(Tname=="Hot")
							//src.MergeStack()
							//suffix = "Hot"
							name = "[ingot_type] Scrap (Hot)"
							sleep(240)

							Tname = "Warm"
							//suffix = "Warm"
							//if(J in usr)
							//	usr << "[J] is warm."
							name = "[ingot_type] Scrap (Warm)"
							sleep(120)
							Tname = "Cool"
							name = "[ingot_type] Scrap (Cool)"
							//suffix = "Cool"
							//if(J in usr)
							//	usr << "[J] has cooled."
						else return
					//else return
				Combine_Scrap(obj/items/Ingots/Scraps/J)
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					set category = null//"Commands"
					var/mob/players/M
					//var/obj/items/Ingots/Scraps/J
					//var/random/R = rand(1,5) //1 in 5 chance to smith
					M = usr
					if(J in M.contents&&J.Tname=="Hot")
						switch(input("Combine [J]?","Combine") in list(J in M.contents))
							//M<<"You start to combine..."
								//sleep(5)
							if("Scrap Iron")
								if(J.stack_amount>=4)
									var/dice = "1d6"
									var/R = roll(dice)
									if(R!=7)
										M<<"You start to combine..."
										J.RemoveFromStack(4)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining the [J] and create a Iron Ingot."
										new /obj/items/Ingots/ironbar(src)
										return
									else
										J.RemoveFromStack(4)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining and are lost in the process."
										return
								else
									M<<"You need at least 4 scrap iron to combine."
							if("Scrap Zinc")
								if(J.stack_amount>=4)
									var/dice = "1d8"
									var/R = roll(dice)
									if(R!=5)
										J.RemoveFromStack(4)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining the [J] and create a Zinc Ingot."
										new /obj/items/Ingots/zincbar(src)
										return
									else
										J.RemoveFromStack(4)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining and are lost in the process."
										return
								else
									M<<"You need at least 4 scrap zinc to combine."
							if("Scrap Lead")
								if(J.stack_amount>=4)
									var/dice = "1d4"
									var/R = roll(dice)
									if(R!=6)
										J.RemoveFromStack(4)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining the [J] and create a Lead Ingot."
										new /obj/items/Ingots/leadbar(src)
										return
									else
										J.RemoveFromStack(4)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining and are lost in the process."
										return
								else
									M<<"You need at least 4 scrap lead to combine."
							if("Scrap Copper")
								if(J.stack_amount>=4)
									var/dice = "1d6"
									var/R = roll(dice)
									if(R!=4)
										J.RemoveFromStack(4)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining the [J] and create a Copper Ingot."
										new /obj/items/Ingots/copperbar(src)
										return
									else
										J.RemoveFromStack(4)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining and are lost in the process."
										return
								else
									M<<"You need at least 4 scrap copper to combine."
							if("Scrap Brass")
								if(J.stack_amount>=4)
									var/dice = "1d10"
									var/R = roll(dice)
									if(R!=2)
										J.RemoveFromStack(4)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining the [J] and create a Brass Ingot."
										new /obj/items/Ingots/brassbar(src)
										return
									else
										J.RemoveFromStack(4)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining and are lost in the process."
										return
								else
									M<<"You need at least 4 scrap brass to combine."
							if("Scrap Bronze")
								if(J.stack_amount>=4)
									var/dice = "1d10"
									var/R = roll(dice)
									if(R!=3)
										J.RemoveFromStack(4)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining the [J] and create a Bronze Ingot."
										new /obj/items/Ingots/bronzebar(src)
										return
									else
										J.RemoveFromStack(4)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining and are lost in the process."
										return
								else
									M<<"You need at least 4 scrap bronze to combine."
							if("Scrap Steel")
								if(J.stack_amount>=4)
									var/dice = "1d10"
									var/R = roll(dice)
									if(R!=3)
										J.RemoveFromStack(4)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining the [J] and create a Steel Ingot."
										new /obj/items/Ingots/steelbar(src)
										return
									else
										J.RemoveFromStack(4)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining and are lost in the process."
										return
								else
									M<<"You need at least 4 scrap steel to combine."
									return
					else
						M<<"[J] needs to be Hot before combining."
						return


		//scrap metal
			Scraps
				parent_type = /obj/items/Ingots
				can_stack = TRUE
				layer = 11
				
				New()
					..()
					// Initialize temperature system for scrap
					if(Tname == "Warm")
						temperature_stage = TEMP_WARM
						spawn(1)
							StartCooling()
					else if(Tname == "Hot")
						temperature_stage = TEMP_HOT
						spawn(1)
							StartCooling()
					else
						temperature_stage = TEMP_COOL
				
				verb
					Combine()
						set popup_menu = 1
						set src in oview(1)
						set category = null//"Commands"
						Combine_Scrap(src)
				scrapiron
					icon = 'dmi/64/build.dmi'
					icon_state = "sci"
					name = "Scrap Iron"
					Tname = "Warm"
					ingot_type = "Iron"
					description = "Scrap Iron"

					//layer = 11
					verb/Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #c0c0c0><center><b>Scrap Iron:</b><br>Scrap metal can be combined to form a new ingot.<br>Temperature: [Tname]"
						//usr << src.Tname
						return
					New()
						set waitfor = 0
						..()
						spawn(1)
							StartCooling()
				scrapzinc
					icon = 'dmi/64/build.dmi'
					icon_state = "scz"
					name = "Scrap Zinc"
					Tname = "Warm"
					description = "Scrap Zinc"
					ingot_type = "Zinc"
					//layer = 11
					verb/Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>Scrap Zinc:</b><br>Scrap metal can be combined to form a new ingot.<br>Temperature: [Tname]"
						//usr << src.Tname
						return
					New()
						set waitfor = 0
						..()
						spawn(1)
							StartCooling()
				scraplead
					icon = 'dmi/64/build.dmi'
					icon_state = "scl"
					name = "Scrap Lead"
					Tname = "Warm"
					description = "Scrap Lead"
					ingot_type = "Lead"
					//layer = 11
					verb/Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #4682b4><center><b>Scrap Lead:</b><br>Scrap metal can be combined to form a new ingot.<br>Temperature: [Tname]"
						//usr << src.Tname
						return
					New()
						set waitfor = 0
						..()
						spawn(1)
							StartCooling()
				scrapcopper
					icon = 'dmi/64/build.dmi'
					icon_state = "scc"
					name = "Scrap Copper"
					Tname = "Warm"
					description = "Scrap Copper"
					ingot_type = "Copper"
					//layer = 11
					verb/Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #b87333><center><b>Scrap Copper:</b><br>Scrap metal can be combined to form a new ingot.<br>Temperature: [Tname]"
						//usr << src.Tname
						return
					New()
						set waitfor = 0
						..()
						spawn(1)
							StartCooling()
				scrapbrass
					icon = 'dmi/64/build.dmi'
					icon_state = "scb"
					name = "Scrap Brass"
					Tname = "Warm"
					description = "Scrap Brass"
					ingot_type = "Brass"
					//layer = 11
					verb/Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #ffd700><center><b>Scrap Brass:</b><br>Scrap metal can be combined to form a new ingot.<br>Temperature: [Tname]"
						//usr << src.Tname
						return
					New()
						set waitfor = 0
						..()
						spawn(1)
							StartCooling()
				scrapbronze
					icon = 'dmi/64/build.dmi'
					icon_state = "scbr"
					name = "Scrap Bronze"
					Tname = "Warm"
					description = "Scrap Bronze"
					ingot_type = "Bronze"
					//layer = 11
					verb/Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "<center>\  <IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #8C7853><br><b>Scrap Bronze:</b><br>Scrap metal can be combined to form a new ingot.<br>Temperature: [Tname]"
						//usr << src.Tname
						return
					New()
						set waitfor = 0
						..()
						spawn(1)
							StartCooling()
				scrapsteel
					icon = 'dmi/64/build.dmi'
					icon_state = "scs"
					name = "Scrap Steel"
					Tname = "Warm"
					description = "Scrap Steel"
					ingot_type = "Steel"
					//layer = 11
					verb/Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #c0c0c0><center><b>Scrap Steel:</b><br>Scrap metal can be combined to form a new ingot.<br>Temperature: [Tname]"
						//usr << src.Tname
						return
					New()
						set waitfor = 0
						..()
						spawn(1)
							StartCooling()
			ironbar
				icon = 'dmi/64/build.dmi'
				icon_state = "ib"
				name = "Iron Ingot"
				Tname = "Hot"
				description = "Pure Iron Ingot"
				ingot_type = "Iron"
				IB = 1
				//layer = 11
				//plane = 7
				//layer = MOB_LAYER-1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #c0c0c0><center><b>Iron Ingot:</b><br>Utilized for smithing.<br>Temperature: [Tname]"
					//usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						//src.Temp() // start the spawn calls
						Start
						if(Tname=="Hot")
							src.Temp()
						//else// return
						sleep(240)
						goto Start
			zincbar
				icon = 'dmi/64/build.dmi'
				icon_state = "zb"
				name = "Zinc Ingot"
				Tname = "Hot"
				description = "Pure Zinc Ingot"
				ingot_type = "Zinc"
				ZB = 1
				//layer = 11
				//layer = MOB_LAYER-1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>Zinc Ingot:</b><br>Utilized for smithing.<br>Temperature: [Tname]"
					//usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						Start
						if(Tname=="Hot")
							src.Temp()
						//else return
						sleep(240)
						goto Start
			copperbar
				icon = 'dmi/64/build.dmi'
				icon_state = "cb"
				name = "Copper Ingot"
				Tname = "Hot"
				description = "Pure Copper Ingot"
				ingot_type = "Copper"
				CB = 1
				//layer = 11
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #b87333><center><b>Copper Ingot:</b><br>Utilized for smithing.<br>Temperature: [Tname]"
					//usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						Start
						if(Tname=="Hot")
							src.Temp()
						//else return
						sleep(240)
						goto Start
			leadbar
				icon = 'dmi/64/build.dmi'
				icon_state = "lb"
				name = "Lead Ingot"
				Tname = "Hot"
				description = "Pure Lead Ingot"
				ingot_type = "Lead"
				LB = 1
				//layer = 11
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #4682b4><center><b>Lead Ingot:</b><br>Utilized for smithing.<br>Temperature: [Tname]"
					//usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						Start
						if(Tname=="Hot")
							src.Temp()
						//else return
						sleep(240)
						goto Start
			brassbar
				icon = 'dmi/64/build.dmi'
				icon_state = "bb"
				name = "Brass Ingot"
				Tname = "Hot"
				description = "Brass Ingot"
				ingot_type = "Brass"
				BB = 1
				//layer = 11
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #ffd700><center><b>Brass Ingot:</b><br>Utilized for smithing.<br>Temperature: [Tname]"
					//usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						Start
						if(Tname=="Hot")
							src.Temp()
						//else return
						sleep(240)
						goto Start
			bronzebar
				icon = 'dmi/64/build.dmi'
				icon_state = "brb"
				name = "Bronze Ingot"
				Tname = "Hot"
				description = "Bronze Ingot"
				ingot_type = "Bronze"
				BRB = 1
				//layer = 11
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "<center>\  <IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #8C7853><br><b>Bronze Ingot:</b><br>Utilized for smithing.<br>Temperature: [Tname]"
					//usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						Start
						if(Tname=="Hot")
							src.Temp()
						//else return
						sleep(240)
						goto Start
			steelbar
				icon = 'dmi/64/build.dmi'
				icon_state = "sb"
				name = "Steel Ingot"
				Tname = "Hot"
				description = "Steel Ingot"
				var/canbefolded = 1
				ingot_type = "Steel"
				STLB = 1
				//layer = 11
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #c0c0c0><center><b>Steel Ingot:</b><br>Utilized for smithing.<br>Temperature: [Tname]"
					//usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						Start
						if(Tname=="Hot")
							src.Temp()
						//else return
						sleep(240)
						goto Start
			damascussteelbar
				icon = 'dmi/64/build.dmi'
				icon_state = "dsb"
				name = "Damascus Steel Ingot"
				Tname = "Hot"
				description = "Damascus Steel Ingot"
				//var/isfolded = 1
				ingot_type = "Damascus Steel"
				DSTLB = 1
				//layer = 11
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #c0c0c0><center><b>Damascus Steel Ingot:</b><br>Utilized for smithing.<br>Temperature: [Tname]"
					//usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						Start
						if(Tname=="Hot")
							src.Temp()
						//else return
						sleep(240)
						goto Start


mob/players/proc
	MNLvl()
		if(mrank>=5)				//Seeing if usr is maxlvl
			MAXmrankLVL=1
			mrank=5
			mrankMAXEXP = mrankEXP					//mrank Lvl Proc		for when you gain lvls.
		if(MAXmrankLVL==1)	//If your woodcutting lvl is max... Return, cant gain anymore lvls greedy bastard!
			return
		else					//Else!!!
			if(mrankEXP>=mrankMAXEXP)		//Does the usr have the req exp for the next lvl?/?
				mrankMAXEXP+=exp2lvl(mrank)	//If he did then here it adds the next MaxExp to his maxexp for the next lvl gain
				mrank++							//mrank lvl +1
				src<<"You gain \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Mining Acuity!"

				MNLvl()			//Calls the WCLvl() proc again to see if the usr gained two lvls in on one tree or not...
				return

var/global/orestage
obj/Rocks							//Simple right??? Just defining objects, Trees!
	//icon='dmi/64/creation.dmi'
	//icon_state="iron"

				//This makes it so we can make a Minimum log amount and a max log amount
	var										//So each tree doesn't always have the same amount of logs each time...
											//So it's random between the set numbers...
		orestate
		//obj/items/iron	//Defines the certain log thats going to be made.
		OreAmount	//Logs in the trees...
		Rarity		//Basically how hard is it to hit the tree?
		MinOre		//Minimum logs in tree
		MaxOre		//Max logs that can be in tree
		GiveXP		//Exp tree gives!
		OreType		//Log type, What log does the tree give...  Its really just for Text purposes.
		spawntime	//How long does it take for the tree to respawn???
		mreq		//mrank lvl required to chop tree down...
		otype		//Ore type, Rock or Cliff
		//di
		ExtraOre
		isn
		gem
	New()
		..()
		orelist+=src
		if(src.OreAmount==null)
			src.OreAmount = rand(src.MinOre,src.MaxOre)
	Del()
		//orelist-=src
		..()


			//icon_state = "water"
			//verbs += /turf/water/verb/Fill_
			//verbs += /turf/water/verb/Fish
			//verbs += /turf/water/verb/Quench
			//name = "Water"
	proc
		Orestateload()
			if(istype(src, /obj/Rocks))
				if(src.orestate==0&src.OreAmount==0)
					src.OreAmount=rand(MinOre,MaxOre)
				if(src.orestate==1)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
					if(otype=="Rock")
						src.icon_state="erock"
					if(istype(src, /obj/Rocks/Cliffs))
						//for(src)
						var/obj/new_cliff = new /obj/Rocks/Cliffs/Empty (loc)
						new_cliff.icon_state = icon_state
						var/turf/t = loc
						if(istype(t))
							t.vis_contents = null
							t.density = 0
				else return
	OreRocks
		//layer = FLOAT_LAYER
		layer = 10
		proc/SetWSeason()
			//if(otype=="Rock")

			if(global.season=="Winter")
				//density=0
				//icon_state += " ramp"
				var/w = "[isn]"
				var/ww = "wint"
				icon_state = "[w][ww]"
				if(OreAmount<=0)
					src.overlays -= overlays
					icon_state = "erock"
					//return
				//icon_state += " wint"
				//plane = 2
				//verbs -= /turf/water/verb/Fill_
				//verbs -= /turf/water/verb/Fish
				//verbs -= /turf/water/verb/Quench
				//name = "Ice"
			else if(global.season!="Winter")
				//density = 1
				icon_state = "[src.isn]"
				if(OreAmount<=0)
					src.overlays -= overlays
					icon_state = "erock"
					//return
		DblClick()
			var/mob/players/M
			M = usr
			//if(!(src in range(1, usr))) return
			//if(M.char_class<>"Builder"&&"GM")
			//	M<<"You need to be a Builder to mine."
				//return
			if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)
			//if(!(src in range(2, usr)))
			//if(get_step_away(src,usr,3))
				M<<"You need to be closer to \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>mine."
				return
			else
				//if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)		//Makes sure the person is right beside the tree and facing it.
				if(src in range(1, usr))
					if(M.mrank<src.mreq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
						M<<"<FONT COLOR=RED>You must have a mining acuity of at least [mreq] to mine [OreType] rocks.</FONT>"
						return
					if(Mining==1)		//This is saying if usr is already cuttin a tree...
						return
					if(M.stamina==0)		//Is your stamina to low???
						M<<"You're too tired to do anything! Drink \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Filledjar'>Water."
						return
					if(M.UPKequipped==1)			//Does the usr have a Axe to cut with?
						M<<"You need an \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Iron Pickaxe to mine this."
						return
					if(M.PXequipped==0)			//Does the usr have a Axe to cut with?
						M<<"You need an \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'> Iron Pickaxe equipped."
						return
					if(OreAmount>=1&&M.PXequipped==1)
						Mine(M)		//Calls the Mine() proc
						return
					else
						if(OreAmount<=0&&M.PXequipped==1)
							M<<"These \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.OreType] Rocks have been depleted of [src.OreType]."
							src.overlays -= overlays
							src.icon_state="erock"
							return
						//..()
					..()
		proc/Mine(mob/players/Miner)
			set waitfor = 0
			var/mob/players/M
			var/gem=list(	/obj/items/Ore/Gems/Ruby,
									/obj/items/Ore/Gems/Sapphire,
									/obj/items/Ore/Gems/Topaz,
									/obj/items/Ore/Gems/Emerald,
									/obj/items/Ore/Gems/Onyx,
									/obj/items/Ore/Gems/Tourmaline,
									/obj/items/Ore/Gems/Quartz,
									/obj/items/Ore/Gems/Carnelian,
									/obj/items/Ore/Gems/Chrysolite,
									/obj/items/Ore/Gems/LapisLazuli,
									/obj/items/Ore/Gems/Turquoise,
									/obj/items/Ore/Gems/Beryl,

									/obj/items/Ore/Gems/Diamond
								)
			var/gempick = pick(gem)
			var/stone=/obj/items/Ore/stone
			M = Miner		//Makes the usr become Miner... Not really neccesary.
			//var/mr = "[src.mreq]"
			//if(mrank<mreq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
				//M<<"<FONT COLOR=RED>You must have a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'> mining acuity of at least [mr] to mine [OreType] rocks.</FONT>"
				//return
			/*if(OreAmount==0)		//Does the tree have logs???
				M<<"It's not worthwhile."
				return	*/			//If no... Return!
			if(M.PXequipped==0)			//Does the usr have a Axe to cut with?
				Miner<<"You need an \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'> Iron Pickaxe equipped."
				return
			M<<"You begin to work on the [OreType] rocks with your \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Pickaxe."			//YAY YOU're CUTTING!!!
			M.overlays += image('dmi/64/PXoy.dmi',icon_state="[get_dir(M,src)]")
			if(M.stamina<=5)			//Calling this again... Some screwy stuff could happen.
				M<<"Your stamina is too low."
				return
			if(Mining==1)
				return
							//Setting this to one because the usr is cutting a tree now.
			sleep(10)				//Sleeps about 2.5 seconds...
			if(OreAmount==0)		//If log amount being called again...
				M<<"These rocks have already been mined."
				Mining=0
				//SetWSeason()
				src.overlays -= overlays
				src.icon_state="erock"
				return
			else
				if(M.PXequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
					Miner<<"You need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'> Pickaxe to use it on the [OreType] rocks."
					return
				/*if (M.stamina < 5)
					M << "Low stamina."*/
				else
					Mining=1
					M.stamina -= 5	//Depletes one stamina
					M.updateST()
					sleep(5)
					if(prob(Rarity+M.mrank))		//Takes the rarity of the tree and your woodcutting lvl
						Miner<<"You Finish working the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> [OreType] rocks and receive [OreType] Ore!"		//You get "tree being cut" Logs!
						M.overlays -= image('dmi/64/PXoy.dmi',icon_state="[get_dir(M,src)]")
						new ore(M)		//Remember ore=obj/items/Logs/Oak???  Heres where this creates a log into invetory
						if(prob(1))
							new gempick(M)
						M.mrankEXP+=GiveXP				//  Add The exp from tree to you.
						Miner.MNLvl()						//Calls the WCLvl() Proc to see if person got lvl...
						Mining=0							// Mining is set to 0 so you are free to move and cut some more.
						//OreAmount--							//Depletes one log from the Amount.
						if(src.OreAmount>=1)
							OreAmount--
						else if(src.OreAmount<=0)
							src.overlays -= overlays
							SetWSeason()
							icon_state="erock"
							return
						//if(OreAmount<=0)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
							//orestate = 1
							//src.overlays -= overlays

						return
					else
						M.overlays -= image('dmi/64/PXoy.dmi',icon_state="[get_dir(M,src)]")
						Miner<<"You \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>mine some stone!"
						new stone(M)
						sleep(10)
						Mining=0
						return

		SRocks
			density=1
			icon='dmi/64/creation.dmi'
			icon_state="srock"
			name = "Stone Rocks"
			//plane = MOB_LAYER+1
			otype = "Rock"
			MinOre=3
			MaxOre=5
			orestate = null
			isn = "srock"
			ore=/obj/items/Ore/iron	//Same here...
			OreAmount=null
			Rarity=90
			GiveXP=1
			spawntime=2420
			mreq=0
			OreType= "Stone"
			ExtraOre= "Iron"

			DblClick()
				var/mob/players/M = usr

					//if(!(src in range(1, usr))) return
					//if(M.char_class<>"Builder"&&"GM")
					//	M<<"You need to be a Builder to mine."
						//return
				//var/obj/items/tools/UeikPickaxe/UPK = locate() in M.contents
				if(M.PXequipped==1)
					Mine(M)
					return
				if(M.UPKequipped==1)
					if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)
					//if(!(src in range(2, usr)))
					//if(get_step_away(src,usr,3))
						M<<"You need to be closer to \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='UeikPickAxe'>mine."
						return
					else
						//if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)		//Makes sure the person is right beside the tree and facing it.
						if(src in range(1, usr))
							if(Mining==1)		//This is saying if usr is already cuttin a tree...
								return
							if(M.stamina==0)		//Is your stamina to low???
								M<<"You're too tired to do anything! Drink \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Filledjar'>Water."
								return
							if(M.UPKequipped==0)			//Does the usr have a Axe to cut with?
								M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='UeikPickAxe'>Ueik PickAxe equipped."
								return
							if(OreAmount>=1&&M.UPKequipped==1)
								Mine(M)		//Calls the Mine() proc
								return
							else
								if(OreAmount<=0&&M.UPKequipped==1)
									src.overlays -= overlays
									SetWSeason()
									icon_state="erock"
									M<<"These \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Rocks have been depleted."
									return
								..()
							..()
				else
					M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='UeikPickAxe'>Ueik Pickaxe equipped to continue..."
		IRocks
			density=1
			icon='dmi/64/creation.dmi'
			icon_state="irock"
			name = "Iron Rocks"
			//plane = MOB_LAYER+1
			otype = "Rock"
			MinOre=5
			MaxOre=10
			orestate = null
			ore=/obj/items/Ore/iron	//Same here...
			OreAmount=null
			isn = "irock"
			Rarity=80
			GiveXP=5
			spawntime=5420
			mreq=1
			OreType= "Iron"

		ZRocks
			density=1
			icon='dmi/64/creation.dmi'
			icon_state="zrock"
			name = "Zinc Rocks"
			//plane = MOB_LAYER+1
			otype = "Rock"
			isn = "zrock"
			MinOre=4
			MaxOre=8
			orestate = null
			ore=/obj/items/Ore/zinc	//Same here...
			OreAmount=null
			Rarity=60
			GiveXP=10
			spawntime=7420
			mreq=3
			OreType= "Zinc"

		CRocks
			density=1
			icon='dmi/64/creation.dmi'
			icon_state="crock"
			name = "Copper Rocks"
			//plane = MOB_LAYER+1
			otype = "Rock"
			isn = "crock"
			MinOre=2
			MaxOre=6
			orestate = null
			ore=/obj/items/Ore/copper	//Same here...
			OreAmount=null
			Rarity=40
			GiveXP=15
			spawntime=9420
			mreq=4
			OreType= "Copper"

		LRocks
			density=1
			icon='dmi/64/creation.dmi'
			icon_state="lrock"
			name = "Lead Rocks"
			//plane = MOB_LAYER+1
			otype = "Rock"
			isn = "lrock"
			MinOre=2
			MaxOre=6
			orestate = null
			ore=/obj/items/Ore/lead	//Same here...
			OreAmount=null
			Rarity=40
			GiveXP=15
			spawntime=8420
			mreq=2
			OreType= "Lead"




	Cliffs
		//var/gem
		SCliff
			density=1
			icon='dmi/64/OreSCliff.dmi'
			//icon_state="[d]"
			name = "Stone Cliff"
			gem = /obj/items/Ore/Gems/Quartz
			layer = 5
			otype = "Cliff"
			MinOre=3
			MaxOre=5
			orestate = null
			ore=/obj/items/Ore/iron	//Same here...
			OreAmount=null
			Rarity=90
			GiveXP=1
			spawntime=2420
			mreq=0
			OreType= "Stone"

			DblClick()
				var/mob/players/M = usr

					//if(!(src in range(1, usr))) return
					//if(M.char_class<>"Builder"&&"GM")
					//	M<<"You need to be a Builder to mine."
						//return
				//var/obj/items/tools/UeikPickaxe/UPK = locate() in M.contents
				if(M.PXequipped==1)
					if(get_dist(src,M)>2&&get_dir(M,src)==M.dir)
					//if(!(src in range(2, usr)))
					//if(get_step_away(src,usr,3))
						M<<"You need to be closer to \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>mine."
						return
					else
						//if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)		//Makes sure the person is right beside the tree and facing it.
						if(src in range(1, usr))
							if(Mining==1)		//This is saying if usr is already cuttin a tree...
								return
							if(M.stamina==0)		//Is your stamina to low???
								M<<"You're too tired to do anything! Drink \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Filledjar'>Water."
								return
							if(M.PXequipped==0)			//Does the usr have a Axe to cut with?
								M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>PickAxe equipped."
								return
							if(OreAmount>=1&&M.PXequipped==1)
								Mine(M)		//Calls the Mine() proc
								return
							else
								if(OreAmount<=0&&M.PXequipped==1)

									M<<"These \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Cliff has been depleted."
									return
								..()
							..()
				else
					M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Pickaxe equipped to continue..."

		ICliff
			density=1
			icon='dmi/64/OreICliff.dmi'
			//icon_state="irock"
			name = "Iron Cliff"
			//plane = MOB_LAYER+1
			gem = /obj/items/Ore/Gems/Ruby
			otype = "Cliff"
			layer = 5
			MinOre=5
			MaxOre=10
			orestate = null
			ore=/obj/items/Ore/iron	//Same here...
			OreAmount=null
			Rarity=80
			GiveXP=5
			spawntime=5420
			mreq=1
			OreType= "Iron"

			DblClick()
				var/mob/players/M = usr

					//if(!(src in range(1, usr))) return
					//if(M.char_class<>"Builder"&&"GM")
					//	M<<"You need to be a Builder to mine."
						//return
				//var/obj/items/tools/UeikPickaxe/UPK = locate() in M.contents
				if(M.PXequipped==1)
					if(get_dist(src,M)>2&&get_dir(M,src)==M.dir)
					//if(!(src in range(2, usr)))
					//if(get_step_away(src,usr,3))
						M<<"You need to be closer to \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>mine."
						return
					else
						//if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)		//Makes sure the person is right beside the tree and facing it.
						if(src in range(1, usr))
							if(Mining==1)		//This is saying if usr is already cuttin a tree...
								return
							if(M.stamina==0)		//Is your stamina to low???
								M<<"You're too tired to do anything! Drink \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Filledjar'>Water."
								return
							if(M.PXequipped==0)			//Does the usr have a Axe to cut with?
								M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>PickAxe equipped."
								return
							if(OreAmount>=1&&M.PXequipped==1)
								Mine(M)		//Calls the Mine() proc
								return
							else
								if(OreAmount<=0&&M.PXequipped==1)

									M<<"These \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Cliff has been depleted."
									return
								..()
							..()
				else
					M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Pickaxe equipped to continue..."
		ZCliff
			density=1
			icon='dmi/64/OreZCliff.dmi'
			//icon_state="zrock"
			name = "Zinc Cliff"
			//plane = MOB_LAYER+1
			otype = "Cliff"
			gem = /obj/items/Ore/Gems/Emerald
			layer = 5
			MinOre=4
			MaxOre=8
			orestate = null
			ore=/obj/items/Ore/zinc	//Same here...
			OreAmount=null
			Rarity=60
			GiveXP=10
			spawntime=7420
			mreq=3
			OreType= "Zinc"

			DblClick()
				var/mob/players/M = usr

					//if(!(src in range(1, usr))) return
					//if(M.char_class<>"Builder"&&"GM")
					//	M<<"You need to be a Builder to mine."
						//return
				//var/obj/items/tools/UeikPickaxe/UPK = locate() in M.contents
				if(M.PXequipped==1)
					if(get_dist(src,M)>2&&get_dir(M,src)==M.dir)
					//if(!(src in range(2, usr)))
					//if(get_step_away(src,usr,3))
						M<<"You need to be closer to \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>mine."
						return
					else
						//if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)		//Makes sure the person is right beside the tree and facing it.
						if(src in range(1, usr))
							if(Mining==1)		//This is saying if usr is already cuttin a tree...
								return
							if(M.stamina==0)		//Is your stamina to low???
								M<<"You're too tired to do anything! Drink \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Filledjar'>Water."
								return
							if(M.PXequipped==0)			//Does the usr have a Axe to cut with?
								M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>PickAxe equipped."
								return
							if(OreAmount>=1&&M.PXequipped==1)
								Mine(M)		//Calls the Mine() proc
								return
							else
								if(OreAmount<=0&&M.PXequipped==1)

									M<<"These \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Cliff has been depleted."
									return
								..()
							..()
				else
					M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Pickaxe equipped to continue..."

		CCliff
			density=1
			icon='dmi/64/OreCCliff.dmi'
			//icon_state="crock"
			name = "Copper Cliff"
			//plane = MOB_LAYER+1
			gem = /obj/items/Ore/Gems/Sapphire
			otype = "Cliff"
			layer = 5
			orestate = null
			MinOre=2
			MaxOre=6
			ore=/obj/items/Ore/copper	//Same here...
			OreAmount=null
			Rarity=40
			GiveXP=15
			spawntime=9420
			mreq=5
			OreType= "Copper"

			DblClick()
				var/mob/players/M = usr

					//if(!(src in range(1, usr))) return
					//if(M.char_class<>"Builder"&&"GM")
					//	M<<"You need to be a Builder to mine."
						//return
				//var/obj/items/tools/UeikPickaxe/UPK = locate() in M.contents
				if(M.PXequipped==1)
					if(get_dist(src,M)>2&&get_dir(M,src)==M.dir)
					//if(!(src in range(2, usr)))
					//if(get_step_away(src,usr,3))
						M<<"You need to be closer to \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>mine."
						return
					else
						//if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)		//Makes sure the person is right beside the tree and facing it.
						if(src in range(1, usr))
							if(Mining==1)		//This is saying if usr is already cuttin a tree...
								return
							if(M.stamina==0)		//Is your stamina to low???
								M<<"You're too tired to do anything! Drink \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Filledjar'>Water."
								return
							if(M.PXequipped==0)			//Does the usr have a Axe to cut with?
								M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>PickAxe equipped."
								return
							if(OreAmount>=1&&M.PXequipped==1)
								Mine(M)		//Calls the Mine() proc
								return
							else
								if(OreAmount<=0&&M.PXequipped==1)

									M<<"These \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Cliff has been depleted."
									return
								..()
							..()
				else
					M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Pickaxe equipped to continue..."

		LCliff
			density=1
			icon='dmi/64/OreLCliff.dmi'

			//icon_state="lrock"
			name = "Lead Cliff"
			//plane = MOB_LAYER+1
			otype = "Cliff"
			gem = /obj/items/Ore/Gems/Onyx
			layer = 5
			MinOre=2
			MaxOre=6
			orestate = null
			ore=/obj/items/Ore/lead	//Same here...
			OreAmount=null
			Rarity=40
			GiveXP=15
			spawntime=8420
			mreq=5
			OreType= "Lead"

			DblClick()
				var/mob/players/M = usr

					//if(!(src in range(1, usr))) return
					//if(M.char_class<>"Builder"&&"GM")
					//	M<<"You need to be a Builder to mine."
						//return
				//var/obj/items/tools/UeikPickaxe/UPK = locate() in M.contents
				if(M.PXequipped==1)
					if(get_dist(src,M)>2&&get_dir(M,src)==M.dir)
					//if(!(src in range(2, usr)))
					//if(get_step_away(src,usr,3))
						M<<"You need to be closer to \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>mine."
						return
					else
						//if(get_dist(src,M)>1&&get_dir(M,src)==M.dir)		//Makes sure the person is right beside the tree and facing it.
						if(src in range(1, usr))
							if(Mining==1)		//This is saying if usr is already cuttin a tree...
								return
							if(M.stamina==0)		//Is your stamina to low???
								M<<"You're too tired to do anything! Drink \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Filledjar'>Water."
								return
							if(M.PXequipped==0)			//Does the usr have a Axe to cut with?
								M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>PickAxe equipped."
								return
							if(OreAmount>=1&&M.PXequipped==1)
								Mine(M)		//Calls the Mine() proc
								return
							else
								if(OreAmount<=0&&M.PXequipped==1)

									M<<"These \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Cliff has been depleted."
									return
								..()
							..()
				else
					M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Pickaxe equipped to continue..."


		Empty
			density=0
			icon='dmi/64/OreECliff.dmi'
			//icon_state="crock"
			name = "Empty Cliff"
			//plane = MOB_LAYER+1
			otype = "Cliff"
			layer = 5
			MinOre=0
			MaxOre=0
			ore=null	//Same here...
			OreAmount=0
			Rarity=0
			GiveXP=0
			mreq=0
			OreType= null


		proc/Mine(mob/players/Miner)
			set waitfor = 0
			var/mob/players/M
			var/gem=list(	/obj/items/Ore/Gems/Ruby,
									/obj/items/Ore/Gems/Sapphire,
									/obj/items/Ore/Gems/Topaz,
									/obj/items/Ore/Gems/Emerald,
									/obj/items/Ore/Gems/Onyx,
									/obj/items/Ore/Gems/Tourmaline,
									/obj/items/Ore/Gems/Quartz,
									/obj/items/Ore/Gems/Carnelian,
									/obj/items/Ore/Gems/Chrysolite,
									/obj/items/Ore/Gems/LapisLazuli,
									/obj/items/Ore/Gems/Turquoise,
									/obj/items/Ore/Gems/Beryl,

									/obj/items/Ore/Gems/Diamond
								)
			var/gempick = pick(gem)
			var/stone=/obj/items/Ore/stone
			M = Miner		//Makes the usr become Miner... Not really neccesary.
			var/mr = "[src.mreq]"
			if(M.mrank<mreq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
				M<<"<FONT COLOR=RED>You must have a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'> mining acuity of at least [mr] to mine [OreType] rocks.</FONT>"
				return
			/*if(OreAmount==0)		//Does the tree have logs???
				M<<"It's not worthwhile."
				return	*/			//If no... Return!
			if(M.PXequipped==0)			//Does the usr have a Axe to cut with?
				Miner<<"You need an \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'> Iron Pickaxe equipped."
				return
			M<<"You begin to work on the [OreType] rocks with your \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Pickaxe."			//YAY YOU're CUTTING!!!
			M.overlays += image('dmi/64/PXoy.dmi',icon_state="[get_dir(M,src)]")
			if(M.stamina<=5)			//Calling this again... Some screwy stuff could happen.
				M<<"Your stamina is too low."
				return
			if(Mining==1)
				return
							//Setting this to one because the usr is cutting a tree now.
			sleep(10)				//Sleeps about 2.5 seconds...
			if(OreAmount==0)		//If log amount being called again...
				M<<"You already \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>mined the [OreType]."
				Mining=0
				return
			else
				if(M.PXequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
					Miner<<"You need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'> Pickaxe to use it on the [OreType] rocks."
					return
				/*if (M.stamina < 5)
					M << "Low stamina."*/
				else
					Mining=1
					M.stamina -= 5	//Depletes one stamina
					M.updateST()
					sleep(5)
					if(prob(Rarity+M.mrank))		//Takes the rarity of the tree and your woodcutting lvl
						Miner<<"You Finish working the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> [OreType] rocks and receive [OreType] Ore!"		//You get "tree being cut" Logs!
						M.overlays -= image('dmi/64/PXoy.dmi',icon_state="[get_dir(M,src)]")
						new ore(M)		//Remember ore=obj/items/Logs/Oak???  Heres where this creates a log into invetory
						if(prob(1))
							new gempick(M)
						M.mrankEXP+=GiveXP				//  Add The exp from tree to you.
						Miner.MNLvl()						//Calls the WCLvl() Proc to see if person got lvl...
						Mining=0							// Mining is set to 0 so you are free to move and cut some more.
						//OreAmount--							//Depletes one log from the Amount.
						if(src.OreAmount>=1)
							OreAmount--

						else if(src.OreAmount<=0)
							//for(src)
							var/obj/new_cliff = new /obj/Rocks/Cliffs/Empty (loc)
							new_cliff.icon_state = icon_state
							var/turf/t = loc
							if(istype(t))
								t.vis_contents = null
								t.density = 0
							del src
								//src.icon_state="ecliff"
							//sleep(spawntime)		//Waiting the spawntime you set for your trees
							//src.icon_state= initial(icon_state)		//Makes your trees come back to live
							//OreAmount=rand(MinOre,MaxOre)			//Redefines new OreAmounts.
							return

					else
						M.overlays -= image('dmi/64/PXoy.dmi',icon_state="[get_dir(M,src)]")
						Miner<<"You \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>mine some stone!"
						new stone(M)
						sleep(10)
						Mining=0
						return
/*
obj/Rocks/
	iron
		New()
			OreAmount=rand(MinOre,MaxOre)		//This makes it so we can make a Minimum log amount and a max log amount
		// Growstate is the tree's current 'phase'
		//var/tgrowstate
		icon = 'dmi/64/build.dmi'
		icon_state = "iron"
		density=1
		MinOre=3
		MaxOre=10
		GiveXP=5
		OreAmount
		ore=/obj/items/Ore/iron    //This is basically saying what log will be made when tree is cut...
		Rarity=1
		spawntime=820
		OreType= "iron"
		mreq=1

	zinc
		New()
			OreAmount=rand(MinOre,MaxOre)		//This makes it so we can make a Minimum log amount and a max log amount
		// Growstate is the tree's current 'phase'
		//var/tgrowstate
		icon = 'dmi/64/build.dmi'
		icon_state = "zinc"
		density=1
		MinOre=4
		MaxOre=8
		GiveXP=10
		OreAmount
		ore=/obj/items/Ore/zinc    //This is basically saying what log will be made when tree is cut...
		Rarity=1
		spawntime=1220
		OreType= "zinc"
		mreq=1

	copper
		New()
			OreAmount=rand(MinOre,MaxOre)		//This makes it so we can make a Minimum log amount and a max log amount
		// Growstate is the tree's current 'phase'
		//var/tgrowstate
		icon = 'dmi/64/build.dmi'
		icon_state = "copper"
		density=1
		MinOre=3
		MaxOre=6
		GiveXP=15
		OreAmount
		ore=/obj/items/Ore/copper    //This is basically saying what log will be made when tree is cut...
		Rarity=1
		spawntime=1420
		OreType= "copper"
		mreq=1*/
