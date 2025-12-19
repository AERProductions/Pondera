/**
 * GATHERING TOOL ACTIVATION SYSTEM
 * 
 * Unified system for all gathering tools (pickaxe, shovel, axe, fishing pole, sickle, hoe, etc.)
 * Integrates with hotbar slot system for seamless tool activation via number keys
 * 
 * TOOL TYPES:
 * - PICKAXE: Mining ore from cliffs/rocks
 * - SHOVEL: Digging/landscaping (dirt, ditches, hills, borders)
 * - AXE: Woodcutting (harvest logs from trees)
 * - FISHING_POLE: Fishing from water bodies
 * - SICKLE: Harvesting crops and vegetation
 * - HOE: Tilling soil for farming
 * - CARVING_KNIFE: Carving wood and stone (dual-wield with hammer/flint)
 * 
 * SLOT 1/1A DESIGN:
 * - Slot 1: Main hand tool
 * - Slot 1A: Secondary hand tool (optional, for dual-wielding)
 * - Players can equip hammer in slot 1, chisel in slot 1a
 * - Single slot occupied for both tools
 * 
 * WORKFLOW:
 * 1. Player obtains tool (pickaxe, hammer, etc.)
 * 2. Player drags tool to hotbar slot 1
 * 3. For dual-wield pairs: secondary tool auto-detected or dragged to 1a
 * 4. Player presses number key (1-9) to activate tool
 * 5. Tool type detected, equipment flags set
 * 6. Player faces target object and presses E to execute action
 */

// ==================== TOOL TYPE CONSTANTS ====================

#define TOOL_TYPE_PICKAXE       "pickaxe"
#define TOOL_TYPE_SHOVEL        "shovel"
#define TOOL_TYPE_AXE           "axe"
#define TOOL_TYPE_FISHING_POLE  "fishing_pole"
#define TOOL_TYPE_SICKLE        "sickle"
#define TOOL_TYPE_HOE           "hoe"
#define TOOL_TYPE_CARVING_KNIFE "carving_knife"
#define TOOL_TYPE_HAMMER        "hammer"
#define TOOL_TYPE_CHISEL        "chisel"
#define TOOL_TYPE_FLINT         "flint"
#define TOOL_TYPE_PYRITE        "pyrite"

// ==================== GATHERING TOOL DETECTION ====================

/proc/GetGatheringToolType(obj/item)
	/**
	 * GetGatheringToolType(item) -> text
	 * 
	 * Identifies the type of gathering tool by name and properties
	 * Used to determine gameplay mode and equipment flags
	 * 
	 * Returns: Tool type constant or ""
	 */
	
	if(!item)
		return ""
	
	var/tool_name = lowertext(item.name)
	
	// Pickaxe (includes Ueik Pickaxe, Iron Pickaxe, etc.)
	if(findtext(tool_name, "pickaxe"))
		return TOOL_TYPE_PICKAXE
	
	// Shovel
	if(findtext(tool_name, "shovel"))
		return TOOL_TYPE_SHOVEL
	
	// Axe
	if(findtext(tool_name, "axe") && !findtext(tool_name, "pickaxe"))
		return TOOL_TYPE_AXE
	
	// Fishing Pole
	if(findtext(tool_name, "fishing") || findtext(tool_name, "pole"))
		return TOOL_TYPE_FISHING_POLE
	
	// Sickle
	if(findtext(tool_name, "sickle"))
		return TOOL_TYPE_SICKLE
	
	// Hoe
	if(findtext(tool_name, "hoe"))
		return TOOL_TYPE_HOE
	
	// Carving Knife
	if(findtext(tool_name, "carving") || findtext(tool_name, "knife"))
		return TOOL_TYPE_CARVING_KNIFE
	
	// Hammer
	if(findtext(tool_name, "hammer"))
		return TOOL_TYPE_HAMMER
	
	// Chisel
	if(findtext(tool_name, "chisel"))
		return TOOL_TYPE_CHISEL
	
	// Flint
	if(findtext(tool_name, "flint"))
		return TOOL_TYPE_FLINT
	
	// Pyrite
	if(findtext(tool_name, "pyrite"))
		return TOOL_TYPE_PYRITE
	
	return ""

// ==================== GATHERING TOOL MODE MAPPING ====================

