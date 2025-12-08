// ============================================================================
// FILE: SelectionWindowSystem.dm
// PURPOSE: Unified selection window framework
// ============================================================================

var/SelectionWindowSystem/selection_manager = new()

SelectionWindowSystem
	var
		list/active_windows = list()
		window_id_counter = 0
	
	proc
		show_selection(mob/user, window_type, title, filter_cb)
			if(!user) return null
			
			window_id_counter++
			var/window_id = window_id_counter
			
			var/list/items = list()
			
			// Route window type to appropriate filter
			switch(window_type)
				if("weapons")
					items = filter_manager.get_weapons(user)
				if("armor")
					items = filter_manager.get_armor(user)
				if("shields")
					items = filter_manager.get_shields(user)
				if("ores")
					items = filter_manager.get_ores(user)
				if("logs")
					items = filter_manager.get_logs(user)
				if("plants")
					items = filter_manager.get_plants(user)
				if("handles")
					items = filter_manager.get_tool_handles(user)
				if("heads")
					items = filter_manager.get_tool_heads(user)
				if("tools")
					items = filter_manager.get_tools(user)
				if("tradeable")
					items = filter_manager.get_tradeable(user)
				else
					items = filter_manager.get_items(user)
			
			// Build HTML window
			var/html = "<div style='width: 400px; border: 2px solid black;'>"
			html += "<h3>[title]</h3>"
			html += "<hr>"
			
			if(!items.len)
				html += "<p><i>No items available.</i></p>"
			else
				html += "<ul>"
				for(var/item in items)
					var/item_name = item
					if(isobj(item))
						item_name = item:name
					html += "<li><a href='?select_item=[item_name]'>[item_name]</a></li>"
				html += "</ul>"
			
			html += "</div>"
			
			active_windows[window_id] = list("user" = user, "type" = window_type, "items" = items, "filter" = filter_cb)
			user << html
			
			return window_id

mob/proc
	show_tool_selection(callback)
		if(!callback) callback = null
		return selection_manager.show_selection(src, "tools", "Select a Tool", callback)
	
	show_tool_handle_selection(callback)
		if(!callback) callback = null
		return selection_manager.show_selection(src, "handles", "Select a Tool Handle", callback)
	
	show_tool_head_selection(callback)
		if(!callback) callback = null
		return selection_manager.show_selection(src, "heads", "Select a Tool Head", callback)
	
	show_weapon_selection(callback)
		if(!callback) callback = null
		return selection_manager.show_selection(src, "weapons", "Select a Weapon", callback)
	
	show_armor_selection(callback)
		if(!callback) callback = null
		return selection_manager.show_selection(src, "armor", "Select Armor", callback)
	
	show_ore_selection(callback)
		if(!callback) callback = null
		return selection_manager.show_selection(src, "ores", "Select Ore", callback)
	
	show_log_selection(callback)
		if(!callback) callback = null
		return selection_manager.show_selection(src, "logs", "Select Log", callback)
	
	show_plant_selection(callback)
		if(!callback) callback = null
		return selection_manager.show_selection(src, "plants", "Select Plant", callback)
