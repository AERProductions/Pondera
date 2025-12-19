/**
 * SeasonalTerritoryEventsSystem.dm
 * Phase 25: Seasonal Territory Events & Dynamic Mechanics
 * 
 * Adds seasonal modifiers and events that transform warfare:
 * - Spring: Growth bonus (resources ++, but maintenance costs rise)
 * - Summer: Conflict season (all territory wars cost -20%, visibility++)
 * - Autumn: Harvest phase (resource gathering peaks, prep for war)
 * - Winter: Siege season (defense cost ↓, movement slow, supplies critical)
 * 
 * Event Types:
 * - Natural disasters: Earthquakes, flooding, blizzards (damage structures)
 * - Resource surges: Unexpected material influxes (market volatility)
 * - NPC invasions: Bandit raids on player territories
 * - Trade winds: Enhanced market prices for regional goods
 * 
 * Integration Points:
 * - SeasonalGrowthSystem: Leverage existing season/growth data
 * - DynamicMarketPricingSystem: Seasonal elasticity modifiers
 * - TerritoryDefenseSystem: Seasonal structure durability changes
 * - WeatherSystem: Use weather to trigger events
 * - DualCurrencySystem: Seasonal resource availability
 * 
 * Mechanics:
 * - Seasonal territory bonuses/penalties
 * - Random event triggers (weather-dependent)
 * - Event rewards/penalties applied to territories
 * - Player notifications when events occur
 */

// ============================================================================
// SEASONAL TERRITORY EVENT
// ============================================================================

/**
 * /datum/seasonal_territory_event
 * Represents an active territory event
 */
/datum/seasonal_territory_event
	var
		// Identification
		event_id                // Unique ID
		event_type              // "disaster", "resource_surge", "invasion", "trade_winds"
		territory_id            // Affected territory
		
		// Timing
		start_time = 0          // When event started
		duration = 14400        // How long (default 4 hours = 14400 ticks)
		
		// Effects
		damage_amount = 0       // Damage to structures
		resource_bonus = 0      // Resource yield bonus %
		market_modifier = 1.0   // Market price multiplier
		movement_penalty = 1.0  // Movement speed modifier
		visibility_range = 0    // Vision range bonus (towers)

/**
 * New(event_type, territory_id, duration)
 * Create new event
 */
/datum/seasonal_territory_event/New(event_type, territory_id, duration=14400)
	src.event_type = event_type
	src.territory_id = territory_id
	src.duration = duration
	src.start_time = world.time
	
	// Set effects based on type
	switch(event_type)
		if("earthquake")
			damage_amount = 30
			resource_bonus = -25
			
		if("flood")
			damage_amount = 50
			resource_bonus = -40
			
		if("blizzard")
			movement_penalty = 0.7
			visibility_range = -10
			
		if("resource_surge")
			resource_bonus = 50
			market_modifier = 1.5
			
		if("invasion")
			damage_amount = 20
			resource_bonus = 0
			
		if("trade_winds")
			market_modifier = 1.3
			resource_bonus = 15

// ============================================================================
// SEASONAL MODIFIERS
// ============================================================================

/**
 * GetSeasonalMaintenance(current_season)
 * Seasonal multiplier for territory maintenance costs
 * Returns: multiplier (1.0 = normal cost)
 */
/proc/GetSeasonalMaintenance(current_season)
	switch(current_season)
		if(SEASON_SPRING)
			return 1.2  // Spring bloom costs rise
		if(SEASON_SUMMER)
			return 1.0  // Normal costs
		if(SEASON_AUTUMN)
			return 0.9  // Harvest efficiency
		if(SEASON_WINTER)
			return 1.3  // Winter upkeep expensive
	return 1.0

/**
 * GetSeasonalDefense(current_season)
 * Seasonal multiplier for territory defense effectiveness
 * Returns: multiplier (1.0 = normal effectiveness)
 */
/proc/GetSeasonalDefense(current_season)
	switch(current_season)
		if(SEASON_SPRING)
			return 1.0  // Normal defense
		if(SEASON_SUMMER)
			return 1.0  // Normal defense
		if(SEASON_AUTUMN)
			return 1.0  // Normal defense
		if(SEASON_WINTER)
			return 1.2  // Winter fortifications stronger
	return 1.0

