/// PickaxeModeIntegration.dm
/// Simplified integration: Equip tool from hotbelt → Press E on ore → Mine
/// No UI menus. Durability tracked backend only with HUD feedback.
///
/// Tool flow:
/// 1. Player equips pickaxe (or other tool) in hotbelt
/// 2. Player walks to ore location
/// 3. Player presses E key to swing tool
/// 4. ToolDurabilitySystem reduces durability (silent unless wear/break)
/// 5. Mining.dm collects ore (durability prevents action if broken)

/mob/players
	var
		obj/currently_equipped_tool = null  // Tracked tool from hotbelt
	
	verb/use_tool()
		/// E key binding - swings currently equipped tool
		/// Called when player presses E near ore/resource
		set hidden = 1
		
		if(!currently_equipped_tool)
			src << "<yellow>No tool equipped.</yellow>"
			return
		
		// Verify tool still exists
		if(!istype(currently_equipped_tool) || currently_equipped_tool.loc != src)
			currently_equipped_tool = null
			src << "<yellow>Tool lost.</yellow>"
			return
		
		// Attempt tool use (reduces durability)
		var/success = AttemptToolUse()
		
		if(!success)
			src << "<red>Tool is broken. Equip a new one.</red>"
			return
		
		// Tool is still usable - let mining.dm or other systems handle actual action
		// (mining.dm will call Mine() and this use_tool verb ensures durability already decreased)
		return TRUE
	
	proc/AttemptToolUse()
		/// Reduces tool durability and returns if tool still works
		/// Called before mining.dm executes actual ore collection
		
		if(!currently_equipped_tool || !tool_durability)
			return FALSE
		
		// Use the tool (reduces durability by 1 swing)
		if(!tool_durability.UseTool())
			// Tool just broke
			return FALSE
		
		// Tool is still usable
		return TRUE
	
	proc/OnEquipToolFromHotbelt(obj/tool)
		/// Called by ToolbeltHotbarSystem when player equips a tool
		
		if(!tool)
			currently_equipped_tool = null
			tool_durability = null
			return
		
		// Check if item is a tool (by name/type)
		var/tool_type_name = lowertext(tool.type)
		var/is_tool = FALSE
		
		if(findtext(tool_type_name, "pickaxe") || findtext(tool_type_name, "hammer") || \
		   findtext(tool_type_name, "axe") || findtext(tool_type_name, "shovel") || \
		   findtext(tool_type_name, "hoe"))
			is_tool = TRUE
		
		if(!is_tool)
			currently_equipped_tool = null
			tool_durability = null
			return
		
		// Valid tool equipped
		currently_equipped_tool = tool
		
		// Initialize durability datum if needed
		var/detected_type = DetectToolType(tool)
		if(!detected_type)
			return
		
		if(!tool_durability || tool_durability.tool_type != detected_type)
			tool_durability = new /datum/tool_durability(detected_type)
		
		src << "<cyan>Tool equipped: [tool.name]. Durability: [tool_durability.current_durability]/[tool_durability.max_durability]</cyan>"


// Integration with ToolbeltHotbarSystem.dm:
// When player presses hotbelt slot key:
//   1. ToolbeltHotbarSystem calls OnEquipToolFromHotbelt(item)
//   2. This proc initializes tool_durability datum
//   3. Player presses E key → use_tool() verb fires
//   4. AttemptToolUse() reduces durability
//   5. If tool still works, mining.dm/other systems execute actual action
//   6. If tool broken, action cancelled with error message
//
// HUD Feedback (from PickaxeMiningSystem.dm):
//   - Wear message: "<yellow>Tool is almost broken (X% durability left).</yellow>"
//   - Break message: "<red>Tool shattered!</red>"
//   - No other UI or menus involved

// Expected macros in Interface.dmf or keybindings:
//   E = /use_tool  (swing currently equipped tool)
