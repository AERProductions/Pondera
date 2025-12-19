// Fishing Minigame System
// Interactive fishing experience with timing-based success mechanic
// Requires: Fishing Rod equipped
// Rank: RANK_FISHING (levels 1-5 determine catch quality and success rate)
// Pattern: DisplayFishingMenu -> SelectFishingSpot -> ExecuteFishingMinigame

var/list/FISHING_SPOTS = null  // Global registry for fishing locations
var/list/FISH_SPECIES = null   // Global registry for fish types by biome/season

/proc/DisplayFishingMenu(mob/players/M)
	if(!M || !M.client)
		return
	
	if(!M.FRequipped)
		M << "<red>You need a fishing rod equipped to fish.</red>"
		return
	
	// Get player's fishing rank
	var/rank = 1
	if(M)
		rank = M.GetRankLevel(RANK_FISHING) || 1
	
	// Get available fish species for this rank
	var/list/fish_list = GetAvailableFishSpecies(M, rank)
	if(!fish_list || fish_list.len == 0)
		M << "<red>You need to improve your fishing rank to catch better fish.</red>"
		return
	
	// Display menu with fish options
	fish_list["Cancel"] = null
	var/fish_choice = input("What would you like to fish for?", "Fishing") in fish_list
	if(!fish_choice || fish_choice == "Cancel")
		return
	
	ExecuteFishingMinigame(M, fish_choice)

/proc/GetAvailableFishSpecies(mob/players/M, rank)
	var/list/available = list()
	
	if(!FISH_SPECIES)
		InitializeFishSpecies()
	
	for(var/fish_name in FISH_SPECIES)
		var/list/fish_data = FISH_SPECIES[fish_name]
		if(fish_data && fish_data["rank_required"] <= rank)
			available[fish_name] = fish_name
	
	return available

/proc/ExecuteFishingMinigame(mob/players/M, fish_name)
	if(!M || !M.client || !fish_name)
		return
	
	// Verify rod still equipped
	if(!M.FRequipped)
		M << "<red>Your fishing rod is no longer equipped!</red>"
		return
	
	// Get fish data
	var/list/fish_data = FISH_SPECIES[fish_name]
	if(!fish_data)
		M << "<red>Unknown fish species.</red>"
		return
	
	// Validate requirements
	if(!CheckFishingRequirements(M, fish_data))
		ShowFishingRequirements(M, fish_data)
		return
	
	// Start minigame sequence
	StartFishingMinigame(M, fish_name, fish_data)

/proc/CheckFishingRequirements(mob/players/M, list/fish_data)
	if(!M || !fish_data)
		return FALSE
	
	// Check fishing rod equipped
	if(!M.FRequipped)
		M << "<red>You need a fishing rod equipped.</red>"
		return FALSE
	
	// Check stamina (fishing is less strenuous than other activities)
	if(M.stamina && M.stamina < fish_data["stamina"])
		M << "<red>You don't have enough stamina ([M.stamina]/[fish_data["stamina"]]).</red>"
		return FALSE
	
	// Check rank
	if(M)
		var/rank = M.GetRankLevel(RANK_FISHING)
		if(rank < fish_data["rank_required"])
			M << "<red>You need fishing rank [fish_data["rank_required"]] (you have [rank]).</red>"
			return FALSE
	else
		if(fish_data["rank_required"] > 1)
			M << "<red>You need fishing rank [fish_data["rank_required"]].</red>"
			return FALSE
	
	return TRUE

/proc/ShowFishingRequirements(mob/players/M, list/fish_data)
	if(!M || !fish_data)
		return
	
	var/rank = M ? M.GetRankLevel(RANK_FISHING) : 1
	var/message = "<b>[fish_data["name"]]</b>\n"
	message += "Difficulty: [fish_data["difficulty"]]\n"
	message += "Rank Required: [fish_data["rank_required"]] (you have: [rank])\n"
	message += "Stamina Cost: [fish_data["stamina"]]\n"
	message += "XP Reward: [fish_data["xp"]]\n"
	message += "Base Difficulty: [fish_data["difficulty"]]%\n"
	message += "Weight: ~[fish_data["weight"]]g\n"
	message += "Description: [fish_data["description"]]\n"
	
	M << message

