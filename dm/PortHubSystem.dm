// PortHubSystem.dm - Port Lobby (Character Customization Gameplay Area)
// Instanced social hub where players create/customize characters and select continents
// Supports both single-player private and multiplayer shared modes

// ============================================================================
// PORT HUB ZONE DEFINITION
// ============================================================================

/turf/port_zone
	name = "Port Zone"
	density = 0
	layer = TURF_LAYER
	
	New()
		. = ..()
		// Port zones can't be damaged or modified
		density = 0

/area/port_hub
	name = "Port Lobby"
	icon_state = "port"
	// Sound managed via SoundManager.dm, not area-level soundscape var

// ============================================================================
// PORT ENTRANCE (Continent Selection Area)
// ============================================================================

/turf/port_entrance
	name = "Port Entrance"
	desc = "A grand port with three towering gateways. Choose your destination..."
	density = 0
	layer = TURF_LAYER

/obj/port_gateway
	name = "portal gateway"
	density = 1
	layer = MOB_LAYER + 1
	
	var
		destination_continent = ""  // "story", "sandbox", "kingdom"
		display_name = ""           // For examination
		description = ""            // More flavor
	
	New()
		. = ..()
		switch(destination_continent)
			if("story")
				name = "Boat to Kingdom of Freedom"
				display_name = "Kingdom Gateway"
				description = "A weathered sailing boat heading toward the Kingdom of Freedom. Adventure and quests await."
				icon_state = "portal_story"
			if("sandbox")
				name = "Portal to Sandbox"
				display_name = "Sandbox Gateway"
				description = "A shimmering portal glowing with creative magic. Build freely without limits."
				icon_state = "portal_sandbox"
			if("kingdom")
				name = "Gateway to Battlelands"
				display_name = "PvP Gateway"
				description = "A dark, ominous gateway crackling with competitive energy. Only the strong survive here."
				icon_state = "portal_kingdom"
	
	Click()
		var/mob/players/P = usr
		if(!istype(P)) return
		
		// Check if player is at port
		if(!istype(P.loc, /turf/port_zone) && !istype(P.loc, /turf/port_entrance))
			usr << "<span class='danger'>You must be at the port to use this gateway.</span>"
			return
		
		// Prompt destination confirmation
		var/confirm = input(usr, "Travel to [display_name]?", "Destination") in list("Yes", "No")
		if(confirm == "No")
			return
		
		// Prepare for travel (transmute equipment, lock inventory)
		TravelToContinentFromPort(P, destination_continent)
	
	// Examine() proc removed - obj/port_gateway examination not fully implemented
	// TODO: Implement proper Examine() with parent call when object hierarchy defined

// ============================================================================
// PORT HUB FUNCTIONS
// ============================================================================

/**
 * TravelToContinentFromPort(mob/players/P, continent_name)
 * Handle player travel from port to continent
 * 1. Save current inventory to port locker
 * 2. Transmute equipment if crossing continents
 * 3. Load continent-specific inventory
 * 4. Teleport to continent-specific spawn
 * 
 * @param P: Player mob
 * @param continent_name: "story", "sandbox", "kingdom"
 */
proc/TravelToContinentFromPort(mob/players/P, continent_name)
	if(!P || !P.character) return
	
	var/datum/continent/destination = continents[continent_name]
	if(!destination)
		P << "<span class='danger'>Continent not found.</span>"
		return
	
	// Verify can travel (check mode restrictions, etc.)
	if(!CanTravelToContinent(P, continent_name))
		return
	
	// Save current inventory & equipment to port locker
	SaveInventoryToPortLocker(P, P.current_continent)
	
	// Transmute equipment if crossing continents
	if(P.current_continent && P.current_continent != continent_name)
		TransmuteEquipmentAcrossContinents(P, P.current_continent, continent_name)
	
	// Load continent-specific inventory
	LoadInventoryFromPortLocker(P, continent_name)
	
	// Update player's current continent
	P.current_continent = continent_name
	
	// Teleport to continent spawn
	var/turf/spawn_loc = GetContinentSpawnPoint(continent_name)
	if(spawn_loc)
		P.loc = spawn_loc
		P << "<span class='good'>You have arrived in the [continent_name] continent.</span>"
	else
		P << "<span class='danger'>ERROR: Could not find spawn location.</span>"

/**
 * CanTravelToContinent(mob/players/P, continent_name)
 * Check if player is allowed to travel to continent
 * Enforces game mode restrictions (SP/MP/offline)
 * 
 * @param P: Player mob
 * @param continent_name: Destination continent
 * @return: 1 if allowed, 0 if blocked
 */
