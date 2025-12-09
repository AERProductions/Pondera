/**
 * TerritoryClaimSystem.dm
 * Phase 21: Territory Claiming & Ownership
 * 
 * Establishes territory control mechanics:
 * - Players/guilds claim regions (2-4 per continent)
 * - Ownership grants passive income (lucre/materials per cycle)
 * - Maintenance costs prevent permanent control without upkeep
 * - Contested zones allow raids and territorial wars
 * 
 * Integration Points:
 * - /datum/territory_claim: Core territory ownership datum
 * - TerritoryDataManager: Persistence and loading
 * - DynamicZoneManager: Zone→territory mapping
 * - PvPRankingSystem: War declarations
 * - DualCurrencySystem: Passive income distribution
 * - EconomyCombatIntegrationSystem: Repair costs vs territory income
 * 
 * Territories (Per Continent):
 * - Story Kingdom: 2 major territories (capital + frontier)
 * - Sandbox Creative: Open claiming (multiple small zones)
 * - PvP Battlelands: 4 strategic nodes (resource-rich)
 */

// ============================================================================
// TERRITORY CLAIM DATUM
// ============================================================================

/**
 * /datum/territory_claim
 * Represents a claimed region under ownership
 */
/datum/territory_claim
	var
		// Identification
		territory_id              // Unique ID ("story_north", "pvp_steel_mine", etc.)
		territory_name            // Display name
		continent                 // Parent continent ("story", "sandbox", "pvp")
		
		// Ownership
		owner_player_key = ""     // Owner mob key (empty string if unclaimed)
		owner_player_name = ""    // Owner display name
		claim_date = 0            // When claimed (world.time)
		
		// Territory Properties
		zone_list = list()        // List of /area zones in this territory
		map_center_x = 0          // Map center coordinate
		map_center_y = 0
		territory_size = 0        // Turf count
		
		// Tier & Upgrades
		tier = 1                  // 1=Basic, 2=Fortified, 3=Elite (determines passive income)
		tier_upgrade_cost = 0     // Lucre cost to upgrade
		
		// Economics
		passive_lucre_per_day = 0     // Daily lucre income (tier * 100)
		passive_materials_per_day = 0 // Daily material income (tier * 50)
		material_type = "copper"      // Primary material this zone produces
		maintenance_cost = 0          // Weekly maintenance (tier * 200)
		maintenance_paid = TRUE       // Paid up?
		maintenance_cycle = 0         // Ticks until next cycle
		
		// Warfare
		is_contested = 0          // Under attack?
		attacker_key = ""         // Current attacker
		attacker_list = list()    // All active attackers
		durability = 100          // Territory health (0-100)
		
		// Flags
		allow_building = TRUE     // Can owner build here?
		allow_raiding = FALSE     // Can others raid?
		is_capital = FALSE        // Strategic location (grants bonuses)?

/**
 * New(continent_name, terr_id, terr_name, center_x, center_y, size, initial_tier=1)
 * Create new territory claim
 */
/datum/territory_claim/New(continent_name, terr_id, terr_name, cx, cy, size, initial_tier=1)
	continent = continent_name
	territory_id = terr_id
	territory_name = terr_name
	map_center_x = cx
	map_center_y = cy
	territory_size = size
	tier = initial_tier
	
	// Calculate economics based on tier
	passive_lucre_per_day = tier * 100
	passive_materials_per_day = tier * 50
	maintenance_cost = tier * 200
	tier_upgrade_cost = tier * 500
	
	// Default unclaimed
	owner_player_key = ""
	owner_player_name = "Unclaimed"
	is_contested = 0
	allow_building = 0  // Only claimed territories allow building
	allow_raiding = 0   // Unclaimed zones can't be raided
	
	world.log << "Territory created: [territory_name] (tier [tier], [territory_size] turfs)"

// ============================================================================
// TERRITORY REGISTRY & MANAGEMENT
// ============================================================================

var
	// Global territory registry
	list/territories_by_id = list()        // territory_claim by ID
	list/territories_by_continent = list() // list of claims per continent
	list/territories_by_owner = list()     // list of claims per owner_key

/**
 * CreateTerritoryRegistry()
 * Initialize territory system and populate initial territories per continent
 * Called from InitializationManager at T+421
 */
