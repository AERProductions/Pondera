/**
 * EXTENDED HUD SUBSYSTEMS - Step 3 Full Implementation
 * Additional HUD panels for inventory, customization, skills, deeds, and market
 * Integrated with PonderaHUDSystem as expandable subsystems
 */

//============================================================
// INVENTORY HUD SUBSYSTEM
//============================================================

/datum/InventoryPanel
	parent_type = /HudGroup
	
	layer = MOB_LAYER + 5
	
	var
		mob/owner
		HudObject/inventory_title
		list/inventory_slots = list()  // 20 inventory slot objects
		HudObject/close_button
		
		selected_slot = 0

	New(mob/m)
		..()
		owner = m
		icon = 'dmi/64/char.dmi'
		
		// Title bar
		inventory_title = add(0, 0, icon_state = null)
		inventory_title.set_maptext("<b>Inventory</b> (0/20 items)", 256, 16)
		
		// Create 20 inventory slots in 4x5 grid
		var/slot_num = 0
		for(var/row in 0 to 3)
			for(var/col in 0 to 4)
				slot_num++
				var/x_pos = col * 48
				var/y_pos = 24 + (row * 48)
				var/HudObject/slot = add(x_pos, y_pos, icon_state = "inventory_slot", value = slot_num)
				inventory_slots += slot
		
		// Close button
		close_button = add(240, 0, icon_state = "btn_close", value = "close")
		
		// Hide initially
		hide()

	proc
		show_inventory()
			visible = 1
			show()
			update_inventory_display()
			owner << "\blue Inventory opened"

		hide_inventory()
			visible = 0
			hide()
			owner << "\blue Inventory closed"

		update_inventory_display()
			if(!owner) return
			
			// TODO: Count items in player inventory
			// Update title with item count
			inventory_title.set_maptext("<b>Inventory</b> (0/20 items)", 256, 16)

	Click(HudObject/object)
		if(object.value == "close")
			hide_inventory()
			return
		
		// Slot click handling
		var/slot = object.value
		if(slot >= 1 && slot <= 20)
			selected_slot = slot
			owner << "\blue Clicked inventory slot [slot]"

//============================================================
// CHARACTER CUSTOMIZATION HUD SUBSYSTEM
//============================================================

/datum/CustomizationPanel
	parent_type = /HudGroup
	
	layer = MOB_LAYER + 5
	
	var
		mob/owner
		HudObject/avatar_preview
		HudObject/name_label
		HudObject/appearance_button
		HudObject/color_button
		HudObject/confirm_button
		HudObject/cancel_button
		
		preview_icon = 'dmi/64/char.dmi'
		preview_color = rgb(255, 255, 255)

	New(mob/m)
		..()
		owner = m
		icon = 'dmi/64/char.dmi'
		
		// Large avatar preview (64x64)
		avatar_preview = add(50, 50, icon_state = "friar")
		avatar_preview.size(2, 2)
		
		// Character name
		name_label = add(20, 30, icon_state = null)
		name_label.set_maptext("<b>[owner.name]</b>", 128, 16)
		
		// Customization buttons
		appearance_button = add(10, 140, icon_state = "btn_appearance", value = "appearance")
		color_button = add(70, 140, icon_state = "btn_color", value = "color")
		confirm_button = add(130, 140, icon_state = "btn_confirm", value = "confirm")
		cancel_button = add(190, 140, icon_state = "btn_cancel", value = "cancel")
		
		// Hide initially
		hide()

	proc
		show_customization()
			visible = 1
			show()
			owner << "\blue Character customization opened"

		hide_customization()
			visible = 0
			hide()

	Click(HudObject/object)
		switch(object.value)
			if("appearance")
				owner << "\yellow Select new appearance (placeholder)"
			if("color")
				owner << "\yellow Select new color (placeholder)"
			if("confirm")
				owner << "\green Customization saved!"
				hide_customization()
			if("cancel")
				hide_customization()

//============================================================
// SKILLS/RANKS HUD SUBSYSTEM
//============================================================

