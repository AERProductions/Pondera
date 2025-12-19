# Foundation Systems Audit - December 18, 2025

## Overview

Complete audit of Pondera's core foundation systems: movement, sound, lighting, game loop, and player interaction. These systems form the critical infrastructure that all gameplay depends on.

---

## 1. MOVEMENT SYSTEM

### Files
- `dm/movement.dm` (140 lines) - PRIMARY SYSTEM
- `dm/Mov.dm` (300+ lines) - Legacy/alternate implementation (mixed use)
- `dm/Stance.dm` (60 lines) - Movement stance system
- `Pondera-Recoded/dm/Stances.dm` - Alternative stance system

### Architecture

**Input Layer** (movement.dm):
- Directional verbs: `MoveNorth()`, `MoveSouth()`, `MoveEast()`, `MoveWest()`
- Stop verbs: `StopNorth()`, `StopSouth()`, `StopEast()`, `StopWest()`
- Each sets direction flags: `MN`, `MS`, `ME`, `MW` (held directions)
- Queued directions: `QueN`, `QueS`, `QueE`, `QueW`

**Sprint System** (movement.dm):
```dm
SprintCheck(TapDir)           // Detect double-tap within 3 ticks
SprintCancel()                 // Cancel sprint when no input
GetMovementSpeed()             // Return current speed (delay ticks)
```
- Double-tap detection enabled sprint
- Sprinting reduces MovementSpeed (currently hardcoded as 3)
- On bump: cancels sprint, plays "Weak" flick animation

**Movement Loop** (movement.dm):
```dm
MovementLoop()
  while(held or queued directions)
    step() in active direction
    sleep(GetMovementSpeed())
  Moving=0  // Clear flag when complete
```
- Non-blocking: sets `Moving=1` to prevent re-entry
- Processes queue depth first
- Sleep delay defines movement speed (lower = faster)

**Speed Variables** (Basics.dm):
```dm
speed = 3           // Legacy old speed variable (superseded by MovementSpeed)
MovementSpeed = 3   // Current system speed delay
move = TRUE         // Enable/disable movement
```

### Issues & Improvements Needed

**Issue 1: Duplicate/Conflicting Systems**
- Both `dm/Mov.dm` and `dm/movement.dm` exist
- `Mov.dm` contains legacy code (commented-out alternatives, old patterns)
- `Stance.dm` has multiple versions (dm/ and Pondera-Recoded/)
- **Status**: Confusing, needs consolidation
- **Fix**: Audit which is canonical, remove dead code paths

**Issue 2: Speed System Ambiguity**
- Two speed variables: `speed` and `MovementSpeed` (both =3)
- Movement loop uses `GetMovementSpeed()` (proper), but `speed` variable unused
- No sprint speed reduction implementation (Sprinting flag set but not used)
- **Status**: Sprint detection works, but speed effect missing
- **Fix**: Implement `Sprinting=1` to modify `MovementSpeed` during sprint

**Issue 3: Movement State Inconsistencies**
- `walk` variable from Mov.dm (frozen flag)
- `move` variable from movement.dm (enable/disable)
- `Moving` flag (prevents loop re-entry)
- `nomotion` flag (shopkeeper interaction freeze)
- **Status**: Multiple overlapping freeze states
- **Fix**: Unify into single state machine (MOVE_NORMAL, MOVE_FROZEN, MOVE_SPRINTING)

**Issue 4: Input Validation Gap**
- Movement verbs check `if(src.move)` but don't validate `Sprinting` before cancel
- Can theoretically queue sprint while already sprinting
- **Status**: Minor, unlikely to cause issues
- **Fix**: Add guard in `SprintCheck()` to prevent re-entry

**Issue 5: Elevation Integration Missing**
- Movement system doesn't check `Chk_LevelRange()` before step
- Players could theoretically interact with objects at different elevation levels
- **Status**: Possibly handled elsewhere (in interaction code), but should be here
- **Fix**: Add `if(!Chk_LevelRange(Target)) return` to MovementLoop before step

