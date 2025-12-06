# Phase B: Procedural Town Generator

**Estimated Duration**: 8-10 hours  
**Objective**: Build procedurally-generated towns for story world with narrative anchors, NPC placement, and connectivity guarantees  
**Status**: READY FOR IMPLEMENTATION  
**Estimated Completion**: Next 2-3 days

---

## Overview

Phase B creates the **town generation system** that places procedurally-varied towns across the story world while maintaining story consistency. Towns serve as:
- Gathering points for NPCs (guilds, services, trading)
- Story waypoints (progression gates, quests)
- Economic hubs (shops, banks, markets)
- Visual landmarks (distinctive architecture per town type)

### What This Phase Delivers
- ✅ Town layout algorithm (buildings, streets, plazas)
- ✅ Multiple town types (hub, settlement, outpost, ruin)
- ✅ Story anchor system (ensuring key NPCs exist)
- ✅ NPC placement framework (roles → locations)
- ✅ Resource spawning (biome-specific goods)
- ✅ Connectivity to main map generator
- ✅ Port town implementation (for ship/portal travel)

### What This Phase Does NOT Include
- ❌ NPC dialogue/interaction (deferred to Phase 7)
- ❌ Quests/story progression (deferred to Phase 6)
- ❌ Player housing (deferred to Phase 4/Sandbox)
- ❌ Dynamic events (deferred to Phase 8)

---

## Phase B Task Breakdown

### Task 1: Town Type Definitions (1-1.5 hours)

#### 1.1: Create Town Type Datum

**File**: `dm/TownGenerator.dm` (NEW - 400 lines)

```dm
/datum/town_type
	var
		name = ""               // "Hub", "Settlement", "Outpost", "Ruin"
		id = ""                 // "hub", "settlement", "outpost", "ruin"
		desc = ""               // Description
		size_range = list(30, 50)  // Width/height range in turfs
		building_density = 0.3  // 0.1 = sparse, 0.5 = dense
		
		// Building types this town spawns
		required_buildings = list()  // Always include (e.g., inn, bank)
		optional_buildings = list()  // Randomly include
		
		// Resources specific to town type
		resource_table = list()     // Biome resources to spawn
		
		// Population parameters
		npc_count_min = 5
		npc_count_max = 15
		npc_roles = list()          // Available roles (blacksmith, healer, etc.)
		
		// Visual/architectural style
		building_style = ""         // "stone", "wood", "mixed"
		street_pattern = ""         // "grid", "organic", "radial"
		has_walls = 0               // Defensive walls?
		has_market = 1              // Merchant stalls?
		has_tavern = 1              // Tavern/inn?
		has_temple = 0              // Religious building?

// Town Type Library
/proc/InitializeTownTypes()
	var/list/town_types = list()
	
	// Hub Town: Story waypoint, trading center, diverse NPCs
	var/datum/town_type/hub = new()
	hub.name = "Hub"
	hub.id = "hub"
	hub.desc = "A major settlement serving as story waypoint"
	hub.size_range = list(40, 60)
	hub.building_density = 0.4
	hub.required_buildings = list("inn", "blacksmith", "bank", "market_hall")
	hub.optional_buildings = list("tavern", "healer", "library", "warehouse")
	hub.npc_count_min = 10
	hub.npc_count_max = 20
	hub.npc_roles = list("blacksmith", "healer", "innkeeper", "banker", "guard_captain", "merchant")
	hub.building_style = "stone"
	hub.street_pattern = "grid"
	hub.has_walls = 1
	hub.has_market = 1
	hub.has_tavern = 1
	town_types["hub"] = hub
	
	// Settlement: Mid-size, mixed resources, craftspeople
	var/datum/town_type/settlement = new()
	settlement.name = "Settlement"
	settlement.id = "settlement"
	settlement.desc = "A farming/crafting community"
	settlement.size_range = list(25, 40)
	settlement.building_density = 0.3
	settlement.required_buildings = list("inn")
	settlement.optional_buildings = list("blacksmith", "healer", "market", "warehouse")
	settlement.npc_count_min = 5
	settlement.npc_count_max = 12
	settlement.npc_roles = list("craftsperson", "farmer", "innkeeper", "merchant")
	settlement.building_style = "wood"
	settlement.street_pattern = "organic"
	settlement.has_market = 1
	town_types["settlement"] = settlement
	
	// Outpost: Small, sparse, frontier
	var/datum/town_type/outpost = new()
	outpost.name = "Outpost"
	outpost.id = "outpost"
	outpost.desc = "A remote trading post"
	outpost.size_range = list(15, 25)
	outpost.building_density = 0.2
	outpost.required_buildings = list("trading_post")
	outpost.optional_buildings = list("watchtower")
	outpost.npc_count_min = 2
	outpost.npc_count_max = 5
	outpost.npc_roles = list("trader", "guard")
	outpost.building_style = "wood"
	outpost.street_pattern = "organic"
	town_types["outpost"] = outpost
	
	// Ruin: Ancient, mysterious, dangerous
	var/datum/town_type/ruin = new()
	ruin.name = "Ruin"
	ruin.id = "ruin"
	ruin.desc = "Abandoned ancient settlement"
	ruin.size_range = list(20, 35)
	ruin.building_density = 0.2
	ruin.required_buildings = list()
	ruin.optional_buildings = list("crumbled_temple", "library_ruins")
	ruin.npc_count_min = 0
	ruin.npc_count_max = 2  // Rare hermits/guardians
	ruin.building_style = "stone"
	ruin.street_pattern = "organic"
	town_types["ruin"] = ruin
	
	return town_types

var/list/town_types = InitializeTownTypes()
```

