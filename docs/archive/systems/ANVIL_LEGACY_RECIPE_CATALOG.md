# Anvil Legacy Recipe Catalog

## Overview
The original Pondera anvil system was much more sophisticated than a simple building piece. It served as:
1. **Crafting recipes** via the Smithing() function (accessed from File and other containers)
2. **Building recipes** for constructing anvils themselves
3. **Tool refinement** via the File tool and various refinement/sharpening mechanics

This document catalogs all legacy anvil-related recipes for future implementation.

---

## Part 1: Building an Anvil (From jblegacyexample.dm, lines 1950-1966)

### Anvil Construction Recipe
**Location**: Building menu (Furnishings > Anvil)
**Requirements**:
- **Materials**:
  - 1x Anvil Head (smelted from metal)
  - 2x Ueik Log (harvested wood)
  - 5x Mortar (building material)
- **Energy Cost**: 45 (stamina/energy)
- **Rewards**:
  - +15 Building Experience (buildexp)
  - Anvil building placed in world
  - Ownership tagged to player who built it

**Building Details**:
- Player selects direction (North/South/East/West)
- Anvil object created at player location with selected orientation
- `buildingowner` set to player's ckey
- Layer set to `MOB_LAYER+1` for proper visual ordering

**Code Context**:
```dm
// Legacy building code pattern
var/obj/items/Mortar/J = locate() in M.contents              // 5 Mortar
var/obj/items/Crafting/Created/AnvilHead/J2 = locate()       // 1 Anvil Head
var/obj/items/Logs/UeikLog/J3 = locate() in M.contents       // 2 Ueik Log

if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&
   (J.stack_amount >= 5)&&(J2.stack_amount >= 1)&&(J3.stack_amount >= 2)&&
   (M.energy >= 45))
    // Remove materials, consume energy, create anvil
```

---

## Part 2: Anvil Head Smelting

The Anvil Head is a **smelted metal component** (not found; must be created).

### Anvil Head Recipe (Inferred from Legacy)
**Type**: Smelting recipe (created at Forge via Smithing function)
**Inputs**: Likely metal ore (iron/copper/bronze/brass/steel)
**Output**: 1x Anvil Head (crafted item)
**Process**: 
- Smelt raw ore at forge
- Create Anvil Head component
- Store in inventory for later use in anvil building

**Item Type**: `/obj/items/Crafting/Created/AnvilHead`
- Stackable (has `stack_amount` property)
- Part of crafting/created items hierarchy

---

## Part 3: Tool Component Refinement & Sharpening

The legacy File tool was used to refine and test tool components via the Smithing() function.

### Tool Components that Could Be Refined at Anvil:
**From toolslegacyexample.dm, lines 3735-3902**

#### Tool Parts (11 types):
1. **Hammer Head** - `/obj/items/Crafting/Created/HammerHead`
2. **Carving Knife Blade** - `/obj/items/Crafting/Created/CKnifeblade`
3. **File Blade** - `/obj/items/Crafting/Created/FileBlade`
4. **Axe Blade** - `/obj/items/Crafting/Created/AxeHead`
5. **Pickaxe Head** - `/obj/items/Crafting/Created/PickaxeHead`
6. **Shovel Blade** - `/obj/items/Crafting/Created/ShovelHead`
7. **Hoe Blade** - `/obj/items/Crafting/Created/HoeBlade`
8. **Saw Blade** - `/obj/items/Crafting/Created/SawBlade`
9. **Sickle Blade** - `/obj/items/Crafting/Created/SickleBlade`
10. **Chisel Blade** - `/obj/items/Crafting/Created/ChiselBlade`
11. **Trowel Blade** - `/obj/items/Crafting/Created/TrowelBlade`

#### Weapon Parts (10 types):
1. **Broad Sword Blade** - `/obj/items/Crafting/Created/Broadswordblade`
2. **War Sword Blade** - `/obj/items/Crafting/Created/Warswordblade`
3. **Battle Sword Blade** - `/obj/items/Crafting/Created/Battleswordblade`
4. **Long Sword Blade** - `/obj/items/Crafting/Created/Longswordblade`
5. **War Maul Head** - `/obj/items/Crafting/Created/Warmaulhead`
6. **Battle Hammer Sledge** - `/obj/items/Crafting/Created/Battlehammersledge`
7. **War Axe Blade** - `/obj/items/Crafting/Created/Waraxeblade`
8. **Battle Axe Blade** - `/obj/items/Crafting/Created/Battleaxeblade`
9. **War Scythe Blade** - `/obj/items/Crafting/Created/Warscytheblade`
10. **Battle Scythe Blade** - `/obj/items/Crafting/Created/Battlescytheblade`

#### Lamp Parts (5 types):
1. **Iron Lamp Head** - `/obj/items/Crafting/Created/IronLampHead`
2. **Copper Lamp Head** - `/obj/items/Crafting/Created/CopperLampHead`
3. **Bronze Lamp Head** - `/obj/items/Crafting/Created/BronzeLampHead`
4. **Brass Lamp Head** - `/obj/items/Crafting/Created/BrassLampHead`
5. **Steel Lamp Head** - `/obj/items/Crafting/Created/SteelLampHead`

### Refinement State System (Legacy)
**Refinement Level**: `Tname` property (in-game shorthand for "Thermal Name" or state)
- **"Unrefined"** - Freshly forged, needs tempering
- **"Filed"** - Filed smooth for durability
- **"Sharpened"** - Edge sharpened for cutting/striking
- **"Polished"** - Final finishing for quality/aesthetics
- **"Cool"** - Quenched to final state (ready for tool assembly)

