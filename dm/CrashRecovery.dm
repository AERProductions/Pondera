/**
 * CRASH RECOVERY SYSTEM
 * Detects and recovers players marked online after unexpected server shutdown
 * 
 * Problem: If server crashes, player entries may remain in "online" state
 * Solution: On startup, validate player status and reset if needed
 * 
 * Integrated with: InitializationManager.dm, SavingChars.dm
 */

// Crash recovery state tracking
var
	crash_recovery_complete = FALSE
	crash_recovery_players_found = 0
	crash_recovery_players_recovered = 0

/**
 * InitializeCrashRecovery()
 * 
 * Called during world initialization to detect and recover crashed players.
 * Should run AFTER character system is ready but BEFORE players can login.
 * 
 * Returns: TRUE if recovery completed successfully, FALSE if errors occurred
 */
proc/InitializeCrashRecovery()
	world.log << "\[CRASH_RECOVERY\] Scanning for players needing recovery..."
	
	crash_recovery_players_found = 0
	crash_recovery_players_recovered = 0
	
	var/list/players_to_recover = list()
	
	// SCAN: Find all player savefiles
	for(var/file in flist("players/*.sav"))
		if(!file) continue
		
		var/player_path = "players/[file]"
		if(!fexists(player_path))
			continue
		
		try
			// Load player savefile and check status
			var/savefile/F = new(player_path)
			if(!F) continue
			
			var/online_status = null
			F["online"] >> online_status
			
			// If player was online, mark for recovery
			if(online_status)
				crash_recovery_players_found++
				players_to_recover += list(list(
					"path" = player_path,
					"file" = file,
					"status" = online_status
				))
				world.log << "\[CRASH_RECOVERY\] Found player [file] - was online"
		
		catch(var/exception/e)
			world.log << "\[CRASH_RECOVERY\] ERROR reading [player_path]: [e]"
	
	// RECOVERY: Reset online status for found players
	if(players_to_recover.len > 0)
		world.log << "\[CRASH_RECOVERY\] Recovering [players_to_recover.len] players..."
		
		for(var/list/player_data in players_to_recover)
			if(!RecoverCrashedPlayer(player_data))
				world.log << "\[CRASH_RECOVERY\] WARNING: Failed to recover [player_data["file"]]"
		
		world.log << "\[CRASH_RECOVERY\] Recovery complete: [crash_recovery_players_recovered]/[crash_recovery_players_found] players recovered"
	
	crash_recovery_complete = TRUE
	return crash_recovery_players_found == crash_recovery_players_recovered

/**
 * RecoverCrashedPlayer(player_data)
 * 
 * Reset the online status of a specific player and log the event.
 * Player data structure: list("path" = savefile_path, "file" = filename, "status" = was_online)
 * 
 * Returns: TRUE if recovery successful, FALSE on error
 */
proc/RecoverCrashedPlayer(list/player_data)
	if(!player_data || !player_data["path"])
		return FALSE
	
	var/player_path = player_data["path"]
	var/player_name = player_data["file"]
	
	try
		var/savefile/F = new(player_path)
		if(!F)
			world.log << "\[CRASH_RECOVERY\] ERROR: Could not open [player_path]"
			return FALSE
		
		// Reset online status to FALSE
		F["online"] << FALSE
		
		// Add recovery timestamp for audit
		F["last_crash_recovery"] << world.time
		
		// Log recovery event
		world.log << "\[CRASH_RECOVERY\] ✓ Recovered [player_name] - reset online status"
		crash_recovery_players_recovered++
		
		return TRUE
	
	catch(var/exception/e)
		world.log << "\[CRASH_RECOVERY\] ERROR recovering [player_name]: [e]"
		return FALSE

/**
 * GetCrashRecoveryReport()
 * 
 * Generate human-readable report of crash recovery operations.
 * Used for admin diagnostics and game log audit.
 * 
 * Returns: String report
 */
proc/GetCrashRecoveryReport()
	var/report = "CRASH RECOVERY REPORT\n"
	report += "═════════════════════════════════════════\n"
	report += "Recovery Complete: [crash_recovery_complete]\n"
	report += "Players Found: [crash_recovery_players_found]\n"
	report += "Players Recovered: [crash_recovery_players_recovered]\n"
	
	if(crash_recovery_players_found > 0)
		report += "Recovery Rate: [round(crash_recovery_players_recovered * 100 / crash_recovery_players_found)]%\n"
	
	return report

/**
 * MarkPlayerOnline(mob/players/M)
 * 
 * Call when player logs in to mark them as online in savefile.
 * Used to track active sessions for crash detection.
 * 
 * Should be called from mob/players/Login() or character load sequence.
 */
proc/MarkPlayerOnline(mob/players/M)
	if(!M || !M.client)
		return FALSE
	
	try
		// Mark in-memory state
		M.online = TRUE
		
		// Mark in savefile for crash detection
		var/savefile/F = new("players/[M.ckey].sav")
		if(F)
			F["online"] << TRUE
			world.log << "\[CRASH_RECOVERY\] Marked [M.ckey] as online"
			return TRUE
	
	catch(var/exception/e)
		world.log << "\[CRASH_RECOVERY\] ERROR marking [M.ckey] online: [e]"
	
	return FALSE

/**
 * MarkPlayerOffline(mob/players/M)
 * 
 * Call when player logs out to mark them as offline.
 * Clears the crash detection flag.
 * 
 * Should be called from mob/players/Logout() or disconnection handler.
 */
proc/MarkPlayerOffline(mob/players/M)
	if(!M)
		return FALSE
	
	try
		// Mark in-memory state
		M.online = FALSE
		
		// Mark in savefile to clear crash flag
		var/savefile/F = new("players/[M.ckey].sav")
		if(F)
			F["online"] << FALSE
			world.log << "\[CRASH_RECOVERY\] Marked [M.ckey] as offline"
			return TRUE
	
	catch(var/exception/e)
		world.log << "\[CRASH_RECOVERY\] ERROR marking [M.ckey] offline: [e]"
	
	return FALSE

/**
 * VerifyCrashRecoveryIntegrity()
 * 
 * Diagnostic tool to verify crash recovery system is working.
 * Checks for stranded players and reports issues.
 * 
 * Returns: List of integrity issues found (empty = OK)
 */
proc/VerifyCrashRecoveryIntegrity()
	var/list/issues = list()
	
	// Check all player files
	for(var/file in flist("players/*.sav"))
		if(!file) continue
		
		var/player_path = "players/[file]"
		if(!fexists(player_path)) continue
		
		try
			var/savefile/F = new(player_path)
			if(!F) continue
			
			var/online_status = null
			F["online"] >> online_status
			
			// If online after recovery, flag as issue
			if(online_status && crash_recovery_complete)
				issues += "Player [file] still marked online after recovery"
		
		catch(var/exception/e)
			issues += "Error reading [file]: [e]"
	
	if(!issues.len)
		world.log << "\[CRASH_RECOVERY\] Integrity check: OK"
	else
		world.log << "\[CRASH_RECOVERY\] Integrity check found [issues.len] issues"
		for(var/issue in issues)
			world.log << "\[CRASH_RECOVERY\]   - [issue]"
	
	return issues
