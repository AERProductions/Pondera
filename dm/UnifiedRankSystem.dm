/**
 * UNIFIED RANK SYSTEM
 * Consolidates all skill/rank progression into a single parameterized framework
 * Eliminates code duplication across frank, crank, grank, wrank, mrank, smirank, fshrank, etc.
 * 
 * DESIGN NOTE: Currently some ranks are stored as mob/players/var while others (hrank, Crank, 
 * CSRank, PLRank) are stored as global var in WC.dm. This should be consolidated so all ranks
 * are mob/players/var for proper multi-player support.
 * 
 * Usage Pattern:
 *   M.UpdateRankExp(rank_type, exp_gain)
 *   M.CheckRankLevel(rank_type, required_level)
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
 *   - RANK_CARVING (Crank - wood carving) [GLOBAL - should be mob/var]
 *   - RANK_SPROUT_CUTTING (CSRank) [GLOBAL - should be mob/var]
 *   - RANK_POLE (PLRank) [GLOBAL - should be mob/var]
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

#define MAX_RANK_LEVEL 5

// ==================== RANK PROPERTY ACCESSORS ====================

/mob/players/proc/GetRankLevel(rank_type)
	/**
	 * GetRankLevel(rank_type) -> rank_level
	 * Returns the current level of the specified rank type
	 * Returns 1 if rank type not found
	 */
	switch(rank_type)
		if(RANK_FISHING) return src.frank
		if(RANK_CRAFTING) return src.crank
		if(RANK_GARDENING) return src.grank
		if(RANK_WOODCUTTING) return src.hrank
		if(RANK_MINING) return src.mrank
		if(RANK_SMITHING) return src.smirank
		if(RANK_SMELTING) return src.smerank
		if(RANK_BUILDING) return src.brank
		if(RANK_DIGGING) return src.drank
		if(RANK_CARVING) return src.Crank
		if(RANK_SPROUT_CUTTING) return src.CSRank
		if(RANK_POLE) return src.PLRank
		else return 1

/mob/players/proc/SetRankLevel(rank_type, new_level)
	/**
	 * SetRankLevel(rank_type, new_level)
	 * Sets the rank level for the specified rank type
	 */
	new_level = min(new_level, MAX_RANK_LEVEL)  // Cap at max level
	switch(rank_type)
		if(RANK_FISHING) src.frank = new_level
		if(RANK_CRAFTING) src.crank = new_level
		if(RANK_GARDENING) src.grank = new_level
		if(RANK_WOODCUTTING) src.hrank = new_level
		if(RANK_MINING) src.mrank = new_level
		if(RANK_SMITHING) src.smirank = new_level
		if(RANK_SMELTING) src.smerank = new_level
		if(RANK_BUILDING) src.brank = new_level
		if(RANK_DIGGING) src.drank = new_level
		if(RANK_CARVING) src.Crank = new_level
		if(RANK_SPROUT_CUTTING) src.CSRank = new_level
		if(RANK_POLE) src.PLRank = new_level

/mob/players/proc/GetRankExp(rank_type)
	/**
	 * GetRankExp(rank_type) -> current_exp
	 * Returns current experience points for the rank type
	 */
	switch(rank_type)
		if(RANK_FISHING) return src.frankEXP
		if(RANK_CRAFTING) return src.CrankEXP
		if(RANK_GARDENING) return src.grankEXP
		if(RANK_WOODCUTTING) return src.hrankEXP
		if(RANK_MINING) return src.mrankEXP
		if(RANK_SMITHING) return src.smiexp
		if(RANK_SMELTING) return src.smeexp
		if(RANK_BUILDING) return src.brankEXP
		if(RANK_DIGGING) return src.drankEXP
		if(RANK_CARVING) return src.CrankEXP
		if(RANK_SPROUT_CUTTING) return src.CSRankEXP
		if(RANK_POLE) return src.PLRankEXP
		else return 0

/mob/players/proc/SetRankExp(rank_type, new_exp)
	/**
	 * SetRankExp(rank_type, new_exp)
	 * Sets the current experience for the rank type
	 */
	new_exp = max(new_exp, 0)  // Can't have negative exp
	switch(rank_type)
		if(RANK_FISHING) src.frankEXP = new_exp
		if(RANK_CRAFTING) src.CrankEXP = new_exp
		if(RANK_GARDENING) src.grankEXP = new_exp
		if(RANK_WOODCUTTING) src.hrankEXP = new_exp
		if(RANK_MINING) src.mrankEXP = new_exp
		if(RANK_SMITHING) src.smiexp = new_exp
		if(RANK_SMELTING) src.smeexp = new_exp
		if(RANK_BUILDING) src.brankEXP = new_exp
		if(RANK_DIGGING) src.drankEXP = new_exp
		if(RANK_CARVING) src.CrankEXP = new_exp
		if(RANK_SPROUT_CUTTING) src.CSRankEXP = new_exp
		if(RANK_POLE) src.PLRankEXP = new_exp

