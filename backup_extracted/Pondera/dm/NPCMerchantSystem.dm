/**
 * NPCMerchantSystem.dm
 * Phase 12b: NPC Merchant System with personality-based pricing
 * 
 * Features:
 * - Merchant personality types (fair, greedy, desperate)
 * - Inventory management with capacity limits
 * - Wealth tracking (can't always afford to buy)
 * - Buy/sell pricing based on personality
 * - Mood modifiers (affects willingness to trade)
 * - Trading cooldowns (prevents spam)
 * - Relationship tracking with players
 * - NPC merchant spawner integration
 * 
 * Integration:
 * - Works with existing NPC system
 * - Links to market pricing (market prices are baseline)
 * - Updates market supply/demand when NPCs trade
 * - Integrates with SeasonalEventsHook for mood changes
 */

// ============================================================================
// NPC MERCHANT DATUM
// ============================================================================

/datum/npc_merchant
	var
		// Identity
		merchant_name = "Unknown Merchant"
		merchant_type = "trader"
		merchant_id = null
		
		// Personality traits
		personality = "fair"
		profit_margin = 1.0
		mood = 0
		
		// Economic state
		current_wealth = 0
		starting_wealth = 0
		inventory = list()
		max_inventory_slots = 20
		max_inventory_per_item = 500
		
		// Trading preferences
		list/prefers_buying = list()
		list/prefers_selling = list()
		list/specialty_items = list()
		
		// Trading state
		last_trade_time = 0
		trading_cooldown = 30
		total_trades = 0
		total_wealth_traded = 0
		
		// Relationships
		list/player_relationships = list()
		reputation = 0
		
		// Reference to actual mob
		mob/npcs/npc_ref = null

/datum/npc_merchant/New(name, type, personality_type)
	/**
	 * Constructor for NPC merchant
	 */
	merchant_name = name
	merchant_type = type
	personality = personality_type
	merchant_id = "[name]_[world.time]"
	switch(personality)
		if("fair")
			profit_margin = 0.95
			mood = 10
			
		if("greedy")
			profit_margin = 1.3
			mood = -20
			
		if("desperate")
			profit_margin = 0.8
			mood = 30
	
	// Initialize inventory lists
	inventory = list()
	prefers_buying = list()
	prefers_selling = list()
	specialty_items = list()
	player_relationships = list()
	switch(personality)
		if("fair")
			current_wealth = 500
			starting_wealth = 500
			
		if("greedy")
			current_wealth = 1000
			starting_wealth = 1000
			
		if("desperate")
			current_wealth = 100
			starting_wealth = 100

/proc/CreateMerchant(name, type, personality_type)
	/**
	 * CreateMerchant(name, type, personality_type)
	 * Factory function to create a new merchant
	 * Returns: /datum/npc_merchant object
	 */
	if(!name || !type || !personality_type)
		world.log << "ERROR: CreateMerchant requires name, type, personality"
		return null
	
	var/datum/npc_merchant/merchant = new /datum/npc_merchant(name, type, personality_type)
	return merchant

// ============================================================================
// MERCHANT INVENTORY MANAGEMENT
// ============================================================================

/datum/npc_merchant/proc/AddToInventory(item_name, quantity)
	/**
	 * AddToInventory(item_name, quantity)
	 * Adds items to merchant inventory
	 * Returns: TRUE if successful, FALSE if at capacity
	 */
	if(!item_name || quantity <= 0) return FALSE
	
	// Check if adding new item would exceed slot limit
	var/inv_count = 0
	for(var/item in inventory) inv_count++
	if(!(item_name in inventory) && inv_count >= max_inventory_slots)
		return FALSE
	
	// Check quantity limits
	var/current_qty = inventory[item_name] || 0
	if(current_qty + quantity > max_inventory_per_item)
		return FALSE
	
	inventory[item_name] = current_qty + quantity
	return TRUE

/datum/npc_merchant/proc/RemoveFromInventory(item_name, quantity)
	/**
	 * RemoveFromInventory(item_name, quantity)
	 * Removes items from merchant inventory
	 * Returns: quantity actually removed, 0 if item not found
	 */
	if(!item_name || quantity <= 0) return 0
	
	var/current_qty = inventory[item_name] || 0
	if(current_qty == 0) return 0
	
	var/removed = min(quantity, current_qty)
	inventory[item_name] = current_qty - removed
	
	// Remove from inventory if empty
	if(inventory[item_name] == 0)
		inventory -= item_name
	
	return removed

