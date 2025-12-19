
// File:    light-source.dm
// Library: Forum_account.DynamicLighting
// Author:  Forum_account
//
// Contents:
//   This file defines the light object which is used to
//   create light sources that are attached to objects.
//   The light can be attached to a stationary object
//   (ex: a turf) or a mobile object (ex: a player).

atom
	var
		light/light

light
	parent_type = /obj

	var
		// the atom the light source is attached to
		atom/owner

		// the radius, intensity, and ambient value control how large of
		// an area the light illuminates and how brightly it's illuminated.
		radius = 2
		intensity = 1
		ambient = 0

		radius_squared = 4

		// the coordinates of the light source - these can be decimal values
		__x = 0
		__y = 0

		// whether the light is turned on or off.
		on = 1

		// this flag is set when a property of the light source (ex: radius)
		// has changed, this will trigger an update of its effect.
		changed = 1

		// this is used to determine if the light is attached to a mobile
		// atom or a stationary one.
		mobile = 0

		// This is the illumination effect of this light source. Storing this
		// makes it very easy to undo the light's exact effect.
		list/effect

	New(atom/a, radius = 3, intensity = 1)
		if(!a || !istype(a))
			CRASH("The first argument to the light object's constructor must be the atom that is the light source. Expected atom, received '[a]' instead.")

		owner = a

		if(istype(owner, /atom/movable))
			loc = owner.loc
			mobile = 1
		else
			loc = owner
			mobile = 0

		src.radius = radius
		src.radius_squared = radius * radius
		src.intensity = intensity

		__x = owner.x
		__y = owner.y

		// the lighting object maintains a list of all light sources
		lighting.lights += src

	proc
		// this used to be called be an infinite loop that was local to
		// the light object, but now there is a single infinite loop in
		// the global lighting object that calls this proc.
		loop()

			// if the light is mobile (if it was attached to an atom of
			// type /atom/movable), check to see if the owner has moved
			if(mobile)

				// compute the owner's coordinates
				var/opx = owner.x
				var/opy = owner.y

				// if pixel movement is enabled we need to take step_x
				// and step_y into account
				if(lighting.pixel_movement)
					opx += owner:step_x / 32
					opy += owner:step_y / 32

				// see if the owner's coordinates match
				if(opx != __x || opy != __y)
					__x = opx
					__y = opy
					changed = 1

			if(changed)
				apply()

		apply()

			changed = 0

			// before we apply the effect we remove the light's current effect.
			if(effect)

				// negate the effect of this light source
				for(var/shading/s in effect)
					s.lum(-effect[s])

				// clear the effect list
				effect.Cut()

			// only do this if the light is turned on and is on the map
			if(on && loc)

				// identify the effects of this light source
				effect = effect()

				// apply the effect
				for(var/shading/s in effect)
					s.lum(effect[s])

		// turn the light source on
		on()
			if(on) return

			on = 1
			changed = 1

		// turn the light source off
		off()
			if(!on) return

			on = 0
			changed = 1

		// toggle the light source's on/off status
		toggle()
			if(on)
				off()
			else
				on()

		radius(r)
			if(radius == r) return

			radius = r
			radius_squared = r * r
			changed = 1

		intensity(i)
			if(intensity == i) return

			intensity = i
			changed = 1

		ambient(a)
			if(ambient == a) return

			ambient = a
			changed = 1

		// compute the center of the light source, this is used
		// for light sources attached to mobs when you're using
		// pixel movement.
		center()
			if(istype(owner, /atom/movable))

				var/atom/movable/m = owner

				. = m.loc
				var/d = bounds_dist(m, .)

				for(var/turf/t in m.locs)
					var/dt = bounds_dist(m, t)
					if(dt < d)
						d = dt
						. = t
			else
				var/turf/t = owner
				while(!istype(t))
					t = t.loc

				return t

		// compute the total effect of this light source
		effect()

			var/list/L = list()

			for(var/shading/s in range(radius, owner))

				// we call this object's lum() proc to compute the illumination
				// value we contribute to each shading object, this way you can
				// override the lum() proc to change how lighting works but leave
				// this proc alone.
				var/lum = lum(s)

				if(lum > 0)
					L[s] = lum

			return L

		// compute the amount of illumination this light source
		// contributes to a single atom
		lum(atom/a)

			if(!radius)
				return 0

			// compute the distance to the tile, we use the __x and __y vars
			// so the light source's pixel offset is taken into account (provided
			// that's enabled)
			var/d = (__x - a.x) * (__x - a.x) + (__y - a.y) * (__y - a.y)

			// if the turf is outside the radius the light doesn't illuminate it
			if(d > radius_squared) return 0

			d = sqrt(d)

			// this creates a circle of light that non-linearly transitions between
			// the value of the intensity var and zero.
			return cos(90 * d / radius) * intensity + ambient
