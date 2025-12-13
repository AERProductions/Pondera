# Sound System Audit - Complete Report
**Date**: December 8, 2025  
**Branch**: recomment-cleanup

---

## Executive Summary

The Pondera sound system is **transitioning from legacy implementations to a modern centralized architecture**. The codebase shows:

- ✅ **New centralized system** (SoundManager + SoundmobIntegration) in place and functional
- ⚠️ **Legacy code mixed in** with old soundmob() calls and commented-out implementations
- ⚠️ **Placeholder sounds** in crafting systems (fishing, refinement using "hammer" for all events)
- ❌ **_MusicEngine() corrupted** and disabled (line 257 in SoundEngine.dm)
- ❌ **No active music system** - background music undefined
- ✅ **Object sound attachment** working (Fire, ambient systems)
- ⚠️ **Soundmob listener sync** partially integrated (Z._updateListeningSoundmobs() called in Mov.dm)

---

## 1. All Function Calls to Sound Functions

### A. `AttachObjectSound()` - Attach persistent ambient sound to objects

**Definition**: `dm/SoundmobIntegration.dm:65`

**Active Calls**:
- `dm/Light.dm:534` → **Fire object** - `AttachObjectSound(src, "fire", 250, 40)` - Attaches crackling fire sound when non-empty fire created
- `dm/UnifiedHeatingSystem.dm:166` → **HeatingStation** - `AttachObjectSound(src, "fire", 250, volume)` - Attaches fire sound to heating stations
- `dm/SoundmobIntegration.dm:32` → **Documentation example** - Shows fire sound attachment pattern

**Documentation/Examples**:
- `dm/SoundmobIntegration.dm:365` → Example fire sound: `AttachObjectSound(src, "fire", 250, 40)`
- `FIRE_SHADOWS_IMPLEMENTATION_GUIDE.md:296` → References fire sound example
- `FIRE_SHADOWS_CODE_REFERENCE.dm:76` → Reference implementation

---

### B. `StopObjectSound()` - Detach and stop ambient sound

**Definition**: `dm/SoundmobIntegration.dm:158`

**Active Calls**:
- `dm/Light.dm:542` → **Fire object deletion** - `StopObjectSound(fire_sound)` - Stops sound when fire is deleted
- `dm/UnifiedHeatingSystem.dm:62` → **HeatingStation deletion** - `StopObjectSound(fire_sound)` - Cleanup on station deletion
- `dm/UnifiedHeatingSystem.dm:171` → **Extinguish action** - `StopObjectSound(fire_sound)` - Stops sound when fire extinguished

**Documentation/Examples**:
- `dm/SoundmobIntegration.dm:369` → Example: `StopObjectSound(fire_sound)`
- `FIRE_SHADOWS_CODE_REFERENCE.dm:99` → Reference implementation
- `LIGHTING_SYSTEM_COMPARATIVE_ANALYSIS.md:123` → System overview

---

### C. `PlayEffectSound()` - Play one-shot effect sounds

**Definition**: `dm/SoundManager.dm:130`

**Active Calls**:
- `dm/SoundManager.dm:297` → **Crafting system** - `sound_mgr.PlayEffectSound("hammer", crafting_location)` - Anvil/forge impact sound
- `dm/LightningSystem.dm:244` → **Thunder strike** - `sound_mgr.PlayEffectSound("thunder", location)` - Thunder sound on lightning strike
- `dm/FishingSystem.dm:388-394` → **Fishing events** (4 calls, ALL PLACEHOLDERS):
  - Line 388: `sound_mgr.PlayEffectSound("hammer", location)` // Placeholder - Bite event
  - Line 390: `sound_mgr.PlayEffectSound("hammer", location)` // Placeholder - Struggle event
  - Line 392: `sound_mgr.PlayEffectSound("hammer", location)` // Placeholder - Failure event
  - Line 394: `sound_mgr.PlayEffectSound("hammer", location)` // Placeholder - Success event
- `dm/RefinementSystem.dm:145,148,151` → **Tool refinement** (3 calls, ALL PLACEHOLDERS):
  - Line 145: `sound_mgr.PlayEffectSound("hammer", location)` // File scrape placeholder
  - Line 148: `sound_mgr.PlayEffectSound("hammer", location)` // Whetstone scrape placeholder
  - Line 151: `sound_mgr.PlayEffectSound("hammer", location)` // Polish cloth placeholder

