# Soil System Integration Guide

## Quick Reference

### For Harvest Integration in plant.dm

#### Get Soil Type for a Location
```dm
// Option 1: Check turf soil variable (future feature)
var/turf/T = get_turf(src)
var/soil_type = T.soil_type  // Once turfs track soil

// Option 2: Default to basic soil (current)
var/soil_type = SOIL_BASIC
```

#### Apply Soil Modifiers to Harvest

**Original harvest code (no soil):**
```dm
var/final_amount = ApplyHarvestYieldBonus(src, 5, usr:hrank)
```

**Updated harvest code (with soil):**
```dm
var/soil_type = SOIL_BASIC  // Get from turf when ready
var/final_amount = ApplyHarvestYieldBonus(src, 5, usr:hrank, soil_type)
```

### Example Integration Points in plant.dm

#### Vegetable Harvesting
```dm
/obj/Plants/Vegetables/proc/PickV()
    var/soil_type = SOIL_BASIC  // Get from location
    var/harvest_amount = ApplyHarvestYieldBonus(src, 5, usr:hrank, soil_type)
    var/message = GetPlantHarvestMessage(src, IsSeasonForCrop(VegeType), soil_type)
    usr << message
    // Create items with harvest_amount
```

#### Berry Harvesting
```dm
/obj/Plants/Bush/proc/Pick()
    var/soil_type = SOIL_BASIC  // Get from location
    var/harvest_amount = ApplyHarvestYieldBonus(src, 3, usr:hrank, soil_type)
    var/message = GetPlantHarvestMessage(src, IsSeasonForCrop(FruitType), soil_type)
    usr << message
    // Create items with harvest_amount
```

#### Grain Harvesting
```dm
/obj/Plants/Grain/proc/PickG()
    var/soil_type = SOIL_BASIC  // Get from location
    var/harvest_amount = ApplyHarvestYieldBonus(src, 4, usr:hrank, soil_type)
    var/message = GetPlantHarvestMessage(src, IsSeasonForCrop(GrainType), soil_type)
    usr << message
    // Create items with harvest_amount
```

### Growth Speed Integration

#### Modify Growth Duration by Soil
```dm
// Original growth code (no soil)
var/growth_days = 14

// Updated with soil modifier
var/soil_type = SOIL_BASIC
var/adjusted_days = ApplySoilModifiersToGrowthSpeed(src, growth_days, soil_type)
// Rich soil: 12 days (15% faster)
// Basic soil: 14 days (normal)
// Depleted soil: 23 days (40% slower)
```

## Constants

### Soil Type Constants
```dm
#define SOIL_DEPLETED 0   // Can't plant, 40% slower growth, 50% lower yield
#define SOIL_BASIC 1      // Normal conditions
#define SOIL_RICH 2       // 15% faster growth, 20% better yield
```

## Soil Modifier Multipliers

### For Quick Reference When Coding

**Growth Modifiers** (days_to_harvest / modifier):
- SOIL_DEPLETED: 0.6 (1.67× longer)
- SOIL_BASIC: 1.0 (baseline)
- SOIL_RICH: 1.15 (15% faster)

**Yield Modifiers** (harvest_amount × modifier):
- SOIL_DEPLETED: 0.5 (half yield)
- SOIL_BASIC: 1.0 (baseline)
- SOIL_RICH: 1.2 (20% more items)

**Quality Modifiers** (food_value × modifier):
- SOIL_DEPLETED: 0.7 (70% nutrition)
- SOIL_BASIC: 1.0 (baseline)
- SOIL_RICH: 1.15 (15% more nutrition)

## Message System

### Using Harvest Messages with Soil Feedback

```dm
// Get harvest message that includes soil quality info
var/message = GetPlantHarvestMessage(plant_obj, in_season, soil_type)

// Messages will include:
// "The rich soil has greatly improved the harvest!"
// "The basic soil provided adequate growing conditions."
// "The depleted soil yielded poor results."
```

## Future Turf Integration

When turfs have soil variables (Phase 9):

