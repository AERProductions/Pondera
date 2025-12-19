/**
 * NPC DIALOGUE SYSTEM
 * ====================
 * Conversation trees, quest assignment, recipe teaching, dialogue branching
 * 
 * Started: 12-11-25 10:00PM
 * Focus: Dynamic NPC interactions with dialogue choices and branching
 */

#define DIALOGUE_TYPE_GREETING "greeting"
#define DIALOGUE_TYPE_QUEST "quest"
#define DIALOGUE_TYPE_TEACH "teach_recipe"
#define DIALOGUE_TYPE_TRADE "trade"
#define DIALOGUE_TYPE_FACTION "faction"
#define DIALOGUE_TYPE_LORE "lore"
#define DIALOGUE_TYPE_CONDITIONAL "conditional"

/datum/dialogue_option
	var
		text = ""                 // Display text for option
		dialogue_key = ""         // Next dialogue to show if selected
		action = ""               // Action type (quest, teach, trade, etc)
		action_data = list()      // Data for action (quest_id, recipe_name, etc)
		requires_quest = ""       // Only show if player has/doesn't have quest
		requires_condition = list() // Custom conditions (level, reputation, etc)
		leads_to = list()         // Multiple possible next dialogues (branching)

/datum/dialogue_option/New(text_input, key_input)
	text = text_input
	dialogue_key = key_input

/datum/dialogue_option/proc/SetAction(action_type, data)
	action = action_type
	action_data = data

/datum/dialogue_option/proc/SetQuestRequirement(quest_id)
	requires_quest = quest_id

/datum/dialogue_node
	var
		key = ""                  // Unique dialogue ID
		npc_name = ""             // Who is speaking
		text = ""                 // NPC's dialogue text (HTML-compatible)
		emotion = ""              // NPC emotion (happy, sad, angry, neutral, excited)
		list/options = list()     // Player dialogue choices
		list/auto_reward = list() // Rewards given automatically (Lucre, items)
		has_quest = FALSE         // Does this dialogue offer a quest?
		quest_data = list()       // Quest details if offering
		teaches_recipe = ""       // Recipe name if teaching
		next_dialogue_key = ""    // Default next dialogue if no choice
		requires_npc_seen = FALSE // Has player met this NPC?

/datum/dialogue_node/New(key_input, npc_input)
	key = key_input
	npc_name = npc_input

/datum/dialogue_node/proc/SetText(dialogue_text, emotion_input = "neutral")
	text = dialogue_text
	emotion = emotion_input

/datum/dialogue_node/proc/AddOption(datum/dialogue_option/option)
	if(option)
		options += option

/datum/dialogue_node/proc/OfferQuest(quest_id, quest_title, quest_desc, reward_lucre)
	has_quest = TRUE
	quest_data["id"] = quest_id
	quest_data["title"] = quest_title
	quest_data["description"] = quest_desc
	quest_data["reward"] = reward_lucre

/datum/dialogue_node/proc/TeachRecipe(recipe_name)
	teaches_recipe = recipe_name

/datum/dialogue_node/proc/GiveReward(item_type, quantity)
	auto_reward[item_type] = quantity

/datum/npc_dialogue_system
	var
		list/all_dialogues = list()    // All dialogue nodes by key
		list/npc_states = list()       // Per-NPC state tracking (seen, quests, etc)
		
/datum/npc_dialogue_system/New()
	PopulateDialogues()

