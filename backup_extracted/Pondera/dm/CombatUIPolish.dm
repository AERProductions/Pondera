/*
	PHASE 44: COMBAT UI POLISH
	
	Provides visual HUD elements for combat feedback:
	- Floating damage numbers with color coding
	- Combat status messages (attacking, hit, miss, defending)
	- Threat level indicators
	- Range visualization for ranged attacks
	- Combat event logging
	
	Features:
	- Green numbers for normal hits
	- Yellow for critical damage
	- Gray for misses
	- Blue for resisted damage
	- Damage flash effects on impact
	- Quick status text above combatants
	
	Simplified for BYOND compatibility - uses visual effects instead of complex HUD objects
*/

#define COLOR_HEALTHY "#00FF00"   // Green (>75% HP)
#define COLOR_WOUNDED "#FFFF00"   // Yellow (50-75% HP)
#define COLOR_CRITICAL "#FF5555"  // Red (<50% HP)

/*
	Show Combat Status Indicator
	Brief text message showing attack/defense state
*/
/proc/ShowCombatStatus(mob/M, status_type)
	if(!M)
		return
	
	// Broadcast system message instead of creating objects
	switch(status_type)
		if("attacking")
			world << "[M.name] is ATTACKING!"
		if("defending")
			world << "[M.name] is DEFENDING!"
		if("dodge_roll")
			world << "[M.name] is DODGING!"
		if("cooldown")
			world << "[M.name] is on COOLDOWN"
		if("hit")
			world << "[M.name] HIT!"
		if("miss")
			world << "[M.name] MISSED!"

/*
	Enhanced Floating Damage Number
	Improved version from Phase 43
*/
/proc/ShowEnhancedDamageNumber(turf/T, damage, damage_type="normal", critical=0)
	if(!T)
		return
	
	var/damage_msg = "[damage]"
	if(damage <= 0)
		damage_msg = "MISS"
	else if(critical)
		damage_msg = "[damage] CRIT!"
	
	// Color-coded damage message to nearby clients
	switch(damage_type)
		if("normal")
			world << "<b style='color:lime'>[damage_msg]</b> at [T]"
		if("critical")
			world << "<b style='color:yellow'>[damage_msg]</b> at [T]"
		if("miss")
			world << "<b style='color:gray'>[damage_msg]</b> at [T]"
		if("resist")
			world << "<b style='color:cyan'>[damage_msg]</b> at [T]"
		else
			world << "[damage_msg] at [T]"


/*
	Range Indicator for Ranged Attacks
	Shows visible range for current ranged weapon
*/
/proc/ShowRangedRange(mob/M)
	if(!M)
		return
	
	world << "[M.name] range indicator active"

/*
	Enemy Threat Level Indicator
	Color-coded name based on relative power
*/
/proc/GetThreatColor(mob/player, mob/enemy)
	if(!player || !enemy)
		return "#FFFFFF"
	
	// Calculate threat based on enemy HP vs player HP
	var/threat_ratio = (enemy:HP / enemy:MAXHP) / (player:HP / player:MAXHP)
	
	if(threat_ratio > 2)
		return "#FF0000"   // Red - deadly
	else if(threat_ratio > 1.5)
		return "#FF6600"   // Orange - very dangerous
	else if(threat_ratio > 1)
		return "#FFFF00"   // Yellow - dangerous
	else if(threat_ratio > 0.5)
		return "#00FF00"   // Green - manageable
	else
		return "#00FFFF"   // Cyan - weak
	
	return "#FFFFFF"  // Default

/*
	Combat Feedback Manager
	Integrates all HUD elements with combat system
*/
/proc/OnPlayerAttackHit(mob/attacker, mob/defender, damage, hit_type="normal")
	if(!attacker || !defender)
		return
	
	// 1. Show damage number at defender location
	var/is_critical = (damage > (defender:MAXHP * 0.1))
	ShowEnhancedDamageNumber(defender, damage, hit_type, is_critical)
	
	// 2. Show status indicators
	ShowCombatStatus(attacker, "hit")
	ShowCombatStatus(defender, "hit")
	
	// 3. Play impact animation (if it exists)
	// PlayImpactAnimation(defender, hit_type)
	
	// 4. Log combat event
	LogCombatEvent("[attacker.name] → [defender.name]: [damage] damage ([hit_type])")