/proc/StartFishingMinigame(mob/players/M, fish_name, list/fish_data)
	/**
	 * Fishing minigame sequence:
	 * 1. Cast line animation (1 second)
	 * 2. Wait for bite (3-8 seconds random)
	 * 3. Player must press E within 2-second window
	 * 4. Reel in with timing challenges (3 prompts, must succeed 2/3)
	 * 5. Catch or lose fish based on performance
	 */
	
	if(!M || !fish_data)
		return
	
	M << "<yellow>== FISHING MINIGAME ==</yellow>"
	M << "Fishing for: <b>[fish_name]</b>"
	M << "<cyan>Casting line...</cyan>"
	
	// Apply stamina cost
	if(M.stamina)
		M.stamina = max(0, M.stamina - fish_data["stamina"])
	
	// Declare shared vars outside spawn blocks for proper scope
	var/successful_reels = 0
	var/bite_caught = 0
	
	// Phase 1: Cast animation (1 second = 10 ticks)
	spawn(10)
		if(!M) return
		
		M << "<cyan>Waiting for bite...</cyan>"
		
		// Phase 2: Random wait for bite (3-8 seconds)
		var/wait_time = rand(30, 80)  // 3-8 seconds in ticks
		spawn(wait_time)
			if(!M || !M.FRequipped)
				M << "<red>Fishing interrupted!</red>"
				return
			
			M << "<b><red>BITE! Press E within 2 seconds!</red></b>"
			
			// Phase 3: Prompt player to press E (2 second window = 20 ticks)
			spawn(20)
				if(!bite_caught)
					M << "<orange>The fish got away...</orange>"
					// Partial XP for attempt
					if(M)
						M.UpdateRankExp(RANK_FISHING, round(fish_data["xp"] * 0.1))
					return
			
			// Wait for E-key press (polling would be in macro handler)
			// For now, simulate success with 70% base + rank bonus
			var/rank = M ? M.GetRankLevel(RANK_FISHING) : 1
			var/success_chance = 70 + (rank * 5)
			bite_caught = (rand(1, 100) <= success_chance)
			
			if(!bite_caught)
				M << "<orange>The fish got away...</orange>"
				if(M)
					M.UpdateRankExp(RANK_FISHING, round(fish_data["xp"] * 0.1))
				return
			
			// Phase 4: Reel in - require 2/3 successful prompts
			M << "<yellow>Reeling in... Press E three times!</yellow>"
			
			// Simulate 3 reel prompts
			for(var/i = 1; i <= 3; i++)
				spawn(10 * i)
					if(!M || !M.FRequipped) return
					
					M << "<b>Reel [i]/3: Press E!</b>"
					
					// Simulate reel success (85% base + rank)
					var/reel_rank = M ? M.GetRankLevel(RANK_FISHING) : 1
					var/reel_success_chance = 85 + (reel_rank * 3)
					if(rand(1, 100) <= reel_success_chance)
						successful_reels++
						M << "<green>Good!</green>"
					else
						M << "<orange>Struggle!</orange>"
			
			// Phase 5: Check final result
			spawn(40)
				if(!M || !M.FRequipped)
					M << "<red>Fishing rod lost!</red>"
					return
				
				if(successful_reels >= 2)
					// Successful catch
					M << "<green><b>You caught a [fish_name]!</b></green>"
					
					// Create fish item at player location
					var/item_type = fish_data["item_type"]
					var/obj/fish_item = new item_type(M.loc)
					if(fish_item)
						fish_item.name = fish_name
					
					// Award XP based on difficulty
					if(M)
						var/xp_award = fish_data["xp"] + (fish_data["difficulty"])
						M.UpdateRankExp(RANK_FISHING, xp_award)
					
					M << "<yellow>You gain [fish_data["xp"]] fishing experience.</yellow>"
					view(3, M) << "<b>[M.name]</b> successfully catches a [fish_name]!"
				else
					// Failed catch
					M << "<orange>The fish broke free!</orange>"
					if(M)
						M.UpdateRankExp(RANK_FISHING, round(fish_data["xp"] * 0.25))

