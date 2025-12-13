# Anvil Recipe Integration Guide

## Overview
This guide explains how to integrate the 26+ legacy anvil smithing recipes into the modern experimentation system through the RECIPES registry and RecipeExperimentationSystem.

**Status**: Documentation phase - Ready for implementation
**Integration Point**: RecipeExperimentationSystem.dm + RECIPES registry
**Workstation**: /obj/Buildable/Smithing/Anvil (ExperimentationWorkstations.dm)

---

## Recipe Registry Format

All anvil smithing recipes follow this structure in the RECIPES registry:

```dm
RECIPES["unique_recipe_key"] = [
    "name" = "Display Name",
    "type" = /obj/items/path/to/output,
    "inputs" = list("ingredient_name" = quantity, ...),
    "output" = output_quantity,
    "skill_requirement" = RANK_SMITHING,
    "skill_level_min" = 1,  // Minimum smithing rank (1-5)
    "workstation_type" = "smithing",  // Must be "smithing" for anvil
    "refinement_stage" = "filed",     // Optional: progression stage
    "quality_modifier" = 0.10,        // Quality multiplier (0.1-0.3)
    "experience_reward" = 50          // XP on successful discovery
]
```

---

## Tool Component Refinement Recipes

### 1. Hammer Head Refinement Series

#### Recipe: hammer_head_refine_filed
```dm
RECIPES["hammer_head_refine_filed"] = [
    "name" = "File Hammer Head",
    "type" = /obj/items/Crafting/Created/HammerHead,
    "inputs" = list("hammer_head_unrefined" = 1, "water" = 1),
    "output" = 1,
    "skill_requirement" = RANK_SMITHING,
    "skill_level_min" = 1,
    "workstation_type" = "smithing",
    "refinement_stage" = "filed",
    "quality_modifier" = 0.10,
    "experience_reward" = 25
]
```

#### Recipe: hammer_head_refine_sharpened
```dm
RECIPES["hammer_head_refine_sharpened"] = [
    "name" = "Sharpen Hammer Head",
    "type" = /obj/items/Crafting/Created/HammerHead,
    "inputs" = list("hammer_head_filed" = 1, "whetstome" = 1),
    "output" = 1,
    "skill_requirement" = RANK_SMITHING,
    "skill_level_min" = 2,
    "workstation_type" = "smithing",
    "refinement_stage" = "sharpened",
    "quality_modifier" = 0.15,
    "experience_reward" = 30
]
```

#### Recipe: hammer_head_quench
```dm
RECIPES["hammer_head_quench"] = [
    "name" = "Quench Hammer Head",
    "type" = /obj/items/Crafting/Created/HammerHead,
    "inputs" = list("hammer_head_sharpened" = 1, "water" = 2),
    "output" = 1,
    "skill_requirement" = RANK_SMITHING,
    "skill_level_min" = 1,
    "workstation_type" = "smithing",
    "refinement_stage" = "cool",
    "quality_modifier" = 0.20,
    "experience_reward" = 40
]
```

### 2. Carving Knife Blade Refinement Series

```dm
RECIPES["ck_blade_refine_filed"] = [
    "name" = "File Carving Knife Blade",
    "type" = /obj/items/Crafting/Created/CKnifeblade,
    "inputs" = list("ck_blade_unrefined" = 1, "water" = 1),
    "output" = 1,
    "skill_requirement" = RANK_SMITHING,
    "skill_level_min" = 1,
    "workstation_type" = "smithing",
    "refinement_stage" = "filed",
    "quality_modifier" = 0.12,
    "experience_reward" = 28
]

RECIPES["ck_blade_quench"] = [
    "name" = "Quench Carving Knife Blade",
    "type" = /obj/items/Crafting/Created/CKnifeblade,
    "inputs" = list("ck_blade_filed" = 1, "water" = 2),
    "output" = 1,
    "skill_requirement" = RANK_SMITHING,
    "skill_level_min" = 1,
    "workstation_type" = "smithing",
    "refinement_stage" = "cool",
    "quality_modifier" = 0.18,
    "experience_reward" = 35
]
```

### 3-11. Other Tool Components

Follow the same pattern for:
- **File Blade**: file_blade_refine_*, file_blade_quench
- **Axe Blade**: axe_blade_refine_*, axe_blade_quench
- **Pickaxe Head**: pickaxe_head_refine_*, pickaxe_head_quench
- **Shovel Blade**: shovel_blade_refine_*, shovel_blade_quench
- **Hoe Blade**: hoe_blade_refine_*, hoe_blade_quench
- **Saw Blade**: saw_blade_refine_*, saw_blade_quench
- **Sickle Blade**: sickle_blade_refine_*, sickle_blade_quench
- **Chisel Blade**: chisel_blade_refine_*, chisel_blade_quench
- **Trowel Blade**: trowel_blade_refine_*, trowel_blade_quench

---

## Weapon Component Refinement Recipes

### 1. Broad Sword Blade

