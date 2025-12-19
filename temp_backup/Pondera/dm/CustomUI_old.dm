/**
 * Custom UI System - Escape BYOND's Skin Limitations
 * 
 * A flexible HUD framework using screen objects positioned anywhere on the client viewport.
 * Allows creation of custom health bars, status displays, and interactive UI elements
 * completely independent of BYOND's built-in skin system.
 */

// ==================== CLIENT-SIDE HUD STATE ====================

client/var/list/hud_panels = list()
client/var/hud_visible = 1

client/proc/add_ui_panel(P)
	if(!P) return 0
	if(P in hud_panels) return 0
	hud_panels += P
	P.owner = src
	if(P.screen_obj) screen += P.screen_obj
	return 1

client/proc/remove_ui_panel(P)
	if(!P || !(P in hud_panels)) return 0
	hud_panels -= P
	if(P.screen_obj) screen -= P.screen_obj
	P.owner = null
	return 1

client/proc/toggle_hud_visibility()
	hud_visible = !hud_visible
	for(var/P in hud_panels)
		P.set_visible(hud_visible)

client/proc/get_ui_panel(name)
	for(var/P in hud_panels)
		if(P.panel_id == name)
			return P
	return null

client/proc/clear_all_panels()
	var/list/temp = hud_panels.Copy()
	for(var/P in temp)
		remove_ui_panel(P)

// ==================== BASE PANEL TYPE ====================

/ui_panel
	var
		panel_id = "default"
		owner = null
		screen_obj = null
		x = 0
		y = 0
		width = 32
		height = 32
		visible = 1
		plane = 10
		icon_state = "blank"
		layer_offset = 0

	New(id = "panel")
		panel_id = id
		screen_obj = new /obj/screen()
		screen_obj.plane = plane
		screen_obj.mouse_opacity = 0
		update_obj()

	proc/set_position(anchor, offset_x = 0, offset_y = 0)
		x = offset_x
		y = offset_y
		screen_obj.screen_loc = "[anchor] + ([x],[y])"
		return src

	proc/set_size(w, h)
		width = w
		height = h
		screen_obj.maptext = ""
		return src

	proc/set_icon(icon_file, state)
		screen_obj.icon = icon_file
		screen_obj.icon_state = state
		icon_state = state
		return src

	proc/set_color(color_value)
		screen_obj.color = color_value
		return src

	proc/set_alpha(alpha_value)
		screen_obj.alpha = clamp(alpha_value, 0, 255)
		return src

	proc/set_visible(show = 1)
		visible = show
		if(owner)
			if(show && (owner && !call(owner, "get_screen_list")() || !(screen_obj in call(owner, "get_screen_list")()))))
				owner.screen += screen_obj
			else if(!show && (screen_obj in owner.screen))
				owner.screen -= screen_obj
		return src

	proc/update_obj()
		if(!screen_obj) return src
		screen_obj.plane = plane + layer_offset
		return src

	proc/delete_panel()
		if(owner)
			call(owner, "remove_ui_panel")(src)
		if(screen_obj)
			del(screen_obj)
		return src

// ==================== BUTTON ELEMENT ====================

/ui_button
	var
		panel_id = "default"
		owner = null
		obj/screen_obj = null
		x = 0
		y = 0
		width = 32
		height = 32
		visible = 1
		plane = 10
		icon_state = "blank"
		layer_offset = 0
		label = "Button"
		text_color = "#FFFFFF"
		bg_color = "#333333"
		hover_color = "#555555"
		clicked_color = "#111111"
		is_hovering = 0
		on_click = null

	New(id = "button", label_text = "Button")
		panel_id = id
		screen_obj = new /obj/screen()
		screen_obj.plane = plane
		screen_obj.mouse_opacity = 0
		label = label_text
		icon_state = "button_idle"
		set_size(64, 24)
		update_obj()

	proc/set_position(anchor, offset_x = 0, offset_y = 0)
		x = offset_x
		y = offset_y
		screen_obj.screen_loc = "[anchor] + ([x],[y])"
		return src

	proc/set_size(w, h)
		width = w
		height = h
		screen_obj.maptext = ""
		return src

	proc/set_icon(icon_file, state)
		screen_obj.icon = icon_file
		screen_obj.icon_state = state
		icon_state = state
		return src

	proc/set_color(color_value)
		screen_obj.color = color_value
		return src

	proc/set_alpha(alpha_value)
		screen_obj.alpha = clamp(alpha_value, 0, 255)
		return src

	proc/set_visible(show = 1)
		visible = show
		if(owner)
			if(show && (owner && !call(owner, "get_screen_list")() || !(screen_obj in call(owner, "get_screen_list")()))))
				owner.screen += screen_obj
			else if(!show && (screen_obj in owner.screen))
				owner.screen -= screen_obj
		return src

	proc/update_obj()
		if(!screen_obj) return src
		screen_obj.plane = plane + layer_offset
		screen_obj.maptext = "<center><b>[label]</b></center>"
		screen_obj.maptext_width = width
		screen_obj.maptext_height = height
		screen_obj.color = bg_color
		return src

	proc/set_label(text)
		label = text
		update_obj()
		return src

	proc/set_colors(bg, hover, clicked)
		bg_color = bg
		hover_color = hover
		clicked_color = clicked
		update_obj()
		return src

	proc/set_click_callback(callback_proc)
		on_click = callback_proc
		return src

	proc/on_button_click()
		if(on_click)
			call(on_click)()
		return src

	proc/delete_panel()
		if(owner)
			call(owner, "remove_ui_panel")(src)
		if(screen_obj)
			del(screen_obj)
		return src