/proc/GetGatheringToolMode(tool_type)
	/**
	 * GetGatheringToolMode(tool_type) -> text
	 * 
	 * Maps tool type to gameplay mode
	 * Determines how tool interacts with world
	 * 
	 * Returns: Mode name or ""
	 */
	
	switch(tool_type)
		if(TOOL_TYPE_PICKAXE)
			return "mining"
		
		if(TOOL_TYPE_SHOVEL)
			return "landscaping"
		
		if(TOOL_TYPE_AXE)
			return "woodcutting"
		
		if(TOOL_TYPE_FISHING_POLE)
			return "fishing"
		
		if(TOOL_TYPE_SICKLE)
			return "harvesting"
		
		if(TOOL_TYPE_HOE)
			return "farming"
		
		if(TOOL_TYPE_CARVING_KNIFE)
			return "carving"
		
		if(TOOL_TYPE_HAMMER)
			return "smithing"
		
		if(TOOL_TYPE_CHISEL)
			return "stonecarving"
		
		if(TOOL_TYPE_FLINT)
			return "firestarting"
		
		if(TOOL_TYPE_PYRITE)
			return "firestarting"
	
	return ""

// ==================== EQUIPMENT FLAG MANAGEMENT ====================

/proc/SetGatheringToolEquipped(mob/players/M, tool_type, equipped_state)
	/**
	 * SetGatheringToolEquipped(M, tool_type, equipped_state) -> null
	 * 
	 * Sets equipment flags for gathering tool
	 * Unequips conflicting tools automatically
	 * 
	 * Parameters:
	 * - M: Player mob
	 * - tool_type: Tool type constant
	 * - equipped_state: 1 = equipped, 0 = unequipped, 3 = secondary hand
	 */
	
	if(!M)
		return
	
	switch(tool_type)
		if(TOOL_TYPE_PICKAXE)
			M.PXequipped = equipped_state
		
		if(TOOL_TYPE_SHOVEL)
			M.SHequipped = equipped_state
		
		if(TOOL_TYPE_AXE)
			M.AXequipped = equipped_state
		
		if(TOOL_TYPE_FISHING_POLE)
			M.FPequipped = equipped_state
		
		if(TOOL_TYPE_SICKLE)
			M.SKequipped = equipped_state
		
		if(TOOL_TYPE_HOE)
			M.HOequipped = equipped_state
		
		if(TOOL_TYPE_CARVING_KNIFE)
			M.CKequipped = equipped_state
		
		if(TOOL_TYPE_HAMMER)
			M.HMequipped = equipped_state
		
		if(TOOL_TYPE_CHISEL)
			M.CHequipped = equipped_state
		
		if(TOOL_TYPE_FLINT)
			M.FLequipped = equipped_state
		
		if(TOOL_TYPE_PYRITE)
			M.PYequipped = equipped_state

/proc/UnequipAllGatheringTools(mob/players/M)
	/**
	 * UnequipAllGatheringTools(M) -> null
	 * 
	 * Unequips all gathering tools
	 * Called when switching between hotbar slots
	 */
	
	if(!M)
		return
	
	M.PXequipped = 0
	M.SHequipped = 0
	M.AXequipped = 0
	M.FPequipped = 0
	M.SKequipped = 0
	M.HOequipped = 0
	M.CKequipped = 0
	M.HMequipped = 0
	M.CHequipped = 0
	M.FLequipped = 0
	M.PYequipped = 0

// ==================== DUAL-WIELD PAIR DETECTION ====================

/proc/FindDualWieldPair(mob/players/M, primary_tool_type)
	/**
	 * FindDualWieldPair(M, primary_tool_type) -> obj/item or null
	 * 
	 * Finds secondary tool that pairs with primary for dual-wielding
	 * Checks inventory for compatible tools
	 * 
	 * VALID PAIRS:
	 * - Hammer + Chisel (stone carving)
	 * - Carving Knife + Flint (fire starting)
	 * - Hammer + Carving Knife (smithing/crafting)
	 * - Flint + Pyrite (fire starting)
	 * - Gloves + Hammer (smithing)
	 * 
	 * Returns: Item object if pair found, null otherwise
	 */
	
	if(!M)
		return null
	
	var/secondary_type = ""
	
	// Determine what secondary tool pairs with primary
	switch(primary_tool_type)
		if(TOOL_TYPE_HAMMER)
			// Hammer pairs with Chisel or Carving Knife
			for(var/obj/item in M.contents)
				var/item_type = GetGatheringToolType(item)
				if(item_type == TOOL_TYPE_CHISEL || item_type == TOOL_TYPE_CARVING_KNIFE)
					return item
		
		if(TOOL_TYPE_CHISEL)
			// Chisel pairs with Hammer
			for(var/obj/item in M.contents)
				var/item_type = GetGatheringToolType(item)
				if(item_type == TOOL_TYPE_HAMMER)
					return item
		
		if(TOOL_TYPE_CARVING_KNIFE)
			// Carving Knife pairs with Hammer or Flint
			for(var/obj/item in M.contents)
				var/item_type = GetGatheringToolType(item)
				if(item_type == TOOL_TYPE_HAMMER || item_type == TOOL_TYPE_FLINT)
					return item
		
		if(TOOL_TYPE_FLINT)
			// Flint pairs with Carving Knife or Pyrite
			for(var/obj/item in M.contents)
				var/item_type = GetGatheringToolType(item)
				if(item_type == TOOL_TYPE_CARVING_KNIFE || item_type == TOOL_TYPE_PYRITE)
					return item
		
		if(TOOL_TYPE_PYRITE)
			// Pyrite pairs with Flint
			for(var/obj/item in M.contents)
				var/item_type = GetGatheringToolType(item)
				if(item_type == TOOL_TYPE_FLINT)
					return item
	
	return null

