# Smithing Phase 2: Detailed Implementation Plan with Recipe Book Integration

**Phase Status:** Deferred from Phase 1-2  
**Timeline:** 9-12 hours (dedicated session)  
**Recipe Source:** Pondera Recipe Book.txt + Objects.dm (lines 5120-8400+)  
**Target:** Production-ready modern smithing system

---

## Overview

Pondera's smithing system is currently embedded in a 3,765+ line verb with hardcoded recipes across nested switch statements. Phase 2 will:

1. Extract all 65+ recipes into a unified SMITHING_RECIPES registry
2. Replace nested input() calls with clean, modular menu system
3. Create generic crafting handler for all item types
4. Integrate with E-key macro support
5. Full backwards compatibility maintenance
6. Comprehensive testing and documentation

**Result:** Modern, maintainable, extensible smithing system

---

## Recipe Inventory (From Recipe Book)

### Total Recipes: 65+

**Smelting (8 recipes):**
- Iron Ingot: 3 Iron Ore
- Lead Ingot: 3 Lead Ore
- Zinc Ingot: 2 Zinc Ore
- Copper Ingot: 2 Copper Ore
- Bronze Ingot: 1 Copper + 1 Lead
- Brass Ingot: 1 Copper + 1 Zinc
- Steel Ingot: 5 Iron + 3 Activated Carbon
- Iron Anvil Head: 15 Iron Ingot

**Misc (2 recipes):**
- Iron Nails: 1 Iron Ingot
- Iron Ribbon: 2 Iron Ingot

**Tools (11 recipes):**
- Carving Knife blade: 1 Iron Ingot
- Hammer Head: 1 Iron Ingot
- File Blade: 1 Iron Ingot
- Axe Head: 2 Iron Ingot
- Pickaxe Head: 3 Iron Ingot
- Shovel Head: 3 Iron Ingot
- Hoe blade: 2 Iron Ingot
- Sickle Blade: 2 Iron Ingot
- Saw Blade: 2 Iron Ingot
- Chisel Blade: 2 Iron Ingot
- Trowel Blade: 3 Steel Ingot

**Weapons (9 recipes):**
- All require 3 Iron Ingot (base)
- Broad Sword, War Sword, Battle Sword
- War Maul, Battle Hammer, War Axe, Battle Axe
- War Scythe, Battle Scythe

**Armor - Evasive (18 recipes):**
- 6 main types + variants
- Mix of copper/bronze/zinc/steel ingots
- Various creature part combinations

**Armor - Defensive (6 recipes):**
- CopperPlate, IronPlate, Iron HalfPlate
- Bronze SolidPlate, Boreal ZincPlate, Aurelian SteelPlate
- Require 3-7 ingots + creature parts

**Armor - Offensive (6 recipes):**
- IronPlate, CopperPlate, BronzePlate
- Omphalos variants, ZincPlate, SteelPlate
- Require 3-5 ingots + creature parts

**Lamps (5 recipes):**
- Iron, Copper, Bronze, Brass, Steel Lamp Heads
- 4 ingots each

**Containers (2 recipes):**
- Quench Box: 3 Ueik Board + 2 Iron Ribbon + 2 Ueik Shingle
- Barrel: 18 Cask Board + 10 Iron Ribbon

---

## Implementation Timeline (9-12 hours)

### Hour 1-2: Recipe Registry Extraction (2 hours)

**Task:** Create SMITHING_RECIPES dictionary with all 65 recipes

```dm
var/global/list/SMITHING_RECIPES = list()

proc/InitializeSmithingRecipes()
    // MISC ITEMS
    SMITHING_RECIPES["iron nails"] = list(
        "name" = "Iron Nails",
        "category" = "misc",
        "ingredients" = list("iron ingot" = 1),
        "output" = /obj/items/Crafting/Created/IronNails,
        "xp_reward" = 15,
        "required_rank" = 1,
        "success_rate" = 80,
        "description" = "Basic iron nails for construction"
    )
    
    SMITHING_RECIPES["iron ribbon"] = list(
        "name" = "Iron Ribbon",
        "category" = "misc",
        "ingredients" = list("iron ingot" = 2),
        "output" = /obj/items/Crafting/Created/IronRibbon,
        "xp_reward" = 20,
        "required_rank" = 1,
        "success_rate" = 75,
        "description" = "Reinforced iron ribbon for decoration"
    )
    
    // TOOLS
    SMITHING_RECIPES["carving knife blade"] = list(
        "name" = "Carving Knife blade",
        "category" = "tools",
        "ingredients" = list("iron ingot" = 1),
        "output" = /obj/items/Crafting/Created/CarvingKnifeblade,
        "xp_reward" = 15,
        "required_rank" = 1,
        "success_rate" = 80
    )
    
    // ... repeat for all 65 recipes
    
    return TRUE
```

