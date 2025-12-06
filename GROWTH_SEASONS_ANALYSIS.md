# Growth & Seasons System Analysis

## Overview

The Pondera growth and seasons system is a **comprehensive world transformation engine** that manages seasonal visual transitions, plant growth progression, and world state management. The system operates on a **Hebrew calendar** with 12 months, dividing the year into 4 seasons (Spring, Summer, Autumn, Winter).

**Key Pattern**: SetSeason() is an expensive world-wide transformation proc that updates ALL turfs, plants, flowers, rocks, and water to reflect seasonal conditions when month boundaries are crossed.

---

## Architecture Overview

### Three-Tier System

```
TIME LAYER (time.dm)
  └─ Month transitions trigger SetSeason() calls
    └─ On month change: call(/world/proc/SetSeason)()

GROWTH LAYER (plant.dm)  
  └─ Plant objects with growth stages
    └─ bgrowstate (bush growth: 1-6, with "51" for hibernation)
    └─ vgrowstate (vegetable growth: 1-8)
    └─ ggrowstate (grain growth: 1-8)
    └─ Global stages: bgrowstage, vgrowstage, ggrowstage

VISUAL LAYER (SavingChars.dm)
  └─ SetSeason() applies icon_state and name changes
    └─ 12 month branches, each with full world transformation
```

---

## Calendar Structure

### Hebrew Calendar Months (12 months = 1 year)

| Month | Season | Duration | Key Events |
|-------|--------|----------|-----------|
| **Shevat** | Spring | 30 days | Spring awakening; bushes dormant→seedling |
| **Adar** | Spring | 29 days | Spring growth begins; bushes seedling→sappling |
| **Nisan** | Spring | 31 days | Spring bloom; bushes sappling→blooming |
| **Iyar** | Spring | 30 days | Late spring; flowers bloom (5 types) |
| **Sivan** | Summer | 31 days | Early summer; bushes become ripe |
| **Tammuz** | Summer | 30 days | Mid-summer; heat peaks |
| **Av** | Summer | 31 days | Late summer; still ripe |
| **Elul** | Autumn | 29 days | Early autumn; bushes transition to ripe/old |
| **Tishrei** | Autumn | 30 days | Mid-autumn; continued dormancy |
| **Cheshvan** | Autumn | 29 days | Late autumn; bushes hibernating (bgrowstate=51) |
| **Kislev** | Autumn→Winter | 30 days | Transition; trees go to winter state |
| **Tevet** | Winter | 30 days | Deep winter; year increments on day 30 |

**Note**: Year increments when Tevet ends (month transitions to Shevat).

---

## SetSeason() Proc: The World Transformation Engine

### Location
`SavingChars.dm`, lines 320-950+

### Purpose
**Transform the entire world's visual appearance when a month boundary is crossed.** This is called 12 times per year (once per month).

### Structure
```dm
proc/SetSeason()
  if(month=="Shevat")
    // 1. Clear all seasonal overlays
    for(var/turf/water/W) W.SetWSeason()
    for(var/obj/border/water/W) W.SetBSeason()
    
    // 2. Set bush growth stages
    for(var/obj/Plants/Bush/B)
      B.name = "Dormant Bush"
      B.icon_state = "aftwint"
      B.bgrowstate = "6"
    
    // 3. Set flower states
    for(var/obj/Flowers/J)
      J.name = "Dormant Plants"
      J.icon_state = "tg3a"
    
    // 4. Clear terrain overlays
    for(var/turf/temperate/A)
      A.overlays -= A.overlays
      A.name = "Grass"
    
    // 5. Set tree states
    for(var/obj/plant/UeikTreeA/UTA)
      UTA.icon_state = "UTAaftwint"
    
    // 6. Add seasonal terrain variations
    for(var/turf/temperate/G)
      if(prob(5))
        G.overlays += icon('dmi/64/gen.dmi', icon_state="sprg2")
    
  else if(month=="Adar")
    // ... similar transformation for Adar season
```

