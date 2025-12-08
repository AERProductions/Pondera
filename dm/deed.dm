
region
	//saveable = TRUE


	deed//a region of deeded land that displays the deed name when entered and exited. Region class requires Forum_Account's Regions library.
		saveable = TRUE
		//density = 0
		name = ""//deed name variable

		var //some of these might not be needed
			owner = ""
			zonex = 10
			zoney = 10
			list/deedallow[0]
			list/deedbuild[0]
			list/deedpickup[0]
			list/deeddrop[0]
			list/deedowner["owner"]
			list/deedname["name"]
			obj/DeedToken/dt//defining a reference

		Entered(mob/players/m)//When a mob is detected entering this region
			dt = locate() in oview(10)//locate a Deed Token in oview of this region
			//grantpermissions(m)//grant the user entering permissions set in the deed token
			if(dt)
				for(src)//for the deed token, we're setting deed variables by using the tokens reference variables
					src:name = dt.name
					src:owner = dt.owner
					src.deedallow = dt.deedallow
					src.deedowner = dt.deedowner
					src.deedname = dt.deedname
			if(istype(m,/mob/players))
				//var/a = deedallow.Find(ckey(m.key))

				var/o = src.deedowner["owner"]
				var/n = src.deedname["name"]
				if(m.permallow==0)//if this user that is entering doesn't have permissions of the deed allowed (they're not on the allow list)

					m << "[o]'s claim: [n] has restricted permissions."//notifying users that they are not on the allow list
					m:canbuild = 0//set the variables to disabled
					m:canpickup = 0
					m:candrop = 0
					return
				else//if they are on the allow list
					if(m.permallow==1)//double check
						m:canbuild = 1//set the variables to disabled
						m:canpickup = 1
						m:candrop = 1
						//for(dt)//setting the deed variables using the reference variables of the token
						//	src:name = dt.name
						//	src:owner = dt.owner
						m << "You entered [o]'s claim:  [n]."//notifying the user that they are on the allow list


		Exited(mob/players/m)//if this user has exited this region, notify them
			//var/owner = deedowner.Find(ckey(M.key))
			if(dt)
				for(src)//for the deed token, we're setting deed variables by using the tokens reference variables
					src:name = dt.name
					src:owner = dt.owner
					src.deedallow = dt.deedallow
					src.deedowner = dt.deedowner
					src.deedname = dt.deedname
			if(istype(m,/mob/players))
				//var/a = deedallow.Find(ckey(m.key))
				var/o = src.deedowner["owner"]
				var/n = src.deedname["name"]
				m << "You left [o]'s claim: [n]."

		New()
			..()
			DeedCheck()

		proc
			DeedCheck()
				dt = locate() in oview(10, src)//locate a Deed Token in oview of this region
				if(dt)
					for(dt)//when this region is created, check the deed token that creates it for information
						src:name = dt.name
						//src:owner = dt.owner
						src.deedallow = dt.deedallow
						src.deedowner = dt.deedowner
						src.deedname = dt.deedname

			revokepermissions(mob/players/M)//revoke permissions proc for the permissions menu
				usr << "Permissions have been revoked."
				if(deedallow.Find(ckey(M.key)))//find the users ckey/key in the deed allow list
					M:permallow = 0
					M:canbuild = 0//set the variables to disabled
					M:canpickup = 0
					M:candrop = 0
					src:deedallow.Remove(ckey(M.key))//remove this user from the allow list

			grantpermissions(mob/players/M)//grant permissions proc for the permissions menu
				if(M.permallow==1&&!deedallow.Find(ckey(M.key)))//if they are permissions allowed but you can't find them in the list
					deedallow.Add(ckey(M.key))
					M:canbuild = 1//enable the variables
					M:canpickup = 1
					M:candrop = 1
				else
					if(deedallow.Find(ckey(M.key))&&M.permallow==0)//if you can find their key in the list but they are not permissions allowed
						M << "You are on the list!"
						M:permallow = 1//Set the variable to enabled, because if they are in the list, they are being granted permissions
						M:canbuild = 1
						M:canpickup = 1
						M:candrop = 1
						return
					else
						if(M.permallow==0&&!deedallow.Find(ckey(M.key)))//if they are not allowed permissions and they are also not in the list, disable permissions
							M << "You are not on the Deed's allow list."
							M:canbuild = 0
							M:canpickup = 0
							M:candrop = 0
							return




