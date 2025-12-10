// NPCDialogueShopHours.dm - Phase 38C: NPC Dialogue & Shop Hours Integration
// Integrates time-based shop hours enforcement, dialogue trees, and greeting systems

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================

/proc/GetCurrentGameHour()
	// Safely get current game hour from global time variables
	// Returns: 1-12 (12-hour format)
	// Uses global 'hour' variable from dm/time.dm
	return hour || 12

// =============================================================================
// SHOP HOURS ENFORCEMENT - Time-based shop accessibility
// =============================================================================

// Note: IsNPCShopOpen(), GetNPCShopStatus(), and CanPlayerBuyFromNPC() are defined in NPCFoodSupplySystem.dm
// This system provides dialogue, wake times, and advanced shop interactions
// that depend on the underlying shop hour checks

/proc/IsNPCAwake(npc_name)
	// Check if NPC is awake (not in sleeping hours)
	// Sleep schedule is configurable per NPC type
	
	if(!global_time_system)
		return 1  // Default to awake if time system not ready
	
	// Determine sleep schedule type by NPC name
	var/sleep_type = "typical"
	switch(npc_name)
		if("Baker")
			sleep_type = "early_riser"
		if("Fisher")
			sleep_type = "typical"
		if("Merchant")
			sleep_type = "night_owl"
		else
			sleep_type = "typical"
	
	var/sleep_sched = NPC_SLEEP_SCHEDULE[sleep_type]
	if(!sleep_sched)
		return 1  // Unknown sleep schedule, assume awake
	
	var/current_hour = GetCurrentGameHour()
	var/sleep_start = sleep_sched["start_hour"]
	var/sleep_end = sleep_sched["end_hour"]
	
	// Handle overnight sleep: 10 PM (22) to 6 AM (6)
	if(sleep_start > sleep_end)
		// Sleeping: 10 PM to 6 AM → awake if hour is between 6 and 22
		return (current_hour >= sleep_end && current_hour < sleep_start)
	else
		// Daytime sleep (rare)
		return !(current_hour >= sleep_start && current_hour < sleep_end)

// =============================================================================
// NPC DIALOGUE SYSTEM
// =============================================================================

// Greeting dialogue based on time of day
var/list/NPC_GREETINGS_BY_TIME = list(
	"early_morning" = list(  // 4 AM - 8 AM
		"Baker" = list(
			"*yawns and stretches* Time to get the ovens going!",
			"Another early morning... the bread waits for no one.",
			"*preparing dough with practiced hands*"
		),
		"Fisher" = list(
			"The fish are biting best at dawn.",
			"*checking fishing nets*",
			"A good catch awaits those who start early!"
		)
	),
	"morning" = list(  // 8 AM - 12 PM
		"Blacksmith" = list(
			"*hammer rings against anvil*",
			"Need something forged? I'm available!",
			"The forge is hot and ready."
		),
		"Merchant" = list(
			"Welcome to my shop! Browse my wares.",
			"*arranging goods on shelves*",
			"Looking for anything in particular?"
		),
		"Herbalist" = list(
			"*grinding herbs into powder*",
			"My remedies are fresh today.",
			"What ailment brings you here?"
		)
	),
	"afternoon" = list(  // 12 PM - 5 PM
		"Innkeeper" = list(
			"Welcome! Can I offer you refreshment?",
			"*wiping down the bar*",
			"We have cold ale and hot stew today."
		),
		"Merchant" = list(
			"Business is brisk today!",
			"*tallying up sales*",
			"Anything catch your eye?"
		)
	),
	"evening" = list(  // 5 PM - 9 PM
		"Baker" = list(
			"*closing up shop for the night*",
			"All the bread is sold for today.",
			"Come back tomorrow for fresh loaves!"
		),
		"Innkeeper" = list(
			"*serving dinner to patrons*",
			"The evening crowd is just arriving.",
			"Care for a meal and a drink?"
		)
	),
	"night" = list(  // 9 PM - 4 AM
		"generic" = list(
			"*yawns widely*",
			"Shouldn't you be sleeping?",
			"*rubs eyes sleepily*"
		)
	)
)

