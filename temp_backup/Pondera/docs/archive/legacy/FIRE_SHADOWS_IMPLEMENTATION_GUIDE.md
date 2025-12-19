# Fire Object Shadow Implementation Guide

## Overview

This guide demonstrates how to optionally add dynamic shadows to the Fire object using the refactored dynamic lighting system. This is a **low-risk enhancement** that can be tested independently.

## Decision Tree

### Should Pondera Add Fire Shadows?

```
Does your fire need visual shadows?
├─ YES → CPU overhead acceptable? (see Performance section)
│   ├─ YES → Implement via DynamicLighting
│   └─ NO → Skip for now, revisit later
└─ NO → Keep current system, focus on other features
```

## Performance Impact

### Single Fire with Dynamic Lighting

```
Radius 3, Intensity 1.0:
  - Affected turfs: ~28 (3² × π ≈ 28)
  - Per-tick cost: ~100-150 microseconds
  - Per-second cost: ~5-8 milliseconds (at 50 ticks/sec)
  - Percentage of frame (16.67ms typical): ~0.3-0.5% CPU per fire

With 10 simultaneous fires:
  - Total cost: ~3-5% CPU
  - Acceptable for MMO
  
With 50 simultaneous fires:
  - Total cost: ~15-25% CPU
  - Approaching warning zone
  - Monitor performance in production
```

### Memory Usage

```
Single fire shadow system:
  - Light object: ~100 bytes
  - Effect list (28 turfs): ~4 bytes per entry = ~112 bytes
  - Shading object updates: On-demand
  - Total overhead: <500 bytes per fire
  
Very lightweight.
```

## Implementation Steps

### Step 1: Enable Dynamic Lighting for Fire Z-Level

In `dm/Light.dm` (Fire object), at the **New()** proc initialization:

```dm
fire/New(location)
    ..(location)
    
    // Enable dynamic lighting on this z-level (one-time)
    if(!locate(/light) in world)  // Check if not already initialized
        lighting.init(icon='lighting.dmi', states=5, z_levels=list(src.z))
    
    // Create light source for this fire
    if(src.name != "Empty Fire")
        src.light = lighting.create_light(src, radius=3, intensity=1)
```

### Step 2: Clean Up Light on Fire Deletion

In `fire/Del()`:

```dm
fire/Del()
    // Clean up dynamic light
    if(src.light)
        src.light.Del()
        src.light = null
    
    ..()  // Call parent Del()
```

### Step 3: Add Light Variable to Fire

In `fire` object definition (top of Fire section in `Light.dm`):

```dm
fire
    var
        soundmob/fire_sound = null  // Existing
        light/light = null          // NEW: For shadow casting
        
        // ... rest of fire variables ...
```

### Step 4: Update Fire Verbs for Light Control

If you have verbs that affect fire state, update them:

```dm
fire/proc/intensify()
    // Increase heat
    intensity += 0.1
    if(src.light)
        src.light.set_intensity(intensity / 2)  // Scale intensity

fire/proc/dampen()
    // Decrease heat
    intensity -= 0.1
    if(src.light)
        src.light.set_intensity(intensity / 2)
```

## Icon File Requirements

The dynamic lighting system requires an icon file with multiple states representing brightness levels.

### Generating a Custom Icon

**Option 1: Use Provided Sample**
- File: `libs/dynamiclighting/lighting.dmi`
- States: 5 brightness levels
- Size: 32×32
- Format: From opaque (dark) to transparent (light)

**Option 2: Generate Custom**
1. Use `libs/dynamiclighting/icon-generator.dm`
2. Configure in world/New():
   ```dm
   icon_width = 32
   icon_height = 32
   states = 5
   darkest = 255   // Fully opaque black
   lightest = 0    // Fully transparent
   ```
3. Compile and run `/Generate Icon` verb in-game
4. Save resulting `.dmi` file

### Icon File Location

Place in Pondera root or `dmi/` folder:
```
Pondera/
  lighting.dmi          // Or custom name
  dmi/
    ...
```

Update init in `Light.dm`:
```dm
lighting.init(icon='dmi/my_lighting.dmi', states=5, z_levels=list(src.z))
```

## Testing Procedure

### Minimal Test (Local)

1. **Build project**:
   ```
   VS Code: Run task "dm: build - Pondera.dme"
   ```

2. **Check for compilation errors**:
   - Look for errors related to `light` or `lighting`
   - If errors occur, verify:
     - `DynamicLighting_Refactored.dm` is not in Pondera.dme (reference only)
     - Icon file path is correct

3. **Run game**:
   - Login to world
   - Find a Fire object
   - Look for darkening around fire
   - Observe shadow gradient

### Production Monitoring

Once deployed:

1. **Monitor CPU usage**:
   - Check frame time with 10+ simultaneous fires
   - Admin command: `/check_cpu` (if available)
   - Look for frame times increasing >10%

2. **Monitor memory**:
   - Check memory usage before/after fire creation
   - Should increase negligibly (<1MB per fire)

