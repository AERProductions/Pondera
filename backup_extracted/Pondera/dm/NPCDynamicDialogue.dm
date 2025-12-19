// ============================================================================
// NPC DYNAMIC DIALOGUE SYSTEM
// ============================================================================
/*
 * NPCDynamicDialogue.dm - 12-11-25 Time-Based NPC Greetings & Dialogue
 * 
 * Integrates NPCRoutineSystem.dm (time-based NPC behavior) with 
 * NPCInteractionHUD.dm to create dynamic opening dialogue that changes based on:
 * - Time of day (morning vs night greetings)
 * - Shop status (open/closed)
 * - NPC mood (happy vs tired)
 * - Season (seasonal flavor text)
 * - Player reputation (warm vs cold reception)
 * 
 * Wires into NPC Click() interaction to set initial HUD response
 * Uses NPCRoutineSystem.dm state (shop hours, sleep schedule, mood)
 * 
 * Pattern:
 *   1. Player clicks NPC
 *   2. NPC.Click() creates NPC_Interaction session
 *   3. GetInitialGreeting() generates time-based response
 *   4. session.SetResponse() displays in HUD
 *   5. GetInteractionOptions() returns visible dialogue choices (filtered by gates)
 */

// ============================================================================
// GREETING DIALOGUE DATABASE - Time & Season Based
// ============================================================================

var/list/NPC_GREETINGS_BY_STATE = list(
	// ===== EARLY MORNING (4-8 AM) =====
	"early_morning_awake" = list(
		"Good morning! You're up early.",
		"Ah, another early riser. What brings you here?",
		"Dawn greetings! What can I do for you?"
	),
	"early_morning_waking" = list(
		"Mmm... what? Oh, hello there. Give me a moment to wake up.",
		"*yawns* Just waking up. Is something urgent?",
		"I'm still getting my bearings. What is it?"
	),
	
	// ===== MORNING (8 AM-12 PM) =====
	"morning_shop_open" = list(
		"Welcome! Shop's open and ready. What do you need?",
		"Good morning! Come to browse?",
		"Ah, a customer! Let's see what I can help with."
	),
	"morning_shop_closed" = list(
		"Morning, but we're not open for business yet.",
		"Still setting up. Check back in a bit.",
		"We open later in the day. Give it time."
	),
	
	// ===== AFTERNOON (12 PM-5 PM) =====
	"afternoon_shop_open" = list(
		"Afternoon, friend! How can I assist?",
		"Welcome back. Looking for something special?",
		"Good to see you! What brings you by?"
	),
	"afternoon_shop_closed" = list(
		"Afternoon, but I'm closed right now. Come back later.",
		"Not open at the moment, sorry. Check again soon.",
		"Taking a break. See you when I reopen."
	),
	
	// ===== EVENING (5 PM-9 PM) =====
	"evening_shop_open" = list(
		"Evening! We're wrapping up, but I can help.",
		"Still open for a bit longer if you need something.",
		"Come in, but make it quick—closing soon."
	),
	"evening_shop_closing" = list(
		"We're closing for the day. Come back tomorrow.",
		"Shop's closing. See you in the morning!",
		"Time to close up. Visit us again tomorrow."
	),
	
	// ===== NIGHT (9 PM-4 AM) =====
	"night_awake" = list(
		"A bit late to be visiting. What's so urgent?",
		"Working late, are you?",
		"It's late. What brings you out?"
	),
	"night_sleeping" = list(
		"*drowsy* ...Huh? Who's there?",
		"*yawns* I was sleeping... This better be important.",
		"...What time is it? Why are you here?"
	),
	
	// ===== REPUTATION-BASED VARIATIONS =====
	"high_reputation" = list(
		"Ah, my friend! Always a pleasure.",
		"Good to see you! We've had good dealings.",
		"Welcome back! It's good to see you again."
	),
	"low_reputation" = list(
		"I know you. What do you want?",
		"Hmph. You again. State your business.",
		"Can't say I trust you much, but I'm listening."
	)
)

// ============================================================================
// SEASONAL DIALOGUE FLAVOR TEXT
// ============================================================================

var/list/NPC_SEASONAL_REMARKS = list(
	"Spring" = list(
		"Spring's here! Everything's coming alive.",
		"Nice weather for gathering. The forest's full of resources.",
		"Spring crops should be ready soon. Good times ahead."
	),
	"Summer" = list(
		"Hot day, isn't it? Try to stay cool.",
		"Summer's at its peak. Farmers are working hard.",
		"The heat brings out interesting opportunities."
	),
	"Autumn" = list(
		"Autumn's arrived. Time to prepare for winter.",
		"Harvest season is underway. Lots to gather.",
		"Better stock up now while supplies are good."
	),
	"Winter" = list(
		"Cold times. Make sure you're prepared.",
		"Winter's harsh. Many items are scarce right now.",
		"Good fire and warm clothes—that's what you need in winter."
	)
)

// ============================================================================
// SHOP-SPECIFIC DIALOGUE
// ============================================================================