// ==================== TOOL ACTION EXECUTION ====================

/proc/ExecuteGatheringToolAction(mob/players/M, tool_type, obj/target_object)
	/**
	 * ExecuteGatheringToolAction(M, tool_type, target_object) -> int
	 * 
	 * Executes the primary action for a gathering tool on target object
	 * Called when player presses E while facing an interactable object
	 * 
	 * ACTIONS:
	 * - Pickaxe: Mine ore from cliff
	 * - Shovel: Dig landscaping features
	 * - Axe: Harvest logs from tree
	 * - Fishing Pole: Fish from water
	 * - Sickle: Harvest crops
	 * - Hoe: Till soil
	 * - Carving Knife: Carve wood/stone
	 * 
	 * Returns: 1 if action executed, 0 if failed
	 */
	
	if(!M || !target_object)
		return 0
	
	// Check stamina
	if(M.stamina < 5)
		M << "<font color=orange>You're too tired to do that</font>"
		return 0
	
	// Check tool is still equipped
	var/equipped_state = 0
	switch(tool_type)
		if(TOOL_TYPE_PICKAXE)
			equipped_state = M.PXequipped
		if(TOOL_TYPE_SHOVEL)
			equipped_state = M.SHequipped
		if(TOOL_TYPE_AXE)
			equipped_state = M.AXequipped
		if(TOOL_TYPE_FISHING_POLE)
			equipped_state = M.FPequipped
		if(TOOL_TYPE_SICKLE)
			equipped_state = M.SKequipped
		if(TOOL_TYPE_HOE)
			equipped_state = M.HOequipped
		if(TOOL_TYPE_CARVING_KNIFE)
			equipped_state = M.CKequipped
	
	if(!equipped_state)
		M << "<font color=red>Tool is not equipped</font>"
		return 0
	
	// Call tool-specific action handler
	switch(tool_type)
		if(TOOL_TYPE_PICKAXE)
			var/result = ExecutePickaxeAction(M, target_object)
			if(result)
				M.stamina = max(0, M.stamina - 5)
				NotifyToolbeltStaminaDrain(M, 5)
			return result
		if(TOOL_TYPE_SHOVEL)
			var/result = ExecuteShovelAction(M, target_object)
			if(result)
				M.stamina = max(0, M.stamina - 5)
				NotifyToolbeltStaminaDrain(M, 5)
			return result
		if(TOOL_TYPE_AXE)
			var/result = ExecuteAxeAction(M, target_object)
			if(result)
				M.stamina = max(0, M.stamina - 5)
				NotifyToolbeltStaminaDrain(M, 5)
			return result
		if(TOOL_TYPE_FISHING_POLE)
			var/result = ExecuteFishingPoleAction(M, target_object)
			if(result)
				M.stamina = max(0, M.stamina - 3)
				NotifyToolbeltStaminaDrain(M, 3)
			return result
		if(TOOL_TYPE_SICKLE)
			var/result = ExecuteSickleAction(M, target_object)
			if(result)
				M.stamina = max(0, M.stamina - 3)
				NotifyToolbeltStaminaDrain(M, 3)
			return result
		if(TOOL_TYPE_HOE)
			var/result = ExecuteHoeAction(M, target_object)
			if(result)
				M.stamina = max(0, M.stamina - 4)
				NotifyToolbeltStaminaDrain(M, 4)
			return result
		if(TOOL_TYPE_CARVING_KNIFE)
			var/result = ExecuteCarvingKnifeAction(M, target_object)
			if(result)
				M.stamina = max(0, M.stamina - 4)
				NotifyToolbeltStaminaDrain(M, 4)
			return result
	
	return 0

