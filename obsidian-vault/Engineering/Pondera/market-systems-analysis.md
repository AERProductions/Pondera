

## Session 3: System Integration Analysis (2025-01-XX HH:MM)

### Market Systems Architecture - Current State

Three separate market systems identified with significant fragmentation:

#### 1. **DynamicMarketPricingSystem.dm** (497 lines)
- **Purpose**: Supply/demand economics engine
- **Data Structure**: `/datum/market_commodity` objects
- **Price Tracking**: `current_price`, `price_history`, `supply_history`
- **Dynamics**: `price_elasticity`, `price_volatility`, `min_price`, `max_price`
- **Tech Tier Support**: Affects base price calculation
- **Status**: ✅ Architecture sound, but NOT linked to actual market
- **Problem**: Price calculations exist but disconnected from active pricing

#### 2. **KingdomMaterialExchange.dm** (472 lines) - HARDCODED PRICES
- **Purpose**: Kingdom-to-kingdom material trading
- **Hardcoded Base Prices** (lines 54-56):
  ```dm
  stone_price = 1.0
  metal_price = 3.0
  timber_price = 2.5
  ```
- **Data Structure**: `/datum/kingdom_treasury_manager` with material counts
- **Volatility**: Tracked but not applied to prices
- **Status**: ❌ CRITICAL - Violates dynamic pricing architecture
- **Problem**: Static hardcoded prices prevent elasticity effects

#### 3. **MarketBoardUI.dm + MarketBoardPersistenceSystem.dm** (653 + 475 lines)
- **Purpose**: Player-driven peer-to-peer trading
- **Data Storage**: 
  - Active listings → `MapSaves/MarketBoard_Listings.sav` (savefile, NOT SQLite)
  - Player stalls → Per-player savefiles
  - Transaction history → Per-player savefiles
- **Data Structures**: `/datum/market_listing`, `/datum/market_board_manager`
- **Persistence Model**: Savefiles with manual load/save procs
- **Status**: ✅ Functional but inefficient
- **Problem**: Savefile-based storage prevents efficient queries, indexed searches, transaction auditing

#### 4. **NPCMerchantSystem.dm** (649 lines)
- **Purpose**: NPC merchant trading with personality-based pricing
- **Prices Source**: Calls `GetCommodityPrice()` using **KingdomMaterialExchange** hardcoded prices
- **Inventory**: In-memory `/datum/npc_merchant` objects
- **Trade State**: Wealth, mood, trading cooldowns
- **Status**: ❌ Volatile persistence
- **Problem**: 
  - No persistence - all NPC trades lost on restart
  - Personality modifiers (`profit_margin`) not saved
  - Total trades/wealth statistics transient

### HUD State Management - Current

**HudGroups.dm** (446 lines)
- Pure UI layout library (add/remove/pos/hide/show screen objects)
- NO game state management
- NO persistence layer
- Used by GameHUDSystem for display rendering only

**GameHUDSystem.dm** (314 lines) 
- Uses HudGroups for visual rendering
- **SavePlayerHUDState()** (lines 236-265):
  - Persists to SQLite `hud_state` table
  - Currently saves: `toolbelt_layout` (JSON), `current_slot` (int)
  - Format: `player_id | toolbelt_layout | current_slot`
- **RestorePlayerHUDState()**: Loads HUD state on login
- **Limitation**: Only toolbelt state saved; all other UI state (inventory open/closed, panel positions, etc) transient

### Critical Issues Identified

| Issue | Impact | Severity |
|-------|--------|----------|
| **3 separate price systems** | KingdomMaterialExchange hardcoded, DynamicMarketPricingSystem disconnected, NPC uses hardcoded | 🔴 CRITICAL |
| **Market prices not persisted** | Hardcoded values reset on restart; no price history across sessions | 🔴 CRITICAL |
| **Savefile-based market listings** | No database queries, can't efficiently search/filter, expensive I/O | 🟠 HIGH |
| **NPC merchant not persisted** | Trades lost on restart; reputation/wealth transient | 🟠 HIGH |
| **Limited HUD state persistence** | Only toolbelt saved; inventory/panel state lost | 🟡 MEDIUM |
| **No unified market interface** | UI systems call GetCommodityPrice() independently | 🟡 MEDIUM |

### Consolidation Opportunities

#### Priority 1: Unified Price System
- **Target**: Merge DynamicMarketPricingSystem + KingdomMaterialExchange into single SQLite-backed engine
- **Storage**: New `market_prices` SQLite table:
  ```sql
  CREATE TABLE market_prices (
    price_id INTEGER PRIMARY KEY,
    commodity_name TEXT UNIQUE,
    base_price REAL,
    current_price REAL,
    elasticity REAL,
    volatility REAL,
    supply_count INTEGER,
    tech_tier INTEGER,
    updated_at TIMESTAMP
  );
  ```
- **Benefit**: Prices persist, can implement per-kingdom price variance, audit trail

#### Priority 2: Market Listings to SQLite
- **Target**: Migrate MarketBoardPersistenceSystem from savefiles to SQLite
- **Storage**: New `market_listings` SQLite table:
  ```sql
  CREATE TABLE market_listings (
    listing_id INTEGER PRIMARY KEY,
    seller_ckey TEXT,
    item_name TEXT,
    quantity INTEGER,
    price_per_unit REAL,
    currency_type TEXT,
    created_at TIMESTAMP,
    expires_at TIMESTAMP,
    is_active BOOLEAN
  );
  ```
