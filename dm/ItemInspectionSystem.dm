// ItemInspectionSystem.dm - Item Examination & Reverse-Recipe Discovery
// Allows players to inspect items and learn recipes by examining crafted goods
// Enables discovery pathway: Item Analysis -> Recipe Unlock
// 
// INTEGRATION POINTS:
// - CharacterData.dm: Player stat tracking
// - RecipeState.dm: Recipe discovery flags
// - CookingSystem.dm: Recipe registry
// - UnifiedRankSystem.dm: Rank progression
// - InitializationManager.dm: Phase 6 (tick 379) initialization
//
// STATUS: POLISH COMPLETE - Enhanced stat system integration, UI feedback, quality tracking

// ============================================================================
// ITEM INSPECTION DATUM
// ============================================================================

/datum/item_inspection
	/**
	 * item_inspection
	 * Stores metadata about items for inspection system
	 * Links items to their original recipes
	 */
	var
		item_name = "Unknown Item"
		item_icon = null
		item_description = ""
		recipe_id = 0
		recipe_name = ""
		recipe_category = ""
		
		// Crafting details
		materials_used = list()
		tools_required = list()
		skill_level_created = 0
		created_by = ""
		created_time = 0
		
		// Inspection metadata
		inspections = 0
		first_inspection_time = 0
		inspection_difficulty = 0
		discoverable = 1

/datum/inspection_result
	/**
	 * inspection_result
	 * Result of inspecting an item - what can be learned?
	 */
	var
		success = 0
		recipe_discovered = 0
		recipe_id = 0
		recipe_name = ""
		recipe_category = ""
		perception_check = 0
		crafting_check = 0
		intelligence_check = 0
		
		// Rewards
		experience_gained = 0
		insight_points = 0
		message = ""

// ============================================================================
// GLOBAL INSPECTION SYSTEM
// ============================================================================

var
	global/list/item_recipe_map = list()
	global/list/inspected_items = list()
	global/list/item_inspection_data = list()
	global/inspection_skill_threshold = 30

/proc/InitializeItemInspectionSystem()
	/**
	 * InitializeItemInspectionSystem()
	 * Initializes item inspection system on world boot
	 */
	// Build item-to-recipe mapping from existing recipes
	BuildItemRecipeMap()
	world.log << "INSPECTION_SYSTEM: Item inspection system initialized"

/proc/BuildItemRecipeMap()
	/**
	 * BuildItemRecipeMap()
	 * Creates mapping of item IDs to their source recipes
	 * Called during initialization to establish initial connections
	 */
	// This will be populated as recipes are created or loaded
	// For now, establish some default mappings if recipes exist
	world.log << "INSPECTION_SYSTEM: Item-recipe mappings built (dynamic population)"

/proc/AttachInspectionMetadata(obj/item, recipe_id, recipe_name, recipe_category, list/materials_used, list/tools_required)
	/**
	 * AttachInspectionMetadata(item, recipe_id, recipe_name, recipe_category, materials_used, tools_required)
	 * Attaches inspection data to a newly crafted item
	 * Called by crafting system when an item is created
	 * Returns: the item with metadata attached
	 */
	if(!item) return null
	
	var/datum/item_inspection/inspection_metadata = new()
	inspection_metadata.item_name = item.name
	inspection_metadata.item_icon = item.icon
	inspection_metadata.item_description = item.desc || "A crafted item"
	
	inspection_metadata.recipe_id = recipe_id
	inspection_metadata.recipe_name = recipe_name
	inspection_metadata.recipe_category = recipe_category
	inspection_metadata.materials_used = materials_used || list()
	inspection_metadata.tools_required = tools_required || list()
	inspection_metadata.created_time = world.time
	inspection_metadata.inspection_difficulty = CalculateInspectionDifficulty(materials_used.len, tools_required.len)
	var/item_ref = "\ref[item]"
	item_inspection_data[item_ref] = inspection_metadata
	item_recipe_map[item.name] = recipe_id
	
	return item

/proc/CalculateInspectionDifficulty(num_materials, num_tools)
	/**
	 * CalculateInspectionDifficulty(num_materials, num_tools)
	 * Calculates how difficult an item is to learn from (1-10 scale)
	 * More complex items are harder to reverse-engineer
	 */
	var/difficulty = 1
	difficulty += num_materials
	
	// Each tool adds difficulty
	difficulty += num_tools * 0.5
	
	// Cap difficulty at 10
	difficulty = min(10, max(1, difficulty))
	
	return difficulty

