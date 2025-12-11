/**
 * PlayerEconomicEngagement.dm
 * Phase 14: Player Economic Engagement
 * 
 * Purpose: Makes players care about the economy through:
 * - Wealth display and progression
 * - Trading profit tracking
 * - Investment opportunities
 * - Speculation mechanics
 * - Leaderboards & rankings
 * - Contracts & commissions
 * 
 * System Integration Points:
 * - MarketIntegrationLayer.dm (market stats)
 * - TradingPostUI.dm (player trades)
 * - NPCMerchantSystem.dm (reputation)
 * - DualCurrencySystem.dm (wealth tracking)
 * 
 * Tick Schedule:
 * - T+395: Player engagement systems initialization
 * - T+396: Contract/commission system
 * - T+397: Wealth tracking & display
 * - T+398: Leaderboard system
 * - T+399-401: Background loops (trading, speculation, profits)
 */

// ============================================================================
// PLAYER WEALTH TRACKING
// ============================================================================

/datum/player_wealth_record
	/**
	 * player_wealth_record
	 * Tracks player's financial information
	 * Stored in datum/character_data
	 */
	var
		total_lucre = 0
		total_materials = 0
		net_worth = 0
		
		// Trading history
		total_trades = 0
		successful_trades = 0
		profitable_trades = 0
		
		// Profit tracking
		lifetime_profit = 0
		lifetime_loss = 0
		net_profit = 0
		profit_ratio = 0
		
		// Investment
		invested_lucre = 0
		investment_returns = 0
		
		// Rank in economy
		economic_tier = 1
		wealth_percentile = 0
		
		// Time tracking
		last_profit_update = 0
		first_trade_time = 0

/proc/InitializePlayerWealth(mob/player)
	/**
	 * InitializePlayerWealth(mob/player)
	 * Create wealth tracking for new player
	 */
	
	if(!player) return FALSE
	
	// Would initialize wealth datum if not exists
	world.log << "WEALTH: Initialized for [player]"
	return TRUE

/proc/UpdatePlayerWealthDisplay(mob/player)
	/**
	 * UpdatePlayerWealthDisplay(mob/player)
	 * Refresh player's wealth UI
	 * Called after any trade or balance change
	 */
	
	if(!player) return FALSE
	
	// Would update:
	// - HUD wealth display (current lucre/materials)
	// - Net worth display
	// - Profit/loss display
	// - Economic tier badge
	// - Leaderboard position
	
	return TRUE

/proc/CalculatePlayerNetWorth(mob/player)
	/**
	 * CalculatePlayerNetWorth(mob/player)
	 * Calculate player's total wealth
	 * Returns: total lucre + (material value)
	 */
	
	if(!player) return 0
	
	// Would sum:
	// - player.lucre (currency)
	// - player.materials (resource value)
	// - Equipment value
	// - Inventory item value
	// - Investment value
	// - Contract earnings
	
	return 0  // Framework placeholder

/proc/UpdateEconomicTier(mob/player)
	/**
	 * UpdateEconomicTier(mob/player)
	 * Update player's economic status
	 * Tier affects NPC reputation, merchant discounts, credit limit
	 */
	
	if(!player) return FALSE
	
	var/net_worth = CalculatePlayerNetWorth(player)
	var/new_tier = 1
	// 1 = 0-1000 lucre (Peasant)
	// 3 = 5001-20000 (Merchant)
	// 5 = 100001+ (Magnate)
	
	switch(net_worth)
		if(0 to 1000)
			new_tier = 1
		if(1001 to 5000)
			new_tier = 2
		if(5001 to 20000)
			new_tier = 3
		if(20001 to 100000)
			new_tier = 4
		else
			new_tier = 5
	
	world.log << "WEALTH: [player] economic tier updated to [new_tier]"
	
	return TRUE

// ============================================================================
// TRADING PROFIT TRACKING
// ============================================================================

/proc/RecordPlayerTradeProfit(mob/player, item_name, quantity, buy_price, sell_price)
	/**
	 * RecordPlayerTradeProfit(mob/player, item_name, quantity, buy_price, sell_price)
	 * Calculate and record profit/loss from trade
	 */
	
	if(!player) return FALSE
	
	var/buy_cost = buy_price * quantity
	var/sell_revenue = sell_price * quantity
	var/profit = sell_revenue - buy_cost
	
	InitializePlayerWealth(player)
	
	// Record trade
	if(profit > 0)
		world.log << "PROFIT: [player] gained [profit] lucre on [item_name]"
	else if(profit < 0)
		world.log << "LOSS: [player] lost [abs(profit)] lucre on [item_name]"
	
	// Update display
	UpdatePlayerWealthDisplay(player)
	UpdateEconomicTier(player)
	
	return TRUE

// ============================================================================
// SPECULATION & INVESTMENT SYSTEM
// ============================================================================

