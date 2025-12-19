/*

  -- Introduction --

The goal of this library is to provide a simple and powerful
way to define groups of turfs that behave as a single region.
For example, you can place an /area over many tiles and set
the area's Entered() proc to display a message to the player.
Since each turf can only be in one /area, you can't have these
types of areas overlap. With regions, you can place multiple
/region objects on a single turf, making that turf behave as
part of multiple regions.


  -- Running Demos --

To run a demo, pick a demo folder (ex: button-demo) and
include all of the files in the folder. Then recompile and
run the library to see the demo.


  -- Version History --

Version 9 (posted 03-07-2012)
 * Added roof-demo which shows how to hide regions of the map until the
   player enters the region.

Version 8 (posted 03-03-2012)
 * Added #define FA_REGION to the .dme file. This can be used outside
   of this project to detect when the Region library has been included.
 * Added the get() and get_list() procs for region objects. The global
   region.get and region.get_list procs simply call these procs for each
   region the source turf is in.
 * Added the add, remove, added, and removed procs for the /region object.
   Each proc takes a turf as an argument. The add/remove procs add or remove
   a turf from the region. The added/removed procs are called when a turf
   is added or removed from a region.
 * Added wire-demo which shows how to create a graphical effect associated
   with a region. It uses a region to manage which turfs have wires placed
   on them. It also uses the get_list() proc to find all doors that are
   connected to a button.
 * Moved some code from region.dm into the new movement.dm.

Version 7 (posted 02-29-2012)
 * Added the global variable called region which is an object containing the get() and
   get_list() procs. These procs split the turfs within a region into disjoint sets and
   search the source atom's set for instances of a specified object type. For example,
   you can place region objects on the map connecting a switch object to a door object.
   Then, at runtime, you can call region.get(switch, /obj/door) to get a reference to
   the door.
 * Added button-demo which is an example of what I just described. It uses the region.get()
   proc to associate buttons with doors.
 * Added partition.dm which contains the new features.
 * Added _readme.dm which contains a description of the library and a version history.

Version 6 (posted 10-27-2011)
 * Added support for the region's Entered() and Exited() procs when using pixel movement.

Version 5 (posted ???)
 * Added support for Enter() and Exit() procs on the region. You can now restrict movement
   by overriding these procs. When you try to Enter a region, the region's Enter proc will
   be called. If it returns false the move isn't allowed. The same is done with the Exit proc
   when leaving a region.
 * The library used to use both turf/Entered and mob/Move to detect the Entered and Exited
   events for regions. The library now only uses mob/Move. This is beneficial because previously,
   you could break the library by overriding turf/Entered but not call ..().

Version 4 (posted 08-24-2011)
 * To save memory, the turf's regions var is no longer initialized to be a list. If the turf
   is in any regions it will be set to a list, otherwise it'll be null.

Version 3 (posted 05-07-2011)
 * Fixed a mistake - the region's Entered/Exited procs were being passed the turf, not the mob.

Version 2 (posted 05-07-2011)
 * The /region object now has a list of turfs that it contains.
 * Cleaned up the code a little and added some more comments to it.

Version 1 (posted 04-18-2011)
 * Initial post, the library defines the /region

*/