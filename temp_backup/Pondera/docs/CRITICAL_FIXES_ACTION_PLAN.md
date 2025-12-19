# 🚨 CRITICAL FIXES - ACTION PLAN

**Priority**: Must complete before Phase 3 features  
**Estimated Time**: 3-4 hours  
**Build Target**: 0 errors, 0 warnings

---

## 1. DEAD CODE CLEANUP (30 minutes)

### Files to Archive
- `toolslegacyexample.dm` (~1,200 lines)
- `jblegacyexample.dm` (~3,000 lines)  
- `Lightlegacyexample.dm` (~600 lines)

### Action Steps

1. **Create `/legacy/` directory** (3 min)
   ```powershell
   mkdir "c:\Users\ABL\Desktop\Pondera\legacy"
   ```

2. **Move legacy files** (5 min)
   ```powershell
   mv "c:\Users\ABL\Desktop\Pondera\toolslegacyexample.dm" "c:\Users\ABL\Desktop\Pondera\legacy\"
   mv "c:\Users\ABL\Desktop\Pondera\jblegacyexample.dm" "c:\Users\ABL\Desktop\Pondera\legacy\"
   mv "c:\Users\ABL\Desktop\Pondera\Lightlegacyexample.dm" "c:\Users\ABL\Desktop\Pondera\legacy\"
   ```

3. **Remove from Pondera.dme** (10 min)
   - Find and delete lines with `#include "toolslegacyexample.dm"`
   - Find and delete lines with `#include "jblegacyexample.dm"`
   - Find and delete lines with `#include "Lightlegacyexample.dm"`

4. **Verify build** (5 min)
   - Compile and confirm no errors
   - Verify code size reduction in error output

### Expected Outcome
- Codebase reduced by ~4,800 lines
- No functional changes (legacy files were never used)
- Cleaner .dme file

---

## 2. NPC DISTANCE VALIDATION (20 minutes)

### Issue Location
`dm/npcs.dm` lines 775-810 (Click handler)

### Current Code (VULNERABLE)
```dm
Click()
    set hidden = 1
    set src in oview(1)
    var/mob/players/M = usr
    if(!istype(M)) return
    if (!(src in range(1, usr))) return  // Validation AFTER dialog opened
    // Dialog code...
```

### Problem
1. `set src in oview(1)` sets permitted click range
2. But input dialog can be opened from anywhere
3. Validation happens after dialog, allowing input from distance

### Fix
```dm
Click()
    set hidden = 1
    set src in oview(1)
    var/mob/players/M = usr
    if(!istype(M)) return
    
    // MOVE THIS CHECK TO TOP
    if(!(src in range(1, M)))
        M << "You're too far away!"
        return
    
    // NOW dialog code safe to proceed
    var/input_dialog = input(M, "What do you want?", "NPC Menu") in list("Talk", "Trade", "Learn")
    // ... rest of code
```

### Action Steps
1. Open `dm/npcs.dm`
2. Find Click() proc (line ~780)
3. Move distance validation before input dialog
4. Compile and verify no errors

### Expected Outcome
- NPC interaction range-locked properly
- Exploit prevented
- No performance impact

---

## 3. PRESTIGE RECIPE INTEGRATION (15 minutes)

### Issue
Prestige rewards recipes in `PrestigeSystem.dm` but `CookingSystem.dm` doesn't check for prestige recipes

### Current Code (INCOMPLETE)

In `PrestigeSystem.dm` (line 250):
```dm
proc/AwardPrestigeRecipes(player, state)
    // Adds to prestige_state but never checked elsewhere
    state.prestige_unlocked_recipes += recipe_list
```

In `CookingSystem.dm` (line 180):
```dm
proc/IsRecipeUnlocked(player, recipe_id)
    return recipe_id in player.character.recipe_state.discovered_recipes
    // MISSING: prestige recipe check!
```

### Fix
Modify `CookingSystem.dm` IsRecipeUnlocked:

**OLD** (3 lines):
```dm
proc/IsRecipeUnlocked(player, recipe_id)
    return recipe_id in player.character.recipe_state.discovered_recipes
```

**NEW** (8 lines):
```dm
proc/IsRecipeUnlocked(player, recipe_id)
    // Check standard discovery
    if(recipe_id in player.character.recipe_state.discovered_recipes)
        return TRUE
    // Check prestige unlock
    var/datum/PrestigeSystem/ps = GetPrestigeSystem()
    if(ps)
        var/datum/prestige_state/state = ps.GetPrestigeState(player)
        if(state && recipe_id in state.prestige_unlocked_recipes)
            return TRUE
    return FALSE
```

### Action Steps
1. Open `dm/CookingSystem.dm`
2. Find `IsRecipeUnlocked()` proc
3. Replace with code above
4. Compile and verify no errors
5. Test with prestige character

### Expected Outcome
- Prestige recipes now display in cooking menus
- Players can use earned recipe rewards
- Feature complete and functional

---

## 4. PATHFINDING WARNINGS CLEANUP (5 minutes)

### Issue Location
`dm/NPCPathfindingSystem.dm` lines 132, 159, 160

### Current Code
```dm
// Line 132
var/npc_elev = npc.elevel  // Declared but never used

// Line 159-160
var/npc_elev = npc.elevel  // Declared but never used
var/target_elev = target.elevel  // Declared but never used
```

### Fix Options

**Option A: Remove unused lines** (if truly not needed)
```dm
// DELETE these three lines
```

