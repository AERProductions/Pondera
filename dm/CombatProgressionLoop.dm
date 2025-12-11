/**
 * CombatProgressionLoop.dm
 * Phase 19: Combat Progression Loop
 * 
 * Purpose: Integrate combat actions with skill progression
 * - Combat experience earned from kills and damage
 * - Skill rank-up unlocks new attack abilities
 * - Equipment scaling with skill levels
 * - Experience-based equipment quality improvements
 * - Progression gates (higher ranks = better gear crafting)
 * 
 * Architecture:
 * - Combat action → Damage dealt → Experience gain
 * - Experience accumulation → Rank up (CheckRankUp)
 * - Rank up → Unlock attacks (UnlockAttackBySkill)
 * - Rank up → Equipment crafting gates (materials locked until rank)
 * - Integration: CombatSystem + SpecialAttacksSystem + UnifiedRankSystem
 * 
 * Tick Schedule:
 * - T+401: Combat progression system initialization
 * - Background: Experience tracking and rank-up checking
 */

// ============================================================================
// COMBAT EXPERIENCE TRACKING
// ============================================================================

/datum/combat_experience
	/**
	 * combat_experience
	 * Track experience gain from combat activities
	 */
	var
		// Identity
		player_ref = null
		skill_name = ""
		
		// Experience tracking
		current_exp = 0
		exp_to_next_level = 100
		total_exp = 0
		
		// Multipliers
		exp_multiplier = 1.0
		difficulty_multiplier = 1.0

/datum/combat_experience/New(skill)
	..()
	skill_name = skill
	exp_to_next_level = CalculateExpThreshold(1)

/proc/CalculateExpThreshold(rank)
	/**
	 * CalculateExpThreshold(rank)
	 * Calculate experience needed to reach next rank
	 * Returns: Experience points
	 */
	
	// Exponential scaling: 100 * 1.5^(rank-1)
	// Rank 1→2: 100 exp
	// Rank 2→3: 150 exp
	// Rank 3→4: 225 exp
	// Rank 4→5: 337 exp
	
	if(rank < 1) rank = 1
	if(rank > 5) rank = 5
	
	var/multiplier = 1.0
	for(var/i = 1; i < rank; i++)
		multiplier *= 1.5
	
	return ceil(100 * multiplier)

// ============================================================================
// EXPERIENCE GAIN MECHANICS
// ============================================================================

/proc/AwardCombatExperience(mob/players/player, skill_name, damage_dealt)
	/**
	 * AwardCombatExperience(mob/players/player, skill_name, damage_dealt)
	 * Award experience for combat action
	 * Called when player deals damage
	 */
	
	if(!player || !skill_name)
		return 0
	
	// Get or create experience tracker
	var/list/combat_exp = player.vars["combat_exp"] || list()
	if(!combat_exp[skill_name])
		combat_exp[skill_name] = new /datum/combat_experience(skill_name)
	
	player.vars["combat_exp"] = combat_exp
	var/datum/combat_experience/exp_data = combat_exp[skill_name]
	// Base: 1 exp per 2 damage dealt
	var/exp_gained = ceil(damage_dealt / 2.0)
	exp_gained *= exp_data.exp_multiplier
	exp_gained = ceil(exp_gained * exp_data.difficulty_multiplier)
	exp_data.current_exp += exp_gained
	exp_data.total_exp += exp_gained
	
	// Check for rank-up
	while(exp_data.current_exp >= exp_data.exp_to_next_level)
		exp_data.current_exp -= exp_data.exp_to_next_level
		var/current_rank = GetRankLevel(player, skill_name)
		ProcessRankUp(player, skill_name, current_rank + 1)
		
		// Update next threshold
		exp_data.exp_to_next_level = CalculateExpThreshold(current_rank + 2)
	
	return exp_gained

