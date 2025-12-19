# Phase 13 Systems - Technical Deep Dive

**Version**: 13D Complete  
**Status**: 0 errors, stub procs ready for implementation  
**Initialization**: Phases A-D integrated in `InitializationManager.dm`

---

## Overview

Pondera Phase 13 modernizes core systems and adds advanced world simulation:

| Phase | Name | Scope | Status |
|-------|------|-------|--------|
| **13A** | World Events & Auctions | Random events, dynamic pricing triggers | ✅ Integrated (stub) |
| **13B** | NPC Migrations & Supply Chains | Caravan routes, trade logistics | ✅ Integrated (stub) |
| **13C** | Economic Cycles | Market boom/crash, supply/demand | ✅ Integrated (stub) |
| **13D** | Movement System | Modern movement (553 lines) | ✅ Complete |

---

## Phase 13A: World Events & Auctions

**File**: `dm/Phase13A_WorldEventsAndAuctions.dm`  
**Purpose**: Create dynamic, unpredictable world events that trigger market changes

### Architecture

```
world_event_loop()
  └─ Periodic random event selection
     ├─ RandomEvent/Plague -> Market prices ↑
     ├─ RandomEvent/Harvest -> Market prices ↓
     ├─ RandomEvent/Calamity -> Expensive repairs
     └─ RandomEvent/Boom -> Trade surplus

auction_system()
  └─ Player-driven bidding
     ├─ List auction_listings (player → item)
     └─ Process auction_bids (highest bidder wins)
```

### Key Mechanics

#### Random Events
- **Plague**: ↑ Herbalist prices (medicine demand)
- **Harvest**: ↓ Food prices (abundant supply)
- **Calamity**: ↑ Builder costs (reconstruction demand)
- **Boom**: ↑ Commerce (more players trading)

#### Auction Integration
- Players post items with starting bid
- Live bidding on marketplace
- Winner pays highest bid, seller receives proceeds
- Commission deducted (5-10% to kingdom)

#### Trigger Hooks
```dm
proc/TriggerWorldEvent(event_type)
  - Update market price modifiers
  - Broadcast event message to all players
  - Log in world_events table

proc/AuctionComplete(auction_id, winner_ckey)
  - Transfer item to winner
  - Transfer currency to seller
  - Record transaction
```

### Database Schema

```sql
CREATE TABLE world_events (
  id INTEGER PRIMARY KEY,
  event_type TEXT,
  severity REAL,
  duration INTEGER,
  created_at TIMESTAMP,
  resolved_at TIMESTAMP
);

CREATE TABLE auction_listings (
  id INTEGER PRIMARY KEY,
  seller_ckey TEXT,
  item_name TEXT,
  starting_bid REAL,
  created_at TIMESTAMP,
  ends_at TIMESTAMP
);

CREATE TABLE auction_bids (
  id INTEGER PRIMARY KEY,
  auction_id INTEGER,
  bidder_ckey TEXT,
  bid_amount REAL,
  bid_time TIMESTAMP
);
```

### Implementation TODOs

- [ ] Implement random event dispatcher loop (every 10-30 minutes)
- [ ] Add UI for auction browsing/bidding
- [ ] Implement commission system
- [ ] Add event notification system (alerts to affected players)
- [ ] Implement price modifier multipliers

---

## Phase 13B: NPC Migrations & Supply Chains

**File**: `dm/Phase13B_NPCMigrationsAndSupplyChains.dm`  
**Purpose**: Create trading opportunities via NPC caravan routes

### Architecture

```
npc_migration_loop()
  └─ Per route (Temperate ↔ Arctic ↔ Desert)
     ├─ Spawn NPC caravan
     ├─ Path along road
     ├─ Buy/sell at villages
     └─ Despawn at destination

supply_chain()
  └─ Track resource flow
     ├─ Origin: Temperate (farming surplus)
     ├─ Transport: NPC caravan
     ├─ Destination: Desert (high demand)
     └─ Price differential: Profit opportunity
```

### Key Mechanics

#### Caravan Routes
- **Route 1**: Temperate → Arctic (fur demand)
- **Route 2**: Arctic → Desert (food demand)
- **Route 3**: Desert → Temperate (stone demand)
- **Route 4**: Forest → Coastal (fish trade)

#### NPC Supply Chain
1. Caravans spawn at origin with goods
2. Travel along predetermined path (20-40 seconds)
3. Buy low, sell high at each stop
4. Profit affects kingdom treasury
5. Players can intercept/raid (PvP implications)

