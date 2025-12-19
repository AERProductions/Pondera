// SandboxRecipeChain.dm
// Stage 4: Complete fire-gated recipe progression for sandbox mode
// Progression: Find wood -> Kindling -> Light fire -> Smelt ore -> Forge tools -> Refine -> Assemble

// Recipe chain progression tracker
/datum/recipe_chain_progress
	var
		chain_name = ""
		list/steps = list()      // Ordered recipe keys for this chain
		current_step = 0
		steps_completed = 0
		last_step_time = 0

// Recipe chains for sandbox progression
var/list/RECIPE_CHAINS = list()

// Fire-gated smelting chain tracker
var/fire_gated_smelting_enabled = TRUE
var/fire_gating_debug = TRUE

proc/InitializeSandboxRecipeChains()
	set background = 1
	set waitfor = 0
	
	// ========================================================================
	// CHAIN 1: Basic Fire -> First Tools
	// ========================================================================
	// Progression: wood -> kindling -> campfire -> smelt ore -> hammer
	
	var/datum/recipe_chain_progress/chain_fire_tools = new()
	chain_fire_tools.chain_name = "Fire to First Tools"
	chain_fire_tools.steps = list(
		"stick",
		"flint",
		"pyrite",
		"kindling",
		"campfire_light",
		"mine_ore",
		"smelt_ore",
		"forge_hammer_head"
	)
	RECIPE_CHAINS["fire_tools"] = chain_fire_tools
	
	// ========================================================================
	// CHAIN 1B: Alloy Mastery -> Bronze Tools
	// ========================================================================
	// Progression: copper ore -> tin ore -> bronze -> bronze tools
	
	var/datum/recipe_chain_progress/chain_alloys = new()
	chain_alloys.chain_name = "Alloy Mastery"
	chain_alloys.steps = list(
		"mine_ore",
		"smelt_ore",
		"smelt_copper",
		"smelt_tin",
		"smelt_bronze",
		"forge_bronze_hammer_head",
		"file_hammer_head",
		"sharpen_hammer_head",
		"quench_hammer_head"
	)
	RECIPE_CHAINS["alloys"] = chain_alloys
	
	// ========================================================================
	// CHAIN 2: Tool Refinement -> Perfect Quality
	// ========================================================================
	// Progression: unrefined hammer -> filed -> sharpened -> quenched
	
	var/datum/recipe_chain_progress/chain_refinement = new()
	chain_refinement.chain_name = "Tool Refinement"
	chain_refinement.steps = list(
		"forge_hammer_head",
		"file_hammer_head",
		"sharpen_hammer_head",
		"quench_hammer_head"
	)
	RECIPE_CHAINS["refinement"] = chain_refinement
	
	// ========================================================================
	// CHAIN 3: Shelter & Survival
	// ========================================================================
	// Progression: materials -> frame -> tent -> sturdy shelter
	
	var/datum/recipe_chain_progress/chain_shelter = new()
	chain_shelter.chain_name = "Shelter Building"
	chain_shelter.steps = list(
		"stick",
		"craft_tent"
	)
	RECIPE_CHAINS["shelter"] = chain_shelter
	
	// ========================================================================
	// CHAIN 4: Masonry & Construction
	// ========================================================================
	// Progression: limestone -> lime -> mortar -> bricks -> stone structures -> castles
	
	var/datum/recipe_chain_progress/chain_masonry = new()
	chain_masonry.chain_name = "Masonry Mastery"
	chain_masonry.steps = list(
		"mine_limestone",
		"process_lime",
		"gather_clay",
		"gather_sand",
		"make_lime_mortar",
		"create_bricks",
		"stonework_build",
		"build_castle"
	)
	RECIPE_CHAINS["masonry"] = chain_masonry
	
	// ========================================================================
	// CHAIN 5: Infrastructure & Settlement
	// ========================================================================
	// Progression: wood house -> furnishings -> forge -> kiln -> anvil -> smithy
	
	var/datum/recipe_chain_progress/chain_infrastructure = new()
	chain_infrastructure.chain_name = "Infrastructure Building"
	chain_infrastructure.steps = list(
		"build_wood_house",
		"make_furnishings",
		"build_furnace",
		"build_kiln",
		"build_forge",
		"build_anvil"
	)
	RECIPE_CHAINS["infrastructure"] = chain_infrastructure
	
	// ========================================================================
	// CHAIN 6: Advanced Metallurgy & Damascus Steel
	// ========================================================================
	// Progression: charcoal -> activated carbon -> steel -> damascus -> legendary weapons
	
	var/datum/recipe_chain_progress/chain_damascus = new()
	chain_damascus.chain_name = "Damascus Steel Mastery"
	chain_damascus.steps = list(
		"burn_wood",
		"make_activated_carbon",
		"smelt_steel",
		"make_damascus_steel",
		"forge_damascus_weapons"
	)
	RECIPE_CHAINS["damascus"] = chain_damascus
	
	// ========================================================================
	// CHAIN 7: Alloy Diversity -> Brass & Advanced Materials
	// ========================================================================
	// Progression: copper -> zinc -> brass -> decorative/durable tools
	
	var/datum/recipe_chain_progress/chain_brass = new()
	chain_brass.chain_name = "Brass Alloy Crafting"
	chain_brass.steps = list(
		"mine_copper",
		"smelt_copper",
		"mine_zinc",
		"smelt_zinc",
		"smelt_brass",
		"forge_brass_hammer_head",
		"forge_brass_pickaxe_head"
	)
	RECIPE_CHAINS["brass"] = chain_brass
	
	// ========================================================================
	// CHAIN 8: Lead & Alternative Metallurgy
	// ========================================================================
	// Progression: lead ore -> lead ingot -> specialized materials
	
	var/datum/recipe_chain_progress/chain_lead = new()
	chain_lead.chain_name = "Lead Working"
	chain_lead.steps = list(
		"mine_lead",
		"smelt_lead"
	)
	RECIPE_CHAINS["lead"] = chain_lead
	
	// ========================================================================
	// CHAIN 9: Logistics & Trade
	// ========================================================================
	// Progression: barrels -> hand cart -> metal-reinforced cart -> trade routes
	
	var/datum/recipe_chain_progress/chain_logistics = new()
	chain_logistics.chain_name = "Trade & Transport"
	chain_logistics.steps = list(
		"craft_barrels",
		"craft_hand_cart",
		"craft_metal_cart",
		"load_barrel_to_cart"
	)
	RECIPE_CHAINS["logistics"] = chain_logistics
	
	if(fire_gating_debug)
		world.log << "\[SANDBOX RECIPE CHAIN\] Initialized [RECIPE_CHAINS.len] recipe chains"
		world.log << "\[SANDBOX RECIPE CHAIN\] Fire gating enabled: [fire_gated_smelting_enabled]"
		world.log << "\[SANDBOX RECIPE CHAIN\] Chains: fire_tools, alloys, refinement, shelter, masonry, infrastructure, damascus, brass, lead, logistics"

