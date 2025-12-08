// MarketTransactionSystem.dm - Complete Market Transaction Processing
// Handles actual currency exchanges, inventory updates, and profit tracking

// ============================================================================
// CURRENCY SYSTEM - Simplified basecamp resources
// ============================================================================

/proc/GetPlayerCurrency(mob/players/player)
	// Return player's stone equivalent currency value
	// For now, uses a mock basecamp_stone value tracked in mob var
	if(!player) return 0
	
	if(!player.basecamp_stone)
		player.basecamp_stone = 0
	
	return player.basecamp_stone

// Currency management moved to DualCurrencySystem.dm
// Use DualCurrencySystem procs for all currency transactions

/proc/ValidateMarketTransaction(mob/players/buyer, obj/market_stall/stall, list/cart_items)
	// Validate that transaction can proceed
	// Returns: list(success, error_msg, total_cost, error_category)
	// error_category: "invalid_data", "stall_closed", "stall_error", "item_unavailable", "insufficient_funds"
	if(!buyer || !stall || !cart_items)
		var/error = !buyer ? "buyer" : (!stall ? "stall" : "cart_items")
		world.log << "MARKET VALIDATION: Invalid transaction data (missing [error])"
		return list(0, "Invalid transaction data", 0, "invalid_data")
	
	if(stall.is_locked)
		world.log << "MARKET VALIDATION: Stall '[stall.stall_name]' is locked (buyer: [buyer.name])"
		return list(0, "This stall is currently closed", 0, "stall_closed")
	
	if(!stall.owner_key)
		world.log << "MARKET VALIDATION: Stall '[stall.stall_name]' has no owner - orphaned stall"
		return list(0, "Stall has no owner", 0, "stall_error")
	
	// Calculate total cost
	var/total_cost = 0
	for(var/item_id in cart_items)
		if(!(item_id in stall.prices))
			world.log << "MARKET VALIDATION: Item '[item_id]' not found in stall '[stall.stall_name]'"
			return list(0, "Item [item_id] is no longer available", 0, "item_unavailable")
		
		var/quantity = cart_items[item_id]
		var/item_price = stall.prices[item_id]
		total_cost += item_price * quantity
	
	// Check if buyer has sufficient funds
	var/buyer_currency = GetPlayerCurrency(buyer)
	if(buyer_currency < total_cost)
		world.log << "MARKET VALIDATION: Insufficient funds - [buyer.name] needs [total_cost], has [buyer_currency]"
		return list(0, "Insufficient funds. Need [total_cost], have [buyer_currency]", total_cost, "insufficient_funds")
	
	world.log << "MARKET VALIDATION: OK - [buyer.name] purchasing from '[stall.stall_name]' for [total_cost] stone"
	return list(1, "Transaction valid", total_cost, "success")

// ============================================================================
// TRANSACTION PROCESSING
// ============================================================================

/proc/ProcessMarketTransaction(mob/players/buyer, obj/market_stall/stall, list/cart_items)
	// Complete market transaction with currency exchange
	// Returns: 1 for success, 0 for failure
	// Logs all transactions (success and failure) for audit trail
	if(!buyer || !stall || !cart_items)
		world.log << "MARKET TRANSACTION: Invalid parameters"
		return 0
	
	// Validate transaction
	var/list/validation = ValidateMarketTransaction(buyer, stall, cart_items)
	if(!validation[1])
		world.log << "MARKET TRANSACTION FAILED: [buyer.name] at '[stall.stall_name]' - Error: [validation[2]] (Category: [validation[4]])"
		buyer << "<b><font color=red>Transaction failed: [validation[2]]</font></b>"
		return 0
	
	var/total_cost = validation[3]
	
	// Deduct currency from buyer
	if(!DeductPlayerCurrency(buyer, total_cost))
		world.log << "MARKET TRANSACTION FAILED: [buyer.name] - Unable to process payment (cost: [total_cost])"
		buyer << "<b><font color=red>Transaction failed: Unable to process payment</font></b>"
		return 0
	
	// Track purchased items in character_data if available
	var/items_purchased = 0
	for(var/item_id in cart_items)
		var/quantity = cart_items[item_id]
		items_purchased += quantity
		
		// Add to character_data.purchased_items for tracking if it exists
		if(buyer.character)
			if(!buyer.character.purchased_items)
				buyer.character.purchased_items = list()
			
			buyer.character.purchased_items[item_id] = quantity
	
	// Add profit to stall owner's account
	if(stall.owner_key)
		stall.daily_profit += total_cost
	
	// Log successful transaction
	world.log << "MARKET TRANSACTION SUCCESS: [buyer.name] -> '[stall.stall_name]' (Owner: [stall.owner_name]) - Cost: [total_cost] stone, Items: [items_purchased]"
	
	// Notify buyer
	buyer << "<b><font color=green>Purchase successful!</font></b>"
	buyer << "Total cost: [total_cost] stone"
	buyer << "Items purchased: [items_purchased]"
	for(var/item_id in cart_items)
		var/quantity = cart_items[item_id]
		var/item_name = stall.stall_items[item_id]
		if(item_name)
			buyer << "  - [item_name] x[quantity]"
	
	// Log transaction globally
	world << "<b>\[MARKET\]</b> [buyer.name] purchased from [stall.stall_name] ([stall.owner_name]) for [total_cost] stone"
	
	// Try to notify stall owner if online
	var/mob/O = locate(stall.owner_key) in world.mob
	if(O && istype(O, /mob/players))
		O << "<b><font color=gold>\[STALL\]</font> [buyer.name] purchased from your stall for [total_cost] stone</b>"
	
	return 1

// ============================================================================
// PROFIT MANAGEMENT
// ============================================================================

/proc/WithdrawStallProfitsTransaction(mob/players/owner, obj/market_stall/stall)
	// Withdraw accumulated profits from stall (transaction version with currency)
	// Returns: 1 for success, 0 for failure
	if(!owner || !stall) return 0
	if(owner.key != stall.owner_key)
		owner << "ERROR: You are not the owner of this stall."
		return 0
	
	if(stall.daily_profit <= 0)
		owner << "No profits to withdraw."
		return 0
	
	var/profit = stall.daily_profit
	stall.daily_profit = 0
	
	// Add profit to owner's currency
	if(AddPlayerCurrency(owner, profit))
		owner << "<b><font color=gold>Withdrawn [profit] stone from stall</font></b>"
		owner << "Daily profits reset."
		return 1
	
	return 0

/proc/ResetDailyProfits()
	// Called daily to reset all stalls' daily_profit counters
	for(var/obj/market_stall/stall in world.contents)
		if(stall && stall.daily_profit > 0)
			world << "\[MARKET DAILY CLOSE\] [stall.stall_name] made [stall.daily_profit] stone"
			stall.daily_profit = 0

// ============================================================================
// SYSTEM INITIALIZATION
// ============================================================================

/proc/InitializeMarketTransactionSystem()
	world << "MARKET Market Transaction System Initialized (currency conversion active)"


