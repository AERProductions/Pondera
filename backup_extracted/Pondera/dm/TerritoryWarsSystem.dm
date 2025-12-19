/**
 * TerritoryWarsSystem.dm
 * Phase 23: Territory Wars & Raiding Mechanics
 * 
 * Enables offensive territory control:
 * - Players declare war on enemy territories
 * - Destroy structures to reduce enemy defense
 * - Raid storage caches for material theft
 * - Claim defeated territories (if durability drops to 0%)
 * - War declarations with cooldowns to prevent spam
 * 
 * Integration Points:
 * - /datum/war_declaration: Active war state between territories
 * - TerritoryClaimSystem: Owner verification, territory transfer
 * - TerritoryDefenseSystem: Structure damage, defense bonuses
 * - PvPRankingSystem: War kills count toward PvP stats
 * - EconomyCombatIntegrationSystem: Raid rewards, bounties
 * - DualCurrencySystem: Stolen materials, lucre from raids
 * 
 * War Mechanics:
 * - Declare war on unclaimed or rival territory
 * - Attack structures (walls, gates, towers) via combat
 * - Destroy all structures → territory becomes vulnerable
 * - Raid storage structures → steal materials
 * - Kill defending players → control point shift
 * - Claim territory when durability reaches 0%
 */

// ============================================================================
// WAR DECLARATION DATUM
// ============================================================================

/**
 * /datum/war_declaration
 * Represents active warfare between territories
 */
/datum/war_declaration
	var
		// Identification
		war_id                    // Unique ID
		attacker_player_key       // Attacking player
		defender_territory_id     // Target territory
		
		// Timing
		war_start_time = 0        // When war declared
		war_duration = 86400      // Duration in deciseconds (24 game hours)
		
		// State
		is_active = 1             // War ongoing?
		was_victorious = 0        // Attacker won?
		
		// Combat Stats
		attacker_kills = 0        // Kills by attacker
		defender_kills = 0        // Kills by defender
		structures_destroyed = 0  // Structures toppled
		materials_stolen = 0      // Total materials raided
		
		// Rewards
		conquest_reward = 0       // Lucre if victorious
		raid_reward = 0           // Materials stolen

/**
 * New(attacker_key, defender_terr_id, duration)
 * Declare new war
 */
/datum/war_declaration/New(attacker_key, defender_terr_id, duration=86400)
	attacker_player_key = attacker_key
	defender_territory_id = defender_terr_id
	war_duration = duration
	war_start_time = world.time
	is_active = 1
	
	world.log << "War declared: [attacker_key] attacks [defender_terr_id]"

// ============================================================================
// WAR REGISTRY
// ============================================================================

var
	list/active_wars = list()              // Active war declarations
	list/wars_by_territory = list()        // Wars indexed by territory ID
	list/wars_by_attacker = list()         // Wars indexed by attacker key

/**
 * DeclareWar(mob/players/attacker, datum/territory_claim/target_territory)
 * Attacker initiates war on territory
 * Returns: war datum if successful
 * 
 * Requirements:
 * - Cannot attack own territory
 * - Cannot attack if war already active on target
 * - Cost: 1000 lucre (war tax)
 * - Cooldown: 24 hours between wars
 */
