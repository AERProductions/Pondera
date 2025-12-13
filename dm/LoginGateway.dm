/*
	LOGIN GATEWAY SYSTEM
	
	Modern login flow that:
	- Gates new character creation on world initialization
	- Integrates character creation UI with initialization checks
	- Provides loading screens while world boots
	
	Called from: client/New() when player connects
*/

/client
	var/char_creation_data = null  // Will be initialized as a list when character creation starts

/client/New()
	..()
	
	// If player has no mob yet, start character creation
	if(!mob)
		show_initialization_check()

/client/proc/show_initialization_check()
	// Check if world is still initializing
	if(!world_initialization_complete)
		// Show loading screen while waiting
		show_loading_screen()
		// Wait for initialization to complete
		spawn while(!world_initialization_complete)
			sleep(10)  // Check every 0.5 seconds
		// Initialization complete, proceed to character creation
		start_character_creation()
	else
		// World already initialized, go straight to character creation
		start_character_creation()

/client/proc/show_loading_screen()
	var/loading_msg = {"
	<html>
	<head>
		<style>
			body {
				background-color: #1a1a2e;
				color: #ffffff;
				font-family: Arial, sans-serif;
				display: flex;
				justify-content: center;
				align-items: center;
				height: 100vh;
				margin: 0;
			}
			.loader {
				text-align: center;
			}
			h1 {
				font-size: 2.5em;
				margin-bottom: 20px;
				color: #00bfff;
			}
			.spinner {
				border: 4px solid #00bfff;
				border-top: 4px solid #ffffff;
				border-radius: 50%;
				width: 50px;
				height: 50px;
				animation: spin 1s linear infinite;
				margin: 0 auto 20px;
			}
			@keyframes spin {
				0% { transform: rotate(0deg); }
				100% { transform: rotate(360deg); }
			}
			.status {
				font-size: 1.2em;
				color: #cccccc;
				margin-top: 20px;
			}
		</style>
	</head>
	<body>
		<div class="loader">
			<h1>Pondera Online</h1>
			<div class="spinner"></div>
			<div class="status">
				Initializing world...<br>
				Please wait
			</div>
		</div>
	</body>
	</html>
	"}
	
	src << browse(loading_msg, "window=loading;size=600x400;can_close=0;can_minimize=0")

/client/proc/start_character_creation()
	// Close loading screen if it was shown
	winshow(src, "loading", 0)
	
	// Initialize character creation data
	char_creation_data = list(mode = null, instance = null, char_class = null, gender = null, name = null)
	show_mode_selection_menu()

/client/proc/show_mode_selection_menu()
	var/result = alert(usr, "How would you like to play?", "Game Mode", "Single Player", "Multi-Player")
	if(result)
		char_creation_data["mode"] = result
		show_instance_selection_menu()
	else
		// If user cancels, wait and retry (they must pick a mode)
		spawn(10) show_mode_selection_menu()

/client/proc/show_instance_selection_menu()
	var/result = alert(usr, "Pick your adventure style:\n\nSandbox - Peaceful creative building\nStory - Progression with NPCs and quests\nKingdom PVP - Competitive raids and warfare", "Instance", "Sandbox", "Story", "Kingdom PVP")
	if(result)
		char_creation_data["instance"] = result
		show_class_selection_menu()
	else
		spawn(10) show_instance_selection_menu()

/client/proc/show_class_selection_menu()
	var/result = alert(usr, "Choose your starting class:\n\nLandscaper - Master of nature and farming\nSmithing - Master of metalworking\nBuilder - Master of construction", "Class", "Landscaper", "Smithy", "Builder")
	if(result)
		char_creation_data["char_class"] = result
		show_gender_selection_menu()
	else
		spawn(10) show_class_selection_menu()

/client/proc/show_gender_selection_menu()
	var/class_name = char_creation_data["char_class"]
	var/result = alert(usr, "Playing as a [class_name]:\n\nChoose your appearance:", "Gender", "Male", "Female")
	if(result)
		char_creation_data["gender"] = result
		show_character_name_input()
	else
		spawn(10) show_gender_selection_menu()

/client/proc/show_character_name_input()
	var/name_input = input(usr, "Enter your character's name (3-15 letters, no spaces):", "Character Name", "")
	if(name_input)
		if(validate_character_name(name_input))
			char_creation_data["name"] = name_input
			show_character_confirmation()
		else
			alert(usr, "Invalid name! Names must be 3-15 characters with letters only.", "Invalid Name")
			show_character_name_input()
	else
		spawn(10) show_character_name_input()

/client/proc/validate_character_name(name)
	// Remove leading/trailing whitespace
	while(name && name[1] == " ")
		name = copytext(name, 2)
	while(name && name[length(name)] == " ")
		name = copytext(name, 1, length(name))
	
	if(!name || length(name) < 3 || length(name) > 15)
		return 0
	
	// Check if name only contains letters
	var/valid_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	for(var/i = 1, i <= length(name), i++)
		if(!(name[i] in valid_chars))
			return 0
	
	return 1

/client/proc/show_character_confirmation()
	var/mode = char_creation_data["mode"]
	var/instance = char_creation_data["instance"]
	var/class = char_creation_data["char_class"]
	var/gen = char_creation_data["gender"]
	var/name = char_creation_data["name"]
	
	var/summary = "Character Summary:\n\nName: [name]\nClass: [class]\nGender: [gen]\nGamemode: [instance] ([mode])\n\nReady to create?"
	
	var/result = alert(usr, summary, "Confirm Character", "Create", "Go Back")
	if(result == "Create")
		create_character()
	else
		show_character_name_input()

/client/proc/create_character()
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
	new_mob.key = src.key  // Assign client to mob
	
	// Set icon state based on gender and class (simple implementation)
	if(gen == "Female")
		switch(class)
			if("Landscaper")
				new_mob.icon_state = "Landscaper"  // Adjust if you have female variants
			if("Smithy")
				new_mob.icon_state = "fighter"
			if("Builder")
				new_mob.icon_state = "theurgist"
	
	// Place in starting location (safe zone)
	new_mob.loc = locate(5, 5, 1)  // Adjust coordinates as needed for your map
	new_mob.location = "Starting Area"
	
	// Initialize character data if not already done
	if(!new_mob.character)
		new_mob.character = new /datum/character_data()
	
	// Save initial character state
	new_mob.base_save_allowed = 1
	
	// Give starting item
	new /obj/IG(new_mob)
	
	// Print intro message
	new_mob << "<font color=#00bfff><center><b>Welcome to Pondera Online!</b>"
	switch(class)
		if("Landscaper")
			new_mob << "<font color=silver>You've chosen Landscaper, terraform the wilderness around you!"
		if("Smithy")
			new_mob << "<font color=silver>You are a Smithy, master the forge and create legendary weapons!"
		if("Builder")
			new_mob << "<font color=silver>You are a Builder, erect magnificent structures that stand the test of time!"
	
	new_mob << "<font color=#00bfff>Arrow Keys or WASD to move • Click to interact • Right-click for menu"
	new_mob << "<font color=#90EE90>Type /help for a list of commands"