**Option B: Use them in logic** (if needed for elevation checks)
```dm
// If elevation should affect pathfinding:
if(abs(npc_elev - target_elev) > 0.5)
    continue  // Can't reach target at different elevation
```

### Action Steps
1. Open `dm/NPCPathfindingSystem.dm`
2. Go to line 132: Either delete or use in elevation check
3. Go to lines 159-160: Either delete or use in elevation check
4. Compile and verify 0 warnings

### Expected Outcome
- Build warnings eliminated
- Cleaner compiler output
- If option B: Better elevation-aware pathfinding

---

## 5. SPAWNER SEASON LOGIC COMPLETION (1 hour)

### Issue Location
`dm/Spawn.dm` lines 480-520

### Current Code (BROKEN)
```dm
else if(season=="Winter")
    var/mob/insects/PLRButterfly/btf
    spawned=0
    for(btf in world)
        Del()  // WRONG: No object specified
        return  // WRONG: Returns immediately, exits loop
```

### Problems
1. `Del()` has no object - should be `del(btf)`
2. `return` in middle of loop stops function
3. Actual spawning may never happen

### Full Fix Investigation
Need to check:
1. What should winter spawning do? (create/delete mobs)
2. What mobs should spawn/despawn in winter?
3. How should season transitions work?

### Action Steps
1. **Audit existing code** (10 min)
   - Check what creatures spawn in each season
   - Verify season detection logic
   - Confirm spawner activation

2. **Fix immediate bugs** (5 min)
   ```dm
   // CHANGE FROM:
   for(btf in world)
       Del()
       return
   
   // CHANGE TO:
   for(btf in world)
       if(istype(btf, /mob/insects/PLRButterfly))
           del(btf)
       // Don't return - continue loop
   ```

3. **Test seasonal spawning** (15 min)
   - Set world time to winter
   - Verify correct mobs spawn
   - Verify summer creatures disappear

4. **Compile and verify** (5 min)

### Expected Outcome
- Seasonal spawning mechanics working
- No premature returns
- Proper creature lifecycle

---

## 6. DEED CACHE INVALIDATION (20 minutes)

### Issue
Players may retain deed permissions after deed frozen/expired

### Current Code
In `deed.dm`:
```dm
proc/InvalidateDeedPermissionCache(player)
    player.deed_cache_valid = FALSE
```

**Problem**: Cache only invalidated on player MOVE, not on DEED CHANGE

### Fix Strategy

Add deed change notifications:

```dm
// In deed.dm, add new proc:
proc/NotifyDeedChange(player)
    """
    Call this whenever deed freezes/expires/changes
    Invalidate all affected players' caches
    """
    if(!player) return
    player.deed_cache_valid = FALSE
    player.deed_cache_timestamp = world.time
```

Add hook calls:
```dm
// When deed is frozen (existing DeedFreeze code):
deed.freeze_status = TRUE
NotifyDeedChange(deed.owner)  // ADD THIS

// When deed expires (MaintenanceProcessor):
deed.status = "expired"
for(var/mob/players/M in deed.owner_players)
    NotifyDeedChange(M)  // ADD THIS
```

### Action Steps
1. Open `dm/deed.dm`
2. Add `NotifyDeedChange()` proc
3. Find all deed mutation points
4. Add notification calls
5. Test deed changes invalidate caches

### Expected Outcome
- Permission cache correctly invalidates on deed changes
- No permission retention exploits
- Players see accurate zone access

---

## Implementation Sequence

**Build after each step to catch errors early:**

```
Step 1: Dead Code Cleanup → Build (should reduce warnings)
        ↓
Step 2: NPC Distance Validation → Build (verify no errors)
        ↓
Step 3: Prestige Recipe Integration → Build (verify no errors)
        ↓
Step 4: Pathfinding Warnings → Build (verify 0 warnings)
        ↓
Step 5: Spawner Season Logic → Build & Test (verify mechanics)
        ↓
Step 6: Deed Cache Invalidation → Build & Test (verify caching)
        ↓
Final Build: Should have 0 errors, 0 warnings
```

---

## Success Criteria

- [ ] Dead code removed (4,800 lines)
- [ ] NPC distance exploit fixed
- [ ] Prestige recipes display in menus
- [ ] Pathfinding warnings = 0
- [ ] Seasonal spawning works
- [ ] Deed cache updates on deed change
- [ ] Build: 0 errors, 0 warnings
- [ ] All tests pass
- [ ] No regressions in existing features

---

## Estimated Timeline

| Task | Time | Status |
|------|------|--------|
| Dead Code Cleanup | 30 min | ⏳ Ready |
| NPC Distance Validation | 20 min | ⏳ Ready |
| Prestige Recipe Integration | 15 min | ⏳ Ready |
| Pathfinding Warnings | 5 min | ⏳ Ready |
| Spawner Season Logic | 1 hour | ⏳ Needs audit |
| Deed Cache Invalidation | 20 min | ⏳ Ready |
| Testing & Verification | 30 min | ⏳ Ready |
| **TOTAL** | **3 hours** | **READY TO START** |

---

## Next Action

Ready to start implementation? I can execute these fixes in order:

1. **Step 1**: Remove legacy files and clean Pondera.dme
2. **Step 2**: Fix NPC distance validation
3. **Step 3**: Integrate prestige recipes
4. **Step 4**: Clean pathfinding warnings
5. **Step 5**: Debug and fix spawner season logic
6. **Step 6**: Implement deed cache change notifications

Shall I proceed? 🚀
