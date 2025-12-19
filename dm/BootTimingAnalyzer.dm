// ============================================================================
// FILE: dm/BootTimingAnalyzer.dm
// PURPOSE: Track and analyze boot sequence timing metrics
// SYSTEM: Phase 3 Boot Diagnostics
// ============================================================================

/**
 * BOOT TIMING ANALYZER
 * ====================
 * Measures initialization performance across all 25+ phases.
 * Provides diagnostic insights into boot time bottlenecks.
 * 
 * USAGE:
 * - Called from InitializationManager at each phase via BootTimingAnalyzer_RecordPhase()
 * - Generates report when world_initialization_complete = TRUE
 * - Accessible via GetBootDiagnosticReport() after boot
 * 
 * METRICS TRACKED:
 * - Phase name & completion tick
 * - Duration since last phase (delta time)
 * - Cumulative time from boot
 * - System category (infrastructure, npc, market, etc.)
 * 
 * PERFORMANCE TARGETS:
 * - Phase 2 (infrastructure): 50 ticks (2500ms) target
 * - Phase 3 (day/night): 50 ticks target
 * - Phase 4 (world systems): 250 ticks target
 * - Phase 5 (complete): 400 ticks (20 seconds) target
 * - Total boot time: <20 seconds preferred
 */

// ============================================================================
// GLOBAL REGISTRY
// ============================================================================

var/global/list/BOOT_PHASE_METRICS = list()  // Track all phase timings
var/global/boot_timing_start_tick = 0         // Boot start time
var/global/boot_timing_complete = FALSE

// ============================================================================
// DATUM: BOOT_PHASE_METRIC
// ============================================================================

/datum/boot_phase_metric
	var
		phase_name              // e.g., "Phase 2: Infrastructure"
		category                // e.g., "infrastructure", "market", "npc"
		start_tick              // When phase started
		end_tick = 0            // When phase ended
		duration = 0            // Duration in ticks
		cumulative_time = 0     // Total time since boot start
		status = "pending"      // pending | running | complete
		dependencies = list()   // Phases that must complete first
		subsystems = list()     // List of subsystems initialized

// ============================================================================
// PHASE RECORDING & TRACKING
// ============================================================================

/**
 * BootTimingAnalyzer_Initialize()
 * Called at boot start (world/New())
 */
proc/BootTimingAnalyzer_Initialize()
	if(!boot_timing_start_tick)
		boot_timing_start_tick = world.time
		world.log << "\[TIMING\] Boot timing analyzer started at world.time = [world.time]"

/**
 * BootTimingAnalyzer_RecordPhase(phase_name, category, dependencies)
 * Record that a new phase is starting
 * 
 * PARAMS:
 * - phase_name: "Phase 2: Infrastructure"
 * - category: "infrastructure" | "market" | "npc" | etc.
 * - dependencies: list of phases that must complete first
 */
proc/BootTimingAnalyzer_RecordPhase(phase_name, category, dependencies = null)
	if(!boot_timing_start_tick)
		BootTimingAnalyzer_Initialize()
	
	var/datum/boot_phase_metric/metric = new()
	metric.phase_name = phase_name
	metric.category = category
	metric.start_tick = world.time
	metric.status = "running"
	metric.dependencies = dependencies || list()
	
	BOOT_PHASE_METRICS[phase_name] = metric
	
	world.log << "\[TIMING\] [phase_name] started"

/**
 * BootTimingAnalyzer_CompletePhase(phase_name, subsystems = null)
 * Record that a phase has completed
 * 
 * PARAMS:
 * - phase_name: Must match the phase recorded in BootTimingAnalyzer_RecordPhase()
 * - subsystems: list of subsystem names initialized
 */
proc/BootTimingAnalyzer_CompletePhase(phase_name, subsystems = null)
	var/datum/boot_phase_metric/metric = BOOT_PHASE_METRICS[phase_name]
	if(!metric)
		world.log << "\[WARNING\] Attempted to complete unknown phase: [phase_name]"
		return
	
	metric.end_tick = world.time
	metric.duration = metric.end_tick - metric.start_tick
	metric.cumulative_time = metric.end_tick - boot_timing_start_tick
	metric.status = "complete"
	metric.subsystems = subsystems || list()
	
	world.log << "\[TIMING\] [phase_name] completed in [metric.duration] ticks ([metric.cumulative_time] cumulative)"

/**
 * GetBootDiagnosticReport()
 * Generate comprehensive boot timing report
 * Called when world_initialization_complete = TRUE
 */
