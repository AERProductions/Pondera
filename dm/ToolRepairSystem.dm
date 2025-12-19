/// ToolRepairSystem.dm
/// Repair system for broken and damaged tools
/// Features:
/// - Tool repair via repair workstation (anvil-style interface)
/// - Repair recipes require materials (metal, stone, wood based on tool type)
/// - Skill-based repair success rate (higher smithing/crafting = better success)
/// - Irreparability chance: Broken tools have % chance to be irreparable (permanent destruction)
/// - Durability restoration: Repaired tools get partial durability back (not full)

/datum/repair_config
	var
		tool_type = "pickaxe"           // Tool being repaired
		repair_cost = list()             // Materials needed: list("material_name" = amount)
		success_rate_base = 60           // Base % chance to repair successfully
		required_rank = 1                // Minimum rank to attempt repair
		irreparability_chance = 25       // % chance tool is irreparable when broken (per tier)
		durability_restored_percent = 75 // % of max durability restored on successful repair
		repair_xp = 20                   // XP awarded on successful repair
		time_to_repair = 10              // Ticks to perform repair animation

	New(tool_name)
		tool_type = tool_name
		
		// Define repair configs per tool type
		switch(tool_type)
			// PICKAXES
			if("ueik_pickaxe")
				repair_cost = list("stone" = 3)
				success_rate_base = 50
				required_rank = 1
				irreparability_chance = 40    // Stone pickaxes have high irreparability
				durability_restored_percent = 60
				repair_xp = 10
			
			if("iron_pickaxe")
				repair_cost = list("metal" = 2, "stone" = 1)
				success_rate_base = 65
				required_rank = 2
				irreparability_chance = 25
				durability_restored_percent = 75
				repair_xp = 25
			
			if("steel_pickaxe")
				repair_cost = list("metal" = 3)
				success_rate_base = 75
				required_rank = 3
				irreparability_chance = 15
				durability_restored_percent = 85
				repair_xp = 40
			
			// HAMMERS
			if("iron_hammer")
				repair_cost = list("metal" = 2)
				success_rate_base = 70
				required_rank = 2
				irreparability_chance = 20
				durability_restored_percent = 80
				repair_xp = 30
			
			if("steel_hammer")
				repair_cost = list("metal" = 3)
				success_rate_base = 80
				required_rank = 3
				irreparability_chance = 10
				durability_restored_percent = 90
				repair_xp = 50
			
			// AXES
			if("iron_axe")
				repair_cost = list("metal" = 2, "wood" = 1)
				success_rate_base = 65
				required_rank = 2
				irreparability_chance = 25
				durability_restored_percent = 75
				repair_xp = 25
			
			if("steel_axe")
				repair_cost = list("metal" = 3)
				success_rate_base = 75
				required_rank = 3
				irreparability_chance = 15
				durability_restored_percent = 85
				repair_xp = 40
			
			// FISHING POLES
			if("fishing_pole")
				repair_cost = list("wood" = 2, "cord" = 1)
				success_rate_base = 55
				required_rank = 1
				irreparability_chance = 35
				durability_restored_percent = 70
				repair_xp = 15
			
			// CARVING KNIVES
			if("carving_knife")
				repair_cost = list("metal" = 1, "wood" = 1)
				success_rate_base = 60
				required_rank = 2
				irreparability_chance = 30
				durability_restored_percent = 75
				repair_xp = 20
			
			// DEFAULT: Generic tool
			else
				repair_cost = list("metal" = 1)
				success_rate_base = 50
				required_rank = 1
				irreparability_chance = 30
				durability_restored_percent = 70
				repair_xp = 15
	
	proc/CanRepair(mob/players/M, obj/items/equipment/item)
		/// Check if player can attempt repair on this item
		/// Returns TRUE if player has resources, skill, and item is broken
		
		if(!M || !item) return FALSE
		
		// Item must be broken
		if(!item.IsBroken())
			M << "<yellow>[item.name] is not broken.</yellow>"
			return FALSE
		
		// Check player rank
		var/player_rank = M.GetRankLevel(RANK_SMITHING) || 1
		if(player_rank < required_rank)
			M << "<yellow>You need Smithing Rank [required_rank] to repair [item.name].</yellow>"
			return FALSE
		
		// Check player has all materials
		for(var/material_name in repair_cost)
			var/amount_needed = repair_cost[material_name]
			var/amount_have = CountItemsInInventory(M, material_name)
			
			if(amount_have < amount_needed)
				M << "<yellow>You need [amount_needed] [material_name] to repair [item.name]. You have [amount_have].</yellow>"
				return FALSE
		
		return TRUE
	
	proc/AttemptRepair(mob/players/M, obj/items/equipment/item)
		/// Perform repair: consume materials, roll success, restore durability
		/// Irreparability check: broken tools have % chance to be permanently destroyed
		/// Returns: 0 = fail, 1 = success, -1 = irreparable
		
		if(!M || !item) return 0
		
		// Pre-check
		if(!CanRepair(M, item)) return 0
		
		// === IRREPARABILITY CHECK ===
		// Broken tools have a chance to be permanently destroyed
		var/irreparability_roll = rand(0, 100)
		if(irreparability_roll < irreparability_chance)
			// Tool is permanently destroyed
			M << "<red>As you attempt to repair [item.name], it shatters beyond recovery!</red>"
			view(3, M) << "<b>[M.name]</b> failed to repair [item.name] - it is now destroyed."
			
			// Remove item from inventory
			del item
			return -1  // Irreparable
		
		// === CONSUME MATERIALS ===
		var/materials_consumed = 1
		for(var/material_name in repair_cost)
			var/amount_needed = repair_cost[material_name]
			if(!RemoveItemsFromInventory(M, material_name, amount_needed))
				M << "<red>Failed to consume [amount_needed] [material_name].</red>"
				materials_consumed = 0
				break
		
		if(!materials_consumed)
			M << "<red>Repair failed - could not consume materials.</red>"
			return 0
		
		// === SUCCESS ROLL ===
		var/player_rank = M.GetRankLevel(RANK_SMITHING) || 1
		var/rank_bonus = (player_rank - required_rank) * 5  // 5% per rank above required
		var/success_rate = min(95, success_rate_base + rank_bonus)  // Cap at 95%
		
		var/repair_roll = rand(0, 100)
		if(repair_roll > success_rate)
			// Repair failed, materials consumed
			M << "<orange>Your repair attempt fails! The [item.name] remains broken.</orange>"
			view(3, M) << "<b>[M.name]</b> failed to repair [item.name]."
			return 0
		
		// === SUCCESS ===
		var/restored_durability = round(item.max_durability * (durability_restored_percent / 100))
		item.current_durability = restored_durability
		
		M << "<lime>Your [item.name] is repaired! Durability restored to [restored_durability]/[item.max_durability].</lime>"
		view(3, M) << "<b>[M.name]</b> successfully repaired [item.name]!"
		
		// Award repair XP (contributes to Smithing rank)
		if(M.character)
			M.character.UpdateRankExp(RANK_SMITHING, repair_xp)
			M << "<green>+[repair_xp] Smithing XP</green>"
		
		return 1  // Success

