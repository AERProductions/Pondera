# Potential SQLite Persistence Candidates for Pondera

**Analysis Date**: 2025-12-17 | **Current Phase**: Post-Phase 10 | **Database Status**: 33 tables, solid foundation

## Priority Ranking: Highest Value Additions

### 🔴 **CRITICAL** - Phase 11 (Immediate high ROI)

#### 1. **Global Resource State** (SP, MP, SM, SB - Stone, Metal, Timber, Supply Boxes)
**Current State**: Stored in `timesave.sav` binary savefile (TimeSave.dm)
**Issue**: Single file, vulnerable to corruption, difficult to audit, no analytics
**Benefit**: 
- Cross-session resource tracking and balancing
- Economy auditing (detect inflation/deflation)
- Per-faction resource pools (story/sandbox/pvp)
- Historical resource trends

**Proposed Tables**:
```sql
CREATE TABLE global_resources (
    resource_type TEXT UNIQUE,  -- 'stone', 'metal', 'timber', 'supply_box'
    current_amount BIGINT,
    last_updated TIMESTAMP,
    total_generated_all_time BIGINT,
    total_consumed_all_time BIGINT
);

CREATE TABLE resource_history (
    resource_type TEXT,
    historical_amount BIGINT,
    recorded_at TIMESTAMP,
    event_type TEXT,  -- harvested, used, crafted, traded
    related_player_id INTEGER,
    related_entity TEXT
);
```

**Procs Needed**: 5
- GetGlobalResourceAmount()
- LogResourceChange()
- GetResourceHistoryTrend()
- ValidateResourceIntegrity()
- GenerateResourceAuditReport()

---

#### 2. **NPC State & Progression** (Spawners, NPC persistence, behavior state)
**Current State**: Respawn-based (no state persistence), hardcoded spawners
**Issue**: NPCs reset on crash, no progression, limited customization per continent
**Benefit**:
- NPC schedules persist (patrol routes, shop hours)
- NPC relationships track over time (reputation, trades)
- NPC inventory state survives crashes
- Dynamic NPC dialogue based on player history

**Proposed Tables**:
```sql
CREATE TABLE npc_state (
    npc_id INTEGER PRIMARY KEY,
    npc_name TEXT UNIQUE,
    npc_type TEXT,  -- merchant, guard, quest_giver, companion
    current_location_x INTEGER,
    current_location_y INTEGER,
    current_location_z INTEGER,
    current_hp INTEGER,
    current_stamina INTEGER,
    inventory_json TEXT,
    emotional_state TEXT,  -- happy, angry, neutral, afraid
    last_update TIMESTAMP
);

CREATE TABLE npc_routines (
    routine_id INTEGER PRIMARY KEY,
    npc_id INTEGER,
    day_of_week TEXT,
    hour_start INTEGER,
    hour_end INTEGER,
    location_x INTEGER,
    location_y INTEGER,
    activity TEXT,  -- patrolling, resting, trading, crafting
    FOREIGN KEY(npc_id) REFERENCES npc_state(npc_id)
);

CREATE TABLE npc_relationships (
    relationship_id INTEGER PRIMARY KEY,
    npc_id INTEGER,
    other_entity TEXT,  -- player_id or other_npc_id
    relationship_type TEXT,  -- ally, enemy, neutral, subordinate
    strength INTEGER,  -- -1000 to +1000
    last_interaction TIMESTAMP
);
```

**Procs Needed**: 8+
- SaveNPCState()
- LoadNPCState()
- UpdateNPCLocation()
- GetNPCRoutine()
- ModifyNPCRelationship()
- GetNPCHistoryWithPlayer()

---

#### 3. **Day/Night Cycle & Seasonal State** (Persistent time metadata)
**Current State**: Stored in `timesave.sav` (hardcoded time vars)
**Issue**: Single point of failure, no seasonal event tracking, no eclipse/weather events
**Benefit**:
- Dynamic seasonal events persist (triggered events, rare phenomena)
- Weather system history and prediction
- Festival/event schedules
- Seasonal economy adjustments

**Proposed Tables**:
```sql
CREATE TABLE world_calendar (
    calendar_id INTEGER PRIMARY KEY,
    season TEXT,
    day_number INTEGER UNIQUE,
    month INTEGER,
    year INTEGER,
    day_of_week TEXT,
    time_of_day_start INTEGER,
    time_of_day_end INTEGER,
    is_festival BOOLEAN,
    weather_type TEXT,
    temperature_modifier REAL,
    event_description TEXT
);

CREATE TABLE seasonal_events (
    event_id INTEGER PRIMARY KEY,
    event_type TEXT,  -- harvest, festival, migration, eclipse, etc.
    season TEXT,
    day_of_year INTEGER,
    duration_hours INTEGER,
    affected_biomes TEXT,  -- JSON array
    resource_availability_modifier REAL,
    economy_impact TEXT
);
```

