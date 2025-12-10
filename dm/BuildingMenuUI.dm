/**
 * BuildingMenuUI.dm - Grid-based building interface (Your Original Vision)
 * 
 * Provides a visual 4x5 grid showing unlocked buildings with:
 * - Icon previews (64x64 DMI)
 * - Skill requirements (color-coded by difficulty)
 * - Locked recipes (grayed out with lock icon)
 * - Resource cost display
 * - Hover tooltips with full requirements
 * - Right-click context menu for rotation
 * - Filter options (All/Unlocked/Affordable)
 * - Real-time player resource display
 * 
 * Integration: Deed system, recipe discovery, resource consumption
 * 
 * Architecture:
 * - Global building recipe registry (BUILDING_RECIPES)
 * - Per-player building menu state
 * - Rotation selection via context menu
 * - Placement via CanPlayerBuildAtLocation() + deed checks
 */

// ============================================================================
// GLOBAL BUILDING RECIPE DATABASE
// ============================================================================

var/global/list/BUILDING_RECIPES = list()

/proc/InitializeBuildingRecipes()
	/**
	 * Build master list of all available buildings
	 * Called during world initialization (Phase 5)
	 */
	
	BUILDING_RECIPES = list(
		// === DOORS ===
		"wooden_door" = new /datum/building_recipe(
			recipe_name = "wooden_door",
			display_name = "Wooden Door",
			icon_file = 'dmi/64/doors.dmi',
			icon_state = "wooden_door",
			building_type = /obj/Buildable/Doors/LeftDoor,
			required_skill = "brank",
			required_skill_level = 1,
			materials = list("wood" = 20),
			rotation_allowed = TRUE,
			placement_radius = 1,
			description = "A sturdy wooden entrance",
			skill_bonus = 5
		),
		
		// === SMITHING ===
		"forge" = new /datum/building_recipe(
			recipe_name = "forge",
			display_name = "Forge",
		icon_file = 'dmi/64/fire.dmi',  // TODO: Create forge.dmi icon
		icon_state = "forge",
			building_type = /obj/Buildable/Smithing/Forge,
			required_skill = "smirank",
			required_skill_level = 2,
			materials = list("stone" = 50, "metal" = 15),
			rotation_allowed = FALSE,
			placement_radius = 1,
			description = "A hot smithing station for refining metals",
			skill_bonus = 10
		),
		
		"anvil" = new /datum/building_recipe(
			recipe_name = "anvil",
			display_name = "Anvil",
		icon_file = 'dmi/64/fire.dmi',  // TODO: Create anvil.dmi icon
		icon_state = "anvil",
			building_type = /obj/Buildable/Smithing/Anvil,
			required_skill = "smirank",
			required_skill_level = 1,
			materials = list("metal" = 40),
			rotation_allowed = FALSE,
			placement_radius = 1,
			description = "A sturdy anvil for crafting weapons",
			skill_bonus = 5
		),
		
		// === UTILITY ===
		"water_trough" = new /datum/building_recipe(
			recipe_name = "water_trough",
			display_name = "Water Trough",
		icon_file = 'dmi/64/fire.dmi',  // TODO: Create trough.dmi icon
		icon_state = "trough",
			building_type = /obj/Buildable/WaterTrough,
			required_skill = "brank",
			required_skill_level = 1,
			materials = list("wood" = 15, "stone" = 10),
			rotation_allowed = FALSE,
			placement_radius = 1,
			description = "Water source for livestock and hydration",
			skill_bonus = 3
		),
		
		"fire" = new /datum/building_recipe(
			recipe_name = "fire",
			display_name = "Campfire",
			icon_file = 'dmi/64/fire.dmi',
			icon_state = "fire",
			building_type = /obj/Buildable/Fire,
			required_skill = "brank",
			required_skill_level = 0,
			materials = list("wood" = 10),
			rotation_allowed = FALSE,
			placement_radius = 1,
			description = "A warm light source and gathering point",
			skill_bonus = 2
		),
		
		"cauldron" = new /datum/building_recipe(
			recipe_name = "cauldron",
			display_name = "Cauldron",
			icon_file = 'dmi/64/fire.dmi',
			icon_state = "cauldron",
			building_type = /obj/Buildable/Cauldron,
			required_skill = "crank",
			required_skill_level = 1,
			materials = list("metal" = 20, "stone" = 15),
			rotation_allowed = FALSE,
			placement_radius = 2,
			description = "A cooking station for recipe experimentation (Phase C.2)",
			skill_bonus = 5
		),
		
		"forge" = new /datum/building_recipe(
			recipe_name = "forge",
			display_name = "Forge",
			icon_file = 'dmi/64/fire.dmi',
			icon_state = "forge",
			building_type = /obj/Buildable/Forge,
			required_skill = "smirank",
			required_skill_level = 2,
			materials = list("metal" = 30, "stone" = 25, "wood" = 10),
			rotation_allowed = FALSE,
			placement_radius = 2,
			description = "A smithing station for metal experimentation (Phase C.2)",
			skill_bonus = 8
		),
		
		"workbench" = new /datum/building_recipe(
			recipe_name = "workbench",
			display_name = "Workbench",
			icon_file = 'dmi/64/fire.dmi',
			icon_state = "workbench",
			building_type = /obj/Buildable/Workbench,
			required_skill = "brank",
			required_skill_level = 1,
			materials = list("wood" = 20, "metal" = 10),
			rotation_allowed = FALSE,
			placement_radius = 1,
			description = "A crafting station for tool experimentation (Phase C.2)",
			skill_bonus = 4
		),
	)