#### 1.2: Narrative Anchor System

**File**: `dm/TownGenerator.dm` (continued)

```dm
/datum/story_anchor
	// Guarantees certain NPCs exist in town regardless of randomness
	var
		town_type = ""              // "hub", "settlement"
		required_npcs = list()      // NPC roles that MUST spawn
		npc_recipes = list()        // What recipes they teach
		story_location = 0          // Is this a story waypoint?
		accessibility = ""          // "free" (anytime) or "gated" (skill requirement)
		skill_gate = ""             // "smithing 2", "harvesting 5", etc. if gated
		kingdom = ""                // "freedom", "belief", "honor", "pride", "greed"
		theme = ""                  // Thematic name for debugging/UI
		is_antagonist = 0           // Is this the antagonist kingdom? (1 for Greed)// Define story anchors for five kingdoms
/proc/InitializeStoryAnchors()
	var/list/anchors = list()
	
	// KINGDOM 1: Kingdom of Freedom (Temperate, Starting Region, No Gates)
	var/datum/story_anchor/freedom = new()
	freedom.town_type = "hub"
	freedom.required_npcs = list("guard_captain", "blacksmith", "healer", "innkeeper")
	freedom.npc_recipes = list(
		"guard_captain" = list("combat_basics", "guard_training"),
		"blacksmith" = list("stone_hammer", "iron_hammer", "basic_smithing", "copper_tools"),
		"healer" = list("healing_knowledge", "herb_gathering", "first_aid"),
		"innkeeper" = list("shelter", "comfort", "rest_system", "basic_food")
	)
	freedom.story_location = 1
	freedom.accessibility = "free"
	freedom.kingdom = "freedom"
	freedom.theme = "Foundational Survival & Community"
	anchors["city_of_the_free"] = freedom
	
	// KINGDOM 2: Kingdom of Belief (Hilly, Scholarly, Gated: Smithing 2+)
	var/datum/story_anchor/behist = new()
	behist.town_type = "hub"
	behist.required_npcs = list("master_smith", "alchemist", "librarian", "architect")
	behist.npc_recipes = list(
		"master_smith" = list("steel_tools", "advanced_smithing", "armor_crafting", "enchanted_forging"),
		"alchemist" = list("refinement", "essence_extraction", "potions", "alchemical_transmutation"),
		"librarian" = list("lore_knowledge", "ancient_texts", "recipe_discovery"),
		"architect" = list("advanced_building", "fortification", "blueprints", "temple_design")
	)
	behist.story_location = 1
	behist.accessibility = "gated"
	behist.skill_gate = "smithing 2"
	behist.kingdom = "belief"
	behist.theme = "Knowledge, Crafting Mastery & Enlightenment"
	anchors["spire_of_behist"] = behist
	
	// KINGDOM 3: Kingdom of Honor (Forests, Chivalric, Gated: Combat 2+ & Moral Alignment)
	var/datum/story_anchor/honor = new()
	honor.town_type = "hub"
	honor.required_npcs = list("paladin", "justice_warden", "temple_healer", "knight_captain")
	honor.npc_recipes = list(
		"paladin" = list("righteous_combat", "virtue_channeling", "holy_protection"),
		"justice_warden" = list("moral_arbitration", "justice_quests", "virtue_teaching"),
		"temple_healer" = list("blessed_healing", "sanctuary_knowledge", "protective_wards"),
		"knight_captain" = list("knightly_order", "chivalric_code", "noble_defense")
	)
	honor.story_location = 1
	honor.accessibility = "gated"
	honor.skill_gate = "combat 2 + moral alignment"
	honor.kingdom = "honor"
	honor.theme = "Righteousness, Justice & Noble Virtue"
	anchors["keep_of_honor"] = honor
	
	// KINGDOM 4: Kingdom of Pride (Mountains, Martial, Gated: Combat 4+ & Smithing 3+)
	var/datum/story_anchor/pride = new()
	pride.town_type = "hub"
	pride.required_npcs = list("war_champion", "armor_smith", "general", "weaponsmith")
	pride.npc_recipes = list(
		"war_champion" = list("legendary_combat", "dueling_techniques", "battle_strategy"),
		"armor_smith" = list("plate_armor", "legendary_armor", "fortified_gear"),
		"general" = list("military_tactics", "siege_warfare", "formation_strategy"),
		"weaponsmith" = list("legendary_weapons", "war_forged_steel", "enchanted_blades")
	)
	pride.story_location = 1
	pride.accessibility = "gated"
	pride.skill_gate = "combat 4 + smithing 3"
	pride.kingdom = "pride"
	pride.theme = "Martial Excellence & Legendary Achievement"
	anchors["castle_of_pride"] = pride
	
	// KINGDOM 5: Kingdom of Greed (Coastal, Economic, ANTAGONIST, Gated: Exploration)
	var/datum/story_anchor/greed = new()
	greed.town_type = "hub"
	greed.required_npcs = list("merchant_prince", "corrupt_judge", "black_market_broker", "tax_collector")
	greed.npc_recipes = list(
		"merchant_prince" = list("exploitative_trade", "wealth_accumulation", "market_domination"),
		"corrupt_judge" = list("corruption_knowledge", "bribery", "legal_exploitation"),
		"black_market_broker" = list("black_market_goods", "stolen_artifacts", "contraband_trafficking"),
		"tax_collector" = list("wealth_extraction", "forced_labor_systems", "exploitation_tactics")
	)
	greed.story_location = 1
	greed.accessibility = "gated"
	greed.skill_gate = "exploration + wealth knowledge"
	greed.kingdom = "greed"
	greed.theme = "Avarice, Exploitation & Corruption (ANTAGONIST)"
	greed.is_antagonist = 1  // Flag as story antagonist
	anchors["port_of_plenty"] = greed
	
	// PORT TOWN: Accessible from all continents (travel nexus)
	var/datum/story_anchor/port = new()
	port.town_type = "hub"
	port.required_npcs = list("port_master", "ship_captain", "world_merchant")
	port.npc_recipes = list(
		"port_master" = list("inter_continental_travel", "world_knowledge"),
		"ship_captain" = list("sailing", "cargo_handling", "world_routes"),
		"world_merchant" = list("exotic_goods", "continental_trade")
	)
	port.story_location = 1
	port.accessibility = "free"
	port.kingdom = "neutral"
	port.theme = "Travel Hub & World Connection"
	anchors["port_town"] = port
		return anchors

var/list/story_anchors = InitializeStoryAnchors()
```

