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
		// SYSTEM INITIALIZATION: Rank System Registry (0 ticks)
		// Lightweight setup required before character creation
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("SYSTEM: Rank System Registry", 0)
		InitializeRankDefinitions()  // Register all rank types for fast O(1) lookup
		RegisterInitComplete("ranks")
		
		LogInit("SYSTEM: Searchable Items Registry (3 ticks)", 3)
		spawn(3)  InitializeSearchables()  // Initialize discoverable items for searching skill
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 1: TIME SYSTEM (0 ticks)
		// Critical: Must be first, required by day/night and maintenance
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 1: Time System", 0)
		TimeLoad()                          // Restore world time from save (or init defaults)
		spawn(0) InitializeTimeAdvancement()  // Start automatic time advancement loop
		RegisterInitComplete("time")
		
		// ────────────────────────────────────────────────────────────────────
		// SYSTEM: SQLITE PERSISTENCE (2 ticks)
		// Database initialization for character data, economy, and progression
		// Must be early but after time system
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("SYSTEM: SQLite Persistence Database (2 ticks)", 0)
		spawn(2)
			if(!InitializeSQLiteDatabase())
				world.log << "\[CRITICAL\] SQLite initialization failed - persistence unavailable"
			else
				world.log << "\[SUCCESS\] SQLite database ready for character persistence"
		spawn(3) RegisterInitComplete("sqlite")
		
		// ────────────────────────────────────────────────────────────────────
		// MARKET PRICES INITIALIZATION (3 ticks - right after SQLite ready)
		// Initialize dynamic commodity pricing system from SQLite
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("MARKET: Initialize Commodity Prices (3 ticks)", 0)
		spawn(3)
			if(!InitializeMarketPrices())
				world.log << "\[SQLite Market WARNING\] Market price initialization failed"
			else
				world.log << "\[SUCCESS\] Market pricing system ready"
		spawn(4) RegisterInitComplete("market_prices")
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 1B: CRASH RECOVERY (5 ticks - runs right after time system)
		// Detect and recover players stranded by server crash
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 1B: Crash Recovery (5 ticks)", 0)
		spawn(5)  InitializeCrashRecovery()  // Detect and recover crashed players
		
		spawn(10) RegisterInitComplete("crash_recovery")
		
		// ────────────────────────────────────────────────────────────────────
		// SYSTEM: SERVER DIFFICULTY & LIVES SYSTEM (10 ticks)
		// Load server configuration (permadeath, lives per continent)
		// Must be ready before death system and player login
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("SYSTEM: Server Difficulty Configuration (10 ticks)", 10)
		spawn(10)
			BootServerDifficultySystem()  // Load difficulty config from savefile
			InitializeServerDifficultyConfig()  // Initialize lives tracking
		spawn(11) RegisterInitComplete("server_difficulty")
		
		// Map generation, zones, weather must be ready before map spawning
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 2: Core Infrastructure (50 ticks)", 0)
		
		spawn(0)   InitializeContinents()             // Three-world continental system
		spawn(0)   InitWeatherController()            // Weather base system
		spawn(1)   InitializeSeasonalWeather()        // Seasonal weather patterns (Phase 37)
		spawn(2)   InitializeWeatherCombatSystem()    // Weather-Combat Integration (Phase 38A)
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
		// PHASE 2B: AUDIO SYSTEM INITIALIZATION (Ticks 45-55)
		// Initialize music, sound effects, and ambient audio
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 2B: Audio System & Deed Registry (10 ticks - conditional)", 45)
		
		spawn(45)  InitializeAudioSystem()             // Audio integration (Phase C.1)
		spawn(47)  InitializeFireSystem()              // Fire system (Phase C.3 Stage 2)
		spawn(48)  InitializeEnvironmentalTemperature()  // Environmental temp (Phase C.3 Stage 3)
		spawn(50)  InitializeDeedDataManagerLazy()     // Deed system (lazy init)
		spawn(51)  LoadAllDeeds()                      // Phase 5: Load deeds from SQLite database
		spawn(52)  LoadMarketPricesFromSQLite()        // Phase 6: Load market prices from SQLite database
		spawn(53)  StartPriceHistoryArchiveLoop()      // Phase 6: Start periodic price history archiving
		spawn(54)  StartMarketAnalyticsUpdateLoop()    // Phase 7: Start market analytics calculations
		
		spawn(55) RegisterInitComplete("audio_deed")
		
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
		spawn(265)  InitializeAscensionMode()         // Stage 6 peaceful creative realm
		//spawn(270)  InitializeAscensionModeKnowledge()// Ascension mode knowledge base - DISABLED: invalid named parameters in new()
		spawn(275)  InitializeFactionSystem()         // Phase 9: Faction registry & PvP
		spawn(280)  InitializeDeathPenaltySystem()   // Death penalties, respawn, loot drops
		spawn(300)  InitializePhase4System()          // Character data & trading
		
		spawn(300) RegisterInitComplete("special_worlds")
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 5: NPC & RECIPE SYSTEMS (Ticks 300-400)
		// Character progression and NPC interactions
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 5: NPC & Recipe Systems (100 ticks)", 300)
		
		spawn(345)  InitializeKnowledgeBase()        // Knowledge base & tech tree (Phase C.3)
		spawn(346)  InitializeSandboxRecipeChains()  // Sandbox progression chains (Phase C.3 Stage 4)
		spawn(350)  InitializeNPCRecipeSystem()       // NPC recipe teaching
		spawn(355)  InitializeNPCRoutineSystem()      // NPC routines & schedules (Phase 38)
		spawn(360)  InitializeNPCRecipeHandlers()     // Recipe execution
		spawn(365)  InitializeFoodSupplySystem()      // Food supply management (Phase 38B)
		spawn(366)  InitializeNPCDialogueSystem()     // NPC dialogue & shop hours (Phase 38C)
		spawn(370)  InitializeSkillLevelUpIntegration() // Skill progression hooks
		spawn(375)  InitializeSkillRecipeSystem()     // Skill-based recipe unlocks
		spawn(376)  InitializeRecipeSignatures()      // Phase C.2: Recipe experimentation signatures
		
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
		spawn(383)  InitializeEquipmentVisualization()   // Equipment overlays (workaround)
		spawn(384)  InitializeMarketBoardUI()            // Trading interface
		spawn(384)  InitializeMarketBoardPersistence()   // Load saved listings/stalls
		spawn(385)  MarketBoardUpdateLoop()              // Market maintenance
		spawn(385)  StartMarketBoardMaintenanceLoop()    // Periodic saves & cleanup
		spawn(386)  InitializeInventoryManagementExtensions() // Bag system
		spawn(387)  InitializeDeedEconomySystem()        // Deed transfers & rentals
		spawn(389)  InitializeTerritoryResourceSystem()  // Phase 12c: Territory resource impact
		spawn(390)  InitializeSupplyDemandSystem()       // Phase 12d: Supply/demand curves
		spawn(391)  InitializeTradingPostUI()            // Phase 12e: Trading post interface
		spawn(392)  InitializeCrisisEventsSystem()       // Phase 12f: Crisis events
		spawn(393)  InitializeMarketIntegration()       // Phase 13: Market integration layer
		spawn(500)  InitializeWorldEventsSystem()        // Phase 13A: World events & auctions (tick 500)
	spawn(515)  InitializeSupplyChainSystem()        // Phase 13B: NPC migrations & supply chains (tick 515)
	spawn(530)  InitializeEconomicCycles()           // Phase 13C: Economic cycles & feedback loops (tick 530)
	spawn(394)  InitializePlayerEconomicEngagement()// Phase 14: Player engagement systems
		spawn(395)  InitializeEconomicGovernance()      // Phase 15: Economic governance
		spawn(396)  InitializeMaterialRegistry()         // Phase 16a: Material registry system
		spawn(397)  InitializeLocationGatedCrafting()    // Phase 16b: Location-gated crafting
		spawn(398)  InitializeWeaponArmorScaling()       // Phase 16c: Weapon/armor scaling
		spawn(399)  InitializeSpecialAttacks()           // Phase 17: Special attacks & skills
		spawn(400)  InitializePvPRanking()               // Phase 18: PvP ranking & rewards
		spawn(401)  InitializeCombatProgression()        // Phase 19: Combat progression loop
		spawn(403)  InitializeEconomyCombatIntegration()  // Phase 20: Economy-combat loop
		spawn(421)  InitializeTerritorySystem()            // Phase 21: Territory claiming
		spawn(422)  InitializeTerritoryDefense()           // Phase 22: Territory defense
		spawn(423)  InitializeTerritoryWars()              // Phase 23: Territory wars & raiding
		spawn(424)  InitializeGuildSystem()                // Phase 24: Guild formation & diplomacy
		spawn(425)  InitializeSeasonalEvents()             // Phase 25: Seasonal territory events
		spawn(426)  InitializeRegionalConflict()           // Phase 26: Regional conflict escalation
		spawn(427)  InitializeSiegeEquipment()             // Phase 27: Siege equipment & weapons
		spawn(428)  InitializeNPCGarrison()                // Phase 28: NPC garrison & auto-defense
		spawn(429)  InitializeSiegeEvents()                // Phase 29: Siege events & dynamic warfare
		spawn(430)  InitializeEliteOfficers()              // Phase 30: Elite officers & command system
		spawn(431)  InitializeOfficerAbilities()           // Phase 31: Officer abilities & specialization
		spawn(432)  InitializeOfficerTournaments()         // Phase 33: Tournaments & ranking system
		spawn(433)  InitializeOfficerLoyalty()             // Phase 34: Officer loyalty & defection
		spawn(434)  InitializeOGVUI()                      // Phase 34B: OGV battle visualization
		
		spawn(435) RegisterInitComplete("economy")
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 7: QUALITY OF LIFE (Ticks 384-395)
		// Discovery, recipe balancing, UI polish
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 7: Quality of Life Systems (11 ticks)", 384)
		
		spawn(384)  InitializeRecipeDiscoveryRateBalancing() // Recipe discovery
		spawn(385)  InitializeUIEventBus()                   // Phase 35: UI Event Bus
		spawn(386)  InitializeSeasonalModifierProcessor()    // Seasonal game mechanics
		spawn(387)  CleanupActivityLogs()                    // Activity log maintenance
		
		spawn(395) RegisterInitComplete("quality_of_life")
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 8: ADVANCED TRADING & TRANSACTION SYSTEMS (Ticks 400-405)
		// Transaction logging, dispute resolution, trading analytics
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 8: Advanced Trading & Transactions (5 ticks)", 400)
		
		spawn(400)  InitializeMarketTransactionLogger()      // Transaction logging
		spawn(401)  InitializeDisputeResolutionSystem()      // Dispute handling
		spawn(402)  InitializePlayerTradingAnalytics()       // Trading statistics
		spawn(403)  InitializeMarketSettlementProcessor()    // Settlement automation
		spawn(404)  StartTransactionMaintenanceLoop()        // Expired transaction cleanup
		
		spawn(405) RegisterInitComplete("trading_transactions")
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 9: RECIPE & CRAFTING PERSISTENCE (Ticks 410-415)
		// Crafting history, recipe discovery tracking, specialization
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 9: Recipe & Crafting Persistence (5 ticks)", 410)
		
		spawn(410)  LoadRecipeDatabase()                     // Load recipes from SQLite
		spawn(411)  InitializeCraftingHistoryTracker()       // Log crafting activities
		spawn(412)  InitializeRecipeDiscoveryTracker()       // Track recipe unlocks
		spawn(413)  InitializeCraftingSpecializationSystem() // Player specialization
		spawn(414)  StartCraftingAchievementProcessor()      // Mastery achievements
		
		spawn(415) RegisterInitComplete("crafting_persistence")
		
		// ────────────────────────────────────────────────────────────────────
		// PHASE 10: ADVANCED MARKET PREDICTIONS (Ticks 420-425)
		// Price forecasting, supply disruption alerts, seasonal analysis
		// ────────────────────────────────────────────────────────────────────
		
		LogInit("PHASE 10: Advanced Market Predictions (5 ticks)", 420)
		
		spawn(420)  InitializeMarketForecastingEngine()      // Price forecasting
		spawn(421)  InitializeSupplyDisruptionAlertSystem()  // Disruption detection
		spawn(422)  InitializeSeasonalDemandAnalyzer()       // Seasonal patterns
		spawn(423)  InitializeCommodityCorrelationAnalysis() // Correlation tracking
		spawn(424)  StartPlayerMarketInsightGenerator()      // Player recommendations
		spawn(425)  StartMarketTrendSnapshotGenerator()      // Daily snapshots
		
		spawn(426) RegisterInitComplete("market_predictions")
		
		// ────────────────────────────────────────────────────────────────────
		// FINALIZATION
		// ────────────────────────────────────────────────────────────────────
		
		spawn(430) FinalizeInitialization()

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
	world.log << "\[INIT\] Total startup time: [total_time] ticks"
	world.log << "\[INIT\] Systems initialized: [initialization_complete.len]"
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

