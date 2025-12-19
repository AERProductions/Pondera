
Minimap
	parent_type = /HudGroup

	icon = 'minimap-demo.dmi'
	layer = MOB_LAYER + 5

	var
		// the size of each tile on the minimap
		scale = 2

		// the border around the minimap
		padding = 1

		// a list that associates mobs with their HudObject
		list/markers = list()

	New()
		..()

		pos(8, 8)

		// create the background
		add(0, 0, icon = 'minimap-background.dmi')

	proc
		// this makes a mob be displayed on the minimap
		track(mob/m)

			// create a marker if we need to
			if(!markers[m])
				markers[m] = add(0, 0, icon_state = m.icon_state, layer = layer + 1)

			m.minimap = src
			update(m)

		// this updates a mob's marker on the minimap
		update(mob/m)

			var/px = (m.x - 1) * scale + padding
			var/py = (m.y - 1) * scale + padding

			var/HudObject/h = markers[m]
			h.pos(px, py)

var
	// there's a single global minimap
	Minimap/Minimap = new()

mob
	var
		// each mob has a reference to the minimap they're shown on
		Minimap/minimap

	// every time you move, update the minimap (only if you're being tracked)
	Move()
		. = ..()

		if(. && minimap)
			minimap.update(src)

	Login()
		..()

		// add the minimap to your screen
		Minimap.add(src)

		// make the minimap track your movement
		Minimap.track(src)

		src << "Click on a turf to create a blue mob."

	// blue mobs run around randomly
	blue
		icon_state = "blue-mob"

		New()
			..()
			walk_rand(src)

turf
	Click()
		var/mob/blue/b = new(src)
		Minimap.track(b)


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