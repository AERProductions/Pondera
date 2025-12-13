// MarketBoardUI.dm - Player-Driven Market Trading Interface
// Enables players to browse, list, and trade goods directly
// Integrates with DualCurrencySystem and KingdomMaterialExchange for comprehensive trading

var
	global/datum/market_board_manager/market_board = null
// MARKET BOARD LISTING DATUM
// ============================================================================

/datum/market_listing
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
		var/buyer_balance = GetPlayerCurrencyBalance(buyer, listing.currency_type)
		if(buyer_balance < total_cost)
			buyer << "ERROR: Insufficient funds. Need [total_cost] [listing.currency_type], have [buyer_balance]"
			return FALSE
		
		// Deduct from buyer
		DeductPlayerCurrency(buyer, listing.currency_type, total_cost)
		
		// Add to seller
		var/seller_mob = GetMobByCKey(listing.seller_ckey)
		if(seller_mob)
			AddPlayerCurrency(seller_mob, listing.currency_type, total_cost)
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

/proc/DisplayMarketBoard(mob/player, search_term = "", currency_filter = "", sort_by = "recent", page = 1)
	/**
	 * DisplayMarketBoard
	 * Show comprehensive market board UI to player with search, filters, pagination
	 * @param player - Target player
	 * @param search_term - Item name filter
	 * @param currency_filter - Filter by currency (lucre/stone/metal/timber)
	 * @param sort_by - Sort method (recent, price_low, price_high, popularity)
	 * @param page - Pagination page number
	 */
	if(!player || !player.client) return
	
	var/datum/market_board_manager/board = GetMarketBoard()
	var/list/all_listings = board.SearchListings(search_term, currency_filter)
	
	// Sort listings
	switch(sort_by)
		if("recent")
			all_listings = sort_listings_by_time(all_listings)
		if("price_low")
			all_listings = sort_listings_by_price(all_listings, 1)  // Ascending
		if("price_high")
			all_listings = sort_listings_by_price(all_listings, 0)  // Descending
		if("popularity")
			all_listings = sort_listings_by_quantity(all_listings)
	
	// Pagination
	var/items_per_page = 15
	var/max_pages = max(1, ceil(length(all_listings) / items_per_page))
	page = max(1, min(page, max_pages))
	
	var/start_idx = (page - 1) * items_per_page + 1
	var/end_idx = min(page * items_per_page, length(all_listings))
	
	var/output = "<html><head><style>"
	output += "body { background-color: #0a0a0a; color: #fff; font-family: Arial, sans-serif; }"
	output += ".header { background: linear-gradient(to right, #FFD700, #FFA500); color: #000; padding: 15px; font-size: 18px; font-weight: bold; text-align: center; }"
	output += ".filter-section { background: #1a1a1a; border: 1px solid #FFD700; padding: 10px; margin: 10px 0; }"
	output += ".listing { background: #1a1a1a; border-left: 3px solid #FFD700; padding: 10px; margin: 5px 0; }"
	output += ".listing-title { color: #FFD700; font-weight: bold; font-size: 14px; }"
	output += ".listing-price { color: #00FF00; font-size: 12px; }"
	output += ".listing-seller { color: #888; font-size: 11px; }"
	output += ".pagination { text-align: center; padding: 10px; color: #FFD700; }"
	output += ".button { background: #FFD700; color: #000; padding: 5px 10px; margin: 2px; font-weight: bold; cursor: pointer; border: none; border-radius: 3px; }"
	output += ".stats { background: #1a1a1a; border: 1px solid #888; padding: 10px; margin: 10px 0; font-size: 12px; }"
	output += "</style></head><body>\n"
	
	// Header
	output += "<div class='header'>═══ MARKET BOARD ═══</div>\n"
	
	// Stats
	output += "<div class='stats'>"
	output += "<b>Market Statistics:</b><br>"
	output += "Total Listings: [length(board.active_listings)] | "
	output += "Total Sellers: [length(board.seller_inventory)] | "
	output += "Sales Completed: [length(board.completed_sales)]"
	output += "</div>\n"
	
	// Filter section
	output += "<div class='filter-section'>"
	output += "<b>Filters & Sort:</b><br>"
	output += "Search: <input type='text' value='[search_term]' style='width: 150px;'> | "
	output += "Currency: <select style='width: 100px;'><option>All</option><option>Lucre</option><option>Stone</option><option>Metal</option><option>Timber</option></select> | "
	output += "Sort: <select style='width: 120px;'><option>Recent</option><option>Price (Low-High)</option><option>Price (High-Low)</option><option>Popular</option></select>"
	output += "</div>\n"
	
	// No results message
	if(!all_listings.len)
		output += "<div style='text-align: center; padding: 20px; color: #888;'>No listings found matching your criteria.</div>\n"
	else
		// Display listings for current page
		for(var/i = start_idx to end_idx)
			var/datum/market_listing/listing = all_listings[i]
			var/total_price = listing.quantity * listing.price_per_unit
			var/age = round((world.time - listing.creation_time) / 600)
			
			output += "<div class='listing'>"
			output += "<span class='listing-title'>[listing.item_name]</span> <span style='color: #888;'>(x[listing.quantity])</span><br>"
			output += "<span class='listing-price'>[listing.price_per_unit] [listing.currency_type] per unit | Total: [total_price] [listing.currency_type]</span><br>"
			output += "<span class='listing-seller'>Seller: [listing.seller_name] | Posted: [age] minute(s) ago | ID: [listing.listing_id]</span>"
			output += "</div>\n"
	
	// Pagination
	if(max_pages > 1)
		output += "<div class='pagination'>"
		if(page > 1)
			output += "<span class='button'>&lt; PREVIOUS PAGE</span> "
		output += " <b>Page [page] of [max_pages]</b> "
		if(page < max_pages)
			output += "<span class='button'>NEXT PAGE &gt;</span>"
		output += "</div>\n"
	
	output += "</body></html>"
	
	player << output

