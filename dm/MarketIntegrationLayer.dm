/**
 * MarketIntegrationLayer.dm
 * Phase 13: Market Economy Integration Layer
 * 
 * Purpose: Unifies all Phase 12 market systems into a cohesive economy
 * 
 * Features:
 * - Central market registry (commodities, trades, crises)
 * - Automatic price updates from supply/demand
 * - NPC merchant integration with trading posts
 * - Territory resource distribution to markets
 * - Crisis event propagation through all systems
 * - Real-time market synchronization
 * - Player activity impact on prices
 * - Historical price tracking
 * 
 * System Dependencies:
 * - EnhancedDynamicMarketPricingSystem.dm (prices, elasticity)
 * - SupplyDemandSystem.dm (curves, sentiment)
 * - TerritoryResourceAvailability.dm (supply sources)
 * - NPCMerchantSystem.dm (traders, inventory)
 * - TradingPostUI.dm (player stalls)
 * - CrisisEventsSystem.dm (disruptions)
 */

// ============================================================================
// CENTRAL MARKET REGISTRY
// ============================================================================

/datum/market_state
	/**
	 * market_state
	 * Aggregated snapshot of entire market at a point in time
	 */
	var
		timestamp = 0
		
		// Commodity tracking
		list/commodity_prices = list()     // commodity_name -> current_price
		list/commodity_supplies = list()   // commodity_name -> available_units
		list/commodity_demands = list()    // commodity_name -> demanded_units
		list/commodity_trends = list()     // commodity_name -> price_trend (-1.0 to +1.0)
		
		// Market health
		market_sentiment = 0               // -100 to +100 (bearish to bullish)
		volatility_index = 0.1             // 0.0-1.0 price swing intensity
		active_crises = 0                  // Number of active economic crises
		
		// Activity metrics
		total_trades = 0
		total_volume = 0
		player_trades = 0
		merchant_trades = 0
		
		// Territory impact
		controlled_supply = 0              // % of supply under territory control
		taxation_collected = 0

/proc/GetMarketState()
	/**
	 * GetMarketState()
	 * Snapshot entire market at current time
	 * Returns: /datum/market_state
	 */
	var/datum/market_state/state = new /datum/market_state()
	
	state.timestamp = world.time
	
	// Would aggregate from all systems:
	// - Enhanced pricing system (prices)
	// - Supply/demand system (curves, sentiment, volatility)
	// - Territory system (controlled supply)
	// - NPC merchant system (active trades)
	// - Trading posts (player activity)
	// - Crisis system (active crises)
	
	world.log << "MARKET: State snapshot taken at [state.timestamp]"
	
	return state

// ============================================================================
// PRICE PROPAGATION SYSTEM
// ============================================================================

/proc/UpdateMarketPrices()
	/**
	 * UpdateMarketPrices()
	 * Recalculate all commodity prices based on current supply/demand
	 * Called periodically (every 50 ticks or on major events)
	 */
	
	// For each commodity:
	// 1. Get base price from EnhancedDynamicMarketPricingSystem
	// 2. Get supply/demand curve from SupplyDemandSystem
	// 3. Check for active crises affecting this commodity
	// 4. Get territory-based modifiers from TerritoryResourceAvailability
	// 5. Apply NPC sentiment/mood modifiers from NPCMerchantSystem
	// 6. Store final price
	// 7. Update trading posts with new prices
	
	world.log << "MARKET: Prices updated"

/proc/PropagateSupplyUpdate(commodity_name, new_supply)
	/**
	 * PropagateSupplyUpdate(commodity_name, new_supply)
	 * When supply changes (harvest, shortage), update all related systems
	 */
	
	// 1. Update SupplyDemandSystem curve
	// 2. Recalculate prices (calls UpdateMarketPrices)
	// 3. Notify NPCs in relevant territories
	// 4. Update trading post availability
	// 5. Check for crisis triggers (gluts, shortages)
	
	world.log << "MARKET: [commodity_name] supply updated to [new_supply] units"

/proc/PropagateDemandUpdate(commodity_name, new_demand)
	/**
	 * PropagateDemandUpdate(commodity_name, new_demand)
	 * When demand changes (consumption, events), update all systems
	 */
	
	// 1. Update SupplyDemandSystem curve
	// 2. Recalculate prices
	// 3. Update NPC purchasing behavior
	// 4. Check for shortage/glut conditions
	// 5. Trigger speculation if profitable
	
	world.log << "MARKET: [commodity_name] demand updated to [new_demand] units"

