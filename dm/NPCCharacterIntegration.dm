// NPCCharacterIntegration.dm - Unified NPC Character Data System
// Migrates all scattered NPC variables to the centralized character_data datum
// Enables persistent NPC state, skill progression, and unified teaching system
// Date: December 8, 2025

// ============================================================================
// MOB/NPCS EXTENSION - Add character_data to all NPCs
// ============================================================================

/mob/npcs
	var/datum/character_data/character = null  // Unified character data for NPCs

// ============================================================================
// NPC INITIALIZATION SYSTEM - Create unified NPC character data on spawn
// ============================================================================

/mob/npcs/New()
	. = ..()
	
	// Initialize character data for this NPC based on their type
	character = new /datum/character_data()
	
	// Determine NPC type and initialize skills accordingly
	var/npc_type_name = GetNPCType()
	if(npc_type_name)
		character.InitializeAsNPC(npc_type_name)
	
	// Ensure recipe state is initialized
	if(!character.recipe_state)
		character.recipe_state = new /datum/recipe_state()
		character.recipe_state.SetRecipeDefaults()

// ============================================================================
// NPC TYPE DETECTION - Identify NPC type from mob name/icon
// ============================================================================

/mob/npcs/proc/GetNPCType()
	// Map NPC names to their types for skill initialization
	var/npc_name = src.name
	
	switch(npc_name)
		if("Traveler")
			return "Traveler"
		if("Elder")
			return "Elder"
		if("Veteran")
			return "Veteran"
		if("Warrior")
			return "Warrior"
		if("Scribe")
			return "Scribe"
		if("Proctor")
			return "Proctor"
		if("Artisan")
			return "Artisan"
		if("Craftsman")
			return "Craftsman"
		if("Builder")
			return "Builder"
		if("Lumberjack")
			return "Lumberjack"
	
	return ""

// ============================================================================
// NPC SKILL ACCESS METHODS - Unified skill rank accessors for NPCs
// ============================================================================

/mob/npcs/proc/GetNPCRankLevel(rank_type)
	// Get NPC skill rank level using unified system
	if(!character) return 0
	return character.GetRankLevel(rank_type)

/mob/npcs/proc/SetNPCRankLevel(rank_type, level)
	// Set NPC skill rank level using unified system
	if(!character) return
	character.SetRankLevel(rank_type, level)

/mob/npcs/proc/UpdateNPCRankExp(rank_type, exp_gain)
	// Update NPC skill experience using unified system
	if(!character) return
	character.UpdateRankExp(rank_type, exp_gain)

// ============================================================================
// NPC RECIPE TEACHING SYSTEM - Unified NPC recipe teaching procs
// ============================================================================

/mob/npcs/proc/TeachRecipeToPlayer(mob/players/M, recipe_name)
	// Teach a specific recipe to a player
	if(!character || !M) return FALSE
	
	// Check if this NPC can teach this recipe
	if(!character.CanTeachRecipe(recipe_name))
		return FALSE
	
	// Unlock recipe for player
	if(M.character && M.character.recipe_state)
		M.character.recipe_state.DiscoverRecipe(recipe_name)
		return TRUE
	
	return FALSE

/mob/npcs/proc/TeachKnowledgeToPlayer(mob/players/M, knowledge_topic)
	// Teach a knowledge topic to a player
	if(!character || !M) return FALSE
	
	// Check if this NPC can teach this knowledge
	if(!character.CanTeachKnowledge(knowledge_topic))
		return FALSE
	
	// Unlock knowledge for player
	if(M.character && M.character.recipe_state)
		M.character.recipe_state.LearnTopic(knowledge_topic)
		return TRUE
	
	return FALSE

/mob/npcs/proc/HasTaughtPlayer(player_ckey)
	// Check if this NPC has taught a specific player
	if(!character) return FALSE
	return character.HasTaughtPlayer(player_ckey)

/mob/npcs/proc/MarkPlayerTaught(player_ckey)
	// Record that this NPC taught a player
	if(!character) return
	character.MarkPlayerTaught(player_ckey)

// ============================================================================
// NPC RECIPE DIALOG INTEGRATION - Update existing recipe dialogs to use unified system
// ============================================================================

