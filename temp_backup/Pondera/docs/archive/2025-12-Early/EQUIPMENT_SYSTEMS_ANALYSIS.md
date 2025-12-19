# Equipment Rendering Systems Analysis - December 13, 2025

## THREE SYSTEMS COMPARISON

### 1. **EquipmentOverlaySystem.dm** (307 lines)
**Status**: Foundation tier / Asset-dependent  
**Maturity**: Planning stage  
**Architecture**: Datum-based overlay definitions

#### Design:
```dm
/obj/equipment_overlay
    var/equipment_name = ""
    var/dmi_file = ""
    var/icon_state_base = ""
    var/has_animations = 0

/obj/equipment_overlay/weapon/longsword
    dmi_file = 'dmi/64/LSoy.dmi'
    icon_state_base = "LS"
```

#### Strengths:
✅ Clean datum architecture for extensibility  
✅ Supports animations/action states  
✅ Directional rendering (8 directions)  
✅ Per-equipment rarity/type metadata  
✅ Comprehensive documentation

#### Weaknesses:
❌ **Requires custom DMI files** (LSoy.dmi, WHoy.dmi, etc.) - NOT YET CREATED  
❌ Blocked by asset pipeline  
❌ Disabled in .dme (commented out)  
❌ No runtime fallback system  
❌ No active integration into tools.dm

#### Current Integration:
```dm
// In Pondera.dme
//#include "dm\EquipmentOverlaySystem.dm"  // <-- COMMENTED OUT
```

---

### 2. **EquipmentOverlayIntegration.dm** (140 lines)
**Status**: Integration bridge / Asset-dependent  
**Maturity**: Awaiting DMI creation  
**Architecture**: Helper functions + commented instructions

#### Design:
```dm
mob/proc/apply_equipment_overlay(obj/items/tools/item)
    // Map typi codes to overlay properties
    if(item.typi == "LS")
        icon_state_base = "LS"
        dmi_file = 'dmi/64/LSoy.dmi'
    // ...apply overlay
```

#### Strengths:
✅ Clear integration instructions (5-step plan)  
✅ Typi code mapping (mirrors tools.dm system)  
✅ Works with existing inventory system  
✅ Explains where to hook tools.dm

#### Weaknesses:
❌ **Entirely commented out** - includes only instructions, not runnable code  
❌ Blocked by same DMI asset requirement  
❌ No failover if DMI missing  
❌ Tightly coupled to tools.dm "typi" codes

#### Current Integration:
```dm
// In Pondera.dme
//#include "dm\EquipmentOverlayIntegration.dm"  // <-- COMMENTED OUT
// Includes 5 steps of manual integration instructions
```

---

### 3. **EquipmentVisualizationWorkaround.dm** (158 lines)  **RECOMMENDED**
**Status**: Active / Working today  
**Maturity**: Production-ready  
**Architecture**: Lightweight procedural system

#### Design:
```dm
/proc/GetEquipmentVisual(item_type)
    // Returns list[icon_state, scale, offset_x, offset_y]
    switch(item_type)
        if(/obj/items/tools)
            return list("item", 1.0, 0, 1)

/proc/CreateEquipmentOverlay(mob/M, obj/item, direction)
    // Create image from existing item.icon
    var/image/overlay = image(item.icon, M, icon_state)
```

#### Strengths:
✅ **Zero asset dependencies** - uses existing item icons  
✅ **Works immediately** - can activate today  
✅ **Lightweight** - 158 lines of lean code  
✅ Clean proc-based API  
✅ Fallback-safe (uses item.icon || generic 'dmi/objects.dmi')  
✅ Recently verified to compile cleanly

#### Weaknesses:
⚠️ No directional variations (same overlay in all directions)  
⚠️ No animation support  
⚠️ Basic positioning (pixel_x/y only, no rotation)  
⚠️ Generic scaling (one size fits all categories)

#### Current Integration:
```dm
// In Pondera.dme
#include "dm\EquipmentVisualizationWorkaround.dm"  // <-- ACTIVE

// Usage in tools.dm (when you call equip/unequip):
player.VisualizeEquippedItem(weapon, "hand")
player.RemoveEquipmentVisualization("hand")
```

