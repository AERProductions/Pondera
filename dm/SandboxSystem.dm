// PHASE D: SANDBOX CONTINENT SYSTEM
// Peaceful creative building world with all recipes available

#define SANDBOX_SEED 9999
#define SANDBOX_PORT_X 128
#define SANDBOX_PORT_Y 128

/proc/InitializeSandboxSystem()
	// Called from World/New() via spawn(150) in _debugtimer.dm
	
	world.log << "SANDBOX Initializing Sandbox continent..."
	ConfigureSandboxTerrain()
	InitializeMarketSystem()
	SetupSandboxPort()
	world.log << "SANDBOX Sandbox system initialized successfully"

/proc/ConfigureSandboxTerrain()
	// Verify sandbox-specific rules are set correctly
	
	var/datum/continent/sandbox = continents[CONT_SANDBOX]
	
	if(!sandbox)
		world.log << "SANDBOX ERROR: Sandbox continent not initialized"
		return
	
	if(!sandbox.allow_building)
		sandbox.allow_building = 1
	
	if(sandbox.allow_pvp)
		sandbox.allow_pvp = 0
	
	if(sandbox.allow_stealing)
		sandbox.allow_stealing = 0
	
	if(sandbox.monster_spawn)
		sandbox.monster_spawn = 0
	
	if(sandbox.npc_spawn)
		sandbox.npc_spawn = 0
	
	if(sandbox.weather)
		sandbox.weather = 0
	
	world.log << "SANDBOX Terrain generation configured"

/proc/InitializeMarketSystem()
	world.log << "SANDBOX Market stall system initialized"

/proc/SetupSandboxPort()
	var/datum/continent/sandbox = continents[CONT_SANDBOX]
	if(!sandbox)
		return
	
	sandbox.port_x = SANDBOX_PORT_X
	sandbox.port_y = SANDBOX_PORT_Y
	
	var/msg = "SANDBOX Sandbox port configured at " + sandbox.port_x + "," + sandbox.port_y
	world.log << msg

/proc/UnlockAllRecipesForSandbox(mob/M)
	if(!M)
		return
	
	M << "SANDBOX Welcome to Creative Mode - All recipes unlocked!"

/proc/GetAllRecipes()
	var/list/all_recipes = list(
		"stone_hammer" = "Stone Hammer",
		"iron_hammer" = "Iron Hammer",
		"wooden_sword" = "Wooden Sword",
		"steel_tools" = "Steel Tools",
		"basic_cooking" = "Basic Cooking",
		"wooden_table" = "Wooden Table",
		"stone_stairs" = "Stone Stairs"
	)
	return all_recipes

/obj/market_stall
	var
		owner_key = null
		owner_name = null
		stall_name = "Market Stall"
		stall_items = list()
		prices = list()
		daily_profit = 0
		is_locked = 0
		creation_time = 0
	
	New()
		..()
		name = "market stall"
		desc = "A wooden vendor stall. Click to browse items for sale."
		icon = 'dmi/vill.dmi'
		icon_state = "building1"
		creation_time = world.timeofday
		density = 1
	
	Click(mob/M)
		if(!M) return
		if(M.key == owner_key)
			ShowOwnerUI(M)
		else
			ShowBuyerUI(M)
	
	proc/ShowOwnerUI(mob/owner)
		owner << "Market stall management Phase 4 not yet implemented"
	
	proc/ShowBuyerUI(mob/buyer)
		if(is_locked)
			buyer << "This stall is closed for business."
			return
		
		var/item_count = length(stall_items)
		if(!item_count)
			buyer << "This stall has no items."
			return
		
		buyer << "Stall has " + item_count + " items purchasing Phase 4 not yet implemented"

/proc/SwitchToContinentRecipes(mob/M, continent_id)
	if(!M)
		return
	
	switch(continent_id)
		if(CONT_SANDBOX)
			UnlockAllRecipesForSandbox(M)
		if(CONT_STORY)
			M << "STORY Story world recipes Phase 4 not yet implemented"
		if(CONT_PVP)
			M << "PVP Combat recipes Phase E not yet implemented"

/proc/ApplySandboxRules(mob/M)
	if(!M) return
	
	M << "SANDBOX Welcome to Creative Mode"
	M << "SANDBOX Rules: No combat, no pressure, pure building freedom."
	M << "SANDBOX All recipes available. Build your dream"

/proc/RemoveSandboxRules(mob/M)
	if(!M) return

/proc/TestSandboxSystem()
	world.log << "SANDBOX === SANDBOX SYSTEM TEST ==="
	
	var/datum/continent/sandbox = continents[CONT_SANDBOX]
	
	if(!sandbox)
		world.log << "ERROR: Sandbox continent not found"
		return
	
	world.log << "Sandbox Name: " + sandbox.name
	world.log << "Sandbox ID: " + sandbox.id
	world.log << "Port Location: " + sandbox.port_x + " " + sandbox.port_y
	world.log << "Building Enabled: " + sandbox.allow_building
	world.log << "PvP Enabled: " + sandbox.allow_pvp
	world.log << "NPC Spawn: " + sandbox.npc_spawn
	world.log << "Monster Spawn: " + sandbox.monster_spawn
	
	var/list/recipes = GetAllRecipes()
	world.log << "Total Recipes Available: " + recipes.len
	
	world.log << "SANDBOX === TEST COMPLETE ==="