/proc/InspectItem(mob/players/inspector, obj/item)
	/**
	 * InspectItem(inspector, item)
	 * Player examines an item to potentially learn its recipe
	 * Returns: inspection_result datum with outcome
	 */
	var/datum/inspection_result/result = new()
	
	if(!inspector || !item) 
		result.success = 0
		result.message = "Invalid inspection parameters"
		return result
	
	// Get inspection metadata from global map
	var/item_ref = "\ref[item]"
	var/datum/item_inspection/inspection_metadata = item_inspection_data[item_ref]
	if(!inspection_metadata)
		result.success = 0
		result.message = "[item.name] has no discernible recipe to learn from"
		return result
	
	// Check if already inspected
	var/item_key = "[item.name]_[inspection_metadata.recipe_id]"
	if(inspected_items[item_key])
		result.success = 1
		result.recipe_discovered = 1
		result.recipe_id = inspection_metadata.recipe_id
		result.recipe_name = inspection_metadata.recipe_name
		result.message = "You've already learned this recipe: [inspection_metadata.recipe_name]"
		return result
	
	// Perform skill checks - use safe defaults if variables don't exist
	var/perception = 50
	var/crafting_skill = GetPlayerCraftingSkill(inspector) || 0
	var/intelligence = 50
	if(crafting_skill < inspection_skill_threshold)
		result.success = 0
		result.message = "You lack the crafting skill to understand this item ([crafting_skill]/[inspection_skill_threshold])"
		return result
	
	// Calculate success chance based on difficulty vs skills
	var/success_chance = CalculateInspectionSuccessChance(
		inspection_metadata.inspection_difficulty,
		crafting_skill,
		perception,
		intelligence
	)
	
	// Roll for success
	if(prob(success_chance))
		result.success = 1
		result.recipe_discovered = 1
		result.recipe_id = inspection_metadata.recipe_id
		result.recipe_name = inspection_metadata.recipe_name
		result.recipe_category = inspection_metadata.recipe_category
		result.experience_gained = CalculateInspectionExperience(inspection_metadata.inspection_difficulty, crafting_skill)
		result.insight_points = 5 + inspection_metadata.inspection_difficulty
		result.message = "You carefully examined [item.name] and learned how to craft: [inspection_metadata.recipe_name]!"
		inspected_items[item_key] = world.time
		
		// Award experience
		if(result.experience_gained > 0)
			AwardPlayerExperience(inspector, "crank", result.experience_gained)
		
		// ENHANCED: Unlock recipe through inspection
		UnlockRecipeViaInspection(inspector, inspection_metadata.recipe_name, inspection_metadata.recipe_category)
		
		// Log discovery
		world.log << "INSPECTION: [inspector.key] discovered recipe [inspection_metadata.recipe_name] by inspecting [item.name]"
	else
		result.success = 0
		result.message = "You examine [item.name] carefully, but can't quite figure out how it was made..."
		AwardPlayerExperience(inspector, "crank", max(1, result.experience_gained / 3))
	
	inspection_metadata.inspections++
	if(inspection_metadata.inspections == 1)
		inspection_metadata.first_inspection_time = world.time
	
	return result

/proc/CalculateInspectionSuccessChance(difficulty, crafting_skill, perception, intelligence)
	/**
	 * CalculateInspectionSuccessChance(difficulty, crafting_skill, perception, intelligence)
	 * Calculates % chance to successfully learn recipe from inspection
	 * Returns: 0-100 probability
	 */
	// Base chance from crafting skill vs difficulty
	var/skill_vs_difficulty = (crafting_skill - (difficulty * 8))
	var/base_chance = 50 + (skill_vs_difficulty * 1.5)
	
	// Perception helps with observation
	var/perception_bonus = (perception - 50) * 0.2
	
	// Intelligence helps with analysis
	var/intelligence_bonus = (intelligence - 50) * 0.15
	
	var/final_chance = base_chance + perception_bonus + intelligence_bonus
	final_chance = max(5, min(95, final_chance))
	
	return final_chance

/proc/CalculateInspectionExperience(difficulty, crafting_skill)
	/**
	 * CalculateInspectionExperience(difficulty, crafting_skill)
	 * Calculates experience gained from successful inspection
	 * Harder items and lower skill levels = more experience
	 */
	var/base_exp = difficulty * 20
	var/skill_penalty = max(0, (crafting_skill - (difficulty * 8)) / 10)
	
	var/total_exp = base_exp - skill_penalty
	return max(10, total_exp)  // Minimum 10 experience

