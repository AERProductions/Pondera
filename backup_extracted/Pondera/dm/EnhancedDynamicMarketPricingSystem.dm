/**
 * EnhancedDynamicMarketPricingSystem.dm
 * Phase 12a: Enhanced market pricing with history tracking, elasticity curves, and seasonal modifiers
 * 
 * Features:
 * - Price history tracking (7+ days of data)
 * - Elasticity curves (item-specific price sensitivity)
 * - Price memory (prices evolve, don't reset)
 * - Seasonal price modifiers (food cheaper in harvest season)
 * - Black market pricing (restricted items cost more)
 * - Price trend forecasting (predict 7-day trends)
 * - Real trade impact on market (actual transactions move prices)
 * 
 * Extends: DynamicMarketPricingSystem.dm
 * Integration: Works with existing DynamicMarketPricingSystem, SeasonalEventsHook, DeedSystem
 */

// ============================================================================
// ENHANCED MARKET PRICE EXTENSIONS
// ============================================================================

// Extend the existing market_commodity with enhanced features
/datum/market_commodity
	var
		// Price history (7+ days minimum)
		list/price_history_7day = list()      // Last 7 day snapshots
		list/trade_history = list()            // All trades affecting this item
		last_price_snapshot = 0                // When did we last snapshot?
		
		// Elasticity and sensitivity
		base_elasticity = 1.0                  // Baseline elasticity before modifiers
		demand_elasticity = 1.0                // How much demand changes affect price
		
		// Volatility and price memory
		price_momentum = 0.0                   // Trend direction (-1.0 to 1.0)
		
		// Last transaction data
		last_trade_price = 0                   // Price of most recent trade
		last_trade_volume = 0                  // Quantity in last trade
		last_trade_time = 0                    // When last trade happened
		
		// Restrictions and black market
		is_restricted = FALSE                  // Restricted items = black market
		black_market_markup = 1.0              // 1.2 = 20% markup for scarcity
		scarcity_level = 0                     // 0-100 (affects black market price)
		
		// Seasonal modifiers
		seasonal_modifier = 1.0                // Multiplier based on season
		seasonal_demand_modifier = 1.0         // Season affects demand

/proc/EnhanceMarketCommodity(commodity_name)
	/**
	 * EnhanceMarketCommodity(commodity_name)
	 * Upgrades an existing market_commodity to use enhanced pricing
	 * Call this during initialization to enable enhanced features
	 */
	if(!market_engine) return FALSE
	
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return FALSE
	
	// Initialize enhanced fields if not already done
	if(!commodity.price_history_7day) commodity.price_history_7day = list()
	if(!commodity.trade_history) commodity.trade_history = list()
	commodity.last_price_snapshot = world.time
	commodity.base_elasticity = commodity.price_elasticity
	commodity.seasonal_modifier = 1.0
	commodity.seasonal_demand_modifier = 1.0
	
	return TRUE

/proc/InitializeEnhancedMarketPricingSystem()
	/**
	 * InitializeEnhancedMarketPricingSystem()
	 * Called after InitializeDynamicMarketPricingSystem() to add enhanced features
	 * Upgrades all base commodities to enhanced pricing
	 */
	if(!market_engine) return
	
	// Upgrade all existing commodities to enhanced pricing
	for(var/commodity_name in market_engine.commodities)
		EnhanceMarketCommodity(commodity_name)
	
	// Start price history snapshot loop (once per game day)
	spawn() PriceHistorySnapshotLoop()
	
	// Start seasonal modifier update loop
	spawn() SeasonalModifierUpdateLoop()
	
	world.log << "MARKET_ENHANCED: Dynamic pricing system enhanced with history tracking, elasticity, and seasonal modifiers"

// ============================================================================
// PRICE HISTORY TRACKING
// ============================================================================

