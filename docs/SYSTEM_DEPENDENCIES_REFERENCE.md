# Phase 8: System Dependencies & Integration Reference

**Status**: Phase 8 Enhancement  
**Purpose**: Document critical system dependencies for developers and operators  
**Audience**: Development team, system administrators, future maintainers  

---

## Critical System Dependencies

### Tier 1: Foundation (Required First)

```
TIME SYSTEM (TimeSave.dm)
  ↓ depends on: [None - first to load]
  ↓ required by: All other systems (time-based logic, maintenance cycles, seasonal systems)
  ↓ failure impact: CRITICAL - Game time broken, all time-dependent systems fail
  
Components:
  • world.time tracking (global tick counter)
  • time_of_day variable (DAY=1 or NIGHT=2)
  • TimeLoad() - Load from save file
  • TimeStore() - Periodic persistence
  • StartPeriodicTimeSave() - Background saver (10h intervals)
  
Validation:
  ✓ FinalizeInitialization() checks: time_of_day in list(1, 2)
  ✓ Critical failure if invalid → world_initialization_complete = FALSE
```

### Tier 2: World Infrastructure (Depend on Time System)

```
CONTINENTS (WorldSystem.dm + MultiWorldConfig.dm)
  ↓ depends on: Time system (required)
  ↓ required by: Map generation, NPC placement, weather, deed system
  ↓ failure impact: HIGH - No game world available
  
Components:
  • 3 continents: STORY, SANDBOX, PVP
  • Per-continent rules: allow_pvp, allow_building, allow_stealing
  • Spawn points for each continent
  • Continental climate zones
  
Initialization:
  • InitializeContinents() called at tick 0 (PHASE 2)
  • RegisterInitComplete("infrastructure") at tick 50
  
WEATHER SYSTEM (WeatherController.dm + WeatherParticles.dm)
  ↓ depends on: Time system, Continents
  ↓ required by: Consumption (affects food availability), Day/night (affects visibility)
  ↓ failure impact: MEDIUM - Weather effects optional but affect gameplay
  
Components:
  • Dynamic weather cycles (rain, wind, thunder)
  • Temperature effects (affects NPC behavior, player consumption)
  • Weather particles and visual effects
  • Seasonal weather patterns
  
Initialization:
  • InitWeatherController() at tick 0
  • DynamicWeatherTick() at tick 5
  • Runs background loop every 100 ticks
  
MAP GENERATION (mapgen/backend.dm + mapgen/biome_*.dm)
  ↓ depends on: Time system, Continents, Weather
  ↓ required by: Player movement, building, resource placement
  ↓ failure impact: CRITICAL - No playable terrain
  
Components:
  • Procedural terrain generation (perlin noise)
  • Lazy chunk loading (10x10 turf chunks)
  • Per-biome resource placement (trees, rocks, water)
  • Chunk persistence (saved to MapSaves/Chunk_*.sav)
  
Initialization:
  • GenerateMap(15, 15) at tick 20 (initial generation)
  • GrowBushes() at tick 25 (initial resource seeding)
  • GrowTrees() at tick 30 (initial resource seeding)
  • Lazy loading on first turf access thereafter
  
DEED SYSTEM (DeedDataManager.dm + DeedPermissionSystem.dm)
  ↓ depends on: Time system, Map generation
  ↓ required by: Building permissions, zone enforcement
  ↓ failure impact: MEDIUM - Deed system optional but affects territory control
  
Components:
  • Deed registry (all deed zones in world)
  • Deed ownership tracking
  • Permission assignment (per-player access)
  • Maintenance processor (monthly payment cycle)
  
Initialization:
  • InitializeDeedDataManagerLazy() at tick 50 (lazy init - only if deeds exist)
  • RegisterInitComplete("deed_system") at tick 55
  • StartDeedMaintenanceProcessor() at tick 40 (background loop)
```

### Tier 3: Visual Systems (Depend on Infrastructure)

```
DAY/NIGHT & LIGHTING (ShadowLighting.dm + AnimateDayNight loop)
  ↓ depends on: Time system (uses time_of_day), Continents (world must exist)
  ↓ required by: Player visibility, mob behavior (some only active at night)
  ↓ failure impact: MEDIUM - Players can still play with flat lighting
  
Components:
  • time_of_day-based overlay transitions
  • Procedural spotlight generation for light sources
  • Client-side lighting plane (created on player login)
  • Global day/night cycle animation
  
Initialization:
  • Day/night animation loop starts at tick 50 (PHASE 3)
  • Client lighting planes created via client/draw_lighting_plane()
  • RegisterInitComplete("lighting") at tick 50
  
Critical Integration:
  • Lighting planes created PER CLIENT on Login()
  • world-level animation loop independent of clients
  • Uses global time_of_day variable (set by TimeLoad)
```

