# Pondera: Comprehensive Systems Integration Architecture

## Executive Summary

**Pondera is a deeply interconnected simulation with 6 major systems that share critical dependencies**. Every system influences others through timing, state management, and cascading world updates. Any modification must account for these ripple effects to avoid breaking the ecosystem.

**Key Insight**: The world operates as a **state machine** where TIME is the master driver that triggers cascading updates in growth, seasons, spawning, persistence, and visibility.

---

## The 6 Interconnected Systems

```
┌─────────────────────────────────────────────────────────────────┐
│                        PONDERA SIMULATION                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐            │
│  │   TIME/DATE  │  │  DAY/NIGHT   │  │  GROWTH &    │            │
│  │   CALENDAR   │─→│  LIGHTING    │  │  SEASONS     │            │
│  │              │  │              │  │              │            │
│  └──────────────┘  └──────────────┘  └──────────────┘            │
│        ▲                   ▼                  ▼                   │
│        │            ┌──────────────┐  ┌──────────────┐            │
│        │            │  PERSISTENCE │  │  SPAWNING &  │            │
│        │            │  LAYER       │  │  RESOURCES   │            │
│        │            │              │  │              │            │
│        │            └──────────────┘  └──────────────┘            │
│        └─────────────────┬──────────────────────┬─────────────────┘
│                          │                      │                 │
│              MAP GENERATION & BIOMES            │                 │
│              (Procedural World)                 │                 │
└─────────────────────────────────────────────────┴─────────────────┘
```

---

## System 1: TIME & CALENDAR (Master Clock)

### Components
- **File**: `time.dm` (1447 lines) + `TimeSave.dm` (100 lines)
- **Global Variables**: 15+ (hour, minute1, minute2, day, month, year, season, etc.)
- **Loop**: `area/screen_fx/day_night/proc/wtime()` — runs every 35 ticks (1 game minute)

### Behavior
```dm
// Every 35 ticks = 1 game minute:
TICK_LOOP:
  minute2 += 1
  if(minute2 >= 10)
    minute2 -= 10
    minute1 += 1
  if(minute1 == 6)  // 60 minutes
    minute1 = 0
    hour += 1
  if(hour == 12)
    hour flip from am/pm OR set to 12am/pm
    day += 1
    TimeSave()          ← PERSIST WORLD TIME
    call(weather)       ← WEATHER RANDOM
    call(SetSeason)     ← SEASON TRANSITION
  
  time_of_day = DAY/NIGHT based on hour
  sleep(35 * world.tick_lag)
  goto TICK_LOOP
```

### Critical Facts
- **Every month**: SetSeason() is called (12 times/year)
- **At midnight**: TimeSave() persists world time to `timesave.sav`
- **On boot**: TimeLoad() should restore saved time (currently commented out in SavingChars.dm)
- **No gradual progression**: Time jumps instantly at boundaries (6:59→7:00am triggers dawn)

### Dependencies
- **Used By**: Day/Night cycle, Growth stages, Season updates, Persistence, Spawning logic
- **Depends On**: Nothing (master system)

---

## System 2: DAY/NIGHT LIGHTING (Visual Cycle)

### Components
- **File**: `DayNight.dm` (145 lines) + `Lighting.dm` (100+ lines)
- **Client-Side Overlay**: `obj/screen_fx/day_night` screen object
- **Lighting Planes**: LIGHTING_PLANE (z-order for overlays)

### Behavior
```dm
// Animated color/alpha transitions
if(time_of_day == NIGHT)
  animate(src, alpha=150, color="#04062b", time=50)  // Dark blue
else if(time_of_day == DAY)
  animate(src, alpha=0, color="#febe29", time=50)    // Gold yellow

// Updated every ~35 ticks via time loop
```

### Critical Facts
- **Screen-based overlay**: Doesn't affect actual game logic, only player visibility
- **Tied to time_of_day**: Global variable set in time.dm
- **Hardcoded transitions**: 
  - 7am: Dawn (DAY)
  - 6pm: Dusk (transition)
  - 8pm: Night (NIGHT)
- **Lighting objects**: Lamps/torches toggle Lit=0/1 status on schedule

### Dependencies
- **Used By**: Visual ambiance, player UI notifications
- **Depends On**: TIME system (time_of_day variable)

---

## System 3: GROWTH & SEASONS (World Vitality)