### Performance Characteristics
- **Input latency**: ~25ms per direction (1 tick = 25ms)
- **Sprint detection window**: 75ms (3 ticks)
- **Movement sleep**: 75ms base (3 ticks), faster when sprinting (needs implementation)
- **Stamina drain**: Not integrated - missing opportunity for sprint fatigue

### Recommendations
1. Consolidate Mov.dm and movement.dm into single canonical system
2. Implement sprint speed modifier (MovementSpeed * 0.67 or similar)
3. Remove `speed` variable, use `MovementSpeed` exclusively
4. Integrate elevation checking into movement loop
5. Add stamina cost to sprint (replaces 3-tick window with stamina availability)

---

## 2. SOUND SYSTEM

### Files
- `dm/SoundEngine.dm` (293 lines) - PRIMARY SYSTEM (active)
- `dm/Snd.dm` (297 lines) - DEPRECATED (legacy, marked obsolete)
- `dm/LightningSystem.dm` - Specialized lightning sound effects
- No integration with movement sounds yet

### Architecture

**Client-Side Channel Management**:
```dm
client/var
  sound_channels[1]   // Dynamic effect channels (auto-expands 1-100+)
  music_channels[4]   // Fixed 4-channel music buffer
  music_playing[2]    // Track which pairs are active
```

**Music Channel Pairs** (for smooth crossfading):
- Pair 1: Channels 1024 (MUSIC_CHANNEL_1) + 1023 (MUSIC_CHANNEL_2)
- Pair 2: Channels 1022 (MUSIC_CHANNEL_3) + 1021 (MUSIC_CHANNEL_4)
- Maps: `MUSIC_CHANNELS_ASSOC = list("1"=2, "2"=1, "3"=4, "4"=3)` for fading

**Procs**:
```dm
musicChannel(sound, channel, replace)    // Allocate music channel in pair
firstChannel(sound)                       // Allocate available effect channel
SoundEngine(sound, range, repeat, ...)   // Play positional effect with range
MusicEngine(sound, channel, fade_time)   // Play music with fade transition
/sound/update()                           // Handle 3D positioning & lifecycle
```

### Architecture Details

**Positional Audio Loop** (`/sound/update`):
```dm
while(sound_is_active)
  Update 3D position as player moves
  Fade volume based on distance (range parameter)
  Update frequency based on relative velocity (Doppler effect? Not confirmed)
  Check if still in range (remove if out)
  sleep(interval)  // Default 10 ticks per update
```

**Music Crossfading**:
- Smoothly transitions between channels in same pair
- Non-blocking: music plays while other sounds continue
- Supports 2 independent music pairs (theory: story + ambient)

### Issues & Improvements Needed

**Issue 1: Snd.dm vs SoundEngine.dm Confusion**
- Snd.dm marked DEPRECATED with comment: "DEPRECATED: This file is superseded by SoundEngine.dm"
- Both still in codebase, only SoundEngine included in DME
- **Status**: Clean (dead code isolated), but confusing
- **Fix**: Delete Snd.dm entirely

**Issue 2: No Sound-to-Movement Integration**
- Movement system has NO sound effects
- Sprint doesn't trigger sound
- Footsteps not implemented
- **Status**: Silent movement breaks immersion
- **Fix**: Add footstep sounds based on terrain/speed, sprint whoosh sound

**Issue 3: Update Interval Hardcoded**
- `/sound/update()` uses `sleep(10)` (10 ticks = 250ms per update)
- Very coarse for positional audio (250ms = 8 pixels at 32px/tile, noticeable)
- **Status**: Acceptable but audible updates in fast movement
- **Fix**: Reduce to `sleep(2-3)` (50-75ms) for smooth transitions

**Issue 4: No Volume Curve Definition**
- Distance falloff "as you walk away" but no specific curve (linear? exponential? inverse square?)
- Range vs falloff difference unclear
- **Status**: Unclear behavior, inconsistent across calls
- **Fix**: Document falloff curve (recommend inverse-square: vol = max / distance^2)

**Issue 5: Channel Allocation Inefficiency**
- Dynamic sound_channels expands linearly: `++sound_channels.len`
- Large number of simultaneous sounds could fragment memory
- No garbage collection (stale channels accumulate)
- **Status**: Low priority (typical games <30 concurrent sounds), but poor practice
- **Fix**: Implement channel recycling (reuse freed slots)