---

### Task 2: Town Layout Algorithm (2-2.5 hours)

#### 2.1: Main Town Generation Proc

**File**: `dm/TownGenerator.dm` (continued)

```dm
/proc/GenerateTown(town_id, town_type_id, location_x, location_y, seed)
	// Main proc: generates complete town at location
	// Returns town datum with all buildings, npcs, etc.
	
	var/datum/town_type/town_type = town_types[town_type_id]
	if(!town_type)
		world << "ERROR: Unknown town type [town_type_id]"
		return null
	
	var/datum/town/town = new()
	town.name = town_type.name
	town.id = town_id
	town.type = town_type_id
	town.origin_x = location_x
	town.origin_y = location_y
	town.seed = seed
	
	// Determine town size
	var/width = rand(town_type.size_range[1], town_type.size_range[2])
	var/height = rand(town_type.size_range[1], town_type.size_range[2])
	town.width = width
	town.height = height
	
	// Generate street layout
	GenerateStreetLayout(town, town_type)
	
	// Place buildings
	PlaceBuildings(town, town_type)
	
	// Spawn resources
	SpawnTownResources(town, town_type)
	
	// Determine NPC roster
	DetermineNPCRoster(town, town_type)
	
	// Build actual town on map
	ConstructTownOnMap(town, location_x, location_y)
	
	return town

/datum/town
	var
		// Identity
		name = ""               // "Kingdom of Freedom"
		id = ""                 // "freedom", "behist", etc.
		type = ""               // "hub", "settlement", "outpost"
		
		// Physical
		origin_x = 0
		origin_y = 0
		width = 0
		height = 0
		seed = 0
		
		// Contents
		buildings = list()      // Building objects placed
		streets = list()        // Street coordinates
		plazas = list()         // Open areas
		npcs = list()           // NPC roster
		resources = list()      // Spawned resources
		
		// Story
		is_story_anchor = 0     // Critical story location?
		accessibility = ""      // "free" or "gated"
		story_description = ""
```

