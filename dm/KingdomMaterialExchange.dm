// KingdomMaterialExchange.dm - Kingdom Material Trading Market UI & Management
// Enables kingdom-to-kingdom material trading with offer/counter-offer system
// Tracks trade history, pricing, and supply/demand dynamics

// ============================================================================
// KINGDOM MATERIAL EXCHANGE DATUM
// ============================================================================

/datum/kingdom_trade_offer
	/**
	 * kingdom_trade_offer
	 * Represents a pending or completed trade between two kingdoms
	 */
	var
		offering_kingdom = null         // Kingdom making the offer
		requesting_kingdom = null       // Kingdom receiving offer
		
		// Offered materials
		offering_stone = 0
		offering_metal = 0
		offering_timber = 0
		offering_lucre = 0
		
		// Requested materials
		requesting_stone = 0
		requesting_metal = 0
		requesting_timber = 0
		requesting_lucre = 0
		
		// Trade metadata
		created_time = 0                // When offer was made
		expires_time = 0                // When offer expires (600 ticks = 10 minutes)
		accepted_by = null              // Which kingdom accepted (if any)
		completed = 0                   // 1 if trade executed
		completion_time = 0             // When completed
		status = "pending"              // pending, accepted, rejected, completed, expired
		
		// Trade notes
		offer_notes = ""                // Why the offer was made
		negotiation_counter = 0         // How many counter-offers made
		
		// Validation
		offer_id = 0                    // Unique ID for tracking
		observer_list = list()          // Kingdoms watching this trade

/datum/kingdom_treasury_manager
	/**
	 * kingdom_treasury_manager
	 * Manages per-kingdom material resources and trading restrictions
	 */
	var
		kingdom_name = "Unaffiliated"
		
		// Current treasury
		stone_treasury = 0
		metal_treasury = 0
		timber_treasury = 0
		lucre_treasury = 0
		
		// Trading history
		list/completed_trades = list()  // Historical trades with timestamps
		list/pending_offers = list()    // Active trade offers
		
		// Trade restrictions & cooldowns
		last_trade_time = 0             // Cooldown between trades
		trades_per_day = 0              // Counter for daily trade limit
		last_day_reset = 0              // When counter was last reset
		trade_reputation = 100          // Starts at 100 (affects trade success)
		
		// Supply tracking
		daily_stone_produced = 0
		daily_metal_produced = 0
		daily_timber_produced = 0
		
		// Demand tracking
		daily_stone_consumed = 0
		daily_metal_consumed = 0
		daily_timber_consumed = 0

/datum/market_price_tracker
	/**
	 * market_price_tracker
	 * Tracks market prices dynamically based on supply/demand
	 */
	var
		// Base prices (in lucre equivalents)
		stone_price = 1.0
		metal_price = 3.0
		timber_price = 2.5
		
		// Price history (for trend analysis)
		list/stone_price_history = list()
		list/metal_price_history = list()
		list/timber_price_history = list()
		
		// Market trends
		stone_volatility = 0.1          // How much price varies
		metal_volatility = 0.15
		timber_volatility = 0.12
		
		// Global supply/demand
		total_stone_on_market = 0
		total_metal_on_market = 0
		total_timber_on_market = 0

// ============================================================================
// GLOBAL KINGDOM TRADING SYSTEM
// ============================================================================

var
	global/list/kingdom_treasuries = list()
	global/list/active_trade_offers = list()
	global/trade_offer_counter = 0
	global/datum/market_price_tracker/market_prices = null

/proc/InitializeKingdomMaterialExchange()
	/**
	 * InitializeKingdomMaterialExchange()
	 * Sets up kingdom trading system on world boot
	 */
	market_prices = new /datum/market_price_tracker()
	
	// Initialize default kingdoms (can be expanded)
	var/list/default_kingdoms = list("Kingdom A", "Kingdom B", "Kingdom C", "Kingdom D")
	for(var/k in default_kingdoms)
		CreateKingdomTreasury(k)

/proc/CreateKingdomTreasury(kingdom_name)
	/**
	 * CreateKingdomTreasury(kingdom_name)
	 * Creates treasury manager for new kingdom
	 */
	var/datum/kingdom_treasury_manager/tm = new()
	tm.kingdom_name = kingdom_name
	tm.stone_treasury = 500   // Starting resources
	tm.metal_treasury = 200
	tm.timber_treasury = 300
	tm.lucre_treasury = 1000
	
	kingdom_treasuries[kingdom_name] = tm
	return tm

/proc/GetKingdomTreasury(kingdom_name)
	/**
	 * GetKingdomTreasury(kingdom_name)
	 * Retrieves treasury manager for kingdom
	 */
	if(!kingdom_treasuries[kingdom_name])
		return CreateKingdomTreasury(kingdom_name)
	return kingdom_treasuries[kingdom_name]

