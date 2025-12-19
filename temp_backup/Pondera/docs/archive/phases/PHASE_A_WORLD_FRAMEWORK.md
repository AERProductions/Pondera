# Phase A: World/Continent Framework Implementation

**Estimated Duration**: 6-8 hours  
**Objective**: Establish foundational world system that enables continent separation, travel mechanics, and per-continent rule enforcement  
**Status**: READY FOR IMPLEMENTATION  
**Estimated Completion**: Next 1-2 days

---

## Overview

Phase A creates the **infrastructure foundation** for three-world architecture. This phase doesn't implement story content, towns, or PvP mechanics—it creates the *framework* that all subsequent phases depend on.

### What This Phase Delivers
- ✅ World/continent identification system
- ✅ Per-continent rule sets (peaceful, creative, combat)
- ✅ Port/travel system (world-to-world navigation)
- ✅ Player position/respawn management
- ✅ Continent-specific inventory isolation
- ✅ Recipe state cross-world sharing
- ✅ Foundation for NPC/structure persistence per continent

### What This Phase Does NOT Include
- ❌ Story world content (deferred to Phase C)
- ❌ Town generation (deferred to Phase B)
- ❌ PvP mechanics (deferred to Phase E)
- ❌ Sandbox terrain generation (deferred to Phase D)
- ❌ NPC dialogue system (deferred to Phase F)

---

## Phase A Task Breakdown

### Task 1: Create Continent Framework (1.5-2 hours)

#### 1.1: Define Continent Datums

**File**: `dm/WorldSystem.dm` (NEW - 150 lines)

Create continent definition system:

```dm
/datum/continent
	var
		name = ""               // "Kingdom of Freedom", "Creative Sandbox", "Battlelands"
		id = ""                 // "story", "sandbox", "pvp"
		desc = ""               // Description for UI/logs
		type_flags = 0          // CONTINENT_PEACEFUL, CONTINENT_CREATIVE, CONTINENT_COMBAT
		
		// Map generation parameters
		generator_type = ""     // "story_procedural", "sandbox_bare", "pvp_survival"
		seed = 0                // Unique per continent
		
		// Rules
		allow_pvp = 0           // Can players attack each other?
		allow_stealing = 0      // Can NPCs/players steal items?
		allow_building = 1      // Can players place structures?
		monster_spawn = 0       // Do monsters spawn?
		npc_spawn = 0           // Do NPCs spawn?
		weather = 0             // Does weather occur?
		
		// Portal locations
		port_x = 0
		port_y = 0
		port_z = 0              // Will be base elevel

**Continent Type Constants** (in `!defines.dm`):
```dm
// Continent flags
#define CONTINENT_PEACEFUL  (1<<0)  // No combat, safe sandbox
#define CONTINENT_CREATIVE  (1<<1)  // Building-focused, no pressure
#define CONTINENT_COMBAT    (1<<2)  // PvP, survival, competition

// Continent IDs
#define CONT_STORY    "story"
#define CONT_SANDBOX  "sandbox"
#define CONT_PVP      "pvp"
```

#### 1.2: Create Continent Registry

**File**: `dm/WorldSystem.dm` (continued)

```dm
// Global continent list
var/list/continents = list()