var/list/NPC_SHOP_STATUS_DIALOGUE = list(
	"just_opened" = list(
		"Just opened up! Fresh inventory.",
		"New day, new stock. Take a look!",
		"Come in, everything's ready for sale."
	),
	"closing_soon" = list(
		"Be quick—closing in about an hour.",
		"Winding down for the day soon.",
		"Don't have long, but I'm still open."
	),
	"restocking" = list(
		"Just got a new shipment. Check out what's new.",
		"Restocked some rare items, if you're interested.",
		"Got some new inventory you might like."
	),
	"low_stock" = list(
		"Supplies are running low. Get what you need while I have it.",
		"Not much left on the shelves, sorry.",
		"Running out of stock. Don't wait too long."
	)
)

// ============================================================================
// MOOD-BASED DIALOGUE MODIFIERS
// ============================================================================

var/list/NPC_MOOD_REMARKS = list(
	"happy" = list(
		"Feeling great today!",
		"It's been a good day so far.",
		"I'm in a wonderful mood!"
	),
	"tired" = list(
		"Long day... I'm exhausted.",
		"Need some rest soon.",
		"Not my best day, I'll admit."
	),
	"neutral" = list(
		"Business as usual.",
		"Same old, same old.",
		"Just another day."
	)
)

// ============================================================================
// MAIN GREETING GENERATION PROC
// ============================================================================

/proc/GetInitialGreeting(mob/npcs/npc, mob/players/player)
	/*
	 * Generate opening dialogue based on:
	 * - Time of day
	 * - Shop status
	 * - NPC mood
	 * - Season
	 * - Player reputation
	 * 
	 * Returns: String of opening greeting text
	 */
	
	if(!npc) return "..."
	if(!player) return "Hello?"
	
	var/greeting = ""
	var/current_hour = GetCurrentGameHour()
	var/npc_name = npc.name
	var/shop_open = IsNPCShopOpen(npc_name)
	var/npc_awake = IsNPCAwake(npc_name)
	var/current_season = GetCurrentSeason()
	var/player_rep = GetPlayerNPCReputation(player, npc_name)
	
	// Step 1: Base greeting by time of day and status
	var/greeting_key = ""
	
	if(current_hour >= 4 && current_hour < 8)
		greeting_key = npc_awake ? "early_morning_awake" : "early_morning_waking"
	else if(current_hour >= 8 && current_hour < 12)
		greeting_key = shop_open ? "morning_shop_open" : "morning_shop_closed"
	else if(current_hour >= 12 && current_hour < 17)
		greeting_key = shop_open ? "afternoon_shop_open" : "afternoon_shop_closed"
	else if(current_hour >= 17 && current_hour < 21)
		greeting_key = shop_open ? "evening_shop_open" : "evening_shop_closing"
	else
		greeting_key = npc_awake ? "night_awake" : "night_sleeping"
	
	// Pick random greeting from category
	if(NPC_GREETINGS_BY_STATE[greeting_key])
		var/list/greetings = NPC_GREETINGS_BY_STATE[greeting_key]
		greeting = pick(greetings)
	else
		greeting = "Hello there."
	
	// Step 2: Add reputation modifier
	if(player_rep >= 50)
		var/list/high_rep_greetings = NPC_GREETINGS_BY_STATE["high_reputation"]
		greeting += "\n" + pick(high_rep_greetings)
	else if(player_rep <= -30)
		var/list/low_rep_greetings = NPC_GREETINGS_BY_STATE["low_reputation"]
		greeting += "\n" + pick(low_rep_greetings)
	
	// Step 3: Add seasonal remark
	if(NPC_SEASONAL_REMARKS[current_season])
		var/list/seasonal = NPC_SEASONAL_REMARKS[current_season]
		greeting += "\n\n" + pick(seasonal)
	
	// Step 4: Add shop-specific status if NPC is a merchant
	if(shop_open)
		// Check if restocking or low stock (requires NPCFoodSupplySystem integration)
		var/list/status = NPC_SHOP_STATUS_DIALOGUE["just_opened"]
		if(status)
			greeting += "\n" + pick(status)
	
	return greeting

// ============================================================================
// NPC INTERACTION INTEGRATION - Enhanced Click() Support
// ============================================================================

/**
 * GetInitialDialogueOptions() - Get available dialogue options for NPC
 * Called by NPC.Click() to populate initial interaction menu
 * Incorporates knowledge gates, reputation gates, time gates
 * 
 * 12-11-25: Integrates with NPCKnowledgeTree.dm for recipe discovery
 */