/proc/InitiateKingdomTradeOffer(kingdom_a, kingdom_b, offered_list, requested_list, notes = "")
	/**
	 * InitiateKingdomTradeOffer(kingdom_a, kingdom_b, offered_list, requested_list, notes)
	 * Creates a new trade offer between kingdoms
	 * offered_list: list(list("stone", 50), list("metal", 20)) format
	 * Returns: trade_offer datum if created, null if failed
	 */
	var/datum/kingdom_treasury_manager/a_treasury = GetKingdomTreasury(kingdom_a)
	var/datum/kingdom_treasury_manager/b_treasury = GetKingdomTreasury(kingdom_b)
	
	if(!a_treasury || !b_treasury) return null
	
	// Validate kingdom A has offered resources
	for(var/O in offered_list)
		var/resource = O[1]
		var/amount = O[2]
		
		switch(resource)
			if("stone")
				if(a_treasury.stone_treasury < amount)
					return null  // Not enough stone
			if("metal")
				if(a_treasury.metal_treasury < amount)
					return null
			if("timber")
				if(a_treasury.timber_treasury < amount)
					return null
			if("lucre")
				if(a_treasury.lucre_treasury < amount)
					return null
	
	// Create trade offer
	var/datum/kingdom_trade_offer/offer = new()
	trade_offer_counter++
	offer.offer_id = trade_offer_counter
	offer.offering_kingdom = kingdom_a
	offer.requesting_kingdom = kingdom_b
	offer.created_time = world.time
	offer.expires_time = world.time + 600  // 10 minute expiration
	offer.offer_notes = notes
	offer.status = "pending"
	
	// Populate offered resources
	for(var/O in offered_list)
		var/resource = O[1]
		var/amount = O[2]
		
		switch(resource)
			if("stone")
				offer.offering_stone = amount
			if("metal")
				offer.offering_metal = amount
			if("timber")
				offer.offering_timber = amount
			if("lucre")
				offer.offering_lucre = amount
	
	// Populate requested resources
	for(var/R in requested_list)
		var/resource = R[1]
		var/amount = R[2]
		
		switch(resource)
			if("stone")
				offer.requesting_stone = amount
			if("metal")
				offer.requesting_metal = amount
			if("timber")
				offer.requesting_timber = amount
			if("lucre")
				offer.requesting_lucre = amount
	
	// Add to active offers
	active_trade_offers[offer.offer_id] = offer
	a_treasury.pending_offers += offer
	b_treasury.pending_offers += offer
	
	world.log << "KINGDOM_TRADE: [kingdom_a] offered trade to [kingdom_b] (ID: [offer.offer_id])"
	
	return offer

/proc/CounterKingdomTradeOffer(offer_id, countering_kingdom, new_offered_list, new_requested_list)
	/**
	 * CounterKingdomTradeOffer(offer_id, countering_kingdom, new_offered_list, new_requested_list)
	 * Counters an existing trade offer with modified terms
	 * Swaps who is offering vs requesting
	 */
	var/datum/kingdom_trade_offer/original_offer = active_trade_offers[offer_id]
	if(!original_offer) return null
	
	// Validate countering kingdom is involved
	if((countering_kingdom != original_offer.offering_kingdom) && (countering_kingdom != original_offer.requesting_kingdom))
		return null
	
	// Determine counter direction
	var/counter_from = countering_kingdom
	var/counter_to = null
	if(countering_kingdom == original_offer.offering_kingdom)
		counter_to = original_offer.requesting_kingdom
	else
		counter_to = original_offer.offering_kingdom
	
	// Create new counter-offer
	var/counter_offer = InitiateKingdomTradeOffer(counter_from, counter_to, 
		new_offered_list, new_requested_list, 
		"Counter to offer #[offer_id]")
	
	if(counter_offer)
		original_offer.negotiation_counter++
		original_offer.status = "countered"
		world.log << "KINGDOM_TRADE: [counter_from] countered offer #[offer_id]"
	
	return counter_offer

