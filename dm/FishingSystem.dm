// FishingSystem.dm — Robust fishing mini-game with tension mechanic, fish varieties, and skill progression

// ==================== FISHING CONSTANTS ====================

#define FISHING_STATE_IDLE 0
#define FISHING_STATE_WAITING 1
#define FISHING_STATE_BITE 2
#define FISHING_STATE_HOOKED 3
#define FISHING_STATE_REELING 4
#define FISHING_STATE_SUCCESS 5
#define FISHING_STATE_FAILED 6

#define FISH_COMMON 1
#define FISH_UNCOMMON 2
#define FISH_RARE 3
#define FISH_LEGENDARY 4

// ==================== FISH DATABASE ====================
// Water types: "fresh", "salt", "both" (anadromous - migrate between fresh and salt)

var/global/list/fish_database = list(
	"Sunfish" = list(
		"rarity" = FISH_COMMON,
		"size_min" = 2, "size_max" = 5,
		"weight" = 0.5,
		"bite_delay_min" = 3, "bite_delay_max" = 8,
		"struggle_power" = 1,
		"difficulty" = 1,
		"value" = 10,
		"color" = "#FFD700",
		"water_type" = "fresh"
	),
	"Catfish" = list(
		"rarity" = FISH_COMMON,
		"size_min" = 4, "size_max" = 8,
		"weight" = 1.5,
		"bite_delay_min" = 5, "bite_delay_max" = 12,
		"struggle_power" = 2,
		"difficulty" = 2,
		"value" = 25,
		"color" = "#8B4513",
		"water_type" = "fresh"
	),
	"Trout" = list(
		"rarity" = FISH_UNCOMMON,
		"size_min" = 5, "size_max" = 9,
		"weight" = 1.2,
		"bite_delay_min" = 4, "bite_delay_max" = 10,
		"struggle_power" = 3,
		"difficulty" = 2,
		"value" = 35,
		"color" = "#DEB887",
		"water_type" = "both"
	),
	"Bass" = list(
		"rarity" = FISH_UNCOMMON,
		"size_min" = 6, "size_max" = 11,
		"weight" = 2.0,
		"bite_delay_min" = 6, "bite_delay_max" = 15,
		"struggle_power" = 4,
		"difficulty" = 3,
		"value" = 45,
		"color" = "#2F4F4F",
		"water_type" = "both"
	),
	"Pike" = list(
		"rarity" = FISH_RARE,
		"size_min" = 8, "size_max" = 14,
		"weight" = 3.5,
		"bite_delay_min" = 8, "bite_delay_max" = 20,
		"struggle_power" = 6,
		"difficulty" = 4,
		"value" = 75,
		"color" = "#556B2F",
		"water_type" = "fresh"
	),
	"Golden Carp" = list(
		"rarity" = FISH_RARE,
		"size_min" = 10, "size_max" = 16,
		"weight" = 5.0,
		"bite_delay_min" = 10, "bite_delay_max" = 25,
		"struggle_power" = 7,
		"difficulty" = 5,
		"value" = 100,
		"color" = "#FFD700",
		"water_type" = "fresh"
	),
	"Leviathan Salmon" = list(
		"rarity" = FISH_LEGENDARY,
		"size_min" = 15, "size_max" = 25,
		"weight" = 10.0,
		"bite_delay_min" = 15, "bite_delay_max" = 40,
		"struggle_power" = 10,
		"difficulty" = 6,
		"value" = 200,
		"color" = "#FF6347",
		"water_type" = "both"
	),
	"Cod" = list(
		"rarity" = FISH_COMMON,
		"size_min" = 7, "size_max" = 12,
		"weight" = 2.2,
		"bite_delay_min" = 6, "bite_delay_max" = 14,
		"struggle_power" = 3,
		"difficulty" = 2,
		"value" = 40,
		"color" = "#696969",
		"water_type" = "salt"
	),
	"Flounder" = list(
		"rarity" = FISH_UNCOMMON,
		"size_min" = 5, "size_max" = 10,
		"weight" = 1.8,
		"bite_delay_min" = 7, "bite_delay_max" = 16,
		"struggle_power" = 2,
		"difficulty" = 2,
		"value" = 38,
		"color" = "#808080",
		"water_type" = "salt"
	),
	"Tuna" = list(
		"rarity" = FISH_RARE,
		"size_min" = 12, "size_max" = 20,
		"weight" = 6.5,
		"bite_delay_min" = 12, "bite_delay_max" = 28,
		"struggle_power" = 8,
		"difficulty" = 5,
		"value" = 120,
		"color" = "#1C1C1C",
		"water_type" = "salt"
	)
)

