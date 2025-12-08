# Pondera AI Coding Instructions

**Pondera** is an open-source BYOND survival MMO with procedural terrain, vertical elevation (multi-level gameplay), deed-based territory control, and 3 distinct continents (Story/Sandbox/PvP). Codebase: 150KB+ DM across 85+ system files with binary chunk saves.

## Developer Workflows

### Build & Deployment
- **Build**: VS Code task `dm: build - Pondera.dme` → outputs `Pondera.dmb` (deployable binary)
- **Compile order critical**: `.dme` file controls include sequence; inheritance depends on placement
- **Include placement rule**: New systems go BEFORE `mapgen/` block and `InitializationManager.dm` (these have dependencies on everything else)
- **Initialization gate**: `world_initialization_complete` = FALSE during boot, TRUE after all 5 phases complete (~400 ticks)
  - Phase 1 (0 ticks): Time system loads from `timesave.sav`
  - Phase 1B (5 ticks): Crash recovery detects and respawns orphaned players
  - Phase 2 (50 ticks): Infrastructure—continents, weather, zones, map generation, initial tree/bush growth
  - Phase 2B (55 ticks): Deed system lazy initialization (only if deeds exist)
  - Phase 3 (100 ticks): Day/night & lighting cycles start
  - Phase 4 (300 ticks): Special world systems (towns, story, sandbox, PvP, multi-world)
  - Phase 5 (400 ticks): NPC recipes, skill unlocks, market integration
- **Performance**: world.fps = 40 TPS (25ms per tick); monitor `_debugtimer.dm` frame times
- **Debug logging**: Use `F0laks Debug Messager.dm` functions; check `world.log`
- **Current branch**: `recomment-cleanup` (Phase 4-5 market/economy focus)

### Testing & Debugging
- **Crash recovery**: `InitializeCrashRecovery()` detects stranded players on boot (Phase 1B, 5 ticks)
- **Admin panel**: Use `_AdminCommands.dm` commands for testing; check player status and system state
- **Initialization status**: Call `GetInitializationStatus()` to check boot progress; block gameplay on `world_initialization_complete == FALSE`
- **Savefile integrity**: Check `SavefileVersioning.dm` for breaking changes; increment version when changing variable types in `datum/character_data` or player vars

## Architecture: Big Picture

### 1. **Centralized Initialization** (`dm/InitializationManager.dm`)
Single orchestrator replacing 30+ scattered `spawn()` calls in `_debugtimer.dm` and `SavingChars.dm`:
```dm
proc/InitializeWorld()  // Called from world/New()
proc/RegisterInitComplete(phase_name)  // Called by subsystems when ready
```
**Integration pattern**: Each subsystem calls `RegisterInitComplete()` after setup. Dependencies trigger at specific tick offsets. Player login gated until `world_initialization_complete = TRUE`.

### 2. **Elevation System** (`libs/Fl_ElevationSystem.dm`, `libs/Fl_AtomSystem.dm`)
Multi-level vertical gameplay with decimal elevation levels:
- **`elevel`**: Vertical position (1.0 = ground, 1.5 = stair/ramp transition, 2.0 = second level, etc.)
- **`layer`**: Auto-calculated from `elevel` via `FindLayer(elevel)` (4 layers per elevel); controls visual z-order
- **`invisibility`**: Auto-calculated via `FindInvis(elevel)`; lower elevals invisible from higher viewpoints
- **Interaction range**: `Chk_LevelRange(A)` checks if two objects within ±0.5 levels; required before combat/interaction
- **Elevation objects**: 
  - `elevation/hill`: Climb UP (enter from below, exit upward)
  - `elevation/ditch`: Transition DOWN (enter from above, exit downward)
  - `elevation/stairs`: Multi-directional access
  - All enforce directional enter/exit via `Odir()` (opposite direction)

**Critical gotcha**: Objects at different elevals can't interact unless `Chk_LevelRange()` passes. Ground NPCs can't attack elevated players.

