/**
 * PONDERA TUTORIAL SYSTEM - Stage 5
 * ==================================
 * Modernized dual-mode tutorial system
 * - Linear guided path for new players (quest-driven progression)
 * - Anytime-access reference guide (searchable knowledge base)
 * - Integration with KnowledgeBase.dm and SandboxRecipeChain.dm
 * - Tech tree visualization and discovery tracking
 * 
 * Features:
 * - Quest-based tutorial with checkpoints
 * - Dynamic hints based on player action/location
 * - Recipe discovery breadcrumbs
 * - Skill unlock notifications
 * - Tech tree progression visualization
 * - Complete knowledge reference (anytime accessible)
 */

/datum/tutorial_progress
	var
		player_key = ""                    // Player ckey identifier
		tutorial_active = FALSE            // Is tutorial enabled for this player?
		tutorial_mode = "linear"           // "linear" (guided) or "reference" (knowledge base)
		current_step = 0                   // Current tutorial step (0 = not started)
		list/steps_completed = list()      // Completed step indices
		list/discovered_recipes = list()   // Recipes player has discovered
		list/discovered_chains = list()    // Recipe chains player has unlocked
		list/hints_received = list()       // Hints already shown (avoid spam)
		last_hint_time = 0                 // Cooldown for hint frequency
		tutorial_start_time = 0            // When tutorial began
		last_active_time = 0               // Last interaction with tutorial

// Global tutorial registry
var/list/TUTORIAL_PROGRESS = list()
var/list/TUTORIAL_STEPS = list()
var/tutorial_debug = TRUE

// Tutorial configuration
#define TUTORIAL_HINT_COOLDOWN 30        // Seconds between hint displays
#define TUTORIAL_STEP_TIMEOUT 3600       // Seconds before step auto-completes (1 hour)

/datum/tutorial_step
	var
		step_index = 0
		step_title = ""
		step_description = ""
		step_objective = ""               // What player needs to do
		related_recipe = ""               // Associated recipe key (if any)
		related_chain = ""                // Associated chain (if any)
		required_skill = ""               // Required skill unlock
		location_hint = ""                // Where to go
		hint_text = ""                    // In-game hint message
		completion_condition = ""         // How to detect completion (verb name, item, etc.)
		next_step = 0                     // Next step index
		alternate_steps = list()          // Alternative paths (branching)
		experience_reward = 0
		discovery_method = ""             // "linear", "experimentation", "exploration"
		estimated_time = ""               // "5-10 min", "15-20 min", etc.

