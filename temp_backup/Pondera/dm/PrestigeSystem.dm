// dm/PrestigeSystem.dm — Player progression reset with prestige ranks and skill multipliers
// Integrates with UnifiedRankSystem for level progression and CharacterData for persistent state
// Provides cosmetic rewards, skill multipliers, and endgame progression

#define MAX_PRESTIGE_RANK 10        // Maximum prestige level achievable
#define PRESTIGE_RANK_REQUIREMENT 5 // Level required in any skill to prestige
#define PRESTIGE_SKILL_MULTIPLIER 1.25  // 25% bonus to skill exp gain per prestige rank

// Global prestige system
var/datum/PrestigeSystem/prestige_system = null

// Initialize on world startup
proc/InitializePrestigeSystem()
	prestige_system = new /datum/PrestigeSystem()
	RegisterInitComplete("Prestige System")

// Get prestige system singleton
proc/GetPrestigeSystem()
	if(!prestige_system)
		world.log << "ERROR: Prestige system not initialized!"
		return null
	return prestige_system

// Prestige cosmetic reward (titles, icons, effects)
datum/prestige_cosmetic
	var/prestige_rank = 0
	var/title = ""                // Prestige title (e.g., "Legendary Blacksmith")
	var/icon_color = "#FFFFFF"    // Name color change
	var/chat_prefix = ""          // Chat prefix (e.g., "[★★★] ")
	var/item_suffix = ""          // Item rarity suffix (e.g., "Prestige")
	var/aura_type = ""            // Visual effect while moving

// Player prestige state
datum/prestige_state
	var/prestige_rank = 0         // Current prestige level (0-10)
	var/prestige_exp = 0          // Experience toward next prestige
	var/prestige_maxexp = 5000    // Exp needed for prestige rank-up
	var/completed_prestiged_resets = 0  // Number of times player has prestiged
	var/highest_skill_reached = 1 // Highest skill level before prestige (for tracking)
	var/total_reset_count = 0     // Lifetime prestige resets
	var/datum/prestige_cosmetic/cosmetics = null  // Cosmetic rewards
	var/list/prestige_unlocked_recipes = list()   // Recipes unlocked by prestige

	proc/CanPrestige(var/mob/players/player)
		// Check if player meets prestige requirements
		if(!player || !player.character) return FALSE
		
		// Require at least one skill at max level
		var/has_max_skill = FALSE
		for(var/rank_type in RANK_DEFINITIONS)
			var/level = player.GetRankLevel(rank_type)
			if(level >= MAX_RANK_LEVEL)  // MAX_RANK_LEVEL = 5
				has_max_skill = TRUE
				break
		
		return has_max_skill

	proc/GetPrestigeBonus(var/rank_type)
		// Return skill exp multiplier for this prestige rank
		// Prestige rank 0 = 1.0x, rank 1 = 1.25x, rank 2 = 1.5x, etc.
		return 1.0 + (prestige_rank * 0.25)

	proc/GetPrestigeChatTitle()
		// Return formatted prestige title for chat display
		if(prestige_rank == 0) return ""
		
		var/stars = ""
		for(var/i = 1 to prestige_rank)
			stars += "★"
		
		return "[stars] Prestige [prestige_rank] [stars]"