**Refinement Process**:
1. Smith smelts raw ore at forge → creates unrefined blade/head
2. Smith takes blade to **File tool** or **Anvil** for refinement
3. Progressive refinement stages tracked via Smithing() function
4. Final quench in **water/tar/oil** vessels or **QuenchBox** to reach "Cool" state
5. Once cool, blade ready for assembly into final tool/weapon

**Quenching Mechanics** (from Barrel and QuenchBox):
- **Water Quench**: Basic cooling (most common)
- **Tar Quench**: Different properties for specific metals
- **Oil Quench**: Alternative cooling medium
- **Sand Quench**: Not for cooling, used for other purposes

---

## Part 4: Legacy Smithing Flow

```
Raw Ore (at Forge)
    ↓
Smelt → Ore refined to metal ingot → Metal at forging temperature
    ↓
Forge → Heat metal ingot → Create unrefined component (HammerHead, Blade, etc.)
    ↓
File or Anvil → File/refine the component
    → Multiple strikes to shape and refine
    → Component state: "Unrefined" → "Filed" → "Sharpened"
    ↓
QuenchBox/Vessel → Cool in water/tar/oil
    → Component state: Hot → "Cool"
    ↓
Assembly at Workbench → Combine component + handle + binding
    → Final tool/weapon created (e.g., Iron Hammer, Broad Sword)
```

---

## Part 5: Anvil Skills Integration (Inferred)

### Smithing Rank System (Future)
Based on the legacy code structure and modern systems:
- **Smithing Rank**: RANK_SMITHING ("smirank")
- **Max Level**: 5
- **Unlock via**: 
  - Direct experimentation at Anvil with different metal combinations
  - Discovery of refinement recipes through trial at File/Anvil workstations
  
### Experience Gains (Legacy):
- **Building anvil**: +15 buildexp
- **Tool assembly**: Crafting exp (varies by tool)
- **Refinement processes**: Likely smithing exp per successful stage

---

## Part 6: Modern Integration Opportunities

### Current System (Phase C.2b)
The modern ExperimentationWorkstations.dm implements:
- **Cauldron** (cooking experimentation)
- **Forge** (smelting/metal work)
- **Anvil** (smithing refinement) ← **THIS IS THE ANVIL**
- **Workbench** (crafting/tool assembly)

### Recommended Recipe Registry Entries (for future):

```dm
// In RecipeExperimentationSystem.dm or RECIPES registry:

RECIPES["hammer_head"] = [
    "type" = /obj/items/Crafting/Created/HammerHead,
    "inputs" = list("metal_ingot" = 2, "flux" = 1),
    "output" = 1,
    "skill_requirement" = RANK_SMITHING,
    "skill_level_min" = 1,
    "workstation_type" = "forge",
    "heat_requirement" = "hot",
    "quality_modifier" = 0.1
]

RECIPES["refine_hammer_head"] = [
    "type" = /obj/items/Crafting/Created/HammerHead,
    "inputs" = list("hammer_head" = 1, "water" = 1),
    "output" = 1,
    "skill_requirement" = RANK_SMITHING,
    "skill_level_min" = 1,
    "workstation_type" = "smithing",  // Anvil workstation
    "refinement_stage" = "filed",      // Progression stage
    "quality_modifier" = 0.15
]

RECIPES["quench_hammer_head"] = [
    "type" = /obj/items/Crafting/Created/HammerHead,
    "inputs" = list("hammer_head" = 1, "water" = 1),
    "output" = 1,
    "skill_requirement" = RANK_SMITHING,
    "skill_level_min" = 1,
    "workstation_type" = "workbench",  // Or anvil?
    "refinement_stage" = "cool",
    "quality_modifier" = 0.2
]
```

---

## Part 7: File Tool Integration

The legacy **File** tool was the primary refinement interface, located in the toolslegacyexample.dm.

### File Tool Features:
- **Icon/Asset**: 'dmi/64/fire.dmi' (likely icon_state = "file")
- **Function**: Smithing() proc call (refined all components)
- **Mechanics**:
  - Player right-clicks File in inventory
  - Opens Smithing() menu with list of components to refine
  - Shows refinement state of each component
  - Allows progressive refinement through stages

### Integration Note:
The legacy File tool AND the Anvil both called the same `Smithing(M)` function, meaning both were refinement workstations. The modern approach uses:
- **Forge** for smelting (ore → ingots → unrefined components)
- **Anvil** for refinement (refining, sharpening, hardening)
- **File** tool as portable refinement (legacy, could be restored)

---

## Legacy Code References

**Primary Sources**:
- `jblegacyexample.dm`: Lines 1949-2024 (Anvil building, AnvilHead requirements)
- `toolslegacyexample.dm`: 
  - Lines 3735-3902 (Tool component catalog, File tool implementation)
  - Lines 5327-5399 (Refinement checking and processing)

**Objects Referenced**:
- `/obj/items/Crafting/Created/AnvilHead` - Anvil building component
- `/obj/items/Crafting/Created/HammerHead` - Tool part
- `/obj/items/Crafting/Created/*blade` - Weapon/tool parts (11 types)
- `/obj/items/Logs/UeikLog` - Building material
- `/obj/items/Mortar` - Building material
- `/obj/Buildable/Smithing/Anvil` - Anvil building object

---

## Summary

The legacy Anvil system was a sophisticated multi-stage crafting pipeline:

1. **Ore smelting** at Forge → raw components (unrefined)
2. **Refinement** at Anvil/File → progressive quality stages (filed → sharpened → polished)
3. **Quenching** in water/tar/oil vessels → final state (cool, ready to use)
4. **Assembly** at Workbench → combine refined parts into final tools/weapons
5. **Building** constructed Anvil with Anvil Head + logs + mortar

The modern experimentation system can be enhanced to support these multi-stage recipes, creating a deeper crafting progression where players discover refinement techniques through trial at the anvil.