/proc/TravelerRecipeDialogUnified(mob/players/M, mob/npcs/npc)
	// Unified Traveler recipe teaching using character data
	if(!M || !npc || !npc.character) return
	
	var/choice = input(M, "What would you like to learn?", "Learn from Traveler") in list(
		"Fishing Basics", 
		"Plant Gathering", 
		"Trading Tips", 
		"Never Mind"
	)
	
	switch(choice)
		if("Fishing Basics")
			if(npc.TeachRecipeToPlayer(M, "fishing_pole"))
				M << "<font color=#57FF00>The Traveler teaches you about fishing poles!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already know how to make fishing poles.</font>"
		
		if("Plant Gathering")
			if(npc.TeachRecipeToPlayer(M, "plant_gathering"))
				M << "<font color=#57FF00>The Traveler teaches you how to safely gather plants!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already know how to gather plants.</font>"
		
		if("Trading Tips")
			if(npc.TeachKnowledgeToPlayer(M, "trading_basics"))
				M << "<font color=#57FF00>The Traveler shares trading wisdom with you!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already understand trading basics.</font>"

/proc/ElderRecipeDialogUnified(mob/players/M, mob/npcs/npc)
	// Unified Elder recipe teaching using character data
	if(!M || !npc || !npc.character) return
	
	var/choice = input(M, "What would you like to learn?", "Learn from Elder") in list(
		"Survival Basics", 
		"Resource Management", 
		"Building Shelter", 
		"Never Mind"
	)
	
	switch(choice)
		if("Survival Basics")
			if(npc.TeachKnowledgeToPlayer(M, "survival_101"))
				M << "<font color=#57FF00>The Elder shares ancient survival wisdom with you!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already understand these survival basics.</font>"
		
		if("Resource Management")
			if(npc.TeachKnowledgeToPlayer(M, "resource_conservation"))
				M << "<font color=#57FF00>The Elder teaches you resource conservation!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already know these conservation techniques.</font>"
		
		if("Building Shelter")
			if(npc.TeachRecipeToPlayer(M, "wooden_wall"))
				M << "<font color=#57FF00>The Elder teaches you how to build wooden walls!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already know how to build wooden walls.</font>"

/proc/VeteranRecipeDialogUnified(mob/players/M, mob/npcs/npc)
	// Unified Veteran recipe teaching using character data
	if(!M || !npc || !npc.character) return
	
	var/choice = input(M, "What would you like to learn?", "Learn from Veteran") in list(
		"Combat Stance", 
		"Weapon Maintenance", 
		"Defensive Tactics", 
		"Never Mind"
	)
	
	switch(choice)
		if("Combat Stance")
			if(npc.TeachKnowledgeToPlayer(M, "combat_basics"))
				M << "<font color=#57FF00>The Veteran teaches you proper combat stance!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already understand combat basics.</font>"
		
		if("Weapon Maintenance")
			if(npc.TeachRecipeToPlayer(M, "tool_sharpening"))
				M << "<font color=#57FF00>The Veteran teaches you weapon maintenance!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already know weapon maintenance.</font>"
		
		if("Defensive Tactics")
			if(npc.TeachKnowledgeToPlayer(M, "defense_101"))
				M << "<font color=#57FF00>The Veteran teaches you defensive tactics!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already know these defensive tactics.</font>"

/proc/WarriorRecipeDialogUnified(mob/players/M, mob/npcs/npc)
	// Unified Warrior recipe teaching using character data
	if(!M || !npc || !npc.character) return
	
	var/choice = input(M, "What would you like to learn?", "Learn from Warrior") in list(
		"Tool Crafting", 
		"Armor Care", 
		"Resource Preparation", 
		"Never Mind"
	)
	
	switch(choice)
		if("Tool Crafting")
			if(npc.TeachRecipeToPlayer(M, "carving_knife"))
				M << "<font color=#57FF00>The Warrior teaches you tool crafting!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already know how to craft tools.</font>"
		
		if("Armor Care")
			if(npc.TeachKnowledgeToPlayer(M, "armor_maintenance"))
				M << "<font color=#57FF00>The Warrior teaches you armor care!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already know armor maintenance.</font>"
		
		if("Resource Preparation")
			if(npc.TeachRecipeToPlayer(M, "cook_food"))
				M << "<font color=#57FF00>The Warrior teaches you resource preparation!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already know resource preparation.</font>"

/proc/ScribeRecipeDialogUnified(mob/players/M, mob/npcs/npc)
	// Unified Scribe recipe teaching using character data
	if(!M || !npc || !npc.character) return
	
	var/choice = input(M, "What would you like to learn?", "Learn from Scribe") in list(
		"History & Lore", 
		"Crafting Methods", 
		"World Knowledge", 
		"Never Mind"
	)
	
	switch(choice)
		if("History & Lore")
			if(npc.TeachKnowledgeToPlayer(M, "world_history"))
				M << "<font color=#57FF00>The Scribe shares world history with you!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already know this history.</font>"
		
		if("Crafting Methods")
			if(npc.TeachKnowledgeToPlayer(M, "crafting_theory"))
				M << "<font color=#57FF00>The Scribe teaches you crafting theory!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already understand crafting theory.</font>"
		
		if("World Knowledge")
			if(npc.TeachKnowledgeToPlayer(M, "knowledge_preservation"))
				M << "<font color=#57FF00>The Scribe shares world knowledge with you!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already possess this knowledge.</font>"

