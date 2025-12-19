# Searching & Destroying Systems: Comprehensive Analysis
**Date**: December 13, 2025  
**Status**: Active but Disconnected  
**Risk Level**: HIGH - Two systems with design issues and minimal integration

---

## 1. SEARCHING SYSTEM

### 1.1 System Overview
The **Searching** system allows players to search flowers and tall grass to find items. It is a **legacy system** that is:
- **Partially functional** but disconnected from the modern unified rank system
- **Not integrated with gameplay loops** (no real pressure to use it)
- **Gated by a separate skill** (searchinglevel) that is NOT part of UnifiedRankSystem.dm

### 1.2 Current Usage

#### Where searchinglevel is Used/Checked:
| Location | Usage | Purpose |
|----------|-------|---------|
| `dm/Basics.dm` line 111 | `searchinglevel = 1` | Player initialization |
| `dm/Basics.dm` line 2006 | Stat panel (COMMENTED OUT) | `//stat(...Searching...)` - Display only |
| `dm/Objects.dm` line 5103-5250+ | `Searching()` proc | **Primary usage** - Controls item discovery probability |

#### Searching() Function Flow (Objects.dm, lines 5103-5250):
```dm
Searching()  // Triggered by clicking flowers or tall grass (lg.dm lines 916, 942, 959)
  ├─ Checks M.searchinglevel (1-5 gates)
  ├─ If M.searchinglevel <= 1:  prob(80%) → Rock (+15 XP), else nothing (+5 XP)
  ├─ If M.searchinglevel <= 2:  prob(25%) → Flint (+20 XP), else nothing (+5 XP)
  ├─ If M.searchinglevel <= 3:  prob(25%) → Ancient Ueik Splinter (+25 XP)
  ├─ If M.searchinglevel <= 4:  prob(30%) → Pyrite (+20 XP), prob(15%) → Wooden Haunch (+15 XP)
  └─ If M.searchinglevel >= 5:  prob(35%) → Whetstone (+25 XP), prob(25%) → Flint (+20 XP), etc.
```

### 1.3 XP Award Complete List (All M.seexp += Lines)

#### From `dm/Objects.dm`:
| Line | Amount | Condition | Item Found |
|------|--------|-----------|-----------|
| 5124 | +15 | searchinglevel ≤ 1, success | Rock |
| 5140 | +5 | searchinglevel ≤ 1, failure | None |
| 5150 | +20 | searchinglevel ≤ 2, success | Flint |
| 5167 | +5 | searchinglevel ≤ 2, failure | None |
| 5179 | +5 | searchinglevel ≤ 2, extra failure | None |
| 5190 | +5 | searchinglevel ≤ 2, extra failure | None |
| 5201 | +25 | searchinglevel ≤ 3, success | Ancient Ueik Splinter |
| 5217 | +5 | searchinglevel ≤ 3, failure | None |
| 5227 | +20 | searchinglevel ≤ 4, success | Pyrite |
| 5244 | +5 | searchinglevel ≤ 4, extra failure | None |
| 5256 | +15 | searchinglevel ≤ 4, Wooden Haunch success | Wooden Haunch |
| 5267 | +5 | searchinglevel ≤ 4, extra failure | None |
| 5277 | +25 | searchinglevel ≥ 5, success | Whetstone |
| 5293 | +5 | searchinglevel ≥ 5, failure | None |
| 5302 | +5 | searchinglevel ≥ 5, extra | Flint |
| 5318 | +5 | searchinglevel ≥ 5, extra | None |
| 5326 | +25 | searchinglevel ≥ 5, extra | None |

**XP Range per action**: 5-25 XP (highly variable)
**Level-up requirement**: 5 XP per level (seexpneeded += 30 per level-up)

### 1.4 Item Discovery Rate Integration

**Relationship between searchinglevel and item discovery:**
- **Searchinglevel = Gate for item types**, not discovery rate
- **Probability per level** is controlled by `prob(X)` values:
  - Level 1: 80% to find something (mostly Rock)
  - Level 2: 25% success (specific items like Flint)
  - Level 3: 25% success (Ancient Ueik Splinter)
  - Level 4: 30% Pyrite, 15% Wooden Haunch
  - Level 5+: 35% Whetstone, 25% Flint, etc.

**Key insight**: Higher searchinglevel does NOT mean better discovery rate—it means **different items available**. A level 5 player finds different items than a level 1 player, but both have similar success probabilities when searching.

### 1.5 Searching System Status