// Create continents on startup
/proc/InitializeContinents()
	var/datum/continent/story = new()
	story.name = "Kingdom of Freedom"
	story.id = CONT_STORY
	story.desc = "A procedurally-generated story world with NPCs and guided progression"
	story.type_flags = 0  // No special flags
	story.generator_type = "story_procedural"
	story.seed = 42       // Fixed seed for story world
	story.allow_pvp = 0
	story.allow_stealing = 0
	story.allow_building = 1  // Can build housing
	story.monster_spawn = 1
	story.npc_spawn = 1
	story.weather = 1
	story.port_x = 64  // Center of starting area
	story.port_y = 64
	continents[story.id] = story
	
	var/datum/continent/sandbox = new()
	sandbox.name = "Creative Sandbox"
	sandbox.id = CONT_SANDBOX
	sandbox.desc = "Peaceful creative building world with all recipes available"
	sandbox.type_flags = CONTINENT_PEACEFUL | CONTINENT_CREATIVE
	sandbox.generator_type = "sandbox_bare"
	sandbox.seed = 9999
	sandbox.allow_pvp = 0
	sandbox.allow_stealing = 0
	sandbox.allow_building = 1
	sandbox.monster_spawn = 0
	sandbox.npc_spawn = 0
	sandbox.weather = 0
	sandbox.port_x = 128
	sandbox.port_y = 128
	continents[sandbox.id] = sandbox
	
	var/datum/continent/pvp = new()
	pvp.name = "Battlelands"
	pvp.id = CONT_PVP
	pvp.desc = "Competitive survival continent with PvP, raiding, and territory control"
	pvp.type_flags = CONTINENT_COMBAT
	pvp.generator_type = "pvp_survival"
	pvp.seed = 12345
	pvp.allow_pvp = 1
	pvp.allow_stealing = 1
	pvp.allow_building = 1
	pvp.monster_spawn = 1
	pvp.npc_spawn = 0
	pvp.weather = 1
	pvp.port_x = 200
	pvp.port_y = 200
	continents[pvp.id] = pvp
	
	return continents

/proc/GetContinent(continent_id)
	return continents[continent_id]
```

#### 1.3: Modify CharacterData to Track Continent

**File**: `dm/CharacterData.dm` (MODIFY)

Add to `/mob/players` var list:

```dm
// Multi-world system
current_continent = CONT_STORY       // Which continent player is on
continent_positions = list()         // Saved positions per continent: CONT_STORY = list(x, y, z, dir)
continent_inventory = list()         // Isolated inventory per continent (optional per-world isolation)

// Loaded recipe_state persists across continents automatically (no changes needed)
```

**Initialization**:
```dm
/mob/players/New()
	..()
	current_continent = CONT_STORY
	continent_positions[CONT_STORY] = list(x: 64, y: 64, z: 1)
	continent_positions[CONT_SANDBOX] = list(x: 128, y: 128, z: 1)
	continent_positions[CONT_PVP] = list(x: 200, y: 200, z: 1)
```

---

### Task 2: Implement Travel System (1.5-2 hours)

#### 2.1: Create Portal Objects

**File**: `dm/Portals.dm` (NEW - 200 lines)

```dm
// Portal base type
/obj/portal
	name = "Portal"
	desc = "A shimmering gateway to another realm"
	icon = 'dmi/portal.dmi'
	icon_state = "active"
	density = 0
	var
		destination_continent = CONT_STORY  // Where does this portal lead?
		is_active = 1

	New(x, y, z, destination)
		..()
		src.x = x
		src.y = y
		src.z = z
		destination_continent = destination
		name = "Portal to [continents[destination].name]"

	Entered(atom/movable/A)
		if(!istype(A, /mob/players)) return
		if(!is_active) return
		
		// Safety: verify destination continent exists
		var/datum/continent/cont = GetContinent(destination_continent)
		if(!cont)
			A << "ERROR: Destination continent not found!"
			return
		
		TravelToContinent(A, destination_continent)

// Specialized portals
/obj/portal/story_gate
	name = "Portal to Kingdom of Freedom"
	destination_continent = CONT_STORY

/obj/portal/sandbox_gate
	name = "Portal to Creative Sandbox"
	destination_continent = CONT_SANDBOX

/obj/portal/pvp_gate
	name = "Portal to Battlelands"
	destination_continent = CONT_PVP
