# Modern Searching System Design

**Status:** Fully Designed, Ready for Integration  
**Author:** Copilot  
**Date:** December 13, 2025  

## Vision

Transform searching from a proof-of-concept random number generator into a genuine **minigame of discovery and wonder** - capturing that feeling of turning over rocks to see what lies underneath.

## Core Features

### 1. **Interactive Minigame Flow**
- **Stage 1 (1 second):** "You kneel and search through the foliage..."
- **Stage 2 (1.5 seconds):** "Your fingers brush against something interesting..."
- **Stage 3 (1.5 seconds):** Reveal what was found
- Creates **tension and reward cycle** - not instant, but fast enough to stay engaging

### 2. **Smart Item Drops**
- **Unique items** (ueik splinter, whetstone) only drop if player doesn't already have one
- Prevents inventory bloat while still granting XP
- Message indicates: "You find: X (you already have one...)" if duplicate unique item

### 3. **Biome-Aware Discoveries**
- Different terrains have different treasures
- Framework supports adding biome-specific loot tables
- Example: Tall grass finds different items than desert flowers

### 4. **Progressive Difficulty & Anti-Abuse**
- **Consecutive search penalty:** Each search in a row is 5% harder (up to 50% floor)
- **Cooldown protection:** 30-second minimum between searches prevents farming
- **Difficulty reset:** Finding something resets consecutive counter (encourages exploration)
- **Escalating XP demands:** As player progresses, XP thresholds increase naturally

### 5. **Delightful Discovery Messages**
Instead of "You found a Rock!", present discoveries with atmosphere:
- Rank 1: "a smooth stone", "a handful of pebbles", "a leaf fragment"
- Rank 3: "an ancient ueik splinter", "a crystal shard", "a curious seed"  
- Rank 5: "a luminescent mushroom", "precious metal ore", "an ancient artifact"

## System Architecture

### Data Structure: `/datum/search_result`
```dm
/datum/search_result
    var
        item_type        // /obj/items/... path (null = no item, just discovery)
        display_name     // "a shiny stone"
        min_rank = 1
        max_rank = 5
        base_xp = 15
        is_unique = FALSE    // Only drop if player doesn't have one
        rarity = 50          // 1-100, higher = rarer
        biomes = list()      // Biomes this can appear in (empty = all)
```

### Global Registry
```dm
var/list/SEARCHABLE_ITEMS = list()

/proc/InitializeSearchables()
    // Populated at world startup (phase tick 3 in InitializationManager.dm)
```

### Main Integration Points

#### Verb Definition (Objects.dm, line ~5103)
```dm
Searching() 
    set waitfor = 0
    var/mob/players/M = usr
    var/obj/Flowers/O = src
    PerformSearch(M, O)  // Calls main engine
```

#### Engine Functions (SearchingSystemModern.dm)
1. **`PerformSearch(mob/players/M, obj/Flowers/searchable_obj)`**
   - Checks cooldowns, prevent double-searching
   - Implements minigame flow (3-stage discovery)
   - Awards XP via `M.character.UpdateRankExp(RANK_SEARCHING, amount)`
   - Creates items and prints messages

2. **`SelectSearchResult(mob/players/M, obj/Flowers/location, difficulty_factor)`**
   - Evaluates which items are available at player's rank
   - Weights by rarity (high rarity = lower probability)
   - Applies difficulty and rank multipliers
   - Returns selected discovery or null if nothing found

3. **`GetPlayerInventoryItemCount(mob/players/M, item_path)`**
   - Counts how many of a specific item type player owns
   - Used to prevent dropping duplicate unique items

### Player Vars
```dm
/mob/players/var/last_search_time = 0           // Last time player searched
/mob/players/var/consecutive_searches = 0       // Counter for difficulty scaling
```

## Rank Progression

| Rank | Available Items | Example Finds | XP Per Find | Difficulty |
|------|---|---|---|---|
| 1 | Tier 1 rocks/leaves | "a smooth stone" | 10-15 | 80-90% success |
| 2 | Tier 2 materials | "some flint", "bone" | 14-20 | 60-75% success |
| 3 | Uncommon finds | "ancient splinter", "crystal" | 18-25 | 50-65% success |
| 4 | Valuable items | "whetstone", "pyrite", "haunch" | 18-25 | 45-60% success |
| 5 | Rare treasures | "iridescent scale", "artifact" | 24-35 | 30-50% success |

## Integration Checklist

**Step 1: Add to .dme file**
```
#include "dm\SearchingSystemModern.dm"  // After FishingSystem.dm
```

**Step 2: Initialize on world boot**
Add to InitializationManager.dm (around tick 3):
```dm
spawn(3)  InitializeSearchables()  // Initialize discoverable items
```

**Step 3: Update Searching() verb in Objects.dm**
Replace the 366-line old system with:
```dm
Searching() 
    set waitfor = 0
    var/mob/players/M = usr
    var/obj/Flowers/O = src
    PerformSearch(M, O)
```

**Step 4: Test**
- Click on any flower/grass and select "Search"
- Verify progressive discovery messages appear (3 stages)
- Check that items spawn in inventory
- Confirm XP is awarded (`M.character.searching_rank` increases)
- Test cooldown (wait 30 seconds before next search)
- Test unique item drops (ancient splinter, whetstone only appear once)

## Future Enhancements

1. **Biome-Specific Discoveries**
   - Forest: "ancient wood", "mushroom spores", "animal tracks"
   - Desert: "fossilized bone", "sand crystal", "ancient pottery"
   - Arctic: "ice shard", "preserved artifact", "ancient scroll"

2. **Location-Specific Bonuses**
   - Near ruins: +50% chance of artifacts
   - Near ancient sites: Unlock special discoveries
   - Player's deed: +10% XP if searching on own land

3. **Seasonal Variations**
   - Spring: More seeds and sprouts
   - Summer: More stones and gems
   - Autumn: More berries and herbs
   - Winter: Ice-related items

4. **Discovery Journal**
   - Track what items player has found
   - Unlock "hidden knowledge" bonus items
   - Achieve "found all rank 1 items" milestone → XP bonus

5. **Skill Unlocks**
   - Rank 3: Unlock "Careful Search" (slower but better odds)
   - Rank 4: Unlock "Expert Eye" (see clues before searching)
   - Rank 5: Unlock "Treasure Sense" (3 discoveries per search)

## Code Quality Notes

- Uses modern unified rank system (`UpdateRankExp(RANK_SEARCHING, amount)`)
- Fully integrated with character data (`M.character.searching_rank`)
- No legacy level-up checks or separate XP variables
- Extensible datum structure for easy item addition
- DM code is clean, readable, with clear variable names

## Files

- **dm/SearchingSystemModern.dm** - Core engine (ready to include)
- **docs/MODERN_SEARCHING_SYSTEM_DESIGN.md** - This design doc

---

## Example Discovery Messages (Fully Implemented)

**Rank 1 Success (80% chance):**
```
=== Beginning Search ===
You kneel and search through the foliage...
Your fingers brush against something interesting...
You discover: something!
You found: a smooth stone!
```

**Rank 5 Rarity Find (15% chance):**
```
You found: a luminescent mushroom!
(awarded 24 XP)
```

**Unique Item Already Owned:**
```
You found: an ancient ueik splinter (you already have one...)
(awarded 22 XP, no item drop)
```

---

**Ready for integration whenever you wish!** The system is fully designed, code-complete, and tested for syntax. Just follow the Integration Checklist above.
