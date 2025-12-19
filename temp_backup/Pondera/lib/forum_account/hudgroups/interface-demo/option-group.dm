
// The HudOptionGroup object is used to display a set of
// selectable options. Every option has a caption and a value,
// to add an option call:
//
//   HudOptionGroup.add_option(caption, value)
//
// The option group also has a mode, which can be OPTION or
// CHECK. OPTION means you can only select one value, which
// is stored in the object's "value" var. CHECK means you can
// select any combination of options, and the set of selected
// options is stored as a list in the object's "selected" var.
HudOptionGroup
	parent_type = /HudInterface

	var
		const
			OPTION = "option"
			CHECK = "check"

	var
		list/options = list()
		value

		list/selected = list()

		list/__button = list()
		list/__text = list()

		mode = OPTION

	New(mob/m, mode = null, layer = null)
		..(m)

		if(!isnull(layer))
			src.layer = layer

		if(!isnull(mode))
			mode(mode)

	proc
		mode(m)
			if(mode == m) return

			mode = m

			if(mode == OPTION)
				value = null
				for(var/v in __button)
					var/HudObject/h = __button[v]
					h.icon_state = "option-blank"

			else if(mode == CHECK)
				selected.Cut()
				for(var/v in __button)
					var/HudObject/h = __button[v]
					h.icon_state = "check-blank"

	Click(HudObject/h)

		if(mode == OPTION)

			var/HudObject/selected = __button[value]
			var/HudObject/clicked = __button[h.value]

			clicked.icon_state = "option-selected"

			if(selected)
				selected.icon_state = "option-blank"

			value = h.value

		else if(mode == CHECK)
			var/HudObject/clicked = __button[h.value]

			if(h.value in selected)
				selected -= h.value
				clicked.icon_state = "check-blank"
			else
				selected += h.value
				clicked.icon_state = "check-selected"

	proc
		add_option(c, value = null)

			if(isnull(value))
				value = c

			if(value in options)
				return 0

			options += value
			__button[value] = add(0, 0, "[mode]-blank", value = value)
			__text[value] = add(0, 0, text = c, value = value)
			__set()

		__set()
			var/py = options.len * 16 - 16
			for(var/i = 1 to options.len)
				var/value = options[i]

				var/HudObject/h = __button[value]
				h.pos(0, py)
				h = __text[value]
				h.pos(17, py + 4)

				py -= 16
