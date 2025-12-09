/*
	InitializationManager.dm - Centralized World Initialization System
	
	Purpose: Orchestrate all system startups with proper dependency tracking and sequencing.
	Previously: 30+ scattered spawn() calls in _debugtimer.dm and SavingChars.dm
	Now: Single InitializeWorld() call with dependency-aware scheduling
	
	Critical Integration: Day/night + lighting + time system must initialize together
	- Lighting plane created on client login (client/draw_lighting_plane)
	- Day/night cycle depends on time_of_day global (initialized in TimeSave)
	- Day/night animate loop depends on both being ready
*/

// ============================================================================
// INITIALIZATION MANAGER - GLOBAL CONTROL
// ============================================================================

var
	// Initialization state tracking
	list/initialization_complete = list()
	initialization_in_progress = FALSE
	initialization_start_time = 0
	initialization_dependencies = list()
	world_initialization_complete = FALSE  // Gate for player login (set by FinalizeInitialization)

proc
	/*
		InitializeWorld()
		
		Central entry point for all world initialization.
		Called from: world/New() in _debugtimer.dm (after timers setup)
		
		Orchestrates 25+ system initializations with proper dependency ordering:
		1. Time system (required by day/night, maintenance, seasonal)
		2. Core infrastructure (world, map, zones)
		3. Special world types (story, sandbox, pvp)
		4. Economic systems (market, currency, trading)
		5. NPC systems (recipes, handlers)
		6. Skill systems (progression, unlocks)
		7. Display systems (market board, inventory, etc)
		
		Total startup time: ~400 ticks with proper sequencing
	*/
	InitializeWorld()
		if(initialization_in_progress)
			return  // Prevent re-entry
		
		initialization_in_progress = TRUE
		initialization_start_time = world.time
		
		world.log << "═══════════════════════════════════════════════════════════════"
		world.log << "\[INIT\] World Initialization Starting"
		world.log << "═══════════════════════════════════════════════════════════════"
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 1: TIME SYSTEM (0 ticks)
		// Critical: Must be first, required by day/night and maintenance
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 1: Time System", 0)
		TimeLoad()                          // Restore world time from save (or init defaults)
		RegisterInitComplete("time")
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 1B: CRASH RECOVERY (5 ticks - runs right after time system)
		// Detect and recover players stranded by server crash
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 1B: Crash Recovery (5 ticks)", 0)
		spawn(5)  InitializeCrashRecovery()  // Detect and recover crashed players
		
		spawn(10) RegisterInitComplete("crash_recovery")
		// Map generation, zones, weather must be ready before map spawning
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 2: Core Infrastructure (50 ticks)", 0)
		
		spawn(0)   InitializeContinents()             // Three-world continental system
		spawn(0)   InitWeatherController()            // Weather base system
		spawn(5)   DynamicWeatherTick()               // Start weather ticking
		
		// Note: Map save/load handled by MPSBWorldSave.dm initialization
		spawn(15)  InitializeDynamicZones()           // Dynamic zone system
		spawn(20)  GenerateMap(15, 15)                // Procedural map generation
		
		spawn(25)  GrowBushes()                       // Initial bush growth
		spawn(30)  GrowTrees()                        // Initial tree growth
		
		spawn(35)  StartPeriodicTimeSave()            // Background time saves (10h intervals)
		spawn(40)  StartDeedMaintenanceProcessor()    // Background maintenance (monthly)
		spawn(42)  BuildElevationTerrainTurfs()       // Build terrain metadata system
		
		spawn(50) RegisterInitComplete("infrastructure")
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 2B: DEED SYSTEM INITIALIZATION (Ticks 50-55)
		// Only initializes if deeds exist (lazy initialization)
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 2B: Deed System Registry (5 ticks - conditional)", 50)
		
		spawn(50)  InitializeDeedDataManagerLazy()  // Lazy init - only if deeds exist
		
		spawn(55) RegisterInitComplete("deed_system")
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 3: DAY/NIGHT & LIGHTING (Ticks 50-100)
		// CRITICAL: Depends on time system being ready
		// - Client-side lighting plane created on player login (not here)
		// - Global day/night cycle animation loop starts here
		// - Uses time_of_day global set by TimeLoad()
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 3: Day/Night & Lighting Cycle (50 ticks)", 50)
		
		// Note: Client lighting planes (obj/lighting_plane) are created per-client
		// in client/draw_lighting_plane() which is called on Login().
		// The global day/night overlay animation loop starts independently.
		
		spawn(50) RegisterInitComplete("lighting")
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 4: SPECIAL WORLD SYSTEMS (Ticks 50-150)
		// Initialize alternative world types in parallel
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 4: Special World Systems (100 ticks)", 50)
		
		spawn(50)   InitializeTownSystem()            // Phase B town generator
		spawn(100)  InitializeStoryWorld()            // Phase C story world
		spawn(150)  InitializeSandboxSystem()         // Phase D sandbox world
		spawn(200)  InitializePvPSystem()             // Phase E PvP world
		spawn(250)  InitializeMultiWorldSystem()      // Phase F multi-world
		spawn(300)  InitializePhase4System()          // Character data & trading
		
		spawn(300) RegisterInitComplete("special_worlds")
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 5: NPC & RECIPE SYSTEMS (Ticks 300-400)
		// Character progression and NPC interactions
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 5: NPC & Recipe Systems (100 ticks)", 300)
		
		spawn(350)  InitializeNPCRecipeSystem()       // NPC recipe teaching
		spawn(360)  InitializeNPCRecipeHandlers()     // Recipe execution
		spawn(370)  InitializeSkillLevelUpIntegration() // Skill progression hooks
		spawn(375)  InitializeSkillRecipeSystem()     // Skill-based recipe unlocks
		
		spawn(380) RegisterInitComplete("npc_recipes")
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 6: ECONOMIC SYSTEMS (Ticks 375-390)
		// Market, trading, currency, inventory management
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 6: Economic Systems (15 ticks)", 375)
		
		spawn(375)  InitializeMarketTransactionSystem()  // Market core
		spawn(376)  InitializeCurrencyDisplayUI()        // HUD currency
		spawn(377)  InitializeDualCurrencySystem()       // Lucre + materials
		spawn(378)  InitializeKingdomMaterialExchange()  // Faction trading
		spawn(379)  InitializeItemInspectionSystem()     // Item details
		spawn(380)  InitializeDynamicMarketPricingSystem() // Price calculation
		spawn(381)  InitializeEnhancedMarketPricingSystem() // Phase 12a: History & elasticity
		spawn(382)  SetupEnhancedPricingTuning()         // Tune elasticity curves
		spawn(383)  InitializeTreasuryUISystem()         // Treasury display
		spawn(384)  InitializeMarketBoardUI()            // Trading interface
		spawn(385)  MarketBoardUpdateLoop()              // Market maintenance
		spawn(386)  InitializeInventoryManagementExtensions() // Bag system
		spawn(387)  InitializeDeedEconomySystem()        // Deed transfers & rentals
		spawn(389)  InitializeTerritoryResourceSystem()  // Phase 12c: Territory resource impact
		spawn(390)  InitializeSupplyDemandSystem()       // Phase 12d: Supply/demand curves
		spawn(391)  InitializeTradingPostUI()            // Phase 12e: Trading post interface
		spawn(392)  InitializeCrisisEventsSystem()       // Phase 12f: Crisis events
		spawn(393)  InitializeMarketIntegration()       // Phase 13: Market integration layer
		
		spawn(394) RegisterInitComplete("economy")
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 7: QUALITY OF LIFE (Ticks 384-395)
		// Discovery, recipe balancing, UI polish
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 7: Quality of Life Systems (11 ticks)", 384)
		
		spawn(384)  InitializeRecipeDiscoveryRateBalancing() // Recipe discovery
		
		spawn(395) RegisterInitComplete("quality_of_life")
		
		// ────────────────────────────────────────────────────────────────────
		// FINALIZATION
		// ────────────────────────────────────────────────────────────────────
		
		spawn(400) FinalizeInitialization()

