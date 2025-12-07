// InventoryManagementExtensions.dm - Enhanced Inventory Management System
// Extends stacking system with smart merging, filtering, and market-ready inventory operations
// Supports market transactions, inventory organization, and stack optimization

// ============================================================================
// INVENTORY CONTAINER MANAGEMENT
// ============================================================================

/proc/CountItemsInInventory(mob/players/player, item_type)
	/**
	 * CountItemsInInventory(player, item_type)
	 * Returns total count of specific item type in player inventory
	 * Accounts for stacked amounts
	 * Returns: integer total count
	 */
	if(!player) return 0
	if(!item_type) return 0
	
	var/total = 0
	for(var/obj/items/item in player.contents)
		if(item.type == item_type)
			total += item.stack_amount
	
	return total

/proc/GetInventoryItemsByType(mob/players/player, item_type)
	/**
	 * GetInventoryItemsByType(player, item_type)
	 * Returns list of all item objects matching type in inventory
	 * Returns: list of /obj/items or empty list
	 */
	if(!player) return list()
	if(!item_type) return list()
	
	var/list/matching = list()
	for(var/obj/items/item in player.contents)
		if(item.type == item_type)
			matching += item
	
	return matching

/proc/GetAllInventoryItems(mob/players/player)
	/**
	 * GetAllInventoryItems(player)
	 * Returns list of all items in player inventory (non-container contents)
	 * Filters out worn equipment, only returns loose items
	 * Returns: list of /obj/items
	 */
	if(!player) return list()
	
	var/list/all_items = list()
	for(var/obj/items/item in player.contents)
		// Skip worn equipment flags
		if(item.stt_worn) continue
		all_items += item
	
	return all_items

/proc/OptimizeInventoryStacks(mob/players/player)
	/**
	 * OptimizeInventoryStacks(player)
	 * Merges all stackable items of same type into consolidated stacks
	 * Minimizes inventory clutter for market transactions
	 * Returns: 1 if optimization performed, 0 if already optimal
	 */
	if(!player) return 0
	
	var/list/item_types = list()
	var/was_optimized = 0
	
	// First pass: identify all unique item types
	for(var/obj/items/item in player.contents)
		if(!item.can_stack) continue
		if(item.type in item_types) continue
		item_types += item.type
	
	// Second pass: consolidate each type
	for(var/item_type in item_types)
		var/list/matching = GetInventoryItemsByType(player, item_type)
		if(matching.len <= 1) continue
		
		// Merge all stacks into first matching item
		var/obj/items/primary = matching[1]
		var/total_stack = primary.stack_amount
		
		for(var/i = 2 to matching.len)
			var/obj/items/secondary = matching[i]
			total_stack += secondary.stack_amount
			del secondary
		
		primary.stack_amount = total_stack
		primary.UpdateStack()
		was_optimized = 1
	
	if(was_optimized)
		player << "Inventory optimized - stacks consolidated"
	
	return was_optimized

/proc/FindItemInInventory(mob/players/player, item_type, min_stack = 1)
	/**
	 * FindItemInInventory(player, item_type, min_stack)
	 * Locates first item of type with at least min_stack amount
	 * Returns: /obj/items object or null
	 */
	if(!player) return null
	if(!item_type) return null
	
	for(var/obj/items/item in player.contents)
		if(item.type == item_type && item.stack_amount >= min_stack)
			return item
	
	return null

// ============================================================================
// INVENTORY TRANSACTION HELPERS (Market-Ready)
// ============================================================================

/proc/RemoveItemsFromInventory(mob/players/player, item_type, amount)
	/**
	 * RemoveItemsFromInventory(player, item_type, amount)
	 * Removes specified amount of item from inventory (respects stacks)
	 * Returns: 1 if successful, 0 if insufficient items
	 */
	if(!player) return 0
	if(!item_type) return 0
	if(amount <= 0) return 1
	
	// Check if we have enough
	var/available = CountItemsInInventory(player, item_type)
	if(available < amount)
		return 0
	
	// Remove items, starting from existing stacks
	var/remaining = amount
	for(var/obj/items/item in player.contents)
		if(item.type != item_type) continue
		if(remaining <= 0) break
		
		if(item.stack_amount <= remaining)
			// Remove entire stack
			remaining -= item.stack_amount
			del item
		else
			// Partial removal from this stack
			item.RemoveFromStack(remaining)
			remaining = 0
	
	return 1

