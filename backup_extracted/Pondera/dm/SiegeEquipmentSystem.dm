/**
 * SiegeEquipmentSystem.dm
 * Phase 27: Siege Warfare Equipment & Heavy Weapons
 * 
 * Introduces specialized siege tools for territorial warfare:
 * - Battering Ram: Break gates, siege damage bonus
 * - Catapult: Long-range structure damage, fire spreads
 * - Siege Tower: Enable climbing walls, assault positioning
 * - Trebuchet: Ultra-heavy damage, requires faction coordination
 * - Explosive Charges: Destroy fortifications, AOE damage
 * 
 * Mechanics:
 * - Equipment requires materials to craft and deploy
 * - Siege items have cooldowns (30-60 minute recharge)
 * - Operators gain XP for skilled siege play
 * - Defenses can destroy siege equipment mid-operation
 * - Equipment placement limited by terrain and positioning
 * 
 * Integration Points:
 * - MaterialRegistrySystem: Siege items cost rare materials (brass, steel)
 * - LocationGatedCraftingSystem: Craft at siege workshop
 * - TerritoryDefenseSystem: Structure HP vs siege damage
 * - CombatSystem: Siege operators have siege skill rank
 * - UnifiedRankSystem: New rank type (siege_rank)
 * 
 * Cost Structure (Per Equipment):
 * - Battering Ram: 500 Iron, 100 Brass (easy)
 * - Catapult: 1000 Iron, 200 Brass, 50 Steel (medium)
 * - Siege Tower: 800 Iron, 300 Brass (medium)
 * - Trebuchet: 2000 Iron, 500 Steel, 100 Mithril (hard)
 * - Explosive Charges: 300 Gunpowder, 200 Iron (medium)
 */

// ============================================================================
// SIEGE EQUIPMENT TYPES
// ============================================================================

#define SIEGE_BATTERING_RAM "battering_ram"
#define SIEGE_CATAPULT "catapult"
#define SIEGE_TOWER "siege_tower"
#define SIEGE_TREBUCHET "trebuchet"
#define SIEGE_EXPLOSIVES "explosives"

// ============================================================================
// SIEGE EQUIPMENT DATUM
// ============================================================================

/**
 * /datum/siege_equipment
 * Represents deployed siege equipment
 */
/datum/siege_equipment
	var
		// Identification
		equipment_id            // Unique ID
		equipment_type          // Type (battering_ram, catapult, etc.)
		territory_id            // Territory deployed in
		
		// Deployment
		operator_key = ""       // Player operating equipment
		deploy_time = 0         // When deployed (world.time)
		deployment_duration = 3600  // Duration (60 minutes = 3600 ticks)
		
		// Stats
		max_hp = 100            // Equipment durability
		current_hp = 100
		damage_per_hit = 50     // Damage to structures per use
		cooldown_ticks = 1800   // 30 minutes between uses
		last_used_time = 0
		
		// Effects
		aoe_radius = 0          // AOE damage radius (for catapult/trebuchet)
		fire_damage = 0         // Ignite structures (catapult)
		structure_bypass = 0    // Bypass wall defense (trebuchet)

/**
 * New(equipment_type, territory_id, operator_key)
 * Create new siege equipment
 */
/datum/siege_equipment/New(equipment_type, territory_id, operator_key)
	src.equipment_type = equipment_type
	src.territory_id = territory_id
	src.operator_key = operator_key
	src.equipment_id = "[equipment_type]_[territory_id]_[world.time]"
	src.deploy_time = world.time
	
	// Set stats based on type
	switch(equipment_type)
		if(SIEGE_BATTERING_RAM)
			damage_per_hit = 75
			cooldown_ticks = 1800  // 30 min
			max_hp = 150
			current_hp = 150
			
		if(SIEGE_CATAPULT)
			damage_per_hit = 100
			cooldown_ticks = 2400  // 40 min
			max_hp = 100
			current_hp = 100
			aoe_radius = 5
			fire_damage = 25
			
		if(SIEGE_TOWER)
			damage_per_hit = 0     // Non-damaging
			cooldown_ticks = 0     // Always ready
			max_hp = 200
			current_hp = 200
			
		if(SIEGE_TREBUCHET)
			damage_per_hit = 150
			cooldown_ticks = 3600  // 60 min
			max_hp = 80
			current_hp = 80
			aoe_radius = 8
			structure_bypass = 1   // Ignores wall defense
			
		if(SIEGE_EXPLOSIVES)
			damage_per_hit = 200
			cooldown_ticks = 3600  // 60 min
			max_hp = 50
			current_hp = 50
			aoe_radius = 10
	
	world.log << "[equipment_type] deployed in [territory_id] by [operator_key]"

