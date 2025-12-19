/// ToolDurabilitySystem.dm
/// Universal durability system for all tools (pickaxe, hammer, axe, shovel, hoe, etc.)
/// - All tools use same durability mechanics
/// - Backend only: no UI menus needed
/// - Durability loss shown in HUD notifications as feedback
/// - Durability affects tool lifetime, not functionality (broken tools can't be used)

/datum/tool_durability
	var
		current_durability = 100        // Current durability points
		max_durability = 100            // Max durability based on tool type
		tool_type = "ueik_pickaxe"      // Identifier for tool (e.g. "ueik_pickaxe", "iron_pickaxe")
		display_name = "pickaxe"        // Friendly name for HUD messages
		durability_loss_per_use = 5     // Amount lost per tool use
		fragility_threshold = 20        // Below this % = show wear message
		is_broken = FALSE

	New(tool_type_name = "ueik_pickaxe")
		tool_type = tool_type_name
		
		// Set stats based on tool type (rudimentary -> advanced progression)
		switch(tool_type)
			// PICKAXES
			if("ueik_pickaxe")
				display_name = "Ueik Pickaxe"
				max_durability = 50
				current_durability = 50
				durability_loss_per_use = 8     // Degrades FAST (6 uses before breaking)
			if("iron_pickaxe")
				display_name = "Iron Pickaxe"
				max_durability = 150
				current_durability = 150
				durability_loss_per_use = 5      // Moderate (30 uses)
			if("steel_pickaxe")
				display_name = "Steel Pickaxe"
				max_durability = 300
				current_durability = 300
				durability_loss_per_use = 4      // Durable (75 uses)
			// HAMMERS (future)
			if("stone_hammer")
				display_name = "Stone Hammer"
				max_durability = 40
				durability_loss_per_use = 6
			if("iron_hammer")
				display_name = "Iron Hammer"
				max_durability = 120
				durability_loss_per_use = 4
			// AXES (future)
			if("stone_axe")
				display_name = "Stone Axe"
				max_durability = 45
				durability_loss_per_use = 7
			if("iron_axe")
				display_name = "Iron Axe"
				max_durability = 140
				durability_loss_per_use = 4
			// Add more tools as needed
			else
				// Safe default
				max_durability = 50
				current_durability = 50
				durability_loss_per_use = 5

	proc/GetDurabilityPercent()
		if(max_durability <= 0) return 0
		return round((current_durability / max_durability) * 100)

	proc/IsFragile()
		return GetDurabilityPercent() <= fragility_threshold

	proc/IsBroken()
		return current_durability <= 0

	proc/UseTool()
		/// Called each time tool is used (pick ore, swing hammer, etc.)
		/// Returns TRUE if tool still works, FALSE if just broke
		
		if(IsBroken())
			return FALSE
		
		current_durability -= durability_loss_per_use
		if(current_durability < 0)
			current_durability = 0
			is_broken = TRUE
		
		return !is_broken

	proc/GetWearMessage()
		var/percent = GetDurabilityPercent()
		if(percent > 75)
			return "<cyan>[display_name] is in good condition.</cyan>"
		else if(percent > 50)
			return "<yellow>[display_name] shows some wear.</yellow>"
		else if(percent > 25)
			return "<yellow>[display_name] is heavily worn and fragile!</yellow>"
		else if(percent > 0)
			return "<orange>[display_name] is almost broken!</orange>"
		else
			return "<red>[display_name] has shattered!</red>"


/mob/players
	var
		// Active tool durability datum (all tools use same system)
		datum/tool_durability/tool_durability = null

	proc/InitializeToolDurability(obj/item/tool_item)
		/// Called when player equips a tool
		/// Determines tool type from item and creates durability datum
		if(!tool_item)
			tool_durability = null
			return FALSE
		
		var/tool_type = DetectToolType(tool_item)
		if(!tool_type)
			return FALSE
		
		tool_durability = new /datum/tool_durability(tool_type)
		return TRUE

	proc/DetectToolType(obj/item/tool_item)
		/// Returns tool_type identifier from item name/type
		/// Examples: "ueik_pickaxe", "iron_pickaxe", "stone_hammer", etc.
		
		if(!tool_item)
			return null
		
		var/item_name = lowertext(tool_item.name)
		var/item_type = lowertext(tool_item.type)
		
		// PICKAXES
		if(findtext(item_name, "ueik") && (findtext(item_name, "pickaxe") || findtext(item_name, "pick")))
			return "ueik_pickaxe"
		if(findtext(item_name, "iron") && (findtext(item_name, "pickaxe") || findtext(item_name, "pick")))
			return "iron_pickaxe"
		if(findtext(item_name, "steel") && (findtext(item_name, "pickaxe") || findtext(item_name, "pick")))
			return "steel_pickaxe"
		
		// HAMMERS (future detection)
		if((findtext(item_name, "hammer") || findtext(item_type, "hammer")))
			if(findtext(item_name, "stone"))
				return "stone_hammer"
			if(findtext(item_name, "iron"))
				return "iron_hammer"
		
		// AXES (future detection)
		if((findtext(item_name, "axe") || findtext(item_type, "axe")))
			if(findtext(item_name, "stone"))
				return "stone_axe"
			if(findtext(item_name, "iron"))
				return "iron_axe"
		
		return null
