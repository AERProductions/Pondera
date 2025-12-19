# PONDERA CONSUMPTION SYSTEM - QUICK REFERENCE

**Build Status**: ✅ **0 errors, 3 warnings**  
**Last Updated**: 12/7/25 10:57 PM  
**Integration**: Complete (Framework Ready for Plant System Connection)

---

## 🎯 AT A GLANCE

### What Was Built
Three interconnected systems that make food work like real life:
1. **ConsumptionManager.dm** - All 25+ foods defined with stats
2. **FarmingIntegration.dm** - Harvest yields, seasonal checks
3. **HungerThirstSystem.dm** (updated) - Quality modifiers on consumption

### The Core Idea
```
HARVEST FOOD (with skill bonus) → FOOD AFFECTED BY SEASON/BIOME/TEMP → CONSUMPTION RESTORES REDUCED STATS

Out-of-season potato:  30% less nutrition
Desert food in desert:  10% more hydration
Extreme cold food:      20% less nutrition
```

---

## 📚 THE THREE FILES

### 1. ConsumptionManager.dm (370 lines)
**Purpose**: Global registry of all foods + quality calculation

```dm
// Every food defined here
CONSUMABLES = list(
    "fresh water" = list(
        "type" = "water",
        "hydration" = 300,
        "stamina" = 50,
        "seasons" = list("Spring", "Summer", "Autumn", "Winter"),
        "biomes" = list("all"),
        "quality" = 1.0,
        ...
    ),
    ...
)

// Main quality function
GetConsumableQuality(food_name, player)
  → Returns 0.5 to 1.2+ multiplier based on season/biome/temp

// Availability checking
IsSeasonForCrop(crop_name)
  → Returns 1 (harvestable) or 0 (not in season)

GetSeasonalConsumables()
  → Returns list of ALL foods harvestable right now
```

**When to use it:**
- Get quality of food before consumption
- Check if crop is harvestable now
- Get list of available foods for UI/merchants
- Calculate environmental impact on food

---

### 2. FarmingIntegration.dm (290 lines)
**Purpose**: Connect harvesting to consumption system

```dm
// Can we harvest this crop right now?
IsHarvestSeason(crop_name)
  → Returns 1 if in-season, 0 if not

// How much do we get when harvesting?
GetCropYield(crop_name)
  → In-season = 1.3× yield
  → Normal = 1.0× yield
  → Out-of-season = 0.7× yield

// Days until crop is ready?
GetCropGrowthDaysRemaining(crop_name)
  → Returns days, used for farm UI

// Apply harvest skill bonus
HarvestCropWithYield(crop_name, skill_level)
  → Skill level 1 = 0.5× yield
  → Skill level 10 = 1.0-1.4× yield

// What's harvestable this season?
GetAvailableFoodsThisSeason()
  → List of all foods you can harvest/buy right now

// Future: NPC eating
NPCConsumesFood(npc, food_name)
  → Affects NPC mood/work/loyalty
```

**When to use it:**
- Before allowing crop harvest
- Calculate total harvest amount
- Show farm UI (days remaining, available crops)
- Get list of foods for merchants/NPCs

---

### 3. HungerThirstSystem.dm (Updated)
**Purpose**: Apply quality modifiers when consuming food

```dm
// The key change
ConsumeFoodItem(food_name, nutrition, hydration, hp, stamina)
    var/quality = GetConsumableQuality(food_name, src)
    var/env_impact = EnvironmentalImpactOnConsumables(src)
    var/final_quality = quality * env_impact
    
    // All effects reduced by final_quality
    nutrition_restored = round(nutrition * final_quality)
    hydration_restored = round(hydration * final_quality)
    health_restored = round(hp * final_quality)
    stamina_restored = round(stamina * final_quality)
```

**The result:**
- Out-of-season food = 70% effectiveness
- Wrong biome = 85% effectiveness
- Local biome = 110% effectiveness
- Extreme cold = 80% effectiveness
- Extreme heat = 90% effectiveness

---

## 🔢 QUALITY CALCULATION FORMULA

```
final_quality = base_quality × seasonal_modifier × biome_modifier × temp_modifier

seasonal_modifier:
  - In-season = 1.0
  - Out-of-season = 0.7 (30% penalty)

biome_modifier:
  - Local biome = 1.1 (10% bonus)
  - Different biome = 0.85 (15% penalty)

temp_modifier:
  - Extreme cold (<-10°C) = 0.8 (20% penalty)
  - Normal temps = 1.0
  - Extreme heat (>35°C) = 0.9 (10% penalty)
```

### Examples

**Potato in Autumn (In-Season, Normal Temp)**
```
base = 1.0
seasonal = 1.0 (autumn is in-season)
biome = 1.0 (temperate)
temp = 1.0 (normal)
result = 1.0
nutrition = 120 × 1.0 = 120 ✅
```

