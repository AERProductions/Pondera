# Phase 11c Integration Test Plan

## Overview
Post-implementation validation of Phase 11c systems (BuildingMenuUI, LivestockSystem, AdvancedCropsSystem, SeasonalEventsHook).

**Target**: Verify all systems compile, load without errors, and integrate with existing Pondera systems.

---

## Test Categories

### 1. BuildingMenuUI Integration Tests

#### 1.1 Recipe System
- [ ] BUILDING_RECIPES database initializes correctly
- [ ] All 5 starter recipes load without errors
- [ ] Recipe filtering by skill level works (GetUnlockedBuildings)
- [ ] Recipe affordability checks work (GetAffordableBuildings)
- [ ] Resource display shows correct inventory counts

#### 1.2 Deed Permission Integration
- [ ] DoBuildingPlacement checks deed permissions correctly
- [ ] CanPlayerBuildAtLocation integration works
- [ ] Building placement fails in non-owned deed zones
- [ ] Building placement succeeds in owned deed zones

#### 1.3 Skill & XP Integration
- [ ] UpdateRankExp called on successful build
- [ ] XP amounts match recipe.skill_bonus values
- [ ] Rank progression unlocks new buildings via skill checks

#### 1.4 Material Consumption
- [ ] ConsumeBuildingMaterials removes correct items from inventory
- [ ] Material cost matches recipe.materials list
- [ ] Building fails if insufficient materials
- [ ] Materials refunded on placement failure (placeholder)

#### 1.5 UI/Verb Integration
- [ ] "Build" verb appears in player actions
- [ ] OpenBuildingMenu displays grid correctly
- [ ] Recipe selection triggers DoBuildingPlacement
- [ ] Building success messages display to player & world

---

### 2. LivestockSystem Integration Tests

#### 2.1 Animal Spawning
- [ ] SpawnLivestock() creates animals at correct location
- [ ] Animal types (cow/chicken/sheep) initialize correctly
- [ ] Age stages update based on age_ticks
- [ ] Initial hunger_level set appropriately

#### 2.2 Lifecycle Loop
- [ ] StartLifecycle background process runs without blocking
- [ ] Aging tick increments every cycle
- [ ] Age stages transition correctly (newborn→young→adult→old)
- [ ] Icon/behavior changes with age stage

#### 2.3 Feeding Mechanics
- [ ] FeedAnimal accepts food items from inventory
- [ ] Hunger_level restores after feeding
- [ ] Happiness increases on successful feed
- [ ] Preferred foods grant double happiness bonus
- [ ] Non-preferred foods grant single bonus

#### 2.4 Production System
- [ ] ProduceProduct generates items at correct intervals
- [ ] Product quality affected by happiness (0.5-1.5x)
- [ ] Product quality affected by hunger (0.7-1.2x)
- [ ] Seasonal modifiers applied to quality
- [ ] Products placed at animal location

#### 2.5 Breeding Mechanics
- [ ] BreedAnimal checks compatibility (same species)
- [ ] Requires happiness >60, hunger >50
- [ ] Season-dependent success rates: Spring 80%, Summer 70%, Autumn 50%, Winter 20%
- [ ] GiveBirth creates offspring with correct type
- [ ] Gestation periods vary by species (Cow 15d, Chicken 5d, Sheep 12d)
- [ ] Offspring inherit parent happiness traits

#### 2.6 Death & Slaughter
- [ ] DieOfStarvation triggers at hunger 0
- [ ] Meat corpse left at location
- [ ] SlaughterAnimal returns meat + hide + bones
- [ ] Player receives correct item counts

#### 2.7 UI Integration
- [ ] Click animal shows status (age, happiness, hunger, production)
- [ ] GetAnimalStatus returns correct formatted text
- [ ] Breed verb appears for nearby animals
- [ ] Animal moves reflect in world

---

### 3. AdvancedCropsSystem Integration Tests

#### 3.1 Crop Database
- [ ] ADVANCED_CROPS loads all 22 crops
- [ ] Each crop has complete data (name, icon, seasons, grow_time, etc.)
- [ ] GetCropData returns correct entry
- [ ] Crop variants accessible via GetCropVariants

#### 3.2 Planting & Validation
- [ ] CanPlantCrop checks season correctly
- [ ] Season gating prevents out-of-season planting
- [ ] Turf type validation works (commented out, needs integration)
- [ ] Soil validation passes for farmable soil

#### 3.3 Companion Planting
- [ ] GetCompanionBonus detects adjacent crops (placeholder)
- [ ] Three Sisters detection: Corn + Beans + Squash = 1.20x
- [ ] Nitrogen fixation detection: Legumes + Staples = 1.15x
- [ ] Returns 1.0 when no companions present

