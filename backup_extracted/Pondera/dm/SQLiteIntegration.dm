// dm/SQLiteIntegration.dm
// SQLite Login/Logout Integration
// Wires character persistence into Pondera's login flow
// Version: 1.0
// Date: 2025-12-17

// ============================================================================
// LOGIN INTEGRATION - Load from SQLite on character spawn
// ============================================================================

/**
 * /mob/players/OnLogin()
 * Called when player character is spawned
 * Restores character data from SQLite if exists
 */
/mob/players/proc/OnLogin()
	if(!src || !src.key)
		return FALSE

	world.log << "\[Login Integration\] Player [src.key] logging in..."

	// Attempt to load character data from SQLite
	var/list/db_char_data = LoadPlayerFromSQLite(src.key)

	if(db_char_data)
		// Player has existing data - restore from database
		world.log << "\[Login Integration\] ✓ Restoring character from database"

		if(!RestoreCharacterFromSQLite(src, db_char_data))
			world.log << "\[Login Integration WARNING\] Failed to restore all data, proceeding with partial restore"
	else
		// New player - create fresh character data
		world.log << "\[Login Integration\] New player detected, creating fresh character"
		if(!src.character)
			src.character = new /datum/character_data()

	// Mark player as online in database
	ExecuteSQLiteQuery("UPDATE players SET online_status = 1, last_login = datetime('now') WHERE ckey='[EscapeSQLString(src.key)]';")

	world.log << "\[Login Integration COMPLETE\] [src.key]"
	return TRUE

/**
 * RestoreCharacterFromSQLite(mob/players/P, list/db_char_data)
 * Restore all character data from SQLite to player object
 */
proc/RestoreCharacterFromSQLite(mob/players/P, list/db_char_data)
	if(!P)
		return FALSE
	
	if(!db_char_data)
		return FALSE

	try
		// Restore/create character datum
		if(!P.character)
			P.character = new /datum/character_data()

		var/datum/character_data/char = P.character

		// Basic character info
		char.selected_class = ExtractJSONField(db_char_data, "char_name", "Unknown")
		char.game_mode = ExtractJSONField(db_char_data, "game_mode", "story")
		char.current_continent = ExtractJSONField(db_char_data, "current_continent", "story")

		// Level (if player object has level support)
		if("level" in db_char_data)
			P.level = db_char_data["level"]

		// Death tracking
		char.death_count = ExtractJSONField(db_char_data, "death_count", 0)

		// Restore skills
		if("skills" in db_char_data && islist(db_char_data["skills"]))
			var/list/skills = db_char_data["skills"]
			if("frank" in skills) { char.frank = skills["frank"]["rank_level"]; char.frankEXP = skills["frank"]["current_exp"]; char.frankMAXEXP = skills["frank"]["max_exp_threshold"] }
			if("crank" in skills) { char.crank = skills["crank"]["rank_level"]; char.crankEXP = skills["crank"]["current_exp"]; char.crankMAXEXP = skills["crank"]["max_exp_threshold"] }
			if("grank" in skills) { char.grank = skills["grank"]["rank_level"]; char.grankEXP = skills["grank"]["current_exp"]; char.grankMAXEXP = skills["grank"]["max_exp_threshold"] }
			if("hrank" in skills) { char.hrank = skills["hrank"]["rank_level"]; char.hrankEXP = skills["hrank"]["current_exp"]; char.hrankMAXEXP = skills["hrank"]["max_exp_threshold"] }
			if("mrank" in skills) { char.mrank = skills["mrank"]["rank_level"]; char.mrankEXP = skills["mrank"]["current_exp"]; char.mrankMAXEXP = skills["mrank"]["max_exp_threshold"] }
			if("smirank" in skills) { char.smirank = skills["smirank"]["rank_level"]; char.smirankEXP = skills["smirank"]["current_exp"]; char.smirankMAXEXP = skills["smirank"]["max_exp_threshold"] }
			if("smerank" in skills) { char.smerank = skills["smerank"]["rank_level"]; char.smerankEXP = skills["smerank"]["current_exp"]; char.smerankMAXEXP = skills["smerank"]["max_exp_threshold"] }
			if("brank" in skills) { char.brank = skills["brank"]["rank_level"]; char.brankEXP = skills["brank"]["current_exp"]; char.brankMAXEXP = skills["brank"]["max_exp_threshold"] }
			if("drank" in skills) { char.drank = skills["drank"]["rank_level"]; char.drankEXP = skills["drank"]["current_exp"]; char.drankMAXEXP = skills["drank"]["max_exp_threshold"] }
			world.log << "\[SQLite Restore\] ✓ Restored [length(skills)] skills"

		// Restore currency
		if("currency" in db_char_data && islist(db_char_data["currency"]))
			var/list/currency = db_char_data["currency"]
			P.lucre = ExtractJSONField(currency, "lucre", 0)
			P.bankedlucre = ExtractJSONField(currency, "banked_lucre", 0)
			P.basecamp_stone = ExtractJSONField(currency, "stone", 0)
			world.log << "\[SQLite Restore\] ✓ Restored currency: [P.lucre] lucre, [P.basecamp_stone] stone"

		// Restore appearance
		if("appearance" in db_char_data && islist(db_char_data["appearance"]))
			var/list/appearance = db_char_data["appearance"]
			char.gender = ExtractJSONField(appearance, "gender", "M")
			char.appearance_locked = ExtractJSONField(appearance, "is_locked", FALSE)
			world.log << "\[SQLite Restore\] ✓ Restored appearance"

		// Restore continent positions
		if("positions" in db_char_data && islist(db_char_data["positions"]))
			var/list/positions = db_char_data["positions"]
			if(!char.continent_positions)
				char.continent_positions = list()
			char.continent_positions = positions.Copy()  // Copy to avoid reference issues
			world.log << "\[SQLite Restore\] ✓ Restored [length(positions)] continent positions"

		return TRUE

	catch(var/exception/e)
		world.log << "\[SQLite Restore ERROR\] Exception: [e.name] - [e.desc]"
		return FALSE

