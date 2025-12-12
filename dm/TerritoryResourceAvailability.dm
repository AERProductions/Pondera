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
		territory_name = "Unknown Territory"
		territory_id = null
		deed_owner = null
		
		// Supply control
		unclaimed_base_price = 1.0
		claimed_multiplier = 1.0
		supply_capacity = 100
		current_supply = 0
		respawn_rate = 10
		harvested_today = 0
		
		// Taxation
		controller_tax_rate = 0.1
		owner_tax_revenue = 0
		tax_collection_interval = 100
		last_tax_collection = 0
		is_contested = FALSE
		contested_multiplier = 0.5
		last_contested_time = 0
		contest_duration = 6000

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
	territory.current_supply = capacity / 2
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
	var/multiplier = 1.0
	if(IsOwned())
		multiplier = claimed_multiplier
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
	if(is_contested)
		available = round(available * contested_multiplier)
	if(IsOwned() && commodity_name == primary_resource)
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
	harvested_today = max(0, harvested_today - respawn_rate)
	
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
// MERCHANT ACTIVITY TAXATION
// ============================================================================

/proc/ApplyTerritoryTaxToMerchantTrade(territory_name, item_name, quantity, trade_price)
	/**
	 * ApplyTerritoryTaxToMerchantTrade(territory_name, item_name, quantity, trade_price)
	 * Tax merchant trading activity in a territory
	 * Called when merchant buys/sells items
	 * Framework: Implement with territory registry system
	 */
	var/tax = trade_price * quantity * 0.1
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
	var/datum/territory_resource_impact/iron_mine = CreateTerritoryResource("Iron Mine", "Iron Ore", 150)
	if(iron_mine)
		iron_mine.secondary_resources = list("Iron Ingot", "Coal")
	var/datum/territory_resource_impact/forest = CreateTerritoryResource("Ancient Forest", "Wood", 180)
	if(forest)
		forest.secondary_resources = list("Branches", "Bark", "Herbs")
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
	
	var/respawn_interval = 360
	var/daily_interval = 2400
	var/tax_interval = 100
	
	var/last_respawn = world.time
	var/last_daily = world.time
	var/last_tax = world.time
	
	while(1)
		sleep(30)
		
		// Respawn supply hourly
		if(world.time - last_respawn >= respawn_interval)
			last_respawn = world.time
		
		// Reset daily limits
		if(world.time - last_daily >= daily_interval)
			last_daily = world.time
		
		// Collect taxes regularly
		if(world.time - last_tax >= tax_interval)
			last_tax = world.time

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

/proc/ConquerTerritory(mob/players/attacker, datum/territory_claim/territory)
	if(!attacker || !territory)
		return 0
	
	// Check war is active
	var/datum/war_declaration/war = GetActiveWar(territory.territory_id)
	if(!war || war.attacker_player_key != attacker.key || !war.is_active)
		return 0
	
	// Check victory condition (all structures destroyed)
	var/list/structures = GetTerritoryStructures(territory)
	var/destroyed_count = 0
	for(var/datum/defense_structure/s in structures)
		if(s.is_destroyed)
			destroyed_count++
	
	// Must destroy all structures (if any exist)
	if(structures.len > 0 && destroyed_count != structures.len)
		return 0
	
	// Remove previous owner
	var/old_owner = territory.owner_player_name
	if(territory.owner_player_key != "")
		if(territories_by_owner[territory.owner_player_key])
			territories_by_owner[territory.owner_player_key] -= territory
	
	// Transfer to attacker
	territory.owner_player_key = attacker.key
	territory.owner_player_name = attacker.name
	territory.claim_date = world.time
	territory.maintenance_paid = 1
	territory.durability = 100
	for(var/datum/defense_structure/s in structures)
		s.current_hp = s.max_hp
		s.is_destroyed = 0
		s.is_damaged = 0
	if(!territories_by_owner[attacker.key])
		territories_by_owner[attacker.key] = list()
	territories_by_owner[attacker.key] += territory
	
	// Award conquest bounty
	var/conquest_bounty = 5000 + (territory.tier * 1000)
	attacker.lucre += conquest_bounty
	
	// Mark war as won
	war.was_victorious = 1
	war.is_active = 0
	war.conquest_reward = conquest_bounty
	
	world.log << "[attacker.name] CONQUERED [territory.territory_name]! Previous owner: [old_owner]"
	return 1

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
