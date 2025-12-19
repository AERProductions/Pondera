
atom
	icon = 'region-demo-icons.dmi'

mob
	icon_state = "mob"

region
	region_1
		icon_state = "region-1"

		Entered(mob/m)
			m << "You entered the building."

		Exited(mob/m)
			m << "You left the building."

	region_2
		icon_state = "region-2"

		Entered(mob/m)
			m << "You entered the closet."

		Exited(mob/m)
			m << "You left the closet."

	region_3
		icon_state = "region-3"

		Entered(mob/m)
			m << "You entered the un-exitable region!"

		Exit(mob/m)
			m << "You can't exit this region."
			return 0

turf
	icon_state = "grass"

	floor
		icon_state = "floor"

	wall
		density = 1
		icon_state = "wall"