**Deliverables:**
- dm/SmithingRecipes.dm (new file, ~400-500 lines)
- All 65 recipes defined with consistent format
- Ingredient lists matching Recipe Book
- XP rewards based on complexity
- Output types matching existing items
- Success rate multipliers (quality-based)

**Quality Checks:**
- [ ] All recipes from Recipe Book included
- [ ] Ingredient types match existing items
- [ ] Output types exist in codebase
- [ ] XP rewards scale with difficulty
- [ ] Category tags consistent (misc/tools/weapons/armor/lamps)

---

### Hour 3-4: Menu System Refactoring (2 hours)

**Task:** Replace nested input() calls with modular menu procs

```dm
proc/DisplaySmithingMenu(mob/players/M)
    var/rank = M.GetRankLevel(RANK_SMITHING)
    var/list/categories = GetAvailableCategories(M, rank)
    
    var/choice = input("What would you like to smith?", "Smithing") in categories
    
    if(choice == "Cancel" || choice == "Back")
        return
    
    DisplayCategoryMenu(M, choice, rank)

proc/GetAvailableCategories(mob/players/M, rank)
    var/list/cats = list("Cancel", "Back")
    
    if(rank >= 1) cats += "Tools"
    if(rank >= 1) cats += "Misc"
    if(rank >= 7) cats += "Weapons"
    if(rank >= 8) cats += "Armor"
    if(rank >= 10) cats += "Lamps"
    
    return cats

proc/DisplayCategoryMenu(mob/players/M, category, rank)
    var/list/items = GetCategoryItems(category, rank)
    
    var/choice = input("Select item to craft:", category) in items
    
    if(choice == "Cancel" || choice == "Back")
        return
    
    AttemptCraft(M, choice)

proc/GetCategoryItems(category, rank)
    var/list/items = list("Cancel", "Back")
    
    for(var/recipe_name in SMITHING_RECIPES)
        var/recipe = SMITHING_RECIPES[recipe_name]
        
        if(recipe["category"] == category && recipe["required_rank"] <= rank)
            items += recipe["name"]
    
    return items
```

**Deliverables:**
- dm/SmithingMenuSystem.dm (new file, ~200-250 lines)
- Clean proc-based menus
- Rank-gated item availability
- Remove all hardcoded lists
- Replace lines 10600-11000 of Objects.dm

**Quality Checks:**
- [ ] All rank gates functional (1-11)
- [ ] All categories available at correct ranks
- [ ] Menu flows correctly (no loops/errors)
- [ ] Back/Cancel always work
- [ ] Selection leads to crafting

---

### Hour 5-6: Crafting Handler Implementation (2 hours)

**Task:** Create generic handler for all recipes

```dm
proc/AttemptCraft(mob/players/M, recipe_name)
    // Validate recipe
    if(!(recipe_name in SMITHING_RECIPES))
        M << "Recipe not found!"
        return
    
    var/recipe = SMITHING_RECIPES[recipe_name]
    var/rank = M.GetRankLevel(RANK_SMITHING)
    
    // Check rank
    if(rank < recipe["required_rank"])
        M << "You're not skilled enough for this recipe!"
        return
    
    // Check ingredients
    var/list/found = CheckIngredients(M, recipe["ingredients"])
    if(!found)
        M << "You don't have the required ingredients!"
        ShowIngredientRequirements(M, recipe)
        return
    
    // Check stamina
    if(M.stamina < 10)
        M << "You're too tired to smith!"
        return
    
    // Start crafting
    M << "You begin to smith [recipe['name']]..."
    M.Doing = 1
    M.UEB = 1
    
    // Remove ingredients
    RemoveIngredients(M, recipe["ingredients"])
    M.stamina -= 10
    M.updateST()
    
    // Delay for crafting (3 seconds)
    sleep(30)
    
    // Calculate success
    var/success_roll = rand(1, 100)
    var/success_chance = recipe["success_rate"] + (rank * 5)
    var/success = success_roll <= success_chance
    
    if(success)
        // Create item
        new recipe["output"](M.loc)
        
        // Award XP
        M.character.UpdateRankExp(RANK_SMITHING, recipe["xp_reward"])
        
        M << "<font color='green'>You successfully crafted [recipe['name']]!</font>"
    else
        M << "<font color='red'>You failed to craft [recipe['name']].</font>"
    
    // Cleanup
    M.Doing = 0
    M.UEB = 0
    M.SMIopen = 0

proc/CheckIngredients(mob/players/M, list/required)
    var/list/found = list()
    
    for(var/ingredient in required)
        var/amount = required[ingredient]
        var/found_amount = 0
        
        for(var/obj/item in M.contents)
            if(item.name == ingredient && found_amount < amount)
                found += item
                found_amount++
        
        if(found_amount < amount)
            return null
    
    return found

proc/RemoveIngredients(mob/players/M, list/required)
    for(var/ingredient in required)
        var/amount = required[ingredient]
        
        for(var/obj/item in M.contents)
            if(item.name == ingredient && amount > 0)
                if(item.can_stack && item.stack_amount > 0)
                    item.RemoveFromStack(1)
                    amount--
                else
                    del item
                    amount--

proc/ShowIngredientRequirements(mob/players/M, recipe)
    var/msg = "To craft [recipe['name']] you need:\n"
    
    for(var/ingredient in recipe["ingredients"])
        var/amount = recipe["ingredients"][ingredient]
        msg += "- [amount]x [ingredient]\n"
    
    M << msg
```

