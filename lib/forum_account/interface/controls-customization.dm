
// File:    controls-customization.dm
// Library: Forum_account.Interface
// Author:  Forum_account
//
// Contents:
//   Contains modifications to the /Control types defined in
//   controls.dm. The procs here provide additional features
//   beyond the library's abstraction of winset/winget calls.
//
//   These procs are defined separately from controls.dm so
//   you can regenerate the code for the controls without losing
//   these features.

Browser
	proc
		// display some HTML in the browser control.
		HTML(html, raw_html = 0)
			if(!raw_html)
				html = JS2DM(owner) + html
			owner << output(html, "[window_id].[control_id]")

		// alias of the HTML() proc
		Output(html)
			return HTML(html)

		// Directs the browser control to the specified URL.
		Link(url)
			HTML({"<meta http-equiv="Refresh" content="0; url='[url]'">"})

		// alias of the Link() proc
		Browse(url)
			Link(url)

		// Places a file in the client's cache (the client is
		// the owner of the browser control). If one argument
		// is specified, that file is placed in the cache. If a
		// second argument is specified, the first arg is assumed
		// to be an icon and the second arg is the icon state to
		// be cached.
		// The proc returns the name of the file as it'll appear
		// in the cache.
		Cache(file, icon_state = "")
			var/filename = "[file]"

			if(isicon(file) && isfile(file) && icon_state)
				var/icon/I = new(file, icon_state)
				filename = copytext(filename, 1, findtext(filename,".dmi")) + ".[icon_state].png"
				owner << browse_rsc(I, filename)
			else
				owner << browse_rsc(file, "[file]")

			return filename

		// calls a JavaScript function inside the browser control.
		// The first argument is the name of the function. The
		// remaining arguments are the parameters.
		JavaScript()
			var/list/parameters = args.Copy()
			parameters.Cut(1,2)
			owner.call_JavaScript("[window_id].[control_id]", args[1], parameters)

Grid
	proc
		List(list/L)
			for(var/i = 1 to L.len)
				Cell(1,i,L[i])
			Cells(L.len)

		Cell(x, y, value)
			if(!isnum(x))
				CRASH("Grid.Cell(x, y, value) expected a number but got Cell([x], [y], [value])")

			if(istype(value, /list))
				for(var/i = 1 to length(value))
					winset(owner, "[window_id].[control_id]", "current-cell=[x],[y+i-1]")
					owner << output(value[i], "[window_id].[control_id]")
			else
				winset(owner, "[window_id].[control_id]", "current-cell=[x],[y]")
				owner << output(value, "[window_id].[control_id]")

Output
	proc
		// The Output() proc takes a text string and an optional target.
		// If both are specified the order doesn't matter. The target is
		// the set of people who receive the message.
		Output()
			if(args.len < 1)
				CRASH("The Output proc needs at least one parameter.")

			var/target
			var/txt
			if(args.len == 1)
				txt = args[1]
				target = owner
			else
				if(istext(args[1]))
					txt = args[1]
					target = args[2]
				else
					txt = args[2]
					target = args[1]

			if(target)
				target << output(txt, "[window_id].[control_id]")
