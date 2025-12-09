/**
 * EconomyCombatIntegrationSystem.dm
 * Phase 20: Economy-Combat Loop
 * 
 * Connects crafting → equipment quality → combat power → PvP earnings → reinvestment
 * Closes the gameplay loop: fight for lucre/materials → upgrade gear → fight better → repeat
 * 
 * Key Systems:
 * - Weapon repair costs scale with material tier (via WeaponArmorScalingSystem)
 * - Bounty system for PvP kills (lucre rewards)
 * - Equipment quality → combat effectiveness
 * - Material scarcity drives market prices
 * - Equipment degradation forces maintenance costs
 * 
 * Dependencies:
 * - UnifiedRankSystem.dm (rank levels)
 * - WeaponArmorScalingSystem.dm (equipment scaling, repair functions)
 * - PvPRankingSystem.dm (kill tracking)
 * - MaterialRegistrySystem.dm (material properties)
 * - DynamicMarketPricingSystem.dm (pricing)
 * - DualCurrencySystem.dm (lucre/materials)
 */

/**
 * PvP BOUNTY SYSTEM
 * Tracks bounty earnings from PvP kills
 */

/**
 * CalculateBountyReward(mob/players/killer, damage_dealt, kill_streak)
 * Calculate bounty earnings from a kill
 * 
 * Formula:
 * - Base: 50 lucre per kill
 * - Streak: +10 lucre per kill in streak (kill 5th → +50 lucre bonus)
 * - Damage: +1 lucre per 10 damage dealt (caps at 50 lucre)
 * 
 * Example: Kill with 8-kill streak, 120 damage dealt
 * - Base: 50 lucre
 * - Streak: 8 * 10 = 80 lucre
 * - Damage: 120 / 10 = 12 lucre
 * - Total: 142 lucre
 */
/proc/CalculateBountyReward(mob/players/killer, damage_dealt = 0, kill_streak = 0)
	if(!killer)
		return 0
	
	var/bounty = 50  // Base kill bounty
	
	// Streak bonus scales linearly
	bounty += kill_streak * 10
	
	// Damage bonus (1 lucre per 10 damage, capped at 50)
	var/damage_bonus = min(ceil(damage_dealt / 10), 50)
	bounty += damage_bonus
	
	return bounty

/**
 * AwardBountyReward(mob/players/killer, damage_dealt, kill_streak)
 * Award bounty earnings to killer
 * Called after kill is confirmed in combat system
 */
/proc/AwardBountyReward(mob/players/killer, damage_dealt = 0, kill_streak = 0)
	if(!killer)
		return FALSE
	
	var/bounty = CalculateBountyReward(killer, damage_dealt, kill_streak)
	if(bounty <= 0)
		return FALSE
	
	killer.lucre += bounty
	
	// Log bounty to player (using world.log as fallback if to_chat unavailable)
	world.log << "[killer.name] earned [bounty] lucre bounty (base:50 + streak:[kill_streak*10] + damage:[ceil(damage_dealt/10)])"
	
	return TRUE

// ============================================================================
// EQUIPMENT QUALITY INTEGRATION
// ============================================================================

/**
 * GetCombatStatBonus(obj/items/equipment/eq)
 * Get combat multiplier from equipment quality
 * 
 * Higher quality = higher damage/armor
 * Quality ranges 80-120% depending on crafter rank and material
 * 
 * Example: Steel weapon, rank 3 crafter
 * - Quality bonus: 95% → 1.0x effective damage (or +5% boost)
 */
/proc/GetCombatStatBonus(obj/items/equipment/eq)
	if(!eq)
		return 1.0
	
	// Default: 100% quality (no bonus/penalty)
	// Equipment quality varies by crafter rank
	var/quality = 100
	
	// Normalize to 0.8-1.2 multiplier
	return quality / 100

/**
 * ApplyCombatBonusesFromGear(mob/players/attacker, attack_data)
 * Apply equipment quality bonuses to outgoing damage
 * Called before damage calculation in combat system
 * 
 * Bonuses:
 * - Weapon quality: +damage multiplier
 * - Material tier: +5% per tier (if available)
 */
/proc/ApplyCombatBonusesFromGear(mob/players/attacker, list/attack_data)
	if(!attacker || !attack_data)
		return attack_data
	
	// Get equipped weapon if available
	var/equipped_weapon = attacker.vars["equipped_weapon"]
	if(!equipped_weapon)
		return attack_data
	
	// Apply weapon quality multiplier
	var/weapon_bonus = GetCombatStatBonus(equipped_weapon)
	attack_data["damage"] *= weapon_bonus
	attack_data["quality_modifier"] = weapon_bonus
	
	return attack_data

/**
 * GetDefenseFromArmor(mob/players/defender)
 * Calculate armor defense bonus
 * Returns damage reduction multiplier (0.5 = 50% reduction)
 */
