
// this file just stores all of the definitions for water types for the map generator
// it's stored here so that you don't need to go into backend.dm if you
// want to make changes to any water stuff

map_generator
	water
		tile = /turf/water

		min_size = 3
		max_size = 6

obj
	border
		water
			ramp_chance = 0
			icon = 'dmi/64/abeach.dmi'
			name = "Shore"
			//SetBSeason()
			//icon_state = "beach"
			New()
				..()
				//new /obj/soundmob/SFX/river(src)
				//soundmob(src, 20, 'snd/creek.ogg', TRUE, 20, 40, TRUE)
		//vis_flags = VIS_HIDE
		//layer = 999
			Del()
				//world << sound(src)
				..()
			proc/SetBSeason()
				if(global.season=="Winter")
					density=0
					icon = 'dmi/64/awbeach.dmi'
					//name = "Shore"
					//mouse_opacity=1
					layer = 2
					verbs -= /turf/water/verb/Fill_
					verbs -= /turf/water/verb/Fish
					verbs -= /turf/water/verb/Quench
				else if(global.season!="Winter")
					density = 1
					icon = 'dmi/64/abeach.dmi'
					//mouse_opacity=0
					//name = "Water"
					verbs += /turf/water/verb/Fill_
					verbs += /turf/water/verb/Fish
					verbs += /turf/water/verb/Quench
