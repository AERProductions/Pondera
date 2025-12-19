// Pondera World/Continent System
// Core infrastructure for three-world architecture
// Manages continent definitions, registry, and rule enforcement

// ============================================================================
// CONTINENT DATUM - World Definition & Configuration
// ============================================================================

/datum/continent
	var
		// Identity
		name = ""               // "Kingdom of Freedom", "Creative Sandbox", "Battlelands"
		id = ""                 // "story", "sandbox", "pvp" (use constants from !defines.dm)
		desc = ""               // Description for UI/logs/tooltips
		type_flags = 0          // CONTINENT_PEACEFUL, CONTINENT_CREATIVE, CONTINENT_COMBAT flags
		
		// Map generation parameters
		generator_type = ""     // "story_procedural", "sandbox_bare", "pvp_survival"
		seed = 0                // Unique seed per continent (affects terrain)
		
		// Gameplay rules
		allow_pvp = 0           // Can players attack each other?
		allow_stealing = 0      // Can NPCs/players steal items?
		allow_building = 1      // Can players place structures?
		monster_spawn = 0       // Do monsters spawn naturally?
		npc_spawn = 0           // Do NPCs spawn?
		weather = 0             // Does weather occur (rain, snow)?
		
		// Portal/spawn location
		port_x = 0              // Port town X coordinate
		port_y = 0              // Port town Y coordinate
		port_z = 1              // Port town Z coordinate (will be base elevel)
	
	New(continent_id, continent_name)
		id = continent_id
		name = continent_name
		return src

// ============================================================================
// GLOBAL CONTINENT REGISTRY
// ============================================================================

var/list/continents = list()  // Indexed by ID ("story", "sandbox", "pvp")

// ============================================================================
// INITIALIZATION - Called at world startup
// ============================================================================

/proc/InitializeContinents()
	// Story Continent: Kingdom of Freedom (procedurally-generated with narrative anchors)
	var/datum/continent/story = new("story", "Kingdom of Freedom")
	story.desc = "A procedurally-generated story world with NPCs and guided progression"
	story.type_flags = 0  // No special flags (normal mode)
	story.generator_type = "story_procedural"
	story.seed = 42       // Fixed seed (could randomize per server instance)
	story.allow_pvp = 0
	story.allow_stealing = 0
	story.allow_building = 1  // Can build housing
	story.monster_spawn = 1   // Creatures present
	story.npc_spawn = 1       // NPCs present
	story.weather = 1
	story.port_x = 64     // Starting area center
	story.port_y = 64
	story.port_z = 1
	continents[story.id] = story
	
	// Sandbox Continent: Creative Sandbox (peaceful, creative, no pressure)
	var/datum/continent/sandbox = new("sandbox", "Creative Sandbox")
	sandbox.desc = "Peaceful creative building world with all recipes available"
	sandbox.type_flags = CONTINENT_PEACEFUL | CONTINENT_CREATIVE
	sandbox.generator_type = "sandbox_bare"
	sandbox.seed = 9999
	sandbox.allow_pvp = 0
	sandbox.allow_stealing = 0
	sandbox.allow_building = 1
	sandbox.monster_spawn = 0  // No creatures
	sandbox.npc_spawn = 0      // No NPCs
	sandbox.weather = 0        // No weather
	sandbox.port_x = 128
	sandbox.port_y = 128
	sandbox.port_z = 1
	continents[sandbox.id] = sandbox
	
	// PvP Continent: Battlelands (competitive, raiding, territory control)
	var/datum/continent/pvp = new("pvp", "Battlelands")
	pvp.desc = "Competitive survival continent with PvP, raiding, and territory control"
	pvp.type_flags = CONTINENT_COMBAT
	pvp.generator_type = "pvp_survival"
	pvp.seed = 12345
	pvp.allow_pvp = 1         // Can attack players
	pvp.allow_stealing = 1    // Can raid/steal
	pvp.allow_building = 1    // Can build fortifications
	pvp.monster_spawn = 1     // Creatures present (threats)
	pvp.npc_spawn = 0         // No friendly NPCs
	pvp.weather = 1           // Weather affects tactics
	pvp.port_x = 200
	pvp.port_y = 200
	pvp.port_z = 1
	continents[pvp.id] = pvp
	
	// Return for testing
	return continents

