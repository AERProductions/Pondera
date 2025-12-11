/**
 * COOKING SYSTEM
 * Transforms raw ingredients into prepared meals
 * Fire/Oven-based cooking mechanics with skill progression
 *
 * Integration Points:
 * - Raw food items (vegetables, grain, meat from ConsumptionManager)
 * - Fire/Oven objects (must be lit/heated)
 * - Cooking skill (ranks 1-10, unlocks new recipes)
 * - Recipe discovery system
 * - Meal quality/nutrition calculation
 */

// ==================== COOKING CONSTANTS ====================

#define COOKING_SKILL_NAME "Culinary"
#define COOKING_SKILL_KEY RANK_COOKING  // If added to SkillManager

// Cooking appliance types
#define OVEN_TYPE_FIRE      1       // Basic open fire
#define OVEN_TYPE_STONE     2       // Stone oven (1.1× quality)
#define OVEN_TYPE_CLAY      3       // Clay oven (1.2× quality, faster)
#define OVEN_TYPE_IRON      4       // Iron oven (1.3× quality, much faster)
#define OVEN_TYPE_INDUSTRIAL 5      // Industrial/steel (1.5× quality, fastest)

// Cooking methods
#define COOK_METHOD_BOIL    1
#define COOK_METHOD_BAKE    2
#define COOK_METHOD_ROAST   3
#define COOK_METHOD_FRY     4
#define COOK_METHOD_STEAM   5
#define COOK_METHOD_STEW    6

// Cooking times (in ticks)
#define COOK_BASE_TIME      30      // 1.5 seconds base
#define COOK_MAX_TIME       300     // 15 seconds max

// Temperature requirements
#define TEMP_BOIL_MIN       200     // Minimum heat needed
#define TEMP_BAKE_MIN       300     // Baking temperature
#define TEMP_ROAST_MIN      350
#define TEMP_FRY_MIN        280

// Quality modifiers
#define QUALITY_SKILL_MIN   0.6     // Unskilled cooking reduces quality
#define QUALITY_SKILL_MAX   1.4     // Master chef increases quality
#define QUALITY_TEMP_BONUS  0.1     // Per 50°F above minimum
#define QUALITY_TIME_PENALTY -0.05  // Per second over optimal


// ==================== RECIPE SYSTEM ====================

/**
 * Global recipe database
 * Each recipe contains:
 * - ingredients: list of required items and amounts
 * - method: cooking method (boil, bake, etc.)
 * - temp_min: minimum temperature required
 * - cook_time: base cooking time in ticks
 * - skill_req: minimum cooking rank required
 * - nutrition: nutrition boost from cooking (% of raw)
 * - name: final dish name
 * - description: flavor text
 */

var/global/list/RECIPES = list()

