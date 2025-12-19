/**
 * CombatProgression.dm - Combat rank progression system
 * 
 * Tracks combat experience and rank advancement.
 * Players improve at combat through practice, earning XP from attacks and leveling up.
 * Ranks 1-5, with damage +5% per rank and -5% stamina cost per rank.
 * 
 * Integration:
 * - CombatSystem.dm: Calls AwardCombatXP() after attacks
 * - UnifiedAttackSystem.dm: Uses GetCombatDamageScalar() and GetCombatStaminaCost()
 * - CharacterData.dm: Stores combat_rank (1-5) and combat_xp (per-rank accumulator)
 */

// ============================================================================
// GLOBAL CONSTANTS & DATA
// ============================================================================

var/global/const/COMBAT_RANK_MAX = 5
var/global/list/COMBAT_XP_THRESHOLDS

var/global/const/COMBAT_XP_ATTACK_HIT = 10        // XP for successful attack
var/global/const/COMBAT_XP_ATTACK_MISS = 5        // XP for missed attack
var/global/const/COMBAT_XP_MOB_DEFEAT = 50        // XP for defeating NPC
var/global/const/COMBAT_XP_PLAYER_DEFEAT = 100    // XP for defeating player
var/global/const/COMBAT_XP_DEATH_PENALTY_PCT = 10 // % XP loss on death

/**
 * Initialize combat progression system
 * Call from world/New() or InitializationManager
 */
proc/InitializeCombatProgressionSystem()
	if(!COMBAT_XP_THRESHOLDS)
		COMBAT_XP_THRESHOLDS = list()
		COMBAT_XP_THRESHOLDS["1"] = 500    // Rank 1→2
		COMBAT_XP_THRESHOLDS["2"] = 1000   // Rank 2→3
		COMBAT_XP_THRESHOLDS["3"] = 1500   // Rank 3→4
		COMBAT_XP_THRESHOLDS["4"] = 2000   // Rank 4→5

// ============================================================================
// XP AWARD SYSTEM
// ============================================================================

/**
 * Award combat XP to attacker
 * Checks for rank-up automatically
 */
proc/AwardCombatXP(mob/players/M, var/xp_amount, var/reason = "combat")
	if(!istype(M) || !M.client || !M.character) return
	
	// Don't award in sandbox mode (no combat)
	if(M.character.current_continent == "sandbox") return
	
	// Ensure thresholds initialized
	if(!COMBAT_XP_THRESHOLDS)
		InitializeCombatProgressionSystem()
	
	M.character.combat_xp += xp_amount
	
	// Check for level-up
	var/rank = M.character.combat_rank
	while(rank < COMBAT_RANK_MAX && M.character.combat_xp >= COMBAT_XP_THRESHOLDS["[rank]"])
		M.character.combat_xp -= COMBAT_XP_THRESHOLDS["[rank]"]
		rank++
		M.character.combat_rank = rank
		OnCombatRankUp(M, rank - 1, rank)

/**
 * Rank-up callback
 */
proc/OnCombatRankUp(mob/players/M, var/old_rank, var/new_rank)
	if(!istype(M) || !M.client) return
	
	var/name = GetCombatRankName(new_rank)
	M << "<span class='combat_rankup'>>>> Combat Rank UP! [name] (Rank [new_rank]) <<<<</span>"

/**
 * Award XP for mob defeat
 */
proc/AwardMobDefeatXP(mob/players/M)
	if(!istype(M)) return
	AwardCombatXP(M, COMBAT_XP_MOB_DEFEAT, "mob_defeat")

/**
 * Award XP for player defeat (PvP)
 */
proc/AwardPlayerDefeatXP(mob/players/M)
	if(!istype(M)) return
	AwardCombatXP(M, COMBAT_XP_PLAYER_DEFEAT, "player_defeat")

/**
 * Apply death penalty to player
 */
proc/ApplyCombatDeathPenalty(mob/players/M)
	if(!istype(M) || !M.character) return
	
	var/loss = round(M.character.combat_xp * (COMBAT_XP_DEATH_PENALTY_PCT / 100.0))
	M.character.combat_xp = max(0, M.character.combat_xp - loss)
	
	if(loss > 0)
		M << "<span class='warning'>Death penalty: Lost [loss] combat XP</span>"

