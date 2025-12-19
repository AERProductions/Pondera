/*
 * TOOLBELT HOTBAR SYSTEM
 * 
 * Implements a 9-slot hotbar (1-9 hotkeys) for equipping and activating tools.
 * Tools immediately dictate available actions (e.g., shovel = landscaping mode).
 * Persistent gameplay UI overlays allow selection while moving freely.
 * 
 * ARCHITECTURE:
 * - datum/toolbelt: Player's hotbar state (9 slots, current active tool)
 * - Tool activation triggers gameplay mode (shovel -> landscaping, hammer -> smithing, etc.)
 * - Persistent selection UI during gameplay (grid, wheel, horizontal bar)
 * - Arrow keys + mouse support for selection
 * - E-key triggers immediate action (no menus, just gameplay)
 * 
 * INTEGRATION:
 * - datum/toolbelt created in mob/players/New() via character datum
 * - Hotkeys 1-9 handled in HandleKeyboardInput macro keys
 * - Tool equip/unequip syncs with hotbar
 * - Mode activation deferred until E-key press (selection UI persists)
 */

// ==================== TOOLBELT DATUM ====================

/datum/toolbelt
	var
		mob/players/owner = null           // Player who owns this hotbar
		list/slots = list()                 // Variable slots (1-9), containing objects or null
		list/secondary_slots = list()      // Secondary slots (1a-9a) for dual-wielding
		max_slots = 2                      // Unlocked slots: 2 (base), 4, 6, 8, 9 (max)
		current_slot = 0                   // Currently active slot (1-9, 0 = none)
		current_tool = null                // Currently equipped tool object
		current_secondary_tool = null      // Secondary hand tool (for dual-wielding)
		active_mode = ""                   // Current gameplay mode ("landscaping", "smithing", etc.)
		ui_visible = 0                     // Is selection UI currently visible?
		selected_index = 0                 // Currently highlighted index in selection UI

	New(mob/players/P)
		owner = P
		max_slots = 2  // Players start with 2 base slots
		slots = list(null, null)  // Start with 2 empty slots
		secondary_slots = list(null, null)  // Secondary slots for dual-wield
		// Expand to 9 if player has upgraded toolbelts in inventory
		CheckForUpgradedToolbelts()
		current_slot = 0
		current_tool = null
		current_secondary_tool = null
		active_mode = ""
		ui_visible = 0
		selected_index = 0
		active_mode = ""                   // Current gameplay mode ("landscaping", "smithing", etc.)
		ui_visible = 0                     // Is selection UI currently visible?
		selected_index = 0                 // Currently highlighted index in selection UI

	New(mob/players/P)
		owner = P
		max_slots = 2  // Players start with 2 base slots
		slots = list(null, null)  // Start with 2 empty slots
		// Expand to 9 if player has upgraded toolbelts in inventory
		CheckForUpgradedToolbelts()
		current_slot = 0
		current_tool = null
		active_mode = ""
		ui_visible = 0
		selected_index = 0

	// ==================== SLOT MANAGEMENT ====================

	proc/SetSlot(slot_num, obj/item)
		/**
		 * SetSlot(slot_num, item) -> int
		 * 
		 * Binds item to hotbar slot (1-max_slots)
		 * Respects max_slots based on equipped toolbelt tier.
		 * 
		 * Returns: 1 if success, 0 if failed
		 */
		
		if(slot_num < 1 || slot_num > max_slots)
			if(owner)
				owner << "<font color=red>Slot [slot_num] is not unlocked. You have [max_slots] slots available.</font>"
			return 0
		
		// Remove item from any existing slot
		for(var/i = 1; i <= max_slots; i++)
			if(slots[i] == item)
				slots[i] = null
		
		// Add to new slot
		slots[slot_num] = item
		
		// Notify HUD system of slot change
		NotifyToolbeltSlotChanged(owner, slot_num, item)
		
		return 1

	proc/GetSlot(slot_num)
		/**
		 * GetSlot(slot_num) -> obj
		 * 
		 * Returns item in hotbar slot (1-max_slots), or null
		 */
		
		if(slot_num < 1 || slot_num > max_slots)
			return null
		
		return slots[slot_num]

	proc/ClearSlot(slot_num)
		/**
		 * ClearSlot(slot_num) -> int
		 * 
		 * Removes item from slot
		 * 
		 * Returns: 1 if cleared, 0 if already empty
		 */
		
		if(slot_num < 1 || slot_num > max_slots)
			return 0
		
		if(slots[slot_num] == null)
			return 0
		
		slots[slot_num] = null
		
		// If this was the active slot, deactivate
		if(current_slot == slot_num)
			DeactivateTool()
		
		return 1

	proc/FindSlotForItem(obj/item)
		/**
		 * FindSlotForItem(item) -> int
		 * 
		 * Finds which slot contains this item
		 * 
		 * Returns: slot number (1-max_slots) or 0 if not in hotbar
		 */
		
		for(var/i = 1; i <= max_slots; i++)
			if(slots[i] == item)
				return i
		
		return 0

	// ==================== TOOL ACTIVATION ====================

	proc/ActivateTool(slot_num)
		/**
		 * ActivateTool(slot_num) -> int
		 * 
		 * Activates tool in slot, enabling its gameplay mode.
		 * 
		 * SIMPLIFIED WORKFLOW:
		 * 1. Player drag-drops item to hotbar slot (SetSlot auto-equips)
		 * 2. Player presses hotkey (1-max_slots)
		 * 3. ActivateTool() is called
		 * 4. Tool mode activates immediately
		 * 5. Selection UI shows and player can act
		 * 
		 * Returns: 1 if activated, 0 if failed
		 */
		
		if(slot_num < 1 || slot_num > max_slots)
			owner << "<font color=red>Slot [slot_num] does not exist. You have [max_slots] slots.</font>"
			return 0
		
		var/obj/item = slots[slot_num]
		if(item == null)
			owner << "<font color=orange>Slot [slot_num] is empty</font>"
			return 0
		
		// Deactivate previous tool
		if(current_tool != null && current_slot != slot_num)
			DeactivateTool()
		
		// Set as current
		current_slot = slot_num
		current_tool = item
		
		// Determine gameplay mode from tool type
		var/mode = GetToolMode(item)
		if(mode == "")
			owner << "<font color=red>Unknown tool type: [item.name]</font>"
			return 0
		
		// Activate mode (equipment flags, stamina drain, etc.)
		if(!ActivateMode(mode))
			current_tool = null
			current_slot = 0
			owner << "<font color=red>Failed to activate [mode] mode</font>"
			return 0
		
		active_mode = mode
		owner << "<font color=green>Equipped [item.name] ([mode] mode active)</font>"
		
		// Show persistent selection UI
		ShowSelectionUI(mode)
		ui_visible = 1
		
		// Notify HUD system of tool activation
		NotifyToolbeltToolActivated(owner, slot_num, item, mode)
		
		return 1

	proc/DeactivateTool()
		/**
		 * DeactivateTool() -> int
		 * 
		 * Deactivates current tool and hides selection UI
		 * 
		 * Returns: 1 if deactivated, 0 if no tool was active
		 */
		
		if(current_tool == null)
			return 0
		
		// Hide selection UI
		HideSelectionUI()
		ui_visible = 0
		
		// Deactivate mode (reset equipment flags, etc.)
		if(active_mode != "")
			DeactivateMode(active_mode)
		
		current_tool = null
		current_slot = 0
		active_mode = ""
		selected_index = 0
		
		owner << "<font color=orange>Tool deactivated</font>"
		
		// Notify HUD system of tool deactivation
		NotifyToolbeltToolDeactivated(owner)
		
		return 1

	// ==================== MODE MANAGEMENT ====================

	proc/GetToolMode(obj/item)
		/**
		 * GetToolMode(item) -> text
		 * 
		 * Determines gameplay mode from tool type using GatheringToolActivation system
		 * Maps tools to their primary gameplay functions
		 * 
		 * Returns: mode name ("mining", "landscaping", etc.) or ""
		 */
		
		if(item == null)
			return ""
		
		// Use gathering tool system to detect tool type
		var/tool_type = GetGatheringToolType(item)
		if(tool_type != "")
			return GetGatheringToolMode(tool_type)
		
		// Legacy tool name checking as fallback
		var/tool_name = lowertext(item.name)
		
		if(findtext(tool_name, "shovel"))
			return "landscaping"
		
		if(findtext(tool_name, "hammer"))
			return "smithing"
		
		if(findtext(tool_name, "fishing"))
			return "fishing"
		
		return ""

	proc/ActivateMode(mode)
		/**
		 * ActivateMode(mode) -> int
		 * 
		 * Activates gameplay mode using gathering tool system
		 * Sets equipment flags, prepares environment for interactions
		 * 
		 * Returns: 1 if mode activated, 0 if invalid
		 */
		
		var/mob/players/M = owner
		if(!M)
			return 0
		
		// Unequip all previous tools first
		UnequipAllGatheringTools(M)
		
		switch(mode)
			if("mining")
				SetGatheringToolEquipped(M, TOOL_TYPE_PICKAXE, 1)
				return 1
			
			if("landscaping")
				SetGatheringToolEquipped(M, TOOL_TYPE_SHOVEL, 1)
				return 1
			
			if("woodcutting")
				SetGatheringToolEquipped(M, TOOL_TYPE_AXE, 1)
				return 1
			
			if("fishing")
				SetGatheringToolEquipped(M, TOOL_TYPE_FISHING_POLE, 1)
				return 1
			
			if("harvesting")
				SetGatheringToolEquipped(M, TOOL_TYPE_SICKLE, 1)
				return 1
			
			if("farming")
				SetGatheringToolEquipped(M, TOOL_TYPE_HOE, 1)
				return 1
			
			if("carving")
				SetGatheringToolEquipped(M, TOOL_TYPE_CARVING_KNIFE, 1)
				return 1
			
			if("smithing")
				SetGatheringToolEquipped(M, TOOL_TYPE_HAMMER, 1)
				return 1
			
			if("stonecarving")
				SetGatheringToolEquipped(M, TOOL_TYPE_CHISEL, 1)
				return 1
			
			if("firestarting")
				SetGatheringToolEquipped(M, TOOL_TYPE_FLINT, 1)
				return 1
		
		return 0

	proc/DeactivateMode(mode)
		/**
		 * DeactivateMode(mode) -> int
		 * 
		 * Deactivates gameplay mode using gathering tool system
		 * Clears equipment flags, resets mode state.
		 * 
		 * Returns: 1 if success, 0 if invalid
		 */
		
		var/mob/players/M = owner
		if(!M)
			return 0
		
		switch(mode)
			if("mining")
				SetGatheringToolEquipped(M, TOOL_TYPE_PICKAXE, 0)
				return 1
			
			if("landscaping")
				SetGatheringToolEquipped(M, TOOL_TYPE_SHOVEL, 0)
				return 1
			
			if("woodcutting")
				SetGatheringToolEquipped(M, TOOL_TYPE_AXE, 0)
				return 1
			
			if("fishing")
				SetGatheringToolEquipped(M, TOOL_TYPE_FISHING_POLE, 0)
				return 1
			
			if("harvesting")
				SetGatheringToolEquipped(M, TOOL_TYPE_SICKLE, 0)
				return 1
			
			if("farming")
				SetGatheringToolEquipped(M, TOOL_TYPE_HOE, 0)
				return 1
			
			if("carving")
				SetGatheringToolEquipped(M, TOOL_TYPE_CARVING_KNIFE, 0)
				return 1
			
			if("smithing")
				SetGatheringToolEquipped(M, TOOL_TYPE_HAMMER, 0)
				return 1
			
			if("stonecarving")
				SetGatheringToolEquipped(M, TOOL_TYPE_CHISEL, 0)
				return 1
			
			if("firestarting")
				SetGatheringToolEquipped(M, TOOL_TYPE_FLINT, 0)
				return 1
			
			else
				return 0

	// ==================== SELECTION UI ====================

	proc/ShowSelectionUI(mode)
		/**
		 * ShowSelectionUI(mode) -> null
		 * 
		 * Displays persistent selection UI for mode.
		 * UI shows available actions/objects for current tool.
		 * Allows arrow key / mouse navigation while player moves freely.
		 * 
		 * Delegates to ToolbeltVisualUI.dm for rendering
		 */
		
		// Use visual UI if available, otherwise fallback to text
		//if(fexists("dm/ToolbeltVisualUI.dm"))
		//	ShowSelectionUI_Visual(mode)
		//else
		ShowSelectionUI_Text(mode)

	proc/ShowSelectionUI_Text(mode)
		/**
		 * ShowSelectionUI_Text(mode) -> null
		 * 
		 * Text-based fallback UI (no visual rendering)
		 */
		
		var/list/options = GetModeOptions(mode)
		
		if(options.len == 0)
			owner << "<font color=red>No options available for [mode]</font>"
			return
		
		owner << "<font color=cyan>--- [mode] MODE ACTIVE ---</font>"
		owner << "<font color=cyan>Use arrow keys/mouse to select, E to confirm</font>"
		
		// TODO: Create visual UI overlay (grid, wheel, or bar)
		// For now: text-based placeholder
		for(var/i = 1; i <= options.len; i++)
			var/option_text = options[i]
			var/marker = (i == selected_index) ? "►" : " "
			owner << "<font color=yellow>[marker] \[[i]\] [option_text]</font>"

	proc/HideSelectionUI()
		/**
		 * HideSelectionUI() -> null
		 * 
		 * Hides persistent selection UI
		 * 
		 * Delegates to visual UI system if available
		 */
		
		//if(fexists("dm/ToolbeltVisualUI.dm"))
		//	HideSelectionUI_Visual()
		//else
		owner << "<font color=gray>Selection UI hidden</font>"

	proc/UpdateSelectionUI()
		/**
		 * UpdateSelectionUI() -> null
		 * 
		 * Refreshes selection UI display (called when selected_index changes)
		 * 
		 * Delegates to visual UI system if available
		 */
		
		if(!ui_visible)
			return
		
		if(active_mode == "")
			return
		
		// Use visual UI if available
		//if(fexists("dm/ToolbeltVisualUI.dm"))
		//	UpdateSelectionUI_Visual()
		//else
		ShowSelectionUI(active_mode)  // Re-display text version

	proc/NavigateSelection(direction)
		/**
		 * NavigateSelection(direction) -> int
		 * 
		 * Moves selection highlight in direction.
		 * direction: 1 = up/left, -1 = down/right
		 * 
		 * Returns: 1 if moved, 0 if at boundary
		 */
		
		if(!ui_visible || active_mode == "")
			return 0
		
		var/list/options = GetModeOptions(active_mode)
		if(options.len == 0)
			return 0
		
		var/new_index = selected_index + direction
		
		// Wrap around
		if(new_index < 1)
			new_index = options.len
		else if(new_index > options.len)
			new_index = 1
		
		selected_index = new_index
		UpdateSelectionUI()
		return 1

	proc/ConfirmSelection()
		/**
		 * ConfirmSelection() -> int
		 * 
		 * Executes action for currently selected option (E-key pressed).
		 * Immediately triggers gameplay (no menus, no prompts).
		 * 
		 * Returns: 1 if action executed, 0 if failed
		 */
		
		if(!ui_visible || active_mode == "")
			owner << "<font color=red>No selection active</font>"
			return 0
		
		var/list/options = GetModeOptions(active_mode)
		if(selected_index < 1 || selected_index > options.len)
			return 0
		
		var/selected = options[selected_index]
		
		// Execute mode-specific action
		var/result = ExecuteModeAction(active_mode, selected)
		
		return result

	// ==================== MODE OPTIONS & ACTIONS ====================

	proc/GetModeOptions(mode)
		/**
		 * GetModeOptions(mode) -> list
		 * 
		 * Returns available actions/objects for mode.
		 * Data-driven from registries (TerrainObjectsRegistry, SmithingRecipes, etc.).
		 * 
		 * Returns: list of option names
		 */
		
		var/list/options = list()
		
		switch(mode)
			if("landscaping")
				// Get available terrain objects from registry
				options = GetTerrainMenuOptions(owner)
			
			if("building")
				// Get available building objects - context-dependent
				if(IsNearAnvil(owner))
					// Near anvil: show anvil menu instead
					DisplayAnvilMenu(owner)
				else
					// Not near anvil: show building menu
					DisplayBuildingMenu(owner)
			
			if("smithing")
				// Get available recipes from smithing system
				options = GetSmithingMenuOptions(owner)
			
			if("fishing")
				// Get available fishing spots/techniques
				options = GetFishingMenuOptions(owner)
			
			if("carving")
				// Get available carving tasks
				options = GetCarvingMenuOptions(owner)
			
			if("woodcutting")
				// Get available woodcutting targets
				options = GetWoodcuttingMenuOptions(owner)
		
		return options

	proc/ExecuteModeAction(mode, selected_action)
		/**
		 * ExecuteModeAction(mode, action) -> int
		 * 
		 * Executes action immediately (E-key triggered).
		 * No menus, no confirmation. Direct gameplay.
		 * 
		 * Returns: 1 if action executed, 0 if failed
		 */
		
		var/mob/players/M = owner
		
		switch(mode)
			if("landscaping")
				// Create terrain object
				return CreateTerrainObject(M, selected_action)
			
			if("building")
				// Building creation or anvil crafting (context-dependent)
				if(IsNearAnvil(M))
					// At anvil: show anvil crafting menu
					DisplayAnvilMenu(M)
				else
					// Not at anvil: show building creation menu
					DisplayBuildingMenu(M)
				return 1
			
			if("smithing")
				// Start smithing minigame
				// TODO: Implement smithing minigame entry
				M << "Smithing: [selected_action] (minigame not yet implemented)"
				return 1
			
		if("fishing")
			// Start fishing minigame
			DisplayFishingMenu(M)
			return 1
		
		if("carving")
			// Check for dual-wield: Hammer + Chisel = Stone Carving
			if(M.HMequipped && M.CHequipped)
				// Stone carving: display stone carving menu
				DisplayStoneCarvingMenu(M)
				return 1
			else
				// Single-tool carving: carving knife for kindling
				if(selected_action == "Carve Kindling")
					M.AttemptCarvingAction("kindling")
					return 1
				return 0
		
		if("torches")
			// Light torch/lamp
			DisplayTorchLampMenu(M)
			return 1
		
		if("consumables")
			// Eat/drink consumable
			DisplayConsumableMenu(M)
			return 1
		
		if("woodcutting")
			// Start woodcutting minigame
			// TODO: Implement woodcutting minigame entry
			M << "Woodcutting: [selected_action] (minigame not yet implemented)"
			return 1
		
		else
			return 0