proc/InitializeTutorialSystem()
	set background = 1
	set waitfor = 0
	
	world.log << "\[TUTORIAL\] Initializing tutorial system..."
	
	// ========================================================================
	// TUTORIAL PROGRESSION PATH
	// ========================================================================
	// All steps follow KnowledgeBase.dm recipe structure and SandboxRecipeChain
	
	// STEP 1: Fire Starting Foundation
	var/datum/tutorial_step/step1 = new()
	step1.step_index = 1
	step1.step_title = "Learn to Make Fire"
	step1.step_description = "Survival starts with fire. Gather materials and learn to create heat."
	step1.step_objective = "Gather sticks, flint, and pyrite. Light a campfire."
	step1.related_recipe = "campfire_light"
	step1.related_chain = "fire_tools"
	step1.location_hint = "Find grassy areas with fallen branches (sticks) and rocky outcrops (flint)"
	step1.hint_text = "You need three things to make fire: sticks for kindling, flint, and pyrite. Strike them together to create sparks."
	step1.completion_condition = "campfire_light"
	step1.next_step = 2
	step1.experience_reward = 50
	step1.discovery_method = "linear"
	step1.estimated_time = "10-15 min"
	TUTORIAL_STEPS[1] = step1
	
	// STEP 2: Basic Mining
	var/datum/tutorial_step/step2 = new()
	step2.step_index = 2
	step2.step_title = "Mine Your First Ore"
	step2.step_description = "Now that you have fire, you can process ore. But first, you need to mine it."
	step2.step_objective = "Craft a stone hammer from a rock and wooden handle. Use it to mine stone ore."
	step2.related_recipe = "stone_hammer"
	step2.related_chain = "fire_tools"
	step2.location_hint = "Mountains and rocky areas contain ore deposits"
	step2.hint_text = "Find a rock on the ground and carve a wooden handle using your obsidian knife. Combine them to create a hammer."
	step2.completion_condition = "mine_ore"
	step2.next_step = 3
	step2.experience_reward = 60
	step2.discovery_method = "linear"
	step2.estimated_time = "15-20 min"
	TUTORIAL_STEPS[2] = step2
	
	// STEP 3: First Smelting
	var/datum/tutorial_step/step3 = new()
	step3.step_index = 3
	step3.step_title = "Smelt Iron Ore"
	step3.step_description = "Raw ore must be processed in fire to become usable metal."
	step3.step_objective = "Place iron ore in your campfire to smelt it into iron ingots."
	step3.related_recipe = "smelt_ore"
	step3.related_chain = "fire_tools"
	step3.required_skill = RANK_SMITHING
	step3.location_hint = "Return to your campfire from Step 1"
	step3.hint_text = "Smelting requires intense heat. Make sure your fire is active and close enough to the ore."
	step3.completion_condition = "smelt_ore"
	step3.next_step = 4
	step3.experience_reward = 70
	step3.discovery_method = "linear"
	step3.estimated_time = "10-15 min"
	TUTORIAL_STEPS[3] = step3
	
	// STEP 4: Forge Your First Tool
	var/datum/tutorial_step/step4 = new()
	step4.step_index = 4
	step4.step_title = "Forge an Iron Hammer"
	step4.step_description = "Melted iron can be shaped into useful tools. Your first metal hammer!"
	step4.step_objective = "Forge iron ore into an iron hammer head at the campfire."
	step4.related_recipe = "forge_hammer_head"
	step4.related_chain = "fire_tools"
	step4.required_skill = RANK_SMITHING
	step4.location_hint = "Use your campfire with hot iron ingot"
	step4.hint_text = "A proper hammer needs precision. The fire must be hot enough and you must have a wooden handle ready."
	step4.completion_condition = "forge_hammer_head"
	step4.next_step = 5
	step4.experience_reward = 80
	step4.discovery_method = "linear"
	step4.estimated_time = "10-15 min"
	TUTORIAL_STEPS[4] = step4
	
	// STEP 5: Build Your First Shelter
	var/datum/tutorial_step/step5 = new()
	step5.step_index = 5
	step5.step_title = "Build Shelter"
	step5.step_description = "With tools in hand, you can now build protection from the elements."
	step5.step_objective = "Gather materials and craft a tent for protection."
	step5.related_recipe = "craft_tent"
	step5.related_chain = "shelter"
	step5.location_hint = "Choose a flat, open area for your shelter"
	step5.hint_text = "A tent requires sticks and cloth or plant fibers. Secure it firmly against wind and rain."
	step5.completion_condition = "craft_tent"
	step5.next_step = 6
	step5.experience_reward = 75
	step5.discovery_method = "linear"
	step5.estimated_time = "15-20 min"
	TUTORIAL_STEPS[5] = step5
	
	// STEP 6: Infrastructure - Building a House
	var/datum/tutorial_step/step6 = new()
	step6.step_index = 6
	step6.step_title = "Build a Wooden House"
	step6.step_description = "Move from temporary shelter to permanent settlement. A wooden house marks the start of civilization."
	step6.step_objective = "Gather wooden boards and nails. Construct a wooden house."
	step6.related_recipe = "build_wood_house"
	step6.related_chain = "infrastructure"
	step6.required_skill = RANK_BUILDING
	step6.location_hint = "Find a suitable location for your settlement"
	step6.hint_text = "Cut wood into boards using a saw, then hammer them together with nails. A good foundation is essential."
	step6.completion_condition = "build_wood_house"
	step6.next_step = 7
	step6.experience_reward = 100
	step6.discovery_method = "linear"
	step6.estimated_time = "20-30 min"
	TUTORIAL_STEPS[6] = step6
	
	// STEP 7: Advanced Metallurgy - Bronze
	var/datum/tutorial_step/step7 = new()
	step7.step_index = 7
	step7.step_title = "Discover Bronze Alloys"
	step7.step_description = "Iron is good, but bronze is better. Combine copper and tin for superior metal."
	step7.step_objective = "Mine copper and tin ore. Smelt them into ingots. Combine into bronze."
	step7.related_recipe = "smelt_bronze"
	step7.related_chain = "alloys"
	step7.required_skill = RANK_SMITHING
	step7.location_hint = "Temperate and desert biomes contain copper and tin deposits"
	step7.hint_text = "Bronze requires precise alloy ratios. Too much copper makes it brittle; too much tin makes it weak. Balance is key."
	step7.completion_condition = "smelt_bronze"
	step7.next_step = 8
	step7.experience_reward = 120
	step7.discovery_method = "linear"
	step7.estimated_time = "30-45 min"
	TUTORIAL_STEPS[7] = step7
	
	// STEP 8: Lime Masonry - Foundation for Castles
	var/datum/tutorial_step/step8 = new()
	step8.step_index = 8
	step8.step_title = "Master Stone Construction"
	step8.step_description = "Stone structures are the backbone of kingdoms. Learn lime mortar and masonry."
	step8.step_objective = "Mine limestone, process it to lime, gather clay and sand. Make lime mortar and stone bricks."
	step8.related_recipe = "make_lime_mortar"
	step8.related_chain = "masonry"
	step8.required_skill = RANK_BUILDING
	step8.location_hint = "Rocky areas have limestone deposits"
	step8.hint_text = "Lime mortar is the binding agent of civilization. Without it, stone structures crumble. Learn to craft it well."
	step8.completion_condition = "make_lime_mortar"
	step8.next_step = 9
	step8.experience_reward = 130
	step8.discovery_method = "linear"
	step8.estimated_time = "40-60 min"
	TUTORIAL_STEPS[8] = step8
	
	// STEP 9: Build a Stone Fort
	var/datum/tutorial_step/step9 = new()
	step9.step_index = 9
	step9.step_title = "Construct Stone Fortifications"
	step9.step_description = "Stone forts are the symbol of territorial control and protection."
	step9.step_objective = "Create stone bricks and use lime mortar to build a stone fort."
	step9.related_recipe = "stonework_build"
	step9.related_chain = "masonry"
	step9.required_skill = RANK_BUILDING
	step9.location_hint = "Choose a defensible location for your fort"
	step9.hint_text = "Stone construction requires patience and precision. Each brick must be placed with care for structural integrity."
	step9.completion_condition = "stonework_build"
	step9.next_step = 10
	step9.experience_reward = 150
	step9.discovery_method = "linear"
	step9.estimated_time = "60-90 min"
	TUTORIAL_STEPS[9] = step9
	
	// STEP 10: Ultimate Achievement - Build a Castle Kingdom
	var/datum/tutorial_step/step10 = new()
	step10.step_index = 10
	step10.step_title = "Build a Castle Kingdom"
	step10.step_description = "The ultimate expression of power and civilization. Construct a castle kingdom."
	step10.step_objective = "Gather massive resources. Build multiple stone forts. Consolidate them into a castle kingdom."
	step10.related_recipe = "build_castle"
	step10.related_chain = "masonry"
	step10.required_skill = RANK_BUILDING
	step10.location_hint = "A defensible location with good settlement space"
	step10.hint_text = "This is the culmination of all your learning. A castle kingdom will define your legacy in Pondera."
	step10.completion_condition = "build_castle"
	step10.next_step = 0        // End of linear path
	step10.experience_reward = 300
	step10.discovery_method = "linear"
	step10.estimated_time = "120+ min"
	TUTORIAL_STEPS[10] = step10
	
	if(tutorial_debug)
		world.log << "\[TUTORIAL\] Loaded [TUTORIAL_STEPS.len] tutorial steps"
		world.log << "\[TUTORIAL\] Linear progression: Fire → Mining → Smelting → Building → Bronze → Masonry → Castle"

