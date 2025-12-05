/**
 * Miscellaneous Interactive Objects - E-Key Support
 * Extends E-key system to lamps, decorative objects, and miscellaneous interactables
 * 
 * Supported object types:
 * - Lamps and torches (lighting)
 * - Banners and signs (display)
 * - Decorative objects (flowers, plants, artwork)
 * - Miscellaneous buildables (sundials, statues, etc.)
 */

// ==================== LAMPS & LIGHT SOURCES ====================
/**
 * Lamps and torches - E-key for ignition/lighting control
 * Delegates to existing Ignite verb or Click behavior
 */

obj/Buildable/Lamps
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

obj/Buildable/lamps
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

obj/items/Buildable/lamps
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

// ==================== BANNERS & SIGNS ====================
/**
 * Banners and wall signs - E-key for message display/interaction
 * Delegates to existing Click handlers
 */

obj/Buildable/Banner
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

obj/Buildable/Sign
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

// ==================== BARRICADES & BARRIERS ====================
/**
 * Barricades and barriers - E-key for interaction/climbing
 * Can display status or allow climbing over
 */

obj/Buildable/Barricade
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

// ==================== MISCELLANEOUS BUILDABLES ====================
/**
 * Sundials, statues, and other miscellaneous interactive objects
 * Covered in SkillExtensions but expanded here for completeness
 */

obj/Buildable/Decoration
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

// ==================== FLOWER & PLANT DISPLAYS ====================
/**
 * Decorative flowers and plants - E-key for inspecting/harvesting
 * Delegates to existing DblClick behavior or visual inspection
 */

obj/Buildable/Flowers
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

// ==================== BOOKSHELVES & LIBRARIES ====================
/**
 * Bookshelves and reading materials - E-key for access
 * Can display lore, story, or storage interface
 */

obj/Buildable/Bookshelf
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

obj/Buildable/Library
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