/datum/SkillsPanel
	parent_type = /HudGroup
	
	layer = MOB_LAYER + 5
	
	var
		mob/owner
		HudObject/skills_title
		list/skill_displays = list()  // Rank displays
		HudObject/close_button
		
		list/skills_to_display = list(
			"Fishing" = "frank",
			"Crafting" = "crank",
			"Mining" = "mrank",
			"Smithing" = "smirank",
			"Building" = "brank",
			"Gardening" = "grank",
			"Woodcutting" = "wrank"
		)

	New(mob/m)
		..()
		owner = m
		icon = 'dmi/64/char.dmi'
		
		// Title
		skills_title = add(0, 0, icon_state = null)
		skills_title.set_maptext("<b>Skills & Ranks</b>", 256, 16)
		
		// Create skill displays (one per row)
		var/row_num = 0
		for(var/skill_name in skills_to_display)
			var/y_pos = 24 + (row_num * 32)
			var/HudObject/skill_display = add(10, y_pos, icon_state = null)
			skill_displays += skill_display
			row_num++
		
		// Close button
		close_button = add(240, 0, icon_state = "btn_close", value = "close")
		
		// Hide initially
		hide()

	proc
		show_skills()
			visible = 1
			show()
			update_skills_display()
			owner << "\blue Skills panel opened"

		hide_skills()
			visible = 0
			hide()

		update_skills_display()
			if(!owner) return
			
			var/row_num = 0
			for(var/skill_name in skills_to_display)
				var/rank_var = skills_to_display[skill_name]
				var/rank = 1
				
				// TODO: Get rank from character data via owner.character datum
				
				var/HudObject/display = skill_displays[++row_num]
				if(display)
					display.set_maptext("[skill_name] - Level [rank]", 256, 24)

	Click(HudObject/object)
		if(object.value == "close")
			hide_skills()

//============================================================
// DEEDS INFO HUD SUBSYSTEM
//============================================================

/datum/DeedsPanel
	parent_type = /HudGroup
	
	layer = MOB_LAYER + 5
	
	var
		mob/owner
		HudObject/deeds_title
		HudObject/deed_info_display
		HudObject/maintenance_label
		HudObject/permissions_label
		HudObject/close_button

	New(mob/m)
		..()
		owner = m
		icon = 'dmi/64/char.dmi'
		
		// Title
		deeds_title = add(0, 0, icon_state = null)
		deeds_title.set_maptext("<b>Territory Deeds</b>", 256, 16)
		
		// Deed info display
		deed_info_display = add(10, 30, icon_state = null)
		deed_info_display.set_maptext("No active deeds", 256, 64)
		
		// Maintenance info
		maintenance_label = add(10, 110, icon_state = null)
		maintenance_label.set_maptext("Maintenance: N/A", 256, 16)
		
		// Permissions info
		permissions_label = add(10, 130, icon_state = null)
		permissions_label.set_maptext("Build: N/A | Pickup: N/A | Drop: N/A", 256, 16)
		
		// Close button
		close_button = add(240, 0, icon_state = "btn_close", value = "close")
		
		// Hide initially
		hide()

	proc
		show_deeds()
			visible = 1
			show()
			update_deeds_display()
			owner << "\blue Deeds panel opened"

		hide_deeds()
			visible = 0
			hide()

		update_deeds_display()
			if(!owner) return
			
			// Check for player deeds
			var/deed_count = 0
			var/deed_info = ""
			var/total_maintenance = 0
			
			// TODO: Pull from actual deed system
			// For now, show placeholder
			if(deed_count == 0)
				deed_info = "You do not own any territory deeds."
			
			deed_info_display.set_maptext(deed_info, 256, 64)
			maintenance_label.set_maptext("Monthly Maintenance: [total_maintenance]g", 256, 16)

	Click(HudObject/object)
		if(object.value == "close")
			hide_deeds()

//============================================================
// MARKET STALL HUD SUBSYSTEM
//============================================================

