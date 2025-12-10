/**
 * ExperimentationWorkstations.dm
 * ==============================
 * Phase C.2b: Recipe Experimentation UI & Workstation Objects
 * 
 * Implements cauldrons, forges, and workbenches where players experiment
 * with recipes. These are building objects that link to RecipeExperimentationSystem.
 * 
 * Integration:
 * - BuildingMenuUI.dm: Building recipe system
 * - RecipeExperimentationSystem.dm: Experimentation logic
 * - AudioIntegrationSystem.dm: Experimentation failure/success sounds
 */

// ============================================================================
// CAULDRON - COOKING EXPERIMENTATION WORKSTATION
// ============================================================================

/obj/Buildable/Cauldron
	name = "Cauldron"
	desc = "A large metal cauldron for cooking and ingredient experimentation."
	icon = 'dmi/64/fire.dmi'
	icon_state = "cauldron"
	density = 1
	opacity = 0
	pixel_x = 0
	pixel_y = 0
	layer = 5
	
	var/is_active = FALSE  // Currently being used for experimentation
	var/current_experimenter = null  // Player currently experimenting
	var/last_experiment_time = 0  // Cooldown tracking
	var/EXPERIMENT_COOLDOWN = 50  // 2.5 seconds between experiments (50 ticks / 20 = 2.5s)

/obj/Buildable/Cauldron/New(location)
	..()
	if(location)
		src.loc = location
	
	// Attach water/steam ambient sound (Phase C.1 integration)
	AttachWaterSound(src)

/obj/Buildable/Cauldron/Click()
	/**
	 * Right-click cauldron to open experimentation menu
	 */
	if(!usr)
		return
	
	if(!istype(usr, /mob/players))
		usr << "Only players can use the cauldron."
		return
	
	// Check cooldown
	if(world.time < last_experiment_time + EXPERIMENT_COOLDOWN)
		usr << "The cauldron needs time to cool before the next experiment."
		return
	
	// Show experimentation menu
	ShowExperimentationMenu(usr, "cauldron")

/obj/Buildable/Cauldron/verb/Experiment()
	/**
	 * Verb to start recipe experimentation
	 * Opens ingredient selection interface
	 */
	set src in oview(1)
	set category = null
	
	if(!usr || !istype(usr, /mob/players))
		return
	
	var/mob/players/player = usr
	var/datum/experimentation_ui/ui = new /datum/experimentation_ui()
	ui.Initialize(player, src, "cauldron")

// ============================================================================
// FORGE - SMITHING EXPERIMENTATION WORKSTATION
// ============================================================================

/obj/Buildable/Forge
	name = "Forge"
	desc = "A roaring forge for smelting and smithing experimentation."
	icon = 'dmi/64/fire.dmi'
	icon_state = "forge"
	density = 1
	opacity = 0
	pixel_x = 0
	pixel_y = 0
	layer = 5
	
	var/is_active = FALSE
	var/current_experimenter = null
	var/last_experiment_time = 0
	var/EXPERIMENT_COOLDOWN = 80  // Forge takes longer (4 seconds)
	var/temperature = 0  // 0-100 heat level

/obj/Buildable/Forge/New(location)
	..()
	if(location)
		src.loc = location
	
	// Attach fire/ambient sound (Phase C.1 integration)
	AttachFireSound(src)

/obj/Buildable/Forge/Click()
	if(!usr)
		return
	
	if(!istype(usr, /mob/players))
		usr << "Only players can use the forge."
		return
	
	if(world.time < last_experiment_time + EXPERIMENT_COOLDOWN)
		usr << "The forge is still too hot. Wait for it to cool."
		return
	
	ShowExperimentationMenu(usr, "forge")

/obj/Buildable/Forge/verb/Experiment()
	set src in oview(1)
	set category = null
	
	if(!usr || !istype(usr, /mob/players))
		return
	
	var/mob/players/player = usr
	var/datum/experimentation_ui/ui = new /datum/experimentation_ui()
	ui.Initialize(player, src, "forge")

