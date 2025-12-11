// DeathPenaltySystem.dm - Respawn mechanics, loot drops, and death consequences
// Implements permadeath risk (PvP), respawn timers, and loot drops for different game modes
// Integrates with CombatSystem, CharacterData, and DualCurrencySystem

var
	global/list/dead_players = list()  // Track players in "dead" state for respawn management
	global/datum/death_penalty_manager/death_penalty_manager = null

// ============================================================================
// DEATH PENALTY MANAGER
// ============================================================================

/datum/death_penalty_manager
	/**
	 * death_penalty_manager
	 * Global manager for death penalties, respawn timers, and permadeath tracking
	 */
	var
		list/death_records = list()  // death_ckey -> list of death records
		list/permadead_players = list()  // permadeath victims (ckey -> death_time)
		list/active_respawns = list()  // players waiting to respawn
		permadeath_enabled = FALSE  // Enable permadeath in PvP mode
		respawn_base_delay = 300  // 300 ticks = 15 seconds base respawn delay
		respawn_delay_per_level = 10  // Additional 10 ticks per level above 1
		loot_drop_rate = 1.0  // 100% chance to drop loot on death (adjustable per mode)
		max_death_records = 20  // Keep max 20 death records per player

	proc/InitializeDeathPenaltyManager()
		/**
		 * InitializeDeathPenaltyManager
		 * Boot death penalty system at world startup
		 */
		death_penalty_manager = src
		RegisterInitComplete("death_penalty_system")

	proc/HandlePlayerDeath(mob/players/player, mob/attacker)
		/**
		 * HandlePlayerDeath
		 * Primary death handler - applies penalties, triggers loot drop, schedules respawn
		 * 
		 * @param player: The player who died
		 * @param attacker: The mob/player who caused death (can be null for environmental)
		 */
		if(!player || !player.character) return
		
		// Record death
		RecordDeath(player, attacker)
		
		// Apply continent-specific death consequences
		var/datum/continent/cont = GetPlayerContinent(player)
		if(cont && cont.allow_pvp)
			// PvP continent - harsh penalties
			ApplyPvPDeathPenalty(player, attacker)
			if(permadeath_enabled)
				ApplyPermadeathRisk(player, attacker)
		else if(cont && !cont.allow_pvp)
			// Story/Sandbox - no permadeath, light penalties
			ApplyPvEDeathPenalty(player)
		
		// Drop loot on ground
		DropPlayerLoot(player, attacker)
		
		// Schedule respawn
		ScheduleRespawn(player)

	proc/RecordDeath(mob/players/player, mob/attacker)
		/**
		 * RecordDeath
		 * Log death in player's record (for statistics, bounty systems, etc)
		 */
		if(!death_records[player.ckey])
			death_records[player.ckey] = list()
		
		var/list/record = list(
			"time" = world.timeofday,
			"attacker_name" = attacker ? attacker.name : "Environmental",
			"attacker_type" = attacker ? attacker.type : "environment",
			"location" = player.loc,
			"level" = player.level,
			"xp_at_death" = player.exp
		)
		
		death_records[player.ckey] += list(record)
		
		// Trim old records if over limit
		if(death_records[player.ckey].len > max_death_records)
			var/start_idx = death_records[player.ckey].len - max_death_records + 1
			death_records[player.ckey] = death_records[player.ckey][start_idx..-1]

	proc/ApplyPvPDeathPenalty(mob/players/player, mob/attacker)
		/**
		 * ApplyPvPDeathPenalty
		 * PvP mode: Heavy penalties (XP loss, temporary stat debuff)
		 */
		// Combat XP loss (10% default, see CombatProgression.dm)
		if(player.character && player.character.combat_xp)
			var/xp_loss = round(player.character.combat_xp * 0.10)
			player.character.combat_xp -= max(0, xp_loss)
			player << "<span class='danger'>DEATH PENALTY: Lost [xp_loss] combat XP (10% loss)</span>"
		
		// Temporary stat debuff: -20% damage for 600 ticks (30 seconds)
		ApplyDeathDebuff(player, 600)
		
		// Notify attacker of kill
		if(attacker && istype(attacker, /mob/players))
			attacker << "<span class='good'>KILL: You defeated [player.name]</span>"

	proc/ApplyPvEDeathPenalty(mob/players/player)
		/**
		 * ApplyPvEDeathPenalty
		 * Story/Sandbox mode: Minor penalties (small XP loss, no permanent consequences)
		 */
		// Minimal XP loss (5% for story mode)
		if(player.character && player.character.combat_xp)
			var/xp_loss = round(player.character.combat_xp * 0.05)
			player.character.combat_xp -= max(0, xp_loss)
			player << "<span class='warning'>You lost [xp_loss] combat XP (5% loss)</span>"
		
		// Very short debuff: -10% damage for 180 ticks (9 seconds)
		ApplyDeathDebuff(player, 180)

	proc/ApplyDeathDebuff(mob/players/player, ticks)
		/**
		 * ApplyDeathDebuff
		 * Apply temporary damage penalty after death
		 * 
		 * @param player: Target player
		 * @param ticks: Duration of debuff (in world ticks, 25ms each)
		 */
		if(!player.character) return
		
		player.character.death_debuff_active = 1
		player.character.death_debuff_end_time = world.time + ticks
		player << "<span class='warning'>Death Debuff: -20% damage for [round(ticks / 40)] seconds</span>"
		
		spawn(ticks)
			if(player && player.character)
				player.character.death_debuff_active = 0

	proc/ApplyPermadeathRisk(mob/players/player, mob/attacker)
		/**
		 * ApplyPermadeathRisk
		 * PvP-only: Roll permadeath check based on level and attacker level
		 * Higher-level players have higher permadeath risk vs similar-level attackers
		 * 
		 * Formula: Base 5% + (player_level - attacker_level) * 2%
		 * Capped at 50% max
		 */
		if(!permadeath_enabled) return
		
		// Get attacker level (if attacker exists and has level)
		var/attacker_level = player.level  // Default: assume same level
		if(attacker && istype(attacker, /mob/players))
			var/mob/players/P = attacker
			attacker_level = P.level
		
		var/base_permadeath_chance = 5  // 5% base
		var/level_diff = player.level - attacker_level
		var/permadeath_chance = min(50, base_permadeath_chance + (level_diff * 2))
		
		if(prob(permadeath_chance))
			// Permanent death - player flagged as permadead
			permadead_players[player.ckey] = world.time
			player << "<span class='danger'>PERMADEATH: Your character has permanently died!</span>"
			world << "<span class='danger'><b>[player.name] has been permanently slain by [attacker ? attacker.name : "environmental hazard"]!</b></span>"
		else
			// Survived permadeath roll
			player << "<span class='good'>You survived permadeath! ([permadeath_chance]% chance was rolled)</span>"

	proc/DropPlayerLoot(mob/players/player, mob/attacker)
		/**
		 * DropPlayerLoot
		 * Drop percentage of player's inventory and currency on death
		 * Loot drops to ground at player's death location
		 * 
		 * Loot drop rates by mode:
		 * - PvP: 50% of inventory items + 25% of carried currency (harsh)
		 * - Story: 25% of inventory items + 10% of currency (moderate)
		 * - Sandbox: 0% (no drops in creative mode)
		 */
		var/datum/continent/cont = GetPlayerContinent(player)
		if(!cont) return
		
		var/item_drop_rate = 0
		var/currency_drop_rate = 0
		
		if(cont.allow_pvp && cont.allow_stealing)
			// PvP mode - harsh loot drops
			item_drop_rate = 0.50
			currency_drop_rate = 0.25
		else if(!cont.allow_pvp && cont.allow_building)
			// Story mode - moderate loot drops
			item_drop_rate = 0.25
			currency_drop_rate = 0.10
		// Sandbox (allow_building, !allow_pvp, !monster_spawn) - no drops
		
		if(item_drop_rate == 0 && currency_drop_rate == 0)
			return  // No drops in this mode
		
		// Drop currency from inventory
		if(player.lucre > 0 && prob(currency_drop_rate * 100))
			var/lucre_drop = round(player.lucre * currency_drop_rate)
			player.lucre -= lucre_drop
			world << "<span class='warning'>[player.name] dropped [lucre_drop] lucre on death!</span>"
		
		// Drop inventory items
		if(item_drop_rate > 0)
			for(var/obj/item/I in player.contents)
				if(prob(item_drop_rate * 100))
					I.loc = player.loc
					world << "<span class='warning'>[player.name] dropped [I.name]!</span>"

	proc/ScheduleRespawn(mob/players/player)
		/**
		 * ScheduleRespawn
		 * Schedule player respawn after configurable delay
		 * Respawn time increases with level
		 */
		if(permadead_players[player.ckey])
			// Permadead - no respawn
			player << "<span class='danger'>This character is permanently dead. Create a new character to continue.</span>"
			return
		
		var/respawn_delay = respawn_base_delay + (player.level * respawn_delay_per_level)
		active_respawns[player.ckey] = world.time + respawn_delay
		
		player << "<span class='info'>Respawning in [round(respawn_delay / 40)] seconds...</span>"
		
		spawn(respawn_delay)
			if(player && player.character)
				RespawnPlayer(player)

	proc/RespawnPlayer(mob/players/player)
		/**
		 * RespawnPlayer
		 * Restore player to full health and teleport to respawn location
		 */
		if(!player || !player.client) return
		
		// Reset vital stats
		player.HP = player.MAXHP
		player.stamina = player.MAXstamina
		player.icon = 'dmi/64/char.dmi'
		player.overlays = null
		player.needrev = 0
		player.nomotion = 0
		player.poisonD = 0
		player.poisoned = 0
		player.poisonDMG = 0
		
		// Teleport to respawn point (use default until continent respawn_location is defined)
		// TODO: Integrate with continent respawn locations when MultiWorldSystem is updated
		player.loc = locate(5, 6, 1)  // Default respawn location
		
		player.location = "Respawned"
		player << "<span class='good'>You have respawned!</span>"
		world << "<span class='info'>[player.name] has respawned.</span>"
		
		// Clear respawn record
		active_respawns -= player.ckey

	proc/GetPlayerDeathCount(player_ckey)
		/**
		 * GetPlayerDeathCount
		 * Query total death count for statistics
		 */
		if(!death_records[player_ckey])
			return 0
		return death_records[player_ckey].len

	proc/GetPlayerDeathRecord(player_ckey)
		/**
		 * GetPlayerDeathRecord
		 * Return list of death records for a player
		 */
		return death_records[player_ckey] || list()

	proc/IsPlayerPermadead(player_ckey)
		/**
		 * IsPlayerPermadead
		 * Check if player is permanently dead
		 */
		return permadead_players[player_ckey] != null

	proc/GetPermadeathTime(player_ckey)
		/**
		 * GetPermadeathTime
		 * Get time of permadeath (for graveyard/memorial features)
		 */
		return permadead_players[player_ckey]

	proc/AdminShowDeathStats(player_ckey)
		/**
		 * AdminShowDeathStats
		 * Admin command to view death statistics for a player
		 */
		var/list/records = GetPlayerDeathRecord(player_ckey)
		
		if(records.len == 0)
			return "<b>[player_ckey]</b>: No deaths recorded"
		
		var/output = "<b>Death Records for [player_ckey]</b> ([records.len] total deaths)\n"
		output += "────────────────────────────────────────────────\n"
		
		for(var/i = max(1, records.len - 4); i <= records.len; i++)  // Last 5 deaths
			var/list/record = records[i]
			output += "• [record["attacker_name"]] (Lv [record["level"]])\n"
		
		if(IsPlayerPermadead(player_ckey))
			output += "\n⚠️ <b>PERMANENTLY DEAD</b> as of [GetPermadeathTime(player_ckey)]"
		
		return output

	proc/AdminRespawnPlayer(player_ckey)
		/**
		 * AdminRespawnPlayer
		 * Admin command to force respawn a player
		 */
		for(var/mob/players/P in world)
			if(P.ckey == player_ckey)
				RespawnPlayer(P)
				return TRUE
		
		return FALSE

	proc/AdminResurrectPermadead(player_ckey)
		/**
		 * AdminResurrectPermadead
		 * Admin command to resurrect a permadead player
		 */
		permadead_players -= player_ckey
		return TRUE

