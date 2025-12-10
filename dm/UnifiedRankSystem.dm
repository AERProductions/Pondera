/**
 * UNIFIED RANK SYSTEM
 * Consolidates all skill/rank progression into a single parameterized framework
 * Eliminates code duplication across frank, crank, grank, wrank, mrank, smirank, fshrank, etc.
 * 
 * DESIGN: All ranks now stored in datum/character_data for cleaner variable organization
 * and easier save/load functionality. Character datum created in mob/players/New().
 * 
 * Usage Pattern:
 *   M.UpdateRankExp(rank_type, exp_gain)
 *   M.CheckRankRequirement(rank_type, required_level)
 *   M.AdvanceRank(rank_type)
 * 
 * Rank Types (defined as constants):
 *   - RANK_FISHING (frank)
 *   - RANK_CRAFTING (crank)  
 *   - RANK_GARDENING (grank)
 *   - RANK_WOODCUTTING (hrank)
 *   - RANK_MINING (mrank)
 *   - RANK_SMITHING (smirank)
 *   - RANK_SMELTING (smerank)
 *   - RANK_BUILDING (brank)
 *   - RANK_DIGGING (drank)
 *   - RANK_CARVING (Crank - wood carving)
 *   - RANK_SPROUT_CUTTING (CSRank)
 *   - RANK_POLE (PLRank)
 */

#define RANK_FISHING "frank"
#define RANK_CRAFTING "crank"
#define RANK_GARDENING "grank"
#define RANK_WOODCUTTING "hrank"
#define RANK_MINING "mrank"
#define RANK_SMITHING "smirank"
#define RANK_SMELTING "smerank"
#define RANK_BUILDING "brank"
#define RANK_DIGGING "drank"
#define RANK_CARVING "Crank"
#define RANK_SPROUT_CUTTING "CSRank"
#define RANK_POLE "PLRank"
#define RANK_ARCHERY "archery"
#define RANK_CROSSBOW "crossbow"
#define RANK_THROWING "throwing"

#define MAX_RANK_LEVEL 5

// ==================== RANK PROPERTY ACCESSORS ====================

/mob/players/proc/GetRankLevel(rank_type)
	/**
	 * GetRankLevel(rank_type) -> rank_level
	 * Returns the current level of the specified rank type
	 * Returns 1 if rank type not found
	 */
	if(!character) return 1  // Safety check
	switch(rank_type)
		if(RANK_FISHING) return character.frank
		if(RANK_CRAFTING) return character.crank
		if(RANK_GARDENING) return character.grank
		if(RANK_WOODCUTTING) return character.hrank
		if(RANK_MINING) return character.mrank
		if(RANK_SMITHING) return character.smirank
		if(RANK_SMELTING) return character.smerank
		if(RANK_BUILDING) return character.brank
		if(RANK_DIGGING) return character.drank
		if(RANK_CARVING) return character.Crank
		if(RANK_SPROUT_CUTTING) return character.CSRank
		if(RANK_POLE) return character.PLRank
		if(RANK_ARCHERY) return character.archery_rank
		if(RANK_CROSSBOW) return character.crossbow_rank
		if(RANK_THROWING) return character.throwing_rank
		else return 1

/mob/players/proc/SetRankLevel(rank_type, new_level)
	/**
	 * SetRankLevel(rank_type, new_level)
	 * Sets the rank level for the specified rank type
	 */
	if(!character) return
	new_level = min(new_level, MAX_RANK_LEVEL)  // Cap at max level
	switch(rank_type)
		if(RANK_FISHING) character.frank = new_level
		if(RANK_CRAFTING) character.crank = new_level
		if(RANK_GARDENING) character.grank = new_level
		if(RANK_WOODCUTTING) character.hrank = new_level
		if(RANK_MINING) character.mrank = new_level
		if(RANK_SMITHING) character.smirank = new_level
		if(RANK_SMELTING) character.smerank = new_level
		if(RANK_BUILDING) character.brank = new_level
		if(RANK_DIGGING) character.drank = new_level
		if(RANK_CARVING) character.Crank = new_level
		if(RANK_SPROUT_CUTTING) character.CSRank = new_level
		if(RANK_POLE) character.PLRank = new_level
		if(RANK_ARCHERY) character.archery_rank = new_level
		if(RANK_CROSSBOW) character.crossbow_rank = new_level
		if(RANK_THROWING) character.throwing_rank = new_level

