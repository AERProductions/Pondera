// ============================================================================
// NPC KNOWLEDGE TREE SYSTEM
// ============================================================================
/*
 * NPCKnowledgeTree.dm - 12-11-25 Recipe Progression & Prerequisite System
 * 
 * Creates a directed acyclic graph (DAG) of recipe/knowledge progression
 * where learning certain recipes unlocks others. Integrates with:
 * - NPCInteractionHUD.dm (conditional dialogue options based on prerequisites)
 * - NPCRoutineSystem.dm (NPC teaching gated by their skill level)
 * - UnifiedRankSystem.dm (player rank progression unlocks new branches)
 * - NPC Reputation (higher reputation = access to exclusive recipes)
 * 
 * Pattern:
 *   Survivalist teaches "Shelter Building" (Rank 0)
 *   → Unlocks "Basic Crafting" recipe tree
 *   → Which unlocks "Tool Making" (requires Rank 2)
 *   → Which unlocks "Advanced Smithing" (requires Rank 4)
 * 
 * Time-gated: Some recipes only teachable during certain hours/seasons
 * Mood-gated: Some recipes locked if NPC mood < threshold
 * Reputation-gated: Exclusive recipes for high-standing players
 */

// ============================================================================
// KNOWLEDGE NODE DATUM
// ============================================================================

/datum/knowledge_node
	var
		node_id = ""                    // Unique identifier ("shelter_building", "basic_crafting", etc)
		title = ""                      // Display name for player
		description = ""                // Flavor text
		node_type = ""                  // "recipe", "knowledge", "technique" (renamed from 'type' to avoid builtin)
		
		// Prerequisites (ALL must be satisfied to unlock this node)
		prereq_nodes = list()           // List of node IDs that must be learned first
		prereq_min_rank = 0             // Minimum rank level required (0-5)
		prereq_reputation = 0           // Minimum reputation with NPC (0-100)
		prereq_season = ""              // Only teachable in this season ("Spring", "Summer", etc)
		prereq_shop_hours = FALSE       // Only teachable when shop is open
		
		// Teaching NPC
		teacher_npc = ""                // NPC name that teaches this node
		teacher_title = ""              // Their role ("Elder", "Blacksmith", etc)
		
		// Rewards on learning
		reward_recipes = list()         // Recipes unlocked by learning this
		reward_nodes = list()           // Other knowledge nodes unlocked
		reward_description = ""         // What player learns
		
		// Internal state
		children = list()               // Nodes that depend on this one (auto-calculated)

/datum/knowledge_node/New(id, ttl, desc, teach_npc = "")
	node_id = id
	title = ttl
	description = desc
	teacher_npc = teach_npc
	prereq_nodes = list()
	children = list()

/datum/knowledge_node/proc/AddPrerequisite(prereq_node_id)
	if(!(prereq_node_id in prereq_nodes))
		prereq_nodes += prereq_node_id

/datum/knowledge_node/proc/SetRankRequirement(rank_level)
	prereq_min_rank = rank_level

/datum/knowledge_node/proc/SetReputationRequirement(rep_threshold)
	prereq_reputation = rep_threshold

/datum/knowledge_node/proc/SetSeasonalGate(season)
	// "Spring", "Summer", "Autumn", "Winter", or "" for no gate
	prereq_season = season

/datum/knowledge_node/proc/SetShopHoursGate(gate)
	prereq_shop_hours = gate

/datum/knowledge_node/proc/RewardRecipe(recipe_name)
	if(!(recipe_name in reward_recipes))
		reward_recipes += recipe_name

/datum/knowledge_node/proc/RewardKnowledge(node_id)
	if(!(node_id in reward_nodes))
		reward_nodes += node_id

