# PONDERA INTEGRATED DEVELOPMENT ROADMAP
**Updated**: December 11, 2025, 4:30 PM  
**Format**: Date-Time-Work (12-11-25 4:41PM SpellRefactor)  
**Strategy**: Integration-based clustering (shared systems work together)  
**Status**: Ready for execution starting 12-11-25 4:45PM

---

## EXECUTIVE SUMMARY

Rather than arbitrary phases, work items are now:
- **Timestamped**: `MM-DD-YY TIME Work Description`
- **Clustered by integration**: Systems that touch each other work together
- **Traceable**: Exact timestamp allows precise recall of what was done when
- **Executable**: Clear sequencing of dependent work

**Total estimated effort**: ~200-250 hours  
**Time to playable**: 4-6 weeks  
**Time to launch**: 3-4 months

---

## WORK CLUSTER 1: KNOWLEDGEBASE & WIKI SYSTEM
**Focus**: Build searchable recipe/tech tree/wiki interface  
**Integration**: Touches: TutorialSystem, KnowledgeBase, SandboxRecipeChain, UI systems  
**Duration**: 2-3 weeks

### 12-11-25 4:45PM - Tech Tree Visualization System
**Objective**: Render tech tree as interactive graph in-game
- Read current PTT.md (Pondera Tech Tree) and KnowledgeBase.dm
- Create `/datum/tech_tree_node` - visual node representation
- Create `/datum/tech_tree_renderer` - graph rendering engine
- Implement directional dependency visualization
- Test with recipe chain visualization
**Deliverable**: Player sees tech tree, can click nodes to learn prerequisites
**Dependencies**: None (foundation work)

### 12-11-25 5:30PM - Searchable Recipe Database Interface
**Objective**: Create in-game recipe browser with filters and search
- Create `/datum/recipe_browser` - search and filter engine
- Implement text search (recipe name, ingredient, output)
- Add category filters (cooking, crafting, smithing, etc.)
- Add rarity/difficulty filters
- Link to tech tree (show prerequisites)
- Show discovery status (discovered/not yet found)
**Deliverable**: Player opens interface, searches "bread", sees recipe + tech path
**Dependencies**: Tech Tree Visualization (12-11-25 4:45PM)

### 12-11-25 6:30PM - Wiki Knowledge Portal
**Objective**: Comprehensive in-game wiki with all game information
**Sections**:
- **Controls & Interface** - Keybindings, HUD elements, menu navigation
- **Survival Mechanics** - Hunger/thirst/temperature system
- **Crafting Guide** - Recipe categories, tool requirements, quality system
- **Sandbox Tips** - Getting started, building basics, farm setup
- **Economy Basics** - Currency, trading, pricing (story mode)
- **Territory System** - Deed claiming, zones, maintenance
- **Combat Tips** - Movement, attack patterns, abilities
- **Story Mode** - NPC locations, quest chains (static content)
**Deliverable**: Player presses F1, sees wiki with searchable topics
**Dependencies**: None (can work in parallel with recipes)

### 12-11-25 8:00PM - Damascus Steel Tutorial/Visualization
**Objective**: Add Damascus steel to wiki + tech tree + tutorial
- Create visual depiction of Damascus folding pattern
- Show pattern variants: Wild, Twist, Ladder, Raindrop, Herringbone, Pyramids, Mosaic, Feather
- Add tutorial steps for Damascus crafting
- Show in tech tree as final metallurgy tier
- Link activated carbon → Damascus folding → legendary weapons
**Deliverable**: Player learns Damascus process through wiki/tutorial, sees pattern variations
**Dependencies**: Searchable Recipe Database (12-11-25 5:30PM), Wiki Portal (12-11-25 6:30PM)

### 12-11-25 9:30PM - Static Trade Routes (Story Mode)
**Objective**: Map static trading hubs and caravan routes in story world
- Create `/datum/trade_route` - defines path and merchants
- Map key towns: Starting village → Harbor → Mountain pass → Forest camp
- Add merchant NPC pools per route (baker, blacksmith, alchemist, etc.)
- Add description text (why this route, who trades where)
- Add to wiki as Story Mode Economy section
**Deliverable**: Player can read about trade routes in wiki, see NPCs at hub towns
**Dependencies**: Wiki Portal (12-11-25 6:30PM)

