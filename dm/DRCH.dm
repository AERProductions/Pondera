#include "DRCH2.dm"

/////////////////////////////////////////////
// WELCOME TO BASECAMP: CHARACTER HANDLING //
/////////////////////////////////////////////
/*
 For a fully working example using this library, download:

 byond://Deadron.SimpleSaving

 or

 byond://Deadron.CharacterSaving

 Everything you need to read about the library is in this file.
 You don't need to look at anything else in the library, unless
 you have a good understanding of BYOND and want to see how it
 works.
*/


/****
 USING THE LIBRARY
 To use the library, you only need to include it, with this line:

#include <deadron/characterhandling>

 You don't need to copy/paste any library code or anything.
 By including it, it will automatically add itself to your game.

 You don't need to do anything else special to use the library.
 The only requirement is the same as for any BYOND game:
 Specify the mob type for new mobs in world.mob, as discussed
 in detail below.

 What it does
 ------------
 When a player logs in, the library checks to see if they have
 any characters saved.  If they do, and if you only allow for
 one character, then the player is immediately logged into that
 character and all their attributes and inventory are restored.

 When the player logs out, their character is automatically saved.
 The character is saved based on its name.


 Choosing a character
 --------------------
 If you allow for multiple characters, then the library lets the
 player choose which character they want to play, or to create
 or delete a character.  When the player chooses a character,
 they are logged into it.  By default he library handles the choosing
 process automatically.  You don't need to do anything.

 You can customize the menus used for choosing and deleting characters,
 as discussed below.

 If you want to change the default behavior, look at the client
 variables discussed further down in this file.


 Creating a character
 --------------------
 If a character needs to be created, then the library creates
 a mob of type world.mob and logs the character into it.
 Whatever you specify as world.mob is what is created.
 For example, if this is how world.mob is set:

world
    mob = /mob/new_character

 Then when a brand new character is created, it will be of type
 /mob/new_character.  You can make this any class you want, and
 can do anything you want with the class.  The library just creates
 a mob of that class and logs the player into it.

 If you want the player to specify attributes when their character
 is created, then you might have a mob class designed just to
 ask them what kind of character they want.  See the CharacterSaving
 demo for a complete example of this.

***/


/*
 Setting the number of characters
 --------------------------------
 You can specify how many characters a player is allowed to have.
 using the client variable, base_num_characters_allowed.

 If you set it to 1, then players will be immediately logged into
 their one character.  If you allow more than one, then players will
 automatically be given a choice of which character to they want to play,
 as well as options for creating and deleting characters.
*/
client/base_num_characters_allowed = 4


/*
 Automatically loading/saving player characters
 ---------------------------------------
 By default, CharacterHandling will automatically load the player's
 character on login, and save a player's character and delete the mob
 on logout.  If you don't want one or more of these to happen by default,
 then set the appropriate "auto" variable(s) to 0.

 If you don't want the character autoloaded, call the player's
 client.base_ChooseCharacter() when you DO want it loaded.
*/
client/base_autoload_character = 1
client/base_autosave_character = 1
client/base_autodelete_mob = 1

/*
 Saving verbs
 ------------
 BYOND does not save verbs, but the library takes care of this for you
 by default. If you don't want verbs saved, then set this to 0 in
 your code.
*/
client/base_save_verbs = 1


client/base_ChooseCharacter()

	/*
	 Choosing a character
	 --------------------
	 This function is called automatically on login if
	 client.base_autoload_character is 1.  If only one
	 character is allowed, it immediately logs the player
	 into a character.  If multiple characters are allowed,
	 it gives the player a menu to create/choose/delete
	 characters.
	 <tr><td align="center"><a href="?menu=choosing_character;choice=[item];src=\ref[src]">\[[item]]</a></td></tr>
	 <tr><td align="center"><a href="?menu=deleting_character;choice=[item];src=\ref[src]">\[[item]]</a></td></tr>
	*/
	//src.choose_char.DisplayForm()
	return ..()


