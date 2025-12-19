// MarketStallUI.dm - Market Stall UI Implementation
// Implements owner and buyer interfaces for market stalls

// ============================================================================
// OWNER UI - Market Stall Management Interface
// ============================================================================

/datum/market_owner_ui
	var/mob/players/owner
	var/obj/market_stall/stall
	var/current_page = "main"
	var/selected_item = null
	var/edit_price = 0
	
	New(mob/players/O, obj/market_stall/S)
		owner = O
		stall = S
	
	proc/Display()
		// Main menu display
		switch(current_page)
			if("main")
				DisplayMainMenu()
			if("items")
				DisplayItemsPage()
			if("settings")
				DisplaySettingsPage()
			if("profits")
				DisplayProfitsPage()
			if("edit_price")
				DisplayEditPrice()
	
	proc/DisplayMainMenu()
		if(!owner || !stall) return
		
		owner << "\n--------- MARKET STALL MANAGEMENT ---------"
		owner << "Stall: [stall.stall_name]"
		owner << "Owner: [stall.owner_name]"
		owner << "Status: [stall.is_locked ? "CLOSED" : "OPEN"]"
		owner << ""
		owner << "\[1\] Manage Items ([length(stall.stall_items)] listed)"
		owner << "\[2\] View Daily Profits ([stall.daily_profit] SP)"
		owner << "\[3\] Stall Settings"
		owner << "\[4\] Exit Management"
		owner << "------------------------------------------\n"
	
	proc/DisplayItemsPage()
		if(!owner || !stall) return
		
		owner << "\n--------- ITEM MANAGEMENT ---------"
		owner << "Items Listed: [length(stall.stall_items)]"
		owner << ""
		
		if(!length(stall.stall_items))
			owner << "No items listed. Add items to your stall!"
			owner << "\[A\] Add Item"
			owner << "\[B\] Back to Main Menu"
			return
		
		// Display all items with prices
		var/index = 1
		for(var/item_id in stall.stall_items)
			var/item_name = stall.stall_items[item_id]
			var/item_price = stall.prices[item_id] || 0
			owner << "\[[index]\] [item_name] - [item_price] SP"
			index++
		
		owner << ""
		owner << "\[A\] Add Item"
		owner << "\[E\] Edit Price"
		owner << "\[R\] Remove Item"
		owner << "\[B\] Back to Main Menu"
		owner << "-----------------------------------\n"
	
	proc/DisplaySettingsPage()
		if(!owner || !stall) return
		
		owner << "\n--------- STALL SETTINGS ---------"
		owner << "Stall Name: [stall.stall_name]"
		owner << ""
		owner << "\[1\] Rename Stall"
		owner << "\[2\] [stall.is_locked ? "Open" : "Close"] Stall"
		owner << "\[3\] View Statistics"
		owner << "\[4\] Back to Main Menu"
		owner << "-----------------------------------\n"
	
	proc/DisplayProfitsPage()
		if(!owner || !stall) return
		
		owner << "\n--------- DAILY PROFITS ---------"
		owner << "Daily Profit: [stall.daily_profit] SP"
		owner << ""
		
		if(stall.daily_profit > 0)
			owner << "\[W\] Withdraw Profits"
		
		owner << "\[B\] Back to Main Menu"
		owner << "---------------------------------\n"
	
	proc/DisplayEditPrice()
		if(!owner || !selected_item) return
		
		var/item_name = stall.stall_items[selected_item]
		var/current_price = stall.prices[selected_item] || 0
		
		owner << "\n--------- EDIT PRICE ---------"
		owner << "Item: [item_name]"
		owner << "Current Price: [current_price] SP"
		owner << ""
		owner << "Enter new price (0 to cancel): "
		owner << "-------------------------------\n"

// ============================================================================
// BUYER UI - Shopping Interface
// ============================================================================

