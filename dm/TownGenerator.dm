/**
 * TOWN GENERATOR - Phase B Implementation
 * 
 * Procedurally generates towns and settlements across the story world.
 * Integrates with WorldSystem to place towns in specific kingdoms.
 * Handles town types, NPC placement, and persistent town data.
 * 
 * Key Features:
 * - 4 town types: Hub (kingdom capitals), Settlement, Outpost, Ruin
 * - Kingdom-specific town generation based on biome
 * - NPC auto-placement based on role and building type
 * - Procedural building layout
 * - Town persistence via savefile
 * - Story anchor integration (5 kingdom hubs + Port Town)
 * 
 * Integration Points:
 * - Triggered during world generation (mapgen/backend.dm)
 * - Uses WorldSystem continent/kingdom data
 * - Stores town data in `towns` global list
 * - Saves/loads via TownData.sav
 */

// ============================================================================
// TOWN TYPE DEFINITIONS
// ============================================================================

/town
	var
		// Core town data
		name = "Unnamed Town"
		town_type = "settlement"    // hub, settlement, outpost, ruin
		kingdom = "freedom"         // which kingdom this town belongs to
		world = "story"             // which world (story, sandbox, pvp)
		
		// Geographic data
		x = 0                       // center x coordinate
		y = 0                       // center y coordinate
		z = 1                       // z level
		radius = 5                  // town radius in tiles (will be procedurally varied)
		width = 10
		height = 10
		
		// Town state
		population = 0              // number of NPCs
		prosperity = 50             // 0-100, affects NPC density and building quality
		corruption = 0              // 0-100, increases based on Greed proximity/influence
		discovered = FALSE          // has player found this town?
		visited = FALSE             // has player entered town?
		
		// NPC and building lists
		buildings = list()          // /building objects in this town
		npcs = list()               // /mob/npc objects in town
		resources = list()          // resource nodes (ore, lumber, etc.)
		
		// Faction/story data
		controlled_by = ""          // which faction controls this town (for Greed crater)
		story_anchor = FALSE        // is this a major story location (kingdom hub)?
		has_quest_giver = FALSE     // does this town have faction quests?
		faction_alignment = 0       // -100 to +100, faction reputation requirement to enter
		
		// Procedural generation data
		seed = 0                    // procedural seed for consistent regeneration
		layout_style = "organic"    // organic, grid, clustered, etc.
		primary_biome = "temperate" // what biome generated around this town?

/town/hub
	town_type = "hub"
	prosperity = 80
	population = 20             // hubs have more NPCs
	story_anchor = TRUE
	has_quest_giver = TRUE

/town/settlement
	town_type = "settlement"
	prosperity = 60
	population = 10

/town/outpost
	town_type = "outpost"
	prosperity = 40
	population = 3

/town/ruin
	town_type = "ruin"
	prosperity = 10
	population = 1              // maybe one hermit NPC
	discovered = FALSE          // ruins start undiscovered

// ============================================================================
// BUILDING DEFINITIONS
// ============================================================================

/building
	var
		// Core data
		name = "Building"
		build_purpose = "house"     // house, shop, tavern, temple, guard, forge, library, farm, etc.
		town = null                 // reference to parent /town
		
		// Geographic data
		x = 0
		y = 0
		z = 1
		width = 2
		height = 2
		
		// Building state
		owner_npc = null            // which NPC owns/runs this building?
		purpose_type = "housing"    // housing, commerce, craft, religion, governance, etc.
		quality = 50                // 0-100, affects appearance and function
		
		// NPC occupants
		occupants = list()          // list of /mob/npc in this building
		max_capacity = 4
		
		// Function data
		has_shop = FALSE            // can you buy/sell here?
		has_crafting = FALSE        // can you craft here?
		has_quest = FALSE           // does NPC owner have quest?
		
		seed = 0                    // procedural seed

/building/house
	type = "house"
	width = 2
	height = 2
	build_purpose = "housing"

/building/shop
	build_purpose = "shop"
	width = 3
	height = 3
	build_purpose = "commerce"
	has_shop = TRUE

/building/tavern
	build_purpose = "tavern"
	name = "Tavern"
	width = 3
	height = 3
	build_purpose = "social"
	max_capacity = 6

/building/temple
	build_purpose = "temple"
	name = "Temple"
	width = 3
	height = 3
	build_purpose = "religion"

