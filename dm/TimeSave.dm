// dm/TimeSave.dm — Global time/resource state serialization and growth stage management.
// NOW USES TimeState DATUM for centralized persistence (see TimeState.dm)
// Maintains backward compatibility with legacy timesave.sav format

// Global basecamp resource plural forms (for UI display)
var
	SPs   // Plural form of SP for display
	MPs   // Plural form of MP for display
	SMs   // Plural form of SM for display
	SBs   // Plural form of SB for display

/**
 * ATOMIC SAVE COORDINATOR
 * Ensures character saves and time saves complete together
 * Prevents data inconsistency if crash occurs between saves
 */
proc/SaveGameState()
	/**
	 * Atomic game state save (3-phase):
	 * 1. Save character data for all connected players
	 * 2. Save global time/resource state
	 * 3. Validate both saves completed before returning
	 * 
	 * If any save fails, log critical error for admin review
	 */
	world.log << "\[SAVE\] Starting atomic save of all game state..."
	
	// PHASE 1: Save all player characters
	var/players_saved = 0
	var/players_failed = 0
	for(var/client/C)
		if(C && C.mob && C.mob.base_save_allowed)
			if(C.base_SaveMob())
				players_saved++
			else
				players_failed++
				world.log << "\[SAVE\] WARNING: Failed to save player [C.mob.name]"
	
	// PHASE 2: Save global time/resource state
	TimeSave()
	world.log << "\[SAVE\] Saved global time state"
	
	// PHASE 3: Validation
	if(fexists("timesave.sav"))
		if(players_failed > 0)
			world.log << "\[SAVE\] ✓ Atomic save completed: [players_saved] players saved, [players_failed] failed, 1 global state"
		else
			world.log << "\[SAVE\] ✓ Atomic save completed: [players_saved] players, 1 global state"
		return TRUE
	else
		world.log << "\[SAVE\] ✗ CRITICAL: Global time save missing!"
		return FALSE

// Serialize global time and resource state to timesave.sav.
// DEPRECATED: Use TimeState datum instead
// This proc maintained for backward compatibility during migration
proc/TimeSave()
	// Capture current state if datum exists
	var/datum/time_state/ts = new()
	ts.CaptureTimeState()
	
	// Save to legacy format for compatibility
	var/savefile/F = new("timesave.sav")
	F["SP"] << SP
	F["MP"] << MP
	F["SM"] << SM
	F["SB"] << SB
	F["time_of_day"] << time_of_day
	F["hour"] << hour
	F["ampm"] << ampm
	F["minute1"] << minute1
	F["minute2"] << minute2
	F["day"] << day
	F["month"] << month
	F["year"] << year
	F["a"] << a
	F["wo"] << wo
	F["vgrowstage"] << vgrowstage
	F["ggrowstage"] << ggrowstage
	F["bgrowstage"] << bgrowstage
	F["growstage"] << growstage
	
	// Also save datum representation for future migration
	F["time_state"] << ts
	
	// Phase A: Save deed registry for economic persistence
	SaveDeedRegistry()

// Deserialize global time and resource state from timesave.sav.
// DEPRECATED: Use TimeState datum instead
// Loads legacy format and validates for corruption
// CRITICAL: Ensures game time is always valid to prevent desynchronization
proc/TimeLoad()
	if(fexists("timesave.sav"))
		var/savefile/F = new("timesave.sav")
		
		// Try to load datum first (new format)
		var/datum/time_state/ts = null
		F["time_state"] >> ts
		
		if(ts)
			// New format: validate and restore
			if(ts.ValidateTimeState())
				ts.RestoreTimeState()
				world.log << "\[INIT\] TimeLoad: Restored state from TimeState datum"
				return TRUE
		
		// Fallback to legacy format if datum not found
		F["SP"] >> SP
		F["MP"] >> MP
		F["SM"] >> SM
		F["SB"] >> SB
		F["time_of_day"] >> time_of_day
		F["hour"] >> hour
		F["ampm"] >> ampm
		F["minute1"] >> minute1
		F["minute2"] >> minute2
		F["day"] >> day
		F["month"] >> month
		F["year"] >> year
		F["a"] >> a
		F["wo"] >> wo
		F["vgrowstage"] >> vgrowstage
		F["ggrowstage"] >> ggrowstage
		F["bgrowstage"] >> bgrowstage
		F["growstage"] >> growstage
		
		// CRITICAL: Validate loaded values have safe defaults
		if(!time_of_day) time_of_day = 1  // Default to DAY
		if(!hour) hour = 12
		if(!ampm) ampm = "am"
		if(!minute1) minute1 = 0
		if(!minute2) minute2 = 0
		if(!day) day = 1
		if(!month) month = "Adar"
		if(!year) year = 0
		
		world.log << "\[INIT\] TimeLoad: Restored state from legacy timesave.sav"
		return TRUE
	else
		// No save file - initialize defaults
		world.log << "\[INIT\] TimeLoad: No timesave.sav found - using defaults"
		time_of_day = 1  // DAY
		hour = 12
		ampm = "am"
		minute1 = 0
		minute2 = 0
		day = 1
		month = "Adar"
		year = 0
		
		// Initialize resource counters
		if(!SP) SP = 0
		if(!MP) MP = 0
	if(!SM) SM = 0
	if(!SB) SB = 0
	
	// Phase A: Load deed registry for economic persistence
	LoadDeedRegistry()
	
	return FALSE// Initialize time state with defaults (called on first world creation)
