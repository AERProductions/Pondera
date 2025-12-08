/**
 * PLANT GROWTH SEASONAL INTEGRATION
 * 
 * This system connects plant.dm growth cycles to the ConsumptionManager
 * so that crops only grow in their appropriate seasons and yield quality
 * varies based on environmental factors.
 */

/**
 * Mapping of plant types to consumable names
 */
/proc/GetPlantConsumableName(plant_obj)
	if (!plant_obj)
		return null
	
	if (istype(plant_obj, /obj/Plants/Vegetables))
		// Vegetables have VegeType variable
		if (plant_obj:VegeType)
			return lowertext(plant_obj:VegeType)
	
	if (istype(plant_obj, /obj/Plants/Bush))
		// Berries have FruitType variable
		if (plant_obj:FruitType)
			return lowertext(plant_obj:FruitType)
	
	if (istype(plant_obj, /obj/Plants/Grain))
		// Grains have GrainType variable
		if (plant_obj:GrainType)
			return lowertext(plant_obj:GrainType)
	
	return null


/proc/ApplySeasonalGrowthModifier(plant_obj)
	/**
	 * Check if plant is in the right season to grow
	 * If out of season, set vgrowstate/bgrowstate/ggrowstate to 8 (out of season)
	 * Returns: 1 if in-season (can grow), 0 if out-of-season (stalled)
	 */
	if (!plant_obj)
		return 1
	
	var/consumable_name = GetPlantConsumableName(plant_obj)
	if (!consumable_name)
		return 1  // No consumable mapping, allow growth
	
	if (!IsSeasonForCrop(consumable_name))
		// Out of season - stop growth
		if (plant_obj:vgrowstate)  // Vegetable
			plant_obj:vgrowstate = 8
		if (plant_obj:bgrowstate)  // Berry (though berries use different timing)
			plant_obj:bgrowstate = 8
		if (plant_obj:ggrowstate)  // Grain
			plant_obj:ggrowstate = 8
		
		return 0  // Out of season
	
	return 1  // In season, can grow


/proc/GetPlantHarvestYield(plant_obj, harvest_skill)
	/**
	 * Calculate how much a plant yields when harvested
	 * Modified by: seasonal quality, harvesting skill
	 */
	if (!plant_obj)
		return 1.0
	
	var/consumable_name = GetPlantConsumableName(plant_obj)
	if (!consumable_name)
		return 1.0
	
	var/crop_quality = GetCropYield(consumable_name)  // Season-based modifier
	var/skill_bonus = max(0.5, harvest_skill / 10.0)  // Skill progression
	
	return crop_quality * skill_bonus


/proc/ApplyHarvestYieldBonus(plant_obj, base_amount, harvest_skill, soil_type = SOIL_BASIC)
	/**
	 * When harvesting, apply quality/skill/soil multiplier to yield amount
	 * 
	 * base_amount: Normal yield (e.g., 3-5 potatoes)
	 * harvest_skill: Player's harvesting rank (hrank)
	 * soil_type: Soil quality (SOIL_BASIC, SOIL_RICH, SOIL_DEPLETED)
	 * 
	 * Formula: yield = base × season × skill × soil × crop_match
	 * Returns: Final amount with modifiers applied
	 */
	if (!plant_obj || base_amount <= 0)
		return base_amount
	
	var/yield_multiplier = GetPlantHarvestYield(plant_obj, harvest_skill)
	
	// Apply soil modifiers to yield
	var/consumable_name = GetPlantConsumableName(plant_obj)
	var/soil_yield_mod = GetSoilYieldModifier(soil_type)
	var/crop_soil_bonus = GetCropSoilBonus(consumable_name, soil_type)
	
	var/final_amount = round(base_amount * yield_multiplier * soil_yield_mod * crop_soil_bonus)
	
	// Ensure at least 1 item harvested
	return max(1, final_amount)


/proc/GetPlantHarvestMessage(plant_obj, is_in_season, soil_type = SOIL_BASIC)
	/**
	 * Get feedback message for harvest attempt
	 * Tells player if crop is in season, soil quality, and about quality
	 */
	if (!plant_obj)
		return "You harvest the plant."
	
	var/consumable_name = GetPlantConsumableName(plant_obj)
	var/plant_name = plant_obj:name
	
	// Add soil quality info to message
	var/soil_quality = ""
	
	// Soil quality feedback
	switch(soil_type)
		if(SOIL_DEPLETED)
			soil_quality = " The depleted soil yielded poor results."
		if(SOIL_BASIC)
			soil_quality = " The basic soil provided adequate growing conditions."
		if(SOIL_RICH)
			soil_quality = " The rich soil has greatly improved the harvest!"
	
	if (!is_in_season)
		return "[plant_name] was planted out of season and has poor quality.[soil_quality]"
	
	var/quality = GetConsumableQuality(consumable_name, usr)
	if (quality >= 1.0)
		return "[plant_name] is in excellent condition. The harvest is bountiful![soil_quality]"
	else if (quality >= 0.85)
		return "[plant_name] is in good condition. The harvest is healthy![soil_quality]"
	else
		return "[plant_name] has decent growth. The harvest is adequate.[soil_quality]"


/**
 * Growth integration hooks
 * These procs are called by the existing plant growth code
 */

/obj/Plants/Vegetables/proc/CheckSeasonalGrowth()
	/**
	 * Call from Grow() proc to check seasonal growth
	 * If out of season, growth is halted
	 */
	return ApplySeasonalGrowthModifier(src)