---

### D. `_SoundEngine()` - Low-level positional audio (LEGACY)

**Definition**: 
- Primary: `dm/SoundEngine.dm:213`
- Secondary: `dm/Snd.dm:175`

**Status**: ⚠️ **LEGACY - Some usage but mostly commented out**

**Commented-out Calls** (in Light.dm):
- `dm/Light.dm:1383` → `//var/sound/fire = _SoundEngine('snd/cleaned/fire2.ogg', src, range = 4, repeat = 1, volume = 60, falloff = 2)`
- `dm/Light.dm:1397` → `//var/sound/F2 = _SoundEngine('snd/cleaned/fire2.ogg', src, channel=11, range = 10, repeat = 1)//works but the range deletes the sound! boo`
- `dm/tools.dm:10896` → Same as Light.dm:1397

**Note**: These are all **disabled** due to BYOND engine incompatibility issues with positional sound lifecycle.

---

### E. `_MusicEngine()` - Background music playback

**Definition**: 
- Primary: `dm/SoundEngine.dm:257` 
- Secondary: `dm/Snd.dm:220`

**Status**: ❌ **CORRUPTED/DISABLED**

**Finding**: 
- `dm/SoundEngine.dm:257` declares the proc but the body is **empty/corrupted**
- `CODEBASE_AUDIT_DECEMBER_2025.md:118,281` documents this as "DISABLED: Corrupted proc body"
- **No active calls** to _MusicEngine() found in the codebase
- Background music is **completely non-functional**

**Documentation Comments**:
- `dm/MusicSystem.dm:12` → References it as separate from positional audio
- `dm/Music.dm:6,37` → Define music constants (MUSIC_ALDORYN, MUSIC_OVERWORLD) but these are never played

---

## 2. Soundmob Listener Management Functions

### A. `listenSoundmob()` - Player subscribes to sound updates

**Definition**: `dm/Sound.dm:386` (mob/players proc)

**Active Calls**:
- `dm/Basics.dm:308` → `listenSoundmob(soundmob)` - Subscribe to sound
- `dm/sfx.dm:211-213` → Forest bird system (2 calls):
  - Line 211: `M.listenSoundmob(fb)` - Player listens to forest birds
  - Line 213: `M.unlistenSoundmob(fb)` - Cleanup when leaving area

**Commented-out Calls** (Legacy):
- `dm/Basics.dm:378,380` → Old autotune initialization
- `dm/SavingChars.dm:1061,1094,1401,1406,1835-1874,2305-2343,2800-2840,3308-3348` → Character creation system (15+ commented calls)
- `dm/DRCH.dm:427,432,446` → Character creation related (3 calls)
- `dm/Light.dm:2481,2537,2776` → Fire object interaction (3 calls)
- `dm/Enemies.dm:874,908,923` → Enemy death handling (3 calls)
- `dm/tools.dm:10814,10866,10983` → Tool/object interaction (3 calls)

---

### B. `unlistenSoundmob()` - Player unsubscribes from sound

**Definition**: `dm/Sound.dm:393` (mob/players proc)

**Active Calls**:
- `dm/sfx.dm:213` → `M.unlistenSoundmob(fb)` - Cleanup when leaving forest area
- `dm/Sound.dm:354` → `unlistenSoundmob(soundmob)` - Automatic cleanup on logout

**Commented-out Calls** (20+ instances):
- `dm/Basics.dm:400` → Old logout handler
- `dm/Light.dm:1375,1448,2481,2486,2537,2777,2796,2881` → Fire interactions (8 calls)
- `dm/jb.dm:5216` → Crafting station interaction
- `dm/tools.dm:10814,10866,10936,10985` → Tool interactions (4 calls)
- `dm/_DRCH2.dm:704,706` → Character creation (2 calls)

---

### C. `_updateListeningSoundmobs()` - Sync soundmob listeners after movement

**Definition**: `dm/Sound.dm:375` (world-level proc)

**Active Calls**:
- `dm/Basics.dm:1011` → Called during logout cleanup sequence
- `dm/Mov.dm:65` → Called after player move completes (✅ **CRITICAL FIX**)
- `dm/Mov.dm:179` → Called after elevation change
- `dm/SavingChars.dm:1082` → Called during character login
- `dm/Sound.dm:375` → Called in multiple login/logout scenarios
- `dm/SoundmobIntegration.dm:19` → Documented as required integration point