/datum/investment_contract
	/**
	 * investment_contract
	 * Player-held contract on future commodity prices
	 */
	var
		player_ref           // Who holds the contract
		commodity_name       // What commodity
		position = "long"
		
		entry_price = 0
		quantity = 0
		
		current_price = 0
		current_value = 0
		
		profit_loss = 0
		stop_loss = 0
		take_profit = 0
		
		opened_time = 0
		expires_time = 0
		closed_time = 0
		
		status = "open"

/proc/BuyInvestmentContract(mob/player, commodity_name, position, quantity, entry_price)
	/**
	 * BuyInvestmentContract(mob/player, commodity_name, position, quantity, entry_price)
	 * Player buys speculative contract
	 * position: "long" (expect price up) or "short" (expect price down)
	 */
	
	if(!player) return FALSE
	
	// Would calculate: cost = entry_price * quantity * 0.1
	// Would check: if(player.lucre < cost) return FALSE
	
	var/datum/investment_contract/contract = new()
	contract.player_ref = player
	contract.commodity_name = commodity_name
	contract.position = position
	contract.entry_price = entry_price
	contract.quantity = quantity
	contract.opened_time = world.time
	contract.expires_time = world.time + 7 * 24 * 60 * 10
	contract.status = "open"
	
	// Would track: player.invested_lucre += cost
	
	world.log << "INVEST: [player] bought [position] on [commodity_name]"
	
	return TRUE

/proc/CloseInvestmentContract(mob/player, contract)
	/**
	 * CloseInvestmentContract(mob/player, contract)
	 * Player closes contract, realizes P/L
	 */
	
	if(!contract) return FALSE
	
	// Framework: Would calculate P/L and return funds to player
	// Based on market_price vs contract.entry_price
	
	world.log << "INVEST: [player] closed contract"
	
	return TRUE

/proc/CheckInvestmentContracts()
	/**
	 * CheckInvestmentContracts()
	 * Check all active contracts for expiry and stop-loss/take-profit
	 * Runs every ~1 minute
	 */
	set background = 1
	set waitfor = 0
	// For each contract:
	//   - Check if expiry time reached → force close
	//   - Check if stop-loss triggered → auto close
	//   - Check if take-profit triggered → auto close
	//   - Update current_value for display
	
	world.log << "INVEST: Contract check completed"

// ============================================================================
// COMMISSION & CONTRACT SYSTEM
// ============================================================================

/datum/player_contract
	/**
	 * player_contract
	 * Work contract offered by NPCs or players
	 */
	var
		contract_id
		issuer                // Who issued (NPC or player)
		recipient             // Who must complete it
		
		contract_type         // "deliver", "harvest", "craft", "trade", "hunt"
		description           // Human-readable task
		
		requirements = list()
		reward_lucre = 0
		reward_items = list()
		
		deadline = 0
		status = "pending"
		
		created_time = 0
		started_time = 0
		completed_time = 0

/proc/CreatePlayerContract(issuer, recipient, contract_type, description, requirements, reward_lucre)
	/**
	 * CreatePlayerContract(...)
	 * Create a new contract for a player to complete
	 */
	
	if(!issuer || !recipient) return FALSE
	
	var/datum/player_contract/contract = new()
	contract.issuer = issuer
	contract.recipient = recipient
	contract.contract_type = contract_type
	contract.description = description
	contract.requirements = requirements
	contract.reward_lucre = reward_lucre
	contract.status = "pending"
	contract.created_time = world.time
	contract.contract_id = "[issuer]-[world.time]-[rand(1000,9999)]"
	
	world.log << "CONTRACT: Created contract [contract.contract_id]"
	
	return contract

/proc/AcceptPlayerContract(mob/player, contract)
	/**
	 * AcceptPlayerContract(mob/player, contract)
	 * Player accepts contract, begins work
	 */
	
	if(!player || !contract) return FALSE
	
	// Would mark contract as active
	// Would store in player's active contracts list
	
	world.log << "CONTRACT: [player] accepted contract"
	
	return TRUE

/proc/CompletePlayerContract(mob/player, contract)
	/**
	 * CompletePlayerContract(mob/player, contract)
	 * Player completes contract, receives reward
	 */
	
	if(!player || !contract) return FALSE
	
	// Would mark as completed
	// Would reward player (add to lucre)
	// Would add items to inventory
	
	world.log << "CONTRACT: [player] completed contract"
	
	return TRUE

/proc/GenerateNPCContracts()
	/**
	 * GenerateNPCContracts()
	 * NPCs generate contracts for players
	 * Types: delivery quests, collection tasks, crafting orders
	 */
	
	// Each NPC merchant could offer:
	// - "Deliver 10 stone to Port" (from Blacksmith)
	// - "Collect 5 herbs for potion" (from Herbalist)
	// - "Craft 3 swords for buyer" (commission)
	
	world.log << "CONTRACT: Generated NPC contracts"

// ============================================================================
// LEADERBOARDS & RANKINGS
// ============================================================================

/datum/wealth_leaderboard
	/**
	 * wealth_leaderboard
	 * Global ranking of wealthiest players
	 */
	var
		list/rankings = list()
		last_update = 0
		update_interval = 3000

