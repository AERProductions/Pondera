# Additional Improvements & Corrections - Session December 13, 2025

## OVERVIEW
Beyond the three major initiatives (Carving unification, Equipment system selection, Deed permission audit, Building modernization), several other improvements were identified.

---

## CATEGORY 1: ANTI-PATTERN CODE (High Priority)

### Issue 1.1: Goto Statements in plant.dm
**Severity**: 🟠 **MEDIUM**  
**Impact**: Code readability, maintainability  
**Locations**: plant.dm (lines 1615-1635, 1709-1729, 1795-1815)

**Current Pattern**:
```dm
var/obj/DeedToken/dt
dt = locate(oview(src,15))
if(!dt)
    goto NXT
for(dt)
    if(M.canbuild==1)
        goto NEXT
    else
        return
NEXT
NXT
```

**Recommendation**: Replace with if/else blocks (Covered in deed permission audit)

**Timeline**: Phase 6-7 (as part of deed unification)

---

### Issue 1.2: While(1) Infinite Loops (set waitfor = 0)
**Severity**: 🟢 **LOW** (intentional pattern)  
**Impact**: Performance, debuggability  
**Locations**: CrisisEventsSystem.dm (line 348), others

**Current Pattern**:
```dm
proc/CrisisEventMonitoringLoop()
    set waitfor = 0
    while(1)
        // Process events
        sleep(tick_interval)
```

**Status**: This is appropriate for background monitoring loops  
**Recommendation**: No change needed - pattern is sound for this use case

---

## CATEGORY 2: TODO COMMENTS (Actionable Items)

### Issue 2.1: BuildingMenuUI Icon File Stubs
**Severity**: 🟢 **LOW** (expected, asset-dependent)  
**Locations**: BuildingMenuUI.dm (lines 56, 71, 87)

**Current**:
```dm
icon_file = 'dmi/64/fire.dmi',  // TODO: Create forge.dmi icon
icon_file = 'dmi/64/fire.dmi',  // TODO: Create anvil.dmi icon
icon_file = 'dmi/64/fire.dmi',  // TODO: Create trough.dmi icon
```

**Recommendation**: 
- Create proper DMI files for forge, anvil, trough
- Timeline: Phase 8-9 (asset pipeline)
- Workaround: Fire icon is currently used (acceptable temporary)

### Issue 2.2: AdvancedCropsSystem TODO
**Severity**: 🟢 **LOW**  
**Locations**: AdvancedCropsSystem.dm (lines 428, 563)

```dm
// TODO: Add turf type checking once terrain system is defined
// TODO: Integrate with Particles-Weather.dm
```

**Status**: These are future enhancement notes  
**Recommendation**: Keep as-is, address in later phases when terrain system solidified

### Issue 2.3: CombatSystem PvP Flag System
**Severity**: ⚠️ **MEDIUM** (game balance)  
**Location**: CombatSystem.dm (line 96)

```dm
// TODO: Implement faction/PvP flagging system
```

**Current State**: PvP logic exists but flagging system incomplete  
**Recommendation**: Schedule for Phase 9+ (after all PvE systems stable)

### Issue 2.4: DeathPenaltySystem Load from Character Data
**Severity**: 🟠 **MEDIUM** (data consistency)  
**Location**: DeathPenaltySystem.dm (line 309)

```dm
return 0  // TODO: Load from character data
```

**Current**: Death penalties hardcoded  
**Better**: Should load from character.death_debuff configuration  
**Recommendation**: Low priority, current implementation works

---

## CATEGORY 3: HIDDEN VERBS (set hidden = 1)

**Purpose**: Remove obsolete commands from player menus while keeping code for fallback/admin use

**Current Hidden Verbs** (appropriate use):
- CraftingIntegration.dm (lines 14, 33, 52, etc.) - 10+ craft verbs hidden
  - ✅ **Reason**: Replaced by modern crafting system
  - ✅ **Status**: Correct use of flag

- AscensionModeSystem.dm (line 346) - Ascension system command
  - ✅ **Reason**: Advanced feature, not for regular players
  - ✅ **Status**: Correct use

- DeathPenaltySystem.dm (line 408) - Admin command
  - ✅ **Reason**: Admin-only testing
  - ✅ **Status**: Correct use

**Recommendation**: Continue using `set hidden = 1` for deprecated systems

---

## CATEGORY 4: FLAG VARIABLES

### Issue 4.1: Multiple Boolean Flags (Scattered Pattern)
**Severity**: 🟠 **MEDIUM** (code organization)  
**Examples**:
- CharacterData.dm: `is_fainted`, `death_debuff_active` (bool flags)
- CombatSystem.dm: Various PvP flags
- dir.dm: `borders` bit-flag

**Current State**: Flags work correctly, but inconsistent naming

**Recommendation**: No immediate change needed  
**Future**: Consider consolidating into flag bitset for performance

### Issue 4.2: spawn() vs spawn(0) usage
**Severity**: 🟢 **LOW**  
**Locations**: PortHubPersistenceSystem.dm (152), CharacterData.dm (231)

**Pattern**:
```dm
spawn(0)  // Immediate async
spawn()   // Next tick async
```

**Status**: Both patterns correct and appropriately used  
**Recommendation**: No change needed

---

## CATEGORY 5: VERBS NEEDING MIGRATION

### Issue 5.1: Building Verb Needs Modern Redirect
**Severity**: ⚠️ **HIGH**  
**Location**: jb.dm, verb/Build()  
**Status**: Covered in Building Modernization Strategy

