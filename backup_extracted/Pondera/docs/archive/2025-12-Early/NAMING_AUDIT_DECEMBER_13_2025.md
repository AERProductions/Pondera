# Comprehensive Naming & Reference Audit - December 13, 2025

## Executive Summary

**Status**: 🔴 CRITICAL MISMATCHES FOUND - 5 Major Issues

This audit found naming inconsistencies between:
1. Modern unified rank system definitions (`!defines.dm`, `UnifiedRankSystem.dm`)
2. Legacy variable names in `CharacterData.dm` and `Basics.dm`
3. Code references across the codebase

**Impact**: Variables exist but reference inconsistencies could cause silent XP/level-up failures if old code paths are triggered.

---

## Issue #1: Carving vs Whittling - PARTIALLY FIXED

### Current Status
✅ **FIXED in !defines.dm** (as of this session)
- `RANK_CARVING = "whittling_rank"` ✅ Correct
- `RANK_WHITTLING = "whittling_rank"` ✅ Correct

❌ **LEGACY VARIABLES STILL EXIST** in CharacterData.dm
- `Crank = 0` (line 18) - Carving rank with CAPITAL C
- UnifiedRankSystem expects: `whittling_rank`, `whittling_xp`, `whittling_maxexp`
- CharacterData ALSO has: `Crank`, `CrankEXP`, `CrankMAXEXP` (lines 18, 41, 61)

### References Found
- `CharacterData.dm` lines 18, 41, 61: Declare legacy `Crank`, `CrankEXP`, `CrankMAXEXP`
- `Basics.dm` lines 204-205: Reset `CrankEXP=0, CrankMAXEXP=10` on character creation
- `CharacterData.dm` lines 327-330: Switch case handles `"Crank"` explicitly

### Risk Level
🟡 **MEDIUM** - Legacy variables exist but may not be used if code uses unified system. However, if any code directly accesses `M.character.Crank`, it won't sync with `M.character.whittling_rank`.

### Recommendation
1. Keep `Crank` variables for savefile compatibility (old saves reference them)
2. OR: Add migration in `SavefileVersioning.dm` to rename `Crank` → `whittling_rank`
3. Ensure all code uses RANK_CARVING macro (not hardcoded "Crank" strings)

---

## Issue #2: Sprout Cutting vs Botany - CRITICAL MISMATCH

### Current Status
✅ **DEFINES ARE CORRECT** as of this session
- `RANK_SPROUT_CUTTING = "botany_rank"` ✅ Correct (points to right var)
- `RANK_BOTANY = "botany_rank"` ✅ Correct (same backing var)
- `RANK_SPROUTING = "botany_rank"` ✅ Correct (legacy alias)

❌ **LEGACY VARIABLES NOT REMOVED** from CharacterData.dm
- `CSRank = 0` (line 19) - Sprout Cutting rank with CS prefix
- `CSRankEXP = 0` (line 42) - Experience for Sprout Cutting
- `CSRankMAXEXP = 10` (line 62) - Max experience threshold
- UnifiedRankSystem.dm DOES register botany under correct vars (line 41)

### References Found
- `CharacterData.dm` lines 19, 42, 62: Declare legacy `CSRank`, `CSRankEXP`, `CSRankMAXEXP`
- `Basics.dm` lines 206-208: Reset CSRank vars on character creation
- `Basics.dm` line 2022: HUD stat panel displays "Botany" using CSRank (correct!)
- `CharacterData.dm` lines 339-340, 368-369, 432-436: Switch cases handle `"CSRank"` explicitly

### Risk Level
🔴 **HIGH** - The HUD displays Botany rank correctly (line 2022), but the underlying variables don't match the unified system registry. If modern code (like `UpdateRankExp()`) uses `botany_rank` variables while old code uses `CSRank`, they won't sync.

### What Should Happen
```dm
// Modern system (UnifiedRankSystem.dm line 41)
RANK_DEFINITIONS[RANK_BOTANY] = list("botany_rank", "botany_xp", "botany_maxexp", ...)

// But CharacterData has
var/CSRank = 0          // OLD
var/botany_rank = 0     // NEW

// Result: Code updating "botany_xp" won't affect "CSRankEXP"
```

### Recommendation
1. Remove `CSRank`, `CSRankEXP`, `CSRankMAXEXP` from CharacterData.dm
2. Migrate any old references to use `botany_rank` instead
3. Update SavefileVersioning to handle old save migration (if needed)

---

## Issue #3: Pole Carving vs Whittling - DUPLICATE NAMING

### Current Status
✅ **DEFINES CORRECT**
- `RANK_POLE = "whittling_rank"` ✅ (pole carving is a whittling specialization)
- `RANK_WHITTLING = "whittling_rank"` ✅ (both use same backing var)

❌ **LEGACY VARIABLES NOT REMOVED**
- `PLRank = 0` (line 20) - Pole carving rank with PL prefix
- `PLRankEXP = 0` (line 43) - Experience for pole carving
- `PLRankMAXEXP = 100` (line 63) - Max experience
- These should be consolidated into `whittling_rank` variables

### References Found
- `CharacterData.dm` lines 20, 43, 63: Declare legacy `PLRank`, `PLRankEXP`, `PLRankMAXEXP`
- `Basics.dm` lines 209-211: Reset PLRank vars on character creation
- `Basics.dm` lines 1887-1894: Entire XP level-up loop for PLRank (legacy code path!)
- `CharacterData.dm` lines 341-342, 370-371, 437-441: Switch cases handle `"PLRank"` explicitly

### Risk Level
🟡 **MEDIUM-HIGH** - Active legacy code path in `Basics.dm` lines 1887-1894 still processes PLRank independently, won't sync with modern `whittling_rank` system.

