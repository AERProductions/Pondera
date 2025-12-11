/**
 * PvPRankingSystem.dm
 * Phase 18: PvP Ranking & Rewards
 * 
 * Purpose: Combat leaderboards and progression rewards
 * - Win/loss tracking per player
 * - Seasonal rankings with resets
 * - Reward distribution (lucre, materials, items)
 * - Kill streaks and achievements
 * - Kingdom-wide PvP stats
 * 
 * Architecture:
 * - /datum/pvp_stats: Player PvP record
 * - /datum/pvp_season: Seasonal ranking period
 * - /datum/kill_streak: Active kill streak tracker
 * - Integration: PlayerEconomicEngagement + SpecialAttacksSystem
 * 
 * Tick Schedule:
 * - T+400: PvP ranking system initialization
 * - Recurring: Season reset every month
 */

// ============================================================================
// PVP STATS DATUM
// ============================================================================

/datum/pvp_stats
	/**
	 * pvp_stats
	 * Track a player's PvP record
	 */
	var
		// Identity
		player_ref = null
		player_name = ""
		
		// Combat record
		wins = 0
		losses = 0
		kills = 0
		deaths = 0
		win_streak = 0
		longest_win_streak = 0
		
		// Rewards earned
		lucre_earned = 0
		kills_since_reward = 0
		
		// Timestamp
		first_combat = 0
		last_combat = 0

/datum/pvp_stats/New(mob/players/player)
	..()
	player_ref = player
	player_name = player.name
	first_combat = world.time
// PVP SEASON TRACKER
// ============================================================================

/datum/pvp_season
	/**
	 * pvp_season
	 * Represents a seasonal ranking period
	 */
	var
		season_number = 1
		season_name = ""
		start_time = 0
		end_time = 0
		duration_ms = 0
		
		list/rankings = list()
		total_matches = 0
		total_kills = 0

/datum/pvp_season/New(season_num, duration)
	..()
	season_number = season_num
	season_name = "Season [season_num]"
	start_time = world.time
	duration_ms = duration
	end_time = world.time + duration

/proc/IsSeasonActive(datum/pvp_season/season)
	/**
	 * IsSeasonActive(datum/pvp_season/season)
	 * Check if season is still running
	 */
	return world.time < season.end_time

// ============================================================================
// KILL STREAK TRACKER
// ============================================================================

/datum/kill_streak
	/**
	 * kill_streak
	 * Track active kill streak for a player
	 */
	var
		player_ref = null
		kills = 0
		started_time = 0
		last_kill_time = 0
		timeout_duration = 300

/datum/kill_streak/New(mob/players/player)
	..()
	player_ref = player
	started_time = world.time
	last_kill_time = world.time

/proc/IsStreakActive(datum/kill_streak/streak)
	/**
	 * IsStreakActive(datum/kill_streak/streak)
	 * Check if streak is still active (not timed out)
	 */
	if(!streak)
		return FALSE
	
	var/time_since_kill = world.time - streak.last_kill_time
	return time_since_kill < streak.timeout_duration

// ============================================================================
// COMBAT RESOLUTION
// ============================================================================

