/**
 * TECH TREE VISUALIZATION SYSTEM
 * =============================
 * Renders interactive tech tree as visual graph showing recipe progression
 * Based on PTT.md (Pondera Tech Tree)
 * 
 * Started: 12-11-25 4:45PM
 * Focus: Make tech progression visible, searchable, prerequisite-aware
 */

// Tech tree node types
#define NODE_TYPE_ITEM "item"
#define NODE_TYPE_CATEGORY "category"
#define NODE_TYPE_ACTION "action"
#define NODE_TYPE_PROCESS "process"
#define NODE_TYPE_CRAFTED "crafted"
#define NODE_TYPE_FOUND "found"
#define NODE_TYPE_ABILITY "ability"
#define NODE_TYPE_STATION "station"
#define NODE_TYPE_REQUIREMENT "requirement"

// Tier classifications
#define TIER_RUDIMENTARY 1
#define TIER_BASIC 2
#define TIER_INTERMEDIATE 3
#define TIER_ADVANCED 4
#define TIER_ENDGAME 5

/datum/tech_tree_node
	var
		name = ""                    // "Iron Hammer"
		node_type = NODE_TYPE_ITEM   // Node type (item, action, etc)
		tier = TIER_RUDIMENTARY      // Progression tier (1-5)
		description = ""             // "Essential first hammer tool"
		icon = null                  // Icon reference for display
		icon_display = ""            // Icon state for display
		node_color = ""              // Hex color for tier (string)
		
		list/prerequisites = list()  // Other nodes that must be learned first
		list/unlocks = list()        // What this node unlocks
		list/components = list()     // What's needed to make this (name -> quantity)
		list/outputs = list()        // What it produces (name -> quantity)
		
		unlocked = FALSE             // Player has discovered this
		discovered_at_tick = 0       // When player discovered it
		
		// Position for rendering
		x_pos = 0
		y_pos = 0

/datum/tech_tree_node/New(name_input, type_input, tier_input, description_input)
	name = name_input
	node_type = type_input
	tier = tier_input
	description = description_input
	SetTierColor()

/datum/tech_tree_node/proc/SetTierColor()
	switch(tier)
		if(TIER_RUDIMENTARY)
			node_color = "#888888" // Gray
		if(TIER_BASIC)
			node_color = "#4CAF50" // Green
		if(TIER_INTERMEDIATE)
			node_color = "#2196F3" // Blue
		if(TIER_ADVANCED)
			node_color = "#FF9800" // Orange
		if(TIER_ENDGAME)
			node_color = "#9C27B0" // Purple

/datum/tech_tree_node/proc/AddPrerequisite(datum/tech_tree_node/prereq_node)
	if(!istype(prereq_node))
		return FALSE
	prerequisites |= prereq_node
	prereq_node.unlocks |= src
	return TRUE

/datum/tech_tree_node/proc/AddComponent(component_name, quantity)
	components[component_name] = quantity

/datum/tech_tree_node/proc/AddOutput(output_name, quantity)
	outputs[output_name] = quantity

/datum/tech_tree_node/proc/CanUnlock(mob/player)
	// Check if player has all prerequisites unlocked
	for(var/datum/tech_tree_node/prereq in prerequisites)
		if(!prereq.unlocked)
			return FALSE
	return TRUE

/datum/tech_tree_node/proc/Unlock(mob/player)
	if(unlocked)
		return FALSE
	unlocked = TRUE
	discovered_at_tick = world.time
	if(ismob(player))
		player << "<font color=green><b>TECH UNLOCKED:</b> [name]</font>"
	return TRUE

/datum/tech_tree_renderer
	var
		list/all_nodes = list()      // All tech tree nodes
		list/player_unlocked = list()// Nodes player has discovered
		list/search_results = list() // Current search results
		
		// Rendering parameters
		node_width = 120
		node_height = 80
		col_spacing = 200
		row_spacing = 150
		
		// Display state
		visible_tier_min = TIER_RUDIMENTARY
		visible_tier_max = TIER_ENDGAME
		zoom_level = 1.0