/proc/PriceHistorySnapshotLoop()
	/**
	 * PriceHistorySnapshotLoop()
	 * Takes daily snapshots of all commodity prices for trend analysis
	 * Keeps 7+ days of history
	 */
	set background = 1
	set waitfor = 0
	
	var/snapshot_interval = 2400  // ~1 game day (24 seconds real time at 25 ticks/sec)
	
	while(1)
		sleep(snapshot_interval)
		
		if(!market_engine) continue
		
		// Snapshot all commodities
		for(var/commodity_name in market_engine.commodities)
			var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
			if(!commodity || !commodity.price_history_7day) continue
			
			// Add price snapshot
			commodity.price_history_7day += list(list(
				"price" = commodity.current_price,
				"supply" = commodity.current_supply,
				"demand" = commodity.current_demand,
				"timestamp" = world.time
			))
			
			// Keep only 7+ days (more than 168 snapshots)
			if(commodity.price_history_7day.len > 168)
				var/list/trimmed = list()
				for(var/i = commodity.price_history_7day.len - 167 to commodity.price_history_7day.len)
					trimmed += commodity.price_history_7day[i]
				commodity.price_history_7day = trimmed
			
			commodity.last_price_snapshot = world.time
			
			// Calculate price momentum (trend)
			CalculatePriceMomentum(commodity_name)

/proc/CalculatePriceMomentum(commodity_name)
	/**
	 * CalculatePriceMomentum(commodity_name)
	 * Calculates trend direction: -1.0 (falling) to +1.0 (rising)
	 * Uses exponential moving average of recent prices
	 */
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity || !commodity.price_history_7day) return
	
	var/hist_len = commodity.price_history_7day.len
	if(hist_len < 2) return
	
	var/oldest_price = 0
	var/newest_price = commodity.current_price
	
	// Get oldest snapshot
	if(hist_len > 0)
		oldest_price = commodity.price_history_7day[1]["price"]
	
	// Calculate overall trend
	if(oldest_price > 0)
		var/price_change = (newest_price - oldest_price) / oldest_price
		
		// Momentum ranges from -1.0 (falling) to +1.0 (rising)
		// Clamped to ±0.5 to prevent extreme values
		commodity.price_momentum = clamp(price_change * 2, -0.5, 0.5)

/proc/GetPrice7DayTrend(commodity_name)
	/**
	 * GetPrice7DayTrend(commodity_name)
	 * Returns price trend over last 7 days
	 * Returns: list with min, max, avg, current, trend direction
	 */
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity || !commodity.price_history_7day) return null
	
	var/list/history = commodity.price_history_7day
	if(history.len == 0) return null
	
	var/min_price = commodity.current_price
	var/max_price = commodity.current_price
	var/total_price = commodity.current_price
	var/count = 1
	
	// Analyze history
	for(var/entry in history)
		var/price = entry["price"]
		min_price = min(min_price, price)
		max_price = max(max_price, price)
		total_price += price
		count++
	
	var/avg_price = total_price / count
	
	var/trend = "stable"
	if(commodity.price_momentum > 0.1)
		trend = "rising"
	else if(commodity.price_momentum < -0.1)
		trend = "falling"
	
	return list(
		"min" = round(min_price, 0.01),
		"max" = round(max_price, 0.01),
		"avg" = round(avg_price, 0.01),
		"current" = round(commodity.current_price, 0.01),
		"trend" = trend,
		"momentum" = round(commodity.price_momentum, 0.01),
		"history_days" = max(1, history.len / 24)  // Approximate days
	)

// ============================================================================
// ELASTICITY CURVES
// ============================================================================

/proc/GetPriceElasticity(commodity_name)
	/**
	 * GetPriceElasticity(commodity_name)
	 * Returns elasticity for a commodity
	 * 0.5 = inelastic (wood - always needed)
	 * 1.0 = unit elastic (normal)
	 * 2.0 = elastic (luxury - price sensitive)
	 */
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity)
		return 1.0  // Default
	
	return commodity.price_elasticity

