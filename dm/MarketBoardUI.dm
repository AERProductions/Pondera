// MarketBoardUI.dm - Player-Driven Market Trading Interface
// Enables players to browse, list, and trade goods directly
// Integrates with DualCurrencySystem and KingdomMaterialExchange for comprehensive trading

var
	global/datum/market_board_manager/market_board = null
// MARKET BOARD LISTING DATUM
// ============================================================================

/datum/market_listing
	/**
	 * market_listing
	 * Represents a single item listing on the market board
	 */
	var
		listing_id = 0
		seller_name = ""
		seller_ckey = ""
		item_name = ""
		item_type = ""
		quantity = 1
		price_per_unit = 0
		currency_type = "lucre"
		creation_time = 0
		expiration_time = 0
		is_active = TRUE
		buyer_name = ""
		buyer_ckey = ""
		purchase_time = 0

/datum/market_board_manager
	/**
	 * market_board_manager
	 * Global manager for all market board listings
	 */
	var
		list/active_listings = list()
		list/completed_sales = list()
		list/seller_inventory = list()
		list/listing_search_cache = list()
		next_listing_id = 1
		max_listings_per_player = 25
		listing_duration = 14400
		cleanup_interval = 3600

	proc/CreateListing(mob/player, item_name, item_type, quantity, price_per_unit, currency_type = "lucre")
		/**
		 * CreateListing
		 * Create a new market board listing
		 * @param player - Seller
		 * @param item_name - Display name
		 * @param item_type - Internal item reference
		 * @param quantity - Stack size
		 * @param price_per_unit - Cost per unit
		 * @param currency_type - Currency (lucre/stone/metal/timber)
		 * @return listing_id or 0 on failure
		 */
		if(!player || !player.ckey) return 0
		
		// Check player's listing count
		var/player_listing_count = length(seller_inventory[player.ckey]) || 0
		if(player_listing_count >= max_listings_per_player)
			player << "ERROR: You have reached maximum listings ([max_listings_per_player])"
			return 0
		
		// Validate currency
		if(currency_type != "lucre" && currency_type != "stone" && currency_type != "metal" && currency_type != "timber")
			currency_type = "lucre"
		var/datum/market_listing/listing = new()
		listing.listing_id = next_listing_id++
		listing.seller_name = player.ckey
		listing.seller_ckey = player.ckey
		listing.item_name = item_name
		listing.item_type = item_type
		listing.quantity = max(1, quantity)
		listing.price_per_unit = price_per_unit
		listing.currency_type = currency_type
		listing.creation_time = world.time
		listing.expiration_time = world.time + listing_duration
		listing.is_active = TRUE
		active_listings += listing
		if(!seller_inventory[player.ckey]) seller_inventory[player.ckey] = list()
		seller_inventory[player.ckey] += listing
		
		world.log << "MARKET_BOARD: [player.ckey] created listing #[listing.listing_id] - [item_name] x[quantity] @ [price_per_unit] [currency_type]"
		
		return listing.listing_id

	proc/PurchaseListing(mob/buyer, listing_id)
		/**
		 * PurchaseListing
		 * Purchase an entire market listing
		 * @param buyer - Purchasing player
		 * @param listing_id - Target listing ID
		 * @return TRUE on success
		 */
		if(!buyer || !buyer.ckey) return FALSE
		
		// Find listing
		var/datum/market_listing/listing = FindListingByID(listing_id)
		if(!listing || !listing.is_active) 
			buyer << "ERROR: Listing not found or no longer available"
			return FALSE
		
		// Check expiration
		if(world.time > listing.expiration_time)
			listing.is_active = FALSE
			active_listings.Remove(listing)
			buyer << "ERROR: Listing has expired"
			return FALSE
		
		// Calculate total cost
		var/total_cost = listing.quantity * listing.price_per_unit
		var/buyer_balance = GetPlayerCurrency(buyer, listing.currency_type)
		if(buyer_balance < total_cost)
			buyer << "ERROR: Insufficient funds. Need [total_cost] [listing.currency_type], have [buyer_balance]"
			return FALSE
		
		// Deduct from buyer
		DeductPlayerCurrency(buyer, total_cost, listing.currency_type)
		
		// Add to seller
		var/seller_mob = GetMobByCKey(listing.seller_ckey)
		if(seller_mob)
			AddPlayerCurrency(seller_mob, total_cost, listing.currency_type)
			seller_mob << "[buyer.ckey] purchased your market listing: [listing.item_name] x[listing.quantity] for [total_cost] [listing.currency_type]"
		else
			// Seller offline - store in account
			SaveOfflinePayment(listing.seller_ckey, total_cost, listing.currency_type)
		
		// Mark as sold
		listing.is_active = FALSE
		listing.buyer_name = buyer.ckey
		listing.buyer_ckey = buyer.ckey
		listing.purchase_time = world.time
		completed_sales += listing
		active_listings.Remove(listing)
		if(seller_inventory[listing.seller_ckey])
			seller_inventory[listing.seller_ckey].Remove(listing)
		
		// Notify buyer
		buyer << "SUCCESS: Purchased [listing.item_name] x[listing.quantity] from [listing.seller_name] for [total_cost] [listing.currency_type]"
		
		world.log << "MARKET_BOARD: [buyer.ckey] purchased listing #[listing_id] from [listing.seller_ckey]"
		
		return TRUE

	proc/CancelListing(mob/seller, listing_id)
		/**
		 * CancelListing
		 * Cancel a market listing
		 * @param seller - Seller mob
		 * @param listing_id - Target listing ID
		 * @return TRUE on success
		 */
		if(!seller || !seller.ckey) return FALSE
		
		var/datum/market_listing/listing = FindListingByID(listing_id)
		if(!listing) return FALSE
		
		// Verify ownership
		if(listing.seller_ckey != seller.ckey)
			seller << "ERROR: You do not own this listing"
			return FALSE
		
		// Deactivate
		listing.is_active = FALSE
		active_listings.Remove(listing)
		if(seller_inventory[seller.ckey])
			seller_inventory[seller.ckey].Remove(listing)
		
		seller << "Listing #[listing_id] cancelled"
		world.log << "MARKET_BOARD: [seller.ckey] cancelled listing #[listing_id]"
		
		return TRUE

	proc/SearchListings(search_term = "", currency_filter = "")
		/**
		 * SearchListings
		 * Find listings matching search criteria
		 * @param search_term - Item name substring
		 * @param currency_filter - Filter by currency
		 * @return list of matching listings
		 */
		var/list/results = list()
		
		for(var/datum/market_listing/listing in active_listings)
			if(!listing.is_active) continue
			
			// Check expiration
			if(world.time > listing.expiration_time)
				listing.is_active = FALSE
				continue
			
			// Filter by search term
			if(search_term && !findtextEx(listing.item_name, search_term))
				continue
			
			// Filter by currency
			if(currency_filter && listing.currency_type != currency_filter)
				continue
			
			results += listing
		
		return results

	proc/GetPlayerListings(ckey)
		/**
		 * GetPlayerListings
		 * Get all active listings for a player
		 * @param ckey - Player ckey
		 * @return list of listings
		 */
		return seller_inventory[ckey] || list()

	proc/FindListingByID(listing_id)
		/**
		 * FindListingByID
		 * Find a listing by ID
		 * @param listing_id - Target ID
		 * @return listing datum or null
		 */
		for(var/datum/market_listing/listing in active_listings)
			if(listing.listing_id == listing_id)
				return listing
		
		return null

	proc/CleanupExpiredListings()
		/**
		 * CleanupExpiredListings
		 * Remove expired listings from active pool
		 */
		var/cleanup_count = 0
		var/list/expired = list()
		
		for(var/datum/market_listing/listing in active_listings)
			if(world.time > listing.expiration_time)
				listing.is_active = FALSE
				expired += listing
				cleanup_count++
		
		active_listings -= expired
		
		if(cleanup_count > 0)
			world.log << "MARKET_BOARD: Cleaned up [cleanup_count] expired listings"

	proc/GetMarketStats()
		/**
		 * GetMarketStats
		 * Get comprehensive market board statistics
		 * @return formatted stats
		 */
		var/output = ""
		output += "═════════════════════════════════════════════\n"
		output += "MARKET BOARD STATISTICS\n"
		output += "═════════════════════════════════════════════\n\n"
		
		output += "Active Listings: [length(active_listings)]\n"
		output += "Completed Sales: [length(completed_sales)]\n"
		output += "Unique Sellers: [length(seller_inventory)]\n"
		output += "Next Listing ID: [next_listing_id]\n\n"
		
		// Top items
		var/list/item_counts = list()
		for(var/datum/market_listing/listing in active_listings)
			item_counts[listing.item_name] = (item_counts[listing.item_name] || 0) + 1
		
		output += "TOP ITEMS:\n"
		var/top_count = 0
		for(var/item in item_counts)
			if(top_count++ >= 5) break
			output += "  [item]: [item_counts[item]] listings\n"
		
		output += "\n═════════════════════════════════════════════\n"
		
		return output

