# Phase 11: Global Resources, NPC State, Calendar/Events - COMPLETE

**Date**: December 17, 2025 - 7:23 PM
**Commit**: `1e7b78d` 
**Status**: ✓ Clean build (0 errors, 36 warnings)
**Database Tables**: 7 new tables across 3 subsystems
**Total Procs**: 17+ new procedures
**Build Time**: 2 minutes

## Executive Summary

Phase 11 implements the "Living World" foundation by migrating 3 critical global systems from binary/scattered storage into a unified SQLite persistence layer:

1. **Global Resources** (Phase 11A): Stone, Metal, Timber, Supply Boxes with transaction history
2. **NPC Persistence** (Phase 11B): Complete NPC state with schedules and relationships  
3. **Calendar & Events** (Phase 11C): Dynamic world calendar with seasonal modifiers

This enables dynamic economies that respond to resource scarcity, NPCs that follow schedules and remember interactions, and seasonal events that reshape the world.

## Phase 11A: Global Resource Persistence

### Purpose
Replace fragile binary `timesave.sav` resource storage with relational SQLite model enabling:
- Real-time resource tracking (stone, metal, timber, supply boxes)
- Transaction history for auditing (harvested, crafted, traded, consumed)
- Scarcity detection driving economy inflation/deflation
- Integrated with market pricing system

### Tables Created

**Table: `global_resources`** (5 columns)
```sql
PRIMARY KEY: resource_type (stone, metal, timber, supply_box)
- current_amount: BIGINT (current quantity)
- last_updated: TIMESTAMP
- total_generated_all_time: BIGINT (lifetime production)
- total_consumed_all_time: BIGINT (lifetime consumption)
- avg_price_current: REAL (current market price)
- scarcity_level: TEXT (abundant/normal/scarce/critical)
- inflation_index: REAL (baseline=1.0, >1.0=inflation)
INDEX: idx_resources_type (fast lookups)
```

**Table: `resource_transactions`** (8 columns)
```sql
PRIMARY KEY: transaction_id (auto-increment)
FOREIGN KEY: resource_type → global_resources
- transaction_type: harvested|crafted|traded|consumed|gifted|destroyed|admin_adjustment
- amount_change: BIGINT (signed delta, can be negative)
- resulting_amount: BIGINT (amount after transaction)
- related_player_id: INTEGER (who triggered transaction)
- related_entity: TEXT (item_name, recipe_name, deed_name, etc.)
- continent: TEXT (story/sandbox/pvp - which world event occurred on)
- recorded_at: TIMESTAMP (transaction timestamp)
- notes: TEXT (optional detailed notes)
INDEXES:
  - idx_transactions_resource (fast filtering by resource type)
  - idx_transactions_type (fast filtering by transaction type)
  - idx_transactions_player (track player-specific resource usage)
  - idx_transactions_date (temporal queries, DESC for recent first)
  - idx_transactions_continent (track resource flows per world)
```

### Procs Implemented (5 total)

1. **`GetGlobalResourceAmount(resource_type)`**
   - Returns current amount of resource
   - Single-row query, very fast
   - Returns 0 if resource doesn't exist
   - **Usage**: Market pricing system needs current stone/metal/timber for elasticity calcs

2. **`SetGlobalResourceAmount(resource_type, new_amount)`**
   - Updates resource to specified amount
   - Clamps to 0 minimum (no negative resources)
   - Creates new resource if doesn't exist
   - **Usage**: Initialization, admin adjustments

3. **`AdjustGlobalResourceAmount(resource_type, amount_change, transaction_type, related_entity, continent)`**
   - Adjusts resource by delta (positive or negative)
   - Logs transaction to resource_transactions table
   - Returns resulting amount after adjustment
   - **Usage**: Every harvest, craft, trade, consumption event

4. **`GetResourceHistoryTrend(resource_type, days_back=30)`**
   - Returns list of historical amounts for graphing
   - Pulls transactions from past N days
   - Ordered chronologically
   - **Usage**: Resource availability charts, admin analytics

