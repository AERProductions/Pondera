// UnifiedAttackSystem.dm
// ============================================================================
// UNIFIED COMBAT SYSTEM - Player vs Player, Player vs Enemy, Enemy vs Player
// ============================================================================
// Purpose: Consolidate scattered attack logic into a single, extensible system
// 
// Key Features:
// - Single attack resolution function for all combat types
// - Type-safe damage calculation with armor/defense reduction
// - Hit chance and evasion mechanics
// - Elevation range validation
// - Stamina/mana requirements
// - Special condition handling (buffs, debuffs, status effects)
// - Unified death handling
// 
// Architecture:
// - ResolveAttack(attacker, defender, attack_type) → Boolean success
// - CalcBaseDamage(attacker) → Damage amount
// - CalcDamage(attacker, defender, base_damage) → Reduced damage amount
// - GetHitChance(attacker, defender) → Hit percentage (0-100)
// - CheckSpecialConditions(attacker, defender) → Boolean can_attack

// ============================================================================
// CORE ATTACK RESOLUTION
// ============================================================================

proc/ResolveAttack(mob/players/attacker, mob/defender, attack_type = "physical")
	/**
	 * Universal attack resolution for players attacking targets
	 * Handles both PvP and PvE combat
	 * 
	 * @param attacker: Player attacking (must be /mob/players type)
	 * @param defender: Target mob (player or enemy)
	 * @param attack_type: "physical", "magic", "ranged" (optional)
	 * @return: TRUE if attack succeeds, FALSE if blocked/failed
	 */
	
	if(!attacker || !defender || attacker == defender)
		return FALSE
	
	// VALIDATION PHASE
	// 1. Check elevation range
	if(!attacker.Chk_LevelRange(defender))
		return FALSE  // Different elevation levels
	
	// 2. Check both combatants alive
	if(attacker.HP <= 0 || (istype(defender, /mob/players) && defender:HP <= 0))
		return FALSE  // Can't attack if dead
	
	// 3. Check attacker has stamina
	if(attacker.stamina <= 0)
		return FALSE  // No stamina
	
	// 4. Check special conditions
	if(!CheckSpecialConditions(attacker, defender))
		return FALSE  // Some condition prevents attack
	
	// CALCULATION PHASE
	var/base_damage = CalcBaseDamage(attacker)
	if(base_damage <= 0)
		return FALSE  // No damage to deal
	
	// Check hit chance
	var/hit_chance = GetHitChance(attacker, defender)
	if(!prob(hit_chance))
		// Miss! Still costs stamina
		attacker.stamina = max(0, attacker.stamina - 5)
		return FALSE
	
	// Calculate final damage with armor
	var/final_damage = CalcDamage(attacker, defender, base_damage)
	
	// EXECUTION PHASE
	// Apply stamina cost
	var/stamina_cost = max(5, round(base_damage * 0.5))
	attacker.stamina = max(0, attacker.stamina - stamina_cost)
	
	// Apply damage to defender
	if(istype(defender, /mob/players))
		var/mob/players/PD = defender
		PD.HP = max(0, PD.HP - final_damage)
		PD.updateHP()
	else if(istype(defender, /mob/enemies))
		var/mob/enemies/ED = defender
		ED.HP = max(0, ED.HP - final_damage)
	
	// Display damage feedback
	DisplayDamage(attacker, defender, final_damage)
	
	// Update attacker UI
	attacker.updateHP()
	attacker.updateST()
	
	// Check if defender died
	if(istype(defender, /mob/players) && defender:HP <= 0)
		ResolveDefenderDeath(attacker, defender)
		return TRUE
	else if(istype(defender, /mob/enemies) && defender:HP <= 0)
		ResolveDefenderDeath(attacker, defender)
		return TRUE
	
	return TRUE

proc/CalcBaseDamage(mob/players/attacker)
	/**
	 * Calculate base damage before armor reduction
	 * Uses player's equipped weapon damage stats
	 * 
	 * @param attacker: Player attacking
	 * @return: Base damage amount (1+)
	 */
	
	if(!attacker)
		return 0
	
	// Use weapon damage range if equipped
	var/damage = rand(attacker.tempdamagemin, attacker.tempdamagemax)
	
	return max(1, damage)

