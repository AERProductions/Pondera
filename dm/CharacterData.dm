// CharacterData Datum - Centralized character skill/progression data
// Consolidates all rank, exp, and skill variables into a single encapsulated structure
// Used by mob/players and can be extended for NPCs with specific behaviors

/datum/character_data
	var
		// === SKILL RANKS & EXPERIENCE ===
		// Rank Levels (0-5 for most, configurable per skill)
		frank = 0           // Fishing rank
		crank = 0           // Crafting rank
		grank = 0           // Gardening rank
		hrank = 0           // Harvesting/Woodcutting rank
		mrank = 0           // Mining rank
		smirank = 0         // Smithing rank
		smerank = 0         // Smelting rank
		brank = 0           // Building rank
		drank = 0           // Digging rank
		botany_rank = 0     // Botany rank (harvesting plants/botanicals)
		whittling_rank = 0  // Whittling rank (specialized wooden items)
		archery_rank = 0    // Archery rank (bows)
		crossbow_rank = 0   // Crossbow rank
		throwing_rank = 0   // Throwing rank (knives, javelins)
		combat_rank = 1     // Combat rank (1-5)
		searching_rank = 1  // Searching/Item discovery rank
		destroying_rank = 1 // Destroying/Wall destruction rank

		// === CHARACTER CLASS SYSTEM ===
		selected_class = "" // Selected starting class (Warrior, Scout, Mage, Crafter, Naturalist)

		// Experience Points (current)
		frankEXP = 0
		crankEXP = 0
		grankEXP = 0
		hrankEXP = 0
		mrankEXP = 0
		smirankEXP = 0
		smerankEXP = 0
		brankEXP = 0
		drankEXP = 0
		botany_xp = 0       // Botany experience
		whittling_xp = 0    // Whittling experience
		archery_xp = 0      // Archery experience
		crossbow_xp = 0     // Crossbow experience
		throwing_xp = 0     // Throwing experience
		combat_xp = 0       // Combat XP (accumulates within rank)
		searching_xp = 0    // Searching/Item discovery XP
		destroying_xp = 0   // Destroying/Wall destruction XP

		// Experience Thresholds (exp needed for next level)
		frankMAXEXP = 100
		crankMAXEXP = 10
		grankMAXEXP = 100
		hrankMAXEXP = 10
		mrankMAXEXP = 100
		smirankMAXEXP = 100
		smerankMAXEXP = 100
		brankMAXEXP = 100
		drankMAXEXP = 100
		botany_maxexp = 100     // Botany max experience per level
		whittling_maxexp = 100  // Whittling max experience per level
		archery_maxexp = 100
		crossbow_maxexp = 100
		throwing_maxexp = 100
		combat_maxexp = 100     // Combat max experience per level
		searching_maxexp = 100  // Searching max experience per level
		destroying_maxexp = 100 // Destroying max experience per level

		// === NPC SYSTEM ===
		is_npc = FALSE                       // TRUE if this is NPC character data
		npc_type = ""                        // Type of NPC (e.g., "blacksmith", "scholar")

		// === RECIPE & KNOWLEDGE STATE ===
		datum/recipe_state/recipe_state = null  // Tracks discovered recipes and knowledge
		datum/experimentation_state/experimentation_state = null  // Phase C.2: Recipe experimentation progress
		purchased_items = list()             // Items purchased from market stalls
		
		// === MULTI-WORLD SYSTEM ===
		// Continent & World variables
		current_continent = CONT_STORY       // Which continent player is on
		last_continent = CONT_STORY          // Previously visited continent (for transmutation on travel)
		continent_positions = list()         // Saved positions per continent: CONT_STORY = list(x,y,z,dir)
		
		// Ascension Mode flags (Stage 6)
		game_mode = "story"                  // Current game mode: "story", "sandbox", "pvp", "ascension"
		ascension_mode_active = FALSE        // TRUE if player is in Ascension Mode
		ascension_locked_in = FALSE          // TRUE if player entered Ascension (one-way, prevents cheesing)
		instant_crafting = FALSE             // Ascension feature: instant recipes
		free_respawn = FALSE                 // Ascension feature: no death penalty
		enhanced_lighting = FALSE            // Ascension feature: better visibility
		
		// === FACTION SYSTEM ===
		faction_id = 0                       // Current faction (FACTION_CRIMSON, FACTION_AZURE, etc.)
		faction_standing = 0                 // Standing within faction (-1000 to +1000)
		
		// === DEATH PENALTY SYSTEM ===
		// Two-death system: First death = fainted, Second death = permanent
		death_count = 0                      // Counter: 0 = alive, 1 = first death (fainted), 2+ = permanent
		is_fainted = 0                       // Flag: 0 = alive, 1 = fainted, 2 = permanently dead
		death_marks = list()                 // Per-continent death marks: death_marks["story"] = 1, etc
		home_point = null                    // Turf reference for respawn location (set via compass or NPC)
		death_debuff_active = 0              // Flag if death debuff is active (1 = active, 0 = inactive)
		death_debuff_end_time = 0            // world.time when debuff expires
		
		// === PRESTIGE SYSTEM ===
		has_prestige = FALSE                 // TRUE if player has prestige unlocked
		prestige_unlock_source = ""          // How prestige was unlocked ("ascension", "manual", etc.)
		prestige_title = ""                  // Prestige title/rank
		
		// === AVATAR APPEARANCE SYSTEM ===
		// Blank avatar customization - player can choose gender, skin, hair, eyes, marks
		gender = GENDER_MALE                 // MALE or FEMALE (default: MALE)
		appearance_locked = 0                // 0 = can customize, 1 = locked
		current_appearance = "blank_base"    // Current appearance preset name
		current_appearance_config = null     // Full appearance config dict
		is_customized = 0                    // 1 = has been customized beyond defaults
		datum/appearance_data/appearance_data = null  // Persistent appearance customization (hair, skin, eyes, marks)
		
		// === SKILL & RECIPE STATE (SIMPLIFIED) ===
		// Note: Detailed ranks stored in frank, crank, etc. above
		// These lists provide convenient access for bulk operations
		skills = list()                      // Skill list (maps to ranks above)
		recipes = list()                     // Discovered recipes (populated from recipe_state)
		knowledge = list()                   // Knowledge topics learned
		crafter_titles = list()              // Crafter titles earned
		
		show_recipe_hints = FALSE            // Ascension feature: recipe tooltips
		can_travel_all_continents = FALSE    // Ascension feature: multi-world access
		multi_world_unlocked = FALSE         // Ascension feature: continental travel enabled
		inventory_expanded = FALSE           // Ascension feature: more carrying capacity
		disable_deed_system = FALSE          // Ascension feature: disable deeds entirely
		disable_deed_costs = FALSE           // Ascension feature: no maintenance fees
		
		// Stall system (per-continent trading)
		stall_owner = ""                     // NPC stall owner name (story continent)
		stall_inventory = list()             // Items for sale in stall
		stall_prices = list()                // Prices for items
		stall_profits = 0                    // Accumulated stall profits (shared globally)
		
		// === DEED ANTI-GRIEFING SYSTEM ===
		datum/deed_anti_grief/deed_anti_grief = null  // Tracks griefing behavior and patterns
		
		// === PERSISTENT PLAYER IDENTITY ===
		ckey = ""                            // Player ckey (unique identifier)
		equipped_items = list()              // Currently equipped items
		npc_teachable_recipes = list()       // Recipes this NPC can teach
		npc_dialogue_topics = list()         // Knowledge topics this NPC can teach
		npc_taught_to = list()               // List of player ckeys this NPC has taught (for tracking)
		
		// === REPUTATION SYSTEM (12-12-25) ===
		reputation_data = list()             // Dictionary: "npc_name" -> list of rep data (standing, tier, etc)

