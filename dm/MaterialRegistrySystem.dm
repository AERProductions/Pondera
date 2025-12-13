/**
 * MaterialRegistrySystem.dm
 * Phase 16a: Material Registry & Continent-Specific Configuration
 * 
 * Purpose: Centralized material definitions per continent
 * - Defines which materials are mineable/craftable per continent
 * - Configures smelting recipes per continent
 * - Gateways for territory-based material availability
 * - Integrates with TerritoryResourceAvailability.dm
 * 
 * Architecture:
 * - /datum/material_config: Single material definition
 * - /datum/continent_material_registry: Per-continent material system
 * - Global: material_registries (indexed by continent)
 * - Integration points: Recipe system, crafting, smelting, trading
 * 
 * Tick Schedule:
 * - T+396: Material registry initialization
 * - T+397: Recipe gating per continent
 * - T+398: Territory material distribution
 */

// Global material registry container (indexed by continent name)
var/list/material_registries = list()

// MATERIAL DEFINITIONS
// ============================================================================

/datum/material_config
	var
		name = ""
		tier = 1
		mineable = FALSE
		smeltable = FALSE
		craftable = FALSE
		
		// Mining info
		ore_name = ""
		ore_to_ingot_ratio = 1
		minimum_mining_level = 1
		
		// Smelting info
		requires_furnace = FALSE
		furnace_type = ""
		smelting_time_ticks = 100
		
		// Crafting info
		base_damage = 0
		armor_ac = 0
		durability = 100
		weight = 1
		
		// Economy info
		base_price = 100
		rarity = "common"
		
		// Descriptions
		description = ""

/proc/CreateMaterial(name, tier, mineable, smeltable, craftable)
	var/datum/material_config/mat = new()
	mat.name = name
	mat.tier = tier
	mat.mineable = mineable
	mat.smeltable = smeltable
	mat.craftable = craftable
	return mat

// ============================================================================
// CONTINENT MATERIAL REGISTRY
// ============================================================================

/datum/continent_material_registry
	var
		continent_name = ""
		
		// Materials available in this continent
		list/materials = list()
		list/mineable_materials = list()
		list/craftable_materials = list()
		list/smeltable_materials = list()
		
		// Smelting recipes (continent-specific)
		list/smelting_recipes = list()
		
		// Crafting restrictions (by player level/story progress)
		list/level_gates = list()
		list/location_gates = list()
		
		// Territory material distribution
		list/territory_materials = list()
		
		// Availability modifiers
		material_abundance = 1.0
		crafting_cost_modifier = 1.0

/proc/InitializeMaterialRegistries()
	/**
	 * InitializeMaterialRegistries()
	 * Create all continent-specific material registries
	 * Called during world initialization
	 */
	
	world.log << "MATERIALS: Initializing material registries for all continents"
	
	// Create global registry container
	material_registries = list()
	InitializeSandboxMaterials()
	InitializeStoryMaterials()
	InitializePvPMaterials()
	
	world.log << "MATERIALS: Material registries initialized"

