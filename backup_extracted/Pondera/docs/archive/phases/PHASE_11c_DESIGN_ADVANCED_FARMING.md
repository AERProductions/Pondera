# Phase 11c Design: Advanced Farming & Original Building Vision
**Duration**: 5-7 days | **Commits**: 4 | **Code**: 1200-1500 lines | **Build Status Target**: 0/0 errors

---

## Overview

Phase 11c realizes your **original building system vision** while expanding farming mechanics with **livestock, advanced crops, and seasonal engagement**. This phase integrates deeply with existing time/season/weather systems to create an enduring, interconnected farming experience.

**Core Philosophy**: Players interact with building and farming **daily**. Systems must be fun, engaging, and rewarding long-term.

---

## Architecture

### New Systems (4 Files)

#### 1. **BuildingMenuUI.dm** (350 lines) - Your Original Vision
**Purpose**: Grid-based building interface with visual previews and skill progression

**Key Features**:
- 4x5 grid layout showing unlocked buildings
- Icon previews (64x64 DMI images)
- Skill requirements color-coded (green=achievable, yellow=challenging, red=locked)
- Locked recipes grayed out with lock icon
- Inline resource cost display
- Hover tooltips with full requirements
- Right-click context menu for rotation (0°/90°/180°/270°)
- Filter buttons (All/Unlocked/Affordable)
- Real-time player resource display (Stone, Wood, Metal)

**Data Structure**:
```dm
/datum/building_recipe
	var/recipe_name           // "wooden_door", "stone_foundation", etc.
	var/display_name          // "Wooden Door"
	var/icon_file             // 'dmi/64/buildings.dmi'
	var/icon_state            // "wooden_door"
	var/building_type         // /obj/Buildable/Doors/LeftDoor
	var/required_skill        // "brank" (building rank)
	var/required_skill_level  // 1-5
	var/materials             // list("stone" = 10, "wood" = 15)
	var/rotation_allowed      // TRUE/FALSE
	var/placement_radius      // Distance from player (default 1)
	var/description           // "A sturdy wooden entrance"
	var/skill_bonus           // XP awarded on completion
```

**Proc Signatures**:
```dm
proc/OpenBuildingMenu(mob/players/player)
	// Main entry point - displays grid UI

proc/GetUnlockedBuildings(mob/players/player)
	// Returns list of buildings player can see

proc/CanAffordBuilding(mob/players/player, recipe)
	// Check if player has resources

proc/DoBuildingPlacement(mob/players/player, recipe, rotation)
	// Handle deed permissions and placement

proc/RegisterBuildingRecipe(recipe_name, recipe_datum)
	// Global registry of all building recipes
```

**Integration Points**:
- Checks `CanPlayerBuildAtLocation()` before placement
- Awards XP to `brank` on successful placement
- Consumes materials from player inventory
- Updates deed zone on placement

---

#### 2. **LivestockSystem.dm** (400 lines) - Animals & Breeding
**Purpose**: Cows, chickens, sheep with seasonal breeding, feeding, and production

**Key Features**:
- Three animal types: Cow, Chicken, Sheep
- Placement requires enclosure/pen (building)
- Feeding mechanics (consumes crops/hay)
- Breeding cycles tied to seasons
- Production systems (milk, eggs, wool)
- Happiness/health mechanics
- Slaughter mechanics (meat/hides)
- Audio/visual feedback (mooing, clucking, etc.)

**Animal Types**:
```dm
/obj/animal
	var/animal_type           // "cow", "chicken", "sheep"
	var/age                   // Days old (0-1825, max lifespan 5 years)
	var/happiness             // 0-100 (fed, housed, company)
	var/hunger_level          // 0-100 (fed = 100, starving = 0)
	var/production_level      // 0-100 (readiness to produce)
	var/last_produced         // Timestamp of last production
	var/last_fed              // Timestamp of last feeding
	var/breeding_cooldown     // Ticks until can breed again
	var/pregnant              // Cooldown ticks if pregnant (cow: 2500, chicken: 750)
	var/production_time       // Ticks between production (cow: daily, chicken: 2x daily)

// Cow: Produces milk (restores 25 hunger, 10 nutrition)
// Chicken: Produces eggs (restores 15 hunger, 5 nutrition)
// Sheep: Produces wool (crafting material, 3-5 per shearing)
```

**Breeding Mechanics**:
- Requires: 2+ animals, happiness > 60, fed > 50
- Season-dependent:
  - Spring: Optimal (80% success)
  - Summer: High (70% success)
  - Autumn: Medium (50% success)
  - Winter: Low (20% success)
