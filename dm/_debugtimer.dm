proc
	TIMER_START(id, list/l)
		timers += new /DEBUG_TIMER(id, l)

	TIMER_END(id)
		for(var/DEBUG_TIMER/dt in timers)
			if(dt.id == id)
				del dt

var
	timers[]

world/New()
	..()
	timers = new
	InitializeContinents()  // Initialize three-world continental system
	InitWeatherController()
	spawn() DynamicWeatherTick()
	spawn(50) InitializeTownSystem()  // Initialize Phase B town generator (after continents)
	spawn(100) InitializeStoryWorld()  // Initialize Phase C story world integration
	spawn(150) InitializeSandboxSystem()  // Initialize Phase D sandbox continent
	spawn(200) InitializePvPSystem()  // Initialize Phase E PvP continent mechanics
	spawn(250) InitializeMultiWorldSystem()  // Initialize Phase F multi-world integration
	spawn(300) InitializePhase4System()  // Initialize Phase 4 character data & market trading
	spawn(350) InitializeNPCRecipeSystem()  // Initialize NPC recipe teaching system
	spawn(360) InitializeNPCRecipeHandlers()  // Initialize NPC recipe handlers for existing NPCs
	spawn(370) InitializeSkillLevelUpIntegration()  // Initialize skill level-up recipe hooks
	spawn(375) InitializeMarketTransactionSystem()  // Initialize market transaction & currency system
	spawn(378) InitializeCurrencyDisplayUI()  // Initialize currency display HUD
	spawn(380) InitializeInventoryManagementExtensions()  // Initialize inventory management extensions
	spawn(400) InitializeSkillRecipeSystem()  // Initialize skill-based recipe unlocks

DEBUG_TIMER
	var
		start_time
		id
		items[]

	New(txt, list/l)
		id = txt
		items = l
		start_time = world.time
		world.log << "[id] start time: [world.time]"
		sleep(-1)

	Del()
		sleep(-1)
		world.log << "[id] end: [world.time]"
		var/total_time = world.time - start_time
		world.log << "[id] total: [total_time] ticks"
		if(items)
			world.log << "[items.len] items, [total_time / items.len] ticks per item"
		..()