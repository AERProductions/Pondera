# Deed System Architecture - Kingdom & Village Tiers

**Status**: Design Complete - Ready for Implementation  
**Date**: 12/7/25

---

## Overview

The deed system supports two distinct use cases:

| Type | System | Size | Use Case | Persistence |
|------|--------|------|----------|-------------|
| **Kingdom Deed** | Region-based (deed.dm) | 100x100 turfs | Faction territories | Persistent |
| **Village Deed** | Zone-based (ImprovedDeedSystem.dm) | Variable (S/M/L) | Player settlements | Persistent |

---

## Kingdom Deeds (Region-Based)

### Design Parameters

- **System**: `/region/deed` (deed.dm)
- **Size**: Fixed **100x100 turf area** (10,240 pixels at 32px/tile)
- **Scope**: Kingdom faction territories
- **Worlds**: Kingdom of Freedom (story mode)
- **Persistence**: Map block persistence across game sessions

### Characteristics

```dm
region/deed (Kingdom)
├─ owner: kingdom_key or player_key
├─ territory_name: "Aldoryn Plains" etc.
├─ deedallow[]: Kingdom members list
├─ size: Fixed 100x100 turfs
├─ center_turf: Kingdom capital/HQ location
└─ claim_date: When claimed
```

### Permission Model

**Kingdom Territories**:
- Only kingdom leaders can claim kingdom deeds
- All kingdom members automatically have access
- Non-members cannot build/gather/pickup in territory
- Kingdom wars can result in deed ownership transfer

### Cost Model

Kingdom deeds established through political play:
- No direct cost (earned through gameplay)
- Leadership privilege
- Can be lost in war/politics

### Implementation Notes

- Uses existing `/region/deed` structure from deed.dm
- Regions are created around `/obj/DeedToken` placement
- Region size tied to DeedToken location (100x100 area)
- Multiple kingdoms = multiple deed regions per map

---

## Village Deeds (Zone-Based)

### Design Parameters

- **System**: `/obj/DeedToken_Zone` (ImprovedDeedSystem.dm)
- **Sizes**: **Small, Medium, Large** (variable scaling)
- **Scope**: Player-created settlements
- **Worlds**: Sandbox + Story Mode
- **Persistence**: Deed inventory items + database storage

### Size Tiers

```
┌─────────────────────────────────────────────┐
│ SMALL VILLAGE (20x20 turfs)                 │
│ Cost: 100 Lucre / Month                     │
│ Max Players: 5                              │
│ Features: Basic homestead                   │
│ Best For: Solo player or small group       │
└─────────────────────────────────────────────┘
  2,048 pixels² = 2KB save data

┌─────────────────────────────────────────────┐
│ MEDIUM VILLAGE (50x50 turfs)                │
│ Cost: 500 Lucre / Month                     │
│ Max Players: 15                             │
│ Features: Shared buildings, market area     │
│ Best For: Small guild or community          │
└─────────────────────────────────────────────┘
  12,800 pixels² = 12KB save data

┌─────────────────────────────────────────────┐
│ LARGE VILLAGE (100x100 turfs)               │
│ Cost: 2000 Lucre / Month                    │
│ Max Players: 50                             │
│ Features: Full settlement, defense towers   │
│ Best For: Large guild or faction            │
└─────────────────────────────────────────────┘
  102,400 pixels² = 100KB save data
```

### Characteristics

```dm
obj/DeedToken_Zone (Village)
├─ zone_id: Unique identifier
├─ owner_key: Player owner
├─ zone_name: "Eldergrove Village" etc.
├─ zone_tier: SMALL, MEDIUM, LARGE
├─ size[2]: [20/50/100, 20/50/100]
├─ center_turf: Village center
├─ allowed_players: List (5, 15, or 50 max)
├─ maintenance_cost: Monthly upkeep
├─ maintenance_due: Next payment date
└─ founded_date: Creation date
```

### Permission Model

**Village Membership**:
- Owner is ultimate authority
- Can add/remove players
- Failed payment = auto-eviction of members
- Transfer ownership to designated heir

### Cost Model

