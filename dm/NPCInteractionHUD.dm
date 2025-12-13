// ============================================================================
// NPC INTERACTION HUD SYSTEM
// ============================================================================
/*
 * NPCInteractionHUD.dm - Unified NPC interaction interface
 * 
 * Integrates with existing client.screen infrastructure to provide
 * modern screen-based NPC dialogue, replacing old input() dialog system
 * 
 * Uses /obj/screen/ objects added via client.add_ui() and client.remove_ui()
 * Hooks into ClientExtensions.dm screen management
 * 
 * Pattern used by all modernized NPCs (after Phase A.2 conversion):
 * 
 * NPC.GetInteractionOptions() returns list of /datum/npc_interaction_option
 * NPC.Interact_[action](mob/players/M, datum/NPC_Interaction/session) handles interaction
 * 
 * Example:
 *   var/datum/NPC_Interaction/menu = new(npc, player)
 *   menu.Show()
 */

// ============================================================================
// NPC INTERACTION SESSION MANAGEMENT
// ============================================================================

/datum/NPC_Interaction
	// Represents an active NPC interaction session
	// Manages dialogue options and coordinates with screen objects
	// Created per-interaction; closed when finished
	// 12-11-25 Enhancement: Supports conditional option visibility based on:
	// - Time of day (shop hours, NPC awake state)
	// - Player reputation with NPC
	// - Knowledge prerequisites (learned recipes/topics)
	// - Season gates
	
	var
		mob/npc = null
		mob/players/player = null
		list/options = list()
		list/visible_options = list()
		current_response = ""
		is_open = FALSE
		
		npc_time_of_day = ""
		npc_shop_open = FALSE
		npc_awake = TRUE
		player_reputation = 0
		
		obj/screen/npc_interaction_main/main = null
		list/option_screens = list()
	New(mob/npc_ref, mob/players/player_ref)
		npc = npc_ref
		player = player_ref
		is_open = TRUE
		
		// Get options from NPC
		if(istype(npc))
			options = call(npc, "GetInteractionOptions")()
		
		if(!options || !options.len)
			options = list(
				new /datum/npc_interaction_option("Leave", "leave", TRUE)
			)
		
		// 12-11-25: Detect NPC state for dynamic dialogue
		CacheNPCState()
		
		// 12-11-25: Filter options based on gates (time, reputation, prerequisites)
		FilterOptionsForGates()
	
	/**
	 * CacheNPCState() - Detect current NPC state for option filtering
	 * Caches: time of day, shop open status, awake status, player reputation
	 * Used by FilterOptionsForGates() to determine visible options
	 */
	proc/CacheNPCState()
		if(!npc) return
		
		// Detect time of day
		var/current_hour = GetCurrentGameHour()
		if(current_hour >= 4 && current_hour < 8)
			npc_time_of_day = "early_morning"
		else if(current_hour >= 8 && current_hour < 12)
			npc_time_of_day = "morning"
		else if(current_hour >= 12 && current_hour < 17)
			npc_time_of_day = "afternoon"
		else if(current_hour >= 17 && current_hour < 21)
			npc_time_of_day = "evening"
		else
			npc_time_of_day = "night"
		
		// Check if NPC shop is open (requires NPCRoutineSystem.dm)
		var/npc_name = npc.name
		npc_shop_open = IsNPCShopOpen(npc_name)
		
		// Check if NPC is awake (not sleeping)
		npc_awake = IsNPCAwake(npc_name)
		
		// Get player reputation with NPC
		if(player)
			player_reputation = GetPlayerNPCReputation(player, npc_name)
		
	/**
	 * FilterOptionsForGates() - Apply conditional visibility filters to options
	 * 12-11-25: Gates applied:
	 *   - Time-of-day gates (only visible during certain hours)
	 *   - Shop-hours gates (only when shop open)
	 *   - Reputation gates (minimum reputation required)
	 *   - Knowledge prerequisite gates (must have learned prior recipes)
	 *   - Season gates (only during specific seasons)
	 */
	proc/FilterOptionsForGates()
		visible_options = list()
		
		if(!options || !length(options))
			return
		
		// "Leave" option is always visible
		visible_options += new /datum/npc_interaction_option("Leave", "leave", TRUE)
		
		// Filter all other options
		for(var/datum/npc_interaction_option/opt in options)
			if(opt.handler == "leave")
				continue  // Already added
			
			// Use helper proc to check gates
			if(IsOptionVisible_Helper(opt, npc_time_of_day, npc_shop_open, npc_awake, player_reputation, player))
				visible_options += opt

	/**
	 * Show() - Display the interaction HUD to the player
	 * Creates and displays screen objects via client.add_ui()
	 */
	proc/Show()
		if(!player || !player.client || !npc)
			return
		
		// Create and display main HUD screen object
		main = new /obj/screen/npc_interaction_main(npc.name, options.len)
		player.client.add_ui(main)
		
		// Store reference so screen object can call back to session
		main.session = src
		
		// Create and display option buttons
		UpdateHUD()

	/**
	 * UpdateHUD() - Update the HUD display with current options and response
	 * Refreshes option buttons and response text on screen
	 * Uses visible_options (filtered by gates) instead of all options (12-11-25)
	 */
	proc/UpdateHUD()
		if(!player || !player.client || !is_open)
			return
		
		// Update main display with response
		if(main)
			main.UpdateResponse(current_response)
		
		// Recreate option buttons (remove old ones, add new ones)
		for(var/obj/screen/npc_interaction_option/btn in option_screens)
			player.client.remove_ui(btn)
		option_screens = list()
		
		// Create option buttons from visible_options (filtered, 12-11-25)
		for(var/i = 1 to visible_options.len)
			var/datum/npc_interaction_option/opt = visible_options[i]
			var/obj/screen/npc_interaction_option/btn = new(opt.label, i)
			btn.session = src
			btn.option_num = i
			player.client.add_ui(btn)
			option_screens += btn

	/**
	 * HandleOption() - Player selected an option number
	 * Called from screen object /obj/screen/npc_interaction_option Click()
	 * Uses visible_options (filtered by gates) instead of raw options (12-11-25)
	 */
	proc/HandleOption(option_num)
		if(option_num < 1 || option_num > visible_options.len)
			return
		
		var/datum/npc_interaction_option/opt = visible_options[option_num]
		
		// Call NPC's interaction handler proc
		// Expected format: Interact_[action](mob/players/M, datum/NPC_Interaction/session)
		if(opt.handler && npc)
			var/handler_name = "Interact_[opt.handler]"
			if(istype(npc))
				call(npc, handler_name)(player, src)
		
		// Check if this option closes the HUD
		if(opt.closes_hud)
			Close()
		else if(current_response)
			// Update HUD with new response
			UpdateHUD()
		else
			// No response set, close HUD
			Close()

	/**
	 * SetResponse() - Set the NPC's response text (shown in HUD)
	 * Called by Interact_* procs on the NPC
	 */
	proc/SetResponse(text)
		current_response = text
		UpdateHUD()

	/**
	 * Close() - Close the interaction HUD and remove all screen objects
	 */
	proc/Close()
		if(!player || !player.client) return
		
		is_open = FALSE
		current_response = ""
		
		// Remove main HUD screen object
		if(main)
			player.client.remove_ui(main)
			main = null
		
		// Remove all option screen objects
		for(var/obj/screen/npc_interaction_option/btn in option_screens)
			player.client.remove_ui(btn)
		option_screens = list()


