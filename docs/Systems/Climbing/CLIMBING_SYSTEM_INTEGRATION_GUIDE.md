# Climbing System Integration Guide

## Overview

The **ClimbingSystem.dm** adds climbing mechanics for elevation transitions in Pondera. It integrates with the existing elevation system (`/elevation/ditch` and `/elevation/hill`) to provide skill-based climbing challenges with progressive difficulty.

## Key Features

### 1. **Skill-Based Climbing Progression**
- **5 Rank Levels** (0-5) with scaling difficulty
- **Base 70% success rate** at rank 0 → **95% at rank 5**
- Success chance formula: `70 + (rank × 5) - (elevation_change × 10)`
- Clamped between 20-95% to maintain challenge at all levels

### 2. **Elevation Transitions**
Climbing enables traversal of:
- **Ditches**: 1.0 (ground) ↔ 0.5 (ditch floor)
- **Hills**: 1.0 (ground) ↔ 2.0 (hilltop)
- **Trenches**: Future support for 1.5 elevation transitions

### 3. **Risk & Reward**
- **Success**: Elevation changes, XP awarded
- **Failure**: Fall damage (5-13 HP), stay at current elevation, minimal XP (1)
- **Fall Damage**: `5 + (elevation_change × 8) - (rank × 2)`, minimum 3 damage

### 4. **XP Rewards**
- **Success**: `5 + (elev_change × 2) + (rank × 0.5)` XP
  - Easy climb (0.5 difference): 6 XP at rank 0, 6.25 at rank 5
  - Medium climb (1.0 difference): 7 XP at rank 0, 7.5 at rank 5
  - Hard climb (2.0 difference): 9 XP at rank 0, 9.5 at rank 5
- **Failure**: 1 XP (learning from mistakes)

## API Functions

### Player Methods

#### `AttemptClimbTraversal(target_elev) → success (0/1)`
Called when player tries to change elevation
```dm
if(player.AttemptClimbTraversal(2.0))  // Try to climb to hilltop
    // Success - elevation changed, XP awarded
else
    // Failure - fall damage taken, stay at current elevation
```

#### `CanAttemptClimb(target_elev) → can_attempt (0/1)`
Checks if player rank allows this elevation change
```dm
if(player.CanAttemptClimb(0.5))  // Can attempt ditch?
    // Yes, proceed with climb
```

#### `updateClimbingUI()`
Updates HUD with climbing rank/XP display
```dm
player.updateClimbingUI()  // Called after rank changes
```

### Global Procs

#### `GetClimbingDifficulty(current_elev, target_elev) → difficulty (1-5)`
Returns difficulty rating for an elevation change
```dm
var/difficulty = GetClimbingDifficulty(1.0, 2.0)  // Returns 2 (moderate)
```

#### `GetClimbingXPReward(rank, elev_change, success) → xp_amount`
Calculates XP for a climb attempt
```dm
var/xp = GetClimbingXPReward(2, 1.0, 1)  // Returns 7-8 XP for success
```

#### `GetClimbingDescription(rank) → description`
Returns flavor text for skill level
```dm
var/desc = GetClimbingDescription(3)
// "You're an experienced climber. Steep slopes no longer worry you."
```

#### `IsClimbableObject(obj) → is_climbable (0/1)`
Determines if an object can be climbed (reserved for future fortress walls)
```dm
if(IsClimbableObject(some_object))
    // This object is climbable
```

## Integration with Elevation System

The climbing system **does not create new object types**. Instead, it adds mechanics to existing elevation objects:

1. **When player enters `/elevation/ditch`**:
   - Call `AttemptClimbTraversal(0.5)` to climb down
   - Success: Player elevation becomes 0.5, XP awarded
   - Failure: Player takes fall damage, stays at elevation 1.0

2. **When player exits `/elevation/ditch`**:
   - Call `AttemptClimbTraversal(1.0)` to climb back up
   - Success: Player elevation becomes 1.0, XP awarded
   - Failure: Player takes fall damage, stays at elevation 0.5

3. **When player enters `/elevation/hill`**:
   - Call `AttemptClimbTraversal(2.0)` to climb to peak
   - Success: Player elevation becomes 2.0, XP awarded
   - Failure: Player takes fall damage, stays at elevation 1.0

## Rank Progression Reference

| Rank | Success Rate | Fall Damage Range | XP Per Climb | Unlocks |
|------|--------------|-------------------|--------------|---------|
| 0 | 70% | 5-13 | 6-9 | Basic ditches, small hills |
| 1 | 75% | 5-11 | 6-9 | Standard hills, safe slopes |
| 2 | 80% | 5-9 | 7-9 | Steeper transitions, complex elevation |
| 3 | 85% | 5-7 | 7-10 | Deep trenches, fortification trenches |
| 4 | 90% | 5-5 | 8-10 | Expert climbing, minimal risk |
| 5 | 95% | 3-3 | 8-10 | Master climber, near-complete safety |

## How to Use in Existing Code

### Example 1: Ditch Entry
```dm
/elevation/ditch
	Entered(mob/M)
		..()
		if(istype(M, /mob/players))
			if(!M.AttemptClimbTraversal(0.5))
				step_to(M, loc, 0)  // Block movement on failure
```

### Example 2: Hill Climb
```dm
/elevation/hill
	Entered(mob/M)
		..()
		if(istype(M, /mob/players))
			if(!M.AttemptClimbTraversal(2.0))
				step_to(M, loc, 0)  // Block movement on failure
```

### Example 3: Check Before Allowing Climb
```dm
/elevation/trench
	Entered(mob/M)
		..()
		if(istype(M, /mob/players))
			if(!M.CanAttemptClimb(1.5))
				M << "You're not skilled enough for this trench!"
				return
			if(!M.AttemptClimbTraversal(1.5))
				step_to(M, loc, 0)
```

## Future Enhancements

1. **Fortress Wall Climbing**: Add climbable fortress walls at rank 4+
2. **Cliff Faces**: Vertical walls (2.0+ elevation changes) at rank 5
3. **Wet Surface Penalties**: Slippery surfaces reduce success chance by 20%
4. **Weather Effects**: Rain/snow increase difficulty
5. **Equipment Bonuses**: Climbing gear reduces fall damage
6. **Multiple Attempts**: Allow retrying failed climbs without cost
7. **Climbing Ropes**: Tools that guarantee success at cost of time

## Performance Notes

- Climbing checks are O(1) - just arithmetic and RNG
- No database lookups or heavy loops
- Safe to call on every elevation transition
- XP updates use existing `UpdateRankExp()` system (already optimized)

## Testing Checklist

- [ ] Rank 0 player can climb ditch (70% chance)
- [ ] Rank 5 player almost always climbs successfully (95%)
- [ ] Failed climbs deal 5-13 fall damage
- [ ] XP scales with difficulty (harder climbs = more XP)
- [ ] Elevation changes correctly on success
- [ ] Player stays at original elevation on failure
- [ ] UI updates show climbing progress
- [ ] Works across all ditch/hill objects

## Files Modified

- `dm/ClimbingSystem.dm` - New system (added to Pondera.dme before mapgen)
- `!defines.dm` - Added `RANK_CLIMBING = "crank"` constant (if not present)
- `dm/CharacterData.dm` - Added climbing rank variable (if integrating persistently)

## See Also

- `libs/Fl_ElevationSystem.dm` - Core elevation mechanics
- `dm/movement.dm` - Movement system (calls climbing checks)
- `dm/UnifiedRankSystem.dm` - Rank progression system
- `dm/ConsumptionManager.dm` - Similar skill progression pattern