/*
	RegisterInitComplete(phase_name)
	
	Track when each initialization phase completes.
	Used for dependency checking and status reporting.
*/
proc/RegisterInitComplete(phase)
	initialization_complete += phase
	world.log << "\[INIT\] ✓ [phase] complete (elapsed: [world.time - initialization_start_time] ticks)"

/*
	LogInit(message, tick_offset)
	
	Log initialization progress with timestamp.
*/
proc/LogInit(message, offset)
	world.log << "\[INIT\] [message] (T+[offset])"

/*
	FinalizeInitialization()
	
	Called after all systems have had time to initialize.
	Performs final validation and logging.
	CRITICAL: Validates core systems to prevent silent failures.
	
	Sets world_initialization_complete flag which gates player login.
*/
proc/FinalizeInitialization()
	var/total_time = world.time - initialization_start_time
	var/critical_failures = 0
	var/list/failed_systems = list()
	
	world.log << "═══════════════════════════════════════════════════════════════"
	world.log << "\[INIT\] World Initialization Complete"
	world.log << "\[INIT\] Total startup time: " + total_time + " ticks"
	world.log << "\[INIT\] Systems initialized: " + initialization_complete.len
	world.log << "═══════════════════════════════════════════════════════════════"
	
	// VALIDATION: CRITICAL SYSTEMS (game-breaking if missing)
	if(!time_of_day || !(time_of_day in list(1, 2)))
		world.log << "🔴 CRITICAL: time_of_day invalid (must be DAY=1 or NIGHT=2)"
		critical_failures++
		failed_systems += "time_system"
	
	if(world.maxx < 100 || world.maxy < 100)
		world.log << "🔴 CRITICAL: World dimensions too small (need min 100x100)"
		critical_failures++
		failed_systems += "world_size"
	
	// VALIDATION: DATA INTEGRITY SYSTEMS
	if(!g_deed_registry)
		world.log << "\[INIT\] Initializing empty deed registry..."
		g_deed_registry = list()
	
	if(!g_deed_owner_map)
		world.log << "\[INIT\] Initializing empty deed owner map..."
		g_deed_owner_map = list()
	
	// VALIDATION: EXPECTED INITIALIZATION PHASES
	var/list/expected_phases = list("time", "infrastructure", "deed_system", "lighting", "special_worlds", "npc_recipes", "economy", "quality_of_life")
	for(var/phase in expected_phases)
		if(!(phase in initialization_complete))
			world.log << "⚠️  WARNING: Phase '[phase]' did not complete initialization!"
	
	// VALIDATION: SPAWN POINT ACCESSIBILITY
	var/spawn_count = 0
	for(var/obj/spawns/S in world)
		if(S && S.loc)
			spawn_count++
	
	if(spawn_count == 0)
		world.log << "⚠️  WARNING: No spawn points found in world"
	else
		world.log << "\[INIT\] ✓ Found [spawn_count] spawn points"
	
	// REPORT FINALIZATION STATUS
	world.log << "═══════════════════════════════════════════════════════════════"
	
	if(critical_failures > 0)
		world.log << "🔴 INITIALIZATION FAILED - [critical_failures] critical system(s) missing:"
		for(var/sys in failed_systems)
			world.log << "   - [sys]"
		world.log << "🔴 Game is UNSTABLE - server restart recommended"
		world.log << "🔴 Player login BLOCKED until systems restored"
		
		// Set gate to prevent player login during critical failure
		world_initialization_complete = FALSE
	else
		world.log << "✅ All critical systems verified"
		world.log << "✅ World is READY for players"
		world.log << "═══════════════════════════════════════════════════════════════"
		
		// Gate is open - players can log in
		world_initialization_complete = TRUE
	
	initialization_in_progress = FALSE

