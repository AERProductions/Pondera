# TOOLBELT HOTBAR - QUICK START (2 STEPS)

## The Workflow

### Step 1: Drag & Drop
Drag shovel from inventory → Drop on hotbar slot 1

### Step 2: Press Key
Press "1" → Landscaping mode active

**Done!** Selection UI appears, press ↓/↑ to select, E to execute.

---

## Slot Limits

| You Have | Max Slots | How to Unlock More |
|----------|-----------|-------------------|
| Nothing (base) | 2 | Default |
| Leather Toolbelt | 4 | Craft from 5× Leather + 3× Thread |
| Reinforced Toolbelt | 6 | Craft from 8× Leather + 3× Iron Bar + 5× Thread |
| Expert Toolbelt | 8 | Craft from 10× Leather + 5× Steel Bar + 1× Gem + 8× Thread |
| Master Toolbelt | 9 | Craft from 15× Leather + 8× Mithril Bar + 2× Perfect Gem + 12× Thread |

**Just pick one up** - slots auto-expand when toolbelt enters inventory.

---

## Tool Modes

| Tool | Mode | What It Does |
|------|------|------|
| Shovel | Landscaping | Create terrain (roads, hills, ditches) |
| Hammer | Smithing | Craft weapons and armor |
| Fishing Pole | Fishing | Cast lines and catch fish |
| Axe | Woodcutting | Chop trees for wood |
| Knife | Carving | Process harvested materials |
| Hoe | Gardening | Plant and maintain crops |

---

## Basic Controls

| Key | Action |
|-----|--------|
| 1-9 | Activate hotbar slot |
| ↑ | Select previous option |
| ↓ | Select next option |
| E | Execute selected action |
| ESC | Deactivate tool (close UI) |

---

## Status Commands

```dm
/show hotbar      // Show bound items and current slot
```

Example output:
```
═══════ HOTBAR STATUS (4 slots) ═══════
1: Shovel (active)
2: Hammer
3: (empty)
4: (empty)
═══════════════════════════════
```

---

## Example: Create Brick Road

1. Drag Shovel → slot 1
2. Press **1**
3. Press **↓↓** (move to Brick Road)
4. Press **E** (create)

Result: Brick road placed, stamina/materials consumed, XP earned.

---

## Why Only 2 Steps?

✅ **Drag-drop** binds item auto-equips (no separate equip button)  
✅ **Hotkey press** auto-detects tool mode (no mode selection menu)  
✅ **No confirmation dialogs** - just go  
✅ **Works while moving** - UI is non-blocking  

Old system: Equip → Menu → Bind → Select slot → Confirm → Press key → Select option → Execute  
**New system**: Drag → Press key

---

## Troubleshooting

**Hotkey does nothing?**
- Check: `/show hotbar` - is slot 1 empty?
- Solution: Drag tool to slot 1 again

**Can't drag to slot?**
- Inventory window must be visible
- Try dragging from a different inventory window location

**Unlocked 4 slots but can't use them?**
- Make sure Leather Toolbelt is in your inventory
- Slots auto-expand when toolbelt detected

**Don't know what mode a tool is?**
- Press hotkey, mode name displays in cyan
- Each tool maps to one primary mode

---

## Compilation Status

🟢 **0 Errors in toolbelt system**
- ToolbeltHotbarSystem.dm ✅
- ToolbeltUpgrades.dm ✅
- HotbarItemBinding.dm ✅

Ready to test!

---

**Version**: 2.0 (Simplified 2-Step Workflow)  
**Date**: December 13, 2025  
**Status**: COMPLETE & READY FOR TESTING
