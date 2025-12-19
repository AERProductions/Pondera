/**
 * Tool Context Menu System
 * 
 * Provides right-click context menu for all tool items
 * Allows players to quickly add tools to their hotbelt
 * 
 * Features:
 * - Right-click menu on any tool item
 * - "Add to Hotbar" option
 * - Auto-fills first available slot
 * - Checks if tool type already equipped (prevents duplicates)
 * - Supports all material tiers (stone, ueik, iron, copper, zinc, steel, damascus, etc.)
 */

// ==================== TOOL TYPE DETECTION ====================

/proc/GetToolType(obj/item)
	/**
	 * GetToolType(item) -> text
	 * 
	 * Determines the tool type (pickaxe, shovel, hoe, etc.)
	 * based on item name or type path
	 * 
	 * Returns standardized tool type name, or null if not a tool
	 */
	
	if(!item) return null
	
	var/item_name = lowertext(item.name)
	var/type_path = "[item.type]"
	
	// Check by name first (material-agnostic)
	if(findtext(item_name, "pickaxe"))  return "pickaxe"
	if(findtext(item_name, "shovel"))   return "shovel"
	if(findtext(item_name, "hoe"))      return "hoe"
	if(findtext(item_name, "axe"))      return "axe"
	if(findtext(item_name, "sickle"))   return "sickle"
	if(findtext(item_name, "knife"))    return "knife"
	if(findtext(item_name, "hammer"))   return "hammer"
	if(findtext(item_name, "fishing")) return "fishing_pole"
	if(findtext(item_name, "file"))     return "file"
	if(findtext(item_name, "saw"))      return "saw"
	if(findtext(item_name, "chisel"))   return "chisel"
	if(findtext(item_name, "trowel"))   return "trowel"
	if(findtext(item_name, "carving"))  return "carving_knife"
	if(findtext(item_name, "rod"))      return "fishing_pole"
	
	// Fallback: check type path
	if(findtext(type_path, "pickaxe"))  return "pickaxe"
	if(findtext(type_path, "shovel"))   return "shovel"
	if(findtext(type_path, "hoe"))      return "hoe"
	if(findtext(type_path, "axe"))      return "axe"
	if(findtext(type_path, "sickle"))   return "sickle"
	if(findtext(type_path, "knife"))    return "knife"
	if(findtext(type_path, "hammer"))   return "hammer"
	if(findtext(type_path, "fishing"))  return "fishing_pole"
	
	return null

/proc/DoesPlayerHaveToolType(mob/players/M, tool_type)
	/**
	 * DoesPlayerHaveToolType(M, tool_type) -> int
	 * 
	 * Check if player already has a tool of this type in hotbelt
	 * tool_type = "pickaxe", "shovel", "axe", etc.
	 * 
	 * Returns: 1 if player has tool type, 0 if not
	 */
	
	if(!M || !M.toolbelt) return 0
	if(!tool_type) return 0
	
	// Check each slot for a tool of this type
	for(var/i = 1; i <= M.toolbelt.max_slots; i++)
		var/obj/slot_item = M.toolbelt.slots[i]
		if(slot_item)
			var/slot_tool_type = GetToolType(slot_item)
			if(slot_tool_type == tool_type)
				return 1  // Already has this tool type
	
	return 0

// ==================== CONTEXT MENU IMPLEMENTATION ====================

/obj/items
	proc/ShowToolContextMenu()
		/**
		 * ShowToolContextMenu() -> null
		 * 
		 * Display right-click context menu for tool items
		 * Called when player right-clicks the item
		 */
		
		var/mob/players/M = usr
		if(!M || !M.toolbelt) return
		
		var/tool_type = GetToolType(src)
		if(!tool_type) return  // Not a tool, don't show menu
		
		var/menu_options = list("Add to Hotbar")
		
		// Check if player already has this tool type
		if(DoesPlayerHaveToolType(M, tool_type))
			menu_options = list("Tool Already in Hotbar", "Cancel")
			var/choice = input(
				"You already have a [tool_type] in your hotbar.",
				"Context Menu"
			) as null|anything in menu_options
			return
		
		// Check if hotbar has space
		if(!M.toolbelt.HasSlotSpace())
			menu_options = list("Hotbar Full", "Cancel")
			var/choice = input(
				"Your hotbar is full. Drop an item first.",
				"Context Menu"
			) as null|anything in menu_options
			return
		
		// Show menu with option to add
		var/choice = input(
			"What would you like to do with this [tool_type]?",
			"Tool Context Menu"
		) as null|anything in menu_options
		
		if(choice == "Add to Hotbar")
			AddToolToHotbar(M)

/obj/items
	proc/AddToolToHotbar(mob/players/M)
		/**
		 * AddToolToHotbar(M) -> int
		 * 
		 * Add this tool to player's hotbelt
		 * Finds first empty slot and binds tool there
		 * 
		 * Returns: 1 if successful, 0 if failed
		 */
		
		if(!M || !M.toolbelt) return 0
		
		var/tool_type = GetToolType(src)
		if(!tool_type) return 0
		
		// Find first empty slot
		var/empty_slot = null
		for(var/i = 1; i <= M.toolbelt.max_slots; i++)
			if(!M.toolbelt.slots[i])
				empty_slot = i
				break
		
		if(!empty_slot)
			M << "<red>Hotbar is full!</red>"
			return 0
		
		// Bind tool to slot
		M.toolbelt.SetSlot(empty_slot, src)
		M << "<green>Added [src.name] to hotbar slot [empty_slot]</green>"
		M.UpdateToolbeltDisplay()
		
		return 1

// ==================== RIGHT-CLICK VERB OVERRIDE ====================

/obj/items
	verb/RightClick()
		set hidden = 1
		
		/**
		 * RightClick() - Triggered by right-click on item
		 * Shows context menu for tools
		 */
		
		var/tool_type = GetToolType(src)
		if(tool_type)
			ShowToolContextMenu()

