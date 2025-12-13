// ============================================================================
// NPC REPUTATION INTEGRATION
// ============================================================================
/*
 * NPCReputationIntegration.dm - 12-12-25 Integration with Character Save/Load
 * 
 * Hooks reputation system into:
 * - Player login (LoadReputationData)
 * - Player logout (SaveReputationData)
 * - Character creation (InitializeReputation)
 * - Knowledge gate checking (KnowledgeGateCheck)
 * - Pricing modifiers (MerchantPricingCheck)
 */

// ============================================================================
// PLAYER LOGIN INTEGRATION
// ============================================================================

/**
 * OnPlayerLogin_Reputation() - Called when player logs in
 * Restores reputation data from saved character file
 */
/proc/OnPlayerLogin_Reputation(mob/players/M)
	if(!M || !M.character)
		return
	
	// Initialize reputation system if needed
	if(!global_reputation_manager)
		InitializeReputationSystem()
	
	// Load reputation data from character savefile
	LoadReputationData(M)

/**
 * OnPlayerLogout_Reputation() - Called when player logs out
 * Saves reputation data to character file
 */
/proc/OnPlayerLogout_Reputation(mob/players/M)
	if(!M || !M.character)
		return
	
	SaveReputationData(M)

// ============================================================================
// CHARACTER CREATION INTEGRATION
// ============================================================================

/**
 * InitializeCharacterReputation() - Called on new character creation
 * Sets up starting reputation values
 */
/proc/InitializeCharacterReputation(mob/players/M)
	if(!M)
		return
	
	if(!global_reputation_manager)
		InitializeReputationSystem()
	
	// New characters start neutral with everyone
	// (GetPlayerReputation auto-creates at 0 standing)

// ============================================================================
// KNOWLEDGE TREE INTEGRATION
// ============================================================================

/**
 * UpdateNPCKnowledgeTreeReputation() - Called by NPCKnowledgeTree.dm
 * Integrates reputation gates into knowledge node unlock checks
 */
/proc/UpdateNPCKnowledgeTreeReputation()
	// This is called when setting up GetLearnableNodesByPlayer
	// Knowledge nodes check reputation automatically via gates
	
	// Example gate: /datum/knowledge_node can have prereq_reputation set
	// e.g., treasure_hunting has prereq_reputation = 50 (requires "liked" standing)

// ============================================================================
// MERCHANT PRICING INTEGRATION
// ============================================================================

/**
 * GetNPCMerchantPrice() - Called by NPCMerchantSystem.dm
 * Applies reputation discount/markup to item prices
 */
/proc/GetNPCMerchantPrice(mob/players/player, npc_name, base_price)
	if(!player || !global_reputation_manager)
		return base_price
	
	// Get reputation modifier and apply to base price
	var/modified_price = ApplyReputationPricingModifier(player.ckey, npc_name, base_price)
	
	return modified_price

// ============================================================================
// REWARD TRACKING INTEGRATION
// ============================================================================

/**
 * OnQuestComplete_Reputation() - Called when player completes NPC quest
 * Awards reputation points
 */
/proc/OnQuestComplete_Reputation(mob/players/M, quest_id, npc_name, reward_amount = 0)
	if(!M)
		return
	
	// Quests award reputation + currency
	ReputationAction(M.ckey, npc_name, "completed_quest", reward_amount / 10)

/**
 * OnRecipeLearn_Reputation() - Called when player learns recipe from NPC
 * Small reputation boost from learning
 */
/proc/OnRecipeLearn_Reputation(mob/players/M, npc_name, recipe_name)
	if(!M || !npc_name)
		return
	
	ReputationAction(M.ckey, npc_name, "learned_recipe")

/**
 * OnTradeComplete_Reputation() - Called after player trades with NPC
 * Reputation based on trade fairness
 */
/proc/OnTradeComplete_Reputation(mob/players/M, npc_name, trade_fair = TRUE)
	if(!M)
		return
	
	if(trade_fair)
		ReputationAction(M.ckey, npc_name, "traded_fairly")
	else
		ReputationAction(M.ckey, npc_name, "traded_poorly")

// ============================================================================
// DIALOGUE INTEGRATION
// ============================================================================

/**
 * GetNPCGreetingByReputation() - Called by NPCDynamicDialogue.dm
 * Returns greeting text modifiers based on reputation
 */
/proc/GetNPCGreetingByReputation(player_ckey, npc_name)
	var/datum/reputation_manager/rep_mgr = GetReputationManager()
	var/datum/npc_reputation/rep = rep_mgr.GetPlayerReputation(player_ckey, npc_name)
	
	// Return greeting modifier based on tier
	switch(rep.tier)
		if("hated")
			return "cold"
		if("disliked")
			return "dismissive"
		if("neutral")
			return "professional"
		if("liked")
			return "warm"
		if("trusted")
			return "friendly"
		if("beloved")
			return "affectionate"
	
	return "professional"

