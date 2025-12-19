# Option 1: E-Key Macro Testing Plan

**Objective:** Verify all 5 Phase 1-2 systems work correctly with E-key macro support  
**Duration:** 2 hours (comprehensive testing)  
**Test Environment:** In-game on Pondera server

---

## Test Matrix: All Crafting/Gathering Systems

### 1. COOKING SYSTEM (E-Key + Verb)
**Location:** Any kitchen area with Oven  
**Objects to Test:** /obj/Oven

**Test Cases:**
- [ ] **Test 1.1:** Click E near oven (targeting with mouse)
  - Expected: ShowCookingMenu appears, player can select recipes
  - Verify: Menu responsive, recipe selection works
  
- [ ] **Test 1.2:** Right-click oven (old verb method)
  - Expected: Verb menu appears with cooking options
  - Verify: No regression, verb still functional
  
- [ ] **Test 1.3:** E-key while moving
  - Expected: Gracefully cancels if out of range
  - Verify: Error message if >1 tile away
  
- [ ] **Test 1.4:** Craft item via E-key menu
  - Expected: Item created, XP awarded, rank checked
  - Verify: M.character.UpdateRankExp() works silently

**Success Criteria:** E-key opens menu consistently, verb still works, no errors

---

### 2. SMITHING SYSTEM - ANVIL (E-Key + Verb)
**Location:** Any smithy with Anvil  
**Objects to Test:** /obj/Buildable/Smithing/Anvil

**Test Cases:**
- [ ] **Test 2.1:** Press E near anvil (target with mouse)
  - Expected: Smithing menu appears with tool/weapon options
  - Verify: Menu responsive, selection works
  
- [ ] **Test 2.2:** Right-click anvil (old verb method)
  - Expected: Verb menu appears
  - Verify: No regression, backwards compatible
  
- [ ] **Test 2.3:** E-key at different distances
  - Expected: Works at 1 tile, fails at 2+ tiles
  - Verify: Range check working (range(1) enforced)
  
- [ ] **Test 2.4:** Craft tool via E-key
  - Expected: Tool created, placed in inventory
  - Verify: No duplication, proper item creation

**Success Criteria:** E-key menu opens, range check works, no errors

---

### 3. SMITHING SYSTEM - FORGE (E-Key + Verb)
**Location:** Same smithy with Forge  
**Objects to Test:** /obj/Buildable/Smithing/Forge

**Test Cases:**
- [ ] **Test 3.1:** Press E near forge
  - Expected: Smithing menu appears (same as anvil)
  - Verify: Consistent behavior, responsive menu
  
- [ ] **Test 3.2:** Right-click forge (old verb)
  - Expected: Verb menu appears
  - Verify: No regression
  
- [ ] **Test 3.3:** E-key fuel/tool interactions
  - Expected: Can add fuel, create items
  - Verify: All options functional

**Success Criteria:** E-key opens menu, consistent with anvil behavior

---

### 4. GARDENING - SOIL DEPOSITS (E-Key + DblClick)
**Location:** Any garden area with soil/richsoil  
**Objects to Test:** /obj/Soil, /obj/Soil/richsoil, /obj/Soil/soil

**Test Cases:**
- [ ] **Test 4.1:** Press E on soil deposit (no sickle)
  - Expected: DblClick triggers, harvesting prompts for tool
  - Verify: Proper error message about sickle requirement
  
- [ ] **Test 4.2:** Equip sickle, press E on soil
  - Expected: Harvest begins, progress visible
  - Verify: Animation, XP award, item creation
  
- [ ] **Test 4.3:** Double-click soil (old method)
  - Expected: Same harvesting behavior
  - Verify: Both methods work identically
  
- [ ] **Test 4.4:** E-key soil quality variants
  - Expected: Richsoil yields more than normal soil
  - Verify: Yield modifiers working (FarmingIntegration.dm)

**Success Criteria:** E-key triggers harvesting, yields correct items

---

### 5. GARDENING - VEGETABLES (E-Key + DblClick)
**Location:** Grown vegetable plants in garden  
**Objects to Test:** /obj/Plants/Vegetables (Potato, Onion, Carrot, Tomato, Pumpkin)

**Test Cases:**
- [ ] **Test 5.1:** Press E on seedling (unripe plant)
  - Expected: Message "too young to pick" or similar
  - Verify: Rank/growth gating working
  
- [ ] **Test 5.2:** Press E on ripe vegetable plant (sickle equipped)
  - Expected: Harvesting begins
  - Verify: Item created, XP awarded, growth stage updated
  
- [ ] **Test 5.3:** Double-click vegetable plant (old method)
  - Expected: Same harvesting behavior
  - Verify: Both methods functional
  