turf
	water
		icon = 'dmi/64/gen.dmi'
		icon_state = "water"
		border_type = /obj/border/water
		density = TRUE
		spawn_resources = FALSE
		plane = REFLECTION_PLANE
		
		var
			water_type = "fresh"  // Fresh water by default (can be overridden by biome)
			mob/players/M

		sfxwat = list ( ///obj/soundmob/SFX/river
						)//water sound effect

		SetElevation(n)
			elevation = -5

		New()
			..()
			soundmob(src, 20, 'snd/creek.ogg', TRUE, 20, null, TRUE)
	//vis_flags = VIS_HIDE
	//layer = 999
		Del()
			world << sound(src)
			..()
			//SpawnSoundEffectsWAT()
		//	soundmob(src, 20, 'snd/creek.ogg', TRUE, 0, 50)
		DblClick()
			set popup_menu = 1
			M = usr
			if (!(src in range(1, M))) return
			if(M.stamina==M.MAXstamina)
				M << "You aren't thirsty right now."
				return
			else if(M.stamina<M.MAXstamina)
				usingmana(M,200)
				sleep(1)
				return
		UseObject(mob/user)
			// E-key fishing handler
			if(user in range(1, src))
				if(!istype(user, /mob/players))
					return 0
				var/mob/players/M = user
				// Check if player has fishing pole equipped
				if(!M.FPequipped)
					M << "<red>You need a Fishing Pole equipped to fish."
					return 1
				// Trigger fishing minigame
				Fishing(M)
				return 1
			return 0
		verb //...
			Fish() //...
				set popup_menu = 1
				set src in oview(1) //...
				//set hidden = 1
				//set category = "Commands"
				//usr << "You cast your line..."
				Fishing(M) //calls the fishing proc might need some checks to prevent double actions
			/*Drink()
				//set category = "Commands"
				set src in oview(1)
				usingmana(src,100)*/
			Fill_()
				set waitfor = 0
				set popup_menu = 1
				set src in oview(1)
				var/mob/players/M
				M = usr

				//set category = "Commands"
				//if(M.JRequipped==1)
				//if(J.CType=="")
				//	J.CType=0
				if(Fill(M))//Need to switch all of these fills over to the new 'detect container and fill volume' system
					//var/obj/items/tools/Containers/Jar/J = FindJar(M)
					var/obj/items/tools/Containers/Jar/J = FindJar(M)
					var/obj/items/tools/Containers/Vessel/J2 = FindVes(M)
					//if(!J)
						//return
					if(J.suffix=="Equipped"&&M.JRequipped==1&&J.filled==0)
						M<<"You begin filling the Jar."
						sleep(2)

						J.icon_state = "Jarw"
						J.name="Filled Jar"
						J.filled=1
						J.CType="Water"
						J.volume=25
						sleep(1)
						//usr << "Ctype[J.CType] & Volume [J.volume]"//call(/obj/items/tools/Containers/Jar/proc/descr)(J)
						M<<"You Filled the Jar."
						return
					else if(J.filled==1&&M.JRequipped==0)
						M<<"Need to hold an empty Jar to fill it."
						return
					else if(J.filled==0&&M.JRequipped==0)
						M<<"Need to hold an empty Jar to fill it."
						return



					else
						goto Vessel
						//return
					Vessel
					if(!J2)
						return
					else if(J2.name=="Vessel"&&J2.volume<J2.volumecap&&J2.CType=="Empty")
						M<<"You begin filling the Vessel with Water."
						sleep(2)
						J2.overlays += /obj/vliquid
						J2.name="Filled Vessel"
						J2.CType="Water"
						J2.volume=50
						sleep(1)
						M<<"You Filled the Vessel full of Water."
						return
					else if(J2.name=="Half Filled Vessel"&&J2.volume<J2.volumecap&&J2.CType=="Water")
						M<<"You begin filling the Vessel with Water."
						sleep(2)
						J2.overlays += /obj/vliquid
						J2.name="Filled Vessel"
						J2.CType="Water"
						J2.volume=50
						sleep(1)
						M<<"You Filled the Vessel full of Water."
						return
					else if(J2.name=="Filled Vessel")
						M<<"This Vessel is already full!"
						return
			/*Hydrate()
				set src in oview(1)
				//set category = "Commands"
				usingmana(M,100)*/
			Quench()//working confirmed -- could probably be expanded more
				set src in view()
				set category=null
			//set hidden = 1
				set popup_menu=1
				var/mob/players/M
				M = usr
				//var/mob/players/J = locate() in oview(1,src)//call(/obj/items/tools/Containers/QuenchBox/proc/FindQB)(M)
				//var/obj/items/tools/Containers/Quench Box/J2 = locate() in view(1,M)
				//if(J)
				if(M.GVequipped==1)//testing
				//if(M in oview(1,src))
					//M << "[J] [J.name] check Filled Quench Box"
					Qench()
					//return
				else
					//M << "Stand near to the water to quench."
					//return
						//M << "src[src] CType[CType] src.CType[src.CType]"
				//else
					M << "Need to use gloves."
					return
				//else return
				//if(J2)
					//M << "Quench Box"
					//call(/obj/items/tools/Containers/Quench Box/proc/Qench)(src)

		proc/FindHMf(mob/players/M)
			for(var/obj/items/Crafting/Created/HammerHead/J in M.contents)//Hammer Head
				locate(J)
				if(J:needsquenched==1)
					return J
		proc/FindCKf(mob/players/M)
			for(var/obj/items/Crafting/Created/CKnifeblade/J1 in M.contents)//Carving Knife
				locate(J1)
				if(J1:needsquenched==1)
					return J1
		proc/FindSBf(mob/players/M)
			for(var/obj/items/Crafting/Created/SickleBlade/J2 in M.contents)//Sickle
				locate(J2)
				if(J2:needsquenched==1)
					return J2
		proc/FindTWBf(mob/players/M)
			for(var/obj/items/Crafting/Created/TrowelBlade/J3 in M.contents)//Trowel
				locate(J3)
				if(J3:needsquenched==1)
					return J3
		proc/FindCBf(mob/players/M)
			for(var/obj/items/Crafting/Created/ChiselBlade/J4 in M.contents)//Chisel
				locate(J4)
				if(J4:needsquenched==1)
					return J4
		proc/FindAHf(mob/players/M)
			for(var/obj/items/Crafting/Created/AxeHead/J5 in M.contents)//Axe
				locate(J5)
				if(J5:needsquenched==1)
					return J5
		proc/FindFBf(mob/players/M)
			for(var/obj/items/Crafting/Created/FileBlade/J6 in M.contents)//File
				locate(J6)
				if(J6:needsquenched==1)
					return J6
		proc/FindSHf(mob/players/M)
			for(var/obj/items/Crafting/Created/ShovelHead/J7 in M.contents)//Shovel
				locate(J7)
				if(J7:needsquenched==1)
					return J7
		proc/FindHOf(mob/players/M)
			for(var/obj/items/Crafting/Created/HoeBlade/J8 in M.contents)//Hoe
				locate(J8)
				if(J8:needsquenched==1)
					return J8
		proc/FindPXf(mob/players/M)
			for(var/obj/items/Crafting/Created/PickaxeHead/J9 in M.contents)//Pickaxe
				locate(J9)
				if(J9:needsquenched==1)
					return J9
		proc/FindSWf(mob/players/M)
			for(var/obj/items/Crafting/Created/SawBlade/J10 in M.contents)//Saw
				locate(J10)
				if(J10:needsquenched==1)
					return J10
