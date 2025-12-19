# Ueik Pickaxe Mining System - Design Specification

## Overview

**Goal**: Implement pickaxe mining with material-tier-based mechanics:
- **Ueik Pickaxe (Rudimentary)**: Fragile, low durability, 1 swing/action
- **Iron Pickaxe (Basic)**: Medium durability, 1 swing/action  
- **Steel Pickaxe (Advanced)**: High durability, 2 swings/action

## Core Systems

### 1. Durability System (`PickaxeMiningSystem.dm`)

#### `/datum/pickaxe_durability`
Tracks durability for each pickaxe instance:
```
Ueik:   max=50,   loss/swing=8   → breaks after ~6 uses
Iron:   max=150,  loss/swing=5   → breaks after ~30 uses
Steel:  max=300,  loss/swing=4   → breaks after ~75 uses
```

**Key Methods**:
- `GetDurabilityPercent()` → 0-100% remaining
- `IsFragile()` → TRUE when < 20% durability (show wear message)
- `IsBroken()` → TRUE when durability ≤ 0 (mining impossible)
- `ReduceDurability(swings)` → Decreases by loss per swing, returns if broken
- `GetWearMessage()` → Player feedback based on durability state

**Behavior**:
- Player equips pickaxe → `/mob/players/InitializePickaxeDurability()` creates datum
- Each swing → `/AttemptPickaxeMining()` calls `ReduceDurability(1)`
- Broken pickaxe → Message displayed, mining blocked until replaced

### 2. Ore Selection UI (`PickaxeOreSelectionUI.dm`)

#### `/datum/ore_selection`
Grid-based ore type selection (same pattern as Shovel landscaping UI):

```
== ORE SELECTION ==
↑/↓ to navigate | E to select

>> Stone <<
Iron
Copper

(Press Q to cancel)
```

**Key Features**:
- Lists available ore types based on nearby cliffs
- Arrow keys navigate selection (UP/DOWN wraps around)
- E key confirms and begins mining
- Q key cancels and closes UI
- Non-blocking (player can move while UI visible)

