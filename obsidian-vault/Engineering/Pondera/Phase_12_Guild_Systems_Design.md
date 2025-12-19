# Phase 12: Guild Systems & Territory Warfare - Design Document

**Target**: Clean build with 7 tables, 22+ procs  
**Estimated Implementation Time**: 3-4 hours  
**Bootstrap Sequence**: Ticks 460-490  
**Status**: PLANNING

---

## Overview

Phase 12 transforms Pondera from a solo/PvP survival game into a guild-based territorial warfare system. Players form guilds, control territory, and engage in raids and conquest.

### Three Sub-Phases

1. **Phase 12A: Guild System Foundation** - Guild CRUD, membership, roles, treasury management
2. **Phase 12B: Territory Control** - Territory claiming, boundaries, deed integration, conflict resolution  
3. **Phase 12C: Raiding & Conquest** - Siege mechanics, raid events, conquest resolution

---

## Phase 12A: Guild System Foundation

### Purpose
Enable players to:
- Create and manage guilds (with leader/officer/member roles)
- Track guild membership (who's in which guild)
- Manage shared guild treasury (resources pooled from members)
- Set guild policies (tax rates, diplomacy flags, PvP rules)

### Database Schema

**Table: `guilds`** (13 columns)
```sql
PRIMARY KEY: guild_id (auto-increment)
UNIQUE: guild_name (case-insensitive)
- leader_id: INTEGER (FOREIGN KEY → players.id, who founded guild)
- founded_date: TIMESTAMP (when guild was created)
- founded_day: INTEGER (day_number when created, for seasonal anniversary)
- guild_level: INTEGER (1-5, affects max members, treasury size)
- max_members: INTEGER (tier-dependent: 1→10, 2→25, 3→50, 4→100, 5→200)
- member_count: INTEGER (cached count, update on join/leave)
- description: TEXT (guild motto/purpose, max 500 chars)
- headquarters_x, headquarters_y, headquarters_z: INTEGER (HQ location)
- treasury_stone: BIGINT (pooled stone)
- treasury_metal: BIGINT (pooled metal)
- treasury_timber: BIGINT (pooled timber)
- total_treasury_value: INTEGER (aggregate value in gold equivalent)
- tax_rate: REAL (0.0-0.5, portion of member harvest taken)
- diplomacy_flags: TEXT (JSON: {ally_guild_id: diplomacy_type})
- is_disbanded: BOOLEAN (soft delete)
- last_activity: TIMESTAMP (when last member logged in)
INDEXES:
  - idx_guilds_leader (find guilds by leader)
  - idx_guilds_name (case-insensitive lookup)
  - idx_guilds_level (filter by tier)
  - idx_guilds_active (exclude disbanded)
```

**Table: `guild_members`** (8 columns)
```sql
PRIMARY KEY: membership_id (auto-increment)
FOREIGN KEY: guild_id → guilds (ON DELETE CASCADE)
FOREIGN KEY: player_id → players (ON DELETE CASCADE)
UNIQUE(guild_id, player_id)
- role: TEXT (leader|officer|member, determines permissions)
- joined_date: TIMESTAMP (when player joined guild)
- contribution_total: BIGINT (lifetime resources contributed)
- contribution_current_cycle: BIGINT (this month's contribution)
- rank_in_guild: INTEGER (1-10, prestige rank based on contribution)
- permissions_flags: TEXT (JSON: {can_disband: bool, can_claim_territory: bool, ...})
- last_active_date: TIMESTAMP (last time this player logged in)
INDEXES:
  - idx_members_guild (find all members of guild)
  - idx_members_player (find which guild player is in)
  - idx_members_role (filter by rank)
  - idx_members_active (active members only)
```

**Table: `guild_treasury_log`** (7 columns)
```sql
PRIMARY KEY: transaction_id (auto-increment)
FOREIGN KEY: guild_id → guilds
FOREIGN KEY: player_id → players (nullable, null if system event)
- transaction_type: TEXT (deposit|withdraw|tax_collected|maintenance_paid|raid_loss|conquest_gain)
- resource_type: TEXT (stone|metal|timber|gold)
- amount: BIGINT (signed, negative for withdrawals)
- reason: TEXT (crafting|maintenance|raid_expense|conquest_reward)
- recorded_at: TIMESTAMP
- balance_after: BIGINT (treasury amount after transaction)
INDEXES:
  - idx_log_guild (filter by guild)
  - idx_log_type (filter by transaction type)
  - idx_log_date (temporal sorting)
```

### Procs Implemented (8 procs)

**1. `CreateGuild(leader_id, guild_name, description="")`**
- Returns new guild_id on success, 0 on failure
- Validates: guild_name unique, leader exists, not already in guild
- Creates entry in guilds table with leader_id, level=1, max_members=10
- Creates initial treasury_log entry
- Output: "✓ Guild '[name]' created by [player]"

**2. `DisbandGuild(guild_id, leader_id)`**
- Validates leader is actual guild leader
- Sets is_disbanded=TRUE
- Transfers remaining treasury to leader (stored in character inventory)
- Removes all guild_members entries
- Output: "✓ Guild disbanded, [amount] resources returned to leader"

**3. `AddGuildMember(guild_id, player_id, role="member")`**
- Validates: player not already in guild, guild not at max_members
- Creates guild_members entry with joined_date=NOW
- Increments guild member_count
- Output: "[player] joined [guild] as [role]"

**4. `RemoveGuildMember(guild_id, player_id, reason="left")`**
- Validates: player is member, not leader (can't leave if leading)
- Removes guild_members entry
- Decrements guild member_count
- Handles pending raid/territory operations
- Output: "[player] left [guild] ([reason])"

**5. `SetGuildLeader(guild_id, new_leader_id, old_leader_id)`**
- Validates: both players in guild, old_leader is current leader
- Updates guilds.leader_id
- Updates guild_members roles (demotes old leader to officer, promotes new to leader)
- Logs transaction in treasury_log
- Output: "✓ [new_leader] is now leader of [guild]"

**6. `DepositToGuildTreasury(guild_id, player_id, resource_type, amount)`**
- Validates: player in guild, has enough resources
- Removes from player inventory
- Adds to guild treasury
- Logs to treasury_log with "deposit" type
- Updates guild.total_treasury_value
- Output: "[player] deposited [amount] [resource] to [guild]"

**7. `WithdrawFromGuildTreasury(guild_id, player_id, resource_type, amount)`**
- Validates: player is officer+ or leader
- Removes from guild treasury
- Adds to player inventory
- Logs to treasury_log with "withdraw" type
- Output: "[player] withdrew [amount] [resource] from [guild]"

**8. `GetGuildStats(guild_id)`**
- Returns formatted string with:
  - Guild name, leader, level, member count
  - Treasury amounts (stone/metal/timber/gold)
  - Controlled territories
  - Active raids/sieges
  - Diplomacy relationships
  - Avg member contribution
  - Last activity timestamp
- Output: Comprehensive guild profile

### Integration Points

**Player Login**:
- Load guild_id from guild_members
- Display guild name in character info
- Sync guild permissions to player flags

**Resource Harvesting**:
- Calculate tax_rate from guild
- Deduct from harvest amount before adding to player inventory
- Log tax_collected to treasury_log

**Logout**:
- Update last_active_date in guild_members
- Update guilds.last_activity if needed

---

## Phase 12B: Territory Control & Warfare

### Purpose
Enable guilds to:
- Claim territory (linked to deed system from Phase 5)
- Control zone resources
- Defend territory from raids
- Resolve territorial conflicts

### Database Schema

**Table: `guild_territories`** (10 columns)
```sql
PRIMARY KEY: territory_id (auto-increment)
FOREIGN KEY: guild_id → guilds
UNIQUE: deed_id (each guild can hold deed)
- deed_id: INTEGER (FOREIGN KEY → deed.id, links to existing deed system)
- claimed_date: TIMESTAMP (when guild claimed territory)
- claimed_day: INTEGER (day_number for tax calculations)
- territory_level: INTEGER (1-5, matches deed tier)
- resource_production_multiplier: REAL (1.0=normal, 1.5=rich deposits)
- control_strength: INTEGER (0-100, how firmly guild controls it)
- monthly_tax_revenue: BIGINT (tribute collected from this territory)
- conflict_status: TEXT (peaceful|disputed|under_siege|contested)
- last_conflict_date: TIMESTAMP
- abandoned_date: TIMESTAMP (when abandoned, if ever)
INDEXES:
  - idx_territories_guild (find all territories of guild)
  - idx_territories_deed (find guild holding deed)
  - idx_territories_status (filter by conflict status)
```

**Table: `territory_claims`** (9 columns)
```sql
PRIMARY KEY: claim_id (auto-increment)
FOREIGN KEY: territory_id → guild_territories
FOREIGN KEY: claimant_guild_id → guilds (guild trying to claim)
FOREIGN KEY: defender_guild_id → guilds (current holder)
- claim_date: TIMESTAMP (when claim filed)
- claim_type: TEXT (peaceful_handover|raid|siege|inheritance|conquest)
- reason: TEXT (guild disbanded, insufficient tribute, military conquest)
- required_military_strength: INTEGER (combat power needed to win)
- resolution_date: TIMESTAMP (when claim resolved)
- resolution_type: TEXT (succeeded|failed|negotiated|abandoned|disputed)
- winner_guild_id: INTEGER (which guild won)
- compensation_paid: BIGINT (gold/resources exchanged if negotiated)
INDEXES:
  - idx_claims_territory (find claims on territory)
  - idx_claims_claimant (find claims filed by guild)
  - idx_claims_defender (find threats to guild territory)
  - idx_claims_status (find unresolved claims)
```

### Procs Implemented (6+ procs)

**1. `ClaimTerritory(guild_id, deed_id)`**
- Validates: guild exists, deed unclaimed, guild has military strength
- Creates guild_territories entry
- Sets control_strength=100 (newly claimed)
- Triggers: immediate resource production at territory
- Output: "[guild] claimed territory [deed_id]"

**2. `AbandonTerritory(guild_id, territory_id)`**
- Validates: guild actually controls territory
- Sets is_abandoned=TRUE, abandoned_date=NOW
- Removes from guild control
- Triggers: territory reverts to wilderness (random resources spawn)
- Output: "[guild] abandoned [territory]"

**3. `IssueTerritorialClaim(claimant_guild_id, territory_id, claim_type, reason="")`**
- Creates territory_claims entry with claim_date=NOW
- Sets conflict_status="disputed" on territory
- Notifies defender guild
- Starts resolution timer (depends on claim_type)
- Output: "[claimant] issued [claim_type] claim on [territory]"

**4. `ResolveClaim(territory_id, winner_guild_id, resolution_type)`**
- Validates: one claim resolved per territory
- Updates territory_claims.resolution_date/type/winner_guild_id
- Transfers territory from defender to winner (updates guild_territories.guild_id)
- Logs to treasury_log (conquest_gain for winner, conquest_loss for loser)
- Sets conflict_status="peaceful"
- Output: "[winner] took control of [territory]"

**5. `CalculateTerritoryResourceProduction(territory_id)`**
- Reads territory_level, resource_production_multiplier
- Base production per level: Level 1=100/day, Level 5=500/day
- Applies multiplier (rich deposits boost or deplete rates)
- Distributes randomly: stone/metal/timber proportions
- Adds to guild treasury automatically
- Returns: {stone: amount, metal: amount, timber: amount}

**6. `GetTerritoryStatus(territory_id)`**
- Returns comprehensive territory info:
  - Current controller guild
  - Resource production rate
  - Control strength
  - Active claims/conflicts
  - Tax revenue (monthly)
  - Strategic value rating
- Output: Formatted territory report

### Integration with Deed System (Phase 5)

The guild_territories table `deed_id` foreign key links to existing `/datum/deed` objects:
- When guild claims territory, creates deed if not exists OR takes control of existing deed
- Deed permission flags (`canbuild`, `canpickup`, `candrop`) now tied to guild membership
- Building in guild territory requires guild membership + proper role
- Deed maintenance costs paid from guild treasury (auto-deducted monthly)

---

## Phase 12C: Raiding & Conquest Mechanics

### Purpose
Enable guilds to:
- Initiate raids on enemy territories
- Defend against incoming raids
- Conduct sieges for strategic control
- Resolve outcomes with combat and resource losses

### Database Schema

**Table: `raid_events`** (13 columns)
```sql
PRIMARY KEY: raid_id (auto-increment)
FOREIGN KEY: attacker_guild_id → guilds
FOREIGN KEY: defender_guild_id → guilds
FOREIGN KEY: territory_id → guild_territories
- raid_start_date: TIMESTAMP (when raid initiated)
- raid_duration_hours: INTEGER (how long raid lasts before auto-resolve)
- raid_status: TEXT (planning|active|resolved|cancelled)
- attacker_military_strength: INTEGER (sum of guild member combat ratings)
- defender_military_strength: INTEGER (defending guild combat power)
- attacker_casualties: INTEGER (players killed/lost)
- defender_casualties: INTEGER (players killed/lost)
- resource_plunder: BIGINT (amount of resources stolen on success)
- resource_destroyed: BIGINT (collateral damage to territory)
- outcome: TEXT (attacker_victory|defender_victory|negotiated_settlement|stalemate)
- settlement_terms: TEXT (JSON: negotiation results if settled)
- raid_resolved_date: TIMESTAMP
- victory_bonus_resources: BIGINT (reward resources distributed)
INDEXES:
  - idx_raids_attacker (find raids by attacking guild)
  - idx_raids_defender (find threats to defending guild)
  - idx_raids_territory (find all raids on territory)
  - idx_raids_status (active raids only)
```

**Table: `siege_progress`** (11 columns)
```sql
PRIMARY KEY: siege_id (auto-increment)
FOREIGN KEY: raid_id → raid_events
FOREIGN KEY: defending_outpost_id: INTEGER (optional, specific defense location)
- days_elapsed: INTEGER (how many days into siege)
- morale_attacker: INTEGER (0-100, affects combat power)
- morale_defender: INTEGER (0-100, affects defense)
- supply_status_attacker: TEXT (well_supplied|rationing|starving)
- supply_status_defender: TEXT (well_supplied|rationing|starving)
- attrition_rate: REAL (% of forces lost daily to hunger/attrition)
- breakthrough_attempts: INTEGER (count of assault waves)
- successful_assaults: INTEGER (forces that penetrated defenses)
- territory_damage_percent: INTEGER (0-100, % of territory destroyed)
- estimated_victory_date: DATE (when siege likely to resolve)
- capitulation_threshold: INTEGER (morale below this = surrender)
INDEXES:
  - idx_siege_raid (find siege for raid)
  - idx_siege_status (active sieges only)
```

### Procs Implemented (8+ procs)

**1. `InitiateRaid(attacker_guild_id, territory_id, raid_type="raid")`**
- Validates: guild exists, territory controlled by different guild
- Calculates: attacker_military_strength from guild members' combat power
- Creates raid_events entry with raid_status="planning"
- Sends notification to defender
- Starts raid timer (defense window opens)
- Output: "[attacker] initiated [raid_type] on [territory] controlled by [defender]"

**2. `CalculateMilitaryStrength(guild_id)`**
- Sums combat ratings of all guild members
- Base: 10 per member (can contribute to combat)
- Bonus: +5 per combat rank achieved
- Equipment modifiers: weapon AC/armor rating
- Returns: total combat power integer
- Output: Integer combat value

**3. `ResolveRaidCombat(raid_id)`**
- Calculates: attacker vs defender military strength
- Determines winner: higher strength = victory (with RNG element)
- Calculates: casualties = loser_strength * random(0.2-0.4)
- Calculates: resource_plunder based on territory tier
- Logs: resource losses to both guilds
- Updates: raid_events with outcome/casualties/plunder
- Output: "Raid resolved: [winner] victorious, [casualties] lost"

**4. `InitiateSiege(attacker_guild_id, territory_id)`**
- Creates siege_progress entry linked to raid_events
- Sets: morale_attacker/defender=75, supply_status=well_supplied
- Starts daily attrition: -5 morale per day without supply (auto-calculated)
- Enables: supply runs (attacking guild can send caravans to resupply)
- Enables: breakthrough attempts (assaults on defenses)
- Output: "Siege initiated on [territory], estimated duration [days]"

**5. `PerformSiegeAssault(siege_id, attacker_guild_id)`**
- Requires: siege in active status
- Calculates: breakthrough chance = (attacker_morale - defender_morale) / 100
- If successful: territory_damage_percent += 10, some defenses breached
- If failed: attacker_casualties += 5-20 (repelled assault)
- Updates: morale_attacker (increases on success, decreases on failure)
- Output: "Assault result: [success|failure]"

**6. `SendSiegeSupplies(guild_id, siege_id, supply_amount)`**
- Validates: guild is attacker or defender
- Deducts supply_amount from guild treasury
- Updates: supply_status_attacker/defender
- Extends: siege duration or reduces attrition
- Output: "[amount] supplies delivered to siege"

**7. `SiegeSurrender(defending_guild_id, siege_id)`**
- Allows defender to surrender before defeat
- Transfers territory immediately to attacker
- Negotiates: settlement_terms (some resources returned to defender)
- Logs: conquest victory to attacker treasury_log
- Output: "[defender] surrendered [territory] to [attacker]"

**8. `CalculateRaidRewards(raid_id)`**
- Attacker victory: plundered_resources + victory_bonus
- Defender victory: defensive_bonus + resource salvage (half of attempted plunder)
- Distributes: among participating guild members
- Updates: guild_members rank_in_guild based on contribution
- Output: "Rewards distributed to [guild] members"

### Combat Integration

Raids tap into existing combat system (`dm/combat.dm`):
- Each guild member's current HP/weapon affects military_strength calculation
- Dead players not counted in active strength
- Wounded players have reduced contribution
- Healing between raids matters (preparation phase)

---

## Boot Initialization (Phase 12 - Ticks 460-490)

**Tick 460**: InitializeGuildSystem()
```
- Load all guilds from database
- Initialize guild_members cache
- Verify guild leaders still exist (promote to officer if deleted)
- Load active raids/sieges
- Log: "GUILD_SYSTEM: Loaded [N] guilds with [M] members"
```

**Tick 475**: InitializeTerritoryControl()
```
- Load all guild_territories
- Calculate resource production for each territory
- Distribute pending production to guild treasuries
- Check for expired territorial claims
- Auto-resolve peaceful claims if duration passed
- Log: "TERRITORY_SYSTEM: Initialized [N] territories"
```

**Tick 490**: InitializeRaidSystem()
```
- Load all active raids/sieges from last session
- Resume siege progress (add daily attrition)
- Auto-resolve stale raids (>7 days old with no activity)
- Notify defending guilds of threats
- Log: "RAID_SYSTEM: Resumed [N] active raids"
```

---

## Integration Checklist

- [ ] 7 tables created with proper indexes
- [ ] 22+ procs implemented
- [ ] Boot sequence added to InitializationManager.dm
- [ ] Guild UI/commands integrated
- [ ] Deed system linked to guild territories
- [ ] Combat system hooks for military strength
- [ ] Treasury auto-taxation on resource harvest
- [ ] Territory resource production loop
- [ ] Raid notification system
- [ ] Siege attrition mechanics
- [ ] Build verification (expect 0 errors)
- [ ] Commit to recomment-cleanup

---

## Notes

- **Scalability**: Indexes on guild_id, player_id, and status fields ensure fast queries
- **Persistence**: All guild state saved to database, survives server restart
- **Diplomacy**: Guild relationships stored in JSON (allies/enemies/neutral)
- **Tax Integration**: Automatic tax deduction from harvest via AdjustGlobalResourceAmount hook
- **Territory Economy**: Guild treasuries drive demand for resources in market

