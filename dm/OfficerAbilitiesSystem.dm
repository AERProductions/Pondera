// OfficerAbilitiesSystem.dm - Officer Combat Abilities & Specializations
// Phase 31: Officer special abilities based on class and quality tier
// Each officer class has 5 abilities (1 per level) with unique mechanics

#define ABILITY_SLASH "slash"
#define ABILITY_PIERCE "pierce"
#define ABILITY_CLEAVE "cleave"
#define ABILITY_RALLY "rally"
#define ABILITY_EXECUTE "execute"

#define ABILITY_VOLLEY "volley"
#define ABILITY_RICOCHET "ricochet"
#define ABILITY_MULTISHOT "multishot"
#define ABILITY_BARRAGE "barrage"
#define ABILITY_RAIN "rain_of_arrows"

#define ABILITY_SLASH_COMMAND "slash_command"
#define ABILITY_ARMOR_COMMAND "armor_command"
#define ABILITY_WEAPON_COMMAND "weapon_command"
#define ABILITY_MORALE_COMMAND "morale_command"
#define ABILITY_ULTIMATE_COMMAND "ultimate_command"

#define ABILITY_ANALYZE "analyze_weakness"
#define ABILITY_KITE "kite_target"
#define ABILITY_POSITION "position_strike"
#define ABILITY_PREDICT "predict_move"
#define ABILITY_SHADOW "shadow_strike"

#define ABILITY_INTIMIDATE "intimidate"
#define ABILITY_CHALLENGE "challenge"
#define ABILITY_DOMINATE "dominate"
#define ABILITY_CONQUER "conquer"
#define ABILITY_APOCALYPSE "apocalypse_strike"

// =============================================================================
// Ability Datum & Registry
// =============================================================================

/datum/officer_ability
	var
		ability_id              // Unique ID from #defines above
		ability_name            // Display name
		ability_description     // Flavor text
		class_type              // OFFICER_CLASS_* constant
		level_requirement       // 1-5, when ability unlocks
		cooldown_seconds = 10   // Base cooldown in seconds
		resource_cost = 10      // Base stamina/mana cost
		base_damage_multiplier = 1.0  // Damage modifier
		accuracy_modifier = 0   // Accuracy adjustment (-1.0 to +1.0)
		is_passive = FALSE      // Passive bonus vs active ability
		passive_bonus_type      // Type of passive (damage, defense, speed, etc)
		passive_bonus_value = 1.0  // Bonus multiplier

	New(aid, aname, adesc, ctype, lreq, cd=10, cost=10, dmg=1.0)
		ability_id = aid
		ability_name = aname
		ability_description = adesc
		class_type = ctype
		level_requirement = lreq
		cooldown_seconds = cd
		resource_cost = cost
		base_damage_multiplier = dmg

// Ability registry for each class
var/global/list
	general_abilities = list()      // General class abilities (1-5)
	marshal_abilities = list()      // Marshal class abilities
	captain_abilities = list()      // Captain class abilities
	strategist_abilities = list()   // Strategist class abilities
	warlord_abilities = list()      // Warlord class abilities

	ability_registry = list()       // All abilities by ID

// =============================================================================
// Ability Initialization
// =============================================================================

