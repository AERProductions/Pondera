/**
 * SEARCHABLE RECIPE DATABASE SYSTEM
 * ==================================
 * Provides in-game recipe browser with advanced search, filtering, and prerequisite visualization
 * Integrated with TechTreeSystem.dm and existing KnowledgeBase.dm
 * 
 * Started: 12-11-25 5:30PM
 * Focus: Player can search "bread" and see recipe + tech tree path to unlock it
 */

/datum/recipe_browser
	var
		list/all_recipes = list()     // All recipes from KNOWLEDGE registry
		list/search_results = list()  // Current search results
		list/filter_category = list() // Category filter (tools, weapons, etc)
		
		search_text = ""              // Current search string
		page = 1                      // Current page of results
		page_size = 20                // Results per page

/datum/recipe_browser/New()
	PopulateRecipes()

/datum/recipe_browser/proc/PopulateRecipes()
	/**
	 * Load all recipes from KNOWLEDGE global registry
	 * KNOWLEDGE format: recipe_key -> /datum/recipe_entry object
	 */
	
	if(!islist(KNOWLEDGE))
		return FALSE
	
	for(var/recipe_key in KNOWLEDGE)
		var/datum/recipe_entry/recipe = KNOWLEDGE[recipe_key]
		if(!istype(recipe))
			continue
		
		all_recipes += recipe
	
	return TRUE

/datum/recipe_browser/proc/Search(search_string, mob/player)
	/**
	 * Search recipes by name, description, category, or ingredients
	 * Returns filtered and paginated results
	 */
	
	search_text = search_string
	search_results = list()
	page = 1
	
	if(!search_string || search_string == "")
		// No search - show all discovered recipes
		for(var/datum/recipe_entry/recipe in all_recipes)
			if(!recipe.is_hidden)
				search_results += recipe
	else
		// Search by name, description, or category
		var/search_lower = lowertext(search_string)
		
		for(var/datum/recipe_entry/recipe in all_recipes)
			if(recipe.is_hidden)
				continue
			
			if(findtext(lowertext(recipe.name), search_lower))
				search_results += recipe
				continue
			
			if(findtext(lowertext(recipe.description), search_lower))
				search_results += recipe
				continue
			
			if(findtext(lowertext(recipe.category), search_lower))
				search_results += recipe
				continue
			
			// Search inputs/ingredients
			for(var/ingredient in recipe.inputs)
				if(findtext(lowertext(ingredient), search_lower))
					search_results += recipe
					break
	
	// Apply category filter
	if(length(filter_category) > 0)
		var/list/filtered = list()
		for(var/datum/recipe_entry/recipe in search_results)
			if(recipe.category in filter_category)
				filtered += recipe
		search_results = filtered
	
	return search_results

/datum/recipe_browser/proc/ShowResults(mob/player)
	/**
	 * Display recipe search results to player
	 * Show recipe name, description, ingredients, and discovery status
	 */
	
	if(!ismob(player))
		return
	
	var/start_idx = (page - 1) * page_size + 1
	var/end_idx = min(page * page_size, length(search_results))
	var/total_pages = ceil(length(search_results) / page_size)
	
	var/output = "<html><head><title>Recipe Browser</title></head><body>"
	output += "<hr><b>RECIPE SEARCH RESULTS</b><hr>"
	output += "Search: '[search_text]' | Page [page]/[total_pages]<br>"
	output += "<i>[length(search_results)] recipe(s) found</i><br><br>"
	
	for(var/i = start_idx; i <= end_idx; i++)
		var/datum/recipe_entry/recipe = search_results[i]
		if(!recipe)
			continue
		
		// Check if player has discovered this recipe
		var/discovered = CheckIfDiscovered(player, recipe.recipe_key)
		var/status = discovered ? "✓" : "◯"
		
		output += "<font color='#2196F3'>[status] <b>[recipe.name]</b></font><br>"
		output += "&nbsp;&nbsp;<i>[recipe.description]</i><br>"
		
		if(length(recipe.inputs) > 0)
			output += "&nbsp;&nbsp;<b>Ingredients:</b> [English(recipe.inputs)]<br>"
		
		output += "&nbsp;&nbsp;<b>Category:</b> [recipe.category]<br>"
		
		if(recipe.workstation_type != "none")
			output += "&nbsp;&nbsp;<b>Requires:</b> [recipe.workstation_type]<br>"
		
		if(recipe.skill_level_min > 0)
			output += "&nbsp;&nbsp;<b>Skill Level:</b> [recipe.skill_level_min]<br>"
		
		// Show tech tree path if available
		var/datum/tech_tree_node/node = FindNodeForRecipe(recipe.name)
		if(node && !discovered)
			output += "&nbsp;&nbsp;<font color='#FF9800'><b>Unlock Path:</b> [GetPrerequisitePath(node)]</font><br>"
		
		output += "<br>"
	
	output += "<hr>"
	if(page > 1)
		var/prev_page = page - 1
		output += "<a href='?page=1'>FIRST PAGE</a> | "
		output += "<a href='?page=" + prev_page + "'>PREV</a> | "
	
	output += "Page " + page + "/" + total_pages
	
	if(page < total_pages)
		var/next_page = page + 1
		output += " | <a href='?page=" + next_page + "'>NEXT</a> | "
		output += "<a href='?page=" + total_pages + "'>LAST PAGE</a>"
	
	output += "<hr></body></html>"
	player << output

