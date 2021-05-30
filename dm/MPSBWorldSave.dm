//the beginning of the new world save/load made by awesome programmer, F0lak!

var
	map_save_manager/save_manager

world
	New()
		..()
		save_manager = new



// CHUNKING

#define DEBUG_MAPSAVE FALSE  // This should only be on for testing and debugging purposes

#if DEBUG_MAPSAVE
#warn DEBUG_MAPSAVE is on
#endif

var
	const
		current_z_level = 2	// the current z level in the game being saved and loaded

proc
	// Sends a debug message to wherever you would like.
	// defaults to world.log
	MSDebugOutput(msg)
		world.log << "Map Save Debug: [msg]"

map_save_manager

	var
		save_chunks[]	// list of all of the save chunks, to loop through

		// Inclusive list of all of the object types that need to be saved
		// Any types not included will be skipped over during map save

		chunkx = 10	// how wide each save chunk is
		chunky = 10	// how tall each save chunk is



	New()
		save_chunks = new

		if(!chunkx)
			#if DEBUG_MAPSAVE
			MSDebugOutput("chunkx is undefined, defaulting to world.maxx/100 ([world.maxx / 10])")
			#endif
			chunkx = world.maxx / 10

		if(!chunky)
			#if DEBUG_MAPSAVE
			MSDebugOutput("chunky is undefined, defaulting to chunkx")
			#endif
			chunky = chunkx

		#if DEBUG_MAPSAVE
		MSDebugOutput("map_save chunk size is set to [chunkx] x [chunky]")
		#else
		MSDebugOutput("DEBUG_MAPSAVE is turned off.  No debugging information will be logged")
		#endif

		for(var/_x = 0, _x < world.maxx / chunkx, _x++)
			for(var/_y = 0, _y < world.maxy / chunky, _y++)

				#if DEBUG_MAPSAVE
				MSDebugOutput("Chunking at [_x], [_y]")
				#endif

				var/save_chunk/new_chunk = new/save_chunk (src, _x, _y)
				save_chunks.Add(new_chunk)


save_chunk

	var
		turfs[0]
		objects[0]
		map_save_manager/manager

		exclude_types[0]

		x
		y

	New(map_save_manager/msm, _x, _y)
		..()
		manager = msm

		x = _x * manager.chunkx
		y = _y * manager.chunky

		PopulateTurfs()

		if(length(turfs) <= 0)
			del src

	proc
		PopulateTurfs()
			turfs = new
			for(var/_x = 1, _x <= manager.chunkx, _x++)
				for(var/_y = 1, _y <= manager.chunky, _y++)
					var/turf/t = locate(_x + x, _y + y, current_z_level)
					if(t)
						turfs.Add(t)


		PopulateObjects()
			objects = new
			for(var/turf/t in turfs)
				for(var/obj/o in t)
					if(!(o.type in exclude_types))
						objects.Add(o)


// Saving and Loading


//	Map Save macros
#define LOAD_FLAG	1
#define SAVE_FLAG	2
#define ALL_FLAG	3

#define MAPSAVE ALL_FLAG//0 turns off map saving ALL_FLAG = on

#if MAPSAVE==FALSE
#warn MAPSAVE is off
#endif

var
	MAP_SAVE = MAPSAVE

	map_loading = 0
	map_loaded = FALSE  // when the map is loaded, it turns this bool on to prevent the generator from running amok
	save_areas[0]

atom
	var
		saved_x
		saved_y
		saved_z
		saveable
		no_save
		save_category = "atom"
		buildingowner
		//deedname[]
		//deedowner[]
		//deedallow[]

turf/save_category = "turfs"
obj/save_category = "objs"
mob/save_category = "mobs"

savedatum

var last_save
var save_period = 1440	//	minutes

mob/players/Special1/verb
	set_save_period() save_period = input(src, "How many minutes should the auto-saver wait between saves?", "Save Period", save_period) || save_period

	Save_All()
		world.save_all()
		world << "World Saved."
	Load_Map()
		world.load_all()
		world << "World Loaded."