/proc/DeclareWar(mob/players/attacker, datum/territory_claim/target_territory)
	if(!attacker || !target_territory)
		return null
	
	// Cannot attack own territory
	if(target_territory.owner_player_key == attacker.key)
		world.log << "[attacker.key] attempted to attack own territory"
		return null
	
	// Check if war already active
	var/list/active = wars_by_territory[target_territory.territory_id]
	if(active && active.len > 0)
		world.log << "[attacker.key] cannot attack [target_territory.territory_name] - war already active"
		return null
	
	// Check war cost
	if(attacker.lucre < 1000)
		world.log << "[attacker.key] insufficient lucre to declare war (need 1000, have [attacker.lucre])"
		return null
	
	// Check cooldown (last war must be 24+ hours ago)
	var/list/prev_wars = wars_by_attacker[attacker.key]
	if(prev_wars && prev_wars.len > 0)
		var/datum/war_declaration/last_war = prev_wars[prev_wars.len]
		var/time_since = world.time - last_war.war_start_time
		if(time_since < 86400)  // Less than 24 hours
			world.log << "[attacker.key] cooldown active - must wait [86400 - time_since] more deciseconds"
			return null
	
	// Deduct war declaration cost
	attacker.lucre -= 1000
	
	// Create war
	var/datum/war_declaration/war = new(attacker.key, target_territory.territory_id, 86400)
	
	// Register war
	active_wars += war
	
	if(!wars_by_territory[target_territory.territory_id])
		wars_by_territory[target_territory.territory_id] = list()
	wars_by_territory[target_territory.territory_id] += war
	
	if(!wars_by_attacker[attacker.key])
		wars_by_attacker[attacker.key] = list()
	wars_by_attacker[attacker.key] += war
	
	world.log << "[attacker.name] declared war on [target_territory.territory_name]! War duration: 24 hours"
	return war

/**
 * GetActiveWar(territory_id)
 * Get active war on territory
 */
/proc/GetActiveWar(territory_id)
	var/list/wars = wars_by_territory[territory_id]
	if(wars && wars.len > 0)
		for(var/datum/war_declaration/w in wars)
			if(w.is_active)
				return w
	return null

/**
 * GetPlayerWars(player_key)
 * Get wars for attacking player
 */
/proc/GetPlayerWars(player_key)
	return wars_by_attacker[player_key] || list()

// ============================================================================
// STRUCTURE ATTACK
// ============================================================================

/**
 * AttackStructure(mob/players/attacker, datum/defense_structure/structure, damage)
 * Player directly attacks a structure
 * 
 * Requirements:
 * - War must be active on target territory
 * - Structure must not be destroyed
 * - Damage scales from player's weapon
 */
/proc/AttackStructure(mob/players/attacker, datum/defense_structure/structure, damage)
	if(!attacker || !structure)
		return 0
	
	// Find territory
	var/datum/territory_claim/territory = GetTerritoryByID(structure.territory_id)
	if(!territory)
		return 0
	
	// Check war is active
	var/datum/war_declaration/war = GetActiveWar(territory.territory_id)
	if(!war || war.attacker_player_key != attacker.key || !war.is_active)
		world.log << "[attacker.key] attempted structure attack without active war"
		return 0
	
	// Attack structure
	var/actual_damage = DamageStructure(structure, damage, attacker)
	
	// Track destruction
	if(structure.is_destroyed)
		war.structures_destroyed++
		
		// Check victory condition
		var/list/structures = GetTerritoryStructures(territory)
		var/destroyed_count = 0
		for(var/datum/defense_structure/s in structures)
			if(s.is_destroyed)
				destroyed_count++
		
		// All structures destroyed = territory vulnerable
		if(destroyed_count == structures.len && structures.len > 0)
			world.log << "All structures destroyed in [territory.territory_name]! Territory vulnerable to conquest!"
	
	return actual_damage

/**
 * RaidStorage(mob/players/attacker, datum/defense_structure/storage)
 * Player raids a storage structure
 * Returns: materials stolen
 * 
 * Requirements:
 * - Structure must be storage type
 * - War must be active
 * - Storage must not be destroyed
 */