#### Price Variations by Route
```dm
route_price_variations
  temperate_furs: 50 lucre (cheap local)
  arctic_furs: 150 lucre (expensive imported)
  profit_margin: 100 lucre per fur

desert_stone: 30 lucre (expensive local)
temperate_stone: 80 lucre (from desert export)
profit_margin: 50 lucre per stone
```

### Database Schema

```sql
CREATE TABLE npc_migration_routes (
  id INTEGER PRIMARY KEY,
  route_name TEXT,
  origin_z INTEGER,
  destination_z INTEGER,
  path_turfs TEXT, -- serialized list
  spawn_interval INTEGER, -- seconds
  last_spawn TIMESTAMP
);

CREATE TABLE supply_chains (
  id INTEGER PRIMARY KEY,
  route_id INTEGER,
  caravan_id INTEGER,
  goods TEXT, -- JSON array
  origin_price REAL,
  current_price REAL,
  profit_so_far REAL
);

CREATE TABLE route_price_variations (
  id INTEGER PRIMARY KEY,
  route_id INTEGER,
  good_name TEXT,
  origin_price REAL,
  destination_price REAL,
  timestamp TIMESTAMP
);
```

### Implementation TODOs

- [ ] Define caravan routes (5-8 routes per continent)
- [ ] Implement caravan movement (pathfinding)
- [ ] Implement buy/sell at villages
- [ ] Add player interception mechanics
- [ ] Integrate with DynamicMarketPricingSystem
- [ ] Add caravan notification (alerts on route start/end)

---

## Phase 13C: Economic Cycles

**File**: `dm/Phase13C_EconomicCycles.dm`  
**Purpose**: Self-regulating economy with boom/crash dynamics

### Architecture

```
economic_cycle_loop()
  └─ Monthly cycle (every ~1 hour real-time)
     ├─ Calculate supply index
     ├─ Calculate demand index
     ├─ Determine market condition
     └─ Update price elasticity

price_elasticity
  growth: 1.5x (boom) → high prices, high profit
  stable: 1.0x (normal) → steady prices
  recession: 0.7x (crash) → low prices, low profit
  depression: 0.4x (crash) → very low prices, survival mode
```

### Key Mechanics

#### Market Cycles

| Condition | Elasticity | Player Impact |
|-----------|-----------|---------------|
| Boom | 1.5x | High prices, high profit margins |
| Growth | 1.2x | Rising prices, medium profit |
| Stable | 1.0x | Balanced prices |
| Slowdown | 0.8x | Falling prices |
| Recession | 0.6x | Low prices, low profit |
| Crash | 0.4x | Survival mode, barely profitable |

#### Cycle Triggers
- **Boom**: Player population ↑, kingdom treasury ↑
- **Growth**: Stable supply, moderate demand
- **Recession**: Oversupply, kingdom spending ↑
- **Crash**: Stagnation, no growth

#### Economic Indicators

```dm
proc/CalculateEconomicIndicators()
  supply_index = TotalResourcesAvailable() / ResourceDemand()
  demand_index = PlayerPopulation() * AverageConsumption()
  confidence = KingdomTreasuryHealth() / RequiredSpending()
  growth = (supply_index - 0.5) * (demand_index - 0.5) * confidence
  
  if(growth > 0.5) market_condition = "BOOM"
  else if(growth > 0.2) market_condition = "GROWTH"
  else if(growth > -0.2) market_condition = "STABLE"
  else if(growth > -0.5) market_condition = "RECESSION"
  else market_condition = "CRASH"
```

### Database Schema

```sql
CREATE TABLE market_cycles (
  id INTEGER PRIMARY KEY,
  cycle_start TIMESTAMP,
  cycle_end TIMESTAMP,
  condition TEXT, -- BOOM, GROWTH, STABLE, RECESSION, CRASH
  elasticity_multiplier REAL,
  supply_index REAL,
  demand_index REAL,
  confidence_level REAL
);

CREATE TABLE economic_indicators (
  id INTEGER PRIMARY KEY,
  timestamp TIMESTAMP,
  supply_total REAL,
  demand_total REAL,
  population_count INTEGER,
  kingdom_treasury REAL,
  growth_rate REAL,
  market_sentiment TEXT
);
```

### Implementation TODOs

- [ ] Implement supply calculation (total resources in circulation)
- [ ] Implement demand calculation (player consumption rate)
- [ ] Implement cycle transitions (smooth, not abrupt)
- [ ] Add player notification system (market alerts)
- [ ] Integrate with DynamicMarketPricingSystem elasticity
- [ ] Add economic recession player effects (hunger increases, etc.)

---

## Phase 13D: Movement System (COMPLETE ✅)