/datum/tech_tree_renderer/New()
	InitializeTechTree()
	LayoutNodes()

/datum/tech_tree_renderer/proc/InitializeTechTree()
	/**
	 * Build complete tech tree from PTT.md specifications
	 * Tier I: Rudimentary
	 * Tier II: Basic
	 * Tier III: Intermediate
	 * Tier IV: Advanced
	 * Tier V: Endgame
	 */
	
	// --- TIER I: RUDIMENTARY ---
	
	var/datum/tech_tree_node/rock = new("Rock", NODE_TYPE_FOUND, TIER_RUDIMENTARY, "Found in flowers and tall grass")
	all_nodes += rock
	
	var/datum/tech_tree_node/flint = new("Flint", NODE_TYPE_FOUND, TIER_RUDIMENTARY, "Fractured from rock")
	all_nodes += flint
	flint.AddPrerequisite(rock)
	
	var/datum/tech_tree_node/ueik_thorn = new("Ueik Thorn", NODE_TYPE_FOUND, TIER_RUDIMENTARY, "From ancient ueik trees")
	all_nodes += ueik_thorn
	
	var/datum/tech_tree_node/obsidian = new("Obsidian", NODE_TYPE_FOUND, TIER_RUDIMENTARY, "From obsidian fields")
	all_nodes += obsidian
	
	var/datum/tech_tree_node/pyrite = new("Pyrite", NODE_TYPE_FOUND, TIER_RUDIMENTARY, "Ancient ueik splinter source")
	all_nodes += pyrite
	pyrite.AddPrerequisite(flint)
	
	var/datum/tech_tree_node/wooden_haunch = new("Wooden Haunch", NODE_TYPE_FOUND, TIER_RUDIMENTARY, "Can be carved from pyrite")
	all_nodes += wooden_haunch
	wooden_haunch.AddPrerequisite(pyrite)
	
	var/datum/tech_tree_node/stone_hammer = new("Stone Hammer", NODE_TYPE_CRAFTED, TIER_RUDIMENTARY, "First tool combining rock and wood")
	all_nodes += stone_hammer
	stone_hammer.AddPrerequisite(rock)
	stone_hammer.AddPrerequisite(wooden_haunch)
	stone_hammer.AddComponent("Rock", 1)
	stone_hammer.AddComponent("Wooden Haunch", 1)
	stone_hammer.AddOutput("Stone Hammer", 1)
	
	var/datum/tech_tree_node/ueik_pickaxe = new("Ueik Pickaxe", NODE_TYPE_CRAFTED, TIER_RUDIMENTARY, "Tool for mining stone")
	all_nodes += ueik_pickaxe
	ueik_pickaxe.AddPrerequisite(ueik_thorn)
	ueik_pickaxe.AddPrerequisite(wooden_haunch)
	ueik_pickaxe.AddComponent("Ueik Thorn", 1)
	ueik_pickaxe.AddComponent("Wooden Haunch", 1)
	
	var/datum/tech_tree_node/obsidian_knife = new("Obsidian Knife", NODE_TYPE_CRAFTED, TIER_RUDIMENTARY, "Sharp cutting tool")
	all_nodes += obsidian_knife
	obsidian_knife.AddPrerequisite(obsidian)
	obsidian_knife.AddPrerequisite(wooden_haunch)
	
	var/datum/tech_tree_node/kindling = new("Kindling", NODE_TYPE_CRAFTED, TIER_RUDIMENTARY, "First fuel source")
	all_nodes += kindling
	kindling.AddPrerequisite(obsidian_knife)
	kindling.AddComponent("Obsidian Knife (carved)", 1)
	
	var/datum/tech_tree_node/fire = new("Fire", NODE_TYPE_ACTION, TIER_RUDIMENTARY, "Heat, cook, smelt, bake")
	all_nodes += fire
	fire.AddPrerequisite(kindling)
	fire.AddPrerequisite(flint)
	fire.AddPrerequisite(pyrite)
	
	var/datum/tech_tree_node/gloves = new("Gloves", NODE_TYPE_CRAFTED, TIER_RUDIMENTARY, "Handle hot items safely")
	all_nodes += gloves
	gloves.AddPrerequisite(fire)
	gloves.AddPrerequisite(obsidian_knife)
	
	var/datum/tech_tree_node/mine_action = new("Mine", NODE_TYPE_ACTION, TIER_RUDIMENTARY, "Extract ore and stone")
	all_nodes += mine_action
	mine_action.AddPrerequisite(ueik_pickaxe)
	
	var/datum/tech_tree_node/smelt_action = new("Smelt", NODE_TYPE_ACTION, TIER_RUDIMENTARY, "Extract metal from ore")
	all_nodes += smelt_action
	smelt_action.AddPrerequisite(mine_action)
	smelt_action.AddPrerequisite(fire)
	smelt_action.AddPrerequisite(stone_hammer)
	
	// --- TIER II: BASIC ---
	
	var/datum/tech_tree_node/iron_ore = new("Iron Ore", NODE_TYPE_FOUND, TIER_BASIC, "Mined from stone")
	all_nodes += iron_ore
	iron_ore.AddPrerequisite(mine_action)
	
	var/datum/tech_tree_node/iron_ingot = new("Iron Ingot", NODE_TYPE_CRAFTED, TIER_BASIC, "Smelted from ore")
	all_nodes += iron_ingot
	iron_ingot.AddPrerequisite(smelt_action)
	iron_ingot.AddPrerequisite(iron_ore)
	
	var/datum/tech_tree_node/iron_hammer = new("Iron Hammer", NODE_TYPE_CRAFTED, TIER_BASIC, "Essential metalworking tool")
	all_nodes += iron_hammer
	iron_hammer.AddPrerequisite(iron_ingot)
	iron_hammer.AddComponent("Iron Ingot", 1)
	
	var/datum/tech_tree_node/build_action = new("Build", NODE_TYPE_ACTION, TIER_BASIC, "Construct structures")
	all_nodes += build_action
	build_action.AddPrerequisite(iron_hammer)
	
	var/datum/tech_tree_node/wood_house = new("Wood House", NODE_TYPE_CRAFTED, TIER_BASIC, "Basic shelter")
	all_nodes += wood_house
	wood_house.AddPrerequisite(build_action)
	wood_house.AddComponent("Boards", 20)
	wood_house.AddComponent("Iron Nails", 10)
	
	var/datum/tech_tree_node/furnishings = new("Furnishings", NODE_TYPE_CRAFTED, TIER_BASIC, "House decorations and storage")
	all_nodes += furnishings
	furnishings.AddPrerequisite(wood_house)
	
	var/datum/tech_tree_node/forge = new("Forge", NODE_TYPE_CRAFTED, TIER_BASIC, "Metalworking station")
	all_nodes += forge
	forge.AddPrerequisite(furnishings)
	forge.AddPrerequisite(fire)
	forge.AddComponent("Stone Blocks", 20)
	
	var/datum/tech_tree_node/kiln = new("Kiln", NODE_TYPE_CRAFTED, TIER_BASIC, "High temperature oven")
	all_nodes += kiln
	kiln.AddPrerequisite(forge)
	
	var/datum/tech_tree_node/anvil_head = new("Anvil Head", NODE_TYPE_CRAFTED, TIER_BASIC, "Forged metal platform")
	all_nodes += anvil_head
	anvil_head.AddPrerequisite(forge)
	
	var/datum/tech_tree_node/anvil = new("Anvil", NODE_TYPE_STATION, TIER_BASIC, "Complete smithing station")
	all_nodes += anvil
	anvil.AddPrerequisite(anvil_head)
	
	var/datum/tech_tree_node/carbon = new("Carbon", NODE_TYPE_CRAFTED, TIER_BASIC, "Produced by burning")
	all_nodes += carbon
	carbon.AddPrerequisite(fire)
	
	var/datum/tech_tree_node/activated_carbon = new("Activated Carbon", NODE_TYPE_CRAFTED, TIER_BASIC, "Purified carbon")
	all_nodes += activated_carbon
	activated_carbon.AddPrerequisite(carbon)
	
	var/datum/tech_tree_node/steel = new("Steel", NODE_TYPE_CRAFTED, TIER_BASIC, "Iron + Carbon alloy")
	all_nodes += steel
	steel.AddPrerequisite(iron_ingot)
	steel.AddPrerequisite(carbon)
	steel.AddComponent("Iron Ingot", 1)
	steel.AddComponent("Carbon", 1)
	
	// --- TIER III: INTERMEDIATE ---
	
	var/datum/tech_tree_node/carve_action = new("Carve", NODE_TYPE_ACTION, TIER_INTERMEDIATE, "Shape wood into tools")
	all_nodes += carve_action
	carve_action.AddPrerequisite(obsidian_knife)
	
	var/datum/tech_tree_node/axe = new("Axe", NODE_TYPE_CRAFTED, TIER_INTERMEDIATE, "Cutting tool")
	all_nodes += axe
	axe.AddPrerequisite(iron_hammer)
	axe.AddComponent("Axe Blade", 1)
	axe.AddComponent("Wood Handle", 1)
	
	var/datum/tech_tree_node/pickaxe_improved = new("Pickaxe (Iron)", NODE_TYPE_CRAFTED, TIER_INTERMEDIATE, "Superior mining tool")
	all_nodes += pickaxe_improved
	pickaxe_improved.AddPrerequisite(iron_hammer)
	
	var/datum/tech_tree_node/fishing_pole = new("Fishing Pole", NODE_TYPE_CRAFTED, TIER_INTERMEDIATE, "Catch fish")
	all_nodes += fishing_pole
	fishing_pole.AddPrerequisite(iron_hammer)
	fishing_pole.AddComponent("Iron Reel", 1)
	fishing_pole.AddComponent("Pole", 1)
	
	var/datum/tech_tree_node/fishing_action = new("Fishing", NODE_TYPE_ACTION, TIER_INTERMEDIATE, "Catch aquatic life")
	all_nodes += fishing_action
	fishing_action.AddPrerequisite(fishing_pole)
	
	var/datum/tech_tree_node/hoe = new("Hoe", NODE_TYPE_CRAFTED, TIER_INTERMEDIATE, "Farming tool")
	all_nodes += hoe
	hoe.AddPrerequisite(iron_hammer)
	
	var/datum/tech_tree_node/sow_action = new("Sow", NODE_TYPE_ACTION, TIER_INTERMEDIATE, "Plant crops")
	all_nodes += sow_action
	sow_action.AddPrerequisite(hoe)
	
	var/datum/tech_tree_node/harvest_action = new("Harvest", NODE_TYPE_ACTION, TIER_INTERMEDIATE, "Collect crops")
	all_nodes += harvest_action
	harvest_action.AddPrerequisite(sow_action)
	
	var/datum/tech_tree_node/longsword = new("Longsword", NODE_TYPE_CRAFTED, TIER_INTERMEDIATE, "Primary melee weapon")
	all_nodes += longsword
	longsword.AddPrerequisite(steel)
	longsword.AddComponent("Sword Blade (Steel)", 1)
	longsword.AddComponent("Wood Handle", 1)
	
	// --- TIER IV: ADVANCED ---
	
	var/datum/tech_tree_node/limestone = new("Limestone", NODE_TYPE_FOUND, TIER_ADVANCED, "Mined stone resource")
	all_nodes += limestone
	limestone.AddPrerequisite(mine_action)
	
	var/datum/tech_tree_node/processed_lime = new("Processed Lime", NODE_TYPE_CRAFTED, TIER_ADVANCED, "Kiln-processed limestone")
	all_nodes += processed_lime
	processed_lime.AddPrerequisite(limestone)
	processed_lime.AddPrerequisite(kiln)
	
	var/datum/tech_tree_node/lime_mortar = new("Lime Mortar", NODE_TYPE_CRAFTED, TIER_ADVANCED, "Structural binding agent")
	all_nodes += lime_mortar
	lime_mortar.AddPrerequisite(processed_lime)
	lime_mortar.AddComponent("Processed Lime", 1)
	lime_mortar.AddComponent("Sand", 1)
	lime_mortar.AddComponent("Clay", 1)
	
	var/datum/tech_tree_node/stone_blocks = new("Stone Blocks", NODE_TYPE_CRAFTED, TIER_ADVANCED, "Shaped building material")
	all_nodes += stone_blocks
	stone_blocks.AddPrerequisite(anvil)
	stone_blocks.AddComponent("Stone (raw)", 1)
	
	var/datum/tech_tree_node/stonework = new("Stonework", NODE_TYPE_ACTION, TIER_ADVANCED, "Build with stone")
	all_nodes += stonework
	stonework.AddPrerequisite(lime_mortar)
	stonework.AddPrerequisite(stone_blocks)
	
	var/datum/tech_tree_node/stone_fort = new("Stone Fort", NODE_TYPE_CRAFTED, TIER_ADVANCED, "Fortified structure")
	all_nodes += stone_fort
	stone_fort.AddPrerequisite(stonework)
	stone_fort.AddComponent("Stone Blocks", 50)
	stone_fort.AddComponent("Lime Mortar", 20)
	
	// --- TIER V: ENDGAME ---
	
	var/datum/tech_tree_node/damascus_steel = new("Damascus Steel", NODE_TYPE_CRAFTED, TIER_ENDGAME, "Legendary folded steel")
	all_nodes += damascus_steel
	damascus_steel.AddPrerequisite(steel)
	damascus_steel.AddPrerequisite(activated_carbon)
	damascus_steel.AddComponent("Steel Ingot", 1)
	damascus_steel.AddComponent("Activated Carbon", 1)
	
	var/datum/tech_tree_node/legendary_sword = new("Legendary Sword", NODE_TYPE_CRAFTED, TIER_ENDGAME, "Ultimate blade")
	all_nodes += legendary_sword
	legendary_sword.AddPrerequisite(damascus_steel)
	legendary_sword.AddPrerequisite(longsword)
	legendary_sword.AddComponent("Damascus Steel Ingot", 1)