proc/GetBootDiagnosticReport()
	var/report = ""
	report += "═══════════════════════════════════════════════════════════════\n"
	report += "BOOT SEQUENCE DIAGNOSTIC REPORT\n"
	report += "═══════════════════════════════════════════════════════════════\n\n"
	
	if(!boot_timing_start_tick)
		return report + "ERROR: Boot timing not initialized\n"
	
	// Summary statistics
	var/total_phases = BOOT_PHASE_METRICS.len
	var/completed_phases = 0
	var/total_ticks = 0
	var/max_phase_ticks = 0
	var/slowest_phase = ""
	var/list/categories = list()
	
	for(var/phase_name in BOOT_PHASE_METRICS)
		var/datum/boot_phase_metric/metric = BOOT_PHASE_METRICS[phase_name]
		if(metric.status == "complete")
			completed_phases++
			total_ticks += metric.duration
			if(metric.duration > max_phase_ticks)
				max_phase_ticks = metric.duration
				slowest_phase = phase_name
			if(!categories[metric.category])
				categories[metric.category] = 0
			categories[metric.category] += metric.duration
	
	report += "SUMMARY\n"
	report += "───────────────────────────────────────────────────────────────\n"
	report += "Total Phases: [total_phases]\n"
	report += "Completed: [completed_phases]\n"
	report += "Total Boot Time: [total_ticks] ticks ([total_ticks * 5]ms / [total_ticks / 20]s)\n"
	report += "Slowest Phase: [slowest_phase] ([max_phase_ticks] ticks)\n\n"
	
	// Category breakdown
	report += "CATEGORY BREAKDOWN\n"
	report += "───────────────────────────────────────────────────────────────\n"
	for(var/category in categories)
		var/time = categories[category]
		var/percent = round((time / total_ticks) * 100)
		report += "[category]: [time] ticks ([percent]%)\n"
	report += "\n"
	
	// Detailed phase timeline
	report += "PHASE TIMELINE\n"
	report += "───────────────────────────────────────────────────────────────\n"
	report += "Phase                                Duration (ticks)  Cumulative  Category\n"
	report += "───────────────────────────────────────────────────────────────\n"
	
	for(var/phase_name in BOOT_PHASE_METRICS)
		var/datum/boot_phase_metric/metric = BOOT_PHASE_METRICS[phase_name]
		if(metric.status == "complete")
			report += "[phase_name] [metric.duration] [metric.cumulative_time] [metric.category]\n"
	
	report += "\n"
	
	// Performance analysis
	report += "PERFORMANCE ANALYSIS\n"
	report += "───────────────────────────────────────────────────────────────\n"
	if(total_ticks < 400)
		report += "✅ Boot time EXCELLENT (<20 seconds)\n"
	else if(total_ticks < 500)
		report += "✓ Boot time acceptable (20-25 seconds)\n"
	else
		report += "⚠️ Boot time slow (>25 seconds)\n"
	
	if(max_phase_ticks > 100)
		report += "⚠️ Single phase taking >5 seconds: [slowest_phase]\n"
	else
		report += "✅ No individual phase bottleneck detected\n"
	
	report += "\n"
	
	// Recommendations
	report += "RECOMMENDATIONS\n"
	report += "───────────────────────────────────────────────────────────────\n"
	
	// Find slow categories
	var/slowest_category = ""
	var/slowest_category_time = 0
	for(var/category in categories)
		if(categories[category] > slowest_category_time)
			slowest_category_time = categories[category]
			slowest_category = category
	
	if(slowest_category_time > 150)  // >7.5 seconds
		report += "- Consider optimizing [slowest_category] systems ([slowest_category_time] ticks)\n"
	
	if(max_phase_ticks > 100)
		report += "- Profile [slowest_phase] for bottlenecks\n"
		report += "- Consider deferring non-critical initialization\n"
	
	report += "\n"
	
	report += "═══════════════════════════════════════════════════════════════\n"
	report += "Report generated at world.time = [world.time]\n"
	
	return report

/**
 * PrintBootDiagnosticReport()
 * Print diagnostic report to world log and return as string
 */
proc/PrintBootDiagnosticReport()
	var/report = GetBootDiagnosticReport()
	world.log << report
	return report

/**
 * GetPhaseMetrics(phase_name)
 * Query metrics for a specific phase
 */
proc/GetPhaseMetrics(phase_name)
	return BOOT_PHASE_METRICS[phase_name]

/**
 * GetBootStatistics()
 * Get quick statistics as associative list
 */
proc/GetBootStatistics()
	var/total_ticks = 0
	var/completed_phases = 0
	
	for(var/phase_name in BOOT_PHASE_METRICS)
		var/datum/boot_phase_metric/metric = BOOT_PHASE_METRICS[phase_name]
		if(metric.status == "complete")
			completed_phases++
			total_ticks += metric.duration
	
	return list(
		"total_phases" = BOOT_PHASE_METRICS.len,
		"completed_phases" = completed_phases,
		"total_ticks" = total_ticks,
		"total_milliseconds" = total_ticks * 5,
		"total_seconds" = round(total_ticks / 20, 0.1)
	)

/**
 * BootTimingAnalyzer_Finalize()
 * Called when world_initialization_complete = TRUE
 */
proc/BootTimingAnalyzer_Finalize()
	boot_timing_complete = TRUE
	world.log << "\[TIMING\] Boot timing analysis complete"
	PrintBootDiagnosticReport()
