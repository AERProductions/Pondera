// dm/HudDialogSystem.dm
// Professional HUD-based Dialog System using HudGroups
// Replaces dumb alert() and input() with polished UI dialogs
// Version: 1.0
// Date: 2025-12-17

#define DIALOG_WIDTH 400
#define DIALOG_HEIGHT 300
#define BUTTON_HEIGHT 32
#define BUTTON_WIDTH 80
#define PADDING 10

// ============================================================================
// HUD DIALOG MANAGER
// ============================================================================

/**
 * HudDialog
 * Manages dialog windows with choice buttons
 */
HudDialog
	var
		HudGroup/group
		client/viewer
		datum/callback/on_choice
		list/buttons = list()
		title_text = ""
		body_text = ""
		
	New(client/c, title, body, on_choice_callback)
		if(!c)
			return
			
		viewer = c
		title_text = title
		body_text = body
		on_choice = on_choice_callback
		
		// Create HudGroup for this dialog
		group = new /HudGroup(c)
		group.layer = 100  // Above all other UI
		
		// Create background panel (semi-transparent)
		group.add(0, 0, icon_state="black", width=DIALOG_WIDTH, height=DIALOG_HEIGHT)
		
		// Create title area
		group.add(PADDING, PADDING, icon_state="title_bg", width=DIALOG_WIDTH-(PADDING*2), height=40)
		
		// Add title text
		var/obj/HudObject/title_obj = group.add(PADDING+5, PADDING+5)
		title_obj.set_text(title_text, width=DIALOG_WIDTH-(PADDING*2)-10, height=30)
		
		// Add body text area
		var/obj/HudObject/body_obj = group.add(PADDING, PADDING+50)
		body_obj.set_text(body_text, width=DIALOG_WIDTH-(PADDING*2), height=150)

	proc/add_button(label, value)
		buttons += list(list("label"=label, "value"=value))

	proc/show()
		if(!group || !viewer)
			return FALSE
			
		group.show()
		
		// Position buttons at bottom
		var/button_count = length(buttons)
		var/button_start_y = DIALOG_HEIGHT - BUTTON_HEIGHT - PADDING
		var/button_spacing = (DIALOG_WIDTH - (PADDING*2)) / button_count
		var/button_x = PADDING
		
		for(var/i = 1 to button_count)
			var/button_data = buttons[i]
			var/label = button_data["label"]
			var/value = button_data["value"]
			
			var/obj/HudObject/btn = group.add(button_x, button_start_y, icon_state="button", width=BUTTON_WIDTH, height=BUTTON_HEIGHT)
			btn.set_text(label)
			btn.Click = new /datum/callback(src, .proc/on_button_click, value)
			
			button_x += button_spacing
		
		return TRUE

	proc/on_button_click(value)
		if(on_choice)
			call(on_choice)(value)
		group.hide()
		del src

	proc/hide()
		if(group)
			group.hide()

	proc/destroy()
		if(group)
			group.hide()
			for(var/obj in group.objects)
				del obj
			del group
		del src

// ============================================================================
// INPUT DIALOG (Single text input field)
// ============================================================================

HudInputDialog
	var
		HudGroup/group
		client/viewer
		datum/callback/on_submit
		title_text = ""
		prompt_text = ""
		default_value = ""
		
	New(client/c, title, prompt, default="", on_submit_callback)
		if(!c)
			return
			
		viewer = c
		title_text = title
		prompt_text = prompt
		default_value = default
		on_submit = on_submit_callback
		
		group = new /HudGroup(c)
		group.layer = 100
		
		// Background
		group.add(0, 0, icon_state="black", width=DIALOG_WIDTH, height=200)
		
		// Title
		group.add(PADDING, PADDING, icon_state="title_bg", width=DIALOG_WIDTH-(PADDING*2), height=40)
		var/obj/HudObject/title_obj = group.add(PADDING+5, PADDING+5)
		title_obj.set_text(title_text, width=DIALOG_WIDTH-(PADDING*2)-10, height=30)
		
		// Prompt text
		var/obj/HudObject/prompt_obj = group.add(PADDING, PADDING+50)
		prompt_obj.set_text(prompt_text, width=DIALOG_WIDTH-(PADDING*2), height=40)
		
		// Input field would go here (requires DM input() integration)
		// For now, using a simplified text input approach
		group.add(PADDING, PADDING+95, icon_state="input_field", width=DIALOG_WIDTH-(PADDING*2), height=32)

	proc/show()
		if(!group || !viewer)
			return FALSE
			
		group.show()
		
		// Add buttons
		var/button_start_y = 160
		
		var/obj/HudObject/ok_btn = group.add(PADDING+30, button_start_y, icon_state="button", width=BUTTON_WIDTH, height=BUTTON_HEIGHT)
		ok_btn.set_text("OK")
		ok_btn.Click = new /datum/callback(src, .proc/on_ok_click)
		
		var/obj/HudObject/cancel_btn = group.add(PADDING+130, button_start_y, icon_state="button", width=BUTTON_WIDTH, height=BUTTON_HEIGHT)
		cancel_btn.set_text("Cancel")
		cancel_btn.Click = new /datum/callback(src, .proc/on_cancel_click)
		
		return TRUE

	proc/on_ok_click()
		// Get text from input field (simplified for now)
		if(on_submit)
			call(on_submit)(default_value)
		group.hide()
		del src

	proc/on_cancel_click()
		group.hide()
		del src

	proc/destroy()
		if(group)
			group.hide()
			for(var/obj in group.objects)
				del obj
			del group
		del src

