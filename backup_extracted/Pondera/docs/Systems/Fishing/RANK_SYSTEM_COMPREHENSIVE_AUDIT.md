# 🎯 Rank System Comprehensive Audit & Integration Report
**Date:** December 13, 2025 | **Scope:** All 15+ rank skill systems

---

## Executive Summary

**STATUS:** 🟡 **PARTIALLY INTEGRATED** - Modern searching system fully integrated, but other skills have mixed implementations with multiple disconnects.

### Key Findings:
- ✅ **Searching**: Fully modernized (3-stage minigame, E-key macro, anti-abuse, modern rank integration)
- ⚠️ **GatheringExtensions**: E-key setup exists but many systems still call `DblClick()` instead of specialized handlers
- ❌ **Old Skill Files**: WC.dm, mining.dm, jb.dm contain deprecated rank logic (270+ lines of dead code)
- ❌ **Fishing**: Modern system exists (FishingSystem.dm) but no macro/E-key integration yet
- ❌ **Crafting/Building/Smithing**: Still use old verb-based approach, not macro-integrated

### Quick Wins (Priority 1-2):
1. Integrate Fishing with macro system (E-key: "Fish" vs "Drink")
2. Clean up deprecated old rank code (WC.dm, mining.dm, jb.dm)
3. Add `UseObject()` support to craft stations (forges, anvils)
4. Verify all rank progression uses modern `UpdateRankExp()` pattern

---

## 📊 Rank System Inventory

### All Rank Types (15 total)

| Rank Type | File(s) | Modern Status | Macro Support | XP System | Issues |
|---|---|---|---|---|---|
| **Searching** | SearchingSystemModern.dm | ✅ Modernized | ✅ E-key | ✅ UpdateRankExp | None |
| **Fishing** | FishingSystem.dm | ✅ Modern engine | ⚠️ Partial (water turfs) | ⚠️ Incomplete | No macro handler |
| **Mining** | mining.dm | ❌ Old | ❌ None | ❌ Old code | 270+ deprecated lines |
| **Woodcutting/Harvesting** | WC.dm | ❌ Old | ❌ None | ❌ Old code | 1790 lines, many deprecated |
| **Crafting** | CookingSystem.dm | ⚠️ Mixed | ❌ None | ✅ UpdateRankExp | No E-key macro |
| **Gardening** | FarmingIntegration.dm | ⚠️ Mixed | ⚠️ Soil objects | ✅ UpdateRankExp | Needs UseObject cleanup |
| **Smithing** | Objects.dm | ⚠️ Mixed | ❌ None | ✅ UpdateRankExp | No E-key macro |
| **Smelting** | Objects.dm | ⚠️ Mixed | ❌ None | ✅ UpdateRankExp | No E-key macro |
| **Building** | Objects.dm | ❌ Old | ❌ None | ✅ UpdateRankExp | No E-key macro |
| **Digging** | jb.dm | ❌ Old | ❌ None | ❌ Old code | 4500+ lines, heavily deprecated |
| **Combat** | CombatSystem.dm | ✅ Modern | ✅ Macro keys | ✅ UpdateRankExp | Fully integrated |
| **Botany** | CharacterData.dm | ⚠️ Stub | ❌ None | ❌ Not implemented | Variables exist, no implementation |
| **Archery** | CharacterData.dm | ⚠️ Stub | ❌ None | ❌ Not implemented | Variables exist, no implementation |
| **Whittling** | CharacterData.dm | ⚠️ Stub | ❌ None | ❌ Not implemented | Variables exist, no implementation |
| **Destroying** | CharacterData.dm | ⚠️ Stub | ❌ None | ❌ Not implemented | Variables exist, no implementation |

---

## 🔍 Detailed Findings by System

### 1. SEARCHING ✅ **FULLY INTEGRATED**

**Status:** Production ready

**Files:**
- `dm/SearchingSystemModern.dm` (211 lines) - Core engine
- `dm/Objects.dm` - Searching() verb
- `dm/GatheringExtensions.dm` - Flowers/Tallgrass UseObject

**Implementation:**
```dm
// CORRECT PATTERN
obj/Flowers/UseObject(mob/user)
    PerformSearch(M, src)  // Direct call to modern engine
    M.UpdateRankExp(RANK_SEARCHING, xp_amount)
```

