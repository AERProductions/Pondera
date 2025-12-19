#include <kaiochao/shapes/shapes.dme>
atom/icon = 'shapes.dmi'

world
	fps = 60
	maxx = 50
	maxy = 50
	view = "21x15"

// yay for randomly colored squares
turf
	icon_state = "rect"
	New() color = rgb(rand(128), rand(128), rand(128))

mob
	icon_state = "oval"
	color = "white"
	step_size = 4

	Login()
		..()
		animate(src, time = 5, loop = -1, alpha = 128)
		animate(time = 5, alpha = 255)

client
	var tmp/map_zoom/map_zoom

	New()
		. = ..()
		map_zoom = new (src)

	#if DM_VERSION >= 508
	MouseWheel(object, delta_x, delta_y, location, control, params)
		..()
		params2list(params)["ctrl"] && zoom(delta_y)
	#endif

	// verb used by macros (see demo.dmf) and mouse wheel
	verb/zoom(Sign as num)
		set hidden = TRUE, instant = TRUE
		map_zoom && Sign && (Sign > 0 ? map_zoom.ZoomIn() : map_zoom.ZoomOut())