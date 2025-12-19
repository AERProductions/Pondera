// dm/Phase13C_EconomicCycles.dm
// Economic Feedback Loops, Inflation/Deflation, and Market Crashes
// Phase 13C: Dynamic Economy - Self-Regulating Economic System
// Version: 1.0
// Date: 2025-12-17

// ============================================================================
// GLOBAL CONFIGURATION
// ============================================================================

var/global/economic_cycles_enabled = TRUE
var/global/active_cycles = list()        // List of resource types in cycles
var/global/economic_system_ready = FALSE

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeEconomicCycles()
 * Called from InitializationManager.dm (Phase 4, tick 530)
 * Loads existing cycles and resumes market indicators
 */
proc/InitializeEconomicCycles()
	if(!sqlite_ready)
		world.log << "[PHASE13C] Skipping economic cycles initialization - database not ready"
		return FALSE

	world.log << "[PHASE13C] Initializing Economic Cycles System..."

	// Load all active market cycles
	var/query = "SELECT cycle_id, affected_resource, cycle_type FROM market_cycles WHERE cycle_type IN ('boom', 'bubble', 'crash', 'recovery') ORDER BY cycle_start_timestamp DESC LIMIT 50;"
	var/result = ExecuteSQLiteQuery(query)

	if(!result)
		world.log << "[PHASE13C] No active market cycles found"
	else
		world.log << "[PHASE13C] Loaded market cycles from database"

	// Initialize economic indicators for all resources
	UpdateAllEconomicIndicators()

	// Calculate overall economic health
	var/health = GetEconomicHealth()
	world.log << "[PHASE13C] Overall Economic Health: [health]%"

	// Start economic monitoring loop
	spawn(5)
		EconomicMonitoringLoop()

	economic_system_ready = TRUE
	RegisterInitComplete("Phase13C_EconomicCycles")
	world.log << "[PHASE13C] Economic Cycles System initialized OK"
	return TRUE

// ============================================================================
// ECONOMIC INDICATOR TRACKING
// ============================================================================

/**
 * UpdateEconomicIndicators(resource_type)
 * Updates price trends, supply/demand, and volatility for a resource
 */
proc/UpdateEconomicIndicators(resource_type)
	if(!sqlite_ready)
		return FALSE

	// TODO: Fetch historical price data (last 24h)
	// Calculate: price_trend (up/down/flat)
	// Calculate: supply_level (shortage/normal/surplus)
	// Calculate: demand_level (low/normal/high)
	// Calculate: volatility (price swing % per day)
	// Update economic_indicators table

	world.log << "[PHASE13C] Economic indicators updated for [resource_type]"
	return TRUE

/**
 * UpdateAllEconomicIndicators()
 * Updates indicators for all tracked resources
 */
proc/UpdateAllEconomicIndicators()
	// TODO: Query all distinct resources from market_prices
	// For each resource: call UpdateEconomicIndicators()

	world.log << "[PHASE13C] All economic indicators updated"
	return TRUE

/**
 * GetEconomicIndicators(resource_type)
 * Returns current economic indicators for a resource
 */
proc/GetEconomicIndicators(resource_type)
	// TODO: Query economic_indicators for resource
	// Return: {price_trend, supply, demand, volatility, health}

	return list()

// ============================================================================
// BUBBLE & CRASH DETECTION
// ============================================================================

/**
 * DetectBubble(resource_type)
 * Detects if a resource is in a price bubble (severity 1-10)
 * 
 * Returns: severity (0=no bubble, 1-10=severity)
 */
proc/DetectBubble(resource_type)
	// TODO: Check if:
	//   - Price up >50% in last 24h
	//   - Volume spike >200% (many purchases)
	//   - Volatility >20% (wild swings)
	// Severity = (price_rise % - 50) / 10, clamped 1-10

	return 0  // Placeholder: no bubble

/**
 * InflateBubble(resource_type)
 * Intensifies bubble - prices continue rising rapidly
 */
proc/InflateBubble(resource_type)
	// TODO: Increase price multiplier  on market_prices
	// Apply elasticity boost to cause rapid inflation
	// Log bubble intensity increase

	world.log << "[PHASE13C] Bubble inflating for [resource_type]"
	return TRUE

/**
 * PopBubble(resource_type)
 * Triggers a bubble pop - prices crash
 */
proc/PopBubble(resource_type)
	// TODO: Trigger economic shock with -80% price change
	// Record crash event in market_cycles
	// Begin recovery phase

	world.log << "[PHASE13C] Bubble popped for [resource_type]!"
	return TRUE