// Prestige System Manager
datum/PrestigeSystem
	var/initialized = FALSE
	var/list/prestige_states = list()       // Per-player prestige data
	var/list/prestige_rewards = list()      // Prestige rank unlock table
	var/list/prestige_milestones = list()   // Major achievements per rank

	New()
		initialized = TRUE
		InitializePrestigeRewards()
		InitializePrestigeMilestones()

	// Initialize prestige rewards per rank
	proc/InitializePrestigeRewards()
		// Rank 1: First Prestige
		prestige_rewards[1] = list(
			"title" = "Novice Ascendant",
			"color" = "#FFD700",  // Gold
			"unlocked_recipes" = list("prestige_crafted_armor_v1"),
			"skill_multiplier" = 1.25
		)
		
		// Rank 2: Double Prestige
		prestige_rewards[2] = list(
			"title" = "Master Ascendant",
			"color" = "#C0C0C0",  // Silver
			"unlocked_recipes" = list("prestige_crafted_weapon_v1"),
			"skill_multiplier" = 1.5
		)
		
		// Rank 5: Grand Master
		prestige_rewards[5] = list(
			"title" = "Grand Master Ascendant",
			"color" = "#FF6B6B",  // Red
			"unlocked_recipes" = list("prestige_legendary_forge", "prestige_legendary_tool"),
			"skill_multiplier" = 1.75
		)
		
		// Rank 10: Legendary
		prestige_rewards[10] = list(
			"title" = "Legendary Ascendant",
			"color" = "#FFD700",  // Gold again
			"unlocked_recipes" = list("prestige_immortal_creation"),
			"skill_multiplier" = 2.0
		)

	// Initialize prestige milestone achievements
	proc/InitializePrestigeMilestones()
		prestige_milestones[1] = "First Prestige: Complete one full skill reset cycle"
		prestige_milestones[5] = "Grand Master: Reach prestige rank 5 with skill multipliers"
		prestige_milestones[10] = "Legendary Status: Achieve maximum prestige rank 10"

	// Get or create prestige state for player
	proc/GetPrestigeState(var/mob/players/player)
		if(!prestige_states[player])
			prestige_states[player] = new /datum/prestige_state()
		
		return prestige_states[player]

	// Check if player can prestige
	proc/CanPlayerPrestige(var/mob/players/player)
		if(!player || !player.character) return FALSE
		
		var/datum/prestige_state/state = GetPrestigeState(player)
		return state.CanPrestige(player)

	// Execute prestige reset for player
	proc/PerformPrestigeReset(var/mob/players/player)
		if(!CanPlayerPrestige(player))
			player << "You do not meet prestige requirements!"
			return FALSE
		
		var/datum/prestige_state/state = GetPrestigeState(player)
		if(!state) return FALSE
		
		// Track highest skill before reset
		var/highest_skill = 1
		for(var/rank_type in RANK_DEFINITIONS)
			var/level = player.GetRankLevel(rank_type)
			if(level > highest_skill)
				highest_skill = level
		
		state.highest_skill_reached = highest_skill
		state.total_reset_count++
		
		// Reset all skills to level 1
		ResetAllSkills(player)
		
		// Increment prestige rank
		if(state.prestige_rank < MAX_PRESTIGE_RANK)
			state.prestige_rank++
			state.prestige_exp = 0
		
		// Award cosmetics
		AwardPrestigeCosmetics(player, state)
		
		// Award prestige-specific recipes
		AwardPrestigeRecipes(player, state)
		
		// Notification
		player << "<b>Prestige Complete!</b>"
		player << "New Prestige Rank: [state.prestige_rank]"
		player << "Skill Multiplier: [state.GetPrestigeBonus(RANK_FISHING)]x"
		player << state.GetPrestigeChatTitle()
		
		return TRUE

	// Reset all player skills to level 1
	proc/ResetAllSkills(var/mob/players/player)
		if(!player || !player.character) return FALSE
		
		for(var/rank_type in RANK_DEFINITIONS)
			// Set level to 1
			player.SetRankLevel(rank_type, 1)
			
			// Reset exp to 0
			var/rank_data = RANK_DEFINITIONS[rank_type]
			if(rank_data)
				var/exp_var = rank_data[2]
				player.character.vars[exp_var] = 0
		
		player << "All skills reset to level 1!"
		return TRUE

	// Award cosmetic title/color for prestige rank
	proc/AwardPrestigeCosmetics(var/mob/players/player, var/datum/prestige_state/state)
		if(!state) return FALSE
		
		var/cosmetic_data = prestige_rewards[state.prestige_rank]
		if(!cosmetic_data) return FALSE
		
		state.cosmetics = new /datum/prestige_cosmetic()
		state.cosmetics.prestige_rank = state.prestige_rank
		state.cosmetics.title = cosmetic_data["title"]
		state.cosmetics.icon_color = cosmetic_data["color"]
		
		// Apply cosmetics
		player.name = "<font color='[state.cosmetics.icon_color]'>[player.name]</font>"
		
		return TRUE

	// Unlock prestige-specific recipes
	proc/AwardPrestigeRecipes(var/mob/players/player, var/datum/prestige_state/state)
		if(!state) return FALSE
		
		var/cosmetic_data = prestige_rewards[state.prestige_rank]
		if(!cosmetic_data) return FALSE
		
		var/list/recipes = cosmetic_data["unlocked_recipes"]
		if(recipes)
			for(var/recipe_name in recipes)
				if(!state.prestige_unlocked_recipes.Find(recipe_name))
					state.prestige_unlocked_recipes += recipe_name
					player << "Prestige Recipe Unlocked: [recipe_name]"
		
		return TRUE

	// Grant prestige experience
	proc/GrantPrestigeExp(var/mob/players/player, var/exp_gain)
		if(!player) return FALSE
		
		var/datum/prestige_state/state = GetPrestigeState(player)
		if(!state) return FALSE
		
		// Don't gain exp if at max prestige
		if(state.prestige_rank >= MAX_PRESTIGE_RANK)
			return FALSE
		
		state.prestige_exp += exp_gain
		
		// Check for prestige rank-up
		if(state.prestige_exp >= state.prestige_maxexp)
			state.prestige_exp = 0
			state.prestige_rank++
			
			if(state.prestige_rank > MAX_PRESTIGE_RANK)
				state.prestige_rank = MAX_PRESTIGE_RANK
			
			AwardPrestigeCosmetics(player, state)
			AwardPrestigeRecipes(player, state)
			
			player << "<b>Prestige Rank-Up!</b> You are now Prestige Rank [state.prestige_rank]!"
			
			return TRUE
		
		return FALSE

	// Get player's prestige info for display
	proc/GetPrestigeInfo(var/mob/players/player)
		if(!player) return null
		
		var/datum/prestige_state/state = GetPrestigeState(player)
		if(!state) return null
		
		var/info = "=== PRESTIGE STATUS ===\n"
		info += "Prestige Rank: [state.prestige_rank]/[MAX_PRESTIGE_RANK]\n"
		info += "Title: [state.cosmetics ? state.cosmetics.title : "None"]\n"
		info += "Skill Multiplier: [state.GetPrestigeBonus(RANK_FISHING)]x\n"
		info += "Total Resets: [state.total_reset_count]\n"
		
		if(state.prestige_rank < MAX_PRESTIGE_RANK)
			var/exp_percent = round(state.prestige_exp / state.prestige_maxexp * 100)
			info += "Progress to Next Rank: [exp_percent]%\n"
		else
			info += "Status: MAXIMUM PRESTIGE ACHIEVED\n"
		
		return info

