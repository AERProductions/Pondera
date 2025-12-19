/**
 * WIKI KNOWLEDGE PORTAL SYSTEM
 * ===========================
 * Comprehensive in-game wiki with all game information
 * Includes: controls, survival mechanics, crafting, sandbox tips, economy, territory, combat, story
 * 
 * Started: 12-11-25 6:30PM
 * Focus: Single searchable knowledge base covering all Pondera mechanics
 */

// Wiki article sections
#define SECTION_CONTROLS "Controls & Interface"
#define SECTION_SURVIVAL "Survival Mechanics"
#define SECTION_CRAFTING "Crafting Guide"
#define SECTION_SANDBOX "Sandbox Tips"
#define SECTION_ECONOMY "Economy Basics"
#define SECTION_TERRITORY "Territory System"
#define SECTION_COMBAT "Combat Tips"
#define SECTION_STORY "Story Mode"

/datum/wiki_article
	var
		key = ""                      // Unique identifier
		title = ""                    // Display title
		section = ""                  // Which section
		content = ""                  // Full article text (HTML-compatible)
		keywords = list()             // Search terms
		related_articles = list()     // Links to related topics
		order = 0                     // Display order within section

/datum/wiki_article/New(key_input, title_input, section_input, content_input)
	key = key_input
	title = title_input
	section = section_input
	content = content_input

/datum/wiki_article/proc/AddKeyword(keyword)
	if(keyword && !(keyword in keywords))
		keywords += lowertext(keyword)

/datum/wiki_article/proc/AddRelated(article_key)
	if(article_key && !(article_key in related_articles))
		related_articles += article_key

/datum/wiki_portal
	var
		list/all_articles = list()    // All wiki articles
		list/search_results = list()  // Current search results
		list/section_filter = list()  // Filter by section
		
		search_text = ""              // Current search string
		current_article = null        // Currently viewing article
		page = 1                      // Pagination
		page_size = 15                // Articles per page

/datum/wiki_portal/New()
	PopulateWiki()

