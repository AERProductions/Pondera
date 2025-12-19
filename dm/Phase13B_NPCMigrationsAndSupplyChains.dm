// dm/Phase13B_NPCMigrationsAndSupplyChains.dm
// NPC Trading Routes, Supply Chains, and Logistics Bottlenecks
// Phase 13B: Dynamic Economy - NPC Movement & Trade
// Version: 1.0
// Date: 2025-12-17

// ============================================================================
// GLOBAL CONFIGURATION
// ============================================================================

var/global/supply_chains_enabled = TRUE
var/global/active_supply_chains = list()     // List of active chain IDs
var/global/npc_migration_system_ready = FALSE

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeSupplyChainSystem()
 * Called from InitializationManager.dm (Phase 4, tick 515)
 * Loads existing routes and resumes active caravans
 */
proc/InitializeSupplyChainSystem()
	if(!sqlite_ready)
		world.log << "PHASE13B Skipping supply chain initialization - database not ready"
		return FALSE

	world.log << "PHASE13B Initializing Supply Chain System..."

	// Load all active migration routes from database
	var/query = "SELECT route_id, route_name FROM npc_migration_routes WHERE is_active = 1;"
	var/result = ExecuteSQLiteQuery(query)

	if(!result)
		world.log << "PHASE13B No active migration routes found"
	else
		world.log << "PHASE13B Loaded migration routes from database"

	// Load all active supply chains
	var/chain_query = "SELECT chain_id FROM supply_chains WHERE chain_status IN ('in_transit', 'delayed');"
	var/chain_result = ExecuteSQLiteQuery(chain_query)

	if(!chain_result)
		world.log << "PHASE13B No active supply chains to resume"

	// Resume caravan timers
	for(var/chain_id in active_supply_chains)
		ResumeCaravanTimer(chain_id)

	npc_migration_system_ready = TRUE
	RegisterInitComplete("Phase13B_SupplyChains")
	world.log << "PHASE13B Supply Chain System initialized OK"
	return TRUE

// ============================================================================
// MIGRATION ROUTE MANAGEMENT
// ============================================================================

/**
 * CreateMigrationRoute(route_name, origin_region, destination_region, waypoints_json)
 * Creates a new NPC migration route
 * 
 * Returns: route_id if successful, null if failed
 */
proc/CreateMigrationRoute(route_name, origin_region, destination_region, waypoints_json)
	// TODO: Insert route into npc_migration_routes table
	world.log << "PHASE13B Migration route created: [route_name]"
	return 1

/**
 * DeleteMigrationRoute(route_id)
 * Deletes a migration route and cancels associated caravans
 */
proc/DeleteMigrationRoute(route_id)
	// TODO: Remove route and auto-cancel caravans
	world.log << "PHASE13B Route deleted: [route_id]"
	return TRUE

/**
 * GetMigrationRoutesByRegion(region)
 * Returns all routes passing through a region
 */
proc/GetMigrationRoutesByRegion(region)
	// TODO: Query routes that pass through this region
	return list()

/**
 * GetMigrationRoutesByResource(resource_type)
 * Returns all routes frequently trading this resource
 */
proc/GetMigrationRoutesByResource(resource_type)
	// TODO: Query routes that primarily trade this resource
	// based on supply_chains historical data
	return list()

// ============================================================================
// CARAVAN MANAGEMENT
// ============================================================================

/**
 * InitiateTradeCaravan(origin_npc_id, destination_npc_id, route_id, resource_type, quantity)
 * Starts a caravan journey with trade goods
 * 
 * Returns: chain_id if successful, null if failed
 */
proc/InitiateTradeCaravan(origin_npc_id, destination_npc_id, route_id, resource_type, quantity)
	if(!sqlite_ready)
		return null

	// Validate origin NPC has quantity
	var/npc_inventory = GetNPCInventory(origin_npc_id)
	if(npc_inventory[resource_type] < quantity)
		return null

	// Remove goods from origin
	RemoveNPCInventory(origin_npc_id, resource_type, quantity)

	// TODO: Insert supply chain record into database
	var/chain_id = 1  // Placeholder

	// TODO: Calculate travel time and schedule delivery
	// spawn(travel_time_ticks) DeliverCaravan(chain_id)

	active_supply_chains += chain_id

	world.log << "PHASE13B Caravan initiated: [quantity] [resource_type] from NPC [origin_npc_id]"
	return chain_id

/**
 * DeliverCaravan(chain_id)
 * Completes caravan journey and transfers goods to destination
 */
proc/DeliverCaravan(chain_id)
	if(!sqlite_ready)
		return FALSE

	// TODO: Query supply_chains record for chain_id
	// Transfer goods to destination NPC
	// Update supply_chains status to delivered
	// Calculate profit and update NPC wealth

	world.log << "PHASE13B Caravan delivered: [chain_id]"
	return TRUE

/**
 * InterruptCaravan(chain_id, disruption_reason)
 * Interrupts a caravan (robbery, disaster, route danger)
 */
proc/InterruptCaravan(chain_id, disruption_reason)
	if(!sqlite_ready)
		return FALSE

	// TODO: Update supply_chains status to disrupted
	// Goods may be lost or recovered
	// May trigger NPC to switch routes

	world.log << "PHASE13B Caravan interrupted: [chain_id] - Reason: [disruption_reason]"
	return TRUE

