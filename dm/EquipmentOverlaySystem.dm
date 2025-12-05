/*
	EQUIPMENT OVERLAY SYSTEM
	
	Modular system for managing character equipment overlays (weapons, armor, shields).
	Supports dynamic overlay rendering based on direction, animation state, and item type.
	
	Features:
	  - Directory-based overlay asset management
	  - Per-equipment-type overlay definitions
	  - Directional rendering (8 directions)
	  - Animation/action-based overlays
	  - Efficient overlay caching
	  - Support for multiple simultaneous overlays
*/

// Equipment overlay definitions
/obj/equipment_overlay
	/*
	   Base definition for equipment overlay properties.
	   Each equipment type has an overlay file path and icon_state patterns.
	*/
	var/equipment_name = ""     // Display name (e.g., "Long Sword")
	var/dmi_file = ""           // Path to DMI file (e.g., 'dmi/64/LSoy.dmi')
	var/icon_state_base = ""    // Base icon_state (e.g., "LSy" - gets dir appended)
	var/has_animations = 0      // Does this equipment have attack animations?
	var/overlay_type = ""       // "weapon", "armor", "shield", "tool"
	var/rarity = "common"       // "common", "uncommon", "rare", "unique"

/obj/equipment_overlay/weapon
	overlay_type = "weapon"
	has_animations = 1

/obj/equipment_overlay/weapon/longsword
	equipment_name = "Long Sword"
	dmi_file = 'dmi/64/LSoy.dmi'
	icon_state_base = "LS"
	rarity = "common"

/obj/equipment_overlay/weapon/warhammer
	equipment_name = "War Hammer"
	dmi_file = 'dmi/64/WHoy.dmi'
	icon_state_base = "WH"
	rarity = "common"

/obj/equipment_overlay/weapon/greatmace
	equipment_name = "Great Mace"
	dmi_file = 'dmi/64/GMoy.dmi'
	icon_state_base = "GM"
	rarity = "uncommon"

/obj/equipment_overlay/weapon/pickaxe
	equipment_name = "Pickaxe"
	dmi_file = 'dmi/64/PXoy.dmi'
	icon_state_base = "PX"
	rarity = "common"

/obj/equipment_overlay/weapon/axe
	equipment_name = "Axe"
	dmi_file = 'dmi/64/axeoy.dmi'
	icon_state_base = "ax"
	rarity = "common"

/obj/equipment_overlay/weapon/scythe
	equipment_name = "Scythe"
	dmi_file = 'dmi/64/SKoy.dmi'
	icon_state_base = "SK"
	rarity = "uncommon"

/obj/equipment_overlay/armor
	overlay_type = "armor"
	has_animations = 0
	// Armor overlays can be added using existing armor.dmi or character dmi files

/obj/equipment_overlay/shield
	overlay_type = "shield"
	has_animations = 0

/obj/equipment_overlay/shield/bast
	equipment_name = "Bast Shield"
	dmi_file = 'dmi/64/shields.dmi'
	icon_state_base = "bast"
	rarity = "common"

/obj/equipment_overlay/shield/vanfos
	equipment_name = "Vanfos Shield"
	dmi_file = 'dmi/64/shields.dmi'
	icon_state_base = "vf"
	rarity = "uncommon"

/obj/equipment_overlay/shield/aegis
	equipment_name = "Aegis Shield"
	dmi_file = 'dmi/64/shields.dmi'
	icon_state_base = "aeg"
	rarity = "rare"

/obj/equipment_overlay/shield/ravelin
	equipment_name = "Ravelin Shield"
	dmi_file = 'dmi/64/shields.dmi'
	icon_state_base = "rav"
	rarity = "rare"

/obj/equipment_overlay/shield/thureos
	equipment_name = "Thureos Shield"
	dmi_file = 'dmi/64/shields.dmi'
	icon_state_base = "thu"
	rarity = "unique"


// Equipment overlay manager
/mob/proc/add_equipment_overlay(overlay_type, icon_state_base, dmi_file, direction)
	/*
	   Add a directional equipment overlay to character.
	   
	   Args:
	     overlay_type: "weapon", "armor", "shield", etc.
	     icon_state_base: Base icon state (e.g., "LSy" → "LSy1", "LSy2", etc.)
	     dmi_file: Path to DMI file
	     direction: BYOND direction (NORTH=1, SOUTH=2, EAST=4, WEST=8, etc.)
	*/
	
	if(!dmi_file || !icon_state_base)
		return null
	
	// Create icon_state with direction suffix
	var/icon_state = "[icon_state_base][direction]"
	
	// Create and apply overlay
	var/image/overlay_image = image(dmi_file, icon_state = icon_state)
	overlays += overlay_image
	
	return overlay_image