### 3. **Procedural Map Generation** (`mapgen/backend.dm`, `mapgen/biome_*.dm`)
Infinite terrain via 10x10 turf chunks with lazy loading and persistence:
- **Entry**: `GenerateMap(lakes, hills)` spawns `map_generator/water` and `map_generator/temperate` objects
- **Generator loop**: Each generator calls `GetTurfs()` (pick random chunk), then `Generate()` (populate turfs)
- **Per-chunk pipeline**: `EdgeBorder()` (paint borders) → `InsideBorder()` (smooth transitions) → `SpawnResource()` (place biome resources)
- **Chunk files**: `MapSaves/Chunk_X,X-Y,Y.sav` (binary savefiles); chunks loaded on first turf access, never regenerated
- **Biome system**: Each biome (`biome_temperate.dm`, `biome_arctic.dm`, etc.) defines spawn tables with probabilities
  - `SpawnResource()` called per-turf after generation; each biome checks its spawn table
  - Resource types inherit from `obj/Rocks`, `obj/plant/ueiktree`, etc.; can have `growstage` for harvesting

**Pattern**: Newly generated turfs auto-save; subsequent logins load from chunk files (no regeneration). Biome spawn tables control resource distribution.

### 4. **Movement & Sprint System** (`dm/movement.dm`)
Direction-based movement with double-tap sprint activation:
- **Direction vars**: `MN`/`MS`/`ME`/`MW` (held input); `QueN`/`QueS`/`QueE`/`QueW` (queued)
- **Sprint mechanic**: Double-tap same direction within 3 ticks → `Sprinting = 1` → reduced `MovementSpeed`
- **Movement loop**: `MovementLoop()` processes held + queued directions, calls `step()` per tick
- **Speed calculation**: `GetMovementSpeed()` returns tick delay (3 default); lower = faster movement
- **Deed cache invalidation**: `InvalidateDeedPermissionCache(M)` called on every player move to detect zone changes

**Key detail**: Corner-cut detection via `NOCC` flag; diagonal movement blocked if adjacent walls present.

### 5. **Deed System & Territory Control** (`dm/deed.dm`, `dm/DeedPermissionSystem.dm`, `dm/ImprovedDeedSystem.dm`)
Territory ownership with zone-based permission enforcement:
```dm
if(!CanPlayerBuildAtLocation(M, T)) return  // Always gate building
// Also: CanPlayerPickupAtLocation(), CanPlayerDropAtLocation()
```
**Permission model**:
- Deeds claim regions via `/datum/deed` objects (owner, tier, maintenance cost, freeze status)
- Tiers determine zone size: Small (1000 turfs), Medium (2000 turfs), Large (8000 turfs)
- Monthly maintenance cost enforced; non-payment triggers deed freeze (24 hours grace period)
- Permission bits on player: `canbuild`, `canpickup`, `candrop` (set by entering deed regions)
- **Deed maintenance processor**: `StartDeedMaintenanceProcessor()` runs background checks every month

**Critical pattern**: All building/pickup/drop must call permission functions. Deed zones override individual flags.

### 6. **Consumption & Survival Ecosystem** (`dm/ConsumptionManager.dm`, `dm/HungerThirstSystem.dm`, `dm/PlantSeasonalIntegration.dm`)
Survival mechanics linked to seasons, biomes, and temperature:
- **Global registry**: `CONSUMABLES["item_name"]` = [type, nutrition, hydration, stamina, seasons, biomes, quality]
- **Season gating**: Items only harvestable/cookable during growth season (check `CONSUMABLES[item]["seasons"]`)
- **Hunger tick**: Consumption every 15-30 ticks (modulated by temperature; extreme cold/heat increases rate)
- **Temperature integration**: Affects consumption needs; cold/heat increases stamina drain via `HungerThirstSystem.dm`
- **Farming cycle**: Harvest crop → cook recipe (quality %) → consume → restores nutrition/stamina → affects movement speed

**Pattern**: New food? Add to `CONSUMABLES` registry with season/biome/nutrition data. Always check seasons before allowing harvest.

### 7. **Unified Rank System** (`dm/UnifiedRankSystem.dm`, `dm/CharacterData.dm`)
Consolidated skill progression (fishing, crafting, mining, smithing, building, gardening, woodcutting, digging, carving, sprout-cutting, smelting, pole):
```dm
M.GetRankLevel(RANK_FISHING)  // Returns 1-5
M.SetRankLevel(RANK_FISHING, 3)
M.UpdateRankExp(RANK_FISHING, exp_gain)  // Triggers level-up checks
```
**Rank type constants**:
- `RANK_FISHING` = "frank", `RANK_CRAFTING` = "crank", `RANK_MINING` = "mrank", `RANK_SMITHING` = "smirank", etc.
- All ranks stored in `datum/character_data` (created in `mob/players/New()`)
- Max level: 5; experience accumulates per rank; level-up triggers skill-based recipe unlocks

