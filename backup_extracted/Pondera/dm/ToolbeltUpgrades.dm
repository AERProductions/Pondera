/*
 * TOOLBELT UPGRADE SYSTEM
 * 
 * Crafted toolbelts that unlock additional hotbar slots:
 * 
 * - Base Toolbelt: 2 slots (default, no item needed)
 * - Leather Toolbelt: 4 slots (crafted from leather + thread)
 * - Reinforced Toolbelt: 6 slots (crafted from iron + leather + thread)
 * - Expert Toolbelt: 8 slots (crafted from steel + leather + gem)
 * - Master Toolbelt: 9 slots (crafted from mithril + leather + perfect gem)
 * 
 * When a player has a toolbelt item in inventory, datum/toolbelt.max_slots
 * expands to match that tier. Multiple toolbelts grant the highest tier.
 * 
 * CRAFTING RECIPES:
 * All toolbelts are crafted via smithing station or hand-crafting.
 */

// ==================== TOOLBELT ITEMS ====================

/obj/items/equipment
	var/is_toolbelt = 0                    // Boolean: is this a toolbelt upgrade?
	var/toolbelt_tier = 0                  // Tier number (1-4, higher = more slots)
	var/slots_granted = 0                  // How many slots this toolbelt grants

// ==================== TOOLBELT VARIANTS ====================

/obj/items/equipment/toolbelt_leather
	name = "Leather Toolbelt"
	desc = "A sturdy leather toolbelt. Grants 4 hotbar slots."
	
	New()
		..()
		is_toolbelt = 1
		toolbelt_tier = 1
		slots_granted = 4

/obj/items/equipment/toolbelt_reinforced
	name = "Reinforced Toolbelt"
	desc = "A reinforced leather toolbelt with iron bands. Grants 6 hotbar slots."
	
	New()
		..()
		is_toolbelt = 1
		toolbelt_tier = 2
		slots_granted = 6

/obj/items/equipment/toolbelt_expert
	name = "Expert Toolbelt"
	desc = "A finely crafted toolbelt with steel reinforcements. Grants 8 hotbar slots."
	
	New()
		..()
		is_toolbelt = 1
		toolbelt_tier = 3
		slots_granted = 8

/obj/items/equipment/toolbelt_master
	name = "Master Toolbelt"
	desc = "An exquisite toolbelt crafted from the finest materials. Grants 9 hotbar slots."
	
	New()
		..()
		is_toolbelt = 1
		toolbelt_tier = 4
		slots_granted = 9

// ==================== CRAFTING RECIPES ====================

proc/InitializeToolbeltRecipes()
	/**
	 * InitializeToolbeltRecipes() -> null
	 * 
	 * Adds toolbelt crafting recipes to global recipe registry.
	 * Call during initialization phase.
	 */
	
	if(!RECIPES)
		RECIPES = list()
	
	// Leather Toolbelt
	RECIPES["leather toolbelt"] = list(
		"name" = "Leather Toolbelt",
		"output_type" = /obj/items/equipment/toolbelt_leather,
		"ingredients" = list("leather" = 5, "thread" = 3),
		"skill_required" = "crafting",
		"skill_level_required" = 1,
		"quality_modifier" = 0.1,
		"description" = "A sturdy leather toolbelt for organizing your tools. Grants 4 hotbar slots."
	)
	
	// Reinforced Toolbelt
	RECIPES["reinforced toolbelt"] = list(
		"name" = "Reinforced Toolbelt",
		"output_type" = /obj/items/equipment/toolbelt_reinforced,
		"ingredients" = list("leather" = 8, "iron bar" = 3, "thread" = 5),
		"skill_required" = "smithing",
		"skill_level_required" = 2,
		"quality_modifier" = 0.15,
		"description" = "A leather toolbelt reinforced with iron bands. Grants 6 hotbar slots."
	)
	
	// Expert Toolbelt
	RECIPES["expert toolbelt"] = list(
		"name" = "Expert Toolbelt",
		"output_type" = /obj/items/equipment/toolbelt_expert,
		"ingredients" = list("leather" = 10, "steel bar" = 5, "gem" = 1, "thread" = 8),
		"skill_required" = "smithing",
		"skill_level_required" = 3,
		"quality_modifier" = 0.2,
		"description" = "A finely crafted toolbelt with steel reinforcements. Grants 8 hotbar slots."
	)
	
	// Master Toolbelt
	RECIPES["master toolbelt"] = list(
		"name" = "Master Toolbelt",
		"output_type" = /obj/items/equipment/toolbelt_master,
		"ingredients" = list("leather" = 15, "mithril bar" = 8, "perfect gem" = 2, "thread" = 12),
		"skill_required" = "smithing",
		"skill_level_required" = 5,
		"quality_modifier" = 0.25,
		"description" = "An exquisite toolbelt crafted from the finest materials. Grants 9 hotbar slots."
	)

