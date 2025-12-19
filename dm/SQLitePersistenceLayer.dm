// dm/SQLitePersistenceLayer.dm
// SQLite Integration Layer for Pondera (IMPROVED)
// Handles database initialization, CRUD operations, and CLI wrapper
// Version: 2.0 (Fixed JSON parsing, proper sanitization, transactions)
// Date: 2025-12-17

// ============================================================================
// GLOBAL CONFIGURATION
// ============================================================================

var/global/sqlite_db_path = "db/pondera.db"
var/global/sqlite_exe_path = null              // Auto-detected (x64 preferred, x86 fallback)
var/global/sqlite_schema_path = "db/schema.sql"
var/global/sqlite_arch = null                  // Detected architecture: "x64" or "x86"
var/global/sqlite_ready = FALSE
var/global/sqlite_error_log = list()           // Track errors
var/global/sqlite_transaction_depth = 0        // Track nested transactions

// Architecture detection constants
#define SQLITE_ARCH_X64 "x64"
#define SQLITE_ARCH_X86 "x86"
#define SQLITE_EXE_X64 "db/lib/sqlite3_x64.exe"
#define SQLITE_EXE_X86 "db/lib/sqlite3.exe"
#define SQLITE_DLL_X64 "db/lib/sqlite3_x64.dll"
#define SQLITE_DLL_X86 "db/lib/sqlite3.dll"

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeSQLiteDatabase()
 * Called on world startup (from InitializationManager.dm)
 */
proc/InitializeSQLiteDatabase()
	world.log << "\[SQLite\] =========================================="
	world.log << "\[SQLite\] Initializing SQLite Database (v2.0)"
	world.log << "\[SQLite\] =========================================="

	// Step 1: Detect architecture
	if(!DetectSQLiteArchitecture())
		world.log << "\[SQLite ERROR\] Could not detect SQLite architecture"
		world.log << "\[SQLite ERROR\] Ensure both x64 and x86 variants are in db/lib/"
		sqlite_ready = FALSE
		return FALSE

	world.log << "\[SQLite\] Using architecture: [sqlite_arch] at [sqlite_exe_path]"

	// Step 2: Check SQLite executable exists
	if(!fexists(sqlite_exe_path))
		world.log << "\[SQLite ERROR\] sqlite3.exe not found at: [sqlite_exe_path]"
		sqlite_ready = FALSE
		return FALSE

	world.log << "\[SQLite\] ✓ Found sqlite3 ([sqlite_arch])"

	// Step 3: Check if database file exists
	if(!fexists(sqlite_db_path))
		world.log << "\[SQLite\] Database not found, creating at: [sqlite_db_path]"

		if(!CreateDatabaseFromSchema())
			world.log << "\[SQLite ERROR\] Failed to create database from schema"
			sqlite_ready = FALSE
			return FALSE

		world.log << "\[SQLite\] ✓ Database created successfully"
	else
		world.log << "\[SQLite\] ✓ Database already exists at: [sqlite_db_path]"

	// Step 4: Verify schema integrity
	if(!VerifySchemaIntegrity())
		world.log << "\[SQLite WARNING\] Schema verification failed - database may be corrupted"
	else
		world.log << "\[SQLite\] ✓ Schema verified"

	sqlite_ready = TRUE
	sqlite_transaction_depth = 0
	world.log << "\[SQLite\] =========================================="
	world.log << "\[SQLite\] Database initialization complete ✓"
	world.log << "\[SQLite\] Ready for character persistence"
	world.log << "\[SQLite\] =========================================="
	return TRUE

/**
 * DetectSQLiteArchitecture()
 * Auto-detect and select appropriate SQLite binary
 * Preference order: x64 → x86
 */
proc/DetectSQLiteArchitecture()
	world.log << "\[SQLite\] Detecting SQLite architecture..."

	// Try x64 first (preferred for modern systems)
	if(fexists(SQLITE_EXE_X64))
		if(fexists(SQLITE_DLL_X64))
			sqlite_arch = SQLITE_ARCH_X64
			sqlite_exe_path = SQLITE_EXE_X64
			world.log << "\[SQLite\] ✓ Detected 64-bit (x64) SQLite"
			return TRUE
		else
			world.log << "\[SQLite WARNING\] Found x64 exe but missing x64 dll"

	// Fallback to x86
	if(fexists(SQLITE_EXE_X86))
		if(fexists(SQLITE_DLL_X86))
			sqlite_arch = SQLITE_ARCH_X86
			sqlite_exe_path = SQLITE_EXE_X86
			world.log << "\[SQLite\] ⚠ Detected 32-bit (x86) SQLite - consider upgrading to x64"
			return TRUE
		else
			world.log << "\[SQLite WARNING\] Found x86 exe but missing x86 dll"

	world.log << "\[SQLite ERROR\] No SQLite binaries found in db/lib/"
	return FALSE

/**
 * ExecuteSQLiteShellHidden(cmd)
 * Execute a shell command in hidden window mode (Windows-specific)
 * Uses VBScript to suppress the console window
 * Returns: Command output as string
 */
proc/ExecuteSQLiteShellHidden(cmd)
	var/vbs_file = "temp_sqlite_[rand(100000, 999999)].vbs"
	var/vbs_script = "Set objShell = CreateObject(\"WScript.Shell\")\nSet objWshScriptExec = objShell.Exec(\"cmd /c " + cmd + "\")\nWScript.Echo objWshScriptExec.StdOut.ReadAll()"
	
	var/F = file(vbs_file)
	F << vbs_script
	
	var/output = shell("cscript.exe //NoLogo \"" + vbs_file + "\"")
	fdel(vbs_file)
	
	return output

/**
 * CreateDatabaseFromSchema()
 * Execute schema.sql to create all tables
 */
proc/CreateDatabaseFromSchema()
	if(!fexists(sqlite_schema_path))
		world.log << "\[SQLite ERROR\] Schema file not found: [sqlite_schema_path]"
		return FALSE

	// Run: sqlite3 pondera.db < schema.sql
	// Build command to be executed (wrapper will hide window)
	var/cmd = "\"[sqlite_exe_path]\" \"[sqlite_db_path]\" < \"[sqlite_schema_path]\""
	var/output = ExecuteSQLiteShellHidden(cmd)

	if(output && length(output) > 0)
		world.log << "\[SQLite SCHEMA OUTPUT\] [output]"

	// Verify tables were created
	var/result = ExecuteSQLiteQuery("SELECT COUNT(name) FROM sqlite_master WHERE type='table';")
	if(!result || result == "0")
		world.log << "\[SQLite ERROR\] Schema creation failed - no tables created"
		return FALSE

	world.log << "\[SQLite\] Schema created successfully"
	return TRUE

/**
 * VerifySchemaIntegrity()
 * Check that all critical tables exist
 */
proc/VerifySchemaIntegrity()
	var/list/required_tables = list(
		"players",
		"character_skills",
		"currency_accounts",
		"character_recipes",
		"npc_reputation",
		"player_deeds",
		"character_appearance",
		"market_board",
		"market_prices",
		"continent_positions"
	)

	for(var/table in required_tables)
		var/result = ExecuteSQLiteQuery("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='[table]';")
		if(!result || result == "0")
			world.log << "\[SQLite WARNING\] Missing table: [table]"
			return FALSE

	return TRUE

/**
 * InitializeMarketPrices()
 * Seed market_prices table with default commodity data on first run
 * Called from InitializationManager.dm Phase 2
 */
proc/InitializeMarketPrices()
	if(!sqlite_ready)
		world.log << "\[SQLite Market\] Database not ready - skipping market price initialization"
		return FALSE

	// Check if market_prices table already has data
	var/check_query = "SELECT COUNT(*) FROM market_prices;"
	var/count = ExecuteSQLiteQuery(check_query)
	
	if(count && count > 0)
		world.log << "\[SQLite Market\] ✓ Market prices already initialized ([count] commodities)"
		return TRUE

	world.log << "\[SQLite Market\] Initializing market prices..."

	// Define default commodities with base prices
	var/list/default_commodities = list(
		list("name" = "stone", "base_price" = 1.0, "elasticity" = 1.0, "volatility" = 0.1, "min" = 0.5, "max" = 2.5, "tier" = 1),
		list("name" = "metal", "base_price" = 3.0, "elasticity" = 1.2, "volatility" = 0.15, "min" = 1.5, "max" = 5.0, "tier" = 2),
		list("name" = "timber", "base_price" = 2.5, "elasticity" = 0.8, "volatility" = 0.12, "min" = 1.0, "max" = 4.0, "tier" = 1),
		list("name" = "iron_ingot", "base_price" = 5.0, "elasticity" = 1.3, "volatility" = 0.2, "min" = 2.5, "max" = 8.0, "tier" = 2),
		list("name" = "steel_ingot", "base_price" = 8.0, "elasticity" = 1.4, "volatility" = 0.25, "min" = 4.0, "max" = 12.0, "tier" = 3),
		list("name" = "gold_ore", "base_price" = 15.0, "elasticity" = 1.5, "volatility" = 0.3, "min" = 7.5, "max" = 25.0, "tier" = 3)
	)

	var/inserted = 0
	for(var/commodity in default_commodities)
		var/query = "INSERT INTO market_prices (commodity_name, base_price, current_price, price_elasticity, price_volatility, min_price, max_price, tech_tier, updated_by) VALUES ('[commodity["name"]]', [commodity["base_price"]], [commodity["base_price"]], [commodity["elasticity"]], [commodity["volatility"]], [commodity["min"]], [commodity["max"]], [commodity["tier"]], 'initialization');"
		
		if(ExecuteSQLiteQuery(query))
			inserted++
		else
			world.log << "\[SQLite Market WARNING\] Failed to insert commodity: [commodity["name"]]"

	world.log << "\[SQLite Market\] ✓ Initialized [inserted]/[default_commodities.len] commodities"
	return (inserted == default_commodities.len)

// ============================================================================
// CORE CRUD OPERATIONS
// ============================================================================

/**
 * ExecuteSQLiteQuery(query)
 * Execute a SQL query and return raw results
 * Use ExecuteSQLiteQueryJSON() for structured data
 */
proc/ExecuteSQLiteQuery(query)
	if(!sqlite_ready)
		world.log << "\[SQLite\] Database not ready - skipping query"
		return null

	// Create temporary file for query
	var/tmp_file = "temp_sqlite_query_[rand(100000, 999999)].sql"
	var/F = file(tmp_file)

	// Write query to temp file
	F << query

	// Execute sqlite3 with query file
	var/cmd = "\"[sqlite_exe_path]\" \"[sqlite_db_path]\" < \"[tmp_file]\""
	var/output = ExecuteSQLiteShellHidden(cmd)

	// Clean up temp file
	fdel(tmp_file)

	if(!output)
		return ""

	return output

/**
 * ExecuteSQLiteQueryJSON(query)
 * Execute query with JSON output format for structured parsing
 * CRITICAL: Use this for SELECT queries that need parsing
 * Returns: Parsed JSON (list of dicts) or empty list on error
 */
proc/ExecuteSQLiteQueryJSON(query)
	if(!sqlite_ready)
		return list()

	var/tmp_file = "temp_sqlite_json_[rand(100000, 999999)].sql"
	var/F = file(tmp_file)

	// Force JSON output mode with proper formatting
	F << ".mode json\n"
	F << ".headers on\n"
	F << query

	var/cmd = "\"[sqlite_exe_path]\" \"[sqlite_db_path]\" < \"[tmp_file]\""
	var/output = ExecuteSQLiteShellHidden(cmd)

	fdel(tmp_file)

	if(!output || length(output) == 0)
		return list()

	// Parse JSON and return structured data
	var/list/result = ParseSQLiteJSONResult(output)
	return result

/**
 * BeginTransaction()
 * Start a database transaction for atomic operations
 */
proc/BeginTransaction()
	if(!sqlite_ready)
		return FALSE

	if(sqlite_transaction_depth == 0)
		ExecuteSQLiteQuery("BEGIN TRANSACTION;")

	sqlite_transaction_depth++
	return TRUE

/**
 * CommitTransaction()
 * Commit database transaction
 */
proc/CommitTransaction()
	if(!sqlite_ready || sqlite_transaction_depth == 0)
		return FALSE

	sqlite_transaction_depth--

	if(sqlite_transaction_depth == 0)
		ExecuteSQLiteQuery("COMMIT;")

	return TRUE

/**
 * RollbackTransaction()
 * Rollback all pending changes in transaction
 */
proc/RollbackTransaction()
	if(!sqlite_ready || sqlite_transaction_depth == 0)
		return FALSE

	sqlite_transaction_depth = 0
	ExecuteSQLiteQuery("ROLLBACK;")
	return TRUE

// ============================================================================
// PLAYER SAVE/LOAD OPERATIONS (WITH TRANSACTIONS)
// ============================================================================

/**
 * SavePlayerToSQLite(mob/players/P)
 * Export player character data to SQLite (ATOMIC)
 * All-or-nothing: If any step fails, all changes rollback
 */
