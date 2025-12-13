# Crafting Systems Modernization Plan - DETAILED REFACTORING GUIDE

**Status:** Active Implementation  
**Priority:** CRITICAL - Legacy code blocking modern features  
**Timeline:** Phased approach (24 hours total)

---

## System-by-System Modernization Plans

### 🔴 CRITICAL PRIORITY 1: SMELTING REFACTOR (4 hours)

**File:** `dm/Objects.dm` lines 10645-10730  
**Issue:** Direct `.smerank` and `.smeexp` access throughout  
**Status:** Ready for immediate refactoring

#### Current Legacy Pattern:
```dm
❌ LEGACY CODE
proc/smeltinglevel()
    if((M.smerank == 1)&&(M.smeexp >= 5))
        M.smerank += 1
        M.msmeexp = 15  // Old formula
        
proc/smeltingunlock()
    if(M.smerank == 1)
        smelt = list("Iron","Cancel","Back")
    // ... 50+ lines of nested ifs
```

#### Modernization Strategy:

**Step 1: Create new smelting module** (1 hour)
- Create `dm/SmeltingSystemModern.dm` 
- Define smelting recipe registry
- Implement UseObject() handler for forge objects

**Step 2: Migrate rank system** (1 hour)
- Replace all `M.smerank` with `M.character.GetRankLevel(RANK_SMELTING)`
- Replace all `M.smeexp += X` with `M.character.UpdateRankExp(RANK_SMELTING, X)`
- Delete deprecated `smeltinglevel()` and `smeltingunlock()` procs
- Use UnifiedRankSystem for all rank-up thresholds

**Step 3: Consolidate recipe logic** (1 hour)
- Extract smelting recipes to registry (Iron, Lead, Zinc, Copper, Bronze, Brass, Steel)
- Create proc to get available recipes based on rank
- Simplify menu generation

**Step 4: Create forge workstation** (1 hour)
- Define `/obj/Buildable/Smelting/Forge` with UseObject() handler
- Add E-key macro support
- Pattern: Same as fishing macro integration

#### Deliverables:
- ✅ New SmeltingSystemModern.dm (200 lines)
- ✅ Objects.dm smelting references updated (deleted 70+ lines of legacy code)
- ✅ E-key forge support
- ✅ Clean build verified
- ✅ Git commit

---

### 🔴 CRITICAL PRIORITY 2: DIGGING CLEANUP (8-12 hours)

**File:** `dm/jb.dm` (8794 lines total)  
**Issue:** EXTREME bloat - 80% likely dead code, scattered legacy  
**Status:** Requires full audit before modernization

#### Two-Phase Approach:

**PHASE A: Analysis & Dead Code Removal (4-6 hours)**

1. **Audit deprecated code patterns:**
   - [ ] Count total lines (8794)
   - [ ] Identify dead code blocks (commented sections, unused procs)
   - [ ] List deprecated rank procs (`GaindLevel()`, `checkdlevel()`, etc.)
   - [ ] Map modern replacements in LandscapingSystem.dm

2. **Dead code removal:**
   - [ ] Remove commented-out code blocks (likely 20-30% of lines)
   - [ ] Remove deprecated procs (estimated 200-400 lines)
   - [ ] Remove unused variables at global scope
   - [ ] Clean up old menu systems

3. **Modern code extraction:**
   - [ ] Identify which parts ARE using modern system
   - [ ] Extract to separate module for review
   - [ ] Cross-reference with LandscapingSystem.dm

**PHASE B: Modern Integration (4-6 hours)**

1. **Consolidate with LandscapingSystem.dm:**
   - [ ] Verify LandscapingSystem.dm has all modern code
   - [ ] Move any additional logic from jb.dm → LandscapingSystem.dm
   - [ ] Ensure all rank checks use `M.character.GetRankLevel(RANK_DIGGING)`
   - [ ] Ensure all XP awards use `M.character.UpdateRankExp(RANK_DIGGING, xp)`

2. **Create forge/smelter workstations:**
   - [ ] Define `/obj/Buildable/Digging` if needed
   - [ ] Add UseObject() handlers for digging objects
   - [ ] E-key macro support

3. **Verify dependencies:**
   - [ ] Check what other systems depend on jb.dm code
   - [ ] Update references to point to LandscapingSystem.dm
   - [ ] Test building system integration

#### Expected Outcome:
- jb.dm reduced from 8794 → ~2000-3000 lines (remove 5000+ lines of dead code)
- All digging uses modern rank system
- E-key support for all digging actions
- Clean, maintainable building system

---

### 🟠 HIGH PRIORITY 3: SMITHING REFACTOR (REVISED SCOPE)