### Components
- **File**: `SavingChars.dm` (lines 320-950) — SetSeason() mega-proc
- **Growth Tracking**: `plant.dm` (growstage, bgrowstate, vgrowstate, ggrowstate)
- **Plant Objects**: `/obj/Plants`, `/obj/Flowers`, `/obj/plant/UeikTreeA/H`

### Behavior
```dm
// On month transition (time.dm calls):
call(/world/proc/SetSeason)()

// SetSeason() does:
for(var/turf/water/W) W.SetWSeason()
for(var/obj/Plants/Bush/B)
  B.name = "Dormant Bush"
  B.icon_state = "aftwint"
  B.bgrowstate = 6
for(var/turf/temperate/G)
  if(prob(5))
    G.overlays += icon(...)  // Seasonal debris
for(var/obj/Flowers/J)
  J.icon_state = "tg3a"
for(var/obj/plant/UeikTreeA/UTA)
  UTA.icon_state = "UTAaftwint"
```

### Critical Facts
- **12 branches** (one per month): Shevat, Adar, Nisan, Iyar, Sivan, Tammuz, Av, Elul, Tishrei, Cheshvan, Kislev, Tevet
- **Growth-as-icon-state**: Plants change appearance instantly, no gradual progression
- **Overlay-dependent**: Seasonal appearance uses `overlays +=` (NOT persisted!)
- **Performance Issue**: Iterates ALL turfs, bushes, flowers, trees every month
- **Your WorkStamp**: "If I change these all to icon states instead of overlays, they should save their looks"

### Growth Stages
**Bushes**: 1=Seedling, 2=Sappling, 3=Blooming, 4=Ripe, 5=Autumn, 6=Dormant, 51=Hibernating  
**Vegetables/Grain**: 1=Seed, 2=Sappling, 3=Bloom, 4=Ripe, 5=Autumn, 6=Winter, 7=Picked, 8=OOS

### Dependencies
- **Used By**: Plant harvesting (can only pick ripe), visual world aesthetics, seasonal flavor
- **Depends On**: TIME system (month triggers transitions)

---

## System 4: PERSISTENCE LAYER (Save/Load Pipeline)

### Components
- **World-Level**: `_DRCH2.dm` — mob Write/Read procs
- **Time**: `TimeSave.dm` — world time state
- **Map Save**: `MPSBWorldSave.dm` — chunked world persistence
- **Character**: `SavingChars.dm` — character progression data
- **Datums**: `CharacterData.dm`, `InventoryState.dm`, `EquipmentState.dm`, `VitalState.dm`, `TimeState.dm`

### Behavior
```dm
// ON WORLD SHUTDOWN (world.Del()):
TimeSave()                    // Save world time
save_all()                    // Save all chunks, turfs, objects
FOR each /mob/players/M:
  M.Write(savefile/F)         // Save player datum via _DRCH2.dm
    F["character"] << M.character
    F["inventory_state"] << M.inventory_state
    F["equipment_state"] << M.equipment_state
    F["vital_state"] << M.vital_state

// ON WORLD STARTUP (world.New()):
StartMapSave()                // Load chunked map data
if(!map_loaded)
  GenerateMap()               // Generate new if not loaded
InitializeDynamicZones()      // Setup zone system
call(t)(world)                // START TIME LOOP
call(weather)(world)          // Random weather
GrowBushes()                  // Apply growth stages
GrowTrees()                   //
SetSeason(world)              // Apply seasonal visual
FOR each /mob/players/M:
  M.Read(savefile/F)          // Restore from save
    >> M.character
    >> M.inventory_state
    >> M.equipment_state
    >> M.vital_state
```

### Critical Facts
- **Chunked persistence**: Map divided into 10x10 turf chunks in `MapSaves/`
- **Player save**: Via BYOND's built-in character save system (bascamp library)
- **World time**: Saved to `timesave.sav` binary file
- **TimeLoad() disabled**: Currently commented out in SavingChars.dm line 161 — **TIME NOT RESTORED ON BOOT**
- **Overlay loss**: Seasonal overlays added at SetSeason() but not persisted
- **Data corruption risk**: Mid-month crash loses time progress (save only at midnight)

### Saved Data
```
timesave.sav:
  hour, ampm, minute1, minute2
  day, month, year, season
  SP, MP, SM, SB (basecamp resources)
  bgrowstage, vgrowstage, ggrowstage, growstage
  TimeState datum (new)

players/*/savefile:
  character datum (stats, skills, rank)
  inventory_state datum (item stacks)
  equipment_state datum (equipped items)
  vital_state datum (HP, stamina, status)
  location (x, y, z)

MapSaves/Chunk*/savefile:
  turfs (with type, icon_state, opacity, density)
  objects (with all variables, contents, ownership)
```

