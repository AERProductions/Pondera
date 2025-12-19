// ============================================================================
// FILE: FilteringLibrary.dm
// PURPOSE: Centralized item filtering for systems
// ============================================================================

var/FilteringLibrary/filter_manager = new()

FilteringLibrary
	proc
		// Get items from container (mob or object)
		get_items(container)
			if(!container)
				return list()
			return container:contents
		
		// EQUIPMENT FILTERS
		is_weapon(item)
			if(!item) return 0
			var/obj/test = item
			if(!test) return 0
			var/type_str = "[test.type]"
			if(findtext(type_str, "Weapon") || findtext(type_str, "Sword") || findtext(type_str, "Knife") || findtext(type_str, "Axe") || findtext(type_str, "Hammer"))
				return 1
			return 0
		
		is_armor(item)
			if(!item) return 0
			var/obj/test = item
			if(!test) return 0
			var/type_str = "[test.type]"
			if(findtext(type_str, "Armor") || findtext(type_str, "Chest") || findtext(type_str, "Helmet") || findtext(type_str, "Gloves") || findtext(type_str, "Boots") || findtext(type_str, "Robe"))
				return 1
			return 0
		
		is_shield(item)
			if(!item) return 0
			var/obj/test = item
			if(!test) return 0
			var/type_str = "[test.type]"
			if(findtext(type_str, "Shield"))
				return 1
			return 0
		
		get_weapons(container)
			var/list/items = get_items(container)
			var/list/result = list()
			for(var/item in items)
				if(is_weapon(item))
					result += item
			return result
		
		get_armor(container)
			var/list/items = get_items(container)
			var/list/result = list()
			for(var/item in items)
				if(is_armor(item))
					result += item
			return result
		
		get_shields(container)
			var/list/items = get_items(container)
			var/list/result = list()
			for(var/item in items)
				if(is_shield(item))
					result += item
			return result
		
		// RESOURCE FILTERS
		is_ore(item)
			if(!item) return 0
			var/obj/test = item
			if(!test) return 0
			var/type_str = "[test.type]"
			if(findtext(type_str, "Ore") || findtext(type_str, "Rock") || findtext(type_str, "Stone") || findtext(type_str, "Iron"))
				return 1
			return 0
		
		is_log(item)
			if(!item) return 0
			var/obj/test = item
			if(!test) return 0
			var/type_str = "[test.type]"
			if(findtext(type_str, "Log") || findtext(type_str, "Wood") || findtext(type_str, "Tree"))
				return 1
			return 0
		
		is_plant(item)
			if(!item) return 0
			var/obj/test = item
			if(!test) return 0
			var/type_str = "[test.type]"
			if(findtext(type_str, "Herb") || findtext(type_str, "Plant") || findtext(type_str, "Seed"))
				return 1
			return 0
		
		get_ores(container)
			var/list/items = get_items(container)
			var/list/result = list()
			for(var/item in items)
				if(is_ore(item))
					result += item
			return result
		
		get_logs(container)
			var/list/items = get_items(container)
			var/list/result = list()
			for(var/item in items)
				if(is_log(item))
					result += item
			return result
		
		get_plants(container)
			var/list/items = get_items(container)
			var/list/result = list()
			for(var/item in items)
				if(is_plant(item))
					result += item
			return result
		
		// TOOL FILTERS
		is_tool_handle(item)
			if(!item) return 0
			var/obj/test = item
			if(!test) return 0
			var/type_str = "[test.type]"
			if(findtext(type_str, "Handle") || findtext(type_str, "handle"))
				return 1
			return 0
		
		is_tool_head(item)
			if(!item) return 0
			var/obj/test = item
			if(!test) return 0
			var/type_str = "[test.type]"
			if(findtext(type_str, "Head") || findtext(type_str, "Blade") || findtext(type_str, "head") || findtext(type_str, "blade"))
				return 1
			return 0
		
		is_tool(item)
			if(!item) return 0
			var/obj/test = item
			if(!test) return 0
			var/type_str = "[test.type]"
			if(findtext(type_str, "Tool") || findtext(type_str, "Hoe") || findtext(type_str, "Shovel") || findtext(type_str, "Pickaxe") || findtext(type_str, "Axe") || findtext(type_str, "Hammer"))
				return 1
			return 0
		
		get_tool_handles(container)
			var/list/items = get_items(container)
			var/list/result = list()
			for(var/item in items)
				if(is_tool_handle(item))
					result += item
			return result
		
		get_tool_heads(container)
			var/list/items = get_items(container)
			var/list/result = list()
			for(var/item in items)
				if(is_tool_head(item))
					result += item
			return result
		
		get_tools(container)
			var/list/items = get_items(container)
			var/list/result = list()
			for(var/item in items)
				if(is_tool(item))
					result += item
			return result
		
		// MARKET FILTERS
		get_tradeable(container)
			var/list/items = get_items(container)
			var/list/result = list()
			for(var/item in items)
				var/obj/test = item
				if(test)
					result += item
			return result

mob/proc
	get_inventory_weapons()
		return filter_manager.get_weapons(src)
	
	get_inventory_armor()
		return filter_manager.get_armor(src)
	
	get_inventory_shields()
		return filter_manager.get_shields(src)
	
	get_inventory_ores()
		return filter_manager.get_ores(src)
	
	get_inventory_logs()
		return filter_manager.get_logs(src)
	
	get_inventory_plants()
		return filter_manager.get_plants(src)
	
	
	get_inventory_tool_handles()
		return filter_manager.get_tool_handles(src)
	
	get_inventory_tool_heads()
		return filter_manager.get_tool_heads(src)
	
	get_inventory_tool_parts()
		var/list/handles = filter_manager.get_tool_handles(src)
		var/list/heads = filter_manager.get_tool_heads(src)
		return handles + heads
	
	get_inventory_tools()
		return filter_manager.get_tools(src)
	
	get_inventory_tradeable()
		return filter_manager.get_tradeable(src)

// ============================================================================
// TEMPERATURE-STATE FILTERS (For Smithing Integration)
// ============================================================================

FilteringLibrary
	proc
		is_hot_item(item)
			if(!item) return 0
			var/obj/test = item
			if(!test) return 0
			if(istype(test, /obj/items/thermable))
				if(test:temperature_stage == TEMP_HOT)
					return 1
			return 0
		
		is_workable_item(item)
			if(!item) return 0
			var/obj/test = item
			if(!test) return 0
			if(istype(test, /obj/items/thermable))
				return test:IsWorkable()
			return 0
		
		get_hot_items(container)
			var/list/items = get_items(container)
			var/list/result = list()
			for(var/item in items)
				if(is_hot_item(item))
					result += item
			return result
		
		get_workable_items(container)
			var/list/items = get_items(container)
			var/list/result = list()
			for(var/item in items)
				if(is_workable_item(item))
					result += item
			return result

mob
	proc
		get_inventory_hot_items()
			return filter_manager.get_hot_items(src)
		
		get_inventory_workable_items()
			return filter_manager.get_workable_items(src)
