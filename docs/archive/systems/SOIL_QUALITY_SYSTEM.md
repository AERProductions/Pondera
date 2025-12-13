# Soil Quality System - Comprehensive Guide

## Overview

The Soil Quality System expands Pondera's farming ecosystem to include **soil fertility mechanics**. Different soil types provide significant benefits or penalties to crop growth, harvest yields, and food quality. This system connects environmental factors to farming outcomes and creates strategic depth in agricultural planning.

## Soil Types

### Three Tiers of Soil Quality

#### 1. **Depleted Soil** (SOIL_DEPLETED = 0)
- **When**: After excessive monoculture farming (future degradation system)
- **Growth**: 40% slower (1.4× days to harvest)
- **Yield**: 50% lower (half the normal amount)
- **Quality**: 30% lower nutrition when eaten
- **Plantability**: **Cannot plant** - must restore fertility first

#### 2. **Basic Soil** (SOIL_BASIC = 1)
- **When**: Default soil type; normal forest/field soil
- **Growth**: Normal speed (baseline)
- **Yield**: Normal amount (baseline)
- **Quality**: Normal nutrition value
- **Plantability**: ✅ Can plant all crops
- **Use**: Most common soil; suitable for survival farming

#### 3. **Rich Soil** (SOIL_RICH = 2)
- **When**: High fertility areas; improved with composting (future)
- **Growth**: 15% faster (reaches harvest in less time)
- **Yield**: 20% more items harvested
- **Quality**: 15% more nutrition when eaten
- **Plantability**: ✅ Can plant all crops
- **Use**: Prime farming locations; creates food surplus

## Soil Modifiers - Impact Table

### Growth Speed Modifier
How fast crops grow in different soil:

| Soil Type | Days to Harvest | Speed | Use Case |
|-----------|-----------------|-------|----------|
| Depleted | 1.67× normal | 60% | Don't farm here |
| Basic | 1.0× normal | 100% | Standard farming |
| Rich | 0.87× normal | 115% | Quick harvests |

**Example**: Potatoes normally need 14 days
- Basic soil: 14 days
- Rich soil: 12 days (2 days faster!)
- Depleted soil: 23 days (unviable)

### Yield Modifier
How much is harvested in different soil:

| Soil Type | Yield Multiplier | Example: Harvest 5 → Result |
|-----------|-----------------|----------|
| Depleted | 0.5× | 5 → 2-3 items |
| Basic | 1.0× | 5 → 5 items |
| Rich | 1.2× | 5 → 6 items |

**Stacking with Season & Skill**:
- Final yield = base × season × skill × soil × crop_match
- In-season + skill rank 5 + rich soil = 2.1× multiplier!

### Quality Modifier
How nutritious food grown in different soil is:

| Soil Type | Quality Multiplier | Effect on Food |
|-----------|-----------------|----------|
| Depleted | 0.7× | Restores 70% normal nutrition |
| Basic | 1.0× | Normal restoration |
| Rich | 1.15× | Restores 15% more stamina/health |

**Consumed As**: Rich soil potatoes heal more than basic soil potatoes of same type

## Crop-Soil Affinity System

### Crops Have Soil Preferences

Different crops grow better or worse in specific soil types:

#### Root Vegetables (Potato, Carrot, Onion)
- **Prefer**: Rich soil
- **Rich soil bonus**: +10% quality
- **Basic soil penalty**: -5% quality
- **Logic**: Deep roots benefit from nutrient-rich deep soil

#### Berries (Raspberry, Blueberry)
- **Prefer**: Basic soil (natural forest conditions)
- **Basic soil bonus**: +5% quality
- **Rich soil penalty**: -2% (too much nitrogen, less flavor)
- **Logic**: Berries thrive in natural, wild conditions

#### Grains (Wheat, Barley)
- **Prefer**: Rich soil
- **Rich soil bonus**: +10% quality
- **Basic soil penalty**: -5% quality
- **Logic**: Grain crops heavy feeders on soil nutrients

#### Tomato & Pumpkin
- **Adaptable**: Do well in any soil
- **Rich soil bonus**: +5% quality
- **Basic soil penalty**: None
- **Logic**: Versatile crops that adapt

### Affinity Calculation

```
Crop-Soil Quality = base × crop_affinity_bonus
```

**Examples**:
- Potato in rich soil: 1.0 × 1.1 = 1.1 (10% boost)
- Raspberry in rich soil: 1.0 × 0.98 = 0.98 (2% penalty)
- Tomato in basic soil: 1.0 × 1.0 = 1.0 (no penalty)

## Full Harvest Yield Calculation

When harvesting a crop, multiple factors combine:

```
Final Yield = Base Amount 
            × Season Modifier (0.7–1.3)
            × Skill Multiplier (0.5–1.4)
            × Soil Yield Modifier (0.5–1.2)
            × Crop-Soil Affinity (0.95–1.1)
```

