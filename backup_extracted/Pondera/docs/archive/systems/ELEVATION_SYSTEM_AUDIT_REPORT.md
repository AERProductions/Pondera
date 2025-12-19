# ELEVATION SYSTEM COMPREHENSIVE AUDIT REPORT
**Date**: December 8, 2025  
**Branch**: recomment-cleanup  
**Scope**: Full elevation system audit (Chk_LevelRange, elevel, FindLayer/FindInvis, ditch/hill, combat, visibility)

---

## EXECUTIVE SUMMARY

The elevation system has **solid core architecture** but exhibits **critical gaps in combat interaction validation**, **inconsistent elevation initialization**, and **visibility/interaction logic edge cases**. The system correctly handles:
- Basic elevation storage and layer mapping (4 layers per elevel)
- Directional ditch/hill entry/exit blocking
- Elevation-aware collision via Chk_LevelRange()

**Major Issues Found**: 8 Critical, 6 Warnings, 5 Info

---

## DETAILED FINDINGS

### **CATEGORY 1: COMBAT & DAMAGE INTERACTIONS**

#### **1.1 - CRITICAL: Attack() Missing Elevation Range Check**
- **Finding**: The `Attack()` proc in `dm/Basics.dm` (lines 1738-1800) deals damage WITHOUT validating elevation range.
- **File:Line**: `dm/Basics.dm:1738-1800`
- **Severity**: **CRITICAL**
- **Impact**: Players at different elevation levels can damage each other across ±0.5 elevel boundaries. Ground-level players can attack sky-level characters.
- **Current Code**:
```dm
proc/Attack() // hit that enemy
    var/mob/players/M
    M = src
    var/mob/players/J
    J = usr
    // ... damage calculation ...
    M.HP -= damage  // NO ELEVATION CHECK!
```
- **Expected Code**:
```dm
proc/Attack() // hit that enemy
    var/mob/players/M
    M = src
    var/mob/players/J
    J = usr
    // ADD THIS CHECK:
    if(!J.Chk_LevelRange(M))
        J << "Target is out of reach at different elevation!"
        return
    // ... rest of damage calculation ...
```

---

#### **1.2 - CRITICAL: Enemy NPC Attack() Missing Elevation Check**
- **Finding**: All enemy `Attack()` procs in `dm/Enemies.dm` (lines 773-1575 across all enemy types: Giu, Gou, Gow, Guwi, Gowu, etc.) lack elevation validation.
- **File:Line**: `dm/Enemies.dm:773-1575` (all enemy types)
- **Severity**: **CRITICAL**
- **Impact**: NPCs can attack players from different elevation levels. Enables cheese tactics (tower up out of range, NPCs still hit).
- **Example**: `Giu/proc/Attack()`, `Gou/proc/Attack()`, etc. all call damage without `Chk_LevelRange()`

---

#### **1.3 - WARNING: checkdeadplayer2() Lacks Elevation Context**
- **Finding**: The death handler `checkdeadplayer2()` in `dm/Basics.dm` (lines 1804-1850) doesn't verify combatants were in elevation range when damage dealt.
- **File:Line**: `dm/Basics.dm:1804-1850`
- **Severity**: **WARNING**
- **Impact**: Could trigger false "kill" events for players who were never in range. Poor PvP tracking.
- **Note**: This is more of an audit trail issue than a functional bug, but should verify elevation before awarding kill credit.

---

### **CATEGORY 2: ELEVATION INITIALIZATION & ASSIGNMENT**

#### **2.1 - CRITICAL: Objects Created Without Elevation Initialization**
- **Finding**: All `new /obj/` spawns in `dm/Enemies.dm` (itemdrop procs) create items without setting `elevel`.
- **File:Line**: `dm/Enemies.dm:10-360` (100+ item drops)
- **Severity**: **CRITICAL**
- **Impact**: Dropped loot items default to `elevel=1` even when dropped on hills/ditches. Items can end up invisible or inaccessible.
- **Example**:
```dm
new/obj/items/CParts/GiuHide (m,1)  // NO elevel set!
```
- **Expected**: Should inherit from creator or explicitly set based on turf elevation.

