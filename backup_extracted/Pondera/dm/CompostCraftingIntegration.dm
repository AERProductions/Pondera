/**
 * CompostCraftingIntegration.dm - UI and crafting interface for composting
 * 
 * Provides compost crafting options through:
 * - Compost Bin object (place-able container)
 * - Crafting menu interface
 * - Recipe discovery system
 * - Quality calculation based on gardening skill
 */

// ============================================================================
// COMPOST RECIPE REGISTRY
// ============================================================================

var/global/list/COMPOST_RECIPES = alist(
	"vegetable_compost" = list(
		"compost_type" = COMPOST_BASIC,
		"ingredients" = list("harvest_waste" = 5, "crop_scraps" = 3),
		"output" = 1,
		"time" = 60,                    // 3 seconds to craft
		"skill_requirement" = 1,
		"discovered" = 1                // Available from start
	),
	"bone_meal" = list(
		"compost_type" = COMPOST_BONE_MEAL,
		"ingredients" = list("bones" = 10),
		"output" = 1,
		"time" = 45,
		"skill_requirement" = 2,
		"discovered" = 0
	),
	"kelp_compost" = list(
		"compost_type" = COMPOST_KELP,
		"ingredients" = list("kelp" = 8, "seaweed" = 5),
		"output" = 1,
		"time" = 50,
		"skill_requirement" = 3,
		"discovered" = 0
	)
)

// ============================================================================
// COMPOST BIN OBJECT
// ============================================================================

/obj/CompostBin
	name = "Compost Bin"
	desc = "A sturdy wooden bin for accumulating and processing compost materials. Click to interact."
	icon = 'dmi/64/creation.dmi'
	icon_state = "compost_bin"
	density = 1
	
	var/owner = null                    // Who placed this bin
	var/contents_list = list()          // What's in the bin (name = amount)
	var/compost_accumulated = 0         // Finished compost ready to apply
	var/compost_type = COMPOST_BASIC
	var/last_update = 0                 // Last time compost was processed

/obj/CompostBin/Click()
	if(!usr) return
	
	OpenCompostInterface(usr, src)

/obj/CompostBin/proc/AddWaste(var/material_name, var/amount)
	if(!material_name || amount <= 0) return FALSE
	
	if(!contents_list[material_name])
		contents_list[material_name] = 0
	
	contents_list[material_name] += amount
	return TRUE

/obj/CompostBin/proc/RemoveWaste(var/material_name, var/amount)
	if(!material_name || amount <= 0) return FALSE
	if(!contents_list[material_name] || contents_list[material_name] < amount)
		return FALSE
	
	contents_list[material_name] -= amount
	if(contents_list[material_name] <= 0)
		contents_list -= material_name
	
	return TRUE

/obj/CompostBin/proc/GetContentsReport()
	var/report = "Compost Bin Contents:\n"
	if(!contents_list)
		report += "Empty\n"
	else
		var/has_contents = 0
		for(var/material in contents_list)
			has_contents = 1
			report += "[material]: [contents_list[material]]\n"
		if(has_contents == 0)
			report += "Empty\n"
	
	report += "\nFinished Compost: [compost_accumulated]\n"
	report += "Type: [GetCompostName(compost_type)]\n"
	
	return report

/obj/CompostBin/proc/ProcessCompost()
	/**
	 * Convert waste materials into finished compost
	 * Happens passively over time, or on player request
	 */
	
	var/waste_count = 0
	if(contents_list)
		for(var/material in contents_list)
			waste_count += contents_list[material]
	
	if(waste_count == 0) return 0
	
	// Conversion rate: ~20% of waste becomes usable compost
	var/compost_produced = round(waste_count * 0.2)
	
	if(compost_produced > 0)
		compost_accumulated += compost_produced
		contents_list = list()  // Clear contents
		last_update = world.time
		return compost_produced
	
	return 0

// ============================================================================
// COMPOST CRAFTING INTERFACE
// ============================================================================

/proc/OpenCompostInterface(mob/players/player, obj/CompostBin/bin)
	if(!player || !bin) return
	
	var/choice = input(player, "What would you like to do?", "Compost Interface") as null|anything in list(
		"View Contents",
		"Add Waste",
		"Craft Compost",
		"Apply Compost to Nearby Soil",
		"Cancel"
	)
	
	switch(choice)
		if("View Contents")
			player << bin.GetContentsReport()
			OpenCompostInterface(player, bin)
		
		if("Add Waste")
			PromptAddWaste(player, bin)
		
		if("Craft Compost")
			PromptCraftCompost(player, bin)
		
		if("Apply Compost to Nearby Soil")
			PromptApplyCompost(player, bin)

/proc/PromptAddWaste(mob/players/player, obj/CompostBin/bin)
	if(!player || !bin) return
	
	var/materials = list(
		"Harvest Waste" = "harvest_waste",
		"Crop Scraps" = "crop_scraps",
		"Bones" = "bones",
		"Kelp" = "kelp",
		"Seaweed" = "seaweed"
	)
	
	var/choice = input(player, "Add which material?", "Add Waste") as null|anything in materials
	if(!choice) return
	
	var/material_name = materials[choice]
	var/amount = input(player, "How much?", "Amount") as num
	
	if(amount && amount > 0)
		if(bin.AddWaste(material_name, amount))
			player << "Added [amount] [choice] to compost bin."
		else
			player << "Failed to add waste."
	
	OpenCompostInterface(player, bin)

