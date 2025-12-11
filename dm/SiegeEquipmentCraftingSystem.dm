/// ============================================================================
/// SIEGE EQUIPMENT CRAFTING SYSTEM
/// System for crafting siege weapons, ramming equipment, and defensive structures.
/// Integrated with smithing ranks and material costs.
///
/// Created: 12-11-25 11:45PM
/// ============================================================================

#define SIEGE_TIER_1  1  // Wooden trebuchets, battering rams
#define SIEGE_TIER_2  2  // Stone ballistas, siege towers
#define SIEGE_TIER_3  3  // Metal catapults, reinforced siege towers
#define SIEGE_TIER_4  4  // Advanced ballistas, cannon-like devices
#define SIEGE_TIER_5  5  // Mythical siege weapons

#define SIEGE_CRAFTING_TIME_SCALE  10  // 10x longer than normal crafting

/// ============================================================================
/// SIEGE WEAPON BLUEPRINT DATUM
/// ============================================================================

/datum/siege_blueprint
	var
		name = ""                // "Wooden Trebuchet", "Stone Ballista"
		tier = 1
		crafting_time = 0        // Ticks to craft
		materials = list()       // item_name -> quantity
		required_rank = 1        // Smithing rank needed
		damage_output = 0        // Damage per hit
		range = 0                // Distance weapon can reach
		crew_required = 1        // Players to operate
		description = ""
		deploy_model = ""        // Visual model when deployed

/datum/siege_blueprint/proc/GetMaterialList()
	return materials

/datum/siege_blueprint/proc/GetTotalWeight()
	// Weight in "units" for transport/deployment
	return 100 * tier

/datum/siege_blueprint/proc/IsDeployable()
	// Can this be placed in-world
	return TRUE

/datum/siege_blueprint/proc/GetDeployTime()
	// Ticks to set up deployed weapon
	return 50 * tier

/// ============================================================================
/// BLUEPRINT REGISTRY
/// ============================================================================

var/datum/siege_blueprint_registry/global_siege_registry

/proc/GetSiegeRegistry()
	if(!global_siege_registry)
		global_siege_registry = new /datum/siege_blueprint_registry()
	return global_siege_registry

/datum/siege_blueprint_registry
	var
		blueprints = list()      // blueprint_name -> /datum/siege_blueprint

