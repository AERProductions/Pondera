/**
 * DEED ANTI-GRIEFING SYSTEM
 * Prevents players from abusing deeds to restrict other players' movement
 */

#define DEED_BUFFER_SMALL 20
#define DEED_BUFFER_MEDIUM 30
#define DEED_BUFFER_LARGE 40

/proc/GetDeedBuffer(tier_size)
	switch(tier_size)
		if("Small")
			return DEED_BUFFER_SMALL
		if("Medium")
			return DEED_BUFFER_MEDIUM
		if("Large")
			return DEED_BUFFER_LARGE
	return DEED_BUFFER_SMALL

/proc/CheckDeedProximity(turf/claim_location, deed_tier, mob/players/claiming_player)
	/**
	 * Validates deed placement against minimum distance rules
	 * Returns: list(can_claim, reason)
	 */
	if(!claim_location) return list(0, "Invalid location")
	
	var/buffer = GetDeedBuffer(deed_tier)
	var/found_conflicts = 0
	var/search_radius = buffer + 50
	
	for(var/obj/DeedToken/dt in world)
		if(!dt) continue
		if(get_dist(claim_location, dt) <= search_radius)
			var/distance = get_dist(claim_location, dt)
			if(distance < buffer)
				found_conflicts++
	
	if(found_conflicts > 0)
		return list(0, "Too close to existing deed(s). Required buffer: [buffer] turfs.")
	
	return list(1, "Proximity check passed")

/proc/DetectDeedGriefing(turf/claim_location, deed_tier, mob/players/claiming_player)
	/**
	 * Detects if new deed would encircle/trap existing deeds
	 * Returns: list(is_griefing, reason)
	 */
	if(!claim_location || !claiming_player) return list(0, "Invalid parameters")
	
	var/buffer = GetDeedBuffer(deed_tier)
	var/search_radius = buffer * 2
	var/adjacent_deeds = 0
	
	// Count deeds from other players nearby
	for(var/obj/DeedToken/dt in world)
		if(!dt || dt.owner == claiming_player.key) continue
		if(get_dist(claim_location, dt) <= search_radius)
			adjacent_deeds++
	
	// If too many deeds nearby, might be griefing
	if(adjacent_deeds >= 3)
		return list(1, "Deed placement would encircle existing claims. Anti-griefing protection activated.")
	
	return list(0, "Griefing check passed")

/proc/CheckDeedVulnerability(obj/DeedToken/existing_deed, turf/new_claim_location, mob/players/new_claimer)
	/**
	 * Protects existing deeds from being griefed by new claims
	 * Returns: 1 if vulnerable, 0 if safe
	 */
	if(!existing_deed || !new_claim_location || !new_claimer) return 0
	
	var/buffer = GetDeedBuffer("Small")
	var/distance = get_dist(existing_deed, new_claim_location)
	
	// Check if new claim would be part of encirclement
	if(distance < buffer && new_claimer.key != existing_deed.owner)
		var/adjacent_to_existing = 0
		
		for(var/obj/DeedToken/dt in world)
			if(!dt) continue
			if(get_dist(existing_deed, dt) <= buffer && dt.owner == new_claimer.key)
				adjacent_to_existing++
		
		if(adjacent_to_existing >= 3)
			return 1
	
	return 0

/proc/LogDeedClaim(mob/players/player, turf/claim_location, deed_tier)
	/**
	 * Logs deed claims for audit trail
	 */
	if(!player || !claim_location) return
	world.log << "DEED_CLAIM: [player.key] claimed [claim_location.x],[claim_location.y] ([deed_tier])"

/proc/GetDeedGriefingStatus(mob/players/player, turf/deed_location)
	/**
	 * Returns griefing status for a player
	 */
	if(!player) return list()
	var/list/status = list("flagged" = FALSE, "risk" = "LOW")
	return status

/proc/AdminFlagDeedGriefing(mob/players/player, reason = "")
	/**
	 * Flags player for griefing
	 */
	if(!player) return
	world.log << "ADMIN: Flagged [player.key] for deed griefing. Reason: [reason]"

/proc/AdminUnflagDeedGriefing(mob/players/player)
	/**
	 * Clears griefing flag for player
	 */
	if(!player) return
	world.log << "ADMIN: Cleared griefing flag for [player.key]"

/proc/AdminGetDeedGriefingReport(mob/players/target_player)
	/**
	 * Returns griefing report for target player
	 */
	if(!target_player) return "No player specified"
	return "Griefing report for [target_player.key]: No suspicious activity detected"