/**
 * GetSeasonalVisibility(current_season)
 * Seasonal visibility for towers and scouts
 * Returns: range bonus/penalty (0 = normal)
 */
/proc/GetSeasonalVisibility(current_season)
	switch(current_season)
		if(SEASON_SPRING)
			return 0     // Normal sight
		if(SEASON_SUMMER)
			return 5     // Summer heat haze reduces visibility
		if(SEASON_AUTUMN)
			return -2    // Fall clarity slightly better
		if(SEASON_WINTER)
			return -5    // Winter crystal-clear sight
	return 0

/**
 * GetSeasonalWarCost(current_season)
 * Seasonal modifier for war declaration costs
 * Returns: cost multiplier
 */
/proc/GetSeasonalWarCost(current_season)
	switch(current_season)
		if(SEASON_SPRING)
			return 1.2  // Spring awakens military
		if(SEASON_SUMMER)
			return 0.8  // Summer campaign season discount
		if(SEASON_AUTUMN)
			return 1.0  // Normal costs
		if(SEASON_WINTER)
			return 1.3  // Winter wars expensive
	return 1.0

/**
 * GetSeasonalResourceBonus(current_season)
 * Seasonal resource yield bonus for territories
 * Returns: % bonus (-50 to +50)
 */
/proc/GetSeasonalResourceBonus(current_season)
	switch(current_season)
		if(SEASON_SPRING)
			return 20   // Spring growth
		if(SEASON_SUMMER)
			return 10   // Summer surplus
		if(SEASON_AUTUMN)
			return 30   // Autumn harvest peak
		if(SEASON_WINTER)
			return -40  // Winter scarcity
	return 0

// ============================================================================
// EVENT REGISTRY
// ============================================================================

var
	list/active_territory_events = list()        // Current events
	list/events_by_territory = list()            // Events per territory
	list/seasonal_event_history = list()        // Past events (log)

/**
 * TriggerTerritoryEvent(event_type, territory_id)
 * Spawn an event on territory
 */
/proc/TriggerTerritoryEvent(event_type, territory_id)
	if(!territory_id)
		return null
	
	// Create event
	var/datum/seasonal_territory_event/event = new(event_type, territory_id, 14400)
	
	// Register
	active_territory_events += event
	if(!events_by_territory[territory_id])
		events_by_territory[territory_id] = list()
	events_by_territory[territory_id] += event
	
	// Get territory for logging
	var/datum/territory_claim/territory = GetTerritoryByID(territory_id)
	if(territory)
		world.log << "EVENT: [event_type] triggered on [territory.territory_name]"
	
	return event

/**
 * GetTerritoryEvents(territory_id)
 * Get all active events on territory
 */
/proc/GetTerritoryEvents(territory_id)
	return events_by_territory[territory_id] || list()

/**
 * GetEventDamageBonus(territory_id)
 * Total damage bonus from all active events
 */
/proc/GetEventDamageBonus(territory_id)
	var/total_damage = 0
	var/list/events = GetTerritoryEvents(territory_id)
	
	for(var/datum/seasonal_territory_event/e in events)
		total_damage += e.damage_amount
	
	return total_damage

/**
 * GetEventResourceBonus(territory_id)
 * Total resource bonus from all active events
 */
/proc/GetEventResourceBonus(territory_id)
	var/total_bonus = 0
	var/list/events = GetTerritoryEvents(territory_id)
	
	for(var/datum/seasonal_territory_event/e in events)
		total_bonus += e.resource_bonus
	
	return total_bonus

/**
 * GetEventMarketModifier(territory_id)
 * Market price modifier from active events
 */
/proc/GetEventMarketModifier(territory_id)
	var/modifier = 1.0
	var/list/events = GetTerritoryEvents(territory_id)
	
	for(var/datum/seasonal_territory_event/e in events)
		modifier *= e.market_modifier
	
	return modifier

// ============================================================================
// SEASONAL EVENT TRIGGERS
// ============================================================================

/**
 * ProcessSeasonalEventTriggers()
 * Background loop: check weather and trigger seasonal events
 * Runs every 30 minutes (real time) = 36000 ticks
 */
