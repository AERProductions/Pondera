# SHOVEL HOTBELT - SIMPLIFIED TESTING GUIDE

## What You Have Now

### Core Systems ✅
- **Hotbar**: 2 base slots, upgradeable to 9 with crafted toolbelts
- **Drag-and-Drop**: Simply drag item from inventory to hotbar slot
- **Auto-Equip**: Item auto-equips when placed in slot
- **One-Key Activation**: Press hotkey (1-2, or up to 9) to activate tool mode
- **Mode System**: Tool automatically determines gameplay mode (shovel → landscaping)
- **Selection UI**: Shows available actions for current mode

### Simplified Workflow (2 Steps)
```
1. Drag shovel from inventory to hotbar slot 1
2. Press "1" key to activate landscaping mode
```

**That's it!** No equipping, no binding menus, no steps 3-7. Just drag and press.

---

## Toolbelt Tiers

**Default**: 2 slots (everyone gets this)

To unlock more slots, craft upgraded toolbelts:

| Toolbelt | Slots | Materials | Skill |
|----------|-------|-----------|-------|
| Base | 2 | None (default) | - |
| Leather | 4 | 5× Leather, 3× Thread | Crafting 1+ |
| Reinforced | 6 | 8× Leather, 3× Iron Bar, 5× Thread | Smithing 2+ |
| Expert | 8 | 10× Leather, 5× Steel Bar, 1× Gem, 8× Thread | Smithing 3+ |
| Master | 9 | 15× Leather, 8× Mithril Bar, 2× Perfect Gem, 12× Thread | Smithing 5 |

Simply carrying a toolbelt in your inventory grants its slots. Higher-tier toolbelts override lower ones (Master = all 9 slots).

---

## Setup Instructions

### Step 1: Get a Shovel

**Option A: Admin Command (Fastest)**
```
/new /obj/items/tools/Shovel
```

**Option B: Craft It**
- Find a smithing station
- Select "Shovel" recipe
- Combine with required materials

**Option C: Find It**
- Check chests for shovels
- Trade with NPCs

### Step 2: Drag Shovel to Hotbar Slot 1

In your inventory window:
1. **Click and drag** the Shovel
2. **Drop it** onto the #1 slot in your hotbar
3. You'll see: `[Green] Bound Shovel to slot 1`

**That's it.** The shovel is now bound to slot 1 and auto-equipped.

### Step 3: Press "1"

Press the key "1" on your keyboard.

Output:
```
[Green] Equipped Shovel (landscaping mode active)
[Cyan] --- LANDSCAPING MODE ACTIVE ---
[Cyan] Use arrow keys/mouse to select, E to confirm
[Yellow] ► [1] Dirt Road
[Yellow]   [2] Wood Road
[Yellow]   [3] Brick Road
[Yellow]   [4] Stone Road
[Yellow]   [5] Hill
[Yellow]   [6] Ditch
```

Done! You're now in landscaping mode with a selection UI visible.

---

## Quick Usage

### Navigate Terrain Options
```
Press ↓ (down arrow) → Selection moves to next option
Press ↑ (up arrow)   → Selection moves to previous option
Press E              → Create selected terrain
```

### Switch Tools
Have a hammer bound to slot 2?
```
Press 2 → Hammer activates, smithing mode appears
Press 1 → Back to shovel, landscaping mode
```

### Drag-Drop to New Slot
```
Drag shovel from inventory
Drop onto slot 2
Shovel is now bound to slot 2 (auto-equipped)
Press 2 to activate it
```

---

## Verification Checklist

### Basic Workflow (2 Steps)
- [ ] Drag item to hotbar slot succeeds
- [ ] Hotbar shows item in correct slot
- [ ] Hotkey press activates tool mode
- [ ] Mode name displays correctly
- [ ] Selection UI appears

### Non-Blocking Gameplay
- [ ] Can move with WASD while UI visible
- [ ] Can combat while selecting
- [ ] Can pick up items while selecting
- [ ] UI doesn't freeze gameplay

### Tool Switching
- [ ] Press "2" deactivates current tool
- [ ] Press "2" shows different tool's UI
- [ ] Press "1" returns to previous tool
- [ ] Each tool shows its own options

### Resource Management
- [ ] Stamina decreases on action
- [ ] Materials consumed correctly
- [ ] XP awarded for action
- [ ] Feedback messages appear

---

## Slot Expansion

### Get More Slots

**Current**: You have 2 slots by default

**Unlock 4 slots**: Craft a Leather Toolbelt
```
Materials: 5× Leather, 3× Thread
Skill: Crafting 1+
```
Once crafted and in your inventory:
```
[Yellow] Leather Toolbelt acquired! Hotbar expanded to 4 slots.
```

Now you can bind items to slots 3 and 4.

