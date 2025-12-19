# BootSequenceManager Undefined Procs Audit
**Status**: Complete discovery phase  
**Date**: 2025-12-19  
**Goal**: Uncomment and fix proc references instead of leaving them commented

---

## Summary

Out of 20 commented proc references in BootSequenceManager.dm, the audit reveals:
- **7 EXIST** - Already implemented, just need uncommented
- **3 EXIST DIFFERENTLY** - Different naming, need to fix the reference
- **10 NEED STUBS** - Require minimal implementation

---

## Category 1: EXISTS & CAN UNCOMMENT ✅

### 1. spawn_heating_loop()
- **File**: `dm/CookingSystem.dm:310`
- **Status**: ✅ Fully implemented
- **Action**: UNCOMMENT line 190 in BootSequenceManager
- **Details**: 
  ```dm
  proc/spawn_heating_loop()
      set waitfor = 0
      set background = 1
      while(is_lit && src)
          current_temp = min(current_temp + rand(5, 15), 400)
          sleep(5)
  ```

### 2. spawn_cooking_loop()
- **File**: `dm/CookingSystem.dm:317`
- **Status**: ✅ Fully implemented
- **Action**: UNCOMMENT line 191 in BootSequenceManager
- **Details**: 270+ line implementation with temperature-based cooking

### 3. InitializeEconomicCycles()
- **File**: `dm/Phase13C_EconomicCycles.dm:24`
- **Status**: ✅ Fully implemented
- **Proc Reference**: Named differently - call once at Phase 5 start
- **Note**: Called during initialization, not as loop

### 4. InitializeEnemyAICombatAnimationSystem()
- **File**: `dm/EnemyAICombatAnimationSystem.dm:218`
- **Status**: ✅ Fully implemented
- **Proc Reference**: Named differently - call once at Phase 4
- **Note**: Initializes system, not a loop

### 5. InitializeCombatProgression()
- **File**: `dm/CombatProgressionLoop.dm:373`
- **Status**: ✅ Fully implemented
- **Proc Reference**: Named differently - call once at Phase 4
- **Note**: Initializes system, not a loop

### 6. InitializeNPCPathfinding()
- **File**: `dm/NPCPathfindingSystem.dm:12`
- **Status**: ✅ Fully implemented
- **Proc Reference**: Named differently - call once at Phase 4
- **Note**: Initializes system, not a loop

### 7. StartDeedMaintenanceProcessor()
- **File**: `dm/TimeSave.dm:210`
- **Status**: ✅ Fully implemented, already called in InitializationManager
- **Action**: Already being used at tick 40 in InitializationManager
- **Note**: This is a background loop that already exists

---

## Category 2: EXISTS WITH DIFFERENT NAME 🔄

### 8. _dynamic_pricing_loop() → SeasonalModifierUpdateLoop()
- **File**: `dm/EnhancedDynamicMarketPricingSystem.dm:260`
- **Existing Name**: `/proc/SeasonalModifierUpdateLoop()`
- **Status**: ✅ Fully implemented
- **Action**: Update BootSequenceManager reference to use correct name
- **Current**: `RegisterBackgroundLoop("dynamic_pricing", /proc/_dynamic_pricing_loop, 375, 100)`
- **Fix To**: `RegisterBackgroundLoop("dynamic_pricing", /proc/SeasonalModifierUpdateLoop, 375, 100)`

### 9. _supply_chain_monitoring_loop() → Phase13B function exists
- **File**: `dm/Phase13B_NPCMigrationsAndSupplyChains.dm`
- **Status**: 🔍 System exists, but no dedicated loop found
- **Action**: Need to check what function to call
- **Alternative**: Create stub that wraps Phase 13B supply chain updates

### 10. _world_events_loop() → Phase13A function exists
- **File**: `dm/Phase13A_WorldEventsAndAuctions.dm`
- **Status**: 🔍 System exists, but no dedicated loop found
- **Action**: Need to check what function to call
- **Alternative**: Create stub that wraps Phase 13A world events updates

---

## Category 3: SYSTEMS EXIST, NEED STUB IMPLEMENTATIONS 📝

These systems exist but don't have dedicated background loop functions. Need to create wrappers:

### 11. _temperature_monitoring_loop()
- **Related System**: `dm/EnvironmentalTemperatureSystem.dm`
- **Existing Functions**: 
  - `EnvironmentalTemperatureTick()` - Updates temperature each tick
  - `UpdateEnvironmentalTemperature(mob/players/M)` - Per-player update
- **Stub Implementation**: Call `EnvironmentalTemperatureTick()` periodically

### 12. _seasonal_modifier_processor_loop()
- **Related System**: `dm/EnhancedDynamicMarketPricingSystem.dm`
- **Existing Functions**: `UpdateAllSeasonalModifiers()`
- **Stub Implementation**: Call this function on schedule

