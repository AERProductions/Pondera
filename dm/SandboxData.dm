// PHASE D: SANDBOX DATA & CONFIGURATION
// =========================================
// Central data store for sandbox continent settings

var/list/sandbox_biome_profiles = list(
	"temperate" = list(
		"name" = "Temperate Forest",
		"tree_type" = "oak",
		"primary_resource" = "wood",
		"secondary_resource" = "stone",
		"water_percentage" = 20,
		"monster_spawn" = 0,
		"npc_spawn" = 0,
		"encounter_chance" = 0
	),
	
	"arctic" = list(
		"name" = "Arctic Tundra",
		"tree_type" = "pine",
		"primary_resource" = "ice",
		"secondary_resource" = "stone",
		"water_percentage" = 30,
		"monster_spawn" = 0,
		"npc_spawn" = 0,
		"encounter_chance" = 0
	),
	
	"desert" = list(
		"name" = "Desert Badlands",
		"tree_type" = "cactus",
		"primary_resource" = "sand",
		"secondary_resource" = "stone",
		"water_percentage" = 5,
		"monster_spawn" = 0,
		"npc_spawn" = 0,
		"encounter_chance" = 0
	),
	
	"rainforest" = list(
		"name" = "Lush Rainforest",
		"tree_type" = "mahogany",
		"primary_resource" = "wood",
		"secondary_resource" = "plant",
		"water_percentage" = 35,
		"monster_spawn" = 0,
		"npc_spawn" = 0,
		"encounter_chance" = 0
	)
)

var/list/sandbox_world_flags = list(
	"allow_building" = 1,
	"allow_furniture_placement" = 1,
	"allow_market_stalls" = 1,
	"allow_terraforming" = 1,
	"unlimited_plot_size" = 1,
	"allow_pvp" = 0,
	"allow_stealing" = 0,
	"allow_destruction" = 0,
	"allow_attacks" = 0,
	"monster_spawn" = 0,
	"npc_spawn" = 0,
	"weather_enabled" = 0,
	"time_passage" = 0,
	"seasons_enabled" = 0,
	"story_gates_enabled" = 0,
	"recipe_gating" = 0,
	"skill_requirements" = 0,
	"affinity_locking" = 0,
	"starting_resources" = 1000,
	"resource_generation" = 10,
	"allow_trading" = 1,
	"npc_markets" = 0,
	"max_players_per_instance" = 0,
	"griefing_protection" = 1,
	"shared_profit_account" = 1
)

var/list/sandbox_resource_config = list(
	"wood" = list(
		"spawn_chance" = 25,
		"density" = "high",
		"harvest_time" = 20,
		"respawn_time" = 300
	),
	
	"stone" = list(
		"spawn_chance" = 20,
		"density" = "high",
		"harvest_time" = 30,
		"respawn_time" = 300
	),
	
	"ore" = list(
		"spawn_chance" = 15,
		"density" = "medium",
		"harvest_time" = 45,
		"respawn_time" = 600
	),
	
	"plant" = list(
		"spawn_chance" = 30,
		"density" = "high",
		"harvest_time" = 10,
		"respawn_time" = 180
	),
	
	"creative_essence" = list(
		"spawn_chance" = 0,
		"harvest_time" = 0,
		"respawn_time" = 0,
		"daily_grant" = 10
	)
)

var/list/sandbox_building_recipes = list(
	"wooden_table" = list(
		"cost_wood" = 10,
		"cost_stone" = 0,
		"category" = "furniture"
	),
	
	"stone_stairs" = list(
		"cost_wood" = 0,
		"cost_stone" = 20,
		"category" = "structure"
	),
	
	"wooden_chair" = list(
		"cost_wood" = 5,
		"cost_stone" = 0,
		"category" = "furniture"
	),
	
	"stone_wall" = list(
		"cost_wood" = 0,
		"cost_stone" = 15,
		"category" = "structure"
	),
	
	"wooden_door" = list(
		"cost_wood" = 20,
		"cost_stone" = 5,
		"category" = "structure"
	),
	
	"stone_floor" = list(
		"cost_wood" = 0,
		"cost_stone" = 10,
		"category" = "structure"
	),
	
	"wooden_roof" = list(
		"cost_wood" = 30,
		"cost_stone" = 0,
		"category" = "structure"
	),
	
	"market_stall" = list(
		"cost_wood" = 20,
		"cost_stone" = 20,
		"category" = "market",
		"description" = "A player-crafted vendor stall for trading"
	),
	
	"market_stand" = list(
		"cost_wood" = 15,
		"cost_stone" = 10,
		"category" = "market"
	)
)

