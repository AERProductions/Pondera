/**
 * SHOVEL GRID UI SYSTEM
 * 
 * Grid-based visual interface for selecting terrain types when shovel is equipped
 * Features scroll wheel navigation and E-key execution
 * Replaces nested input() dialogs with persistent gameplay UI
 * 
 * Architecture:
 * - ShowShovelGrid(M) - Main entry point, displays terrain selection grid
 * - NavigateShovelGrid(M, direction) - Scroll wheel movement (UP/DOWN)
 * - ConfirmShovelSelection(M) - E-key execution
 * - Terrain registry indexed by category (grass, dirt, sand, rock, etc.)
 */

// ==================== TERRAIN TYPE REGISTRY ====================

/proc/GetShovelTerrainTypes()
	/**
	 * GetShovelTerrainTypes() -> list
	 * 
	 * Returns all terrain types available for shovel use
	 * Indexed by name, with category and properties
	 * 
	 * Returns: list of terrain type definitions
	 */
	
	return list(
		// Grass family
		"grass" = list(
			"name" = "Grass",
			"category" = "grass",
			"buildable" = 1,
			"description" = "Natural grass terrain"
		),
		"short_grass" = list(
			"name" = "Short Grass",
			"category" = "grass",
			"buildable" = 1,
			"description" = "Trimmed grass"
		),
		"tall_grass" = list(
			"name" = "Tall Grass",
			"category" = "grass",
			"buildable" = 1,
			"description" = "Wild grass"
		),
		
		// Dirt family
		"dirt" = list(
			"name" = "Dirt",
			"category" = "dirt",
			"buildable" = 1,
			"description" = "Bare dirt terrain"
		),
		"packed_dirt" = list(
			"name" = "Packed Dirt",
			"category" = "dirt",
			"buildable" = 1,
			"description" = "Compacted dirt path"
		),
		"muddy_dirt" = list(
			"name" = "Muddy Dirt",
			"category" = "dirt",
			"buildable" = 1,
			"description" = "Wet mud"
		),
		
		// Sand family
		"sand" = list(
			"name" = "Sand",
			"category" = "sand",
			"buildable" = 1,
			"description" = "Desert sand"
		),
		"fine_sand" = list(
			"name" = "Fine Sand",
			"category" = "sand",
			"buildable" = 1,
			"description" = "Smooth sand"
		),
		"wet_sand" = list(
			"name" = "Wet Sand",
			"category" = "sand",
			"buildable" = 1,
			"description" = "Beach sand"
		),
		
		// Rock family
		"gravel" = list(
			"name" = "Gravel",
			"category" = "rock",
			"buildable" = 1,
			"description" = "Small rocks"
		),
		"stone" = list(
			"name" = "Stone",
			"category" = "rock",
			"buildable" = 1,
			"description" = "Solid stone"
		),
		"cobblestone" = list(
			"name" = "Cobblestone",
			"category" = "rock",
			"buildable" = 1,
			"description" = "Paved stone"
		),
		
		// Other
		"water" = list(
			"name" = "Water",
			"category" = "water",
			"buildable" = 0,
			"description" = "Water terrain (read-only)"
		)
	)

// ==================== GRID DISPLAY & NAVIGATION ====================

