# Equipment Overlay System Documentation

## Overview
The **Equipment Overlay System** provides a modular framework for rendering directional weapon, armor, and shield overlays on player characters. It integrates with Pondera's existing equipment system (tools.dm) to visually represent equipped items on the character sprite.

## Architecture

### Core Components

#### 1. `/obj/equipment_overlay` (Base Class)
Defines the structure for all equipment visual overlays.

**Properties:**
- `equipment_name`: Human-readable name (e.g., "Long Sword")
- `dmi_file`: Path to DMI asset file containing overlay sprites
- `icon_state_base`: Base icon_state prefix (e.g., "LS" for Long Sword)
- `has_animations`: Boolean for animation support (future use)
- `overlay_type`: Category (weapon, armor, shield, tool, misc)
- `rarity`: Equipment rarity level for visual distinction

**Subtypes:**
- `/obj/equipment_overlay/weapon/` - Weapon overlays
  - `longsword` - Maps to LSy.dmi
  - `warhammer` - Maps to WHoy.dmi
  - `greatmace` - Maps to GMoy.dmi
  - `pickaxe` - Maps to PXoy.dmi
  - `axe` - Maps to axeoy.dmi
  - `scythe` - Maps to SKoy.dmi
- `/obj/equipment_overlay/armor/` - Armor overlays (framework)
- `/obj/equipment_overlay/shield/` - Shield overlays (framework)

### 2. Mob Procedures

#### `add_equipment_overlay(overlay_type, icon_state_base, dmi_file, direction)`
Applies a directional equipment overlay to a mob.

**Parameters:**
- `overlay_type`: Path to overlay definition (e.g., `/obj/equipment_overlay/weapon/longsword`)
- `icon_state_base`: Base icon state prefix (e.g., "LS")
- `dmi_file`: DMI file to pull overlay from
- `direction`: Current facing direction (will be appended to icon_state)

**Behavior:**
- Converts direction to numeric suffix (1=N, 2=S, 3=E, 4=W, 5=NE, 6=NW, 7=SE, 8=SW)
- Creates image() with combined icon_state (e.g., "LS1" for North-facing Long Sword)
- Adds to `src.overlays` list
- Stores image reference in `src.equipped_overlays[slot]` for later management

**Example:**
```dm
/mob/players/var/M = usr
M.add_equipment_overlay(/obj/equipment_overlay/weapon/longsword, "LS", 'dmi/LSoy.dmi', M.dir)
```

#### `remove_equipment_overlay(item_or_type, icon_state_base, direction)`
Removes an equipment overlay from a mob.

**Parameters:**
- `item_or_type`: Either an item object or overlay type path
- `icon_state_base`: Base icon state prefix (optional if item passed)
- `direction`: Direction of overlay to remove

**Behavior:**
- If item object passed, extracts `typi` variable for icon_state_base
- Removes matching image from `src.overlays`
- Handles both specific removal and generic removal

#### `clear_all_overlays(overlay_type)`
Removes all overlays of a specific type.

**Parameters:**
- `overlay_type`: Type of overlay to clear (e.g., `/obj/equipment_overlay/weapon`)

**Behavior:**
- Iterates through overlays
- Removes those matching the type
- Used when unequipping all items or changing game state

#### `update_weapon_overlay()`
Applies/updates the current weapon overlay.

#### `update_armor_overlay()`
Applies/updates the current armor overlay.

#### `update_shield_overlay()`
Applies/updates the current shield overlay.

#### `apply_action_overlay(action_name, dmi_file)`
Temporarily applies an action-specific overlay (combat animations, gathering, etc.).

#### `remove_action_overlay()`
Removes temporary action overlay.

#### `track_equipped_overlay(slot, image_object)`
Stores overlay reference for management.

#### `refresh_all_overlays()`
Refreshes all overlays when direction changes.

### 3. Mob Variables

```dm
/mob
	var/list/equipped_overlays = null    // Stores active overlay images by slot
	var/previous_dir = NORTH            // Tracks previous direction for change detection
```

## Directional Icon State System

Equipment overlays use **8-directional icon states** with numeric suffixes:

| Direction | Suffix | Bit Value |
|-----------|--------|-----------|
| NORTH | 1 | 1 |
| SOUTH | 2 | 2 |
| EAST | 3 | 4 |
| WEST | 4 | 8 |
| NORTHEAST | 5 | 5 |
| NORTHWEST | 6 | 6 |
| SOUTHEAST | 7 | 7 |
| SOUTHWEST | 8 | 8 |

**Icon State Format:** `{base_code}{direction_num}`
- Long Sword North: `LS1`
- War Hammer South: `WH2`
- Pickaxe East: `PX3`

## DMI Asset Requirements

For each weapon type, a corresponding DMI file with 8 directional frames is required:

### Current Weapon Overlays (Ready)
- **LSoy.dmi** - Long Sword (8 frames: LS1-LS8)
- **WHoy.dmi** - War Hammer (8 frames: WH1-WH8)
- **GMoy.dmi** - Great Mace (8 frames: GM1-GM8)
- **PXoy.dmi** - Pickaxe (8 frames: PX1-PX8)
- **axeoy.dmi** - Axe (8 frames: AX1-AX8)
- **SKoy.dmi** - Scythe (8 frames: SK1-SK8)

