////////////////////////////
// DON'T TOUCH THIS FILE! //
////////////////////////////
/*
 Unless you are a BYOND guru who is curious how this works,
 there is no point in reading this file.  It's just the gritty
 code, and you NEVER need to touch it or even read it.

 See characterhandling.dm for full library documentation.

 If you touch this file and then your character saving breaks,
 don't bug me about it, it's not my problem.
*/

#include <deadron/basecamp>
#define BASE_MENU_CHOOSE_CHARACTER  "Choose Character"//ChooseCharacterMenu()
#define BASE_MENU_CREATE_CHARACTER	"Create New Link"
#define BASE_MENU_DELETE_CHARACTER	"Delete Link"
#define BASE_MENU_CANCEL			"Cancel"
#define BASE_MENU_QUIT				"Disengage Link"


// Implementation
client/var/tmp
	base_num_characters_allowed = 4
	base_autoload_character = 1
	base_autosave_character = 1
	base_autodelete_mob = 0
	base_save_verbs = 1

mob/players
	base_save_allowed =1
	base_save_location=1
mob/mob
	base_save_allowed=1
	base_save_location=1

mob
	var
		base_save_allowed = 0	// Is this mob allowed to be saved?
		base_save_location = 0	// Should the mob's location be saved and restored?

	var/list/base_saved_verbs	// If we're saving verbs they are stored here.

	proc/base_InitFromSavefile()

		return

	Write(savefile/F)
		// Save the location if that has been specified and there is a map.
		// First, call the default Write() behavior for mobs.
		..()
		if (base_save_location && world.maxx)
			F["last_x"] << x
			F["last_y"] << y
			F["last_z"] << z
			//if(/soundmob)
				//return
		//	if(/obj/snd/sfx)//sound not loading has something to do with read/write. Got the sound (although, without atunement) to play but it was black screen (no loc for usr)
			//	return
		return

	Read(savefile/F)
		// Restore the mob's location if that has been specified and there is a map.
		// Tries to use Move() to place the character, in case the game has special Move() handling.
		// If that fails, forces the move by setting the loc.

		// Call the default Read() behavior for mobs.
		..()
		if (base_save_location)
			var/last_x
			var/last_y
			var/last_z
			F["last_x"] >> last_x
			F["last_y"] >> last_y
			F["last_z"] >> last_z
			if(last_x>world.maxx)
				del(src)
				return
		//	var/destination = locate(last_x, last_y, last_z)
			loc=locate(last_x, last_y, last_z)
			//if (!Move(destination))
				//loc = destination
			return

/*
	Read(savefile/F)
		// Restore the mob's location if that has been specified and there is a map.
		// Tries to use Move() to place the character, in case the game has special Move() handling.
		// If that fails, forces the move by setting the loc.

		// Call the default Read() behavior for mobs.
		..()
		return*/

mob/BaseCamp
	base_save_allowed = 0			// BaseCamp mobs are for admin only.
	var
		Form/NewCharacter/char_form = new()
		//Form/ChooseCharacter/choose_char = new()
		error_text = ""

	Login()
		var/list/available_char_names = client.base_CharacterNames()
		var/list/menu = new()
		menu += available_char_names
		//var/list/names
		//RemoveVerbs()
		//call(/soundmob/proc/broadcast)(src)
		// Don't use any other Login() code.
		//call(/soundmob/proc/setListener)()
		winset(usr, "loadscrn","parent=loadscrn; is-visible = true; focus = true")
		winset(usr, "default","parent=default; is-visible = true; focus = true")
		//sleep(9)
		winset(usr, "loadscrn","parent=loadscrn; is-visible = false; focus = false")
		winset(usr, "macros","parent=macros; is-visible = true; focus = true")
		world << "<center><b><font color=#00bfff>[src.key] has entered this realm!<p>"
		//world << "Tree amount = [treelist.len]"
		//sleep(3)
		//src << "<font color=gold><center>Information: <font color=gold>Arrow or wasd keys to walk, click/double-click to sprint, use, or attack. <br> Use the stance positions, V is sprint mode, C is Strafe mode and X is Hold Position. <br>Ctrl+E provides a quick-unequip menu and Ctrl+G provides a quick-get menu and ctrl+mouse wheel is zoom."
		src << "<center><b><font color=#00bfff>[src.key], Welcome to Pondera Sandbox mode! <p> Find Bugs? Report on the Hub, Pager or e-mail (AERSupport@live.com).<br>"// - (http://pondera.aerproductions.com | AERSupport@live.com)."
		//spawn()
		//ChooseCharacter()
		//QuitMenu()
		//return ..()
		//client.base_ChooseCharacter()
		//src.choose_char.DisplayForm()
		//if (!length(names))
			//FirstTimePlayer()
		//else
			//if (length(names))//if (length(available_char_names) == client.base_num_characters_allowed)
		ChooseCharacter()
			//ooseCharacterMenu(menu)
		//client.base_ChooseCharacter()
		/*winset(usr,"default.Build","is-visible=false")
		winset(usr,"default.Dig","is-visible=false")
		winset(usr,"default.Sow","is-visible=false")
		winset(usr,"default.Smelt","is-visible=false")
		winset(usr,"default.Smith","is-visible=false")
		winset(usr,"default.bar1","is-visible=false")
		winset(usr,"default.bar2","is-visible=false")
		winset(usr,"default.bar3","is-visible=false")
		winset(usr,"default.bar8","is-visible=false")
		winset(usr,"default.bar9","is-visible=false")
		winset(usr,"default.bar10","is-visible=false")
		winset(usr,"default.bar11","is-visible=false")
		winset(usr,"default.bar12","is-visible=false")
		winset(usr,"default.bar13","is-visible=false")
		winset(usr,"default.label1","is-visible=false")
		winset(usr,"default.label2","is-visible=false")
		winset(usr,"default.label4","is-visible=false")
		winset(usr,"default.label8","is-visible=false")
		winset(usr,"default.label9","is-visible=false")
		winset(usr,"default.label10","is-visible=false")
		winset(usr,"default.label11","is-visible=false")
		winset(usr,"default.label12","is-visible=false")
		winset(usr,"default.label13","is-visible=false")*/
		//light = new /light/day_night()

		// we turn the player's light source off initially, so
		// your light doesn't interfere with the shadows you cast.
		//light.off()
		//return

