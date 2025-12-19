
/************************************************************************

	MAP STORAGE LIBRARY
	Created by Foomer

		The purpose of this library is to save and load maps for use in such
	things as level-based puzzle games. Currently it will save and load the
	entire map, and has no support for chunks, although that may change
	in the future. The library is setup so that if maps are tampered with,
	the game can detect this and optionally reject the tampered map file.
	Maps can also be password protected so that only the author of the
	map (or the creator of the game) can work with them in an editor.

	LIMITATIONS:

	* Bad things tend to happen if you try to have two objects of the same
	  type on the same turf when you save. Its nothing destructive, but
	  you'll end up with saved variables being tossed around between
	  objects.

	* Currently the library only saves and loads the entire game world at
	  once. Chunks aren't implemented right now.

	* Before a map is loaded, it will run a function called ClearMap that
	  will attempt to remove all turfs and objects from the map, and any
	  cliented mobs will be moved to null. Make sure you move players
	  back onto the map after loading it, otherwise you'll be stuck in null.

*************************************************************************/
/************************************************************************

INSTRUCTIONS:

STEP 1) You need to create a map storage datum to use this library. If
	you just want to use the basic saving and loading functions and you
	don't need to override any procs, then you can create a global map
	storage object like this:

			var/map_storage/map_storage = new(game_id, backdoor, ignore)

	If you want more control over what's happening in certain functions,
	then you'll need to create your own version of the map storage datum:

			var/map_storage/my_saving/my_saving = new()

			map_storage/my_saving
				game_id = "FoomerMaps"
				backdoor_password = "CutiePie"
				ignore_types = list(/mob)

	Either way, you'll need to specify some additional options:

	* The GAME_ID variable is used to identify your game and separate it
		from any other games that may be using this library. A map saved
		with one game_id can not be loaded by a game using a different ID.

	* The BACKDOOR is an secondary password that allows access to maps
	  which are password protected. This is necessary in order for a game
	  to be able to load password-locked maps freely using the backdoor
	  password, while a level editor requires users to enter the map's
	  password in order to edit it. The backdoor can also be entered
	  at the password prompt in order for the developer to access
	  password-locked maps for debugging purposes.

	  NOTE: Backdoor passwords will only work if a game_id is specified.

	* The IGNORE LIST is an optional list which specifies which object
	  types you do NOT want to be saved with the map, such as /mob, which
	  will prevent any mobs from being saved on the map.



STEP 2) You need to specify which objects will have which variables saved.
	You can do this using the variable called map_storage_saved_vars. This
	variables accepts a params string containing the names of the variables
	that you want to save with the map when this object is saved.

	For example, if you have a door and you want to save whether the door
	has been opened or not, you could do it like this"

			turf/door
				density = 1
				opacity = 0
				var/opened = 0

				map_storage_saved_vars = "density;opacity;opened"

	Then the "density", "opacity" and "opened" variables will be saved with
	the gate object, but only if those variables have been modified from
	their original values. If they haven't been changed, they won't be saved,
	to conserve map space.



STEP 3) You can SAVE maps using the map_storage.Save() function, like this:

			var/savefile/map = new("map.sav")
			map_storage.Save(map, password, extra)

	The map argument is a savefile which needs to be created before trying
	to save any information to it (See _example.dm). If you want the file
	to be password-locked, then specify the password here.

	NOTE: Passwords are case-sensetive.

	You can also add in a list (or params) containing any extra values that
	you want to be stored with the file. These values will be returned by
	the Load() function in /list format when a map is loaded.

	The function will return true if the map was loaded successfully.



STEP 4) You can load maps using the map_storage.Load() function, like this:

			var/savefile/map = new("map.sav")
			var/list/extra = map_storage.Load(map, password)

	The map argument is the savefile containing the saved map data. If the
	map is password-locked, you will need to specify the correct password
	or a backdoor password in order to open the map.

	When a map is loading, before it actually loads anything it will run
	a function called ClearMap that will attempt to clear all turfs and
	objects off the map, and will move any cliented mobs to null. You'll
	need to remember to move any players back onto the map after it loads.

	Once a map is successfully loaded, it will return a /list containing
	any extra variables that were added to the savefile in Save().



	There are also some additional functions that you can use to get info
	about the map before you decide to load it.

	* map_storage.IsValid(savefile) can be used to find out if this is a
	  valid map file, and if it was created using the same game_id. If not,
	  then it will return false. Otherwise it returns true.

	* map_storage.Verify(savefile) lets you find out if the map has been
	  changed at all since it was last saved through this library. If the
	  map has been changed, then verification will return false.

	* map_storage.PasswordLocked(savefile) lets you find out of the map
	  has a password lock or not. Returns true if it does.

	You can use the map_storage.GetExtra() function to extract any extra
	variables stored in the savefile anytime you'd like, like this:

		map_storage.GetExtra(map)

	That will return a /list containing all the extra variables stored in
	the savefile, along with their associated values. Or:

		map_storage.GetExtra(map, variable)

	This will return the value associated with the requested variable.




OTHER STUFF)

	If you create your own version of the map storage datum, you can
	override some functions in order to change their behavior. For instance,
	the _example.dm shows you how to override the SaveOutput(percent) and
	LoadOutput(percent) procs to have them update a label to display the
	current saving or loading progress:

			var/map_storage/map_save/map_save = new()
			map_storage/map_save
				game_id = "FoomerMaps"
				backdoor_password = "CutiePie"
				ignore_types = list(/mob)

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

	You can also override the library's ClearMap() function in order to
	change how the library handles clearing the map before it loads a new
	one:

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


*************************************************************************/