proc/CanTravelToContinent(mob/players/P, continent_name)
	if(!P) return 0
	
	var/datum/continent/dest = continents[continent_name]
	if(!dest) return 0
	
	// Check difficulty configuration
	var/datum/server_difficulty_config/config = GetServerDifficultyConfig()
	if(!config) return 1  // Default allow if no config
	
	// All continents are accessible by default
	// Server difficulty configuration controls other aspects (lives, permadeath)
	// but does not restrict continent access
	
	return 1  // Default allow

/**
 * SaveInventoryToPortLocker(mob/players/P, continent)
 * Save player's current inventory & equipment to port locker
 * Called before traveling to a different continent
 * 
 * @param P: Player mob
 * @param continent: Current continent (to find locker location)
 */
proc/SaveInventoryToPortLocker(mob/players/P, continent)
	if(!P || !P.character) return
	if(!continent) return  // First time (no prior continent)
	
	// Get player's locker for this continent
	var/datum/port_locker/locker = GetPortLocker(P.ckey, continent)
	if(!locker)
		locker = new /datum/port_locker()
		locker.owner_ckey = P.ckey
		locker.continent = continent
		SetPortLocker(P.ckey, continent, locker)
	
	// Save all inventory items & equipment to locker
	for(var/obj/item/I in P.contents)
		locker.items += I
	
	// Clear player inventory
	P.contents = list()
	P.equipped_items = list()

/**
 * LoadInventoryFromPortLocker(mob/players/P, continent)
 * Load player's inventory & equipment from port locker
 * Called after arriving at a continent
 * 
 * @param P: Player mob
 * @param continent: Destination continent
 */
proc/LoadInventoryFromPortLocker(mob/players/P, continent)
	if(!P || !P.character) return
	
	// Get player's locker for this continent
	var/datum/port_locker/locker = GetPortLocker(P.ckey, continent)
	if(!locker)
		// First visit to continent, no saved items
		P.contents = list()
		return
	
	// Load all items from locker
	for(var/obj/item/I in locker.items)
		I.loc = P
	
	// Re-equip items that were equipped
	UpdateEquipmentOverlays(P)

/**
 * GetPortLocker(ckey, continent)
 * Retrieve player's port locker for a specific continent
 * 
 * @param ckey: Player's ckey
 * @param continent: Continent name
 * @return: port_locker datum or null
 */
proc/GetPortLocker(ckey, continent)
	// This would be stored in a global or database
	// For now, simplified implementation
	// var/locker_key = "[ckey]_[continent]"
	// return global_port_lockers[locker_key]
	return null  // TODO: Implement persistent storage

/**
 * SetPortLocker(ckey, continent, datum/port_locker/locker)
 * Save player's port locker for a specific continent
 * 
 * @param ckey: Player's ckey
 * @param continent: Continent name
 * @param locker: port_locker datum
 */
proc/SetPortLocker(ckey, continent, datum/port_locker/locker)
	// Store in global or database
	// var/locker_key = "[ckey]_[continent]"
	// global_port_lockers[locker_key] = locker
	// TODO: Implement persistent storage

// ============================================================================
// PORT CHARACTER CUSTOMIZATION (Prestige-Gated)
// ============================================================================

/obj/port_customization_npc
	name = "Stylist"
	desc = "A professional stylist who can help you customize your appearance."
	density = 1
	
	Click()
		var/mob/players/P = usr
		if(!istype(P)) return
		
		// All players can customize appearance (not prestige-locked)
		// Prestige unlock allows RE-CUSTOMIZATION (makeover) of appearance
		OpenPrestigeCustomizationUI(P)

/**
 * OpenPrestigeCustomizationUI(mob/players/P)
 * Open character customization interface
 * Available to ALL players (not prestige-locked)
 * Prestige unlock allows CHANGING previously customized appearance (makeover feature)
 * 
 * @param P: Player mob
 */
proc/OpenPrestigeCustomizationUI(mob/players/P)
	if(!P || !P.character) return
	
	// All players can customize (prestige is for RE-CUSTOMIZATION only)
	P << "\n<span class='info'>═══════════════════════════════════════</span>"
	P << "<span class='info'>CHARACTER CUSTOMIZATION</span>"
	P << "<span class='info'>═══════════════════════════════════════</span>"
	P << "<span class='info'>[1] Hair Color</span>"
	P << "<span class='info'>[2] Skin Tone</span>"
	P << "<span class='info'>[3] Eye Color</span>"
	P << "<span class='info'>[4] Body Marks</span>"
	P << "<span class='info'>[5] Change Gender (M/F)</span>"
	P << "<span class='info'>[6] Preview Changes</span>"
	P << "<span class='info'>[7] Apply & Save</span>"
	P << "<span class='info'>[0] Cancel</span>"
	P << "<span class='info'>═══════════════════════════════════════</span>"
	
	// NOTE: Prestige system integration pending
	// var/datum/PrestigeSystem/ps = GetPrestigeSystem()
	// if(ps && ps.IsPrestige(P))
	//	P << "<span class='good'>✦ Prestige Unlocked: You can recustomize your appearance anytime! ✦</span>"
	
	// Input handled via verb or client UI
	// See PrestigeSystem.dm for full implementation

