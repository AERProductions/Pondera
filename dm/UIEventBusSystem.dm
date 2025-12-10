// UIEventBusSystem.dm - Phase 35: UI Event Bus & Activity Log
// Centralized event notification and logging for all player activities

#define EVENT_PRIORITY_CRITICAL 1   // Combat, defections, defeats
#define EVENT_PRIORITY_HIGH 2       // Skill ups, recipe discoveries, battles
#define EVENT_PRIORITY_MEDIUM 3     // Transactions, crafting, harvesting
#define EVENT_PRIORITY_LOW 4        // Movement, item picks, general info

#define EVENT_CATEGORY_COMBAT "combat"
#define EVENT_CATEGORY_SKILL "skill"
#define EVENT_CATEGORY_RECIPE "recipe"
#define EVENT_CATEGORY_CRAFTING "crafting"
#define EVENT_CATEGORY_GATHERING "gathering"
#define EVENT_CATEGORY_ECONOMY "economy"
#define EVENT_CATEGORY_TERRITORY "territory"
#define EVENT_CATEGORY_OFFICER "officer"
#define EVENT_CATEGORY_BATTLE "battle"
#define EVENT_CATEGORY_SYSTEM "system"

// =============================================================================
// Activity Log Event Datum
// =============================================================================

/datum/activity_event
	var
		event_id              // Unique ID
		timestamp             // world.time when event occurred
		player_id             // Who experienced this event
		event_type            // Specific action (skill_up, recipe_discovered, etc)
		category              // Category for filtering
		priority              // 1=critical, 2=high, 3=medium, 4=low
		title                 // Short display title
		description           // Full event description
		icon_state            // Icon for UI display
		color                 // Hex color for text display
		data = list()         // Additional structured data

/datum/activity_event/New(type, cat, priority, title_text, desc, icon, hex_color, extra_data)
	src.event_id = "evt_[world.time]_[rand(1,99999)]"
	src.timestamp = world.time
	src.event_type = type
	src.category = cat
	src.priority = priority
	src.title = title_text
	src.description = desc
	src.icon_state = icon
	src.color = hex_color
	if(extra_data)
		for(var/key in extra_data)
			src.data[key] = extra_data[key]

// =============================================================================
// Player Activity Log Manager
// =============================================================================

/datum/player_activity_log
	var
		mob/player
		list/events = list()        // All events for this player
		max_events = 200            // Keep last 200 events
		list/filtered_events = list() // Cached filtered results
		last_filter = ""            // Last filter applied

/datum/player_activity_log/New(mob/P)
	src.player = P
	src.events = list()

/datum/player_activity_log/proc/AddEvent(datum/activity_event/event)
	if(!event)
		return
	
	event.player_id = player ? player.key : "unknown"
	
	events += event
	
	// Maintain max size
	if(events.len > max_events)
		events = events.Copy(2)  // Remove oldest
	
	// Update UI if player is online
	if(player && player.client)
		NotifyPlayerNewEvent(player, event)

/datum/player_activity_log/proc/NotifyPlayerNewEvent(mob/player, datum/activity_event/event)
	if(!player || !player.client)
		return
	
	// Show in status (top-right corner)
	var/notification_text = "<b style='color: [event.color];'>[event.title]</b><br>[event.description]"
	
	// For critical events, force notification
	if(event.priority <= EVENT_PRIORITY_HIGH)
		player << notification_text

/datum/player_activity_log/proc/GetEventsByCategory(category)
	var/list/results = list()
	for(var/datum/activity_event/event in events)
		if(event.category == category)
			results += event
	return results

/datum/player_activity_log/proc/GetEventsByPriority(priority)
	var/list/results = list()
	for(var/datum/activity_event/event in events)
		if(event.priority == priority)
			results += event
	return results

/datum/player_activity_log/proc/GetRecentEvents(count=20)
	if(events.len <= count)
		return events.Copy()
	return events.Copy(events.len - count + 1)

/datum/player_activity_log/proc/ClearOldEvents(older_than_ticks)
	var/list/kept = list()
	for(var/datum/activity_event/event in events)
		if(world.time - event.timestamp < older_than_ticks)
			kept += event
	events = kept

// =============================================================================
// Global Activity Log System
// =============================================================================

var
	list/player_activity_logs = list()    // mob -> /datum/player_activity_log

