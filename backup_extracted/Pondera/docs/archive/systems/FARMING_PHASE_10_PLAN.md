# Farming Phase 10: Soil Management Implementation Plan

## Current State Analysis

**What Exists** (Frameworks):
- ✅ SoilSystem.dm: Soil types (BASIC/RICH/DEPLETED) with modifiers
- ✅ FarmingIntegration.dm: Crop growth and harvest yield calculation
- ✅ PlantSeasonalIntegration.dm: Seasonal growth modifiers
- ✅ CONSUMABLES registry: All food items with seasonality

**What's Missing** (To Implement):
- ❌ Soil fertility tracking per turf (actual numbers, not just types)
- ❌ Soil degradation (fertility loss on harvest)
- ❌ Composting system (compost production and application)
- ❌ Soil property management (pH, nutrients, moisture)
- ❌ Compost crafting recipe

---

## Phase 11b Scope: Farming Phase 10

### 1. Turf-Based Soil Properties (SoilPropertySystem.dm)

**Add to turf/soil**:
```dm
var/fertility = 100         // 0-200 scale (0=depleted, 100=basic, 150+=rich)
var/ph_level = 7.0          // pH 6.0-8.0 (affects nutrient availability)
var/nitrogen = 50           // N-P-K macro nutrients (0-100 each)
var/phosphorus = 50
var/potassium = 50
var/moisture = 60           // % moisture (affects growth rate)
var/last_crop = ""          // Previous crop (for rotation bonus)
var/last_harvest_cycle = 0  // Tick when last harvested
```

**Property ranges**:
- **Fertility 0-50**: SOIL_DEPLETED (60% growth, 50% yield)
- **Fertility 51-120**: SOIL_BASIC (100% growth, 100% yield)
- **Fertility 121-200**: SOIL_RICH (115% growth, 120% yield)

- **pH 6.0-6.5**: Acidic (10% slower growth, herbs prefer this)
- **pH 6.5-7.5**: Neutral (normal growth) ← IDEAL
- **pH 7.5-8.0**: Alkaline (10% slower growth, root crops prefer this)

- **NPK (nitrogen/phosphorus/potassium)**:
  - High N (>75): +15% leafy growth, -10% root growth
  - High P (>75): +10% fruit production, +5% quality
  - High K (>75): +10% disease resistance, better storage
  - Deficiency (<30): -20% yield

- **Moisture**:
  - <40%: -15% growth (too dry)
  - 40-70%: Normal growth
  - 70%+: +10% growth (wet conditions preferred by root crops)

### 2. Composting System (CompostSystem.dm)

**Compost Production**:
Craft from harvest waste/refuse:
```
Recipe: "compost"
Ingredients: 1x harvest_waste OR 5x vegetable_scraps OR 3x bone_meal OR 2x kelp
Output: 1x compost (quality varies 0.5-1.5)
Time: 30 seconds
XP: +5 gardening rank
```

**Compost Properties** (when applied):
- Restores fertility: +30 per compost applied
- Adds nutrients: +15 nitrogen, +10 phosphorus, +5 potassium
- Improves pH: ±0.5 toward neutral
- Max applied: 5 compost per plot per cycle (diminishing returns)

**Compost Quality**:
- Bone meal compost: High phosphorus (good for fruits)
- Kelp compost: High potassium (good for root crops)
- Vegetable compost: Balanced nutrients
- Basic waste: Lower quality, smaller bonuses

### 3. Soil Degradation (on Harvest)

**Fertility Loss Per Harvest**:
- Base depletion: -15 fertility per harvest
- Mitigated by crop rotation: -10 if different crop than last (5% bonus too)
- Worsened by monoculture: -20 if same crop (10% yield penalty)

**Nutrient Depletion**:
- Leafy crops (lettuce, spinach): -20 N, -5 P, -5 K
- Root crops (potato, carrot): -10 N, -5 P, -20 K
- Fruits (tomato, pepper): -10 N, -15 P, -15 K
- Grains (wheat, corn): -20 N, -10 P, -10 K

