# Initialization System Refactoring Plan
## Pondera MMO Boot Sequence Optimization

**Date**: December 18, 2025  
**Status**: ANALYSIS COMPLETE - Ready for Implementation  
**Scope**: Consolidate scattered background loops, integrate lighting, optimize boot sequence  

---

## Executive Summary

The current initialization system (`InitializeWorld()` in `InitializationManager.dm`) is **centralized but incomplete**:
- ✅ 986-line orchestrator with 25+ phases
- ✅ Dependency tracking and validation
- ⚠️ Background loops scattered across 50+ codebase locations
- ⚠️ Lighting integration placeholder (Phase 3)
- ⚠️ No boot-time diagnostics per phase
- ⚠️ No visibility into parallelizable vs. sequential phases

**Goal**: Create unified, transparent, optimized boot sequence with integrated lighting system.

---

## Current Architecture Analysis

### InitializeWorld() Structure (986 lines)

| Phase | Tick Range | Purpose | Status |
|-------|-----------|---------|--------|
| **0** | 0 | Rank registry | ✅ Complete |
| **1** | 0-10 | Time system, crash recovery, difficulty | ✅ Complete |
| **2** | 0-55 | Infrastructure: map, weather, zones | ✅ Complete |
| **2B** | 45-55 | Audio, fire, temperature, deeds | ✅ Complete |
| **3** | 50 | Day/night & lighting | ⚠️ PLACEHOLDER |
| **4** | 50-300 | Special worlds: towns, story, sandbox, pvp | ✅ Complete |
| **5** | 300-400 | NPCs, recipes, dialogue | ✅ Complete |
| **6** | 375-435 | Economy: market, trading, inventory | ✅ Complete |
| **7** | 384-395 | Quality of life | ✅ Complete |
| **8-10** | 400-426 | Advanced systems: transactions, crafting, predictions | ✅ Complete |
| **Final** | 430 | Validation & player login gate | ✅ Complete |

### Boot Sequence Timing
- **Total**: ~426 ticks (~10.6 seconds at 40 FPS)
- **Parallelizable**: Worlds (50-300 ticks) can run simultaneously
- **Critical Path**: Time → Infrastructure → Special Worlds → NPC → Economy

---

## Problem: Scattered Background Loops

### Issue 1: Loops Not Under Central Control

**Current Pattern** (found in 50+ files):
```dm
// In random system file:
proc/SomeBackgroundLoop()
    set background = 1
    set waitfor = 0
    
    while(1)
        // Update logic...
        sleep(ticks)
```

**Problem**:
- Not called from InitializeWorld()
- May start before world is ready
- No visibility into boot sequence
- Can't track completion or failure

**Examples**:
- `Phase13C_EconomicCycles.dm`: `set background=1; set waitfor=0`
- `AdvancedEconomySystem.dm`: Economy update loop
- `CombatProgressionLoop.dm`: Combat progression tick
- `CookingSystem.dm`: Multiple background loops
- `CrisisEventsSystem.dm`: Crisis monitoring loop
- `_lighting_update_loop()` in `Fl_LightingIntegration.dm`

### Issue 2: Lighting System Placeholder

**Current Phase 3**:
```dm
LogInit("PHASE 3: Day/Night & Lighting Cycle (50 ticks)", 50)

// Note: Client lighting planes (obj/lighting_plane) are created per-client
// in client/draw_lighting_plane() which is called on Login().
// The global day/night overlay animation loop starts independently.

spawn(50) RegisterInitComplete("lighting")
```

**Problem**:
- No actual lighting initialization
- Unified lighting system not integrated
- Day/night cycle not started
- Comments indicate incomplete design

### Issue 3: No Boot-Time Diagnostics

**Missing Information**:
- How long does each phase take?
- Which phases run in parallel?
- What's the critical path?
- Why does Phase 6 take 60 ticks (375-435)?

---

## Solution: Three-Part Refactoring

### Part 1: Integrate Lighting System (Phase 3)

**Current** (Placeholder):
```dm
spawn(50) RegisterInitComplete("lighting")
```

