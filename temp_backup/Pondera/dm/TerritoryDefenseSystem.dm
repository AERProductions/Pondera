/**
 * TerritoryDefenseSystem.dm
 * Phase 22: Territory Defense Mechanics
 * 
 * Establishes defensive infrastructure:
 * - Players build defensive structures (walls, watchtowers, gates)
 * - Structures have HP and durability (degrade over time, damaged in combat)
 * - Repair costs scale with material tier (expensive to maintain)
 * - Territory durability tied to structure integrity
 * 
 * Integration Points:
 * - /datum/territory_claim: Extends with structures list
 * - /datum/defense_structure: Individual building (wall, tower, gate)
 * - WeaponArmorScalingSystem: Structure HP/damage calculations
 * - EconomyCombatIntegrationSystem: Repair/maintenance costs
 * - TerritoryClaimSystem: Owner verification, maintenance fees
 * 
 * Structure Types:
 * - Wall: Basic barrier (+10% damage reduction per wall)
 * - Watchtower: Range defense (+5% visibility, enemy spotting)
 * - Gate: Controlled entry/exit (blocks movement if damaged)
 * - Storage: Resource cache (holds materials for quick crafting)
 * - Barracks: Troop rally point (placeholders for NPC defenders)
 */

// ============================================================================
// DEFENSE STRUCTURE DATUM
// ============================================================================

/**
 * /datum/defense_structure
 * Individual defensive building in a territory
 */
/datum/defense_structure
	var
		// Identification
		structure_id              // Unique ID per territory
		structure_type            // "wall", "tower", "gate", "storage", "barracks"
		territory_id              // Parent territory
		
		// Position & Properties
		map_x = 0
		map_y = 0
		map_z = 0
		structure_name = ""       // Display name
		
		// Combat Stats
		max_hp = 100              // Maximum health
		current_hp = 100          // Current durability
		armor_ac = 0              // Armor class (damage reduction)
		repair_cost_lucre = 0     // Cost to fully repair
		repair_cost_materials = 0 // Materials needed
		material_type = "stone"   // Material this structure is built from
		
		// Economic Impact
		construction_cost = 0     // Lucre to build
		material_cost = 0         // Materials to build
		weekly_maintenance = 0    // Lucre/week to maintain
		
		// Gameplay Effects
		damage_reduction = 0      // % damage reduction to territory (walls)
		visibility_bonus = 0      // % detection radius (towers)
		movement_blocked = 0      // Blocks passage if destroyed (gates)
		storage_capacity = 0      // Materials it can hold (storage)
		
		// Status
		is_damaged = 0            // current_hp < max_hp?
		is_destroyed = 0          // current_hp == 0?
		last_damage_tick = 0      // When last hit

/**
 * New(struct_type, territory_id, name, cx, cy, cz)
 * Create new defense structure
 */
/datum/defense_structure/New(struct_type, terr_id, struct_name, cx, cy, cz)
	structure_type = struct_type
	territory_id = terr_id
	structure_name = struct_name
	map_x = cx
	map_y = cy
	map_z = cz
	
	// Set structure properties based on type
	switch(struct_type)
		if("wall")
			max_hp = 150
			armor_ac = 5
			damage_reduction = 10      // +10% damage reduction
			construction_cost = 500
			material_cost = 20
			weekly_maintenance = 50
			material_type = "stone"
			
		if("tower")
			max_hp = 100
			armor_ac = 3
			visibility_bonus = 25      // +25% detection range
			construction_cost = 800
			material_cost = 30
			weekly_maintenance = 75
			material_type = "wood"
			
		if("gate")
			max_hp = 200
			armor_ac = 8
			movement_blocked = 1       // Blocks passage when destroyed
			construction_cost = 600
			material_cost = 25
			weekly_maintenance = 60
			material_type = "iron"
			
		if("storage")
			max_hp = 80
			armor_ac = 2
			storage_capacity = 500     // Can hold 500 materials
			construction_cost = 400
			material_cost = 15
			weekly_maintenance = 40
			material_type = "stone"
			
		if("barracks")
			max_hp = 120
			armor_ac = 4
			construction_cost = 700
			material_cost = 28
			weekly_maintenance = 70
			material_type = "wood"
	
	current_hp = max_hp
	repair_cost_lucre = construction_cost / 2
	repair_cost_materials = material_cost / 2
	
	world.log << "Structure created: [structure_name] (type:[structure_type], hp:[max_hp])"

// ============================================================================
// TERRITORY EXTENSION: STRUCTURES
// ============================================================================

/**
 * AddStructureToTerritory(datum/territory_claim/territory, struct_type, name, x, y, z)
 * Add defensive structure to territory
 * Returns: structure datum if successful
 */