```

#### 2.2: Implement Travel Proc

**File**: `dm/Portals.dm` (continued)

```dm
/proc/TravelToContinent(mob/players/player, destination_continent)
	// Validate
	if(!player) return 0
	if(!destination_continent in continents) return 0
	
	var/datum/continent/src_cont = GetContinent(player.current_continent)
	var/datum/continent/dest_cont = GetContinent(destination_continent)
	
	if(!dest_cont)
		player << "ERROR: Destination continent not accessible."
		return 0
	
	// Save current position
	if(player.current_continent)
		continent_positions[player.current_continent] = list(
			x: player.x,
			y: player.y,
			z: player.z,
			dir: player.dir
		)
	
	// Announce
	player << "You step through the portal..."
	
	// Change continent
	player.current_continent = destination_continent
	
	// Get destination position
	var/list/dest_pos = player.continent_positions[destination_continent]
	if(!dest_pos)
		// Default to continent port location
		dest_pos = list(x: dest_cont.port_x, y: dest_cont.port_y, z: 1)
	
	// Move player to destination continent
	player.x = dest_pos["x"]
	player.y = dest_pos["y"]
	player.z = dest_pos["z"]
	if(dest_pos["dir"]) player.dir = dest_pos["dir"]
	
	// Welcome message
	sleep(10)  // Brief transition delay
	player << "You emerge in [dest_cont.name]..."
	
	// Trigger any continent-specific effects (lighting, sounds, etc.)
	OnContinentEntered(player, destination_continent)
	
	return 1

/proc/OnContinentEntered(mob/players/player, continent_id)
	// Placeholder for continent-specific effects
	// Can be expanded to:
	// - Update HUD continent indicator
	// - Play arrival sound
	// - Display continent-specific UI
	// - Adjust lighting (story world: darker, sandboxX: bright, pvp: ominous)
	// - Trigger weather/ambience
	
	switch(continent_id)
		if(CONT_STORY)
			// Story world entry effects
			player.client.color = rgb(255, 255, 255)  // Normal colors
		if(CONT_SANDBOX)
			// Sandbox world entry effects
			player.client.color = rgb(255, 255, 255)  // Vibrant colors
		if(CONT_PVP)
			// PvP world entry effects
			player.client.color = rgb(200, 100, 100)  // Red-tinted danger
```

#### 2.3: Create World Selection Interface

**File**: `dm/WorldSelection.dm` (NEW - 150 lines)

```dm
/proc/ShowWorldSelectionUI(mob/players/player)
	// Called when player first logs in or uses /worlds command
	
	var/list/options = list()
	var/list/descriptions = list()
	
	for(var/cont_id in continents)
		var/datum/continent/cont = continents[cont_id]
		options += cont.name
		descriptions[cont.name] = "[cont.desc]\n\nStatus: [cont.allow_pvp ? "PvP Enabled" : "Peaceful"]"
	
	var/choice = input(player, "Select a world to enter:", "World Selection", options[1]) in options
	
	if(!choice) return
	
	// Find continent ID matching choice
	for(var/cont_id in continents)
		var/datum/continent/cont = continents[cont_id]
		if(cont.name == choice)
			TravelToContinent(player, cont.id)
			break

// Command to access world selection
/mob/players/verb/worlds()
	set name = "Worlds"
	set category = "Navigation"
	ShowWorldSelectionUI(src)
```

---

### Task 3: Update World Initialization (1 hour)

#### 3.1: Call Continent Initialization at Startup

**File**: `Pondera.dm` (MODIFY - already exists, add to world/New())

```dm
/world/New()
	..()
	
	// [... existing initialization code ...]
	
	// Initialize continental system
	InitializeContinents()
	
	// [... rest of init code ...]
```

#### 3.2: Update Character Data Persistence

**File**: `_DRCH2.dm` (MODIFY)

Add to character Write proc:

```dm
// Write continent data
W["current_continent"] = character.current_continent
W["continent_positions"] = character.continent_positions
// continent_inventory optional: implement in Phase D if needed
```

Add to character Read proc:

```dm
// Read continent data
if("current_continent" in data)
	character.current_continent = data["current_continent"]
