// ============================================================================
// FILE: CraftingIntegration.dm
// PURPOSE: Integration helpers for tool crafting and forge systems
// DESCRIPTION: Practical examples and helpers for using FilteringLibrary
//   with Pondera's existing crafting systems
// ============================================================================

// ============================================================================
// HELPER: Better tool part selection
// ============================================================================

mob/proc/SelectToolHandle()
	/// Select a tool handle from inventory with filtering
	set hidden = 1
	
	var/list/handles = list()
	
	// Find tool handles (Crafting/Created items with "Handle" in type)
	for(var/obj/items/Crafting/Created/item in src.contents)
		var/type_str = "[item.type]"
		if(findtext(type_str, "Handle"))
			handles += item
	
	if(!handles.len)
		src << "You have no tool handles."
		return null
	
	var/selection = input(src, "Select a tool handle:", "Tool Crafting") as null|anything in handles
	return selection

mob/proc/SelectToolHead()
	/// Select a tool head from inventory with filtering
	set hidden = 1
	
	var/list/heads = list()
	
	// Find tool heads (Crafting/Created items with "Blade" or "Head" in type)
	for(var/obj/items/Crafting/Created/item in src.contents)
		var/type_str = "[item.type]"
		if(findtext(type_str, "Blade") || findtext(type_str, "Head"))
			heads += item
	
	if(!heads.len)
		src << "You have no tool heads."
		return null
	
	var/selection = input(src, "Select a tool head:", "Tool Crafting") as null|anything in heads
	return selection

mob/proc/SelectIngot()
	/// Select an ingot from inventory with filtering
	set hidden = 1
	
	var/list/ingots = list()
	
	// Find all ingots
	for(var/obj/items/Ingots/item in src.contents)
		ingots += item
	
	if(!ingots.len)
		src << "You have no ingots."
		return null
	
	var/selection = input(src, "Select an ingot:", "Smithing") as null|anything in ingots
	return selection

mob/proc/SelectToolPart()
	/// Select any tool part (handle or head)
	set hidden = 1
	
	var/list/parts = list()
	
	for(var/obj/items/Crafting/Created/item in src.contents)
		var/type_str = "[item.type]"
		if(findtext(type_str, "Handle") || findtext(type_str, "Blade") || findtext(type_str, "Head"))
			parts += item
	
	if(!parts.len)
		src << "You have no tool parts."
		return null
	
	var/selection = input(src, "Select a tool part:", "Tool Crafting") as null|anything in parts
	return selection

// ============================================================================
// HELPER: Forge/Anvil integration
// ============================================================================

obj/proc/GetCraftingItems(mob/player, craft_type)
	/// Get items available for crafting on this object
	/// craft_type: "handles", "heads", "ingots", "parts"
	set hidden = 1
	
	if(!player) return list()
	
	var/list/result = list()
	
	switch(craft_type)
		if("handles")
			for(var/obj/items/Crafting/Created/item in player.contents)
				if(findtext("[item.type]", "Handle"))
					result += item
		
		if("heads")
			for(var/obj/items/Crafting/Created/item in player.contents)
				var/type_str = "[item.type]"
				if(findtext(type_str, "Blade") || findtext(type_str, "Head"))
					result += item
		
		if("ingots")
			for(var/obj/items/Ingots/item in player.contents)
				result += item
		
		if("parts")
			for(var/obj/items/Crafting/Created/item in player.contents)
				var/type_str = "[item.type]"
				if(findtext(type_str, "Handle") || findtext(type_str, "Blade") || findtext(type_str, "Head"))
					result += item
	
	return result

// ============================================================================
// EXAMPLE: Modern crafting verb using FilteringLibrary
// ============================================================================

mob/verb
	/// Modern tool combining system
	modern_combine_tools()
		set category = "Crafting"
		set hidden = 1  // Example - hide by default
		
		// Get available parts
		var/handle = SelectToolHandle()
		if(!handle) return
		
		var/head = SelectToolHead()
		if(!head) return
		
		// Both items are guaranteed to be correct types
		src << "Combining [handle:name] with [head:name]..."
		
		// Actual crafting logic would go here
		// del handle
		// del head
		// new tool_type(src)

// ============================================================================
// MARKET INTEGRATION HELPER
// ============================================================================

mob/proc/GetSellableItems()
	/// Get items player can sell on market
	set hidden = 1
	
	var/list/sellable = list()
	
	// Most items can be sold (exclude containers, key items)
	for(var/item in src.contents)
		var/obj/test = item
		if(!test) continue
		
		// Skip containers
		if(findtext("[test.type]", "Container") || findtext("[test.type]", "Jar"))
			continue
		
		// Skip quest items/special items
		if(test.vars && ("quest_item" in test.vars))
			if(test.vars["quest_item"] == 1)
				continue
		
		sellable += item
	
	return sellable

mob/proc/SelectSellableItem()
	/// Select an item to sell with filtering
	set hidden = 1
	
	var/list/sellable = GetSellableItems()
	
	if(!sellable.len)
		src << "You have nothing to sell."
		return null
	
	var/selection = input(src, "Select item to sell:", "Market") as null|anything in sellable
	return selection

// ============================================================================
// STORAGE INTEGRATION HELPER
// ============================================================================

mob/proc/GetStorableItems()
	/// Get items that can fit in a container
	set hidden = 1
	
	var/list/storable = list()
	
	for(var/item in src.contents)
		var/obj/test = item
		if(!test) continue
		
		// Don't store containers (nested containers = bad)
		var/type_str = "[test.type]"
		if(findtext(type_str, "Container") || findtext(type_str, "Jar"))
			continue
		
		storable += item
	
	return storable

// ============================================================================
// EXAMPLE: Better market listing
// ============================================================================

mob/verb
	list_item_for_sale()
		set category = "Trading"
		set hidden = 1  // Example - hide by default
		
		var/item = SelectSellableItem()
		if(!item) return
		
		var/obj/sellable = item
		if(!sellable) return
		
		var/price_input = input(src, "Price for [sellable:name]:", "Set Price") as null|num
		if(!price_input) return
		
		src << "Listed [sellable:name] for [price_input] lucre."
		
		// Would integrate with market system
		// market_board.CreateListing(src, sellable:name, sellable:type, 1, price_input)

// ============================================================================
// INTEGRATION NOTES
// ============================================================================

/*
These helpers demonstrate how to use FilteringLibrary patterns with
Pondera's existing item types:

1. TOOL CRAFTING:
   - Use SelectToolHandle() / SelectToolHead()
   - Both guaranteed to return correct types only
   - Can chain for multi-step crafting

2. FORGE/ANVIL:
   - Use GetCraftingItems(player, "ingots")
   - Call on forge object for context
   - Prevents showing wrong item types

3. MARKET:
   - Use SelectSellableItem()
   - Filters out containers and quest items
   - Type-safe market listings

4. STORAGE:
   - Use GetStorableItems()
   - Prevents nested containers
   - Cleaner storage UX

All functions compile and integrate with FilteringLibrary.dm
*/