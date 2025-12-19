/*

  -- Dynamic Lighting --

This library provides a way to turn objects (turfs, objs, mobs, etc.) into
light sources which illuminate the map. It's dynamic because the shading is
updated as objects move.

The library works by placing an object on each turf. This object's icon state
is changed to reflect the shading at that tile. By showing different states with
different levels of darkness and different types of gradients, the map is covered
with smooth shading based on the positions of light sources.


  -- Files --

_readme.dm
	This wonderful help file!

dynamic-lighting.dm
	The core - the global /Lighting object

icon-generator.dm
	Not needed to use the library, it's only used to generate the necessary icon files

light-source.dm
	Defines the /LightSource object which is used to make atoms cause illumination

dynamic-lighting-library.dmi
	A blank icon needed by icon-generator.dm

sample-lighting-4.dmi
	A sample 256 state lighting icon, can be used in demo\demo.dm

sample-lighting-5.dmi
	A sample 625 state lighting icon, can be used in demo\demo.dm

customization-demo\
	demo.dm
		An example of how to modify the lighting behavior to create
		square light ranges and directional lights.

	map.dmm
		The sample map

demo\
	demo.dm
		An example of how to use the library and all of its features

	dynamic-lighting-demo.dmi
		Icons needed for the demo

	map.dmm
		The sample map

shadows-demo\
	demo.dm
		Adds code to the demo (not to the library itself) to show how
		shadows can be added.

	map.dmm
		The sample map


  -- Version History --

Version 7 (posted 03-18-2012)
 * Changed how lighting is initialized. The lighting.init() proc is no longer used to set
   the icon, instead you just set lighting.icon directly. The init() proc initializes lighting.
   Any argument passed to it is a z level to be initialized, if no z levels are specified,
   lighting is initialized for all z levels.
 * Changed how light sources work. Previously you could set their radius and intensity vars
   directly. It took extra CPU usage to detect these changes so now you have to use the
   radius() and intensity() procs to set these values. This way lighting is only recalculated
   when it's absolutely necessary
 * Reorganized the code for the /light object. It now has a proc called loop() that is called
   by the lighting object's central loop. This proc checks for changes and calls apply(). The
   apply() proc removes the light's current effect and applies the updated effect.
 * Added the intensity argument to the /light object's constructor and re-named the radius arg
   to be called "radius". Both are optional (the default is radius = 3, intensity = 1)
 * Added a check so that shading.update() is only called when the lum value has changed in a way
   that will cause the icon_state to change. For example, a change from 0 to 0.1 will still use
   the same state and won't cause an update to occur.
 * Removed the shading.update() proc and made it inline. It was being called so many times that
   the overhead was significant. Profiling shows this change decreased the CPU time used by the
   light.apply() proc by 15%.
 * Changed the default light.lum proc to avoid unnecessary calls to sqrt(). Profiling shows this
   reduced the average CPU time of the light.effect() proc by about 20% and the average CPU time
   of light.apply() by 17%.
 * Added the light.ambient() proc which can be used to change a light's ambient level.

Version 6 (posted 10-20-2011)
 * Added the lighting.ambient var which can be used to set an ambient light level. If you change
   its value at runtime, it won't take effect until a tile is updated. Because the change would
   effect every tile, forcing every tile to update will often be too taxing on the CPU.
 * A new demo called "day-night-demo" was added to show how to use the new lighting.ambient var
   to create a day/night cycle.

Version 5 (posted 10-14-2011)

 * Changed the light.intensity var so it's now on the 0...1 scale. A value of 1 will make the
   center of the lighted area be at the maximum brightness regardless of the number of levels
   of shade you have.
 * Changed the light.lum() proc to take pixel offsets into account (based on step_x and step_y)
   when computing distances. This means that light sources using pixel movement will cause
   updates to illumination with every step they take, instead of causing updates only when they
   transition to another turf.
 * Added the lighting.pixel_movement var which is used to determine if pixel offsets are taken
   into account. By default this is enabled, but you can set light.pixel_movement = 0 to make
   light sources update tile-by-tile, even when using pixel movement.

Version 4 (posted 10-13-2011)

 * Changed the way dynamic lighting is initialized, instead of calling new() to initialize
   it, you call init() and pass init the icon file to use. You call the same init() proc to
   initialize a z level - you can pass any number of z levels as arguments or pass nothing
   to make it initialize all z levels.
 * Changed the /light_source object to just be /light
 * Previously, each light_source object had a loop that executed every tick, this loop
   was moved to be a single global loop in the /Lighting object for performance reasons.
 * Shading objects can now have decimal lum values (ex: 3.5) and will automatically be
   rounded to the nearest integer.
 * Added some detail to the icons used in the demo and created a separate icon file with
   simpler graphics. Switch between the two icon files in demo\demo.dm to see how much
   better the lighting effects look when the turfs have more detailed icons.
 * Added the light.intensity var which can be used to control the intensity of a light.
 * Changed the default light.lum() proc to take into account the radius and intensity vars,
   the default provides a circular area of light with a value equal to the intensity var at
   the center and fading to zero at the edges.
 * Updated each demo to have verbs for increasing and decreasing the light's intensity.

Version 3 (posted 10-12-2011)

 * Replaced the world.illumination and atom.light procs with the light_source.lum and
   light_source.effect procs respectively. This lets you more easily extend the lighting
   behavior by creating child types of /light_source, see customization-demo for an example.

Version 2 (posted 10-10-2011)

 * Changed the /LightSource datum to be /light_source and made it a child of
   /obj so they have positions on the map.
 * Made each /light_source object have a loop to check for changes even if the
   light source isn't attached to a movable atom. This is necessary for implementing
   shadows and lets you change its vars directly - instead of using the light's radius()
   proc to change its radius, just set the radius var directly (ex: light.radius += 1)
 * Added the shadows-demo demo which shows how light sources can be made to cast shadows
   by overriding the atom/light() proc. Instead of just returning the basic circular
   range of light, the light() proc in the demo does some visibility calculations so
   that opaque objects block light.
 * Added the world.illumination() proc which takes two atoms and a radius and returns
   the illumination value based on the distance between atoms and the radius of the light
   source. This way you can override atom/light() but still use the same illumination
   calculation, or you can override illumination() and keep the same atom/light() proc.

Version 1 (posted 10-09-2011)

 * Initial version.





*/