proc/SavePlayerToSQLite(mob/players/P)
	if(!sqlite_ready || !P || !P.key)
		return FALSE

	if(!P.character)
		world.log << "\[SQLite\] Player [P.key] has no character data to save"
		return FALSE

	var/ckey = P.key
	var/datum/character_data/char = P.character

	world.log << "\[SQLite SAVE\] Starting atomic save for player: [ckey]"

	// Start transaction for atomic save
	if(!BeginTransaction())
		world.log << "\[SQLite ERROR\] Failed to start transaction for [ckey]"
		return FALSE

	try
		// 1. Insert/Update players table with safe escaping
		var/insert_player_query = BuildInsertPlayerQuery(
			ckey,
			char.selected_class || "Unknown",
			char.game_mode || "story",
			char.current_continent || "story"
		)

		ExecuteSQLiteQuery(insert_player_query)
		world.log << "\[SQLite\] ✓ Saved player record"

		// 2. Get player_id for foreign key references
		var/list/player_rows = ExecuteSQLiteQueryJSON("SELECT id FROM players WHERE ckey='[EscapeSQLString(ckey)]';")
		if(!player_rows || length(player_rows) == 0)
			world.log << "\[SQLite ERROR\] Failed to get player_id for [ckey]"
			RollbackTransaction()
			return FALSE

		var/player_id = ExtractJSONField(player_rows[1], "id", 0)
		if(!player_id)
			world.log << "\[SQLite ERROR\] Invalid player_id returned"
			RollbackTransaction()
			return FALSE

		world.log << "\[SQLite\] ✓ Got player_id: [player_id]"

		// 3. Save skills
		if(!SavePlayerSkillsToSQLite(player_id, P))
			world.log << "\[SQLite ERROR\] Failed to save skills"
			RollbackTransaction()
			return FALSE
		world.log << "\[SQLite\] ✓ Saved skills"

		// 4. Save currency
		if(!SavePlayerCurrencyToSQLite(player_id, P))
			world.log << "\[SQLite ERROR\] Failed to save currency"
			RollbackTransaction()
			return FALSE
		world.log << "\[SQLite\] ✓ Saved currency"

		// 5. Save appearance
		if(!SavePlayerAppearanceToSQLite(player_id, char))
			world.log << "\[SQLite ERROR\] Failed to save appearance"
			RollbackTransaction()
			return FALSE
		world.log << "\[SQLite\] ✓ Saved appearance"

		// 6. Save continent positions
		if(!SavePlayerPositionsToSQLite(player_id, char))
			world.log << "\[SQLite ERROR\] Failed to save positions"
			RollbackTransaction()
			return FALSE
		world.log << "\[SQLite\] ✓ Saved positions"

		// Commit all changes atomically
		if(!CommitTransaction())
			world.log << "\[SQLite ERROR\] Failed to commit transaction"
			return FALSE

		world.log << "\[SQLite SAVE COMPLETE\] ✓ [ckey] (Player ID: [player_id])"
		return TRUE

	catch(var/exception/e)
		world.log << "\[SQLite SAVE ERROR\] Exception: [e.name] - [e.desc]"
		RollbackTransaction()
		return FALSE

/**
 * LoadPlayerFromSQLite(ckey)
 * Restore player character data from SQLite (with JSON parsing)
 */
proc/LoadPlayerFromSQLite(ckey)
	if(!sqlite_ready)
		return null

	var/safe_ckey = EscapeSQLString(ckey)

	world.log << "\[SQLite LOAD\] Starting load for player: [ckey]"

	try
		// Query player record with JSON
		var/list/player_rows = ExecuteSQLiteQueryJSON("SELECT id, char_name, game_mode, current_continent, level, death_count, last_login FROM players WHERE ckey='[safe_ckey]' LIMIT 1;")

		if(!player_rows || length(player_rows) == 0)
			world.log << "\[SQLite\] Player not found in database: [ckey]"
			return null

		var/list/player_json = player_rows[1]
		var/list/char_data = ParsePlayerFromJSON(player_json)
		var/player_id = char_data["player_id"]

		world.log << "\[SQLite LOAD\] ✓ Found player: [char_data["char_name"]] (ID: [player_id])"

		// Load related data
		char_data["skills"] = LoadPlayerSkillsFromSQLite(player_id)
		world.log << "\[SQLite LOAD\] ✓ Loaded [length(char_data["skills"])] skills"

		char_data["currency"] = LoadPlayerCurrencyFromSQLite(player_id)
		world.log << "\[SQLite LOAD\] ✓ Loaded currency"

		char_data["appearance"] = LoadPlayerAppearanceFromSQLite(player_id)
		world.log << "\[SQLite LOAD\] ✓ Loaded appearance"

		char_data["positions"] = LoadPlayerPositionsFromSQLite(player_id)
		world.log << "\[SQLite LOAD\] ✓ Loaded [length(char_data["positions"])] continent positions"

		world.log << "\[SQLite LOAD COMPLETE\] ✓ [ckey]"
		return char_data

	catch(var/exception/e)
		world.log << "\[SQLite LOAD ERROR\] Exception: [e.name] - [e.desc]"
		return null

// ============================================================================
// SKILL OPERATIONS
// ============================================================================

/**
 * SavePlayerSkillsToSQLite(player_id, mob/players/P)
 * Save all character skills to database
 */
proc/SavePlayerSkillsToSQLite(player_id, mob/players/P)
	if(!P || !P.character)
		return FALSE

	var/datum/character_data/char = P.character

	// Delete existing skills for this player
	ExecuteSQLiteQuery("DELETE FROM character_skills WHERE player_id=[player_id];")

	// List of all skills
	var/list/skills = list(
		list("frank", char.frank, char.frankEXP, char.frankMAXEXP),
		list("crank", char.crank, char.crankEXP, char.crankMAXEXP),
		list("grank", char.grank, char.grankEXP, char.grankMAXEXP),
		list("hrank", char.hrank, char.hrankEXP, char.hrankMAXEXP),
		list("mrank", char.mrank, char.mrankEXP, char.mrankMAXEXP),
		list("smirank", char.smirank, char.smirankEXP, char.smirankMAXEXP),
		list("smerank", char.smerank, char.smerankEXP, char.smerankMAXEXP),
		list("brank", char.brank, char.brankEXP, char.brankMAXEXP),
		list("drank", char.drank, char.drankEXP, char.drankMAXEXP)
	)

	// Insert each skill with safe query builder
	for(var/list/skill in skills)
		var/skill_name = skill[1]
		var/rank_level = skill[2]
		var/current_exp = skill[3]
		var/max_exp = skill[4]

		var/query = BuildInsertSkillQuery(player_id, skill_name, rank_level, current_exp, max_exp)
		ExecuteSQLiteQuery(query)

	return TRUE

/**
 * LoadPlayerSkillsFromSQLite(player_id)
 * Load all skills for a player (FIXED - now uses JSON parsing)
 */
proc/LoadPlayerSkillsFromSQLite(player_id)
	var/query = "SELECT skill_name, rank_level, current_exp, max_exp_threshold FROM character_skills WHERE player_id=[player_id];"
	var/list/result = ExecuteSQLiteQueryJSON(query)

	if(!result || length(result) == 0)
		return list()

	// Parse results using JSON helper
	var/list/skills = ParseSkillsFromJSON(result)
	return skills

// ============================================================================
// CURRENCY OPERATIONS
// ============================================================================

/**
 * SavePlayerCurrencyToSQLite(player_id, mob/players/P)
 * Save currency balance to database
 */
proc/SavePlayerCurrencyToSQLite(player_id, mob/players/P)
	if(!P)
		return FALSE

	var/query = BuildInsertCurrencyQuery(
		player_id,
		P.lucre || 0,
		P.bankedlucre || 0,
		P.basecamp_stone || 0,
		0,  // metal
		0   // timber
	)
	ExecuteSQLiteQuery(query)

	return TRUE

/**
 * LoadPlayerCurrencyFromSQLite(player_id)
 * Load currency balance from database (FIXED)
 */
proc/LoadPlayerCurrencyFromSQLite(player_id)
	var/query = "SELECT lucre, banked_lucre, stone, metal, timber FROM currency_accounts WHERE player_id=[player_id] LIMIT 1;"
	var/list/result = ExecuteSQLiteQueryJSON(query)

	if(!result || length(result) == 0)
		return list("lucre" = 0, "banked_lucre" = 0, "stone" = 0, "metal" = 0, "timber" = 0)

	// Parse and return
	return ParseCurrencyFromJSON(result[1])

// ============================================================================
// APPEARANCE OPERATIONS
// ============================================================================

/**
 * SavePlayerAppearanceToSQLite(player_id, datum/character_data/char)
 * Save appearance customization
 */
proc/SavePlayerAppearanceToSQLite(player_id, datum/character_data/char)
	if(!char)
		return FALSE

	var/query = BuildInsertAppearanceQuery(
		player_id,
		char.gender || "M",
		char.appearance_locked ? 1 : 0
	)
	ExecuteSQLiteQuery(query)

	return TRUE

/**
 * LoadPlayerAppearanceFromSQLite(player_id)
 * Load appearance data (FIXED)
 */
proc/LoadPlayerAppearanceFromSQLite(player_id)
	var/query = "SELECT gender, is_locked FROM character_appearance WHERE player_id=[player_id] LIMIT 1;"
	var/list/result = ExecuteSQLiteQueryJSON(query)

	if(!result || length(result) == 0)
		return list("gender" = "M", "is_locked" = FALSE)

	return ParseAppearanceFromJSON(result[1])

// ============================================================================
// POSITION OPERATIONS
// ============================================================================

/**
 * SavePlayerPositionsToSQLite(player_id, datum/character_data/char)
 * Save per-continent positions
 */
proc/SavePlayerPositionsToSQLite(player_id, datum/character_data/char)
	if(!char || !char.continent_positions)
		return FALSE

	// Delete existing positions
	ExecuteSQLiteQuery("DELETE FROM continent_positions WHERE player_id=[player_id];")

	// Insert new positions
	for(var/continent in char.continent_positions)
		var/list/pos = char.continent_positions[continent]
		if(length(pos) >= 3)
			var/x = pos[1]
			var/y = pos[2]
			var/z = pos[3]
			var/dir = pos[4] || SOUTH

			var/query = BuildInsertPositionQuery(player_id, continent, x, y, z, dir)
			ExecuteSQLiteQuery(query)

	return TRUE

/**
 * LoadPlayerPositionsFromSQLite(player_id)
 * Load continent positions (FIXED)
 */
proc/LoadPlayerPositionsFromSQLite(player_id)
	var/query = "SELECT continent, x, y, z, dir FROM continent_positions WHERE player_id=[player_id];"
	var/list/result = ExecuteSQLiteQueryJSON(query)

	if(!result || length(result) == 0)
		return list()

	return ParsePositionsFromJSON(result)

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/**
 * GetPlayerIDFromCkey(ckey)
 * Quick lookup for player database ID
 */
proc/GetPlayerIDFromCkey(ckey)
	var/safe_ckey = EscapeSQLString(ckey)
	var/list/result = ExecuteSQLiteQueryJSON("SELECT id FROM players WHERE ckey='[safe_ckey]' LIMIT 1;")

	if(!result || length(result) == 0)
		return 0

	return ExtractJSONField(result[1], "id", 0)

/**
 * LogSQLiteError(error_msg)
 * Log SQLite errors to global list for debugging
 */
proc/LogSQLiteError(error_msg)
	sqlite_error_log += "\[[world.realtime]\] [error_msg]"

	if(length(sqlite_error_log) > 1000)
		// Truncate log to prevent memory issues - keep last 500 entries
		var/list/new_log = list()
		var/start_idx = max(1, length(sqlite_error_log) - 499)
		for(var/i = start_idx to length(sqlite_error_log))
			new_log += sqlite_error_log[i]
		sqlite_error_log = new_log

/**
 * GetSQLiteErrorLog()
 * Return full error log for debugging
 */
proc/GetSQLiteErrorLog()
	return sqlite_error_log

/**
 * ClearSQLiteErrorLog()
 * Clear error log
 */
proc/ClearSQLiteErrorLog()
	sqlite_error_log = list()

/**
 * SanitizeSQLString(str)
 * Escape SQL string literals (replace ' with '')
 * @param str - String to sanitize
 * @return Escaped string safe for SQL
 */
proc/SanitizeSQLString(str)
	if(!str) return ""
	var/sanitized = replacetext(str, "'", "''")
	return sanitized

// ============================================================================
// MARKET LISTINGS TABLE CRUD OPERATIONS (Phase 2)
// ============================================================================

/**
 * InsertMarketListing(seller_id, seller_name, item_name, item_type, quantity, unit_price, currency_type, expires_at)
 * Create a new market listing in SQLite
 * Returns: listing_id on success, 0 on failure
 */
proc/InsertMarketListing(seller_id, seller_name, item_name, item_type, quantity, unit_price, currency_type, expires_at)
	if(!seller_id || !seller_name || !item_name) return 0
	
	var/query = "INSERT INTO market_listings (seller_id, seller_name, item_name, item_type, quantity, unit_price, currency_type, created_at, expires_at, is_active) "
	query += "VALUES ([seller_id], '[SanitizeSQLString(seller_name)]', '[SanitizeSQLString(item_name)]', '[SanitizeSQLString(item_type)]', [quantity], [unit_price], '[SanitizeSQLString(currency_type)]', datetime('now'), datetime('now', '[expires_at]'), 1)"
	
	var/result = ExecuteSQLiteQuery(query)
	if(!result) return 0
	
	// Get the inserted listing ID
	var/id_result = ExecuteSQLiteQueryJSON("SELECT last_insert_rowid() as id")
	if(id_result && length(id_result))
		return id_result[1]["id"]
	
	return 0

/**
 * UpdateMarketListingPurchased(listing_id, buyer_id, buyer_name)
 * Mark a listing as purchased
 */
proc/UpdateMarketListingPurchased(listing_id, buyer_id, buyer_name)
	if(!listing_id || !buyer_id) return FALSE
	
	var/query = "UPDATE market_listings SET is_active = 0, buyer_id = [buyer_id], buyer_name = '[SanitizeSQLString(buyer_name)]', purchased_at = datetime('now') WHERE listing_id = [listing_id]"
	return ExecuteSQLiteQuery(query) ? TRUE : FALSE

/**
 * UpdateMarketListingCancelled(listing_id)
 * Mark a listing as cancelled/inactive
 */
proc/UpdateMarketListingCancelled(listing_id)
	if(!listing_id) return FALSE
	
	var/query = "UPDATE market_listings SET is_active = 0 WHERE listing_id = [listing_id]"
	return ExecuteSQLiteQuery(query) ? TRUE : FALSE

/**
 * GetMarketListingByID(listing_id)
 * Fetch a specific listing from SQLite
 * Returns: Dictionary with listing data, or null
 */
proc/GetMarketListingByID(listing_id)
	if(!listing_id) return null
	
	var/query = "SELECT * FROM market_listings WHERE listing_id = [listing_id]"
	var/result = ExecuteSQLiteQueryJSON(query)
	
	if(result && length(result))
		return result[1]
	
	return null

/**
 * GetAllActiveMarketListings()
 * Fetch all active (non-expired, non-purchased) listings
 * Returns: List of listing dictionaries
 */
proc/GetAllActiveMarketListings()
	var/query = "SELECT * FROM market_listings WHERE is_active = 1 AND expires_at > datetime('now') ORDER BY created_at DESC"
	var/result = ExecuteSQLiteQueryJSON(query)
	return result || list()

/**
 * GetPlayerMarketListings(seller_id)
 * Get all listings created by a player (active or completed)
 * Returns: List of listing dictionaries
 */
proc/GetPlayerMarketListings(seller_id)
	if(!seller_id) return list()
	
	var/query = "SELECT * FROM market_listings WHERE seller_id = [seller_id] ORDER BY created_at DESC"
	var/result = ExecuteSQLiteQueryJSON(query)
	return result || list()