else
	character.current_continent = CONT_STORY

if("continent_positions" in data)
	character.continent_positions = data["continent_positions"]
else
	character.continent_positions = list(
		CONT_STORY: list(x: 64, y: 64, z: 1),
		CONT_SANDBOX: list(x: 128, y: 128, z: 1),
		CONT_PVP: list(x: 200, y: 200, z: 1)
	)
```

---

### Task 4: Rule Enforcement System (1 hour)

#### 4.1: Create Rule Checker Procs

**File**: `dm/WorldSystem.dm` (continued)

```dm
/proc/CanAttackInContinent(mob/players/attacker, mob/players/defender)
	var/datum/continent/cont = GetContinent(attacker.current_continent)
	if(!cont) return 0
	
	// Only allow PvP on combat continents
	if(!cont.allow_pvp) return 0
	
	// Both must be on same continent
	if(attacker.current_continent != defender.current_continent) return 0
	
	return 1

/proc/CanBuildInContinent(mob/players/builder)
	var/datum/continent/cont = GetContinent(builder.current_continent)
	if(!cont) return 0
	return cont.allow_building

/proc/CanStealInContinent(mob/players/thief)
	var/datum/continent/cont = GetContinent(thief.current_continent)
	if(!cont) return 0
	return cont.allow_stealing

/proc/GetMonsterSpawnRate(continent_id)
	var/datum/continent/cont = GetContinent(continent_id)
	if(!cont) return 0
	return cont.monster_spawn ? 1.0 : 0  // 1.0 = normal rate, 0 = no spawning

/proc/ShouldSpawnNPC(continent_id)
	var/datum/continent/cont = GetContinent(continent_id)
	if(!cont) return 0
	return cont.npc_spawn

/proc/GetContinent(continent_id)
	// Already defined above, called frequently
	return continents[continent_id]
```

#### 4.2: Integrate Rule Checks into Combat System

**File**: `dm/s_damage2.dm` (MODIFY - existing combat code)

Before attack resolution:

```dm
// Check continent rules
if(!CanAttackInContinent(attacker, defender))
	attacker << "You cannot attack players in this continent!"
	return 0
```

#### 4.3: Integrate into Building System

**File**: `dm/Objects.dm` or `dm/FurnitureExtensions.dm` (MODIFY)

Before structure placement:

```dm
// Check if building allowed in this continent
if(!CanBuildInContinent(builder))
	builder << "Building is not permitted in this continent!"
	return 0
```

---

### Task 5: Testing & Validation (1-1.5 hours)

#### 5.1: Create Test Map

**File**: `test_world_system.dmm` (NEW)

Test map with:
- 3 isolated areas (Story, Sandbox, PvP spawn zones)
- Portal between each area
- Landmark structures to verify position restoration
- Dummy NPCs/structures per continent

#### 5.2: Write Test Cases

**Checklist**:
- [ ] InitializeContinents() creates all 3 continents
- [ ] GetContinent() returns correct continent data
- [ ] TravelToContinent() moves player to destination
- [ ] Player position saved on departure, restored on return
- [ ] continent_positions persists across logout/login
- [ ] CanAttackInContinent() allows PvP only on CONT_PVP
- [ ] CanBuildInContinent() returns correct values per continent
- [ ] CanStealInContinent() returns 0 on CONT_STORY/SANDBOX, 1 on CONT_PVP
- [ ] GetMonsterSpawnRate() returns 0 on CONT_SANDBOX
- [ ] ShouldSpawnNPC() returns 0 on CONT_SANDBOX and CONT_PVP

#### 5.3: Build & Verify

```powershell
# Run build task
dm: build - Pondera.dme

