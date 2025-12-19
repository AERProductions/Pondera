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
		world.log << "PHASE13A Skipping world events initialization - database not ready"
		return FALSE

	world.log << "PHASE13A Initializing World Events System..."

	// Load all active events from database
	var/query = "SELECT event_id, event_name, event_status FROM world_events WHERE event_status IN ('planned', 'active', 'resolving') ORDER BY event_start_timestamp ASC;"
	var/result = ExecuteSQLiteQuery(query)

	if(!result)
		world.log << "PHASE13A No active events to load"
	else
		world.log << "PHASE13A Loaded world events from database"

	// Resume all active event timers
	for(var/event_id in active_world_events)
		ResumeEventTimer(event_id)

	// Check for expired auctions and auto-resolve them
	CleanupExpiredAuctions()

	auction_system_ready = TRUE
	RegisterInitComplete("Phase13A_WorldEvents")
	world.log << "PHASE13A World Events System initialized SUCCESS"
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
		world.log << "PHASE13A Database not ready"
		return null

	if(severity < 1 || severity > 10)
		world.log << "PHASE13A Invalid severity: [severity]"
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
		world.log << "PHASE13A Failed to create event: [event_name]"
		return null

	// Add to active events list
	active_world_events += event_id

	// Schedule activation (1 hour = 150 ticks, warning period)
	spawn(150)
		ActivateWorldEvent(event_id)

	world.log << "PHASE13A World Event created: [event_name] (ID: [event_id])"
	world << "WARNING: WORLD EVENT INCOMING: [event_name] will begin in 1 hour!"

	return event_id

/**
 * ActivateWorldEvent(event_id)
 * Transitions event from planned to active status
 * Applies price multipliers and spawns event hazards
 */
proc/ActivateWorldEvent(event_id)
	if(!sqlite_ready) return FALSE

	// Fetch event details
	var/query = "SELECT * FROM world_events WHERE event_id = ?;"
	var/list/event_data = ExecuteSQLiteQuery(query, list(event_id))

	if(!event_data)
		world.log << "PHASE13A Event not found: [event_id]"
		return FALSE

	// Update status to active
	var/update_query = "UPDATE world_events SET event_status = 'active' WHERE event_id = ?;"
	ExecuteSQLiteQuery(update_query, list(event_id))

	// Parse affected resources JSON
	var/affected_resources = json_decode(event_data["affected_resources"])

	// Apply price multipliers to each affected resource
	for(var/resource in affected_resources)
		var/multiplier = affected_resources[resource]
		TriggerEconomicShock("demand_spike", resource, (multiplier - 1) * 100, event_data["event_name"])

	// Log activation
	world.log << "PHASE13A Event activated: [event_data["event_name"]]"
	world << "ACTIVE: [event_data["event_name"]] is NOW ACTIVE in [event_data["event_continent"]]!"

	// Schedule resolution (event_duration_hours later)
	var/duration_ticks = event_data["event_duration_hours"] * 30  // 1 hour = 30 ticks (125ms per tick)
	spawn(duration_ticks)
		ResolveWorldEvent(event_id)

	return TRUE

/**
 * ResolveWorldEvent(event_id, actual_outcome)
 * Concludes an event, distributes rewards, triggers follow-ups
 */
proc/ResolveWorldEvent(event_id, actual_outcome = "")
	if(!sqlite_ready) return FALSE

	var/query = "SELECT * FROM world_events WHERE event_id = ?;"
	var/list/event_data = ExecuteSQLiteQuery(query, list(event_id))

	if(!event_data)
		world.log << "PHASE13A Event not found: [event_id]"
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
	world.log << "PHASE13A Event resolved: [event_data["event_name"]] | Casualties: [event_data["player_casualties"]] | Resources destroyed: [event_data["resource_destroyed"]]"
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
	world.log << "PHASE13A Event cancelled: [event_id]"
	return TRUE

/**
 * GenerateEventName(event_type, continent)
 * Creates a narrative event name based on type and location
 */
