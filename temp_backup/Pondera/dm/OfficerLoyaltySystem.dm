// OfficerLoyaltySystem.dm - Phase 34: Officer Loyalty & Defection Mechanics
// Tracks officer morale, loyalty decay, and defection risk during battles

#define LOYALTY_DECAY_RATE 0.5      // -loyalty per tick of inactivity
#define LOYALTY_LOSS_DEFEAT 15      // -loyalty when officer's garrison loses
#define LOYALTY_GAIN_VICTORY 10     // +loyalty when officer's garrison wins
#define LOYALTY_LOSS_ABUSE 20       // -loyalty for harsh treatment
#define LOYALTY_LOSS_BRIBE 25       // Enemy bribe attempt
#define LOYALTY_DEFECT_THRESHOLD 50 // <50 = high defection risk
#define LOYALTY_DEFECT_CHANCE 0.5   // 50% chance to defect if <50 loyalty + enemy nearby

// =============================================================================
// Loyalty Manager Datum
// =============================================================================

/datum/loyalty_manager
	var
		list/officer_loyalty_history = list()  // Track loyalty changes per officer
		list/bribe_attempts = list()           // Track NPC bribe offers

/datum/loyalty_manager/New()
	officer_loyalty_history = list()
	bribe_attempts = list()

// =============================================================================
// Global Loyalty System
// =============================================================================

var
	datum/loyalty_manager/global_loyalty_system

/proc/InitializeOfficerLoyalty()
	if(global_loyalty_system)
		return
	
	global_loyalty_system = new /datum/loyalty_manager()
	
	// Start background systems
	spawn(0) StartLoyaltyDecayLoop()
	
	RegisterInitComplete("officer_loyalty")

/proc/GetLoyaltyManager()
	return global_loyalty_system

// =============================================================================
// Loyalty Modification Procs
// =============================================================================

/**
 * ModifyOfficerLoyalty(officer_id, amount, reason)
 * Change officer loyalty and log the reason
 */
/proc/ModifyOfficerLoyalty(officer_id, amount, reason="")
	var/datum/elite_officer/officer = officers_registry[officer_id]
	if(!officer)
		return FALSE
	
	var/old_loyalty = officer.loyalty
	officer.loyalty += amount
	officer.loyalty = clamp(officer.loyalty, 0, 100)  // Keep in 0-100 range
	
	// Log the change
	if(global_loyalty_system)
		global_loyalty_system.officer_loyalty_history["officer_[officer_id]_[world.time]"] = list(
			"officer_id" = officer_id,
			"old_loyalty" = old_loyalty,
			"new_loyalty" = officer.loyalty,
			"change" = amount,
			"reason" = reason,
			"timestamp" = world.time
		)
	
	return TRUE

/**
 * ProcessBattleLoyalty(datum/elite_officer/officer, victory)
 * Update loyalty based on battle outcome
 */
/proc/ProcessBattleLoyalty(datum/elite_officer/officer, victory=FALSE)
	if(!officer)
		return
	
	if(victory)
		ModifyOfficerLoyalty(officer.officer_id, LOYALTY_GAIN_VICTORY, "Battle victory")
	else
		ModifyOfficerLoyalty(officer.officer_id, LOYALTY_LOSS_DEFEAT, "Battle defeat")

/**
 * ApplyBribeAttempt(datum/elite_officer/officer, briber_name)
 * Enemy attempts to turn officer
 */
/proc/ApplyBribeAttempt(datum/elite_officer/officer, briber_name)
	if(!officer)
		return FALSE
	
	// Reduce loyalty slightly
	ModifyOfficerLoyalty(officer.officer_id, -LOYALTY_LOSS_BRIBE, "Enemy bribe attempt from [briber_name]")
	
	// Log bribe attempt
	if(global_loyalty_system)
		global_loyalty_system.bribe_attempts["bribe_[officer.officer_id]_[world.time]"] = list(
			"target_officer" = officer.officer_id,
			"briber" = briber_name,
			"loyalty_before" = officer.loyalty + LOYALTY_LOSS_BRIBE,
			"loyalty_after" = officer.loyalty,
			"timestamp" = world.time
		)
	
	return TRUE

/**
 * ProcessOfficerDefection(datum/elite_officer/officer, enemy_faction)
 * Officer switches allegiance (loyalty = 0)
 */
