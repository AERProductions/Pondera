/**
 * RecipeExperimentationSystem.dm
 * =============================
 * Phase C.2: Recipe Experimentation & Discovery
 * 
 * Allows players to discover new recipes through ingredient experimentation.
 * Core mechanics:
 * - Combine ingredients in a cauldron/workstation to experiment
 * - Track experimentation progress per recipe
 * - Auto-unlock after 10 failed attempts
 * - Award bonus XP on successful discovery
 * - Prevent duplicate experimentation attempts
 * 
 * Integration points:
 * - CookingSystem.dm: Recipe validation
 * - SkillRecipeUnlock.dm: Unlock tracking
 * - CharacterData.dm: Experimentation state persistence
 * - RecipeState.dm: Recipe discovery flags
 * 
 * TODO: Create experimentation UI for selecting ingredients
 * TODO: Implement cauldron/workstation objects with experiment verb
 * TODO: Add experimentation progress tracking to character HUD
 */

// ============================================================================
// EXPERIMENTATION STATE DATUM
// ============================================================================

/datum/experimentation_state
	/**
	 * Tracks player's experimentation progress on individual recipes
	 * Persisted in character_data for progression across sessions
	 */
	
	var/list/experimentation_attempts = list()  // recipe_name = attempt_count
	var/list/discovered_through_experimentation = list()  // recipe_name = TRUE
	var/list/last_experiment_time = list()  // recipe_name = world.time
	
	proc/AttemptExperiment(recipe_name, list/ingredients)
		/**
		 * Record experimentation attempt on a recipe
		 * Returns: success (1), failure (0), already_unlocked (-1)
		 */
		if(!recipe_name || !ingredients)
			return 0
		
		// Check if already discovered through skill or inspection
		var/mob/players/player = usr
		if(!player || !player.character)
			return 0
		
		if(player.character.recipe_state.IsRecipeDiscovered(recipe_name))
			return -1  // Already unlocked
		
		// Increment attempt counter
		if(!experimentation_attempts[recipe_name])
			experimentation_attempts[recipe_name] = 0
		
		experimentation_attempts[recipe_name]++
		last_experiment_time[recipe_name] = world.time
		
		// Check if ingredients match recipe signature
		var/ingredient_match = ValidateIngredientCombination(recipe_name, ingredients)
		
		if(ingredient_match)
			// Success! Unlock recipe through experimentation
			UnlockRecipeViaExperimentation(recipe_name, player)
			return 1
		
		// Check if hit attempt threshold (10 attempts = auto-unlock)
		if(experimentation_attempts[recipe_name] >= 10)
			AutoUnlockAfterAttempts(recipe_name, player)
			return 1
		
		return 0  // Failed, but not unlocked

	proc/ValidateIngredientCombination(recipe_name, list/ingredients)
		/**
		 * Check if ingredient list matches the recipe's required ingredients
		 * Returns TRUE if all required ingredients present with correct types
		 */
		if(!RECIPES || !RECIPES[recipe_name])
			return FALSE
		
		var/list/recipe_data = RECIPES[recipe_name]
		var/list/required_ingredients = recipe_data["ingredients"]
		
		if(!required_ingredients)
			return FALSE
		
		// Simple validation: check if ingredient types match required keys
		var/list/ingredient_types = list()
		for(var/obj/item in ingredients)
			if(item)
				ingredient_types[item.type] = (ingredient_types[item.type] || 0) + 1
		
		// Match against required ingredients
		for(var/ingredient_key in required_ingredients)
			var/required_count = required_ingredients[ingredient_key]
			
			// Check if we have this ingredient type
			var/found_count = 0
			for(var/ingredient_type in ingredient_types)
				// Simplified: check if ingredient type matches required key
				if(findtext(ingredient_type, ingredient_key))
					found_count += ingredient_types[ingredient_type]
			
			if(found_count < required_count)
				return FALSE  // Missing required ingredient
		
		return TRUE  // All ingredients present

	proc/UnlockRecipeViaExperimentation(recipe_name, mob/players/player)
		/**
		 * Player successfully discovered recipe through experimentation
		 * Award bonus XP and unlock the recipe
		 */
		if(!player || !player.character)
			return
		
		// Mark as discovered through experimentation
		discovered_through_experimentation[recipe_name] = TRUE
		
		// Unlock in recipe state
		player.character.recipe_state.DiscoverRecipe(recipe_name)
		
		// Notify player
		player << "<font color=#00FF00><b>Eureka!</b> You discovered a new recipe: [recipe_name]!</font>"
		
		// Award bonus XP (1.5x normal discovery rate)
		var/bonus_xp = 75  // Experimentation bonus
		player.character.UpdateRankExp("crank", bonus_xp)
		
		// Play discovery sound (Phase C.1 integration)
		PlayRecipeDiscoverSound(player)

	proc/AutoUnlockAfterAttempts(recipe_name, mob/players/player)
		/**
		 * Auto-unlock recipe after 10 failed attempts
		 * Represents player "figuring it out" through trial and error
		 */
		if(!player || !player.character)
			return
		
		// Unlock with normal XP (not bonus, since it was brute-forced)
		player.character.recipe_state.DiscoverRecipe(recipe_name)
		
		player << "<font color=#FFFF00>After much experimentation, you figure out how to make [recipe_name]...</font>"
		
		// Award standard XP (no bonus for brute-force)
		var/standard_xp = 40
		player.character.UpdateRankExp("crank", standard_xp)
		
		PlayRecipeDiscoverSound(player)

	proc/GetExperimentationProgress(recipe_name)
		/**
		 * Return experimentation progress for recipe (0-10)
		 * Used for progress bars in UI
		 */
		if(!recipe_name)
			return 0
		
		var/attempts = experimentation_attempts[recipe_name] || 0
		return min(attempts, 10)  // Cap at 10

	proc/HasDiscoveredViaExperimentation(recipe_name)
		/**
		 * Check if recipe was discovered through experimentation (vs skill/inspection)
		 */
		return discovered_through_experimentation[recipe_name] || FALSE

