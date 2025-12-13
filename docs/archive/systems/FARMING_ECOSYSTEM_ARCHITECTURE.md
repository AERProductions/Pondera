# Pondera Farming Ecosystem - Complete Architecture

## System Overview

The Pondera farming ecosystem is a **multi-layered, interconnected system** where environmental factors cascade through harvesting, consumption, and player decisions.

```
┌─────────────────────────────────────────────────────────────────┐
│                    FARMING ECOSYSTEM STACK                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  LAYER 5: PLAYER EXPERIENCE                                     │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Food consumed restores different amounts based on:      │    │
│  │ - Season grown (in-season = 30% better)                 │    │
│  │ - Soil quality (rich = 15% better nutrition)            │    │
│  │ - Biome (local = 15% better, foreign = 15% worse)       │    │
│  │ - Temperature (extreme = 20% worse)                      │    │
│  │ Result: Eating home-grown crops is noticeably better!   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                           ↑                                      │
│  LAYER 4: CONSUMPTION                                            │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ HungerThirstSystem                                      │    │
│  │ ConsumeFoodItem() applies:                              │    │
│  │ - GetConsumableQuality() [season × biome × temp]        │    │
│  │ - EnvironmentalImpactOnConsumables() [temp modifier]    │    │
│  │ - Soil quality modifier (NEW)                           │    │
│  │ Result: Food value = base × all_modifiers               │    │
│  └─────────────────────────────────────────────────────────┘    │
│                           ↑                                      │
│  LAYER 3: HARVESTING                                             │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ PlantSeasonalIntegration                                │    │
│  │ ApplyHarvestYieldBonus() applies:                       │    │
│  │ - Season modifier (in-season = 1.3×)                    │    │
│  │ - Skill multiplier (rank 10 = 1.4×)                     │    │
│  │ - Soil modifier (rich = 1.2×) [NEW]                     │    │
│  │ - Crop-soil affinity (potatoes in rich = 1.1×) [NEW]   │    │
│  │ Result: Harvest amount = base × season × skill × soil   │    │
│  │                                                         │    │
│  │ Harvest messages include:                               │    │
│  │ - "Rich soil has greatly improved the harvest!"         │    │
│  │ - "Depleted soil yielded poor results."                │    │
│  └─────────────────────────────────────────────────────────┘    │
│                           ↑                                      │
│  LAYER 2: GROWTH                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ PlantSeasonalIntegration + SoilSystem                   │    │
│  │                                                         │    │
│  │ ApplySeasonalGrowthModifier():                          │    │
│  │ - Blocks growth out-of-season                           │    │
│  │ - Sets vgrowstate = 8 (visual indicator)                │    │
│  │                                                         │    │
│  │ ApplySoilModifiersToGrowthSpeed():                      │    │
│  │ - Rich soil: 15% faster (0.87× days)                    │    │
│  │ - Basic soil: normal speed (1.0× days)                  │    │
│  │ - Depleted: 40% slower (1.67× days)                     │    │
│  │                                                         │    │
│  │ Result: Growth days = base ÷ soil_growth_modifier       │    │
│  │         14 days basic → 12 days rich → 23 days depleted │    │
│  └─────────────────────────────────────────────────────────┘    │
│                           ↑                                      │
│  LAYER 1: ENVIRONMENT                                            │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Environmental Factors:                                  │    │
│  │ - Season (Spring/Summer/Autumn/Winter) [global.season]  │    │
│  │ - Temperature (°C) [TemperatureSystem]                  │    │
│  │ - Biome (Temperate/Desert/Arctic/etc)                   │    │
│  │ - Soil Quality (Depleted/Basic/Rich) [SoilSystem]       │    │
│  │ - Time (hour, minute, day, month, year)                 │    │
│  │                                                         │    │
│  │ All factors recorded in:                                │    │
│  │ - ConsumptionManager [registry + quality calcs]         │    │
│  │ - SoilSystem [soil modifiers]                           │    │
│  │ - TemperatureSystem [temp values]                       │    │
│  │ - Global time variables                                 │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow: From Planting to Consumption

### 1. Player Plants Crop
```
Player calls: Pick() or plant_crop()
              ↓
         [Get crop type]
              ↓
         [Check season] ← IsSeasonForCrop()
              ↓
    [Create plant object]
              ↓
    [Set growth timer]
         (with soil modifier applied)
