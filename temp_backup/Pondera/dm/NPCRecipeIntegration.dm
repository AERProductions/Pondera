// NPCRecipeIntegration.dm - NPC Recipe Unlocking System
// Integrates recipe discovery with NPC dialogue system
// Allows NPCs to teach recipes to players through conversation

// ============================================================================
// NPC RECIPE TEACHING PROCS
// ============================================================================

/proc/TeachRecipeDialog(mob/players/M, npc_name, recipe_name, description)
	// Display recipe teaching dialog and unlock recipe for player
	if(!M || !M.character) return 0
	
	// Validate recipe state
	if(!M.character.recipe_state)
		M.character.recipe_state = new /datum/recipe_state()
	
	// Check if already learned
	if(M.character.recipe_state.IsRecipeDiscovered(recipe_name))
		alert(M, "[npc_name] says: You already know how to make [recipe_name]. Best of luck with your crafting!", "Recipe")
		return 0
	
	// Show learning dialog
	alert(M, "[npc_name] teaches you: \n\n[description]\n\nRecipe unlocked: [recipe_name]!", "Recipe Discovery")
	
	// Unlock recipe
	M.character.recipe_state.DiscoverRecipe(recipe_name)
	M << "<b><font color=gold>RECIPE DISCOVERED: [recipe_name]</b>"
	
	return 1

/proc/TeachKnowledgeDialog(mob/players/M, npc_name, knowledge_topic, description)
	// Display knowledge teaching dialog and unlock knowledge for player
	if(!M || !M.character) return 0
	
	// Validate recipe state
	if(!M.character.recipe_state)
		M.character.recipe_state = new /datum/recipe_state()
	
	// Show learning dialog
	alert(M, "[npc_name] teaches you: \n\n[description]", "Knowledge Discovery")
	
	// Unlock knowledge
	M.character.recipe_state.LearnTopic(knowledge_topic)
	M << "<b><font color=cyan>KNOWLEDGE GAINED: [knowledge_topic]</b>"
	
	return 1

// ============================================================================
// NPC DIALOGUE OPTION SYSTEM
// ============================================================================

/proc/AddRecipeOption(var/list/options, recipe_name)
	// Add recipe teaching option to dialog menu
	options += "[recipe_name]"
	return options

/proc/CreateNPCRecipeMenu(npc_name, var/list/recipes)
	// Create menu of recipes NPC can teach
	var/list/menu = list("Leave")
	
	for(var/recipe in recipes)
		menu += "[recipe]"
	
	return menu

// ============================================================================
// BLACKSMITH NPC - Teaches steel tool recipes
// ============================================================================

/proc/BlacksmithRecipeDialog(mob/players/M)
	if(!M || !M.character) return
	
	var/choice = input(M, "What would you like to learn?", "Blacksmith") in list(
		"Steel Pickaxe",
		"Steel Hammer",
		"Steel Shovel",
		"Steel Hoe",
		"Steel Axe",
		"Steel Sword",
		"Tool Refinement",
		"Leave"
	)
	
	if(choice == "Leave") return
	
	switch(choice)
		if("Steel Pickaxe")
			TeachRecipeDialog(M, "Blacksmith", "steel_pickaxe", 
				"To craft a steel pickaxe, you'll need:\n- 3x Steel Ingot\n- 2x Iron Handle\n- 1x Oak Wood\n\nHeat the ingots in the forge until they glow, then smith them together on the anvil with the handle.")
		
		if("Steel Hammer")
			TeachRecipeDialog(M, "Blacksmith", "steel_hammer",
				"To craft a steel hammer, you'll need:\n- 2x Steel Ingot\n- 2x Iron Handle\n- 1x Oak Wood\n\nSmith the ingots into a head, attach the handles, and reinforce with the wood.")
		
		if("Steel Shovel")
			TeachRecipeDialog(M, "Blacksmith", "steel_shovel",
				"To craft a steel shovel, you'll need:\n- 2x Steel Ingot\n- 1x Iron Handle\n- 1x Oak Wood\n\nCreate a flat head and secure the handle with iron reinforcements.")
		
		if("Steel Hoe")
			TeachRecipeDialog(M, "Blacksmith", "steel_hoe",
				"To craft a steel hoe, you'll need:\n- 1x Steel Ingot\n- 1x Iron Handle\n- 1x Oak Wood\n\nSmith a curved blade and attach to the handle.")
		
		if("Steel Axe")
			TeachRecipeDialog(M, "Blacksmith", "steel_axe",
				"To craft a steel axe, you'll need:\n- 2x Steel Ingot\n- 2x Iron Handle\n- 1x Oak Wood\n\nCreate a sharp blade with a rounded edge, mount on reinforced handle.")
		
		if("Steel Sword")
			TeachRecipeDialog(M, "Blacksmith", "steel_sword",
				"To craft a steel sword, you'll need:\n- 3x Steel Ingot\n- 2x Iron Handle\n- 1x Oak Wood\n\nForge a long blade, heat-treat it, and secure with a wrapped handle.")
		
		if("Tool Refinement")
			TeachKnowledgeDialog(M, "Blacksmith", "tool_refinement",
				"Tool refinement is the process of improving crafted tools:\n1. Filing - Remove rough edges\n2. Sharpening - Increase cutting edge\n3. Polishing - Final finish\n\nEach stage requires specific materials and increases tool effectiveness.")