/proc/InitializeMarketBoardUI()
	/**
	 * InitializeMarketBoardUI
	 * Initialize the global market board manager
	 */
	market_board = new /datum/market_board_manager()
	world.log << "MARKET_BOARD: System initialized"

/proc/GetMarketBoard()
	/**
	 * GetMarketBoard
	 * Get the global market board manager
	 * @return market_board datum
	 */
	if(!market_board)
		InitializeMarketBoardUI()
	
	return market_board

// ============================================================================
// MARKET BOARD SCREEN OBJECTS
// ============================================================================

/obj/screen/market_board_main
	/**
	 * market_board_main
	 * Main market board UI screen
	 */
	screen_loc = "1,1 to 20,20"
	layer = 20
	plane = 2
	
	var
		list/displayed_listings = list()
		current_page = 1
		items_per_page = 10
		max_pages = 1
		search_term = ""
		currency_filter = ""

/obj/screen/market_board_listing_item
	/**
	 * market_board_listing_item
	 * Individual listing display in market board
	 */
	layer = 21
	plane = 2
	
	var
		datum/market_listing/listing = null
		is_highlighted = FALSE

/proc/DisplayMarketBoard(mob/player)
	/**
	 * DisplayMarketBoard
	 * Show market board UI to player
	 * @param player - Target player
	 */
	if(!player || !player.client) return
	
	var/datum/market_board_manager/board = GetMarketBoard()
	var/list/all_listings = board.SearchListings()
	
	var/output = ""
	output += "<div style='background-color: #1a1a1a; color: #fff; padding: 10px; border: 2px solid #FFD700;'>\n"
	output += "<h2>═══ MARKET BOARD ═══</h2>\n"
	output += "<p>Active Listings: [length(all_listings)]</p>\n"
	output += "<hr>\n"
	
	// List top 20 items
	var/count = 0
	for(var/datum/market_listing/listing in all_listings)
		if(count++ >= 20) break
		
		var/total_price = listing.quantity * listing.price_per_unit
		output += "<div style='border-bottom: 1px solid #666; padding: 5px;'>\n"
		output += "<b>[listing.item_name]</b> x[listing.quantity]<br>\n"
		output += "Price: [listing.price_per_unit] per unit ([total_price] [listing.currency_type] total)<br>\n"
		output += "Seller: [listing.seller_name] | Listed: [round((world.time - listing.creation_time)/600)] minutes ago<br>\n"
		output += "</div>\n"
	
	output += "</div>"
	
	player << output