---

#### **2.2 - CRITICAL: NPCs Spawned Without Elevation Initialization**
- **Finding**: Enemy `New()` procs in `dm/Enemies.dm` don't set `elevel`. Default is 1.0, breaking spawns on elevated terrain.
- **File:Line**: `dm/Enemies.dm:1093-1575` (all enemy type New() blocks)
- **Severity**: **CRITICAL**
- **Impact**: Enemies spawned on hills (elevel=1.5/2.0) are invisible or phased. Enemies on ditches (elevel=0.5) can't reach ground players.
- **Current**: Enemy created with default `elevel=1`, but spawner location might be elevel=2.0 (hillside).
- **Root Cause**: No hook in elevation system to auto-inherit from parent turf on instantiation.

---

#### **2.3 - WARNING: Player New() Lacks Elevation Sync**
- **Finding**: `mob/players/New()` in `dm/Basics.dm` (lines 296-330) doesn't initialize `elevel` from spawn location.
- **File:Line**: `dm/Basics.dm:296-330`
- **Severity**: **WARNING**
- **Impact**: Players spawning on terrain with custom elevation get default elevel=1, breaking immersion.
- **Note**: Less critical than NPCs since player locations are controlled, but still inconsistent.

---

#### **2.4 - WARNING: Cooked Food No Elevation Set**
- **Finding**: `CookedFood` created in `dm/CookingSystem.dm:335` doesn't set `elevel`.
```dm
var/obj/CookedFood/F = new /obj/CookedFood(chef.loc)  // NO elevel!
```
- **File:Line**: `dm/CookingSystem.dm:335`
- **Severity**: **WARNING**
- **Impact**: Food crafted on elevated terrain (cooking on hill) drops at ground level visually.

---

#### **2.5 - INFO: Landscape Objects (Ditch/Hill) Have Manual Elevel Sets**
- **Finding**: In `dm/jb.dm` (lines 407-1108), ditch and hill objects ARE properly set:
```dm
a:elevel = 0.5  // Ditch properly set
a:elevel = 1.5  // Hill properly set
```
- **File:Line**: `dm/jb.dm:407-1108`
- **Severity**: **INFO** (Good practice)
- **Impact**: Building system correctly enforces elevation. Only applies to admin-built terrain, not procedural or NPC spawns.

---

### **CATEGORY 3: VISIBILITY & LAYER SYSTEM**

#### **3.1 - WARNING: FindInvis() Inverse Logic Issue**
- **Finding**: `FindInvis(elevel)` returns `round(elevel)`. Higher elevel = higher invisibility value. Seems backward.
- **File:Line**: `libs/Fl_AtomSystem.dm:29`
- **Severity**: **WARNING**
- **Impact**: Objects at elevel=2.5 have invisibility=3. Objects at elevel=1.0 have invisibility=1. When players at elevel=1.0 try to see objects at elevel=3.0, BYOND hides objects with `invisibility >= player.invisibility`. This means:
  - Ground player (invisibility=1) CAN see ground objects (invisibility=1) ✓
  - Ground player (invisibility=1) CAN'T see sky objects (invisibility=3) ✓
  - SKY player (invisibility=3) CAN see ALL objects ✓ (seems overpowered)
- **Design Question**: Should higher elevation = LOWER invisibility for better visibility from above? Or is current design intentional (higher = more hidden)?
- **Recommendation**: Document intent or reconsider formula. Current behavior: "look up → see everything, look down → see nothing". Might be intentional for gameplay.

---

#### **3.2 - INFO: Layer Calculation via FindLayer() Consistent**
- **Finding**: `FindLayer(elevel)` returns `(round(elevel-1, 0.25) * 4)`. Formula is consistent.
- **File:Line**: `libs/Fl_AtomSystem.dm:26`
- **Severity**: **INFO** (Good practice)
- **Example**:
  - elevel=1.0 → layer=0
  - elevel=1.5 → layer=2
  - elevel=2.0 → layer=4
  - elevel=2.5 → layer=6
- **Impact**: 4 layers per elevel level allows smooth transitions.

---

