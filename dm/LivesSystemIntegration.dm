// LivesSystemIntegration.dm - Lives Tracking & Character Reset on Death
// Integrates with DeathPenaltySystem.dm to track lives per continent
// When lives exhausted OR permadeath enabled: Character reset (respawn at port)

// ============================================================================
// LIVES SYSTEM CONFIGURATION
// ============================================================================

/**
 * ServerDifficultyConfig
 * Server-wide difficulty settings (permadeath, lives limits)
 * Set at world startup via host configuration
 */
/datum/server_difficulty_config
	var
		// Permadeath toggle
		permadeath_enabled = 0      // 1=ON (any death=permadeath), 0=OFF (uses lives system)
		
		// Lives per continent (if permadeath OFF)
		lives_per_continent = list(
			"story" = 3,            // Story has 3 lives
			"sandbox" = 0,          // Sandbox has no deaths (creative mode)
			"kingdom" = 2           // Kingdom has 2 lives (hardest)
		)
		
		// Grace period after death before character reset
		respawn_grace_period = 300  // Ticks (5 minutes at 25ms/tick)

/**
 * Global server config instance
 */
var/global/datum/server_difficulty_config/world_difficulty_config = null

/**
 * InitializeServerDifficultyConfig()
 * Boot server difficulty configuration
 * Called from InitializationManager.dm
 */
proc/InitializeServerDifficultyConfig()
	world_difficulty_config = new /datum/server_difficulty_config()
	RegisterInitComplete("server_difficulty_config")

/**
 * GetServerDifficultyConfig()
 * Get global difficulty config
 */
proc/GetServerDifficultyConfig()
	if(!world_difficulty_config)
		InitializeServerDifficultyConfig()
	return world_difficulty_config

/**
 * SetPermadeathEnabled(enabled)
 * Server host sets permadeath toggle
 * 
 * @param enabled: 1=permadeath ON, 0=permadeath OFF (uses lives)
 */
proc/SetPermadeathEnabled(enabled)
	var/datum/server_difficulty_config/config = GetServerDifficultyConfig()
	if(!config) return
	
	config.permadeath_enabled = (enabled == 1) ? 1 : 0
	world.log << "Server permadeath setting: [config.permadeath_enabled ? "ON" : "OFF"]"

/**
 * SetLivesPerContinent(continent, lives)
 * Server host sets lives limit for a continent
 * 
 * @param continent: "story", "sandbox", "kingdom"
 * @param lives: Number of lives (0=infinite, 1+=limited)
 */
proc/SetLivesPerContinent(continent, lives)
	var/datum/server_difficulty_config/config = GetServerDifficultyConfig()
	if(!config) return
	
	if(!config.lives_per_continent[continent])
		config.lives_per_continent[continent] = 0
	
	config.lives_per_continent[continent] = max(0, lives)
	world.log << "Server: [continent] continent lives set to [lives]"

// ============================================================================
// CHARACTER DEATH TRACKING
// ============================================================================

/**
 * NOTE: character_data already includes death/lives fields from CharacterData.dm:
 * - death_count
 * - is_fainted
 * - death_marks
 * - faint_location
 * - faint_time
 * No need to extend again here - variables already defined
 */

/**
 * IncrementDeathMark(mob/players/P, continent)
 * Increment death count for a continent
 * Called when player dies in that continent
 * 
 * @param P: Player mob
 * @param continent: "story", "sandbox", "kingdom"
 */
proc/IncrementDeathMark(mob/players/P, continent)
	if(!P || !P.character) return
	
	if(!P.character.death_marks[continent])
		P.character.death_marks[continent] = 0
	
	P.character.death_marks[continent]++

/**
 * GetDeathMarksForContinent(mob/players/P, continent)
 * Get current death mark count for continent
 * 
 * @param P: Player mob
 * @param continent: "story", "sandbox", "kingdom"
 * @return: Current death count
 */
proc/GetDeathMarksForContinent(mob/players/P, continent)
	if(!P || !P.character) return 0
	
	if(!P.character.death_marks[continent])
		P.character.death_marks[continent] = 0
	
	return P.character.death_marks[continent]

/**
 * GetLivesRemaining(mob/players/P, continent)
 * Calculate remaining lives for continent
 * 
 * @param P: Player mob
 * @param continent: "story", "sandbox", "kingdom"
 * @return: Lives remaining (0 = exhausted, -1 = unlimited)
 */
