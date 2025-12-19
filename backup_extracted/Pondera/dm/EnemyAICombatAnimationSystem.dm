/*
	PHASE 45: ENEMY AI COMBAT ANIMATION SYSTEM
	
	Integrates enemy combat with:
	- WeaponAnimationSystem (Phase 43)
	- CombatUIPolish (Phase 44)
	- EnvironmentalCombatModifiers (Phase 42)
	
	Features:
	- Enemies now animate attacks like players
	- Color-coded damage numbers for enemy attacks
	- Threat level indicators
	- Combat event logging for enemy actions
	- Directional swing animation based on target position
	- Critical hit detection for enemies
	- Status indicators (attacking, hit, miss, defending)
	
	Integration Points:
	- Replaces old flick() system with unified animation
	- Replaces old s_damage() with ShowEnhancedDamageNumber()
	- Integrates HUD feedback through OnPlayerAttackHit()
	- Uses threat calculation for target color coding
	- Logs all enemy combat actions
	
	Usage in Enemies.dm:
	Before calling HitPlayer(), add:
		ExecuteEnemyAttackAnimation(src, target)
*/

/*
	Execute Enemy Attack Animation
	Called when enemy decides to attack player
*/
/proc/ExecuteEnemyAttackAnimation(mob/enemies/E, mob/players/target)
	if(!E || !target)
		return 0
	
	// Calculate direction to target
	var/attack_dir = get_dir(E, target)
	
	// Start attack animation
	PlayAttackAnimation(E, attack_dir, "enemy_melee")
	
	// Show status indicator on attacker
	ShowCombatStatus(E, "attacking")
	
	// Show threat indicator on target
	var/threat_color = GetThreatColor(target, E)
	target.color = threat_color
	
	return 1

/*
	Execute Enemy Ranged Attack Animation
	For enemies that cast spells or ranged attacks
*/
/proc/ExecuteEnemyRangedAnimation(mob/enemies/E, mob/players/target, spell_type="fire")
	if(!E || !target)
		return 0
	
	// Show casting status
	ShowCombatStatus(E, "attacking")
	
	// Animate ranged attack (draw-fire-impact)
	PlayRangedAnimation(E, spell_type, 0)
	
	// Show threat on target
	var/threat_color = GetThreatColor(target, E)
	target.color = threat_color
	
	return 1

/*
	Process Enemy Damage with HUD Feedback
	Replaces old s_damage() system
*/
/proc/ProcessEnemyDamage(mob/enemies/attacker, mob/players/defender, damage)
	if(!attacker || !defender)
		return 0
	
	// Calculate if critical based on elevation and RNG
	var/crit_chance = CalculateCriticalChance(attacker, defender)
	var/is_critical = (rand(1, 100) <= crit_chance)
	
	// Show damage number with color coding
	var/damage_color = "normal"
	if(is_critical)
		damage_color = "critical"
	
	ShowEnhancedDamageNumber(defender, damage, damage_color, is_critical)
	
	// Trigger HUD feedback integration
	OnPlayerAttackHit(attacker, defender, damage, "melee")
	
	// Log combat event for analytics
	LogCombatEvent("[attacker.name] → [defender.name]: [damage] damage (enemy attack)")
	
	return 1

/*
	Enemy Miss Handler
	Shows miss feedback and resets threat
*/
/proc/ProcessEnemyMiss(mob/enemies/attacker, mob/players/defender)
	if(!attacker || !defender)
		return 0
	
	// Show miss indicator
	ShowEnhancedDamageNumber(defender, 0, "miss", 0)
	ShowCombatStatus(attacker, "miss")
	ShowCombatStatus(defender, "miss")
	
	// Log miss event
	LogCombatEvent("[attacker.name] missed attack on [defender.name]")
	
	return 1

/*
	Get Enemy Attack Power
	Calculates base damage for enemy
*/
/proc/GetEnemyAttackPower(mob/enemies/E)
	if(!E)
		return 0
	
	// Base damage from enemy type
	var/base_damage = 10
	
	// Scale by enemy level/rarity
	if(E.Unique)
		base_damage *= 1.5
	
	// Add variation
	base_damage += rand(-2, 2)
	
	return base_damage

/*
	Get Enemy Hit Chance
	Returns percentage chance to hit (0-100)
*/
/proc/GetEnemyHitChance(mob/enemies/attacker, mob/players/defender)
	if(!attacker || !defender)
		return 50
	
	// Base hit chance
	var/hit_chance = 75
	
	// Elevation advantage for ranged attacks
	if(attacker.elevel > defender.elevel)
		hit_chance += 15
	
	// Defender dodge rating (if available)
	if(defender.tempevade > 0)
		hit_chance -= defender.tempevade
	
	// Clamp to valid range
	hit_chance = max(20, min(95, hit_chance))
	
	return hit_chance

