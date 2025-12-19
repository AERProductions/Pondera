// NPCFoodSupplySystem.dm - Phase 38B: NPC Shop Hours & Food Supply Management
// Gates NPC interactions based on shop hours, tracks food supply in town

// Town Food Supply tracking
/datum/town_food_supply
	var
		bread_supply = 100           // Loaves of bread available
		cooked_meals = 50            // Prepared meals available
		fresh_vegetables = 75        // Fresh produce
		dried_goods = 100            // Non-perishable supplies
		
		last_baker_restock = 0       // World time of last baking
		last_farmer_harvest = 0      // World time of last harvest
		last_merchant_trade = 0      // World time of last trade
		
		supply_last_updated = 0      // When supply was last recalculated
		
		// Supply thresholds (when to trigger events)
		low_bread_threshold = 20
		critical_supply_threshold = 10
		
		// NPC consumption rates (per game day)
		daily_bread_consumption = 30
		daily_meal_consumption = 20
		daily_vegetable_consumption = 15

/datum/town_food_supply/proc/Initialize()
	// Called from InitializationManager
	supply_last_updated = world.time
	
	// Start background update loop
	spawn UpdateFoodSupply()

/datum/town_food_supply/proc/UpdateFoodSupply()
	// Background loop: update food supply every game day
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(1440)  // Update every game day (~1.4 seconds real time)
		
		if(!world_initialization_complete) continue
		
		// Simulate NPC consumption
		ConsumeFoodDaily()
		
		// Check for supply warnings
		CheckFoodSupplyWarnings()

/datum/town_food_supply/proc/ConsumeFoodDaily()
	// NPCs in town consume food daily
	
	// Reduce supplies by daily consumption rates
	bread_supply -= daily_bread_consumption
	cooked_meals -= daily_meal_consumption
	fresh_vegetables -= daily_vegetable_consumption
	
	// Ensure no negative supplies
	bread_supply = max(0, bread_supply)
	cooked_meals = max(0, cooked_meals)
	fresh_vegetables = max(0, fresh_vegetables)
	
	supply_last_updated = world.time
	
	// Log supply status
	if(global_time_system)
		LogSystemEvent(null, "supply", "Daily consumption: Bread=[bread_supply], Meals=[cooked_meals], Vegetables=[fresh_vegetables]")

/datum/town_food_supply/proc/RestockBread(amount)
	// Baker restocks bread supply
	bread_supply += amount
	last_baker_restock = world.time
	
	LogSystemEvent(null, "supply", "Baker restocked [amount] loaves. Total: [bread_supply]")

/datum/town_food_supply/proc/RestockMeals(amount)
	// Chef/Cook prepares meals
	cooked_meals += amount
	
	LogSystemEvent(null, "supply", "Chef prepared [amount] meals. Total: [cooked_meals]")

/datum/town_food_supply/proc/HarvestVegetables(amount)
	// Farmer harvests vegetables
	fresh_vegetables += amount
	last_farmer_harvest = world.time
	
	LogSystemEvent(null, "supply", "Farmer harvested [amount] vegetables. Total: [fresh_vegetables]")

/datum/town_food_supply/proc/TradeGoods(type, amount)
	// Merchant trades goods into/out of supply
	
	switch(type)
		if("bread")
			bread_supply += amount
		if("meals")
			cooked_meals += amount
		if("vegetables")
			fresh_vegetables += amount
		if("dried")
			dried_goods += amount
	
	last_merchant_trade = world.time
	
	LogSystemEvent(null, "supply", "Merchant traded [amount] [type]. Update: Bread=[bread_supply], Meals=[cooked_meals]")

/datum/town_food_supply/proc/CheckFoodSupplyWarnings()
	// Trigger warnings when supply gets low
	
	// Check for critical shortages
	if(bread_supply < critical_supply_threshold)
		for(var/mob/players/P in world)
			P << "CRITICAL: Bread shortage! Bakers must produce immediately!"
			LogSystemEvent(P, "alert", "Critical bread shortage - [bread_supply] loaves remaining")
	
	else if(bread_supply < low_bread_threshold)
		for(var/mob/players/P in world)
			P << "WARNING: Low bread supply - [bread_supply] loaves remaining"
	
	// Check overall supply status
	var/total_supply = bread_supply + cooked_meals + fresh_vegetables
	if(total_supply < critical_supply_threshold)
		for(var/mob/players/P in world)
			P << "CRITICAL SUPPLY SHORTAGE - Food supply at minimum!"

/datum/town_food_supply/proc/GetSupplyStatus()
	// Return text description of current food supply
	
	var/status = "=== TOWN FOOD SUPPLY STATUS ===\n"
	status += "Bread Loaves: [bread_supply]\n"
	status += "Prepared Meals: [cooked_meals]\n"
	status += "Fresh Vegetables: [fresh_vegetables]\n"
	status += "Dried Goods: [dried_goods]\n"
	status += "\n=== DAILY CONSUMPTION ===\n"
	status += "Bread: -[daily_bread_consumption] loaves\n"
	status += "Meals: -[daily_meal_consumption] meals\n"
	status += "Vegetables: -[daily_vegetable_consumption] items\n"
	status += "\n=== LAST UPDATES ===\n"
	status += "Baker Restock: [last_baker_restock ? "T+[last_baker_restock]" : "Never"]\n"
	status += "Farmer Harvest: [last_farmer_harvest ? "T+[last_farmer_harvest]" : "Never"]\n"
	status += "Merchant Trade: [last_merchant_trade ? "T+[last_merchant_trade]" : "Never"]\n"
	
	return status

// Global town food supply instance
var/datum/town_food_supply/global_town_food_supply = null

