// Phase 9: Market Abuse Detection & Permission Analytics
// Adds helper functions for detecting suspicious patterns and permission conflicts

// ============================================================================
// GLOBAL TRACKING VARIABLES
// ============================================================================

var/global/list/transaction_log = list()          // All transactions logged
var/global/list/permission_denials = list()       // All permission denials
var/global/const/MAX_LOG_ENTRIES = 10000          // Prevent unbounded memory growth

// ============================================================================
// MARKET ABUSE DETECTION
// ============================================================================

/**
 * Analyze market transactions for suspicious patterns
 * @param min_transactions - Minimum failed transactions to consider suspicious
 * @return List of suspicious accounts with transaction counts
 * @note Identifies accounts with repeated insufficient funds, stall issues
 */
/proc/AnalyzeMarketSuspiciousActivity(min_transactions = 5)
	var/list/suspicious = list()
	var/list/player_failures = list()
	
	// Count failures by player
	for(var/entry in transaction_log)
		if(istext(entry))
			if(findtext(entry, "FAILED"))
				var/player_name = extract_market_log_field(entry, "player")
				if(player_name)
					if(!player_failures[player_name])
						player_failures[player_name] = 0
					player_failures[player_name]++
	
	// Flag those with threshold violations
	for(var/player_name in player_failures)
		var/count = player_failures[player_name]
		if(count >= min_transactions)
			suspicious[player_name] = list(
				"failed_transactions" = count,
				"percentage" = "N/A"  // Would need total transactions to calculate
			)
	
	return suspicious

/**
 * Get most common failure reasons
 * @return List of error categories with frequencies
 */
/proc/GetMarketFailureAnalysis()
	var/list/failures = list(
		"insufficient_funds" = 0,
		"item_unavailable" = 0,
		"stall_closed" = 0,
		"stall_error" = 0,
		"invalid_data" = 0
	)
	
	for(var/entry in transaction_log)
		if(istext(entry) && findtext(entry, "FAILED"))
			if(findtext(entry, "insufficient_funds"))
				failures["insufficient_funds"]++
			else if(findtext(entry, "item_unavailable"))
				failures["item_unavailable"]++
			else if(findtext(entry, "stall_closed"))
				failures["stall_closed"]++
			else if(findtext(entry, "stall_error"))
				failures["stall_error"]++
			else
				failures["invalid_data"]++
	
	return failures

/**
 * Helper: Extract field from log entry (simple parser)
 */
/proc/extract_market_log_field(log_entry, field_name)
	// Example format: "MARKET TRANSACTION FAILED: PlayerName at 'Stall Name'"
	// Very basic parsing - could be enhanced
	if(field_name == "player")
		var/start = findtext(log_entry, "FAILED: ") + 8
		var/end = findtext(log_entry, " at")
		if(start && end)
			return copytext(log_entry, start, end)
	return null

// ============================================================================
// PERMISSION DENIAL ANALYTICS
// ============================================================================

/**
 * Analyze permission denials for conflict zones
 * @return Deed locations with most denials
 */
/proc/GetMostConflictedDeeds()
	var/list/deed_conflicts = list()
	
	for(var/entry in permission_denials)
		if(istext(entry))
			// Format: "BUILD DENIED: PlayerName at X,Y,Z - DeedName (owner: OwnerName)"
			var/deed_name = extract_denial_field(entry, "deed")
			if(deed_name)
				if(!deed_conflicts[deed_name])
					deed_conflicts[deed_name] = 0
				deed_conflicts[deed_name]++
	
	// Sort by count (descending)
	var/list/sorted = list()
	for(var/deed in deed_conflicts)
		sorted += list(list("deed" = deed, "denials" = deed_conflicts[deed]))
	
	// Simple sort (highest first)
	for(var/i = 1; i <= sorted.len; i++)
		for(var/j = i + 1; j <= sorted.len; j++)
			if(sorted[j]["denials"] > sorted[i]["denials"])
				var/tmp = sorted[i]
				sorted[i] = sorted[j]
				sorted[j] = tmp
	
	return sorted.Copy()  // Return copy to prevent external modification

/**
 * Get permission denial statistics
 * @return Count of each permission type denied
 */
