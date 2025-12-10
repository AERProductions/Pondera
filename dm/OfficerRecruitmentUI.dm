// OfficerRecruitmentUI.dm - Phase 32: UI for Officer Recruitment & Management
// Player-facing interface for recruiting officers, managing garrison, and viewing stats

#define OFFICER_UI_MAIN "officer_main"
#define OFFICER_UI_RECRUIT "officer_recruit"
#define OFFICER_UI_GARRISON "officer_garrison"
#define OFFICER_UI_ABILITIES "officer_abilities"
#define OFFICER_UI_LEADERBOARD "officer_leaderboard"

// =============================================================================
// Officer UI System
// =============================================================================

/datum/officer_ui
	var
		player_mob              // Reference to player mob
		current_view = OFFICER_UI_MAIN  // Current screen
		territory_id = null     // Current territory viewing
		selected_officer = null // Officer being managed
		
	New(mob/M)
		player_mob = M

/proc/OpenOfficerUI(mob/M)
	if(!M)
		return FALSE
	
	var/datum/officer_ui/ui = new(M)
	ui.ShowMainMenu()
	return TRUE

// =============================================================================
// Main Menu
// =============================================================================

/datum/officer_ui/proc/ShowMainMenu()
	var/html = {"<html>
	<head><title>Officer Command Center</title></head>
	<body bgcolor=#1a1a1a text=#aaaaaa>
	<center>
	<h2>⚔ OFFICER COMMAND CENTER ⚔</h2>
	<hr>
	
	<b>Main Menu</b><br><br>
	
	<button onclick="parent.location='?command=recruit'">
	Recruit Officers
	</button><br><br>
	
	<button onclick="parent.location='?command=garrison'">
	Manage Garrison
	</button><br><br>
	
	<button onclick="parent.location='?command=abilities'">
	Officer Abilities
	</button><br><br>
	
	<button onclick="parent.location='?command=leaderboard'">
	Leaderboard
	</button><br><br>
	
	<hr>
	<small>Territory Control | Phase 32</small>
	</center>
	</body>
	</html>"}
	
	player_mob << browse(html, "window=officer_ui;size=400x500")
	current_view = OFFICER_UI_MAIN

// =============================================================================
// Recruitment Interface
// =============================================================================

/datum/officer_ui/proc/ShowRecruitmentUI()
	var/territory_info = GetTerritoryInfo()
	
	var/html = {"<html>
	<head><title>Officer Recruitment</title></head>
	<body bgcolor=#1a1a1a text=#aaaaaa>
	<center>
	<h2>RECRUIT OFFICERS</h2>
	<hr>
	
	<b>"}
	
	html += territory_info + {"</b><br><br>
	
	<b>Available Officer Classes</b><br><br>"}
	
	// General - Tank/Melee
	html += {" <div style='border:1px solid gray;padding:10px;margin:5px'>
	<b>GENERAL</b> (Tank/Melee)<br>
	High defense, moderate damage<br>
	Special: Rally, Execute<br>
	<select name='general_quality'>
		<option value='recruit'>Recruit (100 Lucre)</option>
		<option value='veteran'>Veteran (250 Lucre)</option>
		<option value='elite'>Elite (500 Lucre)</option>
		<option value='legendary'>Legendary (1000 Lucre)</option>
	</select>
	<button onclick='recruit(\"general\")'>Recruit</button>
	</div>"}
	
	// Marshal - Ranged DPS
	html += {" <div style='border:1px solid gray;padding:10px;margin:5px'>
	<b>MARSHAL</b> (Ranged DPS)<br>
	High damage, low defense<br>
	Special: Volley, Rain of Arrows<br>
	<select name='marshal_quality'>
		<option value='recruit'>Recruit (100 Lucre)</option>
		<option value='veteran'>Veteran (250 Lucre)</option>
		<option value='elite'>Elite (500 Lucre)</option>
		<option value='legendary'>Legendary (1000 Lucre)</option>
	</select>
	<button onclick='recruit(\"marshal\")'>Recruit</button>
	</div>"}
	
	// Captain - Support/Command
	html += {" <div style='border:1px solid gray;padding:10px;margin:5px'>
	<b>CAPTAIN</b> (Support/Command)<br>
	Boosts all allies nearby<br>
	Special: Morale Commands, Legion Commander<br>
	<select name='captain_quality'>
		<option value='recruit'>Recruit (100 Lucre)</option>
		<option value='veteran'>Veteran (250 Lucre)</option>
		<option value='elite'>Elite (500 Lucre)</option>
		<option value='legendary'>Legendary (1000 Lucre)</option>
	</select>
	<button onclick='recruit(\"captain\")'>Recruit</button>
	</div>"}
	
	// Strategist - Tactical/Control
	html += {" <div style='border:1px solid gray;padding:10px;margin:5px'>
	<b>STRATEGIST</b> (Tactical/Control)<br>
	Crowd control, positioning damage<br>
	Special: Analyze, Shadow Strike<br>
	<select name='strategist_quality'>
		<option value='recruit'>Recruit (100 Lucre)</option>
		<option value='veteran'>Veteran (250 Lucre)</option>
		<option value='elite'>Elite (500 Lucre)</option>
		<option value='legendary'>Legendary (1000 Lucre)</option>
	</select>
	<button onclick='recruit(\"strategist\")'>Recruit</button>
	</div>"}
	
	// Warlord - Dominance/Terror
	html += {" <div style='border:1px solid gray;padding:10px;margin:5px'>
	<b>WARLORD</b> (Dominance/Terror)<br>
	Fear effects, crowd control<br>
	Special: Intimidate, Apocalypse<br>
	<select name='warlord_quality'>
		<option value='recruit'>Recruit (100 Lucre)</option>
		<option value='veteran'>Veteran (250 Lucre)</option>
		<option value='elite'>Elite (500 Lucre)</option>
		<option value='legendary'>Legendary (1000 Lucre)</option>
	</select>
	<button onclick='recruit(\"warlord\")'>Recruit</button>
	</div>"}
	
	html += {" <hr>
	<button onclick='parent.location=\"?command=main\"'>Back to Main</button>
	</center>
	</body>
	</html>"}
	
	player_mob << browse(html, "window=officer_ui;size=500x800")
	current_view = OFFICER_UI_RECRUIT

// =============================================================================
// Garrison Management
// =============================================================================

/datum/officer_ui/proc/ShowGarrisonUI()
	var/html = {"<html>
	<head><title>Garrison Management</title></head>
	<body bgcolor=#1a1a1a text=#aaaaaa>
	<center>
	<h2>GARRISON MANAGEMENT</h2>
	<hr>"}
	
	var/territory_info = GetTerritoryInfo()
	html += "<b>" + territory_info + "</b><br><br>"
	
	// Show all officers in garrison
	var/list/officers = territory_officers[territory_id]
	if(!officers || officers.len == 0)
		html += "<i>No officers recruited yet.</i><br>"
	else
		html += "<b>[officers.len] Officers</b><br><br>"
		for(var/datum/elite_officer/officer in officers)
			var/status = officer.is_alive ? "ALIVE" : "DEAD (Respawning)"
			var/recruited = officer.is_recruited ? "Ready" : "Recruiting..."
			var/loyalty_color = officer.loyalty > 75 ? "green" : officer.loyalty > 50 ? "yellow" : "red"
			
			html += {" <div style='border:1px solid #444;padding:8px;margin:5px'>
			<b>"}
			html += officer.officer_name || "Officer #[officer.officer_id]"
			html += {"</b> - [officer.officer_class]<br>
			Level: [officer.level] | Status: [recruited] | <span style='color:[loyalty_color]'>Loyalty: [officer.loyalty]%</span><br>
			HP: [officer.hp]/[officer.max_hp] | [status]<br>
			Kills: [officer.kills] | Battles: [officer.battles_fought]<br>
			<button onclick='view_officer([officer.officer_id])'>View Details</button>
			<button onclick='rename_officer([officer.officer_id])'>Rename</button>
			</div>"}
	
	html += {" <hr>
	<button onclick='parent.location=\"?command=main\"'>Back to Main</button>
	</center>
	</body>
	</html>"}
	
	player_mob << browse(html, "window=officer_ui;size=500x600")
	current_view = OFFICER_UI_GARRISON

// =============================================================================
// Abilities Display
// =============================================================================

/datum/officer_ui/proc/ShowAbilitiesUI()
	var/html = {"<html>
	<head><title>Officer Abilities</title></head>
	<body bgcolor=#1a1a1a text=#aaaaaa>
	<center>
	<h2>OFFICER ABILITIES BY CLASS</h2>
	<hr>"}
	
	// Display abilities for each class
	var/list/classes = list(
		OFFICER_CLASS_GENERAL,
		OFFICER_CLASS_MARSHAL,
		OFFICER_CLASS_CAPTAIN,
		OFFICER_CLASS_STRATEGIST,
		OFFICER_CLASS_WARLORD
	)
	
	for(var/class_type in classes)
		var/class_name = GetOfficerClassName(class_type)
		html += "<b>[class_name] Abilities</b><br>"
		
		var/list/abilities = GetAbilitiesForClass(class_type)
		for(var/i=1 to abilities.len)
			var/datum/officer_ability/ability = abilities[i]
			if(!ability) continue
			
			html += {" <div style='border:1px solid #444;padding:8px;margin:5px'>
			<b>[ability.ability_name]</b> (Level [i])<br>
			[ability.ability_description]<br>
			Cooldown: [ability.cooldown_seconds]s | Cost: [ability.resource_cost]<br>
			Damage Multiplier: [ability.base_damage_multiplier]x
			</div>"}
		
		html += "<br>"
	
	html += {" <hr>
	<button onclick='parent.location=\"?command=main\"'>Back to Main</button>
	</center>
	</body>
	</html>"}
	
	player_mob << browse(html, "window=officer_ui;size=600x700")
	current_view = OFFICER_UI_ABILITIES

// =============================================================================
// Leaderboard
// =============================================================================

/datum/officer_ui/proc/ShowLeaderboardUI()
	var/html = {"<html>
	<head><title>Officer Leaderboard</title></head>
	<body bgcolor=#1a1a1a text=#aaaaaa>
	<center>
	<h2>⚔ OFFICER LEADERBOARD ⚔</h2>
	<hr>
	
	<b>Top Officers by Kills</b><br><br>"}
	
	// Sort officers by kills
	var/list/sorted_officers = list()
	for(var/territory_id in territory_officers)
		var/list/territory_ofc = territory_officers[territory_id]
		for(var/datum/elite_officer/officer in territory_ofc)
			sorted_officers += officer
	
	// Sort by kills descending
	sorted_officers = sortBy(sorted_officers, /proc/SortOfficersByKills)
	
	var/rank = 1
	for(var/datum/elite_officer/officer in sorted_officers)
		if(rank > 20) break  // Top 20 only
		
		var/color = rank == 1 ? "gold" : rank == 2 ? "silver" : "lightgray"
		html += {"<div style='color:[color];border:1px solid gray;padding:8px;margin:5px'>
		#[rank]. <b>[officer.officer_name || "Officer [officer.officer_id]"]</b><br>
		[officer.officer_class] - Level [officer.level]<br>
		Kills: [officer.kills] | Battles: [officer.battles_fought] | Loyalty: [officer.loyalty]%
		</div>"}
		
		rank++
	
	html += {" <hr>
	<button onclick='parent.location=\"?command=main\"'>Back to Main</button>
	</center>
	</body>
	</html>"}
	
	player_mob << browse(html, "window=officer_ui;size=500x600")
	current_view = OFFICER_UI_LEADERBOARD

// =============================================================================
// Helper Procs
// =============================================================================

/datum/officer_ui/proc/GetTerritoryInfo()
	if(!territory_id)
		territory_id = GetPlayerPrimaryTerritory(player_mob)
	
	if(!territory_id)
		return "No territory claimed"
	
	var/datum/territory_claim/territory = GetTerritoryByID(territory_id)
	if(!territory)
		return "Invalid territory"
	
	var/owner_name = territory.owner_player_name || "Unknown"
	return "Territory: [territory_id] | Tier: [territory.tier] | Owner: [owner_name]"

/datum/officer_ui/proc/GetOfficerStats()
	if(!selected_officer)
		return "No officer selected"
	
	return "Officer management - details pending"

/datum/officer_ui/proc/HandleInput(input)
	// This would handle button clicks and inputs from the browser
	// Implementation depends on how button clicks are sent back

// =============================================================================
// Sorting & Utility Procs
// =============================================================================

/proc/SortOfficersByKills(datum/elite_officer/a, datum/elite_officer/b)
	return b.kills - a.kills  // Descending order

/proc/GetOfficerClassName(class_type)
	switch(class_type)
		if(OFFICER_CLASS_GENERAL)
			return "General"
		if(OFFICER_CLASS_MARSHAL)
			return "Marshal"
		if(OFFICER_CLASS_CAPTAIN)
			return "Captain"
		if(OFFICER_CLASS_STRATEGIST)
			return "Strategist"
		if(OFFICER_CLASS_WARLORD)
			return "Warlord"
	return "Unknown"

/proc/GetOfficerQualityColor(quality_tier)
	switch(quality_tier)
		if(OFFICER_QUALITY_RECRUIT)
			return "white"
		if(OFFICER_QUALITY_VETERAN)
			return "green"
		if(OFFICER_QUALITY_ELITE)
			return "blue"
		if(OFFICER_QUALITY_LEGENDARY)
			return "gold"
	return "gray"

/proc/GetOfficerQualityName(quality_tier)
	switch(quality_tier)
		if(OFFICER_QUALITY_RECRUIT)
			return "Recruit"
		if(OFFICER_QUALITY_VETERAN)
			return "Veteran"
		if(OFFICER_QUALITY_ELITE)
			return "Elite"
		if(OFFICER_QUALITY_LEGENDARY)
			return "Legendary"
	return "Unknown"

/proc/GetPlayerPrimaryTerritory(mob/M)
	if(!M)
		return null
	
	// Check if player owns a territory
	for(var/territory_id in territories_by_id)
		var/datum/territory_claim/territory = territories_by_id[territory_id]
		if(territory && territory.owner_player_key == M.key)
			return territory_id
	
	return null

/proc/sortBy(list/items, sorting_proc)
	// Simple bubble sort using custom proc
	var/len = items.len
	for(var/i=1 to len)
		for(var/j=1 to len-i)
			if(call(sorting_proc)(items[j], items[j+1]) > 0)
				var/temp = items[j]
				items[j] = items[j+1]
				items[j+1] = temp
	return items

// =============================================================================
// UI Integration with Commands
// =============================================================================

/mob/players/verb/Officers()
	set name = "Officers"
	set category = "Territory"
	if(OpenOfficerUI(src))
		src << "Officer Command Center opened."
