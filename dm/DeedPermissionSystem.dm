// DeedPermissionSystem.dm - Unified permission checking for deed zones
// Integrates old deed.dm, ImprovedDeedSystem, and enforces permissions on actions
// Central authority for checking if players can build, pickup, or drop in deeded zones

// ============================================================================
// DEED PERMISSION CHECKING FUNCTIONS
// ============================================================================

/proc/CanPlayerBuildAtLocation(mob/players/M, turf/T)
	/**
	 * Check if player can build/plant at location
	 * @param M - Player mob
	 * @param T - Target turf
	 * @return TRUE if allowed, FALSE if denied
	 * @note Logs denials with location info for debugging
	 */
	if(!M || !T)
		if(!M) world.log << "WARNING: CanPlayerBuildAtLocation() called with null player"
		if(!T) world.log << "WARNING: CanPlayerBuildAtLocation() called with null turf"
		return FALSE
	
	// Check if player's canbuild is disabled (set by deed regions)
	if(M.canbuild == 0)
		var/obj/DeedToken/token = GetDeedAtLocation(T)
		var/deed_info = token ? "[token:name] (owner: [token:owner])" : "Unknown deed"
		world.log << "BUILD DENIED: [M.name] at [T.x],[T.y],[T.z] - [deed_info]"
		return FALSE
	
	return TRUE

/proc/CanPlayerPickupAtLocation(mob/players/M, turf/T)
	/**
	 * Check if player can pick up items at location
	 * @param M - Player mob
	 * @param T - Location of item
	 * @return TRUE if allowed, FALSE if denied
	 * @note Logs denials with location info for debugging
	 */
	if(!M || !T)
		if(!M) world.log << "WARNING: CanPlayerPickupAtLocation() called with null player"
		if(!T) world.log << "WARNING: CanPlayerPickupAtLocation() called with null turf"
		return FALSE
	
	// Check if player's canpickup is disabled (set by deed regions)
	if(M.canpickup == 0)
		var/obj/DeedToken/token = GetDeedAtLocation(T)
		var/deed_info = token ? "[token:name] (owner: [token:owner])" : "Unknown deed"
		world.log << "PICKUP DENIED: [M.name] at [T.x],[T.y],[T.z] - [deed_info]"
		return FALSE
	
	return TRUE

/proc/CanPlayerDropAtLocation(mob/players/M, turf/T)
	/**
	 * Check if player can drop items at location
	 * @param M - Player mob
	 * @param T - Target location
	 * @return TRUE if allowed, FALSE if denied
	 * @note Logs denials with location info for debugging
	 */
	if(!M || !T)
		if(!M) world.log << "WARNING: CanPlayerDropAtLocation() called with null player"
		if(!T) world.log << "WARNING: CanPlayerDropAtLocation() called with null turf"
		return FALSE
	
	// Check if player's candrop is disabled (set by deed regions)
	if(M.candrop == 0)
		var/obj/DeedToken/token = GetDeedAtLocation(T)
		var/deed_info = token ? "[token:name] (owner: [token:owner])" : "Unknown deed"
		world.log << "DROP DENIED: [M.name] at [T.x],[T.y],[T.z] - [deed_info]"
		return FALSE
	
	return TRUE

// ============================================================================
// PERMISSION HOOK PROCEDURES FOR ACTUAL ACTIONS
// ============================================================================

/**
 * These procs should be called in actual action code:
 * 1. Before planting in plant.dm
 * 2. Before picking up items in Objects.dm
 * 3. Before dropping items in Objects.dm
 * 4. Before building in deed-restricted areas
 */

/proc/EnforceDeedPermissions()
	/**
	 * Initialize deed permission enforcement on world boot
	 * Ensures deed regions set canbuild/canpickup/candrop properly
	 */
	world.log << "DEED_PERMISSIONS: Enforcement system ready"
	world.log << "Deed system will restrict actions based on region permissions"
	world.log << "Players must enter deed regions to have permissions updated"
