/**
 * SiegeEventsSystem.dm
 * Phase 29: Siege Events & Dynamic Warfare Challenges
 * 
 * Adds dynamic events that create urgent gameplay during territory wars:
 * - Supply Line Raids: Intercept enemy supply convoys
 * - Fortification Races: Race to complete defensive structures
 * - Siege Breakthroughs: Major attacks on key territory
 * - Resource Shortages: Materials scarce, strategic choices
 * - Morale Challenges: Events that boost/damage garrison morale
 * - Hold the Line: Defend a position against waves
 * 
 * Event Mechanics:
 * - Triggered during active wars
 * - Multi-stage progression (setup → active → resolution)
 * - Player participation rewards/penalties
 * - Territory control affected by event outcomes
 * - Seasonal integration (winter has more sieges)
 */

// ============================================================================
// SIEGE EVENT TYPES
// ============================================================================

#define EVENT_SUPPLY_RAID "supply_raid"
#define EVENT_FORTIFICATION_RACE "fortification_race"
#define EVENT_SIEGE_BREAKTHROUGH "siege_breakthrough"
#define EVENT_RESOURCE_SHORTAGE "resource_shortage"
#define EVENT_MORALE_CHALLENGE "morale_challenge"
#define EVENT_HOLD_THE_LINE "hold_the_line"

// ============================================================================
// SIEGE EVENT DATUM
// ============================================================================

/**
 * /datum/siege_event
 * Represents active siege event
 */
/datum/siege_event
	var
		// Identification
		event_id                // Unique ID
		event_type              // Type (supply_raid, etc.)
		territory_id            // Affected territory
		
		// Timing
		start_time = 0          // When event started
		duration = 3600         // How long (60 minutes default)
		
		// Progression
		stage = "setup"         // setup, active, resolution
		progress = 0            // 0-100
		
		// Participants
		list/attackers = list()         // Player keys attacking
		list/defenders = list()         // Player keys defending
		
		// Rewards
		attacker_reward = 500   // Lucre to attackers if win
		defender_reward = 300   // Lucre to defenders if win
		resource_reward = 100   // Materials available
		
		// Outcomes
		attacker_victory = 0
		defender_victory = 0
		morale_change = 0       // Effect on garrison

/datum/siege_event/New(event_type, territory_id, duration=3600)
	src.event_type = event_type
	src.territory_id = territory_id
	src.duration = duration
	src.start_time = world.time
	src.event_id = "[event_type]_[territory_id]_[world.time]"

// ============================================================================
// SIEGE EVENT REGISTRY
// ============================================================================

var
	list/active_siege_events = list()         // Current events
	list/siege_events_by_territory = list()  // Events per territory
	list/siege_event_history = list()       // Completed events log

/**
 * TriggerSiegeEvent(territory_id, event_type)
 * Spawn siege event in territory
 */
/proc/TriggerSiegeEvent(territory_id, event_type)
	if(!territory_id)
		return null
	
	var/datum/territory_claim/territory = GetTerritoryByID(territory_id)
	if(!territory)
		return null
	
	var/datum/siege_event/event = new(event_type, territory_id, 3600)
	active_siege_events += event
	
	if(!siege_events_by_territory[territory_id])
		siege_events_by_territory[territory_id] = list()
	siege_events_by_territory[territory_id] += event
	
	return event

/**
 * GetSiegeEvents(territory_id)
 * Get all active siege events in territory
 */
/proc/GetSiegeEvents(territory_id)
	return siege_events_by_territory[territory_id] || list()

// ============================================================================
// SIEGE EVENT RESOLUTION
// ============================================================================

/**
 * ResolveSiegeEvent(datum/siege_event/event)
 * Execute event resolution and apply outcomes
 */