**File:** `dm/Objects.dm` lines 5107-8872  
**Issue:** 3765-line monolithic verb with hundreds of nested menus
**Status:** Phase 1 (E-key support) COMPLETE, Phase 2 (decomposition) DEFERRED

#### Current Status:
- ✅ **Phase 1 COMPLETE:** E-key support added via `SmithingModernE-Key.dm`
  - `/obj/Buildable/Smithing/Anvil` - UseObject() handler
  - `/obj/Buildable/Smithing/Forge` - UseObject() handler
  - Both trigger existing Smithing() verb on E-key press
  - No build errors, fully integrated

#### Why We're Deferring Full Decomposition:

The Smithing() verb is **3765 lines** of nested menus with 100+ recipe cases. Full refactoring would require:
- 12-15 hours of dedicated work
- Complete menu system rewrite
- Potential for regression bugs
- Recipe registry extraction (100+ items)
- Testing all 100+ item combinations

**Decision:** Keep E-key support (Phase 1) complete but defer the full decomposition to a dedicated refactoring session.

#### Future Refactoring Plan (Phase 2 - When Time Permits):

1. **Extract recipes to registry** (2 hours)
   - Define `SMITHING_RECIPES[]` list with all 100+ items
   - Format: [inputs, outputs, xp, req_rank]

2. **Create menu system module** (3 hours)
   - Replace nested input() calls with clean switch handlers
   - Separate Tools/Weapons/Armor/Lamps into distinct procs

3. **Implement UseObject() override** (2 hours)
   - Call new menu system instead of 3765-line verb
   - Clean, maintainable code

4. **Test all recipes** (2-3 hours)
   - Verify each of 100+ items crafts correctly
   - Check XP/stamina costs
   - Ensure rank requirements still work

**Total Future Estimate:** 9-12 hours (vs. current E-key quick win of 10 minutes)

---

### 🟡 HIGH PRIORITY 4: COOKING MACRO (2 hours)

**File:** `dm/CookingSystem.dm` (already modern) + Objects.dm  
**Issue:** Modern logic but verb-only interaction (no E-key)  
**Status:** Low-risk enhancement

#### Current State:
```dm
✅ MODERN - Just needs E-key
obj/Oven
    proc/TryStartCooking(...)
        M.character.UpdateRankExp(RANK_CRAFTING, xp)  // ✅ Modern

❌ LEGACY - Must be right-clicked
    verb/Cooking()
        ShowCookingMenu(M, src)
```

#### Modernization Strategy:

**Step 1: Add UseObject() handler** (30 mins)
- Create `/obj/Oven/UseObject()` 
- Trigger `ShowCookingMenu()` on E-key press
- Pattern: Same as fishing implementation

**Step 2: Optional UI improvement** (30 mins)
- Consider button-based menu instead of input() popup
- Or keep popup but make it accessible via E-key

**Step 3: Verify integration** (1 hour)
- Test that both verb AND E-key work
- Verify XP awards are correct
- Confirm cooking recipes unlock properly

#### Deliverables:
- ✅ E-key oven support in CookingSystem.dm
- ✅ Clean build verified
- ✅ Git commit

---

### 🟡 MEDIUM PRIORITY 5: GARDENING CLEANUP (6 hours)

**File:** `dm/plant.dm` (1876 lines)  
**Issue:** Duplicate rank variables, deprecated procs, mixed patterns  
**Status:** Requires systematic cleanup

#### Current Legacy Pattern:
```dm
❌ LEGACY
var
    grank = 0          // DEPRECATED - in character datum
    grankEXP = 0       // DEPRECATED
    grankMAXEXP = 100  // DEPRECATED
    
proc/GNLvl()          // DEPRECATED - never called
    if(grankEXP>=grankMAXEXP)
        grankMAXEXP+=exp2lvl(grank)  // Old formula
        grank++
```

#### Modernization Strategy:

**Step 1: Remove duplicate rank variables** (1 hour)
- Delete all global rank vars at file scope
- Verify character datum has replacements (botany_rank, botany_xp, etc.)
- Search for references to old vars

**Step 2: Delete deprecated procs** (1 hour)
- Remove `GNLvl()`, `exp2lvl()`, and related procs
- Search codebase for any calls (should be none)
- Consolidate into UpdateRankExp() calls

**Step 3: Audit rank pattern usage** (2 hours)
- Find all direct `.grank` and `.grankEXP` access
- Replace with modern system calls
- Verify all rank-ups go through UnifiedRankSystem

**Step 4: Add E-key support** (1 hour)
- Ensure all garden plants have UseObject() handlers
- Or create handlers where missing
- Test E-key gathering

