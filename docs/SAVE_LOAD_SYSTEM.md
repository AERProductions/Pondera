# Pondera Save/Load System

## Overview

The character save/load system persists player progression data when they disconnect and reconnect. The system uses BYOND's savefile format to serialize character objects and their contained datums.

## Architecture

### Current Implementation

**Location**: `dm/_DRCH2.dm`

The system uses the BYOND client/mob savefile framework:
- **Client**: Manages per-player savefiles stored in `players/[first_initial]/[ckey].sav`
- **Mob Write()**: Called when character is saved (on logout or graceful exit)
- **Mob Read()**: Called when character is loaded (on login)

### Data Persistence Flow

```
Player Login
  → client.base_LoadMob(character_name)
  → Load savefile: players/A/abl.sav
  → Deserialize mob object (triggers Read())
  → Read() restores position + character datum
  → Character logged in with full progression restored

Player Logout/Disconnect
  → client.Del() event fires
  → client.base_SaveMob() called
  → Serialize mob object (triggers Write())
  → Write() persists position + character datum
  → Savefile closed and written to disk
```

## What Gets Saved

### Position Data
- **X coordinate** - Horizontal position on map
- **Y coordinate** - Vertical position on map  
- **Z coordinate** - Map layer/z-level (for multi-level support)
- **Condition**: Only saved if `base_save_location = 1` (default for players)

### Character Progression Data
- **Character Datum** (`/datum/character_data`)
  - 12 rank levels (frank, crank, grank, hrank, mrank, smirank, smerank, brank, drank, Crank, CSRank, PLRank)
  - 12 experience values (frankEXP, crankEXP, grankEXP, etc.)
  - 12 experience thresholds (frankMAXEXP, crankMAXEXP, grankMAXEXP, etc.)
- **Condition**: Automatically serialized for `mob/players` type if character datum exists

### Default Mob Savefile Data
- Name, key, gender, icon, icon_state, dir
- Equipped items and inventory (inherited from mob)
- Custom variables (if defined with appropriate types)

## What Should Be Saved (Future Enhancements)

Currently **NOT** persisted but should be considered for future phases:

### Inventory/Items
- Backpack contents
- Equipment (weapons, armor, shields)
- Stack amounts for stackable items

### Basecamp Resources
- SP (Stone) storage
- MP (Metal) storage
- SB (Supply Box) storage
- SM (Stamina Module) storage

### Player State
- Stamina level
- HP/Health level
- Equipment status (which slots are filled)
- Active status effects

### Knowledge/Progress
- Discovered recipes
- Completed quests/tasks
- Unlocked content/features

### Custom Equipment Overlays
- Applied equipment skins/colors
- Custom appearance settings

## Code Reference

### Write() - Saving Character Data

Located in `dm/_DRCH2.dm` lines 47-61

```dm
Write(savefile/F)
    ..()  // Call default BYOND savefile behavior
    
    // Save position
    if (base_save_location && world.maxx)
        F["last_x"] << x
        F["last_y"] << y
        F["last_z"] << z
    
    // Save character progression datum
    if(ismob(src, /mob/players))
        var/mob/players/player = src
        if(player.character)
            F["character"] << player.character
    return
```

**Key Points**:
- `..()` serializes the mob itself (name, icon, inventory, etc.)
- Manual savefile operations (`<<`) write specific data to named keys
- Character datum is automatically deep-copied when assigned to savefile
- Type checking ensures we only save for player mobs

### Read() - Loading Character Data

Located in `dm/_DRCH2.dm` lines 63-89

```dm
Read(savefile/F)
    ..()  // Call default BYOND savefile behavior
    
    // Restore position
    if (base_save_location)
        var/last_x, last_y, last_z
        F["last_x"] >> last_x
        F["last_y"] >> last_y
        F["last_z"] >> last_z
        if(last_x > world.maxx)
            del(src)  // Invalid location, boot player
            return
        loc = locate(last_x, last_y, last_z)
    
    // Restore character progression datum
    if(ismob(src, /mob/players))
        var/mob/players/player = src
        F["character"] >> player.character
        
        // Fallback for old saves without character datum
        if(!player.character)
            player.character = new /datum/character_data()
            player.character.Initialize()
    return
```

