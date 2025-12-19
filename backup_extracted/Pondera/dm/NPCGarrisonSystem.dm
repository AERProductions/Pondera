/**
 * NPCGarrisonSystem.dm
 * Phase 28: NPC Garrison System & Automatic Defenders
 * 
 * Enables territories to have standing armies of NPCs:
 * - Recruit garrison troops from gold
 * - Different troop types with specializations
 * - Automatic defense when territory attacked
 * - Morale system affects combat effectiveness
 * - Supply lines and logistics management
 * - Garrison skill leveling (combat experience)
 * 
 * Troop Types:
 * - Militia (weak, cheap): Basic defenders, 10 HP, 1 dmg, 10L recruit cost
 * - Archer (ranged): Deal extra damage from towers, 15 HP, 3 dmg, 20L
 * - Knight (tank): Heavy armor, 25 HP, 2 dmg, 50L
 * - Commander (elite): Leader unit, 40 HP, 5 dmg, 100L
 * 
 * Integration Points:
 * - TerritoryDefenseSystem: Garrison defends structures
 * - TerritoryWarsSystem: Auto-defend during wars
 * - CombatSystem: Garrison units engage enemy players
 * - EconomyCombatIntegrationSystem: Garrison maintenance costs
 * - RegionalConflictSystem: Garrison affects faction power
 * 
 * Garrison Mechanics:
 * - Recruit: Territory owner pays lucre to recruit troops
 * - Supply: Feed garrison (costs materials per day)
 * - Morale: Units stronger if well-supplied (bonus damage/defense)
 * - Death: Units respawn after 1 hour if morale > 50%
 * - Desertion: Units leave if unsupplied for 3 days
 */

// ============================================================================
// TROOP TYPE CONSTANTS
// ============================================================================

#define TROOP_MILITIA "militia"
#define TROOP_ARCHER "archer"
#define TROOP_KNIGHT "knight"
#define TROOP_COMMANDER "commander"

// ============================================================================
// GARRISON TROOP DATUM
// ============================================================================

/**
 * /datum/garrison_troop
 * Represents single garrison unit
 */
/datum/garrison_troop
	var
		// Identification
		troop_id                // Unique ID
		troop_type              // Type (militia, archer, etc.)
		territory_id            // Assigned territory
		
		// Stats
		level = 1               // Combat level (1-20)
		experience = 0          // XP toward level up
		
		// Combat
		max_hp = 10             // Health
		current_hp = 10
		armor = 0               // Defense rating
		damage = 1              // Attack damage
		
		// Morale
		morale = 100            // 0-100 (affects damage/defense)
		last_fed_time = 0       // When last supplied
		
		// Location
		territory_position = 1  // Which structure defending
		
		// Status
		is_dead = 0             // Killed in combat
		death_time = 0          // When killed (for respawn)

/**
 * New(troop_type, territory_id)
 * Create new garrison troop
 */
/datum/garrison_troop/New(troop_type, territory_id)
	src.troop_type = troop_type
	src.territory_id = territory_id
	src.troop_id = "[troop_type]_[territory_id]_[world.time]"
	src.last_fed_time = world.time
	
	// Set stats based on type
	switch(troop_type)
		if(TROOP_MILITIA)
			max_hp = 10
			current_hp = 10
			armor = 0
			damage = 1
			
		if(TROOP_ARCHER)
			max_hp = 15
			current_hp = 15
			armor = 1
			damage = 3
			
		if(TROOP_KNIGHT)
			max_hp = 25
			current_hp = 25
			armor = 3
			damage = 2
			
		if(TROOP_COMMANDER)
			max_hp = 40
			current_hp = 40
			armor = 2
			damage = 5

// ============================================================================
// GARRISON REGISTRY
// ============================================================================

var
	list/garrison_troops = list()           // All deployed troops
	list/troops_by_territory = list()       // Troops per territory
	list/dead_troops = list()               // Respawning troops

