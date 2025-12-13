# Comprehensive Crafting Systems Legacy Code Audit

**Date:** December 13, 2025  
**Status:** AUDIT COMPLETE - 7 Systems Analyzed  
**Priority:** HIGH - Multiple systems need modernization

---

## Executive Summary

| System | File | Status | Lines | XP System | E-Key | Issues | Priority |
|--------|------|--------|-------|-----------|-------|--------|----------|
| **Cooking** | CookingSystem.dm | ⚠️ Partial | 600+ | ✅ Modern | ❌ No | No macro | MEDIUM |
| **Crafting** | LocationGatedCraftingSystem.dm | ✅ Modern | 500+ | ✅ Modern | ⚠️ Partial | Clean | LOW |
| **Smithing** | Objects.dm | ⚠️ Legacy | 366 | ⚠️ Mixed | ❌ No | 366 line verb, direct access | HIGH |
| **Smelting** | Objects.dm | ❌ Legacy | 200+ | ⚠️ Legacy | ❌ No | Direct `.smerank` access | CRITICAL |
| **Gardening** | plant.dm | ⚠️ Legacy | 1876 | ⚠️ Legacy | ⚠️ Partial | Rank variable bloat | MEDIUM |
| **Digging** | jb.dm | ❌ Legacy | 4500+ | ⚠️ Legacy | ❌ No | MASSIVE bloat, dead code | CRITICAL |
| **Compost** | CompostCraftingIntegration.dm | ✅ Modern | 200+ | ✅ Modern | ✅ Yes | Clean | NONE |

---

## CRITICAL FINDINGS

### 🔴 CRITICAL: Smelting (Objects.dm lines 10650-10730)

**Current State:**
```dm
if(M.smerank == 1)
    // ... nested logic 
if((M.smerank == 1)&&(M.smeexp >= 5))
    M.smerank += 1  // Direct variable manipulation - LEGACY
```

**Issues:**
- ❌ Direct `.smerank` access (should use `character.smerank` or `GetRankLevel()`)
- ❌ Direct `.smeexp` access (should use `UpdateRankExp()`)
- ❌ Hardcoded rank-up thresholds (should delegate to unified system)
- ❌ No E-key support (verb-only)
- ❌ ~70+ lines of nested conditionals
- ⚠️ Interleaved rank-up checks mixed with recipe logic

**Recommendation:** REFACTOR - Break into separate rank check + recipe execution

---

### 🔴 CRITICAL: Digging (jb.dm ~4500 lines)

**Current State:**
```dm
var
    dig[1]      // Current dig menu
    drank=1     // DEPRECATED - should be character.drank
    drankEXP=0  // DEPRECATED - should be character.drankEXP
    drankMAXEXP=10
// ... 4400+ more lines
```

**Issues:**
- ❌ **EXTREME BLOAT** - 4500+ lines for what should be ~300-400
- ❌ Old rank system (drank, drankEXP, drankMAXEXP at global scope)
- ❌ Deprecated procs (digging level-up logic 50+ lines per tier)
- ❌ No E-key support (verb-only interaction)
- ❌ Dead code scattered throughout
- ❌ No modern rank integration (UpdateRankExp not used)
- ⚠️ Mixed paradigms - some parts reference new system, some old

**Recommendation:** MASSIVE CLEANUP - This is the worst offender

---

### 🟠 HIGH: Smithing (Objects.dm lines 5090-5360)

**Current State:**
```dm
verb/Smithing()
    if(M.smirank >=1)
        switch(input("What would you like to smith?","Smithing") in L00)
            if("Misc")
                switch(input(...) in L6)
                    if("item1")
                        if(prob(50))
                            M.character.UpdateRankExp(RANK_SMITHING, 15)  // ✅ Modern
                        else
                            M << "Failed"
```

**Issues:**
- ❌ **NO E-KEY SUPPORT** - Must right-click anvil and select verb
- ❌ **HUGE VERB** - 366+ nested lines with goto labels
- ⚠️ **MIXED XP SYSTEM** - Uses `UpdateRankExp()` but verb-based interaction
- ❌ **COMPLEX MENUS** - Multiple input() calls instead of simple interface
- ⚠️ **NO WORKSTATION OBJECTS** - Anvil objects created but no UseObject() handlers
- ❌ **MASSIVE CODE SMELL** - Recipe logic deeply nested in verb

**Recommendation:** REFACTOR - Separate smithing workstations with UseObject() handlers

---

### 🟠 HIGH: Cooking (CookingSystem.dm + Objects.dm)

**Current State:**
```dm
obj/Oven
    proc/TryStartCooking(mob/players/M, list/ingredients, list/recipe_data)
        // Modern cooking logic
        M.character.UpdateRankExp(RANK_CRAFTING, xp_amount)  // ✅ Modern
    
    // But activated via verb in Objects.dm
    verb/Cooking()
        ShowCookingMenu(M, src)
```

