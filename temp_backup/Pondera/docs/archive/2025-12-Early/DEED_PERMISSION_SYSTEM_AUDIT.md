# Deed Permission System Audit - December 13, 2025

## ISSUE SUMMARY
Deed permission validation is scattered across **4 different locations** with **3 distinct patterns**, creating:
- Code duplication
- Maintenance burden
- Potential inconsistency in permission checking

---

## CURRENT VALIDATION PATTERNS

### Pattern 1: Legacy Goto Pattern (plant.dm)
**Files**: plant.dm (lines 1615-1635, 1709-1729, 1795-1815)  
**Pattern**: Manual DeedToken lookup + goto labels  
**Severity**: 🟠 MEDIUM

```dm
// plant.dm - Sowing a seed
verb/Plant()
    var/mob/players/M = usr
    var/obj/DeedToken/dt
    dt = locate(oview(src,15))
    if(!dt)
        goto NXT
    for(dt)
        if(M.canbuild==1)
            goto NEXT
        else
            M << "You do not have permission to build"
            return
    NEXT
    NXT
    // ... actual planting code
```

**Issues**:
- ❌ Uses goto statements (anti-pattern)
- ❌ Manual DeedToken locate() each time
- ❌ Direct M.canbuild check (not using CanPlayerBuildAtLocation)
- ❌ Duplicated in 3 places in plant.dm
- ❌ Comment says "remove this section" indicating awareness of legacy code

**Location**: 3 instances in plant.dm

---

### Pattern 2: Hardcoded Inline Checks (jb.dm)
**Files**: jb.dm (lines 8, 54, 1366)  
**Pattern**: Direct M.canbuild flag check without context  
**Severity**: 🟠 MEDIUM

```dm
// jb.dm - Building verification
if(M.canbuild==0)
    M << "You do not have permission to build/plant here..."
    return
```

