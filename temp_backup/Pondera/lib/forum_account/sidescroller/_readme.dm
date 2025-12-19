/*

  -- Introduction --

To add new features you'll probably need to modify the library itself. I tried to expose as
much functionality as possible so you can add or change features by overriding procs.

Every mob has a proc called "movement". This proc is automatically called each tick and
handles the mob's movement. The default behavior is to check for keyboard input and call
procs to perform various actions.

To learn the basics of using the library take a look at the demos that come with the
library (there are nine demos, each contained in a sub-folder with the "-demo" suffix)
or check out this article: http://www.byond.com/members/DreamMakers?command=view_post&post=104440


  -- Version History --

Version 4.4 (posted 05-11-2012)
 * Made the atom's default New() proc take the step_x/y vars into account. You can use them to
   define a pixel offset that gets applied to the object's px/py vars when it's created.
 * Added two optional parameters to the atom.left() and atom.right() procs. These parameters specify
   the bottom and top heights of the bounding box. The default bottom is 1 and the default top is
   pheight - by default the box is as tall as the atom.
 * Changed the front() proc to also take the bottom and top parameters like the atom.left() and
   right() procs.

Version 4.3 (posted 03-19-2012)
 * Added the jump_speed var whose default value is 10. This is what your vel_y is set to by the
   default jump proc. This way you can change a mob's jump height without overriding any procs.
 * Added the moved var which is set by the move() proc to the dir you tried to move in. This new
   var is used by the set_state() proc to determine when the "moving" state is used (previously,
   it used your velocity to determine if the moving state was used).
 * Calls to slow_down() are also based on the new mob.moved var.
 * Changed how a mob's dir is set. It's now set in the action() proc, not set_state().
 * Added the limit var for the Path object. This is the limit of how many turfs will be checked by
   the pathfinding algorithm before it gives up. The default value is zero, which means there is no
   limit.

Version 4.2 (posted 02-11-2012)
 * Changed the default behavior of mob.can_bump to be more like BYOND's default movement. Now dense
   mobs will bump all dense objects by default - you don't have to override the proc to make this
   happen anymore. I updated all demos to make sure they still work after this change.
 * The Forum_account.Keyboard library is now included by a custom line in the library's .dme file,
   which should give a compiler error if you don't have the library. This will make it more obvious
   why the library doesn't compile, instead of giving 20 some errors about missing vars.
 * Changed the way conveyor belts are implemented in the "v2.6" demo. They now make use of the
   flags and on_ground vars.
 * Added the mob.on_ladder() proc which determines if the mob is standing over a ladder tile. The
   mob.on_ladder var determines if the mob is hanging on the ladder, the proc determines if they
   are simple over a ladder tile. The default behavior is to return 1 if the tile the mob overlaps
   most is a ladder. You can override this to change that (ex: make the mob have to be entirely
   inside the ladder tile to climb it).
 * Added the v4.2 demo to show some of the new features.

Version 4.1 (posted 12-07-11)
 * The library now uses the Forum_account.Keyboard library for handling keyboard input. All keyboard
   input functionality still exists, but most of it was moved to the client. The keys list and the
   lock_input, unlock_input, and clear_input procs belong to the client. The key_up and key_down procs
   still exist for the mob. The keyboard library can be downloaded here:
   http://www.byond.com/developer/Forum_account/Keyboard

Version 4.0 (posted 11-14-11)
 * Removed the NATIVE and LIBRARY modes - the library now uses only the HYBRID mode. Since this is the
   only mode there's not an option for it.
 * Removed the pixel-movement-native and pixel-movement-library files and changed the pixel-movement-hybrid.dm
   file to be called pixel-movement.dm instead,
 * Renamed mob-movement.dm to movement.dm and moved the set_flags proc back to it.
 * Renamed pixel-movement-common.dm to background.dm, since all it contained was code for handling backgrounds.
 * Created collision.dm and moved a lot of code from the pixel_move proc to it.
 * Added an optional argument to the front() proc. Calling front(4) will return a list of atoms within 4 pixels
   of the src object based on the direction its facing. Calling front(4, RIGHT) will force it to return a list
   of objects within 4 pixels of the object's right side, regardless of src's dir.
 * Removed the offset_x and offset_y vars, you can now use pixel_x and pixel_y instead.
 * Removed the FOUR_FLAGS flag from _flags.dm because all four flags are necessary for some of the library's
   internals.
 * Changed the NO_STEPPED_ON flag to be called STEPPED_ON and made it enabled by default (this way all demos
   will work, but you can disable it to improve performance in your projects).

Version 3.2 (posted 11-12-11)
 * Added the HYBRID mode which can be set in _flags.dm. This is now the default mode. In hybrid mode
   the library uses some built-in pixel movement procs (ex: obounds) to improve performance but still
   uses the library's soft-coded pixel movement so it's possible to have ramps. The performance is on
   par with native mode (it's actually a little better).
 * Added the v3.2 demo. It's similar to pathing-demo except it adds AI mobs that move randomly around
   the map. You can easily adjust the number of mobs. This demo is a handy way to see what the CPU usage
   will be for a certain number of moving mobs. It's also a handy way to test out pathfinding.
 * Added pixel-movement-common.dm which contains some code that's common to all pixel movement modes.
 * Moved the set_flags proc from mob-movement.dm to each of the mode-specific movement files because
   its implementation is different for each.
 * Renamed icons.dmi to sidescroller-demo-icons.dmi.

Version 3.1 (posted 10-15-11)
 * Added support for calls to set_pos of the form set_pos(atom/a). Passing a single atom to set_pos()
   will make the src mob be centered at that atom.
 * Added a demo called game-demo-2. It combines a bunch of features (many which were already in other
   demos) and makes a simple game. Add your own graphics and maps and you're well on your way to making
   your own game!
 * Added keyboard support for the shift, alt, and ctrl keys.
 * Added a third argument to the bump() proc when native pixel movement is used. This argument is 1 for
   first time bump() is called after performing a single move and 0 all additional times.
 * Added the camera.center() proc, which forces the camera to be within its bounds. This is useful when
   camera.mode = SLIDE and the camera is outside of the bounds and you want it to jump into position instead
   of slide into position. For example, start up the game-demo-2 demo with and without calling camera.center()
   and see the difference.

Version 3.0 (posted 09-11-11)
 * Fixed a bug with fractional moves in the y direction. Thanks to Kaiochao for pointing it out!
 * Added accel, decel, and gravity vars to mobs. These vars are all 1 by default and control the
   mob's acceleration and deceleration rates (gravity being the acceleration rate due to gravity).
 * Added a demo called v3.0 that shows examples of using the new accel, decel, and gravity vars.
 * Added support for BYOND's built-in pixel movement. This is enabled by default, but you can
   switch back to legacy mode by enabling a compiler flag in _flags.dm. The legacy mode uses
   the old soft-coded pixel movement which is necessary for supporting ramps.

Version 2.8 (posted 08-21-11)
 * Changed the SCROLL_X and SCROLL_Y constants to be named REPEAT_X and REPEAT_Y. These names make
   more sense since they are used to determine in which directions the background repeats. You can
   make any background move horizontally and vertically, even if it doesn't repeat in those directions.
 * Created the /Controls object which contains the vars up, down, left, right, and jump. These vars
   contain the keys that correspond to those actions. Each mob has an instance of the /Controls
   object, so to change a mob's jump key to Z just do: mob.controls.jump = "z"
 * Fixed a bug with the way the stepped_on and stepping_on procs were called. Previously there were
   times when they wouldn't be called when you land on the ground while not moving horizontally at
   the same time. Now they should be called in all cases that they apply.
 * Fixed a bug with the behavior of ramps (it was most noticeable in the scaffold ramps in the
   movement-demo). I think it was caused by the support for fractional moves, but I'm not sure.
   Whatever caused it, ramps seem to work fine now.
 * Fixed another bug related to ramps. Some cases where you bumped a ramp from the side weren't
   being handled correctly.

Version 2.7 (posted 07-26-11)
 * Changed the set_flags() proc to call nearby() instead of oview(2). I forget why it was using
   oview (I might have had a reason for doing that). This change makes the default movement loop
   run almost three times faster.
 * Added support for fractional moves. Previously calling pixel_move(1.2, 0) was the same as calling
   pixel_move(1, 0) because the 1.2 would be rounded down. Now each move is always an integer move
   but the fractional parts accumulate. If you call pixel_move(1.2, 0) five times the mob moves six
   pixels - four of the moves are of one pixel, one move is of two pixels.
 * Added _flags.dm which contains the definition of the compile-time flags.
 * Added the LIBRARY_DEBUG flag. The library has the statement "if(trace)" in many of the movement
   procs. If you're not going to use the trace feature these aren't necessary, so you can comment
   out the "#define LIBRARY_DEBUG" line in _flags.dm to make the debugging functions no longer part
   of the compiled library.
 * Added the NO_STEPPED_ON flag. Enabling the flag disables the definition of the atom.stepped_on,
   stepped_off, and stepping_on procs. If you're not using these procs you can enable this flag to
   improve performance.
 * Added the FOUR_FLAGS flag which enables the on_left, on_right, and on_ceiling flags. It's enabled
   by default. Even if this flag isn't included, the on_ground flag is defined because it's used by
   the gravity, jump, and can_jump procs. Disabling this flag also removes the definitions of the
   atom's flags_left, flags_right, and flags_bottom vars.

Version 2.6 (posted 06-26-11)
 * Made a lot of changes to mob-pathing.dm. I inlcuded the old version as _old-mob-pathing.dm in
   case your project relies on the old version.
 * Changed the way path following works when you call move_to(). My hope is that in most cases the
   mob will do a better job of following the path. In the few cases it doesn't, mobs are quicker to
   recompute paths so it should correct its behavior.
 * Added an argument to mob.movement() and mob.action(). Both take a number of ticks. The global
   movement loop keeps track of how many ticks have elapsed (it resets when it reaches 1000) and
   passes the number of ticks to these procs. This can be used for creating mobs that do something
   every 100 ticks (you can use the argument instead of creating your own counter).
 * Made the left and right arrow keys cancel each other out. If you first press left, then press
   right, the library will act like you're not pressing left (keys[K_LEFT] will be 0, but key_up
   won't be called). If you release the right key, keys[K_LEFT] will be restored (provided you
   kept holding it the whole time). Previously if you held both left and right arrow keys you'd
   slowly move to the right.
 * Changed the way platforms are handled. The library no longer defines the /mob/platform type.
   See game-demo\platforms.dm for the new implementation. The platforms now make use of the
   stepped_on and stepped_off procs.
 * Fixed a bug in game-demo where you would respawn on the platform if you pressed an arrow key
   while dead.
 * Added an example of boxes that can be pushed to the interaction-demo.
 * Changed the way move() and climb() are called. Previous, if you were standing next to a wall
   and tried to move towards the wall, move() would not be called. Now it is. This also means that
   bump may be called in more situations.

Version 2.5 (posted 06-11-11)
 * Added mob-debugging.dm which contains the Stat proc from world.dm and some new debugging
   features.
 * Added the mob.start_trace() and mob.stop_trace() procs. When start_trace() is called, every
   movement related proc call will be logged. When stop_trace() is called, the log is displayed
   in the browser.
 * Added a new demo called "v2.5" to showcase the new content.
 * Created an example of variable height jumps in the "v2.5" demo.
 * Fixed a problem with macro initialization - macros wouldn't work when you had a .dmf file with
   multiple windows.
 * Added support for any value of world.icon_size.
 * Added the mob.check_loc() proc. It doesn't do anything new, it just contains the functionality
   that looks for changes in the mob's x, y, and z coordinates to update your pixel coordinates
   when it detects that you manually changed the mob's loc. It's called from the global movement
   loop (world.movement), not from mob.movement, so if you override a mob's movement proc you don't
   lose this feature.

Version 2.4 (posted 04-28-11)
 * Added a demo called "v2.4" which shows how to use the features that are new in this
   version. I used to add examples of new features into whatever existing demos were most
   relevant. I wish I had thought of doing it this way sooner!
 * Added the flags_left, flags_right, flags_top, and flags_bottom vars which behave
   just like atom.flags except they let you define properties for individual sides of
   the atom. The mob's flags are binary ORed with the atom's flags var and the specific
   side's flags var.
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
 * The camera can still do some weird things when you use EDGE_PERSPECTIVE, so I recommend not
   using it and instead using the minx, maxx, miny, and maxy vars to enforce camera bounds near
   the edge of the map.
 * Added the stepped_off and stepping_on procs and changed how the stepped_on proc works.
   stepped_on is called only once when you first step on an atom, stepped_off is called
   once when you stop standing on an atom. stepping_on is called every tick for the whole
   time you're standing on top of the atom.
 * Updated the reference to include all new vars, procs, and objects.

Version 2.3 (posted 04-17-11)
 * Added the mob.face(atom) proc which makes the mob turn to face a specified atom.
 * Added the atom.flags var and changed how the mob's flags (on_ground, on_left,
   on_right, and on_ceiling work). This change is backwards compatible. The
   atom.flags var is a bit mask that gets binary ORed with on_ground. See the
   reference entry for atom.flags in _readme.dm for more information.
 * Added icy floors to movement-demo to show how the new atom.flags var can be used.
 * Changed the mob.background proc to add support for scrolling backgrounds. The first
   argument is still the image file, the second argument is the scrolling mode, 0 for
   no scrolling, SCROLL_X for horizontal, SCROLL_Y for vertical, and SCROLL_X+SCROLL_Y
   for both.
 * Added the mob.backgrounds list so that a single player can have multiple backgrounds
   displayed at the same time.
 * background-demo has been updated to make use of the new background features. Check it out!
 * Updated the reference in _readme.dm.
 * Removed hair.dm. Apparently the accessorization of the base icon didn't attract
   many more users (it was an April Fool's joke anyway).

Version 2.2 (posted 03-27-11)
 * Added the mob.action() proc to mob-movement.dm. This new proc contains code
   that used to be part of movement(). It doesn't do anything new, this split
   just lets you modify a mob's movement behavior without overriding movement().
 * Added the move_speed and climb_speed vars. These are used to limit the mob's
   movement speed in the move() and climb() procs.
 * Changed the name of the terminal_velocity var to "fall_speed".
 * Replaced the turf.platform var with the atom.scaffold var. It does the same thing
   but also allows you to make mobs and objs that behave as scaffolds. The name had
   to change because mobs already had a var called "platform".
 * Added support for sloped tiles that have scaffold = 1. I also added some of these
   tiles to movement-demo.
 * Added a new demo called mario-demo that shows how to create some features from
   Super Mario Bros.
 * Changed the way collisions are resolved. Previously you'd be pushed in the direction
   opposite of the attempted motion, now you're pushed outside of the tile in whatever
   direction is shorter.
   The old method had caused problems - if you ended up inside of a wall and tried to
   move left, you'd be pushed out the right side of the turf even if you entered the wall
   from its left side.
 * Made some minor changes in mob-pathing.dm to the way that mobs follow paths or move
   towards tiles to address the problem shown <a href="http://www.byond.com/members/Forumaccount/forum?id=221">here</a>.
 * Added hair.dm which adds a random hair overlay to all mobs.

Version 2.1 (posted 03-06-11)
 * Updated the reference at the bottom of _readme.dm.
 * Added mob-pathing.dm which contains two new procs: mob.move_to() and
   mob.move_towards(). These procs behave like DM's built-in walk_to and
   walk_towards procs.
 * Added a demo called "pathing-demo" which shows how the pathfinding features
   are used.

Version 2.0 (posted 02-27-11)
 * Removed the warning that would sometimes be displayed when the library detected
   that certain keyboard macros weren't defined. If you suspect that macros aren't
   firing you can set SIDESCROLLER_DEBUG = 1 to see if key presses are being caught.
 * Added the shooter-demo, which contains two different types of projectiles.
 * Changed the order that potential obstacles are considered in the pixel_move proc.
   All atoms in a 3x3 region centered around the player are checked like this:

		     Old:           New:
		+---+---+---+  +---+---+---+
		| 7 | 8 | 9 |  | 6 | 5 | 7 |
		+---+---+---+  +---+---+---+
		| 5 | 1 | 6 |  | 3 | 1 | 4 |
		+---+---+---+  +---+---+---+
		| 2 | 3 | 4 |  | 8 | 2 | 9 |
		+---+---+---+  +---+---+---+

   The important change is that the cardinal directions are checked before diagonals.
   This had caused some problems. If you'd like a further explanation, look at the
   comments in the pixel_move proc.
 * Removed common\interface.dmf. The macro definitions are no longer needed, so BYOND's
   default interface is fine for the demos.

Version 1.9 (posted 02-14-11)
 * When a mob is walking down a ramp they will "stick" to the ramp. This way
   the mob is continually on the ground and can jump while walking down the ramp.
 * Changed the name of the turf's "is_ladder" var to just "ladder".
 * Added the "platform" var to turfs. This allows you to create platforms that
   mobs can walk on top of or drop through.
 * Added an example of the new platform var to movement-demo
 * Added the ability for mobs to drop through platforms by holding down while pressing
   the jump key (space bar)

Version 1.8 (posted 01-26-11)
 * Added a demo called "movement-demo" which shows simple ways to create
   alternative movement styles. It contains three different types of mobs
   (normal, climber, and flyer) each with a different movement style.
 * Changed the way keyboard input is handled. The library adds keyboard
   macros for each client to track which keys are pressed. See keyboard.dm
   for more details.
 * Renamed common\keyboard.dmf to common\interface.dmf because it is not
   used to define keyboard macros, but is still used for the interface.
 * Changed the values of the K_LEFT, K_RIGHT, K_UP, and K_DOWN keyboard
   constants so the values match the macro names ("west" instead of "left" now)
 * General code cleanup. Some procs were moved to different files for more
   logical groupings.
 * Added more comments within code and at the top of each file.

Version 1.7 (posted 12-22-11)
 * Made some changes to the atom.inside proc. It now has three forms:
   atom.inside() returns a list of all atoms inside of src. atom.inside(atom/a)
   returns 1 if a is inside src. The original atom.inside(qx,qy,qw,qh) still
   exists.
 * Changed the order of some things in the mob's default movement proc.
 * Made some parts of the mob's movement proc execute only for mobs that
   have clients connected.
 * Removed the get_left, get_right, get_ground, and get_ceiling procs. They
   were replaced by the set_flags proc which sets the on_ground, on_left, etc.
   flags. If you need a list of atoms on a mob's right call mob.right(1).
 * Replaced x_bump and y_bump with the single bump proc. The first argument to
   bump is the atom you're bumping and the second argument is the direction
   (UP, DOWN, LEFT, or RIGHT).
 * Added the mob.at_edge proc which checks if the mob is standing at the edge
   of a platform
 * Added the mob.dense proc which checks if a list contains an atom that the
   mob can bump.
 * Made the enemies in the interaction-demo move (see interaction-demo/enemy.dm)

Version 1.6
 * Added procs.dm which contains some helper procs meant to compensate for the
   loss of useful tile-based procs like get_step. See the reference or procs.dm
   for a description of each new proc.
 * Added a new demo called "interaction-demo". This demo shows how you can use
   these new procs to interact with objects.

Version 1.5
 * Added world.dm which contains some options and the global movement loop.
 * Added a global SIDESCROLLER_DEBUG flag which enables some error messages and a
   debugging statpanel tab.
 * Added gravity proc for mobs. It is called every tick by the movement proc and
   applies gravity when applicable (mob is off the ground and not on a ladder).
 * Added an error message when the set_pos proc moves an object to a null location (off
   the edge of the map).
 * Added a return value for pixel_move: it returns 1 if any move was made and 0 otherwise.
 * Added the terminal_velocity var for mobs. This var limits how fast a mob can be falling.
 * Changed all pixel movement vars & procs to be defined for /mob instead of /atom/movable.
   Objs are still mobile (their loc can change) but they don't have pixel movement.
 * Removed OVERRIDE_WORLD_LOOP and moved the global movement loop to be a member of the
   world datum. To override the default movement behavior just override world.movement().

Version 1.4
 * The movement loop now detects when the mob's loc was changed. This lets you still move
   mobs by changing their loc, you don't need to use mob.set_pos (but you still can)
 * Added default behavior for the move, climb, jump, and key_down procs. The behavior that was
   previously defined in the demos for these procs is now the default behavior.
 * Added some demos and renamed existing ones:
    * simple-demo		shows very basic features
    * background-demo	shows how to create and manage a background image
    * ramps-demo			shows how to create sloped tiles
    * game-demo			a complete game with bullets and moving platforms

 * Removed set_dir, set_action, and compute_state procs. The set_state proc will now handle
   all of the icon_state behavior. set_state is called from the mob's default movement proc.
 * Changed constant names (ex: STATE_STANDING is now just STANDING).
 * The default movement proc can now call move(UP) and move(DOWN) too.
 * Changed the global movement loop (see the world_loop proc in mob-movement.dm)
    * Does not call the movement proc for objs anymore, just for mobs.
    * If you set OVERRIDE_WORLD_LOOP = 1 the loop will stop (so you can replace it with your own)

Version 1.3
 * Integrated documentation with DM's reference. See this page for instructions on how to set this up.
 * Removed the on_platform var.
 * Removed the can_move proc.

Version 1.2
 * Added scrolling backgrounds and a background demo.
 * Changed the way your loc is computed. It now takes into account your width and height so that your loc is the tile you overlap the most.

Version 1.1
 * Fixed the .zip file.


  -- Files --

To run a demo include all files in the "common" folder (keyboard.dmf) and include all of the files
from a single demo folder (simple-demo, background-demo, ramps-demo, or game-demo).

Library
	keyboard.dm
	mob-movement.dm
	mob-pathing.dm
	pixel-movement.dm
	procs.dm
	world.dm

background-demo
	Shows how to add a background image

	demo.dm
	map.dmm
	background.png

common
	This file is used by almost all of the demos.

	icons.dmi

game-demo
	A complete game with moving platforms, bullets, and spikes.

	enemies.dm
	mob.dm
	platforms.dm
	tiles.dm
	map.dmm

interaction-demo
	Shows how to use some helper procs to create ways for the player to
	interact with other objects.

	demo.dm
	enemy.dm
	map.dmm

mario-demo
	Shows how to implement some basic features that you'd see in a game
	like Super Mario Bros.

	demo.dm
	tiles.dm
	mario.dmi
	map.dmm

movement-demo
	Shows how to create new movement effects (wall climbing, wall jumping, flying)

	demo.dm
	map.dmm

pathing-demo
	Shows how to use the library's pathfinding features.

	demo.dm
	map.dmm

ramps-demo
	Shows how to define sloped tiles.

	demo.dm
	map.dmm

shooter-demo
	Shows how to create different types of projectiles

	demo.dm
	map.dmm

simple-demo
	This is about as simple as it gets. This demo shows what the library's
	default behavior gives you.

	demo.dm
	map.dmm

v2.4
	Shows how to use the features that are new in version 2.4.

	demo.dm
	map.dmm


  -- Reference --

The Background object is created by the mob.background proc. It's used to store
the object responsible for showing a background image and also for storing info
for positioning the image.

Background
	vars
		image/image
			This is how the background image is displayed. If we just used
			objs, every other player would be able to see your background. So,
			we use images and attach them to an obj. You shouldn't ever have
			to access this directly.

		obj/object
			If we used an obj to display your background, every other player
			would be able to see it. So, we leave this obj blank but attach
			images to it. The mob's set_camera proc adjusts the position of
			this object to position the background based on px and py. You
			shouldn't ever have to access this directly.

		mob/owner
			The mob that the background image is displayed for. Because the
			position of the background can be different for different players,
			you need to create a /Background object for each player.

		px, py
			The offset of the background image in pixels. By default (0, 0) the
			lower left corner of the image is in the center of the screen.

		width, height
			The width and height of the image used to create the background.

	procs
		hide()
			Removes the image from the owner's image list and removes the
			/Background object from the owner's backgrounds list.

		show()
			Adds the image to the owner's image list and adds the /Background
			object to the owner's backgrounds list.


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

		vel_x, vel_y
			The speed that the camera is moving at. You shouldn't ever need to
			modify these directly.

atom
	vars
		flags
			This value gets ORed with the mob's directional flags (on_ground, on_left, etc.) in
			the mob's set_flags proc. You can use the flags var to specify atom properties, then
			you can check individual bits of on_ground to see what properties the ground below
			the mob has.

			Example:

				// This example shows how to make icy floors. When
				// standing on an icy floor the mob won't slow down.

				var
					const
						ICY = 2

				mob
					slow_down()
						// This checks if the ICY bit is set
						if(on_ground & ICY)
							// If so, we return so ..() isn't called and
							// we don't slow down.
							return

						..()

				turf
					ice
						icon_state = "ice"
						flags = ICY

			The demo called "movement-demo" has been updated to show how to create icy floors
			(floors that you slide across) and icy walls (walls that the climber mob can't climb).
			These effects are created using atom.flags.

		flags_left, flags_right, flags_top, flags_bottom
			These are used the same way as the flags var except they let you define properties for
			individual sides of the atom.

		offset_x, offset_y
			The pixel offset applied to the atom. This is used when the bottom left of the atom's
			icon is not the bottom left of its bounding box.

			Example:

				Icon:				Bounding Box:
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

		pwidth, pheight
			The size of the atom's bounding box. The box is placed up and right from the atom's
			px/py position.

		pleft, pright
			The height of the tile at each side, this used for sloped tiles.

		px, py
			The atom's position in pixels. If the atom is located exactly at the tile coordinates (1,1)
			then its pixel coordinates are (32,32). If the atom is halfway between (1,1) and (2,1) then
			its pixel coordinates are (48,32).

	procs
		bottom(h)
			Returns a list of atoms within h pixels of src's bottom side.

		front(d)
			Calls left, right, top, or bottom based on src's direction.

		height(qx, qy, qw, qh)
			Returns the y value (in pixels) of the top of the atom that's nearest to the
			specified bounding box (the 4 parameters define this box). This is used to find
			the highest point of a ramp below a mob.

		inside()
			Returns a list of all atoms inside src's bounding box.

		inside(atom/a)
			Returns 1 if src is inside of a's bounding box and 0 otherwise.

		inside4(qx, qy, qw, qh)
			Returns 1 if src is in the bounding box of size qw x qh located at qx, qy and returns
			0 otherwise.

		left(w)
			Returns a list of atoms within w pixels of src's left side.

		nearby()
			Returns a list of atoms near the atom. The atoms on the same tile are listed
			first, the atoms in tiles in cardinal directions (up, down, left, right) are
			listed next, the atoms in tiles in diagonal directions are listed last. This
			proc is basically an alternative to oview() that's used because in pixel_move,
			the order matters.

		right(w)
			Returns a list of atoms within w pixels of src's right side.

		stepped_off(mob/m)
			This is called when a mob was standing on an atom in the previous tick, but is no
			longer standing on the atom in the current tick.

		Note: In version 2.4 the behavior of stepped_on has changed. Previously it was called
		      every tick for as long as you were standing on the atom. Now it's called only when
		      you start standing on the atom. For the old behavior, use stepping_on instead.
		stepped_on(mob/m)
			This is called when a mob was not standing on an atom in the previous tick, but is now
			standing on the atom in the current tick. To be standing on an atom the mob must be able
			to bump the atom and its top must be touching your bottom.

		stepping_on(mob/m, t)
			This is called every tick for as long as the mob is standing on the atom. The second
			argument, t, is the number of consecutive ticks that the mob has spent standing on
			the atom.

		top(h)
			Returns a list of atoms within h pixels of src's top side.


Note: Previously movement procs had been defined for /atom/movable but are now defined only
	  for mobs. The reason for doing this is to provide the developer with an object type (obj)
	  that can be used for objects whose loc can change but don't use pixel movement. You could
	  use objs for items because they can move (their loc changes from a turf to your mob when
	  you pick them up) but they don't use pixel movement. Objs don't need any new procs so all
	  pixel movement procs are now given only to mobs.

mob
	vars
		backgrounds
			This is the list of backgrounds that are currently being displayed for the player.
			You shouldn't have to access this list directly, you can add or remove backgrounds
			by calling the hide and show procs on the /Background object.

		base_state
			The prefix of all mob icon states. If a base state is specified, icon states will
			have the form [base state]-[action_state]-[dir_state], otherwise they will just
			be [action_state]-[dir_state].

		climb_speed
			This var is used by the climb() proc to limit how fast you can move while on a ladder.
			Its default value is 5.

		dropped
			This is set when the player presses the jump key while holding down. It's similar to
			how pressing the jump key doesn't make you jump, it just sets the jumped flag.

		fall_speed
			This var is used to limit your fall speed. It replaces the terminal_velocity var. Its
			default value is -20.

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

		on_ceiling, on_ground, on_left, on_right
			These vars are set by the set_flags() proc. You can use them to determine if a
			dense object is touching a side of the mob. It's often useful just to know if a
			dense object is next to the mob, you don't always need to know what object that is.
			For example, the can_jump proc checks the on_ground flag to only allow jumping if
			you're on the ground.

		on_ladder
			1 if the mob is hanging on a ladder, 0 otherwise.

		platform
			This is a reference to the platform (object of type /mob/platform) that the mob
			is standing on (if they are standing on one).

		vel_x, vel_y
			The mob's velocity in the x and y directions.

		Removed:
		background_width, background_height
			Use the width and height vars of the /Background object instead

		Removed:
		background_x, background_y
			Use the px and py vars of the /Background object instead

		Removed:
		on_platform
			Use on_ground instead.

		Removed:
		terminal_velocity
			Use fall_speed instead

	procs
		action()
			In version 2.2 the movement() proc was further split. The part that contains the
			movement behavior (the call to follow_path and the processing of keyboard input)
			was moved to the action proc. This way you can override the action proc to change
			a mob's movement behavior without overriding the entire movement proc.

			Because the movement proc handles a lot of things (enforces gravity, calls
			pixel_move, etc.) when you override it, you often want to change just a small
			part of the behavior (the part that's now in action()) but you have to remember
			to call gravity(), pixel_move(), and other procs. Now you can just override
			action if that's all you want to change.

		at_edge()
			Returns 1 if the mob is standing at the edge of a platform and 0 otherwise.

		background(icon, scroll_mode = 0)
			This proc creates a /Background object and returns it. To display the background
			add the /Background object to the mob's backgrouds list.

			The scroll mode can be zero, SCROLL_X, SCROLL_Y, or SCROLL_X + SCROLL_Y

		bump(atom/a, d)
			This is called when the mob bumps into something dense. The atom is the
			dense obstacle you hit and d is the direction you were moving in. d is
			either UP, DOWN, LEFT, or RIGHT.

		can_bump(atom/a)
			Returns 1 if src can bump the atom, otherwise returns ..().
			This allows for more complex density than just "all dense objects bump all
			other dense objects". For example, players cannot move through fences but
			bullets can, so player.can_bump(fence) = 1 but bullet.can_bump(bullet) = 0.

		can_jump(on_ground)
			Called to check if the mob is allowed to jump. The default behavior requires
			that you be standing on the ground and not be holding onto a ladder.

		clear_input()
			Clears the keys list so that key[k] = 0 for all keys.

		climb(direction)
			Called to handle movement while the mob is holding onto a ladder.

		dense(list/l)
			Returns 1 if the list contains an atom that src can_bump. Returns 0 otherwise.

		drop()
			Calling this will make a mob drop through a platform turf. A platform turf is a tile
			that is sort of dense - the player can walk in front of it but they can also stand on
			top of it.

		face(atom/a)
			Makes the mob turn to face the atom. If the mob is to the left of the atom the mob'll
			face right. If the mob is to the right, it'll face left.

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

		knockback(atom/a, magnitude = 4)
			Sets src's vel_x and vel_y to knock src away from a. The magnitude specifies
			the power of the knockback.

		lock_input()
			After lock_input is called, keystrokes will not be processed - pressing a key will
			not call key_down/key_up and will not modify the keys list.

		move(direction)
			Called to handle the action of walking left or right.

		move_to(turf/t)
			Plans a somewhat intelligent path to take the mob from it's current position
			to the specified destination t. After this is called, the mob will automatically
			move along the path. If the mob has a client connected, keyboard input will be
			ignored. You can think of this as the equivalent of DM's walk_to proc.
			To stop this movement you can call mob.move_to(null) or mob.stop().

		move_towards(turf/t)
			This proc is like the move_to proc except it doesn't plan a path, it just uses
			some basic rules to make the mob move towards its destination. This sounds useless
			compared to move_to, but it uses less CPU and is often sufficient - if you know that
			the mob and its destination are on the same platform and few obstacles are in
			between, you often don't need to bother planning a path.
			You can think of this as the equivalent of DM's walk_towards proc.
			To stop this movement you can call mob.move_towards(null) or mob.stop().

		movement()
			Automatically called every tick by a global loop. Handles the object's
			movement. The default action for a mob's movement proc is to process
			keyboard input and determine what action should be performed. It calls
			move, climb, and jump to handle each action. You can override those procs
			to change the behavior without having to mess with the movement proc.

			Part of the default behavior checks if the mob's loc has unexpectedly
			changed. This would happen when you've written code that manually changes
			a mob's loc. If it detects a change then it calls set_pos, this way you
			can still change a mob's loc like so:

				mob.loc = locate(10,3,2)

			And the next time movement() is called it'll figure out that the mob has
			moved and call set_pos to update its pixel coordinates and client display.

		pixel_move(dpx, dpy)
			Figures out if the object can perform the move [dpx, dpy]. If a dense object is in
			the way it figures out if the move can be partially made. Calls set_pos to perform
			the move. Returns 1 if any move was made and 0 if no move could be made.

		set_background()
			By default this proc does nothing. It's called every time the mob moves.
			It exists so you can override it to set the mob's background_x and background_y
			variables, which control the position of the background image. See
			background-demo for an example.

		set_camera()
			Sets the client's pixel offset.

		set_flags()

		set_pos(nx, ny)
			Sets the object's px and py to the nx and ny. Updates the object's loc and
			calls set_camera (if the object is a mob). This is automatically called by
			pixel_move so you shouldn't ever need to call set_pos.

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

		Removed:
		can_move(dpx, dpy, trigger_bumps = 1)
			This proc's functionality is taken care of by pixel_move now.

		Removed:
		compute_state(), set_action(), set_dir()
			The functionality that was handled by these procs is now handled by set_state.

turf
	vars
		ladder
			1 if the tile can be climbed, 0 otherwise.

		Removed:
		platform
			Use the scaffold var instead.

*/