/**
 * PONDERA FIRE SYSTEM
 * ==================
 * Comprehensive fire management and object gating
 * 
 * Core Mechanics:
 * - Fire sources: Campfire, Forge, Oven, Smeltery, Torch, Brazier
 * - Fuel management: Wood → Kindling → Load fire → Light → Maintain
 * - Fire spreading: Wildfire events for crisis/resource scarcity
 * - Gating: Cooking/smelting REQUIRE lit fires in those objects
 * 
 * Simple Rule: Objects that need fire will not work without fire.
 */

#define FIRE_STATE_EXTINGUISHED 0
#define FIRE_STATE_LIT          1
#define FIRE_STATE_DYING        2

// Global fire management
var/list/active_fires = list()
var/list/fire_sources = list()
var/fire_system_initialized = FALSE

// ============================================================================
// FIRE DATUM CLASS
// ============================================================================

/datum/fire
	var
		fire_type = "campfire"
		location = null
		state = FIRE_STATE_EXTINGUISHED
		fuel_amount = 0
		burn_rate = 2
		source_obj = null

/datum/fire/New(loc, type, source)
	location = loc
	fire_type = type
	source_obj = source
	
	switch(type)
		if("campfire") burn_rate = 2
		if("torch") burn_rate = 1
		if("forge") burn_rate = 3
		if("oven") burn_rate = 2.5
		if("smelter") burn_rate = 4
		else burn_rate = 2
	
	active_fires += src
	fire_sources[location] = src

/datum/fire/proc/IsLit()
	return (state == FIRE_STATE_LIT)

/datum/fire/proc/Light()
	if(state != FIRE_STATE_EXTINGUISHED) return FALSE
	if(fuel_amount < 1) return FALSE
	
	state = FIRE_STATE_LIT
	if(source_obj && isobj(source_obj))
		source_obj:OnFireLit()
	return TRUE

/datum/fire/proc/AddFuel(amount)
	fuel_amount = min(100, fuel_amount + amount)
	if(state == FIRE_STATE_DYING)
		state = FIRE_STATE_LIT
	return fuel_amount

/datum/fire/proc/Extinguish()
	state = FIRE_STATE_EXTINGUISHED
	fuel_amount = 0
	if(source_obj && isobj(source_obj))
		source_obj:OnFireExtinguished()

// ============================================================================
// FIRE SOURCE BASE CLASS
// ============================================================================

/obj/fire_source
	name = "fire source"
	desc = "A source of fire."
	icon = 'dmi/start.dmi'
	icon_state = "campfire"
	
	var
		datum/fire/fire_obj = null
		fire_type = "campfire"
		lit = FALSE

/obj/fire_source/New()
	. = ..()
	fire_obj = new /datum/fire(src.loc, fire_type, src)

/obj/fire_source/proc/IsLit()
	if(!fire_obj) return FALSE
	return fire_obj.IsLit()

/obj/fire_source/proc/OnFireLit()
	lit = TRUE
	icon_state = fire_type + "_lit"

/obj/fire_source/proc/OnFireExtinguished()
	lit = FALSE
	icon_state = fire_type + "_out"

// ============================================================================
// SPECIFIC FIRE SOURCES
// ============================================================================

/obj/fire_source/campfire
	name = "campfire"
	desc = "A simple fire pit for cooking and warmth."
	fire_type = "campfire"

/obj/fire_source/torch
	name = "torch"
	desc = "A hand-held torch for light and warmth."
	fire_type = "torch"
	icon_state = "torch"

/obj/fire_source/forge
	name = "forge"
	desc = "A smithing forge. Requires active fire."
	fire_type = "forge"

/obj/fire_source/oven
	name = "oven"
	desc = "A clay oven. Requires active fire."
	fire_type = "oven"

/obj/fire_source/smelter
	name = "smelter"
	desc = "A large smelting furnace. Requires active fire."
	fire_type = "smelter"

/obj/fire_source/brazier
	name = "brazier"
	desc = "A standing brazier for light and warmth."
	fire_type = "brazier"

// ============================================================================
// FIRE SYSTEM PROCS
// ============================================================================

/proc/InitializeFireSystem()
	if(fire_system_initialized) return
	fire_system_initialized = TRUE
	active_fires = list()
	fire_sources = list()
	spawn(0) FireSystemTick()
	world.log << "Fire System Initialized"

/proc/FireSystemTick()
	set background = 1
	set waitfor = 0
	
	while(world)
		sleep(1)
		if(!fire_system_initialized) continue
		
		for(var/datum/fire/F in active_fires)
			if(F.state == FIRE_STATE_LIT || F.state == FIRE_STATE_DYING)
				F.fuel_amount = max(0, F.fuel_amount - (F.burn_rate / 10))
				
				if(F.fuel_amount <= 0)
					F.state = FIRE_STATE_DYING
					spawn(10) F.Extinguish()
			
			if(F.state == FIRE_STATE_EXTINGUISHED && !F.source_obj)
				active_fires -= F

/proc/GetFireAt(location)
	return fire_sources[location]

/proc/HasActiveFire(location)
	var/datum/fire/F = fire_sources[location]
	if(F && F.IsLit())
		return TRUE
	return FALSE

/proc/CanCraftWithFire(mob/M, recipe_key, fire_loc)
	var/datum/recipe_entry/recipe = KNOWLEDGE[recipe_key]
	if(!recipe) return FALSE
	
	if(!recipe.requires_fire)
		return TRUE
	
	if(HasActiveFire(fire_loc))
		return TRUE
	
	if(M)
		M << "This recipe requires an active fire!"
	
	return FALSE

/proc/CanStartExperiment(mob/M, workstation_type, recipe_key)
	if(!M) return FALSE
	
	var/datum/recipe_entry/recipe = KNOWLEDGE[recipe_key]
	if(!recipe) return FALSE
	
	if(recipe.workstation_type != workstation_type && recipe.workstation_type != "none")
		M << "Wrong workstation type!"
		return FALSE
	
	if(recipe.requires_fire)
		var/has_fire = FALSE
		
		if(HasActiveFire(M.loc))
			has_fire = TRUE
		
		if(!has_fire)
			for(var/turf/T in range(2, M.loc))
				if(HasActiveFire(T))
					has_fire = TRUE
					break
		
		if(!has_fire)
			M << "This recipe requires an active fire nearby!"
			return FALSE
	
	return TRUE