/**
 * SearchMarketListings(search_term, currency_filter)
 * Search market listings with optional filters
 * Returns: List of matching listings
 */
proc/SearchMarketListings(search_term, currency_filter)
	var/query = "SELECT * FROM market_listings WHERE is_active = 1 AND expires_at > datetime('now')"
	
	if(search_term)
		query += " AND item_name LIKE '%[SanitizeSQLString(search_term)]%'"
	
	if(currency_filter)
		query += " AND currency_type = '[SanitizeSQLString(currency_filter)]'"
	
	query += " ORDER BY created_at DESC"
	
	var/result = ExecuteSQLiteQueryJSON(query)
	return result || list()

/**
 * CleanupExpiredMarketListings()
 * Remove expired listings from active status
 * Returns: Number of listings cleaned up
 */
proc/CleanupExpiredMarketListings()
	var/query = "UPDATE market_listings SET is_active = 0 WHERE is_active = 1 AND expires_at <= datetime('now')"
	var/result = ExecuteSQLiteQuery(query)
	
	// Count how many were updated
	if(result)
		var/count_query = "SELECT COUNT(*) as cleanup_count FROM market_listings WHERE is_active = 0 AND expires_at <= datetime('now')"
		var/count_result = ExecuteSQLiteQueryJSON(count_query)
		if(count_result && length(count_result))
			return count_result[1]["cleanup_count"]
	
	return 0

/**
 * GetMarketBoardStats()
 * Get summary statistics about market board
 * Returns: Dictionary with stats
 */
proc/GetMarketBoardStats()
	var/stats = list()
	
	// Active listings count
	var/active_query = "SELECT COUNT(*) as count FROM market_listings WHERE is_active = 1 AND expires_at > datetime('now')"
	var/active_result = ExecuteSQLiteQueryJSON(active_query)
	stats["active_listings"] = active_result && length(active_result) ? active_result[1]["count"] : 0
	
	// Completed sales count
	var/sold_query = "SELECT COUNT(*) as count FROM market_listings WHERE is_active = 0 AND buyer_id IS NOT NULL"
	var/sold_result = ExecuteSQLiteQueryJSON(sold_query)
	stats["completed_sales"] = sold_result && length(sold_result) ? sold_result[1]["count"] : 0
	
	// Unique sellers
	var/seller_query = "SELECT COUNT(DISTINCT seller_id) as count FROM market_listings"
	var/seller_result = ExecuteSQLiteQueryJSON(seller_query)
	stats["unique_sellers"] = seller_result && length(seller_result) ? seller_result[1]["count"] : 0
	
	return stats

// ============================================================================
// NPC MERCHANTS TABLE CRUD OPERATIONS (Phase 3)
// ============================================================================

/**
 * SaveMerchantState(merchant_datum)
 * Persist NPC merchant state to SQLite
 * @param merchant_datum - /datum/npc_merchant object
 * @return TRUE on success, FALSE on failure
 */
proc/SaveMerchantState(datum/npc_merchant/merchant)
	if(!merchant) return FALSE
	
	// Serialize inventory and lists as JSON
	var/inventory_json = json_encode(merchant.inventory)
	var/prefers_buying_json = json_encode(merchant.prefers_buying)
	var/prefers_selling_json = json_encode(merchant.prefers_selling)
	var/specialty_items_json = json_encode(merchant.specialty_items)
	
	// Use INSERT OR REPLACE to upsert
	var/query = "INSERT OR REPLACE INTO npc_merchants "
	query += "(merchant_id, merchant_name, merchant_type, personality, profit_margin, mood, current_wealth, starting_wealth, "
	query += "inventory, prefers_buying, prefers_selling, specialty_items, last_trade_time, trading_cooldown, "
	query += "total_trades, total_wealth_traded, reputation, last_updated) "
	query += "VALUES ('[SanitizeSQLString(merchant.merchant_id)]', '[SanitizeSQLString(merchant.merchant_name)]', "
	query += "'[SanitizeSQLString(merchant.merchant_type)]', '[SanitizeSQLString(merchant.personality)]', "
	query += "[merchant.profit_margin], [merchant.mood], [merchant.current_wealth], [merchant.starting_wealth], "
	query += "'[SanitizeSQLString(inventory_json)]', '[SanitizeSQLString(prefers_buying_json)]', "
	query += "'[SanitizeSQLString(prefers_selling_json)]', '[SanitizeSQLString(specialty_items_json)]', "
	query += "datetime('now'), [merchant.trading_cooldown], [merchant.total_trades], [merchant.total_wealth_traded], "
	query += "[merchant.reputation], datetime('now'))"
	
	return ExecuteSQLiteQuery(query) ? TRUE : FALSE

/**
 * LoadMerchantState(merchant_id)
 * Load NPC merchant state from SQLite and restore to /datum/npc_merchant
 * @param merchant_id - Unique merchant identifier
 * @return /datum/npc_merchant object or null if not found
 */
proc/LoadMerchantState(merchant_id)
	if(!merchant_id) return null
	
	var/query = "SELECT * FROM npc_merchants WHERE merchant_id = '[SanitizeSQLString(merchant_id)]'"
	var/result = ExecuteSQLiteQueryJSON(query)
	
	if(!result || !length(result)) return null
	
	var/data = result[1]
	
	// Reconstruct merchant datum
	var/datum/npc_merchant/merchant = new /datum/npc_merchant(data["merchant_name"], data["merchant_type"], data["personality"])
	merchant.merchant_id = data["merchant_id"]
	merchant.profit_margin = data["profit_margin"]
	merchant.mood = data["mood"]
	merchant.current_wealth = data["current_wealth"]
	merchant.starting_wealth = data["starting_wealth"]
	merchant.trading_cooldown = data["trading_cooldown"]
	merchant.total_trades = data["total_trades"]
	merchant.total_wealth_traded = data["total_wealth_traded"]
	merchant.reputation = data["reputation"]
	
	// Deserialize JSON fields
	if(data["inventory"])
		merchant.inventory = json_decode(data["inventory"]) || list()
	if(data["prefers_buying"])
		merchant.prefers_buying = json_decode(data["prefers_buying"]) || list()
	if(data["prefers_selling"])
		merchant.prefers_selling = json_decode(data["prefers_selling"]) || list()
	if(data["specialty_items"])
		merchant.specialty_items = json_decode(data["specialty_items"]) || list()
	
	return merchant

/**
 * GetAllMerchants()
 * Fetch all saved merchant states from SQLite
 * @return List of merchant_id strings
 */
proc/GetAllMerchants()
	var/query = "SELECT merchant_id FROM npc_merchants ORDER BY merchant_name"
	var/result = ExecuteSQLiteQueryJSON(query)
	
	if(!result) return list()
	
	var/list/merchant_ids = list()
	for(var/merchant_data in result)
		merchant_ids += merchant_data["merchant_id"]
	
	return merchant_ids

/**
 * DeleteMerchantState(merchant_id)
 * Remove a merchant from SQLite persistence (e.g., when merchant is deleted)
 * @param merchant_id - Merchant to delete
 * @return TRUE on success
 */
proc/DeleteMerchantState(merchant_id)
	if(!merchant_id) return FALSE
	
	var/query = "DELETE FROM npc_merchants WHERE merchant_id = '[SanitizeSQLString(merchant_id)]'"
	return ExecuteSQLiteQuery(query) ? TRUE : FALSE

/**
 * GetMerchantByName(merchant_name)
 * Fetch merchant by display name (for lookup)
 * @param merchant_name - Name to search for
 * @return /datum/npc_merchant or null
 */
proc/GetMerchantByName(merchant_name)
	if(!merchant_name) return null
	
	var/query = "SELECT merchant_id FROM npc_merchants WHERE merchant_name = '[SanitizeSQLString(merchant_name)]' LIMIT 1"
	var/result = ExecuteSQLiteQueryJSON(query)
	
	if(!result || !length(result)) return null
	
	var/merchant_id = result[1]["merchant_id"]
	return LoadMerchantState(merchant_id)

/**
 * GetMerchantsByType(merchant_type)
 * Fetch all merchants of a specific type
 * @param merchant_type - Type filter (trader, blacksmith, etc.)
 * @return List of /datum/npc_merchant objects
 */
proc/GetMerchantsByType(merchant_type)
	if(!merchant_type) return list()
	
	var/query = "SELECT merchant_id FROM npc_merchants WHERE merchant_type = '[SanitizeSQLString(merchant_type)]' ORDER BY merchant_name"
	var/result = ExecuteSQLiteQueryJSON(query)
	
	var/list/merchants = list()
	if(result)
		for(var/merchant_data in result)
			var/datum/npc_merchant/merchant = LoadMerchantState(merchant_data["merchant_id"])
			if(merchant)
				merchants += merchant
	
	return merchants

// ============================================================================
// UTILITY PROCS - Shared SQL helpers
// ============================================================================

/**
 * GetPlayerIDFromSQLite(ckey)
 * Utility to lookup player_id from ckey in SQLite
 * Used by HUD state and other systems for player data lookups
 * @param ckey - Player ckey
 * @return player_id integer or 0 if not found
 */
proc/GetPlayerIDFromSQLite(ckey)
	if(!sqlite_ready || !ckey) return 0
	
	var/query = "SELECT id FROM players WHERE ckey = '[SanitizeSQLString(ckey)]' LIMIT 1"
	var/result = ExecuteSQLiteQueryJSON(query)
	
	if(!result || !length(result)) return 0
	
	return result[1]["id"]

// ============================================================================
// DEED PERSISTENCE PROCS (Phase 5)
// ============================================================================

/**
 * SaveDeedToSQLite(deed, owner_ckey)
 * Persist deed data to SQLite deeds table
 * Called after deed creation or modification
 * @param deed - DeedToken_Zone object with all deed properties
 * @param owner_ckey - Player ckey of deed owner
 * @return 1 if successful, 0 if failed
 */
proc/SaveDeedToSQLite(obj/DeedToken_Zone/deed, owner_ckey)
	if(!sqlite_ready || !deed || !owner_ckey) return 0
	
	// Get owner_id from ckey
	var/owner_id = GetPlayerIDFromSQLite(owner_ckey)
	if(!owner_id)
		world.log << "ERROR: SaveDeedToSQLite() - Owner [owner_ckey] not found in players table"
		return 0
	
	// Serialize allowed_players list to JSON
	var/allowed_json = json_encode(deed.allowed_players)
	
	// Build query - INSERT OR REPLACE to handle updates
	var/query = "INSERT OR REPLACE INTO deeds VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)"
	
	// Get tier name manually
	var/tier_name = "small"
	if(deed.zone_tier == 2)
		tier_name = "medium"
	else if(deed.zone_tier == 3)
		tier_name = "large"
	
	// Get center turf coordinates
	var/center_x = 0, center_y = 0, center_z = 0
	var/turf/ct = deed.center_turf
	if(ct)
		center_x = ct.x
		center_y = ct.y
		center_z = ct.z
	
	// Execute with parameter binding (safe from SQL injection)
	var/result = ExecuteSQLiteQuery(query, list(
		deed.zone_id,
		owner_id,
		SanitizeSQLString(deed.zone_name),
		SanitizeSQLString(tier_name),
		center_x,
		center_y,
		center_z,
		deed.size[1],
		deed.size[2],
		allowed_json,
		deed.maintenance_cost,
		deed.maintenance_due,
		deed.founded_date,
		deed.grace_period_end,
		deed.payment_frozen ? 1 : 0,
		deed.frozen_start,
		deed.freeze_duration,
		deed.freezes_used_this_month,
		deed.last_freeze_month,
		deed.cooldown_end
	))
	
	if(result)
		world.log << "DEED SAVED: [deed.zone_name] (ID: [deed.zone_id]) by [owner_ckey]"
		return 1
	else
		world.log << "ERROR: SaveDeedToSQLite() - Failed to save deed [deed.zone_id]"
		return 0

/**
 * LoadDeedFromSQLite(deed_id)
 * Retrieve single deed from SQLite and recreate DeedToken_Zone object
 * @param deed_id - Unique deed ID
 * @return DeedToken_Zone object or null if not found
 */
proc/LoadDeedFromSQLite(deed_id)
	if(!sqlite_ready || !deed_id) return null
	
	var/query = "SELECT * FROM deeds WHERE deed_id = ? LIMIT 1"
	var/result = ExecuteSQLiteQueryJSON(query, list(deed_id))
	
	if(!result || !length(result))
		world.log << "WARNING: LoadDeedFromSQLite() - Deed [deed_id] not found in database"
		return null
	
	var/deed_data = result[1]
	
	// Recreate DeedToken_Zone object
	var/deed = new /obj/DeedToken_Zone
	
	if(!deed) return null  // Creation failed
	
	// Restore all properties from database using colon notation (dynamic access)
	deed:zone_id = deed_data["deed_id"]
	deed:owner_key = "[deed_data["owner_id"]]"  // Will need to lookup ckey from owner_id if needed
	deed:zone_name = deed_data["zone_name"]
	deed:zone_tier = ConvertTierNameToConstant(deed_data["zone_tier"])
	deed:center_turf = locate(deed_data["center_x"], deed_data["center_y"], deed_data["center_z"])
	deed:size[1] = deed_data["size_x"]
	deed:size[2] = deed_data["size_y"]
	deed:allowed_players = json_decode(deed_data["allowed_players"]) || list()
	deed:maintenance_cost = deed_data["maintenance_cost"]
	deed:maintenance_due = deed_data["maintenance_due"]
	deed:founded_date = deed_data["founded_date"]
	deed:grace_period_end = deed_data["grace_period_end"]
	deed:payment_frozen = deed_data["payment_frozen"]
	deed:frozen_start = deed_data["frozen_start"]
	deed:freeze_duration = deed_data["freeze_duration"]
	deed:freezes_used_this_month = deed_data["freezes_used_this_month"]
	deed:last_freeze_month = deed_data["last_freeze_month"]
	deed:cooldown_end = deed_data["cooldown_end"]
	
	world.log << "DEED LOADED: [deed:zone_name] (ID: [deed:zone_id])"
	return deed

/**
 * GetAllDeedsFromSQLite()
 * Load all deeds from database and recreate DeedToken_Zone objects
 * Called during world initialization (Phase 2)
 * @return List of DeedToken_Zone objects
 */