/proc/PriorVeteranRecipeDialogUnified(mob/players/M, mob/npcs/npc)
	// Unified Proctor recipe teaching using character data
	if(!M || !npc || !npc.character) return
	
	var/choice = input(M, "What would you like to learn?", "Learn from Proctor") in list(
		"Building Basics", 
		"Construction Methods", 
		"Advanced Building", 
		"Never Mind"
	)
	
	switch(choice)
		if("Building Basics")
			if(npc.TeachRecipeToPlayer(M, "wooden_wall"))
				M << "<font color=#57FF00>The Proctor teaches you building basics!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already know building basics.</font>"
		
		if("Construction Methods")
			if(npc.TeachKnowledgeToPlayer(M, "construction_methods"))
				M << "<font color=#57FF00>The Proctor shares construction wisdom with you!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already know these construction methods.</font>"
		
		if("Advanced Building")
			if(npc.TeachRecipeToPlayer(M, "stone_foundation"))
				M << "<font color=#57FF00>The Proctor teaches you advanced building!</font>"
				npc.MarkPlayerTaught(M.ckey)
			else
				M << "<font color=#FF5555>You already know advanced building.</font>"

// ============================================================================
// NPC INTERACTION SYSTEM - Click to interact with NPCs
// ============================================================================

/mob/npcs/Click()
	/**
	 * Click() - NPC interaction handler
	 * Players right-click NPCs to open interaction menu
	 */
	set popup_menu = 1
	
	var/mob/players/player = usr
	if(!istype(player)) return  // Only players can interact
	
	// Show interaction menu
	var/choice = input(player, "What would you like to do?", "Interact with [src.name]") as null|anything in list("Greet", "Learn Recipes", "Cancel")
	
	if(!choice || choice == "Cancel") return
	
	switch(choice)
		if("Greet")
			GreetPlayer(player)
		if("Learn Recipes")
			ShowRecipeTeaching(player)

/mob/npcs/proc/GreetPlayer(mob/players/M)
	/**
	 * GreetPlayer - NPC greets the player
	 * Responds based on NPC type
	 */
	if(!character) return
	
	switch(character.npc_type)
		if("Traveler")
			M << "<span class='good'>Welcome, friend! I've traveled far and wide. Ask me about recipes if you'd like to learn.</span>"
		if("Elder")
			M << "<span class='good'>Greetings, young one. I have much knowledge to share about survival.</span>"
		if("Veteran")
			M << "<span class='good'>Well met, traveler. I've seen much in my years here.</span>"
		if("Warrior")
			M << "<span class='good'>Hail! Ready for battle training?</span>"
		if("Scribe")
			M << "<span class='good'>Welcome to my archives. I keep records of many techniques.</span>"
		if("Proctor")
			M << "<span class='good'>Welcome, student. I can teach you the art of construction.</span>"
		if("Blacksmith")
			M << "<span class='good'>Greetings! I craft the finest tools and weapons.</span>"
		else
			M << "<span class='good'>Hello there, friend.</span>"

/mob/npcs/proc/ShowRecipeTeaching(mob/players/M)
	/**
	 * ShowRecipeTeaching - Display available recipes to teach
	 * Offers basic recipes based on NPC type
	 */
	if(!character)
		M << "<span class='warning'>[src.name] has nothing to teach you right now.</span>"
		return
	
	var/list/available_recipes = list()
	
	// Determine recipes based on NPC type
	switch(character.npc_type)
		if("Traveler", "Elder", "Scribe")
			available_recipes += "stone_hammer"
			available_recipes += "carving_knife"
		if("Blacksmith", "Veteran")
			available_recipes += "iron_hammer"
			available_recipes += "iron_pickaxe"
			available_recipes += "steel_sword"
		if("Proctor")
			available_recipes += "stone_foundation"
			available_recipes += "wooden_wall"
		else
			available_recipes += "stone_hammer"
	
	if(!available_recipes.len)
		M << "<span class='info'>[src.name] has nothing more to teach you.</span>"
		return
	
	var/choice = input(M, "Which recipe would you like to learn?", "Learn from [src.name]") as null|anything in available_recipes
	
	if(!choice) return
	
	if(TeachRecipeToPlayer(M, choice))
		M << "<span class='good'>[src.name] teaches you about [choice]!</span>"
		MarkPlayerTaught(M.ckey)
	else
		M << "<span class='warning'>You already know how to do that.</span>"