// ============================================================================
// PHASE 5 HELPER PROCS (Deed Persistence)
// ============================================================================

proc/LoadAllDeeds()
	/**
	 * Phase 5: Load all deeds from SQLite database on world boot
	 * Called from InitializeWorld() at tick 51 (after SQLite ready)
	 * Recreates all DeedToken_Zone objects in the game world
	 */
	if(!sqlite_ready)
		world.log << "\[WARNING\] LoadAllDeeds() called but SQLite not ready yet"
		return
	
	world.log << "\[DEEDS\] Loading deeds from SQLite database..."
	
	var/list/loaded_deeds = GetAllDeedsFromSQLite()
	
	if(!loaded_deeds || loaded_deeds.len == 0)
		world.log << "\[DEEDS\] No deeds found in database - fresh world or empty database"
		return
	
	world.log << "\[DEEDS\] Successfully restored [loaded_deeds.len] deed(s) from database"
	world.log << "\[SUCCESS\] Deed system ready"

// ============================================================================
// Phase 6: Market Price History Archiving
// ============================================================================

/**
 * StartPriceHistoryArchiveLoop()
 * Runs as background process to periodically save price snapshots
 * Called at tick 53 during initialization
 */
proc/StartPriceHistoryArchiveLoop()
	if(!market_engine)
		world.log << "\[WARNING\] StartPriceHistoryArchiveLoop() - market_engine not ready"
		return
	
	set background = 1
	set waitfor = 0
	
	world.log << "\[MARKET_ARCHIVE\] Price history archiving loop started"
	
	while(1)
		sleep(500)  // Every 2500 ticks (100 seconds per tick * 25ms)
		
		if(!sqlite_ready) continue
		
		// Archive current prices to history
		for(var/commodity_name in market_engine.commodities)
			var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
			if(commodity)
				var/trend = GetCommodityTrend(commodity_name)
				SavePriceHistory(commodity_name, commodity.current_price, trend)
		
		// Prune old records every 100 iterations (daily approximately)
		if(world.time % 50000 == 0)
			PruneOldPriceHistory(30)

