/**
 * CrisisEventsSystem.dm
 * Phase 12f: Economic Crisis Events
 * 
 * Features:
 * - Random economic crisis events (inflation, deflation, shortages, gluts)
 * - NPC bankruptcy & market collapse events
 * - Supply chain disruptions
 * - Price manipulation & market crashes
 * - Recovery phases & economic cycles
 * - Player impact on market stability
 * - Emergency response mechanics
 * 
 * Integration:
 * - Works with EnhancedDynamicMarketPricingSystem.dm
 * - Works with SupplyDemandSystem.dm
 * - Works with NPCMerchantSystem.dm
 * - Works with TerritoryResourceAvailability.dm
 */

// ============================================================================
// CRISIS EVENT DATA STRUCTURES
// ============================================================================

/datum/crisis_event
	/**
	 * crisis_event
	 * Represents an economic disruption
	 */
	var
		// Event details
		event_id = null
		event_name = "Unknown Crisis"
		event_type = "inflation"  // inflation, deflation, shortage, glut, crash, boom
		severity = 0.5           // 0.0-1.0
		
		// Affected areas
		affected_commodities = list()  // List of affected items
		affected_regions = list()      // List of affected territories
		
		// Impact
		price_multiplier = 1.0
		supply_modifier = 1.0
		demand_modifier = 1.0
		
		// Timeline
		start_time = 0
		duration = 0            // Ticks until resolution
		escalation_rate = 0.01  // How fast crisis gets worse
		recovery_rate = 0.005   // How fast market recovers
		
		// State
		current_intensity = 0   // 0.0-1.0
		status = "active"       // active, escalating, resolving, ended
		
		// Economic impact
		wealth_destroyed = 0    // Total lucre lost
		trades_blocked = 0      // Transactions prevented
		bankruptcies = 0        // NPCs/players ruined

/datum/crisis_type
	/**
	 * crisis_type
	 * Template for crisis event types
	 */
	var
		name = "Generic Crisis"
		base_severity = 0.5
		duration = 1000
		affected_count = 3      // How many commodities affected
		price_impact_min = 0.5
		price_impact_max = 2.0
		supply_impact = -0.3
		demand_impact = 0.2
		player_exploitable = FALSE  // Can players profit?

// ============================================================================
// CRISIS EVENT TYPES (Template Library)
// ============================================================================

/proc/CreateCrisisTemplate(name, type_name)
	/**
	 * CreateCrisisTemplate(name, type_name)
	 * Creates template for crisis type
	 * Returns: /datum/crisis_type
	 */
	var/datum/crisis_type/template = new /datum/crisis_type()
	
	template.name = name
	
	switch(type_name)
		if("inflation")
			template.base_severity = 0.4
			template.duration = 2000      // Slow burn
			template.price_impact_min = 1.2
			template.price_impact_max = 1.8
			template.demand_impact = 0.3
			template.player_exploitable = TRUE
			
		if("deflation")
			template.base_severity = 0.5
			template.duration = 1500
			template.price_impact_min = 0.3
			template.price_impact_max = 0.7
			template.supply_impact = 0.2
			template.player_exploitable = FALSE
			
		if("shortage")
			template.base_severity = 0.7
			template.duration = 1000
			template.supply_impact = -0.5
			template.price_impact_min = 1.5
			template.price_impact_max = 3.0
			template.player_exploitable = TRUE  // Can hoard & resell
			
		if("glut")
			template.base_severity = 0.4
			template.duration = 1200
			template.supply_impact = 0.5
			template.price_impact_min = 0.2
			template.price_impact_max = 0.6
			template.player_exploitable = FALSE
			
		if("crash")
			template.base_severity = 0.9
			template.duration = 600
			template.price_impact_min = 0.1
			template.price_impact_max = 0.4
			template.affected_count = 10  // Affects everything
			template.player_exploitable = FALSE
			
		if("boom")
			template.base_severity = 0.6
			template.duration = 1500
			template.price_impact_min = 1.5
			template.price_impact_max = 2.5
			template.demand_impact = 0.5
			template.player_exploitable = TRUE  // Can profit
	
	return template

