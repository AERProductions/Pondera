# Pondera: Three-World MMO RPG Architecture

**Date**: December 6, 2025  
**Vision**: Unified character progression across procedurally-generated story world, peaceful sandbox, and competitive PvP survival  
**Status**: Architecture & Design Phase  
**Build**: ✅ Clean (0 errors)

---

## Executive Summary

Pondera evolves from a single-world design into a **three-connected-worlds architecture** serving different player philosophies:

1. **Story Continent (Aldoryn)**: Procedurally-generated world with handcrafted narrative anchors
2. **Sandbox Continent (Peaceful)**: Unlimited creative building, no combat, no NPCs, no pressure
3. **PvP Continent (Survival)**: Strategic fortification, raiding, territory control, competitive progression

**Single character progression** spans all three worlds. Players choose their experience path without interference from others.

---

## World 1: Story Continent (Aldoryn)

### **Core Concept**
Procedurally-generated world divided into **five feudal kingdoms**, each representing a societal archetype and story progression tier. Four allied kingdoms vs. one adversarial kingdom drives the central narrative conflict. Each kingdom features:
- **Central Hub City** (seat of power, story milestone, economic center)
- **Villages & Settlements** (farming communities, craftspeople, story NPCs)
- **Outposts & Wilderness** (scattered adventure locations, rare resources, encounters)

**Philosophy**: Same story progression and kingdom structure, infinite wilderness variation per playthrough.

### **The Five Kingdoms**

#### **1. Kingdom of Freedom** (Temperate, Foundational)
- **Theme**: Liberty, independence, fundamental survival and community
- **Geography**: Forests, grasslands, rivers, accessible terrain
- **Hub City**: City of the Free (starting sanctuary, mentorship center)
- **Architecture**: Practical wood and stone, welcoming design
- **Key NPCs**: Guard Captain, Hunter, Blacksmith, Healer, Innkeeper
- **Story Role**: Tutorial/onboarding, foundational skills, community values
- **Skill Gates**: None (accessible immediately)
- **Resources**: Wood, common stone, copper ore, basic crops
- **Allegiance**: Allied (foundational)
- **Progression**: Freedom → Belief (requires Smithing 2+)

#### **2. Kingdom of Belief** (Hilly, Scholarly) [Behist]
- **Theme**: Faith, knowledge, enlightenment, magical understanding
- **Geography**: Rolling hills, ancient ruins, temple complexes, sacred groves
- **Hub City**: Spire of Behist (nexus of learning, crafting hub, library)
- **Architecture**: Stone temples, scholarly gardens, enchantment circles
- **Key NPCs**: Master Smith, Alchemist, Librarian, Monk, Architect
- **Story Role**: Advanced crafting mastery, recipe discovery, magical lore
- **Skill Gates**: Smithing 2+, Harvesting 3+
- **Resources**: Rare ore, alchemical plants, ancient artifacts, enchantment materials
- **Allegiance**: Allied (wisdom keepers)
- **Progression**: Belief → Honor or Pride (multiple paths, player chooses)

#### **3. Kingdom of Honor** (Forests/Foothills, Chivalric)
- **Theme**: Righteousness, justice, noble virtue, protection of the weak
- **Geography**: Dense forests, rolling foothills, sacred groves, watchtowers
- **Hub City**: Keep of Honor (knightly stronghold, justiciar courts, healing temple)
- **Architecture**: Elegant stone keeps, training yards, memorial gardens
- **Key NPCs**: Paladin, Justice Warden, Temple Healer, Knight Captain, Virtue Sage
- **Story Role**: Moral choices, righteous quests, noble causes, protecting villages
- **Skill Gates**: Combat 2+, Moral alignment quests
- **Resources**: Holy relics, blessed ores, healing herbs, noble materials
- **Allegiance**: Allied (moral anchor)
- **Special**: Moral alignment system, knightly orders, virtue-based quests
- **Progression**: Honor ↔ Pride (knightly brotherhood)

#### **4. Kingdom of Pride** (Mountains, Martial)
- **Theme**: Strength, honor, martial excellence, legendary achievement
- **Geography**: Mountains, fortresses, plateaus, crystalline caves
- **Hub City**: Castle of Pride (military headquarters, tournament grounds, war room)
- **Architecture**: Imposing stone fortifications, training grounds, trophy halls
- **Key NPCs**: War Champion, Armor Smith, General, Mercenary Captain, Weaponsmith
- **Story Role**: High-level combat, elite equipment, legendary weapons, martial rankings
- **Skill Gates**: Combat 4+, Smithing 3+, Strategy-based quests
- **Resources**: Mithril-tier ore, dragon scales, legendary materials, war-forged steel
- **Allegiance**: Allied (military strength)
- **Special**: Arena rankings, dueling system, legendary weapon quests
- **Progression**: Pride ↔ Honor (knightly alliance); Prime endgame path

