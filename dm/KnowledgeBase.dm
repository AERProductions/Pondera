/**
 * PONDERA KNOWLEDGE BASE SYSTEM
 * =============================
 * Central registry for all game recipes, crafting knowledge, and progression data
 * Serves as the foundation for:
 * - Interactive tech tree UI
 * - Tutorial system integration
 * - Recipe discovery tracking
 * - Biome/elevation/season gating
 * 
 * Data Structure:
 * KNOWLEDGE["recipe_key"] = /datum/recipe_entry
 * 
 * Each recipe_entry contains:
 * - Display info (name, description, icon)
 * - Requirements (skill, tier, biome, elevation, season, fire)
 * - Inputs/outputs (ingredients, products)
 * - Progression data (tier, category, prerequisites)
 */

// Global knowledge base registry
var/list/KNOWLEDGE = list()

/datum/recipe_entry
	var
		// Display information
		recipe_key = ""           // Unique identifier (e.g., "stone_hammer")
		name = ""                 // Display name
		description = ""          // Flavor text and explanation
		icon_state = ""           // Associated icon
		tier = ""                 // "rudimentary", "basic", "intermediate", "advanced"
		category = ""             // "tools", "weapons", "shelter", "containers", "lighting", etc.
		
		// Crafting information
		workstation_type = ""     // "none" (inventory), "fire", "oven", "forge", "anvil", "workbench", "cauldron"
		inputs = list()           // List of required ingredients
		outputs = list()          // List of produced items
		
		// Gating & requirements
		requires_fire = FALSE     // Must have active fire to craft
		skill_requirement = ""    // Skill type (e.g., RANK_SMITHING)
		skill_level_min = 0       // Minimum skill level (1-5)
		
		// Biome & environment requirements
		biomes_allowed = list()   // List of allowed biomes ("temperate", "arctic", "desert", etc.)
		elevation_min = 0         // Minimum elevation (0.0 = ground level)
		elevation_max = 999       // Maximum elevation
		
		// Season gating
		seasons_allowed = list()  // List of allowed seasons ("Spring", "Summer", "Autumn", "Winter")
		
		// Weather/environmental
		weather_blocked = list()  // Weather that blocks this recipe ("heavy_rain", "blizzard", etc.)
		temperature_min = -100    // Minimum temperature (C) to craft
		temperature_max = 100     // Maximum temperature to craft
		
		// Progression
		prerequisites = list()    // List of recipe keys that must be discovered first
		unlocks_recipes = list()  // List of recipes this unlocks
		
		// Gameplay mechanics
		experience_reward = 0     // XP granted on successful craft
		quality_modifier = 0.1    // Quality impact (0.1 = 10% quality variation)
		
		// Tutorial & discovery
		discovery_method = ""     // "experimentation", "npc_teaching", "inspection", "environmental"
		tutorial_step = 0         // Step in guided tutorial (0 = not in tutorial)
		is_hidden = FALSE         // Hidden from knowledge base until discovered

