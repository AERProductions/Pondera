// DeedDataManager.dm - Centralized deed object access and data API
// Provides unified interface for deed operations, ownership, permissions, and queries
// Dependencies: deed.dm, DeedPermissionSystem.dm
// Integrates with: obj/DeedToken, region/deed

/**
 * ============================================================================
 * DEED DATA MANAGER SYSTEM
 * ============================================================================
 * 
 * Purpose:
 *   Centralize all deed data access and manipulation through a single API.
 *   Eliminate scattered deed queries and enable future features (transfer,
 *   rental, sale, mortgaging, etc.).
 *
 * Architecture:
 *   - GetDeedAtLocation() - Retrieve deed token at turf
 *   - GetDeedsByOwner() - Get all deeds owned by player
 *   - GetDeedByName() - Find deed by name
 *   - IsOwnerOfDeed() - Ownership validation
 *   - HasDeedPermission() - Permission state checking
 *   - TransferDeedOwnership() - Change owner (for Phase 3+ features)
 *   - UpdateDeedName() - Rename deed
 *   - ManageDeedAllowList() - Grant/revoke permissions
 *
 * Integration Points:
 *   - DeedToken: obj/DeedToken/{owner, deedallow, deedname, deedowner}
 *   - DeedRegion: region/deed/{deedallow, deedowner, deedname}
 *   - Player vars: {canbuild, canpickup, candrop, permallow}
 *   - Deed scroll: obj/Deed/{deedused}
 *
 * Future Features Enabled:
 *   Phase 3: Transfer ownership, rentals, market sales
 *   Phase 4: Mortgaging, taxation, deed evolution
 *   Phase 5: Deed alliances, shared control, inheritance
 */

// ============================================================================
// GLOBAL DEED DATABASE
// ============================================================================

var
	list/g_deed_registry = list()      // All active deed tokens
	list/g_deed_owner_map = list()     // Indexed by owner ckey
	g_deed_manager_initialized = FALSE // Track if manager has been initialized

// ============================================================================
// DEED REGISTRY MANAGEMENT
// ============================================================================

/**
 * Register a new deed token when it's created
 * Called from obj/DeedToken/New()
 */
/proc/RegisterDeedToken(obj/DeedToken/token)
	if(!token) return FALSE
	
	var/owner_ckey = ckey(token:deedowner["owner"])
	if(!owner_ckey) return FALSE
	
	// Create unique key for this deed
	var/deed_key = "[owner_ckey]_[token:name]_[world.time]"
	
	// Add to global registry
	g_deed_registry[deed_key] = token
	
	// Add to owner index
	if(!g_deed_owner_map[owner_ckey])
		g_deed_owner_map[owner_ckey] = list()
	g_deed_owner_map[owner_ckey] += token
	
	return TRUE

/**
 * Unregister deed when destroyed or transferred
 */
/proc/UnregisterDeedToken(obj/DeedToken/token)
	if(!token) return FALSE
	
	var/owner_ckey = ckey(token:deedowner["owner"])
	if(owner_ckey && g_deed_owner_map[owner_ckey])
		g_deed_owner_map[owner_ckey] -= token
		if(!g_deed_owner_map[owner_ckey].len)
			g_deed_owner_map -= owner_ckey
	
	// Remove from registry
	for(var/key in g_deed_registry)
		if(g_deed_registry[key] == token)
			g_deed_registry -= key
			break
	
	return TRUE

// ============================================================================
// DEED QUERYING FUNCTIONS
// ============================================================================

/**
 * Get the DeedToken object at a specific location
 * @param T - Target turf (or uses usr.loc if not specified)
 * @return DeedToken object or NULL if no deed at location
 */
/proc/GetDeedAtLocation(turf/T)
	if(!T) return null
	
	// Check for deed token in oview
	var/obj/DeedToken/token = locate() in oview(10, T)
	if(token)
		return token
	
	// Alternative: Check for deed region
	var/region/deed/D = locate() in obounds(10, T)
	if(D && D:dt)
		return D:dt
	
	return null

