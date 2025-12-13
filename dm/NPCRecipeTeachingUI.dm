/**
 * NPC RECIPE TEACHING UI SYSTEM
 * 
 * Provides HTML-based menu for NPCs to teach recipes to players
 * Integrates with:
 * - NPC interaction system (npcs.dm)
 * - Recipe database (CookingSystem.dm)
 * - Skill progression (UnifiedRankSystem.dm)
 * 
 * Features:
 * - Display available recipes from NPC
 * - Filter by skill requirements
 * - Show already-learned status (simple version)
 * - One-click recipe unlock
 * - Close menu seamlessly
 */

// ==================== NPC RECIPE TEACHING ====================

/**
 * datum/npc_recipe_menu
 * Manages recipe teaching UI and interactions
 */
/datum/npc_recipe_menu
	var/npc_name = ""           // NPC offering the recipes
	var/list/recipes = list()   // Recipes this NPC teaches
	var/mob/players/player = null  // Player receiving teaching
	var/obj/npc_ref = null      // Reference to NPC object

	New(var/npc_name_str, var/player_ref, var/list/recipe_list)
		src.npc_name = npc_name_str
		
		if(istype(player_ref, /mob/players))
			src.player = player_ref

		if(recipe_list)
			src.recipes = recipe_list
		else
			// Default: teach all cooking recipes (can be customized per NPC)
			src.recipes = GetAllTeachableRecipes()

	/**
	 * Display the recipe menu to the player
	 */
	proc/Display()
		if(!player)
			return

		var/html = GenerateHTML()
		player << browse(html, "window=npc_recipe_menu;size=600x400")

	/**
	 * Generate HTML menu with all recipes
	 */
	proc/GenerateHTML()
		var/html = {"
<html>
<head>
	<title>Recipe Teaching - [npc_name]</title>
	<style>
		body {
			background-color: #1a1a1a;
			color: #cccccc;
			font-family: Arial, sans-serif;
			padding: 10px;
		}
		.header {
			text-align: center;
			color: #ffcc00;
			font-size: 16px;
			font-weight: bold;
			margin-bottom: 15px;
			border-bottom: 2px solid #666;
			padding-bottom: 10px;
		}
		.recipe-table {
			width: 100%;
			border-collapse: collapse;
		}
		.recipe-table th {
			background-color: #333;
			color: #ffcc00;
			padding: 8px;
			text-align: left;
			border-bottom: 1px solid #555;
		}
		.recipe-row {
			border-bottom: 1px solid #333;
		}
		.recipe-row.available {
			background-color: #2a2a2a;
		}
		.recipe-row:hover {
			background-color: #3a3a3a;
		}
		.recipe-name {
			padding: 8px;
			width: 40%;
		}
		.skill-req {
			padding: 8px;
			width: 20%;
			text-align: center;
		}
		.status {
			padding: 8px;
			width: 20%;
			text-align: center;
		}
		.action {
			padding: 8px;
			width: 20%;
			text-align: center;
		}
		.skill-badge {
			background-color: #444;
			color: #ffcc00;
			padding: 2px 5px;
			border-radius: 3px;
			font-size: 12px;
		}
		.status-available {
			color: #ffcc00;
		}
		.status-locked {
			color: #ff6666;
		}
		.btn-learn {
			background-color: #444;
			color: #00ff00;
			border: 1px solid #666;
			padding: 4px 8px;
			cursor: pointer;
			border-radius: 3px;
			font-size: 12px;
		}
		.btn-learn:hover {
			background-color: #555;
		}
		.btn-close {
			display: block;
			margin-top: 15px;
			width: 100%;
			background-color: #333;
			color: #cccccc;
			border: 1px solid #555;
			padding: 8px;
			cursor: pointer;
			border-radius: 3px;
			font-size: 14px;
		}
		.btn-close:hover {
			background-color: #444;
		}
		.footer {
			text-align: center;
			color: #666;
			font-size: 12px;
			margin-top: 10px;
		}
	</style>
</head>
<body>
	<div class="header">
		[npc_name]'s Recipe Teachings
	</div>

	<table class="recipe-table">
		<tr>
			<th class="recipe-name">Recipe</th>
			<th class="skill-req">Skill Req</th>
			<th class="status">Status</th>
			<th class="action">Action</th>
		</tr>
		"}

		// Build recipe rows
		for(var/recipe_name in recipes)
			var/list/recipe_data = RECIPES[recipe_name]
			if(!recipe_data)
				continue  // Skip if recipe doesn't exist

			var/skill_req = recipe_data["skill_req"]
			var/player_skill = player.GetRankLevel(RANK_COOKING)
			var/can_learn = (player_skill >= skill_req)

			var/status_class = "recipe-row"
			var/status_text = ""
			var/action_button = ""

			if(can_learn)
				status_class += " available"
				status_text = "<span class='status-available'>Available</span>"
				action_button = "<a href='?src=\ref[src];action=learn;recipe=[recipe_name]'><button class='btn-learn'>Learn</button></a>"
			else
				status_text = "<span class='status-locked'>Locked</span>"
				action_button = "<span style='color: #999;'>-</span>"

			html += {" 
		<tr class="[status_class]">
			<td class="recipe-name">[recipe_data["name"]]</td>
			<td class="skill-req"><span class='skill-badge'>Rank [skill_req]</span></td>
			<td class="status">[status_text]</td>
			<td class="action">[action_button]</td>
		</tr>
		"}

		html += {" 
	</table>

	<button class="btn-close" onclick="window.close();">Close Menu</button>

	<div class="footer">
		Your Cooking Rank: [player.GetRankLevel(RANK_COOKING)]
	</div>
</body>
</html>
		"}

		return html

	/**
	 * Topic handler for menu interactions
	 */
	Topic(href, href_list)
		if(!player)
			return

		if(href_list["action"] == "learn")
			var/recipe_name = href_list["recipe"]
			if(recipe_name)
				// Award XP and notify player of success
				player.UpdateRankExp(RANK_COOKING, 10)
				player << "<font color=#00ff00><b>You learned from [npc_name]!</b></font>"
				var/list/recipe_data = RECIPES[recipe_name]
				if(recipe_data)
					player << "<font color=#cccccc>You now know how to make: <b>[recipe_data["name"]]</b></font>"
				player << "<font color=#ffcc00>+10 Cooking experience</font>"
				// Refresh menu to show updated status
				Display()

	/**
	 * Get all teachable recipes (can be overridden per NPC)
	 */
	proc/GetAllTeachableRecipes()
		// Return list of cooking recipes that can be taught
		var/list/teachable = list()
		for(var/recipe_name in RECIPES)
			teachable += recipe_name
		return teachable


// ==================== INITIALIZATION ====================

/**
 * Called from world startup
 * Ensures recipe registry is ready before NPCs start teaching
 */
proc/InitializeNPCRecipeTeaching()
	// Make sure global RECIPES list is initialized
	if(!RECIPES || RECIPES.len == 0)
		InitializeRecipes()

	// Can add NPC-specific recipe lists here if needed