proc/GenerateEventName(event_type, continent)
	var/list/type_prefixes = list(
		"invasion" = list("Goblin", "Orc", "Troll", "Undead", "Demon"),
		"plague" = list("Mysterious", "Spreading", "Deadly", "Crimson", "Plague of"),
		"natural_disaster" = list("Great", "Catastrophic", "Terrible", "Apocalyptic", "Devastating"),
		"festival" = list("Summer", "Winter", "Harvest", "Spring", "Grand"),
		"treasure_discovery" = list("Ancient", "Lost", "Hidden", "Legendary", "Mythical"),
		"market_crash" = list("Economic", "Great", "Financial", "Market", "Treasury")
	)

	var/list/location_names = list(
		"story" = list("Kingdom", "Realm", "Lands", "Region", "Frontier"),
		"sandbox" = list("Sandbox", "Creative Zone", "Building Grounds", "Workshop", "Haven"),
		"pvp" = list("Battlelands", "Wastelands", "Conflict Zone", "Warzone", "Arena")
	)

	var/prefix = type_prefixes[event_type][rand(1, length(type_prefixes[event_type]))]
	var/location = location_names[continent][rand(1, length(location_names[continent]))]

	return "[prefix] [event_type] - [location]"

/**
 * RecordEventCasualty(event_id, player_id, damage_amount)
 * Tracks player casualties during world events
 */
proc/RecordEventCasualty(event_id, player_id, damage_amount)
	if(!sqlite_ready) return FALSE

	var/update_query = "UPDATE world_events SET player_casualties = player_casualties + 1, resource_destroyed = resource_destroyed + ? WHERE event_id = ?;"
	ExecuteSQLiteQuery(update_query, list(damage_amount, event_id))

	return TRUE

/**
 * DistributeEventRewards(event_id, rewards_json)
 * Distributes rewards to event participants
 */
proc/DistributeEventRewards(event_id, rewards_json)
	if(!sqlite_ready) return FALSE

	// TODO: Query players who participated in event
	// For each participant, distribute rewards from rewards_json
	// This ties into player inventory and currency systems

	world.log << "PHASE13A Distributing event rewards for event [event_id]"
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
		world.log << "PHASE13A Seller does not have [quantity] of [item_type]"
		return null

	// Remove items from seller inventory
	RemovePlayerInventory(seller_player_id, item_type, quantity)

	// Calculate auction end time (7 days = 10080 ticks at 25ms/tick)
	var/auction_end = "[AddTime(Now(), 604800)]"  // +7 days in seconds

	// TODO: Insert auction listing into database
	var/listing_id = 1  // Placeholder

	if(!listing_id)
		world.log << "PHASE13A Failed to create auction listing"
		AddPlayerInventory(seller_player_id, item_type, quantity)  // Restore items
		return null

	world.log << "PHASE13A Auction created: [item_type] x[quantity] (ID: [listing_id])"
	world << "AUCTION: [quantity] [item_type] listed by seller"

	return listing_id

/**
 * PlaceBid(listing_id, bidder_player_id, bid_amount)
 * Places a bid on an active auction
 */
proc/PlaceBid(listing_id, bidder_player_id, bid_amount)
	if(!sqlite_ready)
		return FALSE

	// Fetch current listing
	var/query = "SELECT * FROM auction_listings WHERE listing_id = ?;"
	var/list/listing = ExecuteSQLiteQuery(query, list(listing_id))

	if(!listing)
		world.log << "PHASE13A Auction not found: [listing_id]"
		return FALSE

	if(listing["auction_status"] != "active")
		world.log << "PHASE13A Auction not active: [listing_id]"
		return FALSE

	// Validate bid
	if(bid_amount <= listing["current_bid"])
		world.log << "PHASE13A Bid too low: [bid_amount] (current: [listing["current_bid"]])"
		return FALSE

	if(bid_amount < listing["reserve_price"])
		world.log << "PHASE13A Bid below reserve: [bid_amount] (reserve: [listing["reserve_price"]])"
		return FALSE

	// Check bidder has enough gold
	var/bidder_gold = GetPlayerGold(bidder_player_id)
	if(bidder_gold < bid_amount)
		world.log << "PHASE13A Bidder insufficient gold: has [bidder_gold], needs [bid_amount]"
		return FALSE

	// Lock gold in bidder account (reserved)
	ReservePlayerGold(bidder_player_id, bid_amount)

	// Parse bid history and add new bid
	var/bid_history = json_decode(listing["bid_history_json"]) || list()
	bid_history += list(list("bidder_id" = bidder_player_id, "amount" = bid_amount, "timestamp" = Now()))

	// Update listing
	var/update_query = "UPDATE auction_listings SET current_bid = ?, buyer_player_id = ?, bid_history_json = ? WHERE listing_id = ?;"
	ExecuteSQLiteQuery(update_query, list(bid_amount, bidder_player_id, json_encode(bid_history), listing_id))

	world.log << "PHASE13A Bid placed: [bid_amount] by player [bidder_player_id] on listing [listing_id]"
	world << "GOLD: Bid placed: [bid_amount] gold on [listing["item_type"]]"

	return TRUE