/proc/OnPlayerAttackMiss(mob/attacker, mob/target)
	if(!attacker || !target)
		return
	
	// Show miss indicator
	ShowEnhancedDamageNumber(target, 0, "miss", 0)
	ShowCombatStatus(attacker, "miss")
	ShowCombatStatus(target, "miss")
	
	LogCombatEvent("[attacker.name] missed attack on [target.name]")

/proc/OnPlayerDefend(mob/defender, defend_type)
	if(!defender)
		return
	
	var/status = (defend_type == "shield") ? "defending" : "dodge_roll"
	ShowCombatStatus(defender, status)
	
	LogCombatEvent("[defender.name] activated [defend_type] defense")

/*
	Integration with MacroKeyCombatSystem
	Hook into E/V/Space key handlers
*/
/proc/OnMeleeAttackAnimation(mob/attacker, mob/target)
	// Show combat status
	ShowCombatStatus(attacker, "attacking")
	
	// Show threat indicator on target
	var/threat_color = GetThreatColor(attacker, target)
	target.color = threat_color

/proc/OnRangedAttackAnimation(mob/attacker, skill_type)
	ShowCombatStatus(attacker, "attacking")
	ShowRangedRange(attacker)

/proc/OnDefendActivated(mob/defender, defend_type)
	OnPlayerDefend(defender, defend_type)

/*
	HUD System Initialization
	Called from InitializationManager
*/
/proc/InitializeCombatHUDSystem()
	// Register for all combat events
	// This would integrate with event bus system
	
	RegisterInitComplete("CombatHUDSystem")

/*
	Debug Verbs for HUD Testing
*/
/mob/players/verb/test_damage_number()
	set name = "Test Damage Number"
	set category = "Debug"
	
	ShowEnhancedDamageNumber(src, 45, "normal", 0)
	ShowEnhancedDamageNumber(get_step(src, NORTH), 120, "critical", 1)
	world.log << "[src.name] damage numbers displayed"

/mob/players/verb/test_status_indicator()
	set name = "Test Status Indicator"
	set category = "Debug"
	
	ShowCombatStatus(src, "attacking")
	spawn(5)
		ShowCombatStatus(src, "hit")
	spawn(10)
		ShowCombatStatus(src, "defending")
	world.log << "[src.name] status indicators shown"

/mob/players/verb/test_range_indicator()
	set name = "Test Range Indicator"
	set category = "Debug"
	
	ShowRangedRange(src)
	world.log << "[src.name] range indicator shown"

/mob/players/verb/test_full_combat_hud()
	set name = "Test Full Combat HUD"
	set category = "Debug"
	
	ShowCombatStatus(src, "attacking")
	ShowEnhancedDamageNumber(src, 75, "normal", 0)
	ShowRangedRange(src)
	
	world.log << "[src.name] full combat HUD test complete"

/*
	Integration Hooks
	These would be called from existing combat systems
*/

// Called from EnvironmentalCombatModifiers.dm after damage application
/proc/IntegrateCombatHUDWithDamage(mob/attacker, mob/defender, damage, hit_type="blunt")
	
	if(!attacker || !defender)
		return
	
	// Only show feedback if damage > 0
	if(damage > 0)
		OnPlayerAttackHit(attacker, defender, damage, hit_type)
	else
		OnPlayerAttackMiss(attacker, defender)

// Called from MacroKeyCombatSystem.dm when defense activated
/proc/IntegrateCombatHUDWithDefense(mob/defender, defend_type)
	OnPlayerDefend(defender, defend_type)

// Called from WeaponAnimationSystem.dm on animation complete
/proc/IntegrateCombatHUDWithAnimation(mob/M, anim_type)
	// anim_type constants: ANIM_TYPE_MELEE=1, ANIM_TYPE_RANGED=2, ANIM_TYPE_IMPACT=3
	switch(anim_type)
		if(1)  // ANIM_TYPE_MELEE
			ShowCombatStatus(M, "attacking")
		if(2)  // ANIM_TYPE_RANGED
			ShowCombatStatus(M, "attacking")

// CONSOLIDATED: InitializeCombatHUDSystem() now called from InitializeWorld() in InitializationManager.dm
// Do NOT define world/New() here - it will override the primary one!
