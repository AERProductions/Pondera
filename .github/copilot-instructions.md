# Pondera AI Coding Instructions

## Project Overview
**Pondera** is an open-source BYOND game project—a procedurally-generated survival MMO where players gather resources, build structures, and explore a vast wilderness across multiple biomes. The codebase is written in **DM (Dream Maker)**, BYOND's scripting language.

### Build System
- **Build Tool**: BYOND Dream Maker (DM compiler)
- **Entry Point**: `Pondera.dme` (Dream Environment file—lists all includes in order)
- **Output**: `Pondera.dmb` (compiled game binary)
- **Task**: Available as `dm: build - Pondera.dme` in VS Code tasks

## Architecture & Key Components

### Directory Structure
- **`dm/`**: Core game systems (85+ .dm files, ~150KB+ of code)
- **`libs/`**: Reusable libraries (elevation, atom systems, UI utilities)
- **`mapgen/`**: Procedural map generation system (biomes, water, seed system)
- **`MapSaves/`**: Persisted chunk data (chunked world saves)
- **`dmi/`**: Graphics/icon files (32x32 and 64x64 tile assets)
- **`snd/`**: Sound effects

### Major Systems

#### 1. **Procedural Map Generation** (`mapgen/backend.dm` + biome files)
Generates infinite terrain using chunked persistence:

**Generation Process:**
- `GenerateMap(lakes, hills)` spawns `map_generator/water` and `map_generator/temperate` objects with specified count
- Each `map_generator` repeatedly calls `GetTurfs()` to select random chunks, then `Generate()` to populate them
- Process: `EdgeBorder()` (paint borders) → `InsideBorder()` (smooth transitions) → `SpawnResource()` (place biome resources)

**Chunk System:**
- World divided into 10x10 turf chunks indexed by coordinate ranges (e.g., "Chunk 0,0-9,9.sav")
- Each chunk persists independently in `MapSaves/` as binary savefile
- On terrain generation, newly created turfs are immediately saved; subsequent logins load from chunk files
- Chunks are lazily loaded—only generate when first requested

**Biome-Specific Spawning:**
- Biome files (`biome_arctic.dm`, `biome_desert.dm`, `biome_rainforest.dm`, `biome_temperate.dm`) define resource types
- Each biome has spawn chance table for resources (ores, logs, plants, etc.)
- `SpawnResource()` proc called on every turf after generation; each biome type checks its spawn table
- Resource types inherit from base classes (e.g., `obj/Rocks`, `obj/plant/ueiktree`) and can have `growstage` for harvesting

**Map Generator Hierarchy:**
- Base `map_generator/` type: defines `pos[2]` (x/y), `size[2]` (width/height), `turfs[0]` (list)
- Subtypes: `/water`, `/temperate`, `/arctic`, `/desert`, `/rainforest` (each with custom turf types and spawn tables)
- Can specify `min_size` and `max_size` to control chunk dimensions

#### 2. **Elevation & Movement** (`libs/Fl_ElevationSystem.dm`, `libs/Fl_AtomSystem.dm`, `dm/movement.dm`)
Multi-level vertical system enabling multi-story landscapes and vertical gameplay:

**Elevation Mechanics:**
- **`elevel` (elevation level)**: A vertical position as a decimal value (e.g., 1.0, 1.5, 2.0, 2.5). Whole numbers represent ground levels; half-values (1.5, 2.5) represent transition states (stairs, ramps).
- **`layer` (visual z-order)**: Automatically calculated from `elevel` via `FindLayer(elevel)` which maps layers to elevation levels (4 layers per elevel). Controls drawing order and invisibility.
- **`invisibility`**: Derived from `elevel` via `FindInvis()`. Lower elevals become invisible when viewing from higher elevations, allowing multi-story visibility.
- **Range checking**: `Chk_LevelRange(atom/movable/A)` validates that two atoms can interact—they must be within ±0.5 levels of each other. This prevents ground-level NPCs from attacking characters on elevated platforms.