# Expected: 0 errors
# Warnings may increase slightly (new procs), acceptable
```

---

## Files to Create

| File | Lines | Purpose |
|------|-------|---------|
| `dm/WorldSystem.dm` | 250 | Continent framework, registry, rule checks |
| `dm/Portals.dm` | 200 | Portal objects, travel system |
| `dm/WorldSelection.dm` | 150 | World selection UI |
| `test_world_system.dmm` | 200 | Test map |

**Total New Code**: ~600 lines

## Files to Modify

| File | Changes | Impact |
|------|---------|--------|
| `!defines.dm` | Add continent constants | +8 lines |
| `dm/CharacterData.dm` | Add continent variables | +8 lines |
| `_DRCH2.dm` | Persist continent data | +20 lines |
| `Pondera.dme` | Add includes | +3 lines |
| `Pondera.dm` (or world file) | Call InitializeContinents() | +1 line |
| `dm/s_damage2.dm` | Add PvP check | +3 lines |
| `dm/Objects.dm` | Add building check | +3 lines |

**Total Modified Lines**: ~46 lines

---

## Integration Checklist

- [ ] Create `dm/WorldSystem.dm` with continent framework
- [ ] Create `dm/Portals.dm` with travel system
- [ ] Create `dm/WorldSelection.dm` with UI
- [ ] Update `!defines.dm` with continent constants
- [ ] Update `dm/CharacterData.dm` with continent variables
- [ ] Update `_DRCH2.dm` to persist continent data
- [ ] Update `Pondera.dme` to include new files
- [ ] Call `InitializeContinents()` in world startup
- [ ] Integrate PvP rule check into combat system
- [ ] Integrate building rule check into construction system
- [ ] Create and test on `test_world_system.dmm`
- [ ] Build and verify 0 errors
- [ ] Commit Phase A to git

---

## Implementation Notes

### Design Decisions

**Why Separate Continent Datums?**
- Allows dynamic continent creation (could add more in future)
- Clean data encapsulation for rules/parameters
- Easy to modify rules without code changes
- Foundation for procedural world variety

**Why Save Positions Per Continent?**
- Players expect to return to where they left
- Enables "continent hopping" without confusion
- Avoids spawn camp crowding (different start points)
- Supports story world narrative waypoints

**Why Rule Checks in Combat/Building?**
- Distributed enforcement more performant than centralized
- Enables continent-specific gameplay immediately
- No need for permission tables or complex logic
- Easy to understand and maintain

**Why Keep Recipe State Global?**
- Players shouldn't lose recipes switching continents
- Recipes are "learned" not "found in world"
- Encourages knowledge accumulation
- Supports "learn in sandbox, use in story" workflow

### Performance Considerations

- Continent lookups: O(1) hash table access (fast)
- Position saves: Only on travel (rare operation)
- Rule checks: Simple boolean operations (negligible cost)
- No new background loops (efficient)

### Extensibility

Future additions ready for:
- Continent-specific crafting recipes (add to continent datum)
- Seasonal variations per continent (add season var)
- Dynamic continent creation (just call new `/datum/continent`)
- Multi-region PvP zones (expand continent framework)
- Cross-continent markets (centralized trading post)

---

## Acceptance Criteria

✅ **Phase A is complete when:**

1. All three continents initialize on world startup
2. Player can travel between continents via portals
3. Player position saves and restores per continent
4. PvP/building rules enforced per continent
5. Recipe/skill state persists across continents
6. No compile errors, minimal new warnings
7. All test cases pass
8. Code committed with clear commit messages

---

## Next Phase Dependency

Phase B (Town Generator) depends on:
- ✅ Continent framework complete (Phase A)
- ✅ Procedural map generation (already exists)
- ⏳ Town layout algorithm (Phase B task)

Phase C (Story World Integration) depends on:
- ✅ Continent framework complete (Phase A)
- ✅ Town generation complete (Phase B)
- ✅ Map generator integration (Phase B)

---

**Ready to begin Phase A?** → Confirm, and implementation will start immediately.