/datum/wiki_portal/proc/PopulateWiki()
	/**
	 * Build complete in-game wiki with all game information
	 */
	
	// === SECTION 1: CONTROLS & INTERFACE ===
	
	var/datum/wiki_article/controls_basics = new("controls_basics", "Basic Controls", SECTION_CONTROLS, \
		"<b>Movement</b><br>" + \
		"Use ARROW KEYS or WASD to move in cardinal directions.<br>" + \
		"Double-tap the same direction within 3 ticks to SPRINT (holds until released).<br><br>" + \
		"<b>Camera & View</b><br>" + \
		"The screen follows your character automatically.<br>" + \
		"Elevation changes affect visibility (higher = can see below).<br><br>" + \
		"<b>Basic Interaction</b><br>" + \
		"Left-click items on the ground to pick them up.<br>" + \
		"Right-click objects to interact with them (talk to NPCs, activate doors, etc).<br>" + \
		"Click inventory items to equip or use them.")
	controls_basics.AddKeyword("movement")
	controls_basics.AddKeyword("sprint")
	controls_basics.AddKeyword("camera")
	all_articles += controls_basics
	
	var/datum/wiki_article/interface_hud = new("interface_hud", "HUD & Interface", SECTION_CONTROLS, \
		"<b>Top-Left Corner: Status Bar</b><br>" + \
		"Shows your name, HP, stamina level.<br>" + \
		"Red bar = health, Blue bar = stamina.<br><br>" + \
		"<b>Bottom-Left: Inventory</b><br>" + \
		"Click items to equip weapons/armor or use consumables.<br>" + \
		"Right-click to drop items.<br>" + \
		"Inventory can hold up to 20 items.<br><br>" + \
		"<b>Top-Right: Time Display</b><br>" + \
		"Shows current time, season, temperature.<br>" + \
		"Weather conditions display here.<br><br>" + \
		"<b>Center Screen: Game Info</b><br>" + \
		"Hover messages appear when near interactive objects.<br>" + \
		"Combat log shows damage dealt and received.")
	interface_hud.AddKeyword("hud")
	interface_hud.AddKeyword("inventory")
	interface_hud.AddKeyword("status bar")
	all_articles += interface_hud
	
	var/datum/wiki_article/menu_navigation = new("menu_nav", "Menus & Navigation", SECTION_CONTROLS, \
		"<b>Escape Key</b><br>" + \
		"Opens main menu with character, equipment, stats screens.<br><br>" + \
		"<b>Character Tab</b><br>" + \
		"View your ranks (fishing, crafting, mining, smithing, etc).<br>" + \
		"Each rank from 1-5, shows experience toward next level.<br><br>" + \
		"<b>Equipment Tab</b><br>" + \
		"View equipped armor and weapons.<br>" + \
		"Shows armor class (AC) and damage values.<br><br>" + \
		"<b>Map (M Key)</b><br>" + \
		"Shows explored areas and current location.<br>" + \
		"Fog of war reveals as you explore.<br><br>" + \
		"<b>Wiki (F1 Key)</b><br>" + \
		"Opens this knowledge base.")
	menu_navigation.AddKeyword("menu")
	menu_navigation.AddKeyword("character")
	menu_navigation.AddKeyword("equipment")
	menu_navigation.AddKeyword("map")
	all_articles += menu_navigation
	
	// === SECTION 2: SURVIVAL MECHANICS ===
	
	var/datum/wiki_article/hunger_thirst = new("hunger_thirst", "Hunger & Thirst", SECTION_SURVIVAL, \
		"<b>Hunger System</b><br>" + \
		"Your hunger increases every 15-30 ticks depending on activity and temperature.<br>" + \
		"When hungry, your stamina regeneration slows down.<br>" + \
		"Extreme hunger leads to starvation and death.<br><br>" + \
		"<b>Eating Food</b><br>" + \
		"Click a food item in inventory to eat it.<br>" + \
		"Each food restores different amounts of hunger (0-100 scale).<br>" + \
		"High-quality food (crafted with skill) restores more.<br><br>" + \
		"<b>Thirst System</b><br>" + \
		"Thirst also increases over time (affected by temperature and activity).<br>" + \
		"Drink water from rivers/wells or crafted containers.<br>" + \
		"Dehydration reduces movement speed and accuracy.<br><br>" + \
		"<b>Temperature Effects</b><br>" + \
		"Extreme cold/heat increases both hunger and thirst drain.<br>" + \
		"Winter: Wear warm clothes, stay near fires.<br>" + \
		"Summer: Stay in shade, drink more water.")
	hunger_thirst.AddKeyword("hunger")
	hunger_thirst.AddKeyword("thirst")
	hunger_thirst.AddKeyword("food")
	hunger_thirst.AddKeyword("temperature")
	all_articles += hunger_thirst
	
	var/datum/wiki_article/stamina = new("stamina_system", "Stamina & Movement", SECTION_SURVIVAL, \
		"<b>Stamina Bar</b><br>" + \
		"Blue bar in top-left shows current stamina (0-100).<br>" + \
		"Regenerates over time when not acting.<br>" + \
		"Hunger affects regeneration rate (hungry = slower recovery).<br><br>" + \
		"<b>Stamina Costs</b><br>" + \
		"Sprinting: Costs stamina per tick.<br>" + \
		"Combat actions: Heavy attacks drain more stamina.<br>" + \
		"Climbing elevation: Takes stamina to move up.<br>" + \
		"Low stamina reduces movement speed by 20-50%.<br><br>" + \
		"<b>Critical Low Stamina</b><br>" + \
		"Below 10 stamina: Cannot sprint.<br>" + \
		"Below 5 stamina: Severe movement penalty, cannot attack.<br>" + \
		"Rest by standing still and eating food to recover quickly.")
	stamina.AddKeyword("stamina")
	stamina.AddKeyword("movement speed")
	stamina.AddKeyword("sprint")
	all_articles += stamina
	
	var/datum/wiki_article/temperature = new("temperature_system", "Temperature & Weather", SECTION_SURVIVAL, \
		"<b>Temperature Meter</b><br>" + \
		"Displayed top-right next to time.<br>" + \
		"Measured in Fahrenheit (-50°F to 120°F range).<br>" + \
		"Affects hunger drain, combat accuracy, movement speed.<br><br>" + \
		"<b>Cold Effects (Below 32°F)</b><br>" + \
		"Movement speed reduced by 10%.<br>" + \
		"Hunger increases faster.<br>" + \
		"Wear wool armor or stand near fires to warm up.<br><br>" + \
		"<b>Heat Effects (Above 95°F)</b><br>" + \
		"Stamina regeneration reduced.<br>" + \
		"Thirst increases much faster.<br>" + \
		"Drink water frequently, wear light clothing, seek shade.<br><br>" + \
		"<b>Weather Types</b><br>" + \
		"Clear: No effects.<br>" + \
		"Rain: -20% ranged accuracy, slight cold.<br>" + \
		"Snow: -10% movement, very cold.<br>" + \
		"Blizzard: -50% visibility, severe cold, extremely dangerous.")
	temperature.AddKeyword("weather")
	temperature.AddKeyword("cold")
	temperature.AddKeyword("heat")
	temperature.AddKeyword("temperature")
	all_articles += temperature
	
	// === SECTION 3: CRAFTING GUIDE ===
	
	var/datum/wiki_article/crafting_basics = new("crafting_basics", "Crafting Fundamentals", SECTION_CRAFTING, \
		"<b>What is Crafting?</b><br>" + \
		"Crafting transforms raw materials into useful tools, weapons, and structures.<br>" + \
		"Most recipes require a specific workstation (fire, forge, anvil, etc).<br><br>" + \
		"<b>How to Craft</b><br>" + \
		"1. Gather required ingredients.<br>" + \
		"2. Go to required workstation (or use inventory-only recipes).<br>" + \
		"3. Open the recipe menu at the workstation.<br>" + \
		"4. Select recipe and click Craft.<br>" + \
		"5. Crafting takes time; you can cancel anytime.<br><br>" + \
		"<b>Skill Levels Matter</b><br>" + \
		"Your rank in crafting/smithing/building/etc affects output quality.<br>" + \
		"Higher ranks: Faster crafting, higher-quality items, less material waste.<br>" + \
		"Level 1 = basic items, Level 5 = legendary weapons.")
	crafting_basics.AddKeyword("crafting")
	crafting_basics.AddKeyword("recipe")
	crafting_basics.AddKeyword("workstation")
	all_articles += crafting_basics
	
	var/datum/wiki_article/recipe_discovery = new("recipe_discovery", "Learning & Discovering Recipes", SECTION_CRAFTING, \
		"<b>Recipe Discovery Methods</b><br>" + \
		"1. NPCs teach you recipes via dialogue.<br>" + \
		"2. Inspect items to learn how they're made.<br>" + \
		"3. Read the Tech Tree to see progression paths.<br>" + \
		"4. Experiment: Try assembling items together.<br><br>" + \
		"<b>Tech Tree System</b><br>" + \
		"Press F2 to open the Tech Tree.<br>" + \
		"Shows what ingredients/steps lead to each recipe.<br>" + \
		"Prerequisite recipes are shown in order.<br>" + \
		"Follow the chain: Rock → Stone Hammer → Iron Hammer → Forge.<br><br>" + \
		"<b>Rank Requirements</b><br>" + \
		"Some recipes locked until you reach required skill level.<br>" + \
		"Example: Steel Sword requires Smithing rank 3.<br>" + \
		"As you craft, your rank increases and new recipes unlock.")
	recipe_discovery.AddKeyword("recipe discovery")
	recipe_discovery.AddKeyword("tech tree")
	recipe_discovery.AddKeyword("learning")
	all_articles += recipe_discovery
	
	var/datum/wiki_article/quality_system = new("quality_system", "Crafting Quality & Materials", SECTION_CRAFTING, \
		"<b>Item Quality</b><br>" + \
		"Higher-quality items are more effective and valuable.<br>" + \
		"Quality affected by: Skill level (50%), ingredient quality (30%), luck (20%).<br>" + \
		"Quality tiers: Poor (red) → Common (white) → Uncommon (green) → Rare (blue) → Legendary (gold).<br><br>" + \
		"<b>Material Refinement</b><br>" + \
		"Some materials can be refined to higher grades:<br>" + \
		"Iron Ore → Iron Ingot (smelt in forge).<br>" + \
		"Iron Ingot + Carbon → Steel Ingot (higher-tier smelting).<br>" + \
		"Steel + Activated Carbon → Damascus Steel (legendary!).<br><br>" + \
		"<b>Where to Find Materials</b><br>" + \
		"Mine: Ore, stone, gems from rocky areas.<br>" + \
		"Harvest: Wood, plants, fiber from forests and fields.<br>" + \
		"Fish: Protein and oils from water.<br>" + \
		"Hunt: Leather, meat, bones from animals.")
	quality_system.AddKeyword("quality")
	quality_system.AddKeyword("materials")
	quality_system.AddKeyword("refinement")
	all_articles += quality_system
	
	// === SECTION 4: SANDBOX TIPS ===
	
	var/datum/wiki_article/sandbox_startup = new("sandbox_startup", "Getting Started in Sandbox", SECTION_SANDBOX, \
		"<b>Sandbox Mode Basics</b><br>" + \
		"Sandbox is a peaceful, creative mode with no hunger, no threats, all recipes unlocked.<br>" + \
		"Perfect for learning mechanics, building, and testing ideas.<br><br>" + \
		"<b>First Steps</b><br>" + \
		"1. Gather some rocks and wood (everywhere).<br>" + \
		"2. Craft stone hammer (rock + wooden haunch).<br>" + \
		"3. Craft iron hammer to unlock building.<br>" + \
		"4. Build a house and furnish it.<br>" + \
		"5. Build a forge to unlock metalworking.<br><br>" + \
		"<b>Home Base Setup</b><br>" + \
		"Find a nice flat area near water (for farming/fishing).<br>" + \
		"Build house → forge → anvil → storage chests.<br>" + \
		"Make a 5x5 fenced garden for crops.<br>" + \
		"Set spawn point with compass (respawn here if you die).")
	sandbox_startup.AddKeyword("sandbox")
	sandbox_startup.AddKeyword("getting started")
	sandbox_startup.AddKeyword("home base")
	all_articles += sandbox_startup
	
	var/datum/wiki_article/sandbox_building = new("sandbox_building", "Building & Construction Tips", SECTION_SANDBOX, \
		"<b>Building Progression</b><br>" + \
		"Wood House (cheapest) → Stone House (fireproof) → Castle (ultimate).<br>" + \
		"Each tier looks better and offers more protection.<br><br>" + \
		"<b>Essential Structures</b><br>" + \
		"Furnace/Kiln: Smelt ores into ingots (fires/heating).<br>" + \
		"Forge: Create metal tools and weapons.<br>" + \
		"Anvil: Refine and combine metal items.<br>" + \
		"Chests: Store items (can place multiple for organization).<br>" + \
		"Bed: Set spawn point, rest to recover stamina fast.<br>" + \
		"Lighthouse: Illuminate large area at night.<br><br>" + \
		"<b>Layout Tips</b><br>" + \
		"Keep furnace/forge/anvil close together for efficiency.<br>" + \
		"Put storage near entrance for quick access.<br>" + \
		"Put beds in separate room for organization.<br>" + \
		"Keep gardens away from structures (needs sunlight).")
	sandbox_building.AddKeyword("building")
	sandbox_building.AddKeyword("structures")
	sandbox_building.AddKeyword("construction")
	all_articles += sandbox_building
	
	// === SECTION 5: ECONOMY BASICS ===
	
	var/datum/wiki_article/currency_system = new("currency_system", "Currencies & Trading", SECTION_ECONOMY, \
		"<b>Two Currency Types</b><br>" + \
		"<i>Lucre</i> (Story Mode): Non-tradable quest rewards, NPC merchant currency.<br>" + \
		"<i>Materials</i> (PvP Mode): Stone, metal, timber traded between kingdoms.<br><br>" + \
		"<b>Earning Currency</b><br>" + \
		"Complete quests → earn Lucre from quest givers.<br>" + \
		"Gather resources → sell to merchants for Lucre or materials.<br>" + \
		"Craft high-quality items → more valuable when sold.<br>" + \
		"Control territory → access to rare materials and NPC trade discounts.<br><br>" + \
		"<b>Trading with NPCs</b><br>" + \
		"Talk to merchants and select 'Buy' or 'Sell'.<br>" + \
		"Prices vary by supply/demand and territory control.<br>" + \
		"Higher supply = lower prices. Scarce items = expensive.")
	currency_system.AddKeyword("currency")
	currency_system.AddKeyword("lucre")
	currency_system.AddKeyword("trading")
	currency_system.AddKeyword("merchant")
	all_articles += currency_system
	
	var/datum/wiki_article/market_system = new("market_system", "Market Pricing & Economy", SECTION_ECONOMY, \
		"<b>Dynamic Pricing</b><br>" + \
		"Item prices change based on supply and demand in real-time.<br>" + \
		"Many players buying ore? → ore prices increase.<br>" + \
		"Lots of stone being sold? → stone prices decrease.<br><br>" + \
		"<b>Territory Control Impact</b><br>" + \
		"Control a forest territory? → wood prices are cheap for you, expensive for others.<br>" + \
		"Own stone mines? → stone is abundant and affordable.<br>" + \
		"Blockade a trade route? → targeted materials become scarce and expensive.<br><br>" + \
		"<b>Smart Trading</b><br>" + \
		"Buy low-priced items and wait for prices to spike before selling.<br>" + \
		"Control resource territories for consistent income.<br>" + \
		"Craft items with high profit margins (cheap ingredients → expensive weapon).")
	market_system.AddKeyword("market")
	market_system.AddKeyword("economy")
	market_system.AddKeyword("pricing")
	all_articles += market_system
	
	// === SECTION 6: TERRITORY SYSTEM ===
	
	var/datum/wiki_article/territory_basics = new("territory_basics", "Territory & Deeds", SECTION_TERRITORY, \
		"<b>What is Territory?</b><br>" + \
		"Claiming a deed gives you control of a large region.<br>" + \
		"You can build, prevent others from building, and control resources.<br><br>" + \
		"<b>Deed Tiers</b><br>" + \
		"Small Deed: 1000 turfs, 100 Lucre/month maintenance.<br>" + \
		"Medium Deed: 2000 turfs, 250 Lucre/month maintenance.<br>" + \
		"Large Deed: 8000 turfs, 500 Lucre/month maintenance.<br><br>" + \
		"<b>Claiming Territory</b><br>" + \
		"Go to unclaimed land and use the Claim Deed verb.<br>" + \
		"Select tier and pay upfront cost.<br>" + \
		"Territory is now yours! (must pay monthly maintenance or lose it).<br><br>" + \
		"<b>Managing Your Deed</b><br>" + \
		"Open deed menu to see expiration date and balance.<br>" + \
		"Pay maintenance before expiration or territory unfreezes (others can build).<br>" + \
		"You can grant building permissions to faction members.")
	territory_basics.AddKeyword("deed")
	territory_basics.AddKeyword("territory")
	territory_basics.AddKeyword("claiming")
	all_articles += territory_basics
	
	var/datum/wiki_article/deed_permissions = new("deed_perms", "Deed Permissions & Control", SECTION_TERRITORY, \
		"<b>Permission Types</b><br>" + \
		"Build: Place structures and furniture.<br>" + \
		"Pickup: Take items from the ground.<br>" + \
		"Drop: Place items on the ground.<br><br>" + \
		"<b>Default Permissions (Your Deed)</b><br>" + \
		"You can always build, pickup, drop anywhere in your deed.<br>" + \
		"Faction members: Check deed settings for their permissions.<br>" + \
		"Enemies/Neutrals: Cannot build or pickup (depends on settings).<br><br>" + \
		"<b>Deed Settings</b><br>" + \
		"Private: Only owner can build.<br>" + \
		"Faction: Owner + faction members can build.<br>" + \
		"Public: Anyone can build (risky!).<br><br>" + \
		"<b>Deed Freeze System</b><br>" + \
		"If you miss maintenance payment, deed FREEZES for 24 hours.<br>" + \
		"During freeze, others can build in your territory.<br>" + \
		"Pay within 24 hours to thaw and restore exclusivity.")
	deed_permissions.AddKeyword("permissions")
	deed_permissions.AddKeyword("building")
	deed_permissions.AddKeyword("faction")
	all_articles += deed_permissions
	
	// === SECTION 7: COMBAT TIPS ===
	
	var/datum/wiki_article/combat_basics = new("combat_basics", "Basic Combat", SECTION_COMBAT, \
		"<b>Initiating Combat</b><br>" + \
		"Click an enemy to attack them.<br>" + \
		"Combat continues automatically until one of you dies or flees.<br>" + \
		"You auto-attack with equipped weapon.<br><br>" + \
		"<b>Damage & Accuracy</b><br>" + \
		"Weapon damage depends on: weapon type, quality, your strength stat.<br>" + \
		"Accuracy affected by: your agility, enemy armor, weather, elevation difference.<br>" + \
		"High armor (AC) reduces incoming damage by percentage.<br><br>" + \
		"<b>Combat Actions</b><br>" + \
		"Move away: Step back to increase distance (ranged advantage).<br>" + \
		"Dodge: Some weapons grant dodge chance (evasion armor helps).<br>" + \
		"Block: Shields reduce damage taken.<br>" + \
		"Flee: Run away and out of range to escape.")
	combat_basics.AddKeyword("combat")
	combat_basics.AddKeyword("fighting")
	combat_basics.AddKeyword("damage")
	all_articles += combat_basics
	
	var/datum/wiki_article/equipment_combat = new("equipment_combat", "Equipment & Armor", SECTION_COMBAT, \
		"<b>Weapon Types</b><br>" + \
		"Melee (swords, axes, hammers): Medium range, high damage.<br>" + \
		"Ranged (bows): Long range, lower damage, affected by wind.<br>" + \
		"Two-handed: Very high damage, slower attack speed.<br><br>" + \
		"<b>Armor Classes</b><br>" + \
		"Light (leather): Low AC, high mobility, good evasion.<br>" + \
		"Medium (iron): Balanced AC and mobility.<br>" + \
		"Heavy (steel): High AC, slower movement, great defense.<br><br>" + \
		"<b>Equipping Items</b><br>" + \
		"Open inventory (bottom-left).<br>" + \
		"Click weapon to equip (shows on character).<br>" + \
		"Click armor piece to wear (layers show visually).<br>" + \
		"Stats update immediately (check top-left status).<br><br>" + \
		"<b>Equipment Slots</b><br>" + \
		"Head, chest, hands, feet, back, waist, accessories.<br>" + \
		"Each slot holds one item (or matching pair for gloves/boots).")
	equipment_combat.AddKeyword("equipment")
	equipment_combat.AddKeyword("armor")
	equipment_combat.AddKeyword("weapons")
	all_articles += equipment_combat
	
	var/datum/wiki_article/weather_combat = new("weather_combat", "Weather & Combat Effects", SECTION_COMBAT, \
		"<b>Rain Effects</b><br>" + \
		"Reduces ranged accuracy by 20%.<br>" + \
		"Slight cold temperature effect.<br>" + \
		"Visibility not greatly reduced.<br><br>" + \
		"<b>Snow/Blizzard</b><br>" + \
		"Heavy snow reduces visibility drastically.<br>" + \
		"Accuracy penalties for both melee and ranged.<br>" + \
		"Movement speed reduced 10-50%.<br>" + \
		"Extreme danger in blizzards (can't see enemies).<br><br>" + \
		"<b>Wind Effects</b><br>" + \
		"Affects projectile trajectories.<br>" + \
		"Strong wind deflects arrows 15-30 degrees.<br>" + \
		"Ranged combat requires leading shots more in windy weather.<br><br>" + \
		"<b>Temperature in Combat</b><br>" + \
		"Extreme cold: -20% damage, slower movement.<br>" + \
		"Extreme heat: +40% stamina drain, slower stamina regen.")
	weather_combat.AddKeyword("weather")
	weather_combat.AddKeyword("rain")
	weather_combat.AddKeyword("blizzard")
	all_articles += weather_combat
	
	// === SECTION 8: STORY MODE ===
	
	var/datum/wiki_article/story_overview = new("story_overview", "Story Mode Overview", SECTION_STORY, \
		"<b>Kingdom of Freedom Setting</b><br>" + \
		"Story mode is a narrative-driven world with NPC towns, quests, and progression.<br>" + \
		"Discover the lore of the Kingdom, uncover mysteries, face challenges.<br><br>" + \
		"<b>Game Progression</b><br>" + \
		"Early game: Gather resources, craft basic tools, meet NPCs.<br>" + \
		"Mid game: Complete faction quests, build settlements, explore territories.<br>" + \
		"Late game: Rise to power, influence factions, shape the world.<br><br>" + \
		"<b>Questgivers</b><br>" + \
		"NPCs marked with yellow ! offer quests.<br>" + \
		"Talk to them and select which quest to accept.<br>" + \
		"Complete objectives and return for rewards (Lucre, items, lore).<br><br>" + \
		"<b>NPC Factions</b><br>" + \
		"Kingdom of Greed: Merchant faction (profit-focused).<br>" + \
		"Ironforge Council: Smithing faction (crafting-focused).<br>" + \
		"Druid Circle: Nature faction (balance-focused).")
	story_overview.AddKeyword("story")
	story_overview.AddKeyword("quest")
	story_overview.AddKeyword("npc")
	all_articles += story_overview
	
	var/datum/wiki_article/npc_interaction = new("npc_interaction", "Interacting with NPCs", SECTION_STORY, \
		"<b>Talking to NPCs</b><br>" + \
		"Right-click any NPC to open dialogue menu.<br>" + \
		"Select dialogue options to learn about quests, lore, recipes.<br><br>" + \
		"<b>Teaching & Learning</b><br>" + \
		"Some NPCs teach recipes (blacksmiths teach smithing recipes).<br>" + \
		"Learning from NPCs: Talk → Choose 'Learn Recipe' → Recipe unlocked.<br>" + \
		"Can learn multiple recipes from same NPC.<br><br>" + \
		"<b>Trading with Merchants</b><br>" + \
		"Merchants buy and sell items.<br>" + \
		"Prices vary by season, supply, and relationship level.<br>" + \
		"Build relationship by trading fairly and completing quests.<br><br>" + \
		"<b>NPC Schedules</b><br>" + \
		"NPCs have daily schedules (move around, work, rest).<br>" + \
		"Find them in their usual places during the day.<br>" + \
		"Night: NPCs return to homes/inns to sleep.")
	npc_interaction.AddKeyword("npc")
	npc_interaction.AddKeyword("dialogue")
	npc_interaction.AddKeyword("learning")
	all_articles += npc_interaction