/**
 * RecruitGarrison(mob/players/owner, territory_id, troop_type, count)
 * Territory owner recruits garrison troops
 * 
 * Cost per troop:
 * - Militia: 10L
 * - Archer: 20L
 * - Knight: 50L
 * - Commander: 100L
 */
/proc/RecruitGarrison(mob/players/owner, territory_id, troop_type, count)
	if(!owner || count <= 0)
		return 0
	
	var/datum/territory_claim/territory = GetTerritoryByID(territory_id)
	if(!territory)
		return 0
	
	// Check owner
	if(territory.owner_player_key != owner.key)
		return 0
	
	// Calculate cost
	var/cost_per_troop = 0
	switch(troop_type)
		if(TROOP_MILITIA)
			cost_per_troop = 10
		if(TROOP_ARCHER)
			cost_per_troop = 20
		if(TROOP_KNIGHT)
			cost_per_troop = 50
		if(TROOP_COMMANDER)
			cost_per_troop = 100
	
	var/total_cost = cost_per_troop * count
	
	if(owner.lucre < total_cost)
		world.log << "[owner.key] insufficient lucre to recruit [count] [troop_type] (need [total_cost]L)"
		return 0
	
	// Deduct cost
	owner.lucre -= total_cost
	
	// Recruit troops
	var/recruited = 0
	for(var/i = 1; i <= count; i++)
		var/datum/garrison_troop/troop = new(troop_type, territory_id)
		garrison_troops += troop
		
		if(!troops_by_territory[territory_id])
			troops_by_territory[territory_id] = list()
		troops_by_territory[territory_id] += troop
		
		recruited++
	
	world.log << "[owner.name] recruited [recruited] [troop_type] in [territory.territory_name]"
	return recruited

/**
 * GetTerritoryGarrison(territory_id)
 * Get all troops in territory
 */
/proc/GetTerritoryGarrison(territory_id)
	return troops_by_territory[territory_id] || list()

/**
 * GetGarrisonStrength(territory_id)
 * Calculate total garrison power (sum of HP)
 */
/proc/GetGarrisonStrength(territory_id)
	var/total_strength = 0
	var/list/troops = GetTerritoryGarrison(territory_id)
	
	for(var/datum/garrison_troop/troop in troops)
		if(!troop.is_dead)
			total_strength += troop.max_hp
	
	return total_strength

// ============================================================================
// GARRISON SUPPLY SYSTEM
// ============================================================================

/**
 * SupplyGarrison(mob/players/owner, territory_id, materials)
 * Feed garrison to boost morale
 * Cost: 1 material per troop (low cost, high benefit)
 */
/proc/SupplyGarrison(mob/players/owner, territory_id, materials)
	if(!owner)
		return 0
	
	var/datum/territory_claim/territory = GetTerritoryByID(territory_id)
	if(!territory)
		return 0
	
	// Check owner
	if(territory.owner_player_key != owner.key)
		return 0
	
	// Check materials available
	var/player_materials = owner.vars["materials"] || 0
	if(player_materials < materials)
		return 0
	
	// Deduct materials
	owner.vars["materials"] = player_materials - materials
	
	// Supply troops
	var/list/troops = GetTerritoryGarrison(territory_id)
	var/supplied = 0
	
	for(var/datum/garrison_troop/troop in troops)
		if(!troop.is_dead)
			troop.morale = min(troop.morale + 10, 100)
			troop.last_fed_time = world.time
			supplied++
	
	world.log << "[owner.name] supplied [supplied] troops in [territory.territory_name]"
	return supplied

/**
 * ProcessGarrisonSupply()
 * Background loop: garrison morale degrades if unsupplied
 * Runs daily
 */
