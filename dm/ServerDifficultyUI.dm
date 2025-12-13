// ServerDifficultyUI.dm - Server Configuration Panel for Difficulty Settings
// Host can set: permadeath toggle, lives per continent, respawn grace period
// Settings persist and are enforced throughout gameplay

// ============================================================================
// SERVER CONFIGURATION UI
// ============================================================================

/**
 * OpenServerConfigurationPanel(mob/players/P)
 * Open server difficulty configuration panel
 * Only Owner/MGM can access
 * 
 * @param P: Player mob (must be Owner/MGM)
 */
proc/OpenServerConfigurationPanel(mob/players/P)
	if(!P) return
	
	// Verify owner/MGM access
	if(!IsOwner(P.ckey))
		P << "<span class='danger'>ERROR: Only Master GM can access server configuration.</span>"
		return
	
	var/datum/server_difficulty_config/config = GetServerDifficultyConfig()
	if(!config) return
	
	P << "\n<span class='good'>═══════════════════════════════════════</span>"
	P << "<span class='good'>SERVER DIFFICULTY CONFIGURATION</span>"
	P << "<span class='good'>═══════════════════════════════════════</span>"
	P << ""
	
	// Current settings
	P << "<span class='info'>CURRENT SETTINGS:</span>"
	var/perm_status = config.permadeath_enabled ? "ON" : "OFF"
	P << "<span class='info'>\[Permadeath\] [perm_status]</span>"
	var/story_lives = config.lives_per_continent["story"]
	P << "<span class='info'>\[Story Lives\] [story_lives]</span>"
	var/sandbox_lives = config.lives_per_continent["sandbox"]
	P << "<span class='info'>\[Sandbox Lives\] [sandbox_lives]</span>"
	var/kingdom_lives = config.lives_per_continent["kingdom"]
	P << "<span class='info'>\[Kingdom Lives\] [kingdom_lives]</span>"
	P << ""
	
	// Options menu
	P << "<span class='info'>OPTIONS:</span>"
	P << "<span class='info'>[1] Toggle Permadeath ([config.permadeath_enabled ? "ON" : "OFF"])</span>"
	P << "<span class='info'>[2] Set Story Lives ([config.lives_per_continent["story"]])</span>"
	P << "<span class='info'>[3] Set Sandbox Lives ([config.lives_per_continent["sandbox"]])</span>"
	P << "<span class='info'>[4] Set Kingdom Lives ([config.lives_per_continent["kingdom"]])</span>"
	P << "<span class='info'>[5] Reset to Defaults</span>"
	P << "<span class='info'>[0] Done</span>"
	P << ""
	P << "<span class='good'>═══════════════════════════════════════</span>"
	
	var/choice = input(P, "Choose option:", "Server Config") in list("1", "2", "3", "4", "5", "0")
	
	switch(choice)
		if("1")
			TogglePermadeath(P, config)
		if("2")
			SetStoryLives(P, config)
		if("3")
			SetSandboxLives(P, config)
		if("4")
			SetKingdomLives(P, config)
		if("5")
			ResetConfigurationToDefaults(config)
			P << "<span class='good'>Configuration reset to defaults.</span>"
		if("0")
			P << "<span class='good'>Configuration saved.</span>"
			return
	
	// Loop back to menu
	spawn(10)
		OpenServerConfigurationPanel(P)

/**
 * TogglePermadeath(mob/players/P, datum/server_difficulty_config/config)
 * Toggle permadeath on/off
 * 
 * @param P: Admin player
 * @param config: Server config
 */
proc/TogglePermadeath(mob/players/P, datum/server_difficulty_config/config)
	if(!config) return
	
	config.permadeath_enabled = config.permadeath_enabled ? 0 : 1
	var/perm_state = config.permadeath_enabled ? "ON" : "OFF"
	var/perm_broadcast = config.permadeath_enabled ? "ENABLED" : "DISABLED"
	
	P << "<span class='good'>Permadeath set to: [perm_state]</span>"
	world << "<span class='danger'>SERVER: Permadeath is now [perm_broadcast]</span>"
	world.log << "Permadeath set to: [config.permadeath_enabled]"

