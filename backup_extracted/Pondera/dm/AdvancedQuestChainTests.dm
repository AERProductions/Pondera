// dm/AdvancedQuestChainTests.dm — Comprehensive test suite for Advanced Quest Chains
// Tests multi-stage chains, branching, reward scaling, and cross-system integration

proc/Test_QuestChainSystemInitialization()
	set name = "Test: Quest Chain System Initialization"
	world << "Testing Quest Chain System initialization..."
	
	var/datum/AdvancedQuestChainSystem/qcs = GetAdvancedQuestChainSystem()
	
	if(!qcs)
		world << "ERROR: Quest chain system not initialized!"
		return FALSE
	
	if(!qcs.initialized)
		world << "ERROR: System initialized flag not set!"
		return FALSE
	
	if(!qcs.chain_templates || qcs.chain_templates.len == 0)
		world << "ERROR: No quest templates loaded!"
		return FALSE
	
	world << "✓ Quest chain system initialized successfully"
	world << "  Templates loaded: [qcs.chain_templates.len]"
	
	return TRUE

proc/Test_QuestChainCreation()
	set name = "Test: Quest Chain Creation"
	world << "Testing quest chain creation..."
	
	var/datum/AdvancedQuestChainSystem/qcs = GetAdvancedQuestChainSystem()
	
	// Create dummy player
	var/mob/players/test_player = new /mob/players()
	test_player.name = "TestPlayer"
	test_player.lucre = 1000
	
	// Create chain from template
	var/datum/quest_chain/chain = qcs.CreatePlayerChain(test_player, "smithing_master")
	
	if(!chain)
		world << "ERROR: Failed to create quest chain!"
		return FALSE
	
	if(chain.chain_id != "smithing_master")
		world << "ERROR: Chain ID mismatch!"
		return FALSE
	
	if(length(chain.stages) == 0)
		world << "ERROR: No stages in chain!"
		return FALSE
	
	if(chain.current_stage_index != 1)
		world << "ERROR: Starting stage index should be 1!"
		return FALSE
	
	world << "✓ Quest chain created successfully"
	world << "  Chain ID: [chain.chain_id]"
	world << "  Stages: [length(chain.stages)]"
	world << "  Starting stage: [chain.GetCurrentStage().title]"
	
	return TRUE

proc/Test_StageProgression()
	set name = "Test: Stage Progression"
	world << "Testing stage progression through chain..."
	
	var/datum/AdvancedQuestChainSystem/qcs = GetAdvancedQuestChainSystem()
	var/mob/players/test_player = new /mob/players()
	test_player.name = "TestPlayer"
	test_player.lucre = 0
	
	var/datum/quest_chain/chain = qcs.CreatePlayerChain(test_player, "smithing_master")
	
	// Check initial stage
	var/datum/quest_stage/stage1 = chain.GetCurrentStage()
	if(stage1.stage_id != "smith_basic")
		world << "ERROR: Initial stage not smith_basic!"
		return FALSE
	
	// Advance to stage 2
	chain.AdvanceStage()
	var/datum/quest_stage/stage2 = chain.GetCurrentStage()
	if(stage2.stage_id != "smith_bronze")
		world << "ERROR: Advanced stage not smith_bronze!"
		return FALSE
	
	// Advance to stage 3
	chain.AdvanceStage()
	var/datum/quest_stage/stage3 = chain.GetCurrentStage()
	if(stage3.stage_id != "smith_damascus")
		world << "ERROR: Final stage not smith_damascus!"
		return FALSE
	
	// Complete chain
	var/complete = chain.AdvanceStage()
	if(!complete || !chain.completed)
		world << "ERROR: Chain should be marked complete!"
		return FALSE
	
	world << "✓ Stage progression works correctly"
	world << "  Stage 1 → 2 → 3 → Complete"
	world << "  Final status: [chain.completed ? "COMPLETE" : "INCOMPLETE"]"
	
	return TRUE

