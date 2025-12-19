// NPC TARGETING SYSTEM - Phase 0.5a
// Allows players to target NPCs and interact via macro keys
// ============================================================================

/**
 * SetTargetNPC() - Set the current target NPC
 * Parameters: npc (mob/npcs) - NPC to target
 * Returns: TRUE if target set successfully, FALSE if out of range or invalid
 */
/mob/players/proc/SetTargetNPC(mob/npcs/npc)
	if(!npc || !istype(npc))
		src << "<span class='warning'>Invalid NPC target.</span>"
		return FALSE
	
	// Check if NPC is in range (same turf or adjacent)
	var/distance = get_dist(src, npc)
	if(distance > 2)
		src << "<span class='warning'>[npc.name] is too far away to target.</span>"
		return FALSE
	
	// Set target
	targeted_npc = npc
	targeted_npc_ckey = npc.ckey ? npc.ckey : ""
	
	// Show visual feedback
	src << "<span class='info'>You have targeted [npc.name]. Press E to interact.</span>"
	
	// Update HUD display (will be called every tick)
	UpdateNPCTargetingHUD()
	
	return TRUE


/**
 * ClearTargetNPC() - Clear the current target NPC (called by click-to-deselect)
 * Parameters: silent (TRUE = no message, for automatic clears)
 */
/mob/players/proc/ClearTargetNPC(silent=FALSE)
	if(targeted_npc)
		if(!silent)
			src << "<span class='info'>Target cleared.</span>"
		targeted_npc = null
		targeted_npc_ckey = ""
		ClearNPCTargetingHUD()  // Remove HUD display
	else if(!silent)
		src << "<span class='warning'>You don't have a target.</span>"


/**
 * GetTargetNPC() - Get the current target NPC
 * Returns: mob/npcs if valid target in range, null otherwise
 */
/mob/players/proc/GetTargetNPC()
	if(!targeted_npc)
		return null
	
	// Validate NPC still exists and is in range
	if(!istype(targeted_npc, /mob/npcs))
		ClearTargetNPC()
		return null
	
	var/mob/npcs/npc = targeted_npc
	
	// Check distance
	var/distance = get_dist(src, npc)
	if(distance > 2)
		src << "<span class='warning'>[npc.name] is out of range.</span>"
		ClearTargetNPC()
		return null
	
	return npc


/**
 * UpdateNPCTargetingHUD() - Update HUD display for targeted NPC
 * Called every tick while NPC is targeted
 */
/mob/players/proc/UpdateNPCTargetingHUD()
	// TODO: Implement HUD display (Phase 0.5c)
	// This will show:
	// - NPC name and type
	// - Available actions (Greet: K, Learn Recipes: L)
	// - Distance status


/**
 * ClearNPCTargetingHUD() - Remove HUD display
 */
/mob/players/proc/ClearNPCTargetingHUD()
	// TODO: Implement HUD removal (Phase 0.5c)


/**
 * IsValidNPCTarget() - Check if object can be targeted as NPC
 * Used by Click() to determine if object is clickable NPC
 */
/proc/IsValidNPCTarget(atom/obj)
	if(!istype(obj, /mob/npcs))
		return FALSE
	var/mob/npcs/npc = obj
	return npc.character ? TRUE : FALSE


/**
 * ValidateNPCTarget() - Called periodically to verify target still valid
 * Runs on every player tick (movement loop)
 */
/mob/players/proc/ValidateNPCTarget()
	if(!targeted_npc) return
	
	// Check if NPC still exists
	if(!istype(targeted_npc, /mob/npcs))
		ClearTargetNPC()
		return
	
	// Check distance
	var/distance = get_dist(src, targeted_npc)
	if(distance > 2)
		ClearTargetNPC(silent=TRUE)
		return
	
	// Update HUD if still valid
	UpdateNPCTargetingHUD()
