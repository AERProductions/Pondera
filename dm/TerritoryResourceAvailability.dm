/**
 * TerritoryResourceAvailability.dm
 * Phase 12c: Territory Control & Resource Availability
 * 
 * Features:
 * - Link deed ownership to resource pricing
 * - Territory owners control supply/demand
 * - Resource harvesting limits per territory
 * - Owner tax revenue from merchant activity
 * - Contested territories have reduced supply
 * - Territory wars affect market prices
 * 
 * Integration:
 * - Works with DeedSystem.dm (territory ownership)
 * - Works with EnhancedDynamicMarketPricingSystem.dm (pricing)
 * - Works with NPCMerchantSystem.dm (merchant activity)
 * - Works with procedural generation (resource spawning)
 */

// ============================================================================
// TERRITORY RESOURCE DATA
// ============================================================================

/datum/territory_resource_impact
	/**
	 * territory_resource_impact
	 * Tracks how territory ownership affects resource availability and pricing
	 */
	var
		// Territory identification
		territory_name = "Unknown Territory"
		territory_id = null
		deed_owner = null                    // Player/faction who owns territory
		
		// Resource definition
		primary_resource = "stone"           // Main resource this territory produces
		list/secondary_resources = list()    // Other resources available here
		list/restricted_resources = list()   // Owner-only resources
		
		// Supply control
		unclaimed_base_price = 1.0           // Price when nobody owns it
		claimed_multiplier = 1.0             // 0.7-1.5x when owned (affects all prices)
		supply_capacity = 100                // Max units available per day
		current_supply = 0                   // Units available now
		respawn_rate = 10                    // Units restored per hour
		harvested_today = 0                  // Track daily harvesting
		
		// Taxation
		controller_tax_rate = 0.1            // 10% of trades go to owner
		owner_tax_revenue = 0                // Accumulated tax
		tax_collection_interval = 100        // Ticks between collection
		last_tax_collection = 0
		
		// Territory state
		is_contested = FALSE                 // TRUE if multiple claims or raid
		contested_multiplier = 0.5           // Contested = half supply
		last_contested_time = 0              // When contest started
		contest_duration = 6000              // 5 minutes real time

/proc/CreateTerritoryResource(territory_name, primary_resource, capacity = 100)
	/**
	 * CreateTerritoryResource(territory_name, primary_resource, capacity)
	 * Creates a new territory resource tracking entry
	 * Returns: /datum/territory_resource_impact
	 */
	var/datum/territory_resource_impact/territory = new /datum/territory_resource_impact()
	
	territory.territory_name = territory_name
	territory.territory_id = "[territory_name]_[world.time]"
	territory.primary_resource = primary_resource
	territory.supply_capacity = capacity
	territory.current_supply = capacity / 2  // Start at half capacity
	territory.unclaimed_base_price = GetCommodityPrice(primary_resource)
	
	return territory

// ============================================================================
// TERRITORY OWNERSHIP & CONTROL
// ============================================================================

/datum/territory_resource_impact/proc/ClaimTerritory(new_owner, multiplier = 1.0)
	/**
	 * ClaimTerritory(new_owner, multiplier)
	 * Owner claims this territory
	 * multiplier: 0.7-1.5 (affects price based on owner's deed tier)
	 * Returns: TRUE if claimed successfully
	 */
	if(!new_owner) return FALSE
	
	deed_owner = new_owner
	claimed_multiplier = clamp(multiplier, 0.7, 1.5)
	
	world.log << "TERRITORY: [territory_name] claimed by [new_owner]"
	return TRUE

/datum/territory_resource_impact/proc/ReleaseTerritory()
	/**
	 * ReleaseTerritory()
	 * Owner loses claim to territory
	 * Reverts to unclaimed pricing
	 */
	if(deed_owner)
		world.log << "TERRITORY: [territory_name] released by [deed_owner]"
	
	deed_owner = null
	claimed_multiplier = 1.0
	is_contested = FALSE
	return TRUE

/datum/territory_resource_impact/proc/IsOwned()
	/**
	 * IsOwned()
	 * Check if territory has an owner
	 */
	return deed_owner != null

/datum/territory_resource_impact/proc/GetOwner()
	/**
	 * GetOwner()
	 * Returns current deed owner
	 */
	return deed_owner

