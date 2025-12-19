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
	
	// Store the chosen class and gender in player
	player.char_class = char_data["class"]
	player.gender = char_data["gender"]
	
	world.log << "\[CHARGEN\] Character finalized: name=[player.name] class=[char_data["class"]] gender=[char_data["gender"]]"
	
	// Initialize character data if not already done
	if(!player.character)
		player.character = new /datum/character_data()
		player.character.Initialize()
	
	// Set player as fully logged in
	player.base_save_allowed = 1
	
	// Initialize HUD BEFORE showing welcome messages
	InitializePlayerHUD(player)
	
	// Give starting item
	new /obj/IG(player)
	
	// Print intro message
	player << "<font color=#00bfff><center><b>Welcome to Pondera Online!</b>"
	switch(char_data["class"])
		if("Landscaper")
			player << "<font color=silver>You've chosen Landscaper, terraform the wilderness around you!"
		if("Smithly")
			player << "<font color=silver>You are a Smith, master the forge and create legendary weapons!"
		if("Builder")
			player << "<font color=silver>You are a Builder, erect magnificent structures that stand the test of time!"
	
	player << "<font color=#00bfff>Arrow Keys or WASD to move • Click to interact • Right-click for menu"
	player << "<font color=#90EE90>Type /help for a list of commands"