/proc/InitializeOfficerAbilities()
	set background = 1
	set waitfor = 0
	
	// =========== GENERAL ABILITIES (Tank/Melee) ===========
	var/datum/officer_ability/ab1 = new(ABILITY_SLASH, "Slash", "Basic sword slash", OFFICER_CLASS_GENERAL, 1, 5, 5, 1.2)
	general_abilities += ab1
	ability_registry[ABILITY_SLASH] = ab1
	
	var/datum/officer_ability/ab2 = new(ABILITY_PIERCE, "Pierce", "Armor-piercing thrust", OFFICER_CLASS_GENERAL, 2, 8, 8, 1.5)
	general_abilities += ab2
	ability_registry[ABILITY_PIERCE] = ab2
	
	var/datum/officer_ability/ab3 = new(ABILITY_CLEAVE, "Cleave", "Heavy swing hitting multiple targets", OFFICER_CLASS_GENERAL, 3, 12, 15, 1.8)
	general_abilities += ab3
	ability_registry[ABILITY_CLEAVE] = ab3
	
	var/datum/officer_ability/ab4 = new(ABILITY_RALLY, "Rally", "Boost allies' defense", OFFICER_CLASS_GENERAL, 4, 15, 20, 1.0)
	ab4.is_passive = FALSE
	general_abilities += ab4
	ability_registry[ABILITY_RALLY] = ab4
	
	var/datum/officer_ability/ab5 = new(ABILITY_EXECUTE, "Execute", "Finishing strike on weakened enemies", OFFICER_CLASS_GENERAL, 5, 20, 30, 3.0)
	general_abilities += ab5
	ability_registry[ABILITY_EXECUTE] = ab5
	
	// =========== MARSHAL ABILITIES (Ranged DPS) ===========
	var/datum/officer_ability/ar1 = new(ABILITY_VOLLEY, "Volley", "Fire 3 arrows", OFFICER_CLASS_MARSHAL, 1, 6, 6, 1.1)
	marshal_abilities += ar1
	ability_registry[ABILITY_VOLLEY] = ar1
	
	var/datum/officer_ability/ar2 = new(ABILITY_RICOCHET, "Ricochet", "Arrows bounce between targets", OFFICER_CLASS_MARSHAL, 2, 10, 10, 1.4)
	marshal_abilities += ar2
	ability_registry[ABILITY_RICOCHET] = ar2
	
	var/datum/officer_ability/ar3 = new(ABILITY_MULTISHOT, "Multishot", "Fire 6 arrows at once", OFFICER_CLASS_MARSHAL, 3, 14, 18, 1.7)
	marshal_abilities += ar3
	ability_registry[ABILITY_MULTISHOT] = ar3
	
	var/datum/officer_ability/ar4 = new(ABILITY_BARRAGE, "Barrage", "Rapid-fire volley", OFFICER_CLASS_MARSHAL, 4, 16, 25, 2.0)
	marshal_abilities += ar4
	ability_registry[ABILITY_BARRAGE] = ar4
	
	var/datum/officer_ability/ar5 = new(ABILITY_RAIN, "Rain of Arrows", "Cover area in arrows", OFFICER_CLASS_MARSHAL, 5, 25, 35, 2.5)
	marshal_abilities += ar5
	ability_registry[ABILITY_RAIN] = ar5
	
	// =========== CAPTAIN ABILITIES (Support/Command) ===========
	var/datum/officer_ability/cp1 = new(ABILITY_SLASH_COMMAND, "Slash Command", "Allies gain +10% slash damage", OFFICER_CLASS_CAPTAIN, 1, 0, 5, 1.0)
	cp1.is_passive = TRUE
	cp1.passive_bonus_type = "damage"
	cp1.passive_bonus_value = 1.1
	captain_abilities += cp1
	ability_registry[ABILITY_SLASH_COMMAND] = cp1
	
	var/datum/officer_ability/cp2 = new(ABILITY_ARMOR_COMMAND, "Armor Command", "Allies gain +15% defense", OFFICER_CLASS_CAPTAIN, 2, 0, 10, 1.0)
	cp2.is_passive = TRUE
	cp2.passive_bonus_type = "defense"
	cp2.passive_bonus_value = 1.15
	captain_abilities += cp2
	ability_registry[ABILITY_ARMOR_COMMAND] = cp2
	
	var/datum/officer_ability/cp3 = new(ABILITY_WEAPON_COMMAND, "Weapon Master", "Allies gain +20% weapon damage", OFFICER_CLASS_CAPTAIN, 3, 0, 15, 1.0)
	cp3.is_passive = TRUE
	cp3.passive_bonus_type = "damage"
	cp3.passive_bonus_value = 1.2
	captain_abilities += cp3
	ability_registry[ABILITY_WEAPON_COMMAND] = cp3
	
	var/datum/officer_ability/cp4 = new(ABILITY_MORALE_COMMAND, "Morale Boost", "Nearby allies +25% damage +10% speed", OFFICER_CLASS_CAPTAIN, 4, 18, 25, 1.0)
	cp4.is_passive = TRUE
	cp4.passive_bonus_type = "morale"
	cp4.passive_bonus_value = 1.25
	captain_abilities += cp4
	ability_registry[ABILITY_MORALE_COMMAND] = cp4
	
	var/datum/officer_ability/cp5 = new(ABILITY_ULTIMATE_COMMAND, "Legion Commander", "All nearby effects +30%", OFFICER_CLASS_CAPTAIN, 5, 0, 35, 1.0)
	cp5.is_passive = TRUE
	cp5.passive_bonus_type = "all"
	cp5.passive_bonus_value = 1.3
	captain_abilities += cp5
	ability_registry[ABILITY_ULTIMATE_COMMAND] = cp5
	
	// =========== STRATEGIST ABILITIES (Tactical/Control) ===========
	var/datum/officer_ability/st1 = new(ABILITY_ANALYZE, "Analyze Weakness", "Expose target weakness (+20% damage next hit)", OFFICER_CLASS_STRATEGIST, 1, 7, 8, 1.3)
	strategist_abilities += st1
	ability_registry[ABILITY_ANALYZE] = st1
	
	var/datum/officer_ability/st2 = new(ABILITY_KITE, "Kite Target", "Slow enemy movement by 30%", OFFICER_CLASS_STRATEGIST, 2, 9, 12, 1.0)
	strategist_abilities += st2
	ability_registry[ABILITY_KITE] = st2
	
	var/datum/officer_ability/st3 = new(ABILITY_POSITION, "Position Strike", "Deal 50% more damage from behind", OFFICER_CLASS_STRATEGIST, 3, 11, 16, 1.5)
	strategist_abilities += st3
	ability_registry[ABILITY_POSITION] = st3
	
	var/datum/officer_ability/st4 = new(ABILITY_PREDICT, "Predict Move", "Dodge next 2 attacks", OFFICER_CLASS_STRATEGIST, 4, 13, 20, 1.0)
	strategist_abilities += st4
	ability_registry[ABILITY_PREDICT] = st4
	
	var/datum/officer_ability/st5 = new(ABILITY_SHADOW, "Shadow Strike", "Teleport behind target + 2x damage", OFFICER_CLASS_STRATEGIST, 5, 22, 40, 2.0)
	strategist_abilities += st5
	ability_registry[ABILITY_SHADOW] = st5
	
	// =========== WARLORD ABILITIES (Dominance/Terror) ===========
	var/datum/officer_ability/wr1 = new(ABILITY_INTIMIDATE, "Intimidate", "Enemies -15% accuracy for 5 seconds", OFFICER_CLASS_WARLORD, 1, 8, 10, 1.0)
	wr1.accuracy_modifier = -0.15
	warlord_abilities += wr1
	ability_registry[ABILITY_INTIMIDATE] = wr1
	
	var/datum/officer_ability/wr2 = new(ABILITY_CHALLENGE, "Challenge", "Force 1 enemy to target you", OFFICER_CLASS_WARLORD, 2, 10, 15, 1.0)
	warlord_abilities += wr2
	ability_registry[ABILITY_CHALLENGE] = wr2
	
	var/datum/officer_ability/wr3 = new(ABILITY_DOMINATE, "Dominate", "Stun enemy for 3 seconds", OFFICER_CLASS_WARLORD, 3, 12, 20, 1.2)
	warlord_abilities += wr3
	ability_registry[ABILITY_DOMINATE] = wr3
	
	var/datum/officer_ability/wr4 = new(ABILITY_CONQUER, "Conquer", "Take control of enemy behavior", OFFICER_CLASS_WARLORD, 4, 16, 30, 1.5)
	warlord_abilities += wr4
	ability_registry[ABILITY_CONQUER] = wr4
	
	var/datum/officer_ability/wr5 = new(ABILITY_APOCALYPSE, "Apocalypse", "Massive area damage + fear effect", OFFICER_CLASS_WARLORD, 5, 30, 50, 3.5)
	warlord_abilities += wr5
	ability_registry[ABILITY_APOCALYPSE] = wr5
	
	RegisterInitComplete("OfficerAbilitiesSystem")