#### **5. Kingdom of Greed** (Coastal, Economic) [ANTAGONIST]
- **Theme**: Avarice, exploitation, unchecked ambition, corruption
- **Geography**: Coastal ports, merchant districts, corrupt harbor towns, slum areas
- **Hub City**: Port of Plenty (exploitative trading hub, corruption nexus, black market)
- **Architecture**: Gaudy merchant mansions, slave docks, fortified counting houses, slums
- **Key NPCs**: Merchant Prince, Slave Master, Corrupt Judge, Black Market Broker, Tax Collector
- **Story Role**: Economic antagonist, moral corruption, exploitation quests, resistance storylines
- **Skill Gates**: Wealth-based (requires minimum lucre) + Trading 3+
- **Resources**: Luxury goods, black market contraband, slave labor products, stolen artifacts
- **Allegiance**: OPPOSED (antagonistic force seeking domination)
- **Special**: Moral conflict zones, rebellion quests, resistance networks, redemption paths
- **Progression**: Greed ↔ Resistance (allied kingdoms work to contain/reform Greed)

### **Story Conflict Framework**

The central narrative tension:
- **Four Allied Kingdoms** (Freedom, Belief, Honor, Pride) represent virtues: liberty, wisdom, justice, strength
- **Kingdom of Greed** represents vice: unchecked avarice and exploitation
- **Player Agency - True Choice System**: Players can:
  1. **Heroic Path**: Support the allied kingdoms fighting Greed's oppression (traditional hero)
  2. **Villain Path**: Join Kingdom of Greed and help dominate the other kingdoms (play the antagonist)
  3. **Revolutionary Path**: Challenge Greed's corruption from within resistance movements (rebel)
  4. **Pragmatist Path**: Navigate neutrality, profit from conflict without moral commitment (merchant)
  5. **Moralist Path**: Expose hypocrisy in allied kingdoms while resisting Greed (idealist)

**Key Design**: Player choice affects:
- **Reputation** with each kingdom (ally/enemy/neutral status)
- **Quest availability** (different quests per allegiance)
- **NPC reactions** (some allies, some enemies based on path)
- **Rewards & recipes** (unique to chosen path, some exclusive to villain route)
- **Story events** (different cutscenes, encounter outcomes, ending variations)
- **PvP interactions** (allied players cooperate, opposed players conflict)
- **Stall access** (heroes use legitimate markets, villains use black markets)

### **World Structure Hierarchy**

```
STORY CONTINENT (ALDORYN):

Kingdom of Freedom (Starting Region - No Gates)
├─ City of the Free (Hub, permanent home base)
├─ 3-5 farming villages (scattered procedurally)
├─ 2-3 wilderness outposts
└─ Mentor NPCs guarantee all basic recipes
└─ CHOICE POINT: Join freedom defenders or take Greed's coin?

Kingdom of Belief (Scholarly Region - Gated: Smithing 2+)
├─ Spire of Behist (Hub, crafting center)
├─ 3-5 monastic/library settlements (procedurally placed)
├─ 2-3 ruin exploration sites (adventure locations)
└─ Master crafters teach advanced recipes
└─ CHOICE POINT: Pursue wisdom or steal alchemical secrets for Greed?

Kingdom of Honor (Chivalric Region - Gated: Combat 2+ & Reputation)
├─ Keep of Honor (Hub, knightly stronghold)
├─ 3-5 noble settlements (villages, watchtowers, temples)
├─ 2-3 justiciar sites (courts, defense posts, memorial sites)
└─ Knights teach virtue and protection-based gameplay
└─ CHOICE POINT: Take the knightly oath or sabotage them for coin?

Kingdom of Pride (Military Region - Gated: Combat 4+ & Reputation)
├─ Castle of Pride (Hub, combat center)
├─ 3-5 military settlements (training villages, garrisons)
├─ 2-3 arena/battle sites (dueling tournaments, legendary encounters)
└─ War champions teach legendary weapon crafting
└─ CHOICE POINT: Defend against Greed or become Greed's military asset?

Kingdom of Greed (Economic Region - ANTAGONIST - Multiple Entry Points)
├─ Port of Plenty (Hub, corrupt trading nexus)
├─ 3-5 exploitative settlements (slave ports, black markets, fortified mansions)
├─ 2-3 resistance sites (hidden rebel bases, underground networks, liberation camps)
└─ VILLAIN PATH: Climb ranks, recruit allies, dominate trade and territory
└─ REBEL PATH: Secretly work with resistance to liberate enslaved peoples
└─ PRAGMATIST PATH: Trade with everyone, exploit market instability
```

