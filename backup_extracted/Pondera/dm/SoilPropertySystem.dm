/**
 * SoilPropertySystem.dm - Soil property tracking and management
 * 
 * Tracks individual soil properties per turf:
 * - Fertility (0-200): overall soil quality
 * - pH level (6.0-8.0): acidity/alkalinity
 * - Nutrients (N/P/K 0-100): macro nutrient levels
 * - Moisture (0-100%): water content
 * - Crop history: last crop planted and harvest tick
 * 
 * These properties directly affect:
 * - Crop growth rate
 * - Harvest yield
 * - Food quality
 */

// ============================================================================
// SOIL PROPERTY CONSTANTS
// ============================================================================

#define SOIL_FERTILITY_MIN 0
#define SOIL_FERTILITY_MAX 200
#define SOIL_FERTILITY_DEPLETED 50
#define SOIL_FERTILITY_BASIC 120

#define SOIL_PH_ACIDIC 6.0
#define SOIL_PH_NEUTRAL 7.0
#define SOIL_PH_ALKALINE 8.0

#define SOIL_NUTRIENT_MIN 0
#define SOIL_NUTRIENT_MAX 100
#define SOIL_NUTRIENT_DEFICIENT 30

#define SOIL_MOISTURE_MIN 0
#define SOIL_MOISTURE_MAX 100

// ============================================================================
// TURF SOIL PROPERTIES (added to /turf/soil)
// ============================================================================

/**
 * Initialize soil properties on a turf
 * Call during map generation or on first planting
 */
proc/InitializeSoilProperties(turf/T)
	if(!istype(T)) return
	
	if(!T.vars["soil_fertility"])
		T.vars["soil_fertility"] = 100          // Basic soil fertility
	if(!T.vars["soil_ph"])
		T.vars["soil_ph"] = 7.0                 // Neutral pH
	if(!T.vars["soil_nitrogen"])
		T.vars["soil_nitrogen"] = 50
	if(!T.vars["soil_phosphorus"])
		T.vars["soil_phosphorus"] = 50
	if(!T.vars["soil_potassium"])
		T.vars["soil_potassium"] = 50
	if(!T.vars["soil_moisture"])
		T.vars["soil_moisture"] = 60            // 60% moisture (optimal)
	if(!T.vars["soil_last_crop"])
		T.vars["soil_last_crop"] = ""
	if(!T.vars["soil_last_harvest_tick"])
		T.vars["soil_last_harvest_tick"] = 0

// ============================================================================
// FERTILITY GETTERS & SETTERS
// ============================================================================

/**
 * Get current fertility level (0-200)
 */
proc/GetSoilFertility(turf/T)
	if(!istype(T)) return 100
	InitializeSoilProperties(T)
	return T.vars["soil_fertility"] || 100

/**
 * Set fertility level with bounds checking
 */
proc/SetSoilFertility(turf/T, var/new_fertility)
	if(!istype(T)) return
	InitializeSoilProperties(T)
	T.vars["soil_fertility"] = clamp(new_fertility, SOIL_FERTILITY_MIN, SOIL_FERTILITY_MAX)

/**
 * Add/subtract fertility (for compost application or degradation)
 */
proc/ModifySoilFertility(turf/T, var/delta)
	if(!istype(T)) return
	var/current = GetSoilFertility(T)
	SetSoilFertility(T, current + delta)

/**
 * Get soil type based on current fertility
 */
proc/GetSoilTypeFromFertility(var/fertility_level)
	if(fertility_level <= SOIL_FERTILITY_DEPLETED)
		return SOIL_DEPLETED
	else if(fertility_level >= SOIL_FERTILITY_BASIC)
		return SOIL_RICH
	else
		return SOIL_BASIC

/**
 * Get soil type for a turf
 */
proc/GetTurfSoilType(turf/T)
	var/fertility = GetSoilFertility(T)
	return GetSoilTypeFromFertility(fertility)

// ============================================================================
// PH LEVEL GETTERS & SETTERS
// ============================================================================

/**
 * Get soil pH level (6.0-8.0, 7.0 is neutral)
 */