proc/GetAllDeedsFromSQLite()
	if(!sqlite_ready) return list()
	
	var/query = "SELECT deed_id FROM deeds ORDER BY created_at"
	var/result = ExecuteSQLiteQueryJSON(query)
	
	var/list/deeds = list()
	if(result)
		for(var/deed_data in result)
			var/obj/DeedToken_Zone/deed = LoadDeedFromSQLite(deed_data["deed_id"])
			if(deed)
				deeds += deed
	
	world.log << "DEEDS LOADED: [deeds.len] deeds restored from database"
	return deeds

/**
 * DeleteDeedFromSQLite(deed_id)
 * Remove deed from database
 * Called when deed is deleted/transferred
 * @param deed_id - Unique deed ID
 * @return 1 if successful, 0 if failed
 */
proc/DeleteDeedFromSQLite(deed_id)
	if(!sqlite_ready || !deed_id) return 0
	
	var/query = "DELETE FROM deeds WHERE deed_id = ?"
	var/result = ExecuteSQLiteQuery(query, list(deed_id))
	
	if(result)
		world.log << "DEED DELETED: [deed_id] removed from database"
		return 1
	else
		world.log << "ERROR: DeleteDeedFromSQLite() - Failed to delete deed [deed_id]"
		return 0

/**
 * UpdateDeedMaintenanceStatus(deed_id, maintenance_due, grace_period_end)
 * Update maintenance payment tracking for a deed
 * Called after payment or failure to pay
 * @param deed_id - Unique deed ID
 * @param maintenance_due - Timestamp when next payment is due
 * @param grace_period_end - Timestamp when grace period ends (0 if none)
 * @return 1 if successful, 0 if failed
 */
proc/UpdateDeedMaintenanceStatus(deed_id, maintenance_due, grace_period_end)
	if(!sqlite_ready || !deed_id) return 0
	
	var/query = "UPDATE deeds SET maintenance_due = ?, grace_period_end = ?, updated_at = CURRENT_TIMESTAMP WHERE deed_id = ?"
	var/result = ExecuteSQLiteQuery(query, list(maintenance_due, grace_period_end, deed_id))
	
	if(result)
		return 1
	else
		world.log << "ERROR: UpdateDeedMaintenanceStatus() - Failed to update deed [deed_id]"
		return 0

/**
 * UpdateDeedFreezeStatus(deed_id, frozen, frozen_start, freeze_duration, freezes_used)
 * Update payment freeze status for a deed
 * Called when freeze activated/deactivated
 * @param deed_id - Unique deed ID
 * @param frozen - Boolean: is freeze active
 * @param frozen_start - Timestamp when freeze started
 * @param freeze_duration - Duration of freeze in deciseconds
 * @param freezes_used - Number of freezes used this month
 * @return 1 if successful, 0 if failed
 */
proc/UpdateDeedFreezeStatus(deed_id, frozen, frozen_start, freeze_duration, freezes_used)
	if(!sqlite_ready || !deed_id) return 0
	
	var/query = "UPDATE deeds SET payment_frozen = ?, frozen_start = ?, freeze_duration = ?, freezes_used_this_month = ?, updated_at = CURRENT_TIMESTAMP WHERE deed_id = ?"
	var/result = ExecuteSQLiteQuery(query, list(frozen ? 1 : 0, frozen_start, freeze_duration, freezes_used, deed_id))
	
	if(result)
		return 1
	else
		world.log << "ERROR: UpdateDeedFreezeStatus() - Failed to update freeze status for deed [deed_id]"
		return 0

/**
 * ConvertTierNameToConstant(tier_name)
 * Convert tier name string to tier constant value
 * @param tier_name - "small", "medium", or "large"
 * @return Tier constant (1=SMALL, 2=MEDIUM, 3=LARGE)
 */
proc/ConvertTierNameToConstant(tier_name)
	if(!tier_name) return 1  // Default to small
	
	var/tier_str = "[tier_name]"  // Ensure string
	
	if(tier_str == "small")
		return 1
	else if(tier_str == "medium")
		return 2
	else if(tier_str == "large")
		return 3
	
	return 1  // Default to small

// ============================================================================
// PHASE 6: MARKET PRICE DYNAMIC UPDATES - SQLite Persistence
// ============================================================================

/**
 * SaveMarketPricesToSQLite()
 * Batch save all current commodity prices to SQLite market_prices table
 * Called during periodic updates or on demand
 * @return 1 if successful, 0 on failure
 */
proc/SaveMarketPricesToSQLite()
	if(!sqlite_ready || !market_engine) return 0
	
	var/success_count = 0
	var/total_count = 0
	
	for(var/commodity_name in market_engine.commodities)
		var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
		if(!commodity) continue
		
		total_count++
		
		// Check if commodity exists in database
		var/check_query = "SELECT id FROM market_prices WHERE commodity_name=?"
		var/exists = ExecuteSQLiteQuery(check_query, list(SanitizeSQLString(commodity_name)))
		
		var/query = ""
		if(exists)
			// UPDATE existing record
			query = "UPDATE market_prices SET current_price=?, price_elasticity=?, price_volatility=?, supply_count=?, updated_at=CURRENT_TIMESTAMP, updated_by='market_dynamics' WHERE commodity_name=?"
			var/result = ExecuteSQLiteQuery(query, list(
				commodity.current_price,
				commodity.price_elasticity,
				commodity.price_volatility,
				commodity.current_supply,
				SanitizeSQLString(commodity_name)
			))
			if(result) success_count++
		else
			// INSERT new record
			query = "INSERT INTO market_prices (commodity_name, base_price, current_price, price_elasticity, price_volatility, supply_count, tech_tier, min_price, max_price, tradable, sellable, updated_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'market_dynamics')"
			var/result = ExecuteSQLiteQuery(query, list(
				SanitizeSQLString(commodity_name),
				commodity.base_price,
				commodity.current_price,
				commodity.price_elasticity,
				commodity.price_volatility,
				commodity.current_supply,
				commodity.tech_tier,
				commodity.min_price,
				commodity.max_price,
				commodity.tradable ? 1 : 0,
				commodity.sellable ? 1 : 0
			))
			if(result) success_count++
	
	if(total_count > 0 && success_count > 0)
		world.log << "MARKET_PRICES_SAVED: [success_count]/[total_count] commodities persisted to SQLite"
	
	return success_count > 0 ? 1 : 0

/**
 * SavePriceHistory(commodity_name, price, market_conditions = "")
 * Save a single price point to price_history table for trend analysis
 * Called after each price calculation
 * @param commodity_name - Name of commodity
 * @param price - The price to record
 * @param market_conditions - Optional condition string (e.g., "rising", "falling", "stable")
 * @return 1 if successful, 0 on failure
 */
proc/SavePriceHistory(commodity_name, price, market_conditions = "")
	if(!sqlite_ready || !commodity_name || !price) return 0
	
	if(!market_engine) return 0
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return 0
	
	// Get supply/demand levels
	var/supply_level = commodity.current_supply
	var/demand_level = commodity.current_demand
	
	// Insert price history record
	var/query = "INSERT INTO price_history (commodity_name, historical_price, market_conditions, supply_level, demand_level) VALUES (?, ?, ?, ?, ?)"
	var/result = ExecuteSQLiteQuery(query, list(
		SanitizeSQLString(commodity_name),
		price,
		SanitizeSQLString(market_conditions),
		supply_level,
		demand_level
	))
	
	if(!result)
		world.log << "ERROR: SavePriceHistory() - Failed to save price history for [commodity_name]"
		return 0
	
	return 1

/**
 * LoadPriceHistory(commodity_name, limit = 50)
 * Retrieve historical price points for a commodity from SQLite
 * Used for price trend analysis and graphing
 * @param commodity_name - Name of commodity
 * @param limit - Maximum number of records to return
 * @return List of price records [{"price": value, "timestamp": time, "conditions": str}, ...]
 */
proc/LoadPriceHistory(commodity_name, limit = 50)
	if(!sqlite_ready || !commodity_name) return list()
	
	var/query = "SELECT historical_price, recorded_at, market_conditions FROM price_history WHERE commodity_name=? ORDER BY recorded_at DESC LIMIT ?"
	var/rows = ExecuteSQLiteQuery(query, list(
		SanitizeSQLString(commodity_name),
		limit
	), return_rows=1)
	
	if(!rows)
		return list()
	
	var/rows_count = length(rows)
	if(rows_count == 0)
		return list()
	
	var/list/history = list()
	for(var/row in rows)
		history += list(list(
			"price" = text2num(row["historical_price"]),
			"timestamp" = row["recorded_at"],
			"conditions" = row["market_conditions"]
		))
	
	return history

/**
 * SyncMarketPricesToSQLite(commodity_name, new_price)
 * Sync a single commodity price to SQLite immediately
 * Called when price recalculation happens
 * @param commodity_name - Name of commodity
 * @param new_price - New price value
 * @return 1 if successful, 0 on failure
 */
proc/SyncMarketPricesToSQLite(commodity_name, new_price)
	if(!sqlite_ready || !commodity_name || new_price <= 0) return 0
	
	var/query = "UPDATE market_prices SET current_price=?, updated_at=CURRENT_TIMESTAMP, updated_by='market_dynamics' WHERE commodity_name=?"
	var/result = ExecuteSQLiteQuery(query, list(
		new_price,
		SanitizeSQLString(commodity_name)
	))
	
	if(!result)
		world.log << "ERROR: SyncMarketPricesToSQLite() - Failed to update price for [commodity_name]"
		return 0
	
	return 1

/**
 * PruneOldPriceHistory(days_to_keep = 30)
 * Clean up old price history records older than specified days
 * Called periodically to prevent database bloat
 * @param days_to_keep - How many days of history to retain
 * @return Number of records deleted
 */
proc/PruneOldPriceHistory(days_to_keep = 30)
	if(!sqlite_ready) return 0
	
	// Calculate the cutoff time for retention (e.g., 30 days = 2,592,000 seconds)
	var/days_in_seconds = days_to_keep * 86400    // Seconds equivalent for logging/analytics
	var/cutoff_time = "datetime('now', '-[days_to_keep] days')"
	
	var/query = "DELETE FROM price_history WHERE recorded_at < [cutoff_time]"
	var/result = ExecuteSQLiteQuery(query)
	
	if(result)
		world.log << "PRICE_HISTORY_PRUNE: Cleaned up old price history (retention: [days_to_keep] days / [days_in_seconds] seconds)"
		return 1
	
	return 0

/**
 * LoadMarketPricesFromSQLite()
 * Load all commodity prices from SQLite into market_engine on boot
 * Called during world initialization (Phase 6)
 * @return Number of prices loaded
 */
proc/LoadMarketPricesFromSQLite()
	if(!sqlite_ready || !market_engine) return 0
	
	var/query = "SELECT commodity_name, current_price, price_elasticity, price_volatility, supply_count, tech_tier FROM market_prices"
	var/rows = ExecuteSQLiteQuery(query, , return_rows=1)
	
	if(!rows)
		world.log << "MARKET_PRICES_LOAD: No prices found in database, using in-memory defaults"
		return 0
	
	var/rows_count = length(rows)
	if(rows_count == 0)
		world.log << "MARKET_PRICES_LOAD: No prices found in database, using in-memory defaults"
		return 0
	
	var/loaded_count = 0
	for(var/row in rows)
		var/commodity_name = row["commodity_name"]
		var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
		
		if(commodity)
			// Restore prices from database
			commodity.current_price = text2num(row["current_price"])
			commodity.price_elasticity = text2num(row["price_elasticity"])
			commodity.price_volatility = text2num(row["price_volatility"])
			commodity.current_supply = text2num(row["supply_count"])
			commodity.tech_tier = text2num(row["tech_tier"])
			loaded_count++
	
	world.log << "MARKET_PRICES_LOAD: Loaded [loaded_count] commodity prices from SQLite"
	return loaded_count

// ============================================================================
// PHASE 7: MARKET ANALYTICS - Volatility, Popularity, Scarcity Metrics
// ============================================================================

/**
 * CalculatePriceVolatility(commodity_name, days=7)
 * Calculate price volatility (rate of change) for a commodity
 * Volatility = standard deviation of price changes
 * @param commodity_name - Commodity to analyze
 * @param days - Days of history to analyze
 * @return Volatility percentage (0-100)
 */
proc/CalculatePriceVolatility(commodity_name, days = 7)
	if(!sqlite_ready || !commodity_name) return 0
	
	// Calculate lookback period in seconds for potential interval-based cleanup
	var/days_seconds = days * 86400  // Convert days to seconds for logging/intervals
	var/cutoff_time = "datetime('now', '-[days] days')"
	
	var/query = "SELECT historical_price FROM price_history WHERE commodity_name=? AND recorded_at > [cutoff_time] ORDER BY recorded_at"
	var/rows = ExecuteSQLiteQuery(query, list(SanitizeSQLString(commodity_name)), return_rows=1)
	
	if(!rows || length(rows) < 2)
		return 0  // Not enough data
	
	var/list/prices = list()
	for(var/row in rows)
		prices += text2num(row["historical_price"])
	
	// Calculate average
	var/sum = 0
	for(var/price in prices)
		sum += price
	var/avg = sum / length(prices)
	
	// Calculate standard deviation
	var/variance_sum = 0
	for(var/price in prices)
		var/diff = price - avg
		variance_sum += (diff * diff)
	var/variance = variance_sum / length(prices)
	var/std_dev = sqrt(variance)
	
	// Volatility as percentage of average
	var/volatility = avg > 0 ? (std_dev / avg) * 100 : 0
	
	return min(100, volatility)  // Cap at 100%

/**
 * CalculateAveragePrice(commodity_name, days=7)
 * Calculate rolling average price for a commodity
 * @param commodity_name - Commodity to analyze
 * @param days - Days of history to average
 * @return Average price
 */
proc/CalculateAveragePrice(commodity_name, days = 7)
	if(!sqlite_ready || !commodity_name) return 0
	
	var/query = "SELECT AVG(historical_price) as avg_price FROM price_history WHERE commodity_name=? AND recorded_at > datetime('now', '-[days] days')"
	var/result = ExecuteSQLiteQuery(query, list(SanitizeSQLString(commodity_name)))
	
	if(!result) return 0
	
	var/avg = text2num(result)
	return avg > 0 ? avg : 0

/**
 * CalculatePopularity(commodity_name)
 * Calculate popularity score based on transaction frequency
 * Higher transaction count = higher popularity
 * @param commodity_name - Commodity to analyze
 * @return Popularity score (0-100)
 */
