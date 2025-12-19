// Stone Carving System
// Allows players to carve stone blocks into detailed stone objects
// Requires: Chisel + Hammer dual-wield
// Rank: RANK_CARVING (levels 1-5 unlock progressively better carvings)
// Pattern: DisplayStoneCarvingMenu -> GetAvailableCarvings -> ExecuteStoneCarvingAction

var/list/STONE_CARVINGS = null  // Global registry for stone carvings

/proc/DisplayStoneCarvingMenu(mob/players/M)
	if(!M || !M.client)
		return
	
	if(!M.HMequipped || !M.CHequipped)
		M << "<red>You need both a hammer and chisel equipped to carve stone.</red>"
		return
	
	// Get player's carving rank
	var/rank = 1
	if(M)
		rank = M.GetRankLevel(RANK_CARVING) || 1
	
	// Get available carvings for this rank
	var/list/carvings = GetAvailableCarvings(M, rank)
	if(!carvings || carvings.len == 0)
		M << "<red>You need to improve your carving rank to create stone carvings.</red>"
		return
	
	// Display menu with categories
	var/category = input("What type of carving would you like to create?", "Stone Carving") in list("Decorative", "Structural", "Artistic", "Cancel")
	if(!category || category == "Cancel")
		return
	
	// Filter carvings by category
	var/list/category_carvings = list()
	for(var/carving_name in carvings)
		var/list/carving_data = STONE_CARVINGS[carving_name]
		if(carving_data && carving_data["category"] == category)
			category_carvings[carving_name] = carving_name
	
	if(!category_carvings || category_carvings.len == 0)
		M << "<red>No carvings available in that category at your rank.</red>"
		return
	
	// Display available carvings in category
	category_carvings["Back"] = null
	var/carving_choice = input("What would you like to carve?", "Stone Carving Menu") in category_carvings
	if(!carving_choice || carving_choice == "Back")
		return
	
	ExecuteStoneCarvingAction(M, carving_choice)

/proc/GetAvailableCarvings(mob/players/M, rank)
	var/list/available = list()
	
	if(!STONE_CARVINGS)
		InitializeStoneCarvings()
	
	for(var/carving_name in STONE_CARVINGS)
		var/list/carving_data = STONE_CARVINGS[carving_name]
		if(carving_data && carving_data["rank_required"] <= rank)
			available[carving_name] = carving_name
	
	return available

/proc/ExecuteStoneCarvingAction(mob/players/M, carving_name)
	if(!M || !M.client || !carving_name)
		return
	
	// Verify dual-wield still active
	if(!M.HMequipped || !M.CHequipped)
		M << "<red>You lost your grip on your tools!</red>"
		return
	
	// Get carving data
	var/list/carving_data = STONE_CARVINGS[carving_name]
	if(!carving_data)
		M << "<red>Unknown carving type.</red>"
		return
	
	// Validate requirements
	if(!CheckStoneCarvingRequirements(M, carving_data))
		ShowStoneCarvingRequirements(M, carving_data)
		return
	
	// Consume resources (stone blocks)
	RemoveStoneCarvingResources(M, carving_data)
	
	// Calculate success chance: 50% base + (rank * 10%)
	var/rank = M ? M.GetRankLevel(RANK_CARVING) : 1
	var/success_chance = 50 + (rank * 10)
	var/is_success = (rand(1, 100) <= success_chance)
	
	// Apply stamina cost
	if(M.stamina)
		M.stamina = max(0, M.stamina - carving_data["stamina"])
	
	if(is_success)
		M << "<green>You successfully carve <b>[carving_name]</b>!</green>"
		
		// Spawn carved item at player location
		var/item_type = carving_data["item_type"]
		new item_type(M.loc)
		
		// Award XP and check rank-up
		if(M)
			M.UpdateRankExp(RANK_CARVING, carving_data["xp"])
		
		// Visual/audio feedback
		M << "<yellow>You gain [carving_data["xp"]] carving experience.</yellow>"
		view(3, M) << "<b>[M.name]</b> carefully carves stone with hammer and chisel."
	else
		M << "<orange>Your carving attempt fails. Stone crumbles.</orange>"
		// Failed attempt still awards partial XP (25% of success XP)
		if(M)
			M.UpdateRankExp(RANK_CARVING, round(carving_data["xp"] * 0.25))