**Integration with Pickaxe Types**:
| Pickaxe | Can Mine | Notes |
|---------|----------|-------|
| Ueik | Stone only | SRocks (basic ore) |
| Iron | Stone, Iron | SRocks + IRocks |
| Steel | All ore types | All Cliffs/* |

### 3. Macro/Keyboard Binding (`PickaxeModeIntegration.dm`)

Players configure hotkeys:
```
Slot 1-9:  /toolbelt_activate_slot_N  (press number key)
Arrow UP:  /ore_select_up              (navigate ore selection)
Arrow DN:  /ore_select_down            (navigate ore selection)
E Key:     /ore_select_confirm         (confirm & mine)
Q Key:     /ore_select_cancel          (close UI)
```

Example hotkey setup:
```
Bind "4" = toolbelt_activate_slot_4   // Equips pickaxe from slot 4
Bind "Up" = ore_select_up              // Navigate ore list up
Bind "Down" = ore_select_down          // Navigate ore list down
Bind "e" = ore_select_confirm          // Start mining selected ore
Bind "q" = ore_select_cancel           // Close ore selection
```

## Gameplay Flow - Ueik Pickaxe Example

### Step 1: Player Equips Pickaxe
```
Player right-clicks Ueik Pickaxe → Add to Hotbelt (slot 4)
Player presses "4" → Hotbelt activates slot 4 (Ueik Pickaxe)
  OnActivateTool("pickaxe", player)
  → InitializePickaxeDurability("ueik")
     Creates datum with max=50, loss=8/swing
```

### Step 2: Ore Selection UI Opens
```
ActivatePickaxeMode(player)
  → OpenOreSelectionUI()
     Scans nearby ore cliffs (view range 2)
     Filters: Ueik can only mine SRocks (Stone)
     Displays: ">> Stone <<"
  → Renders UI to player
     Shows available ore types with arrow key hints
```

### Step 3: Player Navigates & Selects Ore
```
Player presses UP/DOWN arrows:
  ProcessOreSelectionInput(direction)
  → Highlights different ore types
  → Re-renders UI

Player presses E:
  ExecuteOreSelection()
  → Finds nearest cliff matching selected ore type
  → Closes UI
  → Calls ExecutePickaxeMining(target_cliff)
```

### Step 4: Mining Action Executes
```
ExecutePickaxeMining(ore_cliff)
  1. AttemptPickaxeMining(ore_cliff) called
     - Checks if durability exists and not broken
     - Loops swings_per_action times (1 for Ueik)
       - Performs ore extraction (calls mining.dm Mine() proc)
       - Reduces durability by 8 (Ueik loss rate)
       - If broken, displays "Ueik pickaxe has shattered!"
       - Returns FALSE on break
     - Returns TRUE if all swings succeeded
  
  2. If successful:
     - Ore added to player inventory
     - Mining XP awarded (from mining.dm)
     - Wear message displayed:
       "Your ueik pickaxe is heavily worn and fragile!"
  
  3. If broken:
     - Mining halted mid-swing
     - Ore NOT collected
     - Message: "Your ueik pickaxe has shattered!"
     - Player must find new pickaxe to continue
```

## Integration with Existing Systems

### ToolbeltHotbarSystem.dm
- `GetToolMode(item)` extended to detect pickaxe items
- `ActivateTool(slot)` calls `ActivatePickaxeMode()`
- Tool type detection works for ANY pickaxe variant (ueik, iron, steel, etc.)

### mining.dm (Existing)
- **No changes required** - durability tracking is transparent
- Mine(M) proc executes same ore extraction logic
- XP gains and ore spawning unaffected by durability system
- Durability only affects whether swing succeeds/fails

### Character Data (Character.dm)
- Pickaxe durability is **ephemeral** (not saved to file)
- Persists only for current session
- New pickaxe equipped = new durability datum created
- (Future: Could serialize durability to character data if needed)

## Material-Based Progression

### Rudimentary Tier (Ueik)
- **Max Durability**: 50 points
- **Loss Rate**: 8 per swing → ~6 uses before breaking
- **Swings**: 1 per action
- **Fragile Threshold**: 20% (~10 durability points remaining)
- **Design Goal**: Teaching tool; forces player to manage fragility
- **Cost to Replace**: Minimal (Thorn + Wooden Haunch easily found)
- **UX**: Frequent "wear" messages remind player of breakage risk

### Basic Tier (Iron)
- **Max Durability**: 150 points
- **Loss Rate**: 5 per swing → ~30 uses before breaking
- **Swings**: 1 per action
- **Fragile Threshold**: 20% (~30 durability points remaining)
- **Design Goal**: Reliable tool for sustained mining sessions
- **Cost to Replace**: Moderate (Smithing required, 3 Iron Ingot)
- **UX**: Less frequent warnings, longer play session possible

### Advanced Tier (Steel)
- **Max Durability**: 300 points
- **Loss Rate**: 4 per swing → ~75 uses before breaking
- **Swings**: 2 per action (double harvest per button press)
- **Fragile Threshold**: 20% (~60 durability points remaining)
- **Design Goal**: Efficient end-game tool; rewards progression
- **Cost to Replace**: High (Complex smithing, high-tier materials)
- **UX**: Minimal warnings; tool feels "legendary"
- **Advantage**: 2 swings = 2x ore per action = faster mining rate

## Error Handling & Edge Cases

### Broken Pickaxe
```
AttemptPickaxeMining() → durability <= 0
  → "Your ueik pickaxe is broken!"
  → Mining blocked
  → Player must equip new pickaxe
```

### No Eligible Ore
```
OpenOreSelectionUI() → No SRocks in range
  → "No mineable ore nearby."
  → UI not shown
  → Player must move closer to ore cliff
```

### Pickaxe Unequipped During Mining
```
If player drops pickaxe while in ore selection UI:
  CancelOreSelection() called
  → "Ore selection closed."
  → UI closes automatically
```

### Invalid Ore Type for Pickaxe
```
Player with Ueik pickaxe tries to mine Iron ore:
  FilterOreEligibility() prevents Iron from appearing in list
  → Only Stone shows in UI
  → Ueik cannot attempt Iron ore mining
```

## Testing Checklist

- [ ] Ueik Pickaxe: Durability decreases by 8 per swing
- [ ] Ueik Pickaxe: Breaks after ~6 mining actions
- [ ] Ueik Pickaxe: Can only mine Stone ore
- [ ] Iron Pickaxe: Durability decreases by 5 per swing (30 uses)
- [ ] Iron Pickaxe: Can mine Stone + Iron ore
- [ ] Steel Pickaxe: 2 swings per action (both succeed or both fail)
- [ ] Steel Pickaxe: Can mine all ore types
- [ ] Ore Selection UI: Arrow keys navigate list correctly
- [ ] Ore Selection UI: E key confirms selection & starts mining
- [ ] Ore Selection UI: Q key cancels without mining
- [ ] Fragility Message: Displays when <20% durability
- [ ] Broken Pickaxe: Message shown on break, mining blocked
- [ ] Durability Reset: New pickaxe equipped = new durability datum

## Future Enhancements (Not in Initial Release)

1. **Durability Repair**: NPCs/smithing stations restore durability
2. **Tool Enchantments**: Special pickaxes with +durability
3. **Ore Difficulty Tiers**: Diamond ore requires Steel pickaxe or better
4. **Crafting Integration**: Gather broken pickaxe fragments for crafting
5. **Performance Optimization**: Ore selection caches nearby cliffs
6. **Multi-tier Mining**: Mining deep veins requires multiple swings in sequence
7. **Weather Effects**: Rain/snow reduces mining efficiency
8. **NPC Training**: NPCs teach proper pickaxe technique to reduce wear

## Files Created/Modified

### New Files
- `dm/PickaxeMiningSystem.dm` (370 lines) - Durability datum & mechanics
- `dm/PickaxeOreSelectionUI.dm` (190 lines) - UI grid & navigation
- `dm/PickaxeModeIntegration.dm` (140 lines) - Hotbelt integration & verbs

### Modified Files
- `Pondera.dme` - Add `#include` for 3 new files (before mapgen block)
- `dm/ToolbeltHotbarSystem.dm` - `GetToolMode()` extended to detect pickaxe
- `dm/mining.dm` - (OPTIONAL) Add durability checks to existing Mine() procs

### Reference Files (No Changes)
- `dm/mining.dm` - Ore extraction logic (unchanged, works transparently)
- `toolslegacyexample.dm` - Pickaxe item definitions (reference only)
- `dm/Weapons.dm` - Pickaxe object definitions (reference only)

## Summary

The Ueik Pickaxe Mining System introduces **fragility-based gameplay** that encourages tool management and strategic planning. By scaling durability across material tiers (Ueik → Iron → Steel), players experience natural progression where better tools feel genuinely superior. The arrow-key UI keeps mining interactive and non-blocking, maintaining Pondera's dynamic gameplay feel.

**Key Design Principle**: Early-game tools fail often (teaching resource management); late-game tools are reliable (rewarding progression).