#### 2.2: Street Layout Generation

**File**: `dm/TownGenerator.dm` (continued)

```dm
/proc/GenerateStreetLayout(datum/town/town, datum/town_type/town_type)
	// Generate street pattern based on town_type.street_pattern
	
	switch(town_type.street_pattern)
		if("grid")
			GenerateGridStreets(town)
		if("organic")
			GenerateOrganicStreets(town)
		if("radial")
			GenerateRadialStreets(town)

/proc/GenerateGridStreets(datum/town/town)
	// Regular grid pattern (hubs, organized towns)
	// Streets form 4-5 block sections
	var/block_size = 8  // Buildings per block
	var/street_width = 2  // Turf width of streets
	
	for(var/x = 0; x < town.width; x += (block_size + street_width))
		for(var/y = 0; y < town.height; y++)
			town.streets += list(list(x: x, y: y))  // Vertical streets
	
	for(var/y = 0; y < town.height; y += (block_size + street_width))
		for(var/x = 0; x < town.width; x++)
			town.streets += list(list(x: x, y: y))  // Horizontal streets

/proc/GenerateOrganicStreets(datum/town/town)
	// Winding streets, irregular blocks (settlements, outposts)
	// Uses simplex noise for natural-looking paths
	var/list/path = list()
	var/current_x = 0
	var/current_y = 0
	
	while(current_x < town.width && current_y < town.height)
		path += list(list(x: current_x, y: current_y))
		
		// Randomly meander (weighted towards forward movement)
		var/direction = rand(1, 100)
		if(direction < 60)
			current_x += 2
		else if(direction < 80)
			current_y += 2
		else
			current_x += rand(-1, 1) * 2
			current_y += rand(-1, 1) * 2
	
	town.streets = path

/proc/GenerateRadialStreets(datum/town/town)
	// Radial pattern from central plaza (future use)
	// Streets radiate from center like spokes
	// Placeholder for now
	GenerateGridStreets(town)  // Fall back to grid
```