/**
 * ResolveAuction(listing_id)
 * Concludes an auction (called when timer expires)
 */
proc/ResolveAuction(listing_id)
	if(!sqlite_ready)
		return FALSE

	var/query = "SELECT * FROM auction_listings WHERE listing_id = ?;"
	var/list/listing = ExecuteSQLiteQuery(query, list(listing_id))

	if(!listing)
		return FALSE

	if(listing["auction_status"] != "active")
		return FALSE

	var/final_price = listing["current_bid"]
	var/buyer_id = listing["buyer_player_id"]
	var/seller_id = listing["seller_player_id"]

	if(buyer_id)
		// Auction has bids - execute sale
		var/update_query = "UPDATE auction_listings SET auction_status = 'sold', final_price = ? WHERE listing_id = ?;"
		ExecuteSQLiteQuery(update_query, list(final_price, listing_id))

		// Transfer item to buyer
		AddPlayerInventory(buyer_id, listing["item_type"], listing["quantity"])

		// Transfer gold to seller
		UnreservePlayerGold(buyer_id, final_price)
		AddPlayerGold(seller_id, final_price)

		world.log << "PHASE13A Auction resolved: [listing["item_type"]] sold for [final_price]"
		world << "DONE: Auction ended: [listing["item_type"]] sold for [final_price] gold"
	else
		// No bids - return to seller
		var/update_query = "UPDATE auction_listings SET auction_status = 'expired' WHERE listing_id = ?;"
		ExecuteSQLiteQuery(update_query, list(listing_id))

		AddPlayerInventory(seller_id, listing["item_type"], listing["quantity"])

		world.log << "PHASE13A Auction expired: [listing["item_type"]] returned to seller"
		world << "EXPIRED: Auction expired with no bids - [listing["item_type"]] returned to seller"

	return TRUE

/**
 * CancelAuction(listing_id, player_id)
 * Cancels an auction (seller only)
 */
proc/CancelAuction(listing_id, player_id)
	if(!sqlite_ready)
		return FALSE

	var/query = "SELECT * FROM auction_listings WHERE listing_id = ? AND seller_player_id = ?;"
	var/list/listing = ExecuteSQLiteQuery(query, list(listing_id, player_id))

	if(!listing)
		world.log << "PHASE13A Auction not found or not seller"
		return FALSE

	var/update_query = "UPDATE auction_listings SET auction_status = 'cancelled' WHERE listing_id = ?;"
	ExecuteSQLiteQuery(update_query, list(listing_id))

	// Return item to seller
	AddPlayerInventory(player_id, listing["item_type"], listing["quantity"])

	// Refund all bids
	var/bid_history = json_decode(listing["bid_history_json"]) || list()
	for(var/bid in bid_history)
		UnreservePlayerGold(bid["bidder_id"], bid["amount"])

	world.log << "PHASE13A Auction cancelled: [listing_id]"
	world << "CANCELLED: Auction cancelled - items and bids refunded"

	return TRUE

/**
 * GetAuctionHistory(item_type, days_back)
 * Returns list of completed auctions for analysis
 */
proc/GetAuctionHistory(item_type, days_back = 30)
	if(!sqlite_ready)
		return list()

	var/cutoff_date = SubtractTime(Now(), days_back * 86400)  // days_back in seconds

	var/query = "SELECT final_price, quantity, auction_start_timestamp FROM auction_listings WHERE item_type = ? AND auction_status = 'sold' AND auction_start_timestamp > ? ORDER BY auction_start_timestamp DESC;"
	var/list/results = ExecuteSQLiteQuery(query, list(item_type, cutoff_date))

	if(!results)
		return list()

	return results

/**
 * AnalyzeMarketSentiment(item_type, time_window_hours)
 * Analyzes recent auction activity to determine market sentiment
 */
