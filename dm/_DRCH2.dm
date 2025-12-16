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

#define BASE_MENU_SELECT_MODE  "Single Player"
#define BASE_MENU_SELECT_MODE2  "Multi-Player"
#define BASE_MENU_CHOOSE_CHARACTER  "Choose Character"//ChooseCharacterMenu()
#define BASE_MENU_CREATE_CHARACTER	"Create Link"
#define BASE_MENU_DELETE_CHARACTER	"Delete Link"
#define BASE_MENU_CANCEL			"Cancel"
#define BASE_MENU_QUIT				"End Link"


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
		
		// CRITICAL: Write savefile version stamp
		WriteSavefileVersion(F)
		
		if (base_save_location && world.maxx)
			F["last_x"] << x
			F["last_y"] << y
			F["last_z"] << z
		
		// Save character and equipment data
		if(ismob(src, /mob/players))
			var/mob/players/player = src
			
			// Save character progression datum
			if(player.character)
				F["character"] << player.character
			
			// Save inventory state (item stacks)
			if(player.inventory_state)
				player.inventory_state.CaptureInventory(player)
				F["inventory_state"] << player.inventory_state
			
			// Save equipment state (equipped items)
			if(player.equipment_state)
				player.equipment_state.CaptureEquipment(player)
				F["equipment_state"] << player.equipment_state
			
			// Save vital state (HP, stamina, status)
			if(player.vital_state)
				player.vital_state.CaptureVitals(player)
				F["vital_state"] << player.vital_state
			
			// Save recipe/knowledge state (discovered recipes, learned topics)
			if(player.character && player.character.recipe_state)
				player.character.recipe_state.ValidateRecipeState()
				F["recipe_state"] << player.character.recipe_state
			
			// Save multi-world continent data
			F["current_continent"] << player.current_continent
			F["continent_positions"] << player.continent_positions
			F["stall_owner"] << player.stall_owner
			F["stall_inventory"] << player.stall_inventory
			F["stall_prices"] << player.stall_prices
			F["stall_profits"] << player.stall_profits
		return

	Read(savefile/F)
		// CRITICAL: Validate savefile version before loading
		var/file_version = ValidateSavefileVersion(F)
		if(file_version == 0)
			// Incompatible savefile - cannot load
			world.log << "\[LOAD\] Refusing to load incompatible savefile"
			del(src)
			return
		else if(file_version < GetSavefileVersion() && file_version > 0)
			// Compatible but needs migration
			if(!MigrateSavefileVersion(F, file_version, GetSavefileVersion()))
				world.log << "\[LOAD\] Migration failed, attempting load anyway"
		
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
			loc=locate(last_x, last_y, last_z)
			
			// CRITICAL: Validate spawn location post-load to prevent stuck players
			if(ismob(src, /mob/players))
				var/mob/players/player = src
				var/turf/spawn_location = player.loc
				
				// Check if current location is valid
				if(!spawn_location || !ValidateSpawnLocation(spawn_location))
					world.log << "\[INIT\] SpawnValidation: Invalid spawn location at ([last_x],[last_y],[last_z]) - relocating player"
					
					// Try to find safe alternative
					var/turf/safe_spawn = FindSafeSpawnTurf(spawn_location)
					if(safe_spawn)
						player.loc = safe_spawn
						world.log << "\[INIT\] SpawnValidation: Relocated player to safe location ([safe_spawn.x],[safe_spawn.y],[safe_spawn.z])"
					else
						// Fallback: world center
						player.loc = locate(world.maxx / 2, world.maxy / 2, 2)
						world.log << "\[INIT\] SpawnValidation: Fallback - placed player at world center"
		
		// Restore character progression data and equipment
		if(ismob(src, /mob/players))
			var/mob/players/player = src
			
			// Restore character progression datum
			F["character"] >> player.character
			if(!player.character)
				player.character = new /datum/character_data()
				player.character.Initialize()
			
			// SECURITY: Initialize per-player cheat detection offsets
			InitializePlayerSecurity(player)
			
			// Restore inventory state (item stacks)
			F["inventory_state"] >> player.inventory_state
			if(!player.inventory_state)
				player.inventory_state = new /datum/inventory_state()
			
			// Restore equipment state (equipped flags)
			F["equipment_state"] >> player.equipment_state
			if(!player.equipment_state)
				player.equipment_state = new /datum/equipment_state()
			else
				player.equipment_state.RestoreEquipment(player)
			
			// Restore vital state (HP, stamina, status)
			F["vital_state"] >> player.vital_state
			if(!player.vital_state)
				player.vital_state = new /datum/vital_state()
			else
				player.vital_state.RestoreVitals(player)
			
			// Restore recipe/knowledge state (discovered recipes, learned topics)
			F["recipe_state"] >> player.character.recipe_state
			if(!player.character.recipe_state)
				player.character.recipe_state = new /datum/recipe_state()
				player.character.recipe_state.SetRecipeDefaults()
			else
				player.character.recipe_state.ValidateRecipeState()
			
			// Restore multi-world continent data
			F["current_continent"] >> player.current_continent
			if(!player.current_continent)
				player.current_continent = CONT_STORY
			
			F["continent_positions"] >> player.continent_positions
			if(!player.continent_positions)
				player.continent_positions = list()
				player.continent_positions[CONT_STORY] = GetContinentSpawnPoint(CONT_STORY)
				player.continent_positions[CONT_SANDBOX] = GetContinentSpawnPoint(CONT_SANDBOX)
				player.continent_positions[CONT_PVP] = GetContinentSpawnPoint(CONT_PVP)
			else
				// Fill in any missing continents
				if(!(CONT_STORY in player.continent_positions))
					player.continent_positions[CONT_STORY] = GetContinentSpawnPoint(CONT_STORY)
				if(!(CONT_SANDBOX in player.continent_positions))
					player.continent_positions[CONT_SANDBOX] = GetContinentSpawnPoint(CONT_SANDBOX)
				if(!(CONT_PVP in player.continent_positions))
					player.continent_positions[CONT_PVP] = GetContinentSpawnPoint(CONT_PVP)
			
			F["stall_owner"] >> player.stall_owner
			F["stall_inventory"] >> player.stall_inventory
			F["stall_prices"] >> player.stall_prices
			F["stall_profits"] >> player.stall_profits
			
			// Initialize any missing stall variables
			if(!player.stall_owner) player.stall_owner = ""
			if(!player.stall_inventory) player.stall_inventory = list()
			if(!player.stall_prices) player.stall_prices = list()
			if(!player.stall_profits) player.stall_profits = 0
		return
	//verb/Mode()
		//src << "verb SP [SP] | MP [MP] | SB [SB] | SM [SM] && SPs [SPs] | MPs [MPs] | SBs [SBs] | SMs [SMs]"