/datum/siege_blueprint_registry/proc/RegisterBlueprints()
	// Initialize all siege weapon blueprints
	
	// TIER 1: Wooden siege equipment
	var/datum/siege_blueprint/trebuchet = new
	trebuchet.name = "Wooden Trebuchet"
	trebuchet.tier = SIEGE_TIER_1
	trebuchet.crafting_time = 300  // 30 seconds
	trebuchet.materials = list(
		"timber" = 50,
		"rope" = 20,
		"stone" = 10
	)
	trebuchet.required_rank = 1
	trebuchet.damage_output = 15
	trebuchet.range = 15
	trebuchet.crew_required = 2
	trebuchet.description = "Basic siege engine for launching projectiles. Requires 2 crew."
	blueprints["wooden_trebuchet"] = trebuchet
	
	var/datum/siege_blueprint/battering_ram = new
	battering_ram.name = "Wooden Battering Ram"
	battering_ram.tier = SIEGE_TIER_1
	battering_ram.crafting_time = 250
	battering_ram.materials = list(
		"timber" = 80,
		"metal" = 5,
		"rope" = 15
	)
	battering_ram.required_rank = 1
	battering_ram.damage_output = 20
	battering_ram.range = 1  // Melee only
	battering_ram.crew_required = 3
	battering_ram.description = "Reinforced battering ram for breaching gates and walls."
	blueprints["wooden_battering_ram"] = battering_ram
	
	// TIER 2: Stone-reinforced equipment
	var/datum/siege_blueprint/stone_ballista = new
	stone_ballista.name = "Stone Ballista"
	stone_ballista.tier = SIEGE_TIER_2
	stone_ballista.crafting_time = 500
	stone_ballista.materials = list(
		"timber" = 60,
		"stone" = 40,
		"metal" = 15,
		"rope" = 25
	)
	stone_ballista.required_rank = 2
	stone_ballista.damage_output = 30
	stone_ballista.range = 20
	stone_ballista.crew_required = 2
	stone_ballista.description = "Heavy siege weapon firing stone projectiles. Devastating damage."
	blueprints["stone_ballista"] = stone_ballista
	
	var/datum/siege_blueprint/siege_tower = new
	siege_tower.name = "Siege Tower"
	siege_tower.tier = SIEGE_TIER_2
	siege_tower.crafting_time = 600
	siege_tower.materials = list(
		"timber" = 100,
		"stone" = 20,
		"metal" = 20,
		"rope" = 30
	)
	siege_tower.required_rank = 2
	siege_tower.damage_output = 5    // Not a weapon per se
	siege_tower.range = 0
	siege_tower.crew_required = 4
	siege_tower.description = "Mobile platform for scaling walls. Holds up to 6 combatants."
	blueprints["siege_tower"] = siege_tower
	
	// TIER 3: Metal-reinforced equipment
	var/datum/siege_blueprint/metal_catapult = new
	metal_catapult.name = "Metal-Reinforced Catapult"
	metal_catapult.tier = SIEGE_TIER_3
	metal_catapult.crafting_time = 800
	metal_catapult.materials = list(
		"timber" = 70,
		"metal" = 40,
		"stone" = 30,
		"rope" = 35
	)
	metal_catapult.required_rank = 3
	metal_catapult.damage_output = 40
	metal_catapult.range = 25
	metal_catapult.crew_required = 3
	metal_catapult.description = "Advanced catapult with metal frame. High firepower."
	blueprints["metal_catapult"] = metal_catapult
	
	// TIER 4: Advanced ballistic weapons
	var/datum/siege_blueprint/advanced_ballista = new
	advanced_ballista.name = "Advanced Ballista"
	advanced_ballista.tier = SIEGE_TIER_4
	advanced_ballista.crafting_time = 1000
	advanced_ballista.materials = list(
		"timber" = 80,
		"metal" = 60,
		"stone" = 40,
		"rope" = 40,
		"refined_metal" = 10
	)
	advanced_ballista.required_rank = 4
	advanced_ballista.damage_output = 50
	advanced_ballista.range = 30
	advanced_ballista.crew_required = 2
	advanced_ballista.description = "Precision siege weapon with extended range. Pinpoint targeting."
	blueprints["advanced_ballista"] = advanced_ballista
	
	// TIER 5: Mythical weapons
	var/datum/siege_blueprint/oracle_cannon = new
	oracle_cannon.name = "Oracle Cannon"
	oracle_cannon.tier = SIEGE_TIER_5
	oracle_cannon.crafting_time = 2000
	oracle_cannon.materials = list(
		"mithril" = 20,
		"metal" = 80,
		"stone" = 60,
		"rope" = 50,
		"refined_metal" = 30,
		"dragon_scale" = 5
	)
	oracle_cannon.required_rank = 5
	oracle_cannon.damage_output = 100
	oracle_cannon.range = 40
	oracle_cannon.crew_required = 4
	oracle_cannon.description = "Legendary siege weapon. Devastating firepower and range."
	blueprints["oracle_cannon"] = oracle_cannon

/datum/siege_blueprint_registry/proc/GetBlueprints()
	if(!length(blueprints))
		RegisterBlueprints()
	return blueprints

/datum/siege_blueprint_registry/proc/GetBlueprint(blueprint_id)
	var/list/bps = GetBlueprints()
	return bps[blueprint_id]

/datum/siege_blueprint_registry/proc/GetTierBlueprints(tier)
	var/list/result = list()
	var/list/bps = GetBlueprints()
	for(var/bp_id in bps)
		var/datum/siege_blueprint/bp = bps[bp_id]
		if(bp.tier == tier)
			result += bp
	return result

/// ============================================================================
/// SIEGE WEAPON CRAFTING COORDINATOR
/// ============================================================================

var/datum/siege_crafting_system/global_siege_crafter

/proc/GetSiegeCraftingSystem()
	if(!global_siege_crafter)
		global_siege_crafter = new /datum/siege_crafting_system()
	return global_siege_crafter

