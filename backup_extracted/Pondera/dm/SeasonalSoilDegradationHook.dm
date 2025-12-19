/**
 * SeasonalSoilDegradationHook.dm - Applies soil degradation/recovery on season change
 * 
 * Integrates with time system to automatically process:
 * - Seasonal degradation (nutrient loss from weather)
 * - Natural recovery (decomposition, nitrogen fixing)
 * - Fallow land recovery (rested soil)
 * 
 * Called by TimeSystem.dm on each season change
 */

// ============================================================================
// SEASON CHANGE PROCESSOR
// ============================================================================

/**
 * Process all farmed turfs for seasonal effects
 * Call this when season changes (from DayNight.dm or TimeSystem.dm)
 */
proc/ProcessSeasonalSoilCycle(var/new_season)
	if(!new_season) return FALSE
	
	world.log << "\[SOIL\] Starting seasonal soil cycle for [new_season]"
	
	// This would iterate through all active farm turfs
	// Since turfs are chunk-based, we only process "visited" turfs
	// In a full implementation, this would track "farm turfs" globally
	
	var/processed_count = 0
	var/recovered_count = 0
	
	// For now, this is a framework - actual implementation would:
	// 1. Track which turfs have been farmed (via global registry)
	// 2. Iterate through each farmed turf
	// 3. Apply seasonal degradation/recovery
	// 4. Log results
	
	// Example (when global farm turf registry exists):
	//   if(farmed_turfs && farmed_turfs.len > 0)
	//       for(var/turf/T in farmed_turfs)
	//           ApplySeasonalDegradation(T, new_season)
	//           ApplyNaturalFertilityRecovery(T, new_season)
	//           processed_count++
	
	world.log << "\[SOIL\] Seasonal cycle complete. Processed [processed_count] turfs, recovered [recovered_count]"
	
	return TRUE

/**
 * Register a turf as "farmed" for seasonal tracking
 * Call this when player first plants on a turf
 */
proc/RegisterFarmedTurf(turf/T)
	if(!T) return FALSE
	
	// Initialize soil properties
	InitializeSoilProperties(T)
	
	// Mark as farmed (for future seasonal processing)
	T.vars["is_farmed"] = 1
	T.vars["last_farmed_date"] = world.realtime
	
	return TRUE

/**
 * Check if turf is marked as farmed
 */
proc/IsFarmedTurf(turf/T)
	if(!T) return FALSE
	return T.vars["is_farmed"] || FALSE

// ============================================================================
// INTEGRATION HOOKS
// ============================================================================

/**
 * Hook for TimeSystem.dm - call when season changes
 * Location: In DayNight.dm or TimeSystem.dm's season change function
 * 
 * Example integration:
 * 
 * proc/ChangeSeasonTo(var/new_season)
 *     current_season = new_season
 *     
 *     // Existing season change logic...
 *     // ... 
 *     
 *     // NEW: Apply soil seasonal effects
 *     ProcessSeasonalSoilCycle(new_season)
 */

/**
 * Hook for plant.dm - call when crop is planted
 * Location: In plant planting code
 * 
 * Example integration:
 * 
 * /obj/Plants/proc/Plant(mob/players/farmer)
 *     RegisterFarmedTurf(src.loc)  // Register this turf as farmed
 *     // ... rest of planting code
 */

/**
 * Hook for fallow mechanics - player can set land to rest
 * Location: Soil status checker or farm management UI
 * 
 * Example integration:
 * 
 * /proc/SetTurfToFallow(turf/T, var/duration)
 *     T.vars["fallow_until"] = world.time + duration
 *     world << "Land set to fallow until [time_remaining] ticks"
 * 
 * Then on next plant attempt:
 * 
 *     if(T.vars["fallow_until"] > world.time)
 *         ApplyFallowRecovery(T)
 *         T.vars["fallow_until"] = 0
 */

// ============================================================================
// PLAYER-FACING SOIL STATUS COMMAND
// ============================================================================

/**
 * Player-facing soil status command
 * Usage: /soil_status_check
 */