// =============================================================================
// Ability Lookup & Learning
// =============================================================================

/**
 * GetAbilitiesForClass(class_type)
 * Returns list of abilities for a given officer class
 */
/proc/GetAbilitiesForClass(class_type)
	switch(class_type)
		if(OFFICER_CLASS_GENERAL)
			return general_abilities
		if(OFFICER_CLASS_MARSHAL)
			return marshal_abilities
		if(OFFICER_CLASS_CAPTAIN)
			return captain_abilities
		if(OFFICER_CLASS_STRATEGIST)
			return strategist_abilities
		if(OFFICER_CLASS_WARLORD)
			return warlord_abilities
	return list()

/**
 * GetAbilityByLevel(class_type, level)
 * Return ability for specific level (1-5)
 */
/proc/GetAbilityByLevel(class_type, level)
	if(level < 1 || level > 5)
		return null
	
	var/list/abilities = GetAbilitiesForClass(class_type)
	if(level > abilities.len)
		return null
	
	return abilities[level]

/**
 * GetAbilityById(ability_id)
 * Lookup ability by ID constant
 */
/proc/GetAbilityById(ability_id)
	return ability_registry[ability_id]

/**
 * LearnAbility(officer, ability)
 * Officer learns an ability at level-up
 */
/proc/LearnAbility(datum/elite_officer/officer, datum/officer_ability/ability)
	if(!officer || !ability)
		return FALSE
	
	// Check level requirement
	if(officer.level < ability.level_requirement)
		return FALSE
	
	// Add to officer's ability list
	if(!officer.abilities)
		officer.abilities = list()
	
	if(!(ability.ability_id in officer.abilities))
		officer.abilities += ability.ability_id
		return TRUE
	
	return FALSE

