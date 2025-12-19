/**
 * TOWN DATA STRUCTURES & PERSISTENCE
 * 
 * Handles storing and retrieving town data from savefile.
 * Also defines helper structures for town properties.
 */

// ============================================================================
// TOWN BIOME PROFILES
// ============================================================================

var/global/list/biome_town_profiles = list(
	"temperate" = list(
		building_styles = list("wooden", "stone", "thatched"),
		primary_resources = list("lumber", "stone", "grain"),
		natural_surroundings = "forest, grassland",
		npc_archetypes = list("farmer", "merchant", "guard")
	),
	"arctic" = list(
		building_styles = list("stone", "ice", "fur-lined"),
		primary_resources = list("ice", "stone", "fur"),
		natural_surroundings = "snow, mountains",
		npc_archetypes = list("hunter", "scout", "shaman")
	),
	"desert" = list(
		building_styles = list("adobe", "sandstone", "canvas"),
		primary_resources = list("salt", "sand", "rare spices"),
		natural_surroundings = "dunes, rock formations",
		npc_archetypes = list("nomad", "trader", "scholar")
	),
	"rainforest" = list(
		building_styles = list("wooden", "organic", "bamboo"),
		primary_resources = list("lumber", "herbs", "rare plants"),
		natural_surroundings = "dense vegetation, vines",
		npc_archetypes = list("herbalist", "guide", "shaman")
	)
)

// ============================================================================
// TOWN FEATURE DEFINITIONS
// ============================================================================

/**
 * Town Features - special properties that modify town behavior
 * 
 * Examples:
 * - "academy" - town has learning NPCs, craft research bonuses
 * - "market_hub" - town attracts merchants, good prices on trade goods
 * - "corrupted" - town under Greed influence, dark NPCs and items
 * - "liberated" - town freed by players, resistance base
 * - "fortified" - town has military presence, guards patrol
 */

var/global/list/town_features = list(
	"academy" = list(
		description = "Center of learning",
		npcs_attracted = list("scholar", "wizard", "mentor"),
		crafting_bonus = 1.1,
		npc_density = 1.2
	),
	"market_hub" = list(
		description = "Major trading center",
		npcs_attracted = list("merchant", "trader", "appraiser"),
		trade_good_variety = 1.3,
		npc_density = 1.3
	),
	"military_outpost" = list(
		description = "Armed forces base",
		npcs_attracted = list("guard", "general", "trainer"),
		defense_bonus = 1.5,
		npc_density = 1.1
	),
	"shrine" = list(
		description = "Religious site",
		npcs_attracted = list("priest", "pilgrim", "mystic"),
		magic_power = 1.2,
		npc_density = 0.9
	),
	"corrupted" = list(
		description = "Under Greed influence",
		npcs_attracted = list("corrupt_merchant", "cultist", "slave_driver"),
		darkness_factor = 1.5,
		npc_density = 0.8
	),
	"liberated" = list(
		description = "Freed by resistance",
		npcs_attracted = list("freedom_fighter", "refugee", "reformer"),
		freedom_factor = 1.5,
		npc_density = 1.1
	)
)

// ============================================================================
// KINGDOM-SPECIFIC TOWN GENERATION
// ============================================================================

/**
 * KingdomTownTemplate
 * 
 * Each kingdom has a unique town generation template:
 * - Architectural style
 * - NPC population types
 * - Primary resources
 * - Special features
 */

var/global/list/kingdom_templates = list(
	"freedom" = list(
		hub_name = "City of the Free",
		hub_description = "Sprawling city of diverse peoples united by freedom",
		town_naming_theme = "natural_features",
		primary_buildings = list("tavern", "market", "farm", "workshop"),
		npc_mix = list("farmer" = 0.3, "merchant" = 0.2, "craftsperson" = 0.3, "vagabond" = 0.2),
		biome_preference = "temperate"
	),
	"belief" = list(
		hub_name = "Spire of Behist",
		hub_description = "Towering academy and mystical center of learning",
		town_naming_theme = "scholarly",
		primary_buildings = list("library", "tower", "temple", "laboratory"),
		npc_mix = list("scholar" = 0.4, "wizard" = 0.2, "priest" = 0.2, "student" = 0.2),
		biome_preference = "mountain/high_elevation"
	),
	"honor" = list(
		hub_name = "Keep of Honor",
		hub_description = "Fortified stronghold of valiant knights",
		town_naming_theme = "noble_titles",
		primary_buildings = list("keep", "barracks", "temple", "training_grounds"),
		npc_mix = list("knight" = 0.3, "guard" = 0.3, "priest" = 0.2, "noble" = 0.2),
		biome_preference = "highlands/defensive"
	),
	"pride" = list(
		hub_name = "Castle of Pride",
		hub_description = "Magnificent royal seat of military might",
		town_naming_theme = "imperial",
		primary_buildings = list("palace", "barracks", "armory", "war_room"),
		npc_mix = list("general" = 0.2, "soldier" = 0.4, "noble" = 0.2, "commander" = 0.2),
		biome_preference = "strategic_heights"
	),
	"greed" = list(
		hub_name = "Port of Plenty",
		hub_description = "Corrupt trading nexus at crater's rim",
		town_naming_theme = "merchant_greed",
		primary_buildings = list("market", "tavern", "warehouse", "slave_pen"),
		npc_mix = list("merchant" = 0.3, "thug" = 0.3, "slave_master" = 0.2, "smuggler" = 0.2),
		biome_preference = "crater_rim"
	)
)