// ==================== PLACEHOLDER MENU PROCS ====================
// NOTE: GetTerrainMenuOptions() is defined in TerrainObjectsRegistry.dm
// These placeholders are for other gameplay modes

/proc/GetSmithingMenuOptions(mob/players/M)
	/**
	 * GetSmithingMenuOptions(M) -> list
	 * 
	 * Returns available smithing recipes.
	 * Will be replaced by actual SmithingRecipes call.
	 */
	
	// TODO: Call SmithingRecipes registry
	return list("Iron Axe", "Iron Sword", "Iron Hammer")

/proc/GetFishingMenuOptions(mob/players/M)
	/**
	 * GetFishingMenuOptions(M) -> list
	 * 
	 * Returns available fish species based on rank.
	 * Calls DisplayFishingMenu directly.
	 */
	
	// Show fishing menu
	DisplayFishingMenu(M)
	return list()

proc/GetCarvingMenuOptions(mob/players/M)
	/**
	 * GetCarvingMenuOptions(M) -> list
	 * 
	 * Returns available carving tasks.
	 * - Single tool (carving knife): Carve Kindling (wood carving)
	 * - Dual-wield (hammer + chisel): Stone carving menu
	 */
	
	// Check for stone carving dual-wield
	if(M.HMequipped && M.CHequipped)
		// Show stone carving menu
		DisplayStoneCarvingMenu(M)
		return list()
	
	// Single-tool carving (wood carving)
	return list("Carve Kindling")

