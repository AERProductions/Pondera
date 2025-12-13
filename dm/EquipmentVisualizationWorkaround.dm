// EquipmentVisualizationWorkaround.dm - Dynamic Equipment Visualization Without Custom DMI
// Implements immediate equipment overlay rendering using existing icon assets
// Bridges gap until weapon-specific DMI files are created
// Integrates with EquipmentOverlaySystem.dm framework

// ============================================================================
// MOB VARIABLES - Equipment visualization storage
// ============================================================================

/mob/var
	list/equipped_item_visuals = list()  // Stores overlay images by slot

// ============================================================================
// INITIALIZATION
// ============================================================================

/proc/InitializeEquipmentVisualization()
	/**
	 * InitializeEquipmentVisualization()
	 * Initialize equipment visualization system
	 * Called from InitializationManager.dm during infrastructure phase
	 */
	world.log << "EQUIPMENT_VIS: Visualization system initialized"

// ============================================================================
// EQUIPMENT VISUAL PROPERTIES
// ============================================================================

/proc/GetEquipmentVisual(item_type)
	/**
	 * GetEquipmentVisual(item_type)
	 * Get visual properties for an item type
	 * Returns list[icon_state, scale, offset_x, offset_y] or null
	 */
	switch(item_type)
		// TOOLS - Reuse existing tool icons
		if(/obj/items/tools)
			return list("item", 1.0, 0, 1)
		
		// ARMOR
		if(/obj/items/armors)
			return list("item", 1.1, 0, 0)
		
		// SHIELDS
		if(/obj/items/shields)
			return list("item", 0.9, 4, -1)
		
		else
			// Generic fallback
			return list("item", 0.8, 0, 0)

// ============================================================================
// OVERLAY CREATION
// ============================================================================

/proc/CreateEquipmentOverlay(mob/M, obj/item, direction = NORTH)
	/**
	 * CreateEquipmentOverlay(mob/M, obj/item, direction)
	 * Create visual overlay for equipped item
	 * 
	 * Returns: Image object or null if failed
	 */
	if(!M || !item) return null
	
	var/list/vis_data = GetEquipmentVisual(item.type)
	if(!vis_data) return null
	
	var/icon_state = vis_data[1]
	var/scale = vis_data[2]
	var/offset_x = vis_data[3]
	var/offset_y = vis_data[4]
	
	// Create image from item's icon
	var/image/overlay = image(item.icon, M, icon_state)
	overlay.layer = M.layer + 5
	overlay.pixel_x = offset_x
	overlay.pixel_y = round(offset_y * scale)
	
	return overlay

// ============================================================================
// MOB EQUIPMENT VISUALIZATION INTERFACE
// ============================================================================

/mob/proc/VisualizeEquippedItem(obj/item, slot_name = "hand")
	/**
	 * VisualizeEquippedItem(obj/item, slot_name)
	 * Attach visual representation of equipped item to mob
	 */
	if(!item) return
	
	if(!src.equipped_item_visuals)
		src.equipped_item_visuals = list()
	
	// Remove old visual if exists
	if(src.equipped_item_visuals[slot_name])
		var/image/old_overlay = src.equipped_item_visuals[slot_name]
		src.overlays -= old_overlay
	
	// Create new visual
	var/image/new_overlay = CreateEquipmentOverlay(src, item, src.dir)
	if(new_overlay)
		src.overlays += new_overlay
		src.equipped_item_visuals[slot_name] = new_overlay
		world.log << "EQUIPMENT_VIS: [src.name] equipped [item.name]"

/mob/proc/RemoveEquipmentVisualization(slot_name = "hand")
	/**
	 * RemoveEquipmentVisualization(slot_name)
	 * Remove visual representation of unequipped item
	 */
	if(!src.equipped_item_visuals) return
	
	var/image/overlay = src.equipped_item_visuals[slot_name]
	if(overlay)
		src.overlays -= overlay
		src.equipped_item_visuals.Remove(slot_name)
		world.log << "EQUIPMENT_VIS: [src.name] unequipped (slot: [slot_name])"

/mob/proc/ClearAllEquipmentVisuals()
	/**
	 * ClearAllEquipmentVisuals()
	 * Remove all equipment visualizations
	 */
	if(!src.equipped_item_visuals) return
	
	for(var/slot_name in src.equipped_item_visuals)
		RemoveEquipmentVisualization(slot_name)
	
	src.equipped_item_visuals = list()

// ============================================================================
// EQUIPMENT SYSTEM INTEGRATION HELPERS
// ============================================================================

/proc/EquipItemWithVisualization(mob/player, obj/item/weapon)
	/**
	 * EquipItemWithVisualization(mob/player, obj/item/weapon)
	 * Helper for equipping item with visualization
	 */
	if(!player || !weapon) return
	
	weapon.suffix = "Equipped"
	player.VisualizeEquippedItem(weapon, "hand")
	world.log << "EQUIPMENT_VIS: [player.name] equipped [weapon.name]"

/proc/UnequipItemWithVisualization(mob/player, obj/item/weapon)
	/**
	 * UnequipItemWithVisualization(mob/player, obj/item/weapon)
	 * Helper for unequipping item with visualization
	 */
	if(!player || !weapon) return
	
	weapon.suffix = ""
	player.RemoveEquipmentVisualization("hand")
	world.log << "EQUIPMENT_VIS: [player.name] unequipped [weapon.name]"

