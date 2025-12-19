# Pondera Login & Port System - Complete Architecture

**Status**: Design Phase Complete | Implementation Ready  
**Version**: 1.0 (User-Approved Decisions A-1 through F-14)  
**Date**: December 12, 2025

---

## Overview

The new login system transforms character creation from menu-driven to **gameplay-first** with the Port as an instanced social hub. Key innovations:

1. **Blank avatar model** with optional class specialization (prestige-gated)
2. **Prestige as progression gate** - teaches players sandbox first, unlocks customization
3. **Equipment transmutation** - gear morphs seamlessly when crossing continents
4. **Personal lockers** at port for mode-specific item storage
5. **Death respawn at port** - graceful re-entry vs permanent character reset
6. **Role-based admin hierarchy** - Owner (MGM) controls all roles below
7. **Server difficulty toggles** - permadeath/lives configurable by host
8. **True offline mode** - world.visibility=0 for single-player

---

## Part 1: Avatar & Equipment System

### A-1: Binary Gender Selection
- **Male/Female** binary system (not NB, simplifies character data)
- Selected at first port visit, stored in `character.gender` (1=M, 2=F)
- Affects visual appearance (icon_state includes gender suffix: "char_m" vs "char_f")
- Can be changed only after prestige unlock (see A-3)

### A-2: Equipment Transmutation (Seamless Transition)
When player crosses continental boundary (via portal):
1. **On departure**: Unequip all non-cosmetic gear
2. **In transit**: Gather equipped items, look up transmutation rules
3. **On arrival**: Equip transmuted versions (Kingdom sword → Story broadsword, etc.)

**Implementation Pattern**:
```dm
// Global transmutation map
var/global/list/equipment_transmutation = list(
    "Kingdom" = list(
        "Sandbox" = list("iron_sword" = "wooden_sword", "steel_armor" = "cloth_robes"),
        "Story" = list("iron_sword" = "bronze_sword", "steel_armor" = "knight_plate")
    ),
    // ... reciprocal mappings
)

// On portal crossing:
proc/TransmuteEquipment(mob/players/P, from_continent, to_continent)
    var/list/transmutation_map = equipment_transmutation[from_continent][to_continent]
    for(var/obj/equipment/E in P.equipped_items)
        var/new_type = transmutation_map[E.name]
        if(new_type)
            new new_type(P)  // Create transmuted version
            del E            // Remove old version
```

### A-3: Prestige-Gated Customization (C+B Hybrid)

**TIER 1 (First Visit - Default Avatar)**:
- Fixed blank male or female avatar
- Can wear/equip items but cannot change face/hair/body
- **Goal**: Learn game in Sandbox (no pressure, all recipes, no monsters)
- Duration: Until player unlocks any prestige in ANY continent

**TIER 2 (First Prestige Unlocked - Full Customization)**:
- Unlock full character customization system
- Can recreate character appearance at will (cosmetics)
- Cross-continent persistent customization (takes transmuted form per continent)
- Award title: **"Prestige Initiate"** (cosmetic, shown in player list)
- **Goal**: Players learn mechanics in Sandbox, then challenge Kingdom/Story
- Kingdom becomes "hard mode" for new-game-plus players
- Creates self-driven tutorial funnel that teaches proper MMO roles

**Prestige Unlock Triggers**:
- **Sandbox prestige**: Reach max level in any skill (Level 5 fishing, etc.)
- **Story prestige**: Complete major quest chain or reach level cap
- **Kingdom prestige**: Survive X days or earn X kills (hard)

**Implementation**:
```dm
// In character_data
var
    has_prestige = 0  // 0 = locked, 1 = unlocked
    prestige_unlock_source = ""  // "sandbox", "story", "kingdom"
    prestige_title = ""  // "Prestige Initiate"
    appearance_locked = 1  // 1 = can't customize, 0 = can customize

// On prestige unlock
proc/UnlockPrestige(mob/players/P, source)
    P.character.has_prestige = 1
    P.character.prestige_unlock_source = source
    P.character.appearance_locked = 0
    P.character.prestige_title = "Prestige Initiate"
    P << "<span class='good'>PRESTIGE UNLOCKED! You can now customize your character appearance.</span>"
    // Teleport player to port lobby for recreation
    P.loc = /turf/port_center
```

