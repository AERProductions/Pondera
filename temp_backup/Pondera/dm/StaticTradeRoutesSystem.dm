/**
 * STATIC TRADE ROUTES SYSTEM
 * ===========================
 * Story mode merchant caravan routes and trading hubs
 * Adds economic flavor to story world without dynamic wagon system
 * 
 * Started: 12-11-25 8:00PM
 * Focus: Static caravan routes, merchant hubs, quest integration
 */

#define ROUTE_FOREST_TO_CITY "Forest_to_City"
#define ROUTE_CITY_TO_COAST "City_to_Coast"
#define ROUTE_COAST_TO_MOUNTAINS "Coast_to_Mountains"
#define ROUTE_MOUNTAINS_TO_FOREST "Mountains_to_Forest"
#define ROUTE_CITY_CENTER_LOOP "City_Center_Loop"

/datum/trade_hub
	var
		name = ""                 // Display name (e.g., "Port Merchant Guild")
		description = ""          // Flavor text
		location = ""             // Where on map
		faction = ""              // Which faction controls it
		key_goods = list()        // Primary trade goods (list of item types)
		special_deals = list()    // Unique items only here
		npc_merchants = list()    // NPC merchants stationed here
		influenced_by = ""        // Which trade route supplies it

/datum/trade_hub/New(name_input, desc_input, loc_input, faction_input)
	name = name_input
	description = desc_input
	location = loc_input
	faction = faction_input

/datum/trade_hub/proc/AddKeyGood(item_type)
	if(item_type && !(item_type in key_goods))
		key_goods += item_type

/datum/trade_hub/proc/AddSpecialDeal(item_name, price, rarity)
	if(item_name)
		special_deals[item_name] = list("price" = price, "rarity" = rarity)

/datum/trade_route
	var
		key = ""                  // Route ID
		name = ""                 // Display name
		description = ""          // Flavor text
		origin_hub = ""           // Starting hub
		destination_hub = ""      // Ending hub
		travel_time = 0           // Ticks to complete
		goods_transported = list() // What travels this route
		caravan_frequency = 0     // How often (in ticks)
		last_arrival = 0          // Last caravan arrival tick
		next_arrival = 0          // Next expected arrival

/datum/trade_route/New(key_input, name_input, origin, destination, travel, freq)
	key = key_input
	name = name_input
	origin_hub = origin
	destination_hub = destination
	travel_time = travel
	caravan_frequency = freq
	next_arrival = world.timeofday + freq

/datum/trade_route/proc/AddGood(item_type, base_quantity)
	if(item_type)
		goods_transported[item_type] = base_quantity

/datum/trade_routes_system
	var
		list/all_hubs = list()         // All trading hubs
		list/all_routes = list()       // All trade routes
		list/active_caravans = list()  // Currently traveling caravans
		
/datum/trade_routes_system/New()
	PopulateHubs()
	PopulateRoutes()

