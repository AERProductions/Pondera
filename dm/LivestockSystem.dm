/**
 * LivestockSystem.dm - Animal husbandry with breeding and production
 * 
 * Features:
 * - Three animal types: Cow, Chicken, Sheep
 * - Feeding mechanics (consumes crops, affects happiness)
 * - Breeding cycles (seasonal, temperature-dependent)
 * - Production systems (milk, eggs, wool)
 * - Happiness/health tracking
 * - Slaughter mechanics (meat, hides, bones)
 * - Integration with food/soil/season systems
 * 
 * Animal Lifecycle:
 * - Birth → Maturation (varies by species) → Reproduction → Aging → Death
 * - Food requirements daily
 * - Happiness affects production quality
 * - Breeding season depends on global.season
 * 
 * Integration: ConsumptionManager (food values), CharacterData (player), time.dm (calendar)
 */

// ============================================================================
// ANIMAL OBJECT HIERARCHY
// ============================================================================

/obj/animal
	// icon = 'dmi/64/animals.dmi'  // TODO: Create animal icons
	density = FALSE
	layer = TURF_LAYER + 1
	
	var/animal_type           // "cow", "chicken", "sheep"
	var/age                   // Days old (tracked to calendar)
	var/age_ticks             // Raw tick counter for aging
	var/age_stage             // "newborn", "young", "adult", "old"
	var/max_age               // Species-specific lifespan in days
	var/happiness             // 0-100 (fed, housed, company)
	var/hunger_level          // 0-100 (100=fed, 0=starving)
	var/hunger_ticks          // Tick counter for hunger depletion
	var/production_level      // 0-100 (readiness to produce)
	var/last_produced         // Timestamp of last production
	var/last_fed              // Timestamp of last feeding
	var/breeding_cooldown     // Ticks until can breed again
	var/pregnant              // Gestation period in ticks
	var/production_time       // Ticks between production cycles
	var/owner                 // Player who owns/placed animal
	var/mother                // Parent animal (for inheritance)

/obj/animal/New(location, type)
	..()
	animal_type = type || "cow"
	InitializeAnimal()
	StartLifecycle()

/obj/animal/proc/InitializeAnimal()
	/**
	 * Set species-specific values
	 */
	
	switch(animal_type)
		if("cow")
			icon_state = "cow_adult"
			max_age = 1825  // 5 years in days
			production_time = 2400  // Once per day
			happiness = 50
			hunger_level = 75
		
		if("chicken")
			icon_state = "chicken_adult"
			max_age = 730  // 2 years
			production_time = 1200  // Twice per day
			happiness = 40
			hunger_level = 60
		
		if("sheep")
			icon_state = "sheep_adult"
			max_age = 1460  // 4 years
			production_time = 3000  // Once per 1.25 days
			happiness = 55
			hunger_level = 70
	
	age = 0
	age_ticks = 0
	age_stage = "adult"
	last_fed = world.timeofday
	last_produced = world.timeofday
	breeding_cooldown = 0
	pregnant = 0
	production_level = 0

/obj/animal/proc/StartLifecycle()
	/**
	 * Begin aging, hunger, and production loops
	 */
	
	set background = 1
	set waitfor = 0
	
	while(src)
		// Hunger depletion (once per 25 ticks = roughly 2.5x per day)
		hunger_level = max(0, hunger_level - 1)
		hunger_ticks++
		
		// Check starvation
		if(hunger_level <= 0)
			DieOfStarvation()
			return
		
		// Production tick
		production_level = min(100, production_level + 1)
		
		// Age tick (every 3000 ticks = 1 day at 40 TPS)
		age_ticks++
		if(age_ticks >= 3000)
			age++
			age_ticks = 0
			UpdateAgeStage()
		
		// Breeding cooldown
		if(breeding_cooldown > 0)
			breeding_cooldown--
		
		// Pregnancy timer
		if(pregnant > 0)
			pregnant--
			if(pregnant <= 0)
				GiveBirth()
		
		// Happiness decay (once per 100 ticks if not fed)
		if(world.timeofday - last_fed > 2400)  // 4+ hours without food
			happiness = max(0, happiness - 1)
		
		sleep(5)

/obj/animal/proc/UpdateAgeStage()
	/**
	 * Update icon and behavior based on age
	 */
	
	switch(animal_type)
		if("cow")
			if(age < 60)
				age_stage = "newborn"
				icon_state = "calf"
			else if(age < 365)
				age_stage = "young"
				icon_state = "cow_young"
			else if(age < 1460)
				age_stage = "adult"
				icon_state = "cow_adult"
			else
				age_stage = "old"
				icon_state = "cow_old"
		
		if("chicken")
			if(age < 15)
				age_stage = "newborn"
				icon_state = "chick"
			else if(age < 60)
				age_stage = "young"
				icon_state = "chicken_young"
			else if(age < 600)
				age_stage = "adult"
				icon_state = "chicken_adult"
			else
				age_stage = "old"
				icon_state = "chicken_old"
		
		if("sheep")
			if(age < 45)
				age_stage = "newborn"
				icon_state = "lamb"
			else if(age < 200)
				age_stage = "young"
				icon_state = "sheep_young"
			else if(age < 1200)
				age_stage = "adult"
				icon_state = "sheep_adult"
			else
				age_stage = "old"
				icon_state = "sheep_old"