proc/GetSoilPH(turf/T)
	if(!istype(T)) return SOIL_PH_NEUTRAL
	InitializeSoilProperties(T)
	return T.vars["soil_ph"] || SOIL_PH_NEUTRAL

/**
 * Set pH with bounds
 */
proc/SetSoilPH(turf/T, var/new_ph)
	if(!istype(T)) return
	InitializeSoilProperties(T)
	T.vars["soil_ph"] = clamp(new_ph, SOIL_PH_ACIDIC, SOIL_PH_ALKALINE)

/**
 * Adjust pH toward neutral (for compost)
 */
proc/AdjustSoilPHTowardNeutral(turf/T, var/delta)
	if(!istype(T)) return
	var/current_ph = GetSoilPH(T)
	var/new_ph
	
	if(current_ph < SOIL_PH_NEUTRAL)
		new_ph = min(current_ph + delta, SOIL_PH_NEUTRAL)
	else if(current_ph > SOIL_PH_NEUTRAL)
		new_ph = max(current_ph - delta, SOIL_PH_NEUTRAL)
	else
		new_ph = current_ph
	
	SetSoilPH(T, new_ph)

/**
 * Get pH growth modifier (affects crop growth rate)
 * Neutral (7.0) = 1.0
 * Acidic/Alkaline = 0.9-1.0
 */
proc/GetPHGrowthModifier(turf/T)
	var/ph = GetSoilPH(T)
	var/deviation = abs(ph - SOIL_PH_NEUTRAL)  // How far from neutral
	
	// -10% growth per 0.5 pH away from neutral
	return max(0.9, 1.0 - (deviation * 0.2))

// ============================================================================
// NUTRIENT GETTERS & SETTERS
// ============================================================================

/**
 * Get individual nutrient level (0-100)
 */
proc/GetSoilNutrient(turf/T, var/nutrient_type)  // "nitrogen", "phosphorus", "potassium"
	if(!istype(T)) return 50
	InitializeSoilProperties(T)
	
	switch(nutrient_type)
		if("nitrogen") return T.vars["soil_nitrogen"] || 50
		if("phosphorus") return T.vars["soil_phosphorus"] || 50
		if("potassium") return T.vars["soil_potassium"] || 50
		else return 50

/**
 * Set nutrient level with bounds
 */
proc/SetSoilNutrient(turf/T, var/nutrient_type, var/new_level)
	if(!istype(T)) return
	InitializeSoilProperties(T)
	new_level = clamp(new_level, SOIL_NUTRIENT_MIN, SOIL_NUTRIENT_MAX)
	
	switch(nutrient_type)
		if("nitrogen") T.vars["soil_nitrogen"] = new_level
		if("phosphorus") T.vars["soil_phosphorus"] = new_level
		if("potassium") T.vars["soil_potassium"] = new_level

/**
 * Modify nutrient (add/subtract)
 */
proc/ModifySoilNutrient(turf/T, var/nutrient_type, var/delta)
	var/current = GetSoilNutrient(T, nutrient_type)
	SetSoilNutrient(T, nutrient_type, current + delta)

/**
 * Get composite nutrient yield modifier
 * Different crops need different N/P/K ratios
 */
proc/GetNutrientYieldModifier(turf/T, var/crop_name)
	if(!istype(T)) return 1.0
	
	var/n = GetSoilNutrient(T, "nitrogen")
	var/p = GetSoilNutrient(T, "phosphorus")
	var/k = GetSoilNutrient(T, "potassium")
	
	var/modifier = 1.0
	
	// Crop-specific nutrient preferences
	switch(lowertext(crop_name))
		// Leafy crops love nitrogen
		if("lettuce", "spinach", "kale")
			if(n >= 75) modifier += 0.15
			else if(n < SOIL_NUTRIENT_DEFICIENT) modifier -= 0.20
		
		// Root crops love potassium
		if("potato", "carrot", "turnip")
			if(k >= 75) modifier += 0.15
			else if(k < SOIL_NUTRIENT_DEFICIENT) modifier -= 0.20
		
		// Fruits love phosphorus
		if("tomato", "pepper", "cucumber")
			if(p >= 75) modifier += 0.15
			else if(p < SOIL_NUTRIENT_DEFICIENT) modifier -= 0.20
		
		// Grains need balanced nutrition
		if("wheat", "corn", "barley")
			var/avg = (n + p + k) / 3
			if(avg >= 75) modifier += 0.10
			else if(avg < SOIL_NUTRIENT_DEFICIENT) modifier -= 0.15
	
	return max(0.5, min(2.0, modifier))  // Clamp between 0.5x and 2.0x