mob/BaseCamp
	New()
		..()

	SelectModeMenu(list/menu)
		// For each menu item, we'll create an HTML link in a table.
		// The Topic() proc gets called when a link is clicked.
		// The src setting tells it to call Topic() for this object.
		usr << browse_rsc('chcmenu.jpg', "chcmenu.jpg")
		usr << browse_rsc('cscmenu.jpg', "cscmenu.jpg")
		usr << browse_rsc('choose.png', "choose.png")
		usr << browse_rsc('new.png', "new.png")
		usr << browse_rsc('delete.png', "delete.png")
		usr << browse_rsc('quit.png', "quit.png")
		usr << browse_rsc('dcmenu.jpg', "dcmenu.jpg")
		var/menu_rows = ""
		for (var/item in menu)
			menu_rows += {"<tr><td align="center"><font size=5><a href="?menu=select_mode;choice=[item];src=\ref[src]">\[[item]]</a></font></td></tr>"}
		var/page = {"
		<style type="text/css">
		 table.c1 {position:absolute; left:0px; top:0px; width:px; height:px; z-index:1}
		 table.c0 {position:absolute; left:132px; top:60px; width:px; height:px; z-index:2}
		</style>
		<style type="text/css">
		 body {
		  background-color: #206B24;
		  color: #10ca63;
		  position: absolute;
		  input: focus;
		  max-height: 400px;
		  max-width: 398px;
		  text-align: center;
		 }
		 :link { color: #10ca63 }
		 :visited { color: #003DCA }
		</style>
		<table align="center" id="Layer0" class="c0" cellspacing="2" cellpadding="2" border="0">
		<tbody>
		<tr>
		<td align="center">[menu_rows]</td>
		</tr>
		</tbody>
		</table>
		<table id="Layer1" class="c1" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
		<td><img src="cscmenu.jpg" alt="" border="0"></td>
		</tr>
		</tbody>
		</table>
		"}

		// Send them the page.
		src << browse(page, "window=ModeMenu;titlebar=0;can_close=0;can_minimize=0;allow_transparency=true;size=400x398;focus=true;can_resize=0")


	ChooseCharacterMenu(list/menu)
		// For each menu item, we'll create an HTML link in a table.
		// The Topic() proc gets called when a link is clicked.
		// The src setting tells it to call Topic() for this object.
		usr << browse_rsc('chcmenu.jpg', "chcmenu.jpg")
		usr << browse_rsc('cscmenu.jpg', "cscmenu.jpg")
		usr << browse_rsc('choose.png', "choose.png")
		usr << browse_rsc('new.png', "new.png")
		usr << browse_rsc('delete.png', "delete.png")
		usr << browse_rsc('quit.png', "quit.png")
		usr << browse_rsc('dcmenu.jpg', "dcmenu.jpg")
		var/menu_rows = ""
		for (var/item in menu)
			menu_rows += {"<tr><td align="center"><font size=5><a href="?menu=choosing_character;choice=[item];src=\ref[src]">\[[item]]</a></font></td></tr>"}
		var/page = {"
		<style type="text/css">
		 table.c1 {position:absolute; left:0px; top:0px; width:px; height:px; z-index:1}
		 table.c0 {position:absolute; left:132px; top:60px; width:px; height:px; z-index:2}
		</style>
		<style type="text/css">
		 body {
		  background-color: #206B24;
		  color: #10ca63;
		  position: absolute;
		  input: focus;
		  max-height: 400px;
		  max-width: 398px;
		  text-align: center;
		 }
		 :link { color: #10ca63 }
		 :visited { color: #003DCA }
		</style>
		<table align="center" id="Layer0" class="c0" cellspacing="2" cellpadding="2" border="0">
		<tbody>
		<tr>
		<td align="center">[menu_rows]</td>
		</tr>
		</tbody>
		</table>
		<table id="Layer1" class="c1" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
		<td><img src="cscmenu.jpg" alt="" border="0"></td>
		</tr>
		</tbody>
		</table>
		"}

		// Send them the page.
		src << browse(page, "window=CharacterMenu;titlebar=0;can_close=0;can_minimize=0;allow_transparency=true;size=400x398;focus=true;can_resize=0")

	DeleteCharacterMenu(list/menu)
		var/menu_rows = ""
		for (var/item in menu)
		//	menu_rows += {"<td align="center"><a href="?menu=deleting_character;choice=[item];src=\ref[src]"><img alt="" src="delete.jpg" border="0"></a></td>"}
			menu_rows += {"<tr><td align="center"><font size=5><a href="?menu=deleting_character;choice=[item];src=\ref[src]">\[[item]]</a></font></td></tr>"}
		var/page = {"
		<style type="text/css">
		 table.c1 {position:absolute; left:0px; top:0px; width:px; height:px; z-index:1}
		 table.c0 {position:absolute; left:144px; top:60px; width:px; height:px; z-index:2}
		</style>
		<style type="text/css">
		 body {
		  background-color: #206B24;
		  color: #10ca63;
		  position: absolute;
		  input: focus;
		  max-height: 400px;
		  max-width: 398px;
		  text-align: center;
		 }
		 :link { color: #10ca63 }
		 :visited { color: #003DCA }
		</style>
		<table align="center" id="Layer0" class="c0" cellspacing="2" cellpadding="2" border="0">
		<tbody>
		<tr>
		<td align="center">[menu_rows]</td>
		</tr>
		</tbody>
		</table>
		<table id="Layer1" class="c1" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
		<td><img src="dcmenu.jpg" alt="" border="0"></td>
		</tr>
		</tbody>
		</table>
		"}

		// Send them the page.
		src << browse(page, "window=CharacterMenu;titlebar=0;can_close=0;can_minimize=0;allow_transparency=true;size=400x398;focus=true;can_resize=0")

	/*QuitMenu(list/menu)
		var/menu_rows = ""
		for (var/item in menu)
			menu_rows += {"<td align="center"><a href="?menu=quit;choice=[item];src=\ref[src]"><img src="quit.jpg" border="0"></a></td>"}
		var/page = {"
		<style type="text/css">
		 table.c4 {position:absolute; left:115px; top:195px; width:px; height:px; z-index:1}
		 table.c1 {position:absolute; left:0px; top:0px; width:px; height:px; z-index:1}
		 table.c0 {position:absolute; left:115px; top:116px; width:px; height:px; z-index:2}
		</style>
		<style type="text/css">
		 body {
		  background-color: #206B24;
		  color: #325C9A;
		  position:absolute;
		  input:focus;
		  max-height:400px;
		  max-width:398px;
		 }
		 :link { color: #22be68 }
		 :visited { color: #003DCA }
		</style>
		<table align="center" id="Layer0" class="c0" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
		<td align="center"><a href="?menu=choosing_character;choice=;src=\ref[src]"><img src="choose.png" border="0">[menu_rows]</a></td>
		</tr>
		</tbody>
		</table>
		<table id="Layer1" class="c1" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
		<td><img src="chcmenu.jpg" alt="" border="0"></td>
		</tr>
		</tbody>
		</table>
		<table align="center" id="Layer4" class="c4" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
		<td align="center"><a href="?menu=quit;choice=;src=\ref[src]"><img src="quit.png" border="0">[menu_rows]</a></td>
		</tr>
		</tbody>
		"}

		// Send them the page.
		src << browse(page, "window=CharacterMenu;titlebar=0;can_close=0;can_minimize=0;allow_transparency=true;size=400x398;focus=true;can_resize=0")
*/

	Topic(href, href_list[])
		// This is called when the user clicks on a link from the HTML page.
		// We need to let the library know which choice was made.
		var/menu = href_list["menu"]
		switch(menu)
			if ("select_mode")
				// Close the menu window.
				src << browse(null, "window=ModeMenu")

				var/choice = href_list["choice"]
				SelectModeResult(choice)
				return
			if ("choosing_character")
				// Close the menu window.
				src << browse(null, "window=CharacterMenu")

				var/choice = href_list["choice"]
				ChooseCharacterResult(choice)
				return
			//if ("creating_character")
				// Close the menu window.
			//	src << browse(null, "window=CharacterMenu")
			//	CreateCharacter()
			//	return
			if ("deleting_character")
				// Close the menu window.
				src << browse(null, "window=CharacterMenu")

				var/choice = href_list["choice"]
				DeleteCharacterResult(choice)
				return

			/*if ("quit")
				// Close the menu window.
				src << browse(null, "window=CharacterMenu")
				QuitMenuResult()
				return*/

		// If we got this far, this didn't come from one of our links, so let superclass handle.
		return ..()



//mob/BaseCamp/FirstTimePlayer
//	FirstTimePlayer()
		/*
		 Handling first time players
		 ---------------------------
		 If you want to do something special the first time a player ever logs
		 into your game, you can do so by putting code in the FirstTimePlayer
		 class, FirstTimePlayer() proc. This is only the first time EVER that
		 they login...it is not called everytime they login.

		 You can use this to charge the player, or get their email address,
		 or give them special help or whatever.

		 If you don't want to use this, then don't do anything.  By default,
		 nothing will happen.  This is ONLY called the very first time a
		 player logs in, so it's not useful for things that check everytime
		 the player logs in.
		*/
//		return ..()//1



//#include "Soundmob.dm"
#include "Basics.dm"
mob/base_InitFromSavefile()
	//world << "Initfrom Save"
	var/mob/players/M
	M = src
	M.browse_once = 0

	//spawn() if(client && _autotune_soundmobs) for(var/soundmob/soundmob in _autotune_soundmobs) listenSoundmob(soundmob)
	//for(var/soundmob/soundmob in _autotune_soundmobs) //listenSoundmob(soundmob)
	//call(/soundmob/proc/broadcast)(src)
	//call(/soundmob/proc/setListener)(src)
	//_listening_soundmobs += src
		//call(/mob/players/proc/listenSoundmob)(soundmob)
	//call(/soundmob/proc/broadcast)(usr)
	/*
	 Initializing from savefile
	 --------------------------
	 Sometimes you have special checks you need to do or things you need
	 to add when a character is read in from the savefile.  If so,
	 you can do them in this mob function:

	 By default nothing happens.  This is just here in case you need it.
	*/
	//Login()
	//client.focus = client
	//call(/soundmob/Del)(src)
	//call(/mob/proc/unlistenSoundmob)(src)

	return