// ==================== FISHING SESSION OBJECT ====================

obj/fishing_session
	var
		mob/players/angler
		turf/fishing_location
		state = FISHING_STATE_IDLE
		fish_type = null
		fish_size = 0
		fish_weight = 0
		fish_rarity = 0
		
		// Mini-game state
		tension = 0          // 0-100 scale
		tension_gain_rate = 5
		tension_loss_rate = 2
		last_button_press = 0
		button_press_window = 15  // Ticks to press button after bite
		reeling_progress = 0  // 0-100 for reeling success
		reeling_difficulty = 0
		
		// Visual feedback
		feedback_text = ""
		last_feedback_time = 0

	New(mob/players/fisher, turf/location)
		..()
		angler = fisher
		fishing_location = location
		state = FISHING_STATE_IDLE
		tension = 0
		reeling_progress = 0
		spawn() RunFishingSession()

	proc/RunFishingSession()
		set waitfor = 0
		
		angler << "<font color='blue'><b>*** Fishing Started ***</b>"
		angler << "Waiting for a bite... press <b>SPACE</b> when you feel a tug!"
		state = FISHING_STATE_WAITING
		
		// Wait for fish to bite
		var/bite_delay = rand(8, 20) * 10  // In ticks
		sleep(bite_delay)
		
		if(!angler) 
			Cleanup()
			return
		
		// Fish bites!
		SelectFish()
		state = FISHING_STATE_BITE
		angler << "<font color='red'><b>*** FISH BITES! ***</b> Press SPACE NOW!"
		PlayFishingSound("bite", fishing_location)
		
		// Give player window to react
		last_button_press = world.time
		var/button_pressed = FALSE
		var/reaction_window = button_press_window
		
		while(reaction_window > 0)
			if(angler && angler.just_pressed_fish_button)
				button_pressed = TRUE
				angler.just_pressed_fish_button = FALSE
				break
			sleep(1)
			reaction_window--
		
		if(!button_pressed)
			angler << "<font color='orange'>The fish got away! Too slow!</font>"
			state = FISHING_STATE_FAILED
			spawn(50) if(src) Cleanup()
			return
		
		// Hook set!
		angler << "<font color='green'><b>*** HOOKED! ***</b>"
		state = FISHING_STATE_HOOKED
		PlayFishingSound("hook", fishing_location)
		
		// Reeling mini-game
		reeling_difficulty = fish_database[fish_type]["difficulty"]
		ReelInFish()

	proc/ReelInFish()
		set waitfor = 0
		set background = 1
		
		state = FISHING_STATE_REELING
		angler << "<font color='blue'>Hold SPACE to reel in! Don't let tension max out!</font>"
		
		var/reel_time = reeling_difficulty * 50  // Longer for harder fish
		var/tick = 0
		
		while(tick < reel_time && state == FISHING_STATE_REELING)
			// Check for button hold
			if(angler && angler.holding_fish_button)
				reeling_progress += 3
				tension = max(0, tension - tension_loss_rate * 2)
				UpdateFishingUI()
			else
				// Losing line!
				reeling_progress = max(0, reeling_progress - 1)
				tension += tension_gain_rate * 1.5
				UpdateFishingUI()
			
			// Check failure conditions
			if(tension >= 100)
				angler << "<font color='red'><b>LINE SNAPPED!</b> Tension was too high!</font>"
				state = FISHING_STATE_FAILED
				PlayFishingSound("fail", fishing_location)
				spawn(20) if(src) Cleanup()
				return
			
			if(!angler)
				Cleanup()
				return
			
			sleep(1)
			tick++
		
		// Success!
		if(state == FISHING_STATE_REELING)
			state = FISHING_STATE_SUCCESS
			angler << "<font color='gold'><b>*** CAUGHT! ***</b> [fish_type] ([fish_size]\" - [fish_weight] lbs)</font>"
			PlayFishingSound("catch", fishing_location)
			GiveReward()
			spawn(50) if(src) Cleanup()

	proc/SelectFish()
		/**
		 * Randomly select fish based on skill, location, and water type
		 */
		var/skill_level = angler.fishinglevel || 1
		var/rarity_roll = rand(1, 100)
		var/selected_fish = null
		
		// Determine water type from current location
		var/location_water_type = "fresh"  // Default to fresh
		if(fishing_location)
			if(istype(fishing_location, /turf/water))
				location_water_type = fishing_location:water_type
		
		// Weight fish selection by skill, rarity, and water type
		for(var/fish_name in fish_database)
			var/fish_info = fish_database[fish_name]
			var/difficulty = fish_info["difficulty"]
			var/fish_water_type = fish_info["water_type"] || "fresh"
			
			// Check if fish can be caught in this water type
			if(fish_water_type != location_water_type && fish_water_type != "both")
				continue  // Skip fish not available in this water
			
			// Higher skill = access to harder fish
			if(difficulty <= (skill_level / 2))
				// Check rarity
				var/rarity = fish_info["rarity"]
				var/rarity_threshold = 0
				
				switch(rarity)
					if(FISH_COMMON)
						rarity_threshold = 50
					if(FISH_UNCOMMON)
						rarity_threshold = 75
					if(FISH_RARE)
						rarity_threshold = 90
					if(FISH_LEGENDARY)
						rarity_threshold = 98
				
				if(rarity_roll <= rarity_threshold)
					selected_fish = fish_name
					break
		
		if(!selected_fish)
			selected_fish = "Sunfish"  // Fallback
		
		fish_type = selected_fish
		var/fish_data = fish_database[fish_type]
		fish_size = rand(fish_data["size_min"], fish_data["size_max"])
		fish_weight = fish_data["weight"] + (fish_size / 5)
		fish_rarity = fish_data["rarity"]
		reeling_difficulty = fish_data["difficulty"]

	proc/UpdateFishingUI()
		/**
		 * Display real-time fishing feedback
		 */
		var/tension_bar = ""
		var/progress_bar = ""
		
		// Tension bar (red danger indicator)
		var/tension_blocks = round(tension / 10)
		for(var/i = 1; i <= 10; i++)
			if(i <= tension_blocks)
				tension_bar += "█"
			else
				tension_bar += "░"
		
		// Reeling progress bar (green success indicator)
		var/progress_blocks = round(reeling_progress / 10)
		for(var/i = 1; i <= 10; i++)
			if(i <= progress_blocks)
				progress_bar += "█"
			else
				progress_bar += "░"
		
		// Send formatted UI (use oob to update in real-time)
		var/ui_text = "<font color='blue'><b>[fish_type]</b></font><br>"
		ui_text += "Tension: <font color='red'>[tension_bar]</font> [round(tension)]%<br>"
		ui_text += "Progress: <font color='green'>[progress_bar]</font> [round(reeling_progress)]%"
		
		// This would ideally be sent via oob or screen object
		// For now, just update feedback

	proc/GiveReward()
		/**
		 * Spawn caught fish in angler's inventory
		 */
		if(!angler) return
		
		var/fish_data = fish_database[fish_type]
		var/xp_gained = fish_data["difficulty"] * 10 + round(fish_size * 2)
		var/value = fish_data["value"] * fish_rarity
		
		// Create fish object
		var/obj/items/food/caught_fish/fish = new(angler.loc)
		fish.name = "[fish_type] ([fish_size]\", [round(fish_weight, 0.1)] lbs)"
		fish.fish_type = fish_type
		fish.fish_size = fish_size
		fish.fish_weight = fish_weight
		fish.fish_rarity = fish_rarity
		fish.value = value
		fish.color = fish_data["color"]
		
		// Award XP
		angler.fexp += xp_gained
		angler.fishinglevel = max(angler.fishinglevel + 1, round((angler.fexp / 100) + 1))
		
		angler << "<font color='gold'>Gained [xp_gained] Fishing XP!"
		angler << "<font color='blue'>Fish is worth approximately [value] gold!"

	proc/Cleanup()
		if(angler)
			angler.is_fishing = FALSE
			angler.fishing_session = null
		del src

	proc/PlayFishingSound(sound_event, location)
		/**
		 * Play fishing-related sounds via SoundManager
		 */
		if(!sound_mgr) return
		
		switch(sound_event)
			if("bite")
				sound_mgr.PlayEffectSound("fishing_bite", location)
			if("hook")
				sound_mgr.PlayEffectSound("fishing_cast", location)
			if("catch")
				sound_mgr.PlayEffectSound("fishing_reel", location)
			if("fail")
				sound_mgr.PlayEffectSound("fishing_fail", location)

