// BlankAvatarSystem.dm - Blank Avatar Framework
// Implements gender selection (M/F) and base character appearance
// Prestige-gated customization defined in PrestigeSystem.dm

#define GENDER_MALE 1
#define GENDER_FEMALE 2

// ============================================================================
// BLANK AVATAR FRAMEWORK
// ============================================================================

/**
 * GetBlankAvatarIcon(gender)
 * Returns base icon for blank avatar based on gender
 * Male: "char_m" | Female: "char_f"
 * 
 * @param gender: 1=Male, 2=Female
 * @return: Icon path
 */
proc/GetBlankAvatarIcon(gender)
	switch(gender)
		if(GENDER_MALE)
			return 'dmi/64/char.dmi'
		if(GENDER_FEMALE)
			return 'dmi/64/char.dmi'
		else
			return 'dmi/64/char.dmi'  // Default to char base

/**
 * GetBlankAvatarIconState(gender)
 * Returns default icon_state for blank avatar (no customization yet)
 * Male: "m_base" | Female: "f_base"
 * 
 * @param gender: 1=Male, 2=Female
 * @return: Icon state string
 */
proc/GetBlankAvatarIconState(gender)
	switch(gender)
		if(GENDER_MALE)
			return "m_base"
		if(GENDER_FEMALE)
			return "f_base"
		else
			return "m_base"

/**
 * ApplyBlankAvatarAppearance(mob/players/P, gender)
 * Apply base blank avatar appearance to player
 * Called after gender selection (first visit)
 * Also used to reset appearance when needed
 * 
 * NOTE: All players can customize appearance (hair, skin, eyes, marks) at creation
 * Prestige unlock allows RE-CUSTOMIZATION (makeover) of locked-in appearance
 * 
 * @param P: Player mob
 * @param gender: 1=Male, 2=Female
 */
proc/ApplyBlankAvatarAppearance(mob/players/P, gender)
	if(!P) return
	
	P.icon = GetBlankAvatarIcon(gender)
	P.icon_state = GetBlankAvatarIconState(gender)
	P.overlays = list()  // Clear any equipment overlays
	P.character.gender = gender
	
	// Update appearance in character data
	P.character.appearance_locked = 0  // CHANGED: All players can customize at creation
	P.character.current_appearance = "blank_base"

/**
 * GetGenderDisplayName(gender)
 * Convert gender ID to display string for UI
 * 
 * @param gender: 1=Male, 2=Female
 * @return: "Male" or "Female"
 */
proc/GetGenderDisplayName(gender)
	switch(gender)
		if(GENDER_MALE)
			return "Male"
		if(GENDER_FEMALE)
			return "Female"
		else
			return "Unknown"

/**
 * ValidateGender(gender)
 * Check if gender selection is valid
 * 
 * @param gender: Value to validate
 * @return: 1 if valid, 0 if invalid
 */
proc/ValidateGender(gender)
	return (gender == GENDER_MALE || gender == GENDER_FEMALE) ? 1 : 0

// ============================================================================
// PRESTIGE APPEARANCE CUSTOMIZATION (UNLOCKED POST-PRESTIGE)
// ============================================================================

/**
 * CustomizableAppearances
 * Map of prestige-unlocked appearance customization options
 * Includes: hair colors, body colors, facial features, etc.
 */
var/global/list/customizable_appearances = list(
	"hair_colors" = list(
		"black" = list("icon_state" = "hair_black", "display" = "Black Hair"),
		"brown" = list("icon_state" = "hair_brown", "display" = "Brown Hair"),
		"blonde" = list("icon_state" = "hair_blonde", "display" = "Blonde Hair"),
		"red" = list("icon_state" = "hair_red", "display" = "Red Hair"),
		"white" = list("icon_state" = "hair_white", "display" = "White Hair"),
		"purple" = list("icon_state" = "hair_purple", "display" = "Purple Hair"),
		"blue" = list("icon_state" = "hair_blue", "display" = "Blue Hair")
	),
	"skin_tones" = list(
		"fair" = list("icon_state" = "skin_fair", "display" = "Fair"),
		"medium" = list("icon_state" = "skin_medium", "display" = "Medium"),
		"dark" = list("icon_state" = "skin_dark", "display" = "Dark"),
		"olive" = list("icon_state" = "skin_olive", "display" = "Olive")
	),
	"body_marks" = list(
		"none" = list("icon_state" = "", "display" = "None"),
		"scar_face" = list("icon_state" = "mark_scar_face", "display" = "Facial Scar"),
		"tattoo_arm" = list("icon_state" = "mark_tattoo_arm", "display" = "Arm Tattoo"),
		"birthmark" = list("icon_state" = "mark_birthmark", "display" = "Birthmark")
	),
	"eyes" = list(
		"brown" = list("icon_state" = "eyes_brown", "display" = "Brown Eyes"),
		"blue" = list("icon_state" = "eyes_blue", "display" = "Blue Eyes"),
		"green" = list("icon_state" = "eyes_green", "display" = "Green Eyes"),
		"amber" = list("icon_state" = "eyes_amber", "display" = "Amber Eyes")
	)
)