**Strengths:**
- 3-stage theatrical reveal (not instant gratification)
- Smart unique item tracking (whetstones/splinters only drop once)
- 30-second cooldown + escalating difficulty
- Full macro integration (E-key activation)
- Proper use of `UpdateRankExp()` for rank progression

**Zero Issues** ✅

---

### 2. FISHING ⚠️ **PARTIALLY INTEGRATED**

**Status:** Engine exists but macro incomplete

**Files:**
- `dm/FishingSystem.dm` (502 lines) - Complete minigame with tension mechanic
- `dm/GatheringExtensions.dm` - Water turfs with input prompt

**Current Implementation:**
```dm
// PARTIAL PATTERN
turf/water/UseObject(mob/user)
    var/action = input(user, "What do you want to do?") in list("Fish", "Drink", "Cancel")
    if(action == "Fish")
        user:StartFishing(src)
```

**Issues:**
1. ❌ **Input popup blocks UI** - Should be macro buttons (Q for fish, E for drink)
2. ❌ **Missing XP integration** - FishingSystem.dm doesn't call `UpdateRankExp()`
3. ⚠️ **Incomplete water coverage** - Only turf/water has UseObject; water variants (c1-c4, Oasis*, Jungle*) call DblClick()

**Improvements Needed:**
- Replace popup input with dual-macro system
- Add `M.UpdateRankExp(RANK_FISHING, xp_gain)` to fish catch handler
- Verify all water variants inherit UseObject properly

---

### 3. MINING ❌ **LEGACY CODE**

**Status:** Old system with 270+ deprecated lines

**Files:**
- `dm/mining.dm` (1795 lines) - Mixed old rank code + new mineral system

**Old Rank Code (Lines 1-50+):**
```dm
var
    mrank=1             // DEPRECATED - Use character.mrank
    mrankEXP=0          // DEPRECATED - Use character.mrankEXP
    mrankMAXEXP=10      // DEPRECATED - Use character.mrankMAXEXP
    MAXmrankLVL=0       // DEPRECATED - Handled by MAX_RANK_LEVEL constant

proc/MNLvl()           // DEPRECATED - Use UpdateRankExp(RANK_MINING, exp)
    // 50+ lines of old switch/if logic for rank-up checks
```

**Issues:**
1. ❌ **Duplicate rank variables** at global scope (should only exist in character datum)
2. ❌ **Dead code** - `MNLvl()` proc never called (modernized to `UpdateRankExp()`)
3. ❌ **No E-key support** - Only DblClick via old system
4. ❌ **Exp awards not using unified system** - Likely hardcoded values

**Improvements Needed:**
- ✂️ Delete old var declarations (lines 1-50)
- ✂️ Delete deprecated `MNLvl()` proc
- Verify all mining XP calls use `UpdateRankExp(RANK_MINING, amount)`
- Add `UseObject()` to Rocks/SRocks/HRocks/VRocks for E-key support

---

### 4. WOODCUTTING/HARVESTING ❌ **MASSIVE LEGACY**

**Status:** 1790-line file with extensive deprecated code

**Files:**
- `dm/WC.dm` (1790 lines) - Heavily deprecated; only biome system is modern

**Old Rank Code Found:**
```dm
var
    hrank=1             // DEPRECATED
    hrankEXP=0          // DEPRECATED
    hrankMAXEXP=10      // DEPRECATED
    Crank=1             // DEPRECATED (Carving rank)
    CSRank=1            // DEPRECATED (Sprout-cutting rank)
    PLRank=1            // DEPRECATED (Pole rank)
    // ... 20+ old rank vars

proc/WCLvl()           // DEPRECATED
    if(hrank>=5)
        // 50+ lines checking old rank system
        
proc/CLvl()            // DEPRECATED
    // Carving rank level-up (50+ lines)
    
proc/CSLvl()           // DEPRECATED
    // Sprout-cutting rank level-up (50+ lines)
```

**Issues:**
1. ❌ **Extreme code bloat** - 1790 lines for what should be ~300
2. ❌ **Multiple abandoned rank systems** - hrank, Crank, CSRank, PLRank all have separate old logic
3. ❌ **No E-key integration** - Trees still rely on old DblClick
4. ❌ **Dead procs** - `WCLvl()`, `CLvl()`, `CSLvl()` never called
5. ⚠️ **Mixed implementations** - Some sprout-cutting uses new system, some uses old