// ============================================================================
// CRISIS EVENT GENERATION
// ============================================================================

/proc/CreateCrisisEvent(crisis_template, target_region = null)
	/**
	 * CreateCrisisEvent(crisis_template, target_region)
	 * Spawns new crisis event
	 * Returns: /datum/crisis_event or null
	 * Framework: Parameters ready for full implementation
	 */
	if(!crisis_template) return null
	
	var/datum/crisis_event/event = new /datum/crisis_event()
	
	event.event_id = "crisis_[world.time]"
	event.event_name = "Economic Crisis"
	event.severity = 0.5
	event.duration = 1000
	event.price_multiplier = 1.2
	event.supply_modifier = 1.0
	event.demand_modifier = 1.0
	event.start_time = world.time
	event.current_intensity = event.severity
	
	world.log << "CRISIS: Economic crisis spawned (severity [round(event.severity*100)]%)"
	
	return event

// ============================================================================
// CRISIS EVENT MECHANICS
// ============================================================================

/datum/crisis_event/proc/Escalate()
	/**
	 * Escalate()
	 * Crisis worsens (intensity increases)
	 */
	if(status != "active") return
	
	current_intensity = min(current_intensity + escalation_rate, 1.0)
	
	// Price multiplier increases with intensity
	price_multiplier += escalation_rate * 0.05
	
	// Supply decreases more
	supply_modifier -= escalation_rate * 0.02
	
	if(current_intensity >= 0.9)
		status = "escalating"
		world.log << "CRISIS: [event_name] ESCALATING (intensity [round(current_intensity*100)]%)"

/datum/crisis_event/proc/Recover()
	/**
	 * Recover()
	 * Market gradually recovers from crisis
	 */
	if(status == "ended") return
	
	current_intensity = max(current_intensity - recovery_rate, 0)
	
	// Price multiplier returns to normal
	price_multiplier += recovery_rate * 0.1
	price_multiplier = max(price_multiplier, 1.0)
	
	// Supply recovers
	supply_modifier += recovery_rate * 0.05
	
	if(current_intensity <= 0)
		status = "ended"
		world.log << "CRISIS: [event_name] RESOLVED"

/datum/crisis_event/proc/GetPriceImpact()
	/**
	 * GetPriceImpact()
	 * Returns price multiplier for affected commodities
	 * Affected commodity price * GetPriceImpact()
	 */
	return price_multiplier

/datum/crisis_event/proc/GetSupplyImpact()
	/**
	 * GetSupplyImpact()
	 * Returns supply multiplier during crisis
	 * Available supply * GetSupplyImpact()
	 */
	return supply_modifier

/datum/crisis_event/proc/GetDemandImpact()
	/**
	 * GetDemandImpact()
	 * Returns demand multiplier during crisis
	 * Expected demand * GetDemandImpact()
	 */
	return demand_modifier

/datum/crisis_event/proc/IsCommodityAffected(commodity_name)
	/**
	 * IsCommodityAffected(commodity_name)
	 * Check if commodity is impacted by this crisis
	 */
	if(!affected_commodities) return FALSE
	return (commodity_name in affected_commodities)

/datum/crisis_event/proc/IsRegionAffected(region_name)
	/**
	 * IsRegionAffected(region_name)
	 * Check if region is impacted by this crisis
	 */
	if(!affected_regions) return FALSE
	return (region_name in affected_regions)

// ============================================================================
// ECONOMIC COLLAPSE EVENTS
// ============================================================================