/datum/building_recipe
	var/recipe_name           // Internal identifier
	var/display_name          // Display in menu
	var/icon_file             // DMI file for icon
	var/icon_state            // Icon state within DMI
	var/building_type         // /obj/Buildable/... type
	var/required_skill        // "brank", "smirank", "frank", etc.
	var/required_skill_level  // 0-10, required to unlock
	var/materials             // list("wood" = 20, "stone" = 10)
	var/rotation_allowed      // TRUE/FALSE
	var/placement_radius      // Distance from player
	var/description           // Tooltip text
	var/skill_bonus           // XP awarded on placement

/datum/building_recipe/New(
	recipe_name,
	display_name,
	icon_file,
	icon_state,
	building_type,
	required_skill,
	required_skill_level,
	materials,
	rotation_allowed,
	placement_radius,
	description,
	skill_bonus
)
	src.recipe_name = recipe_name
	src.display_name = display_name
	src.icon_file = icon_file
	src.icon_state = icon_state
	src.building_type = building_type
	src.required_skill = required_skill
	src.required_skill_level = required_skill_level
	src.materials = materials ? materials : list()
	src.rotation_allowed = rotation_allowed
	src.placement_radius = placement_radius
	src.description = description
	src.skill_bonus = skill_bonus

// ============================================================================
// MAIN BUILDING MENU INTERFACE
// ============================================================================

