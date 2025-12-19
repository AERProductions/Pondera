# TOOLBELT HOTBAR SYSTEM - IMPLEMENTATION COMPLETE

## Overview

Successfully implemented a 9-slot hotbar system that allows players to equip tools via hotkeys (1-9) and immediately enter gameplay modes. This is the foundation for the tool-first, gameplay-driven interaction model.

**Status**: ✅ COMPLETE & COMPILING

**Files Created**:
- `dm/ToolbeltHotbarSystem.dm` (560+ lines) - Core hotbar datum and mode system
- `dm/ToolbeltMacroIntegration.dm` (180+ lines) - Verb macros for hotkeys and navigation

**Files Modified**:
- `dm/Basics.dm` - Added toolbelt variable and initialization
- `Pondera.dme` - Includes confirmed (already present)

---

## Architecture

### Three-Layer System

**Layer 1: Hotbar Data (datum/toolbelt)**
- 9 slots (indices 1-9)
- Tracks current active tool and gameplay mode
- Manages UI visibility state

**Layer 2: Mode Activation**
- Tool type → Gameplay mode mapping (shovel → landscaping, hammer → smithing, etc.)
- Equipment flag management (SHequipped, HMequipped, etc.)
- Persistent selection UI initialization

**Layer 3: Selection & Execution**
- Persistent selection UI during gameplay
- Arrow key navigation (up/down wrapping)
- E-key immediate action confirmation (no dialogs, no menus)

---

## Key Features

### 1. Tool Equipping (Hotkeys 1-9)
```dm
// Player presses "1" to activate slot 1 tool
toolbelt.ActivateTool(1)
// Returns: 1 if success, 0 if slot empty
```

**What Happens**:
1. Tool in slot 1 is retrieved
2. Gameplay mode determined from tool type
3. Equipment flags set (e.g., SHequipped = 1 for shovel)
4. Persistent selection UI shown
5. UI visibility flag set to 1

### 2. Gameplay Mode System
Currently supports:
- **landscaping** (shovel, pickaxe, hoe)
- **smithing** (hammer, trowel)
- **fishing** (fishing pole)
- **carving** (carving knife)
- **woodcutting** (axe)

Extensible pattern for adding new tools:
```dm
proc/GetToolMode(obj/item)
    if(findtext(lowertext(item.name), "shovel"))
        return "landscaping"
    // ... add new tool type checks
```

### 3. Selection UI System
**Current State**: Text-based placeholder (functional foundation)

**Architecture**:
```
ShowSelectionUI(mode)           // Display options for mode
NavigateSelection(direction)    // Arrow key navigation
UpdateSelectionUI()             // Refresh display
ConfirmSelection()              // E-key execution
HideSelectionUI()               // Deactivate UI
```

**UI Data Flow**:
- Mode → GetModeOptions(mode) → list of available actions
- Selected index highlighted with "►" marker
- Arrow keys wrap around (1→max→1)
- E-key calls ExecuteModeAction(mode, selected)

### 4. Action Execution
**No Menus. No Prompts. Just Gameplay.**

```dm
ConfirmSelection()
    // Gets current selection
    selected = options[selected_index]
    // Immediately executes action
    ExecuteModeAction(active_mode, selected)
    // E.g., CreateTerrainObject(M, "Dirt Road")
```

---

## Hotkey Bindings

| Key | Action |
|-----|--------|
| 1-9 | Activate hotbar slot |
| ↑ | Navigate up in selection UI |
| ↓ | Navigate down in selection UI |
| E | Confirm selection & execute action |

**Utility**:
- `/hotbar status` - View current hotbar state

---

## Integration Points

### Player Creation
```dm
mob/players/New()
    // ... existing code ...
    InitializeToolbelt(src)  // Automatically initialize on login
```

### Hotbar Variable
Added to `mob/players`:
```dm
datum/toolbelt/toolbelt  // Player's hotbar instance
```

### Mode Options Routing
Currently defines stubs for:
- `GetSmithingMenuOptions(M)` - Smithing recipes
- `GetFishingMenuOptions(M)` - Fishing actions
- `GetCarvingMenuOptions(M)` - Carving tasks
- `GetWoodcuttingMenuOptions(M)` - Woodcutting targets

**Note**: `GetTerrainMenuOptions(M)` implemented in `TerrainObjectsRegistry.dm` (no duplicate)

---

## Usage Flow (Example: Shovel)

