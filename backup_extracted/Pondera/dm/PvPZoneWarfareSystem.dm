/// ============================================================================
/// PVP ZONE WARFARE SYSTEM
/// System for territorial control, factional warfare, and zone-based combat.
/// Integrated with deed system and continent rules.
///
/// Created: 12-11-25 12:15AM
/// ============================================================================

#define PVP_ZONE_CAPTURE_DURATION  600  // 60 seconds to capture
#define PVP_ZONE_CONTROL_REFRESH   100  // 10 seconds per tick
#define FACTION_PVP_GREED          "Kingdom of Greed"
#define FACTION_PVP_SMITHS         "Ironforge Council"
#define FACTION_PVP_DRUIDS         "Druid Circle"

/// ============================================================================
/// PVP ZONE DEFINITION
/// ============================================================================

/datum/pvp_zone
	var
		zone_id = ""             // "zone_1", "zone_2"
		name = ""                // "Crystal Peaks", "Iron Valley"
		controlling_faction = "" // Currently controlling faction
		capture_progress = 0     // 0-100% capture
		faction_presence = list()// faction -> player count
		last_tick = 0            // Last control update
		zone_coordinates = null  // Area/location reference
		resource_bonus = 1.0     // Harvesting multiplier (1.0 = normal)
		crafting_bonus = 1.0     // Crafting speed multiplier
		reward_pool = 0          // Materials accumulated by zone control

/datum/pvp_zone/proc/GetControllingFaction()
	return controlling_faction

/datum/pvp_zone/proc/GetCapturePercentage()
	return capture_progress

/datum/pvp_zone/proc/IsCaptured()
	return capture_progress >= 100

/datum/pvp_zone/proc/TickZoneControl()
	// Called periodically to update zone control
	var/max_faction = ""
	var/max_presence = 0
	
	// Find faction with most players present
	for(var/faction in faction_presence)
		var/count = faction_presence[faction]
		if(count > max_presence)
			max_presence = count
			max_faction = faction
	
	// If no faction has presence, lose control
	if(max_presence == 0)
		capture_progress = max(0, capture_progress - 10)
		if(capture_progress <= 0)
			controlling_faction = ""
		return
	
	// Advance capture for dominant faction
	if(max_faction != controlling_faction)
		capture_progress = min(100, capture_progress + 5)
		if(capture_progress >= 100)
			controlling_faction = max_faction
	
	// Faction already controls zone
	else if(capture_progress < 100)
		capture_progress = min(100, capture_progress + 2)

/datum/pvp_zone/proc/GetResourceBonus()
	if(IsCaptured())
		return resource_bonus
	return 1.0

/datum/pvp_zone/proc/GetCraftingBonus()
	if(IsCaptured())
		return crafting_bonus
	return 1.0

/// ============================================================================
/// ZONE WARFARE EVENT
/// ============================================================================

/datum/zone_warfare_event
	var
		event_id = ""            // Unique identifier
		zone = null              // /datum/pvp_zone reference
		attacking_faction = ""   // Faction initiating capture
		start_time = 0           // world.time when started
		duration = 0             // How long event lasts
		victory_faction = ""     // Faction that won
		is_active = TRUE

/datum/zone_warfare_event/proc/IsActive()
	return is_active && (world.time - start_time) < duration

/datum/zone_warfare_event/proc/GetTimeRemaining()
	var/elapsed = world.time - start_time
	return max(0, duration - elapsed)

/datum/zone_warfare_event/proc/GetProgress()
	var/elapsed = world.time - start_time
	return (elapsed / duration) * 100

/datum/zone_warfare_event/proc/ResolveEvent()
	// Determine victor and apply rewards
	is_active = FALSE
	
	var/datum/pvp_zone/z = zone
	if(z.IsCaptured())
		victory_faction = z.GetControllingFaction()
	
	return victory_faction

/// ============================================================================
/// TERRITORY CONTROL TRACKER
/// ============================================================================

/datum/territory_control_state
	var
		faction_territories = list()     // faction -> list of zone_ids
		faction_war_history = list()     // faction -> kill count
		faction_materials_pool = list()  // faction -> accumulated resources
		active_conflicts = list()        // list of active warfare events

/datum/territory_control_state/proc/RegisterTerritoryControl(faction, zone_id)
	if(!(faction in faction_territories))
		faction_territories[faction] = list()
	
	faction_territories[faction] += zone_id

/datum/territory_control_state/proc/GetControlledTerritories(faction)
	return faction_territories[faction] || list()

/datum/territory_control_state/proc/GetFactionKillCount(faction)
	return faction_war_history[faction] || 0

/datum/territory_control_state/proc/IncrementFactionKills(faction, amount = 1)
	if(!(faction in faction_war_history))
		faction_war_history[faction] = 0
	
	faction_war_history[faction] += amount