### Real World Example: Harvesting 5 Potatoes

**Scenario 1: Autumn (in-season) + Skill Rank 5 + Rich Soil**
```
5 × 1.3 (autumn bonus) × 1.05 (rank 5: 0.5 + 5/10) × 1.2 (rich soil) × 1.1 (potato affinity)
= 5 × 1.3 × 1.05 × 1.2 × 1.1
= 9.1 potatoes → rounds to 9 potatoes!
```

**Scenario 2: Spring (out of season) + Skill Rank 1 + Depleted Soil**
```
5 × 0.7 (out of season) × 0.5 (rank 1) × 0.5 (depleted soil) × 0.95 (affinity penalty)
= 5 × 0.7 × 0.5 × 0.5 × 0.95
= 0.83 potatoes → rounds to 1 potato
```

This creates **dramatic strategic gameplay**: farming in the right season, with good soil, improves yields by 9×!

## Integration with Existing Systems

### ConsumptionManager Integration

The soil system integrates with food quality:

1. **Harvest Food Item**: Created with base quality
2. **Apply Soil Modifier**: Food quality × soil_quality_modifier
3. **Consume Food**: Gain multiplied benefits

**Result**: Rich soil food heals 15% more when eaten

### PlantSeasonalIntegration Integration

Functions updated to accept soil_type parameter:

```dm
// Apply soil modifiers to harvest yields
ApplyHarvestYieldBonus(plant_obj, 5, harvest_skill, SOIL_RICH)
// Returns: 5 × season × skill × soil × affinity

// Get harvest message with soil feedback
GetPlantHarvestMessage(plant_obj, in_season, SOIL_RICH)
// Returns: "The rich soil has greatly improved the harvest!"
```

### FarmingIntegration Integration

Functions updated with soil parameters:

```dm
// Calculate harvest yield considering soil
HarvestCropWithYield(crop_name, skill_level, SOIL_RICH)
// Includes soil yield multiplier in calculation
```

## Future System Expansions

### 1. Soil Degradation System
Track fertility level per turf/garden plot:

```dm
var/turf/fertility = 100   // 0-150 range

// After harvest, fertility decreases
DepleteSoil(soil_type, 5)  // -5 fertility per crop

// Monoculture penalty (same crop depletes faster)
GetCropRotationBonus(last_crop, current_crop)
// Different crops: +5% yield
// Same crop: -10% yield
```

**Gameplay Impact**: Farmers must rotate crops or face declining yields

### 2. Composting System
Restore fertility with collected materials:

**Compost Sources**:
- Crop waste (harvest remnants)
- Animal manure (from future ranching)
- Bone meal (from hunting/butchering)
- Kelp (from coastal fishing)
- Kitchen scraps (from cooking)

**Composting Mechanics**:
```dm
// Create compost from materials
ApplyCompost(soil_type, 20)  // +20 fertility
```

**Gameplay Impact**: Creates resource loops - use crops to feed animals, collect manure, restore soil

### 3. Crop-Specific Paddy Systems
Specialized soil for specialized crops:

**Rice Paddies** (wetland crops):
- Require water source
- Special paddy soil (flooded)
- High water availability bonus
- Seasonal water restrictions

**Desert Soil** (arid adaptation):
- Crops adapted to drought
- Cactus, date palms, hardy vegetables
- Temperature resistance
- Low water need

**Swamp Soil** (wetland crops):
- Peat-based fertility
- Acid-loving plants
- Special mushroom growing

### 4. Agriculture & Settlements
Advanced farming creates new gameplay:

**Farmsteads** (future feature):
- Dedicated plots with managed soil
- Infrastructure for composting
- Tool storage for farming
- Seeds storage for planting
- Irrigation systems

**Agricultural Trading**:
- NPCs buy surplus crops
- Better prices for high-quality food
- Seasonal price variations
- Merchant interest in farming regions

**Settlement Growth**:
- Successful farms attract NPCs
- Villages form in agricultural areas
- Trade routes develop
- Economic systems emerge

## Configuration & Extensibility

### Adding New Soil Types

To add a new soil type (future):

```dm
#define SOIL_SANDY 3

// Add to SOIL_TYPES in SoilSystem.dm
alist(
    SOIL_SANDY = list(
        "name" = "Sandy Soil",
        "growth_modifier" = 0.9,
        "yield_modifier" = 0.8,
        "quality_modifier" = 0.85,
        "fertility" = 80,
        "can_plant" = 1
    )
)

// Add to crop affinity system
if (crop_lower == "watermelon")
    if (soil_type == SOIL_SANDY)
        return 1.15  // Watermelons love sandy soil
```

### Adding Crop Affinities

To add soil preference for new crops:

