/**
 * CLIMBING MACRO INTEGRATION - PHASE 6
 * 
 * Adds E-key (UseObject) support for climbing elevation objects
 * Extends elevation objects to work with macro-based interaction
 * 
 * MECHANICS:
 * - Player presses E-key near ditch/hill/stairs
 * - UseObject() handler triggers AttemptClimbTraversal
 * - Success = elevation change + XP
 * - Failure = fall damage + XP
 * - Integrated with existing ClimbingSystem.dm
 * 
 * ELEVATION TYPES SUPPORTED:
 * - /elevation/ditch (downward transition)
 * - /elevation/hill (upward transition)
 * - /elevation/stairs (multi-directional)
 */

// ==================== DITCH CLIMBING - E-KEY INTEGRATION ====================

/elevation/ditch
	/**
	 * UseObject(mob/user) - E-key handler for ditch climbing
	 * Called when player presses E near a ditch
	 * Handles downward elevation transition with climbing checks
	 */
	UseObject(mob/user)
		// Range check: must be adjacent
		if(user in range(1, src))
			// Type check
			if(!istype(user, /mob/players))
				return 0
			
			var/mob/players/M = user
			
			// Direction check: can only enter ditch from specific direction
			// Ditches block based on directional access (see Chk_Enter)
			if(!M.CanAttemptClimb(elevel))
				M << "<red>You're not experienced enough to climb down here. (Requires Climbing Rank 2+)"
				return 1
			
			// Attempt the climb
			if(M.AttemptClimbTraversal(elevel))
				// Success: player moved into ditch
				return 1
			else
				// Failed climb: player stays at current elevation, took damage
				return 1
		
		return 0

// ==================== HILL CLIMBING - E-KEY INTEGRATION ====================

/elevation/hill
	/**
	 * UseObject(mob/user) - E-key handler for hill climbing
	 * Called when player presses E near a hill
	 * Handles upward elevation transition with climbing checks
	 */
	UseObject(mob/user)
		// Range check: must be adjacent
		if(user in range(1, src))
			// Type check
			if(!istype(user, /mob/players))
				return 0
			
			var/mob/players/M = user
			
			// Direction check: can only enter hill from specific direction
			// Hills enforce directional entry (see Chk_Enter)
			if(!M.CanAttemptClimb(elevel))
				M << "<red>You're not experienced enough to climb up here. (Requires Climbing Rank 1+)"
				return 1
			
			// Attempt the climb
			if(M.AttemptClimbTraversal(elevel))
				// Success: player moved up the hill
				return 1
			else
				// Failed climb: player stays at current elevation, took damage
				return 1
		
		return 0

// ==================== STAIRS CLIMBING - E-KEY INTEGRATION ====================

/elevation/stairs
	/**
	 * UseObject(mob/user) - E-key handler for stair climbing
	 * Called when player presses E near stairs
	 * Handles multi-directional elevation transition
	 */
	UseObject(mob/user)
		// Range check: must be adjacent
		if(user in range(1, src))
			// Type check
			if(!istype(user, /mob/players))
				return 0
			
			var/mob/players/M = user
			
			// Stairs allow multi-directional access (if not blocked by direction)
			if(!M.CanAttemptClimb(elevel))
				M << "<red>You're not experienced enough to use these stairs. (Requires Climbing Rank 1+)"
				return 1
			
			// Attempt the climb
			if(M.AttemptClimbTraversal(elevel))
				// Success: player navigated stairs
				return 1
			else
				// Failed climb: player stays at current elevation, took damage
				return 1
		
		return 0

// ==================== CLIMBING FEEDBACK & UI ====================

proc/ShowClimbingPrompt(mob/players/M, elevation/E)
	/*
	 * ShowClimbingPrompt(M, E) - Display E-key prompt
	 * Called when player enters range of climbable elevation
	 * Shows climbing difficulty and current rank
	 */
	
	if(!M || !E) return
	
	var/difficulty = GetClimbingDifficulty(M.elevel, E.elevel)
	var/rank = M.character.GetRankLevel(RANK_CLIMBING)
	
	var/color = "white"
	switch(difficulty)
		if(1, 2) color = "green"    // Easy
		if(3) color = "yellow"       // Medium
		if(4, 5) color = "red"       // Hard/Very Hard
	
	// Potential future: Add HUD element showing prompt
	// For now, this is a placeholder for UI expansion

