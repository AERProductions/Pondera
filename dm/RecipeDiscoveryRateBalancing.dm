// RecipeDiscoveryRateBalancing.dm - Recipe Unlock Rate Control & Balancing System
// Controls the rate at which recipes are discovered through various systems
// Enables tuning of discovery difficulty without recompiling game code

// ============================================================================
// RECIPE DISCOVERY RATE CONFIGURATION
// ============================================================================

/datum/recipe_discovery_rates
	/**
	 * recipe_discovery_rates
	 * Global configuration for recipe discovery rates
	 * Controls how often recipes are unlocked per skill system
	 */
	var
		skill_discovery_base_rate = 1.0
		skill_discovery_scaling = 1.1
		market_discovery_threshold = 5
		
		// Exploration discovery rates (recipes from terrain/events)
		exploration_discovery_rate = 0.3
		exploration_rare_multiplier = 2.0
		
		// Difficulty modifiers
		easy_mode_multiplier = 1.5
		normal_mode_multiplier = 1.0
		hard_mode_multiplier = 0.7
		
		// Discovery limits (anti-spam)
		discovery_cooldown_min = 100
		discovery_daily_max = 10
		
		// Seasonal bonuses
		seasonal_bonus_active = 0
		seasonal_bonus_rate = 1.5

var/global/datum/recipe_discovery_rates/RECIPE_RATES = new()
// RECIPE DISCOVERY RATE CALCULATOR
// ============================================================================

/proc/CalculateRecipeDiscoveryRate(mob/players/player, discovery_type, extra_data = null)
	/**
	 * CalculateRecipeDiscoveryRate(player, discovery_type, extra_data)
	 * Calculates effective recipe discovery rate for specific scenario
	 * 
	 * discovery_type: "skill_levelup", "npc_teaching", "market", "exploration"
	 * extra_data: list with context-specific data
	 * 
	 * Returns: effective_rate (as multiplier, 0.0-2.0+)
	 */
	if(!player) return 0
	
	var/rate = 1.0
	switch(discovery_type)
		if("skill_levelup")
			rate = RECIPE_RATES.skill_discovery_base_rate
			if(extra_data && extra_data["skill_level"])
				var/skill_level = extra_data["skill_level"]
				rate *= (RECIPE_RATES.skill_discovery_scaling ** (skill_level - 1))
		
		if("npc_teaching")
			rate = RECIPE_RATES.npc_discovery_rate
		
		if("market")
			rate = RECIPE_RATES.market_discovery_rate
			if(extra_data && extra_data["item_count"])
				if(extra_data["item_count"] >= RECIPE_RATES.market_discovery_threshold)
					rate *= 1.5  // Bonus for bulk purchases
		
		if("exploration")
			rate = RECIPE_RATES.exploration_discovery_rate
			if(extra_data && extra_data["is_rare"])
				rate *= RECIPE_RATES.exploration_rare_multiplier
	
	// Apply difficulty modifier
	var/difficulty_mod = RECIPE_RATES.normal_mode_multiplier
	if(player.vars["game_difficulty"] == "easy")
		difficulty_mod = RECIPE_RATES.easy_mode_multiplier
	else if(player.vars["game_difficulty"] == "hard")
		difficulty_mod = RECIPE_RATES.hard_mode_multiplier
	
	rate *= difficulty_mod
	
	// Apply seasonal bonus if active
	if(RECIPE_RATES.seasonal_bonus_active)
		rate *= RECIPE_RATES.seasonal_bonus_rate
	
	return rate

// ============================================================================
// RECIPE DISCOVERY COOLDOWN SYSTEM
// ============================================================================