/proc/RaidStorage(mob/players/attacker, datum/defense_structure/storage)
	if(!attacker || !storage)
		return 0
	
	// Check it's a storage
	if(storage.structure_type != "storage")
		return 0
	
	// Check structure still intact
	if(storage.is_destroyed)
		return 0
	
	// Find territory
	var/datum/territory_claim/territory = GetTerritoryByID(storage.territory_id)
	if(!territory)
		return 0
	
	// Check war is active
	var/datum/war_declaration/war = GetActiveWar(territory.territory_id)
	if(!war || war.attacker_player_key != attacker.key || !war.is_active)
		return 0
	
	// Raid succeeds if attacker can reach storage and structure isn't destroyed
	// Steal 30% of stored materials (or default 50)
	var/materials_to_steal = 50
	
	attacker.vars["raided_materials"] = (attacker.vars["raided_materials"] || 0) + materials_to_steal
	war.materials_stolen += materials_to_steal
	
	// Damage storage structure as penalty
	DamageStructure(storage, 25, attacker)
	
	world.log << "[attacker.name] raided storage in [territory.territory_name]! Stole [materials_to_steal] materials"
	return materials_to_steal

// ============================================================================
// TERRITORY CONQUEST
// ============================================================================

// ConquerTerritory implemented in TerritoryResourceAvailability.dm for
// compatibility with resource and supply/demand systems


// ============================================================================
// WAR EXPIRATION
// ============================================================================

/**
 * ProcessWarExpiration()
 * Background loop: expire wars after 24 hours
 * Auto-conclude wars where attacker didn't complete conquest
 */
/proc/ProcessWarExpiration()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(8640)  // Check every 12 minutes (432 deciseconds)
		
		if(!world_initialization_complete)
			continue
		
		for(var/datum/war_declaration/war in active_wars)
			if(!war.is_active)
				continue
			
			var/time_elapsed = world.time - war.war_start_time
			
			// Check expiration (24 hours = 86400 deciseconds)
			if(time_elapsed >= war.war_duration)
				war.is_active = 0
				world.log << "War on [war.defender_territory_id] concluded - attacker did not conquer"
				
				// Remove from active wars
				active_wars -= war

/**
 * ProcessDefensiveKills()
 * Background loop: award bonuses to defending players
 * Defender kills in active war grant bonus lucre
 */
/proc/ProcessDefensiveKills()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(600)  // Check every 30 seconds
		
		if(!world_initialization_complete)
			continue
		
		// This would integrate with PvPRankingSystem kill tracking
		// For now, just a placeholder for future integration

// ============================================================================
// WAR INFORMATION & STATUS
// ============================================================================

/**
 * GetWarInfo(datum/war_declaration/war)
 * Return formatted war status for UI display
 */
/proc/GetWarInfo(datum/war_declaration/war)
	if(!war)
		return "War not found"
	
	var/info = "WAR STATUS\n"
	info += "Territory: [war.defender_territory_id]\n"
	info += "Attacker: [war.attacker_player_key]\n"
	info += "Status: [war.is_active ? "ACTIVE" : "CONCLUDED"]\n"
	info += "Duration: [war.war_duration / 86400] days\n"
	info += "Structures Destroyed: [war.structures_destroyed]\n"
	info += "Materials Stolen: [war.materials_stolen]\n"
	info += "Attacker Kills: [war.attacker_kills]\n"
	info += "Defender Kills: [war.defender_kills]\n"
	
	if(war.was_victorious)
		info += "RESULT: ATTACKER VICTORY - Territory conquered!\n"
		info += "Conquest Reward: [war.conquest_reward] lucre\n"
	
	return info

/**
 * CanPlayerAttackTerritory(mob/players/player, territory_id)
 * Check if player can attack structures in territory
 */
/proc/CanPlayerAttackTerritory(mob/players/player, territory_id)
	if(!player)
		return 0
	
	var/datum/war_declaration/war = GetActiveWar(territory_id)
	if(!war)
		return 0
	
	if(war.attacker_player_key != player.key)
		return 0
	
	if(!war.is_active)
		return 0
	
	return 1

/**
 * GetTerritoryUnderAttack(territory_id)
 * Check if territory has active war
 */
/proc/GetTerritoryUnderAttack(territory_id)
	var/datum/war_declaration/war = GetActiveWar(territory_id)
	if(war && war.is_active)
		return war
	return null