**Improvements Needed:**
- ✂️ Remove all global rank vars (1-50 lines) - Move to character datum only
- ✂️ Delete deprecated procs: `WCLvl()`, `CLvl()`, `CSLvl()`, `PLvl()` if exists
- Consolidate to unified UpdateRankExp() pattern for hrank, Crank, CSRank
- Add UseObject() to tree types for E-key support
- Verify sprout-cutting uses RANK_SPROUT_CUTTING constant

---

### 5. CRAFTING/COOKING ⚠️ **MODERN LOGIC, NO MACRO**

**Status:** Rank progression works, but UI is verb-based

**Files:**
- `dm/CookingSystem.dm` - Modern recipe system
- `dm/Objects.dm` - Cooking() verb on cooking stations

**Current Pattern:**
```dm
// PARTIAL PATTERN
proc/CookRecipe(mob/players/M, recipe_name)
    M.character.UpdateRankExp(RANK_CRAFTING, xp_amount)  // ✅ Modern XP
    // But activated via: verb/Cooking() in Objects.dm
```

**Issues:**
1. ⚠️ **No E-key macro** - Must click cooking station then right-click verb
2. ⚠️ **UI popup required** - Cooking menu pops up instead of macro-driven
3. ✅ **Rank XP correct** - Uses UpdateRankExp() properly

**Improvements Needed:**
- Add `UseObject()` to cooking stations (forges, anvils, stoves)
- Replace Cooking() verb popup with macro-friendly interface
- Verify recipe selection doesn't block on input

---

### 6. GARDENING ⚠️ **MIXED - MOSTLY MODERN**

**Status:** Soil system modern, some edge cases remain

**Files:**
- `dm/FarmingIntegration.dm` - Modern gardening system
- `dm/GatheringExtensions.dm` - Soil/Deposit UseObject

**Current Pattern:**
```dm
// MOSTLY CORRECT
obj/Soil/UseObject(mob/user)
    user.DblClick(src)  // ⚠️ Falls back to old DblClick
    
// Should be:
obj/Soil/UseObject(mob/user)
    var/mob/players/M = user
    M.character.UpdateRankExp(RANK_GARDENING, exp_amount)
```

**Issues:**
1. ⚠️ **DblClick fallback** - Should have specialized handler
2. ⚠️ **Turf deposits inconsistent** - ClayDeposit, ObsidianField, Sand, TarPit call DblClick()

**Improvements Needed:**
- Create dedicated `HandleGardeningAction()` proc
- Replace DblClick() calls with direct rank XP updates
- Verify all soil types (richsoil, soil) use modern progression

---

### 7. SMITHING/SMELTING ⚠️ **MODERN LOGIC, NO MACRO**

**Status:** Rank system works, but interaction is verb-based

**Files:**
- `dm/Objects.dm` - Smithing(), Smelting() verbs (366+ lines)
- Modern rank integration via UpdateRankExp()

**Issues:**
1. ❌ **No E-key support** - Must right-click to access verbs
2. ⚠️ **Massive verb code** - 366+ lines of nested smithing logic in Objects.dm
3. ✅ **Modern XP** - Calls UpdateRankExp() correctly

**Improvements Needed:**
- Create `obj/Forge` and `obj/Anvil` with UseObject() handlers
- Add `obj/Smelter` with UseObject()
- Replace Smithing()/Smelting() verbs with macro-driven interface

---

### 8. BUILDING ❌ **NO MACRO SUPPORT**

**Status:** Modern rank system, but no interactive E-key

**Files:**
- `dm/BuildingMenuUI.dm` - Modern building system
- `dm/Objects.dm` - Building verbs (must right-click)

**Issues:**
1. ❌ **No E-key interaction** - Only via right-click verbs
2. ❌ **No UseObject() on buildable objects** - Walls, doors, foundations have no macro handler

**Improvements Needed:**
- Add `obj/Buildable/Wall` and subclasses with UseObject()
- Trigger building menu from macro instead of right-click
- Verify building XP uses UpdateRankExp()