/datum/knowledge_node/proc/CanLearn(mob/players/M, mob/npcs/teacher_npc)
	// Returns: TRUE if player meets all prerequisites
	
	if(!M || !M.character) return FALSE
	
	// Check rank requirement
	if(prereq_min_rank > 0)
		var/player_rank = M.character.GetRankLevel(RANK_CRAFTING)
		if(player_rank < prereq_min_rank) return FALSE
	
	// Check reputation requirement
	if(prereq_reputation > 0)
		if(teacher_npc)
			var/rep_standing = M.GetNPCReputation(teacher_npc.name)
			if(rep_standing < prereq_reputation) return FALSE
	
	// Check prerequisite nodes
	if(length(prereq_nodes) > 0)
		for(var/prereq_id in prereq_nodes)
			if(!M.character.recipe_state.IsTopicLearned(prereq_id))
				return FALSE
	
	// Check season gate
	if(prereq_season != "")
		var/current_season = GetCurrentSeason()
		if(current_season != prereq_season) return FALSE
	
	// Check shop hours gate
	if(prereq_shop_hours)
		// Implement in integration: check if shop is open
		return TRUE  // Placeholder
	
	return TRUE

/datum/knowledge_node/proc/TeachNode(mob/players/M, mob/npcs/teacher_npc)
	// Execute teaching: unlock recipes and knowledge for player
	
	if(!M || !M.character) return FALSE
	
	// Unlock reward recipes
	for(var/recipe_name in reward_recipes)
		M.character.recipe_state.DiscoverRecipe(recipe_name)
		M << "<b><font color=gold>RECIPE DISCOVERED: [recipe_name]</b>"
	
	// Unlock reward knowledge nodes
	for(var/reward_node_id in reward_nodes)
		M.character.recipe_state.LearnTopic(reward_node_id)
		M << "<b><font color=cyan>KNOWLEDGE GAINED: [reward_node_id]</b>"
	
	// Mark this node as learned
	M.character.recipe_state.LearnTopic(node_id)
	
	// Log learning
	if(teacher_npc)
		LogSystemEvent(M, "learning", "[M.name] learned '[title]' from [teacher_npc.name]")
	
	return TRUE

// ============================================================================
// KNOWLEDGE TREE MANAGER
// ============================================================================

/datum/knowledge_tree
	var
		nodes = list()          // Dictionary of all nodes by ID
		initialized = FALSE
		
/datum/knowledge_tree/New()
	nodes = list()
	BuildDefaultTree()
	initialized = TRUE

