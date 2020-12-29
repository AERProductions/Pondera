var
	mrank=1			//mrank lvl mining rank
	mrankEXP=0		//mrank Exp
	mrankMAXEXP=10		//Exp till level
	MAXmrankLVL=0	//Maxmranklvl when set to one it stops more lvls...
	orelist[0]
mob/var
	tmp
		Mining=0			//Defines cutting.
obj
	items
		Ore
			can_stack = TRUE
			ore = 1
			//var/stack = 1
			Tname="Cool"

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
				layer = 6
				//stack = 1
				ore = 1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Iron Ore:</b> Can be smelted into ingots for metalwork.<br>"
					return
			zinc
				icon = 'dmi/64/build.dmi'
				icon_state = "zinc"
				name = "Zinc Ore"
				description = "Zinc Ore"
				layer = 6
				//stack = 1
				ore = 1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Zinc Ore:</b> Can be smelted into ingots for metalwork.<br>"
					return
			copper
				icon = 'dmi/64/build.dmi'
				icon_state = "copper"
				name = "Copper Ore"
				description = "Copper Ore"
				layer = 6
			//	stack = 1
				ore = 1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Copper Ore:</b> Can be smelted into ingots for metalwork.<br>"
					return
			lead
				icon = 'dmi/64/build.dmi'
				icon_state = "lead"
				name = "Lead Ore"
				description = "Lead Ore"
				layer = 6
				//stack = 1
				ore = 1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Lead Ore:</b> Can be smelted into ingots for metalwork.<br>"
					return
			stone
				icon = 'dmi/64/build.dmi'
				icon_state = "stone"
				name = "Stone Ore"
				description = "Stone Ore"//stone needs a tool like chisel to create stone bricks for stone buildings, grinding stones for wheat, statues/etc
			//	stack = 1
				layer = 6
				ore = 1
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Stone Ore:</b> Can be chiseled for stonework.<br>"
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
					//if(energy<=0)
					//	M<<"You are too tired."
					//	return
					if(M.CHequipped==1)
						if(M.energy==0)		//Is your energy to low???
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
	//items
		Ingots
			can_stack = TRUE
			ore = 1
			Tname = ""
			var

				IB
				ZB
				CB
				LB
				BB
				BRB
				STLB
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
			proc
				Temp(obj/items/Ingots/J)
					set waitfor = 0
					set background = 1
					//set src in usr
					//var/obj/J = src
					//if((CB in M.contents)&&(CB.Tname == "Hot"))
					for(J)
						if(J.Tname=="Hot")
							sleep(240)
							J.Tname = "Warm"
							usr << "[J] is warm."
							sleep(120)
							J.Tname = "Cool"
							usr << "[J] has cooled."
							return
				STemp(obj/items/Ingots/Scraps/J)
					set waitfor = 0
					set background = 1
					//set src in usr
					//var/obj/J = src
					//if((CB in M.contents)&&(CB.Tname == "Hot"))
					for(J)
						if(J.Tname=="Hot")
							sleep(240)
							J.Tname = "Warm"
							usr << "[J] is warm."
							sleep(120)
							J.Tname = "Cool"
							usr << "[J] has cooled."
							return
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
									var/random/R = rand(1,10)
									if(R!=7)
										M<<"You start to combine..."
										J.RemoveFromStack(4)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining."
										new /obj/items/Ingots/ironbar(src)
										return
									else
										J.RemoveFromStack(4)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining."
										return
								else
									M<<"You need at least 4 scrap iron to combine."
							if("Scrap Zinc")
								if(J.stack_amount>=4)
									var/random/R = rand(1,9)
									if(R!=5)
										J.RemoveFromStack(4)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining."
										new /obj/items/Ingots/zincbar(src)
										return
									else
										J.RemoveFromStack(4)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining."
										return
								else
									M<<"You need at least 4 scrap zinc to combine."
							if("Scrap Lead")
								if(J.stack_amount>=4)
									var/random/R = rand(1,8)
									if(R!=6)
										J.RemoveFromStack(4)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining."
										new /obj/items/Ingots/leadbar(src)
										return
									else
										J.RemoveFromStack(4)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining."
										return
								else
									M<<"You need at least 4 scrap lead to combine."
							if("Scrap Copper")
								if(J.stack_amount>=4)
									var/random/R = rand(1,7)
									if(R!=4)
										J.RemoveFromStack(4)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining."
										new /obj/items/Ingots/copperbar(src)
										return
									else
										J.RemoveFromStack(4)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining."
										return
								else
									M<<"You need at least 4 scrap copper to combine."
							if("Scrap Brass")
								if(J.stack_amount>=4)
									var/random/R = rand(1,5)
									if(R!=2)
										J.RemoveFromStack(4)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining."
										new /obj/items/Ingots/brassbar(src)
										return
									else
										J.RemoveFromStack(4)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining."
										return
								else
									M<<"You need at least 4 scrap brass to combine."
							if("Scrap Bronze")
								if(J.stack_amount>=4)
									var/random/R = rand(1,5)
									if(R!=3)
										J.RemoveFromStack(4)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining."
										new /obj/items/Ingots/bronzebar(src)
										return
									else
										J.RemoveFromStack(4)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining."
										return
								else
									M<<"You need at least 4 scrap bronze to combine."
							if("Scrap Steel")
								if(J.stack_amount>=4)
									var/random/R = rand(1,5)
									if(R!=3)
										J.RemoveFromStack(4)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining."
										new /obj/items/Ingots/steelbar(src)
										return
									else
										J.RemoveFromStack(4)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining."
										return
								else
									M<<"You need at least 4 scrap bronze to combine."
									return
					else
						M<<"Needs to be Hot."
						return
			Scraps
				can_stack = TRUE
				verb
					Combine()
						set popup_menu = 1
						set src in oview(1)
						set category = null//"Commands"
						//var/mob/players/M
						Combine_Scrap()
				scrapiron
					icon = 'dmi/64/build.dmi'
					icon_state = "sci"
					name = "Scrap Iron"
					description = "Scrap Iron"

					plane = 7
					verb/Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Scrap Iron:</b> Scrap metal can be combined to form a new ingot.<br>"
						usr << src.Tname
						return
					New()
						set waitfor = 0
						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.STemp() // start the spawn calls
							sleep(80)
				scrapzinc
					icon = 'dmi/64/build.dmi'
					icon_state = "scz"
					name = "Scrap Zinc"
					description = "Scrap Zinc"

					plane = 7
					verb/Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Scrap Zinc:</b> Scrap metal can be combined to form a new ingot.<br>"
						usr << src.Tname
						return
					New()
						set waitfor = 0
						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.STemp() // start the spawn calls
							sleep(80)
				scraplead
					icon = 'dmi/64/build.dmi'
					icon_state = "scl"
					name = "Scrap Lead"
					description = "Scrap Lead"

					plane = 7
					verb/Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Scrap Lead:</b> Scrap metal can be combined to form a new ingot.<br>"
						usr << src.Tname
						return
					New()
						set waitfor = 0
						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.STemp() // start the spawn calls
							sleep(80)
				scrapcopper
					icon = 'dmi/64/build.dmi'
					icon_state = "scc"
					name = "Scrap Copper"
					description = "Scrap Copper"

					plane = 7
					verb/Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Scrap Copper:</b> Scrap metal can be combined to form a new ingot.<br>"
						usr << src.Tname
						return
					New()
						set waitfor = 0
						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.STemp() // start the spawn calls
							sleep(80)
				scrapbrass
					icon = 'dmi/64/build.dmi'
					icon_state = "scb"
					name = "Scrap Brass"
					description = "Scrap Brass"

					plane = 7
					verb/Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Scrap Brass:</b> Scrap metal can be combined to form a new ingot.<br>"
						usr << src.Tname
						return
					New()
						set waitfor = 0
						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.STemp() // start the spawn calls
							sleep(80)
				scrapbronze
					icon = 'dmi/64/build.dmi'
					icon_state = "scbr"
					name = "Scrap Bronze"
					description = "Scrap Bronze"

					plane = 7
					verb/Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Scrap Bronze:</b> Scrap metal can be combined to form a new ingot.<br>"
						usr << src.Tname
						return
					New()
						set waitfor = 0
						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.STemp() // start the spawn calls
							sleep(80)
				scrapsteel
					icon = 'dmi/64/build.dmi'
					icon_state = "scs"
					name = "Scrap Steel"
					description = "Scrap Steel"

					plane = 7
					verb/Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Scrap Steel:</b> Scrap metal can be combined to form a new ingot.<br>"
						usr << src.Tname
						return
					New()
						set waitfor = 0
						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.STemp() // start the spawn calls
							sleep(80)
			ironbar
				icon = 'dmi/64/build.dmi'
				icon_state = "ib"
				name = "Iron Ingot"
				Tname = ""
				description = "Pure Iron Ingot;"

				IB = 1
				plane = 7
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Iron Ingot:</b> Utilized for smithing.<br>"
					usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						src.Temp() // start the spawn calls
						sleep(180)
			zincbar
				icon = 'dmi/64/build.dmi'
				icon_state = "zb"
				name = "Zinc Ingot"
				Tname = ""
				description = "Pure Zinc Ingot;"

				ZB = 1
				plane = 7
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Zinc Ingot:</b> Utilized for smithing.<br>"
					usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						src.Temp() // start the spawn calls
						sleep(180)
			copperbar
				icon = 'dmi/64/build.dmi'
				icon_state = "cb"
				name = "Copper Ingot"
				Tname = ""
				description = "Pure Copper Ingot;"

				CB = 1
				plane = 7
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Copper Ingot:</b> Utilized for smithing.<br>"
					usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						src.Temp() // start the spawn calls
						sleep(180)
			leadbar
				icon = 'dmi/64/build.dmi'
				icon_state = "lb"
				name = "Lead Ingot"
				Tname = ""
				description = "Pure Lead Ingot;"

				LB = 1
				plane = 7
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Lead Ingot:</b> Utilized for smithing.<br>"
					usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						src.Temp() // start the spawn calls
						sleep(180)
			brassbar
				icon = 'dmi/64/build.dmi'
				icon_state = "bb"
				name = "Brass Ingot"
				Tname = ""
				description = "Brass Ingot;"

				BB = 1
				plane = 7
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Brass Ingot:</b> Utilized for smithing.<br>"
					usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						src.Temp() // start the spawn calls
						sleep(180)
			bronzebar
				icon = 'dmi/64/build.dmi'
				icon_state = "brb"
				name = "Bronze Ingot"
				Tname = ""
				description = "Bronze Ingot;"

				BRB = 1
				plane = 7
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Bronze Ingot:</b> Utilized for smithing.<br>"
					usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						src.Temp() // start the spawn calls
						sleep(180)
			steelbar
				icon = 'dmi/64/build.dmi'
				icon_state = "sb"
				name = "Steel Ingot"
				Tname = ""
				description = "Steel Ingot;"

				STLB = 1
				plane = 70
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <font color = #8C7853><center><b>Steel Ingot:</b> Utilized for smithing.<br>"
					usr << src.Tname
					return
				New()
					set waitfor = 0
					..()
						// initialize the list of mobs to be spawned
					spawn while (src) // More efficient to put in a loop like Deadron's event loop
						src.Temp() // start the spawn calls
						sleep(180)


