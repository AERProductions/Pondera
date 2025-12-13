// DeathPenaltySystem.dm - Two-Death System with Fainted State
// Implements original design: First death = fainted state (waitable for revival)
// Second death = permanent (requires new character)
// Revival via Abjure spell prevents second death counter increment

var
	global/list/dead_players = list()  // Track players in "dead" state for respawn management
	global/datum/death_penalty_manager/death_penalty_manager = null

// ============================================================================
// DEATH PENALTY MANAGER
// ============================================================================

/datum/death_penalty_manager
	/**
	 * death_penalty_manager
	 * Global manager for death penalties, fainted state, and two-death system
	 */
	var/list/death_records = list()  // death_ckey -> list of death records
	var/list/fainted_players = list()  // players currently in fainted state (ckey -> faint_location)
	var/list/permadead_players = list()  // second-death victims (ckey -> death_time)
	var/max_death_records = 20  // Keep max 20 death records per player

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
		 * Primary death handler - applies fainted state OR permanent death
		 * Integrated with Lives system for per-continent lives tracking
		 * 
		 * @param player: The player who died
		 * @param attacker: The mob/player who caused death (can be null for environmental)
		 */
		if(!player || !player.character) return
		
		// Record death
		RecordDeath(player, attacker)
		
		// Get server difficulty config and determine consequence
		var/datum/server_difficulty_config/config = GetServerDifficultyConfig()
		if(!config)
			// Fallback: Initialize if not ready
			InitializeServerDifficultyConfig()
			config = GetServerDifficultyConfig()
		
		// Apply Lives system logic (per-continent tracking)
		var/consequence = ApplyLivesSystemLogic(player, attacker)
		
		if(consequence == "reset")
			// PERMANENT DEATH: Character hard reset with skill preservation
			ResetCharacterOnDeath(player)
		else if(consequence == "fainted")
			// FAINTED STATE: Awaitable for revival (standard two-death system)
			ApplyFaintedState(player, attacker)
		else
			// Fallback to original two-death system if lives system unavailable
			player.character.death_count++
			if(player.character.death_count >= 2)
				ApplyPermanentDeath(player, attacker)
			else
				ApplyFaintedState(player, attacker)

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
			"xp_at_death" = player.exp,
			"death_count" = player.character.death_count + 1
		)
		
		death_records[player.ckey] += list(record)
		
		// Trim old records if over limit
		if(death_records[player.ckey].len > max_death_records)
			var/start_idx = death_records[player.ckey].len - max_death_records + 1
			var/list/trimmed = death_records[player.ckey].Copy(start_idx)
			death_records[player.ckey] = trimmed

	proc/ApplyFaintedState(mob/players/player, mob/attacker)
		/**
		 * ApplyFaintedState
		 * First death: Player enters fainted state on current map location
		 * Awaitable by other players for revival via Abjure spell
		 * Player cannot move, act, or interact while fainted
		 */
		if(!player) return
		
		// Mark as fainted
		player.character.is_fainted = 1
		fainted_players[player.ckey] = player.loc
		
		// Visual change: Fainted icon state (overlay on ground)
		player.icon_state = "fainted"
		player.layer = TURF_LAYER  // On ground level, visible to other players
		player.opacity = 0
		player.density = 0  // Other players can move through fainted body
		
		// Disable player controls
		player.nomotion = 1  // Prevent movement
		player.client.perspective = EYE_PERSPECTIVE  // Allow looking around while fainted
		
		// Apply continent-specific penalties
		var/datum/continent/cont = GetPlayerContinent(player)
		if(cont && cont.allow_pvp)
			// PvP continent - XP loss on faint
			ApplyPvPDeathPenalty(player, attacker)
		else if(cont && !cont.allow_pvp)
			// Story/Sandbox - light XP loss
			ApplyPvEDeathPenalty(player)
		
		// Drop loot on ground (30% in PvP, 10% in Story, 0% Sandbox)
		DropPlayerLoot(player, attacker)
		
		// Notify player and world
		player << "<span class='danger'>FAINTED: You have fallen in combat. Another player can revive you with Abjure I spell.</span>"
		world << "<span class='warning'>[player.name] has fainted!</span>"
		
		// Notify attacker of successful kill (not permadeath, but faint)
		if(attacker && istype(attacker, /mob/players))
			attacker << "<span class='good'>You defeated [player.name] (1st death)</span>"

	proc/ApplyPermanentDeath(mob/players/player, mob/attacker)
		/**
		 * ApplyPermanentDeath
		 * Second death: Permanent, character cannot be revived
		 * Character must be deleted or moved to afterlife
		 */
		if(!player) return
		
		// Mark as permanently dead
		permadead_players[player.ckey] = world.time
		
		// Apply harsh penalties (final death)
		player.character.is_fainted = 2  // Flag as permanently dead
		player.icon_state = "dead"
		player.layer = TURF_LAYER - 1  // Below ground level
		player.density = 0
		player.opacity = 0
		
		// Drop all remaining loot
		DropAllPlayerLoot(player)
		
		// Notify player and world
		player << "<span class='danger'>PERMANENTLY DEAD: Your character has been slain. Create a new character to continue.</span>"
		world << "<span class='danger'><b>[player.name] has been permanently slain by [attacker ? attacker.name : "environmental hazard"]!</b></span>"
		
		// Notify attacker of kill
		if(attacker && istype(attacker, /mob/players))
			attacker << "<span class='good'>KILL: You permanently defeated [player.name]!</span>"

	proc/RevivePlayer(mob/players/player, mob/players/reviver)
		/**
		 * RevivePlayer
		 * Revive fainted player via Abjure spell or admin command
		 * Integrated with Lives system: respawns at continent rally point
		 * Resets death_count to prevent second death counter increment
		 * 
		 * @param player: The fainted player
		 * @param reviver: The player casting Abjure (nil if admin revive)
		 */
		if(!player || !player.character) return
		if(!player.character.is_fainted) 
			if(reviver) reviver << "That player is not fainted."
			return
		
		if(player.character.is_fainted >= 2)
			if(reviver) reviver << "That player is permanently dead and cannot be revived."
			return
		
		// Reset fainted state
		player.character.is_fainted = 0
		fainted_players -= player.ckey
		
		// Determine current continent for rally point respawn
		var/datum/continent/cont = GetPlayerContinent(player)
		var/continent_name = cont ? cont.name : "story"  // Default to story
		
		// Respawn at continent rally point via Lives system
		RespawnAfterRevival(player, continent_name)
		
		// Reset death count (this faint doesn't count toward second death)
		player.character.death_count = 0
		
		// Restore player visuals and controls
		player.icon = 'dmi/64/char.dmi'
		player.icon_state = ""
		player.overlays = null
		player.nomotion = 0  // Re-enable movement
		player.density = 1
		player.opacity = 0
		player.layer = MOB_LAYER
		
		// Restore vital stats (partial)
		player.HP = round(player.MAXHP * 0.25)  // Revived at 25% HP
		player.stamina = round(player.MAXstamina * 0.25)  // Revived at 25% stamina
		
		// Notification
		player << "<span class='good'>You have been revived at a rally point!</span>"
		if(reviver)
			world << "<span class='good'>[reviver.name] has revived [player.name]!</span>"
		else
			world << "<span class='good'>[player.name] has been revived!</span>"

	proc/ApplyPvPDeathPenalty(mob/players/player, mob/attacker)
		/**
		 * ApplyPvPDeathPenalty
		 * PvP mode: XP loss on faint
		 */
		if(!player.character || !player.character.combat_xp) return
		
		var/xp_loss = round(player.character.combat_xp * 0.10)  // 10% loss
		player.character.combat_xp -= max(0, xp_loss)
		player << "<span class='danger'>FAINT PENALTY: Lost [xp_loss] combat XP (10% loss)</span>"

	proc/ApplyPvEDeathPenalty(mob/players/player)
		/**
		 * ApplyPvEDeathPenalty
		 * Story/Sandbox mode: Light XP loss on faint
		 */
		if(!player.character || !player.character.combat_xp) return
		
		var/xp_loss = round(player.character.combat_xp * 0.05)  // 5% loss
		player.character.combat_xp -= max(0, xp_loss)
		player << "<span class='warning'>You lost [xp_loss] combat XP (5% loss)</span>"

	proc/DropPlayerLoot(mob/players/player, mob/attacker)
		/**
		 * DropPlayerLoot
		 * Drop percentage of player's inventory and currency on faint
		 * Loot drops to ground at player's faint location
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
			world << "<span class='warning'>[player.name] dropped [lucre_drop] lucre on faint!</span>"
		
		// Drop inventory items
		if(item_drop_rate > 0)
			for(var/obj/item/I in player.contents)
				if(prob(item_drop_rate * 100))
					I.loc = player.loc
					world << "<span class='warning'>[player.name] dropped [I.name]!</span>"

	proc/DropAllPlayerLoot(mob/players/player)
		/**
		 * DropAllPlayerLoot
		 * Drop ALL player inventory and currency on permanent death
		 */
		if(!player) return
		
		// Drop ALL currency
		if(player.lucre > 0)
			world << "<span class='danger'>[player.name] dropped ALL [player.lucre] lucre on death!</span>"
			player.lucre = 0
		
		// Drop ALL inventory items
		for(var/obj/item/I in player.contents)
			I.loc = player.loc
			world << "<span class='danger'>[player.name] dropped [I.name]!</span>"

	proc/GetPlayerDeathCount(ckey)
		/**
		 * GetPlayerDeathCount
		 * Query player's death count for UI display
		 */
		// Query character data from save
		return 0  // TODO: Load from character data

	proc/GetPlayerDeathRecord(ckey)
		/**
		 * GetPlayerDeathRecord
		 * Get most recent death record for player
		 */
		if(!death_records[ckey]) return null
		if(death_records[ckey].len == 0) return null
		return death_records[ckey][-1]

	proc/IsPlayerPermadead(ckey)
		/**
		 * IsPlayerPermadead
		 * Check if player is permanently dead (second death)
		 */
		return permadead_players[ckey] ? 1 : 0

	proc/IsFainted(ckey)
		/**
		 * IsFainted
		 * Check if player is currently in fainted state
		 */
		return fainted_players[ckey] ? 1 : 0

	proc/GetFaintLocation(ckey)
		/**
		 * GetFaintLocation
		 * Get location where player fainted
		 */
		return fainted_players[ckey]

	proc/AdminShowDeathStats(ckey)
		/**
		 * AdminShowDeathStats
		 * Display death statistics for admin review
		 */
		var/record = GetPlayerDeathRecord(ckey)
		if(!record)
			return "No death records for [ckey]"
		
		return "<b>Death Record for [ckey]</b><br>\
			Time: [record["time"]]<br>\
			Attacker: [record["attacker_name"]]<br>\
			Location: [record["location"]]<br>\
			Level at Death: [record["level"]]<br>\
			XP at Death: [record["xp_at_death"]]<br>\
			Death Count: [record["death_count"]]"

	proc/AdminRespawnPlayer(ckey)
		/**
		 * AdminRespawnPlayer
		 * Admin command to force respawn fainted player
		 */
		var/mob/players/player = null
		for(var/mob/players/P in world)
			if(P.ckey == ckey)
				player = P
				break
		
		if(!player)
			return "Player [ckey] not found"
		
		if(!player.character.is_fainted)
			return "[player.name] is not fainted"
		
		RevivePlayer(player, null)
		return "[player.name] has been revived"

	proc/AdminResurrectPermadead(ckey)
		/**
		 * AdminResurrectPermadead
		 * Admin command to resurrect permanently dead player
		 */
		permadead_players -= ckey
		
		// Find player in world
		var/mob/players/player = null
		for(var/mob/players/P in world)
			if(P.ckey == ckey)
				player = P
				break
		
		if(player)
			player.character.is_fainted = 0
			RevivePlayer(player, null)
			return "[player.name] has been resurrected"
		
		return "[ckey] has been resurrected (not currently online)"