// ============================================================================
// NPC INTERACTION OPTION DATUM
// ============================================================================

/datum/npc_interaction_option
	// Represents a single dialogue choice/interaction option
	// (e.g., "Ask meaning", "Learn recipe", "Trade")
	// 12-11-25: Enhanced with conditional visibility gates
	
	var
		label = ""
		handler = ""
		closes_hud = FALSE
		gates = list()

	New(label_text, handler_name, closes = FALSE)
		label = label_text
		handler = handler_name
		closes_hud = closes
		gates = list()
	
	/**
	 * AddGate() - Add a conditional visibility requirement
	 * 12-11-25: Chain-able method for building options with gates
	 * 
	 * Usage:
	 *   var/opt = new /datum/npc_interaction_option("Learn Fishing", "learn_fish")
	 *   opt.AddGate("season", "Spring")
	 *   opt.AddGate("npc_awake", TRUE)
	 */
	proc/AddGate(gate_type, gate_data)
		gates[gate_type] = gate_data
		return src  // Chain-able


// ============================================================================
// NPC INTERACTION SCREEN OBJECTS - HUD UI ELEMENTS
// ============================================================================
// These integrate with existing client.screen infrastructure
// Added via client.add_ui() / removed via client.remove_ui()
// See ClientExtensions.dm for add_ui() and remove_ui() procs