/mob/players/proc/GetRankExp(rank_type)
	/**
	 * GetRankExp(rank_type) -> current_exp
	 * Returns current experience points for the rank type
	 */
	if(!character) return 0
	switch(rank_type)
		if(RANK_FISHING) return character.frankEXP
		if(RANK_CRAFTING) return character.crankEXP
		if(RANK_GARDENING) return character.grankEXP
		if(RANK_WOODCUTTING) return character.hrankEXP
		if(RANK_MINING) return character.mrankEXP
		if(RANK_SMITHING) return character.smirankEXP
		if(RANK_SMELTING) return character.smerankEXP
		if(RANK_BUILDING) return character.brankEXP
		if(RANK_DIGGING) return character.drankEXP
		if(RANK_CARVING) return character.CrankEXP
		if(RANK_SPROUT_CUTTING) return character.CSRankEXP
		if(RANK_POLE) return character.PLRankEXP
		if(RANK_ARCHERY) return character.archery_xp
		if(RANK_CROSSBOW) return character.crossbow_xp
		if(RANK_THROWING) return character.throwing_xp
		else return 0

/mob/players/proc/SetRankExp(rank_type, new_exp)
	/**
	 * SetRankExp(rank_type, new_exp)
	 * Sets the current experience for the rank type
	 */
	if(!character) return
	new_exp = max(new_exp, 0)  // Can't have negative exp
	switch(rank_type)
		if(RANK_FISHING) character.frankEXP = new_exp
		if(RANK_CRAFTING) character.crankEXP = new_exp
		if(RANK_GARDENING) character.grankEXP = new_exp
		if(RANK_WOODCUTTING) character.hrankEXP = new_exp
		if(RANK_MINING) character.mrankEXP = new_exp
		if(RANK_SMITHING) character.smirankEXP = new_exp
		if(RANK_SMELTING) character.smerankEXP = new_exp
		if(RANK_BUILDING) character.brankEXP = new_exp
		if(RANK_DIGGING) character.drankEXP = new_exp
		if(RANK_CARVING) character.CrankEXP = new_exp
		if(RANK_SPROUT_CUTTING) character.CSRankEXP = new_exp
		if(RANK_POLE) character.PLRankEXP = new_exp
		if(RANK_ARCHERY) character.archery_xp = new_exp
		if(RANK_CROSSBOW) character.crossbow_xp = new_exp
		if(RANK_THROWING) character.throwing_xp = new_exp

/mob/players/proc/GetRankMaxExp(rank_type)
	/**
	 * GetRankMaxExp(rank_type) -> max_exp_for_level
	 * Returns the maximum experience needed to level up at current level
	 */
	if(!character) return 100
	switch(rank_type)
		if(RANK_FISHING) return character.frankMAXEXP
		if(RANK_CRAFTING) return character.crankMAXEXP
		if(RANK_GARDENING) return character.grankMAXEXP
		if(RANK_WOODCUTTING) return character.hrankMAXEXP
		if(RANK_MINING) return character.mrankMAXEXP
		if(RANK_SMITHING) return character.smirankMAXEXP
		if(RANK_SMELTING) return character.smerankMAXEXP
		if(RANK_BUILDING) return character.brankMAXEXP
		if(RANK_DIGGING) return character.drankMAXEXP
		if(RANK_CARVING) return character.CrankMAXEXP
		if(RANK_SPROUT_CUTTING) return character.CSRankMAXEXP
		if(RANK_POLE) return character.PLRankMAXEXP
		if(RANK_ARCHERY) return character.archery_maxexp
		if(RANK_CROSSBOW) return character.crossbow_maxexp
		if(RANK_THROWING) return character.throwing_maxexp
		else return 100

/mob/players/proc/SetRankMaxExp(rank_type, new_max_exp)
	/**
	 * SetRankMaxExp(rank_type, new_max_exp)
	 * Sets the maximum experience threshold for the current level
	 */
	if(!character) return
	new_max_exp = max(new_max_exp, 10)  // Minimum 10 exp per level
	switch(rank_type)
		if(RANK_FISHING) character.frankMAXEXP = new_max_exp
		if(RANK_CRAFTING) character.crankMAXEXP = new_max_exp
		if(RANK_GARDENING) character.grankMAXEXP = new_max_exp
		if(RANK_WOODCUTTING) character.hrankMAXEXP = new_max_exp
		if(RANK_MINING) character.mrankMAXEXP = new_max_exp
		if(RANK_SMITHING) character.smirankMAXEXP = new_max_exp
		if(RANK_SMELTING) character.smerankMAXEXP = new_max_exp
		if(RANK_BUILDING) character.brankMAXEXP = new_max_exp
		if(RANK_DIGGING) character.drankMAXEXP = new_max_exp
		if(RANK_CARVING) character.CrankMAXEXP = new_max_exp
		if(RANK_SPROUT_CUTTING) character.CSRankMAXEXP = new_max_exp
		if(RANK_POLE) character.PLRankMAXEXP = new_max_exp
		if(RANK_ARCHERY) character.archery_maxexp = new_max_exp
		if(RANK_CROSSBOW) character.crossbow_maxexp = new_max_exp
		if(RANK_THROWING) character.throwing_maxexp = new_max_exp

/mob/players/proc/GetRankIsMaxed(rank_type)
	/**
	 * GetRankIsMaxed(rank_type) -> is_maxed (0 or 1)
	 * Returns 1 if rank is at maximum level, 0 otherwise
	 */
	return GetRankLevel(rank_type) >= MAX_RANK_LEVEL