// ============================================================================
// SCHOLAR NPC - Teaches knowledge and crafting fundamentals
// ============================================================================

/proc/ScholarKnowledgeDialog(mob/players/M)
	if(!M || !M.character) return
	
	var/choice = input(M, "What would you like to understand?", "Scholar") in list(
		"Smithing Basics",
		"Smelting Ore",
		"Crafting System",
		"Resource Gathering",
		"Building Basics",
		"Leave"
	)
	
	if(choice == "Leave") return
	
	switch(choice)
		if("Smithing Basics")
			TeachKnowledgeDialog(M, "Scholar", "smithing_basics",
				"Smithing is the art of working with heated metal:\n\n1. Heat ore or ingots in a forge until red hot\n2. Shape on an anvil using a hammer\n3. Quench in water to cool and harden\n4. Refine to improve quality\n\nRequires Mining skill level 2+ to begin.")
		
		if("Smelting Ore")
			TeachKnowledgeDialog(M, "Scholar", "smelting_ore",
				"Smelting converts raw ore into usable ingots:\n\n1. Gather ore from mining\n2. Build or find a forge\n3. Place ore and fuel in forge\n4. Heat until ore becomes liquid\n5. Pour into molds to create ingots\n\nStone ore -> Iron ingot (20 ore = 1 ingot)")
		
		if("Crafting System")
			TeachKnowledgeDialog(M, "Scholar", "crafting_system",
				"Crafting allows you to combine materials:\n\n1. Gather required materials\n2. Have proper tool equipped\n3. Right-click materials\n4. Select 'Combine' option\n5. Success chance based on skill level\n\nFail more often with low skill - practice to improve!")
		
		if("Resource Gathering")
			TeachKnowledgeDialog(M, "Scholar", "resource_gathering",
				"Different resources are found in different biomes:\n\n- Stone: Rocky areas, click to mine\n- Wood: Trees, chop with axe\n- Ore: Deep stone, mine with pickaxe\n- Plants: Grasslands, gather by hand\n- Water: Ponds, lakes, rivers\n\nUse appropriate tools for best yield.")
		
		if("Building Basics")
			TeachKnowledgeDialog(M, "Scholar", "building_basics",
				"Building structures requires:\n\n1. Hammer in inventory\n2. Required materials nearby\n3. Clear, flat space\n4. Adequate building skill\n5. Right-click with hammer to start\n\nStart with simple structures like walls and doors. Progress to complex buildings like houses and forges.")

// ============================================================================
// FISHERMAN NPC - Teaches fishing and food recipes
// ============================================================================

/proc/FishermanRecipeDialog(mob/players/M)
	if(!M || !M.character) return
	
	var/choice = input(M, "What fishing knowledge do you seek?", "Fisherman") in list(
		"Fishing Basics",
		"Fish Preparation",
		"Leave"
	)
	
	if(choice == "Leave") return
	
	switch(choice)
		if("Fishing Basics")
			TeachKnowledgeDialog(M, "Fisherman", "fishing_basics",
				"To fish, you'll need:\n\n1. A fishing pole (craft with iron ingot + handle)\n2. Bait (worms, insects, small food)\n3. A body of water\n\nEquip pole, stand by water, and click on fish. Success depends on fishing skill and bait quality.")
		
		if("Fish Preparation")
			TeachRecipeDialog(M, "Fisherman", "cook_fish",
				"To prepare fish:\n\n1. Catch fish with fishing pole\n2. Have fire or cooking station\n3. Right-click fish with heat source\n4. Select 'Cook' option\n5. Cooked fish restores more health than raw\n\nHigher cooking skill = faster and better quality meals")

// ============================================================================
// HERBALIST NPC - Teaches gathering and plant recipes
// ============================================================================

/proc/HerbalistRecipeDialog(mob/players/M)
	if(!M || !M.character) return
	
	var/choice = input(M, "What plant knowledge do you seek?", "Herbalist") in list(
		"Plant Gathering",
		"Herb Remedies",
		"Leave"
	)
	
	if(choice == "Leave") return
	
	switch(choice)
		if("Plant Gathering")
			TeachKnowledgeDialog(M, "Herbalist", "plant_gathering",
				"Plants are found throughout the world:\n\n- Flowers: Healing herbs, in grasslands\n- Berries: Food, on bushes\n- Roots: Medicinal, dig near trees\n- Mushrooms: Potent effects, in forests\n- Leaves: Crafting, from trees\n\nGather with bare hands - higher gardening skill yields more.")
		
		if("Herb Remedies")
			TeachRecipeDialog(M, "Herbalist", "herb_remedy",
				"Create herbal remedies:\n\n1. Gather fresh herbs\n2. Combine with water\n3. Heat gently over fire\n4. Let steep for short time\n5. Drink for healing and buffs\n\nDifferent herb combinations create different effects.")

// ============================================================================
// INITIALIZATION
// ============================================================================

/proc/InitializeNPCRecipeSystem()
	world << "NPC Recipe Integration System Initialized"
