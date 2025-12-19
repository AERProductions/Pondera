/**
 * CHARACTER CREATION GUI - Follows Recoded Hud pattern
 * Icon-based screen objects positioned around the map
 */

/obj/ChargenHud
	parent_type = /obj
	layer = FLY_LAYER

	ClassLandscaper
		name = "Landscaper"
		icon = 'dmi/64/char.dmi'
		icon_state = "Ffriar"
		screen_loc = "CENTER-4,CENTER+3"
		mouse_opacity = 1
		
		Click()
			if(usr && istype(usr, /mob/players))
				var/mob/players/player = usr
				player.chargen_data["class"] = "Landscaper"
				ShowCharCreationStep2(player)

	ClassSmithly
		name = "Smithly"
		icon = 'dmi/64/char.dmi'
		icon_state = "Ffriar"
		screen_loc = "CENTER+4,CENTER+3"
		mouse_opacity = 1
		
		Click()
			if(usr && istype(usr, /mob/players))
				var/mob/players/player = usr
				player.chargen_data["class"] = "Smithly"
				ShowCharCreationStep2(player)

	GenderMale
		name = "Male"
		icon = 'dmi/64/char.dmi'
		icon_state = "Ffriar"
		screen_loc = "CENTER-2,CENTER+3"
		mouse_opacity = 1
		
		Click()
			if(usr && istype(usr, /mob/players))
				var/mob/players/player = usr
				player.chargen_data["gender"] = "Male"
				ShowCharCreationStep3(player)

	GenderFemale
		name = "Female"
		icon = 'dmi/64/char.dmi'
		icon_state = "Ffriar"
		screen_loc = "CENTER+2,CENTER+3"
		mouse_opacity = 1
		
		Click()
			if(usr && istype(usr, /mob/players))
				var/mob/players/player = usr
				player.chargen_data["gender"] = "Female"
				ShowCharCreationStep3(player)

	ConfirmCharacter
		name = "Confirm"
		icon = 'dmi/64/char.dmi'
		icon_state = "Ffriar"
		screen_loc = "CENTER,CENTER+3"
		mouse_opacity = 1
		
		Click()
			if(usr && istype(usr, /mob/players))
				var/mob/players/player = usr
				if(player.chargen_data["class"] && player.chargen_data["gender"])
					ApplyCharacterCreation(player, player.chargen_data)
					ClearChargenGUI(player)

/proc/ShowCharacterCreationGUI(mob/players/player)
	if(!player || !player.client) return
	player.chargen_data = list("class" = null, "gender" = null)
	ShowCharCreationStep1(player)

/proc/ShowCharCreationStep1(mob/players/player)
	if(!player || !player.client) return
	ClearChargenGUI(player)
	
	player.client.screen += new/obj/ChargenHud/ClassLandscaper()
	player.client.screen += new/obj/ChargenHud/ClassSmithly()

/proc/ShowCharCreationStep2(mob/players/player)
	if(!player || !player.client) return
	ClearChargenGUI(player)
	
	player.client.screen += new/obj/ChargenHud/GenderMale()
	player.client.screen += new/obj/ChargenHud/GenderFemale()

/proc/ShowCharCreationStep3(mob/players/player)
	if(!player || !player.client) return
	ClearChargenGUI(player)
	
	player.client.screen += new/obj/ChargenHud/ConfirmCharacter()

/proc/ClearChargenGUI(mob/players/player)
	if(!player || !player.client) return
	for(var/obj/ChargenHud/obj in player.client.screen)
		player.client.screen -= obj
		del(obj)

/proc/ApplyCharacterCreation(mob/players/player, list/char_data)
	if(!player) return
	world.log << "\[CHARGEN\] Character finalized: class=[char_data["class"]] gender=[char_data["gender"]]"
	// Character now ready to interact with world/portals
