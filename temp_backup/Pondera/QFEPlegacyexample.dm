//Quenching, Filing, Etching, Polishing, Folding, Sharpening?
















obj
	items
		tools
			Whetstone //name of object
				icon_state = "Whetstone" //icon state of object
				typi = "WS"
				strreq = 1
				name = "Whetstone"
				//description = "<font color = #8C7853><center><b>Pyrite:</b><br>0 Damage"
				Worth = 0
				//amount = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 0
				DamageMin = 0
				DamageMax = 0
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br> Utilized for sharpening tool parts."

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

//Tool Parts "Carving Knife blade","Hammer head","File blade","Axe blade","Pickaxe head","Shovel blade","Hoe blade","Saw blade","Sickle blade","Chisel Blade","Trowel blade"
				proc/FindHMf(mob/players/M)
					for(var/obj/items/Crafting/Created/HammerHead/J in M.contents)//Hammer Head
						locate(J)
						if(J:needssharpening==1)
							return J
				proc/FindCKf(mob/players/M)
					for(var/obj/items/Crafting/Created/CKnifeblade/J1 in M.contents)//Carving Knife
						locate(J1)
						if(J1:needssharpening==1)
							return J1
				proc/FindSBf(mob/players/M)
					for(var/obj/items/Crafting/Created/SickleBlade/J2 in M.contents)//Sickle
						locate(J2)
						if(J2:needssharpening==1)
							return J2
				proc/FindTWBf(mob/players/M)
					for(var/obj/items/Crafting/Created/TrowelBlade/J3 in M.contents)//Trowel
						locate(J3)
						if(J3:needssharpening==1)
							return J3
				proc/FindCBf(mob/players/M)
					for(var/obj/items/Crafting/Created/ChiselBlade/J4 in M.contents)//Chisel
						locate(J4)
						if(J4:needssharpening==1)
							return J4
				proc/FindAHf(mob/players/M)
					for(var/obj/items/Crafting/Created/AxeHead/J5 in M.contents)//Axe
						locate(J5)
						if(J5:needssharpening==1)
							return J5
				proc/FindFBf(mob/players/M)
					for(var/obj/items/Crafting/Created/FileBlade/J6 in M.contents)//File
						locate(J6)
						if(J6:needssharpening==1)
							return J6
				proc/FindSHf(mob/players/M)
					for(var/obj/items/Crafting/Created/ShovelHead/J7 in M.contents)//Shovel
						locate(J7)
						if(J7:needssharpening==1)
							return J7
				proc/FindHOf(mob/players/M)
					for(var/obj/items/Crafting/Created/HoeBlade/J8 in M.contents)//Hoe
						locate(J8)
						if(J8:needssharpening==1)
							return J8
				proc/FindPXf(mob/players/M)
					for(var/obj/items/Crafting/Created/PickaxeHead/J9 in M.contents)//Pickaxe
						locate(J9)
						if(J9:needssharpening==1)
							return J9
				proc/FindSWf(mob/players/M)
					for(var/obj/items/Crafting/Created/SawBlade/J10 in M.contents)//Saw
						locate(J10)
						if(J10:needssharpening==1)
							return J10
//Weapon Check   "Broad Sword","War Sword","Battle Sword","Long Sword","War Maul","Battle Hammer","War Axe","Battle Axe","Battle Scythe","War Scythe"

				proc/FindBSf(mob/players/M)
					for(var/obj/items/Crafting/Created/Broadswordblade/J11 in M.contents)//Broad Sword
						locate(J11)
						if(J11:needssharpening==1)
							return J11
				proc/FindWSf(mob/players/M)
					for(var/obj/items/Crafting/Created/Warswordblade/J12 in M.contents)//War Sword
						locate(J12)
						if(J12:needssharpening==1)
							return J12
				proc/FindBSWf(mob/players/M)
					for(var/obj/items/Crafting/Created/Battleswordblade/J13 in M.contents)//Battle Sword
						locate(J13)
						if(J13:needssharpening==1)
							return J13
				proc/FindLSf(mob/players/M)
					for(var/obj/items/Crafting/Created/Longswordblade/J14 in M.contents)//Long Sword
						locate(J14)
						if(J14:needssharpening==1)
							return J14
				proc/FindWMf(mob/players/M)
					for(var/obj/items/Crafting/Created/Warmaulhead/J15 in M.contents)//War Maul
						locate(J15)
						if(J15:needssharpening==1)
							return J15
				proc/FindBHf(mob/players/M)
					for(var/obj/items/Crafting/Created/Battlehammersledge/J16 in M.contents)//Battle Hammer
						locate(J16)
						if(J16:needssharpening==1)
							return J16
				proc/FindWXf(mob/players/M)
					for(var/obj/items/Crafting/Created/Waraxeblade/J17 in M.contents)//War Axe
						locate(J17)
						if(J17:needssharpening==1)
							return J17
				proc/FindBXf(mob/players/M)
					for(var/obj/items/Crafting/Created/Battleaxeblade/J18 in M.contents)//Battle Axe
						locate(J18)
						if(J18:needssharpening==1)
							return J18
				proc/FindWSYf(mob/players/M)
					for(var/obj/items/Crafting/Created/Warscytheblade/J19 in M.contents)//War Scythe
						locate(J19)
						if(J19:needssharpening==1)
							return J19
				proc/FindBSYf(mob/players/M)
					for(var/obj/items/Crafting/Created/Battlescytheblade/J20 in M.contents)//Battle Scythe
						locate(J20)
						if(J20:needssharpening==1)
							return J20