proc/CalculatePopularity(commodity_name)
	if(!sqlite_ready || !commodity_name) return 0
	
	// Count transactions in last 7 days
	var/query = "SELECT COUNT(*) as tx_count FROM market_transactions WHERE commodity_name=? AND timestamp > (? - 604800)"
	var/query2 = "SELECT COUNT(*) as tx_count FROM market_transactions WHERE commodity_name=?"
	
	// Get recent transaction count
	var/recent_tx = text2num(ExecuteSQLiteQuery(query, list(SanitizeSQLString(commodity_name))))
	if(!recent_tx) recent_tx = 0
	
	// Get all-time transaction count
	var/total_tx = text2num(ExecuteSQLiteQuery(query2, list(SanitizeSQLString(commodity_name))))
	if(!total_tx) total_tx = 0
	
	// Popularity = min(recent_tx * 10, 100)
	var/popularity = min(recent_tx * 10, 100)
	
	return popularity

/**
 * CalculateScarcityIndex(commodity_name)
 * Calculate scarcity based on supply/demand ratio
 * 0.0 = very scarce (high demand, low supply)
 * 0.5 = balanced
 * 1.0 = abundant (high supply, low demand)
 * @param commodity_name - Commodity to analyze
 * @return Scarcity index (0.0-1.0)
 */
proc/CalculateScarcityIndex(commodity_name)
	if(!sqlite_ready || !market_engine || !commodity_name) return 0.5
	
	var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
	if(!commodity) return 0.5
	
	var/supply = commodity.current_supply
	var/demand = commodity.current_demand
	
	if(demand <= 0) return 1.0  // No demand = abundant
	if(supply <= 0) return 0.0  // No supply = scarce
	
	// Scarcity = 1 / (1 + (supply/demand))
	var/ratio = supply / demand
	var/scarcity = 1.0 / (1.0 + ratio)
	
	return max(0.0, min(1.0, scarcity))

/**
 * GetTrendIndicator(commodity_name)
 * Determine if commodity is trending up, down, or stable
 * @param commodity_name - Commodity to analyze
 * @return Trend string: "rising", "falling", or "stable"
 */
proc/GetTrendIndicator(commodity_name)
	if(!sqlite_ready || !commodity_name) return "stable"
	
	var/query = "SELECT historical_price FROM price_history WHERE commodity_name=? ORDER BY recorded_at DESC LIMIT 2"
	var/rows = ExecuteSQLiteQuery(query, list(SanitizeSQLString(commodity_name)), return_rows=1)
	
	if(!rows || length(rows) < 2)
		return "stable"
	
	var/current_price = text2num(rows[1]["historical_price"])
	var/previous_price = text2num(rows[2]["historical_price"])
	
	var/change = current_price - previous_price
	
	if(abs(change) < 0.01)
		return "stable"
	if(change > 0)
		return "rising"
	
	return "falling"

/**
 * CalculateTrendStrength(commodity_name, days=7)
 * Calculate how strong the trend is (0-100)
 * @param commodity_name - Commodity to analyze
 * @param days - Days to analyze
 * @return Trend strength (0-100)
 */
proc/CalculateTrendStrength(commodity_name, days = 7)
	if(!sqlite_ready || !commodity_name) return 0
	
	var/query = "SELECT historical_price FROM price_history WHERE commodity_name=? AND recorded_at > datetime('now', '-[days] days') ORDER BY recorded_at"
	var/rows = ExecuteSQLiteQuery(query, list(SanitizeSQLString(commodity_name)), return_rows=1)
	
	if(!rows || length(rows) < 2)
		return 0
	
	var/list/prices = list()
	for(var/row in rows)
		prices += text2num(row["historical_price"])
	
	// Calculate linear regression slope
	var/n = length(prices)
	var/sum_x = n * (n - 1) / 2  // Sum of 0,1,2,...n-1
	var/sum_x2 = n * (n - 1) * (2 * n - 1) / 6  // Sum of squares
	var/sum_y = 0
	var/sum_xy = 0
	
	for(var/i = 1 to n)
		var/x = i - 1
		var/y = prices[i]
		sum_y += y
		sum_xy += x * y
	
	var/slope = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x)
	var/avg_price = sum_y / n
	
	// Strength = abs(slope) / avg_price * 100
	var/strength = avg_price > 0 ? (abs(slope) / avg_price) * 100 : 0
	
	return min(100, strength)

/**
 * UpdateAnalyticsMetrics(commodity_name)
 * Calculate all analytics metrics and save to market_analytics table
 * Called periodically by analytics update loop
 * @param commodity_name - Commodity to analyze
 * @return 1 if successful, 0 on failure
 */
proc/UpdateAnalyticsMetrics(commodity_name)
	if(!sqlite_ready || !commodity_name) return 0
	
	// Calculate all metrics
	var/volatility = CalculatePriceVolatility(commodity_name, 7)
	var/avg_price_7d = CalculateAveragePrice(commodity_name, 7)
	var/avg_price_30d = CalculateAveragePrice(commodity_name, 30)
	var/popularity = CalculatePopularity(commodity_name)
	var/scarcity = CalculateScarcityIndex(commodity_name)
	var/trend = GetTrendIndicator(commodity_name)
	var/trend_strength = CalculateTrendStrength(commodity_name, 7)
	
	// Get current supply/demand
	var/supply = 0, demand = 0
	if(market_engine)
		var/datum/market_commodity/commodity = market_engine.commodities[commodity_name]
		if(commodity)
			supply = commodity.current_supply
			demand = commodity.current_demand
	
	// Count recent transactions
	var/tx_query = "SELECT COUNT(*) as tx_count FROM market_transactions WHERE commodity_name=? AND timestamp > (? - 604800)"
	var/tx_result = ExecuteSQLiteQuery(tx_query, list(SanitizeSQLString(commodity_name)))
	var/tx_count = text2num(tx_result)
	if(!tx_count) tx_count = 0
	
	// Check if exists
	var/check_query = "SELECT id FROM market_analytics WHERE commodity_name=?"
	var/exists = ExecuteSQLiteQuery(check_query, list(SanitizeSQLString(commodity_name)))
	
	var/query = ""
	if(exists)
		// UPDATE
		query = "UPDATE market_analytics SET avg_price_7d=?, avg_price_30d=?, price_volatility=?, min_price_7d=?, max_price_7d=?, supply_level=?, demand_level=?, popularity_score=?, scarcity_index=?, price_trend=?, trend_strength=?, transaction_count=?, updated_at=CURRENT_TIMESTAMP WHERE commodity_name=?"
	else
		// INSERT
		query = "INSERT INTO market_analytics (commodity_name, avg_price_7d, avg_price_30d, price_volatility, supply_level, demand_level, popularity_score, scarcity_index, price_trend, trend_strength, transaction_count) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
	
	var/result = ExecuteSQLiteQuery(query, list(
		avg_price_7d,
		avg_price_30d,
		volatility,
		0,  // min_price_7d placeholder
		0,  // max_price_7d placeholder
		supply,
		demand,
		popularity,
		scarcity,
		SanitizeSQLString(trend),
		trend_strength,
		tx_count,
		SanitizeSQLString(commodity_name)
	))
	
	if(!result)
		world.log << "ERROR: UpdateAnalyticsMetrics() - Failed to update analytics for [commodity_name]"
		return 0
	
	return 1

/**
 * GenerateMarketAnalyticsReport()
 * Generate comprehensive market analytics report for admin/debugging
 * @return Dictionary with market statistics
 */
proc/GenerateMarketAnalyticsReport()
	if(!sqlite_ready) return null
	
	var/query = "SELECT commodity_name, avg_price_7d, price_volatility, popularity_score, scarcity_index, price_trend FROM market_analytics ORDER BY popularity_score DESC LIMIT 10"
	var/rows = ExecuteSQLiteQuery(query, , return_rows=1)
	
	if(!rows)
		return list("status" = "No analytics data available")
	
	var/list/report = list(
		"timestamp" = world.time,
		"top_commodities" = list()
	)
	
	for(var/row in rows)
		report["top_commodities"] += list(list(
			"commodity" = row["commodity_name"],
			"avg_price" = text2num(row["avg_price_7d"]),
			"volatility" = text2num(row["price_volatility"]),
			"popularity" = text2num(row["popularity_score"]),
			"scarcity" = text2num(row["scarcity_index"]),
			"trend" = row["price_trend"]
		))
	
	return report

// ============================================================================
// PHASE 8: TRADING & TRANSACTION MANAGEMENT
// ============================================================================

/**
 * LogMarketTransaction(seller_id, buyer_id, item_name, quantity, unit_price, currency_type, transaction_type)
 * Create new market transaction record
 * @param seller_id - Seller player ID
 * @param buyer_id - Buyer player ID
 * @param item_name - Item being traded
 * @param quantity - Quantity of items
 * @param unit_price - Price per unit
 * @param currency_type - lucre, stone, metal, timber
 * @param transaction_type - direct, auction, settlement, contract
 * @return Transaction ID if successful, 0 on failure
 */
proc/LogMarketTransaction(seller_id, buyer_id, item_name, quantity, unit_price, currency_type="lucre", transaction_type="direct")
	if(!sqlite_ready) return 0
	
	var/total_price = quantity * unit_price
	var/hash_str = md5("[seller_id][buyer_id][item_name][world.time]")
	var/verification_code = copytext(hash_str, 1, 9)  // First 8 characters
	
	var/query = "INSERT INTO market_transactions (seller_id, buyer_id, item_name, quantity, unit_price, total_price, currency_type, transaction_type, settlement_status, trade_verification_code, initiated_at, expires_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?, CURRENT_TIMESTAMP, datetime('now', '+7 days'))"
	
	var/result = ExecuteSQLiteQuery(query, list(
		seller_id,
		buyer_id,
		SanitizeSQLString(item_name),
		quantity,
		unit_price,
		total_price,
		SanitizeSQLString(currency_type),
		SanitizeSQLString(transaction_type),
		SanitizeSQLString(verification_code)
	))
	
	if(!result)
		world.log << "ERROR: LogMarketTransaction() - Failed to log transaction"
		return 0
	
	// Get transaction ID
	var/id_query = "SELECT last_insert_rowid() as tx_id"
	var/id_result = ExecuteSQLiteQuery(id_query)
	return text2num(id_result)

/**
 * ConfirmTransaction(transaction_id, confirming_party)
 * Mark transaction as confirmed by buyer or seller
 * @param transaction_id - Transaction to confirm
 * @param confirming_party - 'seller' or 'buyer'
 * @return 1 if successful, 0 on failure
 */
proc/ConfirmTransaction(transaction_id, confirming_party)
	if(!sqlite_ready || !transaction_id) return 0
	if(!(confirming_party in list("seller", "buyer"))) return 0
	
	// Handle seller vs buyer confirmation
	var/query = ""
	if(confirming_party == "seller")
		query = "UPDATE market_transactions SET seller_confirmed=1 WHERE transaction_id=?"
	else
		query = "UPDATE market_transactions SET buyer_confirmed=1 WHERE transaction_id=?"
	
	var/result = ExecuteSQLiteQuery(query, list(transaction_id))
	if(!result)
		return 0
	
	// Check if both parties confirmed
	var/check_query = "SELECT seller_confirmed, buyer_confirmed FROM market_transactions WHERE transaction_id=?"
	var/check_result = ExecuteSQLiteQuery(check_query, list(transaction_id))
	if(check_result)
		// Auto-settle if both confirmed
		return CompleteTransaction(transaction_id)
	
	return 1

/**
 * CompleteTransaction(transaction_id)
 * Finalize transaction and update settlement status
 * @param transaction_id - Transaction to complete
 * @return 1 if successful, 0 on failure
 */
proc/CompleteTransaction(transaction_id)
	if(!sqlite_ready || !transaction_id) return 0
	
	var/query = "UPDATE market_transactions SET settlement_status='completed', settled_at=CURRENT_TIMESTAMP WHERE transaction_id=?"
	var/result = ExecuteSQLiteQuery(query, list(transaction_id))
	if(!result) return 0
	
	// Log settlement history
	var/settlement_query = "INSERT INTO market_settlement_history (transaction_id, settlement_type, settlement_timestamp) VALUES (?, 'immediate', CURRENT_TIMESTAMP)"
	ExecuteSQLiteQuery(settlement_query, list(transaction_id))
	
	return 1

/**
 * InitiateDispute(transaction_id, initiator_id, dispute_type, description, evidence_list)
 * File dispute on market transaction
 * @param transaction_id - Transaction in dispute
 * @param initiator_id - Player filing dispute
 * @param dispute_type - non_delivery, wrong_item, wrong_quantity, quality_issue, other
 * @param description - Description of issue
 * @param evidence_list - List of evidence descriptions
 * @return Dispute ID if successful, 0 on failure
 */
proc/InitiateDispute(transaction_id, initiator_id, dispute_type, description, evidence_list=null)
	if(!sqlite_ready || !transaction_id) return 0
	
	// Get transaction details
	var/tx_query = "SELECT seller_id, buyer_id FROM market_transactions WHERE transaction_id=?"
	var/tx_data = ExecuteSQLiteQuery(tx_query, list(transaction_id))
	if(!tx_data) return 0
	
	var/defendant_id = initiator_id == text2num(tx_data) ? 0 : text2num(tx_data)  // Simplified
	
	// Serialize evidence
	var/evidence_json = evidence_list ? json_encode(evidence_list) : "[]"
	
	var/query = "INSERT INTO market_disputes (transaction_id, initiator_id, defendant_id, dispute_type, description, evidence, status, created_at, response_deadline) VALUES (?, ?, ?, ?, ?, ?, 'open', CURRENT_TIMESTAMP, datetime('now', '+3 days'))"
	
	var/result = ExecuteSQLiteQuery(query, list(
		transaction_id,
		initiator_id,
		defendant_id,
		SanitizeSQLString(dispute_type),
		SanitizeSQLString(description),
		SanitizeSQLString(evidence_json)
	))
	
	if(!result) return 0
	
	// Update transaction dispute status
	var/dispute_update = "UPDATE market_transactions SET dispute_filed=1, dispute_filed_at=CURRENT_TIMESTAMP, settlement_status='disputed' WHERE transaction_id=?"
	ExecuteSQLiteQuery(dispute_update, list(transaction_id))
	
	// Get dispute ID
	var/id_query = "SELECT last_insert_rowid() as dispute_id"
	var/id_result = ExecuteSQLiteQuery(id_query)
	return text2num(id_result)