// ============================================================================
// MOISTURE GETTERS & SETTERS
// ============================================================================

/**
 * Get soil moisture (0-100%)
 */
proc/GetSoilMoisture(turf/T)
	if(!istype(T)) return 60
	InitializeSoilProperties(T)
	return T.vars["soil_moisture"] || 60

/**
 * Set moisture with bounds
 */
proc/SetSoilMoisture(turf/T, var/new_moisture)
	if(!istype(T)) return
	InitializeSoilProperties(T)
	T.vars["soil_moisture"] = clamp(new_moisture, SOIL_MOISTURE_MIN, SOIL_MOISTURE_MAX)

/**
 * Get moisture growth modifier
 * 40-70% optimal, <40% or >70% penalties
 */
proc/GetMoistureGrowthModifier(turf/T)
	var/moisture = GetSoilMoisture(T)
	
	if(moisture < 40)
		return 0.85  // Too dry: -15% growth
	else if(moisture > 70)
		return 1.1   // Very wet: +10% growth (for water-loving crops)
	else
		return 1.0   // Optimal: normal growth

// ============================================================================
// CROP HISTORY & ROTATION
// ============================================================================

/**
 * Get last crop planted on this turf
 */
proc/GetLastCrop(turf/T)
	if(!istype(T)) return ""
	InitializeSoilProperties(T)
	return T.vars["soil_last_crop"] || ""

/**
 * Set last crop (call on harvest)
 */
proc/SetLastCrop(turf/T, var/crop_name)
	if(!istype(T)) return
	InitializeSoilProperties(T)
	T.vars["soil_last_crop"] = crop_name
	T.vars["soil_last_harvest_tick"] = world.time

/**
 * Get crop rotation bonus/penalty
 */
proc/GetCropRotationModifier(turf/T, var/crop_name)
	var/last_crop = GetLastCrop(T)
	
	if(!last_crop || last_crop == "")
		return 1.0  // First crop, no bonus/penalty
	
	if(lowertext(last_crop) == lowertext(crop_name))
		return 0.90  // Monoculture: -10% yield
	else
		return 1.05  // Rotation: +5% yield bonus

// ============================================================================
// SUMMARY & DEBUG
// ============================================================================

/**
 * Get all soil properties as list (for display/analytics)
 */
proc/GetSoilProperties(turf/T)
	if(!istype(T)) return list()
	InitializeSoilProperties(T)
	
	var/list/props = list()
	props["fertility"] = GetSoilFertility(T)
	props["soil_type"] = GetTurfSoilType(T)
	props["ph"] = GetSoilPH(T)
	props["nitrogen"] = GetSoilNutrient(T, "nitrogen")
	props["phosphorus"] = GetSoilNutrient(T, "phosphorus")
	props["potassium"] = GetSoilNutrient(T, "potassium")
	props["moisture"] = GetSoilMoisture(T)
	props["last_crop"] = GetLastCrop(T)
	
	return props

/**
 * Debug: Print soil properties
 */
proc/DebugSoilProperties(turf/T)
	if(!istype(T)) return
	
	var/list/props = GetSoilProperties(T)
	world.log << "\[SOIL\] [T.x],[T.y]:"
	world.log << "  Fertility: [props["fertility"]]/200 ([props["soil_type"]])"
	world.log << "  pH: [props["ph"]] (modifier: [round(GetPHGrowthModifier(T) * 100)]%)"
	world.log << "  NPK: [props["nitrogen"]]/[props["phosphorus"]]/[props["potassium"]]"
	world.log << "  Moisture: [props["moisture"]]%"
	world.log << "  Last Crop: [props["last_crop"]]"