turf
	var/landclaimed = 0//a turf variable for setting if the land has been claimed or not


obj
	DeedToken//Deed Token object that create the deed region and facilitates handling the permissions
		var
			zonex = 10
			zone = 10
			owner = ""
			permallow = 0
			list/deedallow[0]
			list/deedowner["owner"]
			list/deedname["name"]

		name = ""
		density = 1
		var/description = "A witness for Land Claims."
		icon = 'dmi/64/anctxt.dmi'
		icon_state = "token"

		var/turf/t


		New()
			..()//somehow just need to get the deed region to be persistent across save/reboot
			//var/DO = ckey(usr.key)
			//var/region/deed/deed = locate(oview(src,10))
			//if(!deed)
			deed()//run the deed region creation proc when this deed token is created
			
			// Ensure deed manager is initialized before registering
			if(!g_deed_manager_initialized)
				EnsureDeedManagerInitialized()
			
			RegisterDeedToken(src)  // Register with DeedDataManager for central access
			//if(!src)
			//for(src)
			//if(src:name == null)
			//naming
			//var/enter_dname = input("Deed Name","Name Deed",src.name) as text|null//allow user to name the deed, but filter the name using Yash69's Name Filter library
			//if(Review_Name(enter_dname))
			//	goto naming
			//src:name = enter_dname
			//if(src:owner == null)
			//	src:owner = "[usr.key]"//the owner of these objects are the creator of them

		Del()
			UnregisterDeedToken(src)  // Unregister from DeedDataManager on deletion
			..()

		proc
			revokepermissions(mob/players/M)
				usr << "Permissions have been revoked."
				if(deedallow.Find(ckey(M.key)))
					M:permallow = 0
					M:canbuild = 0
					M:canpickup = 0
					M:candrop = 0
					src:deedallow.Remove(ckey(M.key))

			grantpermissions(mob/players/M)
				if(M.permallow==1&&!deedallow.Find(ckey(M.key)))
					M:canbuild = 1
					M:canpickup = 1
					M:candrop = 1
				else
					if(deedallow.Find(ckey(M.key))&&M.permallow==0)
						M << "You are on the list!"
						M:permallow = 1
						M:canbuild = 1
						M:canpickup = 1
						M:candrop = 1
						return
					else
						if(M.permallow==0&&!deedallow.Find(ckey(M.key)))
							M << "You are not on the Deed's allow list."
							M:canbuild = 0
							M:canpickup = 0
							M:candrop = 0
							return
		proc
			deed()
				var/region/deed/D
				D = locate(obounds(10))
				//for(t in oview(10))
					//new /region/deed(t)//creates the deed region that sets the zone
				if(!D)
					for(t in oview(10))
						new /region/deed(t)//creates the deed region that sets the zone
			check()
				var/region/deed/D
				D = locate(obounds(10))
				if(D)
					for(D)//when this region is created, check the deed token that creates it for information
						D:name = src.name
						//src:owner = dt.owner
						D:deedallow = src.deedallow
						D:deedowner = src.deedowner
						D:deedname = src.deedname

		Click()//click activated that calls the verb for extra filtration rather than embedding the manage proc in the click
			var/mob/players/M
			M = usr
			if(M.deedopen==1)//checking if the land claim menu is already open
				return//if it is, return so they can't open it again
			else//otherwise
				Manage()//call the Manage verb
				deed()//											the hacky way to fix deed region not being persistent, not ideal, is temporary
				check()

		verb/Manage()//Manage Deed and Permissions menu
			var/mob/players/M
			M = usr

			START
			M.deedopen=1//set this deed to open
			switch(input("Land Deed","Deed Land") in list("Manage Deed","Set Permissions","Close"))//Open the menu and offer the choices
				if("Close")
					M.deedopen=0

					return
				if("Manage Deed")

					switch(input("Manage Deed","Deed Management") in list("Rename Deed",/*"Expand Deed","Remove Claim"*/,"Close","Back"))//The two commented out options are things that I am working on but designed out for now
						if("Close")
							M.deedopen=0//If they close the menu, disable this so they can open it again

							return
						if("Back") goto START//If they select to go back a menu, send them to the main menu
						if("Rename Deed")//if they select the rename deed option, run the menu for it -- the rest explains itself
							switch(input("Rename Claim","Do you want to Rename this Claim? [src.name]") in list("Yes","No","Close","Back"))
								if("Yes")
									switch(input("Confirm","This will Rename your Claim, are you Sure? [src.name]") in list("Yes","No","Close","Back"))
										if("Yes")
											var/RN = input("Set Name","Set Name", src.name)//sets the name they input
											if(RN)
												if(deedowner.Find(ckey(M.key)))//checking if the owner is the user
													del deedname

													src:name = "[RN]"//setting the name to what they chose
													deedname["name"] = "[RN]"
													//deedname.Add("[RN]")
													M.deedopen=0
													return//close the menu out
												else
													if(!deedowner.Find(ckey(M.key)))//if the owner doesn't match up with the user, they must not be the owner!
														usr << "This is not your claim!"//block em
														M.deedopen=0
														return
										if("No") goto START
										if("Close")
											M.deedopen=0
											return
										if("Back") goto START
								if("No") goto START
								if("Close")
									M.deedopen=0

									return
								if("Back") goto START

				if("Set Permissions")//Permissions menu
					switch(input("Set Permissions","Set Permissions") in list("Grant Permission","Revoke Permission"))//"Open Access","Limited Access","Building Allow","Pickup Allow","Drop Allow","Close","Back"))
						if("Close")
							M.deedopen=0
							return
						if("Back") goto START

						if("Grant Permission")//If you want to grant someone permissions
							var/list/J = list()
							for(var/mob/P as mob in view(10)) // only people you can SEE
								if(istype(P,/mob/players)) // PEOPLE you can see
									J += P
							
							if(J.len >= 1)
								var/mob/selected = input("Grant Permission","Who") as anything in J
								if(selected)
									if (istype(selected,/mob/players))
										selected:permallow = 1
										if(selected:permallow == 1)
											deedallow.Add(ckey(selected.key))
											selected:canbuild = 1
											selected:candrop = 1
											selected:canpickup = 1
											selected << "You have been granted deed permissions."
										else
											selected:canbuild = 0
											selected:candrop = 0
											selected:canpickup = 0
											deedallow.Remove(ckey(selected.key))
										selected:deedopen = 0
										return
							else
								usr << "No players in view."
								usr:deedopen = 0
								return

						if("Revoke Permission")
							var/list/J[1]
							var/C = 1
							for(M as mob in view(10))
								if(src:deedallow.Find(ckey(M.key))) // only people in the list
									if(istype(M,/mob/players)) // if a player
										J[C] = M.key
										C++
										J.len++
										if(J.len >=1)//checking if the list contents is greater than or equal to 1

											var/ST = input("Revoke Permission","Who") as anything in J//If it is greater than or equal to 1, return a list of options

											if(ST)//works but could probably be done better
												if (istype(M,/mob/players))
													if(M.permallow == 1)
														M:permallow = 0
														M:canbuild = 0
														M:candrop = 0
														M:canpickup = 0
														M.deedopen=0
														if(src:deedallow.Find(ckey(M.key)))
															src:deedallow.Remove(ckey(M.key))
														else return
														usr << "You have revoked [ckey(M.key)] permissions."
														return
													else
														M:permallow = 0
														M:canbuild = 0
														M:candrop = 0
														M:canpickup = 0
														M.deedopen=0
														return
										else
											M.deedopen=0
											return





