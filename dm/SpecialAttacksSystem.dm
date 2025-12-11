/**
 * SpecialAttacksSystem.dm
 * Phase 17: Special Attacks & Skills
 * 
 * Purpose: Combat actions with resource costs and cooldowns
 * - Special attacks (slash, thrust, block, riposte, power attack)
 * - Stamina/mana resource management
 * - Attack cooldown tracking per action
 * - Skill-based unlocks (higher ranks = new attacks)
 * - Damage scaling from weapon + attack type + skill level
 * 
 * Architecture:
 * - /datum/attack_action: Single attack definition
 * - /datum/combat_state: Player's current combat status
 * - Integration: CombatSystem + WeaponArmorScalingSystem + UnifiedRankSystem
 * 
 * Tick Schedule:
 * - T+399: Special attacks system initialization
 * - T+400: Register attack recipes
 */

// ============================================================================
// ATTACK ACTION DATUM
// ============================================================================

/datum/attack_action
	/**
	 * attack_action
	 * Definition of a single attack ability
	 * Can be weapon-based or unarmed
	 */
	var
		// Identification
		action_name = ""
		action_type = ""
		weapon_requirement = ""
		
		// Resource costs
		stamina_cost = 0
		mana_cost = 0
		lucre_cost = 0
		
		// Cooldown
		cooldown_ticks = 0
		
		// Damage & effects
		base_damage_multiplier = 1.0
		critical_chance = 0
		critical_multiplier = 1.5
		
		// Requirements
		minimum_rank = 1
		required_skill = ""
		
		// Description
		desc = ""
		animation = ""

/datum/attack_action/New()
	..()

// ============================================================================
// BASIC MELEE ATTACKS
// ============================================================================

/proc/CreateSlashAttack()
	/**
	 * CreateSlashAttack()
	 * Basic slash attack - foundation of melee combat
	 */
	
	var/datum/attack_action/slash = new()
	slash.action_name = "Slash"
	slash.action_type = "melee"
	slash.weapon_requirement = "sword"
	slash.stamina_cost = 10
	slash.cooldown_ticks = 6
	slash.base_damage_multiplier = 1.0
	slash.critical_chance = 5
	slash.minimum_rank = 1
	slash.desc = "A swift horizontal cut. Bread and butter attack."
	slash.animation = "slash"
	
	return slash

/proc/CreateThrustAttack()
	/**
	 * CreateThrustAttack()
	 * Precision thrust attack - high accuracy, lower damage
	 */
	
	var/datum/attack_action/thrust = new()
	thrust.action_name = "Thrust"
	thrust.action_type = "melee"
	thrust.weapon_requirement = "sword"
	thrust.stamina_cost = 12
	thrust.cooldown_ticks = 8
	thrust.base_damage_multiplier = 1.2
	thrust.critical_chance = 15
	thrust.minimum_rank = 2
	thrust.desc = "A precise stab targeting weak points. Requires Rank 2."
	thrust.animation = "thrust"
	
	return thrust

/proc/CreatePowerAttackAction()
	/**
	 * CreatePowerAttackAction()
	 * Slow but devastating attack - leaves player vulnerable
	 */
	
	var/datum/attack_action/power = new()
	power.action_name = "Power Attack"
	power.action_type = "melee"
	power.weapon_requirement = "sword"
	power.stamina_cost = 25
	power.cooldown_ticks = 20
	power.base_damage_multiplier = 2.0
	power.critical_chance = 10
	power.minimum_rank = 3
	power.desc = "Unleash maximum force. High risk, high reward. Requires Rank 3."
	power.animation = "power_attack"
	
	return power

/proc/CreateBlockAction()
	/**
	 * CreateBlockAction()
	 * Defensive stance - reduces incoming damage
	 */
	
	var/datum/attack_action/block = new()
	block.action_name = "Block"
	block.action_type = "defense"
	block.weapon_requirement = "shield"
	block.stamina_cost = 5
	block.cooldown_ticks = 0
	block.base_damage_multiplier = 0
	block.critical_chance = 0
	block.minimum_rank = 1
	block.desc = "Raise shield to reduce incoming damage by 30%."
	block.animation = "block"
	
	return block

