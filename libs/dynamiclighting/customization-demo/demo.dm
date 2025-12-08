
#define DEBUG

// the /light object is what we create to make an atom behave as a
// light source, by creating child types of this object we can override
// parts of its behavior to create different types of lights.
light

	// we override the lum() proc to make the amount
	// of illumination based on get_dist(), this way
	// the light source makes a square area of light.
	square
		lum(atom/a)
			return radius - get_dist(src, a) + 1

	// we create a directional light that only illuminates
	// tiles that are in the direction the light is facing
	directional
		dir = SOUTH

		lum(atom/a)
			if(light_dir(src, a) == dir)
				return ..()
			else
				return 0

proc
	// this is a helper proc we use to create directional lights
	light_dir(atom/a, atom/b)
		var/dx = b.x - a.x
		var/dy = b.y - a.y

		if(dy >= abs(dx))
			return NORTH
		if(dy <= -abs(dx))
			return SOUTH
		if(dx >= abs(dy))
			return EAST
		if(dx <= -abs(dy))
			return WEST

		return 0


world
	fps = 20

	New()
		..()

		// initialize dynamic lighting and make it
		// use the sample-lighting-5.dmi icon.
		lighting.icon = 'sample-lighting-5.dmi'
		lighting.init()

mob
	icon_state = "mob"

	Login()
		loc = locate(6, 13, 1)
		src << "Use the verbs to change the light source attached to your mob. Click on a lamp to rotate the light."

		// The library defines a /LightSource object for every atom
		// called "light", but the var is null by default. We instantiate
		// the object to make the atom a light source. The constructor
		// takes the atom that is the light source and a radius.

		// make the mob a square light source with a radius of 3 tiles
		light = new /light/square(src, 3)

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

			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
			light = new /light/directional(src, 4)
			light.dir = pick(NORTH, SOUTH, EAST, WEST)

		// clicking on the lamp rotates it
		Click()
			light.dir = turn(light.dir, 90)

// The rest of this code is needed for the demo but isn't
// related to how you'd use the library.

client
	view = 8

atom
	icon = 'dynamic-lighting-textured.dmi'

turf
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