**Issue 6: Music Pair Architecture Underutilized**
- Supports 2 independent music pairs but game likely uses only 1
- Pair 2 (channels 3-4) never initialized
- **Status**: Harmless overhead
- **Fix**: Document intended use case (e.g., story vs ambient), or remove if unused

### Performance Characteristics
- **Maximum concurrent sounds**: Unlimited (channels auto-expand)
- **Audio update latency**: ~250ms (10 ticks)
- **Music fade time**: Configurable (typically 2-5 seconds)
- **CPU cost**: Low (position updates every 250ms, not every tick)

### Current Integration Points
- ShadowLighting.dm uses sound for lightning effects (LightningSystem.dm)
- No integration with movement system yet
- No integration with combat system yet

### Recommendations
1. Delete Snd.dm (confirmed deprecated, no code path uses it)
2. Add footstep sounds to movement system (fire on every step)
3. Reduce update interval to 2-3 ticks (50-75ms) for smoother audio
4. Document falloff curve and range semantics
5. Integrate combat sounds (hit, miss, death)
6. Add environmental audio (wind, water, fire)
7. Implement channel recycling for long-running games

---

## 3. LIGHTING SYSTEM

### Files
- `dm/Lighting.dm` (122 lines) - PRIMARY SYSTEM
- `dm/DirectionalLighting.dm` - Shadow/directional effects
- `dm/DirectionalLighting_Integration.dm` - Integration layer
- `dm/ShadowLighting.dm` - Shadow effects (fire/lightning)
- `dm/LightningSystem.dm` - Lightning-specific lighting
- `dm/testdynlight.dm` - Testing/experimental

### Architecture

**Planes & Layers**:
```dm
LIGHTING_PLANE = 2              // Master plane for all lighting
EFFECTS_LAYER = ? (not defined) // Layer within lighting plane
```

**Overlay Objects**:
```dm
/obj/lighting_plane            // Screen-space master lighting object
  plane = LIGHTING_PLANE
  blend_mode = BLEND_MULTIPLY  // Multiplicative blending (darkens)
  appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
  mouse_opacity = 0             // Non-interactive

/atom/movable/spotlight        // Additive light source
  plane = LIGHTING_PLANE
  blend_mode = BLEND_ADD        // Additive (lightens)
  icon = 'dmi/l256.dmi' (256x256 gradient)
  layer = EFFECTS_LAYER + 10

/atom/movable/cone             // Directional light cone
  plane = LIGHTING_PLANE
  blend_mode = BLEND_ADD        // Additive (lightens)
  icon = 'dmi/l256.dmi'
  layer = EFFECTS_LAYER + 10
```

**Client Initialization**:
```dm
client/draw_lighting_plane()    // Called on login
  toggle_daynight(1)            // Toggle day/night cycle
  screen += new/obj/lighting_plane
```

**Light Drawing Procs**:
```dm
draw_spotlight(x_os, y_os, hex, size_modi, alph)
  Creates spotlight overlay with position, color, size, alpha
  Stores reference in atom.spotlight

remove_spotlight(...)
  Removes spotlight from overlays

edit_spotlight(...)
  Animates spotlight changes (position, color, size, alpha)
  Uses animate() with 1-tick duration

draw_cone(x_os, y_os, hex, size_modi, alph)
  Creates directional cone light overlay

remove_cone(...)
  Removes cone light

edit_cone(...)
  Animates cone changes
```

### Issues & Improvements Needed

**Issue 1: Multiple Lighting Systems Fragmentation**
- DirectionalLighting.dm (unknown purpose)
- DirectionalLighting_Integration.dm (integration layer)
- ShadowLighting.dm (shadow-specific)
- LightningSystem.dm (lightning-specific)
- testdynlight.dm (abandoned test code)
- **Status**: Confusing organization, possible redundancy
- **Fix**: Audit which systems are actually used, consolidate or remove dead code