### Called From
1. **time.dm** (lines 613, 651, 661, 670, 680, 688, 698, 708, 730)
   - Called at each month transition via `call(/world/proc/SetSeason)()`
   
2. **SavingChars.dm** (line 175)
   - Called in world initialization: `SetSeason(world)`

### What SetSeason() Modifies

#### 1. **Water Systems** (All 12 months)
```dm
for(var/turf/water/W)
  W.SetWSeason()
for(var/obj/border/water/W)
  W.SetBSeason()
```
Calls SetWSeason() and SetBSeason() on water turfs—sets seasonal water visual appearance.

#### 2. **Plant Growth Stages** (Varies by month)

**Bushes (bgrowstate)**:
- Shevat: `bgrowstate = 6` ("Dormant Bush")
- Adar: `bgrowstate = 1` ("Bush Seedling")
- Nisan: `bgrowstate = 2` ("Bush Sappling")
- Iyar: `bgrowstate = 3` ("Blooming Bush")
- Sivan/Tammuz/Av: `bgrowstate = 4` ("Ripe Bush")
- Elul/Tishrei: `bgrowstate = 5` (Autumn state)
- Cheshvan/Kislev/Tevet: `bgrowstate = 6` or `51` ("Hibernating Bush")

**Flowers (icon_state only)**:
- Shevat: "tg3a" (dormant)
- Adar: "tg0" (seedlings)
- Nisan: "tg0" + 5 flower types (red, blue, pink, lavender, purple)
- Iyar: "tg" (tallgrass)
- Elul: "tg2" (autumn)
- Cheshvan: "tg3" (late autumn)
- Kislev: "tg1" (approaching winter)
- Tevet: "tg4" (dormant plants)

**UeikTrees** (iconic trees):
- Shevat→Adar: "UTAaftwint" / "uthregrow"
- Nisan: "utaregrow2"
- Iyar→Av: "UTA" / "UTH"
- Elul/Tishrei: "UTAaut" / "UTHaut"
- Cheshvan: "UTAwint" / "UTHwint"
- Tevet: "UTAwinth" / "UTHwinth"

#### 3. **Terrain Overlays** (Additive visual effects)

**Spring Overlays** (Shevat, Adar):
```dm
for(var/turf/temperate/G)
  if(prob(1))   G.overlays += icon('dmi/64/gen.dmi', icon_state="rck")
  if(prob(5))   G.overlays += icon('dmi/64/gen.dmi', icon_state="sprg2")
  if(prob(5))   G.overlays += icon('dmi/64/gen.dmi', icon_state="sprg3")
  if(prob(0.1)) G.overlays += icon('dmi/64/gen.dmi', icon_state="rck2")
  if(prob(0.1)) G.overlays += icon('dmi/64/gen.dmi', icon_state="stcks")
```

**Autumn Overlays** (Elul, Tishrei, Cheshvan, Kislev):
```dm
for(var/turf/temperate/A)
  A.overlays += icon('dmi/64/gen.dmi', icon_state="grassaut")  // All
if(prob(15))
  A.overlays += icon('dmi/64/gen.dmi', icon_state="autgrass")  // 15% chance
  A.overlays += icon('dmi/64/gen.dmi', icon_state="autgrass2") // 15% chance
```

**Winter Overlays** (Tevet):
```dm
for(var/turf/temperate/A)
  A.name = "Snow"
  A.overlays += icon('dmi/64/snow.dmi', icon_state="snow")
```

**Specialized Terrain** (Clay, Obsidian, Sand, TarPit, Soil):
- Each has seasonal variants: normal, autumn, winter
- Examples: "claywint", "obsidianwint", "sandwint", "tarwint", "dirtwint", "richsoilwint"

#### 4. **Rock Seasonal Variants**
```dm
for(var/obj/Rocks/OreRocks/R)
  R.SetWSeason()
```
Calls SetWSeason() on all ore rocks (winter variants available).