/proc/sort_listings_by_time(list/listings)
	/**
	 * Sort listings by creation time (newest first)
	 */
	var/list/result = listings.Copy()
	result = sortByKey(result, "creation_time", reverse=1)
	return result

/proc/sort_listings_by_price(list/listings, ascending = 1)
	/**
	 * Sort listings by price per unit
	 */
	var/list/result = listings.Copy()
	result = sortByKey(result, "price_per_unit", reverse=!ascending)
	return result

/proc/sort_listings_by_quantity(list/listings)
	/**
	 * Sort listings by quantity (highest first)
	 */
	var/list/result = listings.Copy()
	result = sortByKey(result, "quantity", reverse=1)
	return result

/proc/sortByKey(list/input, key, reverse = 0)
	/**
	 * Generic list sorting by datum key
	 * Returns sorted copy of list
	 */
	var/list/result = input.Copy()
	var/sorted = 0
	
	while(!sorted)
		sorted = 1
		for(var/i = 1 to length(result) - 1)
			var/datum/a = result[i]
			var/datum/b = result[i + 1]
			
			var/a_val = a.vars[key]
			var/b_val = b.vars[key]
			
			var/should_swap = 0
			if(reverse)
				should_swap = (a_val < b_val)
			else
				should_swap = (a_val > b_val)
			
			if(should_swap)
				result.Swap(i, i + 1)
				sorted = 0
	
	return result

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

mob/verb/BrowseMarketBoard()
	/**
	 * BrowseMarketBoard
	 * Main verb to open market board UI
	 */
	set name = "Browse Market Board"
	set category = "Market"
	
	if(!usr)
		return
	
	DisplayMarketBoard(usr)