/datum/trade_routes_system/proc/PopulateHubs()
	/**
	 * Create all story-mode merchant hubs
	 */
	
	// HUB 1: Port Merchant Guild (coastal city)
	var/datum/trade_hub/port_hub = new("Port Merchant Guild", \
		"Bustling coastal marketplace where sea-traders sell exotic wares. " + \
		"Ships arrive daily with spices, fish, and tropical goods. " + \
		"Controlled by the Kingdom of Greed merchant faction.", \
		"Coast District, northern shore", "Kingdom of Greed")
	port_hub.AddKeyGood("spice")
	port_hub.AddKeyGood("fish")
	port_hub.AddKeyGood("tropical_fruit")
	port_hub.AddKeyGood("sea_salt")
	port_hub.AddSpecialDeal("Exotic Silk", 500, "rare")
	port_hub.AddSpecialDeal("Pearl Necklace", 750, "rare")
	all_hubs += port_hub
	
	// HUB 2: Mountain Smithy Trade Post
	var/datum/trade_hub/mountain_hub = new("Mountain Smithy Trade Post", \
		"High-altitude forge where dwarven smiths trade ore and metals. " + \
		"Controlled by the Ironforge Council. Best place to sell raw ore.", \
		"Mountain Peak, Eastern Range", "Ironforge Council")
	mountain_hub.AddKeyGood("iron_ore")
	mountain_hub.AddKeyGood("copper_ore")
	mountain_hub.AddKeyGood("gold_ore")
	mountain_hub.AddKeyGood("gemstones")
	mountain_hub.AddSpecialDeal("Mithril Ore", 1200, "rare")
	mountain_hub.AddSpecialDeal("Diamond", 2000, "legendary")
	all_hubs += mountain_hub
	
	// HUB 3: Forest Druid Circle
	var/datum/trade_hub/forest_hub = new("Forest Druid Circle", \
		"Sacred grove marketplace where nature druids trade herbs and plants. " + \
		"Controlled by the Druid Circle faction. Source of rare herbs.", \
		"Old Growth Forest, western woodland", "Druid Circle")
	forest_hub.AddKeyGood("healing_herb")
	forest_hub.AddKeyGood("rare_plant")
	forest_hub.AddKeyGood("timber")
	forest_hub.AddKeyGood("honey")
	forest_hub.AddSpecialDeal("Moonflower Extract", 400, "rare")
	forest_hub.AddSpecialDeal("Ancient Bark", 600, "rare")
	all_hubs += forest_hub
	
	// HUB 4: Central Market City
	var/datum/trade_hub/city_hub = new("Central Market City", \
		"Heart of the Kingdom. Massive bazaar where all factions trade. " + \
		"Most expensive goods, but guaranteed availability. " + \
		"Neutral zone controlled by the Kingdom.", \
		"Downtown, City Center", "Kingdom Authority")
	city_hub.AddKeyGood("general_goods")
	city_hub.AddKeyGood("crafting_tools")
	city_hub.AddKeyGood("weapons")
	city_hub.AddKeyGood("armor")
	city_hub.AddSpecialDeal("Royal Scepter", 5000, "legendary")
	city_hub.AddSpecialDeal("Crown of Authority", 8000, "legendary")
	all_hubs += city_hub
	
	// HUB 5: Dockside Black Market
	var/datum/trade_hub/black_market = new("Dockside Black Market", \
		"Underground trading post for rare and illegal goods. " + \
		"Higher prices but access to unique items. " + \
		"Controlled by secretive merchant guilds.", \
		"Harbor Alley, eastern docks", "Shadow Syndicate")
	black_market.AddKeyGood("stolen_goods")
	black_market.AddKeyGood("black_market_herbs")
	black_market.AddKeyGood("forbidden_weapons")
	black_market.AddSpecialDeal("Legendary Curved Blade", 3500, "rare")
	black_market.AddSpecialDeal("Dark Poison Vial", 800, "rare")
	all_hubs += black_market