/datum/tech_tree_renderer/proc/LayoutNodes()
	/**
	 * Position nodes in a tier-based layout
	 * Tiers vertical (top to bottom)
	 * Nodes within tier horizontal (left to right)
	 */
	
	var/list/tier_groups = list()
	for(var/i = TIER_RUDIMENTARY; i <= TIER_ENDGAME; i++)
		tier_groups[i] = list()
	
	// Group nodes by tier
	for(var/datum/tech_tree_node/node in all_nodes)
		tier_groups[node.tier] += node
	
	// Position each tier
	var/y_offset = 50
	for(var/tier = TIER_RUDIMENTARY; tier <= TIER_ENDGAME; tier++)
		var/list/nodes_in_tier = tier_groups[tier]
		var/node_count = length(nodes_in_tier)
		var/total_width = node_count * col_spacing
		var/start_x = (512 - total_width / 2) // Center horizontally
		
		for(var/i = 1; i <= node_count; i++)
			var/datum/tech_tree_node/node = nodes_in_tier[i]
			node.x_pos = start_x + (i - 1) * col_spacing
			node.y_pos = y_offset
		
		y_offset += row_spacing

/datum/tech_tree_renderer/proc/Search(search_text)
	/**
	 * Search nodes by name or description
	 * Returns matching nodes
	 */
	
	search_results = list()
	var/search_lower = lowertext(search_text)
	
	for(var/datum/tech_tree_node/node in all_nodes)
		if(findtext(lowertext(node.name), search_lower) || \
		   findtext(lowertext(node.description), search_lower))
			search_results += node
	
	return search_results