/proc/ProcessGarrisonSupply()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(86400)  // Daily supply check
		
		if(!world_initialization_complete)
			continue
		
		for(var/datum/garrison_troop/troop in garrison_troops)
			if(troop.is_dead)
				continue
			
			// Time since last supply
			var/time_since_supply = world.time - troop.last_fed_time
			var/days_unsupplied = time_since_supply / 86400
			
			// Morale drops: 10% per day unsupplied
			troop.morale -= (10 * days_unsupplied)
			
			// Desertion: troops leave if unsupplied 3+ days
			if(days_unsupplied >= 3)
				garrison_troops -= troop
				if(troops_by_territory[troop.territory_id])
					troops_by_territory[troop.territory_id] -= troop
				world.log << "Troop [troop.troop_id] deserted"

// ============================================================================
// GARRISON COMBAT
// ============================================================================

/**
 * CalculateGarrisonDefense(territory_id)
 * Get total defense bonus from garrison
 * Returns: defense multiplier (1.0 = normal, 1.5 = 50% stronger)
 */
/proc/CalculateGarrisonDefense(territory_id)
	var/list/troops = GetTerritoryGarrison(territory_id)
	if(!troops || troops.len == 0)
		return 1.0
	
	// Base defense: 5% per alive troop
	var/defense_bonus = 1.0 + (troops.len * 0.05)
	
	// Morale modifier: high morale = stronger defense
	var/avg_morale = 0
	for(var/datum/garrison_troop/troop in troops)
		if(!troop.is_dead)
			avg_morale += troop.morale
	
	if(troops.len > 0)
		avg_morale /= troops.len
		// 50% morale = normal, 100% morale = +20% defense
		defense_bonus *= (1.0 + (avg_morale / 500))
	
	return defense_bonus

/**
 * GarrisonAttackPlayer(territory_id, mob/players/attacker, damage)
 * Garrison counter-attacks player
 * Returns: damage dealt by garrison
 */
/proc/GarrisonAttackPlayer(territory_id, mob/players/attacker, damage)
	if(!attacker)
		return 0
	
	var/list/troops = GetTerritoryGarrison(territory_id)
	if(!troops || troops.len == 0)
		return 0
	
	var/garrison_damage = 0
	
	// Each active troop has chance to attack
	for(var/datum/garrison_troop/troop in troops)
		if(troop.is_dead)
			continue
		
		// 30% chance per troop to attack
		if(rand(1, 100) <= 30)
			var/attack_damage = troop.damage
			// Morale affects damage: 50% morale = normal, 100% morale = +20%
			attack_damage *= (1.0 + (troop.morale - 50) / 250)
			garrison_damage += attack_damage
	
	// Attacker takes garrison damage
	if(attacker.vars["hp"])
		attacker.vars["hp"] -= garrison_damage
	
	world.log << "Garrison attacked [attacker.name] for [garrison_damage] damage"
	return garrison_damage

/**
 * DamageGarrisonTroop(territory_id, damage)
 * Attacker damages garrison troop
 * Randomly select a troop to take damage
 */
/proc/DamageGarrisonTroop(territory_id, damage)
	if(damage <= 0)
		return 0
	
	var/list/troops = GetTerritoryGarrison(territory_id)
	if(!troops || troops.len == 0)
		return 0
	
	// Pick random alive troop
	var/datum/garrison_troop/target = null
	for(var/i = 1; i <= 10; i++)
		var/datum/garrison_troop/t = pick(troops)
		if(!t.is_dead)
			target = t
			break
	
	if(!target)
		return 0
	
	// Apply armor reduction
	var/actual_damage = damage - target.armor
	if(actual_damage < 1)
		actual_damage = 1
	
	target.current_hp -= actual_damage
	
	// Check if killed
	if(target.current_hp <= 0)
		target.is_dead = 1
		target.death_time = world.time
		dead_troops += target
		
		// Remove from active troops
		troops_by_territory[territory_id] -= target
		
		world.log << "[target.troop_id] killed"
		return actual_damage
	
	return actual_damage

/**
 * ProcessGarrisonRespawn()
 * Background loop: dead troops respawn after 1 hour (if morale > 50%)
 */
