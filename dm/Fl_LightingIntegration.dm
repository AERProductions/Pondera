// ============================================================================
// FILE: dm/Fl_LightingIntegration.dm
// PURPOSE: Integration layer for unified lighting system
// ============================================================================

var/day_night_cycle_active = 0

proc
	InitLightingIntegration()
		InitUnifiedLighting()

	start_day_night_cycle()
		set background = 1
		set waitfor = 0
		
		if(day_night_cycle_active) return
		day_night_cycle_active = 1
		spawn
			_day_night_cycle_loop()

	_day_night_cycle_loop()
		set background = 1
		set waitfor = 0
		while(world_initialization_complete)
			var/hour = (world.timeofday / 3600) % 24
			
			// Calculate day/night lighting
			var/day_cycle = sin((hour - 6) * 15)
			var/intensity = 0.5 + (0.5 * day_cycle)
			var/darkness = 50 - (50 * day_cycle)
			
			// Determine color based on time of day
			var/color = "#FFFFFF"
			if(hour >= 6 && hour < 9)
				color = "#FFAA44"
			else if(hour >= 9 && hour < 17)
				color = "#FFFFFF"
			else if(hour >= 17 && hour < 20)
				color = "#FFDD88"
			else
				color = "#444488"
			
			set_global_lighting(intensity, color, darkness)
			sleep(50)