- Gestation period:
  - Cow: 15 days → newborn calf
  - Chicken: 5 days → chick (matures in 10 days)
  - Sheep: 12 days → lamb (matures in 15 days)
- Offspring inherits parent happiness/genes

**Production System**:
- Cow produces milk once per day (if fed, happy > 50)
- Chicken produces eggs twice per day (if fed, happy > 50)
- Sheep produces wool when sheared (right-click animal)
- Production quality affected by:
  - Animal happiness (0.5-1.5x multiplier)
  - Nutrition level (0.7-1.2x multiplier)
  - Season quality (spring/summer bonus)

**Feeding Mechanics**:
- Right-click animal → "Feed"
- Consumes food from player inventory
- Preferred foods:
  - Cow: Hay, grain, vegetables (prefers grain, 2x happiness)
  - Chicken: Seeds, grain, scraps (prefers seeds)
  - Sheep: Grass, hay, clover (prefers clover, 2x happiness)
- Starvation: Animals lose 5 hunger/day, die at 0 hunger

**Death/Slaughter**:
- Starving animals die (corpse can be harvested)
- Player can slaughter (right-click → "Slaughter", requires knife)
- Returns: Meat (hunger 50), Hide (crafting), Bones (compost)

**Proc Signatures**:
```dm
proc/SpawnLivestock(location, animal_type)
	// Create new animal at location

proc/FeedAnimal(animal, food_item)
	// Consume food, restore hunger, adjust happiness

proc/ProduceAnimalProduct(animal)
	// Generate milk/eggs/wool based on stats

proc/BreedAnimals(animal1, animal2)
	// Check compatibility, create offspring if successful

proc/SlaughterAnimal(animal, slaughterer)
	// Kill animal, return products
```

**Integration Points**:
- Animals placed in deed-controlled areas respects permissions
- Food consumption linked to `ConsumptionManager.dm`
- Offspring link to calendar for aging
- Happiness modulates quality (ties to crafting quality system)

---

#### 3. **AdvancedCropsSystem.dm** (300 lines) - Crop Variety & Mechanics
**Purpose**: 20+ crops with variants, companion planting, and advanced mechanics

**Crop Database**:
```dm
/proc/InitializeAdvancedCrops()
	global.ADVANCED_CROPS = list(
		"wheat" = list(
			"name" = "Wheat",
			"seasons" = list("Spring", "Summer", "Autumn"),
			"grow_time" = 1200,      // Ticks
			"hunger_value" = 30,
			"companions" = list("barley", "rye"),  // Bonus with these
			"soil_preference" = "loamy",
			"nutrition" = list("n" = 15, "p" = 5, "k" = 10),
			"base_yield" = 3,        // Average harvest
		),
		"corn" = list(
			"name" = "Corn",
			"seasons" = list("Summer", "Autumn"),
			"grow_time" = 1500,
			"hunger_value" = 35,
			"companions" = list("beans", "squash"),  // "Three Sisters"
			"soil_preference" = "rich",
			"nutrition" = list("n" = 20, "p" = 8, "k" = 5),
			"base_yield" = 4,
		),
		// ... 18 more crops (potatoes, carrots, beans, flax, hops, etc.)
	)
```

**Crop Types** (20+ total):
- **Staples** (8): Wheat, Barley, Rye, Corn, Oats, Millet, Rice, Sorghum
- **Vegetables** (6): Potatoes, Carrots, Turnips, Onions, Beets, Cabbage
- **Legumes** (4): Beans, Peas, Lentils, Chickpeas
- **Fibers** (2): Flax, Hemp
- **Specialty** (4): Hops, Saffron, Vanilla (seasonal variants)

**Companion Planting Bonus**:
- "Three Sisters" (Corn + Beans + Squash): +20% yield
- "Nitrogen Fixation" (Beans + Legumes): +15% soil nitrogen
- Incompatible crops: -25% yield (monoculture penalty)
- Formula: `final_yield = base × season_quality × skill × soil × companion_bonus × rotation_penalty`

**Advanced Mechanics**:
- **Crop Variants**: Early/Mid/Late season versions
  - Early corn: Shorter grow time, lower yield
  - Late corn: Longer grow time, higher yield
  - Useful for planning harvests across seasons

- **Intercropping**: Plant multiple crops same turf (different heights)
  - Tall: Corn, sunflower
  - Medium: Beans, peas
  - Short: Carrots, onions, turnips
  - Bonus yield when mixed properly

- **Soil-Crop Matching**:
  - Wheat prefers loamy soil (+15% yield)
  - Potatoes prefer acidic soil (+15% yield)
  - Corn prefers rich soil (+20% yield)

- **Weather Integration**:
  - Rain increases growth (normal growth + 10%)
  - Drought decreases growth (50% growth rate)
  - Snow kills frost-sensitive crops (corn, beans)