#### ✅ What Works:
- Flower/grass searching is **functional**
- Item discovery logic is **implemented**
- XP tracking is **active** (M.seexp += calls execute)
- Level-up check works via `SearchingCheck()`

#### ❌ Critical Issues:

| Issue | Impact | Evidence |
|-------|--------|----------|
| **Not unified with RANK system** | Players see two separate progression systems | `searchinglevel` is player-level var, not in `character_data` |
| **Stat panel hidden** | Players can't see Searching progress | Line 2006 in Basics.dm is COMMENTED OUT |
| **No skill unlocks tied to it** | Level-up has no rewards | `SearchingCheck()` only prints message, no recipe/ability unlock |
| **Only used with flowers** | Extremely limited interaction points | Only triggered via lg.dm Flowers/Tallgrass objects |
| **No alternative uses in PvE/PvP** | Not tied to survival mechanics | Hunger/thirst systems don't check searchinglevel |
| **Disconnected from seasons** | No seasonal gating | `CONSUMABLES` registry not checked in Searching() |

---

## 2. DESTROYING SYSTEM

### 2.1 System Overview
The **Destroying** system allows players to destroy walls they have built. It is:
- **Partially functional** with hardcoded checks
- **Restricted to Builders only** - `if(Player.char_class<>"Builder")`
- **Gated by WarHammer equipment** - `if(WHequipped!=1)`
- **NOT integrated with deed protection** - No permission check before destruction
- **Legacy system** using direct `dexp` variable, NOT unified rank

### 2.2 Wall Definitions & Properties

#### Wall Object Structure (jb.dm, lines 5258-5420):

All walls are defined as `/obj/Buildable/Walls/*` subtypes with these properties:
```dm
obj/Buildable/Walls/[variant]
  icon = 'dmi/64/wall.dmi'
  icon_state = "[direction/type]"
  density = 1              // Blocks movement
  opacity = 0              // Transparent
  HP = 100                 // Fixed HP (always 100)
  expgive = 15            // (Unused - not awarded)
```

#### 26+ Wall Variants Defined:
- **Basic directional**: `nwall`, `swall`, `ewall`, `wall` (N/S/E/W faces)
- **Corner**: `nwwall`, `newall`, `swwall`, `sewall` (diagonals)
- **3-way**: `N3Wwall`, `S3Wwall` (T-junctions)
- **4-way**: `C4Wwall` (center intersection)
- **Mid-sections**: `MIDnswall`, `MIDwewall` (interior connectors)
- **Stone variants**: `Snwall`, `Sswall`, `Sewall`, `Swall`, `Snwwall`, `Snewall`, `Sswwall`, `Ssewall` (S prefix = stone)
- **Stone 3-way**: `SN3Wwall`, `SS3Wwall`, etc.
- **Stone 4-way**: `SC4Wwall`
- **Other**: `SMIDnswall`, `SMIDwewall`, etc.

### 2.3 Current Usage of Destroying

#### Where M.dexp is Used/Checked:

| Location | Type | Usage |
|----------|------|-------|
| `dm/Basics.dm` line 119 | Init | `destroylevel = 1` |
| `dm/Basics.dm` line 1603 | XP Award | `M.dexp += 25` |
| `dm/Basics.dm` line 2008 | Stat panel | `//stat(...Destroy...)` (COMMENTED OUT) |
| `dm/Objects.dm` line 5058-5077 | Level-up check | `DestroyingCheck()` + `Destroying()` proc |

#### Wall Destruction Flow:

**Entry point**: Wall Click() handler (jb.dm, lines 5043-5062)
```dm
obj/Buildable/Walls/Click()
  ├─ Check: Must be Builder or GM
  ├─ Check: Must be within range
  ├─ Check: Player.waiter must be positive (attack cooldown)
  └─ Call: Player.Destroy(W)  // Basics.dm line 1572
```

**Destroy() Proc** (Basics.dm, lines 1572-1609):
```dm
Destroy(obj/Buildable/Walls/W)
  ├─ Check: M.stamina > 7 (or skip)
  ├─ Check: M.WHequipped == 1 (War Hammer required)
  ├─ Calculate: damage = (rand(min,max) * (Strength/100+1))
  ├─ Apply: W.HP -= damage
  ├─ Award: M.dexp += 25
  ├─ Call: DestroyedWall(W)  // Check if wall dead
  └─ Sleep: attackspeed delay (cooldown)
```