// ============================================================================
// PORT RECREATION LOCKER (Character Reset)
// ============================================================================

/obj/port_recreation_npc
	name = "Portal Master"
	desc = "A mystical guide who can help prestige players recreate their characters."
	density = 1
	
	Click()
		var/mob/players/P = usr
		if(!istype(P)) return
		
		// NOTE: Prestige system integration pending
		// var/datum/PrestigeSystem/ps = GetPrestigeSystem()
		// if(!ps || !ps.IsPrestige(P))
		//	P << "<span class='warning'>Character recreation is only available to prestige players.</span>"
		//	return
		
		P << "<span class='info'>Character recreation feature pending prestige system integration.</span>"
		// var/confirm = input(P, "Recreate character? (Resets inventory & appearance, keeps skills/recipes)", "Recreation") in list("Yes", "No")
		// if(confirm == "No")
		//	return
		// RecreateCharacter(P)
	
	// Examine proc disabled pending integration
	// Examine()
	//	. = ..()
	//	// var/datum/PrestigeSystem/ps = GetPrestigeSystem()
	//	// if(ps && ps.IsPrestige(usr))
	//	//	. += "<span class='good'>Prestige players can recreate their character here!</span>"
	//	//	. += "This begins a new-game+ experience with preserved skills."
	//	// else
	//	//	. += "<span class='warning'>Recreation requires prestige status.</span>"
	//	return .

// ============================================================================
// PORT LOCKER DATUM (Persistent Storage)
// ============================================================================

/datum/port_locker
	var
		owner_ckey = ""
		continent = ""           // Which continent's locker this is
		items = list()           // Stored items
		capacity = 50            // Max items
	
	proc/Deposit(obj/item/I)
		/**
		 * Deposit item into locker
		 * Only whitelisted items allowed
		 */
		if(!I) return 0
		if(!IsItemWhitelistedForLocker(I)) return 0
		if(length(items) >= capacity) return 0
		
		items += I
		return 1
	
	proc/Withdraw(item_name)
		/**
		 * Withdraw item from locker by name
		 */
		for(var/obj/item/I in items)
			if(I.name == item_name)
				items -= I
				return I
		
		return null
	
	proc/GetContents()
		/**
		 * Get list of stored items
		 */
		var/list/copy = list()
		for(var/item in items)
			copy += item
		return copy
	
	proc/IsItemWhitelistedForLocker(obj/item/I)
		/**
		 * Check if item is allowed in locker
		 * Whitelisted: Cosmetics, trophies, valuables
		 * Blocked: Weapons, armor, consumables
		 */
		if(!I) return 0
		
		// Only allow specific cosmetic/treasure items in port locker
		// Check by type path since item_type var may not exist
		var/item_path = "[I.type]"
		
		// Block weapons and armor
		if(findtext(item_path, "weapon") || findtext(item_path, "armor")) return 0
		
		// Block consumables
		if(findtext(item_path, "food") || findtext(item_path, "consume")) return 0
		
		// Allow everything else (cosmetics, trophies, etc)
		return 1

// ============================================================================
// PORT HUB SPAWNING
// ============================================================================

/**
 * InitializePortHub()
 * Bootstrap port hub on world start
 * Create: entrance, gateways, customization NPCs
 * Called from InitializationManager.dm
 */
proc/InitializePortHub()
	// Create port entrance area
	var/turf/port_entrance/entrance = new()
	
	// Create gateways
	var/obj/port_gateway/story_gateway = new()
	story_gateway.destination_continent = "story"
	story_gateway.loc = entrance
	
	var/obj/port_gateway/sandbox_gateway = new()
	sandbox_gateway.destination_continent = "sandbox"
	sandbox_gateway.loc = entrance
	
	var/obj/port_gateway/kingdom_gateway = new()
	kingdom_gateway.destination_continent = "kingdom"
	kingdom_gateway.loc = entrance
	
	// Create NPCs
	var/obj/port_customization_npc/stylist = new()
	stylist.loc = entrance
	
	var/obj/port_recreation_npc/portal_master = new()
	portal_master.loc = entrance

// NOTE: GetContinentSpawnPoint is defined in ContinentSpawnZones.dm (Phase 2 modern system)
// Using that implementation instead of duplicating here

/**
 * GetPortHubCenter()
 * Get the port hub center turf (where players arrive on login)
 * 
 * @return: Port hub center turf
 */
proc/GetPortHubCenter()
	return /turf/port_entrance  // Default port entrance

