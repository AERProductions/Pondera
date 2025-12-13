// EquipmentTransmutationSystem.dm - Seamless Equipment Morphing
// When players cross continents, equipped gear "transmutes" into equivalent items for that continent
// Example: Kingdom sword → Story broadsword → Sandbox wooden sword (stats preserved, appearance changes)

// ============================================================================
// EQUIPMENT TRANSMUTATION MAPPING
// ============================================================================

/**
 * GlobalEquipmentTransmutationMap
 * Maps equipment across continents for seamless transitions
 * Structure: [source_continent][dest_continent][item_name] = transmuted_name
 * 
 * Principle: Each continent has equivalent gear with same stats but different flavor/appearance
 * Transmutation preserves equipment quality/rarity but changes cosmetics
 */
var/global/list/equipment_transmutation_map = list(
	"port" = list(
		"story" = list(
			"iron_sword" = "bronze_sword",
			"steel_armor" = "knight_plate",
			"leather_gloves" = "padded_gloves",
			"steel_boots" = "plate_boots"
		),
		"sandbox" = list(
			"iron_sword" = "wooden_sword",
			"steel_armor" = "cloth_robes",
			"leather_gloves" = "craftsman_gloves",
			"steel_boots" = "soft_boots"
		),
		"kingdom" = list(
			"iron_sword" = "steel_sword",
			"steel_armor" = "war_plate",
			"leather_gloves" = "gauntlets",
			"steel_boots" = "sabatons"
		)
	),
	"story" = list(
		"port" = list(
			"bronze_sword" = "iron_sword",
			"knight_plate" = "steel_armor",
			"padded_gloves" = "leather_gloves",
			"plate_boots" = "steel_boots"
		),
		"sandbox" = list(
			"bronze_sword" = "wooden_sword",
			"knight_plate" = "cloth_robes",
			"padded_gloves" = "craftsman_gloves",
			"plate_boots" = "soft_boots"
		),
		"kingdom" = list(
			"bronze_sword" = "steel_sword",
			"knight_plate" = "war_plate",
			"padded_gloves" = "gauntlets",
			"plate_boots" = "sabatons"
		)
	),
	"sandbox" = list(
		"port" = list(
			"wooden_sword" = "iron_sword",
			"cloth_robes" = "steel_armor",
			"craftsman_gloves" = "leather_gloves",
			"soft_boots" = "steel_boots"
		),
		"story" = list(
			"wooden_sword" = "bronze_sword",
			"cloth_robes" = "knight_plate",
			"craftsman_gloves" = "padded_gloves",
			"soft_boots" = "plate_boots"
		),
		"kingdom" = list(
			"wooden_sword" = "steel_sword",
			"cloth_robes" = "war_plate",
			"craftsman_gloves" = "gauntlets",
			"soft_boots" = "sabatons"
		)
	),
	"kingdom" = list(
		"port" = list(
			"steel_sword" = "iron_sword",
			"war_plate" = "steel_armor",
			"gauntlets" = "leather_gloves",
			"sabatons" = "steel_boots"
		),
		"story" = list(
			"steel_sword" = "bronze_sword",
			"war_plate" = "knight_plate",
			"gauntlets" = "padded_gloves",
			"sabatons" = "plate_boots"
		),
		"sandbox" = list(
			"steel_sword" = "wooden_sword",
			"war_plate" = "cloth_robes",
			"gauntlets" = "craftsman_gloves",
			"sabatons" = "soft_boots"
		)
	)
)

// ============================================================================
// TRANSMUTATION PROCESS
// ============================================================================

/**
 * TransmuteEquipmentAcrossContinents(mob/players/P, from_continent, to_continent)
 * Handle complete equipment transmutation when crossing continental boundary
 * Process:
 *   1. Unequip all non-cosmetic gear
 *   2. Gather equipped item names
 *   3. Look up transmutation rules
 *   4. Delete old items, create transmuted versions
 *   5. Re-equip with same slot assignments
 * 
 * @param P: Player mob
 * @param from_continent: Source continent ("story", "sandbox", "kingdom", "port")
 * @param to_continent: Destination continent
 */
