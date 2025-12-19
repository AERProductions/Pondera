// SeasonalModifierProcessor.dm - Phase 7: Seasonal Modifier Integration
// Applies seasonal modifiers to farming, livestock, market pricing, and consumption systems
// Integrates with SeasonalEventsHook.dm to implement actual game mechanics

// ============================================================================
// SEASONAL MODIFIER STATE
// ============================================================================

var/global/
	current_season_modifiers = list(
		"crop_growth_modifier" = 1.0,
		"breeding_season_active" = FALSE,
		"breeding_success_rate" = 0,
		"animal_production_modifier" = 1.0,
		"soil_recovery_modifier" = 1.0,
		"harvest_yield_modifier" = 1.0,
		"food_price_modifier" = 1.0,
		"consumption_rate_modifier" = 1.0
	)

// ============================================================================
// SEASONAL MODIFIER INITIALIZATION
// ============================================================================

/proc/InitializeSeasonalModifierProcessor()
	/**
	 * Initialize seasonal modifier system
	 * Called from InitializationManager.dm (Phase 7, tick 388)
	 */
	
	world << "SEASONAL Seasonal Modifier Processor initialized"
	UpdateSeasonalModifiersForCurrentSeason()
	return 1

// ============================================================================
// APPLY SEASONAL MODIFIERS
// ============================================================================

/proc/UpdateSeasonalModifiersForCurrentSeason()
	/**
	 * Update all seasonal modifiers based on current season
	 * Called on season transition or initialization
	 */
	
	if(!global.current_season)
		return 0
	
	var/season = global.current_season
	
	// Reset all modifiers to neutral
	ResetSeasonalModifiers()
	
	// Apply season-specific modifiers
	switch(season)
		if("Spring")
			ApplySpringModifiers()
		if("Summer")
			ApplySummerModifiers()
		if("Autumn")
			ApplyAutumnModifiers()
		if("Winter")
			ApplyWinterModifiers()
	
	// Broadcast to players
	NotifyPlayersOfModifiers(season)
	return 1

/proc/ResetSeasonalModifiers()
	/**
	 * Reset all modifiers to neutral (1.0 or FALSE)
	 */
	
	current_season_modifiers["crop_growth_modifier"] = 1.0
	current_season_modifiers["breeding_season_active"] = FALSE
	current_season_modifiers["breeding_success_rate"] = 0
	current_season_modifiers["animal_production_modifier"] = 1.0
	current_season_modifiers["soil_recovery_modifier"] = 1.0
	current_season_modifiers["harvest_yield_modifier"] = 1.0
	current_season_modifiers["food_price_modifier"] = 1.0
	current_season_modifiers["consumption_rate_modifier"] = 1.0

/proc/ApplySpringModifiers()
	/**
	 * Spring Modifiers:
	 * - Crop growth +15%
	 * - Breeding season active (80% success)
	 * - Food prices +30% (transition from winter scarcity)
	 * - Normal consumption
	 */
	
	current_season_modifiers["crop_growth_modifier"] = 1.15
	current_season_modifiers["breeding_season_active"] = TRUE
	current_season_modifiers["breeding_success_rate"] = 80
	current_season_modifiers["food_price_modifier"] = 1.3
	current_season_modifiers["consumption_rate_modifier"] = 1.0

/proc/ApplySummerModifiers()
	/**
	 * Summer Modifiers:
	 * - Crop growth +20% (peak season)
	 * - Breeding season active (70% success)
	 * - Animal production +30%
	 * - Food prices -40% (abundance)
	 * - Consumption +25% (heat stress)
	 */
	
	current_season_modifiers["crop_growth_modifier"] = 1.20
	current_season_modifiers["breeding_season_active"] = TRUE
	current_season_modifiers["breeding_success_rate"] = 70
	current_season_modifiers["animal_production_modifier"] = 1.3
	current_season_modifiers["food_price_modifier"] = 0.6
	current_season_modifiers["consumption_rate_modifier"] = 1.25

