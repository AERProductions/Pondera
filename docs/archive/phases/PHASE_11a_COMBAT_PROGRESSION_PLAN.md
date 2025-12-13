# Phase 11a: Combat Progression System

## Objective
Implement combat rank progression so players improve at fighting through practice, creating a meaningful progression hook and making combat feel rewarding.

---

## Design Overview

### Core Concept
- Players earn **Combat XP** from every attack (hit or miss)
- Combat XP accumulates until level-up threshold (tied to existing RANK_COMBAT system)
- Each rank increases damage output and reduces stamina cost
- Rank progression feeds into existing MarketAnalytics for display

### Three Combat Ranks
1. **Novice** (Rank 1): +0% damage, stamina cost normal
2. **Practiced** (Rank 2): +5% damage, stamina -5%
3. **Skilled** (Rank 3): +10% damage, stamina -10%
4. **Expert** (Rank 4): +15% damage, stamina -15%
5. **Master** (Rank 5): +20% damage, stamina -20%

### Earning Combat XP
- **Successful Attack** (hit landed): 10 XP
- **Missed Attack** (dodge/miss): 5 XP
- **Blocked Attack**: 7 XP
- **Defeated Mob**: 50 XP bonus
- **Defeated Player** (PvP): 100 XP bonus
- **Death Penalty**: Lose 10% of current rank XP (motivates careful play)

### Level-Up Requirements
- Rank 1→2: 500 XP
- Rank 2→3: 1000 XP
- Rank 3→4: 1500 XP
- Rank 4→5: 2000 XP

---

## Architecture

### New System: CombatProgression.dm
**Purpose**: Track combat XP, handle leveling, integrate with CombatSystem

**Key Functions**:
```dm
proc/AwardCombatXP(mob/M, var/xp_amount, var/reason)
  → Add XP to player's combat rank
  → Check for level-up
  → Log to analytics

proc/GetCombatRank(mob/M)
  → Return current rank (1-5)

proc/GetCombatXP(mob/M)
  → Return current XP in this rank

proc/GetCombatDamageScalar(mob/M)
  → Return damage multiplier (1.0 at rank 1, 1.20 at rank 5)

proc/GetCombatStaminaCost(mob/M, var/base_stamina)
  → Return adjusted stamina cost (lower at higher ranks)

proc/OnCombatRankUp(mob/M, var/old_rank, var/new_rank)
  → Reward player (message, possible skill unlock)
  → Log to analytics
```

### Integration Points

**1. CombatSystem.dm** (already exists)
- In `LogCombatEvent()`, call `AwardCombatXP(attacker, xp_amount, reason)`
- In `CalcDamageForContinent()`, call `GetCombatDamageScalar()` instead of placeholder

**2. UnifiedAttackSystem.dm** (already exists)
- In stamina cost calculation, call `GetCombatStaminaCost()` instead of base value

**3. CharacterData.dm** (already exists)
- Add `var/combat_xp = 0` (current rank XP)
- Already has: `var/combat_rank = 1` (current rank level)

**4. MarketAnalytics.dm** (already exists)
- New function: `GetCombatProgressionStats()` - returns rank distribution, avg level
- Feed rank-up events into abuse patterns (detect "smurfing" with alt rank farming)

---

## Implementation Plan (5 steps)

### Step 1: Create CombatProgression.dm (400 lines)
- Define XP values and thresholds as constants
- Implement `AwardCombatXP()` with level-up logic
- Implement rank accessors and scalar functions
- Add OnCombatRankUp() callback

### Step 2: Integrate with CombatSystem.dm
- Update `LogCombatEvent()` to award XP per-attack
- Modify `CalcDamageForContinent()` to use `GetCombatDamageScalar()`
- Ensure continent-specific damage stacking works

### Step 3: Integrate with UnifiedAttackSystem.dm
- Replace stamina cost hardcoding with `GetCombatStaminaCost()`
- Ensure stamina reduction scales properly with rank

### Step 4: Extend MarketAnalytics.dm
- Add `GetCombatProgressionStats()` function
- Track rank distribution across continents
- Add rank-up events to analytics log

