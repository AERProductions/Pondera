/**
 * UNIFIED RANK SYSTEM (REFACTORED)
 * Data-driven rank progression with zero code duplication
 * Eliminates massive switch statements through registry-based lookups
 * 
 * DESIGN: Rank definitions stored in associative array mapping rank_type -> {level_var, exp_var, maxexp_var, ui_element}
 * All ranks stored in datum/character_data with consistent access patterns via RegisteredRankGet/Set procs
 * Character datum created in mob/players/New().
 * 
 * Usage Pattern:
 *   M.UpdateRankExp(rank_type, exp_gain)      // Add experience, handle level-ups
 *   M.GetRankLevel(rank_type)                 // Get current level (1-5)
 *   M.CheckRankRequirement(rank_type, level)  // Verify player meets requirement
 * 
 * Rank Registry: RANK_DEFINITIONS global associative array
 *   key = rank_type (RANK_FISHING, RANK_CRAFTING, etc.)
 *   value = list(level_var_name, exp_var_name, maxexp_var_name, ui_element_name, display_name)
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
#define BASE_EXP_FOR_LEVEL 100

// Global rank registry - maps rank_type to [level_var, exp_var, maxexp_var, ui_element, display_name]
var/global/RANK_DEFINITIONS = list()

// ==================== RANK REGISTRY INITIALIZATION ====================

proc/InitializeRankDefinitions()
	/**
	 * InitializeRankDefinitions()
	 * Called once during world startup to register all rank types
	 * Populates RANK_DEFINITIONS with lookups for fast O(1) access
	 * FORMAT: [level_var, exp_var, maxexp_var, ui_element, display_name]
	 */
	RANK_DEFINITIONS[RANK_FISHING] = list("frank", "frankEXP", "frankMAXEXP", "bar_fishing", "Fishing")
	RANK_DEFINITIONS[RANK_CRAFTING] = list("crank", "crankEXP", "crankMAXEXP", "bar_crafting", "Crafting")
	RANK_DEFINITIONS[RANK_GARDENING] = list("grank", "grankEXP", "grankMAXEXP", "bar12", "Gardening")
	RANK_DEFINITIONS[RANK_WOODCUTTING] = list("hrank", "hrankEXP", "hrankMAXEXP", "bar3", "Woodcutting")
	RANK_DEFINITIONS[RANK_MINING] = list("mrank", "mrankEXP", "mrankMAXEXP", "bar_mining", "Mining")
	RANK_DEFINITIONS[RANK_SMITHING] = list("smirank", "smirankEXP", "smirankMAXEXP", "bar_smithing", "Smithing")
	RANK_DEFINITIONS[RANK_SMELTING] = list("smerank", "smerankEXP", "smerankMAXEXP", "bar_smelting", "Smelting")
	RANK_DEFINITIONS[RANK_BUILDING] = list("brank", "brankEXP", "brankMAXEXP", "bar_building", "Building")
	RANK_DEFINITIONS[RANK_DIGGING] = list("drank", "drankEXP", "drankMAXEXP", "bar_digging", "Digging")
	RANK_DEFINITIONS[RANK_CARVING] = list("Crank", "CrankEXP", "CrankMAXEXP", "bar_carving", "Carving")
	RANK_DEFINITIONS[RANK_SPROUT_CUTTING] = list("CSRank", "CSRankEXP", "CSRankMAXEXP", "bar_sprout", "Sprout Cutting")
	RANK_DEFINITIONS[RANK_POLE] = list("PLRank", "PLRankEXP", "PLRankMAXEXP", "bar_pole", "Pole")
	RANK_DEFINITIONS[RANK_ARCHERY] = list("archery_rank", "archery_xp", "archery_maxexp", "bar_archery", "Archery")
	RANK_DEFINITIONS[RANK_CROSSBOW] = list("crossbow_rank", "crossbow_xp", "crossbow_maxexp", "bar_crossbow", "Crossbow")
	RANK_DEFINITIONS[RANK_THROWING] = list("throwing_rank", "throwing_xp", "throwing_maxexp", "bar_throwing", "Throwing")

// ==================== INTERNAL HELPER - SAFE VARIABLE ACCESS ====================

/mob/players/proc/GetRankVariable(rank_type, var_index)
	/**
	 * GetRankVariable(rank_type, var_index) -> value
	 * Internal helper to safely access character datum variables by name
	 * var_index: 0=level, 1=exp, 2=maxexp
	 * Returns sensible defaults if rank_type invalid or character missing
	 */
	if(!character) return (var_index == 0) ? 1 : 0
	
	var/rank_data = RANK_DEFINITIONS[rank_type]
	if(!rank_data) return (var_index == 0) ? 1 : 0  // Unknown rank type
	
	var/var_name = rank_data[var_index + 1]  // list indices are 1-based
	return character.vars[var_name]

/mob/players/proc/SetRankVariable(rank_type, var_index, value)
	/**
	 * SetRankVariable(rank_type, var_index, value)
	 * Internal helper to safely set character datum variables by name
	 * var_index: 0=level, 1=exp, 2=maxexp
	 */
	if(!character) return
	
	var/rank_data = RANK_DEFINITIONS[rank_type]
	if(!rank_data) return  // Unknown rank type - fail silently
	
	var/var_name = rank_data[var_index + 1]
	if(var_index == 0)  // Level capping
		character.vars[var_name] = min(value, MAX_RANK_LEVEL)
	else
		character.vars[var_name] = max(value, 0)  // No negative exp/maxexp