/proc/CreateRiposteAction()
	/**
	 * CreateRiposteAction()
	 * Counter-attack - high damage when enemy misses
	 */
	
	var/datum/attack_action/riposte = new()
	riposte.action_name = "Riposte"
	riposte.action_type = "melee"
	riposte.weapon_requirement = "sword"
	riposte.stamina_cost = 15
	riposte.cooldown_ticks = 12
	riposte.base_damage_multiplier = 1.5
	riposte.critical_chance = 25
	riposte.critical_multiplier = 2.0
	riposte.minimum_rank = 4
	riposte.desc = "Counter-strike following enemy attack. Requires Rank 4."
	riposte.animation = "riposte"
	
	return riposte

// ============================================================================
// RANGED ATTACKS
// ============================================================================

/proc/CreateBowShotAction()
	/**
	 * CreateBowShotAction()
	 * Basic ranged attack with bow
	 */
	
	var/datum/attack_action/bow = new()
	bow.action_name = "Bow Shot"
	bow.action_type = "ranged"
	bow.weapon_requirement = "bow"
	bow.stamina_cost = 8
	bow.cooldown_ticks = 12
	bow.base_damage_multiplier = 0.9
	bow.critical_chance = 20
	bow.minimum_rank = 1
	bow.desc = "Fire an arrow. Works from range."
	bow.animation = "bow_shot"
	
	return bow

/proc/CreateChargedShotAction()
	/**
	 * CreateChargedShotAction()
	 * Powerful ranged attack with charge time
	 */
	
	var/datum/attack_action/charged = new()
	charged.action_name = "Charged Shot"
	charged.action_type = "ranged"
	charged.weapon_requirement = "bow"
	charged.stamina_cost = 20
	charged.cooldown_ticks = 30
	charged.base_damage_multiplier = 2.5
	charged.critical_chance = 30
	charged.critical_multiplier = 2.5
	charged.minimum_rank = 3
	charged.desc = "Draw back and fire a devastating shot. Requires Rank 3."
	charged.animation = "charged_shot"
	
	return charged

// ============================================================================
// COMBAT STATE TRACKER
// ============================================================================

/datum/combat_state
	/**
	 * combat_state
	 * Tracks a player's current combat status
	 */
	var
		// Current state
		player_ref = null
		in_combat = FALSE
		current_opponent = null
		
		// Resource tracking
		current_stamina = 100
		max_stamina = 100
		current_mana = 50
		max_mana = 50
		list/action_cooldowns = list()
		
		// Combat stats
		attacks_made = 0
		damage_dealt = 0
		damage_taken = 0
		
		// Buffs/debuffs
		list/active_effects = list()

/datum/combat_state/New(mob/players/player)
	..()
	player_ref = player
	current_stamina = 100
	max_stamina = 100
// ATTACK EXECUTION
// ============================================================================

