/**
 * LOGOUT HANDLER SYSTEM
 * Centralized, properly-structured player logout and cleanup
 * 
 * Purpose: Refactor scattered manual cleanup code into organized subsystems
 * Previously: Manual bitflag resets, ad-hoc sound cleanup, party management
 * Now: Proper cleanup routines with defensive error handling
 * 
 * Integrated with: mob/players/Logout() in Basics.dm
 */

/**
 * CleanupPlayerSession(mob/players/M)
 * 
 * Master cleanup orchestrator for player disconnect.
 * Called from mob/players/Logout() as central entry point.
 * Executes all logout phases in proper order.
 * 
 * Returns: TRUE if all cleanups successful, FALSE if any errors occurred
 */
proc/CleanupPlayerSession(mob/players/M)
	if(!M)
		world.log << "\[LOGOUT\] WARNING: CleanupPlayerSession called with null mob"
		return FALSE
	
	world.log << "\[LOGOUT\] Starting cleanup for [M.name] ([M.ckey])"
	
	var/cleanup_status = TRUE
	
	// PHASE 1: Clear session state
	if(!CleanupActivityFlags(M))
		cleanup_status = FALSE
	
	// PHASE 2: UI/Browser cleanup
	if(!CleanupBrowserUI(M))
		cleanup_status = FALSE
	
	// PHASE 3: Party system cleanup
	if(!CleanupPartyMembership(M))
		cleanup_status = FALSE
	
	// PHASE 4: Sound system cleanup
	if(!CleanupSoundSystems(M))
		cleanup_status = FALSE
	
	// PHASE 5: Crash recovery marking
	if(!MarkPlayerOffline(M))
		cleanup_status = FALSE
	
	// Final logging
	if(cleanup_status)
		world.log << "\[LOGOUT\] ✓ Cleanup complete for [M.name]"
	else
		world.log << "\[LOGOUT\] ⚠️  WARNING: [M.name] had errors during cleanup - check log above"
	
	return cleanup_status

/**
 * CleanupActivityFlags(mob/players/M)
 * 
 * Reset all activity flags that indicate player is doing something.
 * Prevents stuck states where player appears to be gathering/building/fighting
 * after they've logged out.
 * 
 * Flags reset:
 * - Doing: Generic activity flag
 * - Carving: Carving items from terrain (poles, torch heads)
 * - Cutting: Cutting sprouts
 * - Picking: Harvesting fruits/vegetables
 * - Mining: Mining ores
 * - cooking: Crafting food items
 * - growing: Farming/gardening activity
 * 
 * Returns: TRUE if successful, FALSE if errors
 */
proc/CleanupActivityFlags(mob/players/M)
	if(!M) return FALSE
	
	try
		// Check if any flags are active
		var/flags_active = FALSE
		if(M.Doing || M.Carving || M.Cutting || M.Picking || M.Mining || M.cooking || M.growing)
			flags_active = TRUE
			world.log << "\[LOGOUT\] Resetting active flags for [M.name]"
		
		// Reset all activity flags to safe state
		M.Doing = 0
		M.Carving = 0
		M.Cutting = 0
		M.Picking = 0
		M.Mining = 0
		M.cooking = 0
		M.growing = 0
		
		// Verify reset was successful
		if(M.Doing || M.Carving || M.Cutting || M.Picking || M.Mining)
			world.log << "\[LOGOUT\] ERROR: Activity flags not fully reset"
			return FALSE
		
		if(flags_active)
			world.log << "\[LOGOUT\] ✓ Activity flags reset"
		
		return TRUE
	
	catch(var/exception/e)
		world.log << "\[LOGOUT\] ERROR resetting activity flags: [e]"
		return FALSE

/**
 * CleanupBrowserUI(mob/players/M)
 * 
 * Close all open browser windows and UI dialogs.
 * Prevents phantom windows from reappearing on next login.
 * 
 * Returns: TRUE if successful, FALSE on error
 */
proc/CleanupBrowserUI(mob/players/M)
	if(!M) return FALSE
	
	try
		// Close all open browser windows
		if(M)
			M << browse(null)  // mob sends null to client to close all browse() windows
		
		// Reset any UI state flags
		if(M.browse_once)
			M.browse_once = 0
		
		world.log << "\[LOGOUT\] ✓ Browser UI closed"
		return TRUE
	
	catch(var/exception/e)
		world.log << "\[LOGOUT\] ERROR closing browser UI: [e]"
		return FALSE

/**
 * CleanupPartyMembership(mob/players/M)
 * 
 * Remove player from party, notify party members.
 * Clean and safe removal without leaving party in inconsistent state.
 * 
 * Returns: TRUE if successful, FALSE on error
 */
