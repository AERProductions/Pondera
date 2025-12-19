// EnvironmentalCombatModifiers.dm - Phase 42: Environmental effects on combat
// Wind effects on projectiles, elevation bonuses, cover mechanics, visual feedback
// ============================================================================

/**
 * ENVIRONMENTAL COMBAT MODIFIERS
 * ===============================
 * 
 * Wind System Integration:
 *   - Projectiles affected by wind direction/speed
 *   - Accuracy penalty for cross-wind shots
 *   - Projectile trajectory curve based on wind
 * 
 * Elevation System:
 *   - Higher elevation provides ranged accuracy bonus (+5% per level)
 *   - Higher elevation damage bonus for ranged attacks (+10% per level above target)
 *   - Lower elevation provides melee defense bonus (+5% per level below attacker)
 * 
 * Cover Mechanics:
 *   - Objects provide partial damage reduction
 *   - Line-of-sight checks for blocked attacks
 *   - Cover types: 25% (light), 50% (medium), 75% (heavy)
 * 
 * Combat Visual Feedback:
 *   - Damage numbers floating above targets
 *   - Hit/miss indicators
 *   - Critical hit visual effects
 *   - Projectile impact animations
 */

// ============================================================================
// WIND SYSTEM CONSTANTS
// ============================================================================

#define WIND_NONE 0
#define WIND_NORTH 1
#define WIND_SOUTH 2
#define WIND_EAST 4
#define WIND_WEST 8
#define WIND_SPEED_LIGHT 1
#define WIND_SPEED_MODERATE 2
#define WIND_SPEED_STRONG 3

// ============================================================================
// WIND SYSTEM STATE
// ============================================================================

/datum/wind_state
	var
		direction = WIND_NORTH        // Current wind direction
		speed = WIND_SPEED_LIGHT      // Wind speed (1-3)
		variability = 0.2             // How much wind changes per tick
		next_change = 0               // When wind changes next

/datum/wind_state/New()
	..()
	next_change = world.time + 300

/proc/GetCurrentWind()
	/**
	 * GetCurrentWind()
	 * Returns current wind state from weather system
	 * If weather system not available, returns default calm wind
	 */
	// This would integrate with WeatherSystem.dm if available
	// For now, return a default wind state
	var/datum/wind_state/wind = new
	wind.direction = WIND_NORTH
	wind.speed = WIND_SPEED_LIGHT
	return wind

// ============================================================================
// ELEVATION BONUS SYSTEM
// ============================================================================

/proc/GetElevationAttackBonus(mob/attacker, mob/defender)
	/**
	 * GetElevationAttackBonus(attacker, defender)
	 * Calculates ranged attack bonus from elevation difference
	 * Higher elevation = better accuracy and damage
	 * 
	 * @param attacker: Player performing ranged attack
	 * @param defender: Target mob
	 * @return: Bonus multiplier (1.0 = no bonus, 1.5 = 50% bonus)
	 */
	if(!attacker || !defender) return 1.0
	
	// Check if attacker has elevation advantage
	var/elevation_diff = attacker.elevel - defender.elevel
	
	if(elevation_diff > 0)
		// Attacker is HIGHER - ranged advantage
		// +5% accuracy per level, +10% damage per level
		var/bonus = 1.0 + (elevation_diff * 0.10)  // 10% per level
		return bonus
	else if(elevation_diff < 0)
		// Defender is HIGHER - no bonus (actually penalty, but melee gets defense)
		return 1.0
	
	return 1.0

/proc/GetElevationDefenseBonus(mob/melee_attacker, mob/defender)
	/**
	 * GetElevationDefenseBonus(melee_attacker, defender)
	 * Calculates melee defense bonus from elevation
	 * Lower elevation = better defense against melee
	 * 
	 * @param melee_attacker: Player performing melee attack
	 * @param defender: Target mob
	 * @return: Defense multiplier (0.95 = 5% damage reduction, 1.0 = no bonus)
	 */
	if(!melee_attacker || !defender) return 1.0
	
	// Check if defender is LOWER - melee defense advantage
	var/elevation_diff = defender.elevel - melee_attacker.elevel
	
	if(elevation_diff > 0)
		// Defender is HIGHER - no defense bonus
		return 1.0
	else if(elevation_diff < 0)
		// Defender is LOWER - melee defense bonus
		// -5% damage per level (damage multiplier 0.95, 0.90, etc.)
		var/defense = 1.0 - (abs(elevation_diff) * 0.05)
		return max(0.5, defense)  // Minimum 50% damage taken
	
	return 1.0