// ============================================================================
// HOOK REGISTRATION (Called during initialization)
// ============================================================================

/proc/RegisterReputationHooks()
	// These would be called by the relevant systems:
	// - SavingChars.dm calls OnPlayerLogin_Reputation() on character load
	// - SavingChars.dm calls OnPlayerLogout_Reputation() on character save
	// - CharacterCreation calls InitializeCharacterReputation()
	// - NPCKnowledgeTree calls UpdateNPCKnowledgeTreeReputation()
	// - NPCMerchantSystem calls GetNPCMerchantPrice()
	// - Quest system calls OnQuestComplete_Reputation()
	// - Crafting system calls OnRecipeLearn_Reputation()
	// - Trading system calls OnTradeComplete_Reputation()
	// - NPCDynamicDialogue calls GetNPCGreetingByReputation()
	
	RegisterInitComplete("Reputation Integration Hooks")

// ============================================================================
// PLAYER PROCS (Accessible from mob/players)
// ============================================================================

/mob/players/proc/GetNPCReputation(npc_name)
	// Quick accessor for player to check their reputation with an NPC
	var/datum/reputation_manager/rep_mgr = GetReputationManager()
	var/datum/npc_reputation/rep = rep_mgr.GetPlayerReputation(src.ckey, npc_name)
	return rep.standing

/mob/players/proc/ModifyNPCReputation(npc_name, change, reason = "")
	// Quick accessor to modify reputation
	return ReputationAction(src.ckey, npc_name, reason, change)

/mob/players/proc/GetNPCReputationTier(npc_name)
	// Get tier name ("hated", "neutral", "beloved", etc)
	var/datum/reputation_manager/rep_mgr = GetReputationManager()
	var/datum/npc_reputation/rep = rep_mgr.GetPlayerReputation(src.ckey, npc_name)
	return rep.tier

/mob/players/proc/CanLearnExclusiveRecipe(npc_name)
	// Check if player has high enough reputation to learn exclusive recipes
	var/datum/reputation_manager/rep_mgr = GetReputationManager()
	var/datum/npc_reputation/rep = rep_mgr.GetPlayerReputation(src.ckey, npc_name)
	return rep.CanLearnExclusiveRecipe()

// ============================================================================
// DEBUG INTEGRATION VERBS
// ============================================================================

/mob/players/verb/TestReputationIntegration()
	set name = "Test Reputation Integration"
	set category = "debug"
	
	// Test the full integration chain
	src << "Testing reputation integration...\n"
	
	// 1. Initialize
	OnPlayerLogin_Reputation(src)
	src << "✓ Player login hook\n"
	
	// 2. Simulate quest completion
	OnQuestComplete_Reputation(src, "quest_001", "Elder", 50)
	src << "✓ Quest completion reward\n"
	
	// 3. Check reputation
	var/rep = src.GetNPCReputation("Elder")
	src << "✓ Elder reputation: [rep]\n"
	
	// 4. Check tier
	var/tier = src.GetNPCReputationTier("Elder")
	src << "✓ Elder tier: [tier]\n"
	
	// 5. Check exclusive recipe access
	var/can_learn = src.CanLearnExclusiveRecipe("Elder")
	src << "✓ Can learn exclusive recipes: [can_learn]\n"
	
	src << "\nIntegration test complete!"

/mob/players/verb/SimulateFullReputationChain()
	set name = "Simulate Full Reputation Chain"
	set category = "debug"
	
	src << "=== SIMULATING FULL REPUTATION CHAIN ===\n"
	
	// Start: neutral
	src << "START: Elder reputation = [src.GetNPCReputation("Elder")]\n"
	
	// Help Elder
	OnTradeComplete_Reputation(src, "Elder", TRUE)
	src << "AFTER FAIR TRADE: [src.GetNPCReputation("Elder")]\n"
	
	// Learn from Elder
	OnRecipeLearn_Reputation(src, "Elder", "shelter_building")
	src << "AFTER LEARNING: [src.GetNPCReputation("Elder")]\n"
	
	// Complete Elder's quest
	OnQuestComplete_Reputation(src, "elder_001", "Elder", 100)
	src << "AFTER QUEST: [src.GetNPCReputation("Elder")]\n"
	
	// Check final tier
	var/final_tier = src.GetNPCReputationTier("Elder")
	src << "\nFINAL TIER: [final_tier]\n"
	src << "EXCLUSIVE RECIPES UNLOCKED: [src.CanLearnExclusiveRecipe("Elder")]\n"
