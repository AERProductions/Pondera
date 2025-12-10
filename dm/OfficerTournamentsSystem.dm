// OfficerTournamentsSystem.dm - Phase 33: Competitive Officer Tournaments & Ranking
// Tournament brackets, matchmaking, ranking ladder, and prize system

#define TOURNAMENT_STATUS_SIGNUP "signup"
#define TOURNAMENT_STATUS_BRACKETS "brackets"
#define TOURNAMENT_STATUS_ACTIVE "active"
#define TOURNAMENT_STATUS_FINISHED "finished"

#define TOURNAMENT_TYPE_MELEE "melee"
#define TOURNAMENT_TYPE_RANGED "ranged"
#define TOURNAMENT_TYPE_SUPPORT "support"
#define TOURNAMENT_TYPE_MIXED "mixed"

// =============================================================================
// Tournament Datum
// =============================================================================

/datum/officer_tournament
	var
		tournament_id           // Unique ID
		tournament_name         // Display name
		tournament_type         // melee, ranged, support, mixed
		status = TOURNAMENT_STATUS_SIGNUP  // Current tournament phase
		
		// Scheduling
		start_time = 0          // When tournament begins
		end_time = 0            // When tournament ends
		current_round = 1       // Current bracket round (1-4)
		max_rounds = 4          // Total rounds (16→8→4→2→1)
		
		// Registration
		list/registered_officers = list()  // Officers in this tournament
		list/bracket_pairs = list()        // Current matchups [officer1, officer2]
		
		// Winners
		list/winners = list()   // Officers who won each round
		winner = null           // Tournament champion
		runner_up = null        // 2nd place
		
		// Rewards
		prize_pool = 0          // Total lucre for distribution
		first_place_prize = 0
		second_place_prize = 0
		third_place_prize = 0

/**
 * New(tournament_id, tournament_name, tournament_type, prize_pool)
 */
/datum/officer_tournament/New(t_id, t_name, t_type, prize)
	tournament_id = t_id
	tournament_name = t_name
	tournament_type = t_type
	prize_pool = prize
	first_place_prize = prize * 0.5
	second_place_prize = prize * 0.3
	third_place_prize = prize * 0.2

// =============================================================================
// Global Tournament System
// =============================================================================

var
	list/active_tournaments = list()    // Currently running tournaments
	list/past_tournaments = list()       // Finished tournaments (for history)
	list/officer_rankings = list()       // Ranking by ELO/rating
	list/tournament_bracket_history = list()  // Past brackets

/proc/InitializeOfficerTournaments()
	if(officer_rankings.len > 0)
		return  // Already initialized
	
	// Initialize empty rankings
	officer_rankings = list()
	active_tournaments = list()
	past_tournaments = list()

/**
 * CreateTournament(tournament_name, tournament_type, prize_pool)
 * Create and register new tournament
 */
/proc/CreateTournament(t_name, t_type, prize=500)
	var/t_id = "tournament_[world.time]"
	var/datum/officer_tournament/tournament = new(t_id, t_name, t_type, prize)
	
	active_tournaments[t_id] = tournament
	
	world << "<b>NEW TOURNAMENT: [t_name]</b> - Signups now open!"
	
	return tournament

/**
 * RegisterOfficerInTournament(officer, tournament_id)
 * Add officer to tournament signup
 */
/proc/RegisterOfficerInTournament(officer, tournament_id)
	if(!officer || !tournament_id)
		return FALSE
	
	var/datum/officer_tournament/tournament = active_tournaments[tournament_id]
	if(!tournament)
		return FALSE
	
	// Prevent duplicate registration
	if(officer in tournament.registered_officers)
		return FALSE
	
	tournament.registered_officers += officer
	return TRUE

/**
 * StartTournament(tournament_id)
 * Begin tournament brackets when signup closes
 */