**Purpose**: Ensures soundmobs follow players correctly when they move between chunks - fixes BYOND sound system bug where sounds play twice or skip.

---

## 3. All Sound Files Used

### Ambient Sounds (SoundManager.dm definitions)

| Sound Type | File | Radius | Volume | Category | Loop | Usage |
|-----------|------|--------|--------|----------|------|-------|
| crickets | `snd/nightcrickets.ogg` | 500 | 30 | nature | ✅ | Biome-specific |
| birds | `snd/cycadas.ogg` | 600 | 40 | nature | ✅ | Biome-specific, sfx.dm global (5 instances) |
| wind | `snd/wind.ogg` | 400 | 35 | weather | ✅ | Biome-specific, weather, thunder (placeholder) |
| rain | `snd/lrain.ogg` | 450 | 45 | weather | ✅ | Weather system |
| creek | `snd/creek.ogg` | 300 | 40 | water | ✅ | Water features, mapgen, oasis |
| waterfall | `snd/waterfall.ogg` | 350 | 45 | water | ✅ | Water features, sfx.dm (9 instances) |
| fire | `snd/fire.ogg` | 250 | 40 | craft | ✅ | Fire objects, heating stations |
| caves | `snd/caves.ogg` | 400 | 30 | environment | ✅ | Environment ambience |
| hammer | `snd/fire2a.ogg` | 350 | 70 | craft | ❌ | Crafting impacts, **PLACEHOLDER for fishing/refinement** |
| thunder | `snd/wind.ogg` | 1000 | 95 | weather | ❌ | Lightning strikes (**uses wind placeholder**) |

### Legacy/Additional Sound Files (sfx.dm)

| Sound File | Usage | Context |
|-----------|-------|---------|
| `snd/hollowwind.ogg` | Forest wind (6 instances) | sfx.dm forestwind objects |
| `snd/blowwind.ogg` | Desert wind | sfx.dm desert object |
| `snd/dizzywind.ogg` | Snow wind | sfx.dm snowwind object |
| `snd/waves.ogg` | Beach waves | sfx.dm beach object |
| `snd/waterfalldeep.ogg` | Deep waterfall | sfx.dm waterfall object |
| `snd/cleaned/fire2.ogg` | Fire (legacy format) | Commented-out in Light.dm (3 instances) |
| `snd/mus.ogg` | Background music | Music.dm defines MUSIC_ALDORYN, MUSIC_OVERWORLD (**never played**) |

---

## 4. Placeholder/Undefined Sound Issues

### A. Placeholder Sound Implementations

**Fishing System** - `dm/FishingSystem.dm:388-394`
- All 4 events use "hammer" sound as placeholder:
  - Bite event (line 388)
  - Struggle event (line 390)
  - Failure event (line 392)
  - Success event (line 394)
- ⚠️ **TODO**: Add proper fishing sounds (splash, reeling, success chime, break)

**Refinement System** - `dm/RefinementSystem.dm:145,148,151`
- All 3 tool stages use "hammer" as placeholder:
  - Filing stage (line 145) → Should be "file_scrape"
  - Sharpening stage (line 148) → Should be "whetstone_scrape"
  - Polishing stage (line 151) → Should be "polish_cloth"
- ⚠️ **TODO**: Add proper tool refinement sounds

**Lightning System** - `dm/LightningSystem.dm:234-244`
- Thunder uses "wind.ogg" as temporary placeholder
- `AddCustomSound("thunder", 'snd/wind.ogg', ...)` registers it dynamically
- ⚠️ **TODO**: Replace with actual thunder sound (`snd/thunder.ogg` or similar)

---

### B. Missing Sound Implementations

| Function | Expected | Actual | Status |
|----------|----------|--------|--------|
| `_MusicEngine()` | Background music | Empty/corrupted | ❌ Broken |
| Thunder SFX | Dedicated thunder sound | Wind placeholder | ⚠️ Placeholder |
| Fishing sounds | Splash, reeling, catch | Hammer (4x) | ⚠️ Placeholder |
| Refinement sounds | File, whetstone, polish | Hammer (3x) | ⚠️ Placeholder |

---

## 5. Fire Sound System (Complete)

### Implementation Architecture

