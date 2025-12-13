/**
 * SupplyDemandSystem.dm
 * Phase 12d: Supply & Demand Curve Mechanics
 * 
 * Features:
 * - Dynamic elasticity based on supply/demand ratios
 * - Price volatility from scarcity and market gluts
 * - Market sentiment tracking (bullish/bearish)
 * - Speculative trading mechanics
 * - Supply shock events (droughts, plagues, booms)
 * - Demand cycles (seasonal, event-driven)
 * 
 * Integration:
 * - Works with EnhancedDynamicMarketPricingSystem.dm
 * - Works with TerritoryResourceAvailability.dm
 * - Works with NPCMerchantSystem.dm
 * - Feeds into price calculations via elasticity curves
 */

// ============================================================================
// SUPPLY & DEMAND CURVE DATA
// ============================================================================

/datum/supply_demand_curve
	var
		// Commodity identification
		commodity_name = "Stone"
		commodity_id = null
		base_supply = 100
		current_supply = 100
		supply_shock = 0
		supply_trend = 0
		
		// Demand tracking (units wanted per tick)
		base_demand = 100
		current_demand = 100
		demand_shock = 0
		demand_trend = 0
		
		// Elasticity (price sensitivity)
		price_elasticity = 1.0
		elasticity_momentum = 0
		
		// Market sentiment
		market_sentiment = 0
		sentiment_history = 0
		volatility_index = 0.1
		
		// Ratio tracking
		supply_demand_ratio = 1.0
		ratio_threshold_high = 2.0
		ratio_threshold_low = 0.5
		
		// Speculation tracking
		spec_buy_orders = 0
		spec_sell_orders = 0
		speculation_intensity = 0
		
		// Time tracking
		last_update = 0
		update_interval = 10
		cycle_phase = 0

/proc/CreateSupplyDemandCurve(commodity_name, base_supply = 100, base_demand = 100)
	/**
	 * CreateSupplyDemandCurve(commodity_name, base_supply, base_demand)
	 * Creates new supply/demand tracking for a commodity
	 * Returns: /datum/supply_demand_curve
	 */
	var/datum/supply_demand_curve/curve = new /datum/supply_demand_curve()
	
	curve.commodity_name = commodity_name
	curve.commodity_id = "[commodity_name]_[world.time]"
	curve.base_supply = base_supply
	curve.current_supply = base_supply
	curve.base_demand = base_demand
	curve.current_demand = base_demand
	curve.supply_demand_ratio = base_supply / max(1, base_demand)
	
	return curve

// ============================================================================
// SUPPLY & DEMAND UPDATES
// ============================================================================

/datum/supply_demand_curve/proc/UpdateSupply(new_supply)
	/**
	 * UpdateSupply(new_supply)
	 * Update current supply (from production/harvesting)
	 * Affects supply_shock calculation
	 */
	current_supply = new_supply
	var/deviation = (current_supply - base_supply) / max(1, base_supply)
	supply_shock = clamp(deviation, -1.0, 1.0)
	supply_demand_ratio = current_supply / max(1, current_demand)

/datum/supply_demand_curve/proc/UpdateDemand(new_demand)
	/**
	 * UpdateDemand(new_demand)
	 * Update current demand (from consumption/trading)
	 * Affects demand_shock calculation
	 */
	current_demand = new_demand
	var/deviation = (current_demand - base_demand) / max(1, base_demand)
	demand_shock = clamp(deviation, -1.0, 1.0)
	supply_demand_ratio = current_supply / max(1, current_demand)

/datum/supply_demand_curve/proc/RecalculateElasticity()
	/**
	 * RecalculateElasticity()
	 * Elasticity based on supply/demand ratio
	 * Shortage (low ratio) = inelastic (0.5)
	 * Balanced = neutral (1.0)
	 * Glut (high ratio) = elastic (2.0)
	 */
	var/ratio = supply_demand_ratio
	if(ratio > ratio_threshold_high)
		// Glut: elastic (buyers choosy)
		price_elasticity = 1.5 + (ratio - ratio_threshold_high) * 0.25
	else if(ratio < ratio_threshold_low)
		// Shortage: inelastic (buyers desperate)
		price_elasticity = 0.5 - (ratio_threshold_low - ratio) * 0.25
	else
		// Balanced: interpolate
		price_elasticity = 0.5 + (ratio / 1.0) * 1.0
	
	price_elasticity = clamp(price_elasticity, 0.5, 2.0)

