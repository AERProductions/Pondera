
#define DEBUG

// File:    _reference.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   This file contains the code to generate DM reference pages
//   for the library. Doing this will let you get help on library
//   topics (vars, procs, etc.) by pressing F1, just like how you
//   get help on DM's built-in features.
//
//   To generate the reference pages, follow these steps:
//
//     1. Include _reference.dm in the project (check the box next to it in the file list)
//     2. Compile and run the library
//     3. Click the "generate reference pages" verb.
//     4. Click "Yes" to allow file access (you may be prompted multiple times).
//     5. Wait until you see the "Complete!" message printed to the message log
//     6. Restart Dream Maker.
//
//   Note: If you didn't install BYOND to the c:\program files\byond\ folder
//   you'll have to change the value of the BYOND_DIR variable to point to the
//   folder where BYOND is installed.
//
//   After doing this, press F1 and search for "PixelMovement" in
//   the "topic" tab. This is the main reference page for the library
//   and contains links to all vars and procs defined by the library.
//
//   To remove the reference pages and restore your DM reference to
//   its original state, follow these steps:
//
//     1. Include _reference.dm in the project.
//     2. Compile and run the library.
//     3. Click the "remove reference pages" verb.
//     4. Click "Yes" to allow file access (you may be prompted multiple times).
//     5. Wait until you see the "Complete!" message printed to the message log
//     6. Restart Dream Maker.

var
	const
		BYOND_DIR = "c:\\program files\\byond\\"

mob
	verb
		generate_reference_pages()
			world.generate_reference()

		remove_reference_pages()
			world.restore_reference()

var
	list/reference_pages = list()
	list/library_pages = list()

REF
	var
		name = ""
		title = ""
		hub_entry
		list/see_also
		description
		example
		library
		default_value
		list/possible_values
		format
		when
		args
		returns
		default_action

	proc
		html()
			var/html = ""

			if(name)
				html += "\n\n<a name=[name]>\n"

			if(title)
				if(library)
					html += "<h2>[title] \[library]</h2>\n\n"
				else
					html += "<h2>[title]</h2>\n\n"

			if(hub_entry)
				html += "<dl><dt><b>Hub Entry:</b>\n"
				html += "<dd><a href=\"[hub_entry]\">[hub_entry]</a>\n"
				html += "</dl>\n\n"

			if(library)
				var/pos = findtext(library, "/", 2)
				var/author = copytext(library, 2, pos)
				var/lib_name = copytext(library, pos + 1)

				html += "<dl><dt><b>Library:</b>\n"
				html += "<dd>This page is part of the <a href=#/[author]/[lib_name]>[author].[lib_name]</a> library."
				html += "</dl>\n\n"

			if(see_also)
				html += "<dl><dt><b>See also:</b>\n"
				for(var/p in see_also)
					var/REF/r = reference_pages[p]
					if(istype(r))
						html += "<dd><a href=#[p]>[r.title]</a>\n"
					else if(r)
						html += "<dd><a href=#[p]>[r]</a>\n"
					else
						world << "\red Couldn't find reference page \"[p]\"."
				html += "</dl>\n\n"

			if(default_value)
				html += "<dl><dt><b>Default value:</b>\n"
				html += "<dd>[default_value]\n"
				html += "</dl>\n\n"

			if(possible_values)
				html += "<dl><dt><b>Possible values:</b>\n<dd><ul>\n"
				for(var/p in possible_values)
					html += "<li>[p]\n"
				html += "</ul>\n</dl>\n\n"

			if(format)
				html += "<dl><dt><b>Format:</b>\n"
				html += "<dd>[format]\n"
				html += "</dl>\n\n"

			if(returns)
				html += "<dl><dt><b>Returns:</b>\n"
				html += "<dd>[returns]\n"
				html += "</dl>\n\n"

			if(when)
				html += "<dl><dt><b>When:</b>\n"
				html += "<dd>[when]\n"
				html += "</dl>\n\n"

			if(src.args)
				html += "<dl><dt><b>Args:</b>\n"
				if(istype(src.args, /list))
					for(var/a in src.args)
						html += "<dd>[a]\n"
				else
					html += "<dd>[src.args]\n"
				html += "</dl>\n\n"

			if(default_action)
				html += "<dl><dt><b>Default action:</b>\n"
				html += "<dd>[default_action]\n"
				html += "</dl>\n\n"

			if(description)
				html += "[description]\n\n"

			if(example)
				html += "<h3>Example:</h3>\n"
				html += "[example]\n\n"

			if(name in library_pages)
				html += "<dl><dt><b>Contents:</b>\n"

				var/list/lib_pages = library_pages[name]
				for(var/p in lib_pages)
					var/REF/r = reference_pages[p]
					html += "<dd><a href=#[p]>[r.title]</a>\n"

				html += "</dl>\n\n"

			return html

