/**
 * EconomicGovernanceSystem.dm
 * Phase 15: Economic Governance & Market Stability
 * 
 * Purpose: Government control systems to prevent economy abuse
 * 
 * Features:
 * - Government treasury management
 * - Market regulations & price controls
 * - Tax collection & redistribution
 * - Inflation/deflation management
 * - Economic crime detection
 * - Trade restrictions
 * - Monopoly prevention
 * 
 * Tick Schedule:
 * - T+400: Economic governance initialization
 * - T+401: Tax collection processor
 * - T+402: Market regulation engine
 * - T+403: Economic crime detection
 * - T+404+: Background loops
 */

// ============================================================================
// GOVERNMENT TREASURY & FINANCIAL MANAGEMENT
// ============================================================================

/datum/kingdom_treasury
	/**
	 * kingdom_treasury
	 * Kingdom's financial state
	 * One per continent/kingdom
	 */
	var
		kingdom_name = ""
		
		// Treasury funds
		total_reserves = 100000    // Base lucre in treasury
		tax_pool = 0               // Collected but not yet allocated
		emergency_fund = 0         // For crisis relief
		development_fund = 0       // For infrastructure
		defense_fund = 0           // For military/security
		
		// Revenue sources
		total_tax_collected = 0    // Lifetime tax revenue
		trade_tax_rate = 0.05      // 5% on all trades
		property_tax_rate = 0.02   // 2% on deeds/territory
		income_tax_rate = 0.08     // 8% on wages/salaries
		
		// Spending
		total_spent = 0            // Lifetime expenditure
		monthly_budget = 50000     // Monthly allocations
		
		// Economic indicators
		inflation_rate = 0.0       // % per month
		unemployment_rate = 0.0    // % of population
		gdp_estimate = 0           // Gross economic output
		economic_health = "stable" // stable, growing, declining, crisis

/proc/GetGovernmentTreasury(kingdom_name)
	/**
	 * GetGovernmentTreasury(kingdom_name)
	 * Get kingdom's treasury datum
	 * Returns: /datum/kingdom_treasury or null
	 */
	
	// Would retrieve from global treasuries list
	// indexed by kingdom name
	return null

/proc/AddToTreasuryTax(kingdom_name, tax_amount)
	/**
	 * AddToTreasuryTax(kingdom_name, tax_amount)
	 * Add collected taxes to treasury tax pool
	 */
	
	var/datum/kingdom_treasury/treasury = GetGovernmentTreasury(kingdom_name)
	if(!treasury) return FALSE
	
	// Would add to treasury.tax_pool
	// Would update treasury.total_tax_collected
	
	world.log << "TREASURY: Added [tax_amount] lucre in taxes"
	return TRUE

/proc/AllocateTreasuryFunds(kingdom_name, allocation_map)
	/**
	 * AllocateTreasuryFunds(kingdom_name, allocation_map)
	 * Distribute treasury tax pool into specific funds
	 * allocation_map: list("emergency"=percent, "development"=percent, etc)
	 */
	
	var/datum/kingdom_treasury/treasury = GetGovernmentTreasury(kingdom_name)
	if(!treasury) return FALSE
	
	// Would distribute treasury.tax_pool according to allocations
	// Reset tax_pool to 0 after allocation
	
	world.log << "TREASURY: Allocated funds"
	return TRUE

/proc/WithdrawFromTreasury(kingdom_name, amount, fund_type)
	/**
	 * WithdrawFromTreasury(kingdom_name, amount, fund_type)
	 * Spend money from specific treasury fund
	 * fund_type: "emergency", "development", "defense", etc
	 */
	
	var/datum/kingdom_treasury/treasury = GetGovernmentTreasury(kingdom_name)
	if(!treasury) return FALSE
	
	// Would check fund balance
	// Would deduct from appropriate fund
	// Would track spending
	
	world.log << "TREASURY: Withdrew [amount] from [fund_type]"
	return TRUE

// ============================================================================
// TAX COLLECTION SYSTEM
// ============================================================================

/proc/CalculateTradeTax(player, buyer, seller, transaction_value)
	/**
	 * CalculateTradeTax(player, buyer, seller, transaction_value)
	 * Calculate tax on player-to-player transactions
	 * Returns: tax amount
	 */
	
	if(!buyer || !seller) return 0
	
	// Tax on trade depends on:
	// - Base trade tax rate (5%)
	// - Territory ownership (higher tax if in enemy land)
	// - Economic tier (higher tier pays more)
	// - Trade volume (bulk trades get discount)
	
	var/tax_rate = 0.05  // Base 5%
	
	// Framework: would apply modifiers
	
	var/tax_amount = transaction_value * tax_rate
	return tax_amount