proc/GetLivesRemaining(mob/players/P, continent)
	if(!P || !P.character) return 0
	
	var/datum/server_difficulty_config/config = GetServerDifficultyConfig()
	if(!config) return 0
	
	// If permadeath enabled, any death = character reset
	if(config.permadeath_enabled)
		return 0  // No lives in permadeath mode
	
	// Get configured lives limit for continent
	var/max_lives = config.lives_per_continent[continent]
	if(!max_lives)
		return -1  // Unlimited lives
	
	// Calculate remaining
	var/current_marks = GetDeathMarksForContinent(P, continent)
	var/remaining = max(0, max_lives - current_marks)
	
	return remaining

// ============================================================================
// INTEGRATION WITH DEATH PENALTY SYSTEM
// ============================================================================

/**
 * CheckAndApplyDeathConsequence(mob/players/P, attacker)
 * Centralized death consequence logic
 * Determines: Fainted state vs character reset
 * Called from HandlePlayerDeath() in DeathPenaltySystem.dm
 * 
 * @param P: Player mob
 * @param attacker: Who caused death
 * @return: "fainted" = await revival, "reset" = character reset
 */
proc/CheckAndApplyDeathConsequence(mob/players/P, mob/attacker)
	if(!P || !P.character) return "error"
	
	var/datum/server_difficulty_config/config = GetServerDifficultyConfig()
	if(!config)
		return "fainted"  // Default to fainted
	
	var/continent = P.current_continent
	if(!continent) continent = "story"  // Default
	
	// CASE 1: Permadeath enabled
	if(config.permadeath_enabled)
		// Any death = character reset
		return "reset"
	
	// CASE 2: Lives system enabled
	var/max_lives = config.lives_per_continent[continent]
	if(max_lives > 0)
		// Increment death mark
		IncrementDeathMark(P, continent)
		var/current_marks = GetDeathMarksForContinent(P, continent)
		
		// Check if lives exhausted
		if(current_marks >= max_lives)
			// Lives exhausted = reset
			return "reset"
		else
			// Lives remain = fainted state
			P << "<span class='warning'>Death Mark: [current_marks]/[max_lives] (You can be revived)</span>"
			return "fainted"
	
	// CASE 3: Unlimited lives
	return "fainted"

/**
 * ResetCharacterOnDeath(mob/players/P)
 * Hard reset character after lives exhausted or permadeath
 * Respawns at port for new character creation
 * Preserves: Skills, recipes, knowledge, prestige status
 * Resets: Inventory, equipment, vitals, appearance, death marks
 * 
 * @param P: Player mob
 */
proc/ResetCharacterOnDeath(mob/players/P)
	if(!P || !P.character) return
	
	world << "<span class='danger'>[P.name]'s character has been reset!</span>"
	
	// Backup persistent data (survives reset)
	var/list/saved_skills = list()
	var/list/saved_recipes = list()
	var/list/saved_knowledge = list()
	var/list/saved_crafter_titles = list()
	
	// Manual copy to preserve lists
	for(var/i in P.character.skills)
		saved_skills += P.character.skills[i]
	for(var/i in P.character.recipes)
		saved_recipes += P.character.recipes[i]
	for(var/i in P.character.knowledge)
		saved_knowledge += P.character.knowledge[i]
	for(var/i in P.character.crafter_titles)
		saved_crafter_titles += P.character.crafter_titles[i]
	
	var/saved_prestige = P.character.has_prestige
	var/saved_prestige_source = P.character.prestige_unlock_source
	var/saved_prestige_title = P.character.prestige_title
	
	// Clear inventory & equipment
	P.contents = list()
	P.equipped_items = list()
	
	// Reset vitals
	P.HP = P.MAXHP
	P.stamina = P.MAXstamina
	P.hunger_level = 0  // Use hunger_level (defined in Basics.dm)
	P.thirst_level = 0  // Use thirst_level (defined in Basics.dm)
	
	// Reset appearance (back to blank base)
	ResetAppearanceToBlank(P)
	
	// Clear continent-specific death marks
	P.character.death_marks = list()
	
	// Prompt gender re-selection
	P << "\n<span class='info'>═══════════════════════════════════════</span>"
	P << "<span class='info'>CHARACTER RESET</span>"
	P << "<span class='info'>═══════════════════════════════════════</span>"
	P << "<span class='good'>Your skills, recipes, and knowledge are preserved.</span>"
	P << "<span class='info'>Select your gender to begin anew:</span>"
	P << "<span class='info'>Male or Female</span>"
	
	var/gender_input = input(P, "Select gender (Male/Female):", "Gender") in list("Male", "Female")
	if(!gender_input) return  // Cancelled
	
	if(gender_input == "Male")
		ApplyBlankAvatarAppearance(P, GENDER_MALE)
	else if(gender_input == "Female")
		ApplyBlankAvatarAppearance(P, GENDER_FEMALE)
	
	// Restore persistent data
	P.character.skills = saved_skills
	P.character.recipes = saved_recipes
	P.character.knowledge = saved_knowledge
	P.character.has_prestige = saved_prestige
	P.character.prestige_unlock_source = saved_prestige_source
	P.character.prestige_title = saved_prestige_title
	P.character.crafter_titles = saved_crafter_titles
	
	// Teleport to port for new character experience
	P.loc = GetPortHubCenter()
	
	P << "<span class='good'>═══════════════════════════════════════</span>"
	P << "<span class='good'>You are back at the Port Lobby.</span>"
	P << "<span class='good'>Ready for a new adventure!</span>"
	P << "<span class='good'>═══════════════════════════════════════</span>"