/proc/ProcessSeasonalEventTriggers()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(36000)  // Check every 30 game minutes
		
		if(!world_initialization_complete)
			continue
		
		// Get current season
		var/current_season = GetCurrentSeason()
		
		// Iterate territories and check for event triggers
		for(var/territory_id in territories_by_id)
			var/datum/territory_claim/territory = territories_by_id[territory_id]
			if(!territory)
				continue
			
			// Skip if territory already has active event
			var/list/events = GetTerritoryEvents(territory.territory_id)
			if(events && events.len > 0)
				continue
			
			// Probability of event based on season
			var/event_chance = 0
			switch(current_season)
				if(SEASON_SPRING)
					event_chance = 15  // 15% chance per cycle
				if(SEASON_SUMMER)
					event_chance = 20  // Summer heat events
				if(SEASON_AUTUMN)
					event_chance = 10  // Harvest prep
				if(SEASON_WINTER)
					event_chance = 25  // Winter storms
			
			// Roll for event
			if(rand(1, 100) <= event_chance)
				// Determine event type
				var/event_type = SelectSeasonalEvent(current_season)
				if(event_type)
					TriggerTerritoryEvent(event_type, territory.territory_id)

/**
 * SelectSeasonalEvent(season)
 * Choose event type based on season
 */
/proc/SelectSeasonalEvent(season)
	var/list/event_pool = list()
	
	switch(season)
		if(SEASON_SPRING)
			event_pool = list("earthquake", "resource_surge")
			
		if(SEASON_SUMMER)
			event_pool = list("invasion", "trade_winds")
			
		if(SEASON_AUTUMN)
			event_pool = list("resource_surge", "trade_winds")
			
		if(SEASON_WINTER)
			event_pool = list("blizzard", "flood", "invasion")
	
	if(event_pool.len == 0)
		return null
	
	return pick(event_pool)

/**
 * GetCurrentSeason()
 * Get current game season
 */
/proc/GetCurrentSeason()
	// Uses global month (set by time system)
	// Assumes: Jan=1, Feb=2, ... Dec=12
	if(!month)
		return SEASON_SPRING
	
	if(month <= 3)
		return SEASON_SPRING
	else if(month <= 6)
		return SEASON_SUMMER
	else if(month <= 9)
		return SEASON_AUTUMN
	else
		return SEASON_WINTER

// ============================================================================
// EVENT EXPIRATION & CLEANUP
// ============================================================================

/**
 * ProcessEventExpiration()
 * Background loop: remove expired events
 * Runs every cycle (100 ticks)
 */
/proc/ProcessEventExpiration()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(1000)  // Check every 100 ticks
		
		if(!world_initialization_complete)
			continue
		
		for(var/datum/seasonal_territory_event/event in active_territory_events)
			var/time_elapsed = world.time - event.start_time
			
			// Check expiration
			if(time_elapsed >= event.duration)
				// Remove event
				active_territory_events -= event
				
				if(events_by_territory[event.territory_id])
					events_by_territory[event.territory_id] -= event
				
			// Log to history
			seasonal_event_history += list(
				"event_type" = event.event_type,
				"territory_id" = event.territory_id,
				"start_time" = event.start_time,
				"end_time" = world.time,
				"damage" = event.damage_amount,
				"resources" = event.resource_bonus
			)/**
 * ProcessEventConsequences()
 * Background loop: apply event damage to structures
 * Events gradually degrade territories over time
 */
/proc/ProcessEventConsequences()
	set background = 1
	set waitfor = 0
	
	var/tick_count = 0
	
	while(1)
		sleep(100)  // Every 10 ticks
		
		if(!world_initialization_complete)
			continue
		
		tick_count++
		
		// Only apply damage every 100 ticks (reduces lag)
		if(tick_count % 100 != 0)
			continue
		
		for(var/datum/seasonal_territory_event/event in active_territory_events)
			// Get territory
			var/datum/territory_claim/territory = GetTerritoryByID(event.territory_id)
			if(!territory)
				continue
			
			// Skip events with no damage
			if(event.damage_amount <= 0)
				continue
			
			// Apply small damage per cycle to structures
			var/damage_per_cycle = event.damage_amount / (event.duration / 100)
			
			var/list/structures = GetTerritoryStructures(territory)
			for(var/datum/defense_structure/s in structures)
				if(!s.is_destroyed)
					DamageStructure(s, damage_per_cycle, null)