/datum/MarketPanel
	parent_type = /HudGroup
	
	layer = MOB_LAYER + 5
	
	var
		mob/owner
		HudObject/market_title
		HudObject/price_display
		HudObject/buy_button
		HudObject/sell_button
		HudObject/close_button
		
		current_item = null
		current_price = 0

	New(mob/m)
		..()
		owner = m
		icon = 'dmi/64/char.dmi'
		
		// Title
		market_title = add(0, 0, icon_state = null)
		market_title.set_maptext("<b>Market Board</b>", 256, 16)
		
		// Price display
		price_display = add(10, 30, icon_state = null)
		price_display.set_maptext("Select an item to trade", 256, 32)
		
		// Trading buttons
		buy_button = add(10, 80, icon_state = "btn_buy", value = "buy")
		sell_button = add(70, 80, icon_state = "btn_sell", value = "sell")
		close_button = add(240, 0, icon_state = "btn_close", value = "close")
		
		// Hide initially
		hide()

	proc
		show_market()
			visible = 1
			show()
			owner << "\blue Market board opened"

		hide_market()
			visible = 0
			hide()

		set_item_display(item_name, price)
			current_item = item_name
			current_price = price
			price_display.set_maptext("[item_name]\n\nPrice: [price]g", 256, 64)

	Click(HudObject/object)
		switch(object.value)
			if("buy")
				if(current_item)
					owner << "\yellow Attempting to buy [current_item]..."
			if("sell")
				if(current_item)
					owner << "\yellow Attempting to sell [current_item]..."
			if("close")
				hide_market()

//============================================================
// EXTENDED HUD MASTER - Manages all extended subsystems
//============================================================

/datum/ExtendedHUDManager
	var
		mob/owner
		datum/InventoryPanel/inventory
		datum/CustomizationPanel/customization
		datum/SkillsPanel/skills
		datum/DeedsPanel/deeds
		datum/MarketPanel/market
		datum/ToolbeltHUD/toolbelt_hud

	New(mob/m)
		owner = m
		
		// Instantiate all extended panels - pass mob, HudGroup will extract client
		if(!m || !m.client) return
		
		inventory = new(m)
		inventory.owner = m
		
		customization = new(m)
		customization.owner = m
		
		skills = new(m)
		skills.owner = m
		
		deeds = new(m)
		deeds.owner = m
		
		market = new(m)
		market.owner = m
		
		// Instantiate toolbelt HUD (persistent element, always visible)
		toolbelt_hud = new(m)
		toolbelt_hud.owner = m
		toolbelt_hud.pos(0, 0)  // Bottom center of screen
		toolbelt_hud.show_toolbelt()

	proc
		show_inventory()
			if(inventory) inventory.show_inventory()

		show_customization()
			if(customization) customization.show_customization()

		show_skills()
			if(skills) skills.show_skills()

		show_deeds()
			if(deeds) deeds.show_deeds()

		show_market()
			if(market) market.show_market()

		update_all()
			if(inventory) inventory.update_inventory_display()
			if(skills) skills.update_skills_display()
			if(deeds) deeds.update_deeds_display()
			if(toolbelt_hud) toolbelt_hud.update_hotbar_display()
			if(toolbelt_hud) toolbelt_hud.update_stamina_warning()

		update_toolbelt_display()
			if(toolbelt_hud)
				toolbelt_hud.update_hotbar_display()

		update_toolbelt_mode(mode_name)
			if(toolbelt_hud)
				toolbelt_hud.update_mode_display(mode_name)

		hide_all()
			if(inventory) inventory.hide_inventory()
			if(customization) customization.hide_customization()
			if(skills) skills.hide_skills()
			if(deeds) deeds.hide_deeds()
			if(market) market.hide_market()
			// Note: toolbelt_hud stays visible (persistent)

//============================================================
// TOOLBELT HOTBAR HUD SUBSYSTEM
//============================================================