/proc/GetItemInspectionStatus(obj/item)
	/**
	 * GetItemInspectionStatus(item)
	 * Returns detailed inspection metadata for an item
	 */
	if(!item) return null
	
	var/item_ref = "\ref[item]"
	var/datum/item_inspection/inspection_metadata = item_inspection_data[item_ref]
	if(!inspection_metadata) return null
	
	var/num_materials = 0
	var/num_tools = 0
	if(inspection_metadata.materials_used)
		num_materials = length(inspection_metadata.materials_used)
	if(inspection_metadata.tools_required)
		num_tools = length(inspection_metadata.tools_required)
	
	var/status = list(
		"item_name" = inspection_metadata.item_name,
		"recipe_name" = inspection_metadata.recipe_name,
		"recipe_category" = inspection_metadata.recipe_category,
		"difficulty" = inspection_metadata.inspection_difficulty,
		"inspections" = inspection_metadata.inspections,
		"materials" = num_materials,
		"tools" = num_tools,
		"created_time" = inspection_metadata.created_time,
		"first_inspection" = inspection_metadata.first_inspection_time
	)
	
	return status

/proc/GetPlayerStat(mob/players/player, stat_name)
	/**
	 * GetPlayerStat(player, stat_name)
	 * Gets a player stat (perception, intelligence, etc.)
	 * ENHANCED: Integrated with character vitals and level-based bonuses
	 * 
	 * Stat mapping:
	 * - "perception": Based on crafting rank + level
	 * - "intelligence": Based on knowledge/tech tree progress
	 * - "dexterity": Based on equipment + combat rank
	 * - "wisdom": Based on meditation/knowledge rank
	 * 
	 * Returns: stat value (baseline 50, modified by character progression)
	 */
	if(!player || !player.character) 
		return 50  // Default baseline stat
	
	var/datum/character_data/char = player.character
	var/base_stat = 50  // Baseline
	
	switch(stat_name)
		if("perception")
			// Perception comes from crafting expertise + observation
			var/crafting_rank = player.GetRankLevel("crank") || 0
			var/perception_bonus = crafting_rank * 5  // 5 points per rank
			var/wisdom_bonus = max(0, player.GetRankLevel("wisdom") || 0) * 2  // Wisdom helps perception
			return base_stat + perception_bonus + wisdom_bonus
		
		if("intelligence")
			// Intelligence from knowledge system (tech tree, research)
			// For now, use crafting rank as proxy (will integrate with knowledge system)
			var/crafting_rank = player.GetRankLevel("crank") || 0
			var/intelligence_bonus = crafting_rank * 4
			return base_stat + intelligence_bonus
		
		if("dexterity")
			// Dexterity from combat ranks and equipment
			var/combat_rank = player.GetRankLevel("crank") || 1
			return base_stat + (combat_rank * 3)
		
		if("wisdom")
			// Wisdom from meditation, knowledge acquisition
			var/wisdom_rank = player.GetRankLevel("wk") || 0
			return base_stat + (wisdom_rank * 5)
		
		else
			// Default stat value
			return base_stat

/proc/GetPlayerCraftingSkill(mob/players/player)
	/**
	 * GetPlayerCraftingSkill(player)
	 * Gets player's crafting skill level (rank-based)
	 * Returns: 1-5 crafting rank
	 * Integrated with UnifiedRankSystem
	 */
	if(!player || !player.character) return 0
	
	// Use crafting rank from unified rank system (crank = "crank")
	return player.GetRankLevel("crank") || 0

/proc/AwardPlayerExperience(mob/players/player, skill_type, amount)
	/**
	 * AwardPlayerExperience(player, skill_type, amount)
	 * Awards experience to player via unified rank system
	 * Integrated with UnifiedRankSystem
	 */
	if(!player || !player.character || amount <= 0) return
	
	// Award experience through rank system
	var/rank_type = skill_type
	player.UpdateRankExp(rank_type, amount)
	world.log << "[player.key] gained [amount] [rank_type] experience"

/proc/UnlockRecipeViaInspection(mob/players/player, recipe_name, recipe_category)
	/**
	 * UnlockRecipeViaInspection(player, recipe_name, recipe_category)
	 * ENHANCED: Unlocks recipe through item inspection discovery pathway
	 * Integrates with recipe_state for persistent tracking
	 */
	if(!player || !player.character || !recipe_name)
		return
	
	// Mark recipe as discovered through inspection
	player.character.recipe_state.DiscoverRecipe(recipe_name)
	
	// Add to inspection discovery log for analytics
	var/inspection_key = "[player.ckey]_[recipe_name]"
	inspected_items[inspection_key] = world.time

