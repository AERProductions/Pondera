# Modern Login System - Implementation Guide

**Status**: ✅ Complete and integrated  
**Build Status**: ✅ 0 errors, 0 warnings  
**Commit**: 96639c5

## Overview

The modern login system replaces the legacy DMF login interface with a code-based character class selection system. Players can choose from 5 character classes that provide starting stat bonuses and rank progression advantages.

## Architecture

### Core Component: `/datum/login_ui`

Located in `dm/LoginUIManager.dm`, this datum manages character class selection and stat application.

**Properties**:
```dm
var/mob/players/player = null       // Reference to the player being configured
var/character_initialized = FALSE   // Whether class bonuses have been applied
```

**Key Procedures**:

#### `ShowClassPrompt()`
Displays the class selection interface to the player and applies chosen bonuses.

```dm
login_ui.ShowClassPrompt()
```

- Shows input dialog with 5 class options + "Skip"
- Calls `ApplyClassStats()` if class is selected
- Sets `character_initialized = TRUE` on completion

#### `ApplyClassStats(mob/players/player, class_name)`
Applies class-specific stat bonuses to the player.

```dm
login_ui.ApplyClassStats(player, "Warrior")
```

**Parameters**:
- `player`: Target player mob
- `class_name`: Class string ("Warrior", "Scout", "Mage", "Crafter", "Naturalist")

## Character Classes

All classes provide rank bonuses to `/datum/character_data` and HP/stamina modifiers:

### 1. Warrior
- **HP Bonus**: +50 (150 total)
- **Stamina Bonus**: -20 (80 total)
- **Rank Bonuses**: Building +2, Smithing +1
- **Focus**: Tank/Defense playstyle

### 2. Scout
- **HP Bonus**: -20 (80 total)
- **Stamina Bonus**: +50 (150 total)
- **Rank Bonuses**: Fishing +2
- **Focus**: Speed/Ranged playstyle

### 3. Mage
- **HP Bonus**: -10 (90 total)
- **Stamina Bonus**: +20 (120 total)
- **Rank Bonuses**: Crafting +2
- **Focus**: Utility/Crafting playstyle

### 4. Crafter
- **HP Bonus**: 0 (100 total)
- **Stamina Bonus**: 0 (100 total)
- **Rank Bonuses**: Building +3, Smithing +2, Crafting +2
- **Focus**: Production/Economy playstyle

### 5. Naturalist
- **HP Bonus**: 0 (100 total)
- **Stamina Bonus**: 0 (100 total)
- **Rank Bonuses**: Gardening +3, Mining +2
- **Focus**: Resource gathering playstyle

## Integration with Existing Systems

### Player Mob Integration

The `/mob/players` class in `dm/Basics.dm` includes:

```dm
datum/login_ui/login_ui  // Reference to login UI manager
```

This allows any player to have an active login UI instance for class selection:

```dm
/mob/players/New()
	..()
	// Character data initialized here by existing code
	if(!character)
		character = new /datum/character_data()
		character.Initialize()
```

### Rank System Integration

Class bonuses integrate with the unified rank system via `/datum/character_data`:

```dm
var/frank = 0         // Fishing rank
var/crank = 0         // Crafting rank
var/grank = 0         // Gardening rank
var/mrank = 0         // Mining rank
var/brank = 0         // Building rank
var/smirank = 0       // Smithing rank
```

When class stats are applied:
```dm
player.character.brank = max(player.character.brank, 3)  // Ensure minimum rank
```

Using `max()` prevents overwriting existing rank progress.

### HP/Stamina System

Bonuses apply to player vital stats:

```dm
player.HP = starting_hp       // Current health
player.MAXHP = starting_hp    // Maximum health capacity
player.stamina = starting_stamina
player.MAXstamina = starting_stamina
```

Bonuses only apply if HP/stamina are at default values to avoid affecting characters with existing progress.

## Usage Examples

### Show Class Selection to a Player

```dm
var/mob/players/P = find_player("PlayerName")
if(!P.login_ui)
	P.login_ui = new /datum/login_ui(P)
P.login_ui.ShowClassPrompt()
```

### Programmatically Apply Class Bonuses

```dm
var/mob/players/player = new /mob/players()
player.login_ui = new /datum/login_ui(player)
player.login_ui.ApplyClassStats(player, "Crafter")
// Player now has: brank=3, smirank=2, crank=2
```

### Check if Class Bonuses Applied

```dm
if(player.login_ui && player.login_ui.character_initialized)
	// Class selection was completed
```

## Rank Constants Reference

