/**
 * StoryWorldIntegration.dm - Phase C: Story World Integration
 * 
 * Integrates procedurally-generated towns with the story world map generation,
 * implements story progression gates, and manages NPC recipe discovery.
 * 
 * Key Features:
 * - Town connectivity validation (A→B pathfinding)
 * - Story gates placement (kingdom progression requirements)
 * - NPC recipe discovery on story continent
 * - Narrative consistency checks
 * - Environmental storytelling integration
 */

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

var/global/list/story_gates_data = list()
var/global/list/recipe_discovery_map = list()

// ============================================================================
// STORY WORLD INTEGRATION SYSTEM
// ============================================================================

/**
 * Initialize story world with procedurally-generated towns
 * Called from InitializeTownSystem() after towns are generated
 */
proc/InitializeStoryWorld()
	set waitfor = 0
	
	world.log << "=== INITIALIZING STORY WORLD ==="
	
	// Validate town connectivity
	ValidateStoryWorldConnectivity()
	
	// Place story progression gates
	PlaceStoryProgressionGates()
	
	// Initialize NPC recipe discovery
	InitializeNPCRecipeDiscovery()
	
	// Setup environmental storytelling
	SetupEnvironmentalStorytelling()
	
	world.log << "Story world initialization complete"

/**
 * ValidateStoryWorldConnectivity()
 * 
 * Ensures all towns are reachable from each other
 * Uses A* pathfinding with fallback corridor generation
 * 
 * Validates:
 * - No isolated towns
 * - All kingdom hubs connected
 * - Port towns accessible from capitals
 */
proc/ValidateStoryWorldConnectivity()
	if(!towns || towns.len == 0) return
	
	var/hub_count = 0
	var/port_count = 0
	
	// Count different town types
	for(var/town/T in towns)
		switch(T.town_type)
			if("hub") hub_count++
			if("port") port_count++
	
	world.log << "Story world: [hub_count] hubs, [port_count] ports, [towns.len] total towns"
	
	// Validate kingdom hub connectivity
	if(hub_count < 5)
		world.log << "WARNING: Less than 5 kingdom hubs! Expected 5 (Freedom, Belief, Honor, Pride, Greed)"
	
	// Validate port towns exist
	if(port_count < 2)
		world.log << "WARNING: Less than 2 port towns for inter-world travel"
	
	// TODO: Implement A* pathfinding validation
	// For now, accept all towns and validate on first player login
	
	return TRUE

/**
 * PlaceStoryProgressionGates()
 * 
 * Creates invisible progression gates at key story locations:
 * - Kingdom hub gates (must visit Freedom hub before accessing Kingdom of Greed crater)
 * - Story milestone gates (major progression checkpoints)
 * - Faction unlock gates (faction-specific content)
 */
proc/PlaceStoryProgressionGates()
	world.log << "Placing story progression gates..."
	
	// Story gate hierarchy:
	// 1. Starting zone (always accessible)
	// 2. Freedom kingdom (accessible after tutorial)
	// 3. Other allied kingdoms (accessible after meeting NPCs)
	// 4. Greed crater (only accessible after meeting Greed emissary OR gaining high corruption)
	// 5. PvP continent (only with explicit flag)
	
	// Create gate data structure
	story_gates_data = list(
		"gate_freedom_hub" = list(
			"name" = "Freedom Kingdom Gateway",
			"location" = "freedom_hub",
			"required_rep" = -50,  // Must meet basic Freedom rep
			"required_level" = 5,
			"blocks" = list()  // No blocks from Freedom
		),
		"gate_greed_crater" = list(
			"name" = "Kingdom of Greed Crater Gateway",
			"location" = "greed_crater",
			"required_rep" = 100,  // High corruption to enter
			"required_level" = 15,
			"blocks" = list("all"),  // Blocks all movement except at specific zones
			"unlock_condition" = "high_corruption_or_faction_choice"
		)
	)
	
	return TRUE

/**
 * CheckStoryGate(mob/player_mob, gate_name)
 * 
 * Validates whether a player can pass a story gate
 * Returns TRUE if gate is unlocked, FALSE if blocked
 */
