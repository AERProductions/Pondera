/**
 * CompostSystem.dm - Composting and fertilizer application
 * 
 * Produces compost from waste materials:
 * - Harvest waste / crop scraps
 * - Bone meal from hunting
 * - Kelp from fishing
 * 
 * Compost restores soil fertility and nutrients
 * Different compost types provide different nutrient boosts
 */

// ============================================================================
// COMPOST TYPES & PROPERTIES
// ============================================================================

var/global/list/COMPOST_TYPES = alist(
	COMPOST_BASIC = list(
		"name" = "Vegetable Compost",
		"fertility_boost" = 30,
		"nitrogen_boost" = 15,
		"phosphorus_boost" = 10,
		"potassium_boost" = 5,
		"ph_adjustment" = 0.3,
		"quality" = 1.0
	),
	COMPOST_BONE_MEAL = list(
		"name" = "Bone Meal",
		"fertility_boost" = 25,
		"nitrogen_boost" = 5,
		"phosphorus_boost" = 25,        // High phosphorus for fruits
		"potassium_boost" = 5,
		"ph_adjustment" = 0.2,
		"quality" = 1.2
	),
	COMPOST_KELP = list(
		"name" = "Kelp Compost",
		"fertility_boost" = 28,
		"nitrogen_boost" = 10,
		"phosphorus_boost" = 10,
		"potassium_boost" = 30,         // High potassium for roots
		"ph_adjustment" = 0.4,
		"quality" = 1.1
	)
)

// ============================================================================
// COMPOST PRODUCTION (Crafting)
// ============================================================================

/**
 * Check if material can be composted
 */
proc/CanCompostMaterial(var/material_name)
	switch(lowertext(material_name))
		if("harvest_waste", "vegetable_scraps", "crop_scraps")
			return COMPOST_BASIC
		if("bone_meal", "bones")
			return COMPOST_BONE_MEAL
		if("kelp", "seaweed")
			return COMPOST_KELP
		else
			return 0

/**
 * Get compost type properties
 */
proc/GetCompostProperties(var/compost_type)
	if(!COMPOST_TYPES[compost_type])
		return COMPOST_TYPES[COMPOST_BASIC]
	return COMPOST_TYPES[compost_type]

/**
 * Get human-readable compost name
 */
proc/GetCompostName(var/compost_type)
	var/list/props = GetCompostProperties(compost_type)
	return props["name"] || "Unknown Compost"

/**
 * Craft compost from material
 * 
 * Parameters:
 * - player: mob/players crafting
 * - material: material name to compost
 * - quality: 0.5-1.5 based on skill/luck
 * 
 * Returns: compost_type or 0 if failed
 */
proc/CraftCompost(mob/players/player, var/material, var/quality = 1.0)
	if(!istype(player)) return 0
	
	var/compost_type = CanCompostMaterial(material)
	if(!compost_type) return 0
	
	// Quality clamped to 0.5-1.5 based on gardening skill
	var/grank = player.GetRankLevel(RANK_GARDENING) || 1
	quality = clamp(quality, 0.5, 0.5 + (grank * 0.2))
	
	player << "You create [GetCompostName(compost_type)]."
	
	// Award gardening XP
	player.UpdateRankExp(RANK_GARDENING, 5)
	
	return compost_type

// ============================================================================
// COMPOST APPLICATION
// ============================================================================

/**
 * Apply compost to a turf
 * 
 * Parameters:
 * - T: turf to apply compost to
 * - compost_type: type of compost
 * - quality: 0.5-1.5 (affects boost amount)
 * 
 * Returns: TRUE if applied, FALSE if turf max compost reached
 */