/proc/InitializeSandboxMaterials()
	/**
	 * InitializeSandboxMaterials()
	 * Sandbox continent: FULL material complexity (9 materials)
	 * Creative mode = all materials available, no restrictions
	 */
	
	var/datum/continent_material_registry/registry = new()
	registry.continent_name = "sandbox"
	registry.material_abundance = 2.0
	registry.crafting_cost_modifier = 0.5
	
	// Create all 9 materials
	var/datum/material_config/stone = CreateMaterial("Stone", 1, TRUE, FALSE, TRUE)
	stone.ore_name = "Stone"
	stone.description = "Basic building material, easiest to mine"
	stone.base_price = 10
	stone.armor_ac = 1
	stone.base_damage = 1
	stone.minimum_mining_level = 1
	registry.materials += stone
	registry.mineable_materials += stone
	registry.craftable_materials += stone
	
	var/datum/material_config/copper = CreateMaterial("Copper", 2, TRUE, TRUE, TRUE)
	copper.ore_name = "Copper Ore"
	copper.ore_to_ingot_ratio = 2
	copper.description = "Soft metal, good for early armor and decorative items"
	copper.base_price = 50
	copper.armor_ac = 2
	copper.base_damage = 2
	copper.minimum_mining_level = 5
	copper.requires_furnace = TRUE
	copper.furnace_type = "basic_furnace"
	registry.materials += copper
	registry.mineable_materials += copper
	registry.smeltable_materials += copper
	registry.craftable_materials += copper
	
	var/datum/material_config/tin = CreateMaterial("Tin", 2, TRUE, TRUE, TRUE)
	tin.ore_name = "Tin Ore"
	tin.ore_to_ingot_ratio = 2
	tin.description = "Soft metal used in bronze alloys"
	tin.base_price = 60
	tin.armor_ac = 1
	tin.base_damage = 1
	tin.minimum_mining_level = 5
	tin.requires_furnace = TRUE
	tin.furnace_type = "basic_furnace"
	registry.materials += tin
	registry.mineable_materials += tin
	registry.smeltable_materials += tin
	registry.craftable_materials += tin
	
	var/datum/material_config/lead = CreateMaterial("Lead", 2, TRUE, TRUE, TRUE)
	lead.ore_name = "Lead Ore"
	lead.ore_to_ingot_ratio = 3
	lead.description = "Heavy soft metal, used in specialty alloys"
	lead.base_price = 40
	lead.armor_ac = 2
	lead.base_damage = 1
	lead.weight = 1.5
	lead.minimum_mining_level = 10
	lead.requires_furnace = TRUE
	lead.furnace_type = "basic_furnace"
	registry.materials += lead
	registry.mineable_materials += lead
	registry.smeltable_materials += lead
	registry.craftable_materials += lead
	
	var/datum/material_config/zinc = CreateMaterial("Zinc", 2, TRUE, TRUE, TRUE)
	zinc.ore_name = "Zinc Ore"
	zinc.ore_to_ingot_ratio = 2
	zinc.description = "Metal used in brass alloys, good corrosion resistance"
	zinc.base_price = 55
	zinc.armor_ac = 2
	zinc.base_damage = 1
	zinc.minimum_mining_level = 10
	zinc.requires_furnace = TRUE
	zinc.furnace_type = "basic_furnace"
	registry.materials += zinc
	registry.mineable_materials += zinc
	registry.smeltable_materials += zinc
	registry.craftable_materials += zinc
	
	var/datum/material_config/iron = CreateMaterial("Iron", 3, TRUE, TRUE, TRUE)
	iron.ore_name = "Iron Ore"
	iron.ore_to_ingot_ratio = 3
	iron.description = "Strong metal, foundation of most weapons and armor"
	iron.base_price = 100
	iron.armor_ac = 3
	iron.base_damage = 3
	iron.minimum_mining_level = 15
	iron.requires_furnace = TRUE
	iron.furnace_type = "basic_furnace"
	registry.materials += iron
	registry.mineable_materials += iron
	registry.smeltable_materials += iron
	registry.craftable_materials += iron
	
	var/datum/material_config/bronze = CreateMaterial("Bronze", 3, FALSE, TRUE, TRUE)
	bronze.description = "Copper + Tin alloy, durable and decorative"
	bronze.base_price = 180
	bronze.armor_ac = 3
	bronze.base_damage = 3
	bronze.rarity = "uncommon"
	bronze.requires_furnace = TRUE
	bronze.furnace_type = "basic_furnace"
	registry.materials += bronze
	registry.smeltable_materials += bronze
	registry.craftable_materials += bronze
	// Add smelting recipe: Bronze = Copper Ingot + Tin Ingot
	registry.smelting_recipes["Bronze"] = list("Copper"=1, "Tin"=1)
	
	var/datum/material_config/brass = CreateMaterial("Brass", 3, FALSE, TRUE, TRUE)
	brass.description = "Copper + Zinc alloy, excellent for decorative work"
	brass.base_price = 170
	brass.armor_ac = 2
	brass.base_damage = 2
	brass.rarity = "uncommon"
	brass.requires_furnace = TRUE
	brass.furnace_type = "basic_furnace"
	registry.materials += brass
	registry.smeltable_materials += brass
	registry.craftable_materials += brass
	// Add smelting recipe: Brass = Copper Ingot + Zinc Ingot
	registry.smelting_recipes["Brass"] = list("Copper"=1, "Zinc"=1)
	
	var/datum/material_config/steel = CreateMaterial("Steel", 4, FALSE, TRUE, TRUE)
	steel.description = "Iron + Carbon alloy, strongest common metal"
	steel.base_price = 300
	steel.armor_ac = 5
	steel.base_damage = 5
	steel.durability = 150
	steel.rarity = "rare"
	steel.minimum_mining_level = 40
	steel.requires_furnace = TRUE
	steel.furnace_type = "advanced_foundry"
	steel.smelting_time_ticks = 200
	registry.materials += steel
	registry.smeltable_materials += steel
	registry.craftable_materials += steel
	// Add smelting recipe: Steel = 5 Iron Ingot + 3 Activated Carbon
	registry.smelting_recipes["Steel"] = list("Iron"=5, "Carbon"=3)
	
	// Store in global registry
	material_registries["sandbox"] = registry
	world.log << "MATERIALS: Sandbox registry initialized (9 materials)"

