# Phase 9 - plant.dm Integration Guide

**Status**: Framework ready, awaiting plant.dm integration  
**Build Status**: ✅ 0 errors, 3 warnings  
**Target**: Integrate soil quality system into actual harvesting and growth

## Overview

Phase 9 integrates the soil quality system created in Phase 8 into the actual plant.dm code. This makes farming truly soil-aware - crops will have different growth speeds and harvest yields based on soil quality.

## Integration Points

### 1. PickV() Function (Lines 741-828)

**What it does**: Handles vegetable harvesting (potatoes, carrots, onions, tomatoes, pumpkins)

**Current code** (line 805):
```dm
if(prob(Rarity+grank))		//Takes the rarity of the tree and your woodcutting lvl
	Picker<<"You Finish working the [VegeType] plant and receive [VegeType]!"
	M.overlays -= image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
	src.icon_state="picked"
	src.vgrowstate = 7
	src.name = "Harvested"
	new vegetable(usr)			// NEEDS UPDATE
	new seed(usr)
	grankEXP+=GiveXP
	M.GNLvl()
	Picking=0
	VegeAmount--
	SeedAmount--
```

**Replace with**:
```dm
if(prob(Rarity+grank))		//Takes the rarity of the tree and your woodcutting lvl
	// Integrate soil system
	var/soil_type = SOIL_BASIC  // TODO: Get from loc.soil_type when turfs have soil variables
	
	// Calculate harvest amount with soil modifiers
	var/harvest_amount = ApplyHarvestYieldBonus(src, 1, M:hrank, soil_type)
	var/in_season = IsSeasonForCrop(VegeType)
	var/message = GetPlantHarvestMessage(src, in_season, soil_type)
	
	Picker<<message  // Show soil feedback to player
	M.overlays -= image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
	src.icon_state="picked"
	src.vgrowstate = 7
	src.name = "Harvested"
	
	// Create items based on calculated harvest amount
	for(var/i = 1; i <= harvest_amount; i++)
		new vegetable(usr)
	
	new seed(usr)
	grankEXP+=GiveXP
	M.GNLvl()
	Picking=0
	VegeAmount--
	SeedAmount--
```

**Key changes**:
- Add `soil_type` variable (set to SOIL_BASIC for now)
- Call `ApplyHarvestYieldBonus()` with soil_type
- Call `GetPlantHarvestMessage()` to get feedback message
- Loop `harvest_amount` times to create vegetables
- Result: Rich soil gives more vegetables, depleted soil gives fewer

### 2. PickG() Function (Lines 1093-1170)

**What it does**: Handles grain harvesting (wheat, barley)

**Current code** (line 1143):
```dm
if(prob(Rarity+grank))		//Takes the rarity of the tree and your woodcutting lvl
	Picker<<"You Finish working the [GrainType] plant and receive [GrainType]!"
	M.overlays -= image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
	src.icon_state="picked"
	src.ggrowstate=7
	src.name = "Picked"
	new grain(usr)			// NEEDS UPDATE
	new seed(usr)
	grankEXP+=GiveXP
	M.GNLvl()
	Picking=0
	GrainAmount--
	SeedAmount--
```

**Replace with** (identical pattern to PickV):
```dm
if(prob(Rarity+grank))		//Takes the rarity of the tree and your woodcutting lvl
	// Integrate soil system
	var/soil_type = SOIL_BASIC  // TODO: Get from loc.soil_type when turfs have soil variables
	
	// Calculate harvest amount with soil modifiers
	var/harvest_amount = ApplyHarvestYieldBonus(src, 1, M:hrank, soil_type)
	var/in_season = IsSeasonForCrop(GrainType)
	var/message = GetPlantHarvestMessage(src, in_season, soil_type)
	
	Picker<<message  // Show soil feedback to player
	M.overlays -= image('dmi/64/SKoy.dmi',icon_state="[get_dir(M,src)]")
	src.icon_state="picked"
	src.ggrowstate=7
	src.name = "Picked"
	
	// Create items based on calculated harvest amount
	for(var/i = 1; i <= harvest_amount; i++)
		new grain(usr)
	
	new seed(usr)
	grankEXP+=GiveXP
	M.GNLvl()
	Picking=0
	GrainAmount--
	SeedAmount--
```

### 3. Vegetable Grow() Function (Lines 826-893)

**What it does**: Handles vegetable growth stages over time

**Current code**:
```dm
proc/Grow()//vegetable growth
	var/randomvalue = rand(240,840)
	spawn(randomvalue)
	//spawn(420) // 420 testing Normaly set to 12000, or twenty min.
	// ... growth stage logic
	if(src.vgrowstate == 8||src.vgrowstate == 7)
		return
	if (month == "Shevat"&&day>=1||month == "Shevat"&&day<=9)
		src:vgrowstate = 1//seed
```

