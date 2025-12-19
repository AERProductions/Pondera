// OfficerGarrisonVisualizationUI.dm - Phase 34B: Officer Garrison Visualization
// Real-time battle display showing garrison combat, defections, and officer performance

#define OGV_UPDATE_INTERVAL 5  // Update UI every 5 ticks
#define OGV_MAX_ROUNDS 20      // Max battle rounds to display
#define OGV_LOG_SIZE 100       // Keep last 100 battle events

// =============================================================================
// OGV Battle Event Logger
// =============================================================================

/datum/ogv_battle_event
	var
		timestamp
		event_type      // "round_start", "damage", "death", "defection", "victory", "defeat"
		actor           // Who performed action (officer/unit name)
		target          // Who received action
		damage_amount
		round_number
		description

/datum/ogv_battle_event/New(type, actor_name, target_name, damage=0, round=0, desc="")
	src.timestamp = world.time
	src.event_type = type
	src.actor = actor_name
	src.target = target_name
	src.damage_amount = damage
	src.round_number = round
	src.description = desc

// =============================================================================
// OGV Battle Session Manager
// =============================================================================

/datum/ogv_battle_session
	var
		// Identifiers
		battle_id
		attacking_territory_id
		defending_territory_id
		start_time
		end_time
		
		// Participants
		list/attacking_officers = list()
		list/defending_officers = list()
		attacking_troops_count = 0
		defending_troops_count = 0
		
		// Battle state
		current_round = 0
		is_active = 1
		attacking_won = 0
		
		// Event log
		list/battle_events = list()
		
		// Viewers (who can see this battle)
		list/viewers = list()

/datum/ogv_battle_session/New(attacker_id, defender_id)
	src.battle_id = "battle_[world.time]_[rand(1,99999)]"
	src.attacking_territory_id = attacker_id
	src.defending_territory_id = defender_id
	src.start_time = world.time

/datum/ogv_battle_session/proc/AddEvent(event_type, actor, target, damage=0, desc="")
	if(battle_events.len >= OGV_LOG_SIZE)
		battle_events = battle_events.Copy(2)  // Remove oldest event
	
	var/datum/ogv_battle_event/event = new(event_type, actor, target, damage, current_round, desc)
	battle_events += event
	
	// Notify all viewers of new event
	UpdateAllViewers()

/datum/ogv_battle_session/proc/AddViewer(mob/M)
	if(M && !(M in viewers))
		viewers += M

/datum/ogv_battle_session/proc/RemoveViewer(mob/M)
	viewers -= M

/datum/ogv_battle_session/proc/UpdateAllViewers()
	for(var/mob/M in viewers)
		if(M && M.client)
			ShowOGVBattle(M, src)

/datum/ogv_battle_session/proc/EndBattle(attacking_won=0)
	is_active = 0
	attacking_won = attacking_won
	end_time = world.time
	
	// Log final outcome
	if(attacking_won)
		AddEvent("victory", "Attacking Force", "Defending Force", 0, "Attackers victorious")
	else
		AddEvent("defeat", "Defending Force", "Attacking Force", 0, "Defenders held the territory")
	
	UpdateAllViewers()

// =============================================================================
// Global OGV System
// =============================================================================

var
	list/active_battles = list()           // /datum/ogv_battle_session objects
	list/battle_viewers = list()           // mob -> battle_id
	list/recent_battle_history = list()    // Finished battles

/proc/InitializeOGVSystem()
	if(active_battles == null)
		active_battles = list()
	if(recent_battle_history == null)
		recent_battle_history = list()

/proc/CreateBattleSession(attacking_territory_id, defending_territory_id)
	var/datum/ogv_battle_session/session = new(attacking_territory_id, defending_territory_id)
	active_battles[session.battle_id] = session
	return session

/proc/GetActiveBattle(battle_id)
	return active_battles[battle_id]

/proc/GetPlayerActiveBattle(mob/M)
	if(!M)
		return null
	
	var/battle_id = battle_viewers[M]
	if(battle_id)
		return active_battles[battle_id]
	return null

/proc/ViewBattle(mob/M, datum/ogv_battle_session/battle)
	if(!M || !battle)
		return
	
	battle.AddViewer(M)
	battle_viewers[M] = battle.battle_id
	ShowOGVBattle(M, battle)