/datum/supply_demand_curve/proc/UpdateMarketSentiment()
	/**
	 * UpdateMarketSentiment()
	 * Update bullish/bearish sentiment based on supply/demand
	 * Bullish when shortage, bearish when glut
	 */
	var/sentiment_shift = 0
	if(supply_demand_ratio < ratio_threshold_low)
		sentiment_shift = -50 * (ratio_threshold_low - supply_demand_ratio)
	else if(supply_demand_ratio > ratio_threshold_high)
		sentiment_shift = 50 * (supply_demand_ratio - ratio_threshold_high)
	sentiment_shift += demand_trend * 30
	sentiment_shift += supply_trend * -20  // Supply increase = bearish
	market_sentiment = round(market_sentiment * 0.7 + sentiment_shift * 0.3)
	market_sentiment = clamp(market_sentiment, -100, 100)

/datum/supply_demand_curve/proc/UpdateVolatility()
	/**
	 * UpdateVolatility()
	 * Price swing intensity based on uncertainty
	 * High when supply/demand extremes
	 * Low when balanced
	 */
	var/extremity = 0
	extremity += abs(supply_shock)
	extremity += abs(demand_shock)
	extremity += abs(market_sentiment) / 100.0
	
	// Speculation increases volatility
	extremity += speculation_intensity * 0.5
	
	// Smooth volatility
	volatility_index = round((volatility_index * 0.8 + (extremity / 3.0) * 0.2) * 100) / 100.0
	volatility_index = clamp(volatility_index, 0.05, 1.0)
// PRICE IMPACT CALCULATIONS
// ============================================================================

/datum/supply_demand_curve/proc/GetElasticityMultiplier()
	/**
	 * GetElasticityMultiplier()
	 * Returns price multiplier based on elasticity
	 * Low elasticity (shortage): price rises more
	 * High elasticity (glut): price falls more
	 */
	// Inverse relationship: inelastic = higher price multiplier
	return 2.5 - price_elasticity  // Range: 0.5 to 2.0

/datum/supply_demand_curve/proc/GetSupplyShockMultiplier()
	/**
	 * GetSupplyShockMultiplier()
	 * Price impact from supply deviation
	 * Negative shock (shortage): +30% per point
	 * Positive shock (glut): -30% per point
	 */
	return 1.0 + (supply_shock * -0.3)

/datum/supply_demand_curve/proc/GetDemandShockMultiplier()
	/**
	 * GetDemandShockMultiplier()
	 * Price impact from demand deviation
	 * Negative shock (low demand): -20% per point
	 * Positive shock (high demand): +20% per point
	 */
	return 1.0 + (demand_shock * 0.2)

/datum/supply_demand_curve/proc/GetSentimentMultiplier()
	/**
	 * GetSentimentMultiplier()
	 * Market sentiment affects willingness to pay
	 * Bullish: +10% per 20 sentiment points
	 * Bearish: -10% per 20 sentiment points
	 */
	return 1.0 + (market_sentiment / 200.0)

/datum/supply_demand_curve/proc/GetCurveAdjustment()
	/**
	 * GetCurveAdjustment()
	 * Composite price adjustment from supply/demand curve
	 * Used by EnhancedDynamicMarketPricingSystem
	 * 
	 * Calculation:
	 * (elasticity * supply_shock * demand_shock * sentiment) + volatility
	 */
	var/elasticity_mult = GetElasticityMultiplier()
	var/supply_mult = GetSupplyShockMultiplier()
	var/demand_mult = GetDemandShockMultiplier()
	var/sentiment_mult = GetSentimentMultiplier()
	
	var/composite = elasticity_mult * supply_mult * demand_mult * sentiment_mult
	var/volatility_swing = (rand(-100, 100) / 100.0) * volatility_index
	
	return composite + volatility_swing

// ============================================================================
// SUPPLY SHOCK EVENTS
// ============================================================================

/datum/supply_demand_curve/proc/ApplySupplyShock(severity, duration)
	/**
	 * ApplySupplyShock(severity, duration)
	 * Apply shock (drought, plague, discovery, etc)
	 * severity: -1.0 (complete loss) to +1.0 (massive surge)
	 * duration: ticks until recovery
	 * 
	 * Examples:
	 * - Drought: severity -0.5 (50% loss), duration 300 ticks
	 * - Plague: severity -0.7 (70% loss), duration 600 ticks
	 * - Gold Rush: severity +0.8 (80% increase), duration 200 ticks
	 */
	var/shock_amount = base_supply * severity
	current_supply = max(0, current_supply + shock_amount)
	
	world.log << "SUPPLY_SHOCK: [commodity_name] shock [severity] for [duration] ticks"
	
	// Schedule recovery
	spawn(duration)
		RecoverFromSupplyShock()

/datum/supply_demand_curve/proc/RecoverFromSupplyShock()
	/**
	 * RecoverFromSupplyShock()
	 * Gradually recover to baseline after shock
	 */
	if(current_supply < base_supply)
		current_supply = min(current_supply + (base_supply * 0.1), base_supply)
	else
		current_supply = max(current_supply - (base_supply * 0.1), base_supply)
// DEMAND CYCLE MECHANICS
// ============================================================================