/proc/AcceptKingdomTradeOffer(offer_id, accepting_kingdom)
	/**
	 * AcceptKingdomTradeOffer(offer_id, accepting_kingdom)
	 * Accepts a trade offer and executes the material exchange
	 * Returns: 1 if successful, 0 if failed
	 */
	var/datum/kingdom_trade_offer/offer = active_trade_offers[offer_id]
	if(!offer) return 0
	
	// Validate accepting kingdom is the recipient
	if(accepting_kingdom != offer.requesting_kingdom)
		return 0
	
	// Check expiration
	if(world.time > offer.expires_time)
		offer.status = "expired"
		return 0
	
	// Validate accepting kingdom has requested resources
	var/datum/kingdom_treasury_manager/b_treasury = GetKingdomTreasury(offer.requesting_kingdom)
	if(!b_treasury) return 0
	
	if(b_treasury.stone_treasury < offer.requesting_stone) return 0
	if(b_treasury.metal_treasury < offer.requesting_metal) return 0
	if(b_treasury.timber_treasury < offer.requesting_timber) return 0
	if(b_treasury.lucre_treasury < offer.requesting_lucre) return 0
	
	// Get offering kingdom treasury
	var/datum/kingdom_treasury_manager/a_treasury = GetKingdomTreasury(offer.offering_kingdom)
	if(!a_treasury) return 0
	
	// Execute exchange
	// Kingdom A gives what they offered
	a_treasury.stone_treasury -= offer.offering_stone
	a_treasury.metal_treasury -= offer.offering_metal
	a_treasury.timber_treasury -= offer.offering_timber
	a_treasury.lucre_treasury -= offer.offering_lucre
	
	// Kingdom B gives what they were requested to give
	b_treasury.stone_treasury -= offer.requesting_stone
	b_treasury.metal_treasury -= offer.requesting_metal
	b_treasury.timber_treasury -= offer.requesting_timber
	b_treasury.lucre_treasury -= offer.requesting_lucre
	
	// Exchange completes
	a_treasury.stone_treasury += offer.requesting_stone
	a_treasury.metal_treasury += offer.requesting_metal
	a_treasury.timber_treasury += offer.requesting_timber
	a_treasury.lucre_treasury += offer.requesting_lucre
	
	b_treasury.stone_treasury += offer.offering_stone
	b_treasury.metal_treasury += offer.offering_metal
	b_treasury.timber_treasury += offer.offering_timber
	b_treasury.lucre_treasury += offer.offering_lucre
	
	// Mark as completed
	offer.status = "completed"
	offer.accepted_by = accepting_kingdom
	offer.completion_time = world.time
	offer.negotiation_counter = 0  // Reset counter on completion
	
	// Add to completed trades
	a_treasury.completed_trades += offer
	b_treasury.completed_trades += offer
	
	// Update market supply tracking
	UpdateMarketSupplyFromTrade(offer)
	
	world.log << "KINGDOM_TRADE: [offer.offering_kingdom] and [offer.requesting_kingdom] completed trade #[offer_id]"
	
	return 1

/proc/RejectKingdomTradeOffer(offer_id, rejecting_kingdom)
	/**
	 * RejectKingdomTradeOffer(offer_id, rejecting_kingdom)
	 * Rejects a pending trade offer
	 */
	var/datum/kingdom_trade_offer/offer = active_trade_offers[offer_id]
	if(!offer) return 0
	
	// Validate rejecting kingdom is involved
	if((rejecting_kingdom != offer.offering_kingdom) && (rejecting_kingdom != offer.requesting_kingdom))
		return 0
	
	offer.status = "rejected"
	
	// Remove from pending lists
	var/datum/kingdom_treasury_manager/a_treasury = GetKingdomTreasury(offer.offering_kingdom)
	var/datum/kingdom_treasury_manager/b_treasury = GetKingdomTreasury(offer.requesting_kingdom)
	
	if(a_treasury) a_treasury.pending_offers -= offer
	if(b_treasury) b_treasury.pending_offers -= offer
	
	world.log << "KINGDOM_TRADE: [rejecting_kingdom] rejected offer #[offer_id]"
	return 1

/proc/GetKingdomTradeHistory(kingdom_name, limit = 20)
	/**
	 * GetKingdomTradeHistory(kingdom_name, limit)
	 * Returns list of completed trades for a kingdom
	 */
	var/datum/kingdom_treasury_manager/tm = GetKingdomTreasury(kingdom_name)
	if(!tm) return list()
	
	var/list/history = list()
	var/count = 0
	for(var/i = tm.completed_trades.len to 1 step -1)
		if(count >= limit) break
		history += tm.completed_trades[i]
		count++
	
	return history

/proc/GetKingdomPendingOffers(kingdom_name)
	/**
	 * GetKingdomPendingOffers(kingdom_name)
	 * Returns list of active trade offers for a kingdom
	 */
	var/datum/kingdom_treasury_manager/tm = GetKingdomTreasury(kingdom_name)
	if(!tm) return list()
	
	return tm.pending_offers

