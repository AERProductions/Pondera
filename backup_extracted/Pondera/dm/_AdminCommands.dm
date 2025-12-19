
//var
	//list/admins = world.host

/*mob
	Login()
		..()
		//if(admins.Find(ckey))
		if(ckeyEx("[usr.key]") == world.host&&MP==1)
			verbs += typesof(/mob/players/Special1/verb)*/

mob/players/Special1/verb
	Create(O as anything in typesof(/obj, /mob))
		set category = "Commands"
		set desc = "Create any object or mob type."
		if(O)
			new O (usr.loc)

	// ========================================================================
	// DEED ANTI-GRIEFING ADMIN TOOLS
	// ========================================================================

	Admin_CheckDeedGriefing()
		set category = "Deed Admin"
		set desc = "Check griefing status for a player"
		var/target_name = input("Check griefing status for:", "Player Name") as text
		if(!target_name) return
		
		var/mob/players/target = null
		for(var/mob/players/M in world)
			if(M.key == target_name || M.ckey == ckey(target_name))
				target = M
				break
		
		if(!target)
			usr << "Player not found: [target_name]"
			return
		
		var/list/status = GetDeedGriefingStatus(target, target.loc)
		usr << "\blue==== DEED GRIEFING STATUS FOR [target.key] ====="
		usr << "Location: [status["location"]]"
		usr << "Nearby deeds: [status["nearby_deeds"]]"
		usr << "Own deeds nearby: [status["own_deeds_nearby"]]"
		usr << "Other deeds nearby: [status["other_deeds_nearby"]]"
		usr << "Griefing risk: <b>[status["griefing_risk"]]</b>"
		usr << "Flagged: [status["flagged"] ? "YES" : "NO"]"
		if(status["notes"])
			usr << "Notes: [status["notes"]]"

	Admin_FlagGriefing()
		set category = "Deed Admin"
		set desc = "Flag player for griefing behavior"
		var/target_name = input("Flag for griefing:", "Player Name") as text
		if(!target_name) return
		
		var/mob/players/target = null
		for(var/mob/players/M in world)
			if(M.key == target_name || M.ckey == ckey(target_name))
				target = M
				break
		
		if(!target)
			usr << "Player not found: [target_name]"
			return
		
		var/reason = input("Reason for flag:", "Reason") as text|null
		if(!reason) reason = "No reason provided"
		
		AdminFlagDeedGriefing(target, reason)
		usr << "<b>Flagged [target.key] for deed griefing.</b>"
		world << "<b>ADMIN:</b> [usr.key] flagged [target.key] for deed griefing"

	Admin_UnflagGriefing()
		set category = "Deed Admin"
		set desc = "Clear griefing flag for a player"
		var/target_name = input("Clear griefing flag for:", "Player Name") as text
		if(!target_name) return
		
		var/mob/players/target = null
		for(var/mob/players/M in world)
			if(M.key == target_name || M.ckey == ckey(target_name))
				target = M
				break
		
		if(!target)
			usr << "Player not found: [target_name]"
			return
		
		AdminUnflagDeedGriefing(target)
		usr << "<b>Cleared griefing flag for [target.key].</b>"
		world << "<b>ADMIN:</b> [usr.key] cleared griefing flag for [target.key]"

	Admin_DeedGriefingReport()
		set category = "Deed Admin"
		set desc = "Get full griefing report for a player"
		var/target_name = input("Generate report for:", "Player Name") as text
		if(!target_name) return
		
		var/mob/players/target = null
		for(var/mob/players/M in world)
			if(M.key == target_name || M.ckey == ckey(target_name))
				target = M
				break
		
		if(!target)
			usr << "Player not found: [target_name]"
			return
		
		var/report = AdminGetDeedGriefingReport(target)
		usr << report