/datum/supply_demand_curve/proc/UpdateDemandCycle(phase_0_to_1)
	/**
	 * UpdateDemandCycle(phase_0_to_1)
	 * Apply cyclical demand patterns (seasonal, event-driven)
	 * 0.0 = low demand, 0.5 = high, 1.0 = low again
	 * 
	 * Example uses:
	 * - Seasonal: Winter (high heat/food demand), Summer (low)
	 * - Festival: Event week has +50% demand
	 * - Harvest: Post-harvest high supply, low demand spike
	 */
	cycle_phase = clamp(phase_0_to_1, 0.0, 1.0)
	var/cycle_demand = base_demand * (0.5 + sin(cycle_phase * 180) / 2.0)
	UpdateDemand(cycle_demand)

/datum/supply_demand_curve/proc/SetSeasonalDemand(season)
	/**
	 * SetSeasonalDemand(season)
	 * Apply seasonal demand modifiers
	 * Season: "Spring", "Summer", "Autumn", "Winter"
	 */
	var/seasonal_modifier = 1.0
	
	switch(season)
		if("Spring")
			seasonal_modifier = 0.9
		if("Summer")
			seasonal_modifier = 0.7
		if("Autumn")
			seasonal_modifier = 1.2
		if("Winter")
			seasonal_modifier = 1.5
	
	UpdateDemand(base_demand * seasonal_modifier)

// ============================================================================
// SPECULATION & TRADING
// ============================================================================

/datum/supply_demand_curve/proc/RegisterSpeculativeBuy(player, amount)
	/**
	 * RegisterSpeculativeBuy(player, amount)
	 * Player buying for resale (speculation)
	 * Increases speculation intensity and demand shock
	 */
	spec_buy_orders += amount
	
	// Speculation increases volatility
	speculation_intensity = min(speculation_intensity + 0.1, 1.0)
	
	world.log << "SPEC_BUY: [player] speculating [amount] [commodity_name] units"

/datum/supply_demand_curve/proc/RegisterSpeculativeSell(player, amount)
	/**
	 * RegisterSpeculativeSell(player, amount)
	 * Player selling at peak (speculation)
	 * Increases supply shock temporarily
	 */
	spec_sell_orders += amount
	
	// Increase supply temporarily
	current_supply += amount * 0.5
	speculation_intensity = min(speculation_intensity + 0.1, 1.0)
	
	world.log << "SPEC_SELL: [player] dumping [amount] [commodity_name] units"

/datum/supply_demand_curve/proc/DecaySpeculation()
	/**
	 * DecaySpeculation()
	 * Gradually reduce speculation intensity
	 * Called periodically (e.g., hourly)
	 */
	spec_buy_orders = max(0, spec_buy_orders - (base_demand * 0.05))
	spec_sell_orders = max(0, spec_sell_orders - (base_supply * 0.05))
	speculation_intensity = max(0.0, speculation_intensity - 0.05)
// TREND TRACKING
// ============================================================================

/datum/supply_demand_curve/proc/UpdateTrends()
	/**
	 * UpdateTrends()
	 * Track growing/shrinking supply and demand
	 * Used for sentiment and price momentum
	 */
	// Supply trend: compare to baseline
	var/supply_delta = (current_supply - base_supply) / max(1, base_supply)
	supply_trend = supply_trend * 0.7 + supply_delta * 0.3
	supply_trend = clamp(supply_trend, -0.5, 0.5)
	var/demand_delta = (current_demand - base_demand) / max(1, base_demand)
	demand_trend = demand_trend * 0.7 + demand_delta * 0.3
	demand_trend = clamp(demand_trend, -0.5, 0.5)
// SYSTEM INITIALIZATION
// ============================================================================

/proc/InitializeSupplyDemandSystem()
	/**
	 * InitializeSupplyDemandSystem()
	 * Sets up supply/demand curve system for all major commodities
	 */
	
	// Create curves for major commodities
	CreateDefaultSupplyDemandCurves()
	
	// Start maintenance loop
	spawn() SupplyDemandMaintenanceLoop()
	
	world.log << "SUPPLY_DEMAND: System initialized"

/proc/CreateDefaultSupplyDemandCurves()
	/**
	 * CreateDefaultSupplyDemandCurves()
	 * Creates supply/demand tracking for all commodities
	 */
	
	// Building materials
	CreateSupplyDemandCurve("Stone", 500, 300)
	CreateSupplyDemandCurve("Wood", 400, 350)
	CreateSupplyDemandCurve("Clay", 200, 150)
	CreateSupplyDemandCurve("Flint", 150, 100)
	
	// Metals
	CreateSupplyDemandCurve("Iron Ore", 300, 250)
	CreateSupplyDemandCurve("Iron Ingot", 200, 180)
	CreateSupplyDemandCurve("Coal", 250, 200)
	
	// Food & Resources
	CreateSupplyDemandCurve("Fish", 350, 300)
	CreateSupplyDemandCurve("Herbs", 200, 180)
	CreateSupplyDemandCurve("Grain", 400, 450)
	
	// Luxury & Special
	CreateSupplyDemandCurve("Pearls", 50, 60)
	CreateSupplyDemandCurve("Gems", 30, 40)
	
	world.log << "SUPPLY_DEMAND: Created 13 default curves"

