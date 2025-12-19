#include <kaiochao/shapes/shapes.dme>
#include "skin.dmf"

world
	maxx = 30
	maxy = 30
	view = "20x15"
	fps = 60

turf
	icon_state = "rect"
	New() color = x % 2 == y % 2 ? "silver" : "gray"

mob
	icon_state = "oval"
	color = "navy"
	step_size = 4

client
	New()
		. = ..()

		// attach a new clean_map_scaling component to this client
		new /clean_map_scaling (src)

	verb
		map_resized()
			set hidden = TRUE

			// in your skin editor, the map element should have a "Resize command"
			// that calls this function:
			CleanMapScaling_OnResize()