/proc/InitializeStoryMaterials()
	/**
	 * InitializeStoryMaterials()
	 * Story continent: MODERATE complexity (5 materials)
	 * Materials gated by player level to create progression
	 */
	
	var/datum/continent_material_registry/registry = new()
	registry.continent_name = "story"
	registry.material_abundance = 1.0
	registry.crafting_cost_modifier = 1.0
	
	// Stone: Always available (tier 1)
	var/datum/material_config/stone = CreateMaterial("Stone", 1, TRUE, FALSE, TRUE)
	stone.ore_name = "Stone"
	stone.description = "Basic material available everywhere"
	stone.base_price = 10
	stone.armor_ac = 1
	stone.minimum_mining_level = 1
	registry.materials += stone
	registry.mineable_materials += stone
	registry.craftable_materials += stone
	registry.level_gates["Stone"] = 1
	
	// Copper: Level 15+ (tier 2)
	var/datum/material_config/copper = CreateMaterial("Copper", 2, TRUE, TRUE, TRUE)
	copper.ore_name = "Copper Ore"
	copper.ore_to_ingot_ratio = 2
	copper.description = "Available to miners level 15+"
	copper.base_price = 50
	copper.armor_ac = 2
	copper.minimum_mining_level = 15
	copper.requires_furnace = TRUE
	copper.furnace_type = "basic_furnace"
	registry.materials += copper
	registry.mineable_materials += copper
	registry.smeltable_materials += copper
	registry.craftable_materials += copper
	registry.level_gates["Copper"] = 15
	
	// Tin: Level 15+ (tier 2, paired with Copper for Bronze)
	var/datum/material_config/tin = CreateMaterial("Tin", 2, TRUE, TRUE, TRUE)
	tin.ore_name = "Tin Ore"
	tin.ore_to_ingot_ratio = 2
	tin.description = "Available to miners level 15+"
	tin.base_price = 60
	tin.minimum_mining_level = 15
	tin.requires_furnace = TRUE
	tin.furnace_type = "basic_furnace"
	registry.materials += tin
	registry.mineable_materials += tin
	registry.smeltable_materials += tin
	registry.craftable_materials += tin
	registry.level_gates["Tin"] = 15
	
	// Iron: Level 25+ (tier 3, main mid-game material)
	var/datum/material_config/iron = CreateMaterial("Iron", 3, TRUE, TRUE, TRUE)
	iron.ore_name = "Iron Ore"
	iron.ore_to_ingot_ratio = 3
	iron.description = "Available to miners level 25+"
	iron.base_price = 100
	iron.armor_ac = 3
	iron.base_damage = 3
	iron.minimum_mining_level = 25
	iron.requires_furnace = TRUE
	iron.furnace_type = "basic_furnace"
	registry.materials += iron
	registry.mineable_materials += iron
	registry.smeltable_materials += iron
	registry.craftable_materials += iron
	registry.level_gates["Iron"] = 25
	
	// Bronze: Level 25+ (crafting only, requires Copper + Tin)
	var/datum/material_config/bronze = CreateMaterial("Bronze", 3, FALSE, TRUE, TRUE)
	bronze.description = "Crafted from Copper + Tin at level 25+"
	bronze.base_price = 180
	bronze.armor_ac = 3
	bronze.base_damage = 3
	bronze.rarity = "uncommon"
	bronze.requires_furnace = TRUE
	bronze.furnace_type = "basic_furnace"
	registry.materials += bronze
	registry.smeltable_materials += bronze
	registry.craftable_materials += bronze
	registry.smelting_recipes["Bronze"] = list("Copper"=1, "Tin"=1)
	registry.level_gates["Bronze"] = 25
	
	// Steel: Level 40+ (endgame, quest-locked or rare spawn)
	var/datum/material_config/steel = CreateMaterial("Steel", 4, FALSE, TRUE, TRUE)
	steel.description = "Endgame material, available at level 40+"
	steel.base_price = 300
	steel.armor_ac = 5
	steel.base_damage = 5
	steel.durability = 150
	steel.rarity = "rare"
	steel.minimum_mining_level = 40
	steel.requires_furnace = TRUE
	steel.furnace_type = "advanced_foundry"
	steel.smelting_time_ticks = 200
	registry.materials += steel
	registry.smeltable_materials += steel
	registry.craftable_materials += steel
	registry.smelting_recipes["Steel"] = list("Iron"=5, "Carbon"=3)
	registry.level_gates["Steel"] = 40
	
	// Store in global registry
	material_registries["story"] = registry
	world.log << "MATERIALS: Story registry initialized (6 materials, level-gated)"

