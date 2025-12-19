/**
 * RegionalConflictSystem.dm
 * Phase 26: Regional Conflict Escalation & Faction Territory Control
 * 
 * Enables large-scale territorial conflicts:
 * - Factions compete for regional dominance
 * - Multiple guilds form alliances with shared goals
 * - Control key regions to unlock economic bonuses
 * - Faction capital grants territory-wide buffs
 * - Regional conquest events trigger across continents
 * - Player territories grant faction strategic value
 * 
 * Integration Points:
 * - GuildSystem: Guilds join factions
 * - TerritoryClaimSystem: Regional control bonuses
 * - TerritoryWarsSystem: Faction wars trigger on territory loss
 * - SeasonalTerritoryEventsSystem: Events affect regional control
 * - DynamicMarketPricingSystem: Faction control affects prices
 * - EconomyCombatIntegrationSystem: Bounties for faction kills
 * 
 * Faction Types:
 * - Crown (Story): Lawful, taxation benefits, castle defense bonuses
 * - Nomad (PvP): Raiding bonuses, mobile speed, reduced visibility range
 * - Merchant (Sandbox): Trade discounts, market manipulation, peaceful
 * 
 * Regional Control:
 * - Control 3+ adjacent territories = Regional node
 * - Control 2+ nodes = Regional dominance
 * - Dominance grants 50% bonus to all territory income
 * - Capital territory grants +20% faction-wide defense
 */

// ============================================================================
// FACTION DATUM
// ============================================================================

/**
 * /datum/faction
 * Represents large-scale faction controlling multiple regions
 */
/datum/faction
	var
		// Identification
		faction_id              // Unique ID
		faction_name            // Display name
		faction_color           // Hex color (#FF0000)
		faction_alignment       // "lawful", "neutral", "chaotic"
		
		// Leadership
		list/member_guilds = list()    // Guilds in faction
		list/leaders = list()          // Guild leaders (officers)
		
		// Territory
		list/controlled_territories = list()  // Territory IDs owned by members
		list/regional_nodes = list()          // Strategic regions (3+ adjacent)
		capital_territory_id = ""             // Faction capital (special bonuses)
		
		// Economics
		faction_treasury = 0    // Shared war fund
		treasury_growth = 0     // Income per cycle
		control_bonus = 0       // % income bonus from regional control
		
		// Warfare
		list/enemy_factions = list()   // Hostile factions
		list/allied_factions = list()  // Friendly factions
		total_wars = 0          // Wars declared
		total_victories = 0     // Wars won
		war_history = list()    // Past wars log
		
		// Buffs (applied per control)
		defense_bonus = 0       // % defense bonus from capital
		income_bonus = 0        // % income bonus from regions
		movement_bonus = 0      // % movement speed bonus

/**
 * New(faction_name, alignment, color)
 * Create new faction
 */
/datum/faction/New(faction_name, alignment, color)
	src.faction_name = faction_name
	src.faction_alignment = alignment
	src.faction_color = color
	src.faction_id = "faction_[faction_name]_[world.time]"
	
	world.log << "Faction created: [faction_name] ([alignment])"

// ============================================================================
// FACTION REGISTRY
// ============================================================================

var
	list/faction_registry = list()        // All factions
	list/factions_by_name = list()        // Index by name
	list/factions_by_guild = list()       // Guild → faction mapping
	list/guild_members_cache = list()     // Cache: guild members per faction

/**
 * CreateFaction(faction_name, alignment, color)
 * Create new faction
 * 
 * Requirements:
 * - First guild member pays 10000 lucre to establish
 * - Unique faction name
 */
/proc/CreateFaction(faction_name, alignment, color)
	if(!faction_name)
		return null
	
	// Check name unique
	if(factions_by_name[faction_name])
		world.log << "Faction name '[faction_name]' already taken"
		return null
	
	// Create faction
	var/datum/faction/faction = new(faction_name, alignment, color)
	
	// Register
	faction_registry += faction
	factions_by_name[faction_name] = faction
	
	world.log << "Faction [faction_name] established"
	return faction

/**
 * JoinFactionWithGuild(datum/guild/guild, datum/faction/faction)
 * Guild joins faction (guild leader initiates)
 */
/proc/JoinFactionWithGuild(datum/guild/guild, datum/faction/faction)
	if(!guild || !faction)
		return 0
	
	// Check guild not already in faction
	if(factions_by_guild[guild.guild_id])
		return 0
	
	// Add guild to faction
	faction.member_guilds += guild.guild_id
	factions_by_guild[guild.guild_id] = faction
	
	// Add guild territories to faction control
	for(var/territory_id in guild.territories)
		faction.controlled_territories += territory_id
	
	world.log << "[guild.guild_name] joined [faction.faction_name]"
	return 1

