/**
 * Macros.dm - Keyboard macro system for object interactions
 * 
 * Provides keyboard macro infrastructure for using/interacting with nearby objects.
 * Replaces mouse-based Click() handlers with keyboard-driven interaction system.
 * 
 * Interactive Object Types:
 * - Treasure chests (tchst.dm) - loot containers
 * - Doors (door.dm) - all buildable and castle doors
 * - NPCs (npcs.dm) - interact via E key, click to target, click elsewhere to deselect
 * - Crafting stations (Light.dm) - forges, anvils
 * - Environmental (door.dm, Objects.dm) - signs, exits, water sources
 * 
 * Usage:
 * E = Use nearby object (chests, doors, NPCs, etc.)
 * Click on NPC = Target it (shows "Press E to interact")
 * Click elsewhere = Deselect target
 * [Future: Additional macros can extend this pattern]
 */

mob/players
	verb/use_object()
		set name = "Use"
		set category = "Macros"
		set waitfor = 0
		
		// Find object in front of player (in player's current direction)
		var/atom/target = get_step(src, src.dir)
		
		// Check if there's a usable object at that location
		if(!target)
			return
			
		// Find usable object at target location and try to use it
		for(var/atom/movable/A in target)
			if(A.UseObject(usr))
				return

/**
 * atom/proc/UseObject() - Base interaction handler
 * All atoms have this proc. Objects override to implement custom behavior.
 * Returns 1 if interaction was handled, 0 if not interactive.
 */
atom/proc/UseObject(mob/user)
	return 0  // Default: no interaction


/**
 * Click() handlers for click-to-deselect NPC targeting
 * When player clicks on non-NPC objects, clears their NPC target (silent)
 */

turf/Click(location, control, params)
	// Deselect NPC target when clicking ground
	var/mob/players/player = usr
	if(istype(player) && player.targeted_npc)
		player.ClearTargetNPC(silent=TRUE)
	return ..()


// For other interactive objects, parent Click() will be called
// which will deselect target (they override Click() and call ..()