// ==================== RANK PROPERTY ACCESSORS (DATA-DRIVEN) ====================

/mob/players/proc/GetRankLevel(rank_type)
	/**
	 * GetRankLevel(rank_type) -> level (1-5)
	 * Single-line accessor using registry lookup
	 */
	return GetRankVariable(rank_type, 0)

/mob/players/proc/SetRankLevel(rank_type, new_level)
	/**
	 * SetRankLevel(rank_type, new_level)
	 * Single-line setter capping at MAX_RANK_LEVEL
	 */
	SetRankVariable(rank_type, 0, new_level)

/mob/players/proc/GetRankExp(rank_type)
	/**
	 * GetRankExp(rank_type) -> current_exp
	 * Single-line accessor
	 */
	return GetRankVariable(rank_type, 1)

/mob/players/proc/SetRankExp(rank_type, new_exp)
	/**
	 * SetRankExp(rank_type, new_exp)
	 * Single-line setter clamping to >= 0
	 */
	SetRankVariable(rank_type, 1, new_exp)

/mob/players/proc/GetRankMaxExp(rank_type)
	/**
	 * GetRankMaxExp(rank_type) -> max_exp_for_current_level
	 * Single-line accessor
	 */
	return GetRankVariable(rank_type, 2)

/mob/players/proc/SetRankMaxExp(rank_type, new_max_exp)
	/**
	 * SetRankMaxExp(rank_type, new_max_exp)
	 * Single-line setter clamping to >= 10
	 */
	new_max_exp = max(new_max_exp, 10)
	SetRankVariable(rank_type, 2, new_max_exp)

/mob/players/proc/GetRankIsMaxed(rank_type)
	/**
	 * GetRankIsMaxed(rank_type) -> is_maxed (0 or 1)
	 * Returns 1 if rank is at maximum level, 0 otherwise
	 */
	return GetRankLevel(rank_type) >= MAX_RANK_LEVEL

/mob/players/proc/GetRankDisplayName(rank_type)
	/**
	 * GetRankDisplayName(rank_type) -> display_string
	 * Returns human-readable name for UI display
	 */
	var/rank_data = RANK_DEFINITIONS[rank_type]
	if(!rank_data) return "Unknown"
	return rank_data[5]

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
	if(!src.client || !character) return
	
	if(GetRankIsMaxed(rank_type)) return  // Already at max
	
	var/current_exp = GetRankExp(rank_type)
	var/max_exp = GetRankMaxExp(rank_type)
	var/new_exp = min(current_exp + exp_gain, max_exp)  // Clamp at max_exp
	
	SetRankExp(rank_type, new_exp)
	
	// Check for level ups
	while(GetRankExp(rank_type) >= GetRankMaxExp(rank_type) && !GetRankIsMaxed(rank_type))
		AdvanceRank(rank_type)
	
	// Update UI progress bar
	UpdateRankUI(rank_type)

/mob/players/proc/AdvanceRank(rank_type)
	/**
	 * AdvanceRank(rank_type)
	 * Handle a single rank level-up with exp overflow carry-over
	 */
	if(!character || GetRankIsMaxed(rank_type)) return
	
	var/current_level = GetRankLevel(rank_type)
	var/current_exp = GetRankExp(rank_type)
	var/max_exp = GetRankMaxExp(rank_type)
	
	// Calculate overflow that carries to next level
	var/overflow = current_exp - max_exp
	
	// Increase level and reset exp
	SetRankLevel(rank_type, current_level + 1)
	SetRankExp(rank_type, max(overflow, 0))
	
	// Increase max exp for next level using formula: BASE_EXP_FOR_LEVEL + (level * 50)
	var/next_level = current_level + 1
	var/new_max_exp = max_exp + (BASE_EXP_FOR_LEVEL + (next_level * 50))
	SetRankMaxExp(rank_type, new_max_exp)
	
	// Notify player
	var/rank_name = GetRankDisplayName(rank_type)
	src << "<font color=gold>You have advanced in [rank_name]! (Level [next_level])</font>"

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
	 * Maps rank type to UI element via RANK_DEFINITIONS registry
	 */
	if(!character || !client) return
	
	var/rank_data = RANK_DEFINITIONS[rank_type]
	if(!rank_data) return
	
	var/ui_element = rank_data[4]
	var/current_exp = GetRankExp(rank_type)
	var/max_exp = GetRankMaxExp(rank_type)
	var/progress = 100 * current_exp / max_exp
	
	winset(src, ui_element, "value=[progress]")

// ==================== BACKWARD COMPATIBILITY ====================

/mob/players/proc/AddRankExp(rank_type, exp_gain)
	/**
	 * AddRankExp(rank_type, exp_gain)
	 * Alias for UpdateRankExp for backward compatibility with old code
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

// ==================== WORLD STARTUP ====================

// Note: InitializeRankDefinitions() should be called during world initialization
// Typically invoked from InitializationManager.dm Phase 1
// Can also be called manually: InitializeRankDefinitions()
