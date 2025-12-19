world
	fps = 60
	maxx = 25
	maxy = 25
	view = 12
	turf = /turf/grass

	New()
		new /obj/rescaling (locate(10, 10, 1))
		new /obj/rotating (locate(6, 6, 1))

		new /obj/sharp_rotating (locate(12, 6, 1))

#if DM_VERSION >= 511
client
	fps = 100
#endif

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

obj
	rescaling
		icon = 'shapes256.dmi'
		icon_state = "oval"
		New()
			transform = matrix() * (1/256)
			animate(src, loop = -1, time = 30,
				easing = SINE_EASING,
				transform = matrix() * 2)
			animate(time = 30,
				easing = SINE_EASING,
				transform = matrix() * (1/256))

	rotating
		icon = 'shapes hq 34.dmi'
		icon_state = "rect"
		New()
			transform = 5 * matrix()
			animate(src, loop = -1, time = 30,
				transform = turn(5 * matrix(), 120))
			animate(time = 30, transform = turn(5 * matrix(), 240))
			animate(time = 30, transform = 5 * matrix())

	sharp_rotating
		icon = 'shapes.dmi'
		icon_state = "rect"
		New()
			transform = 5 * matrix()
			animate(src, loop = -1, time = 30,
				transform = turn(5 * matrix(), 120))
			animate(time = 30, transform = turn(5 * matrix(), 240))
			animate(time = 30, transform = 5 * matrix())

mob
	icon = 'shapes hq 34.dmi'
	icon_state = "oval"
	pixel_x = -1
	pixel_y = -1
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