// ============================================================================
// PLAYER PROCS
// ============================================================================

/mob/players/proc/ViewDeathStats()
	/**
	 * ViewDeathStats
	 * Player command to view their own death statistics
	 */
	set name = "Death Statistics"
	set category = "Info"
	
	var/list/records = death_penalty_manager.GetPlayerDeathRecord(ckey)
	
	if(records.len == 0)
		src << "<span class='info'>You haven't died yet. Keep it that way!</span>"
		return
	
	var/msg = "<b>Your Death Records</b> ([records.len] total)\n"
	msg += "────────────────────────────────────────\n"
	
	for(var/i = max(1, records.len - 9); i <= records.len; i++)  // Last 10 deaths
		var/list/record = records[i]
		msg += "• Killed by: [record["attacker_name"]]\n"
	
	src << msg

/mob/players/proc/RespawnWait()
	/**
	 * RespawnWait
	 * Display remaining respawn time
	 */
	set name = "Respawn Status"
	set category = "Info"
	
	if(!death_penalty_manager.active_respawns[ckey])
		src << "<span class='info'>You are not waiting to respawn.</span>"
		return
	
	var/respawn_time = death_penalty_manager.active_respawns[ckey]
	var/time_remaining = max(0, respawn_time - world.time)
	var/seconds = round(time_remaining / 40)
	
	src << "<span class='info'>Respawning in [seconds] seconds...</span>"