**Proc Signatures**:
```dm
proc/GetCropData(crop_name)
	// Return crop database entry

proc/CanPlantCrop(turf/T, crop_name, season)
	// Check if season/soil/permissions allow

proc/GetCompanionBonus(list/crops_on_turf)
	// Calculate companion planting multiplier

proc/HarvestAdvancedCrop(turf/T, mob/players/harvester)
	// Calculate yield with all modifiers applied
```

**Integration Points**:
- Leverages existing `FarmingIntegration.dm` for season checks
- Uses `SoilPropertySystem.dm` for soil matching
- Calls `FarmingIntegration.HarvestCropWithYield()` for final harvest
- Awards XP to gardening rank

---

#### 4. **SeasonalEventsHook.dm** (150 lines) - World Events & Engagement
**Purpose**: Season transitions trigger meaningful world events

**Seasonal Events**:
```dm
// Spring (Month: Adar, Nisan, Iyar)
OnSeasonSpring()
	// Planting Festival announcement
	// Increased crop growth rates (+15%)
	// Seed vendors appear in towns
	// Breeding season for livestock

// Summer (Month: Sivan, Tammuz, Av)
OnSeasonSummer()
	// Harvest begins
	// Food prices drop (abundance)
	// High animal production
	// Heat affects consumption

// Autumn (Month: Elul, Tishrei, Cheshvan)
OnSeasonAutumn()
	// Final harvest push
	// Preservation season (drying, canning)
	// Soil recovery increases
	// Animal products higher quality

// Winter (Month: Kislev, Tevet, Shebat)
OnSeasonWinter()
	// Scarcity increases food prices
	// Animal production drops
	// No crop growth outdoors
	// Survival challenge (hunger increases)
```

**Event Mechanics**:
- Triggered on month change (check in time.dm)
- World announcement to all players
- Statistic tracking (crops planted, harvests, animals bred)
- Cosmetic changes (ambient effects, NPC behavior)

**Integration Hooks** (placeholders for season system):
```dm
// In DayNight.dm, add:
if(new_month != last_month)
	ProcessSeasonalEvents()

// In plant.dm growth loop, add:
if(season == "Summer")
	growth_rate *= 1.15  // Summer bonus
```

---

## Implementation Plan

### Phase 1: BuildingMenuUI.dm (Day 1-2)
1. Create grid layout structure
2. Build recipe database initialization
3. Implement grid display UI
4. Add filter system (All/Unlocked/Affordable)
5. Implement click handlers and rotation
6. Integration with deed permission system
7. Resource consumption on placement
8. Test with existing buildings

**Validation**:
- ✅ Grid displays correctly
- ✅ Icons load and display
- ✅ Skill requirements show color-coded
- ✅ Locked recipes grayed out
- ✅ Placement respects deed zones
- ✅ Resources consumed correctly

### Phase 2: LivestockSystem.dm (Day 2-3)
1. Create animal object hierarchy
2. Implement feeding mechanics
3. Add production system (milk/eggs/wool)
4. Implement breeding system
5. Add slaughter mechanics
6. Integration with food consumption
7. Happiness/health display
8. Test breeding cycles

**Validation**:
- ✅ Animals spawn correctly
- ✅ Feeding restores hunger
- ✅ Production generates items
- ✅ Breeding creates offspring
- ✅ Happiness affects quality
- ✅ Starvation kills animals

### Phase 3: AdvancedCropsSystem.dm (Day 3-4)
1. Create crop database (20+ crops)
2. Implement companion planting logic
3. Add crop variant system
4. Integrate with existing harvest
5. Implement soil-crop matching
6. Add weather integration
7. Test yield calculations
8. Validate season gates

**Validation**:
- ✅ All 20+ crops exist in database
- ✅ Companion planting bonuses apply
- ✅ Variants work correctly
- ✅ Soil matching affects yields
- ✅ Season gates prevent out-of-season
- ✅ Weather modulates growth

### Phase 4: SeasonalEventsHook.dm (Day 4-5)
1. Create event trigger system
2. Implement all 4 seasonal events
3. Add world announcements
4. Create stat tracking
5. Integration with time system
6. Add cosmetic effects (ambient)
7. Test event firing on month change
8. Polish and documentation

**Validation**:
- ✅ Events fire on season change
- ✅ Announcements broadcast correctly
- ✅ Stats track properly
- ✅ No performance impact

### Phase 5: Integration & Testing (Day 5-7)
1. Update Pondera.dme with new includes
2. Run full build test
3. Test deed integration (building placement)
4. Test livestock with food system
5. Test crops with soil/season systems
6. Test seasonal events
7. Documentation and cleanup
8. Final commit

