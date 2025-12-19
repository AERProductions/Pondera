/**
 * TORCH & LAMP HOTBAR SYSTEM (PHASE 5)
 * 
 * Equippable light sources in the toolbelt.
 * Toggle light on/off with E-key while equipped.
 * Integrates with directional lighting system for forward-facing cones.
 * 
 * Light Sources:
 * - Torches (crafted, consume durability)
 * - Hand Lamps (higher quality, better light)
 * - Lanterns (mounted, wide area light)
 * 
 * Mechanics:
 * - Light only emits when equipped in hotbar AND active
 * - E-key toggles on/off (lighting effect attaches/detaches)
 * - Automatic extinguish on unequip
 * - Visual feedback (lit vs unlit icon state)
 * - No stamina cost (torches are passive once lit)
 */

// ==================== TORCH/LAMP REGISTRY ====================

var/global/list/LIGHT_SOURCES = list(
	"wooden torch" = list(
		"name" = "Wooden Torch",
		"type" = "torch",
		"tier" = 1,
		"light_radius" = 2.5,
		"light_color" = "#FFCC00",  // Warm yellow
		"light_intensity" = 0.75,
		"cone_type" = "forward",
		"duration" = 600,  // Ticks (~60 seconds)
		"description" = "Basic wooden torch. Provides warm yellow light.",
		"icon_state" = "torch_wood"
	),
	"iron torch head" = list(
		"name" = "Iron Torch",
		"type" = "torch",
		"tier" = 2,
		"light_radius" = 3.0,
		"light_color" = "#FFD700",  // Brighter yellow
		"light_intensity" = 0.85,
		"cone_type" = "forward",
		"duration" = 800,
		"description" = "Iron torch head. Brighter and longer-lasting.",
		"icon_state" = "torch_iron"
	),
	"copper torch head" = list(
		"name" = "Copper Torch",
		"type" = "torch",
		"tier" = 2,
		"light_radius" = 2.8,
		"light_color" = "#FFA500",  // Warm orange
		"light_intensity" = 0.80,
		"cone_type" = "forward",
		"duration" = 750,
		"description" = "Copper torch head. Warm orange glow.",
		"icon_state" = "torch_copper"
	),
	"hand lamp" = list(
		"name" = "Hand Lamp",
		"type" = "lamp",
		"tier" = 3,
		"light_radius" = 3.5,
		"light_color" = "#FFFACD",  // Light yellow
		"light_intensity" = 0.95,
		"cone_type" = "forward",
		"duration" = 1200,
		"description" = "Quality hand lamp. Superior illumination.",
		"icon_state" = "lamp_hand"
	),
	"brass lamp head" = list(
		"name" = "Brass Lamp",
		"type" = "lamp",
		"tier" = 3,
		"light_radius" = 3.2,
		"light_color" = "#FFE4B5",  // Moccasin
		"light_intensity" = 0.90,
		"cone_type" = "forward",
		"duration" = 1100,
		"description" = "Brass lamp head. Elegant and bright.",
		"icon_state" = "lamp_brass"
	),
	"steel lamp head" = list(
		"name" = "Steel Lamp",
		"type" = "lamp",
		"tier" = 4,
		"light_radius" = 3.8,
		"light_color" = "#FFFFFF",  // Pure white
		"light_intensity" = 1.0,
		"cone_type" = "forward",
		"duration" = 1500,
		"description" = "Steel lamp head. Brightest and most durable.",
		"icon_state" = "lamp_steel"
	),
	"lantern" = list(
		"name" = "Lantern",
		"type" = "lantern",
		"tier" = 3,
		"light_radius" = 4.0,
		"light_color" = "#FFFACD",
		"light_intensity" = 1.0,
		"cone_type" = "wide120",  // 120-degree spread
		"duration" = 1200,
		"description" = "Portable lantern. Wide area illumination.",
		"icon_state" = "lantern_portable"
	)
)

// ==================== TORCH/LAMP ITEM OBJECT ====================

/obj/items/light_sources
	var
		lit = 0                           // 1 = actively emitting light, 0 = off
		light_source_name = ""            // Registry key for light properties
		remaining_ticks = 0               // Fuel left (ticks)
		owner_mob = null                  // Currently equipped player

	proc/GetLightProperties()
		/**
		 * GetLightProperties() -> list
		 * Returns light data from registry
		 */
		if(!light_source_name || !LIGHT_SOURCES[light_source_name])
			return null
		
		return LIGHT_SOURCES[light_source_name]

	proc/TurnOn(mob/M)
		/**
		 * TurnOn(mob/M) -> int
		 * Light the torch/lamp when equipped and E-key pressed
		 * Returns: 1 if lit, 0 if failed
		 */
		
		if(!M || !istype(M, /mob/players))
			return 0
		
		if(lit)
			return 0  // Already lit
		
		if(remaining_ticks <= 0)
			M << "<yellow>The [name] is out of fuel.</yellow>"
			return 0
		
		lit = 1
		owner_mob = M
		icon_state = "[light_source_name]_lit"
		
		var/list/props = GetLightProperties()
		if(props)
			// Attach directional light to player
			M.attach_directional_light(
				cone_type = props["cone_type"],
				hex_color = props["light_color"],
				intens = props["light_intensity"],
				rad = props["light_radius"],
				shadows = 1
			)
			
			M << "<cyan>[src] flares to life, casting [props["light_color"] == "#FFFFFF" ? "white" : "warm"] light ahead.</cyan>"
		
		return 1

	proc/TurnOff(mob/M)
		/**
		 * TurnOff(mob/M) -> int
		 * Extinguish the torch/lamp
		 * Returns: 1 if extinguished, 0 if failed
		 */
		
		if(!M || !istype(M, /mob/players))
			return 0
		
		if(!lit)
			return 0  // Already off
		
		lit = 0
		owner_mob = null
		icon_state = "[light_source_name]_unlit"
		
		M.remove_directional_light()
		M << "<cyan>[src] dims and goes dark.</cyan>"
		
		return 1

	proc/ConsumeFuel()
		/**
		 * ConsumeFuel() -> int
		 * Called every tick while lit
		 * Returns: 1 if still has fuel, 0 if fuel exhausted
		 */
		
		if(remaining_ticks <= 0)
			return 0
		
		remaining_ticks--
		
		if(remaining_ticks == 0 && owner_mob)
			TurnOff(owner_mob)
			owner_mob << "<yellow>[src] sputters and goes dark.</yellow>"
			return 0
		
		return 1