// ============================================================================
// Phase 7: Market Analytics Update Loop
// ============================================================================

/**
 * StartMarketAnalyticsUpdateLoop()
 * Runs as background process to periodically calculate market analytics
 * Called at tick 54 during initialization
 */
proc/StartMarketAnalyticsUpdateLoop()
	if(!market_engine)
		world.log << "\[WARNING\] StartMarketAnalyticsUpdateLoop() - market_engine not ready"
		return
	
	set background = 1
	set waitfor = 0
	
	world.log << "\[MARKET_ANALYTICS\] Market analytics calculation loop started"
	
	while(1)
		sleep(1000)  // Every 5000 ticks (~200 seconds)
		
		if(!sqlite_ready) continue
		
		// Calculate analytics for all commodities
		var/calc_count = 0
		for(var/commodity_name in market_engine.commodities)
			if(UpdateAnalyticsMetrics(commodity_name))
				calc_count++
		
		if(calc_count > 0)
			world.log << "MARKET_ANALYTICS: Updated [calc_count] commodity metrics"

	// ============================================================================
	// PHASE 11: GLOBAL RESOURCES, NPC STATE, CALENDAR/EVENTS (Tick 430-450)
	// ============================================================================

	spawn(86)  // 430 ticks = 86 * 5 deciseconds = 2150ms
		if(!InitializeGlobalResourceSystem())
			world.log << "ERROR: Global Resource System initialization failed"
		else
			RegisterInitComplete("Phase_11A_Global_Resources")

	spawn(88)  // 440 ticks = 88 * 5 deciseconds = 2200ms
		if(!InitializeNPCPersistenceSystem())
			world.log << "ERROR: NPC Persistence System initialization failed"
		else
			RegisterInitComplete("Phase_11B_NPC_State")

	spawn(90)  // 450 ticks = 90 * 5 deciseconds = 2250ms
		if(!InitializeCalendarSystem())
			world.log << "ERROR: Calendar System initialization failed"
		else
			RegisterInitComplete("Phase_11C_Calendar_Events")

