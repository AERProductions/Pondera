// DeedEconomySystem.dm - Deed transfer, rental, and economics
// Enables Phase 3 features: deed sales, rentals, mortgaging
// Dependencies: DeedDataManager.dm, DeedPermissionSystem.dm, CurrencyDisplayUI.dm

/**
 * ============================================================================
 * DEED ECONOMY SYSTEM
 * ============================================================================
 *
 * Purpose:
 *   Implement deed economy features enabling players to:
 *   - Transfer deed ownership (sell to other players)
 *   - Create rental agreements (temporary access)
 *   - Track deed values and transaction history
 *   - Enforce financial obligations (future: maintenance costs)
 *
 * Features:
 *   Phase 3a: Deed Transfers (ownership change)
 *   Phase 3b: Deed Rentals (temporary permissions)
 *   Phase 3c: Deed Valuation (market-based pricing)
 *   Phase 3d: Transaction History (audit trail)
 *   Phase 3e: Transfer Notifications (party notification)
 *
 * Architecture:
 *   - DeedTransferRequest: Pending transfer data structure
 *   - DeedRentalAgreement: Active rental data structure
 *   - DeedValuation: Market pricing system
 *   - TransactionLog: Persistent transaction history
 *   - EconomyNotifications: Party notification system
 *
 * Integration Points:
 *   - DeedDataManager: Query and modify deed data
 *   - CurrencyDisplayUI: Display transfer costs
 *   - Market systems: Price discovery for valuations
 *   - TimeSave.dm: Persist rental agreements
 *
 * Future Extensions:
 *   - Mortgaging system (borrow against deed value)
 *   - Taxation system (periodic maintenance costs)
 *   - Deed insurance (protect against loss)
 *   - Deed bonds (rental securities)
 */

// ============================================================================
// DEED TRANSFER SYSTEM
// ============================================================================

var
	list/g_pending_transfers = list()     // Pending transfer requests
	list/g_transfer_history = list()      // Completed transfers log

/**
 * Initiate a deed transfer (sale)
 * Creates pending transfer request requiring both parties' confirmation
 *
 * @param token - DeedToken to transfer
 * @param seller_ckey - Current owner's ckey
 * @param buyer_ckey - New owner's ckey
 * @param price - Sale price in lucre
 * @return transfer_id if created, null if failed
 */
/proc/InitiateDeedTransfer(obj/DeedToken/token, seller_ckey, buyer_ckey, price)
	if(!token || !seller_ckey || !buyer_ckey || !price)
		return null
	
	if(seller_ckey == buyer_ckey)
		return null  // Can't sell to yourself
	
	// Validate seller owns deed
	if(!IsOwnerOfDeed(seller_ckey, token))
		return null
	
	// Create transfer request object
	var/datum/DeedTransferRequest/request = new()
	request.transfer_id = GenerateTransferId()
	request.deed_token = token
	request.seller_ckey = seller_ckey
	request.buyer_ckey = buyer_ckey
	request.price = price
	request.created_time = world.time
	request.status = "pending_acceptance"
	
	// Add to pending list
	g_pending_transfers += request
	
	// Notify both parties
	NotifyDeedTransferCreated(request)
	
	return request.transfer_id

/**
 * Accept a pending deed transfer
 * Called by either party to confirm the transaction
 *
 * @param transfer_id - ID of transfer to accept
 * @param acceptor_ckey - Player accepting the transfer
 * @return TRUE if accepted, FALSE if failed
 */
/proc/AcceptDeedTransfer(transfer_id, acceptor_ckey)
	if(!transfer_id || !acceptor_ckey)
		return FALSE
	
	var/datum/DeedTransferRequest/request = LocateTransferRequest(transfer_id)
	if(!request)
		return FALSE
	
	// Update acceptance status
	if(acceptor_ckey == request.seller_ckey)
		request.seller_accepted = TRUE
	else if(acceptor_ckey == request.buyer_ckey)
		request.buyer_accepted = TRUE
	else
		return FALSE  // Not a party to this transfer
	
	// If both parties accepted, execute transfer
	if(request.seller_accepted && request.buyer_accepted)
		return ExecuteDeedTransfer(request)
	
	return TRUE

/**
 * Execute a confirmed deed transfer
 * Transfers ownership, handles currency, updates all data
 *
 * @param request - Confirmed DeedTransferRequest
 * @return TRUE if transfer successful, FALSE if failed
 */
