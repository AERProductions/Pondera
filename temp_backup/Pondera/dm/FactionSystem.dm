// FactionSystem.dm - Phase 9 Faction Implementation
// Enables faction-based PvP, territory control, and alliance systems
// Integrates with CombatSystem.dm, MultiWorldIntegration.dm, PvPSystem.dm
// Uses faction_registry from RegionalConflictSystem.dm (shared global)

// ============================================================================
// FACTION CONSTANTS
// ============================================================================

#define FACTION_NONE 0
#define FACTION_CRIMSON 1      // Red faction (Chaotic)
#define FACTION_AZURE 2        // Blue faction (Lawful)
#define FACTION_EMERALD 3      // Green faction (Neutral)
#define FACTION_GOLD 4         // Gold faction (Mercenary)

// Faction configuration
var/list/global/FACTIONS = list(
	"crimson" = list(
		"id" = FACTION_CRIMSON,
		"name" = "Crimson Hand",
		"color" = "#FF3333",
		"alignment" = "chaotic",
		"description" = "A brutal faction of raiders and warlords"
	),
	"azure" = list(
		"id" = FACTION_AZURE,
		"name" = "Azure Order",
		"color" = "#3366FF",
		"alignment" = "lawful",
		"description" = "A disciplined order of knights and defenders"
	),
	"emerald" = list(
		"id" = FACTION_EMERALD,
		"name" = "Emerald Circle",
		"color" = "#33CC33",
		"alignment" = "neutral",
		"description" = "A balanced faction of traders and craftspeople"
	),
	"gold" = list(
		"id" = FACTION_GOLD,
		"name" = "Gold Legion",
		"color" = "#FFCC00",
		"alignment" = "mercenary",
		"description" = "Sell-swords and fortune-seekers"
	)
)

// ============================================================================
// FACTION DATA PERSISTENCE
// ============================================================================

// Uses faction_registry from RegionalConflictSystem.dm (global shared state)
// faction_registry tracks faction standings and member assignments

// ============================================================================
// FACTION SYSTEM INITIALIZATION
// ============================================================================

/proc/InitializeFactionSystem()
	/**
	 * Initialize faction system on world boot
	 * Called from InitializationManager.dm (Phase 4, tick 275)
	 * Coordinates with RegionalConflictSystem faction registry
	 */
	
	// Faction registry already initialized by RegionalConflictSystem
	// This proc just ensures faction constants are available and logs init
	world << "FACTION Faction System Initialized - Story mode PvP via factions enabled"
	
	return 1

// ============================================================================
// FACTION ASSIGNMENT & MANAGEMENT
// ============================================================================

/proc/AssignPlayerFaction(mob/players/player, faction_id)
	/**
	 * Assign player to a faction
	 * 
	 * @param player: Player to assign
	 * @param faction_id: Faction ID (FACTION_CRIMSON, etc.)
	 * @return: TRUE if successful
	 */
	
	if(!player || !player.character) return 0
	
	// Verify faction exists
	var/faction_found = 0
	for(var/key in FACTIONS)
		if(FACTIONS[key]["id"] == faction_id)
			faction_found = 1
			break
	if(!faction_found) return 0
	
	// Remove from old faction if applicable
	if(player.character.faction_id != FACTION_NONE)
		RemovePlayerFromFaction(player)
	
	// Assign to new faction
	player.character.faction_id = faction_id
	player.character.faction_standing = 0
	
	// Notify player
	var/faction_name = GetFactionName(faction_id)
	var/faction_color = GetFactionColor(faction_id)
	var/faction_desc = ""
	
	for(var/key in FACTIONS)
		if(FACTIONS[key]["id"] == faction_id)
			faction_desc = FACTIONS[key]["description"]
			break
	
	player << "<b><font color=[faction_color]>✦ You have joined [faction_name]!</font></b>"
	player << "<font color=[faction_color]>[faction_desc]</font>"
	
	// Log faction assignment
	faction_registry["[player.key]_faction"] = faction_id
	faction_registry["[player.key]_standing"] = 0
	faction_registry["[player.key]_join_time"] = world.timeofday
	
	return 1

/proc/RemovePlayerFromFaction(mob/players/player)
	/**
	 * Remove player from their current faction
	 * 
	 * @param player: Player to remove
	 * @return: TRUE if successful
	 */
	
	if(!player || !player.character) return 0
	
	var/old_faction = player.character.faction_id
	if(old_faction == FACTION_NONE) return 0
	
	var/faction_name = GetFactionName(old_faction)
	
	player.character.faction_id = FACTION_NONE
	player.character.faction_standing = 0
	
	player << "<font color=#FFAA00>You have left [faction_name]</font>"
	
	faction_registry["[player.key]_faction"] = FACTION_NONE
	return 1