/building/forge
	build_purpose = "forge"
	name = "Blacksmith's Forge"
	width = 3
	height = 3
	build_purpose = "craft"
	has_crafting = TRUE

/building/library
	build_purpose = "library"
	name = "Library"
	width = 3
	height = 2
	build_purpose = "knowledge"

/building/farm
	build_purpose = "farm"
	width = 4
	height = 4
	build_purpose = "production"

/building/guard_post
	build_purpose = "guard_post"
	name = "Guard Post"
	width = 2
	height = 2
	build_purpose = "defense"

/building/market
	build_purpose = "market"
	name = "Market"
	width = 4
	height = 4
	build_purpose = "commerce"
	has_shop = TRUE
	max_capacity = 8

// ============================================================================
// GLOBAL TOWN MANAGEMENT
// ============================================================================

var
	global/list/towns = list()          // all towns in the world
	global/list/town_cache = list()     // cache of town data by kingdom
	global/list/buildings = list()      // all buildings
	global/town_data_file = "towns.sav" // persistent town data

// ============================================================================
// TOWN GENERATION PROCEDURES
// ============================================================================

/**
 * GenerateAllTowns()
 * 
 * Main entry point for Phase B town generation.
 * Called during world initialization after map generation.
 * 
 * Creates:
 * - 5 kingdom hubs (story anchors)
 * - Port town (on each continent, for travel)
 * - Procedural settlements/outposts scattered across world
 */
proc/GenerateAllTowns()
	if(towns.len > 0)
		return  // already generated
	
	world.log << "Starting Phase B Town Generation..."
	
	// Generate story anchors (kingdom hubs)
	GenerateKingdomHubs()
	
	// Generate port towns for each continent
	GeneratePortTowns()
	
	// Generate procedural settlements
	GenerateProcedralSettlements()
	
	// Generate crater towns (if crater exists)
	GenerateCraterTowns()
	
	world.log << "Phase B Town Generation complete. [towns.len] towns created."
	SaveTownData()

/**
 * GenerateKingdomHubs()
 * 
 * Creates the 5 major kingdom hub towns:
 * 1. City of the Free (Freedom kingdom)
 * 2. Spire of Behist (Belief kingdom)
 * 3. Keep of Honor (Honor kingdom)
 * 4. Castle of Pride (Pride kingdom)
 * 5. Port of Plenty (Greed crater)
 * 
 * These are story anchors - permanent, important locations.
 * Generated at fixed locations relative to their biomes.
 */
proc/GenerateKingdomHubs()
	var/list/hubs = list(
		list(name="City of the Free", kingdom="freedom", x=50, y=50),
		list(name="Spire of Behist", kingdom="belief", x=150, y=150),
		list(name="Keep of Honor", kingdom="honor", x=250, y=50),
		list(name="Castle of Pride", kingdom="pride", x=50, y=250),
		list(name="Port of Plenty", kingdom="greed", x=200, y=200)
	)
	
	for(var/hub_data in hubs)
		var/town/hub/H = new()
		H.name = hub_data["name"]
		H.kingdom = hub_data["kingdom"]
		H.x = hub_data["x"]
		H.y = hub_data["y"]
		H.seed = rand(1, 999999)
		
		GenerateTownBuildings(H)
		towns.Add(H)
		town_cache[H.kingdom] = H
		
		world.log << "Generated hub: [H.name] ([H.kingdom])"

/**
 * GenerateProcedralSettlements()
 * 
 * Scatter 3-5 settlements per kingdom procedurally.
 * Settlement locations based on:
 * - Distance from hub (not too close)
 * - Biome quality (prefer good land)
 * - Previous settlement spacing
 * 
 * Creates mix of settlements and outposts.
 */
proc/GenerateProcedralSettlements()
	for(var/kingdom in list("freedom", "belief", "honor", "pride"))
		var/town/hub/hub = town_cache[kingdom]
		var/settlement_count = rand(3, 5)
		
		for(var/i = 1; i <= settlement_count; i++)
			var/town/settlement/S = new()
			
			// Place settlement near hub but not too close
			var/dist = rand(40, 100)
			var/angle = rand(0, 359)
			S.x = hub.x + dist * cos(angle)
			S.y = hub.y + dist * sin(angle)
			S.seed = rand(1, 999999)
			S.kingdom = kingdom
			S.name = GenerateSettlementName(kingdom)
			
			// 30% chance for outpost instead
			if(prob(30))
				var/town/outpost/O = new()
				O.name = S.name
				O.x = S.x
				O.y = S.y
				O.seed = S.seed
				O.kingdom = kingdom
				GenerateTownBuildings(O)
				towns.Add(O)
			else
				GenerateTownBuildings(S)
				towns.Add(S)

