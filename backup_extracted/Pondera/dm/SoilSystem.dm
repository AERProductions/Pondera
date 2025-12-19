/**
 * SOIL QUALITY SYSTEM
 * Connects soil fertility to crop growth and yield
 * 
 * In Pondera:
 * - Basic soil: Normal growth and yield
 * - Rich soil: 15% faster growth, 20% better yield, higher quality
 * - Soil degrades with use (future farming system)
 * - Composting restores fertility (future)
 * - Crop rotation prevents depletion (future)
 */

/**
 * Soil type constants - now centralized in !defines.dm
 * SOIL_DEPLETED, SOIL_BASIC, SOIL_RICH
 */

/**
 * Soil quality data structure
 */
var/global/list/SOIL_TYPES = alist(
	SOIL_DEPLETED = list(
		"name" = "Depleted Soil",
		"growth_modifier" = 0.6,      // 40% slower growth
		"yield_modifier" = 0.5,        // 50% lower yield
		"quality_modifier" = 0.7,      // 30% lower food quality
		"fertility" = 0,
		"can_plant" = 0               // Can't plant in depleted soil
	),
	SOIL_BASIC = list(
		"name" = "Basic Soil",
		"growth_modifier" = 1.0,       // Normal growth
		"yield_modifier" = 1.0,        // Normal yield
		"quality_modifier" = 1.0,      // Normal food quality
		"fertility" = 100,
		"can_plant" = 1
	),
	SOIL_RICH = list(
		"name" = "Rich Soil",
		"growth_modifier" = 1.15,      // 15% faster growth
		"yield_modifier" = 1.2,        // 20% better yield
		"quality_modifier" = 1.15,     // 15% higher food quality
		"fertility" = 150,
		"can_plant" = 1
	)
)


/**
 * Determine soil type from fertility level
 * LEGACY: Use SoilPropertySystem.dm for new code
 */
/proc/GetSoilTypeFromFertility_Legacy(fertility_level)
	if (fertility_level <= 0)
		return SOIL_DEPLETED
	else if (fertility_level >= 120)
		return SOIL_RICH
	else
		return SOIL_BASIC


/**
 * Get soil quality modifiers
 */
/proc/GetSoilModifiers(soil_type)
	/**
	 * Returns list of all modifiers for given soil type
	 */
	if (!SOIL_TYPES[soil_type])
		return SOIL_TYPES[SOIL_BASIC]  // Default to basic
	
	return SOIL_TYPES[soil_type]


/proc/GetSoilGrowthModifier(soil_type)
	/**
	 * How fast does crop grow in this soil?
	 * Rich soil: 15% faster (grows to harvest in less time)
	 */
	var/list/soil = GetSoilModifiers(soil_type)
	return soil["growth_modifier"]


/proc/GetSoilYieldModifier(soil_type)
	/**
	 * How much does crop yield in this soil?
	 * Rich soil: 20% more yield
	 * Example: 5 potatoes → 6 potatoes in rich soil
	 */
	var/list/soil = GetSoilModifiers(soil_type)
	return soil["yield_modifier"]


/proc/GetSoilQualityModifier(soil_type)
	/**
	 * How does soil affect food quality when eaten?
	 * Rich soil crops are 15% more nutritious
	 */
	var/list/soil = GetSoilModifiers(soil_type)
	return soil["quality_modifier"]


/proc/CanPlantInSoil(soil_type)
	/**
	 * Can player plant in this soil?
	 * Depleted soil: no (must restore fertility first)
	 * Basic/Rich soil: yes
	 */
	var/list/soil = GetSoilModifiers(soil_type)
	return soil["can_plant"]


/proc/GetSoilName(soil_type)
	/**
	 * Get human-readable soil name
	 */
	var/list/soil = GetSoilModifiers(soil_type)
	return soil["name"]


/**
 * Soil-specific crop matching (advanced)
 */
