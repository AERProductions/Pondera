/// ToolDurabilityPersistence.dm
/// Handles saving and loading tool durability data with player savefiles
/// Integrates with SavingChars.dm load/save procedures
/// 
/// System:
/// - Tools don't stack (1 per inventory slot)
/// - Durability stored per item in inventory
/// - Saved when player logs out
/// - Loaded when player logs in
/// - Broken tools remain in inventory as decoration (can be repaired or discarded)

// Extension: Save tool durability to inventory items
mob/players
	proc/SaveToolDurability()
		/// Called before character save - stores durability for all tools in inventory
		/// Tools with durability have max_durability > 0
		
		if(!contents) return
		
		for(var/obj/items/equipment/item in contents)
			if(!item.max_durability || item.max_durability <= 0)
				continue  // Item has no durability tracking
			
			// Store current durability on the item itself (binary saves include all vars)
			item.current_durability = max(0, min(item.current_durability, item.max_durability))
	
	proc/LoadToolDurability()
		/// Called after character load - restores durability for tools
		/// Items already have durability vars from savefile
		
		if(!contents) return
		
		for(var/obj/items/equipment/item in contents)
			if(!item.max_durability || item.max_durability <= 0)
				continue  // Item has no durability tracking
			
			// Validate durability bounds
			if(item.current_durability > item.max_durability)
				item.current_durability = item.max_durability
			else if(item.current_durability < 0)
				item.current_durability = 0
			
			// Log tool state if broken
			if(item.IsBroken())
				world.log << "\[DURABILITY\] [key] loaded broken [item.name] (0/[item.max_durability])"
	
	proc/ListToolConditions()
		/// Debug: Print condition of all tools in inventory
		/// Format: [Tool Name]: XX% durability (broken/worn/good)
		
		if(!contents) return
		
		src << "<b>Tool Inventory Status:</b>"
		var/tools_found = 0
		
		for(var/obj/items/equipment/item in contents)
			if(!item.max_durability || item.max_durability <= 0)
				continue
			
			tools_found++
			var/percent = item.GetDurabilityPercent()
			var/status = "good"
			
			if(item.IsBroken())
				status = "<red>BROKEN</red>"
			else if(item.IsFragile())
				status = "<orange>worn</orange>"
			else if(percent < 75)
				status = "<yellow>used</yellow>"
			
			src << "  [item.name]: [percent]% ([status])"
		
		if(tools_found == 0)
			src << "  <gray>No tools in inventory</gray>"

// Integration hooks: Call from SavingChars.dm during save/load sequences
/proc/OnPlayerSaveCharacter(mob/players/M)
	/// Called by SavingChars.dm before saving character file
	/// Purpose: Prepare durability data for savefile
	
	if(!M) return
	
	// Save tool durability before character serialization
	M.SaveToolDurability()

/proc/OnPlayerLoadCharacter(mob/players/M)
	/// Called by SavingChars.dm after loading character file
	/// Purpose: Restore durability data from savefile
	
	if(!M) return
	
	// Load tool durability after character deserialization
	M.LoadToolDurability()
	
	// Optional: Log tool conditions to server for diagnostics
	// M.ListToolConditions()

// TODO: Integration points needed in SavingChars.dm:
// 1. Add call to OnPlayerSaveCharacter(M) before F << M  (character save)
// 2. Add call to OnPlayerLoadCharacter(M) after F >> M  (character load)
// 3. Bump SavefileVersioning.dm version when deployed