//Weapon Check   "Broad Sword","War Sword","Battle Sword","Long Sword","War Maul","Battle Hammer","War Axe","Battle Axe","Battle Scythe","War Scythe"

		proc/FindBSf(mob/players/M)
			for(var/obj/items/Crafting/Created/Broadswordblade/J11 in M.contents)//Broad Sword
				locate(J11)
				if(J11:needsquenched==1)
					return J11
		proc/FindWSf(mob/players/M)
			for(var/obj/items/Crafting/Created/Warswordblade/J12 in M.contents)//War Sword
				locate(J12)
				if(J12:needsquenched==1)
					return J12
		proc/FindBSWf(mob/players/M)
			for(var/obj/items/Crafting/Created/Battleswordblade/J13 in M.contents)//Battle Sword
				locate(J13)
				if(J13:needsquenched==1)
					return J13
		proc/FindLSf(mob/players/M)
			for(var/obj/items/Crafting/Created/Longswordblade/J14 in M.contents)//Long Sword
				locate(J14)
				if(J14:needsquenched==1)
					return J14
		proc/FindWMf(mob/players/M)
			for(var/obj/items/Crafting/Created/Warmaulhead/J15 in M.contents)//War Maul
				locate(J15)
				if(J15:needsquenched==1)
					return J15
		proc/FindBHf(mob/players/M)
			for(var/obj/items/Crafting/Created/Battlehammersledge/J16 in M.contents)//Battle Hammer
				locate(J16)
				if(J16:needsquenched==1)
					return J16
		proc/FindWXf(mob/players/M)
			for(var/obj/items/Crafting/Created/Waraxeblade/J17 in M.contents)//War Axe
				locate(J17)
				if(J17:needsquenched==1)
					return J17
		proc/FindBXf(mob/players/M)
			for(var/obj/items/Crafting/Created/Battleaxeblade/J18 in M.contents)//Battle Axe
				locate(J18)
				if(J18:needsquenched==1)
					return J18
		proc/FindWSYf(mob/players/M)
			for(var/obj/items/Crafting/Created/Warscytheblade/J19 in M.contents)//War Scythe
				locate(J19)
				if(J19:needsquenched==1)
					return J19
		proc/FindBSYf(mob/players/M)
			for(var/obj/items/Crafting/Created/Battlescytheblade/J20 in M.contents)//Battle Scythe
				locate(J20)
				if(J20:needsquenched==1)
					return J20

//Lamp

		proc/FindILf(mob/players/M)
			for(var/obj/items/Crafting/Created/IronLampHead/J21 in M.contents)//Iron Lamp Head
				locate(J21)
				if(J21:needsquenched==1)
					return J21
		proc/FindCLf(mob/players/M)
			for(var/obj/items/Crafting/Created/CopperLampHead/J22 in M.contents)//Copper Lamp Head
				locate(J22)
				if(J22:needsquenched==1)
					return J22
		proc/FindBRLf(mob/players/M)
			for(var/obj/items/Crafting/Created/BronzeLampHead/J23 in M.contents)//Bronze Lamp Head
				locate(J23)
				if(J23:needsquenched==1)
					return J23
		proc/FindBSLf(mob/players/M)
			for(var/obj/items/Crafting/Created/BrassLampHead/J24 in M.contents)//Brass Lamp Head
				locate(J24)
				if(J24:needsquenched==1)
					return J24
		proc/FindSLf(mob/players/M)
			for(var/obj/items/Crafting/Created/SteelLampHead/J25 in M.contents)//Steel Lamp Head
				locate(J25)
				if(J25:needsquenched==1)
					return J25

		proc/FindAVf(mob/players/M)
			for(var/obj/items/Crafting/Created/AnvilHead/J26 in M.contents)//Anvil Head
				locate(J26)
				if(J26:needsquenched==1)
					return J26



		proc/Qench()//working J312021
			set src in usr
			var/mob/players/M
			M = usr
			//var/obj/items/Crafting/Created/Whetstone/S = locate() in M.contents
