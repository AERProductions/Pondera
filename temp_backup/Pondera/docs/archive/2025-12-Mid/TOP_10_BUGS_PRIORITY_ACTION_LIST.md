# 🎯 TOP 10 BUGS & UNFINISHED SYSTEMS - PRIORITY ACTION LIST

**Updated**: December 16, 2025  
**Build Status**: ✅ CLEAN (0 errors)  
**Audit Status**: ✅ COMPLETE (349 files scanned)

---

## 🔴 TIER 1: CRITICAL (Must Fix This Session)

### BUG #1: Smelting System is Completely Stubbed
**Severity**: 🔴 CRITICAL  
**Impact**: Smelting recipes cannot be unlocked or executed  
**Location**: `dm/TerrainStubs.dm` lines 86-136

**Evidence**:
```dm
proc/smeltingunlock()
	// STUB - Implement full recipe unlock logic
	return

proc/smeltinglevel()
	// Returns player's smelting level
	// STUB - Implement full smelting system
	return 0
```

**What's Missing**:
- [ ] Real level lookup from player character data
- [ ] Recipe unlock mechanism
- [ ] Smelting formula/crafting logic
- [ ] Output item creation

**Quick Fix** (30 min): Look up actual smelting implementation from elsewhere in codebase or create minimal functional version that reads from UnifiedRankSystem.

**Files to Check**:
- `dm/UnifiedRankSystem.dm` - Check if `RANK_SMELTING` exists
- `dm/CookingSystem.dm` - Use as reference for skill-based systems
- `dm/SmithingRecipes.dm` - Check if smelting handled there

---

### BUG #2: Economy Zone Detection Returns Null
**Severity**: 🔴 CRITICAL  
**Impact**: Kingdom-based pricing not working; economy system broken  
**Location**: `dm/AdvancedEconomySystem.dm` line 186

**Evidence**:
```dm
// TODO: Implement zone-based kingdom detection
return null  // Currently returns null for zone queries
```

**What's Missing**:
- [ ] Player position → zone lookup
- [ ] Zone → kingdom mapping
- [ ] Multi-kingdom price adjustment
- [ ] Supply/demand calculation per kingdom

**Quick Fix** (45 min): Create basic zone detector that:
1. Gets player's current z-level
2. Maps z-level to continent
3. Returns continent as kingdom
4. Use for base pricing

**Depends On**:
- `MultiWorldConfig.dm` - Continent definitions exist
- Player position tracking - Already working

---

### BUG #3: PvP Flagging Not Implemented
**Severity**: 🔴 CRITICAL  
**Impact**: PvP combat cannot distinguish friendly vs hostile  
**Location**: `dm/CombatSystem.dm` line 96

**Evidence**:
```dm
// TODO: Implement faction/PvP flagging system
// Currently can't distinguish PvP from PvE zones
```

**What's Missing**:
- [ ] PvP flag on player when in PvP zone
- [ ] Faction assignment system
- [ ] Friendly fire checks
- [ ] War declaration system

**Quick Fix** (1 hour): 
1. Add `pvp_flagged` var to `/mob/players`
2. Set in LoginGateway based on continent
3. Check in combat before allowing damage
4. Add admin commands to test

**Depends On**:
- `MultiWorldIntegration.dm` - Zone detection
- `CombatSystem.dm` - Combat flow already has hooks

---

## 🟠 TIER 2: HIGH PRIORITY (Next Session)

### BUG #4: Animal Husbandry System is Stub
**Severity**: 🟠 HIGH  
**Impact**: Animals can't be owned or produce items  
**Location**: `dm/AnimalHusbandrySystem.dm` line 131

**Evidence**:
```dm
// TODO: Implement animal ownership tracking and produce creation
// Currently has no owner/produce systems
```

**Status**: 0% implemented

**Quick Fix** (1.5 hours):
1. Create `/datum/animal_ownership` to track owner
2. Add `owner` var to animal mobs
3. Create produce generation loop
4. Link to player inventory

---

### BUG #5: Quest Chain Prerequisites Not Validated
**Severity**: 🟠 HIGH  
**Impact**: Players can start quests in wrong order  
**Location**: `dm/AdvancedQuestChainSystem.dm` line 103

**Evidence**:
```dm
// TODO: Implement prerequisite checking logic
// No validation before quest start
```

**Status**: 20% implemented (chain structure exists, validation missing)

**Quick Fix** (45 min):
1. Add prerequisite check before quest acceptance
2. Return error message if not ready
3. Track completion in player data
4. Add admin test command

---

### BUG #6: Anvil Crafting Unlinked from Systems
**Severity**: 🟠 HIGH  
**Impact**: Crafting doesn't consume stamina or inventory  
**Location**: `dm/AnvilCraftingSystem.dm` lines 104-111

**Evidence**:
```dm
// TODO: Link to actual stamina system
// TODO: Link to actual inventory system
// Currently runs in isolation
```

**Status**: 60% implemented (crafting works, but no cost)

**Quick Fix** (1 hour):
1. Hook to `HungerThirstSystem` for stamina drain
2. Consume ingredients from inventory
3. Create output item in inventory
4. Test with craft command

---

### BUG #7: Kingdom Treasury Kingdom Detection Broken
**Severity**: 🟠 HIGH  
**Impact**: Treasury can't determine which kingdom player belongs to  
**Location**: `dm/KingdomTreasurySystem.dm` lines 311, 323