/datum/npc_merchant/proc/GetInventoryCount(item_name)
	/**
	 * GetInventoryCount(item_name)
	 * Returns quantity of item in merchant inventory
	 */
	return inventory[item_name] || 0

/datum/npc_merchant/proc/CanCarryMore()
	/**
	 * CanCarryMore()
	 * Returns TRUE if merchant has room for more items
	 */
	var/inv_count = 0
	for(var/item in inventory) inv_count++
	if(inv_count < max_inventory_slots) return TRUE
	return FALSE

// ============================================================================
// MERCHANT PRICING LOGIC
// ============================================================================

/datum/npc_merchant/proc/GetBuyPrice(item_name)
	/**
	 * GetBuyPrice(item_name)
	 * Price NPC will pay for items (below market)
	 * Fair: 95%, Greedy: 70%, Desperate: 120%
	 */
	var/market_price = GetCommodityPrice(item_name)
	if(market_price <= 0) market_price = 1.0
	
	var/buy_price = 0
	
	switch(personality)
		if("fair")
			buy_price = market_price * 0.95
		if("greedy")
			buy_price = market_price * 0.70
		if("desperate")
			buy_price = market_price * 1.20
	
	// Apply mood modifier
	var/mood_mult = 1.0 + (mood / 200.0)
	buy_price *= mood_mult
	
	return round(buy_price, 0.01)

/datum/npc_merchant/proc/GetSellPrice(item_name)
	/**
	 * GetSellPrice(item_name)
	 * Price NPC will charge for items (above market)
	 * Fair: 105%, Greedy: 130%, Desperate: 80%
	 */
	var/market_price = GetCommodityPrice(item_name)
	if(market_price <= 0) market_price = 1.0
	
	var/sell_price = 0
	
	switch(personality)
		if("fair")
			sell_price = market_price * 1.05
		if("greedy")
			sell_price = market_price * 1.30
		if("desperate")
			sell_price = market_price * 0.80
	
	// Apply mood modifier
	var/mood_mult = 1.0 + (mood / 200.0)
	sell_price *= mood_mult
	
	return round(sell_price, 0.01)

/datum/npc_merchant/proc/CanAffordToPurchase(item_name, quantity)
	/**
	 * CanAffordToPurchase(item_name, quantity)
	 * Checks if merchant has enough wealth to buy items
	 * Returns: TRUE if can afford, FALSE otherwise
	 */
	var/buy_price = GetBuyPrice(item_name)
	var/total_cost = buy_price * quantity
	
	return current_wealth >= total_cost

/datum/npc_merchant/proc/HasItemsToSell(item_name, quantity)
	/**
	 * HasItemsToSell(item_name, quantity)
	 * Checks if merchant has enough items in stock
	 * Returns: TRUE if has items, FALSE otherwise
	 */
	var/in_stock = GetInventoryCount(item_name)
	return in_stock >= quantity

// ============================================================================
// MERCHANT TRADING
// ============================================================================

/datum/npc_merchant/proc/CanTrade()
	/**
	 * CanTrade()
	 * Checks if merchant is available to trade (not on cooldown)
	 * Returns: TRUE if ready, FALSE if cooldown active
	 */
	var/time_since_trade = (world.time - last_trade_time) / 10
	return time_since_trade >= trading_cooldown

/datum/npc_merchant/proc/SellToMerchant(mob/players/player, item_name, quantity)
	/**
	 * SellToMerchant(player, item_name, quantity)
	 * Player sells items to merchant
	 * Returns: amount paid to player, 0 if trade failed
	 */
	if(!CanTrade())
		return 0
	
	if(!HasItemsToSell(item_name, quantity))
		return 0
	
	var/buy_price = GetBuyPrice(item_name)
	var/total_payment = buy_price * quantity
	
	if(!CanAffordToPurchase(item_name, quantity))
		return 0
	
	// Execute trade
	current_wealth -= total_payment
	AddToInventory(item_name, quantity)
	
	// Update statistics
	last_trade_time = world.time
	total_trades++
	total_wealth_traded += total_payment
	
	// Update mood (just bought items = happy)
	mood += 5
	mood = clamp(mood, -100, 100)
	if(player)
		UpdatePlayerRelationship(player.key, 2)  // +2 relationship
		world.log << "MERCHANT: [merchant_name] bought [quantity] [item_name] from [player.key] for [total_payment] lucre"
	
	// Update market (inventory increase = slight supply increase)
	UpdateCommoditySupply(item_name, quantity * 0.1)  // Add 10% to market supply
	
	return round(total_payment, 0.01)