---

## Part 2: Inventory & Death Mechanics

### B-4: Personal Lockers (Mode-Specific Storage)

**Port Personal Locker** at each continent's port entrance:
- **Capacity**: 50 item slots (whitelist enforced)
- **Access**: Player can deposit/withdraw items between visits
- **Whitelisted items**:
  - Cosmetic items (dyes, hair accessories)
  - Trophies (combat tokens, fishing records, etc.)
  - Non-exploitable trade goods
  - **Blocked items**: Armor, weapons, consumables (prevent mode-break exploits)

**Implementation**:
```dm
// Datum for player's port locker
/datum/port_locker
    var/owner_ckey = ""
    var/list/items = list()  // Stored items
    var/capacity = 50
    
    proc/Deposit(obj/item/I)
        if(items.len >= capacity) return 0
        if(!IsWhitelisted(I)) return 0
        items += I
        return 1
    
    proc/Withdraw(item_name)
        var/obj/item/I = items[item_name]
        if(!I) return 0
        items -= I
        return I
    
    proc/IsWhitelisted(obj/item/I)
        return I.item_type == "cosmetic" || I.item_type == "trophy"

// Player has one locker per continent (saved)
// client.port_locker_story, client.port_locker_sandbox, client.port_locker_kingdom
```

### B-5: Death & Character Reset

**In Kingdom PvP** (default or hardcore mode enabled):
- **First death**: Fainted state (awaitable for Abjure revival) - XP loss
- **Second death (or if Hardcore + 1st death unrevived)**: Permanent
  - **Death consequence**: Player spawns at **port lobby**
  - **Character reset**: Full customization available (like new prestige+)
  - **Retention**: Skills/recipes/knowledge persist (cross-continent global)
  - **Lockers intact**: Port items remain available
  - **Effective**: Hard restart for Kingdom while preserving progression

**In Story Mode**:
- **First death**: Fainted at location (revivable by healer NPC or other players)
- **Respawn option**: Rally point or home haven (with temporary weakness debuff)
- **No second death penalty** (story is exploration-focused)

**In Sandbox**:
- **No death mechanic** (creative play)

---

## Part 3: Class & Specialization System

### C-6: Classes as Optional Hard-Mode Path

**Sandbox (Blank Avatar Mandatory)**:
- No class selection
- All recipes unlocked regardless of class
- All skills learnable (non-exclusive)
- Goal: Creative freedom, teaching tool

**Story (Optional Class)**: 
- Can play blank avatar OR select class
- Class provides starting bonuses (HP, STR, resistances)
- Story-specific NPCs teach recipes without class requirement
- Goal: PvE progression with flavor

**Kingdom (Optional Class, Hard Mode)**:
- Can play blank avatar OR select class
- Class selection grants starting advantage (prestige players only)
- Blank avatar Kingdom player = hard mode (less starting HP/STR)
- Class selection = recommended path (easier entry)
- Goal: Competitive PvP with skill gates

**Class Tiers**:
1. **Base 3**: Landscaper (farming), Builder (building), Smithy (smithing)
2. **Prestige 2**: Feline (magi), Magus (spells)
   - Unlocked via prestige progression (5% XP bonus, story recipes)

### C-7: NPC Specializations as Cosmetic Titles

Working with NPC crafter guides (Blacksmith, Baker, Herbalist, Fisherman) unlocks:
- **Prestige Title**: "Baker's Apprentice", "Master Smith", "Herbalist's Student"
- **Cosmetic Effect**: Title shown in player list + portrait area
- **Recipe Benefit**: Full access to that NPC's recipe tier (Story mode)
- **No Mechanical Advantage**: Purely cosmetic + lore

**Implementation**:
```dm
// In character_data
var
    crafter_titles = list()  // ["Baker's Apprentice", "Master Smith"]
    
// When player completes NPC chain
proc/UnlockCrafterTitle(mob/players/P, npc_name)
    P.character.crafter_titles += "[npc_name]'s Apprentice"
    // Grant full recipe access for that NPC's recipes
    UnlockRecipeTierFromNPC(P, npc_name)
```

