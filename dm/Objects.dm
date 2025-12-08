mob/var
	smithm[1]
	smitht[1]
	smithw[1]
	smithae[1]
	smithad[1]
	smithao[1]
	smithl[1]
	smith[1]
	//CL[1]
	PCL[1]
var
	sme
	smelt[1]
obj
	vitae
		icon_state = "vitae"
		layer = MOB_LAYER+1

/*obj
	lucre
		icon = 'dmi/64/lc.dmi'
		verb
			Get()
				set hidden = 1
				set src in oview(1)
				src.Move(usr)
			Drop()
				set hidden = 1
				set src in usr
				var/numb = input("Drop Lucre","Amount") as num // how much?!
				var/lucre
				if (numb>0) // gotta check and be sure it is a player, and that you aren't trying to steal their lucre with a negative value
					//if(M==usr) // you can't give lucre to yourself
					//	return // we'll just leave this function without even the grace of telling yourself that (seeing as we don't have a cancel button i think this is a good thing
					if (lucre >= numb) // gotta make sure you have the lucre you want to give
						//M.lucre-=numb // let em have it
						lucre-=numb // and take it from you
						//tell everyone what just happened
						//M << "\green<b>[usr]([usr.ckey]) gives you a pouch of [numb] Lucre."
						src.Move(usr.loc)
						//new lucre(locate(x,y,z))
						usr << "\green<b>You drop a pouch of [numb] Lucre."
					else
						usr << "Your pouch doesn't contain enough."*/
obj
	//var
		//smelt[1]
	items
		Crafting
			Created
				layer = 11
				can_stack = TRUE
				//var/stack = 1
				// Legacy refinement flags (pre-Phase 6)
				// NOTE: RefinementSystem.dm (Phase 6) provides modern replacement via refine_stage
				// These are kept for backwards compatibility with existing code
				var/needssharpening = 0
				var/needsfiled = 0
				var/needspolished = 0
				var/needsquenched = 0
				var/needsfixed = 0
				var/etched = 0
				var/item_type=""
				//var/R
				proc/FindI()
					for(var/obj/items/Crafting/Created/J)// Ingot
						locate(J)
						if(J:Tname=="Hot")
							return J
				proc
					CTemp(obj/items/Crafting/Created/J = FindI(usr))//If I want to do the same thing to this temp check as I did with ingots/scraps I'll need to add a [item_type] var
						set waitfor = 0
						set background = 1
						//var/mob/players/M
						//M = usr
						//set src in usr
						//var/obj/J = src
						//if((CB in M.contents)&&(CB.Tname == "Hot"))
						//while(src)//if(J in M)
						for(J)
							if(Tname=="Hot")
								//src.MergeStack()
								//suffix = "Hot"
								name = "[item_type] (Hot)"
								sleep(240)

								Tname = "Warm"
								//suffix = "Warm"
								//if(J in usr)
								//	usr << "[J] is warm."
								name = "[item_type] (Warm)"
								sleep(120)
								Tname = "Cool"
								name = "[item_type] (Cool)"
								//suffix = "Cool"
								//if(J in usr)
								//	usr << "[J] has cooled."
							else return
						//else return
				/*var
					description
				/*verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << src.description*/
				New()
					stack()
				verb
					Description()
						set category=null
						set popup_menu=1
						set src in usr
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						return
					Get()

						set category=null
						set popup_menu=1
						set src in oview(1)
						//set hidden = 1
						var/mob/players/M = usr
						
						// DEED PERMISSION CHECK: Check if player can pick up items in this deed zone
						if(!CanPlayerPickupAtLocation(M, src.loc))
							M << "You do not have permission to pick up items here."
							return
						
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
					Drop()
						set category=null
						set popup_menu=1
						set src in usr
						var/mob/players/M = usr
						
						// DEED PERMISSION CHECK: Check if player can drop items in this deed zone
						if(!CanPlayerDropAtLocation(M, M.loc))
							M << "You do not have permission to drop items here."
							return
						
						if(src.suffix == "Equipped")
							usr << "<font color = teal>Un-equip [src] first!"
						else
							src.Move(usr.loc)*/
				FishingPoleReel
					icon = 'dmi/64/creation.dmi'
					icon_state = "Reel"
					name = "Iron Reel"
					item_type="Iron Reel"
					Tname="Hot"
					Worth = 15
					needssharpening = 0
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"

					New()
						set waitfor = 0
						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							sleep(240)
				IronNails
					icon = 'dmi/64/creation.dmi'//Iron Ribbon for barrel
					icon_state = "IronNails"
					name = "Iron Nails"
					Worth = 15
					item_type="Iron Nails"
					needssharpening = 0
					needsfiled = 0
					needspolished = 0
					needsquenched = 0
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"

					New()
						set waitfor = 0
						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							sleep(240)
				IronRibbon
					icon = 'dmi/64/creation.dmi'//Iron Ribbon for barrel
					icon_state = "IronRibbon"
					name = "Iron Ribbon"
					Worth = 15
					item_type="Iron Ribbon"
					needssharpening = 0
					needsfiled = 0
					needspolished = 0
					needsquenched = 0
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"

					New()
						set waitfor = 0
						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							sleep(240)
				UeikBoard
					icon = 'dmi/64/creation.dmi'
					icon_state = "UeikBoard"
					name = "Ueik Board"
					item_type="Ueik Board"
					//description = "Stone Bricks"
					//Tname = "Hot"
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b>"

					New()
						..()
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b>  Ueik Board."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					verb/Create_Quench_Box()
						set src in usr
						var/dice = "1d4"
						var/R = roll(dice)
						var/obj/items/Crafting/Created/UeikBoard/J = locate() in usr.contents
						var/obj/items/Crafting/Created/IronRibbon/J2 = locate() in usr.contents
						var/obj/items/Crafting/Created/UeikShingle/J3 = locate() in usr.contents
						if(usr.HMequipped==1)
							if(!J2||!J3)
								if(J.stack_amount>=3&&J2.stack_amount>=2&&J3.stack_amount>=2)
								//if(usr.HMequipped==1)
									if(R>=2)
										J.RemoveFromStack(3)
										J2.RemoveFromStack(2)
										J3.RemoveFromStack(2)
										new /obj/items/tools/Containers/QuenchBox()
										usr << "You manage to put together a Quench Box."
										return
									else
										del src
										//new obj/items/crafting/created/Vessel()
										usr << "This Board isn't suitable."
										return
								else
									usr << "You need 3 Ueik Boards, 2 Iron Ribbons and 2 Ueik Shingles to build a Quench Box."
							else
								usr << "You need 3 Ueik Boards, 2 Iron Ribbons and 2 Ueik Shingles to build a Quench Box."
						else
							usr << "Need to use a Hammer."
							return
					verb/Create_Cask_Boards()
						set src in usr
						var/dice = "1d4"
						var/R = roll(dice)
						var/obj/items/Crafting/Created/UeikBoard/J = locate() in usr.contents
						if(usr.SWequipped==1)
							if(!J)
								if(J.stack_amount>=1)
								//if(usr.HMequipped==1)
									if(R>=2)
										J.RemoveFromStack(1)
										new /obj/items/Crafting/Created/CaskBoard(usr,stack_amount+=2)
										usr << "You Saw some Cask Boards from the Ueik Board."
										return
									else
										del src
										//new obj/items/crafting/created/Vessel()
										usr << "This Board isn't suitable."
										return
								//else
									//usr << "You need Ueik Board."
							else
								usr << "You need Ueik Board."
						else
							usr << "Need to use a Saw."
							return

				CaskBoard
					icon = 'dmi/64/creation.dmi'
					icon_state = "CaskBoard"
					name = "Cask Board"
					item_type="Cask Board"
					//description = "Stone Bricks"
					//Tname = "Hot"
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"

					New()
						..()
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b> Cask Board."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					verb/Create_Barrel()
						set src in usr
						var/dice = "1d4"
						var/R = roll(dice)
						var/obj/items/Crafting/Created/CaskBoard/J = locate() in usr.contents
						var/obj/items/Crafting/Created/IronRibbon/J2 = locate() in usr.contents
						if(usr.HMequipped==1)
							if(!J2)
								if(J.stack_amount>=18&&J2.stack_amount>=10)
								//if(usr.HMequipped==1)
									if(R>=2)
										J.RemoveFromStack(18)
										J2.RemoveFromStack(10)
										new /obj/items/tools/Containers/Barrel()
										usr << "You manage to put together a Barrel."
										return
									else
										del src
										//new obj/items/crafting/created/Vessel()
										usr << "This Board isn't suitable."
										return
								else
									usr << "You need 18 Cask Boards and 10 Iron Ribbons to build a Barrel."
							else
								usr << "You need 18 Cask Boards and 10 Iron Ribbons to build a Barrel."
						else
							usr << "Need to use a Hammer."
							return

				UeikShingle
					icon = 'dmi/64/creation.dmi'
					icon_state = "UeikShingle"
					name = "Ueik Shingle"
					item_type="Ueik Shingle"
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"

					//description = "Stone Bricks"
					//Tname = "Hot"
					New()
						..()
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b>  Ueik Shingle."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				AnvilHead
					icon = 'dmi/64/creation.dmi'
					icon_state = "AnvilHead"
					name = "Iron Anvil Head"
					Tname = "Hot"
					item_type="Anvil Head"
					can_stack=TRUE
					needssharpening = 0
					needsfiled = 0
					needspolished = 0
					needsquenched = 0
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					/*verb/Create_Anvil()
						set src in usr
						set waitfor = 0
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/Mortar/J = locate() in M.contents
						var/obj/items/Logs/UeikLog/J1 = locate() in M.contents
						var/dice = "1d4"
						var/R = roll(dice)
						if(J&&J1)
							if(M.GVequipped==1&&Tname=="Hot"&&needsquenched==0&&needspolished==0&&needssharpening==0)
								if(R>=2)
									new /obj/Buildable/Smithing/Anvil(M.loc)
									M << "You assembled an Anvil!"
									src.RemoveFromStack(1)
									J.RemoveFromStack(5)
									J1.RemoveFromStack(2)
									return
								else
									//new obj/items/crafting/created/Vessel()
									M << "The materials aren't viable and must be discarded."
									//src.RemoveFromStack(1)
									J.RemoveFromStack(5)
									J1.RemoveFromStack(2)
									return
							else if(M.GVequipped==0&&Tname!="Hot")
								M << "Need to use Gloves and the Anvil Head must be Hot. (Temperature: [Tname])"
								return
							else if(needsquenched==1&&needspolished==1&&needssharpening==1)
								M << "Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
								return
						else
							M << "You need 2 Logs and 5 Mortar to assemble an Anvil"*/

					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle to create an <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Axe'>Axe. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls

							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
							//if(!usr.umsl_ObtainMultiLock(list("right leg", "left leg"), 6.0)) return null//attempt to make heavy objects slow the user down -- needs testing TestStamp
							//else return ..()

				Bricks//Maybe add a needschiseled/needsfiled system for stone works?
					icon = 'dmi/64/creation.dmi'
					icon_state = "bricks"
					name = "Bricks"
					item_type="Bricks"
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> Chiseled Stone Bricks that can be used for stonework and masonry."//Maybe do the same thing with smithing? NeedsChiseled?

					//description = "Stone Bricks"
					//Tname = "Hot"
					New()
						..()
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b>  Used with\  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='Mortar'>Mortar and <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='trowel'>Trowel to create Stoneworks. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				CKnifeblade
					icon = 'dmi/64/creation.dmi'
					icon_state = "CKB"
					name = "Carving Knife blade"
					//description = "The Blade of a Carving Knife"
					Tname = "Hot"
					item_type="Carving Knife blade"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsquenched = E
						needsfiled = E
						needspolished = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				SickleBlade
					icon = 'dmi/64/creation.dmi'
					icon_state = "Sickleblade"
					name = "Sickle blade"
					//description = "The curved Blade of a Sickle."
					Tname = "Hot"
					item_type="Sickle blade"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Sickle. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				SawBlade
					icon = 'dmi/64/creation.dmi'
					icon_state = "SawBlade"
					name = "Saw blade"
					//description = "The Blade of a Chisel."
					Tname = "Hot"
					item_type="Saw blade"
					needssharpening = 1
					needsfiled = 0
					needspolished = 0
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Saw'>Saw. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				TrowelBlade
					icon = 'dmi/64/creation.dmi'
					icon_state = "TrowelBlade"
					name = "Trowel blade"
					//description = "The Blade of a Trowel."
					Tname = "Hot"
					item_type="Trowel blade"
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needssharpening = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='trowel'>Trowel. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				FileBlade
					icon = 'dmi/64/creation.dmi'
					icon_state = "FileBlade"
					name = "File blade"
					//description = "The Blade of a Chisel."
					Tname = "Hot"
					item_type="File blade"
					needssharpening=0
					needsfiled = 0
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					color = rgb(81,61,51)
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J)
							if(J.suffix=="Equipped"&&M.FIequipped==1)
								call(/obj/items/tools/File/proc/Fle)()
							else
								M << "You need to use a File to test for hardness."
								return
						else return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='File'>File. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				ChiselBlade
					icon = 'dmi/64/creation.dmi'
					icon_state = "Chiselblade"
					name = "Chisel blade"
					//description = "The Blade of a Chisel."
					Tname = "Hot"
					item_type="Chisel blade"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b>  "
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Chisel'>Chisel. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				HoeBlade
					icon = 'dmi/64/creation.dmi'
					icon_state = "Hoeblade"
					name = "Hoe blade"
					//description = "The flat Blade of a Hoe."
					Tname = "Hot"
					item_type="Hoe blade"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hoe'>Hoe. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				StoneAxehead
					icon = 'dmi/64/creation.dmi'
					icon_state = "StoneAxehead"
					name = "Stone Axe head"
					item_type="Stone Axe head"
					//description = "The sharp Head of an Axe."
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> A rudimentary tool intended for chopping down trees."

				AxeHead
					icon = 'dmi/64/creation.dmi'
					icon_state = "AxeHead"
					name = "Axe head"
					//description = "The sharp Head of an Axe."
					Tname = "Hot"
					item_type="Axe head"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle to create an <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Axe'>Axe. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				PickaxeHead
					icon = 'dmi/64/creation.dmi'
					icon_state = "PickaxeHead"
					name = "Pickaxe head"
					description = "The curved Head of a Pickaxe."
					Tname = "Hot"
					item_type="Pickaxe head"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return

					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Pickaxe. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				HammerHead
					icon = 'dmi/64/creation.dmi'
					icon_state = "HH"
					name = "Hammer head"
					item_type="Hammer head"
					//description = "The blunt Head of an Iron Hammer."
					Tname = "Hot"
					needssharpening = 0
					needsfiled = 0
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					//Quench action verb goes onto the Barrel and Quench Box, not parts
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return

					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"

					New()
						set waitfor = 0
						var/E = rand(1,0)
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle to create an <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Hammer'>Iron Hammer. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
								//src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Quench
							/*else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen*/
								//src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Quench
							sleep(240)
				ShovelHead
					icon = 'dmi/64/creation.dmi'
					icon_state = "Shovelhead"
					name = "Shovel head"
					//description = "The Head of a Shovel."
					Tname = "Hot"
					item_type="Shovel head"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Shovel'>Shovel. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
//Weapon Parts
				Broadswordblade
					icon = 'dmi/64/creation.dmi'
					icon_state = "Broadswordblade"
					name = "Broadsword blade"
					//description = "The Blade of a Broadsword."
					Tname = "Hot"
					item_type="Boardsword blade"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hndl'>Handle to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='BroadSword'>Broadsword. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				Warswordblade
					icon = 'dmi/64/creation.dmi'
					icon_state = "Warswordblade"
					name = "Warsword blade"
					Tname = "Hot"
					item_type="Warsword blade"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hndl'>Handle to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='WarSword'>Warsword. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				Battleswordblade
					icon = 'dmi/64/creation.dmi'
					icon_state = "Battleswordblade"
					name = "Battlesword blade"
					Tname = "Hot"
					item_type="Battlesword blade"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hndl'>Handle to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='BattleSword'>Battlesword. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				Longswordblade
					icon = 'dmi/64/creation.dmi'
					icon_state = "Longswordblade"
					name = "Longsword blade"
					Tname = "Hot"
					item_type="Longsword blade"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hndl'>Handle to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='BattleSword'>Battlesword. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
//WorkStamp need to check these new additions for complete crafting (Combine Handle to these parts to create the weapon)
				Waraxeblade
					icon = 'dmi/64/creation.dmi'
					icon_state = "Waraxeblade"
					name = "War Axe blade"
					Tname = "Hot"
					item_type="Waraxe blade"
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='BattleHammer'>Battlehammer. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)

				Warmaulhead
					icon = 'dmi/64/creation.dmi'
					icon_state = "Warmaulhead"
					name = "War Maul head"
					Tname = "Hot"
					item_type="War maul head"
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='BattleHammer'>Battlehammer. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)

				Battleaxeblade//WorkStamp Need to add the finished weapons to the equip menu, most likely.
					icon = 'dmi/64/creation.dmi'
					icon_state = "Battleaxeblade"
					name = "Battle Axe blade"
					Tname = "Hot"
					item_type="Battle axe blade"
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='BattleHammer'>Battlehammer. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)

				Battlehammersledge
					icon = 'dmi/64/creation.dmi'
					icon_state = "Battlehammersledge"
					name = "Battle Hammer sledge"
					Tname = "Hot"
					item_type="Battle hammer sledge"
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='BattleHammer'>Battlehammer. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)

				Warscytheblade
					icon = 'dmi/64/creation.dmi'
					icon_state = "Warscytheblade"
					name = "War Scythe blade"
					Tname = "Hot"
					item_type="War scythe blade"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='BattleScythe'>Battlescythe. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				Battlescytheblade
					icon = 'dmi/64/creation.dmi'
					icon_state = "Battlescytheblade"
					name = "Battle Scythe blade"
					Tname = "Hot"
					item_type="Battle scythe blade"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='WarScythe'>Warscythe. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)

//Lamp Heads
				WoodenTorchHead
					icon = 'dmi/64/creation.dmi'
					icon_state = "woodentorchhead"
					name = "Wooden Torch Head"
					Tname = "Hot"
					item_type="Wooden Torch Head"
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"

					New()
						set waitfor = 0
						Description()//description = "<br><font color = #8C7853><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='woodentorch'>Wooden Torch. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							sleep(240)

