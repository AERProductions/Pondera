// TimeAdvancementSystem.dm - Phase 36: Automated Time Advancement & Seasonal Integration
// Handles automatic progression of time, seasons, and calendar with integrated callbacks

#define TIME_TICK_RATE 10        // Advance time every 10 world ticks
#define MINUTES_PER_TICK 15      // 15 game minutes per world tick = 1 game hour per 4 real minutes

#define SEASON_SPRING "Spring"
#define SEASON_SUMMER "Summer"
#define SEASON_AUTUMN "Autumn"
#define SEASON_WINTER "Winter"

// Hebrew Calendar months (Autumn start: Tishrei)
#define MONTH_TISHREI "Tishrei"      // Fall equinox / Civil New Year
#define MONTH_CHESHVAN "Cheshvan"
#define MONTH_KISLEV "Kislev"
#define MONTH_TEVET "Tevet"          // Winter solstice
#define MONTH_SHEVAT "Shevat"
#define MONTH_ADAR "Adar"
#define MONTH_NISAN "Nisan"          // Spring equinox / Ecclesiastical New Year
#define MONTH_IYAR "Iyar"
#define MONTH_SIVAN "Sivan"
#define MONTH_TAMMUZ "Tammuz"        // Summer solstice
#define MONTH_AV "Av"
#define MONTH_ELUL "Elul"

// Days in each month (Hebrew calendar)
var/list/MONTH_DAYS = list(
	MONTH_TISHREI = 30,
	MONTH_CHESHVAN = 29,
	MONTH_KISLEV = 29,
	MONTH_TEVET = 29,
	MONTH_SHEVAT = 30,
	MONTH_ADAR = 29,
	MONTH_NISAN = 30,
	MONTH_IYAR = 29,
	MONTH_SIVAN = 30,
	MONTH_TAMMUZ = 29,
	MONTH_AV = 30,
	MONTH_ELUL = 29
)

// Season progression (tied to months)
var/list/MONTH_TO_SEASON = list(
	MONTH_TISHREI = SEASON_AUTUMN,
	MONTH_CHESHVAN = SEASON_AUTUMN,
	MONTH_KISLEV = SEASON_AUTUMN,
	MONTH_TEVET = SEASON_WINTER,
	MONTH_SHEVAT = SEASON_WINTER,
	MONTH_ADAR = SEASON_WINTER,
	MONTH_NISAN = SEASON_SPRING,
	MONTH_IYAR = SEASON_SPRING,
	MONTH_SIVAN = SEASON_SPRING,
	MONTH_TAMMUZ = SEASON_SUMMER,
	MONTH_AV = SEASON_SUMMER,
	MONTH_ELUL = SEASON_SUMMER
)

// Month progression order
var/list/MONTH_ORDER = list(
	MONTH_TISHREI,
	MONTH_CHESHVAN,
	MONTH_KISLEV,
	MONTH_TEVET,
	MONTH_SHEVAT,
	MONTH_ADAR,
	MONTH_NISAN,
	MONTH_IYAR,
	MONTH_SIVAN,
	MONTH_TAMMUZ,
	MONTH_AV,
	MONTH_ELUL
)

// =============================================================================
// Time Advancement Manager
// =============================================================================

/datum/time_advancement_system
	var
		last_hour = null           // Track hour changes for callbacks
		last_day = null            // Track day changes for callbacks
		last_month = null          // Track month changes for callbacks
		last_season = null         // Track season changes for callbacks
		advancement_running = 0

/datum/time_advancement_system/proc/StartAdvancementLoop()
	if(advancement_running)
		return
	
	advancement_running = 1
	spawn(0) ContinuousTimeAdvancement()

/datum/time_advancement_system/proc/ContinuousTimeAdvancement()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(TIME_TICK_RATE)
		AdvanceTime()

/datum/time_advancement_system/proc/AdvanceTime()
	// Advance game minutes
	var/old_hour = hour
	var/old_day = day
	var/old_month = month
	
	// Add 15 game minutes per advancement
	var/minute_sum = (minute1 * 10) + minute2 + MINUTES_PER_TICK
	
	if(minute_sum >= 60)
		hour++
		minute_sum -= 60
		
		// Handle hour overflow (12-hour clock)
		if(hour > 12)
			hour = 1
			ampm = (ampm == "am") ? "pm" : "am"  // Toggle AM/PM
	
	// Set minute digits
	minute1 = minute_sum / 10
	minute2 = minute_sum % 10
	
	// Check for hour changes - trigger callbacks
	if(hour != old_hour)
		OnHourChange(old_hour, hour)
	
	// Check for day changes - trigger callbacks
	if(hour == 12 && ampm == "am" && old_hour != 12)  // Midnight transition
		day++
		OnDayChange(old_day, day)
		
		// Check for month changes
		var/days_in_month = MONTH_DAYS[month]
		if(day > days_in_month)
			day = 1
			AdvanceMonth(old_month)
			
			// Check for year changes (after Elul)
			if(month == MONTH_TISHREI)
				year++
				OnYearChange(year)