proc/InitializeRecipes()
	// VEGETABLE DISHES
	RECIPES["vegetable soup"] = list(
		"name" = "Vegetable Soup",
		"ingredients" = list(
			"potato" = 2,
			"carrot" = 1,
			"fresh water" = 1
		),
		"method" = COOK_METHOD_BOIL,
		"temp_min" = TEMP_BOIL_MIN,
		"cook_time" = COOK_BASE_TIME * 2,  // 3 seconds
		"skill_req" = 1,
		"nutrition" = 1.15,  // Cooking improves nutrition by 15%
		"skill_mod" = 0.05,  // +5% per skill rank
		"description" = "A warm, nourishing vegetable soup"
	)

	RECIPES["roasted vegetables"] = list(
		"name" = "Roasted Vegetables",
		"ingredients" = list(
			"carrot" = 1,
			"onion" = 1,
			"pumpkin" = 0.5  // Can be partial
		),
		"method" = COOK_METHOD_ROAST,
		"temp_min" = TEMP_ROAST_MIN,
		"cook_time" = COOK_BASE_TIME * 3,  // 4.5 seconds
		"skill_req" = 2,
		"nutrition" = 1.25,
		"skill_mod" = 0.06,
		"description" = "Caramelized and tender roasted vegetables"
	)

	RECIPES["grain porridge"] = list(
		"name" = "Grain Porridge",
		"ingredients" = list(
			"wheat" = 1,
			"fresh water" = 2
		),
		"method" = COOK_METHOD_BOIL,
		"temp_min" = TEMP_BOIL_MIN,
		"cook_time" = COOK_BASE_TIME * 4,  // 6 seconds
		"skill_req" = 1,
		"nutrition" = 1.2,
		"skill_mod" = 0.05,
		"description" = "A hearty grain porridge, filling and warm"
	)

	RECIPES["baked bread"] = list(
		"name" = "Baked Bread",
		"ingredients" = list(
			"wheat" = 2,
			"fresh water" = 1
		),
		"method" = COOK_METHOD_BAKE,
		"temp_min" = TEMP_BAKE_MIN,
		"cook_time" = COOK_BASE_TIME * 5,  // 7.5 seconds
		"skill_req" = 3,
		"nutrition" = 1.3,
		"skill_mod" = 0.07,
		"description" = "Crusty on outside, soft inside - a staple bread"
	)

	RECIPES["berry compote"] = list(
		"name" = "Berry Compote",
		"ingredients" = list(
			"raspberry" = 3,
			"fresh water" = 1
		),
		"method" = COOK_METHOD_BOIL,
		"temp_min" = TEMP_BOIL_MIN,
		"cook_time" = COOK_BASE_TIME * 2,
		"skill_req" = 2,
		"nutrition" = 1.2,
		"skill_mod" = 0.05,
		"description" = "Sweet and tart berry compote"
	)

	// MEAT DISHES
	RECIPES["roasted meat"] = list(
		"name" = "Roasted Meat",
		"ingredients" = list(
			"raw meat" = 1
		),
		"method" = COOK_METHOD_ROAST,
		"temp_min" = TEMP_ROAST_MIN,
		"cook_time" = COOK_BASE_TIME * 3,
		"skill_req" = 2,
		"nutrition" = 1.35,  // Cooking meat improves it more
		"skill_mod" = 0.08,
		"description" = "Juicy roasted meat with a nice crust"
	)

	RECIPES["meat stew"] = list(
		"name" = "Meat Stew",
		"ingredients" = list(
			"raw meat" = 1,
			"potato" = 1,
			"carrot" = 1,
			"fresh water" = 2
		),
		"method" = COOK_METHOD_STEW,
		"temp_min" = TEMP_BOIL_MIN,
		"cook_time" = COOK_BASE_TIME * 6,
		"skill_req" = 4,
		"nutrition" = 1.4,  // Stew is very nutritious
		"skill_mod" = 0.1,
		"description" = "A hearty stew with meat and vegetables"
	)

	RECIPES["fish fillet"] = list(
		"name" = "Fish Fillet",
		"ingredients" = list(
			"raw fish" = 1
		),
		"method" = COOK_METHOD_FRY,
		"temp_min" = TEMP_FRY_MIN,
		"cook_time" = COOK_BASE_TIME * 2,
		"skill_req" = 2,
		"nutrition" = 1.25,
		"skill_mod" = 0.07,
		"description" = "Delicate fish fillet with crispy exterior"
	)

	// ADVANCED DISHES (Higher skill requirements)
	RECIPES["shepherd's pie"] = list(
		"name" = "Shepherd's Pie",
		"ingredients" = list(
			"raw meat" = 1,
			"potato" = 2,
			"carrot" = 1,
			"onion" = 1,
			"fresh water" = 1
		),
		"method" = COOK_METHOD_BAKE,
		"temp_min" = TEMP_BAKE_MIN,
		"cook_time" = COOK_BASE_TIME * 8,
		"skill_req" = 6,
		"nutrition" = 1.5,
		"skill_mod" = 0.12,
		"description" = "A masterfully prepared meat pie with mashed potato top"
	)

	RECIPES["vegetable medley"] = list(
		"name" = "Vegetable Medley",
		"ingredients" = list(
			"carrot" = 1,
			"potato" = 1,
			"onion" = 1,
			"pumpkin" = 0.5,
			"fresh water" = 1
		),
		"method" = COOK_METHOD_STEAM,
		"temp_min" = TEMP_BOIL_MIN,
		"cook_time" = COOK_BASE_TIME * 4,
		"skill_req" = 5,
		"nutrition" = 1.35,
		"skill_mod" = 0.08,
		"description" = "A colorful and balanced selection of steamed vegetables"
	)