//Lamp

				proc/FindILf(mob/players/M)
					for(var/obj/items/Crafting/Created/IronLampHead/J21 in M.contents)//Iron Lamp Head
						locate(J21)
						if(J21:needssharpening==1)
							return J21
				proc/FindCLf(mob/players/M)
					for(var/obj/items/Crafting/Created/CopperLampHead/J22 in M.contents)//Copper Lamp Head
						locate(J22)
						if(J22:needssharpening==1)
							return J22
				proc/FindBRLf(mob/players/M)
					for(var/obj/items/Crafting/Created/BronzeLampHead/J23 in M.contents)//Bronze Lamp Head
						locate(J23)
						if(J23:needssharpening==1)
							return J23
				proc/FindBSLf(mob/players/M)
					for(var/obj/items/Crafting/Created/BrassLampHead/J24 in M.contents)//Brass Lamp Head
						locate(J24)
						if(J24:needssharpening==1)
							return J24
				proc/FindSLf(mob/players/M)
					for(var/obj/items/Crafting/Created/SteelLampHead/J25 in M.contents)//Steel Lamp Head
						locate(J25)
						if(J25:needssharpening==1)
							return J25
//Misc Parts
				proc/FindAVf(mob/players/M)
					for(var/obj/items/Crafting/Created/AnvilHead/J26 in M.contents)//Iron Anvil Head
						locate(J26)
						if(J26:needssharpening==1)
							return J26

				proc/Shrpn()//working confirmed
					//set src in usr
					var/mob/players/M
					M = usr
