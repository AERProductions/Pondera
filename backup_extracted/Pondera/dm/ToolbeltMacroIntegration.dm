/*
 * TOOLBELT HOTKEY MACRO INTEGRATION
 * 
 * Integrates toolbelt system with macro keys (1-9).
 * Players press number keys to activate tools in corresponding hotbar slots.
 * 
 * ARCHITECTURE:
 * - Verb-based macro system for 1-9 hotkeys
 * - Calls toolbelt.ActivateTool() directly
 * - Arrow keys navigate selection UI
 * - E key confirms selection and executes action
 */

mob/players/verb
	// ==================== HOTKEY ACTIVATION ====================
	
	// Slot 1
	Toolbelt_Slot_1()
		set name = "1"
		set hidden = 1
		set category = null
		
		if(!src.toolbelt)
			return
		
		src.toolbelt.ActivateTool(1)
	
	// Slot 2
	Toolbelt_Slot_2()
		set name = "2"
		set hidden = 1
		set category = null
		
		if(!src.toolbelt)
			return
		
		src.toolbelt.ActivateTool(2)
	
	// Slot 3
	Toolbelt_Slot_3()
		set name = "3"
		set hidden = 1
		set category = null
		
		if(!src.toolbelt)
			return
		
		src.toolbelt.ActivateTool(3)
	
	// Slot 4
	Toolbelt_Slot_4()
		set name = "4"
		set hidden = 1
		set category = null
		
		if(!src.toolbelt)
			return
		
		src.toolbelt.ActivateTool(4)
	
	// Slot 5
	Toolbelt_Slot_5()
		set name = "5"
		set hidden = 1
		set category = null
		
		if(!src.toolbelt)
			return
		
		src.toolbelt.ActivateTool(5)
	
	// Slot 6
	Toolbelt_Slot_6()
		set name = "6"
		set hidden = 1
		set category = null
		
		if(!src.toolbelt)
			return
		
		src.toolbelt.ActivateTool(6)
	
	// Slot 7
	Toolbelt_Slot_7()
		set name = "7"
		set hidden = 1
		set category = null
		
		if(!src.toolbelt)
			return
		
		src.toolbelt.ActivateTool(7)
	
	// Slot 8
	Toolbelt_Slot_8()
		set name = "8"
		set hidden = 1
		set category = null
		
		if(!src.toolbelt)
			return
		
		src.toolbelt.ActivateTool(8)
	
	// Slot 9
	Toolbelt_Slot_9()
		set name = "9"
		set hidden = 1
		set category = null
		
		if(!src.toolbelt)
			return
		
		src.toolbelt.ActivateTool(9)
	
	// ==================== SELECTION NAVIGATION ====================
	
	// Arrow Up / Previous Option
	Toolbelt_Select_Up()
		set name = "Up"
		set hidden = 1
		set category = null
		
		if(!src.toolbelt)
			return
		
		src.toolbelt.NavigateSelection(-1)
	
	// Arrow Down / Next Option
	Toolbelt_Select_Down()
		set name = "Down"
		set hidden = 1
		set category = null
		
		if(!src.toolbelt)
			return
		
		src.toolbelt.NavigateSelection(1)
	
	// ==================== ACTION CONFIRMATION ====================
	
	// E Key - Confirm Selection and Execute Action
	Toolbelt_Confirm()
		set name = "E"
		set hidden = 1
		set category = null
		
		if(!src.toolbelt)
			return
		
		src.toolbelt.ConfirmSelection()
	
	// ==================== UTILITY ====================
	
	// Show Hotbar Status
	Toolbelt_Status()
		set name = "Hotbar Status"
		set category = "Toolbelt"
		
		if(!src.toolbelt)
			src << "<font color=red>Toolbelt not initialized</font>"
			return
		
		src << "<font color=cyan>========== HOTBELT STATUS ==========</font>"
		
		// Show slot contents
		var/slot_text = ""
		for(var/i = 1; i <= 9; i++)
			var/obj/item = src.toolbelt.GetSlot(i)
			var/item_name = item ? item.name : "(empty)"
			var/active_marker = (src.toolbelt.current_slot == i) ? " <-- ACTIVE" : ""
			slot_text += "<font color=yellow>\[[i]\] [item_name][active_marker]</font>\n"
		
		src << slot_text
		
		if(src.toolbelt.active_mode != "")
			src << "<font color=cyan>Current Mode: [src.toolbelt.active_mode]</font>"
		
		src << "<font color=cyan>====================================</font>"