/proc/CanDiscoverRecipeNow(mob/players/player, recipe_name)
	/**
	 * CanDiscoverRecipeNow(player, recipe_name)
	 * Checks if player can discover a recipe right now (respects cooldowns)
	 * Returns: 1 if can discover, 0 if cooldown active
	 */
	if(!player) return 0
	
	// Initialize discovery tracking if needed
	if(!player.vars["last_discovery_time"])
		player.vars["last_discovery_time"] = 0
	if(!player.vars["discoveries_today"])
		player.vars["discoveries_today"] = 0
	
	// Check minimum cooldown between discoveries
	var/time_since_last = world.time - player.vars["last_discovery_time"]
	if(time_since_last < RECIPE_RATES.discovery_cooldown_min)
		return 0
	
	// Check daily limit
	var/today = time2text(world.realtime, "YYYY-MM-DD")
	if(player.vars["last_discovery_date"] != today)
		player.vars["discoveries_today"] = 0
		player.vars["last_discovery_date"] = today
	
	if(player.vars["discoveries_today"] >= RECIPE_RATES.discovery_daily_max)
		return 0
	
	return 1

/proc/RecordRecoveryDiscovery(mob/players/player, recipe_name)
	/**
	 * RecordRecoveryDiscovery(player, recipe_name)
	 * Records that player discovered a recipe (updates cooldowns/limits)
	 */
	if(!player) return
	
	player.vars["last_discovery_time"] = world.time
	if(!player.vars["discoveries_today"])
		player.vars["discoveries_today"] = 0
	player.vars["discoveries_today"]++

/proc/GetRecipeDiscoveryStatus(mob/players/player)
	/**
	 * GetRecipeDiscoveryStatus(player)
	 * Returns status info about player's discovery rate/limits
	 * Returns: list(discoveries_today, daily_limit, can_discover_now, time_until_next)
	 */
	if(!player) return list(0, 0, 0, 0)
	
	var/discoveries = player.vars["discoveries_today"] || 0
	var/can_discover = CanDiscoverRecipeNow(player, "")
	var/time_since = world.time - (player.vars["last_discovery_time"] || 0)
	var/time_until = max(0, RECIPE_RATES.discovery_cooldown_min - time_since)
	
	return list(
		discoveries,
		RECIPE_RATES.discovery_daily_max,
		can_discover,
		time_until
	)

// ============================================================================
// RECIPE WEIGHT & PROBABILITY SYSTEM
// ============================================================================

/proc/GetRecipeDiscoveryWeight(recipe_name, discovery_type, skill_level = 1)
	/**
	 * GetRecipeDiscoveryWeight(recipe_name, discovery_type, skill_level)
	 * Returns weighted probability (0-100) for recipe discovery
	 * Higher weight = more likely to discover
	 * 
	 * Returns: weight value (0-100, adjusted for difficulty)
	 */
	if(!recipe_name) return 0
	
	// Base weights by discovery type
	var/base_weight = 50
	switch(discovery_type)
		if("skill_levelup")
			base_weight = 80 + (skill_level * 2)
		if("npc_teaching")
			base_weight = 70
		if("market")
			base_weight = 30
		if("exploration")
			base_weight = 40
	base_weight = min(base_weight, 100)
	
	return base_weight

/proc/RollRecipeDiscovery(mob/players/player, discovery_type, extra_data = null)
	/**
	 * RollRecipeDiscovery(player, discovery_type, extra_data)
	 * Performs weighted random roll for recipe discovery
	 * Returns: 1 if discovery succeeds, 0 if fails
	 */
	if(!player) return 0
	
	var/rate = CalculateRecipeDiscoveryRate(player, discovery_type, extra_data)
	var/roll = rand(1, 100)
	var/threshold = 100 / rate
	
	// Debug output
	if(0)  // Set to 1 to enable debug logging
		world.log << "Discovery roll: [roll] vs threshold [threshold] (rate=[rate])"
	
	return (roll <= threshold)

// ============================================================================
// RECIPE AVAILABILITY TRACKING
// ============================================================================

/proc/GetAvailableRecipesForPlayer(mob/players/player)
	/**
	 * GetAvailableRecipesForPlayer(player)
	 * Returns list of all recipes player can discover through any method
	 * Returns: list of recipe paths available
	 */
	if(!player) return list()
	
	var/list/available = list()
	// When implemented, check player.character_data for discovered recipes
	
	return available