**Key Points**:
- `>>` operator reads from savefile keys
- Fallback handling ensures old saves still load (new character created)
- Bounds checking prevents loading into invalid map locations
- Type checking ensures correct mob type handling

## Save File Format

Binary BYOND savefile format (`.sav` extension):
- Auto-serializes objects and their datums
- Preserves type information (can deserialize without explicit casting)
- Handles circular references automatically
- Includes version checking for compatibility

**Storage Location**: `players/[first_initial]/[ckey].sav`

Example path: `players/a/abl.sav` for player with ckey "abl"

## Backward Compatibility

The system includes fallback logic to handle old saves:

```dm
// In Read() proc
if(!player.character)  // Old save without datum
    player.character = new /datum/character_data()
    player.character.Initialize()  // Reset to defaults
```

This ensures:
- Old saves can still be loaded without errors
- Players get fresh character progression (no data loss, just reset)
- New saves always preserve datum

## Limitations & Gotchas

### 1. Binary Format Fragility
- **Issue**: Changing datum variable types breaks deserialization
- **Solution**: Increment datum version if types change, handle in Read()
- **Risk**: Renamed variables will silently fail to load (become new vars with default values)

### 2. Datum Scope Requirements
- `/datum/character_data` must be defined before mob/players
- Include order in Pondera.dme is critical
- Savefile can't deserialize unknown types

### 3. No Partial Saves
- Entire mob is saved/loaded atomically
- Can't selectively save just one variable
- Failure affects entire character

### 4. Inventory Handling
- Default BYOND savefile behavior serializes `contents` list
- Items in inventory are deep-copied (new object instances on load)
- Item count/stack amounts NOT automatically persisted

### 5. Map Validation
- Position validation only checks `world.maxx` (max X coordinate)
- Doesn't verify turf type is passable/valid
- Players might load into walls or deleted areas

## Future Improvements

### Phase 1: Validation & Safety
- [ ] Enhanced position validation (check turf density, obstruction)
- [ ] Graceful fallback to safe spawn point if location invalid
- [ ] Savefile version tracking for compatibility

### Phase 2: Extended Persistence  
- [ ] Inventory serialization with stack amounts
- [ ] Stamina/HP recovery on login
- [ ] Equipment/loadout presets
- [ ] Recipe/knowledge database state

### Phase 3: Data Migration
- [ ] Convert old format saves to new datum-based format
- [ ] Lossless migration of scattered rank variables
- [ ] Archive system for deleted characters

### Phase 4: Optimization
- [ ] Lazy-load large character objects
- [ ] Compress savefile data for large player bases
- [ ] Async save/load to prevent frame hitching

## Testing

To verify save/load is working:

1. **Create a character** and advance a skill level
2. **Note the skill level value** (e.g., frank = 2)
3. **Close and reopen the game**
4. **Load the same character**
5. **Verify skill level persists** (frank should still = 2)

### Debug Commands

Check if character datum exists:
```dm
usr << "Character datum exists: [usr.character ? "YES" : "NO"]"
```

View saved character data:
```dm
usr << "Fishing level: [usr.character.frank]"
usr << "Crafting exp: [usr.character.crankEXP] / [usr.character.crankMAXEXP]"
```

## Implementation Notes

**Current Status**: ✅ Complete for character progression

**Scope**: Position + Character Datum (12 skills × 3 variables = 36 variables)

**Build Status**: 0 errors, 3 warnings (pre-existing)

**Next Priority**: Extended persistence for inventory/equipment

---

**Related Files**:
- `dm/_DRCH2.dm` - Character save/load system
- `dm/CharacterData.dm` - Character progression datum
- `dm/Basics.dm` - mob/players type definition
- `dm/UnifiedRankSystem.dm` - Skill accessor functions
- `dm/SavingChars.dm` - Character creation forms

**Last Updated**: December 6, 2025
