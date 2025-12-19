# Tool System Architecture & UI Integration

## Tool Categories

### 1. Gathering Tools (Simple Environment Interaction)
These tools allow players to interact with the environment to gain resources. They have no special UI menu - they simply activate an action on targeted objects.

**Tools in this category:**
- **Pickaxe** (`TOOL_TYPE_PICKAXE`) → mining
  - Action: Mine ore from rocks/cliffs
  - UI: Ore selection menu (which ore to mine)
  - Environment interaction: Direct interaction with rock objects
  
- **Axe** (`TOOL_TYPE_AXE`) → woodcutting
  - Action: Harvest logs from trees
  - UI: None (direct interaction)
  - Environment interaction: Click tree, get logs
  
- **Sickle** (`TOOL_TYPE_SICKLE`) → harvesting
  - Action: Harvest crops/vegetation
  - UI: None (direct interaction)
  - Environment interaction: Click plant, get harvest
  
- **Hoe** (`TOOL_TYPE_HOE`) → farming
  - Action: Till soil for farming
  - UI: None (direct interaction)
  - Environment interaction: Click turf, till soil
  
- **Fishing Pole** (`TOOL_TYPE_FISHING_POLE`) → fishing
  - Action: Fish from water
  - UI: **SPECIAL** - Has fishing minigame UI
  - Environment interaction: Click water, start fishing minigame

---

### 2. Interactive Tools with Context-Dependent UIs
These tools have gameplay mode UIs that change based on context (location, nearby objects).

**Shovel** (`TOOL_TYPE_SHOVEL`) → landscaping
- **Mode**: Landscaping/Terrain Modification
- **UI**: Landscaping UI (TerrainObjectsRegistry.dm)
  - Menu options: Dig, Create border, Create ditch, Create hill, etc.
  - Rank-gated: Different options unlock at different ranks
  - Deed-restricted: Cannot build in restricted zones
- **Status**: ✅ Already implemented (LandscapingSystem.dm)
- **Context Triggers**: Always active when shovel equipped

**Hammer** (`TOOL_TYPE_HAMMER`) → context-dependent
- **Primary Mode 1**: Building/Construction
  - **UI**: Building UI (similar to LandscapingSystem.dm)
  - Menu options: Build wall, build door, build foundation, etc.
  - Rank-gated: Different structures at different building ranks
  - Deed-restricted: Cannot build in restricted zones
  - **Status**: ⚠️ Needs implementation
  - **Context**: In the open (not near anvil)
  
- **Primary Mode 2**: Anvil Crafting/Smithing
  - **UI**: Anvil Crafting UI (metalworking menu)
  - Menu options: Repair items, forge new items, combine items
  - Rank-gated: Smithing rank determines available recipes
  - **Status**: ⚠️ Needs implementation (separate from SmithingMenuSystem.dm)
  - **Context**: When standing in front of an anvil object
  - **Integration Point**: Detect anvil proximity, switch UIs

---

### 3. Crafting Tools (Standalone Crafting UI)
These tools have dedicated crafting interfaces that activate when equipped. They don't depend on environment objects.

**Carving Knife** (`TOOL_TYPE_CARVING_KNIFE`) → carving
- **UI**: Carving Menu (CarvingKnifeSystem.dm) ✅ Already implemented
  - Menu: Carve kindling, carve details, etc.
  - Output: Kindling, crafted details
  - Durability: Reduced per carving action
  - Status: ✅ Fully implemented

**Chisel** (`TOOL_TYPE_CHISEL`) → stonecarving
- **UI**: Stone Carving Menu (needs implementation)
  - Pairs with Hammer (dual-wield: Hammer + Chisel)
  - Menu: Carve stone, create stone blocks, etc.
  - Requires both hammer and chisel equipped
  - Output: Stone blocks, carved details
  - Rank-gated: Carving rank determines options
  - Status: ⚠️ Needs implementation

**Flint** (`TOOL_TYPE_FLINT`) → firestarting
- **UI**: Fire Starting Menu (needs implementation)
  - Pairs with Pyrite (dual-wield: Flint + Pyrite)
  - Menu: Start fire, create tinder bundle, etc.
  - Requires both flint and pyrite equipped
  - Output: Fire, tinder bundles
  - Status: ⚠️ Needs implementation

---

## UI System Architecture

### Landscaping UI Pattern (Reference Implementation)
**File**: `dm/LandscapingSystem.dm`
**Proc**: `ShowSelectionUI_Text(mode)` in ToolbeltHotbarSystem.dm

