// DualCurrencySystem.dm - Unified Currency Framework (Lucre + Material Trading)
// Manages story-mode lucre currency and PvP-mode material trading
// Enables kingdom-to-kingdom material exchanges for fort building, resource management

// ============================================================================
// CURRENCY TYPE DEFINITIONS
// ============================================================================

/datum/currency_type
	/**
	 * Base datum for currency definitions
	 * Allows flexible currency systems per game mode
	 */
	var
		name = "Unknown"              // Currency display name
		abbreviation = "???"          // Short code (Gold, ST, BR, etc.)
		color = "#FFFFFF"             // Display color in UI
		icon_state = null             // Visual icon in inventory
		game_mode = null              // "story", "pvp", "sandbox", "exploration"
		tradable = 0                  // 1 if can be traded between players
		stackable = 1                 // 1 if stacks in inventory
		uses = list()                 // What can you spend it on

/datum/currency_type/lucre
	name = "Lucre"
	abbreviation = "Lu"
	color = "#FFD700"                // Gold
	icon_state = "lucre_coin"
	game_mode = "story"
	tradable = 0                     // Quest currency, can't trade
	stackable = 1
	uses = list("npc_quests", "merchant_goods", "special_items")

/datum/currency_type/stone
	name = "Stone"
	abbreviation = "ST"
	color = "#8B8680"                // Gray stone
	icon_state = "stone_pile"
	game_mode = "pvp"
	tradable = 1                     // Tradable between kingdoms
	stackable = 1
	uses = list("fort_construction", "walls", "foundations")

/datum/currency_type/metal
	name = "Metal Ore"
	abbreviation = "MO"
	color = "#696969"                // Dark gray
	icon_state = "ore_pile"
	game_mode = "pvp"
	tradable = 1                     // Valuable trade commodity
	stackable = 1
	uses = list("weapons", "tools", "armor_upgrades")

/datum/currency_type/timber
	name = "Timber"
	abbreviation = "TM"
	color = "#8B4513"                // Saddle brown
	icon_state = "lumber_stack"
	game_mode = "pvp"
	tradable = 1                     // Building and crafting
	stackable = 1
	uses = list("wooden_structures", "scaffolding", "crafting")

// ============================================================================
// DUAL CURRENCY MANAGER
// ============================================================================

/datum/dual_currency_system
	/**
	 * dual_currency_system
	 * Manages multiple currency types per player
	 * Handles conversion, trading, and mode-specific balances
	 */
	var
		// Story mode currencies
		lucre_balance = 0                  // Gold coins for quests/merchants
		
		// PvP/Kingdom mode currencies (material resources)
		stone_balance = 0                  // Building material
		metal_balance = 0                  // Ore for smithing
		timber_balance = 0                 // Wood for structures
		supply_packs = 0                   // Trading bundles
		
		// Conversion rates (subject to market demand)
		lucre_to_stone_rate = 0.5          // 1 lucre = 0.5 stone (lucre more valuable)
		stone_to_lucre_rate = 2.0          // 1 stone = 2 lucre (can convert down)
		
		// Trading history
		list/transaction_log = list()      // Audit trail of all trades
		last_trade_time = 0                // Cooldown for same-player trades

/proc/InitializeCurrencyForPlayer(mob/players/player)
	/**
	 * InitializeCurrencyForPlayer(player)
	 * Sets up dual currency system for new player
	 * Based on selected game mode and progression
	 */
	if(!player) return
	
	if(!player.currency_system)
		player.currency_system = new /datum/dual_currency_system()
	
	// Initialize based on player's current world
	switch(player.current_world)
		if("story")
			player.currency_system.lucre_balance = 100  // Starting lucre
			player.currency_system.stone_balance = 0
			player.currency_system.metal_balance = 0
			player.currency_system.timber_balance = 0
		
		if("pvp")
			player.currency_system.lucre_balance = 0
			player.currency_system.stone_balance = 50   // Starting materials
			player.currency_system.metal_balance = 20
			player.currency_system.timber_balance = 30
		
		if("sandbox")
			player.currency_system.lucre_balance = 500  // Abundant for building
			player.currency_system.stone_balance = 100
			player.currency_system.metal_balance = 50
			player.currency_system.timber_balance = 75