/datum/time_advancement_system/proc/AdvanceMonth(old_month)
	var/current_index = MONTH_ORDER.Find(month)
	if(current_index)
		var/next_index = (current_index % MONTH_ORDER.len) + 1
		month = MONTH_ORDER[next_index]
	
	// Update season based on new month
	var/old_season = season
	season = MONTH_TO_SEASON[month]
	
	OnMonthChange(old_month, month)
	
	if(season != old_season)
		OnSeasonChange(old_season, season)

// =============================================================================
// Callback Events (Override these to add custom behavior)
// =============================================================================

/datum/time_advancement_system/proc/OnHourChange(old_hour, new_hour)
	// Called every game hour
	// Hook for: day/night transitions, NPC routines, hunger ticks, etc.
	// Currently unused - add custom logic as needed
	return

/datum/time_advancement_system/proc/OnDayChange(old_day, new_day)
	// Called at midnight (12:00 AM)
	// Hook for: daily quests, farm harvests, NPC schedules, deed maintenance
	
	// Log to activity system for each player
	for(var/mob/players/P in world)
		if(P && P.client)
			LogSystemEvent(P, "new_day", "A new day dawns. Day [new_day] of [month].")
	
	// Trigger any daily systems
	OnDailyTick()

/datum/time_advancement_system/proc/OnMonthChange(old_month, new_month)
	// Called on first day of new month
	// Hook for: seasonal spawning, material availability, NPC events
	
	for(var/mob/players/P in world)
		if(P && P.client)
			LogSystemEvent(P, "new_month", "Welcome to [new_month]. Day 1 of 29-30.")
	
	// Trigger monthly systems
	OnMonthlyTick(new_month)

/datum/time_advancement_system/proc/OnSeasonChange(old_season, new_season)
	// Called when season transitions
	// Hook for: plant growth changes, NPC dialogue, biome changes, resource availability
	
	for(var/mob/players/P in world)
		if(P && P.client)
			LogSystemEvent(P, "season_change", "The season has changed to [new_season]!")
	
	// Trigger seasonal systems
	OnSeasonalTick(new_season)

/datum/time_advancement_system/proc/OnYearChange(new_year)
	// Called on New Year (1st Tishrei / Civil New Year)
	// Hook for: annual celebrations, long-term progression
	
	for(var/mob/players/P in world)
		if(P && P.client)
			LogSystemEvent(P, "new_year", "Year [new_year] begins! Shalom Shanah!")
	
	// Trigger yearly systems
	OnYearlyTick(new_year)

// =============================================================================
// Daily, Monthly, Seasonal, and Yearly Tick Handlers
// =============================================================================

/proc/OnDailyTick()
	// Reset daily activities
	// - Farm water needs
	// - NPC movement
	// - Daily quest resets
	// - Basecampcirculation
	return

/proc/OnMonthlyTick(month)
	// Monthly events
	// - Deed maintenance payment (typically monthly)
	// - Market price fluctuations
	// - NPC meetings
	// Trigger deed maintenance (usually called from InitializationManager)
	return

/proc/OnSeasonalTick(season)
	// Seasonal transitions
	// - Plant growth stage changes
	// - Weather pattern changes
	// - Resource availability shifts
	// - NPC dialogue updates
	
	// Update all plant growth stages
	UpdatePlantGrowthStages(season)
	
	// Update biome resource spawning
	UpdateBiomeResourceSpawning(season)

/proc/OnYearlyTick(year)
	// Yearly events
	// - Skill tree resets (if applicable)
	// - Annual celebrations
	// - Territory claims anniversary
	return

// =============================================================================
// Plant Growth System Integration
// =============================================================================

/proc/UpdatePlantGrowthStages(current_season)
	// Advance plant growth stages based on season
	// Growth happens during appropriate seasons only
	
	// Trees grow in Spring/Summer, dormant in Fall/Winter
	if(current_season in list(SEASON_SPRING, SEASON_SUMMER))
		growstage = min(10, growstage + 1)
	else
		// Growth slows in autumn, stops in winter
		if(current_season == SEASON_AUTUMN)
			growstage = min(10, growstage + 0.5)
	
	// Berries/bushes grow in Summer, harvested in Autumn
	if(current_season == SEASON_SUMMER)
		bgrowstage = min(10, bgrowstage + 1)
	else if(current_season == SEASON_AUTUMN)
		bgrowstage = min(10, bgrowstage + 0.5)
	
	// Vegetables grow in Spring/Summer
	if(current_season in list(SEASON_SPRING, SEASON_SUMMER))
		vgrowstage = min(10, vgrowstage + 1)
	
	// Grain grows in Summer, harvested in Autumn
	if(current_season == SEASON_SUMMER)
		ggrowstage = min(10, ggrowstage + 1)
	else if(current_season == SEASON_AUTUMN)
		ggrowstage = min(10, ggrowstage + 0.5)

