// dm/Phase13A_WorldEventsAndAuctions.dm
// World Events, Auction System, and Economic Shocks
// Phase 13A: Dynamic Economy & Market Events
// Version: 1.0
// Date: 2025-12-17

// ============================================================================
// GLOBAL CONFIGURATION
// ============================================================================

var/global/world_events_enabled = TRUE
var/global/active_world_events = list()     // List of active event IDs
var/global/auction_system_ready = FALSE

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeWorldEventsSystem()
 * Called from InitializationManager.dm (Phase 4, tick 500)
 * Loads existing events and resumes active ones
 */
proc/InitializeWorldEventsSystem()
	if(!sqlite_ready)
		world.log << "[PHASE13A] Skipping world events initialization - database not ready"
		return FALSE

	world.log << "[PHASE13A] Initializing World Events System..."

	// Load all active events from database
	var/query = "SELECT event_id, event_name, event_status FROM world_events WHERE event_status IN ('planned', 'active', 'resolving') ORDER BY event_start_timestamp ASC;"
	var/result = ExecuteSQLiteQuery(query)

	if(!result)
		world.log << "[PHASE13A] No active events to load"
	else
		world.log << "[PHASE13A] Loaded world events from database"

	// Resume all active event timers
	for(var/event_id in active_world_events)
		ResumeEventTimer(event_id)

	// Check for expired auctions and auto-resolve them
	CleanupExpiredAuctions()

	auction_system_ready = TRUE
	RegisterInitComplete("Phase13A_WorldEvents")
	world.log << "[PHASE13A] World Events System initialized OK"
	return TRUE

// ============================================================================
// WORLD EVENT MANAGEMENT
// ============================================================================

/**
 * TriggerWorldEvent(event_type, severity, affected_resources_json, event_continent)
 * Creates a new world event with planned status and schedules activation
 * 
 * Args:
 *   event_type: invasion|plague|natural_disaster|festival|treasure_discovery|market_crash
 *   severity: 1-10 (affects impact magnitude and duration)
 *   affected_resources_json: {resource_type: multiplier, ...}
 *   event_continent: story|sandbox|pvp (or null for random)
 * 
 * Returns: event_id if successful, null if failed
 */
proc/TriggerWorldEvent(event_type, severity, affected_resources_json, event_continent)
	if(!sqlite_ready)
		world.log << "[PHASE13A] Database not ready"
		return null

	if(severity < 1 || severity > 10)
		world.log << "[PHASE13A] Invalid severity: [severity]"
		return null

	// Select continent if not specified
	if(!event_continent)
		event_continent = pick("story", "sandbox", "pvp")

	// Generate event name
	var/event_name = GenerateEventName(event_type, event_continent)
	var/duration_hours = 24 + (severity * 12)  // Base 24h + 12h per severity point
	var/start_time = "[Now()]"

	// TODO: Insert event into database (requires parameterized query support)
	// For now, logging the event would happen here
	var/event_id = 1  // Placeholder

	if(!event_id)
		world.log << "[PHASE13A] Failed to create event: [event_name]"
		return null

	// Add to active events list
	active_world_events += event_id

	// Schedule activation (1 hour = 150 ticks, warning period)
	spawn(150)
		ActivateWorldEvent(event_id)

	world.log << "[PHASE13A] World Event created: [event_name] (ID: [event_id])"
	world << "WARNING: WORLD EVENT INCOMING: [event_name] will begin in 1 hour!"
	return event_id

/**
 * ActivateWorldEvent(event_id)
 * Activates an event and applies price shocks to affected resources
 */
proc/ActivateWorldEvent(event_id)
	if(!sqlite_ready) return FALSE

	var/query = "SELECT * FROM world_events WHERE event_id = ?;"
	var/list/event_data = ExecuteSQLiteQuery(query, list(event_id))

	if(!event_data)
		world.log << "[PHASE13A] Event not found: [event_id]"
		return FALSE

	// Parse affected resources and apply shocks
	var/affected_resources = json_decode(event_data["affected_resources"])
	for(var/resource in affected_resources)
		var/multiplier = affected_resources[resource]
		TriggerEconomicShock("demand_spike", resource, (multiplier - 1) * 100, event_data["event_name"])

	// Update status to active
	var/update_query = "UPDATE world_events SET event_status = 'active', activation_timestamp = ? WHERE event_id = ?;"
	ExecuteSQLiteQuery(update_query, list("[Now()]", event_id))

	world.log << "[PHASE13A] Event activated: [event_data["event_name"]]"
	return TRUE

