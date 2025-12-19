# Codebase Integrity Sweep - December 20, 2025

**Status**: IN PROGRESS  
**Scope**: Complete architectural and logical integrity audit  
**Previous Session**: Removed 2 duplicate world/New(), consolidated Login/Logout

---

## CRITICAL ISSUES DISCOVERED

### 🔴 TIER 1: BLOCKING INFRASTRUCTURE BUGS

#### Issue #1: 6 MORE Duplicate world/New() Definitions
**Severity**: CRITICAL - Systems silently don't initialize

| File | Line | Initializes | Scheduled | Status |
|------|------|-------------|-----------|--------|
| `AdminCombatVerbs.dm` | 354 | `InitializeAdminCombatVerbs()` | spawn(400) | ❌ ORPHANED |
| `CombatUIPolish.dm` | 254 | `InitializeCombatHUDSystem()` | spawn(400) | ❌ ORPHANED |
| `EnemyAICombatAnimationSystem.dm` | 298 | `InitializeEnemyAICombatAnimationSystem()` | spawn(400) | ❌ ORPHANED |
| `EnvironmentalCombatIntegration.dm` | 293 | `InitializeEnvironmentalCombatIntegration()` | spawn(400) | ❌ ORPHANED |
| `WeaponAnimationSystem.dm` | 500 | `InitializeAnimationSystem()` | spawn(400) | ❌ ORPHANED |
| `UnifiedAttackSystemHUDIntegration.dm` | 78 | `InitializeUnifiedAttackSystemIntegration()` | spawn(400) | ❌ ORPHANED |

**Impact**: 
- All 6 combat/animation systems are not initializing
- Only canonical `world/New()` in `_debugtimer.dm` executes
- These duplicate definitions are silently ignored
- Phase 6 tick 400 is already assigned to `InitializePvPRanking()` - conflict!

**Fix Required**: 
1. Remove all 6 duplicate `world/New()` procs
2. Identify proper phase assignment for each system
3. Add to `InitializeWorld()` in `dm/InitializationManager.dm`
4. Suggest phases: Phase 5 (350-400) for combat systems, Phase 6 for others

---

### 🟠 TIER 2: ARCHITECTURAL INCONSISTENCIES

#### Issue #2: Hardcoded Material Prices (Should Use Dynamic Pricing)
**Severity**: HIGH - Violates market architecture

**Files with hardcoded prices**:
- `MaterialRegistrySystem.dm`: Lines 130-230
  - Stone: 10, Copper: 50, Tin: 60, Lead: 40, Zinc: 55, Iron: 100, Bronze: 180, Brass: 170
- `KingdomMaterialExchange.dm`: Lines 54-56
  - Stone: 1.0, Metal: 3.0, Timber: 2.5

**Current Architecture**:
- `DynamicMarketPricingSystem.dm` - Provides elasticity-based pricing
- `EnhancedDynamicMarketPricingSystem.dm` - Provides history & volatility
- `MarketBoardPersistenceSystem.dm` - Persists market state

**Expected Pattern**: All prices should be calculated via `GetMarketPrice(item_name)` or similar

**Fix Required**: 
1. Create price initialization in InitializeWorld() that populates market with base prices
2. Reference prices via dynamic system, not hardcoded values
3. Allow prices to float based on supply/demand

---

#### Issue #3: SQLite Persistence Error
**Severity**: MEDIUM - Runtime error on log rotation

**File**: `dm/SQLitePersistenceLayer.dm` lines 607-608
```dm
var/start_idx = length(sqlite_error_log) - 500
sqlite_error_log = sqlite_error_log[start_idx to length(sqlite_error_log)]  // ❌ SYNTAX ERROR
```

**Problem**: BYOND doesn't support `to` operator in list slicing. Should use `..` instead.

**Fix**: 
```dm
var/start_idx = length(sqlite_error_log) - 500
sqlite_error_log = sqlite_error_log[start_idx .. length(sqlite_error_log)]
```

---

#### Issue #4: Macro Redefinition (RangedCombatSystem.dm)
**Severity**: MEDIUM - Rank constants defined multiple times

**File**: `dm/RangedCombatSystem.dm` lines 8-10
```dm
#define RANK_ARCHERY "archery"      // ❌ Redefined (also in UnifiedRankSystem.dm or similar)
#define RANK_CROSSBOW "crossbow"    // ❌ Redefined
#define RANK_THROWING "throwing"    // ❌ Redefined
```

**Expected Pattern**: All rank constants should be defined in ONE place (e.g., `!defines.dm` or `UnifiedRankSystem.dm`)

**Fix**: 
1. Remove duplicate defines from `RangedCombatSystem.dm`
2. Add `#include` or rely on central defines
3. Verify no conflicting definitions

---

#### Issue #5: HUD Path Syntax Error
**Severity**: LOW - But indicates code issues

**File**: `lib/forum_account/hudgroups/hud-groups.dm` lines 268, 272
```dm
__hide_object(HudObject/h, client.c)  // ❌ Should be HudObject/h, client/c
__show_object(HudObject/h, client.c)  // ❌ Should be HudObject/h, client/c
```

**Problem**: Path separated by `.` should use `/`

---