**Adding new rank**: Define `#define RANK_*` constant, add variable to `datum/character_data`, add switch cases to `GetRankLevel()`/`SetRankLevel()`.

### 8. **Recipes & Crafting Discovery** (`dm/CookingSystem.dm`, `dm/RecipeState.dm`, `dm/SkillRecipeUnlock.dm`)
Unified recipe database with dual-unlock (skill + inspection):
- **Global registry**: `RECIPES["recipe_name"]` = [type, ingredients, output, quality_modifier, skill_requirement]
- **Discovery gates**: Recipes unlocked via `CheckAndUnlockRecipeBySkill()` (skill level) OR `ItemInspectionSystem.dm` (examination)
- **Quality system**: Output quality = base + (skill_level * 10%) + (ingredient_quality * modifier); affects nutrition/stats
- **NPC teaching**: `UnlockRecipeFromNPC()` called when NPC teaches; marks recipe as discovered in `player.character.recipe_state`
- **Recipe state**: `/datum/recipe_state` tracks discovered recipes + knowledge topics per player

**Integration points**: Add recipe to `RECIPES`, link skill discovery in `SkillRecipeUnlock.dm`, add consumable to `CONSUMABLES` registry.

### 9. **Equipment & Overlays** (`dm/CentralizedEquipmentSystem.dm`, `dm/EquipmentOverlayIntegration.dm`, `dm/EquipmentOverlaySystem.dm`)
Real-time visual rendering of worn armor/weapons with overlay icons:
- **Equipment slots**: Head, chest, hands, feet, back, waist, accessories
- **Equipped flags**: 30+ slot flags (Wequipped=weapon, Aequipped=armor, Sequipped=shield, TWequipped=two-hand, etc.)
- **Overlay rendering**: Worn items display via overlay icons on character; icon_state must match layer (usually 100-level)
- **Equipment checks**: Before equipping, validate armor AC/weapon damage integration
- **Persistence**: Equipped items saved/loaded via `SavingChars.dm` character data

**Pattern**: New armor/weapon? Extend `obj/items`, integrate via overlay system, add AC/damage stats.

### 10. **Three-Continent Architecture** (`dm/WorldSystem.dm`, `dm/MultiWorldConfig.dm`, `dm/MultiWorldIntegration.dm`)
Separate game modes with distinct rules and player progression sharing:
- **Story (Kingdom of Freedom)**: Procedural towns, NPCs, quests, PvE progression
  - `allow_pvp=0, allow_building=1, monster_spawn=1, npc_spawn=1`
  - Uses "Lucre" currency (non-tradable quest rewards)
  - Progression gates unlock story areas
- **Sandbox (Creative Sandbox)**: Peaceful creative building, all recipes unlocked, no pressure
  - `allow_pvp=0, allow_building=1, monster_spawn=0, npc_spawn=0`
  - Hunger/thirst disabled; no deed costs
  - Designed for builders and economy testing
- **PvP (Battlelands)**: Competitive survival with raiding, permadeath risk, territory wars
  - `allow_pvp=1, allow_stealing=1, allow_building=1, monster_spawn=1`
  - Uses tradable materials (stone, metal, timber)
  - Territory claiming via `/datum/territory_claim`

**Access pattern**: Continents stored in `continents["story"]`, `continents["sandbox"]`, `continents["pvp"]` dictionary. Gate gameplay systems per continent rules at login.

### 11. **NPC & Recipe Teaching System** (`dm/npcs.dm`, `dm/NPCRecipeHandlers.dm`, `dm/NPCRecipeIntegration.dm`)
NPCs teach recipes/knowledge via dialogue interaction:
- **NPC types**: Blacksmith (smithing), Scholar (general), Fisherman (fishing), Herbalist (cooking/gardening)
- **Recipe teaching**: NPC Click() triggers dialogue; player selects recipe to learn; calls `UnlockRecipeFromNPC()`
- **Knowledge topics**: NPCs teach story/lore topics that unlock hints/recipes
- **Spawner integration**: NPCs linked to spawners via `ownere1`-`ownere4` variables; despawn when spawner removed

**Pattern**: NPC dialogue calls `UnlockRecipeFromNPC()` or `UnlockKnowledgeFromNPC()` with recipe/topic name.

