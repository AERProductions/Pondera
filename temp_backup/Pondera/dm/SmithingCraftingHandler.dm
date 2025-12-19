// ========================================
// Smithing Crafting Handler
// ========================================
// Core crafting logic: ingredient validation, XP rewards, item creation
// Integrates with SmithingRecipes.dm & SmithingMenuSystem.dm
//
// Key Procedures:
// - CraftSmithingItem(M, recipe) → Main crafting handler
// - CalculateSuccessRate(rank, base_rate) → Rank-based success
// - AwardSmithingXP(M, recipe) → XP calculation & rank up checks
// - CreateSmithingOutput(M, recipe) → Generate output item
//

// Main crafting handler - called from menu selection
/proc/CraftSmithingItem(mob/M, recipe_name)
	if(!M || !istype(M, /mob/players)) return
	
	var/recipe = GetSmithingRecipe(recipe_name)
	if(!recipe) return
	
	// Gate on rank
	var/rank = M.character.GetRankLevel(RANK_SMITHING)
	if(rank < recipe["required_rank"])
		M << "<red>You don't have the skill rank [recipe["required_rank"]] needed for this recipe.</red>"
		return
	
	// Gate on stamina (crafting is tiring)
	if(M.stamina < 5)
		M << "<red>You're too exhausted to craft. Drink water to restore stamina.</red>"
		return
	
	// Check all ingredients present
	if(!VerifyIngredientsInInventory(M, recipe))
		M << "<red>You don't have all the required ingredients.</red>"
		ShowIngredientRequirements(M, recipe)
		return
	
	// Begin crafting
	M << "<yellow>You begin to craft [recipe["name"]]...</yellow>"
	M.Doing = 1
	
	// Remove ingredients before crafting (commit to action)
	ConsumeIngredients(M, recipe)
	
	// Add anvil/forge overlay effect (3 second delay = 30 ticks)
	var/obj/Anvil = locate() in view(1, M)  // Find nearby anvil/forge
	if(Anvil && Anvil.name in list("Anvil", "Forge", "Empty Forge", "Lit Forge"))
		Anvil.overlays += image('dmi/64/creation.dmi', icon_state="anvilL")
	
	sleep(30)  // 3 second crafting animation
	
	// Deduct stamina
	M.stamina -= 5
	M.updateST()
	
	// Calculate success
	var/success_rate = CalculateSuccessRate(rank, recipe["base_success_rate"])
	var/dice = rand(1, 100)
	
	if(dice <= success_rate)
		// Success! Create output and award XP
		CreateSmithingOutput(M, recipe)
		M << "<green>Success! You craft [recipe["name"]]!</green>"
		AwardSmithingXP(M, recipe, TRUE)  // TRUE = successful craft (bonus XP)
	else
		// Failure - lost ingredients but minor XP
		M << "<red>The materials fail to react well together...</red>"
		AwardSmithingXP(M, recipe, FALSE)  // FALSE = failed craft (50% XP)
	
	// Clean up overlay
	if(Anvil && Anvil.overlays.len > 0)
		Anvil.overlays -= image('dmi/64/creation.dmi', icon_state="anvilL")
	
	M.Doing = 0

// Calculate success rate with rank bonuses
/proc/CalculateSuccessRate(rank, base_rate)
	// Rank 1-11 progression: +5% per rank above minimum
	// Min: 50%, Max: 100%
	var/rank_bonus = max(0, (rank - 1) * 5)
	var/final_rate = min(100, base_rate + rank_bonus)
	
	return final_rate

// Verify ALL ingredients are in player inventory
/proc/VerifyIngredientsInInventory(mob/M, recipe_data)
	if(!M || !recipe_data) return FALSE
	
	var/list/ingredients = recipe_data["ingredients"]
	
	for(var/ingredient_name in ingredients)
		var/amount_needed = ingredients[ingredient_name]
		ingredient_name = lowertext(ingredient_name)
		
		// Count matching items in inventory
		var/count = 0
		var/obj/item
		for(item in M.contents)
			if(lowertext(item.name) == ingredient_name)
				// Check for stacking items (ingots, materials, etc)
				if(item.vars.Find("stack_amount"))
					count += item.stack_amount
				else
					count += 1
		
		if(count < amount_needed)
			return FALSE
	
	return TRUE

// Remove ingredients from inventory
/proc/ConsumeIngredients(mob/M, recipe_data)
	if(!M || !recipe_data) return FALSE
	
	var/list/ingredients = recipe_data["ingredients"]
	
	for(var/ingredient_name in ingredients)
		var/amount_needed = ingredients[ingredient_name]
		ingredient_name = lowertext(ingredient_name)
		
		// Remove from stacking items first
		var/obj/item
		for(item in M.contents)
			if(amount_needed <= 0) break
			if(lowertext(item.name) == ingredient_name)
				if(item.vars.Find("stack_amount") && item.stack_amount > 0)
					var/can_remove = min(item.stack_amount, amount_needed)
					item.RemoveFromStack(can_remove)
					amount_needed -= can_remove
				else if(!item.vars.Find("stack_amount"))
					del(item)
					amount_needed -= 1
	
	return TRUE

// Award XP based on recipe difficulty & success
/proc/AwardSmithingXP(mob/M, recipe_data, success)
	if(!M || !recipe_data) return
	
	var/base_xp = recipe_data["xp_reward"]
	var/rank = M.character.GetRankLevel(RANK_SMITHING)
	
	// XP calculation:
	// - Successful: 100% of base
	// - Failed: 50% of base (still learning)
	// - Rank bonus: recipes at/above current rank worth less XP
	var/xp_multiplier = 1.0
	
	if(!success)
		xp_multiplier = 0.5
	
	// Difficulty scaling: recipes above current rank worth more
	var/recipe_rank = recipe_data["required_rank"]
	if(recipe_rank > rank)
		xp_multiplier *= (1.0 + (recipe_rank - rank) * 0.1)
	
	var/final_xp = round(base_xp * xp_multiplier)
	
	// Award XP
	M.character.UpdateRankExp(RANK_SMITHING, final_xp)
	M << "<cyan>+[final_xp] Smithing experience!</cyan>"

// Create the output item from recipe
/proc/CreateSmithingOutput(mob/M, recipe_data)
	if(!M || !recipe_data) return
	
	var/output_type = recipe_data["output_type"]
	var/output_name = recipe_data["name"]
	
	// Create generic crafted item (can be specialized per recipe later)
	var/obj/item/created_item = new /obj/items/Crafting/Created
	created_item.name = output_name
	created_item.desc = recipe_data["description"]
	
	// Move to player inventory
	created_item.Move(M)
	
	return created_item

// Proc to display crafting menu (called from SmithingModernE-Key.dm)
/proc/DisplaySmithingCraftingMenu(mob/M)
	if(!M) return
	DisplaySmithingMenu(M)  // Delegate to SmithingMenuSystem.dm

// Initialize crafting system (call from world startup)
/proc/InitializeSmithingCraftingSystem()
	if(!SMITHING_RECIPES || SMITHING_RECIPES.len == 0)
		InitializeSmithingRecipes()
	
	world << "[DEBUG] Smithing crafting system initialized with [SMITHING_RECIPES.len] recipes"
	return TRUE
