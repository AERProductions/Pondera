/**
 * CLIMBING SYSTEM - INTEGRATION WITH ELEVATION
 * 
 * Adds climbing mechanics for elevation transitions (ditches, hills)
 * Integrated with RANK_CLIMBING for progression
 * 
 * MECHANICS:
 * - Elevation transitions use AttemptClimbTraversal to determine success
 * - Higher climbing rank = better chance, reduced fall damage
 * - Failed climbs result in fall damage and stayed at current elevation
 * - XP awards scale with difficulty and rank
 * 
 * NOTE: This system integrates with existing /elevation/ditch and /elevation/hill
 * objects. It does NOT create new object types, just adds mechanics.
 */

// ==================== CLIMBING CHECKS & TRAVERSAL ====================

/mob/players/proc/AttemptClimbTraversal(target_elev)
	/*
	 * AttemptClimbTraversal(target_elev) -> 1 if success, 0 if fail
	 * Called when player tries to change elevation via ditch/hill
	 * 
	 * Success chance calculation:
	 * - Base: 70% (everyone can climb with some risk)
	 * - Rank bonus: +5% per climbing rank (5 × 5 = +25% at rank 5)
	 * - Difficulty penalty: -10% per 0.5 elevation difference
	 * - Final: clamped between 20-95%
	 */
	
	if(!character) return 0
	
	var/climb_rank = character.GetRankLevel(RANK_CLIMBING)
	var/elevation_change = abs(target_elev - elevel)
	
	var/base_success = 70
	var/rank_bonus = climb_rank * 5
	var/difficulty_penalty = elevation_change * 10
	
	var/success_chance = base_success + rank_bonus - difficulty_penalty
	success_chance = clamp(success_chance, 20, 95)
	
	if(prob(success_chance))
		// SUCCESS: Elevation changed
		elevel = target_elev
		layer = FindLayer(elevel)
		invisibility = FindInvis(elevel)
		
		src << "<green><b>You successfully navigate the terrain elevation!</b>"
		
		// Award XP: base 5 + difficulty bonus + rank scaling
		var/climb_xp = 5 + (elevation_change * 2) + (climb_rank * 0.5)
		climb_xp = round(climb_xp)
		character.UpdateRankExp(RANK_CLIMBING, climb_xp)
		updateDXP()
		
		return 1
	else
		// FAILURE: Fall damage, stay at current elevation
		src << "<red><b>You slip and fall!</b>"
		
		var/fall_damage = 5 + (elevation_change * 8) - (climb_rank * 2)
		fall_damage = max(fall_damage, 3)
		HP -= fall_damage
		updateHP()
		
		// Minimal XP for failure (learning)
		character.UpdateRankExp(RANK_CLIMBING, 1)
		
		return 0

/mob/players/proc/CanAttemptClimb(target_elev)
	/*
	 * CanAttemptClimb(target_elev) -> 1 if can attempt, 0 if blocked
	 * Used to gate climbing based on player rank and elevation
	 */
	
	if(!character) return 0
	
	var/climb_rank = character.GetRankLevel(RANK_CLIMBING)
	var/elevation_change = abs(target_elev - elevel)
	
	// Rank 0-1: Can only do small elevation changes (ditches, small hills)
	if(climb_rank < 1 && elevation_change > 1.0)
		return 0
	
	// Rank 2+: Can handle most transitions
	return 1

// ==================== FORTRESS WALL BLOCKING ====================

proc/IsClimbableObject(obj/O)
	/*
	 * IsClimbableObject(O) -> 1 if climbable, 0 if blocked
	 * Used to determine if climbing can be attempted on an object
	 */
	
	if(!O) return 0
	
	// For now, only natural terrain objects are climbable
	// Built structures (walls, doors) should not be climbable
	// This check prevents climbing on fortress walls, castle walls, etc.
	
	// In the future, could check for specific object flags
	// if(O.climbable) return 1
	
	return 0

// ==================== CLIMBING PROGRESSION ====================