// ==================== METER/GAUGE ELEMENT ====================

/ui_meter
	var
		panel_id = "default"
		owner = null
		obj/screen_obj = null
		x = 0
		y = 0
		width = 32
		height = 32
		visible = 1
		plane = 10
		icon_state = "blank"
		layer_offset = 0
		current_value = 100
		max_value = 100
		bar_color = "#00FF00"
		bg_color = "#222222"
		label_text = "Health"

	New(id = "meter", label_t = "Meter")
		panel_id = id
		screen_obj = new /obj/screen()
		screen_obj.plane = plane
		screen_obj.mouse_opacity = 0
		label_text = label_t
		set_size(128, 16)
		bar_color = "#00FF00"
		update_obj()

	proc/set_position(anchor, offset_x = 0, offset_y = 0)
		x = offset_x
		y = offset_y
		screen_obj.screen_loc = "[anchor] + ([x],[y])"
		return src

	proc/set_size(w, h)
		width = w
		height = h
		screen_obj.maptext = ""
		return src

	proc/set_icon(icon_file, state)
		screen_obj.icon = icon_file
		screen_obj.icon_state = state
		icon_state = state
		return src

	proc/set_color(color_value)
		screen_obj.color = color_value
		return src

	proc/set_alpha(alpha_value)
		screen_obj.alpha = clamp(alpha_value, 0, 255)
		return src

	proc/set_visible(show = 1)
		visible = show
		if(owner)
			if(show && (owner && !call(owner, "get_screen_list")() || !(screen_obj in call(owner, "get_screen_list")()))))
				owner.screen += screen_obj
			else if(!show && (screen_obj in owner.screen))
				owner.screen -= screen_obj
		return src

	proc/delete_panel()
		if(owner)
			call(owner, "remove_ui_panel")(src)
		if(screen_obj)
			del(screen_obj)
		return src

	proc/set_value(val)
		current_value = clamp(val, 0, max_value)
		update_obj()
		return src

	proc/set_max(val)
		max_value = max(1, val)
		update_obj()
		return src

	proc/set_bar_color(color)
		bar_color = color
		update_obj()
		return src

	proc/get_percentage()
		return round((current_value / max_value) * 100)

	proc/update_obj()
		if(!screen_obj) return src
		screen_obj.plane = plane + layer_offset
		var/percent = get_percentage()
		screen_obj.maptext = "<font color='[bar_color]'><b>[label_text] [percent]%</b></font>"
		screen_obj.maptext_width = width
		screen_obj.maptext_height = height
		return src

// ==================== TEXT ELEMENT ====================

/ui_text
	var
		panel_id = "default"
		owner = null
		obj/screen_obj = null
		x = 0
		y = 0
		width = 32
		height = 32
		visible = 1
		plane = 10
		icon_state = "blank"
		layer_offset = 0
		text_content = "Text"
		text_color = "#FFFFFF"
		text_size = 1
		text_align = "left"

	New(id = "text", content = "Text")
		panel_id = id
		screen_obj = new /obj/screen()
		screen_obj.plane = plane
		screen_obj.mouse_opacity = 0
		text_content = content
		set_size(200, 16)
		update_obj()

	proc/set_position(anchor, offset_x = 0, offset_y = 0)
		x = offset_x
		y = offset_y
		screen_obj.screen_loc = "[anchor] + ([x],[y])"
		return src

	proc/set_size(w, h)
		width = w
		height = h
		screen_obj.maptext = ""
		return src

	proc/set_icon(icon_file, state)
		screen_obj.icon = icon_file
		screen_obj.icon_state = state
		icon_state = state
		return src

	proc/set_color(color_value)
		screen_obj.color = color_value
		return src

	proc/set_alpha(alpha_value)
		screen_obj.alpha = clamp(alpha_value, 0, 255)
		return src

	proc/set_visible(show = 1)
		visible = show
		if(owner)
			if(show && (owner && !call(owner, "get_screen_list")() || !(screen_obj in call(owner, "get_screen_list")()))))
				owner.screen += screen_obj
			else if(!show && (screen_obj in owner.screen))
				owner.screen -= screen_obj
		return src

	proc/delete_panel()
		if(owner)
			call(owner, "remove_ui_panel")(src)
		if(screen_obj)
			del(screen_obj)
		return src

	proc/set_text(content)
		text_content = content
		update_obj()
		return src

	proc/set_text_color(color)
		text_color = color
		update_obj()
		return src

	proc/set_text_align(align)
		text_align = align
		update_obj()
		return src

	proc/update_obj()
		if(!screen_obj) return src
		screen_obj.plane = plane + layer_offset
		var/tag = ""
		var/close_tag = ""
		if(text_align == "center")
			tag = "<center>"
			close_tag = "</center>"
		else if(text_align == "right")
			tag = "<right>"
			close_tag = "</right>"
		screen_obj.maptext = "[tag]<font color='[text_color]'><b>[text_content]</b></font>[close_tag]"
		screen_obj.maptext_width = width
		screen_obj.maptext_height = height
		return src

