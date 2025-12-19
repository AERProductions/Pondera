# Codebase Audit - December 8, 2025

**Scope**: Complete inventory of unfinished work, integration gaps, and connection opportunities  
**Method**: Grep for TODO/FIXME + semantic analysis of system interdependencies  
**Status**: COMPREHENSIVE FINDINGS WITH ACTIONABLE RECOMMENDATIONS

---

## CRITICAL FINDINGS

### 1. **Unfinished Persistence Layer** ⚠️

**Location**: `dm/DeedDataManager.dm` (lines 387, 527, 537)

```dm
// INCOMPLETE:
proc/UpdateDeedBounds()
	// TODO: Re-create deed region with new bounds

proc/SaveDeedRegistry()
	// TODO: Implement binary savefile for deed registry

proc/LoadDeedRegistry()
	// TODO: Implement binary savefile loading for deed registry
```

**Impact**: Deed changes aren't saved to disk
**Severity**: HIGH - Economy system data loss risk
**Fix Time**: 1-2 hours
**Recommendation**: IMPLEMENT IMMEDIATELY - blocks deed sales/transfers

---

### 2. **Incomplete Food Quality Calculations** ⚠️

**Locations**: 
- `dm/CookingSystem.dm` (lines 328, 429)
- PHASE_9_PLANT_INTEGRATION_DETAILED.md (lines 38, 95, 141, 171)

```dm
// INCOMPLETE:
var/skill_rank = 1  // TODO: Get from chef's culinary skill
var/soil_type = SOIL_BASIC  // TODO: Get from loc.soil_type
```

**Impact**: 
- Soil quality bonuses not applied to harvests
- Chef skill bonuses not applied to meals
**Severity**: MEDIUM - Affects gameplay progression
**Fix Time**: 30 minutes (integrate with CookingSkillProgression & SoilSystem)
**Recommendation**: CONNECT THESE NOW - 3-line fixes

---

### 3. **Deed Economy Incomplete** ⚠️

**Location**: `dm/DeedEconomySystem.dm` (lines 136, 389-392, 474-517)

```dm
// INCOMPLETE:
proc/CalculateDeedValue()
	// TODO: Add area calculation
	// TODO: Add location-based multiplier (biome, proximity to towns)
	// TODO: Add demand multiplier (high-traffic areas)
	// TODO: Adjust based on recent transaction prices

// NO NOTIFICATIONS:
// TODO: Implement player notification system (5 instances)
```

**Impact**: 
- Deed pricing is fixed, not dynamic
- Players don't know when offers expire or status changes
**Severity**: MEDIUM - Reduces economic gameplay depth
**Fix Time**: 2-3 hours
**Recommendation**: Connect with TreasuryUISystem for notifications

---

### 4. **Kingdom Material Exchange Placeholder** ⚠️

**Location**: `dm/KingdomMaterialExchange.dm` (line 407)

```dm
proc/AdjustMarketPrices()
	// TODO: Adjust prices based on supply changes
```

**Impact**: Kingdom trade prices are static
**Severity**: LOW - Works, just not dynamic
**Fix Time**: 1 hour
**Recommendation**: DEFER - nice-to-have feature

---

### 5. **Weather System Incomplete** ⚠️

**Location**: `dm/WeatherParticles.dm` (lines 243, 272)

```dm
// Lightning integration: TODO - implement in later phase
// TODO: Use for future fog intensity effects
```

**Impact**: Lightning weather affects aren't visual yet
**Severity**: LOW - Cosmetic
**Fix Time**: 2-3 hours
**Recommendation**: DEFER - Phase 15+

---

### 6. **Sound System Corrupted** ⚠️

**Location**: `dm/SoundEngine.dm` (line 239-247)

```dm
/*
 * _MusicEngine() - DISABLED: Corrupted proc body
 * TODO: Restore full implementation
 */
/*
proc/_MusicEngine(...)
    return S
*/
```

