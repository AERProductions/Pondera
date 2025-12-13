# Deed System Refactor - Architecture & Implementation Plan

## Overview

The deed system manages region-based property ownership and permission control in Pondera. This document outlines the current architecture, identified gaps, and the refactoring plan to enforce permissions properly.

**Status**: ✅ Foundation Complete (0 errors), 🔄 Permission Enforcement In Progress

---

## Current Architecture

### Two Deed System Variants

#### 1. **Old Deed System** (`deed.dm`)
- **Type**: `/region/deed`
- **Mechanism**: Region-based zones with deed tokens
- **Key Variables**:
  - `owner`: Deed owner's ckey
  - `deedallow`: List of allowed players
  - `deedowner`: Associative list storing owner info
  - `deedname`: Associative list storing deed name
  - `dt` (reference): `/obj/DeedToken` object (inventory item)

- **Permission Flow**:
  1. Deed token placed in world
  2. Region created with deed token in range
  3. When player enters region → `Entered()` called
  4. Region checks `permallow` variable on player
  5. Sets `canbuild`, `canpickup`, `candrop` flags

- **Files Using This System**:
  - `plant.dm` (lines 1600-1620): Checks `M.canbuild == 1` before planting
  - `jb.dm` (7 locations): Job board deed checks

**Problem**: Permission enforcement incomplete. Only planting checks, pickup/drop actions don't verify.

---

#### 2. **Improved Deed System** (`ImprovedDeedSystem.dm`)
- **Type**: `/obj/DeedToken_Zone`
- **Mechanism**: Zone-based inventory items with player access lists
- **Key Variables**:
  - `zone_id`: Unique zone identifier
  - `owner_key`: Owner's character key
  - `zone_name`: Display name
  - `allowed_players`: List of permitted players

- **Features**:
  - Click to open deed menu
  - View info, manage access, rename
  - No automatic region creation
  - Better UX for zone management

**Problem**: Not integrated with old deed system. Exists in parallel.

---

### Permission Variables on Players

**Location**: `Basics.dm` (approximately lines 242-244)

```dm
mob/players
	var
		canbuild = 1     // Can plant, build structures
		canpickup = 1    // Can pick up items
		candrop = 1      // Can drop items
```

**Set by**: `/region/deed` `Entered()` proc
**Checked by**: plant.dm when user attempts to plant

---

## Identified Gaps

### 1. **Permission Enforcement Incomplete**

**Current State**:
- ✅ Permissions set when entering deed regions
- ✅ Planting checks `canbuild` flag
- ❌ Picking up items doesn't check `canpickup`
- ❌ Dropping items doesn't check `candrop`
- ❌ Other building actions don't check permissions

**Impact**: Users can bypass deed restrictions by picking up items even when `canpickup = 0`

**Example Code in plant.dm** (lines 1600-1620):
```dm
var/obj/DeedToken/dt = locate(oview(src, 15))
if(!dt)
    goto NXT

for(dt)
    if(M.canbuild == 1)
        goto NEXT
    else
        M << "You do not have permission to build"
        return

NEXT:
    // Plant logic continues
NXT:
    // Alternative path if no deed
```

### 2. **Two Systems Not Integrated**

Old `/region/deed` and new `/obj/DeedToken_Zone` exist independently:
- Old system uses regions + permission variables
- New system uses inventory objects + access lists
- No bridge between them

**Solution**: Create unified permission system that supports both

---

## Refactoring Plan

### Phase 1: Create Unified Permission System ✅ COMPLETE

**File**: `DeedPermissionSystem.dm` (Created)

**Functions Implemented**:
- `CanPlayerBuildAtLocation()`: Check if player can build/plant
- `CanPlayerPickupAtLocation()`: Check if player can pick up
- `CanPlayerDropAtLocation()`: Check if player can drop
- `EnforceDeedPermissions()`: Initialization function

**Current Status**: Compiles cleanly (0 errors)

**What It Does**:
- Provides global permission checking functions
- Checks player's permission flags set by deed regions
- Foundation for integrating with actual action code

---

### Phase 2: Integrate Permission Checks Into Actions (NEXT)

**Required Changes**:

#### A. **Objects.dm - Item Pickup**

Add permission check before item movement:

```dm
// In item Move() or similar proc
if(!CanPlayerPickupAtLocation(usr, get_turf(src)))
    usr << "You do not have permission to pick up items here."
    return FALSE
```

