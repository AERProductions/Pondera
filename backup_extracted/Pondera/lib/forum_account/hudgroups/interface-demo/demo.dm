
// This demo requires the Forum_account.Keyboard library, which can
// be downloaded here:
//
//   http://www.byond.com/developer/Forum_account/Keyboard
//

// this demo shows how to use the HUD-based interface
// controls defined in label.dm and option-group.dm.
mob
	var
		// the player's HUD has two buttons, an option group, and a label
		HudButton/ok_button
		HudButton/cancel_button
		HudOptionGroup/option_group
		HudLabel/label1

		HudInput/input1

	Login()
		loc = locate(10, 6, 1)

		src << "Click on an atom to update the label's caption."
		src << "Use the 'Toggle Option Mode' verb to change the radio buttons to checkboxes."

		// create a label with the text "label1" and a yellow background
		label1 = new(src, "label1", width = 48, background = "#fe6")

		// put the label in the top-left corner of the screen
		label1.pos(4,331)

		// create an on-screen text box.
		input1 = new(src)
		input1.pos(4, 180)

		// create "Ok" and "Cancel" buttons
		ok_button = new(src, "Ok")
		cancel_button = new(src, "Cancel")

		// position both buttons
		ok_button.pos(110, 4)
		cancel_button.pos(178, 4)

		// make the ok button call the player's ok() proc and the
		// cancel button call the cancel() proc.
		ok_button.action("ok")
		cancel_button.action("cancel")

		// the buttons have default colors and sizes, we can
		// change them if we want.
		cancel_button.background("#f55")

		// create an option group with three choices
		option_group = new(src)
		option_group.add_option("Option #1")
		option_group.add_option("Other Choice")
		option_group.add_option("Neither")

		option_group.pos(4, 4)

		world << label1.font.wrap_text("testing\nbugs", 15)

	verb
		Toggle_Option_Mode()

			// we can call the option group's mode() proc to change
			// between OPTION and CHECK modes. OPTION mode only lets
			// the user select one option, CHECK mode lets the user
			// select any combination of options.
			if(option_group.mode == option_group.CHECK)
				option_group.mode(option_group.OPTION)
			else
				option_group.mode(option_group.CHECK)

		// show the interface elements that get hidden when the cancel
		// button is clicked.
		Restore_Interface()
			option_group.show()
			ok_button.show()
			cancel_button.show()

	proc
		ok()
			// if the option group is a single-select:
			if(option_group.mode == option_group.OPTION)

				// option_group.value is the value of the option you have selected.
				if(option_group.value)
					src << "You have selected '[option_group.value]'."
				else
					src << "You didn't select anything."

			// otherwise, the option group is multi-select:
			else
				// option_group.selected is the list of values you have selected.
				if(option_group.selected.len)
					src << "You have selected:"
					for(var/v in option_group.selected)
						src << " * [v]"
				else
					src << "You didn't select anything."

			// show what you have typed in the HudInput object.
			src << "You typed '[input1.value]' in the text box."

		cancel()
			option_group.hide()
			ok_button.hide()
			cancel_button.hide()

			src << "Use the 'Restore Interface' verb to show the buttons and option group again."

atom
	Click()
		usr.label1.caption(name)

// the rest of this code is needed for the demo but doesn't
// relate to how you'd use the HUD library.
atom
	icon = 'hud-demo-icons.dmi'

turf
	icon_state = "grass"

	water
		density = 1
		icon_state = "water"

	trees
		density = 1
		icon_state = "trees"

	rock
		density = 1
		icon_state = "rock"

mob
	icon_state = "mob"