proc/PlayerShowSoilStatus(mob/players/player)
	if(!player) return
	
	var/turf/T = player.loc
	if(!istype(T, /turf))
		player << "You must be standing on soil to check its status."
		return
	
	// Initialize properties if needed
	InitializeSoilProperties(T)
	
	var/report = "=== SOIL STATUS REPORT ===\n"
	report += "Location: [T.x], [T.y], [T.z]\n\n"
	
	// Fertility
	var/fertility = GetSoilFertility(T)
	var/fertility_pct = round((fertility / 200) * 100)
	report += "Fertility: [fertility]/200 ([fertility_pct]%)\n"
	
	// pH
	var/ph = GetSoilPH(T)
	var/ph_status = "Neutral"
	if(ph < 6.5) ph_status = "Acidic"
	else if(ph > 7.5) ph_status = "Alkaline"
	report += "pH: [round(ph, 0.1)] ([ph_status])\n"
	
	// Nutrients
	var/n = GetSoilNutrient(T, "nitrogen")
	var/p = GetSoilNutrient(T, "phosphorus")
	var/k = GetSoilNutrient(T, "potassium")
	report += "\nMacronutrients:\n"
	report += "  Nitrogen (N): [n]/100\n"
	report += "  Phosphorus (P): [p]/100\n"
	report += "  Potassium (K): [k]/100\n"
	
	// Moisture
	var/moisture = GetSoilMoisture(T)
	report += "\nMoisture: [moisture]%\n"
	
	// Crop history
	var/last_crop = GetLastCrop(T)
	if(last_crop && last_crop != "none")
		report += "Last Crop: [last_crop]\n"
		var/rotation_mod = GetCropRotationModifier(T, last_crop)
		if(rotation_mod > 1.0)
			report += "  → Rotation bonus ready (+[round((rotation_mod-1)*100)]%)\n"
		else if(rotation_mod < 1.0)
			report += "  → Monoculture penalty ([round((1-rotation_mod)*100)]%)\n"
	
	// Health
	var/health = GetSoilHealthStatus(T)
	report += "\nOverall Health: [health]\n"
	
	// Recommendations
	report += "\n=== RECOMMENDATIONS ===\n"
	if(fertility < 100)
		report += "• Fertility is low - apply compost to restore\n"
	if(ph < 6.5)
		report += "• Soil is too acidic - lime (compost) will help\n"
	if(ph > 7.5)
		report += "• Soil is too alkaline - sulfur treatments needed\n"
	if(n < 30 || p < 30 || k < 30)
		report += "• Nutrients are depleted - use specialized compost\n"
	if(last_crop && last_crop != "none" && GetCropRotationModifier(T, last_crop) < 1.0)
		report += "• Plant something different next season for rotation bonus\n"
	
	player << report

// ============================================================================
// SOIL STATUS ITEM (Optional)
// ============================================================================

/**
 * Soil Test Kit item - craftable item that players can use
 * to get detailed soil information
 * 
 * Could be added to CookingSystem.dm or crafting system
 */
/obj/SoilTestKit
	name = "Soil Test Kit"
	desc = "A collection of tools and reagents for testing soil quality."
	icon = 'dmi/64/creation.dmi'
	icon_state = "kit"
	
/obj/SoilTestKit/Click()
	if(!usr) return
	PlayerShowSoilStatus(usr)

// ============================================================================
// ADMIN COMMAND SUPPORT
// ============================================================================

/**
 * Admin: Set turf to fallow (rest mode)
 * Usage: /fallow_land (turf area)
 */
/proc/AdminSetFallow(turf/T, var/duration_days = 60)
	if(!T) return FALSE
	
	InitializeSoilProperties(T)
	T.vars["fallow_until"] = world.time + (duration_days * 480)  // 480 ticks per day
	
	return TRUE

/**
 * Admin: Force seasonal processing
 * Usage: /process_soil_cycle spring|summer|autumn|winter
 */
/proc/AdminProcessSoilCycle(var/season)
	return ProcessSeasonalSoilCycle(season)

/**
 * Admin: Check farmed turf count
 * Usage: /check_farmed_turfs
 */
/proc/AdminCheckFarmedTurfs()
	var/count = 0
	// Would count turfs with is_farmed flag set
	// Requires global tracking of farmed turfs
	return count