proc/CleanupPartyMembership(mob/players/M)
	if(!M) return FALSE
	
	try
		// Only cleanup if player is actually in a party
		if(M.inparty)
			world.log << "\[LOGOUT\] Removing [M.name] from party [M.partynumber]"
			M.leaveparty(M)  // Call leaveparty on the mob
			
			// Verify removal
			if(!M.inparty && M.partynumber == 0)
				world.log << "\[LOGOUT\] ✓ Party membership cleaned"
			else
				world.log << "\[LOGOUT\] WARNING: Party cleanup incomplete (inparty=[M.inparty], partynumber=[M.partynumber])"
				return FALSE
		
		return TRUE
	
	catch(var/exception/e)
		world.log << "\[LOGOUT\] ERROR cleaning party membership: [e]"
		return FALSE

/**
 * CleanupSoundSystems(mob/players/M)
 * 
 * Properly disconnect player from all sound systems.
 * Prevents phantom sound mob references and memory leaks.
 * 
 * Two subsystems:
 * 1. _listening_soundmobs: Sound mobs this player is listening to
 * 2. _attached_soundmobs: Sound mobs attached to this player
 * 
 * Returns: TRUE if successful, FALSE on error
 */
proc/CleanupSoundSystems(mob/players/M)
	if(!M) return FALSE
	
	try
		var/listening_count = 0
		var/attached_count = 0
		
		// SUBSYSTEM 1: Disconnect from listening sound mobs
		if(M._listening_soundmobs && M._listening_soundmobs.len > 0)
			listening_count = M._listening_soundmobs.len
			
			for(var/soundmob/soundmob in M._listening_soundmobs)
				if(!soundmob) continue  // Skip null references
				
				// Remove player from this soundmob's listener list
				if(M in soundmob.listeners)
					soundmob.listeners -= M
		
		// SUBSYSTEM 2: Disconnect from attached sound mobs
		if(M._attached_soundmobs && M._attached_soundmobs.len > 0)
			attached_count = M._attached_soundmobs.len
			
			for(var/soundmob/soundmob in M._attached_soundmobs)
				if(!soundmob) continue  // Skip null references
				
				// Remove this player from all listeners of attached soundmobs
				for(var/mob/players/X in soundmob.listeners)
					if(X && X._listening_soundmobs)
						X._listening_soundmobs -= soundmob
				
				// Clear this soundmob's listener list
				soundmob.listeners = new
		
		// SUBSYSTEM 3: Clear player's sound system references
		M._attached_soundmobs = new
		M._listening_soundmobs = new
		
		// Verify cleanup
		if(!M._listening_soundmobs || !M._attached_soundmobs)
			world.log << "\[LOGOUT\] ✓ Sound systems cleaned ([listening_count] listening, [attached_count] attached)"
			return TRUE
		else
			world.log << "\[LOGOUT\] WARNING: Sound system lists not cleared"
			return FALSE
	
	catch(var/exception/e)
		world.log << "\[LOGOUT\] ERROR cleaning sound systems: [e]"
		return FALSE

/**
 * GetLogoutStatus(mob/players/M)
 * 
 * Diagnostic proc to verify player is fully cleaned up.
 * Used for testing and admin diagnostics.
 * 
 * Returns: List of any cleanup issues found (empty = fully clean)
 */
proc/GetLogoutStatus(mob/players/M)
	var/list/issues = list()
	
	if(!M) return issues
	
	// Check activity flags
	if(M.Doing || M.Carving || M.Cutting || M.Picking || M.Mining)
		issues += "Activity flags still active"
	
	// Check party status
	if(M.inparty || M.partynumber != 0)
		issues += "Still in party (inparty=[M.inparty], party#=[M.partynumber])"
	
	// Check sound systems
	if(M._listening_soundmobs && M._listening_soundmobs.len)
		issues += "Still listening to [M._listening_soundmobs.len] sound mobs"
	
	if(M._attached_soundmobs && M._attached_soundmobs.len)
		issues += "Still attached to [M._attached_soundmobs.len] sound mobs"
	
	return issues

/**
 * IsPlayerCleanlyLoggedOut(mob/players/M)
 * 
 * Quick boolean check: is player fully cleaned up?
 * 
 * Returns: TRUE if clean, FALSE if issues remain
 */
proc/IsPlayerCleanlyLoggedOut(mob/players/M)
	if(!M) return TRUE  // Null mobs are "clean" (deleted)
	
	var/list/issues = GetLogoutStatus(M)
	return !issues.len