**File**: `dm/Phase13D_MovementSystem.dm`  
**Lines**: 553  
**Status**: Full implementation, tested

### Architecture

```
proc/MovementLoop()
  ├─ Read input keys (MN, MS, ME, MW)
  ├─ Check collision/deed permissions
  ├─ Calculate speed (stamina-dependent)
  ├─ Execute step()
  ├─ Invalidate permission cache
  └─ Schedule next tick

proc/GetMovementSpeed()
  ├─ Base speed: 3 ticks
  ├─ Stamina modifier: -0.5 to +0.5 per stamina level
  ├─ Hunger penalty: 0.5x if very hungry
  ├─ Temperature modifier: ±0.2x per degree
  └─ Return: tick_delay
```

### Key Features

- **Input Buffering**: Queued directions (QueN/QueS/QueE/QueW)
- **Sprint Mechanic**: Double-tap same direction within 3 ticks
- **Speed Calculation**: Stamina, hunger, temperature-aware
- **Deed Integration**: Permission cache invalidated per move
- **Elevation Support**: `Chk_LevelRange()` validates elevation compatibility

### Performance

- **Tick Rate**: 40 TPS (25ms per tick)
- **Movement Delay**: 3 ticks (75ms) base
- **Cache Invalidation**: O(1) per move
- **Collision Detection**: Native BYOND, negligible overhead

### Complete Features

✅ Directional movement (NORTH, SOUTH, EAST, WEST)  
✅ Stamina-based speed calculation  
✅ Hunger penalty system  
✅ Temperature modifier  
✅ Sprint detection & activation  
✅ Deed permission integration  
✅ Elevation range checking  
✅ Input buffering (queued moves)  

---

## Integration Points

### Phase 13A ↔ 13C
- World events trigger market price changes
- Economic cycles set elasticity multipliers
- Auctions create trading opportunities

### Phase 13B ↔ 13C
- NPC supply chains create artificial demand
- Supply chain prices affect market cycles
- Caravans generate kingdom treasury income

### All Phases ↔ 13D
- Movement system supports all interactions
- Permission cache invalidation per move
- Stamina/hunger affects movement speed

---

## Initialization Sequence

**File**: `dm/InitializationManager.dm`

### Phase Offsets

```dm
proc/InitializeWorld()
  spawn(0) InitializePhase1_TimeSystem()       // 0 ticks
  spawn(5) InitializePhase1B_CrashRecovery()   // 5 ticks
  spawn(50) InitializePhase2_Infrastructure()  // 50 ticks
  spawn(55) InitializePhase2B_Deeds()          // 55 ticks
  spawn(100) InitializePhase3_DayNight()       // 100 ticks
  spawn(300) InitializePhase4_SpecialSystems() // 300 ticks
  spawn(400) InitializePhase5_NPCRecipes()     // 400 ticks
  
  // Phase 13 integration:
  // - Phase 13A starts world event loop (Phase 4)
  // - Phase 13B starts NPC migrations (Phase 4)
  // - Phase 13C starts economic cycle (Phase 5)
  // - Phase 13D movement active immediately
```

---

## Testing & Validation

### Pre-Deployment Checks

- [ ] 0 compilation errors (✅ achieved)
- [ ] All phase procs callable without crashing
- [ ] Phase transitions happen on schedule
- [ ] SQLite schema matches Phase 13 tables
- [ ] 1+ hour stress test (TODO)
- [ ] NPC caravan spawning (TODO)
- [ ] Market cycle transitions (TODO)
- [ ] Auction system (TODO)

---

## Known Limitations & Workarounds

### Phase 13A
- Auction system may need optimization for 100+ simultaneous bids
- Event notifications broadcast to all players (high bandwidth at scale)

### Phase 13B
- Pathfinding simplified (predefined routes vs. dynamic)
- Caravan spawning not load-balanced

### Phase 13C
- Economic indicators calculated sync (may lag at high player count)
- Cycle transitions need smoothing (prevent abrupt crashes)

### General
- All stub procs need implementation before gameplay
- No save/load for in-progress events yet
- Market persistence via SQLite not yet tested

---

## Roadmap: Phase 13 Completion

**Next**: Implement stub procs and test with 1+ hour gameplay  
**Then**: Balance economic multipliers and event frequency  
**Finally**: Stress test with 20+ concurrent players  

---

**Last Updated**: 2025-12-18  
**Mapped By**: Cappy AI + Copilot  
**Source**: Phase 13 source files analysis

---

See also: [[Pondera_Codebase_Architecture]], [[Pondera_File_Index]]
