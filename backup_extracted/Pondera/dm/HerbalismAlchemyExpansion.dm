/// ============================================================================
/// HERBALISM & ALCHEMY EXPANSION SYSTEM
/// System for herb gathering, potion crafting, effects application, and
/// ingredient quality/rarity classification.
///
/// Created: 12-11-25 12:30AM
/// ============================================================================

#define HERB_RARITY_COMMON      1
#define HERB_RARITY_UNCOMMON    2
#define HERB_RARITY_RARE        3
#define HERB_RARITY_EPIC        4
#define HERB_RARITY_LEGENDARY   5

#define POTION_EFFECT_DURATION  100  // 10 seconds base
#define POTION_EFFECT_STACK_MAX 3    // Max stacks of same effect

/// ============================================================================
/// HERB DEFINITION DATUM
/// ============================================================================

/datum/herb
	var
		name = ""                // "Moonflower", "Dragon's Breath"
		rarity = HERB_RARITY_COMMON
		description = ""
		harvesting_level = 1    // Gardening level required
		seasons = list()         // When available
		biomes = list()          // Where found
		properties = list()      // Effects/attributes
		harvest_quantity = 1     // Items per harvest
		regrow_time = 0          // Ticks to respawn
		stack_limit = 99

/datum/herb/proc/GetRarityColor()
	switch(rarity)
		if(HERB_RARITY_COMMON)
			return "#90caf9"      // Blue
		if(HERB_RARITY_UNCOMMON)
			return "#81c784"      // Green
		if(HERB_RARITY_RARE)
			return "#ffb74d"      // Orange
		if(HERB_RARITY_EPIC)
			return "#ce93d8"      // Purple
		if(HERB_RARITY_LEGENDARY)
			return "#ff6b6b"      // Red
	return "#ddd"

/datum/herb/proc/GetRarityName()
	switch(rarity)
		if(HERB_RARITY_COMMON)
			return "Common"
		if(HERB_RARITY_UNCOMMON)
			return "Uncommon"
		if(HERB_RARITY_RARE)
			return "Rare"
		if(HERB_RARITY_EPIC)
			return "Epic"
		if(HERB_RARITY_LEGENDARY)
			return "Legendary"
	return "Unknown"

/// ============================================================================
/// POTION EFFECT DATUM
/// ============================================================================

/datum/potion_effect
	var
		name = ""                // "Regeneration", "Speed Boost"
		effect_type = ""         // health, mana, stamina, speed, strength
		magnitude = 0            // 0-100 (percent or flat value)
		duration = 0             // Ticks remaining
		stack_count = 1          // Number of stacks
		color = "#fff"           // Visual indicator

/datum/potion_effect/proc/Apply(mob/player)
	// Apply effect to player
	switch(effect_type)
		if("health")
			player << "<span style='color: #81c784;'>+[magnitude]% Health restored!</span>"
		if("mana")
			if("mana" in player.vars)
				player.vars["mana"] = min(100, player.vars["mana"] + magnitude)
				player << "<span style='color: #90caf9;'>+[magnitude] Mana!</span>"
		if("stamina")
			player << "<span style='color: #ffb74d;'>+[magnitude]% Stamina boost!</span>"
		if("speed")
			player << "<span style='color: #4fc3f7;'>Speed increased by [magnitude]%!</span>"
		if("strength")
			player << "<span style='color: #ff6b6b;'>Strength increased by [magnitude]%!</span>"

/datum/potion_effect/proc/Tick()
	// Decrement duration
	duration = max(0, duration - 1)
	return duration > 0

/// ============================================================================
/// POTION DEFINITION DATUM
/// ============================================================================

/datum/potion
	var
		name = ""                // "Healing Potion", "Swiftness Draught"
		description = ""
		rarity = HERB_RARITY_COMMON
		recipe_id = ""           // Link to recipe system
		effects = list()         // List of /datum/potion_effect
		ingredients = list()     // herb_name -> quantity
		alchemy_level = 1        // Alchemy skill required
		duration = 100           // Base effect duration
		potency = 1.0            // Quality multiplier

/datum/potion/proc/GetEffectsDescription()
	var/desc = ""
	for(var/datum/potion_effect/effect in effects)
		desc += "[effect.name] +[effect.magnitude]% | "
	return desc