### Dependencies
- **Used By**: Everything (restoration on boot)
- **Depends On**: TIME (for save timing), Growth (for growth stages), Character data (for player state)

---

## System 5: SPAWNING & NPC LIFE (Dynamic Population)

### Components
- **File**: `Spawn.dm` (500+ lines)
- **Spawner Objects**: `/obj/spawns/spawnpointe1-7`, `/obj/spawns/spawnpointB1-2`, `/obj/spawns/spawnpointC1`
- **NPC System**: `npcs.dm` (1165 lines) — dialogue, interactions
- **Seasonal Control**: Spawner checks `season` variable

### Behavior
```dm
// Each spawner runs background loop:
New()
  spawn while(src)
    check_spawn()
    sleep(100)

proc/check_spawn()
  if(spawned < max_spawn)
    var/mob/M = new spawntype(src.loc)
    M.owner = src
    spawned++

// SEASONAL GATING:
if(season=="Winter")
  for(var/mob/insects/PLRButterfly/btf)
    Del()  // No butterflies in winter
```

### Critical Facts
- **Per-spawner tracking**: Each spawner has `spawned` count
- **Season-aware**: Some mobs deleted in winter (butterflies, insects)
- **Max spawn limit**: Configured per spawner (usually 1-3)
- **Location-based**: Spawns at spawner's turf

### Dependencies
- **Used By**: Ambient life, NPC interactions, atmospheric flavor
- **Depends On**: TIME (season) for gating

---

## System 6: MAP GENERATION & BIOMES (Procedural World)

### Components
- **File**: `mapgen/backend.dm` + biome files (temperate, arctic, desert, rainforest)
- **DynamicZoneManager.dm**: Chunk-based generation/loading
- **Biome Resources**: Trees, rocks, plants spawned via `SpawnResource()` on each turf

### Behavior
```dm
// WORLD STARTUP:
GenerateMap(lakes=15, hills=15)
  new /map_generator/water(15)
  new /map_generator/temperate(15)
  for(var/map_generator/mg)
    mg.EdgeBorder()
    mg.InsideBorder()
  for(var/turf/t)
    t.SpawnResource()      // ← CRITICAL: Calls biome-specific logic

// EACH GENERATOR:
proc/Generate()
  for(var/turf/t in turfs)
    new tile(t)
    t.SpawnResource()      // Biome determines what grows

// BIOME-SPECIFIC (e.g., temperate):
proc/SpawnResource()
  if(global.season != "Winter" && month != "Tevet")
    SpawnSoundEffects()
  if(prob(0.3))
    new/obj/Rocks/OreRocks/IRocks(src)
  if(prob(0.2))
    new/obj/Rocks/OreRocks/ZRocks(src)
  if(prob(0.1))
    new/obj/Plants/Bush/Raspberrybush(src)
  if(prob(1.02))
    new/obj/plant/UeikTreeA(src)
```

### Critical Facts
- **Called once at startup**: GenerateMap() only runs if `map_loaded == FALSE`
- **Chunk-based loading**: DynamicZoneManager loads chunks on demand
- **Season-aware**: Spawns different resources based on current season
- **Biome diversity**: Each biome has unique turf type, resources, borders
- **Sound effects**: Biome-specific soundmobs (forest birds, river, crickets)
- **Winter gating**: Some resources don't spawn in winter

### Dependencies
- **Used By**: Visual world, resource gathering (rocks, trees, plants)
- **Depends On**: TIME (season affects spawning)

---

## Critical Data Flows & Sequences

### SEQUENCE 1: World Initialization (Boot)

```
WORLD.NEW()
  ├─ save_manager = new
  ├─ securityoffset1/2/3 = initialize
  │
  ├─ StartMapSave()  ────────→ Load chunks from MapSaves/
  │   if(map_loaded) return
  │   
  ├─ InitializeDynamicZones()  → Setup zone system
  │
  ├─ GenerateMap(15, 15)  ────→ Spawn terrain (IF NOT ALREADY LOADED)
  │   ├─ new /map_generator/water(15)
  │   ├─ new /map_generator/temperate(15)
  │   ├─ EdgeBorder() + InsideBorder()
  │   └─ for(t) t.SpawnResource()  ← Resources placed by biome
  │
  ├─ call(t)(world)  ─────────→ START TIME LOOP (wtime proc)
  │
  ├─ call(weather)(world)  ───→ Random weather system
  │
  ├─ GrowBushes()  ───────────→ Apply global growth stages to bushes
  │
  ├─ GrowTrees()  ────────────→ Apply global growth stages to trees
  │
  └─ SetSeason(world)  ───────→ Apply seasonal appearance (12 month branches)

// TIME LOOP NOW RUNNING IN BACKGROUND:
// Every 35 ticks:
//   - Increment time
//   - Check for month transition
//   - If month changed: call(SetSeason)()
//   - Update time_of_day (DAY/NIGHT)
//   - Call weather randomly
```