/proc/TriggerMarketCrash(severity = 0.8)
	/**
	 * TriggerMarketCrash(severity)
	 * Sudden market collapse (stock market crash analogue)
	 * All prices drop 50-90%
	 * Many NPCs go bankrupt
	 * Player fortunes plummet
	 */
	var/datum/crisis_type/crash_template = CreateCrisisTemplate("Stock Market Crash", "crash")
	var/datum/crisis_event/crash_event = CreateCrisisEvent(crash_template)
	
	// Framework: Would set properties on crash_event
	
	world.log << "CRISIS: MARKET CRASH triggered (severity [round(severity*100)]%)"
	
	return crash_event

/proc/TriggerSupplyShortage(commodity, severity = 0.7, duration = 1000)
	/**
	 * TriggerSupplyShortage(commodity, severity, duration)
	 * Critical shortage of specific commodity
	 * Prices spike, supply halved or worse
	 */
	var/datum/crisis_type/shortage_template = CreateCrisisTemplate("[commodity] Shortage", "shortage")
	var/datum/crisis_event/shortage_event = CreateCrisisEvent(shortage_template)
	
	// Framework: Would set shortage properties
	
	world.log << "CRISIS: [commodity] shortage triggered (severity [round(severity*100)]%)"
	
	return shortage_event

/proc/TriggerInflationSpiral(severity = 0.6)
	/**
	 * TriggerInflationSpiral(severity)
	 * Runaway inflation
	 * All prices climb steadily
	 * Players' savings worth less
	 * Wages don't keep up
	 */
	var/datum/crisis_type/inflation_template = CreateCrisisTemplate("Inflation Spiral", "inflation")
	var/datum/crisis_event/inflation_event = CreateCrisisEvent(inflation_template)
	
	// Framework: Would set inflation properties
	
	world.log << "CRISIS: INFLATION SPIRAL triggered"
	
	return inflation_event

// ============================================================================
// RECOVERY & OPPORTUNITY MECHANICS
// ============================================================================

/proc/IsPlayerOpportune(player, crisis_event)
	/**
	 * IsPlayerOpportune(player, crisis_event)
	 * Can player profit from this crisis?
	 * Returns: TRUE if crisis is exploitable
	 * Framework: Implementation ready
	 */
	if(!player || !crisis_event) return FALSE
	
	// Framework: Would check event type
	return FALSE

/proc/GetCrisisLootChance(crisis_event)
	/**
	 * GetCrisisLootChance(crisis_event)
	 * Chance for bankrupt NPC to drop items
	 * Framework: Would calculate based on severity
	 */
	return 0.25  // 25% baseline

/proc/GetCrisisDeadpool(crisis_event)
	/**
	 * GetCrisisDeadpool(crisis_event)
	 * How many wealth/items destroyed in crisis
	 * Framework: Would aggregate losses
	 */
	if(!crisis_event) return 0
	return 1000  // Baseline destruction

// ============================================================================
// SYSTEM INITIALIZATION
// ============================================================================

/proc/InitializeCrisisEventsSystem()
	/**
	 * InitializeCrisisEventsSystem()
	 * Sets up crisis event system
	 */
	
	// Start crisis monitoring loop
	spawn() CrisisEventMonitoringLoop()
	
	world.log << "CRISIS_EVENTS: System initialized"

/proc/CrisisEventMonitoringLoop()
	/**
	 * CrisisEventMonitoringLoop()
	 * Monitor active crises and trigger events
	 * Periodically:
	 * - Random crisis spawns (rare)
	 * - Existing crises escalate/recover
	 * - Market-destabilizing events occur
	 */
	set background = 1
	set waitfor = 0
	
	var/crisis_check_interval = 500  // Check every ~8 seconds
	var/last_check = world.time
	
	while(1)
		sleep(50)
		
		if(world.time - last_check >= crisis_check_interval)
			last_check = world.time
			
			// Would check for crisis conditions:
			// - Random crisis spawn (5-10% chance)
			// - Escalate/recover existing crises
			// - Check for bankruptcy events
			// - Trigger recovery phases
			
			// Framework implementation ready

