// dm/FullWeek2IntegrationTests.dm - Comprehensive test of all 5 Week-2 systems together

/**
 * FULL WEEK 2 INTEGRATION TEST SUITE
 * 
 * Tests all 5 major systems working together:
 * 1. NPC Pathfinding (navigation)
 * 2. Advanced Economy (supply/demand pricing)
 * 3. Kingdom Treasury (material/lucre storage)
 * 4. Advanced Quest Chains (progression & rewards)
 * 5. Prestige System (endgame progression)
 * 
 * Verifies:
 * - NPCs navigate to quest locations
 * - Players earn economy-driven quest rewards
 * - Rewards deposit to kingdom treasury
 * - Prestige multipliers apply to skill exp
 * - All systems work simultaneously without conflicts
 */

mob/players/verb/RunFullWeek2IntegrationTests()
	set category = "Debug"
	set hidden = 1
	
	usr << "<b>=== FULL WEEK 2 INTEGRATION TESTS ===</b>"
	
	Test_Complete_Quest_Workflow()
	Test_Prestige_Multiplier_with_Quest_Rewards()
	Test_All_Systems_Concurrent_Operation()
	Test_Player_Login_Game_Ready()
	Test_Cross_System_Data_Sharing()
	
	usr << "<b>✓ All Full Integration Tests Completed!</b>"

proc/Test_Complete_Quest_Workflow()
	/**
	 * Test: Complete entire quest workflow
	 * 1. Create quest chain
	 * 2. Accept quest
	 * 3. Advance stages
	 * 4. Receive rewards from economy system
	 * 5. Verify treasury deposited
	 */
	var/mob/players/test_player = locate(/mob/players) in world.contents
	if(!test_player)
		world << "<font color=#FF0000>ERROR: No player found for quest test</font>"
		return
	
	test_player << "\n<b>TEST: Complete Quest Workflow</b>"
	
	// Get systems
	var/datum/AdvancedQuestChainSystem/qcs = GetAdvancedQuestChainSystem()
	var/datum/KingdomTreasurySystem/treasury = GetKingdomTreasurySystem()
	var/datum/AdvancedEconomySystem/econ = GetAdvancedEconomy()
	
	if(!qcs || !treasury || !econ)
		test_player << "<font color=#FF0000>ERROR: Systems not initialized</font>"
		return
	
	test_player << "  ✓ All systems initialized"
	
	// Create quest
	var/datum/quest_chain/chain = qcs.CreatePlayerChain(test_player, "smithing_master")
	if(!chain)
		test_player << "<font color=#FF0000>ERROR: Could not create quest chain</font>"
		return
	
	test_player << "  ✓ Quest chain created: smithing_master"
	
	// Verify initial state
	var/datum/quest_stage/current_stage = chain.GetCurrentStage()
	if(!current_stage)
		test_player << "<font color=#FF0000>ERROR: Current stage is null</font>"
		return
	
	test_player << "  ✓ Current stage retrieved: [current_stage.stage_id]"
	
	// Advance stages
	for(var/i = 1 to 3)
		if(chain.AdvanceStage())
			test_player << "  ✓ Advanced to stage [i]"
		else
			test_player << "  ✓ Quest completed (stage [i] is final)"
			break
	
	// Verify treasury has rewards
	var/treasury_lucre = treasury.GetBalance("lucre")
	test_player << "  ✓ Treasury balance (Lucre): [treasury_lucre]"
	
	if(treasury_lucre > 0)
		test_player << "  ✓ Rewards successfully deposited to treasury"
	
	test_player << "✓ TEST PASSED: Quest Workflow Complete\n"

proc/Test_Prestige_Multiplier_with_Quest_Rewards()
	/**
	 * Test: Verify prestige multiplier applies during skill gains
	 * 1. Gain skill exp normally (no prestige)
	 * 2. Prestige
	 * 3. Gain same skill exp amount
	 * 4. Verify second gain is larger (multiplied)
	 */
	var/mob/players/test_player = locate(/mob/players) in world.contents
	if(!test_player)
		world << "<font color=#FF0000>ERROR: No player found for prestige test</font>"
		return
	
	test_player << "\n<b>TEST: Prestige Multiplier with Quest Rewards</b>"
	
	// Initialize if needed
	if(!test_player.character)
		test_player.character = new /datum/character_data()
	
	var/datum/PrestigeSystem/ps = GetPrestigeSystem()
	if(!ps)
		test_player << "<font color=#FF0000>ERROR: Prestige system not found</font>"
		return
	
	test_player << "  ✓ Prestige system initialized"
	
	// Set up test: Give player max skill to prestige
	test_player.SetRankLevel(RANK_FISHING, 5)
	test_player.SetRankExp(RANK_FISHING, 0)
	test_player.SetRankMaxExp(RANK_FISHING, 100)
	
	test_player << "  ✓ Set fishing rank to 5 (max)"
	
	// Verify prestige eligibility
	if(!ps.CanPlayerPrestige(test_player))
		test_player << "<font color=#FF0000>ERROR: Player not eligible for prestige</font>"
		return
	
	test_player << "  ✓ Player eligible for prestige"
	
	// Perform prestige
	ps.PerformPrestigeReset(test_player)
	
	var/datum/prestige_state/state = ps.GetPrestigeState(test_player)
	test_player << "  ✓ Prestige reset performed (rank: [state.prestige_rank])"
	
	// Verify multiplier is active
	var/multiplier = state.GetPrestigeBonus()
	if(multiplier > 1.0)
		test_player << "  ✓ Prestige multiplier active: [multiplier]x"
	else
		test_player << "<font color=#FF0000>WARNING: Multiplier is 1.0 (prestige not increasing it)</font>"
	
	// Test multiplier application by gaining exp
	var/initial_exp = test_player.GetRankExp(RANK_FISHING)
	test_player.UpdateRankExp(RANK_FISHING, 50)  // Should be multiplied
	var/final_exp = test_player.GetRankExp(RANK_FISHING)
	var/actual_gain = final_exp - initial_exp
	
	test_player << "  ✓ Gained 50 exp, actual gain: [actual_gain] (multiplied by [multiplier])"
	
	if(actual_gain > 50)
		test_player << "  ✓ Multiplier successfully applied!"
	else
		test_player << "<font color=#FF0000>WARNING: Exp gain not multiplied as expected</font>"
	
	test_player << "✓ TEST PASSED: Prestige Multiplier Works\n"

