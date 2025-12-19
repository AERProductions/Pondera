# Crafting Station Lighting Design - Phase 1b
**Status**: Design Phase (ready for implementation)  
**Date**: 2025-12-18  
**Dependencies**: Fl_LightingCore.dm, Fl_LightEmitters.dm, FireSystem.dm

---

## Executive Summary

Crafting stations (Cauldron, Forge, Anvil) should **only emit light when a fire is actively burning inside them**. This requires:

1. **Creating fire objects** for each crafting station (using modern `/obj/fire_source` pattern)
2. **Hooking lighting** into `OnFireLit()` and `OnFireExtinguished()` callbacks
3. **Using appropriate light shapes**:
   - **Cauldron**: OMNIDIRECTIONAL (light spreads all directions for cooking)
   - **Forge**: CONE (light concentrated inside the forge)
   - **Anvil**: PARTICLE EFFECTS only (sparks, not fire light)

---

## Architecture: Fire Lifecycle & Lighting

### Current Fire System Pattern (FireSystem.dm)

```dm
/obj/fire_source
  var/datum/fire/fire_obj        // Core fire data
  var/lit = FALSE                // Current state

  proc/OnFireLit()               // HOOK POINT #1 - Fire just ignited
  proc/OnFireExtinguished()      // HOOK POINT #2 - Fire died out
```

### Integration Pattern

When player ignites fire (flint+pyrite on kindling):
```
1. datum/fire/Light() called
2. fire.state = FIRE_STATE_LIT
3. source_obj:OnFireLit() called  ← HOOK INTO THIS
4. Crafting station creates light emitter
5. Light visible to all nearby players
```

When fire burns out (fuel depleted):
```
1. datum/fire/Extinguish() called
2. fire.state = FIRE_STATE_EXTINGUISHED
3. source_obj:OnFireExtinguished() called  ← HOOK INTO THIS
4. Crafting station removes light emitter
5. Light disappears
```

---

## Implementation: Per-Station Design

### 1. Cauldron (Omnidirectional Cooking Light)

**Current State**:
- `/obj/Buildable/Cauldron` - No fire object
- Uses `AttachWaterSound(src)` for ambient
- No lighting currently

**New Design**:

```dm
/obj/Buildable/Cauldron
  name = "Cauldron"
  icon = 'dmi/64/fire.dmi'
  icon_state = "cauldron"
  
  var/datum/fire/fire_obj = null      // NEW: Fire object reference
  var/obj/light_handle = null          // NEW: Tracking active light

/obj/Buildable/Cauldron/New(location)
  ..()
  if(location)
    src.loc = location
  
  // Create fire object (starts unlit)
  fire_obj = new /datum/fire(src.loc, "cauldron", src)
  
  AttachWaterSound(src)

// HOOK POINT: Called when player ignites the fire
/obj/Buildable/Cauldron/proc/OnFireLit()
  if(light_handle) return  // Already has light
  
  // Create omnidirectional light (cooks on all sides)
  light_handle = create_light_emitter(
    src,
    intensity = 0.8,           // Moderate light (cauldron isn't as bright as forge)
    color = "#FFAA44",         // Warm orange-red cooking light
    range = 5,                 // Medium range (hot cauldron)
    shape = LIGHT_OMNIDIRECTIONAL,  // Light spreads equally all directions
    duration = -1              // Persistent until fire dies
  )

// HOOK POINT: Called when fire burns out
/obj/Buildable/Cauldron/proc/OnFireExtinguished()
  if(light_handle)
    RemoveLight(light_handle)  // Uses Fl_LightingCore registry
    light_handle = null
```

**Light Characteristics**:
- **Shape**: OMNIDIRECTIONAL (cooks all sides equally)
- **Intensity**: 0.8 (warm, cooking-focused)
- **Color**: #FFAA44 (warm orange-red, inviting)
- **Range**: 5 tiles (medium-range illumination)
- **Falloff**: DEFAULT (linear fade)

---

### 2. Forge (Cone Fire Light - Concentrated)

**Current State**:
- `/obj/Buildable/Forge` - No fire object
- Uses `AttachFireSound(src)` for ambient
- No lighting currently
- Has `temperature` tracking variable

**New Design**:

```dm
/obj/Buildable/Forge
  name = "Forge"
  icon = 'dmi/64/fire.dmi'
  icon_state = "forge"
  
  var/datum/fire/fire_obj = null      // NEW: Fire object reference
  var/obj/light_handle = null          // NEW: Tracking active light
  var/temperature = 0                  // Existing: 0-100 heat level

/obj/Buildable/Forge/New(location)
  ..()
  if(location)
    src.loc = location
  
  // Create fire object (starts unlit)
  fire_obj = new /datum/fire(src.loc, "forge", src)
  
  AttachFireSound(src)

// HOOK POINT: Called when player ignites the fire
/obj/Buildable/Forge/proc/OnFireLit()
  if(light_handle) return  // Already has light
  
  // Create cone light (fire concentrated inside forge)
  light_handle = create_light_emitter(
    src,
    intensity = 1.0,           // Maximum light (forge is HOT)
    color = "#FFDD44",         // Bright golden-yellow forge fire
    range = 6,                 // Wider range (forge is brighter)
    shape = LIGHT_CONE,        // Light concentrated (inside forge)
    duration = -1              // Persistent until fire dies
  )
  
  src.temperature = 100       // FUTURE: Sync with actual burning

// HOOK POINT: Called when fire burns out
/obj/Buildable/Forge/proc/OnFireExtinguished()
  if(light_handle)
    RemoveLight(light_handle)  // Uses Fl_LightingCore registry
    light_handle = null
  
  src.temperature = 0         // FUTURE: Cool down
```

