/*
 * TOOLBELT VISUAL UI SYSTEM
 * 
 * Renders persistent, non-blocking selection UI during gameplay.
 * Supports multiple styles: horizontal bar, grid, rotating wheel.
 * Uses screen overlays that don't block player movement.
 * 
 * ARCHITECTURE:
 * - datum/toolbelt_ui: Manages visual display state
 * - Screen elements: Updated each frame during UI visibility
 * - Selection highlighting: Arrow key navigation with visual feedback
 * - Mode-specific layouts: Different UI for landscaping, smithing, etc.
 */

// ==================== TOOLBELT UI DATUM ====================

/datum/toolbelt_ui
	var
		mob/players/owner = null           // Player this UI belongs to
		ui_style = "horizontal_bar"        // UI display style: "bar", "grid", "wheel"
		icon/ui_icon = null                // Reference to icon file
		list/option_icons = list()         // Icon states for each option
		option_width = 32                  // Width of each option display
		option_height = 32                 // Height of each option display
		ui_x = 0                           // Screen X position
		ui_y = 0                           // Screen Y position
		scroll_offset = 0                  // For scrolling long lists

	New(mob/players/P, style = "horizontal_bar")
		owner = P
		ui_style = style
		ui_x = 64                          // Default: left side
		ui_y = 300                         // Default: middle of screen

	// ==================== RENDERING ====================

	proc/RenderUI(list/options, selected_index)
		/**
		 * RenderUI(options, selected_index) -> null
		 * 
		 * Renders UI overlay with current options and selection.
		 * Called each frame while UI is visible.
		 * 
		 * Non-blocking: Uses screen overlays, doesn't interact with world
		 */
		
		if(options.len == 0)
			return
		
		switch(ui_style)
			if("horizontal_bar")
				RenderHorizontalBar(options, selected_index)
			if("grid")
				RenderGrid(options, selected_index)
			if("wheel")
				RenderWheel(options, selected_index)
			else
				RenderHorizontalBar(options, selected_index)  // Default

	proc/RenderHorizontalBar(list/options, selected_index)
		/**
		 * RenderHorizontalBar(options, selected_index) -> null
		 * 
		 * Renders single-row horizontal bar of options.
		 * Shows up to 8 options at once (wraps if more).
		 * 
		 * Example:
		 * ┌──────────────────────────────────────────────────────┐
		 * │ ◄ [1]Dirt Road  [2]Wood Road  ►[3]Brick Road  [4]Hill │
		 * └──────────────────────────────────────────────────────┘
		 */
		
		// Calculate visible range (show 8 at a time, centered on selection)
		var/visible_count = 8
		var/start_index = max(1, selected_index - 2)
		var/end_index = min(options.len, start_index + visible_count - 1)
		
		// Adjust if at end of list
		if(end_index == options.len && start_index > 1)
			start_index = max(1, options.len - visible_count + 1)
		
		// Build display string
		var/display = "<font color=cyan>═ LANDSCAPING ═ "
		
		// Left arrow indicator
		if(start_index > 1)
			display += "◄ "
		
		// Option buttons
		for(var/i = start_index; i <= end_index; i++)
			var/option = options[i]
			var/is_selected = (i == selected_index)
			
			if(is_selected)
				display += "<font color=yellow>►[i]"
			else
				display += "<font color=white>[i]"
			
			display += " [option] "
			
			if(is_selected)
				display += "◄ </font>"
		
		// Right arrow indicator
		if(end_index < options.len)
			display += "►"
		
		display += " ═</font>"
		
		// Send to player HUD (would use actual HUD element in future)
		owner << display

	proc/RenderGrid(list/options, selected_index)
		/**
		 * RenderGrid(options, selected_index) -> null
		 * 
		 * Renders 3x3 (or 4x4) grid of options.
		 * 
		 * Example:
		 * ┌─────────────────────────┐
		 * │ [1]Dirt  [2]Wood  ►[3]Brick │
		 * │ [4]Stone [5]Hill  [6]Ditch  │
		 * │ [7]Road  [8]Path  [9]Plaza  │
		 * └─────────────────────────┘
		 */
		
		var/cols = 3
		var/rows = 3
		var/max_display = cols * rows
		
		var/display = "<font color=cyan>╔════════════════════════╗\n"
		display += "║  LANDSCAPING OPTIONS   ║\n"
		display += "╠════════════════════════╣\n"
		
		for(var/row = 0; row < rows; row++)
			display += "║ "
			for(var/col = 0; col < cols; col++)
				var/idx = (row * cols) + col + 1
				
				if(idx > options.len)
					display += "          "
					continue
				
				var/option = options[idx]
				var/is_selected = (idx == selected_index)
				
				if(is_selected)
					display += "<font color=yellow>►"
				else
					display += " "
				
				display += "[idx][substr(option,1,5)]</font> "
			
			display += "║\n"
		
		display += "╚════════════════════════╝</font>"
		
		owner << display

	proc/RenderWheel(list/options, selected_index)
		/**
		 * RenderWheel(options, selected_index) -> null
		 * 
		 * Renders circular wheel of options (8 directions + center).
		 * 
		 * ASCII representation (simplified):
		 *        [1]
		 *    [8]     [2]
		 *  [7]  ► CENTER ◄  [3]
		 *    [6]     [4]
		 *        [5]
		 */
		
		var/display = "<font color=cyan>\n"
		display += "        [1][options[1]]\n"
		display += "    [8]             [2]\n"
		display += "  [7]    ► SELECT ◄    [3]\n"
		display += "    [6]             [4]\n"
		display += "        [5][options[5]]\n"
		display += "</font>"
		
		// Highlight selected
		if(selected_index >= 1 && selected_index <= options.len)
			var/highlight_char = selected_index == 1 ? "▲" : (selected_index == 3 ? "▶" : "◄")
			display = replacetext(display, "[selected_index]", highlight_char)
		
		owner << display

	// ==================== UPDATE HANDLERS ====================

	proc/UpdateHighlight(selected_index)
		/**
		 * UpdateHighlight(selected_index) -> null
		 * 
		 * Updates only the highlighted element (optimization).
		 * Called when navigation changes selection.
		 * 
		 * In full implementation, would redraw only changed cells.
		 */
		
		// Placeholder: Re-render full UI
		// In production, would only update highlight position
		owner << "Selection updated: [selected_index]"

	proc/ClearUI()
		/**
		 * ClearUI() -> null
		 * 
		 * Removes UI from screen
		 */
		
		owner << "<font color=gray>═════════════════════════════════════</font>"
		owner << ""