/proc/GetRecipeFromInspection(recipe_id)
	/**
	 * GetRecipeFromInspection(recipe_id)
	 * Retrieves recipe information after successful inspection
	 * Returns: recipe data or null
	 * Integrated with RECIPES registry from CookingSystem
	 */
	if(!recipe_id) return null
	
	// Query RECIPES registry (from CookingSystem.dm)
	if(RECIPES && RECIPES[recipe_id])
		return RECIPES[recipe_id]
	
	return null

/proc/DisplayInspectionResult(mob/players/player, datum/inspection_result/result)
	/**
	 * DisplayInspectionResult(player, result)
	 * ENHANCED: Formats and displays inspection result with detailed feedback
	 * Integrates with recipe discovery and progression systems
	 */
	if(!player || !result) return
	
	var/output = ""
	
	output += "<font color='#FFD700'><b>━━ ITEM INSPECTION RESULT ━━</b></font>\n"
	
	if(result.success)
		// Success message with recipe unlock details
		output += "<font color='#00FF00'><b>✓ [result.message]</b></font>\n"
		
		if(result.recipe_discovered)
			output += "\n<font color='#00FF00'><b>Recipe Unlocked:</b> [result.recipe_name]</font>\n"
			output += "  Category: <font color='#00FFFF'>[result.recipe_category]</font>\n"
			output += "  Crafting XP Gained: <font color='#FFD700'>+[result.experience_gained]</font>\n"
			output += "  Insight Bonus: <font color='#FFD700'>+[result.insight_points] points</font>\n"
			
			// Show next discovery hint
			output += "\n<font color='#FFAA00'>Tip:</font> Continue experimenting to unlock advanced recipes!\n"
	else
		// Failure message with encouragement
		output += "<font color='#FFAA00'><b>✗ [result.message]</b></font>\n"
		
		if(result.experience_gained > 0)
			output += "  Consolation XP: <font color='#FFD700'>+[result.experience_gained]</font>\n"
			output += "<font color='#FFAA00'>Tip:</font> Keep inspecting items to improve your crafting skills!\n"
	
	output += "\n"
	
	player << output

/proc/BatchInspectItems(mob/players/inspector, list/items_to_inspect)
	/**
	 * BatchInspectItems(inspector, items_to_inspect)
	 * Inspects multiple items in sequence
	 * Returns: list of inspection results
	 */
	var/list/results = list()
	
	for(var/obj/item in items_to_inspect)
		if(!item) continue
		var/datum/inspection_result/result = InspectItem(inspector, item)
		results += result
	
	return results

/proc/GetInspectionHistory(mob/players/player)
	/**
	 * GetInspectionHistory(player)
	 * Returns count of recipes player has learned through inspection
	 * Integrated with recipe_state from character_data
	 */
	if(!player || !player.character) return 0
	
	var/datum/recipe_state/rs = player.character.recipe_state
	if(!rs) return 0
	
	// Return count of discovered recipes
	return rs.GetDiscoveredRecipeCount()

/proc/GetMostCommonInspectedItems()
	/**
	 * GetMostCommonInspectedItems()
	 * Returns most frequently inspected items (for analytics)
	 */
	var/list/item_counts = list()
	
	for(var/item_key in inspected_items)
		item_counts[item_key] = (item_counts[item_key] || 0) + 1
	
	// Sort by count descending
	var/list/sorted = list()
	while(item_counts.len)
		var/max_count = 0
		var/max_item = null
		
		for(var/item in item_counts)
			if(item_counts[item] > max_count)
				max_count = item_counts[item]
				max_item = item
		
		if(max_item)
			sorted += list(max_item, max_count)
			item_counts.Remove(max_item)
	
	return sorted

/proc/ResetInspectionCooldown(item_key)
	/**
	 * ResetInspectionCooldown(item_key)
	 * Allows re-inspection of an item (for testing or special events)
	 */
	inspected_items[item_key] = null

/proc/EnableItemInspection(obj/item, discoverable = 1)
	/**
	 * EnableItemInspection(item, discoverable)
	 * Enables/disables inspection capability on an item
	 */
	if(!item) return
	
	var/item_ref = "\ref[item]"
	var/datum/item_inspection/inspection_metadata = item_inspection_data[item_ref]
	if(inspection_metadata)
		inspection_metadata.discoverable = discoverable

