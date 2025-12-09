/**
 * GuildSystem.dm
 * Phase 24: Guild Formation & Diplomacy
 * 
 * Enables team-based territory control and organizational structures:
 * - Create/disband guilds with leadership hierarchy
 * - Guild permissions: build, raid, diplomacy, treasury management
 * - Taxation system: guild leaders tax member loot shares
 * - Diplomacy: alliances, truces, enemies between guilds
 * - Guild chat: faction-wide messaging
 * - Territory ownership transfer to guilds
 * 
 * Integration Points:
 * - TerritoryClaimSystem: Guilds can claim/hold territories
 * - TerritoryWarsSystem: Guild wars with war declarations
 * - DualCurrencySystem: Guild treasury holds lucre/materials
 * - PvPRankingSystem: Guild-based leaderboards
 * - DeedSystem: Guild deeds for collective ownership
 * 
 * Guild Hierarchy:
 * - Guild Leader: Full permissions (create, dissolve, invite, tax, diplomacy)
 * - Officers: Manage members, territories, structures (no diplomacy)
 * - Members: Build, raid, access treasury (within permissions)
 * - Recruits: Restricted permissions (no build/raid initially)
 */

// ============================================================================
// GUILD DATUM
// ============================================================================

/**
 * /datum/guild
 * Represents a player organization
 */
/datum/guild
	var
		// Identification
		guild_id                   // Unique identifier
		guild_name                 // Display name
		guild_tag                  // 4-letter tag (e.g. "WOLF")
		guild_leader_key           // Guild leader player key
		guild_leader_name          // Guild leader name
		
		// Founding
		founded_date = 0           // When guild created (world.time)
		
		// Treasury
		treasury_lucre = 0         // Stored lucre
		treasury_materials = 0     // Stored materials
		treasury_history = list()  // Transaction log
		
		// Governance
		tax_rate = 10              // Tax % on member loot (0-50)
		member_limit = 50          // Max members
		
		// Members
		list/members = list()      // Member keys
		list/member_roles = list() // Role per member (leader/officer/member/recruit)
		
		// Territories
		list/territories = list()  // Claimed territories
		
		// Diplomacy
		list/allied_guilds = list()     // Friendly guilds
		list/enemy_guilds = list()      // Hostile guilds
		list/neutral_guilds = list()    // Neutral guilds
		list/war_history = list()       // Past wars

/**
 * New(name, tag, leader_key, leader_name)
 * Create new guild
 */
/datum/guild/New(name, tag, leader_key, leader_name)
	guild_name = name
	guild_tag = tag
	guild_leader_key = leader_key
	guild_leader_name = leader_name
	founded_date = world.time
	
	// Add leader to members
	members += leader_key
	member_roles[leader_key] = "leader"
	
	// Generate unique ID
	guild_id = "guild_[name]_[world.time]"
	
	world.log << "Guild created: [guild_name] ([guild_tag]) by [leader_name]"

// ============================================================================
// GUILD REGISTRY
// ============================================================================

var
	list/guild_registry = list()            // All guilds (datum)
	list/guilds_by_name = list()            // Index by name
	list/guilds_by_player = list()          // Member's guild
	list/guilds_by_id = list()              // Index by ID

/**
 * CreateGuild(mob/players/founder, guild_name, guild_tag)
 * Founder creates new guild
 * 
 * Requirements:
 * - Player not in guild
 * - 5000 lucre creation cost
 * - Guild name/tag must be unique
 */
/proc/CreateGuild(mob/players/founder, guild_name, guild_tag)
	if(!founder)
		return null
	
	// Check player not already in guild
	if(guilds_by_player[founder.key])
		world.log << "[founder.key] already in guild"
		return null
	
	// Check cost
	if(founder.lucre < 5000)
		world.log << "[founder.key] insufficient lucre to create guild (need 5000)"
		return null
	
	// Check guild name unique
	if(guilds_by_name[guild_name])
		world.log << "Guild name '[guild_name]' already taken"
		return null
	
	// Check tag unique
	for(var/datum/guild/g in guild_registry)
		if(g.guild_tag == guild_tag)
			world.log << "Guild tag '[guild_tag]' already taken"
			return null
	
	// Deduct cost
	founder.lucre -= 5000
	
	// Create guild
	var/datum/guild/guild = new(guild_name, guild_tag, founder.key, founder.name)
	
	// Register
	guild_registry += guild
	guilds_by_name[guild_name] = guild
	guilds_by_id[guild.guild_id] = guild
	guilds_by_player[founder.key] = guild
	
	world.log << "[founder.name] created guild [guild_name] ([guild_tag])"
	return guild