/proc/ExecuteDeedTransfer(datum/DeedTransferRequest/request)
	if(!request)
		return FALSE
	
	var/obj/DeedToken/token = request.deed_token
	if(!token)
		return FALSE
	
	// Currency transfer handled by caller via Market/Treasury systems
	// This function focuses on deed ownership transfer only
	// Caller is responsible for:
	//   - Validating buyer has sufficient currency
	//   - Deducting currency from buyer via DualCurrencySystem or MarketBoard
	//   - Awarding currency to seller
	
	// Transfer deed ownership
	if(!TransferDeedOwnership(token, request.buyer_ckey, request.seller_ckey))
		return FALSE
	
	// Log transaction
	var/datum/DeedTransaction/txn = new()
	txn.transaction_id = GenerateTransactionId()
	txn.deed_name = token:name
	txn.seller_ckey = request.seller_ckey
	txn.buyer_ckey = request.buyer_ckey
	txn.sale_price = request.price
	txn.transaction_time = world.time
	txn.transaction_type = "sale"
	
	g_transfer_history += txn
	
	// Update request status
	request.status = "completed"
	g_pending_transfers -= request
	
	// Notify both parties of completion
	NotifyDeedTransferCompleted(request)
	
	return TRUE

/**
 * Cancel a pending deed transfer
 *
 * @param transfer_id - ID of transfer to cancel
 * @param initiator_ckey - Player canceling transfer
 * @return TRUE if cancelled, FALSE if failed
 */
/proc/CancelDeedTransfer(transfer_id, initiator_ckey)
	if(!transfer_id || !initiator_ckey)
		return FALSE
	
	var/datum/DeedTransferRequest/request = LocateTransferRequest(transfer_id)
	if(!request)
		return FALSE
	
	// Validate initiator is a party
	if(initiator_ckey != request.seller_ckey && initiator_ckey != request.buyer_ckey)
		return FALSE
	
	// Remove from pending
	g_pending_transfers -= request
	request.status = "cancelled"
	
	// Notify both parties
	NotifyDeedTransferCancelled(request)
	
	return TRUE

/**
 * Get all pending transfers for a player
 *
 * @param player_ckey - Player's ckey
 * @return List of pending DeedTransferRequest objects
 */
/proc/GetPendingTransfersFor(player_ckey)
	if(!player_ckey)
		return list()
	
	var/list/pending = list()
	for(var/datum/DeedTransferRequest/request in g_pending_transfers)
		if(request.seller_ckey == player_ckey || request.buyer_ckey == player_ckey)
			pending += request
	
	return pending

/**
 * Locate a transfer request by ID
 *
 * @param transfer_id - Transfer ID to find
 * @return DeedTransferRequest or null
 */
/proc/LocateTransferRequest(transfer_id)
	if(!transfer_id)
		return null
	
	for(var/datum/DeedTransferRequest/request in g_pending_transfers)
		if(request.transfer_id == transfer_id)
			return request
	
	return null

// ============================================================================
// DEED RENTAL SYSTEM
// ============================================================================

var
	list/g_active_rentals = list()       // Active rental agreements
	list/g_rental_history = list()       // Completed rentals

/**
 * Create a rental agreement for a deed
 * Grants temporary access to non-owner
 *
 * @param token - DeedToken to rent
 * @param owner_ckey - Deed owner's ckey
 * @param tenant_ckey - Renter's ckey
 * @param rental_period - Duration in ticks (e.g., 3600 = 1 hour at normal tick rate)
 * @param rental_price - Price in lucre per period
 * @return rental_id if created, null if failed
 */
/proc/CreateDeedRental(obj/DeedToken/token, owner_ckey, tenant_ckey, rental_period, rental_price)
	if(!token || !owner_ckey || !tenant_ckey || !rental_period || !rental_price)
		return null
	
	if(owner_ckey == tenant_ckey)
		return null  // Can't rent to yourself
	
	// Validate owner owns deed
	if(!IsOwnerOfDeed(owner_ckey, token))
		return null
	
	// Create rental agreement
	var/datum/DeedRentalAgreement/rental = new()
	rental.rental_id = GenerateRentalId()
	rental.deed_token = token
	rental.owner_ckey = owner_ckey
	rental.tenant_ckey = tenant_ckey
	rental.rental_period = rental_period
	rental.rental_price = rental_price
	rental.start_time = world.time
	rental.end_time = world.time + rental_period
	rental.status = "active"
	
	// Add tenant to deed's allow list
	GrantDeedPermission(tenant_ckey, token, owner_ckey)
	
	// Add to active rentals
	g_active_rentals += rental
	
	// Notify both parties
	NotifyRentalCreated(rental)
	
	return rental.rental_id