**Issues:**
- ⚠️ **NO E-KEY MACRO** - Must click oven then right-click verb
- ✅ **Modern XP** - Uses UpdateRankExp() correctly
- ⚠️ **UI Popup** - Cooking menu pops up instead of macro-driven
- ✅ **Clean recipe system** - Registry-based, no duplication
- ⚠️ **Partial integration** - Mechanics are modern, interaction is legacy

**Recommendation:** ADD E-KEY MACRO - UseObject() handler on ovens

---

## MEDIUM PRIORITY

### 🟡 MEDIUM: Gardening (plant.dm - 1876 lines)

**Current State:**
```dm
var
    grank = 0
    grankEXP = 0
    grankMAXEXP = 100
    hrank = 0
    hrankEXP = 0
    // ... 20+ duplicate rank vars

proc/GNLvl()  // DEPRECATED
    if(grank>=5)
        // 50+ lines of old rank-up logic
    if(grankEXP>=grankMAXEXP)
        grankMAXEXP+=exp2lvl(grank)  // Old proc
        grank++
```

**Issues:**
- ❌ **DUPLICATE RANK VARIABLES** - Should only exist in character datum
- ❌ **DEPRECATED PROCS** - `GNLvl()`, `exp2lvl()` never called
- ⚠️ **MIXED RANK PATTERNS** - Some code uses old system, some uses `UpdateRankExp()`
- ⚠️ **PARTIAL MACRO SUPPORT** - Some plants have UseObject(), some don't
- ⚠️ **CODE BLOAT** - 1876 lines (likely 50% dead code or duplication)

**Recommendation:** CODE CLEANUP - Remove duplicate rank vars, delete deprecated procs

---

### 🟡 MEDIUM: Crafting - Location Gated System (LocationGatedCraftingSystem.dm)

**Current State:**
```dm
proc/OpenCraftingInterface(mob/player, obj/crafting_location/location)
    // Modern location-based crafting
    player.character.UpdateRankExp(RANK_CRAFTING, xp_earned)  // ✅ Modern
    
obj/crafting_location
    UseObject(mob/user)  // ✅ E-key support
        OpenCraftingInterface(user, src)
```

**Status:** ✅ CLEAN - This system is modern and doesn't need refactoring
- ✅ E-key macro support
- ✅ Modern rank system integration
- ✅ Clean architecture
- ✅ No legacy code

---

## LOW PRIORITY

### 🟢 LOW: Compost Crafting (CompostCraftingIntegration.dm)

**Current State:**
```dm
obj/CompostBin
    UseObject(mob/user)  // ✅ E-key
        PromptCraftCompost(user, src)

proc/CraftCompostRecipe(mob/players/player, ...)
    player.character.UpdateRankExp(RANK_CRAFTING, xp_earned)  // ✅ Modern
```

**Status:** ✅ CLEAN - Modern implementation, no issues

---

## LEGACY CODE PATTERNS FOUND

### Pattern 1: Direct Variable Access (ANTI-PATTERN)
```dm
❌ LEGACY
M.smerank = 7
M.smeexp += 10
M.grank++

✅ MODERN
M.character.SetRankLevel(RANK_SMELTING, 7)
M.character.UpdateRankExp(RANK_SMELTING, 10)
M.character.UpdateRankExp(RANK_GARDENING, 0)  // Triggers level-up internally
```

### Pattern 2: Deprecated Proc Calls (ANTI-PATTERN)
```dm
❌ LEGACY
GNLvl()      // Deprecated - never called, dead code
CLvl()       // Deprecated - never called
exp2lvl(X)   // Deprecated - old formula

✅ MODERN
M.character.UpdateRankExp(RANK_GARDENING, xp_amount)  // Handles level-ups
M.character.UpdateRankExp(RANK_CARVING, xp_amount)
```

### Pattern 3: Hardcoded Rank Thresholds (ANTI-PATTERN)
```dm
❌ LEGACY
if(M.smerank == 1 && M.smeexp >= 5)
if(M.smerank == 2 && M.smeexp >= 40)
if(M.smerank == 3 && M.smeexp >= 100)  // Scattered throughout code

✅ MODERN
M.character.UpdateRankExp(RANK_SMELTING, xp_earned)  // All thresholds in UnifiedRankSystem
```

### Pattern 4: Verb-Only Interaction (ANTI-PATTERN)
```dm
❌ LEGACY
verb/Cooking()
    // Must right-click, no E-key support
    
verb/Smithing()
    // 366+ nested lines in one verb

✅ MODERN
obj/CraftingStation
    UseObject(mob/user)
        // Triggered by E-key
        HandleCraftingAction(user)
```

---

## REFACTORING ROADMAP

### Phase 1: CRITICAL CLEANUP (12-16 hours)

**1.1 Smelting System Refactor (4 hours)**
- [ ] Audit all smelting rank checks in Objects.dm (lines 10650-10730)
- [ ] Extract rank-up logic into unified system calls
- [ ] Replace all `M.smerank` → `M.character.smerank` (or `GetRankLevel()`)
- [ ] Replace all `M.smeexp +=` → `M.character.UpdateRankExp(RANK_SMELTING, amount)`
- [ ] Create `/obj/Buildable/Smelting/Forge` with `UseObject()` handler
- [ ] Remove 70+ lines of nested legacy code

