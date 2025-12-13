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
	
	// WATER (Rank 9+)
	LANDSCAPING_REGISTRY["Water"] = list(
		"simple",
		null,
		list(/obj/Landscaping/Water, 20, 5)
	)
	
	// LAVA (Rank 10)
	LANDSCAPING_REGISTRY["Lava"] = list(
		"simple",
		null,
		list(/obj/Landscaping/Lava, 50, 15)
	)

// ==================== CLIMBING SYSTEM ====================

proc/AttemptClimb(mob/players/M, target_elevation)
	//
	// AttemptClimb(M, target_elevation) -> success (0-1)
	// Attempts to traverse a climbable wall (ditch entry/exit, hill)
	// 
	// Climbing success formula:
	// - Base success: 70%
	// - Modifier: +5% per climbing rank
	// - Risk: Failure = short fall damage
	// 
	// Returns:
	// 1 = successful climb to target_elevation
	// 0 = failed climb, took fall damage
	//
	
	if(!M || !M.character) return 0
	
	var/climb_rank = M.character.GetRankLevel(RANK_CLIMBING)
	var/climb_rank_bonus = climb_rank * 5  // 5% per rank
	
	// Base success chance scales with rank
	var/success_chance = 70 + climb_rank_bonus  // 70% base + rank bonus
	success_chance = min(success_chance, 95)  // Cap at 95% (never guaranteed)
	
	if(prob(success_chance))
		// Success: Change elevation
		M.elevel = target_elevation
		M.layer = FindLayer(M.elevel)
		M.invisibility = FindInvis(M.elevel)
		M << "<green><b>You climb successfully!</b>"
		
		// Award small XP for successful climb (grows with rank)
		var/climb_xp = 5 + (climb_rank * 2)  // 5-15 XP per climb based on rank
		M.character.UpdateRankExp(RANK_CLIMBING, climb_xp)
		M.updateDXP()  // Updates climbing rank display
		
		return 1
	else
		// Failure: Fall and take damage
		M << "<red><b>You lose your grip and fall!</b>"
		var/fall_damage = 10 + (5 - climb_rank)  // More damage for lower rank
		fall_damage = max(fall_damage, 5)  // Minimum 5 damage
		M.HP -= fall_damage
		M.updateHP()
		
		// Even failed attempts award tiny XP (learning from failure)
		M.character.UpdateRankExp(RANK_CLIMBING, 1)
		
		return 0

proc/IsClimbableWall(obj/wall_obj)
	//
	// IsClimbableWall(wall_obj) -> 1 if climbable, 0 if not
	// Determines if an object is a valid climbable wall
	// Climbable: Hills, ditches, trenches
	// NOT climbable: Fort walls, castle walls, regular walls
	//
	
	if(!wall_obj) return 0
	
	// Climbable types
	if(istype(wall_obj, /elevation/hill)) return 1
	if(istype(wall_obj, /elevation/ditch)) return 1
	if(istype(wall_obj, /elevation/trench)) return 1
	
	// Non-climbable fortress walls
	if(istype(wall_obj, /obj/Buildable/Walls)) return 0
	if(istype(wall_obj, /obj/Buildable/Doors)) return 0
	if(istype(wall_obj, /obj/fortress_wall)) return 0
	
	return 0

// ==================== CLIMBING INTEGRATION WITH MOVEMENT ====================

proc/HandleClimbAttempt(mob/players/M, obj/target_wall, target_elevation)
	//
	// HandleClimbAttempt(M, target_wall, target_elevation)
	// Triggered when player tries to move into/out of a ditch or hill
	// 
	// Replaces the current broken ditch system where players get trapped
	// Now automatically attempts climbing based on rank
	//
	
	if(!IsClimbableWall(target_wall))
		return 0
	
	// Climbing attempt
	if(AttemptClimb(M, target_elevation))
		return 1  // Successfully climbed, allow movement
	else
		return 0  // Failed climb, block movement

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