/**
 * ResolveWorldEvent(event_id, actual_outcome)
 * Resolves an active event and applies recovery phase
 */
proc/ResolveWorldEvent(event_id, actual_outcome = "")
	if(!sqlite_ready) return FALSE

	var/query = "SELECT * FROM world_events WHERE event_id = ?;"
	var/list/event_data = ExecuteSQLiteQuery(query, list(event_id))

	if(!event_data)
		world.log << "[PHASE13A] Event not found: [event_id]"
		return FALSE

	// Update status to resolved
	var/update_query = "UPDATE world_events SET event_status = 'resolved' WHERE event_id = ?;"
	ExecuteSQLiteQuery(update_query, list(event_id))

	// Parse and distribute rewards
	if(event_data["resolution_rewards"])
		var/rewards = json_decode(event_data["resolution_rewards"])
		DistributeEventRewards(event_id, rewards)

	// Begin recovery phase (prices return to baseline)
	var/affected_resources = json_decode(event_data["affected_resources"])
	for(var/resource in affected_resources)
		TriggerEconomicShock("recovery", resource, 0, "[event_data["event_name"]] resolution")

	// Log resolution
	world.log << "[PHASE13A] Event resolved: [event_data["event_name"]] | Casualties: [event_data["player_casualties"]] | Resources destroyed: [event_data["resource_destroyed"]]"
	world << "RESOLVED: [event_data["event_name"]] has concluded. Event summary: [actual_outcome]"

	// Remove from active events
	active_world_events -= event_id

	// Trigger follow-up event if applicable (chain reactions)
	if(event_data["event_type"] == "invasion")
		spawn(10)
			TriggerWorldEvent("plague", 3, json_encode(list("food" = 0.5, "medicine" = 2.0)), event_data["event_continent"])

	return TRUE

/**
 * CancelWorldEvent(event_id)
 * Cancels a planned or active event
 */
proc/CancelWorldEvent(event_id)
	if(!sqlite_ready) return FALSE

	var/update_query = "UPDATE world_events SET event_status = 'cancelled' WHERE event_id = ?;"
	ExecuteSQLiteQuery(update_query, list(event_id))

	active_world_events -= event_id
	world.log << "[PHASE13A] Event cancelled: [event_id]"
	return TRUE

/**
 * GenerateEventName(event_type, event_continent)
 * Generates a randomized event name based on type and continent
 */
proc/GenerateEventName(event_type, event_continent)
	var/prefix = pick("The", "A Terrible", "An Unexpected")
	var/location = pick("Kingdom of Freedom", "Creative Sandbox", "Battlelands")
	return "[prefix] [event_type] - [location]"

/**
 * DistributeEventRewards(event_id, rewards_json)
 * Distributes rewards to players who participated in resolving the event
 */
proc/DistributeEventRewards(event_id, rewards_json)
	world.log << "[PHASE13A] Distributing event rewards for event [event_id]"
	// TODO: Integrate with player reward system
	return TRUE

/**
 * ResumeEventTimer(event_id)
 * Resumes event timer after server restart
 */
proc/ResumeEventTimer(event_id)
	// Recalculate time remaining and reschedule
	// This is called during boot to resume pending events
	return TRUE

// ============================================================================
// AUCTION SYSTEM
// ============================================================================

/**
 * CreateAuctionListing(seller_player_id, item_type, quantity, starting_price, reserve_price)
 * Creates a new auction listing
 * 
 * Returns: listing_id if successful, null if failed
 */