/**
 * Terminate a rental agreement early
 *
 * @param rental_id - Rental ID to terminate
 * @param initiator_ckey - Player terminating (owner or tenant)
 * @return TRUE if terminated, FALSE if failed
 */
/proc/TerminateRental(rental_id, initiator_ckey)
	if(!rental_id || !initiator_ckey)
		return FALSE
	
	var/datum/DeedRentalAgreement/rental = LocateRental(rental_id)
	if(!rental)
		return FALSE
	
	// Validate initiator is party to rental
	if(initiator_ckey != rental.owner_ckey && initiator_ckey != rental.tenant_ckey)
		return FALSE
	
	// Remove tenant from allow list
	RevokeDeedPermission(rental.tenant_ckey, rental.deed_token, rental.owner_ckey)
	
	// Move to history
	g_active_rentals -= rental
	rental.status = "terminated"
	rental.end_time = world.time
	g_rental_history += rental
	
	// Notify both parties
	NotifyRentalTerminated(rental)
	
	return TRUE

/**
 * Check if rental agreement is still active
 *
 * @param rental_id - Rental ID to check
 * @return TRUE if active, FALSE if expired/terminated
 */
/proc/IsRentalActive(rental_id)
	if(!rental_id)
		return FALSE
	
	var/datum/DeedRentalAgreement/rental = LocateRental(rental_id)
	if(!rental)
		return FALSE
	
	if(rental.status != "active")
		return FALSE
	
	if(world.time > rental.end_time)
		return FALSE
	
	return TRUE

/**
 * Get all active rentals for a player (as owner or tenant)
 *
 * @param player_ckey - Player's ckey
 * @param role - "owner", "tenant", or null for both
 * @return List of DeedRentalAgreement objects
 */
/proc/GetRentalsFor(player_ckey, role)
	if(!player_ckey)
		return list()
	
	var/list/rentals = list()
	
	for(var/datum/DeedRentalAgreement/rental in g_active_rentals)
		if(role == "owner" && rental.owner_ckey == player_ckey)
			rentals += rental
		else if(role == "tenant" && rental.tenant_ckey == player_ckey)
			rentals += rental
		else if(!role)
			if(rental.owner_ckey == player_ckey || rental.tenant_ckey == player_ckey)
				rentals += rental
	
	return rentals

/**
 * Locate a rental agreement by ID
 *
 * @param rental_id - Rental ID to find
 * @return DeedRentalAgreement or null
 */
/proc/LocateRental(rental_id)
	if(!rental_id)
		return null
	
	for(var/datum/DeedRentalAgreement/rental in g_active_rentals)
		if(rental.rental_id == rental_id)
			return rental
	
	return null

// ============================================================================
// DEED VALUATION SYSTEM
// ============================================================================

/**
 * Calculate market valuation for a deed
 * Based on location, size, age, and transaction history
 *
 * @param token - DeedToken to valuate
 * @return Estimated value in lucre
 */
/proc/CalculateDeedValue(obj/DeedToken/token)
	if(!token)
		return 0
	
	var/base_value = 1000  // Base value per deed
	var/area_multiplier = 1.0
	var/location_multiplier = 1.0
	var/demand_multiplier = 1.0
	
	// Calculate area multiplier (deed size affects value)
	if(token && token:zonex)
		area_multiplier = 0.5 + (token:zonex / 100)  // Larger zones more valuable
	
	// Calculate location multiplier based on turf type at deed location
	var/turf/deed_loc = locate(token:x, token:y, token:z)
	if(deed_loc)
		var/turf_type_name = deed_loc.type
		
		// Check biome type via type name
		if(findtext(turf_type_name, "temperate"))
			location_multiplier = 1.5  // Temperate is desirable
		else if(findtext(turf_type_name, "desert"))
			location_multiplier = 0.8  // Desert less desirable
		else if(findtext(turf_type_name, "arctic"))
			location_multiplier = 0.7  // Arctic least desirable
		else if(findtext(turf_type_name, "rainforest"))
			location_multiplier = 1.3  // Rainforest desirable
		else
			location_multiplier = 1.0  // Neutral
	
	// Demand multiplier (high-traffic areas worth more)
	// Currently baseline - could be extended with player_activity_count tracking
	// Future: Track player visits to location and adjust multiplier based on foot traffic
	demand_multiplier = 1.0  // Baseline demand
	
	var/calculated_value = base_value * area_multiplier * location_multiplier * demand_multiplier
	
	return round(calculated_value)

