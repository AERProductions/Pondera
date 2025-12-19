# Quick Testing Guide - Tool Durability Systems

## Tool Durability Values (CORRECTED)

### Iron Tools - 250-350 uses
- **Pickaxe**: 250 max durability, 1 loss per mining action
- **Hammer**: 400 max durability, 1 loss per smithing action
- **Carving Knife**: 300 max durability, 1 loss per carving action
- **Axe**: 300 max durability, 1 loss per woodcutting action
- **Hoe**: 300 max durability, 1 loss per gardening action
- **Sickle**: 300 max durability, 1 loss per harvesting action
- **Shovel**: 350 max durability, 1 loss per digging action

### Fire-Starting Tools - 100 uses each
- **Flint**: 100 max durability, 1 loss per spark strike
- **Pyrite**: 100 max durability, 1 loss per spark strike

### Steel Tools - 400-500 uses
- **Chisel**: 500 max durability, 1 loss per stone carving action
- **Trowel**: 400 max durability, 1 loss per construction action

---

## Testing Scenarios

### Test 1: Carving Knife Kindling Production ✅
**Objective**: Verify carving knife produces kindling

**Steps**:
1. Spawn carving knife: `var/obj/items/equipment/tool/CarvingKnife/K = new(mob)`
2. Equip to main_hand slot
3. Press E-key (or call OpenCarvingMenu() directly)
4. Select "Carve Kindling" (should be only option)
5. Check inventory for Kindling items (1-3 depending on rank)
6. Verify carving knife durability decreased by 1

**Expected**:
- ✅ Menu shows only "Carve Kindling"
- ✅ 1-3 Kindling items created (1 base + rank bonus, up to 3 on critical)
- ✅ Durability: 300 → 299
- ✅ Message: "You carefully carve the wood into kindling."

**Related Files**: CarvingKnifeSystem.dm, ToolbeltHotbarSystem.dm

---

### Test 2: Fire-Starting (Flint + Pyrite) ✅
**Objective**: Verify flint+pyrite create sparks only

**Steps**:
1. Spawn flint and pyrite
2. Equip flint to off-hand, pyrite to main-hand
3. Press E-key to trigger UseFlintAndPyrite()
4. Observe message
5. Check that NO Campfire object was created
6. Verify durability decreased for both tools

**Expected**:
- ✅ Message: "You strike flint and pyrite together... sparks fly!"
- ✅ 70% success rate (30% fail → "The sparks fizzle out...")
- ✅ NO Campfire object in world
- ✅ Flint durability: 100 → 99
- ✅ Pyrite durability: 100 → 99

**Related Files**: FireStartingSystem.dm

---

### Test 3: Kindling Recipe (Sticks → Kindling) ❓
**Objective**: Verify kindling recipe works (NOT carving)

**Steps**:
1. Obtain 3 stick items
2. Find recipe UI (location: UNKNOWN - needs investigation)
3. Select "Create Kindling" recipe
4. Provide 3 sticks as input
5. Get 1 kindling as output

**Expected**:
- ✅ 3 sticks → 1 kindling
- ✅ Recipe works in any biome/season
- ✅ No workstation required
- ✅ Tutorial step 3

**Notes**: This recipe differs from carving knife output
- **Carving Knife**: Wood → Kindling (1-3 items per action)
- **Kindling Recipe**: 3 Sticks → 1 Kindling

---

### Test 4: Fire Lighting Recipe (Flint+Pyrite+Kindling→Campfire) ❓
**Objective**: Verify campfire_light recipe works

**Steps**:
1. Equip Flint + Pyrite + have Kindling in inventory
2. Strike sparks (Test 2 above)
3. Find recipe UI for "Light a Campfire"
4. Execute recipe with Flint (1) + Pyrite (1) + Kindling (1)
5. Get Campfire object (1)

**Expected**:
- ✅ Campfire created (location: player location or forge?)
- ✅ Campfire has heat/light properties
- ✅ Can be used for cooking/smelting
- ✅ Inputs consumed: Flint (1), Pyrite (1), Kindling (1)

**Notes**: 
- Mechanism for recipe execution: **UNKNOWN** (needs research)
- Campfire location: **UNKNOWN** (ground or inventory?)
- Campfire properties: Check FireSystem.dm

---

### Test 5: Tool Durability Threshold Warnings ✅
**Objective**: Verify tool warning messages

**Steps**:
1. Use tool repeatedly until ~25% durability remains
2. Attempt action
3. Check for warning message

**Expected**:
- ✅ Message appears: "Your tool is almost broken (X% durability left)"
- ✅ Tool still functions
- ✅ Message repeats on each action

**Related Files**: CentralizedEquipmentSystem.dm (IsFragile() method)

---

### Test 6: Tool Durability Failure ✅
**Objective**: Verify tool breaks when durability = 0