```dm
RECIPES["broad_sword_blade_refine_filed"] = [
    "name" = "File Broad Sword Blade",
    "type" = /obj/items/Crafting/Created/Broadswordblade,
    "inputs" = list("broad_sword_blade" = 1, "water" = 1),
    "output" = 1,
    "skill_requirement" = RANK_SMITHING,
    "skill_level_min" = 1,
    "workstation_type" = "smithing",
    "refinement_stage" = "filed",
    "quality_modifier" = 0.12,
    "experience_reward" = 35
]

RECIPES["broad_sword_blade_refine_sharpened"] = [
    "name" = "Sharpen Broad Sword Blade",
    "type" = /obj/items/Crafting/Created/Broadswordblade,
    "inputs" = list("broad_sword_blade_filed" = 1, "whetstone" = 1),
    "output" = 1,
    "skill_requirement" = RANK_SMITHING,
    "skill_level_min" = 2,
    "workstation_type" = "smithing",
    "refinement_stage" = "sharpened",
    "quality_modifier" = 0.18,
    "experience_reward" = 45
]

RECIPES["broad_sword_blade_quench"] = [
    "name" = "Quench Broad Sword Blade",
    "type" = /obj/items/Crafting/Created/Broadswordblade,
    "inputs" = list("broad_sword_blade_sharpened" = 1, "water" = 2),
    "output" = 1,
    "skill_requirement" = RANK_SMITHING,
    "skill_level_min" = 1,
    "workstation_type" = "smithing",
    "refinement_stage" = "cool",
    "quality_modifier" = 0.25,
    "experience_reward" = 60
]
```

### 2-10. Other Weapon Components

Follow the same pattern for:
- **War Sword Blade**: war_sword_blade_refine_*
- **Battle Sword Blade**: battle_sword_blade_refine_*
- **Long Sword Blade**: long_sword_blade_refine_*
- **War Maul Head**: war_maul_head_refine_*
- **Battle Hammer Sledge**: battle_hammer_sledge_refine_*
- **War Axe Blade**: war_axe_blade_refine_*
- **Battle Axe Blade**: battle_axe_blade_refine_*
- **War Scythe Blade**: war_scythe_blade_refine_*
- **Battle Scythe Blade**: battle_scythe_blade_refine_*

---

## Lamp Component Refinement Recipes

### Pattern: [Material]_lamp_head_refine_* (5 types)

```dm
RECIPES["iron_lamp_head_refine_filed"] = [
    "name" = "File Iron Lamp Head",
    "type" = /obj/items/Crafting/Created/IronLampHead,
    "inputs" = list("iron_lamp_head" = 1, "water" = 1),
    "output" = 1,
    "skill_requirement" = RANK_SMITHING,
    "skill_level_min" = 1,
    "workstation_type" = "smithing",
    "refinement_stage" = "filed",
    "quality_modifier" = 0.10,
    "experience_reward" = 20
]

// Repeat for: copper_lamp_head, bronze_lamp_head, brass_lamp_head, steel_lamp_head
```

---

## Ingredient & Material Requirements

### Standard Refinement Inputs

| Input Type | Type | Notes |
|-----------|------|-------|
| **water** | consumable | 1-2 units per quench |
| **whetstone** | tool | Sharpening stone |
| **flux** | consumable | Metalworking flux |
| **oil** | consumable | Alternative quench medium (legacy support) |
| **tar** | consumable | Alternative quench medium (legacy support) |

### Component Input Names

Map legacy item types to recipe input names:

```dm
// Tool components
"hammer_head" = /obj/items/Crafting/Created/HammerHead
"ck_blade" = /obj/items/Crafting/Created/CKnifeblade
"file_blade" = /obj/items/Crafting/Created/FileBlade
"axe_blade" = /obj/items/Crafting/Created/AxeHead
"pickaxe_head" = /obj/items/Crafting/Created/PickaxeHead
"shovel_blade" = /obj/items/Crafting/Created/ShovelHead
"hoe_blade" = /obj/items/Crafting/Created/HoeBlade
"saw_blade" = /obj/items/Crafting/Created/SawBlade
"sickle_blade" = /obj/items/Crafting/Created/SickleBlade
"chisel_blade" = /obj/items/Crafting/Created/ChiselBlade
"trowel_blade" = /obj/items/Crafting/Created/TrowelBlade

// Weapon components
"broad_sword_blade" = /obj/items/Crafting/Created/Broadswordblade
"war_sword_blade" = /obj/items/Crafting/Created/Warswordblade
// ... etc for other weapons
```

---

## Implementation Priority

### Phase 1: Core Tool Refinement (MVP)
Implement these 3 recipes first:
1. `hammer_head_refine_filed` - Basic smithing intro
2. `hammer_head_refine_sharpened` - Mid-tier refinement
3. `hammer_head_quench` - Complete refinement cycle

### Phase 2: Full Tool Set
Add remaining 8 tool components (same 3-recipe pattern each)

### Phase 3: Weapons & Lamps
Add weapon (10 types) and lamp (5 types) refinement recipes

### Phase 4: Advanced Refinement
- Multi-stage experimentation: discover each stage separately
- Quality improvements from multiple attempts
- Bonus unlocks for perfect refinements (no ingredient waste)

