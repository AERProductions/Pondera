# Foundation Systems - Next Actions & Quick Wins

## Quick Wins (Highest Impact, Lowest Effort)

### 1. Sprint Speed Implementation (1 hour)
**Current State**: Sprint detected but speed not modified  
**Issue**: Sprinting=1 flag set but never used by movement speed calculation

**Implementation**:
```dm
// In movement.dm, modify GetMovementSpeed():
mob/proc/GetMovementSpeed()
	var/MovementDelay = src.MovementSpeed
	if(src.Sprinting)
		MovementDelay = max(1, MovementDelay - 1)  // Reduce delay by 1 tick (25ms faster)
	return max(1, MovementDelay)
```

**Testing**: Double-tap direction, verify visibly faster movement  
**Files to modify**: `dm/movement.dm` (1 proc)  
**Risk**: Low (isolated change)

---

### 2. Remove Deprecated Snd.dm (15 minutes)
**Current State**: Snd.dm marked obsolete but still in repo  
**Issue**: Dead code creates confusion

**Action**: Delete file `dm/Snd.dm`  
**Verification**: Build still succeeds (Pondera.dme doesn't include it)  
**Risk**: None (already superseded)

---

### 3. Add Elevation Check to Movement (1-2 hours)
**Current State**: Movement allows cross-elevation interaction  
**Issue**: Players could attack/interact with objects at different elevation levels

**Implementation**:
```dm
// In movement.dm, add to MovementLoop:
mob/proc/MovementLoop()
	...
	while(held or queued directions)
		var/turf/nextTile = get_step(src, active_direction)
		if(!Chk_LevelRange(nextTile))
			break  // Can't move to different elevation
		step(src, active_direction)
		sleep(src.GetMovementSpeed())
```

**Testing**: Try to move between elevation levels (should block)  
**Files to modify**: `dm/movement.dm` (1 proc)  
**Risk**: Low (adds guard, shouldn't affect normal gameplay)

---

## Medium Effort (2-4 hours each)

### 4. Footstep Sounds (2-4 hours)
**Files to modify**: `dm/movement.dm`, `dm/SoundEngine.dm`

**Implementation Outline**:
1. Create footstep sounds in `dmi/snd/footsteps/` (grass, stone, sand, etc.)
2. Add `proc/PlayFootstep(terrain_type)` to movement.dm
3. Call in MovementLoop after each step
4. Use SoundEngine._SoundEngine() for positional audio

**Testing**: Walk on different terrain, hear appropriate sounds  
**Risk**: Medium (new audio assets, integration point)

---

### 5. Complete Interaction Gates (5-7 hours)
**Files to modify**: `dm/NPCInteractionHUD.dm`, `dm/CharacterData.dm`

**Implementation Outline**:
1. Implement CacheNPCState() fully
2. Connect player_reputation to character_data field
3. Implement FilterOptionsForGates() with all gate types
4. Add interaction history tracking

**Testing**: Interact with NPCs, verify gates work (time, reputation, knowledge)  
**Risk**: Medium (cross-system integration)

---

## Long-Term Refactoring (4-6 hours)

### 6. Initialization Dependency System
**Files to modify**: `dm/InitializationManager.dm`, all initialization callers

**Implementation Outline**:
1. Define dependency graph for all systems
2. Replace hard-coded `spawn(N)` with `InitializeAfter(["dependency1", "dependency2"])`
3. Build DAG scheduler to determine optimal tick offsets
4. Add timeout detection and logging

**Risk**: High (touches all initialization code)  
**Benefit**: Maintainability, reduced boot time potential

---

## Current Blocking Issues

**None** - All systems functional, just incomplete features.

---

## Audit Findings Summary

| Category | Finding | Impact | Status |
|----------|---------|--------|--------|
| Movement | Sprint speed missing | Medium | Fixable in 1h |
| Movement | Elevation checks missing | Medium | Fixable in 1-2h |
| Sound | Deprecated file lingering | Low | Delete immediately |
| Sound | No footsteps | High | 2-4h to implement |
| Sound | Update interval too coarse (250ms) | Low | 30min optimize |
| Lighting | Multiple fragmented systems | Medium | Consolidation needed |
| Lighting | No spotlight pooling | Low | Performance issue |
| Initialization | Hard-coded ticks | Low | Brittle but works |
| Initialization | No timeout detection | Low | Add safety check |
| Interaction | Gates incomplete | High | 5-7h to complete |
| Interaction | No reputation integration | Medium | 2-3h to integrate |

**Overall Foundation Health**: 85/100
- Core systems work well
- Nice-to-have features incomplete
- Some dead code to clean up
- Performance optimizations available

