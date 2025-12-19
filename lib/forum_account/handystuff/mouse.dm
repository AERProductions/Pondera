
// File:    mouse.dm
// Library: Forum_account.HandyStuff
// Author:  Forum_account
//
// Contents:
//   BYOND's built-in mouse procs each have a "params" argument
//   which contains parameters packed into a string. To access
//   any of these parameters you have to convert the string to a
//   list, then convert the lists's contents from strings to
//   numbers. The MouseEvent object handles all of that for you.
//   Look at demo\demo.dm for an example of how to use it.
//
//   Note: I need to work on the handling of mouse drag events.

MouseEvent
	var
		location = null
		control = ""
		icon_x = -1
		icon_y = -1
		screen_loc = ""

		left = 0
		middle = 0

		mob/usr
		object

	New(loc,ctl,params)
		location = loc
		control = ctl
		src.usr = usr

		params = params2list(params)
		if("icon-x" in params)
			icon_x = text2num(params["icon-x"])
		if("icon-y" in params)
			icon_y = text2num(params["icon-y"])

		if("screen_loc" in params)
			screen_loc = params["screen_loc"]

		left = ("left" in params)
		middle = ("middle" in params)

client
	Click(object, location, control, params)
		..()
		var/MouseEvent/e = new(location, control, params)
		e.object = object
		return e

	DblClick(object, location, control, params)
		..()
		var/MouseEvent/e = new(location, control, params)
		e.object = object
		return e

	MouseDown(object, location, control, params)
		..()
		var/MouseEvent/e = new(location, control, params)
		e.object = object
		return e

	MouseDrag(src_object,over_object,src_location,over_location,src_control,over_control,params)
		..()
		return new /MouseEvent(over_object,over_control,params)

	MouseDrop(src_object,over_object,src_location,over_location,src_control,over_control,params)
		..()
		return new /MouseEvent(over_object,over_control,params)

	MouseEntered(object, location, control, params)
		..()
		var/MouseEvent/e = new(location, control, params)
		e.object = object
		return e

	MouseExited(object, location, control, params)
		..()
		var/MouseEvent/e = new(location, control, params)
		e.object = object
		return e

	MouseUp(object, location, control, params)
		..()
		var/MouseEvent/e = new(location, control, params)
		e.object = object
		return e

atom
	// If you define your own Click proc it will be called
	// before this one. If you call ..() in your Click proc,
	// this one will be called. This one returns a MouseEvent
	// object, so calling ..() in your Click proc will parse
	// the params and return the MouseEvent object for that
	// mouse click.
	Click(location,control,params)
		..()
		return new /MouseEvent(location,control,params)

	DblClick(location,control,params)
		..()
		return new /MouseEvent(location,control,params)

	MouseUp(location,control,params)
		..()
		return new /MouseEvent(location,control,params)

	MouseDown(location,control,params)
		..()
		return new /MouseEvent(location,control,params)

	MouseExited(location,control,params)
		..()
		return new /MouseEvent(location,control,params)

	MouseEntered(location,control,params)
		..()
		return new /MouseEvent(location,control,params)

	MouseDrop(atom/over_object,atom/src_location,atom/over_location,src_control,over_control,params)
		..()
		return new /MouseEvent(over_object,over_control,params)

	MouseDrag(atom/over_object,atom/src_location,atom/over_location,src_control,over_control,params)
		..()
		return new /MouseEvent(over_object,over_control,params)
