# Phase 13: Dynamic Economy & Market Events - Design Document

**Target**: Clean build with 7 tables, 24+ procs  
**Estimated Implementation Time**: 3-4 hours  
**Bootstrap Sequence**: Ticks 500-530  
**Status**: PLANNING

---

## Overview

Phase 13 creates a living, breathing economy where:
- **World Events** disrupt supply/demand (invasions increase armor demand, harvests flood market with crops)
- **NPC Migrations** move resources between regions (traders follow caravans, supply chains break)
- **Economic Cycles** naturally inflate/deflate prices (boom → bubble → crash → recovery)
- **Player Auctions** enable speculation and market manipulation

### Three Sub-Phases

1. **Phase 13A: World Events & Auction System** - Dynamic events, player auctions, price shocks
2. **Phase 13B: NPC Migrations & Supply Chains** - NPC movement, supply routing, logistics bottlenecks
3. **Phase 13C: Economic Cycles & Feedback Loops** - Self-regulating economy with boom/bust cycles

---

## Phase 13A: World Events & Auction System

### Purpose
Enable:
- **World Events** (creature invasions, natural disasters, festivals) that dynamically affect prices
- **Auction System** for players to speculate on price movements
- **Price Shocks** that reward savvy traders and punish unprepared
- **Event Chaining** (one event triggers follow-up events)

### Database Schema

**Table: `world_events`** (14 columns)
```sql
PRIMARY KEY: event_id (auto-increment)
- event_name: TEXT (e.g., "Goblin Invasion - Westlands")
- event_type: TEXT (invasion|plague|natural_disaster|festival|treasure_discovery|market_crash)
- event_continent: TEXT (story|sandbox|pvp)
- event_region: TEXT (optional, specific zone within continent)
- event_start_timestamp: TIMESTAMP (when event begins)
- event_duration_hours: INTEGER (how long event lasts)
- event_status: TEXT (planned|active|resolving|resolved|cancelled)
- severity: INTEGER (1-10, affects impact magnitude)
- affected_resources: TEXT (JSON: {resource_type: multiplier, ...})
  - Example: {stone: 0.5, metal: 2.0, armor: 3.0} = stone scarce, metal abundant, armor in high demand
- affected_biomes: TEXT (JSON array of biome names)
- player_casualties: INTEGER (players killed if combat event)
- resource_destroyed: BIGINT (total resources destroyed)
- event_description: TEXT (narrative flavor, displayed to players)
- resolution_rewards: TEXT (JSON: {item_type: quantity} distributed to participants)
INDEXES:
  - idx_events_type (filter by event type)
  - idx_events_continent (filter by world)
  - idx_events_status (active events only)
  - idx_events_timestamp (temporal sorting)
```

**Table: `auction_listings`** (10 columns)
```sql
PRIMARY KEY: listing_id (auto-increment)
FOREIGN KEY: seller_player_id → players
FOREIGN KEY: buyer_player_id → players (nullable until sold)
- item_type: TEXT (e.g., "stone", "iron_ore", "crafted_sword")
- quantity: INTEGER (how many units)
- starting_price: BIGINT (opening bid in gold)
- current_bid: BIGINT (highest bid so far)
- reserve_price: BIGINT (minimum acceptable price)
- auction_start_timestamp: TIMESTAMP
- auction_end_timestamp: TIMESTAMP
- auction_status: TEXT (active|sold|expired|cancelled)
- bid_history_json: TEXT (JSON array: [{bidder_id, amount, timestamp}])
- final_price: BIGINT (actual sale price, null if unsold)
INDEXES:
  - idx_auctions_seller (find listings by seller)
  - idx_auctions_item (find all auctions for item type)
  - idx_auctions_status (active auctions only)
  - idx_auctions_end_time (auctions ending soon)
```

