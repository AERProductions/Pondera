# Comprehensive Variable Naming & Architecture Audit
## Phase 2: Full System Scan

**Date**: December 13, 2025  
**Duration**: Complete codebase audit  
**Status**: COMPLETE - 8 Major Issues Identified

---

## Summary of Findings

| Category | Issue Count | Severity | Impact |
|----------|------------|----------|--------|
| **Rank/Skill Variables** | 3 | 🔴 HIGH | XP progression desync |
| **Building System** | 1 | 🔴 HIGH | Separate from unified ranks |
| **Fishing System** | 1 | 🟡 MEDIUM | Legacy variable access patterns |
| **Core Stats (HP/Stamina)** | 2 | 🟡 MEDIUM | Capitalization inconsistency |
| **UI/HUD Elements** | 1 | 🟡 MEDIUM | Display naming confusion |

**Total Architectural Issues**: 8 categories  
**Total Code Instances**: 100+ scattered references  
**Compilation Status**: ✅ Clean (hides runtime bugs)

---

## Issue #1: Building XP - Completely Separate System 🔴 CRITICAL

### Current State
- Building progression tracked in OLD variables: `buildexp`, `mbuildexp`
- Modern unified rank system: `character.brank`, `character.brankEXP`, `character.brankMAXEXP`
- **These are completely separate systems**

### Evidence
- `jb.dm` lines 1292-3899: **95+ instances** of `M.buildexp +=` scattered throughout building functions
- `Basics.dm` lines 189, 199: Legacy variables initialized on character creation
- `Basics.dm` lines 1800-1820: Old `updateBXP()` loop for building XP level-up

### Example Mismatch
```dm
// Building creates something → awards XP in OLD system:
M.buildexp += 25

// But unified rank system tracks via:
character.brankEXP (modern var)

// Result: Building progression invisible to modern systems
```

### Risk Level
🔴 **CRITICAL** - Building is only skill still using completely separate XP tracking

### Files with Issues
- `dm/jb.dm` - 95+ instances of `M.buildexp +=`
- `dm/Basics.dm` - Variable initialization + old level-up loop

### Solution
1. Replace all `M.buildexp += X` with `M.character.UpdateRankExp(RANK_BUILDING, X)`
2. Remove old `buildexp`, `mbuildexp` initialization
3. Remove old `updateBXP()` function
4. Update HUD to display `character.brank` instead of building XP

---

## Issue #2: Fishing System - Legacy Variable Access 🟡 MEDIUM

### Current State
- Fishing uses OLD player-level variables: `fishinglevel`, `fexp`, `fexpneeded`
- Modern system has: `character.frank`, `character.frankEXP`, `character.frankMAXEXP`
- **Both variables exist but separately tracked**

### Evidence
- `FishingSystem.dm` lines 266, 368-369: Uses old variables `angler.fishinglevel`, `angler.fexp`
- `Light.dm` lines 841-1103: 7 instances checking `M.fishinglevel >= 5`
- `Lightlegacyexample.dm` lines 890-1152: Same pattern

### Example Pattern
```dm
// Modern system should be:
var/skill_level = angler.character.frank || 1
angler.character.frankEXP += xp_gained

// But actually uses:
var/skill_level = angler.fishinglevel || 1
angler.fexp += xp_gained
```

### Risk Level
🟡 **MEDIUM** - Works for now, but diverges from unified rank pattern

### Files with Issues
- `dm/FishingSystem.dm` - Using old player-level fishing vars
- `dm/Light.dm` - Checking old fishinglevel variable (7 instances)

### Solution
1. Replace `angler.fishinglevel` with `angler.character.frank`
2. Replace `angler.fexp` with `angler.character.frankEXP`
3. Update checks to use character datum access pattern

---

## Issue #3: Core Stats - Capitalization Inconsistency 🟡 MEDIUM

### Current State
**HP Variables**:
- Sometimes: `M.HP`, `M.MAXHP` (UPPERCASE)
- Sometimes: `M.hp`, `M.maxhp` (lowercase)
- Character data vars: `mhp`, `maxhp` (lowercase)

**Stamina Variables**:
- Sometimes: `M.stamina`, `M.MAXstamina` (Mixed case)
- Sometimes: `M.maxstamina` (lowercase)
- Character data vars: `stamina`, `maxstamina`