**Issue 2: Hardcoded Icon Path**
- Both spotlight and cone use `icon = 'dmi/l256.dmi'`
- No fallback if file missing
- Size always assumes 256x256 (no scalability if different icon used)
- **Status**: Fragile, breaks if asset renamed
- **Fix**: Define icon path as constant, add validation on init

**Issue 3: No Spotlight Performance Gating**
- `draw_spotlight()` creates overlay immediately (instant)
- No limit on concurrent spotlights
- Large numbers of spotlights could tank performance (each is animated object + render)
- **Status**: Possible performance issue, untested with large spotlight counts
- **Fix**: Add spotlight pooling/recycling, limit to max 10 concurrent

**Issue 4: Animation Latency**
- `edit_spotlight()` uses `animate(..., time = 1)` (1 tick = 25ms)
- Very fast animation could appear stuttering on slow clients
- **Status**: Minor, but animation smooth at 25ms may be too fast
- **Fix**: Use `time = 2-3` (50-75ms) for smoother transitions

**Issue 5: No Spotlight Lifecycle**
- Spotlights created by `draw_spotlight()` never explicitly removed
- Rely on edit/remove calls, but no automatic timeout
- Long-lived spotlights accumulate memory
- **Status**: Possible memory leak if spotlights not properly cleaned up
- **Fix**: Add timeout to spotlights, automatic removal after N ticks of inactivity

**Issue 6: Missing Cone Icon**
- `/obj/cone` defined but no icon specified (falls back to parent)
- Probably needs separate cone gradient (not 256px radial)
- **Status**: Cone lights may not render correctly
- **Fix**: Create cone-specific icon or verify inheritance works

**Issue 7: No Day/Night Integration Defined**
- `toggle_daynight()` called but not defined in Lighting.dm
- Probably in separate day/night system file
- **Status**: External dependency, unclear coupling
- **Fix**: Document where toggle_daynight is defined, verify separation of concerns

### Performance Characteristics
- **Spotlight creation**: Instant (no animation delay)
- **Spotlight animation**: 1 tick (25ms) to complete
- **Rendering cost**: Per-spotlight additive blend (GPU cost increases with count)
- **Estimated max spotlights**: 20-50 (before noticeable FPS impact at 40 TPS)

### Integration Points
- Day/night system (toggle_daynight)
- Shadow system (ShadowLighting.dm for fire/lightning)
- Combat system (likely uses spotlights for hit effects)
- Elevation system (spotlights should account for elevel?)

### Recommendations
1. Audit and consolidate DirectionalLighting*.dm into single file
2. Delete testdynlight.dm (test artifact)
3. Define max concurrent spotlights, implement pooling
4. Create separate cone icon or verify current works
5. Add spotlight timeout (remove after inactivity)
6. Document toggle_daynight integration point
7. Add elevation awareness to lighting (spotlights at different elevals?)
8. Optimize render path (batch updates, reduce animation frequency)

---

## 4. GAME LOOP & INITIALIZATION

### Files
- `dm/InitializationManager.dm` (986 lines) - PRIMARY SYSTEM
- `Pondera-Recoded/mapgen/_debugtimer.dm` - Legacy debug timer (superseded)
- `libs/BaseCamp.dm` - BaseCamp framework for game controller

### Initialization Sequence

**Boot Timeline** (from InitializationManager.dm):

```
Tick 0:   InitializeWorld() called
          └─ Rank system registry loaded (critical path item 0)
          └─ Time system loaded (Phase 1)
          
Tick 2:   SQLite database initialization starts

Tick 3:   Searchables registry loaded
          Market prices initialization starts
          SQLite registration complete
          
Tick 5:   Crash recovery initialization

Tick 10:  Server difficulty system

Tick 15:  Dynamic zones initialization

Tick 20:  Map generation starts (GenerateMap(15,15))

Tick 25:  Bush growth initialization

Tick 30:  Tree growth initialization

Tick 35:  Periodic time save background loop starts

Tick 40:  Deed maintenance processor starts

Tick 42:  Elevation terrain turfs builder

Tick 50:  Core infrastructure registered complete
          ↓
          PHASE 2B: Deed system lazy init (only if deeds exist)
          
Tick 55:  Deed system initialization

Tick 100: PHASE 3: Day/night + lighting cycles start
          └─ Day/night cycle initialization
          └─ Lighting system initialization
          
Tick 150: Time advancement validation

Tick 200: Weather cycle (already ticking from tick 5)

Tick 300: PHASE 4: Special world systems
          └─ Town system
          └─ Story system
          └─ Sandbox system
          └─ PvP system
          
Tick 400: PHASE 5: NPC systems
          └─ Recipe unlock system
          └─ Skill progression
          └─ Market integration
          
Tick 500: PHASE 13A: World Events System

Tick 515: PHASE 13B: NPC Supply Chains

Tick 530: PHASE 13C: Economic Cycles

Tick 600: FinalizeInitialization() called
          └─ world_initialization_complete = TRUE
          └─ All players gates unlocked for login
```