**Table: `economic_shocks`** (9 columns)
```sql
PRIMARY KEY: shock_id (auto-increment)
FOREIGN KEY: event_id → world_events (nullable, shock can be triggered by other events)
- shock_timestamp: TIMESTAMP (when shock occurred)
- shock_type: TEXT (supply_shortage|demand_spike|panic_buying|market_crash|resource_boom|currency_devaluation)
- affected_resource: TEXT (which resource was shocked)
- price_change_percent: REAL (price multiplier, e.g., +200% = tripled price)
- duration_hours: INTEGER (how long shock lasts)
- triggered_by: TEXT (event_name or "player_action" or "market_forces")
- recovery_rate_per_hour: REAL (price moves back toward baseline by this % per hour)
- player_participation_count: INTEGER (how many players affected)
- total_gold_moved: BIGINT (total currency traded during shock)
INDEXES:
  - idx_shocks_timestamp (temporal queries)
  - idx_shocks_resource (filter by resource)
  - idx_shocks_type (filter by shock type)
```

### Procs Implemented (10+ procs)

**1. `TriggerWorldEvent(event_type, severity, affected_resources_json)`**
- Creates world_events entry with event_status="planned"
- Selects random event_continent and event_region
- Schedules: event_start_timestamp = NOW + 1 hour (warning period)
- Calculates: event_duration_hours based on severity
- Creates economic_shocks entries for each affected resource
- Broadcasts: warning message to all players
- Output: "⚠️ World Event incoming: [event_name] will begin in 1 hour"

**2. `ActivateWorldEvent(event_id)`**
- Sets event_status="active"
- Applies all resource multipliers from affected_resources
- Updates market prices via DynamicMarketPricingSystem
- Spawns event creatures/hazards (integration with map generation)
- Begins damage tracking (player_casualties, resource_destroyed)
- Output: "🔴 [event_name] is NOW ACTIVE in [region]"

**3. `ResolveWorldEvent(event_id, actual_outcome="")`**
- Sets event_status="resolved"
- Calculates: final_player_casualties and resource_destroyed
- Distributes resolution_rewards to participants
- Returns affected_resources to baseline (gradually via recovery_rate)
- Logs to economic_shocks with recovery_rate_per_hour
- Creates follow-up event if chained (e.g., invasion → supply shortage)
- Output: "[event_name] resolved. Final casualties: [N], Resources destroyed: [amount]"

**4. `CreateAuctionListing(seller_player_id, item_type, quantity, starting_price, reserve_price)`**
- Validates: seller has quantity of item
- Removes item from seller inventory
- Creates auction_listings entry with auction_status="active"
- Sets: auction_end_timestamp = NOW + 7 days (standard duration)
- Broadcasts: "[seller] is auctioning [quantity] [item_type]"
- Output: "Auction created, ends in 7 days"

**5. `PlaceBid(auction_id, bidder_player_id, bid_amount)`**
- Validates: auction active, bid > current_bid and > reserve_price
- Calculates: outbid_amount = bid_amount - current_bid
- Locks gold in bidder account (reserved until auction ends)
- Updates: current_bid, appends to bid_history_json
- Notifies: previous high bidder they were outbid
- Output: "[bidder] placed bid of [amount]"

**6. `ResolveAuction(auction_id)`**
- Validates: auction_end_timestamp has passed
- If bids exist: transfers item to highest bidder, gold to seller
- If no bids: returns item to seller, listing marked "expired"
- If unsold: set auction_status="expired"
- Logs transaction to player ledger (if enabled)
- Output: "Auction ended: [winner] won [item] for [price]"

**7. `CancelAuction(auction_id, player_id)`**
- Validates: player is seller or item not yet sold
- Returns item to seller inventory
- Returns all bids to bidders
- Sets auction_status="cancelled"
- Output: "Auction cancelled, [item] returned to [seller]"

**8. `GetAuctionHistory(item_type, days_back=30)`**
- Returns list of completed auctions for item_type in past N days
- Shows: final_prices, quantities, timestamps
- Calculates: average_price, price_trend (up/down)
- Identifies: price spikes (economic shocks)
- Output: Array of auction data for charting

