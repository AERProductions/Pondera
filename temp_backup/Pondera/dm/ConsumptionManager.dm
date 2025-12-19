/**
 * CONSUMPTION MANAGER SYSTEM
 * Unified food, drink, and consumable tracking
 * Tied to environmental factors, seasons, and farming
 *
 * Philosophy: In Pondera, everything you eat or drink comes from
 * the world around you - harvested crops, wild berries, foraged water.
 * Season affects what's available, and consumption affects
 * your survival in extreme climates.
 */

// ==================== CONSUMABLE REGISTRY ====================
/**
 * Global database of all consumables
 * Tags: food_type, nutrition, hydration, health, stamina
 * seasons: list of seasons when available (growth season)
 * environment: preferred biome (affects yield/quality)
 */

var/global/list/CONSUMABLES = list(
	// WATER SOURCES
	"fresh water" = list(
		"type" = "water",
		"nutrition" = 0,
		"hydration" = 300,
		"health" = 0,
		"stamina" = 100,
		"base_cost" = 5,  // stamina cost to consume
		"seasons" = list("Spring", "Summer", "Autumn", "Winter"),
		"biomes" = list("temperate", "jungle", "arctic", "desert", "rainforest"),
		"quality" = 1.0
	),
	"oasis water" = list(
		"type" = "water",
		"nutrition" = 0,
		"hydration" = 300,
		"health" = 0,
		"stamina" = 100,
		"base_cost" = 5,
		"seasons" = list("Spring", "Summer", "Autumn", "Winter"),
		"biomes" = list("desert"),  // Desert-only oasis
		"quality" = 1.0
	),
	"jungle water" = list(
		"type" = "water",
		"nutrition" = 0,
		"hydration" = 250,  // Slightly less pure
		"health" = 0,
		"stamina" = 100,
		"base_cost" = 5,
		"seasons" = list("Spring", "Summer", "Autumn"),  // Not available in winter (frozen)
		"biomes" = list("jungle", "rainforest"),
		"quality" = 0.9
	),
	"water vine" = list(
		"type" = "water",
		"nutrition" = 10,
		"hydration" = 300,
		"health" = 0,
		"stamina" = 80,
		"base_cost" = 5,
		"seasons" = list("Spring", "Summer", "Autumn"),
		"biomes" = list("jungle", "rainforest"),
		"quality" = 0.95
	),
	"cactus water" = list(
		"type" = "water",
		"nutrition" = 20,
		"hydration" = 200,  // Less but more nutritious
		"health" = 5,
		"stamina" = 80,
		"base_cost" = 5,
		"seasons" = list("Spring", "Summer", "Autumn", "Winter"),  // Cacti available year-round
		"biomes" = list("desert"),
		"quality" = 0.8
	),
	"fountain water" = list(
		"type" = "water",
		"nutrition" = 0,
		"hydration" = 350,  // Best hydration
		"health" = 25,  // Magical healing
		"stamina" = 120,
		"base_cost" = 10,
		"seasons" = list("Spring", "Summer", "Autumn", "Winter"),
		"biomes" = list("temperate"),
		"quality" = 1.2  // Premium quality
	),
	"jar water" = list(
		"type" = "water",
		"nutrition" = 0,
		"hydration" = 300,
		"health" = 0,
		"stamina" = 100,
		"base_cost" = 5,
		"seasons" = list("Spring", "Summer", "Autumn", "Winter"),
		"biomes" = list(),  // Any biome (container item)
		"quality" = 1.0
	),
	
	// BERRIES (SPRING/SUMMER/AUTUMN harvests)
	"raspberry" = list(
		"type" = "food",
		"nutrition" = 15,
		"hydration" = 50,
		"health" = 10,
		"stamina" = 5,
		"base_cost" = 3,
		"seasons" = list("Spring", "Summer", "Autumn"),
		"biomes" = list("temperate", "rainforest"),
		"quality" = 1.0,
		"rarity" = "common"
	),
	"blueberry" = list(
		"type" = "food",
		"nutrition" = 15,
		"hydration" = 60,
		"health" = 5,
		"stamina" = 10,
		"base_cost" = 3,
		"seasons" = list("Spring", "Summer", "Autumn"),
		"biomes" = list("temperate", "rainforest"),
		"quality" = 1.0,
		"rarity" = "common"
	),
	"raspberry cluster" = list(
		"type" = "food",
		"nutrition" = 75,
		"hydration" = 100,
		"health" = 100,
		"stamina" = 20,
		"base_cost" = 10,
		"seasons" = list("Summer", "Autumn"),
		"biomes" = list("temperate", "rainforest"),
		"quality" = 1.1,
		"rarity" = "uncommon"
	),
	"blueberry cluster" = list(
		"type" = "food",
		"nutrition" = 75,
		"hydration" = 120,
		"health" = 50,
		"stamina" = 100,
		"base_cost" = 10,
		"seasons" = list("Summer", "Autumn"),
		"biomes" = list("temperate", "rainforest"),
		"quality" = 1.1,
		"rarity" = "uncommon"
	),
	
	// VEGETABLES (AUTUMN harvest)
	"potato" = list(
		"type" = "food",
		"nutrition" = 40,
		"hydration" = 30,
		"health" = 10,
		"stamina" = 20,
		"base_cost" = 5,
		"seasons" = list("Autumn", "Winter"),  // Stored food
		"biomes" = list("temperate"),
		"quality" = 1.0,
		"rarity" = "common"
	),
	"carrot" = list(
		"type" = "food",
		"nutrition" = 35,
		"hydration" = 40,
		"health" = 10,
		"stamina" = 15,
		"base_cost" = 5,
		"seasons" = list("Autumn", "Winter"),
		"biomes" = list("temperate"),
		"quality" = 1.0,
		"rarity" = "common"
	),
	"onion" = list(
		"type" = "food",
		"nutrition" = 30,
		"hydration" = 25,
		"health" = 5,
		"stamina" = 10,
		"base_cost" = 3,
		"seasons" = list("Autumn", "Winter"),
		"biomes" = list("temperate"),
		"quality" = 0.9,
		"rarity" = "common"
	),
	"tomato" = list(
		"type" = "food",
		"nutrition" = 25,
		"hydration" = 60,
		"health" = 8,
		"stamina" = 8,
		"base_cost" = 4,
		"seasons" = list("Summer", "Autumn"),  // Summer crop
		"biomes" = list("temperate"),
		"quality" = 1.0,
		"rarity" = "common"
	),
	"pumpkin" = list(
		"type" = "food",
		"nutrition" = 50,
		"hydration" = 40,
		"health" = 10,
		"stamina" = 25,
		"base_cost" = 7,
		"seasons" = list("Autumn"),  // Harvest in autumn
		"biomes" = list("temperate"),
		"quality" = 1.0,
		"rarity" = "uncommon"
	),
	
	// GRAINS (AUTUMN harvest, winter storage)
	"wheat" = list(
		"type" = "food",
		"nutrition" = 50,
		"hydration" = 20,
		"health" = 0,
		"stamina" = 30,
		"base_cost" = 6,
		"seasons" = list("Autumn", "Winter"),  // Stored
		"biomes" = list("temperate"),
		"quality" = 1.0,
		"rarity" = "common"
	),
	"barley" = list(
		"type" = "food",
		"nutrition" = 50,
		"hydration" = 20,
		"health" = 0,
		"stamina" = 30,
		"base_cost" = 6,
		"seasons" = list("Autumn", "Winter"),
		"biomes" = list("temperate"),
		"quality" = 1.0,
		"rarity" = "common"
	)
)

