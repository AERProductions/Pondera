/**
 * SAVEFILE VERSIONING SYSTEM
 * Prevents silent corruption from schema changes between builds
 * 
 * Strategy:
 * - Each savefile contains a version stamp
 * - On load, version is checked against current build version
 * - If mismatch, migration/validation procedures run
 * - If incompatible, player notified with recovery options
 */

#define SAVEFILE_VERSION 2  // Increment when schema changes
#define SAVEFILE_VERSION_MIN 1  // Minimum compatible version

// Global version tracking
var/global/current_savefile_version = SAVEFILE_VERSION

/**
 * Get the current savefile version
 * Allows code to query what version is active
 */
proc/GetSavefileVersion()
	return current_savefile_version

/**
 * Check if a savefile version is compatible
 * Returns: TRUE if compatible, FALSE if migration needed
 */
proc/IsSavefileVersionCompatible(version)
	if(version >= SAVEFILE_VERSION_MIN && version <= SAVEFILE_VERSION)
		return TRUE
	return FALSE

/**
 * Write savefile version header
 * Called during every character save to stamp the file
 */
proc/WriteSavefileVersion(savefile/F)
	if(!F) return FALSE
	
	// Write version marker at root
	F["__savefile_version"] << SAVEFILE_VERSION
	world.log << "\[SAVE\] Wrote savefile version [SAVEFILE_VERSION]"
	return TRUE

/**
 * Read and validate savefile version
 * Called during character load to check compatibility
 * 
 * Returns: version number if valid, 0 if incompatible, FALSE if missing
 */
proc/ValidateSavefileVersion(savefile/F)
	if(!F) return FALSE
	
	var/version = null
	F["__savefile_version"] >> version
	
	if(version == null)
		world.log << "\[LOAD\] WARNING: Savefile missing version marker (assume legacy v1)"
		return 1  // Assume legacy version 1
	
	if(!IsSavefileVersionCompatible(version))
		world.log << "\[LOAD\] ERROR: Savefile v[version] incompatible with current v[SAVEFILE_VERSION]"
		world.log << "\[LOAD\] Minimum required version: [SAVEFILE_VERSION_MIN]"
		return 0  // Incompatible
	
	if(version < SAVEFILE_VERSION)
		world.log << "\[LOAD\] Savefile v[version] needs migration to v[SAVEFILE_VERSION]"
		return version  // Compatible but needs migration
	
	world.log << "\[LOAD\] Savefile v[version] is current"
	return version  // Current version

/**
 * Migrate savefile from old version to new
 * Add migration cases as schema changes occur
 */
proc/MigrateSavefileVersion(savefile/F, from_version, to_version)
	if(!F || from_version >= to_version) return FALSE
	
	world.log << "\[MIGRATE\] Starting savefile migration v[from_version] → v[to_version]"
	
	switch(from_version)
		if(1)
			// v1 → v2 migrations
			world.log << "\[MIGRATE\] v1→v2: Adding new fields with defaults"
			
			// Example: If new fields added in v2, set safe defaults
			// F["new_field"] << default_value
			
			if(to_version == 2)
				WriteSavefileVersion(F)
				world.log << "\[MIGRATE\] v1→v2 complete"
				return TRUE
	
	return FALSE

/**
 * Create migration report for problematic savefiles
 * Helps admins troubleshoot version issues
 */
proc/CreateSavefileMigrationReport(player_name, from_version, to_version)
	var/report = "Savefile Migration Report\n"
	report += "Player: [player_name]\n"
	report += "Date: [time2text(world.timeofday, "MMM DD, YYYY HH:mm")]\n"
	report += "From Version: [from_version]\n"
	report += "To Version: [to_version]\n"
	report += "Status: [IsSavefileVersionCompatible(from_version) ? "OK" : "INCOMPATIBLE"]\n"
	
	world.log << report
	return report
