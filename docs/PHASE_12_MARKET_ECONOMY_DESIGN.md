# Phase 12: Market Economy Enhancements

**Status**: Planning
**Target**: Deepen market mechanics with dynamic pricing, NPC merchants, supply/demand curves, and treasury management.

---

## Overview

Phase 12 builds on the foundation of Phase 4-5 (DualCurrencySystem, DynamicMarketPricingSystem) and Phase 11c (seasonal events) to create a living, breathing economy where:

- **Prices fluctuate** based on supply, demand, and seasonal factors
- **NPC merchants** buy/sell specific goods with personality and preferences
- **Player trading** directly impacts market prices
- **Territory wars** affect resource availability and pricing
- **Seasonal scarcity** creates economic hardship and opportunity

---

## System Architecture

### 1. Enhanced Dynamic Market Pricing

**File**: `dm/EnhancedDynamicMarketPricingSystem.dm` (NEW - 300+ lines)

**Core Changes**:
- Expand `DYNAMIC_PRICES` with more detailed price history tracking
- Add elasticity curves per item (more/less price-sensitive)
- Implement price memory (prices don't reset, they evolve)
- Add black market pricing for restricted items

**Data Structure**:
```dm
/datum/market_price
	var/item_name
	var/current_price          // Lucre or material cost
	var/base_price             // Baseline before modifiers
	var/price_history[7]       // Last 7 day prices for trends
	var/supply_level           // 0-100 (0=scarce, 100=abundant)
	var/demand_level           // 0-100 (0=unpopular, 100=essential)
	var/elasticity             // 0.5-2.0 (sensitivity to supply)
	var/volatility             // 0.05-0.5 (daily swing range)
	var/last_trade_price       // Last actual transaction price
	var/last_trade_volume      // How many units sold
	var/is_restricted          // TRUE for black market items
```

**Key Functions**:
- `UpdatePriceFromTrade(item, quantity, price_paid)` - Real trades impact prices
- `CalculatePriceWithHistory(item)` - Use trend data for forecasting
- `ApplySeasonalPriceModifier(item, season)` - Spring crops cheaper in spring, etc.
- `CalculateBlackMarketMarkup(item, scarcity_level)` - Restrict items cost more
- `GetPriceElasticity(item)` - How sensitive is price to supply changes
- `GetPrice7DayTrend(item)` - Is this item trending up/down?

---

### 2. NPC Merchant System

**File**: `dm/NPCMerchantSystem.dm` (NEW - 400+ lines)

**Concept**: Each NPC merchant has:
- Preferred goods to buy/sell
- Profit margins (not always fair!)
- Personality traits (greedy, generous, desperate)
- Inventory limits
- Personal wealth (can't always afford to buy)

**Data Structure**:
```dm
/datum/npc_merchant
	var/merchant_name          // "Tavern Keeper", "Blacksmith", etc.
	var/merchant_type          // "blacksmith", "herbalist", "trader"
	var/prefers_buying         // list("metal", "ore", "tools")
	var/prefers_selling        // list("weapons", "armor", "tools")
	var/profit_margin          // 0.8-1.5x (0.8=fair, 1.5=greedy)
	var/personality            // "greedy", "fair", "desperate"
	var/current_wealth         // Amount of Lucre merchant owns
	var/inventory              // list of item_name = quantity
	var/max_inventory_slots    // How many items can carry
	var/last_trade_time        // When did they last trade
	var/trading_cooldown       // Minutes between trades
	var/mood_modifier          // Affects willingness to trade
```

**Merchant Behaviors**:
- **Fair Merchant**: Buys at 95% of market, sells at 105%
- **Greedy Merchant**: Buys at 70% of market, sells at 150%
- **Desperate Merchant**: Buys at 120% of market (needs goods), sells at 80%
- **Specialty Merchant**: Only deals in specific goods

**Key Functions**:
- `CanAffordToPurchase(item, quantity)` - Does NPC have money?
- `GetNPCBuyPrice(item)` - What will NPC pay (below market)
- `GetNPCSellPrice(item)` - What will NPC charge (above market)
- `SellToNPC(mob/player, item, quantity)` - Player sells to NPC
- `BuyFromNPC(mob/player, item, quantity)` - Player buys from NPC
- `UpdateMerchantMood()` - Adjust mood based on recent trades
- `RespawnMerchantInventory()` - Restock periodically

---

### 3. Territory Control & Resource Availability

**File**: `dm/TerritoryResourceAvailability.dm` (NEW - 250+ lines)

**Concept**: When a territory is owned vs unclaimed, resources cost differently:

**Data Structure**:
```dm
/datum/territory_resource_impact
	var/territory_name         // "Stone Quarry", "Iron Mine", etc.
	var/primary_resource       // "stone", "metal", "wood"
	var/unclaimed_base_price   // Price when nobody owns it
	var/claimed_multiplier     // 0.7-1.5x when owned
	var/supply_capacity        // Max units available per day
	var/respawn_rate           // Units restored per hour
	var/controller_tax_rate    // What fraction owner gets as income
```

**Economic Impact**:
- **Territory Owner Controls Supply**: Limit resource extraction to drive prices up
- **Undercut Competition**: Price below market to attract buyers
- **War Economics**: Losing a territory causes resource prices to spike
- **Profit Centers**: Valuable territories become worth raiding for

**Key Functions**:
- `GetResourcePrice(resource, territory)` - Price affected by ownership
- `GetMaxResourceAvailable(resource, territory)` - Supply cap
- `HarvestResource(player, resource, territory, amount)` - Extract with limits
- `DistributeTerritoryTaxRevenue(territory)` - Owner gets paid

---

### 4. Supply & Demand Curves

**File**: `dm/SupplyDemandSystem.dm` (NEW - 280+ lines)

**Concept**: Real supply/demand affects prices dynamically:

**Supply Side**:
- How many units are being produced/harvested per cycle
- Seasonal production swings (Winter: low, Summer: high)
- Territory control affects supply
- NPC merchants affect supply (they sell, removing from market scarcity)

**Demand Side**:
- How many players actively want this item
- Seasonal demand swings (Winter: high food demand, low seeds)
- New crafting recipes increase demand
- PvP phases increase weapon demand

**Price Impact Formula**:
```
Adjusted Price = Base Price × (1 + (Supply Elasticity × Supply Deficit))
                              × (1 + (Demand Elasticity × Demand Surplus))
                              × Seasonal Modifier
                              × Territory Modifier
```

**Key Functions**:
- `CalculateSupplyLevel(item)` - % of production capacity in use
- `CalculateDemandLevel(item)` - % of players seeking item
- `GetSupplyElasticity(item)` - How much supply responds to price
- `GetDemandElasticity(item)` - How much demand responds to price
- `ApplySupplyDemandAdjustment(item)` - Update price based on curves

---

### 5. Trading Post & Market Data

**File**: `dm/TradingPostEnhancements.dm` (NEW - 200+ lines)

**Enhancements to existing market board**:
- Price history charts (ASCII or visual)
- Trend indicators (📈 up, 📉 down)
- Alerts when item reaches target price
- Bulk trading (sell 100 units at once)
- Offer matching (automatic trades at set prices)

**Key Functions**:
- `DisplayPriceChart(item)` - Show 7-day price trend
- `SetPriceAlert(player, item, target_price)` - Notify when price hits
- `PlaceBulkOffer(item, quantity, price, duration)` - Sell many at once
- `MatchOffers(buy_offer, sell_offer)` - Execute trade automatically
- `GetMarketVolume(item)` - How many units trading daily

---

### 6. Economic Crisis Events

**File**: `dm/EconomicCrisisHook.dm` (NEW - 200+ lines)

**Concept**: Occasional market shocks affect prices dramatically:

**Crisis Types**:
- **Resource Shortage**: Supply disrupted, prices spike
- **Market Crash**: Oversupply, prices plummet
- **Inflation**: All prices rise due to wealth accumulation
- **Deflation**: Player poverty reduces demand
- **Supply Chain Broken**: War disrupts trade routes

**Example Events**:
- Winter: Food prices +50%, seed prices -70%
- PvP Phase: Weapon prices +100%, armor prices +80%
- Territory War: Contested resource unavailable until resolved
- NPC Bankruptcy**: Merchant runs out of money, stops buying

**Key Functions**:
- `TriggerResourceShortage(resource, duration, severity)` - Block supply
- `TriggerMarketCrash(item_category)` - Prices plummet
- `BroadcastEconomicAlert()` - Warn players of changes
- `CalculateCrisisImpact(item)` - How much does crisis affect price

---

## Implementation Roadmap

### Phase 12a: Enhanced Dynamic Pricing (200 lines)
1. Create `EnhancedDynamicMarketPricingSystem.dm`
2. Expand price history tracking
3. Implement elasticity curves
4. Add seasonal price modifiers
5. Test with existing market board

### Phase 12b: NPC Merchant System (400 lines)
1. Create `NPCMerchantSystem.dm`
2. Define merchant data structures
3. Implement buy/sell pricing logic
4. Create 5+ diverse merchant NPCs
5. Link to existing NPC spawning system

### Phase 12c: Territory Resource Impact (250 lines)
1. Create `TerritoryResourceAvailability.dm`
2. Link to deed system
3. Implement resource extraction limits
4. Add tax revenue to territory owners
5. Test price changes based on ownership

### Phase 12d: Supply & Demand (280 lines)
1. Create `SupplyDemandSystem.dm`
2. Track supply levels in real-time
3. Calculate demand from player activity
4. Implement elasticity formulas
5. Apply adjustments to all prices

### Phase 12e: Trading Post UI (200 lines)
1. Enhance existing market board UI
2. Add price history display
3. Implement price alerts
4. Add bulk trading interface
5. Add trend indicators

### Phase 12f: Economic Crisis Events (200 lines)
1. Create `EconomicCrisisHook.dm`
2. Define 6 crisis types
3. Implement crisis triggers
4. Create broadcast messages
5. Link to admin commands

---

## Integration Points

**Existing Systems to Connect**:
- DynamicMarketPricingSystem.dm (enhance, don't replace)
- DualCurrencySystem.dm (use Lucre + Materials)
- DeedSystem.dm (territory ownership affects prices)
- SeasonalEventsHook.dm (seasonal modifiers)
- LivestockSystem.dm (animal products affect food prices)
- AdvancedCropsSystem.dm (crop yields affect food prices)
- ConsumptionManager.dm (demand for food)
- MultiWorldConfig.dm (different economy rules per continent)

---

## Success Criteria

✅ Prices update based on real trades
✅ NPC merchants have distinct personalities & pricing
✅ Territory owners profit from resource control
✅ Supply/demand curves demonstrate realistic economics
✅ Market volatility creates trading opportunities
✅ Crisis events provide narrative drama
✅ Players can't crash economy with exploits
✅ Admin can manually adjust prices if needed

---

## Example Gameplay Scenarios

### Scenario 1: Smart Trading
1. Winter comes, food prices spike to 150% base
2. Player predicts Spring will crash food prices
3. Buys 100 wheat at high Winter price
4. Spring arrives, food prices drop to 70% base
5. Player sells wheat for profit (arbitrage)

### Scenario 2: Territory Wars
1. Team A controls Iron Mine (resources cheap)
2. Team B can't access mine, prices spike
3. Team B launches raid to seize mine
4. Prices normalize, Team B profits
5. Team A retaliates in next war cycle

### Scenario 3: NPC Relationships
1. Player finds Desperate Herbalist (pays 120% for herbs)
2. Farms tons of herbs specifically for this NPC
3. Builds relationship, NPC gives discounts on potions
4. Other players notice the deal, crowd the NPC
5. NPC supply runs out, goes on cooldown

### Scenario 4: Market Crash
1. Too many players farming wheat
2. Supply exceeds demand dramatically
3. Wheat prices crash to 20% base
4. Smart players stop farming, prices recover
5. Market finds equilibrium

---

## File Summary

| File | Lines | Purpose |
|------|-------|---------|
| EnhancedDynamicMarketPricingSystem.dm | 300 | Price history, elasticity, seasonal mods |
| NPCMerchantSystem.dm | 400 | NPC personality-based pricing |
| TerritoryResourceAvailability.dm | 250 | Ownership affects resource costs |
| SupplyDemandSystem.dm | 280 | Real supply/demand curves |
| TradingPostEnhancements.dm | 200 | Market board UI improvements |
| EconomicCrisisHook.dm | 200 | Market shock events |
| **Total** | **1630** | **Complete market economy** |

---

## Next Phase (13)

**Phase 13: PvP & Raiding Mechanics**
- Combat enhancements for large-scale warfare
- Territory claiming & defense
- Raid objectives & timing
- Loot distribution & economy recovery
- Permadeath risk & consequences

