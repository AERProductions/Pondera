/*
	PHASE 48: ENVIRONMENTAL COMBAT + SPELL EFFECTS INTEGRATION
	
	Integrates:
	- EnvironmentalCombatModifiers.dm (Phase 42)
	- Combat UI Polish (Phase 44)
	- Animation System (Phase 43)
	
	Purpose:
	- Visualize elevation advantages/disadvantages
	- Add casting animations to spell system
	- Color-code spell impacts by element type
	- Show wind/weather effects on ranged attacks
	- Critical hits stand out visually
	
	Features:
	- Elevation bonus indicators
	- Wind modifier feedback
	- Critical chance display
	- Spell element color coding
	- Casting animation sequences
	- Impact particle effects (future)
*/

/*
	Show Elevation Advantage Feedback
	Called when elevation modifiers are applied
*/
/proc/ShowElevationAdvantage(mob/attacker, mob/defender, modifier)
	if(!attacker || !defender)
		return
	
	// Only show if modifier is significant
	if(modifier > 1.15)  // 15% or greater bonus
		// Show advantage status
		ShowCombatStatus(attacker, "attacking")
		
		// Color defender based on vulnerability
		if(modifier > 1.3)
			defender.color = "#FFFF00"  // Yellow - high vulnerability
		else
			defender.color = "#FFCC00"  // Orange - moderate vulnerability

/*
	Show Wind Modifier Effect
	Called when wind affects ranged attack
*/
/proc/ShowWindModifierFeedback(mob/attacker, direction_match, wind_strength)
	if(!attacker)
		return
	
	// Wind assists (same direction)
	if(direction_match == 1)
		if(wind_strength > 0.2)
			ShowCombatStatus(attacker, "attacking")
			world << "<font color='#00FF00'>[attacker.name] gets a wind boost!"
	
	// Wind hinders (opposite direction)
	else if(direction_match == -1)
		if(wind_strength > 0.2)
			ShowCombatStatus(attacker, "miss")
			world << "<font color='#FF8888'>[attacker.name] is hindered by wind!"

/*
	Show Critical Chance Indicator
	Display when critical hit is rolled
*/
/proc/ShowCriticalChanceIndicator(mob/attacker, mob/target, crit_chance)
	if(!attacker || !target)
		return
	
	// Only show if significant chance
	if(crit_chance >= 50)
		ShowCombatStatus(attacker, "attacking")
		target.color = "#FFFF00"  // Yellow highlight
		
		if(crit_chance >= 75)
			target.color = "#FF6600"  // Orange - very high chance

/*
	Enhanced ApplyEnvironmentalModifiers with HUD
	
	Wrapper function to integrate EnvironmentalCombatModifiers
	with new HUD and animation systems
*/
/proc/ApplyEnvironmentalModifiersWithHUD(mob/attacker, mob/target, base_damage, attack_type="physical")
	if(!attacker || !target)
		return 0
	
	// Get base environmental damage
	var/final_damage = ApplyEnvironmentalModifiers(attacker, target, base_damage, attack_type)
	
	// PHASE 48: Show elevation feedback
	var/elev_modifier = GetElevationAttackBonus(attacker, target)
	if(elev_modifier != 1.0)
		ShowElevationAdvantage(attacker, target, elev_modifier)
	
	// PHASE 48: Apply critical hit visual feedback
	var/crit_chance = CalculateCriticalChance(attacker, target)
	if(crit_chance > 25)
		ShowCriticalChanceIndicator(attacker, target, crit_chance)
	
	// PHASE 48: Check if critical hit applied
	if(final_damage > base_damage * 1.2)  // 20% damage increase indicates critical
		ShowEnhancedDamageNumber(target, final_damage, "critical", 1)
	
	return final_damage

/*
	Spell Casting Animation Handler
	Add this to spell casting system to animate casting
*/
/proc/CastSpellWithAnimation(mob/caster, spell_type, mob/target, spell_damage)
	if(!caster || !target)
		return 0
	
	// PHASE 48: Show casting status
	ShowCombatStatus(caster, "attacking")
	
	// PHASE 48: Play casting animation toward target
	var/cast_dir = get_dir(caster, target)
	PlayAttackAnimation(caster, cast_dir, "spell_cast")
	
	// Wait for animation (assume 5 ticks for spell travel)
	sleep(5)
	
	// PHASE 48: Apply impact at target location
	var/spell_element = GetSpellElement(spell_type)
	
	// Show spell impact based on element
	ShowSpellImpactEffect(target, spell_element, spell_damage)
	
	// PHASE 48: Apply damage with element-specific feedback
	ShowEnhancedDamageNumber(target, spell_damage, spell_element, 0)
	
	// Log spell cast
	LogCombatEvent("[caster.name] cast [spell_type] on [target.name]: [spell_damage] damage")
	
	return spell_damage