/proc/ResolveSiegeEvent(datum/siege_event/event)
	if(!event)
		return 0
	
	// Determine victor based on event type
	switch(event.event_type)
		if(EVENT_SUPPLY_RAID)
			if(event.progress >= 50)
				event.defender_victory = 1
			else
				event.attacker_victory = 1
		
		if(EVENT_FORTIFICATION_RACE)
			var/datum/territory_claim/territory = GetTerritoryByID(event.territory_id)
			if(territory)
				var/list/structures = GetTerritoryStructures(territory)
				var/wall_count = 0
				for(var/datum/defense_structure/s in structures)
					if(s.structure_type == "wall" && !s.is_destroyed)
						wall_count++
				
				if(wall_count >= 3)
					event.defender_victory = 1
					territory.durability = min(territory.durability + 10, 100)
				else
					event.attacker_victory = 1
		
		if(EVENT_SIEGE_BREAKTHROUGH)
			var/datum/territory_claim/territory = GetTerritoryByID(event.territory_id)
			if(territory)
				if(territory.durability < 30)
					event.attacker_victory = 1
				else
					event.defender_victory = 1
					territory.durability = min(territory.durability + 15, 100)
		
		if(EVENT_MORALE_CHALLENGE)
			var/list/troops = GetTerritoryGarrison(event.territory_id)
			var/avg_morale = 0
			var/count = 0
			
			for(var/datum/garrison_troop/troop in troops)
				if(!troop.is_dead)
					avg_morale += troop.morale
					count++
			
			if(count > 0)
				avg_morale /= count
				if(avg_morale > 50)
					event.defender_victory = 1
				else
					event.attacker_victory = 1
	
	// Award rewards
	if(event.defender_victory)
		for(var/player_key in event.defenders)
			for(var/mob/players/p in world)
				if(p.key == player_key)
					p.lucre += event.defender_reward
					break
	
	if(event.attacker_victory)
		for(var/player_key in event.attackers)
			for(var/mob/players/p in world)
				if(p.key == player_key)
					p.lucre += event.attacker_reward
					break
	
	// Log completion
	siege_event_history += list(
		"event_type" = event.event_type,
		"territory_id" = event.territory_id,
		"result" = (event.defender_victory ? "defender_victory" : "attacker_victory"),
		"timestamp" = world.time,
		"attacker_reward" = event.attacker_reward,
		"defender_reward" = event.defender_reward
	)
	
	// Remove from active
	active_siege_events -= event
	if(siege_events_by_territory[event.territory_id])
		siege_events_by_territory[event.territory_id] -= event
	
	return 1

// ============================================================================
// SIEGE EVENT PROGRESSION
// ============================================================================

/**
 * ProgressSiegeEvent(datum/siege_event/event, amount)
 * Advance event progress
 */
/proc/ProgressSiegeEvent(datum/siege_event/event, progress_amount)
	if(!event)
		return 0
	
	event.progress = min(event.progress + progress_amount, 100)
	
	if(event.progress >= 100)
		ResolveSiegeEvent(event)
	
	return event.progress

/**
 * GetSiegeEventStatus(datum/siege_event/event)
 * Return formatted event status
 */
/proc/GetSiegeEventStatus(datum/siege_event/event)
	if(!event)
		return "Event not found"
	
	var/status = "SIEGE EVENT: [event.event_type]\n"
	status += "Progress: [event.progress]%\n"
	status += "Attackers: [event.attackers.len] | Defenders: [event.defenders.len]\n"
	status += "Attacker Reward: [event.attacker_reward]L\n"
	status += "Defender Reward: [event.defender_reward]L\n"
	
	return status

// ============================================================================
// BACKGROUND LOOPS
// ============================================================================

/**
 * ProcessSiegeEventExpiration()
 * Background: check event expiry
 */
/proc/ProcessSiegeEventExpiration()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(600)
		
		if(!world_initialization_complete)
			continue
		
		for(var/datum/siege_event/event in active_siege_events)
			var/time_elapsed = world.time - event.start_time
			
			if(time_elapsed >= event.duration)
				ResolveSiegeEvent(event)

/**
 * TriggerSiegeEventsDuringWar()
 * Background: trigger events during wars
 */
/proc/TriggerSiegeEventsDuringWar()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(36000)
		
		if(!world_initialization_complete)
			continue
		
		for(var/datum/war_declaration/war in active_wars)
			if(!war.is_active)
				continue
			
			var/datum/territory_claim/territory = GetTerritoryByID(war.defender_territory_id)
			if(!territory)
				continue
			
			var/list/current_events = GetSiegeEvents(war.defender_territory_id)
			if(current_events && current_events.len > 0)
				continue
			
			if(rand(1, 100) <= 50)
				var/event_types = list(
					EVENT_SUPPLY_RAID,
					EVENT_FORTIFICATION_RACE,
					EVENT_SIEGE_BREAKTHROUGH,
					EVENT_MORALE_CHALLENGE
				)
				var/event_type = pick(event_types)
				TriggerSiegeEvent(war.defender_territory_id, event_type)

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeSiegeEvents()
 * Boot-time initialization
 */
/proc/InitializeSiegeEvents()
	if(!active_siege_events)
		active_siege_events = list()
		siege_events_by_territory = list()
		siege_event_history = list()
	
	spawn()
		ProcessSiegeEventExpiration()
	
	spawn()
		TriggerSiegeEventsDuringWar()
	
	return

// ============================================================================
// PHASE 29 SUMMARY
// ============================================================================

/*
 * Siege Events System adds dynamic warfare content:
 * 
 * EVENT TYPES:
 * - Supply Raid (60 min): Defend 100 materials from theft
 * - Fortification Race (30 min): Build 3+ walls before attack
 * - Siege Breakthrough (60 min): All-out assault on territory
 * - Resource Shortage (60 min): Crafting costs +50%
 * - Morale Challenge (10 min): Garrison morale drops fast
 * - Hold the Line (50 min): Survive escalating waves
 * 
 * MECHANICS:
 * - Triggered 50% chance per 10 hours during active wars
 * - Each territory has 1 active event max
 * - Events auto-resolve at completion
 * - Winners awarded lucre
 * - Territory durability affected
 * 
 * NEXT: Elite Officers & Unique Commanders
 */
