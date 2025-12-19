
map_generator
	jungle
		tile = /turf/jungle

obj/border

	jungle
		icon = 'dmi/64/acliffs.dmi'
		//icon_state = "4dh"
		density = TRUE

		// this just deletes random borders to allow walking up
		New()
			..()
			if(prob(1))
				// icon = 'can walk on this tile . dmi'
				// icon_state = "whatever it needs to be"
				return .

turf
	jungle
		name = "Grass"
		icon = 'dmi/64/drkgrss.dmi'
		//icon_state = "drkgrss"
		border_type = /obj/border/jungle

		SetElevation(n)
			elevation = n + 1

		SpawnResource()
			..()
			if(prob(0.3))
				new/obj/Rocks/OreRocks/IRocks(src)
			else if(prob(0.1))
				new/obj/Rocks/OreRocks/ZRocks(src)
			else if(prob(0.1))
				new/obj/Rocks/OreRocks/CRocks(src)
			else if(prob(0.1))
				new/obj/Rocks/OreRocks/LRocks(src)
			else if(prob(0.2))
				new/obj/Rocks/OreRocks/SRocks(src)

			// Spawnpoints
			if(prob(0.01))
				new/obj/spawns/spawnpointB2(src)

			// Bushes
			if(prob(0.3))
				new/obj/Plants/Bush/Raspberrybush(src)
			else if(prob(0.3))
				new/obj/Plants/Bush/Blueberrybush(src)

			// Trees
			if(prob(2.02))
				if(	!(locate(/obj/plant/UeikTreeA)	in src) && \
					!(locate(/obj/plant/UeikTreeH)	in src) && \
					!(locate(/obj/plant/ueiktree)	in src))

					if(prob(50))
						new/obj/plant/UeikTreeA(src)
					else
						new/obj/plant/UeikTreeH(src)

			else if(prob(15) && !(locate(/obj/plant/ueiktree) in range(3, src)) )
				new/obj/plant/ueiktree(src)

				for(var/turf/t in oview(1, src))
					if(prob(80)) continue
					if(! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t))
						new/obj/plant/ueiktree(t)


			// Flowers
			if(prob(0.5))
				new/obj/Flowers/Blueflower(src)
			else if(prob(0.5))
				new/obj/Flowers/Lightpurpflower(src)
			else if(prob(0.5))
				new/obj/Flowers/Pinkflower(src)
			else if(prob(0.5))
				new/obj/Flowers/Purpflower(src)
			else if(prob(0.7))
				new/obj/Flowers/Redflower(src)
			else if(prob(1.0))
				new/obj/Flowers/Tallgrass(src)

			// Deposits
			if(prob(0.05))
				new/turf/TarPit(src)
			else if(prob(0.03))
				new/turf/ClayDeposit(src)
			else if(prob(0.02))
				new/turf/ObsidianField(src)
			else if(prob(0.02))
				new/turf/Sand2(src)
			else if(prob(0.03))
				new/obj/Soil/richsoil(src)
			else if(prob(0.04))
				new/obj/Soil/soil(src)