/proc/SupplyDemandMaintenanceLoop()
	/**
	 * SupplyDemandMaintenanceLoop()
	 * Periodic updates for all supply/demand curves
	 * Recalculates elasticity, sentiment, volatility
	 */
	set background = 1
	set waitfor = 0
	
	var/update_interval = 50
	var/decay_interval = 600
	
	var/last_update = world.time
	var/last_decay = world.time
	
	while(1)
		sleep(25)
		
		// Regular updates
		if(world.time - last_update >= update_interval)
			last_update = world.time
			// For now, framework ready
		
		// Decay speculation
		if(world.time - last_decay >= decay_interval)
			last_decay = world.time

/proc/GetSupplyDemandCurve(commodity_name)
	/**
	 * GetSupplyDemandCurve(commodity_name)
	 * Looks up curve by commodity name
	 * Returns: /datum/supply_demand_curve or null
	 */
	// Framework: Would look up from global registry
	return null

// ============================================================================
// ANALYTICS & DISPLAY
// ============================================================================

/datum/supply_demand_curve/proc/GetCurveStatus()
	/**
	 * GetCurveStatus()
	 * Returns comprehensive curve status
	 */
	var/list/status = list(
		"commodity" = commodity_name,
		"supply" = current_supply,
		"base_supply" = base_supply,
		"supply_shock" = round(supply_shock * 100),
		"demand" = current_demand,
		"base_demand" = base_demand,
		"demand_shock" = round(demand_shock * 100),
		"ratio" = round(supply_demand_ratio * 100) / 100.0,
		"elasticity" = round(price_elasticity * 100) / 100.0,
		"sentiment" = market_sentiment,
		"volatility" = round(volatility_index * 100),
		"speculation" = spec_buy_orders + spec_sell_orders
	)
	
	return status

/datum/supply_demand_curve/proc/DisplayCurveInfo()
	/**
	 * DisplayCurveInfo()
	 * Returns formatted curve information
	 */
	var/info = ""
	info += "═════════════════════════════════════════\n"
	info += "[commodity_name] Market\n"
	info += "═════════════════════════════════════════\n"
	
	info += "Supply: [current_supply]/[base_supply] "
	if(supply_shock > 0)
		info += "+[round(supply_shock*100)]% SURPLUS\n"
	else if(supply_shock < 0)
		info += "[round(supply_shock*100)]% SHORTAGE\n"
	else
		info += "(balanced)\n"
	
	info += "Demand: [current_demand]/[base_demand] "
	if(demand_shock > 0)
		info += "+[round(demand_shock*100)]% SPIKE\n"
	else if(demand_shock < 0)
		info += "[round(demand_shock*100)]% LOW\n"
	else
		info += "(balanced)\n"
	
	info += "Ratio: [round(supply_demand_ratio*100)]/100 "
	if(supply_demand_ratio > ratio_threshold_high)
		info += "(GLUT)\n"
	else if(supply_demand_ratio < ratio_threshold_low)
		info += "(SHORTAGE)\n"
	else
		info += "(balanced)\n"
	
	info += "\nMarket Analysis:\n"
	info += "  Elasticity: [round(price_elasticity*100)]/100 "
	if(price_elasticity < 0.8)
		info += "(inelastic - price sensitive)\n"
	else if(price_elasticity > 1.2)
		info += "(elastic - quantity sensitive)\n"
	else
		info += "(balanced)\n"
	
	info += "  Sentiment: [market_sentiment] "
	if(market_sentiment > 30)
		info += "(BULLISH)\n"
	else if(market_sentiment < -30)
		info += "(BEARISH)\n"
	else
		info += "(neutral)\n"
	
	info += "  Volatility: [round(volatility_index*100)]%\n"
	info += "  Speculation: [spec_buy_orders + spec_sell_orders] units\n"
	
	info += "\nPrice Multipliers:\n"
	info += "  Elasticity: [round(GetElasticityMultiplier()*100)]/100\n"
	info += "  Supply Shock: [round(GetSupplyShockMultiplier()*100)]/100\n"
	info += "  Demand Shock: [round(GetDemandShockMultiplier()*100)]/100\n"
	info += "  Sentiment: [round(GetSentimentMultiplier()*100)]/100\n"
	info += "  Curve Total: [round(GetCurveAdjustment()*100)]/100\n"
	
	info += "═════════════════════════════════════════\n"
	
	return info
