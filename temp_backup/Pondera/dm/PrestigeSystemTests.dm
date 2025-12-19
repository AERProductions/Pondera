// dm/PrestigeSystemTests.dm — Test suite for Prestige System
// Tests skill reset, cosmetics, multipliers, and rank progression

proc/Test_PrestigeSystemInitialization()
	set name = "Test: Prestige System Initialization"
	world << "Testing Prestige System initialization..."
	
	var/datum/PrestigeSystem/ps = GetPrestigeSystem()
	
	if(!ps)
		world << "ERROR: Prestige system not initialized!"
		return FALSE
	
	if(!ps.initialized)
		world << "ERROR: System initialized flag not set!"
		return FALSE
	
	if(!ps.prestige_rewards || length(ps.prestige_rewards) == 0)
		world << "ERROR: No prestige rewards loaded!"
		return FALSE
	
	if(!ps.prestige_milestones || length(ps.prestige_milestones) == 0)
		world << "ERROR: No prestige milestones loaded!"
		return FALSE
	
	world << "✓ Prestige system initialized successfully"
	world << "  Rewards: [length(ps.prestige_rewards)]"
	world << "  Milestones: [length(ps.prestige_milestones)]"
	
	return TRUE

proc/Test_PrestigeEligibility()
	set name = "Test: Prestige Eligibility Check"
	world << "Testing prestige eligibility requirements..."
	
	var/datum/PrestigeSystem/ps = GetPrestigeSystem()
	var/mob/players/test_player = new /mob/players()
	test_player.name = "TestPlayer"
	test_player.character = new /datum/character_data()
	test_player.character.Initialize()
	
	// Initially ineligible (all skills level 1)
	if(ps.CanPlayerPrestige(test_player))
		world << "ERROR: Should not be eligible with level 1 skills!"
		return FALSE
	
	// Set one skill to max level
	test_player.character.frank = MAX_RANK_LEVEL  // Set fishing to 5
	
	// Now should be eligible
	if(!ps.CanPlayerPrestige(test_player))
		world << "ERROR: Should be eligible with max skill!"
		return FALSE
	
	world << "✓ Prestige eligibility check successful"
	world << "  Ineligible at level 1: ✓"
	world << "  Eligible at level [MAX_RANK_LEVEL]: ✓"
	
	return TRUE

proc/Test_PrestigeSkillReset()
	set name = "Test: Skill Reset on Prestige"
	world << "Testing skill reset mechanics..."
	
	var/datum/PrestigeSystem/ps = GetPrestigeSystem()
	var/mob/players/test_player = new /mob/players()
	test_player.name = "TestPlayer"
	test_player.character = new /datum/character_data()
	test_player.character.Initialize()
	
	// Level up some skills
	test_player.character.frank = 5
	test_player.character.crank = 4
	test_player.character.mrank = 3
	
	// Verify high levels before reset
	if(test_player.character.frank != 5)
		world << "ERROR: Skill level not set correctly!"
		return FALSE
	
	// Perform reset
	ps.ResetAllSkills(test_player)
	
	// Verify all reset to level 1
	if(test_player.character.frank != 1)
		world << "ERROR: Fishing skill not reset to 1!"
		return FALSE
	
	if(test_player.character.crank != 1)
		world << "ERROR: Crafting skill not reset to 1!"
		return FALSE
	
	world << "✓ Skill reset successful"
	world << "  Before: fishing=5, crafting=4, mining=3"
	world << "  After: all skills=1"
	
	return TRUE

proc/Test_PrestigeRankProgression()
	set name = "Test: Prestige Rank Progression"
	world << "Testing prestige rank advancement..."
	
	var/datum/PrestigeSystem/ps = GetPrestigeSystem()
	var/mob/players/test_player = new /mob/players()
	test_player.name = "TestPlayer"
	test_player.character = new /datum/character_data()
	test_player.character.Initialize()
	test_player.character.frank = MAX_RANK_LEVEL  // Eligible for prestige
	
	// Get initial state
	var/datum/prestige_state/state = ps.GetPrestigeState(test_player)
	
	if(state.prestige_rank != 0)
		world << "ERROR: Initial prestige rank should be 0!"
		return FALSE
	
	// Perform prestige
	ps.PerformPrestigeReset(test_player)
	
	// Verify rank increased
	if(state.prestige_rank != 1)
		world << "ERROR: Prestige rank should be 1 after reset!"
		return FALSE
	
	// Verify skills reset
	if(test_player.character.frank != 1)
		world << "ERROR: Skills should reset after prestige!"
		return FALSE
	
	world << "✓ Prestige rank progression successful"
	world << "  Initial rank: 0"
	world << "  After prestige: [state.prestige_rank]"
	world << "  Skills reset: [test_player.character.frank == 1]"
	
	return TRUE

