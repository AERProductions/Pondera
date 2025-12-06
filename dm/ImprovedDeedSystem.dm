/*
	Improved Deed System for Dynamic Zones
	Integrates zone ownership with deed tokens and regions
*/

obj/DeedToken_Zone
	name = "Zone Deed"
	density = TRUE
	icon = 'dmi/64/anctxt.dmi'
	icon_state = "token"
	
	var
		zone_id = 0
		owner_key = ""
		zone_name = ""
		list/allowed_players = list()

	Click()
		if(usr.key == owner_key)
			OpenDeedMenu(usr)
		else
			usr << "This deed belongs to [owner_key]."

	proc/OpenDeedMenu(mob/players/M)
		var/choice = input(M, "Manage zone:", "Deed") in list("View Info", "Manage Access", "Rename", "Close")
		switch(choice)
			if("View Info")
				M << "<b>[zone_name]</b><br>Owner: [owner_key]<br>Allowed: [allowed_players.len]"
			if("Manage Access")
				var/target = input(M, "Player name:") as text
				if(target in allowed_players)
					allowed_players -= target
					M << "[target] removed."
				else
					allowed_players += target
					M << "[target] added."
			if("Rename")
				var/new_name = input(M, "New name:", "Rename", zone_name) as text
				zone_name = new_name

// Extended Deed object with zone integration
obj/Deed
	verb/ClaimZone()
		set src in usr
		set hidden = 1
		
		var/mob/players/M = usr
		if(!zone_mgr)
			M << "Zone system not initialized."
			return
		
		var/turf/t = M.loc
		if(!istype(t))
			M << "Invalid location."
			return
		
		// Create deed token
		var/obj/DeedToken_Zone/dt = new(M)
		dt.owner_key = M.key
		dt.zone_name = "Unclaimed Zone"
		dt.loc = M
		
		M << "You have claimed this zone!"
		del src  // Consume the deed scroll

proc/IntegrateZoneWithRegion(zone_id, region/R)
	// Link region to zone for access control
	if(!zone_mgr) return
	for(var/dynamic_zone/dz in zone_mgr.active_zones)
		if(dz.zone_id == zone_id)
			R.name = dz.zone_name
			return
