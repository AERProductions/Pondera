/**
 * PONDERA COMPREHENSIVE HUD SYSTEM
 * 
 * Three-Continent Hub Design with Full Feature HUD
 * Uses HudGroups library for professional UI management
 * 
 * Simplified approach: Gracefully handles missing player vars
 */

//============================================================
// STATUS BARS - Health, Stamina, Hunger Display (8-segment bars)
//============================================================

StatusBars
	parent_type = /HudGroup
	
	layer = MOB_LAYER + 5
	
	var
		list/HudObject/health_segments = list()
		list/HudObject/stamina_segments = list()
		list/HudObject/hunger_segments = list()
		
		mob/owner

	New(mob/m)
		..()
		owner = m
		icon = 'dmi/64/char.dmi'
		
		// Create labels
		add(0, 112, icon_state = "health_label", text = "HP")
		add(0, 96, icon_state = "stamina_label", text = "STM")
		add(0, 80, icon_state = "hunger_label", text = "HUN")
		
		// Create health segments (8 segments = 100% health)
		for(var/i = 1 to 8)
			var/HudObject/h = add(i * 12, 112, icon_state = "health_segment")
			health_segments += h
		
		// Create stamina segments
		for(var/i = 1 to 8)
			var/HudObject/s = add(i * 12, 96, icon_state = "stamina_segment")
			stamina_segments += s
		
		// Create hunger segments
		for(var/i = 1 to 8)
			var/HudObject/h = add(i * 12, 80, icon_state = "hunger_segment")
			hunger_segments += h

	proc
		update_health(current, maximum)
			if(maximum <= 0) maximum = 100
			if(current > maximum) current = maximum
			var/segments_full = round((current / maximum) * 8)
			
			for(var/i = 1 to 8)
				var/HudObject/seg = health_segments[i]
				if(i <= segments_full)
					seg.icon_state = "health_segment"
				else
					seg.icon_state = "health_empty"

		update_stamina(current, maximum)
			if(maximum <= 0) maximum = 100
			if(current > maximum) current = maximum
			var/segments_full = round((current / maximum) * 8)
			
			for(var/i = 1 to 8)
				var/HudObject/seg = stamina_segments[i]
				seg.icon_state = (i <= segments_full) ? "stamina_segment" : "stamina_empty"

		update_hunger(current, maximum)
			if(maximum <= 0) maximum = 100
			if(current > maximum) current = maximum
			var/segments_full = round((current / maximum) * 8)
			
			for(var/i = 1 to 8)
				var/HudObject/seg = hunger_segments[i]
				seg.icon_state = (i <= segments_full) ? "hunger_segment" : "hunger_empty"


//============================================================
// CHARACTER PANEL - Avatar, Name, Level, Rank Display
//============================================================

CharacterPanel
	parent_type = /HudGroup
	
	layer = MOB_LAYER + 5
	
	var
		mob/owner
		HudObject/avatar
		HudObject/name_label
		HudObject/level_label
		HudObject/rank_label

	New(mob/m)
		..()
		owner = m
		icon = 'dmi/64/char.dmi'
		
		// Avatar display (32x32)
		avatar = add(0, 0, icon_state = "character_avatar")
		
		// Character name
		name_label = add(40, 0, text = "[m.name]")
		name_label.set_maptext("[m.name]", 96, 16)
		
		// Level display
		level_label = add(40, 16, text = "Lvl 1")
		level_label.set_maptext("Level 1", 96, 16)
		
		// Rank tier display
		rank_label = add(40, 32, text = "Rank 1")
		rank_label.set_maptext("Rank Tier 1", 96, 16)

	proc
		update_character_info()
			if(!owner) return
			name_label.set_maptext("[owner.name]", 96, 16)


//============================================================
// CONTINENT SELECTOR - Three Buttons with Modal Info
//============================================================