**Elevation Types** (derived from `/elevation`):
- **`ditch`**: Transition DOWN (enter from south, exit north; directional blocking)
- **`hill`**: Transition UP (climb up terrain)
- Both enforce directional entry/exit via `Odir()` (opposite direction)

**Interaction Model:**
- Objects occupy elevations via `eloc` (elevation location variable)
- `GetDenseObject()` finds blocking objects at correct elevel ranges
- Movement respects `tbit` (turf entrance block) and `ntbit` (turf exit block) for per-direction blocking

**Movement Integration:**
- Uses direction flags (`dir_to_bitflag`) for corner-cut detection via `Chk_CC()`
- `NOCC` global (no-corner-cutting) flag controls whether diagonal movement blocks on adjacent walls
- Sprint system tracked via `SprintDirs` list with tap-double-tap logic: double-tap same direction within 4 ticks to activate sprint

#### 3. **Lighting & Day/Night Cycle** (`dm/Lighting.dm`, `dm/DayNight.dm`)
- Two-state day/night system using `time_of_day` global (DAY=1, NIGHT=2)
- Client-side screen effect: `obj/screen_fx/day_night` with animated alpha/color transitions
- Per-atom spotlight system: `draw_spotlight()`, `edit_spotlight()`, `remove_spotlight()` procs
- Lighting plane defined as `LIGHTING_PLANE = 2` in `!defines.dm`

#### 4. **Persistence & Time** (`dm/TimeSave.dm`, `dm/SavingChars.dm`)
- Global time state: `hour`, `minute1`, `minute2`, `day`, `month`, `year`, `ampm`
- `TimeSave()/TimeLoad()` procs serialize to `timesave.sav` binary file
- Player data saved via `SavingChars.dm` (character data structure not shown but critical)
- Resource growth tied to growth stages: `growstage` (trees), `bgrowstage` (bushes), `vgrowstage`

#### 5. **Combat & Items** (`dm/Weapons.dm`, `dm/Objects.dm`)
- Weapon system: 30+ weapon types tracked via equipped flags (Wequipped, Aequipped, Sequipped, etc.)
- Stacking system (`dm/stacking.dm`) for inventory items
- Item containers with `stt_container` flag; click toggles open state
- Base damage/defense stat calculations

#### 6. **NPC & Spawn System** (`dm/Spawn.dm`, `dm/npcs.dm`)
- `obj/spawns/spawnpointe1-4`: spawn points with `max_spawn` limits
- Spawner loop runs every 10 ticks; tracks `spawned` count
- NPCs linked to spawner via `ownere1`, `ownere2`, etc.

#### 7. **Global Variables & State** (`!defines.dm`)
- Core constants: `TILE_WIDTH/HEIGHT = 32`, `TIME_STEP = 5`
- Z-plane defines: `REFLECTION_PLANE = -1`, `LIGHTING_PLANE = 2`
- Movement types: `MOVE_SLIDE`, `MOVE_JUMP`, `MOVE_TELEPORT`

### Critical Data Flows
```
World Init
  → GenerateMap() spawns terrain chunks
  → TimeLoad() restores time state
  → Spawners activate (check_spawn loop)
  
Player Login
  → Character loaded from savefile
  → draw_lighting_plane() renders lighting overlay
  → Movement system initialized (sprint tracking, direction queue)
  
Frame Loop (every tick)
  → Movement processed (MN/MS/ME/MW dir vars)
  → Day/night cycle animates (DayNight.dm)
  → Resource growth ticked (TimeSave.dm)
  → Spawner check_spawn() iterates
```

## Coding Patterns & Conventions

### Variable Naming
- **Temp vars**: `tmp/` prefix (e.g., `tmp/list/_listening_soundmobs`)
- **Equipped flags**: 2-letter codes for equipment slots (Wequipped=Weapon, Aequipped=Armor, Sequipped=Shield, TWequipped=Two-Weapon, LSequipped=Long-Sword, AXequipped=Axe, WHequipped=War-Hammer, etc.)
- **Global basecamp resources**: SP/SPs (stone), MP/MPs (metal), SB/SBs (supply box), SM/SMs (stamina module)
- **Basecamp prefixes**: "s"/"S" for singular/plural in `SavingChars.dm`
- **Directional vars**: MN/MS/ME/MW (movement north/south/east/west), QueN/QueS/QueE/QueW (queued directions)

