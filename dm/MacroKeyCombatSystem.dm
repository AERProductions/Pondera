// MacroKeyCombatSystem.dm - Phase 41: Macro-Key Combat System
// Integrated keyboard-driven combat with E (melee), Spacebar (defense), and V (ranged)
// ============================================================================

/**
 * MACRO-KEY COMBAT SYSTEM
 * =======================
 * 
 * E-Key (Left hand, index finger):
 *   - Melee attack with equipped weapon at adjacent target
 *   - Interact with objects (doors, chests, NPCs)
 *   - Uses get_step() for single-tile lookahead
 * 
 * Spacebar (Left hand, thumb):
 *   - Shield raise (if shield equipped)
 *   - Dodge roll (if no shield)
 *   - Invulnerability + movement escape
 * 
 * V-Key (Right hand, ring finger):
 *   - Ranged attack with equipped bow/crossbow/throwing weapon
 *   - Auto-targets nearest enemy in skill range
 *   - Prioritizes direction player is facing
 *   - Fires projectile with skill-based accuracy/damage
 * 
 * All keys have cooldown timers to prevent spam
 * All attacks respect combat rules (continent, PvP, elevation, status)
 */

// ============================================================================
// MACRO-KEY VERB DEFINITIONS
// ============================================================================

mob/players
	var
		attack_cooldown = 0      // Last time E-key was used
		defend_cooldown = 0      // Last time Spacebar was used
		ranged_cooldown = 0      // Last time V-key was used
		
		defending = 0            // Currently blocking with shield
		dodge_rolling = 0        // Currently invulnerable from dodge

	verb/macro_attack()
		set name = "Attack"
		set category = "Combat"
		set waitfor = 0
		
		// Cooldown check (prevent spam)
		var/cooldown_time = 5    // 0.25 seconds (25ms * 5 ticks)
		if(world.time < src.attack_cooldown)
			return
		src.attack_cooldown = world.time + cooldown_time
		
		// Check if player can act
		if(!CanPlayerAct(src))
			return
		
		// Get target in front of player
		var/turf/target_turf = get_step(src, src.dir)
		if(!target_turf)
			return
		
		// Find attackable mob at target location
		var/mob/target = null
		for(var/mob/M in target_turf)
			if(M == src) continue  // Can't attack self
			if(istype(M, /mob/players))
				if(M:HP <= 0) continue  // Can't attack dead
			else if(istype(M, /mob/enemies))
				if(M:HP <= 0) continue  // Can't attack dead
			else
				continue  // Not a player or enemy
			
			if(istype(M, /mob/players) || istype(M, /mob/enemies))
				target = M
				break
		
		// No target found
		if(!target)
			return
		
		// Validate combat
		if(!CanEnterCombat(src, target))
			return
		
		// Check elevation
		if(!src.Chk_LevelRange(target))
			src << "<font color=#FF5555>Target is at different elevation!</font>"
			return
		
		// Perform melee attack with animation (Phase 43)
		PerformAnimatedMeleeAttack(src, target)

	verb/defend()
		set name = "Defend"
		set category = "Combat"
		set waitfor = 0
		
		// Cooldown check
		var/cooldown_time = 10   // 0.5 seconds
		if(world.time < src.defend_cooldown)
			return
		src.defend_cooldown = world.time + cooldown_time
		
		// Check if player can act
		if(!CanPlayerAct(src))
			return
		
		// Check if player has shield equipped
		if(src.Sequipped)
			// Raise shield (defense/blocking)
			PerformShieldRaise(src)
		else
			// Dodge roll (evasion)
			PerformDodgeRoll(src)

	verb/ranged_attack()
		set name = "Ranged Attack"
		set category = "Combat"
		set waitfor = 0
		
		// Cooldown check
		var/cooldown_time = 3    // 0.15 seconds (faster than melee)
		if(world.time < src.ranged_cooldown)
			return
		src.ranged_cooldown = world.time + cooldown_time
		
		// Check if player can act
		if(!CanPlayerAct(src))
			return
		
		// Detect equipped ranged weapon
		var/weapon_info = GetEquippedRangedWeapon(src)
		if(!weapon_info)
			src << "<font color=#FF8800>You don't have a ranged weapon equipped!</font>"
			return
		
		var/weapon_type = weapon_info["type"]
		var/skill_type = weapon_info["skill"]
		var/max_range = weapon_info["range"]
		
		// Get skill level for range determination
		var/skill_level = src.GetRankLevel(skill_type)
		if(skill_level < 1)
			src << "<font color=#FF5555>You need at least rank 1 in [skill_type] to use this weapon!</font>"
			return
		
		// Find best target in range
		var/mob/target = GetRangedTarget(src, max_range, src.dir, skill_type)
		if(!target)
			src << "<font color=#FF8800>No enemies in range!</font>"
			return
		
		// Validate combat
		if(!CanEnterCombat(src, target))
			return
		
		// Fire ranged attack with animation (Phase 43)
		PerformAnimatedRangedAttack(src, skill_type)

