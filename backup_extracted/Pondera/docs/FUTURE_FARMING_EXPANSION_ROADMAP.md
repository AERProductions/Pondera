# Future Farming Expansion - Soil to Agriculture

## Vision: From Simple Farming to Complex Agriculture

The soil system creates a foundation for expanding Pondera's farming from simple "pick crops" to a complex agricultural ecosystem.

```
SIMPLE FARMING (Current - Phase 8)
┌─────────────────────────────────────┐
│ Plant → Grow → Harvest → Eat        │
│ Modifiers: Season, Skill, Soil      │
└─────────────────────────────────────┘
           ↓
AGRICULTURAL STRATEGY (Phases 9-11)
┌─────────────────────────────────────────────────────────┐
│ Farm Planning                                            │
│ ├─ Choose crop type                                     │
│ ├─ Select soil quality                                  │
│ ├─ Manage fertility                                      │
│ └─ Rotate crops                                          │
│                                                         │
│ Resource Management                                      │
│ ├─ Harvest → food storage                               │
│ ├─ Waste → composting                                   │
│ ├─ Compost → fertility restoration                      │
│ └─ Cycle → next season                                  │
│                                                         │
│ Economic Systems                                         │
│ ├─ Surplus → trade with NPCs                            │
│ ├─ Specialization → settlement develops                 │
│ ├─ Infrastructure → irrigation, storage                 │
│ └─ Economy → farming communities form                   │
└─────────────────────────────────────────────────────────┘
           ↓
SPECIALIZED AGRICULTURE (Phases 12-15)
┌──────────────────────────────────────────────────────────┐
│ Paddy Systems                                             │
│ ├─ Rice paddies (flooded wetlands)                       │
│ ├─ Water management (dams, canals)                       │
│ ├─ Crop rotation (rice → vegetables)                     │
│ └─ Settlement formation (rice farming communities)       │
│                                                          │
│ Ranching Systems                                          │
│ ├─ Animal husbandry (cattle, chickens, sheep)            │
│ ├─ Pasture management (grass → animal feed)              │
│ ├─ Manure production (→ compost → soil)                  │
│ └─ Economy (meat, leather, wool)                         │
│                                                          │
│ Advanced Composting                                       │
│ ├─ Multiple compost types (bone meal, kelp, manure)     │
│ ├─ Fermentation times (mature compost better)           │
│ ├─ Nutrient-specific composting (N, P, K)               │
│ └─ Crafting (fertilizer recipes)                        │
│                                                          │
│ Specialized Soils                                         │
│ ├─ Sandy soil (water-loving crops)                       │
│ ├─ Clay soil (root crops)                                │
│ ├─ Peat soil (berries, mushrooms)                        │
│ └─ Hybrid soils (mixed properties)                       │
└──────────────────────────────────────────────────────────┘
```

## Phase-by-Phase Roadmap

### Phase 9: Core Integration
**plant.dm Integration**
- Apply soil growth modifiers to Grow() proc
- Pass soil_type to harvest functions
- Add player feedback messages
- **Impact**: Farming becomes soil-aware
- **Estimated time**: 30-40 minutes

### Phase 10: Soil Management
**Soil Degradation System**
- Turf tracks fertility (0-150)
- Harvesting depletes fertility (-5 per crop)
- Monoculture penalty (-5 additional for same crop)
- Soil recovery from depleted → basic
- **Gameplay mechanic**: Farmers must rotate crops or lose fertility
- **Estimated time**: 60 minutes

**Crop Rotation Benefits**
```dm
// Different crop = +5% yield bonus
GetCropRotationBonus(last_crop, current_crop)

// Same crop = -10% yield penalty
// Encourages diverse farming
```

### Phase 11: Composting
**Compost System**
- Collect crop waste, bone meal, animal manure, kelp
- Create compost in dedicated bin
- Mature compost provides fertility restoration

**Compost Sources**:
```dm
crop_waste    = from harvesting (remnants)
bone_meal     = from hunting (butchering kills)
animal_manure = from ranching (future)
kelp          = from fishing (coastal areas)
kitchen_waste = from cooking (recipe byproducts)
```

**Composting Mechanics**:
```dm
// Add to compost bin (takes time to mature)
/obj/compost_bin/proc/AddMaterial(item)
    contents += item
    maturity_timer = 14 days until ready

// Apply compost to soil
ApplyCompost(soil_type, compost_item)
    soil.fertility += 20
    compost_item deleted
```

**Gameplay Impact**: Creates resource cycles - farming feeds people, people create compost, compost grows more food