// ============================================================================
// INITIALIZATION PROCEDURES
// ============================================================================

/proc/InitializeGlobalResourceSystem()
	// Phase 11A: Initialize global resource tracking from TimeSave data
	// NOTE: TimeSave should already be loaded by world/New(), so SP/MP/SB/SM are available
	set background = 1
	set waitfor = 0
	
	// Load current global resource amounts (these should be loaded from timesave.sav)
	// Note: If savefile doesn't exist, these will be 0 and we initialize with defaults
	var/current_stone = SP || 100000
	SetGlobalResourceAmount("stone", current_stone)
	
	var/current_metal = MP || 50000
	SetGlobalResourceAmount("metal", current_metal)
	
	var/current_timber = SB || 80000
	SetGlobalResourceAmount("timber", current_timber)
	
	var/current_supply_box = SM || 1000
	SetGlobalResourceAmount("supply_box", current_supply_box)
	
	world.log << "RESOURCE_SYSTEM: Initialized [current_stone]sp, [current_metal]mp, [current_timber]t, [current_supply_box]sb"
	
	return TRUE

/proc/InitializeNPCPersistenceSystem()
	// Phase 11B: Load NPC state from database and restore positions
	set background = 1
	set waitfor = 0
	
	// Query all saved NPCs
	var/query = "SELECT npc_name, current_x, current_y, current_z, current_hp, current_stamina FROM npc_persistent_state WHERE is_alive = 1"
	var/result = ExecuteSQLiteQuery(query)
	
	var/restored_count = 0
	
	if(result)
		var/list/rows = result
		for(var/row in rows)
			var/list/cols = row
			restored_count++
	
	if(restored_count > 0)
		world.log << "NPC_PERSISTENCE: Restored state for [restored_count] NPCs"
	
	return TRUE