world
	proc
		save_all(gradual = TRUE)

			#if DEBUG_MAPSAVE
			MSDebugOutput("Saving everything...")
			#endif


			if(MAP_SAVE & SAVE_FLAG)

				if(gradual) sleep(-1)

				var saved_stuff[0]
				for(var/save_chunk/chunk in save_manager.save_chunks)
					world.log << chunk
					chunk.save(gradual)
					saved_stuff += chunk.saved_stuff
					if(gradual) sleep(-1)

				var types[0]
				for(var/atom/o in saved_stuff)
					types[o.type] ++

				var log = "Saved Stuff ([types.len] thing\s):"
				for(var/type in types)
					log += {"
[types[type]]	[type]\s"}

				fdel("Data/Map/saved stuff.txt")
				text2file(log, "Data/Map/saved stuff.txt")

			#if DEBUG_MAPSAVE
			MSDebugOutput("Everything saved.")
			#endif

		load_all(gradual = TRUE)
			#if DEBUG_MAPSAVE
			MSDebugOutput("Loading everything...")
			#endif
			if(MAP_SAVE & LOAD_FLAG)
				map_loading = 1

				var loaded_stuff[0]
				for(var/save_chunk/chunk in save_manager.save_chunks)
					map_loading ++
					chunk.load(gradual)
					loaded_stuff += chunk.loaded_stuff
					if(gradual) sleep(-1)

				var types[0]
				for(var/atom/movable/o in loaded_stuff)
					types[o.type] ++

				var log = "Loaded Stuff ([types.len] thing\s):"
				for(var/type in types)
					log += {"
[types[type]]	[type]\s"}

				fdel("Data/Map/loaded stuff.txt")
				text2file(log, "Data/Map/loaded stuff.txt")

				map_loading = 0
				if(loaded_stuff.len > 0) map_loaded = TRUE

			else world.log << "MAP_SAVE is off"

	proc
		StartMapSave()
			if(save_areas.len)
				load_all()
				if(MAP_SAVE & SAVE_FLAG)
					SaveLoop()

	proc/SaveLoop()
		set waitfor = FALSE
		for()
			sleep 1
			if(world.time >= last_save + save_period * 600)
				last_save = world.time
				save_all(TRUE)

	Del()
		save_all()
		..()

savedatum

	var
		data[0]

		save_x
		save_y
		save_z
		save_sx
		save_sy
		save_dir
		save_type
		save_contents[]
		save_name
		save_state
		save_opacity
		save_density
		save_bounds
		save_gender
		save_invisibility

		save_vis_contents[]

		//Sandbox Owner
		save_buildingowner

		//Deeds
		save_deedname[]
		save_deedowner[]
		save_deedallow[]

		//Lamp Planted state
		save_planted

		//Item Stacking
		save_stack_amount

		//vars to save for rocks
		save_ore_amount

		//vars to save for ueiktrees
		save_log_amount
		save_sprout_amount

		save_seed_amount
		save_grain_amount
		save_fruit_amount
		save_veg_amount

		atom/saved_item

	proc

		load()
			var/path = text2path(save_type)
			if(!path)
				world.log << "Path caught: [save_type]!"
				return

			if(ispath(path, /turf))
				var/turf/item = new path (locate(save_x, save_y, save_z))
				ASSERT(item)

				item.dir = save_dir
				item.name = save_name
				item.buildingowner = save_buildingowner
				item.icon_state = save_state
				item.opacity = save_opacity
				item.density = save_density
				if(save_vis_contents) item.vis_contents = save_vis_contents


			else
				var turf/saved_loc = locate(save_x, save_y, save_z)
				var/atom/movable/item = new save_type (saved_loc)
				ASSERT(item)

				item.loc = locate(save_x, save_y, save_z)
				if(save_contents) item.contents = save_contents

				item.dir = save_dir
				item.name = save_name
				if(save_buildingowner) item.vars["buildingowner"] = save_buildingowner
				item.icon_state = save_state
				item.opacity = save_opacity
				item.density = save_density
				if(save_stack_amount) item.vars["stack_amount"] = save_stack_amount
				if(save_planted) item.vars["Planted"] = save_planted
				//item.stack_amount = save_stack_amount

				if(save_gender) item.gender = save_gender

				if(save_bounds) item.bounds = save_bounds

				if(save_invisibility) item.invisibility = save_invisibility

				if(save_vis_contents) item.vis_contents = save_vis_contents




				// BEGIN Resource Loading
				if(save_ore_amount)		item.vars["OreAmount"]		=	save_ore_amount
				if(save_log_amount)		item.vars["LogAmount"]		=	save_log_amount
				if(save_sprout_amount)	item.vars["SproutAmount"]	=	save_sprout_amount
				if(save_seed_amount)	item.vars["SeedAmount"]		=	save_seed_amount
				if(save_grain_amount)	item.vars["GrainAmount"]	=	save_grain_amount
				if(save_fruit_amount)	item.vars["FruitAmount"]	=	save_fruit_amount
				if(save_veg_amount)		item.vars["VegeAmount"]		=	save_veg_amount
				// END Resource Loading


			/*if(ispath(path, /region))
				var/region/deed/item = new path (locate(save_x, save_y, save_z))
				ASSERT(item)
				if(save_deedname)		item.deedname		=	save_deedname
				if(save_deedowner)		item.deedowner		=	save_deedowner
				if(save_deedallow)		item.deedallow		=	save_deedallow*/



		save(atom/saver)

			ASSERT(saver)

			if(istype(saver, /turf))
				var/turf/item = saver
				save_x = item.x
				save_y = item.y
				save_z = item.z
				save_type = "[item.type]"
				save_state = item.icon_state
				save_dir = item.dir
				save_name = item.name
				save_density = item.density
				save_vis_contents = item.vis_contents
				save_buildingowner = item.buildingowner



			else if(istype(saver, /atom/movable))
				var/atom/movable/item = saver
				save_x = item.x
				save_y = item.y
				save_z = item.z

				save_type = "[item.type]"
				save_dir = item.dir
				save_name = item.name
				save_vis_contents = item.vis_contents

				save_gender = item.gender

				save_state = item.icon_state
				save_density = item.density
				save_opacity = item.opacity
				save_invisibility = item.invisibility
				//save_stack_amount = item.stack_amount

				save_sx = item.step_x
				save_sy = item.step_y

				if(item.bounds != initial(item.bounds))
					save_bounds = item.bounds

				if(item.contents.len)
					save_contents = item.contents

				//save_buildingowner = item.buildingowner

				//if(item.deedname.len)
					//save_deedname = item.deedname

				//if(item.deedowner.len)
				//	save_deedowner = item.deedowner

				//Deed
				/*if(istype(item, /obj/DeedToken))
					var/obj/DeedToken/DT = item
					save_buildingowner = DT.buildingowner
					save_deedallow = DT.deedallow
					save_deedname = DT.deedname
					save_deedowner = DT.deedowner*/
				if(istype(item, /obj/items/Buildable/lamps))
					var/obj/items/Buildable/I = item
					save_planted = I.Planted
				// Resources
				if(istype(item, /obj/items))
					var/obj/items/I = item
					save_stack_amount = I.stack_amount

				if(istype(item, /obj/Rocks/OreRocks))
					var/obj/Rocks/OreRocks/rock = item
					save_ore_amount = rock.OreAmount


				if(istype(item, /obj/plant/ueiktree))
					var/obj/plant/ueiktree/ueiktree = item
					save_log_amount		=	ueiktree.LogAmount
					save_sprout_amount	=	ueiktree.SproutAmount

				if(istype(item, /obj/Plants/Bush))
					var/obj/Plants/Bush/bush = item
					save_seed_amount	=	bush.SeedAmount
					save_fruit_amount	=	bush.FruitAmount

				if(istype(item, /obj/Plants/Vegetables))
					var/obj/Plants/Vegetables/veg = item
					save_seed_amount	=	veg.SeedAmount
					save_veg_amount		=	veg.VegeAmount

				if(istype(item, /obj/Plants/Grain))
					var/obj/Plants/Grain/grain = item
					save_seed_amount	=	grain.SeedAmount
					save_grain_amount	=	grain.GrainAmount

			/*else if(istype(saver, /region))
				var/region/deed/item = saver
				if(istype(item, /region/deed))
					var/region/deed/deed = item
					if(item.deedname.len)
						save_deedname = deed.deedname
					if(item.deedallow.len)
						save_deedallow = deed.deedallow
					if(item.deedowner.len)
						save_deedowner = deed.deedowner*/
					//save_deedname = deed.deedname
					//save_deedowner = deed.deedowner
					//save_deedallow = deed.deedallow

			return 1




save_chunk
	var saved_stuff[0]
	var loaded_stuff[0]

	New()
		..()
		save_areas += src
		#if DEBUG_MAPSAVE
		MSDebugOutput("New Chunk: [x],[y]-[x+manager.chunkx-1],[y+manager.chunky-1]")
		#endif

	proc
		save_path() return "MapSaves/Chunk [x],[y]-[x+manager.chunkx-1],[y+manager.chunky-1].sav"

		save(gradual = FALSE)
			saved_stuff = new

			var path = save_path()
			if(fexists(path)) fdel(path)

			var savefile/savefile = new (path)

			var savelist[]
			var save

			savelist = new

			// Save turfs
			for(var/turf/item in turfs)
				if(item.no_save) continue
				if(gradual) sleep(-1)

				var/savedatum/newsave = new /savedatum
				if(newsave.save(item))
					savelist += newsave

				saved_stuff += item

			if(savelist.len)
				save = 1
				savefile["turf"] << savelist

			if(gradual) sleep(-1)

			// save all objects

			PopulateObjects()

			for(var/obj/item in objects)
				if(item.no_save) continue
				if(gradual) sleep(-1)

				var/savedatum/newsave = new /savedatum
				if(newsave.save(item))
					savelist += newsave

				saved_stuff += item

			if(savelist.len)
				save = 1
				savefile["obj"] << savelist

			if(gradual) sleep(-1)
			// Finished Saving

			if(!save) fdel(path)
			//else if(saved_stuff.len) world.log << "([time2text(world.timeofday)]) Saved [save_path()]"

		load(gradual = FALSE)
			loaded_stuff = new

			var path = save_path()
			var loadlist[0]

			if(path && fexists(path))
				var savefile/savefile = new (path)

				for(var/a in savefile)
					savefile["[a]"] >> loadlist

					for(var/savedatum/item in loadlist)
						item.load()
						loaded_stuff += item.saved_item
						if(gradual) sleep (-world.tick_lag)

		//		if(loaded_stuff.len) world.log << "([time2text(world.timeofday)]) Loaded [name]"
				return 1
			else
				//world.log << "invalid load path: [path]"
				return 0