/datum/trade_routes_system/proc/PopulateRoutes()
	/**
	 * Create all story-mode trade routes connecting hubs
	 */
	
	// ROUTE 1: Forest to City - Timber & Herbs Trade
	var/datum/trade_route/forest_city = new(
		ROUTE_FOREST_TO_CITY,
		"Forest to City Route",
		"Forest Druid Circle",
		"Central Market City",
		300,  // 300 ticks travel time
		1200  // Caravan every 1200 ticks
	)
	forest_city.AddGood("timber", 50)
	forest_city.AddGood("healing_herb", 30)
	forest_city.AddGood("rare_plant", 15)
	forest_city.description = "Daily timber and herb caravans leave the forest for city markets. " + \
		"Watch the druid merchants in their green cloaks hauling lumber and medicine."
	all_routes += forest_city
	
	// ROUTE 2: City to Coast - Food & Tools Trade
	var/datum/trade_route/city_coast = new(
		ROUTE_CITY_TO_COAST,
		"City to Coast Route",
		"Central Market City",
		"Port Merchant Guild",
		250,
		1200
	)
	city_coast.AddGood("crafting_tools", 40)
	city_coast.AddGood("food_supplies", 60)
	city_coast.AddGood("weapons", 10)
	city_coast.description = "Merchant caravans bring finished goods to the coast for maritime traders. " + \
		"Heavy wagons of tools, food, and weapons depart daily."
	all_routes += city_coast
	
	// ROUTE 3: Coast to Mountains - Fish & Salt for Ore
	var/datum/trade_route/coast_mountain = new(
		ROUTE_COAST_TO_MOUNTAINS,
		"Coast to Mountains Route",
		"Port Merchant Guild",
		"Mountain Smithy Trade Post",
		400,
		1500
	)
	coast_mountain.AddGood("fish", 40)
	coast_mountain.AddGood("sea_salt", 30)
	coast_mountain.AddGood("spice", 20)
	coast_mountain.description = "Seafaring merchants carry coastal delicacies to mountain dwellers. " + \
		"Caravans wind up mountain passes with preserved fish and salt."
	all_routes += coast_mountain
	
	// ROUTE 4: Mountains to Forest - Ore for Processing
	var/datum/trade_route/mountain_forest = new(
		ROUTE_MOUNTAINS_TO_FOREST,
		"Mountains to Forest Route",
		"Mountain Smithy Trade Post",
		"Forest Druid Circle",
		350,
		1500
	)
	mountain_forest.AddGood("iron_ore", 60)
	mountain_forest.AddGood("copper_ore", 40)
	mountain_forest.AddGood("gemstones", 10)
	mountain_forest.description = "Mining caravans transport raw ore from mountains to forest craftspeople. " + \
		"Heavy loads of stone and metal rumble down mountain trails."
	all_routes += mountain_forest
	
	// ROUTE 5: City Center Local Routes - Interconnecting hubs
	var/datum/trade_route/city_loop = new(
		ROUTE_CITY_CENTER_LOOP,
		"City Center Distribution Loop",
		"Central Market City",
		"Central Market City",  // Loops back to itself
		100,
		600  // Frequent local deliveries
	)
	city_loop.AddGood("general_goods", 100)
	city_loop.AddGood("crafting_tools", 50)
	city_loop.AddGood("food_supplies", 80)
	city_loop.description = "Constant stream of local delivery carts and messengers. " + \
		"Goods shift from one district to another throughout the day."
	all_routes += city_loop

/datum/trade_routes_system/proc/ShowTradingHubsMap(mob/player)
	/**
	 * Display map of all trading hubs and routes
	 */
	
	if(!ismob(player))
		return
	
	var/output = "<html><head><title>Kingdom Trade Network</title></head><body>"
	output += "<h1>KINGDOM OF FREEDOM: TRADE NETWORK</h1><hr>"
	output += "<i>Map of major merchant hubs and caravan routes</i><br><br>"
	
	output += "<b>Trading Hubs</b><br>"
	output += "Five major merchant hubs control commerce throughout the kingdom:<br><br>"
	
	for(var/datum/trade_hub/hub in all_hubs)
		output += "<a href='?trade_hub=[hub.name]'><b>[hub.name]</b></a><br>"
		output += "Location: [hub.location]<br>"
		output += "Faction: [hub.faction]<br>"
		output += "[hub.description]<br><br>"
	
	output += "<hr><b>Trade Routes</b><br>"
	output += "Five major caravan routes connect the hubs:<br><br>"
	
	for(var/datum/trade_route/route in all_routes)
		output += "<b>[route.name]</b><br>"
		output += route.description + "<br>"
		output += "Next caravan in: " + max(0, route.next_arrival - world.timeofday) + " ticks<br><br>"
	
	output += "<hr><b>Economic Integration</b><br>"
	output += "These trade routes create a living economy:<br>"
	output += "- Caravans deliver goods on schedule<br>"
	output += "- Merchants travel between hubs<br>"
	output += "- Supply affects prices dynamically<br>"
	output += "- Players can trade with merchants at any hub<br>"
	output += "- Completing trade quests unlocks unique deals<br><br>"
	
	output += "</body></html>"
	player << output