**Active Fire Sound System**:
1. **Fire object** (`dm/Light.dm:520-545`)
   - Creates fire sound in `New()` if not "Empty Fire"
   - Calls `AttachObjectSound(src, "fire", 250, 40)`
   - Stops sound in `Del()` via `StopObjectSound(fire_sound)`

2. **UnifiedHeatingStation** (`dm/UnifiedHeatingSystem.dm:1-180`)
   - Manages heating/cooling state machine
   - `AudioFeedback()` proc controls sound lifecycle
   - Lights fire: `AttachObjectSound(src, "fire", 250, volume)`
   - Extinguishes: `StopObjectSound(fire_sound)`

3. **Sound Manager** (`dm/SoundManager.dm:1-364`)
   - Defines fire sound properties: `'snd/fire.ogg'`, radius=250, volume=40
   - Manages ambient sound catalog and conflicts

4. **Soundmob Integration** (`dm/SoundmobIntegration.dm:1-407`)
   - Creates persistent soundmob with `autotune=TRUE`
   - Automatically broadcasts to nearby players
   - Players listen via `_updateListeningSoundmobs()`

### Fire Sound State Transitions

```
Fire Created (non-empty)
    ↓
AttachObjectSound(src, "fire", 250, 40)
    ↓
soundmob created, broadcasts to world
    ↓
Players within range auto-subscribe via _updateListeningSoundmobs()
    ↓
Players hear crackling sound (snd/fire.ogg)
    ↓
Fire Deleted or Extinguished
    ↓
StopObjectSound(fire_sound)
    ↓
soundmob deleted, sound stops
```

---

## 6. Old/Commented-Out Sound System

### Legacy Soundmob Listener System

**Status**: ⚠️ **Partially active, mostly deprecated**

**Old Pattern** (commented out in many files):
```dm
// Old: Manual listener management
var/tmp/list/_listening_soundmobs = list()
var/tmp/list/_autotune_soundmobs = list()

// Manual registration (now auto via autotune=TRUE)
M.listenSoundmob(soundmob)
M.unlistenSoundmob(soundmob)
```

**New Pattern** (active in SoundmobIntegration):
```dm
// New: Automatic via autotune=TRUE
soundmob(attached_object, radius, file, TRUE, ...)  // autotune=TRUE
// _updateListeningSoundmobs() handles subscription automatically
```

### Legacy _SoundEngine Calls

**Disabled/Commented** in Light.dm:
- Lines 1357-1358: Direct soundmob creation attempts
- Line 1379-1381: Multiple soundmob patterns tested
- Lines 1383, 1397: _SoundEngine calls (commented with notes about range deletion bug)

**Reason**: BYOND engine bug where using `range=` parameter in _SoundEngine causes sound to be deleted unexpectedly when sound reaches edge of audible range.

---

## 7. FireShadow System References

**Files Mentioning FireShadow**:
- `FIRE_SHADOWS_IMPLEMENTATION_GUIDE.md:300` → Fire sound listed as ✅ DONE
- `FIRE_SHADOWS_CODE_REFERENCE.dm:76,99` → Fire sound attachment/detachment examples
- `dm/Light.dm:527` → "Initializes fire sound using generalized object sound system"

**Integration**: Fire shadows are **visual-only** system (lighting effects). Sound integration is part of unified fire system, not separate.

---

## 8. Sound System Integration Points

### Current Active Integration

| System | File | Integration Method | Status |
|--------|------|-------------------|--------|
| Fire objects | `dm/Light.dm` | AttachObjectSound/StopObjectSound | ✅ Active |
| Heating stations | `dm/UnifiedHeatingSystem.dm` | AudioFeedback() procs | ✅ Active |
| Lightning strikes | `dm/LightningSystem.dm` | PlayEffectSound("thunder") | ✅ Active |
| Fishing mini-game | `dm/FishingSystem.dm` | PlayEffectSound() (placeholder) | ⚠️ Placeholder |
| Tool refinement | `dm/RefinementSystem.dm` | PlayEffectSound() (placeholder) | ⚠️ Placeholder |
| Water features | `mapgen/_water.dm:69` | soundmob() direct | ⚠️ Legacy |
| Weather effects | `dm/Particles-Weather.dm:50,64` | soundmob() direct | ⚠️ Legacy |
| Forest ambience | `dm/sfx.dm:61-86` | Global soundmob() objects | ⚠️ Legacy |
| Movement sync | `dm/Mov.dm:65,179` | Z._updateListeningSoundmobs() | ✅ Active |
| Logout cleanup | `dm/Sound.dm:354` | unlistenSoundmob(soundmob) | ✅ Active |

