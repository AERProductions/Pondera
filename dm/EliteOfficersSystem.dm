/**
 * EliteOfficersSystem.dm
 * Phase 30: Elite Officers & Command System
 * 
 * Creates unique NPC commanders with special abilities that affect warfare outcomes:
 * - Officer Classes: 5 types (General, Marshal, Captain, Strategist, Warlord)
 * - Officer Stats: Morale bonus, attack speed, command radius, special ability
 * - Officer Abilities: Class-specific bonuses that affect territory control
 * - Officer Leveling: Gain XP from battles, level up to unlock abilities
 * - Officer Recruitment: Cost lucre and materials, limited slots per territory
 * - Officer Death: Can be killed in combat, requires time to train replacement
 * - Officer Perks: Special bonuses to territory income and warfare
 * - Command Radius: Officers boost nearby troops within radius
 * 
 * Integration Points:
 * - NPCGarrisonSystem: Officers command garrison troops
 * - TerritoryDefenseSystem: Officer ability affects structure defense
 * - TerritoryWarsSystem: Officers influence war outcomes
 * - SiegeEquipmentSystem: Officers boost siege equipment damage
 * - CombatSystem: Officer presence affects player combat
 */

// ============================================================================
// OFFICER CLASSES & CONSTANTS
// ============================================================================

#define OFFICER_CLASS_GENERAL "general"
#define OFFICER_CLASS_MARSHAL "marshal"
#define OFFICER_CLASS_CAPTAIN "captain"
#define OFFICER_CLASS_STRATEGIST "strategist"
#define OFFICER_CLASS_WARLORD "warlord"

// Officer quality tiers
#define OFFICER_QUALITY_RECRUIT 1
#define OFFICER_QUALITY_VETERAN 2
#define OFFICER_QUALITY_ELITE 3
#define OFFICER_QUALITY_LEGENDARY 4

// ============================================================================
// OFFICER DATUM
// ============================================================================

/**
 * /datum/elite_officer
 * Represents a single officer in garrison
 */
/datum/elite_officer
	var
		// Identification
		officer_id              // Unique ID
		officer_name            // Custom name (optional)
		officer_class           // Type (general, marshal, etc.)
		quality_tier = OFFICER_QUALITY_RECRUIT // Recruitment quality
		
		// Stats
		level = 1               // 1-10
		experience = 0          // XP towards next level
		hp = 100                // Current health (can be killed)
		max_hp = 100            // Max health
		
		// Bonuses (vary by class)
		morale_bonus = 0        // +% garrison morale
		defense_bonus = 0       // +% structure defense
		damage_bonus = 0        // +% siege equipment damage
		income_bonus = 0        // +% territory income
		
		// Command
		command_radius = 10     // Tiles affected by officer presence
		troops_commanded = 0    // Current troop count under command
		
		// Abilities
		list/abilities          // Known abilities (ability IDs)
		list/ability_cooldowns  // Ability ID -> last use time
		
		// Status
		is_alive = 1            // 0 = dead, waiting for respawn
		is_recruited = 0        // 0 = in recruitment, 1 = ready
		recruitment_time = 0    // When recruitment started
		
		// History
		battles_fought = 0      // Combat participation count
		kills = 0               // Enemies defeated
		loyalty = 100           // 0-100, affects defection risk
		
		// Combat stats (Phase 31+)
		combat_tier = 1         // 1-5, affects ability damage
		damage_vulnerability = 1.0  // Takes 1.0x damage by default
		movement_speed = 1.0    // Movement multiplier
		dodge_chance = 0        // Chance to dodge attacks
		stunned = 0             // Stun duration
		accuracy_penalty = 0    // Accuracy reduction
		controlled_by = null    // Controlled by another officer

