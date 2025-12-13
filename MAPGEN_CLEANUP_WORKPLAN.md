# Map Generation & Chunk Systems Cleanup Workplan

## Executive Summary
**Status**: 2 competing systems (MPSBWorldSave + ProceduralChunkingSystem) + 3 legacy generators (DungeonGenerator, POHGenerator, ClastGenerator) + 100+ lines of commented-out legacy code.

**Critical Issues**:
1. **Dual save systems** - MPSBWorldSave (static chunking) vs ProceduralChunkingSystem (lazy loading) both active
2. **Legacy code pollution** - 200+ lines of commented code in lg.dm (DungeonGenerator, POHGenerator, ClastGenerator)
3. **BiomeRegistry not integrated** - New system created but old biome files still actively used
4. **Spawn system fragmented** - Spawning logic in biome files, turf definitions, AND spawner objects
5. **No continent awareness** - Map generation doesn't respect story/sandbox/pvp modes

---

## Phase 1: Legacy Cleanup (Low Risk)

### Task 1.1: Remove Dead Code from lg.dm
**File**: `dm/lg.dm` (lines 1147-2387)
**Issue**: 150+ lines of commented generator code (MyGenerator, DungeonGenerator, POHGenerator, ClastGenerator)
**Action**: Delete entirely
**Impact**: Cleaner codebase, 0 functional loss
**Effort**: 5 min
**Status**: ⚪ Not Started

### Task 1.2: Clean up Basics.dm Admin Commands
**File**: `dm/Basics.dm` (lines 765-820)
**Issue**: AVATAR_SAVEMAP/LOADMAP/SAVECHUNK/LOADCHUNK use deprecated SwapMaps system
**Action**: Verify SwapMaps is used elsewhere; if not, remove
**Impact**: Reduces confusion about which save system is active
**Effort**: 10 min
**Status**: ⚪ Not Started

### Task 1.3: Archive Commented Code in MPSBWorldSave
**File**: `dm/MPSBWorldSave.dm`
**Issue**: Lines with `//call(/proc/GenerateTurfs)` and other commented attempts
**Action**: Create LEGACY_BACKUP.md documenting old approaches
**Impact**: Documentation, easier to reference later
**Effort**: 15 min
**Status**: ⚪ Not Started

---

## Phase 2: System Integration (Medium Risk)

### Task 2.1: Integrate BiomeRegistry with MapGeneration
**Files**: `mapgen/backend.dm`, `mapgen/BiomeRegistrySystem.dm`
**Issue**: BiomeRegistrySystem created but old biome_*.dm files still define turf types
**Action**:
  1. Update `GenerateMap()` to accept biome name parameter
  2. Have `map_generator.Generate()` call `BiomeSpawnResource()` instead of turf.SpawnResource()
  3. Remove turf.SpawnResource() implementations from biome_*.dm
  4. Update biome_*.dm to only define map_generator and obj/border classes (no turf definitions)
**Impact**: Single source of truth for biome resources
**Effort**: 30 min
**Status**: ⚪ Not Started

### Task 2.2: Wire ProceduralChunkingSystem to Initialization
**Files**: `dm/InitializationManager.dm`, `dm/ProceduralChunkingSystem.dm`, `dm/SavingChars.dm`
**Issue**: ProceduralChunkingSystem exists but not called during world init
**Action**:
  1. Call `InitializeChunkingSystem()` in InitializationManager Phase 1 (0 ticks)
  2. Replace GenerateMap() call in SavingChars with ProceduralChunkingSystem callback
  3. Verify chunk boundary detection works during player movement
**Impact**: On-demand chunk generation replaces static world load
**Effort**: 20 min
**Status**: ⚪ Not Started