proc/CreateAuctionListing(seller_player_id, item_type, quantity, starting_price, reserve_price)
	if(!sqlite_ready)
		return null

	// Validate seller has quantity
	var/seller_inventory = GetPlayerInventory(seller_player_id)
	if(!seller_inventory || seller_inventory[item_type] < quantity)
		world.log << "[PHASE13A] Seller does not have [quantity] of [item_type]"
		return null

	// Remove items from seller inventory
	RemovePlayerInventory(seller_player_id, item_type, quantity)

	// Calculate auction end time (7 days = 10080 ticks at 25ms/tick)
	var/auction_end = "[AddTime(Now(), 604800)]"  // +7 days in seconds

	// TODO: Insert auction listing into database
	var/listing_id = 1  // Placeholder

	if(!listing_id)
		// Refund inventory if listing fails
		AddPlayerInventory(seller_player_id, item_type, quantity)
		return null

	return listing_id

/**
 * PlaceBid(listing_id, bidder_player_id, bid_amount)
 * Places a bid on an active auction
 */
proc/PlaceBid(listing_id, bidder_player_id, bid_amount)
	if(!sqlite_ready)
		return FALSE

	var/query = "SELECT * FROM auction_listings WHERE listing_id = ?;"
	var/list/listing = ExecuteSQLiteQuery(query, list(listing_id))

	if(!listing)
		world.log << "[PHASE13A] Auction not found: [listing_id]"
		return FALSE

	if(listing["auction_status"] != "active")
		world.log << "[PHASE13A] Auction not active: [listing_id]"
		return FALSE

	// Validate bidder has gold
	var/bidder_gold = GetPlayerGold(bidder_player_id)
	if(bidder_gold < bid_amount)
		world.log << "[PHASE13A] Bidder insufficient gold: has [bidder_gold], needs [bid_amount]"
		return FALSE

	// Deduct gold from bidder
	RemovePlayerGold(bidder_player_id, bid_amount)

	// Refund previous highest bidder if exists
	if(listing["highest_bidder_id"])
		AddPlayerGold(listing["highest_bidder_id"], listing["highest_bid"])

	// Update listing with new highest bid
	var/bid_history = json_decode(listing["bid_history"])
	bid_history += list(list("bidder" = bidder_player_id, "amount" = bid_amount, "time" = "[Now()]"))

	var/update_query = "UPDATE auction_listings SET highest_bid = ?, highest_bidder_id = ?, bid_history = ? WHERE listing_id = ?;"
	ExecuteSQLiteQuery(update_query, list(bid_amount, bidder_player_id, json_encode(bid_history), listing_id))

	world.log << "[PHASE13A] Bid placed: [bid_amount] by player [bidder_player_id] on listing [listing_id]"
	return TRUE

/**
 * ResolveAuction(listing_id)
 * Resolves an auction when time expires
 */
proc/ResolveAuction(listing_id)
	if(!sqlite_ready)
		return FALSE

	var/query = "SELECT * FROM auction_listings WHERE listing_id = ?;"
	var/list/listing = ExecuteSQLiteQuery(query, list(listing_id))

	if(!listing)
		world.log << "[PHASE13A] Auction not found: [listing_id]"
		return FALSE

	if(!listing["highest_bidder_id"])
		// No bids - return item to seller
		var/final_price = listing["starting_price"]
		ExecuteSQLiteQuery("UPDATE auction_listings SET auction_status = 'resolved_no_bids' WHERE listing_id = ?;", list(listing_id))
	else
		// Transfer item to winner
		var/final_price = listing["highest_bid"]
		AddPlayerInventory(listing["highest_bidder_id"], listing["item_type"], listing["quantity"])

		// Transfer gold to seller
		AddPlayerGold(listing["seller_player_id"], final_price)

		ExecuteSQLiteQuery("UPDATE auction_listings SET auction_status = 'resolved' WHERE listing_id = ?;", list(listing_id))

		world.log << "[PHASE13A] Auction resolved: [listing["item_type"]] sold for [final_price]"

	return TRUE

/**
 * CancelAuction(listing_id)
 * Cancels an active auction
 */
proc/CancelAuction(listing_id)
	if(!sqlite_ready)
		return FALSE

	var/query = "SELECT * FROM auction_listings WHERE listing_id = ?;"
	var/list/listing = ExecuteSQLiteQuery(query, list(listing_id))

	// Return items to seller
	AddPlayerInventory(listing["seller_player_id"], listing["item_type"], listing["quantity"])

	// Refund any bids
	if(listing["highest_bidder_id"])
		AddPlayerGold(listing["highest_bidder_id"], listing["highest_bid"])

	ExecuteSQLiteQuery("UPDATE auction_listings SET auction_status = 'cancelled' WHERE listing_id = ?;", list(listing_id))

	world.log << "[PHASE13A] Auction cancelled: [listing_id]"
	return TRUE