proc/Test_PrestigeSkillMultiplier()
	set name = "Test: Prestige Skill Multiplier"
	world << "Testing skill exp multiplier bonus..."
	
	var/datum/PrestigeSystem/ps = GetPrestigeSystem()
	var/mob/players/player_rank0 = new /mob/players()
	player_rank0.name = "Rank0"
	player_rank0.character = new /datum/character_data()
	
	var/mob/players/player_rank5 = new /mob/players()
	player_rank5.name = "Rank5"
	player_rank5.character = new /datum/character_data()
	
	// Get states
	var/datum/prestige_state/state0 = ps.GetPrestigeState(player_rank0)
	var/datum/prestige_state/state5 = ps.GetPrestigeState(player_rank5)
	
	state0.prestige_rank = 0
	state5.prestige_rank = 5
	
	// Calculate multipliers
	var/mult0 = state0.GetPrestigeBonus(RANK_FISHING)
	var/mult5 = state5.GetPrestigeBonus(RANK_FISHING)
	
	if(mult0 != 1.0)
		world << "ERROR: Rank 0 multiplier should be 1.0x!"
		return FALSE
	
	if(mult5 != 2.25)  // 1.0 + (5 * 0.25)
		world << "ERROR: Rank 5 multiplier should be 2.25x!"
		return FALSE
	
	if(mult5 <= mult0)
		world << "ERROR: Higher rank should have higher multiplier!"
		return FALSE
	
	world << "✓ Skill multiplier calculation successful"
	world << "  Rank 0: [mult0]x"
	world << "  Rank 5: [mult5]x"
	world << "  Rank 10: [1.0 + (10 * 0.25)]x (maximum)"
	
	return TRUE

proc/Test_PrestigeCosmetics()
	set name = "Test: Prestige Cosmetics & Titles"
	world << "Testing cosmetic reward system..."
	
	var/datum/PrestigeSystem/ps = GetPrestigeSystem()
	var/mob/players/test_player = new /mob/players()
	test_player.name = "TestPlayer"
	test_player.character = new /datum/character_data()
	test_player.character.frank = MAX_RANK_LEVEL
	
	var/datum/prestige_state/state = ps.GetPrestigeState(test_player)
	
	// Prestige to rank 1
	ps.PerformPrestigeReset(test_player)
	
	// Check cosmetics assigned
	if(!state.cosmetics)
		world << "ERROR: Cosmetics not assigned after prestige!"
		return FALSE
	
	if(state.cosmetics.prestige_rank != 1)
		world << "ERROR: Cosmetic rank mismatch!"
		return FALSE
	
	// Get title
	var/title = state.GetPrestigeChatTitle()
	if(!title || !findtext(title, "★"))
		world << "ERROR: Chat title not formatted with stars!"
		return FALSE
	
	world << "✓ Prestige cosmetics successful"
	world << "  Title: [state.cosmetics.title]"
	world << "  Chat Title: [title]"
	world << "  Color: [state.cosmetics.icon_color]"
	
	return TRUE

// Verb to run all prestige tests
mob/players
	verb/RunPrestigeTests()
		set category = "Debug"
		
		world << "\n===== PRESTIGE SYSTEM TESTS ====="
		
		var/pass_count = 0
		var/test_count = 0
		
		test_count++
		if(Test_PrestigeSystemInitialization()) pass_count++
		
		test_count++
		if(Test_PrestigeEligibility()) pass_count++
		
		test_count++
		if(Test_PrestigeSkillReset()) pass_count++
		
		test_count++
		if(Test_PrestigeRankProgression()) pass_count++
		
		test_count++
		if(Test_PrestigeSkillMultiplier()) pass_count++
		
		test_count++
		if(Test_PrestigeCosmetics()) pass_count++
		
		world << "\n===== TEST RESULTS ====="
		world << "Passed: [pass_count]/[test_count]"
		
		if(pass_count == test_count)
			world << "✓ All tests passed!"
		else
			world << "✗ [test_count - pass_count] test(s) failed"
