#!/usr/bin/env python3
import re

with open(r'c:\Users\ABL\Desktop\Pondera\dm\DeedAntiGriefingSystem.dm', 'r') as f:
    content = f.read()

# Find and replace the buggy CheckDeedVulnerability proc
pattern = r'/proc/CheckDeedVulnerability\(obj/DeedToken/existing_deed, turf/new_claim_location, mob/players/new_claimer\)(.*?)(?=/proc/LogDeedClaim)'

replacement = r'''/proc/CheckDeedVulnerability(obj/DeedToken/existing_deed, turf/new_claim_location, mob/players/new_claimer)
	/**
	 * CheckDeedVulnerability(existing_deed, new_claim_turf, new_player) -> is_vulnerable
	 * Detects if existing deed is being griefed by new claim
	 * Protects deed owners from being surrounded
	 */
	if(!existing_deed || !new_claim_location || !new_claimer) return 0
	
	var/buffer = GetDeedBuffer("Small")  // Use minimum buffer for vulnerability check
	var/distance = get_dist(existing_deed, new_claim_location)
	
	// If new claim is within buffer but from different owner = griefing risk
	if(distance < buffer && new_claimer.key != existing_deed.owner)
		// Check if this would encircle the existing deed
		var/adjacent_to_existing = 0
		
		for(var/obj/DeedToken/dt in world)
			if(!dt) continue
			if(get_dist(existing_deed, dt) <= buffer && dt.owner == new_claimer.key)
				adjacent_to_existing++
		
		// If new player has multiple deeds adjacent to target = griefing
		if(adjacent_to_existing >= DEED_GRIEFING_THRESHOLD)
			return 1  // Vulnerable to griefing
	
	return 0

// ============================================================================
// TRACKING & LOGGING
// ============================================================================

/proc/LogDeedClaim'''

newcontent = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open(r'c:\Users\ABL\Desktop\Pondera\dm\DeedAntiGriefingSystem.dm', 'w') as f:
    f.write(newcontent)

print("Fixed bracket mismatch")
