/**
 * ASCENSION MODE SYSTEM - Stage 6
 * ================================
 * A 4th game mode variant that emphasizes peaceful exploration, 
 * unlimited progression, and creative freedom without pressure.
 * 
 * ASCENSION MODE PHILOSOPHY
 * ==========================
 * A "Creative Peaceful Mastery" mode that combines the best of all worlds:
 * - Peaceful gameplay: NO PvP, NO raiding, NO hunger/thirst pressure
 * - Unlimited exploration: ALL recipes available immediately, NO skill gates
 * - Perfect for: Speedrunners, creative builders, recipe testers, chill players
 * - Progression: Focuses on crafting mastery and creative expression
 * 
 * DIFFERS FROM OTHER MODES
 * ========================
 * Story:   - Has narrative, NPCs, quest progression, gated recipes
 *          - Survival mechanics (hunger/thirst) enforce pacing
 *          - Designed for 20-40 hour first playthrough
 * 
 * Sandbox: - Peaceful, creative building focus
 *          - All recipes unlocked, no pressure
 *          - NO hunger/thirst, NO deeds, NO economy
 *          - Designed for builders testing ideas
 * 
 * Ascension: - Peaceful + exploration focus
 *            - All recipes + NPCs available (unlike sandbox)
 *            - No hunger/thirst, no deed costs, no pacing gates
 *            - Full multi-world travel enabled
 *            - Economy enabled but no scarcity mechanics
 *            - Perfect for "mastering all crafts" runs
 *            - ONE-WAY progression: Can enter Ascension from any mode,
 *              but cannot export ascension character back to other modes
 *              (anti-cheese: prevents farming mastery then seeding Story)
 */

// ============================================================================
// ASCENSION MODE CONFIGURATION
// ============================================================================

/datum/ascension_mode_config
	var
		// Identity & description
		name = "Ascension Mode"
		description = "Peaceful exploration & creative mastery - no pressure, all recipes, full freedom"
		id = "ascension"
		
		// Core gameplay toggles
		allow_pvp = FALSE
		allow_stealing = FALSE
		allow_building = TRUE
		allow_hunger = FALSE           // No hunger/thirst pressure
		allow_weather = FALSE          // No environmental threats
		allow_monster_spawn = FALSE    // No hostile creatures
		allow_npc_spawn = TRUE         // NPCs present (unlike sandbox)
		allow_deed_system = FALSE      // No territory claiming
		allow_deed_costs = FALSE       // No maintenance fees
		
		// Recipe & progression system
		unlock_all_recipes = TRUE      // All recipes available immediately
		disable_skill_gates = TRUE     // No RANK_X level requirements
		disable_prerequisites = TRUE   // Can craft anything regardless of chain
		skip_recipe_discovery = TRUE   // Recipes start discovered
		instant_rank_advancement = TRUE // Can manually set skill levels
		
		// Economy & resources
		abundant_resources = TRUE      // Resources spawn infinitely
		free_market = TRUE             // No price inflation/deflation
		free_trading = TRUE            // Trade without scarcity pressure
		infinite_inventory = FALSE     // Inventory space still limited (fair)
		
		// Exploration & travel
		enable_multi_world = TRUE      // Can travel all 3 continents + ascension realm
		unlock_all_portals = TRUE      // All travel points accessible
		no_travel_cooldown = TRUE      // Instant continent switching
		no_travel_cost = TRUE          // Free travel between worlds
		
		// Quality of life
		instant_crafting = FALSE       // Still respects crafting time (immersion)
		enhanced_lighting = TRUE       // Better visibility for creative work
		show_recipe_hints = TRUE       // Tooltips for all recipes
		free_respawn = TRUE            // Instant respawn on death
		no_item_loss_on_death = TRUE   // Keep items when dying

// ============================================================================
// INITIALIZATION & CONTINENT SETUP
// ============================================================================

var/datum/ascension_mode_config/ascension_config = null