**Deliverables:**
- dm/SmithingCraftingHandler.dm (new file, ~300-350 lines)
- AttemptCraft() - main entry point
- CheckIngredients() - inventory validation
- RemoveIngredients() - consumption logic
- ShowIngredientRequirements() - feedback
- Success rate calculations

**Quality Checks:**
- [ ] All checks functional (rank, ingredients, stamina)
- [ ] Success rate scales with rank
- [ ] XP awards correct amounts
- [ ] Items created in correct location
- [ ] Stamina reduced appropriately
- [ ] Inventory updated properly

---

### Hour 7-8: Anvil/Forge E-Key Integration (2 hours)

**Task:** Update SmithingModernE-Key.dm to use new system

Currently, dm/SmithingModernE-Key.dm has basic E-key handlers. Update to:

```dm
obj/Buildable/Smithing/Anvil
    UseObject(mob/user)
        if(user in range(1, src))
            set waitfor = 0
            DisplaySmithingMenu(user)  // New menu system
            return 1
        return 0

obj/Buildable/Smithing/Forge
    UseObject(mob/user)
        if(user in range(1, src))
            set waitfor = 0
            DisplaySmithingMenu(user)  // New menu system
            return 1
        return 0
```

**Deliverables:**
- Updated SmithingModernE-Key.dm (~10-15 lines)
- E-key calls modern menu system
- Works with Anvil and Forge
- Maintains verb menu compatibility

**Quality Checks:**
- [ ] E-key triggers menu
- [ ] Verb menu still works
- [ ] Both structures respond
- [ ] Range checking enforced

---

### Hour 9-10: Testing & Validation (2 hours)

**Task:** Comprehensive testing of all 65 recipes

**Test Categories:**

1. **Rank Gating (30 mins)**
   - [ ] Rank 1 player can craft Tier 1 only
   - [ ] Rank 5 player can craft Tier 1-3
   - [ ] Rank 11 player can craft all
   - [ ] Message shown for insufficient rank

2. **Recipe Testing (45 mins)**
   - [ ] Each of 65 recipes crafts successfully
   - [ ] Correct item created
   - [ ] Correct ingredients consumed
   - [ ] Correct XP awarded
   - [ ] Success rate ~80% at max rank

3. **Edge Cases (30 mins)**
   - [ ] Insufficient ingredients handled
   - [ ] Insufficient stamina handled
   - [ ] Zero stamina prevents crafting
   - [ ] Success/failure properly displayed
   - [ ] Menu flows correctly

4. **Build Verification (15 mins)**
   - [ ] 0 compilation errors
   - [ ] No performance degradation
   - [ ] Old verb still works (backwards compat)
   - [ ] E-key macros functional

**Deliverables:**
- SMITHING_PHASE2_TEST_RESULTS.md (detailed results)
- Bug report template for any issues
- Performance metrics
- Compatibility verification

---

### Hour 11-12: Documentation & Cleanup (1-2 hours)

**Task:** Complete documentation and final integration

**Deliverables:**
- SMITHING_PHASE2_IMPLEMENTATION.md (full guide)
- Code comments in all new files
- Integration guide for future expansions
- Recipe database documentation
- Success rate formula documentation
- Rank gating explanation

**Files Created:**
1. dm/SmithingRecipes.dm (~400-500 lines)
2. dm/SmithingMenuSystem.dm (~200-250 lines)
3. dm/SmithingCraftingHandler.dm (~300-350 lines)
4. Updated dm/SmithingModernE-Key.dm (~15 lines)

