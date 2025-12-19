// dm/AdvancedEconomyTests.dm — Test suite for advanced economy system

proc/RunAllAdvancedEconomyTests()
	world << "========== ADVANCED ECONOMY TESTS =========="
	Test_EconomyInitialization()
	Test_TechTierPricing()
	Test_SupplyDemandCalculations()
	Test_KingdomSupplies()
	Test_MarketReporting()
	world << "========== TESTS COMPLETE =========="

// Test 1: Verify system initialization
proc/Test_EconomyInitialization()
	world << "Test System Initialization..."
	var/datum/AdvancedEconomySystem/econ = GetAdvancedEconomy()
	
	if(!econ)
		world << "  FAIL: Economy system not initialized"
		return
	
	if(!econ.initialized)
		world << "  FAIL: System marked as not initialized"
		return
	
	world << "  PASS: Economy system properly initialized"

// Test 2: Tech tier pricing calculations
proc/Test_TechTierPricing()
	world << "Test Tech Tier Pricing..."
	var/datum/AdvancedEconomySystem/econ = GetAdvancedEconomy()
	
	if(!econ)
		world << "  FAIL: Economy system unavailable"
		return
	
	// Test tier 1 (base price no multiplier)
	var/price_tier1 = econ.GetTechTierPrice("stone blocks", 100, 1, "story")
	var/expected_tier1 = 100
	if(price_tier1 >= 90 && price_tier1 <= 110)  // Allow for inflation variance
		world << "  PASS: Tier 1 pricing correct ([price_tier1])"
	else
		world << "  FAIL: Tier 1 pricing wrong (got [price_tier1], expected ~[expected_tier1])"
	
	// Test tier 5 (8x multiplier)
	var/price_tier5 = econ.GetTechTierPrice("legendary ore", 100, 5, "story")
	var/expected_tier5 = 800
	if(price_tier5 >= 700 && price_tier5 <= 900)  // Allow inflation variance
		world << "  PASS: Tier 5 pricing correct ([price_tier5])"
	else
		world << "  FAIL: Tier 5 pricing wrong (got [price_tier5], expected ~[expected_tier5])"

// Test 3: Supply and demand calculations
proc/Test_SupplyDemandCalculations()
	world << "Test Supply/Demand Calculations..."
	var/datum/AdvancedEconomySystem/econ = GetAdvancedEconomy()
	
	if(!econ)
		world << "  FAIL: Economy system unavailable"
		return
	
	// Get initial ratio
	var/initial_ratio = econ.GetSupplyDemandRatio("pvp", "stone")
	if(initial_ratio > 0)
		world << "  PASS: Supply/demand ratio calculated ([initial_ratio])"
	else
		world << "  FAIL: Supply/demand ratio invalid"
	
	// Test ratio after supply update
	econ.UpdateKingdomSupply("pvp", "stone", 100)
	var/updated_ratio = econ.GetSupplyDemandRatio("pvp", "stone")
	if(updated_ratio > initial_ratio)
		world << "  PASS: Supply update reflected in ratio"
	else
		world << "  FAIL: Supply update not reflected"

// Test 4: Kingdom supplies tracking
proc/Test_KingdomSupplies()
	world << "Test Kingdom Supplies..."
	var/datum/AdvancedEconomySystem/econ = GetAdvancedEconomy()
	
	if(!econ)
		world << "  FAIL: Economy system unavailable"
		return
	
	// Test supply update
	econ.UpdateKingdomSupply("story", "timber", 50)
	var/new_supply = econ.kingdom_supplies["story"]["timber"]
	
	if(new_supply > 3000)  // Should have increased
		world << "  PASS: Kingdom supply updated correctly"
	else
		world << "  FAIL: Kingdom supply not updated"
	
	// Test supply clamping (should not exceed 10000)
	econ.UpdateKingdomSupply("story", "metal", 20000)
	var/clamped_supply = econ.kingdom_supplies["story"]["metal"]
	if(clamped_supply <= 10000)
		world << "  PASS: Supply clamping works"
	else
		world << "  FAIL: Supply exceeded max: [clamped_supply]"

// Test 5: Market reporting
proc/Test_MarketReporting()
	world << "Test Market Reporting..."
	var/datum/AdvancedEconomySystem/econ = GetAdvancedEconomy()
	
	if(!econ)
		world << "  FAIL: Economy system unavailable"
		return
	
	var/report = econ.GetMarketReport()
	if(report && "Inflation" in report)
		world << "  PASS: Market report generated"
	else
		world << "  FAIL: Market report incomplete"
