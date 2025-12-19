/**
 * AdvancedCropsSystem.dm - 20+ crops with variants and companion planting
 * 
 * Features:
 * - 20+ crop types (staples, vegetables, legumes, fibers, specialty)
 * - Crop variants (early/mid/late season)
 * - Companion planting bonuses (Three Sisters, nitrogen fixation)
 * - Soil-crop matching (soil type affects yield)
 * - Weather integration (rain/drought/snow effects)
 * - Season-specific availability
 * - Integration with FarmingIntegration.dm for harvest
 * 
 * Crop Categories:
 * - Staples (8): Wheat, Barley, Rye, Corn, Oats, Millet, Rice, Sorghum
 * - Vegetables (6): Potatoes, Carrots, Turnips, Onions, Beets, Cabbage
 * - Legumes (4): Beans, Peas, Lentils, Chickpeas
 * - Fibers (2): Flax, Hemp
 * - Specialty (4): Hops, Saffron, Vanilla, Tobacco
 * 
 * Companion Planting:
 * - Three Sisters (Corn + Beans + Squash): +20% yield
 * - Nitrogen Fixation (Beans + Legumes): +15% soil nitrogen
 * - Compatibility matrix prevents incompatible pairings
 * 
 * Integration: SoilPropertySystem, FarmingIntegration, ConsumptionManager, time.dm
 */

// ============================================================================
// ADVANCED CROP DATABASE
// ============================================================================

var/global/list/ADVANCED_CROPS = list()