---

## Part 4: Admin & Roles System

### D-8: Owner as Hardcoded Character Role

**Owner/Master GM (MGM)**:
- **Hardcoded as ONE role** tied to specific ckey (e.g., Pondera creator)
- Set in `#define OWNER_CKEY "your_ckey_here"`
- Ultimate authority: Can create, grant, revoke ANY role
- Can toggle between testing character and MGM verb set

### D-9: Admin Testing Path

Admin can:
1. **Create testing character** - regular player login to experience actual gameplay flow
2. **Toggle between modes**:
   - **Test Mode**: Character wanders like normal player (no GM powers visible)
   - **MGM Mode**: Show GM/Admin verbs, access admin commands
   - Toggle command: `/toggleadminmode` (hides/shows verb set)

### D-10: Role Hierarchy (C - Full Authority Model)

```
OWNER/MGM (Master GM)
  ├─ CAN GRANT: All roles below
  ├─ CAN STRIP: All roles below  
  ├─ CAN OVERRIDE: Anything
  └─ MUST BE: Hardcoded, only one
  
├─ GM (Game Master / Host)
  ├─ CAN GRANT: Moderator, Contributor, Audio Engineer, Community Assistant
  ├─ CAN STRIP: Same
  ├─ CAN OVERRIDE: Most gameplay (teleport, item spawn, etc.)
  └─ CANNOT: Assign or promote to MGM/Owner
  
├─ Moderator (MOD)
  ├─ CAN: Soft mute, jail malicious players, warn
  ├─ CAN ESCALATE: Issues to GM
  ├─ CAN RECOMMEND: Promotion to Community Assistant
  └─ SCOPE: Community issues only
  
├─ Audio Engineer (AE) [Wife's Role]
  ├─ CAN: Change playlists, add/remove music
  ├─ CAN: Assign sounds to in-game items (via admin hud)
  ├─ CAN: Manage ambient audio
  └─ SCOPE: Sound system only (no player manipulation)
  
├─ Contributor (Streamer)
  ├─ CAN: No HUD toggle (hide health bars for stream)
  ├─ CAN: Personal emote commands
  ├─ NO POWER: Over other players
  └─ SCOPE: Self-only (cosmetic tools)
  
└─ Community Assistant (CA / Deputy)
  ├─ CAN: Soft warning, light moderation assist
  ├─ CAN: Escalate to Moderator
  ├─ CAN BE PROMOTED: To Moderator by GM/MGM
  └─ SCOPE: Helper role (learning path)
```

**Implementation**:
```dm
// In player object
var
    role = ""  // "", "gm", "moderator", "audio_engineer", "contributor", "ca"
    
// Role permission matrix
var/global/list/role_permissions = list(
    "owner" = list("create_char" = 1, "grant_all_roles" = 1, "override_all" = 1),
    "gm" = list("teleport" = 1, "spawn_items" = 1, "grant_below_gm" = 1),
    "moderator" = list("mute_player" = 1, "jail_player" = 1, "warn_player" = 1),
    "audio_engineer" = list("change_music" = 1, "assign_sounds" = 1),
    "contributor" = list("hide_hud" = 1, "emote_command" = 1),
    "ca" = list("warn_player" = 1, "light_assist" = 1)
)

// Check permission
proc/HasPermission(mob/players/P, action)
    var/list/perms = role_permissions[P.role]
    return perms[action] == 1
```

---

## Part 5: Port System (E - Multiplayer Hub + Single-Player Privacy)

### E-11: Port Instancing Models

**Offline Mode (A)**:
- **Purpose**: True offline play, no hub connection
- **Behavior**: Fully private, single-player experience
- **Access**: BYOND .exe generator (distributable executable)
- **Technical**: `world.visibility = 0` (no hub listing)

