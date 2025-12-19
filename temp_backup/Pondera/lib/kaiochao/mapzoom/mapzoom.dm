// for you
map_zoom
	// change these in your own project like so:
/*
map_zoom
	map_id = "mymap"
*/
	var
		// skin ID of the zooming map control
		map_id = ":map"

		// initial/current index in zoom_steps
		zoom = 0.3

		// steps in the zoom
		zoom_steps[] = list(0.5, 0.75, 1, 1.25, 1.5, 1.75, 2)

		// lerp factor for moving between steps
		// should be between 0 and 1 (1 disables smoothing, 0 disables zooming)
		zoom_smoothing = 0.3

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
		client_zoom = text2num(winget(client, map_id, "zoom"))

	ZoomIn()
		zoom = min(zoom + 1, zoom_steps.len)
		idle && ZoomLoop()

	ZoomOut()
		zoom = max(zoom - 1, 1)
		idle && ZoomLoop()

	proc
		ZoomLoop()
			set waitfor = FALSE
			if(zoom_smoothing in 0 to 1) // only legal smoothing values
				switch(zoom_smoothing)
					if(0) // zoom is disabled
						return

					if(1) // zoom smoothing is disabled
						client_zoom = zoom_steps[zoom]
						winset(client, map_id, "zoom=[client_zoom]")

					else
						idle = FALSE
						var zoom_level
						do
							zoom_level = zoom_steps[zoom]
							client_zoom = client_zoom*(1-zoom_smoothing) + zoom_level*zoom_smoothing
							winset(client, map_id, "zoom=[client_zoom]")
							sleep world.tick_lag
						while(abs(client_zoom - zoom_level) > 0.01)
						idle = TRUE