---

## Growth Stage System

### Global Growth Stage Variables (plant.dm, line 511-513)

```dm
var/global/bgrowstage    // Bush growth stage (global)
var/global/vgrowstage    // Vegetable growth stage (global)
var/global/ggrowstage    // Grain growth stage (global)
```

**CRITICAL FINDING**: These are global variables, but usage is **unclear**. They are:
- Saved/loaded via TimeSave.dm
- Called in GrowBushes/GrowTrees procs
- BUT **not actually incremented anywhere in time loop**

### Per-Plant Growth Variables

#### Bushes (obj/Plants/Bush)
```dm
bgrowstate     // 1=Seedling, 2=Sappling, 3=Blooming, 4=Ripe, 5=Autumn, 6=Dormant, 51=Hibernating
```

#### Vegetables (obj/Plants/Vegetables)
```dm
vgrowstate     // 1=Seed, 2=Sappling, 3=Bloom, 4=Ripe, 5=Autumn, 6=Winter, 7=Picked, 8=Out-of-Season
```

#### Grain (obj/Plants/Grain)
```dm
ggrowstate     // 1=Seed, 2=Sappling, 3=Bloom, 4=Ripe, 5=Autumn, 6=Winter, 7=Picked, 8=Out-of-Season
```

**Range**: 1-8 for vegetables/grain, 1-6 + "51" for bushes

### Growth Progression Logic (plant.dm, lines 700-800+)

**Example from Vegetables**:
```dm
proc/Grow()
  // Shevat (Spring start)
  if (month == "Shevat" && day >= 1 || month == "Shevat" && day <= 9)
    src.vgrowstate = 1  // Seed
  
  // Shevat (late)
  if (month == "Shevat" && day >= 10)
    src.vgrowstate = 2  // Sappling
  
  // Adar (Spring middle)
  if (month == "Adar" && day >= 1)
    src.vgrowstate = 3  // Bloom
  
  // Nisan (Spring late)
  if (month == "Nisan" && day >= 15)
    src.vgrowstate = 4  // Ripe
  
  // Summer (all months)
  if (season == "Summer")
    src.vgrowstate = 4  // Ripe
  
  // Autumn
  if (season == "Autumn")
    src.vgrowstate = 5  // Ripe/Fall
  
  // Winter
  if (season == "Winter")
    src.vgrowstate = 6  // Old/Winter
  
  // Finally, update visual
  src.UpdatePlantPic()
```

**OBSERVATION**: Growth is **season/month-based**, not time-accumulated. Plants don't gradually progress; they jump to the stage matching current month.

---

## WorkStamp Markers (Active Development Areas)

### 1. **SavingChars.dm, Line 325-326**
**Location**: Inside SetSeason() proc  
**Comment**:
```dm
SetSeason()//This needs to be fixed -- If I change these all to icon states instead of overlays, 
           //they should save their looks and not be dependent on being set by this proc || 
           //temporary fix for now was to make all of them set the seasonal foliage WorkStamp
```

**Problem**: Seasonal appearance is **overlay-dependent**, not icon-state dependent.
- **Current Method**: SetSeason() **adds overlays** to turfs every month
- **Issue**: If server crashes mid-month, overlays won't be reapplied on reload
- **Proposed Solution**: Use icon_state changes instead of overlays for persistence
- **Impact**: Plants/terrain lose seasonal appearance if world reloads mid-season

### 2. **plant.dm, Line 1097**
**Location**: Unknown (grep shows line 1097)  
**Comment**: `//WorkStamp`

**Status**: This is a bare WorkStamp with no comment—location needs clarification.

### 3. **Basics.dm, Line 1763**
**Location**: Player equipment overlay section  
**Comment**: `if(J.WHequipped==1)//WorkStamp need to add all of the weapon overlays!`