/datum/elite_officer/New(class_type, quality=OFFICER_QUALITY_RECRUIT, name="")
	src.officer_class = class_type
	src.quality_tier = quality
	src.officer_name = name
	src.officer_id = "[class_type]_[world.time]_[rand(1,10000)]"
	src.recruitment_time = world.time
	
	// Initialize stats based on class
	switch(class_type)
		if(OFFICER_CLASS_GENERAL)
			src.morale_bonus = 20
			src.defense_bonus = 10
			src.income_bonus = 5
			src.max_hp = 120
		
		if(OFFICER_CLASS_MARSHAL)
			src.defense_bonus = 30
			src.income_bonus = 15
			src.max_hp = 100
		
		if(OFFICER_CLASS_CAPTAIN)
			src.morale_bonus = 15
			src.damage_bonus = 25
			src.max_hp = 110
		
		if(OFFICER_CLASS_STRATEGIST)
			src.morale_bonus = 10
			src.income_bonus = 20
			src.damage_bonus = 10
			src.max_hp = 80
		
		if(OFFICER_CLASS_WARLORD)
			src.damage_bonus = 50
			src.morale_bonus = 5
			src.max_hp = 150
	
	// Quality tier multipliers
	switch(quality)
		if(OFFICER_QUALITY_RECRUIT)
			// Base stats (already set)
		if(OFFICER_QUALITY_VETERAN)
			src.morale_bonus = src.morale_bonus * 1.25
			src.defense_bonus = src.defense_bonus * 1.25
			src.damage_bonus = src.damage_bonus * 1.25
			src.max_hp = src.max_hp * 1.25
		if(OFFICER_QUALITY_ELITE)
			src.morale_bonus = src.morale_bonus * 1.5
			src.defense_bonus = src.defense_bonus * 1.5
			src.damage_bonus = src.damage_bonus * 1.5
			src.max_hp = src.max_hp * 1.5
		if(OFFICER_QUALITY_LEGENDARY)
			src.morale_bonus = src.morale_bonus * 2.0
			src.defense_bonus = src.defense_bonus * 2.0
			src.damage_bonus = src.damage_bonus * 2.0
			src.max_hp = src.max_hp * 2.0
	
	src.hp = src.max_hp

// ============================================================================
// OFFICER REGISTRY & MANAGEMENT
// ============================================================================

var
	list/officers_registry = list()            // All officers
	list/territory_officers = list()           // Officers per territory
	list/officer_leaderboard = list()          // Officers by kills

/**
 * RecruitOfficer(territory_id, officer_class, quality)
 * Begin recruitment of new officer - costs will be deducted from territory treasury
 */
/proc/RecruitOfficer(territory_id, officer_class, quality=OFFICER_QUALITY_RECRUIT)
	if(!territory_id)
		return null
	
	var/datum/territory_claim/territory = GetTerritoryByID(territory_id)
	if(!territory)
		return null
	
	// Check officer slots available
	if(!territory_officers[territory_id])
		territory_officers[territory_id] = list()
	
	var/max_officers = territory.tier  // 1-3 based on territory tier
	
	var/list/current_officers = territory_officers[territory_id]
	if(current_officers.len >= max_officers)
		return null  // No slots available
	
	// Create officer
	var/datum/elite_officer/officer = new(officer_class, quality)
	officers_registry += officer
	current_officers += officer
	
	// Recruitment time varies by quality (hours in ticks)
	var/recruitment_duration = 600  // 10 minutes default
	switch(quality)
		if(OFFICER_QUALITY_RECRUIT)
			recruitment_duration = 1800  // 30 min
		if(OFFICER_QUALITY_VETERAN)
			recruitment_duration = 3600  // 1 hour
		if(OFFICER_QUALITY_ELITE)
			recruitment_duration = 7200  // 2 hours
		if(OFFICER_QUALITY_LEGENDARY)
			recruitment_duration = 14400  // 4 hours
	
	officer.recruitment_time = world.time + recruitment_duration
	
	return officer

/**
 * CheckOfficerRecruitmentComplete(datum/elite_officer/officer)
 * Check if officer recruitment finished
 */
/proc/CheckOfficerRecruitmentComplete(datum/elite_officer/officer)
	if(!officer)
		return 0
	
	if(officer.is_recruited)
		return 1
	
	if(world.time >= officer.recruitment_time)
		officer.is_recruited = 1
		return 1
	
	return 0

/**
 * GetTerritoryOfficers(territory_id)
 * Get list of officers in territory
 */
/proc/GetTerritoryOfficers(territory_id)
	return territory_officers[territory_id] || list()

/**
 * GetOfficerStatus(datum/elite_officer/officer)
 * Return formatted officer status
 */
