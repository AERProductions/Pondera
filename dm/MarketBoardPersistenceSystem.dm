// MarketBoardPersistenceSystem.dm - Market Board Persistence Layer
// Implements savefile-based persistence for player stalls, listings, transaction history, and market data
// Integrates with MarketBoardUI.dm for seamless data recovery on server restart

// ============================================================================
// MARKET BOARD PERSISTENCE - GLOBAL SYSTEM
// ============================================================================

/proc/InitializeMarketBoardPersistence()
	/**
	 * InitializeMarketBoardPersistence()
	 * Load all market board data from savefiles on server startup
	 * Called from InitializationManager.dm during Phase 2 (Infrastructure)
	 * 
	 * Loads:
	 * - Active listings from MapSaves/MarketBoard_Listings.sav
	 * - Player stall data from MapSaves/MarketStall_[ckey].sav
	 * - Transaction history from MapSaves/MarketHistory_[ckey].sav
	 * - Offline payments from MapSaves/MarketPayments_[ckey].sav
	 */
	if(!market_board)
		InitializeMarketBoardUI()
	
	LoadAllMarketListings()
	LoadAllPlayerStalls()
	
	world.log << "MARKET_BOARD: Persistence system initialized"

/proc/LoadAllPlayerStalls()
	/**
	 * LoadAllPlayerStalls()
	 * Load all player stall data from savefiles
	 * Currently a stub - per-player stall loading is handled on-demand
	 */
	// Stalls are loaded per-player when they access market features
	// No global stall registry needed at startup
	return

/proc/LoadAllMarketListings()
	/**
	 * LoadAllMarketListings()
	 * Load all active market listings from global savefile
	 * Cleans up expired listings during load
	 * 
	 * Savefile: MapSaves/MarketBoard_Listings.sav
	 * Format: List of /datum/market_listing objects
	 */
	var/datum/market_board_manager/board = GetMarketBoard()
	if(!board) return
	
	var/savefile/S = new("MapSaves/MarketBoard_Listings.sav")
	if(!S)
		world.log << "MARKET_BOARD: No existing listings savefile found (new install)"
		return
	
	var/list/loaded_listings = list()
	S["listings"] >> loaded_listings
	
	if(!loaded_listings || !loaded_listings.len)
		world.log << "MARKET_BOARD: Listings savefile empty or corrupted"
		return
	
	var/loaded_count = 0
	var/expired_count = 0
	
	for(var/datum/market_listing/listing in loaded_listings)
		if(!listing)
			continue
		
		// Check if listing has expired
		if(world.time > listing.expiration_time)
			expired_count++
			continue
		
		// Restore to market board
		board.active_listings += listing
		if(!board.seller_inventory[listing.seller_ckey])
			board.seller_inventory[listing.seller_ckey] = list()
		board.seller_inventory[listing.seller_ckey] += listing
		
		loaded_count++
		// Update next_listing_id if this listing has higher ID
		if(listing.listing_id >= board.next_listing_id)
			board.next_listing_id = listing.listing_id + 1
	
	world.log << "MARKET_BOARD: Loaded [loaded_count] active listings ([expired_count] expired, cleaned up)"

/proc/SaveAllMarketListings()
	/**
	 * SaveAllMarketListings()
	 * Save all active market listings to global savefile
	 * Called periodically and on shutdown
	 * 
	 * Savefile: MapSaves/MarketBoard_Listings.sav
	 */
	var/datum/market_board_manager/board = GetMarketBoard()
	if(!board) return
	
	var/savefile/S = new("MapSaves/MarketBoard_Listings.sav")
	S["listings"] << board.active_listings
	
	world.log << "MARKET_BOARD: Saved [board.active_listings.len] active listings"