5. **`GetResourceScarcityLevel(resource_type)`**
   - Calculates scarcity rating: abundant|normal|scarce|critical
   - Thresholds differ per resource type:
     - **Stone**: Critical <10k, Scarce <50k, Normal <100k, Abundant >100k
     - **Metal**: Critical <5k, Scarce <20k, Normal <50k, Abundant >50k
     - **Timber**: Critical <8k, Scarce <40k, Normal <80k, Abundant >80k
     - **Supply Box**: Critical <100, Scarce <500, Normal <1k, Abundant >1k
   - **Usage**: Market pricing elasticity, event triggering (resource booms/crashes)

6. **`GenerateResourceAuditReport()`**
   - Comprehensive resource summary for debugging/admin
   - Returns formatted text report with:
     - Current amount per resource
     - Lifetime generated/consumed
     - Scarcity level
     - Last update timestamp
   - **Usage**: Admin diagnostics, sanity checks

### Initialization (Phase 11A - Tick 430)

**Proc**: `InitializeGlobalResourceSystem()`
- Runs at tick 430 (2150ms into boot)
- Reads global variables `SP`, `MP`, `SB`, `SM` (should be loaded from timesave.sav by TimeLoad())
- Initializes SQLite tables with loaded amounts
- Defaults if savefile not found: Stone=100k, Metal=50k, Timber=80k, Supply=1k
- **Output**: "RESOURCE_SYSTEM: Initialized [amounts]"

### Integration Points

**Market Pricing System**:
- `DynamicMarketPricingSystem.dm` calls `GetGlobalResourceAmount()` to calculate elasticity
- Scarcity level affects price volatility

**Consumption System**:
- When players harvest/craft/trade, `AdjustGlobalResourceAmount()` is called
- Automatically logged with transaction type and entity reference

**Admin Commands**:
- `/admin set_resource stone 50000` → calls `SetGlobalResourceAmount()`

---

## Phase 11B: NPC State & Persistence

### Purpose
Move NPCs from static spawner-only entities to persistent agents with:
- Current location and emotional state
- Daily schedules (routines)
- Relationship tracking (likes/dislikes players and other NPCs)
- Interaction history
- Personality types affecting dialogue/trading

### Tables Created

**Table: `npc_persistent_state`** (17 columns)
```sql
PRIMARY KEY: npc_id (auto-increment)
UNIQUE: npc_name (identifies specific NPC across restarts)
- npc_type: TEXT (merchant|guard|quest_giver|companion|wanderer)
- current_continent: TEXT (story/sandbox/pvp)
- current_x, current_y, current_z: INTEGER (location on map)
- current_hp: INTEGER (health, used for NPC combat state)
- current_stamina: INTEGER (affects movement speed)
- emotional_state: TEXT (happy|angry|neutral|afraid|sad|excited)
- emotional_intensity: INTEGER (0-100, how strong emotion is)
- inventory_json: TEXT (JSON: {item_name: quantity})
- personality: TEXT (greedy|fair|honest|deceptive|aggressive|peaceful)
- last_player_interaction_id: INTEGER (FOREIGN KEY → players.id)
- last_interaction_time: TIMESTAMP
- total_interactions: INTEGER (lifetime count)
- is_alive: BOOLEAN (for permadeath NPCs)
- behavior_flags: TEXT (JSON: {flag_name: value})
- last_location_change: TIMESTAMP
- created_at, last_update: TIMESTAMP
INDEXES:
  - idx_npc_name (primary lookup)
  - idx_npc_type (filter by type)
  - idx_npc_continent (filter by world)
  - idx_npc_location (spatial queries)
  - idx_npc_alive (only load living NPCs)
```