/datum/ToolbeltHUD
	parent_type = /HudGroup
	
	layer = MOB_LAYER + 5
	
	var
		mob/owner
		list/slot_icons = list()  // 9 tool slot icons
		HudObject/current_mode_label
		HudObject/active_slot_indicator
		HudObject/stamina_warning
		
		active_slot = 0

	New(mob/m)
		..()
		owner = m
		icon = 'dmi/64/char.dmi'
		visible = 1  // Always visible (persistent HUD element)
		
		// Create hotbar slots based on current toolbelt max_slots (starts at 2, +2 per tier)
		var/max_slots = 2  // Default min; will be synced on first update
		if(owner:toolbelt)
			max_slots = owner:toolbelt:max_slots || 2
		
		for(var/slot_num = 1 to max_slots)
			var/x_pos = 32 + ((slot_num - 1) * 40)  // 40 pixels per slot
			var/HudObject/slot = add(x_pos, 0, icon_state = "hotbar_slot", value = slot_num)
			slot_icons += slot
		
		// Current mode label
		current_mode_label = add(400, 0, icon_state = null)
		current_mode_label.set_maptext("No tool equipped", 128, 16)
		
		// Active slot indicator (shows which slot is currently active)
		active_slot_indicator = add(32, -8, icon_state = "hotbar_active")
		
		// Stamina warning (shows when stamina is low for current tool mode)
		stamina_warning = add(400, 16, icon_state = null)
		stamina_warning.set_maptext("Stamina: Full", 128, 12)

	proc
		show_toolbelt()
			visible = 1
			show()

		hide_toolbelt()
			visible = 0
			hide()

		update_hotbar_display()
			if(!owner) return
			
			// Try to access toolbelt - use dynamic var access to avoid type checking issues
			var/tb = owner:toolbelt
			if(!tb) return
			
			// Update each slot with current item
			var/max_slots = tb:max_slots || 2
			for(var/slot_num = 1 to max_slots)
				var/obj/item = tb:GetSlot(slot_num)
				var/HudObject/slot = slot_icons[slot_num]
				
				if(slot)
					if(item)
						// Show item icon/name
						slot.set_maptext("[slot_num]:<br/>[item.name]", 32, 32)
					else
						// Show empty slot
						slot.set_maptext("[slot_num]:<br/>-", 32, 32)
				
				// Highlight active slot
				var/current_slot = tb:current_slot || 0
				if(slot_num == current_slot && slot_num <= slot_icons.len)
					active_slot = slot_num
					if(active_slot_indicator)
						active_slot_indicator.loc = owner
						// Move indicator under active slot
						var/x_pos = 32 + ((slot_num - 1) * 40)
						active_slot_indicator.screen_loc = "[x_pos],0"

		update_mode_display(mode_name)
			if(!mode_name || mode_name == "")
				current_mode_label.set_maptext("No tool equipped", 128, 16)
			else
				// Capitalize first letter of mode
				var/capitalized = uppertext(copytext(mode_name, 1, 2)) + copytext(mode_name, 2)
				current_mode_label.set_maptext("Mode: [capitalized]", 128, 16)

		update_stamina_warning()
			if(!owner) return
			
			// Use dynamic var access to avoid compile-time type issues
			var/stamina = owner:stamina || 100
			var/max_stamina = owner:MAXstamina || 100
			var/stamina_pct = round((stamina / max_stamina) * 100)
			
			var/color = "green"
			if(stamina_pct < 50)
				color = "orange"
			if(stamina_pct < 25)
				color = "red"
			
			stamina_warning.set_maptext("<font color=[color]>Stamina: [stamina_pct]%</font>", 128, 12)

	Click(HudObject/object)
		if(!owner) return
		
		var/tb = owner:toolbelt
		if(!tb) return
		
		var/slot_num = object.value
		var/max_slots = tb:max_slots || 2
		if(slot_num >= 1 && slot_num <= max_slots)
			// Activate tool in this slot
			if(tb:ActivateTool(slot_num))
				update_hotbar_display()
				var/mode = tb:active_mode || "None"
				update_mode_display(mode)
				owner << "<cyan>Tool [slot_num] activated</cyan>"
			else
				owner << "<red>Failed to activate tool in slot [slot_num]</red>"
