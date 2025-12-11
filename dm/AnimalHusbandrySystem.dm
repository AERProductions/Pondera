/// ============================================================================
/// ANIMAL HUSBANDRY SYSTEM
/// System for farming animals, breeding, product collection, and care mechanics.
/// Integrated with farming ecosystem and player inventory management.
///
/// Created: 12-11-25 11:30PM
/// ============================================================================

#define ANIMAL_LIVESTOCK  "livestock"
#define ANIMAL_POULTRY    "poultry"
#define ANIMAL_AQUATIC    "aquatic"

#define ANIMAL_HEALTH_CRITICAL  0
#define ANIMAL_HEALTH_POOR      30
#define ANIMAL_HEALTH_FAIR      60
#define ANIMAL_HEALTH_GOOD      85
#define ANIMAL_HEALTH_EXCELLENT 100

/// ============================================================================
/// ANIMAL SPECIES DEFINITIONS
/// ============================================================================

/datum/animal_species
	var
		name = ""                // "Cow", "Sheep", "Chicken"
		type_category = ""       // ANIMAL_LIVESTOCK, ANIMAL_POULTRY, ANIMAL_AQUATIC
		diet = list()            // List of consumables this species eats
		gestation_ticks = 0      // Ticks until birth (0 = not breedable)
		maturity_ticks = 0       // Ticks to adult
		product = ""             // Product name (e.g., "milk", "wool", "eggs")
		product_interval = 0     // Ticks between product generation
		product_quantity = 1     // Items produced per interval
		lifespan_ticks = 0       // Ticks until death from age
		base_health = 100

/datum/animal_species/proc/GetProductName()
	return product

/datum/animal_species/proc/IsBreedable()
	return gestation_ticks > 0

/datum/animal_species/proc/CanEat(item_name)
	return item_name in diet

/// ============================================================================
/// INDIVIDUAL ANIMAL INSTANCE DATUM
/// ============================================================================

/datum/animal_instance
	var
		species_type = ""        // Reference to /datum/animal_species
		owner = null             // Player mob or deed owner
		name = ""                // Individual animal name
		age_ticks = 0            // Ticks since birth
		health = 100             // 0-100
		hunger = 0               // 0-100 (0 = full, 100 = starving)
		is_pregnant = FALSE      // Currently carrying offspring
		pregnancy_progress = 0   // 0-100% until birth
		last_fed = 0             // world.time of last feeding
		last_product = 0         // world.time of last product generation
		last_health_check = 0    // world.time of last health tick
		is_mature = FALSE        // Adult and can breed/produce
		description = ""         // Custom notes

/datum/animal_instance/proc/GetSpecies()
	// Would retrieve from global species registry
	return null

/datum/animal_instance/proc/GetAge()
	return age_ticks

/datum/animal_instance/proc/GetHealthStatus()
	if(health >= ANIMAL_HEALTH_EXCELLENT)
		return "Excellent"
	else if(health >= ANIMAL_HEALTH_GOOD)
		return "Good"
	else if(health >= ANIMAL_HEALTH_FAIR)
		return "Fair"
	else if(health >= ANIMAL_HEALTH_POOR)
		return "Poor"
	else
		return "Critical"

/datum/animal_instance/proc/GetHungerStatus()
	if(hunger >= 80)
		return "Starving"
	else if(hunger >= 60)
		return "Very Hungry"
	else if(hunger >= 40)
		return "Hungry"
	else if(hunger >= 20)
		return "Satisfied"
	else
		return "Full"

/datum/animal_instance/proc/Feed(var/food_item)
	// Reduce hunger when fed
	hunger = max(0, hunger - 25)
	last_fed = world.time
	health = min(100, health + 5)
	return TRUE

/datum/animal_instance/proc/GetDailyOutput()
	// Calculate potential product output if all conditions met
	var/datum/animal_species/species = GetSpecies()
	if(!species)
		return 0
	
	// Health and hunger affect output
	var/health_factor = health / 100.0
	var/hunger_factor = max(0, (100 - hunger) / 100.0)
	
	return round(species.product_quantity * health_factor * hunger_factor)