---

## WORK CLUSTER 2: AUDIO & VISUAL INTEGRATION
**Focus**: Wire existing audio/equipment systems to actual gameplay  
**Integration**: Touches: Combat, Equipment, UI, NPC interactions  
**Duration**: 1-2 weeks

### 12-12-25 9:00AM - Audio Integration: Combat Sounds
**Objective**: Play sounds when combat actions happen
**Actions to wire**:
- Hit (melee/ranged) → hit_light/medium/heavy
- Critical hit → critical_hit
- Dodge success → dodge
- Block success → block
- Death → death
- Levelup → levelup
- Recipe discover → recipe_discover
**Process**:
- Find all combat action locations (UnifiedAttackSystem.dm, CombatSystem.dm, etc.)
- Add `audio_manager.PlaySound("combat", sound_key)` calls
- Test each sound in-game
**Deliverable**: Combat is audibly satisfying, sounds play on every action
**Dependencies**: None (AudioIntegrationSystem.dm already complete)

### 12-12-25 11:00AM - Audio Integration: UI & Feedback
**Objective**: Play sounds for menu interaction and status changes
**Actions to wire**:
- Click (menus, buttons) → click
- Inventory open/close → inventory_open
- Item pickup → item_pickup
- Item drop → item_drop
- Quest complete → quest_complete
**Process**:
- Find UI interaction points (inventory click, item handling, quest completion)
- Add `audio_manager.PlaySound("ui", sound_key)` calls
- Test menu navigation sounds
**Deliverable**: Menu interaction feels responsive with audio feedback
**Dependencies**: Audio Integration: Combat (12-12-25 9:00AM)

### 12-12-25 1:00PM - Equipment Overlay Integration
**Objective**: Wire equipment overlays to Equip()/Unequip() verbs
**Process**:
- Open tools.dm, find Equip() and Unequip() verbs
- Add `apply_equipment_overlay(item)` call after equipment equipped
- Add `remove_equipment_overlay(item)` call after equipment unequipped
- Add `refresh_equipment_overlays()` call when direction changes
- Test: Equip longsword, see overlay appear with correct direction
**Deliverable**: Player equips weapon, sees visual on character, changes direction → overlay updates
**Dependencies**: None (system already built, just needs wiring)

### 12-12-25 2:30PM - Audio Integration: Ambient & Environmental
**Objective**: Play environmental sounds based on location/weather
**Locations to add**:
- Fire/forge areas → fire_crackle, anvil_ambient (looping)
- Water areas → water_flow (looping)
- Forest areas → forest_birds (looping)
- Windy areas → wind (looping based on weather)
**Process**:
- Create location-based sound emission system
- Link weather system to environmental sounds
- Test on each terrain type
**Deliverable**: World feels alive with ambient sounds
**Dependencies**: Audio Integration: Combat (12-12-25 9:00AM)

---

## WORK CLUSTER 3: NPC SYSTEM UNIFICATION
**Focus**: Coordinate all NPC subsystems into single coherent system  
**Integration**: Touches: NPC AI, dialogue, trading, recipe teaching, supply chains  
**Duration**: 2-3 weeks (CRITICAL BLOCKER FOR LATER PHASES)

### 12-12-25 4:00PM - NPC Dispatcher Architecture
**Objective**: Create single coordinator for all NPC behavior
**Components**:
- `/datum/npc_dispatcher` - Main coordinator
- `/datum/npc_behavior_queue` - Queued actions per NPC
- `/datum/npc_state_manager` - Current NPC state tracking
- Unified goal system (trade, cook, guard, teach, etc.)
**Process**:
- Read existing: NPCRoutineSystem, NPCMerchantSystem, NPCRecipeHandlers
- Design unified interface for all NPC actions
- Create priority system (hunger > teaching > idle)
**Deliverable**: Single system coordinates all NPC activity
**Dependencies**: None (foundation)