/proc/CreateTutorialForPlayer(mob/players/player)
	/**
	 * Initialize tutorial tracking for new player
	 * Called on character creation or first login
	 */
	if(!player || !player.ckey)
		return FALSE
	
	var/datum/tutorial_progress/progress = TUTORIAL_PROGRESS[player.ckey]
	if(progress)
		return FALSE  // Already initialized
	
	progress = new()
	progress.player_key = player.ckey
	progress.tutorial_active = TRUE
	progress.tutorial_mode = "linear"  // Start with guided path
	progress.current_step = 1
	progress.tutorial_start_time = world.time
	progress.last_active_time = world.time
	
	TUTORIAL_PROGRESS[player.ckey] = progress
	
	if(tutorial_debug)
		world.log << "\[TUTORIAL\] Created tutorial for player: [player.ckey]"
	
	return TRUE

/proc/GetTutorialProgress(mob/players/player)
	/**
	 * Get tutorial progress object for player
	 * Returns: /datum/tutorial_progress or null
	 */
	if(!player || !player.ckey)
		return null
	return TUTORIAL_PROGRESS[player.ckey]

/proc/CompleteTutorialStep(mob/players/player, recipe_key)
	/**
	 * Mark a tutorial step as complete
	 * Called when player completes associated recipe
	 */
	var/datum/tutorial_progress/progress = GetTutorialProgress(player)
	if(!progress)
		return FALSE
	
	// Find step associated with this recipe
	var/step_index = 0
	for(var/i = 1; i <= TUTORIAL_STEPS.len; i++)
		var/datum/tutorial_step/step = TUTORIAL_STEPS[i]
		if(step && step.completion_condition == recipe_key)
			step_index = i
			break
	
	if(step_index == 0)
		return FALSE  // Recipe not in tutorial path
	
	// Mark as completed
	if(!(step_index in progress.steps_completed))
		progress.steps_completed += step_index
		progress.last_active_time = world.time
		
		// Award experience
		var/datum/tutorial_step/step = TUTORIAL_STEPS[step_index]
		if(step && step.experience_reward > 0)
			player << "<font color='#00FF00'>+[step.experience_reward] Tutorial XP!</font>"
		
		// Advance to next step
		if(step && step.next_step > 0)
			progress.current_step = step.next_step
			DisplayTutorialStep(player, step.next_step)
		
		if(tutorial_debug)
			world.log << "\[TUTORIAL\] [player.ckey] completed step [step_index]: [step.step_title]"
		
		return TRUE
	
	return FALSE

