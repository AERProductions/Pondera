/**
 * Macros.dm - Keyboard macro system for object interactions
 * 
 * Provides keyboard macro infrastructure for using/interacting with nearby objects.
 * Replaces mouse-based Click() handlers with keyboard-driven interaction system.
 * 
 * Architecture:
 * - Player verbs: /use_object (E-key), /quick_attack (secondary)
 * - Detection system: Finds usable objects/targets in front of player
 * - Shared logic: Objects implement UseObject() proc called by both Click() and verb
 * 
 * Interactive Object Types:
 * - Treasure chests (tchst.dm) - loot containers
 * - Doors (door.dm) - all buildable and castle doors
 * - Furnishings (Objects.dm) - weapon racks, armor racks
 * - Crafting stations (Light.dm) - forges, anvils
 * - NPCs (npcs.dm) - instinctual guide, dialogue
 * - Environmental (door.dm, Objects.dm) - signs, exits, water sources
 * 
 * Usage:
 * E = Use nearby object (chests, doors, NPCs, etc.)
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