/mob/players/proc/GetRankMaxExp(rank_type)
	/**
	 * GetRankMaxExp(rank_type) -> max_exp_for_level
	 * Returns the maximum experience needed to level up at current level
	 */
	switch(rank_type)
		if(RANK_FISHING) return src.frankMAXEXP
		if(RANK_CRAFTING) return src.CrankMAXEXP
		if(RANK_GARDENING) return src.grankMAXEXP
		if(RANK_WOODCUTTING) return src.hrankMAXEXP
		if(RANK_MINING) return src.mrankMAXEXP
		if(RANK_SMITHING) return src.msmiexp
		if(RANK_SMELTING) return src.msmeexp
		if(RANK_BUILDING) return src.brankMAXEXP
		if(RANK_DIGGING) return src.drankMAXEXP
		if(RANK_CARVING) return src.CrankMAXEXP
		if(RANK_SPROUT_CUTTING) return src.CSRankMAXEXP
		if(RANK_POLE) return src.PLRankMAXEXP
		else return 100

/mob/players/proc/SetRankMaxExp(rank_type, new_max_exp)
	/**
	 * SetRankMaxExp(rank_type, new_max_exp)
	 * Sets the maximum experience threshold for the current level
	 */
	new_max_exp = max(new_max_exp, 10)  // Minimum 10 exp per level
	switch(rank_type)
		if(RANK_FISHING) src.frankMAXEXP = new_max_exp
		if(RANK_CRAFTING) src.CrankMAXEXP = new_max_exp
		if(RANK_GARDENING) src.grankMAXEXP = new_max_exp
		if(RANK_WOODCUTTING) src.hrankMAXEXP = new_max_exp
		if(RANK_MINING) src.mrankMAXEXP = new_max_exp
		if(RANK_SMITHING) src.msmiexp = new_max_exp
		if(RANK_SMELTING) src.msmeexp = new_max_exp
		if(RANK_BUILDING) src.brankMAXEXP = new_max_exp
		if(RANK_DIGGING) src.drankMAXEXP = new_max_exp
		if(RANK_CARVING) src.CrankMAXEXP = new_max_exp
		if(RANK_SPROUT_CUTTING) src.CSRankMAXEXP = new_max_exp
		if(RANK_POLE) src.PLRankMAXEXP = new_max_exp

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
	return GetRankLevel(rank_type) >= required_level

/mob/players/proc/UpdateRankUI(rank_type)
	/**
	 * UpdateRankUI(rank_type)
	 * Update the HUD progress bar for the specified rank
	 * Maps each rank type to its appropriate UI element
	 */
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
	 * Ensures consistent initialization across all rank types
	 */
	// Fishing rank
	if(!src.frank) src.frank = 1
	if(!src.frankEXP) src.frankEXP = 0
	if(!src.frankMAXEXP) src.frankMAXEXP = 100
	
	// Crafting rank
	if(!src.crank) src.crank = 1
	if(!src.CrankEXP) src.CrankEXP = 0
	if(!src.CrankMAXEXP) src.CrankMAXEXP = 10
	
	// Gardening rank
	if(!src.grank) src.grank = 1
	if(!src.grankEXP) src.grankEXP = 0
	if(!src.grankMAXEXP) src.grankMAXEXP = 100
	
	// Woodcutting rank
	if(!src.hrank) src.hrank = 1
	if(!src.hrankEXP) src.hrankEXP = 0
	if(!src.hrankMAXEXP) src.hrankMAXEXP = 10
	
	// Mining rank
	if(!src.mrank) src.mrank = 1
	if(!src.mrankEXP) src.mrankEXP = 0
	if(!src.mrankMAXEXP) src.mrankMAXEXP = 10
	
	// Smithing rank
	if(!src.smirank) src.smirank = 1
	if(!src.smiexp) src.smiexp = 0
	if(!src.msmiexp) src.msmiexp = 100
	
	// Smelting rank
	if(!src.smerank) src.smerank = 1
	if(!src.smeexp) src.smeexp = 0
	if(!src.msmeexp) src.msmeexp = 100
	
	// Building rank
	if(!src.brank) src.brank = 1
	if(!src.brankEXP) src.brankEXP = 0
	if(!src.brankMAXEXP) src.brankMAXEXP = 100
	
	// Digging rank
	if(!src.drank) src.drank = 1
	if(!src.drankEXP) src.drankEXP = 0
	if(!src.drankMAXEXP) src.drankMAXEXP = 100
	
	// Carving rank (wood carving)
	if(!src.Crank) src.Crank = 1
	if(!src.CrankEXP) src.CrankEXP = 0
	if(!src.CrankMAXEXP) src.CrankMAXEXP = 10
	
	// Sprout cutting rank
	if(!src.CSRank) src.CSRank = 1
	if(!src.CSRankEXP) src.CSRankEXP = 0
	if(!src.CSRankMAXEXP) src.CSRankMAXEXP = 10
	
	// Pole rank
	if(!src.PLRank) src.PLRank = 1
	if(!src.PLRankEXP) src.PLRankEXP = 0
	if(!src.PLRankMAXEXP) src.PLRankMAXEXP = 100