/datum/npc_dialogue_system/proc/PopulateDialogues()
	/**
	 * Create all NPC dialogue trees across story mode
	 */
	
	// === BLACKSMITH (ore buyer, crafting teacher) ===
	
	var/datum/dialogue_node/smith_greeting = new("smith_greet", "Ironforge Blacksmith")
	smith_greeting.SetText("Hail! You've come to the Ironforge? " + \
		"I'm Gorund, master blacksmith of these halls. " + \
		"I buy ore and teach smithing to those with dedication.", "happy")
	var/datum/dialogue_option/smith_opt1 = new("I want to learn smithing", "smith_teach")
	smith_opt1.SetAction(DIALOGUE_TYPE_TEACH, list("recipe" = "iron_ingot"))
	smith_greeting.AddOption(smith_opt1)
	var/datum/dialogue_option/smith_opt2 = new("I have ore to sell", "smith_trade")
	smith_opt2.SetAction(DIALOGUE_TYPE_TRADE, list())
	smith_greeting.AddOption(smith_opt2)
	all_dialogues["smith_greet"] = smith_greeting
	
	var/datum/dialogue_node/smith_teach = new("smith_teach", "Ironforge Blacksmith")
	smith_teach.SetText("Excellent! I'll teach you the basics of smelting and smithing. " + \
		"First, you need iron ore - lots of it. " + \
		"Bring me ore and I'll show you how to turn it into ingots. " + \
		"Your reward will be a fine smithing hammer when you master the craft.", "excited")
	smith_teach.TeachRecipe("iron_ingot")
	smith_teach.GiveReward("smithing_hammer", 1)
	var/datum/dialogue_option/smith_back = new("Thank you, master. I will study hard.", "smith_greet")
	smith_teach.AddOption(smith_back)
	all_dialogues["smith_teach"] = smith_teach
	
	// === MERCHANT (sells general goods, buys materials) ===
	
	var/datum/dialogue_node/merchant_greet = new("merchant_greet", "Royal Merchant")
	merchant_greet.SetText("Welcome to my trading post! " + \
		"I sell weapons, armor, and fine goods. " + \
		"I also buy materials if you have surplus.", "neutral")
	var/datum/dialogue_option/merc_opt1 = new("What quests do you have?", "merchant_quests")
	merc_opt1.SetAction(DIALOGUE_TYPE_QUEST, list())
	merchant_greet.AddOption(merc_opt1)
	var/datum/dialogue_option/merc_opt2 = new("I'd like to buy something", "merchant_greet")
	merchant_greet.AddOption(merc_opt2)
	all_dialogues["merchant_greet"] = merchant_greet
	
	var/datum/dialogue_node/merchant_quests = new("merchant_quests", "Royal Merchant")
	merchant_quests.SetText("I have several mercantile opportunities:<br><br>" + \
		"<b>Urgent Delivery</b> - Deliver spice to the Port. 150 Lucre.<br>" + \
		"<b>Supply Run</b> - Gather ore for mountain trade. 250 Lucre.<br>" + \
		"<b>Caravan Guard</b> - Protect goods from bandits. 400 Lucre.", "neutral")
	var/datum/dialogue_option/quest_urgent = new("I'll do the Urgent Delivery", "merchant_greet")
	quest_urgent.SetAction(DIALOGUE_TYPE_QUEST, list("quest_id" = "merchant_delivery"))
	merchant_quests.AddOption(quest_urgent)
	var/datum/dialogue_option/quest_supply = new("I'll run the Supply route", "merchant_greet")
	quest_supply.SetAction(DIALOGUE_TYPE_QUEST, list("quest_id" = "merchant_supply"))
	merchant_quests.AddOption(quest_supply)
	var/datum/dialogue_option/quest_guard = new("I can guard caravans", "merchant_greet")
	quest_guard.SetAction(DIALOGUE_TYPE_QUEST, list("quest_id" = "merchant_guard"))
	merchant_quests.AddOption(quest_guard)
	all_dialogues["merchant_quests"] = merchant_quests
	
	// === HEALER (sells potions, teaches healing recipes) ===
	
	var/datum/dialogue_node/healer_greet = new("healer_greet", "Forest Herbalist")
	healer_greet.SetText("Welcome to my herb garden, friend. " + \
		"I see weariness in your eyes - can I prepare a healing potion for you? " + \
		"Or perhaps you wish to learn the herbalist's trade?", "happy")
	var/datum/dialogue_option/heal_opt1 = new("Teach me herbalism", "healer_teach")
	heal_opt1.SetAction(DIALOGUE_TYPE_TEACH, list("recipe" = "healing_potion"))
	healer_greet.AddOption(heal_opt1)
	var/datum/dialogue_option/heal_opt2 = new("Do you have any quests?", "healer_quests")
	heal_opt2.SetAction(DIALOGUE_TYPE_QUEST, list())
	healer_greet.AddOption(heal_opt2)
	all_dialogues["healer_greet"] = healer_greet
	
	var/datum/dialogue_node/healer_teach = new("healer_teach", "Forest Herbalist")
	healer_teach.SetText("Splendid! Healing is the most noble craft. " + \
		"I'll teach you to identify and harvest healing herbs. " + \
		"Gather moonflower petals, and I'll show you how to brew a potion that " + \
		"restores health and cures ailments.", "excited")
	healer_teach.TeachRecipe("healing_potion")
	healer_teach.GiveReward("herb_pouch", 1)
	var/datum/dialogue_option/heal_back = new("Thank you, wise one.", "healer_greet")
	healer_teach.AddOption(heal_back)
	all_dialogues["healer_teach"] = healer_teach
	
	var/datum/dialogue_node/healer_quests = new("healer_quests", "Forest Herbalist")
	healer_quests.SetText("The forest has fallen ill - strange sickness afflicts the plants. " + \
		"I need someone brave to venture deep and retrieve moonflower essence from the Heart Grove. " + \
		"Return with it, and you'll earn my gratitude... and 300 Lucre.", "sad")
	var/datum/dialogue_option/quest_heal = new("I'll find the moonflower essence", "healer_greet")
	quest_heal.SetAction(DIALOGUE_TYPE_QUEST, list("quest_id" = "healer_flowers"))
	healer_quests.AddOption(quest_heal)
	all_dialogues["healer_quests"] = healer_quests
	
	// === FISHER (teaches fishing, buys fish) ===
	
	var/datum/dialogue_node/fisher_greet = new("fisher_greet", "Riverside Fisher")
	fisher_greet.SetText("Aye! You look like you could handle a fishing pole. " + \
		"The river's been good to me, and it can be good to you too. " + \
		"Want to learn the angler's secrets?", "happy")
	var/datum/dialogue_option/fish_opt1 = new("Teach me to fish", "fisher_teach")
	fish_opt1.SetAction(DIALOGUE_TYPE_TEACH, list("recipe" = "fishing_basic"))
	fisher_greet.AddOption(fish_opt1)
	var/datum/dialogue_option/fish_opt2 = new("I'll bring you fish", "fisher_greet")
	fisher_greet.AddOption(fish_opt2)
	all_dialogues["fisher_greet"] = fisher_greet
	
	var/datum/dialogue_node/fisher_teach = new("fisher_teach", "Riverside Fisher")
	fisher_teach.SetText("Right then! Listen close:<br>" + \
		"1. Find a good spot on the river<br>" + \
		"2. Use your fishing pole and bait<br>" + \
		"3. Watch for ripples and splashes<br>" + \
		"4. The bigger the fish, the harder they fight!<br><br>" + \
		"Start with trout - they're common but good eating.", "neutral")
	fisher_teach.TeachRecipe("fishing_basic")
	fisher_teach.GiveReward("iron_fishing_pole", 1)
	var/datum/dialogue_option/fish_back = new("Thanks for the tips!", "fisher_greet")
	fisher_teach.AddOption(fish_back)
	all_dialogues["fisher_teach"] = fisher_teach
	
	// === SCHOLAR (lore, faction info) ===
	
	var/datum/dialogue_node/scholar_greet = new("scholar_greet", "Royal Scholar")
	scholar_greet.SetText("Ah, a seeker of knowledge! How refreshing. " + \
		"I study the history and lore of our kingdom. " + \
		"Perhaps you'd like to hear of the factions that shape our world?", "excited")
	var/datum/dialogue_option/schol_opt1 = new("Tell me about the factions", "scholar_factions")
	schol_opt1.SetAction(DIALOGUE_TYPE_FACTION, list())
	scholar_greet.AddOption(schol_opt1)
	var/datum/dialogue_option/schol_opt2 = new("What of the ancient past?", "scholar_lore")
	schol_opt2.SetAction(DIALOGUE_TYPE_LORE, list())
	scholar_greet.AddOption(schol_opt2)
	all_dialogues["scholar_greet"] = scholar_greet
	
	var/datum/dialogue_node/scholar_factions = new("scholar_factions", "Royal Scholar")
	scholar_factions.SetText("<b>Three Factions Shape Our World:</b><br><br>" + \
		"<b>Kingdom of Greed</b> - The merchant faction. " + \
		"They seek profit and power through commerce. " + \
		"Based at Port Merchant Guild.<br><br>" + \
		"<b>Ironforge Council</b> - The smithing faction. " + \
		"They believe in the power of craft and metallurgy. " + \
		"Deep in the mountains, they forge legendary weapons.<br><br>" + \
		"<b>Druid Circle</b> - The nature faction. " + \
		"They seek balance and harmony with the forest. " + \
		"Their wisdom is ancient and profound.", "neutral")
	var/datum/dialogue_option/fact_back = new("Fascinating. What else do you know?", "scholar_greet")
	scholar_factions.AddOption(fact_back)
	all_dialogues["scholar_factions"] = scholar_factions
	
	var/datum/dialogue_node/scholar_lore = new("scholar_lore", "Royal Scholar")
	scholar_lore.SetText("Long ago, before the Kingdom was unified, " + \
		"the land was torn by terrible wars. " + \
		"Then came the Damascus Masters - smiths so skilled " + \
		"they could forge weapons of legend. " + \
		"Their techniques are now lost to time, but rumors say " + \
		"the patterns can still be learned by dedicated crafters.", "mysterious")
	var/datum/dialogue_option/lore_back = new("Thank you for the history lesson.", "scholar_greet")
	scholar_lore.AddOption(lore_back)
	all_dialogues["scholar_lore"] = scholar_lore