proc/GetWoodcuttingMenuOptions(mob/players/M)
	/**
	 * GetWoodcuttingMenuOptions(M) -> list
	 * 
	 * Returns available woodcutting targets.
	 */
	
	return list("Chop Tree", "Gather Branches")

/proc/GetTorchLampMenuOptions(mob/players/M)
	/**
	 * GetTorchLampMenuOptions(M) -> list
	 * 
	 * Returns available torches and lamps.
	 * Calls DisplayTorchLampMenu directly.
	 */
	
	DisplayTorchLampMenu(M)
	return list()

/proc/IsNearAnvil(mob/players/M)
	/**
	 * IsNearAnvil(M) -> int
	 * 
	 * Checks if player is within anvil interaction range.
	 * Used for context-dependent hammer UI.
	 * 
	 * Returns: 1 if near anvil, 0 otherwise
	 */
	
	if(!M) return 0
	
	// Check for anvil objects within interaction range (2 tiles)
	// Generic check for anvil proximity (by name or type)
	for(var/obj/anvil in view(2, M))
		if(anvil && findtext(anvil.name, "anvil", 1, 0))
			return 1
	
	return 0

// ==================== HOTKEY HANDLERS ====================

proc/HandleToolbeltHotkey(mob/players/M, slot_num)
	/**
	 * HandleToolbeltHotkey(M, slot_num) -> int
	 * 
	 * Called when player presses 1-9 hotkey.
	 * Activates tool in corresponding slot.
	 * 
	 * Called from macro system (1-9 keys)
	 */
	
	if(!M || !M.toolbelt)
		return 0
	
	return M.toolbelt.ActivateTool(slot_num)

