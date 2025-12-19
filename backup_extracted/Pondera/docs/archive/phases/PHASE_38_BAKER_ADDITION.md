# Phase 38 Addition: Baker/Chef NPC Type

**Status**: ✅ COMPLETE (integrated into Phase 38)  
**Date**: December 9, 2025  
**Build**: 0 errors, 0 warnings

## Overview

The Baker NPC type has been added to Phase 38, making practical use of Pondera's cooking system. The Baker wakes very early (4 AM) to prepare ovens and begin baking, provides fresh bread and cooked food throughout the day, and maintains extended shop hours to serve evening customers.

## Baker NPC Details

### Schedule

| Property | Value |
|----------|-------|
| **Shop Hours** | 5 AM - 7 PM |
| **Sleep Time** | 9 PM - 4 AM (very early riser) |
| **Total Sleep** | 7 hours |
| **Work Hours** | 14 hours (longest of all NPC types) |

### Daily Routine

The Baker follows this 11-step routine throughout the day:

1. **Sleep** (9 PM - 4 AM) - Rest after late evening work
2. **Wake** (4 AM) - Rise very early to begin work
3. **Prepare Oven** (4 AM - 5 AM) - Heat ovens, prepare workstation
4. **Bake Bread** (5 AM) - Early morning baking before shop opens
5. **Open Shop** (5 AM) - Open bakery to customers (fresh bread ready)
6. **Work** (Morning) - Serve customers, manage counter
7. **Restock Bread** (Mid-day) - Bake fresh batches for afternoon rush
8. **Lunch** (Noon-1 PM) - Take lunch break
9. **Work** (Afternoon) - Serve customers, complete transactions
10. **Bake Evening** (Evening) - Final baking for next day's morning rush
11. **Close Shop** (7 PM) - Close bakery, end workday
12. **Socialize** (7 PM - 9 PM) - Interact with townspeople, relax

### Gameplay Impact

- **5 AM Opening**: Baker opens earliest among all shops, providing fresh bread for breakfast
- **Extended Hours**: Open until 7 PM serves dinner crowds and evening customers
- **Consistent Supply**: Bakes throughout day ensuring fresh food availability
- **Food Source**: Provides cooked food that contributes to NPC/player consumption ecosystem
- **Town Life**: Creates natural morning/evening rhythm (Baker = first shop open, last action of evening bake)

## Integration Points

### NPCRoutineSystem.dm
- **Shop Hours Entry**: Added Baker to NPC_SHOP_HOURS dictionary (5 AM open, 7 PM close)
- **Routine Type**: Added "baker" case in SetupNPCType() with 11-step routine
- **Sleep Schedule**: Very early riser (21:00 - 04:00 = 9 PM - 4 AM)
- **Actions**: prepare_oven, bake_bread, restock_bread, bake_evening (custom baking actions)

### Code Changes

**File**: `dm/NPCRoutineSystem.dm` (479 lines total)

**Addition 1** - NPC_SHOP_HOURS dictionary:
```dm
"Baker" = list("open_hour" = 5, "open_ampm" = "am", "close_hour" = 7, "close_ampm" = "pm")
```

**Addition 2** - SetupNPCType() function:
```dm
if("baker")
	open_hour = 5      // Very early - starts baking at 5 AM
	close_hour = 19    // 7 PM
	sleep_start_hour = 21
	sleep_end_hour = 4 // Up at 4 AM to start baking
	routine_actions = list(
		"sleep", "wake", "prepare_oven", "bake_bread", "open_shop", "work", 
		"restock_bread", "lunch", "work", "bake_evening", "close_shop", "socialize", "sleep"
	)
```

## Design Rationale

### Why Baker Makes Sense

1. **Cooking System Integration**: Pondera has a robust cooking/baking system; Baker uses it actively
2. **Food Provision**: Supplies the town with bread and cooked goods
3. **Economic Role**: Different from Merchant/Fisher/Herbalist - provides food staple
4. **Realistic Schedule**: Bakers historically wake very early to have bread ready at dawn
5. **Player Interaction**: Fresh bread at 5 AM is a natural early-game resource
6. **Complements Others**: 
   - Herbalist gathers ingredients (herbs)
   - Baker transforms ingredients into food
   - Merchant trades finished goods

