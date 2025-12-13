# Phase 3: Additional Action Restrictions - IMPLEMENTATION GUIDE

**Estimated Time**: 2-3 hours  
**Complexity**: Low-Medium  
**Files to Modify**: 3-5  
**Expected Build**: 0 errors  

---

## Overview

Phase 3 extends village deed zone permission enforcement to additional gameplay actions beyond pickup/drop/plant. This ensures players cannot harvest resources, craft, or trade in unauthorized zones.

---

## Implementation Strategy

Phase 3 follows the same pattern for EACH action:

1. **Locate the action verb/proc**
2. **Check permissions at start**
3. **Block or allow based on flags**
4. **Show appropriate message**

The permission check is always:
```dm
if(!CanPlayerBuildAtLocation(M, get_turf(M)))
	M << "You don't have permission to do this here."
	return
```

Or for pickup/drop specific checks:
```dm
if(!CanPlayerPickupAtLocation(M, T))
	M << "You don't have permission to pick up items here."
	return
```

---

## Action 1: Mining (Resource Harvesting)

### Where to Add Check

**File**: `dm/mining.dm` or appropriate mining system  
**Location**: Inside the ore breaking/harvesting verb or proc  
**Current Pattern**: Likely has verb/tool check, add permission check before action

### Implementation

```dm
mob/players/verb/Mine()
	set name = "Mine"
	set category = "Actions"
	
	// EXISTING CODE: Tool check, animation, etc.
	
	// ADD THIS:
	if(!CanPlayerBuildAtLocation(src, get_turf(src)))
		src << "You don't have permission to mine here."
		return
	
	// EXISTING CODE: Ore removal, inventory add, etc.
```

### Testing
- [ ] Can mine in own village zone
- [ ] Cannot mine in other player's zone
- [ ] Can mine freely outside zones
- [ ] Message shows when blocked

---

## Action 2: Fishing (Fish Catching)

### Where to Add Check

**File**: `dm/FishingSystem.dm`  
**Location**: Inside fish catch logic (likely in a verb or on-click handler)  
**Current Pattern**: Probably checks for fishing spot, skill, etc.

### Implementation

```dm
mob/players/proc/CatchFish(var/turf/fishing_spot)
	// EXISTING CODE: Skill checks, animation
	
	// ADD THIS:
	if(!CanPlayerBuildAtLocation(src, fishing_spot))
		src << "You cannot fish here."
		return FALSE
	
	// EXISTING CODE: Spawn fish, add to inventory, etc.
```

### Testing
- [ ] Can fish in own village zone
- [ ] Cannot fish in other player's zone
- [ ] Can fish freely outside zones
- [ ] Message shows when blocked

---

## Action 3: Crafting (Recipe Execution)

### Where to Add Check

**File**: `dm/RefinementSystem.dm` or `dm/CentralizedEquipmentSystem.dm`  
**Location**: Inside craft/refine verb when recipe is executed  
**Current Pattern**: Validates recipe, checks inventory, consumes materials

### Implementation

```dm
mob/players/proc/CraftRecipe(var/recipe_id)
	// EXISTING CODE: Recipe validation
	
	// ADD THIS:
	if(!CanPlayerBuildAtLocation(src, get_turf(src)))
		src << "You cannot craft items here."
		return FALSE
	
	// EXISTING CODE: Material consumption, item creation, etc.
```

### Testing
- [ ] Can craft in own village zone
- [ ] Cannot craft in other player's zone
- [ ] Can craft freely outside zones
- [ ] Crafting UI shows permission message

---

## Action 4: NPC Trading (Restricted Transactions)

### Where to Add Check

**File**: `dm/NPCRecipeIntegration.dm` or `dm/store.dm`  
**Location**: Inside NPC trade/sell/buy verb  
**Current Pattern**: Checks inventory, NPC proximity, validates items

### Implementation

```dm
mob/players/verb/TradewithNPC(var/atom/NPC)
	set name = "Trade"
	
	// EXISTING CODE: NPC validation, proximity check
	
	// ADD THIS:
	if(!CanPlayerBuildAtLocation(src, get_turf(src)))
		src << "You cannot trade with NPCs in restricted areas."
		return
	
	// EXISTING CODE: Trade window, exchange items, etc.
```

### Testing
- [ ] Can trade in own village zone
- [ ] Cannot trade in other player's zone
- [ ] Can trade freely outside zones
- [ ] NPC dialog shows permission message

---

## Action 5: Housing/Furniture (Deed-Only Decoration)

### Where to Add Check

**File**: `dm/FurnitureExtensions.dm`  
**Location**: Inside furniture placement/decoration verb  
**Current Pattern**: Likely checks for valid location, item type, etc.

### Implementation

```dm
mob/players/verb/PlaceFurniture()
	set name = "Place Furniture"
	
	// EXISTING CODE: Item validation, animation
	
	// ADD THIS:
	if(!CanPlayerBuildAtLocation(src, get_turf(src)))
		src << "You can only place furniture in your own village zone."
		return FALSE
	
	// EXISTING CODE: Furniture object creation, etc.
```

