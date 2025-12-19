// dm/Lighting.dm — Spotlight and cone lighting overlays, client lighting plane management.

client
	proc
		// Initialize client lighting plane on login.
		draw_lighting_plane()	
			toggle_daynight(1)
			screen += new/obj/lighting_plane


atom/movable
	var
		image/spotlight
		image/cone

	cone
		plane 			= LIGHTING_PLANE
		blend_mode 		= BLEND_ADD
		icon 			= 'dmi/l256.dmi'
		icon_state 		= "1"
		pixel_x 		= 0
		pixel_y 		= 0
		layer			= EFFECTS_LAYER+10
		appearance_flags= RESET_COLOR
		has_reflection	= 1
		//vis_flags = VIS_HIDE

	spotlight
		plane 			= LIGHTING_PLANE
		blend_mode 		= BLEND_ADD
		icon 			= 'dmi/l256.dmi'
		icon_state 		= "0"
		pixel_x 		= 0
		pixel_y 		= 0
		layer			= EFFECTS_LAYER+10
		appearance_flags= RESET_COLOR
		has_reflection	= 1
		//vis_flags = VIS_HIDE
	proc
		// Create and display a spotlight overlay with position, color, size and alpha.
		draw_spotlight(x_os = 0, y_os = 0, hex = "#FFFFFF", size_modi = 1, alph = 255)
			if(spotlight) return
			spotlight 			= new /atom/movable/spotlight
			spotlight.pixel_x	= x_os
			spotlight.pixel_y	= y_os
			spotlight.color		= hex
			spotlight.transform	= matrix()*size_modi
			spotlight.alpha		= alph
			overlays += spotlight

		// Remove a spotlight overlay.
		remove_spotlight(x_os, y_os, hex, size_modi, alph)
			if(!spotlight) return
			overlays -= spotlight

		// Animate and update spotlight properties (position, color, size, alpha).
		edit_spotlight(x_os, y_os, hex, size_modi, alph)
			if(!spotlight) return
			overlays -= spotlight
			spotlight.loc = loc
			animate(spotlight, pixel_x = ((!isnull(x_os)) ? x_os : spotlight.pixel_x), pixel_y = ((!isnull(y_os)) ? y_os : spotlight.pixel_y), color = (hex ? hex : spotlight.color), transform = (size_modi ? matrix()*size_modi : spotlight.transform), alpha = ((!isnull(alph)) ? alph : spotlight.alpha), time = 1)
			sleep(1)
			spotlight.loc = null
			overlays += spotlight

		// Create and display a cone overlay with position, color, size and alpha.
		draw_cone(x_os = 0, y_os = 0, hex = "#FFFFFF", size_modi = 1, alph = 255)
			if(cone) return
			cone 			= new /obj/cone
			cone.pixel_x	= x_os
			cone.pixel_y	= y_os
			cone.color		= hex
			cone.transform	= matrix()*size_modi
			cone.alpha		= alph
			overlays += cone

		// Remove a cone overlay.
		remove_cone(x_os, y_os, hex, size_modi, alph)
			if(!cone) return
			overlays -= cone

		// Animate and update cone properties (position, color, size, alpha).
		edit_cone(x_os, y_os, hex, size_modi, alph)
			if(!cone) return
			overlays -= cone
			cone.loc = loc
			animate(cone, pixel_x = ((!isnull(x_os)) ? x_os : cone.pixel_x), pixel_y = ((!isnull(y_os)) ? y_os : cone.pixel_y), color = (hex ? hex : cone.color), transform = (size_modi ? matrix()*size_modi : cone.transform), alpha = ((!isnull(alph)) ? alph : cone.alpha), time = 1)
			sleep(1)
			cone.loc = null
			overlays += cone

obj/lighting_plane
	screen_loc 			= "1,1"
	plane 				= LIGHTING_PLANE
	blend_mode 			= BLEND_MULTIPLY
	appearance_flags 	= PLANE_MASTER | NO_CLIENT_COLOR
	mouse_opacity 		= 0

obj/cone
	plane 			= LIGHTING_PLANE
	blend_mode 		= BLEND_ADD
	icon 			= 'dmi/l256.dmi'
	icon_state 		= "1"
	pixel_x 		= -32
	pixel_y 		= 0
	layer			= 1+EFFECTS_LAYER
	appearance_flags= RESET_COLOR
	has_reflection	= 1
	//vis_flags = VIS_HIDE

obj/spotlight
	plane 			= LIGHTING_PLANE
	blend_mode 		= BLEND_ADD
	icon 			= 'dmi/l256.dmi'
	icon_state 		= "0"
	pixel_x 		= 0
	pixel_y 		= 0
	layer			= 1+EFFECTS_LAYER
	appearance_flags= RESET_COLOR
	has_reflection	= 1
	//vis_flags = VIS_HIDE
