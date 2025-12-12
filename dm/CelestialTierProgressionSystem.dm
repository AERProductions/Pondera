/// ============================================================================
/// CELESTIAL TIER PROGRESSION SYSTEM
/// Endgame progression system with ascension tiers, celestial powers, and
/// prestige mechanics. Extends the existing ascension mode with power progression.
///
/// Created: 12-11-25 12:00AM
/// ============================================================================

#define TIER_PROGRESSION_MAX_LEVEL  5
#define TIER_XP_REQUIREMENT         500  // XP needed per tier
#define CELESTIAL_POWER_SLOTS       6
#define PRESTIGE_BONUS_BASE         1.5

/// ============================================================================
/// CELESTIAL POWER DATUM
/// ============================================================================

/datum/celestial_power
	var
		name = ""                // "Void Strike", "Celestial Healing"
		tier = 1
		description = ""
		damage_bonus = 0         // Percent increase to damage
		healing_bonus = 0        // Percent increase to healing
		speed_bonus = 0          // Percent increase to movement speed
		stat_boost = 0           // Generic stat multiplier
		cooldown = 0             // Ticks between uses
		mana_cost = 0            // If using mana system
		unlocked = FALSE
		uses_remaining = 0

/datum/celestial_power/proc/Activate(mob/player)
	// Activate this power's effect
	if(cooldown > world.time)
		player << "<span style='color: #ffb74d;'>[name] is still on cooldown!</span>"
		return FALSE
	
	if(uses_remaining <= 0 && mana_cost > 0)
		player << "<span style='color: #ff6b6b;'>Not enough energy for [name]!</span>"
		return FALSE
	
	// Apply effect
	uses_remaining = max(0, uses_remaining - 1)
	cooldown = world.time + 100  // 10 second cooldown
	
	return TRUE

/datum/celestial_power/proc/GetDescription()
	var/desc = "<b>[name]</b> (Tier [tier])<br>"
	desc += description + "<br>"
	if(damage_bonus > 0)
		desc += "Damage: +[damage_bonus]% | "
	if(healing_bonus > 0)
		desc += "Healing: +[healing_bonus]% | "
	if(speed_bonus > 0)
		desc += "Speed: +[speed_bonus]% | "
	desc += "Cooldown: [cooldown]"
	return desc

/// ============================================================================
/// TIER PROGRESSION STATE
/// ============================================================================

/datum/tier_progression_state
	var
		player_ref = null        // Reference to mob/players
		current_tier = 0         // 0 = not progressed, 1-5 = tier level
		tier_xp = 0              // XP toward next tier
		total_tier_resets = 0    // Prestige count
		active_powers = list()   // Currently equipped celestial powers
		power_slots_used = 0     // How many slots filled (max CELESTIAL_POWER_SLOTS)
		prestige_multiplier = 1.0 // Cumulative bonus from resets

/datum/tier_progression_state/proc/GetTierTitle()
	switch(current_tier)
		if(0)
			return "Initiate"
		if(1)
			return "Awakened"
		if(2)
			return "Transcendent"
		if(3)
			return "Celestial"
		if(4)
			return "Godlike"
		if(5)
			return "Infinite"
	return "Unknown"

/datum/tier_progression_state/proc/CanProgress()
	if(current_tier >= TIER_PROGRESSION_MAX_LEVEL)
		return FALSE
	
	var/xp_needed = TIER_XP_REQUIREMENT * (current_tier + 1)
	return tier_xp >= xp_needed

/datum/tier_progression_state/proc/AttemptProgression()
	if(!CanProgress())
		return FALSE
	
	current_tier++
	tier_xp = 0
	prestige_multiplier += PRESTIGE_BONUS_BASE * (current_tier * 0.1)
	
	if(istype(player_ref, /mob/players))
		player_ref << "<span style='color: #ce93d8;'>** YOU HAVE ADVANCED TO TIER [current_tier]! **</span>"
		player_ref << "<span style='color: #b39ddb;'>Title: [GetTierTitle()]</span>"
	
	return TRUE