### Testing
- [ ] Can place furniture in own village zone
- [ ] Cannot place furniture in other player's zone
- [ ] Cannot place furniture outside zones
- [ ] Message shows when blocked

---

## Implementation Checklist

### Pre-Implementation
- [ ] Read existing action code to understand structure
- [ ] Identify exact location of action execution
- [ ] Note any special conditions (cooldown, skill check, etc.)
- [ ] Plan permission check placement (before or after other checks?)

### Implementation
- [ ] Add permission check call: `CanPlayerBuildAtLocation(src, get_turf(src))`
- [ ] Add denial message in player's language tone
- [ ] Ensure check happens BEFORE resource consumption
- [ ] Add return/abort if permission denied

### Testing
- [ ] Can perform action in own zone (if owner)
- [ ] Cannot perform action in other zone
- [ ] Can perform action freely outside zones
- [ ] Message appears when denied
- [ ] No resource waste on denied action

### Code Review
- [ ] Check indentation/spacing
- [ ] Verify message clarity
- [ ] Ensure no unintended side effects
- [ ] Confirm permission function exists (should be in DeedPermissionSystem.dm)

### Build Validation
- [ ] Build succeeds (0 errors)
- [ ] No compile warnings related to changes
- [ ] Test each action in game

---

## Permission Function Reference

### CanPlayerBuildAtLocation(mob/players/M, turf/T)
**Returns**: 1 if player can build at location, 0 otherwise  
**Logic**: 
- TRUE if M.canbuild == 1
- TRUE if player is outside all zones
- FALSE if player is in zone with canbuild == 0

**Usage**:
```dm
if(!CanPlayerBuildAtLocation(src, get_turf(src)))
	src << "Permission denied."
	return
```

### CanPlayerPickupAtLocation(mob/players/M, turf/T)
**Returns**: 1 if player can pickup at location, 0 otherwise  
**Logic**: 
- TRUE if M.canpickup == 1
- TRUE if player is outside all zones
- FALSE if in zone with canpickup == 0

### CanPlayerDropAtLocation(mob/players/M, turf/T)
**Returns**: 1 if player can drop at location, 0 otherwise  
**Logic**: 
- TRUE if M.candrop == 1
- TRUE if player is outside all zones
- FALSE if in zone with candrop == 0

**All three are defined in**: `dm/DeedPermissionSystem.dm`

---

## File-by-File Guide

### Action Type: Mining/Harvesting
**Primary File**: `dm/mining.dm`  
**Secondary**: `dm/GatheringExtensions.dm`  
**Search for**: "ore", "harvest", "mine"  
**Look for verb/proc**: Mine(), Harvest(), BreakOre()  

**Modify**:
```dm
// Before ore is removed from world:
if(!CanPlayerBuildAtLocation(src, get_turf(src)))
	src << "You don't have permission to mine here."
	return
```

### Action Type: Fishing
**Primary File**: `dm/FishingSystem.dm`  
**Search for**: "fish", "catch", "cast"  
**Look for verb/proc**: Fish(), CatchFish(), CastLine()  

**Modify**:
```dm
// Before fish is spawned/added to inventory:
if(!CanPlayerBuildAtLocation(src, get_turf(src)))
	src << "You cannot fish here."
	return FALSE
```

### Action Type: Crafting
**Primary File**: `dm/RefinementSystem.dm`  
**Secondary**: `dm/CentralizedEquipmentSystem.dm`  
**Search for**: "craft", "refine", "create"  
**Look for verb/proc**: Craft(), Refine(), CreateItem()  

**Modify**:
```dm
// Before materials are consumed:
if(!CanPlayerBuildAtLocation(src, get_turf(src)))
	src << "You cannot craft items here."
	return FALSE
```

### Action Type: NPC Trading
**Primary File**: `dm/store.dm`  
**Secondary**: `dm/NPCRecipeIntegration.dm`  
**Search for**: "trade", "sell", "buy", "shop"  
**Look for verb/proc**: Trade(), OpenShop(), BuyItem()  

**Modify**:
```dm
// Before trade window opens/items exchange:
if(!CanPlayerBuildAtLocation(src, get_turf(src)))
	src << "You cannot trade here."
	return
```

### Action Type: Housing/Furniture
**Primary File**: `dm/FurnitureExtensions.dm`  
**Search for**: "furniture", "place", "decorate"  
**Look for verb/proc**: PlaceFurniture(), Decorate(), PlaceObject()  

**Modify**:
```dm
// Before furniture object is created:
if(!CanPlayerBuildAtLocation(src, get_turf(src)))
	src << "You can only place furniture in your own village zone."
	return FALSE
```

---

## Example: Complete Mining Action Integration

### Before (No Permission Check)
```dm
mob/players/proc/MinedOre()
	if(!tool)
		src << "You need a pickaxe."
		return
	
	flick("mining", src)
	sleep(30)
	
	var/ore_type = get_ore_at_location(get_turf(src))
	if(!ore_type)
		src << "No ore here."
		return
	
	var/ore = new ore_type()
	src.Add(ore)
	src << "You mined ore!"
	return
```