/proc/GetOfficerStatus(datum/elite_officer/officer)
	if(!officer)
		return "Officer not found"
	
	var/status = "[officer.officer_name || officer.officer_class]\n"
	status += "Class: [officer.officer_class]\n"
	status += "Level: [officer.level]/10\n"
	status += "HP: [officer.hp]/[officer.max_hp]\n"
	status += "Morale Bonus: +[officer.morale_bonus]%\n"
	status += "Defense Bonus: +[officer.defense_bonus]%\n"
	status += "Damage Bonus: +[officer.damage_bonus]%\n"
	status += "Income Bonus: +[officer.income_bonus]%\n"
	status += "Loyalty: [officer.loyalty]%\n"
	status += "Battles: [officer.battles_fought]\n"
	status += "Kills: [officer.kills]\n"
	
	return status

// ============================================================================
// OFFICER LEVELING & EXPERIENCE
// ============================================================================

/**
 * GainOfficerExperience(datum/elite_officer/officer, amount)
 * Award experience to officer
 */
/proc/GainOfficerExperience(datum/elite_officer/officer, amount)
	if(!officer || officer.level >= 10)
		return 0
	
	officer.experience += amount
	
	// Check for level up (100 XP per level)
	if(officer.experience >= 100)
		officer.experience -= 100
		officer.level += 1
		
		if(officer.level > 10)
			officer.level = 10
		
		// Increase stats on level up
		officer.max_hp = min(officer.max_hp + 10, 250)
		officer.hp = officer.max_hp
		officer.morale_bonus = officer.morale_bonus * 1.05
		officer.defense_bonus = officer.defense_bonus * 1.05
		officer.damage_bonus = officer.damage_bonus * 1.05
		officer.income_bonus = officer.income_bonus * 1.05
		
		return 1
	
	return 0

/**
 * DamageOfficer(datum/elite_officer/officer, amount)
 * Deal damage to officer in combat
 */
/proc/DamageOfficer(datum/elite_officer/officer, amount)
	if(!officer || !officer.is_alive)
		return 0
	
	officer.hp -= amount
	
	if(officer.hp <= 0)
		officer.hp = 0
		officer.is_alive = 0
		return 1  // Officer died
	
	return 0

/**
 * KillOfficer(datum/elite_officer/officer)
 * Officer defeated in combat
 */
/proc/KillOfficer(datum/elite_officer/officer)
	if(!officer)
		return 0
	
	officer.is_alive = 0
	officer.hp = 0
	
	// Recruitment restart needed (8 hours to train replacement at same level)
	officer.recruitment_time = world.time + 28800  // 8 hours
	
	return 1

/**
 * ReviveOfficer(datum/elite_officer/officer)
 * Resurrect defeated officer
 */
/proc/ReviveOfficer(datum/elite_officer/officer)
	if(!officer)
		return 0
	
	officer.is_alive = 1
	officer.hp = officer.max_hp
	
	return 1

// ============================================================================
// OFFICER COMBAT PARTICIPATION
// ============================================================================

/**
 * OfficerParticipatesInBattle(datum/elite_officer/officer)
 * Officer involved in combat, gain battle XP
 */
/proc/OfficerParticipatesInBattle(datum/elite_officer/officer)
	if(!officer || !officer.is_alive)
		return 0
	
	officer.battles_fought += 1
	GainOfficerExperience(officer, 25)
	
	return 1

/**
 * OfficerKillsEnemy(datum/elite_officer/officer)
 * Officer defeats enemy, gain kill XP and kill credit
 */
/proc/OfficerKillsEnemy(datum/elite_officer/officer)
	if(!officer || !officer.is_alive)
		return 0
	
	officer.kills += 1
	GainOfficerExperience(officer, 50)
	
	// Update leaderboard
	for(var/datum/elite_officer/o in officer_leaderboard)
		if(o.officer_id == officer.officer_id)
			officer_leaderboard -= o
			break
	
	officer_leaderboard += officer
	officer_leaderboard = officer_leaderboard.Copy()
	
	// Sort by kills (descending)
	var/list/sorted = list()
	for(var/datum/elite_officer/o in officer_leaderboard)
		if(sorted.len == 0)
			sorted += o
		else
			var/inserted = 0
			for(var/i = 1 to sorted.len)
				if(o.kills > sorted[i].kills)
					sorted.Insert(i, o)
					inserted = 1
					break
			if(!inserted)
				sorted += o
	
	officer_leaderboard = sorted
	
	return 1