// ============================================================================
// INTEGRATION WITH CHARACTER DATA
// ============================================================================

/datum/character_data/proc/InitializeExperimentationState()
	/**
	 * Create fresh experimentation state for new characters
	 * Called during character creation in CharacterData.dm
	 */
	if(!experimentation_state)
		experimentation_state = new /datum/experimentation_state()

// ============================================================================
// EXPERIMENTATION UI PROC
// ============================================================================

/proc/ShowExperimentationMenu(mob/players/player, workstation_type = "cauldron")
	/**
	 * Display menu for selecting ingredients to experiment with
	 * workstation_type: "cauldron", "forge", "smithing", etc.
	 * 
	 * TODO: Implement actual UI with ingredient selection
	 * For now: placeholder that shows available recipes to experiment on
	 */
	if(!player || !player.client)
		return
	
	// Get list of recipes player can experiment with
	var/list/available_recipes = GetExperimentableRecipes(player)
	
	if(!available_recipes || available_recipes.len == 0)
		player << "No recipes available to experiment with."
		return
	
	// TODO: Build HTML UI with ingredient selection interface
	player << "<font color=#FFD700>Experimentation Menu (TODO: Build UI)</font>"
	player << "Available recipes to discover:"
	for(var/recipe_name in available_recipes)
		var/attempts = player.character.experimentation_state.GetExperimentationProgress(recipe_name)
		player << "[recipe_name]: [attempts]/10 attempts"

/proc/GetExperimentableRecipes(mob/players/player)
	/**
	 * Get list of recipes player can experiment with
	 * Filters out: already discovered, requires higher skill level
	 */
	if(!player || !RECIPES)
		return list()
	
	var/list/experimentable = list()
	
	for(var/recipe_name in RECIPES)
		// Skip if already discovered
		if(player.character.recipe_state.IsRecipeDiscovered(recipe_name))
			continue
		
		// Skip if requires skill player doesn't have
		var/list/recipe_data = RECIPES[recipe_name]
		var/required_rank = recipe_data["rank"]
		if(required_rank)
			var/player_rank = player.GetRankLevel(required_rank)
			if(player_rank <= 0)
				continue  // Player doesn't have this skill yet
		
		experimentable[recipe_name] = TRUE
	
	return experimentable

// ============================================================================
// EXPERIMENTATION HELPER PROCS
// ============================================================================

// Note: GetIngredientListFromInventory is defined in ExperimentationUI.dm

/proc/ConsumeExperimentationIngredients(mob/players/player, list/ingredients, success = TRUE)
	/**
	 * Remove ingredients from player inventory after experimentation attempt
	 * Success: consume all ingredients
	 * Failure: consume only 50% (player can retry with some materials back)
	 */
	if(!player || !ingredients)
		return
	
	for(var/obj/item in ingredients)
		if(!item)
			continue
		
		// For success, always consume the item
		if(success)
			del(item)
		else
			// For failure, 50% chance to keep the item (return to player)
			if(prob(50))
				continue
			else
				del(item)

// ============================================================================
// INTEGRATION POINTS FOR FUTURE UI SYSTEMS
// ============================================================================