/proc/SetCommodityElasticity(commodity_name, elasticity)
	/**
	 * SetCommodityElasticity(commodity_name, elasticity)
	 * Sets elasticity for a commodity
	 * Call during initialization to tune price sensitivity
	 */
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return
	
	commodity.price_elasticity = clamp(elasticity, 0.5, 2.0)
	commodity.base_elasticity = commodity.price_elasticity

/proc/CalculateElasticityAdjustedPrice(commodity_name, supply_ratio)
	/**
	 * CalculateElasticityAdjustedPrice(commodity_name, supply_ratio)
	 * Applies elasticity curve to price adjustment
	 * Formula: Price = Base × (1 + elasticity × (supply_shortage / base))
	 * Returns: multiplier to apply to base price
	 */
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return 1.0
	
	var/elasticity = commodity.price_elasticity
	var/shortage = 1.0 - supply_ratio  // Negative if surplus
	
	// Inelastic goods (wood, stone) resist price changes
	// Elastic goods (weapons, luxury) respond strongly to supply
	var/multiplier = 1.0 + (elasticity * shortage * 0.3)
	
	return clamp(multiplier, 0.5, 2.0)

// ============================================================================
// SEASONAL PRICE MODIFIERS
// ============================================================================

/proc/SeasonalModifierUpdateLoop()
	/**
	 * SeasonalModifierUpdateLoop()
	 * Updates seasonal price modifiers whenever season changes
	 * Also called at startup to establish baseline modifiers
	 */
	set background = 1
	set waitfor = 0
	
	var/last_season = global.season
	
	while(1)
		sleep(100)  // Check every 5 seconds real time
		
		if(!market_engine) continue
		
		// Detect season change
		if(global.season != last_season)
			last_season = global.season
			UpdateAllSeasonalModifiers()

/proc/UpdateAllSeasonalModifiers()
	/**
	 * UpdateAllSeasonalModifiers()
	 * Recalculates seasonal modifiers for all commodities based on current season
	 */
	if(!market_engine) return
	
	for(var/commodity_name in market_engine.commodities)
		var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
		if(!commodity) continue
		
		ApplySeasonalPriceModifier(commodity_name, global.season)

/proc/ApplySeasonalPriceModifier(commodity_name, season)
	/**
	 * ApplySeasonalPriceModifier(commodity_name, season)
	 * Applies seasonal price adjustments based on item type and season
	 * Examples:
	 * - Food crops cheap in harvest season, expensive in winter
	 * - Seeds expensive in spring, cheap in winter
	 * - Tools stay stable year-round
	 * - Weapons more expensive during PvP phases
	 */
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return
	
	var/name = commodity.commodity_name
	var/modifier = 1.0
	var/demand_mod = 1.0
	
	switch(season)
		if("Spring")
			// Spring: Planting season
			if("Seed" in name || "Sprout" in name)
				modifier = 0.8  // Seeds cheap (abundant)
				demand_mod = 1.3  // Demand high (planting)
			else if("Food" in name || "Wheat" in name || "Grain" in name)
				modifier = 1.2  // Food expensive (winter depletion)
			else if("Herb" in name)
				modifier = 0.9  // Herbs start growing
		
		if("Summer")
			// Summer: Growing and early harvest
			if("Food" in name || "Wheat" in name || "Grain" in name)
				modifier = 1.0  // Food normalizing (growth phase)
				demand_mod = 1.1  // Demand moderate (growing)
			else if("Seed" in name)
				modifier = 1.2  // Seeds expensive (planting window closing)
			else if("Herb" in name || "Vegetable" in name)
				modifier = 0.7  // Herbs/vegetables cheap (abundance)
				demand_mod = 1.2  // Demand high (cooking)
		
		if("Autumn")
			// Autumn: Harvest season
			if("Food" in name || "Wheat" in name || "Grain" in name)
				modifier = 0.6  // Food cheap (harvest abundance)
				demand_mod = 0.8  // Demand low (abundance)
			else if("Herb" in name || "Vegetable" in name)
				modifier = 0.7  // Vegetables very cheap
			else if("Seed" in name)
				modifier = 0.9  // Seeds for next spring becoming available
		
		if("Winter")
			// Winter: Scarcity and preservation
			if("Food" in name || "Wheat" in name || "Grain" in name || "Herb" in name)
				modifier = 1.8  // Food EXPENSIVE (scarcity)
				demand_mod = 1.5  // Demand very high (survival)
			else if("Seed" in name)
				modifier = 1.3  // Seeds for spring expensive (critical)
			else if("Vegetable" in name)
				modifier = 2.0  // Vegetables scarce and precious
	
	// Apply modifiers
	commodity.seasonal_modifier = modifier
	commodity.seasonal_demand_modifier = demand_mod
	
	// Update demand based on seasonal demand modifier
	var/base_demand = commodity.current_supply * 0.8  // Reset to baseline
	commodity.current_demand = base_demand * demand_mod