// =============================================================================
// Ability Execution & Effects
// =============================================================================

/**
 * ExecuteAbility(officer, target, ability_id)
 * Officer uses ability on target
 */
/proc/ExecuteAbility(datum/elite_officer/officer, datum/elite_officer/target, ability_id)
	if(!officer || !ability_id)
		return FALSE
	
	var/datum/officer_ability/ability = GetAbilityById(ability_id)
	if(!ability)
		return FALSE
	
	// Check cooldown
	if(!officer.ability_cooldowns)
		officer.ability_cooldowns = list()
	
	var/last_used = officer.ability_cooldowns[ability_id]
	if(last_used && (world.time - last_used) < (ability.cooldown_seconds * 10))
		return FALSE  // Still on cooldown
	
	// Execute ability effect
	var/success = ApplyAbilityEffect(officer, target, ability)
	
	if(success)
		// Set cooldown
		officer.ability_cooldowns[ability_id] = world.time
		
		// Grant XP for ability use (scaled by quality)
		var/xp_gain = 5 * officer.quality_tier
		officer.experience += xp_gain
		
		return TRUE
	
	return FALSE

/**
 * ApplyAbilityEffect(officer, target, ability)
 * Apply the specific mechanics of an ability
 */
/proc/ApplyAbilityEffect(datum/elite_officer/officer, datum/elite_officer/target, datum/officer_ability/ability)
	if(!officer || !ability)
		return FALSE
	
	var/damage = 0
	
	switch(ability.ability_id)
		// General abilities
		if(ABILITY_SLASH)
			damage = 15 * (1 + officer.combat_tier * 0.1) * ability.base_damage_multiplier
		if(ABILITY_PIERCE)
			damage = 20 * (1 + officer.combat_tier * 0.15) * ability.base_damage_multiplier
		if(ABILITY_CLEAVE)
			damage = 30 * (1 + officer.combat_tier * 0.2) * ability.base_damage_multiplier
		if(ABILITY_RALLY)
			officer.defense_bonus += 10
			return TRUE
		if(ABILITY_EXECUTE)
			damage = 50 * (1 + officer.combat_tier * 0.3) * ability.base_damage_multiplier
		
		// Marshal abilities
		if(ABILITY_VOLLEY)
			damage = 12 * (1 + officer.combat_tier * 0.08) * ability.base_damage_multiplier
		if(ABILITY_RICOCHET)
			damage = 18 * (1 + officer.combat_tier * 0.12) * ability.base_damage_multiplier
		if(ABILITY_MULTISHOT)
			damage = 25 * (1 + officer.combat_tier * 0.17) * ability.base_damage_multiplier
		if(ABILITY_BARRAGE)
			damage = 35 * (1 + officer.combat_tier * 0.2) * ability.base_damage_multiplier
		if(ABILITY_RAIN)
			damage = 40 * (1 + officer.combat_tier * 0.25) * ability.base_damage_multiplier
		
		// Captain abilities are mostly passive
		if(ABILITY_SLASH_COMMAND, ABILITY_ARMOR_COMMAND, ABILITY_WEAPON_COMMAND, ABILITY_MORALE_COMMAND, ABILITY_ULTIMATE_COMMAND)
			return TRUE
		
		// Strategist abilities
		if(ABILITY_ANALYZE)
			target.damage_vulnerability = 1.2
			return TRUE
		if(ABILITY_KITE)
			target.movement_speed = 0.7
			return TRUE
		if(ABILITY_POSITION)
			damage = 25 * (1 + officer.combat_tier * 0.15) * ability.base_damage_multiplier
		if(ABILITY_PREDICT)
			officer.dodge_chance = 0.5
			return TRUE
		if(ABILITY_SHADOW)
			damage = 40 * (1 + officer.combat_tier * 0.25) * ability.base_damage_multiplier
		
		// Warlord abilities
		if(ABILITY_INTIMIDATE)
			target.accuracy_penalty = -0.15
			return TRUE
		if(ABILITY_CHALLENGE)
			target.loyalty -= 10  // Reduces loyalty on challenge
			return TRUE
		if(ABILITY_DOMINATE)
			target.stunned = 3
			return TRUE
		if(ABILITY_CONQUER)
			target.controlled_by = officer
			return TRUE
		if(ABILITY_APOCALYPSE)
			damage = 75 * (1 + officer.combat_tier * 0.3) * ability.base_damage_multiplier
	
	// Apply damage
	if(damage > 0 && target)
		target.hp -= damage
		if(target.hp <= 0)
			target.is_alive = 0  // Mark officer as dead
		return TRUE
	
	return FALSE