/proc/InitializeKnowledgeBase()
	/**
	 * Initialize all recipe entries
	 * Called during world boot (Phase 5)
	 */
	
	// ========================================================================
	// RUDIMENTARY TIER - Starting with nothing
	// ========================================================================
	// These recipes require only what you can find/gather with bare hands
	
	KNOWLEDGE["stick"] = new /datum/recipe_entry(
		recipe_key = "stick",
		name = "Gather Sticks",
		description = "Search fallen branches and sticks on the ground. Essential for kindling and basic tools.",
		icon_state = "stick",
		tier = "rudimentary",
		category = "materials",
		workstation_type = "none",
		inputs = list(),
		outputs = list("stick" = 1),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 0,
		discovery_method = "environmental",
		tutorial_step = 1
	)
	
	KNOWLEDGE["flint"] = new /datum/recipe_entry(
		recipe_key = "flint",
		name = "Search for Flint",
		description = "Search rocks, flowers, and tall grass for sharp flint stones. Used for fire-starting and tool-making.",
		icon_state = "flint",
		tier = "rudimentary",
		category = "materials",
		workstation_type = "none",
		inputs = list(),
		outputs = list("flint" = 1),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "arctic", "desert"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 5,
		discovery_method = "environmental",
		tutorial_step = 2
	)
	
	KNOWLEDGE["pyrite"] = new /datum/recipe_entry(
		recipe_key = "pyrite",
		name = "Search for Pyrite",
		description = "Fool's gold. Strike flint against pyrite to create sparks for fire-starting.",
		icon_state = "pyrite",
		tier = "rudimentary",
		category = "materials",
		workstation_type = "none",
		inputs = list(),
		outputs = list("pyrite" = 1),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "desert"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 5,
		discovery_method = "environmental",
		tutorial_step = 2
	)
	
	KNOWLEDGE["kindling"] = new /datum/recipe_entry(
		recipe_key = "kindling",
		name = "Create Kindling",
		description = "Bundle sticks together into kindling. Essential fuel for starting fires.",
		icon_state = "kindling",
		tier = "rudimentary",
		category = "materials",
		workstation_type = "none",
		inputs = list("stick" = 3),
		outputs = list("kindling" = 1),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 10,
		discovery_method = "experimentation",
		tutorial_step = 3
	)
	
	KNOWLEDGE["campfire_light"] = new /datum/recipe_entry(
		recipe_key = "campfire_light",
		name = "Light a Campfire",
		description = "Strike flint against pyrite to light kindling. Creates warmth, light, and enables cooking.",
		icon_state = "campfire",
		tier = "rudimentary",
		category = "fire",
		workstation_type = "none",
		inputs = list("flint" = 1, "pyrite" = 1, "kindling" = 1),
		outputs = list("campfire" = 1),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 20,
		discovery_method = "experimentation",
		tutorial_step = 4,
		unlocks_recipes = list("cook_meat", "smelt_ore")
	)
	
	KNOWLEDGE["obsidian_knife"] = new /datum/recipe_entry(
		recipe_key = "obsidian_knife",
		name = "Assemble Obsidian Knife",
		description = "Combine obsidian shard + wooden handle. Your first cutting tool. Enables carving and wood processing.",
		icon_state = "obsidian_knife",
		tier = "rudimentary",
		category = "tools",
		workstation_type = "none",
		inputs = list("obsidian_shard" = 1, "wooden_handle" = 1),
		outputs = list("obsidian_knife" = 1),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "desert"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 25,
		discovery_method = "experimentation",
		tutorial_step = 5,
		unlocks_recipes = list("carve_haunch", "cut_firewood")
	)
	
	KNOWLEDGE["stone_hammer"] = new /datum/recipe_entry(
		recipe_key = "stone_hammer",
		name = "Assemble Stone Hammer",
		description = "Combine rock + wooden haunch. Basic striking tool for breaking stone and building.",
		icon_state = "stone_hammer",
		tier = "rudimentary",
		category = "tools",
		workstation_type = "none",
		inputs = list("rock" = 1, "wooden_haunch" = 1),
		outputs = list("stone_hammer" = 1),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 25,
		discovery_method = "experimentation",
		tutorial_step = 5,
		unlocks_recipes = list("break_stone", "dig_dirt")
	)
	
	KNOWLEDGE["ueik_pickaxe"] = new /datum/recipe_entry(
		recipe_key = "ueik_pickaxe",
		name = "Assemble Ueik Pickaxe",
		description = "Combine ueik thorn + wooden handle. Enables mining ore from stone.",
		icon_state = "ueik_pickaxe",
		tier = "rudimentary",
		category = "tools",
		workstation_type = "none",
		inputs = list("ueik_thorn" = 1, "wooden_handle" = 1),
		outputs = list("ueik_pickaxe" = 1),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 25,
		discovery_method = "experimentation",
		tutorial_step = 6,
		unlocks_recipes = list("mine_ore")
	)
	
	KNOWLEDGE["carve_haunch"] = new /datum/recipe_entry(
		recipe_key = "carve_haunch",
		name = "Carve Wooden Haunch",
		description = "Use obsidian knife to shape wood into a haunch. Crafting material for tools and handles.",
		icon_state = "wooden_haunch",
		tier = "rudimentary",
		category = "materials",
		workstation_type = "none",
		inputs = list("obsidian_knife" = 1, "ueik_wood" = 1),
		outputs = list("wooden_haunch" = 2),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 15,
		discovery_method = "npc_teaching"
	)
	
	KNOWLEDGE["cook_meat"] = new /datum/recipe_entry(
		recipe_key = "cook_meat",
		name = "Cook Meat",
		description = "Cook raw meat over a campfire. Improves nutrition and safety.",
		icon_state = "cooked_meat",
		tier = "rudimentary",
		category = "cooking",
		workstation_type = "fire",
		inputs = list("raw_meat" = 1),
		outputs = list("cooked_meat" = 1),
		requires_fire = TRUE,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 10,
		discovery_method = "experimentation"
	)
	
	KNOWLEDGE["mine_ore"] = new /datum/recipe_entry(
		recipe_key = "mine_ore",
		name = "Mine Ore from Stone",
		description = "Use pickaxe to mine ore-bearing rock. First step toward metal tools.",
		icon_state = "iron_ore",
		tier = "rudimentary",
		category = "mining",
		workstation_type = "none",
		inputs = list("ueik_pickaxe" = 1),
		outputs = list("iron_ore" = 1),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 20,
		discovery_method = "npc_teaching",
		unlocks_recipes = list("smelt_ore", "mine_copper", "mine_tin")
	)
	
	KNOWLEDGE["mine_copper"] = new /datum/recipe_entry(
		recipe_key = "mine_copper",
		name = "Mine Copper Ore",
		description = "Use bronze pickaxe to extract copper ore from ore-bearing rock. Found in mountainous regions.",
		icon_state = "copper_ore",
		tier = "intermediate",
		category = "mining",
		workstation_type = "none",
		inputs = list("bronze_pickaxe_head_cool" = 1),
		outputs = list("copper_ore" = 1),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "arctic", "desert"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 30,
		discovery_method = "npc_teaching",
		prerequisites = list("smelt_bronze"),
		unlocks_recipes = list("smelt_copper")
	)
	
	KNOWLEDGE["mine_tin"] = new /datum/recipe_entry(
		recipe_key = "mine_tin",
		name = "Mine Tin Ore",
		description = "Use bronze pickaxe to extract tin ore from ore-bearing rock. Rare in most biomes.",
		icon_state = "tin_ore",
		tier = "intermediate",
		category = "mining",
		workstation_type = "none",
		inputs = list("bronze_pickaxe_head_cool" = 1),
		outputs = list("tin_ore" = 1),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "desert"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 35,
		discovery_method = "npc_teaching",
		prerequisites = list("smelt_bronze"),
		unlocks_recipes = list("smelt_tin")
	)
	
	// ========================================================================
	// BASIC TIER - Fire mastery and first metal tools
	// ========================================================================
	
	KNOWLEDGE["smelt_ore"] = new /datum/recipe_entry(
		recipe_key = "smelt_ore",
		name = "Smelt Iron Ore",
		description = "Heat iron ore in a campfire to extract raw iron. First metal!",
		icon_state = "iron_ingot",
		tier = "basic",
		category = "smelting",
		workstation_type = "fire",
		inputs = list("iron_ore" = 2, "kindling" = 1),
		outputs = list("iron_ingot" = 1),
		requires_fire = TRUE,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 30,
		discovery_method = "npc_teaching",
		prerequisites = list("campfire_light"),
		unlocks_recipes = list("forge_hammer_head", "forge_pickaxe_head")
	)
	
	KNOWLEDGE["forge_hammer_head"] = new /datum/recipe_entry(
		recipe_key = "forge_hammer_head",
		name = "Forge Hammer Head",
		description = "Shape hot iron into a hammer head. Requires forge with active fire.",
		icon_state = "hammer_head",
		tier = "basic",
		category = "smithing",
		workstation_type = "forge",
		inputs = list("iron_ingot" = 1, "kindling" = 1),
		outputs = list("hammer_head_unrefined" = 1),
		requires_fire = TRUE,
		skill_requirement = RANK_SMITHING,
		skill_level_min = 1,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 40,
		discovery_method = "npc_teaching",
		prerequisites = list("smelt_ore")
	)
	
	KNOWLEDGE["make_jar"] = new /datum/recipe_entry(
		recipe_key = "make_jar",
		name = "Make Ceramic Jar",
		description = "Shape clay and bake in an oven. Enables water/resource storage and transport.",
		icon_state = "jar_empty",
		tier = "basic",
		category = "containers",
		workstation_type = "oven",
		inputs = list("clay" = 3, "kindling" = 1),
		outputs = list("jar_empty" = 1),
		requires_fire = TRUE,
		biomes_allowed = list("temperate", "arctic", "desert"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 25,
		discovery_method = "npc_teaching",
		prerequisites = list("campfire_light")
	)
	
	KNOWLEDGE["craft_tent"] = new /datum/recipe_entry(
		recipe_key = "craft_tent",
		name = "Craft Rudimentary Tent",
		description = "Shelter from branches and cloth. Provides warmth at night in temperate biomes.",
		icon_state = "tent",
		tier = "basic",
		category = "shelter",
		workstation_type = "none",
		inputs = list("wood_frame" = 1, "cloth_bundle" = 1),
		outputs = list("tent" = 1),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 50,
		discovery_method = "npc_teaching"
	)
	
	// ========================================================================
	// INTERMEDIATE TIER - Tool specialization
	// ========================================================================
	
	KNOWLEDGE["file_hammer_head"] = new /datum/recipe_entry(
		recipe_key = "file_hammer_head",
		name = "File Hammer Head",
		description = "Refine unrefined hammer head at anvil. Progressive quality improvement.",
		icon_state = "hammer_head",
		tier = "intermediate",
		category = "smithing",
		workstation_type = "anvil",
		inputs = list("hammer_head_unrefined" = 1),
		outputs = list("hammer_head_filed" = 1),
		requires_fire = FALSE,
		skill_requirement = RANK_SMITHING,
		skill_level_min = 1,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 30,
		discovery_method = "experimentation"
	)
	
	KNOWLEDGE["sharpen_hammer_head"] = new /datum/recipe_entry(
		recipe_key = "sharpen_hammer_head",
		name = "Sharpen Hammer Head",
		description = "Use whetstone to sharpen filed hammer head. Critical for performance.",
		icon_state = "hammer_head",
		tier = "intermediate",
		category = "smithing",
		workstation_type = "none",
		inputs = list("hammer_head_filed" = 1, "whetstone" = 1),
		outputs = list("hammer_head_sharp" = 1),
		requires_fire = FALSE,
		skill_requirement = RANK_SMITHING,
		skill_level_min = 2,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 35,
		discovery_method = "experimentation"
	)
	
	KNOWLEDGE["quench_hammer_head"] = new /datum/recipe_entry(
		recipe_key = "quench_hammer_head",
		name = "Quench Hammer Head",
		description = "Cool sharpened hammer head in water. Final hardening step.",
		icon_state = "hammer_head",
		tier = "intermediate",
		category = "smithing",
		workstation_type = "none",
		inputs = list("hammer_head_sharp" = 1, "water" = 1),
		outputs = list("hammer_head_cool" = 1),
		requires_fire = FALSE,
		skill_requirement = RANK_SMITHING,
		skill_level_min = 1,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 40,
		discovery_method = "experimentation"
	)
	
	// ========================================================================
	// INTERMEDIATE TIER - Alloys & Complex Materials
	// ========================================================================
	
	KNOWLEDGE["smelt_tin"] = new /datum/recipe_entry(
		recipe_key = "smelt_tin",
		name = "Smelt Tin Ore",
		description = "Heat tin ore in a campfire to extract raw tin. Softer than iron, used in bronze alloys.",
		icon_state = "tin_ingot",
		tier = "intermediate",
		category = "smelting",
		workstation_type = "fire",
		inputs = list("tin_ore" = 2, "kindling" = 1),
		outputs = list("tin_ingot" = 1),
		requires_fire = TRUE,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 35,
		discovery_method = "npc_teaching",
		prerequisites = list("smelt_ore"),
		unlocks_recipes = list("smelt_bronze")
	)
	
	KNOWLEDGE["smelt_bronze"] = new /datum/recipe_entry(
		recipe_key = "smelt_bronze",
		name = "Smelt Bronze Alloy",
		description = "Heat copper + tin in a forge to create bronze. More durable than iron, excellent for tools and weapons.",
		icon_state = "bronze_ingot",
		tier = "intermediate",
		category = "smelting",
		workstation_type = "forge",
		inputs = list("copper_ingot" = 1, "tin_ingot" = 1, "kindling" = 1),
		outputs = list("bronze_ingot" = 1),
		requires_fire = TRUE,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 50,
		discovery_method = "npc_teaching",
		prerequisites = list("smelt_ore", "smelt_tin"),
		unlocks_recipes = list("forge_bronze_hammer_head", "forge_bronze_pickaxe_head")
	)
	
	KNOWLEDGE["forge_bronze_hammer_head"] = new /datum/recipe_entry(
		recipe_key = "forge_bronze_hammer_head",
		name = "Forge Bronze Hammer Head",
		description = "Shape hot bronze into a hammer head. Bronze tools are superior to iron.",
		icon_state = "hammer_head",
		tier = "intermediate",
		category = "smithing",
		workstation_type = "forge",
		inputs = list("bronze_ingot" = 1, "kindling" = 1),
		outputs = list("bronze_hammer_head_unrefined" = 1),
		requires_fire = TRUE,
		skill_requirement = RANK_SMITHING,
		skill_level_min = 2,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 55,
		discovery_method = "npc_teaching",
		prerequisites = list("smelt_bronze", "forge_hammer_head")
	)
	
	KNOWLEDGE["forge_bronze_pickaxe_head"] = new /datum/recipe_entry(
		recipe_key = "forge_bronze_pickaxe_head",
		name = "Forge Bronze Pickaxe Head",
		description = "Shape hot bronze into a pickaxe head. Enables mining higher-tier ores.",
		icon_state = "pickaxe_head",
		tier = "intermediate",
		category = "smithing",
		workstation_type = "forge",
		inputs = list("bronze_ingot" = 1, "kindling" = 1),
		outputs = list("bronze_pickaxe_head_unrefined" = 1),
		requires_fire = TRUE,
		skill_requirement = RANK_SMITHING,
		skill_level_min = 2,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 55,
		discovery_method = "npc_teaching",
		prerequisites = list("smelt_bronze")
	)
	
	KNOWLEDGE["smelt_copper"] = new /datum/recipe_entry(
		recipe_key = "smelt_copper",
		name = "Smelt Copper Ore",
		description = "Heat copper ore in a campfire to extract raw copper. Excellent thermal conductor, used in bronzes and brasses.",
		icon_state = "copper_ingot",
		tier = "intermediate",
		category = "smelting",
		workstation_type = "fire",
		inputs = list("copper_ore" = 2, "kindling" = 1),
		outputs = list("copper_ingot" = 1),
		requires_fire = TRUE,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 40,
		discovery_method = "npc_teaching",
		prerequisites = list("smelt_ore"),
		unlocks_recipes = list("smelt_bronze")
	)
	
	// ========================================================================
	// ADVANCED TIER - Specialization & complex crafting
	// ========================================================================
	
	// Placeholder for advanced recipes
	// Will be expanded as gameplay systems develop
	
	world.log << "\[KNOWLEDGE BASE\] Initialized [KNOWLEDGE.len] recipes"

/proc/GetRecipeEntry(recipe_key)
	/**
	 * Retrieve a recipe entry from knowledge base
	 * Returns: /datum/recipe_entry or null
	 */
	return KNOWLEDGE[recipe_key]

/proc/GetRecipesByTier(tier)
	/**
	 * Get all recipes for a specific tier
	 * tier: "rudimentary", "basic", "intermediate", "advanced"
	 */
	var/list/recipes = list()
	for(var/key in KNOWLEDGE)
		var/datum/recipe_entry/recipe = KNOWLEDGE[key]
		if(recipe.tier == tier)
			recipes[key] = recipe.name
	return recipes

/proc/GetRecipesByCategory(category)
	/**
	 * Get all recipes in a specific category
	 * category: "tools", "weapons", "cooking", "smithing", "shelter", etc.
	 */
	var/list/recipes = list()
	for(var/key in KNOWLEDGE)
		var/datum/recipe_entry/recipe = KNOWLEDGE[key]
		if(recipe.category == category)
			recipes[key] = recipe.name
	return recipes

/proc/GetRecipesByWorkstation(workstation_type)
	/**
	 * Get all recipes that use a specific workstation
	 * workstation_type: "fire", "forge", "anvil", "oven", "none", etc.
	 */
	var/list/recipes = list()
	for(var/key in KNOWLEDGE)
		var/datum/recipe_entry/recipe = KNOWLEDGE[key]
		if(recipe.workstation_type == workstation_type)
			recipes[key] = recipe.name
	return recipes

/proc/GetRecipesByBiome(biome)
	/**
	 * Get all recipes available in a specific biome
	 */
	var/list/recipes = list()
	for(var/key in KNOWLEDGE)
		var/datum/recipe_entry/recipe = KNOWLEDGE[key]
		if(biome in recipe.biomes_allowed)
			recipes[key] = recipe.name
	return recipes

/proc/GetRecipesBySkill(skill_type, skill_level)
	/**
	 * Get all recipes unlocked for a specific skill level
	 */
	var/list/recipes = list()
	for(var/key in KNOWLEDGE)
		var/datum/recipe_entry/recipe = KNOWLEDGE[key]
		if(recipe.skill_requirement == skill_type && recipe.skill_level_min <= skill_level)
			recipes[key] = recipe.name
	return recipes

/proc/CanCraftRecipe(mob/players/player, recipe_key)
	/**
	 * Check if player meets all requirements to craft a recipe
	 * Returns: TRUE/FALSE with reason message
	 */
	var/datum/recipe_entry/recipe = KNOWLEDGE[recipe_key]
	if(!recipe)
		return FALSE  // Recipe doesn't exist
	
	// Check skill requirement
	if(recipe.skill_requirement != "")
		var/skill_level = player.GetRankLevel(recipe.skill_requirement)
		if(skill_level < recipe.skill_level_min)
			return FALSE  // Skill too low
	
	// Check elevation
	if(player.elevel < recipe.elevation_min || player.elevel > recipe.elevation_max)
		return FALSE  // Wrong elevation
	
	// Check season (if gating enabled - future: implement world.season)
	// TODO: Implement world.season system
	// if(recipe.seasons_allowed.len > 0)
	// 	if(!(world.season in recipe.seasons_allowed))
	// 		return FALSE  // Wrong season
	
	// Check fire requirement
	if(recipe.requires_fire)
		if(!HasAccessToFire(player))
			return FALSE  // No fire available
	
	// Check prerequisites
	for(var/prereq in recipe.prerequisites)
		if(!player.character.recipe_state.IsRecipeDiscovered(prereq))
			return FALSE  // Prerequisite not discovered
	
	return TRUE

/proc/HasAccessToFire(mob/players/player)
	/**
	 * Check if player is near an active fire source
	 * Returns: TRUE/FALSE
	 * 
	 * Future: Check for campfire, forge, oven, smelter, torch, brazier nearby
	 */
	// TODO: Implement actual fire detection
	// For now, placeholder
	return FALSE
