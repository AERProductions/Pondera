/*
	Improved Deed System for Dynamic Zones
	Integrates zone ownership with deed tokens and regions
	
	Village Tiers:
	- SMALL: 20x20 turfs, 5 max players, 100 Lucre/month
	- MEDIUM: 50x50 turfs, 15 max players, 500 Lucre/month
	- LARGE: 100x100 turfs, 50 max players, 2000 Lucre/month
*/

// Tier constants
#define VILLAGE_SMALL 1
#define VILLAGE_MEDIUM 2
#define VILLAGE_LARGE 3

#define VILLAGE_SMALL_SIZE 20
#define VILLAGE_MEDIUM_SIZE 50
#define VILLAGE_LARGE_SIZE 100

#define VILLAGE_SMALL_COST 100      // Monthly maintenance
#define VILLAGE_MEDIUM_COST 500
#define VILLAGE_LARGE_COST 2000

#define VILLAGE_SMALL_PURCHASE 500   // Upfront cost
#define VILLAGE_MEDIUM_PURCHASE 2000
#define VILLAGE_LARGE_PURCHASE 8000

#define VILLAGE_SMALL_MAXPLAYERS 5
#define VILLAGE_MEDIUM_MAXPLAYERS 15
#define VILLAGE_LARGE_MAXPLAYERS 50

