# 🐛 RUNTIME ERROR FIX: Biome Resource Spawning

**Date**: December 16, 2025 21:55 UTC  
**Issue**: 30+ repeated runtime errors during map generation  
**Status**: ✅ FIXED

---

## Problem

When the world initialized and started generating maps, the biome system threw repeated runtime errors:

```
runtime error: new() called with an object of type /datum/resource_spawn_entry instead of the type path itself
proc name: SpawnFloralAtTurf (/datum/biome_definition/proc/SpawnFloralAtTurf)
```

This error occurred for every flower, deposit, and some tree spawns during procedural map generation.

---

## Root Cause

In `mapgen/BiomeRegistrySystem.dm`, the biome definition used two different approaches inconsistently:

1. **Initialization**: Created lists of `/datum/resource_spawn_entry` objects (which contain a `.resource_type` var pointing to the actual object type)
2. **Spawning**: Tried to `pick()` directly from these lists and call `new` on the datum objects

Example of the bug:
```dm
temperate.flower_spawns += new /datum/resource_spawn_entry(/obj/plant/Flower1, 0.5)
// Later...
var/flower_type = pick(flower_spawns)  // This picks a /datum/resource_spawn_entry object
new flower_type(t)  // ERROR: Can't call new() on a datum instance!
```

The `ore_cache` and `tree_cache` were correctly being populated with type paths in `Initialize()`, but `flower_cache` and `deposit_cache` didn't exist, so the code tried to spawn from the raw datum lists.

---

## Solution

Added proper caching for flowers and deposits, extracting `.resource_type` from the datum entries:

### 1. Added cache variables to biome_definition
```dm
var/list/flower_cache = list()
var/list/deposit_cache = list()
```

### 2. Populated caches in Initialize()
```dm
for(var/datum/resource_spawn_entry/e in flower_spawns)
	flower_cache += e.resource_type
for(var/datum/resource_spawn_entry/e in deposit_spawns)
	deposit_cache += e.resource_type
```

### 3. Updated spawn procs to use caches
```dm
// BEFORE:
var/flower_type = pick(flower_spawns)  // Picks a datum object
new flower_type(t)  // ERROR!

// AFTER:
var/flower_type = pick(flower_cache)  // Picks a type path
new flower_type(t)  // Works!
```

---

## Files Modified

| File | Changes |
|------|---------|
| `mapgen/BiomeRegistrySystem.dm` | Added `flower_cache` and `deposit_cache` vars; populated in `Initialize()`; updated spawn procs to use caches instead of raw spawn lists |

---

## Build Status

✅ Compilation: 0 errors, 18 warnings  
✅ Runtime: Biome spawning errors eliminated

---

## Testing

The fix ensures that during map generation (`Phase 2` of initialization):
- Flowers spawn correctly on turfs without throwing runtime errors
- Deposits (soil, tar, clay, obsidian) spawn correctly
- All resource pools use the cached type paths instead of datum objects

---

## Technical Details

**Pattern**: The biome system uses a two-tier approach:
1. **Spawn entries** (`/datum/resource_spawn_entry`): Define which types can spawn, with metadata (probability, weight)
2. **Type caches**: Lists of actual type paths extracted during initialization for O(1) runtime lookup

This separation allows for weighted selection during setup while ensuring fast, error-free spawning at runtime.