/*
 * Climbing Rank Progression:
 * 
 * Rank 0: Beginner (70% base success)
 * - Can attempt ditches and small hills (0.5-1.0 elevation change)
 * - Fall damage: 5-13 per failed climb
 * 
 * Rank 1: Novice (75% base success)
 * - Can attempt all standard elevation transitions
 * - Fall damage: 5-11 per failed climb
 * 
 * Rank 2: Intermediate (80% base success)
 * - Increased confidence on slopes
 * - Fall damage: 5-9 per failed climb
 * 
 * Rank 3: Advanced (85% base success)
 * - Can navigate steep trenches and complex elevation
 * - Fall damage: 5-7 per failed climb
 * 
 * Rank 4: Expert (90% base success)
 * - Few terrain challenges remain
 * - Fall damage: 5-5 (minimal) per failed climb
 * 
 * Rank 5: Master (95% base success)
 * - Expert climber, nearly immune to terrain
 * - Fall damage: 3 (absolute minimum) per failed climb
 */

proc/GetClimbingDifficulty(current_elev, target_elev)
	/*
	 * GetClimbingDifficulty(current, target) -> difficulty_rating (1-5)
	 * Returns a difficulty rating for an elevation change
	 * Used for progression gating and XP scaling
	 */
	
	var/elevation_diff = abs(target_elev - current_elev)
	
	if(elevation_diff <= 0.5) return 1   // Easy (ditch entry/exit)
	if(elevation_diff <= 1.0) return 2   // Moderate (hill climbing)
	if(elevation_diff <= 1.5) return 3   // Hard (steep slopes)
	if(elevation_diff <= 2.0) return 4   // Very hard
	return 5  // Expert only

proc/GetClimbingXPReward(climb_rank, elevation_change, success)
	/*
	 * GetClimbingXPReward(rank, elev_change, success) -> xp_amount
	 * Calculates XP for climbing attempt
	 * 
	 * Success: 5 base + (elev_change * 2) + (rank * 0.5)
	 * Failure: 1 flat (learning from mistakes)
	 */
	
	if(!success) return 1
	
	var/xp = 5 + (elevation_change * 2) + (climb_rank * 0.5)
	return round(xp)

// ==================== UI UPDATES ====================

/mob/players/proc/updateClimbingUI()
	/*
	 * updateClimbingUI() - Refresh climbing rank display in UI
	 * Call after rank changes to update player HUD
	 */
	
	if(!client) return
	
	var/climb_rank = GetRankLevel(RANK_CLIMBING)
	var/climb_xp = GetRankExp(RANK_CLIMBING)
	
	// These winset calls update UI elements (if they exist in DMF)
	// If UI elements don't exist, these are safe no-ops
	winset(usr, "climb_rank", "text='Climbing: [climb_rank]'")
	winset(usr, "climb_xp", "text='[climb_xp] XP'")

// ==================== SKILL DESCRIPTIONS ====================

proc/GetClimbingDescription(rank)
	/*
	 * GetClimbingDescription(rank) -> description string
	 * Returns flavor text for climbing skill level
	 */
	
	switch(rank)
		if(0)
			return "You're new to climbing. Elevation transitions are risky for you."
		if(1)
			return "You've learned the basics of climbing. Simple slopes are manageable."
		if(2)
			return "You're getting confident with elevation transitions and terrain."
		if(3)
			return "You're an experienced climber. Steep slopes no longer worry you."
		if(4)
			return "You're a skilled climber. Few natural obstacles challenge you."
		if(5)
			return "You're a master of climbing. No terrain is beyond your skill."
		else
			return "Unknown climbing skill level."

// ==================== INTEGRATION NOTES ====================

/*
 * INTEGRATION WITH ELEVATION SYSTEM:
 * 
 * 1. ELEVATION CHANGES
 *    - When player enters ditch/hill, call AttemptClimbTraversal(target_elev)
 *    - If success (return 1): Player elevation changes, give XP
 *    - If failure (return 0): Player stays at current elevation, takes fall damage
 * 
 * 2. EXISTING /elevation/ditch AND /elevation/hill
 *    - These objects already exist in the system
 *    - ClimbingSystem just adds success/failure mechanics to them
 *    - Don't need to modify their structure, just call AttemptClimbTraversal
 * 
 * 3. RANK GATING (optional)
 *    - Use CanAttemptClimb() to block certain elevations by rank
 *    - Rank 0-1: Limited to small changes (0.5-1.0)
 *    - Rank 2+: Can attempt most transitions
 * 
 * 4. XP SCALING
 *    - Use GetClimbingXPReward() to scale XP by difficulty
 *    - Harder climbs = more XP
 *    - Rank 5 gets slightly less XP (already dominant)
 * 
 * 5. UI UPDATES
 *    - Call updateClimbingUI() alongside updateDXP()
 *    - Shows rank and progress in HUD
 */
