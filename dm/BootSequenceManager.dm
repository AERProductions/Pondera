// ============================================================================
// FILE: dm/BootSequenceManager.dm
// PURPOSE: Central registry and management for all background loops
// SYSTEM: Phase 2 Boot Optimization
// ============================================================================

/**
 * BOOT SEQUENCE MANAGER
 * =====================
 * Consolidates 50+ scattered background loops into a single registry.
 * 
 * MOTIVATION:
 * - Background loops scattered across 15+ files
 * - No central monitoring or control
 * - Difficult to track which loops are running
 * - No performance profiling data
 * 
 * SOLUTION:
 * - Single registry (BACKGROUND_LOOPS) for all loops
 * - Metadata tracking: name, start time, tick interval, status
 * - Performance metrics: average cycle time, sleep time
 * - Status reporting and diagnostics
 * 
 * INTEGRATION:
 * - Called from InitializationManager.dm Phase 5 (tick 400+)
 * - After all systems initialized
 * - Before world_initialization_complete = TRUE
 * 
 * FUTURE ENHANCEMENTS:
 * - Per-loop performance profiling
 * - Pause/resume individual loops
 * - Dynamic tick interval adjustment
 * - Memory usage tracking
 */

// ============================================================================
// GLOBAL REGISTRY
// ============================================================================

var/global/list/BACKGROUND_LOOPS = list()  // Registry of all background loops
var/global/boot_sequence_manager_ready = FALSE

// ============================================================================
// LOOP REGISTRATION & TRACKING
// ============================================================================

/**
 * RegisterBackgroundLoop(loop_name, proc/loop_proc, tick_offset, interval)
 * Register a background loop for tracking and monitoring
 * 
 * PARAMS:
 * - loop_name: Unique identifier ("day_night_cycle", "deed_maintenance", etc.)
 * - loop_proc: Reference to the loop procedure
 * - tick_offset: When loop starts (in world ticks, relative to boot)
 * - interval: Sleep interval (in ticks) between iterations
 * 
 * EXAMPLE:
 *   RegisterBackgroundLoop("day_night_cycle", /proc/_day_night_cycle_loop, 50, 20)
 */
proc/RegisterBackgroundLoop(loop_name, loop_proc, tick_offset, interval)
	if(BACKGROUND_LOOPS[loop_name])
		world.log << "WARNING: Loop '[loop_name]' already registered"
		return FALSE
	
	var/datum/background_loop/loop = new()
	loop.name = loop_name
	loop.proc = loop_proc
	loop.start_tick = tick_offset
	loop.interval = interval
	loop.status = "pending"  // pending → running → paused
	loop.registered_time = world.time
	
	BACKGROUND_LOOPS[loop_name] = loop
	
	world.log << "Loop registered: [loop_name] (starts tick [tick_offset], interval [interval])"
	return TRUE

/**
 * MarkLoopActive(loop_name)
 * Called when a loop actually starts running (at its spawn point)
 */
proc/MarkLoopActive(loop_name)
	var/datum/background_loop/loop = BACKGROUND_LOOPS[loop_name]
	if(!loop)
		return FALSE
	
	loop.status = "running"
	loop.actual_start_time = world.time
	return TRUE

/**
 * GetLoopStatus(loop_name)
 * Query status of a specific loop
 */
proc/GetLoopStatus(loop_name)
	var/datum/background_loop/loop = BACKGROUND_LOOPS[loop_name]
	if(!loop)
		return "unknown"
	return loop.status

/**
 * GetBackgroundLoopsStatus()
 * Return summary of all registered loops (for diagnostics/admin panel)
 * 
 * RETURNS:
 * - Count of registered loops
 * - Count of running loops
 * - List of loop names and statuses
 */