/**
 * SetStoryLives(mob/players/P, datum/server_difficulty_config/config)
 * Set number of lives for Story continent
 * 
 * @param P: Admin player
 * @param config: Server config
 */
proc/SetStoryLives(mob/players/P, datum/server_difficulty_config/config)
	if(!config) return
	
	var/input_value = input(P, "Set Story continent lives (0=unlimited):", "Story Lives") as num
	if(input_value == null) return
	
	input_value = max(0, min(10, input_value))  // Clamp 0-10
	config.lives_per_continent["story"] = input_value
	var/display_text = input_value > 0 ? input_value : "unlimited"
	var/broadcast_text = input_value > 0 ? input_value : "unlimited"
	
	P << "<span class='good'>Story lives set to: [display_text]</span>"
	world << "<span class='info'>SERVER: Story continent lives set to [broadcast_text]</span>"
	world.log << "Story lives set to: [input_value]"

/**
 * SetSandboxLives(mob/players/P, datum/server_difficulty_config/config)
 * Set number of lives for Sandbox continent
 * 
 * @param P: Admin player
 * @param config: Server config
 */
proc/SetSandboxLives(mob/players/P, datum/server_difficulty_config/config)
	if(!config) return
	
	var/input_value = input(P, "Set Sandbox continent lives (0=unlimited, creative mode):", "Sandbox Lives") as num
	if(input_value == null) return
	
	input_value = max(0, min(10, input_value))  // Clamp 0-10
	config.lives_per_continent["sandbox"] = input_value
	var/display_text = input_value > 0 ? input_value : "unlimited"
	var/broadcast_text = input_value > 0 ? input_value : "unlimited"
	
	P << "<span class='good'>Sandbox lives set to: [display_text]</span>"
	world << "<span class='info'>SERVER: Sandbox continent lives set to [broadcast_text]</span>"
	world.log << "Sandbox lives set to: [input_value]"

/**
 * SetKingdomLives(mob/players/P, datum/server_difficulty_config/config)
 * Set number of lives for Kingdom continent
 * 
 * @param P: Admin player
 * @param config: Server config
 */
proc/SetKingdomLives(mob/players/P, datum/server_difficulty_config/config)
	if(!config) return
	
	var/input_value = input(P, "Set Kingdom continent lives (0=unlimited):", "Kingdom Lives") as num
	if(input_value == null) return
	
	input_value = max(0, min(10, input_value))  // Clamp 0-10
	config.lives_per_continent["kingdom"] = input_value
	var/display_text = input_value > 0 ? input_value : "unlimited"
	var/broadcast_text = input_value > 0 ? input_value : "unlimited"
	
	P << "<span class='good'>Kingdom lives set to: [display_text]</span>"
	world << "<span class='info'>SERVER: Kingdom continent lives set to [broadcast_text]</span>"
	world.log << "Kingdom lives set to: [input_value]"

/**
 * ResetConfigurationToDefaults(datum/server_difficulty_config/config)
 * Reset all difficulty settings to defaults
 * 
 * @param config: Server config
 */
proc/ResetConfigurationToDefaults(datum/server_difficulty_config/config)
	if(!config) return
	
	config.permadeath_enabled = 0
	config.lives_per_continent["story"] = 3
	config.lives_per_continent["sandbox"] = 0
	config.lives_per_continent["kingdom"] = 2
	
	world << "<span class='info'>SERVER: Difficulty settings reset to defaults.</span>"
	world.log << "Difficulty configuration reset to defaults"

/**
 * SaveServerConfiguration(datum/server_difficulty_config/config)
 * Save server configuration to savefile
 * Called on world boot and after changes
 * 
 * @param config: Server config to save
 */
