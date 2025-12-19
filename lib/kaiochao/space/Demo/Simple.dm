/* This is a simple demo showing how to save and load the world map.
	Run this with or without Simple.dmm compiled.
	Poop around and reboot to see them save and load.
*/

#include<kaiochao/shapes/shapes.dme>

var/universe/Universe = new
var/space_storage/SpaceStorage = new

var/const/WorldSpaceName = "Simple"

// After shutting down the world, check the Spaces folder for Simple.sav.

world
	fps = 60
	view = 8
	turf = /turf/grass
	mob = /mob/player

	New()
		..()
		// If pasting a loaded space doesn't work:
		if(!Universe.Paste(SpaceStorage.Load(WorldSpaceName)))
			var/space/world_space // We'll name this WorldSpaceName after initializing it.
			if(maxx) // If there is a compiled map, create a new closed space containing it.
				Universe += world_space = new(locate(1, 1, 1), locate(maxx, maxy, maxz))
			else // If no compiled map, generate a new 25x25x1 map.
				world_space = Universe.Allocate(25, 25, 1)
			SpaceStorage.Name(WorldSpaceName, world_space)

	Del()
		// Save the world space.
		SpaceStorage.Save(WorldSpaceName)
		..()

area
	icon = null

turf/grass
	icon_state = "rect"
	color = rgb(0, 120, 0)

	New()
		..()
		// Set color in a checker pattern.
		if((x + y) & 1)
			color = rgb(0, 128, 0)

	Write(savefile/save)
		..()
		// Don't save color
		save.dir -= "color"

mob/player
	icon_state = "oval"
	step_size = 4

	Login()
		// Try moving to the world space.
		for(var/turf/turf in SpaceStorage.Lookup(WorldSpaceName)?.Turfs())
			if(Move(turf))
				break
		..()

	verb/poo()
		// Make a new poo at your current position.
		var/obj/poo/poo = new(loc)
		poo.step_x = step_x
		poo.step_y = step_y

obj/poo
	icon_state = "oval"

	New()
		..()
		// Give it a random color and elliptical shape.
		color = rgb(rand(255), rand(255), rand(255))
		transform = matrix(rand() + 0.5, rand() + 0.5, MATRIX_SCALE).Turn(rand() * 360)

	Click()
		..()
		// Destroy on click.
		loc = null

	SavesToSpace()
		// We want poo to save to the space.
		return TRUE
