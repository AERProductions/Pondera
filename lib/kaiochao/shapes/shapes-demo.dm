world
	fps = 60
	maxx = 11
	maxy = 11
	turf = /turf/grass

turf
	icon_state = "rect"

	grass
		color = "green"
		New()
			color = rgb(0, rand(120, 125), 0)

	wall
		color = rgb(100, 100, 100)
		New()
			var c = rand(100, 105)
			color = rgb(c, c, c)

mob
	icon_state = "oval"
	color = "navy"
	step_size = 4

client
	show_popup_menus = FALSE

	MouseDown(o, l, c, p)
		MouseDraw(l, params2list(p))

	MouseDrag(so, oo, sl, ol, sc, oc, p)
		MouseDraw(ol, params2list(p))

	proc
		MouseDraw(Loc, Params[])
			if(Params["left"])
				new /turf/wall (Loc)
			else if(Params["right"])
				new /turf/grass (Loc)