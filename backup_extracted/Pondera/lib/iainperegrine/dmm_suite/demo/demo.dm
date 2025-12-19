/*
	/dmm_suite demo, version 1.0
		Released January 30th, 2011.

	Provides the verb write()
	Provides the verb save("name")

	This demo randomly generates an in-game map of size 7x7x7, and provides the
	user with a verb to save that map as a .dmm file. To use the demo, simply call
	'save_map' with a valid file name ("Test_File" is a valid name, "Test/File.dmm"
	is not valid). The .dmm file can now be found in the /demo directory. The user
	may also use the write() verb to see exactly what the library is writing
	without saving a file on their system. The user can also use the load() verb
	to load a previously saved dmm file.
	*/
/*
	Version History
		1.0
			- Released January 30th, 2011.
			- Rebranded as "dmm_suite" from old dmp_reader/writer demos.
	*/

mob/players/verb/save(var/map_name as text)
	/*
		The save() verb saves a map with name "[map_name].dmm".
		*/
	if((ckey(map_name) != lowertext(map_name)) || (!ckey(map_name)))
		usr << "The file name you supplied includes invalid characters, or is empty. Please supply a valid file name."
		return
	var/dmm_suite/D = new()
	var/turf/south_west_deep = locate(1,1,1)
	var/turf/north_east_shallow = locate(world.maxx,world.maxy,world.maxz)
	D.save_map(south_west_deep, north_east_shallow, map_name, flags = DMM_IGNORE_PLAYERS)
	usr << {"The file [map_name].dmm has been saved. It can be found in the same directly in which this library resides.\n\
 (Usually: C:\\Documents and Settings\\Your Name\\Application Data\\BYOND\\lib\\iainperegrine\\dmm_suite)"}


mob/players/verb/write()
	/*
		The write() verb creates a text string of the map in dmm format
			and displays it in the client's browser.
		*/
	var/dmm_suite/D = new()
	var/turf/south_west_deep = locate(1,1,1)
	var/turf/north_east_shallow = locate(world.maxx,world.maxy,world.maxz)
	var/map_text = D.write_map(south_west_deep, north_east_shallow, flags = DMM_IGNORE_PLAYERS)
	usr << browse("<pre>[map_text]</pre>")


mob/players/verb/load(var/dmm_map as file)
	/*
		The load() verb will ask a player for a dmm file (usually found in the demo
			directory) which it will then load, and transport the user to view it.
		*/
	//Test if dmm_map is a .dmm file.
	var/file_name = "[dmm_map]"
	var/file_extension = copytext(file_name,length(file_name)-2,0)
	if(file_extension != "dmm")
		usr << "Supplied file must be a .dmm file."
		return
	//Determine where the new .dmm file will be loaded.
	var/new_maxz = world.maxz+1
	//Instanciate a new dmm_suite object.
	var/dmm_suite/new_reader = new()
	//Call load_map() to load the map file.
	new_reader.load_map(dmm_map, new_maxz)
	//Transport the user to the new map's z level.
	src.z = new_maxz




/*
	The rest of this file defines a demo world of uninteresting nonsense.
	Basically, it randomly places objects, and then randomizes their attributes,
	so the demo has something to put into the map file.
	*/
/*world
	maxx = 7
	maxy = 7
	maxz = 7
	New()
		.=..()
		spawn(10)
			for(var/atoms_left=120;atoms_left;atoms_left--)
				var/atom_type
				switch(rand(1,3))
					if(1) atom_type=pick(typesof(/turf))
					if(2) atom_type=pick(typesof(/obj ))
					if(3) atom_type=pick(typesof(/mob ))
				var/turf/new_loc = locate(rand(1,world.maxx),rand(1,world.maxy),rand(1,world.maxz))
				sleep(-1)
				new atom_type(new_loc)

atom
	icon = 'demo.dmi'

turf
	icon_state = "grass"
	_1
		icon_state = "ledge"
		density = 1

obj
	var
		test_num = 1
		test_txt = "Test"
	New()
		.=..()
		spawn(1)
			dir = dir
			test_num = rand(0,255)
			test_txt = ascii2text(rand(97,122)) + ascii2text(rand(65,90))
	icon_state = "flowers_yellow"
	_1
		icon_state = "flowers_red"

mob
	icon_state = "clams"
	var/test_file as file
	New()
		.=..()
		dir = pick(1,4)
		if(rand(0,5) == 5)
			test_file = 'demo.txt'
	Login()
		.=..()
		tag = key
		icon_state = "mob"*/