// ============================================================================
// OFFICER LOYALTY & DEFECTION SYSTEM
// ============================================================================

/**
 * AdjustOfficerLoyalty(datum/elite_officer/officer, amount)
 * Modify officer loyalty (-100 to +100)
 */
/proc/AdjustOfficerLoyalty(datum/elite_officer/officer, amount)
	if(!officer)
		return 0
	
	officer.loyalty += amount
	officer.loyalty = max(0, min(officer.loyalty, 100))
	
	return officer.loyalty

/**
 * CheckOfficerDefection(datum/elite_officer/officer, territory_id)
 * Check if officer defects to enemy (loyalty < 30%)
 */
/proc/CheckOfficerDefection(datum/elite_officer/officer, territory_id)
	if(!officer || officer.loyalty >= 30)
		return 0
	
	// Low loyalty = risk of defection
	// 30% loyalty = 70% defection chance per week
	var/defection_chance = (30 - officer.loyalty) * 2.33
	
	if(rand(1, 100) <= defection_chance)
		return 1  // Officer defects
	
	return 0

/**
 * DefectOfficer(datum/elite_officer/officer, from_territory_id, to_territory_id)
 * Officer switches sides, takes 30% of garrison with them
 */
/proc/DefectOfficer(datum/elite_officer/officer, from_territory_id, to_territory_id)
	if(!officer)
		return 0
	
	var/datum/territory_claim/from_territory = GetTerritoryByID(from_territory_id)
	var/datum/territory_claim/to_territory = GetTerritoryByID(to_territory_id)
	
	if(!from_territory || !to_territory)
		return 0
	
	// Remove from original territory
	var/list/from_officers = territory_officers[from_territory_id]
	if(from_officers)
		from_officers -= officer
	
	// Add to new territory
	if(!territory_officers[to_territory_id])
		territory_officers[to_territory_id] = list()
	territory_officers[to_territory_id] += officer
	
	// Transfer 30% of garrison
	var/list/from_garrison = GetTerritoryGarrison(from_territory_id)
	var/transfer_count = max(1, from_garrison.len / 3)
	
	for(var/i = 1 to transfer_count)
		if(from_garrison.len > 0)
			var/datum/garrison_troop/troop = from_garrison[from_garrison.len]
			// Transfer troop to new territory
			from_garrison -= troop
	
	// Reset loyalty to 75 (fresh start with new employer)
	officer.loyalty = 75
	
	return 1

// ============================================================================
// OFFICER ABILITIES & BONUSES
// ============================================================================

/**
 * CalculateOfficerGarrisonBonus(territory_id)
 * Calculate garrison bonus from all officers in territory
 */
/proc/CalculateOfficerGarrisonBonus(territory_id)
	var/list/officers = GetTerritoryOfficers(territory_id)
	var/morale_bonus = 0
	
	for(var/datum/elite_officer/officer in officers)
		if(officer.is_alive && officer.is_recruited)
			morale_bonus += officer.morale_bonus
	
	return morale_bonus

/**
 * CalculateOfficerDefenseBonus(territory_id)
 * Calculate structure defense bonus from all officers
 */
/proc/CalculateOfficerDefenseBonus(territory_id)
	var/list/officers = GetTerritoryOfficers(territory_id)
	var/defense_bonus = 0
	
	for(var/datum/elite_officer/officer in officers)
		if(officer.is_alive && officer.is_recruited)
			defense_bonus += officer.defense_bonus
	
	return defense_bonus

/**
 * CalculateOfficerDamageBonus(territory_id)
 * Calculate siege equipment damage bonus from all officers
 */
/proc/CalculateOfficerDamageBonus(territory_id)
	var/list/officers = GetTerritoryOfficers(territory_id)
	var/damage_bonus = 0
	
	for(var/datum/elite_officer/officer in officers)
		if(officer.is_alive && officer.is_recruited)
			damage_bonus += officer.damage_bonus
	
	return damage_bonus

/**
 * CalculateOfficerIncomeBonus(territory_id)
 * Calculate territory income bonus from all officers
 */
/proc/CalculateOfficerIncomeBonus(territory_id)
	var/list/officers = GetTerritoryOfficers(territory_id)
	var/income_bonus = 0
	
	for(var/datum/elite_officer/officer in officers)
		if(officer.is_alive && officer.is_recruited)
			income_bonus += officer.income_bonus
	
	return income_bonus