/proc/GetInitialDialogueOptions(mob/npcs/npc, mob/players/player)
	if(!npc || !player) return list()
	
	var/list/options = list()
	var/npc_name = npc.name
	
	// Base option: Ask about the NPC
	var/opt_ask = new /datum/npc_interaction_option("Ask about them", "ask_about", FALSE)
	options += opt_ask
	
	// Teaching option: If NPC teaches recipes/knowledge
	var/datum/knowledge_tree/tree = GetKnowledgeTree()
	if(tree)
		var/list/teachable = tree.GetLearnableNodesByPlayer(player, npc)
		if(teachable.len > 0)
			var/opt_teach = new /datum/npc_interaction_option("What can you teach me?", "teach_menu", FALSE)
			options += opt_teach
	
	// Trading option: If shop is open
	if(IsNPCShopOpen(npc_name))
		var/opt_trade = new /datum/npc_interaction_option("Do you buy/sell?", "trade_menu", FALSE)
		options += opt_trade
	
	// Gossip option: Time-gated (only when not in a rush)
	var/current_hour = GetCurrentGameHour()
	if(!(current_hour >= 17 && current_hour < 21))  // Not during evening closing
		var/opt_gossip = new /datum/npc_interaction_option("Got any gossip?", "gossip", FALSE)
		options += opt_gossip
	
	// Always: Leave
	var/opt_leave = new /datum/npc_interaction_option("Never mind.", "leave", TRUE)
	options += opt_leave
	
	return options

// ============================================================================
// DIALOGUE HANDLER PROCS - Called by Interact_* in NPCs
// ============================================================================

/**
 * SetInitialGreeting() - Called by NPC when player starts interaction
 * Sets the opening response text in the HUD session
 */
/mob/npcs/proc/SetInitialGreeting(mob/players/M, datum/NPC_Interaction/session)
	var/greeting = GetInitialGreeting(src, M)
	if(session)
		session.SetResponse(greeting)

/**
 * Interact_ask_about() - NPC tells about themselves
 * Generic handler; can be overridden per NPC
 */
/mob/npcs/proc/Interact_ask_about(mob/players/M, datum/NPC_Interaction/session)
	if(!session) return
	
	var/about = "I'm [src.name], a traveler. "
	about += pick(list(
		"I've seen a lot in my time.",
		"Been around these parts for a while.",
		"I try to make an honest living.",
		"Life's an adventure, isn't it?"
	))
	
	session.SetResponse(about)

/**
 * Interact_teach_menu() - Show learnable recipes/knowledge
 * Uses NPCKnowledgeTree to filter available lessons
 */
/mob/npcs/proc/Interact_teach_menu(mob/players/M, datum/NPC_Interaction/session)
	if(!session || !M.character) return
	
	var/datum/knowledge_tree/tree = GetKnowledgeTree()
	var/list/teachable = tree.GetLearnableNodesByPlayer(M, src)
	
	if(!teachable || !teachable.len)
		session.SetResponse("I don't have anything new to teach you right now.")
		return
	
	var/output = "I can teach you:\n"
	for(var/node in teachable)
		var/datum/knowledge_node/knode = node
		output += "\n• [knode.title]"
	
	session.SetResponse(output)

/**
 * Interact_trade_menu() - Show buy/sell options
 * Requires NPCMerchantSystem integration
 */
/mob/npcs/proc/Interact_trade_menu(mob/players/M, datum/NPC_Interaction/session)
	if(!session) return
	session.SetResponse("I trade in various goods. See what interests you.")

/**
 * Interact_gossip() - NPC shares local gossip
 * Time-gated, generates dynamic gossip based on game state
 */
/mob/npcs/proc/Interact_gossip(mob/players/M, datum/NPC_Interaction/session)
	if(!session) return
	
	var/gossip = pick(list(
		"Have you heard about what happened at the market?",
		"There's been some strange activity lately.",
		"The harvest has been unpredictable this year.",
		"People are talking about changes coming soon.",
		"You should hear what I've heard around town."
	))
	
	session.SetResponse(gossip)

// ============================================================================
// INTEGRATION HOOKS
// ============================================================================

/**
 * InitializeNPCDynamicDialogue() - Called during world initialization
 * Verify integration with NPCRoutineSystem.dm and NPCKnowledgeTree.dm
 */
/proc/InitializeNPCDynamicDialogue()
	// Verify NPCRoutineSystem initialized
	if(!world_initialization_complete)
		// Schedule re-check
		spawn(100)
			InitializeNPCDynamicDialogue()
		return
	
	// Log integration status
	LogSystemEvent(null, "npc_dialogue", "Dynamic dialogue system integrated")
	RegisterInitComplete("NPC Dynamic Dialogue")

// ============================================================================
// DEBUG VERBS
// ============================================================================

/mob/verb/TestNPCGreeting()
	set name = "Test NPC Greeting"
	set category = "debug"
	
	// Find first NPC in area
	var/mob/npcs/test_npc = null
	for(var/mob/npcs/npc in world)
		test_npc = npc
		break
	
	if(!test_npc)
		src << "No NPCs found in world"
		return
	
	var/greeting = GetInitialGreeting(test_npc, src)
	src << "Greeting from [test_npc.name]:\n[greeting]"

/mob/verb/TestDialogueOptions()
	set name = "Test Dialogue Options"
	set category = "debug"
	
	var/mob/npcs/test_npc = null
	for(var/mob/npcs/npc in world)
		test_npc = npc
		break
	
	if(!test_npc)
		src << "No NPCs found"
		return
	
	var/list/options = GetInitialDialogueOptions(test_npc, src)
	src << "Options from [test_npc.name]:\n"
	for(var/datum/npc_interaction_option/opt in options)
		src << "- [opt.label]\n"
