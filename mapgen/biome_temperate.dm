
map_generator
	temperate
		tile = /turf/temperate

		min_size = 5
		max_size = 8

obj/border

	temperate
		icon = 'acliffs.dmi'
		ramp_chance = 5
		name = "Cliff"

		deposit_chance = 10
		deposit_types = list(	/obj/Rocks/Cliffs/ICliff,
								/obj/Rocks/Cliffs/ZCliff,
								/obj/Rocks/Cliffs/CCliff,
								/obj/Rocks/Cliffs/LCliff,
								/obj/Rocks/Cliffs/SCliff
							)
		DblClick()
			//set waitfor = 0
			set popup_menu = 0

turf
	temperate//don't forget that in order for the map generator to work, you have to place this turf on the map.
		name = "Grass"
		icon = 'gen.dmi'
		icon_state = "grass"
		border_type = /obj/border/temperate

		wsfx = list(	/obj/snd/sfx/apof/forestwind
					)


		sfx = list(		/obj/snd/sfx/apof/forestbirds,
						/obj/snd/sfx/apof/forestwind
					)

		SetElevation(n)
			elevation = n + 1

		SpawnResource()

			if(prob(0.3)&&global.season!="Winter"&&month!="Tevet")
				SpawnSoundEffects()
			else if(prob(0.2)&&global.season=="Winter")//for some reason summer sounds are still spawning in winter...
				SpawnSoundEffectsW()

			if(!spawn_resources) return

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
			else if(prob(2.02))
				for(var/turf/t in oview(1, src))
					if(!t.spawn_resources || prob(80)) continue
					if(	!(locate(/obj/plant/UeikTreeA)	in src) && \
					!(locate(/obj/plant/UeikTreeH)	in src) && \
					!(locate(/obj/plant/ueiktree)	in src))
					else if(prob(15) && !(locate(/obj/plant/ueiktree) in range(3, src)) && !(locate(/obj/plant/UeikTreeA) in range(3, src))&& !(locate(/obj/plant/UeikTreeH) in range(3, src)) )
						if(! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t) && ! (locate(/obj/plant/ueiktree) in t))
							new/obj/Plants/Bush/Raspberrybush(t)
						if(! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t) && ! (locate(/obj/plant/ueiktree) in t) && ! (locate(/obj/Plants/Bush/Raspberrybush) in t))
							new/obj/Plants/Bush/Blueberrybush(t)

			//if(prob(0.3))
			//	new/obj/Plants/Bush/Raspberrybush(src)
			//else if(prob(0.3))
			//	new/obj/Plants/Bush/Blueberrybush(src)

			// Trees
			else if(prob(2.02))
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
					if(!t.spawn_resources || prob(80)) continue
					if(! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t))
						new/obj/plant/ueiktree(t)
			else if(prob(15))
				new/obj/items/Logs/UeikLog(t)


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
			if(prob(0.03))
				new/turf/TarPit(src)
			else if(prob(0.03))
				new/turf/ClayDeposit(src)
			else if(prob(0.03))
				new/turf/ObsidianField(src)
			else if(prob(0.03))
				new/turf/Sand2(src)
			else if(prob(0.03))
				new/obj/Soil/richsoil(src)
			else if(prob(0.03))
				new/obj/Soil/soil(src)