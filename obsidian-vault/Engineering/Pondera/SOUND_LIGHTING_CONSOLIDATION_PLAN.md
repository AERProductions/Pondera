# Sound & Lighting Consolidation Plan (2025-12-19)

## Current Fragmentation Status

### Sound Systems (5 active systems)
| File | Purpose | Lines | Status | Used |
|------|---------|-------|--------|------|
| lib/koil/soundmob/ | 3D positional audio library | 230 | ✅ Core | YES - in footsteps, effects |
| Sound.dm | soundmob wrapper | 394 | ✅ Wrapper | YES - documentation |
| SoundEngine.dm | Music/UI channels (1-4) | 293 | ✅ Canonical | YES - music playback |
| SoundManager.dm | Ambient sound registry | 411 | ⚠️ Unknown init | YES - used by Fishing, Lightning |
| FootstepSoundSystem.dm | Terrain footsteps | 176 | ✅ Integrated | YES - called on move |
| SoundmobIntegration.dm | Object sound attachment | 400 | ✅ Wrapper | YES - uses sound_mgr |
| AudioIntegrationSystem.dm | Audio manager | 548 | ✅ Init at tick 45 | Unknown |
| Music.dm / MusicSystem.dm | Extra music handling | ? | Duplicate? | Unknown |

### Lighting Systems (Multiple versions)
| File | Purpose | Status |
|------|---------|--------|
| libs/Fl_LightingCore.dm | Registry + core (185 lines) | Possible duplicate |
| dm/Fl_LightingCore.dm | Comprehensive (270 lines) | Possible duplicate |
| Fl_LightingIntegration.dm | Integration layer | Active |
| DirectionalLighting.dm | Directional shadows | Active? |
| DirectionalLighting_Integration.dm | Directional integration | Active? |
| ShadowLighting.dm | Shadow effects | Active? |
| Lighting.dm | Legacy? | Active? |
| Light.dm | Object lights? | Active? |

## KEEP (Core Systems)

### 3D Positional Audio (Verified Essential)
```
lib/koil/soundmob/soundmob.dm    // Core 3D library (non-negotiable)
└─ Used by:
   ├─ Sound.dm (wrapper/documentation)
   ├─ FootstepSoundSystem.dm (terrain sounds)
   ├─ SoundmobIntegration.dm (object attachment)
   ├─ FishingSystem.dm (bite, cast, reel sounds)
   └─ LightningSystem.dm (thunder)
```

**API**: 
- `soundmob(attached, radius, file, autotune=TRUE, channel, volume, repeat)`
- `broadcast(target)` - broadcast to players
- `updateListener(mob)` - per-player volume/pan calculation
- Auto listener management

### Music/UI Audio (SoundEngine.dm)
```
dm/SoundEngine.dm (293 lines)    // Canonical music system
└─ Features:
   ├─ Dual channel pairs (1-2, 3-4)
   ├─ Smooth crossfading
   ├─ Per-client music_channels[4]
   └─ musicChannel() for allocation
```

### Ambient Sound Registry (SoundManager.dm)
```
dm/SoundManager.dm (411 lines)   // Sound property registry
└─ Provides:
   ├─ sound_properties["type"] = [file, radius, volume, category, loop]
   ├─ sound_mgr.PlayAmbientSound(type, location)
   ├─ sound_mgr.PlayEffectSound(type, location)
   └─ Category-based conflict prevention
   
Used by:
   ├─ FishingSystem.dm
   ├─ LightningSystem.dm
   └─ SoundmobIntegration.dm
```

**ISSUE**: SoundManager initialization NOT FOUND IN CODE  
**FIX**: Ensure `InitSoundManager()` is called from InitializationManager at Phase 2B tick 45

### Sound Object Integration (SoundmobIntegration.dm)
```
dm/SoundmobIntegration.dm (400 lines)  // Object sound attachment
└─ Provides:
   ├─ AttachObjectSound(object, type, radius, volume)
   ├─ PlayObjectEffectSound(location, type)
   ├─ StopObjectSound(sound)
   └─ UpdateObjectSoundVolume(sound, volume)
   
Depends on: sound_mgr (SoundManager.dm)
Used by: Forges, fires, anvils, etc.
```

### Footstep System (FootstepSoundSystem.dm)
```
dm/FootstepSoundSystem.dm (176 lines)  // Terrain-based footsteps
└─ Provides:
   ├─ FOOTSTEP_SOUNDS registry
   ├─ PlayFootstep() - plays based on current turf
   └─ Integration: called from movement.dm MovementLoop()
   
Uses: soundmob directly
```

---

## CONSOLIDATE

### Duplicate Lighting
- [ ] Check if libs/Fl_LightingCore.dm and dm/Fl_LightingCore.dm have different purposes
- [ ] If duplicates, keep dm/ version (270 lines = more complete)
- [ ] Remove libs/ version from Pondera.dme (line 337)
- [ ] Verify Fl_LightingIntegration.dm is the only integration layer needed

### Questionable Files (Need Audit)
- [ ] DirectionalLighting.dm / DirectionalLighting_Integration.dm - What do they add beyond Fl_LightingCore?
- [ ] ShadowLighting.dm - Specific feature or duplicate?
- [ ] Lighting.dm - Redundant with Fl_LightingCore?
- [ ] Light.dm - Object light source class?
- [ ] AudioIntegrationSystem.dm - Does it overlap with SoundManager?
- [ ] Music.dm / MusicSystem.dm - Do they overlap with SoundEngine?

---

## REMOVE FROM .dme

- [ ] libs/Fl_LightingCore.dm (line 337) - if duplicate of dm/Fl_LightingCore.dm

---

## ENSURE INITIALIZATION

- [ ] Verify `InitSoundManager()` is called at Phase 2B tick 45
- [ ] Verify `InitializeAudioSystem()` doesn't duplicate SoundManager
- [ ] Verify all 3D sound systems boot correctly
- [ ] Verify SoundEngine music channels initialize properly

---

## TESTING CHECKLIST

- [ ] Footsteps play when moving (3D audio, varies by terrain)
- [ ] Fire sounds loop and adjust volume with distance (3D audio)
- [ ] Music plays without distortion (SoundEngine, channels 1-4)
- [ ] No double-sounds or stuck audio
- [ ] Fishing effects play (bite, cast, reel)
- [ ] Thunder plays on lightning strike
- [ ] Hammer sounds play on anvil crafting

---

## Summary

**KEEP (No Changes)**:
- soundmob library (3D core)
- Sound.dm (wrapper)
- SoundEngine.dm (music)
- SoundManager.dm (registry) + fix initialization
- SoundmobIntegration.dm (object attachment)
- FootstepSoundSystem.dm (footsteps)

**CONSOLIDATE**:
- Lighting: Audit, remove duplicate Fl_LightingCore, verify integration

**VERIFY**:
- SoundManager initialization in InitializeWorld()
- AudioIntegrationSystem vs. SoundManager overlap
- Music.dm / MusicSystem.dm vs. SoundEngine.dm overlap

---

**Consolidation Status**: PLANNED  
**Next Action**: Audit initialization sequence, then test