The following rank variables are modified by class selection:

| Constant | Variable | Meaning |
|----------|----------|---------|
| RANK_FISHING | frank | Fishing skill level |
| RANK_CRAFTING | crank | Crafting skill level |
| RANK_GARDENING | grank | Gardening skill level |
| RANK_MINING | mrank | Mining skill level |
| RANK_BUILDING | brank | Building skill level |
| RANK_SMITHING | smirank | Smithing skill level |

All defined in `!defines.dm` with max level 5.

## Implementation Status

| Component | Status | Location |
|-----------|--------|----------|
| LoginUIManager.dm | ✅ Complete | `dm/LoginUIManager.dm` |
| /datum/login_ui class | ✅ Complete | Lines 3-6 |
| ShowClassPrompt() | ✅ Complete | Lines 11-24 |
| ApplyClassStats() | ✅ Complete | Lines 26-73 |
| /mob/players integration | ✅ Complete | `dm/Basics.dm` line 177 |
| Class definitions | ✅ Complete | 5 classes defined |
| Rank system integration | ✅ Complete | Uses existing character_data |
| HP/stamina application | ✅ Complete | Applies to player vitals |

## Future Enhancements

Planned features for future iterations:

1. **Account System Integration**
   - Persist player class selection across sessions
   - Store class choice in character data

2. **Visual Overlay Effects**
   - Fade in/out animations during class selection
   - Class-specific color themes or icons

3. **Character Preview**
   - Show character model updates as class is selected
   - Display updated stat projections before confirmation

4. **New Game+ Progression**
   - Allow class respec on new character creation
   - Track class history in character_data

5. **Multi-Class System**
   - Support dual-class progression in future phases
   - Advanced skill combinations

## Testing

To test the modern login system:

1. **Build verification**:
   ```
   Run: dm: build - Pondera.dme
   Expected: 0 errors, 0 warnings
   ```

2. **Class application test**:
   ```dm
   var/mob/players/test_player = new /mob/players()
   test_player.login_ui = new /datum/login_ui(test_player)
   test_player.login_ui.ApplyClassStats(test_player, "Warrior")
   // Verify: test_player.character.brank == 2
   // Verify: test_player.HP == 150
   ```

3. **Selection prompt test** (in-game):
   - Create player character
   - Call `player.login_ui.ShowClassPrompt()`
   - Select class from dialog
   - Verify stats applied in character sheet

## Troubleshooting

### "login_ui is undefined" Error
- **Cause**: LoginUIManager.dm not included in .dme
- **Solution**: Verify `#include "dm\LoginUIManager.dm"` exists in Pondera.dme after Phase11c_TestRunner.dm

### Character bonuses not applying
- **Cause**: player.character not initialized
- **Solution**: Ensure character_data is created in player New() proc (handled automatically in Basics.dm)

### Class prompt not showing
- **Cause**: login_ui reference is null
- **Solution**: Create login_ui instance: `player.login_ui = new /datum/login_ui(player)`

## Architecture Decisions

### Why Code-Based Instead of DMF?

1. **Immersion**: Players see the game world during login, not a separate window
2. **Integration**: Direct access to game systems (ranks, stats) without DMF complications
3. **Extensibility**: Easy to add new classes or rank bonuses without DMF redesign
4. **Testability**: Can test login flow directly in code

### Why `/datum/login_ui` Instead of `/mob/login_ui`?

1. **Encapsulation**: Login state belongs to a data structure, not a mob
2. **Reference Counting**: Cleaner lifecycle management through datum
3. **Multiple Instances**: Supports multiple concurrent login sessions
4. **Serialization**: Can save/restore login state if needed

### Class Rank Bonuses Using `max()`

The use of `max()` ensures existing progression isn't lost:

```dm
player.character.brank = max(player.character.brank, 3)
```

This allows:
- Applying class bonuses to fresh characters (brank 0 → 3)
- Avoiding reduction if character already has higher ranks (brank 5 → stays 5)

## Related Documentation

- [Character Data System](./DOCUMENTATION_INDEX_COMPLETE.md#character-data)
- [Unified Rank System](./DOCUMENTATION_INDEX_COMPLETE.md#rank-system)
- [Phase 11c Integration Tests](./PHASE_11c_TEST_RESULTS.md)

## Commit History

- **96639c5**: Modern login system with class selection and stat bonuses
  - Added LoginUIManager.dm
  - Implemented 5 character classes
  - Integrated with /mob/players
  - Applied rank and HP/stamina bonuses
  - Build: 0 errors, 0 warnings
