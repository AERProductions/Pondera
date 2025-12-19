// dm/SQLiteUtils.dm
// SQLite Utility Functions - Sanitization, JSON parsing, and helpers
// Version: 1.0
// Date: 2025-12-17

// ============================================================================
// STRING SANITIZATION
// ============================================================================

/**
 * EscapeSQLString(text)
 * Escape single quotes in SQL strings to prevent injection
 * 
 * SQL Safe: "Robert"; DROP..." → "Robert''; DROP..."
 * 
 * @param text - Input string (can be empty)
 * @return - SQL-escaped string
 */
proc/EscapeSQLString(text)
	if(!text)
		return ""
	
	// SQL injection prevention: single quote → two single quotes
	var/escaped = replacetext(text, "'", "''")
	return escaped

/**
 * ValidateCharacterName(name)
 * Validate character name length and content
 * 
 * @param name - Character name
 * @return - TRUE if valid, FALSE otherwise
 */
proc/ValidateCharacterName(name)
	if(!name || length(name) == 0)
		return FALSE
	
	if(length(name) > 32)
		return FALSE
	
	// Allow alphanumeric, spaces, hyphens, apostrophes only
	if(!istext(name))
		return FALSE
	
	return TRUE

/**
 * SanitizeText(text, max_length = 255)
 * General-purpose text sanitization
 * 
 * @param text - Text to sanitize
 * @param max_length - Maximum allowed length
 * @return - Sanitized text
 */
proc/SanitizeText(text, max_length = 255)
	if(!text)
		return ""
	
	text = copytext(text, 1, max_length + 1)
	return text

// ============================================================================
// JSON PARSING
// ============================================================================

/**
 * ParseSQLiteJSONResult(json_text)
 * Parse JSON output from SQLite queries
 * 
 * Input format: [{"id": 1, "name": "John", "level": 5}, ...]
 * 
 * @param json_text - Raw JSON from SQLite
 * @return - List of dictionaries, or empty list if parse fails
 */
proc/ParseSQLiteJSONResult(json_text)
	if(!json_text || length(json_text) == 0)
		return list()
	
	try
		// Try built-in json_decode first
		var/result = json_decode(json_text)
		if(islist(result))
			return result
		return list()
	catch(var/exception/e)
		world.log << "\[SQLite JSON\] Parse error: [e.name] - [e.desc]"
		return list()

/**
 * ExtractJSONField(json_obj, field_name, default_value)
 * Safely extract field from JSON object
 * 
 * @param json_obj - Dictionary from parsed JSON
 * @param field_name - Field to extract
 * @param default_value - Value if field missing
 * @return - Field value or default
 */
proc/ExtractJSONField(json_obj, field_name, default_value = null)
	if(!islist(json_obj) || !field_name)
		return default_value
	
	if(field_name in json_obj)
		return json_obj[field_name]
	
	return default_value

/**
 * ParsePlayerFromJSON(json_dict)
 * Convert single player JSON row to character dict
 * 
 * @param json_dict - Single row from players table
 * @return - Character data dictionary
 */
proc/ParsePlayerFromJSON(json_dict)
	if(!islist(json_dict))
		return null
	
	var/list/char_data = list(
		"player_id" = ExtractJSONField(json_dict, "id", 0),
		"char_name" = ExtractJSONField(json_dict, "char_name", "Unknown"),
		"game_mode" = ExtractJSONField(json_dict, "game_mode", "story"),
		"current_continent" = ExtractJSONField(json_dict, "current_continent", "story"),
		"level" = ExtractJSONField(json_dict, "level", 1),
		"death_count" = ExtractJSONField(json_dict, "death_count", 0),
		"last_login" = ExtractJSONField(json_dict, "last_login", null)
	)
	
	return char_data

/**
 * ParseSkillsFromJSON(json_array)
 * Convert skill rows from JSON to skill dictionary
 * 
 * @param json_array - Array of skill rows
 * @return - Dictionary keyed by skill name
 */
proc/ParseSkillsFromJSON(json_array)
	var/list/skills = list()
	
	if(!islist(json_array))
		return skills
	
	for(var/json_row in json_array)
		if(!islist(json_row))
			continue
		
		var/skill_name = ExtractJSONField(json_row, "skill_name", null)
		if(!skill_name)
			continue
		
		skills[skill_name] = list(
			"rank_level" = ExtractJSONField(json_row, "rank_level", 0),
			"current_exp" = ExtractJSONField(json_row, "current_exp", 0),
			"max_exp_threshold" = ExtractJSONField(json_row, "max_exp_threshold", 100)
		)
	
	return skills

/**
 * ParseCurrencyFromJSON(json_dict)
 * Convert currency row from JSON to currency dict
 * 
 * @param json_dict - Single currency row
 * @return - Currency data dictionary
 */