// ============================================================================
// RESOURCE SUPPLY MANAGEMENT
// ============================================================================

/datum/territory_resource_impact/proc/GetResourcePrice(commodity_name)
	/**
	 * GetResourcePrice(commodity_name)
	 * Returns price for resource in this territory
	 * Takes ownership and contest status into account
	 */
	if(!commodity_name) return 0
	
	var/market_price = GetCommodityPrice(commodity_name)
	if(market_price <= 0) market_price = 1.0
	
	// Base multiplier from owner (0.7-1.5)
	var/multiplier = 1.0
	if(IsOwned())
		multiplier = claimed_multiplier
	
	// Contest reduces supply (and raises prices)
	if(is_contested)
		multiplier *= contested_multiplier
		multiplier *= 1.5  // Contested = 50% more expensive
	
	return round(market_price * multiplier, 0.01)

/datum/territory_resource_impact/proc/GetMaxResourceAvailable(commodity_name)
	/**
	 * GetMaxResourceAvailable(commodity_name)
	 * Returns maximum units available for harvest
	 * Contested territories have reduced availability
	 */
	if(!commodity_name) return 0
	
	var/available = current_supply
	
	// Contested territories have reduced supply
	if(is_contested)
		available = round(available * contested_multiplier)
	
	// Owner can limit supply (price control)
	if(IsOwned() && commodity_name == primary_resource)
		// Owner can artificially limit supply to drive prices up
		// Or increase supply to drive competitors out
		// For now, multiplier affects it
		available = round(available * claimed_multiplier)
	
	return available

/datum/territory_resource_impact/proc/HarvestResource(player, commodity_name, amount)
	/**
	 * HarvestResource(player, commodity_name, amount)
	 * Player harvests resources from this territory
	 * Returns: amount actually harvested, 0 if failed
	 */
	if(!player || !commodity_name || amount <= 0) return 0
	
	// Check daily limit
	if(harvested_today + amount > supply_capacity)
		amount = max(0, supply_capacity - harvested_today)
	
	if(amount <= 0) return 0
	
	// Check available supply
	var/available = GetMaxResourceAvailable(commodity_name)
	amount = min(amount, available)
	
	// Execute harvest
	current_supply -= amount
	harvested_today += amount
	
	// Update market supply
	UpdateCommoditySupply(commodity_name, amount * -0.2)  // Reduce market supply
	
	// Owner gets tax revenue
	if(IsOwned())
		var/harvest_price = GetResourcePrice(commodity_name)
		var/tax = harvest_price * amount * controller_tax_rate
		owner_tax_revenue += tax
	
	return amount

/datum/territory_resource_impact/proc/RespawnSupply()
	/**
	 * RespawnSupply()
	 * Restore resource supply (called periodically, ~every hour)
	 */
	// Respawn based on rate
	current_supply = min(current_supply + respawn_rate, supply_capacity)
	harvested_today = max(0, harvested_today - respawn_rate)  // Daily harvest decays
	
	// Respawn bonus for owned territories (owner invested)
	if(IsOwned())
		current_supply = min(current_supply + (respawn_rate * 0.5), supply_capacity)

/datum/territory_resource_impact/proc/RefreshDaily()
	/**
	 * RefreshDaily()
	 * Reset daily harvest limits (called once per game day)
	 */
	harvested_today = 0
	world.log << "TERRITORY: [territory_name] refreshed daily limits"

// ============================================================================
// TERRITORY CONTEST & RAIDING
// ============================================================================

/datum/territory_resource_impact/proc/ContestTerritory()
	/**
	 * ContestTerritory()
	 * Mark territory as contested (under dispute/raid)
	 * Reduces supply and raises prices temporarily
	 */
	is_contested = TRUE
	last_contested_time = world.time
	
	world.log << "TERRITORY: [territory_name] is now CONTESTED"
	
	// Schedule automatic resolution
	spawn(contest_duration)
		ResolveContest()

/datum/territory_resource_impact/proc/ResolveContest()
	/**
	 * ResolveContest()
	 * Resolve contest after duration expires
	 * Returns to normal if not re-contested
	 */
	if(!is_contested) return  // Already resolved
	
	is_contested = FALSE
	world.log << "TERRITORY: [territory_name] contest resolved"

/datum/territory_resource_impact/proc/IsContested()
	/**
	 * IsContested()
	 * Check if territory is under dispute
	 */
	return is_contested