// ============================================================================
// WIND EFFECT ON RANGED ATTACKS
// ============================================================================

/proc/ApplyWindModifier(mob/attacker, mob/target, projectile_type)
	/**
	 * ApplyWindModifier(attacker, target, projectile_type)
	 * Calculates accuracy penalty from wind conditions
	 * Wind perpendicular to shot = worst accuracy
	 * Wind with or against = moderate accuracy
	 * 
	 * @param attacker: Player performing ranged attack
	 * @param target: Target mob
	 * @param projectile_type: Type of projectile (arrow, bolt, etc.)
	 * @return: Accuracy multiplier (0.7 = 30% penalty, 1.0 = no penalty)
	 */
	if(!attacker || !target) return 1.0
	
	var/datum/wind_state/wind = GetCurrentWind()
	if(!wind || wind.speed == WIND_SPEED_LIGHT)
		return 1.0  // Light wind has no effect
	
	// Calculate direction from attacker to target
	var/shot_direction = get_dir(attacker, target)
	
	// Check if wind is perpendicular to shot
	var/wind_perpendicular = 0
	switch(wind.direction)
		if(WIND_NORTH, WIND_SOUTH)
			// Vertical wind
			if(shot_direction == EAST || shot_direction == WEST)
				wind_perpendicular = 1
		if(WIND_EAST, WIND_WEST)
			// Horizontal wind
			if(shot_direction == NORTH || shot_direction == SOUTH)
				wind_perpendicular = 1
	
	// Calculate penalty
	var/penalty = 0
	switch(wind.speed)
		if(WIND_SPEED_MODERATE)
			penalty = wind_perpendicular ? 0.15 : 0.05  // 15% or 5% penalty
		if(WIND_SPEED_STRONG)
			penalty = wind_perpendicular ? 0.30 : 0.10  // 30% or 10% penalty
	
	return max(0.7, 1.0 - penalty)  // Minimum 70% accuracy

// ============================================================================
// COVER MECHANICS
// ============================================================================

#define COVER_NONE 0
#define COVER_LIGHT 0.25      // 25% damage reduction
#define COVER_MEDIUM 0.50     // 50% damage reduction
#define COVER_HEAVY 0.75      // 75% damage reduction

/proc/GetCoverAtLocation(turf/T)
	/**
	 * GetCoverAtLocation(T)
	 * Checks if location has cover objects providing damage reduction
	 * Returns cover reduction value (0.25 = 25% damage reduction)
	 * 
	 * @param T: Turf to check
	 * @return: Cover multiplier (1.0 = no cover, 0.25 = 75% damage reduction)
	 */
	if(!T) return 1.0
	
	// Check for dense objects that provide cover
	var/max_cover = 1.0
	for(var/obj/O in T)
		if(O.density)
			// This is a blocking object, provides cover
			// Dense objects provide heavy cover
			max_cover = 0.25  // 75% reduction
	
	return max_cover

/proc/HasLineOfSight(mob/attacker, mob/target)
	/**
	 * HasLineOfSight(attacker, target)
	 * Checks if there's a clear line of sight between attacker and target
	 * Ignores small obstacles (grass, items) but blocks walls/doors
	 * 
	 * @param attacker: Attacking mob
	 * @param target: Target mob
	 * @return: 1 if clear line of sight, 0 if blocked
	 */
	if(!attacker || !target) return 0
	
	// Get the direction between attacker and target
	var/direction = get_dir(attacker, target)
	var/distance = get_dist(attacker, target)
	
	// Check each step along the path
	var/obj/current = attacker
	for(var/i = 1; i < distance; i++)
		current = get_step(current, direction)
		if(!current) return 0
		
		// Check if this turf is blocked
		if(istype(current, /turf))
			var/turf/T = current
			// Walls and doors block sight
			if(T.density)
				return 0
			// Check for dense objects (but allow small items)
			for(var/atom/A in T)
				if(A.density && !istype(A, /obj/item))
					return 0
	
	return 1