/**
 * GetGuildFaction(guild_id)
 * Get faction for guild
 */
/proc/GetGuildFaction(guild_id)
	return factions_by_guild[guild_id] || null

/**
 * GetFactionByName(faction_name)
 * Lookup faction
 */
/proc/GetFactionByName(faction_name)
	return factions_by_name[faction_name] || null

// ============================================================================
// REGIONAL CONTROL SYSTEM
// ============================================================================

/**
 * /datum/regional_node
 * Represents strategic 3-territory control zone
 */
/datum/regional_node
	var
		// Identification
		node_id                 // Unique ID
		node_name               // Display name (e.g. "Steel Triangle")
		
		// Geography
		list/territory_ids = list()  // 3 core territories
		continent               // Parent continent
		
		// Control
		controlling_faction_id  // Faction controlling node
		control_start_time = 0
		
		// Benefits
		income_multiplier = 1.5     // 50% bonus to all 3 territories
		defense_multiplier = 1.2    // 20% defense bonus
		resource_discovery = 1.3    // 30% resource yield bonus

/**
 * New(node_id, node_name, territory_list, continent)
 * Create regional node (3 territories)
 */
/datum/regional_node/New(node_id, node_name, territory_list, continent)
	src.node_id = node_id
	src.node_name = node_name
	// Copy territory list
	for(var/tid in territory_list)
		src.territory_ids += tid
	src.continent = continent

// ============================================================================
// REGIONAL NODES (Pre-defined)
// ============================================================================

var
	list/regional_nodes_registry = list()  // All nodes
	list/nodes_by_territory = list()       // Territory → nodes it's in

/**
 * InitializeRegionalNodes()
 * Create pre-defined regional nodes
 */
/proc/InitializeRegionalNodes()
	// Story Kingdom: 1 node (both territories = control)
	var/datum/regional_node/story_node = new("story_central", "Kingdom Core", list("story_capital", "story_frontier"), "story")
	regional_nodes_registry += story_node
	
	// PvP Battlelands: 2 nodes (strategic resource zones)
	var/datum/regional_node/pvp_north = new("pvp_north", "Northern Alliance", list("pvp_steel_mine", "pvp_timber_forest", "pvp_crystal_caverns"), "pvp")
	var/datum/regional_node/pvp_south = new("pvp_south", "Southern Stronghold", list("pvp_copper_grove", "pvp_steel_mine", "pvp_crystal_caverns"), "pvp")
	
	regional_nodes_registry += pvp_north
	regional_nodes_registry += pvp_south
	
	// Map territories to nodes
	for(var/datum/regional_node/node in regional_nodes_registry)
		for(var/territory_id in node.territory_ids)
			if(!nodes_by_territory[territory_id])
				nodes_by_territory[territory_id] = list()
			nodes_by_territory[territory_id] += node

/**
 * UpdateRegionalControl()
 * Background loop: check territory ownership and update faction control
 * Runs daily
 */
/proc/UpdateRegionalControl()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(86400)  // Daily check (24 hours)
		
		if(!world_initialization_complete)
			continue
		
		// Iterate all regional nodes
		for(var/datum/regional_node/node in regional_nodes_registry)
			// Get faction control for each territory in node
			var/list/faction_control = list()
			
			for(var/territory_id in node.territory_ids)
				var/datum/territory_claim/territory = GetTerritoryByID(territory_id)
				if(!territory || territory.owner_player_key == "")
					continue
				
				// Find faction controlling this territory
				var/datum/faction/territory_faction = null
				for(var/guild_id in factions_by_guild)
					var/datum/guild/guild = GetGuildByID(guild_id)
					if(guild && (territory_id in guild.territories))
						territory_faction = GetGuildFaction(guild_id)
						break
				
				if(territory_faction)
					if(!faction_control[territory_faction.faction_id])
						faction_control[territory_faction.faction_id] = 0
					faction_control[territory_faction.faction_id]++
			
			// Check if faction controls 3+ territories in node
			for(var/faction_id in faction_control)
				if(faction_control[faction_id] >= 3)
					// Faction controls node!
					node.controlling_faction_id = faction_id
					node.control_start_time = world.time
					world.log << "Node [node.node_name] now controlled by faction [faction_id]"

/**
 * GetNodeControlBonus(territory_id)
 * Get income/defense bonus from regional node control
 */
/proc/GetNodeControlBonus(territory_id)
	var/list/nodes = nodes_by_territory[territory_id]
	if(!nodes)
		return 1.0
	
	var/bonus = 1.0
	for(var/datum/regional_node/node in nodes)
		if(node.controlling_faction_id != "")
			bonus *= node.income_multiplier
	
	return bonus

/**
 * GetRegionalDefenseBonus(territory_id)
 * Get defense bonus from regional control
 */