/*
	Get Spell Element Type
	Returns element type for damage coloring
*/
/proc/GetSpellElement(spell_type)
	switch(spell_type)
		if("heat", "fire", "fireball", "burning")
			return "fire"
		if("ice", "icestorm", "frozen", "chill")
			return "ice"
		if("lightning", "chainlightning", "electric", "shock")
			return "lightning"
		if("acid", "poison", "toxic")
			return "poison"
		if("water", "watershock", "flood")
			return "water"
		if("earth", "shardburst", "tremor")
			return "earth"
		if("wind", "gust", "tornado")
			return "wind"
		else
			return "normal"

/*
	Show Spell Impact Effect
	Visual feedback for spell element type
*/
/proc/ShowSpellImpactEffect(mob/target, element_type, damage)
	if(!target)
		return
	
	// Color-coded impact feedback
	var/impact_color = "#FFFFFF"
	var/impact_text = "spell"
	
	switch(element_type)
		if("fire")
			impact_color = "#FF4400"
			impact_text = "fire blast"
		if("ice")
			impact_color = "#44CCFF"
			impact_text = "ice impact"
		if("lightning")
			impact_color = "#FFFF00"
			impact_text = "electric shock"
		if("poison")
			impact_color = "#88FF00"
			impact_text = "toxic splash"
		if("water")
			impact_color = "#0088FF"
			impact_text = "water surge"
		if("earth")
			impact_color = "#8B7355"
			impact_text = "earth quake"
		if("wind")
			impact_color = "#CCCCFF"
			impact_text = "wind blast"
	
	// Show impact animation at location
	var/obj/effect/spell_impact/SI = new(target.loc)
	SI.color = impact_color
	animate(SI, alpha=0, time=10)
	spawn(10)
		del(SI)
	
	// Broadcast impact message
	view(target, 10) << "<font color='[impact_color]'>[target.name] is hit by a [impact_text]!"

/obj/effect/spell_impact
	layer = EFFECTS_LAYER
	density = 0
	opacity = 0
	mouse_opacity = 0
	alpha = 255

/*
	Show Ranged Attack Range Indicator
	Enhanced to show environmental factors
*/
/proc/ShowRangedAttackWithEnvironment(mob/attacker, mob/target, projectile_type)
	if(!attacker || !target)
		return
	
	// Show base range
	ShowRangedRange(attacker)
	
	// Check wind modifier
	var/wind_mod = ApplyWindModifier(attacker, target, projectile_type)
	if(wind_mod < 1.0)
		ShowCombatStatus(attacker, "miss")  // Wind hinders
	else if(wind_mod > 1.0)
		ShowCombatStatus(attacker, "attacking")  // Wind assists

/*
	Environmental Modifiers Test Verbs
	For admin testing
*/
/mob/players/verb/AdminTestElevationBonus()
	set name = "Admin: Test Elevation Bonus"
	set category = "Admin - Environmental"
	set desc = "Test elevation advantage visualization"
	
	if(src.char_class != "GM")
		src << "Only GMs can use this"
		return
	
	var/mob/target = input("Select target") in view(10)
	if(!target)
		return
	
	var/bonus = GetElevationAttackBonus(src, target)
	src << "Elevation bonus: [bonus]x"
	ShowElevationAdvantage(src, target, bonus)

/mob/players/verb/AdminTestCriticalFeedback()
	set name = "Admin: Test Critical Feedback"
	set category = "Admin - Environmental"
	set desc = "Test critical chance visualization"
	
	if(src.char_class != "GM")
		src << "Only GMs can use this"
		return
	
	var/mob/target = input("Select target") in view(10)
	if(!target)
		return
	
	var/crit_chance = CalculateCriticalChance(src, target)
	src << "Critical chance: [crit_chance]%"
	ShowCriticalChanceIndicator(src, target, crit_chance)

/mob/players/verb/AdminTestSpellEffect()
	set name = "Admin: Test Spell Effect"
	set category = "Admin - Environmental"
	set desc = "Test spell casting and impact"
	
	if(src.char_class != "GM")
		src << "Only GMs can use this"
		return
	
	var/mob/target = input("Select target") in view(10)
	if(!target)
		return
	
	CastSpellWithAnimation(src, "fire", target, 75)

/*
	System Initialization
*/
/proc/InitializeEnvironmentalCombatIntegration()
	RegisterInitComplete("EnvironmentalCombatIntegration")

// CONSOLIDATED: InitializeEnvironmentalCombatIntegration() now called from InitializeWorld() in InitializationManager.dm
// Do NOT define world/New() here - it will override the primary one!