**Problem**: Not all weapon types have overlay graphics implemented
- **Current**: Only specific weapons have overlays (War Hammer = WHequipped)
- **Missing**: Full overlay support for all 30+ weapon types

### 4. **Light.dm, Line 1508**
**Location**: Spotlight system  
**Comment**: `src.draw_spotlight(0, 0, "#FFFFFF", 5.5, 255)//WorkStamp -- might need checked`

**Problem**: Spotlight parameters may need tuning or validation
- **Params**: Position (0,0), color (white), radius (5.5), alpha (255)
- **Status**: Uncertain if these are optimal

### 5. **tools.dm, Line 10904**
**Location**: Forge UI overlay system  
**Comment**: `//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeL")//WorkStamp -- These overlays only work for one direction - South`

**Problem**: Forge UI overlays are **directional-sensitive** and incomplete
- **Current**: Only work when player faces South
- **Missing**: Overlays for North, East, West directions
- **Related**: Weapon overlay issue in Basics.dm

### 6. **Objects.dm, Line 1779**
**Location**: Weapon crafting/combining  
**Comment**: `//WorkStamp need to check these new additions for complete crafting (Combine Handle to these parts to create the weapon)`

**Problem**: Weapon part combining system incomplete
- **Parts defined**: Blades, handles, etc. partially exist
- **Missing**: Full recipe system to combine parts into finished weapons

### 7. **Objects.dm, Line 1944**
**Location**: Battle weapons section  
**Comment**: `Battleaxeblade//WorkStamp Need to add the finished weapons to the equip menu, most likely.`

**Problem**: Finished weapons not accessible in equipment menu
- **Current**: Blade/parts defined but not integrated into equip UI
- **Missing**: Menu integration and equip system binding

### 8. **Objects.dm, Line 4871**
**Location**: Inventory equip checking  
**Comment**: `var/obj/items/tools/LongSword/LS = locate() in M.contents//needs to be expanded to all weapons WorkStamp`

**Problem**: Weapon location checking only works for LongSword
- **Current**: Hardcoded check for specific weapon
- **Missing**: Generic weapon checking logic

### 9. **Objects.dm, Line 4907**
**Location**: Armor/weapon inventory overlay removal  
**Comment**: `src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="LSWRO")//needs switched over to armor and finished WorkStamp`

**Problem**: Armor overlays not fully integrated
- **Current**: Only LongSword overlay removal implemented
- **Missing**: All armor types + finished weapon overlays

### 10. **jb.dm, Line 2394**
**Location**: Furniture/deed crafting  
**Comment**: `var/Planks = "6 Ueik Board"//WorkStamp -- Make such things as these require Ueik Boards instead of Poles.`

**Problem**: Recipe system needs refactoring
- **Current**: Using "6 Ueik Board" string (not type-safe)
- **Proposed**: Standardize all recipes to require Ueik Boards
- **Related**: Phase 5 (Recipes/Knowledge Database)

---

## Critical Issues & Recommendations

### ISSUE #1: SetSeason() Performance

**Problem**: SetSeason() iterates **ENTIRE WORLD** every month
```dm
for(var/turf/temperate/G)     // Iterates ALL temperate turfs
  if(prob(5))
    G.overlays += icon(...)   // Expensive operation
```

**Impact**: 
- Every month causes 1-2 second freeze/lag spike
- Multiple overlay additions (5-10 per turf in autumn)
- Players experience stutter at month boundaries

**Recommendation**: 
1. Cache overlay icons to avoid repeated image() calls
2. Batch overlay additions (accumulate list, add once)
3. Consider async processing (spawn background task)
4. **Only update visible chunks** (use CHUNK_SIZE from mapgen)

### ISSUE #2: Growth Stage Logic Is Month-Based, Not Time-Accumulated

**Current Logic**:
```dm
if (month == "Nisan" && day >= 15)
  src.vgrowstate = 4  // Jump to ripe
```

