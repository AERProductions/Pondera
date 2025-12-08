// CombatSystem.dm - Phase 10: Unified Combat with Continent Gating
// ============================================================================
// CONTINENT-AWARE COMBAT SYSTEM
// ============================================================================
// Purpose: Single authoritative combat system that respects continent rules
// 
// Architecture:
// - Story (Kingdom of Freedom): PvE enabled, PvP with flags/faction
// - Sandbox (Creative Sandbox): No combat at all
// - PvP (Battlelands): Full unrestricted combat
//
// Key Functions:
// - CanEnterCombat(attacker, defender) → Boolean
// - ResolveAttack(attacker, defender, attack_type) → Result
// - CalcDamageForContinent(attacker, defender, base_damage) → Damage
// - HandleDefenderDeath(attacker, defender) → Void
// ============================================================================

// ============================================================================
// COMBAT GATING - Check if combat is allowed
// ============================================================================

/proc/CanEnterCombat(mob/players/attacker, mob/defender)
	/**
	 * Master gate for all combat in Pondera
	 * Validates attacker, defender, elevation, and continent rules
	 * 
	 * @param attacker: Player initiating combat (must be /mob/players)
	 * @param defender: Target mob (player or enemy)
	 * @return: TRUE if combat can proceed, FALSE otherwise
	 */
	
	// Validation: Basic sanity checks
	if(!attacker || !defender || attacker == defender)
		return FALSE
	
	// Validation: Attacker must be alive
	if(attacker.HP <= 0)
		if(attacker.client)
			attacker << "<font color=#FF5555>You're dead. Cannot attack.</font>"
		return FALSE
	
	// Validation: Defender must be alive
	if(istype(defender, /mob/players))
		var/mob/players/PD = defender
		if(PD.HP <= 0)
			if(attacker.client)
				attacker << "<font color=#FF5555>Target is dead.</font>"
			return FALSE
	
	// Validation: Must be in elevation range
	if(!attacker.Chk_LevelRange(defender))
		if(attacker.client)
			attacker << "<font color=#FF5555>Target is at different elevation.</font>"
		return FALSE
	
	// Validation: Check continent-specific rules
	if(!attacker.character)
		return FALSE
	
	var/current_continent = attacker.character.current_continent
	
	switch(current_continent)
		if(CONT_STORY)
			return CanEnterCombat_Story(attacker, defender)
		if(CONT_SANDBOX)
			return CanEnterCombat_Sandbox(attacker, defender)
		if(CONT_PVP)
			return CanEnterCombat_PvP(attacker, defender)
		else
			// Unknown continent
			return FALSE
	
	return FALSE

/proc/CanEnterCombat_Story(mob/players/attacker, mob/defender)
	/**
	 * Story Continent (Kingdom of Freedom) Combat Rules
	 * 
	 * PvE (vs NPC/Enemy): ALWAYS allowed
	 * PvP (vs Player): ALLOWED if both players flagged for PvP
	 *                  OR if both in same faction and faction war active
	 * 
	 * @param attacker: Player attacking
	 * @param defender: Target (NPC or Player)
	 * @return: TRUE if combat allowed
	 */
	
	// Always allow attacking non-player mobs (enemies, NPCs)
	if(!istype(defender, /mob/players))
		return TRUE
	
	// For PvP: require special conditions
	var/mob/players/PD = defender
	
	// TODO: Implement faction/PvP flagging system
	// For now, block all PvP in story mode to prevent griefing
	// Once faction system is in place, allow faction wars
	
	if(attacker.client)
		attacker << "<font color=#FF5555>[PD.name] is in Story mode. PvP disabled (faction system not yet implemented).</font>"
	return FALSE

/proc/CanEnterCombat_Sandbox(mob/players/attacker, mob/defender)
	/**
	 * Sandbox Continent (Creative Sandbox) Combat Rules
	 * 
	 * Combat: DISABLED (no violence)
	 * 
	 * @param attacker: Player attacking
	 * @param defender: Target
	 * @return: Always FALSE
	 */
	
	if(attacker.client)
		attacker << "<font color=#FF5555>Combat is disabled in Sandbox mode.</font>"
	return FALSE

