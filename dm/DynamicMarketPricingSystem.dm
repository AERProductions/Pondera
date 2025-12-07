// DynamicMarketPricingSystem.dm - Supply/Demand Economics for Game Economy
// Adjusts material and item prices based on global supply/demand dynamics
// Integrates with kingdom trading and market transactions

// ============================================================================
// MARKET PRICE DATUM
// ============================================================================

/datum/market_commodity
	/**
	 * market_commodity
	 * Represents a tradeable commodity with dynamic pricing
	 */
	var
		commodity_name = "Unknown"
		commodity_type = "material"     // material, weapon, armor, tool, ingredient
		base_price = 1.0                // Starting price in lucre
		current_price = 1.0             // What it costs now
		
		// Supply/demand tracking
		current_supply = 0              // Amount available on market
		current_demand = 0              // How much players want
		supply_history = list()         // Last 24 prices for trends
		price_history = list()          // Track price changes
		
		// Market dynamics
		price_elasticity = 1.0          // How sensitive to supply changes (0.5-2.0)
		price_volatility = 0.1          // How much price can swing (0.05-0.5)
		min_price = 0.5                 // Floor price (can't go below)
		max_price = 10.0                // Ceiling price (can't go above)
		
		// Tech tree tier (affects base price)
		tech_tier = 1                   // 1=foundational, 5=advanced
		craft_difficulty = 1            // 1-10 scale
		
		// Trading restrictions
		tradable = 1                    // Can be traded between players
		kingdom_tradable = 1            // Can kingdoms trade this?
		sellable = 1                    // Can sell to NPCs?
		
		// Economics
		creation_cost = 0               // How much it costs to make
		creation_time = 0               // How long to craft
		consumption_rate = 0            // How fast players use it

/datum/market_price_engine
	/**
	 * market_price_engine
	 * Global price calculation and adjustment system
	 */
	var
		list/commodities = list()       // All tracked commodities
		
		// Global economic state
		inflation_rate = 1.0            // Global price multiplier (1.0 = normal)
		deflation_rate = 1.0            // Global price reduction
		economic_event = null           // Current event affecting market (war, plague, etc.)
		
		// Market trends
		list/price_trends = list()      // Items rising/falling in price
		list/supply_trends = list()     // Items with increasing/decreasing supply
		
		// Thresholds for price changes
		supply_surplus_threshold = 1.5  // Supply 1.5x demand = price drops
		supply_shortage_threshold = 0.7 // Supply 0.7x demand = price rises
		
		// Market volatility settings
		volatility_multiplier = 1.0     // Global volatility control
		update_interval = 100           // Ticks between price updates
		last_update = 0

/datum/market_transaction_record
	/**
	 * market_transaction_record
	 * Records historical market transactions for analysis
	 */
	var
		transaction_id = 0
		commodity_name = ""
		quantity = 0
		price_per_unit = 0
		total_value = 0
		timestamp = 0
		buyer = ""
		seller = ""
		transaction_type = "trade"      // trade, npc_sell, npc_buy, kingdom_trade
		market_conditions = ""          // Description of market state at time

// ============================================================================
// GLOBAL MARKET ENGINE
// ============================================================================

var
	global/datum/market_price_engine/market_engine = null
	global/list/market_commodities = list()
	global/list/market_transactions = list()
	global/market_transaction_counter = 0

/proc/InitializeDynamicMarketPricingSystem()
	/**
	 * InitializeDynamicMarketPricingSystem()
	 * Sets up dynamic pricing system on world boot
	 */
	market_engine = new /datum/market_price_engine()
	
	// Create base commodities (from tech tree foundational -> advanced)
	InitializeBaseCommodities()
	
	// Start market update loop
	spawn() MarketUpdateLoop()
	
	world.log << "MARKET_ENGINE: Dynamic pricing system initialized"