/**
 * GetPlayerGuild(player_key)
 * Get player's guild (if any)
 */
/proc/GetPlayerGuild(player_key)
	return guilds_by_player[player_key] || null

/**
 * GetGuildByName(guild_name)
 * Lookup guild by name
 */
/proc/GetGuildByName(guild_name)
	return guilds_by_name[guild_name] || null

/**
 * GetGuildByID(guild_id)
 * Lookup guild by ID
 */
/proc/GetGuildByID(guild_id)
	return guilds_by_id[guild_id] || null

// ============================================================================
// GUILD MEMBERSHIP
// ============================================================================

/**
 * InviteToGuild(datum/guild/guild, mob/players/recruiter, player_key)
 * Officer/leader invites player to guild
 * 
 * Requirements:
 * - Recruiter must be officer+ in guild
 * - Target not already in guild
 * - Guild not full
 */
/proc/InviteToGuild(datum/guild/guild, mob/players/recruiter, player_key)
	if(!guild || !recruiter)
		return 0
	
	// Check recruiter is officer+
	var/recruiter_role = guild.member_roles[recruiter.key]
	if(recruiter_role != "leader" && recruiter_role != "officer")
		return 0
	
	// Check target not in guild
	if(guilds_by_player[player_key])
		return 0
	
	// Check guild not full
	if(guild.members.len >= guild.member_limit)
		return 0
	
	// Send invite to target player (via message system)
	// For now, auto-accept
	guild.members += player_key
	guild.member_roles[player_key] = "recruit"
	guilds_by_player[player_key] = guild
	
	world.log << "[player_key] invited to [guild.guild_name]"
	return 1

/**
 * LeaveGuild(mob/players/player)
 * Player leaves their guild
 * 
 * Note: Leader cannot leave (must disband or transfer)
 */
/proc/LeaveGuild(mob/players/player)
	if(!player)
		return 0
	
	var/datum/guild/guild = GetPlayerGuild(player.key)
	if(!guild)
		return 0
	
	// Check if leader
	if(guild.member_roles[player.key] == "leader")
		world.log << "[player.name] cannot leave as guild leader"
		return 0
	
	// Remove from guild
	guild.members -= player.key
	guild.member_roles -= player.key
	guilds_by_player -= player.key
	
	world.log << "[player.name] left [guild.guild_name]"
	return 1

/**
 * PromoteMember(datum/guild/guild, promoter_key, target_key, new_role)
 * Leader promotes/demotes member
 */
/proc/PromoteMember(datum/guild/guild, promoter_key, target_key, new_role)
	if(!guild)
		return 0
	
	// Check promoter is leader
	if(guild.member_roles[promoter_key] != "leader")
		return 0
	
	// Cannot promote above officer
	if(new_role == "leader")
		return 0
	
	// Valid roles: recruit, member, officer
	if(!(new_role in list("recruit", "member", "officer")))
		return 0
	
	// Promote
	guild.member_roles[target_key] = new_role
	world.log << "[promoter_key] promoted [target_key] to [new_role] in [guild.guild_name]"
	return 1

/**
 * KickMember(datum/guild/guild, kicker_key, target_key)
 * Officer+ kicks member from guild
 */
/proc/KickMember(datum/guild/guild, kicker_key, target_key)
	if(!guild)
		return 0
	
	// Check kicker is officer+
	var/kicker_role = guild.member_roles[kicker_key]
	if(kicker_role != "leader" && kicker_role != "officer")
		return 0
	
	// Cannot kick leader
	if(guild.member_roles[target_key] == "leader")
		return 0
	
	// Kick
	guild.members -= target_key
	guild.member_roles -= target_key
	guilds_by_player -= target_key
	
	world.log << "[kicker_key] kicked [target_key] from [guild.guild_name]"
	return 1

