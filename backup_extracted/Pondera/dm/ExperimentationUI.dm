/**
 * ExperimentationUI.dm
 * ====================
 * Phase C.2c: Recipe Experimentation UI System
 * 
 * Provides HTML/DMF interface for recipe experimentation:
 * - Recipe selection from undiscovered recipes
 * - Ingredient selection from inventory
 * - Progress bar showing attempts (0-10)
 * - Visual feedback for success/failure
 * - Quick-start buttons for common combinations
 * 
 * Integration points:
 * - RecipeExperimentationSystem.dm: Core logic
 * - ExperimentationWorkstations.dm: Workstation interaction
 * - BuildingMenuUI.dm: Building UI patterns
 * - CharacterData.dm: Player state persistence
 */

// ============================================================================
// EXPERIMENTATION UI DATUM
// ============================================================================

/datum/experimentation_ui
	/**
	 * Manages experimentation UI for a single player
	 * One per player; created when they access a workstation
	 */
	
	var/mob/players/player = null
	var/workstation_type = "cauldron"  // Current workstation: cauldron, forge, workbench
	var/atom/workstation = null         // Reference to physical workstation object
	var/current_recipe = null           // Recipe being experimented with
	var/list/selected_ingredients = list()  // Selected ingredients for current attempt
	
	proc/Initialize(mob/players/P, atom/W, workstation_type_name = "cauldron")
		/**
		 * Initialize UI for a player at a workstation
		 */
		if(!P || !W)
			return FALSE
		
		player = P
		workstation = W
		workstation_type = workstation_type_name
		current_recipe = null
		selected_ingredients = list()
		
		ShowMainMenu()
		return TRUE

	proc/ShowMainMenu()
		/**
		 * Display main experimentation menu
		 * Shows: recipe selection, current progress, quick-start buttons
		 */
		if(!player || !player.client)
			return
		
		var/html = ""
		html += "<html><head><title>Experimentation Workstation</title></head><body>"
		html += "<style>"
		html += "body { background: #1a1a2e; color: #eee; font-family: Arial; margin: 10px; }"
		html += "h1 { color: #FFD700; text-align: center; }"
		html += "h2 { color: #00FF00; margin-top: 20px; }"
		html += ".recipe-box { background: #16213e; border: 1px solid #0f3460; padding: 10px; margin: 5px 0; cursor: pointer; }"
		html += ".recipe-box:hover { background: #0f3460; border-color: #00FF00; }"
		html += ".recipe-box.selected { background: #003d00; border-color: #00FF00; }"
		html += ".progress-bar { background: #444; border: 1px solid #666; width: 100%; height: 20px; margin: 10px 0; }"
		html += ".progress-fill { background: #00FF00; height: 100%; width: 0%; transition: width 0.3s; }"
		html += ".ingredient-list { background: #0f3460; border: 1px solid #666; padding: 10px; margin: 10px 0; max-height: 150px; overflow-y: auto; }"
		html += ".ingredient-item { padding: 5px; margin: 2px 0; background: #16213e; border-left: 2px solid #00FF00; }"
		html += ".button { background: #0f3460; color: #eee; border: 1px solid #00FF00; padding: 8px 15px; margin: 5px; cursor: pointer; }"
		html += ".button:hover { background: #00FF00; color: #000; }"
		html += ".button:disabled { background: #333; border-color: #666; color: #666; cursor: not-allowed; }"
		html += ".stat { color: #FFD700; padding: 5px 0; }"
		html += "</style>"
		
		html += "<h1>[workstation_type] Workstation</h1>"
		html += "<p style='text-align: center;'>Discover new recipes through experimentation</p>"
		
		// Show available recipes
		html += "<h2>Available Recipes to Discover</h2>"
		var/list/available_recipes = GetAvailableRecipes()
		
		if(available_recipes.len == 0)
			html += "<p style='color: #FF6666;'>All recipes discovered! Nothing left to experiment with.</p>"
		else
			for(var/recipe_name in available_recipes)
				var/progress = player.character.experimentation_state.GetExperimentationProgress(recipe_name)
				var/recipe_data = RECIPES[recipe_name]
				var/recipe_desc = recipe_data ? recipe_data["description"] : "Unknown recipe"
				
				var/selected = (recipe_name == current_recipe) ? " selected" : ""
				html += "<div class='recipe-box[selected]'>"
				html += "<b>[recipe_name]</b> - [recipe_desc]<br>"
				html += "<span class='stat'>Attempts: [progress]/10</span>"
				html += "<div class='progress-bar'>"
				html += "<div class='progress-fill' style='width: [progress * 10]%;'></div>"
				html += "</div>"
				html += "<a href='?src=\ref[src];select_recipe=[recipe_name]'>Select</a> | "
				html += "<a href='?src=\ref[src];quick_attempt=[recipe_name]'>Quick Attempt</a>"
				html += "</div>"
		
		// Show selected recipe details
		if(current_recipe)
			ShowRecipeDetails(html)
		
		html += "</body></html>"
		
		player.client << browse(html, "window=experimentation_ui;size=600x700")

	proc/ShowRecipeDetails(var/html = "")
		/**
		 * Display ingredient selection interface for current recipe
		 */
		if(!current_recipe || !RECIPES || !RECIPES[current_recipe])
			return html
		
		var/list/recipe_data = RECIPES[current_recipe]
		var/list/required_ingredients = recipe_data["ingredients"]
		var/list/available_inventory = GetIngredientListFromInventory(player, workstation_type)
		
		html += "<h2>Recipe: [current_recipe]</h2>"
		
		if(recipe_data["description"])
			html += "<p>[recipe_data["description"]]</p>"
		
		html += "<h3>Required Ingredients:</h3>"
		if(required_ingredients && required_ingredients.len > 0)
			for(var/ingredient in required_ingredients)
				var/amount = required_ingredients[ingredient]
				html += "<div class='ingredient-item'>[ingredient] x[amount]</div>"
		else
			html += "<p>No specific ingredients (any combination works)</p>"
		
		html += "<h3>Your Inventory:</h3>"
		if(available_inventory.len == 0)
			html += "<p style='color: #FF6666;'>No valid ingredients for this workstation.</p>"
		else
			html += "<div class='ingredient-list'>"
			for(var/obj/item in available_inventory)
				if(!item) continue
				var/item_name = item.name
				var/selected = (item in selected_ingredients) ? "✓ " : ""
				html += "<a href='?src=\ref[src];toggle_ingredient=\ref[item]'>[selected][item_name]</a><br>"
			html += "</div>"
		
		html += "<h3>Selected Ingredients: [selected_ingredients.len]</h3>"
		html += "<a href='?src=\ref[src];clear_selection'>Clear Selection</a><br><br>"
		
		if(selected_ingredients.len > 0)
			html += "<a class='button' href='?src=\ref[src];attempt_experiment'>Attempt Experiment</a>"
		else
			html += "<a class='button' href='?src=\ref[src];attempt_experiment' disabled>Attempt Experiment (select ingredients)</a>"
		
		return html

	proc/GetAvailableRecipes()
		/**
		 * Get recipes player can experiment with (not yet discovered)
		 */
		if(!player || !RECIPES)
			return list()
		
		var/list/available = list()
		
		for(var/recipe_name in RECIPES)
			// Skip if already discovered
			if(player.character.recipe_state.IsRecipeDiscovered(recipe_name))
				continue
			
			// Skip if doesn't fit this workstation
			var/list/recipe_data = RECIPES[recipe_name]
			var/recipe_type = recipe_data["type"]
			
			switch(workstation_type)
				if("cauldron")
					if(recipe_type != "cooking" && recipe_type != "food")
						continue
				if("forge")
					if(recipe_type != "smithing" && recipe_type != "smelting")
						continue
				if("workbench")
					if(recipe_type != "crafting" && recipe_type != "tools")
						continue
			
			available[recipe_name] = TRUE
		
		return available

	proc/HandleUIClick(href, list/href_list)
		/**
		 * Handle UI clicks and interactions
		 */
		if(href_list["select_recipe"])
			current_recipe = href_list["select_recipe"]
			selected_ingredients = list()
			ShowMainMenu()
		
		if(href_list["quick_attempt"])
			current_recipe = href_list["quick_attempt"]
			selected_ingredients = list()
			// Auto-select first N ingredients that match recipe
			var/list/inventory = GetIngredientListFromInventory(player, workstation_type)
			var/list/recipe_data = RECIPES[current_recipe]
			var/list/required = recipe_data["ingredients"]
			
			if(required)
				for(var/ingredient_key in required)
					for(var/obj/item in inventory)
						if(findtext(item.type, ingredient_key))
							selected_ingredients += item
							break
			
			// Attempt with selected ingredients
			AttemptExperiment()
		
		if(href_list["toggle_ingredient"])
			var/obj/item = locate(href_list["toggle_ingredient"])
			if(item && (item in player.contents))
				if(item in selected_ingredients)
					selected_ingredients -= item
				else
					selected_ingredients += item
			ShowMainMenu()
		
		if(href_list["clear_selection"])
			selected_ingredients = list()
			ShowMainMenu()
		
		if(href_list["attempt_experiment"])
			AttemptExperiment()

	proc/AttemptExperiment()
		/**
		 * Execute experimentation with selected ingredients
		 */
		if(!current_recipe || !player || selected_ingredients.len == 0)
			return
		
		// Check workstation cooldown
		if(!IsWorkstationReady(workstation))
			player << "The workstation is still cooling down..."
			return
		
		// Perform experiment
		var/result = AttemptRecipeExperimentation(player, current_recipe, selected_ingredients)
		
		// Show feedback
		if(result)
			ShowExperimentSuccess()
		else
			ShowExperimentFailure()
		
		// Reset UI
		current_recipe = null
		selected_ingredients = list()
		UpdateWorkstationCooldown(workstation)
		
		// Refresh menu
		spawn(20)
			ShowMainMenu()

	proc/ShowExperimentSuccess()
		/**
		 * Display success animation and message
		 */
		if(!player || !player.client)
			return
		
		var/html = "<html><body style='background: #1a1a2e; color: #00FF00; font-size: 18px; text-align: center;'>"
		html += "<h1 style='color: #FFD700;'>🎉 DISCOVERY!</h1>"
		html += "<p>You've successfully discovered a new recipe!</p>"
		html += "<p style='font-size: 24px; color: #00FF00;'>Bonus XP Awarded!</p>"
		html += "</body></html>"
		
		player.client << browse(html, "window=experiment_feedback;size=400x200")
		spawn(30)
			if(player && player.client)
				player.client << browse(null, "window=experiment_feedback")

	proc/ShowExperimentFailure()
		/**
		 * Display failure message with progress
		 */
		if(!player || !player.client)
			return
		
		var/progress = player.character.experimentation_state.GetExperimentationProgress(current_recipe)
		var/remaining = 10 - progress
		
		var/html = "<html><body style='background: #1a1a2e; color: #FF6666; font-size: 16px; text-align: center;'>"
		html += "<h2>Experiment Failed</h2>"
		html += "<p>The ingredients don't seem to work together.</p>"
		html += "<p>Attempts: [progress]/10</p>"
		if(remaining > 0)
			html += "<p style='color: #FFD700;'>[remaining] attempts until auto-unlock</p>"
		else
			html += "<p style='color: #00FF00;'>This recipe will be unlocked next attempt!</p>"
		html += "</body></html>"
		
		player.client << browse(html, "window=experiment_feedback;size=400x200")
		spawn(30)
			if(player && player.client)
				player.client << browse(null, "window=experiment_feedback")