---

## 9. Undefined/Broken Sound Functions

### Function Issues

| Function | Location | Status | Issue |
|----------|----------|--------|-------|
| `_MusicEngine()` | `dm/SoundEngine.dm:257` | ❌ Broken | Body is empty/corrupted, never called |
| `_SoundEngine()` | `dm/SoundEngine.dm:213` | ⚠️ Disabled | BYOND range deletion bug, all uses commented |
| `PlayWeatherSound()` | `dm/WeatherParticles.dm:117` | ⚠️ Defined but unused | Proc exists but never called |
| `PlayFishingSound()` | `dm/FishingSystem.dm:380` | ⚠️ Unused | Defined but not called; uses PlayEffectSound directly instead |
| `PlayRefinementSound()` | `dm/RefinementSystem.dm:136` | ⚠️ Unused | Defined but not called; uses PlayEffectSound directly instead |
| `AudioFeedback()` | `dm/UnifiedHeatingSystem.dm:155` | ✅ Active | Works correctly with fire sound system |

---

## 10. Summary Table: All Sound Calls by File

### dm/Light.dm
```
Line 534:   AttachObjectSound(src, "fire", 250, 40)  [New() Fire init]
Line 542:   StopObjectSound(fire_sound)               [Del() Fire cleanup]
Lines 1357-1397: Commented legacy soundmob/SoundEngine calls (3 variants disabled)
Lines 2052,2075,2354,2442,2474-2477: Commented listener calls (ancient code)
```

### dm/UnifiedHeatingSystem.dm
```
Line 62:    StopObjectSound(fire_sound)               [Del() cleanup]
Line 166:   AttachObjectSound(src, "fire", 250, volume) [Light/ignite]
Line 171:   StopObjectSound(fire_sound)               [Extinguish action]
Line 155:   AudioFeedback() proc                      [Audio control]
```

### dm/SoundManager.dm
```
Line 7:     Global var sound_mgr initialized
Line 21-85: InitializeAmbientSounds() - defines all 10 sound types
Line 88:    PlayAmbientSound() - main ambient sound API
Line 130:   PlayEffectSound() - effect sound API
Line 160:   StopAmbientSound()
Line 174:   StopAllAmbientSounds()
Line 182:   StopSoundCategory()
Line 192:   AddCustomSound()
```

### dm/SoundmobIntegration.dm
```
Line 65:    AttachObjectSound() - main proc
Line 114:   PlayObjectEffectSound()
Line 158:   StopObjectSound() - main proc
Line 177:   UpdateObjectSoundVolume()
Line 196:   UpdateObjectSoundState()
Line 220:   CountObjectSounds()
Line 230:   GetObjectSounds()
Line 240:   StopAllObjectSounds()
Line 254:   ListActiveObjectSounds()
Line 270:   VerifyObjectSoundHealth()
Line 296:   GetObjectSoundReport()
```

### dm/LightningSystem.dm
```
Line 226:   PlayThunderSound() proc
Line 234:   AddCustomSound("thunder", 'snd/wind.ogg', ...)
Line 244:   sound_mgr.PlayEffectSound("thunder", location)
```

### dm/FishingSystem.dm
```
Line 380:   PlayFishingSound() proc (unused)
Line 388:   sound_mgr.PlayEffectSound("hammer", location)  [Bite - placeholder]
Line 390:   sound_mgr.PlayEffectSound("hammer", location)  [Struggle - placeholder]
Line 392:   sound_mgr.PlayEffectSound("hammer", location)  [Failure - placeholder]
Line 394:   sound_mgr.PlayEffectSound("hammer", location)  [Success - placeholder]
```

### dm/RefinementSystem.dm
```
Line 136:   PlayRefinementSound() proc (unused)
Line 145:   sound_mgr.PlayEffectSound("hammer", location)  [File - placeholder]
Line 148:   sound_mgr.PlayEffectSound("hammer", location)  [Whetstone - placeholder]
Line 151:   sound_mgr.PlayEffectSound("hammer", location)  [Polish - placeholder]
```

