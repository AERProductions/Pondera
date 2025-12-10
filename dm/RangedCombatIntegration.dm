// RangedCombatIntegration.dm - Phase 40: Integration of ranged attacks into combat system
// Adds ranged attack verbs, weapon integration, and combat flow

// =============================================================================
// RANGED ATTACK VERBS FOR WEAPONS
// =============================================================================

// NOTE: Attack verbs have been replaced by the macro-key combat system
// E = Melee attack with equipped weapon
// V = Ranged attack with equipped ranged weapon
// Spacebar = Shield/Dodge
// See MacroKeyCombatSystem.dm for implementation

// ============================================================================
// RANGED COMBAT HELPER FUNCTIONS
// ============================================================================

/proc/get_continent_for_player(mob/player)
	/**
	 * get_continent_for_player(player)
	 * Returns the continent key where the player currently is
	 * Used for PvP/combat rule enforcement
	 */
	if(!player || !player.loc) return null
	
	var/turf/T = player.loc
	if(!T) return null
	
	// Check which continent the turf belongs to
	// This is a simplified check - in full implementation, turfs would have continent markers
	// For now, return default continent
	
	return "story"  // Default to story continent

// =============================================================================
// RANGED COMBAT STAT DISPLAY
// =============================================================================

/mob/players/proc/GetRangedCombatStats()
	/**
	 * GetRangedCombatStats()
	 * Returns a formatted string of the player's ranged combat abilities
	 * Used for HUD display and combat analysis
	 */
	
	if(!character) return "No character data"
	
	var/archery_level = GetRankLevel(RANK_ARCHERY)
	var/crossbow_level = GetRankLevel(RANK_CROSSBOW)
	var/throwing_level = GetRankLevel(RANK_THROWING)
	
	var/output = ""
	output += "=== RANGED COMBAT STATS ===\n"
	output += "Archery: Level [archery_level]/5\n"
	output += "Crossbow: Level [crossbow_level]/5\n"
	output += "Throwing: Level [throwing_level]/5\n"
	
	return output

// =============================================================================
// RANGED ATTACK LOGGING AND ANALYTICS
// =============================================================================

/proc/LogRangedAttack(mob/attacker, mob/defender, projectile_type, accuracy, did_hit, damage_dealt)
	/**
	 * LogRangedAttack(attacker, defender, projectile_type, accuracy, did_hit, damage_dealt)
	 * Logs ranged attack for analytics and debugging
	 */
	
	var/attacker_name = attacker ? attacker.name : "unknown"
	var/defender_name = defender ? defender.name : "unknown"
	var/hit_status = did_hit ? "HIT" : "MISS"
	
	world.log << "[attacker_name] [hit_status] [defender_name] with [projectile_type] (accuracy: [accuracy], damage: [damage_dealt])"

// =============================================================================
// RANGED COMBAT UI UPDATES
// =============================================================================

/mob/players/proc/UpdateRangedCombatUI()
	/**
	 * UpdateRangedCombatUI()
	 * Refreshes the HUD to show current ranged combat status
	 */
	
	if(!client) return
	
	// This would be implemented in the full HUD system
	// For now, just show combat stats in world.log
	world.log << GetRangedCombatStats()

// =============================================================================
// RANGED WEAPON EQUIP/UNEQUIP INTEGRATION
// =============================================================================

// Note: equipped() and unequipped() hooks are not standard BYOND procs
// Equipment feedback is handled by the CentralizedEquipmentSystem instead

// =============================================================================
// RANGED COMBAT SPECIAL EFFECTS
// =============================================================================

/proc/PlayRangedHitEffect(turf/impact_location, projectile_type)
	/**
	 * PlayRangedHitEffect(impact_location, projectile_type)
	 * Creates visual/audio feedback for ranged hits
	 */
	
	if(!impact_location) return
	
	// Determine effect based on projectile type
	var/effect_icon = 'dmi/64/blank.dmi'
	var/effect_state = "hit"
	
	switch(projectile_type)
		if("arrow", "bolt")
			effect_state = "arrow_hit"
		if("knife", "javelin")
			effect_state = "melee_hit"
		if("stone")
			effect_state = "stone_hit"
	
	// Create impact visual
	var/obj/effect/ranged_hit/E = new(impact_location)
	E.icon = effect_icon
	E.icon_state = effect_state

// =============================================================================
// RANGED HIT EFFECT OBJECT
// =============================================================================

/obj/effect/ranged_hit
	name = "impact"
	icon = 'dmi/64/blank.dmi'
	icon_state = "hit"
	layer = EFFECTS_LAYER
	var/duration = 5  // Show for 0.5 seconds

/obj/effect/ranged_hit/New()
	..()
	spawn(duration)
		del(src)

// =============================================================================
// DEBUG VERBS FOR RANGED COMBAT
// =============================================================================

/mob/verb/DebugRangedStats()
	set category = "Debug"
	set name = "Show Ranged Stats"
	
	if(istype(src, /mob/players))
		var/mob/players/P = src
		src << P.GetRangedCombatStats()
	else
		src << "Only players have ranged combat stats!"

/mob/verb/DebugRangedAttack()
	set category = "Debug"
	set name = "Test Ranged Attack (Debug)"
	
	if(!istype(src, /mob/players))
		src << "Only players can use ranged attacks!"
		return
	
	var/mob/target = input(src, "Select a target:", "Ranged Attack") as null|mob in world
	if(!target)
		src << "Cancelled."
		return
	
	if(target == src)
		src << "You can't attack yourself!"
		return
	
	src << "Attempting ranged attack on [target.name]..."
	
	if(FireRangedAttack(src, target, "arrow", RANK_ARCHERY))
		src << "Attack succeeded!"
	else
		src << "Attack failed!"
