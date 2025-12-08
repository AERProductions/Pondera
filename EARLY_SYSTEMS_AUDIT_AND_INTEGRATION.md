# Early Systems Audit & Integration Plan

**Date**: December 7, 2025  
**Status**: Comprehensive audit complete with integration roadmap  

---

## Executive Summary

Five major early systems are ready for integration with the newly completed filtering/admin framework:

1. **TemperatureSystem.dm** - Thermal mechanics for smithing (150% complete, needs WeatherParticles integration)
2. **WeatherParticles.dm** - Dynamic weather with elevation awareness (85% complete, needs TemperatureSystem + DayNight)
3. **LightningSystem.dm** - Lightning strikes with particles/damage (95% complete, needs zone integration)
4. **DynamicZoneManager.dm** - Zone-based weather control (75% complete, needs TemperatureSystem)
5. **ForgeUIIntegration.dm** - Smithing UI with temperature feedback (100% complete, needs activation)

**Key Finding**: `current_temp` variable was planned for elevation-based temperature tracking but commented out. This should be activated and integrated with TemperatureSystem.

---

## System Inventory

### 1. TemperatureSystem.dm (150% - READY)

**Status**: Complete implementation, needs connection  
**Location**: `dm/TemperatureSystem.dm` (238 lines)  
**Purpose**: Centralized thermal state machine for forge items

**Key Components**:
```dm
#define TEMP_COOL 0            // Ready to quench
#define TEMP_WARM 1            // Cooling, workable
#define TEMP_HOT 2             // Fresh from forge

obj/items/thermable
    proc/Heat()                // Set to HOT state
    proc/IsWorkable()          // Can be worked?
    proc/IsQuenchable()        // Can be quenched?
    proc/GetTemperatureName()  // "Hot", "Warm", "Cool"
    proc/GetTemperatureColor() // RGB color for display
    proc/GetCoolingRate()      // Metal-type dependent
    proc/StartCooling()        // Background cooling process
    proc/UpdateDisplay()       // Update name/suffix
```

**Mob Integration Points** (not yet connected):
- `GetWorkableItems()` - Returns items at TEMP_HOT or TEMP_WARM
- `GetQuenchableItems()` - Returns items at TEMP_HOT only

**Connection Status**: ❌ Not connected to FilteringLibrary  
**Action Needed**: Register thermable items in FilteringLibrary, connect to forge procs

---

### 2. WeatherParticles.dm (85% - NEEDS CONNECTION)

**Status**: Particles defined, elevation logic ready, needs activation  
**Location**: `dm/WeatherParticles.dm` (302 lines)  
**Purpose**: Dynamic weather effects based on elevation

**Key Components**:
```dm
particles/fog, /mist, /dust_storm, /hail, /drizzle, /clear_weather

obj/weather_fx
    proc/SetWeatherType(type)
    proc/UpdateParticles()
    proc/PlayWeatherSound()

obj/elevation_weather_controller
    proc/CheckElevationWeather()
    proc/UpdateWeatherForElevation(mob/players/M)
        // Current elevation affects weather selection
        // Planned: current_temp variable (COMMENTED OUT at line 167)
```

**Elevation-Based Weather Rules** (already implemented):
- **< 1.0**: Water level → mist/fog (40%, 30%)
- **< 1.5**: Lowlands → drizzle (30%), fog (20%)
- **< 2.0**: Highlands → drizzle (40%), mist (20%)
- **< 2.5**: Mountains → hail (50%), mist (30%)
- **>= 2.5**: Peaks → hail (60%), mist (25%)

**Missing Piece**: `current_temp` variable planning was abandoned
```dm
// var/current_temp = 15  // Tracks temperature by elevation for future use
```

**Connection Status**: ⚠️ Partially connected to DayNight  
**Action Needed**: 
1. Activate and use current_temp for elevation-based temperature
2. Connect to TemperatureSystem for ambient temperatures
3. Link to MusicSystem for weather-based themes

---

### 3. LightningSystem.dm (95% - COMPLETE)

