/*
	Village Zone Access System - Phase 2d
	Detects when players enter/exit village deed zones and updates permissions
	
	Features:
	- Automatic boundary detection on movement
	- Permission flag updates (canbuild, canpickup, candrop)
	- Welcome/departure messages
	- Integration with DeedToken_Zone objects
*/

// Override mob/players Move() to detect zone boundary changes
mob/players/Move(var/turf/NewLoc, NewDir)
	// Call parent Move() first
	. = ..()
	
	// After successful movement, check zone access
	if(.)
		UpdateZoneAccess()

// Update player's zone access permissions based on current location
mob/players/proc/UpdateZoneAccess()
	// Find all village deed zones in the world
	for(var/obj/DeedToken_Zone/dz in world)
		if(!dz)
			continue
		
		// Check if player is within this zone's boundaries
		if(IsPlayerInZone(src, dz))
			// Player is inside zone - grant permissions
			ApplyZonePermissions(src, dz, TRUE)
		else
			// Player is outside zone - revoke permissions if they're outside all zones
			ApplyZonePermissions(src, dz, FALSE)

// Check if a player is within a zone's boundaries
// Returns TRUE if player's location is within the zone's area
proc/IsPlayerInZone(mob/players/M, obj/DeedToken_Zone/zone)
	if(!M || !zone || !M.loc)
		return FALSE
	
	// Get zone center and size
	var/turf/center = zone.center_turf
	if(!center)
		return FALSE
	
	var/half_width = zone.size[1] / 2
	var/half_height = zone.size[2] / 2
	
	var/min_x = center.x - half_width
	var/max_x = center.x + half_width
	var/min_y = center.y - half_height
	var/max_y = center.y + half_height
	
	var/player_x = M.x
	var/player_y = M.y
	
	return (player_x >= min_x && player_x <= max_x && player_y >= min_y && player_y <= max_y)

// Apply or revoke zone permissions for a player
proc/ApplyZonePermissions(mob/players/M, obj/DeedToken_Zone/zone, is_entering)
	if(!M || !zone)
		return
	
	if(is_entering)
		// Check if player has permission to be in this zone
		// Allow owner and allowed players
		if(M.key == zone.owner_key || (M.key in zone.allowed_players))
			// Set permissions for owner/allowed players
			M.canbuild = 1
			M.canpickup = 1
			M.candrop = 1
			M.village_zone_id = zone.zone_id
			
			// Send welcome message (only on first entry)
			if(M.village_zone_id != zone.zone_id)
				M << "<b><font color=green>Welcome to [zone.zone_name]!</font></b>"
		else
			// Not allowed; revoke permissions
			M.canbuild = 0
			M.canpickup = 0
			M.candrop = 0
			M << "<b><font color=red>You do not have permission to build or modify items in [zone.zone_name].</font></b>"
	else
		// Player exiting zone - check if they're in another zone
		var/in_any_zone = FALSE
		for(var/obj/DeedToken_Zone/other_zone in world)
			if(other_zone && other_zone != zone && IsPlayerInZone(M, other_zone))
				in_any_zone = TRUE
				break
		
		// If not in any zone, revoke all permissions
		if(!in_any_zone)
			M.canbuild = 0
			M.canpickup = 0
			M.candrop = 0
			M.village_zone_id = 0
			M << "<b><font color=orange>You have left the village zone.</font></b>"

// Initialize zone access system on world startup
proc/InitializeZoneAccessSystem()
	// This proc is called from world initialization
	// Currently a placeholder for future expansion
	// Zone access is checked dynamically on each player movement

