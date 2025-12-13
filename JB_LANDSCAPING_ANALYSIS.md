# Landscaping/Digging System (jb.dm) - Comprehensive Analysis

## 1. Current Architecture Overview

**File**: `dm/jb.dm` (8,879 lines)
**Primary Systems**: 
- Dig verb (landscaping/terrain modification)
- Building structures (integrated via `UpdateRankExp(RANK_BUILDING)`)
- Landscaping objects (roads, ditches, hills)

---

## 2. Old Rank System (DEPRECATED - Needs Modernization)

### Global Variables (Lines ~1-50)
```dm
var/Busy = 0
var
	dig[1]  // Current dig menu list
	logs = 0
```

### Player Variables (CharacterData.dm integration needed)
Currently using direct player variables:
- `M.drank` - Digging rank (1-10, needs migration to `character.digging_rank`)
- `M.digexp` - Current experience (needs migration to `character.digging_xp`)
- `M.mdigexp` - Max experience for level (needs migration to `character.digging_maxexp`)

### Deprecated Commented Procs (Lines 4531-4547)
```dm
/*proc/checkdlevel(var/mob/players/M)  // NEVER CALLED
	if (M.digexp >= M.mdigexp) GaindLevel(M)
	M.updateDXP()

proc/GaindLevel(var/mob/players/M)   // NEVER CALLED - dead code
	M << "\green<b>You've become Stronger."
	M.mdigexp+=(13*(M.drank*M.drank))  // Old formula
	M.drank+=1
	M.updateDXP()
*/
```

### Deprecated Helper (No updateDXP proc exists!)
- Code calls `M.updateDXP()` but this proc **doesn't exist** - likely removed
- Code calls `M.updateST()` which exists (stamina update)
- XP display broken - **no way to see dig progress currently**

---

## 3. Digging Rank Progression System (Lines 4540-4650)

### Rank Unlock Gates (digunlock() proc, Lines 4540-4600)
```
Rank 1: ["Dirt"]
Rank 2: ["Dirt", "Grass", "Cancel", "Back"]
Rank 3: ["Dirt", "Grass", "Dirt Road", "Cancel", "Back"]
Rank 4: ["Dirt", "Grass", "Dirt Road", "Dirt Road Corner", "Cancel", "Back"]
Rank 5: ["Dirt", "Grass", "Dirt Road", "Dirt Road Corner", "Wood Road", "Wood Road Corner", "Cancel", "Back"]
Rank 6: Same as Rank 5 (no new options)
Rank 7: + "Ditch"
Rank 8: + "Hill"
Rank 9: + "Water"
Rank 10: + "Lava" (max rank)
```

### Level-Up Thresholds (diglevel() proc, Lines 4603-4650+)
```
Rank 1 → 2: 50 XP  | Max becomes 100
Rank 2 → 3: 150 XP | Max becomes 200
Rank 3 → 4: 200 XP (inferred)
Rank 4 → 5: (not shown in snippet)
...
```

---

## 4. Dig Verb Implementation (Lines 50-4530)

### Structure
```dm
mob/players/verb/Dig()
    set hidden = 1
    var/mob/players/M = usr
    var/obj/DeedToken/dt
    
    // 1. Check deed permissions
    // 2. Check stamina
    // 3. Check shovel equipped (M.SHequipped == 1)
    // 4. Main menu loop: input() → switch statements
```

### Shovel Requirement
- **Prerequisite**: `M.SHequipped == 1` (must have shovel equipped)
- **Effect**: Different for each action, typically `-5 stamina`
- **XP Gain**: Flat `+15 XP` per basic action, `+35 XP` for complex actions

### Terrain Modification Types

#### 1. **Dirt** (Simplest)
- Creates basic dirt/grass turf modifications
- All ranks available

#### 2. **Dirt Road** (3 variants)
- North/South road
- East/West road
- 3-Way North junction
- Creates `/obj/Landscaping/Road/DirtRoad/*` objects
- Requires Rank 3+

#### 3. **Dirt Road Corner** (4 variants)
- NW, NE, SW, SE corners
- Creates `/obj/Landscaping/Road/DirtRoad/*CRoad` objects
- Requires Rank 4+