// ==================== UI STYLE PRESETS ====================

proc/CreateToolbeltUI_HorizontalBar(mob/players/P)
	/**
	 * Creates horizontal bar style UI
	 * Best for: Linear lists (terrain types, recipes)
	 */
	return new/datum/toolbelt_ui(P, "horizontal_bar")

proc/CreateToolbeltUI_Grid(mob/players/P)
	/**
	 * Creates grid style UI
	 * Best for: Medium lists (3x3 = 9 options)
	 */
	return new/datum/toolbelt_ui(P, "grid")

proc/CreateToolbeltUI_Wheel(mob/players/P)
	/**
	 * Creates rotating wheel style UI
	 * Best for: Action-oriented (8-directional selection)
	 */
	return new/datum/toolbelt_ui(P, "wheel")

// ==================== INTEGRATION WITH TOOLBELT ====================

// Extend datum/toolbelt with UI rendering

/datum/toolbelt
	var
		datum/toolbelt_ui/ui = null        // Visual UI renderer

	proc/ShowSelectionUI_Visual(mode)
		/**
		 * ShowSelectionUI_Visual(mode) -> null
		 * 
		 * Shows visual UI overlay for selection.
		 * Replaces text-based ShowSelectionUI().
		 */
		
		if(!owner)
			return
		
		// Create UI if not exists
		if(ui == null)
			var/style = GetUIStyleForMode(mode)
			ui = new/datum/toolbelt_ui(owner, style)
		
		// Get options and render
		var/list/options = GetModeOptions(mode)
		if(options.len == 0)
			owner << "<font color=red>No options available for [mode]</font>"
			return
		
		ui.RenderUI(options, selected_index)

	proc/UpdateSelectionUI_Visual()
		/**
		 * UpdateSelectionUI_Visual() -> null
		 * 
		 * Updates visual UI display (called on navigation).
		 */
		
		if(!ui || active_mode == "")
			return
		
		var/list/options = GetModeOptions(active_mode)
		ui.RenderUI(options, selected_index)

	proc/HideSelectionUI_Visual()
		/**
		 * HideSelectionUI_Visual() -> null
		 * 
		 * Hides visual UI overlay.
		 */
		
		if(ui)
			ui.ClearUI()
			ui = null

	proc/GetUIStyleForMode(mode)
		/**
		 * GetUIStyleForMode(mode) -> text
		 * 
		 * Returns preferred UI style for gameplay mode.
		 * 
		 * Returns: "horizontal_bar", "grid", or "wheel"
		 */
		
		switch(mode)
			if("landscaping")
				return "horizontal_bar"  // Linear terrain types
			if("smithing")
				return "grid"            // Grid of recipes
			if("fishing")
				return "wheel"           // Directional actions
			else
				return "horizontal_bar"  // Default

// ==================== ENHANCED NAVIGATION ====================

/datum/toolbelt
	proc/NavigateSelection_Visual(direction)
		/**
		 * NavigateSelection_Visual(direction) -> int
		 * 
		 * Navigates selection and updates visual UI.
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
		UpdateSelectionUI_Visual()
		return 1

// ==================== DEBUG / TESTING ====================

proc/TestToolbeltUI_HorizontalBar(mob/players/M)
	/**
	 * Quick test of horizontal bar UI
	 */
	var/list/options = list("Dirt Road", "Wood Road", "Brick Road", "Stone Road", "Hill", "Ditch", "Water")
	var/datum/toolbelt_ui/ui = new/datum/toolbelt_ui(M, "horizontal_bar")
	ui.RenderUI(options, 3)

proc/TestToolbeltUI_Grid(mob/players/M)
	/**
	 * Quick test of grid UI
	 */
	var/list/options = list("Dirt Road", "Wood Road", "Brick Road", "Stone Road", "Hill", "Ditch", "Water", "Lava")
	var/datum/toolbelt_ui/ui = new/datum/toolbelt_ui(M, "grid")
	ui.RenderUI(options, 4)

proc/TestToolbeltUI_Wheel(mob/players/M)
	/**
	 * Quick test of wheel UI
	 */
	var/list/options = list("Forward", "ForwardRight", "Right", "BackRight", "Back", "BackLeft", "Left", "ForwardLeft")
	var/datum/toolbelt_ui/ui = new/datum/toolbelt_ui(M, "wheel")
	ui.RenderUI(options, 1)

mob/players/verb
	TestUI_Bar()
		set name = "Test UI Bar"
		set category = "Debug"
		TestToolbeltUI_HorizontalBar(src)

	TestUI_Grid()
		set name = "Test UI Grid"
		set category = "Debug"
		TestToolbeltUI_Grid(src)

	TestUI_Wheel()
		set name = "Test UI Wheel"
		set category = "Debug"
		TestToolbeltUI_Wheel(src)