/proc/CanCraftWithFireGating(mob/players/player, recipe_key)
	/**
	 * Gated crafting check: Enforce fire requirements
	 * Returns: TRUE if player can craft, FALSE + reason if not
	 * 
	 * Used by crafting systems before starting any recipe
	 */
	if(!fire_gated_smelting_enabled)
		return CanCraftRecipe(player, recipe_key)  // Use standard checks if gating disabled
	
	var/datum/recipe_entry/recipe = KNOWLEDGE[recipe_key]
	if(!recipe)
		return FALSE
	
	// Fire-dependent recipes MUST have active fire nearby
	if(recipe.requires_fire)
		// Check for active fire at player location
		if(!HasActiveFire(player.loc))
			if(fire_gating_debug)
				player << "You need an active fire to craft [recipe.name]!"
			return FALSE
		
		// Additional check: fire must be accessible workstation type
		var/datum/fire/fire_obj = GetNearestFire(player.loc)
		if(fire_obj)
			// Verify fire type matches recipe workstation
			if(!fire_obj.IsCompatibleWithRecipe(recipe.workstation_type))
				if(fire_gating_debug)
					player << "This fire is not suitable for [recipe.name]. Need: [recipe.workstation_type]"
				return FALSE
	
	// Standard prerequisite checks
	return CanCraftRecipe(player, recipe_key)