#### 4. **Wood Road** (5 variants)
- Same patterns as Dirt Road + corners
- Creates `/obj/Landscaping/Road/WoodRoad/*` objects
- Requires Rank 5+

#### 5. **Brick/Stone Road** (6 variants)
- NS, EW directions + 4 corners
- Creates `/obj/Landscaping/Road/StoneRoad/*` objects
- Requires Rank 8+

#### 6. **Ditch** (Complex - Lines 392-1000+)
Multiple types:
```
Slope (4 variants):  Slope(NORTH|SOUTH|EAST|WEST)
  Creates: /obj/Landscaping/Ditch/ditchS* (entry slopes DOWN)
  
Exit Slope (4 variants): Exit Slope(NORTH|SOUTH|EAST|WEST)
  Creates: /obj/Landscaping/Ditch/ditch*Exit (exit slopes UP)
  
Corners (4 variants): Corner(NORTHEAST|NORTHWEST|SOUTHEAST|SOUTHWEST)
  Creates: /obj/Landscaping/Ditch/ditch*COR (corner terrain)
  
Straight (2 variants): Ditch(NORTH/SOUTH) | Ditch(EAST/WEST)
  Creates: /obj/Landscaping/Ditch/ditchSN or ditchSE (ditch floor)
```
- **Elevation Integration**: Creates elevation/ditch objects
- **Climbing Integration**: User must climb in/out (no climbing system yet!)
- **Trap Feature**: Can create trapless ditches (no exit slope = player trapped)
- **Requires Rank 7+**

#### 7. **Hill** (Elevation creation - Rank 8+)
- Similar structure to Ditch but creates elevated terrain
- `/obj/Landscaping/Hill/*` objects
- Users climb UP to higher elevation

#### 8. **Water** (Rank 9+)
#### 9. **Lava** (Rank 10 only)

---

## 5. Code Quality Issues

### Issue 1: Repetitive Code (CRITICAL)
**Problem**: ~100+ near-identical blocks following this pattern:
```dm
if("North/South")
    if(M.SHequipped==1)
        a = new/obj/Landscaping/Road/DirtRoad/NSRoad(usr.loc)
        a:buildingowner = ckeyEx("[usr.key]")
        M.digexp += 15
        M.stamina -= 5
        M.updateST()
        M.updateDXP()  // BROKEN - proc doesn't exist!
        Busy = 0
        M.UED = 0
        return call(/proc/diglevel)(M)
```
**Impact**: 
- Hard to maintain
- Difficult to modify XP values globally
- Error-prone when adding new features
- **Solution**: Extract to helper proc `CreateLandscapeObject(object_type, xp_amount)`

### Issue 2: Missing updateDXP() Proc
**Problem**: Called 150+ times but doesn't exist
- UI doesn't show dig XP progress
- Player can't see rank/XP status
**Solution**: Replace with `M.character.UpdateRankExp(RANK_DIGGING, amount)` pattern

### Issue 3: Brittle Rank Gates
**Problem**: Hard-coded `if(M.drank == X)` checks scattered through code
- Difficult to modify unlock thresholds
- Easy to miss when adding new features
**Solution**: Centralize via UnifiedRankSystem registry

### Issue 4: Old Variables Still Exist
**Problem**: `M.digexp` and `M.drank` used instead of `M.character.digging_rank`
- Violates single-source-of-truth principle
- Breaks persistence if CharacterData not saved
**Solution**: Full migration to `character.digging_rank`, `character.digging_xp`, `character.digging_maxexp`

### Issue 5: No Macro Integration
**Problem**: Only accessible via right-click Dig() verb
- Building system uses same pattern
- Opportunity for unified grid-based interface
**Solution**: Create MacroableLandscaping.dm with UseObject() handlers

---

## 6. Integration Opportunities

### With Climbing System (NEW)
**Current State**: Ditches and hills created but no way to climb in/out
**Missing**: 
- Climbing skill progression
- Speed/safety improvements with rank
- Climbable wall detection
- Auto-failsafe on climbing failure

**Design Gap**: Ditch/hill objects are placeholders - need climbing logic
- **Ditch entry**: Must climb down (1.5 → 0.5 elevation)
- **Ditch exit**: Must climb up (0.5 → 1.5 elevation)
- **Hill entry**: Must climb up (1.0 → 2.0 elevation)
- **Hill exit**: Must climb down (2.0 → 1.0 elevation)

