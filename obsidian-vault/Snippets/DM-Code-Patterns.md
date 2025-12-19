# Code Patterns & Snippets

**Category**: DM Language Patterns  
**Last Updated**: 2025-12-16

## Initialization Pattern
Use this when creating systems that need to initialize after world starts:

```dm
// In your system file
/proc/InitializeYourSystem()
	if(world_initialization_complete)
		return  // Already done
	
	// Do initialization
	world.log << "[INIT] Your system initialized"
	RegisterInitComplete("your_system_name")

// In InitializationManager.dm, add to RegisterInitComplete()
```

**Key Points**:
- Always check `world_initialization_complete` first
- Call `RegisterInitComplete()` when done
- Use appropriate spawn() tick offset based on dependencies

## Background Loop Pattern
Non-blocking infinite loop for polling/processing:

```dm
/proc/YourBackgroundProcess()
	set background = 1
	set waitfor = 0
	
	while(1)
		// Do work
		sleep(10)  // Every 0.5 seconds (TIME_STEP = 5)
```

## Movement Cache Invalidation
Called whenever player moves to update permissions:

```dm
/mob/players/proc/InvalidateDeedPermissionCache()
	// Gate on player movement
	// Called every move to check deed zone changes
	if(last_deed_zone != current_deed_zone)
		UpdateDeedPermissions()
```

## Equipment Check Pattern
Before equipping, validate stats:

```dm
if(!CanEquipArmor(M, armor_obj))
	return  // Fail

// Equip and update overlays
M.Aequipped = 1
M.UpdateEquipmentOverlays()
```

## Consuming Item Pattern
Restore stats + remove from inventory:

```dm
if(!istype(item, /obj/consumable))
	return

var/nutrition = CONSUMABLES[item.type]["nutrition"]
M.hunger -= nutrition
M.stamina += CONSUMABLES[item.type]["stamina"]
del(item)  // Remove from inventory
```

## Season-Gated Harvest
Always check if item harvestable in current season:

```dm
var/list/valid_seasons = CONSUMABLES[resource_name]["seasons"]
if(!(current_season in valid_seasons))
	M << "Cannot harvest [resource_name] in [current_season]"
	return
```

## Rank Update Pattern
Get, modify, trigger callbacks:

```dm
var/rank = M.GetRankLevel(RANK_FISHING)
if(rank < 5)
	M.UpdateRankExp(RANK_FISHING, exp_gain)
	M.SetRankLevel(RANK_FISHING, rank + 1)
	M.CheckRecipeUnlocks(RANK_FISHING)
```

## Deed Permission Check
Gate all building/pickup/drop actions:

```dm
if(!CanPlayerBuildAtLocation(M, T))
	M << "Cannot build here - deed protected"
	return

// Safe to build
```

## Elevation Interaction Check
Before objects interact, verify proximity:

```dm
if(!Chk_LevelRange(obj1, obj2))
	return  // Too far apart vertically
// Safe to interact
```

## NPC Recipe Teaching
Unlock recipe via dialogue:

```dm
/mob/npcs/proc/TeachRecipe(mob/players/M, recipe_name)
	if(RECIPES[recipe_name])
		UnlockRecipeFromNPC(M, recipe_name)
		M << "[src.name] teaches you: [recipe_name]"
```

## Market Price Query
Get dynamic pricing from system:

```dm
var/price = GetMarketPrice(item_type, continent)
M << "Current price: [price] Lucre"
```

## Related
- [[Build-System-Reference]]
- [[Project-Overview]]
