/**
 * Macros.dm - Keyboard macro system for object interactions
 * 
 * Provides E-key macro infrastructure for using/interacting with nearby objects.
 * Replaces mouse-based Click() handlers with keyboard-driven interaction system.
 * 
 * Architecture:
 * - Player verb /use_object: E-key bound interaction
 * - Detection system: Finds usable objects in front of player
 * - Shared logic: Objects implement UseObject() proc called by both Click() and verb
 * 
 * Objects implementing UseObject():
 * - Treasure chests (tchst.dm)
 * - Doors (door.dm)
 * - Tree/gathering objects (WC.dm, plant.dm)
 * - NPCs (npcs.dm)
 * - Job board structures (jb.dm)
 */

mob/players
	verb/use_object()
		set name = "Use"
		set waitfor = 0
		
		// Find object in front of player (in player's current direction)
		var/atom/target = get_step(src, src.dir)
		
		// Check if there's a dense usable object at that location
		if(!target)
			usr << "Nothing to use in that direction."
			return
			
		// Find usable object (mob or obj) at target location
		for(var/atom/movable/A in target)
			// Try to use the object
			if(A.UseObject(usr))
				return  // UseObject() handled the interaction
		
		usr << "Nothing to use in that direction."

/**
 * atom/proc/UseObject() - Default interaction handler
 * Override in specific object types to implement custom behavior
 */
atom/proc/UseObject(mob/user)
	return 0  // Default: no interaction