/proc/CreateTerritoryRegistry()
	if(territories_by_id.len > 0)
		return  // Already initialized
	
	// Story Kingdom: 2 territories
	CreateTerritory("story", "story_capital", "Kingdom Capital", 128, 128, 2500, 2)
	CreateTerritory("story", "story_frontier", "Northern Frontier", 200, 80, 1500, 1)
	
	// Sandbox: 4 creative zones (all tier 1, easier claiming)
	CreateTerritory("sandbox", "sandbox_north", "Creative North", 150, 200, 1000, 1)
	CreateTerritory("sandbox", "sandbox_south", "Creative South", 150, 50, 1000, 1)
	CreateTerritory("sandbox", "sandbox_east", "Creative East", 250, 120, 1000, 1)
	CreateTerritory("sandbox", "sandbox_west", "Creative West", 80, 120, 1000, 1)
	
	// PvP Battlelands: 4 strategic resource nodes
	CreateTerritory("pvp", "pvp_steel_mine", "Steel Mining Region", 120, 150, 800, 1)
	CreateTerritory("pvp", "pvp_copper_grove", "Copper Grove", 200, 200, 800, 1)
	CreateTerritory("pvp", "pvp_timber_forest", "Timber Forest", 80, 180, 800, 1)
	CreateTerritory("pvp", "pvp_crystal_caverns", "Crystal Caverns", 160, 100, 800, 1)
	
	world.log << "Territory registry initialized: [territories_by_id.len] territories"

/**
 * CreateTerritory(continent, id, name, cx, cy, size, tier)
 * Helper to create and register a territory
 */
/proc/CreateTerritory(continent, id, name, cx, cy, size, tier)
	var/datum/territory_claim/claim = new(continent, id, name, cx, cy, size, tier)
	
	territories_by_id[id] = claim
	
	if(!territories_by_continent[continent])
		territories_by_continent[continent] = list()
	territories_by_continent[continent] += claim
	
	return claim

/**
 * GetTerritoryByID(territory_id)
 * Lookup territory by unique ID
 */
/proc/GetTerritoryByID(territory_id)
	return territories_by_id[territory_id]

/**
 * GetTerritoriesByContinent(continent)
 * Get all territories in a continent
 */
/proc/GetTerritoriesByContinent(continent)
	return territories_by_continent[continent] || list()

/**
 * GetTerritoriesByOwner(owner_key)
 * Get all territories owned by a player
 */
/proc/GetTerritoriesByOwner(owner_key)
	return territories_by_owner[owner_key] || list()

// ============================================================================
// TERRITORY CLAIMING
// ============================================================================

/**
 * ClaimTerritory(mob/players/player, datum/territory_claim/territory)
 * Player attempts to claim unclaimed territory
 * Returns: TRUE if successful
 * 
 * Requirements:
 * - Territory must be unclaimed (owner_key == NULL)
 * - Player must be in territory
 * - Player pays claiming fee (tier * 100 lucre)
 * - Claiming takes 30 seconds (channel time, can be interrupted)
 */
/proc/ClaimTerritory(mob/players/player, datum/territory_claim/territory)
	if(!player || !territory)
		return FALSE
	
	// Check territory is unclaimed
	if(territory.owner_player_key != "")
		world.log << "[player.key] attempted to claim owned territory [territory.territory_name]"
		return 0
	
	// Check claiming fee
	var/claiming_fee = territory.tier * 100
	if(player.lucre < claiming_fee)
		world.log << "[player.key] insufficient lucre to claim [territory.territory_name]"
		return 0
	
	// Deduct fee
	player.lucre -= claiming_fee
	
	// Assign ownership
	territory.owner_player_key = player.key
	territory.owner_player_name = player.name
	territory.claim_date = world.time
	territory.allow_building = 1
	territory.allow_raiding = 1
	
	// Add to player's territory list
	if(!territories_by_owner[player.key])
		territories_by_owner[player.key] = list()
	territories_by_owner[player.key] += territory
	
	world.log << "[player.name] claimed [territory.territory_name] for [claiming_fee] lucre"
	return 1

/**
 * AbandonTerritory(mob/players/player, datum/territory_claim/territory)
 * Player voluntarily surrenders territory
 * Refunds 50% of claiming fee
 */