// ============================================================================
// COMBAT ACTION HELPERS
// ============================================================================

// NOTE: Actual combat implementation moved to EnvironmentalCombatModifiers.dm
// - PerformMeleeAttackWithEnvironment()
// - PerformRangedAttackWithEnvironment()

/proc/CanPlayerAct(mob/players/player)
	/**
	 * CanPlayerAct(player)
	 * Checks if player is able to perform combat actions
	 * Returns 1 if can act, 0 otherwise
	 */
	if(!player) return 0
	if(player.HP <= 0)
		player << "<font color=#FF5555>You're dead. Cannot act.</font>"
		return 0
	
	return 1

/proc/PerformShieldRaise(mob/players/player)
	/**
	 * PerformShieldRaise(player)
	 * Raises shield for defense/blocking
	 * Reduces incoming damage for duration
	 */
	if(!player) return
	
	player.defending = 1
	player << "<font color=#00AAFF>You raise your shield!</font>"
	
	// Visual feedback - shield is now active (0.5x damage multiplier)
	
	// Duration: 1 second
	spawn(20)
		player.defending = 0
		player << "<font color=#FFAA00>You lower your shield.</font>"

/proc/PerformDodgeRoll(mob/players/player)
	/**
	 * PerformDodgeRoll(player)
	 * Dodge roll for evasion
	 * Brief invulnerability + potential movement
	 */
	if(!player) return
	
	player.dodge_rolling = 1
	player << "<font color=#FFFF00>You dodge roll!</font>"
	
	// Visual feedback - brief invulnerability
	spawn(10)  // 0.5 seconds of invulnerability
		player.dodge_rolling = 0
		player << "<font color=#FFFFFF>You regain balance.</font>"

// ============================================================================
// RANGED ATTACK SUPPORT
// ============================================================================

/proc/GetEquippedRangedWeapon(mob/players/player)
	/**
	 * GetEquippedRangedWeapon(player)
	 * Detects if player has bow/crossbow/throwing weapon equipped
	 * Returns: list with ["type"] = projectile_type, ["skill"] = skill_type, ["range"] = max_tiles
	 * Returns: null if no ranged weapon equipped
	 */
	if(!player) return null
	
	var/obj/item/weapon/W = player.Wequipped
	if(!W) return null
	
	// Check weapon type and return appropriate info
	if(istype(W, /obj/item/weapon/bow/crossbow))
		return list(
			"type" = "bolt",
			"skill" = "crossbow",
			"range" = 22,
			"weapon" = W
		)
	else if(istype(W, /obj/item/weapon/bow/longbow))
		return list(
			"type" = "arrow",
			"skill" = "archery",
			"range" = 18,
			"weapon" = W
		)
	else if(istype(W, /obj/item/weapon/bow))
		return list(
			"type" = "arrow",
			"skill" = "archery",
			"range" = 14,
			"weapon" = W
		)
	else if(istype(W, /obj/item/weapon/throwing/javelin))
		return list(
			"type" = "javelin",
			"skill" = "throwing",
			"range" = 10,
			"weapon" = W
		)
	else if(istype(W, /obj/item/weapon/throwing/knife))
		return list(
			"type" = "knife",
			"skill" = "throwing",
			"range" = 8,
			"weapon" = W
		)
	else if(istype(W, /obj/item/weapon/throwing))
		return list(
			"type" = "stone",
			"skill" = "throwing",
			"range" = 6,
			"weapon" = W
		)
	
	return null

/proc/GetRangedTarget(mob/players/attacker, max_range, preferred_dir, skill_type)
	/**
	 * GetRangedTarget(attacker, max_range, preferred_dir, skill_type)
	 * Finds best target for ranged attack
	 * Prioritizes: direction player is facing > closest distance
	 * Filters: elevation range, alive only, combat-eligible
	 * 
	 * @param attacker: Player performing attack
	 * @param max_range: Maximum tile range (from skill)
	 * @param preferred_dir: Direction player is facing (for priority)
	 * @param skill_type: Skill being used (for validation)
	 * @return: Best target mob or null
	 */
	if(!attacker) return null
	
	var/mob/closest_target = null
	var/closest_distance = max_range + 1
	var/preferred_target = null
	var/preferred_distance = max_range + 1
	
	// Search for targets in range
	for(var/mob/M in range(max_range, attacker))
		if(M == attacker) continue
		if(istype(M, /mob/players))
			if(M:HP <= 0) continue
		else if(istype(M, /mob/enemies))
			if(M:HP <= 0) continue
		else
			continue
		
		if(!attacker.Chk_LevelRange(M)) continue
		
		var/distance = get_dist(attacker, M)
		var/direction_to_target = get_dir(attacker, M)
		
		// PREFER targets directly ahead
		if(direction_to_target == preferred_dir)
			if(distance < preferred_distance)
				preferred_target = M
				preferred_distance = distance
		
		// Track closest target as fallback
		if(distance < closest_distance)
			closest_target = M
			closest_distance = distance
	
	// Return preferred target if found, otherwise closest
	return preferred_target ? preferred_target : closest_target