/datum/wiki_portal/proc/Search(search_string, mob/player)
	/**
	 * Search wiki by keywords and article content
	 */
	
	search_text = search_string
	search_results = list()
	page = 1
	
	if(!search_string || search_string == "")
		// No search - show all
		search_results = all_articles.Copy()
	else
		// Search articles
		var/search_lower = lowertext(search_string)
		
		for(var/datum/wiki_article/article in all_articles)
			// Check title
			if(findtext(lowertext(article.title), search_lower))
				search_results += article
				continue
			
			// Check keywords
			for(var/keyword in article.keywords)
				if(findtext(keyword, search_lower))
					search_results += article
					break
			
			// Check content
			if(findtext(lowertext(article.content), search_lower))
				search_results += article
	
	return search_results

/datum/wiki_portal/proc/ShowIndex(mob/player)
	/**
	 * Display wiki index organized by sections
	 */
	
	if(!ismob(player))
		return
	
	var/output = "<html><head><title>Pondera Wiki</title></head><body>"
	output += "<h1>PONDERA KNOWLEDGE BASE</h1><hr>"
	output += "<i>Press F1 anytime to return to this menu</i><br><br>"
	
	// Group articles by section
	var/list/sections = list()
	for(var/datum/wiki_article/article in all_articles)
		if(!(article.section in sections))
			sections[article.section] = list()
		sections[article.section] += article
	
	// Display sections
	for(var/section_name in sections)
		output += "<b>[section_name]</b><br>"
		var/list/articles_in_section = sections[section_name]
		for(var/datum/wiki_article/article in articles_in_section)
			output += "&nbsp;&nbsp;<a href='?wiki_article=[article.key]'>[article.title]</a><br>"
		output += "<br>"
	
	output += "<hr><b>Search Wiki</b><br>"
	output += "Enter search terms: "
	output += "(powered by full-text search)<br><br>"
	
	output += "</body></html>"
	player << output