```dm
/proc/GetCropSoilBonus(crop_name, soil_type)
    // Add new crop case:
    if (crop_lower == "wheat")
        if (soil_type == SOIL_RICH)
            return 1.10  // Wheat loves rich soil
        else
            return 0.95  // Penalty in basic soil
```

## Player Guidance

### How to Identify Soil Quality

**Current Implementation** (Framework):
- Use admin/developer commands to check soil
- Rich areas (old farmsteads) have rich soil
- Depleted areas (over-farmed) have depleted soil

**Future Feature** (Planned):
- Soil examination tools
- Plant health indicators
- NPC farmer advice
- Achievement badges for farming mastery

### Optimal Farming Strategy

1. **Early Game** (Basic Soil):
   - Farm anywhere
   - Focus on learning seasons
   - Build skill rank

2. **Mid Game** (Seeking Rich Soil):
   - Find fertile areas
   - Establish farm base
   - Practice crop rotation
   - Sell surplus to NPCs

3. **Late Game** (Advanced Farming):
   - Maintain multiple farms
   - Implement crop rotation
   - Set up composting (future)
   - Develop trade routes

## API Reference

### Core Functions

#### Soil Type Detection
```dm
GetSoilTypeFromFertility(fertility_level)
    Returns: SOIL_DEPLETED, SOIL_BASIC, or SOIL_RICH
```

#### Modifier Retrieval
```dm
GetSoilModifiers(soil_type)
    Returns: Complete list of modifiers for soil type

GetSoilGrowthModifier(soil_type)
    Returns: Growth speed multiplier (0.6–1.15)

GetSoilYieldModifier(soil_type)
    Returns: Yield multiplier (0.5–1.2)

GetSoilQualityModifier(soil_type)
    Returns: Food quality multiplier (0.7–1.15)
```

#### Crop Affinity
```dm
GetCropSoilBonus(crop_name, soil_type)
    Returns: Affinity multiplier (0.95–1.15)
```

#### Descriptive Functions
```dm
GetSoilName(soil_type)
    Returns: "Rich Soil", "Basic Soil", etc.

GetSoilDescription(soil_type)
    Returns: Player-friendly description

GetSoilReport(soil_type, fertility_level)
    Returns: Detailed fertility report
```

#### Integration Functions
```dm
ApplySoilModifiersToHarvest(plant_obj, base_yield, soil_type)
    Returns: Final yield with soil multiplier

ApplySoilModifiersToQuality(crop_name, base_quality, soil_type)
    Returns: Final quality with soil multiplier

ApplySoilModifiersToGrowthSpeed(plant_obj, base_days, soil_type)
    Returns: Adjusted growth days
```

## Design Philosophy

**The Pondera Way - Soil Connection**:

The soil system embodies Pondera's philosophy of **environmental interconnection**:

1. **Growth is Environmental**: Not all land is equal. Rich soil grows better crops faster.

2. **Quality Matters**: Food grown in rich soil is more nutritious. Players experience the difference when eating.

3. **Strategy is Rewarded**: Planning farm location, timing harvests, rotating crops - these decisions matter.

4. **Resources Create Systems**: Soil fertility enables composting → enables new crops → enables trade networks.

5. **Degradation Forces Adaptation**: Over-farming depletes soil, forcing players to move or improve land.

This creates **emergent gameplay**: players develop farming strategies, establish base territories, trade with NPCs, and shape the world through agricultural decisions.

## Statistics & Balancing

### Yield Comparisons

Out-of-Season Rich Soil vs In-Season Basic Soil:
- Out-of-season season modifier: 0.7
- In-season season modifier: 1.3
- Rich soil yield: 1.2
- Basic soil yield: 1.0

**Ratio**: (0.7 × 1.2) / (1.3 × 1.0) = 0.65

Harvesting out-of-season in rich soil yields **65% as much** as in-season basic soil - worth it for food security but with cost.

### Growth Speed Impact

Growing in rich soil vs depleted soil:
- Rich soil: 0.87× days (15% faster)
- Depleted soil: 1.67× days (40% slower)

**Ratio**: 1.67 / 0.87 = 1.92

Rich soil grows crops **2× faster** than depleted soil!

## Session Integration Notes

This system was created in Session 11 (Farming Expansion Phase), extending:
- Phase 4: ConsumptionManager (25+ food items)
- Phase 5: HungerThirstSystem integration
- Phase 6: FarmingIntegration (harvesting mechanics)
- Phase 7: PlantSeasonalIntegration (seasonal growth)
- **Phase 8: Soil Quality System** ← Current

## Next Steps

1. **Integrate with plant.dm**: Update Grow() procs to use soil modifiers
2. **Add visual feedback**: Show soil quality in plant states
3. **Create management commands**: `check_soil`, `plant_crop`, etc.
4. **Implement degradation** (Optional Phase 9)
5. **Add composting system** (Optional Phase 10)