### 13. _soil_degradation_processor_loop()
- **Related System**: Farming system (soil_health tracking)
- **Note**: Soil degrades naturally as crops grow
- **Stub Implementation**: Minimal - process soil updates for active farms

### 14. _npc_routine_processor_loop()
- **Related System**: NPC interaction system exists
- **Note**: NPCs have dialogue/reputation but no scheduled routine processor
- **Stub Implementation**: Call reputation decay and routine updates

### 15. _npc_pathfinding_loop()
- **Related System**: `dm/NPCPathfindingSystem.dm`
- **Existing System**: Pathfinding available but not continuously called
- **Stub Implementation**: Process NPC navigation updates

### 16. _npc_reputation_decay_loop()
- **Related System**: `dm/NPCReputationIntegration.dm`
- **Existing Functions**: `UpdateNPCKnowledgeTreeReputation()`
- **Stub Implementation**: Call reputation updates periodically

### 17. _enemy_ai_combat_animation_loop()
- **Related System**: `dm/EnemyAICombatAnimationSystem.dm`
- **Status**: Animation system exists but no loop
- **Stub Implementation**: Minimal - process animation updates

### 18. _combat_progression_loop()
- **Related System**: `dm/CombatProgression.dm`
- **Existing Functions**: Combat progression exists but called on-demand
- **Stub Implementation**: Process background combat progression

### 19. _crisis_event_processor_loop()
- **Related System**: `dm/CrisisEventsSystem.dm`
- **Existing Functions**: `CrisisEventMonitoringLoop()` - ALREADY EXISTS!
- **Action**: UPDATE reference to use actual function name
- **Current**: `RegisterBackgroundLoop("crisis_events", /proc/_crisis_event_processor_loop, 392, 500)`
- **Fix To**: `RegisterBackgroundLoop("crisis_events", /proc/CrisisEventMonitoringLoop, 392, 500)`

---

## Category 4: TERRITORY/WARFARE SYSTEMS - NOT YET IMPLEMENTED ❌

These require new implementation:

### 20. _territory_maintenance_loop()
- **Status**: ❌ No implementation found
- **Purpose**: Background deed maintenance checks
- **Note**: Related to deed system but separate from existing maintenance
- **Stub**: Minimal implementation

### 21. _territory_war_processor_loop()
- **Status**: ❌ No implementation found
- **Purpose**: PvP territory warfare mechanics
- **Stub**: Minimal implementation

### 22. _siege_event_processor_loop()
- **Status**: ❌ No implementation found
- **Purpose**: Siege mechanics for territory control
- **Stub**: Minimal implementation

### 23. _seasonal_territory_events_loop()
- **Status**: ❌ No implementation found
- **Purpose**: Seasonal territory events (different from crisis events)
- **Stub**: Minimal implementation

### 24. _performance_monitoring_loop()
- **Status**: ❌ No implementation found
- **Purpose**: Frame time monitoring and diagnostics
- **Related**: BootTimingAnalyzer exists but different purpose
- **Stub**: Minimal implementation

---

## ACTION ITEMS

### Phase 1: Quick Wins (Uncomment existing)
- ✅ Uncomment `spawn_heating_loop` (line 190)
- ✅ Uncomment `spawn_cooking_loop` (line 191)
- ✅ Fix reference to `SeasonalModifierUpdateLoop` (line 170)
- ✅ Fix reference to `CrisisEventMonitoringLoop` (line 216)

### Phase 2: Verify Phase 13 Systems
- 🔍 Determine correct loop functions for Phase 13A (world_events)
- 🔍 Determine correct loop functions for Phase 13B (supply_chains)

### Phase 3: Create Stub Implementations
- Create wrapper procs for systems that exist but lack dedicated loops:
  - `_temperature_monitoring_loop()` 
  - `_seasonal_modifier_processor_loop()`
  - `_soil_degradation_processor_loop()`
  - `_npc_routine_processor_loop()`
  - `_npc_pathfinding_loop()`
  - `_npc_reputation_decay_loop()`
  - `_enemy_ai_combat_animation_loop()`
  - `_combat_progression_loop()`

### Phase 4: Stub Territory/Warfare Systems
- Create minimal implementations for:
  - `_territory_maintenance_loop()`
  - `_territory_war_processor_loop()`
  - `_siege_event_processor_loop()`
  - `_seasonal_territory_events_loop()`
  - `_performance_monitoring_loop()`

---

## Build Impact

**Current**: 0 errors (all procs commented out)  
**After Phase 1**: Should remain 0 errors (existing systems)  
**After Phase 2-3**: 0 errors expected (stub implementations)  
**After Phase 4**: 0 errors expected (minimal territory stubs)

---

## Testing Strategy

1. Uncomment Phase 1 items
2. Build and verify 0 errors
3. Add Phase 13 system calls
4. Build and verify 0 errors
5. Add stub implementations one category at a time
6. Boot test each category
7. Final comprehensive test