**Single-Player Mode (C)**:
- **Purpose**: Private play with optional friend invites
- **Behavior**: Hybrid - starts private, can invite 1-2 friends
- **Access**: Normal BYOND play, private world
- **Port Model**: Shared social hub (optional multiplayer)
- **Technical**: `world.visibility = 0` with invite whitelist

**Multiplayer Mode (B)**:
- **Purpose**: Hosted server, open to players
- **Behavior**: Shared social hub (port is gathering place)
- **Access**: Anyone can join via hub
- **Port Model**: Social gathering (continent selection happens in port geography)
- **Technical**: `world.visibility = 1` (hub listed)

### E-12: Port Accessibility & Exploit Protection

**Rules**:
- Player can return to port **anytime** from any continent (no cooldown)
- **Exploit prevention**:
  - Cannot carry Kingdom weapons/armor TO Sandbox (blocked on entry)
  - Cannot carry crafting materials with game-breaking combinations
  - Personal locker whitelist prevents mode-break
  - Death respawn at port prevents server farming (if killed in Kingdom, must restart)

**Implementation**:
```dm
// On port entry
proc/CheckPortEntry(mob/players/P, from_continent)
    var/list/banned_items = list()
    for(var/obj/item/I in P.contents)
        if(I.continent_locked == from_continent && from_continent != "port")
            banned_items += I
    
    if(banned_items.len > 0)
        P << "<span class='danger'>Cannot bring [banned_items.len] items across continents.</span>"
        // Drop to locker or ground
        for(var/item in banned_items)
            item.loc = P.loc
        return 0
    
    return 1
```

---

## Part 6: Difficulty & Lives System (F)

### F-13: Lives Pool Per-Continent

**Configuration** (Set by host at server creation):
- **Permadeath Toggle**: ON/OFF
- **Lives Per Continent**: Default 2 (max)
  - If set: Player has X lives per continent
  - Each death = -1 life, until 0 → character reset → respawn at port
  - Lives independent per continent (Kingdom has 2, Story has 2, Sandbox has 0)

**Death Mark System**:
- Each unrevived death = mark on character
- If permadeath OFF + lives ON: 
  - 0-1 marks = faint + revive mechanic
  - 2+ marks = character reset (lives exhausted)
- If permadeath ON: 
  - 1st death (any) = permanent → spawn at port for new character

### F-14: Integration with DeathPenaltySystem.dm

**Existing Death System** (Two-Death Model):
- **First death**: Fainted state (awaitable for Abjure revival)
- **Second death**: Permanent death

**Modified Interaction with Lives**:

```dm
// In HandlePlayerDeath (DeathPenaltySystem.dm)
proc/HandlePlayerDeath(mob/players/player, mob/attacker)
    var/datum/server_config/config = get_server_config()
    var/current_continent = player.current_continent
    
    // Track death mark for lives system
    if(config.lives_enabled && config.lives[current_continent] > 0)
        player.character.death_marks[current_continent]++
        
        if(player.character.death_marks[current_continent] >= config.lives[current_continent])
            // Lives exhausted - hard reset
            ApplyCharacterReset(player)  // Spawn at port, full reset
            return
    
    if(config.permadeath_enabled)
        // Permadeath ON - any death = permanent
        ApplyPermanentDeath(player, attacker)  // Force second death
    else
        // Permadeath OFF - standard two-death
        if(player.character.death_count >= 2)
            ApplyPermanentDeath(player, attacker)
        else
            ApplyFaintedState(player, attacker)

// New proc: Hard reset (respawn at port)
proc/ApplyCharacterReset(mob/players/player)
    player << "<span class='danger'>LIVES EXHAUSTED: Character reset. Respawn at port.</span>"
    player.character = new /datum/character_data(player)  // Fresh character data
    player.loc = /turf/port_center
    player.HP = player.MAXHP
    player.stamina = player.MAXstamina
    // Preserve: Skills, recipes, knowledge, prestige status
    // Reset: Inventory, equipment, vitals, death_marks
```

---

## Part 7: Login Flow (Complete Sequence)

### Sequence Diagram: New Player → Port Hub → Continent