/datum/npc_dialogue_system/proc/ShowDialogue(mob/player, dialogue_key)
	/**
	 * Display a dialogue node with player options
	 */
	
	if(!ismob(player))
		return
	
	var/datum/dialogue_node/dialogue = all_dialogues[dialogue_key]
	if(!dialogue)
		player << "Dialogue not found: [dialogue_key]"
		return
	
	var/output = "<html><head><title>Conversation</title></head><body>"
	output += "<h2>" + dialogue.npc_name + "</h2><hr>"
	
	// Show emotion indicator
	var/emotion_color = "#666"
	if(dialogue.emotion == "happy")
		emotion_color = "#2d5016"  // Green
	else if(dialogue.emotion == "sad")
		emotion_color = "#003d7a"  // Blue
	else if(dialogue.emotion == "angry")
		emotion_color = "#7a0000"  // Red
	else if(dialogue.emotion == "excited")
		emotion_color = "#7a3900"  // Orange
	
	output += "<font color='[emotion_color]'><i>[dialogue.emotion]</i></font><br><br>"
	
	// Show dialogue text
	output += dialogue.text + "<br><hr>"
	
	// Show quest offer if applicable
	if(dialogue.has_quest)
		output += "<b>QUEST AVAILABLE:</b><br>"
		output += "<b>[dialogue.quest_data["title"]]</b><br>"
		output += dialogue.quest_data["description"] + "<br>"
		output += "<b>Reward: [dialogue.quest_data["reward"]] Lucre</b><br><hr>"
	
	// Show recipe teaching if applicable
	if(dialogue.teaches_recipe != "")
		output += "<b>RECIPE UNLOCKED:</b> [dialogue.teaches_recipe]<br><hr>"
	
	// Show player options
	if(length(dialogue.options) > 0)
		for(var/datum/dialogue_option/option in dialogue.options)
			output += "<a href='?dialogue=[option.dialogue_key]'>[option.text]</a><br>"
	else
		output += "<b>END OF CONVERSATION</b>"
	
	output += "</body></html>"
	player << output

