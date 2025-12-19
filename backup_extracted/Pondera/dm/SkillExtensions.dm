/**
 * Skill & Combat Extensions - E-Key Support
 * Extends E-key system to fishing, combat interactions, and skill-based actions
 * 
 * Supported activities:
 * - Fishing spots (water bodies with fishing mechanics)
 * - NPCs (dialogue, trading, interaction)
 * - Enemy spawners (combat prep)
 * - Skill-based activities (summoning, crafting stations)
 */

// ==================== FISHING ====================
/**
 * Fishing - E-key triggers fishing attempt
 * All water bodies support fishing as alternative to drinking
 * See GatheringExtensions.dm for consolidated water/fishing handling
 */

// ==================== SPAWNERS & ENEMY ENCOUNTERS ====================
/**
 * Spawn points and encounter triggers
 * E-key can initiate or check spawner status
 * Spawner UseObject is handled via inheritance on spawnpointe1-6 and similar types
 * Each spawner type with vars/spawned and vars/max_spawn can override UseObject as needed
 */

// Note: Spawner UseObject handlers should be added directly to specific spawnpointe types
// in Spawn.dm if dynamic status display is desired. The parent obj/spawns type does not
// declare spawned/max_spawn, so UseObject is most safely defined on child types.

// ==================== NPC DIALOGUE & TRADING ====================
/**
 * NPCs and merchants - E-key initiates dialogue
 * Supports multiple NPC types and interactions
 */

mob/npc
	UseObject(mob/user)
		if(user in range(2, src))
			user.Click(src)
			return 1
		return 0

// ==================== SKILL & CRAFTING ====================
/**
 * Fire sources and quenching stations - E-key for smelting/crafting
 * Cooking fires, smelting stations, quenching pools
 */

obj/Buildable/Fire
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

// Anvils already handled in UseObjectExtensions.dm but add forge-specific
obj/Buildable/Smithing/Forge
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

// ==================== SUMMONING & PETS ====================
/**
 * Summoning circles and pet interaction
 * Allow E-key interaction with summoning/pet systems
 */

obj/SummoningCircle
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

// ==================== HERBALISM & ALCHEMY ====================
/**
 * Herbalism stations, alchemy tables, apothecaries
 * E-key access to potion/herb crafting
 */

obj/Buildable/Alchemy
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

obj/Buildable/Herbalism
	UseObject(mob/user)
		if(user in range(1, src))
			user.Click(src)
			return 1
		return 0

// ==================== MISC INTERACTIVE OBJECTS ====================
/**
 * Sundials, compasses, markers, and other interactive world objects
 */

obj/Buildable/sundial
	UseObject(mob/user)
		if(user in range(2, src))
			user.Click(src)
			return 1
		return 0

obj/Navi/Compas
	UseObject(mob/user)
		if(user)
			user.Click(src)
			return 1
		return 0

obj/Navi/Arrow
	UseObject(mob/user)
		if(user)
			user.Click(src)
			return 1
		return 0