```
1. CLIENT.LOGIN() [client.dm]
   ├─ Check if player exists (character data in savefile)
   ├─ If new: Spawn at /turf/port_center (blank avatar)
   └─ If existing: Load character_data, respawn at port

2. /TURF/PORT_CENTER (Instanced Zone)
   ├─ [FIRST VISIT] Display character customization UI
   │  ├─ Show gender selection (M/F) [BLOCKED if no prestige]
   │  ├─ Show appearance panel [BLOCKED if no prestige]
   │  ├─ Show equipment loadout selection
   │  └─ Show personal locker (cosmetics/trophies)
   │
   ├─ [PRESTIGE VISIT] Full customization available
   │  ├─ Change gender (M/F)
   │  ├─ Change face/hair/body colors
   │  ├─ Rename character (optional)
   │  └─ Select prestige title to display
   │
   └─ [ALL VISITS] Exit via continent portals
      ├─ "Boat to Kingdom" (PvE/PvP story)
      ├─ "Portal to Sandbox" (Creative)
      ├─ "Gateway to Battlelands" (PvP)
      └─ Each portal teleports to continent-specific spawn

3. CONTINENT SPAWN (/turf/continent_spawn_[type])
   ├─ Load continent-specific inventory from save
   ├─ Transmute equipment to continent version
   ├─ Initialize continent-specific UI (weather, dangers, NPCs)
   └─ Player enters gameplay

4. GAMEPLAY LOOP
   ├─ Player interacts with world (quest, build, farm, fight)
   ├─ On death: Check lives/permadeath
   │  ├─ If lives remain: Faint state → awaitable for revival
   │  └─ If lives = 0 or permadeath: Reset → respawn at port
   ├─ On return to port: Retrace steps 2-3
   └─ Loop continues
```

---

## Part 8: Savefile & Persistence

### Character Data Schema

```dm
/datum/character_data
    var
        // Persistent (Global)
        ckey = ""
        name = ""
        level = 1
        exp = 0
        skills = list()        // All rank levels
        recipes = list()       // Discovered recipes
        knowledge = list()     // Lore/story topics
        
        // Avatar (Global, prestige-gated)
        gender = 1             // 1=M, 2=F
        appearance_locked = 1  // 0 = can customize
        has_prestige = 0
        prestige_source = ""   // "sandbox", "story", "kingdom"
        crafter_titles = list()
        
        // Per-Continent
        current_continent = ""
        inventory = list()     // Maps per continent
        equipment = list()
        vitals = list(HP, stamina, hunger)
        position = list(x, y, z)
        
        // Death System
        death_count = 0        // Reset on continent change
        death_marks = list()   // Per continent (["kingdom"] = 1, etc.)
        is_fainted = 0
        
        // Port
        port_locker = /datum/port_locker

// Server Config (set at world boot)
/datum/server_config
    var
        game_mode = ""         // "sp", "mp", "offline"
        permadeath_enabled = 0
        lives = list("kingdom" = 2, "story" = 1, "sandbox" = 0)
        owner_ckey = ""
```

---

## Part 9: Implementation Roadmap

### Phase 1: Foundation (P0)
- [ ] Create blank avatar framework (gender + base body)
- [ ] Implement prestige unlock system
- [ ] Create port hub zone (/turf/port_center) as gameplay space
- [ ] Implement character customization UI (prestige-gated)

### Phase 2: Equipment & Inventory (P0)
- [ ] Implement equipment transmutation on continent crossing
- [ ] Create port personal locker system with whitelist
- [ ] Implement continent-specific inventory loading

### Phase 3: Death & Respawn (P0)
- [ ] Integrate lives system with DeathPenaltySystem.dm
- [ ] Implement character reset on lives=0
- [ ] Connect death respawn to port lobby

### Phase 4: Admin System (P1)
- [ ] Implement role-based permission matrix
- [ ] Create admin verb set (toggleable)
- [ ] Hardcode Owner/MGM role
- [ ] Create admin panel UI

### Phase 5: Server Config (P1)
- [ ] Create difficulty toggle system (permadeath, lives)
- [ ] Host configuration panel (set at world boot)
- [ ] Save/load difficulty settings