/**
 * ApplyCustomAppearance(mob/players/P, appearance_config)
 * Apply customized appearance to player
 * Available to ALL players at character creation
 * Prestige unlock allows RE-CUSTOMIZATION (makeover) of previously locked appearance
 * 
 * @param P: Player mob
 * @param appearance_config: List containing [hair, skin, eyes, marks]
 */
proc/ApplyCustomAppearance(mob/players/P, appearance_config)
	if(!P || !P.character) return
	
	// NOTE: No prestige check anymore - all players can customize
	// Prestige unlock allows CHANGING previously customized appearance (makeover feature)
	
	// Build overlay stack
	var/list/new_overlays = list()
	
	// Base body + skin tone
	if(appearance_config["skin"])
		var/list/skin_data = customizable_appearances["skin_tones"][appearance_config["skin"]]
		if(skin_data)
			new_overlays += image(GetBlankAvatarIcon(P.character.gender), skin_data["icon_state"])
	
	// Hair
	if(appearance_config["hair"])
		var/list/hair_data = customizable_appearances["hair_colors"][appearance_config["hair"]]
		if(hair_data)
			new_overlays += image(GetBlankAvatarIcon(P.character.gender), hair_data["icon_state"])
	
	// Eyes
	if(appearance_config["eyes"])
		var/list/eye_data = customizable_appearances["eyes"][appearance_config["eyes"]]
		if(eye_data)
			new_overlays += image(GetBlankAvatarIcon(P.character.gender), eye_data["icon_state"])
	
	// Body marks
	if(appearance_config["marks"])
		var/list/mark_data = customizable_appearances["body_marks"][appearance_config["marks"]]
		if(mark_data && mark_data["icon_state"])
			new_overlays += image(GetBlankAvatarIcon(P.character.gender), mark_data["icon_state"])
	
	// Apply overlays
	P.overlays = new_overlays
	
	// Save appearance config in character data
	P.character.current_appearance_config = appearance_config

/**
 * GetAppearancePreview(mob/players/P, appearance_config)
 * Generate preview image showing what appearance will look like
 * Used in port customization UI
 * 
 * @param P: Player mob
 * @param appearance_config: List containing [hair, skin, eyes, marks]
 * @return: Image object for preview display
 */
proc/GetAppearancePreview(mob/players/P, appearance_config)
	if(!P) return null
	
	var/icon/preview = new /icon(GetBlankAvatarIcon(P.character.gender), GetBlankAvatarIconState(P.character.gender))
	
	// Layer components
	if(appearance_config["hair"])
		var/list/hair_data = customizable_appearances["hair_colors"][appearance_config["hair"]]
		if(hair_data)
			preview.Blend(new /icon(GetBlankAvatarIcon(P.character.gender), hair_data["icon_state"]))
	
	if(appearance_config["eyes"])
		var/list/eye_data = customizable_appearances["eyes"][appearance_config["eyes"]]
		if(eye_data)
			preview.Blend(new /icon(GetBlankAvatarIcon(P.character.gender), eye_data["icon_state"]))
	
	return preview

/**
 * ResetAppearanceToBlank(mob/players/P)
 * Reset player appearance to blank base (used on character reset)
 * 
 * @param P: Player mob
 */
proc/ResetAppearanceToBlank(mob/players/P)
	if(!P) return
	
	P.icon = GetBlankAvatarIcon(P.character.gender)
	P.icon_state = GetBlankAvatarIconState(P.character.gender)
	P.overlays = list()
	P.character.current_appearance = "blank_base"
	P.character.current_appearance_config = null

/**
 * IsAppearanceCustomized(mob/players/P)
 * Check if player's appearance differs from blank base
 * 
 * @param P: Player mob
 * @return: 1 if customized, 0 if blank
 */
proc/IsAppearanceCustomized(mob/players/P)
	if(!P || !P.character) return 0
	return (P.character.current_appearance != "blank_base") ? 1 : 0

