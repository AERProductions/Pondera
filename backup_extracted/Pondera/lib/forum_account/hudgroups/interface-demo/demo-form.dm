
mob
	var
		GameForm/game_form

	proc
		// create a game form and show it
		game_form()
			if(!game_form)
				game_form = new(src)

			game_form.show()

// we define custom button types so we can control what
// each one's Click() proc does.
SubmitButton
	parent_type = /HudButton

	Click()
		if(usr.game_form)
			usr.game_form.submit()

CancelButton
	parent_type = /HudButton

	Click()
		if(usr.game_form)
			usr.game_form.hide()

// The game form contains:
//
//  * a text box to type a name in
//  * a label telling you what the text box is for
//  * a list of levels
//  * a submit button
//  * a cancel button
//  * a plain gray background
//
GameForm
	parent_type = /HudGroup

	icon = 'demo-form-icons.dmi'
	layer = MOB_LAYER + 50

	var
		SubmitButton/submit_button
		CancelButton/cancel_button
		HudOptionGroup/level_select
		HudInput/name_input
		HudLabel/name_label
		HudLabel/job_label

	New(mob/m)
		..()

		// create the form's background
		for(var/x = 0 to 7)
			for(var/y = 0 to 5)
				var/px = x * 32 + 48
				var/py = y * 32 + 40
				add(px, py, icon_state = "[x],[y]")

		// create the controls
		submit_button = new(m, caption = "Submit", layer = layer + 1)
		submit_button.pos(110, 44)

		cancel_button = new(m, caption = "Cancel", layer = layer + 1)
		cancel_button.pos(178, 44)

		name_input = new(m, width = 128, layer = layer + 1)
		name_input.pos(150, 200)
		name_input.value("Type name here")

		name_label = new(m, "Name", width = 30, layer = layer + 1)
		name_label.pos(116, 202)

		job_label = new(m, "Select Job", width = 100, layer = layer + 1)
		job_label.pos(116, 182)

		level_select = new(m, layer = layer + 1)
		level_select.pos(100, 118)

		level_select.add_option("Worker")
		level_select.add_option("Fighter")
		level_select.add_option("Hunter")
		level_select.add_option("Renegade")
		//level_select.add_option("Level 5 - Phobos Lab")
		//level_select.add_option("Level 6 - Central Processing")
		//level_select.add_option("Level 7 - Computer Station")

	show()
		..()
		submit_button.show()
		cancel_button.show()
		name_input.show()
		name_label.show()
		job_label.show()
		level_select.show()

	hide()
		submit_button.hide()
		cancel_button.hide()
		name_input.hide()
		name_label.hide()
		job_label.hide()
		level_select.hide()
		..()

	proc
		submit()
			//world << "Creating new game:"
			//world << "name = [name_input.value]"
			//world << "map = [level_select.value]"

			hide()
