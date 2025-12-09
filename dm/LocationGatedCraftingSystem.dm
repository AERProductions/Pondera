/**
 * LocationGatedCraftingSystem.dm
 * Phase 16b: Location-Gated Crafting & Smelting Locations
 * 
 * Purpose: Implement defensible crafting locations (foundries, furnaces)
 * - Basic Furnace: Stone/Copper/Tin/Lead/Zinc/Bronze/Brass smelting
 * - Advanced Foundry: Steel smelting (high-value, worth raiding)
 * - Integrates with Territory/Deed system for ownership
 * - PvP: Foundries are strategic locations for raiding
 * 
 * Architecture:
 * - /obj/crafting_location: Base crafting structure
 * - /obj/basic_furnace: Standard furnace (common)
 * - /obj/advanced_foundry: Strategic endgame furnace (rare)
 * - Integration: Territory ownership affects access/functionality
 * 
 * Tick Schedule:
 * - T+397: Location-gated crafting system initialization
 * - T+398: Register furnaces in territories
 */

// ============================================================================
// CRAFTING LOCATION BASE CLASS
// ============================================================================

/obj/crafting_location
	/**
	 * crafting_location
	 * Base class for all crafting/smelting locations
	 * Can be owned, captured, or destroyed in PvP
	 */
	name = "Crafting Location"
	desc = "A location for crafting"
	icon = null  // Placeholder - will be set by subclasses
	icon_state = "furnace"
	density = TRUE
	
	var
		location_type = ""       // "basic_furnace", "advanced_foundry", etc.
		continent_name = ""      // Where this is located
		
		// Ownership (deed-linked)
		owner_deed = null        // /datum/deed if claimed
		owner_kingdom = ""       // Kingdom if PvP
		owner_player = null      // Individual player owner
		is_claimed = FALSE       // TRUE if owned, FALSE if neutral
		
		// Production
		list/recipes = list()    // What can be crafted here
		list/crafting_queue = list()  // Queued crafting jobs
		
		// Durability (destruction mechanics)
		health = 100
		max_health = 100
		condition = "perfect"    // perfect, worn, damaged, destroyed
		
		// Access control
		list/allowed_players = list()   // Can use this furnace
		list/allowed_guilds = list()    // Guilds with access
		list/alliance_list = list()     // Allied kingdoms (PvP)
		
		// Stats
		smelting_speed_modifier = 1.0   // Higher = faster production
		quality_modifier = 1.0          // Higher = better quality output
		last_owner_change = 0           // Timestamp of ownership change

/obj/crafting_location/New()
	..()
	// Initialize list variables
	if(!recipes) recipes = list()
	if(!crafting_queue) crafting_queue = list()
	if(!allowed_players) allowed_players = list()
	if(!allowed_guilds) allowed_guilds = list()
	if(!alliance_list) alliance_list = list()
	// Register this crafting location globally
	// Would add to continent's crafting location registry

/obj/crafting_location/Click()
	/**
	 * Click()
	 * Open crafting interface
	 */
	if(!usr)
		return
	
	// Check permissions
	if(!CanUseCraftingLocation(usr, src))
		usr << "<font color=#FF5555>You don't have permission to use this furnace.</font>"
		return
	
	// Open crafting UI
	OpenCraftingInterface(usr, src)

/proc/CanUseCraftingLocation(mob/player, obj/crafting_location/location)
	/**
	 * CanUseCraftingLocation(mob/player, obj/crafting_location/location)
	 * Check if player can use this crafting location
	 * Returns: TRUE if allowed, FALSE otherwise
	 */
	
	if(!player || !location)
		return FALSE
	
	// Unclaimed locations: everyone can use
	if(!location.is_claimed)
		return TRUE
	
	// Claimed location: check ownership/alliance
	// Framework: Would check player.kingdom against location.owner_kingdom
	// For now: allow all players to use claimed locations
	// TODO: Integrate with kingdom system once implemented
	
	return TRUE

/proc/OpenCraftingInterface(mob/player, obj/crafting_location/location)
	/**
	 * OpenCraftingInterface(mob/player, obj/crafting_location/location)
	 * Framework: Open UI for crafting
	 * Would show available recipes and queue
	 */
	
	if(!player || !location)
		return
	
	// Framework: Would display:
	// - Available recipes for this location type
	// - Materials player has available
	// - Crafting queue
	// - Cost in lucre
	
	player << "Opening crafting interface..."