/proc/InitializeFoodSupplySystem()
	// Called from InitializationManager during Phase 38B (T+365)
	
	global_town_food_supply = new /datum/town_food_supply()
	global_town_food_supply.Initialize()
	
	RegisterInitComplete("food_supply")
	LogSystemEvent(null, "system", "Food Supply System initialized (Phase 38B)")

/proc/IsNPCShopOpen(npc_name)
	// Check if NPC's shop is currently open based on game time
	// Returns: 1 if open, 0 if closed
	// Integrates with global hour/minute variables from time.dm
	
	// Define shop hours per NPC type (24-hour format)
	// Most shops: 9am-6pm (9-18)
	// Tavern/Inn: 6am-10pm (6-22)
	// Baker: 5am-8pm (5-20)
	// Merchant: 8am-7pm (8-19)
	// Smith: 8am-6pm (8-18)
	
	var/open_hour = 9
	var/close_hour = 18
	
	switch(npc_name)
		if("Baker")
			open_hour = 5
			close_hour = 20
		if("Innkeeper", "Bartender")
			open_hour = 6
			close_hour = 22
		if("Merchant")
			open_hour = 8
			close_hour = 19
		if("Smith", "Blacksmith")
			open_hour = 8
			close_hour = 18
		if("Fisher")
			// Open during morning/evening (dawn/dusk + afternoon)
			// Available: 5am-9am and 3pm-8pm
			if((hour >= 5 && hour < 9) || (hour >= 15 && hour < 20))
				return 1
			return 0
		if("Herbalist")
			open_hour = 9
			close_hour = 17
		else
			// Default shop hours: 9am-6pm
			open_hour = 9
			close_hour = 18
	
	// Check if current hour is within shop hours
	if(hour >= open_hour && hour < close_hour)
		return 1
	
	return 0

/proc/GetNPCShopStatus(npc_name)
	// Return string description of NPC shop status
	// Integrates with global hour/minute variables
	
	// Calculate shop hours for this NPC
	var/open_hour = 9
	var/close_hour = 18
	var/shop_name = npc_name
	
	switch(npc_name)
		if("Baker")
			open_hour = 5
			close_hour = 20
			shop_name = "Bakery"
		if("Innkeeper", "Bartender")
			open_hour = 6
			close_hour = 22
			shop_name = "Inn/Tavern"
		if("Merchant")
			open_hour = 8
			close_hour = 19
			shop_name = "Trading Post"
		if("Smith", "Blacksmith")
			open_hour = 8
			close_hour = 18
			shop_name = "Smithy"
		if("Fisher")
			shop_name = "Fishing Spot"
		if("Herbalist")
			open_hour = 9
			close_hour = 17
			shop_name = "Herbalist's Shop"
		else
			shop_name = "[npc_name]'s Shop"
	
	var/is_open = IsNPCShopOpen(npc_name)
	var/status_text = is_open ? "OPEN" : "CLOSED"
	var/status_color = is_open ? "#00ff00" : "#ff6666"
	
	var/time_str = "[hour]:[minute1][minute2]"
	
	if(npc_name == "Fisher")
		return "<font color='[status_color]'>[shop_name] - [status_text]</font> (Available: 5am-9am, 3pm-8pm) Current time: [time_str]"
	else
		return "<font color='[status_color]'>[shop_name] - [status_text]</font> (Hours: [open_hour]:00 - [close_hour]:00) Current time: [time_str]"

/proc/CanPlayerBuyFromNPC(mob/player, npc_name)
	// Check if player can buy from this NPC
	// Returns: 1 if can trade, 0 if shop closed
	
	if(!IsNPCShopOpen(npc_name))
		player << "This shop is closed right now. Check back during business hours."
		player << GetNPCShopStatus(npc_name)
		return 0
	
	return 1

/proc/CanPlayerSellToNPC(mob/player, npc_name)
	// Check if player can sell to this NPC
	// Merchants are generally open longer than other shops
	
	if(!IsNPCShopOpen(npc_name))
		player << "This merchant isn't buying right now. Try during business hours."
		player << GetNPCShopStatus(npc_name)
		return 0
	
	return 1

// Debug & Admin Verbs

/mob/verb/ViewFoodSupplyStatus()
	set category = "Debug"
	set name = "View Town Food Supply"
	
	if(!global_town_food_supply)
		usr << "Food supply system not initialized"
		return
	
	usr << global_town_food_supply.GetSupplyStatus()

/mob/verb/TestShopHours()
	set category = "Debug"
	set name = "Test NPC Shop Hours"
	
	var/npc_names = list("Blacksmith", "Merchant", "Herbalist", "Innkeeper", "Fisher", "Baker")
	
	var/msg = "═══════════════════════════════════════\n"
	msg += "SHOP HOURS STATUS\n"
	msg += "═══════════════════════════════════════\n"
	
	for(var/name in npc_names)
		msg += GetNPCShopStatus(name) + "\n\n"
	
	usr << msg

/mob/verb/RestockFoodSupply()
	set category = "Debug"
	set name = "Restock Food Supply"
	
	if(!global_town_food_supply)
		usr << "Food supply system not initialized"
		return
	
	global_town_food_supply.RestockBread(50)
	global_town_food_supply.RestockMeals(30)
	global_town_food_supply.HarvestVegetables(40)
	
	usr << "Food supply restocked!"
	usr << global_town_food_supply.GetSupplyStatus()

/mob/verb/DrainFoodSupply()
	set category = "Debug"
	set name = "Drain Food Supply (simulate shortage)"
	
	if(!global_town_food_supply)
		usr << "Food supply system not initialized"
		return
	
	global_town_food_supply.bread_supply = 5
	global_town_food_supply.cooked_meals = 3
	global_town_food_supply.fresh_vegetables = 5
	
	usr << "Food supply drained to critical levels!"
	usr << global_town_food_supply.GetSupplyStatus()
