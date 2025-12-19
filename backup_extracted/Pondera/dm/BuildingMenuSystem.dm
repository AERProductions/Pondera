// ========================================
// Building Menu System
// ========================================
// Rank-gated UI for building construction with hammer
// Modeled after SmithingMenuSystem.dm for consistency
// 
// Architecture:
// - DisplayBuildingMenu(M) → Main menu
// - GetAvailableCategories(M, rank) → Filter categories
// - DisplayCategoryMenu(M, category, rank) → Show items in category
// - GetCategoryItems(category, rank) → Fetch items list
// 

// Main entry point for building menus
/proc/DisplayBuildingMenu(mob/players/M)
	if(!M) return
	if(!istype(M, /mob/players)) return
	
	// Get player rank
	var/rank = 1  // Default rank if character not initialized
	if(M)
		rank = M.GetRankLevel(RANK_BUILDING) || 1
	
	// Check if buildings are available at this rank
	var/list/categories = GetAvailableBuildingCategories(M, rank)
	if(!categories || categories.len == 0)
		M << "<red>You need to improve your building rank to construct buildings.</red>"
		return
	
	var/category_choice = input("What would you like to build?", "Building") in categories
	
	if(!category_choice)
		M << "You cancel your building work."
		return
	
	DisplayBuildingCategoryMenu(M, category_choice, rank)

// Get list of building categories available at player's rank
/proc/GetAvailableBuildingCategories(mob/players/M, rank)
	var/list/available_categories = list()
	var/list/found_categories = list()
	
	// Find unique categories with buildings at this rank
	for(var/building_name in BUILDING_OBJECTS)
		var/building = BUILDING_OBJECTS[building_name]
		if(building["rank_required"] <= rank)
			var/cat = building["category"]
			if(!(cat in found_categories))
				found_categories += cat
	
	// Convert internal names to display names
	if("foundation" in found_categories)
		available_categories["Foundations"] = "foundation"
	if("wall" in found_categories)
		available_categories["Walls"] = "wall"
	if("door" in found_categories)
		available_categories["Doors"] = "door"
	if("window" in found_categories)
		available_categories["Windows"] = "window"
	if("roof" in found_categories)
		available_categories["Roofs"] = "roof"
	if("floor" in found_categories)
		available_categories["Floors"] = "floor"
	if("ramp" in found_categories)
		available_categories["Ramps"] = "ramp"
	if("stairs" in found_categories)
		available_categories["Stairs"] = "stairs"
	if("decoration" in found_categories)
		available_categories["Decorations"] = "decoration"
	if("storage" in found_categories)
		available_categories["Storage"] = "storage"
	if("crafting" in found_categories)
		available_categories["Crafting"] = "crafting"
	
	available_categories["Back"] = null
	available_categories["Cancel"] = null
	
	return available_categories

// Display buildings in a category for selection
/proc/DisplayBuildingCategoryMenu(mob/players/M, category_internal, rank)
	if(!M || !category_internal) return
	
	var/list/buildings = GetBuildingCategoryItems(category_internal, rank)
	
	if(!buildings || buildings.len == 0)
		M << "<yellow>No buildings available in this category at your rank.</yellow>"
		return
	
	var/building_choice = input("What would you like to build?", "Building - [category_internal]") in buildings
	
	if(!building_choice)
		DisplayBuildingMenu(M)
		return
	
	if(building_choice == "Back")
		DisplayBuildingMenu(M)
		return
	
	if(building_choice == "Cancel")
		M << "You cancel your building work."
		return
	
	// User selected a building - attempt to create it
	AttemptBuild(M, building_choice)

// Get list of buildings in a category for this rank
/proc/GetBuildingCategoryItems(category, rank)
	var/list/buildings = list()
	
	for(var/building_name in BUILDING_OBJECTS)
		var/building = BUILDING_OBJECTS[building_name]
		if(building["category"] == category && building["rank_required"] <= rank)
			buildings[building["name"]] = building_name
	
	buildings["Back"] = "back"
	buildings["Cancel"] = "cancel"
	
	return buildings

// Show requirements for a building
/proc/ShowBuildingRequirements(mob/players/M, building_data)
	if(!M || !building_data) return
	
	M << "<yellow>Building: [building_data["name"]]</yellow>"
	M << "<cyan>Requirements:</cyan>"
	
	// Show resources needed
	var/list/resources = building_data["resources_required"]
	if(resources && resources.len > 0)
		for(var/resource in resources)
			var/amount = resources[resource]
			M << "  - [resource] x[amount]"
	else
		M << "  - No materials required"
	
	// Show stamina cost
	M << "<cyan>Stamina cost: [building_data["stamina"]]</cyan>"
	
	// Show rank requirement
	M << "<cyan>Rank required: [building_data["rank_required"]]</cyan>"
	
	// Show XP reward
	M << "<cyan>XP reward: [building_data["xp"]]</cyan>"

// Check if player has all required resources
/proc/CheckBuildingResources(mob/players/M, building_data)
	if(!M || !building_data) return FALSE
	
	var/list/resources = building_data["resources_required"]
	if(!resources || resources.len == 0)
		return TRUE  // No resources needed
	
	for(var/resource_name in resources)
		var/amount_needed = resources[resource_name]
		if(!HasResourceInInventory(M, resource_name, amount_needed))
			return FALSE
	
	return TRUE

// Remove resources from player inventory
/proc/RemoveBuildingResources(mob/players/M, building_data)
	if(!M || !building_data) return FALSE
	
	var/list/resources = building_data["resources_required"]
	if(!resources || resources.len == 0)
		return TRUE  // No resources to remove
	
	for(var/resource_name in resources)
		var/amount_needed = resources[resource_name]
		
		// TODO: Link to actual resource removal from inventory
		// This should call item RemoveFromStack() or similar
	
	return TRUE

// Main building attempt
/proc/AttemptBuild(mob/players/M, building_name)
	if(!M) return
	
	var/building = GetBuildingObjectByName(building_name)
	if(!building)
		M << "<red>Building not found!</red>"
		return
	
	// Verify rank
	var/rank = 1  // Default if character not initialized
	if(M)
		rank = M.GetRankLevel(RANK_BUILDING) || 1
	if(rank < building["rank_required"])
		M << "<red>You need rank [building["rank_required"]] to build this.</red>"
		return
	
	// Verify hammer is equipped
	if(M.HMequipped != 1)
		M << "<red>You need a hammer equipped to build.</red>"
		return
	
	// Verify stamina
	if(M.stamina < building["stamina"])
		M << "<red>You're too tired! (Need [building["stamina"]] stamina)</red>"
		return
	
	// Verify deed permissions
	if(!CanPlayerBuildAtLocation(M, M.loc))
		M << "<red>You don't have permission to build here.</red>"
		return
	
	// Show what's needed
	ShowBuildingRequirements(M, building)
	
	// Check & remove resources
	if(!CheckBuildingResources(M, building))
		M << "<red>You don't have the required materials.</red>"
		return
	
	RemoveBuildingResources(M, building)
	
	// Create the building
	var/building_type = building["type"]
	var/obj/building_obj = new building_type(M.loc)
	if(!building_obj)
		M << "<red>Failed to create building object.</red>"
		return
	
	// Set ownership
	building_obj.buildingowner = ckeyEx("[M.key]")
	
	// Apply costs (stamina, XP)
	M.stamina = max(0, M.stamina - building["stamina"])
	
	if(M.character)
		M.character.UpdateRankExp(RANK_BUILDING, building["xp"])
	
	M << "<green>Successfully built [building["name"]]!</green>"
	return TRUE