/proc/InitializePvPMaterials()
	/**
	 * InitializePvPMaterials()
	 * PvP continent: SIMPLIFIED complexity (4 materials)
	 * Territory-dependent availability, no smelting chains
	 * Focus on Stone/Copper/Iron/Steel progression
	 */
	
	var/datum/continent_material_registry/registry = new()
	registry.continent_name = "pvp"
	registry.material_abundance = 1.0
	registry.crafting_cost_modifier = 1.5
	
	// Stone: Ubiquitous (tier 1, starter)
	var/datum/material_config/stone = CreateMaterial("Stone", 1, TRUE, FALSE, TRUE)
	stone.ore_name = "Stone"
	stone.description = "Starter material, abundant everywhere"
	stone.base_price = 15
	stone.armor_ac = 1
	stone.minimum_mining_level = 1
	registry.materials += stone
	registry.mineable_materials += stone
	registry.craftable_materials += stone
	
	// Copper: Mid-tier (tier 2, armor focus)
	var/datum/material_config/copper = CreateMaterial("Copper", 2, TRUE, TRUE, TRUE)
	copper.ore_name = "Copper Ore"
	copper.ore_to_ingot_ratio = 2
	copper.description = "Mid-tier armor material, territory-dependent"
	copper.base_price = 75
	copper.armor_ac = 2
	copper.minimum_mining_level = 1
	copper.requires_furnace = TRUE
	copper.furnace_type = "basic_furnace"
	registry.materials += copper
	registry.mineable_materials += copper
	registry.smeltable_materials += copper
	registry.craftable_materials += copper
	
	// Iron: Primary (tier 3, weapons focus)
	var/datum/material_config/iron = CreateMaterial("Iron", 3, TRUE, TRUE, TRUE)
	iron.ore_name = "Iron Ore"
	iron.ore_to_ingot_ratio = 3
	iron.description = "Primary warfare material, valuable trade commodity"
	iron.base_price = 150
	iron.armor_ac = 3
	iron.base_damage = 3
	iron.minimum_mining_level = 1
	iron.requires_furnace = TRUE
	iron.furnace_type = "basic_furnace"
	registry.materials += iron
	registry.mineable_materials += iron
	registry.smeltable_materials += iron
	registry.craftable_materials += iron
	
	// Steel: Endgame (tier 4, ultra-rare, high-value raid target)
	var/datum/material_config/steel = CreateMaterial("Steel", 4, FALSE, TRUE, TRUE)
	steel.description = "Endgame warfare material, strategic resource"
	steel.base_price = 450
	steel.armor_ac = 5
	steel.base_damage = 5
	steel.durability = 150
	steel.rarity = "epic"
	steel.requires_furnace = TRUE
	steel.furnace_type = "advanced_foundry"
	steel.smelting_time_ticks = 200
	registry.materials += steel
	registry.smeltable_materials += steel
	registry.craftable_materials += steel
	// Steel recipe simplified: 5 Iron Ingot → 1 Steel (no Carbon requirement in PvP)
	registry.smelting_recipes["Steel"] = list("Iron"=5)
	
	// Store in global registry
	material_registries["pvp"] = registry
	world.log << "MATERIALS: PvP registry initialized (4 materials, territory-dependent)"