/**
 * GeneratePortTowns()
 * 
 * Creates port towns for travel between continents.
 * One on each continent (Story, Sandbox, PvP).
 * Connected via travel system in Portals.dm
 */
proc/GeneratePortTowns()
	// Story world port
	var/town/settlement/port1 = new()
	port1.name = "Port of Travelers"
	port1.x = 100
	port1.y = 300
	port1.kingdom = "travel"
	port1.world = "story"
	port1.seed = 12345
	GenerateTownBuildings(port1)
	towns.Add(port1)
	
	// Sandbox world port
	var/town/settlement/port2 = new()
	port2.name = "Creative Harbor"
	port2.x = 100
	port2.y = 300
	port2.kingdom = "travel"
	port2.world = "sandbox"
	port2.seed = 54321
	GenerateTownBuildings(port2)
	towns.Add(port2)
	
	// PvP world port
	var/town/settlement/port3 = new()
	port3.name = "Contested Docks"
	port3.x = 100
	port3.y = 300
	port3.kingdom = "travel"
	port3.world = "pvp"
	port3.seed = 11111
	GenerateTownBuildings(port3)
	towns.Add(port3)

/**
 * GenerateCraterTowns()
 * 
 * Special handling for Kingdom of Greed crater region.
 * Creates:
 * - Port of Plenty (main hub, crater rim)
 * - 3-5 faction-controlled settlements
 * - 2-3 hidden rebel hideouts
 * 
 * Crater towns have different rules:
 * - Controlled by specific factions
 * - Have warfare/sabotage mechanics
 * - Dynamically change based on player actions
 */
proc/GenerateCraterTowns()
	// This will be expanded in future phases when faction system is active
	// For now, Port of Plenty is created as part of hub generation
	world.log << "Crater towns will be generated with faction system (Phase C)"

/**
 * GenerateTownBuildings(town)
 * 
 * Creates buildings for a specific town.
 * Building count and types based on:
 * - Town type (hub has more buildings)
 * - Town prosperity
 * - Biome type
 * - Kingdom theme
 * 
 * Parameters:
 *   town (/town) - town to generate buildings for
 */
proc/GenerateTownBuildings(town/T)
	if(!T) return
	
	// Calculate building count based on town type
	var/building_count = 0
	switch(T.town_type)
		if("hub")
			building_count = rand(15, 25)
		if("settlement")
			building_count = rand(8, 12)
		if("outpost")
			building_count = rand(3, 5)
		if("ruin")
			building_count = rand(1, 3)
	
	// Create buildings
	for(var/i = 1; i <= building_count; i++)
		var/building/B = GenerateSingleBuilding(T)
		if(B)
			T.buildings += B
			buildings += B
	
	// Ensure essential buildings exist
	EnsureEssentialBuildingsForTown(T)

/**
 * GenerateSingleBuilding(town)
 * 
 * Creates a single building for a town.
 * Type selected probabilistically based on town prosperity.
 * 
 * Parameters:
 *   town (/town) - parent town
 * 
 * Returns:
 *   /building - newly created building
 */
proc/GenerateSingleBuilding(town/T)
	var/building_type = "house"  // default
	var/rand_val = rand(1, 100)
	
	// Building type distribution based on prosperity
	if(T.prosperity > 80)
		// Well-developed town
		if(rand_val <= 40) building_type = "house"
		else if(rand_val <= 50) building_type = "shop"
		else if(rand_val <= 60) building_type = "forge"
		else if(rand_val <= 70) building_type = "tavern"
		else if(rand_val <= 85) building_type = "farm"
		else building_type = "temple"
	else if(T.prosperity > 50)
		// Moderate town
		if(rand_val <= 50) building_type = "house"
		else if(rand_val <= 70) building_type = "shop"
		else if(rand_val <= 85) building_type = "farm"
		else building_type = "tavern"
	else
		// Poor town (mostly houses)
		if(rand_val <= 80) building_type = "house"
		else if(rand_val <= 90) building_type = "farm"
		else building_type = "shop"
	
	// Create building instance based on type
	var/building/B
	switch(building_type)
		if("house") B = new /building/house()
		if("shop") B = new /building/shop()
		if("tavern") B = new /building/tavern()
		if("temple") B = new /building/temple()
		if("forge") B = new /building/forge()
		if("library") B = new /building/library()
		if("farm") B = new /building/farm()
		if("guard_post") B = new /building/guard_post()
		if("market") B = new /building/market()
		else B = new /building/house()
	
	if(B)
		B.town = T
		B.x = T.x + rand(-T.radius, T.radius)
		B.y = T.y + rand(-T.radius, T.radius)
		B.z = T.z
		B.seed = rand(1, 999999)
		B.quality = T.prosperity + rand(-20, 20)
		B.quality = clamp(B.quality, 10, 100)
	
	return B