**Impact**: Music engine disabled/broken
**Severity**: MEDIUM - Music doesn't work properly
**Fix Time**: 1-2 hours (restore from history or rebuild)
**Recommendation**: INVESTIGATE & RESTORE

---

## INTEGRATION GAPS (Ready to Connect)

### Gap 1: Soil Quality → Harvesting

**Systems**: SoilSystem.dm + plant.dm + CookingSystem.dm

**Current State**:
- ✅ SoilSystem tracks soil types (DEPLETED, BASIC, RICH)
- ❌ plant.dm harvest functions ignore soil type
- ❌ Cooked meals don't incorporate soil quality

**Fix**:
```dm
// In plant.dm PickV() / PickG():
var/soil_type = loc.soil_type || SOIL_BASIC  // Get from turf
var/yield_mult = GetSoilYieldModifier(soil_type)
for(var/i = 1; i <= round(yield_mult * base_yield); i++)
    new /obj/food/vegetable(usr)

// In CookingSystem.dm:
final_quality *= GetSoilModifier(recipe_ingredients)  // Check ingredient quality
```

**Time**: 30 minutes  
**Priority**: HIGH - Completes farm-to-table pipeline

---

### Gap 2: Cooking Skill → Meal Quality

**Systems**: CookingSkillProgression.dm + CookingSystem.dm

**Current State**:
- ✅ CookingSkillProgression has quality multiplier (0.6x to 1.8x)
- ❌ CookingSystem hardcodes skill_rank = 1
- ❌ Quality bonus not applied to meals

**Fix**:
```dm
// In CookingSystem.dm FinishCooking():
var/skill_mult = ApplyCookingSkillBonus(chef, base_quality)
final_quality *= skill_mult

// Also: Replace hardcoded skill_rank = 1 with:
var/skill_rank = GetCookingSkillRank(chef)
```

**Time**: 15 minutes  
**Priority**: HIGH - Skill progression affects gameplay

---

### Gap 3: Deed Economy → Player Notifications

**Systems**: DeedEconomySystem.dm + TreasuryUISystem.dm

**Current State**:
- ✅ Deed economy calculates offers/prices
- ❌ 5 TODO stubs for player notifications
- ❌ No UI integration for deed transactions

**Fix**:
```dm
// In DeedEconomySystem.dm:
proc/NotifyPlayerOfDeedEvent(mob/players/M, event_type, deed_name, details)
	if(!TreasuryUISystem)
		world.log << "ERROR: TreasuryUISystem not initialized"
		return
	
	var/message = BuildNotificationMessage(event_type, deed_name, details)
	M << message
	// Also send to Treasury if available
	TreasuryUISystem.AddTransaction(M, message)
```

**Time**: 1-2 hours  
**Priority**: MEDIUM - Improves player experience

---

### Gap 4: Town System → World Integration

**Systems**: TownIntegration.dm + WorldSelection.dm + StoryWorldIntegration.dm

**Current State**:
- ✅ TownIntegration.dm has town discovery system
- ✅ TownData.dm creates town objects
- ❌ 3 TODO stubs for kingdom linkage
- ❌ Not connected to multi-world system

**Fixes Needed**:
```dm
// In TownIntegration.dm (lines 242, 267, 274):
// TODO: Link towns with world_system kingdoms
// TODO: Save town state to P.save_data
// TODO: Restore town discovery state from P.save_data

// When available:
if(world_system && world_system.current_kingdom)
	town.kingdom_id = world_system.current_kingdom.id
```

**Time**: 2-3 hours  
**Priority**: MEDIUM - Needed for faction gameplay

---

### Gap 5: Item Inspection → Recipe/Skill Systems

**Location**: `dm/ItemInspectionSystem.dm` (lines 301, 325, 334, 383, 387)

**Current State**:
- ✅ ItemInspectionSystem has framework
- ❌ 5 TODO stubs for system connections