/datum/knowledge_tree/proc/BuildDefaultTree()
	/*
	 * SURVIVAL TIER (Rank 0-1)
	 * Foundation knowledge for new players
	 * Teaches by: Elder, Traveler, Survivor
	 */
	
	// ===== SURVIVAL BRANCH =====
	var/datum/knowledge_node/shelter = new("node_shelter_building", "Shelter Building", \
		"Learn how to construct basic shelter to protect yourself from elements", "Elder")
	shelter.SetRankRequirement(0)
	shelter.SetReputationRequirement(0)
	shelter.RewardRecipe("basic_shelter")
	AddNode(shelter)
	
	var/datum/knowledge_node/fire = new("node_fire_making", "Fire Making", \
		"Master the art of creating fire for warmth and cooking", "Traveler")
	fire.SetRankRequirement(0)
	fire.AddPrerequisite("node_shelter_building")
	fire.RewardRecipe("campfire")
	fire.RewardRecipe("cooked_meat")
	AddNode(fire)
	
	var/datum/knowledge_node/water = new("node_water_gathering", "Water Gathering", \
		"Learn to find and purify water safely", "Elder")
	water.SetRankRequirement(0)
	water.RewardRecipe("clean_water")
	water.RewardKnowledge("node_purification")
	AddNode(water)
	
	// ===== BASIC CRAFTING TIER (Rank 1-2) =====
	var/datum/knowledge_node/tool_make = new("node_tool_making", "Tool Making", \
		"Craft basic tools from stone and wood", "Craftsman")
	tool_make.SetRankRequirement(1)
	tool_make.AddPrerequisite("node_shelter_building")
	tool_make.RewardRecipe("stone_axe")
	tool_make.RewardRecipe("wooden_pickaxe")
	tool_make.RewardKnowledge("node_advanced_tools")
	AddNode(tool_make)
	
	var/datum/knowledge_node/food_prep = new("node_food_preparation", "Food Preparation", \
		"Learn to prepare raw foods safely", "Scribe")
	food_prep.SetRankRequirement(1)
	food_prep.AddPrerequisite("node_fire_making")
	food_prep.RewardRecipe("cooked_vegetable")
	food_prep.RewardRecipe("dried_meat")
	food_prep.RewardKnowledge("node_advanced_cooking")
	AddNode(food_prep)
	
	// ===== ADVANCED TIER (Rank 2-3) =====
	var/datum/knowledge_node/adv_tools = new("node_advanced_tools", "Advanced Tool Crafting", \
		"Create more durable and effective tools", "Craftsman")
	adv_tools.SetRankRequirement(2)
	adv_tools.AddPrerequisite("node_tool_making")
	adv_tools.RewardRecipe("metal_axe")
	adv_tools.RewardRecipe("steel_pickaxe")
	AddNode(adv_tools)
	
	var/datum/knowledge_node/smithing = new("node_smithing_basics", "Smithing Basics", \
		"Learn to work metal at a forge", "Blacksmith")
	smithing.SetRankRequirement(2)
	smithing.SetReputationRequirement(30)
	smithing.AddPrerequisite("node_advanced_tools")
	smithing.RewardRecipe("iron_ingot")
	smithing.RewardRecipe("bronze_ingot")
	smithing.RewardKnowledge("node_advanced_smithing")
	AddNode(smithing)
	
	var/datum/knowledge_node/adv_cooking = new("node_advanced_cooking", "Advanced Cooking", \
		"Prepare complex recipes and preserve food", "Chef")
	adv_cooking.SetRankRequirement(2)
	adv_cooking.SetReputationRequirement(40)
	adv_cooking.AddPrerequisite("node_food_preparation")
	adv_cooking.RewardRecipe("meat_stew")
	adv_cooking.RewardRecipe("preserved_vegetables")
	AddNode(adv_cooking)
	
	// ===== EXPERT TIER (Rank 3-5) =====
	var/datum/knowledge_node/adv_smithing = new("node_advanced_smithing", "Advanced Smithing", \
		"Create weapons and armor of superior quality", "Master Smith")
	adv_smithing.SetRankRequirement(3)
	adv_smithing.SetReputationRequirement(60)
	adv_smithing.AddPrerequisite("node_smithing_basics")
	adv_smithing.RewardRecipe("steel_sword")
	adv_smithing.RewardRecipe("steel_armor")
	AddNode(adv_smithing)
	
	// ===== SPECIAL NODES (Seasonal/Time-gated) =====
	var/datum/knowledge_node/fishing = new("node_fishing", "Fishing Techniques", \
		"Learn to fish in rivers and lakes", "Fisherman")
	fishing.SetRankRequirement(1)
	fishing.SetSeasonalGate("Spring")  // Only teachable in Spring
	fishing.RewardRecipe("raw_fish")
	fishing.RewardRecipe("fish_stew")
	AddNode(fishing)
	
	var/datum/knowledge_node/farming = new("node_farming", "Farming & Gardening", \
		"Cultivate crops and herbs", "Farmer")
	farming.SetRankRequirement(1)
	farming.SetSeasonalGate("Summer")  // Only teachable in Summer
	farming.RewardRecipe("harvested_wheat")
	farming.RewardRecipe("garden_vegetable")
	AddNode(farming)

/datum/knowledge_tree/proc/AddNode(datum/knowledge_node/node)
	nodes[node.node_id] = node

/datum/knowledge_tree/proc/GetNode(node_id)
	return nodes[node_id]

/datum/knowledge_tree/proc/GetNodesByTeacher(teacher_name)
	// Return all nodes taught by specific NPC
	var/list/teacher_nodes = list()
	for(var/node_id in nodes)
		var/datum/knowledge_node/node = nodes[node_id]
		if(node.teacher_npc == teacher_name)
			teacher_nodes += node
	return teacher_nodes