**Structure**:
```dm
proc/ShowLandscapingUI(mob/players/M)
    // Display available terrain objects based on rank
    var/list/available_objects = GetAvailableTerrainObjects(M)
    var/choice = input("What would you like to build?", "Landscaping") in available_objects
    
    if(!choice) return
    
    // Execute creation
    CreateTerrainObject(M, choice)
```

### Building UI Pattern (To be implemented)
**Analogous to Landscaping but for structures**

```dm
proc/ShowBuildingUI(mob/players/M)
    // Display available buildings based on rank
    var/list/available_buildings = GetAvailableBuildingObjects(M)
    var/choice = input("What would you like to build?", "Building") in available_buildings
    
    if(!choice) return
    
    CreateBuildingObject(M, choice)
```

### Anvil Crafting UI Pattern (To be implemented)
**File**: `dm/AnvilCraftingSystem.dm` (new)
**Analogous to SmithingMenuSystem.dm but contextual**

```dm
proc/ShowAnvilCraftingUI(mob/players/M)
    // Only show anvil crafting options if standing near anvil
    if(!IsNearAnvil(M)) return
    
    var/list/available_recipes = GetAnvilRecipes(M)
    var/choice = input("What would you like to craft at the anvil?", "Anvil") in available_recipes
    
    if(!choice) return
    
    ExecuteAnvilCraft(M, choice)
```

---

## Tool Activation Flow

### Simple Gathering Tool (e.g., Axe)
```
1. Player equips axe from hotbar
   → ActivateMode("woodcutting")
   → SetGatheringToolEquipped(M, TOOL_TYPE_AXE, 1)

2. Player targets tree and presses E
   → ExecuteAxeAction(M, target_tree)
   → Harvest logs directly (no UI)
```

### Context-Dependent Tool (Hammer)
```
1. Player equips hammer from hotbar
   → ActivateMode("smithing") [context-dependent]
   → SetGatheringToolEquipped(M, TOOL_TYPE_HAMMER, 1)

2. CONTEXT A: Player is in open area
   → ShowBuildingUI(M)
   → Menu: Build wall, build door, etc.
   → CreateBuildingObject(M, choice)

3. CONTEXT B: Player stands near anvil
   → ShowAnvilCraftingUI(M)  [replaces building UI]
   → Menu: Forge items, repair, combine
   → ExecuteAnvilCraft(M, choice)
```

### Crafting Tool (Carving Knife)
```
1. Player equips carving knife
   → ActivateMode("carving")
   → SetGatheringToolEquipped(M, TOOL_TYPE_CARVING_KNIFE, 1)

2. Player presses E (or menu key)
   → OpenCarvingMenu()  [in CarvingKnifeSystem.dm]
   → Menu: Carve kindling, carve details
   → ExecuteCarvingAction(M, choice)
```

---

## Implementation Roadmap

### Phase 1: ✅ Already Complete
- [x] Gathering tools: Pickaxe, Axe, Sickle, Hoe
- [x] Landscaping UI: Shovel with terrain modification
- [x] Crafting UI: Carving knife with wood carving

### Phase 2: 🚧 Needs Implementation
- [ ] **Building UI for Hammer** (context: not near anvil)
  - Create BuildingMenuSystem.dm (similar to SmithingMenuSystem.dm)
  - Define building objects in TerrainObjectsRegistry.dm
  - Integrate with ToolbeltHotbarSystem.dm ShowSelectionUI()
  
- [ ] **Anvil Crafting UI for Hammer** (context: near anvil)
  - Create AnvilCraftingSystem.dm
  - Detect anvil proximity in ToolbeltHotbarSystem.dm
  - Switch UI based on proximity
  - Define anvil recipes (metalworking)

- [ ] **Stone Carving UI for Chisel+Hammer**
  - Create StoneCarvingSystem.dm
  - Detect dual-wield: Hammer in main hand, Chisel in off-hand
  - Menu: Carve stone blocks, create details
  - Output: Stone blocks, carved details

- [ ] **Fire Starting for Flint+Pyrite**
  - Create FireStartingSystem.dm
  - Detect dual-wield: Flint + Pyrite
  - Menu: Start fire, create tinder
  - Output: Fire, tinder bundles

- [ ] **Fishing Minigame** (special case)
  - Enhance FishingSystem.dm with minigame UI
  - Interactive fishing mechanics
  - Output: Fish (quality based on skill + minigame performance)