**Procs Needed**: 4+
- GetCurrentSeasonalModifiers()
- TriggerSeasonalEvent()
- GetUpcomingEvents()
- LogSeasonalActivity()

---

### 🟠 **HIGH PRIORITY** - Phase 12 (High value, medium effort)

#### 4. **Faction/Guild Systems** (Territory, politics, alliances)
**Current State**: Basic faction_allegiance table only, no guild infrastructure
**Issue**: No persistent territory claims (deed system exists but no allied territories), no guild hierarchies
**Benefit**:
- Multi-player guilds with leadership hierarchies
- Territory clustering (allied guilds, federal territories)
- Guild treasury and resource pooling
- Guild diplomacy (wars, treaties, alliances)
- Guild quests and collective achievements

**Proposed Tables**: 12+
- guilds (guild_id, name, leader_id, treasury, founded_date)
- guild_members (member_id, guild_id, player_id, rank, joined_date)
- guild_territories (territory_id, guild_id, deed_id, control_percentage)
- guild_diplomacy (diplomacy_id, guild_a_id, guild_b_id, relationship_type, status)
- guild_treasury_logs (log_id, guild_id, transaction_type, amount, timestamp)

---

#### 5. **Combat History & PvP Statistics** (Persistent battle records)
**Current State**: player_stats table (basic pvp_kills, deaths)
**Issue**: No matchmaking history, no skill ratings, no combat analysis
**Benefit**:
- ELO/rating systems for PvP
- Combat matchups analysis (what builds counter what)
- Combat replay data (what happened in each fight)
- Skill progression from combat experience
- Leaderboards with historical rankings

**Proposed Tables**: 8+
- combat_encounters (encounter_id, attacker_id, defender_id, winner_id, duration, damage_dealt, loot_gained)
- player_combat_stats (player_id, total_combat_time, avg_damage, win_rate, preferred_weapon)
- skill_effectiveness (skill_name, times_used, times_successful, effectiveness_percentage)
- combat_replays (encounter_id, action_sequence_json, timestamps)

---

#### 6. **World Events & Quests** (Dynamic world state changes)
**Current State**: Story/quest content hardcoded, no world progression
**Issue**: No persistent world changes from player actions, no meta-event tracking
**Benefit**:
- World responds to player actions (NPCs react, landscapes change)
- Persistent quests (not auto-resetting)
- World war/crisis events (territory battles affect gameplay)
- Achievement cascades (completing quest A unlocks quest B)

**Proposed Tables**: 10+
- world_quests (quest_id, quest_name, giver_id, reward_exp, reward_currency)
- player_quest_progress (player_id, quest_id, status, completion_percentage, last_updated)
- world_events (event_id, event_name, event_type, status, world_impact, start_time, end_time)
- world_changes (change_id, change_type, location_x, location_y, location_z, change_description, applied_at)

---

### 🟡 **MEDIUM PRIORITY** - Phase 13 (Good to have, medium-long term)

#### 7. **Map/Chunk Metadata & Point of Interest Registry**
**Current State**: Procedurally generated (MapSaves/Chunk_*.sav), no POI index
**Issue**: No way to mark/retrieve discovered locations, no fast POI lookup
**Benefit**:
- Fast POI queries (nearest safe zone, nearest shop, nearest resource)
- Player-created waypoints persistence
- Dungeon/cave discovery tracking
- Dynamic location events

**Proposed Tables**: 5+
- points_of_interest (poi_id, poi_name, poi_type, x, y, z, continent, difficulty, discovered_count)
- player_waypoints (waypoint_id, player_id, waypoint_name, x, y, z, created_at)
- location_events (event_id, location, event_type, active, duration)

---

#### 8. **Inventory & Item Management** (Beyond basic equipped items)
**Current State**: In-memory item objects, saved with character
**Issue**: No item-specific history, no serial numbers for tracking, no item trading history
**Benefit**:
- Track item lineage (who crafted it, who owned it, price history)
- Serial numbers for valuable items
- Item condition/durability persistence
- Item-specific lore/modifications