/proc/InitializeAscensionMode()
	/**
	 * Create and configure Ascension Mode
	 * Called during world initialization after other continents are ready
	 */
	if(ascension_config)
		return TRUE  // Already initialized
	
	ascension_config = new /datum/ascension_mode_config()
	
	// Create Ascension Realm continent variant
	var/datum/continent/ascension_realm = new(CONT_ASCENSION, "Ascension Realm")
	ascension_realm.desc = "Peaceful creative realm - all recipes, no pressure, perfect for mastery"
	ascension_realm.type_flags = CONTINENT_PEACEFUL | CONTINENT_CREATIVE
	ascension_realm.generator_type = "ascension_creative"
	ascension_realm.seed = 99999
	
	// Gameplay rules (mirrored from config)
	ascension_realm.allow_pvp = 0
	ascension_realm.allow_stealing = 0
	ascension_realm.allow_building = 1
	ascension_realm.monster_spawn = 0
	ascension_realm.npc_spawn = 1       // Unique: NPCs present (unlike sandbox)
	ascension_realm.weather = 0
	
	// Spawn point at a grand creative hub
	ascension_realm.port_x = 150
	ascension_realm.port_y = 150
	ascension_realm.port_z = 1
	
	// Register in global continents list
	continents[CONT_ASCENSION] = ascension_realm
	
	world.log << "\[ASCENSION\] Mode initialized - Peaceful realm unlocked for creative players"
	return TRUE

// ============================================================================
// PLAYER ASCENSION MODE SETUP
// ============================================================================

/proc/SetupPlayerForAscensionMode(mob/players/player)
	/**
	 * Configure player for Ascension Mode experience
	 * Called when player creates character in Ascension Mode
	 */
	if(!player || !player.character)
		return FALSE
	
	// Disable hunger/thirst mechanics
	player.hunger_level = 0
	player.thirst_level = 0
	
	// Enable deed permissions (player object, not character)
	player.canbuild = TRUE
	player.canpickup = TRUE
	player.candrop = TRUE
	
	// Disable deed restrictions on character data
	player.character.disable_deed_costs = TRUE
	player.character.disable_deed_system = TRUE
	
	// Unlock all recipes in player's recipe state
	UnlockAllRecipesForPlayer(player)
	
	// Set all skills to level 5 (mastery) - optional, can be level 1
	SetPlayerAllSkillsToLevel(player, 1)
	
	// Grant infinite inventory space concept (still has carrying limit)
	player.character.inventory_expanded = TRUE
	
	// Enable multi-world travel
	player.character.can_travel_all_continents = TRUE
	
	// Mark player as in Ascension Mode
	player.character.game_mode = "ascension"
	player.character.ascension_mode_active = TRUE
	
	world.log << "\[ASCENSION\] [player.ckey] configured for Ascension Mode"
	return TRUE

// ============================================================================
// RECIPE UNLOCKING - Ascension Style
// ============================================================================

/proc/UnlockAllRecipesForPlayer(mob/players/player)
	/**
	 * Unlock all recipes in knowledge base for player
	 * In Ascension Mode, no discovery gates - everything available
	 */
	if(!player || !KNOWLEDGE)
		return FALSE
	
	var/recipes_unlocked = 0
	for(var/recipe_key in KNOWLEDGE)
		if(player.character && player.character.recipe_state)
			// Mark as discovered through "ascension_mode" method
			if(player.character.recipe_state.IsRecipeDiscovered(recipe_key) == FALSE)
				player.character.recipe_state.DiscoverRecipe(recipe_key, "ascension_mode")
				recipes_unlocked++
	
	world.log << "\[ASCENSION\] [player.ckey] unlocked [recipes_unlocked] recipes"
	return TRUE

/proc/SetPlayerAllSkillsToLevel(mob/players/player, level)
	/**
	 * Set all skill ranks to specified level (1-5)
	 * In Ascension Mode, player can manually control skill progression
	 * Set to level 1 by default (skills unlock naturally as player crafts)
	 */
	if(!player || !player.character)
		return FALSE
	
	var/skill_types = list(
		RANK_BUILDING,
		RANK_SMITHING,
		RANK_FISHING,
		RANK_MINING,
		RANK_COOKING,
		RANK_CRAFTING,
		RANK_GARDENING,
		RANK_FARMING,
		RANK_WOODCUTTING,
		RANK_DIGGING,
		RANK_CARVING,
		RANK_SPROUTING,
		RANK_SMELTING,
		RANK_POLE
	)
	
	for(var/skill in skill_types)
		if(player.character)
			player.character.SetRankLevel(skill, level)
	
	world.log << "\[ASCENSION\] [player.ckey] skill levels set to [level]"
	return TRUE

