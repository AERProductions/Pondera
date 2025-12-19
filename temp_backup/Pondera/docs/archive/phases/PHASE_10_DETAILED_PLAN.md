# Phase 10: Combat System Consolidation
## Three-Continent Combat Architecture

**Goal**: Unify combat mechanics across Story, Sandbox, and PvP continents with intelligent continent-aware gating.

**Approach**: Consolidate UnifiedAttackSystem + s_damage2.dm + PvPSystem into one extensible combat framework that respects continent rules.

---

## Architecture Overview

### Design Principle: Compartmentalized Combat

Each continent has distinct combat rules:

```
STORY (Kingdom of Freedom)
├── PvE Combat: Player vs Enemies (enabled)
├── PvP Combat: Disabled by default
├── Kingdom Wars: Enabled (players side with story factions)
│   └── Story factions: Kingdom of Freedom, Kingdom of Greed, neutrals
├── NPC Interactions: Combat-enabled (guards, enemies)
└── Mechanics: Standard damage, armor, hit chance, stamina

SANDBOX (Creative Sandbox)
├── PvE Combat: Disabled
├── PvP Combat: Disabled
├── Kingdom Wars: Disabled (no conflict)
├── NPC Interactions: Peaceful only
└── Mechanics: No damage, no combat flow

PVP (Battlelands)
├── PvE Combat: Enabled (monsters, enemies)
├── PvP Combat: Enabled (full combat)
├── Kingdom Wars: Enabled (player-made kingdoms declare war)
│   └── Player kingdoms: Alpha, Bravo, Omega factions, etc.
├── NPC Interactions: Limited (raiders, mercenaries)
└── Mechanics: Full damage, armor, special moves, stamina drain
```

### Global Combat System Architecture

```
CombatSystem.dm (NEW - 450+ lines)
├── proc/CanEnterCombat(player, defender) → Boolean
│   └── Checks continent rules + player status + PvP flags
├── proc/ResolveAttack(attacker, defender, attack_type) → Result
│   └── Uses UnifiedAttackSystem foundation + continent-aware logic
├── proc/CalcDamage(attacker, defender, base_damage, continent) → Damage
│   └── Damage scaling per continent
├── proc/HandleDefenderDeath(attacker, defender, continent) → Void
│   └── Different outcomes per continent (respawn, loot, karma, etc.)
└── Combat Event Logging (tied to MarketAnalytics.dm)
    └── Track PvP abuse, kills, deaths per continent

UnifiedAttackSystem.dm (REFACTORED - remove continent logic)
├── Low-level attack resolution
├── Damage calculation (cleaned up)
├── Hit chance & evasion
└── Stamina/mana cost (unified)

s_damage2.dm (DEPRECATED in favor of unified system)
├── Keep for backward compatibility
└── Route through CombatSystem.dm

PvPSystem.dm (INTEGRATED with combat)
├── Territory claims + combat integration
├── Raid mechanics use CombatSystem.ResolveAttack
├── Kingdom war triggers via combat
└── Combat progression (ranks, kills, deaths)
```

---

## Detailed Implementation Plan

### Phase 10a: Combat System Foundation (Day 1)
**Goal**: Create unified CombatSystem.dm with continent gating