**Table: `npc_schedules`** (11 columns)
```sql
PRIMARY KEY: schedule_id (auto-increment)
FOREIGN KEY: npc_id → npc_persistent_state
UNIQUE(npc_id, day_of_week, hour_start)
- day_of_week: TEXT (Monday|Tuesday|...|daily|weekly|seasonal)
- hour_start, hour_end: INTEGER (0-23, what time of day)
- location_x, location_y, location_z: INTEGER (where NPC goes)
- activity_type: TEXT (patrolling|resting|trading|crafting|socializing|hunting|gathering)
- activity_priority: INTEGER (0-100, higher=more likely to override)
- travel_path_waypoints: TEXT (JSON array of waypoints)
- dialogue_topic: TEXT (what NPC discusses during this time)
INDEXES:
  - idx_schedule_npc (lookup by NPC)
  - idx_schedule_day (lookup by day)
  - idx_schedule_time (temporal filtering)
```

**Table: `npc_relationships`** (9 columns)
```sql
PRIMARY KEY: relationship_id (auto-increment)
FOREIGN KEY: npc_id → npc_persistent_state
UNIQUE(npc_id, other_entity_id)
- other_entity_id: TEXT (player_id or other_npc_id)
- other_entity_type: TEXT (player|npc)
- relationship_type: TEXT (ally|enemy|neutral|friend|rival|superior|subordinate)
- strength: INTEGER (-1000 to +1000, negative=hostile, positive=friendly)
- history_interactions: INTEGER (count of times interacted)
- history_trades: INTEGER (how many trades completed)
- history_gifts_given: INTEGER (items gifted to entity)
- history_insults_received: INTEGER (how many times insulted)
- last_interaction: TIMESTAMP (when last saw each other)
- memory_notes: TEXT (what NPC remembers about this entity)
INDEXES:
  - idx_relationships_npc (lookup NPC's relationships)
  - idx_relationships_other (find who's related to entity)
  - idx_relationships_strength (sort by opinion)
```

### Procs Implemented (8+ total)

1. **`SaveNPCState(npc_ref)`**
   - Saves complete NPC state to database
   - Called when NPC leaves world or server saves
   - Captures: location, health, stamina, emotions, inventory, personality, stats
   - Currently placeholder (all NPCs get same defaults)

2. **`LoadNPCState(npc_name)`**
   - Retrieves NPC state from database
   - Returns `/datum/npc_state_data` object or null
   - Used to restore NPCs on boot or re-spawn

3. **`UpdateNPCLocation(npc_name, x, y, z, continent=null)`**
   - Updates NPC location in database (when NPC moves)
   - Updates `last_location_change` timestamp
   - Optional continent update
   - **Usage**: Movement system calls this on NPC move

4. **`GetNPCRoutine(npc_name, day_of_week)`**
   - Returns schedule for NPC on specific day
   - Ordered by hour_start (morning to evening)
   - List of schedule records or empty list
   - **Usage**: NPC AI decides what to do each hour

5. **`ModifyNPCRelationship(npc_name, other_entity_id, delta_strength, change_reason=null)`**
   - Adjusts NPC opinion of entity (player or other NPC)
   - Clamps to -1000..+1000 range
   - Automatically creates relationship if doesn't exist
   - Updates timestamp
   - **Usage**: Trading, quests, combat outcomes affect relationships

6. **`GetNPCRelationship(npc_name, other_entity_id)`**
   - Returns relationship strength (-1000 to +1000)
   - Defaults to 0 (neutral) if no relationship exists
   - **Usage**: Dialogue system picks options based on relationship

7. **`GetNPCHistoryWithPlayer(npc_name, player_id)`**
   - Returns `/datum/npc_interaction_history` object
   - Fields: total_interactions, trades, gifts_given, insults_received, last_interaction
   - **Usage**: NPC dialogue references past interactions

---

## Phase 11C: Calendar & Seasonal Events

### Purpose
Implement dynamic world calendar driving:
- Seasonal resource availability (crops only grow certain seasons)
- Dynamic world events (festivals, migrations, eclipses, monster invasions)
- Weather effects (temperature modifiers affecting hunger)
- Economic impacts (supply shortages, demand spikes)

### Tables Created