### Evidence
- `toolslegacyexample.dm` lines 9985-10015: Uses `M.HP`, `M.MAXHP` (UPPERCASE)
- `mapgen/_water.dm` lines 81-1028: Uses `M.stamina`, `M.MAXstamina` (mixed)
- `Basics.dm` lines 1270-1302: Uses `M.MAXHP`, `M.MAXstamina` (mixed)

### Example Mismatch
```dm
// This works:
M.HP -= damage
M.stamina += restore_amount

// But character creation initializes:
mhp = 100
maxhp = 100
stamina = 100
maxstamina = 100

// Neither clearly marked as M.HP vs M.mhp
```

### Risk Level
🟡 **MEDIUM** - Works due to case-insensitive variable matching, but confusing

### Files with Issues
- `dm/Basics.dm` - Mixed capitalization throughout
- `mapgen/_water.dm` - Inconsistent stamina naming
- `toolslegacyexample.dm` - HP uses ALL CAPS

### Solution
1. Standardize to lowercase: `M.hp`, `M.maxhp`, `M.stamina`, `M.maxstamina`
2. Update all references across codebase
3. Verify character data var names match player var names

---

## Issue #4: Fishing Level-Up Calculation - Wrong Pattern 🟡 MEDIUM

### Current State
```dm
// FishingSystem.dm line 369:
angler.fishinglevel = max(angler.fishinglevel + 1, round((angler.fexp / 100) + 1))
```

**Problem**: This is non-standard. Modern ranks use unified `UpdateRankExp()` which handles level-ups correctly.

### Evidence
- `FishingSystem.dm` line 369 - Fishing does its own level-up math
- Modern system: `character.UpdateRankExp(rank_type, exp)` handles all level-up logic

### Risk Level
🟡 **MEDIUM** - Works but diverges from standard architecture

### Solution
Use unified rank system for all XP handling (already exists)

---

## Issue #5: UI/HUD Element Naming - Outdated Labels 🟡 MEDIUM

### Current State
- HUD displays skill names like "Carving", "Botany" (now renamed)
- Previously displayed old variable names that no longer exist
- **Fixed earlier this session**, but pattern shows HUD is brittle

### Evidence
- `Basics.dm` line 2012-2013 - Fixed earlier to use modern names
- Shows HUD is tightly coupled to variable names

### Risk Level
🟡 **MEDIUM** - Would break if variables renamed without updating HUD

### Solution
HUD should use unified rank system constants + display names, not variable names

---

## Issue #6: Experience Variables - Inconsistent Naming 🟡 MEDIUM-LOW

### Current State
Rank experience variables use inconsistent suffixes:
- `frankEXP` (Fishing)
- `crankEXP` (Crafting)
- `grankEXP` (Gardening)
- But: `botany_xp`, `whittling_xp`, `archery_xp` (underscores)

### Evidence
- `CharacterData.dm` lines 32-47 - Mix of both naming patterns
- Old ranks: `*EXP` suffix
- New ranks: `*_xp` suffix

### Risk Level
🟡 **LOW-MEDIUM** - Cosmetic inconsistency, but confusing

### Solution
1. Standardize to one pattern (recommend `*_xp` for consistency)
2. Or: Standardize to `*_exp` for all
3. Update all 15 rank types to match

---

## Issue #7: Experience Threshold Variables - Inconsistent Naming 🟡 LOW-MEDIUM

### Current State
Max experience variables also mix naming:
- `frankMAXEXP` (Fishing)
- `crankMAXEXP` (Crafting)
- But: `botany_maxexp`, `whittling_maxexp`, `archery_maxexp` (underscores)

### Evidence
- Same as Issue #6 - split between old and new naming

### Solution
- Standardize to one pattern across all ranks
- Recommend `*_maxexp` for consistency with `*_xp`

---

## Issue #8: Combat Level System - Orphaned Variables 🟡 LOW

### Current State
- `combat_rank` exists in CharacterData
- `combat_xp` exists in CharacterData
- But no corresponding `combat_maxexp` defined
- No registration in UnifiedRankSystem

### Evidence
- `CharacterData.dm` line 25: `combat_rank = 1` (1-5 system)
- `CharacterData.dm` line 47: `combat_xp = 0`
- No `combat_maxexp` defined
- UnifiedRankSystem.dm doesn't register RANK_COMBAT in RANK_DEFINITIONS