/proc/StartTournament(tournament_id)
	var/datum/officer_tournament/tournament = active_tournaments[tournament_id]
	if(!tournament)
		return FALSE
	
	// Create bracket pairs
	GenerateTournamentBracket(tournament)
	tournament.status = TOURNAMENT_STATUS_BRACKETS
	
	world << "<b>TOURNAMENT STARTED: [tournament.tournament_name]</b>"
	world << "Round [tournament.current_round]: [tournament.bracket_pairs.len] matches"
	
	return TRUE

/**
 * GenerateTournamentBracket(tournament)
 * Create random matchups for current round
 */
/proc/GenerateTournamentBracket(datum/officer_tournament/tournament)
	tournament.bracket_pairs = list()
	
	var/list/pool = tournament.registered_officers.Copy()
	
	// Shuffle pool
	for(var/i=1 to pool.len)
		var/j = rand(1, pool.len)
		var/temp = pool[i]
		pool[i] = pool[j]
		pool[j] = temp
	
	// Create pairs
	for(var/i=1 to pool.len-1 step 2)
		if(i+1 <= pool.len)
			tournament.bracket_pairs += list(list(pool[i], pool[i+1]))
	
	// If odd number, give bye to last officer
	if(pool.len % 2 == 1)
		tournament.winners += pool[pool.len]

/**
 * SimulateTournamentMatch(officer1, officer2, tournament)
 * Determine winner based on officer stats and luck
 */
/proc/SimulateTournamentMatch(officer1, officer2, tournament)
	if(!officer1 || !officer2)
		return null
	
	// Calculate win chances based on stats (generic access)
	var/o1_level = officer1:level || 1
	var/o1_kills = officer1:kills || 0
	var/o1_loyalty = officer1:loyalty || 100
	var/o1_class = officer1:officer_class || OFFICER_CLASS_GENERAL
	
	var/o2_level = officer2:level || 1
	var/o2_kills = officer2:kills || 0
	var/o2_loyalty = officer2:loyalty || 100
	var/o2_class = officer2:officer_class || OFFICER_CLASS_GENERAL
	
	var/o1_score = o1_level + (o1_kills / 10) + (o1_loyalty / 100)
	var/o2_score = o2_level + (o2_kills / 10) + (o2_loyalty / 100)
	
	// Add class bonuses
	var/o1_bonus = GetClassMatchupBonus(o1_class, o2_class)
	var/o2_bonus = GetClassMatchupBonus(o2_class, o1_class)
	
	o1_score += o1_bonus
	o2_score += o2_bonus
	
	// Random factor (±20%)
	o1_score *= (0.8 + rand() * 0.4)
	o2_score *= (0.8 + rand() * 0.4)
	
	var/winner = o1_score > o2_score ? officer1 : officer2
	
	// Update tournament tracking
	return winner

/**
 * AdvanceTournamentRound(tournament_id)
 * Move to next round with winners only
 */
/proc/AdvanceTournamentRound(tournament_id)
	var/datum/officer_tournament/tournament = active_tournaments[tournament_id]
	if(!tournament)
		return FALSE
	
	// Save bracket to history
	tournament_bracket_history["tournament_[tournament.tournament_id]_round_[tournament.current_round]"] = tournament.bracket_pairs
	
	// Update registrations for next round
	tournament.registered_officers = tournament.winners.Copy() || list()
	// tournament.winners = list()  // Will reinitialize on next match simulation
	
	tournament.current_round++
	
	if(tournament.current_round > tournament.max_rounds)
		FinishTournament(tournament_id)
		return TRUE
	
	// Generate brackets for next round
	GenerateTournamentBracket(tournament)
	
	world << "<b>TOURNAMENT UPDATE: [tournament.tournament_name]</b>"
	world << "Round [tournament.current_round]: [tournament.bracket_pairs.len] matches"
	
	return TRUE

/**
 * FinishTournament(tournament_id)
 * Conclude tournament and distribute prizes
 */
