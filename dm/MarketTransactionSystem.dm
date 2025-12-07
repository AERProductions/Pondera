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

/proc/DeductPlayerCurrency(mob/players/player, amount_stone)
	// Deduct currency from player
	// Returns 1 if successful, 0 if insufficient funds
	if(!player) return 0
	if(amount_stone <= 0) return 1
	
	if(!player.basecamp_stone)
		player.basecamp_stone = 0
	
	if(player.basecamp_stone < amount_stone)
		return 0
	
	player.basecamp_stone -= amount_stone
	return 1

/proc/AddPlayerCurrency(mob/players/player, amount_stone)
	// Add stone currency to player
	if(!player) return 0
	if(amount_stone <= 0) return 1
	
	if(!player.basecamp_stone)
		player.basecamp_stone = 0
	
	player.basecamp_stone += amount_stone
	player << "Received [amount_stone] stone (basecamp total: [player.basecamp_stone])"
	return 1

/proc/ValidateMarketTransaction(mob/players/buyer, obj/market_stall/stall, list/cart_items)
	// Validate that transaction can proceed
	// Returns: list(success, error_msg, total_cost)
	if(!buyer || !stall || !cart_items)
		return list(0, "Invalid transaction data", 0)
	
	if(stall.is_locked)
		return list(0, "This stall is currently closed", 0)
	
	if(!stall.owner_key)
		return list(0, "Stall has no owner", 0)
	
	// Calculate total cost
	var/total_cost = 0
	for(var/item_id in cart_items)
		if(!(item_id in stall.prices))
			return list(0, "Item [item_id] is no longer available", 0)
		
		var/quantity = cart_items[item_id]
		var/item_price = stall.prices[item_id]
		total_cost += item_price * quantity
	
	// Check if buyer has sufficient funds
	var/buyer_currency = GetPlayerCurrency(buyer)
	if(buyer_currency < total_cost)
		return list(0, "Insufficient funds. Need [total_cost], have [buyer_currency]", total_cost)
	
	return list(1, "Transaction valid", total_cost)

// ============================================================================
// TRANSACTION PROCESSING
// ============================================================================

/proc/ProcessMarketTransaction(mob/players/buyer, obj/market_stall/stall, list/cart_items)
	// Complete market transaction with currency exchange
	// Returns: 1 for success, 0 for failure
	if(!buyer || !stall || !cart_items) return 0
	
	// Validate transaction
	var/list/validation = ValidateMarketTransaction(buyer, stall, cart_items)
	if(!validation[1])
		buyer << "<b><font color=red>Transaction failed: [validation[2]]</font></b>"
		return 0
	
	var/total_cost = validation[3]
	
	// Deduct currency from buyer
	if(!DeductPlayerCurrency(buyer, total_cost))
		buyer << "<b><font color=red>Transaction failed: Unable to process payment</font></b>"
		return 0
	
	// Track purchased items in character_data if available
	for(var/item_id in cart_items)
		var/quantity = cart_items[item_id]
		
		// Add to character_data.purchased_items for tracking if it exists
		if(buyer.character)
			if(!buyer.character.purchased_items)
				buyer.character.purchased_items = list()
			
			buyer.character.purchased_items[item_id] = quantity
	
	// Add profit to stall owner's account
	if(stall.owner_key)
		stall.daily_profit += total_cost
	
	// Notify buyer
	buyer << "<b><font color=green>Purchase successful!</font></b>"
	buyer << "Total cost: [total_cost] stone"
	buyer << "Items purchased: [length(cart_items)]"
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