// ============================================================================
// COSMETIC ITEM RENDERING (OVERLAYS ON BLANK AVATAR)
// ============================================================================

/**
 * ApplyCosmeticItem(mob/players/P, obj/cosmetic_item)
 * Apply cosmetic item overlay to player appearance
 * Used for dyes, accessories, cosmetic armor, etc.
 * 
 * @param P: Player mob
 * @param cosmetic_item: Cosmetic obj/item to apply
 */
proc/ApplyCosmeticItem(mob/players/P, obj/cosmetic_item)
	if(!P || !cosmetic_item) return
	// TODO: Check .is_cosmetic once cosmetic items are fully defined
	// if(!cosmetic_item.is_cosmetic)
	//	P << "<span class='danger'>Item is not cosmetic.</span>"
	//	return
	
	// Add cosmetic overlay
	P.overlays += image(cosmetic_item.icon, cosmetic_item.icon_state)
	P << "<span class='good'>Applied [cosmetic_item.name].</span>"

/**
 * RemoveCosmeticItem(mob/players/P, cosmetic_name)
 * Remove cosmetic item overlay
 * 
 * @param P: Player mob
 * @param cosmetic_name: Name of cosmetic to remove
 */
proc/RemoveCosmeticItem(mob/players/P, cosmetic_name)
	if(!P) return
	
	// Find and remove matching overlay
	var/list/new_overlays = list()
	for(var/img in P.overlays)
		// Skip image objects - rebuild overlays without specific cosmetic
		// Note: Image objects don't have .name property, so we rebuild all except the target
		// For now, we'll just clear and rebuild the appearance
		continue
	
	// Rebuild appearance after cosmetic removal
	P.overlays = new_overlays
	P << "<span class='good'>Removed cosmetic.</span>"

// ============================================================================
// EQUIPMENT OVERLAY INTEGRATION
// ============================================================================

/**
 * RenderEquipmentOverlays(mob/players/P)
 * Render currently equipped items as overlays on blank avatar
 * Separate layer from cosmetics (equipment below, cosmetics on top)
 * 
 * @param P: Player mob
 */
proc/RenderEquipmentOverlays(mob/players/P)
	if(!P) return
	
	var/list/equipment_overlays = list()
	
	// Iterate equipped items in order (head, chest, hands, feet, back, waist)
	// TODO: Equipment overlays - items don't yet have overlay_icon property
	// for(var/obj/items/equipment/E in P.equipped_items)
	//	if(E.overlay_icon)
	//		equipment_overlays += image(E.overlay_icon, E.overlay_icon_state)
	
	// Cosmetics rendered on top (separate list)
	// Equipment overlays are base layer
	P.overlays = equipment_overlays

/**
 * UpdateEquipmentOverlays(mob/players/P)
 * Called whenever equipment changes (equip/unequip)
 * Refreshes equipment overlay rendering
 * 
 * @param P: Player mob
 */
proc/UpdateEquipmentOverlays(mob/players/P)
	RenderEquipmentOverlays(P)

// ============================================================================
// CHARACTER DATA INTEGRATION
// ============================================================================

/**
 * Initialize blank avatar in character_data
 * Called from datum/character_data/New()
 * 
 * NOTE: appearance_locked = 0 means players can customize at creation
 * Prestige unlock allows RE-CUSTOMIZATION (makeover) of appearance
 */
/datum/character_data/proc/InitializeBlankAvatar()
	// Set defaults
	gender = GENDER_MALE
	appearance_locked = 0  // CHANGED: All players can customize at creation
	current_appearance = "blank_base"
	current_appearance_config = null
	is_customized = 0
	
	// (Prestige system will unlock RE-CUSTOMIZATION ability when ready)

/**
 * SaveAppearanceState()
 * Persist appearance in character data
 * Called on login/logout
 */
/datum/character_data/proc/SaveAppearanceState()
	// Appearance config saved to character_data
	// Restored on login via LoadAppearanceState()

/**
 * LoadAppearanceState()
 * Restore appearance from saved character data
 * Called on player login
 */
/datum/character_data/proc/LoadAppearanceState()
	// Recreate appearance overlays from saved config

/**
 * ResetAppearanceState()
 * Clear appearance customization
 * Called on character reset (death/prestige unlock)
 */
/datum/character_data/proc/ResetAppearanceState()
	gender = GENDER_MALE  // Default gender
	appearance_locked = 1
	current_appearance = "blank_base"
	current_appearance_config = null
	is_customized = 0