**DestroyedWall()** (Basics.dm, lines 1718+):
```dm
DestroyedWall(obj/Buildable/Walls/W)
  ├─ Check: W.HP <= 0 (wall destroyed)
  ├─ If true: Delete wall, award exp (party-split if in party)
  └─ If false: Continue (wall still standing)
```

### 2.4 XP Award Summary (Destroying)

| Line | Amount | Condition |
|------|--------|-----------|
| Basics.dm:1603 | +25 | Every wall hit (regardless of damage dealt) |

**Pattern**: One flat 25 XP award per hit, no scaling for difficulty or damage.

**Level-up check** (Objects.dm:5058-5062):
```dm
if(M.dexp >= M.dexpneeded)
    M.destroylevel += 1
    M.dexp = 0
    M.dexpneeded += 30
```

### 2.5 Destroying System Status

#### ✅ What Works:
- Wall Click detection works
- Damage calculation is implemented
- HP tracking works (W.HP -= damage)
- Wall deletion on HP <= 0 works
- Exp award logic executes

#### ❌ Critical Issues:

| Issue | Impact | Evidence |
|-------|--------|----------|
| **NO deed protection** | Walls in deeded territory can be destroyed by anyone | No `CanPlayerBuildAtLocation()` check in Destroy() |
| **No ownership check** | Any Builder can destroy any wall | Only checks `char_class`, not `buildingowner` |
| **Not unified with RANK system** | Destroying skill is separate from unified ranks | `destroylevel` is player var, not in character_data |
| **Stat panel hidden** | Players can't see Destroying progress | Line 2008 in Basics.dm is COMMENTED OUT |
| **No skill unlocks** | Level-up has no rewards | `DestroyingCheck()` does nothing on level-up |
| **expgive property unused** | Wall.expgive = 15 is declared but never used | Flat 25 XP award instead of wall.expgive |
| **Never actually called** | The legacy `Destroying()` proc in Objects.dm is unreachable | Destroy() in Basics.dm is the only entry point, and it DOESN'T call Destroying() |

---

## 3. PVP WALLS - DOES NOT EXIST

### 3.1 Current Implementation
- **NO PVP-specific walls** are defined
- **Deed system does NOT use walls for protection** - Uses permission flags instead (canbuild, canpickup, candrop)
- **Walls are purely cosmetic/blocking** in the current implementation

### 3.2 Territory Defense Architecture

**Current approach** (per copilot-instructions.md):
- Deeds claim regions via `/datum/deed` objects
- Permission bits set on player: `canbuild`, `canpickup`, `candrop`
- Building/pickup/drop gated by: `CanPlayerBuildAtLocation()`
- **NO wall-based destruction mechanics** in territory wars

**Alternative system exists**: `dm/TerritoryDefenseSystem.dm` and `dm/TerritoryWarsSystem.dm` handle sieges via:
- Siege equipment (cannons, trebuchets)
- Fortification levels
- Supply chain mechanics
- **Does NOT use Walls** for destruction

### 3.3 Evidence: Walls NOT Integrated with Deed System

**Wall owner tracking** (jb.dm, building code):
```dm
a = new/obj/Buildable/Walls/nwall(usr.loc)
a:buildingowner = ckeyEx("[usr.key]")  // Sets owner
```

**Destroy() does NOT check ownership or deed**:
```dm
// Basics.dm line 1572-1609
Destroy(obj/Buildable/Walls/W)
  // Missing checks:
  // if(!CanPlayerBuildAtLocation(M, W.loc)) return  // NOT PRESENT
  // if(W.buildingowner != M.key) return             // NOT PRESENT
```

**Result**: A player can destroy walls they don't own, as long as they are a Builder class.

---

## 4. COMPARISON TABLE

| Aspect | Searching System | Destroying System |
|--------|------------------|-------------------|
| **Functional** | ✅ Works (partial) | ✅ Works (partial) |
| **Used in gameplay** | ✅ Flowers/grass interaction | ❌ Rarely used |
| **Unified rank system** | ❌ Separate variable | ❌ Separate variable |
| **Stat panel visible** | ❌ Hidden (commented) | ❌ Hidden (commented) |
| **Skill unlocks tied to it** | ❌ No | ❌ No |
| **Permission gating** | ⚠️ Only char_class check | ⚠️ Only char_class check, no deed protection |
| **XP awards** | ✅ 5-25 XP per search | ✅ 25 XP per hit (flat) |
| **Level-up system** | ✅ Functional | ✅ Functional |
| **Only entry point** | Objects.dm Searching() | jb.dm Walls/Click() → Basics.dm Destroy() |
| **Seasonal integration** | ❌ No | ❌ No (N/A for walls) |
| **PvP integration** | ❌ No | ❌ No |
| **Deed integration** | ❌ No | ❌ **CRITICAL: No** |

