# SHOVEL HOTBELT GAMEPLAY FLOW

## Complete User Experience

```
┌─ PLAYER LOGS IN ────────────────────────────────────────────────┐
│                                                                   │
│  ✓ Player created                                               │
│  ✓ Toolbelt initialized (9 empty slots)                         │
│  ✓ Hotkeys 1-9 ready to bind tools                              │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌─ PLAYER EQUIPS SHOVEL ──────────────────────────────────────────┐
│                                                                   │
│  1. Player has: Shovel (wooden handle, metal blade)             │
│  2. Player clicks inventory item "Shovel"                        │
│  3. Shovel equipped:                                             │
│     - Added to player inventory with "Equipped" suffix           │
│     - Sets player.SHequipped = 1 (passive state)                │
│     - Available to bind to hotbar                               │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌─ PLAYER BINDS SHOVEL TO HOTBAR SLOT 1 ──────────────────────────┐
│                                                                   │
│  Method 1 (Future - Drag/Drop):                                 │
│    - Inventory: [Shovel (Equipped)]                             │
│    - Hotbar: [empty] [empty] ...                                │
│    - Player drags Shovel to slot 1                              │
│    - Result: hotbelt.SetSlot(1, shovel_object)                  │
│                                                                   │
│  Method 2 (Future - Right-click):                               │
│    - Right-click Shovel in inventory                            │
│    - Select "Bind to Slot 1"                                    │
│    - Result: hotbelt.SetSlot(1, shovel_object)                  │
│                                                                   │
│  Method 3 (Manual - For Testing):                               │
│    - Admin command: /bind_tool 1 shovel                         │
│    - Result: hotbelt.SetSlot(1, shovel_object)                  │
│                                                                   │
│  Hotbar Status After:                                           │
│    [1] Shovel       [2] (empty)   [3] (empty) ...               │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌─ PLAYER PRESSES KEY "1" (HOTKEY FOR SLOT 1) ────────────────────┐
│                                                                   │
│  Event: Player presses "1"                                       │
│  ↓                                                                │
│  Verb: mob/players/verb/Toolbelt_Slot_1()                       │
│  ↓                                                                │
│  Action: toolbelt.ActivateTool(1)                               │
│                                                                   │
│  Processing:                                                     │
│    1. Retrieve slot 1 item: shovel_object                       │
│    2. Validate tool exists (not null)                           │
│    3. Determine mode from tool type                              │
│       → GetToolMode(shovel_object)                              │
│       → "shovel" → "landscaping" ✓                              │
│    4. Activate mode: ActivateMode("landscaping")                │
│       → Set player.SHequipped = 1 (already set, redundant)      │
│    5. Get landscaping options:                                   │
│       → GetTerrainMenuOptions(player)                           │
│       → Returns: ["Dirt Road", "Wood Road", "Brick Road",       │
│                   "Hill", "Ditch", ...]                         │
│    6. Show persistent UI                                         │
│    7. Set ui_visible = 1, selected_index = 1                    │
│                                                                   │
│  Output to Player:                                               │
│    [Cyan] Equipped Shovel (landscaping mode active)             │
│    [Cyan] --- LANDSCAPING MODE ACTIVE ---                       │
│    [Cyan] Use arrow keys/mouse to select, E to confirm          │
│    [Yellow] ► [1] Dirt Road                    ← highlighted    │
│    [Yellow]   [2] Wood Road                                      │
│    [Yellow]   [3] Brick Road                                    │
│    [Yellow]   [4] Stone Road                                    │
│    [Yellow]   [5] Hill                                          │
│    [Yellow]   [6] Ditch                                         │
│    [Yellow]   ... (more options)                                │
│                                                                   │
│  Current State:                                                  │
│    - Active tool: Shovel                                        │
│    - Active mode: landscaping                                   │
│    - UI visible: YES                                            │
│    - Selected index: 1 ("Dirt Road")                            │
│    - Player can still move (WASD) without UI blocking           │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌─ PLAYER MOVES WITH WASD (UI STAYS VISIBLE) ──────────────────────┐
│                                                                   │
│  Game Time: 0:15 - Player near forest edge                      │
│                                                                   │
│  Current Selection UI (unchanged):                              │
│    [Yellow] ► [1] Dirt Road                    ← still selected │
│    [Yellow]   [2] Wood Road                                      │
│    [Yellow]   [3] Brick Road                                    │
│    [Yellow]   [4] Stone Road                                    │
│    [Yellow]   [5] Hill                                          │
│    [Yellow]   [6] Ditch                                         │
│                                                                   │
│  Player Actions:                                                │
│    ✓ WASD movement: Works normally                              │
│    ✓ Combat: Possible (if enemy nearby)                         │
│    ✓ Item pickup: Works                                         │
│    ✗ Other tools: Blocked (deactivate first with ESC)           │
│                                                                   │
│  Toolbelt State: UNCHANGED                                      │
│    - UI still visible                                           │
│    - Selection still on "Dirt Road"                             │
│    - Mode still active: landscaping                             │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌─ PLAYER PRESSES DOWN ARROW KEY (↓) ──────────────────────────────┐
│                                                                   │
│  Event: Player presses DOWN arrow                               │
│  ↓                                                                │
│  Verb: mob/players/verb/Toolbelt_Select_Down()                  │
│  ↓                                                                │
│  Action: toolbelt.NavigateSelection(1)                          │
│                                                                   │
│  Processing:                                                     │
│    1. Current selection: 1 ("Dirt Road")                        │
│    2. New index: 1 + 1 = 2                                      │
│    3. Validate bounds: 2 <= 6 ✓ (within list)                   │
│    4. Update: selected_index = 2                                │
│    5. Refresh display: UpdateSelectionUI()                      │
│                                                                   │
│  Updated Selection UI:                                          │
│    [Yellow]   [1] Dirt Road                                     │
│    [Yellow] ► [2] Wood Road                    ← NEW HIGHLIGHT │
│    [Yellow]   [3] Brick Road                                    │
│    [Yellow]   [4] Stone Road                                    │
│    [Yellow]   [5] Hill                                          │
│    [Yellow]   [6] Ditch                                         │
│                                                                   │
│  Toolbelt State: UPDATED                                        │
│    - UI still visible                                           │
│    - Selection now on "Wood Road"                               │
│    - Mode still active: landscaping                             │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌─ PLAYER PRESSES DOWN ARROW AGAIN (↓) ───────────────────────────┐
│                                                                   │
│  Selection advances: 2 → 3 ("Brick Road")                       │
│                                                                   │
│  Updated Selection UI:                                          │
│    [Yellow]   [1] Dirt Road                                     │
│    [Yellow]   [2] Wood Road                                     │
│    [Yellow] ► [3] Brick Road                   ← NEW HIGHLIGHT │
│    [Yellow]   [4] Stone Road                                    │
│    [Yellow]   [5] Hill                                          │
│    [Yellow]   [6] Ditch                                         │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌─ PLAYER PRESSES E KEY (CONFIRM) ───────────────────────────────┐
│                                                                   │
│  Event: Player presses E                                        │
│  ↓                                                                │
│  Verb: mob/players/verb/Toolbelt_Confirm()                      │
│  ↓                                                                │
│  Action: toolbelt.ConfirmSelection()                            │
│                                                                   │
│  Processing:                                                     │
│    1. Get current selection: options[3]                         │
│       → "Brick Road"                                            │
│    2. Call ExecuteModeAction("landscaping", "Brick Road")       │
│       ↓                                                           │
│       → CreateTerrainObject(player, "Brick Road")               │
│         └─ Permission check ✓ (deed system)                     │
│         └─ Rank check ✓ (digging rank required)                 │
│         └─ Resource check ✓ (materials available)               │
│         └─ Stamina check ✓ (stamina available)                  │
│         └─ Animation: Player digs, creates road                │
│         └─ XP awarded: +25 digging XP                           │
│         └─ Stamina deducted: -15 stamina                        │
│         └─ Resource removed: -6 stone                           │
│         └─ Object created: Brick Road at player location        │
│    3. Return status to player                                   │
│                                                                   │
│  Output to Player:                                               │
│    [Green] Successfully created Brick Road!                     │
│    [Green] +25 Digging XP                                       │
│    [Orange] Stamina: 85/100                                     │
│    [Orange] Stone: 14/20                                        │
│                                                                   │
│  World Changes:                                                  │
│    - New turf: Brick Road                                       │
│    - Player stamina updated                                     │
│    - Player XP updated                                          │
│    - Inventory resources reduced                                │
│                                                                   │
│  Toolbelt State: UNCHANGED                                      │
│    - UI still visible (ready for next action)                   │
│    - Selection reset to option 1 or previous                    │
│    - Mode still active: landscaping                             │
│                                                                   │
│  Player can now:                                                │
│    ✓ Select another terrain type                               │
│    ✓ Create another object at new location                     │
│    ✓ Move and build freely                                      │
│    ✓ Switch to different tool (press 2-9)                      │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌─ PLAYER PRESSES KEY "2" (DIFFERENT TOOL) ──────────────────────┐
│                                                                   │
│  Previous Tool (Shovel):                                        │
│    - Mode: landscaping                                          │
│    - UI: Hidden                                                  │
│    - Flag: player.SHequipped = 0                                │
│                                                                   │
│  New Tool (Hammer at Slot 2):                                   │
│    - ActivateTool(2) called                                     │
│    - Mode: smithing                                             │
│    - Flag: player.HMequipped = 1                                │
│    - New UI shown:                                              │
│      [Yellow] ► [1] Iron Axe                                    │
│      [Yellow]   [2] Iron Sword                                  │
│      [Yellow]   [3] Steel Hammer                                │
│      [Yellow]   [4] Copper Ingot                                │
│                                                                   │
│  Output:                                                         │
│    [Cyan] Equipped Hammer (smithing mode active)               │
│    [Cyan] --- SMITHING MODE ACTIVE ---                         │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘

┌─ PLAYER PRESSES ESC (DEACTIVATE TOOL) ──────────────────────────┐
│                                                                   │
│  Event: Player presses ESC (future implementation)              │
│  ↓                                                                │
│  Action: toolbelt.DeactivateTool()                              │
│                                                                   │
│  Processing:                                                     │
│    1. Hide selection UI                                         │
│    2. Deactivate mode: set flags to 0                           │
│    3. Clear active tool and mode                                │
│    4. Reset selection index                                     │
│                                                                   │
│  Output:                                                         │
│    [Orange] Tool deactivated                                    │
│                                                                   │
│  Toolbelt State: RESET                                          │
│    - UI hidden                                                  │
│    - Mode: none                                                 │
│    - All equipment flags: 0                                     │
│    - Can bind new tool to hotbar or press 1-9 again            │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

---

## Key Concepts

### Non-Blocking Gameplay
- Selection UI is **ALWAYS VISIBLE** while tool is active
- Player movement (WASD) is **NEVER BLOCKED** by UI
- Player can combat, pick up items, etc. while selecting
- Only action is selecting the tool type, then pressing E

### Immediate Execution
- **No confirmation dialog**: "Are you sure?"
- **No menu navigation**: Just select and execute
- **Direct gameplay**: Selection → E-key → Action happens
- **Visual feedback**: Stamina/XP/resources update immediately

### Tool-Dictated Actions
```
Tool Equipped → Mode Activated → Options Displayed
                                    ↓
                            Player Selects One
                                    ↓
                            Player Presses E
                                    ↓
                            Action Executes
                            (Minigame or Result)
```

---

## Implementation Status

### Complete ✅
- Hotbar datum (9 slots)
- Tool mode mapping
- Selection navigation (arrow keys)
- Action execution routing
- Hotkey macros (1-9)
- Integration with Basics.dm

### TODO (Next)
- Visual UI rendering
- Hotbar item binding (inventory UI)
- Shovel terrain creation
- Minigame integration
- Stamina/XP deduction

