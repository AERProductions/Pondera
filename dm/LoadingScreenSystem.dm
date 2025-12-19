/**
 * LoadingScreenSystem.dm - Minimalist loading screen
 * Shows initialization progress as world systems initialize
 */

var
	loading_screen_active = 0
	loading_progress = 0
	loading_phase = "Initializing..."

proc/InitializeLoadingScreen()
	loading_screen_active = 1
	loading_progress = 0
	loading_phase = "Starting..."
	world.log << "\[LOADING_SCREEN\] Initialization system ready"

proc/ShowLoadingScreenForClient(client/C)
	if(loading_screen_active && C)
		C << "⏳ [loading_phase] ([loading_progress]%)"

proc/UpdateLoadingScreenPhase(phase_name)
	loading_phase = phase_name
	loading_progress += 6
	
	if(loading_progress > 100) loading_progress = 100
	
	world.log << "\[LOADING_SCREEN\] [phase_name] - [loading_progress]%"
	
	for(var/client/C)
		C << "⏳ [phase_name] ([loading_progress]%)"

proc/HideLoadingScreen()
	loading_screen_active = 0
	loading_progress = 100
	loading_phase = "Ready!"
	
	world.log << "\[LOADING_SCREEN\] Complete"
	
	for(var/client/C)
		C << "✅ World ready!"

proc/BroadcastSystemStatus(system_name, status)
	world.log << "\[SYSTEM_STATUS\] [system_name]: [status]"

/client
	var/loading_screen