proc/InitializeTimeDefaults()
	var/datum/time_state/ts = new()
	ts.SetTimeDefaults()
	ts.RestoreTimeState()

// Update growth stages for all bush plants in the world.
// Reads current bgrowstage, vgrowstage, ggrowstage from globals
proc/GrowBushes()
	for(var/obj/Plants/X in bushlist)
		X.bgrowstate = bgrowstage
		X.vgrowstate = vgrowstage
		X.ggrowstate = ggrowstage
		X.UpdatePlantPic()

// Update growth stages for all tree plants in the world.
// Reads current growstage from globals
proc/GrowTrees()
	for(var/obj/plant/ueiktree/X in treelist)
		X.growstate = growstage
		X.UpdateTreePic()

// Helper: Get current time as string (e.g., "7:39am")
proc/GetTimeString()
	return "[hour]:[minute1][minute2][ampm]"

// Helper: Get current date as string (e.g., "29 Adar 682am")
proc/GetDateString()
	return "[day] [month] [year]"

// Helper: Get full datetime with season
proc/GetFullTimeString()
	return "[GetTimeString()] - [GetDateString()] ([season])"

// Background loop: Periodically save time state to prevent data loss on crashes.
// Saves every ~10 game hours (36000 ticks at tick_lag=0.25 = ~150 real seconds)
proc/StartPeriodicTimeSave()
	set waitfor = 0
	set background = 1
	
	var/save_interval = 36000  // ~10 game hours between saves
	
	while(1)
		sleep(save_interval)
		TimeSave()

// Background loop: Monthly village deed maintenance processor.
// Checks all DeedToken_Zone objects every month and processes maintenance payments.
// Handles grace periods and deed expiration for unpaid villages.
proc/StartDeedMaintenanceProcessor()
	set waitfor = 0
	set background = 1
	
	// Check every month (approximately 43200 ticks at tick_lag=0.25 = 10800 real seconds = 3 hours)
	// This means maintenance checks happen every 3 real hours (1 in-game month per 3 hours)
	var/check_interval = 43200  // 1 month in game time
	
	while(1)
		sleep(check_interval)
		ProcessAllDeedMaintenance()

// Process maintenance for all village deed zones.
// Iterates through all DeedToken_Zone objects and checks if maintenance is due.
proc/ProcessAllDeedMaintenance()
	for(var/obj/DeedToken_Zone/dz in world)
		if(!dz)
			continue
		
		// Check if maintenance is due
		if(dz.IsMaintenanceDue())
			// Attempt to deduct maintenance cost from owner
			var/mob/players/owner = null
			
			// Find owner by key
			for(var/mob/players/M in world)
				if(M.key == dz.owner_key)
					owner = M
					break
			
			if(owner)
				// Owner is online; call their ProcessMaintenance()
				dz.ProcessMaintenance(owner)
				// Notify deed change to invalidate cache
				NotifyDeedChange(owner)
			else
				// Owner offline; attempt direct deduction
				// Note: This is a simplified approach; full implementation would need
				// to integrate with character persistence system
				// For now, we just trigger grace period if not yet started
				if(dz.grace_period_end == 0)
					// First failure; start grace period (7 days)
					dz.grace_period_end = world.timeofday + (7 * 86400)  // 7 days in ticks
				else if(world.timeofday > dz.grace_period_end)
					// Grace period expired; trigger deed expiration
					dz.OnMaintenanceFailure()
					// Notify global cache invalidation for offline owner
					InvalidateDeedPermissionCacheGlobal()

