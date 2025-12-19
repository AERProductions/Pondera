
// The HudLabel object is used to display text on the screen.
// It also captures click events so you can use it as a button.
// The object's constructor takes a mob or client to display
// the object to, it also has the following named parameters:
//
//  * caption
//  * width
//  * height
//  * padding
//  * action
//  * align
//  * valign
//  * background
//  * border
//
// The object also has procs of those same names that can be
// used to set those properties later on.
//
// The caption is the text displayed by the label. The width
// and height are measurements in pixels. The padding is a value
// also in pixels which controls how close to the edge of the
// label the text is placed. action is the proc that's called
// when the label is clicked (it's a proc that belongs to the
// mob that did the clicking). align and valign control the
// alignment of the text - align can be LEFT, CENTER, or RIGHT
// and valign can be TOP, MIDDLE, or BOTTOM. background is the
// background color (or "" for no background), border is the
// border color (or "" for no border).
HudLabel
	parent_type = /HudInterface

	var
		const
			LEFT = 1
			RIGHT = 2
			CENTER = 3

			TOP = 1
			BOTTOM = 2
			MIDDLE = 3

	var
		__width = 0
		__height = 0

		__padding = 2

		__caption
		__caption_width = 0

		__align = LEFT
		__valign = MIDDLE

		__action = null

		__background = ""
		__border = ""

		HudObject/background
		HudObject/caption

	New(mob/m, caption = null, width = null, height = null, padding = null, action = null, align = null, valign = null, background = null, border = null, layer = null)
		..(m)

		if(!isnull(layer))
			src.layer = layer

		if(!isnull(width))
			__width = width

		if(!isnull(height))
			__height = height
		else if(__height <= 0)
			__height = font.line_height + __padding * 2

		if(!isnull(padding))
			__padding = padding
		else
			__padding = 2

		if(!isnull(background))
			__background = background

		if(!isnull(border))
			__border = border

		src.background = add(0, 0)
		if(__background)
			__set_icon()

		src.caption = add(0, 0, layer = src.layer + 1)

		if(!isnull(align))
			align(align)

		if(!isnull(valign))
			valign(valign)

		if(!isnull(action))
			action(action)

		if(!isnull(caption))
			caption(caption)

	Click()
		if(__action)
			call(usr, __action)(src)

	proc
		width(w)
			size(w, null)

		height(h)
			size(null, h)

		border(b)
			__border = b
			__set_icon()

		background(bg)
			__background = bg
			__set_icon()

		__set_icon()

			var/icon/I

			if(__background)
				I = icon(icon, "label")
				I.Blend(__background, ICON_OVERLAY)
				I.Crop(1, 1, 1, 1)
				I.Scale(__width, __height)

				if(__border)
					I.DrawBox(__border, 1, 1, __width, 1)
					I.DrawBox(__border, 1, __height, __width, __height)

					I.DrawBox(__border, 1, 1, 1, __height)
					I.DrawBox(__border, __width, 1, __width, __height)

				background.icon = I

			background.icon = I

		size(w, h)

			if(!isnull(w)) __width = w
			if(!isnull(h)) __height = h

			__set_icon()
			__set()

		padding(p)
			__padding = p
			__set()

		align(a)
			__align = a
			__set()

		valign(a)
			__valign = a
			__set()

		action(a)
			__action = a

		caption(c)

			__caption = c

			c = font.cut_text(c, __width - __padding * 2)
			caption.set_text(c)
			__caption_width = font.text_width(c)

			__set()

		__set()
			if(!__caption) return

			var/px
			if(__align == CENTER)
				px = (__width / 2) - (__caption_width / 2)
			else if(__align == RIGHT)
				px = __width - __caption_width - __padding
			else
				px = __padding

			var/py
			if(__align == MIDDLE)
				py = (__height / 2) - (font.line_height / 2) + __padding
			else if(__align == TOP)
				py = __height - font.line_height - __padding
			else
				py = __padding

			caption.pos(px, py)

// buttons are labels, they just have some different default values.
HudButton
	parent_type = /HudLabel

	__align = CENTER
	__valign = MIDDLE

	__background = "#ccc"
	__border = "#000"

	__width = 64
	__height = 24