//start Land Deed Scrolls

	Deed//Land deed

		name = "Land Deed"
		var/description = "A scroll for claiming land."
		icon = 'dmi/64/at32.dmi'
		icon_state = "deed"
		var/deedused = 0
		var/mob/players/M

		Click()
			M = usr
			if(src.deedused == 1)//if you've already used this deed, you can't use it again
				M << "This deed has already been used."
				return
			else if(M.deedopen==1)//if it is open, return so they can't open it more than once
				return
			else
				ClaimLand()//otherwise run the claim land verb

		verb/ClaimLand()
			set waitfor = 0
			//set popup_menu = 1
			set hidden = 1
			////set category = "Commands"
			set src in usr
			var/mob/players/M
			M = usr
			var/obj/DeedToken/dt
			var/turf/t = locate(obounds(10))
			M.deedopen=1//if this menu is open
			if(M.deedopen==1)//set the icon state to reflect that
				src:icon_state = "deed"
			else while(M.deedopen==1)//otherwise show it closed
				if(M.deedopen==0)
					src:icon_state = "stow"

			START
			switch(input("Land Deed","Deed Land") in list("Claim Land","Close"))//Land Claim menu
				if("Close")
					M.deedopen=0
					if(M.deedopen==0)
						src:icon_state = "stow"//show the closed graphics and notify them of their choice
					sleep(1)
					M << "<font color=#FFFB98>You stow the deed scroll..."
					return

				if("Claim Land")//Claim land option
					M.deedopen=1
					if(src.deedused==1)
						M << "This deed has already been used."
						return
					else
						switch(input("Claim Land?","Select Response") in list("Yes","No","Close","Back"))
							if("Close")
								M.deedopen=0
								if(M.deedopen==0)
									src:icon_state = "stow"
								sleep(1)
								M << "<font color=#FFFB98>You stow the deed scroll..."
								return
							if("Back") goto START

							if("Yes")//If they chose to claim the land they stand on
								if(dt in oview(usr,10))
									M << "These lands are already claimed."//If they're already claim, you can't claim them again
									return
								else if(src.deedused==0)
									M << {"<font color=#FFFB98><left>You place a Land Claim in this area."}//If the deed hasn't been used and the land is not claimed, they can claim it
									for(t)
										t:landclaimed=1
									new dt(usr.loc)//Creates a new deed token which handles creating the region and the zone permissions
									
									dt = locate() in oview(10)//locate a Deed Token in oview of this region
									for(dt)
										if(istype(dt,/obj/DeedToken))
											naming
											var/enter_dname = input("Deed Name","Name Deed",dt:name) as text|null//allow user to name the deed, but filter the name using Yash69's Name Filter library
											if(Review_Name(enter_dname))
												goto naming
											dt:name = enter_dname
											dt:owner = "[M.key]"
											dt:deedname["name"] = "[enter_dname]"
											dt:deedowner["owner"] = "[ckey(M.key)]"
											dt:deedallow.Add(ckey(M.key))
											M:permallow=1
											M:canbuild = 1
											M:candrop = 1
											M:canpickup = 1
											//call(/obj/DeedToken/proc/grantpermissions)(usr)
									src.deedused=1

									M.deedopen=0
									if(M.deedopen==0)
										src:icon_state = "stow"
									sleep(1)
									return

							if("No")//If no, same as closed, close it.
								M << "<font color=#FFFB98>You stow the deed scroll..."
								M.deedopen=0
								if(M.deedopen==0)
									src:icon_state = "stow"
								sleep(1)
								return