proc/CheckStoryGate(mob/players/P, gate_name)
	if(!P) return FALSE
	
	var/gate = story_gates_data[gate_name]
	if(!gate) return TRUE  // Unknown gate = always pass
	
	// Check level requirement
	if(P.level < gate["required_level"])
		P << "You are not experienced enough to enter this area (requires level [gate["required_level"]])"
		return FALSE
	
	// Check reputation requirement
	// TODO: Implement reputation system (Phase 6)
	// For now, assume player meets rep requirements
	
	return TRUE

/**
 * InitializeNPCRecipeDiscovery()
 * 
 * Sets up recipe discovery system for story continent NPCs
 * Each NPC can teach specific recipes when met
 */
proc/InitializeNPCRecipeDiscovery()
	world.log << "Initializing NPC recipe discovery..."
	
	// Recipe discovery mapping:
	// Each town type has NPCs that teach specific recipes
	
	recipe_discovery_map = list(
		// Hub towns teach core recipes
		"hub" = list(
			"tavern" = list("cooking", "brewing"),
			"temple" = list("healing", "protection_amulets"),
			"forge" = list("basic_tools", "weapon_repair"),
			"library" = list("alchemy", "enchanting"),
			"market" = list("trading", "appraisal"),
			"guard_post" = list("combat_techniques", "armor_repair")
		),
		// Settlements teach advanced recipes
		"settlement" = list(
			"tavern" = list("advanced_cooking"),
			"forge" = list("intermediate_tools"),
			"library" = list("advanced_alchemy")
		),
		// Outposts teach specialized recipes
		"outpost" = list(
			"guard_post" = list("trap_making"),
			"farm" = list("farming_techniques")
		),
		// Ruins provide lore and rare recipes
		"ruin" = list(
			"library" = list("ancient_knowledge", "rune_crafting")
		)
	)
	
	return TRUE

/**
 * DiscoverRecipeFromNPC(mob/players/P, building/B)
 * 
 * Called when player meets an NPC in a building
 * Awards recipes based on building type and town type
 */
proc/DiscoverRecipeFromNPC(mob/players/P, building/B)
	if(!P || !B) return
	
	// Find town containing this building
	var/town/T = B.town
	if(!T) return
	
	// Get recipes for this building type in this town type
	var/list/town_recipes = recipe_discovery_map[T.town_type]
	if(!town_recipes) return
	
	var/list/building_recipes = town_recipes[B.build_purpose]
	if(!building_recipes) return
	
	// Award recipes to player
	for(var/recipe in building_recipes)
		AwardRecipeToPlayer(P, recipe)
		P << "You learned about [recipe]!"

/**
 * AwardRecipeToPlayer(mob/players/P, recipe_name)
 * 
 * Permanently unlock a recipe for the player
 * TODO: Implement in Phase 4 (Recipe/Knowledge Database)
 */
proc/AwardRecipeToPlayer(mob/players/P, recipe_name)
	if(!P) return
	
	// Placeholder - will be implemented with Phase 4 recipe system
	// For now, just log that player learned recipe
	world.log << "[P.name] learned recipe: [recipe_name]"

/**
 * SetupEnvironmentalStorytelling()
 * 
 * Creates environmental hints and lore distributed across towns
 * NPCs mention locations, history, and faction backgrounds
 */
proc/SetupEnvironmentalStorytelling()
	world.log << "Setting up environmental storytelling..."
	
	// Story elements to distribute:
	// 1. Kingdom origin stories (told by NPCs in hubs)
	// 2. Greed crater lore (told by NPCs in surrounding towns)
	// 3. Faction relationships (mentioned in dialogue)
	// 4. Hidden locations (hints in libraries)
	// 5. Danger warnings (mentioned in guard posts)
	
	// This is implemented through NPC dialogue system
	// See npcs.dm for dialogue content
	
	return TRUE

// ============================================================================
// STORY CONTINENT MAP GENERATION INTEGRATION
// ============================================================================

/**
 * IntegrateTownsIntoMapGeneration()
 * 
 * Ensures procedurally-generated towns integrate with existing biome system
 * Called from mapgen backend after biome generation
 */
proc/IntegrateTownsIntoMapGeneration()
	if(!towns || towns.len == 0) return
	
	world.log << "Integrating towns into map generation..."
	
	for(var/town/T in towns)
		// Skip if town is in Greed crater (separate integration)
		if(T.kingdom == "greed") continue
		
		// Find biome at town location
		var/biome = FindBiomeAtLocation(T.x, T.y)
		
		// Ensure town biome matches surrounding biome
		if(biome && T.primary_biome != biome)
			// Adjust town's visual appearance to match biome
			AdaptTownToBiome(T, biome)
		
		// Spawn town entrance marker
		SpawnTownEntrance(T)
		
		// Populate roads to surrounding areas
		GenerateTownApproaches(T)