```

### 2. Plant Grows Over Time
```
         [Grow() called]
              ↓
    [Check current season] ← ApplySeasonalGrowthModifier()
              ↓
    [If out-of-season: stop growth, set vgrowstate=8]
    [If in-season: continue growth]
              ↓
    [Check soil] ← ApplySoilModifiersToGrowthSpeed()
              ↓
    [Adjust growth speed: 15% faster (rich) to 40% slower (depleted)]
              ↓
    [When mature: ready for harvest]
```

### 3. Player Harvests Crop
```
      Player calls: PickV() / Pick() / PickG()
              ↓
    [Get harvest season] ← IsSeasonForCrop()
              ↓
    [Get soil quality] ← GetSoilType()
              ↓
    [Calculate yield] ← ApplyHarvestYieldBonus()
         ├─ Season modifier (0.7-1.3)
         ├─ Skill multiplier (0.5-1.4)
         ├─ Soil yield modifier (0.5-1.2)
         └─ Crop-soil affinity (0.95-1.1)
              ↓
    [Generate harvest message] ← GetPlantHarvestMessage()
         "Rich soil greatly improved the harvest!"
              ↓
    [Create food items] with harvest_amount
              ↓
    [Remove plant object]
```

### 4. Player Consumes Food
```
       Player eats: food_item
              ↓
    [Call ConsumeFoodItem()] ← HungerThirstSystem
              ↓
    [Get base values] ← CONSUMABLES registry
       nutrition, hydration, health, stamina
              ↓
    [Calculate quality] ← GetConsumableQuality()
         ├─ Season modifier (±30%)
         ├─ Biome modifier (±15%)
         └─ Temperature modifier (±20%)
              ↓
    [Apply soil quality] ← GetSoilQualityModifier()
         Rich soil: ×1.15 nutrition
              ↓
    [Apply environment impact]
    ← EnvironmentalImpactOnConsumables()
         ├─ Temperature effects
         └─ Final quality multiplier
              ↓
    [Calculate final effect] 
         final_value = base × quality × env_impact × soil_quality
              ↓
    [Restore hunger/thirst/health/stamina]