// ============================================================================
// CRITICAL HIT SYSTEM
// ============================================================================

/proc/CalculateCriticalChance(mob/attacker, mob/target)
	/**
	 * CalculateCriticalChance(attacker, target)
	 * Calculates probability of critical hit
	 * Base: 10% chance
	 * Bonuses: +5% per elevation level above target, +2% per skill level
	 * Penalties: -5% per elevation level below target
	 * 
	 * @param attacker: Attacking mob (player)
	 * @param target: Target mob
	 * @return: Critical hit chance 0-100%
	 */
	if(!attacker || !target) return 10
	
	var/crit_chance = 10  // Base 10%
	
	// Elevation bonus
	var/elevation_diff = attacker.elevel - target.elevel
	if(elevation_diff > 0)
		crit_chance += elevation_diff * 5  // +5% per level higher
	else if(elevation_diff < 0)
		crit_chance -= abs(elevation_diff) * 5  // -5% per level lower
	
	// Skill bonus (for ranged attacks)
	if(istype(attacker, /mob/players))
		var/mob/players/P = attacker
		// Average across ranged skills
		var/avg_skill = (P.GetRankLevel("archery") + P.GetRankLevel("crossbow") + P.GetRankLevel("throwing")) / 3
		crit_chance += avg_skill * 2  // +2% per average skill level
	
	// Clamp to 5-95% range
	return max(5, min(95, crit_chance))

/proc/ApplyCriticalHit(mob/attacker, mob/target, base_damage)
	/**
	 * ApplyCriticalHit(attacker, target, base_damage)
	 * Applies critical hit bonus to damage
	 * Critical multiplier: 1.5x (50% bonus)
	 * Applies elevation bonus on top
	 * 
	 * @param attacker: Attacking mob
	 * @param target: Target mob
	 * @param base_damage: Base damage before critical
	 * @return: Final damage after critical multiplier
	 */
	var/crit_chance = CalculateCriticalChance(attacker, target)
	
	if(prob(crit_chance))
		// CRITICAL HIT!
		var/crit_damage = base_damage * 1.5  // 50% bonus
		
		// Apply elevation bonus on top
		var/elev_bonus = GetElevationAttackBonus(attacker, target)
		crit_damage *= elev_bonus
		
		return crit_damage
	
	return base_damage

// ============================================================================
// DAMAGE NUMBER FLOATING TEXT
// ============================================================================

/obj/effect/damage_number
	name = "damage"
	icon = 'dmi/64/blank.dmi'
	icon_state = ""
	layer = EFFECTS_LAYER
	
	var
		damage_value = 0
		is_critical = 0
		is_miss = 0
		duration = 20  // 1 second

/obj/effect/damage_number/New(turf/location, damage, critical, miss)
	..()
	
	if(!location) return
	
	src.loc = location
	src.damage_value = damage
	src.is_critical = critical
	src.is_miss = miss
	
	// Set color and text based on damage type
	if(miss)
		src.color = "#FF8800"  // Orange for miss
		src.icon_state = "miss"
	else if(critical)
		src.color = "#FFFF00"  // Yellow for critical
		src.icon_state = "crit"
	else
		src.color = "#00FF00"  // Green for normal hit
		src.icon_state = "hit"
	
	// Animate float upward and fade out
	animate(src, pixel_y = src.pixel_y + 32, alpha = 0, time = src.duration)
	
	// Remove after duration
	spawn(src.duration)
		del(src)

/proc/ShowDamageNumber(turf/location, damage, is_critical, is_miss)
	/**
	 * ShowDamageNumber(location, damage, is_critical, is_miss)
	 * Creates floating damage text above target
	 * 
	 * @param location: Where to show damage number
	 * @param damage: Amount of damage
	 * @param is_critical: 1 if critical hit, 0 otherwise
	 * @param is_miss: 1 if miss, 0 otherwise
	 */
	new /obj/effect/damage_number(location, damage, is_critical, is_miss)