/**
 * Get all deeds owned by a player
 * @param player_ckey - Player's ckey (or uses usr if not specified)
 * @return List of DeedToken objects owned by player
 */
/proc/GetDeedsByOwner(player_ckey)
	if(!player_ckey) player_ckey = ckey(usr.key)
	if(!player_ckey) return list()
	
	var/list/deeds = g_deed_owner_map[player_ckey] || list()
	return deeds.Copy()

/**
 * Find a specific deed by name and owner
 * @param deed_name - Name of deed
 * @param owner_ckey - Owner's ckey (optional)
 * @return DeedToken object or null
 */
/proc/GetDeedByName(deed_name, owner_ckey)
	if(!deed_name) return null
	
	if(owner_ckey)
		// Search within specific owner's deeds
		var/list/owner_deeds = g_deed_owner_map[owner_ckey] || list()
		for(var/obj/DeedToken/T in owner_deeds)
			if(T:name == deed_name)
				return T
	else
		// Search all deeds
		for(var/obj/DeedToken/T in g_deed_registry)
			if(T:name == deed_name)
				return T
	
	return null

/**
 * Count total deeds owned by player
 * @param player_ckey - Player's ckey
 * @return Number of deeds owned
 */
/proc/CountDeedsOwnedBy(player_ckey)
	if(!player_ckey) return 0
	var/list/deeds = g_deed_owner_map[player_ckey] || list()
	return deeds.len

/**
 * Get total land area claimed by player (in turfs)
 * Calculated as zone_size * zone_size for each deed
 * @param player_ckey - Player's ckey
 * @return Total turfs claimed
 */
/proc/GetTotalLandAreaFor(player_ckey)
	if(!player_ckey) return 0
	
	var/total_area = 0
	var/list/deeds = g_deed_owner_map[player_ckey] || list()
	
	for(var/obj/DeedToken/token in deeds)
		// Deed zone is zonex * zone (default 10x10 = 100 turfs)
		var/zone_size = token:zonex * token:zone  // zonex and zone both = 10
		total_area += zone_size
	
	return total_area

// ============================================================================
// DEED OWNERSHIP & PERMISSION QUERIES
// ============================================================================

/**
 * Check if player owns a specific deed
 * @param player_ckey - Player's ckey
 * @param token - DeedToken to check
 * @return TRUE if player owns deed, FALSE otherwise
 */
/proc/IsOwnerOfDeed(player_ckey, obj/DeedToken/token)
	if(!player_ckey || !token) return FALSE
	
	var/deed_owner = token:deedowner["owner"]
	return ckey(deed_owner) == player_ckey

/**
 * Check if player has specific permission in a deed
 * @param player_ckey - Player's ckey
 * @param token - DeedToken to check
 * @param permission - "build", "pickup", or "drop"
 * @return TRUE if permission granted, FALSE otherwise
 */
/proc/HasDeedPermission(player_ckey, obj/DeedToken/token, permission)
	if(!player_ckey || !token) return FALSE
	
	// Owner always has all permissions
	if(IsOwnerOfDeed(player_ckey, token))
		return TRUE
	
	// Check if player is in allow list
	if(!token:deedallow.Find(player_ckey))
		return FALSE
	
	// All permissions granted if on allow list
	return TRUE

/**
 * Get list of all players with permissions in a deed
 * @param token - DeedToken to query
 * @return List of player ckeys with permissions
 */
/proc/GetDeedPermittedPlayers(obj/DeedToken/token)
	if(!token) return list()
	return token:deedallow.Copy()

/**
 * Check if a player is on the deed's allow list
 * @param player_ckey - Player's ckey
 * @param token - DeedToken to check
 * @return TRUE if on allow list, FALSE otherwise
 */
/proc/IsPlayerOnDeedAllowList(player_ckey, obj/DeedToken/token)
	if(!player_ckey || !token) return FALSE
	return token:deedallow.Find(player_ckey) ? TRUE : FALSE