proc/CalcDamage(mob/players/attacker, mob/defender, base_damage)
	/**
	 * Calculate final damage after defense reduction
	 * Handles both player and enemy defenders
	 * 
	 * @param attacker: Player attacking
	 * @param defender: Defending mob (player or enemy)
	 * @param base_damage: Damage before reduction
	 * @return: Final damage to apply (minimum 1)
	 */
	
	if(!defender)
		return base_damage
	
	var/defense = 0
	
	// Get defense stat if defender has it
	if(istype(defender, /mob/players))
		var/mob/players/PD = defender
		defense = PD.tempdefense
	else if("tempdefense" in defender.vars)
		defense = defender:tempdefense || 0
	
	// Standard defense calculation (from original code)
	var/damage_reduction = 0
	
	if(defense <= 1050)
		damage_reduction = (((defense) / 10 * (1.05 - (0.0005 * (defense)))) / 100)
	else
		var/resroll = defense - 1050
		damage_reduction = 0.55 + 0.55 * (((resroll) / 10 * (1.05 - (0.0005 * (resroll)))) / 100)
	
	// Clamp damage reduction between 0 and 0.95 (can't block all damage)
	damage_reduction = min(0.95, max(0, damage_reduction))
	
	var/final_damage = round(base_damage * (1 - damage_reduction), 1)
	
	return max(1, final_damage)  // Minimum 1 damage always

proc/GetHitChance(mob/players/attacker, mob/defender)
	/**
	 * Calculate probability of hitting target (0-100)
	 * Handles both player and enemy defenders
	 * 
	 * @param attacker: Player attacking
	 * @param defender: Target mob (player or enemy)
	 * @return: Hit percentage (5-99 range)
	 */
	
	if(!attacker || !defender)
		return 75  // Default 75%
	
	var/base_hit = 75  // 75% base accuracy
	
	// Apply defender evasion if available
	if(istype(defender, /mob/players))
		var/mob/players/PD = defender
		base_hit -= (PD.tempevade / 100) * 40
	else if("tempevade" in defender.vars)
		var/evasion = defender:tempevade || 0
		base_hit -= (evasion / 100) * 40
	
	// Clamp within 5-99% range
	return max(5, min(99, round(base_hit)))

proc/CheckSpecialConditions(mob/players/attacker, mob/defender)
	/**
	 * Check for special conditions that prevent/modify attack
	 * Examples: stun, sleep, frozen, invulnerable buffs, etc.
	 * 
	 * @param attacker: Player attacking
	 * @param defender: Target mob
	 * @return: TRUE if attack can proceed, FALSE if blocked
	 */
	
	// Placeholder for future status effect integration
	// Currently always allows attack to proceed
	return TRUE

proc/DisplayDamage(mob/players/attacker, mob/defender, damage)
	/**
	 * Display damage feedback to both attacker and defender
	 * 
	 * @param attacker: Player attacking
	 * @param defender: Target mob
	 * @param damage: Damage amount dealt
	 */
	
	if(!attacker || !defender)
		return
	
	// Visual feedback at defender location
	if(isobj(defender.loc) || isturf(defender.loc))
		s_damage(defender, damage, "#32cd32")  // Green for damage dealt
	
	// Message to defender
	if(defender.client)
		defender << "<font color='red'><b>[attacker.name] dealt [damage] damage!</b>"
	
	// Message to attacker
	if(attacker.client)
		attacker << "<font color='green'><b>You dealt [damage] damage to [defender.name]!</b>"

proc/ResolveDefenderDeath(mob/players/attacker, mob/defender)
	/**
	 * Handle defender death - unified for all combat types
	 * 
	 * @param attacker: Player that killed the defender
	 * @param defender: Mob that died
	 */
	
	if(!defender)
		return
	
	world << "<font color='red'><b>[defender.name] was defeated by [attacker.name]!</b>"
	
	// Award attacker
	attacker.pvpkills++
	attacker.exp += 100  // Standard exp reward
	
	// Handle defender death based on type
	if(istype(defender, /mob/players))
		var/mob/players/PD = defender
		PD.HP = 1
		PD.location = "Sleep"
		PD.overlays = null
		PD.icon = 'dmi/64/blank.dmi'
		PD.loc = locate(5, 6, 1)  // Respawn at afterlife
	else if(istype(defender, /mob/enemies))
		var/mob/enemies/ED = defender
		ED.loc = null  // Delete enemy
	
	// TODO: Award loot, exp splits for parties, etc.

// ============================================================================
// INTEGRATION HELPERS
// ============================================================================

// s_damage() is already defined in s_damage2.dm - use existing implementation