/obj/Plants/Bush/proc/CheckSeasonalFruiting()
	/**
	 * For berry bushes - check if season allows fruiting
	 * Berries should only fruit in spring/summer
	 */
	if (!IsSeasonForCrop(lowertext(src.FruitType)))
		// Out of season - no fruiting
		if (src.bgrowstate < 4)  // Not yet ripe
			src.FruitAmount = 0
			src.bgrowstate = 8
		return 0
	
	return 1


/obj/Plants/Grain/proc/CheckSeasonalGrowth()
	/**
	 * Grains only grow in certain seasons
	 */
	return ApplySeasonalGrowthModifier(src)


/**
 * Harvest messaging integration
 */

/obj/Plants/Vegetables/proc/GetVegetableHarvestInfo()
	/**
	 * Get harvest amount and quality for vegetables
	 */
	var/consumable_name = GetPlantConsumableName(src)
	if (!consumable_name)
		return list("amount" = src.VegeAmount, "quality" = 1.0)
	
	var/is_in_season = IsSeasonForCrop(consumable_name)
	var/player_hrank = 1
	if (usr && istype(usr, /mob/players))
		player_hrank = usr:hrank ? usr:hrank : 1
	
	return list(
		"amount" = src.VegeAmount,
		"multiplied_amount" = ApplyHarvestYieldBonus(src, src.VegeAmount, player_hrank),
		"quality" = GetConsumableQuality(consumable_name, usr),
		"in_season" = is_in_season,
		"message" = GetPlantHarvestMessage(src, is_in_season)
	)


/obj/Plants/Bush/proc/GetFruitHarvestInfo()
	/**
	 * Get harvest amount and quality for berries
	 */
	var/consumable_name = GetPlantConsumableName(src)
	if (!consumable_name)
		return list("amount" = src.FruitAmount, "quality" = 1.0)
	
	var/is_in_season = IsSeasonForCrop(consumable_name)
	var/player_hrank = 1
	if (usr && istype(usr, /mob/players))
		player_hrank = usr:hrank ? usr:hrank : 1
	
	return list(
		"amount" = src.FruitAmount,
		"multiplied_amount" = ApplyHarvestYieldBonus(src, src.FruitAmount, player_hrank),
		"quality" = GetConsumableQuality(consumable_name, usr),
		"in_season" = is_in_season,
		"message" = GetPlantHarvestMessage(src, is_in_season)
	)


/obj/Plants/Grain/proc/GetGrainHarvestInfo()
	/**
	 * Get harvest amount and quality for grains
	 */
	var/consumable_name = GetPlantConsumableName(src)
	if (!consumable_name)
		return list("amount" = src.GrainAmount, "quality" = 1.0)
	
	var/is_in_season = IsSeasonForCrop(consumable_name)
	var/player_hrank = 1
	if (usr && istype(usr, /mob/players))
		player_hrank = usr:hrank ? usr:hrank : 1
	
	return list(
		"amount" = src.GrainAmount,
		"multiplied_amount" = ApplyHarvestYieldBonus(src, src.GrainAmount, player_hrank),
		"quality" = GetConsumableQuality(consumable_name, usr),
		"in_season" = is_in_season,
		"message" = GetPlantHarvestMessage(src, is_in_season)
	)


/**
 * Visual state updates for seasonality
 */

/proc/UpdatePlantSeasonalState(plant_obj)
	/**
	 * Update plant visual state based on seasonal availability
	 */
	if (!plant_obj)
		return
	
	var/consumable_name = GetPlantConsumableName(plant_obj)
	if (!consumable_name)
		return
	
	// Check if in season
	if (!IsSeasonForCrop(consumable_name))
		// Out of season visuals
		plant_obj:icon_state = "oos"  // Out of season icon state
		plant_obj:name = "[plant_obj:name] (Out of Season)"
		return
	
	// In season - normal growth progression happens
	plant_obj:name = initial(plant_obj:name)


/**
 * Environmental impact on crop growth
 * (Advanced feature: affects growth speed)
 */

/proc/GetCropGrowthSpeedModifier(plant_obj)
	/**
	 * Environmental conditions affect how fast crops grow
	 * Good conditions = faster growth
	 * Poor conditions = slower growth
	 */
	if (!plant_obj)
		return 1.0
	
	var/plant_location = plant_obj:loc
	if (!plant_location)
		return 1.0
	
	// Future: check zone environment
	// For now, return standard modifier
	return 1.0


/**
 * Quality feedback to player
 */

/proc/ShowHarvestQualityFeedback(player, consumable_name, quality)
	/**
	 * Show player how good their harvest quality is
	 */
	if (!player)
		return
	
	var/quality_percent = round(quality * 100)
	var/feedback = ""
	
	if (quality >= 1.15)
		feedback = "[consumable_name] is of exceptional quality! [quality_percent]% effective"
	else if (quality >= 1.0)
		feedback = "[consumable_name] is of excellent quality. [quality_percent]% effective"
	else if (quality >= 0.9)
		feedback = "[consumable_name] is of good quality. [quality_percent]% effective"
	else if (quality >= 0.75)
		feedback = "[consumable_name] is of fair quality. [quality_percent]% effective"
	else
		feedback = "[consumable_name] is of poor quality. [quality_percent]% effective"
	
	player << feedback