### 12-12-25 6:00PM - Unified NPC Dialogue System
**Objective**: Single dialogue handling with choice branching and memory
**Features**:
- Choice selection system (player picks from list)
- Branching dialogue trees (NPC responses vary by state)
- Memory system (NPC remembers player interactions)
- State persistence (dialogue affects NPC behavior)
**Process**:
- Read current dialogue scattered across NPCRecipeHandlers, npcs.dm
- Create `/datum/dialogue_branch` - single dialogue unit
- Create `/datum/npc_memory` - what NPC remembers about player
- Test: Trade with baker, return later, baker remembers you
**Deliverable**: NPCs remember players, dialogue branches based on history
**Dependencies**: NPC Dispatcher (12-12-25 4:00PM)

### 12-12-25 8:00PM - NPC-to-NPC Trading System
**Objective**: Enable NPCs to trade with each other (supply chains)
**Scenario**: Baker buys flour from Farmer, sells bread to Player
**Process**:
- Create `/datum/npc_trade_offer` - what NPC wants to buy/sell
- Create `/datum/npc_supply_chain` - tracks goods flow
- Link to inventory system (NPCs have supplies)
- Create background processor that facilitates trades
- Test: Farmer harvests wheat → Baker buys flour → Player buys bread
**Deliverable**: Economy has NPC activity independent of player
**Dependencies**: Unified Dialogue (12-12-25 6:00PM), NPC Dispatcher (12-12-25 4:00PM)