// ============================================================================
// ASCENSION MODE FEATURE TOGGLES
// ============================================================================

/proc/EnableAscensionFeature(mob/players/player, feature_name)
	/**
	 * Enable specific Ascension Mode feature for testing
	 * Examples: instant_crafting, enhanced_lighting, free_respawn
	 */
	if(!player || !ascension_config)
		return FALSE
	
	switch(feature_name)
		if("instant_crafting")
			player.character.instant_crafting = TRUE
			player << "Instant crafting enabled"
		
		if("enhanced_lighting")
			player.character.enhanced_lighting = TRUE
			player << "Enhanced lighting enabled"
		
		if("free_respawn")
			player.character.free_respawn = TRUE
			player << "Free respawn enabled"
		
		if("show_hints")
			player.character.show_recipe_hints = TRUE
			player << "Recipe hints enabled"
		
		else
			return FALSE
	
	return TRUE

/proc/DisableAscensionFeature(mob/players/player, feature_name)
	/**
	 * Disable specific Ascension Mode feature
	 */
	if(!player || !ascension_config)
		return FALSE
	
	switch(feature_name)
		if("instant_crafting")
			player.character.instant_crafting = FALSE
			player << "Instant crafting disabled"
		
		if("enhanced_lighting")
			player.character.enhanced_lighting = FALSE
			player << "Enhanced lighting disabled"
		
		if("free_respawn")
			player.character.free_respawn = FALSE
			player << "Free respawn disabled"
		
		if("show_hints")
			player.character.show_recipe_hints = FALSE
			player << "Recipe hints disabled"
		
		else
			return FALSE
	
	return TRUE

// ============================================================================
// ASCENSION MODE PLAYER VERBS
// ============================================================================

/mob/players/verb/enter_ascension_realm()
	set name = "Travel to Ascension Realm"
	set category = "World"
	set desc = "Enter the peaceful Ascension Realm - creative mastery without pressure"
	
	if(!ascension_config)
		src << "Ascension Mode not yet initialized"
		return
	
	// Check if player is already in Ascension Mode
	if(src.character.ascension_mode_active)
		src << "You are already in Ascension Mode"
		return
	
	// ANTI-CHEESE: One-way progression enforcement
	// Once you enter Ascension Mode, you're locked into that character permanently
	// Cannot travel back to Story/Sandbox/PvP with ascension progress
	src.character.ascension_locked_in = TRUE
	
	// Travel to Ascension Realm
	var/result = TravelToContinentAsPlayer(src, CONT_ASCENSION)
	if(result)
		src << "<font color=#FFD700>Welcome to the Ascension Realm! All recipes unlocked, no pressure, infinite possibilities.</font>"
		src << "<font color=#FFA500>⚠ Note: Ascension Mode is one-way. Your progress here cannot be exported to other game modes.</font>"
		SetupPlayerForAscensionMode(src)
	else
		src << "Failed to enter Ascension Realm"

/mob/players/verb/ascension_mode_status()
	set name = "Ascension Mode Status"
	set category = "World"
	set desc = "View your Ascension Mode configuration"
	
	if(!ascension_config || !src.character.ascension_mode_active)
		src << "Ascension Mode not active"
		return
	
	var/status = "<font color=#FFD700><b>ASCENSION MODE STATUS</b></font>\n"
	status += "Mode: [ascension_config.name]\n"
	status += "Realm: Ascension Realm\n"
	status += "PvP Enabled: [ascension_config.allow_pvp ? "YES" : "NO"]\n"
	status += "Hunger/Thirst: [ascension_config.allow_hunger ? "YES" : "NO"]\n"
	status += "All Recipes Unlocked: [ascension_config.unlock_all_recipes ? "YES" : "NO"]\n"
	status += "Instant Crafting: [src.character.instant_crafting ? "YES" : "NO"]\n"
	status += "Multi-World Travel: [ascension_config.enable_multi_world ? "YES" : "NO"]\n"
	status += "Free Respawn: [src.character.free_respawn ? "YES" : "NO"]\n"
	src << status

