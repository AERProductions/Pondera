# Kingdom of Greed: Quick Reference Guide

## TL;DR: What is the Crater?

An **unknown entity fell from the sky and created a massive crater**. It rests at the crater's center, radiating strange power that:
- Transforms terrain into desert badlands
- Spawns unique monsters (entity-corrupted creatures)
- Powers forbidden magic and technology
- Attracts ambitious people seeking power/wealth

**Critical Principle**: The crater is **NOT a final dungeon**—it's a **living region** with its own economy, politics, and factions. Players can visit, trade, settle, or liberate crater populations.

---

## The Four Greed Factions

| Faction | Goal | Methods | Player Role | Entry Path |
|---------|------|---------|-------------|-----------|
| **Merchant Princes** | Profit from entity | Commerce, slavery, exploitation | Trader, mercenary, enforcer | Economic motivation |
| **The Corrupted** | Commune with entity | Rituals, sacrifice, self-transformation | Cultist, researcher, prophet | Forbidden knowledge |
| **The Conquerors** | Weaponize entity | War prep, fortification, recruitment | General, soldier, spy | Military advancement |
| **The Rebels** | Seal/destroy entity | Sabotage, liberation, intelligence | Freedom fighter, saboteur, liberator | Moral motivation |

**Key Dynamic**: These factions are in constant conflict. Players can work for any faction, switch allegiances, play factions against each other, or rise to leadership.

---

## Entry Scenarios by Player Type

### **Hero Entering the Crater**
- **Why?** Seek entity weakness, gather forbidden knowledge, prepare for confrontation
- **How?** Negotiate safe passage with rebels OR fight through faction territory
- **Rewards**: Entity knowledge, rare weapons, sealing components, titles
- **Exit**: Return to allied kingdoms to prepare defenses
- **Impact**: If heroes succeed → other kingdoms prepare for entity threat

### **Villain Entering the Crater**
- **Why?** Join faction, gain forbidden power, rise to leadership
- **How?** Faction recruitment OR prove loyalty through dark deeds
- **Rewards**: Faction rank, forbidden magic, territory control, allies
- **Exit**: STAY in crater or use power to dominate other kingdoms
- **Impact**: If villains succeed → entity empowered, other kingdoms threatened

### **Pragmatist Entering the Crater**
- **Why?** Acquire exotic goods, arbitrage prices, gather intelligence
- **How?** Trade agreements, maintain neutral broker status
- **Rewards**: Exotic materials, black market access, multiple faction connections
- **Exit**: Continue operating between crater and kingdoms
- **Impact**: Markets distorted, factions destabilized by outside wealth

### **Rebel (from within) Working in Crater**
- **Why?** Free enslaved workers, sabotage exploitation, gather sealing components
- **How?** Underground networks, disguise, stealth, insider positions
- **Rewards**: Liberated workers, faction intelligence, moral victories
- **Exit**: Establish liberated territories or continue sabotage
- **Impact**: Crater resistance grows, faction control weakens

---

## Crater Geography & Procedural Generation

### **Physical Layout**
- **Central Abyss**: Where entity rests (highest danger, lowest accessibility)
- **Crater Floor**: Desert-like biome, spawning points for monsters
- **Crater Walls**: Jagged terrain, dangerous climbing, multiple elevations
- **Crater Rim**: Settlement zones (Port of Plenty hub, faction bases)
- **Surrounding Wastelands**: Corrupted wilderness with unique resources

### **Procedural Generation Details**
- Crater fills its own region (50-200 tiles from center, procedurally varied)
- Converted to desert + corruption + entity-touched flora/fauna
- Monster difficulty scales with proximity to abyss
- Corruption increases visually closer to center
- Unique resource nodes (only in crater) spawn per faction territory
- Faction settlements auto-placed via procedural algorithm

### **Unique Crater Features**
- **Crystalline Formations**: Entity corruption markers (visual landmarks)
- **Corrupted Water**: Glowing, poisonous, dangerous to drink
- **Carnivorous Plants**: Entity-touched flora (dangerous but harvestable)
- **Bioluminescent Trees**: Light sources in darker crater areas
- **Creature Nests**: Spawning points for entity-corrupted monsters

---

## Crater Corruption Mechanic (Optional)

Long exposure to entity power causes **optional corruption**:
- **Grants**: Forbidden abilities (stronger attacks, dark magic, special spells)
- **Changes**: Appearance (skin discoloration, glowing eyes, dark aura)
- **Consequences**: Allied kingdoms distrust/exile corrupted characters
- **Reversal**: Can be cured at Holy Light sanctuaries (but at great cost)

**Design Purpose**: Creates dramatic risk/reward choices—power now vs. acceptance later.

---

## Bidirectional Travel: The Key Mechanic

### **The Two-Way Path Problem (Solved)**

**Question**: How can the crater be both an antagonist region AND a playable destination?

**Answer**: It's not—it's **multiple antagonists** (factions) competing for control, with players choosing which to support (or all of them).

### **Different Exit Paths**

Players don't just leave the crater one way:

- **Hero Exit**: Return to Freedom kingdom with entity intelligence, prepare defenses
- **Villain Exit**: Return to other kingdoms as Greed's agent, sabotage from within
- **Pragmatist Exit**: Return with exotic goods, bribe/trade with any faction
- **Rebel Exit**: Lead freed workers to safety, establish liberated territories
- **Faction Exit**: Stay in crater, rise through faction ranks, never leave

**This means**: Crater doesn't have a "main story door"—players carve their own paths through **politics, combat, negotiation, and betrayal**.

---

## NPC Placement Strategy

### **Port of Plenty (Merchant Hub)**
- Corrupt merchants (buying/selling black market goods)
- Faction recruiters (for each of 4 factions)
- Information brokers (selling entity knowledge)
- Slave traders (offering illegal labor)
- Smugglers (trading contraband with other kingdoms)

### **Secondary Settlements (Faction Bases)**
- Faction leaders (quest givers for faction advancement)
- Faction quartermaster (faction-exclusive recipes/items)
- Faction trainers (faction-specific combat/magic)
- Spies/double agents (recruiting heroes for covert ops)

### **Hidden Rebel Hideouts**
- Resistance leaders (liberation quests)
- Escaped slaves (personal stories, motivation)
- Scientists studying entity (knowledge quests)
- Underground railroads (passage mechanics)

---

## Questlines: Sample Designs

### **Merchant Princes Questline**
1. "Acquire forbidden goods from other kingdoms"
2. "Enforce labor contracts on escaped workers"
3. "Sabotage rival faction's supply lines"
4. "Establish new trade monopoly"
5. "Rise to Merchant Prince status"

### **Corrupted Questline**
1. "Gather components for entity communion ritual"
2. "Sacrifice items/creatures to entity"
3. "Self-transform via corruption (grants abilities)"
4. "Recruit cultists to the fold"
5. "Become entity's high priest"

### **Conquerors Questline**
1. "Fortify military positions"
2. "Recruit/train entity-touched soldiers"
3. "Raid neighboring kingdom for supplies"
4. "Lead military campaign"
5. "Rise to general rank (command faction armies)"

### **Rebels Questline**
1. "Sabotage extraction camp"
2. "Free enslaved workers"
3. "Establish underground railroad"
4. "Gather entity-destroying components"
5. "Lead liberation movement (become faction leader)"

---

## Integration with Phase B (Town Generator)

When the procedural world generates:

1. **Crater Detection**: Map generator identifies where crater spawns (procedural placement)
2. **Crater Biome Conversion**: Surrounding region converted to desert + corruption + unique flora
3. **Faction Settlement Placement**: Automatically places Port of Plenty and faction bases
4. **Monster Spawning**: Unique crater creature nests auto-generated
5. **Resource Nodes**: Corrupted materials spawn only within crater radius
6. **Visual Markers**: Crater walls visible from distance, entity glow at night

**Result**: Crater is a **naturally-occurring mega-dungeon** that players can stumble upon or seek out—not manually placed.

---

## Relationship to Allied Kingdoms

### **Kingdom of Freedom** (Temperate Region)
- Opposes Greed exploitation
- Harbors escaped crater workers
- Provides supplies to resistance fighters
- May hire adventurers to weaken Greed

### **Kingdom of Belief** (Scholarly Region)
- Studies entity scientifically
- Seeks knowledge of entity origins
- May develop entity-sealing weapons
- Debates moral implications of Greed

### **Kingdom of Honor** (Chivalric Region)
- Takes oath against Greed
- Champions liberation movements
- Refuses to trade with Greed merchants
- Leads holy crusades against entity

### **Kingdom of Pride** (Military Region)
- Fortifies borders against Greed expansion
- May hire mercenaries FROM Greed
- Debates whether to ally with Greed for power
- Most likely to have double-agents

---

## How This Design Enables Multiple Story Endings

The crater's fate is **not predetermined**:

| Outcome | Hero Path | Villain Path | Pragmatist Path | Rebel Path |
|---------|-----------|--------------|-----------------|-----------|
| **Crater Sealed** | Heroes successfully close entity using components | Doesn't happen (villains prevent it) | Could happen if pragmatists tire of trading | Rebels unite all peoples, seal entity together |
| **Crater Conquered** | Crater falls to Greed (heroes unprepared) | Villains/factions dominate, expand territory | Market collapses, pragmatists flee | Resistance crushed, fighters executed |
| **Status Quo** | Stalemate—entity contained but not sealed | Factions constantly battle for control | Eternal trading opportunity | Ongoing covert liberation efforts |
| **Revolution** | Kingdom alliance attacks Greed | Faction coup (rebels within overturn Greed) | New power structure emerges | Liberated territories grow into nations |

**Key Point**: Unlike a traditional final dungeon, the crater's end-state is determined by **collective player actions and choices**—not a scripted sequence.

---

## Design Principle Summary

The Kingdom of Greed crater region solves the "two-way path" problem by:

1. **Making it a place** (physical crater with anchor point)
2. **Making it political** (4 factions competing, not just one evil entity)
3. **Making it optional** (visit anytime, exit anytime via different routes)
4. **Making it consequential** (player choices affect other kingdoms' outcomes)
5. **Making it emergent** (no rails, just competing agendas and player agency)

This transforms Greed from a "final boss to defeat" into a **dynamic, player-shaped region** where the story unfolds based on choices, not predetermined narrative.