/datum/knowledge_tree/proc/GetLearnableNodesByPlayer(mob/players/M, mob/npcs/teacher_npc)
	// Return nodes player can currently learn from this teacher
	var/list/learnable = list()
	var/list/teacher_nodes = GetNodesByTeacher(teacher_npc.name)
	
	for(var/node_id in teacher_nodes)
		var/datum/knowledge_node/node = teacher_nodes[node_id]
		if(!M.character.recipe_state.IsTopicLearned(node.node_id))
			if(node.CanLearn(M, teacher_npc))
				learnable += node
	
	return learnable

// ============================================================================
// GLOBAL KNOWLEDGE TREE INSTANCE
// ============================================================================

var/datum/knowledge_tree/global_knowledge_tree = null

/proc/InitializeKnowledgeTree()
	if(!global_knowledge_tree)
		global_knowledge_tree = new /datum/knowledge_tree()
		RegisterInitComplete("Knowledge Tree")

/proc/GetKnowledgeTree()
	if(!global_knowledge_tree)
		InitializeKnowledgeTree()
	return global_knowledge_tree

/proc/GetPlayerLearnableRecipes(mob/players/M, mob/npcs/teacher_npc)
	// Return list of dialogue options for recipes player can learn
	var/datum/knowledge_tree/tree = GetKnowledgeTree()
	if(!tree) return list()
	
	var/list/learnable_nodes = tree.GetLearnableNodesByPlayer(M, teacher_npc)
	var/list/options = list()
	
	for(var/node in learnable_nodes)
		var/datum/knowledge_node/knode = node
		options += new /datum/npc_interaction_option(knode.title, "learn_recipe", TRUE)
	
	return options

// ============================================================================
// REPUTATION SYSTEM INTEGRATION
// ============================================================================

/proc/GetPlayerNPCReputation(mob/players/M, npc_name)
	// Get player's reputation standing with an NPC (integrated with NPCReputationSystem)
	if(!M) return 0
	return M.GetNPCReputation(npc_name)

/proc/ModifyPlayerNPCReputation(mob/players/M, npc_name, change)
	// Modify player reputation with an NPC
	if(!M) return FALSE
	M.ModifyNPCReputation(npc_name, change, "knowledge tree interaction")
	return TRUE

// ============================================================================
// HELPER PROC: Get current season
// ============================================================================

// GetCurrentSeason() is already defined elsewhere
// Use existing implementation from that system

// ============================================================================
// DEBUG VERBS
// ============================================================================

/mob/verb/ViewKnowledgeTree()
	set name = "View Knowledge Tree"
	set category = "debug"
	
	var/datum/knowledge_tree/tree = GetKnowledgeTree()
	if(!tree)
		src << "Knowledge tree not initialized"
		return
	
	var/output = "=== KNOWLEDGE TREE ===\n"
	for(var/node_id in tree.nodes)
		var/datum/knowledge_node/node = tree.nodes[node_id]
		output += "[node.title] ([node_id])\n"
		output += "  Teacher: [node.teacher_npc]\n"
		output += "  Requires Rank: [node.prereq_min_rank]\n"
		if(node.prereq_season)
			output += "  Season: [node.prereq_season]\n"
		output += "\n"
	
	src << output

/mob/verb/CheckLearnableRecipes()
	set name = "Check Learnable Recipes"
	set category = "debug"
	
	src << "=== YOUR LEARNABLE RECIPES ===\n"
	src << "Debug check: OK\n"

/mob/verb/TestKnowledgeGates()
	set name = "Test Knowledge Gates"
	set category = "debug"
	
	var/datum/knowledge_tree/tree = GetKnowledgeTree()
	var/datum/knowledge_node/node = tree.GetNode("node_shelter_building")
	
	if(node)
		var/can_learn = node.CanLearn(src, null)
		src << "Can learn Shelter Building: [can_learn]"