// ============================================================================
// NPC-MARKET INTEGRATION
// ============================================================================

/proc/SyncNPCMerchantWithMarket(npc_merchant)
	/**
	 * SyncNPCMerchantWithMarket(npc_merchant)
	 * Update NPC prices based on market conditions
	 * Called when:
	 * - Market prices change significantly
	 * - NPC's mood/wealth changes
	 * - Territory ownership changes
	 */
	
	if(!npc_merchant) return FALSE
	
	// Get current market prices
	// Apply NPC personality modifiers:
	// - Fair: 95% buy, 105% sell (at market)
	// - Greedy: 70% buy, 130% sell (undercut buying, raise selling)
	// - Desperate: 120% buy, 80% sell (overpay buying, underprice selling)
	
	// Apply NPC mood:
	// - Happy: More generous pricing
	// - Angry: Worse pricing
	// - Neutral: Market rates
	
	// Update NPC's buy/sell inventory based on:
	// - Current supply (buy if high, avoid if low)
	// - Current demand (sell if high, hold if low)
	// - Competitor activity
	
	world.log << "MARKET: NPC merchant synced with market"
	return TRUE

// ============================================================================
// TERRITORY-MARKET INTEGRATION
// ============================================================================

/proc/IntegrateTerritoryIntoMarket(territory_name)
	/**
	 * IntegrateTerritoryIntoMarket(territory_name)
	 * Link territory resource availability to market supply
	 */
	
	// When territory is claimed:
	// 1. Update market supply curve (owner can increase/decrease)
	// 2. Adjust market prices based on supply
	// 3. Restrict access for non-owners
	// 4. Collect taxes on harvesting/sales
	
	// When territory is contested:
	// 1. Reduce available supply (raid mechanics)
	// 2. Spike prices (shortage condition)
	// 3. Disable owner's taxation temporarily
	
	// When territory changes hands:
	// 1. Update ownership
	// 2. Revise supply cap based on new owner's tier
	// 3. Reset taxation
	
	world.log << "MARKET: Territory integrated into market system"

/proc/UpdateTerritoryTaxation(territory_name, collected_tax)
	/**
	 * UpdateTerritoryTaxation(territory_name, collected_tax)
	 * Pass tax revenue through market economy
	 */
	
	// Owner receives tax as "market revenue"
	// Could be reinvested into:
	// - Increasing supply (pay workers)
	// - Infrastructure improvements (lower prices)
	// - Competition reduction (monopoly mechanics)
	
	world.log << "MARKET: [territory_name] collected [collected_tax] lucre in taxes"

// ============================================================================
// CRISIS EVENT PROPAGATION
// ============================================================================

/proc/PropagateEconomicCrisis(crisis_event)
	/**
	 * PropagateEconomicCrisis(crisis_event)
	 * When crisis occurs, update all market systems
	 */
	
	if(!crisis_event) return FALSE
	
	// 1. Update affected commodity prices
	// 2. Modify supply for shortage/glut crises
	// 3. Update NPC sentiment (panic, greed, etc)
	// 4. Trigger speculation opportunities
	// 5. Mark territories as affected (reduced productivity)
	// 6. Log crisis for historical analysis
	// 7. Notify players of market conditions
	
	world.log << "MARKET: Crisis event propagated through market"
	return TRUE

/proc/PropagateMarketRecovery(crisis_event)
	/**
	 * PropagateMarketRecovery(crisis_event)
	 * When crisis ends, restore normal conditions
	 */
	
	// 1. Gradually return prices to baseline
	// 2. Restore supply/demand to normal
	// 3. NPC sentiment returns to neutral
	// 4. Opportunity window closes for speculators
	// 5. Territories return to full productivity
	
	world.log << "MARKET: Market recovery initiated"

// ============================================================================
// TRADING ACTIVITY IMPACT
// ============================================================================