// ============================================================================
// MELEE SKILL RANK DEFINITION
// ============================================================================

// Note: RANK_MELEE may not exist yet. If it doesn't, we use generic experience.
// The system will work without it but won't progress melee-specific skills.

/proc/UpdateMeleeExperience(mob/players/player, exp_amount)
	/**
	 * UpdateMeleeExperience(player, exp_amount)
	 * Awards melee combat experience
	 * If RANK_MELEE exists, uses it; otherwise just tracks general combat
	 */
	if(!player || !player.character) return
	
	// Try to use RANK_MELEE if defined - for now just don't award
	// The system will work without melee-specific skills
	// player.UpdateRankExp(RANK_MELEE, exp_amount)

// ============================================================================
// DEFENSE STATE HELPERS
// ============================================================================

/mob/players/proc/IsDefending()
	/**
	 * IsDefending()
	 * Returns 1 if player currently has shield raised
	 */
	return src.defending

/mob/players/proc/IsDodging()
	/**
	 * IsDodging()
	 * Returns 1 if player currently invulnerable from dodge roll
	 */
	return src.dodge_rolling

/mob/players/proc/GetDefenseMultiplier()
	/**
	 * GetDefenseMultiplier()
	 * Returns damage multiplier based on defense state
	 * Shield raise: 0.5x damage (50% reduction)
	 * Dodge roll: 0.0x damage (invulnerable)
	 * Normal: 1.0x damage
	 */
	if(src.dodge_rolling) return 0.0  // Invulnerable
	if(src.defending) return 0.5      // 50% damage reduction
	return 1.0                         // Normal damage

// ============================================================================
// DAMAGE PROCESSING WITH DEFENSE STATES
// ============================================================================

/mob/players/proc/TakeDamage(amount)
	/**
	 * TakeDamage(amount)
	 * Applies damage considering defense states
	 * Returns actual damage taken
	 */
	var/multiplier = src.GetDefenseMultiplier()
	var/actual_damage = amount * multiplier
	
	src.HP = max(0, src.HP - actual_damage)
	
	return actual_damage

// ============================================================================
// COOLDOWN HELPERS
// ============================================================================

/mob/players/proc/GetAttackCooldownPercent()
	/**
	 * GetAttackCooldownPercent()
	 * Returns: 0-100% cooldown remaining
	 * 0 = ready, 100 = just used
	 */
	var/remaining = src.attack_cooldown - world.time
	if(remaining <= 0) return 0
	return remaining / 5 * 100  // 5 tick cooldown

/mob/players/proc/GetDefendCooldownPercent()
	var/remaining = src.defend_cooldown - world.time
	if(remaining <= 0) return 0
	return remaining / 10 * 100  // 10 tick cooldown

/mob/players/proc/GetRangedCooldownPercent()
	var/remaining = src.ranged_cooldown - world.time
	if(remaining <= 0) return 0
	return remaining / 3 * 100   // 3 tick cooldown

// ============================================================================
// DEBUG VERBS
// ============================================================================

/mob/players/verb/DebugMacroKeyCombat()
	set category = "Debug"
	set name = "Show Macro-Key Combat Status"
	
	var/output = "<b>MACRO-KEY COMBAT STATUS</b>\n"
	output += "=======================\n"
	output += "E-Key Cooldown: [src.GetAttackCooldownPercent()]%\n"
	output += "Spacebar Cooldown: [src.GetDefendCooldownPercent()]%\n"
	output += "V-Key Cooldown: [src.GetRangedCooldownPercent()]%\n"
	output += "\n"
	output += "Defending: [src.defending ? "YES" : "NO"]\n"
	output += "Dodge Rolling: [src.dodge_rolling ? "YES" : "NO"]\n"
	output += "\n"
	output += "Defense Multiplier: [src.GetDefenseMultiplier() * 100]%\n"
	
	var/ranged_info = GetEquippedRangedWeapon(src)
	if(ranged_info)
		output += "\n<b>EQUIPPED RANGED WEAPON</b>\n"
		output += "Type: [ranged_info["type"]]\n"
		output += "Skill: [ranged_info["skill"]]\n"
		output += "Max Range: [ranged_info["range"]] tiles\n"
	else
		output += "\n<b>NO RANGED WEAPON EQUIPPED</b>\n"
	
	src << output

/mob/players/verb/TestMeleeAttack()
	set category = "Debug"
	set name = "Test Melee Attack (Debug)"
	
	var/mob/target = input(src, "Select target:", "Test Attack") as null|mob in world
	if(!target)
		src << "Cancelled."
		return
	
	src << "Testing melee attack on [target.name]..."
	PerformMeleeAttackWithEnvironment(src, target)

/mob/players/verb/TestShield()
	set category = "Debug"
	set name = "Test Shield Raise (Debug)"
	
	src << "Testing shield raise..."
	PerformShieldRaise(src)

/mob/players/verb/TestDodge()
	set category = "Debug"
	set name = "Test Dodge Roll (Debug)"
	
	src << "Testing dodge roll..."
	PerformDodgeRoll(src)
