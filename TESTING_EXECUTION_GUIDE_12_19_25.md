# In-Game Testing Execution Guide - Options 1 & 4

**Status:** Ready for Testing  
**Date:** December 19, 2025  
**Build:** CLEAN (0 new errors) ✅  
**Commit:** cebfb57 (Options 1 & 4 complete)

---

## Quick Start

### Test Environment Setup
1. Launch Pondera server with latest build
2. Log in with test character (any level)
3. Navigate to testing locations per instructions below
4. Run each test case, document results in provided template

### Key Testing Locations
- **Cooking:** Kitchen/Oven area
- **Smithing:** Forge/Anvil workshop
- **Gardening:** Farm plots with soil/vegetables/grains/bushes
- **Building:** Any deed structure (doors, walls, storage)

---

## Option 1: E-Key Macro Testing

### Test Group 1: Cooking System

**Setup:** Locate Oven object

**Test 1.1: Oven E-Key Menu**
```
Action: Press E while standing adjacent to Oven
Expected: Cooking menu appears (list of recipes)
Timeline: <500ms response time
Pass Criteria: Menu shows > 0 recipes
```

**Test 1.2: Oven Verb Interaction (Regression)**
```
Action: Right-click Oven, select "Cook"
Expected: Same cooking menu appears
Timeline: <500ms
Pass Criteria: Identical menu to E-key version
```

**Test 1.3: Oven Range Check**
```
Action: Move 2+ tiles away from Oven, press E
Expected: No menu appears, player sees nothing
Timeline: Immediate
Pass Criteria: No error message (silent failure expected)
```

**Test 1.4: Cook Recipe & XP Award**
```
Action: Select simple recipe (bread, stew, etc.)
Expected: Item appears in inventory, XP gains toward RANK_COOKING
Timeline: 1-3 seconds for completion
Pass Criteria: Rank increased by 1+ XP
```

---

### Test Group 2: Smithing System - Anvil

**Setup:** Locate Anvil object

**Test 2.1: Anvil E-Key Menu**
```
Action: Press E while adjacent to Anvil
Expected: Smithing menu appears
Timeline: <500ms
Pass Criteria: Menu shows smithing options
```

**Test 2.2: Anvil Verb Interaction (Regression)**
```
Action: Right-click Anvil, select "Smith"
Expected: Same menu as E-key
Timeline: <500ms
Pass Criteria: Menus identical
```

**Test 2.3: Anvil XP Award**
```
Action: Create item via smithing at Anvil
Expected: RANK_SMITHING increases
Timeline: 1-3 seconds
Pass Criteria: Rank increases 1+ XP
```

**Test 2.4: Anvil Range Check**
```
Action: Move 2+ tiles away, press E
Expected: No menu, silent
Timeline: Immediate
Pass Criteria: No response
```

---

### Test Group 3: Smithing System - Forge

**Setup:** Locate Forge object

**Test 3.1: Forge E-Key Menu**
```
Action: Press E while adjacent to Forge
Expected: Forge menu appears (smelting/crafting)
Timeline: <500ms
Pass Criteria: Menu visible
```

**Test 3.2: Forge Verb Interaction (Regression)**
```
Action: Right-click Forge, select "Use"
Expected: Same menu as E-key
Timeline: <500ms
Pass Criteria: Menus identical
```

**Test 3.3: Forge Heat/Status Check**
```
Action: Look at Forge status in menu
Expected: Shows heat level, fuel status
Timeline: <100ms
Pass Criteria: All info displays correctly
```

**Test 3.4: Forge Range Check**
```
Action: Move 2+ tiles away, press E
Expected: No menu, silent
Timeline: Immediate
Pass Criteria: No response
```

---

### Test Group 4: Gardening System - Soil Deposits

**Setup:** Locate Soil object (in farm area)

**Test 4.1: Soil E-Key Harvest**
```
Action: Press E while on/adjacent to Soil
Expected: Harvesting prompt or auto-harvest
Timeline: <500ms
Pass Criteria: Dirt/soil appears in inventory
```

**Test 4.2: Soil XP Award**
```
Action: Observe RANK_GARDENING after harvest
Expected: Rank increases 1+ XP
Timeline: 1-2 seconds
Pass Criteria: Confirmed XP gain
```