### 12. **Market & Economy Systems** (`dm/DynamicMarketPricingSystem.dm`, `dm/DualCurrencySystem.dm`, `dm/KingdomMaterialExchange.dm`, `dm/MarketBoardUI.dm`)
Supply/demand pricing, dual currencies, and player-driven trading:
- **Dual currency**: 
  - **Lucre** (story): Non-tradable quest rewards, NPC merchants
  - **Materials** (PvP): Tradable stone/metal/timber between kingdoms
- **Price dynamics**: 
  - Elasticity 0.5-2.0 (sensitivity to supply changes)
  - Volatility 0.05-0.5 (price swing per tick)
  - Price bounds prevent extreme inflation/deflation
  - Tech tier (1-5) affects base price
- **Market board UI**: Player-driven item trading interface
- **Kingdom treasury**: Per-kingdom material tracking + trade history
- **Trade offers**: Kingdoms negotiate material trades with expiry and negotiation

**Integration**: Don't hardcode prices—use `DynamicMarketPricingSystem.dm` for all commodity pricing.

## Code Patterns & Conventions

### Variable Naming
- **Temp vars**: `tmp/` prefix (e.g., `tmp/list/_data`)
- **Movement**: `MN`/`MS`/`ME`/`MW` (held), `QueN`/`QueS`/`QueE`/`QueW` (queued)
- **Equipped flags**: 2-letter codes (`W`=weapon, `A`=armor, `S`=shield, `TW`=two-hand, etc.)
- **Global resources**: `SP`/`SPs` (stone), `MP`/`MPs` (metal), `SB`/`SBs` (supply box)
- **Directional**: `dir` = standard direction constant (NORTH, SOUTH, etc.); `Odir()` = opposite
- **Seasons**: Stored as strings ("Spring", "Summer", "Autumn", "Winter") in lists
- **Elevation**: `elevel` (decimal: 1.0, 1.5, 2.0, 2.5), `layer` (visual z-order), `invisibility` (from elevel)

### Async Patterns
- **Background loops**: `set background = 1` + `set waitfor = 0` for non-blocking
- **Delayed execution**: `spawn(ticks)` where ticks = TIME_STEP * deciseconds (e.g., `spawn(5)` = 25ms delay)
- **Infinite loops**: `while(1) { sleep(ticks) }` for repeating background tasks
- **Gate on initialization**: Always check `world_initialization_complete` before using global state
- **Initialization callback**: Call `RegisterInitComplete("name")` after subsystem ready; gates next phases

### Object Hierarchy
```dm
/mob/players          // Main character; inventory, skills, deeds, speed, HP, character datum
/mob/npcs             // Non-player characters; spawner-linked via ownere1-4
/obj/                 // Items, weapons, spawners, screen effects
/turf/                // Procedurally-generated terrain; elevation-aware; soil_health for farming
/area/                // Logical zones (screen_fx, deed regions)
/elevation            // Multi-level objects (hills, ditches, stairs); elevel-based
/datum/character_data // Player persistent data (skills, recipes, deeds, inventory state)
/datum/deed           // Territory claim (owner, tier, maintenance, freeze status)
/datum/continent      // World rules (story/sandbox/pvp flags)
/datum/recipe_state   // Per-player recipe discovery tracking
```

### File Inclusion Order (Pondera.dme)
1. Defines & interfaces (`!defines.dm`, Interfacemini.dmf)
2. Core libs (atom system, elevation system) 
3. Foundation systems (movement, damage, time, persistence)
4. Specialized systems (cooking, farming, deed, equipment, market)
5. NPC & recipe systems
6. Display/UI systems (HUD, inventory, market board)
7. Mapgen & initialization LAST (depend on everything)

**Critical**: Compile order matters for inheritance. Always add new systems BEFORE mapgen and InitializationManager.

## Integration Checkpoints

**Adding new systems?** Follow this sequence:

1. **Create system file**: Place in `dm/`, `libs/`, or appropriate folder
2. **Add to .dme**: Insert `#include "path/file.dm"` BEFORE mapgen block, after related systems
3. **Initialization**: If using global state:
   - Call `RegisterInitComplete("name")` after setup
   - Check `world_initialization_complete` before use
   - Schedule via `spawn(tick_offset)` in `InitializeWorld()`