/mob/players/verb/toggle_ascension_feature(feature as text)
	set name = "Toggle Ascension Feature"
	set category = "World"
	set desc = "Toggle specific Ascension Mode features"
	set hidden = 1
	
	if(!ascension_config || !src.character.ascension_mode_active)
		src << "Ascension Mode not active"
		return
	
	var/features = list("instant_crafting", "enhanced_lighting", "free_respawn", "show_hints")
	if(!(feature in features))
		src << "Unknown feature: [feature]"
		return
	
	// Toggle the feature
	if(src.character.vars[feature])
		DisableAscensionFeature(src, feature)
	else
		EnableAscensionFeature(src, feature)

// ============================================================================
// ASCENSION MODE INTEGRATION WITH MULTI-WORLD
// ============================================================================

/proc/EnableAscensionMultiWorldTravel(mob/players/player)
	/**
	 * Allow player to travel between Ascension Realm and other continents
	 * Enables full multi-world exploration with no gates
	 */
	if(!player)
		return FALSE
	
	player.character.can_travel_all_continents = TRUE
	player.character.multi_world_unlocked = TRUE
	
	return TRUE

// ============================================================================
// ASCENSION MODE KNOWLEDGE BASE ENTRIES
// ============================================================================

/proc/InitializeAscensionModeKnowledge()
	/**
	 * Add Ascension Mode documentation to knowledge base
	 * Called during knowledge base initialization
	 */
	if(!KNOWLEDGE)
		return FALSE
	
	KNOWLEDGE["ascension_mode_guide"] = new /datum/recipe_entry(
		recipe_key = "ascension_mode_guide",
		name = "Ascension Mode Guide",
		description = "Welcome to Ascension Mode! No PvP, no hunger, all recipes unlocked. Perfect for creative mastery and exploration.",
		icon_state = "ascension_portal",
		tier = "intermediate",
		category = "mechanics",
		workstation_type = "none",
		inputs = list(),
		outputs = list(),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 0,
		discovery_method = "npc_teaching",
		prerequisites = list("game_controls"),
		unlocks_recipes = list()
	)
	
	KNOWLEDGE["ascension_realm_exploration"] = new /datum/recipe_entry(
		recipe_key = "ascension_realm_exploration",
		name = "Ascension Realm Features",
		description = "The Ascension Realm offers peaceful exploration with NPCs, unlimited recipes, and instant travel. No survival pressure, focus on mastery.",
		icon_state = "world_map",
		tier = "intermediate",
		category = "mechanics",
		workstation_type = "none",
		inputs = list(),
		outputs = list(),
		requires_fire = FALSE,
		biomes_allowed = list("temperate", "arctic", "desert", "forest"),
		seasons_allowed = list("Spring", "Summer", "Autumn", "Winter"),
		experience_reward = 0,
		discovery_method = "npc_teaching",
		prerequisites = list("ascension_mode_guide"),
		unlocks_recipes = list()
	)
	
	return TRUE

// ============================================================================
// DEBUG & TESTING UTILITIES
// ============================================================================

/proc/DebugAscensionMode()
	/**
	 * Comprehensive Ascension Mode debug output
	 */
	if(!ascension_config)
		world.log << "\[ASCENSION DEBUG\] Ascension Mode not initialized"
		return
	
	world.log << "\[ASCENSION DEBUG\] ===== ASCENSION MODE STATUS ====="
	world.log << "\[ASCENSION DEBUG\] Mode: [ascension_config.name]"
	world.log << "\[ASCENSION DEBUG\] Description: [ascension_config.description]"
	world.log << "\[ASCENSION DEBUG\] PvP Enabled: [ascension_config.allow_pvp]"
	world.log << "\[ASCENSION DEBUG\] Hunger Enabled: [ascension_config.allow_hunger]"
	world.log << "\[ASCENSION DEBUG\] All Recipes Unlocked: [ascension_config.unlock_all_recipes]"
	world.log << "\[ASCENSION DEBUG\] Multi-World Enabled: [ascension_config.enable_multi_world]"
	world.log << "\[ASCENSION DEBUG\] Ascension Realm registered: [CONT_ASCENSION in continents ? "YES" : "NO"]"
	
	// Count players in Ascension Mode
	var/ascension_players = 0
	for(var/mob/players/M in world)
		if(M.character && M.character.ascension_mode_active)
			ascension_players++
	
	world.log << "\[ASCENSION DEBUG\] Players in Ascension Mode: [ascension_players]"
	world.log << "\[ASCENSION DEBUG\] =================================="

