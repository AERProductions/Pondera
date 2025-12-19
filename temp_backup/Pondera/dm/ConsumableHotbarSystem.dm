/**
 * CONSUMABLE HOTBAR SYSTEM (PHASE 6)
 * 
 * Quick-use consumables from toolbelt hotbar.
 * E-key = instant consumption → removes item from inventory
 * Integrates with HungerThirstSystem for nutrition/hydration effects.
 * 
 * Features:
 * - Food/drink/potion selection menu
 * - Quick-consume without confirmation
 * - Multi-stack tracking (use 1, stack--; display updated)
 * - Nutrition/hydration/stamina stat display
 * - Rank-based quality bonuses
 * - Season-gated availability
 * - Real-time inventory updates
 */

// ==================== CONSUMABLE HOTBAR REGISTRY ====================

/**
 * Consumable categories for menu organization
 */
#define CONSUME_FOOD        "food"
#define CONSUME_WATER       "water"
#define CONSUME_POTION      "potion"


/**
 * DisplayConsumableMenu(mob/M, category = "") -> null
 * 
 * Shows available consumables player can eat/drink
 * Filters by category and current season
 * Displays nutrition stats and stack counts
 */
/proc/DisplayConsumableMenu(mob/players/M, category = "")
	if(!M || !M.client)
		return
	
	if(!CONSUMABLES)
		world << "ERROR: CONSUMABLES registry not initialized"
		return
	
	// Scan inventory for consumable items
	var/list/available = list()
	
	for(var/obj/items/item in M.contents)
		if(!item.name)
			continue
		
		var/item_name = lowertext(item.name)
		
		// Check if in CONSUMABLES registry
		if(item_name in CONSUMABLES)
			var/list/props = CONSUMABLES[item_name]
			
			// Filter by category if specified
			if(category && props["type"] != category)
				continue
			
			// Check if available this season
			if(props["seasons"])
				var/current_season = GetCurrentSeason()
				if(!(current_season in props["seasons"]))
					continue
			
			available[item_name] = item
	
	if(!available.len)
		M << "<red>You don't have any consumables available right now.</red>"
		return
	
	// Build menu display
	var/title = "<b><cyan>═══════════ CONSUMABLES ═══════════</cyan></b>"
	var/menu_text = title
	menu_text += "\n"
	
	var/list/options = list()
	var/idx = 1
	
	for(var/consumable_name in available)
		var/obj/items/item = available[consumable_name]
		var/list/props = CONSUMABLES[consumable_name]
		
		var/type_icon = props["type"] == "water" ? "💧" : (props["type"] == "food" ? "🍖" : "⚗")
		var/nutrition = props["nutrition"] ? "[props["nutrition"]]NU" : "—"
		var/hydration = props["hydration"] ? "[props["hydration"]]HY" : "—"
		var/stamina = props["stamina"] ? "[props["stamina"]]ST" : "—"
		var/stack = item.stack_size ? item.stack_size : 1
		
		menu_text += "\n[idx]. [type_icon] <b>[consumable_name]</b> x[stack]"
		menu_text += "\n   NUT:[nutrition] | HYD:[hydration] | STA:[stamina]"
		
		if(props["description"])
			menu_text += "\n   [props["description"]]"
		
		options[idx] = consumable_name
		idx++
	
	menu_text += "\n<yellow>0 = Cancel</yellow>"
	
	M << menu_text
	
	// Prompt for selection
	var/choice = input(M, menu_text, "Select Food/Drink") as null|anything in options
	
	if(!choice || !(choice in options))
		return
	
	var/selected_name = options[choice]
	if(selected_name in available)
		ExecuteConsume(M, selected_name)


/**
 * ExecuteConsume(mob/M, consumable_name) -> int
 * 
 * Consume item: remove from inventory, apply effects
 * Returns: 1 if consumed, 0 if failed
 */
/proc/ExecuteConsume(mob/players/M, consumable_name)
	if(!M || !M.client || !consumable_name)
		return 0
	
	if(!CONSUMABLES || !(consumable_name in CONSUMABLES))
		M << "<red>That item doesn't exist in the consumables registry.</red>"
		return 0
	
	// Find item in inventory
	var/obj/items/item = null
	
	for(var/obj/items/it in M.contents)
		if(lowertext(it.name) == lowertext(consumable_name))
			item = it
			break
	
	if(!item)
		M << "<red>You don't have that item.</red>"
		return 0
	
	var/list/props = CONSUMABLES[consumable_name]
	
	// Apply effects
	var/nutrition_gain = props["nutrition"] ? props["nutrition"] : 0
	var/hydration_gain = props["hydration"] ? props["hydration"] : 0
	var/stamina_gain = props["stamina"] ? props["stamina"] : 0
	var/health_gain = props["health"] ? props["health"] : 0
	
	// Apply quality modifier (if exists)
	if(props["quality"] && props["quality"] != 1.0)
		nutrition_gain = round(nutrition_gain * props["quality"])
		hydration_gain = round(hydration_gain * props["quality"])
		health_gain = round(health_gain * props["quality"])
	
	// Apply to player
	if(nutrition_gain > 0)
		M.nutrition = min(M.nutrition + nutrition_gain, 1000)
	
	if(hydration_gain > 0)
		M.hydration = min(M.hydration + hydration_gain, 1000)
	
	if(stamina_gain > 0)
		M.stamina = min(M.stamina + stamina_gain, 1000)
	
	if(health_gain > 0)
		M.health = min(M.health + health_gain, 100)
	
	// Consume message
	var/consume_message = ""
	if(props["type"] == "water")
		consume_message = "You drink the [consumable_name]..."
	else if(props["type"] == "food")
		consume_message = "You eat the [consumable_name]..."
	else
		consume_message = "You consume the [consumable_name]..."
	
	M << "<cyan>[consume_message]</cyan>"
	
	// Flavor feedback
	if(nutrition_gain > 50)
		M << "<yellow>Delicious and filling!</yellow>"
	else if(nutrition_gain > 0)
		M << "<yellow>Tasty morsel.</yellow>"
	
	if(hydration_gain > 100)
		M << "<yellow>Refreshing!</yellow>"
	
	// Remove from inventory
	if(item.stack_size && item.stack_size > 1)
		item.stack_size--
		M << "<gray>([item.stack_size] remaining)</gray>"
	else
		del item
	
	return 1


