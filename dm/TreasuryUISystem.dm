// TreasuryUISystem.dm - Kingdom Treasury Visualization & Management Interface
// Provides visual interface for kingdom resource management, trading history, and economic analysis
// Enables players and admins to monitor and control kingdom finances

// ============================================================================
// TREASURY UI SCREEN OBJECTS
// ============================================================================

/obj/screen/treasury_display
	/**
	 * treasury_display
	 * Main treasury UI screen object showing kingdom resources
	 */
	icon_state = "panel"
	screen_loc = "1,1 to 10,12"
	layer = 20
	plane = 2
	
	var
		kingdom_name = "Kingdom"
		last_update = 0
		update_interval = 50
		
		// Resource display
		display_stone = 0
		display_metal = 0
		display_timber = 0
		display_lucre = 0
		stone_trend = "stable"
		metal_trend = "stable"
		timber_trend = "stable"
		display_mode = "overview"

/obj/screen/treasury_button
	/**
	 * treasury_button
	 * Individual button in treasury UI for resource display
	 */
	icon_state = "button"
	layer = 21
	plane = 2
	
	var
		resource_type = ""
		amount = 0
		trend = "stable"
		price = 0

/obj/screen/trade_history_display
	/**
	 * trade_history_display
	 * Shows recent trades for the kingdom
	 */
	icon_state = "list"
	screen_loc = "1,1 to 10,8"
	layer = 20
	plane = 2
	
	var
		list/trades = list()
		display_index = 1
		items_per_page = 5
		max_pages = 1

/obj/screen/market_price_display
	/**
	 * market_price_display
	 * Shows current market prices for key commodities
	 */
	icon_state = "panel"
	screen_loc = "11,1 to 20,12"
	layer = 20
	plane = 2
	
	var
		list/displayed_commodities = list()
		sort_mode = "price"

// ============================================================================
// TREASURY UI MANAGEMENT SYSTEM
// ============================================================================

/datum/treasury_ui_manager
	/**
	 * treasury_ui_manager
	 * Manages treasury UI for a specific kingdom
	 */
	var
		kingdom_name = ""
		mob/players/owner = null
		
		// UI screens
		obj/screen/treasury_display/main_display = null
		obj/screen/trade_history_display/history_display = null
		obj/screen/market_price_display/market_display = null
		view_mode = "overview"
		sort_order = "amount"
		auto_refresh = 1
		refresh_rate = 50
		
		// Data caching
		cached_treasury = null
		cached_prices = null
		cached_trades = list()
		last_update = 0

/proc/InitializeTreasuryUISystem()
	/**
	 * InitializeTreasuryUISystem()
	 * Sets up treasury UI system on world boot
	 */
	world.log << "TREASURY_UI: Treasury UI system initialized"

/proc/AttachTreasuryUIToKingdom(kingdom_name, mob/player)
	/**
	 * AttachTreasuryUIToKingdom(kingdom_name, player)
	 * Creates and attaches treasury UI to a player for a specific kingdom
	 * Returns: treasury_ui_manager datum
	 */
	if(!player || !kingdom_name) return null
	
	var/datum/treasury_ui_manager/manager = new()
	manager.kingdom_name = kingdom_name
	manager.owner = player
	var/obj/screen/treasury_display/display = new()
	display.kingdom_name = kingdom_name
	if(player.client) player.client.screen += display
	manager.main_display = display
	var/obj/screen/trade_history_display/history = new()
	if(player.client) player.client.screen += history
	manager.history_display = history
	var/obj/screen/market_price_display/market = new()
	if(player.client) player.client.screen += market
	manager.market_display = market
	spawn() TreasuryUIUpdateLoop(manager)
	
	world.log << "TREASURY_UI: Attached treasury UI to [player.key] for [kingdom_name]"
	
	return manager

/proc/DetachTreasuryUI(datum/treasury_ui_manager/manager)
	/**
	 * DetachTreasuryUI(manager)
	 * Removes treasury UI from player
	 */
	if(!manager || !manager.owner) return
	
	if(manager.main_display && manager.owner.client)
		manager.owner.client.screen -= manager.main_display
	if(manager.history_display && manager.owner.client)
		manager.owner.client.screen -= manager.history_display
	if(manager.market_display && manager.owner.client)
		manager.owner.client.screen -= manager.market_display
	
	world.log << "TREASURY_UI: Detached treasury UI from [manager.owner.ckey]"