// ==================== COOKING OBJECT DEFINITIONS ====================

/**
 * Cooking appliance (Fire or Oven)
 * Can be placed in world or interacted with
 */
obj/Oven
	name = "Fire"
	icon = 'dmi/64/fire.dmi'
	icon_state = "LF"
	var
		oven_type = OVEN_TYPE_FIRE
		current_temp = 0        // Current temperature
		is_lit = 0              // 0 = unlit, 1 = lit, 2 = hot
		cooking_item = null     // Currently cooking item
		cook_time_remaining = 0 // Ticks left to cook
		food_safety = 100       // 100 = perfect, <50 = burnt/unsafe

	New()
		..()
		name = "Fire"

	proc/TryLightFire(mob/players/M)
		if(is_lit)
			M << "The fire is already lit."
			return 0
		
		M << "You light the fire carefully..."
		sleep(5)
		is_lit = 1
		current_temp = 150
		spawn_heating_loop()
		M << "The fire catches and begins to heat."
		return 1

	proc/TryStartCooking(mob/players/M, list/ingredients, list/recipe_data)
		if(!is_lit)
			M << "The fire must be lit before cooking."
			return 0
		
		if(current_temp < recipe_data["temp_min"])
			M << "The fire needs to be hotter (current: [current_temp]°F, needed: [recipe_data["temp_min"]]°F)"
			return 0
		
		if(cooking_item)
			M << "Something is already cooking!"
			return 0
		
		M << "You begin cooking [recipe_data["name"]]..."
		cook_time_remaining = recipe_data["cook_time"]
		cooking_item = list("recipe" = recipe_data, "chef" = M, "ingredients" = ingredients)
		spawn_cooking_loop()
		return 1

	verb/Cook()
		set popup_menu = 1
		set src in oview(1)
		set category = "Cooking"
		
		var/mob/players/M = usr
		ShowCookingMenu(M, src)
	
	verb/Light()
		set popup_menu = 1
		set src in oview(1)
		set category = "Cooking"
		
		var/mob/players/M = usr
		TryLightFire(M)

	proc/spawn_heating_loop()
		set waitfor = 0
		set background = 1
		while(is_lit && src)
			current_temp = min(current_temp + rand(5, 15), 400)
			sleep(5)

	proc/spawn_cooking_loop()
		set waitfor = 0
		set background = 1
		if(!cooking_item) return
		
		var/list/recipe = cooking_item["recipe"]
		var/mob/players/chef = cooking_item["chef"]
		var/list/ingredients = cooking_item["ingredients"]
		
		while(cook_time_remaining > 0 && cooking_item && src)
			cook_time_remaining--
			
			// Temperature affects cooking quality
			var/temp_ratio = current_temp / recipe["temp_min"]
			if(temp_ratio > 1.5)
				food_safety -= 2  // Burning
			else if(temp_ratio < 1.0)
				cook_time_remaining++  // Takes longer if cold
			
			sleep(1)
		
		if(!src) return
		
		// Cooking complete!
		var/list/cooked = FinishCooking(recipe, chef, ingredients)
		if(cooked)
			chef << cooked["message"]
			var/obj/CookedFood/F = new /obj/CookedFood(chef.loc)
			F.recipe_name = cooked["recipe"]
			F.quality_modifier = cooked["quality"]
			// CRITICAL: Initialize elevation based on terrain where cooked
			InitializeElevationFromTerrain(F, isturf(chef.loc) ? chef.loc : null)
			F.UpdateIcon()
		
		cooking_item = null
		food_safety = 100