/proc/GetSeasonalModifier(commodity_name)
	/**
	 * GetSeasonalModifier(commodity_name)
	 * Returns current seasonal price modifier
	 */
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return 1.0
	
	return commodity.seasonal_modifier

// ============================================================================
// BLACK MARKET PRICING
// ============================================================================

/proc/SetBlackMarketItem(commodity_name, restrict = TRUE)
	/**
	 * SetBlackMarketItem(commodity_name, restrict)
	 * Marks item as restricted (black market pricing applies)
	 * Restricted items cost more when scarce
	 */
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return
	
	commodity.is_restricted = restrict
	
	if(restrict)
		world.log << "MARKET_ENHANCED: [commodity_name] marked as restricted (black market pricing)"

/proc/CalculateBlackMarketMarkup(commodity_name, scarcity_level)
	/**
	 * CalculateBlackMarketMarkup(commodity_name, scarcity_level)
	 * Calculates black market markup for restricted items
	 * scarcity_level: 0-100 (0=abundant, 100=critically scarce)
	 * Returns: price multiplier (1.0 = normal, 2.0 = double price)
	 */
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return 1.0
	
	if(!commodity.is_restricted) return 1.0
	
	// Markup formula: 1.0 + (scarcity * 0.01)
	// 0 scarcity = 1.0 (normal price)
	// 50 scarcity = 1.5 (50% markup)
	// 100 scarcity = 2.0 (100% markup)
	var/markup = 1.0 + (scarcity_level * 0.01)
	
	commodity.black_market_markup = markup
	commodity.scarcity_level = scarcity_level
	
	return markup

// ============================================================================
// REAL TRADE IMPACT ON PRICES
// ============================================================================

/proc/UpdatePriceFromTrade(commodity_name, quantity, price_paid)
	/**
	 * UpdatePriceFromTrade(commodity_name, quantity, price_paid)
	 * Updates market price based on actual player transaction
	 * Large transactions move prices more than small ones
	 * Tracks trade history for analysis
	 */
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return
	
	// Record trade
	commodity.last_trade_price = price_paid
	commodity.last_trade_volume = quantity
	commodity.last_trade_time = world.time
	
	// Add to trade history
	if(!commodity.trade_history) commodity.trade_history = list()
	commodity.trade_history += list(list(
		"quantity" = quantity,
		"price" = price_paid,
		"timestamp" = world.time
	))
	
	// Keep only last 100 trades
	if(commodity.trade_history.len > 100)
		var/list/trimmed = list()
		for(var/i = commodity.trade_history.len - 99 to commodity.trade_history.len)
			trimmed += commodity.trade_history[i]
		commodity.trade_history = trimmed
	
	// Adjust price based on trade
	// Large transactions move market more
	var/impact = min(0.05, (quantity / 100) * 0.01)  // Max 5% impact per trade
	
	// If price_paid > current_price, market adjusts UP
	// If price_paid < current_price, market adjusts DOWN
	var/price_direction = price_paid > commodity.current_price ? 1.0 : -1.0
	var/adjustment = commodity.current_price * impact * price_direction
	
	commodity.current_price += adjustment
	commodity.current_price = clamp(commodity.current_price, commodity.min_price, commodity.max_price)