/proc/ProcessRankUp(mob/players/player, skill_name, new_rank)
	/**
	 * ProcessRankUp(mob/players/player, skill_name, new_rank)
	 * Handle rank advancement and unlocks
	 */
	
	if(!player || !skill_name || new_rank < 2 || new_rank > 5)
		return FALSE
	
	// Update rank
	SetRankLevel(player, skill_name, new_rank)
	
	// Announce to player
	player << "<font color=#FFFF00>========================================</font>"
	player << "<font color=#FFFF00>RANK UP: [skill_name] Level [new_rank]!</font>"
	player << "<font color=#FFFF00>========================================</font>"
	UnlockAttackBySkill(player, skill_name, new_rank)
	
	// Update equipment crafting gates
	UpdateEquipmentGates(player, skill_name, new_rank)
	
	// Award rank-up bonuses
	AwardRankUpBonus(player, skill_name, new_rank)
	
	world.log << "PROGRESSION: [player.name] reached [skill_name] rank [new_rank]"
	
	return TRUE

// ============================================================================
// EQUIPMENT CRAFTING GATES
// ============================================================================

/proc/UpdateEquipmentGates(mob/players/player, skill_name, rank)
	/**
	 * UpdateEquipmentGates(mob/players/player, skill_name, rank)
	 * Update which materials can be crafted based on rank
	 * Progression: Materials unlock as player advances
	 */
	
	if(!player)
		return FALSE
	
	var/list/unlocked_materials = player.vars["unlocked_materials"] || list()
	var/continent = player.vars["current_continent"] || "story"
	var/datum/continent_material_registry/registry = material_registries[continent]
	if(!registry)
		return FALSE
	
	// Determine which materials unlock at this rank
	var/list/materials_to_unlock = list()
	
	switch(skill_name)
		if("smithing")
			switch(rank)
				if(1)
					materials_to_unlock += "Copper"
					materials_to_unlock += "Tin"
				if(2)
					materials_to_unlock += "Lead"
					materials_to_unlock += "Zinc"
				if(3)
					materials_to_unlock += "Bronze"
					materials_to_unlock += "Brass"
				if(4)
					materials_to_unlock += "Iron"
				if(5)
					materials_to_unlock += "Steel"
	
	// Unlock materials
	var/unlocked_count = 0
	for(var/material_name in materials_to_unlock)
		if(!(material_name in unlocked_materials))
			unlocked_materials[material_name] = TRUE
			unlocked_count++
			player << "<font color=#00FF00>Unlocked [material_name] crafting!</font>"
	
	player.vars["unlocked_materials"] = unlocked_materials
	
	return unlocked_count > 0

// ============================================================================
// RANK-UP BONUSES
// ============================================================================

/proc/AwardRankUpBonus(mob/players/player, skill_name, rank)
	/**
	 * AwardRankUpBonus(mob/players/player, skill_name, rank)
	 * Award stat bonuses for rank-up
	 * Higher rank = better stats
	 */
	
	if(!player)
		return FALSE
	
	// Stamina increase per rank
	var/datum/combat_state/state = player.vars["combat_state"]
	if(state)
		state.max_stamina += (10 * rank)
		state.current_stamina = state.max_stamina
		player << "<font color=#00FF00>Max Stamina +[10 * rank]</font>"
	var/lucre_bonus = 50 * rank
	player.lucre += lucre_bonus
	player << "<font color=#00FF00>Lucre Bonus +[lucre_bonus]</font>"
	player.vars["equipment_quality_bonus"] = (rank - 1) * 5  // +5% per rank
	
	return TRUE

// ============================================================================
// SKILL-TO-EQUIPMENT QUALITY
// ============================================================================

/proc/GetEquipmentQualityBonus(mob/players/player, skill_name)
	/**
	 * GetEquipmentQualityBonus(mob/players/player, skill_name)
	 * Get quality bonus from player's skill rank
	 * Returns: Percentage (0-20%)
	 */
	
	if(!player)
		return 0
	
	var/rank = GetRankLevel(player, skill_name)
	if(rank < 1)
		return 0
	
	// Bonus per rank: 4% per level
	// Rank 1: 4%, Rank 2: 8%, Rank 3: 12%, Rank 4: 16%, Rank 5: 20%
	return (rank - 1) * 4

