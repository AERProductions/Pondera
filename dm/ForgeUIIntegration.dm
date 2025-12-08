// ForgeUIIntegration.dm
// Temperature-aware forge/anvil UI with dialogs and status displays
// Integrates TemperatureSystem with forge mechanics and player feedback

// Enhanced forge interface with temperature validation
obj/Buildable/Smithing/verb
	Check_Forge_Status()
		set popup_menu = 1
		set src in oview(1)
		set category = "Smithing"
		
		var/mob/players/M = usr
		var/output = "<h2><center>Forge Status</center></h2><br>"
		
		// Check forge active state
		if(forge_active)
			output += "<font color='#FF4500'><b>Status:</b> Lit and Active</font><br>"
		else
			output += "<font color='#696969'><b>Status:</b> Cold/Dormant</font><br>"
		
		// List available workable items
		var/list/workable = M.GetWorkableItems()
		output += "<br><b>Available Items for Heating:</b><br>"
		if(workable.len > 0)
			for(var/obj/items/thermable/item in workable)
				var/temp_color = item.GetTemperatureColor()
				output += "• [item.name]: <font color='[temp_color]'>[item.GetTemperatureName()]</font><br>"
		else
			output += "<i>No items available (must be in inventory)</i><br>"
		
		// List quenchable items
		var/list/quenchable = M.GetQuenchableItems()
		output += "<br><b>Items Ready for Quenching:</b><br>"
		if(quenchable.len > 0)
			for(var/obj/items/thermable/item in quenchable)
				output += "• [item.name] (HOT)<br>"
		else
			output += "<i>No items ready (must be HOT state)</i><br>"
		
		output += "<br><hr><br><b>Forge Tips:</b><br>"
		output += "• Heat items in the forge until they glow orange (HOT)<br>"
		output += "• Work items while HOT or WARM (gold color)<br>"
		output += "• Quench ONLY when item is HOT in water trough<br>"
		
		M << output

	Heat_Item_Dialog()
		set popup_menu = 1
		set src in oview(1)
		set category = "Smithing"
		
		var/mob/players/M = usr
		var/list/workable = M.GetWorkableItems()
		
		if(workable.len == 0)
			M << "<font color='#FF0000'><b>No items available to heat!</b></font>"
			return
		
		// Build list for input dialog
		var/list/item_choices = list()
		for(var/obj/items/thermable/item in workable)
			item_choices += "[item.name] ([item.GetTemperatureName()])"
		
		var/selected = input(M, "Select item to heat:", "Forge Heating") in item_choices
		if(!selected)
			return
		
		// Find the selected item
		var/obj/items/thermable/target
		for(var/obj/items/thermable/item in workable)
			if("[item.name] ([item.GetTemperatureName()])" == selected)
				target = item
				break
		
		if(!target)
			M << "<font color='#FF0000'>Item not found!</font>"
			return
		
		// Heat the item
		HeatItem(target, M)

	Quench_Item_Dialog()
		set popup_menu = 1
		set src in oview(1)
		set category = "Smithing"
		
		var/mob/players/M = usr
		var/list/quenchable = M.GetQuenchableItems()
		
		if(quenchable.len == 0)
			M << "<font color='#FF0000'><b>No items ready for quenching (must be HOT)!</b></font>"
			return
		
		// Build list for input dialog
		var/list/item_choices = list()
		for(var/obj/items/thermable/item in quenchable)
			item_choices += item.name
		
		var/selected = input(M, "Select item to quench:", "Quench") in item_choices
		if(!selected)
			return
		
		// Find the selected item
		var/obj/items/thermable/target
		for(var/obj/items/thermable/item in quenchable)
			if(item.name == selected)
				target = item
				break
		
		if(!target || !target.IsQuenchable())
			M << "<font color='#FF0000'>Item not found or not ready!</font>"
			return
		
		// Attempt quench
		var/success = target.temperature_stage == TEMP_HOT
		if(success)
			M << "<font color='#00FF00'><b>Successfully quenched [target]!</b></font>"
			target.temperature_stage = TEMP_COOL
			target.UpdateDisplay()
		else
			M << "<font color='#FF6600'><b>Quench attempt failed - item not hot enough!</b></font>"