// ============================================================================
// ANVIL - SMITHING REFINEMENT & METAL EXPERIMENTATION
// ============================================================================
// The Anvil is the heart of smithing. It's where you hammer hot metal
// into refined tools and weapons. As an experimentation station, it's where
// players discover advanced smithing recipes through trial and error.

/obj/Buildable/Smithing/Anvil
	name = "Anvil"
	desc = "A sturdy iron anvil for smithing and metal refinement. Perfect for experimentation with metal-working recipes."
	icon = 'dmi/64/fire.dmi'
	icon_state = "anvil"
	density = 1
	opacity = 0
	pixel_x = 0
	pixel_y = 0
	layer = 5
	
	var/is_active = FALSE
	var/current_experimenter = null
	var/last_experiment_time = 0
	var/EXPERIMENT_COOLDOWN = 100  // Anvil work is precise (5 seconds)
	var/durability = 100  // Anvil can wear down (future enhancement)

/obj/Buildable/Smithing/Anvil/New(location)
	..()
	if(location)
		src.loc = location
	
	// Attach anvil sound effect (Phase C.1 integration)
	AttachAnvilSound(src)

/obj/Buildable/Smithing/Anvil/Click()
	if(!usr)
		return
	
	if(!istype(usr, /mob/players))
		usr << "Only players can use the anvil."
		return
	
	if(world.time < last_experiment_time + EXPERIMENT_COOLDOWN)
		usr << "You need time to hammer out the last piece. Wait a moment."
		return
	
	ShowExperimentationMenu(usr, "smithing")

/obj/Buildable/Smithing/Anvil/verb/Experiment()
	/**
	 * Smithing experimentation verb
	 * Opens the experimentation UI for anvil work
	 */
	set src in oview(1)
	set category = null
	set name = "Experiment with Metals"
	
	if(!usr || !istype(usr, /mob/players))
		return
	
	var/mob/players/player = usr
	var/datum/experimentation_ui/ui = new /datum/experimentation_ui()
	ui.Initialize(player, src, "smithing")

/obj/Buildable/Smithing/Anvil/proc/HammerMetal(mob/players/smith, obj/item/ingot)
	/**
	 * Actual hammer action on the anvil
	 * Called during successful experimentation
	 * 
	 * Future enhancement: Create visual animation of hammering
	 */
	if(!smith || !ingot)
		return
	
	// Sound effect of hammer striking anvil
	PlayAnvilHammerSound(smith, src)
	
	// Visual feedback - temporary sparks/impact
	// TODO: Implement spark effects around anvil

// ============================================================================
// WORKBENCH - GENERAL CRAFTING EXPERIMENTATION
// ============================================================================

/obj/Buildable/Workbench
	name = "Workbench"
	desc = "A sturdy workbench for crafting and tool experimentation."
	icon = 'dmi/64/fire.dmi'
	icon_state = "workbench"
	density = 1
	opacity = 0
	pixel_x = 0
	pixel_y = 0
	layer = 5
	
	var/is_active = FALSE
	var/current_experimenter = null
	var/last_experiment_time = 0
	var/EXPERIMENT_COOLDOWN = 50

/obj/Buildable/Workbench/New(location)
	..()
	if(location)
		src.loc = location

/obj/Buildable/Workbench/Click()
	if(!usr)
		return
	
	if(!istype(usr, /mob/players))
		usr << "Only players can use the workbench."
		return
	
	if(world.time < last_experiment_time + EXPERIMENT_COOLDOWN)
		usr << "You need to prepare the workbench. Try again in a moment."
		return
	
	ShowExperimentationMenu(usr, "workbench")

/obj/Buildable/Workbench/verb/Experiment()
	set src in oview(1)
	set category = null
	
	if(!usr || !istype(usr, /mob/players))
		return
	
	var/mob/players/player = usr
	var/datum/experimentation_ui/ui = new /datum/experimentation_ui()
	ui.Initialize(player, src, "workbench")

// ============================================================================
// EXPERIMENTATION WORKSTATION BASE UTILITIES
// ============================================================================