4. **Items/weapons**: Extend `obj/items`; integrate via `CentralizedEquipmentSystem.dm`
5. **Consumables**: Add to `CONSUMABLES` registry in `ConsumptionManager.dm` (type, nutrition, seasons, biomes)
6. **Recipes**: Add to `RECIPES` in `CookingSystem.dm`; link skill unlock in `SkillRecipeUnlock.dm`
7. **Deed integration**: Call `CanPlayerBuildAtLocation()`/`CanPlayerPickupAtLocation()`/`CanPlayerDropAtLocation()`
8. **Persistence**: Modify `SavingChars.dm` load/save procs for character data; bump `SavefileVersioning.dm` version
9. **Ranks**: Define `#define RANK_*`, add variable to `datum/character_data`, add switch cases
10. **NPCs**: Link spawner via `ownere1`-`ownere4`; integrate dialogue via `NPCRecipeHandlers.dm`

## Common Gotchas

- **Initialization order**: Don't spawn background loops in system files—use `InitializationManager.dm` phases
- **Elevation conflicts**: `Chk_LevelRange()` must pass before objects interact; ground can't hit elevated
- **Savefile fragility**: Changing var types breaks binary savefiles; bump `SavefileVersioning.dm` version
- **Season gating**: Always check `CONSUMABLES[item]["seasons"]` before harvest/craft; season affects availability
- **Deed authority**: `CanPlayerBuildAtLocation()` is law—deed zones override all other flags
- **Chunk persistence**: Inclusive ranges ("Chunk 0,0-9,9.sav" = turfs [0,0] to [9,9]); chunks never regenerate
- **Hunger/stamina link**: Hunger reduces stamina every 15-30 ticks; low stamina = slow movement
- **Continent rules**: Verify rule config matches game mode (story allows building, pvp allows stealing, sandbox disables conflict)
- **Price hardcoding**: Don't hardcode item prices—use `DynamicMarketPricingSystem.dm`
- **Lighting performance**: Dynamic spotlights expensive; use `draw_spotlight()` sparingly, batch updates
- **Recipe dual-unlock**: Items must be in BOTH `CONSUMABLES` registry AND `recipe_list` for skill + inspection unlocks
- **Rank storage**: Add rank type to `UnifiedRankSystem.dm` constants AND `datum/character_data` variables
- **Movement cache**: `InvalidateDeedPermissionCache()` called on every move; ensures zone-change detection
- **Elevation transitions**: Stairs/hills/ditches enforce directional entry/exit via `Odir()`; directional blocking per-turf

## Cheat Detection & Security

Tripwire pattern (detection, not prevention):
```dm
var
	cheats = 0                  // Detection flag
	securityoffset1 = 4132370   // Line of defense 1
	offsetamount1 = 4132370     // Must match; use unique value per installation
```
Compare offsets periodically; log suspicious activity rather than disconnect (enables admin investigation).

## File Navigation Reference

- **Core systems**: `dm/` (movement, combat, items, recipes, deeds, spawning, time, persistence)
- **Libraries**: `libs/` (elevation, atom system, UI utilities, dynamic lighting)
- **Procedural generation**: `mapgen/` (terrain, biomes, chunk persistence)
- **Assets**: `dmi/` (icons/32x32, 64/64), `snd/` (audio)
- **Player data**: `MapSaves/` (chunk saves), `SavingChars.dm` (character persistence)
- **Interfaces**: `Interfacemini.dmf` (DMF UI definitions)

## Key Constants

- **TIME_STEP** = 5 (deciseconds per world tick)
- **world.fps** = 40 (TPS)
- **TILE_WIDTH/HEIGHT** = 32 pixels
- **REFLECTION_PLANE** = -1
- **LIGHTING_PLANE** = 2
- **MAX_RANK_LEVEL** = 5
- **CONTINENT_PEACEFUL**, **CONTINENT_CREATIVE**, **CONTINENT_COMBAT** (flags)
- **REFINE_STAGE_UNREFINED/FILED/SHARPENED/POLISHED** (refinement states)

## Recent Sessions & Phase Status

- **Phase 4 Complete**: Dual-currency economy, market stalls, trading, recipe unlocking from NPCs (20+ commits)
- **Phase 5 In Progress**: Market board UI, treasury system, skill-based recipe discovery (latest commits)
- **Current focus**: Recipe discovery rate balancing, NPC recipe teaching, inventory management extensions
- **Build status**: Clean (0 errors); last commit fixed deed.dm inclusion (15 compilation errors resolved)

---

**Note**: This is an active WIP project (recomment-cleanup branch). Many systems interact deeply; test thoroughly with procedural map generation enabled. Always verify savefile versioning when changing player data structures. Use full initialization gate checks—world not ready during first 400 ticks.
