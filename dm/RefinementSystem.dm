// RefinementSystem.dm
// Centralized refinement system for forge/anvil crafted items
// Replaces scattered needsfiled/needssharpening/needspolishing flags with unified state machine
// Supports File, Sharpen, and Polish stages with success probability and progression

// Refinement stage constants
#define REFINE_STAGE_UNREFINED 0       // Just smithed, needs filing
#define REFINE_STAGE_FILED 1           // Filed, ready for sharpening
#define REFINE_STAGE_SHARPENED 2       // Sharpened, ready for polishing
#define REFINE_STAGE_POLISHED 3        // Fully refined, complete

// Refinement tool types
#define REFINE_TOOL_FILE 1
#define REFINE_TOOL_WHETSTONE 2
#define REFINE_TOOL_POLISH_CLOTH 3

// Craftable item base class - all smithed items inherit from this
obj/items/crafting/refined
	var
		refine_stage = REFINE_STAGE_UNREFINED      // Current refinement progress
		refine_durability = 100                    // Durability of the item (affects success chance)
		refine_quality = 0                         // Quality score (0-100, affects final stats)
		tool_required = null                       // Which refinement stage next needs

	// Get next refinement tool needed
	proc/GetNextToolNeeded()
		switch(refine_stage)
			if(REFINE_STAGE_UNREFINED)
				return REFINE_TOOL_FILE
			if(REFINE_STAGE_FILED)
				return REFINE_TOOL_WHETSTONE
			if(REFINE_STAGE_SHARPENED)
				return REFINE_TOOL_POLISH_CLOTH
		return null

	// Get tool name for prompts
	proc/GetToolName(tool_type)
		switch(tool_type)
			if(REFINE_TOOL_FILE)
				return "File"
			if(REFINE_TOOL_WHETSTONE)
				return "Whetstone"
			if(REFINE_TOOL_POLISH_CLOTH)
				return "Polish Cloth"
		return "Unknown"

	// Get stage name for prompts
	proc/GetStageNameForDisplay(stage)
		switch(stage)
			if(REFINE_STAGE_UNREFINED)
				return "unrefined - needs filing"
			if(REFINE_STAGE_FILED)
				return "filed - needs sharpening"
			if(REFINE_STAGE_SHARPENED)
				return "sharpened - needs polishing"
			if(REFINE_STAGE_POLISHED)
				return "completed"
		return "unknown"

	// Check if can be refined
	proc/CanRefine()
		if(refine_stage >= REFINE_STAGE_POLISHED)
			return FALSE
		return TRUE

	// Get success probability based on quality and durability
	proc/GetSuccessProbability()
		var/success_chance = 50  // Base 50% success
		success_chance += round(refine_quality / 2)  // Quality improves odds (0-50 bonus)
		success_chance -= round((100 - refine_durability) / 5)  // Wear decreases odds (0-20 penalty)
		return max(20, min(90, success_chance))  // Clamp between 20-90%

// Refinement tool base class
obj/items/tools/refinement
	var
		refine_tool_type = null
		refine_success_text = "The item has been refined!"
		refine_partial_text = "The item could use more refinement."

	verb/Description()
		set category = null
		set popup_menu = 1
		set src in usr
		usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>Tool for item refinement."

	// Find all items needing this refinement stage
	proc/FindItemsNeedingRefinement(mob/players/M, tool_type)
		var/list/items = list()
		for(var/obj/items/crafting/refined/item in M.contents)
			if(item.refine_stage < REFINE_STAGE_POLISHED)
				var/next_tool = item.GetNextToolNeeded()
				if(next_tool == tool_type)
					items += item
		return items

	// Attempt refinement on an item
	proc/AttemptRefinement(mob/players/M, obj/items/crafting/refined/item)
		if(!item || !item.CanRefine())
			return FALSE

		var/success_chance = item.GetSuccessProbability()
		var/success = prob(success_chance)

		// Display action message
		var/stage_name = item.GetStageNameForDisplay(item.refine_stage)
		var/tool_name = item.GetToolName(refine_tool_type)
		M << "You apply the [tool_name] to the [item.name] ([stage_name])."

		// Play refinement sound effect
		PlayRefinementSound(refine_tool_type, M.loc)

		sleep(3)  // Refinement takes time

		if(success)
			// Successful refinement
			item.refine_stage += 1
			item.refine_quality = min(100, item.refine_quality + rand(5, 15))
			M << "[item.name] has been successfully refined!"
			
			// Call stage-specific handler if defined
			if(item.refine_stage == REFINE_STAGE_FILED)
				call(item, "OnFiled")()
			else if(item.refine_stage == REFINE_STAGE_SHARPENED)
				call(item, "OnSharpened")()
			else if(item.refine_stage == REFINE_STAGE_POLISHED)
				call(item, "OnPolished")()
			
			return TRUE
		else
			// Partial progress - quality improves but stage doesn't advance
			item.refine_quality = min(100, item.refine_quality + rand(2, 5))
			item.refine_durability = max(20, item.refine_durability - rand(3, 8))
			M << "[item.name] could use more refinement."
			return FALSE

	proc/PlayRefinementSound(tool_type, location)
		/**
		 * Play appropriate refinement sound based on tool type
		 * Uses the _SoundEngine for positional audio (if sound files are available)
		 * TODO: Add actual sound files as they become available
		 */
		// Placeholder - sounds can be added when audio assets are ready
		// switch(tool_type)
		// 	if(REFINE_TOOL_FILE)
		// 		_SoundEngine('snd/refinement_file.ogg', location, range=3, volume=75)
		// 	if(REFINE_TOOL_WHETSTONE)
		// 		_SoundEngine('snd/refinement_whetstone.ogg', location, range=3, volume=75)
		// 	if(REFINE_TOOL_POLISH_CLOTH)
		// 		_SoundEngine('snd/refinement_polish.ogg', location, range=3, volume=60)

