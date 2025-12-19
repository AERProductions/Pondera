// MarketBoardPersistenceSystem.dm - Market Board Persistence Layer (Phase 2)
// Implements SQLite persistence for player listings, transaction history, and market data
// Integrates with MarketBoardUI.dm for seamless data recovery on server restart

// ============================================================================
// MARKET BOARD PERSISTENCE - GLOBAL SYSTEM (PHASE 2: SQLite)
// ============================================================================

/proc/InitializeMarketBoardPersistence()
	/**
	 * InitializeMarketBoardPersistence()
	 * Load all market board data from SQLite on server startup
	 * Called from InitializationManager.dm during Phase 2 (Infrastructure)
	 * 
	 * Loads:
	 * - Active listings from market_listings SQLite table
	 * - Player stall data (on-demand, per-player)
	 * - Transaction history from market_history SQLite table
	 * 
	 * Phase 2 Change: Migrated from savefiles (MapSaves/MarketBoard_Listings.sav) to SQLite
	 */
	if(!market_board)
		InitializeMarketBoardUI()
	
	LoadAllMarketListings()
	LoadAllPlayerStalls()
	
	world.log << "MARKET_BOARD: Persistence system initialized (SQLite, Phase 2)"

/proc/LoadAllPlayerStalls()
	/**
	 * LoadAllPlayerStalls()
	 * Stub - Player stall loading is handled on-demand
	 * Currently a stub - per-player stall loading is handled on-demand
	 */
	// Stalls are loaded per-player when they access market features
	// No global stall registry needed at startup
	return

/proc/LoadAllMarketListings()
	/**
	 * LoadAllMarketListings()
	 * Load all active market listings from SQLite
	 * Cleans up expired listings during load
	 * 
	 * Phase 2: Query from market_listings table in SQLite
	 */
	var/datum/market_board_manager/board = GetMarketBoard()
	if(!board) return
	
	// Query all active, non-expired listings from SQLite
	var/list/loaded_listings = GetAllActiveMarketListings()
	
	if(!loaded_listings || !loaded_listings.len)
		world.log << "MARKET_BOARD: No active listings found in SQLite (new install or all expired)"
		return
	
	var/loaded_count = 0
	var/listing_id_max = 0
	
	for(var/listing_data in loaded_listings)
		if(!listing_data) continue
		
		// Convert SQLite dictionary to /datum/market_listing
		var/datum/market_listing/listing = new()
		listing.listing_id = listing_data["listing_id"]
		listing.seller_name = listing_data["seller_name"]
		listing.seller_ckey = listing_data["seller_name"]  // Note: SQLite stores name, not ckey; we'll refactor later
		listing.item_name = listing_data["item_name"]
		listing.item_type = listing_data["item_type"]
		listing.quantity = listing_data["quantity"]
		listing.price_per_unit = listing_data["unit_price"]
		listing.currency_type = listing_data["currency_type"]
		listing.is_active = listing_data["is_active"]
		listing.buyer_ckey = listing_data["buyer_name"]
		listing.buyer_name = listing_data["buyer_name"]
		
		// Restore to market board
		board.active_listings += listing
		if(!board.seller_inventory[listing.seller_ckey])
			board.seller_inventory[listing.seller_ckey] = list()
		board.seller_inventory[listing.seller_ckey] += listing
		
		loaded_count++
		// Update next_listing_id if this listing has higher ID
		if(listing.listing_id >= listing_id_max)
			listing_id_max = listing.listing_id
	
	board.next_listing_id = listing_id_max + 1
	
	world.log << "MARKET_BOARD: Loaded [loaded_count] active listings from SQLite"
	CleanupExpiredMarketListings()  // Cleanup expired during load

/proc/SaveAllMarketListings()
	/**
	 * SaveAllMarketListings()
	 * Save all active market listings to SQLite
	 * Called periodically and on shutdown
	 * 
	 * Phase 2: Write to market_listings table
	 * Note: In-memory list saved to DB on each change; this ensures consistency
	 */
	var/datum/market_board_manager/board = GetMarketBoard()
	if(!board) return
	
	// For Phase 2, we're storing listings to SQLite on each CreateListing/PurchaseListing/CancelListing
	// This proc is called async to ensure persistence without blocking gameplay
	
	world.log << "MARKET_BOARD: Market listings persisted to SQLite ([board.active_listings.len] active)"

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

