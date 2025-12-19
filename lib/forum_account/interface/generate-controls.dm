
// File:    generate-controls.dm
// Library: Forum_account.Interface
// Author:  Forum_account
//
// Contents:
//   Contains the code to generate the DM code definitions for
//   each type of interface control.

/*

Label_members is the list of properties that Labels have. Currently some properties are not supported

*/

		/*
		// Generate the code for the /Control objects.
		// You only need to re-generate this code if you make changes to
		// the generation process.
		print_code("Label", Label_members)
		print_code("Output", Output_members)
		print_code("Input", Input_members)
		print_code("Grid", Grid_members)
		print_code("Tab", Tab_members)
		print_code("Bar", Bar_members)
		print_code("Button", Button_members)
		print_code("Map", Map_members)
		print_code("Browser", Browser_members)
		print_code("Info", Info_members)
		print_code("Window", Window_members)
		print_code("Child", Child_members)
		*/

		/*
		// Generate the code for the /Window objects.
		// You need to re-generate this code when you make changes to a window in an interface file.
		generate_window_code("interface.dmf")
		*/

var
	// These lists specify what properties each control type has.
	list/Control_members = list("pos","size","anchor1","anchor2","font-family","font-size","font-style","text-color","background-color","is-visible","is-disabled","is-transparent","is-default","border","drop-zone","right-click","saved-params")
	list/Label_members = list("text","image","image-mode","keep-aspect","align","text-wrap")
	list/Output_members = list("link-color","visited-color","style","enable-http-images","max-lines","image")
	list/Input_members = list("command","multi-line","is-password","no-command")
	list/Grid_members = list("cells","current-cell","show-lines","small-icons","show-names","enable-http-images","link-color","visited-color","line-color","style","is-list")
	list/Tab_members = list("tabs","current-tab","multi-line","on-tab")
	list/Bar_members = list("bar-color","is-slider","width","dir","angle1","angle2","value","on-change")
	list/Button_members = list("text","image","command","is-flat","stretch","is-checked","group","button-type")
	list/Map_members = list("icon-size","text-mode","on-show","on-hide")
	list/Browser_members = list("show-history","show-url","auto-format","use-title","on-show","on-hide")
	list/Info_members = list("highlight-color","tab-text-color","tab-background-color","tab-font-family","tab-font-size","tab-font-style","allow-html","multi-line","on-show","on-hide","on-tab")
	list/Window_members = list("type",,"title","titlebar","statusbar","can-close","can-minimize","can-resize","is-pane","is-minimized","is-maximized","can-scroll","icon","image","image-mode","keep-aspect","transparent-color","alpha","macro","menu","on-close")
	list/Child_members = list("left","right","is-vert","splitter","show-splitter","lock")

	// This list specifies attributes of each control property.
	// The format is:
	//
	// "property-name" = list("type", "yes/no")
	//
	// The "yes/no" specifies if the value is dynamic. Dynamic
	// values can change on the client, so requesting the value
	// of a dynamic property will always result in winget() being
	// called. Non-dynamic values are cached on the server and
	// don't always require calls to winget().
	list/property_info = list(
		"pos" = list("position", "yes"),
		"current-cell" = list("position", "no"),
		"anchor1" = list("position", "no"),
		"anchor2" = list("position", "no"),

		"size" = list("size", "yes"),
		"cells" = list("size", "no"),

		"text-color" = list("color", "no"),
		"background-color" = list("color", "no"),
		"link-color" = list("color", "no"),
		"visited-color" = list("color", "no"),
		"line-color" = list("color", "no"),
		"highlight-color" = list("color", "no"),
		"tab-text-color" = list("color", "no"),
		"tab-background-color" = list("color", "no"),
		"bar-color" = list("color", "no"),
		"transparent-color" = list("color", "no"),

		"is-visible" = list("boolean", "no"),
		"is-default" = list("boolean", "no"),
		"drop-zone" = list("boolean", "no"),
		"show-names" = list("boolean", "no"),
		"auto-format" = list("boolean", "no"),
		"allow-html" = list("boolean", "no"),
		"multi-line" = list("boolean", "no"),
		"text-mode" = list("boolean", "yes"),
		"is-disabled" = list("boolean", "no"),
		"is-transparent" = list("boolean", "no"),
		"right-click" = list("boolean", "no"),
		"keep-aspect" = list("boolean", "no"),
		"text-wrap" = list("boolean", "no"),
		"enable-http-images" = list("boolean", "no"),
		"is-password" = list("boolean", "no"),
		"no-command" = list("boolean", "no"),
		"small-icons" = list("boolean", "no"),
		"is-list" = list("boolean", "no"),
		"show-history" = list("boolean", "no"),
		"show-url" = list("boolean", "no"),
		"use-title" = list("boolean", "no"),
		"is-slider" = list("boolean", "no"),
		"is-flat" = list("boolean", "no"),
		"stretch" = list("boolean", "no"),
		"is-checked" = list("boolean", "no"),
		"titlebar" = list("boolean", "no"),
		"statusbar" = list("boolean", "no"),
		"can-close" = list("boolean", "no"),
		"can-minimize" = list("boolean", "no"),
		"can-resize" = list("boolean", "no"),
		"is-pane" = list("boolean", "no"),
		"is-minimized" = list("boolean", "no"),
		"is-maximized" = list("boolean", "no"),
		"can-scroll" = list("boolean", "no"),
		"focus" = list("boolean", "no"),
		"is-vert" = list("boolean", "no"),
		"show-splitter" = list("boolean", "no"),
		"right-click" = list("boolean", "no"),

		"font-size" = list("number", "no"),
		"max-lines" = list("number", "no"),
		"tab-font-size" = list("number", "no"),
		"width" = list("number", "no"),
		"angle1" = list("number", "no"),
		"angle2" = list("number", "no"),
		"value" = list("number", "yes"),
		"icon-size" = list("number", "no"),
		"alpha" = list("number", "no"),
		"splitter" = list("number", "yes"),

		/* "bold italic underline strike" */
		"font-style" = list("fontstyle", "no"),
		"tab-font-style" = list("fontstyle", "no"),

		/* "none line sunken" */
		"border" = list("borderstyle", "no"),

		/* "center stretch tile" */
		"image-mode" = list("imagemode", "no"),

		/* "center left right top bottom top-left top-right bottom-left bottom-right" */
		"align" = list("alignment", "no"),

		"text" = list("text", "no"),
		"font-family" = list("text", "no"),
		"image" = list("text", "no"),
		"tab-font-family" = list("text", "no"),
		"type" = list("text", "no"),
		"title" = list("text", "no"),
		"icon" = list("text", "no"),
		"macro" = list("text", "no"),
		"menu" = list("text", "no"),
		"left" = list("text", "no"),
		"right" = list("text", "no"),

		"command" = list("event", "no"),
		"on-show" = list("event", "no"),
		"on-hide" = list("event", "no"),
		"on-tab" = list("event", "no"),
		"on-change" = list("event", "no"),
		"on-close" = list("event", "no"),

		/* "pushbutton pushbox checkbox radio" */
		"button-type" = list("buttontype", "no"))


