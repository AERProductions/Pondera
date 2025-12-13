// dm/AdvancedQuestChainSystem.dm — Multi-stage quests with prerequisites, branching, and dynamic rewards
// Extends FactionQuestIntegrationSystem with complex quest dependencies and reward scaling
// Integrates with NPCPathfinding for quest giver movement, AdvancedEconomy for reward scaling

#define QUEST_STAGE_LOCKED 0      // Prerequisites not met
#define QUEST_STAGE_AVAILABLE 1   // Ready to accept
#define QUEST_STAGE_ACTIVE 2      // In progress
#define QUEST_STAGE_COMPLETE 3    // Finished successfully
#define QUEST_STAGE_FAILED 4      // Failed (can retry)

// Global quest chain system
var/datum/AdvancedQuestChainSystem/quest_chain_system = null

// Initialize on world startup
proc/InitializeAdvancedQuestChains()
	quest_chain_system = new /datum/AdvancedQuestChainSystem()
	RegisterInitComplete("Advanced Quest Chains")

// Get quest chain system singleton
proc/GetAdvancedQuestChainSystem()
	if(!quest_chain_system)
		world.log << "ERROR: Advanced Quest Chain system not initialized!"
		return null
	return quest_chain_system

// Quest reward datum with supply/demand scaling
datum/quest_reward
	var/lucre_base = 0          // Base lucre (story mode)
	var/material_stone = 0      // Materials (PvP mode)
	var/material_metal = 0
	var/material_timber = 0
	var/list/item_rewards = list()   // Special items
	var/exp_multiplier = 1.0    // Exp gain multiplier
	var/reputation_gain = 0     // Faction rep
	var/tech_tier = 1           // Reward tech tier (affects price scaling)

datum/quest_reward/proc/ScaleBySupply(var/kingdom = "story")
	// Use economy system to scale rewards based on supply
	var/datum/AdvancedEconomySystem/econ = GetAdvancedEconomy()
	if(!econ) return
	
	// Scale lucre by supply/demand
	if(lucre_base > 0)
		var/supply_ratio = econ.GetSupplyDemandRatio(kingdom, "stone")
		// Higher supply = higher reward to incentivize completion
		if(supply_ratio > 2.0)
			lucre_base = round(lucre_base * 1.5)  // +50% bonus
		else if(supply_ratio < 0.5)
			lucre_base = round(lucre_base * 0.8)  // -20% penalty
	
	// Scale material rewards
	if(material_stone > 0)
		material_stone = round(econ.GetTechTierPrice("stone", material_stone, tech_tier, kingdom) / 10)

// Quest stage representing single quest milestone
datum/quest_stage
	var/stage_id = ""
	var/title = ""
	var/description = ""
	var/list/objectives = list()     // Things player must do
	var/objectives_completed = 0
	var/npc_giver = null        // NPC offering this stage
	var/next_stage = null       // Quest ID of next stage
	var/list/branch_quests = list()  // List of possible next quests
	var/datum/quest_reward/stage_reward = null     // datum/quest_reward
	var/completion_threshold = 100  // % completion needed (100 = all objectives)

// Advanced quest chain datum
datum/quest_chain
	var/chain_id = ""
	var/title = ""
	var/description = ""
	var/faction = ""
	var/list/stages = list()         // Quest stages in order
	var/current_stage_index = 0
	var/completed = FALSE
	var/failed = FALSE
	var/datum/quest_reward/total_reward = null     // datum/quest_reward
	var/difficulty = 1          // 1-5 difficulty rating
	var/quality_level = 100     // Quality % for reward scaling (100 = perfect execution)

datum/quest_chain/proc/GetCurrentStage()
	if(current_stage_index > 0 && current_stage_index <= length(stages))
		return stages[current_stage_index]
	return null

datum/quest_chain/proc/AdvanceStage()
	if(completed || failed) return FALSE
	
	current_stage_index++
	if(current_stage_index > length(stages))
		completed = TRUE
		return TRUE
	
	return FALSE

datum/quest_chain/proc/FailChain()
	failed = TRUE
	return TRUE

datum/quest_chain/proc/IsLocked()
	// Check if prerequisites met
	// TODO: Implement prerequisite checking logic
	return FALSE

datum/quest_chain/proc/GetChainProgress()
	return round(current_stage_index / length(stages) * 100)