### dm/Mov.dm
```
Line 65:    Z._updateListeningSoundmobs()  [After normal move]
Line 179:   Z._updateListeningSoundmobs()  [After elevation change]
```

### dm/Sound.dm
```
Line 48:    _addAutotuneSoundmob()
Line 59:    _removeAutotuneSoundmob()
Line 75:    soundmob() factory proc
Line 142:   mob.listenSoundmob() [listener registration]
Line 351:   spawn() for autotune listener broadcast
Line 354:   unlistenSoundmob() [listener cleanup]
Line 362:   _updateListeningSoundmobs() called
Line 375:   _updateListeningSoundmobs() definition
Line 386:   listenSoundmob() proc
Line 393:   unlistenSoundmob() proc
```

### dm/sfx.dm
```
Lines 61-86: Global soundmob objects (12 ambient sound definitions)
Lines 189,194,197: Commented listener calls
Lines 211,213: Active listenSoundmob/unlistenSoundmob calls
```

### dm/Basics.dm
```
Line 308:   listenSoundmob(soundmob)
Line 378,380: Commented autotune calls
Line 400:   Commented listener cleanup
Line 1011:  _updateListeningSoundmobs()
Line 1023:  listenSoundmob() proc
Line 1029:  unlistenSoundmob() proc
```

### dm/SavingChars.dm
```
Lines 1061,1082,1094: Character login sound handling
Lines 1349-3348: ~30 commented listener calls (legacy code)
```

### mapgen/_water.dm
```
Lines 24,69,76: soundmob() water sound initialization (legacy pattern)
```

### dm/Particles-Weather.dm
```
Line 50:    soundmob(src, 300, 'snd/wind.ogg', ...) [Wind particle]
Line 64:    soundmob(src, 300, 'snd/lrain.ogg', ...) [Rain particle]
```

### Legacy/Reference Files
```
dm/Snd.dm - Old sound engine definitions (parallel to SoundEngine.dm)
dm/SoundEngine.dm - Current engine with corrupted _MusicEngine()
dm/Music.dm - Music constants (MUSIC_ALDORYN, MUSIC_OVERWORLD) never used
dm/LogoutHandler.dm - CleanupSoundSystems() proc called on logout
```

---

## 11. Recommendations for Cleanup

### Priority 1: Critical Bugs
1. **Fix _MusicEngine() body** (`dm/SoundEngine.dm:257`)
   - Currently: Empty/corrupted
   - Action: Restore or remove entirely
   - Impact: Background music completely non-functional

2. **Add missing thunder sound**
   - Currently: Uses wind.ogg placeholder
   - Action: Create/import `snd/thunder.ogg` and update `dm/LightningSystem.dm:236`
   - Impact: Lightning events feel generic

### Priority 2: Placeholder Replacements
3. **Fishing sounds** (`dm/FishingSystem.dm:388-394`)
   - Replace 4 hammer calls with: splash, reeling tension, failure, success sounds
   - Files needed: `snd/fish_splash.ogg`, `snd/reel_tension.ogg`, `snd/fish_escape.ogg`, `snd/fish_catch.ogg`

4. **Refinement tool sounds** (`dm/RefinementSystem.dm:145,148,151`)
   - Replace 3 hammer calls with: file scrape, whetstone scrape, polish sounds
   - Files needed: `snd/file_scrape.ogg`, `snd/whetstone_scrape.ogg`, `snd/polish_cloth.ogg`

### Priority 3: Code Cleanup
5. **Remove commented-out legacy code** (20+ instances)
   - Remove or move legacy soundmob patterns to separate archive file
   - Files: Basics.dm, SavingChars.dm, Light.dm, DRCH.dm, Enemies.dm, etc.
   - Reduces confusion and improves code readability

6. **Remove duplicate sound engine files**
   - Keep only: `SoundEngine.dm` (active)
   - Remove/archive: `Snd.dm` (duplicate definitions)

7. **Unused proc cleanup**
   - `PlayWeatherSound()` - defined but never called
   - `PlayFishingSound()` - defined but never called
   - `PlayRefinementSound()` - defined but never called
   - Either use them or remove them

### Priority 4: Enhancement
8. **Add dynamic music system** using restored `_MusicEngine()`
   - Implement music changes based on location/biome
   - Create biome-specific music tracks

9. **Biome-specific ambient sounds**
   - Currently using generic ambience
   - Add biome variants (arctic wind, desert heat shimmer, jungle canopy, etc.)