**Light Characteristics**:
- **Shape**: LIGHT_CONE (fire is concentrated inside forge, not spreading)
- **Intensity**: 1.0 (maximum - forge is hottest)
- **Color**: #FFDD44 (bright golden-yellow, intense)
- **Range**: 6 tiles (bright forge illuminates further)
- **Falloff**: DEFAULT (linear fade)

---

### 3. Anvil (Particle Effects Only - No Fire Light)

**Current State**:
- `/obj/Buildable/Smithing/Anvil` - No fire object
- Used for metal refinement
- No ambient sound or lighting

**New Design**:

```dm
/obj/Buildable/Smithing/Anvil
  name = "Anvil"
  icon = 'dmi/64/smithing.dmi'
  icon_state = "anvil"
  
  var/datum/fire/fire_obj = null      // NEW: Fire object reference (for consistency)
  // NOTE: Anvil does NOT use fire for cooking
  // It receives heat from nearby forge - see below

/obj/Buildable/Smithing/Anvil/New(location)
  ..()
  if(location)
    src.loc = location
  
  // Anvil doesn't create its own fire - it uses heat from nearby forge
  // No fire_obj needed for Anvil directly

// ALTERNATIVE: Anvil responds to NEARBY forge lighting
// (Sparks light up when anvil is being used WITH forge light nearby)
/obj/Buildable/Smithing/Anvil/proc/OnAnvilStrike()
  var/forge_nearby = locate(/obj/Buildable/Forge) in oview(2, src)
  
  if(forge_nearby && forge_nearby.light_handle)
    // Forge is nearby and lit - show spark particles
    emit_spark_particles(src, "#FFAA00", count=3, intensity=0.6)
    // Spark particles use ambient lighting system (already in Fl_LightEmitters.dm)
```

**Light Characteristics**:
- **Source**: Does NOT have own fire
- **Lighting**: Uses PARTICLE EFFECTS only (sparks from striking)
- **Dependencies**: Must be near lit forge to emit particles
- **Particles**: emit_spark_particles() (existing function in Fl_LightEmitters.dm)

---

## Integration Checklist

### Phase 1b Tasks

- [ ] **Cauldron Update**:
  - Add `var/datum/fire/fire_obj = null`
  - Add `var/obj/light_handle = null`
  - Update `New()` to create fire object
  - Add `OnFireLit()` proc (omnidirectional light)
  - Add `OnFireExtinguished()` proc (remove light)

- [ ] **Forge Update**:
  - Add `var/datum/fire/fire_obj = null`
  - Add `var/obj/light_handle = null`
  - Update `New()` to create fire object
  - Add `OnFireLit()` proc (cone light)
  - Add `OnFireExtinguished()` proc (remove light)

- [ ] **Anvil Verification**:
  - Confirm no fire object needed
  - Verify particle effect system works with nearby forge
  - Add `OnAnvilStrike()` for spark particles

- [ ] **FireSystem.dm Integration**:
  - Verify `/obj/fire_source` callbacks work with Buildable objects
  - Test fire lighting/extinguishing cycle

- [ ] **Fl_LightingCore.dm Verification**:
  - Ensure `create_light_emitter()` works with crafting stations
  - Ensure `RemoveLight()` properly tracks deactivation
  - Verify OMNIDIRECTIONAL and CONE shapes work correctly

### Testing Checklist

- [ ] Create cauldron → Player ignites fire → Omnidirectional light appears
- [ ] Cauldron light extinguishes when fire burns out
- [ ] Create forge → Player ignites fire → Cone light appears (inside forge)
- [ ] Forge light extinguishes when fire burns out
- [ ] Place anvil near lit forge → Spark particles light up on strike
- [ ] Multiple crafting stations with fires don't cause light conflicts
- [ ] Shadow/opacity system works with station lights
- [ ] Light rendering performance acceptable (monitor frame rate)

---

## Key Design Decisions

### Why Two Fire Systems?

The codebase has:
- **Legacy** `/obj/Buildable/Fire`: Direct spotlight calls (older code)
- **Modern** `/obj/fire_source`: Modular with callbacks (newer architecture)

We're using the **modern system** because:
1. It provides callback hooks (`OnFireLit()`, `OnFireExtinguished()`)
2. It's modular and doesn't duplicate light management
3. It integrates with FireSystem.dm's fuel/state tracking
4. We can add more fire sources without touching Light.dm

### Why Different Light Shapes?

- **Cauldron (OMNIDIRECTIONAL)**: Cooking requires even heat distribution all around the pot
- **Forge (CONE)**: Fire is inside the forge, light concentrated forward
- **Anvil (PARTICLES ONLY)**: Smithing doesn't use fire directly; sparks provide ambient light

### Non-Duplication Principle

We're **not** creating new light-emitting code. Instead:
1. FireSystem.dm provides fire lifecycle
2. Fl_LightingCore.dm provides light registry + API
3. Crafting stations hook into both via callbacks
4. Result: One unified lighting system managing all sources

---

## Next Steps

1. **Review Design**: Confirm approach matches user expectations
2. **Implement Cauldron**: Start with simplest case (omnidirectional)
3. **Implement Forge**: Add cone-shaped light
4. **Verify Anvil**: Ensure particle effects work correctly
5. **Phase 2**: Start BootSequenceManager.dm
6. **Phase 3**: Start BootTimingAnalyzer.dm

---

## Code References

- **FireSystem.dm**: Lines 1-150 (fire datum class & fire sources)
- **ExperimentationWorkstations.dm**: Lines 1-130 (Cauldron/Forge definitions)
- **Fl_LightingCore.dm**: create_light_emitter() & RemoveLight() functions
- **Fl_LightEmitters.dm**: emit_spark_particles() & other particle effects
- **Light.dm**: Lines 1350-1450 (legacy fire lifecycle example)