**Example Flow**:
```
Initial soil: fertility=150 (SOIL_RICH), N/P/K=50/50/50
Plant lettuce
Grow 3 days
Harvest lettuce
→ Fertility: 150 - 15 = 135 (still RICH)
→ N: 50 - 20 = 30 (below 50 = -10% yield next time!)
→ Last crop set to "lettuce"

Next planting:
→ If plant lettuce again: monoculture -20% yield
→ If plant carrot instead: rotation +5% yield bonus
```

### 4. Growth Modifier Integration

**Update ApplySeasonalGrowthModifier()** to include soil:

```dm
growth_modifier = season_modifier 
                × skill_modifier 
                × soil_fertility_modifier    // 0.6 to 1.15
                × ph_modifier                // 0.9 to 1.0
                × nutrient_modifier          // 0.8 to 1.2
                × moisture_modifier          // 0.85 to 1.1
```

Example:
```
Base growth: 3 days (spring lettuce)
Season: 1.0 (optimal)
Skill: 1.1 (gardening rank 2)
Soil: RICH (1.15)
pH: 6.8 (1.0, neutral)
NPK: N=30 (-10% yield next), P=50 (normal), K=50 (normal) → 0.97
Moisture: 60% (normal) → 1.0

Final growth: 3 × 1.0 × 1.1 × 1.15 × 1.0 × 0.97 × 1.0 = 3.67 days
```

### 5. Harvest Yield Modifier Update

**Current**: `yield = base × season × skill × soil`

**New**: `yield = base × season × skill × soil × rotation × nutrient`

```dm
var/soil_mod = GetSoilYieldModifier(T.fertility)
var/rotation_mod = GetCropRotationBonus(T.last_crop, crop_name)
var/nutrient_mod = GetNutrientYieldModifier(crop_name, T.nitrogen, T.phosphorus, T.potassium)

final_yield = base_yield * season * skill * soil_mod * rotation_mod * nutrient_mod
```

---

## Implementation Files

### New Files (3):
1. **SoilPropertySystem.dm** (350 lines)
   - Turf soil property definitions
   - Getters/setters for pH, nutrients, moisture
   - Soil state calculations (fertility → soil type)

2. **CompostSystem.dm** (300 lines)
   - Compost crafting recipe integration
   - Compost application logic
   - Quality calculations

3. **SoilDegradationSystem.dm** (200 lines)
   - Harvest degradation calculation
   - Nutrient depletion tracking
   - Crop rotation detection

### Modified Files (3):
1. **SoilSystem.dm**
   - Link to new property system
   - Update modifiers to use real turf properties

2. **FarmingIntegration.dm**
   - Add property checks to growth/yield calculations
   - Call degradation system on harvest

3. **PlantSeasonalIntegration.dm**
   - Include soil property modifiers in growth rate

---

## Success Criteria

✅ Turf soil properties persist per-turf (serialized on map save)  
✅ Fertility affects crop growth rate visibly (faster in rich soil)  
✅ Nutrients affect yield (visible production changes)  
✅ Compost crafting recipe works  
✅ Soil degrades on harvest (richsoil becomes basic over time)  
✅ Crop rotation detected (different crop bonus, same crop penalty)  
✅ Soil can be replenished (compost application restores fertility)  
✅ Analytics track soil trends (admin dashboard shows soil state)  
✅ Zero build errors after integration  

---

## Timeline

- **Step 1**: SoilPropertySystem.dm (turf vars, getters)
- **Step 2**: CompostSystem.dm (crafting recipe, application)
- **Step 3**: SoilDegradationSystem.dm (degradation on harvest)
- **Step 4**: Integration updates (FarmingIntegration, SoilSystem)
- **Step 5**: Testing + documentation

**Estimated**: 3-4 hours total

---

## Three-Continent Notes

**Story Mode** (Kingdom of Freedom):
- Soil properties available everywhere
- Compost crafting encouraged (quest items)
- Rich soil in Story areas (lush farmland)

**Sandbox Mode** (Creative):
- Soil degradation disabled (infinite farming)
- All soil starts RICH (creative freedom)
- Compost still craftable for atmosphere

**PvP Mode** (Battlelands):
- Soil degrades normally (resource scarcity)
- Compost valuable (strategic advantage)
- Fertilizer raids possible (phase 12)