/proc/CraftEquipmentWithSkillBonus(mob/players/player, material_name, equipment_type)
	/**
	 * CraftEquipmentWithSkillBonus(mob/players/player, material_name, equipment_type)
	 * Craft equipment with skill-based quality boost
	 * Returns: /obj/items/equipment or null
	 */
	
	if(!player)
		return null
	
	// Get smithing rank
	var/smith_rank = GetRankLevel(player, "smithing")
	if(smith_rank < 1)
		return null
	
	// Craft base equipment
	var/obj/items/equipment/equipment = null
	
	switch(equipment_type)
		if("weapon")
			equipment = CraftWeapon(material_name, player.vars["current_continent"] || "story", smith_rank)
		if("armor")
			equipment = CraftArmor(material_name, player.vars["current_continent"] || "story", smith_rank)
	
	if(!equipment)
		return null
	
	// Apply skill quality bonus
	var/quality_bonus = GetEquipmentQualityBonus(player, "smithing")
	equipment.stats.quality_percent += quality_bonus
	equipment.stats.damage_modifier = equipment.stats.quality_percent / 100.0
	equipment.stats.armor_modifier = equipment.stats.quality_percent / 100.0
	equipment.stats.durability_modifier = equipment.stats.quality_percent / 100.0
	equipment.current_damage = equipment.stats.base_damage * equipment.stats.damage_modifier
	equipment.current_armor = equipment.stats.armor_class * equipment.stats.armor_modifier
	equipment.current_durability = equipment.stats.durability_max * equipment.stats.durability_modifier
	
	player << "<font color=#FFFF00>Equipment Quality: [equipment.stats.quality_percent]%</font>"
	
	return equipment

// ============================================================================
// COMBAT FEEDBACK WITH EXPERIENCE
// ============================================================================

/proc/DisplayCombatExperience(mob/players/player, skill_name)
	/**
	 * DisplayCombatExperience(mob/players/player, skill_name)
	 * Show player's combat progress
	 */
	
	if(!player)
		return
	
	var/list/combat_exp = player.vars["combat_exp"]
	if(!combat_exp || !combat_exp[skill_name])
		return
	
	var/datum/combat_experience/exp = combat_exp[skill_name]
	var/rank = GetRankLevel(player, skill_name)
	
	var/progress_percent = (exp.current_exp / exp.exp_to_next_level) * 100
	
	player << "\n<font color=#FFFF00>=== [skill_name] PROGRESS ===</font>"
	player << "Rank: [rank]"
	player << "Experience: [exp.current_exp]/[exp.exp_to_next_level] ([progress_percent]%)"
	player << "Total: [exp.total_exp] exp"
	player << "\n"

// ============================================================================
// DIFFICULTY & ENEMY SCALING
// ============================================================================

/proc/GetDifficultyMultiplier(mob/defender, mob/attacker)
	/**
	 * GetDifficultyMultiplier(mob/defender, mob/attacker)
	 * Calculate experience multiplier based on difficulty
	 * Higher rank enemies = more experience
	 */
	
	if(!attacker || !defender)
		return 1.0
	
	if(!istype(attacker, /mob/players))
		return 1.0
	
	var/mob/players/player = attacker
	var/attacker_rank = GetRankLevel(player, "combat")
	
	var/defender_rank = 1
	if(istype(defender, /mob/players))
		var/mob/players/pdef = defender
		defender_rank = GetRankLevel(pdef, "combat")
	// - Fighting weaker enemies: 0.5x exp (capped at 50%)
	// - Fighting equal enemies: 1.0x exp
	// - Fighting stronger enemies: 1.5x exp (per rank difference)
	
	var/rank_diff = defender_rank - attacker_rank
	
	if(rank_diff < 0)
		return max(0.5, 1.0 + (rank_diff * 0.1))  // Penalty for weaker
	else
		return 1.0 + (rank_diff * 0.15)  // Bonus for stronger

// ============================================================================
// PROGRESSION MILESTONES
// ============================================================================

