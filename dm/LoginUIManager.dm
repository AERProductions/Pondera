// LoginUIManager.dm - Modern class selection system
// Integrated character class selection with stat bonuses

/datum/login_ui
	var/mob/players/player = null
	var/character_initialized = FALSE
	var/show_feedback = TRUE  // Display bonus feedback messages

/datum/login_ui/New(mob/players/player_ref)
	player = player_ref

/datum/login_ui/proc/ShowClassPrompt()
	// Display class selection and apply bonuses
	if(!player) return
	
	player << "\n========== CHARACTER CLASS SELECTION ==========\n"
	
	var/class_choice = input(player, "Select your starting class:\n\nWarrior: Strong fighter, +50 HP, +2 building, +1 smithing\nScout: Swift archer, +50 stamina, +2 fishing\nMage: Clever spellcaster, +2 crafting\nCrafter: Master builder, +3 building, +2 smithing, +2 crafting\nNaturalist: Nature keeper, +3 gardening, +2 mining", "Class Selection") in list("Warrior", "Scout", "Mage", "Crafter", "Naturalist", "Skip")
	
	if(!class_choice)
		player << "Class selection cancelled."
		return
	
	if(class_choice == "Skip")
		player << "Class selection skipped. You can choose a class later."
		return
	
	ApplyClassStats(player, class_choice)
	player.character.selected_class = class_choice
	character_initialized = TRUE
	
	player << "Selected: [class_choice]!"
	player << "================================================\n"

/datum/login_ui/proc/ApplyClassStats(mob/players/player, class_name)
	// Apply class-specific starting stats and bonuses
	if(!player) return
	if(!player.character) return
	
	var/starting_hp = 100
	var/starting_stamina = 100
	var/feedback = ""
	
	switch(class_name)
		if("Warrior")
			starting_hp = 150
			starting_stamina = 80
			player.character.brank = max(player.character.brank, 2)
			player.character.smirank = max(player.character.smirank, 1)
			feedback = "Warrior: +50 HP (150), -20 stamina (80), Building +2, Smithing +1"
		
		if("Scout")
			starting_hp = 80
			starting_stamina = 150
			player.character.frank = max(player.character.frank, 2)
			feedback = "Scout: -20 HP (80), +50 stamina (150), Fishing +2"
		
		if("Mage")
			starting_hp = 90
			starting_stamina = 120
			player.character.crank = max(player.character.crank, 2)
			feedback = "Mage: -10 HP (90), +20 stamina (120), Crafting +2"
		
		if("Crafter")
			starting_hp = 100
			starting_stamina = 100
			player.character.brank = max(player.character.brank, 3)
			player.character.smirank = max(player.character.smirank, 2)
			player.character.crank = max(player.character.crank, 2)
			feedback = "Crafter: Building +3, Smithing +2, Crafting +2"
		
		if("Naturalist")
			starting_hp = 100
			starting_stamina = 100
			player.character.grank = max(player.character.grank, 3)
			player.character.mrank = max(player.character.mrank, 2)
			feedback = "Naturalist: Gardening +3, Mining +2"
	
	// Apply HP/stamina (only if at default values)
	if(player.HP <= 0 || player.HP == 100)
		player.HP = starting_hp
		player.MAXHP = starting_hp
	
	if(player.stamina <= 0 || player.stamina == 100)
		player.stamina = starting_stamina
		player.MAXstamina = starting_stamina
	
	// Log to world for admin visibility
	var/log_msg = "CLASS_SELECT: [player.name] selected [class_name]: [feedback]"
	world.log << log_msg
	
	if(show_feedback && player)
		player << feedback