// Dialogue based on season (flavor text and hints)
var/list/NPC_DIALOGUE_BY_SEASON = list(
	"Spring" = list(
		"Blacksmith" = list(
			"The fields are greening. Good time for plowing tools.",
			"Spring repairs are in high demand."
		),
		"Herbalist" = list(
			"The spring herbs are coming in beautifully.",
			"Fresh plants have the strongest potency."
		),
		"Baker" = list(
			"More people travel in spring. Business is good!",
			"Spring flour is the finest of the year."
		)
	),
	"Summer" = list(
		"Blacksmith" = list(
			"It's hot enough! The forge barely adds to the heat.",
			"Harvest tools need reinforcement before the season."
		),
		"Fisher" = list(
			"The water is warm. Fish are everywhere!",
			"Summer is prime fishing season."
		),
		"Baker" = list(
			"The heat makes baking difficult. Early mornings only.",
			"Summer brings berries for special loaves."
		)
	),
	"Autumn" = list(
		"Merchant" = list(
			"Autumn is harvest season. Business booms!",
			"Everyone's buying and trading produce."
		),
		"Herbalist" = list(
			"Autumn plants are rich with nutrients for winter stores.",
			"This is harvest time for my ingredients."
		),
		"Baker" = list(
			"Autumn grains make the best bread.",
			"I prepare extra stores for the long winter."
		)
	),
	"Winter" = list(
		"Innkeeper" = list(
			"Winter brings many travelers seeking warmth.",
			"Hot stew and warm beds fill the inn these days."
		),
		"Baker" = list(
			"Winter flour is scarce. Prices are up.",
			"The stored bread feeds the whole town now."
		),
		"Fisher" = list(
			"Winter fishing is dangerous. I take few trips.",
			"*shivers* The cold makes the work harder."
		)
	)
)

// Dialogue when food supply is low (triggers warnings)
var/list/NPC_SUPPLY_WARNING_DIALOGUE = list(
	"Baker" = list(
		"I'm running low on flour! Need a grain shipment soon.",
		"At this rate, I'll have no bread to bake by week's end.",
		"*nervously checking stores* We need grain, or the town starves!"
	),
	"Merchant" = list(
		"Supplies are running thin. We need a caravan soon.",
		"*frowning at inventory* Stock is dangerously low.",
		"If we don't restock soon, prices will skyrocket."
	),
	"Innkeeper" = list(
		"We're running low on food for the inn.",
		"*checking pantry worriedly* Need restocking soon.",
		"The travelers keep coming but stores keep shrinking."
	)
)

/proc/GetNPCGreeting(npc_name, time_of_day_override = null)
	// Get a random greeting based on NPC name and current time
	// time_of_day_override: "early_morning", "morning", "afternoon", "evening", "night"
	
	var/time_of_day = time_of_day_override || GetTimeOfDay()
	
	var/greeting_list = NPC_GREETINGS_BY_TIME[time_of_day]
	if(!greeting_list)
		return "[npc_name] nods to you."  // Default fallback
	
	var/npc_dialogue = greeting_list[npc_name]
	if(!npc_dialogue)
		npc_dialogue = greeting_list["generic"]  // Fallback to generic
	
	var/list_len = length(npc_dialogue)
	if(!npc_dialogue || !list_len)
		return "[npc_name] nods to you."  // Ultimate fallback
	
	return pick(npc_dialogue)  // Return random greeting

/proc/GetNPCSeasonalDialogue(npc_name)
	// Get a random seasonal greeting based on current season
	// Uses global 'season' variable from dm/time.dm
	
	var/current_season = season || "Spring"
	var/season_dialogue = NPC_DIALOGUE_BY_SEASON[current_season]
	if(!season_dialogue)
		return "[npc_name] has nothing particular to say."
	
	var/npc_dialogue = season_dialogue[npc_name]
	if(!npc_dialogue)
		return "[npc_name] has nothing particular to say."
	
	var/list_len = length(npc_dialogue)
	if(!list_len)
		return "[npc_name] has nothing particular to say."
	
	return pick(npc_dialogue)  // Return random seasonal dialogue

/proc/GetNPCSupplyWarningDialogue(npc_name)
	// Get warning dialogue when food supply is low
	
	var/warning_list = NPC_SUPPLY_WARNING_DIALOGUE[npc_name]
	if(!warning_list)
		return null  // No warning for this NPC
	
	var/list_len = length(warning_list)
	if(!list_len)
		return null  // Empty list
	
	return pick(warning_list)

