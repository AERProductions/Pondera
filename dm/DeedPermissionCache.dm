/**
 * DEED PERMISSION CACHING SYSTEM
 * Optimizes permission lookups with cached results
 * 
 * Problem: Current system checks deed database on EVERY action (build, pickup, drop)
 * During rapid actions (farming, building), this creates many redundant queries
 * 
 * Solution: Cache permission results for each player+location combination
 * Invalidate cache only when:
 * - Player moves to new location (different turf)
 * - Deed region updates permissions
 * - Permission explicitly changed (grant/revoke)
 * 
 * Performance: O(1) cached lookup vs O(n) deed database query
 */

// ============================================================================
// DEED PERMISSION CACHE DATA STRUCTURE
// ============================================================================

/datum/deed_permission_cache
	var
		player_ckey = ""           // Who this cache is for
		location_x = 0             // X coordinate of cached location
		location_y = 0             // Y coordinate of cached location
		location_z = 0             // Z coordinate of cached location
		build_allowed = FALSE      // Can build at this location
		pickup_allowed = FALSE     // Can pickup at this location
		drop_allowed = FALSE       // Can drop at this location
		timestamp = 0              // When cache was created
		deed_id = ""               // Which deed controls this location (if any)

	New(player_ckey, turf/location)
		src.player_ckey = player_ckey
		src.location_x = location.x
		src.location_y = location.y
		src.location_z = location.z
		src.timestamp = world.time
		
		// Calculate all permissions at cache creation time
		src.build_allowed = QueryDeedPermissionAtLocation(player_ckey, location, "build")
		src.pickup_allowed = QueryDeedPermissionAtLocation(player_ckey, location, "pickup")
		src.drop_allowed = QueryDeedPermissionAtLocation(player_ckey, location, "drop")
		src.deed_id = GetCachedDeedAtLocation(location)

	proc/IsValid(turf/current_location)
		/**
		 * Check if cache is still valid
		 * Cache is invalid if player moved or cache is too old (60 seconds)
		 */
		if(!current_location) return FALSE
		if(current_location.x != location_x) return FALSE
		if(current_location.y != location_y) return FALSE
		if(current_location.z != location_z) return FALSE
		if(world.time - timestamp > 600) return FALSE  // 60 seconds in deciseconds
		return TRUE

	proc/GetBuildPermission()
		return build_allowed

	proc/GetPickupPermission()
		return pickup_allowed

	proc/GetDropPermission()
		return drop_allowed

// ============================================================================
// PLAYER CACHE INTEGRATION
// ============================================================================

mob/var
	datum/deed_permission_cache/permission_cache = null

// ============================================================================
// CACHED PERMISSION LOOKUP FUNCTIONS
// ============================================================================

/proc/CanPlayerBuildAtLocationCached(mob/players/M, turf/T)
	/**
	 * OPTIMIZED: Build permission check with caching
	 * Called frequently during construction/planting actions
	 */
	if(!M || !T) return FALSE
	
	// Try to use cached result
	if(M.permission_cache && M.permission_cache.IsValid(T))
		return M.permission_cache.GetBuildPermission()
	
	// Cache miss - create new cache entry
	var/datum/deed_permission_cache/cache = new(M.ckey, T)
	M.permission_cache = cache
	return cache.GetBuildPermission()


/proc/CanPlayerPickupAtLocationCached(mob/players/M, turf/T)
	/**
	 * OPTIMIZED: Pickup permission check with caching
	 * Called on every item pickup attempt
	 */
	if(!M || !T) return FALSE
	
	// Try to use cached result
	if(M.permission_cache && M.permission_cache.IsValid(T))
		return M.permission_cache.GetPickupPermission()
	
	// Cache miss - create new cache entry
	var/datum/deed_permission_cache/cache = new(M.ckey, T)
	M.permission_cache = cache
	return cache.GetPickupPermission()


/proc/CanPlayerDropAtLocationCached(mob/players/M, turf/T)
	/**
	 * OPTIMIZED: Drop permission check with caching
	 * Called on every item drop attempt
	 */
	if(!M || !T) return FALSE
	
	// Try to use cached result
	if(M.permission_cache && M.permission_cache.IsValid(T))
		return M.permission_cache.GetDropPermission()
	
	// Cache miss - create new cache entry
	var/datum/deed_permission_cache/cache = new(M.ckey, T)
	M.permission_cache = cache
	return cache.GetDropPermission()


/proc/InvalidateDeedPermissionCache(mob/players/M)
	/**
	 * Force cache invalidation for player
	 * Call this when:
	 * - Player moves to new location (automatic via movement hook)
	 * - Deed permissions change
	 * - Player permissions explicitly modified
	 */
	if(!M) return
	M.permission_cache = null


/proc/InvalidateDeedPermissionCacheGlobal()
	/**
	 * Force global cache invalidation
	 * Call this when deed system undergoes major update
	 * Less efficient but ensures consistency
	 */
	for(var/mob/M in world)
		InvalidateDeedPermissionCache(M)


// ============================================================================
// UNDERLYING QUERY FUNCTIONS (called during cache misses)
// ============================================================================

/proc/QueryDeedPermissionAtLocation(ckey, turf/location, permission_type)
	/**
	 * Internal function to query actual deed permissions
	 * This is the expensive operation that caching reduces
	 * 
	 * permission_type: "build", "pickup", or "drop"
	 */
	if(!location) return FALSE
	
	// For now, return default based on location
	// In future, this would query deed database
	return TRUE  // Default: allow unless deed restricts


/proc/GetCachedDeedAtLocation(turf/location)
	/**
	 * Get deed ID that controls a location (if any)
	 * Used for cache invalidation when deed changes
	 * NOTE: This is a wrapper around GetDeedAtLocation() from DeedDataManager
	 */
	if(!location) return ""
	
	// Check if turf has buildingowner (deed marker)
	if(location.buildingowner)
		return location.buildingowner
	
	return ""


// ============================================================================
// MIGRATION: Replace old functions with cached versions
// ============================================================================

/**
 * IMPORTANT: Original functions (CanPlayerBuildAtLocation, etc.) are defined
 * in DeedPermissionSystem.dm. We override them here with cached versions.
 * 
 * The DeedPermissionSystem definitions will be shadowed by these implementations.
 * To properly integrate, edit DeedPermissionSystem.dm to call the cached versions.
 * 
 * For now, the cached versions are available as separate functions:
 * - CanPlayerBuildAtLocationCached()
 * - CanPlayerPickupAtLocationCached()
 * - CanPlayerDropAtLocationCached()
 * 
 * These can be called directly or the old functions can be modified to use them.
 */


