
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

world
	fps = 20

	New()

		// tell the dynamic lighting which icon file to use
		lighting.icon = 'sample-lighting-5.dmi'

		// initialize dynamic lighting for all z levels
		lighting.init()

		..()

mob
	icon_state = "mob"

	Login()
		loc = locate(6, 13, 1)
		src << "Use the verbs to change the light source attached to your mob. Click on a lamp to turn it on or off."

		// The library defines a /light object for every atom called "light",
		// but the var is null by default. We instantiate the object to make
		// the atom a light source. The constructor takes the atom that is
		// the light source is attached to and a radius.

		// make the mob a light source with a light radius of 4 tiles
		light = new(src, 4)

	verb
		toggle_light()
			// The light's toggle() proc turns it on or off. It also
			// has procs called on() and off() if we want to specifically
			// turn it on or off.
			light.toggle()

		increase_radius()
			light.radius(light.radius + 1)
			src << "light.radius = [light.radius]"

		decrease_radius()
			light.radius(light.radius - 1)
			src << "light.radius = [light.radius]"

		increase_intensity()
			light.intensity(light.intensity + 0.2)
			src << "light.intensity = [light.intensity]"

		decrease_intensity()
			light.intensity(light.intensity - 0.2)
			src << "light.intensity = [light.intensity]"

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

mob
	icon_state = "mob"