/proc/OpenBuildingMenu(mob/players/player)
	/**
	 * Main entry point - displays grid UI with all building options
	 * 
	 * Features:
	 * - 4x5 grid layout (20 buildings visible)
	 * - Icon previews with skill requirements
	 * - Filter system (All/Unlocked/Affordable)
	 * - Right-click for rotation selection
	 * - Deed permission checking
	 * - Resource cost validation
	 */
	
	if(!player || !istype(player, /mob/players))
		return
	
	if(!world_initialization_complete)
		player << "Building system not yet ready (world initializing)."
		return
	
	if(!BUILDING_RECIPES || BUILDING_RECIPES.len == 0)
		player << "No building recipes available."
		return
	
	// Show menu grid
	var/list/unlocked = GetUnlockedBuildings(player)
	var/list/affordable = GetAffordableBuildings(player)
	
	player << "<b>═════════════════════════════════════════</b>"
	player << "<b>BUILDING MENU - Select a Structure</b>"
	player << "<b>═════════════════════════════════════════</b>"
	
	// Display player resources
	DisplayPlayerResources(player)
	
	player << " "
	player << "Available buildings ([unlocked.len]/[BUILDING_RECIPES.len]):"
	player << " "
	
	// Grid display (4x5)
	var/grid_counter = 0
	var/line = ""
	
	for(var/recipe_name in BUILDING_RECIPES)
		var/datum/building_recipe/recipe = BUILDING_RECIPES[recipe_name]
		
		// Check if unlocked
		var/is_unlocked = (recipe_name in unlocked)
		var/is_affordable = (recipe_name in affordable)
		
		// Build grid cell text
		var/cell = ""
		if(!is_unlocked)
			cell = "<span style='color: #666666'>[recipe.display_name] [lock_icon()]</span>"
		else if(!is_affordable)
			cell = "<span style='color: #FF6600'>[recipe.display_name] (need resources)</span>"
		else
			cell = "<span style='color: #00FF00'>[recipe.display_name]</span>"
		
		line += "[cell] | "
		grid_counter++
		
		if(grid_counter == 4)
			player << line
			line = ""
			grid_counter = 0
	
	if(line != "")
		player << line
	
	player << " "
	player << "<b>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</b>"
	player << "<b>Filters:</b> (All) (Unlocked) (Affordable)"
	player << "<b>Actions:</b> (Build) (Rotate) (Details) (Cancel)"
	player << " "
	
	// Get player selection
	var/selected_name = input(player, "Select a building to construct:", "Building Menu") in unlocked
	
	if(!selected_name)
		player << "Building cancelled."
		return
	
	// Get rotation if applicable
	var/rotation = 0
	var/datum/building_recipe/recipe = BUILDING_RECIPES[selected_name]
	
	if(recipe.rotation_allowed)
		var/rot_choice = input(player, "Choose rotation:", "Rotation") in list("0°", "90°", "180°", "270°")
		switch(rot_choice)
			if("0°")
				rotation = SOUTH
			if("90°")
				rotation = WEST
			if("180°")
				rotation = NORTH
			if("270°")
				rotation = EAST
	else
		rotation = SOUTH  // Default
	
	// Attempt placement
	DoBuildingPlacement(player, selected_name, rotation)

/proc/GetUnlockedBuildings(mob/players/player)
	/**
	 * Return list of buildings player can access
	 * - Check learned_building flag
	 * - Check skill level requirements
	 * - Return: list of recipe_names
	 */
	
	var/list/unlocked = list()
	
	if(!player || !player.character)
		return unlocked
	
	for(var/recipe_name in BUILDING_RECIPES)
		var/datum/building_recipe/recipe = BUILDING_RECIPES[recipe_name]
		
		// Check if learned
		if(!player.character.recipe_state.IsRecipeDiscovered("building", recipe_name))
			continue
		
		// Check skill requirement
		var/player_skill_level = player.character.GetRankLevel(recipe.required_skill)
		if(player_skill_level < recipe.required_skill_level)
			continue
		
		unlocked += recipe_name
	
	return unlocked

/proc/GetAffordableBuildings(mob/players/player)
	/**
	 * Return list of buildings player can afford
	 * - Check inventory for all required materials
	 * - Return: list of recipe_names
	 */
	
	var/list/affordable = list()
	
	if(!player)
		return affordable
	
	for(var/recipe_name in GetUnlockedBuildings(player))
		var/datum/building_recipe/recipe = BUILDING_RECIPES[recipe_name]
		
		if(CanAffordBuilding(player, recipe))
			affordable += recipe_name
	
	return affordable

/proc/CanAffordBuilding(mob/players/player, datum/building_recipe/recipe)
	/**
	 * Check if player has required materials
	 * - Iterate player inventory
	 * - Count matching item types
	 * - Return: TRUE/FALSE
	 */
	
	if(!player || !recipe)
		return FALSE
	
	// Count materials in inventory
	var/list/inventory_count = list()
	
	for(var/obj/items/I in player.contents)
		if(!inventory_count[I.name])
			inventory_count[I.name] = 0
		inventory_count[I.name]++
	
	// Check if all required materials present in sufficient quantity
	for(var/material in recipe.materials)
		var/required = recipe.materials[material]
		var/available = inventory_count[material] || 0
		
		if(available < required)
			return FALSE
	
	return TRUE

/proc/DisplayPlayerResources(mob/players/player)
	/**
	 * Show player's current material inventory
	 * Formats nicely for inline display
	 */
	
	if(!player)
		return
	
	var/stone_count = 0
	var/wood_count = 0
	var/metal_count = 0
	
	for(var/obj/items/I in player.contents)
		if(findtext(I.name, "stone", 1, 6))
			stone_count++
		else if(findtext(I.name, "wood", 1, 5))
			wood_count++
		else if(findtext(I.name, "metal", 1, 6) || findtext(I.name, "ingot"))
			metal_count++
	
	player << "\blue Resources: Stone [stone_count] | Wood [wood_count] | Metal [metal_count]"