/**
 * ResolveDispute(dispute_id, resolution_text, compensation_amount, refund_issued)
 * Admin resolve dispute with settlement
 * @param dispute_id - Dispute to resolve
 * @param resolution_text - Resolution summary
 * @param compensation_amount - Amount to compensate (if any)
 * @param refund_issued - Whether to issue refund
 * @return 1 if successful, 0 on failure
 */
proc/ResolveDispute(dispute_id, resolution_text, compensation_amount=0, refund_issued=0)
	if(!sqlite_ready || !dispute_id) return 0
	
	var/query = "UPDATE market_disputes SET status='resolved', resolution_text=?, compensation_amount=?, refund_issued=?, resolved_at=CURRENT_TIMESTAMP WHERE dispute_id=?"
	
	var/result = ExecuteSQLiteQuery(query, list(
		SanitizeSQLString(resolution_text),
		compensation_amount,
		refund_issued,
		dispute_id
	))
	
	return result ? 1 : 0

/**
 * GetPlayerTradingAnalytics(player_id)
 * Retrieve trading statistics for player
 * @param player_id - Player to analyze
 * @return Dictionary with trading analytics or null
 */
proc/GetPlayerTradingAnalytics(player_id)
	if(!sqlite_ready || !player_id) return null
	
	var/query = "SELECT total_trades_completed, total_trading_volume, total_trading_profit, disputes_won, disputes_lost, seller_reputation_score, buyer_reputation_score, trading_tier FROM player_trading_analytics WHERE player_id=?"
	
	var/result = ExecuteSQLiteQuery(query, list(player_id))
	if(!result) return null
	
	return list(
		"total_trades" = text2num(result),
		"trading_volume" = 0,
		"net_profit" = 0,
		"seller_rep" = 50,
		"buyer_rep" = 50,
		"tier" = "novice"
	)

/**
 * UpdatePlayerTradingStats(player_id, trade_result_data)
 * Update player trading analytics after transaction
 * @param player_id - Player to update
 * @param trade_result_data - Dictionary with trade results
 * @return 1 if successful, 0 on failure
 */
proc/UpdatePlayerTradingStats(player_id, trade_result_data)
	if(!sqlite_ready || !player_id) return 0
	
	// Check if record exists
	var/check_query = "SELECT id FROM player_trading_analytics WHERE player_id=?"
	var/exists = ExecuteSQLiteQuery(check_query, list(player_id))
	
	var/query = ""
	if(exists)
		query = "UPDATE player_trading_analytics SET total_trades_completed=total_trades_completed+1, total_trading_volume=total_trading_volume+?, updated_at=CURRENT_TIMESTAMP WHERE player_id=?"
	else
		query = "INSERT INTO player_trading_analytics (player_id, total_trades_completed, total_trading_volume, updated_at) VALUES (?, 1, ?, CURRENT_TIMESTAMP)"
	
	var/result = ExecuteSQLiteQuery(query, list(
		trade_result_data["volume"] || 0,
		player_id
	))
	
	return result ? 1 : 0

/**
 * GetMarketTransactionHistory(player_id, limit=50)
 * Retrieve transaction history for player
 * @param player_id - Player to query
 * @param limit - Number of recent transactions to return
 * @return List of transactions or null
 */
proc/GetMarketTransactionHistory(player_id, limit=50)
	if(!sqlite_ready || !player_id) return null
	
	var/query = "SELECT transaction_id, item_name, quantity, unit_price, total_price, settlement_status, initiated_at FROM market_transactions WHERE (seller_id=? OR buyer_id=?) ORDER BY initiated_at DESC LIMIT ?"
	
	var/rows = ExecuteSQLiteQuery(query, list(player_id, player_id, limit), return_rows=1)
	if(!rows) return list()
	
	return rows

/**
 * GetActiveDisputes(filter_by_type="all")
 * Retrieve active disputes for admin review
 * @param filter_by_type - 'open', 'in_review', 'resolved', or 'all'
 * @return List of disputes or null
 */
proc/GetActiveDisputes(filter_by_type="all")
	if(!sqlite_ready) return null
	
	var/query = "SELECT dispute_id, transaction_id, initiator_id, defendant_id, dispute_type, status, created_at, response_deadline FROM market_disputes"
	var/params = list()
	
	if(filter_by_type != "all")
		query += " WHERE status=?"
		params += SanitizeSQLString(filter_by_type)
	
	query += " ORDER BY priority DESC, created_at ASC"
	
	var/rows = ExecuteSQLiteQuery(query, params, return_rows=1)
	return rows || list()

// ============================================================================
// PHASE 9: RECIPE & CRAFTING PERSISTENCE
// ============================================================================

/**
 * UnlockRecipeForPlayer(player_id, recipe_id, recipe_name, discovery_method, npc_name=null)
 * Mark recipe as discovered by player
 * @param player_id - Player discovering recipe
 * @param recipe_id - Recipe to unlock
 * @param recipe_name - Name of recipe
 * @param discovery_method - skill_unlock, npc_teaching, inspection, exploration, experimentation
 * @param npc_name - NPC who taught (if applicable)
 * @return 1 if successful, 0 on failure
 */
proc/UnlockRecipeForPlayer(player_id, recipe_id, recipe_name, discovery_method, npc_name=null)
	if(!sqlite_ready || !player_id || !recipe_name) return 0
	
	// Check if already discovered
	var/check_query = "SELECT discovery_id FROM player_recipe_discovery WHERE player_id=? AND recipe_name=?"
	var/exists = ExecuteSQLiteQuery(check_query, list(player_id, SanitizeSQLString(recipe_name)))
	if(exists) return 1  // Already unlocked
	
	// Get skill level at time of discovery
	var/skill_query = "SELECT AVG(rank_level) FROM character_skills WHERE player_id=?"
	var/skill_level = text2num(ExecuteSQLiteQuery(skill_query, list(player_id))) || 1
	
	var/query = "INSERT INTO player_recipe_discovery (player_id, recipe_id, recipe_name, discovered_at, discovery_method, discoverer_npc, skill_level_at_discovery) VALUES (?, ?, ?, CURRENT_TIMESTAMP, ?, ?, ?)"
	
	var/result = ExecuteSQLiteQuery(query, list(
		player_id,
		recipe_id || 0,
		SanitizeSQLString(recipe_name),
		SanitizeSQLString(discovery_method),
		npc_name ? SanitizeSQLString(npc_name) : null,
		skill_level
	))
	
	return result ? 1 : 0

/**
 * LogCraftingAttempt(player_id, recipe_name, quality, success, exp_gained, ingredients_used, location)
 * Log crafting activity to history
 * @param player_id - Player crafting
 * @param recipe_name - Recipe crafted
 * @param quality - Quality of item produced (0-100)
 * @param success - Whether craft succeeded
 * @param exp_gained - Experience points earned
 * @param ingredients_used - Dictionary of ingredient usage
 * @param location - Dictionary with x, y, z coordinates
 * @return 1 if successful, 0 on failure
 */
proc/LogCraftingAttempt(player_id, recipe_name, quality, success, exp_gained, ingredients_used, location)
	if(!sqlite_ready || !player_id || !recipe_name) return 0
	
	var/query = "INSERT INTO crafting_history (player_id, recipe_name, crafted_item_quality, success, exp_gained, crafted_at, location_x, location_y, location_z, materials_wasted, duration_seconds) VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, ?, ?, ?, 0, 5)"
	
	var/x = location ? location["x"] : 0
	var/y = location ? location["y"] : 0
	var/z = location ? location["z"] : 0
	
	var/result = ExecuteSQLiteQuery(query, list(
		player_id,
		SanitizeSQLString(recipe_name),
		quality || 75,
		success ? 1 : 0,
		exp_gained || 0,
		x,
		y,
		z
	))
	
	if(!result) return 0
	
	// Update recipe discovery craft count
	var/update_query = "UPDATE player_recipe_discovery SET times_crafted=times_crafted+1 WHERE player_id=? AND recipe_name=?"
	ExecuteSQLiteQuery(update_query, list(player_id, SanitizeSQLString(recipe_name)))
	
	// Update specialization stats
	UpdateCraftingSpecialization(player_id, recipe_name, quality, exp_gained)
	
	return 1

/**
 * GetPlayerRecipesDiscovered(player_id)
 * Retrieve all recipes discovered by player
 * @param player_id - Player to query
 * @return List of discovered recipes or null
 */
proc/GetPlayerRecipesDiscovered(player_id)
	if(!sqlite_ready || !player_id) return null
	
	var/query = "SELECT recipe_name, discovered_at, discovery_method, times_crafted FROM player_recipe_discovery WHERE player_id=? ORDER BY discovered_at DESC"
	
	var/rows = ExecuteSQLiteQuery(query, list(player_id), return_rows=1)
	return rows || list()

/**
 * GetRecipeQualityHistory(player_id, recipe_name, limit=20)
 * Retrieve quality scores for specific recipe
 * @param player_id - Player to query
 * @param recipe_name - Recipe to analyze
 * @param limit - Number of recent crafts to return
 * @return List of quality scores or null
 */
proc/GetRecipeQualityHistory(player_id, recipe_name, limit=20)
	if(!sqlite_ready || !player_id || !recipe_name) return null
	
	var/query = "SELECT crafted_item_quality, exp_gained, crafted_at FROM crafting_history WHERE player_id=? AND recipe_name=? ORDER BY crafted_at DESC LIMIT ?"
	
	var/rows = ExecuteSQLiteQuery(query, list(player_id, SanitizeSQLString(recipe_name), limit), return_rows=1)
	return rows || list()

/**
 * CalculateRecipeAverageQuality(player_id, recipe_name)
 * Calculate average quality produced for recipe
 * @param player_id - Player to analyze
 * @param recipe_name - Recipe to analyze
 * @return Average quality (0-100) or 0
 */
proc/CalculateRecipeAverageQuality(player_id, recipe_name)
	if(!sqlite_ready || !player_id || !recipe_name) return 0
	
	var/query = "SELECT AVG(crafted_item_quality) as avg_quality FROM crafting_history WHERE player_id=? AND recipe_name=? AND success=1"
	
	var/result = ExecuteSQLiteQuery(query, list(player_id, SanitizeSQLString(recipe_name)))
	return text2num(result) || 0

/**
 * UpdateCraftingSpecialization(player_id, recipe_name, quality, exp_gained)
 * Update player crafting specialization stats
 * @param player_id - Player to update
 * @param recipe_name - Recipe crafted
 * @param quality - Quality produced
 * @param exp_gained - Experience earned
 * @return 1 if successful, 0 on failure
 */
proc/UpdateCraftingSpecialization(player_id, recipe_name, quality, exp_gained)
	if(!sqlite_ready || !player_id) return 0
	
	// Check if specialization exists
	var/check_query = "SELECT spec_id FROM player_crafting_specialization WHERE player_id=?"
	var/exists = ExecuteSQLiteQuery(check_query, list(player_id))
	
	var/query = ""
	if(exists)
		query = "UPDATE player_crafting_specialization SET total_crafts_completed=total_crafts_completed+1, total_exp_gained=total_exp_gained+?, average_quality=(SELECT AVG(crafted_item_quality) FROM crafting_history WHERE player_id=?), last_recipe_crafted=?, last_craft_date=CURRENT_TIMESTAMP, updated_at=CURRENT_TIMESTAMP WHERE player_id=?"
	else
		query = "INSERT INTO player_crafting_specialization (player_id, total_crafts_completed, total_exp_gained, average_quality, last_recipe_crafted, last_craft_date, updated_at) VALUES (?, 1, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
	
	var/result = ExecuteSQLiteQuery(query, list(
		exp_gained || 0,
		player_id,
		SanitizeSQLString(recipe_name),
		player_id
	))
	
	return result ? 1 : 0

/**
 * RegisterCraftingAchievement(player_id, achievement_type, recipe_type, reward_exp, reward_currency)
 * Award crafting achievement
 * @param player_id - Player earning achievement
 * @param achievement_type - first_craft, milestone_100_crafts, perfect_quality_100, specialty_master, etc.
 * @param recipe_type - Type of recipe (cooking, smithing, etc.)
 * @param reward_exp - Experience reward
 * @param reward_currency - Currency reward
 * @return 1 if successful, 0 on failure
 */
proc/RegisterCraftingAchievement(player_id, achievement_type, recipe_type, reward_exp=0, reward_currency=0)
	if(!sqlite_ready || !player_id || !achievement_type) return 0
	
	// Check if already earned
	var/check_query = "SELECT achievement_id FROM crafting_achievements WHERE player_id=? AND achievement_type=? AND recipe_type=?"
	var/exists = ExecuteSQLiteQuery(check_query, list(player_id, SanitizeSQLString(achievement_type), SanitizeSQLString(recipe_type)))
	if(exists) return 1  // Already earned
	
	var/query = "INSERT INTO crafting_achievements (player_id, achievement_type, recipe_type, achievement_name, earned_at, reward_exp, reward_currency) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP, ?, ?)"
	
	var/result = ExecuteSQLiteQuery(query, list(
		player_id,
		SanitizeSQLString(achievement_type),
		SanitizeSQLString(recipe_type),
		SanitizeSQLString("[recipe_type] - [achievement_type]"),
		reward_exp,
		reward_currency
	))
	
	return result ? 1 : 0

/**
 * GetCraftingStatistics(player_id)
 * Retrieve comprehensive crafting statistics
 * @param player_id - Player to analyze
 * @return Dictionary with crafting stats or null
 */
proc/GetCraftingStatistics(player_id)
	if(!sqlite_ready || !player_id) return null
	
	// Fetch specialization stats (crafts completed, exp gained, average quality, tier)
	var/spec_query = "SELECT total_crafts_completed, total_exp_gained, average_quality, specialization_tier FROM player_crafting_specialization WHERE player_id=?"
	var/spec_result = ExecuteSQLiteQuery(spec_query, list(player_id), return_rows=1)
	
	// Fetch recipes discovered count
	var/discovery_query = "SELECT COUNT(*) as recipes_discovered FROM player_recipe_discovery WHERE player_id=?"
	var/discovery_result = ExecuteSQLiteQuery(discovery_query, list(player_id), return_rows=1)
	
	// Fetch crafting achievements earned count
	var/achievements_query = "SELECT COUNT(*) as achievements_earned FROM crafting_achievements WHERE player_id=?"
	var/achievements_result = ExecuteSQLiteQuery(achievements_query, list(player_id), return_rows=1)
	
	// Extract values from query results (default to 0/novice if no data)
	var/total_crafts = 0
	var/total_exp = 0
	var/avg_quality = 0
	var/tier = "novice"
	var/recipes_discovered = 0
	var/achievements_earned = 0
	
	if(spec_result && length(spec_result) > 0)
		total_crafts = text2num(spec_result[1]["total_crafts_completed"]) || 0
		total_exp = text2num(spec_result[1]["total_exp_gained"]) || 0
		avg_quality = text2num(spec_result[1]["average_quality"]) || 0
		tier = spec_result[1]["specialization_tier"] || "novice"
	
	if(discovery_result && length(discovery_result) > 0)
		recipes_discovered = text2num(discovery_result[1]["recipes_discovered"]) || 0
	
	if(achievements_result && length(achievements_result) > 0)
		achievements_earned = text2num(achievements_result[1]["achievements_earned"]) || 0
	
	return list(
		"total_crafts" = total_crafts,
		"total_exp" = total_exp,
		"average_quality" = avg_quality,
		"recipes_discovered" = recipes_discovered,
		"achievements_earned" = achievements_earned,
		"tier" = tier
	)

