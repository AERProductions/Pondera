# PLANT SEASONAL INTEGRATION - IMPLEMENTATION GUIDE

**Build Status**: ✅ **0 errors, 3 warnings**  
**Date**: 12/7/25 11:06 PM  
**File**: PlantSeasonalIntegration.dm (290 lines)

---

## OVERVIEW

The PlantSeasonalIntegration.dm system connects plant growth cycles to the ConsumptionManager, making crops:
- Only grow in their appropriate seasons
- Yield quality based on season and player skill
- Provide meaningful feedback about harvest quality
- Integrate seamlessly with existing plant.dm code

---

## KEY FUNCTIONS

### Core Integration Functions

#### GetPlantConsumableName(plant_obj)
Maps plant objects to ConsumptionManager food names
```dm
// Returns lowercase consumable name
var/consumable = GetPlantConsumableName(potato_plant)
// Returns: "potato"
```

**How it works:**
- Checks plant type (Vegetables, Bush, Grain)
- Reads VegeType, FruitType, or GrainType variable
- Returns lowercase version for ConsumptionManager lookup

---

#### ApplySeasonalGrowthModifier(plant_obj)
Checks if plant is in-season and stops out-of-season growth
```dm
var/can_grow = ApplySeasonalGrowthModifier(plant)
if (!can_grow)
    // Plant is out of season, growth halted
    // vgrowstate/bgrowstate/ggrowstate set to 8
```

**What it does:**
1. Gets plant's consumable name
2. Checks IsSeasonForCrop()
3. If out-of-season: sets growth state to 8 (out of season)
4. Returns 1 (in-season) or 0 (out-of-season)

**Integration point in plant.dm:**
```dm
// In Grow() proc, at start
if (!ApplySeasonalGrowthModifier(src))
    return  // Stop growth, plant is out of season
```

---

#### GetPlantHarvestYield(plant_obj, harvest_skill)
Calculates yield multiplier based on season and skill
```dm
var/yield_mult = GetPlantHarvestYield(potato_plant, 5)
// Returns: 0.7-1.4× depending on season and skill
```

**Example values:**
- In-season, skill 1: 1.3 × 0.5 = 0.65× yield
- In-season, skill 10: 1.3 × 1.4 = 1.82× yield
- Out-season, skill 10: 0.7 × 1.4 = 0.98× yield

---

#### ApplyHarvestYieldBonus(plant_obj, base_amount, harvest_skill)
Applies quality/skill multiplier to harvest amount
```dm
var/final_harvest = ApplyHarvestYieldBonus(potato_plant, 5, player_hrank)
// If normally yields 5, in-season skill 10 = 9-10 potatoes
```

**This is the main function to use in harvesting code!**

---

### Harvest Info Functions

#### GetVegetableHarvestInfo()
Returns complete harvest data for vegetables
```dm
var/list/info = GetVegetableHarvestInfo()
// Returns:
//   "amount" = base VegeAmount
//   "multiplied_amount" = with season/skill bonus
//   "quality" = 0.5-1.2+ quality multiplier
//   "in_season" = 1 (yes) or 0 (no)
//   "message" = player feedback text
```

#### GetFruitHarvestInfo()
Returns complete harvest data for berries
```dm
var/list/info = GetFruitHarvestInfo()
// Same structure as vegetables
```

#### GetGrainHarvestInfo()
Returns complete harvest data for grains
```dm
var/list/info = GetGrainHarvestInfo()
// Same structure as vegetables
```

---

### Seasonal Check Functions

#### CheckSeasonalGrowth() (Vegetables & Grain)
Call from plant object's Grow() proc
```dm
// In /obj/Plants/Vegetables or /obj/Plants/Grain
var/can_grow = src.CheckSeasonalGrowth()
if (!can_grow)
    return  // Out of season
```

#### CheckSeasonalFruiting() (Berries)
Call from berry bush's growth cycle
```dm
// In /obj/Plants/Bush
var/can_fruit = src.CheckSeasonalFruiting()
if (!can_fruit)
    return  // Out of season, no fruiting
```

---

### Feedback Functions

#### GetPlantHarvestMessage(plant_obj, is_in_season)
Gets player-friendly harvest feedback
```dm
var/msg = GetPlantHarvestMessage(potato_plant, 1)
// Returns: "Potato is in excellent condition. The harvest is bountiful!"

var/msg = GetPlantHarvestMessage(potato_plant, 0)
// Returns: "Potato was planted out of season and has poor quality."
```

---

## INTEGRATION EXAMPLES

### Example 1: Update Vegetable Growth Proc

**Current code in plant.dm (Grow proc around line 820):**
```dm
Grow()//vegetable growth
    var/randomvalue = rand(240,840)
    spawn(randomvalue)
        if(src.vgrowstate == 8||src.vgrowstate == 7)
            return
        // ... rest of growth code
```

**Updated with seasonal check:**
```dm
Grow()//vegetable growth
    if (!ApplySeasonalGrowthModifier(src))
        return  // Out of season, stop growth
    
    var/randomvalue = rand(240,840)
    spawn(randomvalue)
        if(src.vgrowstate == 8||src.vgrowstate == 7)
            return
        // ... rest of growth code
```

---

### Example 2: Update Vegetable Harvesting Proc (PickV)