### With Grid-Based Placement System
**Building System** (jb.dm lines 2300+):
- Uses verb-based input dialogs
- Uses `UpdateRankExp(RANK_BUILDING, amount)` ✅ (already modern!)
- No grid visualization
- Stand-still crafting (different from landscaping)

**Landscaping System**:
- Also verb-based
- Still uses old `digexp` variables
- No grid visualization
- Could be active-movement crafting (place while walking)

**Opportunity**: 
- Extract common "placement + confirmation" flow
- Create unified grid visualization system
- Support both stand-still (building) and active-movement (landscaping) modes
- Extend to other crafting systems (smithing, cooking)

### With Elevation System
**Current**: Ditch/hill objects are elevation/ditch and elevation/hill types
**Integration Points**:
- Auto-set elevel on placement
- Enforce level range checks for climbing
- Integration with Chk_LevelRange() for interactions

**Missing**: Climbing procs to handle traversal

---

## 7. Modernization Roadmap

### Phase 1: Data Migration (Quick Win)
1. ✅ Add to CharacterData.dm:
   ```dm
   var
       digging_rank = 0
       digging_xp = 0
       digging_maxexp = 100
   ```

2. ✅ Add to UnifiedRankSystem.dm RANK_DEFINITIONS:
   ```dm
   RANK_DIGGING = "drank"
   ```
   Registry entry: `[digging_rank, digging_xp, digging_maxexp, "dig_rank_ui", "Digging"]`

3. ✅ Replace all `M.digexp += X` with:
   ```dm
   M.character.UpdateRankExp(RANK_DIGGING, X)
   ```

4. ❌ Delete M.drank, M.digexp, M.mdigexp references
   - Replace with `M.character.GetRankLevel(RANK_DIGGING)`, etc.

5. ❌ Delete `call(/proc/diglevel)(M)` calls
   - UpdateRankExp handles level-ups automatically

6. ✅ Delete dead diglevel() proc
   - Now handled by UnifiedRankSystem

### Phase 2: Code Refactoring (Medium Effort)
1. Extract CreateLandscapeObject(object_type, xp_amount, direction) proc
   ```dm
   proc/CreateLandscapeObject(mob/players/M, object_type, xp_amount, optional_direction)
       if(!CanPlayerBuildAtLocation(M, M.loc)) return
       if(M.SHequipped != 1) return M << "Need shovel equipped"
       if(M.stamina < required_stamina) return M << "Too tired"
       
       var/obj/landscaping_object = new object_type(M.loc)
       landscaping_object.buildingowner = ckeyEx("[M.key]")
       M.stamina -= required_stamina
       M.updateST()
       M.character.UpdateRankExp(RANK_DIGGING, xp_amount)
   ```

2. Consolidate input dialogs into menu system
   - Central list of available options per rank
   - One switch/case handler per menu level

3. Extract deed checking to reusable proc
   - `CheckBuildPermission(M)` used by both building and digging

### Phase 3: Climbing System (New)
1. Create RANK_CLIMBING
   - Add to CharacterData.dm, UnifiedRankSystem.dm
   - Progression: Slow climb → Fast climb, Risky → Sure-footed

2. Implement climbing procs
   ```dm
   proc/AttemptClimb(mob/players/M, target_elevation)
       success = base_success - (rank_penalty * M.character.GetRankLevel(RANK_CLIMBING))
       if(prob(success)) traverse_elevation(M, target_elevation)
       else fall_damage(M)
   ```

3. Integrate with Ditch/Hill objects
   - Detect climbable walls (ditches, hills, trenches)
   - Prevent climbing non-climbable walls (forts, castle walls)
   - Call AttemptClimb() on climb attempt

### Phase 4: Grid-Based Macro System (Advanced)
1. Analyze BuildingMenuUI.dm for grid visualization
   - Reuse or extend for landscaping

2. Create LandscapingMacro.dm
   - UseObject() handlers for placement
   - Grid selection interface
   - Macro keys: [Q/E] for menu, [R] to rotate, [SPACE] to confirm, [ESC] to cancel

