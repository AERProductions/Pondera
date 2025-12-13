# Unified Rank System - Migration Guide

**For Developers**: How to gradually migrate existing code to use the new unified system.

## Quick Reference

### Before (Old Pattern)
```dm
// Direct variable manipulation + manual level-up logic
M.grankEXP += 15
if(M.grankEXP >= M.grankMAXEXP) {
    M.grankEXP -= M.grankMAXEXP
    M.grank++
    if(M.grank > 5) M.grank = 5
    M << "You gain Gardening Acuity!"
    M.UpdateRankUI(???)  // If even implemented
}
```

### After (New Pattern)
```dm
// Single function - handles everything
M.UpdateRankExp(RANK_GARDENING, 15)
```

## Migration by File

### Priority 1: Highest Impact (Most Duplicated Code)

#### File: plant.dm
**Current State**: Gardening rank directly manipulates grankEXP
**Lines to Change**: Search for `grankEXP` and `grank` assignments
**Changes Required**: 
- Replace `M.grankEXP += X` with `M.UpdateRankExp(RANK_GARDENING, X)`
- Remove manual level-up checks (now handled by UpdateRankExp)

```dm
// OLD (in plant.dm):
/obj/plant/proc/CheckGrowth()
    // ...
    player.grankEXP += 5
    if(player.grankEXP >= player.grankMAXEXP) {
        player.grankEXP = 0
        player.grank++
        // ...
    }

// NEW:
/obj/plant/proc/CheckGrowth()
    // ...
    player.UpdateRankExp(RANK_GARDENING, 5)
```

**Migration Status**: ⏳ Not started

#### File: mining.dm
**Current State**: Mining rank in separate file
**Lines to Change**: Search for `mrankEXP`, `mrank` assignments
**Changes Required**:
- Replace `M.mrankEXP += X` with `M.UpdateRankExp(RANK_MINING, X)`
- Remove manual level-up checks

**Migration Status**: ⏳ Not started

#### File: WC.dm (Woodcutting, Carving, Pole)
**Current State**: 3 rank types with scattered exp gain logic
**Lines to Change**: Search for:
- `hrankEXP`, `hrank` (woodcutting)
- `CrankEXP`, `Crank` (carving)
- `PLRankEXP`, `PLRank` (pole)

**Changes Required**:
- Replace all direct variable manipulation
- Use UpdateRankExp(rank_type, exp_gain)

**Special Note**: These were moved from global var to mob/players/var, so double-check scoping.

**Migration Status**: ⏳ Not started

#### File: Weapons.dm
**Current State**: Weapon-related rank checks
**Lines to Change**: Search for rank level requirements
**Changes Required**:
- Replace `if(player.mrank >= 3)` with `if(player.CheckRankRequirement(RANK_MINING, 3))`

**Migration Status**: ⏳ Not started

#### File: Objects.dm
**Current State**: Various object/resource rank interactions
**Lines to Change**: Similar pattern to Weapons.dm
**Changes Required**:
- Refactor rank checks
- Consolidate exp gain logic

**Migration Status**: ⏳ Not started

### Priority 2: Medium Impact (Moderate Duplication)

#### File: Basics.dm
**Current State**: Rank variables declared here
**Changes Required**:
- May have scattered rank-related logic
- Search for direct variable manipulation
- Replace with API calls

**Migration Status**: ✅ Variables consolidated (done in current session)

#### File: SteelToolsEquip.dm / SteelToolsUnequip.dm
**Current State**: New files from steel tools feature
**Changes Required**:
- Should already use proper patterns (relatively new code)
- Verify no legacy rank patterns

**Migration Status**: ⏳ Check for compatibility

### Priority 3: Lower Impact (Less Duplication)

#### File: time.dm, timesave.dm
**Current State**: Time-based rank growth
**Changes Required**:
- If implementing passive exp gain, use UpdateRankExp()

**Migration Status**: ⏳ Check for time-based rank logic

## Step-by-Step Migration Process

### For Each File:

**Step 1: Identify**
```powershell
# Search for all rank-related lines
grep -E "rankEXP|rank\s*\+\+|rank\s*=" <filename>.dm
```

**Step 2: Document**
Create a list of all changes needed (search output)

**Step 3: Categorize Patterns**

**Pattern A: Direct Exp Gain**
```dm
// OLD
M.grankEXP += 15

// NEW
M.UpdateRankExp(RANK_GARDENING, 15)
```

**Pattern B: Level-Up Logic**
```dm
// OLD
if(M.grankEXP >= M.grankMAXEXP) {
    M.grankEXP = 0
    M.grank++
}

// NEW (DELETED - now in UpdateRankExp)
// Just call UpdateRankExp() above
```

**Pattern C: Requirement Checking**
```dm
// OLD
if(M.mrank >= 3) { /* allow action */ }

// NEW
if(M.CheckRankRequirement(RANK_MINING, 3)) { /* allow action */ }
```

**Pattern D: UI Updates**
```dm
// OLD (variable location specific, inconsistent)
// Might be: update_bar(), UpdateRankUI(), or manual screen object manipulation

// NEW (consistent)
M.UpdateRankUI(RANK_MINING)
// (Already called by UpdateRankExp, but available if needed separately)
```