#### Task 1: Create CombatSystem.dm (200 lines)
```dm
/proc/CanEnterCombat(mob/players/attacker, mob/defender)
	// Gate 1: Check if attacker is alive
	if(attacker.HP <= 0)
		attacker << "You're dead."
		return FALSE
	
	// Gate 2: Check if defender exists and is alive
	if(!defender || (istype(defender, /mob/players) && defender:HP <= 0))
		return FALSE
	
	// Gate 3: Check elevation range (always required)
	if(!attacker.Chk_LevelRange(defender))
		attacker << "Target is at different elevation."
		return FALSE
	
	// Gate 4: Check continent rules
	var/current_continent = attacker.character.current_continent
	
	switch(current_continent)
		if(CONT_STORY)
			return CanEnterCombat_Story(attacker, defender)
		if(CONT_SANDBOX)
			return CanEnterCombat_Sandbox(attacker, defender)
		if(CONT_PVP)
			return CanEnterCombat_PvP(attacker, defender)
	
	return FALSE

/proc/CanEnterCombat_Story(mob/players/attacker, mob/defender)
	// Story: Allow PvE (player vs enemy), PvP if explicitly flagged
	
	// Always allow attacking enemies
	if(!istype(defender, /mob/players))
		return TRUE  // Player can attack NPC/enemy
	
	// For player vs player: check if both flagged for PvP
	var/mob/players/P = defender
	
	// TODO: Implement faction alliance check (Kingdom of Freedom vs Kingdom of Greed)
	// For now: require both players to be flagged for PvP
	if(!attacker.pvp_enabled || !P.pvp_enabled)
		attacker << "[P.name] is not flagged for PvP."
		return FALSE
	
	return TRUE

/proc/CanEnterCombat_Sandbox(mob/players/attacker, mob/defender)
	// Sandbox: No combat at all
	attacker << "Combat is disabled in Sandbox mode."
	return FALSE

/proc/CanEnterCombat_PvP(mob/players/attacker, mob/defender)
	// PvP: All combat allowed (PvE always, PvP always)
	return TRUE

/proc/ResolveAttack(mob/players/attacker, mob/defender, attack_type = "physical")
	// NEW: Continent-aware wrapper around combat
	
	// Check if combat is allowed first
	if(!CanEnterCombat(attacker, defender))
		return FALSE
	
	// Delegate to UnifiedAttackSystem (refactored)
	return UnifiedAttackSystem::ResolveAttack(attacker, defender, attack_type)

/proc/CalcDamageForContinent(mob/players/attacker, mob/defender, base_damage)
	// Continent-aware damage scaling
	var/current_continent = attacker.character.current_continent
	var/damage_scalar = 1.0
	
	switch(current_continent)
		if(CONT_STORY)
			// Story mode: Normal damage (no scaling)
			damage_scalar = 1.0
		if(CONT_SANDBOX)
			// Sandbox: N/A (no combat)
			return 0
		if(CONT_PVP)
			// PvP: Damage bonuses for combat engagement
			// Higher combat level = more damage
			if(istype(attacker, /mob/players))
				var/combat_bonus = (attacker.character.GetRankLevel(RANK_COMBAT) * 0.05)
				damage_scalar = 1.0 + combat_bonus
	
	return round(base_damage * damage_scalar)
```

**Files Created:**
- `dm/CombatSystem.dm` (200 lines)

**Files to Modify:**
- `Pondera.dme` (add CombatSystem.dm BEFORE UnifiedAttackSystem.dm)

---

### Phase 10b: Refactor UnifiedAttackSystem (Day 1)
**Goal**: Remove continent logic from UnifiedAttackSystem, keep core combat

#### Task 2: Clean UnifiedAttackSystem.dm (260 → 220 lines)
- Remove continent checks (moved to CombatSystem)
- Remove CanEnterCombat logic (moved to CombatSystem)
- Keep: damage calculation, hit chance, stamina cost, death handling
- Add: damage logging to MarketAnalytics (combat audit trail)

**Key Changes:**
```dm
// OLD - Remove this:
if(!attacker.Chk_LevelRange(defender))
	return FALSE  // This now checked in CombatSystem

// OLD - Remove this:
if(!CheckSpecialConditions(attacker, defender))
	return FALSE  // This now checked in CombatSystem

// NEW - Add this logging:
if(istype(attacker, /mob/players) && istype(defender, /mob/players))
	var/combat_log = "COMBAT: [attacker.name] attacked [defender.name] - Damage: [final_damage] - Continent: [attacker.character.current_continent]"
	if(!combat_log_history) combat_log_history = list()
	combat_log_history += list(list("timestamp" = world.time, "log" = combat_log))
```

---

### Phase 10c: Deprecate s_damage2.dm (Day 1)
**Goal**: Keep file for compatibility, but route through new system

#### Task 3: Add deprecation wrapper to s_damage2.dm
```dm
// s_damage2.dm is now deprecated in favor of CombatSystem.dm
// This file is kept for backward compatibility only.
// All new damage calls should use:
//   CombatSystem::ResolveAttack(attacker, defender, attack_type)
// 
// Legacy s_damage() calls (for displaying damage numbers) are still
// functional but should be replaced with:
//   DisplayDamageNumber(attacker, damage_amount)
```

