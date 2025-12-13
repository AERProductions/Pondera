// dm/KingdomTreasurySystem.dm — Kingdom material reserves and spending management
// Tracks per-kingdom material pools, maintenance costs, trade transfers, and treasury access
// Integrates with DeedSystem for territory maintenance, DualCurrencySystem for tracking

#define TREASURY_UPDATE_INTERVAL 500  // Ticks between treasury updates (25 seconds)
#define MAINTENANCE_TICK_INTERVAL 50000  // Ticks between monthly maintenance (2500 seconds = ~42 min)

// Global treasury system
var/datum/KingdomTreasurySystem/kingdom_treasury = null

// Initialize on world startup
proc/InitializeKingdomTreasury()
	kingdom_treasury = new /datum/KingdomTreasurySystem()
	RegisterInitComplete("Kingdom Treasury")

// Get treasury system singleton
proc/GetKingdomTreasurySystem()
	if(!kingdom_treasury)
		world.log << "ERROR: Kingdom Treasury system not initialized!"
		return null
	return kingdom_treasury

// Kingdom treasury engine managing material reserves
datum/KingdomTreasurySystem
	var/initialized = FALSE
	var/list/kingdom_balances = list()     // Material balances per kingdom
	var/list/treasury_logs = list()        // Transaction history
	var/list/maintenance_records = list()  // Deed maintenance history
	var/list/treasury_leaders = list()     // Who can access treasury (by kingdom)
	var/last_maintenance = 0
	var/transaction_counter = 0

	New()
		initialized = TRUE
		InitializeKingdomBalances()
		InitializeTreasuryLeaders()
		spawn(MAINTENANCE_TICK_INTERVAL)
			ProcessMonthlyMaintenance()

	// Initialize kingdom material balances
	proc/InitializeKingdomBalances()
		kingdom_balances["story"] = list(
			"stone" = 5000,
			"metal" = 2000,
			"timber" = 3000,
			"total_value" = 0
		)
		kingdom_balances["sandbox"] = list(
			"stone" = 10000,
			"metal" = 10000,
			"timber" = 10000,
			"total_value" = 0
		)
		kingdom_balances["pvp"] = list(
			"stone" = 500,
			"metal" = 300,
			"timber" = 400,
			"total_value" = 0
		)
		
		// Initialize transaction logs
		treasury_logs["story"] = list()
		treasury_logs["sandbox"] = list()
		treasury_logs["pvp"] = list()
		
		// Initialize maintenance records
		maintenance_records["story"] = list()
		maintenance_records["sandbox"] = list()
		maintenance_records["pvp"] = list()

	// Initialize treasury leaders (kingdom owners)
	proc/InitializeTreasuryLeaders()
		treasury_leaders["story"] = list()
		treasury_leaders["sandbox"] = list()
		treasury_leaders["pvp"] = list()

	// Deposit materials into kingdom treasury
	proc/DepositToTreasury(var/kingdom, var/material, var/amount, var/source = "unknown")
		if(!kingdom_balances[kingdom])
			return FALSE
		
		if(!kingdom_balances[kingdom][material])
			kingdom_balances[kingdom][material] = 0
		
		kingdom_balances[kingdom][material] += amount
		if(kingdom_balances[kingdom][material] < 0)
			kingdom_balances[kingdom][material] = 0
		
		LogTransaction(kingdom, "deposit", material, amount, source)
		return TRUE

	// Withdraw materials from kingdom treasury
	proc/WithdrawFromTreasury(var/kingdom, var/material, var/amount, var/reason = "unknown")
		if(!kingdom_balances[kingdom])
			return FALSE
		
		if(!kingdom_balances[kingdom][material])
			kingdom_balances[kingdom][material] = 0
		
		// Check sufficient balance
		if(kingdom_balances[kingdom][material] < amount)
			return FALSE
		
		kingdom_balances[kingdom][material] -= amount
		LogTransaction(kingdom, "withdraw", material, amount, reason)
		return TRUE

	// Get current balance of material in kingdom
	proc/GetBalance(var/kingdom, var/material)
		if(!kingdom_balances[kingdom])
			return 0
		
		return kingdom_balances[kingdom][material] || 0

	// Get all balances for kingdom
	proc/GetAllBalances(var/kingdom)
		if(!kingdom_balances[kingdom])
			return list()
		
		return kingdom_balances[kingdom]

	// Transfer materials between kingdoms (trade)
	proc/TransferBetweenKingdoms(var/from_kingdom, var/to_kingdom, var/material, var/amount)
		if(!from_kingdom || !to_kingdom)
			return FALSE
		
		if(!kingdom_balances[from_kingdom] || !kingdom_balances[to_kingdom])
			return FALSE
		
		// Check sending kingdom has enough
		if(GetBalance(from_kingdom, material) < amount)
			return FALSE
		
		// Execute transfer
		WithdrawFromTreasury(from_kingdom, material, amount, "trade to [to_kingdom]")
		DepositToTreasury(to_kingdom, material, amount, "trade from [from_kingdom]")
		
		return TRUE

	// Deduct deed maintenance costs from kingdom treasury
	proc/DeductMaintenanceCost(var/kingdom, var/deed_name, var/cost_stone, var/cost_metal, var/cost_timber)
		if(!kingdom_balances[kingdom])
			return FALSE
		
		// Check kingdom has sufficient materials
		if(GetBalance(kingdom, "stone") < cost_stone)
			return FALSE
		if(GetBalance(kingdom, "metal") < cost_metal)
			return FALSE
		if(GetBalance(kingdom, "timber") < cost_timber)
			return FALSE
		
		// Deduct all materials
		WithdrawFromTreasury(kingdom, "stone", cost_stone, "maintenance: [deed_name]")
		WithdrawFromTreasury(kingdom, "metal", cost_metal, "maintenance: [deed_name]")
		WithdrawFromTreasury(kingdom, "timber", cost_timber, "maintenance: [deed_name]")
		
		// Log maintenance record
		LogMaintenanceRecord(kingdom, deed_name, cost_stone, cost_metal, cost_timber)
		
		return TRUE

	// Log transaction to history
	proc/LogTransaction(var/kingdom, var/type, var/material, var/amount, var/note)
		if(!treasury_logs[kingdom])
			treasury_logs[kingdom] = list()
		
		var/transaction = list(
			"id" = transaction_counter++,
			"type" = type,
			"material" = material,
			"amount" = amount,
			"timestamp" = world.time,
			"note" = note
		)
		
		treasury_logs[kingdom] += transaction

	// Log maintenance payment
	proc/LogMaintenanceRecord(var/kingdom, var/deed_name, var/stone, var/metal, var/timber)
		if(!maintenance_records[kingdom])
			maintenance_records[kingdom] = list()
		
		var/record = list(
			"deed" = deed_name,
			"stone_paid" = stone,
			"metal_paid" = metal,
			"timber_paid" = timber,
			"timestamp" = world.time
		)
		
		maintenance_records[kingdom] += record

	// Get transaction history
	proc/GetTransactionHistory(var/kingdom, var/limit = 50)
		if(!treasury_logs[kingdom])
			return list()
		
		var/list/history = treasury_logs[kingdom]
		var/start = max(1, history.len - limit + 1)
		var/list/result = list()
		for(var/i = start to history.len)
			result += history[i]
		return result

	// Get maintenance history
	proc/GetMaintenanceHistory(var/kingdom, var/limit = 12)
		if(!maintenance_records[kingdom])
			return list()
		
		var/list/history = maintenance_records[kingdom]
		var/start = max(1, history.len - limit + 1)
		var/list/result = list()
		for(var/i = start to history.len)
			result += history[i]
		return result

	// Generate treasury report
	proc/GetTreasuryReport(var/kingdom)
		if(!kingdom_balances[kingdom])
			return "Kingdom not found!"
		
		var/list/balances = kingdom_balances[kingdom]
		var/report = "=== KINGDOM TREASURY REPORT: [kingdom] ===\n"
		report += "Stone: [balances["stone"]]\n"
		report += "Metal: [balances["metal"]]\n"
		report += "Timber: [balances["timber"]]\n"
		report += "\nRecent Transactions:\n"
		
		var/list/recent = GetTransactionHistory(kingdom, 5)
		for(var/transaction in recent)
			report += "  [transaction["type"]]: [transaction["amount"]] [transaction["material"]] ([transaction["note"]])\n"
		
		return report

	// Process monthly maintenance for all deeds
	proc/ProcessMonthlyMaintenance()
		set background = 1
		set waitfor = 0

		while(src)
			sleep(MAINTENANCE_TICK_INTERVAL)
			
			// Check each kingdom's deeds
			for(var/kingdom in kingdom_balances)
				ProcessKingdomDeeds(kingdom)

	// Process all deeds in a kingdom
	proc/ProcessKingdomDeeds(var/kingdom)
		// This would integrate with DeedSystem.dm
		// For now, placeholder for future integration
		// TODO: Iterate through deeds owned by kingdom
		// Calculate maintenance costs
		// Deduct from treasury
		// Log if insufficient funds

	// Add leader access to treasury
	proc/AddTreasuryLeader(var/kingdom, var/mob/players/leader)
		if(!treasury_leaders[kingdom])
			treasury_leaders[kingdom] = list()
		
		if(!(leader in treasury_leaders[kingdom]))
			treasury_leaders[kingdom] += leader
			return TRUE
		
		return FALSE

	// Remove leader access from treasury
	proc/RemoveTreasuryLeader(var/kingdom, var/mob/players/leader)
		if(!treasury_leaders[kingdom])
			return FALSE
		
		if(leader in treasury_leaders[kingdom])
			treasury_leaders[kingdom] -= leader
			return TRUE
		
		return FALSE

	// Check if player can access treasury
	proc/CanAccessTreasury(var/mob/players/leader, var/kingdom)
		if(!treasury_leaders[kingdom])
			return FALSE
		
		return (leader in treasury_leaders[kingdom])

	// Get total material value for kingdom (for net worth display)
	proc/GetTreasuryValue(var/kingdom)
		if(!kingdom_balances[kingdom])
			return 0
		
		var/list/balances = kingdom_balances[kingdom]
		var/total = 0
		
		// Get current prices from economy system
		var/datum/AdvancedEconomySystem/econ = GetAdvancedEconomy()
		if(econ)
			total += econ.GetTechTierPrice("stone", 1, 1, kingdom) * balances["stone"]
			total += econ.GetTechTierPrice("metal", 1, 1, kingdom) * balances["metal"]
			total += econ.GetTechTierPrice("timber", 1, 1, kingdom) * balances["timber"]
		else
			// Fallback: simple sum
			total = balances["stone"] + balances["metal"] + balances["timber"]
		
		return total

// Player access to treasury (verb or UI)
mob/players
	verb/ViewTreasuryStatus()
		set category = "Kingdom"
		
		var/kingdom = "story"  // TODO: Determine player's kingdom
		var/datum/KingdomTreasurySystem/treasury = GetKingdomTreasurySystem()
		if(!treasury)
			src << "Treasury system unavailable!"
			return
		
		var/report = treasury.GetTreasuryReport(kingdom)
		src << report

	verb/ViewTreasuryHistory()
		set category = "Kingdom"
		
		var/kingdom = "story"  // TODO: Determine player's kingdom
		var/datum/KingdomTreasurySystem/treasury = GetKingdomTreasurySystem()
		if(!treasury)
			src << "Treasury system unavailable!"
			return
		
		var/list/history = treasury.GetTransactionHistory(kingdom, 20)
		src << "Recent Transactions:"
		for(var/transaction in history)
			src << "  [transaction["type"]]: [transaction["amount"]] [transaction["material"]]"