### After (With Permission Check)
```dm
mob/players/proc/MinedOre()
	// NEW: Check permission first
	if(!CanPlayerBuildAtLocation(src, get_turf(src)))
		src << "You don't have permission to mine here."
		return
	
	if(!tool)
		src << "You need a pickaxe."
		return
	
	flick("mining", src)
	sleep(30)
	
	var/ore_type = get_ore_at_location(get_turf(src))
	if(!ore_type)
		src << "No ore here."
		return
	
	var/ore = new ore_type()
	src.Add(ore)
	src << "You mined ore!"
	return
```

**Note**: Permission check happens FIRST, before tool validation. This is correct order.

---

## Testing Phase 3

### Test Environment Setup
1. Create test village zone with known coordinates
2. Create test character as zone owner
3. Create test character as non-owner
4. Set permissions (owner gets canbuild=1, non-owner gets canbuild=0)

### Test Sequence for Each Action

**Owner Character**:
1. Enter village zone
2. Attempt action (mine/fish/craft/trade/place furniture)
3. VERIFY: Action succeeds, no permission message

**Non-Owner Character**:
1. Enter someone else's village zone
2. Attempt same action
3. VERIFY: Action blocked, permission message appears

**Outside Zone**:
1. Exit all village zones
2. Attempt action
3. VERIFY: Action succeeds (no zone restrictions)

### Debug Commands
```dm
// Check current permission flags:
world << "[usr.canbuild] [usr.canpickup] [usr.candrop]"

// Check zone info:
world << "Zone ID: [usr.village_zone_id]"

// Manually test permission function:
world << "[CanPlayerBuildAtLocation(usr, get_turf(usr))]"
```

---

## Common Pitfalls & Solutions

### Pitfall 1: Permission Check Too Late
**Problem**: Resources consumed before permission checked  
**Solution**: Move check to the VERY START of the proc

```dm
// WRONG:
mob/players/proc/Mine()
	var/ore = get_ore()
	consume_resources()
	if(!CanPlayerBuildAtLocation(src, get_turf(src))) // TOO LATE
		return

// RIGHT:
mob/players/proc/Mine()
	if(!CanPlayerBuildAtLocation(src, get_turf(src)))
		src << "Permission denied."
		return
	
	var/ore = get_ore()
	consume_resources()
```

### Pitfall 2: Wrong Permission Function
**Problem**: Used canpickup for mining action  
**Solution**: Always use CanPlayerBuildAtLocation for crafting/building actions

```dm
// WRONG:
if(!CanPlayerPickupAtLocation(src, get_turf(src))) // For mining?
	return

// RIGHT:
if(!CanPlayerBuildAtLocation(src, get_turf(src))) // Correct
	return
```

### Pitfall 3: Forgot to Return
**Problem**: Action still proceeds even though permission denied  
**Solution**: ALWAYS include return statement after permission check

```dm
// WRONG:
if(!CanPlayerBuildAtLocation(src, get_turf(src)))
	src << "Permission denied."
// Missing return! Action continues!

// RIGHT:
if(!CanPlayerBuildAtLocation(src, get_turf(src)))
	src << "Permission denied."
	return // Don't forget!
```

### Pitfall 4: Unclear Permission Messages
**Problem**: Player doesn't understand why action failed  
**Solution**: Use descriptive, action-specific messages

```dm
// UNCLEAR:
src << "You can't do that."

// CLEAR:
src << "You don't have permission to mine here. Only village members can harvest resources."
```

---

## Estimated Time per Action

| Action | Difficulty | Time | Files |
|--------|-----------|------|-------|
| Mining | Easy | 15 min | 1-2 |
| Fishing | Easy | 15 min | 1 |
| Crafting | Medium | 20 min | 1-2 |
| NPC Trading | Medium | 20 min | 1-2 |
| Housing | Medium | 15 min | 1 |
| **TOTAL** | **Medium** | **~90 min** | **~8** |

---

## Phase 3 Success Criteria

✅ All 5 actions have permission checks  
✅ 0 compile errors after all changes  
✅ Can perform actions in own zone (if owner)  
✅ Cannot perform actions in other zones  
✅ Can perform actions freely outside zones  
✅ Appropriate messages show when blocked  
✅ No resource waste on blocked actions  
✅ Tested with multiple players in game  

---

## Next Phase (Phase 4) Preview

Once Phase 3 is complete, Phase 4 could include:
- **Deed Transfer System**: Allow player-to-player sale of deeds
- **Zone Rental**: Temporary access for payment
- **Treasury System**: Shared village funds
- **Permission Tiers**: Admin, moderator, member, guest levels
- **NPC Hiring**: Pay NPCs to defend/maintain zone

---

**Phase 3 is straightforward and should be implementable in 1-2 hours once you identify all the action locations.** ✅