### Sleep Schedule Justification

- **4 AM Wake Time**: Ensures ovens are hot by 5 AM shop opening
- **9 PM Sleep Time**: Reasonable bedtime after evening bake routine
- **7-Hour Sleep**: Adequate rest for physically demanding early morning work
- **Different from Others**: Distinct schedule from Herbalist (9 PM - 7 AM) and Fisher (8 PM - 5 AM)

### Routine Action Justification

**prepare_oven** (4 AM): Not typically executed during work hours - prep work before opening

**bake_bread** (5 AM): Core baking action - produces fresh goods at opening time

**restock_bread** (Mid-day): Continuous baking throughout day to maintain supply

**bake_evening** (5-7 PM): Final batch for next morning's opening

These actions can integrate with:
- **RECIPES system**: Baker executes bread/pastry recipes
- **CONSUMABLES system**: Produces items consumable by NPCs and players
- **COOKING system**: Uses cooking system's recipe validation and quality calculation

## Future Extensions

### Phase 38D: NPC Food Consumption
- Baker's bread enters town food supply
- NPCs consume bread throughout day
- Low bread supply triggers NPC restlessness/complaints
- Creates economic feedback loop

### Phase 39: NPC Events
- Baker runs out of flour → quest to bring grain
- Oven breaks → quest to repair/find blacksmith
- Bread festival → special event tied to Baker routine
- Food shortage events → Baker cannot bake

### Phase 40: NPC Relationships
- Players can befriend Baker
- Special discounts for regular customers
- Learn bread recipes from Baker through dialogue
- Romantic storylines with Baker (friendly, hospitable personality)

### Phase 41: Dynamic Economy
- Baker's production directly affects town food prices
- Shortage of grain raises bread costs
- Overproduction lowers prices
- Player farming directly impacts Baker's production

## Testing Commands

```dm
/AdvanceGameTime - Jump to 4 AM to see Baker wake and prepare
/AdvanceGameTime - Jump to 5 AM to see shop open with fresh bread
/AdvanceGameTime - Jump to 7 PM to see shop close
/ViewNPCRoutineStatus - Check Baker's current state throughout day
/SimulateNPCRoutineUpdate - Force routine update
```

## Statistics Update

**Phase 38 After Baker Addition**:
- Code Lines: 479 (up from 467)
- NPC Types: 6 (up from 5)
- Total Routine Actions: 64+ (distributed across all NPCs)
- Build Status: ✅ Clean (0 errors, 0 warnings)

## Documentation Updates

- ✅ NPCRoutineSystem.dm (479 lines)
- ✅ PHASE_38_NPC_ROUTINE_SYSTEM.md (473 lines - updated for Baker)
- ✅ PHASE_38_QUICK_REFERENCE.md (84 lines - updated table + stats)
- ✅ PHASE_38_BAKER_ADDITION.md (this file)

## Commit Ready

All changes staged and ready to commit:
- `dm/NPCRoutineSystem.dm` - Baker implementation
- `PHASE_38_NPC_ROUTINE_SYSTEM.md` - Documentation update
- `PHASE_38_QUICK_REFERENCE.md` - Reference table update

## Conclusion

The Baker NPC type perfectly fills the gap in Pondera's NPC ecosystem. Rather than just trading or gathering, the Baker actively uses the cooking system to provide a crucial resource (food) to the town. The very early wake time (4 AM) and extended hours (5 AM - 7 PM) give the Baker a distinctive daily pattern that creates natural gameplay rhythm.

The Baker becomes the economic hub connecting:
- **Herbalist** (provides ingredients via gathering)
- **Farmer** (future: provides grain)
- **Merchant** (sells finished goods)
- **Players** (consume bread, learn recipes)
- **NPCs** (consume bread as part of their day)

This creates a living, breathing ecosystem where NPC actions have real consequences.
