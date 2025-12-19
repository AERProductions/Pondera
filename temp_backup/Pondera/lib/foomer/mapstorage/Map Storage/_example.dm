
// So we can move freely around the map....
mob
	density = 0




/*************************************************************************
DEFINING OUR OWN MAP STORAGE DATUM
**************************************************************************/

// Create a new instance of the map storage datum.
var/map_storage/map_save/map_save = new()

map_storage/map_save
	game_id = "FoomerMaps"

	backdoor_password = "CutiePie"

	ignore_types = list(/mob)

	// This overrides the map_storage library's Output functions so that
	// we can add our own progress meters. Since the library will call
	// these functions every 1% of progress, we're using the probabilty
	// calls to reduce the frequency of the visible updates, since each
	// of these must be followed by a delay in order to display.
	SaveOutput(percent)
		if(prob(10) || percent == 100)
			winset(usr, "status", "text=\"Saving [percent]% done.\"")
			sleep(1)
		return

	LoadOutput(percent)
		if(prob(10) || percent == 100)
			winset(usr, "status", "text=\"Loading [percent]% done\"")
			sleep(1)
		return

	// If you want, you can also override how the library clears the
	// map, just in case you want to include things such as moving players
	// to a save place off the map, or maybe you just don't want anything
	// to be removed when you load a map. What you see here is the default
	// behavior for the ClearMap function.
	ClearMap()
		for(var/turf/T in world)
			for(var/atom/movable/A in T)
				if(ismob(A))
					var/mob/M = A
					if(M.client)
						M.loc = null
						continue
				del(A)
			del(T)
		return



/*************************************************************************
MAP SAVING AND LOADING FUNCTIONS AS USED IN A GAME
**************************************************************************/

// Save the map file.
mob/verb/MapSave()

	// Request a name for this map. If it doesn't have a name cancel this, and if it doesn't
	// have an game_id, then add the .map game_id.
	var/mapname = input(src, "What do you want to name your map?", "Map Name", "My Map") as null|text
	if(!mapname)
		return
	if(copytext(mapname, length(mapname)-3, 0) != ".map")
		mapname += ".map"

	// Ask if the user wants to password-lock the map.
	var/password = input(src, "Save with a password?", "Password", null) as null|text

	// Remove any old files by that name and replace them with the new file.
	fdel(mapname)
	var/savefile/map = new(mapname)

	// Time before we started saving, so we know how long it took.
	var/startsave = world.timeofday

	map_save.Save(map, password)

	world.log << "Map saved as [mapname]! (Time: [(world.timeofday - startsave) / 10] second\s)"
	return



// Load the saved map file.
mob/verb/MapLoad()

	// Find all the map files in the directory, and if there are none, abort.
	var/list/maps = list()
	for(var/file in flist(""))
		if(copytext(file, length(file)-3, 0) == ".map")
			maps += file
	if(!maps.len)
		world.log << "No maps found."
		return

	// Ask the user which map file to load.
	var/mapname = input(src, "Select a map to load.", "Load Map", maps[1]) as null|anything in maps
	if(!mapname)
		return

	if(!fexists(mapname))
		world.log << "No map file."
		return

	var/savefile/map = new(mapname)

	// Make sure that the selected file is a valid map file.
	if(!map_save.IsValid(map))
		world.log << "Invalid map format."
		return

	if(!map_save.Verify(map))
		world.log << "[map] has been tampered with."
		return

	// If the map is password-locked, ask for the password.
	var/password
	if(map_save.PasswordLocked(map))
		password = input(src, "This file requires a password", "Password", null) as null|text
		if(!password)
			return

	// Make sure to move players off the map.
	src.loc = null

	world.log << "Loading map..."
	sleep(1)

	// Time before it started loading, so we know how long it took.
	var/start_time = world.timeofday

	if(map_save.Load(map, password))
		world.log << "Map loaded!"
	else
		world.log << "Map failed to load..."

	// Now we can put players back on the map.
	src.loc = locate(1,1,1)

	world.log << "Loading time: [(world.timeofday - start_time) / 10] second\s"

	return




/************************************************************************/
// OBJECT AND TURF TYPES
/************************************************************************/

obj
	icon = 'items.dmi'
	map_storage_saved_vars = "density;opacity;tag"

	item
		icon_state = "item"

turf
	forest
		map_storage_saved_vars = "density;opacity;tag"


		icon = 'forest.dmi'

		grass1
			icon_state = "grass1"
		grass2
			icon_state = "grass2"
		grass3
			icon_state = "grass3"
		grass4
			icon_state = "grass4"

		flowers1
			icon_state = "flowers1"
		flowers2
			icon_state = "flowers2"

		fern1
			icon_state = "fern1"
		fern2
			icon_state = "fern2"
		fern3
			icon_state = "fern3"
		fern4
			icon_state = "fern4"

		tree_paradise1
			icon_state = "paradise1"
			density = 1
		tree_paradise2
			icon_state = "paradise2"
			density = 1
		tree_paradise3
			icon_state = "paradise3"
			density = 1

		tree1
			icon_state = "tree1"
			density = 1
		tree2
			icon_state = "tree2"
			density = 1
		tree3
			icon_state = "tree3"
			density = 1
		tree4
			icon_state = "tree4"
			density = 1
		tree5
			icon_state = "tree5"
			density = 1
		tree6
			icon_state = "tree6"
			density = 1
		tree7
			icon_state = "tree7"
			density = 1
		tree8
			icon_state = "tree8"

		tree_dead1
			icon_state = "dead1"
			density = 1
		tree_dead2
			icon_state = "dead2"
			density = 1
		tree_dead3
			icon_state = "dead3"
			density = 1
		tree_dead4
			icon_state = "dead4"
			density = 1
		tree_dead5
			icon_state = "dead5"

		rock1
			icon_state = "rock1"
			density = 1
		rock2
			icon_state = "rock2"
			density = 1
		rock3
			icon_state = "rock3"
			density = 1
		rock4
			icon_state = "rock4"
		rock5
			icon_state = "rock5"
		rock6
			icon_state = "rock6"

		shrub
			icon_state = "shrub"
			density = 1

		stump
			icon_state = "stump"
			density = 1

		sign
			icon_state = "sign"
			density = 1