ContinentSelector
	parent_type = /HudGroup
	
	layer = MOB_LAYER + 5
	
	var
		mob/owner
		HudObject/story_button
		HudObject/sandbox_button
		HudObject/pvp_button
		HudObject/modal_background
		HudObject/modal_text
		HudObject/active_continent_indicator
		
		current_modal = null  // "story", "sandbox", or "pvp"
		current_continent = "story"
		
		list/continent_info = list(
			"story" = list(
				"name" = "Kingdom of Freedom",
				"desc" = "Procedural towns, NPCs, quests, PvE progression. Non-tradable Lucre currency.",
				"rules" = "PvE | Building Allowed | No Stealing"
			),
			"sandbox" = list(
				"name" = "Creative Sandbox",
				"desc" = "Peaceful creative building, all recipes unlocked. No pressure or survival needs.",
				"rules" = "Peaceful | Creative | Hunger Disabled"
			),
			"pvp" = list(
				"name" = "Battlelands",
				"desc" = "Competitive survival, raiding, permadeath risk, territory wars. Tradable materials.",
				"rules" = "PvP | Raiding | Territory Wars"
			)
		)

	New(mob/m)
		..()
		owner = m
		icon = 'dmi/64/char.dmi'
		
		// Three continent buttons in a row (center-bottom of screen)
		story_button = add(50, 50, icon_state = "continent_story", value = "story")
		sandbox_button = add(100, 50, icon_state = "continent_sandbox", value = "sandbox")
		pvp_button = add(150, 50, icon_state = "continent_pvp", value = "pvp")
		
		// Modal background (hidden initially)
		modal_background = add(75, 100, icon_state = "modal_bg")
		modal_background.size(2, 2)
		
		// Modal text area
		modal_text = add(85, 110, icon_state = null)
		modal_text.set_maptext("Select a continent", 128, 64)
		
		// Active continent indicator
		active_continent_indicator = add(50, 40, icon_state = "indicator_active")
		
		// Hide modal initially
		modal_background.loc = null
		modal_text.loc = null

	Click(HudObject/object)
		if(!world_initialization_complete)
			owner << "\red World still initializing. Please wait."
			return
		
		switch(object.value)
			if("story")
				show_continent_modal("story")
			if("sandbox")
				show_continent_modal("sandbox")
			if("pvp")
				show_continent_modal("pvp")
			if("confirm")
				travel_to_continent(current_modal)

	proc
		show_continent_modal(continent)
			current_modal = continent
			
			var/list/info = continent_info[continent]
			var/message = "<b>[info["name"]]</b>\n\n[info["desc"]]\n\n<font size='-1'>[info["rules"]]</font>"
			
			modal_text.set_maptext(message, 128, 96)
			modal_background.loc = owner
			modal_text.loc = owner

		travel_to_continent(continent)
			if(!continent) return
			
			// Call HUD wrapper for continent travel
			if(TravelToContinentViaHUD(owner, continent))
				current_continent = continent
				update_continent_display()
				owner << "\green Arrival successful!"
			else
				owner << "\red Travel failed. Please try again."
			
			// Hide modal
			modal_background.loc = null
			modal_text.loc = null

		update_continent_display()
			// Update indicator position based on current continent
			switch(current_continent)
				if("story")
					active_continent_indicator.pos(50, 40)
				if("sandbox")
					active_continent_indicator.pos(100, 40)
				if("pvp")
					active_continent_indicator.pos(150, 40)


//============================================================
// EQUIPMENT DISPLAY - Current Gear Visualization
//============================================================

EquipmentDisplay
	parent_type = /HudGroup
	
	layer = MOB_LAYER + 5
	
	var
		mob/owner
		list/HudObject/equipment_slots = list()
		
		list/slot_names = list("head", "chest", "hands", "feet", "back", "waist")
		list/slot_positions = list(
			"head" = list(0, 64),
			"chest" = list(0, 48),
			"hands" = list(16, 48),
			"feet" = list(0, 32),
			"back" = list(16, 64),
			"waist" = list(16, 32)
		)

	New(mob/m)
		..()
		owner = m
		icon = 'dmi/64/char.dmi'
		
		// Create slot objects for each equipment type
		for(var/slot in slot_names)
			var/list/pos = slot_positions[slot]
			var/HudObject/slot_obj = add(pos[1], pos[2], 
				icon_state = "slot_[slot]", 
				value = slot
			)
			equipment_slots[slot] = slot_obj

	proc
		update_equipment_display()
			if(!owner) return
			
			// Update each slot based on equipped items
			for(var/slot in slot_names)
				var/HudObject/slot_obj = equipment_slots[slot]
				slot_obj.icon_state = "slot_[slot]_empty"  // Default to empty

	Click(HudObject/object)
		// Could implement equipment swapping here
		owner << "Clicked [object.value] slot"


//============================================================
// QUICK ACTIONS MENU - Inventory, Customize, Map
//============================================================

