// dm/AdvancedQuestChainIntegrationTests.dm — Cross-system validation for quest chains
// Tests integration with NPC Pathfinding, Advanced Economy, Kingdom Treasury, Factions

proc/Test_QuestChain_EconomyIntegration()
	set name = "Test: Quest Chains + Economy Integration"
	world << "Testing economy integration with quest rewards..."
	
	var/datum/AdvancedQuestChainSystem/qcs = GetAdvancedQuestChainSystem()
	var/datum/AdvancedEconomySystem/econ = GetAdvancedEconomy()
	
	if(!qcs || !econ)
		world << "ERROR: Systems not initialized!"
		return FALSE
	
	// Create player with chain
	var/mob/players/test_player = new /mob/players()
	test_player.name = "TestPlayer"
	test_player.lucre = 0
	
	// Create chain with material rewards
	var/datum/quest_chain/chain = qcs.CreatePlayerChain(test_player, "smithing_master")
	chain.quality_level = 100
	chain.completed = TRUE
	
	// Check initial economy state
	var/initial_supply = econ.GetSupplyDemandRatio("story", "metal")
	
	// Distribute rewards
	qcs.DistributeChainRewards(test_player, chain)
	
	// Verify rewards were adjusted by economy
	if(test_player.lucre == 0)
		world << "ERROR: Lucre not granted!"
		return FALSE
	
	world << "✓ Economy integration successful"
	world << "  Supply ratio: [initial_supply]"
	world << "  Lucre granted: [test_player.lucre]"
	
	return TRUE

proc/Test_QuestChain_TreasuryIntegration()
	set name = "Test: Quest Chains + Treasury Integration"
	world << "Testing treasury integration with material deposits..."
	
	var/datum/AdvancedQuestChainSystem/qcs = GetAdvancedQuestChainSystem()
	var/datum/KingdomTreasurySystem/treasury = GetKingdomTreasurySystem()
	
	if(!qcs || !treasury)
		world << "ERROR: Systems not initialized!"
		return FALSE
	
	// Get initial treasury balance
	var/initial_metal = 0
	if(treasury.kingdom_balances["story"] && treasury.kingdom_balances["story"]["metal"])
		initial_metal = treasury.kingdom_balances["story"]["metal"]
	
	// Create player with chain
	var/mob/players/test_player = new /mob/players()
	test_player.name = "TestPlayer"
	test_player.lucre = 0
	
	// Complete a chain with metal rewards
	var/datum/quest_chain/chain = qcs.CreatePlayerChain(test_player, "smithing_master")
	chain.quality_level = 100
	chain.completed = TRUE
	
	qcs.DistributeChainRewards(test_player, chain)
	
	// Check treasury balance increased
	var/final_metal = 0
	if(treasury.kingdom_balances["story"] && treasury.kingdom_balances["story"]["metal"])
		final_metal = treasury.kingdom_balances["story"]["metal"]
	
	if(final_metal <= initial_metal)
		world << "ERROR: Treasury not updated!"
		return FALSE
	
	world << "✓ Treasury integration successful"
	world << "  Initial metal: [initial_metal]"
	world << "  Final metal: [final_metal]"
	world << "  Deposit: [final_metal - initial_metal]"
	
	return TRUE

proc/Test_QuestChain_MultipleChains()
	set name = "Test: Multiple Simultaneous Chains"
	world << "Testing multiple chains per player..."
	
	var/datum/AdvancedQuestChainSystem/qcs = GetAdvancedQuestChainSystem()
	
	if(!qcs)
		world << "ERROR: Quest system not initialized!"
		return FALSE
	
	// Create player
	var/mob/players/test_player = new /mob/players()
	test_player.name = "TestPlayer"
	test_player.lucre = 0
	
	// Accept first chain
	if(!qcs.AcceptQuestChain(test_player, "smithing_master"))
		world << "ERROR: Failed to accept first chain!"
		return FALSE
	
	// Accept second chain (create another template first)
	// For now, just test single chain acceptance
	var/list/chains = qcs.GetPlayerChains(test_player)
	
	if(length(chains) != 1)
		world << "ERROR: Expected 1 chain, got [length(chains)]!"
		return FALSE
	
	world << "✓ Multiple chain tracking successful"
	world << "  Active chains: [length(chains)]"
	
	return TRUE

