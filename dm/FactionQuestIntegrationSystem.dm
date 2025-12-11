/**
 * FACTION QUEST INTEGRATION SYSTEM
 * =================================
 * Wires NPC quests to trading routes, faction reputation, and rewards
 * 
 * Started: 12-11-25 11:00PM
 * Focus: Quest assignment, progression tracking, reward distribution
 */

#define FACTION_GREED "Kingdom of Greed"
#define FACTION_SMITHS "Ironforge Council"
#define FACTION_DRUIDS "Druid Circle"

#define QUEST_STATUS_AVAILABLE "available"
#define QUEST_STATUS_ACTIVE "active"
#define QUEST_STATUS_COMPLETED "completed"
#define QUEST_STATUS_FAILED "failed"

/datum/quest
	var
		quest_id = ""             // Unique ID
		title = ""                // Display name
		description = ""          // Full quest text
		faction = ""              // Faction offering (or "neutral")
		giver = ""                // NPC name who gives it
		objectives = list()       // Quest steps
		rewards_lucre = 0         // Lucre reward
		rewards_items = list()    // Item rewards
		reputation_gain = 0       // Faction rep gain
		level_requirement = 0     // Minimum player level
		status = QUEST_STATUS_AVAILABLE  // Current status

/datum/quest/New(id, title_input, desc)
	quest_id = id
	title = title_input
	description = desc

/datum/quest/proc/SetFaction(faction_name, npc_name)
	faction = faction_name
	giver = npc_name

/datum/quest/proc/SetRewards(lucre, rep_gain = 0)
	rewards_lucre = lucre
	reputation_gain = rep_gain

/datum/quest/proc/AddRewardItem(item_type, quantity)
	rewards_items[item_type] = quantity

/datum/quest/proc/AddObjective(objective_text)
	if(objective_text && !(objective_text in objectives))
		objectives += objective_text

/datum/faction_reputation
	var
		faction_name = ""         // Faction name
		reputation_points = 0     // Current rep (-1000 to 1000)
		quest_count = 0           // Quests completed for faction
		rank = 1                  // Rank (1-5 in faction)
		locked = FALSE            // Can do quests?

/datum/faction_reputation/New(name_input)
	faction_name = name_input

/datum/faction_reputation/proc/AddReputation(amount)
	reputation_points += amount
	reputation_points = max(-1000, min(1000, reputation_points))  // Clamp
	
	// Check for rank up
	if(reputation_points >= (rank * 200))
		rank = min(5, rank + 1)
		return TRUE  // Rank up!
	return FALSE

/datum/faction_reputation/proc/GetRankTitle()
	var/list/titles = list("Stranger", "Ally", "Friend", "Honored", "Hero")
	if(rank >= 1 && rank <= 5)
		return titles[rank]
	return "Unknown"

/datum/player_quest_progress
	var
		quest_id = ""             // Which quest
		status = QUEST_STATUS_AVAILABLE  // active, completed, failed
		progress = 0              // Completion % (0-100)
		objectives_completed = list()  // Completed objective indices

/datum/faction_quest_system
	var
		list/all_quests = list()  // Quest definitions
		list/player_quests = list()  // Player's active quests
		list/player_factions = list()  // Player's faction reps

/datum/faction_quest_system/New()
	PopulateQuests()