// ============================================================================
// ADMIN VERBS
// ============================================================================

/mob/verb/AdminShowDeathStats(player_ckey as text)
	/**
	 * AdminShowDeathStats
	 * Admin command: View death statistics for a player
	 */
	set name = "Show Death Stats"
	set category = "Admin"
	
	if(!check_admin(usr)) return
	
	var/output = death_penalty_manager.AdminShowDeathStats(player_ckey)
	src << output

/mob/verb/AdminRespawnPlayer(player_ckey as text)
	/**
	 * AdminRespawnPlayer
	 * Admin command: Force respawn a specific player
	 */
	set name = "Respawn Player"
	set category = "Admin"
	
	if(!check_admin(usr)) return
	
	if(death_penalty_manager.AdminRespawnPlayer(player_ckey))
		src << "[player_ckey] has been respawned."
		world << "<b>[src.name] respawned [player_ckey].</b>"
	else
		src << "[player_ckey] not found or not a player."

/mob/verb/AdminResurrectPermadead(player_ckey as text)
	/**
	 * AdminResurrectPermadead
	 * Admin command: Resurrect a permanently dead player
	 */
	set name = "Resurrect Permadead"
	set category = "Admin"
	
	if(!check_admin(usr)) return
	
	if(death_penalty_manager.AdminResurrectPermadead(player_ckey))
		src << "[player_ckey] has been resurrected."
		world << "<b>[src.name] resurrected [player_ckey].</b>"
	else
		src << "[player_ckey] not found in permadead list."