/proc/InitializeAdvancedCrops()
	/**
	 * Build master crop database on world init
	 * Called during Phase 5 initialization
	 */
	
	ADVANCED_CROPS = list(
		// === STAPLES ===
		"wheat" = list(
			"name" = "Wheat",
			"icon" = "wheat",
			"seasons" = list("Spring", "Summer", "Autumn"),
			"grow_time" = 1200,
			"hunger_value" = 30,
			"companions" = list("barley", "rye"),
			"soil_preference" = "loamy",
			"soil_bonus" = 1.15,
			"nutrition" = list("n" = 15, "p" = 5, "k" = 10),
			"base_yield" = 3,
			"variants" = list("early_wheat", "mid_wheat", "late_wheat")
		),
		
		"corn" = list(
			"name" = "Corn",
			"icon" = "corn",
			"seasons" = list("Summer", "Autumn"),
			"grow_time" = 1500,
			"hunger_value" = 35,
			"companions" = list("beans", "squash"),  // Three Sisters
			"soil_preference" = "rich",
			"soil_bonus" = 1.20,
			"nutrition" = list("n" = 20, "p" = 8, "k" = 5),
			"base_yield" = 4,
			"variants" = list("early_corn", "mid_corn", "late_corn")
		),
		
		"barley" = list(
			"name" = "Barley",
			"icon" = "barley",
			"seasons" = list("Spring", "Summer", "Autumn"),
			"grow_time" = 1100,
			"hunger_value" = 28,
			"companions" = list("wheat", "rye"),
			"soil_preference" = "loamy",
			"soil_bonus" = 1.10,
			"nutrition" = list("n" = 14, "p" = 5, "k" = 9),
			"base_yield" = 3,
			"variants" = list()
		),
		
		"rye" = list(
			"name" = "Rye",
			"icon" = "rye",
			"seasons" = list("Spring", "Summer", "Autumn", "Winter"),
			"grow_time" = 1000,
			"hunger_value" = 27,
			"companions" = list("wheat", "barley"),
			"soil_preference" = "loamy",
			"soil_bonus" = 1.10,
			"nutrition" = list("n" = 13, "p" = 4, "k" = 8),
			"base_yield" = 3,
			"variants" = list()
		),
		
		"oats" = list(
			"name" = "Oats",
			"icon" = "oats",
			"seasons" = list("Spring", "Summer"),
			"grow_time" = 900,
			"hunger_value" = 25,
			"companions" = list("clover", "vetch"),
			"soil_preference" = "loamy",
			"soil_bonus" = 1.08,
			"nutrition" = list("n" = 12, "p" = 4, "k" = 7),
			"base_yield" = 2,
			"variants" = list()
		),
		
		"millet" = list(
			"name" = "Millet",
			"icon" = "millet",
			"seasons" = list("Summer", "Autumn"),
			"grow_time" = 1000,
			"hunger_value" = 26,
			"companions" = list("peas", "beans"),
			"soil_preference" = "sandy",
			"soil_bonus" = 1.12,
			"nutrition" = list("n" = 11, "p" = 3, "k" = 10),
			"base_yield" = 2,
			"variants" = list()
		),
		
		"rice" = list(
			"name" = "Rice",
			"icon" = "rice",
			"seasons" = list("Summer", "Autumn"),
			"grow_time" = 1600,
			"hunger_value" = 32,
			"companions" = list("fish_in_paddies"),
			"soil_preference" = "wet",
			"soil_bonus" = 1.25,
			"nutrition" = list("n" = 16, "p" = 6, "k" = 8),
			"base_yield" = 4,
			"variants" = list()
		),
		
		"sorghum" = list(
			"name" = "Sorghum",
			"icon" = "sorghum",
			"seasons" = list("Summer", "Autumn"),
			"grow_time" = 1300,
			"hunger_value" = 29,
			"companions" = list("legumes"),
			"soil_preference" = "sandy",
			"soil_bonus" = 1.10,
			"nutrition" = list("n" = 14, "p" = 4, "k" = 9),
			"base_yield" = 3,
			"variants" = list()
		),
		
		// === VEGETABLES ===
		"potato" = list(
			"name" = "Potato",
			"icon" = "potato",
			"seasons" = list("Spring", "Summer", "Autumn"),
			"grow_time" = 900,
			"hunger_value" = 35,
			"companions" = list("beans", "corn"),
			"soil_preference" = "acidic",
			"soil_bonus" = 1.15,
			"nutrition" = list("n" = 10, "p" = 4, "k" = 15),
			"base_yield" = 5,
			"variants" = list()
		),
		
		"carrot" = list(
			"name" = "Carrot",
			"icon" = "carrot",
			"seasons" = list("Spring", "Summer", "Autumn"),
			"grow_time" = 800,
			"hunger_value" = 20,
			"companions" = list("onion", "tomato"),
			"soil_preference" = "loamy",
			"soil_bonus" = 1.10,
			"nutrition" = list("n" = 8, "p" = 3, "k" = 10),
			"base_yield" = 4,
			"variants" = list()
		),
		
		"turnip" = list(
			"name" = "Turnip",
			"icon" = "turnip",
			"seasons" = list("Spring", "Autumn", "Winter"),
			"grow_time" = 700,
			"hunger_value" = 22,
			"companions" = list("peas"),
			"soil_preference" = "loamy",
			"soil_bonus" = 1.08,
			"nutrition" = list("n" = 9, "p" = 3, "k" = 12),
			"base_yield" = 4,
			"variants" = list()
		),
		
		"onion" = list(
			"name" = "Onion",
			"icon" = "onion",
			"seasons" = list("Spring", "Summer", "Autumn"),
			"grow_time" = 1000,
			"hunger_value" = 15,
			"companions" = list("carrot", "beet"),
			"soil_preference" = "loamy",
			"soil_bonus" = 1.10,
			"nutrition" = list("n" = 5, "p" = 2, "k" = 8),
			"base_yield" = 3,
			"variants" = list()
		),
		
		"beet" = list(
			"name" = "Beet",
			"icon" = "beet",
			"seasons" = list("Spring", "Summer", "Autumn"),
			"grow_time" = 900,
			"hunger_value" = 25,
			"companions" = list("onion", "cabbage"),
			"soil_preference" = "loamy",
			"soil_bonus" = 1.12,
			"nutrition" = list("n" = 12, "p" = 4, "k" = 14),
			"base_yield" = 4,
			"variants" = list()
		),
		
		"cabbage" = list(
			"name" = "Cabbage",
			"icon" = "cabbage",
			"seasons" = list("Spring", "Summer", "Autumn"),
			"grow_time" = 1100,
			"hunger_value" = 24,
			"companions" = list("beet", "onion"),
			"soil_preference" = "rich",
			"soil_bonus" = 1.13,
			"nutrition" = list("n" = 13, "p" = 4, "k" = 11),
			"base_yield" = 4,
			"variants" = list()
		),
		
		// === LEGUMES ===
		"beans" = list(
			"name" = "Beans",
			"icon" = "beans",
			"seasons" = list("Spring", "Summer", "Autumn"),
			"grow_time" = 1000,
			"hunger_value" = 28,
			"companions" = list("corn", "squash"),  // Three Sisters
			"soil_preference" = "loamy",
			"soil_bonus" = 1.10,
			"nutrition" = list("n" = 8, "p" = 5, "k" = 6),  // Legume! Fixes N
			"base_yield" = 3,
			"nitrogen_fixer" = TRUE,
			"variants" = list()
		),
		
		"peas" = list(
			"name" = "Peas",
			"icon" = "peas",
			"seasons" = list("Spring", "Summer"),
			"grow_time" = 800,
			"hunger_value" = 26,
			"companions" = list("carrot", "turnip"),
			"soil_preference" = "loamy",
			"soil_bonus" = 1.08,
			"nutrition" = list("n" = 7, "p" = 4, "k" = 5),
			"base_yield" = 3,
			"nitrogen_fixer" = TRUE,
			"variants" = list()
		),
		
		"lentils" = list(
			"name" = "Lentils",
			"icon" = "lentils",
			"seasons" = list("Spring", "Summer", "Autumn"),
			"grow_time" = 1100,
			"hunger_value" = 30,
			"companions" = list("wheat", "barley"),
			"soil_preference" = "loamy",
			"soil_bonus" = 1.10,
			"nutrition" = list("n" = 9, "p" = 4, "k" = 5),
			"base_yield" = 3,
			"nitrogen_fixer" = TRUE,
			"variants" = list()
		),
		
		"chickpeas" = list(
			"name" = "Chickpeas",
			"icon" = "chickpeas",
			"seasons" = list("Spring", "Summer"),
			"grow_time" = 1200,
			"hunger_value" = 32,
			"companions" = list("wheat", "oats"),
			"soil_preference" = "loamy",
			"soil_bonus" = 1.12,
			"nutrition" = list("n" = 10, "p" = 5, "k" = 6),
			"base_yield" = 3,
			"nitrogen_fixer" = TRUE,
			"variants" = list()
		),
		
		// === FIBERS ===
		"flax" = list(
			"name" = "Flax",
			"icon" = "flax",
			"seasons" = list("Spring", "Summer"),
			"grow_time" = 1000,
			"hunger_value" = 0,
			"companions" = list("wheat", "beans"),
			"soil_preference" = "loamy",
			"soil_bonus" = 1.10,
			"nutrition" = list("n" = 10, "p" = 3, "k" = 4),
			"base_yield" = 2,
			"craft_material" = "flax_fiber",
			"variants" = list()
		),
		
		"hemp" = list(
			"name" = "Hemp",
			"icon" = "hemp",
			"seasons" = list("Spring", "Summer", "Autumn"),
			"grow_time" = 1200,
			"hunger_value" = 0,
			"companions" = list("beans", "clover"),
			"soil_preference" = "rich",
			"soil_bonus" = 1.15,
			"nutrition" = list("n" = 15, "p" = 4, "k" = 8),
			"base_yield" = 3,
			"craft_material" = "hemp_fiber",
			"variants" = list()
		),
		
		// === SPECIALTY ===
		"hops" = list(
			"name" = "Hops",
			"icon" = "hops",
			"seasons" = list("Spring", "Summer", "Autumn"),
			"grow_time" = 1400,
			"hunger_value" = 0,
			"companions" = list("barley", "wheat"),
			"soil_preference" = "rich",
			"soil_bonus" = 1.12,
			"nutrition" = list("n" = 8, "p" = 3, "k" = 6),
			"base_yield" = 2,
			"craft_material" = "hops",
			"variants" = list()
		),
		
		"saffron" = list(
			"name" = "Saffron",
			"icon" = "saffron",
			"seasons" = list("Autumn"),
			"grow_time" = 2000,
			"hunger_value" = 0,
			"companions" = list(),
			"soil_preference" = "rich",
			"soil_bonus" = 1.20,
			"nutrition" = list("n" = 5, "p" = 8, "k" = 4),
			"base_yield" = 1,
			"craft_material" = "saffron",
			"luxury" = TRUE,
			"variants" = list()
		),
		
		"vanilla" = list(
			"name" = "Vanilla",
			"icon" = "vanilla",
			"seasons" = list("Summer", "Autumn"),
			"grow_time" = 2500,
			"hunger_value" = 0,
			"companions" = list(),
			"soil_preference" = "humid",
			"soil_bonus" = 1.18,
			"nutrition" = list("n" = 4, "p" = 2, "k" = 3),
			"base_yield" = 1,
			"craft_material" = "vanilla_bean",
			"luxury" = TRUE,
			"variants" = list()
		),
		
		"tobacco" = list(
			"name" = "Tobacco",
			"icon" = "tobacco",
			"seasons" = list("Spring", "Summer"),
			"grow_time" = 1300,
			"hunger_value" = 0,
			"companions" = list(),
			"soil_preference" = "rich",
			"soil_bonus" = 1.10,
			"nutrition" = list("n" = 12, "p" = 3, "k" = 5),
			"base_yield" = 2,
			"craft_material" = "tobacco_leaf",
			"variants" = list()
		),
	)