/proc/CheckProgressionMilestone(mob/players/player)
	/**
	 * CheckProgressionMilestone(mob/players/player)
	 * Check for significant progression achievements
	 * Rewards special items or abilities
	 */
	
	if(!player)
		return
	
	// Check for first rank 5
	var/has_rank5 = FALSE
	for(var/skill in list("smithing", "fishing", "mining", "crafting"))
		if(GetRankLevel(player, skill) >= 5)
			has_rank5 = TRUE
			break
	
	if(has_rank5 && !player.vars["milestone_first_rank5"])
		player.vars["milestone_first_rank5"] = TRUE
		player << "<font color=#FFFF00>ACHIEVEMENT: Reached Rank 5 in a skill!</font>"
		player.lucre += 500
		world.log << "MILESTONE: [player.name] reached first skill rank 5"

// ============================================================================
// INITIALIZATION & BACKGROUND
// ============================================================================

/proc/InitializeCombatProgression()
	/**
	 * InitializeCombatProgression()
	 * Called from InitializationManager.dm at T+401
	 * Initialize combat progression system
	 */
	
	world.log << "PROGRESSION: Combat progression loop initialized"
	
	return TRUE

/proc/ProgressionProcessor()
	/**
	 * ProgressionProcessor()
	 * Background loop: Check for rank-ups, milestone processing
	 */
	set background = 1
	set waitfor = 0
	
	var/process_interval = 50
	var/last_process = world.time
	
	while(1)
		sleep(10)
		
		if(world.time - last_process >= process_interval)
			last_process = world.time
			for(var/mob/players/player in world)
				if(!player)
					continue
				
				// Check for progression milestones
				CheckProgressionMilestone(player)

// ============================================================================
// RANK INTEGRATION (Bridge to UnifiedRankSystem)
// ============================================================================

/proc/GetRankLevel(mob/players/player, skill_name)
	/**
	 * GetRankLevel(mob/players/player, skill_name)
	 * Get player's rank in skill
	 * Returns: 1-5, or 0 if not ranked
	 * Bridge to UnifiedRankSystem.dm
	 */
	
	if(!player || !player.character)
		return 0
	
	// Map skill names to rank variables
	var/rank_var = ""
	switch(skill_name)
		if("fishing") rank_var = "frank"
		if("crafting") rank_var = "crank"
		if("mining") rank_var = "mrank"
		if("smithing") rank_var = "smirank"
		if("archery") rank_var = "archrank"
		if("combat") rank_var = "combatrank"
		else rank_var = "[skill_name]rank"
	
	return player.character.vars[rank_var] || 0

/proc/SetRankLevel(mob/players/player, skill_name, level)
	/**
	 * SetRankLevel(mob/players/player, skill_name, level)
	 * Set player's rank in skill
	 * Bridge to UnifiedRankSystem.dm
	 */
	
	if(!player || !player.character || level < 1 || level > 5)
		return FALSE
	
	// Map skill names to rank variables
	var/rank_var = ""
	switch(skill_name)
		if("fishing") rank_var = "frank"
		if("crafting") rank_var = "crank"
		if("mining") rank_var = "mrank"
		if("smithing") rank_var = "smirank"
		if("archery") rank_var = "archrank"
		if("combat") rank_var = "combatrank"
		else rank_var = "[skill_name]rank"
	
	player.character.vars[rank_var] = level
	
	return TRUE

// ============================================================================
// TESTING & DEBUG
// ============================================================================

/proc/DebugAwardExperience(mob/players/player, skill_name, amount)
	/**
	 * DebugAwardExperience(mob/players/player, skill_name, amount)
	 * DEBUG: Instantly award experience
	 */
	
	if(!player)
		return
	
	// Get or create experience tracker
	var/list/combat_exp = player.vars["combat_exp"] || list()
	if(!combat_exp[skill_name])
		combat_exp[skill_name] = new /datum/combat_experience(skill_name)
	
	player.vars["combat_exp"] = combat_exp
	var/datum/combat_experience/exp_data = combat_exp[skill_name]
	exp_data.current_exp += amount
	
	// Check for rank-up
	while(exp_data.current_exp >= exp_data.exp_to_next_level)
		exp_data.current_exp -= exp_data.exp_to_next_level
		var/current_rank = GetRankLevel(player, skill_name)
		ProcessRankUp(player, skill_name, current_rank + 1)
		exp_data.exp_to_next_level = CalculateExpThreshold(current_rank + 2)
	
	player << "<font color=#00FF00>DEBUG: +[amount] experience ([skill_name])</font>"