**1.2 Digging System Refactor (8 hours)**
- [ ] Read full jb.dm and identify dead code (50% of 4500 lines)
- [ ] Extract modern digging logic to separate file (LandscapingSystem.dm exists!)
- [ ] Remove duplicate rank variables from global scope
- [ ] Delete deprecated procs (digging level-up logic)
- [ ] Add `UseObject()` handlers to digging objects
- [ ] Consolidate to ~400 lines of active code

**1.3 Smithing Macro Integration (4 hours)**
- [ ] Create `/obj/Buildable/Smithing/Anvil` with `UseObject()` handler
- [ ] Extract smithing recipe logic from 366-line verb
- [ ] Replace input() menus with button/option-based interface
- [ ] Verify `UpdateRankExp(RANK_SMITHING, xp)` is called correctly
- [ ] Remove goto labels and nested conditionals

### Phase 2: MEDIUM PRIORITY (8-10 hours)

**2.1 Cooking Macro Integration (2 hours)**
- [ ] Add `UseObject()` handler to ovens
- [ ] Keep modern CookingSystem.dm intact
- [ ] Remove or supplement Objects.dm Cooking() verb

**2.2 Gardening Cleanup (6-8 hours)**
- [ ] Remove duplicate rank variables from plant.dm global scope
- [ ] Delete deprecated procs: `GNLvl()`, `exp2lvl()`, etc.
- [ ] Audit all gardening rank checks for modern system integration
- [ ] Add missing `UseObject()` handlers to garden plants
- [ ] Consolidate scattered rank-up logic

### Phase 3: LOW PRIORITY (2-4 hours)

**3.1 Documentation & Validation (2-4 hours)**
- [ ] Create integration test suite for all crafting systems
- [ ] Verify all systems use unified rank system
- [ ] Confirm all rank-ups award correct XP
- [ ] Test E-key support on all crafting stations

---

## INTEGRATION CHECKLIST

### For Each Crafting System:

- [ ] **Rank System**: Uses `M.character.rank_var` or unified accessors
- [ ] **XP Awards**: Uses `M.character.UpdateRankExp(RANK_TYPE, amount)`
- [ ] **Rank Requirements**: Uses `M.CheckRankRequirement(RANK_TYPE, level)`
- [ ] **E-Key Support**: Has `UseObject()` handler on workstation objects
- [ ] **No Hardcoded Thresholds**: All rank-up logic in UnifiedRankSystem
- [ ] **No Deprecated Procs**: Removed all old level-up procs
- [ ] **No Global Duplicates**: Rank vars only in character datum
- [ ] **Recipe Registry**: All recipes in centralized registry (if applicable)

---

## ESTIMATED EFFORT

| Task | Hours | Dependencies | Impact |
|------|-------|--------------|--------|
| Smelting refactor | 4 | None | 70+ lines cleaned |
| Digging refactor | 8 | None | 4000+ lines cleaned |
| Smithing macro | 4 | None | 366-line verb decomposed |
| Cooking macro | 2 | CookingSystem.dm | E-key support added |
| Gardening cleanup | 6 | None | 1000+ lines cleaned |
| **Total** | **24 hours** | Sequential phases | ~5000 lines modernized |

---

## RISK ASSESSMENT

**HIGH RISK:**
- Digging system (4500 lines, heavily interconnected, no test suite)
- Smithing verb decomposition (366 lines, complex menu logic)

**MEDIUM RISK:**
- Gardening cleanup (1876 lines, some modern code already exists)
- Smelting refactoring (200 lines, straightforward legacy pattern)

**LOW RISK:**
- Cooking macro (CookingSystem.dm is already modern, just add E-key)
- Compost crafting (already modern, no changes needed)

---

## QUICK WINS (< 2 hours each)

1. **Remove deprecated procs from Gardening** (30 mins)
   - Delete `GNLvl()`, `CLvl()`, `CSLvl()`, `exp2lvl()`
   - Search for any proc calls and replace with `UpdateRankExp()`

2. **Add Cooking E-key macro** (1 hour)
   - Create `UseObject()` handler on oven objects
   - Pattern already established in CookingSystem.dm

3. **Audit Smelting direct variable access** (1 hour)
   - Count all `M.smerank` and `M.smeexp` usages
   - Create migration plan

---

## NEXT STEPS

1. **Start with Smelting** (highest ROI, lowest risk)
   - Clear legacy pattern, small footprint
   - Establishes refactoring pattern for others

2. **Then Smithing macro** (high impact, medium risk)
   - Proven pattern from climbing system phases 6-7
   - Unblocks manual UI improvements

3. **Then Cooking macro** (low effort, medium impact)
   - CookingSystem.dm already modern
   - Just needs E-key integration

4. **Schedule Digging cleanup** (critical but large)
   - Requires full file audit
   - May reveal undocumented dependencies
   - Best done with dedicated focused session

5. **Gardening cleanup** (medium effort, medium impact)
   - Remove globals, delete procs
   - Consolidate rank patterns