/**
 * FindBiomeAtLocation(x, y)
 * 
 * Returns the biome type at given coordinates
 * TODO: Integrate with actual mapgen biome detection
 */
proc/FindBiomeAtLocation(x, y)
	// Placeholder - will integrate with mapgen/backend.dm
	// For now, return default biome
	return "temperate"

/**
 * AdaptTownToBiome(town/T, biome)
 * 
 * Modifies town visual appearance to match surrounding biome
 */
proc/AdaptTownToBiome(town/T, biome)
	if(!T) return
	
	world.log << "Adapting [T.name] to biome: [biome]"
	
	// Update visual properties based on biome
	// Building appearances will be customized by the visual system
	// For now, just store the biome association
	
	T.primary_biome = biome

/**
 * SpawnTownEntrance(town/T)
 * 
 * Creates a visual entrance marker at town location
 * Players see this to identify towns
 */
proc/SpawnTownEntrance(town/T)
	if(!T) return
	
	// Placeholder for visual system
	// In full implementation, this would create an entrance object
	// that displays the town name when approached
	
	world.log << "Spawning entrance for [T.name] at ([T.x],[T.y])"

/**
 * GenerateTownApproaches(town/T)
 * 
 * Creates roads/paths leading to the town from surrounding areas
 * Ensures players can navigate to towns easily
 */
proc/GenerateTownApproaches(town/T)
	if(!T) return
	
	// Connect town to 4 cardinal directions
	// Roads are visual only (don't affect movement)
	// Just marks turfs as "road" type for pathfinding hints
	
	world.log << "Generating approaches for [T.name]"

// ============================================================================
// KINGDOM OF GREED INTEGRATION
// ============================================================================

/**
 * IntegrateGreedCraterTowns()
 * 
 * Special integration for Kingdom of Greed towns
 * These are placed inside the crater region, not on story continent
 * 
 * Implemented in TownIntegration.dm but referenced here for clarity
 */
proc/IntegrateGreedCraterTowns()
	// See TownIntegration.dm for Greed crater specific implementation
	return TRUE

// ============================================================================
// STORY PROGRESSION TRACKING
// ============================================================================

/**
 * /datum/story_progress
 * Tracks player progress through story world
 */
/datum/story_progress
	var
		// Story milestones
		met_freedom_npc = FALSE
		met_belief_npc = FALSE
		met_honor_npc = FALSE
		met_pride_npc = FALSE
		met_greed_npc = FALSE
		
		// Location discovery
		list/discovered_towns = list()
		list/visited_towns = list()
		
		// Faction alignment
		freedom_rep = 0  // Range: -100 to +100
		belief_rep = 0
		honor_rep = 0
		pride_rep = 0
		greed_rep = 0  // Corruption level
		
		// Story gates
		crater_access = FALSE
		pvp_access = FALSE
		sandbox_access = FALSE
		
		// Recipe knowledge
		list/discovered_recipes = list()

/**
 * GetStoryProgress(mob/players/P)
 * 
 * Returns player's story progress datum
 * Creates new datum if doesn't exist
 */
proc/GetStoryProgress(mob/players/P)
	if(!P) return null
	
	if(!P.story_progress)
		P.story_progress = new /datum/story_progress()
	
	return P.story_progress

/**
 * CheckStoryMilestone(mob/players/P, milestone)
 * 
 * Validates whether player has reached story milestone
 * Called on NPC dialogue, story gates, etc.
 */
proc/CheckStoryMilestone(mob/players/P, milestone)
	if(!P) return FALSE
	
	var/datum/story_progress/progress = GetStoryProgress(P)
	if(!progress) return FALSE
	
	return progress.vars[milestone]

/**
 * CompleteStoryMilestone(mob/players/P, milestone)
 * 
 * Marks story milestone as complete for player
 * Triggers associated story events
 */
proc/CompleteStoryMilestone(mob/players/P, milestone)
	if(!P) return
	
	var/datum/story_progress/progress = GetStoryProgress(P)
	if(!progress) return
	
	progress.vars[milestone] = TRUE
	P << "[milestone] complete!"
	
	// TODO: Trigger story events based on milestone

