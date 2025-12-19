// PvPData.dm - Phase E: PvP Configuration & Data

// Global PvP variables
var/list/pvp_territories = list()
var/list/player_claims = list()
var/list/territory_resources = list()
var/list/player_combat_xp = list()
var/list/player_combat_level = list()
var/list/player_kill_count = list()
var/list/active_pvp_events = list()
var/list/event_history = list()

/proc/VerifyPvPData()
	if(!islist(pvp_territories)) pvp_territories = list()
	if(!islist(player_claims)) player_claims = list()
	if(!islist(territory_resources)) territory_resources = list()
	if(!islist(player_combat_xp)) player_combat_xp = list()
	if(!islist(player_combat_level)) player_combat_level = list()
	if(!islist(player_kill_count)) player_kill_count = list()
	if(!islist(active_pvp_events)) active_pvp_events = list()
	if(!islist(event_history)) event_history = list()
	return 1

// PvP Continent Configuration
var/list/pvp_continent_config = list(
	"allow_pvp" = 1,
	"allow_stealing" = 1,
	"allow_monsters" = 1,
	"allow_npcs" = 1,
	"allow_building" = 0,
	"allow_gathering" = 1,
	"weather_active" = 1,
	"dynamic_events" = 1,
	"faction_wars" = 1,
	"day_night_cycle" = 1,
	"respawn_system" = 1,
	"death_penalty" = 0.2,  // 20% XP loss on death
	"territory_claim_cost_stone" = 100,
	"territory_claim_cost_wood" = 50,
	"territory_radius" = 10,
	"tax_rate" = 0.10
)

// Territory Control Tiers
var/list/territory_tier_config = alist(
	1, list(
		"name" = "Outpost",
		"wall_limit" = 3,
		"tower_limit" = 1,
		"max_resources" = 1000,
		"defense_bonus" = 10
	),
	2, list(
		"name" = "Fort",
		"wall_limit" = 6,
		"tower_limit" = 2,
		"max_resources" = 2500,
		"defense_bonus" = 25
	),
	3, list(
		"name" = "Stronghold",
		"wall_limit" = 10,
		"tower_limit" = 4,
		"max_resources" = 5000,
		"defense_bonus" = 50
	),
	4, list(
		"name" = "Fortress",
		"wall_limit" = 15,
		"tower_limit" = 6,
		"max_resources" = 10000,
		"defense_bonus" = 100
	)
)

// Combat Progression
var/list/combat_level_config = alist(
	1, list("name" = "Novice", "xp_to_next" = 500, "damage_bonus" = 0),
	2, list("name" = "Initiate", "xp_to_next" = 500, "damage_bonus" = 5),
	3, list("name" = "Warrior", "xp_to_next" = 750, "damage_bonus" = 10),
	4, list("name" = "Veteran", "xp_to_next" = 1000, "damage_bonus" = 20),
	5, list("name" = "Champion", "xp_to_next" = 1500, "damage_bonus" = 35),
	10, list("name" = "Legendary", "xp_to_next" = 999999, "damage_bonus" = 100)
)

// Dynamic Event Types & Rewards
var/list/pvp_event_config = list(
	"resource_surge" = list(
		"description" = "Rare resources appear in a location",
		"duration" = 300,
		"reward_base" = 100,
		"participants_max" = 20,
		"difficulty_range" = list(1, 3)
	),
	"monster_invasion" = list(
		"description" = "Wave of monsters attacks a territory",
		"duration" = 600,
		"reward_base" = 150,
		"participants_max" = 40,
		"difficulty_range" = list(2, 4)
	),
	"territory_earthquake" = list(
		"description" = "Earthquake damages nearby fortifications",
		"duration" = 120,
		"reward_base" = 50,
		"participants_max" = 10,
		"difficulty_range" = list(1, 2)
	),
	"faction_war" = list(
		"description" = "Factional forces clash for territory control",
		"duration" = 900,
		"reward_base" = 250,
		"participants_max" = 100,
		"difficulty_range" = list(3, 5)
	)
)

// Faction Configuration for PvP (separate from Story factions)
var/list/pvp_faction_config = alist(
	1, list(
		"name" = "Crimson Legion",
		"philosophy" = "Aggressive expansionism",
		"color" = "#FF0000",
		"bonus_damage" = 0.15,
		"bonus_defense" = 0.05
	),
	2, list(
		"name" = "Silver Guard",
		"philosophy" = "Defensive strategy",
		"color" = "#C0C0C0",
		"bonus_damage" = 0.05,
		"bonus_defense" = 0.20
	),
	3, list(
		"name" = "Shadow Guild",
		"philosophy" = "Stealth and sabotage",
		"color" = "#1A1A1A",
		"bonus_damage" = 0.10,
		"bonus_defense" = 0.10
	),
	4, list(
		"name" = "Golden Dawn",
		"philosophy" = "Trade and prosperity",
		"color" = "#FFD700",
		"bonus_damage" = 0.08,
		"bonus_defense" = 0.08
	)
)