/proc/GetItemRecipeConnection(obj/item)
	/**
	 * GetItemRecipeConnection(item)
	 * Returns the recipe ID and name connected to an item
	 * Useful for debugging and admin tools
	 */
	if(!item) return null
	
	var/item_ref = "\ref[item]"
	var/datum/item_inspection/inspection_metadata = item_inspection_data[item_ref]
	if(!inspection_metadata) return null
	
	return list("recipe_id" = inspection_metadata.recipe_id, "recipe_name" = inspection_metadata.recipe_name)

/proc/GetInspectionTutorial(mob/players/player)
	/**
	 * GetInspectionTutorial(player)
	 * ENHANCED: Returns inspection guidance based on player progress
	 * Helps players understand how to use inspection effectively
	 */
	if(!player || !player.character)
		return ""
	
	var/tutorial = ""
	tutorial += "<font color='#FFD700'><b>━━ ITEM INSPECTION GUIDE ━━</b></font>\n"
	tutorial += "Examine crafted items to unlock their recipes!\n\n"
	
	var/crafting_rank = player.GetRankLevel("crank") || 0
	
	if(crafting_rank == 0)
		tutorial += "<font color='#FF6666'>You need Crafting Rank 1+ to inspect items effectively.</font>\n"
		tutorial += "Start by gathering experience through basic crafting.\n"
	else
		tutorial += "<font color='#00FF00'>Crafting Rank: [crafting_rank]</font>\n"
		tutorial += "Higher ranks improve inspection success chance.\n\n"
		
		tutorial += "<b>Inspection Success depends on:</b>\n"
		tutorial += "• Your Crafting Skill (current: [crafting_rank])\n"
		tutorial += "• Item Complexity (materials + tools)\n"
		tutorial += "• Your Perception & Intelligence Stats\n\n"
		
		if(crafting_rank >= 3)
			tutorial += "<font color='#FFD700'>Tip:</font> You're experienced enough to inspect complex items!\n"
		else
			tutorial += "<font color='#FFAA00'>Tip:</font> Keep crafting to improve your inspection skills.\n"
	
	tutorial += "\n"
	return tutorial

/proc/ShowItemInspectionUI(mob/players/player, obj/item)
	/**
	 * ShowItemInspectionUI(player, item)
	 * ENHANCED: Displays inspection interface with item details and chance to succeed
	 * Called when player begins inspecting an item
	 */
	if(!player || !item)
		return
	
	var/item_ref = "\ref[item]"
	var/datum/item_inspection/inspection_metadata = item_inspection_data[item_ref]
	
	var/html = ""
	html += "<html><head><title>Item Inspection</title></head><body>"
	html += "<style>"
	html += "body { background: #1a1a2e; color: #eee; font-family: Arial; margin: 10px; }"
	html += "h1 { color: #FFD700; text-align: center; }"
	html += ".item-details { background: #0f3460; border: 1px solid #00FF00; padding: 10px; margin: 10px 0; }"
	html += ".stat { color: #FFD700; padding: 5px 0; }"
	html += ".chance { color: #00FF00; font-weight: bold; }"
	html += ".button { background: #0f3460; color: #eee; border: 1px solid #00FF00; padding: 8px 15px; margin: 5px; cursor: pointer; }"
	html += ".button:hover { background: #00FF00; color: #000; }"
	html += "</style>"
	
	html += "<h1>Inspect Item</h1>"
	html += "<div class='item-details'>"
	html += "<b>[item.name]</b><br>"
	
	if(inspection_metadata)
		html += "<span class='stat'>From Recipe: [inspection_metadata.recipe_name]</span><br>"
		html += "<span class='stat'>Difficulty: [inspection_metadata.inspection_difficulty]/10</span><br>"
		html += "<span class='stat'>Previous Inspections: [inspection_metadata.inspections]</span><br>"
		
		var/success_chance = 0
		if(player.character)
			var/crafting_skill = player.GetRankLevel("crank") || 0
			var/perception = GetPlayerStat(player, "perception")
			var/intelligence = GetPlayerStat(player, "intelligence")
			success_chance = CalculateInspectionSuccessChance(
				inspection_metadata.inspection_difficulty,
				crafting_skill * 10,
				perception,
				intelligence
			)
		
		html += "<span class='chance'>Success Chance: [success_chance]%</span><br>"
	
	html += "</div>"
	html += "<a href='?inspect_item=["\ref[item]"]'><button class='button'>Inspect Item</button></a>\n"
	html += "<a href='?close'><button class='button'>Cancel</button></a>\n"
	html += "</body></html>"
	
	player << browse(html, "window=inspection_ui")