**Raspberry in Winter (Out-of-Season)**
```
base = 0.95
seasonal = 0.7 (winter, not in spring-autumn)
biome = 1.0 (temperate)
temp = 1.0 (normal)
result = 0.665
nutrition = 80 × 0.665 = 53 ❌ (much worse!)
```

**Cactus Water in Desert (Local Biome, Hot)**
```
base = 0.8
seasonal = 1.0 (water always in-season)
biome = 1.1 (desert water, desert player)
temp = 0.9 (38°C, extreme heat)
result = 0.792
hydration = 150 × 0.792 = 119 ✅
```

---

## 🍌 CONSUMABLES REFERENCE

### Water (7 types) - Never Decay
| Item | Hydration | Stamina | When? | Where? | Quality |
|------|-----------|---------|-------|--------|---------|
| Fresh Water | 300 | 50 | Always | Everywhere | 1.0 |
| Oasis Water | 250 | 40 | Always | Desert | 1.0 |
| Jungle Water | 280 | 45 | Always | Jungle | 1.0 |
| Water Vine | 200 | 30 | Spring-Summer | Jungle/Rainforest | 0.9 |
| Cactus Water | 150 | 25 | Always | Desert | 0.8 |
| Fountain Water | 400 | 60 | Always | Temperate | 1.2 |
| Jar Water | 300 | 50 | Always | Everywhere | 1.0 |

### Berries (5 types) - 2-3% Daily Decay
| Item | Nutrition | Health | When? | Where? | Quality |
|------|-----------|--------|-------|--------|---------|
| Raspberry | 80 | 15 | Spring-Autumn | Temperate | 0.95 |
| Blueberry | 85 | 20 | Spring-Autumn | Temperate/Rainforest | 1.0 |
| Raspberry Cluster | 200 | 35 | Spring-Autumn | Temperate | 0.95 |
| Blueberry Cluster | 220 | 45 | Spring-Autumn | Temperate/Rainforest | 1.0 |

### Vegetables (5 types) - 5-7% Daily Decay
| Item | Nutrition | Health | When? | Where? | Quality |
|------|-----------|--------|-------|--------|---------|
| Potato | 120 | 25 | Autumn-Winter | Temperate | 1.0 |
| Carrot | 100 | 20 | Autumn-Winter | Temperate | 0.95 |
| Onion | 90 | 18 | Autumn-Winter | Everywhere | 0.9 |
| Tomato | 110 | 30 | Summer-Autumn | Temperate/Desert | 0.98 |
| Pumpkin | 140 | 35 | Autumn-Winter | Temperate | 1.05 |

### Grains (2 types) - Never Decay (Stored)
| Item | Nutrition | Stamina | When? | Where? | Quality |
|------|-----------|---------|-------|--------|---------|
| Wheat | 150 | 40 | All (stored) | Temperate | 1.0 |
| Barley | 145 | 38 | All (stored) | Temperate | 0.98 |

---

## 🎮 HOW PLAYERS EXPERIENCE IT

### Spring
- Berries appear! Excellent nutrition (peak quality)
- No root vegetables yet (still growing)
- Forage for water vines, fountain water
- Build up food supply before summer

### Summer
- Berries reach peak availability
- Tomatoes appear (summer vegetable)
- Root vegetables still growing
- Store berries/grain for winter

### Autumn
- **HARVEST TIME!** Potatoes, carrots, onions, pumpkins ready
- Last berries before winter
- Get 30% bonus yield if skilled (1.3× crops)
- Must preserve vegetables for winter!

### Winter
- Only stored food and basic water available
- Any fresh food is out-of-season (30% less effective)
- Extreme cold makes food even less nourishing (-20%)
- **Survival depends on planning ahead!**

---

## 📋 INTEGRATION CHECKLIST

### Currently Complete ✅
- [x] ConsumptionManager.dm (registry + quality calc)
- [x] FarmingIntegration.dm (harvest hooks)
- [x] HungerThirstSystem.dm (quality application)
- [x] Pondera.dme (includes in correct order)
- [x] Build: 0 errors

### Ready for Next Phase 🔄
- [ ] plant.dm - Add IsHarvestSeason() check to Grow() proc
- [ ] plant.dm - Add GetCropYield() to harvesting code
- [ ] plant.dm - Visual state for out-of-season crops
- [ ] Berry bushes - Seasonal fruiting logic
- [ ] UI system - Farm management display

### Future Features ⏳
- [ ] Inventory spoilage system (decay rates)
- [ ] Food preservation (smoking, salting, drying)
- [ ] Merchant seasonal pricing
- [ ] Recipe seasonal requirements
- [ ] NPC food preferences
- [ ] Weather effects on food quality

---

## 🔗 KEY CONNECTIONS