/datum/siege_crafting_system
	var
		active_crafts = list()   // player -> list of craft jobs
		completed_weapons = list() // player -> list of completed weapons
		crafting_progress = list() // job_id -> progress (0-100)

/datum/siege_crafting_system/proc/CanCraftBlueprint(mob/player, blueprint_id)
	// Check if player meets rank requirement and has materials
	var/datum/siege_blueprint/bp = GetSiegeRegistry().GetBlueprint(blueprint_id)
	if(!bp)
		return FALSE
	
	// Check smithing rank
	if("character" in player.vars)
		var/datum/character_data/char = player.vars["character"]
		if(istype(char))
			var/rank = char.GetRankLevel(RANK_SMITHING)
			if(rank < bp.required_rank)
				player << "<span style='color: #ff6b6b;'>Smithing Rank [bp.required_rank] required!</span>"
				return FALSE
	
	// TODO: Check material inventory
	return TRUE

/datum/siege_crafting_system/proc/StartCraft(mob/player, blueprint_id)
	// Begin crafting a siege weapon
	if(!CanCraftBlueprint(player, blueprint_id))
		return FALSE
	
	var/datum/siege_blueprint/bp = GetSiegeRegistry().GetBlueprint(blueprint_id)
	
	var/list/craft_job = list()
	craft_job["player"] = player
	craft_job["blueprint"] = bp
	craft_job["start_time"] = world.time
	craft_job["end_time"] = world.time + bp.crafting_time
	craft_job["progress"] = 0
	craft_job["job_id"] = "[player.ckey]_[world.time]"
	
	if(!(player.ckey in active_crafts))
		active_crafts[player.ckey] = list()
	
	active_crafts[player.ckey] += craft_job
	
	player << "<span style='color: #81c784;'>Started crafting [bp.name]...</span>"
	return craft_job["job_id"]

/datum/siege_crafting_system/proc/UpdateCraftProgress()
	// Called from game loop - advance all crafts
	for(var/player_ckey in active_crafts)
		var/list/jobs = active_crafts[player_ckey]
		for(var/i = length(jobs); i >= 1; i--)
			var/job = jobs[i]
			var/elapsed = world.time - job["start_time"]
			var/total = job["end_time"] - job["start_time"]
			var/progress = (elapsed / total) * 100
			
			job["progress"] = min(100, progress)
			
			if(progress >= 100)
				// Craft complete
				var/mob/player = job["player"]
				var/datum/siege_blueprint/bp = job["blueprint"]
				
				if(istype(player))
					player << "<span style='color: #81c784;'>** [bp.name] COMPLETE! **</span>"
					
					if(!(player.ckey in completed_weapons))
						completed_weapons[player.ckey] = list()
					
					completed_weapons[player.ckey] += bp
				
				jobs[i] = null

/datum/siege_crafting_system/proc/GetCraftingStatus(mob/player)
	// Return HTML status of crafting progress
	var/html = "<html><head><title>Siege Crafting</title><style>"
	html += "body { background: #0a0a0a; color: #ddd; font-family: monospace; padding: 10px; }"
	html += ".craft-job { background: #1a1a1a; border: 1px solid #666; padding: 10px; margin: 10px 0; }"
	html += ".craft-name { color: #ffb74d; font-weight: bold; font-size: 1.1em; }"
	html += ".progress { background: #333; height: 15px; border: 1px solid #555; margin: 5px 0; }"
	html += ".progress-bar { height: 100%; background: linear-gradient(to right, #ff6b6b, #ffb74d); transition: width 0.3s; }"
	html += "</style></head><body><h2>Active Siege Crafts</h2>"
	
	var/list/jobs = active_crafts[player.ckey]
	if(!jobs || !length(jobs))
		html += "<p>No active crafts. Start a new siege weapon project!</p>"
	else
		for(var/job in jobs)
			if(!job) continue
			var/datum/siege_blueprint/bp = job["blueprint"]
			var/progress = job["progress"]
			html += "<div class='craft-job'>"
			html += "<div class='craft-name'>[bp.name]</div>"
			html += "<div>Materials:"
			for(var/mat in bp.materials)
				html += " [mat]x[bp.materials[mat]],"
			html += "</div>"
			html += "<div class='progress'><div class='progress-bar' style='width: [progress]%;'></div></div>"
			html += "<div>Progress: [progress]%</div>"
			html += "</div>"
	
	html += "<h2>Completed Weapons</h2>"
	var/list/weapons = completed_weapons[player.ckey]
	if(!weapons || !length(weapons))
		html += "<p>No completed weapons yet.</p>"
	else
		for(var/datum/siege_blueprint/wp in weapons)
			html += "<div style='background: #1a2a1a; border: 1px solid #4a8c3c; padding: 8px; margin: 5px 0;'>"
			html += "<b>[wp.name]</b> (Tier [wp.tier]) - Damage: [wp.damage_output], Range: [wp.range]<br>"
			html += "[wp.description]"
			html += "</div>"
	
	html += "</body></html>"
	return html

