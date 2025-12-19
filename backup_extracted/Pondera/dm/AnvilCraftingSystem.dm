// ========================================
// Anvil Crafting System
// ========================================
// Context-aware crafting menu for hammer when near anvil
// Similar to SmithingMenuSystem but specifically for anvil interactions
// 
// Architecture:
// - DisplayAnvilMenu(M) → Main menu
// - IsNearAnvil(M) → Check proximity to anvil objects
// - GetAvailableAnvilRecipes(M, rank) → Filter recipes by rank
// - ExecuteAnvilCraft(M, recipe_name) → Perform crafting
// 

// Main entry point for anvil crafting menus
/proc/DisplayAnvilMenu(mob/players/M)
	if(!M) return
	if(!istype(M, /mob/players)) return
	
	// Verify player is still near anvil
	if(!IsNearAnvil(M))
		M << "<red>You are no longer near the anvil.</red>"
		return
	
	// Get player rank for smithing (use smithing rank for anvil crafting)
	var/rank = 1  // Default rank if character not initialized
	if(M)
		rank = M.GetRankLevel(RANK_SMITHING) || 1
	
	// Get available recipes at this rank
	var/list/recipes = GetAvailableAnvilRecipes(M, rank)
	if(!recipes || recipes.len == 0)
		M << "<red>You need to improve your smithing rank to craft items at the anvil.</red>"
		return
	
	// Show recipe selection
	var/recipe_choice = input("What would you like to forge?", "Anvil Crafting") in recipes
	
	if(!recipe_choice)
		M << "You step away from the anvil."
		return
	
	if(recipe_choice == "Cancel")
		M << "You step away from the anvil."
		return
	
	// Execute crafting
	ExecuteAnvilCraft(M, recipe_choice)

// Get list of recipes available at this rank for anvil crafting
/proc/GetAvailableAnvilRecipes(mob/players/M, rank)
	var/list/available_recipes = list()
	
	// Get all smithing recipes (anvil uses smithing recipe system)
	if(!SMITHING_RECIPES || SMITHING_RECIPES.len == 0)
		InitializeSmithingRecipes()
	
	// Add all recipes that can be crafted at anvil
	// For now: all smithing recipes with appropriate rank
	for(var/recipe_name in SMITHING_RECIPES)
		var/recipe = SMITHING_RECIPES[recipe_name]
		if(recipe["required_rank"] <= rank)
			available_recipes[recipe["name"]] = recipe_name
	
	available_recipes["Cancel"] = "cancel"
	
	return available_recipes

// Check requirements for anvil crafting
/proc/CheckAnvilCraftRequirements(mob/players/M, recipe_data)
	/**
	 * CheckAnvilCraftRequirements(M, recipe_data) -> int
	 * 
	 * Verifies all requirements for crafting at anvil:
	 * - Player has hammer equipped
	 * - Player is near anvil
	 * - Player has required rank
	 * - Player has required ingredients
	 * - Player has sufficient stamina
	 * 
	 * Returns: 1 if all requirements met, 0 otherwise
	 */
	
	if(!M || !recipe_data) return 0
	
	// Check hammer equipped
	if(M.HMequipped != 1)
		M << "<red>You need a hammer equipped to work the anvil.</red>"
		return 0
	
	// Check proximity to anvil
	if(!IsNearAnvil(M))
		M << "<red>You are no longer near the anvil.</red>"
		return 0
	
	// Check rank
	var/rank = 1
	if(M)
		rank = M.GetRankLevel(RANK_SMITHING) || 1
	if(rank < recipe_data["required_rank"])
		M << "<red>You need smithing rank [recipe_data["required_rank"]] to craft this item.</red>"
		return 0
	
	// Check stamina
	// TODO: Link to actual stamina system
	// For now assume stamina exists
	if(M.stamina && M.stamina < 10)
		M << "<red>You're too tired to work the anvil.</red>"
		return 0
	
	// Check ingredients
	// TODO: Link to actual inventory system
	// For now assume ingredients can be checked
	
	return 1