// ============================================================================
// CHOICE DIALOG (Multiple choice buttons)
// ============================================================================

/**
 * show_hud_choice(client/c, title, body, choices_list, on_choice_callback)
 * Display a dialog with multiple choice buttons
 * choices_list format: list("Button Label" = "return_value", ...)
 */
proc/show_hud_choice(client/c, title, body, list/choices, datum/callback/on_choice)
	if(!c)
		return FALSE
		
	var/HudDialog/dialog = new /HudDialog(c, title, body, on_choice)
	
	for(var/choice_label in choices)
		var/choice_value = choices[choice_label]
		dialog.add_button(choice_label, choice_value)
	
	return dialog.show()

/**
 * show_hud_input(client/c, title, prompt, default, on_submit_callback)
 * Display a text input dialog
 */
proc/show_hud_input(client/c, title, prompt, default="", datum/callback/on_submit)
	if(!c)
		return FALSE
		
	var/HudInputDialog/dialog = new /HudInputDialog(c, title, prompt, default, on_submit)
	return dialog.show()

/**
 * Convenience procs for character creation
 */

/client/proc/hud_show_game_mode_choice(datum/callback/on_choice)
	return show_hud_choice(src, "Game Mode", "How would you like to play?", 
		list(
			"Single Player" = "single",
			"Multi-Player" = "multi"
		),
		on_choice)

/client/proc/hud_show_instance_choice(datum/callback/on_choice)
	return show_hud_choice(src, "Instance", 
		"Pick your adventure style:\n\nSandbox - Peaceful creative building\nStory - Progression with NPCs and quests\nKingdom PVP - Competitive raids and warfare",
		list(
			"Sandbox" = "sandbox",
			"Story" = "story",
			"Kingdom PVP" = "pvp"
		),
		on_choice)

/client/proc/hud_show_class_choice(datum/callback/on_choice)
	return show_hud_choice(src, "Class",
		"Choose your starting class:\n\nLandscaper - Master of nature and farming\nSmithing - Master of metalworking\nBuilder - Master of construction",
		list(
			"Landscaper" = "landscaper",
			"Smithy" = "smithy",
			"Builder" = "builder"
		),
		on_choice)

/client/proc/hud_show_gender_choice(class_name, datum/callback/on_choice)
	return show_hud_choice(src, "Gender",
		"Playing as a [class_name]:\n\nChoose your appearance:",
		list(
			"Male" = "male",
			"Female" = "female"
		),
		on_choice)

/client/proc/hud_show_name_input(datum/callback/on_submit)
	return show_hud_input(src, "Character Name",
		"Enter your character's name (3-15 letters, no spaces):",
		"",
		on_submit)

/client/proc/hud_show_confirmation(title, body, datum/callback/on_choice)
	return show_hud_choice(src, title, body,
		list(
			"Create" = "create",
			"Go Back" = "back"
		),
		on_choice)

/client/proc/hud_show_error(title, message)
	return show_hud_choice(src, title, message,
		list(
			"OK" = "ok"
		),
		new /datum/callback(src, .proc/hud_dismiss_error))

/client/proc/hud_dismiss_error(result)
	// Error dismissed
	return