proc/AnalyzeMarketSentiment(item_type, time_window_hours = 24)
	if(!sqlite_ready)
		return "neutral"

	var/cutoff_time = SubtractTime(Now(), time_window_hours * 3600)  // hours in seconds

	// Get active auctions
	var/query = "SELECT COUNT(*) as bid_count, AVG(current_bid - starting_price) as avg_bid_increment FROM auction_listings WHERE item_type = ? AND auction_status = 'active' AND auction_start_timestamp > ?;"
	var/list/data = ExecuteSQLiteQuery(query, list(item_type, cutoff_time))

	if(!data || data["bid_count"] == 0)
		return "neutral"

	var/bid_frequency = data["bid_count"]
	var/bid_aggression = data["avg_bid_increment"] || 0

	// Determine sentiment
	if(bid_frequency > 10 && bid_aggression > 100)
		return "bullish"
	else if(bid_frequency < 3)
		return "bearish"
	else
		return "neutral"

/**
 * CleanupExpiredAuctions()
 * Auto-resolves auctions that have expired
 * Called during boot and periodically
 */
proc/CleanupExpiredAuctions()
	if(!sqlite_ready)
		return FALSE

	var/query = "SELECT listing_id FROM auction_listings WHERE auction_status = 'active' AND auction_end_timestamp < CURRENT_TIMESTAMP;"
	var/list/expired_listings = ExecuteSQLiteQuery(query)

	if(!expired_listings)
		return TRUE

	for(var/listing_id in expired_listings)
		ResolveAuction(listing_id)

	world.log << "PHASE13A Cleaned up [length(expired_listings)] expired auctions"
	return TRUE

// ============================================================================
// ECONOMIC SHOCKS
// ============================================================================

/**
 * TriggerEconomicShock(shock_type, affected_resource, price_change_percent, triggered_by)
 * Creates an economic shock that impacts market prices
 * 
 * Args:
 *   shock_type: supply_shortage|demand_spike|panic_buying|market_crash|resource_boom|currency_devaluation|recovery
 *   affected_resource: which resource is affected
 *   price_change_percent: how much to change price (+ or -)
 *   triggered_by: narrative description of what caused it
 */
proc/TriggerEconomicShock(shock_type, affected_resource, price_change_percent, triggered_by)
	if(!sqlite_ready)
		return null

	// Determine shock duration based on type
	var/duration_hours = 24
	if(shock_type == "supply_shortage")
		duration_hours = 72
	else if(shock_type == "demand_spike")
		duration_hours = 48
	else if(shock_type == "panic_buying")
		duration_hours = 36
	else if(shock_type == "market_crash")
		duration_hours = 24
	else if(shock_type == "resource_boom")
		duration_hours = 48
	else if(shock_type == "currency_devaluation")
		duration_hours = 96
	else if(shock_type == "recovery")
		duration_hours = 168  // 1 week recovery

	// Calculate recovery rate
	var/recovery_rate = abs(price_change_percent) / duration_hours * 0.05

	// TODO: Insert shock into database
	var/shock_id = 1  // Placeholder

	if(!shock_id)
		world.log << "PHASE13A Failed to create economic shock"
		return null

	// Apply price multiplier via DynamicMarketPricingSystem
	ApplyMarketShock(affected_resource, price_change_percent, duration_hours)

	world.log << "PHASE13A Economic shock triggered: [shock_type] on [affected_resource] ([price_change_percent]%)"
	world << "SHOCK: [affected_resource] prices [price_change_percent > 0 ? "rising" : "falling"] [abs(price_change_percent)]%!"

	return shock_id

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

	world.log << "PHASE13A Market prices updated for [resource]: multiplier [multiplier]x"
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
 * ReservePlayerGold(player_id, amount)
 * Locks gold so it can't be spent (for auction bids)
 */
proc/ReservePlayerGold(player_id, amount)
	// TODO: Track reserved gold separately
	return TRUE

/**
 * UnreservePlayerGold(player_id, amount)
 * Releases reserved gold
 */
proc/UnreservePlayerGold(player_id, amount)
	// TODO: Release reserved gold
	return TRUE

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
	return timestamp + seconds

/**
 * Now()
 * Returns current BYOND world time
 */
proc/Now()
	return world.timeofday

// ============================================================================
// END OF PHASE 13A
// ============================================================================
