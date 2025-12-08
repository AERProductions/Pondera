/**
 * FARMING & HARVESTING INTEGRATION
 * Connects plant growth cycles to consumption systems
 * 
 * In Pondera:
 * - Crops grow in specific seasons (potatoes/carrots in autumn)
 * - Wild berries fruit in spring/summer
 * - Trees provide logs year-round, seeds seasonally
 * - All consumed food must be harvested first
 * - Season affects crop yield and food availability
 */

/**
 * Plant growth progression
 * Defines when crops are harvestable based on season
 */

/proc/IsHarvestSeason(crop_name)
	/**
	 * Determine if a crop can be harvested right now
	 */
	var/list/consumable = CONSUMABLES[crop_name]
	if (!consumable)
		return 1  // Default to harvestable
	
	return IsSeasonForCrop(crop_name)


/proc/GetCropYield(crop_name)
	/**
	 * Calculate how much a harvested crop yields
	 * Modified by: season quality, farmer skill, soil quality
	 */
	var/base_yield = 1.0
	var/quality = GetConsumableQuality(crop_name, usr)
	
	// Better quality seasons give better yields
	if (quality >= 1.1)
		base_yield = 1.3  // 30% bonus yield
	else if (quality >= 0.9)
		base_yield = 1.0  // Normal yield
	else
		base_yield = 0.7  // 30% penalty yield
	
	return base_yield


/proc/GetCropGrowthDaysRemaining(crop_name)
	/**
	 * How many in-game days until crop is harvestable
	 * Used for farm management and player feedback
	 */
	var/list/consumable = CONSUMABLES[crop_name]
	if (!consumable)
		return 0
	
	var/list/seasons = consumable["seasons"]
	if (!seasons || seasons.len == 0)
		return 0  // Always available
	
	// Map month to season number
	var/season_map = list(
		"Spring" = 1,
		"Summer" = 2,
		"Autumn" = 3,
		"Winter" = 4
	)
	
	var/current_season_num = season_map[global.season]
	var/target_season_num = season_map[seasons[1]]
	
	if (target_season_num <= current_season_num)
		// Will mature next year cycle
		return (5 - current_season_num + target_season_num) * 14
	else
		// Will mature this year
		return (target_season_num - current_season_num) * 14


/**
 * Harvesting integration with hunger system
 */

/proc/HarvestCropWithYield(crop_name, harvest_skill_level, soil_type = SOIL_BASIC)
	/**
	 * When a player harvests a crop, determine yield
	 * Then add to inventory with appropriate stack
	 * 
	 * Formula: yield = base × season × skill × soil
	 * 
	 * soil_type: SOIL_BASIC (1.0), SOIL_RICH (1.2), SOIL_DEPLETED (0.5)
	 */
	var/base_yield = GetCropYield(crop_name)
	var/skill_bonus = max(0.5, harvest_skill_level / 10.0)  // Level 10 = 1.0x
	var/soil_yield_mod = GetSoilYieldModifier(soil_type)
	var/crop_soil_bonus = GetCropSoilBonus(crop_name, soil_type)
	
	var/total_yield = base_yield * skill_bonus * soil_yield_mod * crop_soil_bonus
	
	return round(total_yield)


/**
 * Seasonal food availability for NPCs/merchants
 */

/proc/GetAvailableFoodsThisSeason()
	/**
	 * Get all foods that can be found/purchased this season
	 * Used by:
	 * - Merchants (what they stock)
	 * - Foraging (what players can find)
	 * - Wildlife/NPCs (what they eat)
	 */
	var/list/available = list()
	
	for (var/food_name in CONSUMABLES)
		if (IsSeasonForCrop(food_name))
			available += food_name
	
	return available


/**
 * Food spoilage system (future feature)
 */

/proc/GetFoodDecayTime(food_name)
	/**
	 * How long before food spoils (in-game days)
	 * Berries: 2-3 days
	 * Vegetables: 5-7 days
	 * Grains: 30+ days
	 */
	var/decay_rate = ConsumableDecayRate(food_name)
	
	if (decay_rate == 0)
		return 0  // Never decays
	
	// 100 hunger points = 1 day of food for one person
	// Decay is percentage per day
	return round(100 / decay_rate)


/**
 * Environmental effects on crop growth
 */

/proc/ApplyWeatherEffectsToCropGrowth(crop_name, weather_type, ambient_temp)
	/**
	 * Severe weather can damage crops in transit
	 * Extreme heat kills berries
	 * Frost kills sensitive crops
	 */
	var/quality_penalty = 0
	
	switch(weather_type)
		if("thunderstorm", "dust_storm")
			quality_penalty += 0.1
		if("blizzard", "extreme_wind")
			quality_penalty += 0.2
	
	if (ambient_temp < 0)
		quality_penalty += 0.15  // Frost damage
	if (ambient_temp > 35)
		quality_penalty += 0.1   // Heat damage
	
	return max(0.1, 1.0 - quality_penalty)


/**
 * Resource gathering integration
 */

/obj/plants/proc/GetHarvestYield(mob/players/player)
	/**
	 * When a player harvests this plant, how much do they get?
	 */
	if (!CONSUMABLES)
		return 1
	
	if (!player)
		player = usr
	
	var/item_name = src.name
	var/harvest_rank = player.hrank ? player.hrank : 1
	return HarvestCropWithYield(lowertext(item_name), harvest_rank)


/obj/plant/proc/GetHarvestConsumable()
	/**
	 * What consumable does this plant produce when harvested?
	 */
	// Map plant types to consumables
	var/harvest_map = list(
		/obj/items/Fruit/Raspberry = "raspberry",
		/obj/items/Fruit/Blueberry = "blueberry",
		/obj/items/Fruit/RaspberryCluster = "raspberry cluster",
		/obj/items/Fruit/BlueberryCluster = "blueberry cluster",
		/obj/items/Vegetables/Potato = "potato",
		/obj/items/Vegetables/Carrot = "carrot",
		/obj/items/Vegetables/Onion = "onion",
		/obj/items/Vegetables/Tomato = "tomato",
		/obj/items/Vegetables/Pumpkin = "pumpkin"
	)
	
	for (var/plant_type in harvest_map)
		if (istype(src, plant_type))
			return harvest_map[plant_type]
	
	return null


/**
 * Growth stage integration with harvest timing
 */

/proc/GetPlantGrowthStageProgress(plant_obj)
	/**
	 * Return growth stage info for UI display
	 */
	if (!plant_obj)
		return 0
	
	// Check for growstage variable
	if (plant_obj:growstage)
		return plant_obj:growstage
	if (plant_obj:bgrowstage)
		return plant_obj:bgrowstage
	if (plant_obj:vgrowstage)
		return plant_obj:vgrowstage
	
	return 0


/**
 * Farming skill progression
 */

/proc/ApplyFarmingSkillBonus(player_hrank)
	/**
	 * Calculate harvest skill multiplier
	 */
	if (!player_hrank)
		return 0.8  // Untrained penalty
	
	// Each harvesting rank: +10% efficiency
	return min(2.0, 0.8 + (player_hrank * 0.1))


/**
 * Wildlife & NPC food consumption
 * (Integration hook for future NPC feeding)
 */

/proc/NPCConsumesFood(npc, food_name)
	/**
	 * When an NPC eats food, apply satisfaction/mood
	 */
	if (!CONSUMABLES[food_name])
		return 0
	
	var/list/consumable = CONSUMABLES[food_name]
	var/nutrition = consumable["nutrition"]
	
	// NPC gets satisfied based on nutrition
	// Could affect: mood, work speed, loyalty
	return nutrition