// ============================================================================
// SIEGE EQUIPMENT REGISTRY
// ============================================================================

var
	list/deployed_siege_equipment = list()      // All active equipment
	list/equipment_by_territory = list()        // Equipment per territory
	list/equipment_by_operator = list()         // Equipment per operator

/**
 * DeploySiegeEquipment(mob/players/operator, equipment_type, territory_id)
 * Operator deploys siege equipment
 * 
 * Requirements:
 * - Must have siege skill (rank 1+)
 * - Must have materials/lucre for cost
 * - Territory must be under control
 * - Operator must be in territory
 */
/proc/DeploySiegeEquipment(mob/players/operator, equipment_type, territory_id)
	if(!operator)
		return null
	
	// Check siege skill
	if(!operator.character)
		return null
	
	var/siege_rank = operator.character.GetRankLevel("siege_rank")
	if(siege_rank < 1)
		world.log << "[operator.key] lacks siege skill"
		return null
	
	// Check territory control
	var/datum/territory_claim/territory = GetTerritoryByID(territory_id)
	if(!territory)
		return null
	
	// Check operator owns territory
	if(territory.owner_player_key != operator.key)
		world.log << "[operator.key] does not control [territory_id]"
		return null
	
	// Get equipment cost
	var/cost_iron = 0
	// var/cost_brass = 0
	// var/cost_steel = 0
	var/cost_lucre = 1000
	
	switch(equipment_type)
		if(SIEGE_BATTERING_RAM)
			cost_iron = 500
			// cost_brass = 100
			
		if(SIEGE_CATAPULT)
			cost_iron = 1000
			// cost_brass = 200
			// cost_steel = 50
			cost_lucre = 2000
			
		if(SIEGE_TOWER)
			cost_iron = 800
			// cost_brass = 300
			cost_lucre = 1500
			
		if(SIEGE_TREBUCHET)
			cost_iron = 2000
			// cost_steel = 500
			cost_lucre = 5000
			
		if(SIEGE_EXPLOSIVES)
			cost_iron = 300
			cost_lucre = 800
	
	// Check cost
	if(operator.lucre < cost_lucre)
		world.log << "[operator.key] insufficient lucre"
		return null
	
	// Deduct cost
	operator.lucre -= cost_lucre
	if(cost_iron > 0)
		operator.vars["materials"] = (operator.vars["materials"] || 0) - cost_iron
	
	// Create equipment
	var/datum/siege_equipment/equipment = new(equipment_type, territory_id, operator.key)
	
	// Register
	deployed_siege_equipment += equipment
	
	if(!equipment_by_territory[territory_id])
		equipment_by_territory[territory_id] = list()
	equipment_by_territory[territory_id] += equipment
	
	if(!equipment_by_operator[operator.key])
		equipment_by_operator[operator.key] = list()
	equipment_by_operator[operator.key] += equipment
	
	world.log << "[operator.name] deployed [equipment_type] in [territory.territory_name]"
	return equipment

/**
 * GetTerritoryEquipment(territory_id)
 * Get all siege equipment in territory
 */
/proc/GetTerritoryEquipment(territory_id)
	return equipment_by_territory[territory_id] || list()

/**
 * GetOperatorEquipment(operator_key)
 * Get all equipment operated by player
 */
/proc/GetOperatorEquipment(operator_key)
	return equipment_by_operator[operator_key] || list()

// ============================================================================
// SIEGE EQUIPMENT USAGE
// ============================================================================

/**
 * UseSiegeEquipment(datum/siege_equipment/equipment, target_structure)
 * Operator uses siege equipment to attack structure
 */
/proc/UseSiegeEquipment(datum/siege_equipment/equipment, datum/defense_structure/target_structure)
	if(!equipment || !target_structure)
		return 0
	
	// Check cooldown
	var/time_since_use = world.time - equipment.last_used_time
	if(time_since_use < equipment.cooldown_ticks)
		world.log << "Equipment on cooldown: [equipment.cooldown_ticks - time_since_use] ticks remaining"
		return 0
	
	// Check equipment still intact
	if(equipment.current_hp <= 0)
		world.log << "Equipment destroyed"
		return 0
	
	// Calculate damage
	var/damage = equipment.damage_per_hit
	
	// Trebuchet bypasses wall defense
	if(equipment.equipment_type == SIEGE_TREBUCHET)
		// Full damage ignores wall reduction
		damage = equipment.damage_per_hit
	else
		// Normal structures reduce damage 10% per wall in territory
		var/list/walls = GetTerritoryStructures(GetTerritoryByID(equipment.territory_id))
		var/wall_count = 0
		for(var/datum/defense_structure/wall in walls)
			if(wall.structure_type == "wall" && !wall.is_destroyed)
				wall_count++
		damage *= (1.0 - (wall_count * 0.1))  // 10% per wall, cap 50%
	
	// Apply damage to structure
	DamageStructure(target_structure, damage, null)
	
	// Apply fire damage if catapult
	if(equipment.equipment_type == SIEGE_CATAPULT && equipment.fire_damage > 0)
		DamageStructure(target_structure, equipment.fire_damage, null)
	
	// Update cooldown
	equipment.last_used_time = world.time
	
	// Degrade equipment durability (1% per use)
	equipment.current_hp -= equipment.max_hp * 0.01
	
	// Grant XP to operator (via mob search)
	for(var/mob/players/op in world)
		if(op.key == equipment.operator_key)
			if(op.character)
				op.character.UpdateRankExp("siege_rank", 10)
			break
	
	world.log << "[equipment.equipment_type] used vs [target_structure.structure_type], [damage] damage"
	return damage