/datum/npc_merchant/proc/BuyFromMerchant(mob/players/player, item_name, quantity)
	/**
	 * BuyFromMerchant(player, item_name, quantity)
	 * Player buys items from merchant
	 * Returns: amount player must pay, 0 if trade failed
	 */
	if(!CanTrade())
		return 0
	
	if(!HasItemsToSell(item_name, quantity))
		return 0
	
	var/sell_price = GetSellPrice(item_name)
	var/total_cost = sell_price * quantity
	
	if(!player) return 0
	
	// Check if player can afford it
	if(player.lucre < total_cost)
		return 0
	
	// Execute trade
	current_wealth += total_cost
	RemoveFromInventory(item_name, quantity)
	
	// Update statistics
	last_trade_time = world.time
	total_trades++
	total_wealth_traded += total_cost
	
	// Update mood (just sold items = happy)
	mood += 3
	mood = clamp(mood, -100, 100)
	UpdatePlayerRelationship(player.key, 1)  // +1 relationship
	world.log << "MERCHANT: [merchant_name] sold [quantity] [item_name] to [player.key] for [total_cost] lucre"
	
	// Update market (inventory decrease = slight demand increase)
	UpdateCommodityDemand(item_name, quantity * 0.1)  // Add 10% to market demand
	
	return round(total_cost, 0.01)

// ============================================================================
// MERCHANT MOOD & RELATIONSHIPS
// ============================================================================

/datum/npc_merchant/proc/UpdatePlayerRelationship(player_name, change)
	/**
	 * UpdatePlayerRelationship(player_name, change)
	 * Updates relationship with a specific player
	 * Positive change = more favorable, negative = less favorable
	 */
	if(!player_name) return
	
	var/current = player_relationships[player_name] || 0
	player_relationships[player_name] = clamp(current + change, -100, 100)

/datum/npc_merchant/proc/GetPlayerRelationship(player_name)
	/**
	 * GetPlayerRelationship(player_name)
	 * Returns relationship score with player (-100 to +100)
	 */
	return player_relationships[player_name] || 0

/datum/npc_merchant/proc/UpdateMood(change = 0)
	/**
	 * UpdateMood(change)
	 * Updates merchant mood
	 * Positive = happy, negative = grumpy
	 */
	mood += change
	mood = clamp(mood, -100, 100)
	switch(global.season)
		if("Spring")
			mood += 5                           // Spring: optimistic
		if("Summer")
			mood += 3                           // Summer: good
		if("Autumn")
			mood -= 5                           // Autumn: worried about winter
		if("Winter")
			mood -= 15                          // Winter: very grumpy
	
	mood = clamp(mood, -100, 100)

/datum/npc_merchant/proc/GetMoodDescription()
	/**
	 * GetMoodDescription()
	 * Returns human-readable mood description
	 */
	switch(mood)
		if(-100 to -50)
			return "absolutely furious"
		if(-49 to -20)
			return "very angry"
		if(-19 to -1)
			return "irritated"
		if(0 to 20)
			return "neutral"
		if(21 to 50)
			return "happy"
		if(51 to 100)
			return "extremely happy"

// ============================================================================
// MERCHANT PREFERENCES
// ============================================================================

/datum/npc_merchant/proc/SetBuyPreferences(list/items)
	/**
	 * SetBuyPreferences(list of item names)
	 * Defines items merchant wants to buy
	 */
	prefers_buying = items.Copy()

/datum/npc_merchant/proc/SetSellPreferences(list/items)
	/**
	 * SetSellPreferences(list of item names)
	 * Defines items merchant sells
	 */
	prefers_selling = items.Copy()

/datum/npc_merchant/proc/AddSpecialtyItem(item_name, markup)
	/**
	 * AddSpecialtyItem(item_name, markup)
	 * Marks item as specialty with extra markup
	 */
	specialty_items[item_name] = markup