---

### 9. DIGGING ❌ **HEAVY LEGACY (4500+ LINES)**

**Status:** Worst case - massive deprecated code

**Files:**
- `dm/jb.dm` (4500+ lines) - Heavily deprecated, mixed old/new

**Issues:**
1. ❌ **Extreme bloat** - 4500+ lines (likely 80% dead code)
2. ❌ **Old rank system** - drank, drankEXP variables at global scope
3. ❌ **Deprecated procs** - digging level-up logic (50+ lines per tier)
4. ❌ **No E-key** - Must use old verb system
5. ❌ **Mixed paradigms** - Some parts use new system, some old

**Improvements Needed:**
- ✂️ **MAJOR CLEANUP** - Audit entire file, remove dead code
- ✂️ Delete deprecated rank variables
- ✂️ Delete deprecated level-up procs
- Consolidate to UpdateRankExp(RANK_DIGGING, amount) pattern
- Add UseObject() to digging deposits

---

### 10. COMBAT ✅ **FULLY INTEGRATED**

**Status:** Modern, macro-driven, working

**Files:**
- `dm/MacroKeyCombatSystem.dm` - Complete macro integration
- `dm/CombatSystem.dm` - Modern rank progression
- `dm/UnifiedRankSystem.dm` - Handles XP

**Implementation:**
```dm
// CORRECT PATTERN
verb/macro_attack()
    M.character.UpdateRankExp(RANK_COMBAT, dmg_amount * 0.5)
```

**Strengths:**
- Full E-key macro support
- Modern rank progression
- Proper XP scaling

**Zero Issues** ✅

---

### 11-15. BOTANY, ARCHERY, WHITTLING, THROWING, DESTROYING ❌ **STUBS**

**Status:** Variables exist in CharacterData, no implementation

**Files:**
- `dm/CharacterData.dm` - Variable declarations only

**Issues:**
1. ❌ **No game systems** - No code to award XP or progress ranks
2. ❌ **Dead variables** - botany_rank, archery_xp, etc. exist but unused
3. ⚠️ **No constants** - No RANK_BOTANY, etc. defined (will cause issues if used)

**Status:** These are future-ready skeletons only. No integration needed yet.

---

## 🛠️ Integration Checklist

### Priority 1: Critical Fixes (Breaking/High Impact)

- [ ] **Fishing XP Integration** - Add UpdateRankExp() calls to FishingSystem.dm
- [ ] **Fishing Macro Upgrade** - Replace input popup with E-key + Q-key approach
- [ ] **Mining Cleanup** - Delete deprecated rank vars/procs from mining.dm (lines 1-50+)
- [ ] **Woodcutting Cleanup** - Delete deprecated code from WC.dm (lines 1-100+)
- [ ] **Digging Cleanup** - Audit jb.dm, remove dead code (major undertaking)

### Priority 2: Medium Improvements

- [ ] **Smithing Macro** - Add UseObject() to Forge/Anvil objects
- [ ] **Gardening Handlers** - Replace DblClick() with direct rank updates
- [ ] **Building Macro** - Add UseObject() to buildable structures
- [ ] **Smelting Macro** - Add UseObject() to Smelter objects
- [ ] **Crafting Cleanup** - Optimize cooking verb to macro interface

### Priority 3: Nice-to-Have

- [ ] **Define Stub Ranks** - Add RANK_BOTANY, RANK_ARCHERY constants if planned
- [ ] **Implement Botany** - Create full botany system (if desired)
- [ ] **Implement Archery** - Create archery system (if desired)
- [ ] **Whittling System** - Create carving/whittling subsystem (if desired)

---

## 📋 Code Pattern Standards

**All new skill integrations should follow this pattern:**

```dm
// MACRO SUPPORT
obj/CraftingStation
    UseObject(mob/user)
        if(user in range(1, src))
            var/mob/players/M = user
            // Trigger specialized action
            HandleCraftingAction(M, src)
            return 1
        return 0

// RANK XP INTEGRATION  
proc/HandleCraftingAction(mob/players/M, obj/station)
    // Check rank requirement
    if(!M.CheckRankRequirement(RANK_CRAFTING, 1))
        M << "You need Crafting rank 1 to use this."
        return
    
    // Perform action
    var/xp_earned = DoSomething()
    
    // Award XP using unified system
    M.UpdateRankExp(RANK_CRAFTING, xp_earned)
    M << "You gain [xp_earned] Crafting experience!"

// OBSOLETE PATTERN
verb/CraftingAction()           // ❌ DEPRECATED
    if(!CheckRankRequirement())
        return
    DoSomething()               // ❌ Manual XP award
    M.crankEXP += xp_earned     // ❌ Direct variable access
```

