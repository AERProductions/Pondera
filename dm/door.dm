mob/players
	Click(obj/O)  //Calls this when a person bumps into something
		if(istype(O,/obj/doors/CLeftDoor/))   //Checks to see if it is a door
			call(/obj/doors/CLeftDoor/proc/tryit)(usr,O)  //Calls the process for asking for the password
		if(istype(O,/obj/doors/CRightDoor/))
			call(/obj/doors/CRightDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/doors/CTopDoor/))   //Checks to see if it is a door
			call(/obj/doors/CTopDoor/proc/tryit)(usr,O)  //Calls the process for asking for the password
		if(istype(O,/obj/doors/CBottomDoor/))
			call(/obj/doors/CBottomDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/LeftDoor/))   //Checks to see if it is a door
			call(/obj/Buildable/Doors/LeftDoor/proc/tryit)(usr,O)  //Calls the process for asking for the password
		if(istype(O,/obj/Buildable/Doors/RightDoor/))
			call(/obj/Buildable/Doors/RightDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/TopDoor/))   //Checks to see if it is a door
			call(/obj/Buildable/Doors/TopDoor/proc/tryit)(usr,O)  //Calls the process for asking for the password
		if(istype(O,/obj/Buildable/Doors/Door/))
			call(/obj/Buildable/Doors/Door/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/WHLeftDoor/))     			//WHD
			call(/obj/Buildable/Doors/WHLeftDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/WHRightDoor/))
			call(/obj/Buildable/Doors/WHRightDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/WHTopDoor/))   //Checks to see if it is a door
			call(/obj/Buildable/Doors/WHTopDoor/proc/tryit)(usr,O)  //Calls the process for asking for the password
		if(istype(O,/obj/Buildable/Doors/WHDoor/))
			call(/obj/Buildable/Doors/WHDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/SHLeftDoor/))   			//SHD
			call(/obj/Buildable/Doors/SHLeftDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/SHRightDoor/))
			call(/obj/Buildable/Doors/SHRightDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/SHTopDoor/))   //Checks to see if it is a door
			call(/obj/Buildable/Doors/SHTopDoor/proc/tryit)(usr,O)  //Calls the process for asking for the password
		if(istype(O,/obj/Buildable/Doors/SHDoor/))
			call(/obj/Buildable/Doors/SHDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/exits/oneway))
			if(usr.dir == O.dir)
				usr.density = 0
				step(usr,usr.dir)
				usr.density = 1
		if(istype(O,/obj/Z/sign))
			usr << "<center>[O:msg]"
			//usr << "<center>[O:owner]"
	Bump(obj/O)  //Calls this when a person bumps into something
		if(istype(O,/obj/doors/CLeftDoor/))   //Checks to see if it is a door
			call(/obj/doors/CLeftDoor/proc/tryit)(usr,O)  //Calls the process for asking for the password
		if(istype(O,/obj/doors/CRightDoor/))
			call(/obj/doors/CRightDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/doors/CTopDoor/))   //Checks to see if it is a door
			call(/obj/doors/CTopDoor/proc/tryit)(usr,O)  //Calls the process for asking for the password
		if(istype(O,/obj/doors/CBottomDoor/))
			call(/obj/doors/CBottomDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/LeftDoor/))
			call(/obj/Buildable/Doors/LeftDoor/proc/tryit)(usr,O)  //Calls the process for asking for the password
		if(istype(O,/obj/Buildable/Doors/RightDoor/))
			call(/obj/Buildable/Doors/RightDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/TopDoor/))   //Checks to see if it is a door
			call(/obj/Buildable/Doors/TopDoor/proc/tryit)(usr,O)  //Calls the process for asking for the password
		if(istype(O,/obj/Buildable/Doors/Door/))
			call(/obj/Buildable/Doors/Door/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/WHLeftDoor/))     			//WHD
			call(/obj/Buildable/Doors/WHLeftDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/WHRightDoor/))
			call(/obj/Buildable/Doors/WHRightDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/WHTopDoor/))   //Checks to see if it is a door
			call(/obj/Buildable/Doors/WHTopDoor/proc/tryit)(usr,O)  //Calls the process for asking for the password
		if(istype(O,/obj/Buildable/Doors/WHDoor/))
			call(/obj/Buildable/Doors/WHDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/SHLeftDoor/))   			//SHD
			call(/obj/Buildable/Doors/SHLeftDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/SHRightDoor/))
			call(/obj/Buildable/Doors/SHRightDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/SHTopDoor/))   //Checks to see if it is a door
			call(/obj/Buildable/Doors/SHTopDoor/proc/tryit)(usr,O)  //Calls the process for asking for the password
		if(istype(O,/obj/Buildable/Doors/SHDoor/))
			call(/obj/Buildable/Doors/SHDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/SLeftDoor/))   			//SD
			call(/obj/Buildable/Doors/SLeftDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/SRightDoor/))
			call(/obj/Buildable/Doors/SRightDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/STopDoor/))   //Checks to see if it is a door
			call(/obj/Buildable/Doors/STopDoor/proc/tryit)(usr,O)  //Calls the process for asking for the password
		if(istype(O,/obj/Buildable/Doors/SDoor/))
			call(/obj/Buildable/Doors/SDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/HTLeftDoor/))   			//HTD
			call(/obj/Buildable/Doors/HTLeftDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/HTRightDoor/))
			call(/obj/Buildable/Doors/HTRightDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/Buildable/Doors/HTTopDoor/))   //Checks to see if it is a door
			call(/obj/Buildable/Doors/HTTopDoor/proc/tryit)(usr,O)  //Calls the process for asking for the password
		if(istype(O,/obj/Buildable/Doors/HTDoor/))
			call(/obj/Buildable/Doors/HTDoor/proc/tryit)(usr,O)
		if(istype(O,/obj/exits/oneway))
			if(usr.dir == O.dir)
				usr.density = 0
				step(usr,usr.dir)
				usr.density = 1
		if(istype(O,/obj/Z/sign))
			usr << "<center>[O:msg]"
			//usr << "<center>[O:owner]"