### Phase 12: Specialized Soils
**Sandy Soil Addition**
```dm
#define SOIL_SANDY 3

SOIL_SANDY = list(
    "name" = "Sandy Soil",
    "growth_modifier" = 0.9,     // Slightly slow
    "yield_modifier" = 0.85,     // Lower yield
    "quality_modifier" = 0.9,    // Less nutrition
    "fertility" = 80,
    "can_plant" = 1,
    "water_retention" = 0.5      // Low water retention
)

// Water-loving crops prefer sandy soil? NO
// Desert crops thrive in sandy soil
GetCropSoilBonus("watermelon", SOIL_SANDY)  // 1.15 (+15%)
GetCropSoilBonus("potato", SOIL_SANDY)      // 0.85 (-15%)
```

**Clay Soil Addition**
```dm
#define SOIL_CLAY 4

SOIL_CLAY = list(
    "growth_modifier" = 1.05,    // Slightly faster
    "yield_modifier" = 1.15,     // Good yield
    "quality_modifier" = 1.1,    // Good nutrition
    "fertility" = 110,           // Between basic and rich
    "water_retention" = 1.5      // Holds water well
)

GetCropSoilBonus("wheat", SOIL_CLAY)        // 1.12 (+12%)
GetCropSoilBonus("root_veggie", SOIL_CLAY)  // 1.08 (+8%)
```

**Soil Distribution by Biome**:
```dm
// Temperate biome: mix of basic and rich
// Desert biome: mostly sandy, some rocky
// Arctic: depleted, poor for farming
// Rainforest: rich, but overgrown (need clearing)
// Swamp: peat soil (for specialized crops)
```

### Phase 13: Paddy Systems
**Rice Paddies**
- Special turf type: `turf/paddy`
- Requires water source adjacent
- Flooded mechanics (visual updates)

```dm
/turf/paddy
    var/water_level = 100    // Needs water
    var/flooded = 1
    var/crops = null
    
    Grow()
        if (water_level <= 0)
            return  // No water, can't grow
        
        if (istype(crops, /obj/Plants/Rice))
            crops.grow()
            water_level -= 0.5  // Water evaporates
```

**Crop Yields in Paddies**:
```dm
rice_paddy_bonus = 1.4      // Rice yields 40% more in paddies
wheat_penalty = 0.7         // Wheat hates water
```

**Paddy Management**:
```dm
// Water source connections
paddy.water_source = dam/pond/river
paddy.water_level = max(0, water_level - evaporation)
paddy.water_level += rainfall_during_rain

// Seasonal water availability
if (season == WINTER && biome == ARCTIC)
    paddy.water_level = 0  // Frozen
```

### Phase 14: Ranching Systems
**Animal Husbandry**
- Livestock produce meat, leather, wool
- Pasture quality affects animal health
- Animal manure provides compost

```dm
/mob/animal
    var/species = "cattle"    // cattle, chicken, sheep
    var/hunger = 100          // Needs grass
    var/health = 100
    var/pasture_quality = 1.0 // Affected by soil
    
    Eat()
        if (pasture_quality < 0.7)
            health -= 5        // Bad pasture = unhealthy animals
        hunger += 20
    
    ProduceManure()
        var/manure = new /obj/compost/manure
        return manure
```

**Pasture Management**:
```dm
/turf/pasture
    var/grass_amount = 100
    var/fertility = 100
    
    GrazeAnimal(animal)
        grass_amount -= animal.size
        if (grass_amount <= 0)
            fertility -= 10    // Overgrazing depletes soil!
```

**Economic Loop**:
```
Farm produces grain
    ↓
Grain feeds animals
    ↓
Animals produce manure
    ↓
Manure becomes compost
    ↓
Compost restores farm soil
    ↓
Better soil = better grain yield
    ↓
More grain to feed more animals
    ↓
Economic growth!
```

### Phase 15: Agricultural Settlements
**Settlement Development**
- Successful farms attract NPCs
- Villages form in fertile regions
- Trade routes develop

```dm
/area/farmstead
    var/fertility_level = 150  // Overall area quality
    var/population = 0         // NPCs attracted
    var/buildings = 0          // Infrastructure
    var/trade_routes = list()  // Connected settlements
    
    UpdatePopulation()
        // Better soil = more NPCs attracted
        if (fertility_level > 120)
            population += 1 per day
        
        // High population = more buildings
        buildings = population / 10
```

**Farmstead Infrastructure**:
```dm
/obj/building/farm_house       // Storage
/obj/building/granary          // Food storage
/obj/building/compost_bin      // Composting
/obj/building/tool_shed        // Farm tools
/obj/building/irrigation_pump  // Water management
/obj/building/market_stand     // Trading
```

**NPC Farmers**:
```dm
/mob/farmer
    var/farm = null
    var/skill = 1  // 1-10 harvesting skill
    
    Work()
        farm.plant_crop(preferred_crop)
        sleep(DAYS(14))  // Wait for growth
        farm.harvest(skill)
        
        // If surplus, trade with merchants
        if (farm.food_surplus > 50)
            merchant.buy_surplus(farm)
```

