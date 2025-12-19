#include <dantom\htmllib\htmllib.dme>

client/Topic(href,hlist[])
	if(hlist["style"])
		switch(hlist["style"])
			if("fullmaze")
				var/Form/FullMaze/F = new()
				usr = mob
				F.DisplayForm()
			if("rogue")
				var/Form/Rogue/F = new()
				usr = mob
				F.DisplayForm()

	..()

Form
	form_reusable = 1
	//form_window = "window=democontrol"
	form_title = "sd_MapMaker Demo Control Panel"
	submit = "Generate\nMap"

Form/FullMaze
	var
		MapReport
		MapReport_interface = CHECKBOX
		open_chance = 0
		open_chance_size = 3
		passage_chance = 0
		passage_chance_size = 3
		node_x = 3	// horizontal size of a node
		node_x_size = 3
		node_y = 3	// vertical size of a node
		node_y_size = 3
		no_deadends = 1
		no_deadends_interface = CHECKBOX
		solid_border = 1
		solid_border_interface = CHECKBOX
		fill_excess = 1
		fill_excess_interface = CHECKBOX

		room_x = 0	// maximum horizontal size of a room
		room_x_size = 3
		room_y = 0	// maximum vertical size of a room
		room_y_size = 3

		border_x = 1	// horizontal thickness of border spaces
		border_x_size = 3
		border_y = 1	// vertical thickness of border spaces
		border_y_size = 3

		clear_columns
		clear_columns_size = 3
		check_passage
		check_passage_size = 3

		show_map = 1
		show_map_interface = CHECKBOX

	Initialize()
		MapReport = sd_MapReport
		open_chance = "[Maze.open_chance]"
		passage_chance = "[Maze.passage_chance]"
		node_x = "[Maze.node_x]"
		node_y = "[Maze.node_y]"
		no_deadends = Maze.no_deadends
		solid_border = Maze.solid_border
		fill_excess = Maze.fill_excess

		room_x = "[Maze.room_x]"
		room_y = "[Maze.room_y]"

		border_x = "[Maze.border_x]"
		border_y = "[Maze.border_y]"

		clear_columns = "[Maze.clear_columns]"
		check_passage = "[Maze.check_passage]"

	HtmlLayout()
		. = {"<table width=100%><tr><th align=left>Full Maze Style</th>\
<td align=right><a href=byond://?style=rogue><small>switch to Classic Rogue Style.</small></a></td></tr>
</table><table>
<tr><td>open_chance</td><td>[open_chance]%</td></tr>
<tr><td>passage_chance</td><td>[passage_chance]%</td></tr>
<tr><td>Node size</td><td>[node_x] x [node_y]</td></tr>
<tr><td>Room size</td><td>[room_x] x [room_y]</td></tr>
<tr><td>Border size</td><td>[border_x] x [border_y]</td></tr>
<tr><td>No deadends</td><td>[no_deadends]</td></tr>
<tr><td>Clear lone columns</td><td>[clear_columns]%</td></tr>
<tr><td>Passage check</td><td>[check_passage]%</td></tr>
<tr><td>Solid border</td><td>[solid_border]</td></tr>
<tr><td>Fill excess</td><td>[fill_excess]</td></tr>

</table><table width=100%>
<tr><td>[MapReport] report map making data<br>[show_map] display full map when done</td><td align=right>[submit]</td></tr>
</table>"}

	ProcessForm()
		sd_MapReport = MapReport
		Maze.open_chance = text2num(open_chance)
		Maze.passage_chance = text2num(passage_chance)
		Maze.node_x = text2num(node_x)
		Maze.node_y = text2num(node_y)
		Maze.no_deadends = no_deadends
		Maze.solid_border = solid_border
		Maze.fill_excess = fill_excess

		Maze.room_x = text2num(room_x)
		Maze.room_y = text2num(room_y)

		Maze.border_x = text2num(border_x)
		Maze.border_y = text2num(border_y)

		Maze.clear_columns = text2num(clear_columns)
		Maze.check_passage = text2num(check_passage)
		// choose a random floor type for Maze.map_passages
		Maze.map_floor = pick(mapfloor)
		Maze.Generate()
		if(usr.density && usr.loc.density)
			var/turf/T = sd_GetEmptyTurf(1)
			if(T) usr.Move(T)
		if(show_map) usr.fullmap()


Form/Rogue
	var
		MapReport
		MapReport_interface = CHECKBOX
		open_chance = 0
		open_chance_size = 3
		passage_chance = 0
		passage_chance_size = 3
		node_x = 3	// horizontal size of a node
		node_x_size = 3
		node_y = 3	// vertical size of a node
		node_y_size = 3
		no_deadends = 1
		no_deadends_interface = CHECKBOX
		solid_border = 1
		solid_border_interface = CHECKBOX
		fill_excess = 1
		fill_excess_interface = CHECKBOX
		min_w = 1	// minimum horizontal size of a room
		min_w_size = 3
		min_h = 1	// minimum vertical size of a room
		min_h_size = 3

		max_w = 10	// maximum horizontal size of a room
		max_w_size = 3
		max_h = 10	// maximum vertical size of a room
		max_h_size = 3

		path_min = 1	// minimum width of the paths
		path_min_size = 3
		path_max = 1	// maximum width ot the paths
		path_max_size = 3
		path_vary = 0
		path_vary_size = 3
		path_jag = 20
		path_jag_size = 3
		path_taper = 0
		path_taper_interface = CHECKBOX

		room_default = 1
		room_default_interface = CHECKBOX
		room_diamond = 0
		room_diamond_interface = CHECKBOX
		room_isotri = 0
		room_isotri_interface = CHECKBOX
		room_oval = 0
		room_oval_interface = CHECKBOX
		room_roundrect = 0
		room_roundrect_interface = CHECKBOX
		room_star = 0
		room_star_interface = CHECKBOX
		room_maze = 0
		room_maze_interface = CHECKBOX
		room_maze2 = 0
		room_maze2_interface = CHECKBOX

		show_map = 1
		show_map_interface = CHECKBOX


	Initialize()
		if(MapReport) sd_MapReport = world.contents
		else sd_MapReport = null
		open_chance = "[Rogue.open_chance]"
		passage_chance = "[Rogue.passage_chance]"
		node_x = "[Rogue.node_x]"
		node_y = "[Rogue.node_y]"
		no_deadends = Rogue.no_deadends
		solid_border = Rogue.solid_border
		fill_excess = Rogue.fill_excess
		min_w = "[Rogue.min_w]"
		min_h = "[Rogue.min_h]"
		max_w = "[Rogue.max_w]"
		max_h = "[Rogue.max_h]"
		if(/sd_MapRoom in Rogue.roomtypes) room_default = 1
		else room_default = 0
		if(/sd_MapRoom/diamond in Rogue.roomtypes) room_diamond = 1
		else room_diamond = 0
		if(/sd_MapRoom/iso_triangle in Rogue.roomtypes) room_isotri = 1
		else room_isotri = 0
		if(/sd_MapRoom/oval in Rogue.roomtypes) room_oval = 1
		else room_oval = 0
		if(/sd_MapRoom/rounded_rect in Rogue.roomtypes) room_roundrect = 1
		else room_roundrect = 0
		if(/sd_MapRoom/star in Rogue.roomtypes) room_star = 1
		else room_star = 0
		if(/sd_MapRoom/maze in Rogue.roomtypes) room_maze = 1
		else room_maze = 0
		if(/sd_MapRoom/maze/double_wide in Rogue.roomtypes) room_maze2 = 1
		else room_maze2 = 0
		path_min = "[Rogue.path_min]"
		path_max = "[Rogue.path_max]"
		path_vary = "[Rogue.path_vary]"
		path_jag = "[Rogue.path_jag]"
		path_taper = Rogue.path_taper

	HtmlLayout()
		. = {"<table width=100%><tr><th align=left>Classic Rogue Style</th>\
<td align=right><a href=byond://?style=fullmaze><small>switch to Full Maze Style.</small></a></td></tr>
</table><table>
<tr><td>open_chance</td><td>[open_chance]%</td></tr>
<tr><td>passage_chance</td><td>[passage_chance]%</td></tr>
<tr><td>Node size</td><td>[node_x] x [node_y]</td></tr>
<tr><td>Room width range</td><td>[min_w] - [max_w]</td></tr>
<tr><td>Room height range</td><td>[min_h] - [max_h]</td></tr>
<tr><td>Room Types:</td><td>
<table><tr><td>Default</td><td>[room_default]</td><td>|</td>
<td>Diamond</td><td>[room_diamond]</td></tr>
<tr><td>IsoTriangle</td><td>[room_isotri]</td><td>|</td>
<td>Oval</td><td>[room_oval]</td></tr>
<tr><td>Rounded Rect</td><td>[room_roundrect]</td><td>|</td>
<td>Star</td><td>[room_star]</td></tr>
<tr><td>Maze</td><td>[room_maze]</td><td>|</td>
<td>Double Wide Maze</td><td>[room_maze2]</td></tr></table>
</td></tr>
<tr><td>Path width range</td><td>[path_min] - [path_max]</td></tr>
<tr><td>Path width variance</td><td>[path_vary]%</td></tr>
<tr><td>Path jaggedness</td><td>[path_jag]%</td></tr>
<tr><td>Path taper</td><td>[path_taper]</td></tr>
<tr><td>No deadends</td><td>[no_deadends]</td></tr>
<tr><td>Solid border (recommended)</td><td>[solid_border]</td></tr>
<tr><td>fill excess (recommended)</td><td>[fill_excess]</td></tr>

</table><table width=100%>
<tr><td>[MapReport] report map making data<br>[show_map] display full map when done</td><td align=right>[submit]</td></tr>
</table>"}

	ProcessForm()
		if(MapReport) sd_MapReport = world.contents
		else sd_MapReport = null
		Rogue.open_chance = text2num(open_chance)
		Rogue.passage_chance = text2num(passage_chance)
		Rogue.node_x = text2num(node_x)
		Rogue.node_y = text2num(node_y)
		Rogue.no_deadends = no_deadends
		Rogue.solid_border = solid_border
		Rogue.fill_excess = fill_excess
		Rogue.min_w = text2num(min_w)
		Rogue.min_h = text2num(min_h)
		Rogue.max_w = text2num(max_w)
		Rogue.max_h = text2num(max_h)
		Rogue.path_min = text2num(path_min)
		Rogue.path_max = text2num(path_max)
		Rogue.path_vary = text2num(path_vary)
		Rogue.path_jag = text2num(path_jag)
		Rogue.path_taper = path_taper
		Rogue.roomtypes = list()
		if(room_default) Rogue.roomtypes += /sd_MapRoom
		if(room_diamond) Rogue.roomtypes += /sd_MapRoom/diamond
		if(room_isotri) Rogue.roomtypes += /sd_MapRoom/iso_triangle
		if(room_oval) Rogue.roomtypes += /sd_MapRoom/oval
		if(room_roundrect) Rogue.roomtypes += /sd_MapRoom/rounded_rect
		if(room_star) Rogue.roomtypes += /sd_MapRoom/star
		if(room_maze) Rogue.roomtypes += /sd_MapRoom/maze
		if(room_maze2) Rogue.roomtypes += /sd_MapRoom/maze/double_wide
		if(!Rogue.roomtypes.len)
			world << "No room types selected. Using defualt room type."
			Rogue.roomtypes += /sd_MapRoom
		// choose a random floor type for Maze.map_passages
		Rogue.map_floor = pick(mapfloor)
		Rogue.Generate()
		if(usr.density && usr.loc.density)
			var/turf/T = sd_GetEmptyTurf(1)
			if(T) usr.Move(T)
		if(show_map) usr.fullmap()

client/New()
	..()
	spawn(2)
		var/Form/Rogue/F = new()
		usr = mob
		F.DisplayForm()