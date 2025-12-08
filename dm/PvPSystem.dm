// PvPSystem.dm - Phase E: PvP Continent Mechanics
// Handles territory claiming, fortifications, raiding, and combat progression

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

var/global/list/raid_history = list()

/proc/InitializePvPSystem()
	if(!continents || !("pvp" in continents))
		return

	var/datum/continent/pvp_cont = continents["pvp"]
	
	// Configure PvP continent rules
	ConfigurePvPTerrain(pvp_cont)
	InitializePvPTerritory()
	InitializePvPCombatSystem()
	InitializePvPDynamicEvents()
	
	world << "PVP PvP Continent Initialized - Territory, Fortifications, Combat & Events Ready"

/proc/ConfigurePvPTerrain(datum/continent/pvp_cont)
	if(!pvp_cont) return
	
	// PvP continent rules
	pvp_cont.allow_pvp = 1
	pvp_cont.allow_stealing = 1
	pvp_cont.monster_spawn = 1
	pvp_cont.npc_spawn = 1
	pvp_cont.allow_building = 0  // Building restricted to claimed territories
	pvp_cont.weather = 1
	
	world << "PVP PvP Continent Rules Applied: PvP=ON, Stealing=ON, Monsters=ON, Events=ON"

/proc/InitializePvPTerritory()
	// Initialize global territory management
	global.pvp_territories = list()
	global.player_claims = list()
	global.territory_resources = list()
	
	world << "PVP Territory System Initialized"

/proc/InitializePvPCombatSystem()
	// Initialize combat progression
	global.player_combat_xp = list()
	global.player_combat_level = list()
	global.player_kill_count = list()
	
	world << "PVP Combat Progression System Ready"

/proc/InitializePvPDynamicEvents()
	// Initialize dynamic event system
	global.active_pvp_events = list()
	global.event_history = list()
	
	// Start event loop
	spawn(200) PvPEventLoop()
	
	world << "PVP Dynamic Events System Activated"

// Territory Claim System
/datum/territory_claim
	var
		claim_id = null
		owner_key = null
		owner_name = null
		faction_id = 0
		center_x = 0
		center_y = 0
		center_z = 0
		radius = 10  // Territory control radius in turfs
		claimed_turfs = list()
		
		// Resources within territory
		resource_nodes = list()
		ore_reserves = 0
		wood_reserves = 0
		
		// Fortifications
		walls = list()
		towers = list()
		gates = list()
		defense_rating = 0
		
		// Status
		is_active = 1
		creation_time = 0
		last_attacked = 0
		tax_rate = 0.1  // 10% resource tax
		

	proc/ClaimTerritory(mob/player, x, y, z)
		if(!player) return 0
		
		// Verify player has resources (100 stone, 50 wood)
		var/stone_count = 0
		var/wood_count = 0
		for(var/obj/O in player.contents)
			if(O.name == "Stone") stone_count++
			if(O.name == "Wood") wood_count++
		
		if(stone_count < 100 || wood_count < 50)
			player << "Need 100 Stone + 50 Wood to claim territory"
			return 0
		
		// Create claim
		claim_id = "[player.key]_[x]_[y]_[z]"
		owner_key = player.key
		owner_name = player.name
		center_x = x
		center_y = y
		center_z = z
		creation_time = world.timeofday
		
		// Consume resources
		for(var/obj/O in player.contents)
			if(O.name == "Stone" && stone_count > 0)
				del O
				stone_count--
			if(O.name == "Wood" && wood_count > 0)
				del O
				wood_count--
		
		player << "Territory claimed! Build fortifications to defend it."
		
		global.pvp_territories[claim_id] = src
		global.player_claims[player.key] = claim_id
		
		return 1
	
	proc/CanBuildFortification()
		if(!is_active) return 0
		if(!owner_key) return 0
		return 1
	
	proc/GetDefenseRating()
		return defense_rating
	
	proc/UpdateDefenseRating()
		src.defense_rating = length(src.towers) * 5 + length(src.walls) * 2
		if(length(src.gates) > 0) src.defense_rating += 10