**Proposed** (Complete):
```dm
spawn(50)
    InitLightingIntegration()           // Initialize unified lighting
    start_day_night_cycle()             // Start background day/night loop
    RegisterInitComplete("lighting")
```

**Integration Details**:
- Calls `InitUnifiedLighting()` to setup registries
- Starts `start_day_night_cycle()` background loop
- Depends on: Time system (Phase 1) ✅, Client login (not startup)
- Enables: Spell lighting, weather effects, environmental ambience

---

### Part 2: Centralize Background Loops

**New File**: `dm/BootSequenceManager.dm`

**Purpose**: Central registry for all background loops

**Structure**:
```dm
var/global/list/BACKGROUND_LOOPS = list()

proc/RegisterBackgroundLoop(name, start_proc, phase_dependency)
    // Register loop to start at specific phase
    BACKGROUND_LOOPS[name] = list("proc" = start_proc, "phase" = phase_dependency)

proc/StartBackgroundLoops(phase)
    // Called during InitializeWorld at each phase
    for(var/name in BACKGROUND_LOOPS)
        var/info = BACKGROUND_LOOPS[name]
        if(info["phase"] == phase)
            call(info["proc"])()
```

**Migration Strategy**:

**BEFORE** (scattered):
```dm
// In Phase13C_EconomicCycles.dm:
proc/InitializeEconomicCycles()
    set background = 1
    set waitfor = 0
    while(1)
        // Economic simulation...
        sleep(50)
```

**AFTER** (centralized):
```dm
// In BootSequenceManager.dm:
spawn(393)  // Phase 13C startup
    RegisterBackgroundLoop("economic_cycles", /proc/EconomicCyclesBackgroundLoop, 393)
    StartBackgroundLoops(393)
    RegisterInitComplete("economic_cycles")

// In Phase13C_EconomicCycles.dm:
proc/EconomicCyclesBackgroundLoop()
    set background = 1
    set waitfor = 0
    while(world_initialization_complete)  // Gate on initialization
        // Economic simulation...
        sleep(50)
```

---

### Part 3: Add Boot-Time Diagnostics

**New File**: `dm/BootTimingAnalyzer.dm`

**Purpose**: Track and report phase timing

**Data Collection**:
```dm
var/global/list/phase_timings = list()  // Track each phase duration

proc/LogPhaseStart(phase_name)
    phase_timings[phase_name] = list("start" = world.time)

proc/LogPhaseComplete(phase_name)
    if(phase_name in phase_timings)
        phase_timings[phase_name]["end"] = world.time
        phase_timings[phase_name]["duration"] = world.time - phase_timings[phase_name]["start"]
```

**Output** (on boot complete):
```
═══════════════════════════════════════════════════════════════
BOOT SEQUENCE TIMING ANALYSIS
═══════════════════════════════════════════════════════════════
Phase 1: Time System              2 ticks (0%)
Phase 2: Infrastructure          55 ticks (13%)
Phase 3: Lighting Integration    10 ticks (2%)  ← NEW
Phase 4: Special Worlds         250 ticks (59%) ← Parallelizable
Phase 5: NPC/Recipe Systems     100 ticks (23%)
Phase 6: Economic Systems        60 ticks (14%)
...
───────────────────────────────────────────────────────────────
CRITICAL PATH: Phases 1 → 2 → 4 → 5 → 6
Total Boot Time: 426 ticks (10.6 seconds)
Estimated Parallel Improvement: -15% (if worlds run together)
═══════════════════════════════════════════════════════════════
```

---

## Implementation Steps

### Step 1: Add Lighting Integration to Phase 3
**File**: `dm/InitializationManager.dm`  
**Change**: Replace Phase 3 placeholder with lighting calls  
**Impact**: Enables all lighting features (spells, weather, day/night)

### Step 2: Create BootSequenceManager.dm
**File**: Create `dm/BootSequenceManager.dm`  
**Purpose**: Central registry for background loops  
**Impact**: Visibility + control over all startup sequences

