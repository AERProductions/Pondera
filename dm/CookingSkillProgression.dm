/**
 * COOKING SKILL PROGRESSION SYSTEM
 * Tracks player culinary skill, unlocks recipes, improves meal quality
 * 
 * Integration with existing character progression:
 * - Cooking skill tracked in character.recipe_state.skill_cooking_level
 * - Ranks 0-10 (10 = Master Chef)
 * - XP earned from cooking high-quality meals
 * - Recipes unlock at specific skill ranks
 * - Higher skill = better quality meals possible
 *
 * Depends on:
 * - CookingSystem.dm (recipe database, quality calculations)
 * - RecipeState.dm (character.recipe_state persistence)
 * - HungerThirstSystem.dm (food data integration)
 */

// ==================== COOKING SKILL CONSTANTS ====================

#define COOKING_RANK_APPRENTICE    1  // Basic recipes unlocked (vegetable soup, porridge)
#define COOKING_RANK_PRACTICED     2  // Roasting, frying basics
#define COOKING_RANK_COMPETENT     3  // Bread baking, stews
#define COOKING_RANK_SKILLED       4  // Advanced combinations
#define COOKING_RANK_EXPERT        5  // Complex dishes unlocked
#define COOKING_RANK_MASTER        6  // Legendary recipes
#define COOKING_RANK_GRANDMASTER   7  // All recipes available
#define COOKING_RANK_LEGENDARY     10 // Maximum possible skill

// XP requirements per rank (cumulative)
#define COOKING_XP_RANK_1   0       // Automatic at start
#define COOKING_XP_RANK_2   500     // 500 XP to apprentice
#define COOKING_XP_RANK_3   1500    // 1000 more XP to practiced
#define COOKING_XP_RANK_4   3500    // 2000 more XP to competent
#define COOKING_XP_RANK_5   7000    // 3500 more XP to skilled
#define COOKING_XP_RANK_6   12000   // 5000 more XP to expert
#define COOKING_XP_RANK_7   18000   // 6000 more XP to master
#define COOKING_XP_RANK_10  50000   // 32000 more XP to legendary

// XP multipliers for meal quality
#define XP_QUALITY_POOR     0.5     // Poor quality = 50% XP
#define XP_QUALITY_AVERAGE  1.0     // Average = normal XP
#define XP_QUALITY_GOOD     1.5     // Good = 150% XP
#define XP_QUALITY_EXCELLENT 2.0    // Excellent = 200% XP

// Quality calculation multipliers by skill
var/global/list/COOKING_SKILL_MULTIPLIERS = list(
	"0" = 0.6,    // Unskilled - significant quality penalty
	"1" = 0.8,    // Apprentice - learning
	"2" = 0.95,   // Practiced - getting better
	"3" = 1.0,    // Competent - baseline quality
	"4" = 1.1,    // Skilled - slightly better
	"5" = 1.25,   // Expert - noticeably better
	"6" = 1.4,    // Master - excellent quality
	"7" = 1.5,    // Grandmaster - superior
	"8" = 1.6,    // Legendary candidate
	"9" = 1.7,    // Legendary candidate
	"10" = 1.8    // Legendary chef - maximum quality
)

// Recipe unlock thresholds
#define RECIPE_UNLOCK_BASIC      COOKING_RANK_APPRENTICE  // 1: Soup, porridge
#define RECIPE_UNLOCK_ROASTING   COOKING_RANK_APPRENTICE  // 1: Can roast
#define RECIPE_UNLOCK_BAKING     COOKING_RANK_COMPETENT   // 3: Can bake bread
#define RECIPE_UNLOCK_STEWING    COOKING_RANK_COMPETENT   // 3: Can make stews
#define RECIPE_UNLOCK_ADVANCED   COOKING_RANK_EXPERT      // 5: Complex recipes
#define RECIPE_UNLOCK_LEGENDARY  COOKING_RANK_MASTER      // 6: Special recipes


// ==================== COOKING SKILL QUERIES ====================

/**
 * Get player's current cooking skill rank
 * Returns: 0-10 (0 = unskilled, 10 = legendary)
 */
proc/GetCookingSkillRank(mob/players/M)
	if(!M || !M.character) return 0
	if(!M.character.recipe_state) return 0
	return M.character.recipe_state.skill_cooking_level

/**
 * Get cooking experience points
 * Returns: Total XP earned (not used for rank calculation currently)
 */
proc/GetCookingExperience(mob/players/M)
	if(!M || !M.character) return 0
	if(!M.character.recipe_state) return 0
	return M.character.recipe_state.experience_smithing  // Repurpose for now

/**
 * Get quality multiplier for skill level
 * Returns: 0.6 to 1.8 (multiplier applied to base recipe quality)
 */
proc/GetCookingQualityBonus(mob/players/M)
	var/rank = GetCookingSkillRank(M)
	return COOKING_SKILL_MULTIPLIERS["[rank]"]

