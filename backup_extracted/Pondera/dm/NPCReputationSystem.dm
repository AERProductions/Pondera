// ============================================================================
// NPC REPUTATION SYSTEM
// ============================================================================
/*
 * NPCReputationSystem.dm - 12-12-25 Player Standing & Relationship Tracking
 * 
 * Unified reputation system tracking player standing with all NPCs:
 * - Range: -100 (hated) to +100 (beloved)
 * - Persistent: Saved/loaded with character data
 * - Dynamic effects:
 *   * Knowledge gates: High rep unlocks exclusive recipes
 *   * Pricing: Merchants adjust prices based on rep (good = discount, bad = markup)
 *   * Dialogue: NPC greeting/mood changes based on rep
 *   * Quest availability: Some quests gated by reputation
 *   * Gossip chain: NPCs talk about player, spread reputation changes
 * 
 * Integrates with:
 * - CharacterData.dm (persistent storage)
 * - NPCKnowledgeTree.dm (rep gates on knowledge nodes)
 * - NPCMerchantSystem.dm (pricing modifiers)
 * - NPCDynamicDialogue.dm (dialogue modifiers)
 * - InitializationManager.dm (background gossip processor)
 */

// ============================================================================
// NPC REPUTATION DATUM
// ============================================================================

/datum/npc_reputation
	var/player_ckey
	var/npc_name
	var/standing = 0
	var/tier = "neutral"
	var/list/action_history = list()
	var/last_modified
	var/gossip_spread = 0

/datum/npc_reputation/New(player, npc)
	..()
	player_ckey = player
	npc_name = npc
	standing = 0
	tier = "neutral"
	UpdateTier()

/datum/npc_reputation/proc/ModifyReputation(change, reason = "")
	standing += change
	standing = clamp(standing, -100, 100)
	last_modified = world.time
	action_history += list(list("change" = change, "reason" = reason, "time" = world.time))
	if(length(action_history) > 20)
		while(length(action_history) > 20)
			action_history.Cut(1, 2)
	UpdateTier()
	return standing

/datum/npc_reputation/proc/UpdateTier()
	if(standing <= -60)
		tier = "hated"
	if(standing > -60 && standing <= -30)
		tier = "disliked"
	if(standing > -30 && standing <= 29)
		tier = "neutral"
	if(standing > 29 && standing <= 59)
		tier = "liked"
	if(standing > 59 && standing <= 89)
		tier = "trusted"
	if(standing > 89)
		tier = "beloved"

/datum/npc_reputation/proc/GetTierDescription()
	switch(tier)
		if("hated")
			return "They despise you."
		if("disliked")
			return "They don't trust you."
		if("neutral")
			return "They're indifferent to you."
		if("liked")
			return "They enjoy your company."
		if("trusted")
			return "They trust you."
		if("beloved")
			return "They hold you in highest regard."
	return "Neutral standing."

/datum/npc_reputation/proc/GetPricingModifier()
	switch(tier)
		if("hated")
			return 1.5
		if("disliked")
			return 1.25
		if("neutral")
			return 1.0
		if("liked")
			return 0.75
		if("trusted")
			return 0.6
		if("beloved")
			return 0.5
	return 1.0

/datum/npc_reputation/proc/CanLearnExclusiveRecipe()
	return (tier == "trusted" || tier == "beloved")

/datum/npc_reputation/proc/GetReputationDescription()
	var/output = "[npc_name]: [standing]/100\n"
	output += "[GetTierDescription()]\n"
	output += "Price modifier: x[GetPricingModifier()]\n"
	if(CanLearnExclusiveRecipe())
		output += "Status: Exclusive recipes unlocked!\n"
	return output

// ============================================================================
// GLOBAL REPUTATION MANAGER
// ============================================================================

/datum/reputation_manager
	var/list/player_reputations = list()
	var/gossip_frequency = 100
	var/last_gossip = 0

/datum/reputation_manager/New()
	..()
	player_reputations = list()
	last_gossip = 0