**Total boot time**: ~600-700 ticks (~15-17 seconds at 40 TPS)

### Initialization Dependencies

**Critical Path** (blocking sequence):
1. Rank system (0 ticks) - Required before character creation
2. Time system (0 ticks) - Required by day/night, maintenance
3. SQLite (2 ticks) - Required by persistence
4. Market prices (3 ticks) - Required by economy
5. Core infrastructure (50 ticks) - Required by gameplay
6. Finalization (600 ticks) - Opens player login

**Parallel Initialization** (non-blocking):
- Weather system (starts tick 5, independent)
- Periodic saves (starts tick 35, background process)
- Deed maintenance (starts tick 40, background process)

### Architecture

**Gate System**:
```dm
RegisterInitComplete(system_name)
  // Called by each subsystem when ready
  // Tracked in list/initialization_complete
  
FinalizeInitialization()
  // Called at tick 600 to verify all systems ready
  // Sets world_initialization_complete = TRUE
  // Gates player login until TRUE
```

**Logging**:
```dm
LogInit(message, tick_offset)
  // Writes to world.log with [INIT] prefix
  // Includes timing information for debugging
```

### Issues & Improvements Needed

**Issue 1: Hard-Coded Tick Offsets**
- Every system has fixed spawn(N) offset
- Adding new system requires manual tick calculation
- High risk of collision (two systems spawning at same tick)
- **Status**: Works but brittle
- **Fix**: Use dependency declaration instead of hard-coded ticks
  ```dm
  RegisterInitFor("my_system", after=["sqlite", "market"], tick_offset=10)
  ```

**Issue 2: No Parallelization Analysis**
- Currently sequential despite many systems being independent
- Example: Weather could start before infrastructure complete
- Could reduce boot time by 100-200 ticks if properly parallelized
- **Status**: Sub-optimal but acceptable
- **Fix**: Build dependency graph, use DAG scheduling

**Issue 3: No Timeout/Deadlock Detection**
- If a system hangs, initialization never completes
- Players would be stuck unable to login indefinitely
- **Status**: Potential issue, untested under failure conditions
- **Fix**: Add timeout per system, force complete after 10-second max

**Issue 4: Silent Failures**
- If RegisterInitComplete("system") never called, completion never reached
- Only visible via world.log, not obvious to admins
- **Status**: Debugging issue, not user-facing
- **Fix**: Add warning at tick 900 if world_initialization_complete still FALSE

**Issue 5: No Initialization Rollback**
- If system X initializes but then fails, no cleanup
- Could leave game in inconsistent state
- **Status**: Unlikely but unhandled edge case
- **Fix**: Add try/catch around each system, log failures

**Issue 6: Phase 13 Integration Incomplete**
- Phase 13A/B/C initialization scheduled but marked as TODO in comments
- "Integration pending" noted for Phase 4-5 systems
- **Status**: Known limitation, work in progress
- **Fix**: Complete Phase 13 integration (in progress with Phase 13 compilation fixes)

### Performance Characteristics
- **Boot time**: 15-17 seconds (600+ ticks @ 40 TPS)
- **Initialization CPU**: High during first 100 ticks (map gen, zone creation)
- **Parallelizable work**: ~40% (weather, saves, deed maintenance)
- **Critical path length**: ~300 ticks (unavoidable sequential work)