// ==================== INITIALIZATION ====================

proc/InitializeToolbelt(mob/players/M)
	/**
	 * InitializeToolbelt(M) -> null
	 * 
	 * Creates and initializes toolbelt for player.
	 * Called from mob/players/New() or character creation.
	 */
	
	if(M.toolbelt != null)
		return  // Already initialized
	
	M.toolbelt = new/datum/toolbelt(M)
	M << "Toolbelt initialized (hotkeys 1-9)"
	
	// Initialize display on next tick
	spawn(1)
		if(M && M.client)
			pass  // TODO: Define InitializeToolbeltDisplay() proc

// ==================== ENHANCED DISPLAY & LIFECYCLE ====================

/datum/toolbelt
	proc/GetSlotState(slot_num)
		/**
		 * GetSlotState(slot_num) -> text
		 * 
		 * Returns state of a specific slot for display.
		 * Returns one of: "active", "equipped", "empty", "locked"
		 */
		
		if(slot_num < 1 || slot_num > 9)
			return "invalid"
		
		if(slot_num > max_slots)
			return "locked"
		
		var/obj/item = slots[slot_num]
		
		if(!item)
			return "empty"
		
		if(current_slot == slot_num)
			return "active"
		
		if(item.suffix == "Equipped")
			return "equipped"
		
		return "empty"

	proc/GetToolsByMode(mode)
		/**
		 * GetToolsByMode(mode) -> list
		 * 
		 * Get all tools in hotbar that use this mode
		 */
		
		var/list/tools = list()
		
		for(var/i = 1; i <= max_slots; i++)
			var/obj/tool = slots[i]
			if(tool && GetToolMode(tool) == mode)
				tools += list(list("slot" = i, "tool" = tool))
		
		return tools

	proc/HasActiveTool()
		/**
		 * HasActiveTool() -> int
		 * 
		 * Check if there's an active tool in current slot
		 * Returns: 1 if active, 0 if not
		 */
		
		if(current_slot < 1 || current_slot > max_slots)
			return 0
		
		var/obj/item = slots[current_slot]
		return (item != null) ? 1 : 0

	proc/SwitchToNextFilled()
		/**
		 * SwitchToNextFilled() -> int
		 * 
		 * Switch to next slot that has an item.
		 * Useful for rapid tool switching.
		 * 
		 * Returns: 1 if switched, 0 if no other items
		 */
		
		for(var/i = 1; i <= max_slots; i++)
			if(i != current_slot && slots[i])
				return ActivateTool(i)
		
		return 0

	proc/GetEmptySlots()
		/**
		 * GetEmptySlots() -> list
		 * 
		 * Returns list of empty slot numbers
		 */
		
		var/list/empty = list()
		
		for(var/i = 1; i <= max_slots; i++)
			if(slots[i] == null)
				empty += i
		
		return empty

	proc/GetFilledSlots()
		/**
		 * GetFilledSlots() -> list
		 * 
		 * Returns list of filled slot numbers
		 */
		
		var/list/filled = list()
		
		for(var/i = 1; i <= max_slots; i++)
			if(slots[i] != null)
				filled += i
		
		return filled

	proc/HasSlotSpace()
		/**
		 * HasSlotSpace() -> int
		 * 
		 * Check if there are empty slots available
		 * Returns: 1 if space, 0 if full
		 */
		
		for(var/i = 1; i <= max_slots; i++)
			if(slots[i] == null)
				return 1
		
		return 0

	proc/PrintDetailedStatus()
		/**
		 * PrintDetailedStatus() -> null
		 * 
		 * Print comprehensive status with all details
		 */
		
		if(!owner)
			return
		
		owner << ""
		owner << "<font color=cyan>╔════════════════════════════════════════════╗</font>"
		owner << "<font color=cyan>║            TOOLBELT DETAILED STATUS        ║</font>"
		owner << "<font color=cyan>╠════════════════════════════════════════════╣</font>"
		owner << "<font color=cyan>║ Tier: [GetTierName()] ([max_slots] slots)</font>"
		owner << "<font color=cyan>║ Active Mode: [active_mode != "" ? active_mode : "None"]</font>"
		var/tool_display = "None"
		if(current_tool && current_tool:name)
			tool_display = current_tool:name
		owner << "<font color=cyan>║ Active Tool: [tool_display]</font>"
		owner << "<font color=cyan>╠════════════════════════════════════════════╣</font>"
		
		var/filled = GetFilledSlots()
		var/empty = GetEmptySlots()
		
		owner << "<font color=cyan>║ SLOTS ([length(filled)]/[max_slots] Filled):</font>"
		
		for(var/i = 1; i <= max_slots; i++)
			var/obj/item = slots[i]
			var/state = GetSlotState(i)
			var/color = "white"
			var/marker = " "
			
			switch(state)
				if("active")
					color = "yellow"
					marker = "→"
				if("equipped")
					color = "lime"
					marker = "•"
				if("empty")
					color = "gray"
					marker = "○"
			
			if(item)
				owner << "<font color=cyan>║ [marker] Slot [i]: <font color=[color]>[item.name]</font></font>"
			else
				owner << "<font color=cyan>║ [marker] Slot [i]: <font color=[color]>(empty)</font></font>"
		
		if(max_slots < 9)
			owner << "<font color=cyan>║ • Slots [max_slots + 1]-9: LOCKED (craft toolbelt to unlock)</font>"
		
		owner << "<font color=cyan>╚════════════════════════════════════════════╝</font>"
		owner << ""

	proc/GetTierName()
		/**
		 * GetTierName() -> text
		 * Returns name of current toolbelt tier
		 */
		
		switch(max_slots)
			if(2)
				return "Base"
			if(4)
				return "Leather"
			if(6)
				return "Reinforced"
			if(8)
				return "Expert"
			if(9)
				return "Master"
		
		return "Unknown"

	proc/OnDeactivateTool()
		/**
		 * OnDeactivateTool() -> null
		 * Called when tool is deactivated
		 * Hook for additional cleanup
		 */
		
		HideSelectionUI()
		DeactivateMode(active_mode)
		active_mode = ""
		current_tool = null
		current_slot = 0
		ui_visible = 0
		selected_index = 0

	proc/OnActivateTool(slot_num)
		/**
		 * OnActivateTool(slot_num) -> null
		 * Called when tool is activated
		 * Hook for additional setup
		 */
		
		// Can be extended for additional behavior
		// e.g., animations, particles, sounds

	proc/RefreshDisplay()
		/**
		 * RefreshDisplay() -> null
		 * Refresh all display elements
		 */
		
		if(owner)
			owner.UpdateToolbeltDisplay()

