# Unified Landscaping & Terrain Modification System - Consolidation Analysis

**Date:** December 19, 2025  
**Status:** Phase Analysis - Preparing for Consolidation  
**Objective:** Merge jb.dm (8794 lines) + LandscapingSystem.dm (262 lines) into ONE unified system

---

## Current State: Duplication Identified

### System 1: jb.dm (8794 lines) - LEGACY
Located in: `dm/jb.dm`

**Contains:**
1. `verb/Dig()` (line 42) - Massive nested digging menu
   - Creates landscape objects (roads, ditches, hills, water, etc.)
   - Highly repetitive code (same pattern 100+ times)
   - Uses `UpdateRankExp(RANK_DIGGING, xp)` ✅ Already modern
   - Uses `M.stamina -= cost` ✅ Modern stamina system
   - Uses `CanPlayerBuildAtLocation()` checks ✅ Modern deed integration

2. `verb/Build()` (line 1236) - Massive nested building menu
   - Creates building objects (wood/stone structures)
   - Similar repetitive pattern
   - Uses modern rank/stamina/deed systems

3. `proc/FindJar` (line 1229) - Utility proc
4. `proc/GaindLevel` (line 4446) - Level gain feedback

**Problems:**
- 8794 lines total
- ~90% is active code (not dead code as originally thought)
- Massive code duplication (same pattern repeated 100+ times)
- Extremely nested switch statements (hard to maintain)
- Adding new building/digging types requires editing deeply nested code

### System 2: LandscapingSystem.dm (262 lines) - MODERN
Located in: `dm/LandscapingSystem.dm`

**Contains:**
1. `proc/CreateLandscapeObject()` - Unified object creation helper
   - Handles permissions, stamina, XP in ONE place
   - Replaces 100+ identical code blocks
   - Returns 1/0 for success

2. `proc/GetDiggingMenuOptions(M)` - Rank-based menu generation
   - Returns list based on player rank
   - Rank gating table: Rank 1-10 mapped to features
   - Replaces hard-coded option lists

3. `proc/GetBuildingMenuOptions(M)` - Similar for building
4. Infrastructure procs

**Design:** Data-driven, modular, zero duplication

---

## Consolidation Strategy

### Goal: Merge into ONE unified system
- Keep: LandscapingSystem.dm architecture (modern, clean)
- Extract: Useful code from jb.dm
- Create: Data-driven lookup tables (instead of nested switches)
- Result: ~400-600 lines instead of 9056 lines (-93% reduction)

### Approach: Three Phases

#### PHASE 1: Extract All Object Types & Recipes (2-3 hours)
**Task:** Create data-driven lookup tables for all landscaping/building objects

From jb.dm, identify:
1. **Digging Objects:**
   - Dirt (Rank 1)
   - Grass (Rank 2)
   - Dirt Road variants: NS, EW, 3-way, corners (Rank 3-4)
   - Wood Road variants (Rank 5)
   - Ditch variants (Rank 7)
   - Brick Road (Rank 8)
   - Hill variants (Rank 8)
   - Water (Rank 9)
   - Lava (Rank 10)

2. **Building Objects:**
   - Scaffolding
   - Wooden structures (walls, roofs, doors, furniture)
   - Stone structures (walls, roofs, doors, furniture)
   - Decorative items

**Format:** Create lookup tables like Smithing recipes
```dm
var/global/list/TERRAIN_OBJECTS = list(
    "dirt" = list(
        "type" = /obj/Landscaping/Dirt,
        "xp" = 10,
        "stamina" = 3,
        "rank_required" = 1,
        "description" = "Basic dirt patch"
    ),
    ...
)
```

**Deliverable:** `dm/TerrainObjectsRegistry.dm` (estimated 150-200 lines)

#### PHASE 2: Convert Menus to Data-Driven (1-2 hours)
**Task:** Replace nested switch statements with registry lookups

From LandscapingSystem.dm, enhance:
1. `GetDiggingMenuOptions(M)` → Read from registry instead of hard-coded lists
2. `GetBuildingMenuOptions(M)` → Same treatment
3. Add `GetTerrainObjectDetails(object_name)` → Lookup function

**Pattern:**
```dm
proc/GetDiggingMenuOptions(M)
    var/rank = M.GetRankLevel(RANK_DIGGING)
    var/options = list("Cancel")
    
    for(var/name in TERRAIN_OBJECTS)
        var/data = TERRAIN_OBJECTS[name]
        if(data["rank_required"] <= rank)
            options += name
    
    return options
```

**Deliverable:** Updated LandscapingSystem.dm (estimated 100-150 lines instead of 262)

#### PHASE 3: Consolidate & Delete Legacy Code (1-2 hours)
**Task:** Move everything to LandscapingSystem.dm, delete jb.dm

