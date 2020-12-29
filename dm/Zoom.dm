


// This makes this library basically plug and play.
// Set client.map_zoom to FALSE to disable basic map zoom controls.

client
	var tmp/map_zoom/map_zoom = TRUE

	New()
		. = ..()
		if(map_zoom == TRUE)
			EnableMapZoom()

	// This defines the default map zoom behavior.
	proc
		EnableMapZoom()
			map_zoom = new (src)

			// dmf-free zoom macro insertion (parent must be your window's macro ID)
			var a = url_encode("Ctrl+="), b = url_encode("Ctrl+-")
			winset(src, "zoom_in_key", "parent=macro;name=[a];command=\"byond://?zoom_in\"")
			winset(src, "zoom_out_key", "parent=macro;name=[b];command=\"byond://?zoom_out\"")

		MapZoomTopic(Action)
			Action == "zoom_in" ? map_zoom.ZoomIn() : Action == "zoom_out" && map_zoom.ZoomOut()

		MapZoomScroll(DeltaY, Params[])
			DeltaY && Params["ctrl"] && (DeltaY > 0 ? map_zoom.ZoomIn() : map_zoom.ZoomOut())

	// Zoom macro commands
	Topic(href)
		map_zoom && MapZoomTopic(href)
		..()

	#if DM_VERSION >= 508
	// Mouse wheel zooming: hold Ctrl while scrolling
	MouseWheel(object, delta_x, delta_y, location, control, params)
		..()
		map_zoom && MapZoomScroll(delta_y, params2list(params))
	#endif


// for you
map_zoom
	// change these in your own project like so:
/*
map_zoom
	map_id = "mymap"
*/
	var
		// skin ID of the zooming map control
		map_id = "map1"

		// initial/current index in zoom_steps
		zoom = 1

		// steps in the zoom
		zoom_steps[] = list(0, 1, 1.5, 2, 2.5)

		// lerp factor for moving between steps
		// should be between 0 and 1 (1 disables smoothing, 0 disables zooming)
		zoom_smoothing = 0.25

	// call these in your project
	proc
		// step up the zoom
		ZoomIn()

		// step down the zoom
		ZoomOut()

// not for you (internals)
map_zoom
	var
		client/client
		client_zoom
		idle = TRUE

	New(Client)
		client = Client
		spawn winset(client, map_id, "zoom=[zoom_steps[zoom]]")

	ZoomIn()
		zoom = min(zoom + 1, zoom_steps.len)
		idle && ZoomLoop()

	ZoomOut()
		zoom = max(zoom - 1, 1)
		idle && ZoomLoop()

	proc
		ZoomLoop()
			set waitfor = FALSE

			// zooming is disabled
			if(!zoom_smoothing) return

			// zoom smoothing is disabled
			if(zoom_smoothing == 1 || !client_zoom || !zoom_steps[zoom])
				client_zoom = zoom_steps[zoom]
				winset(client, map_id, "zoom=[client_zoom]")

			// smooth zoom
			if(zoom_smoothing in 0 to 1)
				idle = FALSE
				var zoom_level
				do
					zoom_level = zoom_steps[zoom]
					client_zoom = client_zoom*(1-zoom_smoothing) + zoom_level*zoom_smoothing
					winset(client, map_id, "zoom=[client_zoom]")
					sleep world.tick_lag
				while(zoom_steps[zoom] && abs(client_zoom - zoom_level) > 0.01)
				client_zoom = zoom_steps[zoom]
				winset(client, map_id, "zoom=[client_zoom]")
				idle = TRUE