/datum/animal_instance/proc/GenerateProduct()
	// Called periodically to generate products (milk, eggs, wool)
	if(!is_mature)
		return FALSE
	
	if(hunger > 70)  // Too hungry to produce
		return FALSE
	
	if(health < 40)  // Too sick to produce
		return FALSE
	
	var/datum/animal_species/species = GetSpecies()
	if(!species)
		return FALSE
	
	var/output = GetDailyOutput()
	last_product = world.time
	
	// Would add to owner's inventory or deed storage
	return TRUE

/datum/animal_instance/proc/Tick()
	// Called every game tick for this animal
	age_ticks++
	hunger = min(100, hunger + 0.5)  // Hunger increases over time
	
	// Check maturity
	if(!is_mature && age_ticks >= GetSpecies().maturity_ticks)
		is_mature = TRUE
	
	// Health degradation from hunger/age
	if((world.time - last_health_check) > 50)  // Every 5 seconds
		last_health_check = world.time
		
		if(hunger > 80)
			health = max(0, health - 2)
		else if(hunger > 60)
			health = max(0, health - 1)
		
		// Age degradation
		if(age_ticks > GetSpecies().lifespan_ticks)
			health = max(0, health - 1)

/// ============================================================================
/// BREEDING & GENETICS SUBSYSTEM
/// ============================================================================

/datum/breeding_pair
	var
		male = null              // datum/animal_instance
		female = null            // datum/animal_instance
		pairing_time = 0         // world.time of pairing
		gestation_progress = 0   // 0-100%
		birth_due = 0            // world.time when birth occurs

/datum/breeding_pair/proc/Breed()
	// Initiate breeding sequence
	var/datum/animal_instance/m = male
	var/datum/animal_instance/f = female
	
	if(!m || !f)
		return FALSE
	
	if(!m.is_mature || !f.is_mature)
		return FALSE
	
	if(m.hunger > 70 || f.hunger > 70)
		return FALSE
	
	f.is_pregnant = TRUE
	pairing_time = world.time
	
	return TRUE

/datum/breeding_pair/proc/UpdateGestation()
	// Called each tick to advance pregnancy
	var/datum/animal_instance/f = female
	if(!f || !f.is_pregnant)
		return FALSE
	
	var/progress = ((world.time - pairing_time) / (birth_due - pairing_time)) * 100
	gestation_progress = min(100, progress)
	
	if(world.time >= birth_due)
		// Birth occurs
		return TriggerBirth()
	
	return TRUE

/datum/breeding_pair/proc/TriggerBirth()
	// Create newborn animal
	var/datum/animal_instance/f = female
	if(!f)
		return FALSE
	
	var/datum/animal_instance/offspring = new /datum/animal_instance()
	offspring.species_type = f.species_type
	offspring.owner = f.owner
	offspring.name = "[f.name]'s Offspring"
	offspring.age_ticks = 0
	offspring.health = 80
	offspring.hunger = 30
	offspring.is_pregnant = FALSE
	
	f.is_pregnant = FALSE
	
	return offspring

/// ============================================================================
/// ANIMAL HUSBANDRY MANAGEMENT SYSTEM
/// ============================================================================

var/datum/animal_husbandry_system/global_animal_husbandry

/proc/GetAnimalHusbandrySystem()
	if(!global_animal_husbandry)
		global_animal_husbandry = new /datum/animal_husbandry_system()
	return global_animal_husbandry

/datum/animal_husbandry_system
	var
		available_species = list()    // All available animal types
		player_animals = list()       // player → list of owned animals
		global_animals = list()       // All animals in world
		breeding_queue = list()       // Waiting breeding pairs
		product_storage = list()      // player → product inventory

