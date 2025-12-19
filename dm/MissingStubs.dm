/*
	MISSING STUBS
	
	Minimal stub file for compilation.
	Most stubs have been moved to their appropriate system files:
	- Tool durability procs → dm/WeaponArmorScalingSystem.dm
	- Character stamina/hunger → dm/CharacterData.dm
	- Name validation → libs/NameFilter.dm
	- HUD initialization → dm/GameHUDSystem.dm
	
	This file contains ONLY unique stubs not defined elsewhere.
*/

// ============================================================================
// ROAD OBJECTS
// ============================================================================

/obj/Dirt_Road
	name = "dirt road"
	icon_state = "dirt_road"
	density = 0

/obj/Stone_Road
	name = "stone road"
	icon_state = "stone_road"
	density = 0

/obj/Brick_Road
	name = "brick road"
	icon_state = "brick_road"
	density = 0

// ============================================================================
// TERRAIN WEIGHT VAR
// ============================================================================

/turf/var/weight = 0  // For movement/pathfinding cost