//#include "Soundmob.dm"
	//Logout()
		//usr._listening_soundmobs -= src
		// Don't use any other Logout() code.
		//leaveparty()
		//del(src)
		//world << "<font color = yellow><b>[usr] has vanished."
		//retur

	proc/RemoveVerbs()
		for (var/my_verb in verbs)
			verbs -= my_verb

//mob/BaseCamp/FirstTimePlayer
	proc/FirstTimePlayer()
		src.char_form.DisplayForm()
		return ..()


//mob/BaseCamp/ChoosingCharacter
	//Login()
		// spawn to make sure all administrative tasks are over.
		//call(/soundmob/proc/broadcast)(src)
		//spawn()
		//	ChooseCharacter()
		//	QuitMenu()
		//return ..()

	proc/ChooseCharacter()
		var/list/available_char_names = client.base_CharacterNames()
		var/list/menu = new()
		menu += available_char_names
		if (length(available_char_names) < client.base_num_characters_allowed)
			if (client.base_num_characters_allowed <= 1)
				// If only one character allowed, jump right to creating character.
				client.base_LoadMob()
				client.base_NewMob()
				del(src)
				return
			else
//				menu += BASE_MENU_CHOOSE_CHARACTER
				menu += BASE_MENU_CREATE_CHARACTER
				//menu += BASE_MENU_CANCEL
				//menu += BASE_MENU_QUIT

		if (length(available_char_names))
			menu += BASE_MENU_DELETE_CHARACTER
			menu += BASE_MENU_QUIT

		// Let developer provide their own menu if they wish.
		ChooseCharacterMenu(menu)
	proc/ChooseCharacterMenu(list/menu)
		// Given a list of menu options, display them and call ChooseCharacterResult() with the choice.
		var/default = null
		var/result = input(src, "What do you wish to do?", "Welcome to [world.name]!", default) in menu
		ChooseCharacterResult(result)

	proc/ChooseCharacterResult(menu_choice)
		// Respond to the option the player chose from the character choosing menu.
		switch(menu_choice)
//			if (BASE_MENU_CHOOSE_CHARACTER)
//				// Give them a chance to delete something, but then they need to choose.
//				ChooseCharacter()
//				return
			if (0, BASE_MENU_QUIT)
				// Kick them off.
				del(src)
				return

			if (BASE_MENU_CREATE_CHARACTER)
				src.char_form.DisplayForm()
				//client.base_NewMob()
				//del(src)
				return

			if (BASE_MENU_DELETE_CHARACTER)
				// Give them a chance to delete something, but then they need to choose.
				DeleteCharacter()
				return

		// They must have chosen a character, so load it.
		var/mob/players/Mob = client.base_LoadMob(menu_choice)//is the loading sound from save issue stemming from having a different mob loaded than intially created?
		if (!Mob)
			ChooseCharacter()

	proc/DeleteCharacter()
		var/list/available_char_names = client.base_CharacterNames()
		var/list/menu = new()
		menu += available_char_names

		menu += BASE_MENU_CANCEL
		menu += BASE_MENU_QUIT

		// Let developer provide their own menu if they wish.
		DeleteCharacterMenu(menu)

	proc/DeleteCharacterMenu(list/menu)
		// Given a list of menu options, display them and return the result.
		var/default = null
		var/result = input(src, "Which character do you want to delete?", "Deleting character", default) in menu
		if (result)
			DeleteCharacterResult(result)

	proc/DeleteCharacterResult(menu_choice)
		// Respond to the option the player chose from the character deletion menu.
		switch(menu_choice)
			if (0, BASE_MENU_QUIT)
				// Kick them off.
				del(src)
				return

			if (BASE_MENU_CANCEL)
				ChooseCharacter()
				return

		// They chose a character to delete.
		client.base_DeleteMob(menu_choice)
		ChooseCharacter()
		return
	proc/Quit()
		var/list/menu = new()

		menu += BASE_MENU_QUIT            //wtf  gotta figure this shit out after I sleep
		QuitMenu(menu)
	proc/QuitMenu(list/menu)
		QuitMenuResult()
	proc/QuitMenuResult()
		del(src.client)
		return