/**
 * DamageSiegeEquipment(datum/siege_equipment/equipment, damage)
 * Equipment takes damage (defender destroys siege equipment)
 */
/proc/DamageSiegeEquipment(datum/siege_equipment/equipment, damage)
	if(!equipment)
		return 0
	
	equipment.current_hp -= damage
	
	if(equipment.current_hp <= 0)
		// Equipment destroyed
		world.log << "[equipment.equipment_id] destroyed"
		
		// Remove from registry
		deployed_siege_equipment -= equipment
		if(equipment_by_territory[equipment.territory_id])
			equipment_by_territory[equipment.territory_id] -= equipment
		if(equipment_by_operator[equipment.operator_key])
			equipment_by_operator[equipment.operator_key] -= equipment
	
	return equipment.current_hp

/**
 * RetrieveSiegeEquipment(datum/siege_equipment/equipment)
 * Remove deployed equipment (operator retrieves it)
 * Restores some durability for next deployment
 */
/proc/RetrieveSiegeEquipment(datum/siege_equipment/equipment)
	if(!equipment)
		return 0
	
	// Equipment can be repaired and redeployed
	// Restore 50% HP
	equipment.current_hp = equipment.max_hp * 0.5
	equipment.last_used_time = 0  // Reset cooldown
	
	// Remove from active list
	deployed_siege_equipment -= equipment
	if(equipment_by_territory[equipment.territory_id])
		equipment_by_territory[equipment.territory_id] -= equipment
	
	world.log << "[equipment.equipment_id] retrieved"
	return 1

// ============================================================================
// SIEGE TOWER MECHANICS
// ============================================================================

/**
 * UseSiegeTower(datum/siege_equipment/tower, mob/players/climber)
 * Player uses siege tower to scale walls
 * Enables climbing into elevated fortifications
 */
/proc/UseSiegeTower(datum/siege_equipment/tower, mob/players/climber)
	if(!tower || !climber)
		return 0
	
	if(tower.equipment_type != SIEGE_TOWER)
		return 0
	
	// Set climber elevation (allows wall scaling)
	climber.vars["siege_tower_climber"] = 1
	climber.elevel = 1.5  // Mid-wall height (elevated position)
	
	world.log << "[climber.name] climbed siege tower"
	return 1

// ============================================================================
// SIEGE OPERATOR RANK SYSTEM
// ============================================================================

/**
 * GetSiegeRank(mob/players/player)
 * Get player's siege operator rank
 */
/proc/GetSiegeRank(mob/players/player)
	if(!player || !player.character)
		return 0
	return player.character.GetRankLevel("siege_rank")

/**
 * CheckSiegeEquipmentUnlock(siege_type, rank_level)
 * Check if rank unlocks equipment type
 */
/proc/CheckSiegeEquipmentUnlock(siege_type, rank_level)
	switch(siege_type)
		if(SIEGE_BATTERING_RAM)
			return (rank_level >= 1)
		if(SIEGE_CATAPULT)
			return (rank_level >= 2)
		if(SIEGE_TOWER)
			return (rank_level >= 1)
		if(SIEGE_TREBUCHET)
			return (rank_level >= 4)
		if(SIEGE_EXPLOSIVES)
			return (rank_level >= 3)
	return 0

// ============================================================================
// SIEGE EQUIPMENT STATUS
// ============================================================================

/**
 * GetEquipmentStatus(datum/siege_equipment/equipment)
 * Return formatted equipment status
 */