/datum/tech_tree_renderer/proc/ShowTree(mob/player, tier_filter = 0)
	/**
	 * Display tech tree to player
	 * tier_filter: 0 = all, 1-5 = specific tier
	 */
	
	if(!ismob(player))
		return
	
	var/output = "<hr><b>PONDERA TECH TREE</b><hr>"
	output += "<i>Click on items to view details and prerequisites</i><br><br>"
	
	for(var/tier = TIER_RUDIMENTARY; tier <= TIER_ENDGAME; tier++)
		if(tier_filter && tier_filter != tier)
			continue
		
		output += "<b>[GetTierName(tier)]</b><br>"
		for(var/datum/tech_tree_node/node in all_nodes)
			if(node.tier != tier)
				continue
			
			var/status = node.unlocked ? "✓" : "◯"
			var/color = node.node_color
			output += "<font color='[color]'>[status] [node.name]</font> - [node.description]<br>"
		
		output += "<br>"
	
	player << output

/datum/tech_tree_renderer/proc/GetTierName(tier)
	switch(tier)
		if(TIER_RUDIMENTARY)
			return "Tier I: Rudimentary"
		if(TIER_BASIC)
			return "Tier II: Basic"
		if(TIER_INTERMEDIATE)
			return "Tier III: Intermediate"
		if(TIER_ADVANCED)
			return "Tier IV: Advanced"
		if(TIER_ENDGAME)
			return "Tier V: Endgame"