**Status**: Ready to deploy, needs zone integration  
**Location**: `dm/LightningSystem.dm` (306 lines)  
**Purpose**: Dynamic lightning with visual/audio/damage effects

**Key Components**:
```dm
obj/lightning_strike
    proc/ExecuteStrike()
    proc/CreateScorchMark(turf/T)
    proc/DamageNearbyMobs(turf/center)
    proc/DamageNearbyTurfs(turf/center)
    proc/ApplyStunEffect(mob/M, duration)

// Random lightning generation expected from DynamicZoneManager
// Called when weather type == "thunderstorm"
```

**Trigger Points** (not yet wired):
- WeatherParticles.dm calls should trigger lightning in thunderstorms
- DynamicZoneManager should create lightning_strike objects during thunderstorms

**Connection Status**: ⚠️ Partially implemented (particles yes, damage framework ready)  
**Action Needed**: Wire thunderstorm weather type to spawn lightning strikes

---

### 4. DynamicZoneManager.dm (75% - NEEDS INTEGRATION)

**Status**: Framework complete, needs system connections  
**Location**: `dm/DynamicZoneManager.dm` (complex, multi-part)  
**Purpose**: Zone-based weather/biome/resource management

**Key Components**:
```dm
zone_manager
    proc/InitializeDynamicZones()
    proc/UpdateZoneWeather()
    proc/GetZoneWeather(zone_id)
    proc/ApplyZoneEffects(mob/players/M)
```

**Missing Integrations**:
1. Temperature system (elevation → ambient temperature)
2. Music system (weather → dynamic music selection)
3. Lighting system (time of day + weather → lighting adjustments)

**Connection Status**: ⚠️ Initialized but underutilized  
**Action Needed**: Connect to TemperatureSystem, MusicSystem, DayNight

---

### 5. ForgeUIIntegration.dm (100% - READY TO USE)

**Status**: Complete, just needs to be invoked  
**Location**: `dm/ForgeUIIntegration.dm` (269 lines)  
**Purpose**: UI dialogs for temperature-aware forge/anvil operations

**Key Components**:
```dm
obj/Buildable/Smithing/verb
    Check_Forge_Status()         // Show forge state + items
    Heat_Item_Dialog()           // Select item to heat
    Quench_Item_Dialog()         // Select item to quench
    
obj/Buildable/WaterTrough/verb
    Check_Trough_Status()        // Show trough contents
```

**Dependency**: Requires `mob/proc/GetWorkableItems()` and `mob/proc/GetQuenchableItems()`

**Connection Status**: ✅ Complete but dormant  
**Action Needed**: Activate verbs, test with TemperatureSystem procs

---

## Integration Opportunities

### Opportunity 1: Temperature-Aware Weather

**From**: WeatherParticles.dm + TemperatureSystem.dm  
**To**: DynamicZoneManager + FilteringLibrary

**Current State**:
```dm
// In WeatherParticles.dm line 167 (commented out)
// var/current_temp = 15  // Tracks temperature by elevation for future use
```

**Integration Point**:
```dm
// PROPOSED: Connect elevation to ambient temperature
proc/GetAmbientTemperature(elevel)
    switch(elevel)
        if(< 1.0)
            return 20  // Water level - cool
        if(< 1.5)
            return 18  // Lowlands - moderate
        if(< 2.0)
            return 15  // Highlands - cool
        if(< 2.5)
            return 10  // Mountains - cold
        else
            return 5   // Peaks - freezing
```

**Benefits**:
- Player sees temperature change with elevation
- Affects forging mechanics (higher elevations = different forge behavior)
- Weather particles + temperature = immersive environment

---

### Opportunity 2: Music Follows Weather

**From**: MusicSystem.dm + WeatherParticles.dm  
**To**: music_manager.SelectTheme()

**Connection**:
```dm
// When weather changes, update music
obj/elevation_weather_controller/proc/UpdateWeatherForElevation(mob/players/M)
    // ... existing weather selection code ...
    
    // NEW: Update music based on weather
    switch(weather_type)
        if("fog", "mist")
            music_manager.SetTheme(M.client, "peaceful", 2)
        if("dust_storm")
            music_manager.SetTheme(M.client, "exploration", 2)
        if("hail")
            music_manager.SetTheme(M.client, "combat", 1)
        if("thunderstorm")
            music_manager.SetTheme(M.client, "boss", 3)
        else
            music_manager.SetTheme(M.client, "peaceful", 1)
```