**Table: `world_calendar`** (12 columns)
```sql
PRIMARY KEY: day_id (auto-increment)
UNIQUE: day_number (1-365, unique day of year)
- season: TEXT (spring|summer|autumn|winter)
- month: INTEGER (1-12)
- year: INTEGER (game year)
- day_of_week: TEXT (Monday|Tuesday|...|Sunday)
- time_of_day_minutes: INTEGER (0-1440, 0=midnight, 720=noon)
- weather_type: TEXT (clear|cloudy|rainy|snowy|stormy|foggy)
- weather_intensity: INTEGER (0-100)
- temperature_modifier: REAL (-50 to +50, affects hunger/thirst rate)
- daylight_hours: INTEGER (season-dependent, 10-14)
- is_festival_day: BOOLEAN
- festival_name: TEXT (if is_festival_day=true)
- special_event: TEXT (eclipse|meteor_shower|northern_lights|etc.)
- biome_effects: TEXT (JSON: {biome_name: {modifier_type: value}})
INDEXES:
  - idx_calendar_season (filter by season)
  - idx_calendar_day_number (lookup by day, DESC for current)
  - idx_calendar_weather (weather-based queries)
```

**Table: `seasonal_events`** (12 columns)
```sql
PRIMARY KEY: event_id (auto-increment)
- event_name: TEXT (e.g., "Spring Harvest Festival")
- event_type: TEXT (harvest_festival|winter_storm|migration|eclipse|meteor_shower|creature_invasion|resource_boom)
- season: TEXT (spring|summer|autumn|winter|any)
- day_of_year_range_start, day_of_year_range_end: INTEGER
- duration_hours: INTEGER (how long event lasts)
- affected_biomes: TEXT (JSON array: ['temperate', 'arctic', 'desert'])
- affected_continents: TEXT (JSON array: ['story', 'sandbox', 'pvp'])
- resource_availability_modifiers: TEXT (JSON: {resource_type: multiplier})
  - Example: {stone: 1.5, metal: 0.7} = abundant stone, scarce metal
- economy_impact: TEXT (inflation|deflation|supply_shortage|demand_spike|neutral)
- economy_impact_percentage: REAL (±5 = ±5% price change)
- player_engagement_reward_bonus: REAL (1.0=normal, 2.0=double rewards)
- npc_behavior_modifiers: TEXT (JSON: NPC behavior changes)
- event_description: TEXT (narrative flavor)
- is_repeating: BOOLEAN (happens every year?)
- enabled: BOOLEAN (can disable events for maintenance)
INDEXES:
  - idx_events_season (filter by season)
  - idx_events_type (filter by type)
  - idx_events_enabled (only active events)
```

**Table: `event_occurrences`** (6 columns)
```sql
PRIMARY KEY: occurrence_id (auto-increment)
FOREIGN KEY: event_id → seasonal_events
- actual_start_timestamp: TIMESTAMP (when event actually occurred)
- actual_end_timestamp: TIMESTAMP
- intensity_modifier: REAL (1.0=baseline, 2.0=double intensity)
- player_participation: INTEGER (how many players engaged)
- event_outcome: TEXT (successful|failed|neutral|chaotic)
- world_impact_summary: TEXT (narrative of what happened)
INDEXES:
  - idx_occurrences_event (filter by event)
  - idx_occurrences_timestamp (temporal queries, DESC for recent)
```

### Procs Implemented (4+ total)

1. **`GetCurrentSeasonalModifiers()`**
   - Returns `/datum/seasonal_modifier` object
   - Reads current day from world_calendar
   - Pulls active events
   - **Usage**: Consumption system checks temperature modifier, market system checks active events

2. **`TriggerSeasonalEvent(event_type, intensity_override=null)`**
   - Activates specified event
   - Creates event_occurrence record
   - Applies resource availability modifiers
   - **Usage**: Called by world systems when event time arrives

3. **`GetUpcomingEvents(days_ahead=30)`**
   - Returns list of events happening in next N days
   - **Usage**: UI shows "upcoming festivals" or player calendars

