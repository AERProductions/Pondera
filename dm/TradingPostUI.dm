/**
 * TradingPostUI.dm
 * Phase 12e: Trading Post Interface
 * 
 * Features:
 * - Player-to-player item trading interface
 * - Merchant stall management (buy/sell stock)
 * - Price history visualization
 * - Offers & negotiations system
 * - Trade completion & verification
 * - Trading post rankings (top traders, volume)
 * 
 * Integration:
 * - Works with DualCurrencySystem.dm
 * - Works with MarketBoardUI.dm
 * - Works with NPCMerchantSystem.dm
 * - Works with InventoryManagementExtensions.dm
 */

// ============================================================================
// TRADING POST INTERFACE DATA
// ============================================================================

/datum/trading_post
	/**
	 * trading_post
	 * Represents a player-managed trading post/stall
	 */
	var
		// Owner info
		stall_owner = null
		owner_name = "Unknown"
		list/buy_offers = list()
		list/sell_stock = list()
		list/active_trades = list()
		
		// Stall stats
		total_trades = 0
		total_volume = 0
		average_rating = 5.0
		markup_percentage = 1.2
		markdown_percentage = 0.8
		
		// Location
		location_x = 0
		location_y = 0
		location_z = 0
		is_open = TRUE
		open_time = 0
		close_time = 0

/datum/stall_trade_offer
	/**
	 * stall_trade_offer
	 * Single trade proposal (buy or sell) at trading post
	 */
	var
		// Offer details
		offer_id = null
		offer_type = "buy"
		
		// Items
		item_name = ""
		item_type = null
		quantity = 0
		unit_price = 0
		trader = null
		trader_name = "Unknown"
		status = "active"
		created_time = 0
		expiry_time = 0
		min_reputation = 0
		max_distance = 0

/datum/trade_history_entry
	/**
	 * trade_history_entry
	 * Record of completed trade
	 */
	var
		timestamp = 0
		buyer_name = ""
		seller_name = ""
		item_name = ""
		quantity = 0
		price_per_unit = 0
		total_value = 0
		buyer_rating = 5
		seller_rating = 5
// TRADING POST MANAGEMENT
// ============================================================================

/proc/CreateTradingPost(player, location_x, location_y, location_z)
	/**
	 * CreateTradingPost(player, location_x, location_y, location_z)
	 * Creates new trading post for player
	 * Returns: /datum/trading_post
	 */
	var/datum/trading_post/post = new /datum/trading_post()
	
	post.stall_owner = player
	post.owner_name = "Merchant"
	post.location_x = location_x
	post.location_y = location_y
	post.location_z = location_z
	
	return post

/datum/trading_post/proc/AddSellOffer(item_name, quantity, unit_price, min_reputation = 0)
	/**
	 * AddSellOffer(item_name, quantity, unit_price, min_reputation)
	 * Add item to sell stock
	 * Returns: /datum/stall_trade_offer or null
	 */
	if(!item_name || quantity <= 0 || unit_price <= 0)
		return null
	
	var/datum/stall_trade_offer/offer = new /datum/stall_trade_offer()
	offer.offer_id = "[owner_name]_sell_[world.time]"
	offer.offer_type = "sell"
	offer.item_name = item_name
	offer.quantity = quantity
	offer.unit_price = unit_price
	offer.trader = stall_owner
	offer.trader_name = owner_name
	offer.created_time = world.time
	offer.min_reputation = min_reputation
	offer.status = "active"
	
	sell_stock += offer
	
	world.log << "TRADING: [owner_name] posted sell: [quantity]x [item_name] @ [unit_price] lucre"
	return offer

/datum/trading_post/proc/AddBuyOffer(item_name, quantity, unit_price, min_reputation = 0)
	/**
	 * AddBuyOffer(item_name, quantity, unit_price, min_reputation)
	 * Add standing buy order
	 * Returns: /datum/stall_trade_offer or null
	 */
	if(!item_name || quantity <= 0 || unit_price <= 0)
		return null
	
	var/datum/stall_trade_offer/offer = new /datum/stall_trade_offer()
	offer.offer_id = "[owner_name]_buy_[world.time]"
	offer.offer_type = "buy"
	offer.item_name = item_name
	offer.quantity = quantity
	offer.unit_price = unit_price
	offer.trader = stall_owner
	offer.trader_name = owner_name
	offer.created_time = world.time
	offer.min_reputation = min_reputation
	offer.status = "active"
	
	buy_offers += offer
	
	world.log << "TRADING: [owner_name] posted buy: [quantity]x [item_name] @ [unit_price] lucre"
	return offer

/datum/trading_post/proc/RemoveOffer(offer_id)
	/**
	 * RemoveOffer(offer_id)
	 * Cancel an active offer
	 * Returns: TRUE if removed
	 */
	var/datum/stall_trade_offer/to_remove = null
	
	for(var/datum/stall_trade_offer/offer in sell_stock)
		if(offer.offer_id == offer_id)
			to_remove = offer
			break
	
	if(to_remove)
		sell_stock -= to_remove
		return TRUE
	
	for(var/datum/stall_trade_offer/offer in buy_offers)
		if(offer.offer_id == offer_id)
			to_remove = offer
			break
	
	if(to_remove)
		buy_offers -= to_remove
		return TRUE
	
	return FALSE