/proc/ApplyAutumnModifiers()
	/**
	 * Autumn Modifiers:
	 * - Crop growth +10%
	 * - Breeding season declining (50% success)
	 * - Animal production +20%
	 * - Soil recovery +25%
	 * - Harvest yield +10%
	 * - Food prices -30% (harvest abundance)
	 * - Normal consumption
	 */
	
	current_season_modifiers["crop_growth_modifier"] = 1.10
	current_season_modifiers["breeding_season_active"] = TRUE
	current_season_modifiers["breeding_success_rate"] = 50
	current_season_modifiers["animal_production_modifier"] = 1.2
	current_season_modifiers["soil_recovery_modifier"] = 1.25
	current_season_modifiers["harvest_yield_modifier"] = 1.10
	current_season_modifiers["food_price_modifier"] = 0.7
	current_season_modifiers["consumption_rate_modifier"] = 1.0

/proc/ApplyWinterModifiers()
	/**
	 * Winter Modifiers:
	 * - Crop growth 0% (no outdoor growth)
	 * - Breeding season disabled (5% success)
	 * - Animal production -40%
	 * - Food prices +50% (scarcity)
	 * - Consumption +50% (extreme cold)
	 */
	
	current_season_modifiers["crop_growth_modifier"] = 0.0
	current_season_modifiers["breeding_season_active"] = FALSE
	current_season_modifiers["breeding_success_rate"] = 5
	current_season_modifiers["animal_production_modifier"] = 0.6
	current_season_modifiers["food_price_modifier"] = 1.5
	current_season_modifiers["consumption_rate_modifier"] = 1.5

// ============================================================================
// MODIFIER QUERIES
// ============================================================================

/proc/GetCropGrowthModifier()
	/**
	 * Get current crop growth rate modifier
	 * Used by FarmingIntegration.dm for turf growth calculations
	 * 
	 * @return: Multiplier (0.0 - 1.5)
	 */
	
	return current_season_modifiers["crop_growth_modifier"] || 1.0

/proc/GetBreedingSeasonActive()
	/**
	 * Check if breeding season is active
	 * Used by LivestockSystem.dm
	 * 
	 * @return: TRUE if breeding enabled
	 */
	
	return current_season_modifiers["breeding_season_active"] || FALSE

/proc/GetBreedingSuccessRate()
	/**
	 * Get current breeding success percentage
	 * Used by LivestockSystem.dm
	 * 
	 * @return: Percentage (0-100)
	 */
	
	return current_season_modifiers["breeding_success_rate"] || 0

/proc/GetAnimalProductionModifier()
	/**
	 * Get animal production multiplier (milk, eggs, wool)
	 * Used by LivestockSystem.dm
	 * 
	 * @return: Multiplier (0.6 - 1.3)
	 */
	
	return current_season_modifiers["animal_production_modifier"] || 1.0

/proc/GetSoilRecoveryModifier()
	/**
	 * Get soil recovery rate multiplier
	 * Used by FarmingIntegration.dm for soil health restoration
	 * 
	 * @return: Multiplier (1.0 - 1.25)
	 */
	
	return current_season_modifiers["soil_recovery_modifier"] || 1.0

/proc/GetHarvestYieldModifier()
	/**
	 * Get harvest yield multiplier
	 * Used by FarmingIntegration.dm when harvesting crops
	 * 
	 * @return: Multiplier (1.0 - 1.1)
	 */
	
	return current_season_modifiers["harvest_yield_modifier"] || 1.0

/proc/GetFoodPriceModifier()
	/**
	 * Get food price multiplier
	 * Used by DynamicMarketPricingSystem.dm
	 * 
	 * Example: Base price 100, modifier 0.6 = 60 (60% of normal)
	 * 
	 * @return: Multiplier (0.6 - 1.5)
	 */
	
	return current_season_modifiers["food_price_modifier"] || 1.0

/proc/GetConsumptionRateModifier()
	/**
	 * Get consumption rate multiplier
	 * Used by HungerThirstSystem.dm for hunger/thirst tick calculations
	 * 
	 * @return: Multiplier (1.0 - 1.5)
	 */
	
	return current_season_modifiers["consumption_rate_modifier"] || 1.0

// ============================================================================
// INTEGRATION HOOKS FOR EXISTING SYSTEMS
// ============================================================================