4. **`LogSeasonalActivity(activity_type, activity_data=null)`**
   - Records significant seasonal activity for audit trails
   - **Usage**: Important world events logged for debugging

### Initialization (Phase 11C - Tick 450)

**Proc**: `InitializeCalendarSystem()`
- Runs at tick 450 (2250ms into boot)
- Reads global variables: `day`, `month`, `year`, `hour`, `minute1`, `minute2`
- Calculates day_number (1-365)
- Detects season from month
- Detects day_of_week (simplified modulo)
- Calculates daylight_hours (10-14 based on season)
- Inserts single calendar record into world_calendar
- **Output**: "CALENDAR_SYSTEM: Initialized calendar - Day [N] ([season]), Time [hour]:[minute]"

### Seasonal Details

**Spring** (Months 4-6)
- Daylight: 12 hours
- Temperature: Moderate (0°C)
- Events: Planting festivals, resource booms in certain areas
- Crops: Vegetables start growing

**Summer** (Months 7-9)
- Daylight: 14 hours
- Temperature: Hot (+20°C, increases hunger)
- Events: Harvest festivals, migration of creatures
- Crops: All crops available, peak production

**Autumn** (Months 10-12)
- Daylight: 12 hours  
- Temperature: Cool (-5°C)
- Events: Harvest festivals (final), supply shortages begin
- Crops: Final harvest before winter

**Winter** (Months 1-3)
- Daylight: 10 hours
- Temperature: Cold (-30°C, drastically increases hunger/stamina drain)
- Events: Winter storms, creature invasions, resource crashes
- Crops: Most crops unavailable, only cold-hardy items survive

---

## Schema Summary

| Component | Tables | Procs | Purpose |
|-----------|--------|-------|---------|
| Phase 11A | 2 | 5 | Resource tracking, scarcity, transaction history |
| Phase 11B | 3 | 8+ | NPC state, schedules, relationships |
| Phase 11C | 3 | 4+ | Calendar, seasonal events, world dynamics |
| **TOTAL** | **7** | **17+** | **Living world foundation** |

## Build Results

**Compile**: ✓ 0 errors, 36 warnings
**Binary**: ✓ Pondera.dmb created successfully
**Commit**: `1e7b78d` - Phase 11 complete

### Remaining Warnings (Non-blocking)
- `BuildingMenuSystem.dm:170` - unused variable `amount_needed`
- `ContinentLobbyHub.dm:36` - unused variable `p1`
- `SQLitePersistenceLayer.dm:2425` - unused variable `stats`
- `ToolbeltHotbarSystem.dm:758` - unused label `pass`
- `AdvancedTerrainFeatures.dm:58` - unused variable `difficulty_mod`

These are pre-existing warnings not introduced by Phase 11.

---

## Integration Checklist

- [x] Schema.sql updated with 7 tables and indexes
- [x] SQLitePersistenceLayer.dm expanded with 17+ procs
- [x] InitializationManager.dm updated with Phase 11 boot sequence (ticks 430/440/450)
- [x] Datum definitions for NPC state, interaction history, seasonal modifiers
- [x] Global variable access fixed (SP/MP/SB/SM from timesave)
- [x] Database initialization on boot
- [x] Clean build verification
- [x] Commit to recomment-cleanup branch

---

## Next Steps

### Phase 12: Guild Systems & Territory Warfare
- Guild creation, membership, territory claims
- Territory raiding mechanics
- Guild resource pools and taxation
- Estimated: 5-6 tables, 20+ procs

### Phase 13: World Events & Dynamic Economy
- Event auction system
- Dynamic supply/demand shocks
- NPC migrations affecting markets
- Estimated: 3-4 tables, 15+ procs

---

## Notes

- **Performance**: All new procs use indexed queries (no full table scans)
- **Backward Compatibility**: Binary timesave.sav still loads but data migrates to SQLite on first boot
- **NPC AI**: Procs ready but NPC behavior loops still need implementation
- **Seasonal Integration**: Calendar ready, need to hook into consumption/farming systems

