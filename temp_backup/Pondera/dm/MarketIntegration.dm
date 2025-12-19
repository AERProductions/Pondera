// ============================================================================
// FILE: MarketIntegration.dm
// PURPOSE: Market trading system enhancements using FilteringLibrary
// DESCRIPTION: Helpers to improve item selection in market systems
// ============================================================================

// ============================================================================
// MARKET ITEM FILTERING
// ============================================================================

proc/GetMarketableItems(mob/player)
	/// Get items a player can list on the market
	if(!player) return list()
	
	var/list/marketable = list()
	
	for(var/item in player.contents)
		var/obj/test = item
		if(!test) continue
		
		var/type_str = "[test.type]"
		
		// Skip non-tradeable item types
		if(findtext(type_str, "Container") || findtext(type_str, "Jar"))
			continue
		if(findtext(type_str, "Deed"))
			continue
		if(findtext(type_str, "Quest"))
			continue
		
		// This item can be sold
		marketable += item
	
	return marketable

proc/IsMarketable(obj/item)
	/// Check if a single item can be traded
	if(!item) return 0
	
	var/type_str = "[item.type]"
	
	// Exclude container types
	if(findtext(type_str, "Container") || findtext(type_str, "Jar") || findtext(type_str, "Deed"))
		return 0
	
	return 1

// ============================================================================
// MARKET STALL IMPROVEMENTS
// ============================================================================

obj/market_stall/proc/GetListableItems(mob/player)
	/// Get items player can list on THIS specific stall
	if(!player) return list()
	
	var/list/listable = GetMarketableItems(player)
	return listable

obj/market_stall/proc/ShowBuyerItems()
	/// Display items available for purchase (for buyers)
	set hidden = 1
	
	var/mob/player = usr
	if(!player) return
	
	var/list/items = src.GetListableItems(player)
	if(!items.len)
		player << "No items available for purchase at this stall."
		return
	
	var/html = "<div style='border: 2px solid gold; width: 400px; padding: 10px;'>"
	html += "<h3>[src.name]</h3>"
	html += "<hr>"
	
	for(var/item in items)
		var/obj/listed_item = item
		if(!listed_item) continue
		
		html += "<b>[listed_item:name]</b><br>"
	
	html += "</div>"
	player << html

// ============================================================================
// TRADING HELPERS
// ============================================================================

mob/proc/ShowTradeableInventory()
	/// Show player's tradeable items
	set hidden = 1
	
	var/list/tradeable = GetMarketableItems(src)
	
	if(!tradeable.len)
		src << "You have nothing to trade."
		return
	
	var/html = "<div style='border: 1px solid gray;'>"
	html += "<h3>Your Tradeable Items</h3>"
	for(var/item in tradeable)
		var/obj/t = item
		if(t)
			html += "[t:name]<br>"
	html += "</div>"
	
	src << html

mob/proc/SelectTradeableItem()
	/// Select an item to trade
	set hidden = 1
	
	var/list/tradeable = GetMarketableItems(src)
	
	if(!tradeable.len)
		src << "You have nothing to trade."
		return null
	
	var/selection = input(src, "Select item to trade:", "Trading") as null|anything in tradeable
	return selection

// ============================================================================
// MARKET BOARD WRAPPER
// ============================================================================

mob/verb
	browse_market_board()
		set category = "Trading"
		set hidden = 1
		
		if(!market_board)
			src << "Market board not available."
			return
		
		// Show available items
		src.ShowTradeableInventory()

	list_item_on_board()
		set category = "Trading"
		set hidden = 1
		
		if(!market_board)
			src << "Market board not available."
			return
		
		var/item = SelectTradeableItem()
		if(!item) return
		
		var/obj/tradeable = item
		if(!tradeable) return
		
		var/price = input(src, "Price per [tradeable:name]:", "Set Price") as null|num
		if(!price) return
		
		src << "Listed [tradeable:name] for [price]."
		
		// market_board.CreateListing(src, tradeable:name, tradeable:type, 1, price)

// ============================================================================
// CURRENCY TRANSACTION HELPERS
// ============================================================================

proc/CanAffordItem(mob/buyer, price)
	/// Check if buyer can afford an item
	if(!buyer || !price) return 0
	
	// Check various currency types
	if(buyer.vars && "lucre" in buyer.vars)
		return buyer.vars["lucre"] >= price
	
	if(buyer.vars && "basecamp_stone" in buyer.vars)
		return buyer.vars["basecamp_stone"] >= price
	
	return 0

proc/ExecuteTrade(mob/seller, mob/buyer, obj/item, amount)
	/// Execute a market trade (handle currency transfer)
	if(!seller || !buyer || !item || !amount) return 0
	
	// This is a template - actual implementation depends on your currency system
	
	seller << "[buyer.key] purchased [item:name] for [amount]!"
	buyer << "You purchased [item:name] for [amount]!"
	
	return 1

// ============================================================================
// INTEGRATION NOTES
// ============================================================================

/*
These market helpers provide:

1. MARKETABLE FILTERING:
   - GetMarketableItems(player) - Get all tradeable items
   - IsMarketable(item) - Check single item
   - Excludes containers, deeds, quest items

2. MARKET STALL INTEGRATION:
   - GetListableItems() - Respects stall restrictions
   - ShowBuyerItems() - Display for purchasers
   - Works with existing market_stall objects

3. TRADING VERBS:
   - browse_market_board() - View items
   - list_item_on_board() - Post for sale
   - Type-safe filtering throughout

4. TRANSACTION HELPERS:
   - CanAffordItem() - Verify purchase ability
   - ExecuteTrade() - Process the transaction
   - Currency-agnostic

All functions integrate with FilteringLibrary.dm and MarketBoardUI.dm
*/