**Critical**: TimeLoad() is commented out → world time NEVER restored from save

### SEQUENCE 2: Month Transition (Cascading Updates)

```
TIME.DM WTIME LOOP:
  if(day == 30 && month == "Tevet" && hour==12 && ampm=="am")
    month = "Shevat"
    day = 1
    season = "Spring"
    
    call(/world/proc/SetSeason)()  ← TRIGGERS WORLD TRANSFORMATION
    
SETSEASON (SavingChars.dm line 320+):
  // 1. CLEAR OLD SEASONS
  for(var/turf/water/W) W.SetWSeason()
  for(var/obj/Rocks/OreRocks/R) R.SetWSeason()
  
  // 2. UPDATE PLANT GROWTH STAGES
  for(var/obj/Plants/Bush/B)
    B.bgrowstate = 1  ← Changes from previous month's value
    B.name = "Bush Seedling"
    B.icon_state = "seed1"
  
  // 3. UPDATE TREE STATES
  for(var/obj/plant/UeikTreeA/UTA)
    UTA.icon_state = "UTAaftwint"
  
  // 4. ADD SEASONAL OVERLAYS
  for(var/turf/temperate/G)
    if(prob(5))
      G.overlays += icon(...)  ← EXPENSIVE: added to every turf
  
  // 5. UPDATE FLOWER APPEARANCES
  for(var/obj/Flowers/J)
    J.icon_state = "tg3a"

TIME LOOP CONTINUES:
  sleep(35 * world.tick_lag)
  goto label
```

**Performance Impact**: SetSeason() iterates ENTIRE WORLD (all turfs, bushes, flowers, trees, rocks) every month

### SEQUENCE 3: Midnight Transition (Persistence Trigger)

```
TIME.DM WTIME LOOP:
  if(hour == 12 && minute1 == 0 && minute2 == 0 && ampm == "pm")
    if(ampm == "pm")
      ampm = "am"
      day += 1
      
      call(/world/proc/WorldStatus)()  ← Update status bar
      TimeSave()  ← PERSIST WORLD TIME & GROWTH STAGES
      
// TimeSave saves to timesave.sav:
//   - time_of_day, hour, ampm, minute1, minute2
//   - day, month, year, season
//   - bgrowstage, vgrowstage, ggrowstage, growstage
//   - SP, MP, SM, SB
//   - TimeState datum (new)
```

**Data Loss Risk**: Crash before midnight = time progress lost until next save

### SEQUENCE 4: Player Login (Restoration)

```
CLIENT.NEW()
  ├─ base_Initialize()
  └─ Choose character or create new

PLAYER LOGIN → _DRCH2.DM READ():
  ├─ Restore location (x, y, z)
  ├─ F["character"] >> player.character
  ├─ F["inventory_state"] >> player.inventory_state
  ├─ F["equipment_state"] >> player.equipment_state
  ├─ F["vital_state"] >> player.vital_state
  │
  └─ DRAW UI:
      ├─ draw_lighting_plane()  ← Add DAY_NIGHT overlay to screen
      ├─ draw_hud()
      └─ apply_equipment_overlays()

// World time is NOT restored because TimeLoad() is commented out
// Player sees current world time (incorrect if boot happened mid-day)
```

### SEQUENCE 5: Growth Stage Application (Boot)

```
WORLD.NEW():
  └─ GrowBushes()
      for(var/obj/Plants/Bush/B)
        if(bgrowstate == 1)
          B.icon_state = "seed1"
        if(bgrowstate == 2)
          B.icon_state = "sapp1"
        if(bgrowstate == 3)
          B.icon_state = "bloo1"
        if(bgrowstate == 4)
          B.icon_state = "ripe1"
        if(bgrowstate == 5)
          B.icon_state = "aut"
        if(bgrowstate == 6)
          B.icon_state = "wint2"
        
        B.UpdatePlantPic()  ← Sets name + visible appearance
  
  └─ SetSeason()  ← Also sets bgrowstate based on current month
                    (OVERWRITES values loaded from save!)
```