/datum/territory_control_state/proc/AwardMaterials(faction, material_type, amount)
	if(!(faction in faction_materials_pool))
		faction_materials_pool[faction] = list()
	
	var/list/pool = faction_materials_pool[faction]
	if(!(material_type in pool))
		pool[material_type] = 0
	
	pool[material_type] += amount

/// ============================================================================
/// PVP ZONE WARFARE SYSTEM COORDINATOR
/// ============================================================================

var/datum/pvp_zone_warfare_system/global_pvp_warfare

/proc/GetPvPWarfareSystem()
	if(!global_pvp_warfare)
		global_pvp_warfare = new /datum/pvp_zone_warfare_system()
	return global_pvp_warfare

/datum/pvp_zone_warfare_system
	var
		all_zones = list()       // zone_id -> /datum/pvp_zone
		territory_state = null   // /datum/territory_control_state
		zone_tick_counter = 0

/datum/pvp_zone_warfare_system/proc/InitializeZones()
	// Create all PvP zones
	if(!territory_state)
		territory_state = new /datum/territory_control_state()
	
	// Zone 1: Crystal Peaks
	var/datum/pvp_zone/zone_1 = new
	zone_1.zone_id = "zone_1"
	zone_1.name = "Crystal Peaks"
	zone_1.controlling_faction = ""
	zone_1.resource_bonus = 1.5   // 50% harvest boost
	zone_1.crafting_bonus = 1.2   // 20% faster crafting
	all_zones["zone_1"] = zone_1
	
	// Zone 2: Iron Valley
	var/datum/pvp_zone/zone_2 = new
	zone_2.zone_id = "zone_2"
	zone_2.name = "Iron Valley"
	zone_2.controlling_faction = ""
	zone_2.resource_bonus = 1.8   // 80% harvest boost (ore-rich)
	zone_2.crafting_bonus = 1.3
	all_zones["zone_2"] = zone_2
	
	// Zone 3: Forest of Whispers
	var/datum/pvp_zone/zone_3 = new
	zone_3.zone_id = "zone_3"
	zone_3.name = "Forest of Whispers"
	zone_3.controlling_faction = ""
	zone_3.resource_bonus = 2.0   // 100% harvest boost (timber)
	zone_3.crafting_bonus = 1.1
	all_zones["zone_3"] = zone_3
	
	// Zone 4: Lava Plains
	var/datum/pvp_zone/zone_4 = new
	zone_4.zone_id = "zone_4"
	zone_4.name = "Lava Plains"
	zone_4.controlling_faction = ""
	zone_4.resource_bonus = 1.4
	zone_4.crafting_bonus = 1.6   // 60% faster (smithing zone)
	all_zones["zone_4"] = zone_4
	
	// Zone 5: Celestial Spire
	var/datum/pvp_zone/zone_5 = new
	zone_5.zone_id = "zone_5"
	zone_5.name = "Celestial Spire"
	zone_5.controlling_faction = ""
	zone_5.resource_bonus = 1.3
	zone_5.crafting_bonus = 2.0   // 100% faster (rare materials)
	all_zones["zone_5"] = zone_5

/datum/pvp_zone_warfare_system/proc/GetZone(zone_id)
	if(!length(all_zones))
		InitializeZones()
	return all_zones[zone_id]

/datum/pvp_zone_warfare_system/proc/TickZoneControl()
	// Called from game loop - update all zones
	if(!length(all_zones))
		InitializeZones()
	
	zone_tick_counter++
	if(zone_tick_counter < PVP_ZONE_CONTROL_REFRESH)
		return
	
	zone_tick_counter = 0
	
	for(var/zone_id in all_zones)
		var/datum/pvp_zone/zone = all_zones[zone_id]
		zone.TickZoneControl()

/datum/pvp_zone_warfare_system/proc/RegisterPlayerInZone(mob/player, zone_id, faction)
	// Player entered PvP zone
	var/datum/pvp_zone/zone = GetZone(zone_id)
	if(!zone)
		return FALSE
	
	if(!(faction in zone.faction_presence))
		zone.faction_presence[faction] = 0
	
	zone.faction_presence[faction]++
	player << "<span style='color: #ff6b6b;'>[faction] presence in [zone.name]: [zone.faction_presence[faction]]</span>"
	
	return TRUE

/datum/pvp_zone_warfare_system/proc/UnregisterPlayerInZone(mob/player, zone_id, faction)
	// Player left PvP zone
	var/datum/pvp_zone/zone = GetZone(zone_id)
	if(!zone)
		return FALSE
	
	zone.faction_presence[faction] = max(0, zone.faction_presence[faction] - 1)
	return TRUE