/**
 * EnsureEssentialBuildingsForTown(town)
 * 
 * Ensures a town has necessary buildings:
 * - Hub: tavern, temple, forge, library, market, guard post
 * - Settlement: tavern, shop
 * - Outpost: shop (for trading)
 * - Ruin: nothing essential
 */
proc/EnsureEssentialBuildingsForTown(town/T)
	if(!T) return
	
	var/list/required = list()
	
	switch(T.town_type)
		if("hub")
			required = list("tavern", "temple", "forge", "library", "market", "guard_post")
		if("settlement")
			required = list("tavern", "shop")
		if("outpost")
			required = list("shop")
	
	for(var/building_name in required)
		// Check if building already exists
		var/exists = FALSE
		for(var/building/B in T.buildings)
			if(B.type == building_name)
				exists = TRUE
				break
		
		if(!exists)
			// Create missing building of appropriate type
			var/building/B
			switch(building_name)
				if("house") B = new /building/house()
				if("shop") B = new /building/shop()
				if("tavern") B = new /building/tavern()
				if("temple") B = new /building/temple()
				if("forge") B = new /building/forge()
				if("library") B = new /building/library()
				if("farm") B = new /building/farm()
				if("guard_post") B = new /building/guard_post()
				if("market") B = new /building/market()
				else B = new /building/house()
			
			if(B)
				B.town = T
				B.x = T.x + rand(-5, 5)
				B.y = T.y + rand(-5, 5)
				B.z = T.z
				B.seed = rand(1, 999999)
				B.quality = T.prosperity
				T.buildings += B
				buildings += B

/**
 * GenerateSettlementName(kingdom)
 * 
 * Procedurally generates a settlement name based on kingdom theme.
 * Uses name lists from names.txt (if available).
 * 
 * Parameters:
 *   kingdom (text) - which kingdom
 * 
 * Returns:
 *   text - generated settlement name
 */
proc/GenerateSettlementName(kingdom)
	var/list/prefixes = list()
	var/list/suffixes = list()
	
	switch(kingdom)
		if("freedom")
			prefixes = list("Green", "Free", "Wild", "Open", "Great")
			suffixes = list("Vale", "Field", "Meadow", "Glen", "Grove")
		if("belief")
			prefixes = list("Holy", "Sacred", "Wise", "Bright", "Mystic")
			suffixes = list("Haven", "Sanctuary", "Tower", "Hall", "Spire")
		if("honor")
			prefixes = list("Noble", "True", "Valiant", "Pride", "Brave")
			suffixes = list("Hold", "Keep", "Fort", "Bastion", "Guard")
		if("pride")
			prefixes = list("Imperial", "Grand", "Royal", "Mighty", "Glorious")
			suffixes = list("Castle", "Citadel", "Stronghold", "Palace", "Fortress")
		if("greed")
			prefixes = list("Dark", "Corrupt", "Vile", "Foul", "Blighted")
			suffixes = list("Pit", "Abyss", "Crater", "Void", "Wasteland")
	
	if(prefixes.len == 0) prefixes = list("New", "Old", "Small", "Great")
	if(suffixes.len == 0) suffixes = list("Town", "Village", "Settlement", "Outpost")
	
	return pick(prefixes) + " " + pick(suffixes)

// ============================================================================
// TOWN DATA PERSISTENCE
// ============================================================================

/**
 * SaveTownData()
 * 
 * Saves all town data to binary savefile.
 * Called after world generation and periodically during play.
 */