// Player extension for prestige
mob/players
	proc/UpdatePrestigeSkillMultiplier()
		// Called when player gains skill exp - multiplies gain by prestige bonus
		if(!character) return 1.0
		
		var/datum/PrestigeSystem/ps = GetPrestigeSystem()
		if(!ps) return 1.0
		
		var/datum/prestige_state/state = ps.GetPrestigeState(src)
		if(!state) return 1.0
		
		return state.GetPrestigeBonus(RANK_FISHING)  // Same for all skills

	verb/ViewPrestigeStatus()
		set category = "Character"
		
		var/datum/PrestigeSystem/ps = GetPrestigeSystem()
		if(!ps)
			src << "Prestige system unavailable!"
			return
		
		var/info = ps.GetPrestigeInfo(src)
		if(info)
			src << info

	verb/AttemptPrestige()
		set category = "Character"
		
		var/datum/PrestigeSystem/ps = GetPrestigeSystem()
		if(!ps)
			src << "Prestige system unavailable!"
			return
		
		if(!ps.CanPlayerPrestige(src))
			src << "You must reach level 5 in at least one skill to prestige!"
			return
		
		var/confirm = alert("Confirm Prestige Reset?\nAll skills reset to level 1.\nGain prestige rank and exclusive rewards!", "Prestige", "Confirm", "Cancel")
		
		if(confirm == "Confirm")
			ps.PerformPrestigeReset(src)
		else
			src << "Prestige canceled."