/proc/GetPlayerFaction(mob/players/player)
	/**
	 * Get player's faction ID
	 * 
	 * @param player: Player to check
	 * @return: Faction ID or FACTION_NONE
	 */
	
	if(!player || !player.character) return FACTION_NONE
	return player.character.faction_id || FACTION_NONE

/proc/GetFactionName(faction_id)
	/**
	 * Get faction display name
	 * 
	 * @param faction_id: Faction ID
	 * @return: Faction name string
	 */
	
	for(var/key in FACTIONS)
		var/list/faction_info = FACTIONS[key]
		if(faction_info["id"] == faction_id)
			return faction_info["name"]
	
	return "Unknown"

/proc/GetFactionColor(faction_id)
	/**
	 * Get faction color code
	 * 
	 * @param faction_id: Faction ID
	 * @return: Hex color string (#RRGGBB)
	 */
	
	for(var/key in FACTIONS)
		var/list/faction_info = FACTIONS[key]
		if(faction_info["id"] == faction_id)
			return faction_info["color"]
	
	return "#FFFFFF"

// ============================================================================
// FACTION STANDING SYSTEM
// ============================================================================

/proc/ModifyFactionStanding(mob/players/player, faction_id, amount)
	/**
	 * Modify player's standing with a faction
	 * Standing ranges from -1000 (enemy) to +1000 (ally)
	 * 
	 * @param player: Player to modify
	 * @param faction_id: Target faction
	 * @param amount: Amount to add (negative = reduce standing)
	 * @return: New standing value
	 */
	
	if(!player || !player.character) return 0
	
	var/standing_key = "[player.key]_[faction_id]_standing"
	var/current = faction_registry[standing_key] || 0
	var/new_standing = clamp(current + amount, -1000, 1000)
	
	faction_registry[standing_key] = new_standing
	
	// Notify player of standing changes (if significant)
	if(abs(amount) >= 50)
		var/faction_name = GetFactionName(faction_id)
		var/change_text = amount > 0 ? "gained" : "lost"
		var/color = amount > 0 ? "#33FF33" : "#FF3333"
		player << "<font color=[color]>[faction_name]: Standing [change_text] ([abs(amount)] points) - Total: [new_standing]</font>"
	
	return new_standing

/proc/GetFactionStanding(mob/players/player, faction_id)
	/**
	 * Get player's standing with a faction
	 * 
	 * @param player: Player to check
	 * @param faction_id: Target faction
	 * @return: Standing value (-1000 to +1000)
	 */
	
	if(!player || !player.character) return 0
	
	var/standing_key = "[player.key]_[faction_id]_standing"
	return faction_registry[standing_key] || 0

// ============================================================================
// FACTION RELATIONSHIP CHECKING
// ============================================================================

/proc/AreFactionsAlly(faction_a, faction_b)
	/**
	 * Check if two factions are allies
	 * Currently: Same faction = ally, different = enemy
	 * Future: Allow formal alliances between factions
	 * 
	 * @param faction_a: First faction ID
	 * @param faction_b: Second faction ID
	 * @return: TRUE if allied
	 */
	
	if(faction_a == FACTION_NONE || faction_b == FACTION_NONE) return 0
	return faction_a == faction_b

/proc/AreFactionsEnemy(faction_a, faction_b)
	/**
	 * Check if two factions are enemies
	 * 
	 * @param faction_a: First faction ID
	 * @param faction_b: Second faction ID
	 * @return: TRUE if enemies
	 */
	
	if(faction_a == FACTION_NONE || faction_b == FACTION_NONE) return 0
	return faction_a != faction_b

/proc/CanFactionAttack(faction_a, faction_b)
	/**
	 * Check if faction A can attack faction B
	 * 
	 * @param faction_a: Attacking faction
	 * @param faction_b: Target faction
	 * @return: TRUE if attack allowed
	 */
	
	// Can always attack enemies
	if(AreFactionsEnemy(faction_a, faction_b))
		return TRUE
	
	// Cannot attack self or allies
	return FALSE

// ============================================================================
// FACTION STATUS DISPLAY
// ============================================================================