proc/SaveServerConfiguration(datum/server_difficulty_config/config)
	if(!config) return
	
	var/savefile/F = new("data/server_config.sav")
	F["permadeath"] << config.permadeath_enabled
	F["lives_story"] << config.lives_per_continent["story"]
	F["lives_sandbox"] << config.lives_per_continent["sandbox"]
	F["lives_kingdom"] << config.lives_per_continent["kingdom"]
	
	world.log << "Server configuration saved to savefile"

/**
 * LoadServerConfiguration(datum/server_difficulty_config/config)
 * Load server configuration from savefile
 * Called on world boot
 * 
 * @param config: Server config to populate
 * @return: 1 if loaded, 0 if using defaults
 */
proc/LoadServerConfiguration(datum/server_difficulty_config/config)
	if(!config) return 0
	
	var/savefile/F = new("data/server_config.sav")
	if(!F)
		world.log << "No server config savefile found (using defaults)"
		return 0
	
	F["permadeath"] >> config.permadeath_enabled
	F["lives_story"] >> config.lives_per_continent["story"]
	F["lives_sandbox"] >> config.lives_per_continent["sandbox"]
	F["lives_kingdom"] >> config.lives_per_continent["kingdom"]
	
	world.log << "Server configuration loaded from savefile"
	return 1

// ============================================================================
// DIFFICULTY DISPLAY (HUD/STATUS)
// ============================================================================

/**
 * DisplayServerDifficultyStatus(mob/players/P)
 * Show player current server difficulty settings in login sequence
 * 
 * @param P: Player mob
 */
proc/DisplayServerDifficultyStatus(mob/players/P)
	if(!P) return
	
	var/datum/server_difficulty_config/config = GetServerDifficultyConfig()
	if(!config) return
	
	P << "\n<span class='warning'>═══════════════════════════════════════</span>"
	P << "<span class='warning'>SERVER DIFFICULTY SETTINGS</span>"
	P << "<span class='warning'>═══════════════════════════════════════</span>"
	
	if(config.permadeath_enabled)
		P << "<span class='danger'>⚠ PERMADEATH ENABLED ⚠</span>"
		P << "<span class='danger'>One death = Character reset. Play carefully!</span>"
	else
		P << "<span class='info'>Permadeath: Disabled</span>"
		P << "<span class='info'>Lives per continent:</span>"
		
		var/story_lives = config.lives_per_continent["story"]
		var/sandbox_lives = config.lives_per_continent["sandbox"]
		var/kingdom_lives = config.lives_per_continent["kingdom"]
		
		P << "<span class='info'>  • Story: [story_lives > 0 ? story_lives : "Unlimited"]</span>"
		P << "<span class='info'>  • Sandbox: [sandbox_lives > 0 ? sandbox_lives : "Unlimited"]</span>"
		P << "<span class='info'>  • Kingdom: [kingdom_lives > 0 ? kingdom_lives : "Unlimited"]</span>"
	
	P << "<span class='warning'>═══════════════════════════════════════</span>\n"

// ============================================================================
// SERVER BOOT INITIALIZATION
// ============================================================================

/**
 * BootServerDifficultySystem()
 * Initialize server difficulty system at world startup
 * Load config from savefile or use defaults
 * Called from InitializationManager.dm
 */
proc/BootServerDifficultySystem()
	var/datum/server_difficulty_config/config = GetServerDifficultyConfig()
	if(!config) return
	
	// Try to load from savefile
	var/loaded = LoadServerConfiguration(config)
	
	if(loaded)
		world.log << "Server difficulty system booted (config loaded from savefile)"
	else
		world.log << "Server difficulty system booted (using default configuration)"
		world.log << "  Permadeath: [config.permadeath_enabled]"
		world.log << "  Story Lives: [config.lives_per_continent["story"]]"
		world.log << "  Sandbox Lives: [config.lives_per_continent["sandbox"]]"
		world.log << "  Kingdom Lives: [config.lives_per_continent["kingdom"]]"