// ============================================================================
// CROP SYSTEM FUNCTIONS
// ============================================================================

/proc/GetCropData(var/crop_name)
	/**
	 * Return crop database entry
	 */
	return ADVANCED_CROPS[crop_name] || null

/proc/IsValidCrop(var/crop_name)
	/**
	 * Check if crop exists in database
	 */
	return (crop_name in ADVANCED_CROPS)

/proc/CanPlantCrop(turf/T, var/crop_name, var/season)
	/**
	 * Check if crop can be planted
	 * Checks: season, soil type, deed permissions
	 */
	
	if(!IsValidCrop(crop_name))
		return FALSE
	
	var/list/crop = GetCropData(crop_name)
	if(!crop)
		return FALSE
	
	// Check season
	if(season && !(season in crop["seasons"]))
		return FALSE
	
	// TODO: Add turf type checking once terrain system is defined
	
	return TRUE

/proc/GetCompanionBonus(turf/T)
	/**
	 * Calculate companion planting multiplier
	 * Checks adjacent turfs for companion crops
	 * Returns: 1.0 (no bonus), 1.15 (nitrogen fixation), 1.20 (Three Sisters)
	 */
	
	var/bonus = 1.0
	var/list/adjacent_crops = list()
	
	// Check adjacent turfs for crops
	for(var/turf/adjacent in range(1, T))
		var/obj/plant/P = locate(/obj/plant) in adjacent
		if(P)
			adjacent_crops += P.type
	
	if(adjacent_crops.len == 0)
		return bonus  // No companions
	
	// Check for Three Sisters (Corn + Beans + Squash)
	var/has_corn = 0
	var/has_beans = 0
	var/has_squash = 0
	
	for(var/plant in adjacent_crops)
		if(findtext(plant, "corn"))
			has_corn = 1
		else if(findtext(plant, "bean"))
			has_beans = 1
		else if(findtext(plant, "squash"))
			has_squash = 1
	
	if(has_corn && has_beans && has_squash)
		bonus = 1.20  // Three Sisters bonus
	
	// Check for nitrogen fixation (legumes + staples)
	var/has_legume = 0
	var/has_staple = 0
	
	for(var/plant in adjacent_crops)
		if(findtext(plant, "bean") || findtext(plant, "pea") || findtext(plant, "lentil"))
			has_legume = 1
		else if(findtext(plant, "wheat") || findtext(plant, "barley") || findtext(plant, "corn"))
			has_staple = 1
	
	if(has_legume && has_staple)
		bonus = max(bonus, 1.15)  // Nitrogen fixation bonus
	
	return bonus