### Tier 4: Special Worlds (Depend on Core Infrastructure)

```
STORY WORLD (StoryWorldIntegration.dm + TownSystem.dm)
  ↓ depends on: Infrastructure (Continents, Map, Time)
  ↓ required by: Quest gameplay, NPC interactions
  ↓ failure impact: LOW - Story world optional; other continents still playable
  
Components:
  • Per-continent town generation
  • NPC spawning and dialogue
  • Quest gates and progression
  • Story-specific item drops
  
Initialization:
  • InitializeTownSystem() at tick 50
  • InitializeStoryWorld() at tick 100
  • RegisterInitComplete("special_worlds") at tick 300
  
SANDBOX WORLD (SandboxSystem.dm)
  ↓ depends on: Infrastructure (Continents, Map, Time)
  ↓ required by: Creative mode gameplay
  ↓ failure impact: LOW - Sandbox optional
  
Components:
  • Creative building (unlimited resources)
  • No hunger/thirst survival mechanics
  • All recipes unlocked
  • Friendly NPC interactions
  
Initialization:
  • InitializeSandboxSystem() at tick 150
  • RegisterInitComplete("special_worlds") at tick 300
  
PvP WORLD (PvPSystem.dm + TerritoryClaimSystem.dm)
  ↓ depends on: Infrastructure (Continents, Map, Time, Deed system)
  ↓ required by: Territory warfare, raiding mechanics
  ↓ failure impact: LOW - PvP optional; other continents still playable
  
Components:
  • Territory claiming system
  • Raiding mechanics (CanRaid + ExecuteRaid)
  • Kingdom treasuries and material exchanges
  • Combat progression tracking
  
Initialization:
  • InitializePvPSystem() at tick 200
  • RegisterInitComplete("special_worlds") at tick 300
  • Enhanced in Phase 8: Added stamina checks, combat level integration
  
MULTI-WORLD (MultiWorldIntegration.dm)
  ↓ depends on: Story + Sandbox + PvP worlds
  ↓ required by: Cross-continental travel, shared skill progression
  ↓ failure impact: MEDIUM - Affects player progression sharing
  
Components:
  • Per-player continent positions (saved on travel)
  • Skill sharing configuration (which skills persist across continents)
  • Recipe sharing configuration
  • Knowledge topic sharing
  
Initialization:
  • InitializeMultiWorldSystem() at tick 250
  • RegisterInitComplete("special_worlds") at tick 300
```

### Tier 5: Game Systems (Depend on Special Worlds)

```
CHARACTER PROGRESSION (UnifiedRankSystem.dm + CharacterData.dm)
  ↓ depends on: Character data initialization (Tier 4)
  ↓ required by: Skill unlocks, recipe discovery, combat mechanics
  ↓ failure impact: HIGH - Skills/progression broken
  
Components:
  • 8 skill types (fishing, crafting, mining, smithing, building, gardening, woodcutting, digging, carving, sprout-cutting, smelting, pole)
  • Max level 5 per skill
  • Experience accumulation per skill
  • Level-up triggers (skill-based recipe unlocks)
  
Integration Points:
  • ItemInspectionSystem uses "crank" (crafting rank)
  • PvPSystem uses global.player_combat_level
  • CookingSystem quality affected by cooking rank
  • RecipeState tracks discovered recipes
  
Initialization:
  • InitializePhase4System() at tick 300 (character data setup)
  • Skills are part of datum/character_data
  • Ranks stored in character.frank, character.crank, etc.
  
NPC SYSTEM (NPCCharacterIntegration.dm)
  ↓ depends on: Character progression, Recipe system
  ↓ required by: Quest progression, recipe teaching
  ↓ failure impact: MEDIUM - NPCs still spawn but can't teach
  
Components:
  • Unified NPC type system
  • Recipe teaching mechanics
  • Knowledge topic teaching
  • NPC rank levels (same as player ranks)
  
Initialization:
  • InitializeNPCRecipeSystem() at tick 350
  • InitializeNPCRecipeHandlers() at tick 360
  • RegisterInitComplete("npc_recipes") at tick 380
  
RECIPE SYSTEM (CookingSystem.dm + ItemInspectionSystem.dm)
  ↓ depends on: Character progression, NPC system
  ↓ required by: Cooking, crafting, item inspection
  ↓ failure impact: HIGH - Can't cook or craft
  
Components:
  • RECIPES global registry
  • CONSUMABLES global registry
  • Dual unlock system: skill-based OR inspection-based
  • Quality system (ingredient + skill quality)
  
Initialization:
  • InitializeRecipes() early in CookingSystem setup
  • ItemInspectionSystem connects to UnifiedRankSystem
  • InitializeSkillRecipeSystem() at tick 375
  • RegisterInitComplete("npc_recipes") at tick 380
  
ITEM INSPECTION (ItemInspectionSystem.dm)
  ↓ depends on: Character progression, Recipes
  ↓ required by: Recipe discovery, item analysis
  ↓ failure impact: MEDIUM - Inspection optional, skills still unlock recipes
  
Components:
  • Item metadata attachment (recipe_id, difficulty)
  • Inspection difficulty calculation
  • Success chance calculation (crafting skill + perception)
  • Experience reward system
  
Integration:
  • GetPlayerCraftingSkill() uses UnifiedRankSystem.GetRankLevel("crank")
  • AwardPlayerExperience() calls character.UpdateRankExp()
  • Unlocks recipes via recipe_state.DiscoverRecipe()
  
Initialization:
  • InitializeItemInspectionSystem() at tick 379
  • BuildItemRecipeMap() initializes recipe connections
  • RegisterInitComplete("economy") at tick 390
```