// ============================================================================
// TERRITORY TAXATION & REVENUE
// ============================================================================

/datum/territory_resource_impact/proc/CollectTaxes()
	/**
	 * CollectTaxes()
	 * Collect accumulated taxes and distribute to owner
	 * Called periodically by maintenance loop
	 */
	if(!IsOwned() || owner_tax_revenue <= 0) return 0
	
	var/tax_amount = owner_tax_revenue
	owner_tax_revenue = 0
	
	world.log << "TERRITORY: [territory_name] collected [tax_amount] lucre for [deed_owner]"
	
	return tax_amount

/datum/territory_resource_impact/proc/GetTaxRevenue()
	/**
	 * GetTaxRevenue()
	 * Returns accumulated but uncollected tax revenue
	 */
	return owner_tax_revenue

/datum/territory_resource_impact/proc/SetTaxRate(rate)
	/**
	 * SetTaxRate(rate)
	 * Owner sets tax rate (0.0-0.2, 0-20%)
	 */
	controller_tax_rate = clamp(rate, 0.0, 0.2)

// ============================================================================
// MERCHANT ACTIVITY TAXATION
// ============================================================================

/proc/ApplyTerritoryTaxToMerchantTrade(territory_name, item_name, quantity, trade_price)
	/**
	 * ApplyTerritoryTaxToMerchantTrade(territory_name, item_name, quantity, trade_price)
	 * Tax merchant trading activity in a territory
	 * Called when merchant buys/sells items
	 * Framework: Implement with territory registry system
	 */
	var/tax = trade_price * quantity * 0.1  // Default 10% tax
	world.log << "TAX: Territory [territory_name] gained [tax] lucre from [item_name] trade"
	return tax

// ============================================================================
// TERRITORY RESOURCE IMPACT INTEGRATION
// ============================================================================

/proc/InitializeTerritoryResourceSystem()
	/**
	 * InitializeTerritoryResourceSystem()
	 * Sets up territory resource availability system
	 */
	
	// Create territories for major resource locations
	CreateDefaultTerritories()
	
	// Start maintenance loop
	spawn() TerritoryMaintenanceLoop()
	
	world.log << "TERRITORY_SYSTEM: Resource impact system initialized"

/proc/CreateDefaultTerritories()
	/**
	 * CreateDefaultTerritories()
	 * Creates default territories for major resources
	 */
	
	// Stone quarries
	var/datum/territory_resource_impact/stone_quarry = CreateTerritoryResource("Stone Quarry", "Stone", 200)
	if(stone_quarry)
		stone_quarry.secondary_resources = list("Flint", "Clay")
	
	// Iron mines
	var/datum/territory_resource_impact/iron_mine = CreateTerritoryResource("Iron Mine", "Iron Ore", 150)
	if(iron_mine)
		iron_mine.secondary_resources = list("Iron Ingot", "Coal")
	
	// Forests
	var/datum/territory_resource_impact/forest = CreateTerritoryResource("Ancient Forest", "Wood", 180)
	if(forest)
		forest.secondary_resources = list("Branches", "Bark", "Herbs")
	
	// Fishing grounds
	var/datum/territory_resource_impact/fishing = CreateTerritoryResource("Fishing Grounds", "Fish", 120)
	if(fishing)
		fishing.secondary_resources = list("Fish Oil", "Pearls")
	
	world.log << "TERRITORY_SYSTEM: Created 4 default territories"

/proc/TerritoryMaintenanceLoop()
	/**
	 * TerritoryMaintenanceLoop()
	 * Periodic maintenance for all territories
	 * Respawns supply, collects taxes, updates contests
	 */
	set background = 1
	set waitfor = 0
	
	var/respawn_interval = 360   // ~1 hour game time
	var/daily_interval = 2400    // ~1 game day
	var/tax_interval = 100       // Frequent collection
	
	var/last_respawn = world.time
	var/last_daily = world.time
	var/last_tax = world.time
	
	while(1)
		sleep(30)
		
		// Respawn supply hourly
		if(world.time - last_respawn >= respawn_interval)
			last_respawn = world.time
			// Would iterate through all territories and respawn
		
		// Reset daily limits
		if(world.time - last_daily >= daily_interval)
			last_daily = world.time
			// Would iterate through all territories and refresh
		
		// Collect taxes regularly
		if(world.time - last_tax >= tax_interval)
			last_tax = world.time
			// Would collect taxes from all territories