// File tool
obj/items/tools/refinement/File
	name = "File"
	icon = 'dmi/tower.dmi'
	icon_state = "file1"
	refine_tool_type = REFINE_TOOL_FILE
	refine_success_text = "The surface is now smooth and ready for sharpening!"
	refine_partial_text = "The surface is becoming smoother, but needs more filing."

	verb/UseFile()
		set category = null
		set popup_menu = 1
		set src in usr
		
		var/mob/players/M = usr
		if(!M) return
		
		var/list/items_to_refine = FindItemsNeedingRefinement(M, REFINE_TOOL_FILE)
		
		if(!items_to_refine.len)
			M << "You have no items that need filing."
			return
			return
		
		// Auto-target first item needing filing
		var/obj/items/crafting/refined/item = items_to_refine[1]
		AttemptRefinement(M, item)

// Whetstone tool
obj/items/tools/refinement/Whetstone
	name = "Whetstone"
	icon = 'dmi/tower.dmi'
	icon_state = "whetstone1"
	refine_tool_type = REFINE_TOOL_WHETSTONE
	refine_success_text = "The edge is now razor sharp!"
	refine_partial_text = "The edge is becoming sharper, but needs more honing."

	verb/UseWhetstone()
		set category = null
		set popup_menu = 1
		set src in usr
		
		var/mob/players/M = usr
		if(!M) return
		
		var/list/items_to_refine = FindItemsNeedingRefinement(M, REFINE_TOOL_WHETSTONE)
		
		if(!items_to_refine.len)
			M << "You have no items that need sharpening."
			return
		
		var/obj/items/crafting/refined/item = items_to_refine[1]
		AttemptRefinement(M, item)

// Polish cloth tool
obj/items/tools/refinement/PolishCloth
	name = "Polish Cloth"
	icon = 'dmi/tower.dmi'
	icon_state = "cloth1"
	refine_tool_type = REFINE_TOOL_POLISH_CLOTH
	refine_success_text = "The finish now gleams with perfection!"
	refine_partial_text = "The finish is becoming more lustrous, but needs more polishing."

	verb/UsePolishCloth()
		set category = null
		set popup_menu = 1
		set src in usr
		
		var/mob/players/M = usr
		if(!M) return
		
		var/list/items_to_refine = FindItemsNeedingRefinement(M, REFINE_TOOL_POLISH_CLOTH)
		
		if(!items_to_refine.len)
			M << "You have no items that need polishing."
			return
		
		var/obj/items/crafting/refined/item = items_to_refine[1]
		AttemptRefinement(M, item)

// Example crafted item (weapon)
obj/items/crafting/refined/weapon
	name = "Smithed Blade"
	icon = 'dmi/tower.dmi'
	icon_state = "blade1"
	refine_stage = REFINE_STAGE_UNREFINED

	// Callbacks for refinement completion
	proc/OnFiled()
		src.name = "Filed Blade"

	proc/OnSharpened()
		src.name = "Sharp Blade"

	proc/OnPolished()
		src.name = "Perfected Blade"
		// Could apply stat bonuses here

// Example crafted item (tool)
obj/items/crafting/refined/tool
	name = "Smithed Tool Head"
	icon = 'dmi/tower.dmi'
	icon_state = "tool1"
	refine_stage = REFINE_STAGE_UNREFINED

	proc/OnFiled()
		src.name = "Filed Tool Head"

	proc/OnSharpened()
		src.name = "Sharp Tool Head"

	proc/OnPolished()
		src.name = "Finished Tool Head"

// Mob refinement interface
mob/players
	// Quick access to check item refinement status
	proc/CheckRefinementStatus()
		var/output = "<b>Refinement Status:</b><br>"
		var/has_items = FALSE
		
		for(var/obj/items/crafting/refined/item in contents)
			if(!item.CanRefine()) continue
			has_items = TRUE
			var/progress = item.refine_quality
			var/next_tool = item.GetToolName(item.GetNextToolNeeded())
			output += "[item.name]: [item.GetStageNameForDisplay(item.refine_stage)] (Quality: [progress]%) - Needs [next_tool]<br>"
		
		if(!has_items)
			output += "No items needing refinement."
		
		usr << output

	// Get refinement summary
	proc/GetRefinementSummary()
		var/list/summary = list()
		summary["unrefined"] = 0
		summary["filed"] = 0
		summary["sharpened"] = 0
		summary["polished"] = 0
		
		for(var/obj/items/crafting/refined/item in contents)
			switch(item.refine_stage)
				if(REFINE_STAGE_UNREFINED)
					summary["unrefined"] += 1
				if(REFINE_STAGE_FILED)
					summary["filed"] += 1
				if(REFINE_STAGE_SHARPENED)
					summary["sharpened"] += 1
				if(REFINE_STAGE_POLISHED)
					summary["polished"] += 1
		
		return summary