/**
 * GetConsumableMenuOptions(mob/M) -> list
 * 
 * Returns list of available consumables for hotbar quick-access display
 */
/proc/GetConsumableMenuOptions(mob/players/M)
	if(!M)
		return list()
	
	var/list/options = list()
	var/current_season = GetCurrentSeason()
	
	for(var/obj/items/item in M.contents)
		if(!item.name)
			continue
		
		var/item_name = lowertext(item.name)
		
		if(item_name in CONSUMABLES)
			var/list/props = CONSUMABLES[item_name]
			
			// Check season availability
			if(props["seasons"] && !(current_season in props["seasons"]))
				continue
			
			var/stack = item.stack_size ? " x[item.stack_size]" : ""
			var/icon = props["type"] == "water" ? "💧" : (props["type"] == "food" ? "🍖" : "⚗")
			
			options += "[icon] [item_name][stack]"
	
	return options


/**
 * QuickConsume(mob/M, hotbar_slot) -> int
 * 
 * E-key quick consumption from hotbar
 * Bypasses menu, immediately consumes bound item
 * Returns: 1 if consumed, 0 if failed
 */
/proc/QuickConsume(mob/players/M, hotbar_slot)
	if(!M || !M.client || !hotbar_slot)
		return 0
	
	if(!M.toolbelt)
		return 0
	
	var/obj/items/item = M.toolbelt.GetSlot(hotbar_slot)
	
	if(!item)
		M << "<red>Nothing in that hotbar slot.</red>"
		return 0
	
	var/item_name = lowertext(item.name)
	
	if(!(item_name in CONSUMABLES))
		M << "<red>That's not a consumable.</red>"
		return 0
	
	return ExecuteConsume(M, item_name)


/**
 * CanConsumeItem(mob/M, consumable_name) -> int
 * 
 * Check if player can consume item (has it, season is right, etc)
 * Returns: 1 if can consume, 0 if not
 */
/proc/CanConsumeItem(mob/players/M, consumable_name)
	if(!M || !consumable_name)
		return 0
	
	if(!(consumable_name in CONSUMABLES))
		return 0
	
	var/list/props = CONSUMABLES[consumable_name]
	
	// Check season availability
	var/current_season = GetCurrentSeason()
	if(props["seasons"] && !(current_season in props["seasons"]))
		return 0
	
	// Check if player has item
	for(var/obj/items/item in M.contents)
		if(lowertext(item.name) == lowertext(consumable_name))
			return 1
	
	return 0


/**
 * DisplayConsumableStats(consumable_name) -> text
 * 
 * Returns formatted stats string for consumable
 */
/proc/DisplayConsumableStats(consumable_name)
	if(!(consumable_name in CONSUMABLES))
		return ""
	
	var/list/props = CONSUMABLES[consumable_name]
	
	var/stats = ""
	stats += "Nutrition: [props["nutrition"] ? props["nutrition"] : 0] | "
	stats += "Hydration: [props["hydration"] ? props["hydration"] : 0] | "
	stats += "Stamina: [props["stamina"] ? props["stamina"] : 0] | "
	stats += "Health: [props["health"] ? props["health"] : 0]"
	
	return stats


// ==================== CONSUMABLE ITEM EXTENSION ====================

/obj/items
	var
		stack_size = 1  // How many of this item are stacked


// ==================== INITIALIZATION ====================

/proc/InitializeConsumableHotbarSystem()
	/**
	 * InitializeConsumableHotbarSystem() -> null
	 * 
	 * Called during world init to set up consumable registry checks
	 */
	
	if(!CONSUMABLES || CONSUMABLES.len == 0)
		world << "<yellow>WARNING: CONSUMABLES registry empty. Check ConsumptionManager.dm</yellow>"
		return
	
	world << "<cyan>Consumable Hotbar System initialized ([CONSUMABLES.len] consumables)</cyan>"