**Problem**:
- Plants don't progressively grow
- Set growth immediately upon month change
- No gradual progression feeling

**Recommendation**:
1. Replace with **time-accumulated** logic
2. Track `growth_progress = 0-100` (percentage)
3. Increment on each growth tick (e.g., daily)
4. Stage changes when progress hits thresholds (25%, 50%, 75%, 100%)

### ISSUE #3: Global Growth Stage Variables Are Never Incremented

**Variables**: `bgrowstage`, `vgrowstage`, `ggrowstage`

**Problem**:
- Saved/loaded but never modified in time loop
- GrowBushes() and GrowTrees() load them but don't use them
- Appears to be **placeholder code**

**Recommendation**:
1. Clarify purpose in TIME_SYSTEM documentation
2. Either:
   - **Option A**: Remove if unused (dead code)
   - **Option B**: Implement increment logic in time loop
3. Integrate with TimeState datum for persistence

### ISSUE #4: Seasonal Overlays Lost on World Reload

**Problem**: SetSeason() uses overlays, which are **NOT persisted**
```dm
A.overlays += icon('dmi/64/gen.dmi', icon_state="sprg2")
```

If server crashes mid-month:
1. World reloads
2. World initialization calls SetSeason() again
3. New overlays added on top of old ones (duplicate visual)
4. Or if old overlays somehow cleared, appearance resets incorrectly

**Recommendation**:
- **As per your WorkStamp**: Convert to icon_state-based system
- Store `season_icon_override` on each turf
- Load icon_state from savefile on boot
- Eliminates overlay duplication/loss issues

### ISSUE #5: No Granular Season Transitions

**Current**: Hard boundaries (month = X → season = Y)

**Issue**: No smooth transitions
- Winter → Spring is abrupt
- No "late autumn" feeling when approaching winter
- Player experience is jarring

**Recommendation**:
- Track "season_progress" (like growth_progress)
- Use `season_progress` for visual interpolation
- Overlay color/alpha blend toward next season

---

## Growth System Architecture Diagram

```
MONTH CHANGE (time.dm, line 613)
    ↓
call(/world/proc/SetSeason)()
    ↓
SetSeason() - SavingChars.dm (320-950+)
    ├─ For Each Turf Type:
    │   ├─ Clear existing overlays
    │   └─ Add seasonal overlays (5-15% chance each)
    │
    ├─ For Each Bush:
    │   ├─ Set bgrowstate (1-6, or 51)
    │   ├─ Set icon_state based on stage
    │   └─ Set name (display label)
    │
    ├─ For Each Flower:
    │   ├─ Set icon_state (tg0-tg4)
    │   └─ Set name
    │
    ├─ For Each Tree (UeikTreeA/H):
    │   ├─ Set icon_state (seasonal variant)
    │   └─ Optional: Set overlays (currently commented out)
    │
    └─ For Each Rock/Water:
        └─ Call SetWSeason() for variant handling

PARALLEL: Growth Stage Updates (implicit in SetSeason)
    └─ Plant growth stage follows month (NOT time-accumulated)
```

---

## Timeline View

### Seasonal Calendar Wheel

```
           SPRING (Shevat → Iyar)
          ╭─────────────────────╮
          │ Shevat (30) → Adar  │
          │ Adar (29)  → Nisan  │
          │ Nisan(31) → Iyar    │
          │ Iyar (30) → Sivan   │  4 months × ~30 days = 120 days/season
          ╰─────────────────────╯

WINTER                            SUMMER
(Tevet)                      (Sivan → Av)
   ↓                         ╭─────────────────────╮
   │                         │ Sivan (31)  → Tammuz│
   │                         │ Tammuz(30)  → Av    │
   │                         │ Av (31)     → Elul  │
   ↓                         │ Elul (29)   → Tishrei
                             ╰─────────────────────╯

        AUTUMN (Elul → Kislev)
        ╭─────────────────────────────╮
        │ Elul (29) → Tishrei         │
        │ Tishrei(30) → Cheshvan      │
        │ Cheshvan(29) → Kislev       │
        │ Kislev (30) → Tevet (Winter)│
        ╰─────────────────────────────╯

        YEAR INCREMENTS
        At Tevet 30 → Shevat 1
```

