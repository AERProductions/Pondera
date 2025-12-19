/**
 * TERRAIN & TOOL STUBS
 * Placeholder implementations for terrain objects and tool systems
 * These allow terrain/tool features to compile while full implementations are developed
 */

// ==================== TERRAIN OBJECTS ====================

/obj/Dirt_Road
	name = "Dirt Road"
	desc = "A simple dirt road."
	icon = 'dmi/64/char.dmi'
	icon_state = "dirt_road"
	layer = MOB_LAYER - 1

	New()
		..()
		// Stub terrain creation - implement full logic in future

/obj/Stone_Road
	name = "Stone Road"
	desc = "A sturdy stone road."
	icon = 'dmi/64/char.dmi'
	icon_state = "stone_road"
	layer = MOB_LAYER - 1

	New()
		..()
		// Stub terrain creation - implement full logic in future

/obj/Brick_Road
	name = "Brick Road"
	desc = "A brick-paved road."
	icon = 'dmi/64/char.dmi'
	icon_state = "brick_road"
	layer = MOB_LAYER - 1

	New()
		..()
		// Stub terrain creation - implement full logic in future

// ==================== TOOL TYPES ====================
// All tools inherit from /obj/items/equipment which provides durability system
// Tool procs (IsBroken, IsFragile, GetDurabilityPercent, AttemptUse) are defined on /obj/items/equipment base class

/obj/items/equipment/tool
	// Tool base type - inherits durability from /obj/items/equipment

// ==================== SPECIFIC TOOLS ====================

/obj/items/equipment/tool/Fishing_Pole
	name = "Fishing Pole"
	desc = "A basic fishing pole for catching fish."
	icon = 'dmi/64/char.dmi'
	icon_state = "fishing_pole"
	weight = 5
	var/value = 50

	New()
		..()
		current_durability = 50
		// Stub fishing pole - implement full logic in future

/obj/items/equipment/tool/CarvingKnife
	name = "Carving Knife"
	desc = "A sharp knife for carving wood."
	icon = 'dmi/64/char.dmi'
	icon_state = "carving_knife"

	New()
		..()
		current_durability = 75

/obj/items/equipment/tool/Hammer
	name = "Hammer"
	desc = "A sturdy hammer for crafting."
	icon = 'dmi/64/char.dmi'
	icon_state = "hammer"

	New()
		..()
		current_durability = 100

// ==================== SMELTING PROCS ====================

proc/smeltingunlock()
	/**
	 * smeltingunlock() -> void
	 * Unlocks smelting recipe for player
	 * STUB - Implement full recipe unlock logic
	 */
	return

proc/smeltinglevel()
	/**
	 * smeltinglevel() -> int
	 * Returns player's smelting level
	 * STUB - Implement full smelting system
	 */
	return 0