world
	proc
		parse_reference()

			var/reference_path = "[BYOND_DIR]help\\ref\\"

			if(!fexists("[reference_path]info.html"))
				CRASH("Cannot locate the DM reference at [reference_path]")

			var/list/pages = list()

			var/ref = file2text("[reference_path]info.html")

			var/pos = findtext(ref, "<a name=")

			while(pos > 0)

				var/end = findtext(ref, ">", pos)
				var/name = copytext(ref, pos + 8, end)

				var/title_start = findtext(ref, "<h2>", pos)
				var/title_end = findtext(ref, "</h2>", pos)
				var/title = copytext(ref, title_start + 4, title_end)

				pages[name] = title

				pos = findtext(ref, "<a name=", pos + 1)

			world << "[pages.len] pages found."

			return pages

		restore_reference()

			var/reference_path = "[BYOND_DIR]help\\ref\\"

			world << "Restoring the DM reference (info.html)..."
			if(!fexists("[reference_path]original-info.html"))
				world << "\red Error: Cannot locate original-info.html at \"[reference_path]\""
				return

			if(fexists("[reference_path]info.html"))
				fdel("[reference_path]info.html")

			fcopy("[reference_path]original-info.html","[reference_path]info.html")
			world << "Complete!"

		// This proc does a lot of work. Here's the general outline:
		//
		//   1. Identify all /REF datums and make sure they're valid.
		//   2. Make sure info.html can be located.
		//   3. If a /REF datum will overwrite a current reference page, remove the current page.
		//   4. Add the new reference pages.
		//
		// If a single step fails to complete the entire process is
		// aborted and no changes are made to info.html.
		generate_reference(verbose = 0)

			var/reference_path = "[BYOND_DIR]help\\ref\\"
			world << "Generating DM reference pages..."

			var/error = 0
			reference_pages = list()

			// first we validate the /REF objects, each one must have
			// a name and title
			for(var/t in typesof(/REF))
				var/REF/r = new t()

				// If the reference entry doesn't have a name, skip it. This
				// is allowed because some types of /REF won't represent
				// reference pages (ex: the base type /REF).
				if(!r.name) continue

				// each entry must have a title
				if(!r.title)
					world << "\red Error: Missing title for [r.name]"
					error = 1
					continue

				if(verbose)
					world << "Page: name = \"[r.name]\", title = \"[r.title]\""

				// if we've already seen an entry of the same name, report
				// the event then skip the entry
				if(r.name in reference_pages)
					world << "\red Error: Duplicate page name \"[r.name]\""
					error = 1
					continue

				reference_pages[r.name] = r

			// get the list of pages currently in the reference
			var/list/current_pages = parse_reference()

			for(var/p in current_pages)
				if(!(p in reference_pages))
					reference_pages[p] = current_pages[p]

			// the "see also" references must point to valid pages
			for(var/p in reference_pages)
				var/REF/r = reference_pages[p]

				if(!istype(r))
					continue

				if(r.library)
					if(!(r.library in reference_pages))
						world << "\red Error: Invalid \"library\" reference to \"[r.library]\" for entry \"[r.name]\", \"[r.library]\" does not exist."
						error = 1
					else
						if(r.library in library_pages)
							var/list/L = library_pages[r.library]
							L += r.name
						else
							library_pages[r.library] = list()
							var/list/L = library_pages[r.library]
							L += r.name

				if(r.see_also)
					for(var/page_name in r.see_also)
						// if it points to a new reference page, it's valid
						if(page_name in reference_pages) continue

						// if it points to a current reference page, it's valid
						if(page_name in current_pages) continue

						// if it doesn't point to either, it's invalid
						world << "\red Error: Invalid \"see also\" reference to \"[page_name]\" for entry \"[r.name]\", \"[page_name]\" does not exist."
						error = 1

			if(error)
				world << "The reference pages could not be generated. info.html will not be written."
				return

			// if we can't find the reference we can't do anything
			if(!fexists("[reference_path]info.html"))
				world << "\red Error: Cannot locate the DM reference at [reference_path]"
				world << "\red Change the global constant <tt>BYOND_DIR</tt> in _reference.dm to point to the correct folder."
				error = 1
				return

			// if we've gotten this far we were able to locate the reference
			// if no backup exists, create one
			if(!fexists("[reference_path]original-info.html"))
				fcopy("[reference_path]info.html","[reference_path]original-info.html")

			// generate the HTML for the new reference pages
			var/html = ""

			for(var/p in reference_pages)
				var/REF/r = reference_pages[p]
				if(!istype(r)) continue

				html += "[r.html()]<hr>"

			// ref is the text contents of the current DM reference
			var/ref = file2text("[reference_path]info.html")

			// remove pages from the reference that will be overwritten.
			var/ignore_overwrite_messages = 0

			if(!verbose)
				ignore_overwrite_messages = 1

			for(var/p in reference_pages)
				// if reference_pages[p] is not an instance of /REF, that
				// means this is an original reference page and it's only
				// in the list so we can look up it's title based on its
				// URL.
				var/REF/r = reference_pages[p]
				if(!istype(r)) continue

				var/first = 1

				if(p in current_pages)
					while(1)
						var/start = findtext(ref, "<a name=[p]")
						if(start < 1) break

						var/end = findtext(ref, "<hr>", start)

						if(!ignore_overwrite_messages)
							if(alert(usr, "The following page will be overwritten:\n\n" + copytext(ref, start, end), "Overwrite [p]", "Ok", "Skip These Warnings") == "Skip These Warnings")
								ignore_overwrite_messages = 1

						if(first)
							if(verbose)
								world << "Overwriting [p]"
						ref = copytext(ref, 1, start) + copytext(ref, end + 4)

						first = 0

			// remove the ending </body> and </html>
			ref = copytext(ref, 1, length(ref) - 16)

			// append the new HTML
			ref += html
			ref += "\n\n</body>\n</html>\n"

			fdel("[reference_path]info.html")
			text2file(ref, "[reference_path]info.html")

			world << "Complete!"

REF/atom_var/flags
	name = "/atom/var/flags"
	library = "/Forum_account/PixelMovement"
	title = "flags var (atom)"
	see_also = list("/atom/var/flags_bottom","/atom/var/flags_ground","/atom/var/flags_left","/atom/var/flags_right","/atom/var/flags_top")
	description = "This value gets ORed with the mob's directional flags (on_ground, on_left, etc.) in the mob's set_flags proc. You can use the flags var to specify atom properties, then you can check individual bits of on_ground to see what properties the ground below the mob has."
	default_value = "0"

REF/atom_var/flags_bottom
	name = "/atom/var/flags_bottom"
	library = "/Forum_account/PixelMovement"
	title = "flags_bottom var (atom)"
	see_also = list("/atom/var/flags","/atom/var/flags_ground","/atom/var/flags_left","/atom/var/flags_right","/atom/var/flags_top","/mob/var/on_top")
	description = "This value gets ORed with the mob's on_top var when the mob is touching the bottom of the atom."
	default_value = "0"

REF/atom_var/flags_ground
	name = "/atom/var/flags_ground"
	library = "/Forum_account/PixelMovement"
	title = "flags_ground var (atom)"
	see_also = list("/atom/var/flags","/atom/var/flags_bottom","/atom/var/flags_left","/atom/var/flags_right","/atom/var/flags_top","/mob/var/on_ground")
	description = "This value gets ORed with the mob's on_ground var when the mob is standing on top of the atom."
	default_value = "0"

REF/atom_var/flags_left
	name = "/atom/var/flags_left"
	library = "/Forum_account/PixelMovement"
	title = "flags_left var (atom)"
	see_also = list("/atom/var/flags","/atom/var/flags_bottom","/atom/var/flags_ground","/atom/var/flags_right","/atom/var/flags_top","/mob/var/on_right")
	description = "This value gets ORed with the mob's on_right var when the mob is touching the left side of the atom."
	default_value = "0"

REF/atom_var/flags_right
	name = "/atom/var/flags_right"
	library = "/Forum_account/PixelMovement"
	title = "flags_right var (atom)"
	see_also = list("/atom/var/flags","/atom/var/flags_bottom","/atom/var/flags_ground","/atom/var/flags_left","/atom/var/flags_top","/mob/var/on_left")
	description = "This value gets ORed with the mob's on_left var when the mob is touching the right side of the atom."
	default_value = "0"

REF/atom_var/flags_top
	name = "/atom/var/flags_top"
	library = "/Forum_account/PixelMovement"
	title = "flags_top var (atom)"
	see_also = list("/atom/var/flags","/atom/var/flags_bottom","/atom/var/flags_ground","/atom/var/flags_left","/atom/var/flags_right","/mob/var/on_top")
	description = "This value gets ORed with the mob's on_bottom var when the mob is touching the top of the atom."
	default_value = "0"


REF/atom_var/pwidth
	name = "/atom/var/pwidth"
	library = "/Forum_account/PixelMovement"
	title = "pwidth var (atom)"
	see_also = list("/atom/var/pheight","/atom/var/pdepth","/atom/var/px","/atom/var/py","/atom/var/pz")
	description = "This variable determines the size of the atom's bounding box in the x direction."
	default_value = "32"

REF/atom_var/pheight
	name = "/atom/var/pheight"
	library = "/Forum_account/PixelMovement"
	title = "pheight var (atom)"
	see_also = list("/atom/var/pwidth","/atom/var/pdepth","/atom/var/px","/atom/var/py","/atom/var/pz")
	description = "This variable determines the size of the atom's bounding box in the y direction."
	default_value = "32"

REF/atom_var/pdepth
	name = "/atom/var/pdepth"
	library = "/Forum_account/PixelMovement"
	title = "pdepth var (atom)"
	see_also = list("/atom/var/pwidth","/atom/var/pheight","/atom/var/px","/atom/var/py","/atom/var/pz")
	description = "This variable determines the size of the atom's bounding box in the z direction."
	default_value = "0 for non-dense atoms, 32 for dense atoms"


REF/atom_var/px
	name = "/atom/var/px"
	library = "/Forum_account/PixelMovement"
	title = "px var (atom)"
	see_also = list("/atom/var/py","/atom/var/pz","/atom/var/pwidth","/atom/var/pheight","/atom/var/pdepth")
	description = "This variable determines the position of the atom's bounding box in the x direction."
	default_value = "32 * x"

REF/atom_var/py
	name = "/atom/var/py"
	library = "/Forum_account/PixelMovement"
	title = "py var (atom)"
	see_also = list("/atom/var/px","/atom/var/pz","/atom/var/pwidth","/atom/var/pheight","/atom/var/pdepth")
	description = "This variable determines the position of the atom's bounding box in the y direction."
	default_value = "32 * y"