### Phase 3: Polish & Integration
- [ ] Anvil object definition (anvil as environmental object)
- [ ] Deed system integration for building
- [ ] Rank progression system (building rank, stone carving rank, etc.)
- [ ] Stamina/durability system integration across all tools
- [ ] Hotbar context detection (which UI to show)

---

## Key Integration Points

### ToolbeltHotbarSystem.dm
**ShowSelectionUI(mode)** proc needs context detection:
```dm
proc/ShowSelectionUI(mode)
    var/mob/players/M = owner
    
    switch(mode)
        if("landscaping")
            ShowLandscapingUI(M)
        
        if("building")
            // CONTEXT DETECTION
            if(IsNearAnvil(M))
                ShowAnvilCraftingUI(M)
            else
                ShowBuildingUI(M)
        
        if("carving")
            OpenCarvingMenu()
        
        if("stonecarving")
            OpenStoneCarvingMenu()
        
        // ... etc for other modes
```

### Hotbar E-Key Binding
When player presses E with a tool equipped:
1. Detect tool mode (via ActivateMode)
2. If mode is "building" or "smithing":
   - Show context-dependent UI
3. If mode is "carving":
   - Show crafting menu
4. If mode is gathering (axe, pickaxe, etc.):
   - Execute gathering action on target

### Context Detection
Need functions to detect:
- **IsNearAnvil(M)**: Check if player is within anvil range
- **IsInBuildingZone(M)**: Check if player has building permission
- **IsInLandscapingZone(M)**: Check if player has landscaping permission

---

## File Dependencies & Creation Plan

### Existing Files (No Changes)
- `dm/LandscapingSystem.dm` - Terrain modification
- `dm/CarvingKnifeSystem.dm` - Wood carving
- `dm/SmithingMenuSystem.dm` - Smithing UI template
- `dm/ToolbeltHotbarSystem.dm` - Main hotbar system

### Files to Create
1. **BuildingMenuSystem.dm** (240 lines)
   - `DisplayBuildingMenu(M)` - Main entry point
   - `GetAvailableBuildings(M, rank)` - Filter buildings by rank
   - `DisplayBuildingCategoryMenu(M, category, rank)` - Show buildings in category
   - Uses TerrainObjectsRegistry.dm for building definitions

2. **AnvilCraftingSystem.dm** (200 lines)
   - `DisplayAnvilMenu(M)` - Main entry point
   - `IsNearAnvil(M)` - Proximity detection
   - `GetAnvilRecipes(M, rank)` - Filter recipes by rank
   - `ExecuteAnvilCraft(M, recipe)` - Craft item at anvil

3. **StoneCarvingSystem.dm** (150 lines)
   - `OpenStoneCarvingMenu(M)` - Main menu
   - `ExecuteStoneCarvingAction(M, type)` - Perform carving
   - Outputs: Stone blocks, carved details

4. **FireStartingSystem.dm** (100 lines)
   - `OpenFireStartingMenu(M)` - Main menu
   - `ExecuteFireStarting(M, type)` - Start fire/create tinder
   - Outputs: Fire object, tinder bundles

### Files to Modify
1. **ToolbeltHotbarSystem.dm**
   - `ShowSelectionUI(mode)` - Add context detection for hammer

2. **TerrainObjectsRegistry.dm**
   - Add building objects registry
   - Define which buildings require what rank/resources

3. **Pondera.dme**
   - Add includes for new system files

---

## Current Status Summary

| Tool | Gathering | UI Type | Status |
|------|-----------|---------|--------|
| Pickaxe | ✅ Simple | Ore selection | ✅ Done |
| Axe | ✅ Simple | None | ✅ Done |
| Sickle | ✅ Simple | None | ✅ Done |
| Hoe | ✅ Simple | None | ✅ Done |
| Fishing Pole | ✅ Gathering | Minigame | ⚠️ Partial |
| Shovel | Interactive | Landscaping | ✅ Done |
| Hammer | Interactive | Building/Anvil | 🚧 In Progress |
| Chisel | Crafting | Stone Carving | ⚠️ Needs UI |
| Carving Knife | Crafting | Wood Carving | ✅ Done |
| Flint | Crafting | Fire Starting | ⚠️ Needs UI |

---

## Notes

- **Dual-wield pairing**: Some tools work as pairs (Hammer+Chisel, Flint+Pyrite)
- **Context switching**: Hammer's UI changes based on proximity to anvil
- **Rank gating**: All UIs should respect player rank progression
- **Deed system**: Building tools must check deed permissions before showing menu
- **Durability**: Crafting tools reduce durability; track via CentralizedEquipmentSystem.dm