/datum/potion/proc/Use(mob/player)
	// Consume potion and apply effects
	for(var/datum/potion_effect/effect in effects)
		var/datum/potion_effect/active_effect = new /datum/potion_effect()
		active_effect.name = effect.name
		active_effect.magnitude = effect.magnitude
		active_effect.duration = round(duration * potency)
		active_effect.effect_type = effect.effect_type
		
		// Add to player's active effects (would integrate with buff system)
		if(!("active_effects" in player.vars))
			player.vars["active_effects"] = list()
		
		var/list/active = player.vars["active_effects"]
		active += active_effect
	
	player << "<span style='color: #81c784;'>You consume [name]...</span>"
	return TRUE

/// ============================================================================
/// HERB REGISTRY
/// ============================================================================

var/datum/herb_registry/global_herb_registry

/proc/GetHerbRegistry()
	if(!global_herb_registry)
		global_herb_registry = new /datum/herb_registry()
	return global_herb_registry

/datum/herb_registry
	var
		all_herbs = list()       // herb_name -> /datum/herb

/datum/herb_registry/proc/RegisterHerbs()
	// Initialize all available herbs
	
	// COMMON HERBS
	var/datum/herb/moonflower = new
	moonflower.name = "Moonflower"
	moonflower.rarity = HERB_RARITY_COMMON
	moonflower.description = "A delicate white flower that blooms at night. Basic healing properties."
	moonflower.harvesting_level = 1
	moonflower.seasons = list("Summer", "Autumn")
	moonflower.biomes = list("forest", "meadow")
	moonflower.properties = list("healing", "calming")
	moonflower.harvest_quantity = 2
	moonflower.regrow_time = 200
	all_herbs["moonflower"] = moonflower
	
	var/datum/herb/shadowleaf = new
	shadowleaf.name = "Shadowleaf"
	shadowleaf.rarity = HERB_RARITY_COMMON
	shadowleaf.description = "Dark green leaves that thrive in shade. Used in basic potions."
	shadowleaf.harvesting_level = 1
	shadowleaf.seasons = list("Spring", "Summer", "Autumn", "Winter")
	shadowleaf.biomes = list("forest", "swamp")
	shadowleaf.properties = list("potency", "bitterness")
	shadowleaf.harvest_quantity = 3
	shadowleaf.regrow_time = 150
	all_herbs["shadowleaf"] = shadowleaf
	
	// UNCOMMON HERBS
	var/datum/herb/bloodblossom = new
	bloodblossom.name = "Bloodblossom"
	bloodblossom.rarity = HERB_RARITY_UNCOMMON
	bloodblossom.description = "Crimson petals with restorative powers. Uncommon but valuable."
	bloodblossom.harvesting_level = 2
	bloodblossom.seasons = list("Summer", "Autumn")
	bloodblossom.biomes = list("mountain", "badlands")
	bloodblossom.properties = list("vitality", "regeneration")
	bloodblossom.harvest_quantity = 1
	bloodblossom.regrow_time = 300
	all_herbs["bloodblossom"] = bloodblossom
	
	// RARE HERBS
	var/datum/herb/starfruit_herb = new
	starfruit_herb.name = "Starfruit Vine"
	starfruit_herb.rarity = HERB_RARITY_RARE
	starfruit_herb.description = "Exotic vine with star-shaped fruit. Powerful alchemical ingredient."
	starfruit_herb.harvesting_level = 3
	starfruit_herb.seasons = list("Summer")
	starfruit_herb.biomes = list("tropical")
	starfruit_herb.properties = list("mana", "clarity")
	starfruit_herb.harvest_quantity = 1
	starfruit_herb.regrow_time = 500
	all_herbs["starfruit_vine"] = starfruit_herb
	
	var/datum/herb/dragon_breath = new
	dragon_breath.name = "Dragon's Breath"
	dragon_breath.rarity = HERB_RARITY_RARE
	dragon_breath.description = "Golden petals that spark with energy. Rare fire herb."
	dragon_breath.harvesting_level = 3
	dragon_breath.seasons = list("Summer", "Autumn")
	dragon_breath.biomes = list("volcano", "badlands")
	dragon_breath.properties = list("fire", "strength")
	dragon_breath.harvest_quantity = 1
	dragon_breath.regrow_time = 450
	all_herbs["dragon_breath"] = dragon_breath
	
	// EPIC HERBS
	var/datum/herb/void_lotus = new
	void_lotus.name = "Void Lotus"
	void_lotus.rarity = HERB_RARITY_EPIC
	void_lotus.description = "Ethereal flower from another plane. Immensely powerful."
	void_lotus.harvesting_level = 4
	void_lotus.seasons = list("Autumn")
	void_lotus.biomes = list("void_realm")
	void_lotus.properties = list("void", "transcendence")
	void_lotus.harvest_quantity = 1
	void_lotus.regrow_time = 1000
	all_herbs["void_lotus"] = void_lotus
	
	// LEGENDARY HERBS
	var/datum/herb/divine_nectar = new
	divine_nectar.name = "Divine Nectar"
	divine_nectar.rarity = HERB_RARITY_LEGENDARY
	divine_nectar.description = "Drops of pure divine essence. Grants powerful blessings."
	divine_nectar.harvesting_level = 5
	divine_nectar.seasons = list()  // Always available but extremely rare
	divine_nectar.biomes = list("celestial")
	divine_nectar.properties = list("divinity", "immortality")
	divine_nectar.harvest_quantity = 1
	divine_nectar.regrow_time = 2000
	all_herbs["divine_nectar"] = divine_nectar