3. Extend to other crafting
   - Smithing via macro (not just stand-still)
   - Smelting via macro
   - Cooking via macro (already modern but still verb-only)

4. Active-movement support
   - Allow placement while walking
   - Queue placement actions during movement
   - Execute on movement completion

---

## 8. File Dependencies

### Current Dependencies
- `CharacterData.dm` - Player skill storage (needs digging_* vars)
- `UnifiedRankSystem.dm` - Rank progression (needs RANK_DIGGING)
- `Objects.dm` - Deed/building checks (has deed permission procs)
- `movement.dm` - Player movement (for active-movement crafting)
- Elevation system (for ditch/hill elevation integration)

### New Dependencies (Post-Modernization)
- `Climbing.dm` (new) - Climbing mechanics
- `LandscapingMacro.dm` (new) - Grid-based placement interface
- `GridPlacementUI.dm` (new) - Shared grid visualization

---

## 9. Known Gotchas

1. **Stamina Dependency**: Most dig actions require stamina > 5
   - Tied to hunger/consumption system
   - Extreme cold/heat increases stamina drain
   - Running out of stamina blocks all dig actions

2. **Shovel Requirement**: Must have shovel equipped
   - Equipment variable: `M.SHequipped == 1`
   - Remove shovel and digging disabled
   - Ties to equipment overlay system

3. **Deed Permission**: Deed zones override all other flags
   - Code checks `M.canbuild == 0` first
   - Returns "You do not have permission to build"
   - Must be in player's deed zone OR no deeds exist at location

4. **Elevation Enforcement**: User must manually use ladder/climbs
   - Ditches trap players without exit slope
   - Hills block upward movement without climbing
   - No auto-detection of elevation boundaries
   - **This is why climbing system is critical**

5. **UED/UEB Flags**: Player state flags during digging
   - `M.UED = 1` during digging (prevents double-casting)
   - `M.UEB = 1` during building
   - Must be reset on cancel/completion
   - Risk of getting stuck if flag not reset

6. **Busy Variable**: Global, not per-player
   - `var/Busy = 0` at top of file
   - Only one player can dig at a time across entire server!
   - **BUG**: Should be `M.busy` instead
   - **Impact**: High-concurrency issues on populated servers

---

## 10. Quick-Win Improvements (No Architecture Changes)

1. **Create updateDXP() proc**
   ```dm
   mob/players/proc/updateDXP()
       if(!character) return
       winset(usr, "dig_rank", "text='[character.GetRankLevel(RANK_DIGGING)]'")
       winset(usr, "dig_xp", "text='[character.GetRankExp(RANK_DIGGING)]/[character.GetRankMaxExp(RANK_DIGGING)]'")
   ```

2. **Fix Busy variable concurrency bug**
   - Replace `var/Busy` with `M.busy` check
   - Or better: check `M.UED == 1` (already done for state)

3. **Add deed permission helper**
   ```dm
   proc/CheckDigPermission(mob/players/M)
       if(!CanPlayerBuildAtLocation(M, M.loc)) return 0
       return 1
   ```

4. **Consolidate stamina checks**
   ```dm
   #define DIG_STAMINA_COST 5
   #define DITCH_STAMINA_COST 10
   #define HILL_STAMINA_COST 15
   ```

---

## 11. Summary

| Aspect | Status | Priority |
|--------|--------|----------|
| **Data Model** | BROKEN (missing updateDXP, using player vars) | 🔴 HIGH |
| **Code Quality** | POOR (100+ identical blocks) | 🔴 HIGH |
| **Rank System** | DEPRECATED (uses old pattern) | 🟡 MEDIUM |
| **Climbing Integration** | MISSING (ditches trap players) | 🔴 HIGH |
| **Macro Integration** | NONE (verb-only) | 🟡 MEDIUM |
| **Deed Integration** | WORKING (permission checks done) | ✅ GOOD |
| **UI/UX** | POOR (dialog-based, no progress display) | 🟡 MEDIUM |
| **Concurrency** | BROKEN (shared Busy variable) | 🔴 HIGH |

**Total Lines of Deprecated Code**: ~600 lines can be refactored to ~200 lines
**Estimated Modernization Time**: 2-3 hours for full refactor + climbing + macro system
