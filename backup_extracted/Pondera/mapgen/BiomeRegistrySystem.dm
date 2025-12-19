// ============================================================================
// BIOME REGISTRY SYSTEM - Consolidated Biome Configuration
// ============================================================================
/*
 * BiomeRegistrySystem.dm - Refactored biome management (12-12-25)
 * 
 * Improvements over scattered biome_*.dm files:
 * - Centralized resource spawn probabilities (lookup table instead of if-chains)
 * - Unified biome definition (tile type, border, sound effects, resource pools)
 * - Per-continent biome assignment (story/sandbox/pvp can have different biomes)
 * - Cached location checks (avoid O(n) repeated locate() calls)
 * - Integration with ProceduralChunkingSystem for per-chunk generation
 * - Season/month awareness via helper functions
 * 
 * Architecture:
 *   /datum/biome_definition - Single biome config (resources, spawn rates)
 *   /datum/biome_registry - Global registry mapping "temperate" -> /datum/biome_definition
 *   BiomeSpawnResource(turf, biome_name) - Entry point for chunk generation
 */

// ============================================================================
// SEASON/MONTH HELPERS
// ============================================================================

/proc/IsWinter()
	return global.season == "Winter"

/proc/IsSpawnable()
	// Check if current season allows resource spawning
	return !IsWinter() && month != "Tevet"

// ============================================================================
// RESOURCE SPAWN POOL
// ============================================================================

/datum/resource_spawn_entry
	var/resource_type  // Path to object type
	var/probability = 1.0  // Spawn chance (0.0-1.0)
	var/weight = 1  // Relative weight for weighted selection

/datum/resource_spawn_entry/New(type, prob = 1.0, wt = 1)
	..()
	resource_type = type
	probability = prob
	weight = wt

// ============================================================================
// BIOME DEFINITION
// ============================================================================

/datum/biome_definition
	var/name = "Generic"
	var/turf_type = /turf/temperate
	var/border_type = /obj/border/temperate
	var/icon = 'dmi/64/gen.dmi'
	var/icon_state = "grass"
	var/elevation_offset = 1
	var/list/sound_effects = list()
	var/list/winter_sound_effects = list()
	var/list/water_sound_effects = list()
	
	// Resource spawn pools (weighted)
	var/list/ore_spawns = list()  // Ore rocks
	var/list/plant_spawns = list()  // Trees/shrubs
	var/list/flower_spawns = list()  // Decorative flowers
	var/list/deposit_spawns = list()  // Soil, tar, clay, etc.
	
	// Spawn probabilities (can be overridden per biome)
	var/ore_chance = 0.3
	var/tree_chance = 1.02
	var/flower_chance = 0.5
	var/deposit_chance = 0.03
	var/spawnpoint_chance = 0.01
	
	// Cache for frequently used lookups
	var/list/ore_cache = list()
	var/list/tree_cache = list()

/datum/biome_definition/proc/Initialize()
	// Build caches for efficient lookups
	ore_cache = list()
	tree_cache = list()
	
	for(var/datum/resource_spawn_entry/e in ore_spawns)
		ore_cache += e.resource_type
	for(var/datum/resource_spawn_entry/e in plant_spawns)
		tree_cache += e.resource_type

/datum/biome_definition/proc/SpawnOreAtTurf(turf/t)
	// Spawn a random ore from this biome's ore pool
	if(!ore_cache.len) return
	if(!prob(ore_chance)) return
	
	var/ore_type = pick(ore_cache)
	new ore_type(t)

/datum/biome_definition/proc/SpawnTreeAtTurf(turf/t)
	// Spawn trees with density caching to avoid expensive lookups
	if(!tree_cache.len) return
	if(!prob(tree_chance)) return
	
	// Use a single locate() call with all possible types
	var/existing_tree = locate(ore_cache | tree_cache) in t
	if(existing_tree) return
	
	var/tree_type = pick(tree_cache)
	new tree_type(t)

/datum/biome_definition/proc/SpawnFloralAtTurf(turf/t)
	// Spawn flowers and decorative plants
	if(!flower_spawns.len) return
	if(!prob(flower_chance)) return
	
	var/datum/resource_spawn_entry/flower_entry = pick(flower_spawns)
	new flower_entry.resource_type(t)

