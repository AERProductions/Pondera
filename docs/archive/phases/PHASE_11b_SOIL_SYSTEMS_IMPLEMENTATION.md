# Phase 11b: Soil Management Systems Implementation

## Summary
Successfully implemented three core farming systems for Phase 11b (Farming Phase 10):
- **SoilPropertySystem.dm** (340 lines): Turf-based soil property tracking
- **CompostSystem.dm** (253 lines): Compost crafting, types, and application
- **SoilDegradationSystem.dm** (313 lines): Soil degradation and nutrient depletion

**Build Status**: ✅ 0/0 errors, clean compile

## Architecture Overview

### 1. SoilPropertySystem.dm
**Purpose**: Manage individual soil properties per turf

**Core Functions**:
- `InitializeSoilProperties(turf/T)` - Lazy initialization of soil vars
- `GetSoilFertility(turf/T)` - Get fertility (0-200 scale)
- `SetSoilFertility(turf/T, value)` - Set fertility directly
- `ModifySoilFertility(turf/T, delta)` - Add/subtract fertility
- `GetSoilPH(turf/T)` - Get pH level (6.0-8.0)
- `SetSoilPH(turf/T, value)` - Set pH level
- `AdjustSoilPHTowardNeutral(turf/T, amount)` - Adjust pH toward 7.0
- `GetPHGrowthModifier(turf/T)` - Returns 0.9-1.0 multiplier (acidity penalty)
- `GetSoilNutrient(turf/T, nutrient_type)` - Get N/P/K level (0-100)
- `SetSoilNutrient(turf/T, nutrient_type, value)` - Set nutrient level
- `ModifySoilNutrient(turf/T, nutrient_type, delta)` - Adjust nutrient
- `GetNutrientYieldModifier(turf/T, crop_name)` - Crop-specific bonus (1.0-2.0x)
- `GetSoilMoisture(turf/T)` - Get moisture % (0-100)
- `SetSoilMoisture(turf/T, value)` - Set moisture
- `GetMoistureGrowthModifier(turf/T)` - Returns 0.85-1.1 multiplier
- `GetLastCrop(turf/T)` - Get previously planted crop
- `SetLastCrop(turf/T, crop_name)` - Update crop history
- `GetCropRotationModifier(turf/T, crop_name)` - Returns +5% for rotation, -10% for monoculture
- `GetSoilProperties(turf/T)` - Get all properties as list
- `DebugSoilProperties(turf/T)` - Print soil info to log

**Key Constants** (in !defines.dm):
```dm
#define SOIL_DEPLETED 0
#define SOIL_BASIC 1
#define SOIL_RICH 2
```

**Property Ranges**:
- **Fertility**: 0-200 (higher = better growth/yield)
- **pH**: 6.0-8.0 (7.0 neutral; <7 acidic, >7 alkaline)
- **Nutrients**: 0-100 each for N, P, K
- **Moisture**: 0-100% (optimal ~60%)

### 2. CompostSystem.dm
**Purpose**: Convert waste materials into fertilizer

**Compost Types**:
1. **COMPOST_BASIC** (Vegetable Compost)
   - Source: Harvest waste, crop scraps
   - Effects: F+30, N+15, P+10, K+5
   - Quality: 1.0

2. **COMPOST_BONE_MEAL**
   - Source: Bones from hunting/animals
   - Effects: F+25, N+5, P+25 (high phosphorus), K+5
   - Quality: 1.2 (best for fruits)

3. **COMPOST_KELP**
   - Source: Kelp/seaweed from fishing
   - Effects: F+28, N+10, P+10, K+30 (high potassium), K+30
   - Quality: 1.1 (best for root crops)

**Core Functions**:
- `CanCompostMaterial(material_name)` - Check if material is compostable
- `GetCompostProperties(compost_type)` - Get compost stats
- `GetCompostName(compost_type)` - Get human-readable name
- `CraftCompost(mob/players/player, material, quality)` - Craft compost from waste
  - Awards 5 gardening XP
  - Quality scaled by gardening skill (0.5-1.5)
  - Returns compost_type or 0 on failure
