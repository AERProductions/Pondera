/*
 * LANDSCAPING & DIGGING SYSTEM (MODERNIZED)
 * 
 * Consolidates terrain modification (digging/landscaping) with modern rank progression
 * Replaces 4500+ lines of jb.dm with efficient, maintainable code
 * 
 * CORE SYSTEMS:
 * - CreateLandscapeObject(M, object_type, xp_gain, stamina_cost)
 * - Rank unlock gates per digging level (unified with UnifiedRankSystem)
 * - Climbing system integration (for ditch/hill traversal)
 * - Macro support via UseObject() handlers (future phase)
 */

// ==================== LANDSCAPING OBJECT CREATION ====================

proc/CreateLandscapeObject(mob/players/M, object_type, xp_gain, stamina_cost)
	//
	// CreateLandscapeObject(M, object_type, xp_gain, stamina_cost)
	// Single unified helper for ALL landscape object placement
	// Replaces 100+ identical code blocks in jb.dm
	// 
	// Parameters:
	// - M: Player attempting placement
	// - object_type: Object type path to instantiate
	// - xp_gain: How much digging XP to award
	// - stamina_cost: How much stamina to drain
	// 
	// Returns: 1 if successful, 0 if failed
	//
	
	// Permission checks
	if(!M || !M.character) return 0
	if(!CanPlayerBuildAtLocation(M, M.loc))
		M << "You do not have permission to build here"
		return 0
	
	// Shovel requirement
	if(M.SHequipped != 1)
		M << "You need a shovel equipped to dig"
		return 0
	
	// Stamina requirement
	if(M.stamina < stamina_cost)
		M << "You're too tired to do that! (Stamina: [M.stamina]/[stamina_cost] required)"
		return 0
	
	// Create the landscape object
	var/obj/landscaping_object = new object_type(M.loc)
	if(!landscaping_object)
		M << "Failed to create landscape object"
		return 0
	
	// Set ownership for deed tracking
	landscaping_object.buildingowner = ckeyEx("[M.key]")
	
	// Stamina drain
	M.stamina -= stamina_cost
	M.updateST()
	
	// XP reward (using modern unified rank system)
	M.character.UpdateRankExp(RANK_DIGGING, xp_gain)
	
	// UI update for digging progress
	M.updateDXP()
	
	return 1

// ==================== DIGGING RANK UNLOCK GATES ====================

proc/GetDiggingMenuOptions(mob/players/M)
	//
	// GetDiggingMenuOptions(M) -> list
	// Returns list of available digging options based on player's digging rank
	// Replaces scattered digunlock() proc logic
	// 
	// Rank Gate Table:
	// Rank 1: Dirt
	// Rank 2: + Grass
	// Rank 3: + Dirt Road (NS, EW, 3-way)
	// Rank 4: + Dirt Road Corners
	// Rank 5: + Wood Road
	// Rank 6: (same as 5)
	// Rank 7: + Ditch (entry/exit slopes, corners, straight)
	// Rank 8: + Brick Road + Hill
	// Rank 9: + Water
	// Rank 10: + Lava (max rank)
	//
	
	if(!M || !M.character) return list()
	
	var/dig_rank = M.character.GetRankLevel(RANK_DIGGING)
	var/options = list("Cancel")
	
	// Rank 1+
	options += "Dirt"
	
	// Rank 2+
	if(dig_rank >= 2)
		options += "Grass"
	
	// Rank 3+
	if(dig_rank >= 3)
		options += "Dirt Road"
	
	// Rank 4+
	if(dig_rank >= 4)
		options += "Dirt Road Corner"
	
	// Rank 5+
	if(dig_rank >= 5)
		options += "Wood Road"
		options += "Wood Road Corner"
	
	// Rank 6+ (no new options, same as 5)
	
	// Rank 7+
	if(dig_rank >= 7)
		options += "Ditch"
	
	// Rank 8+
	if(dig_rank >= 8)
		options += "Brick Road"
		options += "Brick Road Corner"
		options += "Hill"
	
	// Rank 9+
	if(dig_rank >= 9)
		options += "Water"
	
	// Rank 10 (max)
	if(dig_rank >= 10)
		options += "Lava"
	
	return options

// ==================== DIGGING OBJECT REGISTRY ====================