/obj/Oven/proc/FinishCooking(list/recipe, mob/players/chef, list/ingredients)
	// Get chef's cooking skill rank (0-10, default 1 if not yet trained)
	var/skill_rank = max(1, GetCookingSkillRank(chef))
	var/skill_bonus = (skill_rank - 1) * recipe["skill_mod"]  // Each rank adds bonus
	
	// Base nutrition from cooking
	var/nutrition_mult = recipe["nutrition"] + skill_bonus
	
	// Temperature quality bonus
	var/temp_bonus = max(0, (current_temp - recipe["temp_min"]) / 50) * QUALITY_TEMP_BONUS
	
	// Time penalty if overcooked
	var/time_penalty = max(0, -food_safety / 200) * QUALITY_TIME_PENALTY
	
	// Final quality calculation
	var/final_quality = nutrition_mult + temp_bonus + time_penalty
	final_quality = clamp(final_quality, QUALITY_SKILL_MIN, QUALITY_SKILL_MAX)
	
	// Apply skill-based quality multiplier (from CookingSkillProgression.dm)
	final_quality = ApplyCookingSkillBonus(chef, final_quality)
	
	var/quality_text = ""
	if(final_quality >= 1.3)
		quality_text = "masterfully prepared"
	else if(final_quality >= 1.1)
		quality_text = "well-cooked"
	else if(final_quality >= 0.9)
		quality_text = "adequately prepared"
	else
		quality_text = "poorly prepared"
	
	return list(
		"item_type" = /obj/CookedFood,
		"recipe" = recipe["name"],
		"quality" = final_quality,
		"quality_text" = quality_text,
		"message" = "You finish cooking the [recipe["name"]] - it looks [quality_text]!"
	)


/**
 * Cooked food item
 * Inherits from FoodItem in ConsumptionManager
 */
obj/CookedFood
	var
		recipe_name = "Unknown"
		quality_modifier = 1.0  // 0.6-1.4

	New(loc, list/cook_data)
		..()
		recipe_name = cook_data["recipe"]
		quality_modifier = cook_data["quality"]
		name = "[quality_modifier >= 1.2 ? "Excellent" : ""] [recipe_name]"
		UpdateIcon()

	proc/UpdateIcon()
		// Icon based on recipe type - use existing food icons from game
		switch(recipe_name)
			if("Vegetable Soup", "Meat Stew")
				icon = 'dmi/64/inven.dmi'
				icon_state = "potatoc"
			if("Baked Bread", "Roasted Vegetables", "Roasted Meat")
				icon = 'dmi/64/inven.dmi'
				icon_state = "carrotc"
			if("Fish Fillet", "Shepherd's Pie")
				icon = 'dmi/64/inven.dmi'
				icon_state = "rasberryc"
			else
				icon = 'dmi/64/inven.dmi'
				icon_state = "potatoc"

	verb/Eat()
		set src in usr.contents
		var/mob/players/M = usr
		
		// Look up recipe in CONSUMABLES
		var/list/food_data = GetFoodData(recipe_name)
		if(!food_data)
			M << "Unknown food type: [recipe_name]"
			return
		
		// Apply quality modifier to nutrition
		var/final_stamina = food_data["stamina"] * quality_modifier
		
		M << "You eat the [name]..."
		// Apply nutrition and stamina recovery
		if(M && M.client)
			// Stamina recovery using existing system variable
			M.stamina = min(M.stamina + final_stamina, 300)  // Standard stamina cap
			
			// XP for cooking quality appreciation
			if(quality_modifier >= 1.2)
				M << "That was delicious! You appreciate the culinary skill."
		
		del src


// ==================== RECIPE INTERFACE ====================

/**
 * Player-facing cooking command
 * Right-click a fire to see cooking options
 */
proc/ShowCookingMenu(mob/players/M, obj/Oven/fire)
	var/list/available_recipes = list()
	// Get player's cooking skill rank (0-10, default 1 if not yet trained)
	var/skill_rank = max(1, GetCookingSkillRank(M))
	
	for(var/recipe_name in RECIPES)
		var/list/recipe = RECIPES[recipe_name]
		if(recipe["skill_req"] <= skill_rank)
			available_recipes[recipe_name] = recipe
	
	if(!available_recipes.len)
		M << "You don't know any recipes yet."
		return
	
	var/choice = input(M, "What would you like to cook?", "Cooking") as null|anything in available_recipes
	if(!choice) return
	
	var/list/recipe = RECIPES[choice]
	
	// Check for ingredients
	var/list/found_ingredients = CheckForIngredients(M, recipe["ingredients"])
	if(!found_ingredients)
		M << "You don't have the required ingredients."
		ShowIngredientsNeeded(M, recipe)
		return
	
	// Start cooking
	if(fire.TryStartCooking(M, found_ingredients, recipe))
		// Remove ingredients from inventory
		RemoveIngredients(M, recipe["ingredients"])