**9. `AnalyzeMarketSentiment(item_type, time_window_hours=24)`**
- Reads auctions and bids from past N hours
- Calculates: bid_frequency (how many bids placed)
- Calculates: bid_aggression (average bid increment, higher=more competitive)
- Calculates: avg_bid_duration (how fast bids placed, faster=more demand)
- Determines: sentiment = bullish|neutral|bearish
- Output: "Market sentiment for [item]: [sentiment]"

**10. `TriggerEconomicShock(shock_type, affected_resource, price_change_percent)`**
- Creates economic_shocks entry
- Immediately updates market price for resource
- Sets: duration_hours (varies by shock type: crash=24hrs, boom=48hrs, shortage=72hrs)
- Notifies: all traders of price movement
- Logs: shocking event for analytics
- Output: "⚡ Economic shock: [resource] [direction] [percent]%"

### Event Chaining Examples

**Invasion → Armor Demand Spike → Supply Shortage**
```
1. TriggerWorldEvent(invasion, severity=8) creates goblin_invasion
2. Affected_resources = {armor: +300%, weapons: +200%, stone: -50%}
3. ActivateWorldEvent: invasion_start, spawns creatures, demand spikes
4. ReceivePlayerCasualties: armor breaks during combat, players buy replacements
5. ResolveWorldEvent(after 48 hours): 
   - Creates follow-up: economic_shocks("armor_shortage", +150%, 72hr duration)
   - Distribution: armor_pieces dropped by defeated creatures + reward caches
```

**Treasure Discovery → Price Crash**
```
1. TriggerWorldEvent("treasure_discovery", severity=3)
2. Affected_resources = {gold: +500%} (currency flooded market)
3. ActivateWorldEvent: players receive rewards, dump gold at NPCs
4. TriggerEconomicShock: currency_devaluation (-20% purchasing power)
   - Everything costs 20% more (inflation)
   - Savers lose value, borrowers benefit
```

---

## Phase 13B: NPC Migrations & Supply Chains

### Purpose
Enable:
- **NPC Movements** (traders follow supply/demand routes)
- **Supply Chains** (caravans deliver resources between regions)
- **Logistics Bottlenecks** (blocked roads create shortages)
- **Trade Networks** (NPCs create natural trading hubs)

### Database Schema

**Table: `npc_migration_routes`** (11 columns)
```sql
PRIMARY KEY: route_id (auto-increment)
- route_name: TEXT (e.g., "Northern Trade Route", "Coastal Merchant Path")
- origin_region: TEXT (starting location)
- destination_region: TEXT (ending location)
- route_waypoints: TEXT (JSON array: [{x, y, z}, {x, y, z}, ...])
- preferred_resource: TEXT (what NPC typically trades)
- travel_time_hours: INTEGER (how long to traverse route)
- traffic_volume: INTEGER (0-100, how busy the route is)
- danger_level: INTEGER (1-10, bandit activity, monsters, hazards)
- is_active: BOOLEAN (route still in use)
- last_traversed_timestamp: TIMESTAMP
- traffic_history_json: TEXT (JSON: {timestamp: traffic_count} for analytics)
INDEXES:
  - idx_routes_origin (find routes leaving region)
  - idx_routes_destination (find routes entering region)
  - idx_routes_resource (find routes trading item)
  - idx_routes_active (active routes only)
```

**Table: `supply_chains`** (12 columns)
```sql
PRIMARY KEY: chain_id (auto-increment)
FOREIGN KEY: route_id → npc_migration_routes
FOREIGN KEY: origin_npc_id → npc_persistent_state
FOREIGN KEY: destination_npc_id → npc_persistent_state
- resource_type: TEXT (what's being transported)
- shipment_quantity: BIGINT (amount of resource)
- departure_timestamp: TIMESTAMP (when shipment left)
- expected_arrival_timestamp: TIMESTAMP
- actual_arrival_timestamp: TIMESTAMP (null if not arrived)
- chain_status: TEXT (in_transit|delayed|arrived|lost|intercepted)
- shipment_disruption: BOOLEAN (blocked route, ambushed, etc.)
- disruption_reason: TEXT (bandit_attack|enemy_raid|monster_invasion|natural_disaster)
- price_at_origin: BIGINT (cost in origin region)
- price_at_destination: BIGINT (cost in destination region, impacts profit)
- profit_margin: BIGINT (difference, drives route traffic)
INDEXES:
  - idx_chains_route (find shipments on route)
  - idx_chains_status (active shipments only)
  - idx_chains_resource (find shipments of resource type)
  - idx_chains_timestamp (delivery tracking)
```