// ============================================================================
// FEEDING & PRODUCTION
// ============================================================================

/obj/animal/verb/feed()
	set name = "Feed"
	set category = "Animal"
	set src in oview(1)
	
	FeedAnimal(src, usr)

/proc/FeedAnimal(obj/animal/A, mob/players/feeder)
	/**
	 * Player feeds animal
	 * - Select food from inventory
	 * - Consume item
	 * - Restore hunger
	 * - Increase happiness
	 * - Food preference affects happiness bonus
	 */
	
	if(!A || !feeder)
		return
	
	// Get list of food in player inventory
	var/list/foods = list()
	for(var/obj/items/I in feeder.contents)
		if(global.CONSUMABLES && I.name in global.CONSUMABLES)
			foods += I
	
	if(foods.len == 0)
		feeder << "You have no food to feed the [A.animal_type]."
		return
	
	var/obj/items/selected_food = input(feeder, "Select food:", "Feed") in foods
	
	if(!selected_food)
		return
	
	// Get food values
	var/food_data = global.CONSUMABLES[selected_food.name]
	if(!food_data)
		feeder << "Cannot feed [selected_food.name] to animal."
		return
	
	var/nutrition_value = food_data[2] || 10  // Default 10
	var/hunger_restore = nutrition_value * 0.8
	
	// Check if food is preferred by animal
	var/happiness_bonus = 5
	var/list/preferred = GetPreferredFood(A.animal_type)
	if(findtext(selected_food.name, preferred[1], 1))
		happiness_bonus = 10  // Double happiness for preferred food
	
	// Apply effects
	A.hunger_level = min(100, A.hunger_level + hunger_restore)
	A.happiness = min(100, A.happiness + happiness_bonus)
	A.last_fed = world.timeofday
	
	// Remove food
	del(selected_food)
	
	feeder << "<span style='color: #00AA00'>The [A.animal_type] eats happily!</span>"

/proc/GetPreferredFood(var/animal_type)
	/**
	 * Return preferred food types and happiness multiplier
	 */
	
	switch(animal_type)
		if("cow")
			return list("grain", "hay")  // 2x happiness
		if("chicken")
			return list("seed", "grain")
		if("sheep")
			return list("clover", "hay")
	
	return list("generic", "food")

/obj/animal/proc/ProduceProduct()
	/**
	 * Generate milk/eggs/wool based on stats
	 * Quality affected by: happiness (0.5-1.5x), hunger (0.7-1.2x), season
	 */
	
	if(production_level < 100 || hunger_level < 30 || happiness < 30)
		return  // Not ready
	
	var/quality = 1.0
	quality *= (0.5 + (happiness / 100 * 1.0))  // 0.5-1.5x from happiness
	quality *= (0.7 + (hunger_level / 100 * 0.5))  // 0.7-1.2x from nutrition
	
	// Season bonus
	switch(global.season)
		if("Spring", "Summer")
			quality *= 1.2
		if("Autumn")
			quality *= 1.1
		else
			quality *= 0.9  // Winter penalty
	
	var/product_name = ""
	
	switch(animal_type)
		if("cow")
			product_name = "milk"
		if("chicken")
			product_name = "egg"
		if("sheep")
			product_name = "wool"
	
	if(product_name)
		// Create a basic crafting item
		new /obj/items/Crafting(loc)
		production_level = 0
		last_produced = world.timeofday

// ============================================================================
// BREEDING SYSTEM
// ============================================================================

/obj/animal/verb/breed()
	set name = "Breed"
	set category = "Animal"
	set src in oview(3)
	
	BreedAnimal(src, usr)

