/**
 * Modern Searching System
 * 
 * A fun, interactive discovery minigame that rewards curiosity and exploration.
 * Features:
 * - Progressive item revelation (tension/reward)
 * - Smart unique item drops (only if not already owned)
 * - Biome-specific discoveries
 * - Anti-abuse cooldowns and escalating difficulty
 * - Delightful, atmospheric messages
 */

// Search result datum - represents what's found
/datum/search_result
	var
		item_type        // /obj/items/... path
		display_name     // "a shiny stone"
		min_rank = 1
		max_rank = 5
		base_xp = 15
		is_unique = FALSE    // Only drop if player doesn't have one
		rarity = 50          // 1-100, higher = rarer
		biomes = list()      // Biomes this can appear in (empty = all)

/datum/search_result/New(item, display, xp, unique=FALSE, rarity=50, min_r=1, max_r=5, biome_list=null)
	item_type = item
	display_name = display
	base_xp = xp
	is_unique = unique
	src.rarity = rarity
	min_rank = min_r
	max_rank = max_r
	if(biome_list) biomes = biome_list

// Global registry of all discoverable items
var/list/SEARCHABLE_ITEMS = list()

/proc/InitializeSearchables()
	// Tier 1 - Basic discoveries
	SEARCHABLE_ITEMS += new/datum/search_result(/obj/items/Rock, "a smooth stone", 10, FALSE, 80, 1, 1)
	SEARCHABLE_ITEMS += new/datum/search_result(/obj/items/tools/Flint, "a piece of flint", 12, FALSE, 70, 1, 2)
	SEARCHABLE_ITEMS += new/datum/search_result(null, "a handful of interesting pebbles", 8, FALSE, 90, 1, 1)
	
	// Tier 2-3 - Intermediate discoveries
	SEARCHABLE_ITEMS += new/datum/search_result(/obj/items/tools/Pyrite, "some glimmering pyrite", 18, FALSE, 60, 2, 4)
	SEARCHABLE_ITEMS += new/datum/search_result(null, "a curious bone fragment", 15, FALSE, 65, 2, 3)
	SEARCHABLE_ITEMS += new/datum/search_result(null, "dried herbs", 14, FALSE, 70, 1, 3)
	SEARCHABLE_ITEMS += new/datum/search_result(/obj/items/WDHNCH, "a weathered wooden haunch", 16, FALSE, 55, 2, 4)
	
	// Tier 3-4 - Unique finds (only drop if player doesn't have)
	SEARCHABLE_ITEMS += new/datum/search_result(/obj/items/AUS, "an ancient ueik splinter", 22, TRUE, 45, 3, 5)
	SEARCHABLE_ITEMS += new/datum/search_result(null, "a strange crystalline fragment", 20, FALSE, 40, 3, 4)
	
	// Tier 4-5 - Rare discoveries
	SEARCHABLE_ITEMS += new/datum/search_result(/obj/items/tools/Whetstone, "a useful whetstone", 25, TRUE, 35, 4, 5)
	SEARCHABLE_ITEMS += new/datum/search_result(null, "an iridescent scale", 24, FALSE, 30, 4, 5)
	SEARCHABLE_ITEMS += new/datum/search_result(null, "a luminescent toadstool", 26, FALSE, 25, 4, 5)

/mob/players/var/last_search_time = 0
/mob/players/var/consecutive_searches = 0

/proc/GetPlayerInventoryItemCount(mob/players/M, item_path)
	/**
	 * Returns how many of a specific item type the player has
	 */
	if(!M || !item_path) return 0
	var/count = 0
	for(var/obj/items/item in M.contents)
		if(item.type == item_path)
			count += (item.stack_amount || 1)
	return count

