// AnimalOwnershipIntegration.dm - Complete Animal Ownership & Produce Tracking
// Integrates AnimalHusbandrySystem.dm with player inventory, deed system, and produce creation
// Handles ownership persistence, produce harvesting, and animal tracking

// ============================================================================
// ANIMAL OWNERSHIP DATUM (Persistent)
// ============================================================================

/datum/animal_owner_data
	var
		owner_ckey = ""          // Player ckey
		animal_id = 0            // Unique ID for this animal
		species_type = ""        // "cow", "sheep", "chicken", "fish"
		animal_name = ""         // Custom name given by player
		location = null          // Turf where animal is placed
		deed_id = 0              // Deed claiming this land (0 = unclaimed)
		
		// Life stats
		age_ticks = 0            // Ticks since spawn
		health = 100             // 0-100
		hunger = 0               // 0-100
		happiness = 50           // 0-100
		
		// Reproductive state
		is_pregnant = FALSE
		pregnancy_ticks = 0      // Ticks remaining until birth
		
		// Production
		last_product_time = 0    // world.time of last product generation
		produced_items = 0       // Total items produced by this animal
		
		// Traits (inherited from parents)
		health_trait = 1.0       // Multiplier for base health
		fertility_trait = 1.0    // Multiplier for breeding success
		production_trait = 1.0   // Multiplier for product quality

/datum/animal_owner_data/proc/GetDisplayString()
	/**
	 * Return formatted string for display
	 */
	var/status = "[animal_name] the [species_type] (Age: [age_ticks] ticks, Health: [health]%, Hunger: [hunger]%)"
	if(is_pregnant)
		status += " - PREGNANT ([pregnancy_ticks] ticks)"
	return status

// ============================================================================
// GLOBAL ANIMAL OWNERSHIP REGISTRY
// ============================================================================

var/global/list/global_animal_registry = list()        // all_animals = list of /datum/animal_owner_data
var/global/list/global_player_animals = list()         // player_ckey = list of animal IDs
var/global/animal_id_counter = 0                       // Auto-increment for unique animal IDs

// ============================================================================
// ANIMAL OWNERSHIP PROCS
// ============================================================================

/**
 * CreateAnimal(ckey, species_type, location, deed_id)
 * Create new animal owned by player
 * 
 * @param ckey: Player character key
 * @param species_type: "cow", "sheep", "chicken", "fish"
 * @param location: Turf to place animal at
 * @param deed_id: Deed claiming this land (optional, 0 = unclaimed)
 * @return: animal_id or 0 if failed
 */
proc/CreateAnimal(ckey, species_type, turf/location, deed_id = 0)
	if(!ckey || !species_type || !location) return 0
	
	// Verify species exists
	var/datum/animal_husbandry_system/husbandry = GetAnimalHusbandrySystem()
	var/datum/animal_species/species = husbandry.GetAvailableSpecies()[species_type]
	if(!species)
		world.log << "ERROR: Unknown animal species: [species_type]"
		return 0
	
	// Create new animal instance
	animal_id_counter++
	var/datum/animal_owner_data/animal = new()
	
	animal.owner_ckey = ckey
	animal.animal_id = animal_id_counter
	animal.species_type = species_type
	animal.animal_name = "[species.name] #[animal_id_counter]"
	animal.location = location
	animal.deed_id = deed_id
	animal.age_ticks = 0
	animal.health = species.base_health
	animal.hunger = 30
	animal.happiness = 50
	animal.last_product_time = world.time
	
	// Add to global registry
	global_animal_registry += animal
	
	// Add to player's animal list
	if(!(ckey in global_player_animals))
		global_player_animals[ckey] = list()
	global_player_animals[ckey] += animal.animal_id
	
	return animal.animal_id

/**
 * GetAnimal(animal_id)
 * Retrieve animal by ID
 * 
 * @param animal_id: Unique animal ID
 * @return: animal_owner_data or null
 */
proc/GetAnimal(animal_id)
	if(!animal_id) return null
	
	for(var/datum/animal_owner_data/animal in global_animal_registry)
		if(animal.animal_id == animal_id)
			return animal
	
	return null

/**
 * GetPlayerAnimals(ckey)
 * Get all animals owned by player
 * 
 * @param ckey: Player character key
 * @return: list of animal_owner_data
 */