/proc/StopViewingBattle(mob/M)
	if(!M)
		return
	
	var/battle_id = battle_viewers[M]
	if(battle_id)
		var/datum/ogv_battle_session/battle = active_battles[battle_id]
		if(battle)
			battle.RemoveViewer(M)
	
	battle_viewers -= M

// =============================================================================
// OGV UI Display
// =============================================================================

/proc/ShowOGVBattle(mob/M, datum/ogv_battle_session/battle)
	if(!M || !battle)
		return
	
	var/html = ""
	var/attacker_count = 0
	var/defender_count = 0
	var/has_attackers = 0
	var/has_defenders = 0
	
	if(battle.attacking_officers)
		attacker_count = battle.attacking_officers.len
	if(battle.defending_officers)
		defender_count = battle.defending_officers.len
	
	has_attackers = attacker_count > 0
	has_defenders = defender_count > 0
	
	html = "<html><head><title>Battle: [battle.battle_id]</title>"
	html += "<style>"
	html += "body { font-family: Arial, sans-serif; font-size: 12px; color: #FFF; background: #000; margin: 5px; }"
	html += ".header { font-weight: bold; font-size: 16px; border-bottom: 2px solid #FFF; margin-bottom: 10px; }"
	html += ".status { display: flex; justify-content: space-between; margin-bottom: 10px; }"
	html += ".territory { flex: 1; padding: 5px; border: 1px solid #666; }"
	html += ".attacking { border-left: 3px solid #FF4444; }"
	html += ".defending { border-left: 3px solid #44FF44; }"
	html += ".round-info { font-weight: bold; color: #FFFF00; margin: 5px 0; }"
	html += ".event { padding: 3px 5px; margin: 2px 0; border-left: 2px solid #666; font-size: 11px; }"
	html += ".event-damage { border-left-color: #FF6666; color: #FF8888; }"
	html += ".event-death { border-left-color: #FF0000; color: #FF4444; font-weight: bold; }"
	html += ".event-defection { border-left-color: #FF00FF; color: #FF88FF; font-weight: bold; }"
	html += ".event-victory { border-left-color: #00FF00; color: #88FF88; font-weight: bold; }"
	html += ".event-defeat { border-left-color: #FF8800; color: #FFAA44; font-weight: bold; }"
	html += ".log-container { border: 1px solid #666; max-height: 400px; overflow-y: auto; padding: 5px; }"
	html += ".footer { margin-top: 10px; text-align: center; font-size: 10px; }"
	html += ".inactive { opacity: 0.5; }"
	html += "</style>"
	html += "</head><body>"
	
	// Header
	html += "<div class='header'>⚔ GARRISON BATTLE VISUALIZATION ⚔</div>"
	
	// Status section
	html += "<div class='status'>"
	html += "<div class='territory attacking'>"
	html += "<b>ATTACKING FORCE</b><br>"
	html += "Territory: [battle.attacking_territory_id]<br>"
	html += "Officers: [attacker_count]<br>"
	html += "Troops: [battle.attacking_troops_count]"
	html += "</div>"
	
	html += "<div class='territory defending'>"
	html += "<b>DEFENDING FORCE</b><br>"
	html += "Territory: [battle.defending_territory_id]<br>"
	html += "Officers: [defender_count]<br>"
	html += "Troops: [battle.defending_troops_count]"
	html += "</div>"
	html += "</div>"
	
	// Round and status info
	html += "<div class='round-info'>"
	html += "Round: [battle.current_round] / [OGV_MAX_ROUNDS]"
	if(battle.is_active)
		html += " <span style='color: #FF0000;'>● ACTIVE</span>"
	else if(battle.attacking_won)
		html += " <span style='color: #FF4444;'>✗ ATTACKERS WON</span>"
	else
		html += " <span style='color: #44FF44;'>✓ DEFENDERS HELD</span>"
	html += "</div>"
	
	// Battle log
	html += "<div class='log-container'>"
	html += "<div style='font-weight: bold; border-bottom: 1px solid #666; margin-bottom: 5px;'>Battle Log:</div>"
	
	if(battle.battle_events.len == 0)
		html += "<div class='event'>Battle starting...</div>"
	else
		for(var/datum/ogv_battle_event/event in battle.battle_events)
			var/event_class = "event"
			var/event_text = ""
			
			switch(event.event_type)
				if("damage")
					event_class = "event event-damage"
					event_text = "[event.actor] attacks [event.target] for [event.damage_amount] damage"
				if("death")
					event_class = "event event-death"
					event_text = "💀 [event.target] DEFEATED"
				if("defection")
					event_class = "event event-defection"
					event_text = "⚡ [event.actor] DEFECTED to enemy forces!"
				if("round_start")
					event_class = "event"
					event_text = "<b>--- Round [event.round_number] Start ---</b>"
				if("victory")
					event_class = "event event-victory"
					event_text = "✓ [event.description]"
				if("defeat")
					event_class = "event event-defeat"
					event_text = "✗ [event.description]"
				else
					event_class = "event"
					event_text = event.description
			
			html += "<div class='[event_class]'>[event_text]</div>"
	
	html += "</div>"
	
	// Officer details
	if(has_attackers || has_defenders)
		html += "<div style='margin-top: 10px; border-top: 1px solid #666; padding-top: 5px;'>"
		html += "<b>OFFICER STATUS:</b><br>"
		
		if(has_attackers)
			html += "<span style='color: #FF4444;'>Attacking:</span> "
			for(var/datum/elite_officer/officer in battle.attacking_officers)
				html += "[officer.officer_name || officer.officer_id] (L[officer.level]) "
			html += "<br>"
		
		if(has_defenders)
			html += "<span style='color: #44FF44;'>Defending:</span> "
			for(var/datum/elite_officer/officer in battle.defending_officers)
				html += "[officer.officer_name || officer.officer_id] (L[officer.level]) "
			html += "<br>"
		
		html += "</div>"
	
	// Footer
	html += "<div class='footer'>"
	html += "Last updated: [worldtime2text(world.time)]<br>"
	html += "<a href='?src=\ref[M];action=refresh_ogv'>Refresh</a> | "
	html += "<a href='?src=\ref[M];action=close_ogv'>Close</a>"
	html += "</div>"
	
	html += "</body></html>"
	
	M << browse(html, "window=ogv_battle;size=600x700")