/datum/wiki_portal/proc/ShowArticle(mob/player, article_key)
	/**
	 * Display a specific wiki article
	 */
	
	if(!ismob(player))
		return
	
	var/datum/wiki_article/article = null
	for(var/datum/wiki_article/a in all_articles)
		if(a.key == article_key)
			article = a
			break
	
	if(!article)
		player << "Article not found."
		return
	
	var/output = "<html><head><title>[article.title]</title></head><body>"
	output += "<h2>[article.title]</h2>"
	output += "<font color='#666'><i>Section: [article.section]</i></font><hr>"
	
	output += article.content
	
	output += "<hr>"
	
	// Related articles
	if(length(article.related_articles) > 0)
		output += "<b>Related Topics:</b><br>"
		for(var/related_key in article.related_articles)
			output += "&nbsp;&nbsp;<a href='?wiki_article=[related_key]'>See [related_key]</a><br>"
		output += "<br>"
	
	output += "<a href='?wiki_index'>BACK TO INDEX</a>"
	output += "</body></html>"
	player << output

/datum/wiki_portal/proc/ShowSearchResults(mob/player)
	/**
	 * Display search results paginated
	 */
	
	if(!ismob(player))
		return
	
	var/start_idx = (page - 1) * page_size + 1
	var/end_idx = min(page * page_size, length(search_results))
	var/total_pages = ceil(length(search_results) / page_size)
	
	var/output = "<html><head><title>Wiki Search: [search_text]</title></head><body>"
	output += "<h2>Search Results: '[search_text]'</h2>"
	output += "<i>[length(search_results)] article(s) found</i> | Page " + page + "/" + total_pages + "<hr>"
	
	for(var/i = start_idx; i <= end_idx; i++)
		var/datum/wiki_article/article = search_results[i]
		if(!article)
			continue
		
		output += "<b><a href='?wiki_article=[article.key]'>[article.title]</a></b><br>"
		output += "<font color='#666'>[article.section]</font><br>"
		output += "..."
		// Show snippet of content
		var/snippet = copytext(article.content, 1, 100)
		snippet = replacetext(snippet, "<br>", " ")
		snippet = replacetext(snippet, "<b>", "")
		snippet = replacetext(snippet, "</b>", "")
		snippet = replacetext(snippet, "<i>", "")
		snippet = replacetext(snippet, "</i>", "")
		output += snippet + "...<br><br>"
	
	output += "<hr>"
	
	if(page > 1)
		output += "<a href='?wiki_search_page=1'>FIRST</a> | "
		output += "<a href='?wiki_search_page=" + (page - 1) + "'>PREV</a> | "
	
	output += " Page " + page + "/" + total_pages + " "
	
	if(page < total_pages)
		output += " | <a href='?wiki_search_page=" + (page + 1) + "'>NEXT</a> | "
		output += "<a href='?wiki_search_page=" + total_pages + "'>LAST</a>"
	
	output += "<br><br>"
	output += "<a href='?wiki_index'>BACK TO INDEX</a>"
	output += "</body></html>"
	player << output

// Global instance
var/datum/wiki_portal/wiki_system = null

/proc/InitializeWiki()
	if(wiki_system)
		return wiki_system
	wiki_system = new /datum/wiki_portal()
	return wiki_system

/proc/GetWiki()
	if(!wiki_system)
		InitializeWiki()
	return wiki_system

// Hotkey integration - F1 opens wiki
/mob/players/verb/OpenWiki()
	set name = "Wiki"
	set hidden = 1
	var/datum/wiki_portal/wiki = GetWiki()
	wiki.ShowIndex(src)