/mob/verb/AdminTogglePermadeath()
	/**
	 * AdminTogglePermadeath
	 * Admin command: Enable/disable permadeath mechanics globally
	 */
	set name = "Toggle Permadeath"
	set category = "Admin"
	
	if(!check_admin(usr)) return
	
	death_penalty_manager.permadeath_enabled = !death_penalty_manager.permadeath_enabled
	world << "<b>[src.name] [death_penalty_manager.permadeath_enabled ? "enabled" : "disabled"] permadeath.</b>"

/mob/verb/AdminSetRespawnDelay(delay as num)
	/**
	 * AdminSetRespawnDelay
	 * Admin command: Adjust base respawn delay (in seconds)
	 */
	set name = "Set Respawn Delay"
	set category = "Admin"
	
	if(!check_admin(usr)) return
	
	death_penalty_manager.respawn_base_delay = round(delay * 40)  // Convert seconds to ticks
	src << "Respawn delay set to [delay] seconds."
	world << "<b>[src.name] set respawn delay to [delay]s.</b>"

// ============================================================================
// INITIALIZATION
// ============================================================================

/proc/InitializeDeathPenaltySystem()
	/**
	 * InitializeDeathPenaltySystem
	 * Boot death penalty system (called from InitializationManager.dm)
	 */
	if(!death_penalty_manager)
		death_penalty_manager = new /datum/death_penalty_manager()
		death_penalty_manager.InitializeDeathPenaltyManager()

// ============================================================================
// HELPER PROCS
// ============================================================================

// Note: GetPlayerContinent is defined in MultiWorldIntegration.dm

/proc/GetPlayerKillCount(mob/players/player)
	/**
	 * GetPlayerKillCount
	 * Helper: Count kills attributed to this player from death records
	 */
	var/kill_count = 0
	
	for(var/ckey in death_penalty_manager.death_records)
		var/list/records = death_penalty_manager.death_records[ckey]
		for(var/list/record in records)
			if(record["attacker_name"] == player.name)
				kill_count++
	
	return kill_count