// ============================================================================
// TOWN PROSPERITY MECHANICS
// ============================================================================

/**
 * Prosperity Score (0-100)
 * 
 * Affects:
 * - Building quality and quantity
 * - NPC population density
 * - Available goods in shops
 * - NPC mood and cooperation
 * 
 * Modified by:
 * - Kingdom reputation (high = prosperity)
 * - Greed influence (high = poverty unless exploited)
 * - Player actions (liberation = prosperity increase)
 * - Resource availability nearby
 */

proc/UpdateTownProsperity(town/T)
	if(!T) return
	
	var/new_prosperity = 50  // base
	
	// Check nearby resources
	var/nearby_resources = 0
	for(var/building/B in T.buildings)
		if(B.type == "farm") nearby_resources += 10
	new_prosperity += min(nearby_resources, 30)
	
	// TODO: Check kingdom reputation when system is available
	// if(T.kingdom in world_system.kingdoms)
	//	var/reputation = GetKingdomReputation(T.kingdom)
	//	new_prosperity += clamp(reputation / 2, -20, 30)
	
	// Check Greed corruption
	if(T.corruption > 50)
		if(T.controlled_by == "greed_merchant" || T.controlled_by == "greed_corrupted")
			// Exploited towns can still be prosperous (for those exploiting them)
			new_prosperity += 10
		else
			// Towns resisting Greed suffer
			new_prosperity -= 15
	
	T.prosperity = clamp(new_prosperity, 10, 100)

// ============================================================================
// TOWN REPUTATION & CONTROL
// ============================================================================

/**
 * TownControl
 * 
 * Tracks which faction controls a town.
 * Affects:
 * - Available NPCs and quests
 * - Shop goods
 * - Security/safety
 * - Player interaction options
 * 
 * For story mode: Kingdom vs. Greed factions
 * For PvP mode: Player faction control
 */

proc/GetTownControl(town/T)
	if(!T) return "neutral"
	return T.controlled_by || "neutral"

proc/SetTownControl(town/T, controller)
	if(!T) return
	T.controlled_by = controller
	world.log << "[T.name] is now controlled by [controller]"
	UpdateTownProsperity(T)

// ============================================================================
// TOWN DISCOVERY & EXPLORATION
// ============================================================================

/**
 * TownDiscoveryData
 * 
 * Tracks which towns each player has discovered/visited.
 * Stored per player in character data.
 */

/mob/players
	var
		list/discovered_towns = list()
		list/visited_towns = list()

proc/PlayerDiscoversTown(mob/players/P, town/T)
	if(!P || !T) return
	if(T in P.discovered_towns) return
	
	P.discovered_towns.Add(T)
	TownDiscovered(T)
	
	// Notify player
	P.client << output("<b>You discovered [T.name]!</b>", "output")

proc/PlayerVisitsTown(mob/players/P, town/T)
	if(!P || !T) return
	if(T in P.visited_towns) return
	
	P.visited_towns.Add(T)
	TownVisited(T)
	
	// Notify player
	P.client << output("You have entered [T.name]", "output")

// ============================================================================
// BUILDING QUERYING
// ============================================================================

proc/GetBuildingsByType(town/T, building_type)
	var/list/result = list()
	if(!T) return result
	
	for(var/building/B in T.buildings)
		if(B.type == building_type)
			result.Add(B)
	
	return result

proc/GetBuildingsByPurpose(town/T, purpose)
	var/list/result = list()
	if(!T) return result
	
	for(var/building/B in T.buildings)
		if(B.build_purpose == purpose)
			result += B
	
	return result

// ============================================================================
// TOWN INITIALIZATION HOOK
// ============================================================================

/**
 * These procs are called during world startup.
 * Hooked into World/New() in Basics.dm
 */

proc/InitializeTownSystem()
	if(!LoadTownData())
		// No saved data, generate new towns
		GenerateAllTowns()
	else
		// Loaded towns, verify integrity
		VerifyTownData()
	
	// Start periodic saves
	spawn() StartTownPeriodicSave()

proc/VerifyTownData()
	// Check that all towns are valid, rebuild NPCs, etc.
	world.log << "Verifying town data..."
	for(var/town/T in towns)
		if(!T.buildings)
			T.buildings = list()
		else if(length(T.buildings) == 0)
			GenerateTownBuildings(T)
	
	world.log << "Town verification complete"