**Test 4.3: Soil Verb Interaction (Regression)**
```
Action: Right-click Soil, select "Harvest"
Expected: Same result as E-key
Timeline: <500ms
Pass Criteria: Item harvested
```

**Test 4.4: Soil Range Check**
```
Action: Move 2+ tiles away, press E
Expected: No harvest, silent
Timeline: Immediate
Pass Criteria: No response
```

---

### Test Group 5: Gardening System - Vegetables

**Setup:** Locate vegetable plant (Corn, Potato, etc.)

**Test 5.1: Vegetable E-Key Harvest**
```
Action: Press E while adjacent to mature vegetable
Expected: Vegetable item appears in inventory
Timeline: <500ms
Pass Criteria: Item harvested successfully
```

**Test 5.2: Vegetable Growth Stage Check**
```
Action: Press E on immature vegetable
Expected: Message: "Not ready to harvest" or similar
Timeline: <100ms
Pass Criteria: Growth stage respected
```

**Test 5.3: Vegetable XP Award**
```
Action: Harvest mature vegetable
Expected: RANK_GARDENING increases 1+ XP
Timeline: 1-2 seconds
Pass Criteria: XP gain confirmed
```

**Test 5.4: Vegetable Verb Interaction (Regression)**
```
Action: Right-click mature vegetable, select "Pick"
Expected: Same harvest as E-key
Timeline: <500ms
Pass Criteria: Item harvested
```

---

### Test Group 6: Gardening System - Grains

**Setup:** Locate grain plant (Wheat, Barley, etc.)

**Test 6.1: Grain E-Key Harvest**
```
Action: Press E while adjacent to mature grain
Expected: Grain item in inventory
Timeline: <500ms
Pass Criteria: Item harvested
```

**Test 6.2: Grain Growth Stage Check**
```
Action: Press E on immature grain
Expected: "Not ready" message
Timeline: <100ms
Pass Criteria: Growth stage respected
```

**Test 6.3: Grain XP Award**
```
Action: Harvest mature grain
Expected: RANK_GARDENING increases
Timeline: 1-2 seconds
Pass Criteria: XP confirmed
```

**Test 6.4: Grain Verb Interaction (Regression)**
```
Action: Right-click mature grain, select "Harvest"
Expected: Same as E-key
Timeline: <500ms
Pass Criteria: Item harvested
```

---

### Test Group 7: Gardening System - Bushes

**Setup:** Locate berry bush or other bush type

**Test 7.1: Bush E-Key Pick**
```
Action: Press E while adjacent to mature bush
Expected: Berry/fruit in inventory
Timeline: <500ms
Pass Criteria: Item harvested
```

**Test 7.2: Bush Growth Stage Check**
```
Action: Press E on immature bush
Expected: "Not ripe" or similar message
Timeline: <100ms
Pass Criteria: Growth stage respected
```

**Test 7.3: Bush XP Award**
```
Action: Pick from mature bush
Expected: RANK_GARDENING increases
Timeline: 1-2 seconds
Pass Criteria: XP confirmed
```

**Test 7.4: Bush Verb Interaction (Regression)**
```
Action: Right-click bush, select "Pick"
Expected: Same as E-key
Timeline: <500ms
Pass Criteria: Item harvested
```

---

## Regression Testing

### Test R1: Verb Menus Still Work
```
Action: Right-click 5 different objects (oven, anvil, forge, soil, plant)
Expected: All verb menus appear with registered commands
Timeline: <500ms each
Pass Criteria: All 5+ menus functional
```

### Test R2: No Performance Degradation
```
Action: Use E-key continuously on multiple objects (press E 10x in 5 seconds)
Expected: No lag, stuttering, or timeout
Timeline: Smooth response
Pass Criteria: Frame rate stable, no freezes
```

### Test R3: E-Key + Verb Menu Coexist
```
Action: Press E on object, then right-click same object
Expected: Both methods work interchangeably
Timeline: <1 second
Pass Criteria: No conflicts, consistent results
```

### Test R4: Error Messages Clear
```
Action: Try to harvest immature plant, fail permission check, etc.
Expected: Clear feedback message appears
Timeline: <500ms
Pass Criteria: User understands what happened
```

---

## Option 4: Building System E-Key Testing