/proc/InitializeBaseCommodities()
	/**
	 * InitializeBaseCommodities()
	 * Creates all base commodities for the game economy
	 * Based on Pondera tech tree tiers
	 */
	if(!market_engine) return
	
	// FOUNDATIONAL TIER (Tier 1) - Basic gathering resources
	CreateCommodity("Stone", "material", 1.0, 1, 0.8)
	CreateCommodity("Wood", "material", 1.0, 1, 0.8)
	CreateCommodity("Flint", "material", 1.5, 1, 0.7)
	CreateCommodity("Clay", "material", 1.2, 1, 0.75)
	CreateCommodity("Obsidian", "material", 2.0, 1, 0.6)
	
	// EARLY INTERMEDIATE (Tier 2) - Processed materials
	CreateCommodity("Iron Ore", "material", 3.0, 2, 1.0)
	CreateCommodity("Bronze Ingot", "material", 4.0, 2, 1.0)
	CreateCommodity("Copper Ingot", "material", 3.5, 2, 1.0)
	CreateCommodity("Charcoal", "material", 1.5, 2, 0.9)
	CreateCommodity("Tar", "material", 2.0, 2, 0.8)
	
	// INTERMEDIATE TOOLS (Tier 2) - Basic tools
	CreateCommodity("Wooden Hammer", "tool", 5.0, 2, 0.6)
	CreateCommodity("Stone Hammer", "tool", 6.0, 2, 0.5)
	CreateCommodity("Wooden Hoe", "tool", 4.0, 2, 0.6)
	CreateCommodity("Stone Pickaxe", "tool", 7.0, 2, 0.5)
	CreateCommodity("Knife Blade", "tool", 8.0, 2, 0.5)
	
	// ADVANCED MATERIALS (Tier 3) - Refined metals
	CreateCommodity("Iron Ingot", "material", 5.0, 3, 1.2)
	CreateCommodity("Steel Ingot", "material", 8.0, 3, 1.1)
	CreateCommodity("Brass Ingot", "material", 6.0, 3, 1.0)
	CreateCommodity("Activated Carbon", "material", 4.0, 3, 0.8)
	CreateCommodity("Glass", "material", 5.5, 3, 0.9)
	
	// ADVANCED TOOLS (Tier 3)
	CreateCommodity("Iron Hammer", "tool", 12.0, 3, 0.7)
	CreateCommodity("Iron Pickaxe", "tool", 15.0, 3, 0.6)
	CreateCommodity("Steel Sword", "tool", 18.0, 3, 0.5)
	CreateCommodity("Carving Knife", "tool", 10.0, 3, 0.6)
	
	// WEAPONS (Tier 4)
	CreateCommodity("Iron Sword", "weapon", 20.0, 4, 0.6)
	CreateCommodity("Bronze Sword", "weapon", 18.0, 4, 0.6)
	CreateCommodity("Steel Lamp Head", "weapon", 15.0, 4, 0.7)
	CreateCommodity("Battle Axe", "weapon", 25.0, 4, 0.5)
	CreateCommodity("War Hammer", "weapon", 28.0, 4, 0.4)
	
	// ADVANCED WEAPONS (Tier 5)
	CreateCommodity("Long Sword", "weapon", 35.0, 5, 0.4)
	CreateCommodity("War Axe", "weapon", 40.0, 5, 0.3)
	CreateCommodity("War Maul", "weapon", 45.0, 5, 0.3)
	CreateCommodity("Battle Scythe", "weapon", 42.0, 5, 0.3)
	
	// ARMOR (Tier 4-5)
	CreateCommodity("Iron Armor", "armor", 30.0, 4, 0.5)
	CreateCommodity("Steel Armor", "armor", 45.0, 5, 0.4)
	CreateCommodity("War Armor", "armor", 60.0, 5, 0.3)
	
	world.log << "MARKET_ENGINE: Initialized [market_engine.commodities.len] base commodities"

/proc/CreateCommodity(name, type, base_price, tier, elasticity)
	/**
	 * CreateCommodity(name, type, base_price, tier, elasticity)
	 * Creates a new commodity with initial pricing
	 */
	if(!market_engine) return null
	
	var/datum/market_commodity/commodity = new()
	commodity.commodity_name = name
	commodity.commodity_type = type
	commodity.base_price = base_price
	commodity.current_price = base_price
	commodity.tech_tier = tier
	commodity.price_elasticity = elasticity
	commodity.craft_difficulty = tier  // Difficulty scales with tier
	
	// Initialize supply based on tier (foundational more abundant)
	var/base_supply = 100 * (6 - tier)  // Tier 1 = 500, Tier 5 = 100
	commodity.current_supply = base_supply
	commodity.current_demand = base_supply * 0.8  // Demand starts at 80% of supply
	
	market_engine.commodities[name] = commodity
	market_commodities[name] = commodity
	
	return commodity

/proc/GetCommodityPrice(commodity_name)
	/**
	 * GetCommodityPrice(commodity_name)
	 * Gets current market price for a commodity
	 * Returns: price or 0 if not found
	 */
	if(!market_engine) return 0
	
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return 0
	
	return commodity.current_price

/proc/UpdateCommoditySupply(commodity_name, amount_change)
	/**
	 * UpdateCommoditySupply(commodity_name, amount_change)
	 * Adjusts supply of a commodity (positive = more supply, negative = less)
	 * Triggers price recalculation
	 */
	if(!market_engine) return
	
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return
	
	commodity.current_supply += amount_change
	commodity.current_supply = max(0, commodity.current_supply)  // Can't be negative
	
	// Trigger price update
	RecalculateCommodityPrice(commodity_name)