### Tier 6: Economic Systems (Depend on Game Systems)

```
CURRENCY SYSTEM (DualCurrencySystem.dm)
  ↓ depends on: Character data (for currency_system datum)
  ↓ required by: All trading, market transactions
  ↓ failure impact: HIGH - No economy possible
  
Components:
  • Lucre (story mode, non-tradable)
  • Stone, Metal, Timber (PvP mode, tradable)
  • Currency type definitions (datum/currency_type)
  • Per-player currency balance tracking
  
Initialization:
  • InitializeCurrencyForPlayer() called on player creation
  • InitializeDualCurrencySystem() at tick 377
  • Currencies stored in player.currency_system
  
MARKET SYSTEM (MarketTransactionSystem.dm + MarketStallUI.dm)
  ↓ depends on: Currency system, Character data
  ↓ required by: Player-to-player trading
  ↓ failure impact: MEDIUM - Market trading optional
  
Components:
  • Market stalls (placed by players)
  • Transaction processing
  • Profit tracking (stall_profits → character.stall_profits)
  • Daily profit settlements
  
Initialization:
  • InitializeMarketTransactionSystem() at tick 375
  • InitializeMarketStallUI() at tick 382
  • RegisterInitComplete("economy") at tick 390
  
DYNAMIC PRICING (DynamicMarketPricingSystem.dm)
  ↓ depends on: Market system, Currency system
  ↓ required by: Price calculation, supply/demand balancing
  ↓ failure impact: LOW - Pricing optional (hardcoding fallback)
  
Components:
  • Commodity registry (goods with supply/demand)
  • Price calculation (elasticity, volatility, tier)
  • Price history tracking
  • Economic events (temporary price modifiers)
  
Initialization:
  • InitializeDynamicMarketPricingSystem() at tick 380
  • InitializeBaseCommodities() populates initial commodities
  • MarketUpdateLoop() at tick 383 (background pricing updates)
  • RegisterInitComplete("economy") at tick 390
  
DEED ECONOMY (DeedEconomySystem.dm)
  ↓ depends on: Deed system, Currency system, Market system
  ↓ required by: Deed transfers, rentals, valuations
  ↓ failure impact: MEDIUM - Deed economy optional
  
Components:
  • Deed transfer system (ownership sales)
  • Rental agreements (temporary access)
  • Deed valuation (market-based pricing)
  • Transaction history logging
  
Integration:
  • Uses deed_token for property reference
  • Uses currency_system for price transfers
  • Logs all transactions for audit trail
  
Initialization:
  • InitializeDeedEconomySystem() at tick 385
  • RegisterInitComplete("economy") at tick 390
  
MATERIAL EXCHANGE (KingdomMaterialExchange.dm)
  ↓ depends on: Currency system, Multi-world system
  ↓ required by: Kingdom-to-kingdom trading
  ↓ failure impact: MEDIUM - Kingdom trading optional
  
Components:
  • Kingdom treasuries (per-continent material storage)
  • Trade offers (negotiable, time-expiring)
  • Material conversion rates
  • Trade history per kingdom
  
Initialization:
  • InitializeKingdomMaterialExchange() at tick 378
  • RegisterInitComplete("economy") at tick 390
```

---

## Initialization Sequence Verification

### Expected Startup Timeline