/**
 * DefeatOfficer(officer)
 * Mark officer as defeated and start respawn timer
 */
/proc/DefeatOfficer(datum/elite_officer/officer)
	if(!officer)
		return FALSE
	
	officer.is_alive = 0
	officer.hp = 0
	
	// Respawn after 1 hour
	spawn(36000)
		if(officer)
			officer.is_alive = 1
			officer.hp = officer.max_hp
	
	return TRUE

/**
 * GetAbilityStats(class_type, quality_tier)
 * Return stat bonuses from abilities at current level
 */
/proc/GetAbilityStats(class_type, quality_tier)
	var/list/stats = list()
	stats["damage_bonus"] = 1.0
	stats["defense_bonus"] = 1.0
	stats["speed_bonus"] = 1.0
	
	// Captain class gets ability-based bonuses
	if(class_type == OFFICER_CLASS_CAPTAIN)
		switch(quality_tier)
			if(1)
				stats["damage_bonus"] = 1.1
			if(2)
				stats["defense_bonus"] = 1.15
			if(3)
				stats["damage_bonus"] = 1.2
			if(4)
				stats["damage_bonus"] = 1.25
				stats["speed_bonus"] = 1.1
			if(5)
				stats["damage_bonus"] = 1.3
				stats["defense_bonus"] = 1.3
				stats["speed_bonus"] = 1.15
	
	return stats

// =============================================================================
// Cooldown Management
// =============================================================================

/**
 * ResetAbilityCooldowns(officer)
 * Reset all ability cooldowns (for rest/recovery)
 */
/proc/ResetAbilityCooldowns(datum/elite_officer/officer)
	if(!officer)
		return FALSE
	
	officer.ability_cooldowns = list()
	return TRUE

/**
 * GetAbilityCooldownRemaining(officer, ability_id)
 * Return seconds remaining on cooldown (0 if ready)
 */
/proc/GetAbilityCooldownRemaining(datum/elite_officer/officer, ability_id)
	if(!officer || !ability_id)
		return 0
	
	if(!officer.ability_cooldowns)
		return 0
	
	var/last_used = officer.ability_cooldowns[ability_id]
	if(!last_used)
		return 0
	
	var/datum/officer_ability/ability = GetAbilityById(ability_id)
	if(!ability)
		return 0
	
	var/elapsed = (world.time - last_used) / 10  // Convert ticks to deciseconds
	var/remaining = ability.cooldown_seconds - elapsed
	
	return max(0, remaining)