/datum/pvp_zone_warfare_system/proc/GetZoneStatus(zone_id)
	// Return HTML display of zone control state
	var/datum/pvp_zone/zone = GetZone(zone_id)
	if(!zone)
		return "<p>Zone not found.</p>"
	
	var/html = "<div style='background: #1a1a1a; border: 2px solid #ff6b6b; padding: 10px; margin: 10px 0;'>"
	html += "<h3>[zone.name]</h3>"
	html += "<b>Controlling Faction:</b> [zone.GetControllingFaction() || "UNCLAIMED"]<br>"
	html += "<b>Capture Progress:</b> [zone.GetCapturePercentage()]%<br>"
	html += "<div style='background: #333; height: 15px; border: 1px solid #666; margin: 5px 0;'>"
	html += "<div style='background: #ff6b6b; height: 100%; width: [zone.GetCapturePercentage()]%; transition: width 0.3s;'></div>"
	html += "</div>"
	html += "<b>Resource Bonus:</b> [zone.GetResourceBonus()]x<br>"
	html += "<b>Crafting Bonus:</b> [zone.GetCraftingBonus()]x<br>"
	html += "<b>Factions Present:</b> "
	for(var/faction in zone.faction_presence)
		html += "[faction] ([zone.faction_presence[faction]]) "
	html += "</div>"
	
	return html

/datum/pvp_zone_warfare_system/proc/GetWorldWarStatus()
	// Display all zone control states
	var/html = "<html><head><title>World War Status</title><style>"
	html += "body { background: #0a0a0a; color: #ddd; font-family: monospace; padding: 15px; }"
	html += "h1 { text-align: center; color: #ff6b6b; border-bottom: 2px solid #ff6b6b; }"
	html += "</style></head><body><h1>WORLD WAR STATUS</h1>"
	
	if(!length(all_zones))
		InitializeZones()
	
	for(var/zone_id in all_zones)
		html += GetZoneStatus(zone_id)
	
	html += "</body></html>"
	return html

/datum/pvp_zone_warfare_system/proc/AwardZoneVictory(zone_id, faction)
	// Award materials and bonuses to victorious faction
	if(!territory_state)
		territory_state = new /datum/territory_control_state()
	
	var/datum/territory_control_state/ts = territory_state
	var/datum/pvp_zone/zone = GetZone(zone_id)
	if(!zone)
		return FALSE
	
	var/victory_materials = 500 * zone.resource_bonus  // Scales with zone quality
	ts.AwardMaterials(faction, "mixed_materials", round(victory_materials))
	ts.RegisterTerritoryControl(faction, zone_id)
	
	return TRUE

/datum/pvp_zone_warfare_system/proc/GetFactionPower(faction)
	// Calculate total faction power (territories + kills + materials)
	if(!territory_state)
		territory_state = new /datum/territory_control_state()
	
	var/datum/territory_control_state/ts = territory_state
	var/list/territories = ts.GetControlledTerritories(faction)
	var/power = length(territories) * 100
	power += ts.GetFactionKillCount(faction) * 10
	
	var/list/materials = ts.faction_materials_pool[faction]
	if(materials)
		for(var/mat_type in materials)
			power += materials[mat_type]
	
	return power

/datum/pvp_zone_warfare_system/proc/GetFactionReport(faction)
	// Detailed faction war status
	if(!territory_state)
		territory_state = new /datum/territory_control_state()
	
	var/datum/territory_control_state/ts = territory_state
	var/report = "=== [faction] WAR REPORT ===\n"
	report += "Territories Controlled: [length(ts.GetControlledTerritories(faction))]/5\n"
	report += "Kill Count: [ts.GetFactionKillCount(faction)]\n"
	report += "Total Power: [GetFactionPower(faction)]\n"
	
	var/list/materials = ts.faction_materials_pool[faction]
	if(materials && length(materials))
		report += "Materials Pool:\n"
		for(var/mat_type in materials)
			report += "  [mat_type]: [materials[mat_type]]\n"
	
	return report

/// ============================================================================
/// INTEGRATION WITH INITIALIZATION
/// ============================================================================

proc/InitializePvPWarfare()
	// Called from InitializationManager.dm Phase 5
	
	if(!world_initialization_complete)
		spawn(400)
			InitializePvPWarfare()
		return
	
	var/datum/pvp_zone_warfare_system/sys = GetPvPWarfareSystem()
	sys.InitializeZones()
	
	// Start background tick loop for zone control
	spawn
		while(1)
			sleep(PVP_ZONE_CONTROL_REFRESH)
			if(sys)
				sys.TickZoneControl()
	
	RegisterInitComplete("PvPWarfare")

/// ============================================================================
/// END PVP ZONE WARFARE SYSTEM
/// ============================================================================
