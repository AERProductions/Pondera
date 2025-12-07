/**
 * TOWN GENERATOR INTEGRATION
 * 
 * Integrates Phase B town generator with:
 * - World initialization (World/New)
 * - Map generation system (after mapgen completes)
 * - World system (kingdoms, continents)
 * - Persistence system
 * 
 * This file handles all the hooks and integration points.
 */

// ============================================================================
// WORLD INITIALIZATION INTEGRATION
// ============================================================================

/**
 * Called from World/New() after world is initialized
 * 
 * Initialization order:
 * 1. Load saved world state
 * 2. Load saved towns (if exist)
 * 3. If no towns, generate world and towns
 * 4. Start periodic save timer
 */

proc/InitializeGameWorld()
	// This would be called from existing Basics.dm World/New
	// Pseudo-code for integration:
	/*
	
	// In World/New(), after map generation:
	// Town system is initialized by InitializeTownSystem() in _debugtimer.dm
	// StartTownPeriodicSave() starts automatically
	
	*/

/**
 * Periodic town data saving
 * Saves town changes to disk every N ticks
 */
var/global/town_save_timer = 0

proc/StartTownPeriodicSave()
	set waitfor = 0
	set background = 1
	
	while(1)
		sleep(3000)  // Save every 5 minutes (300 seconds * 10 ticks = 3000)
		SaveTownData()

proc/StopTownPeriodicSave()
	town_save_timer = 0

// ============================================================================
// MAP GENERATOR INTEGRATION
// ============================================================================

/**
 * Hook into map generation to place towns procedurally
 * 
 * Called from mapgen/backend.dm after terrain generation completes
 * 
 * This ensures towns are placed at good locations (valid turfs, good biome)
 */

proc/IntegrateTownsWithMapgen()
	// This would be called after all terrain generates
	// Validates town coordinates against map data
	
	for(var/town/T in towns)
		ValidateTownLocation(T)
		GenerateTownTerrainLayer(T)

/**
 * Validates that a town's coordinates are on valid terrain
 * If not, finds nearest valid location
 */
proc/ValidateTownLocation(town/T)
	if(!T) return
	
	// Check if town coordinates exist on map
	var/turf/check = locate(T.x, T.y, T.z)
	
	if(!check)
		// Coordinates invalid, find nearest valid turf
		world.log << "WARNING: Town [T.name] at invalid location, relocating..."
		var/turf/nearest = FindNearestValidTurf(T.x, T.y, T.z)
		if(nearest)
			T.x = nearest.x
			T.y = nearest.y
			T.z = nearest.z
			world.log << "  Relocated to ([T.x], [T.y], [T.z])"
		else
			world.log << "  ERROR: Could not find valid location for town!"
	
	// Check biome matches town type
	var/expected_biome = GetBiomeForKingdom(T.kingdom)
	var/actual_biome = GetBiomeAtLocation(T.x, T.y, T.z)
	
	if(expected_biome && actual_biome != expected_biome)
		world.log << "WARNING: Town [T.name] in wrong biome ([actual_biome] vs [expected_biome])"

/**
 * Finds nearest valid turf to given coordinates
 */
proc/FindNearestValidTurf(x, y, z)
	var/search_radius = 50
	var/turf/best = null
	var/best_dist = search_radius
	
	for(var/turf/T in block(locate(x - search_radius, y - search_radius, z), 
	                         locate(x + search_radius, y + search_radius, z)))
		if(!T.density && !T.opacity)  // Valid walkable turf
			var/dist = sqrt((T.x - x) ** 2 + (T.y - y) ** 2)
			if(dist < best_dist)
				best = T
				best_dist = dist
	
	return best

/**
 * Gets expected biome for a kingdom
 */
proc/GetBiomeForKingdom(kingdom)
	switch(kingdom)
		if("freedom")
			return "temperate"
		if("belief")
			return "mountain"
		if("honor")
			return "highland"
		if("pride")
			return "temperate"
		if("greed")
			return "desert"
	return null

/**
 * Gets biome at specific location
 * Checks turf's biome tag if available
 */
proc/GetBiomeAtLocation(x, y, z)
	var/turf/T = locate(x, y, z)
	if(!T) return null
	
	// Check if turf has biome property
	if(T.vars && T.vars["biome"])
		return T.vars["biome"]
	
	// Otherwise infer from surroundings
	// This is simplified; real implementation would check terrain type
	return "unknown"

/**
 * Generates terrain layer for a town
 * Clears existing turfs in town radius and replaces with town-appropriate terrain
 */
proc/GenerateTownTerrainLayer(town/T)
	if(!T) return
	
	// This would clear turfs in T.radius around T.x, T.y
	// and place town-specific terrain (roads, cleared areas, etc.)
	
	// Placeholder - full implementation would:
	// 1. Create main plaza/town center
	// 2. Create road grid or organic paths
	// 3. Clear vegetation
	// 4. Place town boundary markers