/proc/RecordPvPVictory(mob/players/attacker, mob/players/defender, damage_dealt)
	/**
	 * RecordPvPVictory(mob/players/attacker, mob/players/defender, damage_dealt)
	 * Record a kill and update both players' stats
	 */
	
	if(!attacker || !defender)
		return FALSE
	
	// Get or create PvP stats
	var/datum/pvp_stats/attacker_stats = attacker.vars["pvp_stats"]
	var/datum/pvp_stats/defender_stats = defender.vars["pvp_stats"]
	
	if(!attacker_stats)
		attacker_stats = new /datum/pvp_stats(attacker)
		attacker.vars["pvp_stats"] = attacker_stats
	
	if(!defender_stats)
		defender_stats = new /datum/pvp_stats(defender)
		defender.vars["pvp_stats"] = defender_stats
	
	// ─────────────────────────────────────────────────────────────────────
	// UPDATE ATTACKER STATS
	// ─────────────────────────────────────────────────────────────────────
	
	attacker_stats.kills++
	attacker_stats.wins++
	attacker_stats.win_streak++
	attacker_stats.last_combat = world.time
	
	if(attacker_stats.win_streak > attacker_stats.longest_win_streak)
		attacker_stats.longest_win_streak = attacker_stats.win_streak
	var/datum/kill_streak/streak = attacker.vars["kill_streak"]
	if(!streak || !IsStreakActive(streak))
		streak = new /datum/kill_streak(attacker)
		attacker.vars["kill_streak"] = streak
	
	streak.kills++
	streak.last_kill_time = world.time
	// UPDATE DEFENDER STATS
	// ─────────────────────────────────────────────────────────────────────
	
	defender_stats.deaths++
	defender_stats.losses++
	defender_stats.win_streak = 0
	defender_stats.last_combat = world.time
	defender.vars["kill_streak"] = null
	
	// ─────────────────────────────────────────────────────────────────────
	// REWARD ATTACKER
	// ─────────────────────────────────────────────────────────────────────
	
	// Base reward: 50 lucre per kill
	var/lucre_reward = 50
	if(streak.kills > 1)
		lucre_reward += (streak.kills - 1) * 10
	
	// Damage bonus: +1 lucre per 10 damage (cap at 50 bonus)
	var/damage_bonus = min(50, ceil(damage_dealt / 10.0))
	lucre_reward += damage_bonus
	
	// Award lucre
	attacker.lucre += lucre_reward
	attacker_stats.lucre_earned += lucre_reward
	
	// ─────────────────────────────────────────────────────────────────────
	// FEEDBACK
	// ─────────────────────────────────────────────────────────────────────
	
	attacker << "<font color=#00FF00>KILL: +[lucre_reward] lucre</font>"
	
	if(streak.kills > 1)
		attacker << "<font color=#FFFF00>KILL STREAK: [streak.kills]!</font>"
	
	defender << "<font color=#FF5555>KILLED BY [attacker.name]</font>"
	world.log << "PVP: [attacker.name] killed [defender.name] ([lucre_reward] lucre, streak: [streak.kills])"
	
	return TRUE

/proc/GetKillStreakText(datum/kill_streak/streak)
	/**
	 * GetKillStreakText(datum/kill_streak/streak)
	 * Get flavor text for kill streak milestone
	 */
	
	if(!streak)
		return ""
	
	switch(streak.kills)
		if(1)
			return ""
		if(2)
			return "DOUBLE KILL"
		if(3)
			return "TRIPLE KILL"
		if(5)
			return "PENTAKILL"
		if(10)
			return "UNSTOPPABLE"
		else
			if(streak.kills > 10)
				return "GODLIKE"
	
	return ""

// ============================================================================
// RANKING & LEADERBOARDS
// ============================================================================

/proc/GetPvPLeaderboard(limit)
	/**
	 * GetPvPLeaderboard(limit)
	 * Get top PvP players by wins
	 * Returns: list of /datum/pvp_stats sorted
	 */
	
	var/list/all_stats = list()
	for(var/mob/players/player in world)
		if(!player || !player.vars["pvp_stats"])
			continue
		
		all_stats += player.vars["pvp_stats"]
	
	// Bubble sort by wins (descending)
	var/i = 0
	while(i < all_stats.len - 1)
		if(all_stats[i].wins < all_stats[i+1].wins)
			var/tmp = all_stats[i]
			all_stats[i] = all_stats[i+1]
			all_stats[i+1] = tmp
			i = 0
		else
			i++
	
	// Return top N
	if(limit && limit < all_stats.len)
		return all_stats.Copy(1, limit+1)
	
	return all_stats

/proc/GetPlayerPvPRank(mob/players/player)
	/**
	 * GetPlayerPvPRank(mob/players/player)
	 * Get player's current rank
	 * Returns: Rank number (1-based)
	 */
	
	if(!player || !player.vars["pvp_stats"])
		return 0
	
	var/list/leaderboard = GetPvPLeaderboard(null)
	var/player_stats = player.vars["pvp_stats"]
	
	for(var/i = 1; i <= leaderboard.len; i++)
		if(leaderboard[i] == player_stats)
			return i
	
	return 0

/proc/GetWinRate(datum/pvp_stats/stats)
	/**
	 * GetWinRate(datum/pvp_stats/stats)
	 * Calculate win/loss ratio
	 * Returns: Percentage (0-100)
	 */
	
	if(!stats)
		return 0
	
	var/total = stats.wins + stats.losses
	if(total == 0)
		return 0
	
	return (stats.wins / total) * 100

// ============================================================================
// SEASON MANAGEMENT
// ============================================================================

var/global/datum/pvp_season/current_season = null
var/global/list/season_history = list()

/proc/InitializePvPRanking()
	/**
	 * InitializePvPRanking()
	 * Called from InitializationManager.dm at T+400
	 * Initialize PvP ranking system
	 */
	
	// Create initial season (30 days)
	var/season_duration = 30 * 24 * 60 * 60 * 10
	current_season = new /datum/pvp_season(1, season_duration)
	
	world.log << "RANKING: PvP ranking system initialized (Season [current_season.season_number])"
	
	return TRUE