obj
	doors//story mode doors
		icon = 'dmi/64/Castl.dmi'
		var/unlocked = 1                                //anything tabbed under this is or affects a object
		CBottomDoor                               //starts a obj called "door" (this is the part you've been waiting for!)             //it's icon is 'door.dmi'
			icon = 'dmi/64/Castl.dmi'
			icon_state = "closed"
			layer = MOB_LAYER+5          //it's icon_state is "closed" (this is so the door is closed at first)
			density = 1                    //cant walk through it                    //cant see through it
			unlocked = 1
			DblClick(var/obj/doors/CBottomDoor/O)
				if (!(src in range(1, usr))) return
				O = src
				call(/proc/openbcd)(O)
			proc/tryit(var/mob/m,var/obj/doors/O)  //Procedure for asking for the password
				set background = 1
				if(O.unlocked == 1)
					call(/proc/openbcd)(O)
		CRightDoor                               //starts a obj called "door" (this is the part you've been waiting for!)              //it's icon is 'door.dmi'
			icon = 'dmi/64/Castl.dmi'
			icon_state = "sclosedr"
			layer = MOB_LAYER+3          //it's icon_state is "closed" (this is so the door is closed at first)
			density = 1                    //cant walk through it                    //cant see through it
			unlocked = 1
			DblClick(var/obj/doors/CRightDoor/O)
				if (!(src in range(1, usr))) return
				O = src
				call(/proc/openrcd)(O)
			proc/tryit(var/mob/m,var/obj/doors/O)  //Procedure for asking for the password
				set background = 1
				if(O.unlocked == 1)
					call(/proc/openrcd)(O)
		CTopDoor                               //starts a obj called "door" (this is the part you've been waiting for!)             //it's icon is 'door.dmi'
			icon = 'dmi/64/Castl.dmi'
			icon_state = "sclosedt"
			layer = MOB_LAYER+3          //it's icon_state is "closed" (this is so the door is closed at first)
			density = 1                    //cant walk through it                    //cant see through it
			unlocked = 1
			DblClick(var/obj/doors/CTopDoor/O)
				if (!(src in range(1, usr))) return
				O = src
				call(/proc/opentcd)(O)
			proc/tryit(var/mob/m,var/obj/doors/O)  //Procedure for asking for the password
				set background = 1
				if(O.unlocked == 1)
					call(/proc/opentcd)(O)
		CLeftDoor                               //starts a obj called "door" (this is the part you've been waiting for!)             //it's icon is 'door.dmi'
			icon = 'dmi/64/Castl.dmi'
			icon_state = "sclosedl"
			layer = MOB_LAYER+5          //it's icon_state is "closed" (this is so the door is closed at first)
			density = 1                    //cant walk through it                    //cant see through it
			unlocked = 1
			DblClick(var/obj/doors/CLeftDoor/O)
				if (!(src in range(1, usr))) return
				O = src
				call(/proc/openlcd)(O)
			proc/tryit(var/mob/m,var/obj/doors/O)  //Procedure for asking for the password
				set background = 1
				if(O.unlocked == 1)
					call(/proc/openlcd)(O)
	hdoors
		icon = 'dmi/64/Castl.dmi'
		var/unlocked = 1                                //anything tabbed under this is or affects a object
		HBottomDoor                               //starts a obj called "door" (this is the part you've been waiting for!)             //it's icon is 'door.dmi'
			icon = 'dmi/64/Castl.dmi'
			icon_state = "hclosed"
			layer = MOB_LAYER+5          //it's icon_state is "closed" (this is so the door is closed at first)
			density = 1                    //cant walk through it                    //cant see through it
			unlocked = 1
			DblClick(var/obj/hdoors/HBottomDoor/O)
				if (!(src in range(1, usr))) return
				O = src
				call(/proc/hopenbcd)(O)
			proc/tryit(var/mob/m,var/obj/hdoors/O)  //Procedure for asking for the password
				set background = 1
				if(O.unlocked == 1)
					call(/proc/hopenbcd)(O)
		HRightDoor                               //starts a obj called "door" (this is the part you've been waiting for!)              //it's icon is 'door.dmi'
			icon = 'dmi/64/Castl.dmi'
			icon_state = "hsclosedr"
			layer = MOB_LAYER+5          //it's icon_state is "closed" (this is so the door is closed at first)
			density = 1                    //cant walk through it                    //cant see through it
			unlocked = 1
			DblClick(var/obj/hdoors/HRightDoor/O)
				if (!(src in range(1, usr))) return
				O = src
				call(/proc/hopenrcd)(O)
			proc/tryit(var/mob/m,var/obj/hdoors/O)  //Procedure for asking for the password
				set background = 1
				if(O.unlocked == 1)
					call(/proc/hopenrcd)(O)
		HTopDoor                               //starts a obj called "door" (this is the part you've been waiting for!)             //it's icon is 'door.dmi'
			icon = 'dmi/64/Castl.dmi'
			icon_state = "hsclosedt"
			layer = MOB_LAYER+5          //it's icon_state is "closed" (this is so the door is closed at first)
			density = 1                    //cant walk through it                    //cant see through it
			unlocked = 1
			DblClick(var/obj/hdoors/HTopDoor/O)
				if (!(src in range(1, usr))) return
				O = src
				call(/proc/hopentcd)(O)
			proc/tryit(var/mob/m,var/obj/hdoors/O)  //Procedure for asking for the password
				set background = 1
				if(O.unlocked == 1)
					call(/proc/hopentcd)(O)
		HLeftDoor                               //starts a obj called "door" (this is the part you've been waiting for!)             //it's icon is 'door.dmi'
			icon = 'dmi/64/Castl.dmi'
			icon_state = "hsclosedl"
			layer = MOB_LAYER+5          //it's icon_state is "closed" (this is so the door is closed at first)
			density = 1                    //cant walk through it                    //cant see through it
			unlocked = 1
			DblClick(var/obj/hdoors/HLeftDoor/O)
				if (!(src in range(1, usr))) return
				O = src
				call(/proc/hopenlcd)(O)
			proc/tryit(var/mob/m,var/obj/hdoors/O)  //Procedure for asking for the password
				set background = 1
				if(O.unlocked == 1)
					call(/proc/hopenlcd)(O)



	Buildable
		Doors//buildable sandbox doors
			var/pword
			var/locked
			var/unlocked
			var/Key = /obj/items/DoorKey
			LeftDoor
				icon = 'dmi/64/doors.dmi'
				icon_state = "sclosedl"
				layer = MOB_LAYER+5
				locked
				unlocked
				density = 1
				//opacity = 1
				name = "Wood Fort West Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/LeftDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/LeftDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/openld)(O)
			RightDoor
				density = 1
				//opacity = 1
				locked = 0
				unlocked = 1
				icon_state = "sclosedr"
				icon = 'dmi/64/doors.dmi'
				layer = MOB_LAYER+5
				name = "Wood Fort East Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/RightDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/RightDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/openrd)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/openrd)(O)
			TopDoor
				icon = 'dmi/64/doors.dmi'
				icon_state = "tclosed"
				layer = MOB_LAYER+5
				locked = 0
				unlocked = 1
				density = 1
				//opacity = 1
				name = "Wood Fort North Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/TopDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/TopDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/opentd)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/opentd)(O)
			Door
				density = 1
			//	opacity = 0
				locked = 0
				unlocked = 1
				icon = 'dmi/64/doors.dmi'
				icon_state = "closed"
				layer = MOB_LAYER+5
				name = "Wood Fort South Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/Door/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/Door/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/open1)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/open1)(O)
			SLeftDoor
				icon = 'dmi/64/doors.dmi'
				icon_state = "Ssclosedl"
				layer = MOB_LAYER+5
				locked = 0
				unlocked = 1
				density = 1
				//opacity = 1

				name = "Stone Fort West Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/SLeftDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/SLeftDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/opensld)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/opensld)(O)
			SRightDoor
				density = 1
			//	opacity = 0
				locked = 0
				unlocked = 1
				icon_state = "Ssclosedr"
				icon = 'dmi/64/doors.dmi'
				layer = MOB_LAYER+5
				name = "Stone Fort East Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/SRightDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/SRightDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/opensrd)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/opensrd)(O)
			STopDoor
				icon = 'dmi/64/doors.dmi'
				icon_state = "Stclosed"
				layer = MOB_LAYER+5
				locked = 0
				unlocked = 1
				density = 1
			//	opacity = 0
				name = "Stone Fort North Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/STopDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/STopDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/openstd)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/openstd)(O)
			SDoor
				density = 1
			//	opacity = 0
				locked = 0
				unlocked = 1
				icon = 'dmi/64/doors.dmi'
				icon_state = "Sclosed"
				layer = MOB_LAYER+5
				name = "Stone Fort West Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/SDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/SDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/opens1)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/opens1)(O)
			HTLeftDoor
				icon = 'dmi/64/doors.dmi'
				icon_state = "htlclosed"
				layer = MOB_LAYER+5
				locked = 0
				unlocked = 1
				density = 1
				//opacity = 1
				DblClick(var/obj/Buildable/Doors/O)
					var/mob/m
					if (!(src in range(1, usr))) return
					if(O:buildingowner == "[usr.key]")
						if(O.locked == 1&&Key in m.contents)
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock the door."
							return
						if(O.unlocked == 1&&Key in m.contents)
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the door."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						if(Key in m.contents&&O.locked==1)
							O:locked = 0
							O:unlocked = 1
						else
							m<<"You need to use a key on a locked door to unlock it."
							return 0
					else
						if(O.locked==0&&O.unlocked==1&&O.pword == "")
							call(/proc/openhtld)(O)
					if(O.pword == ""&&O.unlocked == 1&&O.locked == 0)
						call(/proc/openhtld)(O)
					else
						var/a = input("What is the password?","Door")as text  //Asks for the password
						if(O.pword == "[a]")  //If the password you tried is the password
							call(/proc/openhtld)(O)  //It calls the procedure for making the door open
							return 0
						else  //If the password was wrong
							m << "<I><B>INCORRECT PASSWORD!</I>"
							return 0
			HTRightDoor
				density = 1
			//	opacity = 0
				locked = 0
				unlocked = 1
				icon_state = "htrclosed"
				icon = 'dmi/64/doors.dmi'
				layer = MOB_LAYER+5
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						if(Key in m.contents&&O.locked==1)
							O:locked = 0
							O:unlocked = 1
						else
							m<<"You need to use a key on a locked door to unlock it."
							return 0
					else
						if(O.locked==0&&O.unlocked==1&&O.pword == "")
							call(/proc/openhtrd)(O)
					if(O.pword == ""&&O.unlocked == 1&&O.locked == 0)
						call(/proc/openhtrd)(O)
					else
						var/a = input("What is the password?","Door")as text  //Asks for the password
						if(O.pword == "[a]")  //If the password you tried is the password
							call(/proc/openhtrd)(O)  //It calls the procedure for making the door open
							return 0
						else  //If the password was wrong
							m << "<I><B>INCORRECT PASSWORD!</I>"
							return 0
			HTTopDoor
				icon = 'dmi/64/doors.dmi'
				icon_state = "htnclosed"
				layer = MOB_LAYER+5
				locked = 0
				unlocked = 1
				density = 1
			//	opacity = 0
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						if(Key in m.contents&&O.locked==1)
							O:locked = 0
							O:unlocked = 1
						else
							m<<"You need to use a key on a locked door to unlock it."
							return 0
					else
						if(O.locked==0&&O.unlocked==1&&O.pword == "")
							call(/proc/openhttd)(O)
					if(O.pword == ""&&O.unlocked == 1&&O.locked == 0)
						call(/proc/openhttd)(O)
					else
						var/a = input("What is the password?","Door")as text  //Asks for the password
						if(O.pword == "[a]")  //If the password you tried is the password
							call(/proc/openhttd)(O)  //It calls the procedure for making the door open
							return 0
						else  //If the password was wrong
							m << "<I><B>INCORRECT PASSWORD!</I>"
							return 0
			HTDoor
				density = 1
			//	opacity = 0
				locked = 0
				unlocked = 1
				icon = 'dmi/64/doors.dmi'
				icon_state = "htsclosed"
				layer = MOB_LAYER+5
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						if(Key in m.contents&&O.locked==1)
							O:locked = 0
							O:unlocked = 1
						else
							m<<"You need to use a key on a locked door to unlock it."
							return 0
					else
						if(O.locked==0&&O.unlocked==1&&O.pword == "")
							call(/proc/openht1)(O)
					if(O.pword == ""&&O.unlocked == 1&&O.locked == 0)
						call(/proc/openht1)(O)
					else
						var/a = input("What is the password?","Door")as text  //Asks for the password
						if(O.pword == "[a]")  //If the password you tried is the password
							call(/proc/openht1)(O)  //It calls the procedure for making the door open
							return 0
						else  //If the password was wrong
							m << "<I><B>INCORRECT PASSWORD!</I>"
							return 0
		//WOOD HOUSE DOOR
			WHLeftDoor
				icon = 'dmi/64/wall.dmi'
				icon_state = "whdlc"
				layer = MOB_LAYER+5
				name = "Wooden House West Door"
				//description = "Wooden House Left Door
				locked = 0
				unlocked = 1
				density = 1
			//	opacity = 0
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/WHLeftDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/WHLeftDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/openwhld)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/openwhld)(O)

			WHRightDoor
				density = 1
			//	opacity = 0
				locked = 0
				unlocked = 1
				icon = 'dmi/64/wall.dmi'
				icon_state = "whdrc"
				layer = MOB_LAYER+5
				name = "Wooden House East Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/WHRightDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/WHRightDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/openwhrd)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/openwhrd)(O)
			WHTopDoor
				icon = 'dmi/64/wall.dmi'
				icon_state = "whdtc"
				layer = MOB_LAYER+5
				locked = 0
				unlocked = 1
				density = 1
			//	opacity = 0
				name = "Wooden House North Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/WHTopDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/WHTopDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/openwhtd)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/openwhtd)(O)
			WHDoor
				density = 1
			//	opacity = 0
			//	mouse_opacity = 1
				locked = 0
				unlocked = 1
				icon = 'dmi/64/wall.dmi'
				icon_state = "whdc"
				layer = MOB_LAYER+5
				//buildingowner=""
				name = "Wooden House South Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/WHDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/WHDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/openwh1)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/openwh1)(O)
			SHLeftDoor
				icon = 'dmi/64/wall.dmi'
				icon_state = "shdlc"
				layer = MOB_LAYER+5
				locked = 0
				unlocked = 1
				density = 1
				//opacity = 1
				name = "Stone House West Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/SHLeftDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/SHLeftDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/openshld)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/openshld)(O)

			SHRightDoor
				density = 1
				//opacity = 1
				locked = 0
				unlocked = 1
				icon = 'dmi/64/wall.dmi'
				icon_state = "shdrc"
				layer = MOB_LAYER+5
				name = "Stone House East Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/SHRightDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/SHRightDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/openshld)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/openshrd)(O)
			SHTopDoor
				icon = 'dmi/64/wall.dmi'
				icon_state = "shdtc"
				layer = MOB_LAYER+5
				locked = 0
				unlocked = 1
				density = 1
				//opacity = 1
				name = "Stone House North Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/SHTopDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/SHTopDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/openshtd)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/openshtd)(O)
			SHDoor
				density = 1
				//opacity = 1
				locked = 0
				unlocked = 1
				icon = 'dmi/64/wall.dmi'
				icon_state = "shdc"
				layer = MOB_LAYER+5
				name = "Stone House South Door"
				//description = "Wooden House Left Door
				DblClick()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/SHDoor/O
					O = src
					//if (!(src in range(1, usr))) return
					var/obj/items/Lockpick/LKP = locate() in m.contents
					//var/R = roll(dice)
					if(LKP in m)//&&(src.buildingowner == "[usr.key]"))
						var/dice = "1d12"
						var/R = roll(dice)
						if(O.locked == 1)
							if(R==5)
								O.locked = 0
								O.unlocked = 1
								m << "You Unlock the [O.name] with the lockpick."
							else
								return
						if(O.unlocked == 1)
							if(R==9)
								O.unlocked = 0
								O.locked = 1
								m << "You Lock the [O.name] with the lockpick."
							else
								return
					else
						//m << "You need to use a key on a locked door that you own to unlock it."
						return
				Click()
					set popup_menu = 1
					var/mob/players/m
					m = usr
					var/obj/Buildable/Doors/SHDoor/O
					O = src
					var/DKey = locate(Key) in m.contents
					//if (!(src in range(1, usr))) return
					//for(O in view(1, usr))
					if(O.unlocked == 1&&DKey in usr.contents&&O.buildingowner == "[usr.key]")
						call(/proc/opensh1)(O)  //It calls the procedure for making the door open
						return
						m<<"You use the [Key]"
					else
						if(DKey == null&&O.buildingowner != "[usr.key]")
							m<<"Cheeky Bastard! You are not the [O.name] owner! ([src.buildingowner])"
							return
					/*var/txt = input("What is the password for [O.name]?","[O.name]")as text//Asks for the password
					if(O.pword == "[txt]")  //If the password you tried is the password
						call(/proc/openld)(O)  //It calls the procedure for making the door open
						return
					else  //If the password was wrong
						m << "<I><B>INCORRECT PASSWORD!</I>"
						return*/
						if(O.locked == 1&&O.unlocked == 0&&O.buildingowner == "[usr.key]")
							O:locked = 0
							O:unlocked = 1
							m<<"You Unlock [O.name]."
							return
						//else
						//	m<<"You are not the [O.name] owner! ([src.buildingowner])"
						else if(O.locked == 0&&O.unlocked == 1&&O.buildingowner == "[usr.key]")
							O:unlocked = 0
							O:locked = 1
							m<<"You Lock the [O.name]."
							return
				proc/tryit(var/mob/m,var/obj/Buildable/Doors/O)  //Procedure for asking for the password
					set waitfor = 0
					set background = 1
					if(O.locked == 1&&O.unlocked == 0)
						//m<<"You need to use a key to unlock the [O.name]."
						sleep(world.tick_lag)
						return
					else
						if(O.unlocked == 1&&O.locked == 0)
							call(/proc/opensh1)(O)