REF/atom_var/pz
	name = "/atom/var/pz"
	library = "/Forum_account/PixelMovement"
	title = "pz var (atom)"
	see_also = list("/atom/var/px","/atom/var/py","/atom/var/pwidth","/atom/var/pheight","/atom/var/pdepth")
	description = "This variable determines the position of the atom's bounding box in the z direction."
	default_value = "0"


REF/atom_var/ramp
	name = "/atom/var/ramp"
	library = "/Forum_account/PixelMovement"
	title = "ramp var (atom)"
	see_also = list("/atom/var/ramp_dir")
	description = "Determines the change in height across the atom."
	default_value = "0"

REF/atom_var/ramp_dir
	name = "/atom/var/ramp_dir"
	library = "/Forum_account/PixelMovement"
	title = "ramp_dir var (atom)"
	see_also = list("/atom/var/ramp")
	description = "Determines the direction of the ramp. If ramp_dir is set to EAST and ramp is set to 8, the atom will be 8 pixels taller on its right side than on its left."
	possible_values = list("NORTH","SOUTH","EAST","WEST","0")
	default_value = "0"

REF/atom_proc/below
	name = "/atom/proc/below"
	library = "/Forum_account/PixelMovement"
	title = "below proc (atom)"
	see_also = list("/atom/proc/front","/atom/proc/bottom","/atom/proc/left","/atom/proc/right","/atom/proc/top")
	description = "Returns a list of atoms within d pixels of the atom's bottom (in the z direction)."
	format = "below(d)"
	args = "d: A distance in pixels."
	returns = "A list of atoms."

REF/atom_proc/front
	name = "/atom/proc/front"
	library = "/Forum_account/PixelMovement"
	title = "front proc (atom)"
	see_also = list("/atom/proc/below","/atom/proc/bottom","/atom/proc/left","/atom/proc/right","/atom/proc/top")
	description = "Calls left(d), right(d), top(d), or bottom(d) based on src's direction."
	format = "front(d)"
	args = "d: A distance in pixels."
	returns = "A list of atoms."

REF/atom_proc/bottom
	name = "/atom/proc/bottom"
	library = "/Forum_account/PixelMovement"
	title = "bottom proc (atom)"
	see_also = list("/atom/proc/below","/atom/proc/front","/atom/proc/left","/atom/proc/right","/atom/proc/top")
	description = "Returns a list of atoms within d pixels of src's bottom side (in the y direction)."
	format = "bottom(d)"
	args = "d: A distance in pixels."
	returns = "A list of atoms."

REF/atom_proc/left
	name = "/atom/proc/left"
	library = "/Forum_account/PixelMovement"
	title = "left proc (atom)"
	see_also = list("/atom/proc/below","/atom/proc/front","/atom/proc/bottom","/atom/proc/right","/atom/proc/top")
	description = "Returns a list of atoms within d pixels of src's left side."
	format = "left(d)"
	args = "d: A distance in pixels."
	returns = "A list of atoms."

REF/atom_proc/right
	name = "/atom/proc/right"
	library = "/Forum_account/PixelMovement"
	title = "right proc (atom)"
	see_also = list("/atom/proc/below","/atom/proc/front","/atom/proc/bottom","/atom/proc/right","/atom/proc/top")
	description = "Returns a list of atoms within d pixels of src's right side."
	format = "right(d)"
	args = "d: A distance in pixels."
	returns = "A list of atoms."

REF/atom_proc/top
	name = "/atom/proc/top"
	library = "/Forum_account/PixelMovement"
	title = "top proc (atom)"
	see_also = list("/atom/proc/below","/atom/proc/front","/atom/proc/bottom","/atom/proc/left","/atom/proc/right")
	description = "Returns a list of atoms within d pixels of src's top side (in the y direction)."
	format = "top(d)"
	args = "d: A distance in pixels."
	returns = "A list of atoms."

REF/atom_proc/height
	name = "/atom/proc/height"
	library = "/Forum_account/PixelMovement"
	title = "height proc (atom)"
	see_also = list("/atom/var/ramp","/atom/var/ramp_dir","/atom/var/pdepth","/atom/var/pz")
	description = "Returns the z value (in pixels) of the top of the atom that's nearest to the specified bounding box (the 6 parameters define this box). This is used to find the highest point of a ramp below a mob."
	format = "height(qx, qy, qz, qw, qh, qd)"
	args = list("qx: The x coordinate of the bounding box", "qy: The y coordinate of the bounding box", "qz: The z coordinate of the bounding box", "qw: The width of the bounding box", "qh: The height of the bounding box", "qd: The depth of the bounding box")
	returns = "A measurement in pixels"

REF/atom_proc/inside
	name = "/atom/proc/inside"
	library = "/Forum_account/PixelMovement"
	title = "inside proc (atom)"
	see_also = list("/atom/proc/front","/atom/proc/over")
	description = "For the first format, it returns a list of atoms inside src. For the second format it returns 1 if a is inside src and 0 otherwise. For the third format it returns 1 if src is in the bounding box defined by the parameters and 0 otherwise."
	format = "inside()<dd>inside(atom/a)<dd>inside(qx, qy, qw, qh, qz, qd)"
	args = list("a: an arbitrary atom", "qx: The x coordinate of the bounding box", "qy: The y coordinate of the bounding box", "qz: The z coordinate of the bounding box", "qw: The width of the bounding box", "qh: The height of the bounding box", "qd: The depth of the bounding box")
	returns = "Depends on the format."

REF/atom_proc/nearby
	name = "/atom/proc/nearby"
	library = "/Forum_account/PixelMovement"
	title = "nearby proc (atom)"
	see_also = list("/atom/proc/inside")
	description = "Returns a list of atoms near the atom. The atoms on the same tile are listed first, the atoms in tiles in cardinal directions (up, down, left, right) are listed next, the atoms in tiles in diagonal directions are listed last. This proc is basically an alternative to oview() that's used because in pixel_move, the order matters."
	format = "nearby()"
	returns = "A list of atoms."

REF/atom_proc/over
	name = "/atom/proc/over"
	library = "/Forum_account/PixelMovement"
	title = "over proc (atom)"
	see_also = list("/atom/proc/inside")
	description = "Returns 1 if the bounding box defined by the 4 parameters is over top of the specified atom. Returns 0 otherwise."
	format = "over(qx, qy, qw, qh)"
	args = list("qx: The x coordinate of the bounding box", "qy: The y coordinate of the bounding box", "qw: The width of the bounding box", "qh: The height of the bounding box")
	returns = "0 or 1."


REF/atom_proc/stepped_off
	name = "/atom/proc/stepped_off"
	library = "/Forum_account/PixelMovement"
	title = "stepped_off proc (atom)"
	see_also = list("/atom/proc/stepped_on","/atom/proc/stepping_on")
	description = "This is called when a mob was standing on an atom in the previous tick, but is no longer standing on the atom in the current tick."
	format = "stepped_off(mob/m)"
	args = list("m: The mob that just stepped off the atom")
	returns = "Nothing"

REF/atom_proc/stepped_on
	name = "/atom/proc/stepped_on"
	library = "/Forum_account/PixelMovement"
	title = "stepped_on proc (atom)"
	see_also = list("/atom/proc/stepped_off","/atom/proc/stepping_on")
	description = "This is called when a mob was not standing on an atom in the previous tick, but is now standing on the atom in the current tick. To be standing on an atom the mob must be able to bump the atom and its top must be touching your bottom.</p><p>This is called when an object is standing on the atom. src is the atom being stepped on. This is defined for all atoms but generally used for turfs."
	format = "stepped_on(mob/m)"
	args = list("m: The mob that just stepped on the atom")
	returns = "Nothing"