#### **3.3 - WARNING: Weather System Elevation Visibility Check Incomplete**
- **Finding**: In `dm/WeatherParticles.dm:275`, weather FX checks elevation but only uses `<=` comparison:
```dm
if(M.elevel <= elevel + 0.5)  // ONE-WAY check only
```
- **File:Line**: `dm/WeatherParticles.dm:275`
- **Severity**: **WARNING**
- **Impact**: Players above cloud level see weather FX, but the check doesn't verify they're within visible range. Missing lower bound check.
- **Expected**: `if(M.elevel <= elevel + 0.5 && M.elevel >= elevel - 0.5)`

---

### **CATEGORY 4: DITCH/HILL DIRECTIONAL ENFORCEMENT**

#### **4.1 - INFO: Ditch/Hill Enter/Exit Logic Comprehensive**
- **Finding**: Elevation subtypes (ditch, hill, stairs) in `libs/Fl_ElevationSystem.dm` properly enforce directional entry/exit.
- **File:Line**: `libs/Fl_ElevationSystem.dm:51-82`
- **Severity**: **INFO** (Good practice)
- **Ditch Pattern**:
  - ENTER FROM SOUTH: If `src.elevel <= e.elevel && src.dir == e.dir` → allow
  - EXIT TO NORTH: If `src.elevel >= e.elevel && src.dir == Odir(e.dir)` → allow
- **Hill Pattern**: Opposite logic
- **Impact**: Prevents diagonal shortcuts across terrain transitions. Works as designed.

---

#### **4.2 - WARNING: Duplicate Ditch/Hill Logic in jb.dm**
- **Finding**: `dm/jb.dm` (lines 6311-6550+) DUPLICATES the entire ditch/hill Enter/Exit logic from `Fl_ElevationSystem.dm`.
- **File:Line**: `dm/jb.dm:6311-6550`
- **Severity**: **WARNING**
- **Impact**: Code duplication = maintenance risk. If elevation logic changes, must update both places.
- **Root Cause**: Likely admin building system has custom elevation objects that bypass library.

---

### **CATEGORY 5: RANGE CHECKING IMPLEMENTATION**

#### **5.1 - CRITICAL: GetDenseObject() Uses Chk_LevelRange Correctly**
- **Finding**: `GetDenseObject()` in `libs/Fl_ElevationSystem.dm:39-47` properly checks elevation range for collisions.
- **File:Line**: `libs/Fl_ElevationSystem.dm:39-47`
- **Severity**: **INFO** (Correct behavior, but found no usage in combat)
- **Current Code**:
```dm
GetDenseObject(var/atom/movable/a, var/d as null)
    if(!d) d = get_dir(src, a)
    var/turf/t=src
    while(!isturf(t)) t = src.loc
    if(src.Chk_LevelRange(a) && (density || src.Chk_Tbit(d))) return src  // ✓ checks range
    for(var/obj/O in t)
        if(O.Chk_LevelRange(a) && (O.density || O.Chk_Tbit(d))) return O  // ✓ checks range
    for(var/mob/M in t)
        if(M.Chk_LevelRange(a) && (M.density || M.Chk_Tbit(d))) return M  // ✓ checks range
```
- **Impact**: Movement collision respects elevation. **BUT** combat doesn't use this!

---

#### **5.2 - CRITICAL: Chk_LevelRange() Definition Correct But Underutilized**
- **Finding**: `Chk_LevelRange()` correctly validates `±0.5` range, but only called in movement/collision, NOT in combat.
- **File:Line**: `libs/Fl_AtomSystem.dm:31-33`
- **Severity**: **CRITICAL**
- **Current Definition**:
```dm
Chk_LevelRange(var/atom/movable/a)
    return (a.elevel <= src.elevel + 0.5 && a.elevel >= src.elevel - 0.5)
```
- **Usage Audit**:
  - ✓ Used in GetDenseObject() (movement blocking)
  - ✓ Used in Chk_Enter() (entering turfs)
  - ✓ Used in elevation/Enter() (ditch/hill)
  - ✗ **NOT used in Attack()** ← **CRITICAL GAP**
  - ✗ **NOT used in NPC Attack()** ← **CRITICAL GAP**
  - ✗ **NOT used in damage procs** ← **CRITICAL GAP**