/datum/reputation_manager/proc/GetPlayerReputation(player_ckey, npc_name)
	var/list/player_reps = player_reputations[player_ckey]
	if(!player_reps)
		player_reps = list()
		player_reputations[player_ckey] = player_reps
	var/datum/npc_reputation/rep = player_reps[npc_name]
	if(!rep)
		rep = new /datum/npc_reputation(player_ckey, npc_name)
		player_reps[npc_name] = rep
	return rep

/datum/reputation_manager/proc/ModifyPlayerReputation(player_ckey, npc_name, change, reason = "")
	var/datum/npc_reputation/rep = GetPlayerReputation(player_ckey, npc_name)
	rep.ModifyReputation(change, reason)
	rep.gossip_spread = 0
	return rep.standing

/datum/reputation_manager/proc/GetAllPlayerReputations(player_ckey)
	return player_reputations[player_ckey] || list()

/datum/reputation_manager/proc/BroadcastGossip(player_ckey, npc_name, change)
	if(change > 15 || change < -15)
		var/list/all_npcs = player_reputations[player_ckey]
		if(!all_npcs) return
		var/gossip_count = 0
		for(var/other_npc in all_npcs)
			if(other_npc == npc_name) continue
			if(gossip_count > 3) break
			var/datum/npc_reputation/other_rep = all_npcs[other_npc]
			if(!other_rep) continue
			var/gossip_modifier = GetGossipModifier(npc_name, other_npc)
			var/gossip_change = change * gossip_modifier
			if(abs(gossip_change) > 5)
				other_rep.ModifyReputation(gossip_change, "heard about your actions")
				gossip_count++

/datum/reputation_manager/proc/GetGossipModifier(npc_a, npc_b)
	return 0.5 + (world.timeofday % 50) * 0.01

/datum/reputation_manager/proc/ProcessGossip()
	set background = 1
	set waitfor = 0
	while(1)
		sleep(world.fps * 50)
		for(var/player_ckey in player_reputations)
			var/list/player_reps = player_reputations[player_ckey]
			if(!player_reps) continue
			for(var/npc_name in player_reps)
				var/datum/npc_reputation/rep = player_reps[npc_name]
				if(!rep.gossip_spread && abs(rep.standing) > 30)
					BroadcastGossip(player_ckey, npc_name, rep.standing * 0.1)
					rep.gossip_spread = 1

// ============================================================================
// REPUTATION ACTION HANDLERS
// ============================================================================

/proc/ReputationAction(player_ckey, npc_name, action_type, value = 0)
	if(!global_reputation_manager)
		return 0
	var/change = 0
	var/reason = ""
	switch(action_type)
		if("helped")
			change = 10
			reason = "you helped them"
		if("traded_fairly")
			change = 5
			reason = "you traded fairly"
		if("traded_poorly")
			change = -10
			reason = "they feel cheated"
		if("stole")
			change = -25
			reason = "you stole from them"
		if("insulted")
			change = -15
			reason = "you insulted them"
		if("killed_enemy")
			change = 20
			reason = "you defeated their enemy"
		if("learned_recipe")
			change = 3
			reason = "you learned their teachings"
		if("completed_quest")
			change = 15 + value
			reason = "you completed their quest"
		if("failed_quest")
			change = -20
			reason = "you failed their quest"
		if("ignored_request")
			change = -5
			reason = "you ignored their request"
	return global_reputation_manager.ModifyPlayerReputation(player_ckey, npc_name, change, reason)

// ============================================================================
// CHARACTER DATA INTEGRATION
// ============================================================================

/proc/SaveReputationData(mob/players/M)
	if(!M || !M.character || !global_reputation_manager)
		return
	var/list/all_reps = global_reputation_manager.GetAllPlayerReputations(M.ckey)
	var/list/save_data = list()
	for(var/npc_name in all_reps)
		var/datum/npc_reputation/rep = all_reps[npc_name]
		save_data[npc_name] = list("standing" = rep.standing, "tier" = rep.tier, "last_modified" = rep.last_modified)
	M.character.reputation_data = save_data