// ============================================================================
// MATERIAL LOOKUP FUNCTIONS
// ============================================================================

/proc/GetMaterialRegistry(continent_name)
	/**
	 * GetMaterialRegistry(continent_name)
	 * Get registry for specific continent
	 * Returns: /datum/continent_material_registry or null
	 */
	
	if(!material_registries)
		InitializeMaterialRegistries()
	
	return material_registries[continent_name]

/proc/GetMaterial(continent_name, material_name)
	/**
	 * GetMaterial(continent_name, material_name)
	 * Get specific material from continent
	 * Returns: /datum/material_config or null
	 */
	
	var/datum/continent_material_registry/registry = GetMaterialRegistry(continent_name)
	if(!registry) return null
	
	for(var/datum/material_config/mat in registry.materials)
		if(mat.name == material_name)
			return mat
	
	return null

/proc/CanMineInContinent(continent_name, material_name, player_level)
	/**
	 * CanMineInContinent(continent_name, material_name, player_level)
	 * Check if material can be mined in continent at player's level
	 * Returns: TRUE if mineable, FALSE otherwise
	 */
	
	var/datum/continent_material_registry/registry = GetMaterialRegistry(continent_name)
	if(!registry) return FALSE
	
	var/datum/material_config/mat = GetMaterial(continent_name, material_name)
	if(!mat || !mat.mineable) return FALSE
	
	// Check level gate
	var/required_level = registry.level_gates[material_name] || 1
	if(player_level < required_level) return FALSE
	
	// Check location gate (if any)
	if(registry.location_gates[material_name])
		// Would check player's current location
		// Framework: location gating ready for implementation
		return FALSE  // Placeholder
	
	return TRUE

/proc/CanCraftWithMaterial(continent_name, material_name, player_level)
	/**
	 * CanCraftWithMaterial(continent_name, material_name, player_level)
	 * Check if material can be used for crafting
	 * Returns: TRUE if craftable, FALSE otherwise
	 */
	
	var/datum/continent_material_registry/registry = GetMaterialRegistry(continent_name)
	if(!registry) return FALSE
	
	var/datum/material_config/mat = GetMaterial(continent_name, material_name)
	if(!mat || !mat.craftable) return FALSE
	
	// Check level gate
	var/required_level = registry.level_gates[material_name] || 1
	if(player_level < required_level) return FALSE
	
	return TRUE

/proc/GetSmeltingRecipe(continent_name, output_material)
	/**
	 * GetSmeltingRecipe(continent_name, output_material)
	 * Get smelting recipe for material in continent
	 * Returns: list("material"=quantity) or null
	 */
	
	var/datum/continent_material_registry/registry = GetMaterialRegistry(continent_name)
	if(!registry) return null
	
	return registry.smelting_recipes[output_material]

/proc/GetMaterialPrice(continent_name, material_name)
	/**
	 * GetMaterialPrice(continent_name, material_name)
	 * Get current price of material in continent
	 * Includes continent modifier
	 * Returns: lucre price
	 */
	
	var/datum/continent_material_registry/registry = GetMaterialRegistry(continent_name)
	var/datum/material_config/mat = GetMaterial(continent_name, material_name)
	
	if(!registry || !mat) return 0
	
	// Base price * continent modifier
	return mat.base_price * registry.crafting_cost_modifier

// ============================================================================
// INITIALIZATION
// ============================================================================

/proc/InitializeMaterialRegistry()
	/**
	 * InitializeMaterialRegistry()
	 * Called from InitializationManager.dm at T+396
	 * Sets up all material registries
	 */
	
	InitializeMaterialRegistries()
	
	world.log << "MATERIALS: Material registry system initialized"