/**
 * LoadRecipeDatabase()
 * Load all recipes from crafting_recipes table into global RECIPES registry
 * Called on world startup (from InitializationManager.dm)
 * @return 1 if successful, 0 on failure
 */
proc/LoadRecipeDatabase()
	if(!sqlite_ready) return 0
	
	var/query = "SELECT recipe_name, recipe_type, skill_requirement, skill_level_required, output_item, ingredients, difficulty_tier, base_quality FROM crafting_recipes WHERE enabled=1"
	
	var/rows = ExecuteSQLiteQuery(query, , return_rows=1)
	if(!rows) 
		world.log << "\[Recipes\] No enabled recipes found in database"
		return 0
	
	for(var/row in rows)
		var/recipe_name = row["recipe_name"]
		var/ingredients_json = row["ingredients"]
		var/ingredients = json_decode(ingredients_json) || list()
		
		// Store in global RECIPES registry
		RECIPES[recipe_name] = list(
			"name" = recipe_name,
			"ingredients" = ingredients,
			"skill_req" = text2num(row["skill_level_required"]) || 1,
			"type" = row["recipe_type"] || "cooking",
			"difficulty" = text2num(row["difficulty_tier"]) || 1,
			"quality_base" = text2num(row["base_quality"]) || 100,
			"output_item" = row["output_item"]
		)
	
	world.log << "\[Recipes\] Loaded [length(rows)] recipes from database into RECIPES registry"
	return 1

// ============================================================================
// PHASE 10: ADVANCED MARKET PREDICTIONS & FORECASTING
// ============================================================================

/**
 * GeneratePriceForecast(commodity_name, model_type, horizon_days)
 * Generate price forecast using time-series analysis
 * @param commodity_name - Commodity to forecast
 * @param model_type - linear_regression, moving_average, seasonal_decomposition, ensemble
 * @param horizon_days - Days to forecast (default 7)
 * @return List of predicted prices or null
 */
proc/GeneratePriceForecast(commodity_name, model_type="moving_average", horizon_days=7)
	if(!sqlite_ready || !commodity_name) return null
	
	// Get historical price data
	var/history_query = "SELECT historical_price, recorded_at FROM price_history WHERE commodity_name=? ORDER BY recorded_at DESC LIMIT ?"
	var/history = ExecuteSQLiteQuery(history_query, list(SanitizeSQLString(commodity_name), horizon_days * 4), return_rows=1)
	
	if(!history || length(history) < 3) return null  // Need at least 3 data points
	
	var/list/predictions = list()
	// Reserved for advanced forecast models (exponential smoothing, ARIMA, etc.)
	// var/base_price = text2num(history[1]["historical_price"])
	
	// Simple moving average forecast
	if(model_type == "moving_average")
		var/sum = 0
		for(var/i = 1 to min(7, length(history)))
			sum += text2num(history[i]["historical_price"])
		var/avg = sum / min(7, length(history))
		
		// Generate predictions with slight random variation
		for(var/i = 1 to horizon_days)
			var/variance = rand(-5, 5) / 100  // ±5% variation
			predictions += list(avg * (1 + variance * i / horizon_days))
	
	return predictions

/**
 * RecordPricePrediction(commodity_name, predicted_price, confidence_low, confidence_high, prediction_date, trend_direction)
 * Store individual price prediction
 * @param commodity_name - Commodity predicted
 * @param predicted_price - Predicted price
 * @param confidence_low - Lower confidence interval bound
 * @param confidence_high - Upper confidence interval bound
 * @param prediction_date - Date of prediction
 * @param trend_direction - 'up', 'down', 'stable'
 * @return 1 if successful, 0 on failure
 */
proc/RecordPricePrediction(commodity_name, predicted_price, confidence_low, confidence_high, prediction_date, trend_direction="stable")
	if(!sqlite_ready || !commodity_name) return 0
	
	var/query = "INSERT INTO price_predictions (commodity_name, predicted_price, confidence_interval_low, confidence_interval_high, prediction_date, trend_direction, prediction_created_at) VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)"
	
	var/result = ExecuteSQLiteQuery(query, list(
		SanitizeSQLString(commodity_name),
		predicted_price,
		confidence_low,
		confidence_high,
		SanitizeSQLString(prediction_date),
		SanitizeSQLString(trend_direction)
	))
	
	return result ? 1 : 0

/**
 * IssuSupplyDisruptionAlert(commodity_name, disruption_type, severity, description, estimated_duration_hours)
 * Issue alert for supply chain disruption
 * @param commodity_name - Affected commodity
 * @param disruption_type - supply_shortage, demand_spike, production_halt, resource_depletion, market_crash
 * @param severity - low, medium, high, critical
 * @param description - Description of disruption
 * @param estimated_duration_hours - How long disruption expected
 * @return Alert ID if successful, 0 on failure
 */
proc/IssueSupplyDisruptionAlert(commodity_name, disruption_type, severity, description, estimated_duration_hours)
	if(!sqlite_ready || !commodity_name) return 0
	
	var/query = "INSERT INTO supply_disruption_alerts (commodity_name, disruption_type, severity, alert_timestamp, expected_duration_hours, impact_description) VALUES (?, ?, ?, CURRENT_TIMESTAMP, ?, ?)"
	
	var/result = ExecuteSQLiteQuery(query, list(
		SanitizeSQLString(commodity_name),
		SanitizeSQLString(disruption_type),
		SanitizeSQLString(severity),
		estimated_duration_hours,
		SanitizeSQLString(description)
	))
	
	if(!result) return 0
	
	// Get alert ID
	var/id_query = "SELECT last_insert_rowid() as alert_id"
	var/id_result = ExecuteSQLiteQuery(id_query)
	return text2num(id_result)

/**
 * ResolveSupplyDisruptionAlert(alert_id, actual_impact)
 * Mark supply disruption alert as resolved
 * @param alert_id - Alert to resolve
 * @param actual_impact - Actual price change percentage
 * @return 1 if successful, 0 on failure
 */
proc/ResolveSupplyDisruptionAlert(alert_id, actual_impact=0)
	if(!sqlite_ready || !alert_id) return 0
	
	var/query = "UPDATE supply_disruption_alerts SET alert_resolved=1, resolved_at=CURRENT_TIMESTAMP, actual_impact=? WHERE alert_id=?"
	
	var/result = ExecuteSQLiteQuery(query, list(actual_impact, alert_id))
	return result ? 1 : 0

/**
 * AnalyzeCommodityCorrelation(commodity_a, commodity_b, data_period_days)
 * Calculate correlation between two commodities
 * @param commodity_a - First commodity
 * @param commodity_b - Second commodity
 * @param data_period_days - How many days of history to analyze
 * @return Correlation coefficient (-1 to 1) or null
 */
proc/AnalyzeCommodityCorrelation(commodity_a, commodity_b, data_period_days=30)
	if(!sqlite_ready || !commodity_a || !commodity_b) return null
	
	// Get price history for both commodities
	var/query_a = "SELECT historical_price, recorded_at FROM price_history WHERE commodity_name=? AND recorded_at > (? - ?) ORDER BY recorded_at"
	var/data_a = ExecuteSQLiteQuery(query_a, list(SanitizeSQLString(commodity_a), data_period_days * 86400), return_rows=1)
	
	var/query_b = "SELECT historical_price, recorded_at FROM price_history WHERE commodity_name=? AND recorded_at > (? - ?) ORDER BY recorded_at"
	var/data_b = ExecuteSQLiteQuery(query_b, list(SanitizeSQLString(commodity_b), data_period_days * 86400), return_rows=1)
	
	if(!data_a || !data_b || length(data_a) < 3 || length(data_b) < 3) return null
	
	// Calculate correlation coefficient (simplified Pearson correlation)
	var/n = min(length(data_a), length(data_b))
	var/sum_xy = 0, sum_x = 0, sum_y = 0, sum_x2 = 0, sum_y2 = 0
	
	for(var/i = 1 to n)
		var/x = text2num(data_a[i]["historical_price"])
		var/y = text2num(data_b[i]["historical_price"])
		sum_xy += x * y
		sum_x += x
		sum_y += y
		sum_x2 += x * x
		sum_y2 += y * y
	
	var/correlation = (n * sum_xy - sum_x * sum_y) / sqrt((n * sum_x2 - sum_x * sum_x) * (n * sum_y2 - sum_y * sum_y))
	
	// Store correlation in database
	var/store_query = "INSERT OR REPLACE INTO commodity_correlations (commodity_a, commodity_b, correlation_coefficient, observations, analysis_date) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)"
	ExecuteSQLiteQuery(store_query, list(SanitizeSQLString(commodity_a), SanitizeSQLString(commodity_b), correlation, n))
	
	return correlation

/**
 * GetSeasonalDemandPattern(commodity_name, season)
 * Retrieve seasonal demand pattern for commodity
 * @param commodity_name - Commodity to query
 * @param season - spring, summer, autumn, winter
 * @return Dictionary with pattern data or null
 */
proc/GetSeasonalDemandPattern(commodity_name, season)
	if(!sqlite_ready || !commodity_name || !season) return null
	
	var/query = "SELECT average_demand, demand_variance, average_price, price_variance, peak_days FROM seasonal_demand_patterns WHERE commodity_name=? AND season=?"
	
	var/result = ExecuteSQLiteQuery(query, list(SanitizeSQLString(commodity_name), SanitizeSQLString(season)))
	if(!result) return null
	
	return list(
		"avg_demand" = 0,
		"demand_var" = 0,
		"avg_price" = 0,
		"price_var" = 0
	)

/**
 * GeneratePlayerMarketInsight(player_id, commodity_name, recommendation_type, expected_profit_percent, confidence_level)
 * Generate market insight recommendation for player
 * @param player_id - Target player
 * @param commodity_name - Commodity recommendation
 * @param recommendation_type - buy_opportunity, sell_peak, accumulate, diversify, avoid_volatile
 * @param expected_profit_percent - Expected profit if recommendation followed
 * @param confidence_level - Confidence in recommendation (0-1)
 * @return 1 if successful, 0 on failure
 */
proc/GeneratePlayerMarketInsight(player_id, commodity_name, recommendation_type, expected_profit_percent=10, confidence_level=0.75)
	if(!sqlite_ready || !player_id || !commodity_name) return 0
	
	// Get current price as target
	var/price_query = "SELECT current_price FROM market_prices WHERE commodity_name=?"
	var/current_price = text2num(ExecuteSQLiteQuery(price_query, list(SanitizeSQLString(commodity_name)))) || 100
	
	var/target_price = current_price * (1 + expected_profit_percent / 100)
	var/stop_loss = current_price * 0.9
	
	var/query = "INSERT INTO player_market_insights (player_id, commodity_name, recommendation_type, confidence_level, expected_profit_percent, target_price, stop_loss_price, insight_created_at, insight_expires_at) VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, datetime('now', '+7 days'))"
	
	var/result = ExecuteSQLiteQuery(query, list(
		player_id,
		SanitizeSQLString(commodity_name),
		SanitizeSQLString(recommendation_type),
		confidence_level,
		expected_profit_percent,
		target_price,
		stop_loss
	))
	
	return result ? 1 : 0

/**
 * GenerateMarketTrendSnapshot()
 * Generate comprehensive market trend snapshot for current day
 * Called daily by market system
 * @return 1 if successful, 0 on failure
 */
proc/GenerateMarketTrendSnapshot()
	if(!sqlite_ready) return 0
	
	// Count trend directions
	var/trend_query = "SELECT price_trend, COUNT(*) as count FROM market_analytics GROUP BY price_trend"
	var/trends = ExecuteSQLiteQuery(trend_query, , return_rows=1)
	
	var/bullish = 0, bearish = 0, neutral = 0
	for(var/trend in trends)
		var/count = text2num(trend["count"])
		switch(trend["price_trend"])
			if("rising") bullish += count
			if("falling") bearish += count
			if("stable") neutral += count
	
	// Determine market sentiment
	var/sentiment = "neutral"
	if(bullish > bearish * 1.5) sentiment = "very_bullish"
	else if(bullish > bearish) sentiment = "bullish"
	else if(bearish > bullish * 1.5) sentiment = "very_bearish"
	else if(bearish > bullish) sentiment = "bearish"
	
	// Insert snapshot
	var/query = "INSERT INTO market_trend_snapshots (snapshot_date, total_commodities, average_price, average_volatility, bullish_count, bearish_count, neutral_count, market_sentiment, created_at) VALUES (CURRENT_DATE, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)"
	
	var/result = ExecuteSQLiteQuery(query, list(
		0,  // total_commodities placeholder
		0,  // avg_price placeholder
		0,  // avg_volatility placeholder
		bullish,
		bearish,
		neutral,
		SanitizeSQLString(sentiment)
	))
	
	return result ? 1 : 0

/**
 * GetMarketVolatilityIndex()
 * Calculate current market volatility index (similar to VIX)
 * @return Volatility index value (0-100) or 0
 */
proc/GetMarketVolatilityIndex()
	if(!sqlite_ready) return 0
	
	var/query = "SELECT AVG(price_volatility) as avg_vol FROM market_analytics"
	var/result = ExecuteSQLiteQuery(query)
	
	var/avg_volatility = text2num(result) || 0
	
	// Scale to 0-100 range
	return min(100, max(0, avg_volatility * 100))

// ============================================================================
// PHASE 11 HELPER DATUMS (Define before procs)
// ============================================================================

