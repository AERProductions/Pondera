# Pickaxe System Architecture & Progression Roadmap

## System Architecture Overview

All pickaxe types (Ueik, Iron, Steel, Damascus, etc.) use the **same durability system** with different configuration parameters:

```
PickaxeMiningSystem.dm (Universal)
    ↓
    └─→ /datum/pickaxe_durability
            ├─ Ueik:      max=50,   loss=8,   swings=1
            ├─ Iron:      max=150,  loss=5,   swings=1
            ├─ Steel:     max=300,  loss=4,   swings=2
            ├─ Copper:    max=120,  loss=6,   swings=1  (future)
            └─ Damascus:  max=500,  loss=2,   swings=2  (future)

PickaxeOreSelectionUI.dm (Universal)
    ↓
    └─→ /datum/ore_selection
            Filters eligible ore types by pickaxe material tier
            Uses same grid UI for all pickaxe types

ToolbeltHotbarSystem.dm (Extended)
    ↓
    └─→ GetToolMode() detects pickaxe type
    └─→ OnActivateTool() routes to ore selection
```

**Key Insight**: System is **completely scalable**. Adding new pickaxe variants requires only:
1. Create item in game (e.g., `obj/items/tools/CopperPickaxe`)
2. Add durability parameters to `New()` proc switch statement
3. Define ore eligibility filters in `OpenOreSelectionUI()`

## Durability Progression Chart

```
Tool Type  | Max Dur. | Loss/Use | Uses   | Swings | Material Cost | End-Game?
-----------|----------|----------|--------|--------|---------------|----------
Ueik       | 50       | 8        | 6      | 1      | Low (Thorn)   | No
Iron       | 150      | 5        | 30     | 1      | Med (Smithing)| No
Steel      | 300      | 4        | 75     | 2      | High (Complex)| Yes
Copper*    | 120      | 6        | 20     | 1      | Low-Med       | No
Damascus*  | 500      | 2        | 250    | 2      | Very High     | Yes
Mythril*   | 800      | 1        | 800    | 3      | Legendary     | Yes+

* = Future tiers (not in initial release)
```

## Ore Type Availability by Pickaxe

### Tier-Based Ore Access

```
UEIK PICKAXE (Rudimentary - teaches fragility)
├─ Can mine:
│  ├─ Stone Ore (rarity 90)       [SRocks]
│  ├─ Iron Ore (found in stone)   [Hidden in SRocks]
│  └─ Lead Ore (basic) [Optional]
├─ Cannot mine:
│  ├─ Iron Rocks                  [Higher tier ore]
│  ├─ Copper, Zinc, etc.          [Need better tools]

IRON PICKAXE (Basic - reliable workhorse)
├─ Can mine:
│  ├─ Stone Ore
│  ├─ Iron Ore
│  ├─ Copper Ore                  [IRocks/CRocks]
│  ├─ Zinc Ore
│  └─ Lead Ore
├─ Cannot mine:
│  ├─ Gold, Gem veins             [Need steel+]

STEEL PICKAXE (Advanced - efficient endgame)
├─ Can mine:
│  ├─ All basic ores
│  ├─ Gold Ore                    [Higher rarity]
│  ├─ Gem Veins                   [Diamond, Ruby, etc.]
│  ├─ Obsidian Veins
│  └─ Mithril Ore                 [Legendary, super rare]
├─ Special:
│  └─ 2 swings per action = 2x efficiency
```

## Design Philosophy by Tier

### Rudimentary (Ueik)
**Goal**: Tutorial/resource management
- **Why fragile?** Forces player to think about tool maintenance
- **Why 1 swing?** Teaches patience; lets them plan mining sessions
- **Why Stone only?** Limits scope; prevents accessing endgame content too early
- **Gameplay Feel**: "Crude makeshift tool held together with hope"

**Player Progression**:
```
Day 1: "My pickaxe broke! Better craft another Ueik pickaxe..."
Day 2: "I've made 5 pickaxes. This is tedious. Time to mine Iron Ore to craft Iron Pickaxe?"
Day 3: "Finally! Iron Pickaxe lasts 30 times. Much better."
```

### Basic (Iron)
**Goal**: Reliable mining tool; rewards early progression
- **Why durable?** Player has earned tool management competency
- **Why 1 swing?** Maintains parity with Ueik (single-action mining)
- **Why multiple ore types?** More mining diversity; incentivizes exploration
- **Gameplay Feel**: "Professional mining tool; solid and dependable"

**Player Progression**:
```
Mid-Game: "Iron pickaxe opens up more ore types. I can now farm copper for other recipes."
Late-Game: "Still using Iron pickaxe, but I'm eyeing that Steel pickaxe..."
```

### Advanced (Steel)
**Goal**: Endgame efficiency; feels genuinely superior
- **Why highly durable?** Players feel invested; tool lasts entire mining session
- **Why 2 swings?** **MAJOR** quality-of-life upgrade; significantly faster mining
- **Why all ore types?** Becomes mining bottleneck (other systems gate progression)
- **Gameplay Feel**: "Legendary tool; feels like progression payoff"

**Player Progression**:
```
Endgame: "Steel pickaxe! I can get 2 ore per swing. Mining is finally efficient."
Reason to keep: "2 swings means I mine twice as fast. Worth the smithing time."
Reason to eventually replace: "Damascus pickaxe does 2 swings AND lasts 500 uses?"
```

## Implementation Roadmap