### Test B1: Door E-Key Interaction

**Setup:** Locate any door object (standard door, etc.)

```
Action: Press E while adjacent to closed door
Expected: Door opens (or shows interaction menu)
Timeline: <500ms
Pass Criteria: Door responds to E-key
```

### Test B2: Wall/Structure E-Key (Permission Gated)

**Setup:** Locate wall/fortification in owned deed

```
Action: Press E while adjacent to wall (owner)
Expected: Structure menu appears
Timeline: <500ms
Pass Criteria: Access granted
```

### Test B3: Wall E-Key (No Permission)

**Setup:** Locate wall in deed you don't own

```
Action: Press E while adjacent to wall (non-owner)
Expected: Error message: "Permission denied" or similar
Timeline: <500ms
Pass Criteria: Denied access, clear message
```

### Test B4: Storage Container E-Key

**Setup:** Locate storage box/chest in owned deed

```
Action: Press E while adjacent to storage
Expected: Inventory interface opens
Timeline: <500ms
Pass Criteria: Container accessible
```

### Test B5: Storage Container (No Permission)

**Setup:** Locate storage in deed you don't own

```
Action: Press E to access storage
Expected: Error message "Cannot access"
Timeline: <500ms
Pass Criteria: Denied, clear message
```

### Test B6: Utility Structure E-Key (Public)

**Setup:** Locate well, water trough, or public utility

```
Action: Press E while adjacent (any player)
Expected: Utility interaction available
Timeline: <500ms
Pass Criteria: Public access works
```

---

## Test Results Template

### Cooking System Results
| Test # | Name | Expected | Actual | Pass/Fail | Notes |
|--------|------|----------|--------|-----------|-------|
| 1.1 | Oven E-Key | Menu appears | | | |
| 1.2 | Oven Verb | Same menu | | | |
| 1.3 | Oven Range | Silent fail | | | |
| 1.4 | Oven XP | XP awarded | | | |

### Smithing Anvil Results
| Test # | Name | Expected | Actual | Pass/Fail | Notes |
|--------|------|----------|--------|-----------|-------|
| 2.1 | Anvil E-Key | Menu appears | | | |
| 2.2 | Anvil Verb | Same menu | | | |
| 2.3 | Anvil XP | XP awarded | | | |
| 2.4 | Anvil Range | Silent fail | | | |

### Smithing Forge Results
| Test # | Name | Expected | Actual | Pass/Fail | Notes |
|--------|------|----------|--------|-----------|-------|
| 3.1 | Forge E-Key | Menu appears | | | |
| 3.2 | Forge Verb | Same menu | | | |
| 3.3 | Forge Status | Info displays | | | |
| 3.4 | Forge Range | Silent fail | | | |

### Gardening Soil Results
| Test # | Name | Expected | Actual | Pass/Fail | Notes |
|--------|------|----------|--------|-----------|-------|
| 4.1 | Soil E-Key | Item harvested | | | |
| 4.2 | Soil XP | XP awarded | | | |
| 4.3 | Soil Verb | Same harvest | | | |
| 4.4 | Soil Range | Silent fail | | | |

### Gardening Vegetables Results
| Test # | Name | Expected | Actual | Pass/Fail | Notes |
|--------|------|----------|--------|-----------|-------|
| 5.1 | Veg E-Key | Item harvested | | | |
| 5.2 | Veg Growth | Growth respected | | | |
| 5.3 | Veg XP | XP awarded | | | |
| 5.4 | Veg Verb | Same harvest | | | |

### Gardening Grains Results
| Test # | Name | Expected | Actual | Pass/Fail | Notes |
|--------|------|----------|--------|-----------|-------|
| 6.1 | Grain E-Key | Item harvested | | | |
| 6.2 | Grain Growth | Growth respected | | | |
| 6.3 | Grain XP | XP awarded | | | |
| 6.4 | Grain Verb | Same harvest | | | |

### Gardening Bushes Results
| Test # | Name | Expected | Actual | Pass/Fail | Notes |
|--------|------|----------|--------|-----------|-------|
| 7.1 | Bush E-Key | Item harvested | | | |
| 7.2 | Bush Growth | Growth respected | | | |
| 7.3 | Bush XP | XP awarded | | | |
| 7.4 | Bush Verb | Same harvest | | | |