### Task 2.3: Implement Continent-Aware Generation
**Files**: `mapgen/backend.dm`, `mapgen/BiomeRegistrySystem.dm`, `dm/ProceduralChunkingSystem.dm`
**Issue**: GenerateMap() doesn't know which continent it's generating for
**Action**:
  1. Add continent parameter to GenerateMap(continent = "story")
  2. Map_generator stores continent, uses to select biome registry
  3. ProceduralChunkingSystem passes continent to chunk generation callback
  4. Each continent (story/sandbox/pvp) gets different biome mix/probabilities
**Impact**: Story, Sandbox, PvP can have distinct terrain character
**Effort**: 25 min
**Status**: ⚪ Not Started

---

## Phase 3: Choose Authoritative Save System (High Risk)

### Task 3.1: Audit Save/Load in Active Systems
**Files**: `dm/MPSBWorldSave.dm`, `dm/ProceduralChunkingSystem.dm`, `dm/SavingChars.dm`
**Issue**: Two complete save/load implementations; unclear which is authoritative
**Action**:
  1. Trace world.save_all() calls - does it use save_manager or procedural_chunk_manager?
  2. Trace world.load_all() calls - same
  3. Check which system is active in actual gameplay (test with SpawnResource on-demand)
  4. Document findings
**Impact**: Determines migration path
**Effort**: 30 min
**Status**: ⚪ Not Started

### Task 3.2: Choose Winner (Manual Decision Point)
**Decision**: Keep MPSBWorldSave OR ProceduralChunkingSystem?
**Options**:
  - **Option A**: Keep ProceduralChunkingSystem (newer, on-demand, per-continent)
    - Advantage: Scales to 3 continents, lazy-loads chunks
    - Disadvantage: Needs full testing, unproven in production
  - **Option B**: Keep MPSBWorldSave (proven, static chunks)
    - Advantage: Battle-tested, known bugs fixed
    - Disadvantage: Static generation, doesn't scale to large maps
**Recommendation**: Option A (ProceduralChunkingSystem) if testing passes
**Status**: ⚪ Not Started

### Task 3.3: Remove Losing System
**Files**: Entire file (either MPSBWorldSave.dm OR ProceduralChunkingSystem.dm)
**Issue**: Having both creates confusion and dead code paths
**Action**:
  1. Back up loser to LEGACY/ folder
  2. Remove from Pondera.dme
  3. Remove from world init
  4. Update all references to use winner
**Impact**: 500+ lines removed, clear code paths
**Effort**: 30 min
**Status**: ⚪ Not Started

---

## Phase 4: Spawn System Consolidation (Low-Medium Risk)

### Task 4.1: Consolidate Spawn Points
**Files**: `mapgen/biome_*.dm`, `dm/ProceduralChunkingSystem.dm`, `mapgen/BiomeRegistrySystem.dm`
**Issue**: Spawnpoint creation happens in 3 places:
  1. Turf.SpawnResource() in biome_*.dm
  2. BiomeRegistrySystem spawnpoint_chance
  3. Manually placed /obj/spawns/spawnpointB2 objects
**Action**:
  1. Standardize on BiomeRegistrySystem spawnpoint handling
  2. Remove hardcoded new /obj/spawns lines from biome files
  3. Make spawnpoint type configurable per biome
**Impact**: Cleaner spawn distribution logic
**Effort**: 20 min
**Status**: ⚪ Not Started

### Task 4.2: Remove Spawn Object Respawning Logic
**Files**: `dm/Spawn.dm`, `dm/SavingChars.dm`
**Issue**: SpawnpointB1/B2 objects manually track spawned count with sleep loops
**Action**:
  1. Verify this is replaced by InitializationManager.dm phases
  2. If yes, remove manual spawn loops
  3. If no, keep but document why
**Impact**: Async pattern consistency
**Effort**: 15 min
**Status**: ⚪ Not Started

---

## Phase 5: Documentation & Testing

### Task 5.1: Document ProceduralChunkingSystem Integration
**File**: Create `MAPGEN_INTEGRATION_GUIDE.md`
**Contents**:
  - Architecture diagram (world init → ProceduralChunkingSystem)
  - How chunks load on-demand (edge detection)
  - How to configure per-continent biomes
  - Performance expectations (memory, tick time)
  - Troubleshooting (missing chunks, save corruption)