1. **Player has Shovel in inventory**
2. **Player clicks inventory to equip Shovel** (or uses item Click verb)
3. **Shovel moves to hotbar slot 1** (manual placement, or auto-assign to first empty)
4. **Player presses "1"** 
   - Hotbar detects shovel in slot 1
   - Calls `toolbelt.ActivateTool(1)`
   - Mode determined: "landscaping"
   - Flag set: `player.SHequipped = 1`
   - Selection UI shows: `[1] Dirt Road [2] Wooden Road [3] Brick Road ...`
5. **Player moves with WASD while UI visible** (non-blocking)
6. **Player presses ↓ arrow key** (twice)
   - Selection highlights `[3] Brick Road`
   - UI updates instantly
7. **Player presses E**
   - Calls `CreateTerrainObject(player, "Brick Road")`
   - Minigame begins (or object created)
   - Stamina/XP deducted
   - Resources consumed

---

## Future Enhancements

### Immediate (Next Session)
- [ ] Visual UI rendering (grid layout, wheel, horizontal bar)
- [ ] Mouse click support for selection
- [ ] Hotbar inventory assignment (drag-drop items to slots)
- [ ] Item stack handling in hotbar

### Short-Term
- [ ] Minigame integration for each mode
- [ ] Stamina drain during mode-active state
- [ ] Visual feedback (glow, particles) when tool active
- [ ] Cancel/deactivate hotkey (ESC or dedicated key)

### Long-Term
- [ ] Nested selection menus (tool → category → specific action)
- [ ] Keyboard shortcuts for specific actions (1-9 for tools, Q-O for actions)
- [ ] Hotbar appearance customization
- [ ] Mode-specific HUD overlays (heat gauge for smithing, etc.)

---

## Technical Details

### Compilation Status
✅ **0 code errors** (toolbelt system)
✅ **Integrates smoothly** with existing systems
✅ **Ready for hotbar item binding** and UI rendering

### Dependencies
- Requires: `TerrainObjectsRegistry.dm`, `Basics.dm`, item system
- Optional: Minigame systems (can be added incrementally)

### Performance Notes
- Minimal overhead (single datum per player)
- No background loops (event-driven on keypresses)
- Selection UI uses simple list iteration (O(n) where n≤25 typically)

---

## Next Steps

### For Shovel Specifically
1. Create inventory UI for adding items to hotbar
2. Implement visual grid UI for landscaping mode
3. Wire up terraining minigame (or immediate object creation)
4. Test hotkey workflow (equip → activate → select → execute)

### Testing Checklist
- [ ] Player can press 1-9 to activate slots
- [ ] Selection UI appears/disappears correctly
- [ ] Arrow keys navigate without errors
- [ ] E-key confirms and calls action handler
- [ ] Multiple tools can be switched between
- [ ] Mode persists while player moves
- [ ] Deactivating tool clears UI and flags

---

## Code Examples

### Adding a New Tool
```dm
proc/GetToolMode(obj/item)
    var/tool_name = lowertext(item.name)
    
    if(findtext(tool_name, "shovel"))
        return "landscaping"
    
    // NEW: Add support for Staff
    if(findtext(tool_name, "staff") || findtext(tool_name, "wand"))
        return "spellcasting"
    
    return ""

proc/ActivateMode(mode)
    var/mob/players/M = owner
    
    switch(mode)
        if("spellcasting")
            M.STequipped = 1  // Assume staff equipped flag
            return 1
```

### Adding New Mode Options
```dm
proc/GetCarvingMenuOptions(mob/players/M)
    var/list/options = list()
    
    // Check rank-gated recipes
    if(M.GetRankLevel(RANK_CARVING) >= 1)
        options += "Wooden Spoon"
    if(M.GetRankLevel(RANK_CARVING) >= 2)
        options += "Stone Figurine"
    if(M.GetRankLevel(RANK_CARVING) >= 3)
        options += "Marble Statue"
    
    return options
```

---

## Files Summary

### ToolbeltHotbarSystem.dm (560 lines)
**Core datum and systems**
- `datum/toolbelt` definition
- 9 slot management (Set/Get/Clear/Find)
- Mode activation/deactivation
- Selection UI (placeholder text-based)
- Mode options routing
- Action execution dispatch

### ToolbeltMacroIntegration.dm (180 lines)
**Player verbs for hotkey integration**
- 9 verb macros (hidden from menu) for hotkeys 1-9
- 2 verb macros for selection navigation (↑/↓)
- 1 verb macro for confirmation (E)
- 1 utility verb for hotbar status display

### Basics.dm (modified)
- Added `datum/toolbelt/toolbelt` variable
- Added `InitializeToolbelt(src)` call in `New()`

---

**COMPLETION DATE**: December 13, 2025
**AUTHOR**: AI Assistant (GitHub Copilot)
**STATUS**: Ready for testing and UI implementation