//Tool Call
					var/obj/items/Crafting/Created/HammerHead/J = call(/obj/items/tools/Whetstone/proc/FindHMf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/CKnifeblade/J1 = call(/obj/items/tools/Whetstone/proc/FindCKf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/SickleBlade/J2 = call(/obj/items/tools/Whetstone/proc/FindSBf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/TrowelBlade/J3 = call(/obj/items/tools/Whetstone/proc/FindTWBf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/ChiselBlade/J4 = call(/obj/items/tools/Whetstone/proc/FindCBf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/AxeHead/J5 = call(/obj/items/tools/Whetstone/proc/FindAHf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/FileBlade/J6 = call(/obj/items/tools/Whetstone/proc/FindFBf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/ShovelHead/J7 = call(/obj/items/tools/Whetstone/proc/FindSHf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/HoeBlade/J8 = call(/obj/items/tools/Whetstone/proc/FindHOf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/PickaxeHead/J9 = call(/obj/items/tools/Whetstone/proc/FindPXf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/SawBlade/J10 = call(/obj/items/tools/Whetstone/proc/FindSWf)(M)//locate() in M.contents
//Weapon Call

					var/obj/items/Crafting/Created/Broadswordblade/J11 = call(/obj/items/tools/Whetstone/proc/FindBSf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Warswordblade/J12 = call(/obj/items/tools/Whetstone/proc/FindWSf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Battleswordblade/J13 = call(/obj/items/tools/Whetstone/proc/FindBSWf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Longswordblade/J14 = call(/obj/items/tools/Whetstone/proc/FindLSf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Warmaulhead/J15 = call(/obj/items/tools/Whetstone/proc/FindWMf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Battlehammersledge/J16 = call(/obj/items/tools/Whetstone/proc/FindBHf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Waraxeblade/J17 = call(/obj/items/tools/Whetstone/proc/FindWXf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Battleaxeblade/J18 = call(/obj/items/tools/Whetstone/proc/FindBXf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Warscytheblade/J19 = call(/obj/items/tools/Whetstone/proc/FindWSYf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Battlescytheblade/J20 = call(/obj/items/tools/Whetstone/proc/FindBSYf)(M)//locate() in M.contents

//Lamp Call

					var/obj/items/Crafting/Created/IronLampHead/J21 = call(/obj/items/tools/Whetstone/proc/FindILf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/CopperLampHead/J22 = call(/obj/items/tools/Whetstone/proc/FindCLf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/BronzeLampHead/J23 = call(/obj/items/tools/Whetstone/proc/FindBRLf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/BrassLampHead/J24 = call(/obj/items/tools/Whetstone/proc/FindBSLf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/SteelLampHead/J25 = call(/obj/items/tools/Whetstone/proc/FindSLf)(M)//locate() in M.contents
//Misc Parts
					var/obj/items/Crafting/Created/AnvilHead/J26 = call(/obj/items/tools/Whetstone/proc/FindAVf)(M)//locate() in M.contents
//Tool Quench Check
					if(J)
						if(J.needsfiled==1)
							M << "[J] needs to be filed before sharpening."
							return
						else if(J.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J1)
						if(J1.needsfiled==1)
							M << "[J1] needs to be filed before sharpening."
							return
						else if(J1.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J2)
						if(J2.needsfiled==1)
							M << "[J2] needs to be filed before sharpening."
							return
						else if(J2.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J3)
						if(J3.needsfiled==1)
							M << "[J3] needs to be filed before sharpening."
							return
						else if(J3.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J4)
						if(J4.needsfiled==1)
							M << "[J4] needs to be filed before sharpening."
							return
						else if(J4.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J5)
						if(J5.needsfiled==1)
							M << "[J5] needs to be filed before sharpening."
							return
						else if(J5.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J6)
						if(J6.needsfiled==1)
							M << "[J6] needs to be filed before sharpening."
							return
						else if(J6.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J7)
						if(J7.needsfiled==1)
							M << "[J7] needs to be filed before sharpening."
							return
						else if(J7.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J8)
						if(J8.needsfiled==1)
							M << "[J8] needs to be filed before sharpening."
							return
						else if(J8.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J9)
						if(J9.needsfiled==1)
							M << "[J9] needs to be filed before sharpening."
							return
						else if(J9.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J10)
						if(J10.needsfiled==1)
							M << "[J10] needs to be filed before sharpening."
							return
						else if(J10.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
//Weapon Quench Check
					if(J11)
						if(J11.needsfiled==1)
							M << "[J11] needs to be filed before sharpening."
							return
						else if(J11.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J12)
						if(J12.needsfiled==1)
							M << "[J12] needs to be filed before sharpening."
							return
						else if(J12.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J13)
						if(J13.needsfiled==1)
							M << "[J13] needs to be filed before sharpening."
							return
						else if(J13.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J14)
						if(J14.needsfiled==1)
							M << "[J14] needs to be filed before sharpening."
							return
						else if(J14.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J15)
						if(J15.needsfiled==1)
							M << "[J15] needs to be filed before sharpening."
							return
						else if(J15.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J16)
						if(J16.needsfiled==1)
							M << "[J16] needs to be filed before sharpening."
							return
						else if(J16.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J17)
						if(J17.needsfiled==1)
							M << "[J17] needs to be filed before sharpening."
							return
						else if(J17.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J18)
						if(J18.needsfiled==1)
							M << "[J18] needs to be filed before sharpening."
							return
						else if(J18.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J19)
						if(J19.needsfiled==1)
							M << "[J19] needs to be filed before sharpening."
							return
						else if(J19.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J20)
						if(J20.needsfiled==1)
							M << "[J20] needs to be filed before sharpening."
							return
						else if(J20.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
//Lamp Check
					else if(J21)
						if(J21.needsfiled==1)
							M << "[J21] needs to be filed before sharpening."
							return
						else if(J21.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J22)
						if(J22.needsfiled==1)
							M << "[J22] needs to be filed before sharpening."
							return
						else if(J22.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J23)
						if(J23.needsfiled==1)
							M << "[J23] needs to be filed before sharpening."
							return
						else if(J23.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J24)
						if(J24.needsfiled==1)
							M << "[J24] needs to be filed before sharpening."
							return
						else if(J24.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
					else if(J25)
						if(J25.needsfiled==1)
							M << "[J25] needs to be filed before sharpening."
							return
						else if(J25.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
//Misc Parts
					else if(J26)
						if(J26.needsfiled==1)
							M << "[J26] needs to be filed before sharpening."
							return
						else if(J26.needssharpening==0)
							M << "This item doesn't need sharpened."
							return
//Tool Process
					if(J)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J]."
							J.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J] could use more sharpening."
							J.needssharpening=1
							return
					else if(J1)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J1]."
							J1.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J1] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J1]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J1] could use more sharpening."
							J1.needssharpening=1
							return
					else if(J2)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J2]."
							J2.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J2] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J2]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J2] could use more sharpening."
							J2.needssharpening=1
							return
					else if(J3)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J3]."
							J3.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J3] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J3]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J3] could use more sharpening."
							J3.needssharpening=1
							return
					else if(J4)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J4]."
							J4.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J4] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J4]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J4] could use more sharpening."
							J4.needssharpening=1
							return
					else if(J5)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J5]."
							J5.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J5] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J5]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J5] could use more sharpening."
							J5.needssharpening=1
							return
					else if(J6)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J6]."
							J6.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J6] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J6]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J6] could use more sharpening."
							J6.needssharpening=1
							return
					else if(J7)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J7]."
							J7.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J7] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J7]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J7] could use more sharpening."
							J7.needssharpening=1
							return
					else if(J8)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J8]."
							J8.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J8] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J8]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J8] could use more sharpening."
							J8.needssharpening=1
							return
					else if(J9)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J9]."
							J9.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J9] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J9]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J9] could use more sharpening."
							J9.needssharpening=1
							return
					else if(J10)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J10]."
							J10.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J10] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J10]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J10] could use more sharpening."
							J10.needssharpening=1
							return