// ==================== HOTBAR SLOT EXPANSION ====================

/datum/toolbelt
	proc/CheckForUpgradedToolbelts()
		/**
		 * CheckForUpgradedToolbelts() -> null
		 * 
		 * Scans player inventory for upgraded toolbelts.
		 * Each quality tier grants +2 slots (max 9 total).
		 * 
		 * Toolbelt tiers:
		 * - Base (2 slots): Default, no item needed
		 * - Leather (4 slots): obj/items/equipment/toolbelt_leather
		 * - Reinforced (6 slots): obj/items/equipment/toolbelt_reinforced
		 * - Expert (8 slots): obj/items/equipment/toolbelt_expert
		 * - Master (9 slots): obj/items/equipment/toolbelt_master
		 * 
		 * Note: This function is called in datum/toolbelt/New()
		 * and can be called again to refresh slots after acquiring new toolbelt.
		 */
		
		if(!owner)
			return
		
		var/upgraded_count = 0
		
		// Check inventory for upgraded toolbelt items
		for(var/obj/O in owner.contents)
			if(istype(O, /obj/items/equipment/toolbelt_leather))
				upgraded_count = max(upgraded_count, 1)
			if(istype(O, /obj/items/equipment/toolbelt_reinforced))
				upgraded_count = max(upgraded_count, 2)
			if(istype(O, /obj/items/equipment/toolbelt_expert))
				upgraded_count = max(upgraded_count, 3)
			if(istype(O, /obj/items/equipment/toolbelt_master))
				upgraded_count = max(upgraded_count, 4)
		
		// Expand slots based on highest tier found
		switch(upgraded_count)
			if(0)
				max_slots = 2
			if(1)
				max_slots = 4
			if(2)
				max_slots = 6
			if(3)
				max_slots = 8
			if(4)
				max_slots = 9
		
		// Expand slot list to match max_slots
		while(slots.len < max_slots)
			slots += null

// ==================== ITEM PICKUP INTEGRATION ====================

/mob/players
	proc/OnItemPickup(obj/item)
		/**
		 * OnItemPickup(item) -> null
		 * 
		 * Called when player picks up an item.
		 * Checks if it's a toolbelt and updates hotbar slots if needed.
		 */
		
		if(!toolbelt)
			return
		
		// Check if newly picked up item is a toolbelt
		if(istype(item, /obj/items/equipment))
			var/obj/items/equipment/E = item
			if(E.is_toolbelt)
				var/old_max_slots = toolbelt.max_slots
				toolbelt.CheckForUpgradedToolbelts()
				var/new_max_slots = toolbelt.max_slots
				
				// Notify player and HUD of upgrade
				if(new_max_slots > old_max_slots)
					src << "<font color=yellow>[E.name] acquired! Hotbar expanded to [new_max_slots] slots.</font>"
					NotifyToolbeltUpgradeUnlocked(src, new_max_slots)
		
		return

// ==================== ADMIN/DEBUG COMMANDS ====================

/datum/toolbelt
	proc/GetUpgradeStatus()
		/**
		 * GetUpgradeStatus() -> text
		 * 
		 * Returns formatted string showing current toolbelt tier.
		 */
		
		var/tier_name = "Base"
		switch(max_slots)
			if(2)
				tier_name = "Base (default)"
			if(4)
				tier_name = "Leather"
			if(6)
				tier_name = "Reinforced"
			if(8)
				tier_name = "Expert"
			if(9)
				tier_name = "Master"
		
		return "<font color=cyan>Toolbelt Tier: [tier_name] ([max_slots] slots)</font>"

	proc/ShowUpgradeStatus()
		/**
		 * ShowUpgradeStatus() -> null
		 * 
		 * Prints upgrade status to player.
		 */
		
		if(owner)
			owner << GetUpgradeStatus()
			owner << GetHotbarStatus()