/proc/PerformSearch(mob/players/M, obj/Flowers/searchable_obj)
	/**
	 * Main search interaction - the minigame!
	 */
	if(!M || !searchable_obj) return
	
	// Anti-spam check
	if(M.Doing == 1)
		M << "You are already searching!"
		return
	
	// Anti-farm cooldown: 30 seconds between searches
	var/time_since_search = world.time - M.last_search_time
	if(time_since_search < 300)  // 30 seconds = 300 deciseconds (at world.fps=40)
		M << "\yellow You need to wait [round((300 - time_since_search) / 10)] more seconds before searching again..."
		return
	
	// Already searched this spot?
	if(searchable_obj.searched == 1)
		M << "You've already thoroughly searched here. Nothing left to find."
		return
	
	// Mark as being busy
	M.Doing = 1
	M.last_search_time = world.time
	M.consecutive_searches += 1
	
	// Escalating difficulty: consecutive searches are slightly harder (XP down, success rates down)
	var/difficulty_factor = 1.0 - (M.consecutive_searches * 0.05)  // -5% per consecutive search
	if(difficulty_factor < 0.5) difficulty_factor = 0.5  // Floor at 50%
	
	// Start the minigame!
	M << "\cyan\n=== Beginning Search ===\n"
	M << "You kneel down and begin searching through the [searchable_obj.name]...\n"
	
	// Stage 1: Initial search (quick feel around)
	sleep(10)  // 1 second
	M << "You gently part the foliage..."
	
	// Stage 2: Building anticipation
	sleep(15)  // 1.5 seconds
	M << "Your fingers brush against something interesting..."
	
	// Stage 3: The discovery!
	sleep(15)  // 1.5 seconds
	
	// Determine what was found
	var/datum/search_result/discovery = SelectSearchResult(M, searchable_obj, difficulty_factor)
	
	if(discovery)
		// Something was found!
		M << "\green You find: [discovery.display_name]!"
		
		// Award XP (adjusted for difficulty)
		var/xp_award = round(discovery.base_xp * difficulty_factor)
		M.character.UpdateRankExp(RANK_SEARCHING, xp_award)
		
		// Create item if it has one
		if(discovery.item_type)
			// Check if this is a unique item
			if(discovery.is_unique && GetPlayerInventoryItemCount(M, discovery.item_type) > 0)
				// Player already has this unique item - just give XP, no duplicate
				M << "\yellow (You already have one of these...)"
			else
				// Create the item in player inventory
				new discovery.item_type(M, 1)
	else
		// Nothing found - but you still get a little XP for trying
		M << "\yellow You don't find anything, but you gain some experience from the search."
		M.character.UpdateRankExp(RANK_SEARCHING, 5)
	
	// Mark spot as searched
	searchable_obj.searched = 1
	
	// Reset consecutive search counter after successful find (encourages exploration)
	if(discovery) M.consecutive_searches = 0
	
	M.Doing = 0
	M << "\cyan=== Search Complete ===\n"

/proc/SelectSearchResult(mob/players/M, obj/Flowers/location, difficulty_factor)
	/**
	 * Randomly selects what the player finds based on:
	 * - Player searching rank
	 * - Item rarity
	 * - Biome (if applicable)
	 * - Random chance modified by difficulty
	 */
	
	if(!SEARCHABLE_ITEMS || !SEARCHABLE_ITEMS.len) 
		InitializeSearchables()
	
	var/player_rank = M.character.searching_rank
	var/list/valid_results = list()
	
	// Filter: only items within player's rank range
	for(var/datum/search_result/result in SEARCHABLE_ITEMS)
		if(result.min_rank <= player_rank && player_rank <= result.max_rank)
			valid_results += result
	
	if(!valid_results || !valid_results.len)
		return null
	
	// Weight results by rarity (higher rarity = lower chance)
	var/datum/search_result/selected = null
	var/highest_probability = 0
	
	for(var/datum/search_result/result in valid_results)
		// Rarity 50 = 50% chance base, 25 = 75% chance, 90 = 10% chance
		var/base_prob = 100 - result.rarity
		
		// Apply difficulty and rank multipliers
		var/adjusted_prob = base_prob * difficulty_factor
		adjusted_prob *= (1.0 + (player_rank * 0.1))  // Higher rank = slightly better odds
		
		if(prob(adjusted_prob))
			if(adjusted_prob > highest_probability)
				selected = result
				highest_probability = adjusted_prob
	
	// If nothing selected by probability, maybe find something common anyway
	if(!selected && prob(20))
		selected = valid_results[1]  // Pick first (most common)
	
	return selected

// NOTE: The Searching() verb is integrated into Objects.dm as part of /obj verbs
// This system provides the engine - the verb integration handles the actual interaction