/datum/biome_definition/proc/SpawnDepositsAtTurf(turf/t)
	// Spawn soil, tar, clay, obsidian
	if(!deposit_spawns.len) return
	if(!prob(deposit_chance)) return
	
	var/datum/resource_spawn_entry/deposit_entry = pick(deposit_spawns)
	new deposit_entry.resource_type(t)

/datum/biome_definition/proc/SpawnResourcesOnTurf(turf/t)
	// Main entry point: spawn all resource types on a single turf
	if(!t || !t.spawn_resources) return
	
	// Ores (high spawn rate)
	SpawnOreAtTurf(t)
	
	// Trees (medium spawn rate)
	SpawnTreeAtTurf(t)
	
	// Flowers/decorations (low spawn rate)
	SpawnFloralAtTurf(t)
	
	// Soil/special deposits (low spawn rate)
	SpawnDepositsAtTurf(t)
	
	// Spawnpoints (very rare)
	if(prob(spawnpoint_chance))
		new /obj/spawns/spawnpointB2(t)

// ============================================================================
// BIOME REGISTRY
// ============================================================================

var/datum/biome_registry/BIOME_REGISTRY = null

/datum/biome_registry
	var/list/biomes = list()  // "temperate" -> /datum/biome_definition

/datum/biome_registry/proc/Register(name, datum/biome_definition/def)
	biomes[name] = def
	def.Initialize()

/datum/biome_registry/proc/Get(name)
	return biomes[name]

/datum/biome_registry/proc/GetAll()
	return biomes

// ============================================================================
// INITIALIZE BIOME SYSTEM
// ============================================================================