// Maps landscaping type names to their object paths, XP values, stamina costs
var/global/LANDSCAPING_REGISTRY = list()

proc/InitializeLandscapingRegistry()
	//
	// InitializeLandscapingRegistry()
	// Called once during world boot to populate landscaping object registry
	// Format: [object_path, xp_gain, stamina_cost, submenu_list]
	//
	
	// DIRT & GRASS (Rank 1-2)
	LANDSCAPING_REGISTRY["Dirt"] = list(
		"submenu", // Indicates this type has a submenu
		list("Direction: NS", "Direction: EW", "Cancel"),
		null  // Placeholder
	)
	LANDSCAPING_REGISTRY["Grass"] = list(
		"submenu",
		list("Direction: NS", "Direction: EW", "Cancel"),
		null
	)
	
	// DIRT ROAD (Rank 3+)
	LANDSCAPING_REGISTRY["Dirt Road"] = list(
		"submenu",
		list("North/South", "East/West", "3-way North", "Cancel"),
		null
	)
	LANDSCAPING_REGISTRY["Dirt Road Corner"] = list(
		"submenu",
		list("NorthWest", "NorthEast", "SouthWest", "SouthEast", "Cancel"),
		null
	)
	
	// WOOD ROAD (Rank 5+)
	LANDSCAPING_REGISTRY["Wood Road"] = list(
		"submenu",
		list("North/South", "East/West", "3-way North", "Cancel"),
		null
	)
	LANDSCAPING_REGISTRY["Wood Road Corner"] = list(
		"submenu",
		list("NorthWest", "NorthEast", "SouthWest", "SouthEast", "Cancel"),
		null
	)
	
	// BRICK ROAD (Rank 8+)
	LANDSCAPING_REGISTRY["Brick Road"] = list(
		"submenu",
		list("North/South", "East/West", "Cancel"),
		null
	)
	LANDSCAPING_REGISTRY["Brick Road Corner"] = list(
		"submenu",
		list("NorthWest", "NorthEast", "SouthWest", "SouthEast", "Cancel"),
		null
	)
	
	// DITCH (Rank 7+)
	LANDSCAPING_REGISTRY["Ditch"] = list(
		"submenu",
		list("Slope(N)", "Slope(S)", "Slope(E)", "Slope(W)", 
		     "Exit(N)", "Exit(S)", "Exit(E)", "Exit(W)",
		     "Corner(NE)", "Corner(NW)", "Corner(SE)", "Corner(SW)",
		     "Ditch(NS)", "Ditch(EW)", "Cancel"),
		null
	)
	
	// HILL (Rank 8+)
	LANDSCAPING_REGISTRY["Hill"] = list(
		"submenu",
		list("Slope(N)", "Slope(S)", "Slope(E)", "Slope(W)",
		     "Corner(NE)", "Corner(NW)", "Corner(SE)", "Corner(SW)",
		     "Hill(NS)", "Hill(EW)", "Cancel"),
		null
	)
	
	// WATER (Rank 9+) - Placeholder, implement in future
	// LANDSCAPING_REGISTRY["Water"] = list(...)
	
	// LAVA (Rank 10) - Placeholder, implement in future
	// LANDSCAPING_REGISTRY["Lava"] = list(...)

// ==================== DIGGING VERB (MODERNIZED) ====================

mob/players/verb/DigModern()
	set hidden = 1
	set name = "Dig Modern"
	
	//
	// DigModern() - Modernized digging verb
	// Replaces the 4000+ line verb in jb.dm with clean, maintainable code
	//
	
	var/mob/players/M = usr
	
	// Check deed permissions
	if(!CanPlayerBuildAtLocation(M, M.loc))
		M << "You do not have permission to dig here"
		return
	
	// Check equipment
	if(M.SHequipped != 1)
		M << "You need a shovel equipped to dig"
		return
	
	// Prevent double-casting
	if(M.UED)
		M << "You're already digging!"
		return
	M.UED = 1
	
	// Get available options based on rank
	var/dig_menu = GetDiggingMenuOptions(M)
	var/choice = input("What would you like to dig?", "Dig") as null|anything in dig_menu
	
	if(!choice || choice == "Cancel")
		M.UED = 0
		return
	
	// Process the choice (simplified - full implementation in Phase 2)
	M << "Digging: [choice]..."
	M.UED = 0