/proc/AddStructureToTerritory(datum/territory_claim/territory, struct_type, struct_name, x, y, z)
	if(!territory)
		return null
	
	// Initialize structures list if needed
	if(!territory.vars["structures"])
		territory.vars["structures"] = list()
	
	// Create structure
	var/datum/defense_structure/structure = new(struct_type, territory.territory_id, struct_name, x, y, z)
	
	// Add to territory
	territory.vars["structures"] += structure
	
	world.log << "Structure [struct_name] added to [territory.territory_name]"
	return structure

/**
 * GetTerritoryStructures(datum/territory_claim/territory)
 * Get all structures in a territory
 */
/proc/GetTerritoryStructures(datum/territory_claim/territory)
	if(!territory)
		return list()
	
	return territory.vars["structures"] || list()

/**
 * GetTerritoryDurability(datum/territory_claim/territory)
 * Calculate territory durability based on structure health
 * All structures at 100% = territory at 100%
 * Any destroyed structure = -20% territory durability
 * 
 * Formula: 100% - (20% * destroyed_count)
 */
/proc/GetTerritoryDurability(datum/territory_claim/territory)
	if(!territory)
		return 0
	
	var/list/structures = GetTerritoryStructures(territory)
	if(structures.len == 0)
		return 100  // No structures = invincible
	
	var/destroyed_count = 0
	for(var/datum/defense_structure/s in structures)
		if(s.is_destroyed)
			destroyed_count++
	
	var/durability = 100 - (destroyed_count * 20)
	return max(durability, 0)

// ============================================================================
// STRUCTURE COMBAT
// ============================================================================

/**
 * DamageStructure(datum/defense_structure/structure, damage, attacker)
 * Apply damage to a structure
 * 
 * Damage formula:
 * - Armor reduces incoming damage: damage * (1 - AC/100)
 * - Structure takes reduced damage
 * - If HP drops to 0, structure is destroyed
 */
/proc/DamageStructure(datum/defense_structure/structure, damage, attacker)
	if(!structure)
		return 0
	
	if(structure.is_destroyed)
		return 0  // Can't damage destroyed structures
	
	// Apply armor reduction
	var/armor_reduction = structure.armor_ac / 100
	var/actual_damage = damage * (1 - armor_reduction)
	
	// Apply damage
	structure.current_hp -= actual_damage
	structure.last_damage_tick = world.time
	structure.is_damaged = 1
	
	// Check destruction
	if(structure.current_hp <= 0)
		structure.current_hp = 0
		structure.is_destroyed = 1
		world.log << "[structure.structure_name] DESTROYED!"
		return actual_damage
	
	world.log << "[structure.structure_name] damaged: [structure.current_hp]/[structure.max_hp]"
	return actual_damage

/**
 * RepairStructure(datum/defense_structure/structure, repair_amount)
 * Heal a structure
 * Cannot exceed max_hp
 */
/proc/RepairStructure(datum/defense_structure/structure, repair_amount)
	if(!structure)
		return 0
	
	var/old_hp = structure.current_hp
	structure.current_hp = min(structure.current_hp + repair_amount, structure.max_hp)
	structure.is_damaged = (structure.current_hp < structure.max_hp)
	structure.is_destroyed = 0
	
	var/healed = structure.current_hp - old_hp
	world.log << "[structure.structure_name] repaired: +[healed] HP"
	return healed

/**
 * GetStructureRepairCost(datum/defense_structure/structure)
 * Calculate cost to fully repair structure
 * 
 * Formula: (1 - current_hp/max_hp) * construction_cost
 * If 50% damaged: 50% of construction cost to repair
 */
/proc/GetStructureRepairCost(datum/defense_structure/structure)
	if(!structure)
		return list(lucre = 0, materials = 0)
	
	var/damage_percent = (structure.max_hp - structure.current_hp) / structure.max_hp
	
	var/lucre_cost = ceil(damage_percent * structure.repair_cost_lucre)
	var/material_cost = ceil(damage_percent * structure.repair_cost_materials)
	
	return list(
		lucre = lucre_cost,
		materials = material_cost,
		material_type = structure.material_type
	)

// ============================================================================
// STRUCTURE MANAGEMENT
// ============================================================================

/**
 * CanBuildStructure(mob/players/player, datum/territory_claim/territory, struct_type)
 * Check if player can build structure in territory
 * Requirements:
 * - Player owns territory
 * - Player has enough lucre and materials
 * - Territory has space (max 10 structures)
 */