**Step 5: Consolidate scattered logic** (1 hour)
- Look for duplicate code blocks
- Extract common gardening patterns
- Improve code organization

#### Deliverables:
- ✅ Duplicate rank vars removed
- ✅ Deprecated procs deleted
- ✅ All rank access modernized
- ✅ E-key support verified
- ✅ Clean build verified
- ✅ Git commit

---

### 🟢 ALREADY COMPLETE: Crafting & Compost Systems

**No action needed:**
- ✅ `LocationGatedCraftingSystem.dm` - Modern, E-key support, clean code
- ✅ `CompostCraftingIntegration.dm` - Modern, E-key support, clean code

---

## Implementation Sequence

### Timeline:

**Session 1 (Today - 4 hours):**
- [ ] Smelting refactor (CRITICAL, quick win)
- [ ] Create SmeltingSystemModern.dm
- [ ] Delete smelting legacy code
- [ ] Verify build + commit

**Session 2 (Tomorrow - 2 hours):**
- [ ] Cooking macro integration (quick, high impact)
- [ ] Add E-key oven support
- [ ] Verify build + commit

**Session 3 (Later):**
- [ ] Digging cleanup Phase A (4-6 hours)
- [ ] Dead code removal, audit complete code

**Session 4 (Later):**
- [ ] Digging cleanup Phase B (4-6 hours)
- [ ] Modern integration, dependency verification

**Session 5 (Later):**
- [ ] Gardening cleanup (6 hours)
- [ ] Systematic modernization

**Session 6 (Later):**
- [ ] Smithing refactor (4 hours)
- [ ] Decompose 366-line verb
- [ ] E-key integration

---

## Code Patterns to Replace

### Pattern A: Direct Variable Access
```dm
❌ OLD (REMOVE)
M.smerank = 7
M.smeexp += 10
M.grank++

✅ NEW (REPLACE WITH)
M.character.SetRankLevel(RANK_SMELTING, 7)
M.character.UpdateRankExp(RANK_SMELTING, 10)  // Auto level-up
M.character.UpdateRankExp(RANK_GARDENING, 0)
```

### Pattern B: Deprecated Proc Calls
```dm
❌ OLD (REMOVE)
GNLvl()
smeltinglevel()
exp2lvl(rank)

✅ NEW (REPLACE WITH)
M.character.UpdateRankExp(RANK_GARDENING, xp_amount)
// UpdateRankExp handles all level-up logic internally
```

### Pattern C: Hardcoded Thresholds
```dm
❌ OLD (REMOVE)
if(M.smerank == 1 && M.smeexp >= 5)
if(M.smerank == 2 && M.smeexp >= 40)
// ... scattered throughout code

✅ NEW (REPLACE WITH)
M.character.UpdateRankExp(RANK_SMELTING, xp_earned)
// UnifiedRankSystem handles thresholds in one place
```

### Pattern D: Verb-Only Interaction
```dm
❌ OLD (REMOVE)
verb/Cooking()
    ShowCookingMenu()

✅ NEW (REPLACE WITH)
obj/Oven/UseObject(mob/user)
    ShowCookingMenu(user, src)
```

---

## Validation Checklist

After each system refactor, verify:

- [ ] **No direct variable access** to `.smerank`, `.grank`, `.smeexp`, etc.
- [ ] **All XP awards** use `M.character.UpdateRankExp(RANK_TYPE, amount)`
- [ ] **All rank checks** use `M.character.GetRankLevel(RANK_TYPE)` or `CheckRankRequirement()`
- [ ] **No global rank duplicates** - Only in character datum
- [ ] **No deprecated procs** called - SearchGrep for old proc names
- [ ] **E-key support** on all workstations
- [ ] **Clean build** - 0 errors
- [ ] **Git commit** with clear message

---

## Risk Mitigation

**HIGH RISK:** Digging (4500+ lines, lots of unknowns)
- Mitigate: Start with dead code removal audit
- Mitigate: Test building system thoroughly after changes
- Mitigate: Keep LandscapingSystem.dm as fallback reference

**MEDIUM RISK:** Gardening (1876 lines, some modern code mixed in)
- Mitigate: Systematic find/replace with verification
- Mitigate: Test all garden interaction after changes

**LOW RISK:** Smelting, Cooking, Smithing
- Clear legacy patterns
- Smaller scope
- Established patterns from fishing/climbing

---

## Next Steps

1. **Start with Smelting** (this session) ✅
2. **Then Cooking** (next quick session) ✅
3. **Then Smithing** (medium-complexity decomposition)
4. **Schedule Digging & Gardening** (large tasks, dedicated sessions)