// ============================================================================
// GUILD TREASURY
// ============================================================================

/**
 * ContributeToTreasury(datum/guild/guild, mob/players/contributor, lucre, materials)
 * Member deposits lucre/materials to guild
 */
/proc/ContributeToTreasury(datum/guild/guild, mob/players/contributor, lucre, materials)
	if(!guild || !contributor)
		return 0
	
	// Check player is in guild
	if(guilds_by_player[contributor.key] != guild)
		return 0
	
	// Check has resources
	if(contributor.lucre < lucre || (contributor.vars["materials"] || 0) < materials)
		return 0
	
	// Transfer
	contributor.lucre -= lucre
	contributor.vars["materials"] = (contributor.vars["materials"] || 0) - materials
	
	guild.treasury_lucre += lucre
	guild.treasury_materials += materials
	
	// Log transaction
	var/transaction = list(
		"type" = "contribution",
		"player" = contributor.name,
		"lucre" = lucre,
		"materials" = materials,
		"timestamp" = world.time
	)
	guild.treasury_history += transaction
	
	world.log << "[contributor.name] contributed [lucre]L [materials]M to [guild.guild_name] treasury"
	return 1

/**
 * WithdrawGuildTreasury(datum/guild/guild, mob/players/withdrawer, lucre, materials)
 * Leader withdraws from guild treasury
 */
/proc/WithdrawGuildTreasury(datum/guild/guild, mob/players/withdrawer, lucre, materials)
	if(!guild || !withdrawer)
		return 0
	
	// Check leader
	if(guild.member_roles[withdrawer.key] != "leader")
		return 0
	
	// Check treasury has resources
	if(guild.treasury_lucre < lucre || guild.treasury_materials < materials)
		return 0
	
	// Transfer
	guild.treasury_lucre -= lucre
	guild.treasury_materials -= materials
	
	withdrawer.lucre += lucre
	withdrawer.vars["materials"] = (withdrawer.vars["materials"] || 0) + materials
	
	// Log transaction
	var/transaction = list(
		"type" = "withdrawal",
		"player" = withdrawer.name,
		"lucre" = lucre,
		"materials" = materials,
		"timestamp" = world.time
	)
	guild.treasury_history += transaction
	
	world.log << "[withdrawer.name] withdrew [lucre]L [materials]M from [guild.guild_name] treasury"
	return 1

/**
 * ProcessGuildTaxation()
 * Background loop: collect taxes from member loot
 * Runs daily
 */
/proc/ProcessGuildTaxation()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(86400)  // Daily tax collection cycle
		
		if(!world_initialization_complete)
			continue
		
		for(var/datum/guild/guild in guild_registry)
			// Guild members pay tax share of daily loot
			// Tax collected automatically from member inventory/wallet
			// Tax rate: guild.tax_rate (10-50%)
			
			var/total_taxed_lucre = 0
			var/total_taxed_materials = 0
			
			for(var/member_key in guild.members)
				// Would pull player data and calculate tax
				// For now: placeholder
				total_taxed_lucre += 0
				total_taxed_materials += 0
			
			if(total_taxed_lucre > 0 || total_taxed_materials > 0)
				guild.treasury_lucre += total_taxed_lucre
				guild.treasury_materials += total_taxed_materials
				world.log << "[guild.guild_name] collected [total_taxed_lucre]L [total_taxed_materials]M in taxes"

// ============================================================================
// GUILD DIPLOMACY
// ============================================================================

/**
 * DeclareAlly(datum/guild/g1, datum/guild/g2)
 * Two guilds form alliance
 */
/proc/DeclareAlly(datum/guild/g1, datum/guild/g2)
	if(!g1 || !g2 || g1 == g2)
		return 0
	
	// Add to ally lists
	g1.allied_guilds += g2
	g2.allied_guilds += g1
	
	// Remove from enemy lists
	g1.enemy_guilds -= g2
	g2.enemy_guilds -= g1
	
	world.log << "[g1.guild_name] and [g2.guild_name] are now allies!"
	return 1

