// NPCRoutineSystem.dm - Phase 38: NPC Time-Based Routines
// Implements daily schedules, time-gated shops, sleep cycles, and routine-based NPC behavior

#define NPC_STATE_WANDER "wandering"
#define NPC_STATE_WORKING "working"
#define NPC_STATE_SLEEPING "sleeping"
#define NPC_STATE_EATING "eating"
#define NPC_STATE_SOCIALIZING "socializing"
#define NPC_STATE_IDLE "idle"

// Season constants (match TimeAdvancementSystem.dm)
#define SEASON_SPRING "Spring"
#define SEASON_SUMMER "Summer"
#define SEASON_AUTUMN "Autumn"
#define SEASON_WINTER "Winter"

// NPC Shop Hours (in 12-hour format with AM/PM)
var/list/NPC_SHOP_HOURS = list(
	"Blacksmith" = list("open_hour" = 7, "open_ampm" = "am", "close_hour" = 6, "close_ampm" = "pm"),
	"Merchant" = list("open_hour" = 8, "open_ampm" = "am", "close_hour" = 8, "close_ampm" = "pm"),
	"Herbalist" = list("open_hour" = 9, "open_ampm" = "am", "close_hour" = 5, "close_ampm" = "pm"),
	"Inn" = list("open_hour" = 5, "open_ampm" = "am", "close_hour" = 11, "close_ampm" = "pm"),
	"Fisher" = list("open_hour" = 6, "open_ampm" = "am", "close_hour" = 3, "close_ampm" = "pm")
)

// Sleep windows (when NPCs are sleeping, in 24-hour format)
var/list/NPC_SLEEP_SCHEDULE = list(
	"typical" = list("start_hour" = 22, "start_ampm" = "pm", "end_hour" = 6, "end_ampm" = "am"),
	"early_riser" = list("start_hour" = 21, "start_ampm" = "pm", "end_hour" = 5, "end_ampm" = "am"),
	"night_owl" = list("start_hour" = 2, "start_ampm" = "am", "end_hour" = 8, "end_ampm" = "am")
)

// =============================================================================
// NPC ROUTINE DATUM
// =============================================================================

/datum/npc_routine
	var
		npc_ref                          // Weak reference to NPC mob
		npc_type = "generic"             // Type of NPC (blacksmith, merchant, etc.)
		current_state = NPC_STATE_WANDER
		
		// Schedule times (in hours, 24-hour converted from 12-hour)
		open_hour = 7                    // 7 AM default
		close_hour = 18                  // 6 PM default
		sleep_start_hour = 22            // 10 PM
		sleep_end_hour = 6               // 6 AM
		
		// State tracking
		last_state_change = 0
		state_change_interval = 300      // Check state every 5 minutes
		
		// Location tracking
		home_location = null             // Where NPC sleeps
		shop_location = null             // Where NPC works
		
		// Routine flags
		is_awake = 1
		is_open = 1                      // For shopkeepers
		
		// Routine progression
		routine_index = 0                // Current step in daily routine
		routine_actions = list()         // Actions to perform

/datum/npc_routine/proc/Initialize(npc, npc_type_name)
	npc_ref = npc
	npc_type = npc_type_name
	routine_actions = list()  // Initialize as empty list
	
	SetupNPCType(npc_type_name)
	RegisterInitComplete("npc_routine")

