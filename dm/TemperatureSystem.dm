// TemperatureSystem.dm
// Centralized thermal management for forge/anvil/smelting mechanics
// Replaces scattered Tname variables and separate Temp/STemp procs with unified state machine
// Realistic temperature progression: Hot → Warm → Cool with customizable cooling rates

// Temperature stage constants
#define TEMP_COOL 0            // Ready to quench or combine
#define TEMP_WARM 1            // Cooling down, workable
#define TEMP_HOT 2             // Fresh from forge, optimal working window

// Temperature tracking (in game ticks)
#define TEMP_HOT_DURATION 240     // Time spent at Hot stage (12 seconds at 20 ticks/sec)
#define TEMP_WARM_DURATION 120    // Time spent at Warm stage (6 seconds)
#define TEMP_COOL_THRESHOLD 360   // Total time to reach Cool (18 seconds)

// Thermally-aware item base class
obj/items/thermable
	var
		temperature_stage = TEMP_HOT    // Current thermal state
		heat_timestamp = 0               // When item was last heated
		thermal_class = "standard"       // Metal type (affects cooling rate)
		
	// Get current temperature name
	proc/GetTemperatureName()
		switch(temperature_stage)
			if(TEMP_HOT)
				return "Hot"
			if(TEMP_WARM)
				return "Warm"
			if(TEMP_COOL)
				return "Cool"
		return "Unknown"

	// Get temperature color (for display)
	proc/GetTemperatureColor()
		switch(temperature_stage)
			if(TEMP_HOT)
				return "#FF4500"    // Orange-red
			if(TEMP_WARM)
				return "#FFD700"    // Gold
			if(TEMP_COOL)
				return "#696969"    // Dark gray
		return "#FFFFFF"

	// Get cooling rate multiplier based on metal type
	proc/GetCoolingRate()
		switch(thermal_class)
			if("iron")
				return 1.0
			if("steel")
				return 0.9     // Steel cools slightly faster
			if("copper")
				return 1.1     // Copper cools slightly slower
			if("brass")
				return 1.05
			if("bronze")
				return 1.05
			if("zinc")
				return 1.2     // Zinc cools fast
			if("lead")
				return 0.95
		return 1.0

	// Heat the item to Hot state
	proc/Heat()
		if(temperature_stage == TEMP_HOT)
			return FALSE  // Already hot
		
		temperature_stage = TEMP_HOT
		heat_timestamp = world.time
		UpdateDisplay()
		return TRUE

	// Check if item is hot enough for work (accepts Hot or Warm)
	proc/IsWorkable()
		if(temperature_stage == TEMP_COOL)
			return FALSE
		return TRUE

	// Check if item is hot enough for quenching (requires Hot stage)
	proc/IsQuenchable()
		if(temperature_stage != TEMP_HOT)
			return FALSE
		return TRUE

	// Update display name/description based on temperature
	proc/UpdateDisplay()
		name = "[initial(name)] ([GetTemperatureName()])"
		suffix = "<font color='[GetTemperatureColor()]'>[GetTemperatureName()]</font>"

	// Start cooling timer (background process)
	proc/StartCooling()
		if(temperature_stage == TEMP_COOL)
			return  // Already cool
		
		spawn while(src)
			// Calculate actual cooling duration based on metal type
			var/cooling_rate = GetCoolingRate()
			
			// Hot → Warm phase
			sleep(round(TEMP_HOT_DURATION / cooling_rate))
			if(src && temperature_stage == TEMP_HOT)
				temperature_stage = TEMP_WARM
				UpdateDisplay()
			
			// Warm → Cool phase
			sleep(round(TEMP_WARM_DURATION / cooling_rate))
			if(src && temperature_stage == TEMP_WARM)
				temperature_stage = TEMP_COOL
				UpdateDisplay()
			
			return

// NOTE: obj/items/Ingots and obj/items/Ingots/Scraps are defined in mining.dm
// These systems extend them with temperature tracking via parent_type
// The ingot classes should use parent_type = /obj/items/thermable in mining.dm