```

## Key Integration Points

### ConsumptionManager.dm
**Purpose**: Central registry of all consumable foods and quality calculations

**Contains**:
- 25+ food items (water, berries, vegetables, grains)
- Base nutrition/hydration/health/stamina values
- Seasonal availability (which months each food is available)
- Biome preferences
- Quality multipliers for all modifiers

**Used by**:
- HungerThirstSystem (for food consumption)
- FarmingIntegration (for availability checks)
- PlantSeasonalIntegration (for harvest feedback)
- SoilSystem (for crop-soil affinity)

### SoilSystem.dm (NEW)
**Purpose**: Soil quality modifiers and crop affinity system

**Contains**:
- Three soil tiers: Depleted (0), Basic (1), Rich (2)
- Growth, yield, and quality modifiers per soil type
- Crop-soil affinity system (e.g., potatoes prefer rich soil)
- Framework for soil degradation and composting

**Used by**:
- PlantSeasonalIntegration (for harvest calculations)
- FarmingIntegration (for yield calculations)
- HungerThirstSystem (for food quality)
- Future: plant.dm (for growth speed)

### PlantSeasonalIntegration.dm
**Purpose**: Connect plant growth to seasonal and soil systems

**Contains**:
- Plant-to-consumable name mapping
- Seasonal growth blocking
- Harvest yield calculations with all modifiers
- Harvest message generation

**Calls**:
- GetPlantConsumableName() [maps plant → food]
- IsSeasonForCrop() [season check]
- ApplySeasonalGrowthModifier() [stop out-of-season growth]
- ApplyHarvestYieldBonus() [calc yield with soil]
- GetPlantHarvestMessage() [user feedback]

### FarmingIntegration.dm
**Purpose**: Farming mechanics and harvest integration

**Contains**:
- Harvest season calculations
- Crop yield calculations
- Growth day estimations
- Seasonal food availability lists

**Calls**:
- IsSeasonForCrop() [season check]
- GetConsumableQuality() [quality calc]
- HarvestCropWithYield() [yield with soil]

### HungerThirstSystem.dm
**Purpose**: Food consumption and hunger/thirst management

**Contains**:
- ConsumeFoodItem() main consumption proc
- Effect application (health, stamina, etc.)

**Calls**:
- GetConsumableQuality() [seasonal/biome quality]
- EnvironmentalImpactOnConsumables() [temp modifier]
- Soil quality modifiers [via updated ApplyHarvestYieldBonus()]

## Quality Calculation Example

**Scenario**: Player harvests potato in autumn with rank 5 harvesting, grows in rich soil, eats in temperate biome

### Harvest Phase
```
Base potato yield: 5
Season modifier: 1.3 (autumn, in-season) ← IsSeasonForCrop()
Skill modifier: 1.05 (rank 5: 0.5 + 5/10) ← HarvestCropWithYield()
Soil yield modifier: 1.2 (rich soil) ← GetSoilYieldModifier()
Crop-soil affinity: 1.1 (potatoes love rich soil) ← GetCropSoilBonus()

FINAL YIELD = 5 × 1.3 × 1.05 × 1.2 × 1.1 = 9 potatoes
```

**Message**: "Rich soil has greatly improved the harvest!"

### Consumption Phase
```
Base potato nutrition: 10 (from CONSUMABLES registry)
Season quality: 1.0 (eating in-season food) ← GetConsumableQuality()
Biome quality: 1.0 (in temperate biome) ← GetConsumableQuality()
Temperature quality: 1.0 (normal temp) ← GetConsumableQuality()
Overall quality: 1.0

Soil quality modifier: 1.15 (rich soil food is more nutritious) 
← GetSoilQualityModifier()

Environmental impact: 1.0 (normal conditions) 
← EnvironmentalImpactOnConsumables()

FINAL NUTRITION = 10 × 1.0 × 1.0 × 1.0 × 1.15 × 1.0 = 11.5 ≈ 12 nutrition restored
```

**Result**: Rich soil potato heals 20% more than basic soil potato!

## System Dependencies

### Load Order (Critical)
```
Pondera.dme includes in order:
1. !defines.dm [defines soil constants]
2. TemperatureSystem.dm [temperature data]
3. ConsumptionManager.dm [food registry - FIRST]
4. SoilSystem.dm [soil modifiers - DEPENDS on defines]
5. FarmingIntegration.dm [DEPENDS on consumption]
6. PlantSeasonalIntegration.dm [DEPENDS on all above]
7. HungerThirstSystem.dm [DEPENDS on all above]
```

**Why Order Matters**:
- SoilSystem needs SOIL_BASIC/SOIL_RICH constants
- FarmingIntegration needs CONSUMABLES global from ConsumptionManager
- PlantSeasonalIntegration needs functions from both above
- HungerThirstSystem needs quality functions from all systems

### Function Call Dependency Tree
```
ConsumeFoodItem() [HungerThirstSystem]
├─ GetConsumableQuality() [ConsumptionManager]
│  ├─ IsSeasonForCrop() [FarmingIntegration]
│  └─ EnvironmentalImpactOnConsumables() [ConsumptionManager]
└─ (implied soil modifiers via CONSUMABLES)

ApplyHarvestYieldBonus() [PlantSeasonalIntegration]
├─ GetPlantConsumableName() [PlantSeasonalIntegration]
├─ GetSoilYieldModifier() [SoilSystem]
└─ GetCropSoilBonus() [SoilSystem]