**Issues**:
- ❌ No deed context information logged
- ❌ Generic error message (doesn't say WHICH deed blocks you)
- ❌ Direct flag check instead of function call
- ❌ No analytics/logging for permission denials
- ❌ Not using CanPlayerBuildAtLocation()

**Locations**: 3 instances in jb.dm (lines 8, 54, 1366)

---

### Pattern 3: Modern Centralized Function (DeedPermissionSystem.dm) ✅
**Files**: DeedPermissionSystem.dm (lines 9-28)  
**Pattern**: Single unified function with logging  
**Severity**: 🟢 GOOD (this is the target)

```dm
/proc/CanPlayerBuildAtLocation(mob/players/M, turf/T)
    /**
     * Check if player can build/plant at location
     */
    if(!M || !T)
        if(!M) world.log << "WARNING: CanPlayerBuildAtLocation() called with null player"
        if(!T) world.log << "WARNING: CanPlayerBuildAtLocation() called with null turf"
        return FALSE
    
    // Check if player's canbuild is disabled (set by deed regions)
    if(M.canbuild == 0)
        var/obj/DeedToken/token = GetDeedAtLocation(T)
        var/deed_info = token ? "[token:name] (owner: [token:owner])" : "Unknown deed"
        world.log << "BUILD DENIED: [M.name] at [T.x],[T.y],[T.z] - [deed_info]"
        
        // Add to analytics log
        if(!permission_denials) permission_denials = list()
        permission_denials += "BUILD DENIED: [M.name] at [T.x],[T.y],[T.z] - [deed_info]"
        if(permission_denials.len > 10000) PrunePermissionLogs()
        
        return FALSE
    
    return TRUE
```

**Strengths**:
- ✅ Single point of enforcement
- ✅ Comprehensive logging
- ✅ Deed context included in logs
- ✅ Analytics tracking
- ✅ Null safety checks
- ✅ Clear function name
- ✅ Reusable for all location types

**Current Usage**:
- Used in FishingSystem.dm (line 472) - example of correct pattern
- **NOT used** in plant.dm
- **NOT used** in jb.dm

---

### Pattern 4: Entity-Level Permission Flags (deed.dm)
**Files**: deed.dm (lines 41, 47, 90, 98, 105, 112, 176, 183, 190, 197, 302, 307, 335, 346, 470)  
**Pattern**: Direct flag setting on player object  
**Severity**: 🔵 FOUNDATIONAL (works, but underlying)

```dm
// deed.dm - Setting permission flags when player enters/exits deed zones
m:canbuild = 0   // Disable building
m:canbuild = 1   // Enable building
```

**Role**: These statements SET the flags that patterns 1-3 CHECK  
**Status**: Working correctly - this is the source of truth

---

## COMPARISON TABLE

| Aspect | plant.dm (goto) | jb.dm (inline) | DeedPermissionSystem | Recommendation |
|--------|---|---|---|---|
| **Pattern Type** | Goto labels | Direct flag | Function call | ✅ Function call |
| **Code Reusability** | ❌ No | ❌ No | ✅ Yes | ✅ Yes |
| **Logging** | ❌ None | ❌ None | ✅ Full | ✅ Full |
| **Context Info** | ⚠️ Limited | ❌ None | ✅ Complete | ✅ Complete |
| **Null Safety** | ❌ No | ❌ No | ✅ Yes | ✅ Yes |
| **Analytics** | ❌ No | ❌ No | ✅ Yes | ✅ Yes |
| **Maintenance Cost** | 🔴 High (3+ copies) | 🔴 High (3+ copies) | 🟢 Low (1 place) | 🟢 Low |
| **Lines per check** | 8-10 | 3-4 | 1 | ✅ 1 |

---

## MIGRATION STRATEGY

### Phase 1: Identify All Permission Checks
- ✅ plant.dm: 3 instances (lines 1615, 1709, 1795)
- ✅ jb.dm: 3 instances (lines 8, 54, 1366)
- ✅ deed.dm: 15 instances (flag-setting, don't touch)
- ✅ DeedPermissionSystem.dm: 1 instance (target pattern)

### Phase 2: Replace Pattern by Pattern

**Plant.dm Migration** (eliminate goto):
```dm
// BEFORE
var/obj/DeedToken/dt
dt = locate(oview(src,15))
if(!dt) goto NXT
for(dt)
    if(M.canbuild==1) goto NEXT
    else return

// AFTER
if(!CanPlayerBuildAtLocation(M, src.loc))
    return
```

**jb.dm Migration** (use function):
```dm
// BEFORE
if(M.canbuild==0)
    M << "You do not have permission..."
    return

// AFTER
if(!CanPlayerBuildAtLocation(M, usr.loc))
    return
```

### Phase 3: Verify Functionality
- Test building at deed boundaries
- Verify error messages include deed info
- Check analytics logs capture denials
- Confirm permission flags still set/clear correctly

---

## RECOMMENDED CHANGES

### Immediate (No Breaking Changes):
1. ✅ Add comments to deed.dm explaining "permission flags set by deed zones"
2. ✅ Document that DeedPermissionSystem.dm is canonical check point

### Short-term (Phase 6):
1. 🔧 Replace all plant.dm patterns with CanPlayerBuildAtLocation()
2. 🔧 Replace all jb.dm patterns with CanPlayerBuildAtLocation()
3. 🔧 Remove goto statements from plant.dm

### Medium-term (Phase 7):
1. 📊 Add deed permission UI display (shows owner/permissions when hovering over zones)
2. 📊 Create admin command: `/show_deed_denials` - shows recent permission failures

---

## ALSO RECOMMENDED: Similar Functions Exist

**DeedPermissionSystem.dm also defines**:
- `CanPlayerPickupAtLocation()` - for item pickup
- `CanPlayerDropAtLocation()` - for item drop

These should be used consistently where:
- ❌ Building places objects → `CanPlayerBuildAtLocation()`
- ❌ Picking up drops → `CanPlayerPickupAtLocation()`
- ❌ Placing items on ground → `CanPlayerDropAtLocation()`

---

## SUMMARY

| Current State | Issues | Recommendation |
|---|---|---|
| 🟠 Scattered patterns | 6 instances of duplication | Consolidate to CanPlayerBuildAtLocation() |
| 🟠 Legacy goto in plant.dm | Anti-pattern, hard to maintain | Replace with function calls |
| 🔴 No deed context in jb.dm | Generic errors | Use modern function with logging |
| 🟢 DeedPermissionSystem ready | Already works, just unused | Adopt everywhere |

**Estimated migration effort**: 30-45 minutes
**Impact**: Zero gameplay changes, pure code quality improvement
**Benefit**: Single source of truth, better analytics, maintainability