/proc/FinishTournament(tournament_id)
	var/datum/officer_tournament/tournament = active_tournaments[tournament_id]
	if(!tournament)
		return FALSE
	
	tournament.status = TOURNAMENT_STATUS_FINISHED
	
	// Last remaining officer is champion
	if(tournament.registered_officers.len > 0)
		tournament.winner = tournament.registered_officers[1]
	
	// Runner up (2nd place in semifinal)
	if(tournament.registered_officers.len > 1)
		tournament.runner_up = tournament.registered_officers[2]
	
	// Move to past tournaments
	active_tournaments -= tournament_id
	past_tournaments[tournament_id] = tournament
	
	// Update rankings
	UpdateOfficerRankings()
	
	world << "<b>TOURNAMENT COMPLETE: [tournament.tournament_name]</b>"
	if(tournament.winner)
		world << "Winner: [tournament.winner]"
		world << "Prize: [tournament.first_place_prize] Lucre"
	
	return TRUE

/**
 * GetClassMatchupBonus(class1, class2)
 * Return bonus multiplier based on class advantage (rock-paper-scissors)
 */
/proc/GetClassMatchupBonus(class1, class2)
	// General (tank) beats Marshal (DPS)
	// Marshal beats Captain (support)
	// Captain beats Strategist (control)
	// Strategist beats Warlord (fear)
	// Warlord beats General (tanks)
	
	switch(class1)
		if(OFFICER_CLASS_GENERAL)
			if(class2 == OFFICER_CLASS_MARSHAL)
				return 1.2  // Advantage
		if(OFFICER_CLASS_MARSHAL)
			if(class2 == OFFICER_CLASS_CAPTAIN)
				return 1.2
		if(OFFICER_CLASS_CAPTAIN)
			if(class2 == OFFICER_CLASS_STRATEGIST)
				return 1.2
		if(OFFICER_CLASS_STRATEGIST)
			if(class2 == OFFICER_CLASS_WARLORD)
				return 1.2
		if(OFFICER_CLASS_WARLORD)
			if(class2 == OFFICER_CLASS_GENERAL)
				return 1.2
	
	return 1.0

/**
 * UpdateOfficerRankings()
 * Recalculate officer ELO/rating
 */
/proc/UpdateOfficerRankings()
	officer_rankings = list()
	
	// Score = level + wins + (kills * 0.5) + (loyalty * 0.1)
	for(var/datum/elite_officer/officer in officers_registry)
		var/score = officer.level + (officer.kills * 0.5) + (officer.loyalty / 100)
		officer_rankings[officer.officer_id] = score
	
	// Sort by score descending
	var/list/sorted = list()
	for(var/id in officer_rankings)
		sorted += list(list(id, officer_rankings[id]))
	
	// Simple sort
	for(var/i=1 to sorted.len)
		for(var/j=1 to sorted.len-i)
			if(sorted[j][2] < sorted[j+1][2])
				var/temp = sorted[j]
				sorted[j] = sorted[j+1]
				sorted[j+1] = temp
	
	officer_rankings = list()
	for(var/pair in sorted)
		officer_rankings[pair[1]] = pair[2]

/**
 * GetOfficerRank(officer_id)
 * Get rank position (1 = highest)
 */
/proc/GetOfficerRank(officer_id)
	var/rank = 1
	for(var/id in officer_rankings)
		if(id == officer_id)
			return rank
		rank++
	return rank

// =============================================================================
// Tournament Status & Info
// =============================================================================

/proc/GetActiveTournaments()
	return active_tournaments

/proc/GetTournamentStatus(tournament_id)
	var/datum/officer_tournament/tournament = active_tournaments[tournament_id]
	if(!tournament)
		return null
	
	return "{tournament_id: '[tournament.tournament_id]', name: '[tournament.tournament_name]', type: '[tournament.tournament_type]', status: '[tournament.status]', round: [tournament.current_round], registered: [tournament.registered_officers.len]}"

/proc/GetTournamentBracket(tournament_id)
	var/datum/officer_tournament/tournament = active_tournaments[tournament_id]
	if(!tournament)
		return list()
	
	return tournament.bracket_pairs

/proc/GetTournamentWinner(tournament_id)
	var/datum/officer_tournament/tournament = past_tournaments[tournament_id]
	if(!tournament)
		return null
	
	return tournament.winner