proc/TransmuteEquipmentAcrossContinents(mob/players/P, from_continent, to_continent)
	if(!P || !P.character) return
	if(!from_continent || !to_continent) return
	
	// Check if transmutation mapping exists
	var/list/source_map = equipment_transmutation_map[from_continent]
	if(!source_map)
		P << "<span class='warning'>ERROR: No transmutation mapping for [from_continent].</span>"
		return
	
	var/list/transmutation_rules = source_map[to_continent]
	if(!transmutation_rules)
		P << "<span class='warning'>ERROR: No transmutation rules from [from_continent] to [to_continent].</span>"
		return
	
	// Record equipped items before transmutation
	var/list/equipped_record = list()
	for(var/obj/items/equipment/E in P.equipped_items)
		if(!E.is_cosmetic)  // Only transmute non-cosmetic
			equipped_record[E.name] = E.equipment_slot
	
	// PHASE 1: Unequip and delete old equipment
	var/list/items_to_delete = list()
	for(var/obj/items/equipment/E in P.equipped_items)
		if(!E.is_cosmetic)
			items_to_delete += E
	
	for(var/obj/items/equipment/E in items_to_delete)
		UnequipItem(P, E)
		del E
	
	// PHASE 2: Create transmuted versions
	var/list/new_equipment = list()
	for(var/old_item_name in equipped_record)
		var/new_item_name = transmutation_rules[old_item_name]
		
		if(!new_item_name)
			// No transmutation rule, skip this item
			P << "<span class='warning'>No transmutation for [old_item_name].</span>"
			continue
		
		// Create new item by type
		var/new_item_type = GetItemTypeByName(new_item_name)
		if(!new_item_type)
			P << "<span class='danger'>ERROR: Item type not found for [new_item_name].</span>"
			continue
		
		var/obj/items/equipment/new_item = new new_item_type()
		new_item.loc = P
		new_equipment[new_item] = equipped_record[old_item_name]  // Preserve slot
	
	// PHASE 3: Re-equip with same slots
	for(var/obj/items/equipment/new_item in new_equipment)
		var/slot = new_equipment[new_item]
		EquipItem(P, new_item, slot)
	
	// Update overlays
	UpdateEquipmentOverlays(P)
	
	// Notify player of transmutation
	P << "<span class='good'>✦ Equipment transmuted for [to_continent] environment ✦</span>"
	for(var/old_item_name in equipped_record)
		var/new_item_name = transmutation_rules[old_item_name]
		if(new_item_name)
			P << "<span class='info'>  [old_item_name] → [new_item_name]</span>"

/**
 * GetItemTypeByName(item_name)
 * Look up item type path by item name
 * Maps item names to their /obj/items/equipment/... type paths
 * 
 * @param item_name: Name of item (e.g., "iron_sword", "knight_plate")
 * @return: Item type path or null
 */
proc/GetItemTypeByName(item_name)
	// This would be populated from a global item registry
	// For now, using generic /obj/items/equipment type
	// NOTE: Actual equipment subtypes (sword, armor, etc.) would be defined elsewhere
	// This is a placeholder that returns a valid type for testing
	return /obj/items/equipment

/**
 * EquipItem(mob/players/P, obj/equipment/E, slot)
 * Equip item in specified slot
 * Handles equipment flags and overlay updates
 * 
 * @param P: Player mob
 * @param E: Equipment item to equip
 * @param slot: Equipment slot ("head", "chest", "hands", "feet", etc.)
 */