**Unlock 6 slots**: Craft a Reinforced Toolbelt
**Unlock 8 slots**: Craft an Expert Toolbelt
**Unlock 9 slots**: Craft a Master Toolbelt

### Current Slot Status
Command:
```
/show hotbar
```

Output:
```
═══════ HOTBAR STATUS (4 slots) ═══════
1: Shovel (active)
2: Hammer
3: (empty)
4: (empty)
═════════════════════════════
```

---

## Troubleshooting

### Issue: Can't drag-drop to slot
**Solution**: Make sure your inventory window is open and visible. Drag-drop only works from open inventory to hotbar.

### Issue: Hotkey "1" does nothing
**Diagnosis**: Slot 1 might be empty
- Check: `/show hotbar` - should show item in slot 1
- If empty: Drag a tool to slot 1 again

### Issue: Tool doesn't equip when placed in slot
**Diagnosis**: Might be a permission or item-type issue
- Try: Equip the item manually first in inventory
- Try: Use a different tool (hammer, fishing pole, etc.)

### Issue: Selection UI doesn't appear
**Diagnosis**: Tool mode might not be recognized
- Check: Run `/demo hotbar binding` for status
- Try: Use a different tool

### Issue: Can't create terrain (stamina or materials)
**Diagnosis**: Not enough resources
- Check stamina: `/show stamina`
- Check materials: Check your inventory for required stones/materials
- Solution: Gather more materials first

### Issue: "Slot X not available"
**Diagnosis**: You haven't unlocked that many slots yet
- Solution: Craft an upgraded toolbelt to unlock more slots
- Current max: 2 slots (use Leather Toolbelt to get 4)

---

## Expected Workflow Example

### Scenario: Create a Brick Road

**Setup** (before first use):
1. Have or create a Shovel
2. Drag Shovel to hotbar slot 1
3. Have enough Stone (6 pieces)

**Execution**:
```
Step 1: Press "1" key
Output:
[Green] Equipped Shovel (landscaping mode active)
[Cyan] --- LANDSCAPING MODE ACTIVE ---
[Yellow] ► [1] Dirt Road
[Yellow]   [2] Wood Road
[Yellow]   [3] Brick Road
[Yellow]   [4] Stone Road

Step 2: Press ↓ arrow twice
Output:
[Yellow]   [1] Dirt Road
[Yellow]   [2] Wood Road
[Yellow] ► [3] Brick Road
[Yellow]   [4] Stone Road

Step 3: Press E
Output:
[Green] Successfully created Brick Road!
[Orange] Stamina: 85/100
[Orange] Stone: 14/20
[Green] +25 Digging XP
```

**Result**: Brick road tile appears at your location. You're ready to create another terrain or press "2" for a different tool.

---

## Testing Commands

### Quick Status
```
/show hotbar           // Show all bound items and current slot
/show rank             // Show your skill ranks
/show stamina          // Show current stamina
/show inventory        // List inventory contents
```

### Hotbar Operations
```
/bind_tool 1           // Manually bind selected item to slot 1 (alternative to drag-drop)
```

### Mode Demos
```
/test ui bar           // Test horizontal bar UI
/test ui grid          // Test grid UI
/test ui wheel         // Test wheel UI
```

---

## Next Phase: Expanding Tools

Once 2-step workflow is verified, add:
- **Hammer + Smithing mode**: Create weapons/armor
- **Fishing Pole + Fishing mode**: Cast and reel
- **Axe + Woodcutting mode**: Chop trees
- **Knife + Carving mode**: Process materials
- **Hoe + Gardening mode**: Plant crops

Each tool follows the same **drag-drop → press key** pattern.

---

## Complete System Status

### Implemented ✅
- **2-slot base hotbar**: Default for all players
- **Drag-and-drop binding**: Simple inventory interaction
- **Auto-equip on bind**: No manual equipping needed
- **Hotkey activation**: Press 1-max_slots to use tool
- **Tool mode mapping**: Shovel = landscaping, etc.
- **Selection UI**: Shows options for current mode
- **Toolbelt upgrades**: 5 tiers (2, 4, 6, 8, 9 slots)
- **Slot expansion**: Craft toolbelts to unlock more

### Ready for Testing ✅
- Entire workflow compiles
- All feedback messages in place
- Admin commands available
- Tile creation logic functional

### Next TODO
- [ ] Visual UI rendering (icons, colors)
- [ ] Minigame integration
- [ ] Tool-specific action handlers
- [ ] Performance optimization

---

**Status**: READY FOR TESTING
**Workflow Steps**: 2 (drag + press key)
**Time to First Action**: ~30 seconds
**Complexity**: LOW (very straightforward)
**Outcome**: Functional drag-drop hotbar with instant tool activation