## Economic System Integration

### Trade Routes
```dm
/settlement/market
    var/list/trade_routes = list()
    var/list/imported_goods = list()
    var/list/exported_goods = list()
    
    // Export surplus crops
    if (crops_produced > consumption)
        export = crops_produced - consumption
        merchant_buys(export)
    
    // Import needed items
    if (crops_needed > production)
        import = crops_needed - production
        merchant_sells(import)
```

### Price Fluctuation
```dm
// Prices based on season and availability
crop_price = base_price × (1 + availability_modifier)

// Abundant season = cheap
// Scarce season = expensive

GetCropPrice(crop_name, season)
    if (IsSeasonForCrop(crop_name))
        return price * 1.2  // 20% markup (in season)
    else
        return price * 3.0  // 200% markup (out of season)
```

### Player Involvement
```dm
// Player can establish trade routes
// Player can farm surplus and become merchant
// Player can influence settlement development
// Player can manage farms through NPCs
```

## Visual & UX Enhancements

### Soil Quality Indicators
```dm
// Visual indicators of soil quality
turf/icon_state = "soil_[quality]"
    // "soil_depleted" = brown, cracked
    // "soil_basic" = dark brown
    // "soil_rich" = dark fertile brown

plant/icon = "plant_[season_state]_[soil_quality]"
    // Out-of-season + depleted = sickly appearance
    // In-season + rich = vibrant appearance
```

### HUD Farming Information
```dm
/obj/HUD/farming_panel
    Shows:
    ├─ Current soil quality
    ├─ Crop in ground and days to harvest
    ├─ Seasonal availability
    ├─ Predicted yield (with modifiers)
    ├─ Composting status
    └─ Trade route information
```

### Feedback Messages
```dm
On planting:
"Planted potato in RICH SOIL - will be ready in 12 days"

On growth update:
"Your potato is growing well in the rich soil"

On maturity:
"Your potato is ready to harvest! Expected 6 potatoes."

On harvest:
"Harvested 6 potatoes from rich soil - excellent quality!"

On consumption:
"You eat a rich soil potato - delicious and nutritious! (12 nutrition)"
```

## Balancing Considerations

### Skill Progression Through Farming
```
Rank 1 Farmer:
  - Yield: base × 0.5
  - 5 plants = 2-3 harvest
  
Rank 5 Farmer:
  - Yield: base × 1.05
  - 5 plants = 5 harvest
  
Rank 10 Farmer:
  - Yield: base × 1.4
  - 5 plants = 7 harvest
  
With Rich Soil Bonus:
  - Rank 1 → 2.4 (×1.2)
  - Rank 5 → 6 (×1.2)
  - Rank 10 → 8.4 (×1.2)
```

### Economic Balance
```
Starting player:
  - Basic soil farm produces 5-6 food/week
  - Enough for survival with other food sources
  - Takes effort to accumulate surplus
  
Mid-game player:
  - Rich soil farm produces 10-12 food/week
  - Can trade surplus for better equipment
  - Economic opportunity emerges

Experienced player:
  - Multiple farms with rotation
  - 30+ food/week production
  - Becomes major NPC trading partner
  - Can support settlement development
```

## Integration with Existing Systems

### Biome System
```dm
Temperate biome:
  - Natural soil: basic-rich mix
  - Seasons: moderate
  - Crops: diverse (potato, wheat, berries)
  - NPCs: agricultural communities form

Desert biome:
  - Natural soil: sandy
  - Seasons: extreme heat
  - Crops: desert-adapted (cactus, dates)
  - Challenge: water scarcity
  - NPCs: oasis settlements

Arctic biome:
  - Natural soil: depleted/frozen
  - Seasons: extreme cold
  - Crops: very limited (hardy grains)
  - Challenge: short growing season
  - NPCs: few, difficult farming
```

### Fishing Integration
```dm
// Kelp from fishing → compost ingredient
// Fish meal from processing → high-quality compost
// Coastal farms have access to kelp compost

ApplyCompost(fish_meal_compost)
    // More nutrition-rich than standard compost
    soil.fertility += 25  // vs 20 normal
```

### Hunting Integration
```dm
// Bone meal from butchering → compost
// Predator bones have different properties

bone_meal_basic = from deer
    fertility_boost = 15

bone_meal_predator = from wolf
    fertility_boost = 20  // More nitrogen
```

## Conclusion

The soil system establishes the foundation for a **complex, interconnected agricultural economy** in Pondera. From simple "pick crops" to elaborate farm management, settlement development, and trade routes.

**The Pondera Vision**: A world where farming isn't just food production - it's the basis for civilization, economy, and player agency.

---

**Next Phase**: Phase 9 (plant.dm integration) brings soil into actual gameplay!