// ============================================================================
// ECONOMIC SHOCK INTEGRATION
// ============================================================================

/**
 * TriggerEconomicShock(shock_type, resource, price_change_percent, trigger_event_name)
 * Triggers an economic shock that affects market prices
 * 
 * shock_type: demand_spike|supply_shortage|bubble|crash|recovery
 */
proc/TriggerEconomicShock(shock_type, resource, price_change_percent, trigger_event_name)
	// TODO: Integrate with DynamicMarketPricingSystem
	// This proc triggers immediate price changes
	// and should log shock events for player visibility

	world.log << "[PHASE13A] Economic Shock: [shock_type] on [resource] (change: [price_change_percent]%)"
	return TRUE

/**
 * ApplyMarketShock(resource, price_change_percent, duration_hours)
 * Actually applies the price change to market pricing system
 * Integrates with DynamicMarketPricingSystem.dm
 */
proc/ApplyMarketShock(resource, price_change_percent, duration_hours)
	// TODO: Integrate with DynamicMarketPricingSystem
	// This proc modifies the current_price and elasticity for the resource
	// to simulate the shock effect

	var/multiplier = 1.0 + (price_change_percent / 100.0)
	var/update_query = "UPDATE market_prices SET current_price = current_price * ? WHERE commodity_name = ?;"
	ExecuteSQLiteQuery(update_query, list(multiplier, resource))

	world.log << "[PHASE13A] Market prices updated for [resource]: multiplier [multiplier]x"
	return TRUE

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * GetPlayerInventory(player_id)
 * Returns dictionary of player's inventory
 */
proc/GetPlayerInventory(player_id)
	// TODO: Integrate with actual inventory system
	return list()

/**
 * AddPlayerInventory(player_id, item_type, quantity)
 */
proc/AddPlayerInventory(player_id, item_type, quantity)
	// TODO: Integrate with actual inventory system
	return TRUE

/**
 * RemovePlayerInventory(player_id, item_type, quantity)
 */
proc/RemovePlayerInventory(player_id, item_type, quantity)
	// TODO: Integrate with actual inventory system
	return TRUE

/**
 * GetPlayerGold(player_id)
 */
proc/GetPlayerGold(player_id)
	// TODO: Query currency_accounts table
	return 0

/**
 * AddPlayerGold(player_id, amount)
 */
proc/AddPlayerGold(player_id, amount)
	// TODO: Update currency_accounts table
	return TRUE

/**
 * RemovePlayerGold(player_id, amount)
 */
proc/RemovePlayerGold(player_id, amount)
	// TODO: Update currency_accounts table
	return TRUE

/**
 * CleanupExpiredAuctions()
 * Called during boot - resolves any expired auctions
 */
proc/CleanupExpiredAuctions()
	var/query = "SELECT listing_id FROM auction_listings WHERE auction_status = 'active' AND auction_end_time < ?;"
	var/list/expired_listings = ExecuteSQLiteQuery(query)

	if(expired_listings)
		for(var/listing_id in expired_listings)
			ResolveAuction(listing_id)

	return TRUE

/**
 * GetCurrentUTCTime()
 * Returns current UTC timestamp (or placeholder)
 */
proc/GetCurrentUTCTime()
	// TODO: Implement proper UTC timestamp
	return 0

/**
 * Now()
 * Returns current timestamp
 */
proc/Now()
	// TODO: Implement timestamp
	return 0

/**
 * SubtractTime(timestamp, seconds)
 * Returns new timestamp minus specified seconds
 */
proc/SubtractTime(timestamp, seconds)
	// TODO: Implement time arithmetic
	return timestamp

/**
 * AddTime(timestamp, seconds)
 * Returns new timestamp plus specified seconds
 */
proc/AddTime(timestamp, seconds)
	// TODO: Implement time arithmetic
	return timestamp

// ============================================================================
// END OF PHASE 13A
// ============================================================================