proc/SaveTownData()
	var/savefile/F = new(town_data_file)
	F["towns"] << towns
	F["buildings"] << buildings
	world.log << "Town data saved ([towns.len] towns, [buildings.len] buildings)"

/**
 * LoadTownData()
 * 
 * Loads town data from savefile.
 * Called during world initialization.
 */
proc/LoadTownData()
	if(fexists(town_data_file))
		var/savefile/F = new(town_data_file)
		F["towns"] >> towns
		F["buildings"] >> buildings
		world.log << "Town data loaded ([towns.len] towns, [buildings.len] buildings)"
		return TRUE
	return FALSE

// ============================================================================
// TOWN QUERIES
// ============================================================================

/**
 * GetTownAt(x, y, z)
 * 
 * Find town at given coordinates.
 * Used for checking if player is in town.
 * 
 * Parameters:
 *   x, y, z (num) - coordinates
 * 
 * Returns:
 *   /town or null
 */
proc/GetTownAt(x, y, z)
	for(var/town/T in towns)
		if(T.z != z) continue
		var/dist = sqrt((x - T.x) ** 2 + (y - T.y) ** 2)
		if(dist <= T.radius)
			return T
	return null

/**
 * GetTownsByKingdom(kingdom)
 * 
 * Get all towns in a kingdom.
 * 
 * Parameters:
 *   kingdom (text) - kingdom name
 * 
 * Returns:
 *   list of /town
 */
proc/GetTownsByKingdom(kingdom)
	var/list/result = list()
	for(var/town/T in towns)
		if(T.kingdom == kingdom)
			result.Add(T)
	return result

/**
 * GetRandomTown(kingdom = null)
 * 
 * Get random town, optionally filtered by kingdom.
 * 
 * Parameters:
 *   kingdom (text) - optional kingdom filter
 * 
 * Returns:
 *   /town
 */
proc/GetRandomTown(kingdom = null)
	if(kingdom)
		var/list/k_towns = GetTownsByKingdom(kingdom)
		return pick(k_towns)
	else
		return pick(towns)

// ============================================================================
// TOWN LIFECYCLE
// ============================================================================

/**
 * TownDiscovered(town)
 * 
 * Called when a player discovers a town for first time.
 * Updates town.discovered flag and triggers any discovery events.
 */
proc/TownDiscovered(town/T)
	if(!T || T.discovered) return
	
	T.discovered = TRUE
	world.log << "Town discovered: [T.name]"
	
	// Could trigger discovery notification to all players, etc.
	// BroadcastDiscovery(T)

/**
 * TownVisited(town)
 * 
 * Called when a player enters a town.
 * Updates visited flag, spawns NPCs if needed, etc.
 */
proc/TownVisited(town/T)
	if(!T || T.visited) return
	
	T.visited = TRUE
	
	// Spawn NPCs if not already present
	if(!T.npcs) T.npcs = list()
	if(length(T.npcs) == 0)
		SpawnTownNPCs(T)

/**
 * SpawnTownNPCs(town)
 * 
 * Creates NPC instances for a town's buildings.
 * Called lazily when town is first visited.
 * 
 * NPC types and placement based on building types.
 */
proc/SpawnTownNPCs(town/T)
	if(!T) return
	
	for(var/building/B in T.buildings)
		// Initialize occupants if needed
		if(!B.occupants) B.occupants = list()
		
		// Skip if building already has occupants
		if(B.occupants && length(B.occupants) > 0) continue
		
		// Determine NPC count and type based on building
		var/npc_count = 0
		var/npc_role = "citizen"
		
		switch(B.build_purpose)
			if("shop")
				npc_count = 1
				npc_role = "merchant"
			if("tavern")
				npc_count = 2
				npc_role = "bartender"
			if("forge")
				npc_count = 1
				npc_role = "blacksmith"
			if("temple")
				npc_count = 1
				npc_role = "priest"
			if("library")
				npc_count = 1
				npc_role = "scholar"
			if("farm")
				npc_count = 1
				npc_role = "farmer"
			if("house")
				npc_count = rand(1, 3)
				npc_role = "citizen"
			if("guard_post")
				npc_count = rand(2, 4)
				npc_role = "guard"
		
		// Create NPCs for this building
		for(var/i = 1; i <= npc_count; i++)
			// This will be expanded with full NPC system in Phase C
			// For now, just placeholder
			world.log << "Would spawn [npc_role] NPC in [B.name]"

