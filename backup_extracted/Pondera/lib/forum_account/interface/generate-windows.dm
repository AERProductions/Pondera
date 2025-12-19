
// File:    generate-windows.dm
// Library: Forum_account.Interface
// Author:  Forum_account
//
// Contents:
//   Contains code to generate a /Window object definition
//   from a .dmf file. It reads the .dmf file and creates a
//   datum definition where the datum has members for each
//   control defined in the .dmf file. You don't have to do
//   this, but it can simplify your code, especially if you
//   have a static interface (i.e. you don't create a lot of
//   controls at runtime).

proc
	// takes only alphanumeric characters and underscores.
	control_name(n)
		n = replace(n, "-", "_")

		. = ""
		for(var/i = 1 to length(n))
			var/asc = text2ascii(n,i)

			//       a-z range                     A-Z range                  0-9 range               underscore
			if((asc >= 97 && asc <= 122) || (asc >= 65 && asc <=  90) || (asc >= 48 && asc <=  57) || (asc == 95))
				. += copytext(n,i,i+1)

	generate_window_code(filename)
		var/contents = file2text(filename)
		var/list/lines = split(contents, "\n")

		var/window_id = ""
		var/control_id = ""
		var/list/controls = list()

		for(var/i = 1 to lines.len)
			var/line = lines[i]

			// We want to look for a line that looks like: window "window_name"
			if(length(line) > 8 && copytext(line, 1, 7) == "window")
				if(window_id)
					print_window_code(window_id, controls)

				controls = list()
				window_id = copytext(line, 9, length(line))

			// Once we're inside a window we want to get the id and type of each control
			else if(length(line) > 8 && copytext(line, 1, 6) == "\telem")
				control_id = copytext(line, 8, length(line))

			else if(length(line) > 8 && copytext(line, 1, 7) == "\t\ttype")
				var/type = copytext(line, 10)

				if(type != "MAIN")
					controls[control_id] = format_name(type)

		print_window_code(window_id, controls)

	print_window_code(window_id, controls)
		world << "Window/[control_name(window_id)]"
		world << "\tvar"
		for(var/ctl in controls)
			world << "\t\t[controls[ctl]]/[control_name(ctl)]"

		world << "\tNew(mob/m)"
		world << "\t\tcontrol_id = \"[window_id]\""
		world << "\t\towner = m"
		for(var/ctl in controls)
			world << "\t\t[control_name(ctl)] = new(\"[ctl]\",\"[window_id]\",m)"