/**
 * RespawnAfterRevival(mob/players/P, continent)
 * Respawn fainted player at rally point after revival
 * Called when Abjure spell revives player
 * 
 * @param P: Player mob
 * @param continent: Current continent ("story", "sandbox", "kingdom")
 */
proc/RespawnAfterRevival(mob/players/P, continent)
	if(!P) return
	
	// Get continent-specific rally point
	var/turf/rally_point = GetContinentRallyPoint(continent)
	if(rally_point)
		P.loc = rally_point
		P << "<span class='good'>You have been revived and respawned at the rally point.</span>"
	else
		// Fallback to continent spawn
		var/turf/spawn_loc = GetContinentSpawnPoint(continent)
		if(spawn_loc)
			P.loc = spawn_loc

/**
 * GetContinentRallyPoint(continent)
 * Get rally point (revival spawn) for continent
 * Rally point = where players respawn after revival (different from initial spawn)
 * 
 * @param continent: "story", "sandbox", "kingdom"
 * @return: Rally point turf or null
 */
// NOTE: GetContinentRallyPoint is defined in ContinentSpawnZones.dm (Phase 2 modern system)
// Using that implementation instead of duplicating here
/*
proc/GetContinentRallyPoint(continent)
	switch(continent)
		if("story")
			return /turf/story_rally_point  // Story rally point
		if("sandbox")
			return /turf/sandbox_rally_point  // Sandbox rally point
		if("kingdom")
			return /turf/kingdom_rally_point  // Kingdom rally point
		else
			return GetContinentSpawnPoint(continent)  // Fallback to spawn
	
	return null
*/

// ============================================================================
// HOOK INTO EXISTING DEATH SYSTEM
// ============================================================================

/**
 * Extend existing death system with lives integration
 * This is called from DeathPenaltySystem.HandlePlayerDeath()
 */
/datum/death_penalty_manager/proc/ApplyLivesSystemLogic(mob/players/P, mob/attacker)
	if(!P || !P.character) return
	
	// Determine consequence (fainted vs reset)
	var/consequence = CheckAndApplyDeathConsequence(P, attacker)
	
	switch(consequence)
		if("fainted")
			// Standard two-death system applies
			// HandlePlayerDeath continues as normal
			return
		
		if("reset")
			// Hard reset on death
			ResetCharacterOnDeath(P)
			return
		
		if("error")
			// Fallback: fainted state
			return

// ============================================================================
// DEATH DISPLAY & NOTIFICATIONS
// ============================================================================

/**
 * DisplayDeathStatus(mob/players/P)
 * Show player their death status and lives remaining
 */
proc/DisplayDeathStatus(mob/players/P)
	if(!P || !P.character) return
	
	var/datum/server_difficulty_config/config = GetServerDifficultyConfig()
	if(!config) return
	
	if(config.permadeath_enabled)
		P << "<span class='danger'>⚠ Server Mode: PERMADEATH ENABLED ⚠</span>"
		P << "<span class='danger'>One death = Character reset. Play carefully!</span>"
	else
		var/continent = P.current_continent
		if(!continent) continent = "story"
		
		var/max_lives = config.lives_per_continent[continent]
		if(max_lives > 0)
			var/current_marks = GetDeathMarksForContinent(P, continent)
			var/remaining = max(0, max_lives - current_marks)
			
			P << "<span class='warning'>Lives: [remaining]/[max_lives]</span>"
		else
			P << "<span class='info'>Lives: Unlimited</span>"