/proc/GetPermissionDenialStats()
	var/list/stats = list(
		"build_denied" = 0,
		"pickup_denied" = 0,
		"drop_denied" = 0
	)
	
	for(var/entry in permission_denials)
		if(istext(entry))
			if(findtext(entry, "BUILD DENIED"))
				stats["build_denied"]++
			else if(findtext(entry, "PICKUP DENIED"))
				stats["pickup_denied"]++
			else if(findtext(entry, "DROP DENIED"))
				stats["drop_denied"]++
	
	return stats

/**
 * Helper: Extract field from denial log entry
 */
/proc/extract_denial_field(log_entry, field_name)
	// Example: "BUILD DENIED: PlayerName at 50,60,1 - DeedName (owner: OwnerName)"
	if(field_name == "deed")
		var/start = findtext(log_entry, "- ") + 2
		var/end = findtext(log_entry, " (owner:", start)
		if(start && end)
			return copytext(log_entry, start, end)
	else if(field_name == "player")
		var/start = findtext(log_entry, "DENIED: ") + 8
		var/end = findtext(log_entry, " at")
		if(start && end)
			return copytext(log_entry, start, end)
	else if(field_name == "owner")
		var/start = findtext(log_entry, "(owner: ") + 8
		var/end = findtext(log_entry, ")", start)
		if(start && end)
			return copytext(log_entry, start, end)
	return null

// ============================================================================
// LOG MANAGEMENT
// ============================================================================

/**
 * Clear old log entries if list exceeds max size
 * Called automatically to prevent unbounded memory growth
 */
/proc/PruneTransactionLogs()
	if(transaction_log.len > MAX_LOG_ENTRIES)
		// Keep most recent entries, remove oldest
		var/excess = transaction_log.len - MAX_LOG_ENTRIES
		for(var/i = 1; i <= excess; i++)
			transaction_log.Remove(1)  // Remove oldest entries

/proc/PrunePermissionLogs()
	if(permission_denials.len > MAX_LOG_ENTRIES)
		// Keep most recent entries, remove oldest
		var/excess = permission_denials.len - MAX_LOG_ENTRIES
		for(var/i = 1; i <= excess; i++)
			permission_denials.Remove(1)  // Remove oldest entries

/**
 * Export analytics to admin console
 * Shows current state of market and permission systems
 */
/proc/ExportSystemAnalytics()
	var/list/analytics = list()
	
	analytics["timestamp"] = world.time
	analytics["transaction_log_size"] = transaction_log.len
	analytics["permission_denial_count"] = permission_denials.len
	
	// Market analytics
	analytics["market_failures"] = GetMarketFailureAnalysis()
	analytics["suspicious_accounts"] = AnalyzeMarketSuspiciousActivity(5)
	
	// Permission analytics
	analytics["permission_stats"] = GetPermissionDenialStats()
	analytics["conflicted_deeds"] = GetMostConflictedDeeds()
	
	return analytics

// ============================================================================
// ADMIN COMMANDS FOR ANALYTICS
// ============================================================================

/mob/players/proc/AdminViewMarketAnalytics()
	// Check if caller has admin privileges (implementation varies)
	// For now, just prevent direct access
	if(!usr || usr.key != "admin")  // Replace with your admin check
		usr << "Access denied"
		return
	
	var/list/analytics = ExportSystemAnalytics()
	
	usr << "=== MARKET ANALYTICS ==="
	usr << "Transaction log size: [analytics["transaction_log_size"]]"
	usr << "Failed transactions by type:"
	for(var/category in analytics["market_failures"])
		usr << "  [category]: [analytics["market_failures"][category]]"
	
	usr << "\n=== PERMISSION ANALYTICS ==="
	usr << "Total denials: [analytics["permission_denial_count"]]"
	var/stats = analytics["permission_stats"]
	usr << "Build denied: [stats["build_denied"]]"
	usr << "Pickup denied: [stats["pickup_denied"]]"
	usr << "Drop denied: [stats["drop_denied"]]"
	
	usr << "\n=== CONFLICTED DEEDS ==="
	for(var/list/deed_info in analytics["conflicted_deeds"])
		if(deed_info["denials"] > 5)
			usr << "[deed_info["deed"]]: [deed_info["denials"]] denials"