- [ ] **Test 5.4:** Low rank vs high rank harvesting
  - Expected: Higher rank = better success rate
  - Verify: Rank requirement enforced (grank < greq)

**Success Criteria:** E-key harvests plants correctly, ranks enforced

---

### 6. GARDENING - GRAINS (E-Key + DblClick)
**Location:** Grown grain plants (Wheat, Barley)  
**Objects to Test:** /obj/Plants/Grain (Wheat, Barley)

**Test Cases:**
- [ ] **Test 6.1:** Press E on ripe grain (sickle equipped)
  - Expected: Harvesting begins, grain item created
  - Verify: Correct item type, proper quantity
  
- [ ] **Test 6.2:** Double-click grain (old method)
  - Expected: Same behavior as E-key
  - Verify: Both methods work
  
- [ ] **Test 6.3:** Harvest with low stamina
  - Expected: Stamina check performed
  - Verify: Proper feedback if stamina too low

**Success Criteria:** E-key harvests grains correctly

---

### 7. GARDENING - BUSHES (E-Key + DblClick)
**Location:** Raspberry or Blueberry bushes  
**Objects to Test:** /obj/Plants/Bush (Raspberrybush, Blueberrybush)

**Test Cases:**
- [ ] **Test 7.1:** Press E on fruit bush (ripe)
  - Expected: Harvesting begins, fruit item created
  - Verify: Correct fruit type (cluster vs individual)
  
- [ ] **Test 7.2:** Bush with shovel (dig up)
  - Expected: Can dig up entire bush
  - Verify: Bush removed, replantable
  
- [ ] **Test 7.3:** Double-click bush (old method)
  - Expected: Same harvesting behavior
  - Verify: Both methods functional

**Success Criteria:** E-key picks fruit correctly

---

## Regression Testing: Verb-Based Interaction

**Critical:** Ensure old methods still work with no degradation

### Cooking Verb Test
- [ ] Right-click oven → Verb menu appears → Recipe selection works

### Smithing Verb Test
- [ ] Right-click anvil → Verb menu appears → Crafting works
- [ ] Right-click forge → Verb menu appears → Crafting works

### Gardening Verb Test
- [ ] Double-click vegetable → Harvesting starts → Item created
- [ ] Double-click grain → Harvesting starts → Item created
- [ ] Double-click bush → Interaction works → Item created

---

## Performance Metrics to Check

- [ ] **E-Key Response Time:** <500ms from key press to menu/action
- [ ] **Menu Display:** No visual glitches, proper layout
- [ ] **Item Creation:** No duplication, correct quantities
- [ ] **XP Awards:** Silent (background), no spam
- [ ] **Range Checking:** Enforced at 1 tile, proper messages
- [ ] **Error Handling:** Graceful failures, helpful messages

---

## Bug Detection Checklist

Watch for:
- [ ] **Double Triggers:** E-key firing twice on single press
- [ ] **Menu Freezing:** Menu unresponsive or stuck
- [ ] **Item Loss:** Items created but not in inventory
- [ ] **XP Bugs:** Not awarded or wrong amounts
- [ ] **Range Bypass:** Harvesting from >1 tile away
- [ ] **Verb Conflicts:** Old verbs conflicting with E-key
- [ ] **Animation Issues:** Visual glitches or clipping
- [ ] **Stamina Loss:** Stamina drained when shouldn't be

---

## Success Criteria Summary

✅ **All 7 system categories pass their tests**  
✅ **All 4 regression tests pass**  
✅ **No new bugs introduced**  
✅ **Performance metrics acceptable**  
✅ **Verb interaction not degraded**

---

## If Issues Found

Document as follows:
```
BUG: [System] - [Description]
- Reproduction steps:
- Expected: 
- Actual:
- Severity: [Critical/High/Medium/Low]
- Notes:
```

Then either:
1. **Quick fix:** Fix if simple (typo, range check, etc.)
2. **Defer:** Document and defer to detailed investigation session

---

## Test Results Summary Template

| System | Test 1 | Test 2 | Test 3 | Test 4 | Status |
|--------|--------|--------|--------|--------|--------|
| Cooking | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | PASS/FAIL |
| Smithing (Anvil) | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | PASS/FAIL |
| Smithing (Forge) | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | PASS/FAIL |
| Soil | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | PASS/FAIL |
| Vegetables | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | PASS/FAIL |
| Grains | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | PASS/FAIL |
| Bushes | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ | PASS/FAIL |

---

**Note:** This is a comprehensive testing plan. Execute tests methodically and document results. If all tests pass with no bugs, Option 1 is complete and verified!
