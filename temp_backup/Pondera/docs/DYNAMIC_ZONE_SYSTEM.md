# Dynamic Zone System - Implementation Guide

## Overview
This system transforms Pondera from a fixed-size map into an infinite procedurally-generated world with persistent zones in multiplayer and dynamic zones in single-player.

## Architecture

### Core Systems Created

1. **DynamicZoneManager.dm** - Zone lifecycle management
   - RequestZone(chunk_x, chunk_y) - Gets or creates zone
   - LoadZoneRegistry() - Loads persisted zones
   - MonitorPlayerProximity() - Pre-generates adjacent zones

2. **ImprovedDeedSystem.dm** - Zone ownership & permissions
   - Zone claiming via Deed object
   - Permission management per zone
   - Region integration for access control

3. **EdgeDetectionAndExpansion.dm** - Seamless world expansion
   - Monitors player proximity to chunk boundaries
   - Pre-generates zones before player reaches edge
   - Smooths elevation transitions between zones
   - Prevents figure-8 cliff issues

4. **SafeSpawnPlacement.dm** - Reliable spawn system
   - FindSafeSpawnTurf() - Locates accessible spawn
   - ValidateSpawnArea() - Ensures playability
   - CharacterCreationSpawn() - Integration with char creation

## Integration Points

### World Initialization (SavingChars.dm)
```dm
// In world/New():
InitializeDynamicZones()
```

This creates the zone manager singleton and starts the background monitor.

### Player Login
Players spawn via `CharacterCreationSpawn()` which finds safe turf in origin zone.

### Continuous Monitoring
Zone monitor runs every tick:
- Checks player positions
- Pre-generates zones within `generate_distance` (default 3 chunks)
- Smooths transitions between adjacent zones

## Zone Persistence

### Multiplayer Mode
- All generated zones saved to `MapSaves/Zone_[id]_[x]_[y].sav`
- Zone registry in `MapSaves/zone_registry.sav`
- Deeded zones have owner and permission lists
- Zones load from disk on demand

### Single-Player Mode
- Zones persist in current session
- Undeeded zones not saved after logout
- Claimed zones saved permanently
- Easy reset by deleting MapSaves folder

## Configuration

In `DynamicZoneManager.dm`, adjust:
```dm
generate_distance = 3      // Pre-generate 3 chunks ahead
chunk_size = 10            // Each zone is 10x10 turfs
```

## Safe Spawn System

Key features:
- Spiral search from preferred spawn
- Checks density, opacity, elevation
- Ensures adjacent turfs are accessible
- Carves out spawn area if needed

## Cliff Smoothing

Handles figure-8 issues via:
- Elevation comparison between adjacent turfs
- Isolatedcliff detection (surrounded by lower terrain)
- Boundary smoothing between zones

## Next Steps

1. Test zone generation in-game
2. Verify deed claiming system
3. Tune `generate_distance` for optimal pre-loading
4. Monitor performance with multiple players
5. Adjust cliff smoothing thresholds if needed

## Known Limitations

- Current implementation uses simple checkerboard biome selection (could use Perlin noise)
- Zone generation reuses existing MapGen code (may need optimization for on-demand)
- Figure-8 smoothing is basic (could be more sophisticated)

## Debugging

Enable debug output by checking `world.log`:
```dm
MSDebugOutput("Zone message")  // Logged to world.log
```

Zone info available via:
```dm
/mob/players/verb/TestSpawnLocation()
/mob/players/verb/DebugFindSpawns()
```