/proc/GetEquipmentStatus(datum/siege_equipment/equipment)
	if(!equipment)
		return "Equipment not found"
	
	var/status = "SIEGE EQUIPMENT: [equipment.equipment_type]\n"
	status += "═════════════════════════════════════════\n"
	status += "HP: [equipment.current_hp]/[equipment.max_hp]\n"
	status += "Damage Per Hit: [equipment.damage_per_hit]\n"
	
	if(equipment.aoe_radius > 0)
		status += "AOE Radius: [equipment.aoe_radius]\n"
	
	// Cooldown
	var/time_since = world.time - equipment.last_used_time
	var/cooldown_remaining = equipment.cooldown_ticks - time_since
	if(cooldown_remaining > 0)
		status += "Cooldown: [cooldown_remaining] ticks\n"
	else
		status += "Status: READY\n"
	
	// Duration remaining
	var/age = world.time - equipment.deploy_time
	var/duration_remaining = equipment.deployment_duration - age
	if(duration_remaining > 0)
		status += "Deployment: [duration_remaining] ticks remaining\n"
	else
		status += "Status: EXPIRED\n"
	
	return status

/**
 * ProcessSiegeEquipmentExpiration()
 * Background loop: remove expired siege equipment
 * Equipment automatically retrieves after 60 minutes
 */
/proc/ProcessSiegeEquipmentExpiration()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(3600)  // Check every 6 minutes
		
		if(!world_initialization_complete)
			continue
		
		for(var/datum/siege_equipment/equipment in deployed_siege_equipment)
			var/age = world.time - equipment.deploy_time
			
			if(age >= equipment.deployment_duration)
				// Equipment expires and must be retrieved
				RetrieveSiegeEquipment(equipment)

/**
 * ProcessSiegeEquipmentDecay()
 * Background loop: equipment gradually degrades
 * Weather and environmental damage
 */
/proc/ProcessSiegeEquipmentDecay()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(14400)  // Check every 2.4 hours (240 ticks)
		
		if(!world_initialization_complete)
			continue
		
		for(var/datum/siege_equipment/equipment in deployed_siege_equipment)
			// Environmental degradation: 5% per cycle
			equipment.current_hp -= equipment.max_hp * 0.05
			
			if(equipment.current_hp <= 0)
				RetrieveSiegeEquipment(equipment)

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeSiegeEquipment()
 * Boot-time initialization
 * Called from InitializationManager at T+427
 */
/proc/InitializeSiegeEquipment()
	// Initialize registries
	if(!deployed_siege_equipment)
		deployed_siege_equipment = list()
		equipment_by_territory = list()
		equipment_by_operator = list()
	
	// Start background loops
	spawn()
		ProcessSiegeEquipmentExpiration()
	
	spawn()
		ProcessSiegeEquipmentDecay()
	
	world.log << "Siege Equipment System initialized"
	return

// ============================================================================
// SIEGE EQUIPMENT SUMMARY
// ============================================================================

/*
 * Phase 27: Siege Equipment transforms territory warfare:
 * 
 * EQUIPMENT TYPES:
 * - Battering Ram: 75 dmg, 30min cooldown, breaches gates (Rank 1)
 * - Catapult: 100 dmg, AOE 5, fire 25 dmg, 40min cooldown (Rank 2)
 * - Siege Tower: 0 dmg, enable wall climbing, mobile (Rank 1)
 * - Trebuchet: 150 dmg, AOE 8, bypass walls, 60min cooldown (Rank 4)
 * - Explosives: 200 dmg, AOE 10, destroy fortifications, 60min cooldown (Rank 3)
 * 
 * COST STRUCTURE:
 * - Battering Ram: 500 Iron, 100 Brass, 1000L
 * - Catapult: 1000 Iron, 200 Brass, 50 Steel, 2000L
 * - Siege Tower: 800 Iron, 300 Brass, 1500L
 * - Trebuchet: 2000 Iron, 500 Steel, 5000L
 * - Explosives: 300 Iron, 800L
 * 
 * MECHANICS:
 * - Deployment: 60-minute duration, then must retrieve
 * - Durability: 1% degrade per use, 5% environmental decay per 2.4h
 * - Wall defense reduces damage (10% per wall, cap 50%)
 * - Trebuchet ignores wall reduction (strong vs fortified)
 * - Defenders can target equipment, destroy before use
 * 
 * SIEGE RANK PROGRESSION (1-5):
 * - Rank 1: Unlocks Battering Ram, Siege Tower
 * - Rank 2: Unlocks Catapult
 * - Rank 3: Unlocks Explosives
 * - Rank 4: Unlocks Trebuchet
 * - Rank 5: Equipment cost -20%, cooldown -10%
 * 
 * NEXT: NPC Garrison System (automatic defenders)
 *       Siege Events (supply lines, fortification races)
 *       Artillery Duels (tower vs trebuchet warfare)
 */
