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
Procedurally-generated world with **narrative anchors** that ensure consistent story progression while maintaining infinite replayability.

**Philosophy**: Same story beats, different world every playthrough.

### **World Structure**

```
PROCEDURAL LAYERS:
├─ Base Terrain (Biomes)
│  ├─ Temperate (forests, grasslands)
│  ├─ Arctic (snow, mountains)
│  ├─ Desert (sand, oasis)
│  └─ Rainforest (jungle, canopy)
│
├─ Towns (Procedurally Placed Story Anchors)
│  ├─ Kingdom of Freedom (starting region mentor hub)
│  ├─ Kingdom of Behist (advanced crafting hub)
│  ├─ Various smaller settlements (skill-gated access)
│  └─ Each town: Bank, Blacksmith, Healer, Tavern, Housing
│
├─ Wilderness (Procedural Dungeons & Encounters)
│  ├─ Forests (creatures, resources, hidden groves)
│  ├─ Mountains (ore deposits, caves, hermit settlements)
│  ├─ Rivers (fishing, water wheels, crossings)
│  └─ Ruins (lore, rare materials, story locations)
│
└─ Portals (Guarantee Connectivity)
   ├─ Start → Kingdom of Freedom (always reachable)
   ├─ Kingdom of Freedom ↔ Kingdom of Behist (story progression gate)
   ├─ Kingdom of Behist → Adventure Zones (skill-gated access)
   └─ All zones → Port Town (escape to other worlds)
```

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