---

## DECISION MATRIX

| Aspect | OverlaySystem | OverlayIntegration | Workaround |
|--------|---|---|---|
| **Status** | Commented out | Commented out | **ACTIVE** ✅ |
| **Works Today?** | ❌ No | ❌ No | ✅ Yes |
| **Asset Dependencies** | ❌ Heavy (8+ DMI files) | ❌ Heavy (8+ DMI files) | ✅ None |
| **Animation Support** | ✅ Yes | ⚠️ Partial | ❌ No |
| **Directional Rendering** | ✅ 8-direction | ⚠️ Partial | ❌ Single |
| **Lines of Code** | 307 | 140 | 158 |
| **Integration Effort** | ⚠️ High (manual DMI creation) | ⚠️ High (manual DMI creation) | ✅ Low (already integrated) |
| **Architecture Quality** | ✅ Excellent (extensible) | ⚠️ Good (bridge) | ✅ Good (practical) |
| **Recommended for Phase?** | Phase 7+ (Asset pipeline) | Phase 7+ (Asset pipeline) | **Phase 5-6 (Now)** |

---

## RECOMMENDATION: USE WORKAROUND NOW

### Immediate (Phase 5-6):
**Activate**: EquipmentVisualizationWorkaround.dm  
- Provides working equipment visualization TODAY
- Zero blocking dependencies
- Clean API ready for tools.dm integration

### Medium-term (Phase 7):
**Parallel development**:
- Create custom weapon DMI files (LSoy.dmi, WHoy.dmi, etc.)
- When assets ready, enable EquipmentOverlaySystem.dm
- Workaround can remain as fallback layer

### Long-term (Phase 8+):
**Deprecate workaround** once OverlaySystem is fully active with all custom DMI assets

---

## INTEGRATION CHECKLIST FOR WORKAROUND

### Currently Integrated:
- ✅ EquipmentVisualizationWorkaround.dm included in .dme
- ✅ System compiles cleanly (0 errors)
- ✅ Procs available for calling

### TODO: Hook into tools.dm
1. Find tools.dm Equip() verb (~line 240-260)
   ```dm
   src.suffix = "Equipped"
   // ADD: usr.VisualizeEquippedItem(src, "hand")
   ```

2. Find tools.dm Unequip() verb (~line 1670-1750)
   ```dm
   src.suffix = ""
   // ADD: usr.RemoveEquipmentVisualization("hand")
   ```

3. Test equip/unequip in-game

---

## FUTURE MIGRATION PATH

When custom weapon DMI files are available:

```dm
// Step 1: Uncomment both systems in .dme
#include "dm\EquipmentOverlaySystem.dm"
#include "dm\EquipmentOverlayIntegration.dm"

// Step 2: Update tools.dm to call new system
src.suffix = "Equipped"
usr.apply_equipment_overlay(src)  // NEW call

// Step 3: Phase out workaround
//#include "dm\EquipmentVisualizationWorkaround.dm"  // Comment out
```

---

## ARCHITECTURE COMPARISON DIAGRAM

```
CURRENT ARCHITECTURE
====================

Workaround (ACTIVE)
    │
    ├─ GetEquipmentVisual()
    ├─ CreateEquipmentOverlay()
    └─ /mob/proc/VisualizeEquippedItem()
           │
           └─ [Ready to hook into tools.dm]


FUTURE ARCHITECTURE
===================

OverlaySystem (PLANNED)
    │
    ├─ /obj/equipment_overlay (datum definitions)
    │
    └─ apply_equipment_overlay() (in EquipmentIntegration)
           │
           └─ [Requires LSoy.dmi, WHoy.dmi, etc.]

Workaround (FALLBACK)
    │
    └─ Used if OverlaySystem assets unavailable
```

---

## CONCLUSION

**The Workaround is architecturally superior FOR THIS PHASE** because:
1. ✅ Zero blockers - works immediately
2. ✅ Clean, maintainable code
3. ✅ Follows "practical over perfect" principle
4. ✅ Provides clear fallback path
5. ✅ Doesn't prevent future asset-heavy system

**Future migration is straightforward** - switch hooks from Workaround to OverlaySystem when DMI assets ready.