mob/verb/MyMarketListings()
	/**
	 * MyMarketListings
	 * Show player's own listings
	 */
	set name = "My Market Listings"
	set category = "Market"
	
	if(!usr)
		return
	
	var/datum/market_board_manager/board = GetMarketBoard()
	var/list/my_listings = board.GetPlayerListings(usr.ckey)
	
	var/output = "<html><head><style>"
	output += "body { background-color: #0a0a0a; color: #fff; font-family: Arial, sans-serif; }"
	output += ".header { background: #FFD700; color: #000; padding: 15px; font-size: 16px; font-weight: bold; }"
	output += ".listing { background: #1a1a1a; border-left: 3px solid #FFD700; padding: 10px; margin: 5px 0; }"
	output += ".listing-title { color: #FFD700; font-weight: bold; }"
	output += ".listing-stats { color: #888; font-size: 11px; }"
	output += ".listing-price { color: #00FF00; font-weight: bold; }"
	output += ".button { background: #FF6666; color: #000; padding: 5px 10px; font-weight: bold; cursor: pointer; border: none; border-radius: 3px; margin: 5px; }"
	output += ".stats { background: #1a1a1a; border: 1px solid #888; padding: 10px; margin: 10px 0; }"
	output += "</style></head><body>\n"
	
	output += "<div class='header'>MY MARKET LISTINGS</div>\n"
	
	if(!my_listings.len)
		output += "<div style='text-align: center; padding: 20px; color: #888;'>You have no active listings.</div>\n"
	else
		var/total_value = 0
		for(var/datum/market_listing/listing in my_listings)
			var/listing_value = listing.quantity * listing.price_per_unit
			total_value += listing_value
			
			output += "<div class='listing'>"
			output += "<span class='listing-title'>[listing.item_name]</span> (x[listing.quantity])<br>"
			output += "<span class='listing-price'>[listing.price_per_unit] [listing.currency_type] ea. | Total: [listing_value]</span><br>"
			output += "<span class='listing-stats'>Listed: [round((world.time - listing.creation_time)/600)] min ago | Expires: [round((listing.expiration_time - world.time)/600)] min | ID: [listing.listing_id]</span><br>"
			output += "<span class='button' onclick='CancelListing([listing.listing_id])'>CANCEL</span>"
			output += "</div>\n"
		
		output += "<div class='stats'><b>Total Inventory Value: [total_value] (across all listings)</b></div>\n"
	
	output += "</body></html>"
	
	usr << output

mob/verb/ListItemOnMarketBoard()
	/**
	 * ListItemOnMarketBoard
	 * Interactive listing creation with better UX
	 */
	set name = "List Item on Market"
	set category = "Market"
	
	if(!usr)
		return
	
	var/list/marketable = GetMarketableItemsFiltered(usr)
	
	if(!marketable.len)
		usr << "<span style='color: #FF6666;'>ERROR: You have no items to list.</span>"
		return
	
	var/obj/to_list = input(usr, "Select item to list:", "Market Listing") as null|anything in marketable
	if(!to_list)
		return
	
	var/item_name = to_list.name || "[to_list.type]"
	var/suggested_price = 100  // Default starting price
	var/price = input(usr, "Set price per unit (suggested: [suggested_price]):", "Listing Price") as num
	if(!price || price <= 0)
		usr << "<span style='color: #FF6666;'>Invalid price.</span>"
		return
	
	var/currency = input(usr, "Select currency:", "Currency Type") in list("lucre", "stone", "metal", "timber")
	if(!currency)
		usr << "<span style='color: #FF6666;'>Listing cancelled.</span>"
		return
	
	// Attempt to create listing
	var/datum/market_board_manager/board = GetMarketBoard()
	var/listing_id = board.CreateListing(usr, item_name, "[to_list.type]", 1, price, currency)
	
	if(listing_id > 0)
		usr << "<span style='color: #00FF00;'>SUCCESS: Listed [item_name] for [price] [currency]</span>"
		usr << "Listing ID: [listing_id]"
	else
		usr << "<span style='color: #FF6666;'>ERROR: Could not create listing. Check limits.</span>"