/proc/CalculatePropertyTax(territory)
	/**
	 * CalculatePropertyTax(territory)
	 * Calculate monthly tax on deed/territory ownership
	 * Returns: monthly tax due
	 */
	
	if(!territory) return 0
	
	// Property tax depends on:
	// - Territory tier (large = higher tax)
	// - Market value of resources (higher value = higher tax)
	// - Improvements (buildings, roads)
	// - Economic tier of owner
	
	var/base_tax = 100  // Base per month
	
	// Framework: would apply modifiers
	
	return base_tax

/proc/CollectTaxes()
	/**
	 * CollectTaxes()
	 * Process all tax collection
	 * Called monthly by InitializationManager
	 */
	set background = 1
	set waitfor = 0
	
	// Would iterate:
	// - Each player: CalculatePropertyTax on deeds
	// - Each territory: CalculateResourceTax
	// - Pending trades: CalculateTradeTax
	// - Add to treasury via AddToTreasuryTax()
	
	world.log << "TAX: Collected monthly taxes"

// ============================================================================
// MARKET REGULATION ENGINE
// ============================================================================

/proc/SetPriceControl(commodity_name, price_floor, price_ceiling)
	/**
	 * SetPriceControl(commodity_name, price_floor, price_ceiling)
	 * Government imposes price limits on commodity
	 * Prevents inflation/deflation abuse
	 */
	
	// Framework: would store controls globally
	// price_floor: minimum selling price
	// price_ceiling: maximum buying price
	
	// Any trade outside these bounds blocked
	// Government can manually set controls in crisis
	
	world.log << "REGULATION: Price control set for [commodity_name]"

/proc/RemovePriceControl(commodity_name)
	/**
	 * RemovePriceControl(commodity_name)
	 * Remove price controls, return to free market
	 */
	
	world.log << "REGULATION: Price control removed for [commodity_name]"

/proc/EnforcePriceControl(commodity_name, proposed_price)
	/**
	 * EnforcePriceControl(commodity_name, proposed_price)
	 * Check if proposed price complies with controls
	 * Returns: TRUE if allowed, FALSE if restricted
	 */
	
	// Would check global price controls
	// If proposed_price within floor-ceiling: TRUE
	// Otherwise: FALSE (trade blocked)
	
	return TRUE  // Default: no controls

/proc/ImplementImportTariff(commodity_name, tariff_percent)
	/**
	 * ImplementImportTariff(commodity_name, tariff_percent)
	 * Tax imports of commodity to protect local producers
	 * Raises price of foreign goods
	 */
	
	// Would add tariff to import trade tax calculation
	// Domestic trades unaffected
	// Foreign trades pay extra tax
	
	world.log << "REGULATION: Tariff implemented on [commodity_name] at [tariff_percent]%"

/proc/ImplementExportSubsidy(commodity_name, subsidy_percent)
	/**
	 * ImplementExportSubsidy(commodity_name, subsidy_percent)
	 * Government pays bonus on exports
	 * Increases export competitiveness
	 */
	
	// Would add subsidy to export trade value calculation
	// Sellers receive bonus when exporting
	// Encourages production & export
	
	world.log << "REGULATION: Export subsidy on [commodity_name] at [subsidy_percent]%"

/proc/CheckMonopolyViolation(player, commodity_name)
	/**
	 * CheckMonopolyViolation(player, commodity_name)
	 * Check if player's control exceeds limits
	 * Returns: TRUE if monopoly detected
	 */
	
	// Framework: check player's supply percentage
	// If > 50% of market: MONOPOLY
	// Government can force breakup or tax heavily
	
	return FALSE  // Default: no monopoly

// ============================================================================
// ECONOMIC CRIME DETECTION
// ============================================================================

/proc/DetectPriceManipulation(commodity_name, price_history_sample)
	/**
	 * DetectPriceManipulation(commodity_name, price_history_sample)
	 * Detect suspicious price patterns
	 * Returns: 0-100 suspicion score
	 */
	
	if(!price_history_sample)
		return 0
	
	// Check for red flags:
	// - Rapid price swings (>50% in one day)
	// - Coordinated trading by multiple players
	// - Dump & pump (crash price then spike)
	// - Wash trading (buy/sell to self repeatedly)
	
	var/suspicion = 0
	
	// Framework: would calculate based on patterns
	
	if(suspicion > 70)
		world.log << "CRIME: Potential price manipulation on [commodity_name] (suspicion: [suspicion])"
	
	return suspicion

/proc/DetectWashTrading(mob/player, item_name, recent_trades)
	/**
	 * DetectWashTrading(mob/player, item_name, recent_trades)
	 * Detect repeated buy/sell without net change
	 * Returns: TRUE if suspected
	 */
	
	if(!player)
		return FALSE
	
	// Check if player bought then sold same item multiple times
	// in short time without inventory holding
	
	// Framework: would analyze trade sequence
	
	return FALSE  // Default: no wash trading

