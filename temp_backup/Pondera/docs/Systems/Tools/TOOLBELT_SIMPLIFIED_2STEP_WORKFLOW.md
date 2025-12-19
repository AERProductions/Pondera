# TOOLBELT HOTBAR SYSTEM - SIMPLIFIED 2-STEP WORKFLOW

## Overview

The toolbelt system now implements a **radically simplified 2-step workflow**:

1. **Drag** shovel from inventory to hotbar slot 1
2. **Press** key "1" to activate tool mode

That's it. No equipping. No binding menus. No intermediate steps.

---

## System Architecture

### Hotbar Tiers

All players start with **2 base slots** (slots 1 and 2).

Craft upgraded toolbelts to unlock more:

| Toolbelt | Slots | Tier | Materials | Skill |
|----------|-------|------|-----------|-------|
| Default | 2 | - | None | - |
| Leather | 4 | 1 | 5× Leather, 3× Thread | Crafting 1+ |
| Reinforced | 6 | 2 | 8× Leather, 3× Iron Bar, 5× Thread | Smithing 2+ |
| Expert | 8 | 3 | 10× Leather, 5× Steel Bar, 1× Gem, 8× Thread | Smithing 3+ |
| Master | 9 | 4 | 15× Leather, 8× Mithril Bar, 2× Perfect Gem, 12× Thread | Smithing 5 |

Carrying any toolbelt in inventory automatically expands your hotbar. Higher tiers override lower ones.

---

## Core Features

### Drag-and-Drop Binding
- Drag item from inventory window
- Drop onto hotbar slot (1-N, where N = max_slots)
- Item instantly binds to slot

### Auto-Equip on Bind
- When item is placed in slot, it auto-equips
- No manual equip step needed
- `SetSlot()` handles auto-equip internally

### One-Key Activation
- Press hotkey (1-max_slots) to activate tool
- Tool mode determined automatically from tool type
- Selection UI appears immediately

### Tool Mode Mapping
- Shovel → Landscaping mode
- Hammer → Smithing mode
- Fishing Pole → Fishing mode
- Axe → Woodcutting mode
- Knife → Carving mode
- Hoe → Gardening mode

---

## Code Structure

### Files

1. **dm/ToolbeltHotbarSystem.dm** (664 lines)
   - Core `datum/toolbelt` with slot management
   - `ActivateTool()`, `DeactivateTool()`, `GetToolMode()`
   - Tool mode activation and mode deactivation
   - Selection UI integration

2. **dm/HotbarItemBinding.dm** (159 lines)
   - Item binding via `BindToHotbar()`
   - Unbinding via `UnbindFromHotbar()`
   - Slot clearing and management
   - Status display procs

3. **dm/ToolbeltUpgrades.dm** (239 lines)
   - Toolbelt item definitions (5 tiers)
   - Crafting recipe registry
   - Slot expansion logic via `CheckForUpgradedToolbelts()`
   - Upgrade status reporting

4. **dm/ToolbeltVisualUI.dm** (existing)
   - UI rendering for 3 styles (bar, grid, wheel)
   - Arrow key navigation

5. **dm/HotbarMacroIntegration.dm** (existing)
   - Hotkey binding (1-9 to hotbar slots)
   - Keyboard input handling

---

## Key Procs

### datum/toolbelt

```dm
New(mob/players/P)
    // Initialize with 2 slots, expand if upgraded toolbelts present
    
SetSlot(slot_num, obj/item) -> int
    // Bind item to slot, auto-equip, return 1 if success
    
GetSlot(slot_num) -> obj
    // Get item in slot
    
ActivateTool(slot_num) -> int
    // Press hotkey → activate tool mode
    // Determines mode, activates flags, shows UI
    
DeactivateTool() -> int
    // Close tool mode, hide UI, deactivate flags
    
GetToolMode(item) -> text
    // Determine tool's gameplay mode
    
ActivateMode(mode) -> int
    // Set equipment flags (SHequipped, HMequipped, etc.)
    
CheckForUpgradedToolbelts()
    // Scan inventory for toolbelt items, expand slots
    
GetHotbarStatus() -> text
    // Return formatted hotbar state
```