/proc/GetRegionalDefenseBonus(territory_id)
	var/list/nodes = nodes_by_territory[territory_id]
	if(!nodes)
		return 1.0
	
	var/bonus = 1.0
	for(var/datum/regional_node/node in nodes)
		if(node.controlling_faction_id != "")
			bonus *= node.defense_multiplier
	
	return bonus

// ============================================================================
// CAPITAL TERRITORY SYSTEM
// ============================================================================

/**
 * SetFactionCapital(datum/faction/faction, territory_id)
 * Establish faction capital (grants faction-wide buffs)
 * 
 * Requirements:
 * - Faction must control territory
 * - Territory must be major tier (tier 2+)
 */
/proc/SetFactionCapital(datum/faction/faction, territory_id)
	if(!faction || !territory_id)
		return 0
	
	var/datum/territory_claim/territory = GetTerritoryByID(territory_id)
	if(!territory)
		return 0
	
	// Check faction controls territory
	var/controlled = 0
	for(var/guild_id in faction.member_guilds)
		var/datum/guild/guild = GetGuildByID(guild_id)
		if(guild && (territory_id in guild.territories))
			controlled = 1
			break
	
	if(!controlled)
		return 0
	
	// Set capital
	faction.capital_territory_id = territory_id
	faction.defense_bonus = 20  // +20% defense faction-wide
	
	world.log << "[faction.faction_name] capital established at [territory.territory_name]"
	return 1

/**
 * GetCapitalDefenseBonus(faction_id)
 * Get faction-wide defense from capital
 */
/proc/GetCapitalDefenseBonus(faction_id)
	for(var/datum/faction/faction in faction_registry)
		if(faction.faction_id == faction_id)
			if(faction.capital_territory_id != "")
				return faction.defense_bonus
	
	return 0

// ============================================================================
// FACTION WARFARE
// ============================================================================

/**
 * DeclareFactionalWar(datum/faction/attacker, datum/faction/defender)
 * Faction declares war on rival faction
 * All guild wars become faction wars (shared treasury, shared victory)
 */
/proc/DeclareFactionalWar(datum/faction/attacker, datum/faction/defender)
	if(!attacker || !defender || attacker == defender)
		return 0
	
	// Check treasury
	if(attacker.faction_treasury < 5000)
		return 0
	
	// Deduct cost
	attacker.faction_treasury -= 5000
	
	// Mark as enemies
	attacker.enemy_factions += defender.faction_id
	defender.enemy_factions += attacker.faction_id
	
	attacker.total_wars++
	
	// All member guilds are now at war
	for(var/guild_id in attacker.member_guilds)
		for(var/def_guild_id in defender.member_guilds)
			// Guild war registered
			world.log << "Guild war triggered: [guild_id] vs [def_guild_id]"
	
	world.log << "[attacker.faction_name] declared war on [defender.faction_name]!"
	return 1

/**
 * FactionalVictory(datum/faction/victor, datum/faction/loser)
 * Faction achieves victory (captured capital or destroyed all territories)
 */
/proc/FactionalVictory(datum/faction/victor, datum/faction/loser)
	if(!victor || !loser)
		return 0
	
	// Add victory bonus to treasury
	victor.faction_treasury += 10000
	victor.total_victories++
	
	// Seize loser's territories? Or just control them?
	// For now: transfer to victor's first guild
	
	// Remove enemy status
	victor.enemy_factions -= loser.faction_id
	loser.enemy_factions -= victor.faction_id
	
	// Log war
	victor.war_history += list(
		"opponent" = loser.faction_name,
		"result" = "victory",
		"timestamp" = world.time,
		"reward" = 10000
	)
	
	loser.war_history += list(
		"opponent" = victor.faction_name,
		"result" = "defeat",
		"timestamp" = world.time,
		"loss" = 10000
	)
	
	world.log << "[victor.faction_name] achieved victory over [loser.faction_name]!"
	return 1

// ============================================================================
// FACTION INFORMATION & STATUS
// ============================================================================

/**
 * GetFactionInfo(datum/faction/faction)
 * Return formatted faction status
 */
/proc/GetFactionInfo(datum/faction/faction)
	if(!faction)
		return "Faction not found"
	
	var/info = "═════════════════════════════════════════\n"
	info += "FACTION: [faction.faction_name]\n"
	info += "Alignment: [faction.faction_alignment]\n"
	info += "═════════════════════════════════════════\n"
	info += "Member Guilds: [faction.member_guilds.len]\n"
	info += "Controlled Territories: [faction.controlled_territories.len]\n"
	info += "Regional Nodes Held: [faction.regional_nodes.len]\n"
	info += "Treasury: [faction.faction_treasury] lucre\n"
	info += "Treasury Income: [faction.treasury_growth] per cycle\n"
	info += "═════════════════════════════════════════\n"
	info += "Victories: [faction.total_victories]/[faction.total_wars]\n"
	info += "Enemies: [faction.enemy_factions.len]\n"
	info += "Allies: [faction.allied_factions.len]\n"
	
	if(faction.capital_territory_id != "")
		var/datum/territory_claim/capital = GetTerritoryByID(faction.capital_territory_id)
		if(capital)
			info += "Capital: [capital.territory_name]\n"
	
	return info

