/**
 * PONDERA TECH TREE UI SYSTEM
 * ==========================
 * Interactive tech tree viewer showing recipe progression
 * - Accessible via /tech tree verb
 * - Shows recipes by tier with filtering options
 * - Click recipes to view details
 */

/mob/players/verb/ViewTechTree()
	set category = "Skills"
	set desc = "View the tech tree of available recipes"
	
	if(!world_initialization_complete)
		alert(src, "The world is still initializing. Please wait.", "Tech Tree Unavailable")
		return
	
	ShowTechTreeUI(src)

/proc/ShowTechTreeUI(mob/players/player)
	/**
	 * Open tech tree interface for a player
	 */
	if(!player || !player.client) return
	
	// Build and display tech tree HTML
	var/html = BuildTechTreeHTML(player)
	
	// Display as a browse window
	if(player.client)
		player << browse(html, "window=techtree;size=1200x800")

/proc/BuildTechTreeHTML(mob/players/player)
	/**
	 * Build the tech tree HTML interface
	 */
	var/html = "<html><head><style>"
	html += "body { background: #1a1a2e; color: #eee; font-family: Arial; margin: 0; padding: 20px; }"
	html += ".header { color: #e94560; font-size: 24px; font-weight: bold; margin-bottom: 20px; }"
	html += ".controls { background: #16213e; padding: 15px; margin-bottom: 20px; border-radius: 8px; border: 1px solid #0f3460; }"
	html += ".recipe-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 15px; }"
	html += ".recipe-card { background: #16213e; border: 2px solid #0f3460; border-radius: 8px; padding: 15px; cursor: pointer; transition: all 0.3s; }"
	html += ".recipe-card:hover { border-color: #e94560; box-shadow: 0 0 15px #e94560; }"
	html += ".recipe-card.locked { opacity: 0.6; border-style: dashed; }"
	html += ".recipe-name { color: #e94560; font-weight: bold; font-size: 14px; margin-bottom: 5px; }"
	html += ".recipe-tier { font-size: 11px; color: #888; text-transform: uppercase; margin-bottom: 8px; }"
	html += ".recipe-category { font-size: 11px; color: #87ceeb; }"
	html += ".recipe-desc { font-size: 12px; color: #bbb; margin-top: 8px; line-height: 1.4; max-height: 60px; overflow: hidden; }"
	html += ".recipe-fire-warning { color: #ff6b6b; font-size: 11px; margin-top: 8px; font-weight: bold; }"
	html += ".tier-section { margin-bottom: 30px; }"
	html += ".tier-header { color: #87ceeb; font-size: 18px; font-weight: bold; margin-bottom: 15px; border-bottom: 2px solid #0f3460; padding-bottom: 10px; }"
	html += "</style></head><body>"
	
	html += "<div class='header'>⚙️ TECH TREE - Recipe Progression</div>"
	
	html += "<div class='controls'>"
	html += "<b>Filters:</b> "
	html += "<a href='?action=filter_all'>All</a> | "
	html += "<a href='?action=filter_tools'>Tools</a> | "
	html += "<a href='?action=filter_weapons'>Weapons</a> | "
	html += "<a href='?action=filter_cooking'>Cooking</a> | "
	html += "<a href='?action=filter_smithing'>Smithing</a> | "
	html += "<a href='?action=filter_shelter'>Shelter</a>"
	html += "</div>"
	
	// Group recipes by tier
	var/list/tiers = list("rudimentary", "basic", "intermediate", "advanced")
	
	for(var/tier in tiers)
		var/list/recipes = GetRecipesByTier(tier)
		if(!recipes || !recipes.len) continue
		
		html += "<div class='tier-section'>"
		html += "<div class='tier-header'>" + uppertext(tier) + " TIER</div>"
		html += "<div class='recipe-grid'>"
		
		for(var/recipe_key in recipes)
			var/datum/recipe_entry/recipe = KNOWLEDGE[recipe_key]
			if(!recipe) continue
			
			var/is_discovered = FALSE
			if(player && player.character && player.character.recipe_state)
				is_discovered = player.character.recipe_state.IsRecipeDiscovered(recipe_key)
			
			var/locked = !is_discovered
			html += "<div class='recipe-card" + (locked ? " locked" : "") + "'>"
			html += "<div class='recipe-name'>" + recipe.name + "</div>"
			html += "<div class='recipe-tier'>[" + uppertext(recipe.tier) + "]</div>"
			
			if(recipe.category != "")
				html += "<div class='recipe-category'>" + uppertext(recipe.category) + "</div>"
			
			html += "<div class='recipe-desc'>" + recipe.description + "</div>"
			
			if(recipe.requires_fire)
				html += "<div class='recipe-fire-warning'>⚠ REQUIRES FIRE</div>"
			
			html += "</div>"
		
		html += "</div>"
		html += "</div>"
	
	html += "</body></html>"
	return html

// GetRecipeEntry moved to KnowledgeBase.dm to avoid duplication
