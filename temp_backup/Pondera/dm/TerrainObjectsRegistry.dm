// TerrainObjectsRegistry.dm - Terrain & Building object lookup tables
// Extracted from jb.dm (8794 lines) for consolidation
// This registry allows data-driven menu generation instead of nested switches

// ==================== TERRAIN OBJECTS REGISTRY ====================

var/global/list/TERRAIN_OBJECTS = list(
	// DIGGING OBJECTS (ranked progression)
	
	"dirt" = list(
		"type" = /obj/Landscaping/Dirt,
		"category" = "Landscaping",
		"xp" = 10,
		"stamina" = 3,
		"rank_required" = 1,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Basic dirt patch"
	),
	
	/*
	"grass" = list(
		"type" = /obj/Landscaping/Grass,
		"category" = "Landscaping",
		"xp" = 10,
		"stamina" = 3,
		"rank_required" = 2,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Grass patch"
	),
	*/
	
	// DIRT ROADS (Rank 3-4)
	"dirt_road_ns" = list(
		"type" = /obj/Landscaping/Road/DirtRoad/NSRoad,
		"category" = "Road",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 3,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Dirt Road - North/South"
	),
	
	"dirt_road_ew" = list(
		"type" = /obj/Landscaping/Road/DirtRoad/EWRoad,
		"category" = "Road",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 3,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Dirt Road - East/West"
	),
	
	"dirt_road_3way_n" = list(
		"type" = /obj/Landscaping/Road/DirtRoad/R3WNRoad,
		"category" = "Road",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 3,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Dirt Road - 3-way (North)"
	),
	
	// DIRT ROAD CORNERS (Rank 4)
	"dirt_corner_nw" = list(
		"type" = /obj/Landscaping/Road/DirtRoad/NWCRoad,
		"category" = "Road",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 4,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Dirt Road Corner - NW"
	),
	
	"dirt_corner_ne" = list(
		"type" = /obj/Landscaping/Road/DirtRoad/NECRoad,
		"category" = "Road",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 4,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Dirt Road Corner - NE"
	),
	
	"dirt_corner_sw" = list(
		"type" = /obj/Landscaping/Road/DirtRoad/SWCRoad,
		"category" = "Road",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 4,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Dirt Road Corner - SW"
	),
	
	"dirt_corner_se" = list(
		"type" = /obj/Landscaping/Road/DirtRoad/SECRoad,
		"category" = "Road",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 4,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Dirt Road Corner - SE"
	),
	
	// WOOD ROADS (Rank 5)
	"wood_road_ns" = list(
		"type" = /obj/Landscaping/Road/WoodRoad/WRNSRoad,
		"category" = "Road",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 5,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Wood Road - North/South"
	),
	
	"wood_road_ew" = list(
		"type" = /obj/Landscaping/Road/WoodRoad/WREWRoad,
		"category" = "Road",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 5,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Wood Road - East/West"
	),
	
	"wood_road_3way_n" = list(
		"type" = /obj/Landscaping/Road/WoodRoad/WR3WNRoad,
		"category" = "Road",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 5,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Wood Road - 3-way (North)"
	),
	
	// WOOD ROAD CORNERS (Rank 5)
	"wood_corner_nw" = list(
		"type" = /obj/Landscaping/Road/WoodRoad/WRNWCRoad,
		"category" = "Road",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 5,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Wood Road Corner - NW"
	),
	
	"wood_corner_ne" = list(
		"type" = /obj/Landscaping/Road/WoodRoad/WRNECRoad,
		"category" = "Road",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 5,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Wood Road Corner - NE"
	),
	
	"wood_corner_sw" = list(
		"type" = /obj/Landscaping/Road/WoodRoad/WRSWCRoad,
		"category" = "Road",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 5,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Wood Road Corner - SW"
	),
	
	"wood_corner_se" = list(
		"type" = /obj/Landscaping/Road/WoodRoad/WRSECRoad,
		"category" = "Road",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 5,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Wood Road Corner - SE"
	),
	
	// BRICK ROADS (Rank 8)
	"brick_road_ns" = list(
		"type" = /obj/Landscaping/Road/StoneRoad/SNSRoad,
		"category" = "Road",
		"xp" = 25,
		"stamina" = 15,
		"rank_required" = 8,
		"tools_required" = list("shovel"),
		"resources_required" = list("bricks" = 6),
		"description" = "Brick Road - North/South"
	),
	
	/*
	// DITCH OBJECTS (Rank 7)
	"ditch_ns" = list(
		"type" = /obj/Landscaping/Ditch/NSDitch,
		"category" = "Ditch",
		"xp" = 20,
		"stamina" = 8,
		"rank_required" = 7,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Ditch - North/South"
	),
	*/
	
	// HILL OBJECTS (Rank 8)
	"hill_basic" = list(
		"type" = /obj/Landscaping/Hill,
		"category" = "Hill",
		"xp" = 30,
		"stamina" = 12,
		"rank_required" = 8,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Basic hill"
	),
	/*
	// WATER (Rank 9)
	"water" = list(
		"type" = /obj/Landscaping/Water,
		"category" = "Water",
		"xp" = 50,
		"stamina" = 20,
		"rank_required" = 9,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Water body"
	),
	
	// LAVA (Rank 10)
	"lava" = list(
		"type" = /obj/Landscaping/Lava,
		"category" = "Lava",
		"xp" = 100,
		"stamina" = 30,
		"rank_required" = 10,
		"tools_required" = list("shovel"),
		"resources_required" = list(),
		"description" = "Lava flow"
	)
	*/
)

