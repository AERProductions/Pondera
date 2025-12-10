// SkillRecipeUnlock.dm - Skill-Based Recipe Discovery System
// Automatically unlocks recipes when players reach skill thresholds
// Provides passive recipe discovery through skill progression

// ============================================================================
// SKILL-BASED RECIPE UNLOCK TABLES
// ============================================================================

var/datum/skill_recipe_unlock_table/skill_recipes = new()

/datum/skill_recipe_unlock_table
	var/list/mining_recipes = alist(
		2, list("stone_hammer", "Iron Ore has been discovered"),
		4, list("iron_pickaxe", "You can now craft better mining tools"),
		6, list("steel_pickaxe", "Master mining tools unlocked")
	)
	
	var/list/smithing_recipes = alist(
		1, list("iron_hammer", "Basic smithing techniques discovered"),
		2, list("iron_shovel", "Tool crafting expanded"),
		3, list("iron_hoe", "More tool varieties available"),
		4, list("iron_axe", "Advanced tool crafting"),
		5, list("iron_chisel", "Specialized tools unlocked"),
		6, list("steel_hammer", "Master smithing achieved"),
		7, list("steel_shovel", "Expert tool creation"),
		8, list("steel_hoe", "Advanced specialized tools"),
		9, list("steel_axe", "Master craftsmanship"),
		10, list("steel_sword", "Legendary weaponcraft")
	)
	
	var/list/building_recipes = alist(
		1, list("wooden_wall", "Basic wall construction"),
		2, list("stone_wall", "Improved building materials"),
		3, list("wooden_door", "Access control structures"),
		4, list("anvil", "Forge facility unlocked"),
		5, list("forge", "Smelting equipment available"),
		6, list("bed", "Furniture crafting available"),
		7, list("chest", "Storage solutions unlocked"),
		8, list("roof", "Advanced roof structures")
	)
	
	var/list/fishing_recipes = alist(
		1, list("fishing_pole", "Basic fishing equipment"),
		2, list("fish_trap", "Passive fishing methods"),
		3, list("cook_fish", "Fish preparation techniques")
	)
	
	var/list/gardening_recipes = alist(
		1, list("plant_seed", "Basic gardening"),
		2, list("water_plant", "Plant care techniques"),
		3, list("harvest_crop", "Crop harvesting")
	)
	
	var/list/crafting_recipes = alist(
		1, list("carving_knife", "Basic carving tools"),
		2, list("wooden_handle", "Handle crafting"),
		3, list("tool_refinement", "Tool improvement process")
	)
	
	var/list/smelting_recipes = alist(
		1, list("iron_ingot_smelting", "Basic ore smelting"),
		2, list("steel_ingot_creation", "Advanced alloy creation"),
		3, list("tool_filing", "Tool refinement stage 1"),
		4, list("tool_sharpening", "Tool refinement stage 2"),
		5, list("tool_polishing", "Tool refinement stage 3")
	)
	
	var/list/refining_recipes = alist(
		1, list("tool_filing", "Basic tool refinement"),
		2, list("tool_sharpening", "Enhanced tool edges"),
		3, list("tool_polishing", "Perfect tool finishing")
	)

// ============================================================================
// SKILL LEVEL-UP NOTIFICATION & RECIPE UNLOCK
// ============================================================================

/proc/CheckAndUnlockRecipeBySkill(mob/players/player, skill_name, skill_level)
	// Called when a player's skill rank increases
	if(!player || !player.character) return 0
	
	// Validate recipe state
	if(!player.character.recipe_state)
		player.character.recipe_state = new /datum/recipe_state()
	
	// Get recipes for this skill at this level
	var/list/recipes_to_unlock = list()
	
	switch(skill_name)
		if("mining")
			if(skill_recipes.mining_recipes[skill_level])
				recipes_to_unlock = skill_recipes.mining_recipes[skill_level]
		
		if("smithing")
			if(skill_recipes.smithing_recipes[skill_level])
				recipes_to_unlock = skill_recipes.smithing_recipes[skill_level]
		
		if("building")
			if(skill_recipes.building_recipes[skill_level])
				recipes_to_unlock = skill_recipes.building_recipes[skill_level]
		
		if("fishing")
			if(skill_recipes.fishing_recipes[skill_level])
				recipes_to_unlock = skill_recipes.fishing_recipes[skill_level]
		
		if("gardening")
			if(skill_recipes.gardening_recipes[skill_level])
				recipes_to_unlock = skill_recipes.gardening_recipes[skill_level]
		
		if("crafting")
			if(skill_recipes.crafting_recipes[skill_level])
				recipes_to_unlock = skill_recipes.crafting_recipes[skill_level]
		
		if("smelting")
			if(skill_recipes.smelting_recipes[skill_level])
				recipes_to_unlock = skill_recipes.smelting_recipes[skill_level]
		
		if("refining")
			if(skill_recipes.refining_recipes[skill_level])
				recipes_to_unlock = skill_recipes.refining_recipes[skill_level]
	
	// Unlock recipes
	if(recipes_to_unlock && recipes_to_unlock.len >= 2)
		var/recipe_id = recipes_to_unlock[1]
		var/recipe_desc = recipes_to_unlock[2]
		
		if(!player.character.recipe_state.IsRecipeDiscovered(recipe_id))
			player.character.recipe_state.DiscoverRecipe(recipe_id)
			player << "<b><font color=gold>RECIPE DISCOVERED: [recipe_id] - [recipe_desc]</font></b>"
			return 1
	
	return 0