/proc/SavePlayerListings(ckey)
	/**
	 * SavePlayerListings(ckey)
	 * Save a player's specific listings (completed sales history)
	 * Called when player logs off or periodically
	 * 
	 * Savefile: MapSaves/MarketListings_[ckey].sav
	 */
	if(!ckey) return
	
	var/datum/market_board_manager/board = GetMarketBoard()
	if(!board) return
	
	var/list/player_completed = list()
	for(var/datum/market_listing/listing in board.completed_sales)
		if(listing.seller_ckey == ckey || listing.buyer_ckey == ckey)
			player_completed += listing
	
	var/savefile/S = new("MapSaves/MarketListings_[ckey].sav")
	S["completed"] << player_completed
	
	if(player_completed.len > 0)
		world.log << "MARKET_BOARD: Saved [player_completed.len] completed sales for [ckey]"

/proc/LoadPlayerListings(ckey)
	/**
	 * LoadPlayerListings(ckey)
	 * Load a player's completed sales history (for transaction records)
	 * Called when player logs in
	 * 
	 * Returns: List of completed market listings
	 */
	if(!ckey) return list()
	
	var/savefile/S = new("MapSaves/MarketListings_[ckey].sav")
	if(!S) return list()
	
	var/list/player_completed = list()
	S["completed"] >> player_completed
	
	if(player_completed && player_completed.len)
		world.log << "MARKET_BOARD: Loaded [player_completed.len] completed sales for [ckey]"
	
	return player_completed || list()

// ============================================================================
// MARKET STALL PERSISTENCE
// ============================================================================

/proc/SavePlayerStall(ckey)
	/**
	 * SavePlayerStall(ckey)
	 * Save a player's market stall state (items, prices, profits)
	 * Called when stall is updated or player logs off
	 * 
	 * Savefile: MapSaves/MarketStall_[ckey].sav
	 * Stores: stall_items (dict), prices (dict), daily_profit, is_locked, stall_name
	 */
	if(!ckey) return
	
	var/savefile/S = new("MapSaves/MarketStall_[ckey].sav")
	
	// Find player's stall in world (if it exists as object)
	var/obj/market_stall/stall = null
	for(var/obj/market_stall/S2 in world)
		if(S2.owner_key == ckey)
			stall = S2
			break
	
	if(stall)
		S["stall_items"] << stall.stall_items
		S["prices"] << stall.prices
		S["daily_profit"] << stall.daily_profit
		S["is_locked"] << stall.is_locked
		S["stall_name"] << stall.stall_name
		S["owner_name"] << stall.owner_name
		S["owner_key"] << stall.owner_key
		world.log << "MARKET_BOARD: Saved stall for [ckey]"

/proc/LoadPlayerStall(ckey)
	/**
	 * LoadPlayerStall(ckey)
	 * Load a player's market stall state
	 * Returns: List with (stall_items, prices, daily_profit, is_locked, stall_name)
	 */
	if(!ckey) return null
	
	var/savefile/S = new("MapSaves/MarketStall_[ckey].sav")
	if(!S) return null
	
	var/list/stall_data = list()
	var/list/stall_items = list()
	var/list/prices = list()
	var/daily_profit = 0
	var/is_locked = 0
	var/stall_name = ""
	
	S["stall_items"] >> stall_items
	S["prices"] >> prices
	S["daily_profit"] >> daily_profit
	S["is_locked"] >> is_locked
	S["stall_name"] >> stall_name
	
	if(stall_items && stall_items.len)
		stall_data["items"] = stall_items
		stall_data["prices"] = prices
		stall_data["profit"] = daily_profit
		stall_data["locked"] = is_locked
		stall_data["name"] = stall_name
		world.log << "MARKET_BOARD: Loaded stall data for [ckey]"
		return stall_data
	
	return null

// ============================================================================
// OFFLINE PAYMENT SYSTEM - Track payments to offline players
// NOTE: SaveOfflinePayment() is defined in MarketBoardUI.dm
// ============================================================================

// SaveOfflinePayment is called from MarketBoardUI.dm and already defined there
// This prevents duplicate definition