/proc/ProcessOfficerDefection(datum/elite_officer/officer, enemy_faction)
	if(!officer)
		return FALSE
	
	// Mark as defected
	officer.loyalty = 0  // Complete loss of loyalty
	
	// Log defection
	world << "<b><font color=#FF0000>⚔ Officer [officer.officer_name || officer.officer_id] defected to [enemy_faction]!</font></b>"
	
	if(global_loyalty_system)
		global_loyalty_system.officer_loyalty_history["defect_[officer.officer_id]_[world.time]"] = list(
			"officer_id" = officer.officer_id,
			"defected_to" = enemy_faction,
			"final_loyalty" = 0,
			"reason" = "Defection in battle",
			"timestamp" = world.time
		)
	
	return TRUE

// =============================================================================
// Loyalty Decay System (passive loss over time)
// =============================================================================

/**
 * StartLoyaltyDecayLoop()
 * Background loop that slowly decays officer loyalty
 */
/proc/StartLoyaltyDecayLoop()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(3000)  // Every 150 seconds (game time)
		
		for(var/datum/elite_officer/officer in officers_registry)
			if(!officer)
				continue
			
			// Officers waiting in recruitment don't decay
			if(!officer.is_recruited)
				continue
			
			// Officers in active battles don't decay
			if(officer.battles_fought > 0)
				continue
			
			// Apply passive decay
			ModifyOfficerLoyalty(officer.officer_id, -LOYALTY_DECAY_RATE, "Passive decay (inactivity)")

// =============================================================================
// Loyalty Display & Reporting
// =============================================================================

/**
 * GetOfficerLoyaltyStatus(officer_id)
 * Return text description of loyalty level
 */
/proc/GetOfficerLoyaltyStatus(officer_id)
	var/datum/elite_officer/officer = officers_registry[officer_id]
	if(!officer)
		return "Unknown"
	
	if(officer.loyalty >= 90)
		return "Legendary Loyalty"
	if(officer.loyalty >= 75)
		return "Trusted"
	if(officer.loyalty >= 60)
		return "Loyal"
	if(officer.loyalty >= LOYALTY_DEFECT_THRESHOLD)
		return "Uncertain"
	if(officer.loyalty >= 30)
		return "Unreliable"
	if(officer.loyalty > 0)
		return "On the Brink"
	else
		return "Defected"

/**
 * GetOfficerLoyaltyColor(loyalty)
 * Return color code for HUD display
 */
/proc/GetOfficerLoyaltyColor(loyalty)
	if(loyalty >= 90)
		return "#00FF00"  // Green
	if(loyalty >= 75)
		return "#00CC00"
	if(loyalty >= 60)
		return "#FFFF00"  // Yellow
	if(loyalty >= LOYALTY_DEFECT_THRESHOLD)
		return "#FF8800"  // Orange
	if(loyalty >= 30)
		return "#FF4400"
	if(loyalty > 0)
		return "#FF0000"  // Red
	else
		return "#660000"  // Dark red (defected)

/**
 * DisplayOfficerLoyaltyReport(mob/M, territory_id)
 * Show all officers' loyalty status for a territory
 */
/proc/DisplayOfficerLoyaltyReport(mob/M, territory_id)
	if(!M || !territory_id)
		return
	
	var/list/officers = territory_officers[territory_id]
	if(!officers || officers.len == 0)
		M << "No officers in this territory."
		return
	
	M << "\n<b>═══════════════════════════════════</b>"
	M << "<b>OFFICER LOYALTY REPORT</b>"
	M << "<b>═══════════════════════════════════</b>\n"
	
	for(var/datum/elite_officer/officer in officers)
		var/color = GetOfficerLoyaltyColor(officer.loyalty)
		var/status = GetOfficerLoyaltyStatus(officer.officer_id)
		
		M << "<font color=[color]>[officer.officer_name || officer.officer_id]</font>"
		M << " | Level [officer.level] | Loyalty: [officer.loyalty]% ([status])"
		M << " | Battles: [officer.battles_fought] | Kills: [officer.kills]"
		M << ""
	
	M << "\n<b>═══════════════════════════════════</b>\n"

/**
 * DisplayLoyaltyHistory(mob/M, officer_id, max_entries)
 * Show recent loyalty changes for an officer
 */