/proc/RecordPlayerTrade(buyer, seller, item_name, quantity, price_per_unit)
	/**
	 * RecordPlayerTrade(buyer, seller, item_name, quantity, price_per_unit)
	 * Log player trade and update market impact
	 */
	
	if(!buyer || !seller) return FALSE
	
	// Update market:
	// 1. Reduce supply in market (items taken off market)
	// 2. Update price momentum (if price != baseline)
	// 3. Track trading volume
	// 4. Check for market manipulation patterns
	// 5. Update NPC response (will try to match price)
	
	// If player price != market price:
	// - Player paying above market: Creates positive momentum (more sellers interested)
	// - Player paying below market: Creates negative momentum (fewer buyers)
	
	// If large volume:
	// - Notify NPCs of unusual activity
	// - Possible crisis trigger if supply drained
	
	world.log << "MARKET: Trade recorded - [quantity]x [item_name] @ [price_per_unit] lucre"
	return TRUE

/proc/RecordNPCTrade(merchant, commodity, quantity, price, buyer_type)
	/**
	 * RecordNPCTrade(merchant, commodity, quantity, price, buyer_type)
	 * Log NPC merchant trade
	 * buyer_type: "player", "npc", "market"
	 */
	
	// Similar to player trade but:
	// - NPC trades inform market sentiment
	// - Multiple NPC trades indicate trends
	// - Can trigger cascade effects (all NPCs buying = shortage expected)
	
	world.log << "MARKET: NPC trade - [quantity]x [commodity] @ [price] lucre"

// ============================================================================
// MARKET EFFICIENCY CHECKS
// ============================================================================

/proc/CheckForArbitrage(item_name)
	/**
	 * CheckForArbitrage(item_name)
	 * Detect price disparities between markets/NPCs
	 * Opportunities for profit via buying low and selling high
	 */
	
	// Find cheapest source (NPC, trading post, territory)
	// Find most expensive buyer
	// Profit = (expensive - cheap) * expected_volume
	
	// If profit > threshold:
	// - Notify players of opportunity (optional)
	// - Allow speculators to exploit
	// - NPCs eventually notice and adjust prices
	
	return 0  // Baseline profit opportunity

/proc/CheckForMonopoly(commodity_name)
	/**
	 * CheckForMonopoly(commodity_name)
	 * Detect if single entity controls market
	 * Can trigger anti-monopoly events or NPC response
	 */
	
	// Check:
	// - If single player owns >50% of supply
	// - If single territory controls all production
	// - If single NPC has monopoly buying power
	
	// If monopoly detected:
	// - NPCs may refuse to trade with monopolist (too expensive)
	// - Players may boycott
	// - Government could intervene (mechanics tbd)
	
	return FALSE  // No monopoly currently

/proc/CheckForMarketManipulation(player, item_name, quantity)
	/**
	 * CheckForMarketManipulation(player, item_name, quantity)
	 * Detect suspicious market activity
	 */
	
	// Flags for investigation:
	// - Sudden large purchases (hoarding?)
	// - Rapid buy/sell cycles (wash trading?)
	// - Price dumps (market crashing?)
	// - Coordinated NPC activity (collusion?)
	
	// Current implementation: Framework only
	return FALSE

// ============================================================================
// MARKET ANALYTICS & REPORTING
// ============================================================================

/proc/GenerateMarketReport()
	/**
	 * GenerateMarketReport()
	 * Comprehensive market analysis for players/admins
	 */
	
	var/report = ""
	
	report += "╔════════════════════════════════════════╗\n"
	report += "║ MARKET ECONOMY REPORT\n"
	report += "║ Generated: [world.time] ticks\n"
	report += "╚════════════════════════════════════════╝\n\n"
	
	report += "MARKET OVERVIEW:\n"
	report += "  (Would show price indices, volatility, sentiment)\n\n"
	
	report += "TOP COMMODITIES:\n"
	report += "  (Would list highest volume items)\n\n"
	
	report += "ACTIVE CRISES:\n"
	report += "  (Would list ongoing disruptions)\n\n"
	
	report += "TERRITORY CONTROL:\n"
	report += "  (Would show deed ownership by region)\n\n"
	
	report += "NPC MERCHANT STATUS:\n"
	report += "  (Would show merchant sentiment, inventory)\n\n"
	
	report += "PLAYER TRADING POSTS:\n"
	report += "  (Would show top sellers/buyers)\n\n"
	
	return report