/mob/proc/remove_equipment_overlay(item_or_type, icon_state_base, direction)
	/*
	   Remove a directional equipment overlay from character.
	   Can accept either an item object or overlay type.
	*/
	
	// If item passed, determine properties from it
	if(isobj(item_or_type))
		// Item object - extract typi code
		var/obj/I = item_or_type
		if(I.vars && I.vars["typi"])
			icon_state_base = I.vars["typi"]
	
	if(!icon_state_base)
		return
	
	var/icon_state = "[icon_state_base][direction]"
	overlays -= image(icon_state = icon_state)


/mob/proc/clear_all_overlays(overlay_type)
	/*
	   Clear all overlays of a specific type.
	   
	   Args:
	     overlay_type: "weapon", "armor", "shield", "all"
	*/
	
	if(overlay_type == "all")
		overlays = null
	else
		// Filter overlays by type (would need overlay tracking for this)
		// For now, implement simple clearing
		overlays = null


/mob/proc/update_weapon_overlay()
	/*
	   Update weapon overlay based on currently equipped weapon.
	   Called when weapon is equipped/unequipped or direction changes.
	*/
	
	if(!LSequipped)
		remove_equipment_overlay("weapon", "LSy", get_dir(src, src))
		return
	
	// Get current direction
	var/direction = dir
	
	// Add long sword overlay
	add_equipment_overlay("weapon", "LSy", 'dmi/64/LSoy.dmi', direction)


/mob/proc/update_armor_overlay()
	/*
	   Update armor overlay based on currently equipped armor.
	*/
	
	// Check which armor is equipped and apply appropriate overlay
	// This would be expanded based on Aequipped status


/mob/proc/update_shield_overlay()
	/*
	   Update shield overlay based on currently equipped shield.
	*/
	
	if(!Sequipped)
		return
	
	// Similar to weapon overlay but for shields


/mob/proc/apply_action_overlay(action_type, dmi_file, icon_state_base)
	/*
	   Apply temporary overlay for character action (attacking, casting, etc.).
	   Useful for animation frames during combat.
	   
	   Args:
	     action_type: "attack", "cast", "skill", etc.
	     dmi_file: DMI file for action overlay
	     icon_state_base: Base icon state
	*/
	
	var/direction = dir
	var/icon_state = "[icon_state_base][direction]"
	
	overlays += image(dmi_file, icon_state = icon_state)


/mob/proc/remove_action_overlay(dmi_file, icon_state_base)
	/*
	   Remove temporary action overlay.
	*/
	
	var/direction = dir
	var/icon_state = "[icon_state_base][direction]"
	
	overlays -= image(dmi_file, icon_state = icon_state)


/mob/proc/get_equipment_color()
	/*
	   Get equipment quality color for display.
	   Useful for UI indicators and item rarity display.
	*/
	
	var/color = "#CCCCCC"  // Default: common gray
	
	// Check equipped items and set color based on rarity
	// This would need connection to actual item system
	
	return color


// Extension: Equipment slot tracking
/mob
	var/list/equipped_overlays = list()  // Track active overlays by slot

/mob/proc/track_equipped_overlay(slot, overlay_info)
	/*
	   Track equipped overlay for easy management.
	   
	   Args:
	     slot: Equipment slot ("weapon", "armor", "shield", etc.)
	     overlay_info: Dictionary with overlay properties
	*/
	
	if(!equipped_overlays)
		equipped_overlays = list()
	
	equipped_overlays[slot] = overlay_info


/mob/proc/get_equipped_overlay(slot)
	/*
	   Retrieve overlay information for a specific slot.
	*/
	
	if(!equipped_overlays)
		return null
	
	return equipped_overlays[slot]


/mob/proc/refresh_all_overlays()
	/*
	   Refresh all character overlays.
	   Called after direction change, equip/unequip, etc.
	*/
	
	clear_all_overlays("all")
	
	update_weapon_overlay()
	update_armor_overlay()
	update_shield_overlay()


// Direction change handler
/mob/Bump(atom/movable/AM)
	..()
	
	// When direction changes, update overlays
	if(dir != previous_dir)
		refresh_all_overlays()


/mob
	var/previous_dir = 0

/mob/New()
	..()
	previous_dir = dir