/proc/InitializeBiomeRegistry()
	// Called during world init; sets up all biomes
	if(BIOME_REGISTRY) return
	
	BIOME_REGISTRY = new /datum/biome_registry()
	
	// TEMPERATE BIOME
	var/datum/biome_definition/temperate = new /datum/biome_definition()
	temperate.name = "Temperate"
	temperate.turf_type = /turf/temperate
	temperate.border_type = /obj/border/temperate
	temperate.icon_state = "grass"
	temperate.elevation_offset = 1
	temperate.sound_effects = list(/obj/snd/sfx/apof/forestbirds)
	temperate.winter_sound_effects = list()
	temperate.water_sound_effects = list(/obj/snd/sfx/river)
	temperate.ore_chance = 0.3
	temperate.tree_chance = 1.02
	temperate.flower_chance = 0.5
	temperate.deposit_chance = 0.03
	
	// Ore spawns for temperate
	temperate.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/IRocks, 0.3)
	temperate.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/ZRocks, 0.1)
	temperate.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/CRocks, 0.1)
	temperate.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/LRocks, 0.1)
	temperate.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/SRocks, 0.2)
	
	// Tree spawns for temperate
	temperate.plant_spawns += new /datum/resource_spawn_entry(/obj/plant/UeikTreeA, 0.5)
	temperate.plant_spawns += new /datum/resource_spawn_entry(/obj/plant/UeikTreeH, 0.5)
	temperate.plant_spawns += new /datum/resource_spawn_entry(/obj/plant/ueiktree, 0.3)
	
	// Flowers for temperate
	temperate.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Blueflower)
	temperate.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Lightpurpflower)
	temperate.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Pinkflower)
	temperate.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Purpflower)
	temperate.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Redflower)
	temperate.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Tallgrass)
	
	// Deposits for temperate
	temperate.deposit_spawns += new /datum/resource_spawn_entry(/turf/TarPit, 0.05)
	temperate.deposit_spawns += new /datum/resource_spawn_entry(/turf/ClayDeposit, 0.03)
	temperate.deposit_spawns += new /datum/resource_spawn_entry(/turf/ObsidianField, 0.02)
	temperate.deposit_spawns += new /datum/resource_spawn_entry(/turf/Sand2, 0.02)
	temperate.deposit_spawns += new /datum/resource_spawn_entry(/obj/Soil/richsoil, 0.03)
	temperate.deposit_spawns += new /datum/resource_spawn_entry(/obj/Soil/soil, 0.04)
	
	BIOME_REGISTRY.Register("temperate", temperate)
	
	// ARCTIC BIOME
	var/datum/biome_definition/arctic = new /datum/biome_definition()
	arctic.name = "Arctic"
	arctic.turf_type = /turf/snow
	arctic.border_type = /obj/border/snow
	arctic.icon_state = "snow"
	arctic.elevation_offset = 1
	arctic.sound_effects = list()
	arctic.winter_sound_effects = list()
	arctic.water_sound_effects = list()
	arctic.ore_chance = 0.3
	arctic.tree_chance = 2.02
	arctic.flower_chance = 0.5
	arctic.deposit_chance = 0.04
	
	// Ore spawns for arctic
	arctic.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/IRocks, 0.3)
	arctic.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/ZRocks, 0.1)
	arctic.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/CRocks, 0.1)
	arctic.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/LRocks, 0.1)
	arctic.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/SRocks, 0.2)
	
	// Plant spawns for arctic (bushes instead of large trees)
	arctic.plant_spawns += new /datum/resource_spawn_entry(/obj/Plants/Bush/Raspberrybush, 0.3)
	arctic.plant_spawns += new /datum/resource_spawn_entry(/obj/Plants/Bush/Blueberrybush, 0.3)
	arctic.plant_spawns += new /datum/resource_spawn_entry(/obj/plant/ueiktree, 0.4)
	
	// Flowers for arctic
	arctic.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Blueflower, 0.5)
	arctic.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Lightpurpflower, 0.5)
	arctic.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Pinkflower, 0.5)
	arctic.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Purpflower, 0.5)
	arctic.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Redflower, 0.7)
	arctic.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Tallgrass, 1.0)
	
	// Deposits for arctic
	arctic.deposit_spawns += new /datum/resource_spawn_entry(/turf/TarPit, 0.05)
	arctic.deposit_spawns += new /datum/resource_spawn_entry(/turf/ClayDeposit, 0.03)
	arctic.deposit_spawns += new /datum/resource_spawn_entry(/turf/ObsidianField, 0.02)
	arctic.deposit_spawns += new /datum/resource_spawn_entry(/turf/Sand2, 0.02)
	arctic.deposit_spawns += new /datum/resource_spawn_entry(/obj/Soil/richsoil, 0.03)
	arctic.deposit_spawns += new /datum/resource_spawn_entry(/obj/Soil/soil, 0.04)
	
	BIOME_REGISTRY.Register("arctic", arctic)
	
	// DESERT BIOME
	var/datum/biome_definition/desert = new /datum/biome_definition()
	desert.name = "Desert"
	desert.turf_type = /turf/sand
	desert.border_type = /obj/border/sand
	desert.icon_state = "grass"  // Reuses temperate icon
	desert.elevation_offset = 1
	desert.sound_effects = list()
	desert.winter_sound_effects = list()
	desert.water_sound_effects = list()
	desert.ore_chance = 0.25  // Fewer ores in desert
	desert.tree_chance = 0.5  // Fewer trees
	desert.flower_chance = 0.3
	desert.deposit_chance = 0.05  // More deposits
	
	// Ore spawns for desert
	desert.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/IRocks, 0.3)
	desert.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/ZRocks, 0.1)
	desert.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/CRocks, 0.1)
	desert.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/LRocks, 0.1)
	desert.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/SRocks, 0.2)
	
	// Plant spawns for desert (cacti, sparse bushes)
	desert.plant_spawns += new /datum/resource_spawn_entry(/obj/Plants/Bush/Raspberrybush, 0.15)
	desert.plant_spawns += new /datum/resource_spawn_entry(/obj/Plants/Bush/Blueberrybush, 0.15)
	desert.plant_spawns += new /datum/resource_spawn_entry(/obj/plant/ueiktree, 0.2)
	
	// Flowers for desert (fewer)
	desert.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Pinkflower, 0.2)
	desert.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Redflower, 0.3)
	
	// Deposits for desert (sand, clay, tar)
	desert.deposit_spawns += new /datum/resource_spawn_entry(/turf/TarPit, 0.08)
	desert.deposit_spawns += new /datum/resource_spawn_entry(/turf/ClayDeposit, 0.05)
	desert.deposit_spawns += new /datum/resource_spawn_entry(/turf/ObsidianField, 0.03)
	desert.deposit_spawns += new /datum/resource_spawn_entry(/turf/Sand2, 0.1)
	desert.deposit_spawns += new /datum/resource_spawn_entry(/obj/Soil/soil, 0.02)
	
	BIOME_REGISTRY.Register("desert", desert)
	
	// RAINFOREST BIOME
	var/datum/biome_definition/jungle = new /datum/biome_definition()
	jungle.name = "Rainforest"
	jungle.turf_type = /turf/jungle
	jungle.border_type = /obj/border/jungle
	jungle.icon_state = "drkgrss"
	jungle.elevation_offset = 1
	jungle.sound_effects = list()
	jungle.winter_sound_effects = list()
	jungle.water_sound_effects = list()
	jungle.ore_chance = 0.2  // Fewer ores (dense vegetation)
	jungle.tree_chance = 2.5  // Many more trees
	jungle.flower_chance = 0.8  // More flowers
	jungle.deposit_chance = 0.02  // Fewer deposits
	
	// Ore spawns for jungle
	jungle.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/IRocks, 0.3)
	jungle.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/ZRocks, 0.1)
	jungle.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/CRocks, 0.1)
	jungle.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/LRocks, 0.1)
	jungle.ore_spawns += new /datum/resource_spawn_entry(/obj/Rocks/OreRocks/SRocks, 0.2)
	
	// Plant spawns for jungle (dense)
	jungle.plant_spawns += new /datum/resource_spawn_entry(/obj/plant/UeikTreeA, 0.6)
	jungle.plant_spawns += new /datum/resource_spawn_entry(/obj/plant/UeikTreeH, 0.6)
	jungle.plant_spawns += new /datum/resource_spawn_entry(/obj/plant/ueiktree, 0.5)
	
	// Flowers for jungle (lush)
	jungle.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Blueflower, 0.8)
	jungle.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Lightpurpflower, 0.8)
	jungle.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Pinkflower, 0.8)
	jungle.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Purpflower, 0.8)
	jungle.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Redflower, 1.0)
	jungle.flower_spawns += new /datum/resource_spawn_entry(/obj/Flowers/Tallgrass, 1.2)
	
	// Deposits for jungle (rich soil)
	jungle.deposit_spawns += new /datum/resource_spawn_entry(/turf/TarPit, 0.03)
	jungle.deposit_spawns += new /datum/resource_spawn_entry(/turf/ClayDeposit, 0.02)
	jungle.deposit_spawns += new /datum/resource_spawn_entry(/obj/Soil/richsoil, 0.05)
	jungle.deposit_spawns += new /datum/resource_spawn_entry(/obj/Soil/soil, 0.06)
	
	BIOME_REGISTRY.Register("jungle", jungle)
	
	world << "BiomeRegistry initialized with 4 biomes: temperate, arctic, desert, jungle"

