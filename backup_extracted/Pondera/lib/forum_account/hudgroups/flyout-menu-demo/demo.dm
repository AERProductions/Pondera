
// This demo uses two types of hud groups to create a flyout menu. The first
// object, /FlyoutMenu, is the top level which contains a row of buttons. Clicking
// on a button expands out the sub menu.
FlyoutMenu
	parent_type = /HudGroup

	// all objects in this group will use this icon and layer
	icon = 'flyout-demo-icons.dmi'
	layer = MOB_LAYER + 5

	var
		list/buttons = list()
		list/menus = list()

	New(mob/m)
		..()

		// create four buttons and sub-menus
		for(var/i = 1 to 4)

			// position the menu buttons so they're in a row horizontally
			var/px = i * 32 - 32

			// create the button
			// we use the value parameter to store the index of the button,
			// which we use later (when the button is clicked).
			buttons += add(px, 0, "button-[i]", value = i)

			// create the sub-menu
			var/FlyoutSubMenu/f = new(m, i)

			// position the menu and hide it initially
			f.pos(px, 32)
			f.hide()

			menus += f

	// this click proc is called when an object within this group was clicked on
	Click(HudObject/object)

		// identify the menu you clicked on - we do this by using the value of
		// the object. when we created the objects in this group we set their
		// value to be the index of the menu.
		var/FlyoutSubMenu/menu = menus[object.value]

		for(var/FlyoutSubMenu/f in menus)
			// toggle the menu you clicked on
			if(f == menu)
				f.toggle()

			// and close all other menus
			else
				f.hide()

// the sub-menu object contains a list of buttons in a vertical row.
FlyoutSubMenu
	parent_type = /HudGroup

	icon = 'flyout-demo-icons.dmi'
	layer = MOB_LAYER + 5

	New(mob/m, number)
		..(m)

		// create a random number of items in the menu
		for(var/i = 1 to rand(1, 1))

			// make them appear in a row vertically
			var/py = i * 32 - 32

			// again we use the value parameter to store the index of
			// the item within the menu.
			add(0, py, "menu-[number]", value = i)

	Click(HudObject/object)
		// we don't really use object.value here, but you could use it in
		// a game to store a reference to an item or special ability.
		world << "You selected item #[object.value] in [object.icon_state]."

		// hide the menu once a selection is made
		hide()

mob
	var
		// each player has an action menu
		FlyoutMenu/flyout_menu

	Login()
		..()

		src << "Click on a button to show the sub-menu, then click on an option within the sub-menu to select it."

		// create a flyout menu for this mob
		flyout_menu = new(src)

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