/datum/trade_routes_system/proc/ShowHubDetails(mob/player, hub_name)
	/**
	 * Display detailed information about a specific hub
	 */
	
	if(!ismob(player))
		return
	
	var/datum/trade_hub/hub = null
	for(var/datum/trade_hub/h in all_hubs)
		if(h.name == hub_name)
			hub = h
			break
	
	if(!hub)
		player << "Hub not found."
		return
	
	var/output = "<html><head><title>[hub.name]</title></head><body>"
	output += "<h2>[hub.name]</h2>"
	output += "<i>Faction: [hub.faction]</i><br>"
	output += "<i>Location: [hub.location]</i><br><hr>"
	
	output += hub.description + "<br><br>"
	
	output += "<b>Primary Goods:</b><br>"
	for(var/good in hub.key_goods)
		output += "- " + good + "<br>"
	
	if(length(hub.special_deals) > 0)
		output += "<br><b>Exclusive Deals:</b><br>"
		for(var/item in hub.special_deals)
			var/deal = hub.special_deals[item]
			output += "- " + item + " (" + deal["price"] + " Lucre, " + deal["rarity"] + ")<br>"
	
	output += "<br><b>Connected Routes:</b><br>"
	for(var/datum/trade_route/route in all_routes)
		if(route.origin_hub == hub.name || route.destination_hub == hub.name)
			output += "- " + route.name + "<br>"
	
	output += "<hr>"
	output += "<a href='?trade_network'>BACK TO NETWORK MAP</a>"
	output += "</body></html>"
	player << output

/datum/trade_routes_system/proc/ShowTradeQuests(mob/player)
	/**
	 * Display available trade-related quests
	 */
	
	if(!ismob(player))
		return
	
	var/output = "<html><head><title>Trade Quests</title></head><body>"
	output += "<h1>MERCHANT GUILD QUESTS</h1><hr>"
	output += "Complete these quests to unlock exclusive trade deals<br><br>"
	
	output += "<b>Quest 1: Port Delivery Service</b><br>"
	output += "Deliver spice from Port Merchant Guild to Central Market City.<br>"
	output += "Reward: 200 Lucre, access to port's exclusive goods<br>"
	output += "Level: 1-5<br><br>"
	
	output += "<b>Quest 2: Mountain Trade Alliance</b><br>"
	output += "Establish trade agreement: deliver ore from mountains to forest druids.<br>"
	output += "Reward: 500 Lucre, 50% discount on ore purchases<br>"
	output += "Level: 3-5<br><br>"
	
	output += "<b>Quest 3: Emergency Supplies</b><br>"
	output += "Intercept damaged caravan and deliver goods to destination on time.<br>"
	output += "Reward: 300 Lucre, merchant faction reputation boost<br>"
	output += "Level: 2-4<br><br>"
	
	output += "<b>Quest 4: Caravan Defense</b><br>"
	output += "Protect merchant caravan from bandits on dangerous route.<br>"
	output += "Reward: 600 Lucre, sword of the Merchant Guard (rare)<br>"
	output += "Level: 4-5<br><br>"
	
	output += "<b>Quest 5: Black Market Infiltration</b><br>"
	output += "Gain trust of black market traders and access underground network.<br>"
	output += "Reward: 1000 Lucre, access to forbidden items<br>"
	output += "Level: 5 (Dangerous)<br><br>"
	
	output += "</body></html>"
	player << output

// Global instance
var/datum/trade_routes_system/trade_system = null

/proc/InitializeTradeRoutes()
	if(trade_system)
		return trade_system
	trade_system = new /datum/trade_routes_system()
	return trade_system

/proc/GetTradeRoutes()
	if(!trade_system)
		InitializeTradeRoutes()
	return trade_system