#### B. **Objects.dm - Item Drop**

Add permission check before item is placed:

```dm
// In Drop() or similar proc
if(!CanPlayerDropAtLocation(usr, get_turf(src)))
    usr << "You do not have permission to drop items here."
    return FALSE
```

#### C. **plant.dm - Planting** (Already has checks but should be unified)

Replace custom checks with unified system:

```dm
// Old code
var/obj/DeedToken/dt = locate(oview(src, 15))
if(!dt)
    goto NXT
// ... custom permission logic ...

// New code
if(!CanPlayerBuildAtLocation(usr, get_turf(src)))
    usr << "You do not have permission to build here."
    return
```

#### D. **Other Action Files**

Identify other actions requiring deed checks:
- `GatheringExtensions.dm` (mining, harvesting)
- `FishingSystem.dm` (fishing in claimed areas)
- `FurnitureExtensions.dm` (furniture placement)
- Building/crafting systems

---

### Phase 3: Reconcile Two Deed Systems (DESIGN PHASE)

**Question**: Should we keep both systems or consolidate?

**Option A: Keep Both Parallel**
- Old system: Region-based for map persistence
- New system: Inventory-based for dynamic zone management
- Bridge: Check both when enforcing permissions

**Option B: Consolidate to Single System**
- Choose one approach (probably new zone-based)
- Migrate old deed tokens to new format
- Remove redundant code

**Recommendation**: Start with Option A (both systems parallel) for backward compatibility

**Integration Pattern**:
```dm
// In CanPlayerBuildAtLocation():
// 1. Check old deed region permissions (canbuild flag)
// 2. Check new zone deed permissions (allowed_players list)
// Return TRUE if either grants permission
```

---

### Phase 4: Test Permission Enforcement

**Test Cases**:

1. **No Deed Zone**
   - Player can plant, pickup, drop freely ✓

2. **In Deed Zone (Restricted)**
   - Player not on allow list
   - Attempt plant → Denied ✓ (already working)
   - Attempt pickup → Should be Denied (needs implementation)
   - Attempt drop → Should be Denied (needs implementation)

3. **In Deed Zone (Allowed)**
   - Player on allow list
   - All actions should be Allowed ✓

4. **Deed Zone Ownership**
   - Owner can always perform actions ✓

5. **Multiple Zones**
   - Permissions change when entering different zones ✓

---

## Implementation Checklist

- [x] Create `DeedPermissionSystem.dm` with helper functions
- [x] Add to `Pondera.dme` includes
- [x] Build successfully (0 errors)
- [ ] Integrate checks into Objects.dm (pickup/drop)
- [ ] Integrate checks into plant.dm (unify with system)
- [ ] Integrate checks into other action files
- [ ] Implement deed region → new system bridge
- [ ] Test all permission scenarios
- [ ] Document final deed system behavior
- [ ] Update zone management UI if needed

---

## Current Permission Model

```
Player Attempts Action (pickup/drop/build)
    ↓
Check CanPlayer___AtLocation()
    ↓
Is canpickup/candrop/canbuild == 0?
    ↓ YES (Restricted)
    Deny action, show message
    ↓ NO (Allowed)
    Proceed with action
```

---

## Files Modified This Session

1. **DeedPermissionSystem.dm** (NEW - 68 lines)
   - Unified permission checking
   - Global helper functions

2. **Pondera.dme** (MODIFIED)
   - Added: `#include "dm\DeedPermissionSystem.dm"`

3. **deed.dm** (NO CHANGES - already included)
4. **ImprovedDeedSystem.dm** (NO CHANGES - already included)

---

## Next Steps

1. **Identify all action entry points** requiring deed checks
2. **Integrate `CanPlayer___AtLocation()` checks** before each action
3. **Test permission scenarios** with deed zones
4. **Reconcile old/new deed systems** if needed
5. **Document final permission enforcement model**

---

## References

- **Deed System Documentation**: deed.dm (470 lines)
- **Old Region Type**: `/region/deed` with Entered/Exited hooks
- **New Deed Type**: `/obj/DeedToken_Zone` with menu interface
- **Permission Variables**: mob/players.canbuild, .canpickup, .candrop
- **Unified Checking**: DeedPermissionSystem.dm functions

---

**Current Build Status**: ✅ 0 errors, 3 warnings
**System Ready**: Yes (foundation complete, enforcement in progress)