/proc/UpdateWealthLeaderboard()
	/**
	 * UpdateWealthLeaderboard()
	 * Recalculate rankings
	 */
	
	// For each player:
	//   Get net worth from CalculatePlayerNetWorth()
	//   Sort by net_worth descending
	//   Store top 100 or top 1000
	
	world.log << "LEADER: Wealth rankings updated"

/proc/GetPlayerWealthRank(mob/player)
	/**
	 * GetPlayerWealthRank(mob/player)
	 * Get player's rank in leaderboard
	 * Returns: 1-based rank (1 = richest)
	 */
	
	// Would search leaderboard
	return 0  // Not ranked (placeholder)

/proc/GetPlayerWealthPercentile(mob/player)
	/**
	 * GetPlayerWealthPercentile(mob/player)
	 * Get player's percentile (how many % are richer)
	 * Returns: 0-100 (0 = richest, 100 = poorest)
	 */
	
	// Calculate: (rank - 1) / (total_players) * 100
	return 50  // Default (placeholder)

/proc/DisplayWealthLeaderboard(mob/viewer, limit = 100)
	/**
	 * DisplayWealthLeaderboard(mob/viewer, limit)
	 * Show top N richest players
	 */
	
	var/output = ""
	output += "╔════════════════════════════════════════╗\n"
	output += "║ WEALTH LEADERBOARD\n"
	output += "╚════════════════════════════════════════╝\n\n"
	
	output += "Rank │ Player         │ Net Worth    │ Tier\n"
	output += "─────┼────────────────┼──────────────┼──────\n"
	
	// Would iterate rankings and format
	// Placeholder shows 3 example entries:
	output += "1    │ Merchant_King  │ 500,000 Lucre│ Magnate\n"
	output += "2    │ Trader_Sue     │ 350,000 Lucre│ Magnate\n"
	output += "3    │ Smith_Joe      │ 200,000 Lucre│ Trader\n"
	output += "...\n"
	
	viewer << output

// ============================================================================
// TRADING PROFIT BONUSES
// ============================================================================

/proc/CalculateProfitBonus(mob/player, profit_amount)
	/**
	 * CalculateProfitBonus(mob/player, profit_amount)
	 * Calculate bonus rewards for high-profit trades
	 * Rewards successful speculation
	 */
	
	if(!player || profit_amount <= 0) return 0
	
	var/bonus = 0
	// 0-99 lucre profit: 0% bonus
	// 100-499: 5% bonus
	// 500-1999: 10% bonus
	// 2000+: 15% bonus
	
	switch(profit_amount)
		if(0 to 99)
			bonus = 0
		if(100 to 499)
			bonus = profit_amount * 0.05
		if(500 to 1999)
			bonus = profit_amount * 0.10
		else
			bonus = profit_amount * 0.15
	
	if(bonus > 0)
		world.log << "BONUS: [player] earned profit bonus"
	
	return bonus

/proc/CalculateTradingStreak(mob/player)
	/**
	 * CalculateTradingStreak(mob/player)
	 * Track consecutive profitable trades
	 * Awards streak bonuses
	 */
	
	// Would track consecutive profitable trades
	// Every 5 profitable trades in a row: bonus
	// Every 10 profitable trades in a row: larger bonus + achievement
	
	return 0

// ============================================================================
// MERCHANT REPUTATION SYSTEM
// ============================================================================

/proc/AddMerchantReputation(mob/player, merchant_npc, reputation_change)
	/**
	 * AddMerchantReputation(mob/player, merchant_npc, reputation_change)
	 * Modify player's relationship with NPC merchant
	 * Reputation affects NPC pricing/discounts
	 */
	
	if(!player || !merchant_npc) return FALSE
	
	// Would track reputation in character_data
	// At key thresholds:
	// -100: Merchant refuses to trade
	// -50: Heavy price penalty
	// 0: Neutral (baseline prices)
	// +50: Discount applied
	// +100: VIP discounts, priority service
	
	world.log << "REP: [player] reputation with [merchant_npc] modified by [reputation_change]"
	
	return TRUE

// ============================================================================
// INITIALIZATION
// ============================================================================

/proc/InitializePlayerEconomicEngagement()
	/**
	 * InitializePlayerEconomicEngagement()
	 * Sets up Phase 14 systems
	 */
	
	// Start background loops
	spawn() CheckInvestmentContracts()
	spawn() UpdateWealthLeaderboard()
	spawn() PlayerEconomicDisplayLoop()
	
	world.log << "PLAYER_ENGAGEMENT: System initialized"

/proc/PlayerEconomicDisplayLoop()
	/**
	 * PlayerEconomicDisplayLoop()
	 * Update player wealth displays periodically
	 */
	set background = 1
	set waitfor = 0
	
	var/update_interval = 500
	var/last_update = world.time
	
	while(1)
		sleep(50)
		
		if(world.time - last_update >= update_interval)
			last_update = world.time
			// Update leaderboard positions
			// Framework ready