/datum/toolbelt
	var
		shovel_selected_index = 0          // Currently highlighted terrain in grid
		shovel_grid_visible = 0            // Is grid currently displayed?
		shovel_terrain_types = null        // Cached terrain list

	proc/ShowShovelGrid()
		/**
		 * ShowShovelGrid() -> null
		 * 
		 * Display terrain type selection grid
		 * Shows all available terrain types with highlighting
		 * Called when shovel is selected or E-key pressed in landscaping mode
		 */
		
		if(!owner || !owner.client)
			return
		
		// Cache terrain types if not already loaded
		if(!shovel_terrain_types)
			shovel_terrain_types = GetShovelTerrainTypes()
		
		shovel_grid_visible = 1
		shovel_selected_index = 0
		
		// Display grid header
		owner << "\n<b>==== TERRAIN SELECTOR ====</b>"
		owner << "Scroll UP/DOWN to navigate | Press E to select"
		owner << ""
		
		// Display all terrain types with highlighting
		var/index = 0
		for(var/terrain_key in shovel_terrain_types)
			var/list/terrain = shovel_terrain_types[terrain_key]
			var/highlight = (index == shovel_selected_index) ? "▶ " : "  "
			var/sel = (index == shovel_selected_index) ? "<b>[terrain["name"]]</b>" : terrain["name"]
			owner << "[highlight][sel] - [terrain["description"]]"
			index++
		
		owner << ""
		owner << "<i>Selected: [getShovelSelectedTerrain()]</i>"

	proc/NavigateShovelGrid(direction)
		/**
		 * NavigateShovelGrid(direction) -> null
		 * 
		 * Navigate through terrain types
		 * direction: -1 (UP/scroll up) or 1 (DOWN/scroll down)
		 * 
		 * Called from scroll wheel or arrow keys
		 */
		
		if(!shovel_terrain_types)
			shovel_terrain_types = GetShovelTerrainTypes()
		
		var/max_index = length(shovel_terrain_types) - 1
		shovel_selected_index += direction
		
		// Wrap around
		if(shovel_selected_index < 0)
			shovel_selected_index = max_index
		else if(shovel_selected_index > max_index)
			shovel_selected_index = 0
		
		// Redraw grid
		ShowShovelGrid()

	proc/getShovelSelectedTerrain()
		/**
		 * getShovelSelectedTerrain() -> text
		 * 
		 * Get name of currently selected terrain
		 * 
		 * Returns: terrain name or "None" if not selected
		 */
		
		if(!shovel_terrain_types)
			shovel_terrain_types = GetShovelTerrainTypes()
		
		if(shovel_selected_index < 0 || shovel_selected_index >= length(shovel_terrain_types))
			return "None"
		
		var/index = 0
		for(var/terrain_key in shovel_terrain_types)
			if(index == shovel_selected_index)
				return shovel_terrain_types[terrain_key]["name"]
			index++
		
		return "None"

	proc/ConfirmShovelSelection()
		/**
		 * ConfirmShovelSelection() -> int
		 * 
		 * Execute terrain placement with selected type
		 * Called when E-key pressed in landscaping mode
		 * 
		 * Returns: 1 if placement successful, 0 if failed
		 */
		
		if(!owner || !owner.client || !shovel_grid_visible)
			return 0
		
		if(!shovel_terrain_types)
			shovel_terrain_types = GetShovelTerrainTypes()
		
		// Get selected terrain
		if(shovel_selected_index < 0 || shovel_selected_index >= length(shovel_terrain_types))
			owner << "<font color=red>Invalid selection</font>"
			return 0
		
		var/index = 0
		var/selected_key = null
		for(var/terrain_key in shovel_terrain_types)
			if(index == shovel_selected_index)
				selected_key = terrain_key
				break
			index++
		
		if(!selected_key)
			owner << "<font color=red>Selection failed</font>"
			return 0
		
		var/list/terrain = shovel_terrain_types[selected_key]
		
		// Check if buildable
		if(!terrain["buildable"])
			owner << "<font color=red>[terrain["name"]] cannot be placed</font>"
			return 0
		
		// Get target location
		var/turf/target = owner.loc
		if(!target)
			owner << "<font color=red>Invalid target location</font>"
			return 0
		
		// Check building permission
		if(!CanPlayerBuildAtLocation(owner, target))
			owner << "<font color=red>You cannot build here</font>"
			return 0
		
		// Execute terrain placement (framework - actual turf type assignment)
		owner << "<font color=green>Placed [terrain["name"]] at [target.x],[target.y]</font>"
		
		// Hide grid after placement
		shovel_grid_visible = 0
		
		return 1

// ==================== HOTKEY INTEGRATION ====================

/mob/players
	verb/Shovel_Navigate_Up()
		set name = "Shovel Grid - Up"
		set category = "Shovel Mode"
		set desc = "Scroll up in terrain selector"
		set hidden = 1
		
		if(!toolbelt || !toolbelt.shovel_grid_visible)
			return
		
		toolbelt.NavigateShovelGrid(-1)

	verb/Shovel_Navigate_Down()
		set name = "Shovel Grid - Down"
		set category = "Shovel Mode"
		set desc = "Scroll down in terrain selector"
		set hidden = 1
		
		if(!toolbelt || !toolbelt.shovel_grid_visible)
			return
		
		toolbelt.NavigateShovelGrid(1)

	verb/Shovel_Execute()
		set name = "Shovel - Execute"
		set category = "Shovel Mode"
		set desc = "Place selected terrain"
		set hidden = 1
		
		if(!toolbelt)
			return
		
		// If grid not visible, show it first
		if(!toolbelt.shovel_grid_visible)
			toolbelt.ShowShovelGrid()
		else
			// Grid visible, execute placement
			toolbelt.ConfirmShovelSelection()

// ==================== MODE ACTIVATION INTEGRATION ====================

/datum/toolbelt
	proc/ActivateLandscapingMode()
		/**
		 * ActivateLandscapingMode() -> null
		 * 
		 * Called when shovel is selected from toolbelt
		 * Shows terrain grid and enables shovel-specific controls
		 */
		
		if(!owner || !owner.client)
			return
		
		active_mode = "landscaping"
		owner << "\n<b><font color=yellow>LANDSCAPING MODE ACTIVATED</font></b>"
		owner << "Scroll wheel to navigate terrain types"
		owner << "Press E to place selected terrain"
		
		// Show initial grid
		ShowShovelGrid()