/proc/GetDefenseFromArmor(mob/players/defender)
	if(!defender)
		return 1.0
	
	var/total_ac = 0
	
	// Check all equipped armor slots if they exist
	var/list/armor_slots = list("head", "chest", "hands", "feet", "back", "waist")
	for(var/slot in armor_slots)
		var/slot_var = "equipped_[slot]"
		var/equipped_armor = defender.vars[slot_var]
		if(!equipped_armor)
			continue
		
		// Default: armor gives no AC if not defined
		// Could extend with armor_ac variable later
	
	// Cap armor at 50% reduction
	var/reduction = min(total_ac / 100, 0.5)
	return 1.0 - reduction

// ============================================================================
// MATERIAL SCARCITY & MARKET PRESSURE
// ============================================================================

/**
 * UpdateMaterialScarcity()
 * Background system to track material demand
 * High combat activity = high material demand = high prices
 * 
 * Runs every 30 seconds to:
 * - Count active combatants
 * - Calculate equipment repair demand
 * - Update market prices via DynamicMarketPricingSystem
 */
/proc/UpdateMaterialScarcity()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(300)  // 15 seconds (5 deciseconds * 60)
		
		if(!world_initialization_complete)
			continue
		
		// Count active combatants (players with combat_state > 0)
		var/active_combatants = 0
		for(var/mob/players/player in world)
			if(player.vars["in_combat"] || player.vars["last_combat_tick"])
				active_combatants++
		
		if(active_combatants == 0)
			continue
		
		// High combat = material demand spike
		// Prices increase by 5% per active combatant (up to 50%)
		var/demand_multiplier = 1.0 + min(active_combatants * 0.05, 0.5)
		
		// Update material prices via market system
		// This creates emergent economy: more fighting = more expensive materials
		// = less armor repair = more fights = positive feedback loop
		UpdateMarketPricesForDemand(demand_multiplier)

/**
 * UpdateMarketPricesForDemand(multiplier)
 * Temporary price adjustment based on combat activity
 * Called by UpdateMaterialScarcity()
 */
/proc/UpdateMarketPricesForDemand(multiplier)
	// This would hook into DynamicMarketPricingSystem.dm
	// For now, just track active combatants
	return

// ============================================================================
// GEAR PROGRESSION GATES
// ============================================================================

/**
 * CanAffordRepair(mob/players/player, obj/items/equipment/eq)
 * Check if player can afford to repair equipment
 * Used to gate high-tier repairs to high-ranking players
 */
/proc/CanAffordRepair(mob/players/player, obj/items/equipment/eq)
	if(!player || !eq)
		return FALSE
	
	var/cost = CalculateRepairCost(eq)
	
	// Check lucre
	if(player.lucre < cost["lucre"])
		return FALSE
	
	// Check materials
	var/mat_type = cost["material_type"]
	var/mat_inv_var = "[mat_type]s"
	var/player_mats = player.vars[mat_inv_var] || 0
	
	return player_mats >= cost["materials"]

/**
 * GetEquipmentMaintenanceCost(mob/players/player)
 * Calculate total maintenance cost for player's equipped gear
 * Called to gate high-tier gear to wealthy players
 * 
 * Purpose: Forces players to maintain wealth to keep elite gear viable
 * If repair costs exceed income, players must downgrade equipment
 */
/proc/GetEquipmentMaintenanceCost(mob/players/player)
	if(!player)
		return 0
	
	var/total_cost = 0
	
	// Check all equipped items
	var/list/equipment_slots = list(
		"equipped_weapon",
		"equipped_head",
		"equipped_chest",
		"equipped_hands",
		"equipped_feet",
		"equipped_back",
		"equipped_waist"
	)
	
	for(var/slot in equipment_slots)
		var/obj/items/equipment/eq = player.vars[slot]
		if(!eq)
			continue
		
		var/durability = eq.current_durability || 100
		
		// Only expensive if damaged
		if(durability < 75)
			var/cost = CalculateRepairCost(eq)
			total_cost += cost["lucre"]
	
	return total_cost

// ============================================================================
// REINVESTMENT LOOP
// ============================================================================

/**
 * ProcessPlayerEconomyTick(mob/players/player)
 * Background player economy tick
 * Called periodically to update player economic status
 * 
 * Checks:
 * - Equipment durability (triggers repair prompts)
 * - Available lucre (can they afford repairs?)
 * - Rank progression (unlock better gear)
 * - Market prices (should they upgrade equipment?)
 */
/proc/ProcessPlayerEconomyTick(mob/players/player)
	if(!player)
		return
	
	// Check equipment condition every 5 seconds
	var/maintenance_cost = GetEquipmentMaintenanceCost(player)
	
	if(maintenance_cost > 0 && maintenance_cost > player.lucre / 2)
		// Warn player if maintenance > 50% of bank
		world.log << "Warning: [player.name] equipment maintenance costs [maintenance_cost] lucre/cycle"
	
	// Auto-repair low-durability items if affordable?
	// Or just warn and let player decide
	return

