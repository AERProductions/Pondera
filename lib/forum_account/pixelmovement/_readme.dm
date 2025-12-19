/*

  -- Introduction --

This library provides you with a pixel-based movement system for BYOND games. This lets
mobs move a few pixels at a time instead of a whole tile at a time.

Just like how you can override BYOND's built-in movement procs (Move, Entered, etc.) to
make new effects for your game, you can override the procs defined by this library to
create new effects for your game.

To learn the basics of using the library, look through the demos that come with it. The demos
are contained in subfolders (ex: "basic-demo", "intermediate-demo", etc.). These folders are
located in the file tree at the left side of the DM window. To run a demo, check off all of the
files in a single subfolder, then compile and run the program. Make sure you only have files
for one demo included at a time.

If you have any questions, concerns, or comments about using the library, don't hesitate to
post on my forum:

    http://www.byond.com/members/Forumaccount/forum


  -- Learning to Use the Library --

This library is more complex than your average one. It doesn't just give you a single
proc that does something you want. It contains a whole movement system that uses many
vars and procs. It might seem like a lot, but you only need to learn things as you need
to customize them. For example, BYOND defines the Enter() proc for atoms, but you only
need to learn about it if you need to use it - this library is the same way, if you don't
need to change the behavior of the jump() proc, you don't even need to know it exists.

The demo called "basic-demo" is a good place to start. It shows how you can use the library
without having to really write any code that uses the library's features. If you just want
pixel movement in your game and don't need to customize how it works, you don't need to do
much at all.

The demo called "intermediate-demo" shows how some of the library's features work, including:

  * camera control
  * stepped_on, stepped_off, and stepping_on procs
  * the atom.flags var
  * the mob.move_to proc
  * the mob.front helper proc (it's essentially the pixel equivalent of get_step()).

This demo shows how to use the library's features, but doesn't show you how to create many
useful things. It shows you what features exist, but it might not be clear how you can use
these feature to create a game. For this, you can look at the demo called "zelda-demo".

The Zelda demo includes features you'd see in a Zelda-like game, including:

  * melee attacks
  * ranged attacks
  * enemies with AI
  * camera control (panning from room to room)

This README file contains a reference, which is a list of all the vars and procs that are
defined by the library and a short description of each. It's at the bottom of this file. It
may not be as useful as the demos, which let you see things in action, but its a more
comprehensive list of features.


  -- Version History --

Version 5.6 (posted 07-07-2012)
 * Changed the move_towards() proc to allow non-turf arguments. The mob will continually
   move towards an obj, mob, or turf.
 * Fixed a runtime error with referencing the PixelMovement object's tile_width var.
 * Changed the format of some for() loops to not specify a type filter (ex: for(var/atom/a in ...))
   when iterating over a list that's known to contain only atoms. This might provide a
   slight improvement in performance of the set_flags() proc but it's hard to get precise
   profiling measurements.

Version 5.5 (posted 06-08-2012)
 * Changed the way Move(), Entered(), and Exited() are called. Move() is called when the
   center of your mob moves to a different turf. This also triggers the Entered and Exited
   procs for turfs and areas (if you're changing areas). If you need something more precise,
   use the stepped_on proc.
 * The calls to turf's Entered and Exited procs can be unreliable with this new scheme, so
   I added the turf.entered() and turf.exited() procs which you can use instead. These are
   only called by moves stemming from pixel_move, not calls to Move() directly.
 * Removed the TURF_ENTERED and AREA_ENTERED compiler flags. These procs are now called all
   the time, though they're less precise than before.
 * Added the global PixelMovement object which contains global options to control the library's
   behavior at runtime.
 * Moved the global vars and world procs (ex: world.movement) to the PixelMovement object.
 * Added the PixelMovement.distance var which determines which distance metric the distance_to
   proc uses. Its value can be PixelMovement.EUCLIDEAN, PixelMovement.MANHATTAN, or
   PixelMovement.BYOND (the same metric as get_dist, also called the Chebyshev distance but
   "BYOND" is easier to type).
 * Added the PixelMovement.debug var which can be used to enable debugging. The global var
   PIXEL_MOVEMENT_DEBUG still exists for now and does the same thing. All of the demos were
   converted to use the PixelMovement.debug var.
 * Added the PixelMovement.tile_width and PixelMovement.tile_height vars which replace the
   global icon_width and icon_height vars. Previously isometric maps were handled improperly
   with non-square values for world.icon_size. Now they're handled properly.

Version 5.4.1 (posted 05-25-2012)
 * Added support for the step_x/y and bounds_x/y vars. The New() proc for /atom/movable uses
   these values to initialize the pixel_x/y and px/py vars. If you change the step_x/y or
   bounds_x/y vars at runtime they won't take effect, just use pixel_x/y or px/py instead.
 * Added the atom.distance_to() proc which takes an atom as an argument and returns the
   Euclidean distance between the centers of the atoms.

Version 5.4 (posted 05-23-2012)
 * Fixed some issues with how paths were followed when you called move_to.
 * Added the moved_to() and moved_towards() procs which are called when a mob reaches their
   destination after the move_to or move_towards procs were called.
 * Fixed a bug wqith the mob.inside() proc. When passed a single parameter (an atom) it would
   incorrectly return true if the atoms were only adjacent.
 * Changed the set_pos() proc to call the mob's Move() proc when the mob transitions from one
   tile to another.
 * Updated some of the demos to fix the mob's icon_state. A change in v5.3 made the mob have a
   blank icon state in some demos.
 * Made the slow_down() proc slow client-controlled mobs when the client's focus has changed to
   another object.

Version 5.3 (posted 05-12-2012)
 * Fixed a bug in set_state() that caused the jumping state to not be applied in certain cases.
 * Added include.txt so the Keyboard library should be downloaded automatically if you need it.
 * Added a second paramter to the front(), right(), left(), top(), and bottom() procs. The first
   parameter is the depth of the bounding box, the second argument is the width. By default it
   is the width of the mob. For example, if a mob attacks by thrusting a 4 pixel wide dagger out
   10 pixels in front, you'd call front(10, 4) to check for targets. This parameter was not added
   to the above() and below() procs, I'm not sure what it'd mean in three dimensions.
 * Added the camera.pixel_x and camera.pixel_y vars so you can more easily create a pixel offset
   for the camera.
 * Added the TURF_ENTERED and AREA_ENTERED compiler flags to _flags.dm. It takes extra work to
   detect when these procs should be called. If you're not going to use them, there's no need to
   check and you can leave them disabled to reduce CPU usage.
 * Removed the ability to use a single icon_state for a mob (previously the library would detect
   when you don't have separate standing, moving, and jumping states).
 * Added a return value to mob.set_pos(), it returns 1 if the mob moved at all and 0 if they didn't.
   The proc needs to be called each tick because it's in charge of updating the camera location,
   but you may only want things to happen if the mob moved.
 * Made the mob's movement only happen if the client's focus is set to their mob.
 * Removed the jumped var, now the default key_down proc calls can_jump() and jump() itself.

Version 5.2 (posted 03-15-2012)
 * Added the mob.gravity var. This is the acceleration due to gravity used by the gravity() proc.
 * Changed the default behavior of set_state to base the distinction between standing and movement
   states on the mob's moving var instead of their velocity.
 * Added the mob.jump_speed var. This is the value that a mob's vel_z var is set to when they jump.
   This lets you change how high a mob jumps without overriding the jump() proc.
 * Added the limit var for the Path object. This is the limit of how many turfs will be checked by
   the pathfinding algorithm before it gives up. The default value is zero, which means there is no
   limit.
 * Fixed support for the Entered() and Exited() procs for turfs and areas. By default this is disabled
   (for performance reasons) but can be enabled in _flags.dm.

Version 5.1 (posted 02-15-2012)
 * The library now uses the Forum_account.Keyboard library for handling keyboard input. All keyboard
   input functionality still exists, but most of it was moved to the client. The keys list and the
   lock_input, unlock_input, and clear_input procs belong to the client. The key_up and key_down procs
   still exist for the mob. The keyboard library can be downloaded here:
   http://www.byond.com/developer/Forum_account/Keyboard
 * Changed the default behavior of the can_bump proc to make it more like BYOND's default handling. Now
   dense mobs will bump into other dense mobs. Dense turfs are always treated as dense.
 * Changed the way the slow_down() proc works. Previously there were issues with non-player mobs not
   slowing down after reaching their destination. Now, mobs will keep track of whether or not they
   moved and will automatically slow down if they didn't move that tick.
 * The intermediate-demo has been updated to show the changes to slowing down. When you click on a turf
   the yellow mob will move to it. Previously, the mob would continue moving at the same velocity once
   it reached its destination. Now, the mob will slow down once it reaches the destination.
 * Made some changes to the intermediate-demo to organize it better. It shows a lot of useful features
   that you can take and put directly into a project of your own. If you want to get a good idea of what
   this library can do, this is the demo you should check out.
 * Added the mob.accel and mob.decel vars, which control how quickly mobs accelerate and decelerate.
   Previously this value was hardcoded as being 1. Now it is customizable and the default value is 1 for
   both vars.

Version 5.0 (posted 11-30-2011)
 * Removed the library and native modes. Since hybrid mode is the only mode, all of the mode-related
   options and code have been removed.
 * Renamed most of the files. The names are similar: mob-movement.dm became movement.dm, mob-pathing.dm
   became pathing.dm, hybrid-procs.dm became procs.dm, pixel-movement-hybrid.dm became pixel-movement.dm,
   mob-debugging.dm became debugging.dm.
 * Added collision.dm which contains code that used to be part of the pixel_move() proc.
 * Removed the NO_FLAGS flag since all flags are needed by pixel_move() now.
 * Removed the offset_x, offset_y, and offset_z vars. The pixel_x, pixel_y, and pixel_z vars can be used
   instead.

Version 4.1 (posted 11-14-2011)
 * Added the hybrid mode which is now the default mode. It uses some native features (ex: the obounds
   proc) to improve performance of soft-coded movement. This means that hybrid mode has the same
   features as library mode but matches the performance of native mode.
 * Added the benchmarks\demo-3 demo which has mobs move randomly around an isometric map.

Version 4.0 (posted 09-07-2011)
 * Added support for BYOND's native pixel movement feature. It's enabled by default, but you can
   switch back to the legacy mode using the #define METHOD flag in _flags.dm. Legacy mode gives
   you some features not supported by the native feature (ramps, 3D movement).

Version 3.4 (posted 08-27-2011)
 * Fixed a bug with fractional moves in the y and z directions. Thanks to Kaiochao for pointing
   it out!
 * Added the mob.watch() proc. The proc takes a single argument, a mob, and makes your camera
   follow that mob instead. Because there are pixel offsets applied to your client's eye, following
   another mob isn't as simple as just setting client.eye = some_other_mob. However, the watch()
   proc takes care of all the details. The set_camera() proc and camera object are still used and
   these properties apply the same regardless of which mob you're watching.
 * Changed the benchmarks\demo-2\ demo to include example usage of the watch() proc.
 * Added an example of pushable boxes to intermediate-demo.
 * Made some changes to the SLIDE camera mode to help reduce jitter. It's better, but still not
   perfect.
 * Updated the documentation to include reference pages for the preprocessor flags (TWO_DIMENSIONAL,
   LIBRARY_DEBUG, etc.), the mob.watch() proc, and the mob's watching and watching_me vars.

Version 3.3 (posted 08-21-2011)
 * Changed the way path following (the mob.move_to proc) works. It should improve performance
   and make use of the move() proc's support for 8-directional moves.
 * Changed the way path finding works. It now makes use of diagonal moves.

Version 3.2 (posted 07-31-2011)
 * Fixed runtime errors that were caused by the mob's move_towards proc.
 * Added another benchmark (the benchmarks\demo-2 folder) that creates a configurable number
   of mobs that continuously call move_to. The destination of their moves is a random turf
   within a configurable distance from their current location.
 * Changed the move() proc and action() proc to support diagonal movement. The mob's direction
   will now be changed to a diagonal (ex: NORTHEAST) if the player is holding both of the
   corresponding arrow keys.
 * These changes also fix a problem with limiting the player's speed. Previously, if a player's
   move_speed was 5, moving in a diagonal would make vel_x = 3.2 and vel_y = 3.7 when they should
   really be equal. Now they will be equal (both will be about 3.53).

Version 3.1 (posted 07-22-2011)
 * Re-added support for fractional moves. Previously, calling pixel_move(1.5, 1) would be the
   same as calling pixel_move(1, 1) because the decimal part would be ignored. Now decimal parts
   are accumulated so that mobs always have integer coordinates and perform integer moves, but
   when the fractional moves accumulate enough, the move will be augmented to reflect this. For
   example, calling pixel_move(1.2, 0) five times will make the mob move a total of 6 pixels, one
   of the moves will make them move two pixels, the other four just one pixel each.
 * Changed some things in pixel-movement.dm to hopefully avoid some division by zero errors. They
   hadn't been causing problems (at least not that I'd noticed), but seeing runtime errors is always
   annoying.
 * Added the NO_STEPPED_ON flag. Enabling the flag disables the definition of the atom.stepped_on,
   stepped_off, and stepping_on procs. If you're not using these procs you can enable this flag to
   improve performance.

Version 3.0 (posted 06-29-2011)
 * Changed the inside() proc. The version that takes 6 parameters (that form a bounding box)
   is now called inside6(). There is still an atom.inside() proc that returns a list of atoms
   inside src, or when passed an atom as an argument, returns 1 or 0 if the arg is inside src
   or not. There is also an inside4() proc which is used by the new 2D mode.
 * Changed the set_flags() proc to call nearby() instead of oview(2). I forget why it was using
   oview (I might have had a reason for doing that). This change makes the default movement loop
   run slightly more than four times faster.
 * Added _flags.dm which contains some compile-time flags you can set to change the library's
   behavior. These flags are used by pre-processor directives to change the actual DM code that's
   being compiled. This way you can disable a feature to improve runtime performance - at runtime
   it doesn't even need to check that the feature is disabled, the code for unused features is
   just not compiled into the .dmb.
 * When the TWO_DIMENSIONAL flag is set (#define TWO_DIMENSIONAL) the library only provides 2D
   movement and collision detection. If your game doesn't use jumping this can greatly reduce
   CPU usage.
 * When the LIBRARY_DEBUG flag is set the debugging features (ex: mob.start_trace()) are defined
   and enabled. Before this flag existed, movement procs would always be checking if a movement
   trace was enabled. These checks would waste time when you weren't using the feature.
 * When the NO_FLAGS flag is set the atom.flags var (and the flags_left, flags_right, etc. vars)
   and the corresponding mob vars (on_ground, on_left, etc.) are not defined. The set_flags() proc
   is also not defined. If you're using the TWO_DIMENSIONAL flag there's a good chance you can use
   this flag too. Together they really improve performance - set_flags() is one of the bigger CPU
   users.
 * Added the benchmarks\demo-1 demo. This demo creates a number of balls that bounce around the map.
   You can run this demo and take note of what the CPU usage is, then make changes to the library
   (ex: add #define TWO_DIMENSIONAL) and run it again to see how CPU usage changes. You can easily
   change the ball count to stress the server as much or as little as you want.
 * Fixed a problem with fall_speed, it was being applied to vel_y instead of vel_z (whoops!)
 * Re-removed support for fractional moves. You can still call pixel_move(3.5, 0), but you'll only
   move 3 pixels. I need to find a better way to handle this, but it'll have to wait until the next
   update.

Version 2.4 (posted 06-05-2011)
 * Made some tweaks to accommodate fractional moves. In particular, I made the camera's movement
   less shaky. There are still some issues when the camera mode is SLIDE, but it seems to be
   improved for FOLLOW mode.
 * Added better handling of ramps. If a ramp is elevated enough you can walk under it.
 * Added better support for bumping objects from below.
 * Updated the isometric-demo to show these updates. (there are still some layering issues, I'm
   not sure if that's BYOND's fault or mine)

Version 2.3 (posted 05-30-2011)
 * Added support for any value of world.icon_size, not just the default 32.
 * Added the "icon-size-demo" which shows that the library supports any value for world.icon_size.
 * Re-added support for fractional moves. The library used to round your pixel coordinates so
   if you moved 3.5 pixels each tick, you'd really only move 3 pixels each tick. There was no
   difference between moving 3.9 or 3.0 pixels per tick. Now there is. (Note: this had caused
   some problems which is why I first removed the feature. If you notice weird things happening,
   this might be the cause, so let me know.)

Version 2.2 (posted 05-15-2011)
 * Added control scheme demos (in the control-scheme\ folder):
 * The control-scheme\vehicle\ demo shows how to create a movement system where the left and right
   arrow keys make the mob turn, and the up/down keys make the mob move forwards or backwards.
 * The control-scheme\zelda\ demo shows how to create Zelda-like movement. The player can move in
   four directions and adjusts to be aligned with half-tile boundaries. This makes it easier for
   the player, who is a full 32x32 rectangle, line up and fit through one-tile wide passages.
 * The control-scheme\wasd\ demo shows how to use the new mob.controls var to make mobs that move
   using the WASD keys instead of the arrow keys.
 * Added the mob.check_loc() proc. It's nothing new, it contains code that used to be part of the
   mob's default movement proc. check_loc checks for situations where a mob's loc var was changed
   directly and updates the mob's pixel coordinates when this happens. check_loc() is called by the
   global movement loop, so you don't lose this behavior even if you override the mob's movement proc.
 * Added documentation in _reference.dm for check_loc(), world.movement(), start_trace(), stop_trace(),
   and mob.controls.
 * Fixed a problem with macro initialization - macros wouldn't work when you had a .dmf file with
   multiple windows.
 * Added mob-debugging.dm which contains the Stat proc (that used to be in world.dm) and contains
   a new debugging feature.
 * Added the mob.start_trace and mob.stop_trace procs. When start_trace() is called, all of the mob's
   movement related actions (calls to movement, move, bump, pixel_move, set_pos, etc.) will be kept
   in a log. When stop_trace() is called the log will be displayed in the browser.
 * Added the mob.controls var, which is an object that has five vars of its own: left, right, up, down,
   and jump. By default their values are (in the order I mentioned them): west, east, north, south, and
   space. You can change these values to change what keys are used for the default movement behavior.
 * Added a reference page called "Pixel Movement Debugging" which explains the debugging features that
   the library offers and how/when to use them.
 * Added a demo called performance-demo, which shows some simple optimizations that can drastically
   reduce your game's CPU usage. Run the demo with and without including optimizations.dm to see how
   much of a difference the optimizations make.

Version 2.1 (posted 05-10-2011)
 * Made mobs stick to ramps while walking down them. Previously mobs would just fall down the ramp,
   like they kept walking off a ledge. Not only did it look weird, but it made it almost impossible
   to jump while walking down a ramp.
 * Changed the move() proc and bump() proc to use the directions NORTH, SOUTH, EAST, and WEST instead
   of UP, DOWN, LEFT, and RIGHT. The bump() proc still uses the VERTICAL constant for bumps in the z
   direction. (Note: BYOND defines UP and DOWN vars so you won't get errors if you have them in your
   code, but they aren't the same values as NORTH and SOUTH so your code might not work).
 * Fixed a mapping error in the zelda-demo, on the bottom middle screen there was a tile with the wrong
   area, causing the camera to go haywire.
 * Added _reference.dm which contains code to generate DM reference pages for all vars and procs defined
   by the library. This will let you press F1 in Dream Maker to get help with using the library, just
   like you do with DM's built-in features. See _reference.dm for instructions.

Version 2.0 (posted 05-07-2011)
 * Added the move_speed and fall_speed vars. These limit how fast the
   player can run and fall.
 * Made the move() proc limit the mob's combined velocity in the x and y direction.
   The magnitude of the player's combined x and y velocities is limited by move_speed.
   Previously, the x and y velocities were limited separately so the mob could move faster
   in diagonal directions.
 * Added the action() proc which is called by the default movement()
   behavior. The action proc contains the movement logic - the code that
   calls move(). This way you can override a mob's movement actions
   without having to override movement().
 * Added camera.dm which contains the set_camera proc (which was previously in pixel-movement.dm)
   and the /Camera object. A var called "camera" was added for mobs that's an instance of the
   Camera object. This object stores all properties related to the camera.
 * The camera.mode var can be set to camera.FOLLOW or camera.SLIDE to switch between a camera
   that strictly follows the mob and one that speeds up and slows down to smoothly follow the mob.
 * The camera.lag var can be used to specify the number of pixels the mob can move away from
   the camera before the camera will move to follow the mob.
 * The camera.px and camera.py vars can be used to set the camera's position.
 * The camera.minx, camera.maxx, camera.miny, and camera.maxy vars can be used to specify
   bounds on the camera's position. The set_camera proc's default behavior will not move the
   camera outside of these bounds.
 * Removed the need for keyboard.dmf
 * Put copies of common\map.dmm and placed them in the isometric-demo\, demo\,
   and top-down-demo\ folders, which removed the need for the common\ folder. To
   run a demo now, just include (check off) all files in a subfolder.
 * Made the set_state proc check that the new icon state exists in the player's
   icon. This is meant to make including the library even easier because you don't
   need to define separate standing, moving, and jumping states (though, if you
   want to make use of those animations, you'll obviously need to create those states)
 * If a pdepth value isn't specified for an atom, it's pdepth will be set depending on its
   density. If it's dense, its pdepth will be 32, otherwise its pdepth with be zero. This
   lets you not have to worry about pdepth if you don't have jumping in your game.
 * Added mob-pathing.dm which contains pathfinding functions for mobs that use pixel movement.
 * The mob.move_to(atom/a) proc plans a path using the A* algorithm that the mob can follow to
   reach the specified tile. This proc is like BYOND's walk_to proc.
 * The mob.move_towards(atom/a) proc makes the mob move in the direction of the specified atom
   but doesn't use intelligent pathfinding. This proc is like BYOND's walk_towards proc.
 * Added the atom vars: flags, flags_left, flags_right, flags_top, flags_bottom, and flags_ground.
   These vars are numbers that get binary ORed with a mob's on_ground, on_left, on_right, etc.
   vars when the mob is standing next to the atom. flags sets the value for all sides of the atom,
   the other vars are specific to one side (ex: the atom's flags_right defines the properties of
   the atom's right side, so it gets ORed only with a mob's on_left var since the right side of the
   atom touches the mob's left side).
 * Added ramps. You can use the atom.ramp and atom.ramp_dir vars to create sloped objects. atom.ramp_dir
   is a direction (NORTH, SOUTH, EAST, or WEST) that defines the direction of the ramp. Setting it to NORTH
   means that the ramp gets higher as you move north along it. The atom.ramp var defines how much the
   height changes (in pixels) along the length of the ramp.
 * Replace the mob's x_bump, y_bump, and z_bump procs with the single mob.bump(atom/a, d) proc. The
   first argument is the atom the mob bumped into, the second argument is the direction of motion, which
   is LEFT or RIGHT for x-bumps, UP or DOWN for y-bumps, and VERTICAL for z-bumps.
 * Added a demo called "zelda-demo" which shows how to use the library to create some features you'd
   expect to see in a Zelda-like game. It includes melee attacks, projectiles, enemies, and camera control.
 * Changed some demos to make use of BYOND's new SIDE_MAP value for map_format.

Version 1.0 (posted 02-03-2011)
 * Added some comments (particularly file headers).
 * Changed the way keyboard input is handled, the macros are now
   defined at runtime instead of being defined in a .dmf file. This
   means that when you use the library, you can use your own .dmf
   file and don't need to worry about defining certain macros.

Version 0.9 (posted 01-19-2011)
 * Removed the get_ground, get_left, get_right, get_top, and get_bottom
   procs and replaced them with the set_flags proc.
 * Added the below() helper proc which returns a list of bumpable atoms
   directly below the mob.

Version 0.1 (posted 12-14-2011)
 * Created this library to replace Forum_account.Isometric since this
   library has support for top-down and isometric platformers.
 * Modified the code from the isometric library to mirror changes that
   were made to the Forum_account.Sidescroller library.


  -- Files --

Library
	camera.dm
	collision.dm
	debugging.dm
	keyboard.dm
	movement.dm
	pathing.dm
	pixel-movement.dm
	procs.dm
	world.dm

basic-demo
	A very simple example of top-down pixel movement.

	demo.dm
	basic-icons.dmi
	map.dmm

control-schemes
	vehicle
		An example of a movement scheme where the left and right
		arrow keys turn the mob and the up/down arrow keys make
		the mob move forwards and backwards.

		demo.dm
		map.dmm

	wasd
		An example of using the mob's controls var to make the player
		use the WASD keys for movement instead of the arrow keys.

		demo.dm
		map.dmm

	zelda
		An example of 4-directional movement (no diagonals) similar
		to the movement system in the original Zelda game (also
		similar to the movement in BYOND's Casual Quest).

		demo.dm
		map.dmm

icon-size-demo
	A demo that uses icons that aren't 32x32 and a different value for
	world.icon_size.

	demo.dm
	48x24.dmi
	map.dmm

intermediate-demo
	A demo that shows how to use many of the library's features,
	including camera control, object interaction, helper procs,
	stepped_on/stepped_off, and atom.flags.

	demo.dm
	map.dmm

isometric-demo
	Showing pixel movement with isometric maps. Shows some
	more library features, like ramps and jumping.

	demo.dm
	isometric-icons.dmi
	map.dmm

top-down-demo
	Shows moving and jumping in a top-down map.

	demo.dm
	top-down-icons.dmi
	map.dmm

zelda-demo
	Shows how to create some features you'd see in a Zelda game,
	including melee attacks, ranged attacks, enemy AI, and camera
	control.

	demo.dm
	zelda-icons.dmi
	map.dmm


  -- Reference --

atom
	var
		flags
			This value gets ORed with the mob's directional flags (on_ground, on_left, etc.) in
			the mob's set_flags proc. You can use the flags var to specify atom properties, then
			you can check individual bits of on_ground to see what properties the ground below
			the mob has.

		flags_bottom, flags_ground, flags_left, flags_right, flags_top
			These are used the same way as the flags var except they let you define properties for
			individual sides of the atom. The flags_left var defines the properties specific to the
			atom's left side and will be ORed with the mob's on_right var. Note the opposites (left
			vs. right), this is because the mob's right side is what will be touching the atom's left
			side. The exception is flags_ground, it gets ORed with the mob's on_ground var.

		pwidth, pheight, pdepth
			The size of the atom's bounding box. The box is placed up and right from the atom's
			px/py/pz position.

		px, py, pz
			The atom's position in pixels.

		ramp
			Defines how much the tile's heigh changes. The turf's top will be pz + pdepth at the
			lower end and pz + pdepth + ramp at the higher end.

		ramp_dir
			Sets the direction of the ramp. If ramp_dir is WEST, the ramp gets higher as you move left.

	proc
		below(d)
			Returns a list of atoms within d pixels of src's bottom (in the z direction).

		bottom(d)
			Returns a list of atoms within d pixels of src's bottom side (in the y direction).

		front(d)
			Calls left, right, top, or bottom based on src's direction.

		height(qx, qy, qz, qw, qh, qd)
			Returns the z value (in pixels) of the top of the atom that's nearest to the
			specified bounding box (the 6 parameters define this box). This is used to find
			the highest point of a ramp below a mob.

		inside()
			Returns a list of all atoms inside src's bounding box.

		inside(atom/a)
			Returns 1 if src is inside of a's bounding box and 0 otherwise.

		inside(qx,qy,qw,qh,qz,qd)
			Returns 1 if src is in the bounding box of size qw x qh x qd located at qx, qy, qz
			and returns 0 otherwise.

		left(d)
			Returns a list of atoms within d pixels of src's left side.

		nearby
			Returns a list of atoms near the atom. The atoms on the same tile are listed
			first, the atoms in tiles in cardinal directions (up, down, left, right) are
			listed next, the atoms in tiles in diagonal directions are listed last. This
			proc is basically an alternative to oview() that's used because in pixel_move,
			the order matters.

		over(qx,qy,qw,qh)
			Returns 1 if the bounding box defined by the 4 parameters is over top of the
			specified atom. Returns 0 otherwise.

		right(d)
			Returns a list of atoms within d pixels of src's right side.

		stepped_off(mob/m)
			This is called when a mob was standing on an atom in the previous tick, but is no
			longer standing on the atom in the current tick.

		stepped_on(mob/m)
			This is called when a mob was not standing on an atom in the previous tick, but is now
			standing on the atom in the current tick. To be standing on an atom the mob must be able
			to bump the atom and its top must be touching your bottom.

			This is called when an object is standing on the atom. src is the atom being stepped on.
			This is defined for all atoms but generally used for turfs.

		stepping_on(mob/m, t)
			This is called every tick for as long as the mob is standing on the atom. The second
			argument, t, is the number of consecutive ticks that the mob has spent standing on
			the atom.

		top(d)
			Returns a list of atoms within d pixels of src's top side (in the y direction).

mob
	var
		base_state
			The prefix of all mob icon states. If a base state is specified, icon states will
			have the form [base state]-[action_state]-[dir_state], otherwise they will just
			be [action_state]-[dir_state].

		Camera/camera
			This is an instance of the /Camera object which is used to control all aspects
			of the mob's camera. See the /Camera object (further below in this reference) to
			see what properties the camera has.

		fall_speed
			This var is used to limit your fall speed.

		jumped
			Pressing a key does not cause the player to jump. Jumping is handled by the movement
			proc. The jumped var is a flag that tells the movement proc when the player jumped.
			When jumped = 1, the movement proc will process the jump and clear the flag.

		keys
			This is an associative list that keeps track of what keys are being pressed. If
			keys["a"] is 1 then the A key is being held, otherwise the A key is not being held.

		move_speed
			This var is used in the move() proc to limit your movement speed. Its default value
			is 5.

		[removed]
		offset_x, offset_y
			The pixel offset applied to the atom. This is used when the bottom left of the atom's
			icon is not the bottom left of its bounding box.

			Example:

				Icon:               Bounding Box:
				+----------------+	+----------------+
				|       #        |	|#######         |
				|      # #       |	|#######         |
				|      # #       |	|#######         |
				|       #        |	|#######         |
				|     #####      |	|#######         |
				|    #  #  #     |	|#######         |
				|    #  #  #     |	|#######         |
				|      ###       |	|#######         |
				|     #   #      |	|#######         |
				|     #   #      |	|#######         |
				|   ###   ###    |	|#######         |
				+----------------+	+----------------+


			The stick figured is centered in the icon but the bounding box is always in the bottom-
			left of the icon. To account for this you set offset_x = -4 so that the icon is shifted
			left 4 pixels and coincides with the bounding box.

		on_bottom, on_ground, on_left, on_right, on_top
			These vars are set by the set_flags() proc. You can use them to determine if a
			dense object is touching a side of the mob. It's often useful just to know if a
			dense object is next to the mob, you don't always need to know what object that is.
			For example, the can_jump proc checks the on_ground flag to only allow jumping if
			you're on the ground.

		vel_x, vel_y, vel_z
			The mob's velocity in the x, y, and z directions. The z direction is the direction you
			move in when you jump or fall.

	proc
		action
			In version 2.0 the movement() proc was further split. The part that contains the
			movement behavior (the call to follow_path and the processing of keyboard input)
			was moved to the action proc. This way you can override the action proc to change
			a mob's movement behavior without overriding the entire movement proc.

			Because the movement proc handles a lot of things (enforces gravity, calls
			pixel_move, etc.) when you override it, you often want to change just a small
			part of the behavior (the part that's now in action()) but you have to remember
			to call gravity(), pixel_move(), and other procs. Now you can just override
			action if that's all you want to change.

		bump(atom/a, d)
			This is called when the mob bumps into something dense. The atom is the
			dense obstacle you hit and d is the direction you were moving in. d is
			either LEFT or RIGHT (for bumping in the x direction), UP or DOWN (for
			bumping in the y direction), or VERTICAL (for bumping in the z direction).

		can_bump(atom/a)
			Returns 1 if src can bump the atom, otherwise returns ..().
			This allows for more complex density than just "all dense objects bump all
			other dense objects". For example, players cannot move through fences but
			bullets can, so player.can_bump(fence) = 1 but bullet.can_bump(bullet) = 0.

		can_jump()
			Called to check if the mob is allowed to jump. The default behavior requires
			that you be standing on the ground. You can override this to easily create
			different rules, like allowing the player to double jump.

		clear_input()
			Clears the keys list so that key[k] = 0 for all keys.

		dense(list/l)
			Returns 1 if the list contains an atom that src can_bump. Returns 0 otherwise.

		gravity()
			The gravity proc is called by the mob's default movement proc to adjust the mob's
			vel_y variable to create gravity.

		jump()
			Called when the mob jumps.

		key_down(k)
			This is called when the client presses a key. k is the name of the key that was
			pressed (A key -> k = "a", F1 key -> k = "F1"). Some constants exist: K_UP, K_DOWN,
			K_LEFT, and K_RIGHT correspond to the arrow keys.

		key_up(k)
			Like key_down, except this is called when the key is released.

		lock_input()
			After lock_input is called, keystrokes will not be processed - pressing a key will
			not call key_down/key_up and will not modify the keys list.

		move(direction)
			Called to handle the action of walking left, right, up, or down.

		move_to(turf/t)
			Plans a somewhat intelligent path to take the mob from it's current position
			to the specified destination t. After this is called, the mob will automatically
			move along the path. If the mob has a client connected, keyboard input will be
			ignored. You can think of this as the equivalent of DM's walk_to proc.
			To stop this movement you can call mob.move_to(null) or mob.stop().

		move_towards(turf/t)
			This proc is like the move_to proc except it doesn't plan a path, it just uses
			some basic rules to make the mob move towards its destination. This sounds useless
			compared to move_to, but it uses less CPU and is often sufficient.
			You can think of this as the equivalent of DM's walk_towards proc.
			To stop this movement you can call mob.move_towards(null) or mob.stop().

		movement()
			Automatically called every tick by a global loop. Handles the object's
			movement. The default action for a mob's movement proc is to call set_flags,
			gravity, action, set_state, and pixel_move(vel_x, vel_y, vel_z). If you want
			to override a mob's entire movement behavior, override this proc. If you want
			to keep some behavior (gravity, etc.) but change the mob's logic (ex: to give
			mobs AI) you should override the action() proc.

			Part of the default behavior checks if the mob's loc has unexpectedly
			changed. This would happen when you've written code that manually changes
			a mob's loc. If it detects a change then it calls set_pos, this way you
			can still change a mob's loc like so:

				mob.loc = locate(10,3,2)

			And the next time movement() is called it'll figure out that the mob has
			moved and call set_pos to update its pixel coordinates and client display.

		pixel_move(dpx, dpy, dpz)
			Figures out if the object can perform the move [dpx, dpy, dpz]. If a dense object
			is in the way it figures out if the move can be partially made. Calls set_pos to
			perform the move. Returns 1 if any move was made and 0 if no move could be made.

		set_camera()
			Sets the client's pixel offset.

		set_flags()
			Sets the mob's on_ground, on_left, on_right, on_top, and on_bottom vars.

		set_pos(nx, ny, nz, map_z)
			Sets the object's px, py, and pz to nx, ny, and nz. Updates the object's loc
			and calls set_camera (if the mob has a client). set_pos is automatically called by
			pixel_move so you shouldn't ever need to call it directly, but you can use it
			to move a mob to a pixel-precise location, for example:

				// will set px = 320, py = 320
				loc = locate(10, 10, 1)

				// sets the px value more precisely than you can by changing loc
				set_pos(328, 320, 0)

			The map_z argument lets you call set_pos to change what z level of the map the
			mob is on.

		set_state()
			Figures out what icon_state the mob should have and assigns it to the mob.

		slow_down()
			This is called by the mob's default movement proc to slow down the mob's movement
			speed if the player is not pressing an arrow key. This is how the mob gradually
			slows down after an arrow key is released.

		stop()
			Calling this proc stops any movement that was being caused by calls to
			move_towards or move_to.

		unlock_input()
			See lock_input(). This proc enables the processing of keyboard input again
			after you've called lock_input.


Camera
	vars
		FOLLOW
			This is a constant used to specify the camera's mode. When mode is
			set to FOLLOW, the camera will move as fast as the mob to follow
			their motion.

		lag
			The number of pixels the mob is allowed to stray before the camera will
			start moving to keep up.

		minx, maxx, miny, maxy
			These specify the bounds of the camera's coordinates. The default behavior
			of the set_camera proc will not move the camera's px and py to be outside
			of the rectangle defined by these four variables.

		mode
			Can either be SLIDE or FOLLOW.

		px, py
			The position of the camera in pixel coordinates. When they're set to
			the mob's px and py, the camera will be centered on the mob.

		SLIDE
			This is a constant used to specify the camera's mode. When mode is
			set to SLIDE, the camera will speed up and slow down to smoothly
			follow the mob's motion.

*/