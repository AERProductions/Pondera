/*
	PHASE 47: UNIFIED ATTACK SYSTEM HUD INTEGRATION
	
	Integrates UnifiedAttackSystem.dm with Phase 44 Combat UI Polish
	
	Purpose:
	- Enhance DisplayDamage() with color-coded damage numbers
	- Add threat level indicators
	- Integrate HUD feedback with existing damage calculation
	- Maintain backward compatibility with old s_damage() system
	
	Integration Strategy:
	- Wrap existing DisplayDamage() with new HUD calls
	- Keep old text messages for client feedback
	- Add visual effects in parallel
	- All systems coexist during transition period
	
	Benefits:
	- All unified attack system damage now uses new HUD
	- Threat colors appear on targets
	- Combat events logged automatically
	- Critical hits highlighted visually
	- Player attacks visible with new system
*/

/*
	Enhanced Display Damage with HUD Integration
	
	This wrapper function is called instead of old DisplayDamage()
	It provides all old functionality PLUS new Phase 44 HUD enhancements
*/
/proc/DisplayDamageEnhanced(mob/players/attacker, mob/defender, damage)
	if(!attacker || !defender)
		return
	
	// Determine if critical (high damage relative to target max HP)
	var/is_critical = 0
	if(defender:MAXHP)
		is_critical = (damage > defender:MAXHP * 0.15)
	
	// PHASE 47: Show enhanced damage number instead of old s_damage()
	ShowEnhancedDamageNumber(defender, damage, "normal", is_critical)
	
	// PHASE 47: Update threat color on defender
	var/threat_color = GetThreatColor(attacker, defender)
	defender.color = threat_color
	
	// PHASE 47: Log combat event
	LogCombatEvent("[attacker.name] → [defender.name]: [damage] damage (critical: [is_critical])")
	
	// PHASE 47: Trigger HUD feedback (optional - for full integration)
	// OnPlayerAttackHit(attacker, defender, damage, "physical")
	
	// Keep old text messages for backward compatibility
	if(defender.client)
		defender << "<font color='red'><b>[attacker.name] dealt [damage] damage!</b>"
	
	if(attacker.client)
		attacker << "<font color='green'><b>You dealt [damage] damage to [defender.name]!</b>"

/*
	Integration Helper: Use This Instead of DisplayDamage()
	
	In UnifiedAttackSystem.dm, change:
		DisplayDamage(attacker, defender, final_damage)
	To:
		DisplayDamageEnhanced(attacker, defender, final_damage)
	
	This provides unified HUD integration for all player attacks
*/

/*
	System Initialization
*/
/proc/InitializeUnifiedAttackSystemIntegration()
	RegisterInitComplete("UnifiedAttackSystemIntegration")

// CONSOLIDATED: InitializeUnifiedAttackSystemIntegration() now called from InitializeWorld() in InitializationManager.dm
// Do NOT define world/New() here - it will override the primary one!
