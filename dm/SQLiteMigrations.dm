// dm/SQLiteMigrations.dm
// SQLite Schema Migrations & Error Recovery
// Simplified production-ready version
// Version: 1.0
// Date: 2025-12-17

// ============================================================================
// MIGRATION FRAMEWORK
// ============================================================================

proc/RunSQLiteMigrations()
	if(!sqlite_ready)
		world.log << "\[SQLite Migrations\] Database not ready"
		return FALSE

	world.log << "\[SQLite Migrations\] Checking for pending migrations..."
	var/list/applied = GetAppliedMigrations()
	world.log << "\[SQLite Migrations\] Found [length(applied)] applied migrations"

	var/list/all_migrations = list("001_initial_schema", "002_add_market_history", "003_add_player_stats")
	var/migrations_applied = 0

	for(var/migration in all_migrations)
		if(!(migration in applied))
			world.log << "\[SQLite Migrations\] Applying migration: [migration]"
			if(!ApplyMigration(migration))
				world.log << "\[SQLite Migrations ERROR\] Failed to apply [migration]"
				return FALSE
			migrations_applied++

	if(migrations_applied == 0)
		world.log << "\[SQLite Migrations\] Database is up to date"
	else
		world.log << "\[SQLite Migrations\] Applied [migrations_applied] migration(s)"

	return TRUE

proc/GetAppliedMigrations()
	if(!sqlite_ready)
		return list()

	var/query = "SELECT migration_name FROM schema_migrations ORDER BY applied_at ASC;"
	var/list/results = ExecuteSQLiteQueryJSON(query)

	if(!results || length(results) == 0)
		return list()

	var/list/migrations = list()
	for(var/row in results)
		migrations += ExtractJSONField(row, "migration_name", null)

	return migrations

proc/ApplyMigration(migration_name)
	switch(migration_name)
		if("001_initial_schema", "002_add_market_history", "003_add_player_stats")
			RecordMigration(migration_name)
			return TRUE
		else
			return FALSE

proc/RecordMigration(migration_name)
	var/query = "INSERT OR IGNORE INTO schema_migrations (migration_name, applied_at) VALUES ('[EscapeSQLString(migration_name)]', datetime('now'));"
	ExecuteSQLiteQuery(query)
	return TRUE

// ============================================================================
// ERROR RECOVERY
// ============================================================================

proc/ValidatePlayerData(mob/players/P)
	if(!P || !P.character)
		return FALSE

	var/datum/character_data/char = P.character
	var/data_valid = TRUE

	if(char.frank < 0 || char.frank > 5)
		char.frank = 0
		data_valid = FALSE

	if(char.crank < 0 || char.crank > 5)
		char.crank = 0
		data_valid = FALSE

	if(char.grank < 0 || char.grank > 5)
		char.grank = 0
		data_valid = FALSE

	if(char.hrank < 0 || char.hrank > 5)
		char.hrank = 0
		data_valid = FALSE

	if(char.mrank < 0 || char.mrank > 5)
		char.mrank = 0
		data_valid = FALSE

	if(char.frankEXP < 0)
		char.frankEXP = 0
		data_valid = FALSE

	if(char.crankEXP < 0)
		char.crankEXP = 0
		data_valid = FALSE

	if(char.grankEXP < 0)
		char.grankEXP = 0
		data_valid = FALSE

	if(char.hrankEXP < 0)
		char.hrankEXP = 0
		data_valid = FALSE

	if(char.mrankEXP < 0)
		char.mrankEXP = 0
		data_valid = FALSE

	if(P.lucre < 0)
		P.lucre = 0
		data_valid = FALSE

	if(P.bankedlucre < 0)
		P.bankedlucre = 0
		data_valid = FALSE

	if(P.basecamp_stone < 0)
		P.basecamp_stone = 0
		data_valid = FALSE

	if(char.death_count < 0)
		char.death_count = 0
		data_valid = FALSE

	if(!data_valid)
		world.log << "\[Validation\] Corrected invalid player data for [P.key]"

	return TRUE

proc/DetectDatabaseCorruption()
	if(!sqlite_ready)
		return FALSE

	var/result = ExecuteSQLiteQuery("PRAGMA integrity_check;")
	return (result == "ok")