/proc/UpdateTreasuryDisplay(datum/treasury_ui_manager/manager)
	/**
	 * UpdateTreasuryDisplay(manager)
	 * Refreshes the treasury display with current data
	 */
	if(!manager || !manager.owner || !manager.main_display) return
	
	// Get current kingdom treasury
	var/datum/kingdom_treasury_manager/treasury = GetKingdomTreasury(manager.kingdom_name)
	if(!treasury) return
	
	// Update display values
	manager.main_display.display_stone = treasury.stone_treasury
	manager.main_display.display_metal = treasury.metal_treasury
	manager.main_display.display_timber = treasury.timber_treasury
	manager.main_display.display_lucre = treasury.lucre_treasury
	manager.main_display.stone_trend = GetCommodityTrend("Stone")
	manager.main_display.metal_trend = GetCommodityTrend("Metal Ore")
	manager.main_display.timber_trend = GetCommodityTrend("Timber")
	
	manager.last_update = world.time

/proc/UpdateTradeHistoryDisplay(datum/treasury_ui_manager/manager)
	/**
	 * UpdateTradeHistoryDisplay(manager)
	 * Refreshes the trade history view
	 */
	if(!manager || !manager.history_display) return
	
	// Get kingdom's pending and completed trades
	var/list/pending = GetKingdomPendingOffers(manager.kingdom_name)
	var/list/completed = GetKingdomTradeHistory(manager.kingdom_name, 20)
	
	manager.cached_trades = list()
	for(var/datum/kingdom_trade_offer/offer in pending)
		manager.cached_trades += list(list(
			"status" = "pending",
			"id" = offer.offer_id,
			"partner" = (offer.offering_kingdom == manager.kingdom_name) ? offer.requesting_kingdom : offer.offering_kingdom,
			"timestamp" = offer.created_time,
			"notes" = offer.offer_notes
		))
	
	// Add completed trades
	for(var/datum/kingdom_trade_offer/offer in completed)
		manager.cached_trades += list(list(
			"status" = "completed",
			"id" = offer.offer_id,
			"partner" = (offer.offering_kingdom == manager.kingdom_name) ? offer.requesting_kingdom : offer.offering_kingdom,
			"timestamp" = offer.completion_time,
			"duration" = offer.completion_time - offer.created_time
		))
	
	manager.history_display.trades = manager.cached_trades
	manager.history_display.max_pages = ceil(length(manager.cached_trades) / manager.history_display.items_per_page)

/proc/UpdateMarketPriceDisplay(datum/treasury_ui_manager/manager)
	/**
	 * UpdateMarketPriceDisplay(manager)
	 * Refreshes market prices display
	 */
	if(!manager || !manager.market_display) return
	
	var/datum/market_price_tracker/prices = GetMarketPrices()
	if(!prices) return
	
	manager.market_display.displayed_commodities = list(
		list("name" = "Stone", "price" = prices.stone_price, "trend" = GetCommodityTrend("Stone")),
		list("name" = "Metal Ore", "price" = prices.metal_price, "trend" = GetCommodityTrend("Metal Ore")),
		list("name" = "Timber", "price" = prices.timber_price, "trend" = GetCommodityTrend("Timber")),
		list("name" = "Iron Ingot", "price" = GetCommodityPrice("Iron Ingot"), "trend" = GetCommodityTrend("Iron Ingot")),
		list("name" = "Steel Ingot", "price" = GetCommodityPrice("Steel Ingot"), "trend" = GetCommodityTrend("Steel Ingot"))
	)

/proc/TreasuryUIUpdateLoop(datum/treasury_ui_manager/manager)
	/**
	 * TreasuryUIUpdateLoop(manager)
	 * Background loop that updates treasury UI periodically
	 */
	set background = 1
	set waitfor = 0
	
	while(manager && manager.owner)
		sleep(manager.refresh_rate)
		
		if(!manager.owner) break  // Owner logged out
		
		UpdateTreasuryDisplay(manager)
		UpdateTradeHistoryDisplay(manager)
		UpdateMarketPriceDisplay(manager)