### Risk Level
🟡 **LOW** - Combat system works independently, but inconsistent with unified pattern

### Solution
1. Define `combat_maxexp` in CharacterData
2. Add `RANK_COMBAT` registration in UnifiedRankSystem
3. Document whether combat uses unified progression or separate system

---

## Consolidated Issue Summary

### By Severity

🔴 **CRITICAL** (Must Fix):
- **Building XP System** - Completely separate, 95+ code instances need updating

🟡 **MEDIUM** (Should Fix):
- **Fishing System** - Legacy variable access pattern
- **Core Stats Capitalization** - hp/HP inconsistency
- **Experience Naming** - Mixed `*EXP` vs `*_xp` patterns

🟡 **LOW** (Nice to Fix):
- **Combat System** - Orphaned registration
- **UI Element Naming** - Brittle to variable renames

---

## Architecture Patterns Found

### Pattern 1: OLD SYSTEM (Pre-Unification)
Variables stored on player directly:
```dm
var/fishinglevel = 1
var/fexp = 0
var/fexpneeded = 100
```
**Used by**: Fishing system  
**Status**: Still functional but inconsistent

### Pattern 2: LEGACY SYSTEM (Transitional)
Capitalized rank names:
```dm
var/frank = 0              // Fishing rank
var/frankEXP = 0          // Fishing XP
var/frankMAXEXP = 100     // Max per level
```
**Used by**: 10 older ranks  
**Status**: Works with UnifiedRankSystem

### Pattern 3: MODERN SYSTEM (Current Standard)
Underscored rank names:
```dm
var/botany_rank = 0        // Botany rank
var/botany_xp = 0          // Botany XP
var/botany_maxexp = 100    // Max per level
```
**Used by**: Botany, Whittling, Archery, Crossbow, Throwing  
**Status**: Best practice, should extend to all

---

## Migration Strategy

### Phase A: Building System (CRITICAL)
1. Replace all 95+ `M.buildexp +=` with `M.character.UpdateRankExp(RANK_BUILDING, amount)`
2. Remove legacy buildexp initialization
3. Remove old updateBXP() function
4. **Effort**: 2-3 hours
5. **Impact**: HIGH

### Phase B: Fishing System (MEDIUM)
1. Replace `angler.fishinglevel` → `angler.character.frank`
2. Replace `angler.fexp` → `angler.character.frankEXP`
3. Update all checks in Light.dm and FishingSystem.dm
4. **Effort**: 1-2 hours
5. **Impact**: MEDIUM

### Phase C: Naming Standardization (MEDIUM)
1. Rename all `*EXP` to `*_xp` for consistency
2. Rename all `*MAXEXP` to `*_maxexp` for consistency
3. Update UnifiedRankSystem registry
4. **Effort**: 1 hour
5. **Impact**: LOW (cosmetic, but improves readability)

### Phase D: Core Stats Capitalization (MEDIUM)
1. Standardize HP to lowercase: `hp`, `maxhp`
2. Standardize Stamina to lowercase: `stamina`, `maxstamina`
3. Update all references across Basics.dm, Water.dm, etc.
4. **Effort**: 1-2 hours
5. **Impact**: MEDIUM (prevents future bugs)

### Phase E: Combat System Completion (LOW)
1. Define missing `combat_maxexp`
2. Register in UnifiedRankSystem
3. **Effort**: 30 minutes
4. **Impact**: LOW

---

## Build Status

✅ **Current**: 0 errors, 0 warnings (as of 9:41 am)

All issues compile cleanly because they're logic/design issues, not syntax errors.

---

## Recommendation

**Do we tackle these systematically?**

Current issues hide behind compiler because:
- Variables exist (no compilation error)
- Code runs (no runtime crash)
- But: Desync between systems (silent logic bugs)

**Suggested approach**:
1. **Immediately**: Phase A (Building - 1-2 hours, highest impact)
2. **Soon**: Phase B (Fishing - 1 hour, medium impact)
3. **Later**: Phase C + D (Naming standardization - 2-3 hours, quality improvement)
4. **Last**: Phase E (Combat completion - 30 min, low impact)

---

**Next steps**: Shall we proceed with Phase A (Building System unification)?