proc/GetBackgroundLoopsStatus()
	var/total = BACKGROUND_LOOPS.len
	var/running = 0
	var/paused = 0
	var/pending = 0
	
	for(var/loop_name in BACKGROUND_LOOPS)
		var/datum/background_loop/loop = BACKGROUND_LOOPS[loop_name]
		if(loop.status == "running") running++
		else if(loop.status == "paused") paused++
		else if(loop.status == "pending") pending++
	
	var/status_text = "Background Loop Status:\n"
	status_text += "Total: [total] | Running: [running] | Paused: [paused] | Pending: [pending]\n\n"
	
	status_text += "LOOP DETAILS:\n"
	for(var/loop_name in BACKGROUND_LOOPS)
		var/datum/background_loop/loop = BACKGROUND_LOOPS[loop_name]
		status_text += "- [loop_name]: [loop.status] (interval: [loop.interval]ms)\n"
	
	return status_text

// ============================================================================
// BOOT SEQUENCE MANAGER INITIALIZATION
// ============================================================================

/**
 * BootSequenceManager.Start()
 * Called from InitializationManager Phase 5 (tick 400+)
 * 
 * RESPONSIBILITIES:
 * 1. Register known background loops (for tracking)
 * 2. Validate all loops are spawned and active
 * 3. Generate initial status report
 * 4. Enable monitoring and profiling
 * 5. Call RegisterInitComplete("boot_sequence_manager")
 */
proc/BootSequenceManager_Start()
	if(boot_sequence_manager_ready)
		return  // Already initialized
	
	world.log << "BOOT: Initializing Background Loop Registry..."
	
	// ────────────────────────────────────────────────────────────────────
	// LIGHTING SYSTEM LOOPS
	// ────────────────────────────────────────────────────────────────────
	RegisterBackgroundLoop("day_night_cycle", /proc/_day_night_cycle_loop, 50, 20)
	// Note: Day/night loop started in Fl_LightingIntegration.dm Phase 3
	
	// ────────────────────────────────────────────────────────────────────
	// DEED SYSTEM LOOPS
	// ────────────────────────────────────────────────────────────────────
	RegisterBackgroundLoop("deed_maintenance", /proc/StartDeedMaintenanceProcessor, 100, 6000)
	// Deed maintenance runs ~every 5 minutes (6000 ticks = 150 seconds)
	
	// ────────────────────────────────────────────────────────────────────
	// MARKET & ECONOMY LOOPS
	// ────────────────────────────────────────────────────────────────────
	RegisterBackgroundLoop("market_board_update", /proc/MarketBoardUpdateLoop, 385, 50)
	RegisterBackgroundLoop("market_maintenance", /proc/StartMarketBoardMaintenanceLoop, 385, 500)
	RegisterBackgroundLoop("dynamic_pricing", /proc/SeasonalModifierUpdateLoop, 375, 100)
	// Note: enhanced_pricing merged into SeasonalModifierUpdateLoop
	
	// ────────────────────────────────────────────────────────────────────
	// PHASE 13: ECONOMY & WORLD SYSTEMS
	// ────────────────────────────────────────────────────────────────────
	RegisterBackgroundLoop("world_events", /proc/InitializeWorldEventsSystem, 50, 300)
	RegisterBackgroundLoop("supply_chains", /proc/NPCTradingLoop, 515, 200)
	RegisterBackgroundLoop("economic_monitoring", /proc/EconomicMonitoringLoop, 530, 400)
	
	// ────────────────────────────────────────────────────────────────────
	// ENVIRONMENTAL & TEMPERATURE LOOPS
	// ────────────────────────────────────────────────────────────────────
	RegisterBackgroundLoop("temperature_system", /proc/_temperature_monitoring_loop, 200, 100)
	RegisterBackgroundLoop("seasonal_integration", /proc/_seasonal_modifier_processor_loop, 200, 1000)
	RegisterBackgroundLoop("soil_degradation", /proc/_soil_degradation_processor_loop, 200, 600)
	
	// ────────────────────────────────────────────────────────────────────
	// CRAFTING & COOKING LOOPS
	// ────────────────────────────────────────────────────────────────────
	// Note: Cooking loops are obj methods in CookingSystem.dm, not global procs
	
	// ────────────────────────────────────────────────────────────────────
	// NPC & ROUTINE LOOPS
	// ────────────────────────────────────────────────────────────────────
	RegisterBackgroundLoop("npc_routines", /proc/_npc_routine_processor_loop, 350, 250)
	RegisterBackgroundLoop("npc_pathfinding", /proc/_npc_pathfinding_loop, 350, 100)
	RegisterBackgroundLoop("npc_reputation", /proc/_npc_reputation_decay_loop, 360, 500)
	
	// ────────────────────────────────────────────────────────────────────
	// COMBAT & ANIMATION LOOPS
	// ────────────────────────────────────────────────────────────────────
	RegisterBackgroundLoop("enemy_ai_combat", /proc/_enemy_ai_combat_animation_loop, 300, 25)
	RegisterBackgroundLoop("combat_progression", /proc/_combat_progression_loop, 300, 100)
	
	// ────────────────────────────────────────────────────────────────────
	// TERRITORY & WARFARE LOOPS (placeholder - future implementation)
	// ────────────────────────────────────────────────────────────────────
	RegisterBackgroundLoop("territory_claims", /proc/_territory_maintenance_loop, 300, 1000)
	RegisterBackgroundLoop("territory_warfare", /proc/_territory_war_processor_loop, 300, 500)
	RegisterBackgroundLoop("siege_events", /proc/_siege_event_processor_loop, 300, 300)
	
	// ────────────────────────────────────────────────────────────────────
	// WORLD SYSTEMS LOOPS (placeholder - future implementation)
	// ────────────────────────────────────────────────────────────────────
	RegisterBackgroundLoop("crisis_events", /proc/CrisisEventMonitoringLoop, 392, 500)
	RegisterBackgroundLoop("seasonal_events", /proc/_seasonal_territory_events_loop, 200, 1000)
	
	// ────────────────────────────────────────────────────────────────────
	// PERFORMANCE MONITORING (placeholder - future implementation)
	// ────────────────────────────────────────────────────────────────────
	RegisterBackgroundLoop("performance_monitoring", /proc/_performance_monitoring_loop, 400, 100)
	
	boot_sequence_manager_ready = TRUE
	
	world.log << "BOOT: Background Loop Registry initialized successfully"
	world.log << GetBackgroundLoopsStatus()
	
	RegisterInitComplete("boot_sequence_manager")