#### 3.4 Soil Matching
- [ ] GetSoilCropBonus matches soil type to crop
- [ ] Acidic soil bonus for potatoes (+ 15%)
- [ ] Rich soil bonus for corn (+ 20%)
- [ ] Loamy soil bonus for wheat (+ 15%)
- [ ] Returns 0.8-1.3x multiplier

#### 3.5 Yield Calculation
- [ ] CalculateAdvancedYield applies all modifiers
- [ ] Formula: base × season × skill × soil × companion × weather
- [ ] Season modifiers: Spring 1.0x, Summer 1.2x, Autumn 1.1x, Winter 0.5x
- [ ] Skill bonus: +15% per gardening rank (0.0-1.5x)
- [ ] Weather placeholder applies correctly
- [ ] Final yield is reasonable (not negative, not infinite)

#### 3.6 Harvest Integration
- [ ] HarvestAdvancedCrop integrates with FarmingIntegration.dm
- [ ] Calls GetCropData for crop info
- [ ] Applies all yield modifiers
- [ ] Awards gardening XP on harvest
- [ ] Soil fertility modified on harvest

---

### 4. SeasonalEventsHook Integration Tests

#### 4.1 Event Triggering
- [ ] ProcessSeasonalEvents called on season change
- [ ] Detects current season from global.season
- [ ] Routes to correct OnSeason*() proc

#### 4.2 Spring Event
- [ ] OnSeasonSpring broadcasts announcement
- [ ] Modulation points set (crop_growth_modifier = 1.15)
- [ ] Admin players receive confirmation message
- [ ] Statistics reset for new season

#### 4.3 Summer Event
- [ ] OnSeasonSummer broadcasts announcement
- [ ] Peak production modifiers applied
- [ ] Breeding season active with 70% success rate
- [ ] Food prices affected by modulation
- [ ] Consumption rate increased (integrated later)

#### 4.4 Autumn Event
- [ ] OnSeasonAutumn broadcasts announcement
- [ ] Soil recovery modifiers applied (1.25x)
- [ ] Harvest yield bonus applied (1.10x)
- [ ] Breeding success rate at 50%

#### 4.5 Winter Event
- [ ] OnSeasonWinter broadcasts announcement
- [ ] Crop growth disabled (0.0x)
- [ ] Breeding nearly impossible (5% success)
- [ ] Animal production reduced (-40%)
- [ ] Food prices spike (+50%)

#### 4.6 Statistics Tracking
- [ ] IncrementSeasonalStat records event impacts
- [ ] GetSeasonalStats returns accumulated data
- [ ] ResetSeasonalStats clears counters on new season
- [ ] Admin commands test_spring/summer/autumn/winter work

#### 4.7 Integration Hooks
- [ ] Documented integration points clear
- [ ] TODO comments explain what to integrate
- [ ] DayNight.dm hook location identified
- [ ] ConsumptionManager.dm hook identified
- [ ] LivestockSystem.dm hook identified
- [ ] Plant.dm hook identified
- [ ] HungerThirstSystem.dm hook identified

---

## Test Execution Strategy

### Phase 1: Static Analysis (Already Done ✅)
- ✅ Compile test: 0 errors, 0 warnings
- ✅ All procs have valid DM syntax
- ✅ All database structures populate

### Phase 2: Unit Tests (Next)
- Test each system in isolation
- Verify core functions work
- Check database initialization

### Phase 3: Integration Tests
- Test systems talking to each other
- Verify deed/recipe/skill integration
- Check seasonal event modulation

### Phase 4: End-to-End Tests
- Player builds structure
- Player breeds animals
- Player plants crops
- Seasons change and trigger events

---

## Success Criteria

✅ All 4 systems compile without errors
✅ No runtime crashes on first load
✅ Players can execute "Build" verb
✅ Building menu displays correctly
✅ Deed permissions block/allow building
✅ Animals spawn and age correctly
✅ Crops store data correctly
✅ Seasonal events broadcast messages
✅ All integration points documented

---

## Known Limitations (Documented)

- Companion planting: Placeholder, needs plant tracking system integration
- DMI icons: Temporary fire icons, need custom animal/building graphics
- Global modulation: Undefined globals commented out, integration needed
- Turf type checking: Removed, needs terrain system integration

---

## Next Steps After Integration Tests Pass

1. Commit integration test results
2. Begin Phase 12: Market Economy Enhancements
   - Expand DynamicMarketPricingSystem
   - NPC merchant interactions
   - Supply/demand curves
3. Phase 13: PvP/Raiding Mechanics
4. Phase 14: Story Progression System