// ============================================================================
// WORKSTATION INTERACTION
// ============================================================================

// Note: Experiment verbs are defined in ExperimentationWorkstations.dm
// This file provides the UI implementation for those verbs

// ============================================================================
// HELPER PROCS FOR UI
// ============================================================================

/proc/GetIngredientListFromInventory(mob/players/player, workstation_type)
	/**
	 * Extract valid ingredients from player inventory
	 * (moved from RecipeExperimentationSystem.dm for code clarity)
	 */
	if(!player)
		return list()
	
	var/list/valid_ingredients = list()
	
	for(var/obj/item in player.contents)
		if(!item)
			continue
		
		// Check if item is valid ingredient for this workstation
		switch(workstation_type)
			if("cauldron", "cooking")
				// Cooking ingredients: consumables, vegetables, meats, etc.
				// Accept any item that isn't a tool or weapon
				if(!istype(item, /obj/items/tools) && !istype(item, /obj/items/weapons))
					valid_ingredients += item
			
			if("forge", "smithing")
				// Smithing: ores, ingots, metals
				if(istype(item, /obj/items/Ore) || istype(item, /obj/items/Ingots) || istype(item, /obj/items/thermable))
					valid_ingredients += item
			
			if("workbench", "crafting")
				// General crafting: crafting items, created items
				if(istype(item, /obj/items/Crafting) || istype(item, /obj/items/tools))
					valid_ingredients += item
	
	return valid_ingredients