/proc/CheckForIngredients(mob/players/M, list/required)
	var/list/found = list()
	for(var/ingredient in required)
		var/amount_needed = required[ingredient]
		var/amount_found = 0
		
		for(var/obj/item in M.contents)
			if(item.name == ingredient && amount_found < amount_needed)
				found += item
				amount_found++
		
		if(amount_found < amount_needed)
			return null  // Missing ingredients
	
	return found


proc/RemoveIngredients(mob/players/M, list/required)
	for(var/ingredient in required)
		var/amount = required[ingredient]
		for(var/obj/item in M.contents)
			if(item.name == ingredient && amount > 0)
				// Simple removal - stack handling optional
				del item
				amount--
				if(amount <= 0) break


proc/ShowIngredientsNeeded(mob/players/M, list/recipe)
	var/msg = "To make [recipe["name"]] you need:\n"
	for(var/ingredient in recipe["ingredients"])
		var/amount = recipe["ingredients"][ingredient]
		msg += "- [amount]x [ingredient]\n"
	M << msg


proc/GetFoodData(recipe_name)
	// Look up nutrition data for this recipe in CONSUMABLES
	// Return scaled nutrition based on ingredients used
	switch(recipe_name)
		if("Vegetable Soup")
			return list(
				"nutrition" = 45,
				"stamina" = 30,
				"description" = "Warm vegetable soup"
			)
		if("Roasted Vegetables")
			return list(
				"nutrition" = 50,
				"stamina" = 35,
				"description" = "Delicious roasted vegetables"
			)
		if("Baked Bread")
			return list(
				"nutrition" = 55,
				"stamina" = 50,
				"description" = "Fresh baked bread"
			)
		if("Roasted Meat")
			return list(
				"nutrition" = 65,
				"stamina" = 40,
				"description" = "Tender roasted meat"
			)
		if("Meat Stew")
			return list(
				"nutrition" = 70,
				"stamina" = 60,
				"description" = "Hearty meat stew"
			)
		if("Fish Fillet")
			return list(
				"nutrition" = 60,
				"stamina" = 35,
				"description" = "Flaky fish fillet"
			)
		if("Shepherd's Pie")
			return list(
				"nutrition" = 80,
				"stamina" = 65,
				"description" = "Rich shepherd's pie"
			)
		else
			return list(
				"nutrition" = 40,
				"stamina" = 30
			)


// ==================== RECIPE DISCOVERY INTEGRATION ====================

/**
 * Check if player has discovered a cooking recipe
 * Uses the character.recipe_state system for persistence
 */
proc/IsCookingRecipeDiscovered(mob/players/M, recipe_name)
	if(!M || !M.character) return 0
	if(!M.character.recipe_state) return 0
	return M.character.recipe_state.IsRecipeDiscovered(recipe_name)

/**
 * Unlock a cooking recipe for player
 * Integrates with existing phase 4 recipe state system
 */
proc/DiscoverCookingRecipe(mob/players/M, recipe_name)
	if(!M || !M.character) return 0
	if(!M.character.recipe_state)
		M.character.recipe_state = new /datum/recipe_state()
	
	M.character.recipe_state.DiscoverRecipe(recipe_name)
	
	if(M)
		var/list/recipe = RECIPES[recipe_name]
		if(recipe)
			M << "<b><color=#FFD700>★ RECIPE DISCOVERED: [recipe["name"]] ★</color></b>"
			M << "A new cooking recipe has been added to your knowledge!"
	
	return 1


// ==================== INITIALIZATION ====================

var/global/cooking_initialized = 0

proc/InitializeCooking()
	if(cooking_initialized) return
	InitializeRecipes()
	cooking_initialized = 1