/datum/npc_routine/proc/SetupNPCType(type_name)
	// Configure routine based on NPC type
	switch(type_name)
		if("blacksmith")
			open_hour = 7      // 7 AM
			close_hour = 18    // 6 PM
			sleep_start_hour = 22
			sleep_end_hour = 6
			routine_actions = list(
				"sleep", "wake", "breakfast", "open_shop", "work", "lunch", "work", "close_shop", "socialize", "sleep"
			)
		
		if("merchant")
			open_hour = 8
			close_hour = 20    // 8 PM
			sleep_start_hour = 23
			sleep_end_hour = 7
			routine_actions = list(
				"sleep", "wake", "breakfast", "open_shop", "work", "lunch", "work", "evening_sales", "close_shop", "socialize", "sleep"
			)
		
		if("herbalist")
			open_hour = 9
			close_hour = 17    // 5 PM
			sleep_start_hour = 21
			sleep_end_hour = 7
			routine_actions = list(
				"sleep", "wake", "breakfast", "gather_herbs", "prepare_potions", "open_shop", "work", "lunch", "work", "close_shop", "sleep"
			)
		
		if("innkeeper")
			open_hour = 5      // Always open, early
			close_hour = 23    // Late night
			sleep_start_hour = 2
			sleep_end_hour = 5
			routine_actions = list(
				"wake", "breakfast", "manage_inn", "lunch", "manage_inn", "dinner", "manage_inn", "socialize", "close_inn", "sleep"
			)
		
		if("fisher")
			open_hour = 6
			close_hour = 15    // 3 PM
			sleep_start_hour = 20
			sleep_end_hour = 5
			routine_actions = list(
				"sleep", "wake", "breakfast", "go_fishing", "fish", "lunch", "fish", "return_fishing", "close_shop", "socialize", "sleep"
			)
		
		else
			// Generic routine
			routine_actions = list(
				"sleep", "wake", "breakfast", "work", "lunch", "work", "socialize", "sleep"
			)

/datum/npc_routine/proc/UpdateRoutineState()
	// Called periodically to update NPC state based on time
	if(!npc_ref) return
	
	var/mob/npcs/npc = npc_ref
	if(!npc) return
	
	// Check if time to sleep
	if(IsSleepTime())
		if(current_state != NPC_STATE_SLEEPING)
			EnterSleepState(npc)
	else if(!is_awake)
		// Wake up
		ExitSleepState(npc)
	
	// Check if shop should be open/closed
	if(npc_type in NPC_SHOP_HOURS)
		if(IsShopOpen())
			if(!is_open)
				OpenShop(npc)
		else
			if(is_open)
				CloseShop(npc)
	
	// Random routine actions while awake
	if(is_awake && current_state == NPC_STATE_WANDER)
		if(prob(15))  // 15% chance per update
			ExecuteRoutineAction(npc)

/datum/npc_routine/proc/IsSleepTime()
	// Check if current time falls within sleep window
	if(sleep_start_hour > sleep_end_hour)
		// Sleep window crosses midnight (e.g., 10 PM - 6 AM)
		return hour >= sleep_start_hour || hour < sleep_end_hour
	else
		// Sleep window doesn't cross midnight
		return hour >= sleep_start_hour && hour < sleep_end_hour

/datum/npc_routine/proc/IsShopOpen()
	// Check if current time falls within shop hours
	if(open_hour > close_hour)
		// Wraps around midnight (rare)
		return hour >= open_hour || hour < close_hour
	else
		return hour >= open_hour && hour < close_hour

/datum/npc_routine/proc/EnterSleepState(mob/npcs/npc)
	current_state = NPC_STATE_SLEEPING
	is_awake = 0
	
	// Move to home location
	if(home_location)
		npc.loc = home_location
	
	// Stop any active movement - NPCs use NPCWander() which we'll suppress
	// Just move to home and update state tracking
	if(npc && home_location)
		npc.loc = home_location
	
	// Visual: NPC lies down (change icon if available)
	// npc.icon_state = "[npc.base_icon_state]_sleeping"

/datum/npc_routine/proc/ExitSleepState(mob/npcs/npc)
	current_state = NPC_STATE_WANDER
	is_awake = 1
	
	// Visual: NPC stands up
	// npc.icon_state = npc.base_icon_state

/datum/npc_routine/proc/OpenShop(mob/npcs/npc)
	is_open = 1
	current_state = NPC_STATE_WORKING
	
	// Move to shop location if needed
	if(shop_location && npc.loc != shop_location)
		npc.loc = shop_location
	
	// Broadcast to nearby players
	for(var/mob/players/P in range(15, npc))
		LogSystemEvent(P, "npc_event", "[npc.name]'s shop is now open!")

/datum/npc_routine/proc/CloseShop(mob/npcs/npc)
	is_open = 0
	current_state = NPC_STATE_IDLE
	
	// Broadcast to nearby players
	for(var/mob/players/P in range(15, npc))
		LogSystemEvent(P, "npc_event", "[npc.name] is closing up shop for the day.")