Add routing function:
```dm
/proc/s_damage(ref, num, colour = "#FFFFFF")
	// Legacy damage display function
	// Route through new combat system if applicable
	
	if(istype(ref, /mob/players))
		// Display damage number on player
		DisplayDamageNumber(ref, num, colour)
	else if(istype(ref, /mob/enemies))
		// Display damage number on enemy
		DisplayDamageNumber(ref, num, colour)
	else
		// Display on object/turf (neutral display)
		DisplayDamageNumber(ref, num, colour)
```

---

### Phase 10d: Integrate PvPSystem Combat (Day 2)
**Goal**: Make PvPSystem.dm use unified CombatSystem

#### Task 4: Update PvPSystem raid functions
```dm
// OLD PvPSystem raid function:
/proc/CanRaid(mob/attacker)
	// Legacy scatter logic
	...

// NEW PvPSystem raid function:
/proc/CanRaid(mob/players/attacker, mob/defender)
	// Use unified CombatSystem check
	if(!CanEnterCombat(attacker, defender))
		return FALSE
	
	// Additional raid-specific checks:
	// 1. Attacker in territory claim range?
	// 2. Defender territory is vulnerable?
	// 3. Raid window is active?
	...
	return TRUE

/proc/ResolveRaid(mob/players/attacker, obj/DeedToken/defending_deed)
	// Unified raid resolution
	// Uses CombatSystem::ResolveAttack for combat
	
	// Get defender (deed owner or defender NPC)
	var/mob/defender = defending_deed.get_current_defender()
	
	// Check if raid can happen
	if(!CanRaid(attacker, defender))
		return FALSE
	
	// Resolve actual combat
	var/attack_result = ResolveAttack(attacker, defender, "raid")
	
	if(attack_result)
		// Raid succeeded - process deed impacts
		ProcessRaidSuccess(attacker, defending_deed)
		
		// Log raid in analytics
		var/raid_log = "RAID: [attacker.name] raided [defending_deed.owner] - Success"
		combat_raid_log += raid_log
	else
		// Raid failed - log failure
		var/raid_log = "RAID_FAILED: [attacker.name] vs [defending_deed.owner] - Defender won"
		combat_raid_log += raid_log
	
	return attack_result
```

---

### Phase 10e: Combat Logging & Analytics (Day 2)
**Goal**: Tie combat events into MarketAnalytics system

#### Task 5: Add combat logging to MarketAnalytics.dm
```dm
// In MarketAnalytics.dm, add:

var/list/combat_log_history = list()
var/list/pvp_kill_history = list()
var/list/raid_history = list()

/proc/LogCombatEvent(attacker_key, defender_key, damage, attack_type, continent, result)
	if(!combat_log_history) combat_log_history = list()
	
	var/timestamp = world.time
	var/entry = list(
		"timestamp" = timestamp,
		"attacker" = attacker_key,
		"defender" = defender_key,
		"damage" = damage,
		"type" = attack_type,  // "physical", "magic", "raid"
		"continent" = continent,
		"result" = result  // "hit", "miss", "kill"
	)
	
	combat_log_history += entry
	
	// Prune if too large
	if(combat_log_history.len > 10000)
		combat_log_history = combat_log_history[combat_log_history.len - 9999 to combat_log_history.len]

/proc/AnalyzeCombatAbuse(continent_filter = null)
	// Detect griefing patterns, kill farming, etc.
	var/list/abuse_patterns = list()
	
	for(var/entry in combat_log_history)
		// Pattern 1: Repeated kills on same player (griefing)
		// Pattern 2: Kill farming (same attacker, same low-level defender)
		// Pattern 3: AFK farming (repeated combat with NPC while player absent)
		
	return abuse_patterns

/proc/GetCombatStats(filter_continent = null)
	// Return combat statistics per continent
	var/list/stats = list()
	
	for(var/entry in combat_log_history)
		if(filter_continent && entry["continent"] != filter_continent)
			continue
		
		// Aggregate by continent
		stats[entry["continent"]] += 1
	
	return stats
```

---

### Phase 10f: Testing & Validation (Day 2-3)
**Goal**: Ensure combat works correctly per continent