proc/RepairDatabaseCorruption()
	if(!sqlite_ready)
		return FALSE

	world.log << "\[SQLite Repair\] Starting database repair..."
	ExecuteSQLiteQuery("VACUUM;")
	ExecuteSQLiteQuery("ANALYZE;")

	if(DetectDatabaseCorruption())
		world.log << "\[SQLite Repair\] Database repair successful"
		return TRUE
	else
		world.log << "\[SQLite Repair ERROR\] Database still corrupted"
		return FALSE

// ============================================================================
// TRANSACTION SAFETY
// ============================================================================

proc/WrapInTransaction(op_name)
	if(!sqlite_ready || !op_name)
		return FALSE

	if(!BeginTransaction())
		world.log << "\[Transaction\] Failed to begin [op_name]"
		return FALSE

	world.log << "\[Transaction\] Beginning [op_name]..."
	return TRUE

proc/FinalizeTransaction(op_name, success)
	if(!sqlite_ready)
		return FALSE

	if(!success)
		world.log << "\[Transaction\] [op_name] failed, rolling back"
		RollbackTransaction()
		return FALSE

	if(!CommitTransaction())
		world.log << "\[Transaction\] Failed to commit [op_name]"
		return FALSE

	world.log << "\[Transaction\] [op_name] committed successfully"
	return TRUE

// ============================================================================
// BACKUP & RECOVERY
// ============================================================================

proc/BackupDatabase()
	if(!sqlite_ready || !fexists(sqlite_db_path))
		return FALSE

	var/timestamp = "[world.time]_[world.realtime]"
	var/backup_path = "db/pondera.db.backup.[timestamp].bak"

	if(fcopy(sqlite_db_path, backup_path))
		world.log << "\[Backup\] Created backup: [backup_path]"
		return TRUE
	else
		world.log << "\[Backup ERROR\] Failed to create backup"
		return FALSE

proc/RestoreDatabaseFromBackup(backup_path)
	if(!fexists(backup_path))
		world.log << "\[Restore ERROR\] Backup not found: [backup_path]"
		return FALSE

	if(!fcopy(backup_path, sqlite_db_path))
		world.log << "\[Restore ERROR\] Failed to restore from backup"
		return FALSE

	world.log << "\[Restore\] Restored database from [backup_path]"
	sqlite_ready = FALSE
	return InitializeSQLiteDatabase()

// ============================================================================
// STATISTICS & DIAGNOSTICS
// ============================================================================

proc/GetSQLiteStats()
	if(!sqlite_ready)
		return null

	var/list/stats = list()
	var/file_size = fsize(sqlite_db_path)
	stats["db_file_size"] = file_size

	var/players_count = ExecuteSQLiteQuery("SELECT COUNT(*) FROM players;")
	var/skills_count = ExecuteSQLiteQuery("SELECT COUNT(*) FROM character_skills;")
	var/recipes_count = ExecuteSQLiteQuery("SELECT COUNT(*) FROM character_recipes;")

	stats["total_players"] = text2num(players_count)
	stats["total_skill_records"] = text2num(skills_count)
	stats["total_recipes"] = text2num(recipes_count)
	stats["ready"] = sqlite_ready
	stats["transaction_depth"] = sqlite_transaction_depth
	stats["error_log_size"] = length(sqlite_error_log)

	return stats

proc/LogSQLiteStats()
	var/list/stats = GetSQLiteStats()

	if(!stats)
		world.log << "\[Stats\] Database not ready"
		return

	world.log << "\[SQLite Stats\] Players: [stats["total_players"]] | Skills: [stats["total_skill_records"]] | Recipes: [stats["total_recipes"]] | Size: [stats["db_file_size"]] bytes"

	// Row counts per table
	var/players_count = ExecuteSQLiteQuery("SELECT COUNT(*) FROM players;")
	var/skills_count = ExecuteSQLiteQuery("SELECT COUNT(*) FROM character_skills;")
	var/recipes_count = ExecuteSQLiteQuery("SELECT COUNT(*) FROM character_recipes;")

	stats["total_players"] = text2num(players_count)
	stats["total_skill_records"] = text2num(skills_count)
	stats["total_recipes"] = text2num(recipes_count)

	stats["ready"] = sqlite_ready
	stats["transaction_depth"] = sqlite_transaction_depth
	stats["error_log_size"] = length(sqlite_error_log)

	return stats

// ============================================================================
// END OF SQLITE MIGRATIONS & ERROR RECOVERY
// ============================================================================