/datum/herb_registry/proc/GetHerb(herb_name)
	if(!length(all_herbs))
		RegisterHerbs()
	return all_herbs[herb_name]

/datum/herb_registry/proc/GetHerbsByRarity(rarity)
	var/list/result = list()
	if(!length(all_herbs))
		RegisterHerbs()
	
	for(var/hname in all_herbs)
		var/datum/herb/h = all_herbs[hname]
		if(h.rarity == rarity)
			result += h
	
	return result

/datum/herb_registry/proc/GetHerbsByBiome(biome)
	var/list/result = list()
	if(!length(all_herbs))
		RegisterHerbs()
	
	for(var/hname in all_herbs)
		var/datum/herb/h = all_herbs[hname]
		if(biome in h.biomes)
			result += h
	
	return result

/// ============================================================================
/// ALCHEMY SYSTEM COORDINATOR
/// ============================================================================

var/datum/alchemy_system/global_alchemy_system

/proc/GetAlchemySystem()
	if(!global_alchemy_system)
		global_alchemy_system = new /datum/alchemy_system()
	return global_alchemy_system

/datum/alchemy_system
	var
		all_potions = list()     // potion_id -> /datum/potion
		player_recipes = list()  // player -> list of discovered recipe IDs
		player_effects = list()  // player -> list of active effects

/datum/alchemy_system/proc/RegisterPotions()
	// Initialize all potion recipes
	
	var/datum/potion/healing = new
	healing.name = "Healing Potion"
	healing.description = "Basic restoration draught. Restores health."
	healing.rarity = HERB_RARITY_COMMON
	healing.recipe_id = "potion_healing"
	healing.alchemy_level = 1
	healing.ingredients = list("moonflower" = 2, "shadowleaf" = 1)
	var/datum/potion_effect/health_effect = new /datum/potion_effect()
	health_effect.name = "Healing"
	health_effect.effect_type = "health"
	health_effect.magnitude = 30
	healing.effects += health_effect
	all_potions["healing"] = healing
	
	var/datum/potion/swiftness = new
	swiftness.name = "Swiftness Draught"
	swiftness.description = "Increases movement speed temporarily."
	swiftness.rarity = HERB_RARITY_UNCOMMON
	swiftness.recipe_id = "potion_swiftness"
	swiftness.alchemy_level = 2
	swiftness.ingredients = list("shadowleaf" = 2, "bloodblossom" = 1)
	var/datum/potion_effect/speed_effect = new /datum/potion_effect()
	speed_effect.name = "Speed Boost"
	speed_effect.effect_type = "speed"
	speed_effect.magnitude = 25
	swiftness.effects += speed_effect
	all_potions["swiftness"] = swiftness
	
	var/datum/potion/mana_elixir = new
	mana_elixir.name = "Mana Elixir"
	mana_elixir.description = "Restores magical energy and clarity."
	mana_elixir.rarity = HERB_RARITY_RARE
	mana_elixir.recipe_id = "potion_mana"
	mana_elixir.alchemy_level = 3
	mana_elixir.ingredients = list("starfruit_vine" = 1, "shadowleaf" = 3)
	var/datum/potion_effect/mana_effect = new /datum/potion_effect()
	mana_effect.name = "Mana Restoration"
	mana_effect.effect_type = "mana"
	mana_effect.magnitude = 50
	mana_elixir.effects += mana_effect
	all_potions["mana_elixir"] = mana_elixir
	
	var/datum/potion/divine_grace = new
	divine_grace.name = "Divine Grace"
	divine_grace.description = "Legendary potion granting divine blessings."
	divine_grace.rarity = HERB_RARITY_LEGENDARY
	divine_grace.recipe_id = "potion_divine"
	divine_grace.alchemy_level = 5
	divine_grace.ingredients = list("divine_nectar" = 1, "void_lotus" = 1)
	var/datum/potion_effect/divinity = new /datum/potion_effect()
	divinity.name = "Divine Blessing"
	divinity.effect_type = "strength"
	divinity.magnitude = 100
	divine_grace.effects += divinity
	all_potions["divine_grace"] = divine_grace

