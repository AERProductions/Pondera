/**
 * Option 4: Build System E-Key Integration
 * 
 * Purpose: Add unified E-key support to buildable objects with deed permission checking
 * 
 * Key Features:
 * 1. UseObject() handlers for all buildable types
 * 2. Deed permission integration (CanPlayerBuildAtLocation)
 * 3. Consistent range checking (1 tile)
 * 4. Proper feedback for permission denials
 * 
 * Files Modified:
 * - BuildSystemEKeyIntegration.dm (NEW)
 * - Pondera.dme (included before mapgen)
 * 
 * Status: Ready for testing
 */

// ==================== BASE BUILDABLE STRUCTURE ====================
/**
 * Root buildable type - provides centralized E-key handler
 * All other buildables inherit this pattern unless overridden
 */

obj/Buildable
	UseObject(mob/user)
		// Generic E-key handler for most buildables
		// Delegates to Click() for compatibility with existing verb menus
		if(user in range(1, src))
			set waitfor = 0
			user.Click(src)
			return 1
		return 0

// ==================== STRUCTURES WITH PERMISSION GATING ====================
/**
 * Strategic structures that should respect deed permissions:
 * - Walls, gates, towers (fortifications)
 * - Resource storage (supply boxes)
 * - Territory markers
 */

obj/Buildable/Walls
	UseObject(mob/user)
		if(user in range(1, src))
			// Check deed permission for this location
			if(!CanPlayerBuildAtLocation(user, src.loc))
				user << "<font color='red'>You don't have permission to interact with structures here.</font>"
				return 0
			set waitfor = 0
			user.Click(src)
			return 1
		return 0

obj/Buildable/Gates
	UseObject(mob/user)
		if(user in range(1, src))
			// Gates allow passage control via E-key
			if(!CanPlayerBuildAtLocation(user, src.loc))
				user << "<font color='red'>This gate is not under your control.</font>"
				return 0
			set waitfor = 0
			user.Click(src)
			return 1
		return 0

obj/Buildable/Towers
	UseObject(mob/user)
		if(user in range(1, src))
			if(!CanPlayerBuildAtLocation(user, src.loc))
				user << "<font color='red'>This tower is not under your control.</font>"
				return 0
			set waitfor = 0
			user.Click(src)
			return 1
		return 0

// ==================== STORAGE WITH PERMISSION GATING ====================
/**
 * Storage objects that should respect deed permissions
 */

obj/Buildable/Storage
	UseObject(mob/user)
		if(user in range(1, src))
			// Check deed permission - storage can only be accessed by deed owner
			if(!CanPlayerPickupAtLocation(user, src.loc))
				user << "<font color='red'>You don't have access to this storage.</font>"
				return 0
			set waitfor = 0
			user.Click(src)
			return 1
		return 0

// ==================== CRAFTING STATIONS (Already Implemented) ====================
/**
 * Smithing, Cooking, Alchemy, etc. already have UseObject handlers
 * This is reference documentation
 * 
 * File: SmithingModernE-Key.dm - Anvil, Forge
 * File: GatheringExtensions.dm - Already provides E-key for these
 * File: CookingSystem.dm - Oven E-key handler
 */

// ==================== FURNISHINGS & DECORATIVE ====================
/**
 * Non-restricted buildables (furniture, decorations)
 * Don't need deed permission - purely decorative
 * Already handled in MiscExtensions.dm and UseObjectExtensions.dm
 */

obj/Buildable/Furnishings
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			user.Click(src)
			return 1
		return 0

obj/Buildable/Decoration
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			user.DblClick(src)
			return 1
		return 0

// ==================== RESOURCE NODES & PRODUCTION ====================
/**
 * Production buildings: farms, gardens, animal pens
 * These respect deed boundaries but allow owner to interact
 */

obj/Buildable/Production
	UseObject(mob/user)
		if(user in range(1, src))
			// Production buildings respect deed but allow gathering by owner
			if(!CanPlayerPickupAtLocation(user, src.loc))
				user << "<font color='red'>You don't have permission to use this production building.</font>"
				return 0
			set waitfor = 0
			user.Click(src)
			return 1
		return 0

// ==================== UTILITY STRUCTURES ====================
/**
 * Utility: water troughs, wells, composters, etc.
 * These are public utility - no permission gating
 */

obj/Buildable/WaterTrough
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			user.Click(src)
			return 1
		return 0

obj/Buildable/Well
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			user.Click(src)
			return 1
		return 0

// ==================== TELEPORTATION & TRAVEL ====================
/**
 * Portals, teleporters, travel hubs
 * May have location-based restrictions
 */

obj/Buildable/Portal
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			user.Click(src)
			return 1
		return 0

// ==================== DOORS (Enhanced) ====================
/**
 * All door types get range-checked E-key support
 * Handles directional doors and secured doors
 * Already partially implemented in UseObjectExtensions.dm
 */

obj/Buildable/Doors
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			// Delegate to door-specific handlers (tryit procs)
			user.Click(src)
			return 1
		return 0

// ==================== INTEGRATION POINTS ====================
/**
 * Integration with Deed Permission System:
 * 
 * 1. CanPlayerBuildAtLocation(mob/M, turf/T)
 *    - Checks if player can build/destroy at location
 *    - Called before structural modifications
 * 
 * 2. CanPlayerPickupAtLocation(mob/M, turf/T)
 *    - Checks if player can pickup items at location
 *    - Called for storage/resource access
 * 
 * 3. CanPlayerDropAtLocation(mob/M, turf/T)
 *    - Checks if player can drop items at location
 *    - Called for placing items
 * 
 * These functions automatically:
 * - Verify deed ownership or permission
 * - Check zone boundaries
 * - Provide error messages
 * - Log attempts for admin review
 */

// ==================== TESTING REFERENCE ====================
/**
 * To test Option 4 implementation:
 * 
 * 1. Build structures in owned deed zone
 * 2. Press E near each structure type
 * 3. Verify menu appears (Click handler triggered)
 * 4. Verify deed permissions enforced (can't interact outside deed)
 * 5. Verify range check works (must be 1 tile away)
 * 6. Verify error messages clear and helpful
 * 
 * Structure types to test:
 * - Door (any type)
 * - Wall/Fortification
 * - Storage container
 * - Furnishing (furniture)
 * - Production building (if available)
 * - Water trough/Utility
 */

// ==================== FUTURE ENHANCEMENTS ====================
/**
 * Planned improvements for future sessions:
 * 
 * 1. Dynamic structure visualization
 *    - Show structure health/integrity on E-key
 *    - Display maintenance status
 *    - Show zone boundaries visually
 * 
 * 2. Quick action menus
 *    - E-key opens context menu
 *    - Repair, Upgrade, Remove options
 *    - Faster than verb menu
 * 
 * 3. Structure permissions
 *    - Allow deed owner to grant access to allies
 *    - Temporary access tokens
 *    - Permission inheritance in zones
 * 
 * 4. Building placement assist
 *    - E-key shows placement grid
 *    - Highlights invalid placements
 *    - Confirms placement with E+Click combo
 */