//castle doors

//LeftDoor
proc
	openlcd(obj/doors/CLeftDoor/O)
		set waitfor = 0
		O.icon_state = "sopenl"  //Door stays open
		O.density = 0  //Allows you to walk through it
		//O.opacity = 0  //Allows you to see past it
		//sleep(40)  //Waits a while before shutting the door
		loop                   //creates a tag so I can go back here later
		sleep(40)              //waits 1 second
		if(O.loc == usr.loc) //if the player is still inside the door...
			goto loop          //go to the "loop" tag above
		else   //Waits a while before shutting the door
			O.icon_state = "sclosedl"
			O.density = 1  //Makes it solid again
		//	O.opacity = 1  //Now you can't see inside it
	//RightDoor
	openrcd(obj/doors/CRightDoor/O)
		set waitfor = 0
		O = src
		O.icon_state = "sopenr"  //Door stays open
		O.density = 0  //Allows you to walk through it
	//	O.opacity = 0  //Allows you to see past it
		//sleep(40)  //Waits a while before shutting the door
		loop                   //creates a tag so I can go back here later
		sleep(40)              //waits 1 second
		if(O.loc == usr.loc) //if the player is still inside the door...
			goto loop          //go to the "loop" tag above
		else   //Waits a while before shutting the door
			O.icon_state = "sclosedr"
			O.density = 1  //Makes it solid again
	//		O.opacity = 1  //Now you can't see inside it
	//TopDoor
	opentcd(obj/doors/CTopDoor/O)
		set waitfor = 0
		O.icon_state = "sopent"  //Door stays open
		O.density = 0  //Allows you to walk through it
	//	O.opacity = 0  //Allows you to see past it
		//sleep(40)  //Waits a while before shutting the door
		loop                   //creates a tag so I can go back here later
		sleep(40)              //waits 1 second
		if(O.loc == usr.loc) //if the player is still inside the door...
			goto loop          //go to the "loop" tag above
		else   //Waits a while before shutting the door
			O.icon_state = "sclosedt"
			O.density = 1  //Makes it solid again
	//		O.opacity = 1  //Now you can't see inside it
	//Door
	openbcd(obj/doors/CBottomDoor/O)
		set waitfor = 0
		O.icon_state = "open"  //Door stays open
		O.density = 0  //Allows you to walk through it
	//	O.opacity = 0  //Allows you to see past it
		//sleep(40)  //Waits a while before shutting the door
		loop                   //creates a tag so I can go back here later
		sleep(40)              //waits 1 second
		if(O.loc == usr.loc) //if the player is still inside the door...
			goto loop          //go to the "loop" tag above
		else   //Waits a while before shutting the door
			O.icon_state = "closed"
			O.density = 1  //Makes it solid again
	//		O.opacity = 1  //Now you can't see inside it

	//hcastle doors

	//LeftDoor
	hopenlcd(obj/hdoors/HLeftDoor/O)
		set waitfor = 0
		O.icon_state = "hsopenl"  //Door stays open
		O.density = 0  //Allows you to walk through it
		//O.opacity = 0  //Allows you to see past it
		//sleep(40)  //Waits a while before shutting the door
		loop                   //creates a tag so I can go back here later
		sleep(40)              //waits 1 second
		if(O.loc == usr.loc) //if the player is still inside the door...
			goto loop          //go to the "loop" tag above
		else   //Waits a while before shutting the door
			O.icon_state = "hsclosedl"
			O.density = 1  //Makes it solid again
		//	O.opacity = 1  //Now you can't see inside it
	//RightDoor
	hopenrcd(obj/hdoors/HRightDoor/O)
		set waitfor = 0
		O.icon_state = "hsopenr"  //Door stays open
		O.density = 0  //Allows you to walk through it
	//	O.opacity = 0  //Allows you to see past it
		//sleep(40)  //Waits a while before shutting the door
		loop                   //creates a tag so I can go back here later
		sleep(40)              //waits 1 second
		if(O.loc == usr.loc) //if the player is still inside the door...
			goto loop          //go to the "loop" tag above
		else   //Waits a while before shutting the door
			O.icon_state = "hsclosedr"
			O.density = 1  //Makes it solid again
	//		O.opacity = 1  //Now you can't see inside it
	//TopDoor
	hopentcd(obj/hdoors/HTopDoor/O)
		set waitfor = 0
		O.icon_state = "hsopent"  //Door stays open
		O.density = 0  //Allows you to walk through it
	//	O.opacity = 0  //Allows you to see past it
		//sleep(40)  //Waits a while before shutting the door
		loop                   //creates a tag so I can go back here later
		sleep(40)              //waits 1 second
		if(O.loc == usr.loc) //if the player is still inside the door...
			goto loop          //go to the "loop" tag above
		else   //Waits a while before shutting the door
			O.icon_state = "hsclosedt"
			O.density = 1  //Makes it solid again
	//		O.opacity = 1  //Now you can't see inside it
	//Door
	hopenbcd(obj/hdoors/HBottomDoor/O)
		set waitfor = 0
		O.icon_state = "hopen"  //Door stays open
		O.density = 0  //Allows you to walk through it
	//	O.opacity = 0  //Allows you to see past it
		//sleep(40)  //Waits a while before shutting the door
		loop                   //creates a tag so I can go back here later
		sleep(40)              //waits 1 second
		if(O.loc == usr.loc) //if the player is still inside the door...
			goto loop          //go to the "loop" tag above
		else   //Waits a while before shutting the door
			O.icon_state = "hclosed"
			O.density = 1  //Makes it solid again
	//		O.opacity = 1  //Now you can't see inside it


	//house doors
	//LeftDoor
	openld(obj/Buildable/Doors/LeftDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "sopenl"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else   //Waits a while before shutting the door
				O.icon_state = "sclosedl"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//RightDoor
	openrd(obj/Buildable/Doors/RightDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "sopenr"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else   //Waits a while before shutting the door
				O.icon_state = "sclosedr"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//TopDoor
	opentd(obj/Buildable/Doors/TopDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "topen"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else   //Waits a while before shutting the door
				O.icon_state = "tclosed"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//Door
	open1(obj/Buildable/Doors/Door/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "open"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else   //Waits a while before shutting the door
				O.icon_state = "closed"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it



	//WHD
	openwhld(obj/Buildable/Doors/WHLeftDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "whdlo"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
		//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else  //Waits a while before shutting the door
				O.icon_state = "whdlc"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//RightDoor
	openwhrd(obj/Buildable/Doors/WHRightDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "whdro"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
		//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else  //Waits a while before shutting the door
				O.icon_state = "whdlc"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//TopDoor
	openwhtd(obj/Buildable/Doors/WHTopDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "whdto"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else
				O.icon_state = "whdtc"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//Door
	openwh1(obj/Buildable/Doors/WHDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "whdo"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else
				O.icon_state = "whdc"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
		if((O.unlocked == 0)&&(O.locked == 1))
			return 0




	//SHD
	openshld(obj/Buildable/Doors/SHLeftDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "shdlo"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else  //Waits a while before shutting the door
				O.icon_state = "shdlc"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//RightDoor
	openshrd(obj/Buildable/Doors/SHRightDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "shdro"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else   //Waits a while before shutting the door
				O.icon_state = "shdrc"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//TopDoor
	openshtd(obj/Buildable/Doors/SHTopDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "shdto"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else   //Waits a while before shutting the door
				O.icon_state = "shdtc"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//Door
	opensh1(obj/Buildable/Doors/SHDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "shdo"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else   //Waits ca while before shutting the door
				O.icon_state = "shdc"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it




	//SD
	opensld(obj/Buildable/Doors/SLeftDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "Ssopenl"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else  //Waits a while before shutting the door
				O.icon_state = "Ssclosedl"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//RightDoor
	opensrd(obj/Buildable/Doors/SRightDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "Ssopenr"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else   //Waits a while before shutting the door
				O.icon_state = "Ssopenr"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//TopDoor
	openstd(obj/Buildable/Doors/STopDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "Stopen"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else   //Waits a while before shutting the door
				O.icon_state = "Stclosed"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//Door
	opens1(obj/Buildable/Doors/SDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "Sopen"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else   //Waits ca while before shutting the door
				O.icon_state = "Sclosed"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it




	//HTD
	openhtld(obj/Buildable/Doors/HTLeftDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "htlopen"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else  //Waits a while before shutting the door
				O.icon_state = "htlclosed"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//RightDoor
	openhtrd(obj/Buildable/Doors/HTRightDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "htropen"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else   //Waits a while before shutting the door
				O.icon_state = "htrclosed"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//TopDoor
	openhttd(obj/Buildable/Doors/HTTopDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "htnopen"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else   //Waits a while before shutting the door
				O.icon_state = "htnclosed"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it
	//Door
	openht1(obj/Buildable/Doors/HTDoor/O)
		set waitfor = 0
		if((O.unlocked == 1)&&(O.locked == 0))
			O.icon_state = "htsopen"  //Door stays open
			O.density = 0  //Allows you to walk through it
	//		O.opacity = 0  //Allows you to see past it
			//sleep(40)  //Waits a while before shutting the door
			loop                   //creates a tag so I can go back here later
			sleep(40)              //waits 1 second
			if(O.loc == usr.loc) //if the player is still inside the door...
				goto loop          //go to the "loop" tag above
			else   //Waits ca while before shutting the door
				O.icon_state = "htsclosed"
				O.density = 1  //Makes it solid again
	//			O.opacity = 1  //Now you can't see inside it