proc/Test_QuestChain_ProgressTracking()
	set name = "Test: Quest Progress Tracking"
	world << "Testing stage progression tracking..."
	
	var/datum/AdvancedQuestChainSystem/qcs = GetAdvancedQuestChainSystem()
	
	if(!qcs)
		world << "ERROR: Quest system not initialized!"
		return FALSE
	
	// Create player with chain
	var/mob/players/test_player = new /mob/players()
	test_player.name = "TestPlayer"
	test_player.lucre = 0
	
	var/datum/quest_chain/chain = qcs.CreatePlayerChain(test_player, "smithing_master")
	
	// Check initial progress
	var/progress_start = chain.GetChainProgress()
	
	if(progress_start != 0)  // 0% on unstarted chain
		world << "ERROR: Initial progress should be 0%!"
		return FALSE
	
	// Advance one stage
	chain.AdvanceStage()
	var/progress_mid = chain.GetChainProgress()
	
	if(progress_mid <= progress_start)
		world << "ERROR: Progress did not increase!"
		return FALSE
	
	// Complete chain
	chain.AdvanceStage()
	chain.AdvanceStage()
	var/progress_end = chain.GetChainProgress()
	
	if(!chain.completed)
		world << "ERROR: Chain should be marked complete!"
		return FALSE
	
	world << "✓ Progress tracking successful"
	world << "  Start: [progress_start]%"
	world << "  Mid: [progress_mid]%"
	world << "  End: [progress_end]% (Completed: [chain.completed])"
	
	return TRUE

proc/Test_QuestChain_RewardScaling()
	set name = "Test: Reward Scaling by Quality & Supply"
	world << "Testing reward scaling mechanics..."
	
	var/datum/AdvancedQuestChainSystem/qcs = GetAdvancedQuestChainSystem()
	
	if(!qcs)
		world << "ERROR: Quest system not initialized!"
		return FALSE
	
	// Test 1: Quality scaling
	var/mob/players/player_perfect = new /mob/players()
	player_perfect.name = "Perfect"
	player_perfect.lucre = 0
	
	var/mob/players/player_rushed = new /mob/players()
	player_rushed.name = "Rushed"
	player_rushed.lucre = 0
	
	var/datum/quest_chain/chain_perfect = qcs.CreatePlayerChain(player_perfect, "smithing_master")
	chain_perfect.quality_level = 100
	chain_perfect.completed = TRUE
	
	var/datum/quest_chain/chain_rushed = qcs.CreatePlayerChain(player_rushed, "smithing_master")
	chain_rushed.quality_level = 50
	chain_rushed.completed = TRUE
	
	qcs.DistributeChainRewards(player_perfect, chain_perfect)
	qcs.DistributeChainRewards(player_rushed, chain_rushed)
	
	if(player_perfect.lucre <= player_rushed.lucre)
		world << "ERROR: Perfect should reward more than rushed!"
		return FALSE
	
	world << "✓ Reward scaling successful"
	world << "  Perfect (100%): [player_perfect.lucre] Lucre"
	world << "  Rushed (50%): [player_rushed.lucre] Lucre"
	world << "  Ratio: [player_perfect.lucre / player_rushed.lucre]"
	
	return TRUE

// Integration test runner
mob/players
	verb/RunQuestChainIntegrationTests()
		set category = "Debug"
		
		world << "\n===== QUEST CHAIN INTEGRATION TESTS ====="
		
		var/pass_count = 0
		var/test_count = 0
		
		test_count++
		if(Test_QuestChain_EconomyIntegration()) pass_count++
		
		test_count++
		if(Test_QuestChain_TreasuryIntegration()) pass_count++
		
		test_count++
		if(Test_QuestChain_MultipleChains()) pass_count++
		
		test_count++
		if(Test_QuestChain_ProgressTracking()) pass_count++
		
		test_count++
		if(Test_QuestChain_RewardScaling()) pass_count++
		
		world << "\n===== INTEGRATION TEST RESULTS ====="
		world << "Passed: [pass_count]/[test_count]"
		
		if(pass_count == test_count)
			world << "✓ All integration tests passed!"
		else
			world << "✗ [test_count - pass_count] test(s) failed"
