
// File:    icon-generator.dm
// Library: Forum_account.DynamicLighting
// Author:  Forum_account
//
// Contents:
//   This file contains the code used to generate the icon file
//   used to show darkness. You can use the sample icon file that
//   comes with the library or generate your own. To generate
//   your own:
//
//     1. Include this file in the project (click the check box
//        next to this file on the left side of the DM window).
//     2. Change the lighting options (the global vars defined in
//        this file).
//     3. Compile and run the project.
//     4. Use the "Generate Icon" verb.
//     5. Save the resulting .dmi file in your project and update
//        your code to reference it.

var
	icon_width = 32
	icon_height = 32

	// darkest and lightest are alpha values, a lower alpha value
	// means a more transparent icon which means the underlying icon
	// will appear brighter.
	darkest = 255
	lightest = 0

	// the number of illumination values to use, the number of icon
	// states in the icon file depends on this value:
	//
	//   states = 3: 81 icon states
	//   states = 4: 256 icon states
	//   states = 5: 625 icon states
	//   states = 6: 1296 icon states
	//
	// having more states will make it look nicer, but can result in
	// huge icon files.
	states = 8

	// you can change these vars to tint the shadows, by default
	// they're black but you might want them to be other colors
	red = 0
	green = 0
	blue = 0

proc
	generate_icon()

		var/icon/master = new()

		var/total = states * states * states
		var/count = 0

		for(var/a = 1 to states)
			for(var/b = 1 to states)
				for(var/c = 1 to states)
					for(var/d = 1 to states)
						var/icon/I = generate_state(a, b, c, d)

						master.Insert(I, "[a-1][b-1][c-1][d-1]")

					count += 1
					var/pct = round(100 * count / total)
					world << "[pct]%"

					sleep(world.tick_lag)

		world << ftp(master, "lighting.dmi")

	generate_state(a, b, c, d)

		var/icon/I = icon('dynamic-lighting-library.dmi', "blank")
		I.Scale(icon_width, icon_height)

		var/a_val = value(a)
		var/b_val = value(b)
		var/c_val = value(c)
		var/d_val = value(d)

		for(var/x = 1 to icon_width)
			for(var/y = 1 to icon_height)

				// c -- b
				// |    |
				// b -- a

				var/i = (x - 1) / (icon_width - 1)
				var/j = (y - 1) / (icon_height - 1)

				var/a_wgt = (    i) * (1 - j)
				var/b_wgt = (1 - i) * (1 - j)
				var/c_wgt = (1 - i) * (    j)
				var/d_wgt = (    i) * (    j)

				var/alpha = round(a_val * a_wgt + b_val * b_wgt + c_val * c_wgt + d_val * d_wgt)

				I.DrawBox(rgb(red, green, blue, alpha), x, y)

		return I

	value(state)
		return darkest - (darkest - lightest) * ((state - 1) / (states - 1))

mob
	verb
		Generate_Icon()
			generate_icon()