/**
 * Estimate rental income for a deed
 * Based on deed value and standard rental yields
 *
 * @param token - DeedToken to estimate
 * @param rental_period - Duration in ticks
 * @return Estimated rental income in lucre
 */
/proc/EstimateRentalIncome(obj/DeedToken/token, rental_period)
	if(!token || !rental_period)
		return 0
	
	var/deed_value = CalculateDeedValue(token)
	var/annual_yield = 0.05  // 5% annual yield on deed value
	var/period_fraction = rental_period / 31536000  // Ticks per year
	
	return ceil(deed_value * annual_yield * period_fraction)

// ============================================================================
// DEED TRANSACTION HISTORY
// ============================================================================

/**
 * Get transaction history for a deed
 *
 * @param token - DeedToken to query
 * @param limit - Max number of transactions to return (0 = all)
 * @return List of DeedTransaction objects
 */
/proc/GetDeedTransactionHistory(obj/DeedToken/token, limit)
	if(!token)
		return list()
	
	var/list/history = list()
	var/count = 0
	
	// Get most recent transactions first
	for(var/i = g_transfer_history.len to 1 step -1)
		var/datum/DeedTransaction/txn = g_transfer_history[i]
		if(txn.deed_name == token:name)
			history += txn
			count++
			if(limit > 0 && count >= limit)
				break
	
	return history

/**
 * Get all transactions for a player
 *
 * @param player_ckey - Player's ckey
 * @param transaction_type - "sale", "rental", or null for all
 * @return List of DeedTransaction objects
 */
/proc/GetPlayerTransactions(player_ckey, transaction_type)
	if(!player_ckey)
		return list()
	
	var/list/transactions = list()
	
	for(var/datum/DeedTransaction/txn in g_transfer_history)
		if(!transaction_type || txn.transaction_type == transaction_type)
			if(txn.seller_ckey == player_ckey || txn.buyer_ckey == player_ckey)
				transactions += txn
	
	return transactions

// ============================================================================
// NOTIFICATION SYSTEM
// ============================================================================

/**
 * Notify player of deed transfer creation
 */
/proc/NotifyDeedTransferCreated(datum/DeedTransferRequest/request)
	if(!request)
		return
	
	var/seller_ckey = request.seller_ckey
	var/buyer_ckey = request.buyer_ckey
	var/deed_token = request.deed_token
	var/price = request.price || 0
	var/deed_name = deed_token ? deed_token:deedname : "Deed"
	
	// Notify seller
	for(var/mob/players/M in world)
		if(ckey(M.key) == seller_ckey)
			M << "<font color='#90EE90'>\[DEED SALE\] You have offered to sell '[deed_name]' for [price] lucre. Awaiting buyer acceptance.</font>"
	
	// Notify buyer
	for(var/mob/players/M in world)
		if(ckey(M.key) == buyer_ckey)
			M << "<font color='#87CEEB'>\[DEED SALE\] A seller is offering '[deed_name]' for [price] lucre. Use /accept_deed to accept.</font>"

/**
 * Notify player of completed transfer
 */
/proc/NotifyDeedTransferCompleted(datum/DeedTransferRequest/request)
	if(!request)
		return
	
	var/seller_ckey = request.seller_ckey
	var/buyer_ckey = request.buyer_ckey
	var/deed_token = request.deed_token
	var/price = request.price || 0
	var/deed_name = deed_token ? deed_token:deedname : "Deed"
	
	// Notify seller
	for(var/mob/players/M in world)
		if(ckey(M.key) == seller_ckey)
			M << "<font color='#FFD700'>\[DEED SALE\] Transfer complete! You sold '[deed_name]' for [price] lucre.</font>"
	
	// Notify buyer
	for(var/mob/players/M in world)
		if(ckey(M.key) == buyer_ckey)
			M << "<font color='#FFD700'>\[DEED SALE\] Transfer complete! You purchased '[deed_name]' for [price] lucre.</font>"

/**
 * Notify player of cancelled transfer
 */