/**
 * InitiateRecovery(resource_type)
 * Starts recovery phase after crash
 */
proc/InitiateRecovery(resource_type)
	// TODO: Gradually restore prices to baseline over 6-12 hours
	// Reduce volatility
	// Normalize supply/demand

	world.log << "[PHASE13C] Recovery phase started for [resource_type]"
	return TRUE

// ============================================================================
// CYCLE MONITORING & METRICS
// ============================================================================

/**
 * GetCycleDuration(cycle_type)
 * Returns typical duration in ticks for a cycle phase
 */
proc/GetCycleDuration(cycle_type)
	// boom: 24h = 3600 ticks
	// bubble: 24-48h = 3600-7200 ticks
	// crash: instant (1 tick)
	// recovery: 6-12h = 900-1800 ticks

	switch(cycle_type)
		if("boom")
			return 3600
		if("bubble")
			return 5400
		if("crash")
			return 1
		if("recovery")
			return 1440

	return 0

/**
 * GetEconomicHealth()
 * Returns overall economy health percentage (0-100%)
 * 100% = stable, <50% = crisis
 */
proc/GetEconomicHealth()
	// TODO: Aggregate indicators:
	//   - Count active bubbles (each -20%)
	//   - Count recent crashes (each -30%)
	//   - Count in_recovery resources (each -10%)
	//   - Add inflation %
	// Health = 100 - penalties

	return 75  // Placeholder: stable economy

/**
 * GetEconomyStatus()
 * Returns economy status string: stable|booming|warning|critical
 */
proc/GetEconomyStatus()
	var/health = GetEconomicHealth()

	if(health >= 80)
		return "stable"
	else if(health >= 50)
		return "booming"
	else if(health >= 20)
		return "warning"
	else
		return "critical"

/**
 * EconomicMonitoringLoop()
 * Background loop monitoring economic cycles
 * Runs every 100 ticks (~125 seconds)
 */
proc/EconomicMonitoringLoop()
	set background = 1
	set waitfor = 0

	while(TRUE)
		sleep(100)

		if(!economic_cycles_enabled) continue

		// Update indicators for all resources
		UpdateAllEconomicIndicators()

		// TODO: For each resource:
		//   - Detect bubble if forming
		//   - Detect crash if bubble bursts
		//   - Update recovery if in progress
		//   - Broadcast market alerts if major changes
	return

// ============================================================================
// FEEDBACK LOOP EXAMPLES (for documentation)
// ============================================================================

/*
 * STONE BOOM CYCLE (24-84 hours)
 * 
 * Hour 0-24: BOOM
 *   - Major construction project announced (world event)
 *   - Demand for stone spikes: 500 units/hour → 1500 units/hour
 *   - Price: 10g → 20g per stone
 *   - Miners respond with increased production
 *   - Supply increases: 400 units/hour → 600 units/hour
 *   - UpdateEconomicIndicators: price_change = +150% in 24h
 * 
 * Hour 48-72: BUBBLE
 *   - Speculators buying stone to resell
 *   - Price: 35g -> 50g per stone
 *   - DetectBubble returns severity=8 (way overbought)
 *   - InflateBubble: price continues rising
 * 
 * Hour 72-84: CRASH
 *   - PopBubble triggered
 *   - Economic_shock: crash_severity = -80%
 *   - Price drops: 50g -> 15g per stone
 *   - Speculators panic sell (lock in losses)
 * 
 * Hour 84+: RECOVERY
 *   - InitiateRecovery
 *   - Price stabilizes: 15g -> 12g (baseline)
 *   - Supply replenishes
 *   - Cycle restarts
 * 
 * Total Cycle: 84+ hours
 * Winners: Traders who sold before crash
 * Losers: Speculators caught holding at peak
 */

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * GetResourceBasePrice(resource_type)
 * Returns the equilibrium price when no cycles active
 */
proc/GetResourceBasePrice(resource_type)
	// TODO: Query market_prices where commodity_name = ? and get base_price
	return 0

/**
 * GetCurrentPrice(resource_type)
 * Returns current market price (affected by cycles)
 */
proc/GetCurrentPrice(resource_type)
	// TODO: Query market_prices where commodity_name = ? and get current_price
	return 0

/**
 * CalculatePriceTrend(resource_type, hours_back)
 * Returns price trend: bullish|neutral|bearish
 */
proc/CalculatePriceTrend(resource_type, hours_back = 24)
	// TODO: Get average price from hours_back
	// Compare to current price
	// Determine direction

	return "neutral"

// ============================================================================
// END OF PHASE 13C
// ============================================================================