// ==================== CAUGHT FISH OBJECT ====================

obj/items/food/caught_fish
	var
		fish_type = "Unknown"
		fish_size = 0
		fish_weight = 0
		fish_rarity = FISH_COMMON
		catch_time = ""
		value = 0
	
	name = "Caught Fish"
	icon = 'dmi/tower.dmi'
	icon_state = "fish1"
	
	New()
		..()
		catch_time = time2text(world.timeofday, "hh:mm")
	
	verb/Examine()
		set category = null
		set popup_menu = 1
		set src in usr
		
		var/rarity_text = "Unknown"
		switch(fish_rarity)
			if(FISH_COMMON) rarity_text = "Common"
			if(FISH_UNCOMMON) rarity_text = "Uncommon"
			if(FISH_RARE) rarity_text = "Rare"
			if(FISH_LEGENDARY) rarity_text = "Legendary"
		
		usr << "<center><b>[name]</b><br>"
		usr << "Type: [fish_type]<br>"
		usr << "Size: [fish_size]\"<br>"
		usr << "Weight: [round(fish_weight, 0.1)] lbs<br>"
		usr << "Rarity: <font color='[fish_database[fish_type]["color"]]'>[rarity_text]</font><br>"
		usr << "Caught: [catch_time]<br>"
		usr << "Value: [value] gold"