- `ApplyCompost(turf/T, compost_type, quality)` - Apply compost to turf
  - Restores fertility + nutrients
  - Limited to 5 applications per season (anti-exploit)
  - Returns TRUE if applied, FALSE if max reached
- `ResetCompostApplicationCount(turf/T)` - Reset application counter (seasonal)
- `GenerateHarvestCompost(crop_name, harvest_amount)` - Waste from harvest (~10%)
- `GenerateBoneMeal(bone_amount, processing_skill)` - Bones→meal (~50%)
- `GenerateKelpCompost(kelp_amount)` - Kelp→compost (~40%)
- `GetCompostEffectivenessOnCrop(compost_type, crop_name)` - Type-crop matching (0.8-1.3x)

### 3. SoilDegradationSystem.dm
**Purpose**: Model realistic soil depletion and recovery

**Core Degradation Functions**:
- `GetNutrientDemand(crop_name)` - Returns [N, P, K] depletion amounts
  - Leafy (lettuce, spinach): N-heavy (20, 5, 8)
  - Root (potato, carrot): K-heavy (8, 10, 20)
  - Fruit (tomato, pepper): P-heavy (10, 18, 15)
  - Grain (wheat, corn): Balanced (15, 12, 12)

- `GetFertilityLossOnHarvest(turf/T, crop_name)` - Fertility penalty
  - Normal: -15 fertility
  - Good rotation: -5 fertility (33% penalty)
  - Monoculture: -35 fertility (233% penalty)

- `DepleteSoilOnHarvest(turf/T, crop_name, harvest_quality)` - Apply harvest degradation
  - Depletes fertility + crop-specific nutrients
  - Updates crop history for rotation detection
  - Call from FarmingIntegration on harvest

- `DepleteSoilWithContinentScaling(turf/T, crop_name, continent_id, quality)` - Continent-specific degradation
  - CONTINENT_PEACEFUL: 1.0x (normal)
  - CONTINENT_CREATIVE: 0.0x (sandbox = no degradation)
  - CONTINENT_COMBAT: 1.5x (harsh PvP conditions)

**Seasonal Degradation Functions**:
- `ApplySeasonalDegradation(turf/T, season)` - Natural nutrient loss
  - Spring/Autumn: -3 F, -2 N, -1 P, -1 K
  - Summer: -5 F, -3 N, -2 P, -2 K (hot/dry)
  - Winter: -1 F, -1 N (dormant)

- `ApplyNaturalFertilityRecovery(turf/T, season)` - Natural recovery
  - Spring: +4 F, +2 N (nitrogen-fixing bacteria)
  - Summer: +2 F, +1 N (active growth)
  - Autumn: +5 F, +3 N, +2 K (leaf fall)
  - Winter: +1 F (minimal)

- `ApplyFallowRecovery(turf/T)` - Rest land to restore soil
  - +20 F, +10 N, +5 P, +8 K
  - Clears crop history (enables rotation bonus)

**Diagnostics**:
- `GetSoilHealthStatus(turf/T)` - Returns "Critical", "Poor", "Fair", "Good", "Excellent"
- `DebugCropDegradation(crop_name)` - Print nutrient demand
- `GetDegradationStatsByContinent()` - Analytics dict by continent

## Integration Checklist

### TODO: Integrate with Existing Systems

#### 1. **FarmingIntegration.dm** (High Priority)
**What**: Call `DepleteSoilOnHarvest()` when crop is harvested