// Enhanced water trough with temperature awareness
obj/Buildable/WaterTrough/verb
	Check_Trough_Status()
		set popup_menu = 1
		set src in oview(1)
		set category = "Water"
		
		var/mob/players/M = usr
		var/output = "<h2><center>Water Trough Status</center></h2><br>"
		output += "<b>Current Contents:</b> Cool spring water<br><br>"
		
		// List quenchable items
		var/list/quenchable = M.GetQuenchableItems()
		output += "<b>Items Ready for Quenching:</b><br>"
		if(quenchable.len > 0)
			for(var/obj/items/thermable/item in quenchable)
				output += "• [item.name] (HOT)<br>"
		else
			output += "<i>No items ready (must be in inventory and HOT)</i><br>"
		
		// List workable items
		var/list/workable = M.GetWorkableItems()
		output += "<br><b>Items at Working Temperature:</b><br>"
		if(workable.len > 0)
			for(var/obj/items/thermable/item in workable)
				var/temp_color = item.GetTemperatureColor()
				output += "• [item.name]: <font color='[temp_color]'>[item.GetTemperatureName()]</font><br>"
		else
			output += "<i>No items available</i><br>"
		
		output += "<br><hr><br><b>Quenching Notes:</b><br>"
		output += "• HOT items fully quench (ready for refinement)<br>"
		output += "• WARM items partially quench (needs more work)<br>"
		
		M << output

	Quench_Item()
		set popup_menu = 1
		set src in oview(1)
		set category = "Water"
		
		var/mob/players/M = usr
		var/list/quenchable = M.GetQuenchableItems()
		
		if(quenchable.len == 0)
			M << "<font color='#FF0000'><b>No items ready for quenching!</b></font>"
			return
		
		// Build list for input dialog
		var/list/item_choices = list()
		for(var/obj/items/thermable/item in quenchable)
			item_choices += item.name
		
		var/selected = input(M, "Select item to quench:", "Water Quench") in item_choices
		if(!selected)
			return
		
		// Find the selected item
		var/obj/items/thermable/target
		for(var/obj/items/thermable/item in quenchable)
			if(item.name == selected)
				target = item
				break
		
		if(!target)
			M << "<font color='#FF0000'>Item not found!</font>"
			return
		
		// Perform quench with appropriate feedback
		M << "<b>You carefully lower the [target] into the cool water...</b>"
		
		if(target.temperature_stage == TEMP_HOT)
			// Full quench - item ready for work
			M << "<font color='#00FF00'><b>The item hisses and steams! Properly quenched!</b></font>"
			target.temperature_stage = TEMP_COOL
			target.UpdateDisplay()
		else if(target.temperature_stage == TEMP_WARM)
			// Partial quench - needs more work
			M << "<font color='#FFD700'><b>The item cools down, but could use more heat-working.</b></font>"
			target.temperature_stage = TEMP_COOL
			target.UpdateDisplay()

// Temperature status display proc for mob
mob/players/proc
	Display_Temperature_Overlay()
		// Create dynamic screen overlay showing item temperatures
		var/list/temps = list()
		for(var/obj/items/thermable/item in contents)
			var/color_hex = item.GetTemperatureColor()
			var/temp_name = item.GetTemperatureName()
			temps += "<span style='color:[color_hex]'>[item.name]: [temp_name]</span>"
		
		if(temps.len > 0)
			var/output = "<div style='position: fixed; bottom: 10px; right: 10px; background: rgba(0,0,0,0.7); color: white; padding: 10px; border-radius: 5px; font-family: monospace;'>"
			output += "<b>Inventory Temperatures:</b><br>"
			for(var/t in temps)
				output += "[t]<br>"
			output += "</div>"
			statpanel("Temperatures", output)

// Forge enhancement: linked heating with visual feedback
obj/Buildable/Smithing/proc
	HeatItem_Enhanced(obj/items/thermable/item, mob/players/M)
		// Enhanced heating with visual feedback and animation
		if(!item || !M)
			return FALSE
		
		if(!forge_active)
			M << "<font color='#FF0000'>The forge is not lit!</font>"
			return FALSE
		
		if(!item.IsWorkable())
			M << "<font color='#FF0000'>[item] is not hot enough to work with!</font>"
			return FALSE
		
		// Apply heating effect
		M << "<b>You place the [item] into the forge flames...</b>"
		
		sleep(10)
		
		if(!item.Heat())
			M << "<font color='#FF6600'>[item] is already hot!</font>"
			return FALSE
		
		M << "<font color='#FF4500'><b>The [item] glows orange and is ready to work!</b></font>"
		return TRUE