```
Tick   0: Time system loads → world time restored
Tick   5: Crash recovery detects orphaned players
Tick  10: Crash recovery completes
Tick  15: Dynamic zones initialize
Tick  20: Map generation begins (procedural terrain)
Tick  25: Bush growth (initial seeding)
Tick  30: Tree growth (initial seeding)
Tick  35: Periodic time save starts
Tick  40: Deed maintenance processor starts
Tick  50: Infrastructure phase completes
Tick  50: Continents, weather, zones ready
Tick  50: Deed system lazy init (if needed)
Tick  50: Day/night cycle animation starts
Tick  50: Town system initialization
Tick 100: Story world initialization
Tick 150: Sandbox system initialization
Tick 200: PvP system initialization
Tick 250: Multi-world system initialization
Tick 300: Phase 4 character data system
Tick 300: Special worlds phase completes
Tick 350: NPC recipe system
Tick 360: NPC recipe handlers
Tick 370: Skill level-up integration
Tick 375: Skill recipe system
Tick 375: Market transaction system
Tick 376: Currency display UI
Tick 377: Dual currency system
Tick 378: Kingdom material exchange
Tick 379: Item inspection system
Tick 380: Dynamic market pricing
Tick 381: Treasury UI system
Tick 382: Market board UI
Tick 383: Market board update loop
Tick 384: Inventory management extensions
Tick 385: Deed economy system
Tick 384: Recipe discovery rate balancing
Tick 390: Economy phase completes
Tick 395: Quality of life phase completes
Tick 400: Initialization finalization
       → world_initialization_complete = TRUE
       → Players can log in
```

### Critical Failure Points

```
If Time System fails:
  ✗ All time-based logic broken (maintenance, seasonal, day/night)
  ✗ Result: CRITICAL - game unplayable

If Map Generation fails:
  ✗ No terrain available
  ✗ Player movement impossible
  ✗ Result: CRITICAL - game unplayable

If Character Data initialization fails:
  ✗ No character progression
  ✗ No skill tracking
  ✗ Result: HIGH - gameplay severely affected

If Currency System fails:
  ✗ No economy
  ✗ Trading impossible
  ✗ Result: HIGH - economy broken

If any Tier 1 system fails:
  ✗ Phase 2 cannot complete
  ✗ All dependent systems fail
  ✗ Result: CRITICAL - world unplayable

If any Tier 2 system fails:
  ✗ Specific features broken
  ✗ Game may still be playable with reduced functionality
  ✗ Result: HIGH/MEDIUM - depends on system

If Tier 3+ systems fail:
  ✗ Optional features unavailable
  ✗ Game still playable with core mechanics
  ✗ Result: MEDIUM/LOW - cosmetic or optional
```

---

## System Dependency Validation

### FinalizeInitialization() Checks (PHASE 8 Enhancement)

```dm
Critical Validations:
  ✓ time_of_day in list(1, 2)      [TIME SYSTEM]
  ✓ world.maxx >= 100 && world.maxy >= 100  [MAP GENERATION]
  ✓ g_deed_registry initialized     [DEED SYSTEM]
  ✓ g_deed_owner_map initialized    [DEED SYSTEM]

Phase Completion Checks:
  ✓ "time" phase complete
  ✓ "infrastructure" phase complete
  ✓ "deed_system" phase complete
  ✓ "lighting" phase complete
  ✓ "special_worlds" phase complete
  ✓ "npc_recipes" phase complete
  ✓ "economy" phase complete
  ✓ "quality_of_life" phase complete

Spawn Point Validation:
  ✓ At least 1 spawn point exists in world
  ✓ All spawn points accessible

Failure Handling:
  If critical failure detected:
    → world_initialization_complete = FALSE
    → Player login BLOCKED
    → Admin must restart server
    → Log detailed failure messages
```

---

## Adding New Systems in Future Phases

### Checklist for Phase 9+ System Integration

1. **Create system file** in appropriate directory (dm/, libs/, mapgen/)
2. **Add to Pondera.dme** BEFORE mapgen block and InitializationManager
3. **Create initialization function** following naming convention: `Initialize<SystemName>()`
4. **Register with InitializationManager**:
   - Add `spawn(tick_offset) Initialize<SystemName>()`
   - Add `spawn(tick_offset) RegisterInitComplete("system_name")`
5. **Document dependencies**:
   - Which Tier does this system belong to?
   - What Tier 1-2 systems are required?
   - Add to this reference document
6. **Add validation** in FinalizeInitialization():
   - Check critical variables initialized
   - Log failures appropriately
7. **Test initialization sequence**:
   - Verify call order respected
   - Check dependent systems available
   - Confirm phase completes on time

### Tier Placement Guide

- **Tier 1**: Base systems (time, nothing else should be here)
- **Tier 2**: World infrastructure (continents, weather, map, zones, deeds)
- **Tier 3**: Visual systems (lighting, day/night, weather effects)
- **Tier 4**: Alternative worlds (story, sandbox, pvp, multi-world)
- **Tier 5**: Game systems (progression, NPCs, recipes, crafting, combat)
- **Tier 6**: Economic systems (currency, markets, trading, pricing)
- **Tier 7**: Quality of life (discovery, UI polish, convenience)

---

**Document Version**: 1.0 (Phase 8 Enhancement)  
**Last Updated**: 12/8/25 1:50 pm  
**Repository**: AERProductions/Pondera  
**Branch**: recomment-cleanup
