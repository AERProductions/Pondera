
// the HudGroup object is defined by the library, we define a sub-type here
// that will use the base object's features to manage a health meter for us
HealthMeter
	parent_type = /HudGroup

	// all objects in this group will use this icon and layer
	icon = 'health-bar-demo.dmi'
	layer = MOB_LAYER + 5

	New()
		..()

		// add eight objects to this group
		for(var/i = 1 to 8)

			// the objects are placed in a row, 16 pixels apart, starting at 0,0
			var/px = i * 16 - 16
			var/py = 0
			add(px, py, "health")

	proc
		// updates the eight screen objects in the group to represent the new health value
		update(value)
			for(var/i = 1 to 8)

				// the objects list is the list of screen objects in this group
				var/HudObject/h = objects[i]

				// the value var holds the number of screen objects we want to
				// have the "health" state, any extra ones get the "empty" state
				if(i <= value)
					h.icon_state = "health"
				else
					// if they're transitioning from full to empty, play an animation
					if(h.icon_state == "health")
						flick("hurt", h)

					h.icon_state = "empty"

mob
	var
		HealthMeter/health_meter

	Login()
		..()

		// create a health meter for this mob
		health_meter = new(src)

	verb
		change_health()

			// update the value displayed by the health meter
			var/h = rand(0,8)
			health_meter.update(h)

			src << "health_meter.update([h])"

		toggle_health_meter()

			// hide or show the health meter
			health_meter.toggle()

			src << "health_meter.toggle()"

		move_health_meter()

			// move the health meter to a random position
			var/px = rand(0, 120)
			var/py = rand(0, 120)
			health_meter.pos(px, py)

			src << "health_meter.pos([px], [py])"

// the rest of this code is needed for the demo but doesn't
// relate to how you'd use the HUD library.
atom
	icon = 'hud-demo-icons.dmi'

turf
	icon_state = "grass"

	water
		density = 1
		icon_state = "water"

mob
	icon_state = "mob"