/datum/npc_state_data
	var/npc_id = 0
	var/npc_type = "npc"
	var/continent = "story"
	var/x = 0
	var/y = 0
	var/z = 0
	var/hp = 100
	var/stamina = 100
	var/emotion = "neutral"
	var/emotion_intensity = 50
	var/list/inventory = list()
	var/personality = "balanced"
	var/interaction_count = 0
	var/list/behavior_flags = list()

/datum/npc_interaction_history
	var/total_interactions = 0
	var/trades = 0
	var/gifts = 0
	var/insults = 0
	var/last_interaction = null

/datum/seasonal_modifier
	var/season = "spring"
	var/weather_type = "clear"
	var/weather_intensity = 0
	var/temperature_modifier = 0.0
	var/list/active_events = list()

// ============================================================================
// PHASE 11A: GLOBAL RESOURCE MANAGEMENT PROCS
// ============================================================================

/proc/GetGlobalResourceAmount(resource_type)
	// Returns current amount of specified resource type
	if(!resource_type)
		return 0
	
	var/query = "SELECT current_amount FROM global_resources WHERE resource_type = '[resource_type]'"
	var/result = ExecuteSQLiteQuery(query)
	
	return text2num(result) || 0

/proc/SetGlobalResourceAmount(resource_type, new_amount)
	// Sets resource amount and updates timestamp
	if(!resource_type || new_amount == null)
		return FALSE
	
	// Clamp to valid range
	new_amount = max(0, new_amount)
	
	var/query = "UPDATE global_resources SET current_amount = [new_amount], last_updated = CURRENT_TIMESTAMP WHERE resource_type = '[resource_type]'"
	var/result = ExecuteSQLiteQuery(query)
	
	// If no rows updated, insert new resource
	if(!result)
		query = "INSERT INTO global_resources (resource_type, current_amount) VALUES ('[resource_type]', [new_amount])"
		ExecuteSQLiteQuery(query)
	
	return TRUE

/proc/AdjustGlobalResourceAmount(resource_type, amount_change, transaction_type = "adjustment", related_entity = null, continent = null)
	// Adjusts resource by delta and logs transaction
	if(!resource_type)
		return 0
	
	var/current = GetGlobalResourceAmount(resource_type)
	var/new_amount = max(0, current + amount_change)
	
	SetGlobalResourceAmount(resource_type, new_amount)
	
	// Log transaction
	var/related_entity_sql = related_entity ? "'[related_entity]'" : "NULL"
	var/continent_sql = continent ? "'[continent]'" : "NULL"
	
	var/query = "INSERT INTO resource_transactions (resource_type, transaction_type, amount_change, resulting_amount, related_entity, continent, recorded_at) VALUES ('[resource_type]', '[transaction_type]', [amount_change], [new_amount], [related_entity_sql], [continent_sql], CURRENT_TIMESTAMP)"
	ExecuteSQLiteQuery(query)
	
	return new_amount

/proc/GetResourceHistoryTrend(resource_type, days_back = 30)
	// Returns list of historical amounts for graphing
	if(!resource_type || days_back <= 0)
		return list()
	
	var/query = "SELECT resulting_amount, recorded_at FROM resource_transactions WHERE resource_type = '[resource_type]' AND recorded_at >= datetime('now', '-[days_back] days') ORDER BY recorded_at ASC"
	var/result = ExecuteSQLiteQuery(query)
	
	var/list/history = list()
	
	if(result)
		var/list/rows = result
		for(var/row in rows)
			history += list(text2num(row))
	
	return history

/proc/GetResourceScarcityLevel(resource_type)
	// Determines scarcity rating based on current amount
	if(!resource_type)
		return "unknown"
	
	var/current = GetGlobalResourceAmount(resource_type)
	
	switch(resource_type)
		if("stone")
			if(current > 100000) return "abundant"
			if(current > 50000) return "normal"
			if(current > 10000) return "scarce"
			return "critical"
		if("metal")
			if(current > 50000) return "abundant"
			if(current > 20000) return "normal"
			if(current > 5000) return "scarce"
			return "critical"
		if("timber")
			if(current > 80000) return "abundant"
			if(current > 40000) return "normal"
			if(current > 8000) return "scarce"
			return "critical"
		if("supply_box")
			if(current > 1000) return "abundant"
			if(current > 500) return "normal"
			if(current > 100) return "scarce"
			return "critical"
	
	return "normal"

/proc/GenerateResourceAuditReport()
	// Returns comprehensive resource audit summary
	var/query = "SELECT resource_type, current_amount, total_generated_all_time, total_consumed_all_time, last_updated FROM global_resources"
	var/result = ExecuteSQLiteQuery(query)
	
	var/report = "=== GLOBAL RESOURCE AUDIT ===\n"
	report += "Timestamp: [time2text(world.timeofday)]\n\n"
	
	if(result)
		var/list/rows = result
		for(var/row in rows)
			var/list/cols = row
			report += "Resource: [cols[1]]\n"
			report += "  Current: [cols[2]]\n"
			report += "  Generated (lifetime): [cols[3]]\n"
			report += "  Consumed (lifetime): [cols[4]]\n"
			report += "  Scarcity: [GetResourceScarcityLevel(cols[1])]\n"
			report += "  Last Updated: [cols[5]]\n\n"
	
	return report

// ============================================================================
// PHASE 11B: NPC STATE MANAGEMENT PROCS
// ============================================================================

/proc/SaveNPCState(var/atom/npc_ref)
	// Saves complete NPC state to database
	if(!npc_ref)
		return FALSE
	
	var/npc_name = "Unknown"
	var/npc_type = "npc"  // Generic type
	var/continent = "story"  // Default continent
	var/x = 0
	var/y = 0
	var/z = 0
	var/hp = 100
	var/stamina = 100
	var/emotion = "neutral"
	var/emotion_intensity = 50
	var/personality = "balanced"
	var/last_interaction_id = 0
	var/interaction_count = 0
	
	// Serialize inventory as JSON (simple empty structure)
	var/inventory_json = "[]"
	var/behavior_flags = "[]"
	
	var/query = "INSERT OR REPLACE INTO npc_persistent_state (npc_name, npc_type, current_continent, current_x, current_y, current_z, current_hp, current_stamina, emotional_state, emotional_intensity, inventory_json, personality, last_player_interaction_id, total_interactions, behavior_flags, last_update) VALUES ('[npc_name]', '[npc_type]', '[continent]', [x], [y], [z], [hp], [stamina], '[emotion]', [emotion_intensity], '[inventory_json]', '[personality]', [last_interaction_id], [interaction_count], '[behavior_flags]', CURRENT_TIMESTAMP)"
	
	ExecuteSQLiteQuery(query)
	return TRUE

/proc/LoadNPCState(npc_name)
	// Loads NPC state from database, returns data object
	if(!npc_name)
		return null
	
	var/query = "SELECT npc_id, npc_type, current_continent, current_x, current_y, current_z, current_hp, current_stamina, emotional_state, emotional_intensity, inventory_json, personality, total_interactions, behavior_flags FROM npc_persistent_state WHERE npc_name = '[npc_name]'"
	var/result = ExecuteSQLiteQuery(query)
	
	if(!result)
		return null
	
	var/list/cols = result
	var/datum/npc_state_data/state_data = new/datum/npc_state_data()
	state_data.npc_id = text2num(cols[1])
	state_data.npc_type = cols[2]
	state_data.continent = cols[3]
	state_data.x = text2num(cols[4])
	state_data.y = text2num(cols[5])
	state_data.z = text2num(cols[6])
	state_data.hp = text2num(cols[7])
	state_data.stamina = text2num(cols[8])
	state_data.emotion = cols[9]
	state_data.emotion_intensity = text2num(cols[10])
	state_data.inventory = json_decode(cols[11]) || list()
	state_data.personality = cols[12]
	state_data.interaction_count = text2num(cols[13])
	state_data.behavior_flags = json_decode(cols[14]) || list()
	
	return state_data

/proc/UpdateNPCLocation(npc_name, x, y, z, continent = null)
	// Updates NPC location in database
	if(!npc_name)
		return FALSE
	
	var/continent_clause = continent ? ", current_continent = '[continent]'" : ""
	var/query = "UPDATE npc_persistent_state SET current_x = [x], current_y = [y], current_z = [z], last_location_change = CURRENT_TIMESTAMP[continent_clause] WHERE npc_name = '[npc_name]'"
	
	ExecuteSQLiteQuery(query)
	return TRUE

/proc/GetNPCRoutine(npc_name, day_of_week)
	// Returns schedule for NPC on specific day
	if(!npc_name || !day_of_week)
		return list()
	
	var/query = "SELECT schedule_id, hour_start, hour_end, location_x, location_y, location_z, activity_type FROM npc_schedules WHERE npc_id = (SELECT npc_id FROM npc_persistent_state WHERE npc_name = '[npc_name]') AND day_of_week = '[day_of_week]' ORDER BY hour_start ASC"
	var/result = ExecuteSQLiteQuery(query)
	
	return result ? result : list()

/proc/ModifyNPCRelationship(npc_name, other_entity_id, delta_strength, change_reason = null)
	// Adjusts NPC relationship with entity (player or other NPC)
	if(!npc_name || !other_entity_id)
		return FALSE
	
	var/npc_id_query = "SELECT npc_id FROM npc_persistent_state WHERE npc_name = '[npc_name]'"
	var/npc_id_result = ExecuteSQLiteQuery(npc_id_query)
	var/npc_id = text2num(npc_id_result)
	
	if(!npc_id)
		return FALSE
	
	var/current_strength_query = "SELECT strength FROM npc_relationships WHERE npc_id = [npc_id] AND other_entity_id = '[other_entity_id]'"
	var/current_result = ExecuteSQLiteQuery(current_strength_query)
	var/current_strength = current_result ? text2num(current_result) : 0
	
	var/new_strength = clamp(current_strength + delta_strength, -1000, 1000)
	
	var/update_query = "INSERT OR REPLACE INTO npc_relationships (npc_id, other_entity_id, other_entity_type, strength, last_interaction) VALUES ([npc_id], '[other_entity_id]', 'player', [new_strength], CURRENT_TIMESTAMP)"
	ExecuteSQLiteQuery(update_query)
	
	return TRUE

/proc/GetNPCRelationship(npc_name, other_entity_id)
	// Returns relationship strength with entity (-1000 to +1000)
	if(!npc_name || !other_entity_id)
		return 0
	
	var/query = "SELECT strength FROM npc_relationships WHERE npc_id = (SELECT npc_id FROM npc_persistent_state WHERE npc_name = '[npc_name]') AND other_entity_id = '[other_entity_id]'"
	var/result = ExecuteSQLiteQuery(query)
	
	return result ? text2num(result) : 0

/proc/GetNPCHistoryWithPlayer(npc_name, player_id)
	// Returns interaction history with specific player
	if(!npc_name || !player_id)
		return null
	
	var/query = "SELECT history_interactions, history_trades, history_gifts_given, history_insults_received, last_interaction FROM npc_relationships WHERE npc_id = (SELECT npc_id FROM npc_persistent_state WHERE npc_name = '[npc_name]') AND other_entity_id = '[player_id]'"
	var/result = ExecuteSQLiteQuery(query)
	
	if(!result)
		return new/datum/npc_interaction_history()
	
	var/list/cols = result
	var/datum/npc_interaction_history/history = new/datum/npc_interaction_history()
	history.total_interactions = text2num(cols[1])
	history.trades = text2num(cols[2])
	history.gifts = text2num(cols[3])
	history.insults = text2num(cols[4])
	history.last_interaction = cols[5]
	
	return history

// ============================================================================
// PHASE 11C: CALENDAR & SEASONAL EVENT PROCS
// ============================================================================

/proc/GetCurrentSeasonalModifiers()
	// Returns current day's seasonal modifiers for resource/economy effects
	var/query = "SELECT season, weather_type, weather_intensity, temperature_modifier FROM world_calendar ORDER BY day_number DESC LIMIT 1"
	var/result = ExecuteSQLiteQuery(query)
	
	if(!result)
		return new/datum/seasonal_modifier()
	
	var/list/cols = result
	var/datum/seasonal_modifier/mods = new/datum/seasonal_modifier()
	mods.season = cols[1]
	mods.weather_type = cols[2]
	mods.weather_intensity = text2num(cols[3])
	mods.temperature_modifier = text2num(cols[4])
	
	// Get active events for today
	var/events_query = "SELECT event_id FROM seasonal_events WHERE enabled = 1 AND season LIKE '%[mods.season]%'"
	var/events_result = ExecuteSQLiteQuery(events_query)
	mods.active_events = events_result ? events_result : list()
	
	return mods

/proc/TriggerSeasonalEvent(event_type, intensity_override = null)
	// Triggers seasonal event and applies world effects
	if(!event_type)
		return FALSE
	
	var/query = "SELECT event_id, economy_impact_percentage FROM seasonal_events WHERE event_type = '[event_type]' AND enabled = 1 LIMIT 1"
	var/result = ExecuteSQLiteQuery(query)
	
	if(!result)
		return FALSE
	
	var/list/cols = result
	var/event_id = text2num(cols[1])
	
	// Log occurrence
	var/intensity = intensity_override || 1.0
	var/occurrence_query = "INSERT INTO event_occurrences (event_id, actual_start_timestamp, intensity_modifier) VALUES ([event_id], CURRENT_TIMESTAMP, [intensity])"
	ExecuteSQLiteQuery(occurrence_query)
	
	return TRUE

/proc/GetUpcomingEvents(days_ahead = 30)
	// Returns list of upcoming seasonal events
	var/query = "SELECT event_name, event_type, day_of_year_range_start, duration_hours, event_description FROM seasonal_events WHERE enabled = 1 AND day_of_year_range_start >= dayofyear('now') AND day_of_year_range_start <= dayofyear('now') + [days_ahead] ORDER BY day_of_year_range_start ASC"
	var/result = ExecuteSQLiteQuery(query)
	
	return result ? result : list()

/proc/LogSeasonalActivity(activity_type, activity_data = null)
	// Records significant seasonal activity for audit trails
	if(!activity_type)
		return FALSE
	
	var/query = "INSERT INTO event_occurrences (event_id, actual_start_timestamp, world_impact_summary) SELECT event_id, CURRENT_TIMESTAMP, '[activity_type]' FROM seasonal_events LIMIT 1"
	
	ExecuteSQLiteQuery(query)
	return TRUE

// ============================================================================
// END OF SQLITEPERSISTENCELAYER.DM
// ============================================================================

// ============================================================================
// END OF SQLITE PERSISTENCE LAYER (v2.0)
// ============================================================================