// Workstation integration - Global proc for all RepairBench instances
proc/DisplayRepairMenu(mob/players/M)
	/// Menu to select which tool to repair
	/// Called from RepairBench workstation via E-key handler
	
	if(!M || !M.contents) return
	
	var/list/broken_tools = list()
	
	// Find all broken tools in inventory
	for(var/obj/items/equipment/item in M.contents)
		if(item.max_durability > 0 && item.IsBroken())
			broken_tools += item.name
	
	if(broken_tools.len == 0)
		M << "<yellow>You have no broken tools to repair.</yellow>"
		return
	
	broken_tools += "Cancel"
	var/choice = input("Select tool to repair:", "Repair Menu") in broken_tools
	
	if(choice == "Cancel" || !choice)
		M << "You stop repairing."
		return
	
	// Find the selected tool
	var/obj/items/equipment/selected_tool
	for(var/obj/items/equipment/item in M.contents)
		if(item.name == choice)
			selected_tool = item
			break
	
	if(!selected_tool) return
	
	// Get repair config
	var/repair_config_name = lowertext(selected_tool.type)
	repair_config_name = replacetext(repair_config_name, "/obj/items/equipment/tool/", "")
	repair_config_name = replacetext(repair_config_name, "_", "_")
	
	var/datum/repair_config/config = new /datum/repair_config(repair_config_name)
	
	// Attempt repair
	config.AttemptRepair(M, selected_tool)

// ============================================================================
// REPAIR SYSTEM INTEGRATION POINTS
// ============================================================================
// RepairBench workstation defined in ExperimentationWorkstations.dm
// Uses DisplayRepairMenu() proc when player interacts with bench via E-key
// Integration checklist:
// ✅ 1. Repair logic system complete (AttemptRepair, CanRepair procs)
// ✅ 2. Irreparability mechanics implemented (random destruction on failure)
// ✅ 3. Material costs defined per tool type
// ✅ 4. XP awards configured (contributes to Smithing rank)
// TODO: 5. RepairBench workstation in ExperimentationWorkstations.dm
// TODO: 6. Building menu integration (if applicable)
// TODO: 7. Deed system registration (if tool uses deed space)