### Regression Testing Results
| Test # | Name | Expected | Actual | Pass/Fail | Notes |
|--------|------|----------|--------|-----------|-------|
| R1 | Verb Menus | All work | | | |
| R2 | Performance | No lag | | | |
| R3 | Coexistence | Both methods work | | | |
| R4 | Error Messages | Clear feedback | | | |

### Building System Results
| Test # | Name | Expected | Actual | Pass/Fail | Notes |
|--------|------|----------|--------|-----------|-------|
| B1 | Door E-Key | Door opens | | | |
| B2 | Wall (Owner) | Access granted | | | |
| B3 | Wall (No Perm) | Denied, message | | | |
| B4 | Storage (Owner) | Access granted | | | |
| B5 | Storage (No Perm) | Denied, message | | | |
| B6 | Utility (Public) | Access granted | | | |

---

## Pass/Fail Criteria

### PASS Conditions (All Required)
- [ ] 28 test cases: 26+ pass (93%+)
- [ ] 4 regression tests: 4/4 pass (100%)
- [ ] 6 building tests: 6/6 pass (100%)
- [ ] No unexpected errors logged
- [ ] Performance acceptable (frame rate stable)
- [ ] Error messages clear and helpful

### FAIL Conditions (Any trigger investigation)
- [ ] <26 test cases pass (<93%)
- [ ] Any regression test fails
- [ ] Any permission check fails
- [ ] E-key unresponsive (>1000ms response time)
- [ ] Menu/action doesn't trigger
- [ ] XP awards missing
- [ ] Growth stages not respected

---

## Troubleshooting Guide

### If E-Key Doesn't Respond
1. Verify character in range (1 tile)
2. Check if object has UseObject() handler
3. Review build errors for missing includes
4. Check world initialization complete flag
5. Try verb method (right-click) as fallback

### If Menu Appears But Action Fails
1. Verify ingredients/materials available
2. Check rank/skill requirements met
3. Review character inventory space
4. Check deed permissions (for building)
5. Look for error messages in game log

### If XP Not Awarded
1. Verify RANK constant defined
2. Check character.UpdateRankExp() called
3. Review rank level cap (max 5)
4. Check for exp threshold calculations
5. Verify rank system initialized

### If Permission Denied Incorrectly
1. Verify deed ownership/membership
2. Check CanPlayerBuildAtLocation() result
3. Review deed zone boundaries
4. Verify player permission bits set
5. Check for deed freeze status

---

## Success Metrics

### Quantitative
- [ ] 28/28 Option 1 test cases passing
- [ ] 4/4 regression tests passing
- [ ] 6/6 building tests passing
- [ ] 0 new error messages
- [ ] <500ms response time (99%+)

### Qualitative
- [ ] E-key feels responsive and intuitive
- [ ] No degradation vs. verb menus
- [ ] Error messages helpful when denying access
- [ ] Permission system working as intended
- [ ] XP awards consistent

---

## Next Steps After Testing

### If All Tests Pass ✅
1. Mark todos as complete
2. Create final session summary
3. Plan Smithing Phase 2 (9-12 hours)
4. Plan Digging Phase B (4-6 hours)
5. Schedule dedicated sessions (no token limits)

### If Issues Found ❌
1. Document bugs per template above
2. Prioritize by severity (critical/high/medium/low)
3. Quick fixes if simple (<30 mins)
4. Defer complex fixes to dedicated debugging session
5. Continue with Phase 3+ after core issues resolved

---

## Session Summary

**Options 1 & 4: Light Work Completion**
- Phase 1-2 crafting modernization: COMPLETE ✅
- Build system E-key integration: COMPLETE ✅
- Testing plan: READY ✅
- Commit cebfb57: PUSHED ✅

**Ready for In-Game Verification**
- 28 test cases prepared
- 4 regression tests planned
- 6 building tests designed
- Expected timeline: 45-65 minutes

**Upon Testing Completion:**
- Full session review & summary
- Plan Phase 3+ dedicated work
- No time/token limits (user approved)

---

**Status:** READY FOR TESTING  
**Build:** CLEAN (0 new errors) ✅  
**Commit:** cebfb57 (Options 1 & 4 complete)  
**Date:** December 19, 2025