/proc/ExecuteAttack(mob/players/attacker, datum/attack_action/action, mob/defender)
	/**
	 * ExecuteAttack(mob/players/attacker, datum/attack_action/action, mob/defender)
	 * Execute an attack action
	 * Returns: Damage dealt
	 */
	
	if(!attacker || !action || !defender)
		return 0
	
	// Get attacker's combat state
	var/datum/combat_state/state = attacker.vars["combat_state"]
	if(!state)
		state = new /datum/combat_state(attacker)
		attacker.vars["combat_state"] = state
	
	// Check stamina
	if(state.current_stamina < action.stamina_cost)
		attacker << "<font color=#FF5555>Not enough stamina for [action.action_name]!</font>"
		return 0
	
	// Check cooldown
	if(state.action_cooldowns[action.action_name] && state.action_cooldowns[action.action_name] > world.time)
		var/remaining = (state.action_cooldowns[action.action_name] - world.time) / 10.0
		attacker << "<font color=#FF5555>[action.action_name] on cooldown for [remaining]s</font>"
		return 0
	
	// Check weapon requirement
	// Framework: Verify attacker has required weapon equipped
	
	// Check skill requirement
	// Framework: Check if attacker has required rank in skill
	
	// ─────────────────────────────────────────────────────────────────────
	// DAMAGE CALCULATION
	// ─────────────────────────────────────────────────────────────────────
	
	// Get base weapon damage
	var/base_weapon_damage = 15
	
	// Apply attack multiplier
	var/attack_damage = base_weapon_damage * action.base_damage_multiplier
	var/is_critical = FALSE
	if(rand(1, 100) <= action.critical_chance)
		is_critical = TRUE
		attack_damage *= action.critical_multiplier
	
	// Apply armor reduction
	var/armor_defense = 5
	attack_damage = attack_damage * (100 - armor_defense) / 100.0
	var/damage_variance = attack_damage * (rand(90, 110) / 100.0)
	attack_damage = damage_variance
	// APPLY DAMAGE & EFFECTS
	// ─────────────────────────────────────────────────────────────────────
	
	// Reduce defender HP
	if(istype(defender, /mob/players))
		var/mob/players/pdef = defender
		pdef.HP -= attack_damage
	
	// Reduce weapon durability
	var/obj/items/equipment/weapon = attacker.vars["equipped_weapon"]
	if(weapon)
		DecrementDurability(weapon, attack_damage)
	
	// Reduce armor durability
	var/obj/items/equipment/armor = defender.vars["equipped_armor"]
	if(armor)
		DecrementDurability(armor, attack_damage)
	
	// ─────────────────────────────────────────────────────────────────────
	// UPDATE COMBAT STATE
	// ─────────────────────────────────────────────────────────────────────
	
	// Consume stamina
	state.current_stamina -= action.stamina_cost
	if(state.current_stamina < 0)
		state.current_stamina = 0
	state.action_cooldowns[action.action_name] = world.time + action.cooldown_ticks
	
	// Track stats
	state.attacks_made++
	state.damage_dealt += attack_damage
	state.in_combat = TRUE
	// FEEDBACK
	// ─────────────────────────────────────────────────────────────────────
	
	var/crit_text = is_critical ? " <font color=#FFFF00>***CRIT***</font>" : ""
	var/damage_text = "[attack_damage]"
	
	attacker << "<font color=#00FF00>[action.action_name]</font> on [defender.name] for [damage_text] damage[crit_text]"
	
	if(istype(defender, /mob/players))
		var/mob/players/pdef = defender
		pdef << "<font color=#FF5555>[attacker.name] uses [action.action_name] for [damage_text] damage[crit_text]</font>"
	
	return attack_damage

// ============================================================================
// STAMINA MANAGEMENT
// ============================================================================

/proc/RegenerateStamina(mob/players/player, amount)
	/**
	 * RegenerateStamina(mob/players/player, amount)
	 * Restore stamina to player
	 */
	
	if(!player)
		return FALSE
	
	var/datum/combat_state/state = player.vars["combat_state"]
	if(!state)
		return FALSE
	
	state.current_stamina += amount
	if(state.current_stamina > state.max_stamina)
		state.current_stamina = state.max_stamina
	
	return TRUE

/proc/GetStaminaPercent(mob/players/player)
	/**
	 * GetStaminaPercent(mob/players/player)
	 * Get stamina as percentage
	 * Returns: 0-100
	 */
	
	if(!player)
		return 0
	
	var/datum/combat_state/state = player.vars["combat_state"]
	if(!state)
		return 0
	
	return (state.current_stamina / state.max_stamina) * 100

/proc/IsStaminaLow(mob/players/player)
	/**
	 * IsStaminaLow(mob/players/player)
	 * Check if stamina is critically low
	 * Returns: TRUE if below 20%
	 */
	
	var/stamina_percent = GetStaminaPercent(player)
	return stamina_percent < 20

// ============================================================================
// ATTACK REGISTRY & LEARNING
// ============================================================================

var/global/list/attack_registry = list()

/proc/InitializeSpecialAttacks()
	/**
	 * InitializeSpecialAttacks()
	 * Called from InitializationManager.dm at T+399
	 * Register all attack actions
	 */
	
	// Create and register all attacks
	attack_registry["Slash"] = CreateSlashAttack()
	attack_registry["Thrust"] = CreateThrustAttack()
	attack_registry["Power Attack"] = CreatePowerAttackAction()
	attack_registry["Block"] = CreateBlockAction()
	attack_registry["Riposte"] = CreateRiposteAction()
	attack_registry["Bow Shot"] = CreateBowShotAction()
	attack_registry["Charged Shot"] = CreateChargedShotAction()
	
	world.log << "COMBAT: Special attacks system initialized ([attack_registry.len] attacks registered)"
	
	return TRUE

/proc/GetAttack(attack_name)
	/**
	 * GetAttack(attack_name)
	 * Retrieve attack by name from registry
	 * Returns: /datum/attack_action or null
	 */
	
	if(!attack_registry[attack_name])
		return null
	
	return attack_registry[attack_name]