REF/atom_proc/stepping_on
	name = "/atom/proc/stepping_on"
	library = "/Forum_account/PixelMovement"
	title = "stepping_on proc (atom)"
	see_also = list("/atom/proc/stepped_off","/atom/proc/stepped_on")
	description = "This is called every tick for as long as the mob is standing on the atom. The second argument, t, is the number of consecutive ticks that the mob has spent standing on the atom."
	format = "stepping_on(mob/m, t)"
	args = list("m: The mob that just stepped off the atom", "t: the number of consecutive ticks the mob has spent standing on the atom.")
	returns = "Nothing"


REF/mob_var/base_state
	name = "/mob/var/base_state"
	library = "/Forum_account/PixelMovement"
	title = "base_state var (mob)"
	see_also = list("/mob/proc/set_state")
	description = "The prefix of all mob icon states. If a base state is specified, icon states will have the form \[base state]-\[action_state]-\[dir_state], otherwise they will just be \[action_state]-\[dir_state]."
	default_value = "empty string"

REF/mob_var/camera
	name = "/mob/var/camera"
	library = "/Forum_account/PixelMovement"
	title = "camera var (mob)"
	see_also = list("/Camera")
	description = "This is an instance of the /Camera object which is used to control all aspects of the mob's camera. See the /Camera object documentation to see what properties the camera has."

REF/mob_var/fall_speed
	name = "/mob/var/fall_speed"
	library = "/Forum_account/PixelMovement"
	title = "fall_speed var (mob)"
	see_also = list("/mob/var/move_speed")
	description = "This is the maximum speed the mob can fall at (in pixels per tick)."
	default_value = "20"

REF/mob_var/jumped
	name = "/mob/var/jumped"
	library = "/Forum_account/PixelMovement"
	title = "jumped var (mob)"
	see_also = list("/mob/proc/jump", "/mob/proc/can_jump")
	description = "Pressing a key does not cause the player to jump. Jumping is handled by the movement proc. The jumped var is a flag that tells the movement proc when the player jumped. When jumped = 1, the movement proc will process the jump and clear the flag."

REF/mob_var/keys
	name = "/mob/var/keys"
	library = "/Forum_account/PixelMovement"
	title = "keys list var (mob)"
	see_also = list("/mob/proc/key_down", "/mob/proc/key_up", "/mob/proc/clear_input", "/mob/proc/lock_input", "/mob/proc/unlock_input")
	description = "This is an associative list that keeps track of what keys are being pressed. If keys\[\"a\"] is 1 then the A key is being held, otherwise the A key is not being held. The library defines the K_LEFT, K_RIGHT, K_UP, and K_DOWN constants that can be used for checking the arrow keys."

REF/mob_var/move_speed
	name = "/mob/var/move_speed"
	library = "/Forum_account/PixelMovement"
	title = "move_speed var (mob)"
	see_also = list("/mob/var/fall_speed")
	description = "This var is used in the move() proc to limit your movement speed."
	default_value = "5"
/*
REF/mob_var/offset_x
	name = "/mob/var/offset_x"
	library = "/Forum_account/PixelMovement"
	title = "offset_x var (mob)"
	see_also = list("/mob/var/offset_y")
	description = "The pixel offset applied to the atom. This is used when the bottom left of the atom's icon is not the bottom left of its bounding box."
	default_value = "0"

REF/mob_var/offset_y
	name = "/mob/var/offset_y"
	library = "/Forum_account/PixelMovement"
	title = "offset_y var (mob)"
	see_also = list("/mob/var/offset_x")
	description = "The pixel offset applied to the atom. This is used when the bottom left of the atom's icon is not the bottom left of its bounding box."
	default_value = "0"
*/
REF/mob_var/on_bottom
	name = "/mob/var/on_bottom"
	library = "/Forum_account/PixelMovement"
	title = "on_bottom var (mob)"
	see_also = list("/atom/var/flags","/atom/var/flags_top","/mob/var/on_ground", "/mob/var/on_left", "/mob/var/on_right", "/mob/var/on_top")
	description = "This var is set by the mob's set_flags() proc. You can use it to check if there is a bumpable object below the mob. on_bottom is set to 1 if there's a bumpable atom below the mob. on_bottom is also binary ORed with the atom's flags and flags_top vars, so you can also use this var to extract properties of the objects your're touching."

REF/mob_var/on_ground
	name = "/mob/var/on_ground"
	library = "/Forum_account/PixelMovement"
	title = "on_ground var (mob)"
	see_also = list("/atom/var/flags","/atom/var/flags_ground","/mob/var/on_bottom", "/mob/var/on_left", "/mob/var/on_right", "/mob/var/on_top")
	description = "This var is set by the mob's set_flags() proc. You can use it to check if there is a bumpable object underneath the mob. on_ground is set to 1 if there's a bumpable atom underneath the mob. on_ground is also binary ORed with the atom's flags and flags_ground vars, so you can also use this var to extract properties of the objects your're touching."

REF/mob_var/on_left
	name = "/mob/var/on_left"
	library = "/Forum_account/PixelMovement"
	title = "on_left var (mob)"
	see_also = list("/atom/var/flags","/atom/var/flags_right","/mob/var/on_bottom", "/mob/var/on_ground", "/mob/var/on_right", "/mob/var/on_top")
	description = "This var is set by the mob's set_flags() proc. You can use it to check if there is a bumpable object underneath the mob. on_left is set to 1 if there's a bumpable atom underneath the mob. on_left is also binary ORed with the atom's flags and flags_right vars, so you can also use this var to extract properties of the objects your're touching."

REF/mob_var/on_right
	name = "/mob/var/on_right"
	library = "/Forum_account/PixelMovement"
	title = "on_right var (mob)"
	see_also = list("/atom/var/flags","/atom/var/flags_left","/mob/var/on_bottom", "/mob/var/on_ground", "/mob/var/on_left", "/mob/var/on_top")
	description = "This var is set by the mob's set_flags() proc. You can use it to check if there is a bumpable object underneath the mob. on_right is set to 1 if there's a bumpable atom underneath the mob. on_right is also binary ORed with the atom's flags and flags_left  vars, so you can also use this var to extract properties of the objects your're touching."

REF/mob_var/on_top
	name = "/mob/var/on_top"
	library = "/Forum_account/PixelMovement"
	title = "on_top var (mob)"
	see_also = list("/atom/var/flags","/atom/var/flags_bottom","/mob/var/on_bottom", "/mob/var/on_ground", "/mob/var/on_left", "/mob/var/on_right")
	description = "This var is set by the mob's set_flags() proc. You can use it to check if there is a bumpable object underneath the mob. on_top is set to 1 if there's a bumpable atom underneath the mob. on_top is also binary ORed with the atom's flags and flags_bottom vars, so you can also use this var to extract properties of the objects your're touching."

REF/mob_var/watching
	name = "/mob/var/watching"
	library = "/Forum_account/PixelMovement"
	title = "watching var (mob)"
	see_also = list("/mob/proc/watch","/mob/var/watching_me")
	description = "This is set automatically by the <code>mob.watch()</code> proc. This var is a reference to the mob that your client is watching. Do not set the value of this var directly because it won't do anything, it's just there for you to reference. Call <code>mob.watch()</code> instead."

REF/mob_var/watching_me
	name = "/mob/var/watching_me"
	library = "/Forum_account/PixelMovement"
	title = "watching_me var (mob)"
	see_also = list("/mob/proc/watch","/mob/var/watching")
	description = "This is a list of mobs that are watching you. This list is automatically maintained by the <code>mob.watch()</code> proc. When a mob starts watching you they are added to the list. When they stop, they're removed. This is all done automatically. You should never modify this list yourself, it's just there for you to reference."