/proc/InitializeUIEventBus()
	if(!player_activity_logs)
		player_activity_logs = list()
	RegisterInitComplete("ui_event_bus")

/proc/GetPlayerActivityLog(mob/player)
	if(!player)
		return null
	
	var/key = player.key
	if(!player_activity_logs[key])
		player_activity_logs[key] = new /datum/player_activity_log(player)
	
	return player_activity_logs[key]

/proc/LogActivityEvent(mob/player, event_type, category, priority, title, description, icon="", color="#FFFFFF", extra_data=null)
	if(!player)
		return
	
	var/datum/player_activity_log/log = GetPlayerActivityLog(player)
	var/datum/activity_event/event = new(event_type, category, priority, title, description, icon, color, extra_data)
	
	log.AddEvent(event)
	return event

// =============================================================================
// Convenience Functions for Common Events
// =============================================================================

/proc/LogSkillUp(mob/player, skill_name, old_level, new_level)
	LogActivityEvent(
		player,
		"skill_up",
		EVENT_CATEGORY_SKILL,
		EVENT_PRIORITY_HIGH,
		"[skill_name] Leveled Up!",
		"[skill_name] increased from level [old_level] to [new_level]",
		"skill",
		"#00FF00",
		list("skill" = skill_name, "old_level" = old_level, "new_level" = new_level)
	)

/proc/LogRecipeDiscovered(mob/player, recipe_name, discovery_method)
	LogActivityEvent(
		player,
		"recipe_discovered",
		EVENT_CATEGORY_RECIPE,
		EVENT_PRIORITY_HIGH,
		"New Recipe Discovered!",
		"You discovered: [recipe_name] (via [discovery_method])",
		"recipe",
		"#FFFF00",
		list("recipe" = recipe_name, "method" = discovery_method)
	)

/proc/LogCraftingComplete(mob/player, recipe_name, quality)
	LogActivityEvent(
		player,
		"crafting_complete",
		EVENT_CATEGORY_CRAFTING,
		EVENT_PRIORITY_MEDIUM,
		"Crafting Complete",
		"Successfully crafted [recipe_name] (Quality: [quality]%)",
		"craft",
		"#88CCFF",
		list("recipe" = recipe_name, "quality" = quality)
	)

/proc/LogGatheringComplete(mob/player, resource_name, amount)
	LogActivityEvent(
		player,
		"gathering_complete",
		EVENT_CATEGORY_GATHERING,
		EVENT_PRIORITY_MEDIUM,
		"Gathered Resources",
		"Collected [amount]x [resource_name]",
		"gather",
		"#88FF88",
		list("resource" = resource_name, "amount" = amount)
	)

/proc/LogCombatVictory(mob/player, enemy_name, loot_gained)
	LogActivityEvent(
		player,
		"combat_victory",
		EVENT_CATEGORY_COMBAT,
		EVENT_PRIORITY_HIGH,
		"Combat Victory!",
		"Defeated [enemy_name]. Gained [loot_gained]",
		"combat",
		"#FF4444",
		list("enemy" = enemy_name, "loot" = loot_gained)
	)

/proc/LogCombatDefeat(mob/player, enemy_name, damage_taken)
	LogActivityEvent(
		player,
		"combat_defeat",
		EVENT_CATEGORY_COMBAT,
		EVENT_PRIORITY_CRITICAL,
		"Combat Defeat!",
		"Defeated by [enemy_name]. Took [damage_taken] damage.",
		"combat",
		"#FF0000",
		list("enemy" = enemy_name, "damage" = damage_taken)
	)

/proc/LogTransactionComplete(mob/player, transaction_type, amount, item_name)
	LogActivityEvent(
		player,
		"transaction",
		EVENT_CATEGORY_ECONOMY,
		EVENT_PRIORITY_MEDIUM,
		"Transaction Complete",
		"[transaction_type]: [amount]x [item_name]",
		"trade",
		"#FFD700",
		list("type" = transaction_type, "amount" = amount, "item" = item_name)
	)

/proc/LogTerritoryEvent(mob/player, event_type, territory_name, details)
	LogActivityEvent(
		player,
		"territory_" + event_type,
		EVENT_CATEGORY_TERRITORY,
		EVENT_PRIORITY_HIGH,
		"Territory Event: [territory_name]",
		details,
		"territory",
		"#FF8844",
		list("territory" = territory_name, "event" = event_type)
	)