// ============================================================================
// TRADE EXECUTION
// ============================================================================

/datum/trading_post/proc/AcceptOffer(buyer, offer, quantity_accepted = 0)
	/**
	 * AcceptOffer(buyer, offer, quantity_accepted)
	 * Player accepts a sell offer
	 * quantity_accepted: 0 = full quantity
	 * Returns: TRUE if accepted
	 * Framework: Full implementation pending
	 */
	if(!buyer || !offer) return FALSE
	
	// Framework: Would validate offer status, check currency, execute trade
	world.log << "TRADE: Offer accepted (framework)"
	return TRUE

/proc/ExecuteStallTrade(buyer, seller, item_name, quantity, price_per_unit)
	/**
	 * ExecuteStallTrade(buyer, seller, item_name, quantity, price_per_unit)
	 * Execute actual trade: transfer items & currency
	 * Returns: /datum/trade_history_entry
	 * Framework: Implementation ready
	 */
	if(!buyer || !seller) return null
	
	// Framework: Would handle currency transfer, inventory, logging
	return null

// ============================================================================
// PRICING & ECONOMICS
// ============================================================================

/datum/trading_post/proc/GetSuggestedPrice(item_name, base_price)
	/**
	 * GetSuggestedPrice(item_name, base_price)
	 * Suggests selling price based on stall markup
	 * Returns: base_price * markup_percentage
	 */
	return base_price * markup_percentage

/datum/trading_post/proc/SetMarkup(percentage)
	/**
	 * SetMarkup(percentage)
	 * Owner adjusts markup (1.0 = cost, 1.5 = 50% markup)
	 * Range: 0.9 (10% discount) to 2.0 (100% markup)
	 */
	markup_percentage = clamp(percentage, 0.9, 2.0)

/datum/trading_post/proc/MatchBuyOffer(seller, item_name, quantity, unit_price)
	/**
	 * MatchBuyOffer(seller, item_name, quantity, unit_price)
	 * Check if seller can match any standing buy orders
	 * Returns: matching /datum/stall_trade_offer or null
	 */
	for(var/datum/stall_trade_offer/offer in buy_offers)
		if(offer.item_name == item_name && offer.status == "active")
			if(unit_price <= offer.unit_price)
				if(quantity >= offer.quantity)
					return offer
	
	return null

// ============================================================================
// STALL MANAGEMENT
// ============================================================================

/datum/trading_post/proc/OpenStall()
	/**
	 * OpenStall()
	 * Open stall for trading
	 */
	is_open = TRUE
	open_time = world.time
	world.log << "STALL: [owner_name] opened trading post"

/datum/trading_post/proc/CloseStall()
	/**
	 * CloseStall()
	 * Close stall (no new trades accepted)
	 */
	is_open = FALSE
	close_time = world.time
	world.log << "STALL: [owner_name] closed trading post"

/datum/trading_post/proc/IsOpen()
	/**
	 * IsOpen()
	 * Check if stall is open for business
	 */
	return is_open

/datum/trading_post/proc/GetStallInfo()
	/**
	 * GetStallInfo()
	 * Returns comprehensive stall status
	 */
	var/list/info = list(
		"owner" = owner_name,
		"location" = "[location_x], [location_y], [location_z]",
		"is_open" = is_open,
		"sell_offers" = sell_stock.len,
		"buy_offers" = buy_offers.len,
		"total_trades" = total_trades,
		"total_volume" = total_volume,
		"rating" = round(average_rating * 10) / 10.0,
		"markup" = round((markup_percentage - 1.0) * 100) + "%"
	)
	
	return info

// ============================================================================
// RANKINGS & STATISTICS
// ============================================================================

/datum/trading_post/proc/UpdateRating(rating_value)
	/**
	 * UpdateRating(rating_value)
	 * Update stall rating (1-5 stars)
	 * Maintains running average
	 */
	if(rating_value < 1 || rating_value > 5) return FALSE
	
	// Running average
	average_rating = (average_rating * total_trades + rating_value) / (total_trades + 1)
	total_trades += 1
	
	return TRUE

/datum/trading_post/proc/GetRating()
	/**
	 * GetRating()
	 * Returns current stall rating (1-5)
	 */
	return round(average_rating * 10) / 10.0

/datum/trading_post/proc/GetTradingVolume()
	/**
	 * GetTradingVolume()
	 * Returns total lucre traded through stall
	 */
	return total_volume

/proc/GetTopTradingPosts(limit = 10)
	/**
	 * GetTopTradingPosts(limit)
	 * Returns list of highest-rated trading posts
	 * Framework: Would query global stall registry
	 */
	var/list/top_posts = list()
	return top_posts

/proc/GetMostActiveTradingPosts(limit = 10)
	/**
	 * GetMostActiveTradingPosts(limit)
	 * Returns list of highest-volume trading posts
	 * Framework: Would query global stall registry
	 */
	var/list/active_posts = list()
	return active_posts

// ============================================================================
// TRADING POST UI DISPLAY
// ============================================================================