mob/proc
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
	New()
		..()
		orelist+=src
		if(src.OreAmount==null)
			src.OreAmount = rand(src.MinOre,src.MaxOre)
	Del()
		//orelist-=src
		..()
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

	SRocks
		density=1
		icon='dmi/64/creation.dmi'
		icon_state="srock"
		name = "Stone"
		plane = MOB_LAYER+1
		otype = "Rock"
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
						if(M.energy==0)		//Is your energy to low???
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
		name = "Rock"
		plane = MOB_LAYER+1
		otype = "Rock"
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

	ZRocks
		density=1
		icon='dmi/64/creation.dmi'
		icon_state="zrock"
		name = "ZRock"
		plane = MOB_LAYER+1
		otype = "Rock"
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
		name = "CRock"
		plane = MOB_LAYER+1
		otype = "Rock"
		MinOre=2
		MaxOre=6
		orestate = null
		ore=/obj/items/Ore/copper	//Same here...
		OreAmount=null
		Rarity=40
		GiveXP=15
		spawntime=9420
		mreq=5
		OreType= "Copper"

	LRocks
		density=1
		icon='dmi/64/creation.dmi'
		icon_state="lrock"
		name = "LRock"
		plane = MOB_LAYER+1
		otype = "Rock"
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


	Gems
		Ruby
			icon='dmi/64/gemstones.dmi'
			icon_state="Ruby"
		Sapphire
			icon='dmi/64/gemstones.dmi'
			icon_state="Sapphire"
		Topaz
			icon='dmi/64/gemstones.dmi'
			icon_state="Topaz"
		Diamond
			icon='dmi/64/gemstones.dmi'
			icon_state="Diamond"
		Quartz
			icon='dmi/64/gemstones.dmi'
			icon_state="Quartz"
		Emerald
			icon='dmi/64/gemstones.dmi'
			icon_state="Emerald"
		Onyx
			icon='dmi/64/gemstones.dmi'
			icon_state="Onyx"
		Tourmaline
			icon='dmi/64/gemstones.dmi'
			icon_state="Tourmaline"
		Carnelian
			icon='dmi/64/gemstones.dmi'
			icon_state="Carnelian"
		Chrysolite
			icon='dmi/64/gemstones.dmi'
			icon_state="Chrysolite"
		LapisLazuli
			icon='dmi/64/gemstones.dmi'
			icon_state="LapisLazuli"
		Turquoise
			icon='dmi/64/gemstones.dmi'
			icon_state="Turquoise"
		Beryl
			icon='dmi/64/gemstones.dmi'
			icon_state="Beryl"


	Cliffs
		var/gem
		SCliff
			density=1
			icon='dmi/64/OreSCliff.dmi'
			//icon_state="[d]"
			name = "Stone Cliff"
			gem = /obj/Rocks/Gems/Quartz
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
							if(M.energy==0)		//Is your energy to low???
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
			gem = /obj/Rocks/Gems/Ruby
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
							if(M.energy==0)		//Is your energy to low???
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
			gem = /obj/Rocks/Gems/Emerald
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
							if(M.energy==0)		//Is your energy to low???
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
			gem = /obj/Rocks/Gems/Sapphire
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
							if(M.energy==0)		//Is your energy to low???
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
			gem = /obj/Rocks/Gems/Onyx
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
							if(M.energy==0)		//Is your energy to low???
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



	DblClick()
		var/mob/players/M = usr
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
				if(Mining==1)		//This is saying if usr is already cuttin a tree...
					return
				if(M.energy==0)		//Is your energy to low???
					M<<"You're too tired to do anything! Drink \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Filledjar'>Water."
					return
				if(M.UPKequipped==1)			//Does the usr have a Axe to cut with?
					M<<"You need an \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Iron PickAxe to mine this."
					return
				if(M.PXequipped==0)			//Does the usr have a Axe to cut with?
					M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>PickAxe equipped."
					return
				if(OreAmount>=1&&M.PXequipped==1)
					Mine(M)		//Calls the Mine() proc
					return
				else
					if(OreAmount<=0&&M.PXequipped==1)
						M<<"These \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.OreType] Rocks have been depleted of [src.OreType]."
						return
					..()
				..()
	proc/Mine(mob/Miner)
		set waitfor = 0
		var/mob/players/M
		var/gem=list(	/obj/Rocks/Gems/Ruby,
								/obj/Rocks/Gems/Sapphire,
								/obj/Rocks/Gems/Topaz,
								/obj/Rocks/Gems/Emerald,
								/obj/Rocks/Gems/Onyx,
								/obj/Rocks/Gems/Tourmaline,
								/obj/Rocks/Gems/Quartz,
								/obj/Rocks/Gems/Carnelian,
								/obj/Rocks/Gems/Chrysolite,
								/obj/Rocks/Gems/LapisLazuli,
								/obj/Rocks/Gems/Turquoise,
								/obj/Rocks/Gems/Beryl,

								/obj/Rocks/Gems/Diamond
							)
		var/stone=/obj/items/Ore/stone
		M = Miner		//Makes the usr become Miner... Not really neccesary.
		if(mrank<mreq)			//If usrs woodcutting lvl isnt greater than or equal to lvl req return
			M<<"<FONT COLOR=RED>You must have a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>mining acuity of at least [src:mreq] to mine [src.OreType] rocks.</FONT>"
			return
		/*if(OreAmount==0)		//Does the tree have logs???
			M<<"It's not worthwhile."
			return	*/			//If no... Return!
		if(M.PXequipped==0)			//Does the usr have a Axe to cut with?
			Miner<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>PickAxe equipped."
			return
		M<<"You begin to work on the [src.OreType] rocks with your \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>PickAxe."			//YAY YOU're CUTTING!!!
		M.overlays += image('dmi/64/PXoy.dmi',icon_state="[get_dir(M,src)]")
		if(M.energy<=5)			//Calling this again... Some screwy stuff could happen.
			M<<"Your energy is too low."
			return
		if(Mining==1)
			return
		Mining=1				//Setting this to one because the usr is cutting a tree now.
		sleep(10)				//Sleeps about 2.5 seconds...
		if(OreAmount==0)		//If log amount being called again...
			M<<"You already \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>mined the [src.OreType]."
			Mining=0
			return
		else
			if(M.PXequipped==0)// Calling this again cause players like to drop axes just to see what will happen while they cut...
				Miner<<"You need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>PickAxe to use it on the [src.OreType] rocks."
				return
			/*if (M.energy < 5)
				M << "Low energy."*/
			else
				M.energy -= 5	//Depletes one energy
				M.updateEN()
				if(prob(Rarity+mrank))		//Takes the rarity of the tree and your woodcutting lvl
					Miner<<"You Finish working the <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.OreType] rocks and receive [src.OreType] Ore!"		//You get "tree being cut" Logs!
					M.overlays -= image('dmi/64/PXoy.dmi',icon_state="[get_dir(M,src)]")
					new ore(M)		//Remember ore=obj/items/Log/Oak???  Heres where this creates a log into invetory
					if(prob(1))
						new gem(M)
					mrankEXP+=GiveXP				//  Add The exp from tree to you.
					Miner.MNLvl()						//Calls the WCLvl() Proc to see if person got lvl...
					Mining=0							// Mining is set to 0 so you are free to move and cut some more.
					OreAmount--							//Depletes one log from the Amount.
					if(OreAmount<=0)			//After you cut the tree is the Log Amount 0??? If yes change icon to tree stump.
						orestate = 1
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