/datum/npc_dialogue_system/proc/ProcessDialogueAction(mob/player, datum/dialogue_option/option)
	/**
	 * Execute dialogue action (give quest, teach recipe, etc)
	 */
	
	if(!ismob(player) || !option)
		return
	
	if(option.action == DIALOGUE_TYPE_QUEST)
		// Assign quest to player
		var/quest_id = option.action_data["quest_id"]
		if(quest_id)
			player << "You have accepted the quest: [quest_id]"
			// Wire to actual quest system when available
	
	else if(option.action == DIALOGUE_TYPE_TEACH)
		// Teach recipe
		var/recipe_name = option.action_data["recipe"]
		if(recipe_name)
			// Mark recipe as discovered in character data
			if("character" in player.vars)
				var/datum/character_data/char = player.vars["character"]
				if(istype(char) && "recipe_state" in char.vars)
					var/datum/recipe_state/rs = char.vars["recipe_state"]
					if(istype(rs))
						var/var_name = "discovered_[recipe_name]"
						rs.vars[var_name] = TRUE
			player << "You have learned: [recipe_name]"
	
	else if(option.action == DIALOGUE_TYPE_TRADE)
		// Open trade interface
		player << "Opening trade interface... (stub)"
	
	else if(option.action == DIALOGUE_TYPE_FACTION)
		player << "Faction information displayed."
	
	else if(option.action == DIALOGUE_TYPE_LORE)
		player << "Lore information displayed."

/datum/npc_dialogue_system/proc/GetGreetingDialogue(mob/npc)
	/**
	 * Get initial greeting dialogue for any NPC
	 * Returns appropriate greeting based on NPC type
	 */
	
	if(!ismob(npc))
		return null
	
	// Map NPC types to dialogue keys
	if("blacksmith" in npc.type)
		return "smith_greet"
	else if("merchant" in npc.type)
		return "merchant_greet"
	else if("healer" in npc.type || "herbalist" in npc.type)
		return "healer_greet"
	else if("fisher" in npc.type)
		return "fisher_greet"
	else if("scholar" in npc.type)
		return "scholar_greet"
	
	return null

// Global instance
var/datum/npc_dialogue_system/npc_dialogue_system = null

/proc/InitializeNPCDialogue()
	if(npc_dialogue_system)
		return npc_dialogue_system
	npc_dialogue_system = new /datum/npc_dialogue_system()
	return npc_dialogue_system

/proc/GetNPCDialogue()
	if(!npc_dialogue_system)
		InitializeNPCDialogue()
	return npc_dialogue_system

// NPC interaction verb
/mob/players/verb/TalkToNPC()
	set name = "Talk to NPC"
	set hidden = 1
	
	var/datum/npc_dialogue_system/system = GetNPCDialogue()
	var/mob/target = null
	
	// Find nearest NPC
	for(var/mob/npc in view(1))
		if(!ismob(npc, /mob/players))
			target = npc
			break
	
	if(!target)
		src << "No NPC nearby to talk to."
		return
	
	var/greeting_key = system.GetGreetingDialogue(target)
	if(greeting_key)
		system.ShowDialogue(src, greeting_key)
	else
		src << "This NPC doesn't have dialogue yet."