// Advanced Quest Chain System
datum/AdvancedQuestChainSystem
	var/initialized = FALSE
	var/list/quest_chains = list()      // All available chains
	var/list/player_chains = list()     // Per-player active chains
	var/list/chain_templates = list()   // Template chains for creation
	var/list/completion_bonuses = list() // Bonus rewards for perfect completion

	New()
		initialized = TRUE
		InitializeQuestTemplates()

	// Initialize template quest chains
	proc/InitializeQuestTemplates()
		// Smithing chain: Basic blacksmith -> Advanced -> Legendary
		var/datum/quest_chain/smith_chain = new /datum/quest_chain()
		smith_chain.chain_id = "smithing_master"
		smith_chain.title = "Path of the Blacksmith"
		smith_chain.description = "Master the art of smithing from basic iron to legendary materials"
		smith_chain.faction = "Ironforge Council"
		smith_chain.difficulty = 3
		
		// Stage 1: Iron Basics
		var/datum/quest_stage/stage1 = new /datum/quest_stage()
		stage1.stage_id = "smith_basic"
		stage1.title = "Learn the Forge"
		stage1.description = "Master basic iron smelting"
		stage1.objectives = list(
			"Smelt 10 iron ore",
			"Create 5 iron tools",
			"Report to Blacksmith Torgan"
		)
		stage1.stage_reward = new /datum/quest_reward()
		if(stage1.stage_reward)
			stage1.stage_reward.lucre_base = 100
			stage1.stage_reward.reputation_gain = 50
		
		smith_chain.stages += stage1
		
		// Stage 2: Bronze Advancement
		var/datum/quest_stage/stage2 = new /datum/quest_stage()
		stage2.stage_id = "smith_bronze"
		stage2.title = "Bronze Mastery"
		stage2.description = "Learn to craft bronze alloys"
		stage2.objectives = list(
			"Smelt 5 bronze ingots",
			"Create 3 bronze weapons",
			"Test in combat against training dummy"
		)
		stage2.stage_reward = new /datum/quest_reward()
		if(stage2.stage_reward)
			stage2.stage_reward.lucre_base = 250
			stage2.stage_reward.material_metal = 50
			stage2.stage_reward.reputation_gain = 100
		
		smith_chain.stages += stage2
		
		// Stage 3: Damascus Steel
		var/datum/quest_stage/stage3 = new /datum/quest_stage()
		stage3.stage_id = "smith_damascus"
		stage3.title = "Damascus Legendary"
		stage3.description = "Craft the legendary Damascus steel"
		stage3.objectives = list(
			"Gather 100 rare ore",
			"Forge 1 Damascus blade",
			"Deliver to Master Ironsmith"
		)
		stage3.stage_reward = new /datum/quest_reward()
		if(stage3.stage_reward)
			stage3.stage_reward.lucre_base = 500
			stage3.stage_reward.material_metal = 150
			stage3.stage_reward.tech_tier = 5
			stage3.stage_reward.reputation_gain = 250
		
		smith_chain.stages += stage3
		
		chain_templates["smithing_master"] = smith_chain

	// Create new quest chain instance for player
	proc/CreatePlayerChain(var/mob/players/player, var/template_id)
		if(!chain_templates[template_id])
			return null
		
		var/datum/quest_chain/template = chain_templates[template_id]
		var/datum/quest_chain/new_chain = new /datum/quest_chain()
		
		// Copy template
		new_chain.chain_id = template.chain_id
		new_chain.title = template.title
		new_chain.description = template.description
		new_chain.faction = template.faction
		new_chain.difficulty = template.difficulty
		new_chain.current_stage_index = 1
		
		// Deep copy stages
		for(var/datum/quest_stage/stage in template.stages)
			var/datum/quest_stage/new_stage = new /datum/quest_stage()
			new_stage.stage_id = stage.stage_id
			new_stage.title = stage.title
			new_stage.description = stage.description
			// Copy objectives list
			new_stage.objectives = list()
			for(var/obj in stage.objectives)
				new_stage.objectives += obj
			new_stage.completion_threshold = stage.completion_threshold
			new_stage.stage_reward = stage.stage_reward
			new_chain.stages += new_stage
		
		// Register with player
		if(!player_chains[player])
			player_chains[player] = list()
		
		player_chains[player][new_chain.chain_id] = new_chain
		return new_chain

	// Accept quest chain for player
	proc/AcceptQuestChain(var/mob/players/player, var/chain_id)
		if(!chain_templates[chain_id])
			return FALSE
		
		var/datum/quest_chain/chain = CreatePlayerChain(player, chain_id)
		if(!chain) return FALSE
		
		// Notify player
		player << "You have accepted: [chain.title]"
		player << "[chain.description]"
		
		return TRUE

	// Update quest stage completion
	proc/UpdateStageProgress(var/mob/players/player, var/chain_id, var/progress_percent)
		if(!player_chains[player] || !player_chains[player][chain_id])
			return FALSE
		
		var/datum/quest_chain/chain = player_chains[player][chain_id]
		var/datum/quest_stage/stage = chain.GetCurrentStage()
		if(!stage) return FALSE
		
		if(progress_percent >= 100)
			// Stage complete
			if(chain.AdvanceStage())
				// Chain complete
				CompleteQuestChain(player, chain_id)
				return TRUE
			else
				// Next stage available
				stage = chain.GetCurrentStage()
				player << "Stage complete! Next: [stage.title]"
				return TRUE
		
		return FALSE

	// Complete entire quest chain
	proc/CompleteQuestChain(var/mob/players/player, var/chain_id)
		if(!player_chains[player] || !player_chains[player][chain_id])
			return FALSE
		
		var/datum/quest_chain/chain = player_chains[player][chain_id]
		if(chain.completed)
			return FALSE
		
		chain.completed = TRUE
		
		// Calculate total reward
		DistributeChainRewards(player, chain)
		
		player << "Quest chain complete: [chain.title]"
		player << "You have earned significant rewards!"
		
		return TRUE

	// Distribute rewards from quest chain
	proc/DistributeChainRewards(var/mob/players/player, var/datum/quest_chain/chain)
		if(!player || !chain) return FALSE
		
		var/total_lucre = 0
		var/total_stone = 0
		var/total_metal = 0
		var/total_timber = 0
		var/total_rep = 0
		
		// Sum all stage rewards
		for(var/datum/quest_stage/stage in chain.stages)
			if(stage.stage_reward)
				total_lucre += stage.stage_reward.lucre_base
				if(stage.stage_reward.material_metal > 0)
					total_metal += stage.stage_reward.material_metal
				if(stage.stage_reward.material_stone > 0)
					total_stone += stage.stage_reward.material_stone
				if(stage.stage_reward.material_timber > 0)
					total_timber += stage.stage_reward.material_timber
				total_rep += stage.stage_reward.reputation_gain
		
		// Apply quality modifier (perfect = 100%, rushed = 50%)
		var/quality_factor = chain.quality_level / 100
		total_lucre = round(total_lucre * quality_factor)
		total_metal = round(total_metal * quality_factor)
		total_stone = round(total_stone * quality_factor)
		total_timber = round(total_timber * quality_factor)
		
		// Scale by supply/demand
		var/datum/AdvancedEconomySystem/econ = GetAdvancedEconomy()
		if(econ)
			// Adjust material rewards based on supply
			var/supply_ratio_metal = econ.GetSupplyDemandRatio("story", "metal")
			if(supply_ratio_metal > 2.0)
				total_metal = round(total_metal * 0.7)  // Abundant: reduce
			else if(supply_ratio_metal < 0.3)
				total_metal = round(total_metal * 1.5)  // Scarce: increase
		
		// Grant rewards to player
		if(player)
			player.lucre += total_lucre
		
		// Update kingdom treasury
		var/datum/KingdomTreasurySystem/treasury = GetKingdomTreasurySystem()
		if(treasury)
			if(total_stone > 0) treasury.DepositToTreasury("story", "stone", total_stone, "quest reward: [chain.title]")
			if(total_metal > 0) treasury.DepositToTreasury("story", "metal", total_metal, "quest reward: [chain.title]")
			if(total_timber > 0) treasury.DepositToTreasury("story", "timber", total_timber, "quest reward: [chain.title]")
		
		player << "Reward: [total_lucre] Lucre, [total_metal] Metal, [total_stone] Stone, [total_timber] Timber"

	// Get player's active chains
	proc/GetPlayerChains(var/mob/players/player)
		if(!player_chains[player])
			return list()
		
		return player_chains[player]

	// Get chain status for UI
	proc/GetChainStatus(var/mob/players/player, var/chain_id)
		if(!player_chains[player] || !player_chains[player][chain_id])
			return null
		
		var/datum/quest_chain/chain = player_chains[player][chain_id]
		var/status = "Chain: [chain.title]\n"
		status += "Progress: [chain.GetChainProgress()]%\n"
		status += "Current Stage: [chain.current_stage_index] of [length(chain.stages)]\n"
		
		var/datum/quest_stage/current = chain.GetCurrentStage()
		if(current)
			status += "Objectives:\n"
			for(var/obj in current.objectives)
				status += "  - [obj]\n"
		
		return status

// Player extension for quest tracking
mob/players
	var/list/active_quest_chains = list()

	verb/ViewQuestChains()
		set category = "Quests"
		
		var/datum/AdvancedQuestChainSystem/qcs = GetAdvancedQuestChainSystem()
		if(!qcs)
			src << "Quest system unavailable!"
			return
		
		var/list/chains = qcs.GetPlayerChains(src)
		if(!chains || length(chains) == 0)
			src << "You have no active quest chains."
			return
		
		src << "=== QUEST CHAINS ==="
		for(var/chain_id in chains)
			var/status = qcs.GetChainStatus(src, chain_id)
			src << status

	verb/AcceptQuestChain(template_id as text)
		set category = "Quests"
		
		if(!template_id)
			template_id = "smithing_master"
		
		var/datum/AdvancedQuestChainSystem/qcs = GetAdvancedQuestChainSystem()
		if(!qcs)
			src << "Quest system unavailable!"
			return
		
		if(qcs.AcceptQuestChain(src, template_id))
			src << "Quest chain accepted!"
		else
			src << "Unable to accept quest chain."