/proc/NotifyDeedTransferCancelled(datum/DeedTransferRequest/request)
	if(!request)
		return
	
	var/seller_ckey = request.seller_ckey
	var/buyer_ckey = request.buyer_ckey
	var/deed_token = request.deed_token
	var/deed_name = deed_token ? deed_token:deedname : "Deed"
	
	// Notify seller
	for(var/mob/players/M in world)
		if(ckey(M.key) == seller_ckey)
			M << "<font color='#FFB6C6'>\[DEED SALE\] Transfer cancelled. Sale of '[deed_name]' was not completed.</font>"
	
	// Notify buyer
	for(var/mob/players/M in world)
		if(ckey(M.key) == buyer_ckey)
			M << "<font color='#FFB6C6'>\[DEED SALE\] Transfer cancelled. Purchase of '[deed_name]' was not completed.</font>"

/**
 * Notify player of rental creation
 */
/proc/NotifyRentalCreated(datum/DeedRentalAgreement/rental)
	if(!rental)
		return
	
	var/owner_ckey = rental.owner_ckey
	var/tenant_ckey = rental.tenant_ckey
	var/deed_token = rental.deed_token
	var/rental_price = rental.rental_price || 0
	var/rental_period = rental.rental_period || 0
	var/deed_name = deed_token ? deed_token:deedname : "Deed"
	
	// Notify owner
	for(var/mob/players/M in world)
		if(ckey(M.key) == owner_ckey)
			M << "<font color='#90EE90'>\[RENTAL\] Rental agreement created for '[deed_name]'. Rent: [rental_price] lucre, Period: [rental_period] ticks.</font>"
	
	// Notify tenant
	for(var/mob/players/M in world)
		if(ckey(M.key) == tenant_ckey)
			M << "<font color='#87CEEB'>\[RENTAL\] You have rented '[deed_name]' for [rental_price] lucre for [rental_period] ticks.</font>"

/**
 * Notify player of rental termination
 */
/proc/NotifyRentalTerminated(datum/DeedRentalAgreement/rental)
	if(!rental)
		return
	
	var/owner_ckey = rental.owner_ckey
	var/tenant_ckey = rental.tenant_ckey
	var/deed_token = rental.deed_token
	var/deed_name = deed_token ? deed_token:deedname : "Deed"
	
	// Notify owner
	for(var/mob/players/M in world)
		if(ckey(M.key) == owner_ckey)
			M << "<font color='#FFB6C6'>\[RENTAL\] Rental agreement terminated for '[deed_name]'.</font>"
	
	// Notify tenant
	for(var/mob/players/M in world)
		if(ckey(M.key) == tenant_ckey)
			M << "<font color='#FFB6C6'>\[RENTAL\] Your rental of '[deed_name]' has been terminated.</font>"

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/**
 * Generate unique transfer ID
 */
/proc/GenerateTransferId()
	return "TRANSFER_[world.time]_[rand(1, 99999)]"

/**
 * Generate unique rental ID
 */
/proc/GenerateRentalId()
	return "RENTAL_[world.time]_[rand(1, 99999)]"

/**
 * Generate unique transaction ID
 */
/proc/GenerateTransactionId()
	return "TXN_[world.time]_[rand(1, 99999)]"

// ============================================================================
// DATA STRUCTURES
// ============================================================================

/**
 * Deed transfer request - pending ownership change
 */
datum/DeedTransferRequest
	var
		transfer_id
		obj/DeedToken/deed_token
		seller_ckey
		buyer_ckey
		price
		created_time
		status  // "pending_acceptance", "completed", "cancelled"
		seller_accepted = FALSE
		buyer_accepted = FALSE

/**
 * Deed rental agreement - temporary access grant
 */
datum/DeedRentalAgreement
	var
		rental_id
		obj/DeedToken/deed_token
		owner_ckey
		tenant_ckey
		rental_period
		rental_price
		start_time
		end_time
		status  // "active", "terminated", "expired"

/**
 * Deed transaction record - completed deed economy event
 */
datum/DeedTransaction
	var
		transaction_id
		deed_name
		seller_ckey
		buyer_ckey
		sale_price
		transaction_time
		transaction_type  // "sale", "rental_created", "rental_terminated"

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * Initialize Deed Economy System
 * Called from InitializationManager.dm - Phase 6
 */
/proc/InitializeDeedEconomySystem()
	world.log << "\[INIT\] DeedEconomySystem: Initializing deed transfer and rental systems..."
	
	g_pending_transfers = list()
	g_transfer_history = list()
	g_active_rentals = list()
	g_rental_history = list()
	
	world.log << "\[INIT\] DeedEconomySystem: Ready for Phase 3 economy features"
	return TRUE
