
#define DEBUG

world
	fps = 20

	New()
		..()
		lighting.icon = 'sample-lighting-5.dmi'
		lighting.init()

mob
	icon_state = "mob"

	Login()
		loc = locate(6, 13, 1)
		src << "<b>This demo is the same as the other one except object cast shadows. Your mob casts shadows and so do brick walls.</b>"
		src << ""
		src << "Use the verbs to change the light source attached to your mob. Click on a lamp to turn it on or off."

		light = new(src, 3)

		// we turn the player's light source off initially, so
		// your light doesn't interfere with the shadows you cast.
		light.off()

		// make the mob opaque so it casts shadows. notice that we use
		// the "opaque" var and not BYOND's built-in opacity var, this
		// is because the opacity var has a meaning to BYOND and will
		// trigger it's built-in visibility system. we don't want that,
		// we just want the dynamic lighting to know what objects are
		// opaque.
		opaque = 1

	verb
		toggle_light()
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
			light = new(src, 8)

		Click()
			light.toggle()

atom
	movable
		Move()
			var/shading/old = loc:shading
			. = ..()

			// if the object moved and is opaque, we need to check
			// for nearby light sources that need to update in case
			// the object changes how shadows are cast
			if(opaque && .)

				// for all nearby light sources...
				for(var/light/l in range(10,src))
					if(!l.effect) continue

					// if you moved to or from a tile that was
					// affected by this light source...
					var/shading/s = loc:shading
					if(!isnull(l.effect[s]) || !isnull(l.effect[old]))

						// set the stale flag so they'll be updated automatically
						l.changed = 1

atom
	var
		// we don't use the opacity var because we don't
		// want to use BYOND's built-in opacity system,
		// we want to create our own effects.
		opaque = 0

turf
	proc
		// return 1 if the turf is opaque or contains an
		// opaque object, return 0 otherwise
		opaque(atom/ignore)
			if(opaque) return 1

			for(var/atom/a in src)
				if(a == ignore) continue
				if(a.opaque) return 1

			return 0

light
	// we override the light's effect() proc, this is the
	// proc that computes the total effect of the light source.
	// we override it to make it take visibility into account, that
	// way tiles that aren't visible from the light source aren't
	// illuminated by it, which creates shadows.
	effect()

		// the associative list of shading objects and their
		// illumination values
		var/list/L = list()

		for(var/shading/s in range(radius, src))

			// if we already have a value for it, skip it
			if(!isnull(L[s])) continue

			// if its the center we handle this case specially to
			// avoid some division by zero errors later. also, we
			// know we can always see the center so we don't need
			// to check.
			if(s.x == x && s.y == y)
				var/lum = lum(s)
				if(lum > 0)
					L[s] = lum

				continue

			// determine if s can be seen from src...

			// find the normalized vector pointing from src to s
			var/dx = (s.x - x)
			var/dy = (s.y - y)
			var/d = sqrt(dx * dx + dy * dy)

			if(d > 0)
				dx /= d
				dy /= d

			// we'll use this vector to trace a line from src to s
			// and check each tile along the way for opaque objects
			var/tx = x + dx + 0.5
			var/ty = y + dy + 0.5

			// we use a limited number of iterations
			for(var/i = 1 to radius)

				var/turf/t = locate(round(tx), round(ty), z)

				// in case we went off the edge of the map
				if(!t) break

				// if we don't have an illumination value, compute one
				if(!L[t.shading])
					var/lum = lum(t.shading)
					if(lum > 0)
						L[t.shading] = lum

				// if it's opaque, stop tracing the line
				if(t.opaque(owner))
					break

				// if we've reached s, stop tracing the line
				if(t.shading == s) break

				// continue tracing the line
				tx += dx
				ty += dy

		return L

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
		opaque = 1

	sidewalk
		icon_state = "sidewalk"

	pavement
		icon_state = "pavement"

	floor
		icon_state = "floor"

mob
	icon_state = "mob"