- **Benefit**: Efficient filtering/search, audit trail, cross-kingdom visibility

#### Priority 3: NPC Merchant Persistence
- **Target**: Persist NPC merchant state to SQLite
- **Storage**: New `npc_merchants` SQLite table:
  ```sql
  CREATE TABLE npc_merchants (
    merchant_id TEXT PRIMARY KEY,
    merchant_name TEXT,
    personality TEXT,
    current_wealth REAL,
    total_trades INTEGER,
    mood INTEGER,
    last_traded_at TIMESTAMP
  );
  ```
- **Benefit**: NPC trades preserved across restarts, relationship tracking

#### Priority 4: Extend HUD State Persistence
- **Target**: SavePlayerHUDState() extended to capture:
  - Panel visibility flags (inventory_open, market_board_open, etc.)
  - Panel positions (if moveable)
  - Last viewed market tab/filters
- **Storage**: Extend existing `hud_state` table with additional columns:
  ```sql
  ALTER TABLE hud_state ADD COLUMN panel_visibility TEXT;  -- JSON
  ALTER TABLE hud_state ADD COLUMN panel_positions TEXT;   -- JSON
  ALTER TABLE hud_state ADD COLUMN last_market_view TEXT;  -- JSON
  ```
- **Benefit**: Seamless UI restoration between sessions

### Interaction Pattern Analysis

```
Current Flow:
┌─ MarketBoardUI (player creates listing)
│  └─ CreateListing() → market_board_manager.active_listings (in-memory)
│     └─ LoadAllMarketListings() loads from MapSaves/MarketBoard_Listings.sav
│
├─ KingdomMaterialExchange (hardcoded prices)
│  └─ market_prices.stone_price = 1.0 (STATIC)
│     └─ NPCMerchantSystem.GetCommodityPrice() reads hardcoded value
│
└─ DynamicMarketPricingSystem (disconnected)
   └─ market_price_engine maintains /datum/market_commodity objects
      └─ Never reads/writes to actual prices used by systems above
```

**Problem**: Three systems operating in isolation. No unified interface.

**Proposed Flow**:
```
Unified Architecture:
┌─ Centralized SQLite-backed Market Engine
│  ├─ market_prices table (DynamicMarketPricingSystem data)
│  ├─ market_listings table (MarketBoardUI data)
│  └─ npc_merchants table (NPCMerchantSystem data)
│
├─ Market API Procs
│  ├─ GetCommodityPrice(item_name) → SQLite query
│  ├─ UpdateCommodityPrice(item_name, new_price) → SQLite update
│  ├─ CreateListing(player, item, qty, price) → SQLite insert
│  └─ GetNPCMerchantState(merchant_id) → SQLite query
│
└─ All systems call unified API
   ├─ MarketBoardUI: CreateListing() → unified API
   ├─ NPCMerchantSystem: GetCommodityPrice() → unified API
   └─ DynamicMarketPricingSystem: UpdatePrice() → unified API
```

### Recommendations

1. **Immediate (Block 1)**: Remove hardcoded prices from KingdomMaterialExchange.dm:54-56
2. **Phase 1**: Create unified market_prices SQLite table + migration script
3. **Phase 2**: Migrate MarketBoardUI from savefiles to SQLite queries
4. **Phase 3**: Persist NPC merchant state + reputation
5. **Phase 4**: Extend SavePlayerHUDState() to capture panel visibility/positions
6. **Phase 5**: Implement per-kingdom price variance in unified system

### Files Requiring Changes

| File | Changes | Priority |
|------|---------|----------|
| KingdomMaterialExchange.dm | Remove hardcoded prices, use API | 🔴 P0 |
| SQLitePersistenceLayer.dm | Add market_prices/listings/npc_merchants tables + init | 🔴 P1 |
| DynamicMarketPricingSystem.dm | Link to SQLite backend, remove in-memory price tracking | 🔴 P1 |
| MarketBoardPersistenceSystem.dm | Migrate to SQLite queries instead of savefiles | 🟠 P2 |
| NPCMerchantSystem.dm | Persist merchant state to SQLite | 🟠 P2 |
| GameHUDSystem.dm | Extend SavePlayerHUDState() + RestorePlayerHUDState() | 🟡 P3 |
| InitializationManager.dm | Add market system init check to Phase 2/Phase 6 | 🟡 P3 |

### Summary

**Market systems are fragmented across 3+ implementations with different persistence models:**
- KingdomMaterialExchange: Hardcoded in-memory prices
- MarketBoardUI: Savefile-based listings
- NPCMerchantSystem: In-memory merchant state (lost on restart)
- DynamicMarketPricingSystem: Sophisticated elasticity/volatility engine but disconnected

**Consolidation into unified SQLite-backed market engine would provide:**
- ✅ Persistent prices across restarts
- ✅ Unified API for all systems
- ✅ Efficient queries and indexing
- ✅ Audit trail for market activity
- ✅ Per-kingdom price variance support
- ✅ NPC merchant persistence

**HUD state currently limited to toolbelt persistence; extending to panel visibility/positions would improve UX.**