/proc/LoadOfflinePayments(ckey)
	/**
	 * LoadOfflinePayments(ckey)
	 * Load all offline payments for a player
	 * Called when player logs in
	 * 
	 * Returns: List of payment entries [timestamp, amount, currency, time_readable]
	 */
	if(!ckey) return list()
	
	var/savefile/S = new("MapSaves/MarketPayments_[ckey].sav")
	if(!S) return list()
	
	var/list/payments = list()
	S["payments"] >> payments
	
	if(payments && payments.len)
		world.log << "MARKET_BOARD: Loaded [payments.len] offline payments for [ckey]"
	
	return payments || list()

/proc/ProcessOfflinePayments(mob/player)
	/**
	 * ProcessOfflinePayments(mob/player)
	 * Process all offline payments into player's account on login
	 * Displays payment summary to player
	 */
	if(!player || !player.ckey) return
	
	var/list/payments = LoadOfflinePayments(player.ckey)
	if(!payments.len)
		return
	
	var/lucre_total = 0
	var/stone_total = 0
	var/metal_total = 0
	var/timber_total = 0
	var/payment_count = payments.len
	
	for(var/list/payment in payments)
		if(!payment) continue
		
		var/amount = payment["amount"] || 0
		var/currency = payment["currency"] || "lucre"
		
		switch(currency)
			if("lucre")
				lucre_total += amount
				AddPlayerCurrency(player, "lucre", amount)
			if("stone")
				stone_total += amount
				AddPlayerCurrency(player, "stone", amount)
			if("metal")
				metal_total += amount
				AddPlayerCurrency(player, "metal", amount)
			if("timber")
				timber_total += amount
				AddPlayerCurrency(player, "timber", amount)
	
	// Build notification
	var/notification = "<b><font color='#FFD700'>═══ MARKET BOARD ═══</font></b><br>"
	notification += "You have received <b>[payment_count]</b> offline sale payments:<br><br>"
	
	if(lucre_total > 0) notification += "💰 Lucre: +[lucre_total]<br>"
	if(stone_total > 0) notification += "🪨 Stone: +[stone_total]<br>"
	if(metal_total > 0) notification += "⚙️ Metal: +[metal_total]<br>"
	if(timber_total > 0) notification += "🪵 Timber: +[timber_total]<br>"
	
	notification += "<br><b>Total Payments: [payment_count]</b>"
	
	player << notification
	
	// Clear payments file
	fdel("MapSaves/MarketPayments_[player.ckey].sav")
	
	world.log << "MARKET_BOARD: Processed [payment_count] offline payments for [player.ckey]"

// ============================================================================
// MARKET TRANSACTION HISTORY
// ============================================================================

/proc/SaveMarketTransaction(seller_ckey, buyer_ckey, item_name, quantity, price_per_unit, currency_type)
	/**
	 * SaveMarketTransaction(seller_ckey, buyer_ckey, item_name, quantity, price_per_unit, currency_type)
	 * Log a completed market transaction to player histories
	 * Called after successful purchase
	 * 
	 * Savefiles:
	 * - MapSaves/MarketHistory_[ckey].sav
	 * Contains: List of [timestamp, party, item_name, qty, price, currency, type (buy/sell)]
	 */
	if(!seller_ckey || !buyer_ckey) return
	
	var/transaction_data = list()
	transaction_data["timestamp"] = world.time
	transaction_data["item"] = item_name
	transaction_data["quantity"] = quantity
	transaction_data["price_per_unit"] = price_per_unit
	transaction_data["total"] = quantity * price_per_unit
	transaction_data["currency"] = currency_type
	transaction_data["time_readable"] = "[time2text(world.timeofday)]"
	
	// Save to seller's history
	SavePlayerTransactionHistory(seller_ckey, buyer_ckey, "sell", transaction_data)
	
	// Save to buyer's history
	SavePlayerTransactionHistory(buyer_ckey, seller_ckey, "buy", transaction_data)