/datum/market_buyer_ui
	var/mob/players/buyer
	var/obj/market_stall/stall
	var/current_page = "main"
	var/cart_items = list()
	var/cart_total = 0
	
	New(mob/players/B, obj/market_stall/S)
		buyer = B
		stall = S
	
	proc/Display()
		// Main menu display
		switch(current_page)
			if("main")
				DisplayStorefront()
			if("cart")
				DisplayCart()
			if("checkout")
				DisplayCheckout()
	
	proc/DisplayStorefront()
		if(!buyer || !stall) return
		
		buyer << "\n--------- MARKET STALL ---------"
		buyer << "Stall: [stall.stall_name]"
		buyer << "Owner: [stall.owner_name]"
		buyer << ""
		
		var/item_count = length(stall.stall_items)
		if(!item_count)
			buyer << "This stall has no items for sale."
			buyer << "\[E\] Exit Shop"
			return
		
		// Display all items with prices
		var/index = 1
		for(var/item_id in stall.stall_items)
			var/item_name = stall.stall_items[item_id]
			var/item_price = stall.prices[item_id] || 0
			buyer << "\[[index]\] [item_name] - [item_price] SP"
			index++
		
		buyer << ""
		buyer << "\[C\] Add to Cart"
		buyer << "\[V\] View Cart ([length(cart_items)] items)"
		buyer << "\[E\] Exit Shop"
		buyer << "---------------------------------\n"
	
	proc/DisplayCart()
		if(!buyer) return
		
		buyer << "\n--------- SHOPPING CART ---------"
		
		if(!length(cart_items))
			buyer << "Your cart is empty."
			buyer << "\[B\] Back to Shop"
			return
		
		var/total = 0
		for(var/item_id in cart_items)
			var/quantity = cart_items[item_id]
			var/item_name = stall.stall_items[item_id]
			var/item_price = stall.prices[item_id] || 0
			var/line_total = item_price * quantity
			total += line_total
			buyer << "[item_name] x[quantity] - [line_total] SP"
		
		buyer << ""
		buyer << "Total: [total] SP"
		buyer << ""
		buyer << "\[C\] Checkout"
		buyer << "\[R\] Remove Item"
		buyer << "\[B\] Back to Shop"
		buyer << "---------------------------------\n"
	
	proc/DisplayCheckout()
		if(!buyer) return
		
		var/total = 0
		for(var/item_id in cart_items)
			var/quantity = cart_items[item_id]
			var/item_price = stall.prices[item_id] || 0
			total += item_price * quantity
		
		buyer << "\n--------- CHECKOUT ---------"
		buyer << "Total Cost: [total] SP"
		buyer << ""
		
		// Check buyer stone (Phase 4 deferred - actual currency system)
		buyer << "You have sufficient funds (verification Phase 4)."
		buyer << "\[P\] Purchase"
		
		buyer << "\[C\] Cancel - Return to Cart"
		buyer << "-----------------------------\n"

// ============================================================================
// OWNER UI INTERACTION HANDLER
// ============================================================================

/proc/ShowMarketStallOwnerUI(mob/players/owner, obj/market_stall/stall)
	// Owner management interface
	if(!owner || !stall) return
	
	var/datum/market_owner_ui/ui = new(owner, stall)
	ui.Display()
	
	// For now, provide basic command interface
	owner << "\nOwner Commands:"
	owner << "  say add_item <name> <price> - Add item to stall"
	owner << "  say remove_item <number> - Remove item from stall"
	owner << "  say rename_stall <new_name> - Rename your stall"
	owner << "  say lock_stall - Lock/unlock stall"
	owner << "  say withdraw - Withdraw profits\n"

// ============================================================================
// BUYER UI INTERACTION HANDLER
// ============================================================================

/proc/ShowMarketStallBuyerUI(mob/players/buyer, obj/market_stall/stall)
	// Buyer shopping interface
	if(!buyer || !stall) return
	
	if(stall.is_locked)
		buyer << "This stall is closed for business."
		return
	
	var/item_count = length(stall.stall_items)
	if(!item_count)
		buyer << "This stall has no items for sale."
		return
	
	var/datum/market_buyer_ui/ui = new(buyer, stall)
	ui.Display()
	
	// For now, provide basic command interface
	buyer << "\nShopper Commands:"
	buyer << "  say buy <number> - Add item to cart"
	buyer << "  say checkout - Proceed to purchase"
	buyer << "  say cart - View cart"
	buyer << "  say exit - Leave shop\n"

// ============================================================================
// MARKET STALL OWNER COMMANDS
// ============================================================================

// Item management, price updates, and profit withdrawal moved to MarketTransactionSystem.dm
// Stall locking and renaming procs remain here for UI management

/proc/LockStall(mob/players/owner, obj/market_stall/stall)
	// Lock/unlock stall
	if(!owner || !stall) return 0
	if(owner.key != stall.owner_key)
		owner << "ERROR: You are not the owner of this stall."
		return 0
	
	stall.is_locked = !stall.is_locked
	owner << "Stall is now [stall.is_locked ? "CLOSED" : "OPEN"]"
	return 1

/proc/RenameStall(mob/players/owner, obj/market_stall/stall, new_name)
	// Rename stall
	if(!owner || !stall) return 0
	if(owner.key != stall.owner_key)
		owner << "ERROR: You are not the owner of this stall."
		return 0
	
	stall.stall_name = new_name
	owner << "Stall renamed to: [new_name]"
	return 1

// ============================================================================
// MARKET STALL INITIALIZATION
// ============================================================================

/proc/InitializeMarketStallUI()
	world << "MARKET Market Stall UI System Initialized"