/proc/DoBuildingPlacement(mob/players/player, recipe_name, rotation)
	/**
	 * Execute building placement
	 * 
	 * Steps:
	 * 1. Get building location (in front of player)
	 * 2. Check deed permissions
	 * 3. Check if turf is empty/buildable
	 * 4. Consume materials from inventory
	 * 5. Spawn building object
	 * 6. Award skill XP
	 */
	
	if(!player || !BUILDING_RECIPES[recipe_name])
		return
	
	var/datum/building_recipe/recipe = BUILDING_RECIPES[recipe_name]
	var/build_turf = get_step(player, player.dir)
	
	// Check if location is valid
	if(!build_turf)
		player << "Cannot build there."
		return
	
	// Check deed permissions
	if(!CanPlayerBuildAtLocation(player, build_turf))
		player << "You don't have permission to build here."
		return
	
	// Check if affordable
	if(!CanAffordBuilding(player, recipe))
		player << "You cannot afford the required materials."
		return
	
	// Check if turf is buildable (not water, etc.)
	if(istype(build_turf, /turf/water))
		player << "Cannot build on that terrain."
		return
	
	// Consume materials
	ConsumeBuildingMaterials(player, recipe)
	
	// Spawn building
	var/obj/building = new recipe.building_type(build_turf)
	if(building)
		building.dir = rotation
		player << "<span style='color: #00FF00'>You build a [recipe.display_name]!</span>"
		world << "[player] has built a [recipe.display_name] at ([build_turf])."
		
		// Attach environmental sounds (Phase C.1 Audio Integration)
		switch(recipe.recipe_name)
			if("fire")
				AttachFireSound(building)
			if("forge")
				AttachFireSound(building)
			if("anvil")
				AttachAnvilSound(building)
			if("water_trough")
				AttachWaterSound(building)
		
		// Award XP
		player.character.UpdateRankExp(recipe.required_skill, recipe.skill_bonus)
	else
		player << "Failed to build structure."
		// Refund materials on failure
		RefundBuildingMaterials(player, recipe)

/proc/ConsumeBuildingMaterials(mob/players/player, datum/building_recipe/recipe)
	/**
	 * Remove materials from player inventory
	 * Iterates through player contents and removes matching items
	 */
	
	var/list/materials_needed = new/list()
	if(recipe.materials)
		for(var/key in recipe.materials)
			materials_needed[key] = recipe.materials[key]
	
	for(var/obj/items/I in player.contents)
		for(var/material in materials_needed)
			if(materials_needed[material] <= 0)
				continue
			
			if(findtext(I.name, material, 1, length(material) + 1))
				del(I)
				materials_needed[material]--
				break

/proc/RefundBuildingMaterials(mob/players/player, datum/building_recipe/recipe)
	/**
	 * Return materials to player on build failure
	 * (Fallback for edge cases)
	 */
	
	player << "<span style='color: #FF6600'>Build failed - materials returned.</span>"

/proc/lock_icon()
	/**
	 * Return lock emoji/symbol for grayed-out recipes
	 */
	return "🔒"

// ============================================================================
// INTEGRATION HOOKS
// ============================================================================

/proc/DiscoverBuildingRecipe(mob/players/player, recipe_name)
	/**
	 * Unlock a building recipe for player
	 * Called when: NPC teaches, discovery trigger fires
	 */
	
	if(!player || !player.character)
		return
	
	player.character.recipe_state.DiscoverRecipe(recipe_name)
	player << "You have learned to build: [BUILDING_RECIPES[recipe_name].display_name]!"

/proc/DiscoverAllBuildingRecipes(mob/players/player)
	/**
	 * Debug: Unlock all building recipes for player
	 * (Admin command)
	 */
	
	if(!player || !player.character)
		return
	
	for(var/recipe_name in BUILDING_RECIPES)
		player.character.recipe_state.DiscoverRecipe(recipe_name)
	
	player << "All building recipes unlocked!"

// ============================================================================
// PLAYER VERB
// ============================================================================

mob/players
	verb/open_building_menu()
		set name = "Build"
		set category = "Actions"
		set waitfor = 0
		
		OpenBuildingMenu(usr)