/proc/UpdateBiomeResourceSpawning(current_season)
	// Update which resources can spawn based on season
	// This would integrate with mapgen/biome_*.dm to gate spawning
	return

// =============================================================================
// Time Query Utilities
// =============================================================================

/proc/IsNightTime()
	// True if currently night (roughly 8 PM - 7 AM)
	var/night_start = 20  // 8 PM
	var/night_end = 7     // 7 AM
	
	var/current_time = hour
	if(ampm == "pm" && hour < 12)
		current_time += 12
	
	return current_time >= night_start || current_time < night_end

/proc/IsSeasonMonth(target_season, target_month)
	// Check if target_month matches target_season
	return MONTH_TO_SEASON[target_month] == target_season

/proc/GetDaysUntilSeason(target_season)
	// Calculate days until target season starts
	var/current_index = MONTH_ORDER.Find(month)
	var/target_index = 1
	
	// Find first month of target season
	for(var/i = 1 to MONTH_ORDER.len)
		var/check_month = MONTH_ORDER[i]
		if(MONTH_TO_SEASON[check_month] == target_season)
			target_index = i
			break
	
	if(target_index >= current_index)
		return (target_index - current_index) * 30 + (MONTH_DAYS[month] - day)
	else
		return ((MONTH_ORDER.len - current_index) + target_index) * 30 + (MONTH_DAYS[month] - day)

/proc/GetDaysUntilMonth(target_month)
	// Calculate days until target month
	var/current_index = MONTH_ORDER.Find(month)
	var/target_index = MONTH_ORDER.Find(target_month)
	
	if(target_index >= current_index)
		return (target_index - current_index) * 30 + (MONTH_DAYS[month] - day)
	else
		return ((MONTH_ORDER.len - current_index) + target_index) * 30 + (MONTH_DAYS[month] - day)

// =============================================================================
// Time System Initialization
// =============================================================================

var/datum/time_advancement_system/global_time_system

/proc/InitializeTimeAdvancement()
	if(global_time_system)
		return
	
	global_time_system = new /datum/time_advancement_system()
	global_time_system.StartAdvancementLoop()
	
	RegisterInitComplete("time_advancement")

// =============================================================================
// Debug Verbs for Testing
// =============================================================================

/mob/players/verb/AdvanceGameTime()
	set name = "Advance Game Time (Debug)"
	set category = "Debug"
	
	global_time_system.AdvanceTime()
	src << "Advanced time. Current: [GetFullTimeString()]"

/mob/players/verb/SkipToNextHour()
	set name = "Skip to Next Hour (Debug)"
	set category = "Debug"
	
	for(var/i = 0 to 4)
		global_time_system.AdvanceTime()
	
	src << "Skipped ahead. Current: [GetFullTimeString()]"

/mob/players/verb/SkipToNextDay()
	set name = "Skip to Next Day (Debug)"
	set category = "Debug"
	
	for(var/i = 0 to 95)
		global_time_system.AdvanceTime()
	
	src << "Skipped to next day. Current: [GetFullTimeString()]"

/mob/players/verb/SkipToNextSeason()
	set name = "Skip to Next Season (Debug)"
	set category = "Debug"
	
	// Skip to day 1 of first month of next season
	var/current_index = MONTH_ORDER.Find(month)
	var/target_index = current_index + 3  // Skip 3 months
	if(target_index > MONTH_ORDER.len)
		target_index -= MONTH_ORDER.len
	
	for(var/i = 0 to 2700)  // ~90 days
		global_time_system.AdvanceTime()
	
	src << "Skipped to next season. Current: [GetFullTimeString()]"

/mob/players/verb/ViewCurrentTime()
	set name = "View Current Time (Debug)"
	set category = "Debug"
	
	var/time_str = GetTimeString()
	var/date_str = GetDateString()
	var/night = IsNightTime() ? "Yes" : "No"
	
	src << "\n<b>═══════════════════════════════════</b>"
	src << "<b>CURRENT TIME & DATE</b>"
	src << "<b>═══════════════════════════════════</b>"
	src << "Time: [time_str]"
	src << "Date: [date_str]"
	src << "Season: [season]"
	src << "Night: [night]"
	src << "\n<b>═══════════════════════════════════</b>\n"