**Fixes Needed**:
```dm
// Line 301:
// TODO: Connect to actual stat system
GetItemStats(item) -> check RecipeState, SkillManager

// Line 325:
// TODO: Connect to actual experience system
GetPlayerProgression() -> check character.recipe_state

// Line 334:
// TODO: Connect to actual recipe database
GetRecipeInfo() -> check RECIPES global

// Lines 383, 387:
// TODO: Track inspection history
// Requires player inspection log in character savefile
```

**Time**: 2-3 hours  
**Priority**: MEDIUM - Polish feature

---

## ORPHANED/DEAD CODE

### 1. CustomUI_old.dm
- **Status**: DEAD - 500+ lines of old UI framework
- **Action**: DELETE - not used, replaced by newer systems
- **Impact**: None (commented out, not loaded)

### 2. SoundEngine.dm (Music Engine)
- **Status**: HALF-DEAD - `_MusicEngine()` corrupted/disabled
- **Action**: RESTORE or DELETE section
- **Impact**: Music playback may be broken
- **Note**: Check if used by MusicSystem.dm

### 3. jb.dm (Building System)
- **Status**: ANCIENT - 4000+ lines, mostly working but poor organization
- **Action**: REFACTOR (not urgent) - works but unreadable
- **Impact**: Hard to maintain
- **Note**: Consider splitting into smaller files (Phase 15+)

### 4. WC.dm (Ueik Tree System)
- **Status**: LEGACY - 1000+ lines of tree growth logic
- **Action**: WORKS, but could use organization review
- **Impact**: Plant system functional
- **Note**: Growth stages are complex but stable

---

## MISSING BUT DESIGNED SYSTEMS

### 1. Recipe Experimentation
- **Status**: Framework ready, no UI
- **File**: Comments in COMPLETE_FOOD_ECOSYSTEM_GUIDE.md
- **Need**: AttemptRecipeExperimentation() to show UI
- **Time**: Phase 13 (2-3 hours)

### 2. Forge UI Directional Sensitivity
- **Status**: Noted as incomplete
- **File**: dm/ForgeUIIntegration.dm
- **Issue**: Overlays don't respect player direction
- **Time**: 1-2 hours

### 3. Weapon Part Combining
- **Status**: System incomplete
- **File**: dm/Objects.dm (smithing system)
- **Issue**: Combining weapon parts not fully implemented
- **Time**: 2-3 hours

---

## ARCHITECTURAL ISSUES

### Issue 1: Scattered Initialization (15+ InitializationManager calls)

**Problem**: World init code split across multiple files:
- InitializationManager.dm (primary)
- Phase4Integration.dm (recipe init)
- CookingSkillProgression.dm (cooking init)
- SoilSystem.dm (soil init)
- CookingSystem.dm (cooking init)
- WeatherParticles.dm (weather init)
- And more...

**Impact**: Hard to verify init order, possible race conditions

**Fix**: Centralize all inits in InitializationManager
- Call other InitializeXxx() from world/New()
- Guarantee dependency order
- Time: 1 hour

---

### Issue 2: Skill System Not Fully Integrated

**Problem**: Multiple skill systems exist:
- SkillRecipeUnlock.dm (recipe unlocks by rank)
- CookingSkillProgression.dm (cooking-specific)
- Old hardcoded skill vars in mob/players

**Impact**: Inconsistent progression, possible conflicts

**Fix**: Create SkillManager.dm that unifies all systems
- Time: 2-3 hours (nice-to-have)

---

### Issue 3: NPC Recipe Teaching Incomplete

**Location**: NPC_RECIPE_INTEGRATION_PLAN.md

**Issue**: 
- Line 116: `if(req_skill > 0)  // TODO: determine which skill applies`
- Line 127: `return TRUE  // TODO`

**Status**: Design doc exists, implementation incomplete

**Fix**: Finish NPC teaching system integration
- Time: 2-3 hours

---

## QUICK WINS (Easy Fixes)