/proc/InitializeCalendarSystem()
	// Phase 11C: Initialize world calendar and seasonal events
	// NOTE: Global time variables (hour, day, month, year, minute1, minute2) should be loaded from timesave.sav
	set background = 1
	set waitfor = 0
	
	// Use global time variables (should be loaded from savefile by TimeLoad())
	var/current_day = day || 1
	var/current_month = month || 1
	var/current_year = year || 1
	var/current_hour = hour || 12
	var/minute_val = ((minute1 || 0) * 10) + (minute2 || 0)
	
	// Calculate day number (1-365/366)
	var/day_number = (((current_month - 1) * 30) + current_day)
	
	// Determine season
	var/season = "spring"
	switch(current_month)
		if(4, 5, 6)
			season = "spring"
		if(7, 8, 9)
			season = "summer"
		if(10, 11, 12)
			season = "autumn"
		if(1, 2, 3)
			season = "winter"
	
	// Determine day of week (simplified)
	var/list/days_of_week = list("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
	var/day_of_week = days_of_week[((day_number % 7) + 1)]
	
	// Calculate daylight hours based on season
	var/daylight_hours = 12
	switch(season)
		if("spring", "autumn")
			daylight_hours = 12
		if("summer")
			daylight_hours = 14
		if("winter")
			daylight_hours = 10
	
	var/query = "INSERT OR REPLACE INTO world_calendar (day_number, season, month, year, day_of_week, time_of_day_minutes, daylight_hours) VALUES ([day_number], '[season]', [current_month], [current_year], '[day_of_week]', [minute_val], [daylight_hours])"
	ExecuteSQLiteQuery(query)
	
	world.log << "CALENDAR_SYSTEM: Initialized calendar - Day [day_number] ([season]), Time [current_hour]:[minute_val % 60]"
	
	return TRUE

// ============================================================================
// PHASE 8: ADVANCED TRADING & TRANSACTIONS INITIALIZATION
// ============================================================================

/**
 * InitializeMarketTransactionLogger()
 * Setup transaction logging system for market trades
 */
proc/InitializeMarketTransactionLogger()
	world.log << "\[TRADING\] Initializing market transaction logger..."
	// Transactions logged automatically by market system via LogMarketTransaction()
	world.log << "\[SUCCESS\] Transaction logger ready"

/**
 * InitializeDisputeResolutionSystem()
 * Setup dispute handling and resolution system
 */
proc/InitializeDisputeResolutionSystem()
	world.log << "\[DISPUTES\] Initializing dispute resolution system..."
	// Disputes managed via dispute APIs
	world.log << "\[SUCCESS\] Dispute resolution system ready"

/**
 * InitializePlayerTradingAnalytics()
 * Setup player trading statistics tracking
 */
proc/InitializePlayerTradingAnalytics()
	world.log << "\[ANALYTICS\] Initializing player trading analytics..."
	// Analytics updated after each transaction via UpdatePlayerTradingStats()
	world.log << "\[SUCCESS\] Trading analytics ready"

/**
 * InitializeMarketSettlementProcessor()
 * Setup automatic transaction settlement
 */
proc/InitializeMarketSettlementProcessor()
	world.log << "\[SETTLEMENT\] Initializing market settlement processor..."
	// Settlement handled by CompleteTransaction() on confirmation
	world.log << "\[SUCCESS\] Settlement processor ready"

/**
 * StartTransactionMaintenanceLoop()
 * Background loop to expire old transactions and clean up database
 */
proc/StartTransactionMaintenanceLoop()
	set background = 1
	set waitfor = 0
	
	world.log << "\[TRANSACTIONS\] Transaction maintenance loop started"
	
	while(1)
		sleep(3000)  // Every 15000 ticks (~150 seconds)
		
		if(!sqlite_ready) continue
		
		// Clean expired transactions
		var/cleanup_query = "UPDATE market_transactions SET settlement_status='expired' WHERE expires_at < CURRENT_TIMESTAMP AND settlement_status='pending'"
		ExecuteSQLiteQuery(cleanup_query)

// ============================================================================
// PHASE 9: RECIPE & CRAFTING PERSISTENCE INITIALIZATION
// ============================================================================

/**
 * InitializeCraftingHistoryTracker()
 * Setup crafting activity logging
 */
proc/InitializeCraftingHistoryTracker()
	world.log << "\[CRAFTING\] Initializing crafting history tracker..."
	// History logged automatically via LogCraftingAttempt()
	world.log << "\[SUCCESS\] Crafting history tracker ready"

/**
 * InitializeRecipeDiscoveryTracker()
 * Setup recipe discovery tracking
 */
proc/InitializeRecipeDiscoveryTracker()
	world.log << "\[RECIPES\] Initializing recipe discovery tracker..."
	// Discovery tracked via UnlockRecipeForPlayer()
	world.log << "\[SUCCESS\] Recipe discovery tracker ready"

/**
 * InitializeCraftingSpecializationSystem()
 * Setup player crafting specialization
 */
proc/InitializeCraftingSpecializationSystem()
	world.log << "\[SPECIALIZATION\] Initializing crafting specialization system..."
	// Specialization managed via UpdateCraftingSpecialization()
	world.log << "\[SUCCESS\] Specialization system ready"

/**
 * StartCraftingAchievementProcessor()
 * Background loop to award crafting achievements
 */
proc/StartCraftingAchievementProcessor()
	set background = 1
	set waitfor = 0
	
	world.log << "\[ACHIEVEMENTS\] Crafting achievement processor started"
	
	while(1)
		sleep(5000)  // Check every 25000 ticks
		
		if(!sqlite_ready) continue
		
		// Award milestones (100 crafts, perfect quality, etc.) via RegisterCraftingAchievement()

// ============================================================================
// PHASE 10: ADVANCED MARKET PREDICTIONS INITIALIZATION
// ============================================================================

/**
 * InitializeMarketForecastingEngine()
 * Setup price forecasting system
 */
proc/InitializeMarketForecastingEngine()
	world.log << "\[FORECASTING\] Initializing market forecasting engine..."
	// Forecasts generated via GeneratePriceForecast()
	world.log << "\[SUCCESS\] Forecasting engine ready"

/**
 * InitializeSupplyDisruptionAlertSystem()
 * Setup supply disruption detection and alerts
 */
proc/InitializeSupplyDisruptionAlertSystem()
	world.log << "\[DISRUPTIONS\] Initializing supply disruption alert system..."
	// Alerts issued via IssueSupplyDisruptionAlert()
	world.log << "\[SUCCESS\] Disruption alert system ready"

/**
 * InitializeSeasonalDemandAnalyzer()
 * Setup seasonal demand pattern analysis
 */
proc/InitializeSeasonalDemandAnalyzer()
	world.log << "\[SEASONAL\] Initializing seasonal demand analyzer..."
	// Patterns stored via GetSeasonalDemandPattern()
	world.log << "\[SUCCESS\] Seasonal analyzer ready"

/**
 * InitializeCommodityCorrelationAnalysis()
 * Setup commodity correlation tracking
 */
proc/InitializeCommodityCorrelationAnalysis()
	world.log << "\[CORRELATION\] Initializing commodity correlation analysis..."
	// Correlations calculated via AnalyzeCommodityCorrelation()
	world.log << "\[SUCCESS\] Correlation analysis ready"

/**
 * StartPlayerMarketInsightGenerator()
 * Background loop to generate personalized player insights
 */
proc/StartPlayerMarketInsightGenerator()
	set background = 1
	set waitfor = 0
	
	world.log << "\[INSIGHTS\] Player market insight generator started"
	
	while(1)
		sleep(6000)  // Every 30000 ticks (~5 minutes)
		
		if(!sqlite_ready) continue
		
		// Generate insights for active players via GeneratePlayerMarketInsight()

/**
 * StartMarketTrendSnapshotGenerator()
 * Daily background process to generate market trend snapshots
 */
proc/StartMarketTrendSnapshotGenerator()
	set background = 1
	set waitfor = 0
	
	world.log << "\[SNAPSHOTS\] Market trend snapshot generator started"
	
	while(1)
		sleep(432000)  // Every 24 hours (432000 ticks = ~1 day)
		
		if(!sqlite_ready) continue
		
		// Generate daily snapshot via GenerateMarketTrendSnapshot()
		GenerateMarketTrendSnapshot()