// ============================================================================
// DEED DATA MODIFICATION
// ============================================================================

/**
 * Rename a deed
 * @param token - DeedToken to rename
 * @param new_name - New deed name
 * @param requester_ckey - Player requesting rename (must be owner)
 * @return TRUE if successful, FALSE if denied
 */
/proc/RenameDeed(obj/DeedToken/token, new_name, requester_ckey)
	if(!token || !new_name || !requester_ckey) return FALSE
	
	// Validate requester is owner
	if(!IsOwnerOfDeed(requester_ckey, token))
		return FALSE
	
	// Update token
	token:name = new_name
	
	// Update deedname list
	del token:deedname
	token:deedname = list()
	token:deedname["name"] = new_name
	
	// Update associated region
	var/region/deed/D = locate() in obounds(10, token)
	if(D)
		D:name = new_name
		D:deedname = token:deedname
	
	return TRUE

/**
 * Transfer deed ownership to another player
 * @param token - DeedToken to transfer
 * @param new_owner_ckey - New owner's ckey
 * @param requester_ckey - Current owner (must match)
 * @return TRUE if successful, FALSE if denied
 * 
 * Note: Enables Phase 3+ feature (deed sales, transfers)
 */
/proc/TransferDeedOwnership(obj/DeedToken/token, new_owner_ckey, requester_ckey)
	if(!token || !new_owner_ckey || !requester_ckey) return FALSE
	
	// Validate requester is current owner
	if(!IsOwnerOfDeed(requester_ckey, token))
		return FALSE
	
	// Unregister from old owner's map
	UnregisterDeedToken(token)
	
	// Update ownership data
	token:owner = new_owner_ckey
	token:deedowner = list()
	token:deedowner["owner"] = new_owner_ckey
	
	// Clear old owner from allow list and add new owner
	token:deedallow -= requester_ckey
	token:deedallow.Add(ckey(new_owner_ckey))
	
	// Re-register with new owner
	RegisterDeedToken(token)
	
	// Update associated region
	var/region/deed/D = locate() in obounds(10, token)
	if(D)
		D:deedowner = token:deedowner
		D:deedallow = token:deedallow
	
	return TRUE

/**
 * Grant permission to a player on a deed
 * @param player_ckey - Player to grant permission to
 * @param token - DeedToken
 * @param requester_ckey - Deed owner (must match)
 * @return TRUE if successful, FALSE if denied
 */
/proc/GrantDeedPermission(player_ckey, obj/DeedToken/token, requester_ckey)
	if(!player_ckey || !token || !requester_ckey) return FALSE
	
	// Validate requester is owner
	if(!IsOwnerOfDeed(requester_ckey, token))
		return FALSE
	
	// Add to allow list
	if(!token:deedallow.Find(player_ckey))
		token:deedallow.Add(player_ckey)
	
	// Update associated region
	var/region/deed/D = locate() in obounds(10, token)
	if(D)
		D:deedallow = token:deedallow
	
	return TRUE

/**
 * Revoke permission from a player on a deed
 * @param player_ckey - Player to revoke permission from
 * @param token - DeedToken
 * @param requester_ckey - Deed owner (must match)
 * @return TRUE if successful, FALSE if denied
 */
/proc/RevokeDeedPermission(player_ckey, obj/DeedToken/token, requester_ckey)
	if(!player_ckey || !token || !requester_ckey) return FALSE
	
	// Validate requester is owner
	if(!IsOwnerOfDeed(requester_ckey, token))
		return FALSE
	
	// Remove from allow list
	if(token:deedallow.Find(player_ckey))
		token:deedallow.Remove(player_ckey)
	
	// Update associated region
	var/region/deed/D = locate() in obounds(10, token)
	if(D)
		D:deedallow = token:deedallow
	
	return TRUE

// ============================================================================
// DEED AREA & ZONE MANAGEMENT
// ============================================================================