/proc/IsExperimentationWorkstation(obj/building)
	/**
	 * Check if building is a valid experimentation workstation
	 */
	if(!building)
		return FALSE
	
	return istype(building, /obj/Buildable/Cauldron) || \
	       istype(building, /obj/Buildable/Forge) || \
	       istype(building, /obj/Buildable/Smithing/Anvil) || \
	       istype(building, /obj/Buildable/Workbench)

/proc/GetWorkstationType(obj/building)
	/**
	 * Get the workstation type identifier
	 */
	if(istype(building, /obj/Buildable/Cauldron))
		return "cauldron"
	else if(istype(building, /obj/Buildable/Forge))
		return "forge"
	else if(istype(building, /obj/Buildable/Smithing/Anvil))
		return "smithing"
	else if(istype(building, /obj/Buildable/Workbench))
		return "workbench"
	
	return null

/proc/UpdateWorkstationCooldown(obj/building)
	/**
	 * Reset cooldown timer after experimentation
	 */
	if(!building || !IsExperimentationWorkstation(building))
		return
	
	building.vars["last_experiment_time"] = world.time
	building.vars["is_active"] = FALSE

/proc/IsWorkstationReady(obj/building)
	/**
	 * Check if workstation is ready for next experiment
	 */
	if(!building || !IsExperimentationWorkstation(building))
		return FALSE
	
	var/last_time = building.vars["last_experiment_time"] || 0
	var/cooldown = building.vars["EXPERIMENT_COOLDOWN"] || 50
	
	return world.time >= (last_time + cooldown)

// ============================================================================
// INTEGRATION POINTS FOR FUTURE UI
// ============================================================================

/proc/StartExperimentationUI(mob/players/player, obj/building)
	/**
	 * Main entry point for starting experimentation
	 * Called when player clicks "Experiment" after selecting ingredients
	 * 
	 * TODO: Build visual interface for ingredient selection and confirmation
	 * TODO: Show success/failure feedback with audio (Phase C.1)
	 * TODO: Track experimentation progress in player HUD
	 */
	if(!player || !building)
		return FALSE
	
	var/workstation_type = GetWorkstationType(building)
	if(!workstation_type)
		return FALSE
	
	// Check workstation ready
	if(!IsWorkstationReady(building))
		player << "The workstation is still cooling down."
		return FALSE
	
	// Get ingredients from inventory
	var/list/ingredients = GetIngredientListFromInventory(player, workstation_type)
	
	if(!ingredients || ingredients.len == 0)
		player << "You need ingredients to experiment."
		return FALSE
	
	// TODO: Show recipe selection menu (recipes player hasn't discovered)
	// TODO: Let player select specific ingredients to combine
	// TODO: Validate combination and process experimentation
	
	player << "Full experimentation UI coming in Phase C.2c"
	return FALSE

// ============================================================================
// DOCUMENTATION: EXPERIMENTATION WORKSTATION FLOW
// ============================================================================

/**
 * PLAYER EXPERIMENTATION WORKFLOW
 * ===============================
 * 
 * 1. Player builds/places Cauldron/Forge/Workbench (building menu)
 * 2. Player right-clicks workstation to open experimentation UI
 * 3. System shows:
 *    - List of undiscovered recipes player can experiment with
 *    - Available ingredients in player inventory
 * 4. Player selects recipe and ingredients to combine
 * 5. System validates if combination matches recipe signature
 * 6. If valid: Recipe unlocked, ingredients consumed, bonus XP awarded
 *    If invalid: Attempt counter +1, 50% of ingredients consumed
 * 7. After 10 attempts: Recipe auto-unlocked with standard XP
 * 
 * WORKSTATION DIFFERENCES
 * =======================
 * - Cauldron: Cooking recipes (vegetables, meats, spices)
 * - Forge: Smelting & smithing (ores, ingots, metals)
 * - Workbench: Crafting & tools (wood, stone, materials)
 * 
 * Each has different cooldown and ingredient requirements
 * 
 * AUDIO INTEGRATION
 * =================
 * - Fire/water ambient sounds via Phase C.1 (AttachFireSound, AttachWaterSound)
 * - Success: PlayRecipeDiscoverSound() when recipe unlocked
 * - Failure: (TODO) Sizzle/clang/error sound for failed attempts
 */