/**
 * Check if player can cook a specific recipe
 * Verifies skill rank meets recipe requirement
 */
proc/CanCookRecipe(mob/players/M, recipe_name)
	if(!M || !M.character) return 0
	if(!M.character.recipe_state) return 0
	
	var/rank = M.character.recipe_state.skill_cooking_level
	var/list/recipe = RECIPES[recipe_name]
	if(!recipe) return 0
	
	// Check if player has discovered recipe
	if(!M.character.recipe_state.IsRecipeDiscovered(recipe_name))
		return 0
	
	// Check if player's rank meets recipe requirement
	if(recipe["skill_req"] && recipe["skill_req"] > rank)
		return 0
	
	return 1

/**
 * Get player's cooking skill description
 * Returns: Text like "Apprentice Chef" or "Master Chef"
 */
proc/GetCookingSkillTitle(rank)
	switch(rank)
		if(0)
			return "Untrained"
		if(1)
			return "Apprentice Chef"
		if(2)
			return "Practiced Cook"
		if(3)
			return "Competent Chef"
		if(4)
			return "Skilled Chef"
		if(5)
			return "Expert Chef"
		if(6)
			return "Master Chef"
		if(7)
			return "Grandmaster Chef"
		if(8,9)
			return "Legendary Chef"
		if(10)
			return "Supreme Chef"
	return "Unknown"


// ==================== COOKING SKILL ADVANCEMENT ====================

/**
 * Grant cooking XP for completing a meal
 * Called after successful cooking with quality calculated
 */
proc/AwardCookingXP(mob/players/M, base_xp, quality_modifier)
	if(!M || !M.character) return
	if(!M.character.recipe_state) return
	
	// Calculate XP based on quality
	var/quality_rank = round(quality_modifier * 5)  // 1.0 = rank 5
	var/xp_multiplier = XP_QUALITY_AVERAGE
	
	switch(quality_rank)
		if(1,2)
			xp_multiplier = XP_QUALITY_POOR
		if(3)
			xp_multiplier = XP_QUALITY_AVERAGE
		if(4,5)
			xp_multiplier = XP_QUALITY_GOOD
		if(6 to 999)
			xp_multiplier = XP_QUALITY_EXCELLENT
	
	var/final_xp = round(base_xp * xp_multiplier)
	
	// Add to experience
	M.character.recipe_state.experience_smithing += final_xp
	
	// Check for rank up
	CheckCookingRankUp(M, final_xp)
	
	// Feedback to player
	if(final_xp > 0)
		M << "<color=#FFD700>Cooking XP: +[final_xp]</color>"

/**
 * Check if player ranks up in cooking
 * Called after XP gain
 */
proc/CheckCookingRankUp(mob/players/M, xp_gained)
	if(!M || !M.character) return
	if(!M.character.recipe_state) return
	
	var/current_rank = M.character.recipe_state.skill_cooking_level
	var/total_xp = M.character.recipe_state.experience_smithing
	
	// Check each rank threshold
	var/next_rank = current_rank
	if(total_xp >= COOKING_XP_RANK_2 && current_rank < 2)
		next_rank = 2
	else if(total_xp >= COOKING_XP_RANK_3 && current_rank < 3)
		next_rank = 3
	else if(total_xp >= COOKING_XP_RANK_4 && current_rank < 4)
		next_rank = 4
	else if(total_xp >= COOKING_XP_RANK_5 && current_rank < 5)
		next_rank = 5
	else if(total_xp >= COOKING_XP_RANK_6 && current_rank < 6)
		next_rank = 6
	else if(total_xp >= COOKING_XP_RANK_7 && current_rank < 7)
		next_rank = 7
	else if(total_xp >= COOKING_XP_RANK_10 && current_rank < 10)
		next_rank = 10
	
	if(next_rank > current_rank)
		OnCookingRankUp(M, next_rank)

/**
 * Called when player reaches new cooking rank
 * Unlocks new recipes, shows achievement message
 */
proc/OnCookingRankUp(mob/players/M, new_rank)
	if(!M || !M.character) return
	if(!M.character.recipe_state) return
	
	M.character.recipe_state.skill_cooking_level = new_rank
	
	var/title = GetCookingSkillTitle(new_rank)
	M << "<b><color=#FFD700>═══════════════════════════════════</color></b>"
	M << "<b><color=#FFD700>☆ COOKING RANK UP! ☆</color></b>"
	M << "<b><color=#FFD700>You are now a [title]!</color></b>"
	M << "<b><color=#FFD700>═══════════════════════════════════</color></b>"
	
	// Unlock recipes at this rank
	UnlockRecipesByRank(M, new_rank)
	
	// Broadcast to nearby players
	var/message = "[M.name] has reached the rank of [title]!"
	for(var/mob/players/P in view(M))
		if(P != M)
			P << "<i>[message]</i>"

/**
 * Unlock all recipes that require a specific rank
 * Called when player ranks up
 */