/proc/BiomeSpawnResource(turf/t, biome_name = "temperate")
	// Main entry point for spawning resources on a turf
	// Called by chunk generation or turf.SpawnResource()
	
	if(!BIOME_REGISTRY)
		InitializeBiomeRegistry()
	
	if(IsWinter() || month == "Tevet")
		// No resource spawning in winter
		return
	
	var/datum/biome_definition/biome = BIOME_REGISTRY.Get(biome_name)
	if(!biome)
		// Fallback to temperate if biome not found
		biome = BIOME_REGISTRY.Get("temperate")
	
	biome.SpawnResourcesOnTurf(t)

/proc/GetBiomeDefinition(biome_name = "temperate")
	// Get biome by name
	if(!BIOME_REGISTRY)
		InitializeBiomeRegistry()
	return BIOME_REGISTRY.Get(biome_name)

/proc/GetAllBiomes()
	// Get all registered biomes
	if(!BIOME_REGISTRY)
		InitializeBiomeRegistry()
	return BIOME_REGISTRY.GetAll()

// ============================================================================
// ADMIN COMMANDS
// ============================================================================

/mob/verb/ViewBiomeRegistry()
	set name = "View Biome Registry"
	set category = "debug"
	
	if(!BIOME_REGISTRY)
		InitializeBiomeRegistry()
	
	src << "=== BIOME REGISTRY ==="
	for(var/biome_name in BIOME_REGISTRY.GetAll())
		var/datum/biome_definition/def = BIOME_REGISTRY.Get(biome_name)
		src << "[biome_name]: [def.name]"
		src << "  Turf: [def.turf_type]"
		src << "  Resources: [def.ore_spawns.len] ore types, [def.plant_spawns.len] plants, [def.flower_spawns.len] flowers, [def.deposit_spawns.len] deposits"

/mob/verb/TestBiomeSpawn()
	set name = "Test Biome Spawn"
	set category = "debug"
	
	if(!src.loc) return
	var/turf/t = src.loc
	if(!istype(t, /turf)) 
		t = locate(/turf) in range(1, src)
	if(!t) return
	
	t.spawn_resources = TRUE
	BiomeSpawnResource(t, "temperate")
	src << "Spawned resources at [t]"