// ============================================================================
// CURRENCY RETRIEVAL & BALANCE CHECKING
// ============================================================================

/proc/GetPlayerCurrencyBalance(mob/players/player, currency_type)
	/**
	 * GetPlayerCurrencyBalance(player, currency_type)
	 * Returns player's balance for specific currency
	 * currency_type: "lucre", "stone", "metal", "timber"
	 */
	if(!player || !player.currency_system) return 0
	
	switch(currency_type)
		if("lucre")
			return player.currency_system.lucre_balance
		if("stone")
			return player.currency_system.stone_balance
		if("metal")
			return player.currency_system.metal_balance
		if("timber")
			return player.currency_system.timber_balance
	
	return 0

/proc/GetPlayerTotalCurrencyValue(mob/players/player)
	/**
	 * GetPlayerTotalCurrencyValue(player)
	 * Returns total wealth in lucre equivalents
	 * (stone/metal/timber converted to lucre value)
	 */
	if(!player || !player.currency_system) return 0
	
	var/datum/dual_currency_system/cs = player.currency_system
	var/total = cs.lucre_balance
	
	// Add material values in lucre equivalents
	total += cs.stone_balance * cs.lucre_to_stone_rate
	total += cs.metal_balance * 3.0  // Metal worth 3x lucre
	total += cs.timber_balance * 2.5 // Timber worth 2.5x lucre
	
	return total

/proc/CanAffordCurrency(mob/players/player, currency_type, amount)
	/**
	 * CanAffordCurrency(player, currency_type, amount)
	 * Checks if player has sufficient funds
	 * Returns: 1 if can afford, 0 if not
	 */
	if(!player) return 0
	if(amount <= 0) return 1
	
	var/balance = GetPlayerCurrencyBalance(player, currency_type)
	return (balance >= amount)

// ============================================================================
// CURRENCY TRANSACTIONS
// ============================================================================

/proc/TransferCurrency(mob/players/payer, mob/players/payee, currency_type, amount, reason = "trade")
	/**
	 * TransferCurrency(payer, payee, currency_type, amount, reason)
	 * Transfers currency between players (for kingdom trades, sales, etc.)
	 * Returns: 1 if successful, 0 if failed
	 */
	if(!payer || !payee) return 0
	if(amount <= 0) return 1
	if(payer == payee) return 0
	
	// Check affordability
	if(!CanAffordCurrency(payer, currency_type, amount))
		payer << "Insufficient [currency_type] for transaction"
		return 0
	
	// Process transfer
	DeductPlayerCurrency(payer, currency_type, amount)
	AddPlayerCurrency(payee, currency_type, amount)
	
	// Log transaction
	LogCurrencyTransaction(payer, payee, currency_type, amount, reason)
	
	// Notify both parties
	payer << "Paid [amount] [currency_type] to [payee.key]"
	payee << "Received [amount] [currency_type] from [payer.key]"
	
	return 1

/proc/DeductPlayerCurrency(mob/players/player, currency_type, amount)
	/**
	 * DeductPlayerCurrency(player, currency_type, amount)
	 * Removes currency from player (spending, taxation, etc.)
	 */
	if(!player || !player.currency_system) return 0
	if(amount <= 0) return 1
	
	switch(currency_type)
		if("lucre")
			if(player.currency_system.lucre_balance < amount) return 0
			player.currency_system.lucre_balance -= amount
		if("stone")
			if(player.currency_system.stone_balance < amount) return 0
			player.currency_system.stone_balance -= amount
		if("metal")
			if(player.currency_system.metal_balance < amount) return 0
			player.currency_system.metal_balance -= amount
		if("timber")
			if(player.currency_system.timber_balance < amount) return 0
			player.currency_system.timber_balance -= amount
	
	return 1