### Proc Organization
- Procs at file scope (not always in type definitions) scattered throughout
- `set waitfor = 0` + `set background = 1` for async background loops
- `spawn()` blocks for delayed execution; `sleep()` for tick delays
- Loops use `while(1)` with `sleep()` for infinite background tasks

### Object Hierarchy
- `mob/players`: Main character type (has speed, HP, stamina, inventory)
- `obj/`: Generic objects (weapons, items, spawners, screen effects)
- `turf/`: Terrain tiles (generated procedurally, have density/opacity)
- `area/`: Logical regions (screen_fx containers)
- `elevation`: Multi-level container (derived from /obj)

### File Inclusion Order (in Pondera.dme)
1. Defines & interfaces first (`!defines.dm`, Interfacemini.dmf)
2. Core libs (atom system, elevation system) before game code
3. Game systems (movement, combat, NPCs) in middle
4. Mapgen last (depends on everything else)

**Critical**: The `.dme` file controls compile order—missing includes won't load, and order matters for inheritance.

## Developer Workflow

### Building
```powershell
# Via VS Code task (preferred)
dm: build - Pondera.dme

# Output: Pondera.dmb (deployable binary)
```

### Debugging
- `F0laks Debug Messager.dm` available for logging
- `_debugtimer.dm` for performance profiling
- Admin commands in `_AdminCommands.dm`

### Adding New Features
1. **New system**: Create `.dm` file in appropriate folder, add `#include` to `Pondera.dme`
2. **New item/weapon**: Add to `obj/items` hierarchy in `dm/Weapons.dm` or `dm/Objects.dm`
3. **Map generation**: Extend biome file (e.g., `biome_temperate.dm`) for resource spawning
4. **Persistence**: Update `TimeSave()/TimeLoad()` procs if adding global state

## Common Gotchas
- **Elevation conflicts**: Objects must be within 0.5 levels (`Chk_LevelRange()`) to interact
- **Spawn order**: World initialization race conditions—ensure dependencies loaded before use
- **Lighting overhead**: Dynamic spotlights are expensive; spawn judiciously
- **Save file fragility**: Binary savefile format breaks if variable types change
- **Direction handling**: Diagonals blocked by `NOCC` flag; watch corner-cut logic
- **Chunk naming**: MapSaves uses inclusive ranges (e.g., "Chunk 0,0-9,9.sav" includes turfs (0,0) through (9,9))

## Cheat Detection & Security Patterns

The codebase implements a **cheat detection system** (not prevention) using tripwire variables. This approach avoids crashing or kicking players, instead flagging suspicious behavior:

**Pattern** (in `SavingChars.dm`):
```dm
var
	cheats = 0  // Detection flag
	securityoffset1 = 4132370  // Line of defense 1
	securityoffset2 = 0        // Line of defense 2
	securityoffset3 = 0        // Line of defense 3 (dynamic)
	offsetamount1 = 4132370    // Must match securityoffset1
	offsetamount2 = 0          // Mirrors securityoffset2
	offsetamount3 = 0          // Mirrors securityoffset3
```

**Guidelines:**
- Use different offset amounts per installation (don't reuse defaults)
- Keep copies of offsets in separate variables for comparison checks
- `securityoffset3` should be randomized during runtime for dynamic detection
- Compare values periodically to flag unauthorized modifications
- Log suspicious activity rather than disconnecting (allows admin investigation)

## Integration Points
- **BYOND Hub**: Published to AERProductions.Pondera hub (see README.md)
- **Discord**: Community server for player feedback
- **Asset loading**: Icons preloaded via `preload_rsc = 1` (client-side)

---

**Note**: This is an active WIP project (f0lak branch). Many systems are partially implemented or experimental. When modifying core systems, test thoroughly with procedural map generation and persistence enabled.
