
// File:    base.dm
// Library: Forum_account.Interface
// Author:  Forum_account
//
// Contents:
//   Some basic functionality used by all interface controls.

Size
	var
		width
		height

	New(a, b = -1)
		if(istext(a))
			a = split(a, "x")
			width = text2num(a[1])
			height = text2num(a[2])
		else
			width = a
			height = b

Position
	var
		x
		y

	New(a, b = -1)
		if(istext(a))
			a = split(a, ",")
			x = text2num(a[1])
			y = text2num(a[2])
		else
			x = a
			y = b

Color
	var
		red = 0
		green = 0
		blue = 0
		alpha = -1

	New(color_code)
		if(length(color_code) < 8)
			red = int(copytext(color_code, 2, 4), 16)
			green = int(copytext(color_code, 4, 6), 16)
			blue = int(copytext(color_code, 6, 8), 16)
		else
			red = int(copytext(color_code, 2, 4), 16)
			green = int(copytext(color_code, 4, 6), 16)
			blue = int(copytext(color_code, 6, 8), 16)
			alpha = int(copytext(color_code, 8, 10), 16)

var
	const
		EVENT_CLICK = "click"

mob
	var
		list/_InterfaceEvents = list()

	verb
		InterfaceEvent(window_id as text, control_id as text, event as text)
			set hidden = 1

			var/param = null
			var/pos = findtext(event,"\"")
			if(pos)
				param = copytext(event,pos+1)
				event = copytext(event,1,pos)

			var/k = "[window_id].[control_id].[event]"

			if(k in _InterfaceEvents)
				if(_InterfaceEvents[k])
					if(param)
						call(src, _InterfaceEvents[k])(param)
					else
						call(src, _InterfaceEvents[k])()

Control
	var
		window_id
		control_id
		mob/owner

	New()

		for(var/i = 1 to args.len)
			var/arg_value = args[i]

			if(istext(arg_value))
				if(!window_id)
					window_id = arg_value
				else if(!control_id)
					control_id = arg_value

			else if(ismob(arg_value))
				owner = arg_value

		if(!control_id)
			var/pos = findtext(window_id, ".")

			if(pos)
				control_id = copytext(window_id, pos + 1)
				window_id = copytext(window_id, 1, pos)

	proc
		_get(property, cache_var)
			if(cache_var && vars[cache_var])
				return vars[cache_var]

			if(control_id)
				. = winget(owner, "[window_id].[control_id]", property)
			else
				. = winget(owner, window_id, property)

		_get_position(property, cache_var)
			. = new /Position(_get(property, cache_var))
			if(cache_var)
				vars[cache_var] = .

		_get_size(property, cache_var)
			. = new /Size(_get(property, cache_var))
			if(cache_var)
				vars[cache_var] = .

		_get_color(property, cache_var)
			. = new /Color(_get(property, cache_var))
			if(cache_var)
				vars[cache_var] = .

		_get_boolean(property, cache_var)
			. = (_get(property, cache_var) == "true") ? 1 : 0
			if(cache_var)
				vars[cache_var] = .

		_get_number(property, cache_var)
			. = text2num(_get(property, cache_var))
			if(cache_var)
				vars[cache_var] = .

		_get_fontstyle(property, cache_var)
			. = split(_get(property, cache_var), " ")
			if(cache_var)
				vars[cache_var] = .

		_get_text(property, cache_var)
			. = _get(property, cache_var)
			if(cache_var)
				vars[cache_var] = .

		_get_borderstyle(property, cache_var)
			return _get_text(property, cache_var)

		_get_imagemode(property, cache_var)
			return _get_text(property, cache_var)

		_get_alignment(property, cache_var)
			return _get_text(property, cache_var)

		_get_buttontype(property, cache_var)
			return _get_text(property, cache_var)

		_set(property, cache_var, value)
			if(control_id)
				winset(owner, "[window_id].[control_id]", "[property]=[value]")
			else
				winset(owner, window_id, "[property]=[value]")

		_set_position(property, cache_var, list/params)
			var/Position/value
			if(params.len == 2)
				value = new /Position(params[1], params[2])
			else if(params.len == 1)
				if(istext(params[1]))
					value = new /Position(params[1])
				if(isnum(params[1]))
					value = new /Position(params[1],-1)
				else
					value = params[1]
			else
				CRASH("Setting a position property expects a single paramter (either a /Position object or a text string like '32,14') or two numerical parameters (the x and y)")

			if(cache_var)
				vars[cache_var] = value

			_set(property, cache_var, "[value.x],[value.y]")

		_set_size(property, cache_var, list/params)
			var/Size/value
			if(params.len == 2)
				value = new /Size(params[1], params[2])
			else if(params.len == 1)
				if(istext(params[1]))
					value = new /Size(params[1])
				else if(isnum(params[1]))
					if(params[1] == 0)
						value = new /Size(0,params[1])
					else
						value = new /Size(1,params[1])
				else
					value = params[1]
			else
				CRASH("Setting a size property expects a single paramter (either a /Size object or a text string like '32x14') or two numerical parameters (the width and height)")

			if(cache_var)
				vars[cache_var] = value

			_set(property, cache_var, "[value.width]x[value.height]")

		_set_color(property, cache_var, Color/value)
			if(cache_var)
				vars[cache_var] = value
			_set(property, cache_var, rgb(value.red, value.green, value.blue))

		_set_boolean(property, cache_var, value)
			if(cache_var)
				vars[cache_var] = value
			_set(property, cache_var, value ? "true" : "false")

		_set_number(property, cache_var, value)
			if(cache_var)
				vars[cache_var] = value
			_set(property, cache_var, "[value]")

		_set_fontstyle(property, cache_var, list/value)
			if(cache_var)
				vars[cache_var] = value
			_set(property, cache_var, merge(value, " "))

		_set_text(property, cache_var, value)
			if(cache_var)
				vars[cache_var] = value
			_set(property, cache_var, "\"[value]\"")

		_set_borderstyle(property, cache_var, value)
			return _set_text(property, cache_var, value)

		_set_imagemode(property, cache_var, value)
			return _set_text(property, cache_var, value)

		_set_alignment(property, cache_var, value)
			return _set_text(property, cache_var, value)

		_set_buttontype(property, cache_var, value)
			return _set_text(property, cache_var, value)