### obj/items

```dm
BindToHotbar(slot_num) -> int
    // Bind to slot, check permissions, return 1 if success
    
UnbindFromHotbar() -> int
    // Remove from hotbar
```

---

## Workflow Example

### Create a Brick Road

**Preconditions**:
- Have a Shovel in inventory
- Have 6× Stone materials
- Hotbar has 2+ slots

**Steps**:

1. **Drag Shovel to Slot 1**
   ```
   Open inventory → Drag Shovel → Drop on hotbar slot 1
   Message: "[Green] Bound Shovel to slot 1"
   ```

2. **Press Key "1"**
   ```
   Result:
   [Green] Equipped Shovel (landscaping mode active)
   [Cyan] --- LANDSCAPING MODE ACTIVE ---
   [Cyan] Use arrow keys to select, E to confirm
   [Yellow] ► [1] Dirt Road
   [Yellow]   [2] Wood Road
   [Yellow]   [3] Brick Road
   ```

3. **Navigate and Select**
   ```
   Press ↓ twice to select [3] Brick Road
   
   [Yellow]   [1] Dirt Road
   [Yellow]   [2] Wood Road
   [Yellow] ► [3] Brick Road
   ```

4. **Execute**
   ```
   Press E to create terrain
   
   [Green] Successfully created Brick Road!
   [Orange] Stone: 14/20
   [Green] +25 Digging XP
   ```

**Result**: Brick road appears at player location. Ready for next action or tool switch.

---

## Unlock More Slots

### Craft Leather Toolbelt (4 slots)

**Materials**: 5× Leather, 3× Thread  
**Skill**: Crafting 1+

```
Visit crafting station
Select "Leather Toolbelt" recipe
Output: Leather Toolbelt item
Add to inventory
```

**Auto-Detection**:
```
When you pick up the Leather Toolbelt:
[Yellow] Leather Toolbelt acquired! Hotbar expanded to 4 slots.
```

Now you can bind items to slots 3 and 4.

---

## Status Reporting

### Check Current Slots

```dm
/show hotbar
```

Output:
```
═══════ HOTBAR STATUS (4 slots) ═══════
1: Shovel (active)
2: Hammer
3: (empty)
4: (empty)
═══════════════════════════════
```

---

## Compilation Status

### Files with 0 Errors
- ✅ ToolbeltHotbarSystem.dm
- ✅ ToolbeltUpgrades.dm
- ✅ HotbarItemBinding.dm (1 warning - legacy item.UnbindFromHotbar call)

### Integration Points
- Integrated with existing equipment flags (SHequipped, HMequipped, etc.)
- Uses existing selection UI from ToolbeltVisualUI.dm
- Uses existing hotkey handling from macro system
- Uses existing tool mode detection

---

## Testing Checklist

- [ ] Drag item to slot works
- [ ] Item appears in hotbar
- [ ] Hotkey press activates tool
- [ ] Mode name displays
- [ ] Selection UI shows
- [ ] Navigation (↑/↓) works
- [ ] E-key executes action
- [ ] Tool switching (press different hotkey) works
- [ ] Crafting toolbelt unlocks new slots
- [ ] Status command shows correct slot count

---

## Summary

**Old Workflow** (7 steps):
1. Equip shovel
2. Open bind menu
3. Select slot
4. Confirm binding
5. Press hotkey
6. Select option
7. Press E

**New Workflow** (2 steps):
1. Drag shovel to slot
2. Press hotkey

**Reduction**: 7 → 2 steps (71% simpler)

---

## Next Phase

Once 2-step workflow is validated:
- [ ] Visual UI polish (icons, colors)
- [ ] Minigame system integration
- [ ] Tool-specific action handlers
- [ ] Sound effects
- [ ] Performance optimization