proc/UnlockRecipesByRank(mob/players/M, new_rank)
	if(!M || !M.character) return
	if(!M.character.recipe_state) return
	
	var/recipes_unlocked = 0
	
	for(var/recipe_name in RECIPES)
		var/list/recipe = RECIPES[recipe_name]
		if(!recipe) continue
		
		// Only unlock cooking recipes
		if(recipe["category"] != "cooking") continue
		
		// Skip if already discovered
		if(M.character.recipe_state.IsRecipeDiscovered(recipe_name)) continue
		
		// Check if this recipe unlocks at new rank
		if(recipe["skill_req"] == new_rank)
			M.character.recipe_state.DiscoverRecipe(recipe_name)
			M << "  ★ Unlocked recipe: [recipe["name"]]"
			recipes_unlocked++
	
	if(recipes_unlocked > 0)
		M << "<i>You feel more confident in the kitchen...</i>"


// ==================== SKILL-BASED QUALITY SCALING ====================

/**
 * Apply skill-based quality multiplier to cooking result
 * Called during FinishCooking() to adjust final meal quality
 * 
 * Quality formula with skill:
 * Final = BaseQuality × SkillMultiplier × TemperatureBonus × OvenBonus
 */
proc/ApplyCookingSkillBonus(mob/players/M, base_quality)
	var/skill_bonus = GetCookingQualityBonus(M)
	return base_quality * skill_bonus

/**
 * Calculate quality range for a recipe given player skill
 * Returns: list with min_quality and max_quality based on skill
 */
proc/list/GetCookingQualityRange(mob/players/M, recipe_name)
	var/list/recipe = RECIPES[recipe_name]
	if(!recipe) return list()
	
	var/base_quality = recipe["quality"] || 1.0
	var/skill_bonus = GetCookingQualityBonus(M)
	
	return list(
		"min_quality" = base_quality * skill_bonus * 0.8,  // 80% of bonus
		"max_quality" = base_quality * skill_bonus * 1.2   // 120% of bonus
	)


// ==================== COOKING MENU INTEGRATION ====================

/**
 * Build cooking menu showing available recipes for player
 * Groups recipes by unlock status and skill requirement
 */
proc/BuildCookingMenuText(mob/players/M)
	var/rank = GetCookingSkillRank(M)
	var/title = GetCookingSkillTitle(rank)
	
	var/menu = "<b>═══ COOKING MENU ═══</b>\n"
	menu += "Skill: [title] (Rank [rank])\n\n"
	
	var/list/known = list()
	var/list/locked = list()
	
	for(var/recipe_name in RECIPES)
		var/list/recipe = RECIPES[recipe_name]
		if(!recipe || recipe["category"] != "cooking") continue
		
		if(M.character.recipe_state.IsRecipeDiscovered(recipe_name))
			known += recipe_name
		else
			locked += recipe_name
	
	menu += "<b>Known Recipes ([known.len]):</b>\n"
	for(var/r in known)
		var/list/recipe = RECIPES[r]
		menu += "  ✓ [recipe["name"]] (Rank [recipe["skill_req"]])\n"
	
	if(!known.len)
		menu += "  (None yet - experiment with ingredients!)\n"
	
	menu += "\n<b>Locked Recipes ([locked.len]):</b>\n"
	menu += "  Reach higher cooking ranks to unlock new recipes.\n"
	
	return menu

/**
 * Show cooking status to player
 * Displays current rank, XP progress, and next milestone
 */
proc/ShowCookingStatus(mob/players/M)
	if(!M || !M.character) return
	
	var/rank = GetCookingSkillRank(M)
	var/title = GetCookingSkillTitle(rank)
	var/xp = GetCookingExperience(M)
	
	var/status = "<b>═══ COOKING SKILL STATUS ═══</b>\n\n"
	status += "Rank: [rank]/10\n"
	status += "Title: [title]\n"
	status += "Experience: [xp] XP\n"
	status += "Quality Multiplier: [round(GetCookingQualityBonus(M) * 100)]%\n\n"
	
	// Show next milestone
	switch(rank)
		if(0)
			status += "Next Milestone: Apprentice at 500 XP\n"
		if(1)
			status += "Next Milestone: Practiced at 1500 XP\n"
		if(2)
			status += "Next Milestone: Competent at 3500 XP\n"
		if(3)
			status += "Next Milestone: Skilled at 7000 XP\n"
		if(4)
			status += "Next Milestone: Expert at 12000 XP\n"
		if(5)
			status += "Next Milestone: Master at 18000 XP\n"
		if(6)
			status += "Next Milestone: Legendary at 50000 XP\n"
		if(7 to 999)
			status += "You are at the pinnacle of culinary arts!\n"
	
	M << status


// ==================== INITIALIZATION ====================

var/global/cooking_skill_initialized = 0

proc/InitializeCookingSkillSystem()
	if(cooking_skill_initialized) return
	cooking_skill_initialized = 1
	world << "Cooking Skill Progression System Initialized"