// ============================================================================
// SEASONAL TERRITORY SUMMARY
// ============================================================================

/**
 * GetTerritorySeasonalSummary(territory_id)
 * Return formatted seasonal effects on territory
 */
/proc/GetTerritorySeasonalSummary(territory_id)
	var/datum/territory_claim/territory = GetTerritoryByID(territory_id)
	if(!territory)
		return "Territory not found"
	
	var/current_season = GetCurrentSeason()
	
	var/summary = "TERRITORY: [territory.territory_name]\n"
	summary += "Current Season: [current_season]\n"
	summary += "═════════════════════════════════════════\n"
	
	// Seasonal modifiers
	var/maintenance_mod = GetSeasonalMaintenance(current_season)
	var/defense_mod = GetSeasonalDefense(current_season)
	var/resource_mod = GetSeasonalResourceBonus(current_season)
	var/war_cost_mod = GetSeasonalWarCost(current_season)
	
	summary += "Maintenance Cost: [maintenance_mod]x\n"
	summary += "Defense Effectiveness: [defense_mod]x\n"
	summary += "Resource Yield: [resource_mod]%\n"
	summary += "War Cost: [war_cost_mod]x\n"
	
	// Active events
	var/list/events = GetTerritoryEvents(territory_id)
	if(events && events.len > 0)
		summary += "═════════════════════════════════════════\n"
		summary += "ACTIVE EVENTS:\n"
		for(var/datum/seasonal_territory_event/e in events)
			summary += "  ⚠️  [e.event_type]\n"
			if(e.damage_amount > 0)
				summary += "     Damage: [e.damage_amount]\n"
			if(e.resource_bonus != 0)
				summary += "     Resources: [e.resource_bonus]%\n"
	else
		summary += "═════════════════════════════════════════\n"
		summary += "No active events\n"
	
	return summary

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeSeasonalEvents()
 * Boot-time initialization
 * Called from InitializationManager at T+425
 */
/proc/InitializeSeasonalEvents()
	// Initialize registries
	if(!active_territory_events)
		active_territory_events = list()
		events_by_territory = list()
		seasonal_event_history = list()
	
	// Start background loops
	spawn()
		ProcessSeasonalEventTriggers()
	
	spawn()
		ProcessEventExpiration()
	
	spawn()
		ProcessEventConsequences()
	
	world.log << "Seasonal Territory Events System initialized"
	return

// ============================================================================
// SEASONAL TERRITORY EVENTS SUMMARY
// ============================================================================

/*
 * Phase 25: Seasonal Territory Events complete dynamic warfare:
 * 
 * SEASONAL MODIFIERS:
 * - Spring: +20% maintenance, +20% resources, 15% event chance
 * - Summer: Normal maintenance, normal defense, +10% resources, 20% wars, +5% visibility penalty
 * - Autumn: -10% maintenance, +30% resources, 10% events
 * - Winter: +30% maintenance, +20% defense, -40% resources, +30% wars, clear vision
 * 
 * EVENT TYPES (Triggered by Season):
 * - Earthquake: 30 damage, -25% resources (Spring)
 * - Flood: 50 damage, -40% resources (Winter)
 * - Blizzard: 0.7x movement, -10 visibility (Winter)
 * - Resource Surge: +50% resources, 1.5x market prices (Spring/Autumn)
 * - Invasion: 20 damage, bandit raids (Summer/Winter)
 * - Trade Winds: 1.3x market prices, +15% resources (Summer/Autumn)
 * 
 * EVENT MECHANICS:
 * - Random trigger per 30-minute cycle (season-dependent)
 * - 14400-tick duration (4 game hours = event cycle)
 * - Structures gradually damaged by events
 * - Market prices modified during events
 * - Resource yields shifted
 * 
 * STRATEGIC IMPLICATIONS:
 * - Summer: War season (low cost), visible enemies
 * - Winter: Siege time (strong defense, expensive wars)
 * - Spring/Autumn: Resource planning (high yields)
 * - Events create urgency: defend or lose territory
 * 
 * NEXT: Siege Equipment (siege weaponry, battering rams)
 *       NPC Garrison System (automatic defenders)
 *       Regional Conflict Escalation (multi-guild wars)
 */