**What to change:**
When giving vegetables to player, apply yield bonus.

**Current code structure (around line 635):**
```dm
proc/PickV(mob/Picker)//vegetable proc
    var/mob/players/M = usr
    // ... validation code ...
    
    // When harvesting succeeds:
    for(var/obj/items/Vegetables/V in world)
        if(istype(V, vegetable))
            V.Amount += VegeAmount  // Give vegetables
```

**Updated with yield bonus:**
```dm
proc/PickV(mob/Picker)//vegetable proc
    var/mob/players/M = usr
    // ... validation code ...
    
    // When harvesting succeeds:
    var/yield = ApplyHarvestYieldBonus(src, VegeAmount, M.hrank ? M.hrank : 1)
    
    for(var/obj/items/Vegetables/V in world)
        if(istype(V, vegetable))
            V.Amount += yield  // Give vegetables with season/skill bonus
    
    // Show quality feedback
    var/quality = GetConsumableQuality(lowertext(VegeType), M)
    var/quality_percent = round(quality * 100)
    M << "[VegeType] harvest quality: [quality_percent]%"
```

---

### Example 3: Update Berry Harvesting

**For berry picking (Pick proc around line 620):**

```dm
proc/Pick(mob/Picker)//berry proc
    var/mob/players/M = usr
    // ... validation code ...
    
    // When picking succeeds:
    var/yield = ApplyHarvestYieldBonus(src, FruitAmount, M.hrank ? M.hrank : 1)
    
    // Create items and give to player
    for(var/i = 1; i <= yield; i++)
        new fruit(M.loc)
    
    M << "[FruitType] picked: [yield] items (adjusted for season)"
```

---

### Example 4: Show Seasonal Feedback

**In harvesting code, add:**

```dm
// After successful harvest
var/consumable_name = GetPlantConsumableName(src)
if (consumable_name)
    if (!IsSeasonForCrop(consumable_name))
        M << "[name] was out of season - reduced quality!"
    else
        var/quality = GetConsumableQuality(consumable_name, M)
        if (quality >= 1.1)
            M << "[name] is in perfect condition!"
        else if (quality < 0.85)
            M << "[name] is not optimal this season."
```

---

## SEASONAL MAPPING

### Vegetables (Autumn-Winter Crops)
```
Potato:     Autumn-Winter (good in autumn, okay in winter)
Carrot:     Autumn-Winter
Onion:      Autumn-Winter
Tomato:     Summer-Autumn (prefers summer)
Pumpkin:    Autumn-Winter
```

### Berries (Spring-Summer)
```
Raspberry:   Spring-Autumn
Blueberry:   Spring-Autumn
```

### Grains (Autumn Harvest, Winter Storage)
```
Wheat:  All (but grown in autumn)
Barley: All (but grown in autumn)
```

---

## QUALITY CALCULATION REMINDER

```
Quality = base × season × biome × temperature

Season modifier:
  - In-season = 1.0
  - Out-of-season = 0.7 (30% penalty)

Example:
  Potato in autumn (in-season) = 1.0 quality → 100% harvest value
  Potato in spring (out-of-season) = 0.7 quality → 70% harvest value
```

---

## NEXT STEPS FOR FULL INTEGRATION

### Phase 1: Add Seasonal Check to Growth (5 minutes)
- [ ] Add ApplySeasonalGrowthModifier() call to Grow() proc
- [ ] Test that vegetables stop growing out of season

### Phase 2: Add Yield Bonus to Harvesting (15 minutes)
- [ ] Update PickV() for vegetables
- [ ] Update Pick() for berries
- [ ] Update PickG() for grains
- [ ] Test that yields vary by season/skill

### Phase 3: Add Quality Feedback (10 minutes)
- [ ] Add quality percentage messages
- [ ] Add in-season/out-of-season feedback
- [ ] Test player feedback

### Phase 4: Visual Updates (10 minutes)
- [ ] Add out-of-season visual state
- [ ] Update plant names to show status
- [ ] Make it clear when crops aren't growing

### Total Time: ~40 minutes for full integration

---

## CODE SNIPPETS TO COPY

### Seasonal Check (Add to Grow proc)
```dm
if (!ApplySeasonalGrowthModifier(src))
    return  // Out of season
```

### Yield Application (Add to Pick/PickV/PickG)
```dm
var/final_yield = ApplyHarvestYieldBonus(src, base_amount, player.hrank ? player.hrank : 1)
```

### Quality Feedback (Add after harvest)
```dm
var/quality = GetConsumableQuality(lowertext(crop_name), player)
player << "Harvest quality: [round(quality * 100)]%"
```

---

## TESTING CHECKLIST

- [ ] Plant in-season crop → should grow
- [ ] Plant out-of-season crop → should NOT grow (vgrowstate=8)
- [ ] Harvest in-season crop with skill 1 → fewer items (0.5×)
- [ ] Harvest in-season crop with skill 10 → more items (1.4×)
- [ ] Harvest out-of-season → 30% fewer items
- [ ] See quality messages when harvesting
- [ ] Skill progression works (higher rank = bigger harvests)

---

**Status**: Ready for plant.dm integration  
**Estimated Time**: 40 minutes for full connection  
**Impact**: Complete seasonal farming system