// ==================== CONSUMPTION QUALITY SYSTEM ====================
/**
 * Calculate consumption quality based on:
 * - Current season vs. harvest season
 * - Biome match
 * - Storage/freshness (if applicable)
 * - Environmental conditions
 */

/proc/GetConsumableQuality(food_name, mob/players/consumer)
	var/list/consumable = CONSUMABLES[food_name]
	if (!consumable)
		return 1.0
	
	var/quality = consumable["quality"]
	var/current_season = global.season
	var/list/available_seasons = consumable["seasons"]
	
	// SEASONAL PENALTY - eating out-of-season food is less nourishing
	if (available_seasons && !(current_season in available_seasons))
		quality *= 0.7  // 30% quality loss out of season
	
	// BIOME MATCH - local foods are more nourishing
	if (consumer && consumer.ambient_temp)  // Check if player has environment info
		var/current_biome = "temperate"  // Default
		// Try to get biome from zone manager if available
		if (global.zone_mgr && global.zone_mgr.active_zones)
			for (var/dynamic_zone/dz in global.zone_mgr.active_zones)
				var/chunk_center_x = dz.chunk_x * global.zone_mgr.chunk_size + (global.zone_mgr.chunk_size / 2)
				var/chunk_center_y = dz.chunk_y * global.zone_mgr.chunk_size + (global.zone_mgr.chunk_size / 2)
				var/distance = sqrt((consumer.x - chunk_center_x) ** 2 + (consumer.y - chunk_center_y) ** 2)
				if(distance < 50)
					current_biome = dz.terrain_type ? dz.terrain_type : "temperate"
					break
		
		var/list/biomes = consumable["biomes"]
		if (biomes && biomes.len > 0)
			if (!(current_biome in biomes))
				quality *= 0.85  // 15% loss if not local biome
			else
				quality *= 1.1   // 10% bonus if local biome
	
	return max(0.5, quality)  // Never below 50% quality