REF/mob_var/vel_x
	name = "/mob/var/vel_x"
	library = "/Forum_account/PixelMovement"
	title = "vel_x var (mob)"
	see_also = list("/mob/var/vel_y","/mob/var/vel_z","/mob/proc/pixel_move", "/mob/proc/move", "/mob/proc/gravity")
	description = "The mob's speed in the x direction."

REF/mob_var/vel_y
	name = "/mob/var/vel_y"
	library = "/Forum_account/PixelMovement"
	title = "vel_y var (mob)"
	see_also = list("/mob/var/vel_x","/mob/var/vel_z","/mob/proc/pixel_move", "/mob/proc/move", "/mob/proc/gravity")
	description = "The mob's speed in the y direction."

REF/mob_var/vel_z
	name = "/mob/var/vel_z"
	library = "/Forum_account/PixelMovement"
	title = "vel_z var (mob)"
	see_also = list("/mob/var/vel_x","/mob/var/vel_y","/mob/proc/pixel_move", "/mob/proc/move", "/mob/proc/gravity")
	description = "The mob's speed in the z direction."


REF/mob_proc/action
	name = "/mob/proc/action"
	library = "/Forum_account/PixelMovement"
	title = "action proc (mob)"
	see_also = list("/mob/proc/movement", "/mob/proc/move_to", "/mob/proc/move_towards")
	description = "The action proc is called by the mob's movement proc. The action proc, by default, checks for keyboard input or, if move_to or move_towards has been called, makes the mob follow a path. You can override this proc to create custom movement logic (ex: enemy AI) without overriding the mob's movement() proc."
	format = "action()"
	args = ""
	returns = "nothing"
	default_action = "Processes keyboard input if the mob has a client attached. Also executes path-following logic if move_to or move_towards was called."

REF/mob_proc/bump
	name = "/mob/proc/bump"
	library = "/Forum_account/PixelMovement"
	title = "bump proc (mob)"
	see_also = list("/mob/proc/pixel_move")
	description = "This is called from pixel_move() when the mob bumps into something dense. The atom is the dense obstacle you hit and d is the direction you were moving in. d is either EAST or WEST (for bumping in the x direction), NORTH or SOUTH (for bumping in the y direction), or VERTICAL (for bumping in the z direction)."
	format = "bump(atom/a, d)"
	args = list("a: the atom that the mob bumped into", "d: the direction of the motion that caused the collision")
	returns = "nothing"
	default_action = "Sets the mob's velocity to zero for the direction that caused the collision. For example, if d is EAST or WEST, vel_x is set to zero."

REF/mob_proc/can_bump
	name = "/mob/proc/can_bump"
	library = "/Forum_account/PixelMovement"
	title = "can_bump proc (mob)"
	description = "Returns 1 if src can bump the atom, otherwise returns ..(). This allows for more complex density rules than just \"all dense objects bump all other dense objects\". For example, players cannot move through fences but bullets can, so player.can_bump(fence) = 1 but bullet.can_bump(bullet) = 0."
	format = "can_bump(atom/a)"
	args = "a: an atom we need to determine if we can collide with"
	returns = "0 or 1"
	default_action = "Returns 1 if a is a turf or a dense /obj. Returns 0 otherwise."

REF/mob_proc/can_jump
	name = "/mob/proc/can_jump"
	library = "/Forum_account/PixelMovement"
	title = "can_jump proc (mob)"
	see_also = list("/mob/proc/jump")
	description = "Called to check if the mob is allowed to jump. The default behavior requires that you be standing on the ground. You can override this to easily create different rules, like allowing the player to double jump."
	format = "can_jump()"
	args = ""
	returns = "0 or 1"
	default_action = "Returns 1 if the mob's on_ground flag is set, returns 0 otherwise."

REF/mob_proc/check_loc
	name = "/mob/proc/check_loc"
	library = "/Forum_account/PixelMovement"
	title = "check_loc proc (mob)"
	see_also = list("/world/proc/movement", "/atom/var/px", "/atom/var/py", "/atom/var/pz", "/atom/var/loc")
	description = "Checks if the mob's loc was changed directly - by saying mob.loc = locate(1,2,3) as opposed to the mob's loc changing naturally as the player moves around. When a direct change to loc is detected, the mob's pixel coordinates are updated. Without this, directly changing the mob's loc will do nothing because it doesn't update the mob's pixel coordinates (px, py, pz)."
	format = "check_loc()"
	args = ""
	returns = "nothing"

REF/mob_proc/clear_input
	name = "/mob/proc/clear_input"
	library = "/Forum_account/PixelMovement"
	title = "clear_input proc (mob)"
	see_also = list("/mob/proc/lock_input", "/mob/proc/unlock_input")
	description = "Clears the keys list so that key\[k] = 0 for all keys."
	format = "clear_input()"
	args = ""
	returns = "nothing"

REF/mob_proc/dense
	name = "/mob/proc/dense"
	library = "/Forum_account/PixelMovement"
	title = "dense proc (mob)"
	description = "Returns 1 if the list contains an atom that src can_bump. Returns 0 otherwise."
	format = "dense(list/l)"
	args = "l: a list of atoms"
	returns = "0 or 1"

REF/mob_proc/gravity
	name = "/mob/proc/gravity"
	library = "/Forum_account/PixelMovement"
	title = "gravity proc (mob)"
	see_also = list("/mob/proc/movement", "/mob/var/vel_z", "/mob/var/on_ground")
	description = "The gravity proc is called by the mob's default movement proc to adjust the mob's vel_z variable to create gravity."
	format = "gravity()"
	args = ""
	returns = "nothing"
	default_action = "Subtracts 1 from vel_z if the mob is not on the ground."

REF/mob_proc/jump
	name = "/mob/proc/jump"
	library = "/Forum_account/PixelMovement"
	title = "jump proc (mob)"
	see_also = list("/mob/proc/can_jump", "/mob/var/on_ground", "/mob/var/fall_speed")
	description = "Called when the mob jumps."
	format = "jump()"
	args = ""
	returns = "nothing"
	default_action = "Sets vel_z = 8."

REF/mob_proc/key_down
	name = "/mob/proc/key_down"
	library = "/Forum_account/PixelMovement"
	title = "key_down proc (mob)"
	see_also = list("/mob/proc/key_up", "/mob/var/keys")
	description = {"This is called when the client presses a key. k is the name of the key that was pressed (A key -> k = "a", F1 key -> k = "F1"). Some constants exist: K_UP, K_DOWN, K_LEFT, and K_RIGHT correspond to the arrow keys."}
	format = "key_down(k)"
	args = "k: a string representing the key that was pressed."
	returns = "nothing"
	default_action = "If k is \"space\", it sets jumped to 1 (which will cause the jump() proc to be called the next time the movement proc runs)."

REF/mob_proc/key_up
	name = "/mob/proc/key_up"
	library = "/Forum_account/PixelMovement"
	title = "key_up proc (mob)"
	see_also = list("/mob/proc/key_down", "/mob/var/keys")
	description = "Like key_down, except this is called when the key is released."
	format = "key_up(k)"
	args = "k: a string representing the key that was released."
	returns = "nothing"
	default_action = "nothing"

REF/mob_proc/lock_input
	name = "/mob/proc/lock_input"
	library = "/Forum_account/PixelMovement"
	title = "lock_input proc (mob)"
	see_also = list("/mob/proc/unlock_input", "/mob/proc/clear_input")
	description = "After lock_input is called, keystrokes will not be processed - pressing a key will not call key_down/key_up and will not modify the keys list."
	format = "lock_input()"
	args = ""
	returns = "nothing"
	default_action = "nothing"