### Procs Implemented (8+ procs)

**1. `CreateMigrationRoute(route_name, origin_region, destination_region, waypoints_json)`**
- Creates npc_migration_routes entry
- Calculates: travel_time_hours from waypoint distances
- Samples: danger_level from region hazards
- Sets: traffic_volume=0 (initially empty)
- Output: "Route created: [route_name]"

**2. `InitiateTradeCaravan(origin_npc_id, destination_npc_id, route_id, resource_type, quantity)`**
- Validates: origin NPC has quantity of resource
- Removes resource from origin NPC inventory
- Creates supply_chains entry with chain_status="in_transit"
- Reads: current prices in both regions
- Calculates: expected profit_margin
- Starts: travel timer (will auto-arrive after travel_time_hours)
- Output: "Caravan departed: [quantity] [resource] heading to [destination]"

**3. `DeliverCaravan(chain_id)`**
- Sets: chain_status="arrived", actual_arrival_timestamp=NOW
- Transfers: shipment_quantity to destination NPC inventory
- Calculates: profit_margin (destination_price * quantity - origin_price * quantity)
- Adds profit to destination NPC gold/resources
- Updates: supply_chain price_at_destination (current market price)
- Logs: transaction to supply chain history
- Output: "Caravan arrived! [NPC] received [quantity] [resource]"

**4. `InterruptCaravan(chain_id, disruption_reason)`**
- Sets: chain_status="intercepted" or "delayed"
- Removes: 50% of shipment (lost in ambush/disaster)
- Sets: shipment_disruption=TRUE, disruption_reason
- Returns: 50% to origin NPC (partial recovery)
- Raises: danger_level on route (if bandit attack)
- Triggers: economic_shock (supply shortage for resource in destination)
- Output: "Caravan intercepted: [reason], [amount] resources lost"

**5. `CalculateRouteTraffic(route_id)`**
- Counts: active supply_chains using this route
- Calculates: average_profit_margin from recent shipments
- Higher profit = more NPCs use route (traffic increases)
- Higher danger = fewer NPCs use route (traffic decreases)
- Updates: traffic_volume (0-100 scale)
- Output: Integer traffic volume

**6. `UpdatePriceAlongRoute(route_id, resource_type)`**
- Reads: prices at origin and destination
- Calculates: price_delta per hour of travel
- Price increases as shipment travels (cost + time value)
- Updates: expected prices in each region
- Triggers: NPC price adjustments at each waypoint
- Output: "Prices updated along [route]"

**7. `RerouteCaravan(chain_id, new_route_id)`**
- Validates: caravan in transit and not near destination
- Changes: waypoints to new_route_id waypoints
- Recalculates: expected_arrival_timestamp
- May trigger: longer route = higher loss risk
- Output: "Caravan rerouted"

**8. `GetSupplyChainStatus(resource_type)`**
- Aggregate view of all active shipments for resource
- Returns: total_in_transit, expected_delivery_dates
- Calculates: supply shortage predictions
- Shows: which routes are blocked/delayed
- Output: "Supply Report: [resource] - [in_transit qty] arriving [date]"

### NPC Trading AI Integration

When NPC finishes trade at location:
1. **Analyze Local Market**: Call `GetCurrentSeasonalModifiers()` + check local prices
2. **Select Route**: Highest profit_margin route from current location
3. **Initiate Caravan**: Call `InitiateTradeCaravan()` with chosen route
4. **Travel**: NPC moves along route_waypoints
5. **Deliver**: Call `DeliverCaravan()` when reaching destination
6. **Repeat**: Start trading at new location, look for next profitable route