proc/EquipItem(mob/players/P, obj/items/equipment/E, slot)
	if(!P || !E) return
	
	// Add to equipped list
	P.equipped_items += E
	
	// Set equipment flags based on slot
	// TODO: Map slot names to equipment flag variables
	// switch(slot)
	//	if("weapon")
	//		P.Wequipped = 1
	//	if("chest")
	//		P.Aequipped = 1
	//	if("hands")
	//		P.Hequipped = 1  // Flag may not exist
	//	if("feet")
	//		P.Fequipped = 1  // Flag may not exist
	
	// Update equipment callbacks
	// if(E.on_equip)
	//	E.on_equip(P)

/**
 * UnequipItem(mob/players/P, obj/items/equipment/E)
 * Unequip item from player
 * 
 * @param P: Player mob
 * @param E: Equipment item to unequip
 */
proc/UnequipItem(mob/players/P, obj/items/equipment/E)
	if(!P || !E) return
	
	// Remove from equipped list
	P.equipped_items -= E
	
	// Clear equipment flags (only clear if they exist)
	P.Wequipped = 0
	P.Aequipped = 0
	// P.Hequipped = 0  // May not exist
	// P.Fequipped = 0  // May not exist
	
	// Call unequip handler if it exists
	// if(E.on_unequip)
	//	E.on_unequip(P)

// ============================================================================
// COSMETIC ITEMS (No Transmutation)
// ============================================================================

/**
 * PreserveCosmetics(mob/players/P)
 * Cosmetic items do NOT transmute - they persist across continents
 * Called before transmutation to preserve cosmetics
 * 
 * @param P: Player mob
 * @return: List of cosmetic items to preserve
 */
proc/PreserveCosmetics(mob/players/P)
	var/list/cosmetics = list()
	
	// TODO: Filter cosmetic items once .is_cosmetic property is defined
	// for(var/obj/items/equipment/E in P.equipped_items)
	//	if(E.is_cosmetic)
	//		cosmetics += E
	
	return cosmetics

/**
 * RestoreCosmetics(mob/players/P, list/cosmetics)
 * Restore cosmetic items after transmutation
 * 
 * @param P: Player mob
 * @param cosmetics: List of cosmetic items to restore
 */
proc/RestoreCosmetics(mob/players/P, list/cosmetics)
	for(var/obj/item/C in cosmetics)
		C.loc = P
		// TODO: Call on_equip handler once defined
		// if(C.on_equip)
		//	C.on_equip(P)

// ============================================================================
// TRANSMUTATION VALIDATION
// ============================================================================

/**
 * ValidateTransmutationMapping()
 * Verify that all transmutation mappings are complete
 * Called on world boot for debugging
 */
proc/ValidateTransmutationMapping()
	var/errors = 0
	
	var/list/continents = list("port", "story", "sandbox", "kingdom")
	
	var/from_cont
	for(from_cont in continents)
		var/dest_cont
		for(dest_cont in continents)
			if(from_cont == dest_cont) continue  // Skip self-mapping
			
			var/list/rules = equipment_transmutation_map[from_cont][dest_cont]
			if(!rules)
				world.log << "WARNING: No transmutation rules from [from_cont] to [dest_cont]."
				errors++
	
	if(errors == 0)
		world.log << "Transmutation mapping validated successfully."
	else
		world.log << "Transmutation validation complete with [errors] warnings."


// ============================================================================
// INTEGRATION WITH CHARACTER LOGIN
// ============================================================================

/**
 * InitializeEquipmentForContinent(mob/players/P, continent)
 * On login to a continent, ensure equipment is transmuted for that continent
 * Called from character login flow
 * 
 * @param P: Player mob
 * @param continent: Destination continent
 */
proc/InitializeEquipmentForContinent(mob/players/P, continent)
	if(!P) return
	
	// If player's last continent differs from current, transmute
	if(P.character.last_continent && P.character.last_continent != continent)
		TransmuteEquipmentAcrossContinents(P, P.character.last_continent, continent)
	
	// Update current continent
	P.character.last_continent = continent
	P.current_continent = continent