/proc/GetLockedRecipesForPlayer(mob/players/player)
	/**
	 * GetLockedRecipesForPlayer(player)
	 * Returns list of recipes player hasn't discovered yet (but could unlock)
	 * Returns: list of locked recipe paths
	 */
	if(!player) return list()
	
	var/list/locked = list()
	// For now, return empty list placeholder
	
	return locked

// ============================================================================
// RECIPE UNLOCK THRESHOLD SYSTEM
// ============================================================================

/proc/GetRecipeUnlockThreshold(recipe_name)
	/**
	 * GetRecipeUnlockThreshold(recipe_name)
	 * Returns minimum requirement to unlock specific recipe
	 * Format: list(requirement_type, value, description)
	 * 
	 * requirement_type: "skill_level", "item_count", "exploration", "npc_meeting", etc.
	 * Returns: list or null if no threshold
	 */
	if(!recipe_name) return null
	
	// This would be populated from recipe database
	// Example structure for future implementation:
	// var/recipe_thresholds = alist(
	//   "/obj/recipes/iron_sword" = list("item_count", 10, "Craft 10 items to unlock"),
	// )
	
	return null

// ============================================================================
// SEASONAL & EVENT MODIFIERS
// ============================================================================

/proc/SetSeasonalBonusActive(active = 1, bonus_rate = 1.5)
	/**
	 * SetSeasonalBonusActive(active, bonus_rate)
	 * Enables/disables seasonal recipe discovery bonus
	 * Called by event system or admin commands
	 */
	RECIPE_RATES.seasonal_bonus_active = active
	RECIPE_RATES.seasonal_bonus_rate = bonus_rate
	
	world.log << "Seasonal recipe bonus: [active ? "ACTIVE" : "INACTIVE"] ([bonus_rate]x)"

/proc/AdjustRecipeDiscoveryRate(discovery_type, new_rate)
	/**
	 * AdjustRecipeDiscoveryRate(discovery_type, new_rate)
	 * Adjusts base discovery rate for specific type (for balancing)
	 * Called by admins or balance system
	 */
	switch(discovery_type)
		if("skill")
			RECIPE_RATES.skill_discovery_base_rate = new_rate
		if("npc")
			RECIPE_RATES.npc_discovery_rate = new_rate
		if("market")
			RECIPE_RATES.market_discovery_rate = new_rate
		if("exploration")
			RECIPE_RATES.exploration_discovery_rate = new_rate
	
	world.log << "Recipe discovery rate adjusted: [discovery_type] = [new_rate]"

// ============================================================================
// RECIPE DISCOVERY STATISTICS
// ============================================================================

/proc/GetGlobalRecoveryDiscoveryStats()
	/**
	 * GetGlobalRecoveryDiscoveryStats()
	 * Returns aggregate statistics on recipe discoveries (all players)
	 * Returns: list(total_discoveries, unique_recipes, avg_per_player, most_common_source)
	 */
	var/total = 0
	var/count = 0
	// When recipe tracking implemented, iterate through players
	
	var/avg = (count > 0) ? total / count : 0
	
	return list(total, length(world), avg, "Unknown")

/proc/GetPlayerRecoveryDiscoveryStats(mob/players/player)
	/**
	 * GetPlayerRecoveryDiscoveryStats(player)
	 * Returns player-specific discovery statistics
	 * Returns: list(total_discovered, discovery_sources, last_discovery, discovery_rate)
	 */
	if(!player) return list(0, list(), 0, 0)
	
	var/total = 0
	
	return list(
		total,
		list(),  // Would be populated with source breakdown
		player.vars["last_discovery_time"] || 0,
		CalculateRecipeDiscoveryRate(player, "skill_levelup", null)
	)

// ============================================================================
// INITIALIZATION
// ============================================================================

/proc/InitializeRecipeDiscoveryRateBalancing()
	world.log << "Recipe Discovery Rate Balancing System initialized"
	world.log << "Base skill rate: [RECIPE_RATES.skill_discovery_base_rate]"
	world.log << "NPC discovery rate: [RECIPE_RATES.npc_discovery_rate]"
	world.log << "Market discovery rate: [RECIPE_RATES.market_discovery_rate]"
	world.log << "Daily discovery limit: [RECIPE_RATES.discovery_daily_max]"