proc
	// This converts names like "font-family" to "FontFamily"
	format_name(p)
		. = ""
		var/capitalize = 0
		for(var/i = 1 to length(p))
			if(copytext(p,i,i+1) == "-")
				capitalize = 1
			else
				if(i == 1 || capitalize)
					. += uppertext(copytext(p,i,i+1))
				else
					. += lowertext(copytext(p,i,i+1))

				capitalize = 0

	event_name(e)
		var/pos = findtext(e,"-")
		if(pos)
			return copytext(e,pos+1)
		return e

	// Output the code for a control type
	print_code(object_name, list/properties)

		var/list/local_vars = list()

		for(var/p in properties)
			if(!(p in property_info))
				local_vars += "_[format_name(p)]"
			else if(property_info[p][1] == "position")
				local_vars += "Position/_[format_name(p)]"
			else if(property_info[p][1] == "size")
				local_vars += "Size/_[format_name(p)]"
			else if(property_info[p][1] == "color")
				local_vars += "Color/_[format_name(p)]"
			else if(property_info[p][1] == "event")
			else
				local_vars += "_[format_name(p)]"

		world << object_name
		world << "\tparent_type = /Control"
		world << "\tvar"
		for(var/v in local_vars)
			world << "\t\t[v]"

		world << "\tNew()"
		world << "\t\t..()"
		for(var/p in properties)
			if(!(p in property_info)) continue
			if(property_info[p][1] == "event")
				world << "\t\twinset(owner,\"\[window_id].\[control_id]\",\"[p]=InterfaceEvent+\\\"\[window_id]\\\"+\\\"\[control_id]\\\"+\\\"[event_name(p)]\\\"\")"

		world << "\tproc"

		for(var/p in properties)
			if(!(p in property_info)) continue

			if(property_info[p][1] == "event")
				world << "\t\t[format_name(p)]()"
				world << "\t\t\tif(args.len)"
				world << "\t\t\t\towner._InterfaceEvents\[\"\[window_id].\[control_id].[event_name(p)]\"] = args\[1]"
				world << "\t\t\telse"
				world << "\t\t\t\treturn owner._InterfaceEvents\[\"\[window_id].\[control_id].[event_name(p)]\"]"
			else
				var/cache_var = ""
				if(property_info[p][2] == "no")
					cache_var = "_[format_name(p)]"
				world << "\t\t[format_name(p)]()"
				world << "\t\t\tif(args.len)"

				if(property_info[p][1] == "size" || property_info[p][1] == "position")
					world << "\t\t\t\treturn _set_[property_info[p][1]](\"[p]\", \"[cache_var]\", args)"
				else
					world << "\t\t\t\treturn _set_[property_info[p][1]](\"[p]\", \"[cache_var]\", args\[1])"

				world << "\t\t\telse"
				world << "\t\t\t\treturn _get_[property_info[p][1]](\"[p]\", \"[cache_var]\")"