proc/Test_RewardDistribution()
	set name = "Test: Reward Distribution"
	world << "Testing quest chain reward distribution..."
	
	var/datum/AdvancedQuestChainSystem/qcs = GetAdvancedQuestChainSystem()
	var/mob/players/test_player = new /mob/players()
	test_player.name = "TestPlayer"
	test_player.lucre = 0
	
	var/datum/quest_chain/chain = qcs.CreatePlayerChain(test_player, "smithing_master")
	chain.quality_level = 100  // Perfect completion
	chain.completed = TRUE
	
	var/initial_lucre = test_player.lucre
	
	// Distribute rewards
	qcs.DistributeChainRewards(test_player, chain)
	
	var/final_lucre = test_player.lucre
	
	if(final_lucre <= initial_lucre)
		world << "ERROR: No lucre reward distributed!"
		return FALSE
	
	world << "✓ Reward distribution successful"
	world << "  Lucre before: [initial_lucre]"
	world << "  Lucre after: [final_lucre]"
	world << "  Earned: [final_lucre - initial_lucre]"
	
	return TRUE

proc/Test_QualityModifier()
	set name = "Test: Quality Modifier Impact"
	world << "Testing quality modifier effect on rewards..."
	
	var/datum/AdvancedQuestChainSystem/qcs = GetAdvancedQuestChainSystem()
	
	// Create two chains with different quality
	var/mob/players/player1 = new /mob/players()
	player1.name = "Perfect"
	player1.lucre = 0
	
	var/mob/players/player2 = new /mob/players()
	player2.name = "Rushed"
	player2.lucre = 0
	
	var/datum/quest_chain/chain1 = qcs.CreatePlayerChain(player1, "smithing_master")
	chain1.quality_level = 100  // Perfect
	chain1.completed = TRUE
	
	var/datum/quest_chain/chain2 = qcs.CreatePlayerChain(player2, "smithing_master")
	chain2.quality_level = 50   // Rushed (50%)
	chain2.completed = TRUE
	
	qcs.DistributeChainRewards(player1, chain1)
	qcs.DistributeChainRewards(player2, chain2)
	
	var/reward_perfect = player1.lucre
	var/reward_rushed = player2.lucre
	
	if(reward_perfect <= reward_rushed)
		world << "ERROR: Perfect execution should yield more reward!"
		return FALSE
	
	var/expected_ratio = 100 / 50  // 2x
	var/actual_ratio = reward_perfect / reward_rushed
	
	world << "✓ Quality modifier working correctly"
	world << "  Perfect reward: [reward_perfect]"
	world << "  Rushed reward: [reward_rushed]"
	world << "  Ratio: [actual_ratio] (expected ~[expected_ratio])"
	
	return TRUE

proc/Test_ChainAcceptance()
	set name = "Test: Chain Acceptance & Registration"
	world << "Testing player acceptance of quest chains..."
	
	var/datum/AdvancedQuestChainSystem/qcs = GetAdvancedQuestChainSystem()
	var/mob/players/test_player = new /mob/players()
	test_player.name = "TestPlayer"
	test_player.lucre = 0
	
	if(!qcs.AcceptQuestChain(test_player, "smithing_master"))
		world << "ERROR: Failed to accept quest chain!"
		return FALSE
	
	var/list/chains = qcs.GetPlayerChains(test_player)
	if(!chains || length(chains) == 0)
		world << "ERROR: Chain not registered with player!"
		return FALSE
	
	if(!chains["smithing_master"])
		world << "ERROR: Specific chain not found in player's list!"
		return FALSE
	
	world << "✓ Chain acceptance successful"
	world << "  Player chains: [length(chains)]"
	world << "  Active: smithing_master"
	
	return TRUE

// Verb to run all tests
mob/players
	verb/RunQuestChainTests()
		set category = "Debug"
		
		world << "\n===== QUEST CHAIN SYSTEM TESTS ====="
		
		var/pass_count = 0
		var/test_count = 0
		
		// Run each test
		test_count++
		if(Test_QuestChainSystemInitialization()) pass_count++
		
		test_count++
		if(Test_QuestChainCreation()) pass_count++
		
		test_count++
		if(Test_StageProgression()) pass_count++
		
		test_count++
		if(Test_RewardDistribution()) pass_count++
		
		test_count++
		if(Test_QualityModifier()) pass_count++
		
		test_count++
		if(Test_ChainAcceptance()) pass_count++
		
		world << "\n===== TEST RESULTS ====="
		world << "Passed: [pass_count]/[test_count]"
		
		if(pass_count == test_count)
			world << "✓ All tests passed!"
		else
			world << "✗ [test_count - pass_count] test(s) failed"