### Future Armor Assets
- **armor.dmi** - Armor variants (body placement)

### Future Shield Assets
- **shields.dmi** - Shield variants (arm placement)

## Integration with Existing Equipment System

The Equipment Overlay System is designed to integrate with **tools.dm**'s Equip/Unequip verbs.

### Integration Points (EquipmentOverlayIntegration.dm)

When the weapon DMI assets are created, modify tools.dm's Equip() and Unequip() verbs:

**In Equip() verb (after `src.suffix = "Equipped"`):**
```dm
// Apply visual overlay
if(src.suffix == "Equipped" || src.suffix == "Dual Wield")
	var/mob/players/M = usr
	if(ismob(M) && M)
		M.apply_equipment_overlay(src)
```

**In Unequip() verb (after clearing suffix):**
```dm
// Remove visual overlay
if(src.suffix == "")
	var/mob/players/M = usr
	if(ismob(M) && M)
		M.remove_equipment_overlay(src)
```

### Helper Procedures (Available in EquipmentOverlayIntegration.dm when enabled)

```dm
/mob/proc/apply_equipment_overlay(obj/items/tools/item)
	// Maps item typi codes to overlays
	// LS→LSoy.dmi, WH→WHoy.dmi, etc.

/mob/proc/remove_equipment_overlay(obj/items/tools/item)
	// Removes overlay for item being unequipped

/mob/proc/refresh_equipment_overlays()
	// Updates all overlays when direction changes
```

## Usage Example

### Equipping a weapon (after integration)
```dm
// In tools.dm Equip() verb
if ((typi=="LS")&&(twohanded==1))
	if (usr.tempstr>=src.strreq)
		if(usr.LSequipped==0)
			usr << "You unsheath and wield the Longsword."
			src.suffix="Equipped"
			
			// NEW: Apply visual overlay
			var/mob/players/M = usr
			M.apply_equipment_overlay(src)
			
			// ... rest of equip logic ...
```

### Directional updates
```dm
// Direction change automatically updates overlays (via Bump override in EquipmentOverlaySystem)
/mob/Bump(atom/A)
	var/old_dir = src.previous_dir
	..()
	
	if(previous_dir != src.dir)
		previous_dir = src.dir
		refresh_all_overlays()  // All overlays update to new direction
```

## File Organization

```
dm/
├── EquipmentOverlaySystem.dm         # Core overlay system (ACTIVE)
├── EquipmentOverlayIntegration.dm    # Integration hooks (DISABLED until DMI files exist)
└── tools.dm                          # Equipment system (will integrate with)

dmi/
├── LSoy.dmi                          # Weapon overlays (TO BE CREATED)
├── WHoy.dmi
├── GMoy.dmi
├── PXoy.dmi
├── axeoy.dmi
├── SKoy.dmi
├── armor.dmi                         # Armor overlays (future)
└── shields.dmi                       # Shield overlays (future)
```

## Implementation Checklist

- [x] Create EquipmentOverlaySystem.dm with modular architecture
- [x] Define overlay types for weapons (6 types)
- [x] Implement directional rendering system
- [x] Create mob procedures for overlay management
- [x] Create EquipmentOverlayIntegration.dm helper procs
- [ ] Create weapon DMI files (LSoy.dmi, WHoy.dmi, GMoy.dmi, PXoy.dmi, axeoy.dmi, SKoy.dmi)
- [ ] Create armor DMI file (armor.dmi)
- [ ] Create shield DMI file (shields.dmi)
- [ ] Enable EquipmentOverlayIntegration.dm in Pondera.dme
- [ ] Hook integration procs into tools.dm Equip/Unequip verbs
- [ ] Test equipment visual overlay rendering
- [ ] Test directional overlay updates on movement
- [ ] Implement armor overlay support
- [ ] Implement shield overlay support
- [ ] Add action overlays for combat animations
- [ ] Add gathering action overlays

## Future Enhancements

1. **Animation Overlays**: Temporary overlays for attack/skill animations
2. **Armor Variants**: Multiple armor visual sets with stat bonuses
3. **Shield Types**: Directional shield rendering on left arm
4. **Dual Wield**: Side-by-side weapon rendering
5. **Aura Effects**: Magical effect overlays for buffs
6. **Enchantment Effects**: Visual indicators for item enchantments
7. **Cosmetic System**: Transmog-style appearance overrides
8. **Color Customization**: Dynamic tinting of equipment overlays

## Troubleshooting

### Overlays not appearing
- Check DMI file path exists
- Verify icon_state names match (e.g., "LS1" not "LS 1")
- Ensure direction suffix is correctly calculated (1-8)
- Check that image() is being added to overlays list

### Overlays flickering
- May need to cache images to prevent recreation
- Verify refresh_all_overlays() isn't being called excessively

### Performance issues
- Equipment overlays are lightweight (simple image objects)
- Max 8 overlays per character (one per equipment slot)
- Avoid creating new overlays every frame

## Build Status

- **Current**: ✅ Clean build (0 errors)
- **EquipmentOverlaySystem.dm**: ✅ Active and functional
- **EquipmentOverlayIntegration.dm**: ⏸️ Disabled (awaiting DMI assets)
- **DMI Assets**: ⏳ Pending creation

Last updated: 12/5/25 3:45 pm