/datum/tier_progression_state/proc/GainTierXP(amount)
	tier_xp += amount
	
	// Auto-attempt progression if threshold reached
	while(CanProgress())
		AttemptProgression()

/datum/tier_progression_state/proc/EquipPower(datum/celestial_power/power)
	if(power_slots_used >= CELESTIAL_POWER_SLOTS)
		return FALSE
	
	active_powers += power
	power_slots_used++
	
	return TRUE

/datum/tier_progression_state/proc/UnequipPower(power_name)
	for(var/i = 1; i <= length(active_powers); i++)
		var/datum/celestial_power/power = active_powers[i]
		if(power && power.name == power_name)
			active_powers[i] = null
			power_slots_used--
			return TRUE
	return FALSE

/datum/tier_progression_state/proc/PrestigeReset()
	// Reset to Tier 0, keep prestige bonus, unlock new content
	current_tier = 0
	tier_xp = 0
	total_tier_resets++
	
	if(istype(player_ref, /mob/players))
		player_ref << "<span style='color: #ffb74d;'>You have performed a PRESTIGE RESET!</span>"
		player_ref << "<span style='color: #90caf9;'>Total Resets: [total_tier_resets]</span>"
		player_ref << "<span style='color: #90caf9;'>Prestige Multiplier: [prestige_multiplier]x</span>"
	
	return TRUE

/// ============================================================================
/// CELESTIAL POWER REGISTRY
/// ============================================================================

var/datum/celestial_power_registry/global_celestial_registry

/proc/GetCelestialPowerRegistry()
	if(!global_celestial_registry)
		global_celestial_registry = new /datum/celestial_power_registry()
	return global_celestial_registry

/datum/celestial_power_registry
	var
		all_powers = list()      // power_name -> /datum/celestial_power

/datum/celestial_power_registry/proc/RegisterPowers()
	// Initialize all celestial powers
	
	// TIER 1 POWERS
	var/datum/celestial_power/void_strike = new
	void_strike.name = "Void Strike"
	void_strike.tier = 1
	void_strike.description = "Channel void energy for a devastating attack. Ignore 30% of enemy armor."
	void_strike.damage_bonus = 50
	void_strike.cooldown = 100
	all_powers["void_strike"] = void_strike
	
	var/datum/celestial_power/celestial_healing = new
	celestial_healing.name = "Celestial Healing"
	celestial_healing.tier = 1
	celestial_healing.description = "Channel celestial energy to heal. Restores 40% health."
	celestial_healing.healing_bonus = 40
	celestial_healing.cooldown = 150
	all_powers["celestial_healing"] = celestial_healing
	
	// TIER 2 POWERS
	var/datum/celestial_power/time_warp = new
	time_warp.name = "Time Warp"
	time_warp.tier = 2
	time_warp.description = "Bend time around yourself. Gain 50% movement speed for 30 seconds."
	time_warp.speed_bonus = 50
	time_warp.cooldown = 300
	all_powers["time_warp"] = time_warp
	
	var/datum/celestial_power/meteor_strike = new
	meteor_strike.name = "Meteor Strike"
	meteor_strike.tier = 2
	meteor_strike.description = "Call meteors from the heavens. 80% bonus damage in large AOE."
	meteor_strike.damage_bonus = 80
	meteor_strike.cooldown = 250
	all_powers["meteor_strike"] = meteor_strike
	
	// TIER 3 POWERS
	var/datum/celestial_power/ascension_shield = new
	ascension_shield.name = "Ascension Shield"
	ascension_shield.tier = 3
	ascension_shield.description = "Summon a shield that blocks 50% of all damage. Lasts 20 seconds."
	ascension_shield.stat_boost = 50
	ascension_shield.cooldown = 400
	all_powers["ascension_shield"] = ascension_shield
	
	var/datum/celestial_power/void_vortex = new
	void_vortex.name = "Void Vortex"
	void_vortex.tier = 3
	void_vortex.description = "Create a vortex of void energy. Pull enemies close and damage all in area."
	void_vortex.damage_bonus = 100
	void_vortex.cooldown = 350
	all_powers["void_vortex"] = void_vortex
	
	// TIER 4 POWERS
	var/datum/celestial_power/infinite_potential = new
	infinite_potential.name = "Infinite Potential"
	infinite_potential.tier = 4
	infinite_potential.description = "Unlock your full potential. Gain 200% stat bonuses for 60 seconds."
	infinite_potential.stat_boost = 200
	infinite_potential.cooldown = 600
	all_powers["infinite_potential"] = infinite_potential
	
	var/datum/celestial_power/reality_shift = new
	reality_shift.name = "Reality Shift"
	reality_shift.tier = 4
	reality_shift.description = "Shift reality itself. Teleport to target location and stun enemies."
	reality_shift.speed_bonus = 100
	reality_shift.cooldown = 500
	all_powers["reality_shift"] = reality_shift
	
	// TIER 5 POWERS
	var/datum/celestial_power/celestial_ascension = new
	celestial_ascension.name = "Celestial Ascension"
	celestial_ascension.tier = 5
	celestial_ascension.description = "Achieve true ascension. Perfect all stats and become invulnerable for 30 seconds."
	celestial_ascension.stat_boost = 500
	celestial_ascension.cooldown = 1000
	all_powers["celestial_ascension"] = celestial_ascension