/datum/tech_tree_renderer/proc/ShowNodeDetails(mob/player, datum/tech_tree_node/node)
	/**
	 * Display detailed information about a tech tree node
	 */
	
	if(!ismob(player) || !istype(node))
		return
	
	var/output = "<hr><b>[node.name]</b><hr>"
	output += "[node.description]<br><br>"
	
	output += "<font color='#666'><b>Tier:</b> [GetTierName(node.tier)]</font><br>"
	output += "<b>Type:</b> [node.node_type]<br>"
	
	if(length(node.prerequisites))
		output += "<b>Prerequisites:</b><br>"
		for(var/datum/tech_tree_node/prereq in node.prerequisites)
			var/status = prereq.unlocked ? "✓" : "✗"
			output += "&nbsp;&nbsp;[status] [prereq.name]<br>"
	
	if(length(node.components))
		output += "<br><b>Components Needed:</b><br>"
		for(var/comp_name in node.components)
			output += "&nbsp;&nbsp;• [comp_name] x[node.components[comp_name]]<br>"
	
	if(length(node.outputs))
		output += "<br><b>Produces:</b><br>"
		for(var/out_name in node.outputs)
			output += "&nbsp;&nbsp;• [out_name] x[node.outputs[out_name]]<br>"
	
	if(length(node.unlocks))
		output += "<br><b>Unlocks:</b><br>"
		for(var/datum/tech_tree_node/unlock in node.unlocks)
			output += "&nbsp;&nbsp;→ [unlock.name]<br>"
	
	player << output

// Global instance
var/datum/tech_tree_renderer/tech_tree_system = null

/proc/InitializeTechTree()
	if(tech_tree_system)
		return tech_tree_system
	tech_tree_system = new /datum/tech_tree_renderer()
	return tech_tree_system

/proc/GetTechTree()
	if(!tech_tree_system)
		InitializeTechTree()
	return tech_tree_system