REF/mob_proc/move
	name = "/mob/proc/move"
	library = "/Forum_account/PixelMovement"
	title = "move proc (mob)"
	see_also = list("/mob/proc/movement")
	description = "Called to handle the action of walking left, right, up, or down."
	format = "move(d)"
	args = "d: the direction the player is trying to move (NORTH, SOUTH, EAST, WEST)"
	returns = "nothing"
	default_action = "Accelerates the player in the specified direction and enforces the move_speed restriction."

REF/mob_proc/move_to
	name = "/mob/proc/move_to"
	library = "/Forum_account/PixelMovement"
	title = "move_to proc (mob)"
	see_also = list("/mob/proc/move_towards", "/mob/proc/stop", "/mob/proc/action")
	description = "Plans a path to the specified destination using the A* search algorithm. If the argument is a mob, the path will be planned to the mob's loc. Once move_to is called, the mob's keyboard input will be ignored and they'll automatically follow the path. You can call stop() or move_to(null) to stop this behavior. You can think of this as the pixel movement equivalent of BYOND's walk_to proc."
	format = "move_to(atom/a)"
	args = "a: the destination"
	returns = "nothing"
	default_action = ""

REF/mob_proc/move_towards
	name = "/mob/proc/move_towards"
	library = "/Forum_account/PixelMovement"
	title = "move_towards proc (mob)"
	see_also = list("/mob/proc/move_to", "/mob/proc/stop", "/mob/proc/action")
	description = "This proc is like the move_to proc except it doesn't plan a path, it just uses some basic rules to make the mob move towards its destination. This sounds useless compared to move_to, but it uses less CPU and is often sufficient. You can think of this as the equivalent of DM's walk_towards proc. To stop this movement you can call mob.move_towards(null) or mob.stop()."
	format = "move_towards(atom/a)"
	args = "a: the destination"
	returns = "nothing"
	default_action = ""

REF/mob_proc/movement
	name = "/mob/proc/movement"
	library = "/Forum_account/PixelMovement"
	title = "movement proc (mob)"
	see_also = list("/mob/proc/move", "/mob/proc/action", "/mob/proc/set_flags", "/mob/proc/set_state", "/mob/proc/pixel_move")
	description = "This is called every tick for every mob by a global loop. It handles the default movement behavior for mobs.<p>You can override this proc to drastically change a mob's movement behavior. For example, for projectiles like bullets which move in a constant direction until they hit something, you don't need to call set_flags(), gravity(), set_state(), or action(). You can override the movement proc to make the behavior much simpler.<p>If you want to keep the basic movement behavior (gravity, velocity, etc.) but want to change the mob's movement logic (ex: to add AI), you can override the action() proc instead."
	format = "movement()"
	args = ""
	returns = "nothing"
	default_action = "Calls set_flags(), gravity(), action(), set_state(), then pixel_move(vel_x, vel_y, vel_z)."

REF/mob_proc/pixel_move
	name = "/mob/proc/pixel_move"
	library = "/Forum_account/PixelMovement"
	title = "pixel_move proc (mob)"
	see_also = list("/mob/proc/movement", "/mob/proc/set_pos")
	description = "This proc is used to make the mob move by a specific number of pixels. It's automatically called by the mob's movement() proc, but you might find cases where you need to call it yourself. It's kind of like the pixel equivalent of BYOND's step() proc."
	format = "pixel_move(dpx, dpy, dpz)"
	args = list("dpx: the amount of pixels to move in the x direction", "dpy: the amount of pixels to move in the y direction", "dpz: the amount of pixels to move in the z direction")
	returns = "0 or 1"
	default_action = "Moves the mob by the requested number of pixels taking obstacles into account, then calls set_pos() to update the mob's coordinates. It returns 1 if any movement was performed and zero if no move was performed."

REF/mob_proc/set_camera
	name = "/mob/proc/set_camera"
	library = "/Forum_account/PixelMovement"
	title = "set_camera proc (mob)"
	see_also = list("/mob/var/camera", "/Camera", "/mob/proc/set_pos")
	description = "The set_camera() proc is called by the set_pos() proc, so it executes every time the mob's position changes. It's used to enforce the default camera logic, but you can override it to replace or extend these rules."
	format = "set_camera()"
	args = ""
	returns = "nothing"
	default_action = "Enforces the default camera rules, taking into account the mob's camera settings."

REF/mob_proc/set_flags
	name = "/mob/proc/set_flags"
	library = "/Forum_account/PixelMovement"
	title = "set_flags proc (mob)"
	see_also = list("/mob/proc/movement", "/mob/proc/can_bump", "/mob/var/on_ground", "/mob/var/on_left", "/mob/var/on_right", "/mob/var/on_top", "/mob/var/on_bottom", "/atom/var/flags")
	description = "Sets the values of the mob's on_ground, on_left, on_right, on_top, and on_bottom vars. This is automatically called by the default movement() proc.<p>The on_ground, on_left, etc. vars are set to indicate what objects are next to the mob on each side. If a bumpable atom is next to the player, the flag is set to 1. Each flag is also binary ORed with the flags var of the adjacent atoms so you can see what properties belong to the atoms that are next to the player."
	format = "set_flags()"
	args = ""
	returns = "nothing"
	default_action = "Sets the values of the mob's on_ground, on_left, on_right, on_top, and on_bottom vars."

REF/mob_proc/set_pos
	name = "/mob/proc/set_pos"
	library = "/Forum_account/PixelMovement"
	title = "set_pos proc (mob)"
	see_also = list("/mob/proc/pixel_move", "/mob/proc/set_camera", "/atom/var/px", "/atom/var/py", "/atom/var/pz")
	description = "Updates the mob's pixel coordinates (px, py, pz). If the mob has crossed into another tile (so that the majority of the mob is inside that tile), the mob's loc will be changed and the appropriate Entered and Exited procs will be called for the turfs/areas the mob is entering or exiting."
	format = "set_pos(nx, ny, nz, map_z)"
	args = list("nx: the new px value", "ny: the new py value", "nz: the new pz value", "map_z: the new z coordinate, this is used to make the mob change z levels")
	returns = "nothing"
	default_action = "Updates the mob's pixel coordinates (px, py, pz). Updates the mob's loc. Also calls set_camera() and sets the client's pixel_x and pixel_y values."

REF/mob_proc/set_state
	name = "/mob/proc/set_state"
	library = "/Forum_account/PixelMovement"
	title = "set_state proc (mob)"
	see_also = list("/mob/proc/movement", "/mob/var/base_state")
	description = "Sets the mob's icon_state to reflect the action the mob is performing. If the mob is standing still, their icon_state will be set to \"standing\". If the mob's base_state variable is set, this value will be used as a prefix to the icon_state. So, if the mob is standing still and it's base_state is \"mob\", its icon_state will be set to \"mob-standing\". This lets you define icon states for many mobs in the same .dmi file and use the base_state variable to control which states are used for a mob.<p>You may often need to override this proc to accommodate additional actions (attacking, climbing, ducking, etc.)."
	format = "set_state()"
	args = ""
	returns = "nothing"
	default_action = "Sets the mob's icon_state to \"jumping\" if the mob is in the air, \"standing\" if the mob is not moving, and \"moving\" if it is moving."

REF/mob_proc/slow_down
	name = "/mob/proc/slow_down"
	library = "/Forum_account/PixelMovement"
	title = "slow_down proc (mob)"
	see_also = list("/mob/proc/movement", "/mob/proc/move", "/mob/var/vel_x", "/mob/var/vel_y", "/mob/var/vel_z")
	description = "When you release a key, this proc makes your mob gradually slow down."
	format = "slow_down()"
	args = ""
	returns = "nothing"
	default_action = "Reduces the mob's vel_x and vel_y values based on what directional keys are or aren't pressed."