/proc/GetNearestFire(turf/location, range = 5)
	/**
	 * Find nearest active fire to location within range
	 * Returns: /datum/fire or null
	 */
	if(!location)
		return null
	
	var/closest_fire = null
	var/closest_distance = range
	
	for(var/datum/fire/fire in active_fires)
		if(!fire.IsLit())
			continue
		
		var/distance = get_dist(location, fire.location)
		if(distance <= closest_distance)
			closest_fire = fire
			closest_distance = distance
	
	return closest_fire

/proc/StartSandboxCraftingSession(mob/players/player, recipe_key)
	/**
	 * Begin a crafting session for a recipe
	 * Validates fire gating, gathers ingredients, starts animation
	 * 
	 * Returns: TRUE if session started, FALSE if failed
	 */
	if(!player)
		return FALSE
	
	var/datum/recipe_entry/recipe = KNOWLEDGE[recipe_key]
	if(!recipe)
		return FALSE
	
	// Fire gating check
	if(!CanCraftWithFireGating(player, recipe_key))
		return FALSE
	
	// Check inventory for ingredients
	if(!HasIngredientsForRecipe(player, recipe))
		player << "You lack the required ingredients for [recipe.name]."
		return FALSE
	
	// Remove ingredients from inventory
	ConsumeIngredientsForRecipe(player, recipe)
	
	// Show crafting message
	player << "You begin crafting [recipe.name]..."
	
	// Simulate crafting time (varies by recipe complexity)
	var/craft_time = GetCraftingTime(recipe)
	spawn(craft_time)
		CompleteSandboxCraft(player, recipe)
	
	return TRUE

/proc/CompleteSandboxCraft(mob/players/player, datum/recipe_entry/recipe)
	/**
	 * Complete a crafting session and grant outputs
	 */
	if(!player || !recipe)
		return
	
	// Grant outputs
	for(var/item_name in recipe.outputs)
		var/quantity = recipe.outputs[item_name]
		// TODO: Integrate with actual inventory system
		player << "You successfully created [quantity]x [item_name]!"
	
	// Grant experience
	if(recipe.experience_reward > 0)
		var/skill = recipe.skill_requirement
		if(skill != "")
			player.UpdateRankExp(skill, recipe.experience_reward)
			player << "You gained [recipe.experience_reward] XP in [skill]!"
	
	// Mark recipe as discovered (if not already)
	if(player.character && player.character.recipe_state)
		player.character.recipe_state.DiscoverRecipe(recipe.recipe_key)

/proc/HasIngredientsForRecipe(mob/players/player, datum/recipe_entry/recipe)
	/**
	 * Check if player has all required ingredients
	 * Future: Actually check inventory system
	 */
	// Placeholder for inventory integration
	return TRUE

/proc/ConsumeIngredientsForRecipe(mob/players/player, datum/recipe_entry/recipe)
	/**
	 * Remove ingredients from player inventory
	 * Future: Actually consume from inventory system
	 */
	// Placeholder for inventory integration
	for(var/ingredient in recipe.inputs)
		// TODO: Remove from inventory
		continue

/proc/GetCraftingTime(datum/recipe_entry/recipe)
	/**
	 * Calculate crafting time in ticks
	 * Varies by recipe complexity and workstation type
	 */
	switch(recipe.tier)
		if("rudimentary")
			return 30   // 150ms
		if("basic")
			return 60   // 300ms
		if("intermediate")
			return 120  // 600ms
		if("advanced")
			return 240  // 1200ms
	return 60

/proc/UnlockChainStep(mob/players/player, chain_name)
	/**
	 * Unlock next step in a recipe chain
	 * Called when player completes current step
	 */
	var/datum/recipe_chain_progress/chain = RECIPE_CHAINS[chain_name]
	if(!chain)
		return
	
	chain.current_step += 1
	chain.steps_completed += 1
	chain.last_step_time = world.time
	
	var/total_steps = chain.steps?.len || 0
	if(chain.current_step >= total_steps)
		if(player)
			player << "Congratulations! You've mastered the [chain.chain_name] chain!"
	else
		var/next_idx = chain.current_step + 1
		if(next_idx <= total_steps)
			var/next_recipe = chain.steps[next_idx]
			var/datum/recipe_entry/next_rec = KNOWLEDGE[next_recipe]
			var/next_name = next_rec ? next_rec.name : next_recipe
			if(player)
				player << "Next step: [next_name]"

