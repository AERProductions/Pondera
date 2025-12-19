# Building System Modernization Strategy - Phase 6

## OBJECTIVE
Transition from legacy jb.dm (11,000 line monolithic building system) to modern BuildingMenuUI.dm while maintaining 100% gameplay compatibility and data integrity.

---

## CURRENT STATE

### Legacy System (jb.dm)
- **Location**: dm/jb.dm, lines 1317-5600+
- **Size**: ~4,300 lines of nested switch statements
- **Characteristics**:
  - Alert dialog UI
  - Hardcoded material checks
  - Scattered deed permission checks
  - Uses old `buildexp` variable (not unified rank system)
  - Direct property manipulation (M.stamina -= X)
  - No visual feedback/preview
- **Status**: Fully functional, widely used

### Modern System (BuildingMenuUI.dm)
- **Location**: dm/BuildingMenuUI.dm, lines 1-559
- **Size**: 559 lines of clean, procedural code
- **Characteristics**:
  - Global recipe registry (BUILDING_RECIPES)
  - Unified deed permission checks (CanPlayerBuildAtLocation)
  - Proper rank system integration
  - Better error messages
  - Verb: `open_building_menu()`
- **Status**: Code exists but not integrated into main UI flow

---

## MIGRATION PHASES

### PHASE A: Add Modern System Alongside Legacy (NON-BREAKING)

**Timing**: This week (Session)

**Changes**:
1. Create alias verb in BuildingMenuUI or Basics.dm
   ```dm
   /mob/players/verb/BuildModern()
       set name = "Build (Modern)"
       set category = "Actions"
       DisplayBuildingMenu(usr)
   ```

2. Keep old verb hidden but available
   ```dm
   // In jb.dm, change existing verb:
   verb/Build()
       set hidden = 1  // Hide from players
       // Legacy code unchanged
   ```

3. Update UI button to call new verb
   - Find the "Build" button in DMF interface
   - Change command from `/verb/Build` to `/verb/BuildModern`

**Result**: Players can opt-in to test modern system while legacy still works

---

### PHASE B: Migrate Building Recipes (Parallel Work)

**Timing**: Sessions 2-3 of building system work

**Task**: Move ALL building recipes from jb.dm's nested switches into BUILDING_RECIPES registry

**Current State**:
- jb.dm has ~200+ recipe definitions embedded in switch/case tree
- Example:
  ```dm
  if("Stone Wall") switch(input(...) in list("Northeast", "North", ...))
      if("Northeast")
          if((M.TWequipped==1)&&(J in M.contents)&&...)
              // Check materials, consume, spawn
  ```

**Target State**:
- BUILDING_RECIPES contains all 200+ recipes as datum objects
- Each recipe self-contained:
  ```dm
  BUILDING_RECIPES["stone_wall_ne"] = new /datum/building_recipe(
      recipe_name = "stone_wall_ne",
      display_name = "Stone Wall (NE)",
      building_type = /obj/Buildable/Walls/SNEWall,
      materials = list("mortar" = 1, "bricks" = 3),
      // ...
  )
  ```

**Effort**: High (but scriptable)

---

### PHASE C: Cutover (Switch Primary UI)

**Timing**: When Phase B recipes complete (verified)

**Changes**:
1. Make BuildModern the default:
   ```dm
   /mob/players/verb/Build()
       set name = "Build"
       set category = "Actions"
       DisplayBuildingMenu(usr)
   ```

2. Make legacy hidden:
   ```dm
   // In jb.dm
   verb/BuildLegacy()
       set hidden = 1
       // Legacy code (unchanged)
   ```

3. Redirect old calls:
   ```dm
   // In any old code calling verb/Build():
   // usr.BuildLegacy()  // If fallback needed
   ```

**Result**: Players use modern system by default, legacy available for testing/fallback

---

### PHASE D: Validation & Testing

**Timing**: 1-2 weeks after cutover

**Tests**:
- ✅ All building types place correctly
- ✅ Materials consumed accurately
- ✅ Deed permissions enforced
- ✅ XP awarded via unified rank system
- ✅ Stamina costs applied
- ✅ Tool requirements working
- ✅ Building ownership saved
- ✅ Rotation working correctly

**Result**: Confidence that modern system is production-ready

---

### PHASE E: Deprecation & Cleanup

**Timing**: 1 month after cutover (stable verification)

**Changes**:
1. Remove legacy code from jb.dm
   ```dm
   // DELETE: verb/Build() definition
   // DELETE: All recipe switch statements (4000+ lines)
   // KEEP: Non-building systems in jb.dm (if any)
   ```

2. Archive old code
   ```dm
   // Create: dm/archive/jb_legacy_building.dm
   // Copy entire old system there for reference
   ```

3. Update documentation
   - Mark old BuildingSystem docs as archived
   - Update integration guides

**Result**: Clean codebase, legacy preserved in archive

---

## DETAILED RECIPE MIGRATION EXAMPLE