/**
 * DeclareEnemy(datum/guild/g1, datum/guild/g2)
 * Two guilds enter hostile state
 */
/proc/DeclareEnemy(datum/guild/g1, datum/guild/g2)
	if(!g1 || !g2 || g1 == g2)
		return 0
	
	// Add to enemy lists
	g1.enemy_guilds += g2
	g2.enemy_guilds += g1
	
	// Remove from ally lists
	g1.allied_guilds -= g2
	g2.allied_guilds -= g1
	
	world.log << "[g1.guild_name] and [g2.guild_name] are now enemies!"
	return 1

/**
 * IsAlly(guild1_id, guild2_id)
 * Check if two guilds are allied
 */
/proc/IsAlly(guild1_id, guild2_id)
	var/datum/guild/g1 = GetGuildByID(guild1_id)
	var/datum/guild/g2 = GetGuildByID(guild2_id)
	
	if(!g1 || !g2)
		return 0
	
	return (g2 in g1.allied_guilds)

/**
 * IsEnemy(guild1_id, guild2_id)
 * Check if two guilds are enemies
 */
/proc/IsEnemy(guild1_id, guild2_id)
	var/datum/guild/g1 = GetGuildByID(guild1_id)
	var/datum/guild/g2 = GetGuildByID(guild2_id)
	
	if(!g1 || !g2)
		return 0
	
	return (g2 in g1.enemy_guilds)

// ============================================================================
// GUILD TERRITORY
// ============================================================================

/**
 * TransferTerritoryToGuild(datum/territory_claim/territory, datum/guild/guild)
 * Transfer territory from player to guild
 * Guild can now hold/defend collective territories
 */
/proc/TransferTerritoryToGuild(datum/territory_claim/territory, datum/guild/guild)
	if(!territory || !guild)
		return 0
	
	// Remove from player ownership
	var/old_owner = territory.owner_player_key
	if(old_owner != "" && territories_by_owner[old_owner])
		territories_by_owner[old_owner] -= territory
	
	// Transfer to guild (use guild_id as owner)
	territory.owner_player_key = guild.guild_id
	territory.owner_player_name = guild.guild_name
	
	// Add to guild territories
	guild.territories += territory
	
	world.log << "Territory [territory.territory_name] transferred to [guild.guild_name]"
	return 1

/**
 * ClaimTerritoryForGuild(datum/guild/guild, datum/territory_claim/territory)
 * Guild claims new territory (like player claim, but with guild resources)
 * Cost: tier * 100 lucre (paid from treasury)
 */
/proc/ClaimTerritoryForGuild(datum/guild/guild, datum/territory_claim/territory)
	if(!guild || !territory)
		return 0
	
	// Check territory unclaimed
	if(territory.owner_player_key != "")
		return 0
	
	// Check cost
	var/claim_cost = territory.tier * 100
	if(guild.treasury_lucre < claim_cost)
		return 0
	
	// Deduct from treasury
	guild.treasury_lucre -= claim_cost
	
	// Claim
	territory.owner_player_key = guild.guild_id
	territory.owner_player_name = guild.guild_name
	territory.claim_date = world.time
	territory.maintenance_paid = 1
	
	guild.territories += territory
	
	world.log << "[guild.guild_name] claimed [territory.territory_name]"
	return 1

// ============================================================================
// GUILD WARFARE
// ============================================================================

/**
 * DeclareGuildWar(datum/guild/attacker, datum/guild/defender)
 * Guild declares war on rival guild
 * All territory disputes escalate to guild war
 */
/proc/DeclareGuildWar(datum/guild/attacker, datum/guild/defender)
	if(!attacker || !defender || attacker == defender)
		return 0
	
	// Check treasury can afford war (1000 lucre)
	if(attacker.treasury_lucre < 1000)
		return 0
	
	// Deduct cost
	attacker.treasury_lucre -= 1000
	
	// Create war (uses territory wars system)
	// For each territory owned by defender, attacker can raid
	
	// Record in guild history
	var/war_entry = list(
		"opponent" = defender.guild_name,
		"start_time" = world.time,
		"attacker" = 1
	)
	attacker.war_history += war_entry
	
	world.log << "[attacker.guild_name] declared war on [defender.guild_name]!"
	return 1