/proc/SaveOfflinePayment(ckey, amount, currency_type)
	/**
	 * SaveOfflinePayment
	 * Store payment for offline player
	 * Used when listing is sold while seller is offline
	 */
	// This would integrate with character save system
	// Placeholder for now
	world.log << "MARKET_BOARD: Offline payment pending - [ckey] owes [amount] [currency_type]"

/proc/GetMobByCKey(ckey)
	/**
	 * GetMobByCKey
	 * Find online player by ckey
	 * @param ckey - Target player ckey
	 * @return mob or null
	 */
	for(var/mob/players/M in world)
		if(M.ckey == ckey)
			return M
	
	return null

/proc/MarketBoardUpdateLoop()
	/**
	 * MarketBoardUpdateLoop
	 * Background loop for market board maintenance
	 */
	set background = 1
	set waitfor = 0
	
	var/datum/market_board_manager/board = GetMarketBoard()
	
	while(1)
		sleep(board.cleanup_interval)
		
		// Cleanup expired listings
		board.CleanupExpiredListings()
		
		// Update search cache
		board.listing_search_cache = list()
// MARKET BOARD INTEGRATION WITH FILTERING LIBRARY
// ============================================================================

// Market-specific filtering helpers
proc/GetMarketableItemsFiltered(mob/player)
	/// Get items that can be listed on market board using filtering
	if(!player) return list()
	
	var/list/marketable = list()
	
	for(var/item in player.contents)
		var/obj/test = item
		if(!test) continue
		
		var/type_str = "[test.type]"
		if(findtext(type_str, "Container") || findtext(type_str, "Jar") || findtext(type_str, "Bag"))
			continue
		if(findtext(type_str, "Deed") || findtext(type_str, "Quest"))
			continue
		
		// Add marketable items
		marketable += item
	
	return marketable

mob/verb/quick_list_item()
	set category = "Market"
	set popup_menu = 1
	set hidden = 1
	
	var/list/marketable = GetMarketableItemsFiltered(usr)
	
	if(!marketable.len)
		usr << "You have nothing to list."
		return
	
	var/selected = input(usr, "Which item to list?", "Market") as null|anything in marketable
	if(!selected)
		return
	
	var/obj/to_list = selected
	var/price = input(usr, "Price per unit?", "Listing Price") as num
	if(price < 0)
		usr << "Invalid price."
		return
	
	var/currency = input(usr, "Currency type?", "Currency") in list("lucre", "stone", "metal", "timber")
	if(!currency)
		return
	
	// Add listing to market
	var/datum/market_board_manager/board = GetMarketBoard()
	if(!board)
		usr << "Market board not available."
		return
	
	board.CreateListing(usr, to_list:name, "[to_list.type]", 1, price, currency)
	usr << "Listed [to_list] for [price] [currency]."