client
	var/tmp/savefile/_base_player_savefile

	New()

		// Let them choose/create a character.
		if (base_autoload_character)
			base_ChooseCharacter()
			base_Initialize()
			return
		return ..()

	Del()
		// Save character.
		if (base_autosave_character)
			base_SaveMob()

		// Delete mob.
		if (base_autodelete_mob)
			del(mob)
		return ..()


	proc/base_PlayerSavefile()
		if (!_base_player_savefile)
			// Put in players/[first_initial]/[ckey].sav
			var/start = 1
			var/end = 2
			var/first_initial = copytext(ckey, start, end)
			var/filename = "players/[first_initial]/[ckey].sav"
			_base_player_savefile = new(filename)
		return _base_player_savefile


	/*proc/base_FirstTimePlayer()
		var/mob/BaseCamp/FirstTimePlayer/first_mob = new()
		first_mob.name = key
		//first_mob.gender = gender
		mob = first_mob
		return first_mob.FirstTimePlayer()*/

	proc/base_Quit()
		del(src)
		return
	proc/base_ChooseCharacter()
		// Switches the player to a choosing character mob.
		// In case switching in middle of game, save previous mob.
		base_SaveMob()

		var/mob/BaseCamp/chooser

		// Do they have any characters to choose from?
		var/list/names = base_CharacterNames()
		if (!length(names))
			// They must be a first time player.
			//var/result = base_FirstTimePlayer()
			//if (!result)
				// They weren't approved, so boot 'em.
				//del(src)
				//return ..()

			// Okay let them create their first character.
			chooser = new()
			mob = chooser
			return

		// If only one character is allowed, try to just load it.
		//if (base_num_characters_allowed == 1)
			//base_LoadMob(names[1])
			//return

		chooser = new()
		mob = chooser
		return


	proc/base_CharacterNames()
		// Get the full names of all this player's characters.
		var/list/names = new()
		var/savefile/F = base_PlayerSavefile()

		F.cd = "/players/[ckey]/mobs/"
		var/list/characters = F.dir
		var/char_name
		for (var/entry in characters)
			F["[entry]/name"] >> char_name
			names += char_name
		return names


	proc/base_NewMob()
		// Give the player a standard mob.
		// First save existing mob if necessary.
		base_SaveMob()
		var/mob/mob/mob
		mob = new world.mob()
		mob.name = key
		mob.gender = gender
		mob = /mob/mob
//		player.base_Initialize()

		// Clear out the savefile to keep it from staying open.
		_base_player_savefile = null
		return mob


	proc/base_SaveMob()
		// Saves the player's current mob based on the ckey of its name.
		if (!mob || !mob.base_save_allowed)
			return

		// If we're saving verbs, move them over now.
		if (base_save_verbs)
			mob.base_saved_verbs = mob.verbs

		var/savefile/F = base_PlayerSavefile()

		var/mob_ckey = ckey(mob.name)

		var/directory = "/players/[ckey]/mobs/[mob_ckey]"
		F.cd = directory
		F["name"] << mob.name
		F["mob"] << mob
		//if(/soundmob)
		 //return 0
		_base_player_savefile = null


	proc/base_LoadMob(char_name)
		// Look for a character with the ckey version of this name.
		// If found, load it, set the client mob to it, and return it.
		// Otherwise return null.
		//var/mob/mob/Mob
		var/mob/players/Mob
		var/char_ckey = ckey(char_name)

		var/savefile/F = base_PlayerSavefile()
		_base_player_savefile = null

		F.cd = "/players/[ckey]/mobs/"
		//var/list/characters = F.dir
		//if (!characters.Find(char_ckey))
		//	world.log << "[key]'s client.LoadCharacter() could not locate character [char_name]."
		//	mob << "Unable to load [char_name]."
		//	return null

		F["[char_ckey]/mob"] >> Mob

		src.mob=Mob
		if (Mob)

			//call(/soundmob/proc/broadcast)(player)
			//call(/mob/players/proc/unlistenSoundmob)(Mob)
			Mob.base_InitFromSavefile()
			//call(/mob/players/proc/listenSoundmob)(player.client)
			// If we're doing verbs, set them now.
			if (base_save_verbs && Mob.base_saved_verbs)
				for (var/item in Mob.base_saved_verbs)
					Mob.verbs += item
			world << "Loaded Character"
			return Mob
		else return


	proc/base_DeleteMob(char_name)
		// Look for a character with the ckey version of this name.
		// If found, delete it.
		var/char_ckey = ckey(char_name)
		var/savefile/F = base_PlayerSavefile()

		F.cd = "/players/[ckey]/mobs/"
		F.dir.Remove(char_ckey)