QuickActionsMenu
	parent_type = /HudGroup
	
	layer = MOB_LAYER + 5
	
	var
		mob/owner
		HudObject/inventory_button
		HudObject/customize_button
		HudObject/map_button
		HudObject/skills_button
		HudObject/hub_button
		
		open = 0

	New(mob/m)
		..()
		owner = m
		icon = 'dmi/64/char.dmi'
		
		// Menu buttons in column (bottom-left of screen)
		inventory_button = add(0, 32, icon_state = "btn_inventory", value = "inventory")
		customize_button = add(0, 48, icon_state = "btn_customize", value = "customize")
		skills_button = add(0, 64, icon_state = "btn_skills", value = "skills")
		map_button = add(0, 80, icon_state = "btn_map", value = "map")
		hub_button = add(0, 96, icon_state = "btn_hub", value = "hub")

	Click(HudObject/object)
		switch(object.value)
			if("inventory")
				// TODO: Get reference to extended_hud from parent PonderaHUD
				owner << "\blue Opening inventory..."
			if("customize")
				owner << "\blue Opening customization..."
			if("skills")
				owner << "\blue Viewing skills..."
			if("map")
				owner << "\blue Opening map..."
			if("hub")
				// Return to port island hub
				if(ReturnToHub(owner))
					owner << "\green Hub return initiated."
				else
					owner << "\red Failed to return to hub."


//============================================================
// SYSTEM MESSAGES - Server Notifications
//============================================================

SystemMessages
	parent_type = /HudGroup
	
	layer = MOB_LAYER + 5
	
	var
		mob/owner
		list/HudObject/message_slots = list()
		list/message_queue = list()
		
		max_messages = 5  // Show up to 5 messages at once

	New(mob/m)
		..()
		owner = m
		icon = 'dmi/64/char.dmi'
		
		// Create 5 message slots (stack vertically)
		for(var/i = 1 to max_messages)
			var/py = (i - 1) * 16  // Stack messages
			var/HudObject/msg = add(0, 200 - py, icon_state = "msg_bg")
			msg.set_maptext("", 200, 16)
			message_slots += msg

	proc
		add_message(text, duration = 50)  // duration in ticks
			message_queue += list(list("text" = text, "ticks" = duration))
			show_messages()

		show_messages()
			// Clear all slots
			for(var/HudObject/slot in message_slots)
				slot.set_maptext("")
			
			// Fill slots with messages from queue
			for(var/i = 1 to min(message_queue.len, max_messages))
				var/list/msg_data = message_queue[i]
				message_slots[i].set_maptext(msg_data["text"], 200, 16)
			
			// Schedule cleanup of oldest messages
			spawn(50)
				for(var/list/msg in message_queue)
					msg["ticks"] -= 1
					if(msg["ticks"] <= 0)
						message_queue -= msg
				
				if(message_queue.len > 0)
					show_messages()


//============================================================
// MAIN PONDERA HUD - Master Container
//============================================================

PonderaHUD
	var
		mob/owner
		
		StatusBars/status_bars
		CharacterPanel/char_panel
		ContinentSelector/continent_selector
		EquipmentDisplay/equipment_display
		QuickActionsMenu/quick_menu
		SystemMessages/system_messages
		ExtendedHUDManager/extended_hud

	New(mob/m)
		owner = m
		
		// Create all HUD subsystems - pass mob, HudGroup will extract client
		if(!m || !m.client) return
		
		status_bars = new(m)
		status_bars.pos(10, 200)
		
		char_panel = new(m)
		char_panel.pos(200, 200)
		
		continent_selector = new(m)
		continent_selector.pos(100, 50)
		
		equipment_display = new(m)
		equipment_display.pos(10, 100)
		
		quick_menu = new(m)
		quick_menu.pos(10, 0)
		
		system_messages = new(m)
		system_messages.pos(100, 0)
		
		// Create extended HUD subsystems (inventory, customization, skills, deeds, market)
		extended_hud = new(m)

	proc
		update_all()
			if(!owner) return
			
			// Update status bars using dynamic variable access to avoid type errors
			var/hp = owner:HP || 100
			var/max_hp = owner:MAXHP || 100
			var/stamina = owner:stamina || 100
			var/hunger = 100  // Default hunger
			
			status_bars.update_health(hp, max_hp)
			status_bars.update_stamina(stamina, 100)
			status_bars.update_hunger(hunger, 100)
			
			char_panel.update_character_info()
			equipment_display.update_equipment_display()
			
			// Update extended HUD systems
			if(extended_hud)
				extended_hud.update_all()

		add_system_message(text, duration = 50)
			system_messages.add_message(text, duration)

		update_toolbelt_display()
			if(extended_hud)
				extended_hud.update_toolbelt_display()

		update_toolbelt_mode(mode_name)
			if(extended_hud)
				extended_hud.update_toolbelt_mode(mode_name)

		show_all()
			status_bars.show()
			char_panel.show()
			continent_selector.show()
			equipment_display.show()
			quick_menu.show()
			system_messages.show()
			// Note: extended_hud elements show themselves on creation

		hide_all()
			status_bars.hide()
			char_panel.hide()
			continent_selector.hide()
			equipment_display.hide()
			quick_menu.hide()
			system_messages.hide()