/proc/CanBuildStructure(mob/players/player, datum/territory_claim/territory, struct_type)
	if(!player || !territory)
		return 0
	
	// Verify ownership
	if(territory.owner_player_key != player.key)
		return 0
	
	// Check structure limit
	var/list/structures = GetTerritoryStructures(territory)
	if(structures.len >= 10)
		return 0  // Too many structures
	
	// Check costs based on type
	var/lucre_cost = 0
	var/mat_cost = 0
	var/mat_type = ""
	
	switch(struct_type)
		if("wall")
			lucre_cost = 500; mat_cost = 20; mat_type = "stone"
		if("tower")
			lucre_cost = 800; mat_cost = 30; mat_type = "wood"
		if("gate")
			lucre_cost = 600; mat_cost = 25; mat_type = "iron"
		if("storage")
			lucre_cost = 400; mat_cost = 15; mat_type = "stone"
		if("barracks")
			lucre_cost = 700; mat_cost = 28; mat_type = "wood"
	
	// Check lucre
	if(player.lucre < lucre_cost)
		return 0
	
	// Check materials
	var/mat_var = "[mat_type]s"
	var/player_mats = player.vars[mat_var] || 0
	if(player_mats < mat_cost)
		return 0
	
	return 1

/**
 * BuildStructure(mob/players/player, datum/territory_claim/territory, struct_type, x, y, z)
 * Construct a structure in territory
 * Returns: structure datum if successful
 */
/proc/BuildStructure(mob/players/player, datum/territory_claim/territory, struct_type, x, y, z)
	if(!CanBuildStructure(player, territory, struct_type))
		return null
	
	// Get costs
	var/lucre_cost = 0
	var/mat_cost = 0
	var/mat_type = ""
	var/struct_name = ""
	
	switch(struct_type)
		if("wall")
			lucre_cost = 500; mat_cost = 20; mat_type = "stone"; struct_name = "Stone Wall"
		if("tower")
			lucre_cost = 800; mat_cost = 30; mat_type = "wood"; struct_name = "Watchtower"
		if("gate")
			lucre_cost = 600; mat_cost = 25; mat_type = "iron"; struct_name = "Iron Gate"
		if("storage")
			lucre_cost = 400; mat_cost = 15; mat_type = "stone"; struct_name = "Storage Cache"
		if("barracks")
			lucre_cost = 700; mat_cost = 28; mat_type = "wood"; struct_name = "Barracks"
	
	// Deduct costs
	player.lucre -= lucre_cost
	var/mat_var = "[mat_type]s"
	player.vars[mat_var] = (player.vars[mat_var] || 0) - mat_cost
	
	// Add structure
	var/datum/defense_structure/structure = AddStructureToTerritory(territory, struct_type, struct_name, x, y, z)
	
	world.log << "[player.name] built [struct_name] in [territory.territory_name] for [lucre_cost] lucre + [mat_cost] [mat_type]"
	return structure

/**
 * DestroyStructure(datum/defense_structure/structure)
 * Remove structure (owner decision or completely destroyed)
 */
/proc/DestroyStructure(datum/defense_structure/structure)
	if(!structure)
		return 0
	
	// Remove from territory's structure list
	// (Would need reverse lookup or pass territory)
	world.log << "[structure.structure_name] removed"
	return 1

// ============================================================================
// TERRITORY DEFENSE CALCULATION
// ============================================================================

/**
 * GetTerritoryDefenseBonus(datum/territory_claim/territory)
 * Calculate total defense bonuses from structures
 * 
 * Walls: +10% damage reduction each
 * Gates: +5% if not destroyed
 * Return: damage multiplier (0.7 = 30% damage reduction)
 */
/proc/GetTerritoryDefenseBonus(datum/territory_claim/territory)
	if(!territory)
		return 1.0
	
	var/damage_reduction = 0
	var/list/structures = GetTerritoryStructures(territory)
	
	for(var/datum/defense_structure/s in structures)
		if(s.is_destroyed)
			continue
		
		if(s.structure_type == "wall")
			damage_reduction += s.damage_reduction
		else if(s.structure_type == "gate" && !s.is_destroyed)
			damage_reduction += 5
	
	// Cap at 50% reduction
	damage_reduction = min(damage_reduction, 50)
	
	// Return multiplier (50% reduction = 0.5 multiplier)
	return 1.0 - (damage_reduction / 100)

/**
 * GetTerritoryVisibility(datum/territory_claim/territory)
 * Calculate detection range bonuses from watchtowers
 * Return: visibility multiplier (1.0 = normal, 1.25 = 25% further)
 */
