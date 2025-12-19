/**
 * CONTINENT TELEPORTATION SYSTEM - HUD Integration Layer
 * Wraps existing TravelToContinent from Portals.dm with HUD updates
 * Provides interface for HUD-based continent travel
 */

// Global dictionary tracking last position in each continent per player
var/tmp/list/continent_positions = list()

/**
 * TravelToContinentViaHUD(mob/players/player, continent_name)
 * HUD wrapper for continent travel
 * Calls existing TravelToContinent and updates HUD display
 * 
 * @param player: The player mob attempting travel
 * @param continent_name: "story", "sandbox", or "kingdom"
 * @return TRUE if travel successful, FALSE if failed
 */
proc/TravelToContinentViaHUD(mob/players/player, continent_name)
	if(!player || !player.client)
		return FALSE
	
	// Validate continent name
	if(!(continent_name in list("story", "sandbox", "kingdom")))
		player << "\red Invalid continent selection."
		return FALSE
	
	// Gating: Only allow travel if initialization is complete
	if(!world_initialization_complete)
		player << "\red World is still initializing. Please wait..."
		return FALSE
	
	// Store current position before leaving
	var/current_continent = player:current_continent || "story"
	var/key = "[player.key]_[current_continent]"
	continent_positions[key] = player.loc
	
	// Call existing TravelToContinent from Portals.dm
	var/result = TravelToContinent(player, continent_name)
	
	// Update HUD to reflect travel (stub for now)
	if(result && player && player.main_hud)
		// HUD update - will be implemented when HUD system fully initialized
		// spawn(1)
		// 	if(player && player.main_hud)
		//		player.main_hud.update_all()
	
	return result

/**
 * ReturnToHub(mob/players/player)
 * Return player to Port Island hub from any continent
 * Called from HUD QuickActionsMenu "Return to Hub" button
 * 
 * @param player: The player mob
 * @return TRUE if return successful, FALSE if failed
 */
proc/ReturnToHub(mob/players/player)
	if(!player || !player.client)
		return FALSE
	
	if(!world_initialization_complete)
		player << "\red World is still initializing. Please wait..."
		return FALSE
	
	// Get hub center location
	var/turf/hub_turf = GetPortHubCenter()
	
	if(!hub_turf)
		player << "\red ERROR: Cannot return to hub. Hub location not found."
		return FALSE
	
	// Save current position before returning
	var/current_continent = player:current_continent || "story"
	var/key = "[player.key]_[current_continent]"
	continent_positions[key] = player.loc
	
	// Perform teleportation to hub
	player.loc = hub_turf
	player.dir = SOUTH
	
	// Clear active continent (player is in neutral hub)
	player:current_continent = "hub"
	
	// Update HUD
	if(player && player.main_hud)
		// HUD update - will be implemented when HUD system fully initialized
		// spawn(1)
		//	if(player && player.main_hud)
		//		player.main_hud.update_all()
	
	player << "\cyan You have returned to the Port Island hub."
	
	return TRUE

/**
 * ClearContinentPositionCache(mob/players/player)
 * Remove cached positions for a player (called on logout)
 * 
 * @param player: The player mob
 */
proc/ClearContinentPositionCache(mob/players/player)
	if(!player) return
	
	for(var/continent in list("story", "sandbox", "kingdom"))
		var/key = "[player.key]_[continent]"
		continent_positions -= key