/proc/LogOfficerEvent(mob/player, officer_name, event_type, details)
	LogActivityEvent(
		player,
		"officer_" + event_type,
		EVENT_CATEGORY_OFFICER,
		EVENT_PRIORITY_HIGH,
		"Officer: [officer_name]",
		details,
		"officer",
		"#AA44FF",
		list("officer" = officer_name, "event" = event_type)
	)

/proc/LogBattleEvent(mob/player, battle_type, territory_name, outcome)
	var/priority = outcome == "victory" ? EVENT_PRIORITY_HIGH : EVENT_PRIORITY_CRITICAL
	LogActivityEvent(
		player,
		"battle_" + battle_type,
		EVENT_CATEGORY_BATTLE,
		priority,
		"Battle: [territory_name]",
		"[battle_type] battle [outcome]",
		"battle",
		outcome == "victory" ? "#00FF00" : "#FF0000",
		list("territory" = territory_name, "type" = battle_type, "outcome" = outcome)
	)

/proc/LogSystemEvent(mob/player, event_type, message)
	LogActivityEvent(
		player,
		event_type,
		EVENT_CATEGORY_SYSTEM,
		EVENT_PRIORITY_MEDIUM,
		"System Event",
		message,
		"system",
		"#CCCCCC",
		list("type" = event_type)
	)

// =============================================================================
// Activity Log UI Display
// =============================================================================

/proc/ShowActivityLog(mob/M, category_filter="", priority_filter=0)
	if(!M)
		return
	
	var/datum/player_activity_log/log = GetPlayerActivityLog(M)
	if(!log)
		return
	
	var/html = "<html><head><title>Activity Log</title>"
	html += "<style>"
	html += "body { font-family: Arial, sans-serif; font-size: 12px; color: #FFF; background: #111; margin: 5px; }"
	html += ".header { font-weight: bold; font-size: 16px; border-bottom: 2px solid #FFF; margin-bottom: 10px; }"
	html += ".filter { margin-bottom: 10px; padding: 5px; background: #222; border: 1px solid #444; }"
	html += ".event { padding: 8px; margin: 3px 0; border-left: 3px solid #666; background: #1a1a1a; }"
	html += ".event-critical { border-left-color: #FF0000; background: #2a1a1a; }"
	html += ".event-high { border-left-color: #FF8800; }"
	html += ".event-medium { border-left-color: #FFFF00; }"
	html += ".event-low { border-left-color: #00FF00; }"
	html += ".event-title { font-weight: bold; }"
	html += ".event-time { font-size: 10px; color: #999; }"
	html += ".log-container { border: 1px solid #444; max-height: 600px; overflow-y: auto; padding: 5px; }"
	html += "a { color: #88CCFF; text-decoration: none; }"
	html += "a:hover { text-decoration: underline; }"
	html += "</style>"
	html += "</head><body>"
	
	html += "<div class='header'>📋 ACTIVITY LOG</div>"
	
	// Filter controls
	html += "<div class='filter'>"
	html += "<b>Filter by:</b><br>"
	html += "<a href='?src=\ref[M];action=view_log;category='>All Events</a> | "
	html += "<a href='?src=\ref[M];action=view_log;category=[EVENT_CATEGORY_SKILL]'>Skills</a> | "
	html += "<a href='?src=\ref[M];action=view_log;category=[EVENT_CATEGORY_RECIPE]'>Recipes</a> | "
	html += "<a href='?src=\ref[M];action=view_log;category=[EVENT_CATEGORY_COMBAT]'>Combat</a> | "
	html += "<a href='?src=\ref[M];action=view_log;category=[EVENT_CATEGORY_ECONOMY]'>Economy</a> | "
	html += "<a href='?src=\ref[M];action=view_log;category=[EVENT_CATEGORY_TERRITORY]'>Territory</a><br>"
	html += "<a href='?src=\ref[M];action=view_log;category=[EVENT_CATEGORY_BATTLE]'>Battles</a> | "
	html += "<a href='?src=\ref[M];action=view_log;category=[EVENT_CATEGORY_OFFICER]'>Officers</a>"
	html += "</div>"
	
	// Get events
	var/list/events = log.events
	if(category_filter)
		events = log.GetEventsByCategory(category_filter)
	
	// Display events (most recent first)
	html += "<div class='log-container'>"
	if(events.len == 0)
		html += "<div class='event'>No events found.</div>"
	else
		for(var/i = events.len to 1 step -1)
			var/datum/activity_event/event = events[i]
			var/priority_class = ""
			switch(event.priority)
				if(EVENT_PRIORITY_CRITICAL)
					priority_class = "event-critical"
				if(EVENT_PRIORITY_HIGH)
					priority_class = "event-high"
				if(EVENT_PRIORITY_MEDIUM)
					priority_class = "event-medium"
				else
					priority_class = "event-low"
			
			var/time_since = (world.time - event.timestamp) / 10
			var/time_text = "[time_since]s ago"
			
			html += "<div class='event [priority_class]'>"
			html += "<div class='event-title' style='color: [event.color];'>[event.title]</div>"
			html += "<div>[event.description]</div>"
			html += "<div class='event-time'>[time_text] • [event.category]</div>"
			html += "</div>"
	
	html += "</div>"
	
	html += "<div style='margin-top: 10px; text-align: center;'>"
	html += "<a href='?src=\ref[M];action=close_log'>Close</a>"
	html += "</div>"
	
	html += "</body></html>"
	
	M << browse(html, "window=activity_log;size=700x700")