obj/DeedToken_Zone
	name = "Zone Deed"
	density = TRUE
	icon = 'dmi/64/anctxt.dmi'
	icon_state = "token"
	
	var
		zone_id = 0
		owner_key = ""
		zone_name = ""
		zone_tier = VILLAGE_SMALL     // SMALL, MEDIUM, or LARGE
		size[2]                        // [width, height] in turfs
		center_turf = null            // Zone center location
		list/allowed_players = list()
		maintenance_cost = 0          // Monthly cost
		maintenance_due = 0           // Next payment due (world time)
		founded_date = 0              // Creation timestamp
		grace_period_end = 0          // Non-payment grace period
		payment_frozen = 0            // Is payment frozen (1=yes, 0=no)
		frozen_start = 0              // When freeze was activated (world.time)
		freeze_duration = 0           // How long to freeze (in ticks)
		freezes_used_this_month = 0   // Track freeze count (max 2 per month)
		last_freeze_month = 0         // When freezes_used was last reset
		cooldown_end = 0              // When early unfreeze cooldown expires (0 if none)

	New()
		..()
		zone_id = rand(1000000, 9999999)
		founded_date = world.time

	proc/InitializeTier(tier)
		/**
		 * Set up zone based on tier level
		 * @param tier - SMALL, MEDIUM, or LARGE
		 */
		zone_tier = tier
		
		switch(tier)
			if(VILLAGE_SMALL)
				size[1] = VILLAGE_SMALL_SIZE
				size[2] = VILLAGE_SMALL_SIZE
				maintenance_cost = VILLAGE_SMALL_COST
				allowed_players.len = VILLAGE_SMALL_MAXPLAYERS
				name = "Small Village Deed"
				
			if(VILLAGE_MEDIUM)
				size[1] = VILLAGE_MEDIUM_SIZE
				size[2] = VILLAGE_MEDIUM_SIZE
				maintenance_cost = VILLAGE_MEDIUM_COST
				allowed_players.len = VILLAGE_MEDIUM_MAXPLAYERS
				name = "Medium Village Deed"
				
			if(VILLAGE_LARGE)
				size[1] = VILLAGE_LARGE_SIZE
				size[2] = VILLAGE_LARGE_SIZE
				maintenance_cost = VILLAGE_LARGE_COST
				allowed_players.len = VILLAGE_LARGE_MAXPLAYERS
				name = "Large Village Deed"
		
		// Set maintenance due 30 game days from now
		maintenance_due = world.time + (30 * 24 * 60 * 10)  // 30 days in ticks

	proc/GetTierName()
		/**
		 * Get human-readable tier name
		 * @return "Small", "Medium", or "Large"
		 */
		switch(zone_tier)
			if(VILLAGE_SMALL)
				return "Small"
			if(VILLAGE_MEDIUM)
				return "Medium"
			if(VILLAGE_LARGE)
				return "Large"
		return "Unknown"

	proc/GetTierSize()
		/**
		 * Get zone size in turfs
		 * @return "20x20", "50x50", or "100x100"
		 */
		return "[size[1]]x[size[2]]"

	proc/GetMaxPlayers()
		/**
		 * Get maximum allowed players for this tier
		 * @return 5, 15, or 50
		 */
		switch(zone_tier)
			if(VILLAGE_SMALL)
				return VILLAGE_SMALL_MAXPLAYERS
			if(VILLAGE_MEDIUM)
				return VILLAGE_MEDIUM_MAXPLAYERS
			if(VILLAGE_LARGE)
				return VILLAGE_LARGE_MAXPLAYERS
		return 0

	proc/IsMaintenanceDue()
		/**
		 * Check if maintenance payment is due
		 * @return TRUE if payment overdue or grace period expired
		 */
		// Check if payments are frozen
		if(payment_frozen && frozen_start > 0)
			if(world.time < (frozen_start + freeze_duration))
				return FALSE  // Still frozen, no payment due
			else
				// Freeze period ended, unfreeze and reset maintenance due
				payment_frozen = 0
				frozen_start = 0
				maintenance_due = world.time + (30 * 24 * 60 * 10)  // Reset 30 days from now
				return FALSE
		
		if(world.time >= grace_period_end && grace_period_end > 0)
			return TRUE  // Grace period expired, zone should be deleted
		
		if(world.time >= maintenance_due)
			return TRUE  // Payment due
		
		return FALSE

	proc/OnMaintenanceFailure()
		/**
		 * Handle non-payment of maintenance
		 * Starts 7-day grace period, then deletes zone
		 */
		if(grace_period_end == 0)
			grace_period_end = world.time + (7 * 24 * 60 * 10)  // 7 days in ticks
			world.log << "VILLAGE: [zone_name] (ID: [zone_id]) - Grace period started"
			
			// Notify owner
			var/mob/players/owner_mob = null
			for(var/mob/players/M in world)
				if(M.ckey == owner_key)
					owner_mob = M
					break
			
			if(owner_mob)
				owner_mob << "<b><font color=red>WARNING: Village deed [zone_name] maintenance unpaid!"
				owner_mob << "You have 7 days to pay [maintenance_cost] Lucre or the deed will be lost!"
		else if(world.time >= grace_period_end)
			// Grace period expired - delete zone
			world.log << "VILLAGE: [zone_name] (ID: [zone_id]) - Deleted due to non-payment"
			del src

	proc/ProcessMaintenance(mob/players/M)
		/**
		 * Process monthly maintenance payment
		 * @param M - Owner attempting to pay
		 */
		if(M.ckey != owner_key)
			M << "Only the deed owner can pay maintenance."
			return
		
		// Check if payments are frozen
		if(payment_frozen && frozen_start > 0)
			var/days_remaining = ceil((frozen_start + freeze_duration - world.time) / (24 * 60 * 10))
			if(days_remaining > 0)
				M << "<font color=orange>Village deed payments are currently frozen!</font>"
				M << "Freeze will end in [days_remaining] days."
				return
		
		if(M.lucre < maintenance_cost)
			M << "You need [maintenance_cost] Lucre to pay maintenance."
			M << "Current balance: [M.lucre]"
			return
		
		// Deduct cost
		M.lucre -= maintenance_cost
		maintenance_due = world.time + (30 * 24 * 60 * 10)  // 30 days from now
		grace_period_end = 0
		
		M << "<font color=green>Maintenance payment of [maintenance_cost] Lucre processed!"
		M << "Next payment due in 30 days."
		world.log << "VILLAGE: [zone_name] (ID: [zone_id]) - Maintenance paid by [M.ckey]"

	Click()
		if(usr.key == owner_key)
			OpenDeedMenu(usr)
		else
			usr << "This [GetTierName()] village deed belongs to [owner_key]."

	proc/OpenDeedMenu(mob/players/M)
		/**
		 * Open deed management menu for owner
		 */
		var/choice = input(M, "Manage village:", "Village Deed") in list(
			"View Info",
			"Manage Access",
			"Rename",
			"Pay Maintenance",
			"Freeze Payments",
			"Upgrade Tier",
			"Close"
		)
		
		switch(choice)
			if("View Info")
				var/info = "<b>[zone_name]</b><br>"
				info += "Tier: [GetTierName()] ([GetTierSize()] turfs)<br>"
				info += "Owner: [owner_key]<br>"
				info += "Members: [allowed_players.len] / [GetMaxPlayers()]<br>"
				info += "Monthly Cost: [maintenance_cost] Lucre<br>"
				
				if(world.time >= maintenance_due)
					info += "<font color=red><b>MAINTENANCE OVERDUE</b></font><br>"
				else
					var/days_until = max(1, ceil((maintenance_due - world.time) / (24 * 60 * 10)))
					info += "Next Payment: [days_until] days<br>"
				
				M << info
				
			if("Manage Access")
				var/action = input(M, "Action:", "Access") in list("Add Player", "Remove Player", "Back")
				
				if(action == "Add Player")
					var/target = input(M, "Player name to add:") as text
					if(allowed_players.len >= GetMaxPlayers())
						M << "Village is at maximum capacity!"
						return
					
					if(!(target in allowed_players))
						allowed_players += target
						M << "[target] added to village."
					else
						M << "[target] is already in the village."
				
				else if(action == "Remove Player")
					var/target = input(M, "Player name to remove:", "Remove") as text
					if(target in allowed_players)
						allowed_players -= target
						M << "[target] removed from village."
					else
						M << "[target] is not in the village."
			
			if("Rename")
				var/new_name = input(M, "New village name:", "Rename", zone_name) as text
				if(new_name && length(new_name) > 0 && length(new_name) <= 50)
					zone_name = new_name
					M << "Village renamed to [zone_name]."
				else
					M << "Invalid name."
			
		if("Pay Maintenance")
			ProcessMaintenance(M)
		
		if("Freeze Payments")
			OpenFreezeMenu(M)
		
		if("Upgrade Tier")
			var/new_tier = input(M, "Upgrade to which tier?", "Upgrade") in list("Medium (2000 Lucre)", "Large (8000 Lucre)", "Cancel")
			
			if(new_tier == "Cancel")
				return
			
			// Implement tier upgrade logic
			M << "Tier upgrades coming in a future update!"
		
		if("Close")
			return

	proc/OpenFreezeMenu(mob/players/M)
		/**
		 * Manage deed payment freeze feature
		 * Allows owner to pause maintenance payments while on vacation
		 * Anti-abuse: Max 2 freezes per month, 7-day cooldown on early unfreeze
		 */
		CheckMonthlyReset()  // Reset freeze count if month changed
		
		if(payment_frozen)
			// Currently frozen; show unfreeze option
			var/days_remaining = ceil((frozen_start + freeze_duration - world.time) / (24 * 60 * 10))
			var/choice = input(M, "Payments frozen for [days_remaining] more days. Options:", "Freeze Status") in list(
				"View Status",
				"Unfreeze Now",
				"Back"
			)
			
			switch(choice)
				if("View Status")
					var/info = "<b>Deed Freeze Status</b><br>"
					info += "Status: <font color=orange>FROZEN</font><br>"
					info += "Days Remaining: [days_remaining]<br>"
					info += "Maintenance payments are paused.<br>"
					M << info
					
				if("Unfreeze Now")
					var/confirm = alert(M, "Unfreeze deed payments now?\nThis will trigger a 7-day cooldown before you can freeze again.", "Unfreeze", "Yes", "No")
					if(confirm == "Yes")
						payment_frozen = 0
						frozen_start = 0
						maintenance_due = world.time + (30 * 24 * 60 * 10)  // 30 days from now
						cooldown_end = world.time + (7 * 24 * 60 * 10)  // 7-day cooldown
						M << "<font color=orange>Deed payments unfrozen! You can re-freeze in 7 days.</font>"
						world.log << "VILLAGE: [zone_name] (ID: [zone_id]) - Payments unfrozen early by [M.ckey] (7-day cooldown applied)"
					
				if("Back")
					return
		else
			// Not frozen; check if in cooldown or at freeze limit
			var/freezes_available = 2 - freezes_used_this_month
			var/cooldown_days = GetCooldownDaysRemaining()
			
			var/freeze_status = ""
			if(cooldown_days > 0)
				freeze_status = "<font color=orange>[cooldown_days] day(s) remaining in cooldown</font><br>"
			freeze_status += "Freezes available: <b>[freezes_available]/2</b> this month<br>"
			freeze_status += "Resets: <b>[GetNextMonthReset()]</b>"
			
			var/choice = input(M, "Freeze deed payments while on vacation. This pauses all maintenance requirements.<br><br>[freeze_status]", "Freeze Payments") in list(
				"Freeze for 7 Days",
				"Freeze for 14 Days",
				"Freeze for 30 Days",
				"View Info",
				"Back"
			)
			
			switch(choice)
				if("Freeze for 7 Days")
					ActivateFreeze(M, 7)
					
				if("Freeze for 14 Days")
					ActivateFreeze(M, 14)
					
				if("Freeze for 30 Days")
					ActivateFreeze(M, 30)
					
				if("View Info")
					var/info = "<b>Deed Payment Freeze</b><br><br>"
					info += "This feature allows you to pause maintenance payments for your village while you take a vacation or break.<br><br>"
					info += "<b>How it works:</b><br>"
					info += "1. Select a freeze duration (7, 14, or 30 days)<br>"
					info += "2. Maintenance payments will not be due during freeze period<br>"
					info += "3. You can unfreeze anytime to resume payments<br>"
					info += "4. When freeze ends, your next payment will be due in 30 days<br><br>"
					info += "<b>Limitations (Anti-Abuse):</b><br>"
					info += "- Maximum 2 freezes per calendar month<br>"
					info += "- Early unfreeze triggers 7-day cooldown before re-freezing<br>"
					info += "- You still have 7-day grace period if payments are late<br><br>"
					info += "<b>Benefits:</b><br>"
					info += "- Prevents deed loss while on extended breaks<br>"
					info += "- Zone remains under your ownership<br>"
					info += "- Preserves all zone data and player memberships<br><br>"
					info += "Current Status: <font color=green>NOT FROZEN</font>"
					M << info
					
				if("Back")
					return

	proc/ActivateFreeze(mob/players/M, days)
		/**
		 * Activate deed payment freeze for specified days
		 * @param M - Owner activating freeze
		 * @param days - Number of days to freeze (7, 14, or 30)
		 */
		CheckMonthlyReset()  // Reset freeze count if month changed
		
		// Check if in cooldown
		if(cooldown_end > 0 && world.time < cooldown_end)
			var/days_remaining = ceil((cooldown_end - world.time) / (24 * 60 * 10))
			M << "<font color=red>You cannot freeze yet! Early unfreeze cooldown active.</font>"
			M << "Try again in [days_remaining] day(s)."
			return
		
		// Check if at freeze limit
		if(freezes_used_this_month >= 2)
			M << "<font color=red>You have reached your freeze limit for this month (2 max).</font>"
			M << "Try again when the month resets on the 1st."
			return
		
		var/confirm = alert(M, "Freeze payments for [days] days?\nMaintenance will be paused. You can unfreeze anytime.\n\nThis uses 1 of your 2 monthly freezes.", "Confirm Freeze", "Yes", "No")
		
		if(confirm == "No")
			return
		
		payment_frozen = 1
		frozen_start = world.time
		freeze_duration = days * 24 * 60 * 10  // Convert days to ticks
		freezes_used_this_month += 1  // Increment freeze count
		cooldown_end = 0  // Clear any cooldown since they're not unfreezing early
		
		M << "<font color=orange><b>Deed payments are now frozen for [days] days!</b></font>"
		M << "Your village remains under your ownership."
		M << "When the freeze ends, you'll have 30 days to pay maintenance."
		M << "Freezes used this month: [freezes_used_this_month]/2"
		world.log << "VILLAGE: [zone_name] (ID: [zone_id]) - Payments frozen for [days] days by [M.ckey] ([freezes_used_this_month]/2 freezes used)"

	proc/CheckMonthlyReset()
		/**
		 * Check if calendar month has changed; reset freeze count if so
		 */
		// Get current month (1-12)
		var/current_month = text2num(time2text(world.realtime, "MM"))
		
		// Check if we need to reset
		if(last_freeze_month != current_month)
			freezes_used_this_month = 0
			last_freeze_month = current_month
			world.log << "VILLAGE: [zone_name] (ID: [zone_id]) - Monthly freeze count reset"

	proc/GetCooldownDaysRemaining()
		/**
		 * Get days remaining in early unfreeze cooldown
		 * @return Number of days remaining (0 if no cooldown)
		 */
		if(cooldown_end == 0 || world.time >= cooldown_end)
			return 0
		
		return ceil((cooldown_end - world.time) / (24 * 60 * 10))

	proc/GetNextMonthReset()
		/**
		 * Get formatted date of next month reset (1st of next month)
		 * @return String like "January 1st"
		 */
		var/current_month = text2num(time2text(world.realtime, "MM"))
		var/next_month = current_month + 1
		var/next_year = text2num(time2text(world.realtime, "YYYY"))
		
		if(next_month > 12)
			next_month = 1
			next_year += 1
		
		var/month_names = list("January", "February", "March", "April", "May", "June", 
							   "July", "August", "September", "October", "November", "December")
		var/month_name = month_names[next_month]
		
		return "[month_name] 1st"

