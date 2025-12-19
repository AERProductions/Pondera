/*
CODE FILES
==========
	files.dm
		This file, providing a list of the files in the library.

	sd_MapMaker.dm
		Defines the sd_MapMaker datum as a generic parent for the
		various types of maps. (see the built in MAP TYPES below.)

	sd_MapMatrix.dm
		Defines the sd_MapMatrix datum, which determines
		connecivity between map nodes for the sd_MapMakers.

	sd_MapProcs.dm
		A couple useful procs for making maps.

		sd_GetEmptyTurf(z, minx = 1, miny = 1, maxx = world.maxx,\
			maxy = world.maxy, maxcount = 0, block = 0)

			Finds an empty nondense turf within a block on a specific z level.

		sd_PathTurfs(turf/start, turf/end, pathtype, min_width = 1,\
			max_width = 1, jaggedness=0, w_variance = 0, taper = 0)

			Creates a path from start to end. Intended For creating anything
			from a narrow dungeon corridors to winding caverns of varying width.

	sd_MapRoom.dm
		Defines the sd_MapRoom datum, used to define and keep track
		of rooms of various sizes and shapes. See the Room Type Files
		below for specialized sd_MapRoom types.

	sd_MapSuite.dm
		Information about how to use this library.

DEMO FILES
----------
	demoforms.dm
		Uses HTMLlib to give a form based interface to the demo. This
		allows you to enter any parameters you like to try out
		different map styles.

	demopresets.dm
		Provides presets for the FullMaze and Rogue-like styles to let users
		see some of the variety available.

	mapdemo.dm
		The core of the demo. This file sets up the map size, icons,
		and some demonstrative commands.

	mapdisplaydemo.dm
		A very crude map display using ASCII characters. This is an
		early version of the map display used in Darke Dungeon, and
		you can use it as a demo to build your own map display system.

MAP TYPE FILES
--------------
	ClassicRogue.dm
		A classic rogue-like map: several rooms in a loose grid with
		passages between them.

	FullMaze.dm (From the original darke_MapMaker libary.)
		Fills the entire map space with a maze of desired complexity.
		A wide range of options allow for a staggering degree of
		customization.

	Multipath.dm
		An experimental map type meant to create more chaotic caverns
		and natural maps in a rogue-like style. I abandoned this
		method and use a rogue-like map with no rooms, high width
		variance, and fairly high jaggedness for caverns in Darke
		Dungeon.

ROOM TYPE FILES
---------------
	Diamond.dm
		Defines sd_MapRoom/diamond, which creates diamond shaped rooms.

	IsoTriangle.dm
		Defines sd_MapRoom/iso_triangle, which creates rooms shaped like
		an isosceles triangle.

	Oval.dm
		Defines sd_MapRoom/oval, which produces oval rooms.

	Rectangle
		Defines sd_MapRoom/rectangle, which uses a more specialized
		Border() proc for greater efficiency.

	RoundedRect
		Defines sd_MapRoom/rounded_rect, which produces an ovaloid room
		resembling a rounded rectangle.

	Star
		Defines sd_MapRoom/star, which produces rooms shaped like a
		diamond with concave sides.
*/