/proc/AddItemsToInventory(mob/players/player, item_type, amount)
	/**
	 * AddItemsToInventory(player, item_type, amount)
	 * Adds specified amount of item to inventory
	 * Creates new stacks as needed, respects stack limits
	 * Returns: 1 if successful, 0 if failed
	 */
	if(!player) return 0
	if(!item_type) return 0
	if(amount <= 0) return 1
	
	// Get a sample item to check stack limits
	var/obj/items/sample = new item_type()
	var/max_stack = sample.stack_amount || 1
	if(!sample.can_stack) max_stack = 1
	del sample
	
	// Add items to inventory
	var/remaining = amount
	while(remaining > 0)
		var/to_add = min(remaining, max_stack)
		var/obj/items/new_item = new item_type(player)
		new_item.stack_amount = to_add
		new_item.UpdateStack()
		remaining -= to_add
	
	return 1

/proc/TransferItemsToContainer(mob/players/from_player, atom/container, item_type, amount)
	/**
	 * TransferItemsToContainer(from_player, container, item_type, amount)
	 * Transfers items from player inventory to another container (stall, vendor, etc)
	 * Returns: 1 if successful, 0 if failed (insufficient items)
	 */
	if(!from_player || !container) return 0
	
	if(!RemoveItemsFromInventory(from_player, item_type, amount))
		return 0
	
	return AddItemsToInventory(container, item_type, amount)

// ============================================================================
// INVENTORY VALIDATION & DIAGNOSTICS
// ============================================================================

/proc/ValidatePlayerInventory(mob/players/player)
	/**
	 * ValidatePlayerInventory(player)
	 * Checks for inventory corruption or invalid stacks
	 * Returns: list(is_valid, error_message, item_count, total_stack_amount)
	 */
	if(!player) return list(0, "Invalid player", 0, 0)
	
	var/item_count = 0
	var/total_stacked = 0
	var/error_count = 0
	
	for(var/obj/items/item in player.contents)
		if(!item.type)
			error_count++
			continue
		
		if(!item.can_stack && item.stack_amount != 1)
			error_count++
			continue
		
		if(item.stack_amount < 1)
			error_count++
			continue
		
		item_count++
		total_stacked += item.stack_amount
	
	var/is_valid = (error_count == 0)
	var/error_msg = (error_count > 0) ? "Errors found" : "No errors"
	
	return list(is_valid, error_msg, item_count, total_stacked)

/proc/GetInventoryDetailedSummary(mob/players/player)
	/**
	 * GetInventoryDetailedSummary(player)
	 * Returns detailed breakdown of inventory contents
	 * Format: list of list(item_name, item_type, count, stack_size)
	 * Useful for debugging and UI display
	 */
	if(!player) return list()
	
	var/list/summary = list()
	var/list/seen_types = list()
	
	for(var/obj/items/item in player.contents)
		if(item.type in seen_types) continue
		
		var/count = CountItemsInInventory(player, item.type)
		summary += list(list(
			"name" = item.name,
			"type" = "[item.type]",
			"count" = count,
			"stackable" = item.can_stack
		))
		
		seen_types += item.type
	
	return summary

// ============================================================================
// INVENTORY UI HELPERS
// ============================================================================

/proc/GetInventorySlotCount(mob/players/player)
	/**
	 * GetInventorySlotCount(player)
	 * Returns number of unique item stacks in inventory
	 * (Not the total item count, but number of "slots" used)
	 */
	if(!player) return 0
	
	var/list/unique_types = list()
	for(var/obj/items/item in player.contents)
		if(!(item.type in unique_types))
			unique_types += item.type
	
	return unique_types.len

/proc/GetInventoryWeight(mob/players/player)
	/**
	 * GetInventoryWeight(player)
	 * Calculates total inventory weight (if items have weight property)
	 * Returns: total weight or 0 if no weight system
	 */
	if(!player) return 0
	
	var/total_weight = 0
	for(var/obj/items/item in player.contents)
		// Weight calculation placeholder - would need weight var on items
		total_weight += item.stack_amount
	
	return total_weight

/proc/FormatInventoryList(mob/players/player, show_stacks = 1)
	/**
	 * FormatInventoryList(player, show_stacks)
	 * Returns formatted string of inventory for display
	 * Format: "Item Name x5 (stackable)" or "Item Name" (unstackable)
	 * Returns: multi-line string
	 */
	if(!player) return "Empty inventory"
	
	var/list/lines = list()
	var/list/seen = list()
	
	for(var/obj/items/item in player.contents)
		if(item.type in seen) continue
		
		var/count = CountItemsInInventory(player, item.type)
		if(show_stacks && item.can_stack)
			lines += "[item.name] x[count]"
		else
			lines += "[item.name]"
		
		seen += item.type
	
	if(lines.len == 0)
		return "Empty"
	
	return lines.Join("\n")

// ============================================================================
// INITIALIZATION
// ============================================================================

/proc/InitializeInventoryManagementExtensions()
	// Called during world initialization to set up inventory system
	world.log << "Inventory Management Extensions initialized"