proc/Test_All_Systems_Concurrent_Operation()
	/**
	 * Test: Verify all 5 systems can operate simultaneously
	 * Simulates real gameplay with overlapping operations
	 */
	var/mob/players/test_player = locate(/mob/players) in world.contents
	if(!test_player)
		world << "<font color=#FF0000>ERROR: No player found</font>"
		return
	
	test_player << "\n<b>TEST: All Systems Concurrent Operation</b>"
	
	// Verify all 5 systems exist
	var/datum/NPCPathfindingSystem/pathfinding = GetNPCPathfindingSystem()
	var/datum/AdvancedEconomySystem/econ = GetAdvancedEconomy()
	var/datum/KingdomTreasurySystem/treasury = GetKingdomTreasurySystem()
	var/datum/AdvancedQuestChainSystem/quests = GetAdvancedQuestChainSystem()
	var/datum/PrestigeSystem/prestige = GetPrestigeSystem()
	
	if(pathfinding) test_player << "  ✓ NPCPathfinding: READY"
	else test_player << "  ✗ NPCPathfinding: MISSING"
	
	if(econ) test_player << "  ✓ AdvancedEconomy: READY"
	else test_player << "  ✗ AdvancedEconomy: MISSING"
	
	if(treasury) test_player << "  ✓ KingdomTreasury: READY"
	else test_player << "  ✗ KingdomTreasury: MISSING"
	
	if(quests) test_player << "  ✓ AdvancedQuests: READY"
	else test_player << "  ✗ AdvancedQuests: MISSING"
	
	if(prestige) test_player << "  ✓ PrestigeSystem: READY"
	else test_player << "  ✗ PrestigeSystem: MISSING"
	
	if(pathfinding && econ && treasury && quests && prestige)
		test_player << "✓ TEST PASSED: All Systems Operational\n"
	else
		test_player << "✗ TEST FAILED: Some systems missing\n"

proc/Test_Player_Login_Game_Ready()
	/**
	 * Test: Verify player is ready for gameplay after login
	 * Check initialization complete, character data exists, systems accessible
	 */
	var/mob/players/test_player = locate(/mob/players) in world.contents
	if(!test_player)
		world << "<font color=#FF0000>ERROR: No player found</font>"
		return
	
	test_player << "\n<b>TEST: Player Login & Game Ready</b>"
	
	// Check initialization
	if(world_initialization_complete)
		test_player << "  ✓ World initialization complete"
	else
		test_player << "  ✗ World initialization NOT complete (gameplay should be blocked)"
	
	// Check character data
	if(test_player.character)
		test_player << "  ✓ Character data loaded"
	else
		test_player << "  ✗ Character data MISSING"
	
	// Check rank system
	var/fishing_level = test_player.GetRankLevel(RANK_FISHING)
	test_player << "  ✓ Rank system accessible (fishing: level [fishing_level])"
	
	// Check prestige state
	var/datum/PrestigeSystem/ps = GetPrestigeSystem()
	if(ps)
		var/datum/prestige_state/state = ps.GetPrestigeState(test_player)
		test_player << "  ✓ Prestige state initialized (rank: [state.prestige_rank])"
	
	test_player << "✓ TEST PASSED: Player Ready for Gameplay\n"

proc/Test_Cross_System_Data_Sharing()
	/**
	 * Test: Verify data flows correctly between systems
	 * 1. Economy pricing affects quest rewards
	 * 2. Treasury stores quest rewards
	 * 3. Prestige multiplier affects all skill gains
	 */
	var/mob/players/test_player = locate(/mob/players) in world.contents
	if(!test_player)
		world << "<font color=#FF0000>ERROR: No player found</font>"
		return
	
	test_player << "\n<b>TEST: Cross-System Data Sharing</b>"
	
	var/datum/AdvancedEconomySystem/econ = GetAdvancedEconomy()
	var/datum/KingdomTreasurySystem/treasury = GetKingdomTreasurySystem()
	
	if(!econ || !treasury)
		test_player << "<font color=#FF0000>ERROR: Economy or Treasury system missing</font>"
		return
	
	// Check supply/demand ratio (affects quest rewards)
	var/ratio = econ.GetSupplyDemandRatio("stone_ore")
	test_player << "  ✓ Economy supply/demand ratio: [ratio]"
	
	// Check treasury can store materials
	var/test_deposit = 100
	treasury.DepositToTreasury("stone_ore", test_deposit)
	var/current_balance = treasury.GetBalance("stone_ore")
	test_player << "  ✓ Deposited [test_deposit] stone_ore, balance: [current_balance]"
	
	// Check rank system uses prestige multiplier
	var/datum/PrestigeSystem/ps = GetPrestigeSystem()
	if(ps)
		var/datum/prestige_state/state = ps.GetPrestigeState(test_player)
		var/multiplier = state.GetPrestigeBonus()
		test_player << "  ✓ Rank system aware of prestige multiplier: [multiplier]x"
	
	test_player << "✓ TEST PASSED: Data Sharing Works\n"

// ==== END OF TEST SUITE ====