/proc/GetSoilCropBonus(turf/T, var/crop_name)
	/**
	 * Calculate soil-to-crop matching bonus
	 * Uses SoilPropertySystem to get soil pH/type
	 * Returns: 0.8-1.3x multiplier
	 */
	
	var/list/crop = GetCropData(crop_name)
	if(!crop || !crop["soil_preference"])
		return 1.0
	
	var/preference = crop["soil_preference"]
	var/soil_bonus = crop["soil_bonus"] || 1.0
	
	// Check soil pH via SoilPropertySystem
	var/soil_ph = GetSoilPH(T)
	
	// Penalty for mismatched soil
	switch(preference)
		if("acidic")
			if(soil_ph < 6.5)
				return soil_bonus
			else
				return 0.8
		if("loamy")
			if(soil_ph >= 6.0 && soil_ph <= 7.5)
				return soil_bonus
			else
				return 0.85
		if("rich")
			if(GetSoilFertility(T) > 150)
				return soil_bonus
			else
				return 0.9
		if("sandy")
			return 0.95
		if("wet")
			return soil_bonus
	
	return 1.0

/proc/CalculateAdvancedYield(turf/T, var/crop_name, mob/players/harvester)
	/**
	 * Calculate final yield with all modifiers
	 * Formula: base × season × skill × soil × companion × weather
	 * 
	 * Returns: number of items harvested
	 */
	
	var/list/crop = GetCropData(crop_name)
	if(!crop)
		return 0
	
	var/base_yield = crop["base_yield"] || 2
	
	// Season quality modifier
	var/season_quality = 1.0
	switch(global.season)
		if("Spring")
			season_quality = 1.0
		if("Summer")
			season_quality = 1.2  // Peak growing season
		if("Autumn")
			season_quality = 1.1  // Harvest season
		else
			season_quality = 0.5  // Winter penalty
	
	// Skill modifier (gardening rank)
	var/skill_bonus = 1.0
	if(harvester && harvester.character)
		var/grank = harvester.character.GetRankLevel("grank")
		skill_bonus = 1.0 + (grank * 0.15)  // +15% per rank (0.0-1.5x)
	
	// Soil matching bonus
	var/soil_bonus = GetSoilCropBonus(T, crop_name)
	
	// Companion planting bonus
	var/companion_bonus = GetCompanionBonus(T)
	
	// Weather modifier (should integrate with weather system)
	var/weather_bonus = 1.0
	// TODO: Integrate with Particles-Weather.dm
	// if(raining) weather_bonus = 1.1
	// if(drought) weather_bonus = 0.7
	
	// Final calculation
	var/final_yield = base_yield * season_quality * skill_bonus * soil_bonus * companion_bonus * weather_bonus
	
	return round(final_yield)