/proc/UpdateCommodityDemand(commodity_name, amount_change)
	/**
	 * UpdateCommodityDemand(commodity_name, amount_change)
	 * Adjusts demand for a commodity
	 * Positive = more demand, negative = less demand
	 */
	if(!market_engine) return
	
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return
	
	commodity.current_demand += amount_change
	commodity.current_demand = max(0, commodity.current_demand)
	
	// Trigger price update
	RecalculateCommodityPrice(commodity_name)

/proc/RecalculateCommodityPrice(commodity_name)
	/**
	 * RecalculateCommodityPrice(commodity_name)
	 * Recalculates price based on current supply/demand
	 */
	if(!market_engine) return
	
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return
	
	var/old_price = commodity.current_price
	
	// Calculate supply/demand ratio
	var/supply_ratio = 1.0
	if(commodity.current_demand > 0)
		supply_ratio = commodity.current_supply / commodity.current_demand
	
	// Price adjustment based on ratio
	var/price_multiplier = 1.0
	
	if(supply_ratio > market_engine.supply_surplus_threshold)
		// Surplus: price drops
		price_multiplier = 0.95 - ((supply_ratio - market_engine.supply_surplus_threshold) * 0.05 * commodity.price_elasticity)
	else if(supply_ratio < market_engine.supply_shortage_threshold)
		// Shortage: price rises
		price_multiplier = 1.05 + ((market_engine.supply_shortage_threshold - supply_ratio) * 0.08 * commodity.price_elasticity)
	
	// Apply global economic multipliers
	price_multiplier *= market_engine.inflation_rate
	price_multiplier *= market_engine.deflation_rate
	
	// Add volatility (random fluctuation)
	var/volatility = (rand(-10, 10) / 100.0) * commodity.price_volatility * market_engine.volatility_multiplier
	price_multiplier += volatility
	
	// Calculate new price
	var/new_price = commodity.base_price * price_multiplier
	
	// Clamp price to min/max
	new_price = max(commodity.min_price, min(commodity.max_price, new_price))
	
	commodity.current_price = new_price
	
	// Record price history (keep last 50 prices)
	commodity.price_history += new_price
	var/hist_len = length(commodity.price_history)
	if(hist_len > 50)
		var/list/new_history = list()
		for(var/i = 2 to hist_len)
			new_history += commodity.price_history[i]
		commodity.price_history = new_history
	
	// Log significant price changes (>20%)
	var/percent_change = abs((new_price - old_price) / old_price) * 100
	if(percent_change > 20)
		world.log << "MARKET_PRICE: [commodity_name] changed [percent_change]% (old: [old_price], new: [new_price])"

/proc/GetCommodityTrend(commodity_name)
	/**
	 * GetCommodityTrend(commodity_name)
	 * Returns price trend for a commodity
	 * Returns: "rising", "falling", or "stable"
	 */
	if(!market_engine) return "stable"
	
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	var/hist_len = length(commodity.price_history)
	
	if(!commodity || hist_len < 2) return "stable"
	
	var/current = commodity.price_history[hist_len]
	var/previous = commodity.price_history[max(1, hist_len - 1)]
	
	var/change = current - previous
	
	if(abs(change) < 0.01) return "stable"
	if(change > 0) return "rising"
	return "falling"

/proc/GetMarketSupplyDemandStatus()
	/**
	 * GetMarketSupplyDemandStatus()
	 * Returns overall market status report
	 */
	if(!market_engine) return null
	
	var/total_supply = 0
	var/total_demand = 0
	var/rising_prices = 0
	var/falling_prices = 0
	
	for(var/commodity_name in market_engine.commodities)
		var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
		total_supply += commodity.current_supply
		total_demand += commodity.current_demand
		
		var/trend = GetCommodityTrend(commodity_name)
		if(trend == "rising")
			rising_prices++
		else if(trend == "falling")
			falling_prices++
	
	var/status = list(
		"total_commodities" = market_engine.commodities.len,
		"total_supply" = total_supply,
		"total_demand" = total_demand,
		"rising_prices" = rising_prices,
		"falling_prices" = falling_prices,
		"inflation_rate" = market_engine.inflation_rate,
		"deflation_rate" = market_engine.deflation_rate,
		"overall_trend" = (rising_prices > falling_prices) ? "inflation" : "deflation"
	)
	
	return status

/proc/MarketUpdateLoop()
	/**
	 * MarketUpdateLoop()
	 * Continuously updates all market prices
	 * Runs as background process
	 */
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(market_engine.update_interval)
		
		if(!market_engine) continue
		
		// Update all commodity prices
		for(var/commodity_name in market_engine.commodities)
			RecalculateCommodityPrice(commodity_name)
		
		market_engine.last_update = world.time