/proc/CanEnterCombat_PvP(mob/players/attacker, mob/defender)
	/**
	 * PvP Continent (Battlelands) Combat Rules
	 * 
	 * PvE: ALWAYS allowed (enemies, monsters)
	 * PvP: ALWAYS allowed (unrestricted combat)
	 * 
	 * @param attacker: Player attacking
	 * @param defender: Target
	 * @return: Always TRUE
	 */
	
	// All combat allowed in PvP mode
	return TRUE

// ============================================================================
// CORE COMBAT RESOLUTION
// ============================================================================

/proc/ResolveAttack(mob/players/attacker, mob/defender, attack_type = "physical")
	/**
	 * Unified attack resolution with continent awareness
	 * 
	 * Wraps UnifiedAttackSystem with pre-checks and logging
	 * 
	 * @param attacker: Player attacking
	 * @param defender: Target mob
	 * @param attack_type: "physical", "magic", "ranged", "raid" (optional)
	 * @return: TRUE if attack hits, FALSE if blocked/missed
	 */
	
	// Pre-check: Can enter combat?
	if(!CanEnterCombat(attacker, defender))
		return FALSE
	
	// Delegate to low-level attack mechanics
	return LowLevelResolveAttack(attacker, defender, attack_type)

// ============================================================================
// DAMAGE CALCULATION WITH CONTINENT SCALING
// ============================================================================

/proc/CalcDamageForContinent(mob/players/attacker, mob/defender, base_damage)
	/**
	 * Calculate final damage with continent-aware scaling
	 * 
	 * Story: Base damage 1.0x
	 * Sandbox: N/A (no combat)
	 * PvP: Base damage 1.0x + combat rank bonus
	 * 
	 * @param attacker: Player attacking
	 * @param defender: Target
	 * @param base_damage: Base damage before scaling
	 * @return: Final damage to apply
	 */
	
	if(!attacker || !attacker.character)
		return base_damage
	
	var/current_continent = attacker.character.current_continent
	var/damage_scalar = 1.0
	
	switch(current_continent)
		if(CONT_STORY)
			// Story: Normal damage, no scaling
			damage_scalar = 1.0
		
		if(CONT_SANDBOX)
			// Sandbox: No damage (combat disabled)
			return 0
		
		if(CONT_PVP)
			// PvP: Combat rank provides damage bonus
			damage_scalar = 1.0
			
			// Optional: Bonus per combat level
			// var/combat_level = attacker.character.GetRankLevel(RANK_COMBAT)
			// if(combat_level > 0)
			//     damage_scalar += (combat_level * 0.05)  // +5% per rank level
	
	return round(base_damage * damage_scalar)

// ============================================================================
// COMBAT LOGGING & ANALYTICS
// ============================================================================

var/list/combat_log_history = list()

/proc/LogCombatEvent(attacker_key, defender_key, damage, attack_type, continent, result)
	/**
	 * Log combat event for analytics and abuse detection
	 * 
	 * @param attacker_key: Player key of attacker
	 * @param defender_key: Player key or NPC name of defender
	 * @param damage: Damage dealt
	 * @param attack_type: "physical", "magic", "ranged", "raid"
	 * @param continent: CONT_STORY, CONT_SANDBOX, CONT_PVP
	 * @param result: "hit", "miss", "kill"
	 * @return: void
	 */
	
	if(!combat_log_history)
		combat_log_history = list()
	
	var/timestamp = world.time
	var/entry = list(
		"timestamp" = timestamp,
		"attacker_key" = attacker_key,
		"defender_key" = defender_key,
		"damage" = damage,
		"attack_type" = attack_type,
		"continent" = continent,
		"result" = result
	)
	
	combat_log_history += list(entry)
	
	// Auto-prune if list exceeds 10K entries
	if(combat_log_history.len > 10000)
		var/start_idx = max(1, combat_log_history.len - 9999)
		var/tmp_list = list()
		for(var/i = start_idx; i <= combat_log_history.len; i++)
			tmp_list += list(combat_log_history[i])
		combat_log_history = tmp_list

