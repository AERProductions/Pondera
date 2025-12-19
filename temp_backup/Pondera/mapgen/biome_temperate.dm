
map_generator
	temperate
		tile = /turf/temperate

		min_size = 5
		max_size = 8

obj/border

	temperate
		icon = 'dmi/64/acliffs.dmi'
		ramp_chance = 5
		name = "Cliff"
		layer = 1
		//plane = 1
		deposit_chance = 10
		deposit_types = list(	/obj/Rocks/Cliffs/ICliff,
								/obj/Rocks/Cliffs/ZCliff,
								/obj/Rocks/Cliffs/CCliff,
								/obj/Rocks/Cliffs/LCliff,
								/obj/Rocks/Cliffs/SCliff
							)
turf
	start//don't forget that in order for the map generator to work, you have to place this turf on the map.
		name = "Grass"
		icon = 'dmi/64/gen.dmi'
		icon_state = "grass"

turf
	temperate//don't forget that in order for the map generator to work, you have to place this turf on the map.
		name = "Grass"
		icon = 'dmi/64/gen.dmi'
		icon_state = "grass"
		border_type = /obj/border/temperate
		layer = 1
		//plane = 1
		wsfx = list(
					)
		sfx = list( /obj/snd/sfx/apof/forestbirds
					)
		sfxwat = list( /obj/snd/sfx/river
						)

		SetElevation(n)
			elevation = n + 1

		SpawnResource()

			if(global.season!="Winter"&&month!="Tevet")
				SpawnSoundEffects()
				SpawnSoundEffectsWAT()
			else if(global.season=="Winter")
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

			//if(prob(0.02)&& !(locate(/obj/spawns/spawnpointB1) in oview(30, src)) )
				//new/obj/spawns/spawnpointB1(src)

			// Trees
			if(prob(1.02))
				for(var/turf/t in view(2, src))
					if(!t.spawn_resources || prob(80)) continue
					if(	!(locate(/obj/plant/UeikTreeA)	in src) && \
					!(locate(/obj/plant/UeikTreeH)	in src) && \
					!(locate(/turf/water)	in src) && \
					!(locate(/obj/Rocks/Cliffs)	in src) && \
					!(locate(/obj/border/temperate)	in src) && \
					!(locate(/obj/plant/ueiktree)	in src))
			//else if(prob(1) && !(locate(/obj/plant/ueiktree) in view(1, src)) && !(locate(/obj/plant/UeikTreeA) in view(1, src))&& !(locate(/obj/plant/UeikTreeH) in view(1, src)) )
						//if(! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t) && ! (locate(/obj/plant/ueiktree) in t) && ! (locate(/obj/Plants/Bush/Blueberrybush) in t) && ! (locate(/obj/plant/ueiktree/ueikstump) in t))

						new/obj/plant/UeikTreeA(src)
						//if(! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t) && ! (locate(/obj/plant/ueiktree) in t) && ! (locate(/obj/Plants/Bush/Blueberrybush) in t) && ! (locate(/obj/plant/ueiktree/ueikstump) in t))
			if(prob(1.02))
				for(var/turf/t in view(2, src))
					if(!t.spawn_resources || prob(80)) continue
					if(	!(locate(/obj/plant/UeikTreeA)	in src) && \
					!(locate(/obj/plant/UeikTreeH)	in src) && \
					!(locate(/turf/water)	in src) && \
					!(locate(/obj/Rocks/Cliffs)	in src) && \
					!(locate(/obj/border/temperate)	in src) && \
					!(locate(/obj/plant/ueiktree)	in src))
						new/obj/plant/UeikTreeH(src)
						//if(! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t) && ! (locate(/obj/plant/ueiktree) in t) && ! (locate(/obj/Plants/Bush/Blueberrybush) in t) && ! (locate(/obj/plant/ueiktree/ueikstump) in t))



			if(prob(0.1))
				for(var/turf/t in view(1, src))
					if(!t.spawn_resources || prob(80)) continue
					if(	!(locate(/obj/plant/UeikTreeA)	in src) && \
					!(locate(/obj/plant/UeikTreeH)	in src) && \
					!(locate(/turf/water)	in src) && \
					!(locate(/obj/Rocks/Cliffs)	in src) && \
					!(locate(/obj/border/temperate)	in src) && \
					!(locate(/obj/plant/ueiktree)	in src))
			//else if(prob(1) && !(locate(/obj/plant/ueiktree) in view(1, src)) && !(locate(/obj/plant/UeikTreeA) in view(1, src))&& !(locate(/obj/plant/UeikTreeH) in view(1, src)) )
						//if(! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t) && ! (locate(/obj/plant/ueiktree) in t) && ! (locate(/obj/Plants/Bush/Blueberrybush) in t) && ! (locate(/obj/plant/ueiktree/ueikstump) in t))
							//if(prob(0.01))
						new/obj/items/Logs/UeikLog(t)

			if(prob(0.1))
				for(var/turf/t in view(1, src))
					if(!t.spawn_resources || prob(80)) continue
					if(	!(locate(/obj/plant/UeikTreeA)	in src) && \
					!(locate(/obj/plant/UeikTreeH)	in src) && \
					!(locate(/turf/water)	in src) && \
					!(locate(/obj/Rocks/Cliffs)	in src) && \
					!(locate(/obj/border/temperate)	in src) && \
					!(locate(/obj/plant/ueiktree)	in src))
						if(! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t) && ! (locate(/obj/plant/ueiktree) in t) && ! (locate(/obj/Plants/Bush/Blueberrybush) in t) && ! (locate(/obj/Plants/Bush/Raspberrybush) in t) && ! (locate(/obj/plant/ueiktree/ueikstump) in t))

							new/obj/plant/ueiktree/ueikstump(t)

						//else if(! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t) && ! (locate(/obj/plant/ueiktree) in t) && ! (locate(/obj/Plants/Bush/Raspberrybush) in t))
							//new/obj/Plants/Bush/Blueberrybush(t)

			// Bushes
			if(prob(10.02))
				for(var/turf/t in view(2, src))
					if(!t.spawn_resources || prob(80)) continue
					if(	!(locate(/obj/plant/UeikTreeA)	in src) && \
					!(locate(/obj/plant/UeikTreeH)	in src) && \
					!(locate(/turf/water)	in src) && \
					!(locate(/obj/Rocks/Cliffs)	in src) && \
					!(locate(/obj/border/temperate)	in src) && \
					!(locate(/obj/plant/ueiktree)	in src))
			//else if(prob(1) && !(locate(/obj/plant/ueiktree) in view(1, src)) && !(locate(/obj/plant/UeikTreeA) in view(1, src))&& !(locate(/obj/plant/UeikTreeH) in view(1, src)) )
						if(prob(10.02)&&! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t) && ! (locate(/obj/plant/ueiktree) in t) && ! (locate(/obj/Plants/Bush/Blueberrybush) in t) && ! (locate(/obj/plant/ueiktree/ueikstump) in t))
							new/obj/Plants/Bush/Raspberrybush(t)
						else if(prob(10.02)&&! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t) && ! (locate(/obj/plant/ueiktree) in t) && ! (locate(/obj/Plants/Bush/Raspberrybush) in t)&& ! (locate(/obj/plant/ueiktree/ueikstump) in t))
							new/obj/Plants/Bush/Blueberrybush(t)

			if(prob(10))
				for(var/turf/t in view(1, src))
					if(!t.spawn_resources) continue
					if(	!(locate(/obj/plant/UeikTreeA)	in t) && \
					!(locate(/obj/plant/UeikTreeH)	in t) && \
					!(locate(/turf/water)	in t) && \
					!(locate(/obj/Rocks/Cliffs)	in t) && \
					!(locate(/obj/border/temperate)	in src) && \
					!(locate(/obj/plant/ueiktree)	in t))
						if(!(locate(/obj/plant/UeikTreeH) in view(1, t)) && !(locate(/obj/plant/UeikTreeA) in view(1, t)) && !(locate(/obj/plant/ueiktree) in view(1, t)) && !(locate(/obj/Plants/Bush/Blueberrybush) in view(1, t)) && !(locate(/obj/Plants/Bush/Raspberrybush) in view(1, t)) && !(locate(/obj/plant/ueiktree/ueikstump) in view(1, t)))
							var/obj/plant/ueiktree/UT
							new/obj/plant/ueiktree(src)
							if((locate(UT) in view(1,t)))
								for(t in oview(1,UT))
									new/obj/plant/ueiktree(t)
			if(prob(0.01))
				new/obj/plant/ueiktree(src)

			//if(prob(0.3))
			//	new/obj/Plants/Bush/Raspberrybush(src)
			//else if(prob(0.3))
			//	new/obj/Plants/Bush/Blueberrybush(src)



			for(var/turf/t in view(5, src))
				if(!t.spawn_resources)// continue
					if(!(locate(/turf/nostart)	in src) && \
						!(locate(/turf/water)	in src) && \
						!(locate(/obj/border/water)	in src) && \
						!(locate(/obj/border/temperate)	in src) && \
						!(locate(/obj/Rocks/Cliffs)	in src))
						if(prob(0.01))
							new/turf/start(src)


			// Flowers
			if(prob(0.5)&&!(locate(/obj/Flowers) in view(1, src)))
				new/obj/Flowers/Blueflower(src)
			else if(prob(0.5)&&!(locate(/obj/Flowers) in view(1, src)))
				new/obj/Flowers/Lightpurpflower(src)
			else if(prob(0.5)&&!(locate(/obj/Flowers) in view(1, src)))
				new/obj/Flowers/Pinkflower(src)
			else if(prob(0.5)&&!(locate(/obj/Flowers) in view(1, src)))
				new/obj/Flowers/Purpflower(src)
			else if(prob(0.7)&&!(locate(/obj/Flowers) in view(1, src)))
				new/obj/Flowers/Redflower(src)
			else if(prob(1.0)&&!(locate(/obj/Flowers) in view(1, src)))
				new/obj/Flowers/Tallgrass(src)

			// Deposits
			if(prob(0.1))
				new/turf/TarPit(src)
			else if(prob(0.1))
				new/turf/ClayDeposit(src)
			else if(prob(0.1))
				new/turf/ObsidianField(src)
			else if(prob(0.1))
				new/turf/Sand2(src)
			else if(prob(0.1)&&!(locate(/obj/Soil) in view(1, src)))
				new/obj/Soil/richsoil(src)
			else if(prob(0.1)&&!(locate(/obj/Soil) in view(1, src)))
				new/obj/Soil/soil(src)