// ============================================================================
// PRICE DISPLAY & ANALYSIS
// ============================================================================

/proc/GetEnhancedPriceAnalysis(commodity_name)
	/**
	 * GetEnhancedPriceAnalysis(commodity_name)
	 * Returns comprehensive price analysis for a commodity
	 * Used by market boards and trading UI
	 */
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return null
	
	var/trend = GetPrice7DayTrend(commodity_name)
	
	var/list/analysis = list(
		"name" = commodity.commodity_name,
		"current_price" = round(commodity.current_price, 0.01),
		"base_price" = round(commodity.base_price, 0.01),
		"elasticity" = round(commodity.price_elasticity, 0.01),
		"volatility" = round(commodity.price_volatility, 0.01),
		"momentum" = round(commodity.price_momentum, 0.01),
		"trend" = trend,
		"seasonal_modifier" = round(commodity.seasonal_modifier, 0.01),
		"is_restricted" = commodity.is_restricted,
		"black_market_markup" = round(commodity.black_market_markup, 0.01),
		"last_trade_price" = commodity.last_trade_price,
		"last_trade_volume" = commodity.last_trade_volume,
		"last_trade_time" = commodity.last_trade_time
	)
	
	return analysis

/proc/DisplayPriceChart(commodity_name)
	/**
	 * DisplayPriceChart(commodity_name)
	 * Returns ASCII price chart for market board display
	 * Shows 7-day price history
	 */
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity || !commodity.price_history_7day) return "No data"
	
	var/list/history = commodity.price_history_7day
	if(history.len == 0) return "No history yet"
	
	var/chart = "[commodity.commodity_name] - 7 Day Price History:\n"
	
	// Find min/max for scaling
	var/min_price = commodity.current_price
	var/max_price = commodity.current_price
	
	for(var/entry in history)
		min_price = min(min_price, entry["price"])
		max_price = max(max_price, entry["price"])
	
	// Add some padding for readability
	var/price_range = max_price - min_price
	if(price_range == 0) price_range = 1
	min_price -= price_range * 0.1
	max_price += price_range * 0.1
	
	// Render chart (simplified ASCII)
	for(var/i = 1 to min(history.len, 7))
		var/entry = history[history.len - 7 + i]
		var/price = entry["price"]
		var/normalized = (price - min_price) / (max_price - min_price)
		var/bars = max(1, round(normalized * 20))
		
		chart += "Day [i]: [repeat("#", bars)] [price]\n"
	
	return chart

/proc/repeat(text, times)
	/**
	 * Helper to repeat text N times
	 */
	var/result = ""
	for(var/i = 1 to times)
		result += text
	return result

// ============================================================================
// INTEGRATION & SETUP
// ============================================================================

/proc/SetupEnhancedPricingTuning()
	/**
	 * SetupEnhancedPricingTuning()
	 * Tunes elasticity and seasonal modifiers for all items
	 * Call during initialization after commodities created
	 */
	
	// Inelastic goods (always needed, resistant to price changes)
	SetCommodityElasticity("Stone", 0.5)
	SetCommodityElasticity("Wood", 0.5)
	SetCommodityElasticity("Iron Ore", 0.6)
	SetCommodityElasticity("Clay", 0.6)
	
	// Normal elasticity
	SetCommodityElasticity("Iron Ingot", 1.0)
	SetCommodityElasticity("Steel Ingot", 1.0)
	SetCommodityElasticity("Bronze Ingot", 1.0)
	
	// Elastic goods (luxury, price-sensitive)
	SetCommodityElasticity("Long Sword", 1.8)
	SetCommodityElasticity("War Axe", 1.8)
	SetCommodityElasticity("Steel Armor", 1.8)
	SetCommodityElasticity("War Armor", 2.0)
	
	// Mark restricted items (black market)
	// None by default, but can be set by admin/systems
	
	world.log << "MARKET_ENHANCED: Elasticity tuning complete"