// ==================== BUILDING OBJECTS REGISTRY ====================
// Hammer-based construction objects with rank progression

/*
var/global/list/BUILDING_OBJECTS = list(
	
	// FOUNDATIONS (Rank 1-2)
	"stone_foundation" = list(
		"type" = /obj/Building/Foundation/Stone,
		"name" = "Stone Foundation",
		"category" = "foundation",
		"xp" = 15,
		"stamina" = 5,
		"rank_required" = 1,
		"tools_required" = list("hammer"),
		"resources_required" = list("stone" = 5),
		"description" = "Basic stone foundation for buildings"
	),
	
	"wooden_foundation" = list(
		"type" = /obj/Building/Foundation/Wood,
		"name" = "Wooden Foundation",
		"category" = "foundation",
		"xp" = 20,
		"stamina" = 6,
		"rank_required" = 2,
		"tools_required" = list("hammer"),
		"resources_required" = list("logs" = 3),
		"description" = "Sturdy wooden foundation"
	),
	
	// WALLS (Rank 2-4)
	"stone_wall" = list(
		"type" = /obj/Building/Wall/Stone,
		"name" = "Stone Wall",
		"category" = "wall",
		"xp" = 25,
		"stamina" = 8,
		"rank_required" = 2,
		"tools_required" = list("hammer"),
		"resources_required" = list("stone" = 10),
		"description" = "Solid stone wall structure"
	),
	
	"wooden_wall" = list(
		"type" = /obj/Building/Wall/Wood,
		"name" = "Wooden Wall",
		"category" = "wall",
		"xp" = 20,
		"stamina" = 7,
		"rank_required" = 1,
		"tools_required" = list("hammer"),
		"resources_required" = list("logs" = 5),
		"description" = "Basic wooden wall"
	),
	
	"reinforced_wall" = list(
		"type" = /obj/Building/Wall/Reinforced,
		"name" = "Reinforced Wall",
		"category" = "wall",
		"xp" = 35,
		"stamina" = 10,
		"rank_required" = 4,
		"tools_required" = list("hammer"),
		"resources_required" = list("stone" = 12, "metal" = 3),
		"description" = "Reinforced stone and metal wall"
	),
	
	// DOORS (Rank 3-5)
	"wooden_door" = list(
		"type" = /obj/Building/Door/Wood,
		"name" = "Wooden Door",
		"category" = "door",
		"xp" = 30,
		"stamina" = 10,
		"rank_required" = 3,
		"tools_required" = list("hammer"),
		"resources_required" = list("logs" = 8),
		"description" = "Basic wooden door with lock"
	),
	
	"metal_door" = list(
		"type" = /obj/Building/Door/Metal,
		"name" = "Metal Door",
		"category" = "door",
		"xp" = 40,
		"stamina" = 12,
		"rank_required" = 5,
		"tools_required" = list("hammer"),
		"resources_required" = list("metal" = 10),
		"description" = "Heavy metal security door"
	),
	
	// ROOFS (Rank 3-5)
	"wooden_roof" = list(
		"type" = /obj/Building/Roof/Wood,
		"name" = "Wooden Roof",
		"category" = "roof",
		"xp" = 35,
		"stamina" = 12,
		"rank_required" = 3,
		"tools_required" = list("hammer"),
		"resources_required" = list("logs" = 10),
		"description" = "Wooden pitched roof"
	),
	
	"stone_roof" = list(
		"type" = /obj/Building/Roof/Stone,
		"name" = "Stone Roof",
		"category" = "roof",
		"xp" = 45,
		"stamina" = 15,
		"rank_required" = 4,
		"tools_required" = list("hammer"),
		"resources_required" = list("stone" = 15),
		"description" = "Durable stone tile roof"
	),
	
	// STORAGE (Rank 2-4)
	"wooden_chest" = list(
		"type" = /obj/Building/Storage/WoodenChest,
		"name" = "Wooden Chest",
		"category" = "storage",
		"xp" = 20,
		"stamina" = 6,
		"rank_required" = 2,
		"tools_required" = list("hammer"),
		"resources_required" = list("logs" = 6),
		"description" = "Basic wooden storage chest"
	),
	
	"metal_locker" = list(
		"type" = /obj/Building/Storage/MetalLocker,
		"name" = "Metal Locker",
		"category" = "storage",
		"xp" = 30,
		"stamina" = 10,
		"rank_required" = 4,
		"tools_required" = list("hammer"),
		"resources_required" = list("metal" = 8),
		"description" = "Secure metal storage locker"
	),
	
	// CRAFTING STATIONS (Rank 3-5)
	"anvil" = list(
		"type" = /obj/Building/Crafting/Anvil,
		"name" = "Anvil",
		"category" = "crafting",
		"xp" = 40,
		"stamina" = 15,
		"rank_required" = 4,
		"tools_required" = list("hammer"),
		"resources_required" = list("metal" = 12, "stone" = 5),
		"description" = "Smithing anvil for metalwork"
	),
	
	"crafting_table" = list(
		"type" = /obj/Building/Crafting/CraftingTable,
		"name" = "Crafting Table",
		"category" = "crafting",
		"xp" = 25,
		"stamina" = 8,
		"rank_required" = 3,
		"tools_required" = list("hammer"),
		"resources_required" = list("logs" = 8),
		"description" = "General purpose crafting workbench"
	),
)
*/