/proc/ApplySeasonalConsumption(mob/players/player)
	/**
	 * Apply seasonal consumption rate modifier to player
	 * Called by HungerThirstSystem.dm hunger tick processor
	 * 
	 * @param player: Player to apply consumption modifier to
	 */
	
	if(!player) return 0
	
	var/modifier = GetConsumptionRateModifier()
	if(modifier == 1.0) return 0  // No change
	
	// Reduce hunger tick delays by modifier (higher modifier = faster consumption)
	// If normal hunger tick = 20, and modifier = 1.5, effective tick = 20/1.5 = 13.3
	var/adjusted_delay = 20 / modifier
	
	return adjusted_delay

/proc/ApplySeasonalCropGrowth(turf/T)
	/**
	 * Apply seasonal modifier to crop growth rate
	 * Called by FarmingIntegration.dm turf growth calculations
	 * 
	 * @param T: Turf with crop
	 * @return: Modified growth rate
	 */
	
	if(!T) return 0
	
	var/base_growth = 1  // Default growth rate
	var/modifier = GetCropGrowthModifier()
	
	// Return the adjusted growth rate for crops
	// Actual crop data would be stored in turf variables
	return base_growth * modifier

/proc/ApplySeasonalBreeding(animal)
	/**
	 * Apply seasonal breeding modifiers to livestock
	 * Called by LivestockSystem.dm breeding processor
	 * 
	 * @param animal: Livestock object/datum to check breeding for
	 * @return: TRUE if breeding allowed and successful
	 */
	
	if(!animal) return 0
	
	if(!GetBreedingSeasonActive())
		return FALSE  // Breeding disabled this season
	
	var/success_rate = GetBreedingSuccessRate()
	var/roll = rand(1, 100)
	
	return roll <= success_rate

// ============================================================================
// NOTIFICATION SYSTEM
// ============================================================================

/proc/NotifyPlayersOfModifiers(season)
	/**
	 * Broadcast seasonal modifiers to all players
	 * Helps players understand current economy/farming conditions
	 * 
	 * @param season: Current season name
	 */
	
	for(var/mob/players/M in world)
		if(M.client)
			M << "<font color=#FFAA00>─── SEASONAL MODIFIERS ───</font>"
			M << "<font color=#FFAA00>Crop Growth: [current_season_modifiers["crop_growth_modifier"] * 100]%</font>"
			M << "<font color=#FFAA00>Food Price: [current_season_modifiers["food_price_modifier"] * 100]%</font>"
			M << "<font color=#FFAA00>Animal Production: [current_season_modifiers["animal_production_modifier"] * 100]%</font>"
			M << "<font color=#FFAA00>Consumption Rate: [current_season_modifiers["consumption_rate_modifier"] * 100]%</font>"
			if(GetBreedingSeasonActive())
				M << "<font color=#00FF00>✓ Breeding Season Active ([GetBreedingSuccessRate()]% success)</font>"
			else
				M << "<font color=#FF5555>✗ Breeding Season Inactive</font>"

// ============================================================================
// ADMIN COMMANDS
// ============================================================================

/proc/AdminGetSeasonalModifiers()
	/**
	 * Admin command: Display current modifiers
	 */
	
	var/output = "<b>CURRENT SEASONAL MODIFIERS</b>\n"
	output += "Season: [global.current_season]\n\n"
	
	if(current_season_modifiers)
		for(var/key in current_season_modifiers)
			output += "[key]: [current_season_modifiers[key]]\n"
	else
		output += "No modifiers initialized\n"
	
	return output

/proc/AdminSetSeasonalModifier(modifier_name, value)
	/**
	 * Admin command: Override seasonal modifier
	 * For testing and emergency adjustments
	 * 
	 * @param modifier_name: Name of modifier to override
	 * @param value: New value
	 */
	
	if(!current_season_modifiers) return 0
	if(!(modifier_name in current_season_modifiers)) return 0
	
	var/old_value = current_season_modifiers[modifier_name]
	current_season_modifiers[modifier_name] = value
	
	world << "SEASONAL OVERRIDE: [modifier_name] = [value] (was [old_value])"
	return 1