#### Task 6: Create combat test suite
```dm
// In dm/CombatSystemTests.dm (new file - reference only, not compiled):

/proc/TestCombat_Story_PvE()
	// Test: Player can attack NPC in story mode
	// Expected: Attack succeeds, damage applied
	
/proc/TestCombat_Story_PvP()
	// Test: Player vs player in story mode WITHOUT pvp_enabled flag
	// Expected: Attack fails (not flagged for PvP)
	
	// Test: Player vs player in story mode WITH pvp_enabled flag
	// Expected: Attack succeeds (both flagged)

/proc/TestCombat_Sandbox()
	// Test: Player tries to attack anyone in sandbox
	// Expected: Combat disabled message, attack fails

/proc/TestCombat_PvP()
	// Test: Player attacks another player
	// Expected: Attack always succeeds (no gating)

/proc/TestCombat_Logging()
	// Test: Each attack is logged to combat_log_history
	// Expected: Combat logs created + analytics available
```

---

## Implementation Checklist

### Day 1
- [ ] Create CombatSystem.dm with continent gating (200 lines)
- [ ] Refactor UnifiedAttackSystem.dm (remove continent logic)
- [ ] Add deprecation wrapper to s_damage2.dm
- [ ] Update Pondera.dme includes (CombatSystem before UnifiedAttackSystem)
- [ ] Build & verify (target: 0/0)
- [ ] Mark Phase 10a complete

### Day 2
- [ ] Update PvPSystem.dm to use CombatSystem
- [ ] Add combat logging to MarketAnalytics.dm
- [ ] Create combat analysis functions (abuse detection, stats)
- [ ] Update CanRaid / ResolveRaid to use unified system
- [ ] Build & verify (target: 0/0)
- [ ] Mark Phase 10b complete

### Day 3
- [ ] Manual testing per continent
  - Story mode: PvE works ✓
  - Story mode: PvP requires flag ✓
  - Sandbox: No combat ✓
  - PvP: All combat allowed ✓
- [ ] Verify logging (combat_log_history populated)
- [ ] Verify analytics (GetCombatStats works)
- [ ] Git commit Phase 10 complete
- [ ] Documentation & summary

---

## Files Summary

### New Files
- `dm/CombatSystem.dm` (200 lines) - Unified combat with continent gating

### Modified Files
- `dm/UnifiedAttackSystem.dm` (260 → 220 lines) - Remove continent logic, add logging
- `dm/PvPSystem.dm` (369 lines) - Update raid functions to use CombatSystem
- `dm/MarketAnalytics.dm` (226 lines) - Add combat logging & analytics
- `dm/s_damage2.dm` (214 lines) - Add deprecation notice + routing
- `Pondera.dme` - Update includes (add CombatSystem.dm)

### Reference/Testing (not compiled)
- `dm/CombatSystemTests.dm` - Test suite documentation

---

## Design Decisions

### Why Separate CombatSystem.dm?
- Keeps continent gating logic centralized (easier to modify rules)
- UnifiedAttackSystem stays as low-level mechanics (reusable)
- PvPSystem can focus on territory, not combat logic
- New features (Kingdom Wars) can hook into combat easily

### Why Deprecate s_damage2.dm Instead of Delete?
- Backward compatibility (other code might reference it)
- Routing preserves existing functionality
- Clear migration path for future refactors

### Why Log Combat to MarketAnalytics?
- Unified abuse detection system
- Admin can see PvP grief patterns + market fraud patterns together
- Same infrastructure (log pruning, admin tools, exports)

### Why Continent Flags (pvp_enabled)?
- Players control their combat exposure
- Prevents unwanted PvP even on PvP continent
- Works with Kingdom Wars (can "join a faction" = enable PvP for that faction)

---

## Future Integration Points (Post-Phase 10)

Once combat is unified, Phase 11-12 can easily add:

1. **Advanced Combat Features** (Phase 11)
   - Special moves / combo system
   - Armor/weapon proficiency modifiers
   - Status effects (poison, stun, bleed)

2. **Kingdom Wars** (Phase 11-12)
   - Faction reputation system
   - Territory siege mechanics
   - Alliance warfare

3. **Combat Progression** (Phase 12)
   - Combat skill ranking (RANK_COMBAT)
   - Kill achievements
   - Legendary weapons/armor

4. **Economy Integration** (Phase 12)
   - Repair costs from battle damage
   - Healing item consumption
   - War bonds / faction treasury

---

## Estimated Effort
- **Days**: 2-3 days total
- **Commits**: 2-3 commits (foundation, integration, completion)
- **Lines Added**: 450-500 total
- **Testing**: 4-5 test scenarios per continent
- **Build Target**: 0 errors, 0 warnings

Ready to proceed with Phase 10?

