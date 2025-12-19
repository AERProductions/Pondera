// MultiWorldConfig.dm - Phase F: Multi-World Configuration

// Global multi-world data
var/list/player_continent_history = list()
var/list/cross_world_achievements = list()

/proc/VerifyMultiWorldConfig()
	if(!islist(player_continent_history)) player_continent_history = list()
	if(!islist(cross_world_achievements)) cross_world_achievements = list()
	return 1

// ============================================================================
// CROSS-WORLD ACHIEVEMENT SYSTEM
// ============================================================================

var/list/achievement_definitions = list(
	"continental_explorer" = list(
		"name" = "Continental Explorer",
		"description" = "Visit all three continents",
		"reward" = 500
	),
	"master_craftsman" = list(
		"name" = "Master Craftsman",
		"description" = "Achieve level 10 in any skill globally",
		"reward" = 1000
	),
	"recipe_master" = list(
		"name" = "Recipe Master",
		"description" = "Unlock 50 recipes across all continents",
		"reward" = 750
	),
	"global_merchant" = list(
		"name" = "Global Merchant",
		"description" = "Earn 10000 profit from stalls across continents",
		"reward" = 500
	),
	"legendary_adventurer" = list(
		"name" = "Legendary Adventurer",
		"description" = "Spend time on all three continents",
		"reward" = 2000
	)
)

// ============================================================================
// PERSISTENCE CONFIGURATION
// ============================================================================

var/list/multi_world_persistence = list(
	"persist_skills" = 1,          // Skills learned anywhere apply everywhere
	"persist_recipes" = 1,         // Recipes discovered anywhere unlock everywhere
	"persist_knowledge" = 1,       // Knowledge learned globally
	"persist_positions" = 1,       // Save position per continent
	"persist_stall_profits" = 1,   // Stall profits shared globally
	"persist_achievements" = 1,    // Achievements tracked globally
	"reset_inventory_on_switch" = 0,  // Inventory stays with player by default
	"reset_equipment_on_switch" = 0,  // Equipment stays with player by default
	"reset_vitals_on_switch" = 0      // HP/stamina persist (no penalty)
)

// ============================================================================
// CONTINENT TRAVEL RULES
// ============================================================================

var/list/continent_travel_rules = list(
	CONT_STORY = list(
		"name" = "Kingdom of Freedom",
		"type" = "story",
		"min_level" = 1,
		"travel_cost" = 0,
		"cooldown" = 0,
		"allow_pvp" = 0,
		"allow_building" = 1,
		"allow_stealing" = 0,
		"description" = "A procedurally-generated story world with narrative anchors, NPCs, and quests"
	),
	CONT_SANDBOX = list(
		"name" = "Creative Sandbox",
		"type" = "sandbox",
		"min_level" = 1,
		"travel_cost" = 0,
		"cooldown" = 0,
		"allow_pvp" = 0,
		"allow_building" = 1,
		"allow_stealing" = 0,
		"description" = "An infinite creative world for building without combat pressure"
	),
	CONT_PVP = list(
		"name" = "Battlelands",
		"type" = "pvp",
		"min_level" = 5,
		"travel_cost" = 100,
		"cooldown" = 300,
		"allow_pvp" = 1,
		"allow_building" = 0,
		"allow_stealing" = 1,
		"description" = "A deadly PvP zone with territorial warfare, raiding, and faction conflict"
	)
)

// ============================================================================
// SKILL SHARING CONFIGURATION
// ============================================================================
// Lists all skills that persist across continents

var/list/globally_shared_skills = list(
	"building",
	"smithing",
	"smelting",
	"cooking",
	"gardening",
	"fishing",
	"harvesting",
	"mining",
	"digging",
	"carving"
)

// ============================================================================
// RECIPE SHARING CONFIGURATION
// ============================================================================

var/list/globally_shared_recipes = list(
	"wooden_table",
	"stone_stairs",
	"wooden_door",
	"stone_wall",
	"market_stall",
	"iron_sword",
	"steel_tools",
	"basic_cooking"
)

// ============================================================================
// KNOWLEDGE PERSISTENCE
// ============================================================================

var/list/global_knowledge_topics = list(
	"smithing_fundamentals",
	"resource_gathering",
	"cooking_basics",
	"building_principles",
	"world_lore"
)

// ============================================================================
// CONTINENT HISTORY TRACKING
// ============================================================================

/proc/LogContinentVisit(mob/player, continent_id)
	if(!player) return
	
	if(!(player.key in player_continent_history))
		player_continent_history[player.key] = list()
	
	player_continent_history[player.key] += continent_id

/proc/GetContinentVisitCount(mob/player, continent_id)
	if(!player || !(player.key in player_continent_history)) return 0
	
	var/count = 0
	for(var/visit in player_continent_history[player.key])
		if(visit == continent_id) count++
	
	return count

/proc/GetContinentsVisited(mob/player)
	if(!player || !(player.key in player_continent_history)) return list()
	
	var/list/unique = list()
	for(var/cont in player_continent_history[player.key])
		if(!(cont in unique)) unique += cont
	
	return unique

/proc/HasVisitedAllContinents(mob/player)
	if(!player) return 0
	var/list/visited = GetContinentsVisited(player)
	return (visited.len >= 3)

// ============================================================================
// ACHIEVEMENT TRACKING
// ============================================================================

/proc/UnlockAchievement(mob/player, achievement_id)
	if(!player) return 0
	
	if(!(player.key in cross_world_achievements))
		cross_world_achievements[player.key] = list()
	
	if(achievement_id in cross_world_achievements[player.key])
		return 0  // Already unlocked
	
	cross_world_achievements[player.key] += achievement_id
	
	var/def = achievement_definitions[achievement_id]
	if(def && player)
		player << "MULTI Achievement Unlocked: [def["name"]] - [def["description"]]"
	
	return 1

/proc/HasAchievement(mob/player, achievement_id)
	if(!player || !(player.key in cross_world_achievements)) return 0
	return (achievement_id in cross_world_achievements[player.key])

/proc/GetPlayerAchievements(mob/player)
	if(!player || !(player.key in cross_world_achievements)) return list()
	return cross_world_achievements[player.key]

// ============================================================================
// DEBUGGING
// ============================================================================

/proc/DebugMultiWorldConfig()
	world << "MULTI Config Debug:"
	world << "MULTI  Persistence Flags: [multi_world_persistence.len] configured"
	world << "MULTI  Continents: [continent_travel_rules.len] defined"
	world << "MULTI  Global Skills: [globally_shared_skills.len]"
	world << "MULTI  Global Recipes: [globally_shared_recipes.len]"
	world << "MULTI  Achievements: [achievement_definitions.len]"
	world << "MULTI  Config Debug Complete"
