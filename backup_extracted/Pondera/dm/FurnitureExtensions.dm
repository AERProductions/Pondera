/**
 * Furniture & Container Extensions - E-Key Support
 * Extends E-key system to interactive furniture and storage containers
 * 
 * Supported furniture types:
 * - Beds (rest/sleep interactions)
 * - Tables (seating, work surfaces)
 * - Chairs (seating)
 * - Crates/Storage (inventory management)
 * - Containers (fridges, storage boxes)
 * - Ovens/Stoves (cooking)
 */

// ==================== BEDS & SLEEPING ====================
/**
 * Beds - E-key for resting/sleep mechanics
 * Delegates to existing DblClick/Click behavior or creates rest verb
 */

obj/Buildable/Furnishings/bed
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

obj/Buildable/Furnishings/beds
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

// ==================== TABLES & WORK SURFACES ====================
/**
 * Tables - E-key for examining contents or interaction
 * Can be extended for crafting or inspection
 */

obj/Buildable/Furnishings/Table
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

// ==================== CHAIRS & SEATING ====================
/**
 * Chairs - E-key for sitting or interaction
 * All chair variants support basic Click delegation
 */

obj/Buildable/Furnishings/Chairr
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

obj/Buildable/Furnishings/Chairl
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

obj/Buildable/Furnishings/Chairn
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

obj/Buildable/Furnishings/Chairs
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

obj/Buildable/Furnishings/Chairst
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

// ==================== STORAGE & CONTAINERS ====================
/**
 * Crates and storage containers - E-key for inventory access
 * Delegates to existing storage/click interface
 */

obj/Buildable/Furnishings/crate
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

// Buildable containers (fridges, storage boxes, etc.)
obj/Buildable/Containers
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

// ==================== COOKING & FOOD PREP ====================
/**
 * Ovens and stoves - E-key for cooking interface
 * Baking, cooking, and food preparation
 */

obj/Buildable/Oven
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

// Stove turf (kitchen stove on floor)
turf/woodstove
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