### From plant.dm to ConsumptionManager
```dm
// In Grow() proc - check if harvestable
if (!IsHarvestSeason(crop_name))
    src.vgrowstate = 8  // Out of season
    return

// In harvesting - apply yield bonus
var/yield = GetCropYield(crop_name)
total_harvest = base_amount * yield
```

### From harvesting to HungerThirstSystem
```dm
// When player eats harvested food
ConsumeFoodItem("potato", 120, 0, 25, 0)
// Internally:
//   quality = GetConsumableQuality("potato", src)
//   env = EnvironmentalImpactOnConsumables(src)
//   nutrition = 120 × quality × env
```

### From seasons to gameplay
```dm
// Spring/Summer: Berries abundant
// Autumn: Root vegetables harvest
// Winter: Stored food only, reduced quality
// Year-round survival loop
```

---

## 💡 DEVELOPER TIPS

### Calling the Functions

**Check if crop harvestable:**
```dm
if (IsHarvestSeason("potato"))
    world << "Potatoes are ready to harvest!"
```

**Get harvest amount:**
```dm
var/yield = GetCropYield("potato")
var/harvest_amount = 5 * yield  // 5 base potatoes × yield
// In autumn: 6-7 potatoes (1.3× bonus)
// In summer: 3-4 potatoes (0.7× penalty)
```

**Get quality for display:**
```dm
var/quality = GetConsumableQuality("raspberry", player)
var/quality_percent = round(quality * 100)
world << "This raspberry is [quality_percent]% effective"
```

**Get available foods for UI:**
```dm
var/list/available = GetAvailableFoodsThisSeason()
// Returns list of all foods harvestable right now
// Good for: Merchant stock, farm UI, foraging prompts
```

---

## ⚠️ COMMON MISTAKES

❌ **Wrong**: Using `player.zone` directly
```dm
// This doesn't work - zone is not a variable
var/biome = player.zone
```

✅ **Right**: Use zone_manager to find player's zone
```dm
// This works - iterate active zones
for (var/zone in global.zone_mgr.active_zones)
    if (zone.CheckIfTurfInZone(player.x, player.y, player.z))
        var/biome = zone.biome_type
        break
```

❌ **Wrong**: Forgetting quality modifier
```dm
// Food always restores full amount
ConsumeFoodItem("potato", 120, 0, 25, 0)
// This ignores season/biome/temp!
```

✅ **Right**: Quality is applied automatically
```dm
// Inside ConsumeFoodItem(), it calculates:
var/quality = GetConsumableQuality(food_name, src)
var/final_effect = 120 * quality
// If out-of-season: 120 × 0.7 = 84 nutrition
```

---

## 📞 FUNCTION REFERENCE

### ConsumptionManager Functions

| Function | Returns | Example |
|----------|---------|---------|
| `GetConsumableQuality(food_name, player)` | 0.5-1.2+ | Quality 0.7 for out-of-season food |
| `IsSeasonForCrop(crop_name)` | 0/1 | 1 if harvestable now, 0 if not |
| `GetSeasonalConsumables()` | list | ["raspberry", "potato", "wheat", ...] |
| `EnvironmentalImpactOnConsumables(player)` | 0.8-1.0 | 0.8 if extreme cold, 1.0 if normal |
| `ConsumableDecayRate(food_name)` | %/day | 3% for berries, 0% for water |

### FarmingIntegration Functions

| Function | Returns | Example |
|----------|---------|---------|
| `IsHarvestSeason(crop_name)` | 0/1 | 1 if can harvest now |
| `GetCropYield(crop_name)` | 0.7-1.3 | 1.3 if in-season, 0.7 if not |
| `GetCropGrowthDaysRemaining(crop_name)` | days | 60 days until autumn potato harvest |
| `HarvestCropWithYield(crop_name, skill)` | amount | Skill 10 gets 1.4× yield |
| `GetAvailableFoodsThisSeason()` | list | All foods harvestable right now |

---

## 📊 QUICK STATS TABLE

### Seasonal Availability
| Season | Key Foods | Quality Bonus |
|--------|-----------|---------------|
| Spring | Berries, water vines | Berries 100% |
| Summer | Berries, tomatoes | Berries 100%, tomatoes 100% |
| Autumn | All vegetables, last berries | Vegetables 100% |
| Winter | Stored foods only | All -30% (extreme cold) |

### Biome Effects
| Effect | Bonus | Penalty | Example |
|--------|-------|---------|---------|
| Local biome food | +10% | — | Desert player drinks cactus water +10% |
| Foreign biome food | — | -15% | Temperate player drinks cactus water -15% |
| Extreme cold (<-10°C) | — | -20% | Any food in arctic blizzard -20% |
| Extreme heat (>35°C) | — | -10% | Any food in desert heat -10% |

---

**Status**: Ready for plant.dm integration!  
**Next Step**: Add IsHarvestSeason() check to plant.dm Grow() proc