REF/mob_proc/start_trace
	name = "/mob/proc/start_trace"
	library = "/Forum_account/PixelMovement"
	title = "start_trace proc (mob)"
	see_also = list("/mob/proc/stop_trace","/Forum_account/PixelMovement/debugging")
	description = "The start_trace proc enables the debug log for the src mob. Once the start_trace proc is called, all movement events (pixel_move, movement, set_pos, bump, etc.) will be logged. When stop_trace is called the log will be shown in an HTML popup.<p>This debugging tool can be useful for identifying problem situations that would be hard to identify by watching events happen in realtime. See the <a href=#/Forum_account/PixelMovement/debugging>debugging page</a> for more debugging tips."
	format = "start_trace()"
	args = ""
	returns = "nothing"

REF/mob_proc/stop
	name = "/mob/proc/stop"
	library = "/Forum_account/PixelMovement"
	title = "stop proc (mob)"
	see_also = list("/mob/proc/move_to", "/mob/proc/move_towards")
	description = "Cancels any automatic movement that would be triggered by calls to move_to() or move_towards()."
	format = "stop()"
	args = ""
	returns = "nothing"

REF/mob_proc/stop_trace
	name = "/mob/proc/stop_trace"
	library = "/Forum_account/PixelMovement"
	title = "stop_trace proc (mob)"
	see_also = list("/mob/proc/start_trace","/Forum_account/PixelMovement/debugging")
	description = "Stops the debug logger and shows the log information in an HTML popup.<p>This debugging tool can be useful for identifying problem situations that would be hard to identify by watching events happen in realtime. See the <a href=#/Forum_account/PixelMovement/debugging>debugging page</a> for more debugging tips."
	format = "stop_trace()"
	args = ""
	returns = "nothing"

REF/mob_proc/unlock_input
	name = "/mob/proc/unlock_input"
	library = "/Forum_account/PixelMovement"
	title = "unlock_input proc (mob)"
	see_also = list("/mob/proc/lock_input", "/mob/proc/clear_input", "/mob/var/keys")
	description = "This proc enables the processing of keyboard input again after you've called lock_input."
	format = "unlock_input()"
	args = ""
	returns = "nothing"

REF/mob_proc/watch
	name = "/mob/proc/watch"
	library = "/Forum_account/PixelMovement"
	title = "watch proc (mob)"
	see_also = list("/client/var/eye","/mob/var/watching","/mob/var/watching_me")
	description = "This proc makes the client attached to the src mob watch the specified mob. This is necessary because the client's eye has to have a pixel offset to properly follow another mob, so it's not as simple as just saying <tt>client.eye = m</tt>. The process of following another mob is more complex but that's all internal to the library. It handles the details of updating your client's pixel offset to follow the mob, you only need to call <code>mob.watch()</code>."
	format = "watch(mob/m)"
	args = list("m: the mob to watch")
	returns = "nothing"


REF/DM/preprocessor/define/TWO_DIMENSIONAL
	name = "/DM/preprocessor/define/TWO_DIMENSIONAL"
	library = "/Forum_account/PixelMovement"
	title = "TWO_DIMENSIONAL definition"
	see_also = list("/DM/preprocessor/define")
	description = "If <code>TWO_DIMENSIONAL</code> is defined, the library operates in a top-down, two-dimensional mode. This means that players cannot jump or move at all in the z direction.<p>If your game doesn't use the z-dimension for jumping, you can declare this flag to tell the library to not bother worrying about that dimension. If you don't, it'll do more time-consuming collision checks. Enabling the flag will boost performance.<p>You can define this flag in the library itself. Or, you can declare the flag by opening up the .dme file for your project (the project that's using the pixel movement library) and placing the #define statement on the line before <code>// BEGIN_INTERNALS</code>."
	format = "#define TWO_DIMENSIONAL"

REF/DM/preprocessor/define/LIBRARY_DEBUG
	name = "/DM/preprocessor/define/LIBRARY_DEBUG"
	library = "/Forum_account/PixelMovement"
	title = "LIBRARY_DEBUG definition"
	see_also = list("/DM/preprocessor/define","/Forum_account/PixelMovement/debugging","/mob/proc/start_trace","/mob/proc/stop_trace")
	description = "If <code>LIBRARY_DEBUG</code> is defined, the library enables some debugging features. Every movement proc needs to have some code to handle movement traces (the mob.start_trace proc), but this code slows things down if you aren't using the debugging features. Leave this flag undefined for a performance boost."
	format = "#define LIBRARY_DEBUG"

REF/DM/preprocessor/define/NO_FLAGS
	name = "/DM/preprocessor/define/NO_FLAGS"
	library = "/Forum_account/PixelMovement"
	title = "NO_FLAGS definition"
	see_also = list("/DM/preprocessor/define")
	description = "If <code>NO_FLAGS</code> is defined, the library doesn't define the mob's set_flags proc, and the on_ground, on_left, on_right, flags, flags_left, flags_right, etc. vars. If you never use these vars you can define this flag to improve performance."
	format = "#define NO_FLAGS"

REF/DM/preprocessor/define/NO_STEPPED_ON
	name = "/DM/preprocessor/define/NO_STEPPED_ON"
	library = "/Forum_account/PixelMovement"
	title = "NO_STEPPED_ON definition"
	see_also = list("/DM/preprocessor/define")
	description = "If <code>NO_STEPPED_ON</code> is defined, the library doesn't define the stepped_on, stepping_on, and stepped_off procs. The library has to do some computation to detect when these events occur, so if you don't use these procs you can define this flag for a performance boost."
	format = "#define NO_STEPPED_ON"


REF/Camera
	name = "/Camera"
	library = "/Forum_account/PixelMovement"
	title = "Camera object"
	see_also = list("/mob/proc/set_camera")
	description = "This object contains many variables that you can use to control the camera's behavior.<dl><dt>Camera/var\n<dd><a href=#/Camera/var/lag>lag</a>\n<dd><a href=#/Camera/var/minx>minx</a>\n<dd><a href=#/Camera/var/maxx>maxx</a>\n<dd><a href=#/Camera/var/miny>miny</a>\n<dd><a href=#/Camera/var/maxy>maxy</a>\n<dd><a href=#/Camera/var/mode>mode</a>\n<dd><a href=#/Camera/var/px>px</a>\n<dd><a href=#/Camera/var/py>py</a>\n</dl>"

REF/Camera_var/lag
	name = "/Camera/var/lag"
	library = "/Forum_account/PixelMovement"
	title = "lag var (Camera)"
	see_also = list("/Camera/var/mode","/Camera/var/px","/Camera/var/py")
	description = "The number of pixels the mob is allowed to stray before the camera will start moving to keep up."
	default_value = "0"

REF/Camera_var/minx
	name = "/Camera/var/minx"
	library = "/Forum_account/PixelMovement"
	title = "minx var (Camera)"
	see_also = list("/Camera/var/maxx","/Camera/var/miny","/Camera/var/maxy")
	description = "These specify the bounds of the camera's coordinates. The default behavior of the set_camera proc will not move the camera's px and py to be outside of the rectangle defined by these four variables."
	default_value = "0"

REF/Camera_var/maxx
	name = "/Camera/var/maxx"
	library = "/Forum_account/PixelMovement"
	title = "maxx var (Camera)"
	see_also = list("/Camera/var/minx","/Camera/var/miny","/Camera/var/maxy")
	description = "These specify the bounds of the camera's coordinates. The default behavior of the set_camera proc will not move the camera's px and py to be outside of the rectangle defined by these four variables."
	default_value = "320000"

