// PortHubPersistenceSystem.dm - Persistent Storage for Port Hub Customization & Lockers
// Saves/loads character appearance customization and per-continent port lockers
// Integrates with CharacterData.dm and PortHubSystem.dm

// ============================================================================
// GLOBAL PORT LOCKER REGISTRY
// ============================================================================

var/global/list/global_port_lockers = list()  // Stores all port lockers: "[ckey]_[continent]" = port_locker datum

// ============================================================================
// APPEARANCE DATA STRUCTURE (saves to CharacterData)
// ============================================================================

/datum/appearance_data
	var
		hair_color = ""      // "blonde", "brown", "red", "black", "white", etc.
		skin_tone = ""       // "pale", "light", "medium", "dark", "green", "blue", etc.
		eye_color = ""       // "blue", "green", "brown", "yellow", "purple", etc.
		body_marks = list()  // Tattoos, scars, birthmarks: list of mark descriptions
		gender = "M"         // "M" or "F"
	
	proc/ToList()
		/**
		 * Convert appearance data to list for savefile serialization
		 */
		return list(
			"hair_color" = hair_color,
			"skin_tone" = skin_tone,
			"eye_color" = eye_color,
			"body_marks" = body_marks,
			"gender" = gender
		)
	
	proc/FromList(list/data)
		/**
		 * Load appearance data from list
		 */
		if(!data) return
		
		hair_color = data["hair_color"] || ""
		skin_tone = data["skin_tone"] || ""
		eye_color = data["eye_color"] || ""
		body_marks = data["body_marks"] || list()
		gender = data["gender"] || "M"

// ============================================================================
// PORT LOCKER PERSISTENCE PROCS (No duplicates - PortHubSystem procs are stubs)
// ============================================================================

/**
 * InitializePortLockers()
 * Load all port lockers from savefiles on world start
 * Called from InitializationManager.dm
 */
proc/InitializePortLockers()
	// Port lockers stored in PortLocker_[ckey]_[continent].sav files
	// Loaded on demand (lazy loading) when player travels
	global_port_lockers = list()

/**
 * getPortLocker(ckey, continent)
 * Retrieve player's port locker for a specific continent
 * Loads from savefile if not already in memory
 * IMPLEMENTATION for PortHubSystem.dm stub (renamed with lowercase 'get')
 * 
 * @param ckey: Player's character key
 * @param continent: Continent name ("story", "sandbox", "kingdom")
 * @return: port_locker datum or null
 */
proc/getPortLocker(ckey, continent)
	if(!ckey || !continent) return null
	
	var/locker_key = "[ckey]_[continent]"
	
	// Check if already loaded in global registry
	if(locker_key in global_port_lockers)
		return global_port_lockers[locker_key]
	
	// Try to load from savefile
	var/datum/port_locker/locker = LoadPortLockerFromFile(ckey, continent)
	if(locker)
		global_port_lockers[locker_key] = locker
		return locker
	
	// Create new empty locker
	locker = new /datum/port_locker()
	locker.owner_ckey = ckey
	locker.continent = continent
	global_port_lockers[locker_key] = locker
	
	return locker

/**
 * setPortLocker(ckey, continent, datum/port_locker/locker)
 * Save player's port locker to memory and file
 * IMPLEMENTATION for PortHubSystem.dm stub (renamed with lowercase 'set')
 * 
 * @param ckey: Player's character key
 * @param continent: Continent name
 * @param locker: port_locker datum to save
 */
proc/setPortLocker(ckey, continent, datum/port_locker/locker)
	if(!ckey || !continent || !locker) return
	
	var/locker_key = "[ckey]_[continent]"
	global_port_lockers[locker_key] = locker
	
	// Save to file asynchronously
	SavePortLockerToFile(locker)

/**
 * LoadPortLockerFromFile(ckey, continent)
 * Load port locker from savefile
 * File: MapSaves/PortLocker_[ckey]_[continent].sav
 * 
 * @param ckey: Player's character key
 * @param continent: Continent name
 * @return: port_locker datum or null
 */
proc/LoadPortLockerFromFile(ckey, continent)
	var/path = "MapSaves/PortLocker_[ckey]_[continent].sav"
	
	// Check if file exists
	if(!fexists(path))
		return null
	
	var/savefile/S = new(path)
	if(!S)
		world.log << "ERROR: Could not open port locker savefile: [path]"
		return null
	
	var/datum/port_locker/locker = new()
	
	// Read locker data
	S["locker"] >> locker
	
	if(!locker)
		world.log << "WARNING: Port locker savefile corrupted: [path]"
		return null
	
	return locker

/**
 * SavePortLockerToFile(datum/port_locker/locker)
 * Save port locker to savefile asynchronously
 * File: MapSaves/PortLocker_[ckey]_[continent].sav
 * 
 * @param locker: port_locker datum to save
 */