### Current (jb.dm - Complex)
```dm
if("Stone Walls") switch(input("Select Wall Type","Stone Walls") as anything in L2)
    if("NorthEast Wall")
        var/obj/items/Crafting/Created/Mortar/J = locate() in M.contents
        var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
        var/Mortar = "1 Mortar"
        var/Stone = "3 Piles of Bricks"
        if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&
            (J.stack_amount >= 1)&&(J2.stack_amount >= 3)&&(M.stamina >= 50))
            for(J in M.contents) J.RemoveFromStack(1)
            for(J2 in M.contents) J2.RemoveFromStack(3)
            M.UETW = 1
            if(M.stamina >= 50)
                M.stamina -= 50
                M.updateST()
                M.buildexp += 50
                a = new/obj/Buildable/Walls/SNEWall(usr.loc)
                a:buildingowner = ckeyEx("[usr.key]")
                M.UEB = 0
                M.UETW = 0
                return call(/proc/buildlevel)()
            else
                M.UEB = 0
                M << "You lack the effort, replenish your stamina..."
                return
        else
            M.UEB = 0
            M << "You lack the effort (stamina: [M.stamina]) or the material..."
            return
    if("North Wall")
        // ... 20 more lines, nearly identical
    // ... 15 more wall types, each 20+ lines
if("Wooden Walls")
    // ... 300 more lines
if("Doors")
    // ... 500 more lines
// ... etc - total 4000+ lines for 200 recipes
```

### Modern (BuildingMenuUI.dm - Clean)
```dm
BUILDING_RECIPES["stone_wall_ne"] = new /datum/building_recipe(
    recipe_name = "stone_wall_ne",
    display_name = "Stone Wall (NE)",
    icon_file = 'dmi/64/walls.dmi',
    icon_state = "swne",
    building_type = /obj/Buildable/Walls/SNEWall,
    required_skill = RANK_BUILDING,
    required_skill_level = 1,
    materials = list("mortar" = 1, "bricks" = 3),
    rotation_allowed = FALSE,
    placement_radius = 1,
    description = "A northeast-facing stone wall section",
    skill_bonus = 50,
    stamina_cost = 50
)
```

**Conversion**: From 20+ lines per recipe → 12 lines per recipe  
**Benefit**: 40% code reduction, easier to maintain, easier to tweak

---

## DEED PERMISSION UNIFICATION

Currently in jb.dm building code:
```dm
if(M.canbuild==0)
    M << "You do not have permission..."
    return
```

**MUST CHANGE** to use modern system:
```dm
if(!CanPlayerBuildAtLocation(M, usr.loc))
    return
```

This is already implemented in BuildingMenuUI, just needs to be confirmed.

---

## RANK SYSTEM INTEGRATION

### Current (Old):
```dm
M.buildexp += 50
M.updateST()  // Direct stamina manipulation
```

### Modern:
```dm
M.character.UpdateRankExp(RANK_BUILDING, 50)
M.stamina -= 50
M.updateST()
```

BuildingMenuUI already uses modern system, verified in code.

---

## INTEGRATION CHECKLIST

### Phase A (This Week)
- [ ] Create `/mob/players/verb/BuildModern()` alias
- [ ] Hide old `/mob/players/verb/Build()` (set hidden = 1)
- [ ] Test both systems work in parallel
- [ ] Verify no conflicts

### Phase B (Next 2 Sessions)
- [ ] Extract all recipes from jb.dm
- [ ] Create datum objects for each
- [ ] Add to BUILDING_RECIPES registry
- [ ] Verify recipe counts match old system

### Phase C (After Phase B Complete)
- [ ] Swap default UI button to BuildModern
- [ ] Run comprehensive testing
- [ ] Fix any integration gaps

### Phase D (1-2 weeks post-swap)
- [ ] Monitor error logs
- [ ] Track player feedback
- [ ] Verify all building types functional
- [ ] Test edge cases (rotation, boundaries, deed zones)

### Phase E (1 month post-swap)
- [ ] Remove old jb.dm building code
- [ ] Archive to dm/archive/
- [ ] Update all documentation
- [ ] Close building refactor tickets

---

## RISK MITIGATION

### Risk: Recipe data loss during migration
**Mitigation**: 
- Keep jb.dm unchanged during migration
- Verify recipe counts (old vs new)
- Side-by-side testing before cutover

### Risk: Players can't build during transition
**Mitigation**:
- Both systems available simultaneously
- Default to legacy until modern verified
- Explicit migration flag if needed

### Risk: XP/rank data inconsistency
**Mitigation**:
- Modern system uses unified rank system
- Legacy system updated to also use unified system
- Verify xp awarded is identical

### Risk: Deed permissions not enforced equally
**Mitigation**:
- Both systems use same permission functions
- Audit permission checking in both paths
- Add logging/analytics

---

## EXPECTED BENEFITS

| Aspect | Before | After |
|--------|--------|-------|
| **Code lines (building)** | 4,300 | 700 |
| **Recipe definitions** | Scattered | Centralized registry |
| **Permission checks** | 3 patterns | 1 pattern |
| **Maintainability** | Low | High |
| **Feature additions** | Hard (navigate 4k lines) | Easy (add recipe to registry) |
| **Testing** | Manual per recipe | Data-driven |
| **UI Quality** | Alert dialogs | Modern interface |
| **Error messages** | Generic | Detailed with deed info |

---

## SUCCESS CRITERIA

✅ Phase A: Alias works, both systems available  
✅ Phase B: All 200+ recipes migrated to registry  
✅ Phase C: BuildModern is default, all tests pass  
✅ Phase D: 2 weeks stable, no permission/xp/deed issues  
✅ Phase E: jb.dm legacy code removed, codebase cleaner

---

## SUPPORTING IMPROVEMENTS (Phase 6 Concurrent)

While doing building migration:
1. ✅ **Consolidate Carving→Woodworking** (DONE)
2. ✅ **Unify Deed Permission Checks** (Audit complete, ready for implementation)
3. ⏳ **Select Equipment Rendering System** (Recommendation: Workaround for now)

---

**Estimated Total Timeline**: 3-4 weeks
**Estimated Code Reduction**: 4,000+ lines  
**Risk Level**: LOW (old system stays until confident)