/proc/GetTerritoryByName(territory_name)
	/**
	 * GetTerritoryByName(territory_name)
	 * Looks up territory by name
	 * Currently returns NULL (needs global registry)
	 */
	// This would look up from a global territory registry
	// For now, returns null - framework for future
	return null

/proc/GetTerritoryByDeed(deed)
	/**
	 * GetTerritoryByDeed(deed)
	 * Gets territories owned by a deed
	 * Returns list of territories
	 */
	var/list/owned_territories = list()
	// This would search all territories for matching deed_owner
	// For now, returns empty list - framework for future
	return owned_territories

/proc/GetResourcePriceInTerritory(territory_name, commodity_name)
	/**
	 * GetResourcePriceInTerritory(territory_name, commodity_name)
	 * Gets price for resource in specific territory
	 * Framework: Implement with territory registry system
	 */
	// For now, return base commodity price
	return GetCommodityPrice(commodity_name)

/proc/HarvestResourceInTerritory(player, territory_name, commodity_name, amount)
	/**
	 * HarvestResourceInTerritory(player, territory_name, commodity_name, amount)
	 * Player harvests from territory with taxation
	 * Framework: Implement with territory registry system
	 */
	world.log << "HARVEST: [territory_name] harvested [amount] [commodity_name]"
	return amount

// ============================================================================
// TERRITORY WARFARE INTEGRATION (Framework)
// ============================================================================

/proc/RaidTerritory(raider_faction, territory_name)
	/**
	 * RaidTerritory(raider_faction, territory_name)
	 * Triggers raid on named territory (from combat/PvP system)
	 * Framework: Implement in territory registry system
	 */
	world.log << "RAID: [raider_faction] is raiding [territory_name]"
	return TRUE

/proc/DefeatRaid(territory_name)
	/**
	 * DefeatRaid(territory_name)
	 * Owner defeats raid, territory returned to normal
	 * Framework: Implement in territory registry system
	 */
	world.log << "RAID: Raid on [territory_name] defeated"
	return TRUE

/proc/ConquerTerritory(conquering_faction, territory_name)
	/**
	 * ConquerTerritory(conquering_faction, territory_name)
	 * One faction conquers another's territory
	 * Framework: Implement in territory registry system
	 */
	world.log << "CONQUEST: [territory_name] conquered by [conquering_faction]"
	return TRUE

// ============================================================================
// TERRITORY STATUS & ANALYTICS
// ============================================================================

/datum/territory_resource_impact/proc/GetTerritoryStatus()
	/**
	 * GetTerritoryStatus()
	 * Returns comprehensive territory status
	 */
	var/list/status = list(
		"name" = territory_name,
		"owner" = deed_owner || "Unclaimed",
		"primary_resource" = primary_resource,
		"current_supply" = current_supply,
		"supply_capacity" = supply_capacity,
		"is_contested" = is_contested,
		"resource_price" = GetResourcePrice(primary_resource),
		"tax_revenue" = owner_tax_revenue,
		"daily_harvested" = harvested_today,
		"daily_capacity" = supply_capacity
	)
	
	return status

/datum/territory_resource_impact/proc/DisplayTerritoryInfo()
	/**
	 * DisplayTerritoryInfo()
	 * Returns formatted territory information
	 */
	var/info = ""
	info += "═════════════════════════════════════════\n"
	info += "[territory_name]\n"
	info += "═════════════════════════════════════════\n"
	
	if(IsOwned())
		info += "Owner: [deed_owner]\n"
		info += "Tax Revenue: [owner_tax_revenue] lucre\n"
	else
		info += "Status: UNCLAIMED\n"
	
	if(IsContested())
		info += "Status: UNDER RAID\n"
	
	info += "\nResources:\n"
	info += "  [primary_resource]: [current_supply]/[supply_capacity]\n"
	info += "  Price: [GetResourcePrice(primary_resource)] lucre\n"
	
	if(secondary_resources.len > 0)
		info += "  Secondary: [secondary_resources.Join(", ")]\n"
	
	info += "\nDaily Harvest: [harvested_today]/[supply_capacity]\n"
	info += "═════════════════════════════════════════\n"
	
	return info