---

## Phase 13C: Economic Cycles & Feedback Loops

### Purpose
Enable:
- **Natural Boom/Bust Cycles** (market feedback loops self-regulate)
- **Speculative Bubbles** (excessive trading drives artificial price spikes)
- **Market Crashes** (bubbles pop, prices crash, economy resets)
- **Recovery Periods** (slow return to equilibrium)

### Database Schema

**Table: `economic_indicators`** (10 columns)
```sql
PRIMARY KEY: indicator_id (auto-increment)
- indicator_timestamp: TIMESTAMP (when reading taken)
- resource_type: TEXT (which resource)
- price_current: BIGINT (current market price)
- price_previous_day: BIGINT (price 24h ago)
- supply_total: BIGINT (total available in all treasuries)
- demand_signal: REAL (0.0-1.0, consumer buying pressure)
- inflation_rate: REAL (% price change per day)
- volatility: REAL (0.0-1.0, price stability)
- trend_direction: TEXT (bullish|neutral|bearish)
- is_bubble: BOOLEAN (price detached from fundamentals?)
INDEXES:
  - idx_indicators_resource (filter by resource)
  - idx_indicators_timestamp (temporal analysis, DESC for recent)
```

**Table: `market_cycles`** (10 columns)
```sql
PRIMARY KEY: cycle_id (auto-increment)
- cycle_start_timestamp: TIMESTAMP
- cycle_type: TEXT (boom|bubble|crash|recovery|equilibrium)
- affected_resource: TEXT
- price_peak: BIGINT (highest price during cycle)
- price_trough: BIGINT (lowest price during cycle)
- cycle_duration_hours: INTEGER
- bubble_severity: INTEGER (1-10, how detached from reality)
- crash_severity: INTEGER (1-10, how hard the fall)
- trading_volume_total: BIGINT (gold traded during cycle)
- participant_count: INTEGER (how many players involved)
INDEXES:
  - idx_cycles_resource (filter by resource)
  - idx_cycles_type (filter by phase)
  - idx_cycles_timestamp (timeline analysis)
```

### Procs Implemented (6+ procs)

**1. `UpdateEconomicIndicators(resource_type)`**
- Reads: current market price from dynamic pricing system
- Reads: total supply from global_resources + guild_treasuries
- Calculates: demand_signal from recent auction volume
- Calculates: inflation_rate = (price_current - price_previous_day) / price_previous_day
- Detects: volatility from price swings (std dev of last 24h prices)
- Determines: trend_direction (bullish if price_change > +2%, bearish if < -2%)
- Detects: is_bubble if price > baseline * 2.5 (way too high)
- Creates economic_indicators entry
- Output: "Updated indicators for [resource]"

**2. `DetectBubble(resource_type)`**
- Reads: recent price_current vs price 7 days ago
- If price increased >150% in 7 days: likely bubble
- Checks: supply hasn't increased proportionally (fundamental reason?)
- Checks: auction bid_history for frenzy activity
- Returns: bubble_severity (1-10)
- Output: Integer bubble severity, or 0 if not in bubble

**3. `InflateBubble(resource_type, severity)`**
- Price continues rising (momentum)
- Creates economic_shocks with positive recovery_rate (runaway inflation)
- Logs: bubble_severity to market_cycles
- Warns: economy in danger zone
- Increases: player speculation (more auctions created)
- Output: "⚠️ Bubble forming: [resource] rising [percent]% daily"

**4. `PopBubble(resource_type)`**
- Immediately triggers: economic_shock with crash_severity * -10x
- Sets: market_cycles.cycle_type="crash"
- Price crashes back toward baseline (fast reversion)
- Logs: crash_severity
- Affects: speculators who bought at peak (lose gold)
- Output: "💥 Bubble popped: [resource] crashed [percent]%"

**5. `InitiateRecovery(resource_type)`**
- Sets: market_cycles.cycle_type="recovery"
- Price gradually returns to equilibrium
- Sets: recovery_rate = baseline_price / cycle_duration_hours (slow return)
- Stops: wild volatility (dampens price swings)
- Allows: market to stabilize
- Duration: 48-72 hours typical
- Output: "Recovery starting: [resource] stabilizing"