/proc/BreedAnimal(obj/animal/A, mob/players/breeder)
	/**
	 * Initiate breeding with nearby compatible animal
	 * Requirements:
	 * - 2+ animals in range
	 * - Both happiness > 60
	 * - Both hunger > 50
	 * - Season-dependent success rate
	 * - Gestation period varies by species
	 */
	
	if(!A || !breeder)
		return
	
	if(A.breeding_cooldown > 0)
		breeder << "This [A.animal_type] is not ready to breed."
		return
	
	if(A.happiness < 60)
		breeder << "Animal is too unhappy to breed."
		return
	
	if(A.hunger_level < 50)
		breeder << "Animal is too hungry to breed."
		return
	
	// Find compatible nearby animal
	var/obj/animal/partner = null
	for(var/obj/animal/nearby in range(3, A))
		if(nearby.animal_type == A.animal_type && nearby != A)
			if(nearby.happiness > 60 && nearby.hunger_level > 50)
				partner = nearby
				break
	
	if(!partner)
		breeder << "No compatible partner found nearby."
		return
	
	// Season-dependent success rate
	var/success_rate = 50  // Default 50%
	
	switch(global.season)
		if("Spring")
			success_rate = 80
		if("Summer")
			success_rate = 70
		if("Autumn")
			success_rate = 50
		else
			success_rate = 20  // Winter
	
	if(rand(1, 100) > success_rate)
		breeder << "Breeding unsuccessful."
		A.breeding_cooldown = 1000
		return
	
	// Breeding successful - initiate pregnancy
	A.pregnant = GetGestationTime(A.animal_type)
	A.breeding_cooldown = 5000  // Long cooldown before next breeding
	partner.breeding_cooldown = 5000
	
	breeder << "<span style='color: #00AA00'>Breeding successful! The [A.animal_type] will give birth soon.</span>"

/proc/GetGestationTime(var/animal_type)
	/**
	 * Return gestation period in ticks (at 40 TPS)
	 * Cow: 15 days = 18000 ticks
	 * Chicken: 5 days = 6000 ticks
	 * Sheep: 12 days = 14400 ticks
	 */
	
	switch(animal_type)
		if("cow")
			return 18000  // 15 days
		if("chicken")
			return 6000   // 5 days
		if("sheep")
			return 14400  // 12 days
	
	return 10000  // Default

/obj/animal/proc/GiveBirth()
	/**
	 * Create offspring with inherited traits
	 */
	
	var/offspring_type = animal_type
	
	// Create offspring
	var/obj/animal/offspring = new /obj/animal(loc, offspring_type)
	offspring.age = 0
	offspring.happiness = (happiness + 50) / 2  // Average with baseline
	offspring.mother = src
	
	world << "<span style='color: #00FFFF'>A new [animal_type] has been born!</span>"

/obj/animal/proc/DieOfStarvation()
	/**
	 * Animal dies from lack of food
	 * Can be harvested for meat/bones
	 */
	
	world << "[src] has starved to death."
	
	// Leave corpse (can be looted)
	var/obj/items/meat = new /obj/items/Crafting()
	meat.name = "[animal_type] meat"
	meat.Move(loc)
	
	del(src)

// ============================================================================
// SLAUGHTER MECHANICS
// ============================================================================

/obj/animal/verb/slaughter()
	set name = "Slaughter"
	set category = "Animal"
	set src in oview(1)
	
	SlaughterAnimal(src, usr)

/proc/SlaughterAnimal(obj/animal/A, mob/players/slaughterer)
	/**
	 * Kill animal and return products
	 * Products: meat (food), hide (crafting), bones (compost)
	 */
	
	if(!A || !slaughterer)
		return
	
	// Create products
	var/obj/items/meat = new /obj/items/Crafting()
	meat.name = "[A.animal_type] meat"
	meat.Move(A.loc)
	
	var/obj/items/hide = new /obj/items/Crafting()
	hide.name = "[A.animal_type] hide"
	hide.Move(A.loc)
	
	var/obj/items/bones = new /obj/items/Crafting()
	bones.name = "[A.animal_type] bones"
	bones.Move(A.loc)
	
	slaughterer << "<span style='color: #FF6600'>You slaughter the [A.animal_type]. Meat, hide, and bones obtained.</span>"
	world << "[slaughterer] has slaughtered a [A.animal_type]."
	
	del(A)

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/proc/SpawnLivestock(var/location, var/animal_type)
	/**
	 * Create new animal at location
	 * Called by: BuildingMenuUI when placing livestock enclosure
	 */
	
	if(!location)
		return null
	
	var/obj/animal/A = new /obj/animal(location, animal_type)
	return A

/proc/GetAnimalStatus(obj/animal/A)
	/**
	 * Return formatted status string for animal
	 */
	
	if(!A)
		return "No animal"
	
	var/status = "<b>[A.animal_type]</b><br>"
	status += "Age: [A.age] days ([A.age_stage])<br>"
	status += "Happiness: [A.happiness]/100<br>"
	status += "Hunger: [A.hunger_level]/100<br>"
	status += "Production: [A.production_level]/100<br>"
	
	if(A.pregnant > 0)
		status += "<span style='color: #FF00FF'>PREGNANT ([A.pregnant] ticks remaining)</span><br>"
	
	return status

/obj/animal/Click()
	/**
	 * Right-click animal to see status
	 */
	
	var/mob/M = usr
	if(!M || !istype(M, /mob))
		return
	
	M << GetAnimalStatus(src)
	M << " "
	M << "Actions: (Feed) (Breed) (Slaughter)"