// Water trough enhancement: linked quenching with validation
obj/Buildable/WaterTrough/proc
	QuenchItem_Enhanced(obj/items/thermable/item, mob/players/M)
		// Enhanced quenching with validation and feedback
		if(!item || !M)
			return FALSE
		
		if(!item.IsQuenchable())
			M << "<font color='#FF0000'>[item] is not hot enough to quench properly!</font>"
			return FALSE
		
		M << "<b>You submerge the glowing [item] into the water...</b>"
		sleep(5)
		
		item.temperature_stage = TEMP_COOL
		item.UpdateDisplay()
		
		M << "<font color='#00FF00'><b>Steam rises as the [item] is quenched! Ready for refinement!</b></font>"
		return TRUE

// ============================================================================
// REFINEMENT SYSTEM INTEGRATION - Connect RefinementSystem to Forge UI
// ============================================================================

obj/Buildable/Smithing/verb
	Refine_Item_Dialog()
		set popup_menu = 1
		set src in oview(1)
		set category = "Smithing"
		
		var/mob/players/M = usr
		
		// Check if player has any items needing refinement
		var/has_refinable = FALSE
		for(var/obj/items/crafting/refined/item in M.contents)
			if(item.CanRefine())
				has_refinable = TRUE
				break
		
		if(!has_refinable)
			M << "<font color='#FF0000'>You have no items that need refinement.</font>"
			return
		
		// Show refinement status
		var/output = "<h2><center>Item Refinement</center></h2><br>"
		output += "<b>Stages:</b><br>"
		output += "1. File - Smooth the surface<br>"
		output += "2. Sharpen - Create sharp edges<br>"
		output += "3. Polish - Perfect the finish<br><br>"
		
		output += "<b>Your Items:</b><br>"
		for(var/obj/items/crafting/refined/item in M.contents)
			if(!item.CanRefine()) continue
			var/stage_name = item.GetStageNameForDisplay(item.refine_stage)
			var/next_tool = item.GetToolName(item.GetNextToolNeeded())
			output += "• [item.name]: [stage_name] (Quality: [item.refine_quality]%)<br>"
			output += "   Needs: [next_tool]<br><br>"
		
		M << output
		
		// Ask which tool to use
		var/choice = input(M, "Select refinement tool:", "Refinement") in list(
			"File (Stage 1)",
			"Whetstone (Stage 2)",
			"Polish Cloth (Stage 3)",
			"Cancel"
		)
		
		if(!choice || choice == "Cancel")
			return
		
		// Find the tool and attempt refinement
		var/tool_type = 0
		switch(choice)
			if("File (Stage 1)")
				tool_type = REFINE_TOOL_FILE
			if("Whetstone (Stage 2)")
				tool_type = REFINE_TOOL_WHETSTONE
			if("Polish Cloth (Stage 3)")
				tool_type = REFINE_TOOL_POLISH_CLOTH
		
		// Find items matching this stage
		var/list/matching_items = list()
		for(var/obj/items/crafting/refined/item in M.contents)
			if(!item.CanRefine()) continue
			if(item.GetNextToolNeeded() == tool_type)
				matching_items += item
		
		if(!matching_items.len)
			M << "<font color='#FF0000'>You have no items ready for this refinement stage.</font>"
			return
		
		// Auto-select first matching item
		var/obj/items/crafting/refined/target = matching_items[1]
		
		// Perform refinement
		M << "<b>You begin refining [target.name]...</b>"
		sleep(15)  // Time for refinement
		
		var/success_chance = target.GetSuccessProbability()
		if(prob(success_chance))
			target.refine_stage += 1
			target.refine_quality = min(100, target.refine_quality + rand(5, 15))
			M << "<font color='#00FF00'><b>[target.name] has been successfully refined!</b></font>"
			
			// Stage advancement is the main result
			// Items can have OnFiled/OnSharpened/OnPolished procs if desired
		else
			target.refine_quality = min(100, target.refine_quality + rand(2, 5))
			target.refine_durability = max(20, target.refine_durability - rand(3, 8))
			M << "<font color='#FFD700'>[target.name] could use more refinement.</font>"