/datum/npc_routine/proc/ExecuteRoutineAction(mob/npcs/npc)
	// Execute a random action from the routine
	// Check if routine_actions list exists and has items
	var/action_count = length(routine_actions)
	if(action_count <= 0) return
	
	var/action = routine_actions[rand(1, action_count)]
	
	switch(action)
		if("breakfast", "lunch", "dinner")
			// Sit down and "eat"
			current_state = NPC_STATE_EATING
			sleep(50)  // Eat for a bit
			current_state = NPC_STATE_WANDER
		
		if("work", "manage_inn", "open_shop")
			current_state = NPC_STATE_WORKING
			// Stay in place and look busy
			sleep(100)
			current_state = NPC_STATE_WANDER
		
		if("socialize")
			current_state = NPC_STATE_SOCIALIZING
			// Look around for other NPCs to talk to
			sleep(80)
			current_state = NPC_STATE_WANDER
		
		if("gather_herbs", "go_fishing")
			// Move to work area
			current_state = NPC_STATE_WORKING
			if(shop_location)
				npc.loc = shop_location
			sleep(150)
			current_state = NPC_STATE_WANDER
		
		if("fish", "prepare_potions")
			current_state = NPC_STATE_WORKING
			sleep(120)
			current_state = NPC_STATE_WANDER

/datum/npc_routine/proc/GetRoutineState()
	return current_state

/datum/npc_routine/proc/IsNPCAwake()
	return is_awake

/datum/npc_routine/proc/IsShopOperating()
	return is_open

// =============================================================================
// TIME-BASED SHOP SYSTEM
// =============================================================================

/proc/CheckNPCShopStatus(npc_name)
	// Return shop status (open/closed) for a specific NPC
	var/hours = NPC_SHOP_HOURS[npc_name]
	if(!hours) return "unknown"
	
	var/open_h = ConvertTo24Hour(hours["open_hour"], hours["open_ampm"])
	var/close_h = ConvertTo24Hour(hours["close_hour"], hours["close_ampm"])
	
	if(open_h > close_h)
		// Wraps midnight
		return (hour >= open_h || hour < close_h) ? "open" : "closed"
	else
		return (hour >= open_h && hour < close_h) ? "open" : "closed"

/proc/ConvertTo24Hour(hour_12, ampm)
	// Convert 12-hour format to 24-hour
	if(ampm == "am")
		if(hour_12 == 12) return 0   // 12 AM = 0
		return hour_12
	else  // PM
		if(hour_12 == 12) return 12  // 12 PM = 12
		return hour_12 + 12

/proc/ConvertTo12Hour(hour_24)
	// Convert 24-hour to 12-hour
	if(hour_24 == 0) return list(12, "am")
	if(hour_24 < 12) return list(hour_24, "am")
	if(hour_24 == 12) return list(12, "pm")
	return list(hour_24 - 12, "pm")

// =============================================================================
// NPC INTERACTION HOOKS
// =============================================================================

/proc/CanTalkToNPC(mob/npcs/npc)
	// Check if NPC is available for conversation
	if(!npc) return 0
	
	// Look up routine in active list
	var/datum/npc_routine/routine = active_npc_routines[npc]
	if(!routine) return 1  // No routine = always available
	
	// Can't talk to sleeping NPCs
	if(routine.current_state == NPC_STATE_SLEEPING)
		return 0
	
	// Can talk during other states
	return 1

/proc/CanBuyFromNPC(mob/npcs/npc)
	// Check if NPC's shop is open
	if(!npc) return 0
	
	// For now, NPCs are always open - Phase 38 feature check
	// TODO: Integrate with NPC routine system when NPC datum is expanded
	return 1

// =============================================================================
// BACKGROUND ROUTINE MANAGER
// =============================================================================

var/list/active_npc_routines = list()

/proc/RegisterNPCRoutine(mob/npcs/npc, npc_type)
	// Register an NPC for routine management
	if(!npc) return
	
	var/datum/npc_routine/routine = new /datum/npc_routine()
	routine.Initialize(npc, npc_type)
	
	// Track in active routines list
	active_npc_routines[npc] = routine