/obj/screen/npc_interaction_main
	/**
	 * Main NPC interaction HUD - Shows NPC name, response text, options
	 * Screen object added to client.screen via client.add_ui()
	 * Uses existing HUD infrastructure
	 */
	screen_loc = "1,1 to 20,20"
	layer = 20
	plane = 2
	
	var
		npc_name = ""
		option_count = 0
		response_text = ""
		datum/NPC_Interaction/session = null
	
	New(name, num_options)
		.=..()
		npc_name = name
		option_count = num_options
	
	proc/UpdateResponse(text)
		response_text = text


/obj/screen/npc_interaction_option
	/**
	 * Individual option button in NPC interaction HUD
	 * Player clicks button or uses /npc_respond macro to select
	 * Screen object added to client.screen via client.add_ui()
	 */
	layer = 21
	plane = 2
	
	var
		option_label = ""
		option_num = 0
		datum/NPC_Interaction/session = null
	
	New(label, num)
		.=..()
		option_label = label
		option_num = num
	
	Click()
		if(session)
			session.HandleOption(option_num)


// ============================================================================
// OPTION VISIBILITY HELPER - External proc for checking gate conditions
// ============================================================================

/**
 * IsOptionVisible_Helper() - Check if a dialogue option should be visible
 * Evaluates all conditional gates and returns TRUE if option should be displayed
 * Called by FilterOptionsForGates() in NPC_Interaction datum
 */
/proc/IsOptionVisible_Helper(datum/npc_interaction_option/opt, \
	npc_time_of_day = "", npc_shop_open = 0, npc_awake = 1, \
	player_reputation = 0, mob/players/player = null)
	
	if(!opt) 
		return 0
	
	// No gates on this option - always visible
	if(!opt.gates || !length(opt.gates))
		return 1
	
	// Check each gate requirement
	for(var/gate_type in opt.gates)
		var/gate_data = opt.gates[gate_type]
		
		switch(gate_type)
			// Time-of-day gate: "early_morning", "morning", "afternoon", "evening", "night"
			if("time_of_day")
				if(npc_time_of_day != gate_data)
					return 0
			
			// Shop-hours gate: TRUE = must be open, FALSE = must be closed
			if("shop_hours")
				if(gate_data && !npc_shop_open)
					return 0
				if(!gate_data && npc_shop_open)
					return 0
			
			// Reputation gate: minimum required reputation
			if("min_reputation")
				if(player_reputation < gate_data)
					return 0
			
			// Knowledge prerequisite gate: list of node IDs that must be learned
			if("requires_knowledge")
				if(player && player.character && player.character.recipe_state)
					// gate_data is a list of node IDs
					for(var/node_id in gate_data)
						if(!player.character.recipe_state.IsTopicLearned(node_id))
							return 0
			
			// Season gate: "Spring", "Summer", "Autumn", "Winter"
			if("season")
				var/current_season = GetCurrentSeason()
				if(current_season != gate_data)
					return 0
			
			// Awake gate: TRUE = must be awake, FALSE = must be sleeping
			if("npc_awake")
				if(gate_data && !npc_awake)
					return 0
				if(!gate_data && npc_awake)
					return 0
	
	return 1

// ============================================================================
// GENERIC INTERACTION HANDLERS
// ============================================================================

/**
 * Generic "leave" handler (common to all NPCs)
 * Closes the interaction HUD
 */
/mob/proc/Interact_leave(mob/players/M, datum/NPC_Interaction/session)
	if(session)
		session.Close()