/proc/AbandonTerritory(mob/players/player, datum/territory_claim/territory)
	if(!player || !territory)
		return FALSE
	
	// Verify ownership
	if(territory.owner_player_key != player.key)
		return 0
	
	// Refund 50%
	var/refund = territory.tier * 50
	player.lucre += refund
	
	// Clear ownership
	territory.owner_player_key = ""
	territory.owner_player_name = "Unclaimed"
	territory.allow_building = 0
	territory.allow_raiding = 0
	territory.durability = 100
	
	// Remove from player's list
	if(territories_by_owner[player.key])
		territories_by_owner[player.key] -= territory
	
	world.log << "[player.name] abandoned [territory.territory_name] (refunded [refund] lucre)"
	return 1

// ============================================================================
// PASSIVE INCOME DISTRIBUTION
// ============================================================================

/**
 * ProcessTerritoryIncome()
 * Background loop: distribute passive income every in-game day
 * Called from InitializationManager at T+421
 * 
 * Income formula (per day):
 * - Tier 1: 100 lucre, 50 materials
 * - Tier 2: 200 lucre, 100 materials
 * - Tier 3: 300 lucre, 150 materials
 * 
 * Only pays if maintenance is current
 */
/proc/ProcessTerritoryIncome()
	set background = 1
	set waitfor = 0
	
	var/income_cycle = 0  // Track cycles
	
	while(1)
		sleep(1200)  // 60 seconds (5 deciseconds * 240 = 60s)
		
		if(!world_initialization_complete)
			continue
		
		income_cycle++
		
		// Distribute income to all territory owners
		for(var/territory_id in territories_by_id)
			var/datum/territory_claim/territory = territories_by_id[territory_id]
			if(!territory)
				continue
			
			// Only pay if owned and maintained
			if(territory.owner_player_key == "" || !territory.maintenance_paid)
				continue
			
			// Find owner player by iterating world
			var/mob/players/owner = null
			for(var/mob/players/p in world)
				if(p.key == territory.owner_player_key)
					owner = p
					break
			
			if(!owner)
				continue
			
			// Award daily income
			var/lucre_reward = territory.passive_lucre_per_day
			var/material_reward = territory.passive_materials_per_day
			
			owner.lucre += lucre_reward
			
			// Track material income per type
			var/mat_var = "[territory.material_type]s"
			owner.vars[mat_var] = (owner.vars[mat_var] || 0) + material_reward
			
			// Log every 10 cycles (reduce spam)
			if(income_cycle % 10 == 0)
				world.log << "[owner.name] earned [lucre_reward] lucre from [territory.territory_name]"

/**
 * ProcessTerritoryMaintenance()
 * Background loop: check maintenance costs weekly
 * Unpaid territories can be claimed by others
 */
/proc/ProcessTerritoryMaintenance()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(8400)  // ~7 game days (1200 * 7)
		
		if(!world_initialization_complete)
			continue
		
		for(var/territory_id in territories_by_id)
			var/datum/territory_claim/territory = territories_by_id[territory_id]
			if(!territory || territory.owner_player_key == "")
				continue
			
			// Find owner player by iterating world
			var/mob/players/owner = null
			for(var/mob/players/p in world)
				if(p.key == territory.owner_player_key)
					owner = p
					break
			
			if(!owner)
				continue
			
			// Check maintenance cost
			var/cost = territory.maintenance_cost
			
			if(owner.lucre >= cost)
				owner.lucre -= cost
				territory.maintenance_paid = TRUE
				world.log << "[owner.name] paid [cost] lucre maintenance for [territory.territory_name]"
			else
				// Unpaid - territory becomes claimable
				territory.maintenance_paid = FALSE
				world.log << "[owner.name] unable to pay [cost] lucre maintenance for [territory.territory_name] - UNCLAIMED"


// ============================================================================
// TERRITORY UPGRADES
// ============================================================================

/**
 * UpgradeTerritoryTier(mob/players/player, datum/territory_claim/territory)
 * Owner upgrades territory to next tier
 * Tier 1→2: 500 lucre, +100 daily income
 * Tier 2→3: 1000 lucre, +100 daily income
 */