/proc/SavePlayerTransactionHistory(ckey, other_party, transaction_type, list/transaction_data)
	/**
	 * SavePlayerTransactionHistory(ckey, other_party, transaction_type, transaction_data)
	 * Internal proc to save transaction to player's history file
	 */
	if(!ckey || !transaction_data) return
	
	var/savefile/S = new("MapSaves/MarketHistory_[ckey].sav")
	
	var/list/history = list()
	S["history"] >> history
	
	if(!history) history = list()
	
	// Add new transaction
	transaction_data["party"] = other_party
	transaction_data["type"] = transaction_type
	history += transaction_data
	
	// Cap history at 5000 entries to prevent file bloat
	if(history.len > 5000)
		// Keep only last 5000 entries using manual loop
		var/start_idx = max(1, history.len - 4999)
		var/list/trimmed = list()
		for(var/i = start_idx to history.len)
			if(i > 0 && i <= history.len)
				trimmed += history[i]
		history = trimmed
	
	S["history"] << history

/proc/LoadPlayerTransactionHistory(ckey)
	/**
	 * LoadPlayerTransactionHistory(ckey)
	 * Load a player's complete transaction history
	 * Used for market analytics and player records
	 * 
	 * Returns: List of transaction entries
	 */
	if(!ckey) return list()
	
	var/savefile/S = new("MapSaves/MarketHistory_[ckey].sav")
	if(!S) return list()
	
	var/list/history = list()
	S["history"] >> history
	
	return history || list()

// ============================================================================
// PERIODIC MAINTENANCE - Background market data cleanup
// ============================================================================

/proc/StartMarketBoardMaintenanceLoop()
	/**
	 * StartMarketBoardMaintenanceLoop()
	 * Background loop for periodic market board maintenance
	 * Called from InitializationManager.dm
	 * 
	 * Tasks:
	 * - Save active listings every 10 minutes (600 ticks)
	 * - Clean expired listings every 30 minutes (1800 ticks)
	 * - Log market statistics hourly (3600 ticks)
	 */
	set background = 1
	set waitfor = 0
	
	while(world_initialization_complete)
		sleep(600)  // 10 minutes
		
		SaveAllMarketListings()
		
		// Every 3 saves = 30 minutes, cleanup expired listings
		var/static/cleanup_counter = 0
		cleanup_counter++
		if(cleanup_counter >= 3)
			var/datum/market_board_manager/board = GetMarketBoard()
			if(board)
				board.CleanupExpiredListings()
			cleanup_counter = 0
		
		// Every 6 saves = 1 hour, log stats
		if(cleanup_counter == 0)
			var/datum/market_board_manager/board = GetMarketBoard()
			if(board)
				world.log << board.GetMarketStats()

// ============================================================================
// WORLD SHUTDOWN INTEGRATION
// ============================================================================

/proc/SaveMarketBoardOnShutdown()
	/**
	 * SaveMarketBoardOnShutdown()
	 * Save all market board data before server shutdown
	 * Ensures no data loss during crashes or restarts
	 * Called from world/Del() in time.dm
	 */
	world.log << "MARKET_BOARD: Performing emergency save before shutdown..."
	SaveAllMarketListings()
	world.log << "MARKET_BOARD: Shutdown save complete"

// ============================================================================
// PLAYER LOGIN/LOGOUT INTEGRATION
// ============================================================================

/proc/IntegrateMarketBoardOnLogin(mob/players/player)
	/**
	 * IntegrateMarketBoardOnLogin(mob/players/player)
	 * Called from mob/players/New() when player logs in
	 * 
	 * Processes:
	 * - Load player's market stall state
	 * - Process offline payments
	 * - Display market statistics
	 */
	if(!player || !player.ckey) return
	
	// Process offline payments (adds currency automatically)
	ProcessOfflinePayments(player)
	
	// Load transaction history for reference (optional display)
	var/list/history = LoadPlayerTransactionHistory(player.ckey)
	
	if(history && history.len)
		player << "<b><font color='#FFD700'>Market History: You have [history.len] transactions on record</font></b>"

/proc/IntegrateMarketBoardOnLogout(ckey)
	/**
	 * IntegrateMarketBoardOnLogout(ckey)
	 * Called from mob/players/Logout() when player logs out
	 * 
	 * Saves:
	 * - Player's active listings
	 * - Player's stall state (if exists)
	 */
	if(!ckey) return
	
	SavePlayerListings(ckey)
	SavePlayerStall(ckey)