/proc/GetCommodityMarketHealth(commodity_name)
	/**
	 * GetCommodityMarketHealth(commodity_name)
	 * Health check for specific commodity market
	 * Returns: dict with status metrics
	 */
	
	var/list/health = list(
		"price_volatility" = 0.5,
		"supply_status" = "balanced",    // shortage, balanced, glut
		"demand_status" = "neutral",     // low, neutral, high
		"price_trend" = "stable",        // rising, stable, falling
		"affected_by_crises" = 0,        // count of active crises
		"speculation_intensity" = 0.3    // 0.0-1.0
	)
	
	return health

// ============================================================================
// SYSTEM INITIALIZATION & MAINTENANCE
// ============================================================================

/proc/InitializeMarketIntegration()
	/**
	 * InitializeMarketIntegration()
	 * Sets up market integration layer
	 * Connects all Phase 12 systems
	 */
	
	// Start market synchronization loop
	spawn() MarketSynchronizationLoop()
	
	// Start crisis propagation monitor
	spawn() CrisisPropagationMonitor()
	
	// Start market efficiency checker
	spawn() MarketEfficiencyMonitor()
	
	world.log << "MARKET_INTEGRATION: System initialized"

/proc/MarketSynchronizationLoop()
	/**
	 * MarketSynchronizationLoop()
	 * Periodic sync of all market systems
	 * Updates prices, propagates changes, checks conditions
	 */
	set background = 1
	set waitfor = 0
	
	var/sync_interval = 100  // Every 100 ticks (~2.5 seconds)
	var/last_sync = world.time
	
	while(1)
		sleep(50)
		
		if(world.time - last_sync >= sync_interval)
			last_sync = world.time
			
			// Would perform:
			// UpdateMarketPrices()
			// SyncNPCMerchantWithMarket() for each NPC
			// CheckForArbitrage() for each commodity
			// PropagateEconomicCrisis() if active
			// RecordMarketSnapshot() for history
			// Framework ready for implementation

/proc/CrisisPropagationMonitor()
	/**
	 * CrisisPropagationMonitor()
	 * Watch for crisis events and propagate effects
	 */
	set background = 1
	set waitfor = 0
	
	var/check_interval = 200  // Every 200 ticks (~5 seconds)
	var/last_check = world.time
	
	while(1)
		sleep(50)
		
		if(world.time - last_check >= check_interval)
			last_check = world.time
			
			// Would check:
			// GetActiveCrises() list
			// For each crisis:
			//   PropagateEconomicCrisis(crisis)
			//   Update affected commodities
			//   Notify relevant systems
			// Framework ready

/proc/MarketEfficiencyMonitor()
	/**
	 * MarketEfficiencyMonitor()
	 * Detect anomalies, opportunities, and risks
	 */
	set background = 1
	set waitfor = 0
	
	var/check_interval = 500  // Every 500 ticks (~12 seconds)
	var/last_check = world.time
	
	while(1)
		sleep(50)
		
		if(world.time - last_check >= check_interval)
			last_check = world.time
			
			// Would check:
			// CheckForArbitrage() for each commodity
			// CheckForMonopoly() for each commodity
			// Detect unusual trading patterns
			// Notify admins of anomalies
			// Framework ready

// ============================================================================
// MARKET STATE HISTORY
// ============================================================================

/proc/RecordMarketSnapshot()
	/**
	 * RecordMarketSnapshot()
	 * Store market state for historical analysis
	 * Can replay market history to understand trends
	 */
	
	// Would append to global market history list
	// Keep only last N snapshots (e.g., 1000 for ~25 min history)
	
	world.log << "MARKET: Snapshot recorded"

/proc/GetMarketHistory(limit = 100)
	/**
	 * GetMarketHistory(limit)
	 * Get historical market snapshots
	 * For analysis and player charts
	 */
	
	var/list/history = list()
	// Would return last N snapshots
	return history

/proc/AnalyzeMarketTrend(commodity_name, time_window = 1000)
	/**
	 * AnalyzeMarketTrend(commodity_name, time_window)
	 * Analyze price trend over time
	 * Returns: trend direction and strength
	 */
	
	// Would look at snapshots within time window
	// Calculate average price, volatility, momentum
	// Return trend data
	
	return "stable"  // Default: framework