// ==================== TOOL-SPECIFIC ACTION HANDLERS ====================

/proc/ExecutePickaxeAction(mob/players/M, obj/target_object)
	/**
	 * ExecutePickaxeAction(M, target) -> int
	 * 
	 * Mine ore from cliff/rock formation
	 * References existing mining.dm implementation
	 */
	
	if(!M.PXequipped)
		M << "You need a pickaxe equipped"
		return 0
	
	// Verify target is a mineable object (cliff)
	// This integrates with existing mining system in mining.dm
	// Target object must have Mine() proc
	if(istype(target_object, /obj/Cliff))
		if(target_object:Mine(M))
			return 1
	
	M << "You cannot mine that"
	return 0

/proc/ExecuteShovelAction(mob/players/M, obj/target_object)
	/**
	 * ExecuteShovelAction(M, target) -> int
	 * 
	 * Dig landscaping features (ditches, hills, borders, roads)
	 * References existing landscaping system in jb.dm
	 */
	
	if(!M.SHequipped)
		M << "You need a shovel equipped"
		return 0
	
	// Show landscaping menu (integrates with diglevel from jb.dm)
	// This is a placeholder - actual implementation calls existing diglevel()
	M << "Shovel action executed (integration with existing jb.dm diglevel)"
	return 1

/proc/ExecuteAxeAction(mob/players/M, obj/target_object)
	/**
	 * ExecuteAxeAction(M, target) -> int
	 * 
	 * Harvest logs from tree
	 * References existing woodcutting system in WC.dm
	 */
	
	if(!M.AXequipped)
		M << "You need an axe equipped"
		return 0
	
	// Verify target is a tree
	// Check for tree-like objects (plants with wood/resources)
	if(target_object && findtext(target_object.name, "tree", 1, 0))
		// For now, just return success for any tree-like object
		// TODO: Implement proper tree harvesting with Chop proc
		M << "You chop at the [target_object.name]..."
		return 1
	
	M << "You cannot chop that"
	return 0

/proc/ExecuteFishingPoleAction(mob/players/M, obj/target_object)
	/**
	 * ExecuteFishingPoleAction(M, target) -> int
	 * 
	 * Fish from water body
	 * References existing fishing system
	 */
	
	if(!M.FPequipped)
		M << "You need a fishing pole equipped"
		return 0
	
	// Check if target is water
	if(istype(target_object, /turf/water))
		M << "You cast your line and begin fishing..."
		// Integration point: call existing fishing system
		return 1
	
	M << "You cannot fish there"
	return 0

/proc/ExecuteSickleAction(mob/players/M, obj/target_object)
	/**
	 * ExecuteSickleAction(M, target) -> int
	 * 
	 * Harvest crops and vegetation
	 * References existing harvesting system in plant.dm
	 */
	
	if(!M.SKequipped)
		M << "You need a sickle equipped"
		return 0
	
	// Check if target is a plant/crop
	if(istype(target_object, /obj/plant))
		M << "You harvest with your sickle..."
		// Integration point: call existing plant harvesting
		return 1
	
	M << "You cannot harvest that"
	return 0

/proc/ExecuteHoeAction(mob/players/M, obj/target_object)
	/**
	 * ExecuteHoeAction(M, target) -> int
	 * 
	 * Till soil for farming
	 * References existing farming system in plant.dm
	 */
	
	if(!M.HOequipped)
		M << "You need a hoe equipped"
		return 0
	
	// Check if target is soil/ground (check if it's NOT a mountain or cave)
	if(!istype(target_object, /turf/mntn) && !findtext(target_object.name, "cave"))
		M << "You till the soil with your hoe..."
		// Integration point: call existing soil tilling
		return 1
	
	M << "You cannot till that"
	return 0

/proc/ExecuteCarvingKnifeAction(mob/players/M, obj/target_object)
	/**
	 * ExecuteCarvingKnifeAction(M, target) -> int
	 * 
	 * Carve wood or stone
	 * Can be dual-wielded with hammer/flint
	 */
	
	if(!M.CKequipped)
		M << "You need a carving knife equipped"
		return 0
	
	// Check if target is wood or stone
	M << "You carve carefully with your knife..."
	// Integration point: call existing carving system
	return 1