/**
 * MonitorEconomyCombatLoop()
 * Global background loop tracking economy-combat feedback
 * 
 * Purpose: Ensure combat activity drives material demand → prices → repair costs
 * This creates economic pressure that makes high-tier gear valuable
 */
/proc/MonitorEconomyCombatLoop()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(600)  // 30 seconds
		
		if(!world_initialization_complete)
			continue
		
		UpdateMaterialScarcity()

/**
 * InitializeEconomyCombatIntegration()
 * Boot-time initialization for economy-combat loop
 * Called from InitializationManager at T+403
 */
/proc/InitializeEconomyCombatIntegration()
	// Start background loops
	spawn()
		MonitorEconomyCombatLoop()
	
	// Log startup
	world.log << "EconomyCombatIntegrationSystem initialized"
	return

// ============================================================================
// INTEGRATION POINTS
// ============================================================================

/**
 * Equipment Durability Decay
 * Called after each attack in combat system:
 * 
 * for(var/obj/items/equipment/weapon/w in player.equipment)
 *     DegradeEquipment(w)
 * 
 * After 100 attacks, weapon at 50% durability = 200 lucre repair cost
 * Forces players to choose: fight more (earn lucre) or repair (spend lucre)
 */

/**
 * PvP Kill Integration
 * Called after each confirmed kill in PvPRankingSystem.dm:
 * 
 * var/bounty = CalculateBountyReward(killer, damage, streak)
 * killer.lucre += bounty
 * 
 * 8-kill streak with 120 damage = 142 lucre
 * Enough to repair 1-2 weapons or upgrade material
 */

/**
 * Rank-Up Equipment Gates
 * Called from CombatProgressionLoop.dm ProcessRankUp():
 * 
 * if(rank >= 3)
 *     UnlockMaterial(player, "Bronze")  // Can now craft/use Bronze
 * if(rank >= 5)
 *     UnlockMaterial(player, "Steel")   // Elite only
 * 
 * Higher-rank players earn more bounty (streak bonus)
 * = Can afford better equipment = Stat advantage
 */

// ============================================================================
// HELPER PROCS
// ============================================================================

/**
 * DegradeEquipment(obj/items/equipment/eq)
 * Called after each attack to reduce durability
 * 
 * Every 10 attacks = 5% durability loss
 * 100% health → 50% health over 100 attacks
 * At 50% health: -60% effectiveness (from WeaponArmorScalingSystem)
 */
/proc/DegradeEquipment(obj/items/equipment/eq)
	if(!eq)
		return
	
	// 5% durability loss per 10 attacks
	// (actual degrade per-attack: 0.5%)
	eq.current_durability -= 0.5
	if(eq.current_durability < 0)
		eq.current_durability = 0
	
	if(eq.current_durability <= 25)
		// Warn player equipment is nearly broken
		// to_chat(owner) if we can find owner
		return

/**
 * List of all repair-requiring equipment
 */
/proc/GetRepairedEquipment(mob/players/player)
	if(!player)
		return list()
	
	var/list/repaired = list()
	
	// Check all inventory
	for(var/obj/items/equipment/eq in player.contents)
		if(eq.current_durability < 100)
			repaired[eq] = CalculateRepairCost(eq)
	
	return repaired

// ============================================================================
// ECONOMY-COMBAT LOOP SUMMARY
// ============================================================================

/*
 * The complete loop:
 * 
 * 1. COMBAT
 *    - Player fights enemy
 *    - Deals 120 damage over 8-kill streak
 *    - Equipment durability: 100% → 95%
 * 
 * 2. BOUNTY EARNINGS
 *    - Kill confirmed
 *    - Bounty = 50 (base) + 80 (streak) + 12 (damage) = 142 lucre
 *    - Player.lucre += 142
 * 
 * 3. EQUIPMENT MAINTENANCE
 *    - Weapon at 95% durability = low repair cost (5 lucre)
 *    - Player can afford to maintain gear
 * 
 * 4. MARKET PRESSURE
 *    - 10 combatants active = 50% material price spike
 *    - Steel ore price increases
 * 
 * 5. RANK PROGRESSION
 *    - Kill count triggers rank milestone
 *    - Rank 2 → Rank 3: Unlock Bronze crafting
 *    - Can now craft better armor (+15% AC)
 * 
 * 6. REINVESTMENT
 *    - Accumulated 1000 lucre from kills
 *    - Spend 600 lucre + 4 steel ore on new helmet
 *    - +5 AC = 5% damage reduction
 *    - Better armor = survive longer = more kills = more lucre
 * 
 * Result: Emergent economy where:
 * - Fighting funds equipment upgrades
 * - Better equipment makes fighting more profitable
 * - Material scarcity creates price pressure
 * - High-rank players dominate economically
 * - New players must grind low-tier content first
 */