proc/ApplyCompost(turf/T, var/compost_type, var/quality = 1.0)
	if(!istype(T)) return FALSE
	
	// Initialize soil properties
	InitializeSoilProperties(T)
	
	// Check application limit (max 5 per cycle to avoid exploits)
	if(!T.vars["compost_applications"])
		T.vars["compost_applications"] = 0
	
	if(T.vars["compost_applications"] >= 5)
		return FALSE  // Too much compost applied already
	
	var/list/props = GetCompostProperties(compost_type)
	
	// Apply nutrients and fertility, scaled by quality
	var/fertility_boost = round(props["fertility_boost"] * quality)
	var/n_boost = round(props["nitrogen_boost"] * quality)
	var/p_boost = round(props["phosphorus_boost"] * quality)
	var/k_boost = round(props["potassium_boost"] * quality)
	var/ph_adj = props["ph_adjustment"] * quality
	
	ModifySoilFertility(T, fertility_boost)
	ModifySoilNutrient(T, "nitrogen", n_boost)
	ModifySoilNutrient(T, "phosphorus", p_boost)
	ModifySoilNutrient(T, "potassium", k_boost)
	AdjustSoilPHTowardNeutral(T, ph_adj)
	
	// Increment application counter
	T.vars["compost_applications"]++
	
	return TRUE

/**
 * Reset compost application counter (start of growing cycle)
 */
proc/ResetCompostApplicationCount(turf/T)
	if(!istype(T)) return
	T.vars["compost_applications"] = 0

// ============================================================================
// COMPOST SOURCES & PRODUCTION
// ============================================================================

/**
 * Generate compost from harvest waste
 * Called when crop is harvested
 */
proc/GenerateHarvestCompost(var/crop_name, var/harvest_amount)
	/**
	 * Waste from harvesting can be composted
	 * Amount: ~10% of harvest becomes composable waste
	 * Quality: Based on how ripe the crop was
	 */
	var/waste_amount = max(1, round(harvest_amount * 0.1))
	
	// Returns amount of harvest_waste available to compost
	return waste_amount

/**
 * Generate compost from bone processing (hunting)
 * Called when bones are processed
 */
proc/GenerateBoneMeal(var/bone_amount, var/processing_skill = 1)
	/**
	 * Bones from animals become bone meal (fertilizer)
	 * Amount: ~50% yield from bones
	 * Quality: Improves with hunting skill
	 */
	var/meal_amount = max(1, round(bone_amount * 0.5))
	return meal_amount

/**
 * Generate compost from kelp (fishing/seaweed)
 * Called when kelp is harvested from water
 */
proc/GenerateKelpCompost(var/kelp_amount)
	/**
	 * Kelp can be dried and composted
	 * Amount: ~40% yield from fresh kelp
	 * Quality: High potassium for root crops
	 */
	var/compost_amount = max(1, round(kelp_amount * 0.4))
	return compost_amount

// ============================================================================
// ANALYTICS & DIAGNOSTICS
// ============================================================================

/**
 * Get compost effectiveness on a crop
 */
proc/GetCompostEffectivenessOnCrop(var/compost_type, var/crop_name)
	/**
	 * Different compost types are more/less effective on different crops
	 * Returns: efficiency multiplier 0.8-1.3
	 */
	var/crop_lower = lowertext(crop_name)
	
	var/effectiveness = 1.0
	
	// Bone meal best for fruits
	if(compost_type == COMPOST_BONE_MEAL)
		switch(crop_lower)
			if("tomato", "pepper", "cucumber", "pumpkin")
				effectiveness = 1.3  // +30% effectiveness
			else
				effectiveness = 0.9
	
	// Kelp best for root crops
	else if(compost_type == COMPOST_KELP)
		switch(crop_lower)
			if("potato", "carrot", "turnip", "radish")
				effectiveness = 1.3  // +30% effectiveness
			else
				effectiveness = 0.9
	
	// Basic compost works on everything
	else
		effectiveness = 1.1  // +10% baseline
	
	return effectiveness

/**
 * Debug: Print compost info
 */
proc/DebugCompostInfo()
	world.log << "\[COMPOST\] Available compost types:"
	for(var/compost_id in COMPOST_TYPES)
		var/list/props = COMPOST_TYPES[compost_id]
		world.log << "  [props["name"]]: F+[props["fertility_boost"]] N+[props["nitrogen_boost"]] P+[props["phosphorus_boost"]] K+[props["potassium_boost"]]"
