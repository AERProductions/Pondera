
#define DEBUG

atom
	icon = 'dynamic-lighting-textured.dmi'

var
	time_of_day = 0

// the library defines the lighting.ambient var which
// you can use to set the ambient light level. changing
// the value of the var doesn't force an update because
// it'd have to update every tile in the world. this can
// be very taxing on the CPU if you have a large map, so
// it's up to you to determine how the illumination gets
// updated.
//
// we define a new type of light source that checks every
// tile in view and force it to update if it doesn't reflect
// the ambient lighting value. by attaching this type of
// light source to players and because it updates every
// tile the player can see, we don't update every tile in
// the world when the ambient value changes, but we do
// update every tile a player can see.
light
	day_night
		apply()
			var/mob/m = owner

			// only force an update of the entire view
			// for light sources attached to players
			if(istype(m) && m.client)
				for(var/shading/s in range(m.client.view + 1, m))

					// if we haven't updated this tile's ambient light
					// value, force an update
					if(s.ambient != ambient)
						s.lum(0)

			return ..()

world
	fps = 20

	New()
		lighting.icon = 'sample-lighting-5.dmi'
		lighting.init()
		..()

mob
	icon_state = "mob"

	Login()
		loc = locate(7, 14, 1)
		src << "Use the verbs to change the light source attached to your mob. Click on a lamp to turn it on or off."

		// we use the new light source we defined
		light = new /light/day_night(src, 4)

	verb
		daytime()

			if(time_of_day != 0) return

			src << "Transitioning to daytime."
			time_of_day = 1

			for(var/i = 1 to 20)
				lighting.ambient += 0.25
				sleep(1)

			src << "It is now daytime."
			time_of_day = 2

		nighttime()

			if(time_of_day != 2) return

			src << "Transitioning to nighttime."
			time_of_day = 1

			for(var/i = 1 to 20)
				lighting.ambient -= 0.25
				sleep(1)

			src << "It is now nighttime."
			time_of_day = 0

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
			light = new(src, 4)

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