proc/SavePortLockerToFile(datum/port_locker/locker)
	spawn(0)  // Async save
		if(!locker || !locker.owner_ckey || !locker.continent)
			return
		
		var/path = "MapSaves/PortLocker_[locker.owner_ckey]_[locker.continent].sav"
		
		var/savefile/S = new(path)
		if(!S)
			world.log << "ERROR: Could not create port locker savefile: [path]"
			return
		
		// Write locker data
		S["locker"] << locker

/**
 * DeletePortLocker(ckey, continent)
 * Delete port locker file and memory entry
 * Called when player deletes character or switches continents
 * 
 * @param ckey: Player's character key
 * @param continent: Continent name
 */
proc/DeletePortLocker(ckey, continent)
	if(!ckey || !continent) return
	
	var/locker_key = "[ckey]_[continent]"
	
	// Remove from memory
	global_port_lockers -= locker_key
	
	// Remove file
	var/path = "MapSaves/PortLocker_[ckey]_[continent].sav"
	if(fexists(path))
		fdel(path)

// ============================================================================
// CHARACTER APPEARANCE PERSISTENCE PROCS
// ============================================================================

/**
 * LoadCharacterAppearance(mob/players/P)
 * Load character appearance from CharacterData savefile
 * Called after character data is loaded
 * 
 * @param P: Player mob
 */
proc/LoadCharacterAppearance(mob/players/P)
	if(!P || !P.character) return
	
	// Appearance data stored in character datum
	if(!P.character.appearance_data)
		// First time: create default appearance
		P.character.appearance_data = new /datum/appearance_data()
		P.character.appearance_data.hair_color = "brown"
		P.character.appearance_data.skin_tone = "light"
		P.character.appearance_data.eye_color = "blue"
		P.character.appearance_data.gender = "M"
	
	// Apply appearance to visual (this is stubbed - integration with BlankAvatarSystem.dm)
	ApplyAppearanceToCharacter(P, P.character.appearance_data)

/**
 * SaveCharacterAppearance(mob/players/P)
 * Save character appearance to CharacterData savefile
 * Called when player modifies appearance
 * 
 * @param P: Player mob
 */
proc/SaveCharacterAppearance(mob/players/P)
	if(!P || !P.character) return
	
	// Appearance is automatically saved with character data
	// in SavingChars.dm player save cycle

/**
 * ApplyAppearanceToCharacter(mob/players/P, datum/appearance_data/appearance)
 * Apply appearance data to character visual
 * Updates hair color, skin tone, eye color, body marks
 * 
 * @param P: Player mob
 * @param appearance: appearance_data datum
 */
proc/ApplyAppearanceToCharacter(mob/players/P, datum/appearance_data/appearance)
	if(!P || !appearance) return
	
	// This is a stub for integration with BlankAvatarSystem.dm
	// Which handles actual visual updates (overlays, colors, etc.)
	
	// TODO: Integrate with BlankAvatarSystem.dm to:
	// - Set hair color overlay
	// - Set skin tone base color
	// - Set eye color overlay
	// - Apply body marks/tattoos
	// - Update icon_state based on gender

/**
 * GetCharacterAppearance(mob/players/P)
 * Get character's appearance data
 * 
 * @param P: Player mob
 * @return: appearance_data datum
 */
proc/GetCharacterAppearance(mob/players/P)
	if(!P || !P.character) return null
	
	if(!P.character.appearance_data)
		P.character.appearance_data = new /datum/appearance_data()
	
	return P.character.appearance_data

// ============================================================================
// CHARACTER APPEARANCE CUSTOMIZATION UI
// ============================================================================

/**
 * BeginAppearanceCustomization(mob/players/P)
 * Start character appearance customization flow
 * Interactive menu-driven experience
 * 
 * @param P: Player mob
 */
proc/BeginAppearanceCustomization(mob/players/P)
	if(!P || !P.character) return
	
	var/datum/appearance_data/appearance = GetCharacterAppearance(P)
	var/customizing = 1
	
	while(customizing)
		P << "\n<b>═══════════════════════════════════════</b>"
		P << "<b>CHARACTER APPEARANCE CUSTOMIZATION</b>"
		P << "<b>═══════════════════════════════════════</b>"
		P << "<span class='info'>Current: [appearance.gender] with [appearance.hair_color] hair, [appearance.skin_tone] skin</span>"
		P << "<span class='info'>[1] Hair Color</span>"
		P << "<span class='info'>[2] Skin Tone</span>"
		P << "<span class='info'>[3] Eye Color</span>"
		P << "<span class='info'>[4] Body Marks (Tattoos)</span>"
		P << "<span class='info'>[5] Change Gender (M/F)</span>"
		P << "<span class='info'>[6] Preview Changes</span>"
		P << "<span class='info'>[7] Apply & Save</span>"
		P << "<span class='info'>[0] Cancel</span>"
		P << "<b>═══════════════════════════════════════</b>"
		
		var/choice = input(P, "Select option:", "Customization") in list("1", "2", "3", "4", "5", "6", "7", "0")
		
		switch(choice)
			if("1")
				CustomizeHairColor(P, appearance)
			if("2")
				CustomizeSkinTone(P, appearance)
			if("3")
				CustomizeEyeColor(P, appearance)
			if("4")
				CustomizeBodyMarks(P, appearance)
			if("5")
				CustomizeGender(P, appearance)
			if("6")
				PreviewAppearance(P, appearance)
			if("7")
				ApplyAppearanceToCharacter(P, appearance)
				SaveCharacterAppearance(P)
				P << "<span class='good'>Appearance saved!</span>"
				customizing = 0
			if("0")
				customizing = 0

