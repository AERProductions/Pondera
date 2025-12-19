/**
 * SoilDegradationSystem.dm - Soil degradation and nutrient depletion on harvest
 * 
 * Harvesting crops consumes soil nutrients and reduces fertility
 * Different crops deplete different nutrients
 * Crop rotation reduces penalty; monoculture increases it
 */

// ============================================================================
// NUTRIENT DEPLETION TABLES
// ============================================================================

/**
 * Define how much each crop type depletes soil nutrients
 * Returns: list(nitrogen_depletion, phosphorus_depletion, potassium_depletion)
 */
proc/GetNutrientDemand(var/crop_name)
	var/crop = lowertext(crop_name)
	
	switch(crop)
		// Leafy crops - high nitrogen demand
		if("lettuce", "spinach", "kale", "cabbage", "bok_choy")
			return list(20, 5, 8)
		
		// Root crops - high potassium demand
		if("potato", "carrot", "turnip", "radish", "beet")
			return list(8, 10, 20)
		
		// Fruit crops - high phosphorus demand
		if("tomato", "pepper", "cucumber", "pumpkin", "squash")
			return list(10, 18, 15)
		
		// Grain crops - balanced demand
		if("wheat", "rice", "corn", "barley")
			return list(15, 12, 12)
		
		// Berries - moderate balanced
		if("berry", "strawberry", "blueberry")
			return list(12, 10, 10)
		
		// Default moderate demand
		else
			return list(10, 10, 10)

/**
 * Get fertility loss on harvest
 * Base: -15 fertility
 * Monoculture penalty: -20 (total -35)
 * Rotation bonus: -10 (total -5, 5x less penalty)
 */
proc/GetFertilityLossOnHarvest(turf/T, var/crop_name)
	var/base_loss = 15
	
	// Get rotation modifier
	var/rotation_modifier = GetCropRotationModifier(T, crop_name)
	
	if(rotation_modifier >= 1.0)
		// Good rotation detected (bonus)
		return round(base_loss * 0.33)  // -5 fertility instead of -15
	else if(rotation_modifier < 0.95)
		// Monoculture detected (penalty)
		return round(base_loss * 2.33)  // -35 fertility instead of -15
	else
		// Normal/first year
		return base_loss

// ============================================================================
// HARVEST DEGRADATION
// ============================================================================

/**
 * Deplete soil on harvest
 * Called by FarmingIntegration when crop is harvested
 * 
 * Parameters:
 * - T: turf being harvested
 * - crop_name: name of crop harvested
 * - harvest_quality: 0.5-1.5 (affects degradation slightly)
 */
proc/DepleteSoilOnHarvest(turf/T, var/crop_name, var/harvest_quality = 1.0)
	if(!istype(T)) return FALSE
	
	// Initialize soil properties
	InitializeSoilProperties(T)
	
	// Get fertility loss
	var/fertility_loss = GetFertilityLossOnHarvest(T, crop_name)
	
	// Get nutrient demand
	var/list/demand = GetNutrientDemand(crop_name)
	var/n_demand = demand[1] * (harvest_quality * 0.8)  // Quality reduces demand slightly
	var/p_demand = demand[2] * (harvest_quality * 0.8)
	var/k_demand = demand[3] * (harvest_quality * 0.8)
	
	// Apply degradation
	ModifySoilFertility(T, -fertility_loss)
	ModifySoilNutrient(T, "nitrogen", -round(n_demand))
	ModifySoilNutrient(T, "phosphorus", -round(p_demand))
	ModifySoilNutrient(T, "potassium", -round(k_demand))
	
	// Update crop history
	SetLastCrop(T, crop_name)
	
	return TRUE

// ============================================================================
// SEASONAL DEGRADATION
// ============================================================================

/**
 * Apply end-of-season soil degradation
 * Called by seasonal system at season change
 * 
 * Represents:
 * - Natural nutrient leaching
 * - Microbial decomposition
 * - Erosion
 */
proc/ApplySeasonalDegradation(turf/T, var/season)
	if(!istype(T)) return FALSE
	
	InitializeSoilProperties(T)
	
	// Season-specific degradation
	switch(season)
		if("Spring", "Autumn")
			// Moderate degradation - transitional weather
			ModifySoilFertility(T, -3)
			ModifySoilNutrient(T, "nitrogen", -2)
			ModifySoilNutrient(T, "phosphorus", -1)
			ModifySoilNutrient(T, "potassium", -1)
		
		if("Summer")
			// High degradation - heat, drought stress
			ModifySoilFertility(T, -5)
			ModifySoilNutrient(T, "nitrogen", -3)
			ModifySoilNutrient(T, "phosphorus", -2)
			ModifySoilNutrient(T, "potassium", -2)
		
		if("Winter")
			// Low degradation - cold slows processes
			ModifySoilFertility(T, -1)
			ModifySoilNutrient(T, "nitrogen", -1)
	
	return TRUE

/**
 * Recover some fertility naturally over time
 * Simulates:
 * - Leaf litter decomposition
 * - Microbial nutrient cycling
 * - Deep root nutrient uptake
 */
