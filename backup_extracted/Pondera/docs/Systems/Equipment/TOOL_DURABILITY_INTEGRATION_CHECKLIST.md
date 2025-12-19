# Tool Durability Integration Checklist

**Status**: System implementation complete, integration phase beginning

## Phase 1: ✅ System Implementation Complete
- [x] Create `/datum/tool_durability` with universal tool support
- [x] Implement all tool type detection (pickaxe variants, hammers, axes)
- [x] Add HUD notification system (wear/break messages)
- [x] Create E-key verb integration layer
- [x] Verify zero compilation errors in new files
- [x] Remove deprecated ore selection UI from .dme
- [x] Document system architecture and usage

## Phase 2: Hotbelt System Integration (Next Steps)

### Step 1: Verify ToolbeltHotbarSystem.dm
- [ ] Check if `OnEquipToolFromHotbelt()` calls exist
- [ ] Locate where tools are equipped in hotbelt slot system
- [ ] Find hotbelt slot activation proc (likely something like `/toolbelt_activate_slot_1`)
- [ ] Identify how equipped items are tracked

### Step 2: Add Hotbelt Hook
In ToolbeltHotbarSystem.dm, find the slot activation code and add:
```dm
// After item is successfully equipped from hotbelt:
if(istype(M))
    M.OnEquipToolFromHotbelt(equipped_item)
```

### Step 3: Test Hotbelt Integration
- [ ] Equip pickaxe in hotbelt
- [ ] Verify tool_durability datum initializes
- [ ] Check console for equip message
- [ ] Verify currently_equipped_tool is set

## Phase 3: Mining.dm Integration (Required for Gameplay)

### Step 1: Locate Mining Entry Point
- [ ] Find Mining.dm file
- [ ] Locate Mine() proc or ore collection proc
- [ ] Identify where ore is actually collected

### Step 2: Add Durability Check
Before ore collection, add:
```dm
proc/Mine(mob/M, obj/ore)
    // Verify tool still usable
    if(!M.tool_durability || M.tool_durability.IsBroken())
        M << "<red>Your tool is broken!</red>"
        return FALSE
    
    // Proceed with mining (durability already reduced by use_tool() verb)
    // ... existing ore collection code ...
```

### Step 3: Test Mining Integration
- [ ] Equip Ueik Pickaxe
- [ ] Press E on ore 6 times
- [ ] Verify durability message after ~5th swing
- [ ] Verify mining blocked after 6th swing
- [ ] Test with Iron/Steel pickaxes (different durability)

## Phase 4: Keybinding Setup (UI Integration)

### Step 1: Add E-Key Macro
In Interface.dmf or macro system, add:
```
E = /use_tool
```

### Step 2: Verify Macro Context
- [ ] E-key only fires in-game (not in menus)
- [ ] E-key doesn't conflict with other bindings
- [ ] Consider if E also used for other interactions (dialogue, etc.)

### Step 3: Test Keybinding
- [ ] Press E with tool equipped
- [ ] Press E with no tool equipped
- [ ] Press E with broken tool equipped

## Phase 5: Content Integration (Tool Items)

### Step 1: Verify Pickaxe Items Exist
- [ ] Check `/obj/Rocks/` or similar for Ueik Pickaxe definition
- [ ] Verify item names match detection patterns:
  - "Ueik Pickaxe" or "ueik_pickaxe"
  - "Iron Pickaxe" or "iron_pickaxe"
  - "Steel Pickaxe" or "steel_pickaxe"

### Step 2: Create Missing Tool Items (if needed)
If items don't exist, create in tools.dm or appropriate file:
```dm
/obj/items/tools/Ueik_Pickaxe
    name = "Ueik Pickaxe"
    desc = "A fragile pickaxe made from Ueik stone"
    icon = 'path/to/icon.dmi'
    icon_state = "ueik_pickaxe"
```

### Step 3: Add Tools to Crafting/Recipes
- [ ] Add Ueik Pickaxe to starter items or quests
- [ ] Make sure Iron/Steel variants are craftable via smithing
- [ ] Set appropriate recipes/unlock levels

## Phase 6: Balance & Feedback (Final Polish)

### Step 1: Test Durability Progression
- [ ] Ueik (6 uses) feels right for difficulty
- [ ] Iron (30 uses) feels like substantial upgrade
- [ ] Steel (75 uses) feels like late-game tool
- [ ] Wear message helpful but not annoying

### Step 2: Adjust Values (if needed)
If durability feels wrong, update in `/datum/tool_durability/New()`:
```dm
if("ueik_pickaxe")
    max_durability = 50    // Adjust this value
    durability_loss_per_use = 8  // Or this one
```

### Step 3: Test Break Message
- [ ] Message appears at correct time
- [ ] Player can see tool is unusable after break
- [ ] Clear feedback to equip new tool

## Integration Order (Recommended)

1. **Hotbelt Integration** first (enables equipping)
2. **Keybinding Setup** second (enables tool use)
3. **Mining Integration** third (enables actual mining with durability)
4. **Content Setup** fourth (ensures tools exist for testing)
5. **Balance Testing** fifth (fine-tune values based on gameplay feel)

## Quick Reference: System API

### Equip Tool (called from hotbelt system)
```dm
M.OnEquipToolFromHotbelt(tool_object)
```

### Use Tool (triggered by E-key)
```dm
M.use_tool()  // verb - automatically called by keybinding
// Or directly:
var/success = M.AttemptToolUse()
```

### Check Tool Status
```dm
M.tool_durability.current_durability          // Current HP
M.tool_durability.max_durability              // Max HP
M.tool_durability.GetDurabilityPercent()      // 0-100%
M.tool_durability.IsBroken()                  // TRUE if unusable
M.tool_durability.IsFragile()                 // TRUE if <20%
```

### Manually Set Durability (for testing)
```dm
M.tool_durability.current_durability = 10  // Set to 10
```

### Testing Command
For admin testing, could add verb:
```dm
verb/test_tool_break()
    set hidden = 1
    if(tool_durability)
        tool_durability.current_durability = 1
        src << "Tool durability set to 1"
```

---

**Estimated Remaining Work**: 2-4 hours
- Hotbelt integration: 30 mins
- Keybinding setup: 15 mins
- Mining integration: 45 mins
- Content verification: 30 mins
- Testing & balancing: 1 hour
- Unexpected integration issues: 30 mins buffer

**Build Status**: Ready (0 errors in tool system, 86 pre-existing)

**Next Action**: Review ToolbeltHotbarSystem.dm to identify hotbelt equip hook point
