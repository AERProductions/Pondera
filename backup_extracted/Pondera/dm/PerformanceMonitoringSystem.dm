/// ============================================================================
/// PERFORMANCE MONITORING SYSTEM
/// Tracks frame times, system load, memory usage, and provides diagnostic UI.
/// Designed to identify bottlenecks in complex multi-system gameworld.
///
/// Created: 12-11-25 1:05AM
/// ============================================================================

var/datum/performance_monitor/global_perf_monitor

/proc/GetPerformanceMonitor()
	if(!global_perf_monitor)
		global_perf_monitor = new /datum/performance_monitor()
	return global_perf_monitor

/// ============================================================================
/// MAIN PERFORMANCE MONITOR
/// ============================================================================

/datum/performance_monitor
	var
		list/frame_times = list()  // Time (ms) for each world tick
		list/system_loads = list() // Load per system (% of frame)
		list/memory_snapshots = list()
		
		current_frame_start = 0
		frame_count = 0
		avg_frame_time = 0
		peak_frame_time = 0
		
		// Thresholds for warnings
		frame_time_warning = 30     // ms - warn if frame > 30ms (1.2x normal 25ms)
		frame_time_critical = 40    // ms - critical if > 40ms (1.6x normal)
		
		memory_warning_mb = 512     // MB
		memory_critical_mb = 1024   // MB
		
		enabled = TRUE

/datum/performance_monitor/proc/StartFrameTimer()
	if(!enabled) return
	current_frame_start = world.timeofday

/datum/performance_monitor/proc/EndFrameTimer()
	if(!enabled) return
	
	var/frame_duration = world.timeofday - current_frame_start
	frame_times += frame_duration
	frame_count++
	
	// Keep only last 60 frame samples
	if(length(frame_times) > 60)
		frame_times.Cut(1, 2)
	
	// Calculate rolling average
	avg_frame_time = 0
	for(var/t in frame_times)
		avg_frame_time += t
	avg_frame_time /= length(frame_times)
	
	// Track peak
	if(frame_duration > peak_frame_time)
		peak_frame_time = frame_duration
	
	// Warn if threshold exceeded
	if(frame_duration > frame_time_critical)
		LogPerformanceWarning("CRITICAL: Frame time [frame_duration]ms exceeded critical threshold!")
	else if(frame_duration > frame_time_warning)
		LogPerformanceWarning("WARNING: Frame time [frame_duration]ms exceeded warning threshold")

/datum/performance_monitor/proc/LogSystemLoad(system_name, time_ms)
	/// Track time spent in a specific system
	if(!enabled) return
	
	system_loads[system_name] = time_ms
	
	// Calculate % of frame
	var/frame_percent = (time_ms / (world.fps * 1000)) * 100
	if(frame_percent > 10)  // Warn if system uses >10% of frame
		LogPerformanceWarning("[system_name] using [frame_percent]% of frame time")

/datum/performance_monitor/proc/LogPerformanceWarning(message)
	/// Log warning with timestamp
	world << "<span style='color: #ff6b6b;'>[message]</span>"

/datum/performance_monitor/proc/GetFrameTimeReport()
	/// HTML report of frame timing statistics
	var/html = "<html><head><title>Frame Time Report</title><style>"
	html += "body { background: #0a0a0a; color: #ddd; font-family: monospace; }"
	html += ".frame-ok { color: #81c784; }"
	html += ".frame-warn { color: #ffb74d; }"
	html += ".frame-crit { color: #ff6b6b; }"
	html += ".chart { background: #1a1a1a; padding: 10px; margin: 10px 0; }"
	html += "</style></head><body><h1>Frame Time Report</h1>"
	
	html += "<p>Frames Sampled: [frame_count]</p>"
	html += "<p>Average Frame Time: <span class='"
	if(avg_frame_time > frame_time_critical)
		html += "frame-crit"
	else if(avg_frame_time > frame_time_warning)
		html += "frame-warn"
	else
		html += "frame-ok"
	html += "'>[avg_frame_time]ms</span></p>"
	
	html += "<p>Peak Frame Time: [peak_frame_time]ms</p>"
	html += "<p>Target Frame Time: [1000 / world.fps]ms (TPS: [world.fps])</p>"
	
	// Frame time chart
	html += "<div class='chart'>"
	for(var/i = 1; i <= length(frame_times); i++)
		var/t = frame_times[i]
		var/height = (t / peak_frame_time) * 100
		var/color = "#81c784"
		if(t > frame_time_critical) color = "#ff6b6b"
		else if(t > frame_time_warning) color = "#ffb74d"
		html += "<div style='display: inline-block; width: 4px; height: [height]%; background: [color]; margin: 1px;'></div>"
	html += "</div>"
	
	html += "</body></html>"
	return html

