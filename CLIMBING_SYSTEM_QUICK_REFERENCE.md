# Climbing System - Quick Reference

## One-Line Integration

```dm
// In elevation/ditch or elevation/hill Entered() proc:
if(!M.AttemptClimbTraversal(target_elevation)) step_to(M, loc, 0)
```

## Core Functions

| Function | Usage | Returns |
|----------|-------|---------|
| `AttemptClimbTraversal(elev)` | Attempt to change elevation | 1=success, 0=fail |
| `CanAttemptClimb(elev)` | Check if rank allows attempt | 1=allowed, 0=blocked |
| `GetRankLevel(RANK_CLIMBING)` | Get player's climbing rank | 0-5 |
| `UpdateRankExp(RANK_CLIMBING, xp)` | Add XP to climbing | (automatic handling) |

## Quick Examples

### Ditch Entry (1.0 → 0.5)
```dm
if(istype(M, /mob/players))
    M.AttemptClimbTraversal(0.5)
```

### Hill Climb (1.0 → 2.0)
```dm
if(istype(M, /mob/players))
    M.AttemptClimbTraversal(2.0)
```

### Conditional Entry
```dm
if(istype(M, /mob/players))
    if(!M.CanAttemptClimb(target_elev))
        M << "You're not skilled enough!"
    else
        M.AttemptClimbTraversal(target_elev)
```

## Success Rates by Rank

| Rank | %Success | Risk |
|------|----------|------|
| 0 | 70% | High (5-13 damage) |
| 1 | 75% | High (5-11 damage) |
| 2 | 80% | Medium (5-9 damage) |
| 3 | 85% | Medium (5-7 damage) |
| 4 | 90% | Low (5 damage) |
| 5 | 95% | Very Low (3 damage) |

## XP Gains

- Easy climb (0.5): 6-6.5 XP
- Medium climb (1.0): 7-7.5 XP  
- Hard climb (1.5): 8-8.5 XP
- Very hard (2.0): 9-9.5 XP
- Failed attempt: 1 XP

## Player Variables

```dm
M.elevel             // Current elevation (1.0 = ground)
M.character.climbing_rank  // 0-5 skill level
M.HP                 // Reduced by fall damage on failure
```

## Constants

```dm
RANK_CLIMBING = "climbing_rank"  // Defined in !defines.dm
```

## Difficulty Calculation

```dm
elevation_diff = abs(target_elev - current_elev)
success_chance = clamp(70 + (rank*5) - (elev_diff*10), 20, 95)
```

## When Climbing is Called

The system provides the mechanics, but YOU must call it:

1. **From ditch entry**: When player steps on ditch slope, call `AttemptClimbTraversal(0.5)`
2. **From ditch exit**: When player climbs out, call `AttemptClimbTraversal(1.0)`
3. **From hill entry**: When player climbs hill, call `AttemptClimbTraversal(2.0)`
4. **From trench**: When player enters fortification trench, call `AttemptClimbTraversal(1.5)`

## Typical Flow

```
Player enters elevation object
    ↓
Check IsClimbableObject() → yes
    ↓
(Optional) Check CanAttemptClimb() → allowed?
    ↓
Call AttemptClimbTraversal(target_elev)
    ↓
Success? (70-95% chance)
    ├─ Yes: Elevation changed, XP awarded, movement allowed
    ├─ No: Fall damage taken, elevation unchanged, movement blocked
```

## Testing Your Integration

```dm
// Test ditch entry
/elevation/ditch
    Entered(mob/M)
        ..()
        if(istype(M, /mob/players))
            if(M.AttemptClimbTraversal(0.5))
                M << "You've entered the ditch!"
            else
                M << "You fell into the ditch!"
                step_to(M, loc, 0)  // Block movement
```

## Common Mistakes

❌ Forgetting to call the function (mechanics won't activate)  
❌ Using wrong elevation target (use 0.5 for ditch, 2.0 for hill)  
❌ Not checking return value (should block movement on failure)  
❌ Calling from wrong object type (only /mob/players should climb)

## See Also

- `CLIMBING_SYSTEM_INTEGRATION_GUIDE.md` - Full API reference
- `dm/ClimbingSystem.dm` - Source code (240 lines)
- `dm/UnifiedRankSystem.dm` - Rank mechanics
- `libs/Fl_ElevationSystem.dm` - Elevation system

---

**Quick Copy-Paste Template**:
```dm
/elevation/ditch
    Entered(mob/M)
        ..()
        if(istype(M, /mob/players))
            if(!M.AttemptClimbTraversal(0.5))
                step_to(M, loc, 0)  // Block on failure
```
