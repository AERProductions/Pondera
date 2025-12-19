/// FishingPoleMinigameSystem.dm
/// Fishing system with simple minigame mechanics
/// Works with CentralizedEquipmentSystem durability tracking
/// 
/// Features:
/// - Fishing minigame with timing-based catches
/// - Durability reduction per cast/catch
/// - Resource collection (fish, treasure) ONLY
/// - Skill progression via fishing rank
/// - NO CAMPFIRE CREATION (use kindling + sparks for that)

/mob/players
	var
		datum/fishing_minigame/active_fishing_game = null
	
	proc/UseFishingPole()
		/// Called when fishing pole is equipped and user initiates fishing
		/// Opens fishing minigame
		src.StartFishingMinigame()
	
	proc/StartFishingMinigame()
		/// Starts the fishing minigame - player must catch fish
		var/obj/items/equipment/pole = equipment_slots["main_hand"]
		
		if(!pole || !istype(pole, /obj/items/equipment/tool/Fishing_Pole))
			src << "<yellow>You need a fishing pole equipped.</yellow>"
			return
		
		// Check durability
		if(pole.IsBroken())
			src << "<red>Your fishing pole is broken! Find a new one to fish.</red>"
			return
		
		// Verify we're at water
		var/turf/T = src.loc
		if(!T || T.name != "Water")
			src << "<yellow>You need to be standing in water to fish.</yellow>"
			return
		
		// Check stamina
		if(stamina < 15)
			src << "<yellow>You're too tired to fish. Rest first.</yellow>"
			return
		
		// Start minigame
		active_fishing_game = new /datum/fishing_minigame(src, pole)
		active_fishing_game.StartMinigame()

// ==================== FISHING MINIGAME DATUM ====================

/datum/fishing_minigame
	var
		mob/players/player = null
		obj/items/equipment/tool/pole = null
		var/game_active = TRUE
		var/cast_time = 0
		var/catch_window = 0
		var/difficulty_level = 1
	
	New(mob/players/P, obj/items/equipment/tool/pole_item)
		player = P
		pole = pole_item
		difficulty_level = player.character.GetRankLevel(RANK_FISHING) || 1
	
	proc/StartMinigame()
		if(!player || !pole) return
		
		player << "\n<cyan>========== FISHING MINIGAME ==========</cyan>"
		player << "<yellow>Cast your line into the water...</yellow>"
		player << "<cyan>A fish bites!</cyan>"
		player << "<lime>HURRY! Press E to reel in the catch!</lime>"
		player << "<orange>You have 5 seconds to respond!</orange>"
		player << "<cyan>======================================</cyan>\n"
		
		// Set catch window (5 seconds = 50 deciseconds)
		catch_window = world.time + 50
		game_active = TRUE
		
		// Player must press E within the catch window
		// This is simplified - real implementation would need input handling
	
	proc/AttemptCatch()
		if(!game_active)
			player << "<red>Too late! The fish got away.</red>"
			return FALSE
		
		if(world.time > catch_window)
			player << "<red>You waited too long! The fish got away.</red>"
			game_active = FALSE
			return FALSE
		
		// Caught the fish!
		ExecuteFishingCatch()
		game_active = FALSE
		return TRUE
	
	proc/ExecuteFishingCatch()
		if(!player || !pole) return
		
		// Reduce pole durability
		if(!pole.AttemptUse())
			player << "<red>Your fishing pole has broken during the catch!</red>"
			return
		
		// Show wear warning
		if(pole.IsFragile())
			var/percent = pole.GetDurabilityPercent()
			player << "<yellow>Your fishing pole is almost broken ([percent]% durability left).</yellow>"
		
		// Consume stamina
		player.stamina = max(0, player.stamina - 15)
		
		// Determine catch based on rank and luck
		var/rank = player.character.GetRankLevel(RANK_FISHING) || 1
		var/success_chance = 40 + (rank * 10)  // 50-100%
		var/treasure_chance = 5 + rank  // 6-15% rare items
		
		if(rand(0, 100) > success_chance)
			player << "<orange>You almost had it, but the fish slipped away!</orange>"
			return
		
		// Caught a fish!
		var/common_fish = list(
			"Common Fish",
			"Bass",
			"Trout",
			"Catfish"
		)
		var/rare_fish = list(
			"Golden Fish",
			"Legendary Carp",
			"Exotic Fish"
		)
		
		var/catch_name = ""
		var/xp_reward = 10 + (rank * 3)
		
		if(rand(0, 100) <= treasure_chance)
			catch_name = pick(rare_fish)
			xp_reward = 30 + (rank * 5)
			player << "<lime>RARE CATCH! You caught a [catch_name]!</lime>"
		else
			catch_name = pick(common_fish)
			player << "<cyan>You caught a [catch_name]!</cyan>"
		
		// Create catch item and add to inventory
		var/obj/item = new /obj/items()
		item.name = catch_name
		item.icon = 'dmi/64/creation.dmi'
		item.icon_state = "fish"
		item.Move(player)
		
		// Award XP
		player.character.UpdateRankExp(RANK_FISHING, xp_reward)
		
		// Check for rank up
		var/old_rank = rank
		var/new_rank = player.character.GetRankLevel(RANK_FISHING)
		if(new_rank > old_rank)
			player << "<lime>Your fishing skill has improved to rank [new_rank]!</lime>"

// ==================== FISHING RANK DEFINITION ====================

// Ensure RANK_FISHING is defined in UnifiedRankSystem
// If not defined elsewhere, add to UnifiedRankSystem.dm:
// #define RANK_FISHING "fishing_rank"