proc/GetPlayerAnimals(ckey)
	if(!ckey) return list()
	
	var/list/result = list()
	var/list/animal_ids = global_player_animals[ckey]
	
	if(!animal_ids) return result
	
	for(var/id in animal_ids)
		var/datum/animal_owner_data/animal = GetAnimal(id)
		if(animal)
			result += animal
	
	return result

/**
 * DeleteAnimal(animal_id)
 * Remove animal from world (death/slaughter)
 * 
 * @param animal_id: Animal to remove
 */
proc/DeleteAnimal(animal_id)
	var/datum/animal_owner_data/animal = GetAnimal(animal_id)
	if(!animal) return
	
	// Remove from player's list
	if(animal.owner_ckey in global_player_animals)
		global_player_animals[animal.owner_ckey] -= animal.animal_id
	
	// Remove from global registry
	global_animal_registry -= animal

// ============================================================================
// ANIMAL LIFECYCLE TICKS
// ============================================================================

/**
 * TickAnimal(animal_id)
 * Process one game tick for an animal
 * Called every world tick for each owned animal
 * 
 * @param animal_id: Animal to process
 */
proc/TickAnimal(animal_id)
	var/datum/animal_owner_data/animal = GetAnimal(animal_id)
	if(!animal) return
	
	var/datum/animal_husbandry_system/husbandry = GetAnimalHusbandrySystem()
	var/datum/animal_species/species = husbandry.GetAvailableSpecies()[animal.species_type]
	if(!species) return
	
	// Increment age
	animal.age_ticks++
	
	// Hunger increases over time
	animal.hunger = min(100, animal.hunger + 0.1)
	
	// Hunger affects happiness
	if(animal.hunger > 80)
		animal.happiness = max(0, animal.happiness - 0.5)
	
	// Health degradation
	if(animal.hunger > 90)
		animal.health = max(0, animal.health - 0.5)  // Starving
	else if(animal.hunger > 75)
		animal.health = max(0, animal.health - 0.2)  // Very hungry
	
	// Health recovery if well-fed and happy
	if(animal.hunger < 30 && animal.happiness > 50)
		animal.health = min(100, animal.health + 0.3)
	
	// Starvation death
	if(animal.hunger >= 100)
		world << "<span class='warning'>[animal.animal_name] has died of starvation!</span>"
		DeleteAnimal(animal.animal_id)
		return
	
	// Age death
	if(animal.age_ticks > species.lifespan_ticks)
		world << "<span class='warning'>[animal.animal_name] has died of old age!</span>"
		DeleteAnimal(animal.animal_id)
		return
	
	// Generate products if mature and well-fed
	if(animal.age_ticks > species.maturity_ticks)
		if((world.time - animal.last_product_time) > species.product_interval)
			if(animal.hunger < 70 && animal.health > 40)
				GenerateAnimalProduct(animal.animal_id)
				animal.last_product_time = world.time
	
	// Pregnancy progression
	if(animal.is_pregnant)
		animal.pregnancy_ticks--
		if(animal.pregnancy_ticks <= 0)
			GiveBirth(animal.animal_id)

/**
 * FeedSpecificAnimal(animal_id, food_name, quantity)
 * Feed an animal with consumable item
 * 
 * @param animal_id: Animal to feed
 * @param food_name: Name of food item from CONSUMABLES registry
 * @param quantity: Number of items to consume
 * @return: TRUE if fed successfully
 */
proc/FeedSpecificAnimal(animal_id, food_name, quantity = 1)
	var/datum/animal_owner_data/animal = GetAnimal(animal_id)
	if(!animal) return FALSE
	
	var/datum/animal_husbandry_system/husbandry = GetAnimalHusbandrySystem()
	var/datum/animal_species/species = husbandry.GetAvailableSpecies()[animal.species_type]
	if(!species) return FALSE
	
	// Check if animal eats this food
	if(!(food_name in species.diet))
		return FALSE
	
	// Reduce hunger
	animal.hunger = max(0, animal.hunger - (10 * quantity))
	
	// Happiness bonus
	animal.happiness = min(100, animal.happiness + (5 * quantity))
	
	// Health recovery
	animal.health = min(100, animal.health + (2 * quantity))
	
	return TRUE