// ============================================================================
// SKILL KNOWLEDGE UNLOCK SYSTEM
// ============================================================================

/proc/UnlockSkillKnowledge(mob/players/player, skill_name, skill_level)
	// Unlock knowledge topics based on skill progression
	if(!player || !player.character) return 0
	
	// Validate recipe state
	if(!player.character.recipe_state)
		player.character.recipe_state = new /datum/recipe_state()
	
	var/knowledge_topic = ""
	var/knowledge_desc = ""
	
	switch(skill_name)
		if("mining")
			switch(skill_level)
				if(1)
					knowledge_topic = "mining_basics"
					knowledge_desc = "Ore deposits become visible in stone"
				if(3)
					knowledge_topic = "mining_efficiency"
					knowledge_desc = "Faster ore extraction techniques"
				if(5)
					knowledge_topic = "mining_master"
					knowledge_desc = "Expert ore identification and extraction"
		
		if("smithing")
			switch(skill_level)
				if(1)
					knowledge_topic = "smithing_basics"
					knowledge_desc = "Basic anvil and hammer techniques"
				if(3)
					knowledge_topic = "heat_treatment"
					knowledge_desc = "Proper heating and cooling methods"
				if(6)
					knowledge_topic = "master_smithing"
					knowledge_desc = "Creating legendary tools"
		
		if("building")
			switch(skill_level)
				if(1)
					knowledge_topic = "building_basics"
					knowledge_desc = "Foundation and wall construction"
				if(3)
					knowledge_topic = "structural_design"
					knowledge_desc = "Optimal building layouts"
				if(6)
					knowledge_topic = "master_architecture"
					knowledge_desc = "Complex multi-story structures"
		
		if("fishing")
			switch(skill_level)
				if(1)
					knowledge_topic = "fishing_basics"
					knowledge_desc = "Fish behavior and bait selection"
				if(2)
					knowledge_topic = "advanced_fishing"
					knowledge_desc = "Deep water fishing techniques"
		
		if("gardening")
			switch(skill_level)
				if(1)
					knowledge_topic = "plant_care"
					knowledge_desc = "Watering and fertilization"
				if(3)
					knowledge_topic = "crop_rotation"
					knowledge_desc = "Sustainable gardening practices"
	
	if(knowledge_topic)
		player.character.recipe_state.LearnTopic(knowledge_topic)
		player << "<b><font color=cyan>KNOWLEDGE GAINED: [knowledge_topic] - [knowledge_desc]</font></b>"
		return 1
	
	return 0

// ============================================================================
// RECIPE DISCOVERY NOTIFICATION SYSTEM
// ============================================================================

/proc/NotifyRecipeDiscovered(mob/players/player, recipe_id, source = "skill")
	// Notify player of recipe discovery with style
	if(!player) return
	
	switch(source)
		if("skill")
			player << "<b><font color=gold>* [recipe_id] recipe discovered through skill practice *</font></b>"
		
		if("npc")
			player << "<b><font color=#FFD700>* [recipe_id] recipe learned from NPC *</font></b>"
		
		if("item")
			player << "<b><font color=#FF6347>* [recipe_id] recipe discovered by examining item *</font></b>"
		
		if("exploration")
			player << "<b><font color=#32CD32>* [recipe_id] recipe discovered during exploration *</font></b>"

// ============================================================================
// INTEGRATION HOOKS
// ============================================================================

/proc/OnSkillLevelUp(mob/players/player, skill_name, new_level)
	// Called when player skill level increases
	// Triggers recipe and knowledge unlocks
	if(!player) return
	
	// Log to activity system
	var/old_level = new_level - 1
	LogSkillUp(player, skill_name, old_level, new_level)
	
	CheckAndUnlockRecipeBySkill(player, skill_name, new_level)
	UnlockSkillKnowledge(player, skill_name, new_level)

/proc/InitializeSkillRecipeSystem()
	world << "Skill-Based Recipe Unlock System Initialized"
	skill_recipes = new /datum/skill_recipe_unlock_table()