/datum/recipe_browser/proc/CheckIfDiscovered(mob/player, recipe_key)
	/**
	 * Check if player has discovered this recipe
	 * Uses character.recipe_state flags
	 */
	
	if(!ismob(player))
		return FALSE
	
	// Try character data
	if("character" in player.vars)
		var/datum/character_data/char = player.vars["character"]
		if(istype(char) && "recipe_state" in char.vars)
			var/datum/recipe_state/rs = char.vars["recipe_state"]
			if(istype(rs))
				// Try dynamic var check
				var/var_name = "discovered_[recipe_key]"
				return (var_name in rs.vars)
	
	// Try direct player vars (fallback)
	return "discovered_[recipe_key]" in player.vars

/datum/recipe_browser/proc/FindNodeForRecipe(recipe_name)
	/**
	 * Find tech tree node corresponding to a recipe
	 * Returns the node, or null if not found
	 */
	
	var/datum/tech_tree_renderer/tree = GetTechTree()
	if(!tree)
		return null
	
	for(var/datum/tech_tree_node/node in tree.all_nodes)
		if(findtext(lowertext(node.name), lowertext(recipe_name)))
			return node
	
	return null

/datum/recipe_browser/proc/GetPrerequisitePath(datum/tech_tree_node/node)
	/**
	 * Get human-readable path of prerequisites
	 * e.g. "Rock → Stone Hammer → Iron Hammer → Forge → Anvil"
	 */
	
	if(!istype(node))
		return "Unknown"
	
	var/path = "[node.name]"
	
	// Walk backwards through prerequisites
	var/datum/tech_tree_node/current = node
	var/steps = 0
	
	while(length(current.prerequisites) > 0 && steps < 10)
		var/datum/tech_tree_node/prereq = current.prerequisites[1]
		path = "[prereq.name] → " + path
		current = prereq
		steps++
	
	return path

/datum/recipe_browser/proc/ShowDetails(mob/player, recipe_key)
	/**
	 * Show detailed information about a specific recipe
	 */
	
	if(!ismob(player))
		return
	
	var/datum/recipe_entry/recipe = KNOWLEDGE[recipe_key]
	if(!istype(recipe))
		return
	
	var/output = "<html><head><title>[recipe.name]</title></head><body>"
	output += "<hr><b>[recipe.name]</b><hr>"
	
	output += "[recipe.description]<br><br>"
	
	output += "<b>Category:</b> [recipe.category]<br>"
	
	if(recipe.workstation_type != "none")
		output += "<b>Requires:</b> [recipe.workstation_type]<br>"
	
	if(length(recipe.inputs) > 0)
		output += "<br><b>Ingredients Needed:</b><br>"
		for(var/ingredient in recipe.inputs)
			output += "&nbsp;&nbsp;• [ingredient]<br>"
	
	if(length(recipe.outputs) > 0)
		output += "<br><b>Produces:</b><br>"
		for(var/output_item in recipe.outputs)
			output += "&nbsp;&nbsp;• [output_item]<br>"
	
	if(recipe.skill_level_min > 0)
		output += "<br><b>Skill Requirement:</b> Level [recipe.skill_level_min]<br>"
	
	if(length(recipe.seasons_allowed) > 0)
		output += "<br><b>Available Seasons:</b> [English(recipe.seasons_allowed)]<br>"
	
	if(length(recipe.biomes_allowed) > 0)
		output += "<br><b>Available Biomes:</b> [English(recipe.biomes_allowed)]<br>"
	
	// Tech tree information
	var/datum/tech_tree_node/node = FindNodeForRecipe(recipe.name)
	if(node)
		output += "<br><b>Tech Tree Path:</b> [GetPrerequisitePath(node)]<br>"
	
	output += "<hr>"
	output += "<a href='?action=back'>"
	output += "BACK TO BROWSER"
	output += "</a>"
	output += "</body></html>"
	player << output

// Global instance
var/datum/recipe_browser/recipe_browser_system = null

/proc/InitializeRecipeBrowser()
	if(recipe_browser_system)
		return recipe_browser_system
	recipe_browser_system = new /datum/recipe_browser()
	return recipe_browser_system

/proc/GetRecipeBrowser()
	if(!recipe_browser_system)
		InitializeRecipeBrowser()
	return recipe_browser_system

// Helper for displaying lists in english
/proc/English(list/items)
	if(!items || length(items) == 0)
		return "none"
	
	if(length(items) == 1)
		return items[1]
	
	if(length(items) == 2)
		return "[items[1]] and [items[2]]"
	
	var/result = ""
	for(var/i = 1; i < length(items); i++)
		result += "[items[i]], "
	result += "and [items[length(items)]]"
	return result