/proc/LoadReputationData(mob/players/M)
	if(!M || !M.character || !global_reputation_manager)
		return
	if(!M.character.reputation_data)
		return
	for(var/npc_name in M.character.reputation_data)
		var/list/rep_data = M.character.reputation_data[npc_name]
		var/datum/npc_reputation/rep = global_reputation_manager.GetPlayerReputation(M.ckey, npc_name)
		rep.standing = rep_data["standing"]
		rep.tier = rep_data["tier"]
		rep.last_modified = rep_data["last_modified"]

// ============================================================================
// GLOBAL INSTANCE
// ============================================================================

var/datum/reputation_manager/global_reputation_manager = null

/proc/InitializeReputationSystem()
	if(!global_reputation_manager)
		global_reputation_manager = new /datum/reputation_manager()
		spawn global_reputation_manager.ProcessGossip()
		RegisterInitComplete("Reputation System")

/proc/GetReputationManager()
	if(!global_reputation_manager)
		InitializeReputationSystem()
	return global_reputation_manager

// ============================================================================
// PLAYER-FACING REPUTATION DISPLAY
// ============================================================================

/mob/players/verb/ViewMyReputation()
	set name = "View My Reputation"
	set category = "info"
	var/datum/reputation_manager/rep_mgr = GetReputationManager()
	if(!rep_mgr)
		src << "Reputation system not initialized"
		return
	var/list/my_reps = rep_mgr.GetAllPlayerReputations(src.ckey)
	if(!my_reps || !length(my_reps))
		src << "You haven't met anyone yet."
		return
	var/output = "<b>=== YOUR REPUTATION ===</b>\n"
	for(var/npc_name in my_reps)
		var/datum/npc_reputation/rep = my_reps[npc_name]
		output += "\n[rep.GetReputationDescription()]"
	src << output

/mob/players/verb/ViewNPCReputation(npc_name as text)
	set name = "View NPC Reputation"
	set category = "info"
	var/datum/reputation_manager/rep_mgr = GetReputationManager()
	var/datum/npc_reputation/rep = rep_mgr.GetPlayerReputation(src.ckey, npc_name)
	src << "Reputation with [npc_name]:\n[rep.GetReputationDescription()]"

// ============================================================================
// INTEGRATION HOOKS FOR OTHER SYSTEMS
// ============================================================================

/proc/ApplyReputationPricingModifier(player_ckey, npc_name, base_price)
	var/datum/reputation_manager/rep_mgr = GetReputationManager()
	var/datum/npc_reputation/rep = rep_mgr.GetPlayerReputation(player_ckey, npc_name)
	return base_price * rep.GetPricingModifier()

/proc/CheckReputationKnowledgeGate(player_ckey, npc_name, gate_type = "")
	var/datum/reputation_manager/rep_mgr = GetReputationManager()
	var/datum/npc_reputation/rep = rep_mgr.GetPlayerReputation(player_ckey, npc_name)
	switch(gate_type)
		if("exclusive")
			return rep.CanLearnExclusiveRecipe()
		if("basic")
			return 1
	return 1

// ============================================================================
// DEBUG VERBS
// ============================================================================

/mob/verb/TestReputationActions()
	set name = "Test Reputation Actions"
	set category = "debug"
	var/npc_name = "Test NPC"
	ReputationAction(src.ckey, npc_name, "helped")
	ReputationAction(src.ckey, npc_name, "helped")
	ReputationAction(src.ckey, npc_name, "completed_quest", 10)
	var/datum/reputation_manager/rep_mgr = GetReputationManager()
	var/datum/npc_reputation/rep = rep_mgr.GetPlayerReputation(src.ckey, npc_name)
	src << "Test reputation with [npc_name]: [rep.standing]\n"
	src << "Tier: [rep.tier]\n"
	src << "Price modifier: x[rep.GetPricingModifier()]\n"
	src << "[rep.GetReputationDescription()]"

/mob/verb/SetReputationDebug(npc as text, value as num)
	set name = "Set Reputation (Debug)"
	set category = "debug"
	var/datum/reputation_manager/rep_mgr = GetReputationManager()
	var/datum/npc_reputation/rep = rep_mgr.GetPlayerReputation(usr.ckey, npc)
	rep.standing = clamp(value, -100, 100)
	rep.UpdateTier()
	usr << "Set [npc] reputation to [rep.standing] ([rep.tier])"