REF/Camera_var/miny
	name = "/Camera/var/miny"
	library = "/Forum_account/PixelMovement"
	title = "miny var (Camera)"
	see_also = list("/Camera/var/minx","/Camera/var/maxx","/Camera/var/maxy")
	description = "These specify the bounds of the camera's coordinates. The default behavior of the set_camera proc will not move the camera's px and py to be outside of the rectangle defined by these four variables."
	default_value = "0"

REF/Camera_var/maxy
	name = "/Camera/var/maxy"
	library = "/Forum_account/PixelMovement"
	title = "maxy var (Camera)"
	see_also = list("/Camera/var/minx","/Camera/var/maxx","/Camera/var/miny")
	description = "These specify the bounds of the camera's coordinates. The default behavior of the set_camera proc will not move the camera's px and py to be outside of the rectangle defined by these four variables."
	default_value = "320000"

REF/Camera_var/mode
	name = "/Camera/var/mode"
	library = "/Forum_account/PixelMovement"
	title = "mode var (Camera)"
	see_also = list("/Camera/var/px","/Camera/var/py")
	description = "Can either be SLIDE or FOLLOW. The SLIDE and FOLLOW constants are members of the camera object, so to set a mob's camera mode, you'd do: mob.camera.mode = mob.camera.SLIDE.<p>When mode is set to FOLLOW, the camera will move as fast as the mob to follow their motion. When mode is set to SLIDE, the camera will speed up and slow down to smoothly follow the mob's motion."
	default_value = "0"

REF/Camera_var/px
	name = "/Camera/var/px"
	library = "/Forum_account/PixelMovement"
	title = "px var (Camera)"
	see_also = list("/Camera/var/py")
	description = "The position of the camera in pixel coordinates. When they're set to the mob's px and py, the camera will be centered on the mob."
	default_value = "0"

REF/Camera_var/py
	name = "/Camera/var/py"
	library = "/Forum_account/PixelMovement"
	title = "py var (Camera)"
	see_also = list("/Camera/var/px")
	description = "The position of the camera in pixel coordinates. When they're set to the mob's px and py, the camera will be centered on the mob."
	default_value = "0"


REF/world_proc/movement
	name = "/world/proc/movement"
	library = "/Forum_account/PixelMovement"
	title = "movement proc (world)"
	see_also = list("/mob/proc/movement", "/mob/proc/check_loc")
	description = "world.movement() is automatically called every tick and it calls the check_loc() and movement() procs for all mobs in the world.<p>You can override this proc to create a custom movement loop. You might do this because you don't want to call the movement proc for every mob in the world, just the mobs that are near clients. Otherwise you'd be using a lot of CPU time performing movements for mobs that nobody can see."
	format = "movement()"
	args = ""
	returns = "nothing"


REF/Controls
	name = "/Controls"
	library = "/Forum_account/PixelMovement"
	title = "Controls object"
	see_also = list("/mob/var/keys")
	description = "This object contains variables that are used by the library's default movement behavior to map keys to actions.<p>You can change the values of the Control object's vars to change what keys the player uses. See the control-scheme\\wasd demo for an example of how to use the WASD keys instead of the arrow keys."

REF/Controls_var/up
	name = "/Controls/var/up"
	library = "/Forum_account/PixelMovement"
	title = "up var (Controls)"
	see_also = list("/Controls","/Controls/var/down","/Controls/var/left","/Controls/var/right","/Controls/var/jump")
	description = "The key that makes the mob move up."
	default_value = "north"

REF/Controls_var/down
	name = "/Controls/var/down"
	library = "/Forum_account/PixelMovement"
	title = "down var (Controls)"
	see_also = list("/Controls","/Controls/var/up","/Controls/var/left","/Controls/var/right","/Controls/var/jump")
	description = "The key that makes the mob move down."
	default_value = "south"

REF/Controls_var/left
	name = "/Controls/var/left"
	library = "/Forum_account/PixelMovement"
	title = "left var (Controls)"
	see_also = list("/Controls","/Controls/var/up","/Controls/var/down","/Controls/var/right","/Controls/var/jump")
	description = "The key that makes the mob move left."
	default_value = "west"

REF/Controls_var/right
	name = "/Controls/var/right"
	library = "/Forum_account/PixelMovement"
	title = "right var (Controls)"
	see_also = list("/Controls","/Controls/var/up","/Controls/var/down","/Controls/var/left","/Controls/var/jump")
	description = "The key that makes the mob move right."
	default_value = "east"

REF/Controls_var/jump
	name = "/Controls/var/jump"
	library = "/Forum_account/PixelMovement"
	title = "jump var (Controls)"
	see_also = list("/Controls","/Controls/var/up","/Controls/var/down","/Controls/var/left","/Controls/var/right")
	description = "The key that makes the mob jump."
	default_value = "space"


REF/page/debugging
	name = "/Forum_account/PixelMovement/debugging"
	library = "/Forum_account/PixelMovement"
	title = "Pixel Movement Debugging"
	see_also = list("/DM/preprocessor/define/LIBRARY_DEBUG","/mob/proc/start_trace","/mob/proc/stop_trace")
	description = "Even if you're used to debugging movement related problems with BYOND's default tile-based movement system, debugging pixel movement can be tricky. Situations are more complex and things happen faster. This makes things harder to reproduce and harder to identify problems just by watching events as they happen.<p>The first debugging tool is the library's debugging statpanel. To enable this, set the global variable <tt>PIXEL_MOVEMENT_DEBUG = 1</tt>. This creates a tab in the statpanel that shows information related to your mob (if you use the Stat() proc in your project, make sure you call ..() in it).<p>One of the more useful features of the debugging statpanel is the list of keys pressed. Keyboard input is surprisingly limited. Run a demo and press as many keys as you can - the library won't recognize all of them. In fact, it probably won't recognize most. This isn't a limitation of the library or even a limitation of BYOND, it's a limitation due to how keyboards are designed. Some key combinations will prevent additional keypresses from being recognized. If you suspect this is creating problems you can look at the debugging statpanel to verify this.<p>The statpanel isn't always useful. If there's a situation where the mob's movement appears to be incorrect you may need to know exactly where the mob was standing and how exactly they tried to move. That statpanel doesn't refresh often enough, and even if it did, you wouldn't be able to catch the numbers as they change. For problems like this there's the movement logger.<p>The mob.start_trace() proc starts the movement logger. After calling this proc, all movement-related actions (movement(), pixel_move(), set_pos(), etc.) are logged. When stop_trace() is called, the log is shown in an HTML popup window. This lets you review the log to see what the exact circumstances were when the unexpected behavior happened."

REF/library/PixelMovement
	name = "/Forum_account/PixelMovement"
	title = "PixelMovement Library"
	hub_entry = "http://www.byond.com/developer/Forum_account/PixelMovement"
	description = {"This library provides you with a pixel-based movement system for BYOND games. This lets mobs move a few pixels at a time instead of a whole tile at a time.<p>Just like how you can override BYOND's built-in movement procs (Move, Entered, etc.) to make new effects for your game, you can override the procs defined by this library to create new effects for your game.<p>To learn the basics of using the library, look through the demos that come with it. The demos are contained in subfolders (ex: "basic-demo", "intermediate-demo", etc.). These folders are located in the file tree at the left side of the DM window. To run a demo, check off all of the files in a single subfolder, then compile and run the program. Make sure you only have files for one demo included at a time.<p>If you have any questions, concerns, or comments about using the library, don't hesitate to post on <a href="http://www.byond.com/members/Forumaccount/forum">my forum</a>."}