/*
	Read(savefile/F)
		// Restore the mob's location if that has been specified and there is a map.
		// Tries to use Move() to place the character, in case the game has special Move() handling.
		// If that fails, forces the move by setting the loc.

		// Call the default Read() behavior for mobs.
		..()
		return*/
/*
	// DEPRECATED: This /mob/Login() has been consolidated into /mob/players/Login() in Basics.dm
	// Keeping for reference only - DO NOT USE
mob
	Login()//character login
		client.draw_lighting_plane()
			//S
		draw_spotlight(0, 0, "#FFFFFF", 1.3, 255)
		remove_spotlight()
		winset(src, "R", "parent=macros;name=Run;command=Run")
		winset(src, "NORTH", "parent=macros;name=NORTH+REP;command=")
		winset(src, "SOUTH", "parent=macros;name=SOUTH+REP;command=")
		winset(src, "EAST", "parent=macros;name=EAST+REP;command=")
		winset(src, "WEST", "parent=macros;name=WEST+REP;command=")
		winset(src, "NORTH", "parent=macros;name=NORTH;command=MoveNorth")
		winset(src, "SOUTH", "parent=macros;name=SOUTH;command=MoveSouth")
		winset(src, "EAST", "parent=macros;name=EAST;command=MoveEast")
		winset(src, "WEST", "parent=macros;name=WEST;command=MoveWest")
		winset(src, "W", "parent=macros;name=W+REP;command=")
		winset(src, "S", "parent=macros;name=S+REP;command=")
		winset(src, "D", "parent=macros;name=D+REP;command=")
		winset(src, "A", "parent=macros;name=A+REP;command=")
		winset(src, "W", "parent=macros;name=W;command=MoveNorth")
		winset(src, "S", "parent=macros;name=S;command=MoveSouth")
		winset(src, "D", "parent=macros;name=D;command=MoveEast")
		winset(src, "A", "parent=macros;name=A;command=MoveWest")
		src.move=1
		src.Moving=0
		//src.updateHP()
		//src.updateST()
			//sleep(5)
			//goto S
*/

