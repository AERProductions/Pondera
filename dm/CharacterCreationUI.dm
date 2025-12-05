/*
	CHARACTER CREATION UI SYSTEM
	
	Modern, modular screen-based replacement for the HTML form system.
	Uses client-level procs to manage the character creation flow.
*/

/client
	var/char_creation_data = list(mode = null, instance = null, char_class = null, gender = null, name = null)

/client/proc/start_character_creation()
	// Initialize character creation data
	char_creation_data = list(mode = null, instance = null, char_class = null, gender = null, name = null)
	show_mode_selection_menu()

/client/proc/show_mode_selection_menu()
	var/result = alert(usr, "How would you like to play?", "Game Mode", "Single Player", "Multi-Player")
	if(result)
		char_creation_data["mode"] = result
		show_instance_selection_menu()

/client/proc/show_instance_selection_menu()
	var/result = alert(usr, "Pick your adventure style:", "Instance", "Sandbox", "Story")
	if(result)
		char_creation_data["instance"] = result
		show_class_selection_menu()

/client/proc/show_class_selection_menu()
	var/result = alert(usr, "Choose your starting class:\n\nLandscaper - Terraform and farm\nSmithing - Master metalworking\nBuilder - Construct magnificent structures", "Class", "Landscaper", "Smithy", "Builder")
	if(result)
		char_creation_data["char_class"] = result
		show_gender_selection_menu()

/client/proc/show_gender_selection_menu()
	var/class_name = char_creation_data["char_class"]
	var/result = alert(usr, "Playing as a [class_name]:\n", "Gender", "Male", "Female")
	if(result)
		char_creation_data["gender"] = result
		show_character_name_input()

/client/proc/show_character_name_input()
	var/name_input = input(usr, "Enter your character's name (3-15 letters):", "Character Name", "")
	if(name_input)
		if(validate_character_name(name_input))
			char_creation_data["name"] = name_input
			show_character_confirmation()
		else
			alert(usr, "Invalid name! Names must be 3-15 characters with letters, no profanity.", "Invalid Name")
			show_character_name_input()

/client/proc/validate_character_name(name)
	// Remove leading/trailing whitespace manually
	while(name && name[1] == " ")
		name = copytext(name, 2)
	while(name && name[length(name)] == " ")
		name = copytext(name, 1, length(name))
	
	if(!name || length(name) < 3 || length(name) > 15)
		return 0
	
	var/ckey_name = ckey(name)
	if(!ckey_name || ckey_name == "")
		return 0
	
	// Would call Review_Name() here if it's in scope
	return 1

/client/proc/show_character_confirmation()
	var/mode = char_creation_data["mode"]
	var/instance = char_creation_data["instance"]
	var/class = char_creation_data["char_class"]
	var/gen = char_creation_data["gender"]
	var/name = char_creation_data["name"]
	
	var/summary = "Character Summary:\n\nName: [name]\nMode: [mode]\nInstance: [instance]\nClass: [class]\nGender: [gen]\n\nReady to create?"
	
	var/result = alert(usr, summary, "Confirm Character", "Create", "Go Back")
	if(result == "Create")
		create_character()
	else
		show_character_name_input()

/client/proc/create_character()
	var/mode = char_creation_data["mode"]
	var/instance = char_creation_data["instance"]
	var/class = char_creation_data["char_class"]
	var/gen = char_creation_data["gender"]
	var/name = char_creation_data["name"]
	
	// Create mob based on class
	var/mob/players/new_mob
	switch(class)
		if("Landscaper")
			new_mob = new /mob/players/Landscaper()
		if("Smithy")
			new_mob = new /mob/players/Smithy()
		if("Builder")
			new_mob = new /mob/players/Builder()
	
	if(!new_mob)
		new_mob = new /mob/players/Landscaper()
	
	new_mob.name = name
	new_mob.color = rgb(rand(100,200), rand(100,200), rand(100,200))
	
	// Set icon state based on gender
	if(gen == "Female")
		switch(class)
			if("Landscaper")
				new_mob.icon_state = "Ffriar"
			if("Smithy")
				new_mob.icon_state = "Ffighter"
			if("Builder")
				new_mob.icon_state = "Ftheurgist"
	
	// Place in starting location
	var/turf/start_loc = locate(/turf/start)
	if(start_loc)
		new_mob.loc = start_loc
	
	// Save settings
	new_mob.base_save_allowed = 1
	new_mob.base_save_location = 1
	
	// Give starting item (if obj/IG exists)
	new /obj/IG(new_mob)
	
	// Print intro
	switch(class)
		if("Landscaper")
			mob << "<font color=silver>You've chosen Landscaper, terraform the wilderness around you!"
		if("Smithy")
			mob << "<font color=silver>You are a Smithy, form metal to your will!"
		if("Builder")
			mob << "<font color=silver>You are a Builder, founding kingdoms with one stone!"
	
	mob << "<font color=#00bfff><center>Information: Arrow/WASD to walk, click/double-click to use or attack."
	
	// Switch client to mob
	mob = new_mob