// ============================================================================
// CONTINENT LOOKUP
// ============================================================================

/proc/GetContinent(continent_id)
	// Safe continent lookup with validation
	if(!continent_id) return null
	if(!(continent_id in continents)) return null
	return continents[continent_id]

/proc/ListContinents()
	// Return list of all continent names for UI
	var/list/names = list()
	for(var/cont_id in continents)
		var/datum/continent/cont = continents[cont_id]
		names += cont.name
	return names

// ============================================================================
// RULE ENFORCEMENT - Check continent rules before action
// ============================================================================

/proc/CanAttackInContinent(mob/players/attacker, mob/players/defender)
	// Check if PvP is allowed
	if(!attacker || !defender) return 0
	if(attacker.current_continent != defender.current_continent) return 0  // Different worlds
	
	var/datum/continent/cont = GetContinent(attacker.current_continent)
	if(!cont) return 0
	
	return cont.allow_pvp

/proc/CanStealInContinent(mob/players/thief)
	// Check if stealing/raiding is allowed
	if(!thief) return 0
	
	var/datum/continent/cont = GetContinent(thief.current_continent)
	if(!cont) return 0
	
	return cont.allow_stealing

/proc/CanBuildInContinent(mob/players/builder)
	// Check if building/placing structures is allowed
	if(!builder) return 0
	
	var/datum/continent/cont = GetContinent(builder.current_continent)
	if(!cont) return 0
	
	return cont.allow_building

/proc/GetMonsterSpawnRate(continent_id)
	// Return spawn rate multiplier for creatures
	// 0 = no spawning, 1.0 = normal rate, >1.0 = increased rate
	var/datum/continent/cont = GetContinent(continent_id)
	if(!cont) return 0
	
	if(cont.monster_spawn)
		return 1.0  // Normal rate
	else
		return 0    // No spawning

/proc/ShouldSpawnNPC(continent_id)
	// Check if NPCs should spawn on this continent
	var/datum/continent/cont = GetContinent(continent_id)
	if(!cont) return 0
	
	return cont.npc_spawn

/proc/ShouldHaveWeather(continent_id)
	// Check if weather should occur on this continent
	var/datum/continent/cont = GetContinent(continent_id)
	if(!cont) return 0
	
	return cont.weather

/proc/IsPeacefulContinent(continent_id)
	// Check if this is a peaceful continent (no PvP)
	var/datum/continent/cont = GetContinent(continent_id)
	if(!cont) return 0
	
	return !(cont.allow_pvp)

/proc/IsCreativeContinent(continent_id)
	// Check if this is designed for creative expression
	var/datum/continent/cont = GetContinent(continent_id)
	if(!cont) return 0
	
	return (cont.type_flags & CONTINENT_CREATIVE)

/proc/IsCombatContinent(continent_id)
	// Check if this is designed for combat/PvP
	var/datum/continent/cont = GetContinent(continent_id)
	if(!cont) return 0
	
	return (cont.type_flags & CONTINENT_COMBAT)

// ============================================================================
// DEBUG - Console commands for testing
// ============================================================================

/proc/DebugContinentStatus()
	// Print all continent configurations to console
	. = "=== CONTINENT STATUS ===\n"
	for(var/cont_id in continents)
		var/datum/continent/cont = continents[cont_id]
		. += "[cont.name] ([cont.id]):\n"
		. += "  PvP: [cont.allow_pvp] | Building: [cont.allow_building] | "
		. += "Monsters: [cont.monster_spawn] | NPCs: [cont.npc_spawn] | "
		. += "Weather: [cont.weather]\n"
		. += "  Port: ([cont.port_x], [cont.port_y], [cont.port_z])\n"
	return .