### Integration Points
- Time system (TimeSave.dm, TimeAdvance.dm)
- SQLite persistence (SQLitePersistenceLayer.dm)
- Map generation (mapgen/backend.dm)
- Weather system (WeatherController.dm, SeasonalWeather.dm)
- Day/night system (unclear which file - needs audit)
- All 13 phases of gameplay systems

### Recommendations
1. Implement dependency-based scheduling (replace hard-coded ticks)
2. Add timeout detection and warning system
3. Add rollback/cleanup on initialization failure
4. Analyze parallelization opportunities (weather before infrastructure?)
5. Document dependency graph for each system
6. Add admin command to show initialization status: `/admin_init_status`
7. Implement incremental initialization (not all systems required for minimal gameplay)
8. Add performance metrics per system (log initialization time)

---

## 5. GAME INTERACTION SYSTEM

### Files
- `dm/NPCInteractionHUD.dm` (400 lines) - PRIMARY SYSTEM
- `dm/NPCInteractionMacroKeys.dm` - Macro key integration
- Mixed into NPC behavior (Enemies.dm, Turf.dm)

### Architecture

**Core Interaction Session**:
```dm
/datum/NPC_Interaction
  var
    mob/npc                    // NPC being interacted with
    mob/players/player         // Player doing interaction
    list/options               // All available dialogue options
    list/visible_options       // Filtered options (gates applied)
    is_open                    // Session active flag
    
    npc_time_of_day            // Cached NPC state
    npc_shop_open
    npc_awake
    player_reputation
    
    obj/screen/npc_interaction_main/main
    list/option_screens        // Screen objects for each option
```

**Option Gating**:
```dm
CacheNPCState()         // Detect: time of day, shop hours, awake, reputation

FilterOptionsForGates() // Apply visibility filters:
  - Time of day gates (shop hours)
  - Player reputation gates
  - Knowledge prerequisites (learned recipes/topics)
  - Season gates
```

**Interaction Flow**:
```
Player clicks NPC
  ↓
NPC.Click() handler
  ↓
new /datum/NPC_Interaction(npc, player)
  ├─ CacheNPCState()
  ├─ FilterOptionsForGates()
  └─ Show()  // Displays screen-based menu
  ↓
Player selects option
  ↓
NPC.Interact_[action](player, session)
  ├─ Add item to inventory
  ├─ Unlock recipe
  ├─ Give quest
  └─ Update reputation
  ↓
session.Close()
```

**Conditional Options** (12-11-25 enhancement):
```dm
// Time gates: shop only open 6am-6pm
if(time < 6 || time > 18)
  hide "Buy" option

// Reputation gates: +50 reputation = unlock special options
if(player_reputation < 50)
  hide "Get discount"

// Knowledge gates: must have learned recipe first
if(player not in recipe_knowers[recipe_name])
  hide "Learn advanced recipe"

// Season gates: only available in spring
if(current_season != "Spring")
  hide "Buy spring seeds"
```

### Issues & Improvements Needed

**Issue 1: NPC State Detection Incomplete**
- `CacheNPCState()` defined but not fully implemented
- Comments show intent but code shows stubs
- **Status**: Framework in place, implementation incomplete
- **Fix**: Implement full state detection for all gate types

**Issue 2: No Reputation System Integrated**
- `player_reputation` variable cached but never loaded
- No source database for reputation data
- **Status**: Feature designed but not implemented
- **Fix**: Connect to character_data reputation field

**Issue 3: No Knowledge Prerequisites Database**
- `recipe_knowers[recipe_name]` referenced but not defined
- No way to check if player has "learned" a topic
- **Status**: Feature designed but storage undefined
- **Fix**: Use SQLite recipe_discovery table or character_data knowledge list

**Issue 4: Season Gate Implementation**
- References `current_season` global but not defined in this file
- Probably in time system, but dependency unclear
- **Status**: Partially implemented
- **Fix**: Document where current_season comes from, add validation

**Issue 5: No Timed/Event-Based Interactions**
- Always available if gates pass
- Can't do limited-time events ("special sale for 1 hour")
- **Status**: Missing feature
- **Fix**: Add expiry_time to option filters