### Step 5: Testing & Verification
- Verify XP awarded correctly per attack type
- Test level-up thresholds (XP cap per rank)
- Verify damage scalar applies correctly
- Check stamina reduction with combat rank
- Test analytics displays correct progression

---

## Example Flow: Combat Progression in Action

```
Player encounters forest goblin (Story mode, rank 1)
  ↓
Attack 1 (hit):       AwardCombatXP(player, 10, "attack_hit")     → 10/500 XP
Attack 2 (miss):      AwardCombatXP(player, 5, "attack_miss")     → 15/500 XP
...
Attack 50 (hit):      AwardCombatXP(player, 10, "attack_hit")     → 495/500 XP
Attack 51 (hit):      AwardCombatXP(player, 10, "attack_hit")     → 505/500 XP 🎉
  ↓
OnCombatRankUp() triggered:
  - Rank: 1 → 2
  - Message to player: "Your combat experience has grown! You are now Practiced (Rank 2)."
  - Damage: +5% (multiplier 1.05)
  - Stamina: -5% reduction
  - XP reset: 5/1000
  - Analytics: RankUpEvent(player, 2) logged
```

---

## Key Design Decisions

### 1. Why Combat XP Not Combat Rank?
- **Combat Rank** (1-5) tied to existing `RANK_COMBAT` system (easy to access)
- **Combat XP** (accumulates within rank) allows smooth progression
- **Example**: Rank 2 means "practiced in fighting" + 347/1000 XP toward Rank 3

### 2. Why Different XP for Attack Types?
- **Hit (10 XP)**: Reward landing attacks (requires skill)
- **Miss (5 XP)**: Reward practice even if unsuccessful (learning by doing)
- **Block (7 XP)**: Balanced between hit and miss (some success)
- **Defeated Mob (50 XP)**: Big reward for overcoming challenge
- **PvP Kill (100 XP)**: Massive reward but requires defeating player (high risk)

### 3. Why Death Penalty?
- Creates meaningful consequence (encourages careful play)
- Prevents passive grinding (avoid combat if losing quickly)
- Keeps progression meaningful (must actually win fights)
- -10% per death prevents cascading (can recover from bad streak)

### 4. Why 5 Ranks?
- Matches existing RANK_COMBAT max level (consistency)
- Allows meaningful progression without imbalance
- 20% damage swing (rank 1→5) is noticeable but not game-breaking
- Fits with other skill ranks (fishing, mining, etc.)

---

## Interaction with Three Continents

### Story Mode (Kingdom of Freedom)
- Combat XP earned fighting NPCs
- Later: Combat XP bonus from faction wars (Phase 12)
- Rank progression visible in faction rankings

### Sandbox Mode (Creative)
- No combat → No combat XP
- Rank progression disabled
- Analytics show "N/A" for combat stats

### PvP Mode (Battlelands)
- Combat XP earned from all sources
- PvP kills grant massive XP (100 vs 10 for NPC)
- Rank progression critical for dominance
- Analytics track rank distribution (smurfs detected)

---

## Success Criteria

✅ Players gain combat XP from every attack (hit/miss)  
✅ XP accumulates until rank-up threshold  
✅ Rank-up increases damage output (+5% per rank)  
✅ Rank-up reduces stamina cost (-5% per rank)  
✅ Death applies -10% XP penalty  
✅ Analytics track progression (shows rank distribution)  
✅ Zero build errors after integration  
✅ No regressions in existing systems  

---

## Deferred to Phase 11b+

- **Special Moves** (tied to rank unlocks)
- **Status Effects** (poison, stun, bleed)
- **Combat Achievements** (e.g., "Legendary Slayer" at Rank 5)
- **Faction Warfare XP Bonuses** (Story mode only)
- **Combat Leaderboards** (UI based on analytics)

---

## File Checklist

- [ ] Create `dm/CombatProgression.dm` (400 lines)
- [ ] Update `dm/CombatSystem.dm` (integrate XP award calls)
- [ ] Update `dm/UnifiedAttackSystem.dm` (integrate stamina scaling)
- [ ] Update `dm/MarketAnalytics.dm` (add progression stats)
- [ ] Update `Pondera.dme` (add CombatProgression.dm before CombatSystem.dm)
- [ ] Test build (0/0 expected)
- [ ] Git commit (Phase 11a: Combat Progression)