/datum/character_data/proc/Initialize()
	// Reset all ranks and exp to zero on creation
	// Can be called during character creation
	frank = 0
	frankEXP = 0
	frankMAXEXP = 100

	crank = 0
	crankEXP = 0
	crankMAXEXP = 10

	grank = 0
	grankEXP = 0
	grankMAXEXP = 100

	hrank = 0
	hrankEXP = 0
	hrankMAXEXP = 10

	mrank = 0
	mrankEXP = 0
	mrankMAXEXP = 100

	smirank = 0
	smirankEXP = 0
	smirankMAXEXP = 100

	smerank = 0
	smerankEXP = 0
	smerankMAXEXP = 100

	brank = 0
	brankEXP = 0
	brankMAXEXP = 100

	drank = 0
	drankEXP = 0
	drankMAXEXP = 100

	botany_rank = 0
	botany_xp = 0
	botany_maxexp = 100

	whittling_rank = 0
	whittling_xp = 0
	whittling_maxexp = 100

	// Initialize recipe state with defaults
	recipe_state = new /datum/recipe_state()
	recipe_state.SetRecipeDefaults()
	
	// Initialize experimentation state (Phase C.2)
	experimentation_state = new /datum/experimentation_state()
	
	// INTEGRATION: Avatar appearance system (blank avatar customization)
	gender = GENDER_MALE  // MALE or FEMALE
	appearance_locked = 0  // Can customize appearance at creation
	current_appearance = "blank_base"
	current_appearance_config = null  // Stores full appearance configuration
	is_customized = 0  // Whether appearance has been customized beyond defaults
	
	// INTEGRATION: Display server difficulty settings to player (Phase 4)
	// Called on character creation/login to show permadeath and lives limits
	if(ismob(src) && istype(src, /mob/players))
		var/mob/players/M = src
		spawn(1) DisplayServerDifficultyStatus(M)

