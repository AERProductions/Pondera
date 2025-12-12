/// ============================================================================
/// SKILL PROGRESSION UI SYSTEM
/// System for visualizing character rank progression, experience bars, and
/// skill-based notifications. Integrated with UnifiedRankSystem.dm for rank
/// display and experience tracking.
///
/// Created: 12-11-25 11:15PM
/// ============================================================================

#define RANK_VISUAL_EMPTY    "░"
#define RANK_VISUAL_FILLED   "▓"
#define RANK_VISUAL_PARTIAL  "▒"
// MAX_RANK_LEVEL defined in !defines.dm
#define XP_LEVEL_SCALING     1.2  // XP requirement scales by 1.2x per level

/// ============================================================================
/// RANK EXPERIENCE TRACKER DATUM
/// ============================================================================

/datum/rank_experience
	var
		rank_type = ""           // Type of rank (RANK_FISHING, RANK_CRAFTING, etc.)
		current_level = 1        // Current level (1-5)
		current_exp = 0          // Current experience points
		total_exp_earned = 0     // Lifetime experience earned
		level_up_count = 0       // Total times leveled up

/datum/rank_experience/proc/GetExpForLevel(level)
	// Base exp: 100 per level, scales with level
	var/base_exp = 100
	var/cumulative = 0
	for(var/i = 1; i < level; i++)
		cumulative += round(base_exp * (XP_LEVEL_SCALING ** (i - 1)))
	return cumulative

/datum/rank_experience/proc/GetExpToNextLevel()
	if(current_level >= MAX_RANK_LEVEL)
		return 0
	var/next_level_total = GetExpForLevel(current_level + 1)
	var/current_level_total = GetExpForLevel(current_level)
	return next_level_total - current_level_total

/datum/rank_experience/proc/GetExpProgress()
	// Returns 0-100% for progress bar
	if(current_level >= MAX_RANK_LEVEL)
		return 100
	var/exp_needed = GetExpToNextLevel()
	var/exp_in_level = current_exp - GetExpForLevel(current_level)
	if(exp_needed <= 0)
		return 100
	return round((exp_in_level / exp_needed) * 100)

/datum/rank_experience/proc/GainExp(amount)
	// Add experience and check for level-up
	current_exp += amount
	total_exp_earned += amount
	
	// Check if we leveled up
	while(current_level < MAX_RANK_LEVEL)
		var/next_threshold = GetExpForLevel(current_level + 1)
		if(current_exp >= next_threshold)
			current_level++
			level_up_count++
		else
			break
	
	// Cap at max level
	if(current_level >= MAX_RANK_LEVEL)
		current_level = MAX_RANK_LEVEL

/datum/rank_experience/proc/GetProgressBar(width = 20)
	// Visual progress bar for HUD display
	var/progress = GetExpProgress()
	var/filled_blocks = round((progress / 100) * width)
	var/empty_blocks = width - filled_blocks
	
	var/bar = ""
	for(var/i = 1; i <= filled_blocks; i++)
		bar += RANK_VISUAL_FILLED
	for(var/i = 1; i <= empty_blocks; i++)
		bar += RANK_VISUAL_EMPTY
	
	return "[bar] [progress]%"

/// ============================================================================
/// SKILL PROGRESSION HUD ELEMENT
/// ============================================================================

/datum/skill_progression_hud
	var
		owner = null             // Reference to player mob
		visible = TRUE
		display_mode = "compact" // compact, detailed, hover
		update_interval = 5      // Update every 5 ticks
		last_update = 0

