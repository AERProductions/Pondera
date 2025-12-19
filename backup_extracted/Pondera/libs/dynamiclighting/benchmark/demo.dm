
#define DEBUG

atom
	// switch which line is commented to change which
	// icon file is used, when using the 'simple' icon
	// look at how harsh the lighting effects look
	// compared to the 'textured' tiles. the lighting
	// effects look much nicer when the tiles underneath
	// have more detail and aren't just solid colors.
	// icon = 'dynamic-lighting-simple.dmi'
	icon = 'dynamic-lighting-textured.dmi'

var
	const
		MOB_COUNT = 10

world
	fps = 10

	New()

		// tell the dynamic lighting which icon file to use
		lighting.icon = 'sample-lighting-5.dmi'

		// initialize dynamic lighting for all z levels
		lighting.init()

		for(var/i = 1 to MOB_COUNT)

			while(1)
				var/x = rand(1, world.maxx)
				var/y = rand(1, world.maxy)

				var/turf/t = locate(x, y, 1)
				if(t.density) continue

				new /mob/random(t)

				break

		..()

mob
	icon_state = "mob"

	Stat()
		stat("world.cpu", world.cpu)

	Login()
		loc = locate(6, 13, 1)

		// make the mob a light source with a light radius of 4 tiles
		light = new(src, 4)

	random
		New()
			..()

			// attach a light source to the mob
			light = new(src, 4)

			// and make it walk around randomly
			walk_rand(src, 2)

obj
	lamp
		icon_state = "lamp"

		New()
			..()
			light = new(loc, 4)

		// clicking on the lamp turns it on or off
		Click()
			light.toggle()

// The rest of this code is needed for the demo but isn't
// related to how you'd use the library.

client
	view = 8

turf
	New()
		..()
		dir = pick(NORTH, SOUTH, EAST, WEST)

	grass
		icon_state = "grass"

	brick
		icon_state = "brick"
		density = 1

	sidewalk
		icon_state = "sidewalk"

	pavement
		icon_state = "pavement"

	floor
		icon_state = "floor"

	black
		density = 1
		icon_state = "black"

mob
	icon_state = "mob"