### 🟡 TIER 3: CODE QUALITY ISSUES

#### Issue #6: Markdown Formatting Errors (Non-blocking)
**Severity**: LOW - Documentation only

**Files affected**: 
- `docs/SQLITE_HUD_INTEGRATION_GUIDE.md`
- `docs/ARCHIVE_INDEX.md`
- Many others

**Issues**: Missing blank lines around headings, improper fence blocks, etc.

**Fix**: Run markdown formatter or manually fix headings

---

## POSITIVE FINDINGS

### ✅ Initialization Gate Usage
- `world_initialization_complete` is properly checked in 30+ places
- Login gateway (`LoginGateway.dm`) properly validates initialization
- HUDManager.dm Login() includes `CanPlayersLogin()` check
- **Status**: GOOD

### ✅ Deed Permission Enforcement
- `CanPlayerBuildAtLocation()` properly integrated in 10+ build systems
- `CanPlayerPickupAtLocation()` and `CanPlayerDropAtLocation()` are checked
- Deed system properly gates player actions
- **Status**: GOOD

### ✅ Core Infrastructure
- Time system initializes first (Phase 1)
- Infrastructure initializes Phase 2
- Player login gates on `world_initialization_complete`
- Crash recovery properly integrated
- **Status**: GOOD

---

## REMEDIATION PLAN

### Phase 1: CRITICAL (Do First)
1. **Remove all 6 duplicate world/New() definitions** (30 min)
   - Delete from: AdminCombatVerbs, CombatUIPolish, EnemyAICombatAnimationSystem, EnvironmentalCombatIntegration, WeaponAnimationSystem, UnifiedAttackSystemHUDIntegration
   
2. **Identify & assign combat systems to proper phases** (20 min)
   - Admin verbs → Phase 5 (tick 350)
   - Combat HUD → Phase 5 (tick 355)
   - Enemy AI animation → Phase 5 (tick 360)
   - Environmental combat → Phase 5 (tick 365)
   - Weapon animation → Phase 5 (tick 370)
   - Unified attack → Phase 5 (tick 375)

3. **Add to InitializeWorld()** (15 min)
   - Update InitializationManager.dm to add these 6 calls

4. **Test build** (10 min)
   - Verify no errors, systems initialize correctly

### Phase 2: HIGH (Do Second)
1. **Fix SQLite syntax error** (5 min)
   - Replace `to` with `..` in list slicing

2. **Remove macro redefinitions** (10 min)
   - Remove RANK_ARCHERY, RANK_CROSSBOW, RANK_THROWING from RangedCombatSystem.dm

3. **Fix HUD path syntax** (5 min)
   - Change `client.c` to `client/c` in hud-groups.dm

### Phase 3: MEDIUM (Do Third)
1. **Audit hardcoded prices** (30 min)
   - Document where prices are used
   - Create initialization that populates market system
   - Ensure all prices reference dynamic system

2. **Documentation cleanup** (20 min)
   - Fix markdown formatting in 2 guide files

---

## BUILD VERIFICATION CHECKLIST

- [ ] No compilation errors
- [ ] All 6 combat systems show "Initialized" in logs
- [ ] Player can successfully login
- [ ] Building/pickup/drop works
- [ ] Market prices are accessible
- [ ] Deed system prevents unauthorized building

---

## FILES TO MODIFY

**Tier 1 (Critical)**:
- [ ] `dm/AdminCombatVerbs.dm` - Remove world/New()
- [ ] `dm/CombatUIPolish.dm` - Remove world/New()
- [ ] `dm/EnemyAICombatAnimationSystem.dm` - Remove world/New()
- [ ] `dm/EnvironmentalCombatIntegration.dm` - Remove world/New()
- [ ] `dm/WeaponAnimationSystem.dm` - Remove world/New()
- [ ] `dm/UnifiedAttackSystemHUDIntegration.dm` - Remove world/New()
- [ ] `dm/InitializationManager.dm` - Add 6 combat init calls to Phase 5

**Tier 2 (High)**:
- [ ] `dm/SQLitePersistenceLayer.dm` - Fix list slicing syntax (line 608)
- [ ] `dm/RangedCombatSystem.dm` - Remove macro redefinitions (lines 8-10)
- [ ] `lib/forum_account/hudgroups/hud-groups.dm` - Fix path syntax (lines 268, 272)

**Tier 3 (Medium)**:
- [ ] `dm/MaterialRegistrySystem.dm` - Document hardcoded prices
- [ ] `dm/KingdomMaterialExchange.dm` - Document hardcoded prices
- [ ] `docs/SQLITE_HUD_INTEGRATION_GUIDE.md` - Fix markdown
- [ ] `docs/ARCHIVE_INDEX.md` - Fix markdown

---

## NOTES

- Session 1 fixed: 2 duplicate world/New(), 1 duplicate Login(), 1 duplicate Logout()
- Session 2 (current) discovering: 6 MORE duplicate world/New(), SQLite error, macro redefs, hardcoded prices
- Total issues found: 10+ significant infrastructure problems
- Build still compiles (redundant definitions silently ignored by BYOND)
- All fixes are consolidations/corrections (no new logic added)

---

**Next Steps**: Proceed with Phase 1 remediation (fix critical issues)