// ============================================================================
// NPC INITIALIZATION - Create unified NPC character data
// ============================================================================

/datum/character_data/proc/InitializeAsNPC(npc_type_name = "")
	// Convert this datum to an NPC with specific type and teachable recipes
	is_npc = TRUE
	npc_type = npc_type_name
	npc_taught_to = list()
	
	// Initialize NPC-specific skills based on type
	switch(npc_type)
		if("Traveler")
			frank = 4           // Excellent fishing knowledge
			crank = 3           // Good crafting
			grank = 3           // Gardening
			npc_teachable_recipes = list("fishing_pole", "plant_gathering", "trading_basics")
			npc_dialogue_topics = list("trading_basics", "world_travel")
			
		if("Elder")
			frank = 5           // Master fisherman
			crank = 4           // Master crafter
			smirank = 3         // Good smithing
			npc_teachable_recipes = list("wooden_wall", "survival_basics", "resource_conservation")
			npc_dialogue_topics = list("survival_101", "resource_conservation", "world_wisdom")
			
		if("Veteran")
			mrank = 4           // Excellent mining
			smirank = 4         // Excellent smithing
			hrank = 3           // Good harvesting
			npc_teachable_recipes = list("tool_sharpening", "combat_basics", "weapon_maintenance")
			npc_dialogue_topics = list("combat_basics", "defense_101", "weapon_care")
			
		if("Warrior")
			crank = 5           // Master crafting
			mrank = 3           // Good mining
			smerank = 3         // Good smelting
			npc_teachable_recipes = list("carving_knife", "cook_food", "armor_maintenance")
			npc_dialogue_topics = list("armor_maintenance", "resource_preparation")
			
		if("Scribe")
			crank = 3           // Crafting knowledge
			frank = 2           // Some fishing knowledge
			grank = 2           // Some gardening knowledge
			npc_teachable_recipes = list("cooking_basics", "gardening_101")
			npc_dialogue_topics = list("world_history", "crafting_theory", "knowledge_preservation")
			
		if("Proctor")
			brank = 5           // Master builder
			crank = 4           // Master crafter
			mrank = 3           // Good mining
			npc_teachable_recipes = list("wooden_wall", "stone_foundation", "building_basics")
			npc_dialogue_topics = list("building_theory", "construction_methods")