---

## Appendix A: Complete File List with Sound Activity

### Files with Active Sound Code
- ✅ `dm/SoundManager.dm` - Central sound management (364 lines)
- ✅ `dm/SoundmobIntegration.dm` - Object sound attachment (407 lines)
- ✅ `dm/Light.dm` - Fire object sounds (3002 lines, sound code: 28 lines active)
- ✅ `dm/UnifiedHeatingSystem.dm` - Heating station sounds (351 lines, sound code: 40 lines)
- ✅ `dm/LightningSystem.dm` - Thunder sounds (active)
- ✅ `dm/Mov.dm` - Soundmob listener sync (critical integration)
- ✅ `dm/Sound.dm` - Soundmob listener procs (active)

### Files with Placeholder/Legacy Sound Code
- ⚠️ `dm/FishingSystem.dm` - 4 placeholder hammer calls
- ⚠️ `dm/RefinementSystem.dm` - 3 placeholder hammer calls
- ⚠️ `dm/Particles-Weather.dm` - Direct soundmob() calls (legacy pattern)
- ⚠️ `mapgen/_water.dm` - Direct soundmob() calls (legacy pattern)
- ⚠️ `dm/sfx.dm` - 12 global soundmob objects (legacy pattern)

### Files with Commented-Out Sound Code
- ⚠️ `dm/Light.dm` - 20+ commented calls (legacy patterns, _SoundEngine disabled)
- ⚠️ `dm/Basics.dm` - 10+ commented calls (legacy initialization)
- ⚠️ `dm/SavingChars.dm` - 30+ commented calls (legacy character creation)
- ⚠️ `dm/DRCH.dm`, `dm/Enemies.dm`, `dm/tools.dm` - Various commented patterns

### Files with Broken/Disabled Code
- ❌ `dm/SoundEngine.dm` - _MusicEngine() corrupted (line 257)
- ❌ `dm/Music.dm` - Music constants defined but never played
- ❌ `dm/Snd.dm` - Duplicate sound engine definitions

### Documentation Files
- `CODEBASE_AUDIT_DECEMBER_2025.md` - Notes _MusicEngine broken
- `FIRE_SHADOWS_IMPLEMENTATION_GUIDE.md` - Fire sound reference
- `FIRE_SHADOWS_CODE_REFERENCE.dm` - Code examples

---

## Appendix B: Sound Type Registry

### Sound Manager Registry (`SoundManager.dm:21-85`)
```dm
sound_properties = list()

"crickets"   → file='snd/nightcrickets.ogg',   radius=500, volume=30, category="nature", loop=TRUE
"birds"      → file='snd/cycadas.ogg',         radius=600, volume=40, category="nature", loop=TRUE
"wind"       → file='snd/wind.ogg',            radius=400, volume=35, category="weather", loop=TRUE
"rain"       → file='snd/lrain.ogg',           radius=450, volume=45, category="weather", loop=TRUE
"creek"      → file='snd/creek.ogg',           radius=300, volume=40, category="water", loop=TRUE
"waterfall"  → file='snd/waterfall.ogg',       radius=350, volume=45, category="water", loop=TRUE
"fire"       → file='snd/fire.ogg',            radius=250, volume=40, category="craft", loop=TRUE
"caves"      → file='snd/caves.ogg',           radius=400, volume=30, category="environment", loop=TRUE
"hammer"     → file='snd/fire2a.ogg',          radius=350, volume=70, category="craft", loop=FALSE
"thunder"    → file='snd/wind.ogg',            radius=1000, volume=95, category="weather", loop=FALSE
```

---

## Summary Statistics

- **Total sound function calls**: 50+ across codebase
- **Active modern system calls**: 14+ (AttachObjectSound, StopObjectSound, PlayEffectSound, _updateListeningSoundmobs)
- **Placeholder calls**: 7 (4 fishing + 3 refinement using "hammer")
- **Legacy commented calls**: 60+ (soundmob listener management, _SoundEngine)
- **Sound types defined**: 10 base + dynamic custom sounds
- **Sound files referenced**: 18 total OGG files
- **Broken/corrupted functions**: 1 (_MusicEngine)
- **Disabled functions**: _SoundEngine (due to BYOND bug)
- **Files needing cleanup**: 8+ with commented code