```dm
var/turf/T = get_turf(src)

// Check soil fertility
if (T.fertility <= 0)
    soil_type = SOIL_DEPLETED
else if (T.fertility >= 120)
    soil_type = SOIL_RICH
else
    soil_type = SOIL_BASIC

// Deplete soil after harvest (monoculture penalty)
if (T.fertility)
    T.fertility -= 5

// Restore soil with compost (future)
T.fertility = min(150, T.fertility + 20)
```

## Crop-Soil Affinity Examples

### Root Vegetables Prefer Rich Soil
```dm
// Potato in rich soil: bonus 10%
var/potato_bonus = GetCropSoilBonus("potato", SOIL_RICH)  // Returns 1.10

// Carrot in basic soil: penalty 5%
var/carrot_penalty = GetCropSoilBonus("carrot", SOIL_BASIC)  // Returns 0.95
```

### Berries Prefer Basic (Natural) Soil
```dm
// Raspberry in basic soil: bonus 5%
var/raspberry_bonus = GetCropSoilBonus("raspberry", SOIL_BASIC)  // Returns 1.05

// Blueberry in rich soil: penalty 2%
var/blueberry_penalty = GetCropSoilBonus("blueberry", SOIL_RICH)  // Returns 0.98
```

### Grains Love Rich Soil
```dm
// Wheat in rich soil: bonus 10%
var/wheat_bonus = GetCropSoilBonus("wheat", SOIL_RICH)  // Returns 1.10
```

## Configuration Changes

### To Change Soil Modifier Values

**File**: `dm/SoilSystem.dm`

**For Yield** (currently 0.5-1.2 range):
```dm
SOIL_RICH = list(
    "yield_modifier" = 1.3,  // Changed from 1.2 to 30% bonus
    ...
)
```

**For Growth Speed** (currently 0.6-1.15):
```dm
SOIL_RICH = list(
    "growth_modifier" = 1.20,  // Changed from 1.15 to 20% faster
    ...
)
```

**For Quality** (currently 0.7-1.15):
```dm
SOIL_DEPLETED = list(
    "quality_modifier" = 0.5,  // Changed from 0.7 to 50% less nutrition
    ...
)
```

### To Add Crop Affinity

**File**: `dm/SoilSystem.dm`, `GetCropSoilBonus()` function

```dm
/proc/GetCropSoilBonus(crop_name, soil_type)
    var/crop_lower = lowertext(crop_name)
    
    // Add new crop:
    if (crop_lower == "newcrop")
        if (soil_type == SOIL_RICH)
            return 1.12  // 12% bonus in rich soil
        else if (soil_type == SOIL_BASIC)
            return 0.98  // 2% penalty in basic
    
    return 1.0  // Default no bonus/penalty
```

## Testing Soil System

### Manual Testing Commands (for future admin system)

```dm
// Check soil type
/admin/cmd/check_soil
    var/turf/T = get_turf(usr)
    var/soil = GetSoilTypeFromFertility(T.fertility)
    usr << "Soil: [GetSoilName(soil)], Fertility: [T.fertility]"

// Test harvest yield
/admin/cmd/test_harvest
    var/yield = HarvestCropWithYield("potato", 5, SOIL_RICH)
    usr << "Harvest yield: [yield]"

// Test food quality
/admin/cmd/test_quality
    var/quality = GetConsumableQuality("potato", usr)
    usr << "Potato quality: [quality]"
```

## Performance Notes

- **Soil lookups**: O(1) hash table access - no performance concern
- **Crop affinity**: Simple switch/if statements - negligible cost
- **Growth recalculation**: Done once at planting - no frame-to-frame cost
- **Harvest calculation**: Done once at harvest time - no frame-to-frame cost

**Recommendation**: Soil system has **zero performance impact** once integrated. Safe to use everywhere.

## Phase Progression

| Phase | System | Status |
|-------|--------|--------|
| 4 | ConsumptionManager | ✅ Complete |
| 5 | HungerThirstSystem Integration | ✅ Complete |
| 6 | FarmingIntegration | ✅ Complete |
| 7 | PlantSeasonalIntegration | ✅ Complete |
| **8** | **Soil Quality System** | **✅ Complete** |
| 9 | plant.dm Integration | ⏳ Next |
| 10 | Soil Degradation (Optional) | 📋 Planned |
| 11 | Composting System (Optional) | 📋 Planned |