/proc/GetTreasuryUIReport(kingdom_name)
	/**
	 * GetTreasuryUIReport(kingdom_name)
	 * Generates comprehensive treasury report
	 * Returns: formatted text report
	 */
	var/datum/kingdom_treasury_manager/treasury = GetKingdomTreasury(kingdom_name)
	if(!treasury) return "No treasury data found"
	
	var/output = ""
	output += "═════════════════════════════════════════════\n"
	output += "TREASURY REPORT: [kingdom_name]\n"
	output += "═════════════════════════════════════════════\n\n"
	
	// Resources section
	output += "CURRENT RESOURCES:\n"
	output += "  Stone:   [treasury.stone_treasury] (Trend: [GetCommodityTrend("Stone")])\n"
	output += "  Metal:   [treasury.metal_treasury] (Trend: [GetCommodityTrend("Metal Ore")])\n"
	output += "  Timber:  [treasury.timber_treasury] (Trend: [GetCommodityTrend("Timber")])\n"
	output += "  Lucre:   [treasury.lucre_treasury]\n\n"
	
	// Net worth
	var/net_worth = GetKingdomNetWorth(kingdom_name)
	output += "NET WORTH: [round(net_worth, 0.01)] lucre\n\n"
	
	// Trading activity
	output += "TRADING ACTIVITY:\n"
	output += "  Pending Offers: [length(treasury.pending_offers)]\n"
	output += "  Completed Trades: [length(treasury.completed_trades)]\n"
	output += "  Reputation: [treasury.trade_reputation]/100\n\n"
	
	// Market prices
	var/datum/market_price_tracker/prices = GetMarketPrices()
	if(prices)
		output += "MARKET PRICES:\n"
		output += "  Stone:  [round(prices.stone_price, 0.01)] lucre\n"
		output += "  Metal:  [round(prices.metal_price, 0.01)] lucre\n"
		output += "  Timber: [round(prices.timber_price, 0.01)] lucre\n\n"
	
	output += "═════════════════════════════════════════════\n"
	
	return output

/proc/DisplayTreasuryReport(mob/player, kingdom_name)
	/**
	 * DisplayTreasuryReport(player, kingdom_name)
	 * Shows formatted treasury report to player
	 */
	if(!player) return
	
	var/report = GetTreasuryUIReport(kingdom_name)
	player << report

/proc/GetResourceBreakdown(kingdom_name)
	/**
	 * GetResourceBreakdown(kingdom_name)
	 * Returns breakdown of kingdom resources by percentage
	 */
	var/datum/kingdom_treasury_manager/treasury = GetKingdomTreasury(kingdom_name)
	if(!treasury) return null
	
	var/total_materials = treasury.stone_treasury + treasury.metal_treasury + treasury.timber_treasury
	if(total_materials <= 0)
		return list(
			"stone_pct" = 0,
			"metal_pct" = 0,
			"timber_pct" = 0,
			"total" = 0
		)
	
	return list(
		"stone_pct" = round((treasury.stone_treasury / total_materials) * 100, 0.1),
		"metal_pct" = round((treasury.metal_treasury / total_materials) * 100, 0.1),
		"timber_pct" = round((treasury.timber_treasury / total_materials) * 100, 0.1),
		"total" = total_materials,
		"stone_amount" = treasury.stone_treasury,
		"metal_amount" = treasury.metal_treasury,
		"timber_amount" = treasury.timber_treasury
	)

/proc/GetTreasuryTrends(kingdom_name, num_days = 7)
	/**
	 * GetTreasuryTrends(kingdom_name, num_days)
	 * Analyzes treasury trends over time
	 * Returns: analysis data
	 */
	var/datum/kingdom_treasury_manager/treasury = GetKingdomTreasury(kingdom_name)
	if(!treasury) return null
	
	var/list/analysis = list(
		"kingdom" = kingdom_name,
		"analysis_period" = "[num_days] days",
		"total_trades" = treasury.completed_trades.len,
		"pending_trades" = treasury.pending_offers.len,
		"reputation" = treasury.trade_reputation,
		"most_traded_resource" = null,
		"price_impact" = "neutral"
	)
	
	// Determine most traded resource
	var/stone_trades = 0
	var/metal_trades = 0
	var/timber_trades = 0
	
	for(var/datum/kingdom_trade_offer/trade in treasury.completed_trades)
		stone_trades += trade.offering_stone + trade.requesting_stone
		metal_trades += trade.offering_metal + trade.requesting_metal
		timber_trades += trade.offering_timber + trade.requesting_timber
	
	if(stone_trades > metal_trades && stone_trades > timber_trades)
		analysis["most_traded_resource"] = "Stone"
	else if(metal_trades > timber_trades)
		analysis["most_traded_resource"] = "Metal"
	else
		analysis["most_traded_resource"] = "Timber"
	
	return analysis

/proc/ExportTreasuryToLog(kingdom_name)
	/**
	 * ExportTreasuryToLog(kingdom_name)
	 * Exports complete treasury data to world log
	 */
	var/report = GetTreasuryUIReport(kingdom_name)
	var/breakdown = GetResourceBreakdown(kingdom_name)
	var/trends = GetTreasuryTrends(kingdom_name)
	
	world.log << "═════════════════════════════════════════════"
	world.log << "TREASURY EXPORT: [kingdom_name]"
	world.log << "Time: [time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")]"
	world.log << "═════════════════════════════════════════════"
	world.log << report
	world.log << "RESOURCE BREAKDOWN:"
	world.log << "  Stone:  [breakdown["stone_amount"]] ([breakdown["stone_pct"]]%)"
	world.log << "  Metal:  [breakdown["metal_amount"]] ([breakdown["metal_pct"]]%)"
	world.log << "  Timber: [breakdown["timber_amount"]] ([breakdown["timber_pct"]]%)"
	world.log << "TRENDS:"
	world.log << "  Most Traded: [trends["most_traded_resource"]]"
	world.log << "  Pending Trades: [trends["pending_trades"]]"
	world.log << "  Reputation: [trends["reputation"]]/100"