// ============================================================================
// MOB/PLAYERS PROCS
// ============================================================================

/mob/players/proc/ViewDeathStats()
	/**
	 * ViewDeathStats
	 * Player verb to check their own death statistics
	 */
	set hidden = 1
	if(!death_penalty_manager) return
	
	var/list/all_records = death_penalty_manager.death_records[ckey]
	if(!all_records || all_records.len == 0)
		usr << "You have not died yet."
		return
	
	var/output = "<b>Your Death Statistics</b><br>"
	output += "Total Deaths: [all_records.len]<br>"
	output += "Current Death Count: [character.death_count]<br><br>"
	
	for(var/i = 1 to all_records.len)
		var/record = all_records[i]
		output += "<b>Death #[i]:</b> [record["time"]]<br>"
		output += "Attacker: [record["attacker_name"]]<br>"
		output += "---<br>"
	
	usr << output

/mob/players/verb/ViewMyDeaths()
	set category = null
	ViewDeathStats()

// ============================================================================
// ADMIN VERBS
// ============================================================================

/mob/verb/AdminShowDeathStats(ckey as text)
	set category = "Admin"
	if(!check_admin(usr)) 
		return
	
	if(!death_penalty_manager) return
	usr << death_penalty_manager.AdminShowDeathStats(ckey)

/mob/verb/AdminRespawnFainted(ckey as text)
	set category = "Admin"
	if(!check_admin(usr))
		return
	
	if(!death_penalty_manager) return
	usr << death_penalty_manager.AdminRespawnPlayer(ckey)

/mob/verb/AdminResurrectPermadead(ckey as text)
	set category = "Admin"
	if(!check_admin(usr))
		return
	
	if(!death_penalty_manager) return
	usr << death_penalty_manager.AdminResurrectPermadead(ckey)

// ============================================================================
// WORLD PROC
// ============================================================================

/proc/InitializeDeathPenaltySystem()
	/**
	 * InitializeDeathPenaltySystem
	 * Boot sequence call for death penalty system
	 */
	var/datum/death_penalty_manager/manager = new()
	manager.InitializeDeathPenaltyManager()