/**
 * Expand a deed zone (foundation for Phase 3+ features)
 * @param token - DeedToken to expand
 * @param new_size - New zone size
 * @param requester_ckey - Owner (must match)
 * @return TRUE if successful, FALSE if denied
 */
/proc/ExpandDeedZone(obj/DeedToken/token, new_size, requester_ckey)
	if(!token || !new_size || !requester_ckey) return FALSE
	
	// Validate requester is owner
	if(!IsOwnerOfDeed(requester_ckey, token))
		return FALSE
	
	// Validate new size is larger
	if(new_size <= token:zonex)
		return FALSE
	
	// Update zone size
	var/old_size = token:zonex
	token:zonex = new_size
	token:zone = new_size
	
	// Re-create deed region with new bounds
	UpdateDeedRegionBounds(token, old_size, new_size)
	
	return TRUE

/**
 * Update deed region bounds when zone size changes
 * @param token - DeedToken
 * @param old_size - Previous zone size
 * @param new_size - New zone size
 */
/proc/UpdateDeedRegionBounds(obj/DeedToken/token, old_size, new_size)
	if(!token || !token:x || !token:y || !token:z)
		return
	
	// Find deed name for region
	var/deed_name = token:deedname || "Unnamed"
	
	// All turfs in new zone get blocked
	var/turf/center = locate(token:x, token:y, token:z)
	if(!center)
		world.log << "\[DEED\] WARNING: UpdateDeedRegionBounds() - Cannot locate center turf at ([token:x],[token:y],[token:z])"
		return
	
	// Mark all turfs in new zone with deed ownership
	for(var/turf/T in block(
		locate(token:x - new_size, token:y - new_size, token:z),
		locate(token:x + new_size, token:y + new_size, token:z)
	))
		if(T)
			T:buildingowner = deed_name  // Mark turf as deeded
	
	world.log << "\[DEED\] Updated zone bounds for '[deed_name]': [old_size] → [new_size]"

/**
 * Get all turfs in a deed's zone
 * @param token - DeedToken
 * @return List of all turfs in zone (or empty list if invalid)
 */
/proc/GetDeedZoneTurfs(obj/DeedToken/token)
	if(!token) 
		return list()
	
	// Validate token position
	if(!token:x || !token:y || !token:z)
		world.log << "WARNING: GetDeedZoneTurfs() called on deed with invalid position"
		return list()
	
	var/list/zone_turfs = list()
	var/token_x = token:x
	var/token_y = token:y
	var/token_z = token:z
	var/zone_size = token:zonex
	
	// Bounds checking - prevent accessing invalid coordinates
	var/start_x = max(1, token_x - zone_size/2)
	var/start_y = max(1, token_y - zone_size/2)
	var/end_x = min(world.maxx, token_x + zone_size/2)
	var/end_y = min(world.maxy, token_y + zone_size/2)
	
	// Safety: bounds shouldn't be inverted
	if(start_x > end_x || start_y > end_y)
		world.log << "WARNING: GetDeedZoneTurfs() bounds inverted for deed [token:name]"
		return list()
	
	for(var/x in start_x to end_x)
		for(var/y in start_y to end_y)
			var/turf/T = locate(x, y, token_z)
			if(T) // Only add valid turfs
				zone_turfs += T
	
	return zone_turfs

// ============================================================================
// INITIALIZATION & CLEANUP
// ============================================================================

/**
 * Lazy initialize DeedDataManager - only initializes if deeds exist
 * Called from InitializationManager.dm - Phase 2B
 * If no deeds exist, does nothing (defers to on-demand initialization)
 */
/proc/InitializeDeedDataManagerLazy()
	world.log << "\[INIT\] DeedDataManager: Checking for existing deeds..."
	
	// Quick scan - only count existing deed tokens
	var/deed_count = 0
	var/obj/DeedToken_Zone/token
	
	for(token in world)
		if(!token) continue
		if(istype(token, /obj/DeedToken_Zone))
			deed_count++
	
	// If deeds exist, initialize registry
	if(deed_count > 0)
		world.log << "\[INIT\] DeedDataManager: Found [deed_count] existing deeds - initializing registry"
		InitializeDeedDataManager()
		return TRUE
	else
		// No deeds exist - defer initialization until first deed is created
		world.log << "\[INIT\] DeedDataManager: No deeds found - lazy initialization deferred"
		world.log << "\[INIT\] DeedDataManager: Registry will initialize on first deed creation"
		g_deed_manager_initialized = FALSE
		return FALSE

