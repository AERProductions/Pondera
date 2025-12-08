// ============================================================================
// FILE: AdminSystemRefactor.dm
// PURPOSE: Complete admin command system
// ============================================================================

#define ADMIN_NONE        0
#define ADMIN_MODERATOR   1
#define ADMIN_ADMIN       2
#define ADMIN_HOST        3

var/AdminSystem/admin_system = new()

AdminSystem
	var
		list/admin_log = list()
		list/player_bans = list()
		list/player_mutes = list()
	
	New()
		admin_log = list()
	
	proc
		get_admin_level(mob/player)
			if(!player) return ADMIN_NONE
			if(ckeyEx("[player.key]") == world.host)
				return ADMIN_HOST
			return ADMIN_NONE
		
		has_permission(mob/player, required_level)
			return get_admin_level(player) >= required_level
		
		log_action(mob/admin, action, target, details)
			var/entry = "[time2text(world.timeofday)] - [admin.key]: [action] on [target] - [details]"
			admin_log += entry
		
		get_logs(num_entries)
			var/list/result = list()
			var/start = max(1, admin_log.len - num_entries + 1)
			for(var/i = start; i <= admin_log.len; i++)
				result += admin_log[i]
			return result

mob/verb
	open_admin_panel()
		set category = "Admin"
		
		if(admin_system.get_admin_level(src) < ADMIN_MODERATOR)
			src << "Access denied."
			return
		
		var/html = "<div style='width: 500px; border: 2px solid gold;'>"
		html += "<h2>Admin Control Panel</h2>"
		html += "<hr>"
		html += "<h3>Player Management</h3>"
		html += "<ul>"
		html += "<li><a href='?adm=kick_player'>Kick Player</a></li>"
		html += "<li><a href='?adm=ban_player'>Ban Player</a></li>"
		html += "<li><a href='?adm=mute_player'>Mute Player</a></li>"
		html += "</ul>"
		html += "<h3>System</h3>"
		html += "<ul>"
		html += "<li><a href='?adm=view_logs'>View Logs</a></li>"
		html += "</ul>"
		html += "</div>"
		src << html
	
	kick_player()
		set category = "Admin"
		
		if(admin_system.get_admin_level(src) < ADMIN_MODERATOR)
			src << "Access denied."
			return
		
		var/target_key = input(src, "Enter player key:") as null|text
		if(!target_key) return
		
		var/mob/target = null
		for(var/mob/m in world.contents)
			if(m.key && m.key == target_key)
				target = m
				break
		
		if(!target)
			src << "Player not found."
			return
		
		admin_system.log_action(src, "KICK", target.key, "Kicked from server")
		target << "You have been kicked."
		del target
		src << "[target.key] has been kicked."
	
	ban_player()
		set category = "Admin"
		
		if(admin_system.get_admin_level(src) < ADMIN_ADMIN)
			src << "Access denied."
			return
		
		var/target_key = input(src, "Enter player key:") as null|text
		if(!target_key) return
		
		admin_system.player_bans += target_key
		admin_system.log_action(src, "BAN", target_key, "Banned")
		src << "[target_key] has been banned."
	
	mute_player()
		set category = "Admin"
		
		if(admin_system.get_admin_level(src) < ADMIN_MODERATOR)
			src << "Access denied."
			return
		
		var/target_key = input(src, "Enter player key:") as null|text
		if(!target_key) return
		
		admin_system.player_mutes[target_key] = world.time + 600  // 10 minutes
		admin_system.log_action(src, "MUTE", target_key, "Muted for 10 minutes")
		src << "[target_key] has been muted."
	
	view_admin_logs()
		set category = "Admin"
		
		if(admin_system.get_admin_level(src) < ADMIN_MODERATOR)
			src << "Access denied."
			return
		
		var/list/logs = admin_system.get_logs(50)
		var/html = "<div style='font-family: monospace; font-size: 11px;'>"
		html += "<h3>Admin Logs</h3>"
		for(var/entry in logs)
			html += "[entry]<br>"
		html += "</div>"
		src << html

// ============================================================================
// INTEGRATION EXAMPLES - Working crafting system template
// ============================================================================