#### 2.3: Building Placement

**File**: `dm/TownGenerator.dm` (continued)

```dm
/proc/PlaceBuildings(datum/town/town, datum/town_type/town_type)
	// Place buildings in available spaces between streets
	
	var/target_building_count = round(town.width * town.height * town_type.building_density)
	var/buildings_placed = 0
	
	// First place REQUIRED buildings
	for(var/building_type in town_type.required_buildings)
		var/list/space = FindBuildingSpace(town, 6, 8)  // 6x8 building size
		if(space)
			PlaceBuilding(town, building_type, space["x"], space["y"], space["width"], space["height"])
			buildings_placed++
	
	// Then place OPTIONAL buildings until we reach density target
	while(buildings_placed < target_building_count)
		var/building_type = pick(town_type.optional_buildings)
		var/list/space = FindBuildingSpace(town, 4, 6)  // Smaller optional buildings
		
		if(!space)
			break  // No more space
		
		PlaceBuilding(town, building_type, space["x"], space["y"], space["width"], space["height"])
		buildings_placed++

/proc/FindBuildingSpace(datum/town/town, min_width, min_height)
	// Find open rectangular space large enough for building
	// Returns list(x, y, width, height) or null
	
	for(var/attempt = 0; attempt < 20; attempt++)
		var/test_x = rand(town.origin_x, town.origin_x + town.width - min_width)
		var/test_y = rand(town.origin_y, town.origin_y + town.height - min_height)
		
		if(IsSpaceClear(town, test_x, test_y, min_width, min_height))
			return list(
				x: test_x,
				y: test_y,
				width: min_width + rand(-1, 2),  // Slight variation
				height: min_height + rand(-1, 2)
			)
	
	return null  // No space found

/proc/IsSpaceClear(datum/town/town, x, y, width, height)
	// Check if rectangular space is free of streets/buildings
	
	for(var/check_x = x; check_x < x + width; check_x++)
		for(var/check_y = y; check_y < y + height; check_y++)
			// Check if this space is a street or occupied building
			for(var/street in town.streets)
				if(street["x"] == check_x && street["y"] == check_y)
					return 0  // Street here
			
			for(var/building in town.buildings)
				if(check_x >= building.x && check_x < building.x + building.width)
					if(check_y >= building.y && check_y < building.y + building.height)
						return 0  // Building here
	
	return 1  // Space is clear

/proc/PlaceBuilding(datum/town/town, building_type, x, y, width, height)
	// Create building object and add to town
	
	var/obj/building/building = new()
	building.type = building_type
	building.x = x
	building.y = y
	building.width = width
	building.height = height
	
	// Set visual appearance based on type
	switch(building_type)
		if("inn")
			building.name = "Inn"
			building.icon_state = "inn"
		if("blacksmith")
			building.name = "Blacksmith's Forge"
			building.icon_state = "blacksmith"
		if("bank")
			building.name = "Bank"
			building.icon_state = "bank"
		// ... etc for other types
	
	town.buildings += building

/obj/building
	var
		type = ""
		width = 0
		height = 0
```

---

### Task 3: NPC Placement & Roster (1.5-2 hours)

#### 3.1: NPC Roster Determination

**File**: `dm/TownGenerator.dm` (continued)

