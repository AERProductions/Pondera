// ItemInspectionSystem.dm - Item Examination & Reverse-Recipe Discovery
// Allows players to inspect items and learn recipes by examining crafted goods
// Enables discovery pathway: Item Analysis -> Recipe Unlock

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
		
		// Recipe connection
		recipe_id = 0                   // Which recipe created this item
		recipe_name = ""                // Name of the recipe
		recipe_category = ""            // Craft category
		
		// Crafting details
		materials_used = list()         // What was used to craft this (list of items)
		tools_required = list()         // What tools were needed
		skill_level_created = 0         // What skill level created this
		created_by = ""                 // Who crafted it
		created_time = 0                // When it was crafted
		
		// Inspection metadata
		inspections = 0                 // How many times inspected
		first_inspection_time = 0       // When first examined
		inspection_difficulty = 0       // How hard to learn from this item (1-10)
		discoverable = 1                // Can this item teach recipes?

/datum/inspection_result
	/**
	 * inspection_result
	 * Result of inspecting an item - what can be learned?
	 */
	var
		success = 0                     // Did inspection succeed?
		recipe_discovered = 0           // Did we learn a recipe?
		recipe_id = 0                   // Which recipe was discovered
		recipe_name = ""
		recipe_category = ""
		
		// Skill checks
		perception_check = 0            // Difficulty rating (1-100)
		crafting_check = 0              // Required crafting skill (1-100)
		intelligence_check = 0          // Required intelligence (1-100)
		
		// Rewards
		experience_gained = 0
		insight_points = 0
		message = ""                    // Description of what was learned

// ============================================================================
// GLOBAL INSPECTION SYSTEM
// ============================================================================

var
	global/list/item_recipe_map = list()    // Maps item ID to recipe ID
	global/list/inspected_items = list()    // Track which items have been inspected
	global/list/item_inspection_data = list()  // Maps item ref to inspection metadata
	global/inspection_skill_threshold = 30  // Min crafting skill to attempt inspection

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
	
	// Calculate inspection difficulty based on recipe complexity
	inspection_metadata.inspection_difficulty = CalculateInspectionDifficulty(materials_used.len, tools_required.len)
	
	// Store in global map using item ref as key
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
	
	// Each material adds difficulty
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
	
	// Check minimum crafting skill threshold
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
		result.insight_points = 5 + inspection_metadata.inspection_difficulty  // 6-15 insight points
		result.message = "You carefully examined [item.name] and learned how to craft: [inspection_metadata.recipe_name]!"
		
		// Mark item as inspected
		inspected_items[item_key] = world.time
		
		// Award experience
		if(result.experience_gained > 0)
			AwardPlayerExperience(inspector, "crafting", result.experience_gained)
		
		// Log discovery
		world.log << "INSPECTION: [inspector.key] discovered recipe [inspection_metadata.recipe_name] by inspecting [item.name]"
	else
		result.success = 0
		result.message = "You examine [item.name] carefully, but can't quite figure out how it was made..."
		
		// Small experience for failed attempt
		AwardPlayerExperience(inspector, "crafting", max(1, result.experience_gained / 3))
	
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
	var/base_chance = 50 + (skill_vs_difficulty * 1.5)  // Each skill point above needed = +1.5%
	
	// Perception helps with observation
	var/perception_bonus = (perception - 50) * 0.2  // +/- 0.2% per perception point
	
	// Intelligence helps with analysis
	var/intelligence_bonus = (intelligence - 50) * 0.15  // +/- 0.15% per intelligence point
	
	var/final_chance = base_chance + perception_bonus + intelligence_bonus
	
	// Clamp to 5-95 range (never guaranteed, never impossible)
	final_chance = max(5, min(95, final_chance))
	
	return final_chance

/proc/CalculateInspectionExperience(difficulty, crafting_skill)
	/**
	 * CalculateInspectionExperience(difficulty, crafting_skill)
	 * Calculates experience gained from successful inspection
	 * Harder items and lower skill levels = more experience
	 */
	var/base_exp = difficulty * 20  // Difficulty 1-10 = 20-200 base exp
	var/skill_penalty = max(0, (crafting_skill - (difficulty * 8)) / 10)  // Reduce for high skill
	
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
	
	// Safely get list lengths using length() function instead of .len
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
	 * Returns: stat value or 50 (default) if not found
	 * This is a placeholder - connect to actual stat system
	 */
	if(!player) return 50
	
	// Returns default value of 50 for all stats
	// TODO: Connect to actual stat system when available
	return 50

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
	var/rank_type = skill_type  // skill_type should be RANK_* constant
	player.UpdateRankExp(rank_type, amount)
	world.log << "[player.key] gained [amount] [rank_type] experience"

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
	 * Formats and displays inspection result to player
	 */
	if(!player || !result) return
	
	var/output = ""
	
	output += "--- ITEM INSPECTION RESULT ---\n"
	
	if(result.success)
		output += "<font color='green'>[result.message]</font>\n"
		
		if(result.recipe_discovered)
			output += "\nRecipe Learned: <b>[result.recipe_name]</b>\n"
			output += "Category: [result.recipe_category]\n"
			output += "Experience Gained: [result.experience_gained]\n"
			output += "Insight Points: [result.insight_points]\n"
	else
		output += "<font color='orange'>[result.message]</font>\n"
	
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