/proc/ProcessGarrisonRespawn()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(3600)  // Check every 6 minutes (60 tick cycle)
		
		if(!world_initialization_complete)
			continue
		
		for(var/datum/garrison_troop/troop in dead_troops)
			var/time_dead = world.time - troop.death_time
			
			// Check morale allows respawn
			if(troop.morale < 50)
				continue  // Don't respawn low morale
			
			// 1 hour dead = respawn
			if(time_dead >= 3600)
				troop.is_dead = 0
				troop.current_hp = troop.max_hp
				troop.morale -= 20  // Cost of death
				
				if(!troops_by_territory[troop.territory_id])
					troops_by_territory[troop.territory_id] = list()
				troops_by_territory[troop.territory_id] += troop
				
				dead_troops -= troop
				
				world.log << "[troop.troop_id] respawned"

// ============================================================================
// GARRISON LEVELING
// ============================================================================

/**
 * GainGarrisonXP(territory_id, experience)
 * All troops in territory gain XP
 * Kills grant troops combat experience
 */
/proc/GainGarrisonXP(territory_id, experience)
	var/list/troops = GetTerritoryGarrison(territory_id)
	
	for(var/datum/garrison_troop/troop in troops)
		if(troop.is_dead)
			continue
		
		troop.experience += experience
		
		// Level up: 100 XP per level
		while(troop.experience >= 100)
			troop.experience -= 100
			troop.level++
			
			// Stat improvements per level
			troop.max_hp += 2
			troop.current_hp = troop.max_hp
			troop.damage += 1
			troop.armor += 1
			
			world.log << "[troop.troop_id] leveled up to [troop.level]"

/**
 * GetGarrisonAverageLevel(territory_id)
 * Get average level of garrison
 */
/proc/GetGarrisonAverageLevel(territory_id)
	var/list/troops = GetTerritoryGarrison(territory_id)
	if(!troops || troops.len == 0)
		return 0
	
	var/total_level = 0
	var/count = 0
	
	for(var/datum/garrison_troop/troop in troops)
		if(!troop.is_dead)
			total_level += troop.level
			count++
	
	if(count == 0)
		return 0
	
	return total_level / count

// ============================================================================
// GARRISON INFORMATION
// ============================================================================

/**
 * GetGarrisonStatus(territory_id)
 * Return formatted garrison status
 */
/proc/GetGarrisonStatus(territory_id)
	var/datum/territory_claim/territory = GetTerritoryByID(territory_id)
	if(!territory)
		return "Territory not found"
	
	var/list/troops = GetTerritoryGarrison(territory_id)
	var/alive_count = 0
	var/dead_count = 0
	var/avg_level = GetGarrisonAverageLevel(territory_id)
	
	for(var/datum/garrison_troop/troop in troops)
		if(troop.is_dead)
			dead_count++
		else
			alive_count++
	
	var/status = "GARRISON: [territory.territory_name]\n"
	status += "═════════════════════════════════════════\n"
	status += "Active Troops: [alive_count]\n"
	status += "Dead (Respawning): [dead_count]\n"
	status += "Total Strength: [GetGarrisonStrength(territory_id)] HP\n"
	status += "Average Level: [avg_level]\n"
	status += "Defense Bonus: [CalculateGarrisonDefense(territory_id)]x\n"
	
	return status

/**
 * GetGarrisonComposition(territory_id)
 * Return breakdown by troop type
 */
/proc/GetGarrisonComposition(territory_id)
	var/list/troops = GetTerritoryGarrison(territory_id)
	var/list/types = list()
	
	for(var/datum/garrison_troop/troop in troops)
		if(!troop.is_dead)
			types[troop.troop_type] = (types[troop.troop_type] || 0) + 1
	
	var/composition = "TROOP COMPOSITION:\n"
	for(var/type in types)
		composition += "  [type]: [types[type]]\n"
	
	return composition

// ============================================================================
// GARRISON MAINTENANCE COSTS
// ============================================================================

/**
 * ProcessGarrisonMaintenance()
 * Background loop: garrison costs lucre per day
 * Cost: 1L per troop per day (for wages/upkeep)
 */