**Steps**:
1. Use tool until durability = 0
2. Attempt action
3. Check result

**Expected**:
- ✅ Message: "Your tool is broken!"
- ✅ Action fails (no kindling produced, no sparks, etc.)
- ✅ Tool remains in inventory (broken state)
- ✅ Tool needs replacement/repair

**Related Files**: CentralizedEquipmentSystem.dm (IsBroken() method)

---

### Test 7: Carving Rank Progression
**Objective**: Verify RANK_CARVING increases with use

**Steps**:
1. Check initial carving rank: `M.character.GetRankLevel(RANK_CARVING)`
2. Carve 10 kindling (10 actions)
3. Check rank after: should be 1 → 2
4. Repeat to max rank 5

**Expected**:
- ✅ Each carving action awards 5-7 XP
- ✅ Rank-up message: "Your carving skill has improved to rank X!"
- ✅ Output increases: Rank 1 (1), Rank 2 (2), Rank 5 (5) items per normal action
- ✅ Critical chance increases: Rank 1 (5%), Rank 5 (25%)

**Related Files**: CarvingKnifeSystem.dm, UnifiedRankSystem.dm

---

### Test 8: Hotbar Integration
**Objective**: Verify carving works via ToolbeltHotbarSystem

**Steps**:
1. Equip carving knife to toolbelt slot
2. Press hotbar key (e.g., "1" for slot 1)
3. Select "Carving" mode
4. Highlight "Carve Kindling"
5. Press E-key to execute

**Expected**:
- ✅ Mode changes to "carving"
- ✅ Menu shows "Carve Kindling" as only option
- ✅ E-key executes carving
- ✅ No errors or placeholder messages

**Related Files**: ToolbeltHotbarSystem.dm

---

## Debugging Commands

### Check Tool Durability
```dm
/world/proc/CheckToolDurability(mob/M, slot)
	var/obj/items/equipment/tool/T = M.equipment_slots[slot]
	if(!T) return "No tool in [slot]"
	return "Durability: [T.current_durability] / [T.max_durability] ([T.GetDurabilityPercent()]%)"
```

### Force Tool Breaking
```dm
/world/proc/BreakTool(mob/M, slot)
	var/obj/items/equipment/tool/T = M.equipment_slots[slot]
	if(T) T.current_durability = 0
	return "Tool broken"
```

### Check Carving Rank
```dm
/world/proc/CheckCarvingRank(mob/M)
	return "Carving rank: [M.character.GetRankLevel(RANK_CARVING)]"
```

### List All Tool Durabilities
```dm
/world/proc/ListAllToolDurabilities()
	var/list/tools = list(
		/obj/items/equipment/tool/Pickaxe = 250,
		/obj/items/equipment/tool/Hammer = 400,
		/obj/items/equipment/tool/CarvingKnife = 300,
		/obj/items/equipment/tool/Axe = 300,
		/obj/items/equipment/tool/Hoe = 300,
		/obj/items/equipment/tool/Sickle = 300,
		/obj/items/equipment/tool/Shovel = 350,
		/obj/items/equipment/tool/Flint = 100,
		/obj/items/equipment/tool/Pyrite = 100,
		/obj/items/equipment/tool/Chisel = 500,
		/obj/items/equipment/tool/Trowel = 400
	)
	for(var/tool_type in tools)
		world << "[tool_type]: [tools[tool_type]] max durability"
```

---

## Known Issues / Pending Investigation

### ❓ Fire Recipe Execution
- **Issue**: How does campfire_light recipe trigger?
- **Status**: Needs research in CookingSystem.dm or RecipeState.dm
- **Impact**: Fire-making workflow incomplete

### ❓ Dual-Wield Hotbar Slots
- **Issue**: How does toolbelt handle Flint+Pyrite together?
- **Status**: Needs research in ToolbeltComplete.dm
- **Impact**: May need hotbar slot adjustment

### ❓ Stone Carving System
- **Issue**: Where is Hammer+Chisel stone carving?
- **Status**: Not yet implemented
- **Impact**: Stone carving unavailable

### ❓ Carving Details Option
- **Issue**: Should there be "Carve Initials" for item personalization?
- **Status**: Deferred until user clarifies
- **Impact**: Only Kindling available now

---

## Build Information

**Build Status**: ✅ CLEAN  
**Baseline Errors**: 88 (markdown linting)  
**Tool-Related Errors**: 0  
**Last Build**: 12/14/25 12:58 pm  
**Files Modified**: CentralizedEquipmentSystem.dm, CarvingKnifeSystem.dm, FireStartingSystem.dm, ToolbeltHotbarSystem.dm

---

**Ready for Testing** ✅

All tool durability systems are implemented and ready for QA.
See TOOL_SYSTEMS_COMPLETION_SESSION_12_14_25.md for full documentation.