**Village Economics**:
- **Upfront Cost**: Purchase deed scroll
  - Small: 500 Lucre
  - Medium: 2000 Lucre
  - Large: 8000 Lucre

- **Monthly Maintenance**: Due on maintenance_due date
  - Small: 100 Lucre/month
  - Medium: 500 Lucre/month
  - Large: 2000 Lucre/month

- **Upgrade**: Can expand Small→Medium→Large
  - Cost is (new_tier_cost - old_tier_paid)

- **Failed Payment**: Zone becomes "unclaimed"
  - 7-day grace period
  - Reverts to wilderness after grace period
  - All structures deleted if maintenance not paid

### Implementation Notes

- Stored as inventory item: `/obj/Deed` scroll
- Create zone via ClaimZone() verb from scroll
- Zone regions created dynamically
- Monthly maintenance triggered by time system
- Can be transferred via menu interface

---

## Coexistence & Integration

### Spatial Separation

```
World = 2 Z-levels (1 = story/sandbox, 2 = procedural)

Z-Level 1: Manual Maps
├─ Kingdom Deed Regions (100x100 areas for major territories)
└─ Village Deeds scattered throughout

Z-Level 2: Procedurally Generated
├─ Kingdom Deeds (if faction system extends here)
└─ Village Deeds (player settlements in procedural world)
```

### Permission Check Cascade

```
Player attempts action in area
  ↓
Check if in Kingdom Deed region
  ├─ YES: Check kingdom membership
  │   ├─ Member: Allow
  │   └─ Non-member: Deny
  ├─ NO: Continue
      ↓
  Check if in Village Deed zone
    ├─ YES: Check village allowed_players
    │   ├─ Allowed: Allow
    │   └─ Not allowed: Deny
    ├─ NO: Allow (wilderness)
```

### Deed Token Types

| Token Type | File | System | Used For |
|-----------|------|--------|----------|
| `/obj/DeedToken` | deed.dm | Region-based | Kingdom territories |
| `/obj/DeedToken_Zone` | ImprovedDeedSystem.dm | Zone-based | Village settlements |
| `/obj/Deed` | ImprovedDeedSystem.dm | Inventory scroll | Village creation |

---

## File Modifications Required

### 1. **deed.dm** - Kingdom Deed Enhancements
- Add kingdom-specific checks
- Ensure 100x100 size is enforced
- Add territory name display

### 2. **ImprovedDeedSystem.dm** - Village Deed Implementation
- Add SMALL/MEDIUM/LARGE tier system
- Implement size scaling (20x20, 50x50, 100x100)
- Add monthly maintenance system
- Add cost calculations
- Add failed payment handling

### 3. **DeedPermissionSystem.dm** - Already Complete
- Already checks deed permissions
- Can handle both kingdom and village checks

### 4. **Basics.dm** - Player Variables
- Add `village_deed_owner`: Track if player owns village deed
- Add `village_maintenance_due`: Next payment due date
- Add `village_zone_id`: Current village zone ID

### 5. **TimeSave.dm** - Time System Integration
- Add monthly maintenance check loop
- Process village maintenance payments
- Handle failed payment consequences

---

## Permission Variables

### On mob/players (Basics.dm)

```dm
var
    // Deed permissions (set by region entry)
    canbuild = 1            // Building/planting
    canpickup = 1           // Item pickup
    candrop = 1             // Item drop
    
    // Kingdom deed state
    kingdom_ckey = ""       // Kingdom membership
    in_kingdom_deed = FALSE // Currently in kingdom territory
    
    // Village deed state
    village_deed_owner = FALSE  // Owns village deed
    village_zone_id = 0         // Current village zone
    village_maintenance_due = 0 // Next payment tick
```

---

## Cost-to-Features Table

### Kingdom Deeds

| Feature | Cost | Benefit |
|---------|------|---------|
| Claim Territory | FREE | Strategic control |
| Add Members | FREE | Shared access |
| Evict Member | FREE | Permission control |
| Territory Cap | ~3 | Balance game |

### Village Deeds

