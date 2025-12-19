
// the HudGroup object is defined by the library, we define a sub-type here
// that will use the base object's features to manage a menu for us.
ActionMenu
	parent_type = /HudGroup

	// all objects in this group will use this icon and layer
	icon = 'menu-demo.dmi'
	layer = MOB_LAYER + 5

	var
		mob/owner
		HudObject/cursor
		position = 1
		open = 0

	New(mob/m)
		..()

		// we keep track of the mob that owns the menu, because when
		// they select an action we need to call one of their procs
		owner = m

		// to make the menu icon I drew it in MS Paint and pasted it
		// into Dream Maker's icon editor, which chops it into 32x32
		// pieces, so we add a screen object for each piece of it
		for(var/x = 0 to 3)
			for(var/y = 0 to 3)
				add(x * 32, y * 32, "[x],[y]")

		// create a screen object for the cursor and keep a reference to it
		cursor = add(16, 16, "cursor")
		cursor.layer = layer + 2

	// these are the actions our menu can perform
	proc
		// set the cursor's position
		set_position(p)
			position = p

			// limit what values position can have
			if(position > 3) position = 3
			if(position < 1) position = 1

			// update the position of the cursor object
			cursor.pos(16, position * 37 - 16)

		// move the cursor up in the menu
		up()
			set_position(position + 1)

		// move the cursor down in the menu
		down()
			set_position(position - 1)

		// select an action and execute it
		select()
			if(position == 1)
				owner.examine()
			else if(position == 2)
				owner.attackt()
			else if(position == 3)
				owner.speak()

			close()

		// open the menu
		open()
			set_position(1)
			open = 1
			show()

		// close the menu
		close()
			open = 0
			hide()

mob
	var
		// each player has an action menu
		ActionMenu/action_menu

	Login()
		..()

		src << "Press 5 on the numpad to open the menu."
		src << "Use the arrow keys to move the cursor, then press 5 again to select an action."
		src << "Press 7 on the numpad to close the menu."

		// create an action menu for this mob
		action_menu = new(src)

		// position the menu 16 pixels over and 208 pixels up
		// from the bottom left corner of the screen.
		action_menu.pos(16, 208)

		// we want it to be hidden initially
		action_menu.hide()

	// these procs are called by the action menu
	proc
		examine()
			src << "\blue You examine your surroundings."

		attackt()
			src << "\red You attack!"

		speak()
			src << "\blue You speak, but nobody is there to listen :-("

// we also have to override these procs to make them call actions
// within the menu if the menu is open.
client
	Center()
		// if the menu is open, select the action
		if(mob.action_menu.open)
			mob.action_menu.select()

		// if the menu is closed, open it
		else
			mob.action_menu.open()

	Northwest()
		// if the menu is open, close it
		if(mob.action_menu.open)
			mob.action_menu.close()

	North()
		// if the menu is open, it handles the action
		if(mob.action_menu.open)
			mob.action_menu.up()

		// otherwise we run the default action
		else
			..()

	South()
		// if the menu is open, it handles the action
		if(mob.action_menu.open)
			mob.action_menu.down()

		// otherwise we run the default action
		else
			..()

	// we override East() and West() to make them do
	// nothing while the menu is open.
	East()
		if(!mob.action_menu.open)
			..()

	West()
		if(!mob.action_menu.open)
			..()

// the rest of this code is needed for the demo but doesn't
// relate to how you'd use the HUD library.
atom
	icon = 'hud-demo-icons.dmi'

turf
	icon_state = "grass"

	water
		density = 1
		icon_state = "water"

mob
	icon_state = "mob"