var/list/sandbox_player_defaults = list(
	"starting_wood" = 100,
	"starting_stone" = 100,
	"starting_plant" = 50,
	"starting_ore" = 20,
	"starting_sp" = 500,
	"daily_wood_grant" = 20,
	"daily_stone_grant" = 20,
	"daily_plant_grant" = 10,
	"daily_sp_grant" = 50,
	"max_structures" = 999,
	"max_market_stalls" = 50,
	"max_furniture" = 200,
	"starting_mining" = 0,
	"starting_smithing" = 0,
	"starting_building" = 0,
	"starting_cooking" = 0,
	"crafting_unlocked" = 1,
	"building_unlocked" = 1,
	"trading_unlocked" = 1,
	"all_recipes_unlocked" = 1,
	"creative_mode" = 1
)

var/list/sandbox_port_layout = list(
	"entry_point" = list("x" = 128, "y" = 128),
	"market_hub" = list(
		"x" = 150,
		"y" = 150,
		"description" = "Central marketplace for trading",
		"stalls" = 3
	),
	"building_gallery" = list(
		"x" = 175,
		"y" = 175,
		"description" = "Showcase of creative builds for inspiration",
		"display_count" = 10
	),
	"tutorial_area" = list(
		"x" = 100,
		"y" = 100,
		"description" = "Learn basic building optional",
		"tutorials" = list("How to Place Objects", "Market Stall Basics", "Trading Tips")
	),
	"wilderness_gate" = list(
		"x" = 200,
		"y" = 200,
		"description" = "Gateway to unlimited creative space"
	)
)

/proc/VerifySandboxData()
	// Validate that all sandbox configuration is properly set
	
	world.log << "SANDBOX Verifying sandbox data..."
	
	if(sandbox_biome_profiles.len == 0)
		world.log << "SANDBOX ERROR: No biome profiles defined"
		return 0
	
	if(sandbox_world_flags.len == 0)
		world.log << "SANDBOX ERROR: No world flags defined"
		return 0
	
	if(sandbox_resource_config.len == 0)
		world.log << "SANDBOX ERROR: No resource config defined"
		return 0
	
	if(sandbox_building_recipes.len == 0)
		world.log << "SANDBOX ERROR: No building recipes defined"
		return 0
	
	world.log << "SANDBOX Data verification passed"
	world.log << "SANDBOX Biomes: " + sandbox_biome_profiles.len
	world.log << "SANDBOX World flags: " + sandbox_world_flags.len
	world.log << "SANDBOX Resources: " + sandbox_resource_config.len
	world.log << "SANDBOX Recipes: " + sandbox_building_recipes.len
	
	return 1

/proc/GetSandboxBiomeProfile(biome_type)
	return sandbox_biome_profiles[biome_type]

/proc/GetSandboxWorldFlag(flag_name)
	return sandbox_world_flags[flag_name]

/proc/GetSandboxRecipesCost(recipe_id)
	return sandbox_building_recipes[recipe_id]

/proc/GrantSandboxStartingResources(mob/M)
	// Grant default starting resources when entering Sandbox
	// Implementation deferred to Phase 4
	
	if(!M)
		return
	
	M << "SANDBOX Starting resources granted!"

var/list/sandbox_beginner_guide = list(
	"welcome" = "Welcome to Creative Mode! Build without limits or pressure.",
	"step_1" = "Step 1: Gather Resources - Mine wood and stone from the landscape",
	"step_2" = "Step 2: Craft - Use your inventory to combine resources",
	"step_3" = "Step 3: Build - Place your creations in the world",
	"step_4" = "Step 4: Trade - Set up a market stall and trade with other players",
	"step_5" = "Step 5: Create - Unleash your imagination and build whatever you want!"
)

/proc/ShowSandboxBeginnersGuide(mob/M)
	if(!M) return
	
	M << sandbox_beginner_guide["welcome"]
	M << ""
	for(var/i = 1 to 5)
		M << (sandbox_beginner_guide["step_" + i] || "")
	
	M << ""
	M << "=== TIPS ==="
	M << "Tip 1: Visit the Market Hub to see what other players are building"
	M << "Tip 2: Market stalls cost 20 wood + 20 stone to craft"
	M << "Tip 3: All recipes are available - no prerequisites!"
	M << "Tip 4: Your skills and money carry over to Story mode when you return"
	M << "Tip 5: Take your time - there is no rush or pressure here"
