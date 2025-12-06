/**
 * INVENTORY STATE DATUM
 * 
 * Manages serialization/deserialization of player inventory with proper
 * stack amount tracking. Works alongside the stacking system to ensure
 * all item data (including stack_amount) persists correctly.
 * 
 * The default BYOND savefile handles contents list serialization,
 * but this datum ensures stack_amount is properly preserved.
 */

/datum/inventory_state
	var
		// List of item type paths with their stack amounts
		list/saved_items = list()
		// Format: list("type" = stack_amount, "/obj/items/ore/iron" = 5, ...)

	proc/CaptureInventory(atom/container)
		/**
		 * CaptureInventory(container)
		 * Scans a container (usually player.contents) and records all items
		 * with their exact stack amounts for later restoration.
		 */
		saved_items = list()
		
		for(var/obj/items/item in container)
			if(!item.type) continue
			
			var/item_path = "[item.type]"
			var/amount = item.stack_amount
			
			if(item_path in saved_items)
				// Item type already recorded - add to stack
				saved_items[item_path] += amount
			else
				// First occurrence of this item type
				saved_items[item_path] = amount

	proc/RestoreInventory(atom/container)
		/**
		 * RestoreInventory(container)
		 * Recreates inventory from saved state, spawning items with
		 * correct stack amounts. Used during character load to fix
		 * any stacking issues from corruption or partial saves.
		 */
		if(!saved_items || !saved_items.len) return
		
		for(var/item_path in saved_items)
			var/amount = saved_items[item_path]
			var/path = text2path(item_path)
			
			if(!path) continue  // Skip invalid paths
			if(!ispath(path, /obj/items)) continue  // Skip non-items
			
			// Create the item in the container
			var/obj/items/item = new path(container)
			if(item && item.can_stack)
				item.stack_amount = amount
				item.UpdateStack()

	proc/ValidateInventory(atom/container)
		/**
		 * ValidateInventory(container)
		 * Checks if inventory state matches actual contents.
		 * Returns 1 if valid, 0 if corruption detected.
		 * Useful for debugging or logging suspicious states.
		 */
		var/list/actual = list()
		for(var/obj/items/item in container)
			if(!item.type) continue
			var/item_path = "[item.type]"
			actual[item_path] = (actual[item_path] || 0) + item.stack_amount
		
		if(actual.len != saved_items.len) return 0
		
		for(var/item_path in saved_items)
			if(saved_items[item_path] != actual[item_path])
				return 0
		
		return 1