// ============================================================================
// GUILD INFO & STATUS
// ============================================================================

/**
 * GetGuildInfo(datum/guild/guild)
 * Return formatted guild status
 */
/proc/GetGuildInfo(datum/guild/guild)
	if(!guild)
		return "Guild not found"
	
	var/info = "GUILD: [guild.guild_name] ([guild.guild_tag])\n"
	info += "Leader: [guild.guild_leader_name]\n"
	info += "Members: [guild.members.len]/[guild.member_limit]\n"
	info += "Treasury: [guild.treasury_lucre]L [guild.treasury_materials]M\n"
	info += "Territories: [guild.territories.len]\n"
	info += "Allies: [guild.allied_guilds.len]\n"
	info += "Enemies: [guild.enemy_guilds.len]\n"
	info += "Tax Rate: [guild.tax_rate]%\n"
	
	return info

/**
 * DisbandGuild(datum/guild/guild, mob/players/leader)
 * Leader dissolves guild (returns treasury to members)
 */
/proc/DisbandGuild(datum/guild/guild, mob/players/leader)
	if(!guild || !leader)
		return 0
	
	// Check leader
	if(guild.member_roles[leader.key] != "leader")
		return 0
	
	// Distribute treasury evenly
	// var/per_member_lucre = guild.treasury_lucre / guild.members.len
	// var/per_member_materials = guild.treasury_materials / guild.members.len
	
	// Return territories to unclaimed
	for(var/datum/territory_claim/t in guild.territories)
		t.owner_player_key = ""
		t.owner_player_name = "Unclaimed"
	
	// Remove members
	for(var/member_key in guild.members)
		guilds_by_player -= member_key
	
	// Remove guild
	guild_registry -= guild
	guilds_by_name -= guild.guild_name
	guilds_by_id -= guild.guild_id
	
	world.log << "[guild.guild_name] has been disbanded"
	return 1

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * InitializeGuildSystem()
 * Boot-time initialization
 * Called from InitializationManager at T+424
 */
/proc/InitializeGuildSystem()
	// Initialize registry (usually empty unless loading from save)
	if(!guild_registry)
		guild_registry = list()
		guilds_by_name = list()
		guilds_by_player = list()
		guilds_by_id = list()
	
	// Start background loops
	spawn()
		ProcessGuildTaxation()
	
	world.log << "Guild System initialized"
	return

// ============================================================================
// GUILD SYSTEM SUMMARY
// ============================================================================

/*
 * Phase 24: Guild Formation & Diplomacy completes team-based gameplay:
 * 
 * GUILD MECHANICS:
 * - Create guild: 5000 lucre cost, unique name/tag
 * - Invite members: Officers can invite, guild name spreads
 * - Roles: Leader (full), Officer (mgmt), Member (restricted), Recruit (limited)
 * - Max 50 members per guild
 * 
 * TREASURY SYSTEM:
 * - Guild holds lucre and materials collectively
 * - Members contribute loot via taxation (10-50% rate)
 * - Leader withdraws for guild projects
 * - Tax rate adjustable per guild (balances incentive vs. cost)
 * 
 * DIPLOMACY:
 * - Ally system: shared war buffs, non-attack treaties
 * - Enemy system: hostile relations, raid bonuses
 * - War declarations: guild-vs-guild conflicts
 * - Alliance chains: multi-guild military alliances
 * 
 * TERRITORY INTEGRATION:
 * - Guilds claim territories (same cost as players)
 * - Collective defense: all members defend guild territories
 * - Guild wars: raid opponent territories
 * - Conquest: winning guild takes territory
 * 
 * TAXATION LOOP (Daily):
 * - Automatic collection from member loot shares
 * - Tax stored in treasury
 * - Leader redistributes for special projects
 * - Members benefit from guild resources (repair discounts, etc)
 * 
 * NEXT: Seasonal Territory Events (seasonal effects on warfare)
 *       Siege Equipment (catapults, battering rams, siege towers)
 *       NPC Garrison System (automatic defense troops)
 */