/proc/GetCropSoilBonus(crop_name, soil_type)
	/**
	 * Some crops prefer certain soil types
	 * Matching soil to crop provides bonus quality/yield
	 * 
	 * Currently basic matching:
	 * Root vegetables (potato, carrot) prefer rich soil: +10% quality
	 * Berries prefer basic to moderate soil: -5% in rich (prefer natural)
	 * Grains prefer rich soil: +10% quality
	 * Tomatoes adaptable: +5% everywhere
	 */
	var/crop_lower = lowertext(crop_name)
	
	// Root vegetables like rich soil
	if (crop_lower == "potato" || crop_lower == "carrot" || crop_lower == "onion")
		if (soil_type == SOIL_RICH)
			return 1.10  // 10% bonus in rich soil
		else
			return 0.95  // 5% penalty in basic soil
	
	// Berries prefer natural soil (basic)
	if (crop_lower == "raspberry" || crop_lower == "blueberry")
		if (soil_type == SOIL_BASIC)
			return 1.05  // 5% bonus in basic
		else if (soil_type == SOIL_RICH)
			return 0.98  // 2% penalty in too-rich soil
	
	// Grains love rich soil
	if (crop_lower == "wheat" || crop_lower == "barley")
		if (soil_type == SOIL_RICH)
			return 1.10  // 10% bonus
		else
			return 0.95  // 5% penalty in basic
	
	// Tomatoes adaptable
	if (crop_lower == "tomato" || crop_lower == "pumpkin")
		if (soil_type == SOIL_RICH)
			return 1.05  // 5% bonus
		else
			return 1.0   // No penalty
	
	// Default: no bonus/penalty
	return 1.0


/**
 * Soil degradation system (framework)
 */
/proc/DepleteSoil(soil_type, depletion_amount)
	/**
	 * Using soil for farming reduces its fertility
	 * Example: Harvest 5 crops → soil fertility -5
	 * 
	 * Future: Implement soil fertility as turf variable
	 * var/turf/soil/T = get_turf(player)
	 * T.fertility -= depletion_amount
	 */
	
	// Framework for future implementation
	// When fertility reaches 0, soil becomes SOIL_DEPLETED
	// When fertility < 50, soil is SOIL_BASIC
	// When fertility >= 120, soil is SOIL_RICH
	
	return 1


/**
 * Fertilizer application (framework)
 * LEGACY: Use CompostSystem.dm for new code
 */
/proc/ApplyCompost_Legacy(soil_type, compost_amount)
	/**
	 * Apply compost/fertilizer to restore fertility
	 * Example: Add compost → fertility +20
	 * 
	 * Compost sources (future):
	 * - Crop waste (harvest remnants)
	 * - Animal manure (from ranches)
	 * - Bone meal (from hunting)
	 * - Kelp (from fishing)
	 */
	
	// Framework for future implementation
	// Adds to soil fertility level
	// Can restore depleted soil back to basic
	
	return soil_type


/**
 * Crop rotation benefit (framework)
 */
/proc/GetCropRotationBonus(last_crop, current_crop)
	/**
	 * Planting different crop than last cycle provides bonus
	 * Prevents soil depletion from monoculture
	 * 
	 * Different crops = +5% yield
	 * Same crop = -10% yield (depletes specific nutrients)
	 */
	
	if (last_crop != current_crop)
		return 1.05  // 5% bonus for crop rotation
	else
		return 0.90  // 10% penalty for monoculture


/**
 * Integration with existing yield system
 */
/proc/ApplySoilModifiersToHarvest(plant_obj, base_yield, soil_type)
	/**
	 * Apply soil quality modifiers to harvest calculation
	 * 
	 * Final yield = base × season × skill × soil × crop_match
	 */
	
	var/soil_yield = GetSoilYieldModifier(soil_type)
	var/crop_bonus = GetCropSoilBonus(GetPlantConsumableName(plant_obj), soil_type)
	
	return base_yield * soil_yield * crop_bonus


/proc/ApplySoilModifiersToQuality(crop_name, base_quality, soil_type)
	/**
	 * Apply soil modifiers to food quality
	 * 
	 * Food grown in rich soil is more nutritious
	 * Food grown in depleted soil is less nutritious
	 */
	
	var/soil_quality = GetSoilQualityModifier(soil_type)
	var/crop_bonus = GetCropSoilBonus(crop_name, soil_type)
	
	return base_quality * soil_quality * crop_bonus


/**
 * Growth speed modification by soil
 */