/**
 * On-demand initialization when first deed is created
 * Called from obj/DeedToken/New() if manager not yet initialized
 * Ensures registry is ready before deed is registered
 */
/proc/EnsureDeedManagerInitialized()
	if(g_deed_manager_initialized)
		return  // Already initialized
	
	if(!g_deed_registry)
		g_deed_registry = list()
	if(!g_deed_owner_map)
		g_deed_owner_map = list()
	
	world.log << "\[INIT\] DeedDataManager: On-demand initialization triggered by first deed"
	g_deed_manager_initialized = TRUE

/**
 * Initialize DeedDataManager on world startup
 * Called from InitializationManager.dm - Phase 2B (if deeds exist)
 * OR called on-demand when first deed is created
 * Scans for all existing deed tokens and registers them
 */
/proc/InitializeDeedDataManager()
	world.log << "\[INIT\] DeedDataManager: Initializing deed registry..."
	
	if(!g_deed_registry)
		g_deed_registry = list()
	if(!g_deed_owner_map)
		g_deed_owner_map = list()
	
	// Clear and rebuild from existing objects
	g_deed_registry = list()
	g_deed_owner_map = list()
	
	var/deed_count = 0
	var/obj/DeedToken/token
	
	// Iterate all objects in world (deed tokens persisted by BYOND savefile system)
	for(token in world)
		if(!token) continue  // Safety check for null references
		
		if(istype(token, /obj/DeedToken))
			// Validate deed data integrity
			if(!token:deedowner || !token:deedowner["owner"])
				world.log << "\[INIT\] WARNING: DeedToken at ([token.x],[token.y],[token.z]) has invalid owner data"
				continue
			
			// Attempt to register
			if(RegisterDeedToken(token))
				deed_count++
	
	world.log << "\[INIT\] DeedDataManager: Registered [deed_count] deed tokens"
	world.log << "\[INIT\] DeedDataManager: Registry initialized and validated"
	g_deed_manager_initialized = TRUE
	
	return deed_count > 0

/**
 * Save deed registry to persistent storage
 * Ensures deed data survives world reboots
 * Called from TimeSave() in dm/TimeSave.dm
 */
/proc/SaveDeedRegistry()
	var/savefile/F = new("deeds.sav")
	if(!F)
		world.log << "\[DEED\] ERROR: Failed to open deeds.sav for writing"
		return FALSE
	
	// Serialize global deed registry
	F["g_deed_registry"] << g_deed_registry
	F["g_deed_owner_map"] << g_deed_owner_map
	
	world.log << "\[DEED\] Saved [g_deed_registry.len] deeds to persistent storage"
	return TRUE

/**
 * Load deed registry from persistent storage
 * Called from TimeLoad() in dm/TimeSave.dm (after deed tokens loaded)
 */
/proc/LoadDeedRegistry()
	if(!fexists("deeds.sav"))
		world.log << "\[DEED\] No prior deed data found - starting fresh"
		return TRUE
	
	var/savefile/F = new("deeds.sav")
	if(!F)
		world.log << "\[DEED\] ERROR: Failed to open deeds.sav for reading"
		return FALSE
	
	// Deserialize global deed registry
	F["g_deed_registry"] >> g_deed_registry
	F["g_deed_owner_map"] >> g_deed_owner_map
	
	if(!g_deed_registry) g_deed_registry = list()
	if(!g_deed_owner_map) g_deed_owner_map = list()
	
	world.log << "\[DEED\] Restored [g_deed_registry.len] deeds from persistent storage"
	return TRUE