/proc/AddPlayerCurrency(mob/players/player, currency_type, amount)
	/**
	 * AddPlayerCurrency(player, currency_type, amount)
	 * Adds currency to player (rewards, trades, harvesting, etc.)
	 */
	if(!player || !player.currency_system) return 0
	if(amount <= 0) return 1
	
	switch(currency_type)
		if("lucre")
			player.currency_system.lucre_balance += amount
		if("stone")
			player.currency_system.stone_balance += amount
		if("metal")
			player.currency_system.metal_balance += amount
		if("timber")
			player.currency_system.timber_balance += amount
	
	return 1

// ============================================================================
// CURRENCY CONVERSION (Lucre <-> Materials)
// ============================================================================

/proc/ConvertCurrency(mob/players/player, from_type, to_type, amount)
	/**
	 * ConvertCurrency(player, from_type, to_type, amount)
	 * Converts between currency types (lucre <-> materials)
	 * Conversion rates apply (lucre more valuable than materials)
	 * Returns: 1 if successful, 0 if failed
	 */
	if(!player || !player.currency_system) return 0
	if(amount <= 0) return 1
	
	var/datum/dual_currency_system/cs = player.currency_system
	var/converted_amount = 0
	
	// Lucre to material conversions
	if(from_type == "lucre")
		if(!CanAffordCurrency(player, "lucre", amount)) return 0
		
		switch(to_type)
			if("stone")
				converted_amount = amount * cs.lucre_to_stone_rate
				DeductPlayerCurrency(player, "lucre", amount)
				AddPlayerCurrency(player, "stone", converted_amount)
			if("metal")
				converted_amount = amount / 3.0  // Less efficient trade
				DeductPlayerCurrency(player, "lucre", amount)
				AddPlayerCurrency(player, "metal", converted_amount)
			if("timber")
				converted_amount = amount / 2.5
				DeductPlayerCurrency(player, "lucre", amount)
				AddPlayerCurrency(player, "timber", converted_amount)
	
	// Material to lucre conversions (less favorable)
	else if(to_type == "lucre")
		if(!CanAffordCurrency(player, from_type, amount)) return 0
		
		switch(from_type)
			if("stone")
				converted_amount = amount * cs.stone_to_lucre_rate
				DeductPlayerCurrency(player, "stone", amount)
				AddPlayerCurrency(player, "lucre", round(converted_amount))
			if("metal")
				converted_amount = amount * 2.5
				DeductPlayerCurrency(player, "metal", amount)
				AddPlayerCurrency(player, "lucre", round(converted_amount))
			if("timber")
				converted_amount = amount * 2.0
				DeductPlayerCurrency(player, "timber", amount)
				AddPlayerCurrency(player, "lucre", round(converted_amount))
	
	if(converted_amount > 0)
		player << "Converted [amount] [from_type] into [converted_amount] [to_type]"
		return 1
	
	return 0

// ============================================================================
// KINGDOM MATERIAL TRADING
// ============================================================================

/proc/InitiateKingdomMaterialTrade(mob/players/kingdom1_rep, mob/players/kingdom2_rep, list/offer_materials, list/request_materials)
	/**
	 * InitiateKingdomMaterialTrade(kingdom1_rep, kingdom2_rep, offer_materials, request_materials)
	 * Proposes kingdom-to-kingdom material exchange
	 * offer_materials: list(list(type, amount), ...)
	 * request_materials: list(list(type, amount), ...)
	 * Returns: 1 if trade succeeds, 0 if failed/rejected
	 */
	if(!kingdom1_rep || !kingdom2_rep) return 0
	
	// Validate kingdom1 has materials
	for(var/list/material_pair in offer_materials)
		var/mat_type = material_pair[1]
		var/mat_amount = material_pair[2]
		if(!CanAffordCurrency(kingdom1_rep, mat_type, mat_amount))
			kingdom1_rep << "Kingdom doesn't have [mat_amount] [mat_type]"
			return 0
	
	// Validate kingdom2 has requested materials
	for(var/list/material_pair in request_materials)
		var/mat_type = material_pair[1]
		var/mat_amount = material_pair[2]
		if(!CanAffordCurrency(kingdom2_rep, mat_type, mat_amount))
			kingdom2_rep << "Counterparty doesn't have [mat_amount] [mat_type]"
			return 0
	
	// Execute transfers
	for(var/list/material_pair in offer_materials)
		TransferCurrency(kingdom1_rep, kingdom2_rep, material_pair[1], material_pair[2], "kingdom_trade")
	
	for(var/list/material_pair in request_materials)
		TransferCurrency(kingdom2_rep, kingdom1_rep, material_pair[1], material_pair[2], "kingdom_trade")
	
	// Notify both parties
	kingdom1_rep << "Kingdom material trade completed!"
	kingdom2_rep << "Kingdom material trade completed!"
	
	return 1