// ==================== RANK PROGRESSION ====================

/mob/players/proc/UpdateRankExp(rank_type, exp_gain)
	/**
	 * UpdateRankExp(rank_type, exp_gain)
	 * Primary function to add experience to a rank
	 * Handles clamping, leveling, and UI updates
	 * 
	 * Usage:
	 *   var/mob/players/M = user
	 *   M.UpdateRankExp(RANK_WOODCUTTING, 15)  // Gain 15 XP in woodcutting
	 */
	if(!src.client)
		return
	if(!character) return
	
	if(GetRankIsMaxed(rank_type))
		return  // No point gaining exp if already maxed
	
	var/current_exp = GetRankExp(rank_type)
	var/new_exp = current_exp + exp_gain
	var/max_exp = GetRankMaxExp(rank_type)
	
	// Clamp exp to max while gaining levels
	new_exp = min(new_exp, max_exp)
	SetRankExp(rank_type, new_exp)
	
	// Check for level ups
	while(GetRankExp(rank_type) >= GetRankMaxExp(rank_type))
		AdvanceRank(rank_type)
	
	// Update UI progress bar
	UpdateRankUI(rank_type)

/mob/players/proc/AdvanceRank(rank_type)
	/**
	 * AdvanceRank(rank_type)
	 * Handle a single rank level-up
	 * Called internally by UpdateRankExp when exp threshold met
	 */
	if(!character) return
	
	var/current_level = GetRankLevel(rank_type)
	var/current_exp = GetRankExp(rank_type)
	var/max_exp = GetRankMaxExp(rank_type)
	
	// Check if already at max
	if(current_level >= MAX_RANK_LEVEL)
		SetRankLevel(rank_type, MAX_RANK_LEVEL)
		SetRankExp(rank_type, 0)
		return
	
	// Subtract current max exp from current exp (overflow carries to next level)
	var/overflow = current_exp - max_exp
	
	// Increase level and reset exp
	SetRankLevel(rank_type, current_level + 1)
	SetRankExp(rank_type, overflow)
	
	// Increase max exp for next level
	var/new_max_exp = max_exp + exp2lvl(current_level + 1)
	SetRankMaxExp(rank_type, new_max_exp)
	
	// Notify player
	src << "<font color=gold>You gain [rank_type] Acuity!</font>"

/mob/players/proc/CheckRankRequirement(rank_type, required_level)
	/**
	 * CheckRankRequirement(rank_type, required_level) -> meets_requirement
	 * Check if player has sufficient rank level for an action
	 * Returns 1 if requirement met, 0 otherwise
	 * 
	 * Usage:
	 *   if(!usr.CheckRankRequirement(RANK_MINING, 3))
	 *       usr << "You need Mining level 3 to mine this."
	 *       return
	 */
	if(!character) return 0
	return GetRankLevel(rank_type) >= required_level

/mob/players/proc/UpdateRankUI(rank_type)
	/**
	 * UpdateRankUI(rank_type)
	 * Update the HUD progress bar for the specified rank
	 * Maps each rank type to its appropriate UI element
	 */
	if(!character) return
	
	var/current_exp = GetRankExp(rank_type)
	var/max_exp = GetRankMaxExp(rank_type)
	var/progress = 100 * current_exp / max_exp
	
	switch(rank_type)
		if(RANK_WOODCUTTING)
			winset(src, "bar3", "value=[progress]")
		if(RANK_GARDENING)
			winset(src, "bar12", "value=[progress]")
		if(RANK_MINING)
			winset(src, "bar_mining", "value=[progress]")
		if(RANK_CARVING)
			winset(src, "bar_carving", "value=[progress]")
		if(RANK_CRAFTING)
			winset(src, "bar_crafting", "value=[progress]")
		if(RANK_SMITHING)
			winset(src, "bar_smithing", "value=[progress]")
		if(RANK_SMELTING)
			winset(src, "bar_smelting", "value=[progress]")
		if(RANK_SPROUT_CUTTING)
			winset(src, "bar_sprout", "value=[progress]")
		if(RANK_POLE)
			winset(src, "bar_pole", "value=[progress]")
		// Add more UI mappings as needed

// ==================== BACKWARD COMPATIBILITY ====================

/mob/players/proc/AddRankExp(rank_type, exp_gain)
	/**
	 * AddRankExp(rank_type, exp_gain)
	 * Alias for UpdateRankExp for backward compatibility
	 */
	return UpdateRankExp(rank_type, exp_gain)

// ==================== INITIALIZATION ====================

/mob/players/proc/InitializeRanks()
	/**
	 * InitializeRanks()
	 * Called during character creation to set up all rank variables
	 * Now delegates to character datum's Initialize() method
	 * Ensures consistent initialization across all rank types
	 */
	if(!character)
		character = new /datum/character_data()
	character.Initialize()