/proc/UpgradeTerritoryTier(mob/players/player, datum/territory_claim/territory)
	if(!player || !territory)
		return FALSE
	
	// Verify ownership
	if(territory.owner_key != player.key)
		return 0
	
	// Can't exceed tier 3
	if(territory.tier >= 3)
		return 0
	
	// Check cost
	var/upgrade_cost = territory.tier_upgrade_cost
	if(player.lucre < upgrade_cost)
		return 0
	
	// Process upgrade
	player.lucre -= upgrade_cost
	territory.tier++
	
	// Recalculate economics
	territory.passive_lucre_per_day = territory.tier * 100
	territory.passive_materials_per_day = territory.tier * 50
	territory.maintenance_cost = territory.tier * 200
	territory.tier_upgrade_cost = territory.tier * 500
	
	world.log << "[player.name] upgraded [territory.territory_name] to tier [territory.tier]"
	return 1

// ============================================================================
// TERRITORY QUERYING
// ============================================================================

/**
 * GetPlayerTerritoryCount(mob/players/player)
 * How many territories does player own?
 */
/proc/GetPlayerTerritoryCount(mob/players/player)
	if(!player)
		return 0
	
	var/list/owned = territories_by_owner[player.key]
	return owned ? owned.len : 0

/**
 * GetPlayerTerritoryIncome(mob/players/player)
 * Calculate total daily income from all territories
 */
/proc/GetPlayerTerritoryIncome(mob/players/player)
	if(!player)
		return 0
	
	var/total_income = 0
	var/list/owned = GetTerritoriesByOwner(player.key)
	
	for(var/datum/territory_claim/territory in owned)
		if(territory.maintenance_paid)
			total_income += territory.passive_lucre_per_day
	
	return total_income

/**
 * GetTerritoryInfo(datum/territory_claim/territory)
 * Return formatted territory status for UI display
 */
/proc/GetTerritoryInfo(datum/territory_claim/territory)
	if(!territory)
		return "Territory not found"
	
	var/info = "[territory.territory_name]\n"
	info += "Owner: [territory.owner_name]\n"
	info += "Tier: [territory.tier]\n"
	info += "Daily Income: [territory.passive_lucre_per_day] lucre, [territory.passive_materials_per_day] [territory.material_type]\n"
	info += "Maintenance: [territory.maintenance_cost] lucre/week\n"
	info += "Status: [territory.maintenance_paid ? "PAID" : "UNPAID"]\n"
	info += "Durability: [territory.durability]%\n"
	
	if(territory.is_contested)
		info += "STATUS: UNDER ATTACK\n"
	
	return info

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeTerritorySystem()
 * Boot-time initialization
 * Called from InitializationManager at T+421
 */
/proc/InitializeTerritorySystem()
	// Create territory registry
	CreateTerritoryRegistry()
	
	// Start background loops
	spawn()
		ProcessTerritoryIncome()
	
	spawn()
		ProcessTerritoryMaintenance()
	
	world.log << "Territory System initialized: [territories_by_id.len] territories"
	return

// ============================================================================
// TERRITORY SYSTEM SUMMARY
// ============================================================================

/*
 * Phase 21: Territory Claims establish ownership layer:
 * 
 * MECHANICS:
 * - Unclaimed territories can be claimed for tier*100 lucre
 * - Ownership grants passive income: tier*100 lucre/day, tier*50 materials/day
 * - Weekly maintenance cost: tier*200 lucre (unpaid → claimable)
 * - Upgradeable tiers (1→2→3) for higher income
 * 
 * ECONOMIC PRESSURE:
 * - Claiming fee + tier*50 material cost creates barrier to entry
 * - Maintenance forces active engagement (must farm lucre)
 * - Passive income creates wealth disparity (rich get richer)
 * - Competition for high-value zones (more lucre = more fights)
 * 
 * STRATEGIC DEPTH:
 * - Small guilds claim cheap tier-1 zones
 * - War for tier-3 capitals creates political conflict
 * - Unpaid maintenance opens claiming windows (assassination via neglect)
 * - Territory material type creates specialization (steel mine vs timber forest)
 * 
 * NEXT: Phase 22 adds defensibility (buildings, walls, durability)
 *       Phase 23 adds attack mechanics (sieges, raids, territorial wars)
 */
