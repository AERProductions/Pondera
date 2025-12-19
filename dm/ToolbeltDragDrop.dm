/**
 * TOOLBELT DRAG & DROP BINDING SYSTEM
 * 
 * Allows players to drag tools from inventory and drop them onto hotbar slots
 * Provides visual feedback and slot validation
 * 
 * Features:
 * - Drag tool from inventory window and drop on hotbar slot
 * - Visual slot highlighting when dragging over hotbar
 * - Slot validation (checks if tool type already equipped, slot availability)
 * - Supports all tool types
 * - Works alongside right-click and auto-pickup systems
 */

// ==================== TOOL ITEM DRAG DROP SUPPORT ====================

/obj/items
	var
		is_dragging_to_hotbar = 0  // Flag indicating drag-to-hotbar in progress

	proc/CanBeAddedToHotbar()
		/**
		 * CanBeAddedToHotbar() -> int
		 * 
		 * Check if this item can be added to a hotbar
		 * Must be a tool type (pickaxe, shovel, hammer, etc.)
		 * 
		 * Returns: 1 if can be added, 0 if not a tool
		 */
		
		var/tool_type = GetToolType(src)
		return (tool_type != null) ? 1 : 0

	proc/HandleDroppedOnSlot(mob/players/M, slot_num)
		/**
		 * HandleDroppedOnSlot(M, slot_num) -> int
		 * 
		 * Called when this tool item is dropped onto a hotbar slot
		 * Handles validation and binding
		 * 
		 * Parameters:
		 * - M: Player performing the drop
		 * - slot_num: Target slot number (1-9)
		 * 
		 * Returns: 1 if successful, 0 if failed
		 */
		
		if(!M || !M.toolbelt)
			return 0
		
		var/tool_type = GetToolType(src)
		if(!tool_type)
			return 0
		
		// Validate slot number
		if(slot_num < 1 || slot_num > M.toolbelt.max_slots)
			M << "<font color=red>Slot [slot_num] is not unlocked!</font>"
			return 0
		
		// Check if tool type already in hotbar
		if(DoesPlayerHaveToolType(M, tool_type))
			M << "<font color=orange>You already have a [tool_type] in your hotbar.</font>"
			return 0
		
		// Bind tool to slot via SetSlot (removes from any other slot)
		if(M.toolbelt.SetSlot(slot_num, src))
			M << "<font color=green>Bound [src.name] to hotbar slot [slot_num]</font>"
			M.UpdateToolbeltDisplay()
			return 1
		else
			M << "<font color=red>Failed to bind tool to slot [slot_num]</font>"
			return 0

// ==================== HOTBAR SLOT SCREEN OBJECT ====================

/obj/screen/hotbar_slot
	/**
	 * Screen object representing a single hotbar slot
	 * Used for drag-drop detection and visual feedback
	 * Can be highlighted when dragging a tool over it
	 */
	
	var
		slot_id = 0              // Slot number (1-9)
		owner_toolbelt = null    // Reference to parent toolbelt datum
		is_highlighted = 0       // Is this slot highlighted (drag over)?
		base_color = "#FFFFFF"   // Base color when not highlighted
		highlight_color = "#FFFF00"  // Highlight color when dragging over

	New(slot_number, datum/toolbelt/tb)
		slot_id = slot_number
		owner_toolbelt = tb
		is_highlighted = 0
		base_color = "#FFFFFF"
		highlight_color = "#FFFF00"
		..()

	proc/Highlight(state)
		/**
		 * Highlight(state) -> null
		 * 
		 * Highlight/unhighlight this slot
		 * state = 1 to highlight, 0 to unhighlight
		 */
		
		is_highlighted = state
		color = state ? highlight_color : base_color