// ============================================================================
// CURRENCY PERSISTENCE
// ============================================================================

/proc/SavePlayerCurrencyData(mob/players/player, savefile/F)
	/**
	 * SavePlayerCurrencyData(player, savefile)
	 * Saves all currency balances to character file
	 */
	if(!player || !F) return
	
	if(player.currency_system)
		F["lucre_balance"] = player.currency_system.lucre_balance
		F["stone_balance"] = player.currency_system.stone_balance
		F["metal_balance"] = player.currency_system.metal_balance
		F["timber_balance"] = player.currency_system.timber_balance

/proc/LoadPlayerCurrencyData(mob/players/player, savefile/F)
	/**
	 * LoadPlayerCurrencyData(player, savefile)
	 * Loads currency balances from character file
	 */
	if(!player || !F) return
	
	if(!player.currency_system)
		player.currency_system = new /datum/dual_currency_system()
	
	player.currency_system.lucre_balance = F["lucre_balance"] || 0
	player.currency_system.stone_balance = F["stone_balance"] || 0
	player.currency_system.metal_balance = F["metal_balance"] || 0
	player.currency_system.timber_balance = F["timber_balance"] || 0

// ============================================================================
// NOTE: LogCurrencyTransaction already defined in CurrencyDisplayUI.dm
// ============================================================================

/proc/GetPlayerCurrencySummary(mob/players/player)
	/**
	 * GetPlayerCurrencySummary(player)
	 * Returns formatted currency summary for display
	 * Format: "Lucre: 100 | Stone: 50 | Metal: 20 | Timber: 30"
	 */
	if(!player) return "No currencies"
	
	var/lucre = GetPlayerCurrencyBalance(player, "lucre")
	var/stone = GetPlayerCurrencyBalance(player, "stone")
	var/metal = GetPlayerCurrencyBalance(player, "metal")
	var/timber = GetPlayerCurrencyBalance(player, "timber")
	
	return "Lucre: [lucre] | Stone: [stone] | Metal: [metal] | Timber: [timber]"

// ============================================================================
// WORLD MODE INTEGRATION
// ============================================================================

/proc/UpdateCurrencyForWorldTransition(mob/players/player, from_world, to_world)
	/**
	 * UpdateCurrencyForWorldTransition(player, from_world, to_world)
	 * Adjusts currency balances when player moves between worlds
	 * Different worlds emphasize different currencies
	 */
	if(!player || !player.currency_system) return
	
	// Story world: focus on lucre
	if(to_world == "story")
		player << "Entering story mode - material resources reduced"
		player.currency_system.stone_balance = round(player.currency_system.stone_balance * 0.1)
		player.currency_system.metal_balance = round(player.currency_system.metal_balance * 0.1)
		player.currency_system.timber_balance = round(player.currency_system.timber_balance * 0.1)
	
	// PvP world: focus on materials
	if(to_world == "pvp")
		player << "Entering kingdom conquest mode - lucre less relevant"
		// Keep lucre but emphasize material gathering
	
	// Sandbox: abundant resources
	if(to_world == "sandbox")
		if(player.currency_system.lucre_balance < 500)
			player.currency_system.lucre_balance = 500

// ============================================================================
// INITIALIZATION
// ============================================================================

/proc/InitializeDualCurrencySystem()
	world.log << "Dual Currency System initialized"
	world.log << "Currencies: Lucre (Story), Stone/Metal/Timber (PvP/Kingdom)"
	world.log << "Tradable materials enable kingdom-to-kingdom commerce"

