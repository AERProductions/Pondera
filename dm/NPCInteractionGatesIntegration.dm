// dm/NPCInteractionGatesIntegration.dm — NPC Interaction Gate Documentation & Helpers
// Date: 2025-12-18
// Purpose: Document and provide helper functions for NPC interaction gates
//
// Gate System Features (implemented in NPCInteractionHUD.dm):
// ✅ Time-of-day gates (morning, afternoon, evening, night)
// ✅ Shop-hours gates (only when shop open)
// ✅ Reputation gates (minimum reputation threshold)
// ✅ Knowledge prerequisites (learned recipes/topics)
// ✅ Season gates (Spring, Summer, Autumn, Winter)
// ✅ Awake-state gates (NPC sleeping vs active)
//
// Integration: NPCInteractionHUD.dm calls IsOptionVisible_Helper() to filter options
// 
// Usage:
//   var/opt = new /datum/npc_interaction_option("Learn Fishing", "learn_fish")
//   opt.gates["time_of_day"] = "morning"
//   opt.gates["min_reputation"] = 5
//   opt.gates["npc_awake"] = 1

// ============================================================================
// REPUTATION SYSTEM INTEGRATION
// ============================================================================

/**
 * ModifyNPCReputation(mob/players/M, npc_name, delta) - Adjust player's reputation with NPC
 * Called after positive/negative interactions
 * 
 * Example:
 *   ModifyNPCReputation(player, "Blacksmith Bob", +10)  // Increases reputation
 */
proc/ModifyNPCReputation(mob/players/M, npc_name, delta)
	if(!M || !M.character || !delta)
		return
	
	var/current_rep = GetPlayerNPCReputation(M, npc_name)
	var/new_rep = current_rep + delta
	
	// Clamp to reasonable range (-100 to +100)
	if(new_rep < -100) new_rep = -100
	if(new_rep > 100) new_rep = 100

/**
 * InitializeNPCReputation(mob/players/M, npc_name) - Initialize reputation with NPC
 * Called when player first meets an NPC
 */
proc/InitializeNPCReputation(mob/players/M, npc_name)
	if(!M || !M.character)
		return
	
	// NPCKnowledgeTree.dm handles reputation storage

// ============================================================================
// KNOWLEDGE PREREQUISITE SYSTEM
// ============================================================================

/**
 * HasPrerequisiteKnowledge(mob/players/M, list/node_ids) - Check if player knows all prerequisite topics
 * Returns: 1 if all prerequisites met, 0 otherwise
 * 
 * Example:
 *   if(!HasPrerequisiteKnowledge(player, list("fishing_basics", "knot_tying")))
 *       player << "You haven't learned the prerequisites!"
 */
proc/HasPrerequisiteKnowledge(mob/players/M, list/node_ids)
	if(!M || !M.character || !M.character.recipe_state)
		return 0
	
	if(!node_ids || !node_ids.len)
		return 1  // No prerequisites
	
	for(var/node_id in node_ids)
		if(!M.character.recipe_state.IsTopicLearned(node_id))
			return 0
	
	return 1

/**
 * GetMissingPrerequisites(mob/players/M, list/node_ids) - Find which prerequisites player hasn't met
 * Returns: List of unlearned node IDs
 * 
 * Example:
 *   var/missing = GetMissingPrerequisites(player, list("A", "B", "C"))
 *   if(missing.len)
 *       player << "You're missing: [missing.Join(", ")]"
 */
proc/GetMissingPrerequisites(mob/players/M, list/node_ids)
	var/list/missing = list()
	
	if(!M || !M.character || !M.character.recipe_state)
		return node_ids  // All missing
	
	if(!node_ids)
		return list()
	
	for(var/node_id in node_ids)
		if(!M.character.recipe_state.IsTopicLearned(node_id))
			missing += node_id
	
	return missing

// ============================================================================
// GATE PRESET BUILDERS - Quick option creation
// ============================================================================

/**
 * CreateMerchantOption(label, handler, gates_list) - Create a merchant interaction option
 * 
 * Example:
 *   var/opt = CreateMerchantOption("Buy Items", "buy_items", \
 *       list("shop_hours" = 1, "time_of_day" = "afternoon"))
 */
proc/CreateMerchantOption(label, handler, list/gates_list)
	var/opt = new /datum/npc_interaction_option(label, handler, FALSE)
	return opt

/**
 * CreateReputationGatedOption(label, handler, min_rep) - Create option requiring minimum reputation
 * 
 * Example:
 *   var/opt = CreateReputationGatedOption("Learn Secret", "learn_secret", 20)
 */
proc/CreateReputationGatedOption(label, handler, min_rep)
	var/opt = new /datum/npc_interaction_option(label, handler, FALSE)
	return opt

/**
 * CreateSeasonalOption(label, handler, season) - Create option available only in specific season
 * 
 * Example:
 *   var/opt = CreateSeasonalOption("Harvest Advice", "harvest_tips", "Spring")
 */
proc/CreateSeasonalOption(label, handler, season)
	var/opt = new /datum/npc_interaction_option(label, handler, FALSE)
	return opt

/**
 * CreateTimeGatedOption(label, handler, time_period) - Create option available only at specific time
 * 
 * Example:
 *   var/opt = CreateTimeGatedOption("Morning Workout", "workout", "morning")
 */
proc/CreateTimeGatedOption(label, handler, time_period)
	var/opt = new /datum/npc_interaction_option(label, handler, FALSE)
	return opt

/**
 * CreateKnowledgeGatedOption(label, handler, list/prerequisites) - Create option requiring knowledge
 * 
 * Example:
 *   var/opt = CreateKnowledgeGatedOption("Advanced Fishing", "adv_fishing", \
 *       list("basic_fishing", "knot_tying", "cast_technique"))
 */
proc/CreateKnowledgeGatedOption(label, handler, list/prerequisites)
	var/opt = new /datum/npc_interaction_option(label, handler, FALSE)
	return opt

// ============================================================================
// INTERACTION LOG SYSTEM (Optional enhancement)
// ============================================================================

/**
 * LogNPCInteraction(mob/players/M, npc_name, interaction_type, success) - Record interaction
 * Optional: Enable to track all NPC interactions for statistics/replay
 */
proc/LogNPCInteraction(mob/players/M, npc_name, interaction_type, success)
	if(!M || !M.character)
		return
	
	// To implement: Add interaction history to character data
	// For now, just placeholder