// =============================================================================
// Battle Round Simulation
// =============================================================================

/proc/SimulateBattleRound(datum/ogv_battle_session/battle)
	if(!battle || !battle.is_active || battle.current_round >= OGV_MAX_ROUNDS)
		return FALSE
	
	battle.current_round++
	battle.AddEvent("round_start", "Battle", "Round Start", 0, "Round [battle.current_round] begins")
	
	// Simple round simulation
	// Attackers vs Defenders - calculate casualties
	var/attacker_damage = 0
	var/defender_damage = 0
	
	// Attacking officers deal damage
	for(var/datum/elite_officer/officer in battle.attacking_officers)
		if(officer && officer.is_alive)
			var/damage = (officer.level * 10) + rand(5, 15)
			attacker_damage += damage
			battle.AddEvent("damage", officer.officer_name || officer.officer_id, "Defending Force", damage, "")
	
	// Defending officers deal damage
	for(var/datum/elite_officer/officer in battle.defending_officers)
		if(officer && officer.is_alive)
			var/damage = (officer.level * 10) + rand(5, 15)
			defender_damage += damage
			battle.AddEvent("damage", officer.officer_name || officer.officer_id, "Attacking Force", damage, "")
	
	// Apply damage to troops
	battle.attacking_troops_count = max(0, battle.attacking_troops_count - (defender_damage / 20))
	battle.defending_troops_count = max(0, battle.defending_troops_count - (attacker_damage / 20))
	
	// Check for defections (loyalty < 50%)
	for(var/datum/elite_officer/officer in battle.attacking_officers)
		if(CheckOfficerDefection(officer))
			battle.AddEvent("defection", officer.officer_name || officer.officer_id, "Defending Force", 0, "")
			ProcessOfficerDefection(officer, "Defending Force")
			battle.attacking_officers -= officer
			battle.defending_officers += officer
	
	for(var/datum/elite_officer/officer in battle.defending_officers)
		if(CheckOfficerDefection(officer))
			battle.AddEvent("defection", officer.officer_name || officer.officer_id, "Attacking Force", 0, "")
			ProcessOfficerDefection(officer, "Attacking Force")
			battle.defending_officers -= officer
			battle.attacking_officers += officer
	
	// Check win conditions
	if(battle.attacking_troops_count <= 0)
		battle.EndBattle(0)  // Defenders win
		return FALSE
	
	if(battle.defending_troops_count <= 0)
		battle.EndBattle(1)  // Attackers win
		return FALSE
	
	// Move to next round if not finished
	return TRUE

