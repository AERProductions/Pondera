/**
 * MOVEMENT MODERNIZATION - Optional Enhancement Layer
 * 
 * Current system uses: MN, MS, ME, MW (directional flags) + QueN, QueS, QueE, QueW (queued)
 * This works but is verbose and error-prone
 * 
 * New system: Uses movement_state datum with cleaner interface
 * Backward compatible - wraps existing system
 * 
 * Benefits:
 * - Cleaner variable naming
 * - Easier to understand intent
 * - Easier to debug movement issues
 * - Can add features (stamina drain, acceleration) without complication
 */

/datum/movement_state
	var
		mob/owner                  // Reference to moving mob
		
		// Direction state (replaces MN, MS, ME, MW)
		moving_north = FALSE
		moving_south = FALSE
		moving_east = FALSE
		moving_west = FALSE
		
		// Queued inputs (replaces QueN, QueS, QueE, QueW)
		queued_north = FALSE
		queued_south = FALSE
		queued_east = FALSE
		queued_west = FALSE
		
		// Movement properties
		is_sprinting = FALSE
		is_moving = FALSE
		movement_speed = 3
		last_move_time = 0
		last_move_direction = 0

	New(mob/M)
		owner = M
		is_moving = FALSE
		movement_speed = M.MovementSpeed || 3

	// ===== LEGACY COMPATIBILITY LAYER =====
	
	proc/ApplyToLegacyVars()
		/**
		 * Sync new state to legacy variables for compatibility
		 * Call this after updating movement_state to apply to player
		 */
		if(!owner) return
		
		owner.MN = moving_north ? 1 : 0
		owner.MS = moving_south ? 1 : 0
		owner.ME = moving_east ? 1 : 0
		owner.MW = moving_west ? 1 : 0
		owner.QueN = queued_north ? 1 : 0
		owner.QueS = queued_south ? 1 : 0
		owner.QueE = queued_east ? 1 : 0
		owner.QueW = queued_west ? 1 : 0

	proc/LoadFromLegacyVars()
		/**
		 * Read new state from legacy variables for compatibility
		 * Call this if legacy code updates MN/MS/ME/MW directly
		 */
		if(!owner) return
		
		moving_north = owner.MN ? TRUE : FALSE
		moving_south = owner.MS ? TRUE : FALSE
		moving_east = owner.ME ? TRUE : FALSE
		moving_west = owner.MW ? TRUE : FALSE
		queued_north = owner.QueN ? TRUE : FALSE
		queued_south = owner.QueS ? TRUE : FALSE
		queued_east = owner.QueE ? TRUE : FALSE
		queued_west = owner.QueW ? TRUE : FALSE

	// ===== NEW CLEAN INTERFACE =====

	proc/ClearAllDirections()
		/**
		 * Reset all movement directions
		 * Cleaner than: src.MN=0;src.MS=0;src.ME=0;src.MW=0
		 */
		moving_north = FALSE
		moving_south = FALSE
		moving_east = FALSE
		moving_west = FALSE

	proc/ClearAllQueued()
		/**
		 * Reset all queued directions
		 * Cleaner than: src.QueN=0;src.QueS=0;src.QueE=0;src.QueW=0
		 */
		queued_north = FALSE
		queued_south = FALSE
		queued_east = FALSE
		queued_west = FALSE

	proc/AnyDirectionActive()
		/**
		 * Check if any direction is being held or queued
		 * Cleaner than: while(src.MN || src.ME || src.MW || src.MS || ...)
		 */
		return moving_north || moving_south || moving_east || moving_west || \
		       queued_north || queued_south || queued_east || queued_west

	proc/AnyDirectionHeld()
		/**
		 * Check if player is actively holding any direction
		 */
		return moving_north || moving_south || moving_east || moving_west

	proc/SetDirection(direction, active)
		/**
		 * Set a directional input (NORTH, SOUTH, EAST, WEST)
		 * Example: state.SetDirection(NORTH, TRUE)
		 */
		switch(direction)
			if(NORTH)
				moving_north = active
			if(SOUTH)
				moving_south = active
			if(EAST)
				moving_east = active
			if(WEST)
				moving_west = active

	proc/GetActiveDirection()
		/**
		 * Get primary active direction (with diagonal preference)
		 * Returns: NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, etc. or 0
		 */
		var/primary_ns = moving_north ? NORTH : (moving_south ? SOUTH : 0)
		var/primary_ew = moving_east ? EAST : (moving_west ? WEST : 0)
		
		if(primary_ns && primary_ew)
			// Diagonal movement - return diagonal direction
			if(primary_ns == NORTH && primary_ew == EAST)
				return NORTHEAST
			else if(primary_ns == NORTH && primary_ew == WEST)
				return NORTHWEST
			else if(primary_ns == SOUTH && primary_ew == EAST)
				return SOUTHEAST
			else if(primary_ns == SOUTH && primary_ew == WEST)
				return SOUTHWEST
		
		return primary_ns || primary_ew

	proc/SetSprinting(value)
		/**
		 * Enable/disable sprint mode
		 * Cleaner than: src.Sprinting = value
		 */
		is_sprinting = value ? TRUE : FALSE

	proc/GetMovementDelayDeciseconds()
		/**
		 * Calculate movement delay based on sprint/stamina state
		 * Returns delay in deciseconds (20ths of a second)
		 * 
		 * Default: 3 deciseconds per step
		 * Sprinting: 1 decisecond per step (3x faster)
		 * Low stamina: 5 deciseconds per step (slower)
		 */
		if(is_sprinting)
			return max(1, movement_speed / 3)
		
		return max(1, movement_speed)

// ============================================================================
// PLAYER MODERNIZATION HOOK
// ============================================================================

mob/var
	datum/movement_state/movement_state = null

/**
 * Initialize movement state for a player
 * Call in Login() or when creating character
 */
proc/InitializeMovementState(mob/M)
	if(!M.movement_state)
		M.movement_state = new(M)

/**
 * Optional modern movement proc (can coexist with old MovementLoop)
 */
mob/proc/ModernMovementLoop()
	/**
	 * Alternative implementation using movement_state
	 * This is provided as a reference/upgrade path
	 * Current system still uses legacy MovementLoop
	 */
	if(!movement_state)
		movement_state = new(src)
	
	walk(src, 0)
	if(movement_state.is_moving) return
	movement_state.is_moving = TRUE
	
	var/first_step = TRUE
	
	while(movement_state.AnyDirectionActive())
		var/direction = movement_state.GetActiveDirection()
		
		if(direction)
			step(src, direction)
			movement_state.last_move_direction = direction
			movement_state.last_move_time = world.time
		
		movement_state.ClearAllQueued()
		
		// Invalidate permission cache on movement
		InvalidateDeedPermissionCache(src)
		
		if(first_step)
			sleep(1)
			first_step = FALSE
		
		sleep(movement_state.GetMovementDelayDeciseconds())
	
	movement_state.is_moving = FALSE