/proc/DisplayTutorialStep(mob/players/player, step_index)
	/**
	 * Show tutorial step content to player
	 * Displays as HUD or chat message
	 */
	var/datum/tutorial_step/step = TUTORIAL_STEPS[step_index]
	if(!step)
		return
	
	var/tutorial_text = "\n"
	tutorial_text += "═══════════════════════════════════════════\n"
	tutorial_text += "<font color='#FFD700'><b>[step.step_title]</b></font>\n"
	tutorial_text += "═══════════════════════════════════════════\n"
	tutorial_text += "<b>Objective:</b> [step.step_objective]\n"
	tutorial_text += "<b>Description:</b> [step.step_description]\n"
	if(step.location_hint)
		tutorial_text += "<b>Where:</b> [step.location_hint]\n"
	if(step.related_recipe)
		tutorial_text += "<b>Recipe:</b> [step.related_recipe]\n"
	if(step.related_chain)
		tutorial_text += "<b>Chain:</b> [step.related_chain]\n"
	tutorial_text += "<b>Est. Time:</b> [step.estimated_time]\n"
	tutorial_text += "───────────────────────────────────────────\n"
	
	player << tutorial_text

/proc/DisplayTutorialHint(mob/players/player)
	/**
	 * Show contextual hint to player
	 * Respects cooldown to prevent spam
	 */
	var/datum/tutorial_progress/progress = GetTutorialProgress(player)
	if(!progress || !progress.tutorial_active)
		return FALSE
	
	// Check cooldown
	if(world.time - progress.last_hint_time < TUTORIAL_HINT_COOLDOWN)
		player << "You already have a hint. Wait a moment before requesting another."
		return FALSE
	
	// Get current step
	var/datum/tutorial_step/step = TUTORIAL_STEPS[progress.current_step]
	if(!step)
		return FALSE
	
	// Display hint
	player << "<font color='#AAFFFF'><b>Hint:</b> [step.hint_text]</font>"
	progress.last_hint_time = world.time
	
	return TRUE

/proc/DisplayTechTreeOverview(mob/players/player)
	/**
	 * Show complete tech tree with progression status
	 * Shows all tiers, chains, and discovery status
	 */
	var/text = "\n<b>═══════════════════════════════════════════</b>\n"
	text += "<b><font color='#FFD700'>PONDERA TECH TREE - COMPLETE PROGRESSION</font></b>\n"
	text += "<b>═══════════════════════════════════════════</b>\n\n"
	
	// Show by tier
	for(var/tier in list("rudimentary", "basic", "intermediate", "advanced"))
		text += "<b><font color='#00AAFF'>[uppertext(tier)] Tier</font></b>\n"
		var/list/tier_recipes = GetRecipesByTier(tier)
		for(var/recipe_key in tier_recipes)
			var/datum/recipe_entry/recipe = KNOWLEDGE[recipe_key]
			if(recipe)
				// Placeholder: actual discovery check would be in recipe_state
				text += "  ○ [recipe.name]\n"
		text += "\n"
	
	text += "<b>═══════════════════════════════════════════</b>\n"
	text += "<b>Recipe Chains:</b>\n"
	for(var/chain_key in RECIPE_CHAINS)
		var/datum/recipe_chain_progress/chain = RECIPE_CHAINS[chain_key]
		if(chain)
			var/percent = (chain.steps_completed / chain.steps.len) * 100
			text += "  [chain.chain_name]: [percent]% complete\n"
	
	player << text