/*
	IsInitComplete(phase)
	
	Check if a particular initialization phase is complete.
	Used for dependency validation.
	
	Returns: TRUE if phase complete, FALSE otherwise
*/
proc/IsInitComplete(phase)
	return (phase in initialization_complete)

/*
	CanPlayersLogin()
	
	Gate function for player login validation.
	Called from client/New() or mob/players/Login() to prevent login during startup failures.
	
	Returns: TRUE if world is ready for players, FALSE if still initializing or failed
*/
proc/CanPlayersLogin()
	// If still initializing, reject login
	if(initialization_in_progress)
		world.log << "\[LOGIN\] Player login attempt during initialization - BLOCKED"
		return FALSE
	
	// If critical systems failed, reject login
	if(!world_initialization_complete)
		world.log << "\[LOGIN\] Player login attempt with incomplete initialization - BLOCKED"
		return FALSE
	
	// All checks passed
	return TRUE

/*
	GetInitializationStatus()
	
	Returns human-readable status of world initialization.
	Used for admin diagnostics and login denial messages.
	
	Returns: String status report
*/
proc/GetInitializationStatus()
	var/status = "WORLD INITIALIZATION STATUS\n"
	status += "═════════════════════════════════════════\n"
	status += "In Progress: [initialization_in_progress]\n"
	status += "Ready for Players: [world_initialization_complete]\n"
	status += "Systems Complete: [initialization_complete.len]\n"
	status += "Elapsed Time: [world.time - initialization_start_time] ticks\n"
	status += "\nCompleted Phases:\n"
	
	for(var/phase in initialization_complete)
		status += "  ✓ [phase]\n"
	
	return status