/proc/AttemptRecipeExperimentation(mob/players/player, recipe_name, list/ingredients)
	/**
	 * Main entry point for recipe experimentation
	 * Called from experimentation UI when player clicks "Experiment"
	 * 
	 * Validates ingredients, records attempt, consumes materials, notifies player
	 */
	if(!player || !player.character || !recipe_name || !ingredients)
		return FALSE
	
	// Initialize experimentation state if needed
	if(!player.character.experimentation_state)
		player.character.InitializeExperimentationState()
	
	// Attempt experiment
	var/result = player.character.experimentation_state.AttemptExperiment(recipe_name, ingredients)
	
	if(result == -1)
		player << "You already know how to make [recipe_name]."
		return FALSE
	
	if(result == 1)
		// Success! Consume all ingredients
		ConsumeExperimentationIngredients(player, ingredients, TRUE)
		return TRUE
	
	if(result == 0)
		// Failed attempt. Consume 50% of ingredients
		ConsumeExperimentationIngredients(player, ingredients, FALSE)
		var/progress = player.character.experimentation_state.GetExperimentationProgress(recipe_name)
		player << "The ingredients don't seem to work together. ([progress]/10 attempts)"
		return FALSE
	
	return FALSE

// ============================================================================
// SAVE/LOAD INTEGRATION
// ============================================================================

/proc/SaveExperimentationState(mob/players/player, savefile/F)
	/**
	 * Serialize experimentation state to savefile
	 * Called from SavingChars.dm during character save
	 * 
	 * TODO: Implement actual savefile integration
	 */
	if(!player || !player.character || !player.character.experimentation_state)
		return
	
	// Placeholder: actual implementation would use savefile[][] syntax
	// F["character_data"]["experimentation"]["attempts"] = player.character.experimentation_state.experimentation_attempts
	// F["character_data"]["experimentation"]["discovered"] = player.character.experimentation_state.discovered_through_experimentation

/proc/LoadExperimentationState(mob/players/player, savefile/F)
	/**
	 * Deserialize experimentation state from savefile
	 * Called from SavingChars.dm during character load
	 * 
	 * TODO: Implement actual savefile integration
	 */
	if(!player || !player.character)
		return
	
	// Placeholder: actual implementation would read from F["character_data"]["experimentation"]

// ============================================================================
// RECIPE EXPERIMENTATION REGISTRY
// ============================================================================

/**
 * RECIPE INGREDIENT SIGNATURES
 * ===========================
 * 
 * Defines which ingredient combinations unlock which recipes
 * Format: recipe_name = list(ingredient_type_1, ingredient_type_2, ...)
 * 
 * Examples:
 * "vegetable_soup" = list("vegetable", "water", "salt")
 * "iron_ingot" = list("iron_ore", "flux")
 * "bronze_ingot" = list("copper_ore", "tin_ore", "flux")
 * 
 * TODO: Build comprehensive ingredient signature database
 * TODO: Link to CookingSystem.dm RECIPES registry
 */

var/list/RECIPE_SIGNATURES = list()

/proc/InitializeRecipeSignatures()
	/**
	 * Build recipe signature database from RECIPES registry
	 * Called during world initialization (Phase 5)
	 * 
	 * TODO: Populate from actual RECIPES data
	 */
	if(!RECIPES)
		return
	
	for(var/recipe_name in RECIPES)
		var/list/recipe_data = RECIPES[recipe_name]
		if(recipe_data && recipe_data["ingredients"])
			RECIPE_SIGNATURES[recipe_name] = recipe_data["ingredients"]

// ============================================================================
// DOCUMENTATION: EXPERIMENTATION DISCOVERY FLOW
// ============================================================================

/**
 * PLAYER EXPERIMENTATION FLOW
 * ===========================
 * 
 * 1. Player opens experimentation workstation (cauldron, forge, etc.)
 * 2. System shows list of recipes player can experiment with
 * 3. Player selects recipe and ingredient combination
 * 4. System validates if ingredients match recipe signature
 * 5. If match: Recipe unlocked, bonus XP awarded, ingredients consumed
 * 6. If no match: Attempt counter +1, 50% of ingredients consumed
 * 7. After 10 failed attempts: Recipe auto-unlocked with standard XP
 * 
 * This creates gameplay loop:
 * - Early game: Players discover recipes through NPC teaching + inspection
 * - Mid game: Players experiment to discover specialized recipes
 * - Late game: Players have most recipes, focus on skill optimization
 * 
 * INTEGRATION TIMELINE
 * ====================
 * 
 * Phase C.2a (This commit): Core experimentation system
 * Phase C.2b: Experimentation UI & workstation objects
 * Phase C.2c: Ingredient signature database population
 * Phase C.2d: Savefile persistence integration
 * Phase C.2e: HUD progress tracking (attempts remaining)
 * Phase C.2f: Advanced: multi-step experimentation quests
 */