mob
	Login()//character login (DEPRECATED - see Basics.dm /mob/players/Login())
		client.draw_lighting_plane()
			//S
		draw_spotlight(0, 0, "#FFFFFF", 1.3, 255)
		remove_spotlight()
		winset(src, "R", "parent=macros;name=Run;command=Run")
		winset(src, "NORTH", "parent=macros;name=NORTH+REP;command=")
		winset(src, "SOUTH", "parent=macros;name=SOUTH+REP;command=")
		winset(src, "EAST", "parent=macros;name=EAST+REP;command=")
		winset(src, "WEST", "parent=macros;name=WEST+REP;command=")
		winset(src, "NORTH", "parent=macros;name=NORTH;command=MoveNorth")
		winset(src, "SOUTH", "parent=macros;name=SOUTH;command=MoveSouth")
		winset(src, "EAST", "parent=macros;name=EAST;command=MoveEast")
		winset(src, "WEST", "parent=macros;name=WEST;command=MoveWest")
		winset(src, "W", "parent=macros;name=W+REP;command=")
		winset(src, "S", "parent=macros;name=S+REP;command=")
		winset(src, "D", "parent=macros;name=D+REP;command=")
		winset(src, "A", "parent=macros;name=A+REP;command=")
		winset(src, "W", "parent=macros;name=W;command=MoveNorth")
		winset(src, "S", "parent=macros;name=S;command=MoveSouth")
		winset(src, "D", "parent=macros;name=D;command=MoveEast")
		winset(src, "A", "parent=macros;name=A;command=MoveWest")
		src.move=1
		src.Moving=0
		//src.updateHP()
		//src.updateST()
			//sleep(5)
			//goto S
		return ..()  // CRITICAL: Call parent to continue chain to /mob/players/Login()


mob/BaseCamp
	base_save_allowed = 0			// BaseCamp mobs are for admin only.
	var
		Form/NewCharacterSB/SBchar_form = new()
		Form/NewCharacterSM/SMchar_form = new()
		Form/NewCharacterMPSB/MPSBchar_form = new()
		Form/NewCharacterMPSM/MPSMchar_form = new()
		Form/ModeMenu/mode_form = new()
		Form/TechTree/TT_form = new()
		//Form/SOS/mode2_form = new()
		//Form/ChooseCharacter/choose_char = new()
		error_text = ""

	Login()//login character creation start
		var/list/available_char_names = client.base_CharacterNames()
		var/list/menu = new()
		menu += available_char_names
		if(ckeyEx("[usr.key]") == world.host)
			TimeLoad()
		//SetMode()
		//var/list/names
		//RemoveVerbs()
		//call(/soundmob/proc/broadcast)(src)
		// Don't use any other Login() code.
		//call(/soundmob/proc/setListener)()
		//client.draw_lighting_plane()
		//usr.draw_spotlight(-17, -17, "#FFFFFF", 1.3, 255)
		//src.remove_spotlight()
		winset(usr, "loadscrn","parent=loadscrn; is-visible = true; focus = true")
		winset(usr, "default","parent=default; is-visible = true; focus = true")
		//sleep(9)
		//winset(usr, "loadscrn","parent=loadscrn; is-visible = false; focus = false")
		//winset(usr, "macros","parent=macros; is-visible = true; focus = true")
		world << "<center><b><font color=#00bfff>[src.key] has entered this realm!<p>"
		//world << "Tree amount = [treelist.len]"
		//sleep(3)
		//src << "<font color=gold><center>Information: <font color=gold>Arrow or wasd keys to walk, click/double-click to sprint, use, or attack. <br> Use the stance positions, V is sprint mode, C is Strafe mode and X is Hold Position. <br>Ctrl+E provides a quick-unequip menu and Ctrl+G provides a quick-get menu and ctrl+mouse wheel is zoom."
		src << "<center><b><font color=#00bfff>[src.key], Welcome to Pondera! <p> Find Bugs? Report on the Hub, Pager or e-mail (AERSupport@live.com) - https://aerproductions.com/pond .<br>"// - (http://pondera.aerproductions.com | AERSupport@live.com)."
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
		sleep(5)
		winset(usr, "loadscrn","parent=loadscrn; is-visible = false; focus = false")
		//FirstTimePlayer()

		//world << "Basecamp login SP [SP] | MP [MP] | SB [SB] | SM [SM] && SPs [SPs] | MPs [MPs] | SBs [SBs] | SM [SMs]"
		if(SP!=1&&MP!=1)
			FirstTimePlayer()
		else
			ChooseCharacter()

		if(ckeyEx("[usr.key]") == world.host&&MP==1)
			verbs += typesof(/mob/players/Special1/verb)
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
		//new /light/day_night()

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
		if(ckeyEx("[usr.key]") == world.host)
		//src << "SP [SP] | MP [MP] | SB [SB] | SM [SM]"
		//SelectMode()

			// Use new character creation UI instead of HTML forms
			start_character_creation_ui()
		else
		//else if(global.SP==1||global.SB==1||global.MP==1||global.SM==1)
			ChooseCharacter()

			//src.mode_form.DisplayForm()
		return //..()