/proc/PenalizeEconomicCrime(mob/player, crime_type, severity)
	/**
	 * PenalizeEconomicCrime(mob/player, crime_type, severity)
	 * Apply penalties for detected economic crimes
	 * severity: "warning", "fine", "ban"
	 */
	
	if(!player) return FALSE
	
	// Penalties:
	// - Warning: logged, player warned
	// - Fine: confiscate % of lucre
	// - Ban: block from trading for period
	// - Jail: imprisonment (if hardcore rule)
	
	world.log << "CRIME: [player] penalized for [crime_type] - [severity]"
	return TRUE

// ============================================================================
// INFLATION & DEFLATION MANAGEMENT
// ============================================================================

/proc/CalculateInflationRate(kingdom_name)
	/**
	 * CalculateInflationRate(kingdom_name)
	 * Calculate current inflation rate
	 * Returns: % per month (-1.0 to +1.0)
	 */
	
	var/datum/kingdom_treasury/treasury = GetGovernmentTreasury(kingdom_name)
	if(!treasury) return 0
	
	// Inflation factors:
	// - Money supply (more lucre in system = inflation)
	// - Production (more goods = deflation)
	// - Trade volume (high activity = inflation)
	// - Crisis events (disruption = inflation)
	
	// Framework: would calculate complex
	
	return 0  // Default: 0% inflation

/proc/ApplyInflation(kingdom_name, inflation_rate)
	/**
	 * ApplyInflation(kingdom_name, inflation_rate)
	 * Adjust all prices upward to reflect inflation
	 * Called monthly
	 */
	
	if(inflation_rate == 0) return TRUE
	
	// Would update all commodity base prices
	// Would proportionally adjust player wealth
	// Would affect contract/loan interest
	
	world.log << "ECONOMY: Inflation rate [inflation_rate * 100]% applied"
	return TRUE

/proc/IssueMoneySupply(kingdom_name, amount)
	/**
	 * IssueMoneySupply(kingdom_name, amount)
	 * Government prints/issues new currency
	 * Can trigger inflation
	 * Used during economic emergencies
	 */
	
	var/datum/kingdom_treasury/treasury = GetGovernmentTreasury(kingdom_name)
	if(!treasury) return FALSE
	
	// Would add to treasury
	// Would announce to players
	// Would note inflation impact
	
	world.log << "TREASURY: Issued [amount] new lucre"
	return TRUE

/proc/RetireMoneySupply(kingdom_name, amount)
	/**
	 * RetireMoneySupply(kingdom_name, amount)
	 * Government removes currency from circulation
	 * Can trigger deflation
	 * Used to fight inflation
	 */
	
	world.log << "TREASURY: Retired [amount] lucre from circulation"
	return TRUE

// ============================================================================
// ECONOMIC STIMULUS & RELIEF
// ============================================================================

/proc/ImplementEconomicStimulus(kingdom_name, stimulus_amount, target_sector)
	/**
	 * ImplementEconomicStimulus(kingdom_name, stimulus_amount, target_sector)
	 * Government spends money to boost economy
	 * target_sector: "agriculture", "mining", "fishing", "crafting", etc
	 */
	
	// Government spending on infrastructure
	// Direct payments to workers in sector
	// Subsidies for businesses
	// Results in temporary economic boost
	
	world.log << "STIMULUS: [stimulus_amount] lucre stimulus in [target_sector]"

/proc/ImplementCrisisRelief(kingdom_name, affected_commodities)
	/**
	 * ImplementCrisisRelief(kingdom_name, affected_commodities)
	 * Government relief during supply shock
	 * affected_commodities: list of items in shortage
	 */
	
	// Actions:
	// - Release government reserves of items
	// - Price caps on essentials
	// - Direct aid to affected populations
	// - Temporary tax breaks
	
	world.log << "RELIEF: Crisis relief enacted"

/proc/EstablishBasicIncome(kingdom_name, monthly_stipend)
	/**
	 * EstablishBasicIncome(kingdom_name, monthly_stipend)
	 * Government provides basic income to all citizens
	 * Prevents poverty trap
	 */
	
	// Would pay stipend to every player
	// Each month: player.lucre += monthly_stipend
	// Prevents economic death spiral
	// Costs treasury monthly
	
	world.log << "SOCIAL: Basic income established at [monthly_stipend] lucre/month"

// ============================================================================
// TRADE RESTRICTIONS & EMBARGOES
// ============================================================================

/proc/IssueTradeRestriction(kingdom_name, target_kingdom, commodity_name, restriction_type)
	/**
	 * IssueTradeRestriction(kingdom_name, target_kingdom, commodity_name, restriction_type)
	 * Kingdom restricts trade with another kingdom
	 * restriction_type: "import_ban", "export_ban", "tariff_increase", etc
	 */
	
	// Can be used as economic warfare
	// Or to protect domestic industries
	
	world.log << "TRADE: [kingdom_name] restricted [commodity_name] [restriction_type] with [target_kingdom]"