| Tier | Upfront | Monthly | Size | Max Players |
|------|---------|---------|------|-------------|
| Small | 500 Lucre | 100/mo | 20x20 | 5 |
| Medium | 2000 Lucre | 500/mo | 50x50 | 15 |
| Large | 8000 Lucre | 2000/mo | 100x100 | 50 |

---

## World Map Coordination

### Map Block Concept

World divided into logical 100x100 regions:
- Block (0,0): Turfs 1-100, 1-100
- Block (1,0): Turfs 101-200, 1-100
- Block (0,1): Turfs 1-100, 101-200
- etc.

**Kingdom Deeds** claim entire blocks (100x100)
**Village Deeds** claim portions within blocks (20x20, 50x50, or 100x100)

### Example Layout

```
          X Axis →
     0         1         2
   ┌─────────┬─────────┬─────────┐
 0 │ Kingdom │ Kingdom │ Village │ Y
   │  Deed A │ Deed B  │  Deed 1 │ Axis
   │(100x100)│(100x100)│(50x50)  │ ↓
   ├─────────┼─────────┼─────────┤
 1 │ Village │ Wilds   │ Wilds   │
   │ Deed 2  │         │         │
   │(20x20)  │         │         │
   ├─────────┼─────────┼─────────┤
 2 │ Wilds   │ Wilds   │ Village │
   │         │         │ Deed 3  │
   │         │         │(100x100)│
   └─────────┴─────────┴─────────┘
```

---

## Implementation Phases

### Phase 1: Foundation (COMPLETE)
- ✅ Create DeedPermissionSystem.dm
- ✅ Integrate permission checks
- ✅ Refactor old deed code

### Phase 2: Village System (NEXT)
- [ ] Enhance ImprovedDeedSystem with tiers
- [ ] Add size scaling
- [ ] Implement cost system
- [ ] Create deed scroll item

### Phase 3: Maintenance System
- [ ] Add monthly payment checks
- [ ] Implement grace period logic
- [ ] Auto-eviction on payment failure

### Phase 4: Kingdom System
- [ ] Enhance deed.dm for kingdoms
- [ ] Add kingdom-specific UI
- [ ] Territory war mechanics

---

## Testing Checklist

### Kingdom Deeds
- [ ] Can claim 100x100 territory
- [ ] Kingdom members can access
- [ ] Non-members cannot build
- [ ] Territory persists on server restart

### Village Deeds - Small
- [ ] Create small village (20x20)
- [ ] Cost: 500 Lucre upfront + 100/month
- [ ] Max 5 players
- [ ] Maintenance due monthly

### Village Deeds - Medium
- [ ] Create medium village (50x50)
- [ ] Cost: 2000 Lucre upfront + 500/month
- [ ] Max 15 players
- [ ] Can expand to large

### Village Deeds - Large
- [ ] Create large village (100x100)
- [ ] Cost: 8000 Lucre upfront + 2000/month
- [ ] Max 50 players
- [ ] Full settlement functionality

### Maintenance System
- [ ] Monthly cost calculated correctly
- [ ] Grace period on non-payment
- [ ] Auto-eviction after grace period
- [ ] Zone cleanup on failure

---

## Technical Considerations

### Size Calculation

100x100 turfs = 10,000 turfs per kingdom deed
- 20x20 village = 400 turfs
- 50x50 village = 2,500 turfs
- 100x100 village = 10,000 turfs

Multiple villages can fit within a 100x100 kingdom territory

### Save File Impact

Kingdom deeds: Minimal (just region metadata)
Village deeds: Stored as savefile chunks similar to mapgen

### Performance

- Permission checks: O(1) flag lookup
- Zone boundary checks: O(n) with radius scan
- Monthly maintenance: O(m) where m = active villages

---

## Success Criteria

1. ✅ Kingdom deeds function with 100x100 fixed size
2. ✅ Village deeds available in SMALL/MEDIUM/LARGE tiers
3. ✅ Cost system implemented and enforced
4. ✅ Maintenance system monthly
5. ✅ Both systems coexist without conflicts
6. ✅ Build remains at 0 errors
7. ✅ All deed permission checks working

---

**Ready for Phase 2 implementation!**
