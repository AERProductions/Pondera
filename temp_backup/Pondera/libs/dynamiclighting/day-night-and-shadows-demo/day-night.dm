
var
	time_of_day = 0

light
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

mob
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
