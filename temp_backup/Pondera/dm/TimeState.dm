// dm/TimeState.dm — Global time/calendar state datum for persistence and validation
// Replaces scattered time variables with centralized state management
// Handles serialization of all time-of-day, calendar, and growth stage data

/datum/time_state
	var
		// Time of day (12-hour format)
		time_of_day = DAY        // DAY=2, NIGHT=0, SUNSET=1 (lighting state)
		hour = 7                 // 1-12 (12-hour clock)
		ampm = "am"              // "am" or "pm"
		minute1 = 3              // First digit of minutes (0-5)
		minute2 = 9              // Second digit of minutes (0-9)
		
		// Calendar tracking
		day = 29                 // 1-30 (varies by month)
		month = "Adar"           // Month name (Hebrew calendar)
		year = 682               // Anno Mundi
		season = "Spring"        // Spring, Summer, Autumn, Winter
		
		// Resource growth stages (applied to world objects)
		growstage = 0            // Tree growth stage
		bgrowstage = 0           // Bush/plant growth stage (berries)
		vgrowstage = 0           // Vegetable growth stage
		ggrowstage = 0           // Grain growth stage
		
		// Global basecamp resource counts
		SP = 0                   // Stone count (singular)
		MP = 0                   // Metal count (singular)
		SM = 0                   // Stamina module count (singular)
		SB = 0                   // Supply box count (singular)
		
		// Misc state
		a = 0                    // Unknown variable (preserved from original)
		wo = 0                   // Weather override flag (0=no weather, 1=weather active)

	// Capture current global time state for serialization
	proc/CaptureTimeState()
		time_of_day = global.time_of_day
		hour = global.hour
		ampm = global.ampm
		minute1 = global.minute1
		minute2 = global.minute2
		day = global.day
		month = global.month
		year = global.year
		season = global.season
		
		growstage = global.growstage
		bgrowstage = global.bgrowstage
		vgrowstage = global.vgrowstage
		ggrowstage = global.ggrowstage
		
		SP = global.SP
		MP = global.MP
		SM = global.SM
		SB = global.SB
		
		a = global.a
		wo = global.wo
		
		return TRUE

	// Restore captured time state to global variables
	proc/RestoreTimeState()
		if(!src)
			return FALSE
		
		global.time_of_day = time_of_day
		global.hour = hour
		global.ampm = ampm
		global.minute1 = minute1
		global.minute2 = minute2
		global.day = day
		global.month = month
		global.year = year
		global.season = season
		
		global.growstage = growstage
		global.bgrowstage = bgrowstage
		global.vgrowstage = vgrowstage
		global.ggrowstage = ggrowstage
		
		global.SP = SP
		global.MP = MP
		global.SM = SM
		global.SB = SB
		
		global.a = a
		global.wo = wo
		
		return TRUE

	// Validate time state for corruption
	proc/ValidateTimeState()
		var/valid = TRUE
		
		// Validate time of day
		if(!(time_of_day in list(DAY, NIGHT, 1)))
			valid = FALSE
		
		// Validate hour (1-12)
		if(hour < 1 || hour > 12)
			valid = FALSE
		
		// Validate ampm
		if(!(ampm in list("am", "pm")))
			valid = FALSE
		
		// Validate minutes
		if(minute1 < 0 || minute1 > 5)
			valid = FALSE
		if(minute2 < 0 || minute2 > 9)
			valid = FALSE
		
		// Validate day (1-30, most months have 29-30 days)
		if(day < 1 || day > 30)
			valid = FALSE
		
		// Validate month (Hebrew calendar)
		if(!(month in list("Shevat", "Adar", "Nisan", "Iyar", "Sivan", "Tammuz", "Av", "Elul", "Tishrei", "Cheshvan", "Kislev", "Tevet")))
			valid = FALSE
		
		// Validate year (should be reasonable)
		if(year < 1 || year > 9999)
			valid = FALSE
		
		// Validate season
		if(!(season in list("Spring", "Summer", "Autumn", "Winter")))
			valid = FALSE
		
		// Validate growth stages (0-based indices for plant growth)
		if(growstage < 0 || growstage > 10)
			valid = FALSE
		if(bgrowstage < 0 || bgrowstage > 10)
			valid = FALSE
		if(vgrowstage < 0 || vgrowstage > 10)
			valid = FALSE
		if(ggrowstage < 0 || ggrowstage > 10)
			valid = FALSE
		
		// Validate resource counts (should be non-negative)
		if(SP < 0 || MP < 0 || SM < 0 || SB < 0)
			valid = FALSE
		
		// Validate misc state
		if(wo < 0 || wo > 1)
			valid = FALSE
		
		if(!valid)
			// Attempt recovery with defaults
			SetTimeDefaults()
		
		return valid

	// Set default time state for new worlds
	proc/SetTimeDefaults()
		time_of_day = DAY
		hour = 7
		ampm = "am"
		minute1 = 3
		minute2 = 9
		day = 29
		month = "Adar"
		year = 682
		season = "Spring"
		
		growstage = 0
		bgrowstage = 0
		vgrowstage = 0
		ggrowstage = 0
		
		SP = 0
		MP = 0
		SM = 0
		SB = 0
		
		a = 0
		wo = 0

	// Get readable time string (e.g., "7:39am")
	proc/GetTimeString()
		return "[hour]:[minute1][minute2][ampm]"

	// Get readable date string (e.g., "29 Adar 682am")
	proc/GetDateString()
		return "[day] [month] [year] AM"

	// Get full datetime string
	proc/GetFullTimeString()
		return "[GetTimeString()] - [GetDateString()] ([season])"

	// Calculate elapsed in-game time since capture (in minutes)
	proc/GetElapsedMinutes()
		// Returns approximate minutes elapsed
		// This is a simple calculation; actual tracking could be more sophisticated
		return (minute1 * 10) + minute2