// Forge/Anvil smithing interface
obj/Buildable/Smithing
	var
		forge_temperature = TEMP_COOL  // Ambient forge temperature
		forge_active = FALSE             // Is forge lit?

	// Heat an item in the forge
	proc/HeatItem(obj/items/thermable/item, mob/players/M)
		if(!forge_active)
			M << "The forge is not lit."
			return FALSE
		
		if(item.temperature_stage == TEMP_HOT)
			M << "This item is already hot!"
			return FALSE
		
		M << "You place [item] into the forge to heat..."
		sleep(30)  // Heating takes 1.5 seconds
		
		item.Heat()
		M << "[item] is now hot and ready for smithing!"
		item.StartCooling()
		
		return TRUE

	// Check if item can be worked on
	proc/CanWork(obj/items/thermable/item, mob/players/M)
		if(!item.IsWorkable())
			M << "[item] is too cold to work with. Heat it first."
			return FALSE
		return TRUE

	// Check if item can be quenched
	proc/CanQuench(obj/items/thermable/item, mob/players/M)
		if(!item.IsQuenchable())
			if(item.temperature_stage == TEMP_WARM)
				M << "[item] is cooling down. It needs to be hotter to quench properly."
			else
				M << "[item] is too cold to quench."
			return FALSE
		return TRUE

// Quenching system (water cooling)
obj/Buildable/WaterTrough
	// Quench a hot item in water
	proc/QuenchItem(obj/items/thermable/item, mob/players/M)
		if(!item.IsQuenchable())
			M << "[item] isn't hot enough to quench properly."
			return FALSE
		
		if(item.temperature_stage == TEMP_WARM)
			// Partial quench - item cools to cold but needs re-working
			M << "You submerge the [item] into the water."
			item.temperature_stage = TEMP_COOL
			item.UpdateDisplay()
			sleep(3)
			M << "[item] has cooled, but could use more heat-working."
			return FALSE
		
		// Proper hot quench - item is ready
		M << "You submerge the [item] into the water with a hiss of steam!"
		item.temperature_stage = TEMP_COOL
		item.UpdateDisplay()
		sleep(3)
		M << "[item] has been properly quenched! Ready for refinement."
		return TRUE

// Mob temperature interface
mob/players
	// Get list of workable items at forge
	proc/GetWorkableItems()
		var/list/workable = list()
		for(var/obj/items/thermable/item in contents)
			if(item.IsWorkable())
				workable += item
		return workable

	// Get list of quenchable items
	proc/GetQuenchableItems()
		var/list/quenchable = list()
		for(var/obj/items/thermable/item in contents)
			if(item.IsQuenchable())
				quenchable += item
		return quenchable

	// Check if can start smithing (has hot item)
	proc/CanSmith()
		var/list/workable = GetWorkableItems()
		if(!workable.len)
			return FALSE
		return TRUE

	// Get temperature status of all items
	proc/GetTemperatureStatus()
		var/output = "<b>Item Temperatures:</b><br>"
		var/has_items = FALSE
		
		for(var/obj/items/thermable/item in contents)
			has_items = TRUE
			var/temp_name = item.GetTemperatureName()
			var/temp_color = item.GetTemperatureColor()
			output += "[item.name]: <font color='[temp_color]'>[temp_name]</font><br>"
		
		if(!has_items)
			output += "No items to display."
		
		return output

// Forging helper procs (replaces scattered Temp/STemp)
proc/CoolItem(obj/items/thermable/item)
	// Alternative to StartCooling - allows manual cooling without spawn
	if(item.temperature_stage == TEMP_HOT)
		item.temperature_stage = TEMP_WARM
		item.UpdateDisplay()
		sleep(round(TEMP_HOT_DURATION / item.GetCoolingRate()))
	
	if(item.temperature_stage == TEMP_WARM)
		item.temperature_stage = TEMP_COOL
		item.UpdateDisplay()
		sleep(round(TEMP_WARM_DURATION / item.GetCoolingRate()))