---

## 5. DESIGN ASSESSMENT

### 5.1 Are These Systems Functional & Necessary?

#### Searching System:
- **Functional**: YES - Items are discovered and XP is awarded
- **Necessary**: **QUESTIONABLE**
  - Items could be gathered via other means (mining, farming, NPCs)
  - No survival pressure to use it (Hunger/thirst don't scale with searchinglevel)
  - Extremely low interaction surface (only 2-3 object types)
  - **Recommendation**: Either fully integrate into rank system OR consider deprecation

#### Destroying System:
- **Functional**: YES - Walls can be destroyed
- **Necessary**: **NOT CURRENTLY**
  - Walls are never strategically important (no deed protection)
  - No PvP use case implemented (territory wars use TerritoryDefenseSystem)
  - Only Builders can use it (1 class out of many)
  - Building destruction is decorative, not strategic
  - **Recommendation**: Either integrate with TerritoryDefenseSystem OR remove

### 5.2 Critical Gaps

#### Security Risk (HIGHEST PRIORITY):
- **Wall destruction has NO deed protection**
- A malicious Builder can destroy another player's walls without permission
- `CanPlayerBuildAtLocation()` is never called in Destroy()
- This is an anti-griefing vulnerability

#### Design Issues:
1. **Two separate skill systems** instead of unified (searchinglevel, destroylevel not in character_data)
2. **Stat panels hidden** - Players don't see progression
3. **No reward structure** - Level-ups don't unlock anything
4. **No seasonal/biome gating** - Searching ignores season data
5. **Legacy code** - Both systems use old player-level variables

---

## 6. RECOMMENDATIONS

### Phase 1: Security Fix (URGENT)
Add deed protection to wall destruction:
```dm
// Add to Destroy() in Basics.dm, line ~1575
if(!CanPlayerBuildAtLocation(M, W.loc))
    M << "You cannot destroy walls in this territory."
    return

// Also check wall ownership
if(W.buildingowner && W.buildingowner != M.key)
    M << "You can only destroy walls you built."
    return
```

### Phase 2: Decide System Fate
- **Option A**: Fully integrate both into unified rank system
  - Add `searchinglevel` → `character.seexp` / `character.SEEXP`
  - Add `destroylevel` → `character.dexp` / `character.DEXP`
  - Unlock recipes/abilities at levels
  - Integrate with seasons/biomes
  
- **Option B**: Mark as legacy and deprecate
  - Move to archive folder
  - Disable verb/interaction points
  - Remove from stat panel

### Phase 3: Design Clarity (if keeping)
- **Searching**: Link to survival (e.g., searchinglevel affects hunger drain or item quality)
- **Destroying**: Link to territory wars (walls become destructible in PvP zones)

---

## 7. AFFECTED FILES SUMMARY

### Searching System Files:
- `dm/Basics.dm`: Initialization (line 111), stat panel (line 2006)
- `dm/Objects.dm`: `Searching()` proc (5103-5250+), `SearchingCheck()` (5023-5026)
- `dm/lg.dm`: Flower/grass objects that call `Searching(M)` (916, 942, 959)
- `dm/npcs.dm`: NPC dialogue mentioning searching flowers (274, 614, 624, 645)

### Destroying System Files:
- `dm/Basics.dm`: Initialization (line 119), `Destroy()` proc (1572-1609), `DestroyedWall()` (1718), stat panel (2008)
- `dm/Objects.dm`: `Destroying()` proc (5065-5077), `DestroyingCheck()` (5056-5062)
- `dm/jb.dm`: Wall definitions (5258-5420), Click handler (5043-5062), building spawns (3486+)

### Missing Integration:
- `dm/DeedPermissionSystem.dm`: Should block wall destruction but doesn't
- `dm/TerritoryDefenseSystem.dm`: Should use walls but doesn't

---

## Conclusion

**Both systems are functional but disconnected:**

1. **Searching** works but is orphaned—low usage, no rewards, no progression visibility
2. **Destroying** works but is unprotected—**SECURITY RISK** for griefing walls
3. **Neither is critical** to core gameplay loops (survival/combat/building/economy)

**Immediate action required**: Add deed permission check to wall destruction before PvP zone implementation.

**Medium-term decision**: Decide whether to unify these systems with unified rank system or deprecate them entirely.