/proc/GetTimeOfDay()
	// Classify current time into periods: early_morning, morning, afternoon, evening, night
	
	if(!global_time_system)
		return "morning"  // Default
	
	var/current_hour = GetCurrentGameHour()
	
	switch(current_hour)
		if(4 to 7)
			return "early_morning"
		if(8 to 11)
			return "morning"
		if(12 to 16)
			return "afternoon"
		if(17 to 20)
			return "evening"
		else
			return "night"  // 21-3

/proc/BroadcastShopOpeningMessage(npc_name)
	// Broadcast when an NPC opens their shop
	
	var/message = "[npc_name]'s shop is now open for business!"
	if(global_seasonal_weather)
		message += " Weather: [global_seasonal_weather.current_weather]"
	
	// Broadcast to all logged-in players
	for(var/mob/players/P in world)
		if(P && P.client)
			P << message

/proc/BroadcastShopClosingMessage(npc_name)
	// Broadcast when an NPC closes their shop
	
	var/message = "[npc_name]'s shop is now closing for the day."
	
	// Broadcast to all logged-in players
	for(var/mob/players/P in world)
		if(P && P.client)
			P << message

// =============================================================================
// NPC INTERACTION PROCS (Integration hooks for click interactions)
// =============================================================================

/proc/NPCClickDialogue(mob/player, npc_name)
	// Called when player clicks on an NPC
	// Displays greeting, shop status, and options
	
	if(!IsNPCAwake(npc_name))
		player << "[npc_name] is sleeping. Come back later."
		return
	
	var/greeting = GetNPCGreeting(npc_name)
	player << greeting
	
	// Show shop status if shop is available
	var/shop_status = GetNPCShopStatus(npc_name)
	player << shop_status
	
	// If food supply is low, NPC complains
	if(global_town_food_supply)
		var/warning = GetNPCSupplyWarningDialogue(npc_name)
		if(warning)
			player << warning

/proc/NPCClickTrade(mob/player, npc_name)
	// Called when player tries to trade with NPC
	
	if(!CanPlayerBuyFromNPC(player, npc_name))
		if(!IsNPCAwake(npc_name))
			player << "[npc_name] is sleeping. Come back during shop hours."
		else
			var/hours = NPC_SHOP_HOURS[npc_name]
			if(hours)
				player << "[npc_name]'s shop is closed. Hours: [hours["open_hour"]][hours["open_ampm"]] - [hours["close_hour"]][hours["close_ampm"]]"
			else
				player << "[npc_name] is not available for trading right now."
		return 0
	
	// Player can trade
	player << "You open trade window with [npc_name]."
	return 1

// =============================================================================
// INITIALIZATION & INTEGRATION
// =============================================================================

/proc/InitializeNPCDialogueSystem()
	// Called from InitializationManager at T+366
	// No background loop needed - hooks into TimeAdvancementSystem callbacks
	
	// Register callback for hourly shop status checks
	// OnHourlyNPCShopCheck() will be called from TimeAdvancementSystem
	
	return 1  // Success

// =============================================================================
// HOURLY SHOP CHECK (called from TimeAdvancementSystem.OnHourChange)
// This complements the existing OnHourlyNPCCheck() in NPCRoutineSystem
// =============================================================================

/proc/OnHourlyNPCShopCheck()
	// Called from TimeAdvancementSystem.OnHourChange() every hour
	// Checks if any NPC shops should open or close
	
	if(!global_time_system)
		return
	
	var/current_hour = GetCurrentGameHour()
	
	// Check each NPC type
	for(var/npc_name in NPC_SHOP_HOURS)
		var/hours = NPC_SHOP_HOURS[npc_name]
		if(!hours)
			continue
		
		var/open_hour = hours["open_hour"]
		var/close_hour = hours["close_hour"]
		
		// NPC is opening
		if(current_hour == open_hour)
			BroadcastShopOpeningMessage(npc_name)
		
		// NPC is closing
		if(current_hour == close_hour)
			BroadcastShopClosingMessage(npc_name)

// Debug verbs for testing
/mob/verb/ViewNPCShopHours()
	set category = "Debug"
	set name = "NPC Shop Hours"
	
	var/msg = "=== NPC SHOP HOURS ===\n"
	for(var/npc_name in NPC_SHOP_HOURS)
		var/hours = NPC_SHOP_HOURS[npc_name]
		msg += "[npc_name]: [hours["open_hour"]][hours["open_ampm"]] - [hours["close_hour"]][hours["close_ampm"]] | Open: [IsNPCShopOpen(npc_name)] | Awake: [IsNPCAwake(npc_name)]\n"
	
	src << msg