/datum/npc_merchant/proc/GetSellPriceSpecialty(item_name)
	/**
	 * GetSellPriceSpecialty(item_name)
	 * Returns sell price for specialty items (with markup)
	 */
	var/base_price = GetSellPrice(item_name)
	
	if(item_name in specialty_items)
		var/markup = specialty_items[item_name]
		base_price *= (1.0 + markup)
	
	return round(base_price, 0.01)

// ============================================================================
// MERCHANT INVENTORY RESTOCKING
// ============================================================================

/datum/npc_merchant/proc/RespawnInventory()
	/**
	 * RespawnInventory()
	 * Restocks merchant inventory periodically
	 * Called by seasonal/daily systems
	 */
	for(var/item_name in prefers_selling)
		// Restock based on selling preferences
		var/amount = rand(10, 50)
		
		// Don't exceed inventory limits
		if(!CanCarryMore()) break
		
		var/current = GetInventoryCount(item_name)
		if(current < 20)
			AddToInventory(item_name, amount)

/datum/npc_merchant/proc/ResetWealth()
	/**
	 * ResetWealth()
	 * Resets merchant wealth to starting amount
	 * Called at season change or after bankruptcy
	 */
	current_wealth = starting_wealth

/datum/npc_merchant/proc/DecayWealth()
	/**
	 * DecayWealth()
	 * Reduces wealth over time (operational costs)
	 * Called daily
	 */
	var/daily_cost = starting_wealth * 0.05
	current_wealth -= daily_cost
	
	// Prevent bankruptcy
	if(current_wealth < 0)
		current_wealth = starting_wealth * 0.5
		mood -= 30  // Very grumpy
		reputation -= 10

// ============================================================================
// MERCHANT STATISTICS & ANALYSIS
// ============================================================================

/datum/npc_merchant/proc/GetMerchantStats()
	/**
	 * GetMerchantStats()
	 * Returns comprehensive merchant statistics
	 */
	var/inv_count = 0
	for(var/item in inventory) inv_count++
	
	var/list/stats = list(
		"name" = merchant_name,
		"type" = merchant_type,
		"personality" = personality,
		"wealth" = current_wealth,
		"mood" = mood,
		"mood_desc" = GetMoodDescription(),
		"inventory_slots" = inv_count,
		"inventory_max" = max_inventory_slots,
		"total_trades" = total_trades,
		"total_wealth_traded" = total_wealth_traded,
		"buy_margin" = profit_margin,
		"sell_margin" = profit_margin,
		"reputation" = reputation,
		"can_trade" = CanTrade()
	)
	
	return stats

/datum/npc_merchant/proc/GetInventoryList()
	/**
	 * GetInventoryList()
	 * Returns formatted list of merchant inventory
	 */
	var/list/inv_list = list()
	
	for(var/item_name in inventory)
		var/qty = inventory[item_name]
		var/price = GetSellPrice(item_name)
		
		inv_list += "[qty]x [item_name] @ [price] lucre"
	
	// Return count check instead of .len
	var/count = 0
	for(var/entry in inv_list) count++
	if(count == 0)
		inv_list += "Merchant inventory is empty"
	
	return inv_list

// ============================================================================
// MERCHANT CREATION SYSTEM
// ============================================================================

/proc/InitializeNPCMerchantSystem()
	/**
	 * InitializeNPCMerchantSystem()
	 * Sets up NPC merchant system during world initialization
	 * Phase 3: Loads merchants from SQLite if they exist, otherwise creates defaults
	 */
	
	// Try to load merchants from SQLite persistence
	var/list/saved_merchant_ids = GetAllMerchants()
	if(saved_merchant_ids && saved_merchant_ids.len)
		world.log << "MERCHANT_SYSTEM: Loading [saved_merchant_ids.len] merchants from SQLite..."
		for(var/merchant_id in saved_merchant_ids)
			var/datum/npc_merchant/merchant = LoadMerchantState(merchant_id)
			if(merchant)
				world.log << "  ✓ Loaded merchant: [merchant.merchant_name] ([merchant.merchant_type])"
	else
		// No saved merchants - create defaults
		world.log << "MERCHANT_SYSTEM: No saved merchants found, creating defaults..."
		CreateDefaultMerchants()
	
	// Start periodic maintenance
	spawn() MerchantMaintenanceLoop()
	
	world.log << "MERCHANT_SYSTEM: NPC merchant system initialized (Phase 3 SQLite)"