// ============================================================================
// COMBAT FEEDBACK INTEGRATION
// ============================================================================

/proc/ApplyEnvironmentalModifiers(mob/attacker, mob/target, base_damage, attack_type)
	/**
	 * ApplyEnvironmentalModifiers(attacker, target, base_damage, attack_type)
	 * Unified function to apply all environmental modifiers to damage
	 * Integrates: elevation, wind, cover, critical hits
	 * 
	 * @param attacker: Attacking mob
	 * @param target: Target mob
	 * @param base_damage: Base damage before modifiers
	 * @param attack_type: "melee", "ranged", "magic"
	 * @return: Final damage after all modifiers
	 */
	if(!attacker || !target) return 0
	
	var/final_damage = base_damage
	
	switch(attack_type)
		if("melee")
			// Melee: elevation defense bonus only
			var/defense_mult = GetElevationDefenseBonus(attacker, target)
			final_damage *= defense_mult
		
		if("ranged")
			// Ranged: elevation attack bonus, wind modifier, critical
			var/elev_mult = GetElevationAttackBonus(attacker, target)
			var/wind_mult = ApplyWindModifier(attacker, target, "arrow")
			final_damage *= elev_mult
			final_damage *= wind_mult
			
			// Check for critical hit
			final_damage = ApplyCriticalHit(attacker, target, final_damage)
			
			// Check for cover on target
			var/cover_mult = GetCoverAtLocation(target.loc)
			final_damage *= cover_mult
		
		if("magic")
			// Magic: elevation bonus, no wind or cover
			var/elev_mult = GetElevationAttackBonus(attacker, target)
			final_damage *= elev_mult
	
	return max(1, final_damage)  // Minimum 1 damage

// ============================================================================
// INTEGRATION WITH MACRO-KEY COMBAT
// ============================================================================

/proc/PerformMeleeAttackWithEnvironment(mob/players/attacker, mob/defender)
	/**
	 * PerformMeleeAttackWithEnvironment(attacker, defender)
	 * Enhanced melee attack with environmental modifiers
	 * Shows damage numbers and visual feedback
	 */
	if(!attacker || !defender) return
	
	// Get equipped weapon
	var/obj/item/weapon/W = attacker.Wequipped
	if(!W)
		attacker << "<font color=#FF8800>You don't have a weapon equipped!</font>"
		return
	
	// Calculate accuracy
	var/accuracy = 65  // Base 65% for melee
	if(prob(accuracy))
		// HIT
		var/base_damage = 8  // Default melee damage
		if(W:damage)
			base_damage = W:damage
		
		// Apply environmental modifiers
		var/final_damage = ApplyEnvironmentalModifiers(attacker, defender, base_damage, "melee")
		
		// Apply to target
		if(istype(defender, /mob/players))
			var/mob/players/PD = defender
			PD.HP = max(0, PD.HP - final_damage)
			attacker << "<font color=#00FF00>HIT! Dealt [final_damage] damage.</font>"
			defender << "<font color=#FF0000>You took [final_damage] damage!</font>"
		else if(istype(defender, /mob/enemies))
			var/mob/enemies/ED = defender
			ED:HP = max(0, ED:HP - final_damage)
			attacker << "<font color=#00FF00>HIT! Dealt [final_damage] damage.</font>"
			defender << "<font color=#FF0000>You took [final_damage] damage!</font>"
		
		// Show damage number
		ShowDamageNumber(defender.loc, final_damage, 0, 0)
	else
		// MISS
		attacker << "<font color=#FF8800>You missed!</font>"
		defender << "<font color=#FF8800>[attacker.name] missed you!</font>"
		ShowDamageNumber(defender.loc, 0, 0, 1)