/proc/GetChainProgress(chain_name)
	/**
	 * Get progress for a specific chain
	 * Returns: datum or null
	 */
	return RECIPE_CHAINS[chain_name]

/proc/DisplayChainProgress(mob/players/player, chain_name)
	/**
	 * Show player their progress in a recipe chain
	 */
	var/datum/recipe_chain_progress/chain = RECIPE_CHAINS[chain_name]
	if(!chain)
		if(player)
			player << "Chain not found: [chain_name]"
		return
	
	var/output = "<b>[chain.chain_name]</b><br>"
	var/total_steps = chain.steps?.len || 0
	output += "Progress: [chain.steps_completed] / [total_steps]<br><br>"
	
	for(var/i = 1; i <= total_steps; i++)
		var/recipe_key = chain.steps[i]
		var/datum/recipe_entry/recipe = KNOWLEDGE[recipe_key]
		var/recipe_name = recipe ? recipe.name : recipe_key
		
		if(i <= chain.steps_completed)
			output += "<font color='green'>✓ [recipe_name]</font><br>"
		else if(i == chain.steps_completed + 1)
			output += "<font color='blue'>→ [recipe_name] (Next)</font><br>"
		else
			output += "<font color='gray'>• [recipe_name]</font><br>"
	
	if(player)
		player << output

// Player verb to view recipe chain progress
/mob/players/verb/view_recipe_chain()
	set name = "View Recipe Chains"
	set category = "Crafting"
	set desc = "View your progress through recipe chains"
	
	if(!RECIPE_CHAINS || !RECIPE_CHAINS.len)
		src << "No recipe chains available."
		return
	
	var/list/chain_names = list()
	for(var/chain_key in RECIPE_CHAINS)
		var/datum/recipe_chain_progress/chain = RECIPE_CHAINS[chain_key]
		if(chain)
			chain_names[chain.chain_name] = chain_key
	
	var/selected = input("Select a chain to view:", "Recipe Chains") in chain_names
	if(selected)
		var/chain_key = chain_names[selected]
		DisplayChainProgress(src, chain_key)

// Alternative: View all chains at once
/mob/players/verb/view_all_recipe_chains()
	set name = "View All Recipe Chains"
	set category = "Crafting"
	set desc = "View progress on all recipe chains"
	
	if(!RECIPE_CHAINS || !RECIPE_CHAINS.len)
		src << "No recipe chains available."
		return
	
	var/output = "<b>RECIPE CHAIN PROGRESSION</b><hr>"
	
	for(var/chain_key in RECIPE_CHAINS)
		var/datum/recipe_chain_progress/chain = RECIPE_CHAINS[chain_key]
		if(!chain)
			continue
		
		var/total = chain.steps?.len || 0
		output += "<b>[chain.chain_name]</b> ([chain.steps_completed]/[total])<br>"
		
		// Show next 2 steps only
		if(chain.steps_completed < total)
			for(var/i = chain.steps_completed + 1; i <= min(chain.steps_completed + 2, total); i++)
				var/next_recipe = chain.steps[i]
				var/datum/recipe_entry/recipe = KNOWLEDGE[next_recipe]
				var/recipe_name = recipe ? recipe.name : next_recipe
				output += "  → [recipe_name]<br>"
		else
			output += "  ✓ COMPLETE<br>"
		
		output += "<br>"
	
	src << output

/datum/fire/proc/IsCompatibleWithRecipe(workstation_type)
	/**
	 * Check if this fire source is suitable for a recipe's workstation type
	 */
	switch(fire_type)
		if("campfire")
			return (workstation_type == "fire" || workstation_type == "none")
		if("torch")
			return (workstation_type == "none")  // Portable, minimal cooking
		if("forge")
			return (workstation_type == "forge" || workstation_type == "fire")
		if("oven")
			return (workstation_type == "oven" || workstation_type == "fire")
		if("smelter")
			return (workstation_type == "fire" || workstation_type == "smelter")
		if("brazier")
			return (workstation_type == "none")  // Generic warmth/light
	
	return FALSE