/proc/GetTerritoryVisibility(datum/territory_claim/territory)
	if(!territory)
		return 1.0
	
	var/visibility_bonus = 0
	var/list/structures = GetTerritoryStructures(territory)
	
	for(var/datum/defense_structure/s in structures)
		if(s.structure_type == "tower" && !s.is_destroyed)
			visibility_bonus += s.visibility_bonus
	
	// Each tower adds +25%, cap at +100% (double detection)
	visibility_bonus = min(visibility_bonus, 100)
	
	return 1.0 + (visibility_bonus / 100)

// ============================================================================
// MAINTENANCE PROCESSOR
// ============================================================================

/**
 * ProcessStructureMaintenance()
 * Background loop: weekly structure maintenance costs
 * Similar to territory maintenance but per-structure
 */
/proc/ProcessStructureMaintenance()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(8400)  // ~7 game days
		
		if(!world_initialization_complete)
			continue
		
		// Check all territories
		for(var/territory_id in territories_by_id)
			var/datum/territory_claim/territory = territories_by_id[territory_id]
			if(!territory || territory.owner_player_key == "")
				continue
			
			// Find owner
			var/mob/players/owner = null
			for(var/mob/players/p in world)
				if(p.key == territory.owner_player_key)
					owner = p
					break
			
			if(!owner)
				continue
			
			// Check structure maintenance
			var/list/structures = GetTerritoryStructures(territory)
			var/total_maintenance = 0
			
			for(var/datum/defense_structure/s in structures)
				if(!s.is_destroyed)
					total_maintenance += s.weekly_maintenance
			
			// Deduct maintenance
			if(total_maintenance > 0)
				if(owner.lucre >= total_maintenance)
					owner.lucre -= total_maintenance
					world.log << "[owner.name] paid [total_maintenance] lucre for structure maintenance in [territory.territory_name]"
				else
					// Can't afford maintenance - damage structures
					world.log << "[owner.name] insufficient lucre for structure maintenance - structures decaying!"
					for(var/datum/defense_structure/s in structures)
						if(!s.is_destroyed)
							DamageStructure(s, 10, null)  // 10 damage per maintenance cycle

/**
 * ProcessNaturalDecay()
 * Background loop: structures degrade over time (weather, entropy)
 * 1% health loss per week if not maintained
 */
/proc/ProcessNaturalDecay()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(8400)  // ~7 game days
		
		if(!world_initialization_complete)
			continue
		
		// Apply decay to all structures
		for(var/territory_id in territories_by_id)
			var/datum/territory_claim/territory = territories_by_id[territory_id]
			if(!territory)
				continue
			
			var/list/structures = GetTerritoryStructures(territory)
			for(var/datum/defense_structure/s in structures)
				if(!s.is_destroyed && s.current_hp > 0)
					// 1% decay per week
					DamageStructure(s, s.max_hp * 0.01, null)

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeTerritoryDefense()
 * Boot-time initialization
 * Called from InitializationManager at T+422
 */
/proc/InitializeTerritoryDefense()
	// Start background loops
	spawn()
		ProcessStructureMaintenance()
	
	spawn()
		ProcessNaturalDecay()
	
	world.log << "Territory Defense System initialized"
	return

// ============================================================================
// TERRITORY DEFENSE SUMMARY
// ============================================================================

/*
 * Phase 22: Territory Defense adds structural layer:
 * 
 * STRUCTURE TYPES:
 * - Wall (150 HP): +10% damage reduction, cost 500L + 20 stone
 * - Tower (100 HP): +25% detection, cost 800L + 30 wood
 * - Gate (200 HP): Movement block, cost 600L + 25 iron
 * - Storage (80 HP): Hold 500 materials, cost 400L + 15 stone
 * - Barracks (120 HP): NPC defender rally point, cost 700L + 28 wood
 * 
 * ECONOMICS:
 * - Building requires lucre + materials
 * - Weekly maintenance: wall 50L, tower 75L, gate 60L, etc.
 * - 1% natural decay per week (weather/entropy)
 * - Repair cost = (damage % * construction cost)
 * 
 * STRATEGIC DEPTH:
 * - Multiple walls stack: 4 walls = 40% damage reduction (capped 50%)
 * - Towers provide early warning system
 * - Gates create chokepoints (enemy must destroy to pass)
 * - Storage lets owner bank materials against raids
 * - Destroyed structure = -20% territory durability
 * 
 * DEFENSE CALCULATION:
 * - Territory durability = 100% - (20% * destroyed_structures)
 * - Incoming damage multiplied by defense bonus (walls + gates)
 * - Visibility impacts enemy detection (towers)
 * 
 * NEXT: Phase 23 adds attack mechanics (siege, raids, territorial wars)
 *       Players can now destroy structures and win territory control
 */