/proc/GetPlayerAttacks(mob/players/player)
	/**
	 * GetPlayerAttacks(mob/players/player)
	 * Get list of attacks player can use (rank-gated)
	 * Returns: list of attack names
	 */
	
	if(!player)
		return list()
	
	var/list/available = list()
	
	for(var/attack_name in attack_registry)
		// Check if rank requirement met
		// Framework: Query player's rank in action.required_skill
		// For now: add all attacks
		available += attack_name
	
	return available

/proc/UnlockAttack(mob/players/player, attack_name)
	/**
	 * UnlockAttack(mob/players/player, attack_name)
	 * Unlock a new attack for player
	 * Returns: TRUE if successful
	 */
	
	if(!player)
		return FALSE
	
	var/list/learned = player.vars["learned_attacks"]
	if(!learned)
		learned = list()
		player.vars["learned_attacks"] = learned
	
	if(attack_name in learned)
		return FALSE  // Already known
	
	learned += attack_name
	
	player << "<font color=#FFFF00>You learned [attack_name]!</font>"
	world.log << "COMBAT: [player.name] learned [attack_name]"
	
	return TRUE

// ============================================================================
// COMBAT LOOP & PASSIVE EFFECTS
// ============================================================================

/proc/CombatProcessor()
	/**
	 * CombatProcessor()
	 * Background loop: Process combat state, stamina regen, cooldowns
	 */
	set background = 1
	set waitfor = 0
	
	var/process_interval = 10
	var/last_process = world.time
	
	while(1)
		sleep(5)
		
		if(world.time - last_process >= process_interval)
			last_process = world.time
			for(var/mob/players/player in world)
				if(!player)
					continue
				
				var/datum/combat_state/state = player.vars["combat_state"]
				if(!state)
					continue
				
				// Passive stamina regen
				if(state.current_stamina < state.max_stamina)
					RegenerateStamina(player, 3)  // Regen 3 per 250ms
				
				// Check for low stamina warning
				if(IsStaminaLow(player) && !player.vars["low_stamina_warned"])
					player << "<font color=#FF5555>WARNING: Low stamina!</font>"
					player.vars["low_stamina_warned"] = TRUE
				else if(!IsStaminaLow(player))
					player.vars["low_stamina_warned"] = FALSE

// ============================================================================
// SKILL-BASED ATTACK PROGRESSION
// ============================================================================

/proc/UnlockAttackBySkill(mob/players/player, skill_name, skill_level)
	/**
	 * UnlockAttackBySkill(mob/players/player, skill_name, skill_level)
	 * Automatically unlock attacks as player advances in skill
	 * Called from SkillRecipeUnlock.dm on rank-up
	 */
	
	if(!player)
		return FALSE
	
	// Determine which attacks unlock at this level
	var/list/attacks_to_unlock = list()
	
	switch(skill_name)
		if("smithing")
			switch(skill_level)
				if(1) attacks_to_unlock += "Slash"
				if(2) attacks_to_unlock += "Thrust"
				if(3) attacks_to_unlock += "Power Attack"
				if(4) attacks_to_unlock += "Riposte"
		
		if("archery")
			switch(skill_level)
				if(1) attacks_to_unlock += "Bow Shot"
				if(3) attacks_to_unlock += "Charged Shot"
	
	// Unlock each attack
	var/unlocked_count = 0
	for(var/attack_name in attacks_to_unlock)
		if(UnlockAttack(player, attack_name))
			unlocked_count++
	
	if(unlocked_count > 0)
		world.log << "COMBAT: [player.name] unlocked [unlocked_count] attack(s) from [skill_name] rank [skill_level]"
	
	return unlocked_count > 0

// ============================================================================
// DEBUG & TESTING
// ============================================================================

/proc/DebugShowAttacks(mob/players/player)
	/**
	 * DebugShowAttacks(mob/players/player)
	 * Display all available attacks and their stats
	 */
	
	if(!player)
		return
	
	player << "\n<font color=#FFFF00>=== AVAILABLE ATTACKS ===</font>"
	
	for(var/attack_name in attack_registry)
		var/datum/attack_action/action = attack_registry[attack_name]
		player << "[action.action_name]: [action.desc]"
		player << "  Cost: [action.stamina_cost] stamina | Cooldown: [action.cooldown_ticks]"
		player << "  Damage: [action.base_damage_multiplier]x | Crit: [action.critical_chance]%"
	
	player << "\n"