// ==================== MOB EXTENSIONS ====================

mob/players
	var
		is_fishing = FALSE
		fishing_session = null
		just_pressed_fish_button = FALSE
		holding_fish_button = FALSE

	// Fishing button control (hook into movement/input system)
	proc/ProcessFishingInput(direction)
		/**
		 * Handle SPACE bar for fishing mini-game
		 * Called from movement processing or keybind system
		 */
		if(is_fishing && fishing_session)
			just_pressed_fish_button = TRUE
			holding_fish_button = TRUE
			spawn(5) holding_fish_button = FALSE

// ==================== WATER TURF FISHING INTEGRATION ====================

// Extension to existing turf/water (defined in GatheringExtensions.dm)
// Add StartFishing proc to mob/players to enable fishing

	mob/players
		proc/StartFishing(turf/location)
			/**
			 * Initiate a fishing session - requires fishing pole equipped
			 */
			
			// CRITICAL: Check elevation range - must be within ±0.5 of water
			if(!src.Chk_LevelRange(location))
				src << "<font color='orange'><b>You must be on the same elevation level to fish here!</b>"
				return
			
			// Phase 3: Check zone permissions
			if(!CanPlayerBuildAtLocation(src, location))
				src << "<b><font color=red>You cannot fish here. Only village members can fish in this area.</font></b>"
				return
			
			if(FPequipped != 1)
				src << "<font color='red'>You need to equip a Fishing Pole first!</font>"
				return
			
			if(is_fishing)
				src << "You're already fishing!"
				return
			
			if(!location || !isturf(location))
				src << "Invalid fishing location."
				return
			
			is_fishing = TRUE
			fishing_session = new /obj/fishing_session(src, location)

// ==================== INITIALIZATION ====================

proc/InitFishingSystem()
	/**
	 * Initialize fishing system
	 */
	world.log << "Fishing System initialized with [fish_database.len] fish species"

// Hook into world startup
world/New()
	..()
	InitFishingSystem()