### Step 3: Create BootTimingAnalyzer.dm
**File**: Create `dm/BootTimingAnalyzer.dm`  
**Purpose**: Boot diagnostics and timing analysis  
**Impact**: Understanding bottlenecks, optimization opportunities

### Step 4: Audit Background Loops
**File**: All codebase files with `set background=1`  
**Action**: Identify loops and plan centralization  
**Timeline**: Document which loops can run in parallel

### Step 5: Migrate Critical Loops (Phase 2)
**Files**: 10-15 high-impact loops  
**Action**: Move to BootSequenceManager  
**Impact**: Better control, guaranteed initialization order

### Step 6: Update Phase Dependencies
**File**: `dm/InitializationManager.dm`  
**Action**: Add phase dependency comments  
**Impact**: Documentation + future-proofing

---

## Dependency Graph

```
CRITICAL PATH (Sequential):
┌─────────────────────────────────────────────┐
│ Phase 1: Time System (0s)                   │
└────────────────┬────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────┐
│ Phase 2: Infrastructure (1.4s)              │
│   - Map generation                          │
│   - Weather system                          │
│   - Zones & elevation                       │
└────────────────┬────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────┐
│ Phase 3: Lighting Integration (0.25s) ← NEW │
│   - Unified lighting system                 │
│   - Day/night cycle                         │
│   - Background loops                        │
└────────────────┬────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────┐
│ Phase 4: Special Worlds (6.25s)             │
│   Can run in PARALLEL:                      │
│   - Towns (1.25s)                           │
│   - Story world (1.5s)                      │
│   - Sandbox world (1.5s)                    │
│   - PvP world (1.5s)                        │
└────────────────┬────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────┐
│ Phase 5: NPC & Recipes (2.5s)               │
└────────────────┬────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────┐
│ Phase 6+: Economy & Advanced (2.0s)         │
└─────────────────────────────────────────────┘
```

---

## Estimated Impact

| Metric | Current | Proposed | Change |
|--------|---------|----------|--------|
| Boot Time | 426 ticks | 426 ticks | No change (sequential) |
| Visibility | Low (scattered loops) | High (central registry) | ✅ Better |
| Debugging | Difficult | Easy (diagnostics) | ✅ Better |
| Lighting Features | Partial | Complete | ✅ +100% |
| Maintainability | Medium | High | ✅ Better |

**Note**: Boot time only improves if Phase 4 worlds are truly parallelizable (BYOND fork support needed for >40% improvement).

---

## Files Affected

### Create (New)
- `dm/BootSequenceManager.dm` (150 lines)
- `dm/BootTimingAnalyzer.dm` (100 lines)

### Modify
- `dm/InitializationManager.dm` (Phase 3 update + dependency comments)
- `dm/Fl_LightingIntegration.dm` (already done)
- `Pondera.dme` (add lighting includes)

### Audit (No immediate changes)
- 50+ files with background loops (document, plan migration)

---

## Testing Checklist

- [ ] Boot completes with 0 errors
- [ ] `world_initialization_complete` set to TRUE after all phases
- [ ] Phase 3: Lighting system initializes correctly
- [ ] Phase 3: Day/night cycle starts (background loop visible in logs)
- [ ] Phase 3: Global lighting controls work (admin verb test)
- [ ] All 25+ phases register completion
- [ ] FinalizeInitialization validates critical systems
- [ ] Player login blocked until `world_initialization_complete == TRUE`
- [ ] Boot timing analyzer outputs timing breakdown
- [ ] No spurious spawn() calls starting before world ready

---

## Priority: High

**Reason**: Lighting system needs integration point, and boot sequence cleanup improves overall system stability and debuggability.

**Effort**: 4-6 hours (create 2 files, modify 1 file, test)

**Risk**: Low (changes isolated to initialization, no gameplay logic affected)

---

## Next Session Goals

1. ✅ Lighting system architecture (COMPLETE)
2. 🔄 Add lighting to Phase 3 of InitializeWorld()
3. 🔄 Create BootSequenceManager.dm
4. 🔄 Create BootTimingAnalyzer.dm
5. 🔄 Audit and document background loops
6. 🔄 Integration testing