/datum/animal_husbandry_system/proc/InitializeSpecies()
	// Register all available animal species
	
	var/datum/animal_species/cow = new
	cow.name = "Cow"
	cow.type_category = ANIMAL_LIVESTOCK
	cow.diet = list("grass", "grain", "hay")
	cow.gestation_ticks = 300     // 30 seconds
	cow.maturity_ticks = 600      // 60 seconds to adult
	cow.product = "milk"
	cow.product_interval = 100    // Produce every 10 seconds
	cow.product_quantity = 2
	cow.lifespan_ticks = 7200     // 12 minutes
	available_species["cow"] = cow
	
	var/datum/animal_species/sheep = new
	sheep.name = "Sheep"
	sheep.type_category = ANIMAL_LIVESTOCK
	sheep.diet = list("grass", "grain", "hay")
	sheep.gestation_ticks = 250
	sheep.maturity_ticks = 500
	sheep.product = "wool"
	sheep.product_interval = 150
	sheep.product_quantity = 1
	sheep.lifespan_ticks = 6000
	available_species["sheep"] = sheep
	
	var/datum/animal_species/chicken = new
	chicken.name = "Chicken"
	chicken.type_category = ANIMAL_POULTRY
	chicken.diet = list("grain", "seeds", "bugs")
	chicken.gestation_ticks = 100
	chicken.maturity_ticks = 200
	chicken.product = "eggs"
	chicken.product_interval = 80
	chicken.product_quantity = 1
	chicken.lifespan_ticks = 4800
	available_species["chicken"] = chicken
	
	var/datum/animal_species/fish = new
	fish.name = "Fish"
	fish.type_category = ANIMAL_AQUATIC
	fish.diet = list("plankton", "algae", "seeds")
	fish.gestation_ticks = 150
	fish.maturity_ticks = 300
	fish.product = "fish_meat"
	fish.product_interval = 120
	fish.product_quantity = 1
	fish.lifespan_ticks = 5000
	available_species["fish"] = fish

/datum/animal_husbandry_system/proc/GetAvailableSpecies()
	if(!available_species || !length(available_species))
		InitializeSpecies()
	return available_species

/datum/animal_husbandry_system/proc/AcquireAnimal(mob/player, species_name)
	// Purchase animal from vendor/spawn
	var/datum/animal_species/species = GetAvailableSpecies()[species_name]
	if(!species)
		return FALSE
	
	var/datum/animal_instance/animal = new
	animal.species_type = species_name
	animal.owner = player
	animal.name = "[species.name] #[length(player_animals[player.ckey]) + 1]"
	animal.age_ticks = 0
	animal.health = species.base_health
	animal.hunger = 30
	
	if(!(player.ckey in player_animals))
		player_animals[player.ckey] = list()
	
	player_animals[player.ckey] += animal
	global_animals += animal
	
	player << "<span style='color: #4fc3f7;'>You now own a [species.name] named [animal.name]!</span>"
	return animal

/datum/animal_husbandry_system/proc/FeedAnimal(mob/player, animal_id, food_item)
	// Feed specific animal
	var/list/animals = player_animals[player.ckey]
	if(!animals || animal_id > length(animals))
		return FALSE
	
	var/datum/animal_instance/animal = animals[animal_id]
	return animal.Feed(food_item)