**Benefits**:
- Weather dynamically changes music intensity
- Storm music during dangerous weather
- Peaceful music during calm weather

---

### Opportunity 3: Forge Temperature Integrated with Ambient

**From**: TemperatureSystem.dm + ambient temperature  
**To**: ForgeUIIntegration heating rates

**Connection**:
```dm
obj/items/thermable/proc/GetCoolingRate()
    // Current code: varies by metal type only
    // PROPOSED: Also factor in elevation
    
    var/metal_rate = GetMetalCoolingRate()
    var/altitude_factor = 1.0
    
    if(usr.elevel >= 2.5)
        altitude_factor = 0.7  // Cools faster at high altitude
    else if(usr.elevel < 1.0)
        altitude_factor = 1.3  // Cools slower at low altitude
    
    return metal_rate * altitude_factor
```

**Benefits**:
- Realistic forge mechanics (mountains = colder)
- Smithing at different elevations has strategic value
- Connects weather/elevation to crafting

---

### Opportunity 4: Lightning in Thunderstorms

**From**: LightningSystem.dm  
**To**: WeatherParticles.dm thunderstorm handling

**Connection**:
```dm
obj/elevation_weather_controller/proc/UpdateWeatherForElevation(mob/players/M)
    // When thunderstorm selected:
    if(weather_type == "thunderstorm")
        // Spawn lightning strikes randomly
        if(prob(30))  // 30% chance each check
            var/turf/T = get_random_turf_near(M, 10)
            new /obj/lightning_strike(T, 250, 35, 4)
```

**Benefits**:
- Thunderstorms become dangerous, not just visual
- Dynamic hazards encourage strategic movement
- Connects all weather systems together

---

### Opportunity 5: Filtering System for Temperature States

**From**: FilteringLibrary.dm  
**To**: Temperature-aware item categories

**Connection** (add to FilteringLibrary):
```dm
FilteringLibrary
    proc
        is_hot_item(item)
            if(!item) return 0
            var/obj/test = item
            if(!test) return 0
            if(istype(test, /obj/items/thermable))
                if(test:temperature_stage == TEMP_HOT)
                    return 1
            return 0
        
        is_workable_item(item)
            if(!item) return 0
            var/obj/test = item
            if(!test) return 0
            if(istype(test, /obj/items/thermable))
                return test:IsWorkable()
            return 0
        
        get_hot_items(container)
            // Returns all TEMP_HOT items
        
        get_workable_items(container)
            // Returns all TEMP_HOT or TEMP_WARM items
```

**Benefits**:
- Forge UI can use FilteringLibrary selection windows
- Consistent item selection across all systems
- Type-safe thermable item filtering

---

## Integration Roadmap

### Phase 1: Temperature System Activation (15 min)
1. ✅ TemperatureSystem.dm already complete
2. Add mob procs: `GetWorkableItems()`, `GetQuenchableItems()`
3. Activate ForgeUIIntegration verbs in forge objects
4. Test Heat/Cool/Quench flow

**Code Location**: Light.dm forge/anvil objects
**Files to Modify**: Light.dm (add proc calls)

### Phase 2: Weather-Temperature Integration (20 min)
1. Uncomment `current_temp` variable in WeatherParticles.dm
2. Create `GetAmbientTemperature(elevel)` proc
3. Update `UpdateWeatherForElevation()` to set `current_temp`
4. Connect to TemperatureSystem cooling rates

**Code Location**: WeatherParticles.dm + TemperatureSystem.dm
**Files to Modify**: WeatherParticles.dm, TemperatureSystem.dm

### Phase 3: Music Integration (10 min)
1. Connect weather changes to MusicSystem.SetTheme()
2. Map weather types → music themes
3. Test music transitions on elevation change