### Phase 6: Cleanup (P2)
- [ ] Archive legacy SavingChars.dm forms
- [ ] Consolidate character creation (remove duplication)
- [ ] Remove legacy input() dialogs
- [ ] Test full login flow (SP/MP/offline)

---

## Part 10: Testing Checklist

- [ ] New player login → port customization (prestige locked)
- [ ] Prestige unlock → full customization available
- [ ] Equipment transmutation (Kingdom sword → Sandbox wooden sword)
- [ ] Personal locker storage/retrieval (whitelisted items only)
- [ ] Death respawn at port (lives exhausted)
- [ ] Continent travel (inventory loading, spawn zones)
- [ ] Role granting (Owner → GM, GM → Moderator, etc.)
- [ ] Admin mode toggle (testing char vs MGM verbs)
- [ ] Server difficulty (permadeath ON → any death = reset, lives ON → countdown to reset)
- [ ] Persistence (skills/recipes survive character reset)
- [ ] Offline mode (world.visibility=0, no hub connection)

---

## Part 11: File Structure

**New Files to Create**:
- `dm/PortHubSystem.dm` - Port zone, customization UI, locker
- `dm/EquipmentTransmutationSystem.dm` - Gear morphing on continent crossing
- `dm/PrestigeSystem.dm` - Prestige unlock, appearance locking
- `dm/RoleBasedAdminSystem.dm` - Permission matrix, role granting
- `dm/ServerConfigUI.dm` - Difficulty/lives toggles
- `dm/BlankAvatarSystem.dm` - Gender selection, body framework
- `turf/port.dm` - Port zone definition

**Files to Modify**:
- `dm/DeathPenaltySystem.dm` - Integrate lives system, add character reset
- `dm/CharacterCreationUI.dm` - Simplify, gate to prestige unlocks
- `dm/Basics.dm` - Remove class-locked avatar code, use blank avatar
- `Pondera.dme` - Add new includes before mapgen block

**Files to Archive**:
- `dm/SavingChars.dm` (legacy forms) → `archive/SavingChars.dm.legacy`
- `dm/_DRCH2.dm` (old login) → `archive/_DRCH2.dm.legacy`
- `dm/DRCH2.dm` (mode selection) → `archive/DRCH2.dm.legacy` (keep reference only)

---

## Summary: Design Decisions (User-Approved)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **A-1: Gender** | Male/Female binary | Simplifies avatar, visual consistency |
| **A-2: Equipment** | Seamless transmutation (C) | Feels like real magic, not inventory swap |
| **A-3: Customization** | Prestige-gated (C+B hybrid) | Teaches players via Sandbox, rewards with freedom |
| **B-4: Inventory** | Personal lockers + whitelist (A) | Prevents mode exploitation, cosmetics persist |
| **B-5: Death** | Reset at port, preserve skills (D) | Graceful re-entry, progression saved |
| **C-6: Classes** | Optional, hard mode blank (C) | Encourages learning, preserves challenge |
| **C-7: Specializations** | NPC titles, cosmetic (C) | Lore flavor, no mechanical advantage |
| **D-8: Owner** | Hardcoded single role (B) | Simple, clear authority structure |
| **D-9: Admin Testing** | Toggle between modes (A) | Experience actual gameplay, verify systems |
| **D-10: Hierarchy** | Master GM controls all (C) | Clear authority, prevents rogue GMs |
| **E-11: Port** | B (multi), C (SP), A (offline) | Gameplay-first hub, privacy preserved |
| **E-12: Access** | Anytime, exploit-protected (B) | Freedom + fairness |
| **F-13: Lives** | Per-continent, respects host setting (B) | Customizable difficulty per game mode |
| **F-14: Death Integration** | Lives = reset, permadeath = permanent (B) | Clear consequences, respects death system |

---

## Next Steps

1. **User approval** of design (this document)
2. **Phase 1 implementation** (blank avatar + prestige system)
3. **Parallel work** (port hub, equipment transmutation)
4. **Integration testing** (full login flow)
5. **Legacy cleanup** (archive old systems)
6. **Final verification** (build status = 0 errors)