### 12-13-25 10:00AM - NPC Recipe Teaching Integration
**Objective**: Connect NPC teaching to recipe discovery + memory
**Process**:
- Link recipe teaching to unified dialogue system
- NPC offers recipe teaching → Player accepts → Recipe unlocked
- Track taught recipes in NPC memory (can't teach same recipe twice)
- Show in knowledgebase which NPCs teach which recipes
- Test: Talk to blacksmith, learn steel sword recipe
**Deliverable**: NPCs teach recipes within dialogue/memory system
**Dependencies**: Unified Dialogue (12-12-25 6:00PM), Knowledgebase (Cluster 1)

---

## WORK CLUSTER 4: TERRITORY-ECONOMY LINKAGE
**Focus**: Make deed territories affect market prices and availability  
**Integration**: Touches: Market pricing, NPC supply, territory control  
**Duration**: 2 weeks

### 12-13-25 12:00PM - Territory Resource Availability
**Objective**: Territory control affects what resources are available
**Logic**:
- Territory with forests → wood availability higher, price lower
- Territory with wheat farms → flour availability higher, price lower
- Territory under siege → resources scarce, prices spike
- Territory without deed → neutral prices, low availability
**Process**:
- Create `/datum/territory_resources` - tracks resources per territory
- Link to MarketPricingSystem (already exists)
- Modify NPC supply chains to check territory resources
- Test: Control wheat territory → bread price drops
**Deliverable**: Economy responds to territorial control
**Dependencies**: NPC-to-NPC Trading (12-12-25 8:00PM)

### 12-13-25 2:00PM - Dynamic Price Elasticity
**Objective**: Fine-tune market pricing based on territory scarcity
**Process**:
- Adjust elasticity curves in DynamicMarketPricingSystem
- Test price swings (should feel responsive but not chaotic)
- Add UI showing "High demand!" / "Abundant supply!" alerts
**Deliverable**: Market prices feel realistic and responsive
**Dependencies**: Territory Resource Availability (12-13-25 12:00PM)

### 12-13-25 4:00PM - Trade Route Integration
**Objective**: Static trade routes affect market access in story mode
**Process**:
- Link static trade routes to NPC availability
- Merchant caravans travel routes, bring goods
- Blocked routes (weather/siege) reduce available items
- Add to story mode economy simulation
**Deliverable**: Story mode trade routes create dynamic marketplace
**Dependencies**: Static Trade Routes (12-11-25 9:30PM), NPC Supply (12-12-25 8:00PM)

---

## WORK CLUSTER 5: WEATHER-COMBAT INTEGRATION
**Focus**: Make weather affect combat mechanics  
**Integration**: Touches: Combat system, visibility, accuracy  
**Duration**: 1.5 weeks

### 12-13-25 6:00PM - Weather Visibility Modifier
**Objective**: Rain/fog reduce visibility, affecting accuracy
**Mechanics**:
- Rain → -20% ranged accuracy, -10% melee accuracy
- Fog → -30% ranged accuracy, no visibility beyond 10 tiles
- Clear → +10% morale bonus
- Snow → -10% movement speed, +10% cold resistance need
**Process**:
- Create `/datum/weather_combat_modifier` - visibility/accuracy effects
- Link to combat damage calculation
- Test: Rain fight vs sunny fight should play different
**Deliverable**: Combat plays different in different weather
**Dependencies**: None (systems already exist separately)

### 12-14-25 10:00AM - Projectile Weather Deflection
**Objective**: Wind affects projectile trajectories
**Mechanics**:
- Strong wind (15+ mph) → projectiles deflected 15-30 degrees
- Light wind → slight deflection
- Still air → no deflection
**Process**:
- Modify RangedCombatSystem to check wind speed
- Calculate trajectory adjustment
- Test: Fire arrow with tailwind vs headwind
**Deliverable**: Archery feels more realistic with wind effects
**Dependencies**: Weather Visibility (12-13-25 6:00PM)

### 12-14-25 12:00PM - Temperature Combat Effects
**Objective**: Extreme temperature affects stamina drain in combat
**Mechanics**:
- Extreme cold (below freezing) → +50% stamina drain, -20% damage
- Extreme heat (over 100°F) → +40% stamina drain, slow movement
- Comfortable temp → normal mechanics
**Process**:
- Link temperature system to stamina calculations
- Test: Combat in winter vs summer feels different
**Deliverable**: Temperature is actually relevant to survival
**Dependencies**: Weather Visibility (12-13-25 6:00PM)

---

## WORK CLUSTER 6: SEASON-FARMING DEEPENING
**Focus**: Make seasons truly affect farming viability  
**Integration**: Touches: Farming, soil, plant growth, NPC demand  
**Duration**: 2 weeks

### 12-14-25 2:00PM - Seasonal Crop Availability
**Objective**: Different crops only grow in specific seasons
**Crops**:
- Spring: Peas, lettuce, spinach, wheat
- Summer: Corn, tomatoes, berries, melons
- Autumn: Squash, pumpkin, cabbage, carrots
- Winter: Root vegetables (stored), special herbs
**Process**:
- Create `/datum/seasonal_crops` - map crops to seasons
- Modify PlantSeasonalIntegration to block out-of-season planting
- Add failure feedback (can't plant corn in winter)
- Show in wiki which crops per season
**Deliverable**: Farming has seasonal strategy, not year-round monotony
**Dependencies**: None (foundation work)

### 12-14-25 4:00PM - Seasonal Soil Effects
**Objective**: Soil quality changes with weather and season
**Mechanics**:
- Winter freeze → soil quality -20%, but deep frost kills pests
- Spring thaw → soil recovery begins
- Summer drought → soil quality -30% unless irrigated
- Autumn rain → soil quality +20%
**Process**:
- Modify SoilDegradationSystem to track seasonal factors
- Add irrigation mechanic (water requirement)
- Test: Farm in winter is harder than spring
**Deliverable**: Seasonal farming requires seasonal strategy
**Dependencies**: Seasonal Crop Availability (12-14-25 2:00PM)

### 12-14-25 6:00PM - NPC Seasonal Demand
**Objective**: NPC food needs change by season
**Logic**:
- Winter: High demand for stored crops, meat preservation
- Spring: Seed demand from farmers
- Summer: Fresh produce demand (salads, preserves)
- Autumn: Grain & harvest tool demand
**Process**:
- Modify NPC supply chains to track seasonal demand
- Prices spike for in-demand items per season
- Festival events trigger per-season
**Deliverable**: Economy shifts seasonally, creates trading opportunities
**Dependencies**: Territory-Economy (Cluster 4), NPC Supply (12-12-25 8:00PM)

---

## WORK CLUSTER 7: FACTION TERRITORY WARS
**Focus**: Make factions actually fight over territories  
**Integration**: Touches: Factions, territories, combat, economy  
**Duration**: 2.5 weeks

### 12-15-25 9:00AM - Territory Ownership & Faction Control
**Objective**: Territories locked to owning faction
**Mechanics**:
- Territory owner: Sets prices, spawns faction NPCs
- Non-owner: Can't build, pay higher NPC prices
- Contested: Territory ownership disputed
- Siege state: Territory under active attack
**Process**:
- Modify TerritoryClaimSystem to track faction ownership
- Modify deed system to tie to faction
- Create faction respawn points in owned territories
**Deliverable**: Territories matter politically, affect access
**Dependencies**: Territory-Economy (Cluster 4)

### 12-15-25 1:00PM - Automatic War Declaration
**Objective**: Factions automatically declare war over adjacent territories
**Mechanics**:
- If hostile factions control adjacent territories → War state
- War state → Increased NPC patrols, reduced trade
- Cessation conditions: Territory concession or treaty
**Process**:
- Create `/datum/faction_war_manager` - automatic declaration
- Create `/datum/treaty_system` - peace negotiations
- Test: Two factions fight over valley
**Deliverable**: Faction conflict feels organic and automatic
**Dependencies**: Territory Ownership (12-15-25 9:00AM)

### 12-15-25 3:00PM - Siege Mechanics Integration
**Objective**: Wire SiegeEquipmentSystem to actual war mechanics
**Equipment to use**:
- Ballista → Ranged siege damage
- Catapult → Area damage (collateral on terrain)
- Trebuchet → Long-range devastation
- Siege towers → Assault structures for entry
**Process**:
- Test siege equipment in combat (already defined)
- Create siege damage calculations
- Test: Siege equipment actually damages territory structures
**Deliverable**: Siege equipment is viable and devastating
**Dependencies**: Faction Territory Wars (12-15-25 9:00AM)

### 12-15-25 5:00PM - War Costs & Treasury Impact
**Objective**: Waging war costs materials from kingdom treasury
**Mechanics**:
- Raise armies → Cost: wood + metal per unit
- March armies → Cost: supplies per day
- Siege setup → Cost: siege equipment materials
- Victory/defeat → Treasury gains/loses materials
**Process**:
- Link KingdomMaterialExchange to war costs
- Create army maintenance system
- Track costs per action
**Deliverable**: War has real resource costs, strategic depth
**Dependencies**: Territory-Economy (Cluster 4), Siege (12-15-25 3:00PM)

---

## WORK CLUSTER 8: OFFICER SYSTEM COMPLETION
**Focus**: Elite officer recruitment, loyalty, and progression  
**Integration**: Touches: NPCs, combat, faction, tournaments  
**Duration**: 1.5 weeks

### 12-16-25 10:00AM - Officer Recruitment from NPC Pool
**Objective**: Recruit elite officers from NPC population
**Mechanics**:
- Certain NPCs have "officer potential" stat
- Recruit by: Paying gold + spending time training
- Officers start at level 1, can be promoted to level 5
- Special abilities unlock per level
**Process**:
- Modify NPC system to flag officer candidates
- Create recruitment UI
- Create training system (time → level)
**Deliverable**: Player can recruit officers from town population
**Dependencies**: NPC Unification (Cluster 3)

### 12-16-25 12:00PM - Officer Loyalty & Morale
**Objective**: Officers have loyalty that affects performance
**Mechanics**:
- Good decisions → +loyalty, better performance
- Poor decisions → -loyalty, may desert
- High morale → Combat bonuses
- Low morale → Higher casualty rates
**Process**:
- Create `/datum/officer_loyalty` tracker
- Link decisions to morale changes
- Add morale effects to combat calculations
**Deliverable**: Officers feel like real characters, not just stats
**Dependencies**: Officer Recruitment (12-16-25 10:00AM)

### 12-16-25 2:00PM - Officer Tournament Ranking
**Objective**: Officers can compete for rank via tournaments
**Mechanics**:
- 1v1 combat tournament bracket
- Winner gets promoted, loot, prestige
- Loser loses morale but can try again later
- Tournament held per-season in major city
**Process**:
- Create `/datum/tournament_bracket` system
- Create match orchestration (NPC fights are simulated)
- Test: Officer wins tournament → promoted
**Deliverable**: Officers have clear progression path via competition
**Dependencies**: Officer Loyalty (12-16-25 12:00PM)

---

## WORK CLUSTER 9: MISSING FEATURES RECOVERY
**Focus**: Recover systems from plannedfeatures.txt not yet started  
**Integration**: Touches: Various (character creation, gameplay mechanics)  
**Duration**: 1.5-2 weeks

### 12-16-25 4:00PM - Game Mode Selection UI
**Objective**: Refactor character creation with game mode picker
**Modes**:
- Story (medieval quest progression, narrative focus)
- Sandbox (creative building, no pressure, all recipes unlocked)
- PvP (competition, raiding, risk/reward)
**Process**:
- Modify CharacterCreationUI to add mode selector
- Show description and rulesets for each mode
- Link to MultiWorldConfig (systems already exist)
**Deliverable**: New players clearly choose game mode
**Dependencies**: None (UI work)

### 12-16-25 6:00PM - Difficulty Toggle System
**Objective**: Add difficulty selection affecting resource scarcity
**Difficulties**:
- Easy: 2x resources, 0.5x hunger drain, NPC prices lower
- Normal: 1x base values (current)
- Hard: 0.5x resources, 2x hunger drain, hostile NPCs
**Process**:
- Create `/datum/difficulty_manager` - tracks difficulty
- Modify resource spawning with difficulty multiplier
- Modify hunger/consumption with difficulty multiplier
- Test each difficulty mode
**Deliverable**: Game difficulty affects all mechanics consistently
**Dependencies**: None (foundation)

### 12-16-25 8:00PM - Sandbox Home Point Setter (Compass)
**Objective**: Sandbox mode compass item for setting home respawn
**Mechanics**:
- Find/craft compass item
- Right-click → Mark current location as home
- Death in sandbox → Respawn at home point
- Can reset home point anytime
**Process**:
- Create `/obj/items/compass` object
- Link to respawn system
- Test: Set home, die, respawn at home
**Deliverable**: Sandbox players have convenient respawn mechanic
**Dependencies**: Game Mode Selection (12-16-25 4:00PM)

### 12-17-25 10:00AM - War Tent & Rally Point System
**Objective**: Faction rally points for army staging
**Mechanics**:
- Build war tent in friendly territory
- Tent becomes army rally point
- Armies spawn at closest friendly tent
- Tents can be destroyed by enemy siege
**Process**:
- Create `/obj/buildable/war_tent` structure
- Link to army spawn system
- Create destruction mechanics (durability, siege damage)
**Deliverable**: Strategic faction infrastructure for warfare
**Dependencies**: Faction Territory Wars (12-15-25 9:00AM)

### 12-17-25 12:00PM - Spell System Redesign (Damage Spells)
**Objective**: Redesign spell system with proper damage mechanics
**Current issue**: Existing Spells.dm lacks realistic damage/cooldown balance
**Redesign**:
- Spell cost system (mana/stamina/reagents)
- Cooldown progression (early spells quick, powerful spells long)
- Damage scaling (intellect stat affects spell power)
- Area effects (some spells hit multiple targets)
**Process**:
- Refactor Spells.dm spell definitions
- Create `/datum/spell_damage` calculator
- Balance via playtesting (target: spells viable in combat)
- Add to combat UI (show spell cooldowns)
**Deliverable**: Spells are viable, balanced combat option
**Dependencies**: Combat integration (Cluster 2, 5)

---

## WORK CLUSTER 10: LOGISTICS & TRADE ROUTES ADVANCED
**Focus**: Complete logistics system with dynamic wagon transport  
**Integration**: Touches: Economy, NPCs, trade routes, UI  
**Duration**: 2-3 weeks

### 12-17-25 2:00PM - Wagon System Foundation
**Objective**: Create mobile cargo transport for trade routes
**Mechanics**:
- Wagons spawn at trade route nodes
- Travel fixed routes carrying goods
- Can be attacked/raided (risk mechanic)
- Arrive at destination with goods
**Process**:
- Create `/obj/wagons/trade_wagon` object
- Create `/datum/wagon_route` system (ties to trade routes)
- Create wagon AI (pathfinding on routes)
- Create cargo system (inventory per wagon)
**Deliverable**: See wagons traveling between towns
**Dependencies**: Static Trade Routes (12-11-25 9:30PM), NPC Supply (12-12-25 8:00PM)

### 12-17-25 4:00PM - Supply Chain Logistics
**Objective**: Track goods flow: Production → Transport → Consumption
**Mechanics**:
- Factory produces goods (rate based on input)
- Wagons transport to merchant
- Merchant sells to player/NPCs
- Demand drives production
**Process**:
- Modify NPC supply chains to use wagons
- Create logistics tracking UI (optional: detailed logs)
- Test: Wheat → Flour -> Baker → Bread → Player
**Deliverable**: See full supply chain operate
**Dependencies**: Wagon System (12-17-25 2:00PM), NPC Supply (12-12-25 8:00PM)

### 12-17-25 6:00PM - Raid/Intercept Mechanics
**Objective**: Wagons can be raided, disrupting supply
**Mechanics**:
- Wagons have defense (NPC guards, health)
- Raiders attack wagon → Combat
- Win: Steal goods
- Lose: Wagon destroyed, goods lost
- NPC factions use this in war
**Process**:
- Create wagon combat system (treated as enemy group)
- Create loot drops (wagon cargo)
- Test: Raid wagon, steal goods
**Deliverable**: Economic warfare via supply disruption
**Dependencies**: Wagon System (12-17-25 2:00PM)

### 12-18-25 10:00AM - Logistics UI & Tracking
**Objective**: Player can view supply chain logistics
**Display**:
- Wagon routes with current locations
- Goods in transit
- Production facilities and output rates
- Consumption hubs
**Process**:
- Create logistics viewer interface
- Show real-time wagon positions
- Estimated delivery times
**Deliverable**: Player understands economy flow
**Dependencies**: Supply Chain Logistics (12-17-25 4:00PM)

---

## EXECUTION TIMELINE

### WEEK 1: 12-11-25 to 12-18-25
**Focus**: Knowledgebase, Audio, NPC Unification

| Time | Work Item | Status |
|------|-----------|--------|
| 12-11-25 4:45PM | Tech Tree Visualization | ▶️ Start |
| 12-11-25 5:30PM | Searchable Recipe DB | ▶️ Follow |
| 12-11-25 6:30PM | Wiki Portal | ▶️ Parallel |
| 12-11-25 8:00PM | Damascus Steel Tutorial | ▶️ Follow |
| 12-11-25 9:30PM | Static Trade Routes | ▶️ Follow |
| 12-12-25 9:00AM | Audio: Combat | ▶️ Start |
| 12-12-25 11:00AM | Audio: UI | ▶️ Follow |
| 12-12-25 1:00PM | Equipment Overlays | ▶️ Parallel |
| 12-12-25 2:30PM | Audio: Ambient | ▶️ Follow |
| 12-12-25 4:00PM | NPC Dispatcher | ▶️ Start |
| 12-12-25 6:00PM | NPC Dialogue | ▶️ Follow |
| 12-12-25 8:00PM | NPC-to-NPC Trading | ▶️ Follow |
| 12-13-25 10:00AM | NPC Recipe Teaching | ▶️ Follow |

### WEEK 2: 12-15-25 to 12-21-25
**Focus**: Economy Integration, Weather, Seasons, Factions

| Time | Work Item | Status |
|------|-----------|--------|
| 12-13-25 12:00PM | Territory Resources | ▶️ Start |
| 12-13-25 2:00PM | Dynamic Pricing | ▶️ Follow |
| 12-13-25 4:00PM | Trade Route Integration | ▶️ Follow |
| 12-13-25 6:00PM | Weather Visibility | ▶️ Start |
| 12-14-25 10:00AM | Projectile Weather | ▶️ Follow |
| 12-14-25 12:00PM | Temperature Combat | ▶️ Follow |
| 12-14-25 2:00PM | Seasonal Crops | ▶️ Start |
| 12-14-25 4:00PM | Seasonal Soil Effects | ▶️ Follow |
| 12-14-25 6:00PM | NPC Seasonal Demand | ▶️ Follow |
| 12-15-25 9:00AM | Territory Ownership | ▶️ Start |
| 12-15-25 1:00PM | War Declaration | ▶️ Follow |
| 12-15-25 3:00PM | Siege Mechanics | ▶️ Follow |
| 12-15-25 5:00PM | War Costs | ▶️ Follow |

### WEEK 3: 12-16-25 to 12-22-25
**Focus**: Officer System, Feature Recovery, Logistics

| Time | Work Item | Status |
|------|-----------|--------|
| 12-16-25 10:00AM | Officer Recruitment | ▶️ Start |
| 12-16-25 12:00PM | Officer Loyalty | ▶️ Follow |
| 12-16-25 2:00PM | Officer Tournament | ▶️ Follow |
| 12-16-25 4:00PM | Game Mode Selection | ▶️ Start |
| 12-16-25 6:00PM | Difficulty Toggle | ▶️ Follow |
| 12-16-25 8:00PM | Sandbox Home Point | ▶️ Follow |
| 12-17-25 10:00AM | War Tent System | ▶️ Follow |
| 12-17-25 12:00PM | Spell Redesign | ▶️ Follow |
| 12-17-25 2:00PM | Wagon System | ▶️ Start |
| 12-17-25 4:00PM | Supply Chain | ▶️ Follow |
| 12-17-25 6:00PM | Raid Mechanics | ▶️ Follow |
| 12-18-25 10:00AM | Logistics UI | ▶️ Follow |

---

## SUCCESS METRICS

### After Week 1 (12-18-25):
- ✅ Tech tree searchable and visible in-game
- ✅ Wiki accessible with all info
- ✅ All combat actions have sound
- ✅ Equipment visually appears on character
- ✅ NPCs coordinate with single system
- ✅ NPCs remember player interactions

### After Week 2 (12-21-25):
- ✅ Market prices respond to territory control
- ✅ Weather affects combat
- ✅ Seasonal crops affect farming
- ✅ Factions fight over territories
- ✅ Siege equipment is integrated

### After Week 3+ (12-22-25+):
- ✅ Officers can be recruited and leveled
- ✅ Game modes are selectable
- ✅ Wagons transport goods
- ✅ Supply chains are visible/trackable
- ✅ Everything integrated and playable

---

## BUILD CONTINUITY

**After each work item**:
- [ ] Build verification (0 errors, 0 warnings)
- [ ] Git commit with timestamp-based message
- [ ] Quick playtest of new feature
- [ ] Note any blockers or dependencies

---

## BLOCKERS & DEPENDENCIES

**Hard Blockers** (must complete before dependent work):
- NPC Dispatcher (blocks all NPC-dependent work)
- Tech Tree Visualization (blocks wiki, damascus, tutorial)
- Audio Combat (blocks other audio)

**Soft Dependencies** (nice-to-have for testing, but can work in parallel):
- Equipment Overlays can start during audio work
- Territory economy can start before siege systems
- Spell redesign independent of faction wars

---

**Ready to execute**: 12-11-25 4:45PM  
**Format**: Timestamp-based, traceable, organized by integration  
**First item**: Tech Tree Visualization  

Shall we begin? 🚀