/datum/skill_progression_hud/proc/DisplayCompactUI(mob/player)
	// Minimal rank display (for corner HUD)
	var/html = "<div style='background: #1a1a1a; padding: 5px; border: 1px solid #666; margin: 5px; font-size: 0.8em; max-width: 200px;'>"
	html += "<b>Rank Progress</b><br>"
	
	// Show top 3 active ranks
	var/count = 0
	if("character" in player.vars)
		var/datum/character_data/char = player.vars["character"]
		if(istype(char))
			var/list/rank_types = list(RANK_FISHING, RANK_CRAFTING, RANK_MINING, RANK_SMITHING, RANK_BUILDING, RANK_GARDENING)
			for(var/rank_type in rank_types)
				if(count >= 3) break
				var/level = char.GetRankLevel(rank_type)
				var/rank_name = ConvertRankTypeToName(rank_type)
				html += "[rank_name]: Level [level]/[MAX_RANK_LEVEL]<br>"
				count++
	
	html += "</div>"
	return html

/datum/skill_progression_hud/proc/DisplayDetailedUI(mob/player)
	// Full rank and experience display
	var/html = "<html><head><title>Skill Progression</title><style>"
	html += "body { background: #0a0a0a; color: #ddd; font-family: monospace; }"
	html += ".rank-section { margin: 15px; padding: 10px; border: 1px solid #444; background: #1a1a1a; }"
	html += ".rank-name { font-weight: bold; color: #4fc3f7; }"
	html += ".level-bar { display: inline-block; width: 100px; height: 8px; background: #333; border: 1px solid #555; margin: 3px 0; }"
	html += ".level-fill { height: 100%; background: linear-gradient(to right, #4fc3f7, #81c784); transition: width 0.5s; }"
	html += ".stat { margin: 5px 0; font-size: 0.9em; }"
	html += "</style></head><body>"
	html += "<h2>Skill Progression</h2>"
	
	if("character" in player.vars)
		var/datum/character_data/char = player.vars["character"]
		if(istype(char))
			var/list/rank_types = list(
				RANK_FISHING = "Fishing",
				RANK_CRAFTING = "Crafting",
				RANK_MINING = "Mining",
				RANK_SMITHING = "Smithing",
				RANK_BUILDING = "Building",
				RANK_GARDENING = "Gardening",
				RANK_WOODCUTTING = "Woodcutting",
				RANK_DIGGING = "Digging",
				RANK_CARVING = "Carving",
				RANK_SPROUT_CUTTING = "Sprout Cutting",
				RANK_SMELTING = "Smelting",
				RANK_POLE = "Pole Crafting"
			)
			
			for(var/rank_type in rank_types)
				var/level = char.GetRankLevel(rank_type)
				var/progress = GetProgressBar(rank_type, char)
				html += "<div class='rank-section'>"
				html += "<span class='rank-name'>[rank_types[rank_type]]</span>"
				html += " (Level [level]/[MAX_RANK_LEVEL])<br>"
				html += "<div class='level-bar'><div class='level-fill' style='width: [progress]%'></div></div>"
				html += "<div class='stat'>Progress: [progress]%</div>"
				html += "</div>"
	
	html += "</body></html>"
	return html

/datum/skill_progression_hud/proc/GetProgressBar(rank_type, datum/character_data/char)
	// Get visual progress percentage for rank
	// For now, simplified: (level - 1) / MAX_RANK_LEVEL
	var/level = char.GetRankLevel(rank_type)
	return round(((level - 1) / MAX_RANK_LEVEL) * 100)

/datum/skill_progression_hud/proc/ConvertRankTypeToName(rank_type)
	var/static/rank_names = list(
		RANK_FISHING = "Fishing",
		RANK_CRAFTING = "Crafting",
		RANK_MINING = "Mining",
		RANK_SMITHING = "Smithing",
		RANK_BUILDING = "Building",
		RANK_GARDENING = "Gardening",
		RANK_WOODCUTTING = "Woodcutting",
		RANK_DIGGING = "Digging",
		RANK_CARVING = "Carving",
		RANK_SPROUT_CUTTING = "Sprout Cutting",
		RANK_SMELTING = "Smelting",
		RANK_POLE = "Pole Crafting"
	)
	return rank_names[rank_type] || "Unknown"

/// ============================================================================
/// LEVEL-UP NOTIFICATION SYSTEM
/// ============================================================================