/mob/players
	proc/UpdateToolbeltDisplay()
		/**
		 * UpdateToolbeltDisplay() -> null
		 * 
		 * Update the hotbar display with current slot contents
		 * Called after adding/removing items from hotbar
		 * 
		 * Currently minimal implementation for text-based UI
		 * Can be extended for visual UI updates later
		 */
		
		if(!toolbelt) return
		
		// Refresh HUD display
		if(client && client.screen)
			// Text-based notification
			src << "<yellow>Hotbar updated</yellow>"

// ==================== TERRAIN SYSTEM STUBS ====================
// These will be replaced with full implementations

/proc/GetTerrainMenuOptions(mob/players/M)
	/**
	 * GetTerrainMenuOptions(M) -> list
	 * 
	 * Returns available terrain objects player can create based on rank/permissions
	 * STUB - will integrate with TerrainObjectsRegistry.dm
	 */
	return list(
		"Dirt Road",
		"Stone Road",
		"Brick Road"
	)

/proc/CreateTerrainObject(mob/players/M, terrain_type)
	/**
	 * CreateTerrainObject(M, terrain_type) -> obj
	 * 
	 * Creates a terrain object at player location
	 * STUB - will integrate with full terrain creation system
	 */
	if(!M) return null
	
	var/obj/new_terrain
	switch(terrain_type)
		if("Dirt Road")
			new_terrain = new /obj/Dirt_Road(M.loc)
		if("Stone Road")
			new_terrain = new /obj/Stone_Road(M.loc)
		if("Brick Road")
			new_terrain = new /obj/Brick_Road(M.loc)
		else
			M << "Unknown terrain type: [terrain_type]"
			return null
	
	return new_terrain