/datum/faction_quest_system/proc/PopulateQuests()
	/**
	 * Create all faction quests tied to story and trade routes
	 */
	
	// === KINGDOM OF GREED QUESTS ===
	
	var/datum/quest/q_delivery = new("merchant_delivery", "Urgent Delivery to Port", \
		"A shipment of spice is needed at the Port Merchant Guild immediately. " + \
		"Travel from the central market to the coast and deliver it safely. " + \
		"Watch for bandits - the roads are dangerous these days.")
	q_delivery.SetFaction(FACTION_GREED, "Royal Merchant")
	q_delivery.SetRewards(150, 25)
	q_delivery.AddObjective("Take spice cargo from merchant")
	q_delivery.AddObjective("Travel to Port Merchant Guild")
	q_delivery.AddObjective("Deliver cargo safely")
	all_quests["merchant_delivery"] = q_delivery
	
	var/datum/quest/q_supply = new("merchant_supply", "Supply Run for Mountains", \
		"The Mountain Smithy is running low on supplies. " + \
		"Gather ore and materials from the hillsides, then bring them to the mountain traders. " + \
		"A steady supply means steady profit for our guild.")
	q_supply.SetFaction(FACTION_GREED, "Royal Merchant")
	q_supply.SetRewards(250, 40)
	q_supply.AddObjective("Mine 10 iron ore")
	q_supply.AddObjective("Collect 5 copper ore")
	q_supply.AddObjective("Deliver to Mountain Smithy")
	all_quests["merchant_supply"] = q_supply
	
	var/datum/quest/q_guard = new("merchant_guard", "Caravan Guard Duty", \
		"A merchant caravan is traveling the trade routes and needs protection. " + \
		"Bandits have been spotted along the roads. " + \
		"You'll be well-paid for keeping the cargo and merchants safe.")
	q_guard.SetFaction(FACTION_GREED, "Royal Merchant")
	q_guard.SetRewards(400, 75)
	q_guard.AddObjective("Meet caravan at designated meeting point")
	q_guard.AddObjective("Defend caravan from bandits")
	q_guard.AddObjective("Escort to destination safely")
	all_quests["merchant_guard"] = q_guard
	
	// === IRONFORGE COUNCIL QUESTS ===
	
	var/datum/quest/q_ore_hunt = new("smith_ore_hunt", "Legendary Ore Expedition", \
		"Deep in the mountains lies a vein of mithril ore - stronger than steel. " + \
		"Few have the skill to survive the journey to find it. " + \
		"Bring back ore samples and you'll be recognized as a true craftsperson.")
	q_ore_hunt.SetFaction(FACTION_SMITHS, "Ironforge Blacksmith")
	q_ore_hunt.SetRewards(500, 100)
	q_ore_hunt.AddObjective("Explore deep mountain caves")
	q_ore_hunt.AddObjective("Locate mithril ore vein")
	q_ore_hunt.AddObjective("Gather at least 3 mithril ore")
	q_ore_hunt.AddObjective("Return to Mountain Smithy")
	all_quests["smith_ore_hunt"] = q_ore_hunt
	
	var/datum/quest/q_steel_craft = new("smith_steel_craft", "Master Steel Crafting", \
		"To prove your smithing prowess, craft a steel sword of superior quality. " + \
		"Smithing is as much art as it is technique. " + \
		"Show us your best work and we'll recognize your mastery.")
	q_steel_craft.SetFaction(FACTION_SMITHS, "Ironforge Blacksmith")
	q_steel_craft.SetRewards(300, 60)
	q_steel_craft.AddObjective("Gather steel materials")
	q_steel_craft.AddObjective("Craft a steel sword")
	q_steel_craft.AddObjective("Ensure quality is excellent or better")
	q_steel_craft.AddObjective("Return sword to Ironforge Blacksmith")
	all_quests["smith_steel_craft"] = q_steel_craft
	
	// === DRUID CIRCLE QUESTS ===
	
	var/datum/quest/q_moonflower = new("healer_flowers", "Moonflower Essence Quest", \
		"The forest is sick - ancient magic is fading. " + \
		"We need moonflower essence from the Heart Grove to restore balance. " + \
		"It's a dangerous journey through corrupted forest, but the druids will honor your bravery.")
	q_moonflower.SetFaction(FACTION_DRUIDS, "Forest Herbalist")
	q_moonflower.SetRewards(300, 70)
	q_moonflower.AddObjective("Navigate to Heart Grove")
	q_moonflower.AddObjective("Defeat corrupted forest guardian")
	q_moonflower.AddObjective("Collect moonflower essence")
	q_moonflower.AddObjective("Return to Druid Circle")
	all_quests["healer_flowers"] = q_moonflower
	
	var/datum/quest/q_herb_garden = new("healer_garden", "Restore the Herb Garden", \
		"Plant rare healing herbs in the Druid Circle's sacred garden. " + \
		"Each herb takes time to grow, but will eventually provide ingredients for potions. " + \
		"Help us restore what was lost.")
	q_herb_garden.SetFaction(FACTION_DRUIDS, "Forest Herbalist")
	q_herb_garden.SetRewards(200, 50)
	q_herb_garden.AddObjective("Gather herb seeds")
	q_herb_garden.AddObjective("Plant in Druid Circle garden")
	q_herb_garden.AddObjective("Tend plants for growth cycle")
	all_quests["healer_garden"] = q_herb_garden

/datum/faction_quest_system/proc/AssignQuestToPlayer(mob/player, quest_id)
	/**
	 * Give a quest to player and track progress
	 */
	
	if(!ismob(player) || !all_quests[quest_id])
		return FALSE
	
	var/datum/quest/quest = all_quests[quest_id]
	
	// Create progress tracking
	var/datum/player_quest_progress/progress = new
	progress.quest_id = quest_id
	progress.status = QUEST_STATUS_ACTIVE
	
	// Store in player (would normally use character data)
	if(!("active_quests" in player.vars))
		player.vars["active_quests"] = list()
	
	player.vars["active_quests"][quest_id] = progress
	
	player << "Quest accepted: [quest.title]"
	return TRUE