proc/ParseCurrencyFromJSON(json_dict)
	if(!islist(json_dict))
		return list("lucre" = 0, "stone" = 0, "metal" = 0, "timber" = 0)
	
	var/list/currency = list(
		"lucre" = ExtractJSONField(json_dict, "lucre", 0),
		"banked_lucre" = ExtractJSONField(json_dict, "banked_lucre", 0),
		"stone" = ExtractJSONField(json_dict, "stone", 0),
		"metal" = ExtractJSONField(json_dict, "metal", 0),
		"timber" = ExtractJSONField(json_dict, "timber", 0)
	)
	
	return currency

/**
 * ParseAppearanceFromJSON(json_dict)
 * Convert appearance row from JSON
 * 
 * @param json_dict - Single appearance row
 * @return - Appearance data dictionary
 */
proc/ParseAppearanceFromJSON(json_dict)
	if(!islist(json_dict))
		return list("gender" = "M", "is_locked" = FALSE)
	
	var/list/appearance = list(
		"gender" = ExtractJSONField(json_dict, "gender", "M"),
		"is_locked" = ExtractJSONField(json_dict, "is_locked", FALSE)
	)
	
	return appearance

/**
 * ParsePositionsFromJSON(json_array)
 * Convert continent positions from JSON
 * 
 * @param json_array - Array of position rows
 * @return - Dictionary keyed by continent
 */
proc/ParsePositionsFromJSON(json_array)
	var/list/positions = list()
	
	if(!islist(json_array))
		return positions
	
	for(var/json_row in json_array)
		if(!islist(json_row))
			continue
		
		var/continent = ExtractJSONField(json_row, "continent", null)
		if(!continent)
			continue
		
		positions[continent] = list(
			ExtractJSONField(json_row, "x", 1),
			ExtractJSONField(json_row, "y", 1),
			ExtractJSONField(json_row, "z", 1),
			ExtractJSONField(json_row, "dir", SOUTH)
		)
	
	return positions

// ============================================================================
// QUERY BUILDERS (Safe - uses parameterization where possible)
// ============================================================================

/**
 * BuildInsertPlayerQuery(ckey, char_name, game_mode, continent)
 * Build INSERT query with proper escaping
 * 
 * @param ckey - Player key
 * @param char_name - Character name
 * @param game_mode - Game mode (story/sandbox/pvp)
 * @param continent - Current continent
 * @return - SQL INSERT statement
 */
proc/BuildInsertPlayerQuery(ckey, char_name, game_mode, continent)
	var/safe_ckey = EscapeSQLString(ckey)
	var/safe_name = EscapeSQLString(char_name)
	var/safe_mode = EscapeSQLString(game_mode)
	var/safe_continent = EscapeSQLString(continent)
	
	return "INSERT OR REPLACE INTO players (ckey, char_name, game_mode, current_continent, last_logout, online_status) VALUES ('[safe_ckey]', '[safe_name]', '[safe_mode]', '[safe_continent]', datetime('now'), 0);"

/**
 * BuildInsertSkillQuery(player_id, skill_name, rank_level, current_exp, max_exp)
 * Build INSERT query for skill data
 * 
 * @param player_id - Player database ID
 * @param skill_name - Skill identifier
 * @param rank_level - Current rank (0-5)
 * @param current_exp - Current experience points
 * @param max_exp - Experience needed for next level
 * @return - SQL INSERT statement
 */
proc/BuildInsertSkillQuery(player_id, skill_name, rank_level, current_exp, max_exp)
	var/safe_skill = EscapeSQLString(skill_name)
	return "INSERT INTO character_skills (player_id, skill_name, rank_level, current_exp, max_exp_threshold) VALUES ([player_id], '[safe_skill]', [rank_level], [current_exp], [max_exp]);"

/**
 * BuildInsertCurrencyQuery(player_id, lucre, banked_lucre, stone, metal, timber)
 * Build INSERT query for currency data
 */
proc/BuildInsertCurrencyQuery(player_id, lucre, banked_lucre, stone, metal, timber)
	return "INSERT OR REPLACE INTO currency_accounts (player_id, lucre, banked_lucre, stone, metal, timber) VALUES ([player_id], [lucre || 0], [banked_lucre || 0], [stone || 0], [metal || 0], [timber || 0]);"

/**
 * BuildInsertAppearanceQuery(player_id, gender, is_locked)
 * Build INSERT query for appearance data
 */
proc/BuildInsertAppearanceQuery(player_id, gender, is_locked)
	var/safe_gender = EscapeSQLString(gender)
	return "INSERT OR REPLACE INTO character_appearance (player_id, gender, is_locked) VALUES ([player_id], '[safe_gender]', [is_locked ? 1 : 0]);"

/**
 * BuildInsertPositionQuery(player_id, continent, x, y, z, dir)
 * Build INSERT query for continent position
 */
proc/BuildInsertPositionQuery(player_id, continent, x, y, z, dir)
	var/safe_continent = EscapeSQLString(continent)
	return "INSERT INTO continent_positions (player_id, continent, x, y, z, dir) VALUES ([player_id], '[safe_continent]', [x], [y], [z], [dir]);"

// ============================================================================
// END OF SQLITE UTILS
// ============================================================================
