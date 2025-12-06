/**
 * Gathering Extensions - E-Key Support
 * Extends E-key UseObject system to all gathering/harvesting mechanics
 * 
 * Supported gathering types:
 * - Trees (harvesting logs, sprouts, materials)
 * - Mining deposits (ore, stone, gems)
 * - Water sources (drinking, filling containers, quenching)
 * - Environmental resources (flowers, plants)
 */

// ==================== TREE HARVESTING ====================
/**
 * Ueik Tree variants - E-key triggers harvesting
 * Different tree types have specialized gathering (logs, materials, sprouts)
 */

obj/plant/tree/UeikTree
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			// Trigger DblClick behavior for tree gathering
			user.DblClick(src)
			return 1
		return 0

obj/plant/tree/UeikTreeH
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			// Hallowed tree material harvesting
			user.DblClick(src)
			return 1
		return 0

obj/plant/tree/UeikTreeA
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			// Ancient tree gathering (fir, thorn)
			user.DblClick(src)
			return 1
		return 0

// Generic tree base - catches any tree types
obj/plant/tree
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			// Attempt to trigger DblClick on any tree type
			user.DblClick(src)
			return 1
		return 0

// ==================== MINING DEPOSITS ====================
/**
 * Mining rocks and cliffs - E-key triggers mining
 * Supports stone rocks, ores, cliffs with various difficulty levels
 */

obj/Rocks
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			if(user:PXequipped || user:UPKequipped)
				user.DblClick(src)
				return 1
			else
				user << "You need a pickaxe equipped to mine."
				return 0
		return 0

obj/Rocks/SRocks
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			if(user:PXequipped == 1)
				user.DblClick(src)
				return 1
			else
				user << "You need a pickaxe equipped to mine."
				return 0
		return 0

obj/Rocks/HRocks
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			if(user:PXequipped == 1)
				user.DblClick(src)
				return 1
			else
				user << "You need a pickaxe equipped to mine."
				return 0
		return 0

obj/Rocks/VRocks
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			if(user:UPKequipped == 1)
				user.DblClick(src)
				return 1
			else
				user << "You need a Ueik pickaxe equipped to mine."
				return 0
		return 0

// Cliff mining
obj/Cliff
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			if(user:PXequipped == 1)
				user.DblClick(src)
				return 1
			else
				user << "You need a pickaxe equipped to mine."
				return 0
		return 0

// ==================== WATER SOURCES ====================
/**
 * Water interaction - E-key triggers drinking or filling
 * Supports different water body types with quenching and hydration
 */

turf/water
	UseObject(mob/user)
		if(user in range(1, src))
			// Drink from water source
			if(user:stamina < user:MAXstamina)
				user.DblClick(src)
				return 1
			else
				user << "You aren't thirsty right now."
				return 0
		return 0

turf/water/c1
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

turf/water/c2
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

turf/water/c3
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

turf/water/c4
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

// Oasis water sources
turf/OasisWaterc1
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

turf/OasisWaterc2
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

turf/OasisWaterc3
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

turf/OasisWaterc4
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

// Jungle water sources
turf/JungleWaterc1
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

turf/JungleWaterc2
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

turf/JungleWaterc3
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

turf/JungleWaterc4
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

// Water fountain - buildable water structure
obj/WaterFountain
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

// ==================== FLOWERS & PLANTS ====================
/**
 * Flowers and environmental plants - E-key for gathering
 * Resource gathering from ground flora
 */

obj/Flowers
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

obj/Flowers/Tallgrass
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

// Cacti for water
obj/plant/Cacti
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

// Vines for gathering
obj/plant/Vines
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

// ==================== SOIL & DEPOSITS ====================
/**
 * Soil and resource deposits - E-key triggers searching
 * Clay, sand, tar, and other ground resources
 */

obj/Soil
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

obj/Soil/richsoil
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

obj/Soil/soil
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

// ==================== TURF DEPOSITS ====================
/**
 * Turf-level deposits - Clay, tar, sand, obsidian fields
 * Gathered via terrain interaction
 */

turf/ClayDeposit
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

turf/ObsidianField
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

turf/Sand
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

turf/Sand2
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

turf/TarPit
	UseObject(mob/user)
		if(user in range(1, src))
			user.DblClick(src)
			return 1
		return 0

// ==================== WATER HARVESTING & FISHING ====================
/**
 * Water turfs - drinking, filling containers, fishing
 * Default drinking/stamina recovery; specialized fishing in subzones
 * Consolidates all water-based interactions into a single handler
 */

turf/water
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			// Check if user wants to fish instead of drink
			var/action = input(user, "What do you want to do?", "Water Interaction") in list("Fish", "Drink", "Cancel")
			
			switch(action)
				if("Fish")
					if(istype(user, /mob/players))
						var/mob/players/M = user
						M.StartFishing(src)
					return 1
				if("Drink")
					// Attempt to drink or use existing water interaction
					user.DblClick(src)
					return 1
		return 0

// Water variants (c1-c4) inherit from turf/water and use its UseObject
turf/water/c1
	// Inherits UseObject from turf/water

turf/water/c2
	// Inherits UseObject from turf/water

turf/water/c3
	// Inherits UseObject from turf/water

turf/water/c4
	// Inherits UseObject from turf/water