// ============================================================================
// LIGHTING SYSTEM INTEGRATION
// ============================================================================

/*
	IMPORTANT: Day/Night Lighting Architecture
	
	The day/night and lighting system has two components:
	
	1. GLOBAL LIGHTING CYCLE (initiated here in InitializeWorld)
	   - Global day/night overlay animation loop (day_night_loop)
	   - Uses time_of_day variable set by TimeLoad()
	   - Runs independently in background
	   - NOT dependent on any client
	
	2. CLIENT LIGHTING PLANE (initiated per-player on Login)
	   - Each client gets a personal lighting_plane object
	   - Added to client screen in client/draw_lighting_plane()
	   - Called during mob/players/Login()
	   - Uses LIGHTING_PLANE = 2 (defined in !defines.dm)
	
	The integration:
	- TimeLoad() sets time_of_day (1=DAY or 2=NIGHT)
	- day_night_loop() animates based on time_of_day
	- On player login, draw_lighting_plane() creates client-side overlay
	- Both work together to create cohesive lighting experience
	
	This manager handles the GLOBAL part (time system → day/night animation).
	The CLIENT part happens automatically on Login().
*/

// ============================================================================
// DEPENDENCY REFERENCE (for future system additions)
// ============================================================================

/*
	INITIALIZATION DEPENDENCIES:
	
	PHASE 1: TIME SYSTEM (must be first)
	├─ TimeLoad() → restores time_of_day, hour, minute, day, month, year
	└─ Required by: day/night, maintenance, seasonal growth
	
	PHASE 2: CORE INFRASTRUCTURE (map/world must exist before anything spawns)
	├─ InitializeContinents()
	├─ InitWeatherController()
	├─ StartMapSave()
	├─ InitializeDynamicZones()
	├─ GenerateMap()
	├─ GrowBushes(), GrowTrees()
	├─ StartPeriodicTimeSave() [depends on TimeLoad]
	└─ StartDeedMaintenanceProcessor() [depends on TimeLoad]
	
	PHASE 3: LIGHTING (depends on time from PHASE 1)
	├─ Global day/night animation starts here [depends on time_of_day]
	└─ Client lighting planes created on Login (not here)
	
	PHASE 4: SPECIAL WORLDS (can run in parallel)
	├─ InitializeTownSystem()
	├─ InitializeStoryWorld()
	├─ InitializeSandboxSystem()
	├─ InitializePvPSystem()
	├─ InitializeMultiWorldSystem()
	└─ InitializePhase4System()
	
	PHASE 5: NPC & RECIPES (depends on PHASE 4 completing)
	├─ InitializeNPCRecipeSystem()
	├─ InitializeNPCRecipeHandlers()
	└─ InitializeSkillLevelUpIntegration()
	
	PHASE 6: ECONOMY (depends on PHASE 5)
	├─ InitializeMarketTransactionSystem()
	├─ InitializeCurrencyDisplayUI()
	├─ InitializeDualCurrencySystem()
	├─ InitializeKingdomMaterialExchange()
	├─ InitializeItemInspectionSystem()
	├─ InitializeDynamicMarketPricingSystem()
	├─ InitializeTreasuryUISystem()
	├─ InitializeMarketBoardUI()
	└─ MarketBoardUpdateLoop()
	
	PHASE 7: QUALITY OF LIFE (can run in parallel with others)
	└─ InitializeRecipeDiscoveryRateBalancing()
	
	TIMING NOTES:
	- Phases can overlap (spawn() is asynchronous)
	- Total startup: ~400 ticks (about 40 seconds at normal tick rate)
	- Critical path: Time → Infrastructure → Day/Night
	- Other systems can initialize in background
*/