```dm
/proc/DetermineNPCRoster(datum/town/town, datum/town_type/town_type)
	// Determine which NPCs spawn in town
	
	var/npc_count = rand(town_type.npc_count_min, town_type.npc_count_max)
	
	// Check if this is a story anchor
	for(var/anchor_id in story_anchors)
		var/datum/story_anchor/anchor = story_anchors[anchor_id]
		if(anchor.town_type == town.type)
			// This town matches a story anchor
			// MUST include required NPCs
			for(var/role in anchor.required_npcs)
				town.npcs += list(list(
					role: role,
					recipes: anchor.npc_recipes[role]
				))
				npc_count--  // Decrement available slots
	
	// Fill remaining slots with available roles
	while(npc_count > 0)
		var/role = pick(town_type.npc_roles)
		town.npcs += list(list(
			role: role,
			recipes: GetDefaultRecipesForRole(role)
		))
		npc_count--

/proc/GetDefaultRecipesForRole(role)
	// Return default recipes NPCs teach based on role
	
	switch(role)
		if("blacksmith")
			return list("stone_hammer", "iron_hammer", "basic_smithing")
		if("healer")
			return list("healing_knowledge", "herb_gathering")
		if("innkeeper")
			return list("shelter", "comfort", "rest_system")
		if("merchant")
			return list("trading_knowledge", "value_assessment")
		if("farmer")
			return list("farming", "crop_knowledge")
		// ... etc
	
	return list()

/proc/AssignNPCsToBuildings(datum/town/town)
	// Match NPC roles to building types
	// e.g., blacksmith NPC → blacksmith building
	
	var/list/role_to_building = list(
		"blacksmith" = "blacksmith",
		"healer" = "healer",
		"innkeeper" = "inn",
		"banker" = "bank",
		"merchant" = "market",
		"guard_captain" = "watchtower"
	)
	
	for(var/npc in town.npcs)
		var/building_type = role_to_building[npc["role"]]
		
		if(building_type)
			// Find matching building in town
			for(var/building in town.buildings)
				if(building.type == building_type)
					npc["building"] = building
					break
```

---

### Task 4: Resource & Spawn Integration (1-1.5 hours)

#### 4.1: Town Resource Spawning

**File**: `dm/TownGenerator.dm` (continued)

```dm
/proc/SpawnTownResources(datum/town/town, datum/town_type/town_type)
	// Spawn resources unique to town type
	// Resources vary by biome AND town type
	
	// Small amount of crafting materials in town
	var/resource_count = round(town.width * town.height * 0.05)
	
	for(var/i = 0; i < resource_count; i++)
		var/resource_type = pick(town_type.resource_table)
		var/list/space = FindRandomTown Space(town)
		
		if(space)
			var/obj/resource = new(resource_type)
			resource.x = space["x"]
			resource.y = space["y"]
			town.resources += resource

/proc/ConstructTownOnMap(datum/town/town, base_x, base_y)
	// Actually build town on the game map
	// Called after all planning is complete
	
	// Paint streets
	for(var/street in town.streets)
		var/actual_x = base_x + street["x"]
		var/actual_y = base_y + street["y"]
		var/turf/T = locate(actual_x, actual_y, 1)
		if(T)
			T.ChangeTurf(/turf/dirt_path)  // Streets are dirt paths
	
	// Build buildings
	for(var/building in town.buildings)
		BuildingOnMap(building, base_x, base_y)
	
	// Spawn NPCs
	for(var/npc_data in town.npcs)
		SpawnNPCInTown(town, npc_data, base_x, base_y)

/proc/BuildingOnMap(obj/building/building, base_x, base_y)
	// Create actual building structure on map
	// Placeholder: just mark area with different turf
	
	for(var/x = building.x; x < building.x + building.width; x++)
		for(var/y = building.y; y < building.y + building.height; y++)
			var/actual_x = base_x + x
			var/actual_y = base_y + y
			var/turf/T = locate(actual_x, actual_y, 1)
			if(T)
				T.ChangeTurf(/turf/stone_floor)  // Building interiors
```

---

### Task 5: Integration with Map Generator (1.5-2 hours)

