// dm/TimeSave.dm — Global time/resource state serialization and growth stage management.
// NOW USES TimeState DATUM for centralized persistence (see TimeState.dm)
// Maintains backward compatibility with legacy timesave.sav format

// Global basecamp resource plural forms (for UI display)
var
	SPs   // Plural form of SP for display
	MPs   // Plural form of MP for display
	SMs   // Plural form of SM for display
	SBs   // Plural form of SB for display

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

// Deserialize global time and resource state from timesave.sav.
// DEPRECATED: Use TimeState datum instead
// Loads legacy format and validates for corruption
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
		
		return TRUE
	else
		// No save file exists; initialize defaults
		InitializeTimeDefaults()
		return FALSE

// Initialize time state with defaults (called on first world creation)
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