/proc/ProcessGarrisonMaintenance()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(86400)  // Daily maintenance
		
		if(!world_initialization_complete)
			continue
		
		for(var/territory_id in troops_by_territory)
			var/list/troops = troops_by_territory[territory_id]
			if(!troops || troops.len == 0)
				continue
			
			var/datum/territory_claim/territory = GetTerritoryByID(territory_id)
			if(!territory)
				continue
			
			// Calculate maintenance
			var/maintenance = 0
			for(var/datum/garrison_troop/troop in troops)
				if(!troop.is_dead)
					maintenance++  // 1L per troop
			
			// Try to deduct from territory owner's lucre
			var/mob/players/owner = null
			for(var/mob/players/p in world)
				if(p.key == territory.owner_player_key)
					owner = p
					break
			
			if(owner)
				if(owner.lucre >= maintenance)
					owner.lucre -= maintenance
				else
					// Can't afford: disband weakest troops
					var/to_disband = maintenance - owner.lucre
					for(var/i = 1; i <= to_disband; i++)
						if(troops.len == 0)
							break
						garrison_troops -= troops[1]
						troops -= troops[1]

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeNPCGarrison()
 * Boot-time initialization
 * Called from InitializationManager at T+428
 */
/proc/InitializeNPCGarrison()
	// Initialize registries
	if(!garrison_troops)
		garrison_troops = list()
		troops_by_territory = list()
		dead_troops = list()
	
	// Start background loops
	spawn()
		ProcessGarrisonSupply()
	
	spawn()
		ProcessGarrisonRespawn()
	
	spawn()
		ProcessGarrisonMaintenance()
	
	world.log << "NPC Garrison System initialized"
	return

// ============================================================================
// NPC GARRISON SYSTEM SUMMARY
// ============================================================================

/*
 * Phase 28: NPC Garrison System enables passive territory defense:
 * 
 * TROOP TYPES:
 * - Militia: 10 HP, 1 dmg, 10L cost (basic)
 * - Archer: 15 HP, 3 dmg, 20L cost (damage dealer)
 * - Knight: 25 HP, 2 dmg, 50L cost (tank, high armor)
 * - Commander: 40 HP, 5 dmg, 100L cost (elite leader)
 * 
 * RECRUITMENT:
 * - Recruit troops for lucre (10-100L per unit)
 * - Build garrison gradually over time
 * - Mix troop types for balanced forces
 * - Weak territories can be defended by NPCs
 * 
 * SUPPLY SYSTEM:
 * - Feed garrison 1 material per troop
 * - Boosts morale +10 per supply
 * - Unsupplied 3+ days = troops desert
 * - Morale affects combat (50% morale = weak, 100% = strong)
 * 
 * COMBAT MECHANICS:
 * - Garrison defense: +5% per active troop
 * - Morale modifier: 50-100% affects bonus
 * - Counter-attack: 30% chance per troop to hit attacker
 * - Damage mitigation: Armor reduces incoming damage
 * - Death/Respawn: 1 hour respawn if morale > 50%
 * 
 * LEVELING & PROGRESSION:
 * - Gain XP during territory defense
 * - Level up: 100 XP per level (max 20)
 * - Per level: +2 HP, +1 damage, +1 armor
 * - Average garrison level shows battle readiness
 * 
 * MAINTENANCE:
 * - 1L per troop per day (wages/food)
 * - Can't afford = weakest troops disbanded
 * - Territories with income can sustain garrisons
 * - Larger garrison = larger upkeep cost
 * 
 * STRATEGIC DEPTH:
 * - Small garrison: Fast to recruit, weak defense, low cost
 * - Large garrison: Slow to build, strong defense, high cost
 * - Mixed types: Archers for damage, Knights for tank
 * - Well-supplied high-level garrison = expensive to attack
 * 
 * NEXT: Siege Events (supply line raids, fortification races)
 *       NPC Officers (unique commanders with special abilities)
 *       Garrison Morale Events (boost/damage from player actions)
 */