mob/verb
	/// Example: Combine tool parts (demonstrates FilteringLibrary)
	example_combine_tool_parts()
		set category = "Crafting"
		set hidden = 1
		
		// Get available handles
		var/list/handles = src.get_inventory_tool_handles()
		if(!handles.len)
			src << "You have no tool handles to combine."
			return
		
		// Get available heads
		var/list/heads = src.get_inventory_tool_heads()
		if(!heads.len)
			src << "You have no tool heads to combine."
			return
		
		// User selects items (100% guaranteed to be correct types)
		var/handle_choice = input(src, "Select a tool handle:", "Tool Crafting") as null|anything in handles
		if(!handle_choice)
			return
		
		var/head_choice = input(src, "Select a tool head:", "Tool Crafting") as null|anything in heads
		if(!head_choice)
			return
		
		src << "Combining [handle_choice:name] with [head_choice:name]..."
		
		// Actual crafting would happen here
		// del handle_choice
		// del head_choice
	
	/// Example: Show inventory summary (demonstrates admin + filtering)
	example_inventory_summary()
		set category = "Inventory"
		set hidden = 1
		
		if(admin_system.get_admin_level(src) < ADMIN_NONE)
			return
		
		var/summary = "Inventory Summary:<br>"
		summary += "Weapons: [src.get_inventory_weapons().len]<br>"
		summary += "Armor: [src.get_inventory_armor().len]<br>"
		summary += "Tools: [src.get_inventory_tools().len]<br>"
		summary += "Tool Handles: [src.get_inventory_tool_handles().len]<br>"
		summary += "Tool Heads: [src.get_inventory_tool_heads().len]<br>"
		summary += "Ores: [src.get_inventory_ores().len]<br>"
		summary += "Logs: [src.get_inventory_logs().len]<br>"
		summary += "Plants: [src.get_inventory_plants().len]<br>"
		
		src << summary
	
	admin_audit_self_inventory()
		set category = "Admin"
		set hidden = 1
		
		if(admin_system.get_admin_level(src) < ADMIN_MODERATOR)
			src << "Access denied."
			return
		
		var/report = "Your Inventory Audit:<br>"
		report += "Total items: [src.contents.len]<br>"
		report += "Weapons: [src.get_inventory_weapons().len]<br>"
		report += "Armor: [src.get_inventory_armor().len]<br>"
		report += "Resources: [src.get_inventory_ores().len + src.get_inventory_logs().len + src.get_inventory_plants().len]<br>"
		report += "Tools: [src.get_inventory_tools().len]<br>"
		
		src << report
		admin_system.log_action(src, "audit_inventory", src.key, "Audited self inventory")
	
	admin_check_own_market()
		set category = "Admin"
		set hidden = 1
		
		if(admin_system.get_admin_level(src) < ADMIN_MODERATOR)
			src << "Access denied."
			return
		
		var/list/marketable = GetMarketableItemsFiltered(src)
		
		var/report = "Your Marketable Items ([marketable.len]):<br>"
		for(var/item in marketable)
			var/obj/it = item
			if(it)
				report += "- [it.name]<br>"
		
		src << report
		admin_system.log_action(src, "check_market", src.key, "[marketable.len] marketable items")
	
	admin_quick_list()
		set category = "Admin"
		set hidden = 1
		
		if(admin_system.get_admin_level(src) < ADMIN_MODERATOR)
			src << "Access denied."
			return
		
		var/list/marketable = GetMarketableItemsFiltered(src)
		if(!marketable.len)
			src << "You have no marketable items."
			return
		
		var/selected = input(src, "Which item to list?", "Quick List") as null|anything in marketable
		if(!selected)
			return
		
		var/obj/item = selected
		var/price = input(src, "Price per unit?", "Amount") as num
		if(price < 0) price = 0
		
		var/datum/market_board_manager/board = GetMarketBoard()
		if(board)
			board.CreateListing(src, item.name, "[item.type]", 1, price, "lucre")
			src << "Listed [item.name] for [price] lucre"
			admin_system.log_action(src, "admin_list", src.key, "[item.name]")
		else
			src << "Market board not available."