**Where**: In the harvest logic (likely in plant.dm or FarmingIntegration's harvest proc)

**Code Template**:
```dm
// In harvest proc:
if(harvest_amount > 0)
	var/turf/harvest_turf = get_turf(plant)
	DepleteSoilWithContinentScaling(harvest_turf, crop_name, current_continent, quality)
	player << "Soil fertility decreased from repeated harvesting."
```

**Impact**: Makes farming a resource management activity, prevents infinite yield

#### 2. **PlantSeasonalIntegration.dm** (High Priority)
**What**: Include soil property modifiers in growth rate calculation

**Current**: Likely uses season modifiers + skill modifiers
**New**: Add soil pH, nutrient, and moisture modifiers

**Code Template**:
```dm
// In growth rate calculation:
var/growth_rate = base_rate * season_modifier * skill_modifier
var/turf/T = get_turf(plant)
if(T)
	InitializeSoilProperties(T)
	growth_rate *= GetPHGrowthModifier(T)           // 0.9-1.0x
	growth_rate *= GetNutrientYieldModifier(T, crop) // 1.0-2.0x
	growth_rate *= GetMoistureGrowthModifier(T)     // 0.85-1.1x
	growth_rate *= GetCropRotationModifier(T, crop) // 1.05 or 0.90x
```

**Impact**: Good soil → faster growth; poor soil → slower; rotation → faster

#### 3. **SoilSystem.dm** (Low Priority)
**What**: Keep legacy SOIL_BASIC/SOIL_RICH system intact

**Status**: Renamed conflicting procs to `*_Legacy` versions:
- `GetSoilTypeFromFertility_Legacy()`
- `ApplyCompost_Legacy()`
- `GetTurfSoilType_Legacy()`

**Note**: Can eventually deprecate these; currently harmless placeholders

#### 4. **Compost Crafting UI**
**What**: Create recipe or crafting UI for compost production

**Options**:
- Add to CookingSystem.dm as a "crafting" recipe
- Create separate compost crafting UI (similar to furnace)
- Integrate with existing crafting bench

**Materials Available**:
- From FarmingIntegration: Harvest waste on crop harvest
- From hunting: Bone meal when processing animals
- From fishing: Kelp when harvesting water plants

#### 5. **Season Change Hook** (Medium Priority)
**What**: Apply seasonal degradation/recovery when season changes

**Where**: In TimeSystem or DayNight.dm's season change proc

**Code Template**:
```dm
// On season change, for each active farm turf:
for(var/turf/farm_turf in farm_turfs)
	ApplySeasonalDegradation(farm_turf, new_season)
	ApplyNaturalFertilityRecovery(farm_turf, new_season)
```

**Impact**: Simulates natural cycles; prevents infinite farming

#### 6. **Player UI: Soil Status Checker** (Medium Priority)
**What**: Allow players to check soil fertility/nutrients

**Options**:
- Command: `/soil_status` shows current turf's soil
- Item: "Soil test kit" - examine to get report
- Skill: Gardening rank 2+ allows reading soil status

**Output**:
```
Soil Status:
Fertility: 125/200
pH: 6.8 (slightly acidic)
Nitrogen: 45/100
Phosphorus: 55/100
Potassium: 40/100
Moisture: 62%
Last Crop: Tomato
Overall Health: GOOD
```

#### 7. **Compost Bin/Composter Item** (Low Priority)
**What**: Place-able object that accumulates compost

**Mechanics**:
- Players throw waste into bin
- Accumulates compost over time (passive)
- Or: Use crafting system for instant compost

## Testing Checklist

### Unit Tests
- [ ] `InitializeSoilProperties()` creates all vars on first call
- [ ] `GetSoilFertility()` returns 0-200 range
- [ ] `ModifySoilFertility()` clamps to min/max
- [ ] `GetNutrientDemand()` returns correct [N,P,K] for each crop
- [ ] `DepleteSoilOnHarvest()` correctly penalizes monoculture
- [ ] `ApplyCompost()` restores fertility and limits to 5/season
- [ ] `GetCropRotationModifier()` returns +5% for rotation, -10% for monoculture
- [ ] Continent scalars: Peaceful=1.0, Creative=0.0, Combat=1.5

### Integration Tests
- [ ] Plant grows faster in fertile soil
- [ ] Plant grows slower in depleted soil
- [ ] Harvest degrades soil appropriately
- [ ] Compost restores degraded soil
- [ ] Rotation bonus appears after 1 season of different crop
- [ ] Monoculture penalty applies immediately

### Edge Cases
- [ ] New turf without initialized properties
- [ ] Compost application exceeding 5/season
- [ ] Harvest in Sandbox (should not degrade)
- [ ] pH adjustments stay within 6.0-8.0
- [ ] Nutrients clamped to 0-100

## Performance Considerations

- **Lazy initialization**: Turf vars created only on first soil access (minimal overhead)
- **No background loops**: All calculations on-demand (harvest, growth, season change)
- **Clamping built-in**: Prevents extreme values from arithmetic errors
- **Three-continent separation**: Each continent has different rules (no conflicts)

## Constants Added to !defines.dm

```dm
// Soil System Constants
#define SOIL_DEPLETED 0
#define SOIL_BASIC 1
#define SOIL_RICH 2

// Compost Types
#define COMPOST_BASIC 1
#define COMPOST_BONE_MEAL 2
#define COMPOST_KELP 3
```

## Files Modified

1. **!defines.dm** → Added SOIL_* and COMPOST_* constants
2. **dm/SoilSystem.dm** → Renamed legacy functions to `*_Legacy`
3. **Pondera.dme** → Reordered includes (CompostSystem, SoilPropertySystem, SoilDegradationSystem after UnifiedRankSystem)

## Files Created

1. **dm/SoilPropertySystem.dm** (340 lines) → Turf property management
2. **dm/CompostSystem.dm** (253 lines) → Compost crafting/application
3. **dm/SoilDegradationSystem.dm** (313 lines) → Harvest degradation/recovery

## Commit Summary

**Commit**: `5c76eeb` Phase 11b: Soil, composting, and degradation systems
- **Changed**: 7 files
- **Insertions**: 1,145 lines
- **Deletions**: 4 lines
- **Result**: 0/0 errors

## Next Steps (Priority Order)

1. **[HIGH]** Integrate with FarmingIntegration.dm harvest logic
2. **[HIGH]** Integrate with PlantSeasonalIntegration.dm growth rate
3. **[MEDIUM]** Implement season change hook for seasonal degradation/recovery
4. **[MEDIUM]** Create player UI for soil status checking
5. **[LOW]** Create compost crafting recipe/UI
6. **[LOW]** Deprecate legacy SoilSystem functions

## Architecture Notes

### Crop-Specific Nutrient Demand
The system recognizes four crop categories:
- **Leafy** (lettuce, spinach, kale): High nitrogen demand
- **Root** (potato, carrot, turnip): High potassium demand
- **Fruit** (tomato, pepper, cucumber): High phosphorus demand
- **Grain** (wheat, rice, corn): Balanced nutrient demand

### Three-Continent Soil Dynamics
- **CONTINENT_PEACEFUL** (Story): Normal degradation → encourages compost use
- **CONTINENT_CREATIVE** (Sandbox): No degradation → "infinite" farming possible
- **CONTINENT_COMBAT** (PvP): 1.5x degradation → scarce resources, farming as survival strategy

### Rotation Bonus System
- Detects last planted crop via `GetLastCrop()`
- Same crop = -10% yield penalty (monoculture nutrient depletion)
- Different crop = +5% yield bonus (reduces nutrient depletion)
- Players encouraged to diversify crops

### Compost Quality System
- Quality ranges 0.5-1.5 based on gardening skill
- Affects both effectiveness (fertility restore) and material output
- Higher rank gardeners create more potent compost

## Related Systems

- **FarmingIntegration.dm** → Calls soil degradation on harvest
- **PlantSeasonalIntegration.dm** → Applies soil growth modifiers
- **ConsumptionManager.dm** → Food nutrition (affected by soil quality)
- **UnifiedRankSystem.dm** → Gardening skill affects compost quality
- **TimeSystem** → Season changes trigger natural recovery

---

**Phase 11b Status**: ✅ Core systems complete, build verified
**Estimated Integration Time**: 2-3 hours
**Testing Time**: 1-2 hours