---

## Data Integration

### Building System Integration
```dm
// In BuildingMenuUI.dm placement:
if(!CanPlayerBuildAtLocation(player, build_location))
	player << "You don't have permission to build here."
	return FALSE

new building_type(build_location)
player.character.UpdateRankExp("brank", 10)  // Award XP
```

### Farming System Integration
```dm
// In AdvancedCropsSystem.dm harvest:
var/yield = HarvestAdvancedCrop(T, harvester)
// Integrates with SoilPropertySystem modifiers
// Integrates with FarmingIntegration yield calculation
// Returns: base × season × skill × soil × companion
```

### Livestock & Food Integration
```dm
// In LivestockSystem.dm feeding:
FeedAnimal(animal, food_item)
	animal.hunger_level = min(100, animal.hunger_level + food_item.nutrition)
	animal.happiness = min(100, animal.happiness + 5)
	// Uses CONSUMABLES registry for food values
```

### Time/Season Integration
```dm
// Hook in DayNight.dm or time.dm:
proc/ProcessSeasonalEvents()
	if(global.season == "Spring")
		OnSeasonSpring()
		// All players see: "The Spring Festival begins!"
		// Crop growth +15%
		// Breeding season activated
```

---

## File Changes Summary

### New Files (4)
- `dm/BuildingMenuUI.dm` (350 lines)
- `dm/LivestockSystem.dm` (400 lines)
- `dm/AdvancedCropsSystem.dm` (300 lines)
- `dm/SeasonalEventsHook.dm` (150 lines)

### Modified Files (2)
- `Pondera.dme`: Add includes for 4 new files (after UnifiedRankSystem.dm, before mapgen)
- `!defines.dm`: Add animal constants if needed (optional)

### Integration Hooks (Documentation)
- `DayNight.dm`: Add seasonal event call (no code change)
- `time.dm`: Reference for season change trigger
- `plant.dm`: Already integrates with seasons
- `ConsumptionManager.dm`: Already has food registry

---

## Success Criteria

✅ **Build**: 0/0 errors on clean compile
✅ **Building Menu**: Grid displays, icons load, filters work, placement respects deeds
✅ **Livestock**: Animals breed, produce, have happiness system, starve if not fed
✅ **Advanced Crops**: 20+ crops plantable, companions work, soil/season integration
✅ **Seasonal Events**: Fire on season change, announce to all players, modulate systems
✅ **Integration**: All systems work together (building + farming + livestock + seasons)
✅ **Performance**: No lag spikes, background processes don't block main thread
✅ **Documentation**: All procs documented, integration points clear

---

## Timeline

| Day | Phase | Deliverable |
|-----|-------|-------------|
| 1-2 | BuildingMenuUI | Grid UI fully functional, deed integrated |
| 2-3 | LivestockSystem | Animals spawn, feed, breed, produce |
| 3-4 | AdvancedCropsSystem | 20+ crops, companions, soil matching |
| 4-5 | SeasonalEventsHook | Events fire, announce, modulate systems |
| 5-7 | Integration & Test | Full system test, documentation, commit |

---

## Commits

**Commit 1**: BuildingMenuUI.dm (Day 2)
**Commit 2**: LivestockSystem.dm (Day 3)
**Commit 3**: AdvancedCropsSystem.dm + SeasonalEventsHook.dm (Day 4)
**Commit 4**: Integration, testing, documentation (Day 7)

---

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Compilation errors | Iterative building after each system |
| Performance impact | Use background = 1 for long-running loops |
| Deed zone conflicts | Test extensively with CanPlayerBuildAtLocation() |
| Season gating bugs | Log season transitions for debugging |
| Animal starvation spam | Cap event messages, use quiet mechanics |

---

## Your Original Vision: Realization

### Building Grid Menu Features (From Your Requirement)
✅ Grid panels showing unlocked buildings
✅ Click on picture of item in menu
✅ Build in front of player (respects deed zones)
✅ Visual previews (64x64 DMI icons)
✅ Skill progression shown (color-coded)
✅ Locked recipes grayed out
✅ Rotation selection (right-click menu)
✅ Resource costs inline

### Advanced Farming Integration
✅ Livestock with breeding cycles
✅ 20+ crops with variants
✅ Seasonal engagement hooks
✅ Integration with existing time/season systems
✅ Interconnected survival loop

---

## Ready to Implement

All systems designed to work together. Building UI is foundation, livestock adds life to farms, crops provide food/materials, seasonal events drive engagement.

Your dream building system + advanced farming ecosystem = enduring gameplay loop.

**Let's build this!** 🚀