// ============================================================================
// NPC RECIPE TEACHING - Track which NPCs taught which recipes
// ============================================================================

/datum/character_data/proc/CanTeachRecipe(recipe_name)
	// Check if this NPC can teach a specific recipe
	if(!is_npc) return FALSE
	return recipe_name in npc_teachable_recipes

/datum/character_data/proc/CanTeachKnowledge(knowledge_topic)
	// Check if this NPC can teach a specific knowledge topic
	if(!is_npc) return FALSE
	return knowledge_topic in npc_dialogue_topics

/datum/character_data/proc/HasTaughtPlayer(player_ckey)
	// Check if this NPC has already taught a specific player
	if(!is_npc) return FALSE
	return player_ckey in npc_taught_to

/datum/character_data/proc/MarkPlayerTaught(player_ckey)
	// Record that this NPC taught a player (prevents duplicate teaching)
	if(!is_npc) return
	if(!(player_ckey in npc_taught_to))
		npc_taught_to += player_ckey

// ============================================================================
// UNIFIED RANK ACCESSOR METHODS - Get/Set/Update skill ranks
// ============================================================================

/datum/character_data/proc/GetRankLevel(rank_type)
	// Get skill rank level (1-5 for most skills)
	switch(rank_type)
		if("frank")
			return frank
		if("crank")
			return crank
		if("grank")
			return grank
		if("hrank")
			return hrank
		if("mrank")
			return mrank
		if("smirank")
			return smirank
		if("smerank")
			return smerank
		if("brank")
			return brank
		if("drank")
			return drank
	return 0

/datum/character_data/proc/SetRankLevel(rank_type, level)
	// Set skill rank level to a specific value
	switch(rank_type)
		if("frank")
			frank = level
		if("crank")
			crank = level
		if("grank")
			grank = level
		if("hrank")
			hrank = level
		if("mrank")
			mrank = level
		if("smirank")
			smirank = level
		if("smerank")
			smerank = level
		if("brank")
			brank = level
		if("drank")
			drank = level

/datum/character_data/proc/UpdateRankExp(rank_type, exp_gain)
	// Add experience to a skill and check for level-up
	if(exp_gain <= 0) return
	
	var/current_exp = 0
	var/max_exp = 0
	var/current_level = 0
	
	switch(rank_type)
		if("frank")
			frankEXP += exp_gain
			current_exp = frankEXP
			max_exp = frankMAXEXP
			current_level = frank
		if("crank")
			crankEXP += exp_gain
			current_exp = crankEXP
			max_exp = crankMAXEXP
			current_level = crank
		if("grank")
			grankEXP += exp_gain
			current_exp = grankEXP
			max_exp = grankMAXEXP
			current_level = grank
		if("hrank")
			hrankEXP += exp_gain
			current_exp = hrankEXP
			max_exp = hrankMAXEXP
			current_level = hrank
		if("mrank")
			mrankEXP += exp_gain
			current_exp = mrankEXP
			max_exp = mrankMAXEXP
			current_level = mrank
		if("smirank")
			smirankEXP += exp_gain
			current_exp = smirankEXP
			max_exp = smirankMAXEXP
			current_level = smirank
		if("smerank")
			smerankEXP += exp_gain
			current_exp = smerankEXP
			max_exp = smerankMAXEXP
			current_level = smerank
		if("brank")
			brankEXP += exp_gain
			current_exp = brankEXP
			max_exp = brankMAXEXP
			current_level = brank
		if("drank")
			drankEXP += exp_gain
			current_exp = drankEXP
			max_exp = drankMAXEXP
			current_level = drank
	
	// Check for level-up
	while(current_exp >= max_exp && current_level < 5)
		current_exp -= max_exp
		current_level++
		SetRankLevel(rank_type, current_level)
		// Max exp increases per level
		max_exp = max_exp * 1.5