/proc/ApplySoilModifiersToGrowthSpeed(plant_obj, base_growth_days, soil_type)
	/**
	 * Rich soil speeds up growth
	 * Depleted soil slows down growth
	 * 
	 * Rich soil: Plant ready 15% sooner
	 * Basic soil: Normal growth time
	 * Depleted soil: Takes 40% longer
	 */
	
	var/soil_growth = GetSoilGrowthModifier(soil_type)
	var/adjusted_days = round(base_growth_days / soil_growth)
	
	return adjusted_days


/**
 * Soil information for player display
 */
/proc/GetSoilDescription(soil_type)
	/**
	 * Get player-friendly description of soil
	 */
	var/list/soil = GetSoilModifiers(soil_type)
	var/description = soil["name"]
	
	switch(soil_type)
		if(SOIL_DEPLETED)
			description += " - No crops will grow. Need to restore fertility with compost."
		if(SOIL_BASIC)
			description += " - Standard growing conditions. Crops grow normally."
		if(SOIL_RICH)
			description += " - Excellent fertility! Crops grow 15% faster and yield 20% more."
	
	return description


/proc/GetSoilReport(soil_type, fertility_level)
	/**
	 * Get detailed soil fertility report for player
	 */
	var/report = "[GetSoilName(soil_type)]\n"
	report += "Fertility: [fertility_level]%\n"
	
	if (fertility_level <= 0)
		report += "Status: DEPLETED - Plant nothing here!\n"
		report += "Action: Add compost to restore fertility"
	else if (fertility_level < 50)
		report += "Status: POOR - Crops struggle\n"
		report += "Action: Consider adding compost"
	else if (fertility_level < 100)
		report += "Status: ADEQUATE - Normal growth\n"
		report += "Action: Good for farming"
	else if (fertility_level < 120)
		report += "Status: GOOD - Crops thrive\n"
		report += "Action: Ideal for farming"
	else
		report += "Status: EXCELLENT - Optimal fertility!\n"
		report += "Action: Crops grow quickly and yield bountifully"
	
	return report


/**
 * Future farming system hooks
 */

/proc/ImplementFarmingSystem()
	/**
	 * Advanced farming features (future implementation)
	 * 
	 * 1. SOIL FERTILITY SYSTEM
	 *    - Each turf/garden plot has fertility variable
	 *    - Using soil depletes fertility
	 *    - Compost application restores fertility
	 *    - Player can check soil status
	 * 
	 * 2. COMPOSTING
	 *    - Collect crop waste, animal manure, bone meal
	 *    - Create compost in dedicated bin
	 *    - Apply to depleted soil to restore
	 *    - Different materials provide different fertility
	 * 
	 * 3. CROP ROTATION
	 *    - Track what was planted last cycle
	 *    - Planting different crop provides bonus
	 *    - Same crop multiple seasons = penalty (monoculture)
	 *    - Encourages diverse farming
	 * 
	 * 4. PADDIES & AGRICULTURE
	 *    - Rice paddies for wetland crops
	 *    - Terraces for hillside crops
	 *    - Irrigation systems for arid zones
	 *    - Weather affects water availability
	 * 
	 * 5. RANCHING (FUTURE)
	 *    - Animals produce manure for compost
	 *    - Pasture fertility affects animal health
	 *    - Rotation of animals improves soil
	 * 
	 * 6. TRADING & AGRICULTURE
	 *    - Rich soil farms can trade surplus
	 *    - NPCs buy/sell fertile soil
	 *    - Agricultural settlements develop
	 */
	return 1


/**
 * Soil management commands (for players/admins)
 */
/proc/ShowSoilStatus()
	/**
	 * Display current soil status for player's location
	 * Used by command: check_soil
	 */
	var/turf/T = usr.loc
	if (!T)
		return
	
	// Future: Check if turf has soil system
	// if (T:soil_type && T:fertility)
	//     var/report = GetSoilReport(T:soil_type, T:fertility)
	//     usr << report


/**
 * Get soil type from turf location (safely handles non-turf objects)
 * LEGACY: Use SoilPropertySystem.dm for new code
 */
/proc/GetTurfSoilType_Legacy(atom/location)
	if (!location)
		return SOIL_BASIC
	
	var/turf/T = location
	if (!istype(T, /turf))
		// If not on a turf, return basic soil
		return SOIL_BASIC
	
	if (T.soil_type)
		return T.soil_type
	else
		return SOIL_BASIC