GetPlantHarvestMessage() [PlantSeasonalIntegration]
├─ GetConsumableQuality() [ConsumptionManager]
├─ GetSoilName() [SoilSystem]
└─ GetSoilDescription() [SoilSystem]
```

## Modifiers Summary Table

### All Modifiers in One Place

| Factor | Type | Min | Max | Impact |
|--------|------|-----|-----|--------|
| **Season** | Quality | 0.7 | 1.3 | ±30% food value |
| **Season** | Yield | 0.7 | 1.3 | ±30% harvest amount |
| **Biome** | Quality | 0.85 | 1.15 | ±15% nutrition |
| **Temperature** | Quality | 0.8 | 1.0 | ±20% (extreme cold) |
| **Temperature** | Yield | 0.8 | 1.0 | ±20% (extreme cold) |
| **Skill** | Yield | 0.5 | 1.4 | Rank 1-10 multiplier |
| **Soil Growth** | Speed | 0.6 | 1.15 | ±40% days to grow |
| **Soil Yield** | Amount | 0.5 | 1.2 | ±50% harvest |
| **Soil Quality** | Nutrition | 0.7 | 1.15 | ±30% food value |
| **Crop Affinity** | Quality | 0.95 | 1.15 | ±15% (crop-specific) |

### Practical Example: Worst Case
```
Out-of-season potato
In depleted soil
Harvested by rank 1 player
In desert biome
At extreme cold (-20°C)
Then eaten in desert at extreme heat (+40°C)

Harvest: 5 × 0.7 (season) × 0.5 (rank 1) × 0.5 (depleted) × 0.95 (affinity)
       = 0.83 → 1 potato

Nutrition: 10 × 0.7 (out-of-season) × 0.85 (biome) × 0.8 (cold) × 0.7 (depleted soil) × 0.9 (heat)
        = 2.98 ≈ 3 nutrition restored
```

**That one potato restores only 3 nutrition - barely worthwhile!**

### Practical Example: Best Case
```
In-season potato
In rich soil
Harvested by rank 10 player
In local biome (temperate)
At normal temperature (20°C)
Then eaten in local biome

Harvest: 5 × 1.3 (season) × 1.4 (rank 10) × 1.2 (rich) × 1.1 (affinity)
       = 12 potatoes!

Nutrition: 10 × 1.0 (in-season) × 1.0 (local biome) × 1.0 (normal temp) × 1.15 (rich soil) × 1.0 (normal temp)
        = 11.5 ≈ 12 nutrition restored
```

**Best case is 12× better than worst case!**

## Future Expansion Architecture

### Phase 9: Soil Degradation
```
Turf variables:
  fertility = 0-150 (determines soil_type)
  last_crop = name of crop last planted
  
On harvest:
  fertility -= 5  (normal depletion)
  
If (last_crop == current_crop):
  fertility -= 5  (monoculture penalty)
```

### Phase 10: Composting System
```
New item type: obj/composting_bin
  Accepts: crop_waste, bone_meal, manure, kelp
  
Combines into: compost item
  
On apply_compost(T, compost_item):
  T.fertility += 20
  compost_item deleted
```

### Phase 11: Paddy Systems
```
Special turf type: turf/paddy
  fertility like normal soil
  
Requires: water adjacent
  
Benefits: high yield for water-loving crops
  rice_yield_modifier = 1.3 (vs 1.2 for rich soil)
```

## Design Philosophy: "The Pondera Way"

**Every system interconnects**:
1. Environment (season/temp/biome) affects growth
2. Growth affects harvest
3. Harvest affects consumption
4. Consumption affects player progression
5. Soil quality amplifies or diminishes ALL steps

**Result**: The farming ecosystem creates a **self-reinforcing loop** where better planning → better harvest → better food → better survival → better progression.

This embodies Pondera's design philosophy: **everything matters, everything connects**.