// TODO: BUILDING_OBJECTS registry temporarily disabled due to undefined building type paths
// Re-enable when /obj/Building/* hierarchy is properly defined
var/global/list/BUILDING_OBJECTS = list()  // Placeholder - will be populated when building types are defined

// ==================== UTILITY PROCS ====================

proc/GetTerrainObjectByName(object_name)
	return TERRAIN_OBJECTS[object_name]

proc/GetBuildingObjectByName(object_name)
	return BUILDING_OBJECTS[object_name]

proc/GetTerrainObjectsByRank(rank, category = null)
	var/list/available = list()
	for(var/name in TERRAIN_OBJECTS)
		var/data = TERRAIN_OBJECTS[name]
		if(data["rank_required"] <= rank)
			if(!category || data["category"] == category)
				available[name] = data
	return available

proc/GetBuildingObjectsByRank(rank, category = null)
	var/list/available = list()
	for(var/name in BUILDING_OBJECTS)
		var/data = BUILDING_OBJECTS[name]
		if(data["rank_required"] <= rank)
			if(!category || data["category"] == category)
				available[name] = data
	return available

proc/CanPlayerCreateTerrainObject(mob/player, object_name)
	var/data = TERRAIN_OBJECTS[object_name]
	if(!data) return 0
	
	// Check rank
	// TODO: Fix rank system integration
	/*
	if(!player.GetRankLevel)
		return 0  // mob doesn't have modern rank system
	
	var/rank = player.GetRankLevel(RANK_DIGGING)
	if(rank < data["rank_required"]) return 0
	*/
	
	// Check stamina
	// TODO: Fix stamina system integration
	/*
	if(player.stamina != null)
		if(player.stamina < data["stamina"]) return 0
	*/
	
	// Check tools
	for(var/tool in data["tools_required"])
		if(!HasToolEquipped(player, tool))
			return 0
	
	// Check resources
	for(var/resource in data["resources_required"])
		if(!HasResourceInInventory(player, resource, data["resources_required"][resource]))
			return 0
	
	// Check deed permissions
	if(!CanPlayerBuildAtLocation(player, player.loc))
		return 0
	
	return 1