// ============================================================================
// ANIMAL PRODUCT GENERATION
// ============================================================================

/**
 * GenerateAnimalProduct(animal_id)
 * Create product items (milk, eggs, wool) and place in world
 * 
 * @param animal_id: Animal producing product
 */
proc/GenerateAnimalProduct(animal_id)
	var/datum/animal_owner_data/animal = GetAnimal(animal_id)
	if(!animal) return FALSE
	
	var/datum/animal_husbandry_system/husbandry = GetAnimalHusbandrySystem()
	var/datum/animal_species/species = husbandry.GetAvailableSpecies()[animal.species_type]
	if(!species) return FALSE
	
	// Calculate quantity based on health and happiness
	var/health_factor = animal.health / 100.0
	var/hunger_factor = max(0, (100 - animal.hunger) / 100.0)
	var/happiness_factor = animal.happiness / 100.0
	
	var/qty = round(species.product_quantity * health_factor * hunger_factor * happiness_factor * animal.production_trait)
	if(qty < 1) qty = 1
	
	// Create items in world at animal location
	if(animal.location)
		var/turf/spawn_location = animal.location
		
		// Create appropriate item based on product type
		switch(species.product)
			if("milk")
				for(var/i = 1; i <= qty; i++)
					var/obj/items/M = new(spawn_location)
					M.name = "fresh milk"
					M.icon_state = "milk"
			if("eggs")
				for(var/i = 1; i <= qty; i++)
					var/obj/items/E = new(spawn_location)
					E.name = "chicken egg"
					E.icon_state = "egg"
			if("wool")
				for(var/i = 1; i <= qty; i++)
					var/obj/items/W = new(spawn_location)
					W.name = "wool"
					W.icon_state = "wool"
			if("fish_meat")
				for(var/i = 1; i <= qty; i++)
					var/obj/items/F = new(spawn_location)
					F.name = "fresh fish"
					F.icon_state = "fish"
		
		animal.produced_items += qty
		return TRUE
	
	return FALSE

/**
 * HarvestProductFromGround(turf/location)
 * Collect all products lying on ground at location
 * Used when player walks over produced items
 * 
 * @param location: Turf to harvest from
 * @return: list of collected items
 */
proc/HarvestProductFromGround(turf/location)
	var/list/collected = list()
	
	for(var/obj/item/I in location.contents)
		// Check if item is animal product (milk, eggs, wool, etc.)
		if(findtext("[I.type]", "milk") || findtext("[I.type]", "egg") || findtext("[I.type]", "wool") || findtext("[I.type]", "fish_meat"))
			collected += I
	
	return collected

// ============================================================================
// ANIMAL BREEDING
// ============================================================================

/**
 * BreedAnimals(animal_id_1, animal_id_2)
 * Attempt to breed two animals
 * Both must be same species, mature, well-fed, happy
 * 
 * @param animal_id_1: First animal
 * @param animal_id_2: Second animal
 * @return: TRUE if breeding initiated
 */
proc/BreedAnimals(animal_id_1, animal_id_2)
	var/datum/animal_owner_data/animal1 = GetAnimal(animal_id_1)
	var/datum/animal_owner_data/animal2 = GetAnimal(animal_id_2)
	
	if(!animal1 || !animal2) return FALSE
	
	// Must be same species
	if(animal1.species_type != animal2.species_type) return FALSE
	
	var/datum/animal_husbandry_system/husbandry = GetAnimalHusbandrySystem()
	var/datum/animal_species/species = husbandry.GetAvailableSpecies()[animal1.species_type]
	if(!species || !species.IsBreedable()) return FALSE
	
	// Both must be mature and well-fed
	if(animal1.age_ticks < species.maturity_ticks || animal2.age_ticks < species.maturity_ticks) return FALSE
	if(animal1.hunger > 70 || animal2.hunger > 70) return FALSE
	if(animal1.happiness < 50 || animal2.happiness < 50) return FALSE
	
	// Pick a female (assume animal1 is female for simplicity)
	var/datum/animal_owner_data/female = animal1
	
	// Initiate pregnancy
	female.is_pregnant = TRUE
	female.pregnancy_ticks = species.gestation_ticks
	
	// Reduce happiness (pregnancy toll)
	female.happiness = max(0, female.happiness - 10)
	
	return TRUE