/proc/GetPriceHistory(commodity_name, num_points = 20)
	/**
	 * GetPriceHistory(commodity_name, num_points)
	 * Returns last N price points for graphing/analysis
	 */
	if(!market_engine) return list()
	
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return list()
	
	var/list/history = list()
	var/hist_len = length(commodity.price_history)
	var/start_index = max(1, hist_len - num_points + 1)
	
	for(var/i = start_index to hist_len)
		history += commodity.price_history[i]
	
	return history

/proc/ApplyEconomicEvent(event_name, price_multiplier, duration_ticks = 3000)
	/**
	 * ApplyEconomicEvent(event_name, price_multiplier, duration_ticks)
	 * Applies a global economic event (war, famine, treasure discovery, etc.)
	 * Multiplier: >1 = inflation, <1 = deflation
	 */
	if(!market_engine) return
	
	market_engine.economic_event = event_name
	market_engine.inflation_rate = price_multiplier
	
	world.log << "MARKET_EVENT: [event_name] applied (multiplier: [price_multiplier], duration: [duration_ticks] ticks)"
	
	// Schedule event removal
	spawn(duration_ticks)
		if(market_engine)
			market_engine.economic_event = null
			market_engine.inflation_rate = 1.0
			world.log << "MARKET_EVENT: [event_name] ended"

/proc/CalculateTransactionPrice(commodity_name, quantity)
	/**
	 * CalculateTransactionPrice(commodity_name, quantity)
	 * Calculates total price for a transaction
	 * Accounts for bulk pricing (quantity discounts)
	 * Returns: total price
	 */
	var/unit_price = GetCommodityPrice(commodity_name)
	if(unit_price <= 0) return 0
	
	var/total = unit_price * quantity
	
	// Bulk discount (every 10 units = 1% discount, max 10% discount)
	var/bulk_discount = min(0.10, (quantity / 10) * 0.01)
	total *= (1.0 - bulk_discount)
	
	return round(total, 0.01)

/proc/RecordMarketTransaction(commodity_name, quantity, price_per_unit, buyer, seller, type = "trade")
	/**
	 * RecordMarketTransaction(commodity_name, quantity, price_per_unit, buyer, seller, type)
	 * Records a transaction for market analytics
	 */
	var/datum/market_transaction_record/record = new()
	market_transaction_counter++
	
	record.transaction_id = market_transaction_counter
	record.commodity_name = commodity_name
	record.quantity = quantity
	record.price_per_unit = price_per_unit
	record.total_value = price_per_unit * quantity
	record.timestamp = world.time
	record.buyer = buyer
	record.seller = seller
	record.transaction_type = type
	
	// Capture market conditions at time of transaction
	var/trend = GetCommodityTrend(commodity_name)
	record.market_conditions = "[trend] prices"
	
	market_transactions += record
	
	// Keep only last 1000 transactions
	if(market_transactions.len > 1000)
		market_transactions.Cut(1, 2)
	
	return record

/proc/GetMarketAnalytics()
	/**
	 * GetMarketAnalytics()
	 * Returns comprehensive market analysis
	 */
	var/list/analytics = list(
		"total_transactions" = market_transactions.len,
		"commodities_tracked" = market_engine.commodities.len,
		"total_market_value" = 0,
		"price_volatility" = 0,
		"most_expensive" = null
	)
	
	var/max_price = 0
	var/max_expensive = null
	var/total_volatility = 0
	
	for(var/commodity_name in market_engine.commodities)
		var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
		
		// Market value = supply * price
		analytics["total_market_value"] += commodity.current_supply * commodity.current_price
		
		// Track most expensive
		if(commodity.current_price > max_price)
			max_price = commodity.current_price
			max_expensive = commodity_name
		
		// Track volatility
		total_volatility += commodity.price_volatility
	
	analytics["most_expensive"] = max_expensive
	analytics["price_volatility"] = round(total_volatility / market_engine.commodities.len, 0.01)
	analytics["total_market_value"] = round(analytics["total_market_value"], 1)
	
	return analytics

/proc/GetCommoditiesAtPriceRange(min_price, max_price)
	/**
	 * GetCommoditiesAtPriceRange(min_price, max_price)
	 * Returns list of commodities within price range
	 * Useful for filtering market displays
	 */
	var/list/results = list()
	
	for(var/commodity_name in market_engine.commodities)
		var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
		
		if(commodity.current_price >= min_price && commodity.current_price <= max_price)
			results[commodity_name] = commodity.current_price
	
	return results