### **Reputation & Allegiance System**

Each player has a **reputation variable** tracking standing with all 5 kingdoms:

```
player_reputation = list(
	"freedom" = 0,        // -100 (enemy) to +100 (hero)
	"belief" = 0,
	"honor" = 0,
	"pride" = 0,
	"greed" = 0           // Negative = resisting, positive = collaborating
)
```

**Reputation Effects**:
- **-100**: Hunted (enemies attack on sight, banned from kingdom)
- **-50**: Hostile (NPCs won't trade, guards bar entry)
- **-25**: Distrusted (expensive prices, limited quests)
- **0**: Neutral (normal prices, standard quests)
- **+25**: Respected (small discounts, special quests)
- **+100**: Honored (titles, unique quests, exclusive recipes, faction leader status)

**Faction-Specific Gains**:
- Help Freedom → gain Freedom reputation (unlocks hero quests, defensive lore)
- Help Greed → gain Greed reputation (unlocks villain quests, exploitation recipes)
- Betray kingdoms → lose reputation with that kingdom, gain with enemy
- Expose hypocrisy → gain reputation with moralists, lose with hypocrites

---

## **Affinity System & PvP Safeguards**

### **What is Affinity?**

**Affinity** is the player's net moral alignment derived from reputation:

```
player_affinity = (freedom + belief + honor + pride) - greed
```

- **Strong Light Affinity** (+200+): Virtuous path, anti-corruption, natural hero
- **Light Affinity** (+50 to +200): Aligned with allied kingdoms
- **Neutral** (-50 to +50): Pragmatist, fence-sitter, opportunist
- **Dark Affinity** (-200 to -50): Committed to Greed's dominion
- **Strong Dark Affinity** (-200-): Villain path, full corruption, natural antagonist

### **Affinity Applications**

#### **1. Magic System (Story & Sandbox)**
- **Light Magic**: Healing, protection, purification (requires light affinity)
- **Dark Magic**: Corruption, domination, exploitation (requires dark affinity)
- **Neutral Magic**: Transmutation, elemental, utility (no affinity lock)
- **Hybrid Magic**: Forbidden spells unavailable until player commits to path

#### **2. Luck & Fortune (All Modes)**
- **Light Affinity**: +luck in noble endeavors, harvest bonus, NPC aid
- **Neutral**: Standard luck
- **Dark Affinity**: +luck in theft, deception, corruption, resource extraction
- Creates natural playstyle advantages for chosen path

#### **3. NPC Interaction (Story Mode)**
- **Light Affinity**: NPCs help willingly, quests easier, better prices
- **Dark Affinity**: NPCs demand higher prices, can be bribed/coerced for dark quests
- **Neutral**: Standard interaction

#### **4. Environmental Effects (Story Mode)**
- **Light Path**: Healing wells, protective auras in allied kingdoms
- **Dark Path**: Corrupted ruins, forbidden knowledge in Greed territory
- **Neutral Path**: Standard environment, fewer bonuses

### **Story Mode PvP Safeguards**

**Critical Design Decision**: Story mode allows **ideological conflict but prevents griefing**.

#### **Rule 1: Level-Gated Conflict**
- Players can only attack enemies within **±5 levels** of their own level
- Exception: Equal-level dueling (arenas, agreed combat)
- Prevents high-level villains from steamrolling low-level heroes

#### **Rule 2: Reputation-Gated Attacks**
- Players can only attack in **kingdom territory matching their allegiance**
- **Light Affinity Heroes**: Can attack dark affinity players in allied kingdoms
- **Dark Affinity Villains**: Can attack light affinity players in Greed territory
- **Neutral Players**: Cannot initiate attacks (defensive only)
- Prevents griefing across all territories

#### **Rule 3: Safe Zones & Sanctuaries**
- **Starting town** (City of the Free): Always safe, no PvP
- **Kingdom hubs**: Safe zones for aligned players (you can't attack allies in their capital)
- **Neutral market areas**: Safe trade zones (no PvP)
- **Wilderness**: Open PvP (level-gated, reputation-gated)

#### **Rule 4: Consensus-Based Conflict**
- Large-scale kingdom vs. kingdom warfare **requires player consensus**
- If heroes and villains declare war, conflict becomes explicit and server-wide
- War periods are **announced with 24-hour notice** (real time)
- War zones are **designated beforehand** (not the entire story world)
- Post-war peace periods prevent constant griefing

#### **Rule 5: Consequence & Recovery**
- Defeating players yields **no XP** (no incentive to camp lowbies)
- Defeated players recover quickly (**25% health in sanctuary**)
- Reputation loss from attacking much weaker players (cowardice penalty)
- Defeated players can request **safe passage** to sanctuary

### **Sandbox & PvP Mode Contrast**

| Feature | Story Mode | Sandbox | PvP Mode |
|---------|-----------|---------|----------|
| **Affinity Lock** | Soft (can switch) | None (irrelevant) | Hard (determines side) |
| **PvP Rules** | Strict (level/reputation gated) | None (creative only) | Loose (open warfare) |
| **Safe Zones** | Many (hubs, start) | None (creative freedom) | Strategic points |
| **Griefing** | Heavily protected | N/A | Allowed/encouraged |
| **Conflict Type** | Ideological | N/A | Territorial & resource |
| **Consequence** | Reputation shifts | N/A | Territory loss |

### **Managing Ideological Conflict**

**Design Goal**: Create **meaningful opposition** without **toxic griefing**.

**Mechanics**:
1. **Explicit Enemy Status**
   - Light Affinity & Dark Affinity players show as "Enemy" overhead
   - Natural conflict emerges from player choice, not forced mechanics
   
2. **Territory Control (Non-Griefing)**
   - Villains can take control of Greed towns (requires coordinated effort)
   - Heroes can liberate Greed towns (raids, sieges, story events)
   - Control grants faction NPCs & quest access, not permanent dominion
   
3. **Quest Conflict**
   - Hero quest: "Protect village from Greed bandits"
   - Villain quest: "Raid village for Greed's profit"
   - Same location, opposing objectives, natural conflict
   - Low-level protection quests don't target high-level villains
   
4. **Peaceful Coexistence Option**
   - Players can **opt out of conflict** (neutral affinity)
   - Neutral players trade with both sides, take neither's quests
   - No forced participation in ideological war

### **Implementation Checklist**

- [ ] Affinity calculation system (Phase 6)
- [ ] Magic affinity locks (Phase 7)
- [ ] Luck system tied to affinity (Phase 6)
- [ ] PvP level-gating enforcement (Phase 6)
- [ ] Reputation-based attack restrictions (Phase 6)
- [ ] Safe zone system (Phase 5)
- [ ] War declaration mechanics (Phase 8)
- [ ] Consequence system for bullying (Phase 6)
- [ ] Territory control system (Phase 8)

### **World Structure Hierarchy**

```
STORY CONTINENT (ALDORYN):

Kingdom of Freedom (Starting Region - No Gates)
├─ City of the Free (Hub, permanent home base)
├─ 3-5 farming villages (scattered procedurally)
├─ 2-3 wilderness outposts
└─ Mentor NPCs guarantee all basic recipes

Kingdom of Belief (Scholarly Region - Gated: Smithing 2+)
├─ Spire of Behist (Hub, crafting center)
├─ 3-5 monastic/library settlements (procedurally placed)
├─ 2-3 ruin exploration sites (adventure locations)
└─ Master crafters teach advanced recipes

Kingdom of Honor (Chivalric Region - Gated: Combat 2+ & Moral Alignment)
├─ Keep of Honor (Hub, knightly stronghold)
├─ 3-5 noble settlements (villages, watchtowers, temples)
├─ 2-3 justiciar sites (courts, defense posts, memorial sites)
└─ Knights teach virtue and protection-based gameplay

Kingdom of Pride (Military Region - Gated: Combat 4+)
├─ Castle of Pride (Hub, combat center)
├─ 3-5 military settlements (training villages, garrisons)
├─ 2-3 arena/battle sites (dueling tournaments, legendary encounters)
└─ War champions teach legendary weapon crafting

Kingdom of Greed (Economic Region - ANTAGONIST - Gated: Wealth + Exploration)
├─ Port of Plenty (Hub, corrupt trading nexus)
├─ 3-5 exploitative settlements (slave ports, black markets, fortified mansions)
├─ 2-3 resistance sites (hidden rebel bases, underground networks, liberation camps)
└─ NPCs teach merchant skills AND moral corruption resistance
```

### **Procedural Generation Rules**

### **Procedural Generation Rules**

#### **Towns (NPCState Anchors)**
```dm
// Town Generator: Ensures narrative consistency despite randomness

proc/GenerateTown(town_type, location)
  // town_type = "freedom_hub" | "behist_hub" | "settlement" | "outpost"
  
  switch(town_type)
    if("freedom_hub")
      // Kingdom of Freedom always has these NPCs:
      spawn_npc("Blacksmith", recipe_teaches = ["stone_hammer", "iron_hammer"])
      spawn_npc("Healer", recipe_teaches = ["healing_knowledge"])
      spawn_npc("Innkeeper", recipe_teaches = ["shelter", "comfort"])
      spawn_npc("Guard Captain", recipe_teaches = ["combat_basics"])
      
      // Town layout procedurally varies but always has:
      // - Central square (gathering point)
      // - Smithy (always has forge)
      // - Healer's hut (always has resources)
      // - Inn (always has beds)
      // - Bank (always accessible)
      
      // But the exact locations are different each playthrough
      generate_town_layout("freedom_hub", location)
    
    if("behist_hub")
      spawn_npc("Master Smith", recipe_teaches = ["steel_tools", "advanced_smithing"])
      spawn_npc("Alchemist", recipe_teaches = ["refinement", "enchantments"])
      spawn_npc("Architect", recipe_teaches = ["advanced_building"])
      
      generate_town_layout("behist_hub", location)
    
    if("settlement")
      // Smaller towns, random specialization
      var/specialization = pick("farming", "hunting", "crafting", "trade")
      spawn_settlement_npcs(specialization, location)
      generate_settlement_layout(specialization, location)
```

#### **Wilderness Generation**
```dm
proc/GenerateWilderness(biome_type, region)
  // Ensure narrative paths exist despite randomness
  
  // Step 1: Generate base terrain (biome-specific resources)
  GenerateMap(biome_type, region)
  
  // Step 2: Ensure story locations are reachable
  var/list/story_points = GetStoryPointsForRegion(region)
  for(var/location in story_points)
    EnsurePathExists(location)  // Guarantee player can reach it
  
  // Step 3: Add dynamic encounters (non-blocking)
  SpawnCreatures(biome_type, region)
  SpawnResourceDeposits(biome_type, region)
  SpawnDungeons(biome_type, region)
  
  // Step 4: Add environmental storytelling
  PlaceRelics(biome_type, region)        // Lore hints
  PlaceAncientSites(biome_type, region)  // Hidden story locations
```

#### **Connectivity Guarantee**
```dm
proc/EnsurePathExists(source, destination)
  // Use A* pathfinding with story-aware heuristic
  // Ensure player can always walk from Point A to Point B
  
  var/path = AStar(source, destination)
  
  if(!path)
    // Path blocked! Generate corridor/passage
    GenerateConnectingPath(source, destination)
  
  // Validate no one-way passages
  if(!AStar(destination, source))
    // Oops, can't go back. Fix it.
    GenerateReturnPath(destination, source)
```

### **Story Progression Framework**

**Gate 1: Kingdom of Freedom**
```
Entry: New player spawns, finds shelter
Mentors: Blacksmith, Healer, Innkeeper, Guard Captain
Recipes: Stone Hammer, Carving Knife, Iron Hammer, Basic Cooking
Skills: Mining 0→1, Smithing 0→2, Building 0→1
Gate: Must reach Smithing level 2 to leave for Behist
```

**Gate 2: Kingdom of Behist**
```
Entry: Player learns advanced smithing, seeks mastery
Mentors: Master Smith, Alchemist, Architect
Recipes: Steel tools, Refinement techniques, Advanced structures
Skills: Smithing 2→5, Refining 0→3, Building 1→4
Gate: Must reach Smithing level 5 to unlock Adventure Zones
```

**Adventure Zones (Unlocked at High Skills)**
```
Arctic Wastes (Survival focus, rare ores)
Rainforest Temple (Exploration, ancient recipes)
Desert Tombs (Combat, treasure)
Mountain Peaks (Legendary crafting)
```

### **NPC System Integration**

Each NPC carries `npc_state` datum:
```dm
datum/npc_state
  var
    npc_name = "Master Smith"
    npc_role = "crafting_mentor"  // Defines what recipes taught
    town_location = "behist_hub"   // Generic town type (location varies)
    teaches_recipes = list(...)    // Recipe list
    skill_gates = list(...)        // Prerequisites
    dialogue_branches = list(...)  // Dynamic dialogue
    player_history = list()        // Who's talked to this NPC
```

When NPC spawns in procedurally-generated town:
- NPC always appears in appropriate building (Blacksmith in smithy)
- NPC recipe teaching remains consistent
- Dialogue acknowledges local town details
- Player still feels world is coherent despite procedural variation

### **Environmental Storytelling**

**Without handcrafted narrative**, story is told through:
- **NPC dialogue**: "Why are you in this remote outpost? Seeking refuge?"
- **Architecture**: Town layouts reflect local materials (desert towns use sandstone)
- **Resources**: Biome resources hint at local economy
- **Encounters**: Who/what you meet tells you about the region
- **Progression gates**: "To learn master smithing, seek Behist"

**Result**: Feels like real world with history, despite being procedural

---

## World 2: Sandbox Continent (Peaceful)

### **Core Concept**
Infinite creative building with no narrative pressure, no NPCs, no combat, no resource competition.

**Philosophy**: Build your dream, at your pace, uninterrupted.

### **Design**

**Features**:
- ✅ All recipes available from start (no NPC gating)
- ✅ Infinite building space (procedural terrain)
- ✅ No monsters (peaceful environment)
- ✅ No players (solo or small group mode)
- ✅ No time pressure (no "story progression" to chase)
- ✅ Shared skills with Story world (recipes learned here count there)

**Use Cases**:
- Practice crafting before story
- Creative building experiments
- Relaxing creative mode
- Tutorial/learning space

**Map Style**:
- Procedurally generated like Story world
- But NO story gates, NO NPCs, NO encounters
- Pure canvas for player creativity

---

## World 3: PvP Continent (Survival)

### **Core Concept**
Strategic territory control, base fortification, raiding, competitive progression.

**Philosophy**: This is where your evolved sandbox mode becomes competitive design.

### **Key Mechanics**

**Territory Claims**:
```dm
// Players claim land (e.g., 100x100 turf grid)
var/territory
  var/owner_key              // "playerkey"
  var/territory_bounds[4]    // [x1, y1, x2, y2]
  var/control_level = 0      // 0-10 (fortification tier)
  var/last_claimed = 0       // Timestamp
  var/resources_stored[]     // Bank of claimed resources
```

**Fortification**:
```dm
// Walls, gates, watchtowers prevent raids
// Destroy walls to breach territory
// Control choke points for defense

obj/structure/wall
  var/hp = 100
  var/territory_owner
  
  proc/DealDamage(amount)
    hp -= amount
    if(hp <= 0)
      territory_owner.AlertOwner("Wall breached!")
      del(src)  // Wall destroyed
```

**Raiding System**:
```dm
// Players raid for resources, territorial gain
proc/AttemptRaid(attacker, defender_territory)
  // Check: Can attacker breach defenses?
  // Check: Does attacker have raiding equipment?
  // If successful: Transfer resources, reduce territory control
  // If defensive: Defender gets warning, can reinforce
```

**Progression (Combat-Focused)**:
```
Kills → Combat XP → Combat Rank
Territory Held → Territory XP → Territory Rank
Resources Controlled → Economic XP → Economic Rank

Ranks unlock:
- Better weapons
- Stronger structures
- Territory expansion limits
- Raiding bonuses
```

**Creatures/Threats**:
- NPCs with siege AI (not friendly mentors, enemy forces)
- Environmental hazards
- Dynamic events (season changes, meteor showers, disease)

### **Design Philosophy**

This isn't a "PvE sandbox + PvP tag". It's intentional competitive design:
- Scarce resources (unlike Sandbox, resources here are limited)
- Strategic locations matter (hills overlook plains, control wins fights)
- Skill matters (combat, tactics, economy)
- Social matters (alliances, diplomacy, trade)
- Risk/reward (raid to get rich, but lose territory if defeated)

---

## Multi-World Character Progression

### **What Persists Across Worlds**

```
Character Data (Shared):
├─ Skills & Experience (Smithing level 5 everywhere)
├─ Recipes Discovered (Iron Hammer unlocked everywhere)
├─ Knowledge Topics (Smithing topic learned everywhere)
├─ Biome Discoveries (Visited forest = visited on all worlds)
├─ Character Progression (XP, ranks, achievements)
│
└─ NOT Shared (World-Specific):
   ├─ Inventory (keep items in each world)
   ├─ Equipment (worn gear per world)
   ├─ Buildings (only exist on building continent)
   ├─ Territory (only on PvP continent)
   ├─ Discovered Locations (story points vary per procedural generation)
   └─ Player Position (respawn at port when switching worlds)
```

### **Player Stall System (Cross-World Trading)**

Each continent features a **per-continent stall system** tailored to its gameplay:

#### **Story Continent: NPC-Rented Merchant Stalls**
```dm
/obj/npc_merchant_stall
  // Player rents stall from NPC merchant
  // NPC handles sales while player offline
  // Player earns profits (10% commission to NPC)
  
  var
    owner_name = ""           // Character who rents stall
    stall_name = ""           // "Glom's Smithing Supplies"
    inventory = list()        // Up to 20 items for sale
    prices = list()           // Prices per item
    daily_profit = 0          // Earnings from NPC sales
    
  proc/AddToStall(obj/item, price)
    if(inventory.len >= 20) return 0
    inventory += item
    prices[item.id] = price
    return 1
  
  proc/NPC_SellItem()
    // Called by NPC merchant proc every 10 ticks
    // If customer wants item, NPC sells at list price
    // Takes 10% commission, adds 90% to owner's profits
```

**Economics**:
- Player inputs goods → NPC manages sales
- Passive income when offline
- Profits go to global character account (usable across worlds)
- Encourages engagement with story world economy

**Location**: Found in story towns (Kingdom of Freedom, Kingdom of Behist, settlements)

#### **Sandbox Continent: Player-Crafted Market Stalls**
```dm
/obj/market_stall
  // Player-built furniture object
  // Can be placed anywhere, customized, decorated
  
  var
    owner_name = ""
    stall_name = ""
    contents = list()         // Unlimited items (player chooses limit)
    prices = list()
    is_locked = 0             // Can be closed/opened by owner
    
  New()
    ..()
    name = "Market Stall"
    desc = "A vendor stall. Click to browse."
    icon = 'dmi/furniture.dmi'
    icon_state = "stall"
  
  Click(mob/players/M)
    if(M == owner) OpenOwnerUI(M)
    else OpenBuyerUI(M)
  
  proc/OpenBuyerUI(mob/players/buyer)
    // Shows items + prices
    // Buyer clicks item to purchase
    // Instant transaction, no NPC middleman
    
  proc/OpenOwnerUI(mob/players/owner)
    // Owner can add items, set prices, collect profits
    // Can lock stall to prevent access
```

**Building Requirements**:
- Costs: 20 wood + 20 stone (craftable)
- Can be placed in player-owned plots or public areas
- Can be decorated (signs, lights, banners)

**Economics**:
- No commission (direct peer-to-peer)
- All profits go directly to seller
- Encourages player markets and trading hubs

**Location**: Player-placed anywhere (homes, market districts, trading plazas)

#### **PvP Continent: Fortified Trading Posts**
```dm
/obj/structure/trading_post
  // Built within player territory
  // Can be raided, destroyed, defended
  // High-risk, high-reward economy
  
  var
    territory_owner = ""
    contents = list()
    prices = list()
    vault_level = 0           // Defensive level (harder to raid)
    is_locked = 1             // Always locked by default
    hp = 200                  // Can be destroyed by attackers
    
  proc/DealDamage(amount)
    hp -= amount
    if(hp <= 0)
      // Stall destroyed, contents lootable
      territory_owner.AlertOwner("Trading post destroyed!")
      SpillContents()
      del(src)
  
  proc/SpillContents()
    // Items drop on ground, raiders can loot
    for(var/item in contents)
      item.loc = src.loc
```

**Economics**:
- Profits from sales
- BUT contents can be stolen via raiding
- Vault upgrades increase raid difficulty
- Territory control = economic control

**Location**: Built in player territories on PvP continent

#### **Cross-Continent Profit Sharing**
```dm
// Profits are NOT continent-specific
// Profit earned in Story world (NPC stall) = Global account
// Can be spent in any continent
// Example workflow:
//   1. Grind story world → Build profit at NPC stall
//   2. Withdraw profits → Stock sandbox market
//   3. Trade in sandbox → Accumulate wealth
//   4. Transfer to PvP → Build trading post + defense
```

**Design Philosophy**:
- Each continent's stall system reflects its gameplay
- Story: Passive income from participation
- Sandbox: Direct trading between players
- PvP: Economic warfare (stalls as raid targets)
- Profits ARE shared (encourages cross-world engagement)

### **Travel System (Portals & Port Ships)**

**Two complementary travel methods** enable world-switching:

#### **Teleportation Portals** (Instant, Magic-Based)
```dm
/obj/portal
  // Instant magical travel between continents
  // Found at designated portal locations
  // One-way or two-way depending on design
  
  Click(mob/players/M)
    TravelToContinent(M, destination_continent)
```

**Usage**:
- Fast travel to known locations
- Can be restricted/gated by story progression
- Portal hubs in major towns

#### **Port Ships** (Immersive, Traveling, Economy-Based) [FUTURE]
```dm
/obj/ship
  // Seagoing vessel traveling between port towns
  // Passengers board, ship travels to destination
  // Creates downtime and world immersion
  
  var
    current_port = ""         // Which port currently docked
    destination = ""          // Where ship is sailing
    passengers = list()       // Who's aboard
    cargo = list()            // Trade goods
    departure_time = 0        // When ship leaves
    arrival_time = 0          // When ship arrives
    
  proc/Board(mob/players/player)
    // Player enters ship, gets teleported on arrival
    // Creates journey roleplay moment
    
  proc/Travel()
    // Simulate journey over several minutes
    // Arrive at destination, unload passengers
```

**Economy Impact**:
- Ship captains (NPC or player-controlled)
- Cargo trading between ports (economic gameplay)
- Costs (passage fees, cargo fees)
- Timing matters (ships have schedules)

**Design Note**: 
Both systems coexist. Portals provide instant convenience travel for gameplay. Ships provide immersive, economic travel for roleplay and resource movement. Can be unlocked/unavailable depending on story progression.

### **Port Town (on each continent)**
```dm
mob/players/verb/TravelToContinent()
  set category = "Travel"
  var/continent = input("Travel to:", "Continent") in list("Story", "Sandbox", "PvP")
  
  switch(continent)
    if("Story")
      loc = locate(port_x, port_y, STORY_Z)  // Port town on Story Continent
    if("Sandbox")
      loc = locate(port_x, port_y, SANDBOX_Z)
    if("PvP")
      loc = locate(port_x, port_y, PVP_Z)
```

**Practical Effect**:
- Switch worlds instantly at ports
- Keep learned skills/recipes
- Keep profits/money (shared across worlds)
- But inventory/equipment separate per world
- Buildings don't travel (you can't take your house)
- Stalls persist independently per continent
- Character feels "equipped for this world" not "displaced"

---

## Implementation Roadmap

### **Phase A: Architecture Foundation** (6-8 hours)
1. Create world/continent ID framework
2. Implement travel system (ports, world switching)
3. Ensure recipe_state persists across worlds
4. Create continent-specific rule sets

### **Phase B: Procedural Town Generator** (8-10 hours)
1. Build town layout generator (maintains Kingdom of Freedom aesthetic)
2. Create NPC placement system (roles → buildings)
3. Implement story anchor system (ensure NPCs always teach right recipes)
4. Test: Towns feel cohesive and narratively consistent

### **Phase C: Story World Integration** (6-8 hours)
1. Integrate town generator with existing map generation
2. Ensure connectivity A→B
3. Place story gates (Kingdom progression)
4. Implement NPC recipe discovery on story continent

### **Phase D: Sandbox Continent Setup** (2-3 hours)
1. Create infinite building canvas
2. Disable story gates, NPCs, encounters
3. Enable all recipes immediately
4. Test: Pure creative mode works

### **Phase E: PvP Continent Mechanics** (12-15 hours)
1. Territory claim system
2. Fortification/raiding mechanics
3. Combat XP progression
4. Dynamic events
5. Testing & balancing

### **Phase F: Multi-World Integration** (4-5 hours)
1. Cross-world skill sharing
2. Multi-world character data persistence
3. Testing character progression continuity

**Total Estimated**: 38-49 hours over 4-5 weeks

---

## Design Decisions Made

### **Procedural Story World (NOT Handcrafted)**
- ✅ Infinite replayability (different world each time)
- ✅ Scalable to multiplayer (different shards can have different worlds)
- ✅ Leverages procedural generator already built
- ✅ Modern MMO design pattern

### **Single Character, Three Experiences (NOT Mode Selection)**
- ✅ Skills progress together (learning helps everywhere)
- ✅ No "locked out" content (can do all three)
- ✅ Social cohesion (same player base, different zones)
- ✅ Less technical complexity (no per-mode datastores)

### **Story Anchors (NOT Fully Handcrafted, NOT Fully Random)**
- ✅ NPCs remain consistent (Blacksmith always teaches smithing)
- ✅ World varies (town layout different each time)
- ✅ Story progresses logically (progression gates maintained)
- ✅ Replayability without losing narrative

---

## Risk Assessment & Mitigations

### **Risk 1: Procedural World Feels Generic**
**Mitigation**: Environmental storytelling (NPC dialogue, architecture reflects biome, lore hints through placement)

### **Risk 2: Connectivity Fails (Can't Reach Story Gate)**
**Mitigation**: A* pathfinding with fallback corridor generation; test every playthrough

### **Risk 3: NPCs in Wrong Locations**
**Mitigation**: Town generator ensures appropriate buildings (Blacksmith in smithy) before NPC spawn

### **Risk 4: Three Continents Feel Disconnected**
**Mitigation**: Port towns, shared progression, unified character, travel system

### **Risk 5: PvP Too Brutal for Casual Players**
**Mitigation**: Separate continent (players choose to be there); Sandbox & Story remain safe

---

## Next Immediate Actions

1. **Document NPCState Integration for Story Continent** (clarify what changes to npcs.dm)
2. **Design Town Generator Algorithm** (layout, building placement, NPC assignment)
3. **Create Continent Framework in Code** (world IDs, travel system)
4. **Begin Phase A: Architecture Foundation** (6-8 hours of coding)

---

## Vision Summary

**Pondera becomes**:
- A story-driven MMO where narrative unfolds procedurally
- A sandbox creative playground where building is pure expression
- A competitive PvP world where strategy and tactics matter
- One character, three worlds, infinite replayability
- Where players choose their own adventure without blocking others

**The old Aldoryn maps become** narrative reference material for procedural rules.

**The result**: A game bigger than the sum of its parts.

---

**Ready to begin Phase A: Architecture Foundation?**