/**
 * GiveBirth(animal_id)
 * Create offspring from pregnant animal
 * 
 * @param animal_id: Pregnant animal
 */
proc/GiveBirth(animal_id)
	var/datum/animal_owner_data/animal = GetAnimal(animal_id)
	if(!animal || !animal.is_pregnant) return
	
	var/datum/animal_husbandry_system/husbandry = GetAnimalHusbandrySystem()
	var/datum/animal_species/species = husbandry.GetAvailableSpecies()[animal.species_type]
	if(!species) return
	
	// Create offspring
	var/offspring_id = CreateAnimal(animal.owner_ckey, animal.species_type, animal.location, animal.deed_id)
	if(!offspring_id) return
	
	var/datum/animal_owner_data/offspring = GetAnimal(offspring_id)
	if(!offspring) return
	
	// Offspring inherits traits from parent
	offspring.health_trait = animal.health_trait
	offspring.fertility_trait = animal.fertility_trait
	offspring.production_trait = animal.production_trait
	
	// Slight mutation chance
	if(prob(10))  // 10% chance for trait variation
		offspring.health_trait *= rand(0.9, 1.1)
		offspring.fertility_trait *= rand(0.9, 1.1)
		offspring.production_trait *= rand(0.9, 1.1)
	
	// Update parent
	animal.is_pregnant = FALSE
	animal.pregnancy_ticks = 0
	
	world << "<span class='good'>[animal.animal_name] has given birth to [offspring.animal_name]!</span>"

// ============================================================================
// ANIMAL SLAUGHTER
// ============================================================================

/**
 * SlaughterSpecificAnimal(animal_id)
 * Kill animal and return meat/hides/bones
 * 
 * @param animal_id: Animal to slaughter
 * @return: list of items produced
 */
proc/SlaughterSpecificAnimal(animal_id)
	var/datum/animal_owner_data/animal = GetAnimal(animal_id)
	if(!animal) return list()
	
	var/list/products = list()
	var/turf/location = animal.location
	
	if(!location) return products
	
	var/datum/animal_husbandry_system/husbandry = GetAnimalHusbandrySystem()
	var/datum/animal_species/species = husbandry.GetAvailableSpecies()[animal.species_type]
	if(!species) return products
	
	// Slaughter yields based on health
	var/meat_qty = round(3 * (animal.health / 100.0))
	var/hide_qty = round(1 * (animal.health / 100.0))
	
	// Create items
	for(var/i = 1; i <= meat_qty; i++)
		var/obj/items/M = new(location)
		M.name = "[animal.species_type] meat"
		M.icon_state = "meat"
		products += M
	
	for(var/i = 1; i <= hide_qty; i++)
		var/obj/items/H = new(location)
		H.name = "[animal.species_type] hide"
		H.icon_state = "hide"
		products += H
	
	world << "<span class='warning'>[animal.animal_name] has been slaughtered!</span>"
	
	DeleteAnimal(animal.animal_id)
	return products

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeAnimalOwnership()
 * Load animal registry from savefiles on startup
 * Called from InitializationManager.dm
 */
proc/InitializeAnimalOwnership()
	// Animals are stored as savefile data associated with players
	// Loaded when player logs in via LoadPlayerAnimals(ckey)
	global_animal_registry = list()
	global_player_animals = list()
	animal_id_counter = 0

/**
 * LoadPlayerAnimals(ckey)
 * Load animals owned by player from savefile
 * Called after player character loads
 * 
 * @param ckey: Player character key
 */
proc/LoadPlayerAnimals(ckey)
	var/path = "MapSaves/Animals_[ckey].sav"
	
	if(!fexists(path))
		return  // No saved animals
	
	var/savefile/S = new(path)
	if(!S)
		return
	
	// Read animal registry for this player
	S["animals"] >> global_player_animals[ckey]

/**
 * SavePlayerAnimals(ckey)
 * Save player's animals to savefile
 * Called on player logout or periodically
 * 
 * @param ckey: Player character key
 */
proc/SavePlayerAnimals(ckey)
	var/path = "MapSaves/Animals_[ckey].sav"
	var/savefile/S = new(path)
	
	if(!S) return
	
	S["animals"] << global_player_animals[ckey]
