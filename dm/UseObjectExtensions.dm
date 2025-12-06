/**
 * E-Key UseObject Extensions
 * Comprehensive E-key interaction system extending macro framework to all major interactive objects
 * Supports: doors, furnishings, crafting structures, NPCs, gathering, and environmental objects
 */

// ==================== DOOR BASE CLASS ====================
/**
 * Generic door base type supporting both Click and E-key interaction
 * All door types support E-key by delegating to their existing tryit proc
 */

obj/doors/CLeftDoor
	UseObject(mob/user)
		call(src, /obj/doors/CLeftDoor/proc/tryit)(user, src)
		return 1

obj/doors/CRightDoor
	UseObject(mob/user)
		call(src, /obj/doors/CRightDoor/proc/tryit)(user, src)
		return 1

obj/doors/CTopDoor
	UseObject(mob/user)
		call(src, /obj/doors/CTopDoor/proc/tryit)(user, src)
		return 1

obj/doors/CBottomDoor
	UseObject(mob/user)
		call(src, /obj/doors/CBottomDoor/proc/tryit)(user, src)
		return 1

// Simplified approach: just call the common tryit proc pattern
// All doors have tryit procs, just need to delegate

obj/Buildable/Doors/LeftDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/LeftDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/RightDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/RightDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/TopDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/TopDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/Door
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/Door/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/WHLeftDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/WHLeftDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/WHRightDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/WHRightDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/WHTopDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/WHTopDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/WHDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/WHDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/SHLeftDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/SHLeftDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/SHRightDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/SHRightDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/SHTopDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/SHTopDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/SHDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/SHDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/SLeftDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/SLeftDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/SRightDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/SRightDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/STopDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/STopDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/SDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/SDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/HTLeftDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/HTLeftDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/HTRightDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/HTRightDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/HTTopDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/HTTopDoor/proc/tryit)(user, src)
		return 1

obj/Buildable/Doors/HTDoor
	UseObject(mob/user)
		call(src, /obj/Buildable/Doors/HTDoor/proc/tryit)(user, src)
		return 1

// ==================== FURNISHINGS & STORAGE ====================
/**
 * Equipment racks for storing/retrieving weapons and armor
 */

obj/Buildable/Furnishings/WeaponRack
	UseObject(mob/user)
		if(user)
			user.Click(src)
		return 1

obj/Buildable/Furnishings/ArmorRack
	UseObject(mob/user)
		if(user)
			user.Click(src)
		return 1

// ==================== CRAFTING & SMITHING ====================
/**
 * Forges and Anvils - core crafting structures
 */

obj/Buildable/Smithing/Forge
	var
		is_lit = FALSE
	
	UseObject(mob/user)
		if(user)
			is_lit = !is_lit  // Toggle forge state
			if(is_lit)
				user << "You light the forge."
				PlayForgeAmbient(src, TRUE)
			else
				user << "You extinguish the forge flames."
				PlayForgeAmbient(src, FALSE)
			user.Click(src)
		return 1

obj/Buildable/Smithing/Anvil
	UseObject(mob/user)
		if(user)
			// Play hammer strike sound when using anvil
			PlayHammerStrike(src)
			user << "You strike the anvil with your hammer."
			user.Click(src)
		return 1

// ==================== NPC INTERACTIONS ====================
/**
 * Instinctual Guide - E-key opens tutorial menu
 */
obj/IG
	UseObject(mob/user)
		if(user)
			user.Click(src)
		return 1

// ==================== SIGNS & DISPLAYS ====================
/**
 * Generic sign - E-key reads message
 */
obj/Z/sign
	UseObject(mob/user)
		if(user && src.msg)
			user << "<center>[src.msg]"
		return 1

// ==================== ONE-WAY EXITS ====================
/**
 * One-way exit portal - E-key triggers passage check
 */
obj/exits/oneway
	UseObject(mob/user)
		if(user.dir == src.dir)
			user.density = 0
			step(user, user.dir)
			user.density = 1
			return 1
		else
			user << "You must be facing the exit to pass through."
			return 0