/datum/performance_monitor/proc/GetSystemLoadReport()
	/// HTML report of per-system load
	var/html = "<html><head><title>System Load Report</title><style>"
	html += "body { background: #0a0a0a; color: #ddd; font-family: monospace; }"
	html += "table { border-collapse: collapse; }"
	html += "th, td { border: 1px solid #444; padding: 8px; text-align: left; }"
	html += ".load-ok { color: #81c784; }"
	html += ".load-warn { color: #ffb74d; }"
	html += ".load-crit { color: #ff6b6b; }"
	html += "</style></head><body><h1>System Load Report</h1>"
	html += "<table><tr><th>System</th><th>Time (ms)</th><th>% of Frame</th><th>Status</th></tr>"
	
	for(var/system in system_loads)
		var/t = system_loads[system]
		var/percent = (t / (world.fps * 1000)) * 100
		var/status_class = "load-ok"
		var/status = "OK"
		
		if(percent > 20)
			status_class = "load-crit"
			status = "CRITICAL"
		else if(percent > 10)
			status_class = "load-warn"
			status = "WARNING"
		
		html += "<tr><td>[system]</td><td>[t]</td><td class='[status_class]'>[percent]%</td><td class='[status_class]'>[status]</td></tr>"
	
	html += "</table></body></html>"
	return html

/datum/performance_monitor/proc/GetMemoryReport()
	/// HTML report of memory usage
	var/html = "<html><head><title>Memory Report</title><style>"
	html += "body { background: #0a0a0a; color: #ddd; font-family: monospace; }"
	html += ".mem-ok { color: #81c784; }"
	html += ".mem-warn { color: #ffb74d; }"
	html += ".mem-crit { color: #ff6b6b; }"
	html += ".meter { background: #1a1a1a; border: 1px solid #444; height: 20px; }"
	html += ".meter-fill { background: #81c784; height: 100%; }"
	html += "</style></head><body><h1>Memory Report</h1>"
	
	var/mob_count = 0
	for(var/mob/m in world.contents) mob_count++
	
	html += "<p>Current Objects: [length(world.contents)]</p>"
	html += "<p>Current Mobs: [mob_count]</p>"
	
	memory_snapshots += list(
		"timestamp" = world.time,
		"objects" = length(world.contents),
		"mobs" = mob_count
	)
	
	// Keep only last 10 snapshots
	if(length(memory_snapshots) > 10)
		memory_snapshots.Cut(1, 2)
	
	html += "<h2>Memory Trend (last 10 snapshots)</h2>"
	html += "<table><tr><th>Time</th><th>Objects</th><th>Mobs</th></tr>"
	for(var/snapshot in memory_snapshots)
		html += "<tr><td>[snapshot["timestamp"]]</td><td>[snapshot["objects"]]</td><td>[snapshot["mobs"]]</td></tr>"
	html += "</table>"
	
	html += "</body></html>"
	return html

/datum/performance_monitor/proc/DisplayFrameReport(mob/viewer)
	if(viewer && viewer.client)
		viewer.client << browse(GetFrameTimeReport(), "window=frame_report;size=600x400")

/datum/performance_monitor/proc/DisplaySystemLoadReport(mob/viewer)
	if(viewer && viewer.client)
		viewer.client << browse(GetSystemLoadReport(), "window=system_load;size=600x500")

/datum/performance_monitor/proc/DisplayMemoryReport(mob/viewer)
	if(viewer && viewer.client)
		viewer.client << browse(GetMemoryReport(), "window=memory_report;size=600x400")

/// ============================================================================
/// INTEGRATION WITH WORLD TICK
/// ============================================================================

/world/proc/InitializePerformanceMonitoring()
	/// Called from InitializationManager.dm Phase 5
	var/datum/performance_monitor/pm = GetPerformanceMonitor()
	if(pm)
		world << "Performance Monitoring System initialized"
		RegisterInitComplete("PerformanceMonitoring")

/world/proc/PerformanceTickStart()
	/// Called at start of each game tick (from _debugtimer.dm)
	var/datum/performance_monitor/pm = GetPerformanceMonitor()
	if(pm)
		pm.StartFrameTimer()

/world/proc/PerformanceTickEnd()
	/// Called at end of each game tick (from _debugtimer.dm)
	var/datum/performance_monitor/pm = GetPerformanceMonitor()
	if(pm)
		pm.EndFrameTimer()

/// ============================================================================
/// ADMIN COMMANDS
/// ============================================================================

/mob/players/verb/PerfReport()
	set category = "Debug"
	set name = "Performance Report"
	
	var/datum/performance_monitor/pm = GetPerformanceMonitor()
	if(pm)
		pm.DisplayFrameReport(src)

/mob/players/verb/SystemLoadReport()
	set category = "Debug"
	set name = "System Load Report"
	
	var/datum/performance_monitor/pm = GetPerformanceMonitor()
	if(pm)
		pm.DisplaySystemLoadReport(src)

/mob/players/verb/MemoryReport()
	set category = "Debug"
	set name = "Memory Report"
	
	var/datum/performance_monitor/pm = GetPerformanceMonitor()
	if(pm)
		pm.DisplayMemoryReport(src)

/// ============================================================================
/// END PERFORMANCE MONITORING SYSTEM
/// ============================================================================