**Files to Migrate/Remove:**
- Migrate anvil/forge/misc crafting code from Objects.dm (lines ~5120-8400)
- Keep structure definitions, remove crafting logic
- Update Pondera.dme includes to load new files

---

## Architecture Overview

```
Before Phase 2:
Objects.dm (3765+ line Smithing verb)
    ├─ Rank 1-11 switch
    │   ├─ Category switch (Tools/Weapons/Armor/Lamps)
    │   │   ├─ Item choice
    │   │   │   ├─ Ingredient check
    │   │   │   ├─ Item creation
    │   │   │   ├─ XP award
    │   │   │   └─ Cleanup
    │   │   └─ (Repeat 65+ times)
    │   └─ (Repeat for each rank)
    └─ Nested input() calls throughout

After Phase 2:
SmithingRecipes.dm (Registry)
    └─ SMITHING_RECIPES["name"] = list(...)

SmithingMenuSystem.dm (UI)
    ├─ DisplaySmithingMenu(M)
    ├─ GetAvailableCategories(M, rank)
    ├─ DisplayCategoryMenu(M, category, rank)
    └─ GetCategoryItems(category, rank)

SmithingCraftingHandler.dm (Logic)
    ├─ AttemptCraft(M, recipe)
    ├─ CheckIngredients(M, list)
    ├─ RemoveIngredients(M, list)
    └─ ShowIngredientRequirements(M, recipe)

SmithingModernE-Key.dm (Access)
    ├─ Anvil/UseObject() → DisplaySmithingMenu()
    └─ Forge/UseObject() → DisplaySmithingMenu()
```

---

## Integration Checklist

### Pre-Implementation
- [x] Recipe Book documented (65 recipes)
- [x] Current code analyzed (3765+ lines)
- [x] Architecture designed
- [x] Timeline estimated (9-12 hours)

### Implementation Phase
- [ ] SmithingRecipes.dm created + tested
- [ ] SmithingMenuSystem.dm created + tested
- [ ] SmithingCraftingHandler.dm created + tested
- [ ] SmithingModernE-Key.dm updated
- [ ] All 65 recipes verified working
- [ ] Build compiles CLEAN (0 errors)

### Testing Phase
- [ ] Rank gating tests (4 ranks: 1, 5, 8, 11)
- [ ] Recipe tests (65 items)
- [ ] Edge case tests (stamina, ingredients)
- [ ] Performance tests (no lag)
- [ ] Backwards compatibility tests (verb still works)

### Documentation Phase
- [ ] Code comments complete
- [ ] Integration guide written
- [ ] Future expansion roadmap
- [ ] Test results documented
- [ ] Commit message prepared

### Final Integration
- [ ] Pondera.dme updated (includes new files)
- [ ] Objects.dm cleaned up (remove crafting logic)
- [ ] All files compile CLEAN
- [ ] Git commit created with detailed message
- [ ] Session complete

---

## Success Metrics

✅ **All 65 recipes** extracted and functional  
✅ **3765 lines** reduced to ~1000 lines modular code  
✅ **0 new compilation errors**  
✅ **100% backwards compatibility** (verb still works)  
✅ **E-key support** integrated  
✅ **Rank gating** maintained for all recipes  
✅ **XP awards** consistent with original  
✅ **Success rates** properly calculated  
✅ **Comprehensive documentation** provided  

---

## Next Steps After Phase 2

### Immediate (After Testing Passes)
1. Verify all 65 recipes working
2. Run comprehensive regression tests
3. Document any issues found
4. Create final session summary

### Future Enhancements (Phase 3+)
1. **Recipe UI Improvement:** Modern recipe browser
2. **Quality System:** Crafting quality affects item stats
3. **Material Variants:** Different ingot types affect output
4. **Skill Bonuses:** Higher rank = better items
5. **Failure Handling:** Scrap/partial items on failure
6. **NPC Trading:** Buy/sell recipes from NPCs
7. **Recipe Discovery:** Learn recipes from NPC teachers

---

## Deferred Work Notes

**Why Phase 2 was deferred:**
- Requires deep understanding of existing code
- 3,765+ line verb needs careful refactoring
- 65+ recipes need validation
- Significant testing required
- Better as dedicated 9-12 hour session

**Why it's ready now:**
- Phase 1-2 E-key foundation complete
- Recipe Book fully documented
- Architecture clearly designed
- Timeline and scope defined
- No blocking dependencies

---

**Status: READY FOR DEDICATED SESSION** ✅  
**Timeline: 9-12 hours continuous work**  
**Expected Result: Production-ready modern smithing system**