### Phase 1: Ueik Pickaxe (IN PROGRESS)
- ✅ Durability system foundation
- ✅ Ore selection UI
- ✅ Hotbelt integration
- ⏳ TODO: mining.dm integration check
- ⏳ TODO: Player testing & balancing

**Estimated Effort**: 4-6 hours (including testing)

### Phase 2: Iron Pickaxe (FUTURE)
- Create `obj/items/tools/PickAxe` (Iron variant)
- Add to `PickaxeMiningSystem.dm` durability switch (max=150)
- Update `OpenOreSelectionUI()` ore filter (allow Iron ore)
- Smithing recipe (3 Iron Ingot → Pickaxe Head)
- Handle in Hotbelt detection (GetToolMode extends to "iron pickaxe")

**Estimated Effort**: 2-3 hours (mostly reusing Ueik code)

### Phase 3: Steel Pickaxe (FUTURE)
- Create `obj/items/tools/SteelPickaxe`
- Add durability + **2 swings per action** logic
- Update ore selection (add gem veins, gold)
- Complex smithing recipe (5+ Steel Ingots + rare materials)
- Animation/visual feedback for "double swing" action

**Estimated Effort**: 3-4 hours (double-swing logic is new)

### Phase 4: Advanced Tiers (Aspirational)
- Copper pickaxe (mid-tier, between Iron/Steel)
- Damascus pickaxe (legendary, super durable, 2 swings)
- Mythril pickaxe (endgame+, 3 swings, ultra-rare)

**Estimated Total Effort**: 15-20 hours for all tiers

## Code Reusability

### 100% Reusable Across Pickaxes
- `PickaxeMiningSystem.dm` - Just change durability params in `New()`
- `PickaxeOreSelectionUI.dm` - No changes needed; filters work generically
- `PickaxeModeIntegration.dm` - Works for any pickaxe variant

### Minimal Code Per New Pickaxe
To add Steel Pickaxe:
```dm
// In PickaxeMiningSystem.dm, add 1 case:
if("steel")
    max_durability = 300
    current_durability = 300
    swings_per_action = 2      // NEW: 2 swings
    durability_loss_per_swing = 4

// In PickaxeOreSelectionUI.dm, update ore filter:
if(pickaxe_type == "steel")
    // Can mine ALL ore types
    eligible_cliffs += C  // No restrictions

// That's it! Hotbelt detection auto-works via name matching.
```

## Performance Considerations

### Memory Usage (Per Pickaxe Equipped)
```
Ueik pickaxe:     ~250 bytes (datum + 2 var refs)
Iron pickaxe:     ~250 bytes (same structure)
Steel pickaxe:    ~250 bytes (same structure)
Total per player: ~250 bytes (only 1 pickaxe active at a time)
```

### CPU Usage
- Ore selection UI render: **O(n)** where n = ore types nearby (avg 3-4)
- Durability check: **O(1)** (simple comparison)
- Mining loop: **O(swings)** where swings = 1-3 (negligible)
- **Conclusion**: Negligible overhead; system is performant

### Network Overhead
- No extra network traffic beyond existing tool equipping
- All calculations client-side (optional server-side validation later)
- **Conclusion**: Zero network impact

## Balancing Knobs (Easy Tweaks)

If playtesting reveals issues:

```dm
// Too easy? Increase loss per swing:
durability_loss_per_swing = 10  // Was 8 for Ueik

// Too grindy? Decrease loss rate:
durability_loss_per_swing = 5   // Was 8 for Ueik

// Want faster endgame? Increase steel swings:
swings_per_action = 3           // Was 2

// Make fragility less annoying? Raise threshold:
fragility_threshold = 50        // Was 20% (show warnings earlier)
```

These changes can be made in **one file** (PickaxeMiningSystem.dm) without touching game logic.

## Testing Strategy

### Unit Tests (Per Pickaxe Type)
For each pickaxe tier, test:
1. ✅ Durability decreases at correct rate
2. ✅ Breaks after correct number of uses
3. ✅ Can mine correct ore types
4. ✅ Cannot mine restricted ore types
5. ✅ Correct number of swings per action (1 vs 2)
6. ✅ UI displays correct ore options

### Integration Tests
1. ✅ Hotbelt recognizes all pickaxe variants
2. ✅ Ore selection appears on activation
3. ✅ Mining XP still awarded (unchanged)
4. ✅ Broken pickaxe blocks further mining
5. ✅ New pickaxe resets durability

### Balancing Tests
1. Does Ueik feel appropriately fragile?
2. Does Iron feel like a "nice upgrade"?
3. Does Steel feel like a "major reward"?
4. Is mining speed paced reasonably?

## Extensibility

To add a new pickaxe at any point:

1. **Define item object** (1 DM file, ~20 lines)
2. **Add durability params** (2-3 lines in PickaxeMiningSystem.dm)
3. **Define ore access** (2-3 lines in PickaxeOreSelectionUI.dm)
4. **Add crafting recipe** (existing smithing system handles this)
5. **Test** (run unit tests for new pickaxe)

**Total time per new pickaxe**: ~30-45 minutes

## Summary

The pickaxe system is designed to **scale horizontally** across material tiers while maintaining consistent mechanics:

- **Same code** serves all pickaxe types
- **Durability params** are the only differentiator
- **Adding new pickaxes** is trivial (4 lines of code per tier)
- **System is balanced** for tutorial (Ueik) → endgame (Steel) progression

This architecture allows us to launch Ueik Pickaxe now, then incrementally add Iron/Steel without refactoring existing code.

**Next pickaxe after Ueik**: Iron (estimated 2-3 hours implementation + testing)