proc/CanPlayerCreateBuildingObject(mob/player, object_name)
	var/data = BUILDING_OBJECTS[object_name]
	if(!data) return 0
	
	// TODO: Fix rank system integration
	/*
	// Check rank
	if(!player.GetRankLevel)
		return 0  // mob doesn't have modern rank system
	
	var/rank = player.GetRankLevel(RANK_BUILDING)
	if(rank < data["rank_required"]) return 0
	*/
	
	// TODO: Fix stamina system integration
	/*
	// Check stamina
	if(player.stamina != null)
		if(player.stamina < data["stamina"]) return 0
	*/
	
	// Check resources
	for(var/resource in data["resources_required"])
		if(!HasResourceInInventory(player, resource, data["resources_required"][resource]))
			return 0
	
	// Check deed permissions
	if(!CanPlayerBuildAtLocation(player, player.loc))
		return 0
	
	return 1

proc/HasToolEquipped(mob/player, tool_name)
	switch(tool_name)
		if("shovel")
			return player.SHequipped == 1
		if("hammer")
			// Tool type check (actual type path defined in CentralizedEquipmentSystem.dm)
			return 1  // TODO: Verify hammer is equipped
		if("axe")
			// Tool type check (actual type path defined in CentralizedEquipmentSystem.dm)
			return 1  // TODO: Verify axe is equipped
		if("pickaxe")
			// Tool type check (actual type path defined in CentralizedEquipmentSystem.dm)
			return 1  // TODO: Verify pickaxe is equipped
	return 0

proc/HasResourceInInventory(mob/player, resource_name, quantity)
	// TODO: Fix item property integration (stack_amount vs amount)
	return 1  // Placeholder: assume player has resources

/*
	var/count = 0
	for(var/obj/items/item in player.contents)
		if(item.name == resource_name)
			// Try stack_amount first (modern items), then amount
			var/item_qty = item.stack_amount || item.amount || 1
			count += item_qty
			if(count >= quantity)
				return 1
	return 0
*/

proc/ConsumeResourceFromInventory(mob/player, resource_name, quantity)
	// TODO: Fix item property integration
	return 1  // Placeholder
/*
	var/consumed = 0
	for(var/obj/items/item in player.contents)
		if(item.name == resource_name)
			// Try stack_amount first (modern items), then amount
			var/item_qty = item.stack_amount || item.amount || 1
			var/take = min(quantity - consumed, item_qty)
			
			// Try RemoveFromStack first, then reduce amount manually
			if(item.RemoveFromStack)
				item.RemoveFromStack(take)
			else if(item.stack_amount)
				item.stack_amount -= take
				if(item.stack_amount <= 0)
					del(item)
			else if(item.amount)
				item.amount -= take
				if(item.amount <= 0)
					del(item)
			else
				del(item)
			
			consumed += take
			if(consumed >= quantity)
				return 1
	return 0
*/

proc/ApplyTerrainObjectCosts(mob/player, object_name)
	// TODO: Fix stamina and rank system integration
	return 1  // Placeholder
/*
	var/data = TERRAIN_OBJECTS[object_name]
	if(!data) return 0
	
	// Consume resources
	for(var/resource in data["resources_required"])
		ConsumeResourceFromInventory(player, resource, data["resources_required"][resource])
	
	// Apply stamina cost
	if(player.stamina != null)
		player.stamina -= data["stamina"]
		if(player.updateST)
			player.updateST()
	
	// Award XP
	if(player.character && player.character.UpdateRankExp)
		player.character.UpdateRankExp(RANK_DIGGING, data["xp"])
	
	if(player.updateDXP)
		player.updateDXP()
	
	return 1
*/

proc/ApplyBuildingObjectCosts(mob/player, object_name)
	// TODO: Fix stamina and rank system integration
	return 1  // Placeholder
/*
	var/data = BUILDING_OBJECTS[object_name]
	if(!data) return 0
	
	// Consume resources
	for(var/resource in data["resources_required"])
		ConsumeResourceFromInventory(player, resource, data["resources_required"][resource])
	
	// Apply stamina cost
	if(player.stamina != null)
		player.stamina -= data["stamina"]
		if(player.updateST)
			player.updateST()
	
	// Award XP
	if(player.character && player.character.UpdateRankExp)
		player.character.UpdateRankExp(RANK_BUILDING, data["xp"])
	
	if(player.updateDXP)
		player.updateDXP()
	
	return 1
*/