/datum/faction_quest_system/proc/CompleteQuest(mob/player, quest_id)
	/**
	 * Mark quest complete and give rewards
	 */
	
	if(!ismob(player) || !all_quests[quest_id])
		return FALSE
	
	var/datum/quest/quest = all_quests[quest_id]
	
	// Give Lucre reward
	if(quest.rewards_lucre > 0)
		if("lucre" in player.vars)
			player.vars["lucre"] += quest.rewards_lucre
			player << "Received [quest.rewards_lucre] Lucre!"
	
	// Give item rewards
	for(var/item_type in quest.rewards_items)
		var/qty = quest.rewards_items[item_type]
		player << "Received [qty]x [item_type]!"
	
	// Give faction reputation
	if(quest.faction && quest.reputation_gain > 0)
		UpdateFactionReputation(player, quest.faction, quest.reputation_gain)
	
	// Mark complete
	if("active_quests" in player.vars && quest_id in player.vars["active_quests"])
		var/datum/player_quest_progress/progress = player.vars["active_quests"][quest_id]
		progress.status = QUEST_STATUS_COMPLETED
		progress.progress = 100
	
	player << "<b>Quest Complete!</b> [quest.title]"
	return TRUE

/datum/faction_quest_system/proc/UpdateFactionReputation(mob/player, faction_name, rep_gain)
	/**
	 * Update player's faction reputation
	 */
	
	if(!ismob(player))
		return
	
	// Initialize faction reps if needed
	if(!("faction_reps" in player.vars))
		player.vars["faction_reps"] = list()
	
	var/list/factions = player.vars["faction_reps"]
	
	if(!(faction_name in factions))
		factions[faction_name] = new /datum/faction_reputation(faction_name)
	
	var/datum/faction_reputation/rep = factions[faction_name]
	var/ranked_up = rep.AddReputation(rep_gain)
	
	player << "You've gained [rep_gain] reputation with [faction_name]!"
	
	if(ranked_up)
		player << "<b>PROMOTED!</b> You are now [rep.GetRankTitle()] of the [faction_name]!"

/datum/faction_quest_system/proc/ShowQuestLog(mob/player)
	/**
	 * Display player's active quests and progress
	 */
	
	if(!ismob(player))
		return
	
	var/output = "<html><head><title>Quest Log</title></head><body>"
	output += "<h1>QUEST LOG</h1><hr>"
	
	if(!("active_quests" in player.vars) || length(player.vars["active_quests"]) == 0)
		output += "No active quests.<br>"
	else
		output += "<b>Active Quests:</b><br>"
		for(var/quest_id in player.vars["active_quests"])
			var/datum/player_quest_progress/prog = player.vars["active_quests"][quest_id]
			var/datum/quest/q = all_quests[quest_id]
			
			if(q)
				output += "<b>[q.title]</b> ([prog.progress]% complete)<br>"
				output += "[q.description]<br>"
				
				if(length(prog.objectives_completed) > 0)
					output += "Progress:<br>"
					for(var/i = 1; i <= length(q.objectives); i++)
						var/check = (i in prog.objectives_completed) ? "✓" : "○"
						output += "[check] [q.objectives[i]]<br>"
				output += "<br>"
	
	output += "<hr><b>Faction Reputation:</b><br>"
	
	if("faction_reps" in player.vars)
		for(var/faction in player.vars["faction_reps"])
			var/datum/faction_reputation/rep = player.vars["faction_reps"][faction]
			output += "[faction]: [rep.GetRankTitle()] ([rep.reputation_points] rep)<br>"
	else
		output += "No faction reputation yet.<br>"
	
	output += "</body></html>"
	player << output

/datum/faction_quest_system/proc/ShowAvailableQuests(mob/player, faction_name = "")
	/**
	 * Show quests available for player
	 */
	
	if(!ismob(player))
		return
	
	var/output = "<html><head><title>Available Quests</title></head><body>"
	output += "<h1>AVAILABLE QUESTS</h1><hr>"
	
	for(var/quest_id in all_quests)
		var/datum/quest/q = all_quests[quest_id]
		
		// Filter by faction if specified
		if(faction_name && q.faction != faction_name)
			continue
		
		output += "<b>[q.title]</b><br>"
		output += "Faction: [q.faction]<br>"
		output += "Reward: [q.rewards_lucre] Lucre<br>"
		output += "[q.description]<br>"
		output += "<a href='?accept_quest=[quest_id]'>Accept Quest</a><br><br>"
	
	output += "</body></html>"
	player << output

// Global instance
var/datum/faction_quest_system/faction_quest_system = null

/proc/InitializeFactionQuests()
	if(faction_quest_system)
		return faction_quest_system
	faction_quest_system = new /datum/faction_quest_system()
	return faction_quest_system

/proc/GetFactionQuests()
	if(!faction_quest_system)
		InitializeFactionQuests()
	return faction_quest_system