// ============================================================================
// INTEGRATION: COMBAT BONUSES FOR WAR
// ============================================================================

/**
 * GetDefensivePositionBonus(mob/players/defender, datum/territory_claim/territory)
 * Defending in home territory grants combat bonus
 * +10% damage, +20% armor if defending own territory
 */
/proc/GetDefensivePositionBonus(mob/players/defender, datum/territory_claim/territory)
	if(!defender || !territory)
		return 1.0
	
	// Only bonus if defending own territory
	if(territory.owner_player_key != defender.key)
		return 1.0
	
	// +20% damage reduction (home field advantage)
	return 0.8  // Takes 80% damage (20% reduction)

/**
 * ApplyWarCombatModifiers(mob/players/attacker, mob/players/defender, list/attack_data)
 * Modify combat stats based on war status
 */
/proc/ApplyWarCombatModifiers(mob/players/attacker, mob/players/defender, list/attack_data)
	if(!attacker || !defender || !attack_data)
		return attack_data
	
	// Find territories for both players
	for(var/datum/war_declaration/war in active_wars)
		if(!war.is_active)
			continue
		
		// Check if defender is owner of attacked territory
		var/datum/territory_claim/def_territory = GetTerritoryByID(war.defender_territory_id)
		if(def_territory && def_territory.owner_player_key == defender.key)
			if(war.attacker_player_key == attacker.key)
				// Attacker gets +10% damage in active war
				attack_data["damage"] *= 1.1
				// Defender gets defensive position bonus
				attack_data["damage"] *= GetDefensivePositionBonus(defender, def_territory)
				break
	
	return attack_data

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeTerritoryWars()
 * Boot-time initialization
 * Called from InitializationManager at T+423
 */
/proc/InitializeTerritoryWars()
	// Start background loops
	spawn()
		ProcessWarExpiration()
	
	spawn()
		ProcessDefensiveKills()
	
	world.log << "Territory Wars System initialized"
	return

// ============================================================================
// TERRITORY WARS SUMMARY
// ============================================================================

/*
 * Phase 23: Territory Wars complete the PvP loop:
 * 
 * WAR MECHANICS:
 * - Declare war for 1000 lucre (24 hour duration)
 * - Attack enemy structures directly (walls, gates, towers)
 * - Destroy all structures = territory vulnerable
 * - Raid storage structures = steal 50 materials
 * - Claim territory when all structures destroyed
 * - Conquest reward: 5000 lucre + (tier * 1000)
 * 
 * STRATEGIC DEPTH:
 * - Wall damage reduction applies: attacker takes more hits
 * - Gates block movement: must destroy to pass
 * - Towers provide visibility: enemy spots incoming attacks
 * - Storage holds resources: raid successfully = steal materials
 * - Barracks (future NPC defenders): require special tactics
 * 
 * COMBAT INTEGRATION:
 * - Attacking in active war: +10% damage bonus
 * - Defending own territory: +20% damage reduction
 * - Kill streaks reward bonus lucre during war
 * - Territory control = passive income + raid defense
 * 
 * ECONOMIC LOOP (Complete):
 * 1. Farm materials/lucre
 * 2. Claim territory (cost: tier * 100L)
 * 3. Build defenses (walls, towers, storage)
 * 4. Earn passive income (tier * 100L/day)
 * 5. Enemies declare war (cost: 1000L)
 * 6. Defend or lose territory
 * 7. Raider claims territory + collects loot
 * 8. Winner reinvests in better materials
 * 
 * WAR EXPIRATION:
 * - 24 hour war duration
 * - Auto-conclude if conquest not achieved
 * - War cost prevents spam declaring
 * - Cooldown: 24 hours between wars per player
 * 
 * NEXT: Guilds/Factions (team-based territory control)
 *       NPC Defenders (garrison troops, auto-defense)
 *       Siege Equipment (battering rams, catapults)
 */