/proc/StartNewSeason()
	/**
	 * StartNewSeason()
	 * End current season and start new one
	 * Called monthly
	 */
	
	if(!current_season)
		return FALSE
	
	// Archive current season
	season_history += current_season
	
	// Create new season
	var/new_season_num = current_season.season_number + 1
	var/season_duration = 30 * 24 * 60 * 60 * 10
	current_season = new /datum/pvp_season(new_season_num, season_duration)
	for(var/mob/players/player in world)
		if(!player.client)
			continue
		
		player << "<font color=#FFFF00>======================================</font>"
		player << "<font color=#FFFF00>SEASON [new_season_num] STARTED</font>"
		player << "<font color=#FFFF00>All ranks reset. Good luck, warriors!</font>"
		player << "<font color=#FFFF00>======================================</font>"
	
	world.log << "RANKING: New season started (Season [new_season_num])"
	
	return TRUE

/proc/EndSeason()
	/**
	 * EndSeason()
	 * Process season end rewards and leaderboards
	 */
	
	if(!current_season)
		return FALSE
	
	// Get final rankings
	var/list/final_rankings = GetPvPLeaderboard(null)
	var/list/reward_tiers = alist(
		1, 1000,  // 1st place: 1000 lucre
		2, 500,   // 2nd: 500
		3, 250,   // 3rd: 250
		4, 150,
		5, 100,
		6, 75,
		7, 50,
		8, 40,
		9, 30,
		10, 20
	)
	
	for(var/rank = 1; rank <= min(10, final_rankings.len); rank++)
		var/datum/pvp_stats/stats = final_rankings[rank]
		if(!stats.player_ref)
			continue
		
		var/mob/players/player = stats.player_ref
		var/reward = reward_tiers[rank] || 0
		
		if(reward > 0)
			player.lucre += reward
			player << "<font color=#FFFF00>SEASON END: Ranked [rank] - [reward] lucre reward!</font>"
	
	world.log << "RANKING: Season [current_season.season_number] ended. Top player: [final_rankings[1].player_name] with [final_rankings[1].wins] wins"
	
	return TRUE

// ============================================================================
// PVP UI & DISPLAY
// ============================================================================

/proc/DisplayPvPStats(mob/players/player)
	/**
	 * DisplayPvPStats(mob/players/player)
	 * Show player's PvP statistics
	 */
	
	if(!player)
		return
	
	var/datum/pvp_stats/stats = player.vars["pvp_stats"]
	if(!stats)
		player << "No PvP stats yet."
		return
	
	var/rank = GetPlayerPvPRank(player)
	var/win_rate = GetWinRate(stats)
	var/datum/kill_streak/streak = player.vars["kill_streak"]
	var/current_streak = streak && IsStreakActive(streak) ? streak.kills : 0
	
	player << "\n<font color=#FFFF00>=== PVP STATISTICS ===</font>"
	player << "Rank: [rank]"
	player << "Wins: [stats.wins] | Losses: [stats.losses]"
	player << "Win Rate: [win_rate]%"
	player << "Kills: [stats.kills] | Deaths: [stats.deaths]"
	player << "Longest Streak: [stats.longest_win_streak]"
	player << "Current Streak: [current_streak]"
	player << "Lucre Earned: [stats.lucre_earned]"
	player << "\n"

/proc/DisplayLeaderboard(limit)
	/**
	 * DisplayLeaderboard(limit)
	 * Show top PvP players
	 * Returns: Formatted text
	 */
	
	var/list/leaderboard = GetPvPLeaderboard(limit || 10)
	var/text = ""
	
	text += "<font color=#FFFF00>=== PVP LEADERBOARD (Season [current_season.season_number]) ===</font>\n"
	
	for(var/rank = 1; rank <= leaderboard.len; rank++)
		var/datum/pvp_stats/stats = leaderboard[rank]
		var/win_rate = GetWinRate(stats)
		
		text += "[rank]. [stats.player_name]: [stats.wins] wins ([win_rate]%) - [stats.kills] kills\n"
	
	return text

// ============================================================================
// BACKGROUND PROCESSING
// ============================================================================

/proc/PvPProcessor()
	/**
	 * PvPProcessor()
	 * Background loop: Track seasons, seasonal resets
	 */
	set background = 1
	set waitfor = 0
	
	var/process_interval = 3000
	var/last_process = world.time
	
	while(1)
		sleep(100)
		
		if(world.time - last_process >= process_interval)
			last_process = world.time
			if(current_season && !IsSeasonActive(current_season))
				EndSeason()
				StartNewSeason()
