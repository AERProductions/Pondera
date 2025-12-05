// EquipmentOverlayIntegration.dm
// CURRENTLY DISABLED - Awaiting weapon overlay DMI asset creation
//
// This file contains:
// 1. Helper procedures to map equipment items to overlays
// 2. Instructions for integrating into tools.dm's Equip/Unequip verbs
//
// When weapon overlay DMI files are created (LSoy.dmi, WHoy.dmi, GMoy.dmi, PXoy.dmi, axeoy.dmi, SKoy.dmi),
// this file can be enabled and tools.dm modified to call the integration functions.
//
// See EQUIPMENT_OVERLAY_SYSTEM.md for full documentation.

/*

INTEGRATION INSTRUCTIONS:
=========================

Step 1: Create weapon overlay DMI files
Required files in /dmi/:
- LSoy.dmi (8 frames: LS1-LS8 for Long Sword)
- WHoy.dmi (8 frames: WH1-WH8 for War Hammer)
- GMoy.dmi (8 frames: GM1-GM8 for Great Mace)
- PXoy.dmi (8 frames: PX1-PX8 for Pickaxe)
- axeoy.dmi (8 frames: AX1-AX8 for Axe)
- SKoy.dmi (8 frames: SK1-SK8 for Scythe)

Step 2: Uncomment this file in Pondera.dme
Find the line:
  //#include "dm\EquipmentOverlayIntegration.dm"
And change to:
  #include "dm\EquipmentOverlayIntegration.dm"

Step 3: Modify tools.dm Equip() verb
After setting src.suffix = "Equipped" (around line 240-260 area), add:
  
  // Apply equipment visual overlay
  if(src.suffix == "Equipped" || src.suffix == "Dual Wield")
      var/mob/players/M = usr
      if(ismob(M) && M)
          M.apply_equipment_overlay(src)

Step 4: Modify tools.dm Unequip() verb
After clearing src.suffix = "" (around line 1670-1750 area), add:

  // Remove equipment visual overlay
  if(src.suffix == "")
      var/mob/players/M = usr
      if(ismob(M) && M)
          M.remove_equipment_overlay(src)

Step 5: Build and test
Run the build task and test equipping/unequipping weapons to verify overlays appear/disappear correctly.

*/

mob
	// Helper proc to apply equipment overlay based on item typi code
	// Call this from tools.dm Equip() verb after setting suffix = "Equipped"
	proc/apply_equipment_overlay(obj/items/tools/item)
		if(!item || !ismob(src)) return
		
		// Determine which overlay type and properties to use based on item typi
		var/icon_state_base = null
		var/dmi_file = null
		
		// Map typi codes to overlay properties (matches tools.dm equipment system)
		if(item.typi == "LS")	// LongSword
			icon_state_base = "LS"
			dmi_file = 'dmi/LSoy.dmi'
		else if(item.typi == "WH")	// WarHammer
			icon_state_base = "WH"
			dmi_file = 'dmi/WHoy.dmi'
		else if(item.typi == "GM")	// GreatMace
			icon_state_base = "GM"
			dmi_file = 'dmi/GMoy.dmi'
		else if(item.typi == "PX")	// Pickaxe
			icon_state_base = "PX"
			dmi_file = 'dmi/PXoy.dmi'
		else if(item.typi == "AX")	// Axe
			icon_state_base = "AX"
			dmi_file = 'dmi/axeoy.dmi'
		else if(item.typi == "SK")	// Scythe
			icon_state_base = "SK"
			dmi_file = 'dmi/SKoy.dmi'
		
		// Apply the overlay if we found a mapping
		if(icon_state_base && dmi_file)
			// Convert direction to number (1=N, 2=S, 3=E, 4=W, 5=NE, 6=NW, 7=SE, 8=SW)
			var/dir_num = 1
			if(src.dir == SOUTH) dir_num = 2
			else if(src.dir == EAST) dir_num = 3
			else if(src.dir == WEST) dir_num = 4
			else if(src.dir == NORTHEAST) dir_num = 5
			else if(src.dir == NORTHWEST) dir_num = 6
			else if(src.dir == SOUTHEAST) dir_num = 7
			else if(src.dir == SOUTHWEST) dir_num = 8
			
			var/icon_state = "[icon_state_base][dir_num]"
			var/image/overlay_img = image(dmi_file, icon_state = icon_state)
			src.overlays += overlay_img
			
			// Store overlay reference for later removal
			if(!src.equipped_overlays)
				src.equipped_overlays = list()
			src.equipped_overlays[item.typi] = overlay_img

	// Helper proc to remove equipment overlay when item is unequipped
	// Call this from tools.dm Unequip() verb after clearing the item state
	proc/remove_equipment_overlay(obj/items/tools/item)
		if(!item || !ismob(src)) return
		if(!src.equipped_overlays) return
		
		// Remove the stored overlay for this item type
		var/image/old_overlay = src.equipped_overlays[item.typi]
		if(old_overlay)
			src.overlays -= old_overlay
			src.equipped_overlays -= item.typi

	// Refresh overlays when direction changes (called from Bump override in EquipmentOverlaySystem)
	proc/refresh_equipment_overlays()
		if(!src.equipped_overlays || !src.equipped_overlays.len) return
		
		// Get current direction number
		var/dir_num = 1
		if(src.dir == SOUTH) dir_num = 2
		else if(src.dir == EAST) dir_num = 3
		else if(src.dir == WEST) dir_num = 4
		else if(src.dir == NORTHEAST) dir_num = 5
		else if(src.dir == NORTHWEST) dir_num = 6
		else if(src.dir == SOUTHEAST) dir_num = 7
		else if(src.dir == SOUTHWEST) dir_num = 8
		
		// Update each overlay with new direction
		for(var/slot in src.equipped_overlays)
			var/image/old_img = src.equipped_overlays[slot]
			if(old_img)
				// Determine DMI file from slot
				var/dmi_file = null
				if(slot == "LS") dmi_file = 'dmi/LSoy.dmi'
				else if(slot == "WH") dmi_file = 'dmi/WHoy.dmi'
				else if(slot == "GM") dmi_file = 'dmi/GMoy.dmi'
				else if(slot == "PX") dmi_file = 'dmi/PXoy.dmi'
				else if(slot == "AX") dmi_file = 'dmi/axeoy.dmi'
				else if(slot == "SK") dmi_file = 'dmi/SKoy.dmi'
				
				if(dmi_file)
					var/new_state = "[slot][dir_num]"
					src.overlays -= old_img
					var/image/new_img = image(dmi_file, icon_state = new_state)
					src.overlays += new_img
					src.equipped_overlays[slot] = new_img