**6. `GetEconomicHealth()`**
- Aggregate: is any resource in bubble? crash? recovering?
- Returns: overall_economy_health = (1.0 - bubble_severity - crash_severity) * 100%
- 100% = perfect equilibrium
- <50% = economy in crisis (multiple problems)
- Affects: NPC migration routes (less trade in crisis)
- Output: "Overall Economic Health: [percent]%"

### Feedback Loop Example: Stone Boom

```
Hour 1-12: EQUILIBRIUM
- Price: 10g per stone
- Supply: 100k stone available
- Demand: low (few building projects)

Hour 12-24: DEMAND SPIKE (construction event starts)
- Players need stone for building
- Auctions: quantity spike, prices increase
- Price: 12g per stone
- TriggerEconomicShock("demand_spike", stone, +20%)

Hour 24-48: BOOM
- Price keeps rising: 15g → 20g → 25g per stone
- Supply dwindling (being consumed faster than produced)
- Miners can't keep up
- UpdateEconomicIndicators detects: price_change = +150% in 24h
- Is_bubble = TRUE (supply hasn't increased)

Hour 48-72: BUBBLE
- Speculators buy stone to resell (no intention to build)
- Price: 35g per stone
- Auctions: frenzied bidding
- InflateBubble: price rises to 50g per stone
- Few actually building, mostly trading

Hour 72-84: CRASH
- DetectBubble returns severity=8 (way overbought)
- PopBubble: triggers crash
- Price immediately drops: 50g → 30g → 15g per stone
- Speculators panic sell
- Economic_shock: crash_severity = -80%

Hour 84+: RECOVERY
- Price stabilizes around 12g (near original baseline)
- InitiateRecovery: prices gradually normalize
- Supply replenishes (miners selling at lower prices again)
- Cycle restarts

Total cycle: 84+ hours, wild swings, economy self-regulates
```

### Speculative Trading Strategy (Player Behavior)

**Smart Traders Can Profit From Cycles**:
1. Buy cheap stone during EQUILIBRIUM (10g each)
2. Hold and create auctions when BOOM starts (sell at 25g)
3. Exit before CRASH (sell at 45g before pop)
4. Buy during CRASH (5g each) → PROFIT when cycle restarts

**Risky Traders Get Hurt**:
- Buy at peak (50g) thinking price will keep rising → CRASH → lose 60% value
- Get liquidated if auctions expire while underwater

**Market Manipulation Possible** (economy has depth!):
- Guilds could artificially inflate prices by hoarding resources
- Could trigger crashes by dumping supplies (but loses gold)
- Healthy conflict between traders and the core economy

---

## Boot Initialization (Phase 13 - Ticks 500-530)

**Tick 500**: InitializeEconomicEvents()
```
- Load all active world_events from database
- Resume event timers
- Resume economic_shocks (apply ongoing price modifiers)
- Load auction_listings (check for expired auctions)
- Auto-resolve auctions that ended while server was down
- Log: "ECONOMIC_SYSTEM: Loaded [N] events, [M] auctions"
```

**Tick 515**: InitializeSupplyChains()
```
- Load all active supply_chains (in_transit status)
- Calculate elapsed time since departure
- Check if shipments should have arrived
- Auto-deliver arrived shipments
- Check for disrupted routes (world events blocking travel)
- Auto-interrupt compromised caravans
- Log: "SUPPLY_CHAIN_SYSTEM: [N] active shipments, [M] delayed"
```

**Tick 530**: InitializeEconomicCycles()
```
- UpdateEconomicIndicators for all resources
- DetectBubble for any resource
- Check cycle_type for each resource
- Resume recovery phases if in progress
- Calculate overall_economic_health
- Broadcast: health status to players/admins
- Log: "ECONOMIC_CYCLES: Health=[health]%, [N] resources in cycle"
```

---

## Integration with Existing Systems