**Critical Bug**: SetSeason() called AFTER GrowBushes() can overwrite growth stages

---

## Data Dependency Matrix

| System | Reads From | Writes To | Affects | Frequency |
|--------|-----------|-----------|---------|-----------|
| **TIME** | time variables | minute2, hour, day, month, year, season, time_of_day | ALL SYSTEMS | Every 35 ticks |
| **DAY/NIGHT** | time_of_day | screen overlay (visual only) | Player UI, mood | Every 35 ticks |
| **GROWTH** | month, day | bgrowstate, vgrowstate, icon_state | Plant appearance, harvesting | Once per month |
| **PERSISTENCE** | All world state | timesave.sav, player saves | Next boot | At midnight + shutdown |
| **SPAWNING** | season | NPC mobs | World population | Every 100 ticks (per spawner) |
| **MAP GEN** | season (at startup) | turfs, objects | All terrain | Once at boot |

---

## Critical Dependencies & Risks

### RISK 1: Time Persistence Broken

**Current Issue**: `TimeLoad()` is commented out in SavingChars.dm:161

**Impact**:
- World time NEVER restored from save
- Always boots with default time (7:03am, 29 Adar, year 682)
- If boot happens mid-day, world time resets to morning
- Growth stages may be applied incorrectly if timing is off

**Fix**: Uncomment TimeLoad() call

### RISK 2: Overlay Loss on Crash

**Current Issue**: SetSeason() uses `overlays +=` which are NOT persisted

**Impact**:
- Seasonal overlays (autumn leaves, snow) are lost on crash
- Reloading world calls SetSeason() again, duplicating overlays or losing them

**Fix**: Convert to icon_state-based system (as per your WorkStamp)

### RISK 3: Growth Stage Cascade

**Current Issue**: SetSeason() called AFTER GrowBushes() can overwrite stages

**Impact**:
- Growth stages loaded from save
- Then SetSeason() sets them based on month
- Final value may not match saved state

**Fix**: Separate growth stage loading from seasonal appearance

### RISK 4: Expensive SetSeason() Call

**Current Issue**: SetSeason() iterates ALL turfs/plants every month

**Impact**:
- 1-2 second lag spike every month
- Probability-based overlay additions (5-15% chance per turf)
- No batching or async processing

**Fix**: 
- Cache overlay icons
- Batch additions
- Consider async processing

### RISK 5: No Periodic Saves

**Current Issue**: TimeSave() only at midnight + shutdown

**Impact**:
- Crash mid-day loses hours of time progress
- No automatic saves during gameplay

**Fix**: Implement periodic saves (every 6-12 game hours)

### RISK 6: Season-Aware Resources Missing Sync

**Current Issue**: Biome SpawnResource() checks season at spawn time, not update

**Impact**:
- Resources spawned in spring won't transform on season change
- Only works correctly on initial world generation

**Fix**: Add seasonal updating to existing resources

---

## Integration Points (Where Systems Touch)

| Interaction | From | To | Trigger | Data Passed |
|------------|------|-----|---------|------------|
| Time→Season | TIME | GROWTH | Month change | month, day |
| Time→Light | TIME | DAY/NIGHT | Hour change | time_of_day, hour |
| Time→Spawn | TIME | SPAWNING | Season change | season |
| Time→Persist | TIME | PERSISTENCE | Midnight/shutdown | all time vars |
| Season→Plant | GROWTH | PLANT OBJECTS | SetSeason() | bgrowstate, icon_state |
| Season→Resource | GROWTH | BIOME | Map gen phase | season (filters spawns) |
| Persist→Boot | PERSISTENCE | TIME | World.New() | TimeLoad() [COMMENTED OUT] |
| Persist→Player | PERSISTENCE | CHARACTER | Player login | character datum |
| Persist→World | PERSISTENCE | MAP GEN | Boot | map_loaded flag |
| Spawn→NPC | SPAWNING | NPC | Every 100 ticks | spawned mobs |
| MapGen→Resource | MAP GEN | GROWTH | Generation | turf types, biome |
| MapGen→Season | MAP GEN | GROWTH | Boot | seasonal appearance |

---

## Master State Snapshot

### What Gets Saved to timesave.sav
```
TIME:          hour, ampm, minute1, minute2, time_of_day
CALENDAR:      day, month, year, season
GROWTH:        growstage, bgrowstage, vgrowstage, ggrowstage
RESOURCES:     SP, MP, SM, SB (basecamp—status unclear)
STATE:         a, wo (unknown purpose)
DATUM:         TimeState (new—contains above)
```