// Execute anvil crafting
/proc/ExecuteAnvilCraft(mob/players/M, recipe_name)
	/**
	 * ExecuteAnvilCraft(M, recipe_name) -> int
	 * 
	 * Performs anvil crafting for selected recipe.
	 * Updates player stats, creates items, provides feedback.
	 * 
	 * Returns: 1 if successful, 0 if failed
	 */
	
	if(!M) return 0
	
	var/recipe = GetSmithingRecipe(recipe_name)
	if(!recipe)
		M << "<red>Recipe not found!</red>"
		return 0
	
	// Check all requirements
	if(!CheckAnvilCraftRequirements(M, recipe))
		return 0
	
	// Show what's being crafted
	M << "<yellow>You begin working the anvil...</yellow>"
	M << "<cyan>Crafting: [recipe["name"]]</cyan>"
	
	// Get success rate based on rank
	var/rank = 1
	if(M)
		rank = M.GetRankLevel(RANK_SMITHING) || 1
	
	var/base_success = recipe["base_success_rate"] || 50
	var/rank_bonus = (rank - recipe["required_rank"]) * 5  // 5% per rank above required
	var/success_rate = min(95, base_success + rank_bonus)  // Cap at 95%
	
	// Roll for success
	var/is_success = (rand(0, 100) <= success_rate)
	
	if(!is_success)
		M << "<orange>Your craft fails! The item is ruined.</orange>"
		// Still consume resources and stamina on failure
		if(M.stamina)
			M.stamina = max(0, M.stamina - 5)
		return 0
	
	// Success!
	M << "<lime>You successfully craft [recipe["name"]]!</lime>"
	
	// Award XP
	var/xp_reward = recipe["xp_reward"] || 10
	if(M.character)
		M.character.UpdateRankExp(RANK_SMITHING, xp_reward)
		M << "<green>+[xp_reward] Smithing XP</green>"
	
	// Consume stamina
	if(M.stamina)
		M.stamina = max(0, M.stamina - 10)
	
	// Consume ingredients from inventory
	var/ingredients_consumed = 1
	for(var/ingredient_name in recipe["ingredients"])
		var/amount_needed = recipe["ingredients"][ingredient_name]
		if(!RemoveItemsFromInventory(M, ingredient_name, amount_needed))
			M << "<red>Failed to consume ingredient: [ingredient_name]</red>"
			ingredients_consumed = 0
	
	if(!ingredients_consumed)
		M << "<red>Crafting failed - could not consume ingredients.</red>"
		return 0
	
	// Create the crafted item
	var/output_type = recipe["output_type"]
	if(!output_type)
		M << "<red>Recipe output type not defined.</red>"
		return 0
	
	var/obj/items/crafted_item = new output_type(M.loc)
	if(!crafted_item)
		M << "<red>Failed to create crafted item.</red>"
		return 0
	
	M << "<lime>Your [recipe["name"]] is complete!</lime>"
	view(3, M) << "<b>[M.name]</b> has crafted a [recipe["name"]]!"
	
	// Apply durability wear on hammer if equipped
	var/obj/items/equipment/tool/Hammer/hammer_item = FindItemInInventory(M, /obj/items/equipment/tool/Hammer)
	if(hammer_item && !hammer_item.AttemptUse())
		M << "<red>Your hammer has shattered mid-strike! Find a new one to craft.</red>"
		return 0
	else if(hammer_item && hammer_item.IsFragile())
		var/percent = hammer_item.GetDurabilityPercent()
		M << "<yellow>Your hammer is worn ([percent]% durability left).</yellow>"
	
	// Check for rank up
	if(M)
		var/new_rank = M.GetRankLevel(RANK_SMITHING)
		if(new_rank > rank)
			M << "<lime>Your smithing skill has improved to rank [new_rank]!</lime>"
	
	return 1