**Proposed Tables**: 6+
- item_registry (item_id, item_type, created_at, creator_id, current_owner_id, durability, modifications)
- item_ownership_history (history_id, item_id, owner_id, acquired_at, sold_to_id, transaction_price)
- item_modifications (mod_id, item_id, modification_type, applied_by_player_id, applied_at)

---

#### 9. **AI & NPC Learning Systems** (Behavioral memory)
**Current State**: Basic NPC routines, no learning/adaptation
**Issue**: NPCs don't learn from player interactions, no strategic behavior
**Benefit**:
- NPCs remember player theft/betrayal
- Market NPCs learn price trends and adjust accordingly
- Combat NPCs learn player tactics
- NPCs adapt behavior based on repeated interactions

**Proposed Tables**: 4+
- npc_memories (memory_id, npc_id, player_id, memory_type, intensity, created_at)
- npc_learned_behaviors (behavior_id, npc_id, behavior_pattern, effectiveness_score, times_used)
- npc_price_beliefs (belief_id, npc_id, commodity_name, believed_price, confidence_level)

---

### 🟢 **LOWER PRIORITY** - Phase 14+ (Nice features, long-term)

#### 10. **Player Achievements & Badges System** (Beyond crafting milestones)
Already have crafting_achievements, but could expand significantly with:
- Exploration achievements (visited X locations)
- Social achievements (guild leader, alliance)
- World event achievements (participated in world war)
- Hidden/secret achievements (speedrunning, pacifist runs)

#### 11. **Lore & Storytelling Database**
- Book/scroll items that players can find and collect
- Faction history and propaganda
- NPC backstories with branching choices
- Easter eggs and hidden lore elements

#### 12. **Performance Analytics & Debug Telemetry**
- Track server performance (FPS dips, lag spikes)
- Monitor system resource usage
- Log compilation errors and recovery
- Analyze player behavior patterns for balancing

---

## Quick Reference: Effort vs Impact Matrix

| System | Tables | Procs | Difficulty | Impact | ROI |
|--------|--------|-------|-----------|--------|-----|
| Global Resources | 2 | 5 | Easy | High | ★★★★★ |
| NPC State | 3 | 8+ | Medium | Very High | ★★★★★ |
| Calendar/Seasons | 2 | 4+ | Easy | Medium | ★★★★☆ |
| Guilds | 5+ | 10+ | Hard | Very High | ★★★★☆ |
| Combat History | 4+ | 8+ | Medium | High | ★★★★☆ |
| World Events | 4+ | 12+ | Hard | Very High | ★★★★☆ |
| Map POI | 3+ | 6+ | Medium | Medium | ★★★☆☆ |
| Item History | 3+ | 8+ | Medium | Medium | ★★★☆☆ |
| NPC Learning | 3+ | 8+ | Hard | Medium | ★★☆☆☆ |

---

## Recommended Phase 11 Focus

**Top 3 candidates for Phase 11** (balanced scope and impact):

1. **Global Resources** - 2 tables, 5 procs, massive economy auditing benefit
2. **NPC State & Routines** - 3 tables, 8 procs, transforms NPC richness
3. **Calendar/Seasonal Events** - 2 tables, 4 procs, enables dynamic world

**Combined effort**: ~7 tables, ~17 procs, ~2-3 hours implementation
**Combined impact**: Foundation for living, breathing world with economy controls and dynamic NPCs

---

## Architecture Synergies

These systems would integrate beautifully with existing persistence:

- **Global Resources** ↔ **Market Prices** (resource inflation affects prices)
- **NPC State** ↔ **NPC Merchants** (merchants adjust inventory based on routes)
- **Calendar** ↔ **Seasonal Demand Patterns** (seasonal events trigger demand spikes)
- **Guild System** ↔ **Deed System** (guilds own collective deeds)
- **Combat History** ↔ **Player Trading Analytics** (combat stats enhance player profiles)
- **World Events** ↔ **Supply Disruption Alerts** (events trigger alerts)

---

## Next Steps

1. **User decision**: Pick 1-2 systems for Phase 11
2. **Schema design**: Finalize tables and indexes
3. **Integration mapping**: Identify hooks into existing systems
4. **Implementation**: 2-3 hour sprint
5. **Testing**: Verify persistence across server restarts

---

**Total Database Scale After Phase 14**: Potentially 60+ tables, 1000+ columns, 300+ indexes
**Estimated Implementation Time**: 10-12 more phases at 2-3 hours each
**Long-term Vision**: A fully persistent, living world with NPC society, guild politics, and emergent gameplay