// Deed Scroll - used to create new villages
obj/Deed
	name = "Village Deed"
	icon = 'dmi/64/anctxt.dmi'
	icon_state = "scroll"
	
	var/tier = VILLAGE_SMALL  // What size deed this scroll creates
	
	proc/GetTierName()
		switch(tier)
			if(VILLAGE_SMALL)
				return "Small"
			if(VILLAGE_MEDIUM)
				return "Medium"
			if(VILLAGE_LARGE)
				return "Large"
		return "Unknown"

	verb/ClaimZone()
		set src in usr
		set hidden = 1
		
		var/mob/players/M = usr
		var/turf/t = M.loc
		
		if(!istype(t))
			M << "Invalid location."
			return
		
		// Create deed token zone
		var/obj/DeedToken_Zone/dt = new(M.loc)
		dt.owner_key = M.ckey
		dt.zone_name = "New [GetTierName()] Village"
		dt.InitializeTier(tier)
		dt.center_turf = t
		
		// Add owner to allowed list
		dt.allowed_players += M.ckey
		
		world.log << "VILLAGE: [dt.zone_name] created by [M.ckey] (Tier: [dt.GetTierName()], ID: [dt.zone_id])"
		
		M << "<font color=green>You have founded [dt.zone_name]!"
		M << "Village size: [dt.GetTierSize()] turfs"
		M << "Maximum players: [dt.GetMaxPlayers()]"
		M << "Monthly maintenance: [dt.maintenance_cost] Lucre"
		
		del src  // Consume the deed scroll

proc/IntegrateZoneWithRegion(zone_id, region/R)
	// Link region to zone for access control
	if(!R) return
	
	for(var/obj/DeedToken_Zone/dz in world)
		if(dz.zone_id == zone_id)
			// Region name integration - regions don't have settable names in BYOND
			// This is a stub for future integration
			return