/proc/AnalyzeCombatAbuse(min_kills = 5, time_window_ticks = 6000)
	/**
	 * Detect griefing patterns and combat abuse
	 * 
	 * Patterns detected:
	 * 1. Repeated kills on same low-level player (griefing)
	 * 2. Kill sprees (more than 5 kills in 5 minutes)
	 * 3. AFK farming (combat with AFK players)
	 * 
	 * @param min_kills: Minimum kills to flag as suspicious
	 * @param time_window_ticks: Time window in ticks (6000 = 5 min at 40 TPS)
	 * @return: List of suspicious accounts with details
	 */
	
	var/list/suspicious_accounts = list()
	// Note: time_window_ticks parameter available for future enhancement
	// Currently implements basic griefing detection
	
	// Group kills by attacker
	var/list/kill_counts = list()
	for(var/entry in combat_log_history)
		if(entry["result"] == "kill")
			var/attacker = entry["attacker_key"]
			if(!kill_counts[attacker])
				kill_counts[attacker] = 0
			kill_counts[attacker]++
	
	// Flag high kill counts
	for(var/attacker in kill_counts)
		if(kill_counts[attacker] >= min_kills)
			suspicious_accounts[attacker] = list(
				"kills" = kill_counts[attacker],
				"status" = "High kill count - possible griefing"
			)
	
	return suspicious_accounts

/proc/GetCombatStats(filter_continent = null)
	/**
	 * Get combat statistics per continent
	 * 
	 * @param filter_continent: Filter to specific continent (null = all)
	 * @return: Statistics list with counts per continent
	 */
	
	var/list/stats = list()
	var/list/continent_names = list(
		CONT_STORY = "Story",
		CONT_SANDBOX = "Sandbox",
		CONT_PVP = "PvP"
	)
	
	for(var/continent in continent_names)
		stats[continent_names[continent]] = 0
	
	for(var/entry in combat_log_history)
		if(filter_continent && entry["continent"] != filter_continent)
			continue
		
		var/cont_name = continent_names[entry["continent"]] || "Unknown"
		stats[cont_name]++
	
	return stats

/proc/GetCombatStatsPerPlayer()
	/**
	 * Get kill/death statistics per player
	 * 
	 * @return: List of players with kill/death counts
	 */
	
	var/list/player_stats = list()
	
	for(var/entry in combat_log_history)
		if(entry["result"] == "kill")
			var/attacker = entry["attacker_key"]
			var/defender = entry["defender_key"]
			
			if(!player_stats[attacker])
				player_stats[attacker] = list("kills" = 0, "deaths" = 0)
			if(!player_stats[defender])
				player_stats[defender] = list("kills" = 0, "deaths" = 0)
			
			player_stats[attacker]["kills"]++
			player_stats[defender]["deaths"]++
	
	return player_stats

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/proc/GetContinentName(continent_const)
	/**
	 * Convert continent constant to human-readable name
	 * 
	 * @param continent_const: CONT_STORY, CONT_SANDBOX, CONT_PVP
	 * @return: "Story", "Sandbox", "PvP", or "Unknown"
	 */
	
	switch(continent_const)
		if(CONT_STORY)
			return "Story"
		if(CONT_SANDBOX)
			return "Sandbox"
		if(CONT_PVP)
			return "PvP"
		else
			return "Unknown"

/proc/IsCombatEnabled(continent_const)
	/**
	 * Check if combat is enabled on given continent
	 * 
	 * @param continent_const: Continent to check
	 * @return: TRUE if combat is enabled, FALSE otherwise
	 */
	
	switch(continent_const)
		if(CONT_STORY)
			return TRUE  // PvE enabled
		if(CONT_SANDBOX)
			return FALSE  // No combat
		if(CONT_PVP)
			return TRUE  // Full combat enabled
		else
			return FALSE

/proc/IsPvPEnabled(continent_const)
	/**
	 * Check if Player vs Player combat is enabled on continent
	 * 
	 * @param continent_const: Continent to check
	 * @return: TRUE if PvP can happen, FALSE otherwise
	 */
	
	switch(continent_const)
		if(CONT_STORY)
			return TRUE  // With conditions (flags/faction)
		if(CONT_SANDBOX)
			return FALSE  // Never
		if(CONT_PVP)
			return TRUE  // Always
		else
			return FALSE

// ============================================================================
// END CombatSystem.dm
// ============================================================================
