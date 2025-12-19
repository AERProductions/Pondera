/*
	MISSING STUBS
	
	Defines stubs for procs and types that are referenced but not implemented.
	These allow the game to compile while full implementations are added.
	
	TODO: Replace with full implementations
*/

// ============================================================================
// NAME VALIDATION
// ============================================================================

/proc/Review_Name(name_text)
	/*
		Validate character/deed name format.
		Returns TRUE if name is invalid, FALSE if valid.
	*/
	if(!name_text) return TRUE
	if(length(name_text) < 3) return TRUE
	if(length(name_text) > 15) return TRUE
	return FALSE


// ============================================================================
// DEED PROCS
// ============================================================================

/region/deed/proc/Entered(mob/M)
	/*
		Called when player enters deed region.
		Updates permission cache.
	*/
	if(istype(M, /mob/players))
		InvalidateDeedPermissionCache(M)

/region/deed/proc/Exited(mob/M)
	/*
		Called when player exits deed region.
		Updates permission cache.
	*/
	if(istype(M, /mob/players))
		InvalidateDeedPermissionCache(M)


// ============================================================================
// HUD INITIALIZATION
// ============================================================================

/proc/InitializePlayerHUD(mob/M)
	/*
		Initialize player HUD systems.
		Called after player spawn.
	*/
	if(!M.client) return
	// Placeholder - real implementation in GameHUDSystem.dm
	return TRUE


// ============================================================================
// SMELTING PROCS
// ============================================================================

/proc/smeltingunlock(mob/M)
	/*
		Check if player can access smelting recipe.
		Returns TRUE if unlocked.
	*/
	if(!M) return FALSE
	if(!istype(M, /mob/players)) return FALSE
	// Check if player has smelting level via vars
	return M.vars["smitrank"] >= 1

/proc/smeltinglevel(mob/M)
	/*
		Get player's smelting level.
		Returns 1-5.
	*/
	if(!M) return 0
	if(!istype(M, /mob/players)) return 0
	// Get smelting rank from player vars
	return M.vars["smitrank"] || 0


// ============================================================================
// TOOL/EQUIPMENT TYPE STUBS
// ============================================================================

// Note: /obj/items/equipment already has max_durability and current_durability
// defined in WeaponArmorScalingSystem.dm, so we don't redefine them here

/obj/items/equipment/tool
	name = "generic tool"
	icon_state = "tool"

/obj/items/equipment/tool/Fishing_Pole
	name = "fishing pole"
	icon_state = "fishing_pole"

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
// TOOL INTERFACE PROCS - GENERIC /obj/items FALLBACK
// ============================================================================
// NOTE: These are fallbacks for items that don't inherit from /obj/items/equipment
// Most modern items should use the procs in WeaponArmorScalingSystem.dm on /obj/items/equipment

/obj/items/proc/IsBroken()
	/*
		Check if tool is broken (durability at 0).
		Fallback version for non-equipment items.
	*/
	if(!istype(src, /obj/items)) return FALSE
	// Try to use max_durability/current_durability if present
	if(src.vars["max_durability"] && src.vars["current_durability"])
		return (src.vars["current_durability"] <= 0)
	// If durability vars not present, assume not broken
	return FALSE

/obj/items/proc/IsFragile()
	/*
		Check if tool is close to breaking.
		Fallback version for non-equipment items.
	*/
	if(!istype(src, /obj/items)) return FALSE
	var/max_dur = src.vars["max_durability"]
	var/cur_dur = src.vars["current_durability"]
	if(!max_dur || max_dur == 0) return FALSE
	return (cur_dur < max_dur * 0.2) // Fragile if <20%

/obj/items/proc/GetDurabilityPercent()
	/*
		Get durability as percentage (0-100).
		Fallback version for non-equipment items.
	*/
	if(!istype(src, /obj/items)) return 0
	var/max_dur = src.vars["max_durability"]
	var/cur_dur = src.vars["current_durability"]
	if(!max_dur || max_dur == 0) return 100
	return (cur_dur / max_dur) * 100

/obj/items/proc/AttemptUse()
	/*
		Attempt to use the tool.
		Returns TRUE if successful, FALSE if broken.
		Fallback version for non-equipment items.
	*/
	if(IsBroken()) return FALSE
	// Degrade durability on use if vars present
	if(src.vars["current_durability"])
		src.vars["current_durability"]--
	return TRUE


// ============================================================================
// CHARACTER STAMINA/HUNGER STUBS
// ============================================================================

// These are typically in character_data datum
// Adding stubs so movement.dm can compile

/datum/character_data/var/stamina_level = 100
/datum/character_data/var/hunger_level = 100

// Procs on players to access these
/mob/players/proc/GetStaminaLevel()
	if(character) return character.stamina_level || 100
	return 100

/mob/players/proc/GetHungerLevel()
	if(character) return character.hunger_level || 100
	return 100

/mob/players/proc/SetStaminaLevel(amount)
	if(character) character.stamina_level = amount
	return amount

/mob/players/proc/SetHungerLevel(amount)
	if(character) character.hunger_level = amount
	return amount

// ============================================================================
// TOOL DURABILITY PROCS ALREADY DEFINED ABOVE
// ============================================================================
// NOTE: IsBroken(), IsFragile(), GetDurabilityPercent(), AttemptUse()
// are defined on /obj/items/proc above (lines ~138-151)

// ============================================================================
// TERRAIN WEIGHT VAR
// ============================================================================

/turf/var/weight = 0  // For movement/pathfinding cost
