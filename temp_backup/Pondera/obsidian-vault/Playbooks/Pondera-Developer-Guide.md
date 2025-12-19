# Pondera Quick Reference - Developer Guide

**Created**: 2025-12-16  
**For**: Developers working on Pondera codebase  
**Updated Regularly**: Yes

## File Locations
```
c:\Users\ABL\Desktop\Pondera\
├── Pondera.dme          ← Main project file (include order here)
├── Pondera.dmb          ← Compiled binary (generated)
├── dm/                  ← System code (85+ files)
├── libs/                ← Libraries (elevation, atoms, etc)
├── mapgen/              ← Procedural generation
├── dmi/                 ← Icons (32x32, 64x64)
├── Pondera-Recoded/     ← UI/Interface files
└── MapSaves/            ← Player chunk saves
```

## Building
```powershell
# Navigate to project
cd 'c:\Users\ABL\Desktop\Pondera'

# Build
& 'C:\Program Files (x86)\BYOND\bin\dm.exe' 'Pondera.dme'

# Expected: 0 errors, ~20 warnings (acceptable)

# Start server (for testing)
& 'C:\Program Files (x86)\BYOND\bin\dreamdaemon.exe' 'Pondera.dmb' 5900 -trusted

# Current port: 5900
```

## Critical Concepts

### 1. The Initialization Sequence
**Five phases, takes ~400 ticks (10 seconds at 40 TPS)**

```
Tick  0 → Time system loads
Tick  5 → Crash recovery  ← BLOCKS new players until here
Tick 50 → Infrastructure (map, weather, zones)
Tick 55 → Deed system lazy-init
Tick 100 → Lighting cycles start
Tick 300 → World systems (towns, market)
Tick 400 → Everything ready
```

**Gate all player gameplay on**: `world_initialization_complete == TRUE`

### 2. Player Data Storage
**Three types**:
```
datum/character_data    ← Per-player persistent data (saved in character file)
player variables        ← Runtime-only (not saved)
savefile data          ← Binary chunk saves (auto-save)
```

**When adding new player data**:
1. Add variable to `datum/character_data`
2. Bump `SavefileVersioning.dm` version
3. Add load/save code in `SavingChars.dm`

### 3. Elevation System
**Key variables**:
```dm
obj.elevel        ← Decimal height (1.0 ground, 1.5 stairs, 2.0 second level)
obj.layer         ← Auto-calculated (higher elevel = higher layer)
obj.invisibility  ← Auto-calculated (lower elevals invisible from high)
```

**Always check** before interaction:
```dm
if(!Chk_LevelRange(A, B))
	return  // Can't interact - different levels
```

### 4. Deed System
**Core proc** - always call before building/pickup/drop:
```dm
if(!CanPlayerBuildAtLocation(M, T))
	return  // Deed prevents this
```

**What it checks**:
- Territory ownership
- Permission bits (canbuild, canpickup, candrop)
- Freeze status (non-payment)

### 5. Consumption Ecosystem
**Global registry** - never hardcode values:
```dm
CONSUMABLES["item_name"] = [type, nutrition, hydration, stamina, seasons, biomes, quality]
```

**All items must be in registry** before:
- Harvesting
- Cooking
- Consuming

**Season check** (always required):
```dm
if(!(current_season in CONSUMABLES[item]["seasons"]))
	return  // Wrong season
```

### 6. Rank System
**12 skill types**, 5 levels each:
```dm
RANK_FISHING      "frank"
RANK_CRAFTING     "crank"
RANK_MINING       "mrank"
RANK_SMITHING     "smirank"
...12 total
```

**To check/update**:
```dm
var/level = M.GetRankLevel(RANK_FISHING)
M.UpdateRankExp(RANK_FISHING, exp_gain)
M.SetRankLevel(RANK_FISHING, new_level)
```

### 7. Three Continents
**Rules per continent**:
```
Story:      allow_pvp=0, building=1, monsters=1, NPCs=1
Sandbox:    allow_pvp=0, building=1, monsters=0, NPCs=0
Kingdom PvP: allow_pvp=1, stealing=1, building=1, monsters=1
```

**Gate gameplay on**: Continent rules dictionary

## Common Tasks

### Add New System
```
1. Create dm/MySystem.dm
2. Add to Pondera.dme BEFORE mapgen block
3. Use RegisterInitComplete() if needs boot phase
4. Rebuild: dm.exe Pondera.dme
5. Verify: 0 errors
```

### Add New Consumable
```
1. Add to CONSUMABLES registry in ConsumptionManager.dm
   CONSUMABLES["item_name"] = [/obj/item/type, nutrition, hydration, stamina, ["Spring", "Summer"], ["temperate"], 0.8]
2. Create /obj/item/type code
3. Add recipe to RECIPES (if craftable)
4. Test harvest/cook/consume cycle
```

### Add New Rank
```
1. Define #define RANK_MYSKILL "myrank" at top
2. Add var/myrank in /datum/character_data
3. Add case to GetRankLevel/SetRankLevel/UpdateRankExp
4. Add skill-based recipe unlock in SkillRecipeUnlock.dm
5. Rebuild and test progression
```

### Add Equipment
```
1. Extend /obj/items
2. Add equipment slot vars (Aequipped, Wequipped, etc)
3. Integrate overlay rendering via EquipmentOverlaySystem.dm
4. Add AC/damage stats as needed
5. Test equipping and overlay display
```

## Debugging Tips

### Check Build Errors
```powershell
dm.exe Pondera.dme 2>&1 | Select-String "error"
```

### Check World Log
```
File: world.log (in Pondera folder)
Look for: [LOGIN], [INIT], [ERROR], [CHARGEN]
```

### Test Player Creation
```dm
var/mob/players/M = new /mob/players()
M.key = "testkey"
M.loc = locate(5, 5, 1)
// Login() called automatically
```

### Verify Initialization
```dm
world.log << "[DEBUG] Init complete? [world_initialization_complete]"
world.log << "[DEBUG] Status: [GetInitializationStatus()]"
```

## Known Gotchas

1. **Include order matters** - Later files override earlier ones
2. **Savefile fragility** - Changing var types breaks saves (bump version)
3. **Elevation conflicts** - Chk_LevelRange() must pass before any interaction
4. **Season gating** - Always check CONSUMABLES seasons before harvest
5. **Deed authority** - CanPlayerBuildAtLocation() is the law
6. **No hardcoded prices** - Use DynamicMarketPricingSystem.dm
7. **Movement cache** - InvalidateDeedPermissionCache() called every move
8. **Initialization timing** - Gate gameplay until tick 400+

## Performance Notes
```
FPS Setting: 40 TPS (25ms per tick = TIME_STEP 5)
Warning Signs: Compilation time > 5 sec, file size > 1MB
```

## Related Documentation
- [[Project-Overview]] - High-level architecture
- [[Build-System-Reference]] - Building and compile
- [[DM-Code-Patterns]] - Common code snippets
- [[Session-Log-2025-12-16]] - Latest session work
- [[Character-Creation-UI-Fix]] - Recent decision record