// ============================================================================
// DATUM: BACKGROUND_LOOP (METADATA)
// ============================================================================

/datum/background_loop
	var
		name                // Loop identifier
		proc                // Proc reference (for future pause/resume)
		start_tick          // When loop should start (world ticks)
		interval            // Sleep interval (ticks) between iterations
		status = "pending"  // pending | running | paused
		registered_time     // When registered
		actual_start_time   // When actually started
		
		// Performance metrics (future use)
		last_cycle_duration = 0  // Time to complete one cycle
		average_cycle_duration = 0
		total_cycles = 0

// ============================================================================
// UTILITY PROCS
// ============================================================================

/**
 * PauseBackgroundLoop(loop_name)
 * Pause a specific loop (future enhancement)
 */
proc/PauseBackgroundLoop(loop_name)
	var/datum/background_loop/loop = BACKGROUND_LOOPS[loop_name]
	if(!loop)
		return FALSE
	
	loop.status = "paused"
	world.log << "Loop paused: [loop_name]"
	return TRUE

/**
 * ResumeBackgroundLoop(loop_name)
 * Resume a paused loop (future enhancement)
 */
proc/ResumeBackgroundLoop(loop_name)
	var/datum/background_loop/loop = BACKGROUND_LOOPS[loop_name]
	if(!loop)
		return FALSE
	
	loop.status = "running"
	world.log << "Loop resumed: [loop_name]"
	return TRUE

/**
 * GetBackgroundLoopCount()
 * Quick count of total registered loops
 */
proc/GetBackgroundLoopCount()
	return BACKGROUND_LOOPS.len

/**
 * GetBackgroundLoopCount_Running()
 * Count of currently running loops
 */
proc/GetBackgroundLoopCount_Running()
	var/count = 0
	for(var/loop_name in BACKGROUND_LOOPS)
		var/datum/background_loop/loop = BACKGROUND_LOOPS[loop_name]
		if(loop.status == "running") count++
	return count