/**
 * Seasonal availability check
 * Used for farming/harvesting - when can a crop be harvested?
 */
/proc/IsSeasonForCrop(crop_name)
	var/list/consumable = CONSUMABLES[crop_name]
	if (!consumable)
		return 1  // Default to available
	
	var/list/seasons = consumable["seasons"]
	return (global.season in seasons) ? 1 : 0


/**
 * Get all available foods in current season
 */
/proc/GetSeasonalConsumables()
	var/list/available = list()
	var/current_season = global.season
	
	for (var/food_name in CONSUMABLES)
		var/list/consumable = CONSUMABLES[food_name]
		var/list/seasons = consumable["seasons"]
		if (!seasons || (current_season in seasons))
			available[food_name] = consumable
	
	return available


/**
 * Get environmental impact on food availability
 * E.g., extreme cold kills crops, drought affects water
 */
/proc/EnvironmentalImpactOnConsumables(mob/players/player)
	var/multiplier = 1.0
	
	if (!player)
		return multiplier
	
	var/ambient_temp = player.ambient_temp ? player.ambient_temp : 15
	
	// EXTREME COLD - limits availability of fresh foods
	if (ambient_temp <= -10)
		multiplier *= 0.8  // 20% less nourishment from fresh foods
	
	// EXTREME HEAT - affects hydration but increases water consumption
	if (ambient_temp >= 35)
		multiplier *= 0.9  // Foods less nourishing
	
	return multiplier


/**
 * Nutrition decay over time (perishability)
 * Fresh berries rot faster than stored grains
 */
/proc/ConsumableDecayRate(food_name)
	var/list/consumable = CONSUMABLES[food_name]
	if (!consumable)
		return 0
	
	var/food_type = consumable["type"]
	
	switch(food_type)
		if("water")
			return 0  // Water doesn't decay
		if("food")
			var/rarity = consumable["rarity"]
			switch(rarity)
				if("common")
					return 2  // Decays 2% per day
				if("uncommon")
					return 3  // Decays faster
				else
					return 1
		else
			return 1
	
	return 0