//SleepStamp need to finish setting the file/fir/etc checks for these lamps
				IronLampHead
					icon = 'dmi/64/creation.dmi'
					icon_state = "ironlamphead"
					name = "Iron Lamp Head"
					Tname = "Hot"
					item_type="Iron Lamp Head"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='WarScythe'>Warscythe. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				CopperLampHead
					icon = 'dmi/64/creation.dmi'
					icon_state = "copperlamphead"
					name = "Copper Lamp Head"
					Tname = "Hot"
					item_type="Copper Lamp Head"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='WarScythe'>Warscythe. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				BronzeLampHead
					icon = 'dmi/64/creation.dmi'
					icon_state = "bronzelamphead"
					name = "Bronze Lamp Head"
					Tname = "Hot"
					item_type="Bronze Lamp Head"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='WarScythe'>Warscythe. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				BrassLampHead
					icon = 'dmi/64/creation.dmi'
					icon_state = "brasslamphead"
					name = "Brass Lamp Head"
					Tname = "Hot"
					item_type="Brass Lamp Head"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='WarScythe'>Warscythe. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)
				SteelLampHead
					icon = 'dmi/64/creation.dmi'
					icon_state = "steellamphead"
					name = "Steel Lamp Head"
					Tname = "Hot"
					item_type="Steel Lamp Head"
					needssharpening = 1
					needsfiled = 1
					needspolished = 1
					needsquenched = 1
					needsfixed = 0
					etched = 0
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"
					verb/File()//working, sorta
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						//var/obj/items/UeikFir/J = locate() in M.contents
						var/obj/items/tools/File/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.FIequipped==1)
							call(/obj/items/tools/File/proc/Fle)()
						else
							M << "You need to use a File to test for hardness."
							return
					verb/Polish()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/UeikFir/J = locate() in M.contents
						if(J)
							call(/obj/items/UeikFir/proc/Plish)()
						else
							M << "You need Ueik Fir to polish."
							return
					verb/Sharpen()//working confirmed
						//set src in usr
						set category=null
						set popup_menu=1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Whetstone/J = locate() in M.contents
						if(J.suffix=="Equipped"&&M.WSequipped==1)
							call(/obj/items/tools/Whetstone/proc/Shrpn)()
						else
							M << "You need to use a whetstone to sharpen."
							return
					New()
						set waitfor = 0
						var/E = rand(1,0)
						needssharpening = E
						needsfiled = E
						needspolished = E
						needsquenched = E
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='WarScythe'>Warscythe. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

						..()
							// initialize the list of mobs to be spawned
						spawn while (src) // More efficient to put in a loop like Deadron's event loop
							src.CTemp() // start the spawn calls
							if(src.needspolished==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Polish
							else if(src.needspolished==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Polish
							if(src.needsfiled==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/File
							else if(src.needsfiled==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/File
							if(src.needssharpening==0)
								src:verbs -= /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							else if(src.needssharpening==1)
								src:verbs += /obj/items/Crafting/Created/HammerHead/verb/Sharpen
							sleep(240)

				Clay
					icon = 'dmi/64/inven.dmi'
					icon_state = "clay"
					name = "Clay"
					Tname = "Cool"
					item_type="Clay"
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b> <br>Temperature: [Tname]<br>Needs Quenched: [needsquenched?"Yes":"No"]<br>Needs Filed: [needsfiled?"Yes":"No"]<br>Needs Polished: [needspolished?"Yes":"No"]<br>Needs Sharpened: [needssharpening?"Yes":"No"]"

					//need to set descrip
								//Description()//description = "<br><font color = #e6e8fa><center><b>[name]:</b><br>  Used with\  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole to create a <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='bronzelamp'>Bronze Lamp. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					proc/FindJar(mob/players/M)
						for(var/obj/items/tools/Containers/Jar/J in M.contents)
							locate(J)
							if(J:suffix=="Equipped"&&J:CType=="Sand"&&J:filled==1)
								return J
					verb
						Combine()//fixed 1/21/2024
							set waitfor = 0
							//set src in oview(1)
							set popup_menu = 1
							set category = null
							var/mob/players/M
							M = usr
							var/obj/items/tools/Containers/Jar/J = locate(M.contents)// = FindJar(M.contents)
							//var/random/R = rand(1,5) //1 in 5 chance to smith

							//J = locate(M.contents)
							//for(J in M.contents)
							//locate(J)
								//if(J:suffix=="Equipped"&&J:CType=="Sand"&&J:filled==1)
									//return J
							//if(!J in M.contents)
								//M << "You need a Filled Jar of Sand to combine with Clay to create Mortar..."
								//return
							//if(J in M.contents)
							//locate(J) in M.contents
							for(J in M.contents)
								if(J.suffix=="Equipped"&&J.filled==1&&J.CType=="Sand")
									//input("Create Mortar?","Combine") in list("Yes","No")
									//if("No")
										//return
									//if("Yes")
									//if(J.stack_amount>=1)

										//if(J.name=="Clay")
									var/dice = "1d8"
									var/R = roll(dice)
									if(R>=5)
										locate(J) in M.contents
										M<<"You start to combine the Clay with the Sand..."
										//sleep(5)
										//J.RemoveFromStack(1)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")

										sleep(15)
										for(J in M.contents)
											if(J.suffix=="Equipped"&&J.filled==1&&J.CType=="Sand")
												J.icon_state = "Jar"
												J.volume = 0
												//if(volume<0)
												//	volume=0
												//	M<<"The Jar is empty."
												J.CType="Empty"
												J.name = "Jar"
												J.filled=0

										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining the Clay with the Sand and create Mortar."

										new /obj/items/Mortar(M)
										//del src
										if(src.stack_amount >1)
											src.RemoveFromStack(1)
										else if(src.stack_amount ==1)
											del src
										return
									else
										//if(R<=4)

													//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
											//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining and are lost in the process."
										if(src.stack_amount >1)
											src.RemoveFromStack(1)
										else if(src.stack_amount ==1)
											del src

										return
								else
									M << "You need to hold a Jar filled of sand to create Mortar."
									return
					verb/Form_Jar()
						set waitfor = 0
						//set src in oview(1)
						set popup_menu = 1
						set category = null
						var/mob/players/M
						M = usr
						var/obj/items/Crafting/Created/Clay/J = locate() in M.contents
						//var/random/R = rand(1,5) //1 in 5 chance to smith

						//locate(src) in M.contents
						//if(J)
						var/CF = input("Create an Unbaked Jar?","Clayworking") in list("Yes","No")
						if(CF=="No")
							return
						if(CF=="Yes")
							//for(src in M.contents)
							//if(J.name=="Clay")
							M<<"You start to form the Clay into the shape of a Jar..."
							//sleep(5)
							var/dice = "1d8"
							var/R = roll(dice)
							if(R>=4)

									//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
								sleep(7)
								//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
								M<<"You finish forming the [src.name] and create an Unbaked Jar."
								new /obj/items/tools/Containers/UnbakedJar(M)
								J.RemoveFromStack(1)
								//del src
								return
							if(R<=4)

										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
								sleep(7)
								//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
								M<<"The materials fail at combining and are lost in the process."
								J.RemoveFromStack(1)
								return
						else if(!J)
							M << "You need Clay to continue..."
							return
					New()
						..()
						//Description()


				Handle//fixed F12021
					icon = 'dmi/64/creation.dmi'
					icon_state = "hndl"
					name = "Wooden Handle"
					item_type="Handle"
//Tool Call
					proc/FindHM(mob/players/M)
						for(var/obj/items/Crafting/Created/HammerHead/J in M.contents)
							locate(J)
							if(J.name=="Hammer head")
								return J
					proc/FindCK(mob/players/M)
						for(var/obj/items/Crafting/Created/CKnifeblade/J1 in M.contents)
							locate(J1)
							if(J1.name=="Carving Knife blade")
								return J1
					proc/FindSB(mob/players/M)
						for(var/obj/items/Crafting/Created/SickleBlade/J2 in M.contents)
							locate(J2)
							if(J2.name=="Sickle blade")
								return J2
					proc/FindTWB(mob/players/M)
						for(var/obj/items/Crafting/Created/TrowelBlade/J3 in M.contents)
							locate(J3)
							if(J3.name=="Trowel blade")
								return J3
					proc/FindCB(mob/players/M)
						for(var/obj/items/Crafting/Created/ChiselBlade/J4 in M.contents)
							locate(J4)
							if(J4.name=="Chisel blade")
								return J4
					proc/FindAH(mob/players/M)
						for(var/obj/items/Crafting/Created/AxeHead/J5 in M.contents)
							locate(J5)
							if(J5.name=="Axe head")
								return J5
					proc/FindFB(mob/players/M)
						for(var/obj/items/Crafting/Created/FileBlade/J6 in M.contents)
							locate(J6)
							if(J6.name=="File blade")//Sleepstamp (sleepstamp is a new thing I'm doing to check something in the morning that I didn't finish before going to bed)
								return J6
					proc/FindSAH(mob/players/M)
						for(var/obj/items/Crafting/Created/StoneAxehead/J7 in M.contents)
							locate(J7)
							if(J7.name=="Stone Axe head")
								return J7
					proc/FindSW(mob/players/M)
						for(var/obj/items/Crafting/Created/SawBlade/J8 in M.contents)
							locate(J8)
							if(J8.name=="Saw blade")
								return J8
//Weapon Call
					proc/FindBSf(mob/players/M)
						for(var/obj/items/Crafting/Created/Broadswordblade/J11 in M.contents)//Broad Sword
							locate(J11)
							if(J11.name=="Broadsword blade")
								return J11
					proc/FindWSf(mob/players/M)
						for(var/obj/items/Crafting/Created/Warswordblade/J12 in M.contents)//War Sword
							locate(J12)
							if(J12.name=="Warsword blade")
								return J12
					proc/FindBSWf(mob/players/M)
						for(var/obj/items/Crafting/Created/Battleswordblade/J13 in M.contents)//Battle Sword
							locate(J13)
							if(J13.name=="Battlesword blade")
								return J13
					proc/FindLSf(mob/players/M)
						for(var/obj/items/Crafting/Created/Longswordblade/J14 in M.contents)//Long Sword
							locate(J14)
							if(J14.name=="Longsword blade")
								return J14
					proc/FindWMf(mob/players/M)
						for(var/obj/items/Crafting/Created/Warmaulhead/J15 in M.contents)//War Maul
							locate(J15)
							if(J15.name=="War Maul head")
								return J15
					verb/Combine()
						set waitfor = 0
						set src in usr
						set category = null//"Commands"
						set popup_menu = 1
						var/mob/players/M
						M = usr
						var/list/CL1 = list()
						//CL1 = M.CL
						//var/obj/items/Crafting/Created/J0 = CL1
//Handle Combine Tool Call
						var/obj/items/Crafting/Created/Handle/S = locate() in M.contents
						var/obj/items/Crafting/Created/HammerHead/J = call(/obj/items/Crafting/Created/Handle/proc/FindHM)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/CKnifeblade/J1 = call(/obj/items/Crafting/Created/Handle/proc/FindCK)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/SickleBlade/J2 = call(/obj/items/Crafting/Created/Handle/proc/FindSB)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/TrowelBlade/J3 = call(/obj/items/Crafting/Created/Handle/proc/FindTWB)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/ChiselBlade/J4 = call(/obj/items/Crafting/Created/Handle/proc/FindCB)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/AxeHead/J5 = call(/obj/items/Crafting/Created/Handle/proc/FindAH)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/FileBlade/J6 = call(/obj/items/Crafting/Created/Handle/proc/FindFB)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/StoneAxehead/J7 = call(/obj/items/Crafting/Created/Handle/proc/FindSAH)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/SawBlade/J8 = call(/obj/items/Crafting/Created/Handle/proc/FindSW)(M)//locate() in M.contents
						//var/obj/items/Crafting/Created/PickaxeHead/J6 = locate() in M.contents
//Handle Combine Weapon Call
						var/obj/items/Crafting/Created/Broadswordblade/J9 = call(/obj/items/Crafting/Created/Handle/proc/FindBSf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Warswordblade/J10 = call(/obj/items/Crafting/Created/Handle/proc/FindWSf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Battleswordblade/J11 = call(/obj/items/Crafting/Created/Handle/proc/FindBSWf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Longswordblade/J12 = call(/obj/items/Crafting/Created/Handle/proc/FindLSf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Warmaulhead/J13 = call(/obj/items/Crafting/Created/Handle/proc/FindWMf)(M)//locate() in M.contents

						var/dice = "1d4"
						var/R = roll(dice)//does this work or did I change it to rand for a reason?
						//var/obj/items/Obsidian/J
						//var/obj/items/Rock/J1
						//var/obj/items/UeikThorn/J2
						//var/list/L
						//L = list("Obsidian","Rock","Ueik",3)
						//var/random/R = rand(1,5) //1 in 5 chance to smith
						//if(J in M.contents)

						//if(!J||!J1||!J2||!J3||!J4||!J5||!J6)
							//M << "Need a tool part to combine."
							//return
						//need to check all of these to make sure that proper item checks are happening and finish the extended side of allowing people to accomplish them
						//J.needssharpening==1||J.needsfiled==1||J.needsquenched==1||J.needspolished==1
						if(J in M.contents)
							if(J.needsfiled==1)
								M << "You need to check the hardness of this item with a file before you can complete it with a Handle."
								return
							else if(J.needsquenched==1)
								M << "You need to quench this item before you can complete it with a Handle."
								return
							else if(J.needspolished==1)
								M << "You need to polish this item with Ueik Fir before you can complete it with a Handle."
								return
							else if(J.needssharpening==1)
								M << "You need to sharpen this item with a Whetstone before you can complete it with a Handle."
								return
							else goto Process
						else if(J1 in M.contents)
							if(J1.needsfiled==1)
								M << "You need to check the hardness of this item with a file before you can complete it with a Handle."
								return
							else if(J1.needsquenched==1)
								M << "You need to quench this item before you can complete it with a Handle."
								return
							else if(J1.needspolished==1)
								M << "You need to polish this item with Ueik Fir before you can complete it with a Handle."
								return
							else if(J1.needssharpening==1)
								M << "You need to sharpen this item with a Whetstone before you can complete it with a Handle."
								return
							else goto Process
						else if(J2 in M.contents)
							if(J2.needsfiled==1)
								M << "You need to check the hardness of this item with a file before you can complete it with a Handle."
								return
							else if(J2.needsquenched==1)
								M << "You need to quench this item before you can complete it with a Handle."
								return
							else if(J2.needspolished==1)
								M << "You need to polish this item with Ueik Fir before you can complete it with a Handle."
								return
							else if(J2.needssharpening==1)
								M << "You need to sharpen this item with a Whetstone before you can complete it with a Handle."
								return
							else goto Process
						else if(J3 in M.contents)
							if(J3.needsfiled==1)
								M << "You need to check the hardness of this item with a file before you can complete it with a Handle."
								return
							else if(J3.needsquenched==1)
								M << "You need to quench this item before you can complete it with a Handle."
								return
							else if(J3.needspolished==1)
								M << "You need to polish this item with Ueik Fir before you can complete it with a Handle."
								return
							else if(J3.needssharpening==1)
								M << "You need to sharpen this item with a Whetstone before you can complete it with a Handle."
								return
							else goto Process
						else if(J4 in M.contents)
							if(J4.needsfiled==1)
								M << "You need to check the hardness of this item with a file before you can complete it with a Handle."
								return
							else if(J4.needsquenched==1)
								M << "You need to quench this item before you can complete it with a Handle."
								return
							else if(J4.needspolished==1)
								M << "You need to polish this item with Ueik Fir before you can complete it with a Handle."
								return
							else if(J4.needssharpening==1)
								M << "You need to sharpen this item with a Whetstone before you can complete it with a Handle."
								return
							else goto Process
						else if(J5 in M.contents)
							if(J5.needsfiled==1)
								M << "You need to check the hardness of this item with a file before you can complete it with a Handle."
								return
							else if(J5.needsquenched==1)
								M << "You need to quench this item before you can complete it with a Handle."
								return
							else if(J5.needspolished==1)
								M << "You need to polish this item with Ueik Fir before you can complete it with a Handle."
								return
							else if(J5.needssharpening==1)
								M << "You need to sharpen this item with a Whetstone before you can complete it with a Handle."
								return
							else goto Process
						else if(J6 in M.contents)
							if(J6.needsfiled==1)
								M << "You need to check the hardness of this item with a file before you can complete it with a Handle."
								return
							else if(J6.needsquenched==1)
								M << "You need to quench this item before you can complete it with a Handle."
								return
							else if(J6.needspolished==1)
								M << "You need to polish this item with Ueik Fir before you can complete it with a Handle."
								return
							else if(J6.needssharpening==1)
								M << "You need to sharpen this item with a Whetstone before you can complete it with a Handle."
								return
							else if(J6.needsfiled==0&&J6.needsquenched==0&&J6.needspolished==0&&J6.needssharpening==0)//not sure if this is required
								goto Process
						else if(J7 in M.contents)
							goto Process
						else if(J8 in M.contents)
							if(J8.needsfiled==1)
								M << "You need to check the hardness of this item with a file before you can complete it with a Handle."
								return
							else if(J8.needsquenched==1)
								M << "You need to quench this item before you can complete it with a Handle."
								return
							else if(J8.needspolished==1)
								M << "You need to polish this item with Ueik Fir before you can complete it with a Handle."
								return
							else if(J8.needssharpening==1)
								M << "You need to sharpen this item with a Whetstone before you can complete it with a Handle."
								return
							else if(J8.needsfiled==0&&J8.needsquenched==0&&J8.needspolished==0&&J8.needssharpening==0)//not sure if this is required
								goto Process
						else if(J9 in M.contents)
							if(J9.needsfiled==1)
								M << "You need to check the hardness of this item with a file before you can complete it with a Handle."
								return
							else if(J9.needsquenched==1)
								M << "You need to quench this item before you can complete it with a Handle."
								return
							else if(J9.needspolished==1)
								M << "You need to polish this item with Ueik Fir before you can complete it with a Handle."
								return
							else if(J9.needssharpening==1)
								M << "You need to sharpen this item with a Whetstone before you can complete it with a Handle."
								return
							else if(J9.needsfiled==0&&J9.needsquenched==0&&J9.needspolished==0&&J9.needssharpening==0)//not sure if this is required
								goto Process
						else if(J10 in M.contents)
							if(J10.needsfiled==1)
								M << "You need to check the hardness of this item with a file before you can complete it with a Handle."
								return
							else if(J10.needsquenched==1)
								M << "You need to quench this item before you can complete it with a Handle."
								return
							else if(J10.needspolished==1)
								M << "You need to polish this item with Ueik Fir before you can complete it with a Handle."
								return
							else if(J10.needssharpening==1)
								M << "You need to sharpen this item with a Whetstone before you can complete it with a Handle."
								return
							else if(J10.needsfiled==0&&J10.needsquenched==0&&J10.needspolished==0&&J10.needssharpening==0)//not sure if this is required
								goto Process
						else if(J11 in M.contents)
							if(J11.needsfiled==1)
								M << "You need to check the hardness of this item with a file before you can complete it with a Handle."
								return
							else if(J11.needsquenched==1)
								M << "You need to quench this item before you can complete it with a Handle."
								return
							else if(J11.needspolished==1)
								M << "You need to polish this item with Ueik Fir before you can complete it with a Handle."
								return
							else if(J11.needssharpening==1)
								M << "You need to sharpen this item with a Whetstone before you can complete it with a Handle."
								return
							else if(J11.needsfiled==0&&J11.needsquenched==0&&J11.needspolished==0&&J11.needssharpening==0)//not sure if this is required
								goto Process
						else if(J12 in M.contents)
							if(J12.needsfiled==1)
								M << "You need to check the hardness of this item with a file before you can complete it with a Handle."
								return
							else if(J12.needsquenched==1)
								M << "You need to quench this item before you can complete it with a Handle."
								return
							else if(J12.needspolished==1)
								M << "You need to polish this item with Ueik Fir before you can complete it with a Handle."
								return
							else if(J12.needssharpening==1)
								M << "You need to sharpen this item with a Whetstone before you can complete it with a Handle."
								return
							else if(J12.needsfiled==0&&J12.needsquenched==0&&J12.needspolished==0&&J12.needssharpening==0)//not sure if this is required
								goto Process
						else if(J13 in M.contents)
							if(J13.needsfiled==1)
								M << "You need to check the hardness of this item with a file before you can complete it with a Handle."
								return
							else if(J13.needsquenched==1)
								M << "You need to quench this item before you can complete it with a Handle."
								return
							else if(J13.needspolished==1)
								M << "You need to polish this item with Ueik Fir before you can complete it with a Handle."
								return
							else if(J13.needssharpening==1)
								M << "You need to sharpen this item with a Whetstone before you can complete it with a Handle."
								return
							else if(J13.needsfiled==0&&J13.needsquenched==0&&J13.needspolished==0&&J13.needssharpening==0)//not sure if this is required
								goto Process
						/*if(J1.needssharpening==1||J2.needssharpening==1||J3.needssharpening==1||J4.needssharpening==1||J5.needssharpening==1)
							M << "You need to sharpen this item with a Whetstone before you can complete it with a Handle."
							return
						if(J.needsfiled==1||J1.needsfiled==1||J2.needsfiled==1||J3.needsfiled==1||J4.needsfiled==1||J5.needsfiled==1)
							M << "You need to check the hardness of this item with a file before you can complete it with a Handle."
							return
						if(J.needsquenched==1||J1.needsquenched==1||J2.needsquenched==1||J3.needsquenched==1||J4.needsquenched==1||J5.needsquenched==1)
							M << "You need to quench this item before you can complete it with a Handle."
							return
						if(J.needspolished==1||J1.needspolished==1||J2.needspolished==1||J3.needspolished==1||J4.needspolished==1||J5.needspolished==1||J6.needspolished==1)
							M << "You need to polish this item with Ueik Fir before you can complete it with a Handle."
							return*/
						Process
						if(Carving==1)		//This is saying if usr is already cuttin a tree...
							return
						if(stamina==0)		//Is your stamina too low???
							M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
							return
						else
							if(S in M.contents)

								if(J in M.contents)
									CL1.Add("Hammer head")
								else
									CL1.Remove("Hammer head")
									//CL1 + J
								if(J1 in M.contents)
									CL1.Add("Carving Knife blade")
								else
									CL1.Remove("Carving Knife blade")
									//CL1 += J1
								if(J2 in M.contents)
									CL1.Add("Sickle blade")
								else
									CL1.Remove("Sickle blade")
									//CL1 += J2
								if(J3 in M.contents)
									CL1.Add("Trowel blade")
								else
									CL1.Remove("Trowel blade")
									//CL1 += J3
								if(J4 in M.contents)
									CL1.Add("Chisel blade")
								else
									CL1.Remove("Chisel blade")
									//CL1 += J4
								if(J5 in M.contents)
									CL1.Add("Axe head")
								else
									CL1.Remove("Axe head")
								if(J6 in M.contents)
									CL1.Add("File blade")
								else
									CL1.Remove("File blade")
								if(J7 in M.contents)
									CL1.Add("Stone Axe head")
								else
									CL1.Remove("Stone Axe head")
								if(J8 in M.contents)
									CL1.Add("Saw blade")
								else
									CL1.Remove("Saw blade")

								if(J9 in M.contents)
									CL1.Add("Broadsword blade")
								else
									CL1.Remove("Broadsword blade")
									//CL1 += J4
								if(J10 in M.contents)
									CL1.Add("Warsword blade")
								else
									CL1.Remove("Warsword blade")
								if(J11 in M.contents)
									CL1.Add("Battlesword blade")
								else
									CL1.Remove("Battlesword blade")
								if(J12 in M.contents)
									CL1.Add("Longsword blade")
								else
									CL1.Remove("Longsword blade")
								if(J13 in M.contents)
									CL1.Add("War Maul head")
								else
									CL1.Remove("War Maul head")
								//input("Affix?","Affix") in list("Obsidian","Rock","Ueik Thorn")
								var/i = input("Combine items?","Combine") in list("Yes","No")//in list("Hammer head","Carving Knife Blade","Sickle blade","Chisel blade","Axe head","Pickaxe head","Trowel blade") // in list("Dirt Road","Dirt Road Corner","Water")
								if(i=="No")
									return
								if(i=="Yes")

										//CL1 += J5
									//if(J6 in M.contents)
										//CL1.Add("Pickaxe head")
									//else
										//CL1.Remove("Pickaxe head")
										//CL1 += J6
								//else
									//M << "Nothing to combine is within your grasp."
									//return
									switch(input("Which tool?","Combine") in CL1)
									//switch(input("Which tool?","Combine") in CL1)
									//for(J0 in M.contents)
										//M<<"You start to affix the Wooden Haunch..."
										//Carving=1
											//sleep(5)
										//var/obj/items/WDHNCH/S = locate() in M.contents
										//var/obj/items/Crafting/Created/HammerHead/J = locate() in M.contents
										//var/obj/items/Crafting/Created/CKnifeblade/J1 = locate() in M.contents
										//var/obj/items/Crafting/Created/SickleBlade/J2 = locate() in M.contents
										//var/dice = "1d4"
										//var/R = roll(dice)

										if("Hammer head")
											if(J in M.contents)

												if(J.name=="Hammer head")
													for(J in M.contents)
														//M<<"You need Obsidian to continue..."
													//	return	//var/random/R = rand(1,5)

														if(R>=2)
															M<<"You start to Combine the Hammer Head and the Handle..."
															J.RemoveFromStack(1)
															//S.RemoveFromStack(1)
															Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
																//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Hammer Head to the Handle and create an Iron Hammer."
															new /obj/items/tools/Hammer(M)
															//del src
															Carving=0
															S.RemoveFromStack(1)
															return
														else
															if(R<=2)
																M<<"You start to combine..."
																J.RemoveFromStack(1)
																//S.RemoveFromStack(1)
																Carving=1		//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																sleep(5)
																//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																M<<"The materials fail at combining and are lost in the process."
																Carving=0
																S.RemoveFromStack(1)
																return
											//else
												//M<<"You need a tool part to continue..."
												//return
										//else
										if("Carving Knife blade")
											if(J1 in M.contents)
												if(J1.name == "Carving Knife blade")
													for(J1 in M.contents)
													//	M<<"You need Rock to continue..."
													//	return		//var/random/R = rand(1,5)

														if(R>=2)
															var/CK = /obj/items/tools/CarvingKnife
															M<<"You start to combine the Carving Knife blade and the Handle..."
															J1.RemoveFromStack(1)
															//S.RemoveFromStack(1)
															Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
																	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Carving Knife blade to the Handle and create a Carving Knife."
															new CK(M)
															//del src
															//for(CK in M.contents)
																//CK.needssharpening=1
															Carving=0
															S.RemoveFromStack(1)
															return
														else
															if(R<=2)
																M<<"You start to combine..."
																J1.RemoveFromStack(1)
																//S.RemoveFromStack(1)
																Carving=1		//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																sleep(5)
																	//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																M<<"The materials fail at combining and are lost in the process."
																Carving=0
																S.RemoveFromStack(1)
																return
												//else
													//M<<"You need a tool part to continue..."
													//return
											//else
										if("Sickle blade")
											if(J2 in M.contents)
												if(J2.name == "Sickle blade")
													for(J2 in M.contents)
														//M<<"You need Ueik Thorn to continue..."
														//return			//var/random/R = rand(1,5)
														if(R>=2)
															M<<"You start to combine the Sickle Blade to the Handle..."
															J2.RemoveFromStack(1)
															//S.RemoveFromStack(1)
															Carving=1//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
																	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Sickle Blade to the Handle and create a Sickle."
															new /obj/items/tools/Sickle(M)
																		//del src
															Carving=0
															S.RemoveFromStack(1)
															return
														else
															if(R<=2)
																M<<"You start to combine..."
																J2.RemoveFromStack(1)
																//S.RemoveFromStack(1)
																Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																sleep(5)
																M<<"The materials fail at combining and are lost in the process."
																//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																Carving=0
																S.RemoveFromStack(1)
																return
													/*else
														M<<"You need a tool part to continue..."
														return*/
												//else
										if("Chisel blade")
											if(J4 in M.contents)
												if(J4.name == "Chisel blade")
													for(J4 in M.contents)
														//M<<"You need Ueik Thorn to continue..."
														//return			//var/random/R = rand(1,5)
														if(R>=2)
															M<<"You start to combine the Chisel Blade to the Handle..."
															J4.RemoveFromStack(1)
															//S.RemoveFromStack(1)
															Carving=1//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
																	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Chisel Blade to the Handle and create a Chisel."
															new /obj/items/tools/Chisel(M)
																		//del src
															Carving=0
															S.RemoveFromStack(1)
															return
														else
															if(R<=2)
																M<<"You start to combine..."
																J4.RemoveFromStack(1)
																//S.RemoveFromStack(1)
																Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																sleep(5)
																M<<"The materials fail at combining and are lost in the process."
																//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																Carving=0
																S.RemoveFromStack(1)
																return
														/*else
															M<<"You need a tool part to continue..."
															return*/
													//else
										if("Stone Axe head")
											if(J7 in M.contents)
												if(J7.name == "Stone Axe head")
													for(J7 in M.contents)
														//M<<"You need Ueik Thorn to continue..."
														//return			//var/random/R = rand(1,5)
														if(R>=2)
															M<<"You start to combine the Stone Axe head to the Handle..."
															J7.RemoveFromStack(1)
															//S.RemoveFromStack(1)
															Carving=1//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
																	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Stone Axe head to the Handle and create a Stone Axe."
															new /obj/items/tools/StoneAxe(M)
																		//del src
															Carving=0
															S.RemoveFromStack(1)
															return
														else
															if(R<=2)
																M<<"You start to combine..."
																J7.RemoveFromStack(1)
																//S.RemoveFromStack(1)
																Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																sleep(5)
																M<<"The materials fail at combining and are lost in the process."
																//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																Carving=0
																S.RemoveFromStack(1)
																return
										if("Axe head")
											if(J5 in M.contents)
												if(J5.name == "Axe head")
													for(J5 in M.contents)
														//M<<"You need Ueik Thorn to continue..."
														//return			//var/random/R = rand(1,5)
														if(R>=2)
															M<<"You start to combine the Axe Head to the Handle..."
															J5.RemoveFromStack(1)
															//S.RemoveFromStack(1)
															Carving=1//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
																	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Axe Head to the Handle and create an Axe."
															new /obj/items/tools/Axe(M)
																		//del src
															Carving=0
															S.RemoveFromStack(1)
															return
														else
															if(R<=2)
																M<<"You start to combine..."
																J5.RemoveFromStack(1)
																//S.RemoveFromStack(1)
																Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																sleep(5)
																M<<"The materials fail at combining and are lost in the process."
																//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																Carving=0
																S.RemoveFromStack(1)
																return
															/*else
																M<<"You need a tool part to continue..."
																return*/
														/*else
															if("Pickaxe head")
																if(J6 in M.contents)
																	if(J6.name == "Pickaxe head")
																		for(J6 in M.contents)
																			//M<<"You need Ueik Thorn to continue..."
																			//return			//var/random/R = rand(1,5)
																			if(R>=2)
																				M<<"You start to combine the Pickaxe Head to the Handle..."
																				J6.RemoveFromStack(1)
																				//S.RemoveFromStack(1)
																				Carving=1//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																				sleep(15)
																						//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																				M<<"You finish combining the Pickaxe Head to the Handle and create a Pickaxe."
																				new /obj/items/tools/PickAxe(M)
																							//del src
																				Carving=0
																				S.RemoveFromStack(1)
																				return
																			else
																				if(R<=2)
																					M<<"You start to combine..."
																					J6.RemoveFromStack(1)
																					//S.RemoveFromStack(1)
																					Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																					sleep(5)
																					M<<"The materials fail at combining and are lost in the process."
																					//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																					Carving=0
																					S.RemoveFromStack(1)
																					return*/
																/*else
																	M<<"You need a tool part to continue..."
																	return*/
														//else
										if("Trowel blade")
											if(J3 in M.contents)
												if(J3.name == "Trowel blade")
													for(J3 in M.contents)
														//M<<"You need Ueik Thorn to continue..."
														//return			//var/random/R = rand(1,5)
														if(R>=2)
															M<<"You start to combine the Trowel Blade to the Handle..."
															J3.RemoveFromStack(1)
															//S.RemoveFromStack(1)
															Carving=1//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
																	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Trowel Blade to the Handle and create a Trowel."
															new /obj/items/tools/Trowel(M)
																		//del src
															Carving=0
															S.RemoveFromStack(1)
															return
														else
															if(R<=2)
																M<<"You start to combine..."
																J3.RemoveFromStack(1)
																//S.RemoveFromStack(1)
																Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																sleep(5)
																M<<"The materials fail at combining and are lost in the process."
																//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																Carving=0
																S.RemoveFromStack(1)
																return
															//else
										if("File blade")
											if(J6 in M.contents)
												if(J6.name == "File blade")
													for(J6 in M.contents)
														//M<<"You need Ueik Thorn to continue..."
														//return			//var/random/R = rand(1,5)
														if(R>=2)
															M<<"You start to combine the File Blade to the Handle..."
															J6.RemoveFromStack(1)
															//S.RemoveFromStack(1)
															Carving=1//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
																	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the File Blade to the Handle and create a File."
															new /obj/items/tools/File(M)
																		//del src
															Carving=0
															S.RemoveFromStack(1)
															return
														else
															if(R<=2)
																M<<"You start to combine..."
																J6.RemoveFromStack(1)
																//S.RemoveFromStack(1)
																Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																sleep(5)
																M<<"The materials fail at combining and are lost in the process."
																//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																Carving=0
																S.RemoveFromStack(1)
																return
										if("Saw blade")
											if(J8 in M.contents)
												if(J8.name == "Saw blade")
													for(J8 in M.contents)
														//M<<"You need Ueik Thorn to continue..."
														//return			//var/random/R = rand(1,5)
														if(R>=2)
															M<<"You start to combine the Saw Blade to the Handle..."
															J8.RemoveFromStack(1)
															//S.RemoveFromStack(1)
															Carving=1//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
																	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Saw Blade to the Handle and create a Saw."
															new /obj/items/tools/Saw(M)
																		//del src
															Carving=0
															S.RemoveFromStack(1)
															return
														else
															if(R<=2)
																M<<"You start to combine..."
																J8.RemoveFromStack(1)
																//S.RemoveFromStack(1)
																Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																sleep(5)
																M<<"The materials fail at combining and are lost in the process."
																//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																Carving=0
																S.RemoveFromStack(1)
																return
																/*else
																		M<<"You need a tool part to continue..."
																		return*/
										if("Broadsword blade")
											if(J8 in M.contents)
												if(J8.name == "Broadsword blade")
													for(J8 in M.contents)
														//M<<"You need Ueik Thorn to continue..."
														//return			//var/random/R = rand(1,5)
														if(R>=2)
															M<<"You start to combine the Broadsword blade to the Handle..."
															J8.RemoveFromStack(1)
															//S.RemoveFromStack(1)
															Carving=1//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
																	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Broadsword blade to the Handle and create a Broadsword."
															new /obj/items/tools/BroadSword(M)
																		//del src
															Carving=0
															S.RemoveFromStack(1)
															return
														else
															if(R<=2)
																M<<"You start to combine..."
																J8.RemoveFromStack(1)
																//S.RemoveFromStack(1)
																Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																sleep(5)
																M<<"The materials fail at combining and are lost in the process."
																//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																Carving=0
																S.RemoveFromStack(1)
																return
										if("Warsword blade")
											if(J8 in M.contents)
												if(J8.name == "Warsword blade")
													for(J8 in M.contents)
														//M<<"You need Ueik Thorn to continue..."
														//return			//var/random/R = rand(1,5)
														if(R>=2)
															M<<"You start to combine the Warsword blade to the Handle..."
															J8.RemoveFromStack(1)
															//S.RemoveFromStack(1)
															Carving=1//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
																	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Warsword blade to the Handle and create a Warsword."
															new /obj/items/tools/WarSword(M)
																		//del src
															Carving=0
															S.RemoveFromStack(1)
															return
														else
															if(R<=2)
																M<<"You start to combine..."
																J8.RemoveFromStack(1)
																//S.RemoveFromStack(1)
																Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																sleep(5)
																M<<"The materials fail at combining and are lost in the process."
																//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																Carving=0
																S.RemoveFromStack(1)
																return
										if("Battlesword blade")
											if(J8 in M.contents)
												if(J8.name == "Battlesword blade")
													for(J8 in M.contents)
														//M<<"You need Ueik Thorn to continue..."
														//return			//var/random/R = rand(1,5)
														if(R>=2)
															M<<"You start to combine the Battlesword blade to the Handle..."
															J8.RemoveFromStack(1)
															//S.RemoveFromStack(1)
															Carving=1//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
																	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Battlesword blade to the Handle and create a Battlesword."
															new /obj/items/tools/BattleSword(M)
																		//del src
															Carving=0
															S.RemoveFromStack(1)
															return
														else
															if(R<=2)
																M<<"You start to combine..."
																J8.RemoveFromStack(1)
																//S.RemoveFromStack(1)
																Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																sleep(5)
																M<<"The materials fail at combining and are lost in the process."
																//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																Carving=0
																S.RemoveFromStack(1)
																return
										if("Longsword blade")
											if(J8 in M.contents)
												if(J8.name == "Longsword blade")
													for(J8 in M.contents)
														//M<<"You need Ueik Thorn to continue..."
														//return			//var/random/R = rand(1,5)
														if(R>=2)
															M<<"You start to combine the Longsword blade to the Handle..."
															J8.RemoveFromStack(1)
															//S.RemoveFromStack(1)
															Carving=1//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
																	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Longsword blade to the Handle and create a Longsword."
															new /obj/items/tools/LongSword(M)
																		//del src
															Carving=0
															S.RemoveFromStack(1)
															return
														else
															if(R<=2)
																M<<"You start to combine..."
																J8.RemoveFromStack(1)
																//S.RemoveFromStack(1)
																Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																sleep(5)
																M<<"The materials fail at combining and are lost in the process."
																//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																Carving=0
																S.RemoveFromStack(1)
																return
										if("War Maul head")
											if(J8 in M.contents)
												if(J8.name == "War Maul head")
													for(J8 in M.contents)
														//M<<"You need Ueik Thorn to continue..."
														//return			//var/random/R = rand(1,5)
														if(R>=2)
															M<<"You start to combine the War Maul head to the Handle..."
															J8.RemoveFromStack(1)
															//S.RemoveFromStack(1)
															Carving=1//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
																	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the War Maul head to the Handle and create a Warmaul."
															new /obj/items/tools/WarMaul(M)
																		//del src
															Carving=0
															S.RemoveFromStack(1)
															return
														else
															if(R<=2)
																M<<"You start to combine..."
																J8.RemoveFromStack(1)
																//S.RemoveFromStack(1)
																Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																sleep(5)
																M<<"The materials fail at combining and are lost in the process."
																//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
																Carving=0
																S.RemoveFromStack(1)
																return
							else
								M<<"You need a Handle to combine..."
								return
					/*verb
						Combine()
							//set src in oview(1)
							//set category = "Commands"
							var/mob/players/M
							//var/obj/items/Crafting/Created/J
							//var/random/R = rand(1,5) //1 in 5 chance to smith
							M = usr
							if(M.Doing==1)
								return
							else
								var/i = input("Combine?","Combine") in list("Hammer head","Carving Knife blade","Sickle blade")
								//var/obj/items/Crafting/Created/J
								if(M.stamina==0)
									M<<"You are too tired, drink water!"
									return
								else
									//if(J.Tname!="Cool")
									//	M<<"Wait for it to cool before combining."
									//	return 0
									var/obj/items/Crafting/Created/J
									for(J in M.contents)
										//M<<"You start to combine the [J] with the Wooden handle..."
										//sleep(5)
										var/dice = "1d4"
										var/R = roll(dice)
										if(i == "Hammer head")
											//var/random/R = rand(1,5)
											var/obj/items/Crafting/Created/HammerHead/HH = locate() in M.contents
											var/obj/items/Crafting/Created/Handle/Hnd = locate() in M.contents
											var/obj/items/tools/Hammer/H = new(M, 1)
											if(R>=2)
												M.Doing=1
												M<<"You start to combine the [HH] with the Wooden handle..."
												HH.RemoveFromStack(1)
												//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the Hammer Head to the handle and create an Iron Hammer."
												H += M.contents
												M.Doing=0
												Hnd.RemoveFromStack(1)//del src
												return
											else
												if(R<=2)
													M.Doing=1
													M<<"You start to combine the [HH] with the Wooden handle..."
													HH.RemoveFromStack(1)
														//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													sleep(15)
													M.Doing=0
													Hnd.RemoveFromStack(1)//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													M<<"The materials fail at combining and are lost in the process."
													return
										if("Carving Knife blade")
											//var/random/R = rand(1,5)
											if(R>=2)
												J.RemoveFromStack(1)
												//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the blade to the handle and create a Carving Knife."
												new /obj/items/tools/CarvingKnife(M)
												del src
												return
											else
												if(R<=2)
													J.RemoveFromStack(1)
														//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													sleep(15)
													del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													M<<"The materials fail at combining and are lost in the process."
													return
										if("Sickle blade")
											//var/random/R = rand(1,5)
											if(R>=2)
												J.RemoveFromStack(1)
												//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the blade to the handle and create a Sickle."
												new /obj/items/tools/Sickle(M)
												del src
												return
											else
												if(R<=2)
													J.RemoveFromStack(1)
														//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													sleep(15)
													del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													M<<"The materials fail at combining and are lost in the process."
													return
										if("Broad Sword blade")
											//var/random/R = rand(1,5)
											if(R>=2)
												J.RemoveFromStack(1)
												//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the blade to the handle and create a Broad Sword."
												new /obj/items/tools/BroadSword(M)
												del src
												return
											if(R<=2)
												J.RemoveFromStack(1)
													//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"The materials fail at combining and are lost in the process."
												return
										if("War Sword blade")
											//var/random/R = rand(1,5)
											if(R>=2)
												J.RemoveFromStack(1)
												//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the blade to the handle and create a War Sword."
												new /obj/items/tools/WarSword(M)
												del src
												return
											if(R<=2)
												J.RemoveFromStack(1)
													//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"The materials fail at combining and are lost in the process."
												return
										if("Battle Sword blade")
											//var/random/R = rand(1,5)
											if(R>=2)
												J.RemoveFromStack(1)
												//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the blade to the handle and create a Battle Sword."
												new /obj/items/tools/BattleSword(M)
												del src
												return
											if(R<=2)
												J.RemoveFromStack(1)
													//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"The materials fail at combining and are lost in the process."
												return
										/*if("Battle Axe blade")
											var/random/R = rand(1,5)
											if(R!=2)
												J.RemoveFromStack(1)
												//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the blade to the handle and create a Battle Axe."
												new /obj/items/tools/BattleAxe(M)
												del src
												return
											else
												J.RemoveFromStack(1)
													//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"The materials fail at combining and are lost in the process."
												return*/
										if("Battle Scythe blade")
											//var/random/R = rand(1,5)
											if(R>=2)
												J.RemoveFromStack(1)
												//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the blade to the handle and create a Battle Scythe."
												new /obj/items/tools/BattleScythe(M)
												del src
												return
											if(R<=2)
												J.RemoveFromStack(1)
													//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"The materials fail at combining and are lost in the process."
												return
										/*if("Battle Maul head")
											var/random/R = rand(1,5)
											if(R!=2)
												J.RemoveFromStack(1)
												//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the head to the handle and create a Battle Maul."
												new /obj/items/tools/BattleMaul(M)
												del src
												return
											else
												J.RemoveFromStack(1)
													//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"The materials fail at combining and are lost in the process."
												return*/
										if("Battle Hammer sledge")
											//var/random/R = rand(1,5)
											if(R>=2)
												J.RemoveFromStack(1)
												//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the sledge to the handle and create a Battle Hammer."
												new /obj/items/tools/BattleHammer(M)
												del src
												return
											if(R<=2)
												J.RemoveFromStack(1)
													//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"The materials fail at combining and are lost in the process."
												return
										/*if("War Maul head")
											var/random/R = rand(1,5)
											if(R!=2)
												J.RemoveFromStack(1)
												//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the blade to the handle and create a War Maul."
												new /obj/items/tools/WarMaul(M)
												del src
												return
											else
												J.RemoveFromStack(1)
													//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"The materials fail at combining and are lost in the process."
												return
										if("War Axe blade")
											var/random/R = rand(1,5)
											if(R!=2)
												J.RemoveFromStack(1)
												//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the blade to the handle and create a War Axe."
												new /obj/items/tools/WarAxe(M)
												del src
												return
											else
												J.RemoveFromStack(1)
													//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"The materials fail at combining and are lost in the process."
												return*/
										if("War Scythe blade")
											//var/random/R = rand(1,5)
											if(R>=2)
												J.RemoveFromStack(1)
												//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the blade to the handle and create a War Scythe."
												new /obj/items/tools/WarScythe(M)
												del src
												return
											if(R<=2)
												J.RemoveFromStack(1)
													//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
												del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"The materials fail at combining and are lost in the process."
												return*/


				Pole//fixed
					icon = 'dmi/64/creation.dmi'
					icon_state = "pole"
					name = "Wooden Pole"
					item_type="Wooden Pole"

//Tool Call
					proc/FindSHf(mob/players/M)
						for(var/obj/items/Crafting/Created/ShovelHead/J1 in M.contents)//Shovel
							locate(J1)
							if(J1.name=="Shovel head")
								return J1
					proc/FindHOf(mob/players/M)
						for(var/obj/items/Crafting/Created/HoeBlade/J in M.contents)//Hoe
							locate(J)
							if(J.name=="Hoe blade")
								return J
					proc/FindPXf(mob/players/M)
						for(var/obj/items/Crafting/Created/PickaxeHead/J0 in M.contents)//Pickaxe
							locate(J0)
							if(J0.name=="Pickaxe head")
								return J0
					proc/FindFPf(mob/players/M)
						for(var/obj/items/Crafting/Created/FishingPoleReel/J00 in M.contents)//Fishing Pole
							locate(J00)
							if(J00.name=="Iron Reel")
								return J00
//Weapon Call
					proc/FindBHf(mob/players/M)
						for(var/obj/items/Crafting/Created/Battlehammersledge/J16 in M.contents)//Battle Hammer
							locate(J16)
							if(J16.name=="Battle Hammer sledge")
								return J16
					proc/FindWXf(mob/players/M)
						for(var/obj/items/Crafting/Created/Waraxeblade/J17 in M.contents)//War Axe
							locate(J17)
							if(J17.name=="War Axe blade")
								return J17
					proc/FindBXf(mob/players/M)
						for(var/obj/items/Crafting/Created/Battleaxeblade/J18 in M.contents)//Battle Axe
							locate(J18)
							if(J18.name=="Battle Axe blade")
								return J18
					proc/FindWSYf(mob/players/M)
						for(var/obj/items/Crafting/Created/Warscytheblade/J19 in M.contents)//War Scythe
							locate(J19)
							if(J19.name=="War Scythe blade")
								return J19
					proc/FindBSYf(mob/players/M)
						for(var/obj/items/Crafting/Created/Battlescytheblade/J20 in M.contents)//Battle Scythe
							locate(J20)
							if(J20.name=="Battle Scythe blade")
								return J20

//Lamp
					proc/FindWLf(mob/players/M)
						for(var/obj/items/Crafting/Created/WoodenTorchHead/J2 in M.contents)//Iron Lamp Head
							locate(J2)
							if(J2.name=="Wooden Torch Head")
								return J2
					proc/FindILf(mob/players/M)
						for(var/obj/items/Crafting/Created/IronLampHead/J3 in M.contents)//Iron Lamp Head
							locate(J3)
							if(J3.name=="Iron Lamp Head")
								return J3
					proc/FindCLf(mob/players/M)
						for(var/obj/items/Crafting/Created/CopperLampHead/J4 in M.contents)//Copper Lamp Head
							locate(J4)
							if(J4.name=="Copper Lamp Head")
								return J4
					proc/FindBRLf(mob/players/M)
						for(var/obj/items/Crafting/Created/BronzeLampHead/J5 in M.contents)//Bronze Lamp Head
							locate(J5)
							if(J5.name=="Bronze Lamp Head")
								return J5
					proc/FindBSLf(mob/players/M)
						for(var/obj/items/Crafting/Created/BrassLampHead/J6 in M.contents)//Brass Lamp Head
							locate(J6)
							if(J6.name=="Brass Lamp Head")
								return J6
					proc/FindSLf(mob/players/M)
						for(var/obj/items/Crafting/Created/SteelLampHead/J7 in M.contents)//Steel Lamp Head
							locate(J7)
							if(J7.name=="Steel Lamp Head")
								return J7
					verb
						Combine()
							set waitfor = 0
							//set src in oview(1)
							set category = null//"Commands"
							set popup_menu = 1
							var/mob/players/M
							M = usr
							var/list/PCL1
							PCL1 = M.PCL

//Pole Combine Tool Call
							var/obj/items/Crafting/Created/Pole/P = locate() in M.contents
							var/obj/items/Crafting/Created/PickaxeHead/J0 = call(/obj/items/Crafting/Created/Pole/proc/FindPXf)(M)//locate() in M.contents
							var/obj/items/Crafting/Created/HoeBlade/J = call(/obj/items/Crafting/Created/Pole/proc/FindHOf)(M)//locate() in M.contents
							var/obj/items/Crafting/Created/ShovelHead/J1 = call(/obj/items/Crafting/Created/Pole/proc/FindSHf)(M)//locate() in M.contents
							var/obj/items/Crafting/Created/FishingPoleReel/J00 = call(/obj/items/Crafting/Created/Pole/proc/FindFPf)(M)//locate() in M.contents

//Pole Combine Lamp Call
							var/obj/items/Crafting/Created/WoodenTorchHead/J2 = call(/obj/items/Crafting/Created/Pole/proc/FindWLf)(M)//locate() in M.contents
							var/obj/items/Crafting/Created/IronLampHead/J3 = call(/obj/items/Crafting/Created/Pole/proc/FindILf)(M)//locate() in M.contents
							var/obj/items/Crafting/Created/CopperLampHead/J4 = call(/obj/items/Crafting/Created/Pole/proc/FindCLf)(M)//locate() in M.contents
							var/obj/items/Crafting/Created/BrassLampHead/J5 = call(/obj/items/Crafting/Created/Pole/proc/FindBSLf)(M)//locate() in M.contents
							var/obj/items/Crafting/Created/BronzeLampHead/J6 = call(/obj/items/Crafting/Created/Pole/proc/FindBRLf)(M)//locate() in M.contents
							var/obj/items/Crafting/Created/SteelLampHead/J7 = call(/obj/items/Crafting/Created/Pole/proc/FindSLf)(M)//locate() in M.contents
//Pole Combine Weapon Call
							var/obj/items/Crafting/Created/Battlehammersledge/J16 = call(/obj/items/Crafting/Created/Pole/proc/FindBHf)(M)//locate() in M.contents
							var/obj/items/Crafting/Created/Waraxeblade/J17 = call(/obj/items/Crafting/Created/Pole/proc/FindWXf)(M)//locate() in M.contents
							var/obj/items/Crafting/Created/Battleaxeblade/J18 = call(/obj/items/Crafting/Created/Pole/proc/FindBXf)(M)//locate() in M.contents
							var/obj/items/Crafting/Created/Warscytheblade/J19 = call(/obj/items/Crafting/Created/Pole/proc/FindWSYf)(M)//locate() in M.contents
							var/obj/items/Crafting/Created/Battlescytheblade/J20 = call(/obj/items/Crafting/Created/Pole/proc/FindBSYf)(M)//locate() in M.contents
							//var/dice = "1d4"
							//var/R = roll(dice)
							//var/random/R = rand(1,5) //1 in 5 chance to smith
							//M = usr
							//if(src.Tname!="Hot")
							/*if(J0.Tname!="Hot")
								M<<"Heat it up before combining."
								return
							else*/
							if(J00 in M.contents)
								if(J00.needsfiled==1)
									M << "You need to check the hardness of this item with a file before you can complete it with a Pole."
									return
								else if(J00.needsquenched==1)
									M << "You need to quench this item before you can complete it with a Pole."
									return
								else if(J00.needspolished==1)
									M << "You need to polish this item with Ueik Fir before you can complete it with a Pole."
									return
								else if(J00.needssharpening==1)
									M << "You need to sharpen this item with a Whetstone before you can complete it with a Pole."
									return
								else if(J00.needsfiled==0&&J00.needsquenched==0&&J00.needspolished==0&&J00.needssharpening==0)//not sure if this is required
									goto Process
							if(J0 in M.contents)
								if(J0.needsfiled==1)
									M << "You need to check the hardness of this item with a file before you can complete it with a Pole."
									return
								else if(J0.needsquenched==1)
									M << "You need to quench this item before you can complete it with a Pole."
									return
								else if(J0.needspolished==1)
									M << "You need to polish this item with Ueik Fir before you can complete it with a Pole."
									return
								else if(J0.needssharpening==1)
									M << "You need to sharpen this item with a Whetstone before you can complete it with a Pole."
									return
								else if(J0.needsfiled==0&&J0.needsquenched==0&&J0.needspolished==0&&J0.needssharpening==0)//not sure if this is required
									goto Process
							if(J in M.contents)
								if(J.needsfiled==1)
									M << "You need to check the hardness of this item with a file before you can complete it with a Pole."
									return
								else if(J.needsquenched==1)
									M << "You need to quench this item before you can complete it with a Pole."
									return
								else if(J.needspolished==1)
									M << "You need to polish this item with Ueik Fir before you can complete it with a Pole."
									return
								else if(J.needssharpening==1)
									M << "You need to sharpen this item with a Whetstone before you can complete it with a Pole."
									return
								else if(J.needsfiled==0&&J.needsquenched==0&&J.needspolished==0&&J.needssharpening==0)//not sure if this is required
									goto Process
							if(J1 in M.contents)
								if(J1.needsfiled==1)
									M << "You need to check the hardness of this item with a file before you can complete it with a Pole."
									return
								else if(J1.needsquenched==1)
									M << "You need to quench this item before you can complete it with a Pole."
									return
								else if(J1.needspolished==1)
									M << "You need to polish this item with Ueik Fir before you can complete it with a Pole."
									return
								else if(J1.needssharpening==1)
									M << "You need to sharpen this item with a Whetstone before you can complete it with a Pole."
									return
								else if(J1.needsfiled==0&&J1.needsquenched==0&&J1.needspolished==0&&J1.needssharpening==0)//not sure if this is required
									goto Process
							if(J2 in M.contents)
								goto Process
							if(J3 in M.contents)
								if(J3.needsfiled==1)
									M << "You need to check the hardness of this item with a file before you can complete it with a Pole."
									return
								else if(J3.needsquenched==1)
									M << "You need to quench this item before you can complete it with a Pole."
									return
								else if(J3.needspolished==1)
									M << "You need to polish this item with Ueik Fir before you can complete it with a Pole."
									return
								else if(J3.needssharpening==1)
									M << "You need to sharpen this item with a Whetstone before you can complete it with a Pole."
									return
								else if(J3.needsfiled==0&&J3.needsquenched==0&&J3.needspolished==0&&J3.needssharpening==0)//not sure if this is required
									goto Process
							if(J4 in M.contents)
								if(J4.needsfiled==1)
									M << "You need to check the hardness of this item with a file before you can complete it with a Pole."
									return
								else if(J4.needsquenched==1)
									M << "You need to quench this item before you can complete it with a Pole."
									return
								else if(J4.needspolished==1)
									M << "You need to polish this item with Ueik Fir before you can complete it with a Pole."
									return
								else if(J4.needssharpening==1)
									M << "You need to sharpen this item with a Whetstone before you can complete it with a Pole."
									return
								else if(J4.needsfiled==0&&J4.needsquenched==0&&J4.needspolished==0&&J4.needssharpening==0)//not sure if this is required
									goto Process
							if(J5 in M.contents)
								if(J5.needsfiled==1)
									M << "You need to check the hardness of this item with a file before you can complete it with a Pole."
									return
								else if(J5.needsquenched==1)
									M << "You need to quench this item before you can complete it with a Pole."
									return
								else if(J5.needspolished==1)
									M << "You need to polish this item with Ueik Fir before you can complete it with a Pole."
									return
								else if(J5.needssharpening==1)
									M << "You need to sharpen this item with a Whetstone before you can complete it with a Pole."
									return
								else if(J5.needsfiled==0&&J5.needsquenched==0&&J5.needspolished==0&&J5.needssharpening==0)//not sure if this is required
									goto Process
							if(J6 in M.contents)
								if(J6.needsfiled==1)
									M << "You need to check the hardness of this item with a file before you can complete it with a Pole."
									return
								else if(J6.needsquenched==1)
									M << "You need to quench this item before you can complete it with a Pole."
									return
								else if(J6.needspolished==1)
									M << "You need to polish this item with Ueik Fir before you can complete it with a Pole."
									return
								else if(J6.needssharpening==1)
									M << "You need to sharpen this item with a Whetstone before you can complete it with a Pole."
									return
								else if(J6.needsfiled==0&&J6.needsquenched==0&&J6.needspolished==0&&J6.needssharpening==0)//not sure if this is required
									goto Process
							if(J7 in M.contents)
								if(J7.needsfiled==1)
									M << "You need to check the hardness of this item with a file before you can complete it with a Pole."
									return
								else if(J7.needsquenched==1)
									M << "You need to quench this item before you can complete it with a Pole."
									return
								else if(J7.needspolished==1)
									M << "You need to polish this item with Ueik Fir before you can complete it with a Pole."
									return
								else if(J7.needssharpening==1)
									M << "You need to sharpen this item with a Whetstone before you can complete it with a Pole."
									return
								else if(J7.needsfiled==0&&J7.needsquenched==0&&J7.needspolished==0&&J7.needssharpening==0)//not sure if this is required
									goto Process
							if(J16 in M.contents)
								if(J16.needsfiled==1)
									M << "You need to check the hardness of this item with a file before you can complete it with a Pole."
									return
								else if(J16.needsquenched==1)
									M << "You need to quench this item before you can complete it with a Pole."
									return
								else if(J16.needspolished==1)
									M << "You need to polish this item with Ueik Fir before you can complete it with a Pole."
									return
								else if(J16.needssharpening==1)
									M << "You need to sharpen this item with a Whetstone before you can complete it with a Pole."
									return
								else if(J16.needsfiled==0&&J16.needsquenched==0&&J16.needspolished==0&&J16.needssharpening==0)//not sure if this is required
									goto Process
							if(J17 in M.contents)
								if(J17.needsfiled==1)
									M << "You need to check the hardness of this item with a file before you can complete it with a Pole."
									return
								else if(J17.needsquenched==1)
									M << "You need to quench this item before you can complete it with a Pole."
									return
								else if(J17.needspolished==1)
									M << "You need to polish this item with Ueik Fir before you can complete it with a Pole."
									return
								else if(J17.needssharpening==1)
									M << "You need to sharpen this item with a Whetstone before you can complete it with a Pole."
									return
								else if(J17.needsfiled==0&&J17.needsquenched==0&&J17.needspolished==0&&J17.needssharpening==0)//not sure if this is required
									goto Process
							if(J18 in M.contents)
								if(J18.needsfiled==1)
									M << "You need to check the hardness of this item with a file before you can complete it with a Pole."
									return
								else if(J18.needsquenched==1)
									M << "You need to quench this item before you can complete it with a Pole."
									return
								else if(J18.needspolished==1)
									M << "You need to polish this item with Ueik Fir before you can complete it with a Pole."
									return
								else if(J18.needssharpening==1)
									M << "You need to sharpen this item with a Whetstone before you can complete it with a Pole."
									return
								else if(J18.needsfiled==0&&J18.needsquenched==0&&J18.needspolished==0&&J18.needssharpening==0)//not sure if this is required
									goto Process
							if(J19 in M.contents)
								if(J19.needsfiled==1)
									M << "You need to check the hardness of this item with a file before you can complete it with a Pole."
									return
								else if(J19.needsquenched==1)
									M << "You need to quench this item before you can complete it with a Pole."
									return
								else if(J19.needspolished==1)
									M << "You need to polish this item with Ueik Fir before you can complete it with a Pole."
									return
								else if(J19.needssharpening==1)
									M << "You need to sharpen this item with a Whetstone before you can complete it with a Pole."
									return
								else if(J19.needsfiled==0&&J19.needsquenched==0&&J19.needspolished==0&&J19.needssharpening==0)//not sure if this is required
									goto Process
							if(J20 in M.contents)
								if(J20.needsfiled==1)
									M << "You need to check the hardness of this item with a file before you can complete it with a Pole."
									return
								else if(J20.needsquenched==1)
									M << "You need to quench this item before you can complete it with a Pole."
									return
								else if(J20.needspolished==1)
									M << "You need to polish this item with Ueik Fir before you can complete it with a Pole."
									return
								else if(J20.needssharpening==1)
									M << "You need to sharpen this item with a Whetstone before you can complete it with a Pole."
									return
								else if(J20.needsfiled==0&&J20.needsquenched==0&&J20.needspolished==0&&J20.needssharpening==0)//not sure if this is required
									goto Process

							Process
							if(J0 in M.contents)
								PCL1.Add("Pickaxe head")
							else
								PCL1.Remove("Pickaxe head")
							if(J in M.contents)
								PCL1.Add("Hoe blade")
							else
								PCL1.Remove("Hoe blade")
							if(J1 in M.contents)
								PCL1.Add("Shovel head")
							else
								PCL1.Remove("Shovel head")
							if(J00 in M.contents)
								PCL1.Add("Iron Reel")
							else
								PCL1.Remove("Iron Reel")
//Lamps
							if(J2 in M)
								PCL1.Add("Wooden Torch Head")
							else
								PCL1.Remove("Wooden Torch Head")
							if(J3 in M.contents)
								PCL1.Add("Iron Lamp Head")
							else
								PCL1.Remove("Iron Lamp Head")
							if(J4 in M.contents)
								PCL1.Add("Copper Lamp Head")
							else
								PCL1.Remove("Copper Lamp Head")
							if(J5 in M.contents)
								PCL1.Add("Brass Lamp Head")
							else
								PCL1.Remove("Brass Lamp Head")
							if(J6 in M.contents)
								PCL1.Add("Bronze Lamp Head")
							else
								PCL1.Remove("Bronze Lamp Head")
							if(J7 in M.contents)
								PCL1.Add("Steel Lamp Head")
							else
								PCL1.Remove("Steel Lamp Head")
//Weapons
							if(J16 in M.contents)
								PCL1.Add("Battle Hammer sledge")
							else
								PCL1.Remove("Battle Hammer sledge")
							if(J17 in M.contents)
								PCL1.Add("War Axe blade")
							else
								PCL1.Remove("War Axe blade")
							if(J18 in M.contents)
								PCL1.Add("Battle Axe blade")
							else
								PCL1.Remove("Battle Axe blade")
							if(J19 in M.contents)
								PCL1.Add("War Scythe blade")
							else
								PCL1.Remove("War Scythe blade")
							if(J20 in M.contents)
								PCL1.Add("Battle Scythe blade")
							else
								PCL1.Remove("Battle Scythe blade")
							if(P in M.contents)
								var/i = input("Combine items?","Combine") in list("Yes","No")//in list("Hammer head","Carving Knife Blade","Sickle blade","Chisel blade","Axe head","Pickaxe head","Trowel blade") // in list("Dirt Road","Dirt Road Corner","Water")
								if(i=="No")
									return
								if(i=="Yes")
//Tools
									switch(input("Combine?","Combine") in PCL1)//list("Hoe blade","Shovel head","Wooden Torch Head","Iron Lamp Head","Copper Lamp Head","Brass Lamp Head","Bronze Lamp Head","Steel Lamp Head"))
									//for(P in M.contents)
									//for(J in M.contents)
										if("Pickaxe head")
											var/dice = "1d4"
											var/R = roll(dice)
											if(J0 in M.contents)
												for(J0 in M.contents)
											//var/random/R = rand(1,5)
													if(J0.name=="Pickaxe head")
														if(R>=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J0.RemoveFromStack(1)
															//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the head to the pole and create a Pickaxe."
															new /obj/items/tools/PickAxe(M)
															P.RemoveFromStack(1)//del src
															return
														else//if(R<=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J0.RemoveFromStack(1)
																//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															P.RemoveFromStack(1)//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"The materials fail at combining and are lost in the process."
															return
										if("Hoe blade")
											var/dice = "1d4"
											var/R = roll(dice)
											if(J in M.contents)
												for(J in M.contents)
											//var/random/R = rand(1,5)
													if(J.name=="Hoe blade")
														if(R>=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J.RemoveFromStack(1)
															//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the blade to the handle and create a Hoe."
															new /obj/items/tools/Hoe(M)
															P.RemoveFromStack(1)
															return
														else//if(R<=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J.RemoveFromStack(1)
																//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															P.RemoveFromStack(1)//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"The materials fail at combining and are lost in the process."
															return
										if("Shovel head")
											var/dice = "1d4"
											var/R = roll(dice)
											if(J1 in M.contents)
												for(J1 in M.contents)
											//var/random/R = rand(1,5)
													if(J1.name == "Shovel head")
														if(R>=2)
															J1.RemoveFromStack(1)
															M<<"You start to combine the item with the Wooden Pole..."//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the head to the pole and create a Shovel."
															new /obj/items/tools/Shovel(M)
															P.RemoveFromStack(1)
															return
														else//if(R<=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J1.RemoveFromStack(1)
																//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															P.RemoveFromStack(1)//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"The materials fail at combining and are lost in the process."
															return
										if("Iron Reel")
											var/dice = "1d4"
											var/R = roll(dice)
											if(J00 in M.contents)
												for(J00 in M.contents)
											//var/random/R = rand(1,5)
													if(J00.name=="Iron Reel")
														if(R>=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J00.RemoveFromStack(1)
															//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the reel to the pole and create a Fishing Pole."
															new /obj/items/tools/FishingPole(M)
															P.RemoveFromStack(1)//del src
															return
														else//if(R<=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J00.RemoveFromStack(1)
																//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															P.RemoveFromStack(1)//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"The materials fail at combining and are lost in the process."
															return







										if("Wooden Torch Head")//works needs to be copied over to others
											var/dice = "1d4"
											var/R = roll(dice)
											if(J2 in M)
												if(R>=2)
													M<<"You start to combine the item with the Wooden Pole..."
													//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													sleep(15)
													//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													M<<"You finish combining the Wooden Torch Head to the Pole and create a Wooden Torch"
													new /obj/items/Buildable/lamps/woodentorch(M)
													J2.RemoveFromStack(1)
													P.RemoveFromStack(1)
													return
												else//if(R<=2)
													//J2.RemoveFromStack(1)
													M<<"You start to combine the item with the Wooden Pole..."
														//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													sleep(15)
													//P.RemoveFromStack(1)//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													M<<"The materials fail at combining and are lost in the process."
													J2.RemoveFromStack(1)
													P.RemoveFromStack(1)
													return


										if("Iron Lamp Head")//testing no J.name
											var/dice = "1d4"
											var/R = roll(dice)
											if(J3 in M.contents)
												for(J3 in M.contents)
											//var/random/R = rand(1,5)
													if(J3.name == "Iron Lamp Head")
														if(R>=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J3.RemoveFromStack(1)
															//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Iron Lamp Head to the Pole and create a Iron Lamp"
															new /obj/items/Buildable/lamps/ironlamp(M)
															P.RemoveFromStack(1)
															return
														else//if(R<=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J3.RemoveFromStack(1)
																//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															P.RemoveFromStack(1)//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"The materials fail at combining and are lost in the process."
															return
										if("Copper Lamp Head")
											var/dice = "1d4"
											var/R = roll(dice)
											if(J4 in M.contents)
												for(J4 in M.contents)
											//var/random/R = rand(1,5)
													if(J4.name == "Copper Lamp Head")

														if(R>=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J4.RemoveFromStack(1)
															//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Copper Lamp Head to the Pole and create a Copper Lamp"
															new /obj/items/Buildable/lamps/copperlamp(M)
															P.RemoveFromStack(1)
															return
														else//if(R<=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J4.RemoveFromStack(1)
																//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															P.RemoveFromStack(1)//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"The materials fail at combining and are lost in the process."
															return
										if("Bronze Lamp Head")
											var/dice = "1d4"
											var/R = roll(dice)
											if(J6 in M.contents)
												for(J6 in M.contents)
											//var/random/R = rand(1,5)
													if(J.name=="Bronze Lamp Head")
														if(R>=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J6.RemoveFromStack(1)
															//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Bronze Lamp Head to the Pole and create a Bronze Lamp"
															new /obj/items/Buildable/lamps/bronzelamp(M)
															P.RemoveFromStack(1)
															return
														else//if(R<=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J6.RemoveFromStack(1)
																//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															P.RemoveFromStack(1)//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"The materials fail at combining and are lost in the process."
															return
										if("Brass Lamp Head")
											var/dice = "1d4"
											var/R = roll(dice)
											if(J5 in M.contents)
												for(J5 in M.contents)
											//var/random/R = rand(1,5)
													if(J5.name == "Brass Lamp Head")
														if(R>=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J5.RemoveFromStack(1)
															//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Brass Lamp Head to the Pole and create a Brass Lamp"
															new /obj/items/Buildable/lamps/brasslamp(M)
															P.RemoveFromStack(1)
															return
														else//if(R<=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J5.RemoveFromStack(1)
																//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															P.RemoveFromStack(1)//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"The materials fail at combining and are lost in the process."
															return

										if("Steel Lamp Head")
											var/dice = "1d4"
											var/R = roll(dice)
											if(J7 in M.contents)
												for(J7 in M.contents)
											//var/random/R = rand(1,5)
													if(J7.name=="Steel Lamp Head")
														if(R>=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J7.RemoveFromStack(1)
															//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Steel Lamp Head to the Pole and create a Steel Lamp"
															new /obj/items/Buildable/lamps/steellamp(M)
															P.RemoveFromStack(1)
															return
														else//if(R<=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J7.RemoveFromStack(1)
																//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															P.RemoveFromStack(1)//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"The materials fail at combining and are lost in the process."
															return

										if("Battle Hammer sledge")//testing no J.name
											var/dice = "1d4"
											var/R = roll(dice)
											if(J16 in M.contents)
												for(J16 in M.contents)
											//var/random/R = rand(1,5)
													if(J16.name == "Battle Hammer sledge")
														if(R>=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J16.RemoveFromStack(1)
															//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Battle Hammer sledge to the Pole and create a Battle Hammer"
															new /obj/items/tools/BattleHammer(M)
															P.RemoveFromStack(1)
															return
														else
															M<<"You start to combine the item with the Wooden Pole..."
															J16.RemoveFromStack(1)
																//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															P.RemoveFromStack(1)//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"The materials fail at combining and are lost in the process."
															return
										if("War Axe blade")
											var/dice = "1d4"
											var/R = roll(dice)
											if(J17 in M.contents)
												for(J17 in M.contents)
											//var/random/R = rand(1,5)
													if(J17.name == "War Axe blade")

														if(R>=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J17.RemoveFromStack(1)
															//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the War Axe blade to the Pole and create a War Axe"
															new /obj/items/tools/WarAxe(M)
															P.RemoveFromStack(1)
															return
														else//if(R<=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J17.RemoveFromStack(1)
																//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															P.RemoveFromStack(1)//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"The materials fail at combining and are lost in the process."
															return
										if("Battle Axe blade")
											var/dice = "1d4"
											var/R = roll(dice)
											if(J18 in M.contents)
												for(J18 in M.contents)
											//var/random/R = rand(1,5)
													if(J18.name == "Battle Axe blade")
														if(R>=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J18.RemoveFromStack(1)
															//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Battle Axe blade to the Pole and create a Battle Axe"
															new /obj/items/tools/BattleAxe(M)
															P.RemoveFromStack(1)
															return
														else//if(R<=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J18.RemoveFromStack(1)
																//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															P.RemoveFromStack(1)//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"The materials fail at combining and are lost in the process."
															return
										if("War Scythe blade")
											var/dice = "1d4"
											var/R = roll(dice)
											if(J19 in M.contents)
												for(J19 in M.contents)
											//var/random/R = rand(1,5)
													if(J19.name=="War Scythe blade")
														if(R>=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J19.RemoveFromStack(1)
															//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the War Scythe blade to the Pole and create a War Scythe"
															new /obj/items/tools/WarScythe(M)
															P.RemoveFromStack(1)
															return
														else//if(R<=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J19.RemoveFromStack(1)
																//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															P.RemoveFromStack(1)//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"The materials fail at combining and are lost in the process."
															return
										if("Battle Scythe blade")
											var/dice = "1d4"
											var/R = roll(dice)
											if(J20 in M.contents)
												for(J20 in M.contents)
											//var/random/R = rand(1,5)
													if(J20.name=="Battle Scythe blade")
														if(R>=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J20.RemoveFromStack(1)
															//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"You finish combining the Battle Scythe blade to the Pole and create a Battle Scythe"
															new /obj/items/tools/BattleScythe(M)
															P.RemoveFromStack(1)
															return
														else//if(R<=2)
															M<<"You start to combine the item with the Wooden Pole..."
															J20.RemoveFromStack(1)
																//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															sleep(15)
															P.RemoveFromStack(1)//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
															M<<"The materials fail at combining and are lost in the process."
															return
							else
								M<<"You need a Pole to combine..."
								return


				WeaponRack
					icon = 'dmi/64/Castl.dmi'
					icon_state = "wr"
					name = "Weapon Rack"
					item_type="Weapon Rack"
					var/empty = 1
					var/occupiedLS = 0
					var/occupiedBS = 0
					Click()
						//set src in oview(1)
						////set category = "Commands"
						set waitfor = 0
						var/mob/players/M
						M = usr
						var/obj/items/tools/LongSword/LS = locate() in M.contents//needs to be expanded to all weapons WorkStamp
						if(src.occupiedLS == 1)
							src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="LSWRO")

							sleep(5)
							new /obj/items/tools/LongSword(M)
							return
						if(LS in M.contents)
							for(LS in M.contents)
								if(src.empty == 1)
									del LS
									src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="LSWRO")
									src:empty = 0
									src:occupiedLS = 1
									sleep(5)
									return
								else
									M<<"Weapon Rack is Full."
									return
						else
							return
				ArmorRack
					icon = 'dmi/64/Castl.dmi'
					icon_state = "ar"
					name = "Armor Rack"
					item_type="Armor Rack"
					var/empty = 1
					var/occupiedLS = 0
					Click()
						set waitfor = 0
						//set src in oview(1)
						////set category = "Commands"
						var/mob/players/M
						M = usr
						var/obj/items/tools/LongSword/LS = locate() in M.contents
						if(src.occupiedLS == 1)
							src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="LSWRO")//needs switched over to armor and finished WorkStamp

							sleep(5)
							new /obj/items/tools/LongSword(M)
							return
						if(LS in M.contents)
							for(LS in M.contents)
								if(src.empty == 1)
									del LS
									src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="LSWRO")
									src:empty = 0
									src:occupiedLS = 1
									sleep(5)
									return
								else
									M<<"Weapon Rack is Full."
									return
						else
							return

		Sand
			icon = 'dmi/64/inven.dmi'
			icon_state = "sand"
			name = "Sand"
			can_stack = TRUE
			layer = 11
			verb
				Combine()
					set waitfor = 0
					//set src in oview(1)
					set popup_menu = 1
					set category = null
					var/mob/players/M
					var/obj/items/Crafting/Created/Clay/J
					//var/random/R = rand(1,5) //1 in 5 chance to smith
					M = usr
					//J = locate(M.contents)
					locate(J) in M.contents//fixed don't add any dumb inputs :) J
					if(!J in M.contents)
						M << "You need Clay to combine Sand..."
						return
					else
						for(J in M.contents)
							//input("Create Mortar?","Combine") in list("Yes","No")
							//if("No")
								//return
							//if("Yes")
							if(J.stack_amount>=1)

								if(J.name=="Clay")
									var/dice = "1d8"
									var/R = roll(dice)
									if(R>=5)
										M<<"You start to combine the Clay with the Sand..."
										//sleep(5)
										J.RemoveFromStack(1)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"You finish combining the Clay with the Sand and create Mortar."
										new /obj/items/Mortar(M)
										//del src
										return
									else
										if(R<=4)
											J.RemoveFromStack(1)
													//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
											sleep(15)
											//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
											M<<"The materials fail at combining and are lost in the process."
											return
							else
								M << "You need at least 1 [J.name] to create Mortar."


obj
	var/Tname=""
	proc
		NoLucre() // this function get called alot, so it is defined up here
			usr << "<font color = teal>Your pouch does not contain enough lucre."
		Selling(var/obj/J in usr) // so does this one
			var/mob/players/M = usr
			if ( istype(J,/obj/items/weapons) || istype(J,/obj/items/armors) || istype(J,/obj/items/shields) || istype(J,/obj/items/ancscrlls) || istype(J,/obj/items) ) // gotta check to be sure it is the right type of item
				if(J.suffix == "Equipped") // you can't sell equipped stuff
					usr << "<font color = teal>Un-equip [J] first!"
				else
					if((input("Are you sure you want to sell the [J] for [J.Worth] lucre?") in list("Yes","No")) != "Yes")
						return // leave this function if you said no
					//otherwise...
					M.lucre+=J.Worth // sell the item
					usr << "\green<b>You sold [J] for [J.Worth] lucre."
					del J
			else
				usr << "You can't sell that."
	//proc //.....
		FishingCheck() //name of proc dexp (destroy fexp (fishing seexp (Searching
			var/mob/players/M = usr
			if(M.fexp >= M.fexpneeded) //if users mining experience is or gos past users max ming experience
				M.fishinglevel+=1 //users mining gos up by 1
				M.fexp=0 //resets user mining experience to 0
				M.fexpneeded+=30 //add 30 to users max mining experience
				M << "\green<b> You gain Fishing Acuity..."
		SearchingCheck() //name of proc
			var/mob/players/M = usr
			if(M.seexp >= M.seexpneeded) //if users mining experience is or gos past users max ming experience
				M.searchinglevel+=1 //users mining gos up by 1
				M.seexp=0 //resets user mining experience to 0
				M.seexpneeded+=30 //add 30 to users max mining experience
				M << "\green<b> You gain Searching Acuity..."
		//M.smeexp += 5 //name of proc
		//	var/mob/players/M = usr
		//	if(M.smexp >= M.smexpneeded) //if users mining experience is or gos past users max ming experience
		//		M.smeltinglevel+=1 //users mining gos up by 1
		//		M.smexp=0 //resets user mining experience to 0
		//		M.smexpneeded+=30 //add 30 to users max mining experience
		//		world << "\green<b>[M]'s Smelting Levelup!!"
		/*HuntingCheck() //name of proc
			var/mob/players/M = usr
			if(M.hexp >= M.hexpneeded) //if users mining experience is or gos past users max ming experience
				M.huntinglevel+=1 //users mining gos up by 1
				M.hexp=0 //resets user mining experience to 0
				M.hexpneeded+=30 //add 30 to users max mining experience
				world << "\green<b>[M]'s Mining Levelup!!"
		MiningCheck() //name of proc
			var/mob/players/M = usr
			if(M.mexp >= M.mexpneeded) //if users mining experience is or gos past users max ming experience
				M.mininglevel+=1 //users mining gos up by 1
				M.mexp=0 //resets user mining experience to 0
				M.mexpneeded+=30 //add 30 to users max mining experience
				world << "\green<b>[M]'s Mining Levelup!!"*/
		//M.smiexp += 15 //name of proc
		//	var/mob/players/M = usr
		//	if(M.sexp >= M.sexpneeded) //if users mining experience is or gos past users max ming experience
		//		M.smithinglevel+=1 //users mining gos up by 1
		//		M.sexp=0 //resets user mining experience to 0
		//		M.sexpneeded+=30 //add 30 to users max mining experience
		//		world << "\green<b>[M]'s Smithing Levelup!!"
		DestroyingCheck() //name of proc
			var/mob/players/M = usr
			if(M.dexp >= M.dexpneeded) //if users mining experience is or gos past users max ming experience
				M.destroylevel+=1 //users mining gos up by 1
				M.dexp=0 //resets user mining experience to 0
				M.dexpneeded+=30 //add 30 to users max mining experience
				//world << "\green<b>[M]'s getting better at Destroying..."
				return
	//proc //Procedures
		Destroying() //Name of proc
			set waitfor = 0
			var/mob/players/M = usr
			if(M.Doing == 0)
				if(M.WHequipped == 1) //If user PickAxe is more that or equal to 1
					if(M.destroylevel <= 10) //If user mining skill is less than or equal to 19
						if(prob(30)) //30% probabilty of something happening
							usr << "You begin to destroy..."
							M.Doing = 1
							sleep(30) //Delay 3 seconds

							M.dexp += 25 //user gets 25 mining experience
							DestroyingCheck() //go to proc miningcheck
							usr << "You rest..." //message to user saying he/she mined something
							M.Doing = 0
							return

		Weed1()
			set waitfor = 0
			set popup_menu = 1
			var/mob/players/M = usr
			if(M.Doing == 1)
				M<<"You are preoccupied!"
				return
			else
				if(M.SKequipped==1)
					M<<"You begin to remove the [src]!"
					M.Doing=1
					sleep(15)

					M.Doing=0
					M<<"You finish removing the [src]!"
					del(src)
					return
				else
					M << "Have to use a Sickle to remove [src.name]!"
					return

		Searching() //Name of proc
			set waitfor = 0
			//set popup_menu = 1
		//	set hidden = 0
			//set src in oview(1)
			var/mob/players/M = usr
			var/obj/Flowers/O = src
			//M<<"You are searching!"
			if(M.Doing == 1)
				M<<"You are already searching!"
				return
			if(O.searched==1)
				M<<"You've already searched here!"
				O.searched()
				return
			else
				if(M.searchinglevel <= 1) //If user mining skill is less than or equal to 19
					if(prob(80)) //30% probabilty of something happening
						usr << "You begin to search."
						M.Doing = 1
						sleep(30) //Delay 3 seconds
						M.seexp += 15 //user gets 25 mining experience
						SearchingCheck() //go to proc miningcheck
						new /obj/items/Rock(M,1)
						M << "You found a Rock!"
						O.searched=1
						//var/obj/items/Rock/A = new(M)
						//usr << "You found [A]!" //message to user saying he/she mined something
						M.Doing = 0
						return
					else
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						usr << "You didn't find anything!" //same as before
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					return
				if(M.searchinglevel <= 2)
					if(prob(25)) //30% probabilty of something happening
						usr << "You begin to search."
						M.Doing = 1
						sleep(30) //Delay 3 seconds
						M.seexp += 20 //user gets 25 mining experience
						//M.searchinglevel = 11
						SearchingCheck() //go to proc miningcheck
						new /obj/items/tools/Flint(M,1)
						M << "You found some Flint!"
						O.searched=1
						//var/obj/items/tools/Flint/B = new(M)
						//usr << "You found [B]!" //message to user saying he/she mined something
						M.Doing = 0
						return
					else
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						usr << "You didn't find anything!" //same as before
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					if(prob(10))
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						new /obj/items/Rock(M,1)
						M << "You found a Rock!"
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					else
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						usr << "You didn't find anything!" //same as before
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return

					return//else
				if(M.searchinglevel <= 3) //if user mining is greater than or equal to 20
					if(prob(25)) //30% probabilty
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						M.seexp += 25 //same as before
						new /obj/items/AUS(M,1)
						M << "You found an Ancient Ueik Splinter!"
						O.searched=1
						//var/obj/items/AUS/C = new(M)
						//usr << "You found [C]!" //same as before
						SearchingCheck() //same as before
						M.Doing = 0
						return
					else
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						usr << "You didn't find anything!" //same as before
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					return//else
				if(M.searchinglevel <= 4)
					if(prob(30)) //probabilty of 20%
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						M.seexp += 20 //user mining experiance increases by 30
						//M.searchinglevel = 15
						SearchingCheck() //same as before
						new /obj/items/tools/Pyrite(M,1)
						M << "You found some Pyrite!"
						O.searched=1
						//var/obj/items/tools/Pyrite/D = new(M)
						//usr << "You found [D]!" //message to user saying he/she mined steel ore
						M.Doing = 0
						return
					else
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						usr << "You didn't find anything!" //same as before
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					if(prob(15))
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						new /obj/items/WDHNCH(M,1)
						M << "You found a Wooden Haunch!"
						O.searched=1
						M.seexp += 15 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					else
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						usr << "You didn't find anything!" //same as before
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					return//else
				if(M.searchinglevel >= 5)
					if(prob(35)) //30% probabilty of something happening
						usr << "You begin to search."
						M.Doing = 1
						sleep(10) //Delay 3 seconds
						M.seexp += 25 //user gets 25 mining experience
						SearchingCheck() //go to proc miningcheck
						new /obj/items/tools/Whetstone(M,1)
						M << "You found a Whetstone!"
						O.searched=1
						//var/obj/items/Rock/A = new(M)
						//usr << "You found [A]!" //message to user saying he/she mined something
						M.Doing = 0
						return
					else
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						usr << "You didn't find anything!" //same as before
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					if(prob(25))
						//if(prob(1)) //30% probabilty of something happening
						usr << "You begin to search."
						M.Doing = 1
						sleep(10) //Delay 3 seconds
						M.seexp += 5 //user gets 25 mining experience
						SearchingCheck() //go to proc miningcheck
						new /obj/items/tools/Flint(M,1)
						M << "You found some Flint!"
						O.searched=1
						//var/obj/items/tools/Flint/B = new(M)
						//usr << "You found [B]!" //message to user saying he/she mined something
						M.Doing = 0
						return
					else
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						usr << "You didn't find anything!" //same as before
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					if(prob(25)) //30% probabilty
						usr << "You begin to search."
						M.Doing = 1
						sleep(10) //Delay 3 seconds
						M.seexp += 25 //same as before
						new /obj/items/AUS(M,1)
						M << "You found an Ancient Ueik Splinter!"
						O.searched=1
						//var/obj/items/AUS/C = new(M)
						//usr << "You found [C]!" //same as before
						SearchingCheck() //same as before
						M.Doing = 0
						return
					else
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						usr << "You didn't find anything!" //same as before
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					if(prob(25))
						//if(prob(2)) //probabilty of 20%
						usr << "You begin to search."
						M.Doing = 1
						sleep(10) //Delay 3 seconds
						M.seexp += 10 //user mining experiance increases by 30
						SearchingCheck() //same as before
						new /obj/items/tools/Pyrite(M,1)
						M << "You found some Pyrite!"
						O.searched=1
						//var/obj/items/tools/Pyrite/D = new(M)
						//usr << "You found [D]!" //message to user saying he/she mined steel ore
						M.Doing = 0
						return
					else
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						usr << "You didn't find anything!" //same as before
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					if(prob(20)) //30% probabilty
						usr << "You begin to search."
						M.Doing = 1
						sleep(10) //Delay 3 seconds
						M.seexp += 25 //same as before
						new /obj/items/Carbon(M,1)
						M << "You found Carbon!"
						O.searched=1
						//var/obj/items/AUS/C = new(M)
						//usr << "You found [C]!" //same as before
						SearchingCheck() //same as before
						M.Doing = 0
						return
					else
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						usr << "You didn't find anything!" //same as before
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					if(prob(15))
						//if(prob(2)) //probabilty of 20%
						usr << "You begin to search."
						M.Doing = 1
						sleep(10) //Delay 3 seconds
						M.seexp += 10 //user mining experiance increases by 30
						SearchingCheck() //same as before
						new /obj/items/Rock(M,1)
						M << "You found a Rock!"
						O.searched=1
						//var/obj/items/tools/Pyrite/D = new(M)
						//usr << "You found [D]!" //message to user saying he/she mined steel ore
						M.Doing = 0
						return
					else
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						usr << "You didn't find anything!" //same as before
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					if(prob(15))
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						new /obj/items/WDHNCH(M,1)
						M << "You found a Wooden Haunch!"
						O.searched=1
						M.seexp += 15 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					else
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						usr << "You didn't find anything!" //same as before
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					if(prob(10)) //30% probabilty
						usr << "You begin to search..."
						M.Doing = 1
						sleep(10) //Delay 3 seconds
						M.seexp += 35 //same as before
						new /obj/items/Activated_Carbon(M,1)
						M << "You found Activated Carbon!"
						O.searched=1
						//var/obj/items/AUS/C = new(M)
						//usr << "You found [C]!" //same as before
						SearchingCheck() //same as before
						M.Doing = 0
						return
					else
						//if(prob(40)) //probablity ...
						usr << "You begin to search."
						M.Doing = 1
						sleep(15) //Delay 3 seconds
						usr << "You didn't find anything!" //same as before
						O.searched=1
						M.seexp += 5 //user mining experiance increases by 15
						SearchingCheck() //same as before....
						M.Doing = 0
						return
					return
//Smithing
			//else
			//	usr << "You are already searching!"
		Smithing()//Smith //need to test this thoroughly and implement the smithy system updates (RGB coloring of created tool parts?)
			set waitfor = 0
			set popup_menu = 1
			var/mob/players/M
			M = usr
			var/L00[1]
			L00 = M.smith
			var/L0[1]
			L0 = M.smitht
			var/L[1]
			L = M.smithw
			var/L2[1]
			L2 = M.smithae
			var/L3[1]
			L3 = M.smithl
			var/L4[1]
			L4 = M.smithad
			var/L5[1]
			L5 = M.smithao
			var/L6[1]
			L6 = M.smithm

			//call(/proc/smithingunlock)()
			//call(/proc/smithinglevel)()
			if(M.SMIopen==1)
				//M << "Smithing menu is currently open.."
				return
			if(M.stamina == 0)
				return
			if(M.Doing == 0)
				if(M.HMequipped == 1) //If user Hammer is more than or equal to 1
					SMITHING
					M.SMIopen = 1
					M.UEB = 1
					//M << "Smithing menu is open, tool restriction is set"
					switch(input("What would you like to smith?","Smithing") in L00)//list("Tools","Weapons","Armor","Lamps"))
						//M.SMIopen = 1
						//M.UEB = 1
						if("Cancel")
							M<<"You Cancel Selection..."
							Busy = 0
							M.UEB = 0
							M.SMIopen=0
							return
						if("Back") goto SMITHING
						if("Misc.")
							switch(input("What would you like to make?","Miscellaneous Smithing") in L6)
								if("Cancel")
									M<<"You Cancel Selection..."
									Busy = 0
									M.UEB = 0
									M.SMIopen=0
									return
								if("Back") goto SMITHING
								if("Iron Nails")
									var/obj/items/Ingots/ironbar/IB = locate() in M.contents
									if((IB in M.contents)&&(IB.stack_amount>=1)&&(IB.Tname=="Hot"))
										var/dice = "1d4"
										var/R = roll(dice)
										if(R <= 2)

											var/IN = /obj/items/Crafting/Created/IronNails
											usr << "You begin to smith a handful of Iron Nails."
											M.Doing = 1
											IB.RemoveFromStack(1)
											src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
											sleep(30) //Delay 3 seconds
											M.smiexp += 15 //go to proc miningcheck
											M.stamina -= 5
											M.updateST()
											new IN(M)
											usr << "You smith Iron Nails!" //message to user saying he/she mined something
											//BSB:Tname="Hot"
											src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()
										else
											if((IB in M.contents)&&(IB.stack_amount>=1)&&(IB.Tname=="Hot"))
												var/SCI = /obj/items/Ingots/Scraps/scrapiron
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(1)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												 //user mining skill gos up by 15
												M.smiexp += 15 //....
												M.stamina -= 5
												M.updateST()
												new SCI(M)
												usr << "The materials fail to react well together and produce iron scrap..." //message to user saying he/she didn't mine anything
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												usr<<"You need 1 Hot Iron Ingot for smithing this item..."
												return call(/proc/smithinglevel)()
									else
										usr<<"You need 1 Hot Iron Ingot for smithing this item..."
										M.Doing = 0
										M.UEB = 0
										M.SMIopen=0
										return call(/proc/smithinglevel)()
								if("Iron Ribbon")
									var/obj/items/Ingots/ironbar/IB = locate() in M.contents
									if((IB in M.contents)&&(IB.stack_amount>=1)&&(IB.Tname=="Hot"))
										var/dice = "1d4"
										var/R = roll(dice)
										if(R <= 2)

											var/IR = /obj/items/Crafting/Created/IronRibbon
											usr << "You begin to smith an Iron Ribbon."
											M.Doing = 1
											IB.RemoveFromStack(1)
											src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
											sleep(30) //Delay 3 seconds
											M.smiexp += 15 //go to proc miningcheck
											M.stamina -= 5
											M.updateST()
											new IR(M)
											usr << "You smith an Iron Ribbon!" //message to user saying he/she mined something
											//BSB:Tname="Hot"
											src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()
										else
											if((IB in M.contents)&&(IB.stack_amount>=1)&&(IB.Tname=="Hot"))
												var/SCI = /obj/items/Ingots/Scraps/scrapiron
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(1)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												 //user mining skill gos up by 15
												M.smiexp += 15 //....
												M.stamina -= 5
												M.updateST()
												new SCI(M)
												usr << "The materials fail to react well together and produce iron scrap..." //message to user saying he/she didn't mine anything
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												usr<<"You need 1 Hot Iron Ingot for smithing this item..."
												return call(/proc/smithinglevel)()
									else
										usr<<"You need 1 Hot Iron Ingot for smithing this item..."
										M.Doing = 0
										M.UEB = 0
										M.SMIopen=0
										return call(/proc/smithinglevel)()
						if("Tools")
							switch(input("What Weapon would you like to make?","Tool Smithing") in L0)
								if("Cancel")
									M<<"You Cancel Selection..."
									Busy = 0
									M.UEB = 0
									M.SMIopen=0
									return
								if("Back") goto SMITHING
								if("Carving Knife blade")
									var/obj/items/Ingots/ironbar/IB = locate() in M.contents
									if((IB in M.contents)&&(IB.stack_amount>=1)&&(IB.Tname=="Hot"))
										var/dice = "1d4"
										var/R = roll(dice)
										if(R == 2)
											var/CKB = /obj/items/Crafting/Created/CKnifeblade
											usr << "You begin to smith a Carving Knife Blade."
											M.Doing = 1
											IB.RemoveFromStack(1)
											src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
											sleep(30) //Delay 3 seconds
											M.smiexp += 15 //go to proc miningcheck
											M.stamina -= 5
											M.updateST()
											new CKB(M)
											usr << "You smith a Carving Knife Blade!" //message to user saying he/she mined something
											//BSB:Tname="Hot"
											src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()
										else
											if((IB in M.contents)&&(IB.stack_amount>=1)&&(IB.Tname=="Hot"))
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(1)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												 //user mining skill gos up by 15
												M.smiexp += 15 //....
												M.stamina -= 5
												M.updateST()
												usr << "The materials fail to react well together..." //message to user saying he/she didn't mine anything
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												usr<<"You need 1 Hot Iron Ingot for smithing this item..."
												return call(/proc/smithinglevel)()
									else
										usr<<"You need 1 Hot Iron Ingot for smithing this item..."
										M.Doing = 0
										M.UEB = 0
										M.SMIopen=0
										return call(/proc/smithinglevel)()
								if("Shovel head")
									var/obj/items/Ingots/ironbar/IB = locate() in M.contents
									if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
										var/random/R = rand(1,3)
										if(R == 2)
											var/SHD = /obj/items/Crafting/Created/ShovelHead
											usr << "You begin to smith a Shovel Head."
											M.Doing = 1
											IB.RemoveFromStack(3)
											src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
											sleep(30) //Delay 3 seconds
											M.smiexp += 15 //go to proc miningcheck
											M.stamina -= 5
											M.updateST()
											new SHD(M)
											usr << "You smith a Shovel Head!" //message to user saying he/she mined something
											//BSB:Tname="Hot"
											src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()
										else
											if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(3)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												 //user mining skill gos up by 15
												M.smiexp += 15 //....
												M.stamina -= 5
												M.updateST()
												usr << "The materials fail to react well together..." //message to user saying he/she didn't mine anything
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												usr<<"You need 3 Hot Iron Ingot for smithing this item..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
									else
										usr<<"You need 3 Hot Iron Ingot for smithing this item..."
										M.Doing = 0
										M.UEB = 0
										M.SMIopen=0
										return call(/proc/smithinglevel)()
								if("Axe head")
									var/obj/items/Ingots/ironbar/IB = locate() in M.contents
									if((IB in M.contents)&&(IB.stack_amount>=2)&&(IB.Tname=="Hot")&&(M.stamina>=5))
										var/dice = "1d4"
										var/R = roll(dice)
										if(R == 2)
											var/AHD = /obj/items/Crafting/Created/AxeHead
											usr << "You begin to smith a Axe Head."
											M.Doing = 1
											IB.RemoveFromStack(2)
											src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
											sleep(30) //Delay 3 seconds
											M.smiexp += 15 //go to proc miningcheck
											M.stamina -= 5
											M.updateST()
											new AHD(M)
											usr << "You smith a Axe Head!" //message to user saying he/she mined something
											//BSB:Tname="Hot"
											src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()
										else
											if((IB in M.contents)&&(IB.stack_amount>=2)&&(IB.Tname=="Hot"))
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(2)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												 //user mining skill gos up by 15
												M.smiexp += 15 //....
												M.stamina -= 5
												M.updateST()
												usr << "The materials fail to react well together..." //message to user saying he/she didn't mine anything
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												usr<<"You need 2 Hot Iron Ingot for smithing this item..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
									else
										usr<<"You need 2 Hot Iron Ingot for smithing this item..."
										return 0
								if("Pickaxe head")
									var/obj/items/Ingots/ironbar/IB = locate() in M.contents
									if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
										var/dice = "1d4"
										var/R = roll(dice)
										if(R == 2)
											var/PHD = /obj/items/Crafting/Created/PickaxeHead
											usr << "You begin to smith a Pickaxe Head."
											M.Doing = 1
											IB.RemoveFromStack(3)
											src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
											sleep(30) //Delay 3 seconds
											M.smiexp += 15 //go to proc miningcheck
											M.stamina -= 5
											M.updateST()
											new PHD(M)
											usr << "You smith a Pickaxe Head!" //message to user saying he/she mined something
											//BSB:Tname="Hot"
											src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()
										else
											if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(3)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												 //user mining skill gos up by 15
												M.smiexp += 15 //....
												M.stamina -= 5
												M.updateST()
												usr << "The materials fail to react well together..." //message to user saying he/she didn't mine anything
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												usr<<"You need 3 Hot Iron Ingot for smithing this item..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
									else
										usr<<"You need 3 Hot Iron Ingot for smithing this item..."
										M.Doing = 0
										M.UEB = 0
										M.SMIopen=0
										return call(/proc/smithinglevel)()
								if("Hammer head")
									var/obj/items/Ingots/ironbar/IB = locate() in M.contents
									if((IB in M.contents)&&(IB.stack_amount>=1)&&(IB.Tname=="Hot"))
										var/dice = "1d4"
										var/R = roll(dice)
										if(R == 2)
											var/HHD = /obj/items/Crafting/Created/ShovelHead
											usr << "You begin to smith a Hammer Head."
											M.Doing = 1
											IB.RemoveFromStack(1)
											src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
											sleep(30) //Delay 3 seconds
											M.smiexp += 15 //go to proc miningcheck
											M.stamina -= 5
											M.updateST()
											new HHD(M)
											usr << "You smith a Hammer Head!" //message to user saying he/she mined something
											//BSB:Tname="Hot"
											src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()
										else
											if((IB in M.contents)&&(IB.stack_amount>=1)&&(IB.Tname=="Hot"))
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(1)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												 //user mining skill gos up by 15
												M.smiexp += 15 //....
												M.stamina -= 5
												M.updateST()
												usr << "The materials fail to react well together..." //message to user saying he/she didn't mine anything
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												usr<<"You need 1 Hot Iron Ingot for smithing this item..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
									else
										usr<<"You need 1 Hot Iron Ingot for smithing this item..."
										M.Doing = 0
										M.UEB = 0
										M.SMIopen=0
										return call(/proc/smithinglevel)()
								if("Hoe blade")
									var/obj/items/Ingots/ironbar/IB = locate() in M.contents
									if((IB in M.contents)&&(IB.stack_amount>=2)&&(IB.Tname=="Hot"))
										var/dice = "1d4"
										var/R = roll(dice)
										if(R == 2)
											var/HBD = /obj/items/Crafting/Created/HoeBlade
											usr << "You begin to smith a Hoe blade."
											M.Doing = 1
											IB.RemoveFromStack(2)
											src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
											sleep(30) //Delay 3 seconds
											M.smiexp += 15 //go to proc miningcheck
											M.stamina -= 5
											M.updateST()
											new HBD(M)
											usr << "You smith a Hoe Blade!" //message to user saying he/she mined something
											//BSB:Tname="Hot"
											src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()
										else
											if((IB in M.contents)&&(IB.stack_amount>=2)&&(IB.Tname=="Hot"))
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(2)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												 //user mining skill gos up by 15
												M.smiexp += 15 //....
												M.stamina -= 5
												M.updateST()
												usr << "The materials fail to react well together..." //message to user saying he/she didn't mine anything
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												usr<<"You need 2 Hot Iron Ingot for smithing this item..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
									else
										usr<<"You need 2 Hot Iron Ingot for smithing this item..."
										M.Doing = 0
										M.UEB = 0
										M.SMIopen=0
										return call(/proc/smithinglevel)()
								if("Sickle blade")
									var/obj/items/Ingots/ironbar/IB = locate() in M.contents
									if((IB in M.contents)&&(IB.stack_amount>=2)&&(IB.Tname=="Hot"))
										var/dice = "1d4"
										var/R = roll(dice)
										if(R == 2)
											var/SBD = /obj/items/Crafting/Created/SickleBlade
											usr << "You begin to smith a Sickle blade."
											M.Doing = 1
											IB.RemoveFromStack(2)
											src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
											sleep(30) //Delay 3 seconds
											M.smiexp += 15 //go to proc miningcheck
											M.stamina -= 5
											M.updateST()
											new SBD(M)
											usr << "You smith a Sickle Blade!" //message to user saying he/she mined something
											//BSB:Tname="Hot"
											src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()
										else
											if((IB in M.contents)&&(IB.stack_amount>=2)&&(IB.Tname=="Hot"))
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(2)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												 //user mining skill gos up by 15
												M.smiexp += 15 //....
												M.stamina -= 5
												M.updateST()
												usr << "The materials fail to react well together..." //message to user saying he/she didn't mine anything
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												usr<<"You need 2 Hot Iron Ingot for smithing this item..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
									else
										usr<<"You need 2 Hot Iron Ingot for smithing this item..."
										M.Doing = 0
										M.UEB = 0
										M.SMIopen=0
										return call(/proc/smithinglevel)()
								if("Chisel blade")
									var/obj/items/Ingots/ironbar/IB = locate() in M.contents
									if((IB in M.contents)&&(IB.stack_amount>=2)&&(IB.Tname=="Hot"))
										var/dice = "1d4"
										var/R = roll(dice)
										if(R == 2)
											var/CHBD = /obj/items/Crafting/Created/ChiselBlade
											usr << "You begin to smith a Chisel blade."
											M.Doing = 1
											IB.RemoveFromStack(2)
											src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
											sleep(30) //Delay 3 seconds
											M.smiexp += 15 //go to proc miningcheck
											M.stamina -= 5
											M.updateST()
											new CHBD(M)
											usr << "You smith a Chisel Blade!" //message to user saying he/she mined something
											//BSB:Tname="Hot"
											src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()
										else
											if((IB in M.contents)&&(IB.stack_amount>=2)&&(IB.Tname=="Hot"))
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(2)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												 //user mining skill gos up by 15
												M.smiexp += 15 //....
												M.stamina -= 5
												M.updateST()
												usr << "The materials fail to react well together..." //message to user saying he/she didn't mine anything
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												usr<<"You need 2 Hot Iron Ingot for smithing this item..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
									else
										usr<<"You need 2 Hot Iron Ingot for smithing this item..."
										M.Doing = 0
										M.UEB = 0
										M.SMIopen=0
										return call(/proc/smithinglevel)()
								if("File blade")
									var/obj/items/Ingots/ironbar/IB = locate() in M.contents
									//var/obj/items/Crafting/Created/FileBlade/FB// = locate() in M.contents
									//var/FB
									if((IB in M.contents)&&(IB.stack_amount>=1)&&(IB.Tname=="Hot"))
										var/dice = "1d4"
										var/R = roll(dice)
										if(R <= 2)
											var/FIBD = /obj/items/Crafting/Created/FileBlade

											usr << "You begin to smith a File blade."
											M.Doing = 1
											IB.RemoveFromStack(1)
											src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
											sleep(30) //Delay 3 seconds
											M.smiexp += 15 //go to proc miningcheck
											M.stamina -= 5
											M.updateST()

											//new /obj/items/Crafting/Created/FileBlade(M)

											// = rgb(rand(0,15),rand(0,15),rand(0,15))
											new FIBD(M)
											locate(FIBD) in M
											if(FIBD in M)
												for(FIBD in M)
													Tname="Hot"
													overlays += image('dmi/64/creation.dmi',icon_state="FileBlade",rgb(24,21,21))
											//for(FB in M)
												//FB.color = rgb(rand(170,185),rand(170,175),rand(170,174))
												//obj.color = rgb(24,21,21)
											usr << "You smith a File Blade!" //message to user saying he/she mined something
											//BSB:Tname="Hot"

											src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()
										else
											if((IB in M.contents)&&(IB.stack_amount>=1)&&(IB.Tname=="Hot"))
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(1)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												 //user mining skill gos up by 15
												M.smiexp += 15 //....
												M.stamina -= 5
												M.updateST()
												usr << "The materials fail to react well together..." //message to user saying he/she didn't mine anything
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												usr<<"You need 1 Hot Iron Ingot for smithing this item..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
									else
										usr<<"You need 1 Hot Iron Ingot for smithing this item..."
										M.Doing = 0
										M.UEB = 0
										M.SMIopen=0
										return call(/proc/smithinglevel)()
								if("Saw blade")
									var/obj/items/Ingots/ironbar/IB = locate() in M.contents
									if((IB in M.contents)&&(IB.stack_amount>=2)&&(IB.Tname=="Hot"))
										var/dice = "1d4"
										var/R = roll(dice)
										if(R == 2)
											var/SWBD = /obj/items/Crafting/Created/SawBlade
											usr << "You begin to smith a Saw blade."
											M.Doing = 1
											IB.RemoveFromStack(2)
											src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
											sleep(30) //Delay 3 seconds
											M.smiexp += 15 //go to proc miningcheck
											M.stamina -= 5
											M.updateST()
											new SWBD(M)
											usr << "You smith a Saw Blade!" //message to user saying he/she mined something
											//BSB:Tname="Hot"
											src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()
										else
											if((IB in M.contents)&&(IB.stack_amount>=2)&&(IB.Tname=="Hot"))
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(2)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												 //user mining skill gos up by 15
												M.smiexp += 15 //....
												M.stamina -= 5
												M.updateST()
												usr << "The materials fail to react well together..." //message to user saying he/she didn't mine anything
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												usr<<"You need 2 Hot Iron Ingot for smithing this item..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
									else
										usr<<"You need 2 Hot Iron Ingot for smithing this item..."
										M.Doing = 0
										M.UEB = 0
										M.SMIopen=0
										return call(/proc/smithinglevel)()
//Steel Parts
								if("Trowel blade")
									var/obj/items/Ingots/steelbar/SB = locate() in M.contents
									if((SB in M.contents)&&(SB.stack_amount>=3)&&(SB.Tname=="Hot"))
										var/dice = "1d4"
										var/R = roll(dice)
										if(R == 2)
											var/TWBD = /obj/items/Crafting/Created/TrowelBlade
											usr << "You begin to smith a Trowel blade."
											M.Doing = 1
											SB.RemoveFromStack(3)
											src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
											sleep(30) //Delay 3 seconds
											M.smiexp += 15 //go to proc miningcheck
											M.stamina -= 5
											M.updateST()
											new TWBD(M)
											usr << "You smith a Trowel Blade!" //message to user saying he/she mined something
											//BSB:Tname="Hot"
											src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()
										else
											if((SB in M.contents)&&(SB.stack_amount>=1)&&(SB.Tname=="Hot"))
												usr << "You begin to smith."
												M.Doing = 1
												SB.RemoveFromStack(3)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												 //user mining skill gos up by 15
												M.smiexp += 15 //....
												M.stamina -= 5
												M.updateST()
												usr << "The materials fail to react well together..." //message to user saying he/she didn't mine anything
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												usr<<"You need 3 Hot Steel Ingot for smithing this item..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
									else
										usr<<"You need 3 Hot Steel Ingot for smithing this item..."
										M.Doing = 0
										M.UEB = 0
										M.SMIopen=0
										return call(/proc/smithinglevel)()
								if("Iron Reel")
									var/obj/items/Ingots/ironbar/IB = locate() in M.contents
									if((IB in M.contents)&&(IB.stack_amount>=1)&&(IB.Tname=="Hot"))
										var/dice = "1d4"
										var/R = roll(dice)
										if(R == 2)
											var/IR = /obj/items/Crafting/Created/FishingPoleReel
											usr << "You begin to smith an Iron Reel."
											M.Doing = 1
											IB.RemoveFromStack(1)
											src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
											sleep(30) //Delay 3 seconds
											M.smiexp += 15 //go to proc miningcheck
											M.stamina -= 5
											M.updateST()
											new IR(M)
											usr << "You smith an Iron Reel!" //message to user saying he/she mined something
											//BSB:Tname="Hot"
											src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()
										else
											if((IB in M.contents)&&(IB.stack_amount>=1)&&(IB.Tname=="Hot"))
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(1)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												 //user mining skill gos up by 15
												M.smiexp += 15 //....
												M.stamina -= 5
												M.updateST()
												usr << "The materials fail to react well together..." //message to user saying he/she didn't mine anything
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												usr<<"You need 1 Hot Iron Ingot for smithing this item..."
												return call(/proc/smithinglevel)()
									else
										usr<<"You need 1 Hot Iron Ingot for smithing this item..."
										M.Doing = 0
										M.UEB = 0
										M.SMIopen=0
										return call(/proc/smithinglevel)()
							if("Weapons")//Need to add ORPG weapons
								switch(input("What Weapon would you like to make?","Weapon Smithing") in L)// in list("Broad Sword"))
									if("Cancel")
										M<<"You Cancel Selection..."
										Busy = 0
										M.UEB = 0
										M.SMIopen=0
										return
									if("Back") goto SMITHING
									if("Broad Sword")
										var/obj/items/Ingots/ironbar/IB = locate() in M.contents
										if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
											var/dice = "1d6"
											var/R = roll(dice)
											if(R == 2)
												var/BSB = /obj/items/Crafting/Created/Broadswordblade
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(3)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												M.smiexp += 15 //go to proc miningcheck
												M.stamina -= 5
												M.updateST()
												new BSB(locate(x,y,z))
												usr << "You smith a Broad Sword Blade!" //message to user saying he/she mined something
												//BSB:Tname="Hot"
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
													usr << "You begin to smith."
													M.Doing = 1
													IB.RemoveFromStack(3)
													src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
													sleep(30) //Delay 3 seconds
													 //user mining skill gos up by 15
													M.smiexp += 15 //....
													M.stamina -= 5
													M.updateST()
													usr << "The materials fail to react well together..." //message to user saying he/she didn't mine anything
													src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
												else
													usr<<"You need 3 Iron Hot Ingots for smithing this item..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
										else
											usr<<"You need 3 Iron Hot Ingots for smithing this item..."
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()

									if("War Sword")
										//var/obj/items/tools/BroadSword/BS
										//var/random/R = rand(1,5) //1 in 5 chance to smith
										var/obj/items/Ingots/ironbar/IB = locate() in M.contents
										if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
											//var/obj/items/tools/BroadSword/BS
											var/dice = "1d6"
											var/R = roll(dice)
											if(R == 2)
												var/WSWB = /obj/items/Crafting/Created/Warswordblade
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(3)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												M.smiexp += 15 //go to proc miningcheck
												M.stamina -= 5
												M.updateST()
												new WSWB(locate(x,y,z))
												usr << "You smith a War Sword Blade!" //message to user saying he/she mined something
												//BSB:Tname="Hot"
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
													usr << "You begin to smith."
													M.Doing = 1
													IB.RemoveFromStack(3)
													src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
													sleep(30) //Delay 3 seconds
													 //user mining skill gos up by 15
													M.smiexp += 15 //....
													M.stamina -= 5
													M.updateST()
													usr << "The materials fail to react well..." //message to user saying he/she didn't mine anything
													src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
												else
													usr<<"You need 3 Iron Hot Ingots for smithing this item..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
										else
											usr<<"You need 3 Iron Hot Ingots for smithing this item..."
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()

									if("Battle Sword")
										//var/obj/items/tools/BroadSword/BS
										//var/random/R = rand(1,5) //1 in 5 chance to smith
										var/obj/items/Ingots/ironbar/IB = locate() in M.contents
										if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
											//var/obj/items/tools/BroadSword/BS
											var/dice = "1d6"
											var/R = roll(dice)
											if(R == 2)
												var/BSWB = /obj/items/Crafting/Created/Battleswordblade
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(3)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												M.smiexp += 15 //go to proc miningcheck
												M.stamina -= 5
												M.updateST()
												new BSWB(locate(x,y,z))
												usr << "You smith a Battle Sword Blade!" //message to user saying he/she mined something
												//BSB:Tname="Hot"
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
													usr << "You begin to smith."
													M.Doing = 1
													IB.RemoveFromStack(3)
													src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
													sleep(30) //Delay 3 seconds
													 //user mining skill gos up by 15
													M.smiexp += 15 //....
													M.stamina -= 5
													M.updateST()
													usr << "The materials fail to react well..." //message to user saying he/she didn't mine anything
													src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
												else
													usr<<"You need 3 Hot Iron Ingots to utilize for smithing this item..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
										else
											usr<<"You need 3 Hot Iron Ingots to utilize for smithing this item..."
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()

									if("Long Sword")
										//var/obj/items/tools/BroadSword/BS
										//var/random/R = rand(1,5) //1 in 5 chance to smith
										var/obj/items/Ingots/ironbar/IB = locate() in M.contents
										if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
											//var/obj/items/tools/BroadSword/BS
											var/dice = "1d6"
											var/R = roll(dice)
											if(R == 2)
												var/BSWB = /obj/items/Crafting/Created/Longswordblade
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(3)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												M.smiexp += 15 //go to proc miningcheck
												M.stamina -= 5
												M.updateST()
												new BSWB(locate(x,y,z))
												usr << "You smith a Long Sword Blade!" //message to user saying he/she mined something
												//BSB:Tname="Hot"
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
													usr << "You begin to smith."
													M.Doing = 1
													IB.RemoveFromStack(3)
													src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
													sleep(30) //Delay 3 seconds
													 //user mining skill gos up by 15
													M.smiexp += 15 //....
													M.stamina -= 5
													M.updateST()
													usr << "The materials fail to react well..." //message to user saying he/she didn't mine anything
													src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
												else
													usr<<"You need 3 Hot Iron Ingots to utilize for smithing this item..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
										else
											usr<<"You need 3 Hot Iron Ingots to utilize for smithing this item..."
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()

									if("Battle Hammer")
										//var/obj/items/tools/BroadSword/BS
										//var/random/R = rand(1,5) //1 in 5 chance to smith
										var/obj/items/Ingots/ironbar/IB = locate() in M.contents
										if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
											//var/obj/items/tools/BroadSword/BS
											var/dice = "1d6"
											var/R = roll(dice)
											if(R == 2)
												var/BHS = /obj/items/Crafting/Created/Battlehammersledge
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(3)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												M.smiexp += 15 //go to proc miningcheck
												M.stamina -= 5
												M.updateST()
												new BHS(locate(x,y,z))
												usr << "You smith a Battle Hammer Sledge!" //message to user saying he/she mined something
												//BHS:Tname="Hot"
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
													usr << "You begin to smith."
													M.Doing = 1
													IB.RemoveFromStack(3)
													src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
													sleep(30) //Delay 3 seconds
													 //user mining skill gos up by 15
													M.smiexp += 15 //....
													M.stamina -= 5
													M.updateST()
													usr << "The materials fail to react well..." //message to user saying he/she didn't mine anything
													src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
												else
													usr<<"You need 3 Iron Hot Ingots for smithing this item..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
										else
											usr<<"You need 3 Iron Hot Ingots for smithing this item..."
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()

									if("War Scythe")
										//var/obj/items/tools/BroadSword/BS
										//var/random/R = rand(1,5) //1 in 5 chance to smith
										var/obj/items/Ingots/ironbar/IB = locate() in M.contents
										if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
											//var/obj/items/tools/BroadSword/BS
											var/dice = "1d6"
											var/R = roll(dice)
											if(R == 2)
												var/WSB = /obj/items/Crafting/Created/Warscytheblade
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(3)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												M.smiexp += 15 //go to proc miningcheck
												M.stamina -= 5
												M.updateST()
												new WSB(locate(x,y,z))
												usr << "You smith a War Scythe Blade!" //message to user saying he/she mined something
												//BSB:Tname="Hot"
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
													usr << "You begin to smith."
													M.Doing = 1
													IB.RemoveFromStack(3)
													src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
													sleep(30) //Delay 3 seconds
													 //user mining skill gos up by 15
													M.smiexp += 15 //....
													M.stamina -= 5
													M.updateST()
													usr << "The materials fail to react well..." //message to user saying he/she didn't mine anything
													src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
												else
													usr<<"You need 3 Iron Hot Ingots for smithing this item..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
										else
											usr<<"You need 3 Iron Hot Ingots for smithing this item..."
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()

									if("Battle Scythe")
										//var/obj/items/tools/BroadSword/BS
										//var/random/R = rand(1,5) //1 in 5 chance to smith
										var/obj/items/Ingots/ironbar/IB = locate() in M.contents
										if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
											//var/obj/items/tools/BroadSword/BS
											var/dice = "1d6"
											var/R = roll(dice)
											if(R == 2)
												var/BSCB = /obj/items/Crafting/Created/Battlescytheblade
												usr << "You begin to smith."
												M.Doing = 1
												IB.RemoveFromStack(3)
												src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
												sleep(30) //Delay 3 seconds
												M.smiexp += 15 //go to proc miningcheck
												M.stamina -= 5
												M.updateST()
												new BSCB(locate(x,y,z))
												usr << "You smith a Broad Scythe Blade!" //message to user saying he/she mined something
												//BSB:Tname="Hot"
												src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
											else
												if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot"))
													usr << "You begin to smith."
													M.Doing = 1
													IB.RemoveFromStack(3)
													src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
													sleep(30) //Delay 3 seconds
													 //user mining skill gos up by 15
													M.smiexp += 15 //....
													M.stamina -= 5
													M.updateST()
													usr << "The materials fail to react well..." //message to user saying he/she didn't mine anything
													src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
												else
													usr<<"You need 3 Iron Hot Ingots for smithing this item..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
										else
											usr<<"You need 3 Iron Hot Ingots for smithing this item..."
											M.Doing = 0
											M.UEB = 0
											M.SMIopen=0
											return call(/proc/smithinglevel)()


							//call(/proc/smithinglevel)(M)
							if("Armor")
								ARMOR
								switch(input("What Type of armor would you like to smith?","Smithing Armor Type") in list("Evasive","Defensive","Offensive","Cancel","Back"))
									if("Cancel")
										M<<"You Cancel Selection..."
										Busy = 0
										M.UEB = 0
										return
									if("Back") goto ARMOR
									if("Evasive")
										switch(input("What Armor would you like to make?","Evasive Armor Smithing") in L2)//in list())
											if("Cancel")
												M<<"You Cancel Selection..."
												Busy = 0
												M.UEB = 0
												M.SMIopen=0
												return
											if("Back") goto ARMOR
											if("Giu Hide Vestments")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/copperbar/CB = locate() in M.contents
												var/obj/items/CParts/GiuHide/GH0 = locate() in M.contents
												if((CB in M.contents)&&(CB.stack_amount>=2)&&(CB.Tname=="Hot")&&(GH0 in M.contents)&&(GH0.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/avgvestments
														usr << "You begin to smith."
														M.Doing = 1
														CB.RemoveFromStack(2)
														GH0.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Giu Hide Vestments!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((CB in M.contents)&&(CB.stack_amount>=2)&&(CB.Tname=="Hot")&&(GH0 in M.contents)&&(GH0.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															CB.RemoveFromStack(2)
															GH0.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Giu Hide and 2 Hot Copper Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Giu Hide and 2 Hot Copper Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Giu Shell Vestments")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/copperbar/CB = locate() in M.contents
												var/obj/items/CParts/GiuShell/GS1 = locate() in M.contents
												if((CB in M.contents)&&(CB.stack_amount>=2)&&(CB.Tname=="Hot")&&(GS1 in M.contents)&&(GS1.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/unuvestments
														usr << "You begin to smith."
														M.Doing = 1
														CB.RemoveFromStack(2)
														GS1.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Giu Shell Vestments!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((CB in M.contents)&&(CB.stack_amount>=2)&&(CB.Tname=="Hot")&&(GS1 in M.contents)&&(GS1.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															CB.RemoveFromStack(2)
															GS1.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need a Giu Shell and 2 Hot Copper Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need a Giu Shell and 2 Hot Copper Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Gou ShellHide Vestments")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/bronzebar/BRB = locate() in M.contents
												var/obj/items/CParts/GouHide/GH2 = locate() in M.contents
												var/obj/items/CParts/GouShell/GS2 = locate() in M.contents
												if((BRB in M.contents)&&(BRB.stack_amount>=3)&&(BRB.Tname=="Hot")&&(GH2 in M.contents)&&(GS2 in M.contents)&&(GH2.stack_amount>=1)&&(GS2.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/uncovestments
														usr << "You begin to smith."
														M.Doing = 1
														BRB.RemoveFromStack(3)
														GH2.RemoveFromStack(1)
														GS2.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Gou ShellHide Vestments!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((BRB in M.contents)&&(BRB.stack_amount>=3)&&(BRB.Tname=="Hot")&&(GH2 in M.contents)&&(GS2 in M.contents)&&(GH2.stack_amount>=1)&&(GS2.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															BRB.RemoveFromStack(3)
															GH2.RemoveFromStack(1)
															GS2.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gou Shell, Gou Hide and 3 Hot Bronze Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gou Shell, Gou Hide and 3 Hot Bronze Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Coppermail Vestments")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/copperbar/CB = locate() in M.contents
												var/obj/items/CParts/GowHide/GH3 = locate() in M.contents
												if((CB in M.contents)&&(CB.stack_amount>=2)&&(CB.Tname=="Hot")&&(GH3 in M.contents)&&(GH3.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/choivestments
														usr << "You begin to smith."
														M.Doing = 1
														CB.RemoveFromStack(2)
														GH3.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Coppermail Vestments!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((CB in M.contents)&&(CB.stack_amount>=2)&&(CB.Tname=="Hot")&&(GH3 in M.contents)&&(GH3.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															CB.RemoveFromStack(2)
															GH3.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need a Gow Hide and 2 Hot Copper Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need a Gow Hide and 2 Hot Copper Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Zinc ShellPlate Vestments")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/zincbar/ZB = locate() in M.contents
												var/obj/items/CParts/GuwiShell/GS4 = locate() in M.contents
												if((ZB in M.contents)&&(ZB.stack_amount>=3)&&(ZB.Tname=="Hot")&&(GS4 in M.contents)&&(GS4.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/ordivestments
														usr << "You begin to smith."
														M.Doing = 1
														ZB.RemoveFromStack(3)
														GS4.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Zinc ShellPlate Vestments!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((ZB in M.contents)&&(ZB.stack_amount>=3)&&(ZB.Tname=="Hot")&&(GS4 in M.contents)&&(GS4.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															ZB.RemoveFromStack(3)
															GS4.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Guwi Shell and 3 Hot Zinc Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Guwi Shell and 3 Hot Zinc Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Steel ShellPlate Vestments")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/steelbar/STLB = locate() in M.contents
												var/obj/items/CParts/GowuShell/GS5 = locate() in M.contents
												if((STLB in M.contents)&&(STLB.stack_amount>=3)&&(STLB.Tname=="Hot")&&(GS5 in M.contents)&&(GS5.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/sinvestments
														usr << "You begin to smith."
														M.Doing = 1
														STLB.RemoveFromStack(3)
														GS5.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Steel ShellPlate Vestments!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((STLB in M.contents)&&(STLB.stack_amount>=3)&&(STLB.Tname=="Hot")&&(GS5 in M.contents)&&(GS5.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															STLB.RemoveFromStack(3)
															GS5.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gowu Shell and 3 Hot Steel Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gowu Shell and 3 Hot Steel Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()

											if("Monk Tunic")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/copperbar/CB = locate() in M.contents
												//var/obj/items/GiuShell/GS0 = locate() in M.contents
												var/obj/items/CParts/GiuHide/GH0 = locate() in M.contents
												if((CB in M.contents)&&(CB.stack_amount>=2)&&(CB.Tname=="Hot")&&/*(GS0 in M.contents)&&(GS0.stack_amount>=1)&&*/(GH0 in M.contents)&&(GH0.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/avgtunic
														usr << "You begin to smith."
														M.Doing = 1
														CB.RemoveFromStack(2)
														//GS0.RemoveFromStack(1)
														GH0.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Monk Tunic!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((CB in M.contents)&&(CB.stack_amount>=2)&&(CB.Tname=="Hot")/*&&(GS0 in M.contents)&&(GS0.stack_amount>=1)*/&&(GH0 in M.contents)&&(GH0.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															CB.RemoveFromStack(2)
															//GS0.RemoveFromStack(1)
															GH0.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Giu Hide and 2 Hot Copper Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Giu Hide and 2 Hot Copper Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Iron Studded Tunic")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/ironbar/IB = locate() in M.contents
												var/obj/items/CParts/GouHide/GH1 = locate() in M.contents
												//var/obj/items/GouShell/GS1 = locate() in M.contents
												if((IB in M.contents)&&(IB.stack_amount>=2)&&(IB.Tname=="Hot")&&(GH1 in M.contents)&&(GH1.stack_amount>=1))//&&(GS1 in M.contents)&&(GS1.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/unutunic
														usr << "You begin to smith."
														M.Doing = 1
														IB.RemoveFromStack(2)
														GH1.RemoveFromStack(1)
														//GS1.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Iron Studded Tunic!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((IB in M.contents)&&(IB.stack_amount>=2)&&(IB.Tname=="Hot")&&(GH1 in M.contents)&&(GH1.stack_amount>=1))//&&(GS1 in M.contents)&&(GS1.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															IB.RemoveFromStack(2)
															GH1.RemoveFromStack(1)
															//GS1.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gou Hide and 2 Hot Iron Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gou Hide and 2 Hot Iron Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Copper ShellPlate Tunic")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/copperbar/CB = locate() in M.contents
												var/obj/items/CParts/GouHide/GH2 = locate() in M.contents
												var/obj/items/CParts/GouShell/GS2 = locate() in M.contents
												if((CB in M.contents)&&(CB.stack_amount>=2)&&(CB.Tname=="Hot")&&(GH2 in M.contents)&&(GH2.stack_amount>=1)&&(GS2 in M.contents)&&(GS2.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/uncotunic
														usr << "You begin to smith."
														M.Doing = 1
														CB.RemoveFromStack(2)
														GH2.RemoveFromStack(1)
														GS2.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Copper ShellPlate Tunic!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((CB in M.contents)&&(CB.stack_amount>=2)&&(CB.Tname=="Hot")&&(GH2 in M.contents)&&(GH2.stack_amount>=1)&&(GS2 in M.contents)&&(GS2.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															CB.RemoveFromStack(2)
															GH2.RemoveFromStack(1)
															GS2.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gou Shell, Gou Hide and 2 Hot Copper Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gou Shell, Gou Hide and 2 Hot Copper Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Bronzemail Tunic")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/bronzebar/BRB = locate() in M.contents
												var/obj/items/CParts/GowHide/GH3 = locate() in M.contents
												if((BRB in M.contents)&&(BRB.stack_amount>=2)&&(BRB.Tname=="Hot")&&(GH3 in M.contents)&&(GH3.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/choitunic
														usr << "You begin to smith."
														M.Doing = 1
														BRB.RemoveFromStack(2)
														GH3.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Bronzemail Tunic!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((BRB in M.contents)&&(BRB.stack_amount>=2)&&(BRB.Tname=="Hot")&&(GH3 in M.contents)&&(GH3.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															BRB.RemoveFromStack(2)
															GH3.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gow Hide and 2 Hot Bronze Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gow Hide and 2 Hot Bronze Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Zincmail Tunic")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/zincbar/ZB = locate() in M.contents
												var/obj/items/CParts/GuwiHide/GH4 = locate() in M.contents
												if((ZB in M.contents)&&(ZB.stack_amount>=2)&&(ZB.Tname=="Hot")&&(GH4 in M.contents)&&(GH4.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/orditunic
														usr << "You begin to smith."
														M.Doing = 1
														ZB.RemoveFromStack(2)
														GH4.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Zincmail Tunic!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((ZB in M.contents)&&(ZB.stack_amount>=2)&&(ZB.Tname=="Hot")&&(GH4 in M.contents)&&(GH4.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															ZB.RemoveFromStack(2)
															GH4.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Guwi Hide and 2 Hot Zinc Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Guwi Hide and 2 Hot Zinc Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Landscaper Tunic")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/steelbar/STLB = locate() in M.contents
												var/obj/items/CParts/GowuShell/GS5 = locate() in M.contents
												var/obj/items/CParts/GowuHide/GH5 = locate() in M.contents
												if((STLB in M.contents)&&(STLB.stack_amount>=2)&&(STLB.Tname=="Hot")&&(GS5 in M.contents)&&(GH5 in M.contents)&&(GS5.stack_amount>=1)&&(GH5.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/sintunic
														usr << "You begin to smith."
														M.Doing = 1
														STLB.RemoveFromStack(2)
														GS5.RemoveFromStack(1)
														GH5.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Landscaper Tunic!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((STLB in M.contents)&&(STLB.stack_amount>=2)&&(STLB.Tname=="Hot")&&(GS5 in M.contents)&&(GH5 in M.contents)&&(GS5.stack_amount>=1)&&(GH5.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															STLB.RemoveFromStack(2)
															GS5.RemoveFromStack(1)
															GH5.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gowu Shell, Gowu Hide and 2 Hot Steel Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gowu Shell, Gowu Hide and 2 Hot Steel Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()

											if("Giu ShellHide Corslet")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/bronzebar/BRB = locate() in M.contents
												var/obj/items/CParts/GiuShell/GS0 = locate() in M.contents
												var/obj/items/CParts/GiuHide/GH0 = locate() in M.contents
												if((BRB in M.contents)&&(BRB.stack_amount>=3)&&(BRB.Tname=="Hot")&&(GS0 in M.contents)&&(GH0 in M.contents)&&(GS0.stack_amount>=1)&&(GH0.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/avgcorslet
														usr << "You begin to smith."
														M.Doing = 1
														BRB.RemoveFromStack(3)
														GS0.RemoveFromStack(1)
														GH0.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Giu ShellHide Corslet!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((BRB in M.contents)&&(BRB.stack_amount>=3)&&(BRB.Tname=="Hot")&&(GS0 in M.contents)&&(GH0 in M.contents)&&(GS0.stack_amount>=1)&&(GH0.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															BRB.RemoveFromStack(3)
															GS0.RemoveFromStack(1)
															GH0.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Giu Shell, Giu Hide and 3 Hot Bronze Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Giu Shell, Giu Hide and 3 Hot Bronze Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Gou ShellPlate Corslet")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/ironbar/IB = locate() in M.contents
												var/obj/items/CParts/GouShell/GS1 = locate() in M.contents
												var/obj/items/CParts/GouHide/GH1 = locate() in M.contents
												if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot")&&(GS1 in M.contents)&&(GS1.stack_amount>=1)&&(GH1 in M.contents)&&(GH1.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/unucorslet
														usr << "You begin to smith."
														M.Doing = 1
														IB.RemoveFromStack(3)
														GS1.RemoveFromStack(1)
														GH1.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Gou ShellPlate Corslet!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot")&&(GS1 in M.contents)&&(GS1.stack_amount>=1)&&(GH1 in M.contents)&&(GH1.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															IB.RemoveFromStack(3)
															GS1.RemoveFromStack(1)
															GH1.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gou Hide, Gou Shell and 3 Hot Iron Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gou Hide, Gou Shell and 3 Hot Iron Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Iron Platemail Corslet")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/ironbar/IB = locate() in M.contents
												var/obj/items/CParts/GouShell/GS2 = locate() in M.contents
												var/obj/items/CParts/GouHide/GH2 = locate() in M.contents
												if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot")&&(GS2 in M.contents)&&(GS2.stack_amount>=1)&&(GH2 in M.contents)&&(GH2.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/uncocorslet
														usr << "You begin to smith."
														M.Doing = 1
														IB.RemoveFromStack(3)
														GS2.RemoveFromStack(1)
														GH2.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Iron Platemail Corslet!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot")&&(GS2 in M.contents)&&(GS2.stack_amount>=1)&&(GH2 in M.contents)&&(GH2.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															IB.RemoveFromStack(3)
															GS2.RemoveFromStack(1)
															GH2.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gou Shell and 3 Hot Iron Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gou Shell and 3 Hot Iron Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Copper Platemail Corslet")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/copperbar/CB = locate() in M.contents
												var/obj/items/CParts/GowShell/GS3 = locate() in M.contents
												var/obj/items/CParts/GowHide/GH3 = locate() in M.contents
												if((CB in M.contents)&&(CB.stack_amount>=3)&&(CB.Tname=="Hot")&&(GS3 in M.contents)&&(GS3.stack_amount>=1)&&(GH3 in M.contents)&&(GH3.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/choicorslet
														usr << "You begin to smith."
														M.Doing = 1
														CB.RemoveFromStack(3)
														GS3.RemoveFromStack(1)
														GH3.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Copper Platemail Corslet!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((CB in M.contents)&&(CB.stack_amount>=3)&&(CB.Tname=="Hot")&&(GS3 in M.contents)&&(GS3.stack_amount>=1)&&(GH3 in M.contents)&&(GH3.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															CB.RemoveFromStack(3)
															GS3.RemoveFromStack(1)
															GH3.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gow Hide, Gow Shell and 3 Hot Copper Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gow Hide, Gow Shell and 3 Hot Copper Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Bronzemail Corslet")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/bronzebar/BRB = locate() in M.contents
												var/obj/items/CParts/GuwiShell/GS4 = locate() in M.contents
												var/obj/items/CParts/GuwiHide/GH4 = locate() in M.contents
												if((BRB in M.contents)&&(BRB.stack_amount>=3)&&(BRB.Tname=="Hot")&&(GS4 in M.contents)&&(GS4.stack_amount>=1)&&(GH4 in M.contents)&&(GH4.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/ordicorslet
														usr << "You begin to smith."
														M.Doing = 1
														BRB.RemoveFromStack(3)
														GS4.RemoveFromStack(1)
														GH4.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Bronzemail Corslet!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((BRB in M.contents)&&(BRB.stack_amount>=3)&&(BRB.Tname=="Hot")&&(GS4 in M.contents)&&(GS4.stack_amount>=1)&&(GH4 in M.contents)&&(GH4.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															BRB.RemoveFromStack(3)
															GS4.RemoveFromStack(1)
															GH4.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Guwi Hide, Guwi Shell and 3 Hot Bronze Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Guwi Hide, Guwi Shell and 3 Hot Bronze Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Zinc Platemail Corslet")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/zincbar/ZB = locate() in M.contents
												var/obj/items/CParts/GowuShell/GS5 = locate() in M.contents
												var/obj/items/CParts/GowuHide/GH5 = locate() in M.contents
												if((ZB in M.contents)&&(ZB.stack_amount>=3)&&(ZB.Tname=="Hot")&&(GS5 in M.contents)&&(GS5.stack_amount>=1)&&(GH5 in M.contents)&&(GH5.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/sincorslet
														usr << "You begin to smith."
														M.Doing = 1
														ZB.RemoveFromStack(3)
														GS5.RemoveFromStack(1)
														GH5.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Zinc Platemail Corslet!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((ZB in M.contents)&&(ZB.stack_amount>=3)&&(ZB.Tname=="Hot")&&(GS5 in M.contents)&&(GS5.stack_amount>=1)&&(GH5 in M.contents)&&(GH5.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															ZB.RemoveFromStack(3)
															GS5.RemoveFromStack(1)
															GH5.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gowu Hide, Gowu Shell and 3 Hot Zinc Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gowu Hide, Gowu Shell and 3 Hot Zinc Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
									//call(/proc/smithinglevel)(M)
									if("Defensive")
										switch(input("What Armor would you like to make?","Defensive Armor Smithing") in L4)//in list())
											if("Cancel")
												M<<"You Cancel Selection..."
												Busy = 0
												M.UEB = 0
												M.SMIopen=0
												return
											if("Back") goto ARMOR
										//if(null)
											//M<<"You need the materials to smith this Armor"
											//return
											if("CopperPlate Cuirass")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/copperbar/CB = locate() in M.contents
												var/obj/items/CParts/GiuShell/GS0 = locate() in M.contents
												var/obj/items/CParts/GiuHide/GH0 = locate() in M.contents
												if((CB in M.contents)&&(CB.stack_amount>=4)&&(CB.Tname=="Hot")&&(GS0 in M.contents)&&(GH0 in M.contents)&&(GS0.stack_amount>=1)&&(GH0.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/avgcuirass
														usr << "You begin to smith."
														M.Doing = 1
														CB.RemoveFromStack(4)
														GS0.RemoveFromStack(1)
														GH0.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith a CopperPlate Cuirass!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((CB in M.contents)&&(CB.stack_amount>=4)&&(CB.Tname=="Hot")&&(GS0 in M.contents)&&(GH0 in M.contents)&&(GS0.stack_amount>=1)&&(GH0.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															CB.RemoveFromStack(4)
															GS0.RemoveFromStack(1)
															GH0.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Giu Shell, Giu Hide and 4 Hot Copper Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Giu Shell, Giu Hide and 4 Hot Copper Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("IronPlate Cuirass")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/ironbar/LB = locate() in M.contents
												var/obj/items/CParts/GouShell/GS1 = locate() in M.contents
												var/obj/items/CParts/GouHide/GH1 = locate() in M.contents
												if((LB in M.contents)&&(LB.stack_amount>=4)&&(LB.Tname=="Hot")&&(GS1 in M.contents)&&(GH1 in M.contents)&&(GS1.stack_amount>=1)&&(GH1.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/unucuirass
														usr << "You begin to smith."
														M.Doing = 1
														LB.RemoveFromStack(4)
														GS1.RemoveFromStack(1)
														GH1.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith a IronPlate Cuirass!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((LB in M.contents)&&(LB.stack_amount>=4)&&(LB.Tname=="Hot")&&(GS1 in M.contents)&&(GH1 in M.contents)&&(GS1.stack_amount>=1)&&(GH1.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															LB.RemoveFromStack(4)
															GS1.RemoveFromStack(1)
															GH1.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gou Shell, Gou Hide and 3 Hot Iron Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gou Shell, Gou Hide and 3 Hot Iron Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Iron HalfPlate Cuirass")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/ironbar/IB = locate() in M.contents
												var/obj/items/CParts/GowShell/GS2 = locate() in M.contents
												var/obj/items/CParts/GowHide/GH2 = locate() in M.contents
												if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot")&&(GS2 in M.contents)&&(GH2 in M.contents)&&(GS2.stack_amount>=1)&&(GH2.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/uncocuirass
														usr << "You begin to smith."
														M.Doing = 1
														IB.RemoveFromStack(3)
														GS2.RemoveFromStack(1)
														GH2.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith a Iron HalfPlate Cuirass!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((IB in M.contents)&&(IB.stack_amount>=3)&&(IB.Tname=="Hot")&&(GS2 in M.contents)&&(GH2 in M.contents)&&(GS2.stack_amount>=1)&&(GH2.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															IB.RemoveFromStack(3)
															GS2.RemoveFromStack(1)
															GH2.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gow Shell, Gow Hide and 3 Hot Iron Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gow Shell, Gow Hide and 3 Hot Iron Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Bronze SolidPlate Cuirass")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/bronzebar/BRB = locate() in M.contents
												var/obj/items/CParts/GowShell/GS3 = locate() in M.contents
												var/obj/items/CParts/GowHide/GH3 = locate() in M.contents
												if((BRB in M.contents)&&(BRB.stack_amount>=5)&&(BRB.Tname=="Hot")&&(GS3 in M.contents)&&(GH3 in M.contents)&&(GS3.stack_amount>=1)&&(GH3.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/choicuirass
														usr << "You begin to smith."
														M.Doing = 1
														BRB.RemoveFromStack(5)
														GS3.RemoveFromStack(1)
														GH3.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith a Bronze SolidPlate Cuirass!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((BRB in M.contents)&&(BRB.stack_amount>=5)&&(BRB.Tname=="Hot")&&(GS3 in M.contents)&&(GH3 in M.contents)&&(GS3.stack_amount>=1)&&(GH3.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															BRB.RemoveFromStack(5)
															GS3.RemoveFromStack(1)
															GH3.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gow Shell, Gow Hide and 5 Hot Bronze Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gow Shell, Gow Hide and 5 Hot Bronze Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Boreal ZincPlate Cuirass")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/zincbar/ZB = locate() in M.contents
												var/obj/items/CParts/GuwiShell/GS4 = locate() in M.contents
												var/obj/items/CParts/GuwiHide/GH4 = locate() in M.contents
												if((ZB in M.contents)&&(ZB.stack_amount>=5)&&(ZB.Tname=="Hot")&&(GS4 in M.contents)&&(GH4 in M.contents)&&(GS4.stack_amount>=1)&&(GH4.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/ordicuirass
														usr << "You begin to smith."
														M.Doing = 1
														ZB.RemoveFromStack(5)
														GS4.RemoveFromStack(1)
														GH4.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith a Boreal ZincPlate Cuirass!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((ZB in M.contents)&&(ZB.stack_amount>=5)&&(ZB.Tname=="Hot")&&(GS4 in M.contents)&&(GH4 in M.contents)&&(GS4.stack_amount>=1)&&(GH4.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															ZB.RemoveFromStack(5)
															GS4.RemoveFromStack(1)
															GH4.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Guwi Shell, Guwi Hide and 5 Hot Zinc Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Guwi Shell, Guwi Hide and 5 Hot Zinc Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Aurelian SteelPlate Cuirass")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/steelbar/STLB = locate() in M.contents
												var/obj/items/CParts/GowuShell/GS5 = locate() in M.contents
												var/obj/items/CParts/GowuHide/GH5 = locate() in M.contents
												if((STLB in M.contents)&&(STLB.stack_amount>=7)&&(STLB.Tname=="Hot")&&(GS5 in M.contents)&&(GH5 in M.contents)&&(GS5.stack_amount>=1)&&(GH5.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/sincuirass
														usr << "You begin to smith."
														M.Doing = 1
														STLB.RemoveFromStack(7)
														GS5.RemoveFromStack(1)
														GH5.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith a Aurelian SteelPlate Cuirass!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((STLB in M.contents)&&(STLB.stack_amount>=7)&&(STLB.Tname=="Hot")&&(GS5 in M.contents)&&(GH5 in M.contents)&&(GS5.stack_amount>=1)&&(GH5.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															STLB.RemoveFromStack(7)
															GS5.RemoveFromStack(1)
															GH5.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gowu Shell, Gowu Hide and 7 Hot Steel Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gowu Shell, Gowu Hide and 7 Hot Steel Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
									//call(/proc/smithinglevel)(M)
									if("Offensive")
										switch(input("What Armor would you like to make?","Offensive Armor Smithing") in L5)//in list())
											if("Cancel")
												M<<"You Cancel Selection..."
												Busy = 0
												M.UEB = 0
												M.SMIopen=0
												return
											if("Back") goto ARMOR
											if("IronPlate Battlegear")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/ironbar/IB = locate() in M.contents
												var/obj/items/CParts/GiuShell/GS0 = locate() in M.contents
												var/obj/items/CParts/GiuHide/GH0 = locate() in M.contents
												if((IB in M.contents)&&(IB.stack_amount>=5)&&(IB.Tname=="Hot")&&(GS0 in M.contents)&&(GH0 in M.contents)&&(GS0.stack_amount>=1)&&(GH0.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/avgbattlegear
														usr << "You begin to smith."
														M.Doing = 1
														IB.RemoveFromStack(5)
														GS0.RemoveFromStack(1)
														GH0.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith IronPlate Battlegear!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((IB in M.contents)&&(IB.stack_amount>=5)&&(IB.Tname=="Hot")&&(GS0 in M.contents)&&(GH0 in M.contents)&&(GS0.stack_amount>=1)&&(GH0.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															IB.RemoveFromStack(5)
															GS0.RemoveFromStack(1)
															GH0.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Giu Shell, Giu Hide and 5 Hot Iron Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Giu Shell, Giu Hide and 5 Hot Iron Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("CopperPlate Battlegear")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/copperbar/CB = locate() in M.contents
												var/obj/items/CParts/GouShell/GS1 = locate() in M.contents
												var/obj/items/CParts/GouHide/GH1 = locate() in M.contents
												if((CB in M.contents)&&(CB.stack_amount>=5)&&(CB.Tname=="Hot")&&(GS1 in M.contents)&&(GH1 in M.contents)&&(GS1.stack_amount>=1)&&(GH1.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/unubattlegear
														usr << "You begin to smith."
														M.Doing = 1
														CB.RemoveFromStack(5)
														GS1.RemoveFromStack(1)
														GH1.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith CopperPlate Battlegear!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((CB in M.contents)&&(CB.stack_amount>=5)&&(CB.Tname=="Hot")&&(GS1 in M.contents)&&(GH1 in M.contents)&&(GS1.stack_amount>=1)&&(GH1.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															CB.RemoveFromStack(5)
															GS1.RemoveFromStack(1)
															GH1.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gou Shell, Gou Hide and 5 Hot Copper Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gou Shell, Gou Hide and 5 Hot Copper Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("BronzePlate Battlegear")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/bronzebar/BRB = locate() in M.contents
												var/obj/items/CParts/GowShell/GS2 = locate() in M.contents
												var/obj/items/CParts/GowHide/GH2 = locate() in M.contents
												if((BRB in M.contents)&&(BRB.stack_amount>=5)&&(BRB.Tname=="Hot")&&(GS2 in M.contents)&&(GH2 in M.contents)&&(GS2.stack_amount>=1)&&(GH2.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d6"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/uncobattlegear
														usr << "You begin to smith."
														M.Doing = 1
														BRB.RemoveFromStack(5)
														GS2.RemoveFromStack(1)
														GH2.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith BronzePlate Battlegear!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((BRB in M.contents)&&(BRB.stack_amount>=5)&&(BRB.Tname=="Hot")&&(GS2 in M.contents)&&(GH2 in M.contents)&&(GS2.stack_amount>=1)&&(GH2.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															BRB.RemoveFromStack(5)
															GS2.RemoveFromStack(1)
															GH2.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gow Shell, Gow Hide and 5 Hot Bronze Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gow Shell, Gow Hide and 5 Hot Bronze Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("Omphalos AlloyPlate Battlegear")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/ironbar/LB = locate() in M.contents
												var/obj/items/Ingots/copperbar/CB = locate() in M.contents
												var/obj/items/CParts/GowShell/GS3 = locate() in M.contents
												var/obj/items/CParts/GowHide/GH3 = locate() in M.contents
												if((LB in M.contents)&&(LB.stack_amount>=3)&&(LB.Tname=="Hot")&&(CB in M.contents)&&(CB.stack_amount>=2)&&(CB.Tname=="Hot")&&(GS3 in M.contents)&&(GH3 in M.contents)&&(GS3.stack_amount>=1)&&(GH3.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d10"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/choibattlegear
														usr << "You begin to smith."
														M.Doing = 1
														CB.RemoveFromStack(2)
														LB.RemoveFromStack(3)
														GS3.RemoveFromStack(1)
														GH3.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith Omphalos AlloyPlate Battlegear!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((LB in M.contents)&&(LB.stack_amount>=3)&&(LB.Tname=="Hot")&&(CB in M.contents)&&(CB.stack_amount>=2)&&(CB.Tname=="Hot")&&(GS3 in M.contents)&&(GH3 in M.contents)&&(GS3.stack_amount>=1)&&(GH3.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															CB.RemoveFromStack(2)
															LB.RemoveFromStack(3)
															GS3.RemoveFromStack(1)
															GH3.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gow Shell, Gow Hide, 2 Hot Copper Ingot and 3 Hot Iron Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gow Shell, Gow Hide, 2 Hot Copper Ingot and 3 Hot Iron Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("ZincPlate Battlegear")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/zincbar/ZB = locate() in M.contents
												var/obj/items/CParts/GuwiShell/GS4 = locate() in M.contents
												var/obj/items/CParts/GuwiHide/GH4 = locate() in M.contents
												if((ZB in M.contents)&&(ZB.stack_amount>=5)&&(ZB.Tname=="Hot")&&(GS4 in M.contents)&&(GH4 in M.contents)&&(GS4.stack_amount>=1)&&(GH4.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d12"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/ordibattlegear
														usr << "You begin to smith."
														M.Doing = 1
														ZB.RemoveFromStack(5)
														GS4.RemoveFromStack(1)
														GH4.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith ZincPlate Battlegear!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((ZB in M.contents)&&(ZB.stack_amount>=5)&&(ZB.Tname=="Hot")&&(GS4 in M.contents)&&(GH4 in M.contents)&&(GS4.stack_amount>=1)&&(GH4.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															ZB.RemoveFromStack(5)
															GS4.RemoveFromStack(1)
															GH4.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Guwi Shell, Guwi Hide and 5 Hot Zinc Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Guwi Shell, Guwi Hide and 5 Hot Zinc Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
											if("SteelPlate Battlegear")
												//var/obj/items/tools/BroadSword/BS
												//var/random/R = rand(1,5) //1 in 5 chance to smith
												var/obj/items/Ingots/steelbar/STLB = locate() in M.contents
												var/obj/items/CParts/GowuShell/GS5 = locate() in M.contents
												var/obj/items/CParts/GowuHide/GH5 = locate() in M.contents
												if((STLB in M.contents)&&(STLB.stack_amount>=5)&&(STLB.Tname=="Hot")&&(GS5 in M.contents)&&(GH5 in M.contents)&&(GS5.stack_amount>=1)&&(GH5.stack_amount>=1))
													//var/obj/items/tools/BroadSword/BS
													var/dice = "1d20"
													var/R = roll(dice)
													if(R == 2)
														var/AV = /obj/items/armors/sinbattlegear
														usr << "You begin to smith."
														M.Doing = 1
														STLB.RemoveFromStack(5)
														GS5.RemoveFromStack(1)
														GH5.RemoveFromStack(1)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														M.smiexp += 15 //go to proc miningcheck
														M.stamina -= 5
														M.updateST()
														new AV(M)//(locate(x,y,z))
														usr << "You smith SteelPlate Battlegear!" //message to user saying he/she mined something
														//BSB:Tname="Hot"
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														if((STLB in M.contents)&&(STLB.stack_amount>=5)&&(STLB.Tname=="Hot")&&(GS5 in M.contents)&&(GH5 in M.contents)&&(GS5.stack_amount>=1)&&(GH5.stack_amount>=1))
															usr << "You begin to smith."
															M.Doing = 1
															STLB.RemoveFromStack(5)
															GS5.RemoveFromStack(1)
															GH5.RemoveFromStack(1)
															src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
															sleep(30) //Delay 3 seconds
															 //user mining skill gos up by 15
															M.smiexp += 15 //....
															M.stamina -= 5
															M.updateST()
															usr << "The materials fail to react well together and become unusable..." //message to user saying he/she didn't mine anything
															src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
														else
															usr<<"You need Gowu Shell, Gowu Hide and 5 Hot Steel Ingots to utilize for smithing this Armor..."
															M.Doing = 0
															M.UEB = 0
															M.SMIopen=0
															return call(/proc/smithinglevel)()
												else
													usr<<"You need Gowu Shell, Gowu Hide and 5 Hot Steel Ingots to utilize for smithing this Armor..."
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
								//call(/proc/smithinglevel)(M)
								if("Lamps")
									switch(input("What would you like to make?","Smithing") in L3)//in list())
								//switch(L)
										if("Cancel")
											M<<"You Cancel Selection..."
											Busy = 0
											M.UEB = 0
											M.SMIopen=0
											return
										if("Back") goto SMITHING
										if("Iron Lamp Head")
											//var/obj/items/tools/BroadSword/BS
											//var/random/R = rand(1,5) //1 in 5 chance to smith
											var/obj/items/Ingots/ironbar/IB = locate() in M.contents
											if((IB in M.contents)&&(IB.stack_amount>=4)&&(IB.Tname=="Hot"))
												//var/obj/items/tools/BroadSword/BS
												var/dice = "1d6"
												var/R = roll(dice)
												if(R == 2)
													var/ILH = /obj/items/Crafting/Created/IronLampHead
													usr << "You begin to smith."
													M.Doing = 1
													IB.RemoveFromStack(4)
													src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
													sleep(30) //Delay 3 seconds
													M.smiexp += 15 //go to proc miningcheck
													M.stamina -= 5
													M.updateST()
													new ILH(locate(x,y,z))
													usr << "You smith a Iron Lamp Head!" //message to user saying he/she mined something
													//BSB:Tname="Hot"
													src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
												else
													if((IB in M.contents)&&(IB.stack_amount>=4)&&(IB.Tname=="Hot"))
														usr << "You begin to smith."
														M.Doing = 1
														IB.RemoveFromStack(4)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														 //user mining skill gos up by 15
														M.smiexp += 15 //....
														M.stamina -= 5
														M.updateST()
														usr << "The materials fail to react well..." //message to user saying he/she didn't mine anything
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														usr<<"You need 4 Hot Iron Ingots for smithing this Lamp Head..."
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
											else
												usr<<"You need 4 Hot Iron Ingots for smithing this Lamp Head..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
										if("Copper Lamp Head")
											//var/obj/items/tools/BroadSword/BS
											//var/random/R = rand(1,5) //1 in 5 chance to smith
											var/obj/items/Ingots/copperbar/CB = locate() in M.contents
											if((CB in M.contents)&&(CB.stack_amount>=4)&&(CB.Tname=="Hot"))
												//var/obj/items/tools/BroadSword/BS
												var/dice = "1d6"
												var/R = roll(dice)
												if(R == 2)
													var/CLH = /obj/items/Crafting/Created/CopperLampHead
													usr << "You begin to smith."
													M.Doing = 1
													CB.RemoveFromStack(4)
													src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
													sleep(30) //Delay 3 seconds
													M.smiexp += 15 //go to proc miningcheck
													M.stamina -= 5
													M.updateST()
													new CLH(locate(x,y,z))
													usr << "You smith a Copper Lamp Head!" //message to user saying he/she mined something
													//BSB:Tname="Hot"
													src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
												else
													if((CB in M.contents)&&(CB.stack_amount>=4)&&(CB.Tname=="Hot"))
														usr << "You begin to smith."
														M.Doing = 1
														CB.RemoveFromStack(4)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														 //user mining skill gos up by 15
														M.smiexp += 15 //....
														M.stamina -= 5
														M.updateST()
														usr << "The materials fail to react well..." //message to user saying he/she didn't mine anything
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														usr<<"You need 4 Hot Copper Ingots for smithing this Lamp Head..."
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
											else
												usr<<"You need 4 Hot Copper Ingots for smithing this Lamp Head..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
										if("Bronze Lamp Head")
											//var/obj/items/tools/BroadSword/BS
											//var/random/R = rand(1,5) //1 in 5 chance to smith
											var/obj/items/Ingots/bronzebar/BRB = locate() in M.contents
											if((BRB in M.contents)&&(BRB.stack_amount>=4)&&(BRB.Tname=="Hot"))
												//var/obj/items/tools/BroadSword/BS
												var/dice = "1d6"
												var/R = roll(dice)
												if(R == 2)
													var/BRLH = /obj/items/Crafting/Created/BronzeLampHead
													usr << "You begin to smith."
													M.Doing = 1
													BRB.RemoveFromStack(4)
													src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
													sleep(30) //Delay 3 seconds
													M.smiexp += 15 //go to proc miningcheck
													M.stamina -= 5
													M.updateST()
													new BRLH(locate(x,y,z))
													usr << "You smith a Bronze Lamp Head!" //message to user saying he/she mined something
													//BSB:Tname="Hot"
													src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
												else
													if((BRB in M.contents)&&(BRB.stack_amount>=4)&&(BRB.Tname=="Hot"))
														usr << "You begin to smith."
														M.Doing = 1
														BRB.RemoveFromStack(4)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														 //user mining skill gos up by 15
														M.smiexp += 15 //....
														M.stamina -= 5
														M.updateST()
														usr << "The materials fail to react well..." //message to user saying he/she didn't mine anything
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														usr<<"You need 4 Hot Bronze Ingots for smithing this Lamp Head..."
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
											else
												usr<<"You need 4 Hot Bronze Ingots for smithing this Lamp Head..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
										if("Brass Lamp Head")
											//var/obj/items/tools/BroadSword/BS
											//var/random/R = rand(1,5) //1 in 5 chance to smith
											var/obj/items/Ingots/brassbar/BB = locate() in M.contents
											if((BB in M.contents)&&(BB.stack_amount>=4)&&(BB.Tname=="Hot"))
												//var/obj/items/tools/BroadSword/BS
												var/dice = "1d6"
												var/R = roll(dice)
												if(R == 2)
													var/BLH = /obj/items/Crafting/Created/BrassLampHead
													usr << "You begin to smith."
													M.Doing = 1
													BB.RemoveFromStack(4)
													src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
													sleep(30) //Delay 3 seconds
													M.smiexp += 15 //go to proc miningcheck
													M.stamina -= 5
													M.updateST()
													new BLH(locate(x,y,z))
													usr << "You smith a Brass Lamp Head!" //message to user saying he/she mined something
													//BSB:Tname="Hot"
													src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
												else
													if((BB in M.contents)&&(BB.stack_amount>=4)&&(BB.Tname=="Hot"))
														usr << "You begin to smith."
														M.Doing = 1
														BB.RemoveFromStack(4)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														 //user mining skill gos up by 15
														M.smiexp += 15 //....
														M.stamina -= 5
														M.updateST()
														usr << "The materials fail to react well..." //message to user saying he/she didn't mine anything
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														usr<<"You need 4 Hot Brass Ingots for smithing this Lamp Head..."
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
											else
												usr<<"You need 4 Hot Brass Ingots for smithing this Lamp Head..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
										if("Steel Lamp Head")
											//var/obj/items/tools/BroadSword/BS
											//var/random/R = rand(1,5) //1 in 5 chance to smith
											var/obj/items/Ingots/steelbar/STB = locate() in M.contents
											if((STB in M.contents)&&(STB.stack_amount>=4)&&(STB.Tname=="Hot"))
												//var/obj/items/tools/BroadSword/BS
												var/dice = "1d6"
												var/R = roll(dice)
												if(R == 2)
													var/STLH = /obj/items/Crafting/Created/SteelLampHead
													usr << "You begin to smith."
													M.Doing = 1
													STB.RemoveFromStack(4)
													src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
													sleep(30) //Delay 3 seconds
													M.smiexp += 15 //go to proc miningcheck
													M.stamina -= 5
													M.updateST()
													new STLH(locate(x,y,z))
													usr << "You smith a Steel Lamp Head!" //message to user saying he/she mined something
													//BSB:Tname="Hot"
													src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
													M.Doing = 0
													M.UEB = 0
													M.SMIopen=0
													return call(/proc/smithinglevel)()
												else
													if((STB in M.contents)&&(STB.stack_amount>=4)&&(STB.Tname=="Hot"))
														usr << "You begin to smith."
														M.Doing = 1
														STB.RemoveFromStack(4)
														src.overlays += image('dmi/64/creation.dmi',icon_state="anvilL")
														sleep(30) //Delay 3 seconds
														 //user mining skill gos up by 15
														M.smiexp += 15 //....
														M.stamina -= 5
														M.updateST()
														usr << "The materials fail to react well..." //message to user saying he/she didn't mine anything
														src.overlays -= image('dmi/64/creation.dmi',icon_state="anvilL")
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
													else
														usr<<"You need 4 Hot Steel Ingots for smithing this Lamp Head..."
														M.Doing = 0
														M.UEB = 0
														M.SMIopen=0
														return call(/proc/smithinglevel)()
											else
												usr<<"You need 4 Hot Steel Ingots for smithing this Lamp Head..."
												M.Doing = 0
												M.UEB = 0
												M.SMIopen=0
												return call(/proc/smithinglevel)()
							//call(/proc/smithinglevel)(M)
				else //else contrasting the if at the top
					usr << "You need to use an Iron Hammer to smith!" //message to user saying that they need a pick axe to mine
					M.Doing = 0
					M.UEB = 0
					M.SMIopen=0
					return call(/proc/smithinglevel)()
			//else
			//	usr << "You are already smithing!"
//smelting

		Smelting() //Name of proc
			set waitfor = 0
			var/mob/players/M
			M = usr

			//var/sme
			//sme = smeltingunlock(arglist(smelt))
			//smeltingunlock()
			//call(/proc/smeltingunlock)(usr)
			//smeltinglevel()
			if(M.stamina == 0)
				return
			if(M.Doing == 1)
				M << "You are already smelting!"
				return
			if(M.GVequipped == 1&&src.name=="Lit Forge")
				M.SMEopen = 1
				M.UESME = 1
				//M.Doing = 1
				//M<<"test message"//var/sme = input("What would you like to smelt?","Smelting") in L//in list("Iron"))//switch this to a ranking system and only provide higher options(copper brass bronze) when you reach higher rank?
				switch(input("What would you like to smelt?","Smelting") as anything in smelt)
					if("Cancel")
						M.Doing = 0
						M.UESME = 0
						M.SMEopen=0
						M<<"You Cancel Selection..."
						return
					//if("Back") goto SMELTING
					if("Iron Anvil Head")
						var/SCI = /obj/items/Ingots/Scraps/scrapiron
						var/IB = /obj/items/Crafting/Created/AnvilHead
						var/obj/items/Ingots/ironbar/I = locate() in M.contents
						var/random/R = rand(1,5) //1 in 5 chance to smith -- Need to replace these with dice rolls
						if((I in M.contents)&&(I.stack_amount>=15)&&(I.Tname=="Hot")&&(src.name=="Lit Forge"))
							M << "You begin to smelt an Iron Anvil Head..."
							M.Doing = 1
							I.RemoveFromStack(15)
							sleep(30) //Delay 3 seconds
								//user gets 25 mining experience
							M.smeexp += 5 //go to proc miningcheck
							M.stamina -= 5
							M.updateST()
								//IB:Tname="Hot"
							new IB(locate(x,y,z))
							M << "You smelt an Iron Anvil Head!" //message to user saying he/she mined something
							//src.overlays -= image('dmi/64/creation.dmi',icon_state="forgeL")
								//light.off()
							M.Doing = 0
							M.UESME = 0
							M.SMEopen=0
							return call(/proc/smeltinglevel)(M)
						else
							M<<"You need 15 Hot Iron Ingots and a Lit Forge to smelt Iron Anvil Head."
							M.Doing = 0
							M.UESME = 0
							M.SMEopen=0
							return
							if(R==2)
									//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeL")
										//light.on()
								usr << "You begin to smelt an Iron Anvil Head..."
								M.Doing = 1
								I.RemoveFromStack(1)
								sleep(30) //Delay 3 seconds
								//user mining skill gos up by 15
								M.smeexp += 5 //....
								M.stamina -= 5
								M.updateST()
								M << "The material used was too pitted to smelt properly and produced scrap iron!" //message to user saying he/she didn't mine anything
									//SCI:Tname="Hot"
								new SCI(locate(x,y,z))
									//src.overlays -= image('dmi/64/creation.dmi',icon_state="forgeL")
									//light.off()
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
					if("Iron")
						var/SCI = /obj/items/Ingots/Scraps/scrapiron
						var/IB = /obj/items/Ingots/ironbar
						var/obj/items/Ore/iron/I = locate() in M.contents
						var/random/R = rand(1,5) //1 in 5 chance to smith
						if((I in M.contents)&&(I.stack_amount>=3)&&(src.name=="Lit Forge"))
							M << "You begin to smelt Iron ore..."
							M.Doing = 1
							I.RemoveFromStack(3)
							sleep(30) //Delay 3 seconds
								//user gets 25 mining experience
							M.smeexp += 5 //go to proc miningcheck
							M.stamina -= 5
							M.updateST()
								//IB:Tname="Hot"
							new IB(locate(x,y,z))
							M << "You smelt an Iron Ingot!" //message to user saying he/she mined something
							//src.overlays -= image('dmi/64/creation.dmi',icon_state="forgeL")
								//light.off()
							M.Doing = 0
							M.UESME = 0
							M.SMEopen=0
							return call(/proc/smeltinglevel)(M)
						else
							M<<"You need 3 Iron Ore and a Lit Forge to smelt an ingot."
							M.Doing = 0
							M.UESME = 0
							M.SMEopen=0
							return
							if(R==2)
									//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeL")
										//light.on()
								usr << "You begin to smelt Iron ore..."
								M.Doing = 1
								I.RemoveFromStack(1)
								sleep(30) //Delay 3 seconds
								//user mining skill gos up by 15
								M.smeexp += 5 //....
								M.stamina -= 5
								M.updateST()
								M << "The material used was too pitted to smelt properly and produced scrap iron!" //message to user saying he/she didn't mine anything
									//SCI:Tname="Hot"
								new SCI(locate(x,y,z))
									//src.overlays -= image('dmi/64/creation.dmi',icon_state="forgeL")
									//light.off()
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)

					if("Lead")
						var/LB = /obj/items/Ingots/leadbar
						var/SCL = /obj/items/Ingots/Scraps/scraplead
						var/obj/items/Ore/lead/LE = locate() in M.contents
						var/random/R = rand(1,5) //1 in 5 chance to smith
						if(R>=2)
							if((LE in M.contents)&&(LE.stack_amount>=3))
								//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeL")
								usr << "You begin to smelt Lead ore..."
								M.Doing = 1
								LE.RemoveFromStack(3)
								sleep(30) //Delay 3 seconds
							//user gets 25 mining experience
								M.smeexp += 5 //go to proc miningcheck
								M.stamina -= 5
								M.updateST()
								new LB(locate(x,y,z))
								//LB:Tname="Hot"
								usr << "You smelt a Lead Ingot!" //message to user saying he/she mined something
								//src.overlays -= image('dmi/64/creation.dmi',icon_state="forgeL")
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
							else
								usr << "You need 3 Lead ore and a Lit Forge to smelt an ingot."
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
						else
							if((LE in M.contents)&&(LE.stack_amount>=3))
								//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeL")
								usr << "You begin to smelt Lead ore..."
								M.Doing = 1
								LE.RemoveFromStack(1)
								sleep(30) //Delay 3 seconds
							//user mining skill gos up by 15
								M.smeexp += 5 //....
								M.stamina -= 5
								M.updateST()
								M << "The material used was too pitted to smelt properly and produced scrap lead!" //message to user saying he/she didn't mine anything
								new SCL(locate(x,y,z))
								//SCL:Tname="Hot"
								//src.overlays -= image('dmi/64/creation.dmi',icon_state="forgeL")
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
							else
								usr << "You need 3 Lead ore and a Lit Forge to smelt an ingot."
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
					if("Zinc")
						var/SCZ = /obj/items/Ingots/Scraps/scrapzinc
						var/ZB = /obj/items/Ingots/zincbar
						var/obj/items/Ore/zinc/Z = locate() in M.contents
						var/random/R = rand(1,5) //1 in 5 chance to smith
						if(R==3)
							if((Z in M.contents)&&(Z.stack_amount>=2))
								usr << "You begin to smelt Zinc ore..."
								M.Doing = 1
								Z.RemoveFromStack(2)
								sleep(30) //Delay 3 seconds
							//user gets 25 mining experience
								M.smeexp += 5 //go to proc miningcheck
								M.stamina -= 5
								M.updateST()
								new ZB(locate(x,y,z))
								//ZB:Tname="Hot"
								usr << "You smelt a Zinc Ingot!" //message to user saying he/she mined something
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
							else
								usr << "You need 2 Zinc ore and a Lit Forge to smelt an ingot."
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
						else
							if((Z in M.contents)&&(Z.stack_amount>=2))
								usr << "You begin to smelt Zinc ore..."
								M.Doing = 1
								Z.RemoveFromStack(1)
								sleep(30) //Delay 3 seconds
							//user mining skill gos up by 15
								M.smeexp += 5 //....
								M.stamina -= 5
								M.updateST()
								M << "The material used was too pitted to smelt properly and produced scrap zinc!" //message to user saying he/she didn't mine anything
								new SCZ(locate(x,y,z))
								//SCZ:Tname="Hot"
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
							else
								usr << "You need 2 Zinc ore and a Lit Forge to smelt an ingot."
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
					if("Copper")
						var/SCC = /obj/items/Ingots/Scraps/scrapcopper
						var/CB = /obj/items/Ingots/copperbar
						var/obj/items/Ore/copper/C = locate() in M.contents
						var/random/R = rand(1,5) //1 in 5 chance to smith
						if(R==3)
							if((C in M.contents)&&(C.stack_amount>=2))
								usr << "You begin to smelt Copper ore..."
								M.Doing = 1
								C.RemoveFromStack(2)
								sleep(30) //Delay 3 seconds
							//user gets 25 mining experience
								M.smeexp += 5 //go to proc miningcheck
								M.stamina -= 5
								M.updateST()
								//M.copperbar += 1
								new CB(locate(x,y,z))
								//CB:Tname="Hot"
								usr << "You smelt a Copper Ingot!" //message to user saying he/she mined something
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
							else
								usr << "You need 2 Copper ore and a Lit Forge to smelt an ingot."
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
						else
							if((C in M.contents)&&(C.stack_amount>=2))
								usr << "You begin to smelt Copper ore..."
								M.Doing = 1
								C.RemoveFromStack(1)
								sleep(30) //Delay 3 seconds
							//user mining skill gos up by 15
								M.smeexp += 5 //....
								M.stamina -= 5
								M.updateST()
								M << "The material used was too pitted to smelt properly and produced scrap copper!" //message to user saying he/she didn't mine anything
								new SCC(locate(x,y,z))
								//SCC:Tname="Hot"
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
							else
								usr << "You need 2 Copper ore and a Lit Forge to smelt an ingot."
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
					if("Bronze")
						var/SCBR = /obj/items/Ingots/Scraps/scrapbronze
						var/BRB = /obj/items/Ingots/bronzebar
						var/obj/items/Ingots/copperbar/CB = locate() in M.contents
						var/obj/items/Ingots/leadbar/LB = locate() in M.contents
						var/random/R = rand(1,5) //1 in 5 chance to smith
						if(R==3)
							if((CB in M.contents)&&(CB.stack_amount>=1)&&(LB in M.contents)&&(LB.stack_amount>=1))
								usr << "You begin to smelt Bronze..."
								M.Doing = 1
								CB.RemoveFromStack(1)
								LB.RemoveFromStack(1)
								sleep(30) //Delay 3 seconds
							//user gets 25 mining experience
								M.smeexp += 5 //go to proc miningcheck
								M.stamina -= 5
								M.updateST()
									//M.copperbar += 1
								new BRB(locate(x,y,z))
								//BRB:Tname="Hot"
								usr << "You smelt a Bronze Ingot!" //message to user saying he/she mined something
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
							else
								usr << "You need 1 Copper Ingot, 1 Lead Ingot and a Lit Forge to smelt an ingot."
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
						else
							if((CB in M.contents)&&(CB.stack_amount>=1)&&(LB in M.contents)&&(LB.stack_amount>=1))
								usr << "You begin to smelt Bronze..."
								M.Doing = 1
								CB.RemoveFromStack(1)
								LB.RemoveFromStack(1)
								sleep(30) //Delay 3 seconds
							//user mining skill gos up by 15
								M.smeexp += 5 //....
								M.stamina -= 5
								M.updateST()
								M << "The material used was too pitted to smelt properly and produced scrap bronze!" //message to user saying he/she didn't mine anything
								new SCBR(locate(x,y,z))
								//SCBR:Tname="Hot"
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
							else
								usr << "You need 1 Copper Ingot, 1 Lead Ingot and a Lit Forge to smelt an ingot."
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
					if("Brass")
						var/SCB = /obj/items/Ingots/Scraps/scrapbrass
						var/BB = /obj/items/Ingots/brassbar
						var/obj/items/Ingots/copperbar/CB = locate() in M.contents
						var/obj/items/Ingots/zincbar/ZB = locate() in M.contents
						var/random/R = rand(1,5) //1 in 5 chance to smith
						if(R==3)
							if((CB in M.contents)&&(CB.stack_amount>=1)&&(ZB in M.contents)&&(ZB.stack_amount>=1))
								usr << "You begin to smelt Brass..."
								M.Doing = 1
								CB.RemoveFromStack(1)
								ZB.RemoveFromStack(1)
								sleep(30) //Delay 3 seconds
							//user gets 25 mining experience
								M.smeexp += 5 //go to proc miningcheck
								M.stamina -= 5
								M.updateST()
								//M.copperbar += 1
								new BB(locate(x,y,z))
								//BB:Tname="Hot"
								usr << "You smelt a Brass Ingot!" //message to user saying he/she mined something
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
							else
								usr << "You need 1 Copper Ingot, 1 Zinc Ingot and a Lit Forge to smelt an ingot."
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
						else
							if((CB in M.contents)&&(CB.stack_amount>=1)&&(ZB in M.contents)&&(ZB.stack_amount>=1))
								usr << "You begin to smelt Brass..."
								M.Doing = 1
								CB.RemoveFromStack(1)
								ZB.RemoveFromStack(1)
								sleep(30) //Delay 3 seconds
							//user mining skill gos up by 15
								M.smeexp += 5 //....
								M.stamina -= 5
								M.updateST()
								M << "The material used was too pitted to smelt properly and produced scrap brass!" //message to user saying he/she didn't mine anything
								new SCB(locate(x,y,z))
								//SCB:Tname="Hot"
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
							else
								usr << "You need 1 Copper Ingot, 1 Zinc Ingot and a Lit Forge to smelt an ingot."
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)

					if("Steel")
						//var/SCST = /obj/items/Ingots/Scraps/scrapst
						var/STB = /obj/items/Ingots/steelbar
						var/obj/items/Ingots/ironbar/IB = locate() in M.contents
						var/obj/items/Activated_Carbon/AC = locate() in M.contents
						var/random/R = rand(1,5) //1 in 5 chance to smith
						if(R==3)
							if((IB in M.contents)&&(IB.stack_amount>=3)&&(AC in M.contents)&&(AC.stack_amount>=2))
								usr << "You begin to smelt Steel..."
								M.Doing = 1
								IB.RemoveFromStack(3)
								AC.RemoveFromStack(2)
								sleep(30) //Delay 3 seconds
							//user gets 25 mining experience
								M.smeexp += 5 //go to proc miningcheck
								M.stamina -= 5
								M.updateST()
									//M.copperbar += 1
								new STB(locate(x,y,z))
								//STB:Tname="Hot"
								usr << "You smelt a Steel Ingot!" //message to user saying he/she mined something
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
							else
								usr << "You need 3 Iron Ingot, 2 Activated Carbon and a Lit Forge to smelt an ingot."
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
						else
							if((IB in M.contents)&&(IB.stack_amount>=3)&&(AC in M.contents)&&(AC.stack_amount>=2))
								usr << "You begin to smelt Steel..."
								M.Doing = 1
								IB.RemoveFromStack(3)
								AC.RemoveFromStack(2)
								sleep(30) //Delay 3 seconds
							//user mining skill gos up by 15
								M.smeexp += 5 //....
								M.stamina -= 5
								M.updateST()
								M << "The material used was too pitted to smelt properly and was lost in the process!" //message to user saying he/she didn't mine anything
								//new SCBR(locate(x,y,z))
								//SCBR:Tname="Hot"
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
							else
								usr << "You need 3 Iron Ingot, 2 Activated Carbon and a Lit Forge to smelt an ingot."
								M.Doing = 0
								M.UESME = 0
								M.SMEopen=0
								return call(/proc/smeltinglevel)(M)
				//call(/proc/smeltinglevel)(M)
			else //else contrasting the if at the top
				usr << "You need to use Gloves to hold the hot materials to be produced from a Lit Forge! Status:[src.name]" //message to user saying that they need a pick axe to mine
				M.UESME = 0
				M.SMEopen=0
				return call(/proc/smeltinglevel)()
	//These are all pretty self-explanatory.  Define what the object is, how it works, and protect from letting the player do anything stupid.
obj/npcs
	//plane = 3
	layer = 3
	Inn1
		name = "Scrollkeeper"
		density = 1 // cant walk through him
		icon = 'dmi/64/npcs.dmi'
		icon_state = "inn1"
		verb
			Talk()
				set src in oview(2)
				set hidden = 1
				var/mob/players/M
				M = usr
				var/amount = round(((M.MAXHP-M.HP)+(M.MAXstamina-M.stamina))/10,5) // calculation for cost based on your HP and stamina
				src.verbs-=new/obj/npcs/Inn1/verb/Talk() // protection against talking multiple times
				M.nomotion=1 // protection against opening the dialog and moving around
				//var/I = input("Refresh with Ancient Scrolls for [amount] lucre?","Scrollkeep") in list ("Yes","No")
				switch(input("Refresh with Ancient Scrolls for [amount] lucre?","Scrollkeep") in list ("Yes","No"))
					if ("Yes") // taking a rest
						if (M.lucre>=amount) // if you can afford it
							M.HP = M.MAXHP
							M.stamina = M.MAXstamina
							M.poisonD=0
							M.poisoned=0
							M.poisonDMG=0
							M.overlays = /obj/vitae
							M.lucre-=amount
							usr << "Thank you. Be Safe."
							M.nomotion=0
							src.verbs+=new/obj/npcs/Inn1/verb/Talk()
						else // poor bum
							NoLucre()
							M.nomotion=0
							src.verbs+=new/obj/npcs/Inn1/verb/Talk()
					else
						usr << "<font color = teal>Be Careful."
						M.nomotion=0
						src.verbs+=new/obj/npcs/Inn1/verb/Talk()
	HP1
		name = "Scrollkeeper"
		density = 1 // cant walk through him
		icon = 'dmi/64/npcs.dmi'
		icon_state = "lsdshp"
		verb
			Talk()
				set src in oview(2)
				set hidden = 1
				var/mob/players/M
				M = usr
				var/amount = round(((M.MAXHP-M.HP)+(M.MAXstamina-M.stamina))/10,5) // calculation for cost based on your HP and stamina
				src.verbs-=new/obj/npcs/Inn1/verb/Talk() // protection against talking multiple times
				M.nomotion=1 // protection against opening the dialog and moving around
				//var/I = input("Refresh with Ancient Scrolls for [amount] lucre?","Scrollkeep") in list ("Yes","No")
				switch(input("Refresh with Ancient Scrolls for [amount] lucre?","Scrollkeep") in list ("Yes","No"))
					if ("Yes") // taking a rest
						if (M.lucre>=amount) // if you can afford it
							M.HP = M.MAXHP
							M.stamina = M.MAXstamina
							M.poisonD=0
							M.poisoned=0
							M.poisonDMG=0
							M.overlays = /obj/vitae
							M.lucre-=amount
							usr << "Thank you. Be Safe."
							M.nomotion=0
							src.verbs+=new/obj/npcs/Inn1/verb/Talk()
						else // poor bum
							NoLucre()
							M.nomotion=0
							src.verbs+=new/obj/npcs/Inn1/verb/Talk()
					else
						usr << "<font color = teal>Be Careful."
						M.nomotion=0
						src.verbs+=new/obj/npcs/Inn1/verb/Talk()
	HP3
		name = "Scrollkeeper"
		density = 1 // cant walk through him
		icon = 'dmi/64/npcs.dmi'
		icon_state = "hp3"
		verb
			Talk()
				set src in oview(2)
				set hidden = 1
				var/mob/players/M
				M = usr
				var/amount = round(((M.MAXHP-M.HP)+(M.MAXstamina-M.stamina))/10,5) // calculation for cost based on your HP and stamina
				src.verbs-=new/obj/npcs/Inn1/verb/Talk() // protection against talking multiple times
				M.nomotion=1 // protection against opening the dialog and moving around
				//var/I = input("Refresh with Ancient Scrolls for [amount] lucre?","Scrollkeep") in list ("Yes","No")
				switch(input("Refresh with Ancient Scrolls for [amount] lucre?","Scrollkeep") in list ("Yes","No"))
					if ("Yes") // taking a rest
						if (M.lucre>=amount) // if you can afford it
							M.HP = M.MAXHP
							M.stamina = M.MAXstamina
							M.poisonD=0
							M.poisoned=0
							M.poisonDMG=0
							M.overlays = /obj/vitae
							M.lucre-=amount
							usr << "Thank you. Be Safe."
							M.nomotion=0
							src.verbs+=new/obj/npcs/Inn1/verb/Talk()
						else // poor bum
							NoLucre()
							M.nomotion=0
							src.verbs+=new/obj/npcs/Inn1/verb/Talk()
					else
						usr << "<font color = teal>Be Careful."
						M.nomotion=0
						src.verbs+=new/obj/npcs/Inn1/verb/Talk()
	HP4
		name = "Scrollkeeper"
		density = 1 // cant walk through him
		icon = 'dmi/64/npcs.dmi'
		icon_state = "hsdshp"
		verb
			Talk()
				set src in oview(2)
				set hidden = 1
				var/mob/players/M
				M = usr
				var/amount = round(((M.MAXHP-M.HP)+(M.MAXstamina-M.stamina))/40,5) // calculation for cost based on your HP and stamina
				src.verbs-=new/obj/npcs/Inn1/verb/Talk() // protection against talking multiple times
				M.nomotion=1 // protection against opening the dialog and moving around
				//var/I = input("Refresh with Ancient Scrolls for [amount] lucre?","Scrollkeep") in list ("Yes","No")
				switch(input("Refresh with Ancient Scrolls for [amount] lucre?","Scrollkeep") in list ("Yes","No"))
					if ("Yes") // taking a rest
						if (M.lucre>=amount) // if you can afford it
							M.HP = M.MAXHP
							M.stamina = M.MAXstamina
							M.poisonD=0
							M.poisoned=0
							M.poisonDMG=0
							M.overlays = /obj/vitae
							M.lucre-=amount
							usr << "Thank you. Be Safe."
							M.nomotion=0
							src.verbs+=new/obj/npcs/Inn1/verb/Talk()
						else // poor bum
							NoLucre()
							M.nomotion=0
							src.verbs+=new/obj/npcs/Inn1/verb/Talk()
					else
						usr << "<font color = teal>Be Careful."
						M.nomotion=0
						src.verbs+=new/obj/npcs/Inn1/verb/Talk()
	Inn2
		name = "Inn Attendant"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "inn2"
		layer = 6
		verb
			Talk()
				set src in oview(2)
				set hidden = 1
				var/mob/players/M
				M = usr
				var/amount = round(((M.MAXHP-M.HP)+(M.MAXstamina-M.stamina))/10,5)
				src.verbs-=new/obj/npcs/Inn2/verb/Talk()
				M.nomotion=1
				//var/I = input("Would you like a room for [amount] Lucre?","INN") in list ("Yes","No")
				switch(input("Refresh with Ancient Scrolls for [amount] lucre?","Scrollkeep") in list ("Yes","No"))
					if ("Yes")
						if (M.lucre>=amount)
							M.HP = M.MAXHP
							M.stamina = M.MAXstamina
							M.poisonD=0
							M.poisoned=0
							M.poisonDMG=0
							M.overlays = null
							M.lucre-=amount
							usr << "Good morning, how did you sleep?"
							M.nomotion=0
							src.verbs+=new/obj/npcs/Inn2/verb/Talk()
						else
							NoLucre()
							M.nomotion=0
							src.verbs+=new/obj/npcs/Inn2/verb/Talk()
					else
						usr << "<font color = teal>Sorry but it seems that you do not have enough Lucre."
						M.nomotion=0
						src.verbs+=new/obj/npcs/Inn2/verb/Talk()
	Inn3
		name = "Inn Attendant"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "inn3"
		layer = 6
		verb
			Talk()
				set src in oview(2)
				set hidden = 1
				var/mob/players/M
				M = usr
				var/amount = round(((M.MAXHP-M.HP)+(M.MAXstamina-M.stamina))/17,5)
				src.verbs-=new/obj/npcs/Inn2/verb/Talk()
				M.nomotion=1
				//var/I = input("Would you like a room for [amount] Lucre?","INN") in list ("Yes","No")
				switch(input("Refresh with Ancient Scrolls for [amount] lucre?","Scrollkeep") in list ("Yes","No"))
					if ("Yes")
						if (M.lucre>=amount)
							M.HP = M.MAXHP
							M.stamina = M.MAXstamina
							M.poisonD=0
							M.poisoned=0
							M.poisonDMG=0
							M.overlays = null
							M.lucre-=amount
							usr << "Good morning, how did you sleep?"
							M.nomotion=0
							src.verbs+=new/obj/npcs/Inn2/verb/Talk()
						else
							NoLucre()
							M.nomotion=0
							src.verbs+=new/obj/npcs/Inn2/verb/Talk()
					else
						usr << "<font color = teal>Sorry but it seems that you do not have enough Lucre."
						M.nomotion=0
						src.verbs+=new/obj/npcs/Inn2/verb/Talk()
	Inn4
		name = "Inn Attendant"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "hinn"
		layer = 6
		verb
			Talk()
				set src in oview(2)
				set hidden = 1
				var/mob/players/M
				M = usr
				var/amount = round(((M.MAXHP-M.HP)+(M.MAXstamina-M.stamina))/27,5)
				src.verbs-=new/obj/npcs/Inn2/verb/Talk()
				M.nomotion=1
				//var/I = input("Would you like a room for [amount] Lucre?","INN") in list ("Yes","No")
				switch(input("Refresh with Ancient Scrolls for [amount] lucre?","Scrollkeep") in list ("Yes","No"))
					if ("Yes")
						if (M.lucre>=amount)
							M.HP = M.MAXHP
							M.stamina = M.MAXstamina
							M.poisonD=0
							M.poisoned=0
							M.poisonDMG=0
							M.overlays = null
							M.lucre-=amount
							usr << "Good morning, how did you sleep?"
							M.nomotion=0
							src.verbs+=new/obj/npcs/Inn2/verb/Talk()
						else
							NoLucre()
							M.nomotion=0
							src.verbs+=new/obj/npcs/Inn2/verb/Talk()
					else
						usr << "<font color = teal>Sorry but it seems that you do not have enough Lucre."
						M.nomotion=0
						src.verbs+=new/obj/npcs/Inn2/verb/Talk()

	weapon_dealer

		var/inventory[] // the inventory of the shopkeeper (these are object prototypes)
		var/money		// how much money the shopkeeper has available to them



		town
			name = "Town Weapon Dealer"
			icon = 'dmi/64/npcs.dmi'
			icon_state = "weap1"

			inventory = list(
							/obj/items/weapons/avganlace,
							/obj/items/weapons/ordianlace,
							/obj/items/weapons/avgmarubo,
							/obj/items/weapons/avgbrand,
							/obj/items/weapons/avgestoc,
							/obj/items/weapons/avgtanto,
							/obj/items/weapons/avgferule
							)

		village

	Weapons1
		name = "Town Weapon Dealer"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "weap1"
		verb
			Talk()
				set src in oview(2)
				set hidden = 1
				var/mob/players/M
				M = usr
				var/K = (input("Welcome","WEAPONS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/choices = list(
							"Russet (Anlace)  2-4 DMG, 1 STRReq, 1H : 4 lucre",
							"Ochroid (Anlace) 7-11 DMG, 4 STRReq, 1H : 84 lucre",
							"Firm (Marubo): 7-8 DMG, 3 STRReq, 2H : 25 lucre",
							"Russet (Brand): 8-10 DMG, 5 STRReq, 2H : 45 lucre",
							"Ecru (Estoc): 4-8 DMG, 2 STRReq, 1H : 11 lucre",
							"Worn (Tanto): 3-5 DMG, 1 STRReq, 1H : 20 lucre",
							"Blackjack (Ferule): 4-6 DMG, 2 STRReq, 1H : 33 lucre",
							"Leave"
										)

						var/I = input("What would you like to buy?","WEAPONS") in choices
						if(I == choices[1])
							if (M.lucre>=4)
								M.lucre-=4
								var/obj/items/weapons/avganlace/J = new(M)
								usr << "Thank you for buying [J]."
							else
								NoLucre()
						if(I == choices[2])
							if (M.lucre>=84)
								M.lucre-=84
								var/obj/items/weapons/ordianlace/J = new(M)
								usr << "Thank you for buying [J]."
							else
								NoLucre()
						if(I == choices[3])
							if (M.lucre>=25)
								M.lucre-=25
								var/obj/items/weapons/avgmarubo/J = new(M)
								usr << "Thank you for buying [J]."
							else
								NoLucre()
						if(I == choices[4])
							if (M.lucre>=45)
								M.lucre-=45
								var/obj/items/weapons/avgbrand/J = new(M)
								usr << "Thank you for buying [J]."
							else
								NoLucre()
						if(I == choices[5])
							if (M.lucre>=11)
								M.lucre-=11
								var/obj/items/weapons/avgestoc/J = new(M)
								usr << "Thank you for buying [J]."
							else
								NoLucre()
						if(I == choices[6])
							if (M.lucre>=20)
								M.lucre-=20
								var/obj/items/weapons/avgtanto/J = new(M)
								usr << "Thank you for buying [J]."
							else
								NoLucre()
						if(I == choices[7])
							if (M.lucre>=33)
								M.lucre-=33
								var/obj/items/weapons/avgferule/J = new(M)
								usr << "Thank you for buying [J]."
							else
								NoLucre()
						else
							usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	Weapons1a
		name = "Village Weapon Dealer"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "vw1"
		verb
			Talk()
				set src in oview(2)
				set hidden = 1
				var/mob/players/M
				M = usr
				var/K = (input("Welcome","WEAPONS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Russet (Anlace)  2-4 DMG, 1 STRReq : 4 lucre"
						var/const/temp2 = "Firm (Marubo): 7-8 DMG, 3 STRReq : 25 lucre"
						var/const/temp3 = "Ecru (Estoc): 4-8 DMG, 2 STRReq : 11 lucre"
						var/const/temp4 = "Worn (Tanto): 3-5 DMG, 1 STRReq : 20 lucre"
						var/const/temp5 = "Blackjack (Ferule): 4-6 DMG, 2 STRReq : 33 lucre"
						switch(input("What would you like to buy?","WEAPONS") in list (temp1,temp2,temp3,temp4,temp5,"Leave"))
							if(temp1)
								if (M.lucre>=4)
									M.lucre-=4
									var/obj/items/weapons/avganlace/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp2)
								if (M.lucre>=25)
									M.lucre-=25
									var/obj/items/weapons/avgmarubo/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp3)
								if (M.lucre>=11)
									M.lucre-=11
									var/obj/items/weapons/avgestoc/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp4)
								if (M.lucre>=20)
									M.lucre-=20
									var/obj/items/weapons/avgtanto/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp5)
								if (M.lucre>=33)
									M.lucre-=33
									var/obj/items/weapons/avgferule/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							else
								usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else if("Leave")
						usr << "<font color = teal>Maybe next time."
	Weapons2
		name = "Weapon Dealer"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "weap2"
		layer = 6
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(2)
				M = usr
				var/K = (input("Welcome","WEAPONS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Worn (Yawara): 4-9 dmg, 10 str req::142 lucre"
						var/const/temp2 = "Elde (Eiku): 8-10 dmg, 24 str req::133 lucre"
						var/const/temp3 = "Swift (Kakubo): 3-6 dmg, 9 str req::113 lucre"
						var/const/temp4 = "Butcher (Tinberochin): 5-11 dmg, 22 str req, 2H::234 lucre"
						var/const/temp5 = "Dull (Katar): 4-7 dmg, 16 str req::164 lucre"
						var/const/temp6 = "Precise (Brand): 18-18 dmg, 20 str req::184 lucre"
						switch(input("What would you like to buy?","WEAPONS") in list (temp1,temp2,temp3,temp4,temp5,temp6,"Leave"))
							if(temp1)
								if (M.lucre>=142)
									M.lucre-=142
									var/obj/items/weapons/avgyawara/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp2)
								if (M.lucre>=133)
									M.lucre-=133
									var/obj/items/weapons/avgeiku/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp3)
								if (M.lucre>=113)
									M.lucre-=113
									var/obj/items/weapons/avgkakubo/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp4)
								if (M.lucre>=234)
									M.lucre-=234
									var/obj/items/weapons/avgtinberochin/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp5)
								if (M.lucre>=164)
									M.lucre-=164
									var/obj/items/weapons/avgkatar/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp6)
								if (M.lucre>=184)
									M.lucre-=184
									var/obj/items/weapons/choibrand/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							else
								usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	Weapons3
		name = "Weapon Dealer"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "weap3"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(2)
				M = usr
				var/K = (input("Welcome","WEAPONS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Dull (Voulge): 13-24 dmg, 28 str req::275 lucre"
						var/const/temp2 = "Studded (Rakkakubo): 16-26 dmg, 33 str req::264 lucre"
						var/const/temp3 = "Harvest (Kama): 11-13 dmg, 18 str req::184 lucre"
						var/const/temp4 = "Rustic (Wakizashi): 7-17 dmg, 21 str req::204 lucre"
						var/const/temp5 = "Worn (Nagamaki): 9-23 dmg, 24 str req::190 lucre"
						var/const/temp6 = "Relic (Tachi): 11-19 dmg, 28 str req::240 lucre"
						switch(input("What would you like to buy?","WEAPONS") in list (temp1,temp2,temp3,temp4,temp5,temp6,"Leave"))
							if(temp1)
								if (M.lucre>=275)
									M.lucre-=275
									var/obj/items/weapons/avgvoulge/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp2)
								if (M.lucre>=264)
									M.lucre-=264
									var/obj/items/weapons/avgrakkakubo/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp3)
								if (M.lucre>=184)
									M.lucre-=184
									var/obj/items/weapons/avgkama/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp4)
								if (M.lucre>=204)
									M.lucre-=204
									var/obj/items/weapons/avgwakizashi/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp5)
								if (M.lucre>=190)
									M.lucre-=190
									var/obj/items/weapons/avgnagamaki/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp6)
								if (M.lucre>=240)
									M.lucre-=240
									var/obj/items/weapons/avgtachi/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							else
								usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	Weapons4
		name = "Weapon Dealer"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "hweap"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(2)
				M = usr
				var/K = (input("What do you want?","WEAPONS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Rusty (Uchigatana): 170-178 dmg, 52 str req::364 lucre"
						var/const/temp3 = "Relic (Naginata): 142-184 dmg, 38 str req::333 lucre"
						var/const/temp4 = "Hard (Hakkakubo): 160-201 dmg, 66 str req::313 lucre"
						var/const/temp5 = "Edge (Wakizashi): 290-334 dmg, 58 str req::664 lucre"
						var/const/temp6 = "Edge (Kama): 174-195 dmg, 52 str req::672 lucre"
						switch(input("What do you want to buy?","WEAPONS") in list (temp1,temp3,temp4,temp5,temp6,"Leave"))
							if(temp1)
								if (M.lucre>=364)
									M.lucre-=364
									var/obj/items/weapons/avguchigatana/J = new(M)
									usr << "[J]. That's cool."
								else
									NoLucre()
							if(temp3)
								if (M.lucre>=333)
									M.lucre-=333
									var/obj/items/weapons/avgnaginata/J = new(M)
									usr << "[J]. That's cool."
								else
									NoLucre()
							if(temp4)
								if (M.lucre>=313)
									M.lucre-=313
									var/obj/items/weapons/avghakkakubo/J = new(M)
									usr << "[J]. That's cool."
								else
									NoLucre()
							if(temp5)
								if (M.lucre>=384)
									M.lucre-=384
									var/obj/items/weapons/choiwakizashi/J = new(M)
									usr << "[J]. That's cool."
								else
									NoLucre()
							if(temp6)
								if (M.lucre>=372)
									M.lucre-=372
									var/obj/items/weapons/choikama/J = new(M)
									usr << "[J]. That's cool."
								else
									NoLucre()
							else
								usr << "<font color = teal>Aww. Too bad."
					if("Sell")
						Selling(input("What do you want to sell") in usr)
					else
						usr << "<font color = teal>Aww. Too bad."
	WeaponsX
		name = "Au'yuhi"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "weapX"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(2)
				M = usr
				var/I
				I = input("Singular Wakizashi:  348-390 damage, one-handed, Increased Attack Speed, +60 Str, +20 Int, +600-1000 HP(varies), +600-1000 stamina(varies), +5-10 Demi(varies), +24-33 Resist All(varies), 240 strength required","INVISOMAN",I) in list ("Yes","No")
				switch(I)
					if("Yes")
						if (M.lucre>=5000000)
							M.lucre-=5000000
							var/obj/items/weapons/sinwakizashi/J = new(M)
							usr << "Thank you for buying [J]."
						else
							NoLucre()
					else
						usr << "<font color = teal>Too bad."
	Armors1
		name = "Armor Dealer"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "arm1"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(2)
				M = usr
				var/K = (input("Welcome","ARMORS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Vestments: 2 DEF, 6% eva, 3 STR-REQ : 15 lucre"
						var/const/temp2 = "Ringmail Vestments: 13 DEF, 4% eva, 15 STR-REQ : 75 lucre"
						var/const/temp3 = "Tunic: 5 DEF, 8% Eva, 5 STR-REQ : 30 lucre"
						var/const/temp4 = "Corslet: 14 DEF, 4% eva, 11 STR-REQ, : 67 lucre"
						var/const/temp5 = "Bastion: 11 DEF, 3% eva, 6 STR-REQ : 50 lucre"
						switch(input("What would you like to buy?","ARMORS") in list (temp1,temp2,temp3,temp4,temp5,"Leave"))
							if(temp1)
								if (M.lucre>=15)
									M.lucre-=15
									var/obj/items/armors/avgvestments/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp2)
								if (M.lucre>=75)
									M.lucre-=75
									var/obj/items/armors/choivestments/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp3)
								if (M.lucre>=30)
									M.lucre-=30
									var/obj/items/armors/avgtunic/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp4)
								if (M.lucre>=67)
									M.lucre-=67
									var/obj/items/armors/avgcorslet/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp5)
								if (M.lucre>=50)
									M.lucre-=50
									var/obj/items/shields/avgbast/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							else
								usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	Armors1a
		name = "Armor Dealer"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "lsdsa"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(2)
				M = usr
				var/K = (input("Welcome","ARMORS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Vestments: 2 DEF, 6% eva, 3 STR-REQ : 15 lucre"
						var/const/temp2 = "Ringmail Vestments: 13 DEF, 4% eva, 15 STR-REQ : 75 lucre"
						var/const/temp3 = "Tunic: 5 DEF, 8% Eva, 5 STR-REQ : 30 lucre"
						var/const/temp4 = "Corslet: 14 DEF, 4% eva, 11 STR-REQ, : 67 lucre"
						var/const/temp5 = "Bastion: 11 DEF, 3% eva, 6 STR-REQ : 50 lucre"
						switch(input("What would you like to buy?","ARMORS") in list (temp1,temp2,temp3,temp4,temp5,"Leave"))
							if(temp1)
								if (M.lucre>=15)
									M.lucre-=15
									var/obj/items/armors/avgvestments/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp2)
								if (M.lucre>=75)
									M.lucre-=75
									var/obj/items/armors/choivestments/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp3)
								if (M.lucre>=30)
									M.lucre-=30
									var/obj/items/armors/avgtunic/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp4)
								if (M.lucre>=67)
									M.lucre-=67
									var/obj/items/armors/avgcorslet/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp5)
								if (M.lucre>=50)
									M.lucre-=50
									var/obj/items/shields/avgbast/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							else
								usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	Armors2
		name = "Armor Dealer"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "arm2"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(2)
				M = usr
				var/K = (input("Welcome","ARMORS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Bronzemail (Tunic): 13 def, 7% eva, 11 str req::89 lucre"
						var/const/temp2 = "CopperPlate (Cuirass): 23 def, 1% eva, 12 str req::250 lucre"
						var/const/temp3 = "Vanfos: 15 DEF, 10% Evasion, 12 STR-REQ::99 lucre"
						var/const/temp4 = "Screen Vanfos: 30 DEF, 2% Evasion, 20 STR-REQ::164 lucre"
						var/const/temp5 = "Aegis: 60 DEF, 4% Evasion, 30 STR-REQ::224 lucre"
						switch(input("What would you like to buy?","ARMORS") in list (temp1,temp2,temp3,temp4,temp5,"Leave"))
							if(temp1)
								if (M.lucre>=89)
									M.lucre-=89
									var/obj/items/armors/choitunic/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp2)
								if (M.lucre>=250)
									M.lucre-=250
									var/obj/items/armors/avgcuirass/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp3)
								if (M.lucre>=99)
									M.lucre-=99
									var/obj/items/shields/avgvanfos/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp4)
								if (M.lucre>=164)
									M.lucre-=164
									var/obj/items/shields/uncovanfos/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp5)
								if (M.lucre>=224)
									M.lucre-=224
									var/obj/items/shields/avgaegis/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							else
								usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	Armors3
		name = "Armor Dealer"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "arm3"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				var/K = (input("Welcome","ARMORS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Bronze SolidPlate (Cuirass): 28 def, 2% eva, 25 str req::250 lucre"
						var/const/temp2 = "Omphalos IronPlate (Battlegear): 18 def, 1% eva, 17 str req::176 lucre"
						var/const/temp3 = "Murrion Aegis: 84 DEF, 28% Evasion, 46 STR-REQ::224 lucre"
						var/const/temp4 = "Ravelin: 113 DEF, 21% Evasion, 67 STR-REQ::324 lucre"
						switch(input("What would you like to buy?","ARMORS") in list (temp1,temp2,temp3,temp4,"Leave"))
							if(temp1)
								if (M.lucre>=250)
									M.lucre-=250
									var/obj/items/armors/choicuirass/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp2)
								if (M.lucre>=176)
									M.lucre-=176
									var/obj/items/armors/choibattlegear/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp3)
								if (M.lucre>=224)
									M.lucre-=224
									var/obj/items/shields/uncoaegis/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							if(temp4)
								if (M.lucre>=324)
									M.lucre-=324
									var/obj/items/shields/avgravelin/J = new(M)
									usr << "Thank you for buying [J]."
								else
									NoLucre()
							else
								usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	Armors4
		name = "Blacksmith"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "harmr"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				var/K = (input("What would you like to purchase?","ARMORS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "ZincPlate (Battlegear): 189 def, 22% eva, 97 str req::445 lucre"
						var/const/temp2 = "SteelPlate (Battlegear): 264 def, 14% eva, 141 str req::2240 lucre"
						var/const/temp3 = "Thureos Shield: 155 def, 22% eva, 105 str req::760 lucre"
						var/const/temp4 = "Ravenous Thureos Shield: 285 def, 15% eva, 142 str req::1380 lucre"
						switch(input("What did I tell you?","ARMORS") in list (temp1,temp2,temp3,temp4,"Leave"))
							if(temp1)
								if (M.lucre>=445)
									M.lucre-=445
									var/obj/items/armors/ordibattlegear/J = new(M)
									usr << "Thank you for purchasing [J]"
								else
									NoLucre()
							if(temp2)
								if (M.lucre>=2240)
									M.lucre-=2240
									var/obj/items/armors/sinbattlegear/J = new(M)
									usr << "Thank you for purchasing [J]"
								else
									NoLucre()
							if(temp3)
								if (M.lucre>=760)
									M.lucre-=760
									var/obj/items/shields/avgthureos/J = new(M)
									usr << "Thank you for purchasing [J]"
								else
									NoLucre()
							if(temp4)
								if (M.lucre>=1380)
									M.lucre-=1380
									var/obj/items/shields/choithureos/J = new(M)
									usr << "Thank you for purchasing [J]"
								else
									NoLucre()
							else
								usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	Items1
		name = "Town Item Dealer"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "inv1"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				var/K = (input("What would you like to purchase?","ITEMS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Vitae Vial: restores up to 39 HP::42 lucre"
						var/const/temp2 = "stamina Tonic: restores up to 24 stamina::33 lucre"
						var/const/temp3 = "Large Vitae Vial: restores up to 64 HP::59 lucre"
						var/const/temp4 = "Strong stamina Tonic: restores up to 42 stamina::64 lucre"
						var/I = input("Items?","ITEMS") in list (temp1,temp2,temp3,temp4,"Leave")
						var/N
						if(I!="Leave")
							N = input("How many?","ITEMS") as num
						if(N>0)
							switch(I)
								if(temp1)
									if (M.lucre>=42*N)
										M.lucre-=42*N
										while(N>0)
											var/obj/items/Tonics/vitaevial/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>See you again."
								if(temp2)
									if (M.lucre>=33*N)
										M.lucre-=33*N
										while(N>0)
											var/obj/items/Tonics/staminatonic/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>See you again."
								if(temp3)
									if (M.lucre>=59*N)
										M.lucre-=59*N
										while(N>0)
											var/obj/items/Tonics/largevitaevial/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>See you again."
								if(temp4)
									if (M.lucre>=64*N)
										M.lucre-=64*N
										while(N>0)
											var/obj/items/Tonics/strongstaminatonic/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	ItemsT
		name = "Town Item Dealer"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "tsi"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				var/K = (input("What would you like to purchase?","ITEMS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Vitae Vial: restores up to 39 HP::45 lucre"
						var/const/temp2 = "stamina Tonic: restores up to 24 stamina::35 lucre"
						var/const/temp3 = "Large Vitae Vial: restores up to 64 HP::120 lucre"
						var/const/temp4 = "Strong stamina Tonic: restores up to 42 stamina::90 lucre"
						var/I = input("Items?","ITEMS") in list (temp1,temp2,temp3,temp4,"Leave")
						var/N
						if(I!="Leave")
							N = input("How many?","ITEMS") as num
						if(N>0)
							switch(I)
								if(temp1)
									if (M.lucre>=45*N)
										M.lucre-=45*N
										while(N>0)
											var/obj/items/Tonics/vitaevial/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>See you again."
								if(temp2)
									if (M.lucre>=35*N)
										M.lucre-=35*N
										while(N>0)
											var/obj/items/Tonics/staminatonic/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>See you again."
								if(temp3)
									if (M.lucre>=120*N)
										M.lucre-=120*N
										while(N>0)
											var/obj/items/Tonics/largevitaevial/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>See you again."
								if(temp4)
									if (M.lucre>=90*N)
										M.lucre-=90*N
										while(N>0)
											var/obj/items/Tonics/strongstaminatonic/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	Items1a
		name = "Village Item Dealer"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "vi1"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				var/K = (input("What would you like to purchase?","ITEMS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Vitae Vial: restores up to 39 HP::45 lucre"
						var/const/temp2 = "stamina Tonic: restores up to 24 stamina::33 lucre"
						var/I = input("Items?","ITEMS") in list (temp1,temp2,"Leave")
						var/N
						if(I!="Leave")
							N = input("How many?","ITEMS") as num
						if(N>0)
							switch(I)
								if(temp1)
									if (M.lucre>=45*N)
										M.lucre-=45*N
										while(N>0)
											var/obj/items/Tonics/vitaevial/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>See you again."
								if(temp2)
									if (M.lucre>=33*N)
										M.lucre-=33*N
										while(N>0)
											var/obj/items/Tonics/staminatonic/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>See you again."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	Items2
		name = "Item Dealer"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "inv2"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				var/K = (input("What would you like to purchase?","ITEMS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Vitae Liniments: restores up to 84 HP::88 lucre"
						var/const/temp2 = "stamina Spirits: restores up to 64 stamina::93 lucre"
						var/const/temp3 = "Quality Vitae Liniments: restores up to 113 HP::118 lucre"
						var/const/temp4 = "Strong stamina Spirits: restores up to 204 stamina::124 lucre"
						var/I = input("Items?","ITEMS") in list (temp1,temp2,temp3,temp4,"Leave")
						var/N
						if(I!="Leave")
							N = input("How many?","ITEMS") as num
						if(N>0)
							switch(I)
								if(temp1)
									if (M.lucre>=88*N)
										M.lucre-=88*N
										while(N>0)
											var/obj/items/Tonics/vitaeliniments/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp2)
									if (M.lucre>=93*N)
										M.lucre-=93*N
										while(N>0)
											var/obj/items/Tonics/staminaspirits/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp3)
									if (M.lucre>=118*N)
										M.lucre-=118*N
										while(N>0)
											var/obj/items/Tonics/qualityvitaeliniments/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp4)
									if (M.lucre>=124*N)
										M.lucre-=124*N
										while(N>0)
											var/obj/items/Tonics/strongstaminaspirits/J = new(M)
											N--
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	Items3
		name = "Item Dealer"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "Ftheurgist"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				var/K = (input("What would you like to purchase?","ITEMS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Vitae Curative: restores up to 184 HP::190 lucre"
						var/const/temp2 = "stamina Restorative: restores up to 168 stamina::204 lucre"
						var/const/temp3 = "Quality Vitae Curative: restores up to 264 HP::313 lucre"
						var/const/temp4 = "Strong stamina Restorative: restores up to 224 stamina::324 lucre"
						var/const/temp5 = "Antitoxin: counteracts toxins::150 lucre"
						var/I = input("Items?","ITEMS") in list (temp1,temp2,temp3,temp4,"Leave")
						var/N
						if(I!="Leave")
							N = input("How many?","ITEMS") as num
						if(N>0)
							switch(I)
								if(temp1)
									if (M.lucre>=190*N)
										M.lucre-=190*N
										while(N>0)
											var/obj/items/Tonics/vitaecurative/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp2)
									if (M.lucre>=204*N)
										M.lucre-=204*N
										while(N>0)
											var/obj/items/Tonics/staminarestorative/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp3)
									if (M.lucre>=313*N)
										M.lucre-=313*N
										while(N>0)
											var/obj/items/Tonics/qualityvitaecurative/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp4)
									if (M.lucre>=324*N)
										M.lucre-=324*N
										while(N>0)
											var/obj/items/Tonics/strongstaminarestorative/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp5)
									if (M.lucre>=150*N)
										M.lucre-=150*N
										while(N>0)
											var/obj/items/Tonics/antitoxin/J = new(M)
											N--
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	Items4
		name = "Merchant"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "hitems"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				var/K = (input("What would you like to purchase?","ITEMS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Large Quality Vitae Curative: restores up to 364 HP::420 lucre"
						var/const/temp2 = "Large Strong stamina Restorative: restores up to 324 stamina::444 lucre"
						var/const/temp3 = "Strong Antitoxin: Counteracts Toxins::250 lucre"
						var/I = input("Items?","ITEMS") in list (temp1,temp2,temp3,"Leave")
						var/N
						if(I!="Leave")
							N = input("How many?","ITEMS") as num
						if(N>0)
							switch(I)
								if(temp1)
									if (M.lucre>=313*N)
										M.lucre-=313*N
										while(N>0)
											var/obj/items/Tonics/concentratedvitaecurative/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp2)
									if (M.lucre>=324*N)
										M.lucre-=324*N
										while(N>0)
											var/obj/items/Tonics/stronglargestaminarestorative/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp3)
									if (M.lucre>=250*N)
										M.lucre-=250*N
										while(N>0)
											var/obj/items/Tonics/strngantitoxin/J = new(M)
											N--
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."


	AncientScrpt1
		name = "Tome Keeper"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "mag1"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				var/K = (input("What Scroll would you like?","Ancient Scrolls") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Ancient Tome of Heat::400 lucre"
						var/const/temp2 = "Ancient Tome of Shard Burst::500 lucre"
						var/const/temp3 = "Ancient Tome of Water Shock::600 lucre"
						var/const/temp4 = "Ancient Tome of Vitae::400 lucre"
						var/I = input("Items?","ITEMS") in list (temp1,temp2,temp3,temp4,"Leave")
						var/N
						if(I!="Leave")
							N = input("How many?","ITEMS") as num
						if(N>0)
							switch(I)
								if(temp1)
									if (M.lucre>=400*N)
										M.lucre-=400*N
										while(N>0)
											var/obj/items/ancscrlls/heat/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp2)
									if (M.lucre>=500*N)
										M.lucre-=500*N
										while(N>0)
											var/obj/items/ancscrlls/shardburst/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp3)
									if (M.lucre>=600*N)
										M.lucre-=600*N
										while(N>0)
											var/obj/items/ancscrlls/watershock/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp4)
									if (M.lucre>=400*N)
										M.lucre-=400*N
										while(N>0)
											var/obj/items/ancscrlls/vitae/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	AncientScrpt2
		name = "Tome Keeper"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "mag2"
		layer = 6
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				var/K = (input("What Scroll would you like?","Ancient Scrolls") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Ancient Tome of Heat::400 lucre"
						var/const/temp2 = "Ancient Tome of Shard Burst::500 lucre"
						var/const/temp3 = "Ancient Tome of Water Shock::600 lucre"
						var/const/temp4 = "Ancient Tome of Vitae::400 lucre"
						var/I = input("Items?","ITEMS") in list (temp1,temp2,temp3,temp4,"Leave")
						var/N
						if(I!="Leave")
							N = input("How many?","ITEMS") as num
						if(N>0)
							switch(I)
								if(temp1)
									if (M.lucre>=400*N)
										M.lucre-=400*N
										while(N>0)
											var/obj/items/ancscrlls/heat/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp2)
									if (M.lucre>=500*N)
										M.lucre-=500*N
										while(N>0)
											var/obj/items/ancscrlls/shardburst/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp3)
									if (M.lucre>=600*N)
										M.lucre-=600*N
										while(N>0)
											var/obj/items/ancscrlls/watershock/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp4)
									if (M.lucre>=400*N)
										M.lucre-=400*N
										while(N>0)
											var/obj/items/ancscrlls/vitae/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	AncientScrpt1a
		name = "Tome Keeper"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "rsdss"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				var/K = (input("What Scroll would you like?","Ancient Scrolls") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Ancient Tome of Heat::400 lucre"
						var/const/temp2 = "Ancient Tome of Shard Burst::500 lucre"
						var/const/temp3 = "Ancient Tome of Water Shock::600 lucre"
						var/const/temp4 = "Ancient Tome of Vitae::400 lucre"
						var/I = input("Items?","ITEMS") in list (temp1,temp2,temp3,temp4,"Leave")
						var/N
						if(I!="Leave")
							N = input("How many?","ITEMS") as num
						if(N>0)
							switch(I)
								if(temp1)
									if (M.lucre>=400*N)
										M.lucre-=400*N
										while(N>0)
											var/obj/items/ancscrlls/heat/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp2)
									if (M.lucre>=500*N)
										M.lucre-=500*N
										while(N>0)
											var/obj/items/ancscrlls/shardburst/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp3)
									if (M.lucre>=600*N)
										M.lucre-=600*N
										while(N>0)
											var/obj/items/ancscrlls/watershock/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp4)
									if (M.lucre>=400*N)
										M.lucre-=400*N
										while(N>0)
											var/obj/items/ancscrlls/vitae/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	AncientScrpt3
		name = "Tome Keeper"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "mag1"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				var/K = (input("What would you like to purchase?","ITEMS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Ancient Tome of Flame::2000 lucre"
						var/const/temp2 = "Ancient Tome of Ice Storm::2500 lucre"
						var/const/temp3 = "Ancient Tome of Cascade Lightning::3000 lucre"
						var/const/temp4 = "Ancient Tome of Telekinesis::1000 lucre"
						var/I = input("Items?","ITEMS") in list (temp1,temp2,temp3,temp4,"Leave")
						var/N
						if(I!="Leave")
							N = input("How many?","ITEMS") as num
						if(N>0)
							switch(I)
								if(temp1)
									if (M.lucre>=2000*N)
										M.lucre-=2000*N
										while(N>0)
											var/obj/items/ancscrlls/flame/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp2)
									if (M.lucre>=2500*N)
										M.lucre-=2500*N
										while(N>0)
											var/obj/items/ancscrlls/icestorm/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp3)
									if (M.lucre>=3000*N)
										M.lucre-=3000*N
										while(N>0)
											var/obj/items/ancscrlls/cascadelightning/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp4)
									if (M.lucre>=1000*N)
										M.lucre-=1000*N
										while(N>0)
											var/obj/items/ancscrlls/telekinesis/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."
	AncientScrpt4
		name = "Tome Keeper"
		density = 1
		icon = 'dmi/64/npcs.dmi'
		icon_state = "hscrpt"
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				var/K = (input("What would you like to purchase?","ITEMS") in list("Buy","Sell","Leave"))
				switch(K)
					if("Buy")
						var/const/temp1 = "Ancient Tome of Bludgeon::5000 lucre"
						var/const/temp2 = "Ancient Tome Acid::5000 lucre"
						var/const/temp3 = "Ancient Tome Cosmos::6000 lucre"
						var/const/temp4 = "Ancient Tome Rephase::6000 lucre"
						var/I = input("Items?","ITEMS") in list (temp1,temp2,temp3,temp4,"Leave")
						var/N
						if(I!="Leave")
							N = input("How many?","ITEMS") as num
						if(N>0)
							switch(I)
								if(temp1)
									if (M.lucre>=5000*N)
										M.lucre-=5000*N
										while(N>0)
											var/obj/items/ancscrlls/bludgeon/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp2)
									if (M.lucre>=5000*N)
										M.lucre-=5000*N
										while(N>0)
											var/obj/items/ancscrlls/acid/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp3)
									if (M.lucre>=6000*N)
										M.lucre-=6000*N
										while(N>0)
											var/obj/items/ancscrlls/cosmos/J = new(M)
											N--
											usr << "Thank you for buying [J]."
									else
										NoLucre()
								if(temp4)
									if (M.lucre>=6000*N)
										M.lucre-=6000*N
										while(N>0)
											var/obj/items/ancscrlls/rephase/J = new(M)
											usr << "Thank you for buying [J]."
											N--
									else
										usr << "<font color = teal>Maybe next time."
					if("Sell")
						Selling(input("What would you like to sell") in usr)
					else
						usr << "<font color = teal>Maybe next time."


	Bank //Ya the bank!!!
		icon='dmi/64/npcs.dmi'
		icon_state="bnk1"
		density = 1
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				sleep(2)
				switch(alert("Welcome to the bank. What would you like to do?","Bank","Deposit","Withdraw","Cancel","Back"))
					if("Deposit")
						var/d = input("You have [M.lucre] Lucre on you, How much Lucre do you wish to deposit?") as num|null
						if(d >= M.lucre+1)
							alert("You don't seem to have that much Lucre.")
							return
						if(d <= 0)
							alert("Please don't waste my time, Sir.")
							return
						if(d <= M.lucre+1)
							alert("You deposited [d] Lucre into your holding account.")
							M.bankedlucre += d
							M.lucre -=d
					if("Withdraw")
						if(M.bankedlucre <= 0)
							alert("Sorry, But it seems you don't have any Lucre in your holding account.")
							return
						else
							var/m = input("You have [M.bankedlucre] Lucre in your holding account, How much do you wish to take?") as num|null
							if(m >= M.bankedlucre+1)
								alert("You don't have that much Lucre")
								return
							if(m <=0)
								return
							else
								M.lucre += m
								M.bankedlucre -= m
								alert("Thank you, Stop by anytime!")
								return
					if("Cancel")
						return
	hBank //Ya the bank!!!
		icon='dmi/64/npcs.dmi'
		icon_state="hbnk"
		density = 1
		verb
			Talk()
				set hidden = 1
				var/mob/players/M
				set src in oview(1)
				M = usr
				sleep(2)
				switch(alert("Welcome to the bank. What would you like to do?","Bank","Deposit","Withdraw","Cancel","Back"))
					if("Deposit")
						var/d = input("You have [M.lucre] Lucre on you, How much Lucre do you wish to deposit?") as num|null
						if(d >= M.lucre+1)
							alert("You don't seem to have that much Lucre.")
							return
						if(d <= 0)
							alert("Please don't waste my time, Sir.")
							return
						if(d <= M.lucre+1)
							alert("You deposited [d] Lucre into your holding account.")
							M.bankedlucre += d
							M.lucre -=d
					if("Withdraw")
						if(M.bankedlucre <= 0)
							alert("Sorry, But it seems you don't have any Lucre in your holding account.")
							return
						else
							var/m = input("You have [M.bankedlucre] Lucre in your holding account, How much do you wish to take?") as num|null
							if(m >= M.bankedlucre+1)
								alert("You don't have that much Lucre")
								return
							if(m <=0)
								return
							else
								M.lucre += m
								M.bankedlucre -= m
								alert("Thank you, Stop by anytime!")
								return
					if("Cancel")
						return

	/*Jar
		name = "Jar"
		density = 1
		plane = MOB_LAYER+1
		liquid = 0
		icon = 'dmi/64/creation.dmi'
		icon_state = "Jar"
		var/mob/players/M
		verb //...
			Fill() //...
				//set category = "Commands"
				set src in oview(1) //...
				Fill(M)*/ //calls the mining proc
/*
	snowyrock
		name = "Snowy Rock"
		icon = 'dmi/64/snow.dmi'
		density = 1
		icon_state = "snowyrock"
	ices1
		name = "Ice"
		icon = 'dmi/64/snow.dmi'
		density = 1
		icon_state = "ices1"
	ices2
		name = "Ice"
		icon = 'dmi/64/snow.dmi'
		density = 1
		icon_state = "ices2"
	icecolumn1
		name = "Ice Column"
		density = 1
		icon = 'dmi/64/snow.dmi'
		icon_state = "icecolumn1"
	icecolumn4
		name = "Ice Column"
		density = 1
		icon = 'dmi/64/snow.dmi'
		icon_state = "icecolumn4"
	crystal1
		name = "Ice Crystal"
		density = 1
		plane = MOB_LAYER+1
		icon = 'dmi/64/snow.dmi'
		icon_state = "crystal1"
	crystal4
		name = "Ice Crystal"
		plane = MOB_LAYER+1
		icon = 'dmi/64/snow.dmi'
		icon_state = "crystal4"
	crystal
		name = "Ice Crystal"
		icon = 'dmi/64/snow.dmi'
		density = 1
		icon_state = "crystal"
		msmiexp = 100
		msmeexp = 100*/
proc
	smeltingunlock()

		set background = 1
		var/mob/players/M
		M = usr
		if(M.smerank == 1)
			//M.drank += 1
			//M << "<b><font color=silver>You know how to smelt iron!"
			//usr << "<b><font color=silver>Your Build Rank went up!"
			smelt = list("Iron","Cancel","Back")
			return
		else
			if(M.smerank == 2)
				//M.smerank += 1
				//M.msmeexp = 10
				//usr << "<b><font color=silver>Your Smelting Rank went up!"
				smelt = list("Iron","Lead","Cancel","Back")
				return
			else
				if(M.smerank == 3)
					//M.smerank += 1
					//M.msmeexp = 50
					//usr << "<b><font color=silver>Your Smelting Rank went up!"
					smelt = list("Iron","Lead","Zinc","Cancel","Back")
					return
				else
					if(M.smerank == 4)
						//M.smerank += 1
						//M.msmeexp = 100
						//usr << "<b><font color=silver>Your Smelting Rank went up!"
						smelt = list("Iron","Lead","Zinc","Copper","Cancel","Back")
						return
					else
						if(M.smerank == 5)
							//M.smerank += 1
							//M.msmeexp = 1000
							//usr << "<b><font color=silver>Your Smelting Rank went up!"
							smelt = list("Iron","Lead","Zinc","Copper","Bronze","Cancel","Back")
							return
						else
							if(M.smerank == 6)
								//M.smerank += 1
								//M.msmeexp = 5000
								//usr << "<b><font color=silver>Your Smelting Rank went up!"
								smelt = list("Iron","Lead","Zinc","Copper","Bronze","Brass","Cancel","Back")
								return
							else
								if(M.smerank == 7)
									//M.smerank += 1
									//M.msmeexp = 5000
									//usr << "<b><font color=silver>Your Smelting Rank went up!"
									smelt = list("Iron","Lead","Zinc","Copper","Bronze","Brass","Steel","Cancel","Back")
									return
								else
									if (M.smerank>=7)
										//M << "<b><font color=silver>You've reached Max Build Rank!"
										M.smerank = 7
										return
		//..()
proc
	smeltinglevel()
		set background = 1
		var/mob/players/M
		M = usr
		//if((M.smerank >= 0)&&(M.smeexp >= 0))
			//M.drank += 1
			//M << "<b><font color=silver>Your Smithing Rank went up!"
			//usr << "<b><font color=silver>Your Build Rank went up!"
			//M.smelt.Add("Iron")
		if((M.smerank == 1)&&(M.smeexp >= 5))
			M.smerank += 1
			M.msmeexp = 15
			usr << "<b><font color=silver>You learn about smelting!"
			//M.smelt.Add("Lead")
		if((M.smerank == 1)&&(M.smeexp >= 20))
			M.smerank += 1
			M.msmeexp = 20
			usr << "<b><font color=silver>You gain more smelting knowledge!"
		if((M.smerank == 2)&&(M.smeexp >= 40))
			M.smerank += 1
			M.msmeexp = 50
			usr << "<b><font color=silver>You gain more smelting knowledge!"
			//M.smelt.Add("Zinc")
		if((M.smerank == 3)&&(M.smeexp >= 90))
			M.smerank += 1
			M.msmeexp = 100
			usr << "<b><font color=silver>You gain more smelting knowledge!"
			//M.smelt.Add("Copper")
		if((M.smerank == 4)&&(M.smeexp >= 190))
			M.smerank += 1
			M.msmeexp = 200
			usr << "<b><font color=silver>You gain more smelting knowledge!"
			//M.smelt.Add("Brass")
		if((M.smerank == 5)&&(M.smeexp >= 390))
			M.smerank += 1
			M.msmeexp = 780
			usr << "<b><font color=silver>You gain more smelting knowledge!"
			//M.smelt.Add("Bronze")
		if((M.smerank == 6)&&(M.smeexp >= 780))
			M.smerank += 1
			M.msmeexp = 1560
			usr << "<b><font color=silver>You gain more smelting knowledge!"
		if((M.smerank == 7)&&(M.smeexp >= 1560))
			//M.smerank += 1
			//M.msmeexp = 5000
			M.msmeexp = M.smeexp
			usr << "<b><font color=silver>You know all there is to know about smelting!"
			//M.smelt.Add("Bronze")
		else
			if(M.smerank >= 7)
				//M << "<b><font color=silver>You begin to wonder what more is there to build... (Building Acuity: [M.brank])"
				M.smerank = 7

proc
	smithingunlock()
		set background = 1
		var/mob/players/M
		M = usr
		//tools
		if(M.smirank == 1)
			M.smith = list("Tools","Misc.","Cancel","Back")
			M.smithm = list("Iron Nails","Cancel","Back")
			M.smitht = list("Carving Knife blade","Hammer head","File blade","Cancel","Back")//remove trowel blade after testing
			M.smithw = list("")
			M.smithl = list("")
			M.smithae = list("")
			M.smithad = list("")
			M.smithao = list("")
			return
		else
			if(M.smirank == 2)
				M.smith = list("Tools","Misc.","Cancel","Back")
				M.smithm = list("Iron Ribbon","Iron Nails","Cancel","Back")
				M.smitht = list("Carving Knife blade","Hammer head","File blade","Axe blade","Cancel","Back")
				M.smithw = list("")
				M.smithl = list("")
				M.smithae = list("")
				M.smithad = list("")
				M.smithao = list("")
				//M.smith.Add("Armors","Platemail")
				return
			else
				if(M.smirank == 3)
					//usr << "<b><font color=silver>Your Smithing Rank went up!"
					M.smith = list("Tools","Misc.","Cancel","Back")
					M.smithm = list("Iron Ribbon","Iron Nails","Cancel","Back")
					M.smitht = list("Carving Knife blade","Hammer head","File blade","Axe blade","Pickaxe head","Iron Reel","Cancel","Back")
					M.smithw = list("")
					M.smithl = list("")
					M.smithae = list("")
					M.smithad = list("")
					M.smithao = list("")
					return
				else
					if(M.smirank == 4)
						M.smith = list("Tools","Misc.","Cancel","Back")
						M.smithm = list("Iron Ribbon","Iron Nails","Cancel","Back")
						M.smitht = list("Carving Knife blade","Hammer head","File blade","Axe blade","Pickaxe head","Iron Reel","Shovel blade","Cancel","Back")
						M.smithw = list("")
						M.smithl = list("")
						M.smithae = list("")
						M.smithad = list("")
						M.smithao = list("")
						return
					else
						if(M.smirank == 5)
							M.smith = list("Tools","Misc.","Cancel","Back")
							M.smithm = list("Iron Ribbon","Iron Nails","Cancel","Back")
							M.smitht = list("Carving Knife blade","Hammer head","File blade","Axe blade","Pickaxe head","Iron Reel","Shovel blade","Hoe blade","Cancel","Back")
							M.smithw = list("")
							M.smithl = list("")
							M.smithae = list("")
							M.smithad = list("")
							M.smithao = list("")
							return
						else
							if(M.smirank == 6)
								M.smith = list("Tools","Misc.","Cancel","Back")
								M.smithm = list("Iron Ribbon","Iron Nails","Cancel","Back")
								M.smitht = list("Carving Knife blade","Hammer head","File blade","Axe blade","Pickaxe head","Iron Reel","Shovel blade","Hoe blade","Saw blade","Cancel","Back")
								M.smithw = list("")
								M.smithl = list("")
								M.smithae = list("")
								M.smithad = list("")
								M.smithao = list("")
								return
							else
								if(M.smirank == 7)
									M.smith = list("Tools","Misc.","Weapons","Cancel","Back")
									M.smithm = list("Iron Ribbon","Iron Nails","Cancel","Back")
									M.smitht = list("Carving Knife blade","Hammer head","File blade","Axe blade","Pickaxe head","Iron Reel","Shovel blade","Hoe blade","Saw blade","Sickle blade","Cancel","Back")
									M.smithw = list("Broad Sword","Cancel","Back")
									M.smithl = list("")
									M.smithae = list("")
									M.smithad = list("")
									M.smithao = list("")
									return
								else
									if(M.smirank == 8)
										M.smith = list("Tools","Weapons","Armors","Misc.","Cancel","Back")
										M.smithm = list("Iron Ribbon","Iron Nails","Cancel","Back")
										M.smitht = list("Carving Knife blade","Hammer head","File blade","Axe blade","Pickaxe head","Iron Reel","Shovel blade","Hoe blade","Saw blade","Sickle blade","Chisel Blade","Cancel","Back")
										M.smithw = list("Broad Sword","War Sword","Cancel","Back")
										M.smithl = list("")
										M.smithae = list("Giu Hide Vestments","Monk Tunic","Giu ShellHide Corslet","Cancel","Back")
										M.smithad = list("CopperPlate Cuirass","Cancel","Back")
										M.smithao = list("IronPlate Battlegear","Cancel","Back")
										return
									else
										if(M.smirank == 9)
											M.smith = list("Tools","Weapons","Armors","Misc.","Cancel","Back")
											M.smithm = list("Iron Ribbon","Iron Nails","Cancel","Back")
											M.smitht = list("Carving Knife blade","Hammer head","File blade","Axe blade","Pickaxe head","Iron Reel","Shovel blade","Hoe blade","Saw blade","Sickle blade","Chisel Blade","Cancel","Back")
											M.smithw = list("Broad Sword","War Sword","Battle Sword","Cancel","Back")
											M.smithl = list("")
											M.smithae = list("Cancel","Giu Hide Vestments","Monk Tunic","Giu ShellHide Corslet","Giu Shell Vestments","Iron Studded Tunic","Gou ShellPlate Corslet")
											M.smithad = list("Cancel","IronPlate Cuirass","CopperPlate Cuirass")
											M.smithao = list("Cancel","IronPlate Battlegear","BronzePlate Battlegear")
											return
										else
											if(M.smirank == 10)
												M.smith = list("Tools","Weapons","Armors","Lamps","Misc.","Cancel","Back")
												M.smithm = list("Iron Ribbon","Iron Nails","Cancel","Back")
												M.smitht = list("Carving Knife blade","Hammer head","File blade","Axe blade","Pickaxe head","Iron Reel","Shovel blade","Hoe blade","Saw blade","Sickle blade","Chisel Blade","Trowel blade","Cancel","Back")
												M.smithw = list("Broad Sword","War Sword","Battle Sword","Long Sword","War Maul","Battle Hammer","Cancel","Back")
												M.smithl = list("Iron Lamp Head","Cancel","Back")//roads and floors first then walls and doors then more advanced of the same etc
												M.smithae = list("Cancel","Giu Hide Vestments","Monk Tunic","Giu ShellHide Corslet","Giu Shell Vestments","Iron Studded Tunic","Gou ShellPlate Corslet","Gou ShellHide Vestments","Copper ShellPlate Tunic","Iron Platemail Corslet")
												M.smithad = list("Cancel","IronPlate Cuirass","CopperPlate Cuirass","Iron HalfPlate Cuirass","Bronze SolidPlate Cuirass")
												M.smithao = list("Cancel","IronPlate Battlegear","BronzePlate Battlegear","IronPlate Battlegear")
												return
											else
												if(M.smirank == 11)
													M.smith = list("Tools","Weapons","Armors","Lamps","Misc.","Cancel","Back")
													M.smithm = list("Iron Ribbon","Iron Nails","Cancel","Back")
													M.smitht = list("Carving Knife blade","Hammer head","File blade","Axe blade","Pickaxe head","Iron Reel","Shovel blade","Hoe blade","Saw blade","Sickle blade","Chisel Blade","Trowel blade","Cancel","Back")
													M.smithw = list("Broad Sword","War Sword","Battle Sword","Long Sword","War Maul","Battle Hammer","War Axe","Cancel","Back")
													M.smithl = list("Iron Lamp Head","Copper Lamp Head","Cancel","Back")//roads and floors first then walls and doors then more advanced of the same etc
													M.smithae = list("Cancel","Giu Hide Vestments","Monk Tunic","Giu ShellHide Corslet","Giu Shell Vestments","Iron Studded Tunic","Gou ShellPlate Corslet","Gou ShellHide Vestments","Copper ShellPlate Tunic","Iron Platemail Corslet","Coppermail Vestments","Bronzemail Tunic","Copper Platemail Corslet")
													M.smithad = list("Cancel","CopperPlate Cuirass","IronPlate Cuirass","Iron HalfPlate Cuirass","Bronze SolidPlate Cuirass","Boreal ZincPlate Cuirass")
													M.smithao = list("Cancel","IronPlate Battlegear","BronzePlate Battlegear","IronPlate Battlegear","Omphalos BronzePlate Battlegear")
													return
												else

													if(M.smirank == 12)
														M.smith = list("Tools","Weapons","Armors","Lamps","Misc.","Cancel","Back")
														M.smithm = list("Iron Ribbon","Iron Nails","Cancel","Back")
														M.smitht = list("Carving Knife blade","Hammer head","File blade","Axe blade","Pickaxe head","Iron Reel","Shovel blade","Hoe blade","Saw blade","Sickle blade","Chisel Blade","Trowel blade","Cancel","Back")
														M.smithw = list("Broad Sword","War Sword","Battle Sword","Long Sword","War Maul","Battle Hammer","War Axe","Battle Axe","Cancel","Back")
														M.smithl = list("Iron Lamp Head","Copper Lamp Head","Bronze Lamp Head","Cancel","Back")//roads and floors first then walls and doors then more advanced of the same etc
														M.smithae = list("Cancel","Giu Hide Vestments","Giu Shell Vestments","Gou ShellHide Vestments","Coppermail Vestments","Zinc ShellPlate Vestments","Steel ShellPlate Vestments","Monk Tunic","Iron Studded Tunic","Copper ShellPlate Tunic","Bronzemail Tunic","Zincmail Tunic","Landscaper Tunic","Giu ShellHide Corslet","Gou ShellPlate Corslet","Iron Platemail Corslet","Copper Platemail Corslet","Bronzemail Corslet","Zinc Platemail Corslet")
														M.smithad = list("Cancel","CopperPlate Cuirass","IronPlate Cuirass","Iron HalfPlate Cuirass","Bronze SolidPlate Cuirass","Boreal ZincPlate Cuirass","Aurelian SteelPlate Cuirass")
														M.smithao = list("Cancel","IronPlate Battlegear","BronzePlate Battlegear","IronPlate Battlegear","Omphalos BronzePlate Battlegear","ZincPlate Battlegear","SteelPlate Battlegear")
														return
													else

														if(M.smirank == 13)
															M.smith = list("Tools","Weapons","Armors","Lamps","Misc.","Cancel","Back")
															M.smithm = list("Iron Ribbon","Iron Nails","Cancel","Back")
															M.smitht = list("Carving Knife blade","Hammer head","File blade","Axe blade","Pickaxe head","Iron Reel","Shovel blade","Hoe blade","Saw blade","Sickle blade","Chisel Blade","Trowel blade","Cancel","Back")
															M.smithw = list("Broad Sword","War Sword","Battle Sword","Long Sword","War Maul","Battle Hammer","War Axe","Battle Axe","War Scythe","Cancel","Back")
															M.smithl = list("Iron Lamp Head","Copper Lamp Head","Bronze Lamp Head","Brass Lamp Head","Cancel","Back")//roads and floors first then walls and doors then more advanced of the same etc
															M.smithae = list("Cancel","Giu Hide Vestments","Giu Shell Vestments","Gou ShellHide Vestments","Coppermail Vestments","Zinc ShellPlate Vestments","Steel ShellPlate Vestments","Monk Tunic","Iron Studded Tunic","Copper ShellPlate Tunic","Bronzemail Tunic","Zincmail Tunic","Landscaper Tunic","Giu ShellHide Corslet","Gou ShellPlate Corslet","Iron Platemail Corslet","Copper Platemail Corslet","Bronzemail Corslet","Zinc Platemail Corslet")
															M.smithad = list("Cancel","CopperPlate Cuirass","IronPlate Cuirass","Iron HalfPlate Cuirass","Bronze SolidPlate Cuirass","Boreal ZincPlate Cuirass","Aurelian SteelPlate Cuirass")
															M.smithao = list("Cancel","IronPlate Battlegear","BronzePlate Battlegear","IronPlate Battlegear","Omphalos BronzePlate Battlegear","ZincPlate Battlegear","SteelPlate Battlegear")
															return
														else

															if(M.smirank == 14)
																M.smith = list("Tools","Weapons","Armors","Lamps","Misc.","Cancel","Back")
																M.smithm = list("Iron Ribbon","Iron Nails","Cancel","Back")
																M.smitht = list("Carving Knife blade","Hammer head","File blade","Axe blade","Pickaxe head","Iron Reel","Shovel blade","Hoe blade","Saw blade","Sickle blade","Chisel Blade","Trowel blade","Cancel","Back")
																M.smithw = list("Broad Sword","War Sword","Battle Sword","Long Sword","War Maul","Battle Hammer","War Axe","Battle Axe","War Scythe","Battle Scythe","Cancel","Back")
																M.smithl = list("Iron Lamp Head","Copper Lamp Head","Bronze Lamp Head","Brass Lamp Head","Steel Lamp Head","Cancel","Back")//roads and floors first then walls and doors then more advanced of the same etc
																M.smithae = list("Cancel","Giu Hide Vestments","Giu Shell Vestments","Gou ShellHide Vestments","Coppermail Vestments","Zinc ShellPlate Vestments","Steel ShellPlate Vestments","Monk Tunic","Iron Studded Tunic","Copper ShellPlate Tunic","Bronzemail Tunic","Zincmail Tunic","Landscaper Tunic","Giu ShellHide Corslet","Gou ShellPlate Corslet","Iron Platemail Corslet","Copper Platemail Corslet","Bronzemail Corslet","Zinc Platemail Corslet")
																M.smithad = list("Cancel","CopperPlate Cuirass","IronPlate Cuirass","Iron HalfPlate Cuirass","Bronze SolidPlate Cuirass","Boreal ZincPlate Cuirass","Aurelian SteelPlate Cuirass")
																M.smithao = list("Cancel","IronPlate Battlegear","BronzePlate Battlegear","IronPlate Battlegear","Omphalos BronzePlate Battlegear","ZincPlate Battlegear","SteelPlate Battlegear")
																return
															else
																if (M.smirank>=14)
																	//M << "<b><font color=silver>You've reached Max Build Rank!"
																	M.smirank = 14
																	return
/*
		//armor
	  //requirements
		var/obj/items/GiuHide/GH0 = locate() in M.contents
		var/obj/items/GiuShell/GS0 = locate() in M.contents

		var/obj/items/GiuShell/GS1 = locate() in M.contents
		var/obj/items/GiuHide/GH1 = locate() in M.contents

		var/obj/items/GouShell/GS2 = locate() in M.contents
		var/obj/items/GouHide/GH2 = locate() in M.contents

		var/obj/items/GowShell/GS3 = locate() in M.contents
		var/obj/items/GowHide/GH3 = locate() in M.contents

		var/obj/items/GuwiShell/GS4 = locate() in M.contents
		var/obj/items/GuwiHide/GH4 = locate() in M.contents

		var/obj/items/GowuShell/GS5 = locate() in M.contents
		var/obj/items/GowuHide/GH5 = locate() in M.contents
	//evasive armors
		if((GH0 in M.contents)&&(M.smirank == 0)&&(M.smiexp >= 0)) "Giu Hide Vestments","Giu Shell Vestments","Gou ShellHide Vestments","Coppermail Vestments","Zinc ShellPlate Vestments","Steel ShellPlate Vestments"
			M.smithae.Add("Giu Hide Vestments") "Giu Hide Vestments","Monk Tunic","Giu ShellHide Corslet" evasive lvl 1
		if((GS1 in M.contents)&&(M.smirank == 1)&&(M.smiexp >= 10))
			M.smithae.Add("Giu Shell Vestments") "Giu Hide Vestments","Monk Tunic","Giu ShellHide Corslet","Giu Shell Vestments","Iron Studded Tunic","Gou ShellPlate Corslet",
		if((GS2 in M.contents)&&(GH2 in M.contents)&&(M.smirank == 2)&&(M.smiexp >= 50))
			M.smithae.Add("Gou ShellHide Vestments") "Giu Hide Vestments","Monk Tunic","Giu ShellHide Corslet","Giu Shell Vestments","Iron Studded Tunic","Gou ShellPlate Corslet","Gou ShellHide Vestments","Copper ShellPlate Tunic","Iron Platemail Corslet"
		if((GH3 in M.contents)&&(M.smirank == 3)&&(M.smiexp >= 100))
			M.smithae.Add("Coppermail Vestments")"Giu Hide Vestments","Monk Tunic","Giu ShellHide Corslet","Giu Shell Vestments","Iron Studded Tunic","Gou ShellPlate Corslet","Gou ShellHide Vestments","Copper ShellPlate Tunic","Iron Platemail Corslet"
			"Coppermail Vestments","Bronzemail Tunic","Copper Platemail Corslet"
		if((GS4 in M.contents)&&(M.smirank == 4)&&(M.smiexp >= 500))
			M.smithae.Add("Zinc ShellPlate Vestments")
		if((GS5 in M.contents)&&(M.smirank == 5)&&(M.smiexp >= 1000))
			M.smithae.Add("Steel ShellPlate Vestments")
		//Landscaper
		if((GH0 in M.contents)&&(GS0 in M.contents)&&(M.smirank == 0)&&(M.smiexp >= 0)) "Monk Tunic","Iron Studded Tunic","Copper ShellPlate Tunic","Bronzemail Tunic","Zincmail Tunic","Landscaper Tunic"
			M.smithae.Add("Monk Tunic")
		if((GH1 in M.contents)&&(M.smirank == 1)&&(M.smiexp >= 10))
			M.smithae.Add("Iron Studded Tunic")
		if((GH2 in M.contents)&&(M.smirank == 2)&&(M.smiexp >= 50))
			M.smithae.Add("Copper ShellPlate Tunic")
		if((GH3 in M.contents)&&(M.smirank == 3)&&(M.smiexp >= 100))
			M.smithae.Add("Bronzemail Tunic")
		if((GH4 in M.contents)&&(M.smirank == 4)&&(M.smiexp >= 500))
			M.smithae.Add("Zincmail Tunic")
		if((GS5 in M.contents)&&(GH5 in M.contents)&&(M.smirank == 5)&&(M.smiexp >= 1000))
			M.smithae.Add("Landscaper Tunic")
		//All Classes
		if((GH0 in M.contents)&&(GS0 in M.contents)&&(M.smirank == 0)&&(M.smiexp >= 0)) "Giu ShellHide Corslet","Gou ShellPlate Corslet","Iron Platemail Corslet","Copper Platemail Corslet","Bronzemail Corslet","Zinc Platemail Corslet"
			M.smithae.Add("Giu ShellHide Corslet")
		if((GS1 in M.contents)&&(M.smirank == 1)&&(M.smiexp >= 10))
			M.smithae.Add("Gou ShellPlate Corslet")
		if((GS2 in M.contents)&&(M.smirank == 2)&&(M.smiexp >= 50))
			M.smithae.Add("Iron Platemail Corslet")
		if((GS3 in M.contents)&&(M.smirank == 3)&&(M.smiexp >= 100))
			M.smithae.Add("Copper Platemail Corslet")
		if((GS4 in M.contents)&&(M.smirank == 4)&&(M.smiexp >= 500))
			M.smithae.Add("Bronzemail Corslet")
		if((GS5 in M.contents)&&(M.smirank == 5)&&(M.smiexp >= 1000))
			M.smithae.Add("Zinc Platemail Corslet")
	  //Defensive
	    //Landscaper
		if((GS0 in M.contents)&&(GH0 in M.contents)&&(M.smirank == 0)&&(M.smiexp >= 0)) "CopperPlate Cuirass","IronPlate Cuirass","Iron HalfPlate Cuirass","Bronze SolidPlate Cuirass","Boreal ZincPlate Cuirass","Aurelian SteelPlate Cuirass"
			M.smithad.Add("CopperPlate Cuirass")
		if((GS1 in M.contents)&&(GH1 in M.contents)&&(M.smirank == 1)&&(M.smiexp >= 10))
			M.smithad.Add("IronPlate Cuirass")
		if((GS2 in M.contents)&&(GH2 in M.contents)&&(M.smirank == 2)&&(M.smiexp >= 50))
			M.smithad.Add("Iron HalfPlate Cuirass")
		if((GS3 in M.contents)&&(GH3 in M.contents)&&(M.smirank == 3)&&(M.smiexp >= 100))
			M.smithad.Add("Bronze SolidPlate Cuirass")
		if((GS4 in M.contents)&&(GH4 in M.contents)&&(M.smirank == 4)&&(M.smiexp >= 500))
			M.smithad.Add("Boreal ZincPlate Cuirass")
		if((GS5 in M.contents)&&(GH5 in M.contents)&&(M.smirank == 5)&&(M.smiexp >= 1000))
			M.smithad.Add("Aurelian SteelPlate Cuirass")
	  //Offensive
	    //Landscaper
		if((GS0 in M.contents)&&(GH0 in M.contents)&&(M.smirank == 0)&&(M.smiexp >= 0))"IronPlate Battlegear","BronzePlate Battlegear","IronPlate Battlegear","Omphalos BronzePlate Battlegear","ZincPlate Battlegear","SteelPlate Battlegear"
			M.smithao.Add("IronPlate Battlegear")
		if((GS1 in M.contents)&&(GH1 in M.contents)&&(M.smirank == 1)&&(M.smiexp >= 10))
			M.smithao.Add("BronzePlate Battlegear")
		if((GS2 in M.contents)&&(GH2 in M.contents)&&(M.smirank == 2)&&(M.smiexp >= 50))
			M.smithao.Add("IronPlate Battlegear")
		if((GS3 in M.contents)&&(GH3 in M.contents)&&(M.smirank == 3)&&(M.smiexp >= 100))
			M.smithao.Add("Omphalos BronzePlate Battlegear")
		if((GS4 in M.contents)&&(GH4 in M.contents)&&(M.smirank == 4)&&(M.smiexp >= 500))
			M.smithao.Add("ZincPlate Battlegear")
		if((GS5 in M.contents)&&(GH5 in M.contents)&&(M.smirank == 5)&&(M.smiexp >= 1000))
			M.smithao.Add("SteelPlate Battlegear")*/
	///..()
proc
	smithinglevel()
		set background = 1
		var/mob/players/M
		M = usr
		//var/obj/items/Ingots/bronzebar/BRB = locate() in M.contents
	//tools
		if((M.smirank == 1)&&(M.smiexp >= 5))
			M.msmeexp = 15	//M.brank += 1
			//M << "<b><font color=silver>Your Build Rank went up!"
			//M.smitht.Add("Carving Knife blade")
		//if((M.smirank == 0)&&(M.smiexp >= 0))
			//usr << "<b><font color=silver>Your Build Rank went up!"
		//	M.smithw.Add("Broad Sword")
		if((M.smirank == 2)&&(M.smiexp >= 20))
			M.smirank += 1
			M.msmeexp = 30
			usr << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smitht.Add("Axe blade")
			//M.smith.Add("Armors","Platemail")
		if((M.smirank == 3)&&(M.smiexp >= 50))
			M.smirank += 1
			M.msmeexp = 60
			usr << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smitht.Add("Pickaxe head")

		if((M.smirank == 4)&&(M.smiexp >= 110))
			M.smirank += 1
			M.msmeexp = 120
			usr << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smitht.Add("Shovel blade")

		if((M.smirank == 5)&&(M.smiexp >= 230))
			M.smirank += 1
			M.msmeexp = 150
			usr << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smitht.Add("Hoe blade")

		if((M.smirank == 6)&&(M.smiexp >= 380))
			M.smirank += 1
			M.msmeexp = 300
			usr << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smitht.Add("Sickle blade")
//weapons
		if((M.smirank == 7)&&(M.smiexp >= 680))
			M.smirank += 1
			M.msmeexp = 600
			M << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smithw.Add("Broad Sword")
		//if((M.smirank == 0)&&(M.smiexp >= 0))
			//usr << "<b><font color=silver>Your Build Rank went up!"
		//	M.smithw.Add("Broad Sword")
		if((M.smirank == 8)&&(M.smiexp >= 1280))
			M.smirank += 1
			M.msmeexp = 1200
			usr << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smithw.Add("War Sword")
			//M.smith.Add("Armors","Platemail")
		if((M.smirank == 9)&&(M.smiexp >= 2480))
			M.smirank += 1
			M.msmeexp = 2400
			usr << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smithw.Add("Battle Sword")
		if((M.smirank == 10)&&(M.smiexp >= 4880))
			M.smirank += 1
			M.msmeexp = 4800
			usr << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smithw.Add("Battle Hammer")
		if((M.smirank == 11)&&(M.smiexp >= 9880))
			M.smirank += 1
			M.msmeexp = 9880
			usr << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smithw.Add("Battle Scythe")
		if((M.smirank == 12)&&(M.smiexp >= 19760))
			M.smirank += 1
			M.msmeexp = 19760
			usr << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smithw.Add("Battle Scythe")
		if((M.smirank == 13)&&(M.smiexp >= 39520))
			M.smirank += 1
			M.msmeexp = 39520
			usr << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smithw.Add("Battle Scythe")
		if((M.smirank == 14)&&(M.smiexp >= 79040))
			//M.smirank += 1
			//M.msmeexp = 300
			M.msmiexp = M.smiexp
			usr << "<b><font color=silver>You know all there is to know about Smithing!"
			//M.smithw.Add("War Scythe")
		else
			if(M.smirank >= 14)
				//M << "<b><font color=silver>You begin to wonder what more is there to build... (Building Acuity: [M.brank])"
				M.smirank = 14
	//lamps
		//if((M.smirank >= 0)&&(M.smiexp >= 0))
			//usr << "<b><font color=silver>Your Build Rank went up!"
			//M.smithl.Add("Iron Lamp Head")//roads and floors first then walls and doors then more advanced of the same etc
		//if((M.smirank >= 1)&&(M.smiexp >= 0))
			//usr << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smithl.Add("Copper Lamp Head")
		//if((M.smirank >= 2)&&(M.smiexp >= 5))
			//usr << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smithl.Add("Bronze Lamp Head")
		//if((M.smirank >= 3)&&(M.smiexp >= 10))
			//usr << "<b><font color=silver>Your Smithing Rank went up!"
			//M.smithl.Add("Brass Lamp Head")
	///..()
/*obj
	proc
		Fuel()
			var/mob/players/M = usr
			var/obj/items/tools/Gloves/typi="GV"
			if(M.Doing == 0)
				if(M.Tequipped==1&&typi=="GV") //If user PickAxe is more that or equal to 1
					var/obj/items/Kindling/ueikkindling/J = locate() in M.contents
					if(src.name=="Fueled Fire")
						M<<"The Fire is already Fueled."
						return
					if(J in M.contents&&src.name=="Lit Fire")
						M<<"You toss the [J] into the fire."
						sleep(2)
						J.RemoveFromStack(1)
						src.name="Fueled Fire"
						M<<"You Fuel the Fire."
						//flick("FF",src)
						//src.overlays += icon('dmi/64/fire.dmi',icon_state="FF")
						sleep(1)
						src.name="Fire"
				else
					usr << "You need to put the Gloves on to fuel the fire!"
		Light()
			var/mob/players/M = usr
			var/obj/items/tools/Flint/typi="FL"
			if(M.Doing == 0)
				if(M.Tequipped==1&&typi=="FL") //If user PickAxe is more that or equal to 1
					//var/obj/items/Kindling/ueikkindling/J = locate() in M.contents
					if(src.name=="Lit Fire")
						M<<"The Fire is already Lit."
						return
					if(M.Tequipped==1&&typi=="FL")
						M<<"You Begin lighting the fire."
						sleep(5)
						//J.RemoveFromStack(1)
						src.name="Lit Fire"
						M<<"You Light the Fire."
						//flick("FF",src)
						src.overlays += icon('dmi/64/fire.dmi',icon_state="LF")
						//sleep(5)
						//src.name="Fire"
				else
					usr << "You need to put the Gloves on to fuel the fire!"*/


obj
	proc//Used by fountains, not called by water turfs
		FindJarWF(mob/players/M)
			for(var/obj/items/tools/Containers/Jar/J in M.contents)
				if(J.filled==0)
					return J
		FindVesWF(mob/players/M)
			for(var/obj/items/tools/Containers/Vessel/J in M.contents)
				if(J.name=="Vessel"||J.name=="Half Filled Vessel")
					return J
		Fill()
			set waitfor = 0
			var/mob/players/M = usr
			if(M.Doing == 0)
				if(M.JRequipped==1) //If user PickAxe is more that or equal to 1
					var/obj/items/tools/Containers/Jar/J = locate() in M.contents
					//var/obj/items/tools/Containers/Vessel/J2 = locate() in M.contents
					//if(!J)
					//	return
					if(J.filled==1)
						M<<"The Jar is already Full."
						return
					else if(J.filled==0&&M.JRequipped==1&&J.CType=="Empty")
					//if(M.huntinglevel <= 10) //If user mining skill is less than or equal to 19
						//if(prob(100)) //30% probabilty of something happening
						usr << "You begin to fill the Jar. Test1"
						M.Doing = 1
						J.CType="Water"
						J.volume=25
						J.name = "Filled Jar"
						//var/obj/items/tools/Containers/Jar/R = locate() in M.contents
						J.icon_state="Jarw"
						J.filled=1
						sleep(5) //Delay 3 seconds
						usr << "You finish filling the Jar. Test1" //message to user saying he/she mined something
						M.Doing = 0
						return
				else
					//usr << "You need to hold the Jar to fill it!"
					goto Vessel
					//return

				Vessel
				var/obj/items/tools/Containers/Vessel/J2 = locate() in M.contents
				if(!J2)
					return
				else if(J2.name=="Filled Vessel")
					//M<<"The Vessel is already Full."
					return
				else if(J2.name=="Vessel"&&J2.volume<J2.volumecap&&J2.CType=="Empty")
				//if(M.huntinglevel <= 10) //If user mining skill is less than or equal to 19
					//if(prob(100)) //30% probabilty of something happening
					usr << "You begin to fill the Vessel."
					M.Doing = 1
					//var/obj/items/tools/Containers/Jar/R = locate() in M.contents
					J2.icon_state = "Vesselw"
					J2.name="Filled Vessel"
					J2.CType="Water"
					J2.volume=J2.volumecap
					sleep(5) //Delay 3 seconds
					usr << "You finish filling the Vessel." //message to user saying he/she mined something
					M.Doing = 0
					return
				else if(J2.name=="Half Filled Vessel"&&J2.volume<J2.volumecap&&J2.CType=="Water")
				//if(M.huntinglevel <= 10) //If user mining skill is less than or equal to 19
					//if(prob(100)) //30% probabilty of something happening
					usr << "You begin to fill the Vessel."
					M.Doing = 1
					//var/obj/items/tools/Containers/Jar/R = locate() in M.contents
					J2.icon_state = "Vesselw"
					J2.CType="Water"
					J2.name="Filled Vessel"
					J2.volume=J2.volumecap
					sleep(5) //Delay 3 seconds
					usr << "You finish filling the Vessel." //message to user saying he/she mined something
					M.Doing = 0
					return



turf

	proc//this proc is called by anything that is a turf, such as water, when a user activates the action to fill a container, such as a jar. Called by obj/items/tools/Containers/Jar etc
		FindJarWT(mob/players/M)
			for(var/obj/items/tools/Containers/Jar/J in M.contents)
				locate(J)
				if(J.suffix=="Equipped"&&J.CType=="Empty")
					return J
		FindVesWT(mob/players/M)
			for(var/obj/items/tools/Containers/Vessel/J2 in M.contents)
				//locate(J2)
				if(J2.name=="Vessel"||J2.name=="Half Filled Vessel")
					return J2

		Fill()//working -- checks if user is doing anything, checks if jar is equipped, locates jar in user contents, checks if the jar is already full, if not, then runs
			set waitfor = 0
			var/mob/players/M
			M = usr
			if(M.Doing == 0)
				var/obj/items/tools/Containers/Jar/J = FindJarWT(M)
				var/obj/items/tools/Containers/Vessel/J2 = FindVesWT(M)
				locate(J)
				if(istype(J,/obj/items/tools/Containers/Jar))
					if(J.suffix=="Equipped"&&M.JRequipped==1) //If user Jar is equal to 1

						//var/obj/items/tools/Containers/Vessel/J2 = locate() in M.contents
						//if(!J)
						//	return
						if(J.suffix=="Equipped"&&J.filled==1)
							M<<"The Jar is already Full of Water."
							return
						else if(J.suffix=="Equipped"&&J.filled==0&&M.JRequipped==1&&J.CType=="Empty")//If the jar isn't full and it is equipped and the contents is empty
						//if(M.huntinglevel <= 10) //If user mining skill is less than or equal to 19
							//if(prob(100)) //30% probabilty of something happening
							usr << "You begin to fill the Jar with Water."//Notify the user that they have started filling the jar
							M.Doing = 1
							J.CType="Water"
							J.volume=25
							J.name = "Filled Jar"
							J.icon_state="Jarw"
							J.filled=1
							sleep(5) //Delay
							usr << "You finish filling the Jar with Water." //message to user saying he/she mined something
							M.Doing = 0
							return
				else if(istype(J2,/obj/items/tools/Containers/Vessel))
					goto Vessel

				Vessel
				//var/obj/items/tools/Containers/Vessel/J2 = locate() in M.contents
				if(!J2)
					return
				else if(J2.name=="Filled Vessel")
					//M<<"The Vessel is already Full."
					return
				else if(J2.name=="Vessel"&&J2.volume<J2.volumecap&&J2.CType=="Empty")
				//if(M.huntinglevel <= 10) //If user mining skill is less than or equal to 19
					//if(prob(100)) //30% probabilty of something happening
					usr << "You begin to fill the Vessel."
					M.Doing = 1
					//var/obj/items/tools/Containers/Jar/R = locate() in M.contents
					J2.icon_state = "Vesselw"
					J2.name="Filled Vessel"
					J2.CType="Water"
					J2.volume=J2.volumecap
					sleep(5) //Delay 3 seconds
					usr << "You finish filling the Vessel." //message to user saying he/she mined something
					M.Doing = 0
					return
				else if(J2.name=="Half Filled Vessel"&&J2.volume<J2.volumecap&&J2.CType=="Water")
				//if(M.huntinglevel <= 10) //If user mining skill is less than or equal to 19
					//if(prob(100)) //30% probabilty of something happening
					usr << "You begin to fill the Vessel."
					M.Doing = 1
					//var/obj/items/tools/Containers/Jar/R = locate() in M.contents
					J2.icon_state = "Vesselw"
					J2.CType="Water"
					J2.name="Filled Vessel"
					J2.volume=J2.volumecap
					sleep(5) //Delay 3 seconds
					usr << "You finish filling the Vessel." //message to user saying he/she mined something
					M.Doing = 0
					return
		/*Fuel()
			var/mob/players/M = usr
			var/obj/items/tools/Gloves/typi="GV"
			if(M.Doing == 0)
				if(M.Tequipped==1&&typi=="GV") //If user PickAxe is more that or equal to 1
					var/obj/items/Kindling/ueikkindling/J = locate() in M.contents
					if(src.name=="Fueled Fire")
						M<<"The Fire is already Fueled."
						return
					if(J in M.contents)
						M<<"You toss the [J] into the fire."
						sleep(2)
						J.RemoveFromStack(1)
						src.name="Fueled Fire"
						M<<"You Fuel the Fire."
						flick("FF",src)
						//src.overlays += icon('dmi/64/fire.dmi',icon_state="FF")
						sleep(1)
						src.name="Fire"
				else
					usr << "You need to put the Gloves on to fuel the fire!"*/
		AttackE() //lots of content to fill but not as much as the RPG
			var/mob/players/M = usr
			if(M.hexp >= M.hexpneeded) //if users mining experience is or gos past users max ming experience
				M.huntinglevel+=1 //users mining gos up by 1
				M.hexp=0 //resets user mining experience to 0
				M.hexpneeded+=30 //add 30 to users max mining experience
				world << "\green<b>[M]'s Hunting Levelup!!"
			else //else contrasting the if at the top
				usr << "!" //message to user saying that they need a pick axe to mine
		Fishing() //Name of proc
			set waitfor = 0
			var/mob/players/M = usr
			//var/dice = "1d12"
			//var/R = roll(dice)
			if(M.Doing == 0)
				if(M.FPequipped==1&&get_dist(src,M)<2&&get_dir(M,src)==M.dir) //If user PickAxe is more that or equal to 1
					//M << "You begin to fish."
					M << "You cast your line..."
					if(M.fishinglevel <= 5) //If user mining skill is less than or equal to 19
						//M << "You begin to fish."
						if((prob(25)&&pick(1)))//if(R<=5)
							M << "You begin to fish."
							if(1)
								M.overlays += image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
								//if(M.dir=="North")
								//	M.overlays += /obj/overlay/FPN
								M.Doing = 1
								sleep(40) //Delay 3 seconds
								M.fexp += 25 //user gets 25 mining experience
								Fishing() //go to proc miningcheck
								new/obj/items/Food/sunfish(M)
								usr << "You caught a Sunfish!" //message to user saying he/she mined something
								M.overlays -= image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
								M.Doing = 0
								return
							else
								//usr << "You begin to fish."
								M.overlays += image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
								M.Doing = 1
								sleep(30) //Delay 3 seconds
								M.fexp += 15 //user mining skill gos up by 15
								Fishing() //....
								usr << "You didn't catch anything!" //message to user saying he/she didn't mine anything
								M.overlays -= image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
								M.Doing = 0
								return
						if((prob(50))&&(pick(2)))
							if(2) //30% probabilty of something happening
								//M << "You begin to fish."
								M.overlays += image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
								//if(M.dir=="North")
								//	M.overlays += /obj/overlay/FPN
								M.Doing = 1
								sleep(30) //Delay 3 seconds
								M.fexp += 25 //user gets 25 mining experience
								Fishing() //go to proc miningcheck
								new/obj/items/Food/perch(M)
								usr << "You caught a Perch!" //message to user saying he/she mined something
								M.overlays -= image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
								M.Doing = 0
								return
							else
								//usr << "You begin to fish."
								M.overlays += image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
								M.Doing = 1
								sleep(30) //Delay 3 seconds
								usr << "You didn't catch anything!" //same as before
								M.overlays -= image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
								M.fexp += 15 //user mining experiance increases by 15
								Fishing() //same as before....
								M.Doing = 0
								return
						if((prob(125))&&(pick(3)))
							if(3) //30% probabilty of something happening
								//M << "You begin to fish."
								M.overlays += image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
								//if(M.dir=="North")
								//	M.overlays += /obj/overlay/FPN
								M.Doing = 1
								sleep(30) //Delay 3 seconds
								M.fexp += 25 //user gets 25 mining experience
								Fishing() //go to proc miningcheck
								new/obj/items/Food/carp(M)
								usr << "You caught a Carp!" //message to user saying he/she mined something
								M.overlays -= image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
								M.Doing = 0
								return
							else
								//usr << "You begin to fish."
								M.overlays += image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
								M.Doing = 1
								sleep(30) //Delay 3 seconds
								usr << "You didn't catch anything!" //same as before
								M.overlays -= image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
								M.fexp += 15 //user mining experiance increases by 15
								Fishing() //same as before....
								M.Doing = 0
								return

					/*if(M.fishinglevel >= 6) //if user mining is greater than or equal to 20
						if(prob(20)) //30% probabilty
							usr << "You begin to fish."
							M.overlays += image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.Doing = 1
							sleep(30) //Delay 3 seconds
							M.fexp += 25 //same as before
							new/obj/items/Food/catfish(M)
							usr << "You caught a Catfish!" //same as before
							M.overlays -= image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							Fishing() //same as before
							M.Doing = 0
							return
						else
							usr << "You begin to fish."
							M.overlays += image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.Doing = 1
							sleep(30) //Delay 3 seconds
							usr << "You didn't catch anything!" //same as before
							M.overlays -= image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.fexp += 15 //user mining experiance increases by 15
							Fishing() //same as before....
							M.Doing = 0
							return
						if(prob(20)) //probabilty of 20%
							usr << "You begin to fish."
							M.overlays += image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.Doing = 1
							sleep(30) //Delay 3 seconds
							M.fexp += 40 //user mining experiance increases by 30
							Fishing() //same as before
							new/obj/items/Food/bass(M)
							usr << "You caught a Bass!" //message to user saying he/she mined steel ore
							M.overlays -= image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.Doing = 0
							return
						else
							usr << "You begin to fish."
							M.overlays += image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.Doing = 1
							sleep(30) //Delay 3 seconds
							usr << "You didn't catch anything!" //same as before
							M.overlays -= image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.fexp += 15 //user mining experiance increases by 15
							Fishing() //same as before....
							M.Doing = 0
							return
						if(prob(10)) //probabilty of 20%
							usr << "You begin to fish."
							M.overlays += image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.Doing = 1
							sleep(30) //Delay 3 seconds
							M.fexp += 40 //user mining experiance increases by 30
							Fishing() //same as before
							new/obj/items/Food/trout(M)
							usr << "You caught a Trout!" //message to user saying he/she mined steel ore
							M.overlays -= image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.Doing = 0
							return
						else
							usr << "You begin to fish."
							M.overlays += image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.Doing = 1
							sleep(30) //Delay 3 seconds
							usr << "You didn't catch anything!" //same as before
							M.overlays -= image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.fexp += 15 //user mining experiance increases by 15
							Fishing() //same as before....
							M.Doing = 0
							return
						if(prob(10)) //probabilty of 20%
							usr << "You begin to fish."
							M.overlays += image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.Doing = 1
							sleep(30) //Delay 3 seconds
							M.fexp += 40 //user mining experiance increases by 30
							Fishing() //same as before
							new/obj/items/Food/salmon(M)
							usr << "You caught a Salmon!" //message to user saying he/she mined steel ore
							M.overlays -= image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.Doing = 0
							return
						else
							usr << "You begin to fish."
							M.overlays += image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.Doing = 1
							sleep(30) //Delay 3 seconds
							usr << "You didn't catch anything!" //same as before
							M.overlays -= image('dmi/64/creation.dmi',icon_state="[get_dir(M,src)]")
							M.fexp += 15 //user mining experiance increases by 15
							Fishing() //same as before....
							M.Doing = 0
							return*/
				else if(M.FPequipped==0)
					usr << "Need to hold the Fishing Pole to use it."