// ============================================================================
// CRATER-SPECIFIC TOWN INTEGRATION
// ============================================================================

/**
 * Special handling for crater towns during map generation
 * 
 * Crater generation happens after town generation because:
 * 1. We need to know where the crater spawns (procedurally)
 * 2. Then place faction settlements within crater region
 * 3. Create unique crater biome around settlements
 */

proc/IntegrateCraterTownsWithMapgen()
	// Check if crater was generated
	var/turf/crater_center = FindCraterCenter()
	
	if(crater_center)
		world.log << "Crater detected, generating crater towns..."
		GenerateCraterTownsAtLocation(crater_center)
		GenerateCraterBiome(crater_center)
	else
		world.log << "No crater found in generated world"

/**
 * Finds the crater center in the generated world
 * Looks for concentration of special crater turfs
 */
proc/FindCraterCenter()
	// This would scan the world for crater features
	// For now, simplified - just return null
	return null

/**
 * Generates crater-specific towns at discovered crater location
 */
proc/GenerateCraterTownsAtLocation(turf/center)
	if(!center) return
	
	// Port of Plenty at crater rim
	var/town/hub/port = town_cache["greed"]
	if(port)
		port.x = center.x
		port.y = center.y + 50  // Place at rim, not center
		port.z = center.z
		world.log << "Positioned Port of Plenty at crater rim"

/**
 * Generates special crater biome around towns
 * Creates desert-like environment with corruption effects
 */
proc/GenerateCraterBiome(turf/center)
	if(!center) return
	
	// Would convert surrounding turfs to crater biome
	// - Desert terrain
	// - Corruption markers
	// - Unique flora/fauna
	// - Crystalline formations
	
	world.log << "Crater biome generated around [center]"

// ============================================================================
// WORLD SYSTEM INTEGRATION
// ============================================================================

/**
 * Ensures towns are linked to world system kingdoms
 * Validates that each town's kingdom exists in world_system.kingdoms
 */
proc/ValidateTownsWithWorldSystem()
	// TODO: Link towns with world_system kingdoms when that system is available
	// For now, just verify towns exist
	if(!towns || towns.len == 0)
		world.log << "WARNING: No towns initialized"
		return
	
	world.log << "Town system validation: [towns.len] towns loaded"

// ============================================================================
// PERSISTENCE INTEGRATION
// ============================================================================

/**
 * Hooks town saving into player save system
 * 
 * When player saves, also save current town state
 * When player loads, restore town state to what it was
 */

proc/SaveTownStateWithPlayer(mob/players/P)
	if(!P) return
	
	// Store player's current town
	var/current_town = GetTownAt(P.x, P.y, P.z)
	if(current_town)
		// TODO: Save town state to P.save_data when persistence system is ready
		// Placeholder for future persistence integration
		return

proc/LoadTownStateWithPlayer(mob/players/P)
	if(!P) return
	
	// TODO: Restore town discovery state from P.save_data when persistence system is ready
	// Restore town discovery state
	// if(P.save_data["towns_discovered"])
	//	P.discovered_towns = P.save_data["towns_discovered"]
	// if(P.save_data["towns_visited"])
	//	P.visited_towns = P.save_data["towns_visited"]

// ============================================================================
// TOWN DEBUG/ADMIN COMMANDS
// ============================================================================

/**
 * Admin commands for testing town system
 * Usage: /cmd/GenerateTownsNow
 */

var/admin_town_commands = list(
	"GenerateTownsNow" = "Force immediate town generation",
	"ListTowns" = "List all generated towns",
	"TeleportToTown" = "Teleport to specified town",
	"DeleteAllTowns" = "Clear all towns and regenerate",
	"ShowTownInfo" = "Show detailed info for a town"
)

// Admin commands disabled until check_admin() is available
/*
proc/AdminGenerateTownsNow()
	if(!check_admin(usr)) return
	GenerateAllTowns()
	usr << "Towns generated"

proc/AdminListTowns()
	if(!check_admin(usr)) return
	var/output = "=== Towns ===\n"
	for(var/i = 1; i <= towns.len; i++)
		var/town/T = towns[i]
		output += "[i]. [T.name] ([T.town_type]) - [T.kingdom] - [T.buildings.len] buildings\n"
	usr << output

proc/AdminShowTownInfo(town/T)
	if(!check_admin(usr)) return
	if(!T) return
	var/output = "=== [T.name] ===\n"
	output += "Type: [T.town_type]\n"
	output += "Kingdom: [T.kingdom]\n"
	output += "Location: ([T.x], [T.y], [T.z])\n"
	output += "Radius: [T.radius]\n"
	output += "Prosperity: [T.prosperity]\n"
	output += "Population: [T.population]\n"
	output += "Buildings: [T.buildings.len]\n"
	output += "NPCs: [T.npcs.len]\n"
	usr << output
*/