**Market Pricing System (Phases 2, 6, 7)**:
- Economic shocks directly modify market_prices
- Supply chains affect supply amounts in pricing formula
- Bubble detection feeds into elasticity calculations

**Consumption System (Phase 10)**:
- Demand signal comes from consumption tracking
- Hunger rates impact resource demand
- Seasonal consumption patterns visible in economic indicators

**Guild Treasury System (Phase 12)**:
- Guild spending shows demand signal
- Resource hoarding visible in supply calculations
- Guild trades affect trade volumes in auctions

**NPC State System (Phase 11)**:
- NPC migrations follow supply chains
- Trader NPCs respond to price signals
- Migration routes persistent across server restarts

---

## Integration Checklist

- [ ] 7 tables created with proper indexes
- [ ] 24+ procs implemented
- [ ] Boot sequence added to InitializationManager.dm
- [ ] World event UI/commands integrated
- [ ] Auction system accessible to players
- [ ] NPC migration AI implemented
- [ ] Economic indicator display/charting
- [ ] Bubble detection warnings
- [ ] Crash recovery mechanics
- [ ] Event chaining logic
- [ ] Build verification (expect 0 errors)
- [ ] Commit to recomment-cleanup

---

## Notes

- **Emergent Complexity**: This system has no "designed" cycles—they emerge from player behavior and game mechanics
- **Player Agency**: Traders and guilds shape economy, not vice versa
- **Failure States**: Economy can get stuck if all resources hoarded; requires admin intervention or server reset
- **Performance**: All procs use indexed queries; economic calculations happen hourly, not per-tick
- **Balance**: Boom cycles reward production/saving, crash cycles reward spending/investing
- **Long-term**: After several cycle weeks, savvy players will predict patterns and profit accordingly




---

## Phase 13A Implementation Status - 2025-12-17

### Completed ✓

**Database Schema**:
- ✓ `world_events` table (16 columns) with 4 indexes
- ✓ `auction_listings` table (12 columns) with 5 indexes  
- ✓ `economic_shocks` table (10 columns) with 3 indexes
- ✓ Added to `db/schema.sql`
- ✓ Added to SQLitePersistenceLayer verification

**Code Files**:
- ✓ Created `dm/Phase13A_WorldEventsAndAuctions.dm` (662 lines)
- ✓ 10+ procs implemented with stubs:
  - TriggerWorldEvent, ActivateWorldEvent, ResolveWorldEvent
  - CreateAuctionListing, PlaceBid, ResolveAuction, CancelAuction
  - GetAuctionHistory, AnalyzeMarketSentiment
  - TriggerEconomicShock, ApplyMarketShock
  - GenerateEventName, CleanupExpiredAuctions

**Build Integration**:
- ✓ Added `#include "dm\Phase13A_WorldEventsAndAuctions.dm"` to Pondera.dme
- ✓ Added `spawn(500) InitializeWorldEventsSystem()` to InitializationManager.dm
- ✓ Build successful (Pondera.dmb created 12/17/2025 7:23 PM)

### Next Steps (Phase 13B-C)

1. **Phase 13B**: NPC Migrations & Supply Chains
   - Add `npc_migration_routes` and `supply_chains` tables
   - Implement NPC trading AI integration
   - Create caravan disruption mechanics

2. **Phase 13C**: Economic Cycles & Feedback Loops
   - Add `economic_indicators` and `market_cycles` tables
   - Implement bubble detection and crash mechanics
   - Create self-regulating feedback loops

3. **Full Database Integration** (deferred):
   - Replace placeholder database calls with real parameterized queries
   - Integrate with actual inventory/currency systems
   - Add player inventory integration points

### Architecture Notes

- **Stub Pattern**: All 10+ procs follow stub architecture with TODO comments for future database integration
- **Boot Sequence**: Phase 13A initializes at tick 500 (after market systems ready at tick ~380)
- **Event Chaining**: Invasion events trigger plague follow-ups (implemented)
- **Market Integration**: Ready to hook into DynamicMarketPricingSystem via ApplyMarketShock()