// Fortification System
/obj/fortification
	var
		fort_type = "wall"
		territory_owner = null
		durability = 100
		max_durability = 100
		is_destroyed = 0
		faction_id = 0
	
	New()
		..()
		icon = 'dmi/vill.dmi'
		icon_state = "building2"
		density = 1
		name = "fortification"
		desc = "A defensive structure. Click to view status."

/obj/fortification/wall
	name = "Stone Wall"
	fort_type = "wall"
	max_durability = 50
	
	New()
		..()
		durability = max_durability
		icon_state = "building1"

/obj/fortification/tower
	name = "Guard Tower"
	fort_type = "tower"
	max_durability = 100
	
	New()
		..()
		durability = max_durability
		icon_state = "building3"
	
	proc/CanRaid()
		if(durability <= 0) return 1
		return 0

/obj/fortification/gate
	name = "Territory Gate"
	fort_type = "gate"
	max_durability = 75
	
	New()
		..()
		durability = max_durability
		icon_state = "building4"

// Raiding System
/proc/InitiateRaid(mob/attacker, datum/territory_claim/target_claim)
	if(!attacker || !target_claim) return 0
	if(!target_claim.is_active) return 0
	
	// Verify attacker can raid (gear check, etc.)
	if(!CanRaid(attacker))
		attacker << "You lack the power to raid this territory"
		return 0
	
	var/defense = target_claim.GetDefenseRating()
	var/attack_power = GetAttackPower(attacker)
	
	// Simple raid roll: attacker vs defense
	if(attack_power > defense)
		return ExecuteRaid(attacker, target_claim, attack_power)
	else
		attacker << "Defense is too strong. Raid failed."
		return 0

/proc/CanRaid(mob/attacker)
	if(!attacker) return 0
	if(!istype(attacker, /mob/players)) return 0
	
	// Check minimum requirements for raiding
	var/mob/players/P = attacker
	
	// Must have adequate stamina to attempt raid
	if(P.stamina < 50) return 0
	
	// Future: Add faction standing and equipment checks
	// if(P.character.faction_standing < 0) return 0  // Neutral or hostile to system
	// if(!HasRaidWeapon(P)) return 0  // Must have combat weapon
	
	return 1

/proc/GetAttackPower(mob/attacker)
	if(!istype(attacker, /mob/players)) return 0
	
	var/mob/players/P = attacker
	var/power = 10  // Base power
	
	// Add combat contribution from equipment (future)
	// var/weapon = P.Wequipped  // Get equipped weapon
	// if(weapon) power += weapon.damage
	
	// Add combat progression if system available
	if(global.player_combat_level[P.ckey])
		power += global.player_combat_level[P.ckey] * 5
	
	// Add stamina contribution (higher stamina = more aggressive)
	power += (P.stamina / 300) * 10  // Up to 10 extra from stamina
	
	return power

/proc/ExecuteRaid(mob/attacker, datum/territory_claim/target_claim, attack_power)
	if(!target_claim) return 0
	
	var/mob/owner = null
	for(var/mob/players/P in world)
		if(P.key == target_claim.owner_key)
			owner = P
			break
	
	// Alert owner
	if(owner)
		owner << "Your territory [target_claim.claim_id] is under attack!"
	
	// Damage fortifications
	for(var/obj/fortification/F in target_claim.walls)
		F.durability -= rand(5, 15)
		if(F.durability <= 0)
			F.is_destroyed = 1
			del F
	
	// Grant raid XP
	GrantCombatXP(attacker, 50)
	
	attacker << "Raid successful! Resources extracted."
	
	if(owner)
		owner << "Territory raided! Resources lost."
	
	return 1

// Combat XP System
/proc/GrantCombatXP(mob/player, xp_amount)
	if(!player) return
	
	var/current_xp = global.player_combat_xp[player.key] || 0
	var/current_level = global.player_combat_level[player.key] || 1
	
	current_xp += xp_amount
	
	// Level up at 500 XP per level
	while(current_xp >= 500)
		current_level++
		current_xp -= 500
		
		if(player)
			player << "COMBAT Combat Level [current_level] Reached!"
	
	global.player_combat_xp[player.key] = current_xp
	global.player_combat_level[player.key] = current_level