/proc/LiftTradeRestriction(kingdom_name, target_kingdom, commodity_name)
	/**
	 * LiftTradeRestriction(kingdom_name, target_kingdom, commodity_name)
	 * Remove trade restrictions
	 */
	
	world.log << "TRADE: [kingdom_name] lifted restrictions on [commodity_name] with [target_kingdom]"

/proc/EnforceTradeRestriction(kingdom_name, target_kingdom, commodity_name)
	/**
	 * EnforceTradeRestriction(kingdom_name, target_kingdom, commodity_name)
	 * Check if trade is blocked by restriction
	 * Returns: TRUE if blocked, FALSE if allowed
	 */
	
	// Framework: check global restrictions list
	// If restriction exists: return TRUE (blocked)
	// Otherwise: return FALSE (allowed)
	
	return FALSE

// ============================================================================
// ECONOMIC REPORTING & ANALYSIS
// ============================================================================

/proc/GenerateEconomicReport(kingdom_name)
	/**
	 * GenerateEconomicReport(kingdom_name)
	 * Comprehensive economic analysis
	 * For government & players
	 */
	
	var/report = ""
	
	report += "╔════════════════════════════════════════╗\n"
	report += "║ ECONOMIC REPORT - [kingdom_name]\n"
	report += "║ Generated: [world.time] ticks\n"
	report += "╚════════════════════════════════════════╝\n\n"
	
	report += "TREASURY STATUS:\n"
	report += "  (Would show reserves, budgets, spending)\n\n"
	
	report += "TAX COLLECTION:\n"
	report += "  (Would show revenue sources, totals)\n\n"
	
	report += "INFLATION RATE:\n"
	report += "  (Would show current rate & trend)\n\n"
	
	report += "MARKET CONDITIONS:\n"
	report += "  (Would show price indices, volatility)\n\n"
	
	report += "EMPLOYMENT:\n"
	report += "  (Would show unemployment, wages)\n\n"
	
	report += "TRADE ACTIVITY:\n"
	report += "  (Would show volumes, top commodities)\n\n"
	
	return report

/proc/GetEconomicForecast(kingdom_name, months_ahead)
	/**
	 * GetEconomicForecast(kingdom_name, months_ahead)
	 * Predict economic trends
	 * Returns: forecast data
	 */
	
	// Would analyze:
	// - Current trends
	// - Planned government spending
	// - Known upcoming crises
	// - Seasonal patterns
	// - Player behavior patterns
	
	// Predict: inflation, employment, growth rate
	
	world.log << "FORECAST: Generated [months_ahead]-month forecast"
	return list()

// ============================================================================
// INITIALIZATION
// ============================================================================

/proc/InitializeEconomicGovernance()
	/**
	 * InitializeEconomicGovernance()
	 * Sets up Phase 15 systems
	 */
	
	// Would initialize kingdom treasuries
	// Start background collection loops
	
	spawn() TaxCollectionProcessor()
	spawn() MarketRegulationEngine()
	spawn() EconomicCrimeDetector()
	spawn() InflationProcessor()
	
	world.log << "GOVERNANCE: Economic governance systems initialized"

/proc/TaxCollectionProcessor()
	/**
	 * TaxCollectionProcessor()
	 * Periodic tax collection
	 */
	set background = 1
	set waitfor = 0
	
	var/collection_interval = 2400  // Every ~1 minute
	var/last_collection = world.time
	
	while(1)
		sleep(50)
		
		if(world.time - last_collection >= collection_interval)
			last_collection = world.time
			// CollectTaxes() - framework ready

/proc/MarketRegulationEngine()
	/**
	 * MarketRegulationEngine()
	 * Monitor market for regulation violations
	 */
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(500)
		
		// Would check:
		// - Price controls being enforced
		// - Monopolies being prevented
		// - Trade restrictions active
		// Framework ready

/proc/EconomicCrimeDetector()
	/**
	 * EconomicCrimeDetector()
	 * Detect economic crimes
	 */
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(1000)
		
		// Would analyze:
		// - Recent trades for wash trading
		// - Price history for manipulation
		// - Supply patterns for hoarding
		// Framework ready

/proc/InflationProcessor()
	/**
	 * InflationProcessor()
	 * Apply inflation/deflation
	 */
	set background = 1
	set waitfor = 0
	
	var/process_interval = 24000  // Every ~10 minutes (monthly game time)
	var/last_process = world.time
	
	while(1)
		sleep(50)
		
		if(world.time - last_process >= process_interval)
			last_process = world.time
			// Would apply inflation to all systems
			// Framework ready