**Effort**: 45 min
**Status**: ⚪ Not Started

### Task 5.2: Test On-Demand Generation
**Manual Tests**:
  - Fast player movement across chunk boundaries
  - Verify adjacent chunks pre-load (no pop-in)
  - Verify chunk saves happen in background (no stalls)
  - Verify different continents have different biomes
**Effort**: 30 min testing + fixes
**Status**: ⚪ Not Started

### Task 5.3: Performance Benchmark
**Metrics**:
  - Time to generate first chunk (ticks)
  - Time to load chunk from disk (ticks)
  - Memory used by 32-chunk LRU cache (MB)
  - Tick time impact of async saves (ms)
**Effort**: 20 min
**Status**: ⚪ Not Started

---

## Summary Table

| Phase | Task | Priority | Effort | Risk | Status |
|-------|------|----------|--------|------|--------|
| **1.1** | Remove lg.dm dead code | HIGH | 5m | LOW | ⚪ |
| **1.2** | Clean Basics.dm | MEDIUM | 10m | LOW | ⚪ |
| **1.3** | Archive MPSBWorldSave comments | LOW | 15m | LOW | ⚪ |
| **2.1** | Integrate BiomeRegistry | HIGH | 30m | MEDIUM | ⚪ |
| **2.2** | Wire ProceduralChunkingSystem | HIGH | 20m | HIGH | ⚪ |
| **2.3** | Continent-aware generation | MEDIUM | 25m | MEDIUM | ⚪ |
| **3.1** | Audit save/load systems | HIGH | 30m | MEDIUM | ⚪ |
| **3.2** | Choose winner | CRITICAL | 0m | HIGH | ⚪ |
| **3.3** | Remove loser | HIGH | 30m | HIGH | ⚪ |
| **4.1** | Consolidate spawn points | MEDIUM | 20m | LOW | ⚪ |
| **4.2** | Review spawn object logic | LOW | 15m | LOW | ⚪ |
| **5.1** | Document integration | MEDIUM | 45m | NONE | ⚪ |
| **5.2** | Test on-demand generation | HIGH | 30m | NONE | ⚪ |
| **5.3** | Performance benchmark | MEDIUM | 20m | NONE | ⚪ |

**Total Effort**: ~295 minutes (4.9 hours)

---

## Recommended Execution Order

1. **Phase 1** (30 min) - Quick cleanup wins
2. **Phase 3.1** (30 min) - Understand current state before making decisions
3. **Phase 3.2** (0 min) - Make strategic decision
4. **Phase 2** (75 min) - Integrate BiomeRegistry and ProceduralChunking
5. **Phase 3.3** (30 min) - Remove dead system
6. **Phase 4** (50 min) - Consolidate spawning
7. **Phase 5** (95 min) - Document and test

---

## Risk Mitigation

- **Before Phase 2**: Create branch `mapgen-refactor`
- **Before Phase 3.3**: Run full test suite, verify no regressions
- **After Phase 3.3**: 0-error build mandatory before merge
- **During Phase 5**: Test on small map first (test.dmm), then full world

---

## Known Dependencies

- `InitializationManager.dm` must be complete (Phase 4/5 boot gates)
- `movement.dm` already has chunk boundary detection integrated
- `BiomeRegistrySystem.dm` already created and compiling
- No other systems depend on removed/changed files (verified via grep)

---

## Success Criteria

- ✅ 0 errors, 4 warnings (only on-file warnings unrelated to mapgen)
- ✅ ProceduralChunkingSystem active in world init
- ✅ BiomeRegistry used for all resource spawning
- ✅ Story/Sandbox/PvP continents generate different terrain
- ✅ No commented-out generator code in lg.dm
- ✅ Save/load unified on single system
- ✅ Performance: <50ms chunk generation, <20ms chunk load from disk