/proc/PerformRangedAttackWithEnvironment(mob/players/attacker, mob/target, skill_type)
	/**
	 * PerformRangedAttackWithEnvironment(attacker, target, skill_type)
	 * Enhanced ranged attack with environmental modifiers
	 * Integrates with FireRangedAttack and applies environment effects
	 */
	if(!attacker || !target) return 0
	
	// Get skill level
	var/skill_level = attacker.GetRankLevel(skill_type)
	if(skill_level < 1)
		attacker << "<font color=#FF5555>You need at least rank 1 in [skill_type]!"
		return 0
	
	// Get base accuracy and damage
	var/base_accuracy = 50 + (skill_level * 8)  // 50% + 8% per level
	
	// Apply wind modifier to accuracy
	var/wind_modifier = ApplyWindModifier(attacker, target, "arrow")
	var/final_accuracy = base_accuracy * wind_modifier
	
	if(prob(final_accuracy))
		// HIT
		var/base_damage = 8 + (skill_level * 2)
		
		// Check for critical
		var/crit_chance = CalculateCriticalChance(attacker, target)
		var/is_critical = prob(crit_chance)
		
		// Apply all environmental modifiers
		var/final_damage = ApplyEnvironmentalModifiers(attacker, target, base_damage, "ranged")
		
		// Apply to target
		if(istype(target, /mob/players))
			var/mob/players/PD = target
			PD.HP = max(0, PD.HP - final_damage)
			attacker << "<font color=#00FF00>HIT! Dealt [final_damage] damage[is_critical ? " (CRITICAL)" : ""]!</font>"
			target << "<font color=#FF0000>You took [final_damage] damage!</font>"
		else if(istype(target, /mob/enemies))
			var/mob/enemies/ED = target
			ED:HP = max(0, ED:HP - final_damage)
			attacker << "<font color=#00FF00>HIT! Dealt [final_damage] damage[is_critical ? " (CRITICAL)" : ""]!</font>"
			target << "<font color=#FF0000>You took [final_damage] damage!</font>"
		
		// Show damage number with critical indicator
		ShowDamageNumber(target.loc, final_damage, is_critical, 0)
		
		// Award experience
		attacker.UpdateRankExp(skill_type, 5)
		return 1
	else
		// MISS
		attacker << "<font color=#FF8800>You missed! (Accuracy: [final_accuracy]%)</font>"
		target << "<font color=#FF8800>[attacker.name] missed you!</font>"
		ShowDamageNumber(target.loc, 0, 0, 1)
		return 0

// ============================================================================
// DEBUG VERBS FOR ENVIRONMENTAL MODIFIERS
// ============================================================================

/mob/players/verb/DebugEnvironmentalModifiers()
	set category = "Debug"
	set name = "Show Environmental Modifiers (Debug)"
	
	var/mob/target = input(src, "Select target:", "Environmental Modifiers") as null|mob in world
	if(!target)
		src << "Cancelled."
		return
	
	var/output = "<b>ENVIRONMENTAL MODIFIERS vs [target.name]</b>\n"
	output += "================================\n"
	
	// Elevation
	var/elevation_attack = GetElevationAttackBonus(src, target)
	var/elevation_defense = GetElevationDefenseBonus(src, target)
	output += "Your Elevation: [src.elevel]\n"
	output += "Target Elevation: [target.elevel]\n"
	output += "Ranged Attack Bonus: [elevation_attack * 100]%\n"
	output += "Melee Defense Bonus: [elevation_defense * 100]%\n"
	output += "\n"
	
	// Wind
	var/wind_effect = ApplyWindModifier(src, target, "arrow")
	output += "Wind Accuracy Modifier: [wind_effect * 100]%\n"
	output += "\n"
	
	// Critical
	var/crit_chance = CalculateCriticalChance(src, target)
	output += "Critical Hit Chance: [crit_chance]%\n"
	output += "\n"
	
	// Cover
	var/cover = GetCoverAtLocation(target.loc)
	output += "Cover at Target: [cover == 1.0 ? "None" : "[((1.0 - cover) * 100)]% reduction"]\n"
	output += "\n"
	
	// Line of Sight
	var/los = HasLineOfSight(src, target)
	output += "Line of Sight: [los ? "CLEAR" : "BLOCKED"]\n"
	
	src << output

/mob/players/verb/DebugDamageNumbers()
	set category = "Debug"
	set name = "Test Damage Numbers (Debug)"
	
	var/damage = input(src, "Enter damage amount:", "Damage Number") as num
	if(!damage) damage = 25
	
	src << "Showing damage number: [damage]"
	ShowDamageNumber(src.loc, damage, prob(50), 0)
