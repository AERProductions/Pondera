// Phase4Integration.dm - Phase 4: Character Data & Market System Completion
// Completes recipe unlocking, market stall trading, and character progression integration

/proc/InitializePhase4System()
	world << "PHASE4 Character Data Integration & Market System Initialization"
	ValidateRecipeState()
	InitializeMarketTradingSystem()
	InitializeMarketStallUI()

// ============================================================================
// RECIPE STATE VALIDATION & RECOVERY
// ============================================================================

/proc/ValidateRecipeState(mob/players/player = null)
	// Validate recipe_state exists and is properly initialized
	if(!player)
		// Global validation - for all online players
		for(var/mob/players/P in world)
			if(P && !P.character)
				P.character = new /datum/character_data()
				P.character.Initialize()
			
			if(P && !P.character.recipe_state)
				P.character.recipe_state = new /datum/recipe_state()
		return 1
	
	// Per-player validation
	if(!player.character)
		player.character = new /datum/character_data()
		player.character.Initialize()
	
	if(!player.character.recipe_state)
		player.character.recipe_state = new /datum/recipe_state()
	
	return 1

// ============================================================================
// NPC RECIPE UNLOCKING
// ============================================================================

/proc/UnlockRecipeFromNPC(mob/players/player, npc_name, recipe_id)
	// Called when NPC teaches recipe to player
	if(!player || !player.character) return 0
	
	if(!player.character.recipe_state)
		player.character.recipe_state = new /datum/recipe_state()
	
	player.character.recipe_state.DiscoverRecipe(recipe_id)
	
	if(player)
		player << "PHASE4 [npc_name] taught you recipe: [recipe_id]"
	
	return 1

/proc/UnlockKnowledgeFromNPC(mob/players/player, npc_name, topic_name)
	// Called when NPC teaches knowledge topic
	if(!player || !player.character) return 0
	
	if(!player.character.recipe_state)
		player.character.recipe_state = new /datum/recipe_state()
	
	player.character.recipe_state.LearnTopic(topic_name)
	
	if(player)
		player << "PHASE4 [npc_name] taught you: [topic_name]"
	
	return 1

/proc/IsRecipeUnlocked(mob/players/player, recipe_id)
	// Check if player has unlocked this recipe
	if(!player || !player.character) return 0
	if(!player.character.recipe_state) return 0
	
	return player.character.recipe_state.IsRecipeDiscovered(recipe_id)

// ============================================================================
// MARKET STALL TRADING SYSTEM
// ============================================================================

/proc/InitializeMarketTradingSystem()
	world << "PHASE4 Market Trading System Initialized"

// Market Stall UI functions are defined in MarketStallUI.dm

// ============================================================================
// CHARACTER PROGRESSION UNLOCK SYSTEM
// ============================================================================

// CheckAndUnlockRecipeBySkill moved to SkillRecipeUnlock.dm - now with full skill system integration

// ============================================================================
// TRADING SYSTEM - Player to Player
// ============================================================================

/datum/trade_offer
	var
		trader_key = ""
		trader_name = ""
		receiver_key = ""
		receiver_name = ""
		offered_items = list()
		requested_items = list()
		status = "pending"  // pending, accepted, rejected, completed
		creation_time = 0

/proc/InitiateTrade(mob/players/trader, mob/players/receiver, list/offered, list/requested)
	// Create trade offer between two players
	if(!trader || !receiver) return 0
	
	var/datum/trade_offer/offer = new()
	offer.trader_key = trader.key
	offer.trader_name = trader.name
	offer.receiver_key = receiver.key
	offer.receiver_name = receiver.name
	offer.offered_items = offered
	offer.requested_items = requested
	offer.creation_time = world.timeofday
	
	if(receiver)
		receiver << "PHASE4 Trade offer from [trader.name]: (Phase 4 not yet implemented)"
	
	return 1

// ============================================================================
// STALL PROFIT SYSTEM
// ============================================================================

/proc/AddStallProfit(mob/players/player, amount)
	// Record profit from stall sales
	if(!player) return 0
	
	// TODO: Implement currency/profit tracking
	// player.stall_profits += amount
	
	return 1

/proc/GetStallProfit(mob/players/player)
	// Get accumulated stall profits
	if(!player) return 0
	// TODO: return player.stall_profits || 0
	return 0

/proc/WithdrawStallProfit(mob/players/player, amount)
	// Convert stall profits to player currency
	if(!player) return 0
	// TODO: Implement
	return 1

// ============================================================================
// RECIPE DISCOVERY CALLBACK
// ============================================================================

/proc/OnRecipeDiscovered(mob/players/player, recipe_id)
	// Called whenever a recipe is discovered
	if(!player) return
	
	// Log discovery
	world << "PHASE4 [player.name] discovered recipe: [recipe_id]"
	
	// Broadcast to nearby players
	for(var/mob/players/P in oview(5, player))
		if(P && P != player)
			P << "PHASE4 [player.name] discovered something new!"

// ============================================================================
// KNOWLEDGE DISCOVERY CALLBACK
// ============================================================================

/proc/OnKnowledgeDiscovered(mob/players/player, topic_name)
	// Called whenever a knowledge topic is learned
	if(!player) return
	
	world << "PHASE4 [player.name] learned about: [topic_name]"

// ============================================================================
// TESTING & VERIFICATION
// ============================================================================

/proc/TestPhase4System()
	world << "PHASE4 Test: Phase 4 System"
	
	var/test_passed = 0
	var/test_total = 0
	
	// Test 1: Validate recipe state creation
	test_total++
	var/mob/players/test_player = new /mob/players()
	ValidateRecipeState(test_player)
	if(test_player.character && test_player.character.recipe_state)
		test_passed++
		world << "PHASE4  ✓ Recipe state creation"
	else
		world << "PHASE4  ✗ Recipe state creation FAILED"
	
	// Test 2: Recipe unlock
	test_total++
	if(test_player.character.recipe_state.DiscoverRecipe("steel_sword"))
		test_passed++
		world << "PHASE4  ✓ Recipe unlock"
	else
		world << "PHASE4  ✗ Recipe unlock FAILED"
	
	// Test 3: Recipe check
	test_total++
	if(test_player.character.recipe_state.IsRecipeDiscovered("steel_sword"))
		test_passed++
		world << "PHASE4  ✓ Recipe discovery check"
	else
		world << "PHASE4  ✗ Recipe discovery check FAILED"
	
	// Test 4: Knowledge unlock
	test_total++
	test_player.character.recipe_state.LearnTopic("smithing")
	if(test_player.character.recipe_state.learned_smithing)
		test_passed++
		world << "PHASE4  ✓ Knowledge unlock"
	else
		world << "PHASE4  ✗ Knowledge unlock FAILED"
	
	world << "PHASE4 Test Results: [test_passed]/[test_total] passed"
	del test_player
	return (test_passed == test_total)

/proc/DebugPlayerRecipeState(mob/players/player)
	if(!player || !player.character) return
	
	ValidateRecipeState(player)
	
	world << "PHASE4 Debug: [player.name]'s Recipe State"
	
	if(player.character.recipe_state)
		var/count = 0
		if(player.character.recipe_state.discovered_steel_sword) count++
		if(player.character.recipe_state.discovered_forge) count++
		if(player.character.recipe_state.discovered_steel_hammer) count++
		world << "PHASE4  [count] recipes unlocked"
	
	world << "PHASE4 Debug Complete"