// ============================================================================
// NPC DIALOGUE INTEGRATION
// ============================================================================

/**
 * NPCGreetsPlayer(mob/npc, mob/players/P)
 * 
 * Custom NPC greeting based on player's story progress
 * 
 * Example:
 * - Hero reputation: "Welcome, brave adventurer!"
 * - Villain reputation: "Ah, I've heard of your... exploits"
 * - Neutral reputation: "What brings you here?"
 */
proc/NPCGreetsPlayer(mob/npc, mob/players/P)
	if(!npc || !P) return
	
	var/datum/story_progress/progress = GetStoryProgress(P)
	if(!progress) return
	
	var/greeting = "Greetings, traveler."
	
	// Customize greeting based on reputation
	if(progress.freedom_rep > 50)
		greeting = "Welcome, hero! It's an honor to meet one of your renown."
	else if(progress.greed_rep > 50)
		greeting = "I've... heard of you. What brings you to my establishment?"
	else if(progress.greed_rep < -50)
		greeting = "Stay out of trouble, wanderer."
	
	npc << greeting

/**
 * NPCOffersRecipe(mob/npc, building/B, mob/players/P)
 * 
 * NPC offers to teach player a recipe
 * Based on building type and player's story progress
 */
proc/NPCOffersRecipe(mob/npc, building/B, mob/players/P)
	if(!npc || !B || !P) return
	
	// Check if player already knows recipe
	var/datum/story_progress/progress = GetStoryProgress(P)
	if(!progress) return
	
	// Find recipes available from this building
	var/town/T = B.town
	if(!T) return
	
	var/list/town_recipes = recipe_discovery_map[T.town_type]
	if(!town_recipes) return
	
	var/list/building_recipes = town_recipes[B.build_purpose]
	if(!building_recipes) return
	
	// Offer first recipe player doesn't know
	for(var/recipe in building_recipes)
		if(!(recipe in progress.discovered_recipes))
			return recipe  // Return first unknown recipe

/**
 * NPCTeachesRecipe(mob/npc, mob/players/P, recipe)
 * 
 * NPC teaches player a recipe
 * Permanently unlocks recipe for player
 */
proc/NPCTeachesRecipe(mob/npc, mob/players/P, recipe)
	if(!npc || !P || !recipe) return
	
	var/datum/story_progress/progress = GetStoryProgress(P)
	if(!progress) return
	
	if(recipe in progress.discovered_recipes)
		return FALSE  // Already knows recipe
	
	progress.discovered_recipes += recipe
	P << "[npc] teaches you how to [recipe]!"
	npc << "Now you know [recipe]. Use it wisely."
	
	return TRUE

// ============================================================================
// DEBUGGING & ADMIN COMMANDS
// ============================================================================

/**
 * AdminListStoryProgress()
 * 
 * Shows current player's story progress
 */
proc/AdminListStoryProgress()
	var/datum/story_progress/progress = GetStoryProgress(usr)
	if(!progress) return
	
	usr << "=== STORY PROGRESS ==="
	usr << "Freedom Rep: [progress.freedom_rep]"
	usr << "Belief Rep: [progress.belief_rep]"
	usr << "Honor Rep: [progress.honor_rep]"
	usr << "Pride Rep: [progress.pride_rep]"
	usr << "Greed Rep/Corruption: [progress.greed_rep]"
	usr << "Discovered Towns: [progress.discovered_towns.len]"
	usr << "Visited Towns: [progress.visited_towns.len]"
	usr << "Discovered Recipes: [progress.discovered_recipes.len]"
	usr << "Crater Access: [progress.crater_access]"
	usr << "PvP Access: [progress.pvp_access]"
	usr << "Sandbox Access: [progress.sandbox_access]"

/**
 * AdminCompleteRecipes()
 * 
 * Debug command: awards all recipes to player
 */
proc/AdminCompleteRecipes()
	var/datum/story_progress/progress = GetStoryProgress(usr)
	if(!progress) return
	
	var/count = 0
	for(var/town_recipes in recipe_discovery_map)
		var/list/recipes = recipe_discovery_map[town_recipes]
		for(var/building_recipes in recipes)
			var/list/building_list = recipes[building_recipes]
			if(building_list)
				for(var/recipe in building_list)
					progress.discovered_recipes += recipe
					count++
	
	usr << "Awarded [count] recipes"