#### 5.1: Hook into Procedural Map Generation

**File**: `mapgen/backend.dm` (MODIFY - add town spawning)

The existing map generator needs a hook to spawn towns after terrain is generated:

```dm
// In existing GenerateMap() proc, after terrain generation:

proc/GenerateMap(lakes, hills)
	// [... existing terrain generation code ...]
	
	// NEW: Spawn story towns after terrain
	GenerateStoryTowns()
	
	return 1

/proc/GenerateStoryTowns()
	// Place all five kingdom hubs with story anchors
	
	// Kingdom 1: Freedom (Starting point, temperate, no skill gates)
	GenerateTown("city_of_the_free", "hub", 100, 100, world.time)
	
	// Kingdom 2: Belief (Scholarly, gated at Smithing 2+)
	GenerateTown("spire_of_behist", "hub", 300, 250, world.time + 100)
	
	// Kingdom 3: Honor (Chivalric, gated at Combat 2+ & Moral Alignment)
	GenerateTown("keep_of_honor", "hub", 150, 300, world.time + 75)
	
	// Kingdom 4: Pride (Martial, gated at Combat 4+ & Smithing 3+)
	GenerateTown("castle_of_pride", "hub", 500, 150, world.time + 200)
	
	// Kingdom 5: Greed (Economic ANTAGONIST, gated at Exploration)
	GenerateTown("port_of_plenty", "hub", 200, 400, world.time + 150)
	
	// Spawn secondary settlements in each kingdom region
	GenerateKingdomSettlements("freedom", 3)     // 3 villages in Freedom region
	GenerateKingdomSettlements("belief", 3)      // 3 settlements in Belief region
	GenerateKingdomSettlements("honor", 3)       // 3 settlements in Honor region
	GenerateKingdomSettlements("pride", 3)       // 3 military settlements in Pride region
	GenerateKingdomSettlements("greed", 3)       // 3 exploitative settlements in Greed region

/proc/GenerateKingdomSettlements(kingdom, count)
	// Spawn procedural settlements in kingdom region
	for(var/i = 1; i <= count; i++)
		var/x = rand(50, 400)
		var/y = rand(50, 400)
		var/settlement_type = pick("settlement", "outpost")
		GenerateTown("[kingdom]_[settlement_type]_[i]", settlement_type, x, y, world.time + rand(50, 300))
	
	// Random settlements, outposts based on biome
	// Places settlements near forest/grassland areas
	// Places outposts near mountains/water
	
	// Port Town: on coastline if water exists
	GenerateTown("port", "hub", 500, 400, world.time + 200)
```

#### 5.2: Story Town Integration

**File**: `dm/Basics.dm` (MODIFY - call town generator on world init)

```dm
world/New()
	..()
	InitializeContinents()
	InitializeTownTypes()        // NEW: Initialize town definitions
	InitializeStoryAnchors()     // NEW: Initialize story anchors
	InitWeatherController()
	spawn() DynamicWeatherTick()
```

---

### Task 6: Testing & Validation (1.5 hours)

#### 6.1: Test Town Generation

**Checklist**:
- [ ] Town types initialize correctly (4 town types)
- [ ] Story anchors create required NPCs (blacksmith, healer always in hub)
- [ ] Street layout generates (grid/organic patterns work)
- [ ] Buildings place without overlap
- [ ] Resources spawn in towns
- [ ] NPCs roster matches building availability
- [ ] Towns place on actual map turfs
- [ ] Multiple towns spawn without collision
- [ ] Story anchor towns always exist (Freedom, Behist, Port)
- [ ] Procedural variation works (different towns on each run)

#### 6.2: Build & Verify

```powershell
# Run build task
dm: build - Pondera.dme

# Expected: 0 errors
# Test in-game: /debug_worlds should show towns
```

---

## Files to Create

| File | Lines | Purpose |
|------|-------|---------|
| `dm/TownGenerator.dm` | 700+ | Core town generation system |

