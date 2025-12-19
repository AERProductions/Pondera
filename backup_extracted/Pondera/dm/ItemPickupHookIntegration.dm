/**
 * ITEM PICKUP HOOK INTEGRATION
 * 
 * Hooks the auto-hotbar pickup system into item acquisition
 * Integrates with existing drop/pickup system to trigger auto-binding
 * 
 * Integration points:
 * - Extend /obj/items to add OnPickup() for pickup detection
 * - Call CheckAutoHotbarPickup() when items move into player inventory
 * - Maintain compatibility with existing drop/pickup verbs
 * 
 * NOTE: Get/Drop verbs are defined in Weapons.dm and kept there
 * This file provides the hook integration, not the verbs themselves
 */

// ==================== ITEM PICKUP DETECTION ====================

/obj/items
	var
		last_owner = null  // Track previous container for pickup detection

	proc/OnPickup(mob/players/M)
		/**
		 * OnPickup(M) -> null
		 * 
		 * Called when item is picked up by player
		 * Triggers auto-hotbar binding if enabled
		 * 
		 * Parameters:
		 * - M: Player acquiring the item
		 */
		
		if(!M || !istype(M, /mob/players))
			return
		
		last_owner = M
		
		// Check if auto-hotbar is enabled
		if(!M.character || !M.character.auto_hotbar_pickup)
			return
		
		// Attempt auto-hotbar binding
		CheckAutoHotbarPickup(M, src)

	proc/DetectPickup()
		/**
		 * DetectPickup() -> null
		 * 
		 * Detect if item was just picked up by comparing previous location
		 * Called from Move() after movement completes
		 * 
		 * This method detects:
		 * - Items moved from turf/ground into player inventory
		 * - Items moved from being on ground to being carried
		 */
		
		var/mob/players/M = loc
		if(!istype(M, /mob/players))
			return
		
		if(!last_owner || last_owner != M)
			// Item was just picked up by this player
			OnPickup(M)
			last_owner = M

// ==================== INTEGRATION WITH CRAFTING SYSTEMS ====================

/proc/OnItemCreated(mob/players/M, obj/items/created_item)
	/**
	 * OnItemCreated(M, created_item) -> null
	 * 
	 * Hook called when player receives crafted item
	 * Integrates with cooking, smithing, crafting systems
	 * 
	 * Parameters:
	 * - M: Player receiving item
	 * - created_item: Newly created item object
	 * 
	 * Example integration:
	 * In SmeltingSystem:
	 *   var/created = new /obj/items/Crafting/Created/Ingot()
	 *   created.Move(M)
	 *   OnItemCreated(M, created)  // Add this line
	 */
	
	if(!M || !created_item)
		return
	
	// Check if auto-hotbar enabled
	if(M.character && M.character.auto_hotbar_pickup)
		CheckAutoHotbarPickup(M, created_item)

/proc/OnItemRemoved(mob/players/M, obj/items/removed_item)
	/**
	 * OnItemRemoved(M, removed_item) -> null
	 * 
	 * Hook called when item is removed from player inventory
	 * Removes from hotbar if bound
	 * 
	 * Parameters:
	 * - M: Player losing item
	 * - removed_item: Item being removed
	 */
	
	if(!M || !M.toolbelt || !removed_item)
		return
	
	// Check if item is in hotbar
	for(var/i = 1; i <= M.toolbelt.max_slots; i++)
		if(M.toolbelt.GetSlot(i) == removed_item)
			M.toolbelt.ClearSlot(i)
			break

// ==================== EXTEND GET/DROP VERBS ====================

// NOTE: Actual Get/Drop verb implementations are in Weapons.dm
// Those verbs call OnPickup() when items are picked up
// This provides the integration framework