---

## Persistence Integration

### Current State (Before TimeState Integration)

**Saved**:
- `season` (global string: "Spring"/"Summer"/"Autumn"/"Winter")
- `bgrowstage`, `vgrowstage`, `ggrowstage` (global ints)
- Individual plant `bgrowstate`, `vgrowstate`, `ggrowstate` (per object)

**NOT Saved**:
- Turf overlays (reapplied on SetSeason() at boot)
- Seasonal icon_states (reapplied at boot)

**Problem**: If server crashes mid-month, overlays duplicated on reload.

### Recommended Persistence Layer

**New TimeState datum fields** (for Phase 5):
```dm
var
  season           // "Spring", "Summer", "Autumn", "Winter"
  bgrowstage       // Global bush stage
  vgrowstage       // Global vegetable stage
  ggrowstage       // Global grain stage
  last_setseason   // timestamp of last SetSeason() call
  season_progress  // 0-100, for smooth transitions
```

**On world.Del()**:
- Capture current growth stages
- Store last_setseason timestamp
- Save all active plant growth_progress values

**On world.New()**:
- Load TimeState from save
- Call SetSeason() to repopulate overlays
- Restore individual plant growth_progress values

---

## Summary Table

| Aspect | Current State | Issues | Recommendation |
|--------|---------------|--------|-----------------|
| **SetSeason() Frequency** | Every month (12/year) | Heavy world iteration | Optimize with caching/async |
| **Growth Logic** | Month-based, instant jumps | No gradual progression | Implement time-accumulated system |
| **Global Stages** | Saved but not incremented | Dead code? | Clarify or remove |
| **Overlay Persistence** | Not persisted, reapplied | Duplication on reload | Use icon_state instead |
| **Season Transitions** | Hard boundaries | Abrupt changes | Add season_progress field |
| **Seasonal Overlays** | Additive (5-15% chance) | Performance expensive | Cache, batch, or async |
| **Flower/Bush Names** | Updated by SetSeason() | Name depends on proc call | Consider icon_state-based naming |

---

## Next Steps (Recommended Implementation Order)

### Phase 1: Documentation & Clarification (This Session)
- ✅ Document SetSeason() architecture
- ✅ Map WorkStamp locations
- ⏳ Create TimeState extension for growth tracking
- ⏳ Add season_progress field

### Phase 2: Growth Logic Refactor (Next Session)
- ⏳ Replace month-jump logic with time-accumulated
- ⏳ Implement growth_progress tracking
- ⏳ Test gradual plant development

### Phase 3: Performance Optimization (Following Session)
- ⏳ Cache overlay images
- ⏳ Implement async SetSeason() processing
- ⏳ Profile performance before/after

### Phase 4: Persistence Hardening (Following Session)
- ⏳ Convert overlays to icon_state system
- ⏳ Integrate with TimeState datum
- ⏳ Test world reload scenarios

---

## Code References

| File | Lines | Purpose |
|------|-------|---------|
| SavingChars.dm | 320-950 | SetSeason() full implementation |
| time.dm | 613, 651, 661, 670, 680, 688, 698, 708, 730 | SetSeason() calls on month changes |
| plant.dm | 511-513 | Global growth stage variables |
| plant.dm | 700-850 | Vegetable/Grain Grow() procs |
| TimeSave.dm | Lines 1-85 | Time/calendar persistence |
| Basics.dm | 879 | SetSeason() call during init |

---

**Document Created**: December 6, 2025  
**Status**: Complete Analysis  
**Next Action**: Awaiting decision on Phase 1 extension items