// Fortification Cost Tables
var/list/fortification_costs = list(
	"wall" = list(
		"stone" = 25,
		"wood" = 15,
		"durability" = 50,
		"labor_time" = 30
	),
	"tower" = list(
		"stone" = 50,
		"wood" = 30,
		"durability" = 100,
		"labor_time" = 60,
		"defense_bonus" = 5
	),
	"gate" = list(
		"stone" = 40,
		"wood" = 25,
		"durability" = 75,
		"labor_time" = 45,
		"entry_control" = 1
	)
)

// Resource Extraction Rates
var/list/territory_resource_yields = list(
	"ore" = list(
		"base_rate" = 5,
		"seasonal_modifier" = 1.0,
		"difficulty_tier" = 1
	),
	"wood" = list(
		"base_rate" = 8,
		"seasonal_modifier" = 1.2,
		"difficulty_tier" = 1
	),
	"rare_ore" = list(
		"base_rate" = 1,
		"seasonal_modifier" = 0.8,
		"difficulty_tier" = 3
	),
	"enchanted_wood" = list(
		"base_rate" = 0.5,
		"seasonal_modifier" = 1.5,
		"difficulty_tier" = 4
	)
)

// Raid Mechanics
var/list/raid_config = list(
	"min_attackers" = 2,
	"max_def_multiplier" = 2.0,
	"raid_cooldown" = 3600,  // 1 hour between raids on same territory
	"resources_stolen_percent" = 0.25,  // 25% of resources can be stolen
	"reinforcement_delay" = 60,
	"victory_bonus_xp" = 100,
	"defeat_penalty_xp" = 10
)

// Respawn System
var/list/respawn_config = list(
	"respawn_delay" = 30,
	"respawn_location_type" = "nearest_friendly_territory",
	"xp_loss_on_death" = 0.20,
	"item_loss_on_death" = 0.10,
	"invulnerability_duration" = 10
)

// Helper Procs for Config Access
/proc/GetPvPConfig(config_key)
	return pvp_continent_config[config_key]

/proc/GetTerritoryTierConfig(tier)
	return territory_tier_config[tier]

/proc/GetCombatLevelConfig(level)
	return combat_level_config[level]

/proc/GetEventConfig(event_type)
	return pvp_event_config[event_type]

/proc/GetFactionConfig(faction_id)
	return pvp_faction_config[faction_id]

/proc/GetFortificationCost(fort_type)
	return fortification_costs[fort_type]

/proc/GetResourceYield(resource_type)
	return territory_resource_yields[resource_type]

/proc/GetRaidConfig(key)
	return raid_config[key]

/proc/GetRespawnConfig(key)
	return respawn_config[key]

// PvP Arena Locations (Fixed spawn points for events/raids)
var/list/pvp_arena_locations = list(
	"central_plateau" = list(50, 50, 1),
	"northern_heights" = list(30, 80, 1),
	"southern_swamps" = list(70, 20, 1),
	"eastern_canyons" = list(90, 50, 1),
	"western_forests" = list(10, 50, 1)
)

// Port Location (entry to PvP continent)
var/list/pvp_port_layout = list(
	"entry_point" = list(25, 25, 1),
	"armory" = list(27, 25, 1),
	"tavern" = list(25, 27, 1),
	"faction_halls" = list(30, 30, 1),
	"respawn_chamber" = list(25, 25, 1),
	"arena_entrance" = list(40, 40, 1)
)

// Beginner Guide for PvP Continent
var/list/pvp_beginner_guide = alist(
	1, "Welcome to the Battlelands! This is a full-PvP zone with deadly competition and territorial conflict.",
	2, "Claim a territory to establish your faction base. You'll need 100 Stone + 50 Wood to claim.",
	3, "Build fortifications (walls, towers, gates) to defend your territory from raids.",
	4, "Gain Combat Experience by defeating other players and completing dynamic events.",
	5, "Join a faction (Crimson Legion, Silver Guard, Shadow Guild, or Golden Dawn) for faction-specific bonuses."
)

/proc/ShowPvPBeginnersGuide(mob/player)
	if(!player) return
	
	for(var/step = 1 to pvp_beginner_guide.len)
		player << "PVP [step]. [pvp_beginner_guide[step]]"

/proc/GrantPvPStartingResources(mob/player)
	// Phase 4 deferred - Would grant starting resources for first-time PvP players
	// 200 stone, 200 wood, combat gear
	if(!player) return
	player << "PVP Starting resources Phase 4 not yet implemented"