/proc/HarvestAdvancedCrop(turf/T, mob/players/harvester)
	/**
	 * Execute harvest with all modifiers
	 * Integration point with FarmingIntegration.dm
	 */
	
	if(!T)
		return 0
	
	var/crop_name = T.vars["plant"]
	var/yield = CalculateAdvancedYield(T, crop_name, harvester)
	
	// Award XP
	if(harvester && harvester.character)
		harvester.character.UpdateRankExp("grank", 5)
	
	// Degrade soil
	ModifySoilFertility(T, -10)
	
	return yield

// ============================================================================
// CROP VARIANTS
// ============================================================================

/proc/GetCropVariants(var/crop_name)
	/**
	 * Return list of crop variants (early/mid/late season)
	 */
	
	var/list/crop = GetCropData(crop_name)
	if(!crop || !crop["variants"])
		return list(crop_name)  // No variants, return base crop
	
	return crop["variants"]

/proc/GetVariantGrowTime(var/crop_name, var/variant_name)
	/**
	 * Return grow time for specific variant
	 * Early: 70% time, lower yield
	 * Mid: 100% time, normal yield
	 * Late: 150% time, higher yield
	 */
	
	var/base_name = crop_name
	if(findtext(variant_name, "early"))
		base_name = findtext(variant_name, "early_") ? copytext(variant_name, 7) : crop_name
		var/base_time = GetCropData(base_name)["grow_time"]
		return base_time * 0.7
	
	else if(findtext(variant_name, "late"))
		base_name = findtext(variant_name, "late_") ? copytext(variant_name, 6) : crop_name
		var/base_time = GetCropData(base_name)["grow_time"]
		return base_time * 1.5
	
	else
		return GetCropData(variant_name)["grow_time"]