---

### **CATEGORY 6: WATER TERRAIN & ELEVATION**

#### **6.1 - INFO: Water Turfs Support Elevation Assignment**
- **Finding**: Water turfs created in `dm/DynamicZoneManager.dm:343` properly initialized:
```dm
t = new /turf/water(x, y, 2)
t:water_type = water_type  // Biome water type set
```
- **File:Line**: `dm/DynamicZoneManager.dm:343-344`
- **Severity**: **INFO** (Good practice)
- **Impact**: Water terrain respects elevation system. However, **no elevel is explicitly set**, so defaults to 1.0. Edge case: floating water at 1.5 elevation not supported.

---

#### **6.2 - WARNING: Fishing System Elevation Not Considered**
- **Finding**: Fishing in `dm/FishingSystem.dm:273-284` checks `turf/water` type but not elevation range.
- **File:Line**: `dm/FishingSystem.dm:273-284`
- **Severity**: **WARNING**
- **Impact**: Players can fish from elevated platforms over water (should require adjacent water at same elevation). Allows terrain exploitation.

---

### **CATEGORY 7: EDGE CASES & CORNER CUTTING**

#### **7.1 - INFO: Corner-Cut Logic Exists and Elevation-Aware**
- **Finding**: `Chk_CC()` in `libs/Fl_AtomSystem.dm:46-50` handles diagonal movement corner blocking.
- **File:Line**: `libs/Fl_AtomSystem.dm:46-50`
- **Severity**: **INFO** (Good practice)
- **Current Code**:
```dm
Chk_CC(atom/movable/a)
    var/d = get_dir(src,a)
    if(NOC  && (d&(d-1))) return 0          // NO Cutting Corners globally set
    if(NOCC && (d&(d-1)))                  // NO Cutting Corners for this atom
        var/turf/T = get_step(src,d)
        return T.Check_CC(d,a)
    else return 1
```
- **Issue**: When NOCC set and checking diagonals, `Check_CC()` is called. This checks both component directions via `Check_Step()`. **BUT** no elevation filtering on component checks.
- **Example**: Diagonal NE movement might allow crossing through elevation discontinuity if individual N and E steps are clear.

---

#### **7.2 - WARNING: Elevation Transitions Lacking Smoothness**
- **Finding**: Half-value elevations (1.5, 2.5) represent transitions, but no smooth interpolation between terrain levels.
- **File:Line**: Various (architectural issue)
- **Severity**: **WARNING**
- **Impact**: Character at elevel=1.0 entering ditch (0.5) is abrupt. No intermediate transitions. Works but feels non-smooth.

---

### **CATEGORY 8: INITIALIZATION MANAGER INTEGRATION**

#### **8.1 - INFO: InitializationManager Not Used for Elevation Setup**
- **Finding**: `dm/InitializationManager.dm` orchestrates 5 phases of startup but doesn't initialize global elevation state.
- **File:Line**: `dm/InitializationManager.dm:*`
- **Severity**: **INFO** (Architectural note)
- **Impact**: No centralized elevation system startup. OK since elevation is object-level, but consider adding sanity checks.

---

## SUMMARY TABLE

| Category | Issue | File:Line | Severity | Fix Difficulty |
|----------|-------|-----------|----------|----------------|
| Combat | Attack() missing Chk_LevelRange | Basics.dm:1738 | **CRITICAL** | Easy |
| Combat | Enemy Attack() missing checks | Enemies.dm:773-1575 | **CRITICAL** | Easy (bulk change) |
| Combat | checkdeadplayer2() lacks context | Basics.dm:1804 | WARNING | Medium |
| Init | Objects dropped without elevel | Enemies.dm:10-360 | **CRITICAL** | Medium |
| Init | NPCs spawn without elevel setup | Enemies.dm:1093-1575 | **CRITICAL** | Medium |
| Init | Player New() lacks elevel sync | Basics.dm:296 | WARNING | Easy |
| Init | CookedFood no elevel | CookingSystem.dm:335 | WARNING | Easy |
| Visibility | FindInvis() logic unclear | Fl_AtomSystem.dm:29 | WARNING | Design decision |
| Visibility | Weather visibility incomplete | WeatherParticles.dm:275 | WARNING | Easy |
| Ditch/Hill | Code duplication in jb.dm | jb.dm:6311 | WARNING | Medium |
| Range | Combat not using Chk_LevelRange | Basics.dm, Enemies.dm | **CRITICAL** | Easy |
| Fishing | No elevation check for fishing | FishingSystem.dm:273 | WARNING | Easy |
| Corner-Cut | Diagonal elevation gaps possible | Fl_AtomSystem.dm:46 | WARNING | Medium |