//mob/BaseCamp/ChoosingCharacter
	//Login()
		// spawn to make sure all administrative tasks are over.
		//call(/soundmob/proc/broadcast)(src)
		//spawn()
		//	ChooseCharacter()
		//	QuitMenu()
		//return ..()
	//proc/SelectMode()//Need to be able to select between singleplayer/multiplayer and sandbox/story modes
		//var/list/available_char_names = client.base_CharacterNames()
		//var/list/available_modes = src.mode_form.DisplayForm()
		//var/list/menu = new()
		//menu += available_modes
		//src.mode_form.DisplayForm()
//				menu += BASE_MENU_CHOOSE_CHARACTER
		//menu += BASE_MENU_SELECT_MODE//BASE_MENU_CREATE_CHARACTER
		//menu += BASE_MENU_SELECT_MODE2
				//menu += BASE_MENU_CANCEL
				//menu += BASE_MENU_QUIT

		// Let developer provide their own menu if they wish.
		//SelectModeMenu(menu)

	proc/SelectModeMenu(list/menu)
		// Given a list of menu options, display them and call ChooseCharacterResult() with the choice.
		//var/default = null
		//var/result = input(src, "What do you wish to do?", "Welcome to [world.name]!", default) in menu
		SelectModeResult()
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
	proc/SelectModeResult(menu_choice)
		// Respond to the option the player chose from the character choosing menu.
		switch(menu_choice)
//			if (BASE_MENU_CHOOSE_CHARACTER)
//				// Give them a chance to delete something, but then they need to choose.
//				ChooseCharacter()
//				return


			if (BASE_MENU_SELECT_MODE)
				src.mode_form.DisplayForm()
				//client.base_NewMob()
				//del(src)
				return

			if (BASE_MENU_SELECT_MODE2)
				// Give them a chance to delete something, but then they need to choose.
				//src.mode2_form.DisplayForm()
				return

		// They must have chosen a character, so load it.
		//var/mob/players/Mob = client.base_LoadMob(menu_choice)//is the loading sound from save issue stemming from having a different mob loaded than intially created?
		//if (!Mob)
			//ChooseCharacter()
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
				if(global.SB==1&&global.SP==1)
					//mob << browse(page, "window=NewCharacterSB")
					src.SBchar_form.DisplayForm()
				if(global.SM==1&&global.SP==1)
					//mob << browse(page, "window=NewCharacterSM")
					src.SMchar_form.DisplayForm()
				if(global.SB==1&&global.MP==1)
					//mob << browse(page, "window=NewCharacterMPSB")
					src.MPSBchar_form.DisplayForm()
				if(global.SM==1&&global.MP==1)
					//mob << browse(page, "window=NewCharacterMPSM")
					src.MPSMchar_form.DisplayForm()

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
		// Returns TRUE if save successful, FALSE otherwise
		if (!mob || !mob.base_save_allowed)
			return FALSE

		// If we're saving verbs, move them over now.
		if (base_save_verbs)
			mob.base_saved_verbs = mob.verbs

		var/savefile/F = base_PlayerSavefile()
		if(!F)
			world.log << "\[SAVE\] ERROR: Could not open savefile for [key]"
			return FALSE

		var/mob_ckey = ckey(mob.name)

		var/directory = "/players/[ckey]/mobs/[mob_ckey]"
		F.cd = directory
		F["name"] << mob.name
		F["mob"] << mob
		
		world.log << "\[SAVE\] Saved character [mob.name] for [key]"
		_base_player_savefile = null
		return TRUE


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
			//Mob.umsl_ObtainMultiLock(list("right leg", "left leg"), 2)
			Mob << "Loading Complete"
			return Mob
		else return


	proc/base_DeleteMob(char_name)
		// Look for a character with the ckey version of this name.
		// If found, delete it.
		var/char_ckey = ckey(char_name)
		var/savefile/F = base_PlayerSavefile()

		F.cd = "/players/[ckey]/mobs/"
		F.dir.Remove(char_ckey)