// ============================================================================
// BASIC FURNACE
// ============================================================================

/obj/crafting_location/basic_furnace
	/**
	 * basic_furnace
	 * Standard furnace for basic smelting
	 * Smelts: Stone (pass-through), Copper, Tin, Lead, Zinc, Bronze, Brass
	 * Common in all continents
	 */
	name = "Basic Furnace"
	desc = "A simple furnace for smelting common metals. Produces: Copper, Tin, Lead, Zinc, Bronze, Brass ingots."
	icon = null  // Placeholder
	icon_state = "furnace_basic"
	// All vars inherited from base - location_type handled in New()

/obj/crafting_location/basic_furnace/New()
	..()
	
	// Set location type
	location_type = "basic_furnace"
	
	// Configure recipes for basic furnace
	recipes += "Copper Ingot"    // 2 Copper Ore
	recipes += "Tin Ingot"       // 2 Tin Ore
	recipes += "Lead Ingot"      // 3 Lead Ore
	recipes += "Zinc Ingot"      // 2 Zinc Ore
	recipes += "Bronze Ingot"    // 1 Copper + 1 Tin
	recipes += "Brass Ingot"     // 1 Copper + 1 Zinc
	
	// Continent-specific: Story adds level-gating
	// Continent-specific: PvP simplified

/proc/CreateBasicFurnace(continent, x, y, z, owner_kingdom)
	/**
	 * CreateBasicFurnace(continent, x, y, z, owner_kingdom)
	 * Factory function to create furnace at location
	 */
	
	var/obj/crafting_location/basic_furnace/furnace = new()
	furnace.continent_name = continent
	furnace.x = x
	furnace.y = y
	furnace.z = z
	furnace.owner_kingdom = owner_kingdom
	furnace.is_claimed = (owner_kingdom != "")
	
	return furnace

// ============================================================================
// ADVANCED FOUNDRY
// ============================================================================

/obj/crafting_location/advanced_foundry
	/**
	 * advanced_foundry
	 * Advanced foundry for high-tier smelting
	 * Smelts: Steel only (5 Iron Ingot → 1 Steel Ingot)
	 * RARE - only 1-3 per continent, highly defensible
	 * Worth raiding for in PvP
	 */
	name = "Advanced Foundry"
	desc = "A sophisticated foundry capable of high-temperature smelting. Produces: Steel ingots from iron. Requires: Advanced Foundry access."
	icon = null  // Placeholder
	icon_state = "foundry_advanced"
	density = TRUE
	
	var
		is_strategic_location = TRUE   // Marks as raid target
		siege_defense_level = 5        // How hard to capture (1-10 scale)

/obj/crafting_location/advanced_foundry/New()
	..()
	
	// Set location type
	location_type = "advanced_foundry"
	
	// Configure recipes: Only Steel
	recipes += "Steel Ingot"  // 5 Iron Ingot
	
	// Advanced foundry is high-maintenance
	health = 150
	max_health = 150
	condition = "perfect"

/proc/CreateAdvancedFoundry(continent, x, y, z, owner_kingdom)
	/**
	 * CreateAdvancedFoundry(continent, x, y, z, owner_kingdom)
	 * Factory function - RARE creation (admin/special event only)
	 */
	
	var/obj/crafting_location/advanced_foundry/foundry = new()
	foundry.continent_name = continent
	foundry.x = x
	foundry.y = y
	foundry.z = z
	foundry.owner_kingdom = owner_kingdom
	foundry.is_claimed = (owner_kingdom != "")
	foundry.last_owner_change = world.time
	
	world.log << "FOUNDRY: Advanced foundry created in [continent] for [owner_kingdom]"
	
	return foundry

// ============================================================================
// CRAFTING LOCATION REGISTRY
// ============================================================================

/proc/InitializeLocationGatedCrafting()
	/**
	 * InitializeLocationGatedCrafting()
	 * Called from InitializationManager.dm at T+397
	 * Sets up crafting location registry
	 */
	
	// Create registry (would be indexed by continent and location)
	world.log << "CRAFTING: Location-gated crafting system initialized"
	
	// Would register furnaces based on continent:
	// - Sandbox: Multiple basic furnaces scattered everywhere
	// - Story: Basic furnaces in towns, advanced foundry in endgame zone
	// - PvP: Few basic furnaces (easy to access), 1-2 advanced foundries (worth raiding)