/*
	Enemy Combat Manager
	Background loop for enemy combat behavior
*/
/proc/EnemyCombatManager()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(10)  // Check every 0.5 seconds
		
		for(var/mob/enemies/E in world)
			if(!E || E.HP <= 0)
				continue
			
			// Find nearby players
			var/mob/players/target = null
			for(var/mob/players/P in oview(E, 10))
				if(P.HP > 0)
					target = P
					break
			
			// If target found and able to attack
			if(target && E.awake)
				// Check if in range
				if(get_dist(E, target) <= 1)
					// Perform attack
					var/hit_chance = GetEnemyHitChance(E, target)
					if(rand(1, 100) <= hit_chance)
						// Calculate damage
						var/base_damage = GetEnemyAttackPower(E)
						var/final_damage = round(base_damage * ((E.Strength / 100) + 1), 1)
						
						// Execute animation and damage
						ExecuteEnemyAttackAnimation(E, target)
						
						// Wait for animation to complete (4 ticks)
						sleep(4)
						
						// Apply damage with HUD feedback
						ProcessEnemyDamage(E, target, final_damage)
						
						// Apply damage to target
						target.HP = max(0, target.HP - final_damage)
						
						// Check if player died
						if(target.HP <= 0)
							LogCombatEvent("[E.name] killed [target.name]")
					else
						// Miss
						ProcessEnemyMiss(E, target)

/*
	Initialize Enemy Combat Animation System
	Called from InitializationManager
*/
/proc/InitializeEnemyAICombatAnimationSystem()
	spawn()
		EnemyCombatManager()
	
	RegisterInitComplete("EnemyAICombatAnimationSystem")

/*
	Integration Hook for Existing Enemy Attack Procs
	Call this from enemy Attack() procs to use new system
*/
/proc/IntegrateEnemyAttackWithAnimation(mob/enemies/E, mob/players/target)
	if(!E || !target)
		return 0
	
	// Check elevation range first
	if(!E.Chk_LevelRange(target))
		return 0
	
	// Execute full animation + damage cycle
	ExecuteEnemyAttackAnimation(E, target)
	
	// Calculate damage
	var/hit_chance = GetEnemyHitChance(E, target)
	if(rand(1, 100) <= hit_chance)
		var/base_damage = GetEnemyAttackPower(E)
		var/final_damage = round(base_damage * ((E.Strength / 100) + 1), 1)
		
		// Wait for animation timing
		sleep(4)
		
		// Apply damage with visual feedback
		ProcessEnemyDamage(E, target, final_damage)
		target.HP = max(0, target.HP - final_damage)
		
		return 1
	else
		ProcessEnemyMiss(E, target)
		return 0

/*
	Debug Verbs for Testing Enemy Combat
*/
/mob/players/verb/test_enemy_attack()
	set name = "Test Enemy Attack"
	set category = "Debug"
	
	// Find nearest enemy
	var/mob/enemies/E = locate() in view(5)
	if(E)
		IntegrateEnemyAttackWithAnimation(E, src)
		world.log << "[E.name] test attack on [src.name] completed"
	else
		world.log << "No enemies in range"

/mob/players/verb/test_enemy_hud_feedback()
	set name = "Test Enemy HUD Feedback"
	set category = "Debug"
	
	// Simulate enemy attack with full HUD
	var/mob/enemies/E = locate() in view(5)
	if(E)
		ExecuteEnemyAttackAnimation(E, src)
		sleep(4)
		ProcessEnemyDamage(E, src, 50)
		world.log << "[E.name] HUD feedback test completed"
	else
		world.log << "No enemies in range"

/mob/players/verb/test_enemy_threat_color()
	set name = "Test Enemy Threat Color"
	set category = "Debug"
	
	// Show threat colors for all nearby enemies
	for(var/mob/enemies/E in oview(10))
		var/threat_color = GetThreatColor(src, E)
		world.log << "[E.name] threat level color: [threat_color]"

// CONSOLIDATED: InitializeEnemyAICombatAnimationSystem() now called from InitializeWorld() in InitializationManager.dm
// Do NOT define world/New() here - it will override the primary one!

/*
	Enhanced HitPlayer Integration Wrapper
	Call from Enemies.dm HitPlayer() procs to add animation feedback
	Usage: Add at START of HitPlayer proc:
		ExecuteEnemyHitPlayerAnimation(src, P)
*/
/proc/ExecuteEnemyHitPlayerAnimation(mob/enemies/E, mob/players/target)
	if(!E || !target)
		return
	
	// Execute attack animation
	ExecuteEnemyAttackAnimation(E, target)
	
	// Show threat color on target
	var/threat_color = GetThreatColor(target, E)
	target.color = threat_color

/*
	Show Enhanced Damage for Existing HitPlayer System
	Call from HitPlayer() after damage calculation:
		ShowEnemyDamageNumber(P, damage)
*/
/proc/ShowEnemyDamageNumber(mob/players/defender, damage)
	if(!defender)
		return
	
	// Determine if critical (high damage relative to max HP)
	var/is_critical = (damage > defender:MAXHP * 0.15)
	
	ShowEnhancedDamageNumber(defender, damage, "normal", is_critical)
	
	// Also log the event
	LogCombatEvent("Enemy attack on [defender.name]: [damage] damage (critical: [is_critical])")