/proc/UpdateAllNPCRoutines()
	// Background loop to update all NPC routines
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(50)  // Update every 2.5 seconds
		
		for(var/datum/npc_routine/routine in active_npc_routines)
			if(routine)
				routine.UpdateRoutineState()

/proc/InitializeNPCRoutineSystem()
	// Start the background routine updater
	spawn(0) UpdateAllNPCRoutines()

// =============================================================================
// NPC TIME-BASED DIALOGUE
// =============================================================================

/proc/GetNPCDialogueBySeason(season)
	// Return time/season-appropriate dialogue hints
	switch(season)
		if(SEASON_SPRING)
			return list(
				"The flowers are blooming beautifully this time of year.",
				"Spring rains bring new growth to the land.",
				"It's planting season - farmers are busy in the fields."
			)
		if(SEASON_SUMMER)
			return list(
				"It's quite hot out there - make sure you stay hydrated!",
				"The long days are perfect for traveling far.",
				"Merchants have their best goods in stock during summer."
			)
		if(SEASON_AUTUMN)
			return list(
				"The harvest is in full swing this time of year.",
				"The cooler weather is a welcome change.",
				"Prepare your supplies - winter will be here soon."
			)
		if(SEASON_WINTER)
			return list(
				"Brr, it's freezing out there. Bundle up!",
				"Winter is harsh - many avoid travel during this season.",
				"A warm fire and a hot meal - what more could you want?"
			)
	
	return list("How can I help you?")

/proc/GetNPCDialogueByTime(hour)
	// Return time-appropriate dialogue
	if(hour >= 6 && hour < 12)
		return "Good morning! Did you sleep well?"
	else if(hour >= 12 && hour < 17)
		return "Good afternoon! Staying busy, I hope?"
	else if(hour >= 17 && hour < 21)
		return "Good evening! The day's work is nearly done."
	else
		return "It's quite late. Most folk are sleeping now."

// =============================================================================
// DEBUG VERBS FOR NPC ROUTINES
// =============================================================================

/mob/players/verb/ViewNPCRoutineStatus()
	set name = "View NPC Routine Status (Debug)"
	set category = "Debug"
	
	if(active_npc_routines.len == 0)
		src << "No NPCs registered for routines."
		return
	
	src << "\n<b>═══════════════════════════════════</b>"
	src << "<b>NPC ROUTINE STATUS</b>"
	src << "<b>═══════════════════════════════════</b>"
	
	for(var/datum/npc_routine/routine in active_npc_routines)
		var/mob/npcs/npc = routine.npc_ref
		if(npc)
			var/state = routine.GetRoutineState()
			var/awake = routine.IsNPCAwake() ? "Yes" : "No"
			var/shop = routine.IsShopOperating() ? "Open" : "Closed"
			
			src << "[npc.name]: State=[state], Awake=[awake], Shop=[shop]"
	
	src << "<b>═══════════════════════════════════</b>\n"

/mob/players/verb/SimulateNPCRoutineUpdate()
	set name = "Simulate NPC Update (Debug)"
	set category = "Debug"
	
	var/updated = 0
	for(var/datum/npc_routine/routine in active_npc_routines)
		routine.UpdateRoutineState()
		updated++
	
	src << "Updated [updated] NPC routines."

/mob/players/verb/TestNPCDialogue()
	set name = "Test NPC Time Dialogue (Debug)"
	set category = "Debug"
	
	var/time_dialogue = GetNPCDialogueByTime(hour)
	var/season_dialogue = GetNPCDialogueBySeason(season)
	
	src << "\n<b>DIALOGUE TEST</b>"
	src << "Time of Day: [GetTimeString()]"
	src << "Season: [season]"
	src << "Time Dialogue: [time_dialogue]"
	src << "Season Dialogue: [season_dialogue[1]]"
	src << "\n"

// =============================================================================
// INTEGRATION WITH TIMEADVANCEMENTSYSTEM
// =============================================================================

/proc/OnHourlyNPCCheck()
	// Called every game hour to update NPC states
	if(!active_npc_routines.len) return
	
	for(var/datum/npc_routine/routine in active_npc_routines)
		routine.UpdateRoutineState()

// Hook into TimeAdvancementSystem.OnHourChange()
// This is called automatically when hours change
