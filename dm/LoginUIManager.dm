// LoginUIManager.dm - Modern class selection system
// Simple overlay-based class selection that applies stat bonuses to new characters

/datum/login_ui
	var/mob/players/player = null
	var/character_initialized = FALSE

/datum/login_ui/New(mob/players/player_ref)
	player = player_ref

/datum/login_ui/proc/ShowClassPrompt()
	// Display class selection and apply bonuses
	if(!player) return
	
	var/class_choice = input(player, "Select your starting class:\n\nWarrior - +50 HP, +2 building\nScout - +50 stamina, +2 fishing\nMage - +2 crafting\nCrafter - +3 building, +2 smithing, +2 crafting\nNaturalist - +3 gardening, +2 mining", "Class Selection") in list("Warrior", "Scout", "Mage", "Crafter", "Naturalist", "Skip")
	
	if(!class_choice || class_choice == "Skip")
		return
	
	ApplyClassStats(player, class_choice)
	player.character.selected_class = class_choice
	character_initialized = TRUE

/datum/login_ui/proc/ApplyClassStats(mob/players/player, class_name)
	// Apply class-specific starting stats
	if(!player) return
	if(!player.character) return
	
	var/starting_hp = 100
	var/starting_stamina = 100
	
	switch(class_name)
		if("Warrior")
			starting_hp = 150
			starting_stamina = 80
			player.character.brank = max(player.character.brank, 2)
			player.character.smirank = max(player.character.smirank, 1)
			player << output("Warrior bonus applied: +50 HP, +2 building rank", "message_output")
		
		if("Scout")
			starting_hp = 80
			starting_stamina = 150
			player.character.frank = max(player.character.frank, 2)
			player << output("Scout bonus applied: +50 stamina, +2 fishing rank", "message_output")
		
		if("Mage")
			starting_hp = 90
			starting_stamina = 120
			player.character.crank = max(player.character.crank, 2)
			player << output("Mage bonus applied: +2 crafting rank", "message_output")
		
		if("Crafter")
			starting_hp = 100
			starting_stamina = 100
			player.character.brank = max(player.character.brank, 3)
			player.character.smirank = max(player.character.smirank, 2)
			player.character.crank = max(player.character.crank, 2)
			player << output("Crafter bonus applied: +3 building, +2 smithing, +2 crafting", "message_output")
		
		if("Naturalist")
			starting_hp = 100
			starting_stamina = 100
			player.character.grank = max(player.character.grank, 3)
			player.character.mrank = max(player.character.mrank, 2)
			player << output("Naturalist bonus applied: +3 gardening, +2 mining", "message_output")
	
	// Apply HP/stamina if not yet customized
	if(player.HP <= 0 || player.HP == 100)
		player.HP = starting_hp
		player.MAXHP = starting_hp
	
	if(player.stamina <= 0 || player.stamina == 100)
		player.stamina = starting_stamina
		player.MAXstamina = starting_stamina

// ============================================================================
// END OF LOGIN UI MANAGER
// ============================================================================