proc/ApplyNaturalFertilityRecovery(turf/T, var/season)
	if(!istype(T)) return FALSE
	
	InitializeSoilProperties(T)
	
	// Recovery varies by season
	switch(season)
		if("Spring")
			// High recovery - growing season starts
			ModifySoilFertility(T, 4)
			ModifySoilNutrient(T, "nitrogen", 2)  // Nitrogen-fixing bacteria
		
		if("Summer")
			// Moderate recovery - active growth
			ModifySoilFertility(T, 2)
			ModifySoilNutrient(T, "nitrogen", 1)
		
		if("Autumn")
			// High recovery - leaf fall
			ModifySoilFertility(T, 5)
			ModifySoilNutrient(T, "nitrogen", 3)
			ModifySoilNutrient(T, "potassium", 2)  // Leaves high in K
		
		if("Winter")
			// Low recovery - dormancy
			ModifySoilFertility(T, 1)
	
	return TRUE

// ============================================================================
// CONTINENT-SPECIFIC DEGRADATION
// ============================================================================

/**
 * Adjust degradation based on continent
 */
proc/GetDegradationScalarForContinent(var/continent_id)
	switch(continent_id)
		if(CONTINENT_PEACEFUL)
			// Story/Normal: normal degradation
			return 1.0
		
		if(CONTINENT_CREATIVE)
			// Sandbox: no degradation, fertile paradise
			return 0.0
		
		if(CONTINENT_COMBAT)
			// PvP: harsh conditions, higher degradation
			return 1.5
		
		else
			return 1.0

/**
 * Apply continent-specific degradation modifier
 */
proc/DepleteSoilWithContinentScaling(turf/T, var/crop_name, var/continent_id, var/harvest_quality = 1.0)
	if(!istype(T)) return FALSE
	
	var/scalar = GetDegradationScalarForContinent(continent_id)
	
	if(scalar == 0.0)
		// Sandbox mode: no degradation
		return TRUE
	
	// Standard degradation adjusted by continent
	InitializeSoilProperties(T)
	
	var/fertility_loss = GetFertilityLossOnHarvest(T, crop_name)
	fertility_loss = round(fertility_loss * scalar)
	
	var/list/demand = GetNutrientDemand(crop_name)
	var/n_demand = round(demand[1] * scalar * (harvest_quality * 0.8))
	var/p_demand = round(demand[2] * scalar * (harvest_quality * 0.8))
	var/k_demand = round(demand[3] * scalar * (harvest_quality * 0.8))
	
	// Apply scaled degradation
	ModifySoilFertility(T, -fertility_loss)
	ModifySoilNutrient(T, "nitrogen", -n_demand)
	ModifySoilNutrient(T, "phosphorus", -p_demand)
	ModifySoilNutrient(T, "potassium", -k_demand)
	
	SetLastCrop(T, crop_name)
	
	return TRUE

// ============================================================================
// RECOVERY & MANAGEMENT
// ============================================================================

/**
 * Fallow period recovery - leaving land unfarmed restores soil
 * Apply when season changes without harvesting
 */
proc/ApplyFallowRecovery(turf/T)
	if(!istype(T)) return FALSE
	
	InitializeSoilProperties(T)
	
	// Significant fertility recovery
	ModifySoilFertility(T, 20)
	ModifySoilNutrient(T, "nitrogen", 10)
	ModifySoilNutrient(T, "phosphorus", 5)
	ModifySoilNutrient(T, "potassium", 8)
	
	// Clear crop history to enable rotation bonus next harvest
	SetLastCrop(T, "none")
	
	return TRUE

/**
 * Check soil health status
 * Returns: "Critical", "Poor", "Fair", "Good", "Excellent"
 */
proc/GetSoilHealthStatus(turf/T)
	if(!istype(T)) return "Unknown"
	
	InitializeSoilProperties(T)
	
	var/fertility = GetSoilFertility(T)
	var/n = GetSoilNutrient(T, "nitrogen")
	var/p = GetSoilNutrient(T, "phosphorus")
	var/k = GetSoilNutrient(T, "potassium")
	var/avg_nutrients = (n + p + k) / 3
	
	var/health_score = fertility + (avg_nutrients * 0.5)
	
	if(health_score < 50)
		return "Critical"
	else if(health_score < 100)
		return "Poor"
	else if(health_score < 150)
		return "Fair"
	else if(health_score < 200)
		return "Good"
	else
		return "Excellent"

// ============================================================================
// ANALYTICS & DIAGNOSTICS
// ============================================================================

/**
 * Debug: Show degradation info for a crop
 */
proc/DebugCropDegradation(var/crop_name)
	var/list/demand = GetNutrientDemand(crop_name)
	world.log << "\[DEGRADATION\] [crop_name]: N-[demand[1]] P-[demand[2]] K-[demand[3]]"

/**
 * Get total nutrient depletion stats by continent
 */
proc/GetDegradationStatsByContinent()
	var/list/stats = list()
	stats["peaceful"] = GetDegradationScalarForContinent(CONTINENT_PEACEFUL)
	stats["creative"] = GetDegradationScalarForContinent(CONTINENT_CREATIVE)
	stats["combat"] = GetDegradationScalarForContinent(CONTINENT_COMBAT)
	return stats