### Issue 5.2: Old Crafting Verbs Hidden (Correct)
**Status**: Already handled with `set hidden = 1`

---

## CATEGORY 6: DATA CONSISTENCY ITEMS

### Issue 6.1: Character Data Variables Need Audit
**Severity**: 🟠 **MEDIUM**  
**Current**: CharacterData.dm has 100+ variables  
**Recommendation**: 
- ✅ Variables are well-organized (already done in Phase 6)
- ✅ Unified rank system properly integrated
- No immediate action needed

---

## CATEGORY 7: DOCUMENTATION OPPORTUNITIES

### Opportunity 7.1: Update Architecture Docs
**Files affected**: Multiple system integration points

**Recommendation**:
- Add diagrams showing:
  - Equipment flow (Workaround → OverlaySystem upgrade path)
  - Deed permission unification
  - Building system modernization phases
- Update PONDERA_ARCHITECTURE.md with modern patterns

**Timeline**: Phase 7 (after implementations stabilize)

---

## CATEGORY 8: PERFORMANCE OPPORTUNITIES

### Opportunity 8.1: Optimize DeedToken Lookups
**Current**: `dt = locate(oview(src,15))` - expensive operation in tight loops  
**Used in**: plant.dm (multiple locations)

**Potential Optimization**:
```dm
// Current (expensive):
var/obj/DeedToken/dt = locate(oview(src,15))

// Better (cache deed check result):
if(last_deed_check_time + 5 < world.time)
    var/obj/DeedToken/dt = locate(oview(src,15))
    cached_deed = dt
    last_deed_check_time = world.time
else
    var/obj/DeedToken/dt = cached_deed
```

**Impact**: Moderate performance improvement for high-activity zones  
**Timeline**: Phase 8+ (after deed system stable)

---

## QUICK WINS (Can do immediately)

### Win 1: Add Comments to Deprecated Code
```dm
// jb.dm, at top of verb/Build():
/*
 * DEPRECATED: This building system is being migrated to BuildingMenuUI.dm
 * New players should use /verb/BuildModern() which provides:
 * - Cleaner UI
 * - Better recipe organization  
 * - Modern permission checking
 * 
 * This verb kept for backwards compatibility and fallback.
 * Timeline: Remove after Phase D testing complete (1 month)
 */
```

**Effort**: 5 minutes  
**Benefit**: Clarity for future developers

### Win 2: Add Logging to Deed Permission Denials
```dm
// In all 3 plant.dm instances:
if(M.canbuild==0)
    var/obj/DeedToken/dt = GetDeedAtLocation(src.loc)
    if(!CanPlayerBuildAtLocation(M, src.loc))
        // Use modern unified check (see deed audit)
        return
```

**Effort**: 15 minutes  
**Benefit**: Better analytics, easier debugging

### Win 3: Create Equipment Rendering Upgrade Plan
**Recommendation**: Document in code comments

```dm
// EquipmentVisualizationWorkaround.dm, at top:
/*
 * CURRENT PHASE (Production):
 * Lightweight equipment visualization using existing item icons.
 * Requirements: ZERO custom asset dependencies
 * Status: Active, working in production
 * 
 * FUTURE PHASE (Phase 7+):
 * Enhanced EquipmentOverlaySystem with:
 * - Custom weapon DMI files (LSoy.dmi, WHoy.dmi, etc.)
 * - Directional animations (8 directions)
 * - Attack animation support
 * Status: Awaiting DMI asset pipeline
 * 
 * Migration: Swap hooks from this system to OverlaySystem when assets ready
 */
```

**Effort**: 5 minutes  
**Benefit**: Clear roadmap for future work

---

## SUMMARY OF ALL IMPROVEMENTS

### COMPLETED (This Session)
✅ 1. Consolidated RANK_CARVING → RANK_WOODWORKING  
✅ 2. Unified rank system updated  
✅ 3. Equipment system analysis (3 systems compared)  
✅ 4. Deed permission audit (identified 6 instances to fix)  
✅ 5. Building modernization strategy (5 phases documented)

### HIGH PRIORITY (Ready to implement)
🔧 1. Migrate deed permission checks (plant.dm + jb.dm)  
🔧 2. Create BuildModern verb (BuildingMenuUI alias)  
🔧 3. Migrate building recipes (jb.dm → BUILDING_RECIPES)  

### MEDIUM PRIORITY (Plan for Phase 7-8)
🟠 1. Consolidate equipment rendering systems  
🟠 2. Remove goto statements from plant.dm  
🟠 3. Performance optimize DeedToken lookups  
🟠 4. Implement PvP flagging system  

### LOW PRIORITY (Nice to have)
🟢 1. Create proper forge/anvil/trough DMI files  
🟢 2. Add architecture documentation  
🟢 3. Create admin dashboard for deed denials  

---

## FINAL RECOMMENDATIONS FOR NEXT SESSION

**Priority Order**:
1. **Start Phase A of Building Modernization** - Add BuildModern verb (1 hour)
2. **Unify Deed Permission Checks** - Replace 6 scattered checks (2 hours)
3. **Add Comments to Deprecated Code** - Quick documentation (30 minutes)
4. **Create Equipment Rendering Roadmap** - Document upgrade path (30 minutes)

**Expected Outcome**:
- ✅ Both old and new building systems available (safe transition)
- ✅ Deed permissions unified (one code path)
- ✅ Clear documentation for future work
- ✅ No gameplay changes, pure refactoring
- ✅ Green build (0 errors, 0 warnings)

---

**Session Complete**: Ready for implementation phase