/datum/animal_husbandry_system/proc/GetAnimalStatus(mob/player)
	// Display HTML status of all player animals
	var/html = "<html><head><title>Animal Husbandry</title><style>"
	html += "body { background: #0a0a0a; color: #ddd; font-family: monospace; padding: 10px; }"
	html += ".animal-card { background: #1a1a1a; border: 1px solid #444; padding: 10px; margin: 10px 0; }"
	html += ".animal-name { color: #81c784; font-weight: bold; font-size: 1.1em; }"
	html += ".stat { display: inline-block; width: 45%; margin: 5px; }"
	html += ".stat-label { color: #90caf9; }"
	html += ".progress { background: #333; height: 10px; border: 1px solid #555; margin: 3px 0; }"
	html += ".progress-bar { height: 100%; background: #4fc3f7; transition: width 0.3s; }"
	html += "</style></head><body><h2>Your Animals</h2>"
	
	var/list/animals = player_animals[player.ckey]
	if(!animals || !length(animals))
		html += "<p>You don't own any animals yet!</p>"
	else
		for(var/i = 1; i <= length(animals); i++)
			var/datum/animal_instance/animal = animals[i]
			var/datum/animal_species/species = available_species[animal.species_type]
			
			html += "<div class='animal-card'>"
			html += "<div class='animal-name'>[animal.name]</div>"
			html += "<div class='stat'><span class='stat-label'>Species:</span> [species.name]</div>"
			html += "<div class='stat'><span class='stat-label'>Age:</span> [round(animal.age_ticks/50)]s</div>"
			html += "<div class='stat'><span class='stat-label'>Health:</span> [animal.health]% ([animal.GetHealthStatus()])</div>"
			html += "<div class='progress'><div class='progress-bar' style='width: [animal.health]%;'></div></div>"
			html += "<div class='stat'><span class='stat-label'>Hunger:</span> [animal.hunger]% ([animal.GetHungerStatus()])</div>"
			html += "<div class='progress'><div class='progress-bar' style='width: [animal.hunger]%; background: #ffb74d;'></div></div>"
			
			if(animal.is_pregnant)
				html += "<div class='stat'><span class='stat-label'>Pregnancy:</span> [animal.pregnancy_progress]%</div>"
				html += "<div class='progress'><div class='progress-bar' style='width: [animal.pregnancy_progress]%; background: #ce93d8;'></div></div>"
			
			if(animal.is_mature && species.product)
				var/daily_output = animal.GetDailyOutput()
				html += "<div class='stat'><span class='stat-label'>Daily Output:</span> [daily_output] [species.product]</div>"
			
			html += "</div>"
	
	html += "</body></html>"
	return html

/datum/animal_husbandry_system/proc/BuyBreedingPair(mob/player, male_species, female_species)
	// Initiate breeding between two animals
	var/list/animals = player_animals[player.ckey]
	if(!animals || length(animals) < 2)
		return FALSE
	
	// Find animals of specified species
	var/datum/animal_instance/male = null
	var/datum/animal_instance/female = null
	
	for(var/i = 1; i <= length(animals); i++)
		if(animals[i].species_type == male_species && !male)
			male = animals[i]
		else if(animals[i].species_type == female_species && !female)
			female = animals[i]
	
	if(!male || !female)
		return FALSE
	
	var/datum/breeding_pair/pair = new
	pair.male = male
	pair.female = female
	
	if(pair.Breed())
		breeding_queue += pair
		player << "<span style='color: #ce93d8;'>[male.name] and [female.name] are now breeding!</span>"
		return TRUE
	
	return FALSE

/datum/animal_husbandry_system/proc/TickAllAnimals()
	// Called from game loop to advance all animals
	for(var/datum/animal_instance/animal in global_animals)
		animal.Tick()
	
	// Update breeding progress
	for(var/i = length(breeding_queue); i >= 1; i--)
		var/datum/breeding_pair/pair = breeding_queue[i]
		if(!pair.UpdateGestation())
			breeding_queue[i] = null

/datum/animal_husbandry_system/proc/CollectProducts(mob/player)
	// Harvest all mature animals
	var/list/animals = player_animals[player.ckey]
	var/list/collected = list()
	
	if(!animals)
		return collected
	
	for(var/datum/animal_instance/animal in animals)
		if(animal.GenerateProduct())
			var/datum/animal_species/species = available_species[animal.species_type]
			var/qty = animal.GetDailyOutput()
			
			if(!(species.product in collected))
				collected[species.product] = 0
			
			collected[species.product] += qty
	
	return collected

/// ============================================================================
/// INTEGRATION WITH INITIALIZATION
/// ============================================================================

proc/InitializeAnimalHusbandry()
	// Called from InitializationManager.dm Phase 5
	
	if(!world_initialization_complete)
		spawn(400)
			InitializeAnimalHusbandry()
		return
	
	var/datum/animal_husbandry_system/husbandry = GetAnimalHusbandrySystem()
	husbandry.InitializeSpecies()
	
	// Start background tick loop
	spawn
		while(1)
			sleep(10)  // Every 1 second
			if(husbandry)
				husbandry.TickAllAnimals()
	
	RegisterInitComplete("AnimalHusbandry")

/// ============================================================================
/// END ANIMAL HUSBANDRY SYSTEM
/// ============================================================================