/proc/RegisterCraftingLocation(continent_name, obj/crafting_location/crafting_location)
	/**
	 * RegisterCraftingLocation(continent_name, obj/crafting_location/crafting_location)
	 * Register a crafting location in continent registry
	 */
	
	if(!crafting_location)
		return FALSE
	
	// Framework: Would add to global crafting location registry
	// Indexed by continent and location type
	
	world.log << "CRAFTING: Registered [crafting_location.location_type] in [continent_name]"
	return TRUE

/proc/GetCraftingLocations(continent_name, location_type)
	/**
	 * GetCraftingLocations(continent_name, location_type)
	 * Get all crafting locations of type in continent
	 * Returns: list of /obj/crafting_location
	 */
	
	var/list/locations = list()
	
	// Framework: Would query registry
	// Return locations matching continent and type
	
	return locations

/proc/GetNearestCraftingLocation(mob/player, location_type)
	/**
	 * GetNearestCraftingLocation(mob/player, location_type)
	 * Find nearest crafting location of type
	 * Returns: /obj/crafting_location or null
	 */
	
	if(!player)
		return null
	
	// Framework: Would calculate distance to all nearby furnaces
	// Return closest one
	
	return null

// ============================================================================
// CRAFTING JOBS & QUEUE
// ============================================================================

/datum/crafting_job
	/**
	 * crafting_job
	 * A single crafting job queued at a furnace
	 */
	var
		player_ref            // Who submitted the job
		recipe_name = ""       // What to craft
		quantity = 1           // How many to produce
		
		ingredients = list()   // list("material"=quantity)
		output = ""            // What's produced
		output_quantity = 0
		
		cost_lucre = 0         // Crafting cost
		status = "pending"     // pending, in_progress, complete, failed
		
		started_time = 0
		estimated_completion = 0
		actual_completion = 0
		
		quality_output = 100   // % quality (80-120%)

/proc/QueueCraftingJob(mob/player, obj/crafting_location/location, recipe_name, quantity)
	/**
	 * QueueCraftingJob(mob/player, obj/crafting_location/location, recipe_name, quantity)
	 * Submit a crafting job to a furnace
	 */
	
	if(!player || !location)
		return FALSE
	
	// Check recipe available at location
	if(!(recipe_name in location.recipes))
		player << "This furnace cannot craft [recipe_name]."
		return FALSE
	
	// Check materials
	// Check lucre cost
	// Create job
	var/datum/crafting_job/job = new()
	job.player_ref = player
	job.recipe_name = recipe_name
	job.quantity = quantity
	job.status = "pending"
	job.started_time = world.time
	
	// Add to location queue
	location.crafting_queue += job
	
	world.log << "CRAFTING: [player] queued [recipe_name] at furnace"
	
	return TRUE

/proc/ProcessCraftingQueue(obj/crafting_location/location)
	/**
	 * ProcessCraftingQueue(obj/crafting_location/location)
	 * Process pending crafting jobs at furnace
	 * Called periodically by background loop
	 */
	
	if(!location || !location.crafting_queue.len)
		return
	
	// Framework: Would iterate jobs in queue
	// For each pending job:
	//   - Update status to in_progress
	//   - Calculate completion time
	//   - Check if complete
	//   - If complete: deliver items, remove from queue

/proc/CompleteCraftingJob(datum/crafting_job/job)
	/**
	 * CompleteCraftingJob(datum/crafting_job/job)
	 * Deliver finished crafting job to player
	 */
	
	if(!job || !job.player_ref)
		return FALSE
	
	var/mob/player = job.player_ref
	
	// Framework: Would add items to player inventory
	// Mark job as complete
	// Log completion
	
	player << "Your crafting job is complete!"
	
	return TRUE

// ============================================================================
// FURNACE DESTRUCTION & REPAIRS
// ============================================================================

/proc/DamageCraftingLocation(obj/crafting_location/location, damage_amount)
	/**
	 * DamageCraftingLocation(obj/crafting_location/location, damage_amount)
	 * Damage furnace (in PvP combat or siege)
	 * Lower health = slower production
	 */
	
	if(!location)
		return FALSE
	
	location.health -= damage_amount
	
	// Update condition
	var/health_percent = (location.health / location.max_health) * 100
	
	switch(health_percent)
		if(75 to 100)
			location.condition = "perfect"
		if(50 to 75)
			location.condition = "worn"
			location.smelting_speed_modifier = 0.8  // 20% slower
		if(25 to 50)
			location.condition = "damaged"
			location.smelting_speed_modifier = 0.5  // 50% slower
		if(0 to 25)
			location.condition = "destroyed"
			location.smelting_speed_modifier = 0    // Non-functional
	
	if(location.health <= 0)
		DestroyCraftingLocation(location)
	
	world.log << "CRAFTING: [location.name] damaged (health: [location.health]/[location.max_health])"
	
	return TRUE