/datum/alchemy_system/proc/GetPotion(potion_id)
	if(!length(all_potions))
		RegisterPotions()
	return all_potions[potion_id]

/datum/alchemy_system/proc/BrewPotion(mob/player, potion_id)
	// Attempt to craft potion
	var/datum/potion/potion = GetPotion(potion_id)
	if(!potion)
		return FALSE
	
	// Check alchemy level
	if("character" in player.vars)
		var/datum/character_data/char = player.vars["character"]
		if(istype(char))
			var/level = char.GetRankLevel(RANK_CRAFTING)
			if(level < potion.alchemy_level)
				player << "<span style='color: #ff6b6b;'>Alchemy Level [potion.alchemy_level] required!</span>"
				return FALSE
	
	player << "<span style='color: #81c784;'>Brewing [potion.name]...</span>"
	return TRUE

/datum/alchemy_system/proc/ShowHerbBrowser()
	// Display all available herbs
	var/datum/herb_registry/registry = GetHerbRegistry()
	registry.RegisterHerbs()
	
	var/html = "<html><head><title>Herb Browser</title><style>"
	html += "body { background: #0a0a0a; color: #ddd; font-family: monospace; padding: 15px; }"
	html += ".herb-card { border-left: 4px solid #81c784; background: #1a1a1a; padding: 10px; margin: 10px 0; }"
	html += ".rarity { font-weight: bold; }"
	html += "</style></head><body><h1>Herb Encyclopedia</h1>"
	
	for(var/rarity = 1; rarity <= 5; rarity++)
		var/list/herbs_at_rarity = registry.GetHerbsByRarity(rarity)
		if(!length(herbs_at_rarity))
			continue
		
		// Get rarity name
		var/rarity_name = "Unknown"
		switch(rarity)
			if(1) rarity_name = "Common"
			if(2) rarity_name = "Uncommon"
			if(3) rarity_name = "Rare"
			if(4) rarity_name = "Epic"
			if(5) rarity_name = "Legendary"
		
		html += "<h2>[rarity_name] Herbs</h2>"
		
		for(var/datum/herb/h in herbs_at_rarity)
			html += "<div class='herb-card'>"
			html += "<div class='rarity' style='color: [h.GetRarityColor()];'>[h.name] ([h.GetRarityName()])</div>"
			html += "<div>[h.description]</div>"
			html += "<div style='font-size: 0.9em; color: #90caf9;'>"
			html += "Level [h.harvesting_level] | Quantity: [h.harvest_quantity] | Properties: "
			for(var/prop in h.properties)
				html += "[prop] "
			html += "</div></div>"
	
	html += "</body></html>"
	return html

/// ============================================================================
/// INTEGRATION WITH INITIALIZATION
/// ============================================================================

proc/InitializeHerbalism()
	// Called from InitializationManager.dm Phase 5
	
	if(!world_initialization_complete)
		spawn(400)
			InitializeHerbalism()
		return
	
	var/datum/alchemy_system/alchemy = GetAlchemySystem()
	var/datum/herb_registry/herbs = GetHerbRegistry()
	
	herbs.RegisterHerbs()
	alchemy.RegisterPotions()
	
	RegisterInitComplete("HerbalisAnd Alchemy")

/// ============================================================================
/// END HERBALISM & ALCHEMY EXPANSION SYSTEM
/// ============================================================================