**Replace with**:
```dm
proc/Grow()//vegetable growth
	// Apply soil growth modifiers
	var/soil_type = SOIL_BASIC  // TODO: Get from loc.soil_type
	var/base_growth_ticks = rand(240,840)
	var/adjusted_growth_ticks = ApplySoilModifiersToGrowthSpeed(src, base_growth_ticks, soil_type)
	
	spawn(adjusted_growth_ticks)  // Rich soil: ~204 ticks (15% faster), Depleted soil: ~1280 ticks (40% slower)
	
	// Check seasonal growth inside spawn block
	if(!CheckSeasonalGrowth())
		return
	
	// ... rest of growth stage logic
	if(src.vgrowstate == 8||src.vgrowstate == 7)
		return
	if (month == "Shevat"&&day>=1||month == "Shevat"&&day<=9)
		src:vgrowstate = 1//seed
```

**Key changes**:
- Calculate adjusted growth time using soil modifier
- Add seasonal growth check (blocks out-of-season growth)
- Result: Rich soil grows faster, depleted soil grows slower

### 4. Grain Grow() Function (Lines 1171-1238)

**What it does**: Handles grain growth stages

**Same pattern as Vegetable Grow()**:
```dm
proc/Grow()//grain growth
	// Apply soil growth modifiers
	var/soil_type = SOIL_BASIC  // TODO: Get from loc.soil_type
	var/base_growth_ticks = rand(840,1240)
	var/adjusted_growth_ticks = ApplySoilModifiersToGrowthSpeed(src, base_growth_ticks, soil_type)
	
	spawn(adjusted_growth_ticks)  // Rich soil: ~732 ticks (15% faster), Depleted soil: ~2067 ticks (40% slower)
	
	// Check seasonal growth inside spawn block
	if(!CheckSeasonalGrowth())
		return
	
	// ... rest of growth stage logic
```

### 5. Berry Pick() Function (Lines 556-640)

**Optional**: Same pattern as vegetables, but berries have different base yields

Current: `new fruitc(usr)` (creates fruit cluster)

With soil: Could vary fruit cluster quality or yield

## Test Plan

### After Integration

**Test 1: Harvest Feedback**
- Harvest vegetable in basic soil → See normal message
- Harvest vegetable in rich soil → See "Rich soil has greatly improved the harvest!"
- Verify message appears for each harvest

**Test 2: Harvest Quantity**
- Harvest vegetable with rank 5 skill, basic soil → Get 1 vegetable
- Harvest same in rich soil → Get more vegetables (1.2× multiplier)
- Verify ApplyHarvestYieldBonus() is being called with correct soil_type

**Test 3: Growth Speed**
- Plant vegetable, check growth time
- Growth time should vary by soil quality
- Rich soil should reach maturity faster

**Test 4: Seasonal Check**
- Plant vegetable out of season → Growth stops (vgrowstate=8)
- Plant in season → Growth continues normally

## Implementation Steps

1. **Make backup**: `git checkout -b phase-9-soil-integration`

2. **Edit plant.dm - PickV() function**
   - Find line ~805 where "You Finish working the [VegeType]..." message appears
   - Replace with soil-aware version
   - Test build

3. **Edit plant.dm - PickG() function**
   - Same changes for grain (line ~1143)
   - Test build

4. **Edit plant.dm - Vegetable Grow()**
   - Find line ~826 `var/randomvalue = rand(240,840)`
   - Replace spawn logic
   - Test build

5. **Edit plant.dm - Grain Grow()**
   - Find line ~1171 `var/randomvalue = rand(840,1240)`
   - Replace spawn logic
   - Test build

6. **Test all changes**
   - Plant crops in different seasons
   - Harvest crops with different soil types
   - Verify growth speeds differ
   - Verify harvest amounts differ

## Expected Results After Integration

### Harvest Quantity Example
- Base harvest: 1 item
- Basic soil: 1 item
- Rich soil: 1.2 items → 1 item (rounds down, but with multiple harvests builds up)
- Depleted soil: 0.5 items → 1 item (minimum)

### Growth Speed Example
- Vegetables: normally 240-840 ticks
  - Basic soil: 240-840 ticks
  - Rich soil: 209-731 ticks (15% faster)
  - Depleted soil: 400-1400 ticks (40% slower)

- Grains: normally 840-1240 ticks
  - Basic soil: 840-1240 ticks
  - Rich soil: 731-1078 ticks (15% faster)
  - Depleted soil: 1400-2067 ticks (40% slower)

### Player Experience
- Farming in rich soil is visibly more rewarding (more items, faster growth)
- Out-of-season farming is blocked by seasonal check
- Players get feedback: "Rich soil has greatly improved the harvest!"
- Strategic choice: Find good soil for farming locations

## Future Enhancements

### Phase 10: Soil Variable on Turfs
When turfs have `soil_type` variable:
```dm
var/soil_type = SOIL_BASIC  // Current
// Becomes:
var/soil_type = loc.soil_type  // Get from location
```

### Phase 11+: Soil Degradation
Track fertility on turfs, deplete with use, restore with compost

## Notes

- The soil system is designed to be transparent - just change one line to get soil_type
- All functions already accept soil_type parameter
- No changes needed to ConsumptionManager, SoilSystem, or other files
- Only plant.dm changes required

## Support

If stuck:
- See SOIL_SYSTEM_INTEGRATION_GUIDE.md for code examples
- See SOIL_QUALITY_SYSTEM.md for complete soil mechanics
- See FARMING_ECOSYSTEM_ARCHITECTURE.md for system overview