/proc/StartBattleSimulation(datum/ogv_battle_session/battle)
	set background = 1
	set waitfor = 0
	
	if(!battle)
		return
	
	// Simulate rounds every 10 ticks
	while(battle.is_active && battle.current_round < OGV_MAX_ROUNDS)
		sleep(10)
		SimulateBattleRound(battle)
	
	// Battle finished - log to history
	if(recent_battle_history.len >= 100)
		recent_battle_history = recent_battle_history.Copy(2)  // Keep last 100
	recent_battle_history[battle.battle_id] = battle

// =============================================================================
// OGV Client Commands & Verbs
// =============================================================================

/mob/players/verb/ViewGarrisonBattle()
	set name = "View Garrison Battle"
	set category = "Territory"
	
	if(!active_battles.len)
		src << "No active battles to view."
		return
	
	// Show list of active battles
	var/html = "<html><head><title>Active Battles</title></head><body>"
	html += "<h2>Active Garrison Battles</h2>"
	
	for(var/battle_id in active_battles)
		var/datum/ogv_battle_session/battle = active_battles[battle_id]
		if(battle)
			html += "<p>"
			html += "<a href='?src=\ref[src];action=watch_battle;battle_id=[battle_id]'>"
			html += "[battle.attacking_territory_id] vs [battle.defending_territory_id] (Round [battle.current_round])"
			html += "</a>"
			html += "</p>"
	
	html += "</body></html>"
	src << browse(html, "window=battle_list;size=400x300")

// =============================================================================
// Handle User Input from OGV UI
// =============================================================================

/mob/players/Topic(href, list/href_list)
	..()
	
	if(href_list["action"] == "watch_battle")
		var/battle_id = href_list["battle_id"]
		var/datum/ogv_battle_session/battle = active_battles[battle_id]
		if(battle)
			ViewBattle(src, battle)
	
	if(href_list["action"] == "refresh_ogv")
		var/battle_id = battle_viewers[src]
		if(battle_id)
			var/datum/ogv_battle_session/battle = active_battles[battle_id]
			if(battle)
				ShowOGVBattle(src, battle)
	
	if(href_list["action"] == "close_ogv")
		StopViewingBattle(src)
		src << "Battle view closed."

// =============================================================================
// OGV Integration with Siege System
// =============================================================================

/**
 * CreateOGVBattleFromSiege(attacking_mob, defending_territory_id)
 * Hook to integrate with SiegeEventsSystem
 */
/proc/CreateOGVBattleFromSiege(mob/attacker, defending_territory_id)
	if(!attacker)
		return null
	
	var/attacking_territory_id = GetPlayerPrimaryTerritory(attacker)
	if(!attacking_territory_id)
		return null
	
	var/datum/ogv_battle_session/battle = CreateBattleSession(attacking_territory_id, defending_territory_id)
	
	// Add officers from both territories
	var/list/attacker_officers = territory_officers[attacking_territory_id]
	var/list/defender_officers = territory_officers[defending_territory_id]
	
	if(attacker_officers)
		battle.attacking_officers = attacker_officers.Copy()
	
	if(defender_officers)
		battle.defending_officers = defender_officers.Copy()
	
	// Estimate troop counts
	battle.attacking_troops_count = 50 + (attacker_officers ? attacker_officers.len * 10 : 0)
	battle.defending_troops_count = 50 + (defender_officers ? defender_officers.len * 10 : 0)
	
	// Start the battle simulation
	spawn(0) StartBattleSimulation(battle)
	
	return battle

// =============================================================================
// OGV System Initialization
// =============================================================================

/proc/InitializeOGVUI()
	InitializeOGVSystem()
	RegisterInitComplete("ogv_ui")

// Utility function (if worldtime2text doesn't exist elsewhere)
/proc/worldtime2text(time_value)
	if(!time_value)
		time_value = world.time
	return "[time_value / 600]:[((time_value % 600) / 10)]"