//Tool Call
			var/obj/items/Crafting/Created/HammerHead/J = call(/turf/water/proc/FindHMf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/CKnifeblade/J1 = call(/turf/water/proc/FindCKf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/SickleBlade/J2 = call(/turf/water/proc/FindSBf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/TrowelBlade/J3 = call(/turf/water/proc/FindTWBf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/ChiselBlade/J4 = call(/turf/water/proc/FindCBf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/AxeHead/J5 = call(/turf/water/proc/FindAHf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/FileBlade/J6 = call(/turf/water/proc/FindFBf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/ShovelHead/J7 = call(/turf/water/proc/FindSHf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/HoeBlade/J8 = call(/turf/water/proc/FindHOf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/PickaxeHead/J9 = call(/turf/water/proc/FindPXf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/SawBlade/J10 = call(/turf/water/proc/FindSWf)(M)//locate() in M.contents
//Weapon Call

			var/obj/items/Crafting/Created/Broadswordblade/J11 = call(/turf/water/proc/FindBSf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/Warswordblade/J12 = call(/turf/water/proc/FindWSf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/Battleswordblade/J13 = call(/turf/water/proc/FindBSWf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/Longswordblade/J14 = call(/turf/water/proc/FindLSf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/Warmaulhead/J15 = call(/turf/water/proc/FindWMf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/Battlehammersledge/J16 = call(/turf/water/proc/FindBHf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/Waraxeblade/J17 = call(/turf/water/proc/FindWXf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/Battleaxeblade/J18 = call(/turf/water/proc/FindBXf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/Warscytheblade/J19 = call(/turf/water/proc/FindWSYf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/Battlescytheblade/J20 = call(/turf/water/proc/FindBSYf)(M)//locate() in M.contents

//Lamp Call

			var/obj/items/Crafting/Created/IronLampHead/J21 = call(/turf/water/proc/FindILf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/CopperLampHead/J22 = call(/turf/water/proc/FindCLf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/BronzeLampHead/J23 = call(/turf/water/proc/FindBRLf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/BrassLampHead/J24 = call(/turf/water/proc/FindBSLf)(M)//locate() in M.contents
			var/obj/items/Crafting/Created/SteelLampHead/J25 = call(/turf/water/proc/FindSLf)(M)//locate() in M.contents
//Misc Parts
			var/obj/items/Crafting/Created/AnvilHead/J26 = call(/turf/water/proc/FindAVf)(M)//locate() in M.contents

			//if(src:CType=="Empty")
				//M << "Need to fill the Quench Box to Quench!"
				//return
			//M << "work"
			//if(M in oview(1,src))
			if(J&&J.Tname!="Cool")
				if(J.Tname=="Hot")
					M<<"You submerge the [J.Tname] [J] into the water."
					J.needsquenched=0
					sleep(3)
					J.Tname="Cool"
					//insert sfx and flick an animation
					M<<"You have quenched [J]! Test it for hardness with a File."
					return
				else if(J.Tname=="Warm")
					M<<"You submerge the [J.Tname] [J] into the water."
					J.needsquenched=1
					sleep(3)
					J.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J] wasn't hot enough."
					return
			//else if(!J)
				//return
				else if(J.Tname=="Cool")
					M << "Heat the [J] before quenching."
					return
			if(J1&&J1.Tname!="Cool")
				if(J1.Tname=="Hot")
					M<<"You submerge the [J1.Tname] [J1] into the water."
					J1.needsquenched=0
					sleep(3)
					J1.Tname="Cool"
					M<<"You have quenched [J1]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J1.Tname=="Warm")
					M<<"You submerge the [J1.Tname] [J1] into the water."
					J1.needsquenched=1
					sleep(3)
					J1.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J1] wasn't hot enough."
					return
			//else if(!J1)
				//return
				else if(J1.Tname=="Cool")
					M << "Heat the [J1] before quenching."
					return
			if(J2&&J2.Tname!="Cool")
				if(J2.Tname=="Hot")
					M<<"You submerge the [J2.Tname] [J2] into the water."
					J2.needsquenched=0
					sleep(3)
					J2.Tname="Cool"
					M<<"You have quenched [J2]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J2.Tname=="Warm")
					M<<"You submerge the [J2.Tname] [J2] into the water."
					J2.needsquenched=1
					sleep(3)
					J2.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J2] wasn't hot enough."
					return
			//else if(!J2)
				//return
				else if(J2.Tname=="Cool")
					M << "Heat the [J2] before quenching."
					return
			if(J3&&J3.Tname!="Cool")
				if(J3.Tname=="Hot")
					M<<"You submerge the [J3.Tname] [J3] into the water."
					J3.needsquenched=0
					sleep(3)
					J3.Tname="Cool"
					M<<"You have quenched [J3]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J3.Tname=="Warm")
					M<<"You submerge the [J3.Tname] [J3] into the water."
					J3.needsquenched=1
					sleep(3)
					J3.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J3] wasn't hot enough."
					return
			//else if(!J3)
				//return
				else if(J3.Tname=="Cool")
					M << "Heat the [J3] before quenching."
					return
			if(J4&&J4.Tname!="Cool")
				if(J4.Tname=="Hot")
					M<<"You submerge the [J4.Tname] [J4] into the water."
					J4.needsquenched=0
					sleep(3)
					J4.Tname="Cool"
					M<<"You have quenched [J4]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J4.Tname=="Warm")
					M<<"You submerge the [J4.Tname] [J4] into the water."
					J4.needsquenched=1
					sleep(3)
					J4.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J4] wasn't hot enough."
					return
			//else if(!J4)
				//return
				else if(J4.Tname=="Cool")
					M << "Heat the [J4] before quenching."
					return
			if(J5&&J5.Tname!="Cool")
				if(J5.Tname=="Hot")
					M<<"You submerge the [J5.Tname] [J5] into the water."
					J5.needsquenched=0
					sleep(3)
					J5.Tname="Cool"
					M<<"You have quenched [J5]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J5.Tname=="Warm")
					M<<"You submerge the [J5.Tname] [J5] into the water."
					J5.needsquenched=1
					sleep(3)
					J5.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J5] wasn't hot enough."
					return
			//else if(!J5)
				//return
				else if(J5.Tname=="Cool")
					M << "Heat the [J5] before quenching."
					return
			if(J6&&J6.Tname!="Cool")
				if(J6.Tname=="Hot")
					M<<"You submerge the [J6.Tname] [J6] into the water."
					J6.needsquenched=0
					sleep(3)
					J6.Tname="Cool"
					M<<"You have quenched [J6]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J6.Tname=="Warm")
					M<<"You submerge the [J6.Tname] [J6] into the water."
					J6.needsquenched=1
					sleep(3)
					J6.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J6] wasn't hot enough."
					return
			//else if(!J6)
				//return
				else if(J6.Tname=="Cool")
					M << "Heat the [J6] before quenching."
					return
			if(J7&&J7.Tname!="Cool")
				if(J7.Tname=="Hot")
					M<<"You submerge the [J7.Tname] [J7] into the water."
					J7.needsquenched=0
					sleep(3)
					J7.Tname="Cool"
					M<<"You have quenched [J7]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J7.Tname=="Warm")
					M<<"You submerge the [J7.Tname] [J7] into the water."
					J7.needsquenched=1
					sleep(3)
					J7.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J7] wasn't hot enough."
					return
			//else if(!J7)
				//return
				else if(J7.Tname=="Cool")
					M << "Heat the [J7] before quenching."
					return
			if(J8&&J8.Tname!="Cool")
				if(J8.Tname=="Hot")
					M<<"You submerge the [J8.Tname] [J8] into the water."
					J8.needsquenched=0
					sleep(3)
					J8.Tname="Cool"
					M<<"You have quenched [J8]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J8.Tname=="Warm")
					M<<"You submerge the [J8.Tname] [J8] into the water."
					J8.needsquenched=1
					sleep(3)
					J8.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J8] wasn't hot enough."
					return
			//else if(!J8)
				//return
				else if(J8.Tname=="Cool")
					M << "Heat the [J8] before quenching."
					return
			if(J9&&J9.Tname!="Cool")
				if(J9.Tname=="Hot")
					M<<"You submerge the [J9.Tname] [J9] into the water."
					J9.needsquenched=0
					sleep(3)
					J9.Tname="Cool"
					M<<"You have quenched [J9]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J9.Tname=="Warm")
					M<<"You submerge the [J9.Tname] [J9] into the water."
					J9.needsquenched=1
					sleep(3)
					J9.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J9] wasn't hot enough."
					return
			//else if(!J9)
				//return
				else if(J9.Tname=="Cool")
					M << "Heat the [J9] before quenching."
					return
			if(J10&&J10.Tname!="Cool")
				if(J10.Tname=="Hot")
					M<<"You submerge the [J10.Tname] [J10] into the water."
					J10.needsquenched=0
					sleep(3)
					J10.Tname="Cool"
					M<<"You have quenched [J10]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J10.Tname=="Warm")
					M<<"You submerge the [J10.Tname] [J10] into the water."
					J10.needsquenched=1
					sleep(3)
					J10.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J10] wasn't hot enough."
					return
			//else if(!J10)
				//return
				else if(J10.Tname=="Cool")
					M << "Heat the [J10] before quenching."
					return

//Water Weapon part Quench Process
			if(J11&&J11.Tname!="Cool")
				if(J11.Tname=="Hot")
					M<<"You submerge the [J11.Tname] [J11] into the water."
					J11.needsquenched=0
					sleep(3)
					J11.Tname="Cool"
					M<<"You have quenched [J11]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J11.Tname=="Warm")
					M<<"You submerge the [J11.Tname] [J11] into the water."
					J11.needsquenched=1
					sleep(3)
					J11.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J11] wasn't hot enough."
					return
			//else if(!J11)
				//return
				else if(J11.Tname=="Cool")
					M << "Heat the [J11] before quenching."
					return
			if(J12&&J12.Tname!="Cool")
				if(J12.Tname=="Hot")
					M<<"You submerge the [J12.Tname] [J12] into the water."
					J12.needsquenched=0
					sleep(3)
					J12.Tname="Cool"
					M<<"You have quenched [J12]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J12.Tname=="Warm")
					M<<"You submerge the [J12.Tname] [J12] into the water."
					J12.needsquenched=1
					sleep(3)
					J12.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J12] wasn't hot enough."
					return
			//else if(!J12)
				//return
				else if(J12.Tname=="Cool")
					M << "Heat the [J12] before quenching."
					return
			if(J13&&J13.Tname!="Cool")
				if(J13.Tname=="Hot")
					M<<"You submerge the [J13.Tname] [J13] into the water."
					J13.needsquenched=0
					sleep(3)
					J13.Tname="Cool"
					M<<"You have quenched [J13]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J13.Tname=="Warm")
					M<<"You submerge the [J13.Tname] [J13] into the water."
					J13.needsquenched=1
					sleep(3)
					J13.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J13] wasn't hot enough."
					return
			//else if(!J13)
				//return
				else if(J13.Tname=="Cool")
					M << "Heat the [J13] before quenching."
					return
			if(J14&&J14.Tname!="Cool")
				if(J14.Tname=="Hot")
					M<<"You submerge the [J14.Tname] [J14] into the water."
					J14.needsquenched=0
					sleep(3)
					J14.Tname="Cool"
					M<<"You have quenched [J14]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J14.Tname=="Warm")
					M<<"You submerge the [J14.Tname] [J14] into the water."
					J14.needsquenched=1
					sleep(3)
					J14.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J14] wasn't hot enough."
					return
			//else if(!J14)
				//return
				else if(J14.Tname=="Cool")
					M << "Heat the [J14] before quenching."
					return
			if(J15&&J15.Tname!="Cool")
				if(J15.Tname=="Hot")
					M<<"You submerge the [J15.Tname] [J15] into the water."
					J15.needsquenched=0
					sleep(3)
					J15.Tname="Cool"
					M<<"You have quenched [J15]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J15.Tname=="Warm")
					M<<"You submerge the [J15.Tname] [J15] into the water."
					J15.needsquenched=1
					sleep(3)
					J15.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J15] wasn't hot enough."
					return
			//else if(!J15)
				//return
				else if(J15.Tname=="Cool")
					M << "Heat the [J15] before quenching."
					return
			if(J16&&J16.Tname!="Cool")
				if(J16.Tname=="Hot")
					M<<"You submerge the [J16.Tname] [J16] into the water."
					J16.needsquenched=0
					sleep(3)
					J16.Tname="Cool"
					M<<"You have quenched [J16]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J16.Tname=="Warm")
					M<<"You submerge the [J16.Tname] [J16] into the water."
					J16.needsquenched=1
					sleep(3)
					J16.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J16] wasn't hot enough."
					return
			//else if(!J16)
				//return
				else if(J16.Tname=="Cool")
					M << "Heat the [J16] before quenching."
					return
			if(J17&&J17.Tname!="Cool")
				if(J17.Tname=="Hot")
					M<<"You submerge the [J17.Tname] [J17] into the water."
					J17.needsquenched=0
					sleep(3)
					J17.Tname="Cool"
					M<<"You have quenched [J17]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J17.Tname=="Warm")
					M<<"You submerge the [J17.Tname] [J17] into the water."
					J17.needsquenched=1
					sleep(3)
					J17.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J17] wasn't hot enough."
					return
			//else if(!J17)
				//return
				else if(J17.Tname=="Cool")
					M << "Heat the [J17] before quenching."
					return
			if(J18&&J18.Tname!="Cool")
				if(J18.Tname=="Hot")
					M<<"You submerge the [J18.Tname] [J18] into the water."
					J18.needsquenched=0
					sleep(3)
					J18.Tname="Cool"
					M<<"You have quenched [J18]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J18.Tname=="Warm")
					M<<"You submerge the [J18.Tname] [J18] into the water."
					J18.needsquenched=1
					sleep(3)
					J18.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J18] wasn't hot enough."
					return
			//else if(!J18)
				//return
				else if(J18.Tname=="Cool")
					M << "Heat the [J18] before quenching."
					return
			if(J19&&J19.Tname!="Cool")
				if(J19.Tname=="Hot")
					M<<"You submerge the [J19.Tname] [J19] into the water."
					J19.needsquenched=0
					sleep(3)
					J19.Tname="Cool"
					M<<"You have quenched [J19]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J19.Tname=="Warm")
					M<<"You submerge the [J19.Tname] [J19] into the water."
					J19.needsquenched=1
					sleep(3)
					J19.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J19] wasn't hot enough."
					return
			//else if(!J19)
				//return
				else if(J19.Tname=="Cool")
					M << "Heat the [J19] before quenching."
					return
			if(J20&&J20.Tname!="Cool")
				if(J20.Tname=="Hot")
					M<<"You submerge the [J20.Tname] [J20] into the water."
					J20.needsquenched=0
					sleep(3)
					J20.Tname="Cool"
					M<<"You have quenched [J20]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J20.Tname=="Warm")
					M<<"You submerge the [J20.Tname] [J20] into the water."
					J20.needsquenched=1
					sleep(3)
					J20.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J20] wasn't hot enough."
					return
			//else if(!J20)
				//return
				else if(J20.Tname=="Cool")
					M << "Heat the [J20] before quenching."
					return


//Water Lamp part Quench Process
			if(J21&&J21.Tname!="Cool")
				if(J21.Tname=="Hot")
					M<<"You submerge the [J21.Tname] [J21] into the water."
					J21.needsquenched=0
					sleep(3)
					J21.Tname="Cool"
					M<<"You have quenched [J21]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J21.Tname=="Warm")
					M<<"You submerge the [J21.Tname] [J21] into the water."
					J21.needsquenched=1
					sleep(3)
					J21.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J21] wasn't hot enough."
					return
			//else if(!J21)
				//return
				else if(J21.Tname=="Cool")
					M << "Heat the [J21] before quenching."
					return
			if(J22&&J22.Tname!="Cool")
				if(J22.Tname=="Hot")
					M<<"You submerge the [J22.Tname] [J22] into the water."
					J22.needsquenched=0
					sleep(3)
					J22.Tname="Cool"
					M<<"You have quenched [J22]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J22.Tname=="Warm")
					M<<"You submerge the [J22.Tname] [J22] into the water."
					J22.needsquenched=1
					sleep(3)
					J22.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J22] wasn't hot enough."
					return
			//else if(!J22)
				//return
				else if(J22.Tname=="Cool")
					M << "Heat the [J22] before quenching."
					return
			if(J23&&J23.Tname!="Cool")
				if(J23.Tname=="Hot")
					M<<"You submerge the [J23.Tname] [J23] into the water."
					J23.needsquenched=0
					sleep(3)
					J23.Tname="Cool"
					M<<"You have quenched [J23]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J23.Tname=="Warm")
					M<<"You submerge the [J23.Tname] [J23] into the water."
					J23.needsquenched=1
					sleep(3)
					J23.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J23] wasn't hot enough."
					return
			//else if(!J23)
				//return
				else if(J23.Tname=="Cool")
					M << "Heat the [J23] before quenching."
					return
			if(J24&&J24.Tname!="Cool")
				if(J24.Tname=="Hot")
					M<<"You submerge the [J24.Tname] [J24] into the water."
					J24.needsquenched=0
					sleep(3)
					J24.Tname="Cool"
					M<<"You have quenched [J24]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J24.Tname=="Warm")
					M<<"You submerge the [J24.Tname] [J24] into the water."
					J24.needsquenched=1
					sleep(3)
					J24.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J24] wasn't hot enough."
					return
			//else if(!J24)
				//return
				else if(J24.Tname=="Cool")
					M << "Heat the [J24] before quenching."
					return
			if(J25&&J25.Tname!="Cool")
				if(J25.Tname=="Hot")
					M<<"You submerge the [J25.Tname] [J25] into the water."
					J25.needsquenched=0
					sleep(3)
					J25.Tname="Cool"
					M<<"You have quenched [J25]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J25.Tname=="Warm")
					M<<"You submerge the [J25.Tname] [J25] into the water."
					J25.needsquenched=1
					sleep(3)
					J25.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J25] wasn't hot enough."
					return
			//else if(!J25)
				//return
				else if(J25.Tname=="Cool")
					M << "Heat the [J25] before quenching."
					return
