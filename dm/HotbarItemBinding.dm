/*
 * HOTBAR ITEM BINDING SYSTEM - SIMPLIFIED
 * 
 * Drag-and-drop binding: Player drags item from inventory to hotbar slot.
 * Automatic equip: When item is placed in slot, it's auto-equipped.
 * One-button activation: Press hotkey (1-max_slots) to activate tool mode.
 * 
 * SIMPLIFIED WORKFLOW:
 * 1. Drag shovel from inventory to hotbar slot 1
 * 2. Press key "1"
 * 3. Landscaping mode active - ready to use
 * 
 * TOOLBELT TIERS (unlock more slots):
 * - Base toolbelt: 2 slots (default)
 * - Leather toolbelt: 4 slots (crafted)
 * - Reinforced toolbelt: 6 slots (crafted)
 * - Expert toolbelt: 8 slots (crafted)
 * - Master toolbelt: 9 slots (crafted)
 * 
 * ARCHITECTURE:
 * - Extends obj/items with binding procs
 * - Drag-drop sets slot (calls SetSlot which auto-equips)
 * - Hotkey press activates tool (calls ActivateTool)
 * - No additional steps needed
 */

// ==================== ITEM BINDING SYSTEM ====================

/obj/items
	var
		hotbar_slot = 0                    // Which hotbar slot this item is bound to (0 = none)
		is_hotbar_bound = 0                // Boolean: is this item in hotbar?

	proc/BindToHotbar(slot_num)
		/**
		 * BindToHotbar(slot_num) -> int
		 * 
		 * Binds this item to specified hotbar slot (drag-drop).
		 * SetSlot() in datum/toolbelt auto-equips the item.
		 * 
		 * Returns: 1 if bound, 0 if failed
		 */
		
		// Find owner (player)
		var/mob/players/owner = null
		for(var/mob/players/M in world)
			if(src in M.contents)
				owner = M
				break
		
		if(!owner || !owner.toolbelt)
			return 0
		
		// Check if slot is valid
		if(slot_num < 1 || slot_num > owner.toolbelt.max_slots)
			if(owner)
				owner << "<font color=red>Slot [slot_num] not available. Unlock more slots with upgraded toolbelts.</font>"
			return 0
		
		// Bind to slot (SetSlot auto-equips via datum/toolbelt)
		hotbar_slot = slot_num
		is_hotbar_bound = 1
		
		if(owner.toolbelt.SetSlot(slot_num, src))
			owner << "<font color=green>Bound [src.name] to slot [slot_num]</font>"
			return 1
		
		return 0

	proc/UnbindFromHotbar()
		/**
		 * UnbindFromHotbar() -> int
		 * 
		 * Removes this item from hotbar.
		 * 
		 * Returns: 1 if unbound, 0 if not in hotbar
		 */
		
		if(!is_hotbar_bound || hotbar_slot == 0)
			return 0
		
		// Find owner
		var/mob/players/owner = null
		for(var/mob/players/M in world)
			if(src in M.contents)
				owner = M
				break
		
		if(!owner || !owner.toolbelt)
			return 0
		
		// Unbind from slot
		var/slot = hotbar_slot
		hotbar_slot = 0
		is_hotbar_bound = 0
		
		return owner.toolbelt.ClearSlot(slot)

// ==================== HOTBAR STATUS & MANAGEMENT ====================

/datum/toolbelt
	proc/GetHotbarStatus()
		/**
		 * GetHotbarStatus() -> text
		 * 
		 * Returns formatted string showing all hotbar slots (1 to max_slots).
		 */
		
		var/status = "<font color=cyan>═══════ HOTBAR STATUS ([max_slots] slots) ═══════\n"
		
		for(var/i = 1; i <= max_slots; i++)
			var/obj/item = slots[i]
			var/item_name = item ? item.name : "(empty)"
			var/active = (current_slot == i) ? " <-- ACTIVE" : ""
			status += "[i]: [item_name][active]\n"
		
		status += "═══════════════════════════════</font>"
		return status

	proc/ShowHotbarStatus()
		/**
		 * ShowHotbarStatus() -> null
		 * 
		 * Displays hotbar status to owner
		 */
		
		owner << GetHotbarStatus()

	proc/ClearAllSlots()
		/**
		 * ClearAllSlots() -> int
		 * 
		 * Unbinds all items from hotbar (destructive).
		 * 
		 * Returns: number of slots cleared
		 */
		
		var/cleared = 0
		for(var/i = 1; i <= max_slots; i++)
			if(slots[i] != null)
				ClearSlot(i)
				cleared++
		
		return cleared

// ==================== TESTING HELPERS ====================

mob/players/verb
	Show_Hotbar()
		set name = "Show Hotbar"
		set category = "Tools"
		
		if(!src.toolbelt)
			src << "Toolbelt not initialized"
			return
		
		src.toolbelt.ShowHotbarStatus()
