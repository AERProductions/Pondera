/**
 * Screen Objects - UI elements for HUD display
 */

obj/screen
	health_bar
		icon = 'dmi/64/inven.dmi'
		icon_state = "health_bar"
		screen_loc = "SOUTHWEST + (10,40)"
		layer = 20
		
		proc/refresh()
			if(usr && ismob(usr))
				var/mob/players/M = usr
				// Update health bar display based on M's HP
				var/health_percent = (M.HP / M.MAXHP) * 100
				if(health_percent > 75)
					color = "#00FF00"  // Green
				else if(health_percent > 50)
					color = "#FFFF00"  // Yellow
				else if(health_percent > 25)
					color = "#FF8800"  // Orange
				else
					color = "#FF0000"  // Red
	
	stamina_bar
		icon = 'dmi/64/inven.dmi'
		icon_state = "stamina_bar"
		screen_loc = "SOUTHWEST + (10,60)"
		layer = 20
		
		proc/refresh()
			if(usr && ismob(usr))
				var/mob/players/M = usr
				// Update stamina bar display based on M's stamina
				if(M.stamina)
					var/stamina_percent = (M.stamina / M.MAXstamina) * 100
					if(stamina_percent > 75)
						color = "#0088FF"  // Blue
					else if(stamina_percent > 50)
						color = "#00CCFF"  // Light Blue
					else if(stamina_percent > 25)
						color = "#FFFF00"  // Yellow
					else
						color = "#FF8800"  // Orange