### Recommendation
1. Remove `PLRank`, `PLRankEXP`, `PLRankMAXEXP` from CharacterData
2. Remove legacy PLRank level-up loop from Basics.dm (lines 1887-1894)
3. Ensure RANK_POLE macro is used instead of hardcoded "PLRank" strings

---

## Issue #4: Carving (Crafting) vs Crank Capitalization

### Current Status
✅ **DEFINES CORRECT**
- `RANK_CRAFTING = "crafting_rank"` ✅ (from !defines.dm)

❌ **INCONSISTENT CAPITALIZATION**
- UnifiedRankSystem registers: `"crank"` (lowercase)
- CharacterData declares: `crank` (lowercase) ✅
- BUT ALSO declares: `Crank` (CAPITAL C) for Carving - WRONG!

### References Found
- `UnifiedRankSystem.dm` line 39: `RANK_DEFINITIONS[RANK_CRAFTING] = list("crank", "crankEXP", "crankMAXEXP", ...)`
- `CharacterData.dm` line 10: `crank = 0` ✅ Correct (crafting)
- `CharacterData.dm` line 18: `Crank = 0` ❌ Wrong (should be lowercase for consistency, or use `whittling_rank`)
- `ItemInspectionSystem.dm` lines 191, 201, 296, 304, 310, 332, 516, 573: All use lowercase `"crank"` ✅
- `LoginUIManager.dm` lines 61, 69: Use lowercase `crank` ✅

### Risk Level
🟡 **MEDIUM** - Capitalization is internally consistent for Crafting, but `Crank` (capital) is declared for Carving and could cause confusion.

### Root Cause
Legacy codebase had mixed capitalization (WC.dm declared `Crank`, `CSRank`, `PLRank` as globals). This was fixed by moving to CharacterData, but the legacy names weren't removed.

---

## Issue #5: Building XP Still Uses Old Variable

### Current Status
❌ **NOT UNIFIED**
- Old system: `M.buildexp += N` (direct variable access)
- Modern system: `M.UpdateRankExp(RANK_BUILDING, exp)` (unified call)

### References Found
- `Basics.dm` lines 189, 199: Declare `buildexp=0, mbuildexp=100` on character creation
- `Basics.dm` lines 518, 694: Reset `buildexp=0` on respawn
- `Basics.dm` lines 1813-1819: Legacy building XP level-up loop (same pattern as PLRank!)
- `jb.dm` (building system): Uses `M.buildexp += N` for awards

### Risk Level
🔴 **HIGH** - Building progression is completely separate from unified rank system. When players build, they gain building XP in the OLD system, not the unified modern system.

### Expected Behavior
Building should use: `M.UpdateRankExp(RANK_BUILDING, exp_amount)`
Instead it uses: `M.buildexp += N`

### Impact
- Building rank progression won't sync with other systems
- HUD may not display properly if checking `brank` instead of `buildexp`
- Savefile versioning won't handle building rank properly

---

## Audit Results Summary

| Issue | System | Current | Expected | Risk | Status |
|-------|--------|---------|----------|------|--------|
| **Carving/Whittling** | CharacterData | `Crank` + `whittling_rank` | Only `whittling_rank` | 🟡 MEDIUM | Partial fix |
| **Sprout Cutting/Botany** | CharacterData | `CSRank` + `botany_rank` | Only `botany_rank` | 🔴 HIGH | Mismatch |
| **Pole/Whittling** | CharacterData | `PLRank` + `whittling_rank` | Only `whittling_rank` | 🔴 MEDIUM-HIGH | Duplicate |
| **Crafting Crank** | CharacterData | Capitalized `Crank` | Lowercase `crank` | 🟡 MEDIUM | Wrong var for Carving |
| **Building XP** | Basics/jb.dm | `buildexp` (old) | `brank` (unified) | 🔴 HIGH | Completely separate |

---

## What Compiled But Shouldn't

All code compiles because:
1. Variables declared in CharacterData exist ✅
2. Macros defined in !defines.dm exist ✅
3. Switch statements handle both old and new names ✅

BUT:
- If code path A updates `botany_xp` and code path B reads `CSRankEXP`, they won't match
- If one system loads from savefile as `CSRank` and another writes as `botany_rank`, desync happens
- Building progression is completely isolated from unified rank tracking

---

## Files Requiring Updates

1. **CharacterData.dm** - Remove legacy Crank, CSRank, PLRank variables
2. **Basics.dm** - Remove legacy variable resets and level-up loops
3. **jb.dm** - Update building XP to use unified system
4. **SavefileVersioning.dm** - Add migration for old save format
5. **Optional: UnifiedRankSystem.dm** - Add sanity check that all registered ranks exist in CharacterData

---

## Implementation Priority

**TIER 1 (Do First - High Impact)**
1. Remove CSRank variables (Botany uses these currently)
2. Remove PLRank variables (Active legacy code in Basics.dm)
3. Unify building XP to use `brank` system

**TIER 2 (Do Second - Medium Impact)**
1. Remove Crank variables (not actively used if using RANK_CARVING macro)
2. Update legacy code paths in Basics.dm

**TIER 3 (Do Later - Documentation)**
1. Verify SavefileVersioning handles migrations
2. Test with old save files to confirm compatibility

---

## Build Status

✅ **Compiles cleanly** (0 errors, 0 warnings) - These are logic/runtime issues, not syntax errors

---

## Testing Strategy

After fixes:
1. Create new character in each class
2. Check that rank variables match (e.g., `M.character.botany_rank == M.character.CSRank`)
3. Award XP and verify both vars update
4. Load old save file and verify migration
5. Test building progression with new unified system

---

**Audit Date**: December 13, 2025  
**Auditor**: System Audit Pass 2  
**Session**: Carving→Whittling Consolidation + Legacy Reference Cleanup