// ==================== HOTBAR INTEGRATION ====================

/**
 * DisplayTorchLampMenu(mob/M) -> null
 * 
 * Shows available torches and lamps player can equip.
 * Filtered by inventory and tier availability.
 */
/proc/DisplayTorchLampMenu(mob/players/M)
	if(!M || !M.client)
		return
	
	if(!LIGHT_SOURCES)
		LIGHT_SOURCES = list()
	
	var/list/available = list()
	
	// Scan inventory for light sources
	for(var/obj/items/light_sources/torch in M.contents)
		if(torch.light_source_name && LIGHT_SOURCES[torch.light_source_name])
			available[torch.light_source_name] = torch
	
	if(!available.len)
		M << "<red>You don't have any torches or lamps.</red>"
		return
	
	var/title = "<b><cyan>═══════════ LIGHT SOURCES ═══════════</cyan></b>"
	var/menu_text = title
	menu_text += "\n"
	
	var/list/options = list()
	var/idx = 1
	
	for(var/light_name in available)
		var/obj/items/light_sources/item = available[light_name]
		var/list/props = item.GetLightProperties()
		
		if(!props)
			continue
		
		var/fuel_status = item.remaining_ticks > 0 ? "<green>●</green>" : "<red>●</red>"
		var/status = item.lit ? "<b><yellow>LIT</yellow></b>" : "dim"
		
		menu_text += "\n[idx]. <b>[props["name"]]</b> [fuel_status] ([status])"
		menu_text += "\n   Tier [props["tier"]] | Radius [props["light_radius"]] | Fuel: [item.remaining_ticks] ticks"
		menu_text += "\n   [props["description"]]"
		
		options[idx] = light_name
		idx++
	
	menu_text += "\n<yellow>Press 0 to cancel</yellow>"
	
	M << menu_text
	
	// Prompt for selection
	var/choice = input(M, menu_text, "Select Light Source") as null|anything in options
	
	if(!choice || !(choice in options))
		return
	
	var/selected_name = options[choice]
	if(selected_name in available)
		ExecuteTorchLampAction(M, selected_name)


/**
 * ExecuteTorchLampAction(mob/M, light_name) -> int
 * 
 * Toggle light on/off for selected torch/lamp
 */
/proc/ExecuteTorchLampAction(mob/players/M, light_name)
	if(!M || !M.client || !light_name)
		return 0
	
	// Find item in inventory
	var/obj/items/light_sources/target = null
	
	for(var/obj/items/light_sources/torch in M.contents)
		if(torch.light_source_name == light_name)
			target = torch
			break
	
	if(!target)
		M << "<red>You don't have that item.</red>"
		return 0
	
	// Toggle on/off
	if(target.lit)
		target.TurnOff(M)
		return 1
	else
		target.TurnOn(M)
		return 1


/**
 * GetLightSourceMenuOptions(mob/M) -> list
 * 
 * Returns list of available light sources for hotbar display
 */
/proc/GetLightSourceMenuOptions(mob/players/M)
	if(!M)
		return list()
	
	var/list/options = list()
	
	for(var/obj/items/light_sources/torch in M.contents)
		if(torch.light_source_name && LIGHT_SOURCES[torch.light_source_name])
			var/list/props = torch.GetLightProperties()
			if(props)
				var/lit_tag = torch.lit ? "LIT" : ""
				options += torch.lit ? "[props["name"]] <yellow>[lit_tag]</yellow>" : "[props["name"]]"
	
	return options


/**
 * FuelTick() -> null
 * 
 * Background tick loop for all active light sources
 * Called from world/Tick() or similar
 */
/proc/FuelTick()
	set background = 1
	set waitfor = 0
	
	// Iterate all players
	for(var/mob/players/M in world.contents)
		if(!M.client)
			continue
		
		// Check all light sources in inventory
		for(var/obj/items/light_sources/torch in M.contents)
			if(torch.lit)
				if(!torch.ConsumeFuel())
					// Fuel exhausted, already turned off in ConsumeFuel()
					continue


// ==================== INITIALIZATION ====================

/proc/InitializeTorchLampSystem()
	/**
	 * InitializeTorchLampSystem() -> null
	 * 
	 * Called during world init to set up light source registry
	 */
	
	if(!LIGHT_SOURCES)
		LIGHT_SOURCES = list()
	
	// Populate with default entries (already done above)
	world << "<cyan>Torch & Lamp System initialized ([LIGHT_SOURCES.len] light sources)</cyan>"
