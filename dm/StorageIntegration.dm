// ============================================================================
// FILE: StorageIntegration.dm
// PURPOSE: Storage and container system enhancements
// DESCRIPTION: Helpers for filtering items for storage in containers
// ============================================================================

// ============================================================================
// STORAGE FILTERING
// ============================================================================

proc/GetStorableItems(mob/player)
	/// Get items that can be stored in a container
	if(!player) return list()
	
	var/list/storable = list()
	
	for(var/item in player.contents)
		var/obj/test = item
		if(!test) continue
		
		var/type_str = "[test.type]"
		
		// Can't store containers in containers (prevents nesting issues)
		if(findtext(type_str, "Container") || findtext(type_str, "Jar") || findtext(type_str, "Bag"))
			continue
		
		// Can't store deed objects
		if(findtext(type_str, "Deed"))
			continue
		
		// Can store most everything else
		storable += item
	
	return storable

proc/IsStorable(obj/item)
	/// Check if a single item can be stored
	if(!item) return 0
	
	var/type_str = "[item.type]"
	
	// Exclude container types and special items
	if(findtext(type_str, "Container") || findtext(type_str, "Jar") || findtext(type_str, "Bag"))
		return 0
	if(findtext(type_str, "Deed"))
		return 0
	
	return 1

// ============================================================================
// CONTAINER IMPROVEMENTS
// ============================================================================

obj/items/tools/Containers/proc/GetContents()
	/// Get items stored in this container
	set hidden = 1
	
	var/list/contents = list()
	for(var/item in src:contents)
		contents += item
	
	return contents

obj/items/tools/Containers/proc/ShowContents(mob/viewer)
	/// Show container contents to player
	if(!viewer) return
	
	var/list/contents = src.GetContents()
	
	var/html = "<div style='border: 1px solid brown;'>"
	html += "<h3>[src.name]</h3>"
	
	if(!contents.len)
		html += "<i>Empty</i>"
	else
		html += "[contents.len] item(s):<br><ul>"
		for(var/item in contents)
			var/obj/contained = item
			if(contained)
				html += "<li>[contained:name]</li>"
		html += "</ul>"
	
	html += "</div>"
	viewer << html

obj/items/tools/Containers/proc/StoreItem(obj/item)
	/// Store an item in this container
	if(!item) return 0
	
	// Check if item is storable
	if(!IsStorable(item))
		return 0
	
	// Move item into container
	item.loc = src
	return 1

obj/items/tools/Containers/proc/RemoveItem(obj/item, mob/player)
	/// Remove an item from container to player
	if(!item || !player) return 0
	
	if(!(item in src:contents))
		return 0
	
	item.loc = player
	return 1

// ============================================================================
// CONTAINER UI IMPROVEMENTS
// ============================================================================

mob/proc/SelectStorableItem()
	/// Select an item to store in container
	set hidden = 1
	
	var/list/storable = GetStorableItems(src)
	
	if(!storable.len)
		src << "You have nothing to store."
		return null
	
	var/selection = input(src, "Select item to store:", "Storage") as null|anything in storable
	return selection

mob/verb
	store_item_in_container()
		set category = "Objects"
		set hidden = 1
		
		// Select target container
		var/obj/items/tools/Containers/target = input(src, "Store in which container?") as obj in (src.contents)
		if(!target)
			return
		
		if(!istype(target, /obj/items/tools/Containers))
			src << "That's not a container."
			return
		
		// Select item to store
		var/item = SelectStorableItem()
		if(!item)
			return
		
		var/obj/to_store = item
		if(!to_store)
			return
		
		// Try to store
		if(target.StoreItem(to_store))
			src << "Stored [to_store:name] in [target:name]."
		else
			src << "Could not store [to_store:name]."
	
	remove_item_from_container()
		set category = "Objects"
		set hidden = 1
		
		// Select source container
		var/obj/items/tools/Containers/source = input(src, "Remove from which container?") as obj in (src.contents)
		if(!source)
			return
		
		if(!istype(source, /obj/items/tools/Containers))
			src << "That's not a container."
			return
		
		var/list/contents = source.GetContents()
		if(!contents.len)
			src << "[source:name] is empty."
			return
		
		// Select item to remove
		var/item = input(src, "Remove which item?", "Storage") as null|anything in contents
		if(!item)
			return
		
		var/obj/to_remove = item
		if(!to_remove)
			return
		
		// Try to remove
		if(source.RemoveItem(to_remove, src))
			src << "Removed [to_remove:name] from [source:name]."
		else
			src << "Could not remove [to_remove:name]."
	
	view_container_contents()
		set category = "Objects"
		set hidden = 1
		
		// Select container to view
		var/obj/items/tools/Containers/target = input(src, "View which container?") as obj in (src.contents)
		if(!target)
			return
		
		if(!istype(target, /obj/items/tools/Containers))
			src << "That's not a container."
			return
		
		target.ShowContents(src)

// ============================================================================
// ADVANCED: ORGANIZED STORAGE
// ============================================================================

mob/proc/GetStorageItemsByType(container_type)
	/// Get storable items filtered by type
	set hidden = 1
	
	var/list/result = list()
	
	switch(container_type)
		if("weapons")
			for(var/item in GetStorableItems(src))
				if(findtext("[item:type]", "Sword") || findtext("[item:type]", "Axe"))
					result += item
		
		if("resources")
			for(var/item in GetStorableItems(src))
				var/type_str = "[item:type]"
				if(findtext(type_str, "Ore") || findtext(type_str, "Log") || findtext(type_str, "Plant"))
					result += item
		
		if("armor")
			for(var/item in GetStorableItems(src))
				if(findtext("[item:type]", "Armor") || findtext("[item:type]", "Helmet"))
					result += item
		
		else
			result = GetStorableItems(src)
	
	return result

// ============================================================================
// INTEGRATION NOTES
// ============================================================================

/*
These storage helpers provide:

1. STORABLE FILTERING:
   - GetStorableItems(player) - Get all storable items
   - IsStorable(item) - Check single item
   - Excludes containers (no nesting) and deeds

2. CONTAINER OPERATIONS:
   - StoreItem(item) - Put item in container
   - RemoveItem(item, player) - Take item out
   - GetContents() - List what's inside
   - ShowContents(player) - Display to player

3. STORAGE VERBS:
   - store_item_in_container() - Interactive storage
   - remove_item_from_container() - Interactive removal
   - view_container_contents() - Browse container
   - All use filtering to show only valid items

4. ADVANCED:
   - GetStorageItemsByType() - Organize by category
   - Easy to extend for other container types

All functions integrate with FilteringLibrary.dm
and work with /obj/items/tools/Containers hierarchy
*/