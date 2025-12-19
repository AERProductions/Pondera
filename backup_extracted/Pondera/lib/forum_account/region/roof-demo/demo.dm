
world
	fps = 20
	view = 7

turf
	var
		image/roof

region
	roof
		// each turf inside the region has a roof image
		added(turf/t)
			t.roof = image(icon, t, "black", MOB_LAYER + 5)

		var
			list/visible = list()

		// when you enter the region, hide its roof
		Entered(mob/m)
			if(istype(m) && m.client)
				hide(m)

		// when you exit the region, show its roof
		Exited(mob/m)
			if(istype(m) && m.client)
				show(m)

		proc
			hide(mob/m)

				// keep track of whether or not the region is shown to this player
				visible[m] = 0

				// remove the image from all turfs in the region
				for(var/turf/t in turfs)
					var/d = get_dist(m, t)

					if(d < world.view * 2)
						spawn(d * world.tick_lag)
							if(!visible[m])
								m.client.images -= t.roof
					else
						m.client.images -= t.roof

			show(mob/m)
				visible[m] = 1

				for(var/turf/t in turfs)
					var/d = world.view - get_dist(m, t)

					if(d > 0)
						spawn(d * world.tick_lag)
							if(visible[m])
								m.client.images += t.roof
					else
						m.client.images += t.roof

		roof_01
			icon_state = "region-1"

		roof_02
			icon_state = "region-2"

		roof_03
			icon_state = "region-3"

mob
	Login()
		// by default a player is shown all regions, the regions
		// will become hidden when the player enters them.
		for(var/region/roof/r in world)
			r.show(src)

		..()


atom
	icon = 'region-demo-icons.dmi'

mob
	icon_state = "mob"

turf
	icon_state = "grass"

	wall
		density = 1
		icon_state = "wall"

	floor
		icon_state = "floor"

	sidewalk
		icon_state = "sidewalk"

	pavement
		icon_state = "pavement"