/datum/trading_post/proc/DisplayStallWindow()
	/**
	 * DisplayStallWindow()
	 * Returns formatted stall display for client
	 * Would be rendered as HUD overlay or popup
	 */
	var/display = ""
	
	display += "╔════════════════════════════════════════╗\n"
	display += "║ TRADING POST: [owner_name]\n"
	display += "╚════════════════════════════════════════╝\n\n"
	
	if(!is_open)
		display += "[owner_name]'s stall is currently CLOSED.\n\n"
	else
		display += "STATUS: OPEN\n"
		display += "Rating: [GetRating()]/5.0 ★ "
		display += "Volume: [total_volume] lucre\n\n"
		
		display += "SELLING ([sell_stock.len] items):\n"
		display += "╔──┬─────────────┬──────┬─────────╗\n"
		display += "║# │ Item        │ Qty  │ Price   ║\n"
		display += "╠──┼─────────────┼──────┼─────────╣\n"
		
		var/count = 0
		for(var/datum/stall_trade_offer/offer in sell_stock)
			if(offer.status == "active")
				count += 1
				display += "║[count]│ [offer.item_name] │ [offer.quantity] │ [offer.unit_price]L ║\n"
				if(count >= 5) break  // Show top 5
		
		display += "╚──┴─────────────┴──────┴─────────╝\n\n"
		
		display += "BUYING ([buy_offers.len] items):\n"
		display += "  Wants to buy various items at listed prices.\n\n"
	
	display += "╔════════════════════════════════════════╗\n"
	
	return display

/datum/trading_post/proc/DisplayPriceHistory(item_name, days = 7)
	/**
	 * DisplayPriceHistory(item_name, days)
	 * Show price trend for item (ASCII chart)
	 * Framework: Would query historical data
	 */
	var/display = ""
	
	display += "PRICE HISTORY: [item_name] (last [days] days)\n"
	display += "┌─────────────────────────────┐\n"
	display += "│ (Historical data not yet)   │\n"
	display += "│ (integrated with system)    │\n"
	display += "└─────────────────────────────┘\n"
	
	return display

// ============================================================================
// SYSTEM INITIALIZATION
// ============================================================================

/proc/InitializeTradingPostUI()
	/**
	 * InitializeTradingPostUI()
	 * Sets up trading post system
	 */
	
	// Create default trading posts for NPCs
	CreateDefaultNPCStalls()
	
	// Start trading post maintenance
	spawn() TradingPostMaintenanceLoop()
	
	world.log << "TRADING_POST: UI system initialized"

/proc/CreateDefaultNPCStalls()
	/**
	 * CreateDefaultNPCStalls()
	 * Creates trading posts for major merchant NPCs
	 */
	
	// These would create stalls at major locations
	// For framework: placeholder implementation
	
	world.log << "TRADING_POST: Created default NPC stalls"

/proc/TradingPostMaintenanceLoop()
	/**
	 * TradingPostMaintenanceLoop()
	 * Periodic maintenance for trading posts
	 * Expires old offers, updates prices, collects fees
	 */
	set background = 1
	set waitfor = 0
	
	var/update_interval = 150
	var/last_update = world.time
	
	while(1)
		sleep(50)
		
		if(world.time - last_update >= update_interval)
			last_update = world.time
			// - Remove expired offers
			// - Update suggested prices
			// - Calculate daily fees
			// Framework ready for implementation

/proc/GetTradingPost(player)
	/**
	 * GetTradingPost(player)
	 * Gets player's trading post (if any)
	 * Framework: Would look up from global registry
	 */
	return null

/proc/GetNearbyTradingPosts(player, distance = 10)
	/**
	 * GetNearbyTradingPosts(player, distance)
	 * Gets open trading posts within distance
	 * Framework: Would search spatial registry
	 */
	var/list/nearby = list()
	return nearby

// ============================================================================
// TRADING ANALYTICS
// ============================================================================

/datum/trading_post/proc/GetDailyStats()
	/**
	 * GetDailyStats()
	 * Returns trading metrics for current day
	 */
	var/list/stats = list(
		"day_trades" = 0,  // Would track trades since server day reset
		"day_volume" = 0,
		"average_price" = 0,
		"best_item" = "Unknown",
		"slowest_item" = "Unknown"
	)
	
	return stats

/datum/trading_post/proc/DisplayAnalytics()
	/**
	 * DisplayAnalytics()
	 * Show stall performance analysis
	 */
	var/display = ""
	
	display += "═════════════════════════════════════════\n"
	display += "STALL ANALYTICS: [owner_name]\n"
	display += "═════════════════════════════════════════\n"
	display += "Total Trades: [total_trades]\n"
	display += "Total Volume: [total_volume] lucre\n"
	display += "Average Rating: [GetRating()]/5.0\n"
	display += "Current Markup: [round((markup_percentage - 1.0) * 100)]%\n"
	display += "\nTop Items:\n"
	display += "  (Would show best-selling items)\n"
	display += "\nRecent Trades:\n"
	display += "  (Would show transaction log)\n"
	display += "═════════════════════════════════════════\n"
	
	return display
