var/obj/defaultobj = new()

var/list/presets = list()
world/New()
	..()
	for(var/V in typesof(/obj/preset)-/obj/preset)
		presets += new V()

mob/Stat()
	//stat("[x],[y]")
	statpanel("Map Presets")
	stat("Click these to fill out the forms with some interesting values.")
	stat("-------------------")
	stat(presets)

obj/preset
	var
		formtype
		open_chance = 0
		passage_chance = 0
		node_x = 3
		node_y = 3
		no_deadends = 1
		solid_border = 1
		fill_excess = 1

	Click()
		world << "Generating [src] ([desc])\n[suffix]"
		var/sd_MapMaker/maker = Maze
		if(desc == "rogue-like") maker = Rogue
		for(var/V in vars - defaultobj.vars - "formtype")
			maker.vars[V] = vars[V]
		maker.map_floor = pick(mapfloor)
		maker.Generate()
		usr.fullmap()
		var/Form/F = new formtype()
		F.DisplayForm()

	default_full_maze
		formtype = /Form/FullMaze
		desc = "full maze"
		suffix = "The default full maze style map."
		var
			room_x = 0
			room_y = 0

			border_x = 1
			border_y = 1

			clear_columns = 0
			check_passage = 100

		tight_maze
			suffix = "WARNING: This maze may take a while to generate. It's is a very tight maze with only a single solution."
			node_x = 1
			node_y = 1
			no_deadends = 0

		room_maze
			name = "\"room\" maze"
			suffix = "This maze uses the room settings to produce artificial spaces within the maze."
			node_x = 2
			node_y = 2
			border_x = 2
			border_y = 2
			room_x = 20
			room_y = 20

		not_so_mazelike_maze
			suffix = "Uses some of the Full Maze style options to make themaze seem much less like a maze."
			open_chance = 75
			passage_chance = 90
			node_x = 4
			node_y = 4
			clear_columns = 100
			check_passage = 100

	roguelike
		formtype = /Form/Rogue
		desc = "rogue-like"
		suffix = "The default rogue-like style map."
		node_x = 10
		node_y = 10
		passage_chance = 100
		no_deadends = 0
		var
			min_w = 1
			min_h = 1

			max_w = 10
			max_h = 10

			path_min = 1
			path_max = 1
			path_vary = 0
			path_jag = 20
			path_taper = 0
			list
				roomtypes = list(/sd_MapRoom)

		caves
			suffix = "Produces very random almost natural passages. Combine \
				with a rocky wall icon for best results."
			open_chance = 30
			passage_chance = 0
			min_w = 1
			min_h = 1
			max_w = 1
			max_h = 1
			path_min = 1
			path_max = 10
			path_vary = 75
			path_jag = 30
			path_taper = 1

		mazy_roguelike
			suffix = "A large complex maze generated in a fraction of the \
				time required by the tight full maze style, because it \
				makes 16 small mazes and pieces them together."
			node_x = 15
			node_y = 15
			no_deadends = 0
			min_w = 14
			min_h = 14
			max_w = 14
			max_h = 14
			path_min = 1
			path_max = 1
			path_vary = 0
			path_jag = 20
			path_taper = 0
			roomtypes = list(/sd_MapRoom/maze)