/datum/siege_crafting_system/proc/GetBlueprintBrowser()
	// Display all available blueprints for crafting
	var/html = "<html><head><title>Siege Blueprint Browser</title><style>"
	html += "body { background: #0a0a0a; color: #ddd; font-family: monospace; padding: 15px; }"
	html += "h2 { color: #ff6b6b; border-bottom: 2px solid #ff6b6b; padding-bottom: 5px; }"
	html += ".blueprint { background: #1a1a1a; border-left: 4px solid #ffb74d; padding: 10px; margin: 10px 0; }"
	html += ".stats { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin: 5px 0; }"
	html += ".stat { font-size: 0.9em; color: #90caf9; }"
	html += "</style></head><body><h1>Siege Weapon Blueprints</h1>"
	
	var/datum/siege_blueprint_registry/registry = GetSiegeRegistry()
	var/list/all_blueprints = registry.GetBlueprints()
	
	for(var/tier = 1; tier <= 5; tier++)
		html += "<h2>Tier [tier] Weapons</h2>"
		var/list/tier_bps = registry.GetTierBlueprints(tier)
		
		if(!length(tier_bps))
			html += "<p>No weapons available at this tier yet.</p>"
		else
			for(var/datum/siege_blueprint/bp in tier_bps)
				html += "<div class='blueprint'>"
				html += "<b>[bp.name]</b><br>"
				html += "<div class='stats'>"
				html += "<div class='stat'><b>Rank Required:</b> [bp.required_rank]</div>"
				html += "<div class='stat'><b>Crafting Time:</b> [bp.crafting_time / 50]s</div>"
				html += "<div class='stat'><b>Damage:</b> [bp.damage_output]</div>"
				html += "<div class='stat'><b>Range:</b> [bp.range]</div>"
				html += "<div class='stat'><b>Crew:</b> [bp.crew_required]</div>"
				html += "<div class='stat'><b>Weight:</b> [bp.GetTotalWeight()] units</div>"
				html += "</div>"
				html += "<b>Materials:</b> "
				for(var/mat in bp.materials)
					html += "[mat] x[bp.materials[mat]] "
				html += "<br>"
				html += "<b>Description:</b> [bp.description]"
				html += "</div>"
	
	html += "</body></html>"
	return html

/// ============================================================================
/// INTEGRATION WITH INITIALIZATION
/// ============================================================================

proc/InitializeSiegeCrafting()
	// Called from InitializationManager.dm Phase 5
	
	if(!world_initialization_complete)
		spawn(400)
			InitializeSiegeCrafting()
		return
	
	var/datum/siege_crafting_system/crafter = GetSiegeCraftingSystem()
	var/datum/siege_blueprint_registry/registry = GetSiegeRegistry()
	registry.RegisterBlueprints()
	
	// Start background progress update loop
	spawn
		while(1)
			sleep(10)  // Every 1 second
			if(crafter)
				crafter.UpdateCraftProgress()
	
	RegisterInitComplete("SiegeCrafting")

/// ============================================================================
/// END SIEGE EQUIPMENT CRAFTING SYSTEM
/// ============================================================================