/proc/GetCombatLevel(mob/player)
	if(!player) return 1
	return global.player_combat_level[player.key] || 1

/proc/GetCombatXP(mob/player)
	if(!player) return 0
	return global.player_combat_xp[player.key] || 0

// Dynamic Events
/datum/pvp_event
	var
		event_id = null
		event_type = "resource_surge"  // Types: resource_surge, monster_invasion, territory_earthquake, faction_war
		location_x = 0
		location_y = 0
		location_z = 0
		active = 1
		reward = 100
		difficulty = 1
		participants = list()
		
		start_time = 0
		end_time = 0

/proc/PvPEventLoop()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(300)  // Every 30 seconds (10 ticks * 3)
		
		// 10% chance of event per loop
		if(prob(10))
			GeneratePvPEvent()

/proc/GeneratePvPEvent()
	var/event_types = list("resource_surge", "monster_invasion", "territory_earthquake", "faction_war")
	var/event_type = pick(event_types)
	
	var/datum/pvp_event/new_event = new()
	new_event.event_id = "[event_type]_[world.timeofday]"
	new_event.event_type = event_type
	new_event.location_x = rand(1, 100)
	new_event.location_y = rand(1, 100)
	new_event.location_z = 1
	new_event.start_time = world.timeofday
	new_event.reward = rand(50, 200)
	new_event.difficulty = rand(1, 5)
	
	global.active_pvp_events[new_event.event_id] = new_event
	global.event_history += new_event.event_id
	
	// Announce event to all players on PvP continent
	for(var/mob/players/P in world)
		if(P && P.current_continent == "pvp")
			P << "PVP [event_type] event at ([new_event.location_x], [new_event.location_y])! Difficulty: [new_event.difficulty]"

/proc/ResolveEvents()
	for(var/event_id in global.active_pvp_events)
		var/datum/pvp_event/E = global.active_pvp_events[event_id]
		if(!E) continue
		
		// Expire events after 5 minutes
		if(world.timeofday - E.start_time > 300)
			E.active = 0
			global.active_pvp_events -= event_id

// ============================================================================
// RAID SYSTEM - Integration with CombatSystem (Phase 10)
// ============================================================================
// NOTE: CanRaid and GetAttackPower already exist above.
// These functions have been enhanced to use the unified CombatSystem.
// ExecuteRaid now delegates to ResolveAttack for combat resolution.

/proc/ResolveRaidCombat(mob/players/attacker, mob/owner)
	/**
	 * Unified raid combat resolution using CombatSystem
	 * 
	 * @param attacker: Raiding player
	 * @param owner: Defending owner
	 * @return: TRUE if raid succeeds, FALSE if raid fails
	 */
	
	// Use unified combat system
	return ResolveAttack(attacker, owner, "raid")

/proc/LogRaidEvent(attacker_key, defender_key, result)
	/**
	 * Log raid event to analytics
	 * 
	 * @param attacker_key: Raider's key
	 * @param defender_key: Defender's key
	 * @param result: "success" or "failure"
	 */
	
	LogCombatEventToAnalytics(
		attacker_key,
		defender_key,
		0,
		"raid",
		CONT_PVP,
		result == "success" ? "kill" : "miss"
	)
	
	// Also track in raid history
	if(!global.raid_history)
		global.raid_history = list()
	
	global.raid_history += list(list(
		"timestamp" = world.time,
		"attacker" = attacker_key,
		"defender" = defender_key,
		"result" = result
	))

// Testing
/proc/TestPvPSystem()
	world << "PVP Test: PvP System Loaded"
	world << "PVP Territories: [global.pvp_territories.len]"
	world << "PVP Events: [global.active_pvp_events.len]"
	world << "PVP Test Complete"