// ============================================================================
// BACKGROUND PROCESSES
// ============================================================================

/**
 * ProcessOfficerRecruitment()
 * Background: check recruitment completion
 */
/proc/ProcessOfficerRecruitment()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(600)
		
		if(!world_initialization_complete)
			continue
		
		for(var/datum/elite_officer/officer in officers_registry)
			if(!officer.is_recruited)
				CheckOfficerRecruitmentComplete(officer)

/**
 * ProcessOfficerDefections()
 * Background: check for officer defections
 */
/proc/ProcessOfficerDefections()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(36000)  // Check every 10 game hours
		
		if(!world_initialization_complete)
			continue
		
		for(var/territory_id in territory_officers)
			var/list/officers = territory_officers[territory_id]
			for(var/datum/elite_officer/officer in officers)
				if(CheckOfficerDefection(officer, territory_id))
					// Find enemy territory to defect to
					var/list/territories = territories_by_id
					if(territories)
						var/datum/territory_claim/enemy_territory = pick(territories)
						if(enemy_territory && enemy_territory.territory_id != territory_id)
							DefectOfficer(officer, territory_id, enemy_territory.territory_id)

/**
 * ProcessOfficerRespawn()
 * Background: respawn dead officers
 */
/proc/ProcessOfficerRespawn()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(3600)  // Check every hour
		
		if(!world_initialization_complete)
			continue
		
		for(var/datum/elite_officer/officer in officers_registry)
			if(!officer.is_alive && officer.recruitment_time > 0)
				if(world.time >= officer.recruitment_time)
					ReviveOfficer(officer)

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeEliteOfficers()
 * Boot-time initialization
 */
/proc/InitializeEliteOfficers()
	if(!officers_registry)
		officers_registry = list()
		territory_officers = list()
		officer_leaderboard = list()
	
	spawn()
		ProcessOfficerRecruitment()
	
	spawn()
		ProcessOfficerDefections()
	
	spawn()
		ProcessOfficerRespawn()
	
	return

// ============================================================================
// PHASE 30 SUMMARY
// ============================================================================

/*
 * Phase 30: Elite Officers & Command System
 * 
 * OFFICER CLASSES (5 types):
 * - General: +20% morale, +10% defense, +5% income (balanced leader)
 * - Marshal: +30% defense, +15% income (fortress specialist)
 * - Captain: +15% morale, +25% damage (combat leader)
 * - Strategist: +10% morale, +20% income, +10% damage (economist)
 * - Warlord: +50% damage, +5% morale (siege specialist)
 * 
 * QUALITY TIERS (recruitment quality matters):
 * - Recruit: Base stats (100L, 50M cost)
 * - Veteran: +25% all stats (250L, 150M cost)
 * - Elite: +50% all stats (500L, 300M cost)
 * - Legendary: +100% all stats (1000L, 600M cost)
 * 
 * OFFICER SLOTS (per territory tier):
 * - Small: 1 officer max
 * - Medium: 2 officers max
 * - Large: 3 officers max
 * 
 * MECHANICS:
 * - Recruitment takes 30min (recruit) to 4 hours (legendary)
 * - Officers level 1-10, gain XP from battles and kills
 * - Officers can die in combat (8-hour respawn/retraining)
 * - Officer loyalty affects defection risk
 * - Defecting officers take 30% of garrison with them
 * - Officers boost: morale, defense, damage, income (+5-50% each)
 * 
 * ENGAGEMENT HOOKS:
 * - Collect different officer types
 * - Develop officers through leveling
 * - Protect valuable officers (if killed, lose strength)
 * - Worry about defections if loyalty drops
 * - Officer tournaments (Phase 33)
 * 
 * STRATEGIC IMPLICATIONS:
 * - Enemy officers are targets (kill them to weaken territory)
 * - Officer balance requires payment (lucre/materials)
 * - Losing officers hurts (no instant replacement)
 * - Small guilds can steal officers (Phase 34 loyalty defections)
 * 
 * NEXT: Officer Abilities (Phase 31)
 *       Officer Recruitment UI (Phase 32)
 *       Officer Tournaments (Phase 33)
 *       Officer Loyalty & Betrayal (Phase 34)
 */