**Evidence**:
```dm
var/kingdom = "story"  // TODO: Determine player's kingdom
// Hardcoded to "story" - doesn't detect real kingdom
```

**Occurs**: Multiple places (2x in file)

**Quick Fix** (30 min):
1. Create helper proc `GetPlayerKingdom(mob/player)`
2. Check player's continent
3. Return appropriate kingdom name
4. Replace hardcoded "story" with function call

---

## 🟡 TIER 3: MEDIUM PRIORITY (This Week)

### BUG #8: Recipe Discovery UI Incomplete
**Severity**: 🟡 MEDIUM  
**Impact**: Players see placeholder "TODO: Build UI" messages  
**Location**: `dm/RecipeExperimentationSystem.dm` lines 195, 208-209

**Status**: 30% implemented

**Quick Fix** (2 hours):
1. Create HTML recipe selection interface
2. Add ingredient selection checkboxes
3. Validate combination before submit
4. Return success/failure feedback

---

### BUG #9: NPC Recipe Teaching Missing HUD Integration
**Severity**: 🟡 MEDIUM  
**Impact**: NPCs can't teach recipes via HUD  
**Location**: `dm/NPCCharacterIntegration.dm` line 412

**Evidence**:
```dm
// TODO: Implement HUD-based recipe selection (Phase 0.5c)
```

**Status**: 40% implemented (NPC system exists, HUD missing)

**Quick Fix** (1.5 hours):
1. Create recipe browser HUD screen
2. Filter by NPC's teachable recipes
3. Add learn button
4. Call `UnlockRecipeFromNPC()`

---

### BUG #10: Particle/Visual Effects Missing
**Severity**: 🟡 MEDIUM  
**Impact**: Crafting animations not visible  
**Location**: `dm/ExperimentationWorkstations.dm` lines 259-261

**Status**: 10% implemented

**Quick Fix** (2 hours):
1. Create particle effect objects
2. Spawn on anvil during craft
3. Link to audio system for sound feedback
4. Clean up after animation ends

---

## 📊 Issue Summary Table

| # | Bug | System | Severity | Status | Est. Fix |
|---|-----|--------|----------|--------|----------|
| 1 | Smelting stub | TerrainStubs | 🔴 CRITICAL | 0% | 30m |
| 2 | Zone detection null | Economy | 🔴 CRITICAL | 20% | 45m |
| 3 | PvP flagging missing | Combat | 🔴 CRITICAL | 0% | 1h |
| 4 | Animal ownership stub | Husbandry | 🟠 HIGH | 0% | 1.5h |
| 5 | Quest prerequisites | Quests | 🟠 HIGH | 20% | 45m |
| 6 | Anvil unlinked | Crafting | 🟠 HIGH | 60% | 1h |
| 7 | Kingdom detect hardcoded | Economy | 🟠 HIGH | 30% | 30m |
| 8 | Recipe UI incomplete | Experimentation | 🟡 MEDIUM | 30% | 2h |
| 9 | NPC teaching HUD missing | NPCs | 🟡 MEDIUM | 40% | 1.5h |
| 10 | Particle effects missing | VFX | 🟡 MEDIUM | 10% | 2h |

---

## 🛠️ Recommended Attack Order

### This Session (3 hours)
1. ✅ Fix CharacterCreationUI.dm - DONE
2. Fix Smelting stub (30 min) → 1 proc call to UnifiedRankSystem
3. Fix Zone detection (45 min) → Add MultiWorld lookup
4. Fix PvP flagging (1 hour) → Add flag + combat check

**Result**: All TIER 1 critical bugs fixed

### Next Session (3-4 hours)
5. Fix Animal ownership (1.5 hours)
6. Fix Quest prerequisites (45 min)
7. Fix Anvil linking (1 hour)

**Result**: All TIER 2 high priority bugs fixed

### Third Session (4 hours)
8. Fix Kingdom detection (30 min)
9. Build Recipe UI (2 hours)
10. Build NPC HUD (1.5 hours)

**Result**: TIER 3 medium priority mostly complete

---

## 🚀 How to Use This List

### Option A: Sequential Fixing (Recommended)
1. Pick #1 from TIER 1
2. Find the file and line
3. Implement the fix
4. Rebuild and test
5. Move to next bug

### Option B: System Cleanup
1. Pick one system (e.g., "Economy")
2. Fix all bugs in that system
3. Fully test that system
4. Move to next system

### Option C: Impact-Driven
1. Fix bugs affecting most players first
2. Smelting → Economy → PvP → NPCs → UI/Polish
3. Prioritize multiplayer/core gameplay

---

## 🔗 Related Documents

- `CODEBASE_AUDIT_COMPREHENSIVE_12_16_25.md` - Full audit findings
- `/Engineering/Codebase-Audit-Status.md` - Obsidian brain notes
- `Pondera.dme` - Build manifest (FIXED: line 44 removed)

---

## 📈 Expected Outcome

**After All Fixes**:
- ✅ Build: 0 errors (already achieved)
- ✅ Runtime: World initializes cleanly
- ✅ Player login: No UI conflicts
- ✅ Economy: Zone-based pricing works
- ✅ Combat: PvP/PvE properly flagged
- ✅ Crafting: Stamina/inventory integrated
- ✅ NPCs: Can teach recipes via HUD

**Estimated Total Time**: 10-12 hours spread over 3 sessions

---

**Last Updated**: 2025-12-16 20:50 UTC  
**Ready to Start**: YES - All TIER 1 issues identified and documented