/proc/CheckStoneCarvingRequirements(mob/players/M, list/carving_data)
	if(!M || !carving_data)
		return FALSE
	
	// Check hammer equipped
	if(!M.HMequipped)
		M << "<red>You need a hammer equipped.</red>"
		return FALSE
	
	// Check chisel equipped
	if(!M.CHequipped)
		M << "<red>You need a chisel equipped.</red>"
		return FALSE
	
	// Check stamina
	if(M.stamina && M.stamina < carving_data["stamina"])
		M << "<red>You don't have enough stamina ([M.stamina]/[carving_data["stamina"]]).</red>"
		return FALSE
	
	// Check rank
	if(M)
		var/rank = M.GetRankLevel(RANK_CARVING)
		if(rank < carving_data["rank_required"])
			M << "<red>You need carving rank [carving_data["rank_required"]] (you have [rank]).</red>"
			return FALSE
	else
		if(carving_data["rank_required"] > 1)
			M << "<red>You need carving rank [carving_data["rank_required"]].</red>"
			return FALSE
	
	// Check resources (stone blocks) - for now skip inventory check
	// Since GetInventoryCount may not exist, we'll assume resources are consumed from inventory
	
	return TRUE

/proc/RemoveStoneCarvingResources(mob/players/M, list/carving_data)
	if(!M || !carving_data)
		return
	
	var/list/resources = carving_data["resources"]
	if(!resources)
		return
	
	// TODO: Integrate with inventory system to remove resources
	// For now, just a placeholder for resource consumption

/proc/ShowStoneCarvingRequirements(mob/players/M, list/carving_data)
	if(!M || !carving_data)
		return
	
	var/rank = M ? M.GetRankLevel(RANK_CARVING) : 1
	var/message = "<b>[carving_data["name"]]</b>\n"
	message += "Category: [carving_data["category"]]\n"
	message += "Rank Required: [carving_data["rank_required"]] (you have: [rank])\n"
	message += "Stamina Cost: [carving_data["stamina"]]\n"
	message += "XP Reward: [carving_data["xp"]]\n"
	message += "Description: [carving_data["description"]]\n"
	message += "\nResources Required:\n"
	
	var/list/resources = carving_data["resources"]
	if(resources)
		for(var/resource_type in resources)
			message += "- [resources[resource_type]]x [resource_type]\n"
	else
		message += "- None\n"
	
	M << message

/proc/InitializeStoneCarvings()
	if(STONE_CARVINGS)
		return
	
	STONE_CARVINGS = list(
		// Decorative tier (rank 1-2)
		"Carved Stone Block" = list(
			"name" = "Carved Stone Block",
			"category" = "Decorative",
			"rank_required" = 1,
			"stamina" = 5,
			"xp" = 10,
			"item_type" = "/obj/Building/Decorative/CarvedStoneBlock",
			"resources" = list("Stone Block" = 1),
			"description" = "A simple carved stone block with basic geometric patterns."
		),
		"Polished Stone Tile" = list(
			"name" = "Polished Stone Tile",
			"category" = "Decorative",
			"rank_required" = 2,
			"stamina" = 8,
			"xp" = 15,
			"item_type" = "/obj/Building/Decorative/PolishedStoneTile",
			"resources" = list("Stone Block" = 1),
			"description" = "A polished stone tile with a smooth, reflective surface."
		),
		// Structural tier (rank 2-3)
		"Stone Pillar" = list(
			"name" = "Stone Pillar",
			"category" = "Structural",
			"rank_required" = 2,
			"stamina" = 10,
			"xp" = 20,
			"item_type" = "/obj/Building/Structural/StonePillar",
			"resources" = list("Stone Block" = 2),
			"description" = "A carved stone pillar suitable for architectural support."
		),
		"Stone Arch" = list(
			"name" = "Stone Arch",
			"category" = "Structural",
			"rank_required" = 3,
			"stamina" = 12,
			"xp" = 25,
			"item_type" = "/obj/Building/Structural/StoneArch",
			"resources" = list("Stone Block" = 3),
			"description" = "An elegantly carved stone arch perfect for doorways."
		),
		// Artistic tier (rank 3-5)
		"Stone Statue" = list(
			"name" = "Stone Statue",
			"category" = "Artistic",
			"rank_required" = 3,
			"stamina" = 15,
			"xp" = 30,
			"item_type" = "/obj/Building/Artistic/StoneStatue",
			"resources" = list("Stone Block" = 3),
			"description" = "A beautifully carved stone statue, perfect for monuments."
		),
		"Ornate Stone Relief" = list(
			"name" = "Ornate Stone Relief",
			"category" = "Artistic",
			"rank_required" = 4,
			"stamina" = 18,
			"xp" = 40,
			"item_type" = "/obj/Building/Artistic/OrnateStoneRelief",
			"resources" = list("Stone Block" = 4),
			"description" = "An intricate stone relief with detailed artistic patterns."
		),
		"Masterwork Stone Sculpture" = list(
			"name" = "Masterwork Stone Sculpture",
			"category" = "Artistic",
			"rank_required" = 5,
			"stamina" = 20,
			"xp" = 50,
			"item_type" = "/obj/Building/Artistic/MasterworkStoneSculpture",
			"resources" = list("Stone Block" = 5),
			"description" = "A masterwork stone sculpture, the pinnacle of carving artistry."
		)
	)