**Issue 6: No Interaction History**
- Player can't see what they've already done with NPC
- No memory of completed quests in interaction menu
- **Status**: Missing feature
- **Fix**: Track completed interactions per player

**Issue 7: Screen-Based HUD Not Fully Documented**
- References `obj/screen/npc_interaction_main` but definition not in this file
- Unclear how screen objects are created/displayed
- **Status**: Dependency on external system (ClientExtensions.dm?)
- **Fix**: Document and consolidate screen object definitions

### Performance Characteristics
- **Option filtering**: O(n) where n = option count (typically <20)
- **State detection**: O(1) per property (cached at session start)
- **Session overhead**: Minimal (pure datum, no rendering until Show())

### Integration Points
- Time system (for time-of-day gates)
- Character data system (for reputation, knowledge)
- Quest system (for quest interactions)
- Recipe system (for recipe gates)
- SQLite (for persistence of player history)

### Recommendations
1. Complete CacheNPCState() implementation
2. Implement reputation gates (connect to character_data)
3. Implement knowledge prerequisites (use recipe_discovery table)
4. Add interaction history tracking (character_data.completed_interactions)
5. Add timed/expiry gates for event-based interactions
6. Document screen object architecture
7. Add "favorite NPC" feature (auto-expand common options)
8. Add NPC schedule awareness (don't interact if NPC sleeping)

---

## CROSS-SYSTEM INTEGRATION ISSUES

### 1. Movement ↔ Sound
- **Current**: No footstep sounds
- **Needed**: Movement triggers sound effects based on terrain
- **Severity**: High (immersion impact)
- **Estimate**: 2-4 hours implementation

### 2. Movement ↔ Elevation
- **Current**: Movement doesn't check elevation range
- **Needed**: Prevent interaction across elevation gaps
- **Severity**: Medium (prevents bugs)
- **Estimate**: 1-2 hours implementation

### 3. Movement ↔ Sprint
- **Current**: Sprint detected but speed not modified
- **Needed**: Implement actual sprint speed change
- **Severity**: Medium (feature incomplete)
- **Estimate**: 1 hour implementation

### 4. Lighting ↔ Day/Night
- **Current**: Toggle called but integration unclear
- **Needed**: Document and verify coupling
- **Severity**: Low (seems to work)
- **Estimate**: 30 min review

### 5. Interaction ↔ Time System
- **Current**: Time gates designed but not fully implemented
- **Needed**: Complete gate implementation
- **Severity**: Medium (feature incomplete)
- **Estimate**: 2-3 hours implementation

### 6. Interaction ↔ Reputation
- **Current**: Reputation caching designed but no data source
- **Needed**: Connect to character_data reputation
- **Severity**: Medium (feature incomplete)
- **Estimate**: 2-3 hours implementation

### 7. All Systems ↔ Initialization
- **Current**: Hard-coded tick offsets
- **Needed**: Dependency-based scheduling
- **Severity**: Low (works but brittle)
- **Estimate**: 4-6 hours refactoring

---

## SUMMARY TABLE

| System | Status | Critical Issues | Estimate to Fix |
|--------|--------|-----------------|-----------------|
| Movement | 80% | Sprint speed missing, elevation check missing | 2-3h |
| Sound | 90% | Deprecated file exists, footsteps missing | 2-4h |
| Lighting | 85% | Multiple fragmented systems, no pooling | 3-4h |
| Game Loop | 95% | Hard-coded ticks brittle, but functional | 4-6h |
| Interaction | 70% | Gates incomplete, no data source | 5-7h |

**Total effort to polish foundations**: ~16-24 hours

---

## NEXT STEPS (Priority Order)

1. **Sprint Speed Implementation** (1h) - High visibility, quick win
2. **Footstep Sounds** (2-4h) - Major immersion improvement
3. **Interaction Gates Completion** (5-7h) - Feature-complete dialogue system
4. **Lighting System Consolidation** (3-4h) - Code cleanup, performance
5. **Elevation Integration** (1-2h) - Bug prevention
6. **Initialization Refactoring** (4-6h) - Technical debt, maintainability