/proc/GetFactionStatus(mob/players/player)
	/**
	 * Get formatted faction status string for UI display
	 * 
	 * @param player: Player to check
	 * @return: Status string
	 */
	
	if(!player || !player.character) return "Not in a faction"
	
	var/faction_id = player.character.faction_id
	if(faction_id == FACTION_NONE) return "Not in a faction"
	
	var/faction_name = GetFactionName(faction_id)
	var/faction_color = GetFactionColor(faction_id)
	var/standing = GetFactionStanding(player, faction_id)
	
	var/standing_desc = "Neutral"
	if(standing >= 500) standing_desc = "Legendary"
	else if(standing >= 250) standing_desc = "Honored"
	else if(standing >= 100) standing_desc = "Respected"
	else if(standing >= 0) standing_desc = "Neutral"
	else if(standing >= -100) standing_desc = "Suspicious"
	else if(standing >= -250) standing_desc = "Hostile"
	else standing_desc = "Despised"
	
	return "<b><font color=[faction_color]>[faction_name]</font></b> ([standing_desc] - [standing] pts)"

// ============================================================================
// FACTION REGISTRY PERSISTENCE
// ============================================================================

/proc/SaveFactionRegistry()
	/**
	 * Faction registry persisted by RegionalConflictSystem
	 * This is a stub for compatibility
	 */
	
	// No action needed - RegionalConflictSystem handles persistence

/proc/LoadFactionRegistry()
	/**
	 * Faction registry loaded by RegionalConflictSystem
	 * This is a stub for compatibility
	 */
	
	// No action needed - RegionalConflictSystem handles persistence

// ============================================================================
// FACTION VERB COMMANDS
// ============================================================================

mob/players/verb/JoinFaction(faction_choice in list("Crimson Hand", "Azure Order", "Emerald Circle", "Gold Legion"))
	/**
	 * Player verb: Join a faction
	 * Can be called from faction recruitment NPCs or UI
	 */
	
	if(!src) return
	
	// Map choice to faction ID
	var/faction_id = FACTION_NONE
	switch(faction_choice)
		if("Crimson Hand") faction_id = FACTION_CRIMSON
		if("Azure Order") faction_id = FACTION_AZURE
		if("Emerald Circle") faction_id = FACTION_EMERALD
		if("Gold Legion") faction_id = FACTION_GOLD
	
	if(!faction_id)
		src << "Invalid faction choice"
		return
	
	// Check if already in a faction
	if(src.character.faction_id != FACTION_NONE)
		src << "You are already in a faction. Leave your current faction first."
		return
	
	AssignPlayerFaction(src, faction_id)

mob/players/verb/LeaveFaction()
	/**
	 * Player verb: Leave current faction
	 */
	
	if(!src) return
	
	if(src.character.faction_id == FACTION_NONE)
		src << "You are not in a faction"
		return
	
	RemovePlayerFromFaction(src)

mob/players/verb/FactionStatus()
	/**
	 * Player verb: Check faction status
	 */
	
	if(!src) return
	
	src << GetFactionStatus(src)
	
	// Show standings with all factions
	for(var/key in FACTIONS)
		var/list/faction_info = FACTIONS[key]
		var/standing = GetFactionStanding(src, faction_info["id"])
		src << " - [faction_info["name"]]: [standing] standing"

// ============================================================================
// ADMIN VERBS
// ============================================================================

mob/verb/AdminSetFaction(player_name as text, faction_name in list("Crimson Hand", "Azure Order", "Emerald Circle", "Gold Legion", "None"))
	/**
	 * Admin verb: Assign faction to player
	 */
	
	if(!check_admin(usr)) return
	
	var/mob/players/target = null
	for(var/mob/players/P in world)
		if(ckey(P.key) == ckey(player_name))
			target = P
			break
	
	if(!target)
		usr << "Player not found"
		return
	
	var/faction_id = FACTION_NONE
	switch(faction_name)
		if("Crimson Hand") faction_id = FACTION_CRIMSON
		if("Azure Order") faction_id = FACTION_AZURE
		if("Emerald Circle") faction_id = FACTION_EMERALD
		if("Gold Legion") faction_id = FACTION_GOLD
	
	if(faction_id != FACTION_NONE)
		AssignPlayerFaction(target, faction_id)
	else
		RemovePlayerFromFaction(target)
	
	usr << "Faction assignment processed"

mob/verb/AdminShowFactionRegistry()
	/**
	 * Admin verb: Show faction registry contents
	 */
	
	if(!check_admin(usr)) return
	
	var/output = "<b>FACTION REGISTRY</b>\n"
	output += "Total entries: [faction_registry.len]\n\n"
	
	for(var/key in faction_registry)
		output += "[key]: [faction_registry[key]]\n"
	
	usr << output