/proc/PromptCraftCompost(mob/players/player, obj/CompostBin/bin)
	if(!player || !bin) return
	
	var/choices = list()
	for(var/recipe_name in COMPOST_RECIPES)
		var/list/recipe = COMPOST_RECIPES[recipe_name]
		if(recipe["discovered"])
			choices[recipe_name] = recipe_name
	
	var/recipe_count = 0
	if(choices)
		for(var/x in choices) recipe_count++
	
	if(recipe_count == 0)
		player << "No compost recipes discovered yet."
		return
	
	var/choice = input(player, "Craft which compost?", "Craft Compost") as null|anything in choices
	if(!choice) return
	
	var/recipe_name = choices[choice]
	CraftCompostRecipe(player, bin, recipe_name)

/proc/CraftCompostRecipe(mob/players/player, obj/CompostBin/bin, var/recipe_name)
	if(!player || !bin || !recipe_name) return
	
	var/list/recipe = COMPOST_RECIPES[recipe_name]
	if(!recipe)
		player << "Recipe not found."
		return
	
	// Check skill requirement
	var/grank = 1
	if(player.character)
		grank = player.character.GetRankLevel("grank") || 1
	
	if(grank < recipe["skill_requirement"])
		player << "You need Gardening rank [recipe["skill_requirement"]] to craft this."
		return
	
	// Check ingredients
	var/list/ingredients = recipe["ingredients"]
	for(var/ingredient_name in ingredients)
		var/amount_needed = ingredients[ingredient_name]
		if(!bin.contents_list[ingredient_name] || bin.contents_list[ingredient_name] < amount_needed)
			player << "Not enough [ingredient_name]. Need [amount_needed], have [bin.contents_list[ingredient_name] || 0]."
			return
	
	// Consume ingredients
	for(var/ingredient_name in ingredients)
		bin.RemoveWaste(ingredient_name, ingredients[ingredient_name])
	
	// Calculate quality based on skill
	var/quality = 0.5 + (grank * 0.2)  // 0.5 to 1.5 based on rank
	quality = clamp(quality, 0.5, 1.5)
	
	// Award experience
	if(player.character)
		player.character.UpdateRankExp("grank", 10)
	
	// Add compost to bin
	var/output_amount = recipe["output"]
	var/compost_type = recipe["compost_type"]
	var/compost_name = GetCompostName(compost_type)
	
	bin.compost_type = compost_type
	bin.compost_accumulated += output_amount
	
	player << "You craft [output_amount] units of [compost_name]! (Quality: [round(quality, 0.1)]x)"
	
	OpenCompostInterface(player, bin)

/proc/PromptApplyCompost(mob/players/player, obj/CompostBin/bin)
	if(!player || !bin) return
	
	if(bin.compost_accumulated <= 0)
		player << "No finished compost in this bin."
		return
	
	// Find nearby turfs to apply compost to
	var/turf/target_turf = input(player, "Click on soil to apply compost.", "Apply Compost") as null|turf
	
	if(!target_turf)
		return
	
	// Check distance (must be within 3 tiles)
	if(get_dist(player, target_turf) > 3)
		player << "That location is too far away."
		return
	
	// Apply compost
	var/compost_type = bin.compost_type
	var/quality = 1.0  // Could scale based on when it was made
	
	if(ApplyCompost(target_turf, compost_type, quality))
		bin.compost_accumulated--
		player << "Applied compost to soil at [target_turf.x], [target_turf.y]."
		// Visual effect - add overlay if animation exists
		// target_turf.overlays += image(icon='dmi/64/creation.dmi', icon_state="compost_effect")
	else
		player << "Could not apply compost to that location (max 5 per season)."
	
	OpenCompostInterface(player, bin)

// ============================================================================
// COMPOST BIN PLACEMENT
// ============================================================================

/**
 * Place compost bin command for players
 * Can be integrated with building system or admin commands
 */
/proc/PlaceCompostBin(mob/players/player)
	if(!player) return
	
	var/turf/target = input(player, "Click to place compost bin", "Place Compost Bin") as null|turf
	
	if(!target || get_dist(player, target) > 5)
		player << "Invalid location."
		return
	
	// Check if location is clear
	for(var/obj/O in target)
		if(O.density)
			player << "That location is occupied."
			return
	
	var/obj/CompostBin/bin = new(target)
	bin.owner = player.key
	player << "Compost bin placed."

// ============================================================================
// RECIPE DISCOVERY
// ============================================================================

/**
 * Unlock compost recipes through NPC teaching or experimentation
 */
/proc/UnlockCompostRecipe(mob/players/player, var/recipe_name)
	if(!player) return
	
	if(!COMPOST_RECIPES[recipe_name])
		return FALSE
	
	COMPOST_RECIPES[recipe_name]["discovered"] = 1
	player << "You discovered the [recipe_name] recipe!"
	
	return TRUE

/**
 * NPC teaching integration
 */
/proc/TeachCompostRecipeFromNPC(mob/players/player, mob/npcs/npc, var/recipe_name)
	if(!player || !npc) return
	
	if(UnlockCompostRecipe(player, recipe_name))
		player << "[npc.name] teaches you how to make [recipe_name]."
		world << "[npc.name] says: [player.name], remember: good compost is key to fertile soil!"
		return TRUE
	
	return FALSE