/**
 * GetFactionLeaderboard()
 * Return faction rankings
 */
/proc/GetFactionLeaderboard()
	var/list/factions_sorted = list()
	
	// Sort by victory count
	for(var/datum/faction/faction in faction_registry)
		factions_sorted += faction
	
	// Bubble sort by victories (descending)
	var/swapped = 1
	while(swapped)
		swapped = 0
		for(var/i = 1; i < factions_sorted.len; i++)
			var/datum/faction/f1 = factions_sorted[i]
			var/datum/faction/f2 = factions_sorted[i+1]
			if(f1.total_victories < f2.total_victories)
				factions_sorted[i] = f2
				factions_sorted[i+1] = f1
				swapped = 1
	
	var/leaderboard = "FACTION LEADERBOARD\n"
	leaderboard += "═══════════════════════════════════════════════════════════\n"
	
	var/rank = 1
	for(var/datum/faction/faction in factions_sorted)
		leaderboard += "[rank]. [faction.faction_name] - [faction.total_victories] victories\n"
		rank++
	
	return leaderboard

// ============================================================================
// FACTION BENEFITS & BUFFS
// ============================================================================

/**
 * ProcessFactionTreasuryIncome()
 * Background loop: collect faction treasury from member territories
 * Runs daily
 */
/proc/ProcessFactionTreasuryIncome()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(86400)  // Daily
		
		if(!world_initialization_complete)
			continue
		
		for(var/datum/faction/faction in faction_registry)
			// Collect 10% of member territory income to faction treasury
			var/daily_income = 0
			
			for(var/territory_id in faction.controlled_territories)
				var/datum/territory_claim/territory = GetTerritoryByID(territory_id)
				if(territory)
					// Territory passive income: tier * 100 lucre per day
					var/territory_income = territory.tier * 100
					
					// Apply bonuses
					territory_income *= GetNodeControlBonus(territory_id)
					territory_income *= GetRegionalDefenseBonus(territory_id)
					
					// 10% goes to faction treasury
					daily_income += territory_income * 0.1
			
			faction.faction_treasury += daily_income
			faction.treasury_growth = daily_income
			
			if(daily_income > 0)
				world.log << "[faction.faction_name] treasury received [daily_income] lucre"

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeRegionalConflict()
 * Boot-time initialization
 * Called from InitializationManager at T+426
 */
/proc/InitializeRegionalConflict()
	// Initialize factions (empty by default)
	if(!faction_registry)
		faction_registry = list()
		factions_by_name = list()
		factions_by_guild = list()
	
	// Initialize regional nodes
	InitializeRegionalNodes()
	
	// Start background loops
	spawn()
		UpdateRegionalControl()
	
	spawn()
		ProcessFactionTreasuryIncome()
	
	world.log << "Regional Conflict System initialized"
	return

// ============================================================================
// REGIONAL CONFLICT SYSTEM SUMMARY
// ============================================================================

/*
 * Phase 26: Regional Conflict Escalation brings guild-scale gameplay to faction level:
 * 
 * FACTION MECHANICS:
 * - Create faction: Free (first guild joining)
 * - Join faction: Guild adds its territories to faction control
 * - Leave faction: Guild removes from faction (reduces control)
 * - Faction roles: Leader (declare war), Member (build/raid)
 * 
 * REGIONAL CONTROL:
 * - 3+ territories in region = Node control
 * - Node control grants 50% income bonus to all 3
 * - Node control grants 20% defense bonus to all 3
 * - Control majority of nodes = regional dominance
 * 
 * FACTION CAPITAL:
 * - Most important territory becomes capital
 * - Capital grants +20% defense faction-wide
 * - Capital lost = major morale/strategic blow
 * - Defending capital grants extra incentives
 * 
 * FACTION WARFARE:
 * - Declare war: 5000L cost (shared treasury)
 * - Victory grants: 10000L + territory control
 * - War affects all member guilds simultaneously
 * - Factional victory → control opponent's territories
 * 
 * ECONOMIC LOOP (Faction Scale):
 * - Collect 10% of member territory income
 * - Territory income = (tier*100) × node_bonus × defense_bonus
 * - Fund faction wars, territory upgrades, special events
 * - Faction treasury grows = more aggressive warfare
 * 
 * NEXT: Multi-Region Conflict (cross-continent warfare)
 *       Siege Warfare Equipment (battering rams, catapults)
 *       NPC Garrison System (automatic defenders)
 */