/datum/level_up_notification
	var
		rank_type = ""
		new_level = 1
		skill_name = ""
		timestamp = 0
		display_duration = 100  // 5 seconds at 20 TPS

/datum/level_up_notification/proc/GetNotificationText()
	return "** [skill_name] RANK [new_level]! **"

/datum/level_up_notification/proc/GetDisplayHTML()
	var/html = "<div style='background: #2d5016; border: 2px solid #81c784; padding: 10px; margin: 10px; text-align: center; color: #c8e6c9; font-weight: bold; font-size: 1.2em; animation: pulse 0.5s;'>"
	html += "[GetNotificationText()]<br>"
	html += "<span style='font-size: 0.8em; color: #a5d6a7;'>New skills unlocked!</span>"
	html += "</div>"
	return html

/// ============================================================================
/// SKILL PROGRESSION UI SYSTEM COORDINATOR
/// ============================================================================

var/datum/skill_progression_ui_system/global_skill_ui_system

/proc/GetSkillProgressionUI()
	if(!global_skill_ui_system)
		global_skill_ui_system = new /datum/skill_progression_ui_system()
	return global_skill_ui_system

/datum/skill_progression_ui_system
	var
		player_huds = list()                // player → HUD datum mapping
		level_up_queue = list()            // Global queue of level-ups
		notification_cache = list()        // Display cache for notifications

/datum/skill_progression_ui_system/proc/CreatePlayerHUD(mob/player)
	// Initialize HUD for player login
	if(!(player.ckey in player_huds))
		player_huds[player.ckey] = new /datum/skill_progression_hud(player)
	return player_huds[player.ckey]

/datum/skill_progression_ui_system/proc/ShowSkillScreen(mob/player, mode = "detailed")
	// Display comprehensive skill progression UI
	var/datum/skill_progression_hud/hud = CreatePlayerHUD(player)
	
	var/html = ""
	if(mode == "compact")
		html = hud.DisplayCompactUI(player)
	else if(mode == "detailed")
		html = hud.DisplayDetailedUI(player)
	
	if(player.client)
		player.client << browse(html, "window=skillprogression;size=400x500")

/datum/skill_progression_ui_system/proc/NotifyLevelUp(mob/player, rank_type, new_level)
	// Queue and display level-up notification
	var/rank_name = ConvertRankTypeToName(rank_type)
	
	var/datum/level_up_notification/notification = new
	notification.rank_type = rank_type
	notification.new_level = new_level
	notification.skill_name = rank_name
	notification.timestamp = world.time
	
	level_up_queue += notification
	
	// Show notification to player
	if(player.client)
		player.client << notification.GetDisplayHTML()
	
	// Log to chat
	player << "<span style='color: #81c784;'>[notification.GetNotificationText()]</span>"

/datum/skill_progression_ui_system/proc/ConvertRankTypeToName(rank_type)
	var/static/rank_names = list(
		RANK_FISHING = "Fishing",
		RANK_CRAFTING = "Crafting",
		RANK_MINING = "Mining",
		RANK_SMITHING = "Smithing",
		RANK_BUILDING = "Building",
		RANK_GARDENING = "Gardening",
		RANK_WOODCUTTING = "Woodcutting",
		RANK_DIGGING = "Digging",
		RANK_CARVING = "Carving",
		RANK_SPROUT_CUTTING = "Sprout Cutting",
		RANK_SMELTING = "Smelting",
		RANK_POLE = "Pole Crafting"
	)
	return rank_names[rank_type] || "Unknown"

/datum/skill_progression_ui_system/proc/GetLevelUpHistory(mob/player, limit = 10)
	// Retrieve last N level-ups for this player
	var/list/history = list()
	var/count = 0
	
	// Scan queue backwards (most recent first)
	for(var/i = length(level_up_queue); i >= 1 && count < limit; i--)
		var/datum/level_up_notification/notif = level_up_queue[i]
		history += notif
		count++
	
	return history