//Misc Parts
			if(J26&&J26.Tname!="Cool")
				if(J26.Tname=="Hot")
					M<<"You submerge the [J26.Tname] [J26] into the water."
					J26.needsquenched=0
					sleep(3)
					J26.Tname="Cool"
					M<<"You have quenched [J26]! Test it for hardness with a File."
					//insert sfx and flick an animation
					return
				else if(J26.Tname=="Warm")
					M<<"You submerge the [J26.Tname] [J26] into the water."
					J26.needsquenched=1
					sleep(3)
					J26.Tname="Cool"
					//insert sfx and flick an animation
					M<<"The quench failed, [J26] wasn't hot enough."
					return
			//else if(!J26)
				//return
				else if(J26.Tname=="Cool")
					M << "Heat the [J26] before quenching."
					return

		proc/SetWSeason()
			if(global.season=="Winter")
				density=0
				icon_state = "ice"
				layer = 2
				//mouse_opacity=1
				verbs -= /turf/water/verb/Fill_
				verbs -= /turf/water/verb/Fish
				verbs -= /turf/water/verb/Quench
				name = "Ice"
			else if(global.season!="Winter")
				density = 1
				icon_state = "water"
				//mouse_opacity=0
				verbs += /turf/water/verb/Fill_
				verbs += /turf/water/verb/Fish
				verbs += /turf/water/verb/Quench
				name = "Water"


		proc/FindJar(mob/players/M)
			for(var/obj/items/tools/Containers/Jar/J in M.contents)
				if(J.suffix=="Equipped"&&J.CType=="Empty")
					return J

		proc/FindVes(mob/players/M)
			for(var/obj/items/tools/Containers/Vessel/J in M.contents)
				if(J.CType=="Empty")
					return J
		proc/usingmana(var/turf/Water/J,amount)
			set waitfor = 0
			var/mob/players/M
			M = usr
			if(global.season=="Winter")
				M << "This water is frozen solid."
				sleep(5)
				return

			if (amount > (M.MAXstamina-M.stamina))
				amount = (M.MAXstamina-M.stamina)
			usr << "You Begin drinking the Water..."
			sleep(2)
			M.ConsumeFoodItem("fresh water", 0, 300, 0, amount)
			sleep(2)