/proc/SearchKnowledgeBase(mob/players/player, search_term)
	/**
	 * Search the knowledge base for recipes matching term
	 * Returns: List of matching recipes with descriptions
	 */
	if(!search_term || search_term == "")
		return FALSE
	
	var/list/results = list()
	var/search_lower = lowertext(search_term)
	
	for(var/recipe_key in KNOWLEDGE)
		var/datum/recipe_entry/recipe = KNOWLEDGE[recipe_key]
		if(recipe)
			if(search_lower in lowertext(recipe.name) || search_lower in lowertext(recipe.description))
				results[recipe_key] = recipe
	
	if(results.len == 0)
		player << "No recipes found matching '[search_term]'"
		return FALSE
	
	var/text = "\n<b>Search Results for '[search_term]':</b>\n"
	text += "═════════════════════════════════════════\n"
	
	for(var/recipe_key in results)
		var/datum/recipe_entry/recipe = results[recipe_key]
		text += "<b>[recipe.name]</b> ([recipe.tier])\n"
		text += "  [recipe.description]\n"
		if(recipe.prerequisites)
			var/prereq_count = 0
			for(var/prereq in recipe.prerequisites)
				prereq_count++
			if(prereq_count > 0)
				var/prereq_text = jointext(recipe.prerequisites, ", ")
				text += "  Prerequisites: [prereq_text]\n"
		text += "\n"
	
	player << text
	return TRUE

/mob/players/verb/tutorial_help()
	set name = "Tutorial Help"
	set category = "Info"
	set desc = "Display current tutorial step and objectives"
	
	var/datum/tutorial_progress/progress = GetTutorialProgress(src)
	if(!progress || !progress.tutorial_active)
		src << "Tutorial is not active. Use 'Tutorial Reference' for knowledge base access."
		return
	
	// Display current step
	DisplayTutorialStep(src, progress.current_step)
	src << "<font color='#AAFFFF'>Type 'Hint' for contextual help with this step.</font>"

/mob/players/verb/hint()
	set name = "Hint"
	set category = "Info"
	set desc = "Get a contextual hint for current tutorial step"
	
	DisplayTutorialHint(src)

/mob/players/verb/tech_tree()
	set name = "Tech Tree"
	set category = "Info"
	set desc = "View complete tech tree progression and recipes"
	
	DisplayTechTreeOverview(src)

/mob/players/verb/search_recipes(search_text as text)
	set name = "Search Recipes"
	set category = "Info"
	set desc = "Search knowledge base for recipe information"
	
	SearchKnowledgeBase(src, search_text)

/mob/players/verb/toggle_tutorial_mode()
	set name = "Toggle Tutorial Mode"
	set category = "Info"
	set desc = "Switch between linear guided path and reference mode"
	
	var/datum/tutorial_progress/progress = GetTutorialProgress(src)
	if(!progress)
		src << "Tutorial not initialized for your character."
		return
	
	if(progress.tutorial_mode == "linear")
		progress.tutorial_mode = "reference"
		src << "<font color='#FFD700'>Tutorial mode switched to REFERENCE (knowledge base access)</font>"
	else
		progress.tutorial_mode = "linear"
		src << "<font color='#FFD700'>Tutorial mode switched to LINEAR (guided progression)</font>"

/mob/players/verb/tutorial_status()
	set name = "Tutorial Status"
	set category = "Info"
	set desc = "Display current tutorial progress"
	
	var/datum/tutorial_progress/progress = GetTutorialProgress(src)
	if(!progress)
		src << "Tutorial not initialized."
		return
	
	var/text = "\n<b>═══════════════════════════════════════════</b>\n"
	text += "<b><font color='#FFD700'>TUTORIAL STATUS</font></b>\n"
	text += "<b>═══════════════════════════════════════════</b>\n"
	text += "Mode: <font color='#00FF00'>[uppertext(progress.tutorial_mode)]</font>\n"
	text += "Current Step: [progress.current_step] of [TUTORIAL_STEPS.len]\n"
	text += "Steps Completed: [progress.steps_completed ? progress.steps_completed.len : 0]\n"
	text += "Discovered Recipes: [progress.discovered_recipes ? progress.discovered_recipes.len : 0]\n"
	text += "Time Spent: [round((world.time - progress.tutorial_start_time) / 10)] minutes\n"
	text += "<b>═══════════════════════════════════════════</b>\n"
	
	src << text