/datum/skill_progression_ui_system/proc/GetSkillSummary(mob/player)
	// Return HTML summary of all skills and levels
	var/html = "<div style='background: #0a0a0a; color: #ddd; padding: 15px; border: 1px solid #555;'>"
	html += "<h3>Skill Summary</h3>"
	html += "<table style='width: 100%; border-collapse: collapse;'>"
	html += "<tr style='background: #1a1a1a; border-bottom: 1px solid #444;'>"
	html += "<th style='padding: 5px; text-align: left;'>Skill</th>"
	html += "<th style='padding: 5px;'>Level</th>"
	html += "<th style='padding: 5px;'>Progress</th>"
	html += "</tr>"
	
	if("character" in player.vars)
		var/datum/character_data/char = player.vars["character"]
		if(istype(char))
			var/list/rank_types = list(RANK_FISHING, RANK_CRAFTING, RANK_MINING, RANK_SMITHING, RANK_BUILDING, RANK_GARDENING)
			for(var/rank_type in rank_types)
				var/level = char.GetRankLevel(rank_type)
				var/rank_name = ConvertRankTypeToName(rank_type)
				var/progress = (level - 1) * 100 / MAX_RANK_LEVEL
				html += "<tr style='border-bottom: 1px solid #333;'>"
				html += "<td style='padding: 5px;'>[rank_name]</td>"
				html += "<td style='padding: 5px; text-align: center;'>[level]/[MAX_RANK_LEVEL]</td>"
				html += "<td style='padding: 5px;'><div style='background: #333; height: 12px; border: 1px solid #555; position: relative;'><div style='background: #4fc3f7; height: 100%; width: [progress]%;'></div></div></td>"
				html += "</tr>"
	
	html += "</table>"
	html += "</div>"
	return html

/datum/skill_progression_ui_system/proc/UnlockRecipeFromSkillReach(mob/player, rank_type, new_level)
	// Called when player reaches new rank level
	// Integrated with SkillRecipeUnlock.dm to auto-unlock recipes
	
	// Trigger recipe discovery
	if("character" in player.vars)
		var/datum/character_data/char = player.vars["character"]
		if(istype(char) && "recipe_state" in char.vars)
			var/datum/recipe_state/rs = char.vars["recipe_state"]
			if(istype(rs))
				// Find recipes matching this rank type + level requirement
				// This would integrate with RECIPES registry
				// For now, notify player of potential unlocks
				player << "<span style='color: #ffb74d;'>New recipes may be available at [ConvertRankTypeToName(rank_type)] rank [new_level]!</span>"

/datum/skill_progression_ui_system/proc/ClearOldNotifications()
	// Remove notifications older than 60 seconds
	var/current_time = world.time
	var/list/to_remove = list()
	for(var/i = 1; i <= length(level_up_queue); i++)
		var/datum/level_up_notification/notif = level_up_queue[i]
		if((current_time - notif.timestamp) > 600)  // 600 deciseconds = 60 seconds
			to_remove += i
	
	// Remove in reverse order to maintain indices
	for(var/i = length(to_remove); i >= 1; i--)
		level_up_queue[to_remove[i]] = null

// Background cleanup loop
proc/StartSkillProgressionUICleanup()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(100)  // Every 10 seconds
		var/datum/skill_progression_ui_system/ui = GetSkillProgressionUI()
		if(ui)
			ui.ClearOldNotifications()

/// ============================================================================
/// INTEGRATION WITH INITIALIZATION MANAGER
/// ============================================================================

proc/InitializeSkillProgressionUI()
	// Called from InitializationManager.dm Phase 5 (400 ticks)
	
	if(!world_initialization_complete)
		spawn(400)
			InitializeSkillProgressionUI()
		return
	
	// Initialize the global UI system
	GetSkillProgressionUI()
	
	// Start cleanup background loop
	StartSkillProgressionUICleanup()
	
	// Register initialization complete
	RegisterInitComplete("SkillProgressionUI")

/// ============================================================================
/// END SKILL PROGRESSION UI SYSTEM
/// ============================================================================