// ============================================================================
// LOGOUT INTEGRATION - Save to SQLite on disconnect
// ============================================================================

/**
 * /client/Del()
 * Called when client disconnects
 * Saves character to SQLite before cleanup
 */
/client/Del()
	if(mob && ismob(mob) && istype(mob, /mob/players))
		var/mob/players/P = mob
		OnLogout(P)

	return ..()

/**
 * OnLogout(mob/players/P)
 * Save player character data to SQLite
 */
proc/OnLogout(mob/players/P)
	if(!P || !P.key || !P.character)
		return FALSE

	world.log << "\[Logout Integration\] Saving player [P.key] to database..."

	// Save to SQLite
	if(!SavePlayerToSQLite(P))
		world.log << "\[Logout Integration ERROR\] Failed to save [P.key]"
		return FALSE

	// Mark player as offline in database
	var/safe_ckey = EscapeSQLString(P.key)
	ExecuteSQLiteQuery("UPDATE players SET online_status = 0, last_logout = datetime('now') WHERE ckey='[safe_ckey]';")

	world.log << "\[Logout Integration COMPLETE\] ✓ [P.key] saved and marked offline"
	return TRUE

// ============================================================================
// STARTUP INTEGRATION - Call SQLite init from InitializationManager
// ============================================================================

/**
 * AddSQLiteInitialization()
 * Register SQLite initialization with the initialization manager
 * This is called from InitializationManager.dm during world boot
 */
proc/RegisterSQLiteInitialization()
	// Initialize SQLite database
	if(!InitializeSQLiteDatabase())
		world.log << "\[SQLite\] ⚠️ WARNING: SQLite initialization failed - character persistence disabled"
		return FALSE

	// Register as complete
	RegisterInitComplete("sqlite_database")
	return TRUE

// ============================================================================
// END OF SQLITE INTEGRATION
// ============================================================================