/datum/celestial_power_registry/proc/GetPower(power_name)
	if(!length(all_powers))
		RegisterPowers()
	return all_powers[power_name]

/datum/celestial_power_registry/proc/GetPowersByTier(tier)
	var/list/result = list()
	for(var/pname in all_powers)
		var/datum/celestial_power/power = all_powers[pname]
		if(power.tier == tier)
			result += power
	return result

/// ============================================================================
/// TIER PROGRESSION SYSTEM COORDINATOR
/// ============================================================================

var/datum/tier_progression_system/global_tier_system

/proc/GetTierProgressionSystem()
	if(!global_tier_system)
		global_tier_system = new /datum/tier_progression_system()
	return global_tier_system

/datum/tier_progression_system
	var
		player_tier_states = list() // player.ckey -> /datum/tier_progression_state

/datum/tier_progression_system/proc/InitializePlayer(mob/player)
	// Set up tier progression for new player
	if(!(player.ckey in player_tier_states))
		var/datum/tier_progression_state/state = new
		state.player_ref = player
		state.current_tier = 0
		state.tier_xp = 0
		state.total_tier_resets = 0
		state.prestige_multiplier = 1.0
		player_tier_states[player.ckey] = state
	return player_tier_states[player.ckey]

/datum/tier_progression_system/proc/GetPlayerState(mob/player)
	if(!(player.ckey in player_tier_states))
		return InitializePlayer(player)
	return player_tier_states[player.ckey]