**Total New Code**: ~700 lines

## Files to Modify

| File | Changes | Impact |
|------|---------|--------|
| `mapgen/backend.dm` | Add town spawn hook | +10 lines |
| `dm/Basics.dm` | Call init procs | +2 lines |
| `Pondera.dme` | Add include | +1 line |

**Total Modified Lines**: ~13 lines

---

## Integration Checklist

- [ ] Create `dm/TownGenerator.dm` with full town system
- [ ] Define town types (hub, settlement, outpost, ruin)
- [ ] Implement story anchor system
- [ ] Build street layout algorithms (grid, organic)
- [ ] Implement building placement with collision detection
- [ ] Build NPC roster determination
- [ ] Implement resource spawning
- [ ] Hook into map generator (GenerateStoryTowns)
- [ ] Update world init to call town initialization
- [ ] Update Pondera.dme includes
- [ ] Test town generation (multiple runs)
- [ ] Verify no overlapping buildings
- [ ] Verify story anchor towns always exist
- [ ] Build and verify 0 errors
- [ ] Commit Phase B to git

---

## Implementation Notes

### Design Decisions

**Why Separate Town Types?**
- Different gameplay purposes (hub vs outpost)
- Visual/thematic variety
- Resource distribution (hubs have more, outposts have less)
- NPC availability (hubs have diverse roles, outposts have few)

**Why Story Anchors?**
- Ensures key NPCs exist for story progression
- Prevents "missing blacksmith" problem in random generation
- Maintains narrative consistency despite procedural variance
- Easy to extend (just add more anchors)

**Why Separate Street Patterns?**
- Grid = organized, efficient (hubs)
- Organic = natural, wandering (settlements)
- Radial = ancient/magical (ruins, temples)

**Why NPC-Building Matching?**
- Logical placement (blacksmith in smithy)
- Players learn town layout naturally
- Reduces need for explicit signage

### Pseudocode Flow

```
GenerateTown(town_id, type):
  1. Create town datum
  2. Determine size (random within type range)
  3. Generate street pattern (grid/organic/radial)
  4. Find building spaces between streets
  5. Place required buildings (inn, bank, etc.)
  6. Place optional buildings until density reached
  7. Determine NPC roster (required + random)
  8. Assign NPCs to matching buildings
  9. Spawn resources in town
  10. Actually construct on map (change turfs, spawn objects)
```

### Performance Considerations

- **Town generation on world startup**: One-time cost (~5-10 seconds for whole world)
- **No per-tick overhead**: Towns don't update after generation
- **Memory efficient**: Town datums stored once, NPCs created as actual mobs
- **Scalable**: Can generate 20+ towns without issue

### Extensibility

Future additions ready for:
- Dynamic town growth (new buildings added over time)
- Town destruction/ruin (abandoned settlements)
- Player-built towns (sandbox/PvP continents)
- Town alliances/wars (diplomatic gameplay)
- Seasonal town variations (different resources per season)

---

## Acceptance Criteria

✅ **Phase B is complete when:**

1. All town types initialize (hub, settlement, outpost, ruin)
2. Story anchors guarantee required NPCs spawn
3. Street layouts generate (grid/organic patterns work)
4. Buildings place without overlap
5. NPCs spawn in towns matched to buildings
6. Resources spawn in towns
7. Towns actually exist on the game map
8. Multiple towns spawn on same continent without collision
9. Story anchor towns (Freedom, Behist, Port) always exist
10. Procedural variation works (different layout each run)
11. No compile errors
12. All test cases pass
13. Code committed with clear commit messages

---

## Next Phase Dependency

Phase C (Story World Integration) depends on:
- ✅ Continent framework complete (Phase A)
- ✅ Town generation complete (Phase B)
- ⏳ Map generator integration (Phase B Task 5)

Phase D (Sandbox Continent) can start after Phase B.

---

**Ready to begin Phase B?** → Confirm, and implementation will start immediately.