/proc/UpdateMarketSupplyFromTrade(datum/kingdom_trade_offer/offer)
	/**
	 * UpdateMarketSupplyFromTrade(offer)
	 * Updates global market supply/demand based on completed trade
	 * Affects future market prices dynamically
	 */
	if(!market_prices) return
	
	// Increase total on market for what was given
	market_prices.total_stone_on_market += offer.offering_stone
	market_prices.total_metal_on_market += offer.offering_metal
	market_prices.total_timber_on_market += offer.offering_timber
	
	// Decrease for what was received (removed from supply)
	market_prices.total_stone_on_market -= offer.requesting_stone
	market_prices.total_metal_on_market -= offer.requesting_metal
	market_prices.total_timber_on_market -= offer.requesting_timber
	
	// TODO: Adjust prices based on supply changes
	AdjustMarketPricesFromSupply()

/proc/AdjustMarketPricesFromSupply()
	/**
	 * AdjustMarketPricesFromSupply()
	 * Adjusts market prices based on global supply/demand
	 * More supply = lower prices, less supply = higher prices
	 */
	if(!market_prices) return
	
	// Base supply threshold (when prices are at base level)
	var/base_supply = 10000
	
	// Stone price adjustment
	var/stone_ratio = market_prices.total_stone_on_market / base_supply
	market_prices.stone_price = 1.0 * (2.0 - stone_ratio)  // Inverse relationship
	market_prices.stone_price = max(0.5, min(2.5, market_prices.stone_price))  // Clamp price
	
	// Metal price adjustment
	var/metal_ratio = market_prices.total_metal_on_market / base_supply
	market_prices.metal_price = 3.0 * (2.0 - metal_ratio)
	market_prices.metal_price = max(1.5, min(5.0, market_prices.metal_price))
	
	// Timber price adjustment
	var/timber_ratio = market_prices.total_timber_on_market / base_supply
	market_prices.timber_price = 2.5 * (2.0 - timber_ratio)
	market_prices.timber_price = max(1.0, min(4.0, market_prices.timber_price))

/proc/GetMarketPrices()
	/**
	 * GetMarketPrices()
	 * Returns current market prices
	 */
	if(!market_prices)
		market_prices = new /datum/market_price_tracker()
	return market_prices

/proc/GetKingdomNetWorth(kingdom_name)
	/**
	 * GetKingdomNetWorth(kingdom_name)
	 * Calculates total kingdom wealth in lucre equivalents
	 */
	var/datum/kingdom_treasury_manager/tm = GetKingdomTreasury(kingdom_name)
	if(!tm) return 0
	
	var/datum/market_price_tracker/prices = GetMarketPrices()
	var/total = tm.lucre_treasury
	
	total += tm.stone_treasury * prices.stone_price
	total += tm.metal_treasury * prices.metal_price
	total += tm.timber_treasury * prices.timber_price
	
	return total

/proc/GetKingdomTreasuryStatus(kingdom_name)
	/**
	 * GetKingdomTreasuryStatus(kingdom_name)
	 * Returns detailed status report of kingdom treasury
	 */
	var/datum/kingdom_treasury_manager/tm = GetKingdomTreasury(kingdom_name)
	if(!tm) return null
	
	var/datum/market_price_tracker/prices = GetMarketPrices()
	var/net_worth = GetKingdomNetWorth(kingdom_name)
	
	var/report = list(
		"kingdom" = tm.kingdom_name,
		"stone" = tm.stone_treasury,
		"metal" = tm.metal_treasury,
		"timber" = tm.timber_treasury,
		"lucre" = tm.lucre_treasury,
		"net_worth" = net_worth,
		"pending_offers" = tm.pending_offers.len,
		"completed_trades" = tm.completed_trades.len,
		"reputation" = tm.trade_reputation,
		"market_prices" = list(
			"stone" = round(prices.stone_price, 0.01),
			"metal" = round(prices.metal_price, 0.01),
			"timber" = round(prices.timber_price, 0.01)
		)
	)
	
	return report

/proc/ExpireOldTradeOffers()
	/**
	 * ExpireOldTradeOffers()
	 * Marks expired offers as expired (called periodically)
	 * Remove offers from pending lists after 10 minutes
	 */
	for(var/offer_id in active_trade_offers)
		var/datum/kingdom_trade_offer/offer = active_trade_offers[offer_id]
		
		if(world.time > offer.expires_time && offer.status == "pending")
			offer.status = "expired"
			
			// Remove from pending lists
			var/datum/kingdom_treasury_manager/a_treasury = GetKingdomTreasury(offer.offering_kingdom)
			var/datum/kingdom_treasury_manager/b_treasury = GetKingdomTreasury(offer.requesting_kingdom)
			
			if(a_treasury) a_treasury.pending_offers -= offer
			if(b_treasury) b_treasury.pending_offers -= offer