3. **Monitor for bugs**:
   - Fire shadows disappearing when fire moves (shouldn't happen)
   - Shadows not updating in real-time
   - Performance degradation over time

### Diagnostic Procs

Add to `_AdminCommands.dm` for troubleshooting:

```dm
admin/proc/check_dynamic_lighting()
    var/count = 0
    for(var/light/l in lighting.lights)
        count++
        world << "[l]: owner=[l.owner], radius=[l.radius], on=[l.on]"
    world << "Total lights: [count]"

admin/proc/toggle_fire_shadows()
    for(var/fire/f in world)
        if(f.light)
            f.light.toggle()
            world << "[f]: shadows toggled"
```

## Fallback Plan

If performance is problematic:

### Option 1: Disable Shadows
```dm
// In Fire/New(), comment out light creation:
// src.light = lighting.create_light(src, radius=3, intensity=1)
```

### Option 2: Reduce Light Radius
```dm
// Smaller radius = fewer affected turfs = less CPU
src.light = lighting.create_light(src, radius=2, intensity=1)  // Was 3
```

### Option 3: Reduce Light Count
```dm
// Only enable shadows for important fires (forge, anvil)
if(src.is_important_fire)
    src.light = lighting.create_light(src, radius=3, intensity=1)
```

### Option 4: Selective Z-Levels
```dm
// Only enable shadows on certain z-levels (dungeons, not overworld)
var/list/shadow_zlevels = list(5, 6, 7)  // Underground only
if(src.z in shadow_zlevels)
    if(!(locate(/light) in world))
        lighting.init(icon='lighting.dmi', states=5, z_levels=shadow_zlevels)
    src.light = lighting.create_light(src, radius=3, intensity=1)
```

## Comparison: With vs Without Shadows

### Visual Comparison

**Without Dynamic Lighting** (Current):
```
[F=Fire] [Ground] [Ground] [Ground]
                    ↑ No darkening
```

**With Dynamic Lighting** (Proposed):
```
[F=Fire] [Darker] [Medium] [Light]
  ↑ Shadow gradient around fire
  (Realistically darker near, lighter far)
```

### Player Immersion Impact

- **With shadows**: "Fire casts darkness, feels more realistic"
- **Without shadows**: "Fire exists but doesn't affect environment"

### Development Complexity

- **With shadows**: +20 lines of code in Fire object
- **Without shadows**: 0 additional code

## Next Steps

### If Implementing Fire Shadows:

1. **Step 1**: Copy code from "Implementation Steps" above
2. **Step 2**: Test locally with single fire
3. **Step 3**: Deploy to test server (or staging)
4. **Step 4**: Monitor performance for 1 week
5. **Step 5**: If stable, deploy to production

### If Not Implementing Now:

1. **Keep refactored reference file** for future exploration
2. **Revisit if** players request better lighting
3. **Consider** for underground zones/dungeons (Phase 4+)

## Integration with Other Systems

### Sound System (Already Integrated)

Fire already has sound attached:
```dm
fire_sound = AttachObjectSound(src, "fire", 250, 40)
```

Adding shadows would complement this:
- Fire sound: Auditory immersion ✅ (DONE)
- Fire shadow: Visual immersion ✅ (OPTIONAL)

### Movement System

If fire can be carried or moved:
- Set `light.mobile = 1` (automatic if owner is `/atom/movable`)
- Light will update position automatically
- Shadows follow fire in real-time

### Elevation System (Multi-Level Terrain)

If using elevation system (hills, ditches):
- Dynamic lighting works within elevation ranges
- Shadows respect elevation levels
- More sophisticated than plane-based system

## Troubleshooting

### Problem: Icon file not found

**Error**: `CRASH("You have to first tell dynamic lighting which icon file to use")`

**Solution**:
```dm
// Verify in Light.dm:
lighting.init(icon='lighting.dmi', ...)  // Must exist in root or dmi/

// Check file path:
// Pondera/lighting.dmi  OR  Pondera/dmi/lighting.dmi
```

### Problem: Shadows not showing

**Check**:
1. Is `lighting.init()` called in `world/New()`?
2. Is icon file valid (multiple states)?
3. Is Fire object's z-level included in `z_levels`?
4. Are you looking at correct z-level?

**Debug**:
```dm
/proc/test_shadows()
    var/fire/f = locate() in world
    if(f)
        world << "Fire found: [f]"
        world << "Fire light: [f.light]"
        if(f.light)
            world << "Light radius: [f.light.radius]"
            world << "Light on: [f.light.on]"
```

### Problem: Performance degradation

**Monitor**:
1. Check active light count: `world << lighting.lights.len`
2. Check affected turfs per light: Calculate radius² × π
3. If >100 turfs affected per tick, reduce radius

**Reduce Overhead**:
```dm
// Use smaller radius
src.light = lighting.create_light(src, radius=2, intensity=1)  // Was 3

// Or disable for non-important fires
if(!is_forge && !is_anvil)
    return  // Skip shadow for regular fires
```

## References

- **Full system**: `DynamicLighting_Refactored.dm`
- **Original library**: `libs/dynamiclighting/`
- **Comparative analysis**: `LIGHTING_SYSTEM_COMPARATIVE_ANALYSIS.md`
- **Current plane system**: `Light.dm`, `DayNight.dm`

## FAQ

**Q: Will this interfere with day/night cycle?**
A: No. Plane-based day/night and dynamic shadows are independent systems and will work together.

**Q: Can I have both fire shadows AND player torch shadows?**
A: Yes, but monitor CPU. Each light adds 50-100μs. Recommend limiting to 20-30 total.

**Q: Can shadows work underground without overworld shadows?**
A: Yes. Initialize lighting only for underground z-levels: `z_levels=list(5,6,7)` instead of all.

**Q: What if I want shadows on all objects, not just Fire?**
A: Add the same light creation code to any object type. But be mindful of CPU - 100+ lights would be expensive.

**Q: Can I control shadow darkness (intensity)?**
A: Yes. In `Fire/New()`:
```dm
src.light.set_intensity(0.5)  // Fainter shadows
src.light.set_intensity(1.5)  // Darker shadows
```

**Q: Will this work with pixel movement?**
A: Yes, if `lighting.pixel_movement = 1` and owner is `/atom/movable`.