/proc/DisplayCompariativeTreasuryAnalysis(list/kingdoms)
	/**
	 * DisplayCompariativeTreasuryAnalysis(kingdoms)
	 * Compares multiple kingdoms' treasury status
	 * Returns: comparison report
	 */
	var/output = ""
	output += "═════════════════════════════════════════════\n"
	output += "COMPARATIVE TREASURY ANALYSIS\n"
	output += "═════════════════════════════════════════════\n\n"
	
	// Create comparison table
	output += "Kingdom          | Stone    | Metal    | Timber   | Lucre    | Net Worth\n"
	output += "─────────────────┼──────────┼──────────┼──────────┼──────────┼──────────\n"
	
	for(var/kingdom in kingdoms)
		var/datum/kingdom_treasury_manager/treasury = GetKingdomTreasury(kingdom)
		if(!treasury) continue
		
		var/net_worth = GetKingdomNetWorth(kingdom)
		var/stone_str = "[treasury.stone_treasury]"
		var/metal_str = "[treasury.metal_treasury]"
		var/timber_str = "[treasury.timber_treasury]"
		var/lucre_str = "[treasury.lucre_treasury]"
		var/worth_str = "[round(net_worth, 1)]"
		while(length(stone_str) < 8) stone_str = " " + stone_str
		while(length(metal_str) < 8) metal_str = " " + metal_str
		while(length(timber_str) < 8) timber_str = " " + timber_str
		while(length(lucre_str) < 8) lucre_str = " " + lucre_str
		while(length(worth_str) < 10) worth_str = " " + worth_str
		
		var/kingdom_name = kingdom
		while(length(kingdom_name) < 16) kingdom_name += " "
		
		output += "[kingdom_name]| [stone_str] | [metal_str] | [timber_str] | [lucre_str] | [worth_str]\n"
	
	output += "═════════════════════════════════════════════\n"
	
	return output

/proc/AlertKingdomResourceLow(kingdom_name, resource_type, threshold = 10)
	/**
	 * AlertKingdomResourceLow(kingdom_name, resource_type, threshold)
	 * Alerts when a kingdom's resource drops below threshold
	 */
	var/datum/kingdom_treasury_manager/treasury = GetKingdomTreasury(kingdom_name)
	if(!treasury) return
	
	var/current_amount = 0
	
	switch(resource_type)
		if("stone")
			current_amount = treasury.stone_treasury
		if("metal")
			current_amount = treasury.metal_treasury
		if("timber")
			current_amount = treasury.timber_treasury
		if("lucre")
			current_amount = treasury.lucre_treasury
	
	if(current_amount < threshold)
		world.log << "ALERT: [kingdom_name] has low [resource_type] ([current_amount]/[threshold])"

/proc/AutoSuggestTrade(kingdom_name)
	/**
	 * AutoSuggestTrade(kingdom_name)
	 * Analyzes kingdom treasury and suggests beneficial trades
	 * Returns: list of trade suggestions
	 */
	var/datum/kingdom_treasury_manager/treasury = GetKingdomTreasury(kingdom_name)
	if(!treasury) return list()
	
	var/list/suggestions = list()
	var/total = treasury.stone_treasury + treasury.metal_treasury + treasury.timber_treasury
	if(total <= 0) return suggestions
	
	var/stone_pct = treasury.stone_treasury / total
	var/metal_pct = treasury.metal_treasury / total
	var/timber_pct = treasury.timber_treasury / total
	if(stone_pct > 0.5)
		suggestions += "Consider trading excess stone for metal or timber"
	if(metal_pct > 0.5)
		suggestions += "Consider trading excess metal for stone or timber"
	if(timber_pct > 0.5)
		suggestions += "Consider trading excess timber for stone or metal"
	
	// Market-based suggestions
	var/stone_trend = GetCommodityTrend("Stone")
	var/metal_trend = GetCommodityTrend("Metal Ore")
	
	if(stone_trend == "rising" && treasury.stone_treasury > 100)
		suggestions += "Stone prices rising - good time to sell excess stone"
	if(metal_trend == "falling" && treasury.metal_treasury < 50)
		suggestions += "Metal prices falling - good time to buy metal"
	
	return suggestions

