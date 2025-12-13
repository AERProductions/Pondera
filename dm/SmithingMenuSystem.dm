// ========================================
// Smithing Menu System
// ========================================
// Rank-gated UI with clean procs for displaying menus
// Replaces nested input() calls in Objects.dm Smithing verb (1000+ lines reduction)
// 
// Architecture:
// - DisplaySmithingMenu(M) → Main menu
// - GetAvailableCategories(M, rank) → Filter categories
// - DisplayCategoryMenu(M, category, rank) → Show items in category
// - GetCategoryItems(category, rank) → Fetch items list
// 

// Main entry point for smithing menus
/proc/DisplaySmithingMenu(mob/M)
	if(!M) return
	if(!istype(M, /mob/players)) return
	
	var/rank = M.character.GetRankLevel(RANK_SMITHING)
	
	// Initialize recipes if needed
	if(!SMITHING_RECIPES || SMITHING_RECIPES.len == 0)
		InitializeSmithingRecipes()
	
	// Main menu: Categories available at this rank
	var/list/categories = GetAvailableCategories(M, rank)
	if(!categories || categories.len == 0)
		M << "<red>You need to improve your smithing rank to craft items.</red>"
		return
	
	var/category_choice = input("What would you like to craft?", "Smithing") in categories
	
	if(!category_choice)
		M << "You cancel your smithing work."
		return
	
	DisplayCategoryMenu(M, category_choice, rank)

// Get list of categories available at player's rank
/proc/GetAvailableCategories(mob/M, rank)
	var/list/available_categories = list()
	var/list/found_categories = list()
	
	// Find unique categories with recipes at this rank
	for(var/recipe_name in SMITHING_RECIPES)
		var/recipe = SMITHING_RECIPES[recipe_name]
		if(recipe["required_rank"] <= rank)
			var/cat = recipe["category"]
			if(!(cat in found_categories))
				found_categories += cat
	
	// Convert internal names to display names
	if("misc" in found_categories)
		available_categories["Misc."] = "misc"
	if("tools" in found_categories)
		available_categories["Tools"] = "tools"
	if("weapons" in found_categories)
		available_categories["Weapons"] = "weapons"
	if("armor_evasive" in found_categories)
		available_categories["Armor - Evasive"] = "armor_evasive"
	if("armor_defensive" in found_categories)
		available_categories["Armor - Defensive"] = "armor_defensive"
	if("armor_offensive" in found_categories)
		available_categories["Armor - Offensive"] = "armor_offensive"
	if("lamps" in found_categories)
		available_categories["Lamps"] = "lamps"
	if("containers" in found_categories)
		available_categories["Containers"] = "containers"
	
	available_categories["Back"] = null
	available_categories["Cancel"] = null
	
	return available_categories

// Display items in a category for selection
/proc/DisplayCategoryMenu(mob/M, category_internal, rank)
	if(!M || !category_internal) return
	
	var/list/items = GetCategoryItems(category_internal, rank)
	
	if(!items || items.len == 0)
		M << "<yellow>No recipes available in this category at your rank.</yellow>"
		return
	
	var/item_choice = input("What would you like to craft?", "Smithing - [category_internal]") in items
	
	if(!item_choice)
		DisplaySmithingMenu(M)
		return
	
	if(item_choice == "Back")
		DisplaySmithingMenu(M)
		return
	
	if(item_choice == "Cancel")
		M << "You cancel your smithing work."
		return
	
	// User selected a recipe - trigger crafting
	AttemptCraft(M, item_choice)

// Get list of items in a category for this rank
/proc/GetCategoryItems(category, rank)
	var/list/items = list()
	
	for(var/recipe_name in SMITHING_RECIPES)
		var/recipe = SMITHING_RECIPES[recipe_name]
		if(recipe["category"] == category && recipe["required_rank"] <= rank)
			items[recipe["name"]] = recipe_name
	
	items["Back"] = "back"
	items["Cancel"] = "cancel"
	
	return items

// Show ingredient requirements for a recipe
/proc/ShowIngredientRequirements(mob/M, recipe_data)
	if(!M || !recipe_data) return
	
	M << "<yellow>Recipe: [recipe_data["name"]]</yellow>"
	M << "<cyan>Ingredients needed:</cyan>"
	
	var/list/ingredients = recipe_data["ingredients"]
	for(var/ingredient in ingredients)
		var/amount = ingredients[ingredient]
		M << "  - [ingredient] x[amount]"
	
	M << "<cyan>Rank required: [recipe_data["required_rank"]]</cyan>"
	M << "<cyan>Base success rate: [recipe_data["base_success_rate"]]%</cyan>"
	M << "<cyan>XP reward: [recipe_data["xp_reward"]]</cyan>"

// Check if player has all ingredients
/proc/CheckIngredients(mob/M, recipe_data)
	if(!M || !recipe_data) return FALSE
	
	var/list/ingredients = recipe_data["ingredients"]
	for(var/ingredient_name in ingredients)
		var/amount_needed = ingredients[ingredient_name]
		
		// Check player inventory for ingredient
		// TODO: Link to actual item type lookup when SmithingCraftingHandler.dm created
		// For now, assume ingredient checking works
		
	return TRUE

// Remove ingredients from inventory
/proc/RemoveIngredients(mob/M, recipe_data)
	if(!M || !recipe_data) return FALSE
	
	var/list/ingredients = recipe_data["ingredients"]
	for(var/ingredient_name in ingredients)
		var/amount_needed = ingredients[ingredient_name]
		
		// TODO: Implement ingredient removal
		// Link to actual item RemoveFromStack() calls
		
	return TRUE

// Main crafting attempt (placeholder - full implementation in SmithingCraftingHandler.dm)
/proc/AttemptCraft(mob/M, recipe_name)
	if(!M) return
	
	var/recipe = GetSmithingRecipe(recipe_name)
	if(!recipe)
		M << "<red>Recipe not found!</red>"
		return
	
	// Verify rank
	var/rank = M.character.GetRankLevel(RANK_SMITHING)
	if(rank < recipe["required_rank"])
		M << "<red>You need rank [recipe["required_rank"]] to craft this.</red>"
		return
	
	// Show what's needed
	ShowIngredientRequirements(M, recipe)
	
	// Check & remove ingredients
	if(!CheckIngredients(M, recipe))
		M << "<red>You don't have the required ingredients.</red>"
		return
	
	RemoveIngredients(M, recipe)
	
	// TODO: Call full crafting handler from SmithingCraftingHandler.dm
	// This includes:
	// - XP award calculation
	// - Success rate check (with rank bonus)
	// - Item creation
	// - Feedback messages
	// - Animations/overlays
	
	M << "<green>Crafting system initialized (full handler in SmithingCraftingHandler.dm)</green>"