/proc/InitializeFishSpecies()
	if(FISH_SPECIES)
		return
	
	FISH_SPECIES = list(
		// Beginner tier (rank 1-2)
		"Common Trout" = list(
			"name" = "Common Trout",
			"difficulty" = 20,
			"rank_required" = 1,
			"stamina" = 3,
			"xp" = 15,
			"weight" = 250,
			"item_type" = "/obj/item/Fish/CommonTrout",
			"seasons" = list("Spring", "Summer", "Autumn"),
			"biomes" = list("Temperate", "Mountain"),
			"description" = "A common freshwater trout. Easy to catch and moderately nutritious."
		),
		"Freshwater Bass" = list(
			"name" = "Freshwater Bass",
			"difficulty" = 25,
			"rank_required" = 1,
			"stamina" = 3,
			"xp" = 15,
			"weight" = 300,
			"item_type" = "/obj/item/Fish/FreshwaterBass",
			"seasons" = list("Spring", "Summer", "Autumn"),
			"biomes" = list("Temperate"),
			"description" = "A medium-sized bass found in lakes. Good flavor."
		),
		// Intermediate tier (rank 2-3)
		"Golden Carp" = list(
			"name" = "Golden Carp",
			"difficulty" = 40,
			"rank_required" = 2,
			"stamina" = 5,
			"xp" = 25,
			"weight" = 400,
			"item_type" = "/obj/item/Fish/GoldenCarp",
			"seasons" = list("Summer", "Autumn"),
			"biomes" = list("Temperate"),
			"description" = "A rare golden carp with excellent nutritional value."
		),
		"Arctic Char" = list(
			"name" = "Arctic Char",
			"difficulty" = 45,
			"rank_required" = 2,
			"stamina" = 5,
			"xp" = 25,
			"weight" = 350,
			"item_type" = "/obj/item/Fish/ArcticChar",
			"seasons" = list("Winter", "Spring", "Autumn"),
			"biomes" = list("Arctic", "Mountain"),
			"description" = "A cold-water fish with rich, delicious flesh."
		),
		// Advanced tier (rank 3-4)
		"Silver Salmon" = list(
			"name" = "Silver Salmon",
			"difficulty" = 60,
			"rank_required" = 3,
			"stamina" = 7,
			"xp" = 35,
			"weight" = 500,
			"item_type" = "/obj/item/Fish/SilverSalmon",
			"seasons" = list("Summer", "Autumn"),
			"biomes" = list("Temperate", "Mountain"),
			"description" = "A powerful salmon known for fighting during the catch. Highly prized."
		),
		"Luminous Sunfish" = list(
			"name" = "Luminous Sunfish",
			"difficulty" = 55,
			"rank_required" = 3,
			"stamina" = 6,
			"xp" = 35,
			"weight" = 450,
			"item_type" = "/obj/item/Fish/LuminousSunfish",
			"seasons" = list("Spring", "Summer"),
			"biomes" = list("Tropical"),
			"description" = "A magical fish that glows softly. Legendary flavor."
		),
		// Expert tier (rank 4-5)
		"Ancient Leviathan" = list(
			"name" = "Ancient Leviathan",
			"difficulty" = 80,
			"rank_required" = 4,
			"stamina" = 10,
			"xp" = 50,
			"weight" = 1000,
			"item_type" = "/obj/item/Fish/AncientLeviathan",
			"seasons" = list("Autumn", "Winter"),
			"biomes" = list("Temperate", "Arctic"),
			"description" = "A massive ancient fish. Extremely difficult to catch and incredibly nutritious."
		),
		"Mythical Starfish" = list(
			"name" = "Mythical Starfish",
			"difficulty" = 85,
			"rank_required" = 5,
			"stamina" = 12,
			"xp" = 60,
			"weight" = 800,
			"item_type" = "/obj/item/Fish/MythicalStarfish",
			"seasons" = list("Spring", "Summer", "Autumn", "Winter"),
			"biomes" = list("Tropical", "Temperate"),
			"description" = "A legendary fish said to grant visions. The ultimate fishing achievement."
		)
	)