//Weapon Process
					else if(J11)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J11]."
							J11.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J11] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J11]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J11] could use more sharpening."
							J11.needssharpening=1
							return
					else if(J12)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J12]."
							J12.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J12] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J12]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J12] could use more sharpening."
							J12.needssharpening=1
							return
					else if(J13)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J13]."
							J13.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J13] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J13]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J13] could use more sharpening."
							J13.needssharpening=1
							return
					else if(J14)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J14]."
							J14.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J14] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J14]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J14] could use more sharpening."
							J14.needssharpening=1
							return
					else if(J15)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J15]."
							J15.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J15] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J15]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J15] could use more sharpening."
							J15.needssharpening=1
							return
					else if(J16)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J16]."
							J6.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J16] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J16]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J16] could use more sharpening."
							J16.needssharpening=1
							return
					else if(J17)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J17]."
							J17.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J17] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J17]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J17] could use more sharpening."
							J17.needssharpening=1
							return
					else if(J18)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J18]."
							J18.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J18] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J18]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J18] could use more sharpening."
							J18.needssharpening=1
							return
					else if(J19)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J19]."
							J19.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J19] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J19]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J19] could use more sharpening."
							J19.needssharpening=1
							return
					else if(J20)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J20]."
							J20.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J20] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J20]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J20] could use more sharpening."
							J20.needssharpening=1
							return
//Lamp Process
					else if(J21)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J21]."
							J21.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J21] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J21]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J21] could use more sharpening."
							J21.needssharpening=1
							return
					else if(J22)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J22]."
							J22.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J22] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J22]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J22] could use more sharpening."
							J22.needssharpening=1
							return
					else if(J23)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J23]."
							J23.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J23] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J23]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J23] could use more sharpening."
							J23.needssharpening=1
							return
					else if(J24)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J24]."
							J24.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J24] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J24]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J24] could use more sharpening."
							J24.needssharpening=1
							return
					else if(J25)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J25]."
							J25.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J25] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J25]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J25] could use more sharpening."
							J25.needssharpening=1
							return
//Misc Parts
					else if(J26)
						if(prob(50))
							M<<"You run the Whetstone across the edge of [J26]."
							J26.needssharpening=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J26] has been sharpened to a fine edge!"
							return
						else
							M<<"You run the Whetstone across the edge of [J26]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J26] could use more sharpening."
							J26.needssharpening=1
							return