/datum/tier_progression_system/proc/ShowTierUI(mob/player)
	// Display comprehensive tier progression status
	var/datum/tier_progression_state/state = GetPlayerState(player)
	
	var/html = "<html><head><title>Tier Progression</title><style>"
	html += "body { background: #0a0a0a; color: #ddd; font-family: monospace; padding: 15px; }"
	html += ".header { background: linear-gradient(to right, #ce93d8, #b39ddb); color: #000; padding: 10px; font-weight: bold; text-align: center; font-size: 1.2em; }"
	html += ".stat-panel { background: #1a1a1a; border: 2px solid #ce93d8; padding: 10px; margin: 10px 0; }"
	html += ".tier-bar { height: 25px; background: #333; border: 1px solid #666; margin: 5px 0; border-radius: 3px; }"
	html += ".tier-fill { height: 100%; background: linear-gradient(to right, #ce93d8, #b39ddb); transition: width 0.3s; border-radius: 3px; }"
	html += ".power-slot { background: #0a1a2e; border: 1px solid #90caf9; padding: 8px; margin: 5px 0; border-radius: 3px; }"
	html += "</style></head><body>"
	
	html += "<div class='header'>TIER PROGRESSION SYSTEM</div>"
	html += "<div class='stat-panel'>"
	html += "<b>Title:</b> [state.GetTierTitle()]<br>"
	html += "<b>Current Tier:</b> [state.current_tier]/[TIER_PROGRESSION_MAX_LEVEL]<br>"
	html += "<b>Prestige Resets:</b> [state.total_tier_resets]<br>"
	html += "<b>Prestige Multiplier:</b> [state.prestige_multiplier]x<br>"
	html += "</div>"
	
	html += "<b>Tier Progression:</b><br>"
	var/xp_needed = TIER_XP_REQUIREMENT * (state.current_tier + 1)
	var/progress = (state.tier_xp / xp_needed) * 100
	html += "<div class='tier-bar'><div class='tier-fill' style='width: [progress]%;'></div></div>"
	html += "[state.tier_xp] / [xp_needed] XP ([round(progress)]%)<br><br>"
	
	html += "<b>Equipped Celestial Powers ([state.power_slots_used]/[CELESTIAL_POWER_SLOTS]):</b><br>"
	if(state.power_slots_used == 0)
		html += "<div style='color: #ffb74d;'>No powers equipped.</div>"
	else
		for(var/datum/celestial_power/power in state.active_powers)
			if(power)
				html += "<div class='power-slot'>[power.GetDescription()]</div>"
	
	html += "<br><b>Available Powers at Tier [state.current_tier]:</b><br>"
	var/datum/celestial_power_registry/registry = GetCelestialPowerRegistry()
	var/list/available = registry.GetPowersByTier(state.current_tier)
	if(!length(available))
		html += "<p style='color: #ffb74d;'>Advance to next tier to unlock new powers!</p>"
	else
		for(var/datum/celestial_power/power in available)
			html += "<div class='power-slot'>[power.GetDescription()]</div>"
	
	html += "</body></html>"
	return html

/datum/tier_progression_system/proc/GainTierXP(mob/player, amount)
	var/datum/tier_progression_state/state = GetPlayerState(player)
	state.GainTierXP(amount)

/datum/tier_progression_system/proc/AttemptPrestige(mob/player)
	// Player chooses to reset and prestige
	var/datum/tier_progression_state/state = GetPlayerState(player)
	state.PrestigeReset()

/datum/tier_progression_system/proc/EquipPower(mob/player, power_name)
	var/datum/tier_progression_state/state = GetPlayerState(player)
	var/datum/celestial_power_registry/registry = GetCelestialPowerRegistry()
	var/datum/celestial_power/power = registry.GetPower(power_name)
	
	if(!power)
		return FALSE
	
	if(power.tier > state.current_tier)
		player << "<span style='color: #ff6b6b;'>Tier [power.tier] power required! Current tier: [state.current_tier]</span>"
		return FALSE
	
	return state.EquipPower(power)

/datum/tier_progression_system/proc/GetStatusReport(mob/player)
	var/datum/tier_progression_state/state = GetPlayerState(player)
	var/report = "=== TIER PROGRESSION REPORT ===\n"
	report += "Title: [state.GetTierTitle()]\n"
	report += "Tier: [state.current_tier]/[TIER_PROGRESSION_MAX_LEVEL]\n"
	
	var/xp_needed = TIER_XP_REQUIREMENT * (state.current_tier + 1)
	report += "XP: [state.tier_xp]/[xp_needed]\n"
	report += "Powers: [state.power_slots_used]/[CELESTIAL_POWER_SLOTS]\n"
	report += "Prestige: [state.total_tier_resets]x ([state.prestige_multiplier])\n"
	
	return report

/// ============================================================================
/// INTEGRATION WITH INITIALIZATION
/// ============================================================================

proc/InitializeTierProgression()
	// Called from InitializationManager.dm Phase 5
	
	if(!world_initialization_complete)
		spawn(400)
			InitializeTierProgression()
		return
	
	var/datum/tier_progression_system/sys = GetTierProgressionSystem()
	var/datum/celestial_power_registry/registry = GetCelestialPowerRegistry()
	registry.RegisterPowers()
	
	RegisterInitComplete("TierProgression")

/// ============================================================================
/// END CELESTIAL TIER PROGRESSION SYSTEM
/// ============================================================================
