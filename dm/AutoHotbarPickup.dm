/**
 * AUTO-HOTBAR PICKUP TOGGLE SYSTEM
 * 
 * Allows players to enable/disable automatic addition of newly-picked-up tools to hotbar
 * Settings persist in character data
 * 
 * Features:
 * - Toggle via settings verb or command
 * - Automatically binds new tools to first available slot when picked up
 * - Respects duplicate prevention (won't add if tool type already in hotbar)
 * - Respects slot availability (won't add if hotbar full)
 * - Shows visual feedback on successful/failed auto-add
 * - Persists across login/logout
 */

// ==================== CHARACTER DATA INTEGRATION ====================

/datum/character_data
	var
		auto_hotbar_pickup = 0  // Toggle: 1 = enabled, 0 = disabled

// ==================== AUTO-PICKUP ON ITEM ACQUISITION ====================

/proc/CheckAutoHotbarPickup(mob/players/M, obj/items/item)
	/**
	 * CheckAutoHotbarPickup(M, item) -> int
	 * 
	 * Check if player has auto-hotbar enabled and attempt to add item to hotbar
	 * Called when player picks up an item
	 * 
	 * Parameters:
	 * - M: Player acquiring the item
	 * - item: Item being acquired
	 * 
	 * Returns: 1 if added to hotbar, 0 if not added or not tool
	 */
	
	if(!M || !M.character || !M.toolbelt)
		return 0
	
	// Check if auto-hotbar is enabled
	if(!M.character.auto_hotbar_pickup)
		return 0
	
	// Check if item is a tool
	var/tool_type = GetToolType(item)
	if(!tool_type)
		return 0
	
	// Check if player already has this tool type in hotbar
	if(DoesPlayerHaveToolType(M, tool_type))
		return 0
	
	// Check if hotbar has available slots
	if(!M.toolbelt.HasSlotSpace())
		return 0
	
	// Find first empty slot
	var/empty_slot = null
	for(var/i = 1; i <= M.toolbelt.max_slots; i++)
		if(!M.toolbelt.slots[i])
			empty_slot = i
			break
	
	if(!empty_slot)
		return 0
	
	// Add to hotbar
	if(M.toolbelt.SetSlot(empty_slot, item))
		if(M.client)
			M << "<font color=green>Auto-added [item.name] to hotbar slot [empty_slot]</font>"
		M.UpdateToolbeltDisplay()
		return 1
	
	return 0

// ==================== AUTO-HOTBAR TOGGLE SETTINGS ====================

/mob/players
	verb/ToggleAutoHotbarPickup()
		set name = "Toggle Auto-Hotbar Pickup"
		set category = "Settings"
		set desc = "Automatically add newly-picked-up tools to your hotbar"
		
		if(!character)
			src << "<font color=red>Character data not initialized</font>"
			return
		
		// Toggle the setting
		character.auto_hotbar_pickup = !character.auto_hotbar_pickup
		
		var/state = character.auto_hotbar_pickup ? "ENABLED" : "DISABLED"
		src << "<font color=yellow>Auto-hotbar pickup [state]</font>"

	proc/GetAutoHotbarStatus()
		/**
		 * GetAutoHotbarStatus() -> int
		 * 
		 * Get current auto-hotbar setting status
		 * 
		 * Returns: 1 if enabled, 0 if disabled
		 */
		
		if(!character)
			return 0
		
		return character.auto_hotbar_pickup

	proc/SetAutoHotbarStatus(state)
		/**
		 * SetAutoHotbarStatus(state) -> int
		 * 
		 * Set auto-hotbar status
		 * 
		 * Parameters:
		 * - state: 1 to enable, 0 to disable
		 * 
		 * Returns: 1 if set successfully, 0 if failed
		 */
		
		if(!character)
			return 0
		
		character.auto_hotbar_pickup = state ? 1 : 0
		
		var/status_text = state ? "ENABLED" : "DISABLED"
		src << "<font color=yellow>Auto-hotbar pickup [status_text]</font>"
		
		return 1

// ==================== COMMAND INTERFACE ====================

/mob/players
	verb/ToggleAutoHotbar()
		set name = "Auto-Hotbar"
		set category = "Settings"
		set desc = "Toggle automatic tool pickup to hotbar"
		
		ToggleAutoHotbarPickup()