/**
 * CustomizeHairColor(mob/players/P, datum/appearance_data/appearance)
 * Select hair color
 */
proc/CustomizeHairColor(mob/players/P, datum/appearance_data/appearance)
	if(!P || !appearance) return
	
	var/colors = list("Blonde", "Brown", "Red", "Black", "White", "Gray", "Auburn", "Platinum")
	var/choice = input(P, "Select hair color:", "Hair") in colors
	
	if(choice)
		appearance.hair_color = lowertext(choice)
		P << "<span class='good'>Hair color set to [choice].</span>"

/**
 * CustomizeSkinTone(mob/players/P, datum/appearance_data/appearance)
 * Select skin tone
 */
proc/CustomizeSkinTone(mob/players/P, datum/appearance_data/appearance)
	if(!P || !appearance) return
	
	var/tones = list("Pale", "Light", "Medium", "Dark", "Olive", "Green", "Blue", "Purple")
	var/choice = input(P, "Select skin tone:", "Skin") in tones
	
	if(choice)
		appearance.skin_tone = lowertext(choice)
		P << "<span class='good'>Skin tone set to [choice].</span>"

/**
 * CustomizeEyeColor(mob/players/P, datum/appearance_data/appearance)
 * Select eye color
 */
proc/CustomizeEyeColor(mob/players/P, datum/appearance_data/appearance)
	if(!P || !appearance) return
	
	var/colors = list("Blue", "Green", "Brown", "Gray", "Amber", "Yellow", "Red", "Purple")
	var/choice = input(P, "Select eye color:", "Eyes") in colors
	
	if(choice)
		appearance.eye_color = lowertext(choice)
		P << "<span class='good'>Eye color set to [choice].</span>"

/**
 * CustomizeBodyMarks(mob/players/P, datum/appearance_data/appearance)
 * Add/remove tattoos and body marks
 */
proc/CustomizeBodyMarks(mob/players/P, datum/appearance_data/appearance)
	if(!P || !appearance) return
	
	var/choice = input(P, "Add a tattoo or scar? (or leave blank to skip):", "Body Marks")
	
	if(choice && choice != "")
		appearance.body_marks += choice
		P << "<span class='good'>Body mark added: [choice]</span>"
		var/marks_str = ""
		if(appearance.body_marks)
			for(var/mark in appearance.body_marks)
				if(marks_str) marks_str += ", "
				marks_str += mark
		if(!marks_str) marks_str = "None"
		P << "<span class='info'>Current marks: [marks_str]</span>"

/**
 * CustomizeGender(mob/players/P, datum/appearance_data/appearance)
 * Select gender
 */
proc/CustomizeGender(mob/players/P, datum/appearance_data/appearance)
	if(!P || !appearance) return
	
	var/choice = input(P, "Select gender:", "Gender") in list("M", "F")
	
	if(choice)
		appearance.gender = choice
		var/gender_name = choice == "M" ? "Male" : "Female"
		P << "<span class='good'>Gender set to [gender_name].</span>"

/**
 * PreviewAppearance(mob/players/P, datum/appearance_data/appearance)
 * Display preview of current appearance configuration
 */
proc/PreviewAppearance(mob/players/P, datum/appearance_data/appearance)
	if(!P || !appearance) return
	
	var/gender_name = appearance.gender == "M" ? "Male" : "Female"
	
	P << "\n<b>═══════════════════════════════════════</b>"
	P << "<b>APPEARANCE PREVIEW</b>"
	P << "<b>═══════════════════════════════════════</b>"
	P << "<span class='info'>Gender: [gender_name]</span>"
	P << "<span class='info'>Hair Color: [appearance.hair_color]</span>"
	P << "<span class='info'>Skin Tone: [appearance.skin_tone]</span>"
	P << "<span class='info'>Eye Color: [appearance.eye_color]</span>"
	
	var/marks_str = ""
	if(appearance.body_marks)
		for(var/mark in appearance.body_marks)
			if(marks_str) marks_str += ", "
			marks_str += mark
	if(!marks_str) marks_str = "None"
	
	if(marks_str != "None")
		P << "<span class='info'>Body Marks: [marks_str]</span>"
	else
		P << "<span class='info'>Body Marks: None</span>"
	
	P << "<b>═══════════════════════════════════════</b>\n"