// =============================================================================
// Activity Log Verb
// =============================================================================

/mob/players/verb/ViewActivityLog()
	set name = "Activity Log"
	set category = "Skills"
	
	ShowActivityLog(src)

// =============================================================================
// Topic Handler
// =============================================================================

/mob/players/Topic(href, list/href_list)
	..()
	
	if(href_list["action"] == "view_log")
		var/category = href_list["category"]
		ShowActivityLog(src, category)
	
	if(href_list["action"] == "close_log")
		src << browse(null, "window=activity_log")

// =============================================================================
// Integration with Existing Systems
// =============================================================================

/**
 * Hook into RecipeDiscovery
 * Called when player discovers new recipe
 */
/proc/OnRecipeDiscovered(mob/player, recipe_name, discovery_method)
	if(!player)
		return
	
	LogRecipeDiscovered(player, recipe_name, discovery_method)

/**
 * Hook into CombatSystem
 * Called when combat ends
 */
/proc/OnCombatEnd(mob/attacker, mob/defender, attacker_won)
	if(!attacker)
		return
	
	if(attacker_won)
		LogCombatVictory(attacker, defender.name, 0)
	else
		LogCombatDefeat(attacker, defender.name, 0)

/**
 * Hook into SiegeEventsSystem
 * Called when siege completes
 */
/proc/OnSiegeComplete(mob/player, territory_name, attacking_won)
	if(!player)
		return
	
	var/outcome = attacking_won ? "victory" : "defeat"
	LogBattleEvent(player, "siege", territory_name, outcome)

/**
 * Hook into CookingSystem
 * Called when recipe is completed
 */
/proc/OnRecipeCompleted(mob/player, recipe_name, quality_percent)
	if(!player)
		return
	
	LogCraftingComplete(player, recipe_name, quality_percent)

// =============================================================================
// Cleanup & Maintenance
// =============================================================================

/proc/CleanupActivityLogs()
	set background = 1
	set waitfor = 0
	
	// Every hour, clean up old events
	while(1)
		sleep(36000)  // 1 hour
		
		for(var/key in player_activity_logs)
			var/datum/player_activity_log/log = player_activity_logs[key]
			if(log)
				log.ClearOldEvents(180000)  // Keep last 30 minutes

// =============================================================================
// Testing & Debug Verbs
// =============================================================================

/mob/players/verb/TestActivityLog()
	set name = "Test Activity Log"
	set category = "Debug"
	
	// Log various test events
	LogSkillUp(src, "Fishing", 3, 4)
	LogRecipeDiscovered(src, "Grilled Fish", "NPC Teaching")
	LogCraftingComplete(src, "Iron Sword", 85)
	LogGatheringComplete(src, "Stone", 15)
	LogCombatVictory(src, "Goblin", "5 Gold")
	LogTerritoryEvent(src, "captured", "Northern Fields", "Successfully captured territory!")
	LogOfficerEvent(src, "recruited", "Marshal Jenkins", "New officer recruited and ready for duty")
	LogBattleEvent(src, "siege", "Castle Peak", "victory")
	
	src << "Test events logged. Check Activity Log."