/proc/DestroyCraftingLocation(obj/crafting_location/location)
	/**
	 * DestroyCraftingLocation(obj/crafting_location/location)
	 * Destroy furnace (cannot be used until repaired)
	 * Strategic objective in PvP
	 */
	
	if(!location)
		return FALSE
	
	location.health = 0
	location.condition = "destroyed"
	location.smelting_speed_modifier = 0
	
	world.log << "CRAFTING: [location.name] destroyed!"
	
	// Cancel all crafting jobs
	for(var/datum/crafting_job/job in location.crafting_queue)
		job.status = "failed"
	
	location.crafting_queue = list()  // Clear queue
		
	return TRUE

/proc/RepairCraftingLocation(obj/crafting_location/location, lucre_cost)
	/**
	 * RepairCraftingLocation(obj/crafting_location/location, lucre_cost)
	 * Repair damaged furnace
	 * Owner pays lucre
	 */
	
	if(!location || location.health >= location.max_health)
		return FALSE
	
	// Owner pays repair cost
	// Location health restored
	location.health = location.max_health
	location.condition = "perfect"
	location.smelting_speed_modifier = 1.0
	
	world.log << "CRAFTING: [location.name] repaired for [lucre_cost] lucre"
	
	return TRUE

// ============================================================================
// CRAFTING LOCATION OWNERSHIP & CONTROL
// ============================================================================

/proc/ClaimCraftingLocation(obj/crafting_location/location, kingdom_name)
	/**
	 * ClaimCraftingLocation(obj/crafting_location/location, kingdom_name)
	 * Kingdom claims ownership of crafting location
	 */
	
	if(!location)
		return FALSE
	
	location.owner_kingdom = kingdom_name
	location.is_claimed = TRUE
	location.last_owner_change = world.time
	
	world.log << "CRAFTING: [location.name] claimed by [kingdom_name]"
	
	// If advanced foundry: record strategic importance
	if(istype(location, /obj/crafting_location/advanced_foundry))
		world.log << "STRATEGIC: Advanced foundry now under [kingdom_name] control!"
	
	return TRUE

/proc/TransferCraftingLocation(obj/crafting_location/location, from_kingdom, to_kingdom)
	/**
	 * TransferCraftingLocation(obj/crafting_location/location, from_kingdom, to_kingdom)
	 * Change ownership (capture, conquest, trade)
	 */
	
	if(!location)
		return FALSE
	
	world.log << "CRAFTING: [location.name] transferred from [from_kingdom] to [to_kingdom]"
	
	// Update owner
	location.owner_kingdom = to_kingdom
	location.last_owner_change = world.time
	
	// Raid bonus: half health damage on capture
	DamageCraftingLocation(location, location.max_health * 0.25)
	
	// If advanced foundry: major strategic event
	if(istype(location, /obj/crafting_location/advanced_foundry))
		world.log << "STRATEGIC EVENT: Advanced foundry captured! [to_kingdom] now controls steel production!"
	
	return TRUE

/proc/ReleaseCraftingLocation(obj/crafting_location/location)
	/**
	 * ReleaseCraftingLocation(obj/crafting_location/location)
	 * Revert to neutral/unclaimed (abandoned)
	 */
	
	if(!location)
		return FALSE
	
	location.owner_kingdom = ""
	location.is_claimed = FALSE
	location.last_owner_change = world.time
	
	world.log << "CRAFTING: [location.name] released to neutral status"
	
	return TRUE

// ============================================================================
// BACKGROUND PROCESSING
// ============================================================================

/proc/CraftingLocationProcessor()
	/**
	 * CraftingLocationProcessor()
	 * Background loop: Process furnace queues, repairs, damage
	 */
	set background = 1
	set waitfor = 0
	
	var/process_interval = 100  // Process every 100 ticks
	var/last_process = world.time
	
	while(1)
		sleep(50)
		
		if(world.time - last_process >= process_interval)
			last_process = world.time
			
			// Would iterate all crafting locations
			// Process queues, apply passive repairs, check conditions
			// Framework ready