---

## Integration Steps

### Step 1: Add Recipes to RECIPES Registry
**File**: RecipeExperimentationSystem.dm or separate smithing_recipes.dm
```dm
// Define RECIPES["hammer_head_refine_filed"] etc.
// Follow format above
```

### Step 2: Map Ingredients in ValidateIngredientCombination()
**File**: RecipeExperimentationSystem.dm
```dm
proc/ValidateIngredientCombination(recipe_key, player_ingredients)
    var/recipe = RECIPES[recipe_key]
    if(!recipe) return FALSE
    
    // Check if player has required ingredients
    for(var/ingredient in recipe["inputs"])
        var/required_amount = recipe["inputs"][ingredient]
        var/player_amount = player_ingredients[ingredient] || 0
        if(player_amount < required_amount)
            return FALSE
    
    return TRUE
```

### Step 3: Filter Recipes by Workstation Type
**File**: ExperimentationUI.dm GetAvailableRecipes()
```dm
proc/GetAvailableRecipes(mob/players/player, workstation_type)
    var/list/available = list()
    
    for(var/recipe_key in RECIPES)
        var/recipe = RECIPES[recipe_key]
        if(recipe["workstation_type"] != workstation_type)
            continue
        
        // Check skill level
        if(player.GetRankLevel(recipe["skill_requirement"]) < recipe["skill_level_min"])
            continue
        
        available[recipe_key] = recipe["name"]
    
    return available
```

### Step 4: Anvil Durability Integration
**File**: ExperimentationWorkstations.dm Anvil/HammerMetal()
```dm
proc/HammerMetal(mob/players/smith, obj/item/ingot)
    // Decrease durability per successful hammer strike
    if(durability > 0)
        durability--
    
    // When durability reaches 0, anvil needs repair/replacement
    if(durability <= 0)
        smith << "The anvil has worn out from use..."
        // Trigger anvil degradation or destruction
```

---

## Expected Outcomes

### Progression Experience
- Player discovers hammer head recipes through experimentation
- Progressive refinement (filed → sharpened → cool) unlocks at different skill levels
- Encourages multiple attempts to discover optimal ingredient combinations
- Quality varies based on ingredient selection and attempt count

### Gameplay Loop
1. Player mines ore or finds metal ingots
2. Smelts ore at Forge to create unrefined components
3. Takes components to Anvil for refinement
4. Experiments with water/oil/tar quenching
5. Discovers refinement techniques through trial
6. Collects refined parts for tool assembly
7. Increases smithing rank, unlocks higher-tier components

### Skill Development
- Smithing rank 1: Basic tool components (hammer head, blades)
- Smithing rank 2: Sharpening and refinement techniques
- Smithing rank 3: Weapon component refinement
- Smithing rank 4: Advanced alloy work
- Smithing rank 5: Mastery recipes (legendary components)

---

## Future Enhancements

### Multi-Input Experimentation
Support recipes with multiple ingredient choices:
```dm
RECIPES["hammer_head_quench"] = [
    "inputs" = list(
        "hammer_head_sharpened" = 1,
        "coolant" = list("water" = 2, "oil" = 1, "tar" = 1)  // Choose one
    )
    // Each coolant type produces different quality/properties
]
```

### Sequential Quenching
Chain multiple quench recipes for deeper refinement:
```dm
RECIPES["hammer_head_premium_quench"] = [
    "inputs" = list(
        "hammer_head_water_quenched" = 1,  // Output from previous recipe
        "oil" = 1
    ),
    "output" = 1,
    // Results in superior quality hammer head
]
```

### Anvil Repair Recipes
Replace worn anvils or restore durability:
```dm
RECIPES["repair_anvil"] = [
    "inputs" = list("anvil_head" = 1, "logs" = 2, "mortar" = 5),
    "output" = 1,
    // Restores durability to 100
]
```

---

## Recipe Validation Checklist

- [ ] All 26 recipes added to RECIPES registry
- [ ] Ingredient mappings correct in ValidateIngredientCombination()
- [ ] Skill level requirements follow progression (1-5)
- [ ] Quality modifiers reflect refinement complexity
- [ ] Experience rewards scale with difficulty
- [ ] Workstation type set to "smithing" for all anvil recipes
- [ ] Refinement stages documented (filed/sharpened/cool)
- [ ] Legacy item types match current codebase paths
- [ ] Build verification passes with no errors
- [ ] In-game testing: recipes appear in experimentation UI
- [ ] UI properly filters recipes by workstation type
- [ ] Ingredient validation works correctly
- [ ] Experience gain and quality modifier applied on success

---

## References

- **Legacy Code**: `jblegacyexample.dm` (lines 1949-2024)
- **Tool Legacy**: `toolslegacyexample.dm` (lines 3735-5399)
- **System Architecture**: ANVIL_LEGACY_RECIPE_CATALOG.md
- **Current Implementation**: ExperimentationWorkstations.dm, ExperimentationUI.dm, RecipeExperimentationSystem.dm