---

## 🎯 Implementation Order

**Recommended execution order:**

1. **Fishing** (Priority 1, ~2 hours) - Quick high-impact fix
2. **Mining** (Priority 1, ~1 hour) - Cleanup relatively straightforward
3. **Woodcutting** (Priority 1, ~2 hours) - Similar scope to mining
4. **Digging** (Priority 1, ~4-6 hours) - Huge file, major undertaking
5. **Smithing** (Priority 2, ~2 hours) - Add UseObject handlers
6. **Building** (Priority 2, ~1.5 hours) - Relatively small scope
7. **Gardening** (Priority 2, ~1 hour) - DblClick → direct calls
8. **Crafting** (Priority 2, ~1 hour) - UI polish
9. **Stubs** (Priority 3) - Only if implementing systems

---

## 🔒 Safeguards & Testing

**Before deploying any changes:**

```dm
// Build must succeed
dm: build - Pondera.dme
// Result: 0 errors

// Test rank progression
/test_rank_progression()
    var/mob/players/M = new
    var/start_level = M.GetRankLevel(RANK_FISHING)
    M.UpdateRankExp(RANK_FISHING, 1000)  // Award massive XP
    ASSERT(M.GetRankLevel(RANK_FISHING) > start_level, "Rank should increase")

// Verify no duplicate variables
grep "^var" mining.dm | grep "mrank"    // Should be 0 results (all in character datum)
```

---

## 📊 Expected Impact

### Lines of Code Impact:
- **Mining.dm**: -50 lines (old vars/procs)
- **WC.dm**: -100+ lines (old rank code)
- **jb.dm**: -500+ lines (massive cleanup)
- **GatheringExtensions.dm**: +50 lines (modern handlers)
- **FishingSystem.dm**: +30 lines (macro + XP integration)
- **Net impact**: ~-400 lines of dead code removed

### Performance Impact:
- ✅ **Better**: Fewer global variables, cleaner scoping
- ✅ **Better**: Unified rank system (O(1) lookups vs switch statements)
- ✅ **Better**: No DblClick fallback chains

### User Experience:
- ✅ **Better**: Consistent E-key interaction across all skills
- ✅ **Better**: No popup menus (all macro-driven)
- ✅ **Better**: Faster feedback on rank progression

---

## Summary Table

| System | Status | Macro | XP System | Lines | Action |
|---|---|---|---|---|---|
| Searching | ✅ Done | ✅ | ✅ | 211 | None |
| Fishing | ⚠️ Partial | ⚠️ | ⚠️ | 502 | Add XP, improve macro |
| Mining | ❌ Legacy | ❌ | ❌ | 1795 | Cleanup, add macro |
| Woodcutting | ❌ Legacy | ❌ | ❌ | 1790 | Cleanup, add macro |
| Crafting | ⚠️ Partial | ❌ | ✅ | 300+ | Add macro |
| Gardening | ⚠️ Partial | ⚠️ | ✅ | 200+ | Simplify handlers |
| Smithing | ⚠️ Partial | ❌ | ✅ | 366+ | Add macro, split verbs |
| Smelting | ⚠️ Partial | ❌ | ✅ | ~150 | Add macro |
| Building | ⚠️ Partial | ❌ | ✅ | 200+ | Add macro |
| Digging | ❌ Legacy | ❌ | ❌ | 4500+ | **MAJOR CLEANUP** |
| Combat | ✅ Done | ✅ | ✅ | 500+ | None |
| Botany-Destroy | ⚠️ Stubs | ❌ | ❌ | ~50 | Future work |

---

**Estimated Total Effort:** 15-20 hours of focused work to fully integrate all systems
**Quick Wins (3 systems):** 4-5 hours to get Searching, Fishing, Mining at production level