// ============================================================================
// RANK & XP ACCESSORS
// ============================================================================

/**
 * Get player's current combat rank (1-5)
 */
proc/GetCombatRank(mob/players/M)
	if(!istype(M) || !M.character) return 0
	return M.character.combat_rank

/**
 * Get player's current XP in their rank
 */
proc/GetCombatXP(mob/players/M)
	if(!istype(M) || !M.character) return 0
	return M.character.combat_xp

/**
 * Get human-readable rank name
 */
proc/GetCombatRankName(var/rank)
	switch(rank)
		if(1) return "Novice"
		if(2) return "Practiced"
		if(3) return "Skilled"
		if(4) return "Expert"
		if(5) return "Master"
		else return "Unknown"

// ============================================================================
// COMBAT SCALING FUNCTIONS
// ============================================================================

/**
 * Get damage multiplier from combat rank
 * 1.0 at rank 1, 1.20 at rank 5 (+5% per rank)
 */
proc/GetCombatDamageScalar(mob/players/M)
	var/rank = GetCombatRank(M)
	if(rank < 1) return 1.0
	return 1.0 + ((rank - 1) * 0.05)

/**
 * Get stamina cost multiplier from combat rank
 * 1.0 at rank 1, 0.80 at rank 5 (-5% per rank)
 */
proc/GetCombatStaminaCost(mob/players/M, var/base_cost)
	var/rank = GetCombatRank(M)
	if(rank < 1) return base_cost
	var/mult = 1.0 - ((rank - 1) * 0.05)
	return round(base_cost * mult)

// ============================================================================
// ANALYTICS & STATISTICS
// ============================================================================

/**
 * Get progression statistics for all players
 */
proc/GetCombatProgressionStats()
	var/list/stats = list()
	var/list/ranks = list()
	ranks["1"] = 0
	ranks["2"] = 0
	ranks["3"] = 0
	ranks["4"] = 0
	ranks["5"] = 0
	
	var/total_players = 0
	
	for(var/client/C)
		var/mob/players/M = C.mob
		if(!istype(M)) continue
		
		total_players++
		var/rank = GetCombatRank(M)
		if(rank >= 1 && rank <= 5)
			ranks["[rank]"]++
	
	stats["total_players"] = total_players
	stats["rank_distribution"] = ranks
	
	return stats

/**
 * Get progression stats per continent
 */
proc/GetCombatProgressionStatsByContinent()
	var/list/stats = list()
	
	for(var/continent in list("story", "sandbox", "pvp"))
		stats[continent] = list()
		stats[continent]["count"] = 0
		var/list/ranks = list()
		ranks["1"] = 0
		ranks["2"] = 0
		ranks["3"] = 0
		ranks["4"] = 0
		ranks["5"] = 0
		stats[continent]["ranks"] = ranks
	
	for(var/client/C)
		var/mob/players/M = C.mob
		if(!istype(M) || !M.character) continue
		
		var/cont = M.character.current_continent
		if(!stats[cont]) continue
		
		stats[cont]["count"]++
		var/rank = GetCombatRank(M)
		if(rank >= 1 && rank <= 5)
			stats[cont]["ranks"]["[rank]"]++
	
	return stats

/**
 * Debug: Print player's combat stats
 */
proc/DebugCombatProgression(mob/players/M)
	if(!istype(M)) return
	
	var/rank = GetCombatRank(M)
	var/xp = GetCombatXP(M)
	var/next_threshold = (COMBAT_XP_THRESHOLDS && COMBAT_XP_THRESHOLDS["[rank]"]) ? COMBAT_XP_THRESHOLDS["[rank]"] : 9999
	
	world.log << "\[COMBAT\] [M.key]: Rank [rank]/5, XP [xp]/[next_threshold]"
	world.log << "  → Damage: +[round((GetCombatDamageScalar(M) - 1.0) * 100)]%"
	world.log << "  → Stamina: -[round((1.0 - (GetCombatStaminaCost(M, 100) / 100.0)) * 100)]%"