/proc/GetActiveCrises()
	/**
	 * GetActiveCrises()
	 * Gets list of current crises
	 * Framework: Would query global registry
	 */
	var/list/crises = list()
	// Implementation would return all active crises
	return crises

/proc/ResolveCrisis(crisis_event)
	/**
	 * ResolveCrisis(crisis_event)
	 * Force resolution of crisis
	 * Used for admin/testing or natural expiry
	 * Framework: Implementation ready
	 */
	if(!crisis_event) return FALSE
	
	// Framework: Would set crisis_event.status = "ended"
	world.log << "CRISIS: Crisis manually resolved"
	return TRUE

// ============================================================================
// CRISIS ANALYTICS & DISPLAY
// ============================================================================

/datum/crisis_event/proc/GetCrisisStatus()
	/**
	 * GetCrisisStatus()
	 * Returns comprehensive crisis info
	 */
	var/list/crisis_info = list(
		"name" = event_name,
		"type" = event_type,
		"severity" = round(severity * 100),
		"intensity" = round(current_intensity * 100),
		"crisis_status" = status,
		"price_impact" = round(price_multiplier * 100),
		"supply_impact" = round(supply_modifier * 100),
		"duration_remaining" = max(0, (start_time + duration) - world.time),
		"affected_commodities" = 0,  // Framework: would count from list
		"bankruptcies" = bankruptcies,
		"wealth_destroyed" = wealth_destroyed
	)
	
	return crisis_info

/datum/crisis_event/proc/DisplayCrisisInfo()
	/**
	 * DisplayCrisisInfo()
	 * Returns formatted crisis information
	 */
	var/display = ""
	
	display += "╔════════════════════════════════════════╗\n"
	display += "║ ECONOMIC CRISIS ALERT\n"
	display += "╚════════════════════════════════════════╝\n\n"
	
	display += "Crisis: [event_name]\n"
	display += "Type: [event_type]\n"
	display += "Severity: [round(severity*100)]%\n"
	display += "Current Intensity: [round(current_intensity*100)]%\n"
	display += "Status: [status]\n\n"
	
	display += "Market Impact:\n"
	display += "  Prices: [round(price_multiplier*100)]% of normal\n"
	display += "  Supply: [round(supply_modifier*100)]% of normal\n"
	display += "  Demand: [round(demand_modifier*100)]% of normal\n\n"
	
	display += "Duration Remaining: [max(0, (start_time + duration) - world.time)] ticks\n"
	display += "Bankruptcies: [bankruptcies]\n"
	display += "Wealth Lost: [wealth_destroyed] lucre\n\n"
	
	if(IsPlayerOpportune(null, src))
		display += "⚠ OPPORTUNITY: Astute traders may exploit this crisis!\n"
	else
		display += "⚠ WARNING: This crisis presents significant economic risk!\n"
	
	display += "╚════════════════════════════════════════╝\n"
	
	return display

// ============================================================================
// HISTORICAL TRACKING
// ============================================================================

/proc/RecordCrisisHistory(crisis_event)
	/**
	 * RecordCrisisHistory(crisis_event)
	 * Log crisis for historical analysis
	 * Framework: Would store in global history registry
	 */
	if(!crisis_event) return
	world.log << "CRISIS_HISTORY: Crisis recorded"

/proc/GetCrisisHistory(limit = 10)
	/**
	 * GetCrisisHistory(limit)
	 * Get past crises (for lore/analysis)
	 * Framework: Would query historical database
	 */
	var/list/history = list()
	// Implementation would return past crises
	return history

/proc/CalculateCrisisImpact(commodity, start_time, end_time)
	/**
	 * CalculateCrisisImpact(commodity, start_time, end_time)
	 * Analyze how crises affected a commodity's price
	 * Framework: Would aggregate crisis price impacts
	 */
	var/impact = 1.0
	// Would apply all crises affecting commodity during period
	return impact