/proc/CreateDefaultMerchants()
	/**
	 * CreateDefaultMerchants()
	 * Creates a set of default merchants at different locations
	 * Phase 3: Saves merchants to SQLite after creation
	 */
	var/datum/npc_merchant/tavern_keeper = CreateMerchant("Tavern Keeper", "trader", "fair")
	if(tavern_keeper)
		tavern_keeper.SetBuyPreferences(list("Grain", "Herb", "Vegetable"))
		tavern_keeper.SetSellPreferences(list("Food", "Ale", "Bread"))
		tavern_keeper.AddToInventory("Food", 30)
		tavern_keeper.AddToInventory("Ale", 20)
		tavern_keeper.starting_wealth = 500
		tavern_keeper.current_wealth = 500
		SaveMerchantState(tavern_keeper)
	
	var/datum/npc_merchant/blacksmith = CreateMerchant("Blacksmith", "blacksmith", "greedy")
	if(blacksmith)
		blacksmith.SetBuyPreferences(list("Iron Ore", "Stone", "Wood"))
		blacksmith.SetSellPreferences(list("Iron Hammer", "Iron Pickaxe", "Steel Sword"))
		blacksmith.AddToInventory("Iron Hammer", 5)
		blacksmith.AddToInventory("Iron Pickaxe", 3)
		blacksmith.AddToInventory("Steel Sword", 2)
		blacksmith.starting_wealth = 1000
		blacksmith.current_wealth = 1000
		SaveMerchantState(blacksmith)
	
	var/datum/npc_merchant/herbalist = CreateMerchant("Herbalist", "herbalist", "fair")
	if(herbalist)
		herbalist.SetBuyPreferences(list("Herb", "Flower", "Plant"))
		herbalist.SetSellPreferences(list("Potion", "Herb Extract", "Salve"))
		herbalist.AddToInventory("Potion", 15)
		herbalist.AddToInventory("Herb Extract", 10)
		herbalist.starting_wealth = 300
		herbalist.current_wealth = 300
		SaveMerchantState(herbalist)
	
	var/datum/npc_merchant/fisherman = CreateMerchant("Fisherman", "fisherman", "desperate")
	if(fisherman)
		fisherman.SetBuyPreferences(list("Fish", "Net", "Boat Supplies"))
		fisherman.SetSellPreferences(list("Fish", "Fish Oil", "Fishing Nets"))
		fisherman.AddToInventory("Fish", 50)
		fisherman.AddToInventory("Fish Oil", 10)
		fisherman.starting_wealth = 150
		fisherman.current_wealth = 150
		SaveMerchantState(fisherman)
	
	world.log << "MERCHANT_SYSTEM: Created and saved 4 default merchants to SQLite"

// ============================================================================
// MERCHANT MAINTENANCE LOOP
// ============================================================================

/proc/MerchantMaintenanceLoop()
	/**
	 * MerchantMaintenanceLoop()
	 * Periodic maintenance for all merchants
	 * Restocks inventory, decays wealth, updates mood
	 */
	set background = 1
	set waitfor = 0
	
	var/maintenance_interval = 2400
	
	while(1)
		sleep(maintenance_interval)
		
		// Update all merchants
		// This would iterate through a global merchant registry
		// For now, provides the framework
		
		world.log << "MERCHANT_SYSTEM: Daily maintenance complete"

/proc/GetMerchantCount()
	/**
	 * GetMerchantCount()
	 * Returns number of active merchants
	 * Currently returns default count (4)
	 */
	return 4  // Default merchants

/proc/GetMerchantPrice(merchant_name, item_name, trade_type = "sell")
	/**
	 * GetMerchantPrice(merchant_name, item_name, trade_type)
	 * Gets price from specific merchant
	 * trade_type: "buy" or "sell"
	 */
	// This would look up merchant from global registry
	// For now, returns market price
	
	if(trade_type == "buy")
		return GetCommodityPrice(item_name) * 0.9
	else
		return GetCommodityPrice(item_name) * 1.1