| Fix | File | Lines | Time | Impact |
|-----|------|-------|------|--------|
| Use soil quality in harvest | plant.dm | 804, 1154 | 15m | HIGH |
| Use chef skill in cooking | CookingSystem.dm | 328, 429 | 15m | HIGH |
| Add deed notifications | DeedEconomySystem.dm | 474-517 | 1h | MED |
| Restore sound system | SoundEngine.dm | 239-247 | 1h | MED |
| Delete dead code | CustomUI_old.dm | All | 5m | LOW |
| Verify town→kingdom links | TownIntegration.dm | 242, 267, 274 | 30m | MED |
| **TOTAL** | | | **~4 hours** | |

---

## CONNECTION OPPORTUNITIES

### 1. **Deed Economy ↔ Treasury System**
- DeedEconomySystem calculates prices
- TreasuryUISystem displays transactions
- **Action**: Connect seller notification to Treasury UI
- **Time**: 1 hour
- **Priority**: HIGH

### 2. **Soil Quality ↔ Food Quality ↔ Skill**
- SoilSystem affects harvest
- Harvest affects meal base quality
- Skill affects final quality
- **Action**: Chain these 3 systems
- **Time**: 1 hour
- **Priority**: HIGH

### 3. **NPC Teaching ↔ Recipe Discovery**
- NPCs should teach cooking recipes
- Recipe discovery should track this
- **Action**: Implement NPC teaching for cooking
- **Time**: 2 hours
- **Priority**: MEDIUM

### 4. **Item Inspection ↔ Recipe Browser**
- Players inspect items to learn recipes
- Should show recipes that use this item
- **Action**: Add recipe filtering to ItemInspectionSystem
- **Time**: 1.5 hours
- **Priority**: LOW (nice-to-have)

---

## RISK ASSESSMENT

### HIGH RISK (Data Loss Potential)
1. ⚠️ Deed persistence not implemented (DeedDataManager)
2. ⚠️ Economy system values not persistent
3. ⚠️ Sound system corrupted

### MEDIUM RISK (Gameplay Issues)
1. ⚠️ Soil quality not affecting harvests
2. ⚠️ Chef skill not affecting meals
3. ⚠️ Deed notifications missing

### LOW RISK (Polish/Nice-to-Have)
1. ⚠️ Weather lightning effects missing
2. ⚠️ Weapon combining incomplete
3. ⚠️ Inspection system not connected

---

## BUILD STATUS

**Current**: ✅ 0 errors, 2 warnings (pre-existing)

**After Fixes**: Should remain 0 errors (no code changes needed, just completions)

---

## RECOMMENDED ACTION PLAN

### Phase A: CRITICAL (Today)
1. ✅ Implement deed persistence (DeedDataManager)
2. ✅ Connect soil quality to harvesting
3. ✅ Connect skill to meal cooking
4. **Time**: 2-3 hours

### Phase B: IMPORTANT (This Week)
1. Add deed notifications (DeedEconomySystem)
2. Investigate sound system corruption
3. Verify town→kingdom integration points
4. **Time**: 2-3 hours

### Phase C: NICE-TO-HAVE (Next Phase)
1. Create unified SkillManager
2. Implement recipe experimentation UI
3. Add item inspection recipe filtering
4. **Time**: 5-6 hours

### Phase D: CLEANUP (Later)
1. Delete CustomUI_old.dm
2. Refactor jb.dm into modules
3. Extract weather system
4. **Time**: 4-5 hours

---

## SUMMARY

**Total Unfinished Work**: ~15-18 hours
- **Critical (blocking)**: 2-3 hours
- **Important (should do)**: 2-3 hours
- **Nice-to-have (optional)**: 5-6 hours
- **Cleanup (refactoring)**: 4-5 hours

**Recommendation**: Focus on Phase A (3 quick wins), then Phase B if time permits. Phase C/D are optional improvements.

**Next Step**: Execute quick wins to unblock deed economy and complete farm-to-table pipeline.
