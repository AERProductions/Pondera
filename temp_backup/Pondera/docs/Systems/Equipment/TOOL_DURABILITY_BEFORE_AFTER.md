# Tool Durability Consolidation: Before & After

## The Problem

We had created **3 separate files** just to add durability tracking to tools:
- `PickaxeMiningSystem.dm` (154 lines)
- `PickaxeModeIntegration.dm` (110 lines)  
- `PickaxeOreSelectionUI.dm` (deprecated stub)

But Pondera already had a **CentralizedEquipmentSystem.dm** that manages all equipped items.

## The Solution

Moved all durability logic **into the existing equipment system** → One unified place for all item-related mechanics.

---

## Before: Standalone Durability System

### File Structure
```
dm/
  ├─ PickaxeMiningSystem.dm
  ├─ PickaxeModeIntegration.dm
  ├─ PickaxeOreSelectionUI.dm (deprecated)
  └─ CentralizedEquipmentSystem.dm (unchanged)

Pondera.dme includes:
  #include "PickaxeMiningSystem.dm"
  #include "PickaxeModeIntegration.dm"
  #include "PickaxeOreSelectionUI.dm"
```

### Usage Flow
```
Equipment System      Durability System       Integration System
(separate)           (separate)              (separate)
    ↓                     ↓                      ↓
EquipItem()    →    InitializeToolDurability()  →  AttemptToolUse()
```

### API
```dm
// Durability datum
var/datum/tool_durability/tool_durability

// Equip via tool-specific handler
proc/OnEquipToolFromHotbelt(tool)

// Use via separate verb
verb/use_tool()
```

---

## After: Unified Equipment System

### File Structure
```
dm/
  ├─ CentralizedEquipmentSystem.dm (now includes durability)
  └─ PickaxeOreSelectionUI.dm (deprecated stub only)

Pondera.dme includes:
  #include "CentralizedEquipmentSystem.dm"
  (no separate durability files)
```

### Usage Flow
```
                  Unified Equipment System
                  (tools + durability)
                         ↓
            EquipItem() → initialize durability
            AttemptUse() → reduce durability
            IsBroken() → check durability
```

### API
```dm
// Durability variables on equipment item
var/current_durability = 50
var/max_durability = 50
var/durability_loss_per_use = 8

// Equip via standard equipment handler
proc/EquipItem(item)

// Use via standard equipment utility
proc/AttemptUseMainHandTool()
```

---

## Code Comparison

### Equipment Definition (Pickaxe)

**Before** (across 2 systems):
```dm
// In CentralizedEquipmentSystem.dm:
obj/items/equipment/tool/Pickaxe
    name = "Pickaxe"
    damage_min = 5
    damage_max = 10
    on_use_proc = "UseMiningTool"

// In PickaxeMiningSystem.dm:
/datum/tool_durability/New("ueik_pickaxe")
    display_name = "Ueik Pickaxe"
    max_durability = 50
    durability_loss_per_use = 8
```

**After** (single location):
```dm
// In CentralizedEquipmentSystem.dm:
obj/items/equipment/tool/Pickaxe
    name = "Pickaxe"
    damage_min = 5
    damage_max = 10
    max_durability = 50
    durability_loss_per_use = 8
    on_use_proc = "UseMiningTool"
```

### Tool Usage

**Before**:
```dm
// In PickaxeModeIntegration.dm:
verb/use_tool()
    if(!currently_equipped_tool) return
    if(!tool_durability) return
    var/success = tool_durability.UseTool()
    if(!success)
        src << "<red>Tool broken!</red>"
```

**After**:
```dm
// In CentralizedEquipmentSystem.dm:
proc/AttemptUseMainHandTool()
    var/obj/items/equipment/tool = equipment_slots[EQUIP_SLOT_MAIN_HAND]
    if(!tool.AttemptUse())
        src << "<red>Tool broken!</red>"
        return FALSE
    return TRUE
```

### Checking Durability

**Before** (separate datum):
```dm
// Requires separate datum tracking
if(tool_durability && tool_durability.IsFragile())
    src << "Tool fragile!"
```

**After** (on equipment):
```dm
// Equipment has durability directly
var/tool = equipment_slots[EQUIP_SLOT_MAIN_HAND]
if(tool && tool.IsFragile())
    src << "Tool fragile!"
```

---

## Benefits Summary

| Aspect | Before | After |
|--------|--------|-------|
| **Files** | 3 separate systems | 1 unified system |
| **Line Count** | ~400 lines across 3 files | ~100 lines in 1 file |
| **Integration Points** | Multiple hooks needed | Already integrated |
| **Maintenance** | Update equipment AND durability separately | Update durability with equipment |
| **Scalability** | Add new tool type in 2 places | Add new tool type in 1 place |
| **Player Data** | Durability saved separately | Durability travels with equipment |
| **API Complexity** | Mix of datums and procs | Simple equipment properties |
| **Code Clarity** | Scattered across files | Concentrated in equipment definitions |

---

## Migration Impact

### For Existing Code

If your code used the old standalone system:
```dm
// OLD (no longer works):
M.tool_durability.UseTool()
M.InitializeToolDurability(tool)

// NEW (use equipment directly):
var/tool = M.equipment_slots[EQUIP_SLOT_MAIN_HAND]
tool.AttemptUse()
```

### For Mining Integration

**Old approach** (separate E-key system):
```dm
// Would need hooks in PickaxeModeIntegration
```

**New approach** (standard equipment):
```dm
// In mining.dm Mine() proc:
if(!M.AttemptUseMainHandTool())
    M << "Tool broken!"
    return
// Proceed with ore collection
```

### For New Tools

**Old approach**:
1. Create tool in CentralizedEquipmentSystem
2. Add durability case in PickaxeMiningSystem
3. Add detection in PickaxeModeIntegration

**New approach**:
1. Create tool in CentralizedEquipmentSystem with durability values
2. Done!

---

## What Stays The Same

✅ **Equipment slots** - Still work the same (`equipment_slots[EQUIP_SLOT_MAIN_HAND]`)
✅ **Equip/Unequip** - Same procs, now with durability init
✅ **Stat bonuses** - Weapons still add damage/defense
✅ **Player data** - Equipment still persists with character
✅ **Durability behavior** - Same progression (wear at 20%, break at 0)

---

## Summary

**Consolidation Result**: Tool durability went from being a **separate parallel system** to being a **first-class feature of equipment management**.

This is cleaner, more maintainable, and follows the principle: *"Use existing systems rather than building parallel ones"*

**Next Step**: Integrate with mining.dm by calling `M.AttemptUseMainHandTool()` before ore collection.