/**
 * RerouteCaravan(chain_id, new_route_id)
 * Changes a caravan's route mid-journey
 */
proc/RerouteCaravan(chain_id, new_route_id)
	if(!sqlite_ready)
		return FALSE

	// TODO: Update caravan route and recalculate delivery time
	world.log << "PHASE13B Caravan rerouted: [chain_id] to route [new_route_id]"
	return TRUE

// ============================================================================
// SUPPLY CHAIN STATUS & MONITORING
// ============================================================================

/**
 * GetSupplyChainStatus(resource_type)
 * Returns current supply chain status for a resource (in_stock | shortage | surplus | disrupted)
 */
proc/GetSupplyChainStatus(resource_type)
	// TODO: Query supply_chains for active trades of this resource
	// Calculate: 
	//   - Total in_transit goods
	//   - Average delivery time
	//   - Disruption rate
	//   - Current price trend
	// Return overall status

	return "normal"

/**
 * UpdateSupplyChainTraffic(route_id)
 * Updates traffic volume and congestion on a route
 */
proc/UpdateSupplyChainTraffic(route_id)
	// TODO: Count active caravans on route
	// Increase danger/difficulty if congested
	world.log << "PHASE13B Route traffic updated: [route_id]"
	return TRUE

/**
 * UpdateRoutesDanger(route_id, danger_delta)
 * Increases or decreases danger level of a route (affects NPC decisions)
 */
proc/UpdateRoutesDanger(route_id, danger_delta)
	if(!sqlite_ready)
		return FALSE

	// TODO: Increment danger_level by danger_delta
	// Clamp to 1-10
	// Notify merchants about dangerous routes
	// May trigger NPCs to abandon this route

	world.log << "PHASE13B Route [route_id] danger increased by [danger_delta]"
	return TRUE

// ============================================================================
// PRICE DYNAMICS ALONG ROUTES
// ============================================================================

/**
 * UpdatePriceAlongRoute(route_id, resource_type)
 * Calculates how prices change as caravan travels
 * Price increases with travel time (cost of goods in transit)
 */
proc/UpdatePriceAlongRoute(route_id, resource_type)
	if(!sqlite_ready)
		return FALSE

	// TODO: Fetch route travel_time_hours
	// Fetch current prices at origin and destination
	// Calculate: price_delta = (destination_price - origin_price) / travel_time_hours
	// Price increases per hour of travel as time value accrues
	// Update expected prices at each waypoint

	world.log << "PHASE13B Prices updated along route [route_id] for [resource_type]"
	return TRUE

/**
 * CalculateTradeProfit(origin_price, destination_price, quantity, distance_hours)
 * Calculates potential profit from a caravan trade
 * 
 * Returns: profit_amount or negative if net loss
 */
proc/CalculateTradeProfit(origin_price, destination_price, quantity, distance_hours)
	// Profit = (destination_price - origin_price) * quantity - travel_cost
	// travel_cost = distance_hours * caravan_maintenance_per_hour
	var/travel_cost = distance_hours * 5  // 5g per hour placeholder

	var/profit = ((destination_price - origin_price) * quantity) - travel_cost
	return profit

// ============================================================================
// NPC TRADING LOOP
// ============================================================================

/**
 * ResumeCaravanTimer(chain_id)
 * Resumes a caravan timer after server restart
 */
proc/ResumeCaravanTimer(chain_id)
	// TODO: Recalculate delivery time and reschedule
	return TRUE

/**
 * UpdateNPCTradeTarget(npc_id)
 * Updates an NPC's next trade destination based on profit analysis
 */
proc/UpdateNPCTradeTarget(npc_id)
	// TODO: Evaluate all possible routes
	// Select most profitable route based on:
	//   - Current prices at destinations
	//   - Route danger level
	//   - Travel time
	//   - NPC inventory
	// Set NPC trade_target and caravan_deadline

	world.log << "PHASE13B NPC [npc_id] trade target updated"
	return TRUE

/**
 * NPCTradingLoop()
 * Background loop: periodically updates NPC trading decisions
 * Runs every 50 ticks (62.5 seconds)
 */
proc/NPCTradingLoop()
	set background = 1
	set waitfor = 0

	while(TRUE)
		sleep(50)

		if(!supply_chains_enabled) continue

		// TODO: Get all active NPCs
		// For each NPC that finished trading:
		//   - Call UpdateNPCTradeTarget()
		//   - Start new caravan if profitable
	return

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * GetNPCInventory(npc_id)
 * Returns dictionary of NPC's inventory
 */
proc/GetNPCInventory(npc_id)
	// TODO: Integrate with NPC persistent state
	return list()

/**
 * AddNPCInventory(npc_id, item_type, quantity)
 */
proc/AddNPCInventory(npc_id, item_type, quantity)
	// TODO: Update NPC inventory
	return TRUE

/**
 * RemoveNPCInventory(npc_id, item_type, quantity)
 */
proc/RemoveNPCInventory(npc_id, item_type, quantity)
	// TODO: Update NPC inventory
	return TRUE

// ============================================================================
// END OF PHASE 13B
// ============================================================================