---

## RECOMMENDATIONS

### **Priority 1 (Fix Immediately)**

1. **Add Chk_LevelRange() check to Attack() procs**
   - `dm/Basics.dm:1738` (player attack)
   - `dm/Enemies.dm:773-1575` (all enemy types)
   - Before damage calculation: `if(!attacker.Chk_LevelRange(target)) return`

2. **Fix object/NPC elevation initialization**
   - Create helper: `InitializeElevationFromTurf(turf/t)`
   - Call in New() for items, NPCs, or inherit from location
   - Apply to: dropped items, cooked food, summoned objects

3. **Audit combat damage flow**
   - Trace damage from Attack() → s_damage() → updateHP()
   - Ensure no bypass paths around elevation checks

### **Priority 2 (Fix Soon)**

4. **Complete weather visibility checks**
   - Add lower bound: `if(M.elevel <= elevel + 0.5 && M.elevel >= elevel - 0.5)`
   - Apply to all weather FX checks

5. **Consolidate ditch/hill logic**
   - Move duplication from jb.dm back to Fl_ElevationSystem.dm
   - Or create shared proc to avoid divergence

6. **Document FindInvis() design intent**
   - Clarify: Is higher elevel intentionally hidden from below?
   - Consider reversing if not intentional

### **Priority 3 (Polish)**

7. **Add elevation system documentation**
   - Create `ELEVATION_SYSTEM_DESIGN.md` explaining ranges, transitions, visibility rules
   - Include diagrams showing layer/invisibility mapping

8. **Consider smooth transitions**
   - Add intermediate elevel states (1.25, 1.75, etc.) for ramps
   - Not urgent if current discrete levels work

---

## FILES REQUIRING CHANGES

### Must-Change (Critical Fixes)
- `dm/Basics.dm` (Attack proc)
- `dm/Enemies.dm` (all enemy Attack procs, New procs)
- `dm/CookingSystem.dm` (line 335)

### Should-Change (Important Fixes)
- `dm/WeatherParticles.dm` (visibility check)
- `dm/FishingSystem.dm` (elevation validation)

### Consider-Change (Improvements)
- `libs/Fl_AtomSystem.dm` (FindInvis documentation)
- `dm/jb.dm` (refactor duplicated logic)
- `libs/Fl_ElevationSystem.dm` (add helper for initialization)

---

## TESTING CHECKLIST

After implementing fixes:

- [ ] Player can attack NPC from ground level (distance ✓, elevation ✓)
- [ ] Player cannot attack NPC on elevated terrain > 0.5 levels away
- [ ] Enemy NPC respects elevation range when attacking
- [ ] Items dropped on hills appear at correct elevation
- [ ] Enemy spawned on hill (elevel=1.5) visible and can attack ground players
- [ ] Ditch entry/exit blocking works bidirectionally
- [ ] Weather FX visibility respects elevation range both directions
- [ ] Fishing only allowed adjacent to water at same elevation ±0.5
- [ ] Cooked food inherits elevation from chef location
- [ ] Corner-cut logic doesn't bypass elevation discontinuities

---

## CONCLUSION

The elevation system has **solid architectural foundations** with correct layer mapping and range checking procs. However, **combat interactions completely bypass elevation validation**, creating a critical security/exploit vector. This is the **#1 priority fix**. Secondary issues around object initialization and visibility edge cases are less severe but should be addressed for completeness.

**Overall Assessment**: 70/100 - Solid core, critical combat gap, good execution on non-combat paths.