/proc/DisplayLoyaltyHistory(mob/M, officer_id, max_entries=20)
	if(!M || !officer_id)
		return
	
	var/count = 0
	M << "\n<b>Loyalty History for Officer [officer_id]:</b>"
	
	if(global_loyalty_system)
		for(var/entry_id in global_loyalty_system.officer_loyalty_history)
			var/entry = global_loyalty_system.officer_loyalty_history[entry_id]
			if(entry["officer_id"] != officer_id)
				continue
			
			var/direction = entry["change"] > 0 ? "+" : ""
			M << "[entry["reason"]]: [direction][entry["change"]] ([entry["old_loyalty"]] → [entry["new_loyalty"]])"
			
			count++
			if(count >= max_entries)
				break
	
	if(count == 0)
		M << "No history found."

// =============================================================================
// Loyalty & Pay System Integration
// =============================================================================

/**
 * BoostLoyalty(officer_id, boost_type, amount)
 * Increase loyalty through specific actions
 */
/proc/BoostLoyalty(officer_id, boost_type, amount=5)
	var/reason = ""
	if(boost_type == "pay_raise")
		reason = "Pay raise granted"
	else if(boost_type == "celebration")
		reason = "Victory celebration held"
	else if(boost_type == "promotion")
		reason = "Promoted to higher rank"
	else if(boost_type == "medal")
		reason = "Medal of honor awarded"
	else if(boost_type == "equipment_upgrade")
		reason = "Equipment upgraded"
	else
		reason = boost_type
	
	ModifyOfficerLoyalty(officer_id, amount, reason)

/**
 * PunishOfficer(officer_id, punishment_type, amount)
 * Decrease loyalty through negative actions
 */
/proc/PunishOfficer(officer_id, punishment_type, amount=10)
	var/reason = ""
	if(punishment_type == "harsh_orders")
		reason = "Harsh treatment received"
	else if(punishment_type == "pay_cut")
		reason = "Salary reduced"
	else if(punishment_type == "overworked")
		reason = "Excessive deployments"
	else if(punishment_type == "public_humiliation")
		reason = "Publicly humiliated"
	else if(punishment_type == "failed_mission")
		reason = "Failed critical mission"
	else
		reason = punishment_type
	
	ModifyOfficerLoyalty(officer_id, -amount, reason)

// =============================================================================
// Defection Prevention & Recovery
// =============================================================================

/**
 * OfferLoyaltyRecovery(officer_id)
 * Special action to restore loyalty (costs resources)
 */
/proc/OfferLoyaltyRecovery(officer_id, lucre_cost=200)
	var/datum/elite_officer/officer = officers_registry[officer_id]
	if(!officer)
		return FALSE
	
	// Cost scales with defection risk
	if(officer.loyalty < LOYALTY_DEFECT_THRESHOLD)
		lucre_cost = lucre_cost * (1.5)  // More expensive to save defectors
	
	// In full implementation, would check treasury
	// For now, just restore loyalty
	ModifyOfficerLoyalty(officer_id, 30, "Loyalty recovery intervention (cost: [lucre_cost] Lucre)")
	
	return TRUE

/**
 * CheckAndHandleDefections(territory_id, battle_outcome)
 * During siege, check for defections
 */
/proc/CheckAndHandleDefections(territory_id, battle_outcome)
	var/list/officers = territory_officers[territory_id]
	if(!officers || officers.len == 0)
		return list()  // No defections if no officers
	
	var/list/defected = list()
	
	for(var/datum/elite_officer/officer in officers)
		if(!officer)
			continue
		
		// Process battle loyalty first
		ProcessBattleLoyalty(officer, battle_outcome)
		
		// Then check for defection using existing proc from EliteOfficersSystem
		// CheckOfficerDefection returns 1 if defection occurs
		if(CheckOfficerDefection(officer))
			ProcessOfficerDefection(officer, "Enemy forces")
			defected += officer
	
	return defected

// =============================================================================
// Loyalty Verb for Testing/Admin
// =============================================================================

/mob/players/verb/CheckOfficerLoyalty()
	set name = "Officer Loyalty Report"
	set category = "Territory"
	
	var/territory_id = GetPlayerPrimaryTerritory(src)
	if(!territory_id)
		src << "You don't own a territory."
		return
	
	DisplayOfficerLoyaltyReport(src, territory_id)