1. Move `proc/FindJar` → LandscapingSystem.dm (if still used)
2. Move `proc/GaindLevel` → LandscapingSystem.dm (if still used)
3. Create E-key handlers (UseObject) for digging/building stations
4. Delete jb.dm entirely
5. Update Pondera.dme include statements
6. Test build

**Deliverable:** Single unified system, jb.dm deleted, build verified

---

## Why This Works

### Comparison

| Aspect | Before | After |
|--------|--------|-------|
| **Total Lines** | 9056 (jb + LandscapingSystem) | ~500 (consolidated) |
| **Duplication** | 90% repeated code | 0% (data-driven) |
| **Maintainability** | Hard (nested switches) | Easy (lookup tables) |
| **Adding New Object** | Edit verb deeply (error-prone) | Add 1 entry to registry (safe) |
| **Build Complexity** | 2 files, 2 systems | 1 file, 1 system |

### Architecture Benefits

1. **Single Responsibility:**
   - TerrainObjectsRegistry.dm = "What objects exist"
   - LandscapingSystem.dm = "How to place them"
   - E-key handlers = "How to trigger from game"

2. **Data Isolation:**
   - All object definitions in ONE place
   - Easy to verify completeness
   - Easy to add new objects

3. **Modern Patterns:**
   - Matches Smithing Phase 2 architecture (registry + handler)
   - Follows UnifiedRankSystem patterns
   - Uses character.UpdateRankExp() properly

4. **Zero Duplication:**
   - CreateLandscapeObject() handles ALL placement
   - Single stamina/XP/permission logic
   - No repeated code blocks

---

## Implementation Timeline

| Phase | Task | Time | Output |
|-------|------|------|--------|
| 1 | Extract objects to registry | 2-3h | TerrainObjectsRegistry.dm (150-200 lines) |
| 2 | Convert menus to lookups | 1-2h | Updated LandscapingSystem.dm (100-150 lines) |
| 3 | Consolidate & delete | 1-2h | jb.dm deleted, clean build |
| TOTAL | | **4-7 hours** | **500 lines total instead of 9056** |

---

## Execution Steps

### Step 1: Analysis (THIS DOCUMENT)
- [x] Identify duplication
- [x] Map out objects and recipes
- [x] Design new architecture

### Step 2: Object Registry Creation
- [ ] Scan jb.dm for all object types
- [ ] Create lookup table structure
- [ ] Extract XP/stamina costs
- [ ] Extract rank requirements
- [ ] Create TerrainObjectsRegistry.dm

### Step 3: Menu System Upgrade
- [ ] Update GetDiggingMenuOptions() to use registry
- [ ] Update GetBuildingMenuOptions() to use registry
- [ ] Verify rank gating works
- [ ] Test menu displays

### Step 4: Code Migration
- [ ] Move utility procs (FindJar, GaindLevel, etc.)
- [ ] Create E-key handlers (UseObject)
- [ ] Update Pondera.dme
- [ ] Delete jb.dm

### Step 5: Testing & Verification
- [ ] Clean build
- [ ] Verify all terrain objects work
- [ ] Test rank gating
- [ ] Test stamina costs
- [ ] Test XP rewards

---

## Key Questions Answered

**Q: Is jb.dm still active?**  
A: Yes, 90% of it is active code. The Dig() and Build() verbs are called by players.

**Q: Is there duplication?**  
A: YES - massive duplication. Same object creation pattern repeated 100+ times with slight variations.

**Q: Can we consolidate with LandscapingSystem.dm?**  
A: YES - LandscapingSystem.dm has the right architecture. We just need to:
  1. Extract object recipes from jb.dm into registry
  2. Feed registry to LandscapingSystem.dm menu system
  3. Delete jb.dm

**Q: Will this break anything?**  
A: No - we're preserving functionality while reorganizing:
  - Same XP rewards
  - Same stamina costs
  - Same rank gating
  - Same objects created
  - Just in cleaner code

---

## Why This Matters

- **Code Reduction:** 8794 lines → ~300 lines in main logic (96% reduction)
- **Maintenance:** New terrain types = 1 registry entry instead of deep verb edit
- **Quality:** Patterns match Smithing Phase 2 (proven architecture)
- **Integration:** Unified with UnifiedRankSystem (no legacy code)
- **Extensibility:** Easy to add tools, special terrain, seasonal variants

---

## Next Steps

1. **Proceed with Phase 1:** Extract terrain/building object registry
2. **Create TerrainObjectsRegistry.dm:** Lookup table with all objects
3. **Update LandscapingSystem.dm:** Switch to data-driven menus
4. **Consolidate:** Move utility procs, add E-key handlers
5. **Delete jb.dm:** Clean up legacy system
6. **Build & Test:** Verify everything works

---

**Recommendation:** Proceed with full consolidation. The architecture is sound, and the code reduction is significant (96%). This positions terrain modification for future enhancements (seasonal terrain, tools, special regions, etc.).