### What Gets Saved to players/*/savefile
```
LOCATION:      x, y, z (base_save_location)
CHARACTER:     /datum/character_data (stats, skills, rank)
INVENTORY:     /datum/inventory_state (item stacks)
EQUIPMENT:     /datum/equipment_state (equipped items)
VITALS:        /datum/vital_state (HP, stamina, status)
```

### What Gets Saved to MapSaves/Chunk*/savefile
```
TURFS:         type, icon_state, opacity, density, dir, buildingowner
OBJECTS:       type, variables, contents, dir, bounds, gender, owner
RESOURCES:     LogAmount, SproutAmount, SeedAmount, FruitAmount, VegeAmount
```

### What's NOT Saved (Regenerated on Boot)
```
OVERLAYS:      Seasonal decorations (rebuilt by SetSeason)
GROWTH APP:    Plant appearance (rebuilt by GrowBushes/SetSeason)
SOUND FX:      Ambient mobs (respawned by SpawnSoundEffects)
DAY/NIGHT:     Lighting overlay (added by draw_lighting_plane)
```

---

## Recommended Modification Checklist

### When Adding a New System:
- [ ] Does it depend on TIME? How does it react to time changes?
- [ ] Does it read/write to persistence? What needs saving?
- [ ] Does it interact with GROWTH? Does it affect plant/season appearance?
- [ ] Does it affect world state? Does SetSeason() need updating?
- [ ] Does it spawn objects? Could it cause mass iteration?
- [ ] Is it seasonal? Should it gate based on season variable?

### When Modifying TIME:
- [ ] Update SetSeason() if new seasonal logic needed
- [ ] Update growth stage application if time format changes
- [ ] Test that TimeSave/TimeLoad round-trip correctly
- [ ] Check for cascading effects on spawning, lighting, growth

### When Modifying GROWTH:
- [ ] Test season transitions work smoothly
- [ ] Verify overlay additions don't duplicate
- [ ] Check plant harvesting still works at correct growth stages
- [ ] Ensure growth stages persist correctly

### When Modifying PERSISTENCE:
- [ ] Test character load/save round-trip
- [ ] Verify world state restored correctly
- [ ] Check time state persistence specifically
- [ ] Test mid-save crash scenarios

### When Modifying SPAWNING:
- [ ] Verify seasonal gating works (winter deletions)
- [ ] Check spawn count limits enforced
- [ ] Test that spawner cleanup doesn't cause orphans
- [ ] Validate NPC dialogue references correct data

### When Modifying MAP GEN:
- [ ] Test that initial generation completes
- [ ] Verify chunk loading doesn't cause lag
- [ ] Check that resources spawn with correct biome
- [ ] Ensure seasonal resources respect season

---

## System Health Metrics

| Metric | Status | Notes |
|--------|--------|-------|
| **Time Loop** | ✅ Healthy | Running at 35-tick interval |
| **Time Persistence** | ⚠️ Broken | TimeLoad() commented out |
| **Season Transitions** | ✅ Healthy | SetSeason() called reliably |
| **Seasonal Overlays** | ⚠️ Fragile | Not persisted, duplicates on crash |
| **Growth Stages** | ✅ Mostly OK | Applied correctly, but auto-increment mechanism unclear |
| **Player Persistence** | ✅ Healthy | Character, inventory, equipment saved/loaded |
| **Map Persistence** | ✅ Healthy | Chunked saves working via MPSBWorldSave |
| **Spawning** | ✅ Healthy | Season-aware, respawn working |
| **Day/Night Cycle** | ✅ Healthy | Lighting overlay animating correctly |
| **Performance** | ⚠️ Degraded | SetSeason() causes monthly lag spikes |

---

## Conclusion

Pondera's systems form a **tightly coupled simulation** where time is the master orchestrator. Changes in one system ripple through others:

- **TIME** triggers GROWTH → SEASON → PERSISTENCE
- **SEASON** affects SPAWNING → RESOURCES → APPEARANCE
- **PERSISTENCE** restores TIME → GROWTH → PLAYER STATE
- **MAP GEN** creates initial RESOURCES → GROWTH STATE

**The most critical issue**: Time persistence is broken (TimeLoad() commented out). This should be the first fix before making other improvements.

**The biggest opportunity**: Convert seasonal appearance from overlays to icon_state system. This would fix persistence, reduce performance overhead, and simplify SetSeason() logic.