**Code Location**: WeatherParticles.dm + MusicSystem.dm
**Files to Modify**: WeatherParticles.dm, DynamicZoneManager.dm

### Phase 4: Lightning Activation (15 min)
1. Wire thunderstorm weather to lightning spawning
2. Set proper strike radius/damage for balance
3. Test lightning visuals + audio + damage

**Code Location**: WeatherParticles.dm, LightningSystem.dm
**Files to Modify**: WeatherParticles.dm

### Phase 5: Filtering Integration (10 min)
1. Add temperature-state filters to FilteringLibrary
2. Update ForgeUIIntegration to use selection windows
3. Replace input() dialogs with SelectionWindowSystem

**Code Location**: FilteringLibrary.dm, ForgeUIIntegration.dm
**Files to Modify**: FilteringLibrary.dm, ForgeUIIntegration.dm, Light.dm

---

## Technical Details

### Current Implementation Status

**TemperatureSystem.dm**: 100% complete
- All procs implemented
- All constants defined
- No missing functionality

**WeatherParticles.dm**: 85% complete (missing activation)
- Particles defined ✅
- Elevation logic ready ✅
- Temperature tracking commented out ❌
- Sound integration partial ⚠️

**ForgeUIIntegration.dm**: 100% complete (dormant)
- All UI dialogs ready ✅
- Temperature-aware ✅
- Just needs mob procs to exist

**LightningSystem.dm**: 95% complete
- Particles ready ✅
- Damage framework ready ✅
- Zone triggering not connected ❌

**DynamicZoneManager.dm**: 75% complete
- Zone framework ready ✅
- Weather selection working ✅
- System connections missing ❌

---

## Recommended Implementation Sequence

**Priority 1** (Do First - 30 min):
1. Add mob procs to retrieve temperature-aware items
2. Uncomment `current_temp` in WeatherParticles
3. Test forge heating/cooling with new ambient temperature

**Priority 2** (Then - 20 min):
1. Connect MusicSystem to weather changes
2. Test music transitions
3. Adjust theme selection logic as needed

**Priority 3** (Then - 15 min):
1. Wire lightning to thunderstorms
2. Test safety/balance of strike damage
3. Adjust strike frequency/radius

**Priority 4** (Polish - 10 min):
1. Update FilteringLibrary with temperature filters
2. Update ForgeUIIntegration to use new selection windows
3. Replace all broken input() calls in forge

---

## Expected Outcomes

### After Phase 1
- Forge heating/cooling works
- Temperature displayed on items
- UI shows current temperatures

### After Phase 2
- Temperature varies by elevation
- Weather changes with elevation
- Forge rates affected by altitude

### After Phase 3
- Music responds to weather
- Different themes for different weather types
- Seamless transitions

### After Phase 4
- Thunderstorms become dangerous
- Lightning creates dynamic hazards
- Strategic weather avoidance

### After Phase 5
- Unified selection windows across systems
- No more broken input() calls
- FilteringLibrary handles all item categories

---

## Files to Modify (Complete List)

1. `dm/TemperatureSystem.dm` - Add mob helper procs
2. `dm/WeatherParticles.dm` - Uncomment current_temp, connect systems
3. `dm/Light.dm` - Add forge temperature integration
4. `dm/ForgeUIIntegration.dm` - Activate and test
5. `dm/MusicSystem.dm` - Receive weather callbacks
6. `dm/LightningSystem.dm` - Adjust as needed
7. `dm/FilteringLibrary.dm` - Add temperature-state filters
8. `dm/DynamicZoneManager.dm` - Connect to music/weather

---

## Conclusion

**All five early systems are ready for integration**. The main blockers are:

1. `current_temp` variable needs to be activated (1 line)
2. Mob procs for temperature-aware items need implementation (10 lines)
3. Music/weather connection needs wiring (15 lines)
4. Lightning/thunderstorm connection needs wiring (10 lines)
5. FilteringLibrary needs 4 new temperature-state procs (30 lines)

**Total effort**: ~70 lines of code across 8 files, ~90 minutes of work.

**High-value integration**: All these systems work together to create a cohesive environment where elevation, weather, temperature, music, and danger all intertwine.