**Step 4: Edit and Test**

1. Edit file to replace patterns
2. Build: `dm: build - Pondera.dme` (should compile with 0 errors)
3. Test in-game:
   - Log in
   - Perform rank-related action
   - Check that:
     - Exp increments correctly
     - UI updates
     - Level-ups trigger
     - Notifications display

**Step 5: Commit**
```bash
git add <filename>.dm
git commit -m "refactor: Migrate <filename> to use UnifiedRankSystem

- Replace direct rank variable manipulation with UpdateRankExp()
- Remove duplicate level-up logic now in centralized system
- Use CheckRankRequirement() for validation
- Standardize UI updates via UpdateRankUI()
"
```

## Testing Checklist

After each file migration, verify:

### Exp Gain
- [ ] Correct exp amount added
- [ ] Exp clamped to valid range (0 to max_exp)
- [ ] Overflow exp carries to next level

### Level-Up
- [ ] Level increases when threshold met
- [ ] Level capped at MAX_RANK_LEVEL (5)
- [ ] Player notification displays
- [ ] UI progress bar updates correctly

### Requirements
- [ ] CheckRankRequirement() returns correct value
- [ ] Actions allowed/blocked based on level
- [ ] Error messages display if needed

### Backward Compatibility
- [ ] Old code using direct variables still works
- [ ] No breaking changes to other systems
- [ ] Player save/load unchanged

## Risk Assessment

### Low Risk
- Exp gain replacements (very straightforward)
- UI update consolidation
- Requirement checking

### Medium Risk
- Level-up logic (ensure exp overflow handled correctly)
- Max level enforcement
- Player notifications

### High Risk
- If SaveGame/LoadGame directly reference rank variables
- If UI display logic varies per rank type
- If level-up has complex side effects (abilities unlocked, etc.)

**Mitigation**: Test thoroughly in-game before committing.

## Rollback Plan

If migration breaks something:

```bash
# Revert single file to previous version:
git checkout HEAD~1 <filename>.dm
git commit -m "revert: Restore <filename> - unified rank system migration issue"

# Diagnose problem
# Fix UnifiedRankSystem.dm if needed
# Re-migrate file
```

## Consolidated Leveling Procedures

### Current Scattered Implementations
The codebase currently has individual proc names for leveling:
- CLvl() - Crafting level up
- CSLvl() - Sprout cutting level up
- HLvl() - Harvesting/Woodcutting level up
- MLvl() - Mining level up
- etc.

Each likely has duplicated logic for:
- Level increment
- Max level check
- Exp reset
- Player notification
- Potential side effects (unlock new actions, etc.)

### Future Consolidation (Phase 3)
Once individual file migration complete, consolidate these into unified proc:

```dm
/mob/players/proc/LevelUpRank(rank_type)
    // Single implementation handles all level-ups
    // Calls AdvanceRank() for core logic
    // Handles rank-specific side effects
    // Displays notification
    // Updates UI
```

This would further reduce code duplication (~30-50 lines saved per old proc).

## Success Metrics

**Before Unified System**:
- 12 rank types with duplicate level-up logic
- Scattered exp gain checks across 6+ files
- 500+ lines of duplicate code
- Inconsistent UI updates
- Variable scoping issues (global vars)

**After Full Migration**:
- Single UpdateRankExp() function
- Consistent exp handling everywhere
- ~350 lines consolidated into 1 file (UnifiedRankSystem.dm)
- Standardized UI updates
- Proper scoping (per-player)

**Target**: Eliminate 80% of rank-related code duplication.

## Questions & Troubleshooting

### "UpdateRankExp() doesn't exist after rebuild"
- Check that UnifiedRankSystem.dm is included in Pondera.dme
- Verify it's included AFTER Basics.dm (where variables are declared)
- Check spelling: RANK_GARDENING (not grank directly)

### "Level-up happens twice for same exp"
- Check you're not calling both old code AND UpdateRankExp()
- Remove old duplicate level-up logic
- Verify exp threshold is correct

### "UI doesn't update after level-up"
- UpdateRankExp() calls UpdateRankUI() automatically
- If UI still not updating, check that UpdateRankUI() implementation exists
- Verify rank type maps to correct UI element in UpdateRankUI()

### "Requirement check always fails"
- Verify you're using CheckRankRequirement(rank_type, level), not direct comparison
- Check that rank_type constant matches actual var name
- Verify player's level is >= required level

## Timeline Estimate

- **Priority 1 files**: ~4-6 hours
  - plant.dm: ~1.5 hours (searching, editing, testing)
  - mining.dm: ~1.5 hours
  - WC.dm: ~2 hours (3 rank types)
  - Weapons.dm: ~1 hour

- **Priority 2 files**: ~2-3 hours
  - Objects.dm: ~1.5 hours
  - SteelToolsEquip.dm: ~30 min
  - Others: ~1 hour

- **Priority 3 files**: ~1-2 hours
  - Various: searching, editing, testing

- **Phase 3 (Optional)**: ~3-4 hours
  - Consolidate individual leveling procedures
  - Create unified LevelUpRank()
  - Remove old CLvl, HLvl, etc.

**Total Full Migration**: ~10-15 hours of development
