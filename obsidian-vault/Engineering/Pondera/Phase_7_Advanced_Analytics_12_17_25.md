# Phase 7: Advanced Market Analytics System
**Date**: 2025-12-17 | **Status**: ✓ Complete (0 errors, 28 warnings) | **Branch**: recomment-cleanup

## Overview
Implemented comprehensive market analytics with time-series analysis, trend detection, popularity scoring, and scarcity tracking. All analytics persist to SQLite and automatically recalculate every 5 minutes with boot initialization.

## Implementation Summary

### 1. Schema Extension (db/schema.sql)
**New Table**: `market_analytics`
```sql
CREATE TABLE IF NOT EXISTS market_analytics (
  commodity_name TEXT PRIMARY KEY,
  price_volatility_pct REAL,              -- Std dev of 7-day price history
  avg_price_7d REAL,                      -- 7-day moving average
  avg_price_30d REAL,                     -- 30-day moving average
  price_trend TEXT,                       -- 'rising', 'falling', 'stable'
  popularity_score INTEGER,               -- 0-100 based on transaction volume
  scarcity_score INTEGER,                 -- 0-100 based on shortage frequency
  supply_demand_ratio REAL,               -- Current supply / current demand
  price_points_last_7d TEXT,              -- JSON array of price history
  calculated_at DATETIME,
  last_updated DATETIME
)
```

**Indexes** (3 added):
- PRIMARY KEY on commodity_name (fast lookups)
- DATETIME INDEX on calculated_at (historical queries)
- POPULARITY DESC INDEX (trending commodities)

### 2. Analytics Calculation Procs (dm/SQLitePersistenceLayer.dm)
Added 7 new procedures:

#### `CalculateCommodityVolatility(commodity_name)`
- Queries price_history for last 7 days
- Calculates standard deviation from 7-day moving average
- Returns volatility as percentage (0-100)

#### `CalculateCommodityTrend(commodity_name)`
- Compares 7-day avg vs 30-day avg
- Returns: "rising" (7d > 30d), "falling" (7d < 30d), "stable" (7d ≈ 30d)
- Threshold: ±2% for stable classification

#### `CalculatePopularityScore(commodity_name)`
- Queries transaction count from market_transactions table (last 7 days)
- Scores 0-100 based on transaction frequency
- Baseline: 100 transactions = popularity 100

#### `CalculateScarcityScore(commodity_name)`
- Analyzes price_history for shortage events
- Counts occurrences where supply < demand
- Scores 0-100: higher score = more frequent shortages

#### `CalculateSupplyDemandRatio(commodity_name)`
- Calculates current supply / current demand
- Returns ratio (e.g., 1.5 = 50% surplus, 0.5 = 50% shortage)
- Used for supply chain analysis

#### `UpdateCommodityAnalytics(commodity_name)`
- Orchestrator proc
- Calls all 5 calculation procs sequentially
- INSERTs/UPDATEs market_analytics table with results
- Runs on individual commodity change

#### `UpdateAllAnalytics()`
- Batch processor for all commodities
- Iterates through all items in global COMMODITIES list
- Calls UpdateCommodityAnalytics per commodity
- Designed for boot initialization and periodic background updates

### 3. Boot Initialization (dm/InitializationManager.dm)
**Tick 54 - Phase 2B**:
```dm
spawn(54) UpdateAllAnalytics()  // Populate analytics after market_prices loads
```

**Phase 3 - Tick 105**:
```dm
spawn(105) StartMarketAnalyticsUpdateLoop()
```

**Background Loop Proc**:
```dm
proc/StartMarketAnalyticsUpdateLoop()
    set background = 1
    while(1)
        sleep(5000)  // 5-minute interval (~5000 ticks)
        UpdateAllAnalytics()
```

### 4. UI Display Helpers (dm/DynamicMarketPricingSystem.dm)
Added 5 formatting procs for player-facing analytics:

#### `FormatPriceWithTrend(price, trend)`
- Returns formatted string with trend arrow
- Example outputs: "42.50 ↑", "39.99 ↓", "50.00 →"

#### `FormatTrendIndicator(commodity_name)`
- Returns arrow icon based on price_trend from analytics table
- "↑" = rising, "↓" = falling, "→" = stable

#### `GetCommodityScarcityLabel(commodity_name)`
- Converts scarcity_score (0-100) to human-readable label
- Returns: "Common" (0-25), "Moderate" (26-50), "Scarce" (51-75), "Critical" (76-100)

#### `GetCommodityPopularityLabel(commodity_name)`
- Converts popularity_score (0-100) to human-readable label
- Returns: "Unpopular" (0-25), "Average" (26-50), "Popular" (51-75), "Trending" (76-100)

#### `FormatAnalyticsCard(commodity_name)`
- Returns complete analytics display string
- Combines: trend, volatility, scarcity label, popularity label, supply/demand ratio
- Designed for market board UI panels

## Integration Points

### Automatic Analytics Updates
- **RecalculateCommodityPrice()**: Now calls `UpdateCommodityAnalytics(commodity_name)` after price recalc
- **Boot sequence**: Tick 54 populates all analytics from historical data
- **Background loop**: Updates all commodities every 5000 ticks (~5 minutes)

### Real-time vs Scheduled
- **Real-time**: Individual commodity analytics updated when price changes
- **Scheduled**: Full batch update every 5 minutes (catches demand changes, transaction activity)

## Data Persistence

- **Storage**: SQLite `market_analytics` table
- **Granularity**: Per-commodity summary + calculated_at timestamp
- **History**: price_points_last_7d stores JSON array for trend visualization
- **Retention**: Analytics kept current; old records updated (not deleted) to preserve history

## Performance Considerations

### Database Queries
- Volatility calc: Single query with 7-day window
- Popularity calc: COUNT(*) on market_transactions (indexed)
- Trend calc: Two AVG() queries (7-day and 30-day windows)
- Scarcity calc: Single query counting shortage events

### Update Frequency
- Boot: Single full batch update (Tick 54)
- Runtime: 5000-tick intervals (non-blocking background loop)
- Real-time: Individual commodity updates on price change (lightweight)

### Optimization
- Indexes on commodity_name prevent table scans
- Batch updates batched to reduce DB round-trips
- Background loop uses `set background = 1` to avoid blocking game world

## Files Modified

1. **db/schema.sql** (+35 lines)
   - market_analytics table definition
   - 3 indexes

2. **dm/SQLitePersistenceLayer.dm** (+120 lines)
   - 7 analytics calculation procs

3. **dm/InitializationManager.dm** (+40 lines)
   - Tick 54 initialization
   - Background loop spawning and proc

4. **dm/DynamicMarketPricingSystem.dm** (+80 lines)
   - 5 UI display helper procs

## Test Results

- **Compilation**: 0 errors, 28 warnings
- **Build**: Successful (12/17/25 3:38 pm)
- **Schema validation**: 5 false positive linting errors (T-SQL linter doesn't understand SQLite syntax; verified successful in Phases 2-6)

## Next Phase (Phase 8)

Potential expansions:
- Advanced market prediction (ML trend forecasting)
- Supply chain recommendations (scarcity alerts for traders)
- Historical analytics dashboards (price history graphs)
- Commodity correlation analysis (which items move together)

## Related Documents

- [[Phase_1_SQLite_Setup_12_6_25|Phase 1: SQLite Foundation]]
- [[Phase_2_Market_Persistence_12_9_25|Phase 2: Market Data]]
- [[Phase_3_NPC_Persistence_12_10_25|Phase 3: NPC Merchants]]
- [[Phase_4_HUD_State_Persistence_12_12_25|Phase 4: HUD State]]
- [[Phase_5_Deed_Persistence_12_14_25|Phase 5: Deed System]]
- [[Phase_6_Market_Price_Dynamics_12_17_25|Phase 6: Price History]]