// ==================== HEALTH BAR COMPONENT ====================

/ui_health_bar
	var
		panel_id = "health_bar"
		owner = null
		obj/screen_obj = null
		x = 0
		y = 0
		width = 32
		height = 32
		visible = 1
		plane = 10
		icon_state = "blank"
		layer_offset = 0
		current_value = 100
		max_value = 100
		bar_color = "#FF0000"
		bg_color = "#222222"
		label_text = "HP"
		mob/target = null

	New(mob_target)
		panel_id = "health_bar"
		screen_obj = new /obj/screen()
		screen_obj.plane = plane
		screen_obj.mouse_opacity = 0
		target = mob_target
		set_size(150, 20)
		bar_color = "#FF0000"
		update_obj()

	proc/set_position(anchor, offset_x = 0, offset_y = 0)
		x = offset_x
		y = offset_y
		screen_obj.screen_loc = "[anchor] + ([x],[y])"
		return src

	proc/set_size(w, h)
		width = w
		height = h
		screen_obj.maptext = ""
		return src

	proc/set_visible(show = 1)
		visible = show
		if(owner)
			if(show && (owner && !call(owner, "get_screen_list")() || !(screen_obj in call(owner, "get_screen_list")()))))
				owner.screen += screen_obj
			else if(!show && (screen_obj in owner.screen))
				owner.screen -= screen_obj
		return src

	proc/delete_panel()
		if(owner)
			call(owner, "remove_ui_panel")(src)
		if(screen_obj)
			del(screen_obj)
		return src

	proc/set_value(val)
		current_value = clamp(val, 0, max_value)
		update_obj()
		return src

	proc/set_max(val)
		max_value = max(1, val)
		update_obj()
		return src

	proc/set_bar_color(color)
		bar_color = color
		update_obj()
		return src

	proc/get_percentage()
		return round((current_value / max_value) * 100)

	proc/update_obj()
		if(!screen_obj) return src
		screen_obj.plane = plane + layer_offset
		if(target && target:HP)
			set_value(target:HP)
			if(target:MAXHP)
				set_max(target:MAXHP)
			label_text = "[target.name]: [target:HP]/[target:MAXHP]"
		var/percent = get_percentage()
		screen_obj.maptext = "<font color='[bar_color]'><b>[label_text] [percent]%</b></font>"
		screen_obj.maptext_width = width
		screen_obj.maptext_height = height
		return src

// ==================== STAMINA BAR COMPONENT ====================

/ui_stamina_bar
	var
		panel_id = "stamina_bar"
		owner = null
		obj/screen_obj = null
		x = 0
		y = 0
		width = 32
		height = 32
		visible = 1
		plane = 10
		icon_state = "blank"
		layer_offset = 0
		current_value = 100
		max_value = 100
		bar_color = "#FFFF00"
		bg_color = "#222222"
		label_text = "Stamina"
		mob/target = null

	New(mob_target)
		panel_id = "stamina_bar"
		screen_obj = new /obj/screen()
		screen_obj.plane = plane
		screen_obj.mouse_opacity = 0
		target = mob_target
		set_size(150, 20)
		bar_color = "#FFFF00"
		update_obj()

	proc/set_position(anchor, offset_x = 0, offset_y = 0)
		x = offset_x
		y = offset_y
		screen_obj.screen_loc = "[anchor] + ([x],[y])"
		return src

	proc/set_size(w, h)
		width = w
		height = h
		screen_obj.maptext = ""
		return src

	proc/set_visible(show = 1)
		visible = show
		if(owner)
			if(show && (owner && !call(owner, "get_screen_list")() || !(screen_obj in call(owner, "get_screen_list")()))))
				owner.screen += screen_obj
			else if(!show && (screen_obj in owner.screen))
				owner.screen -= screen_obj
		return src

	proc/delete_panel()
		if(owner)
			call(owner, "remove_ui_panel")(src)
		if(screen_obj)
			del(screen_obj)
		return src

	proc/set_value(val)
		current_value = clamp(val, 0, max_value)
		update_obj()
		return src

	proc/set_max(val)
		max_value = max(1, val)
		update_obj()
		return src

	proc/set_bar_color(color)
		bar_color = color
		update_obj()
		return src

	proc/get_percentage()
		return round((current_value / max_value) * 100)

	proc/update_obj()
		if(!screen_obj) return src
		screen_obj.plane = plane + layer_offset
		if(target && target:stamina)
			set_value(target:stamina)
			if(target:MAXstamina)
				set_max(target:MAXstamina)
		var/percent = get_percentage()
		screen_obj.maptext = "<font color='[bar_color]'><b>[label_text] [percent]%</b></font>"
		screen_obj.maptext_width = width
		screen_obj.maptext_height = height
		return src

