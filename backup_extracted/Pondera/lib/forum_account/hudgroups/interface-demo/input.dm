
#include <forum_account\keyboard\keyboard.dme>

// The input control is really just a label that can accept keyboard
// focus. When you press a key its "value" var is set to be the text
// the user has typed. The caption is set to reflect the current value
// and cursor position.
//
// This control supports typing a limited set of characters, using the
// arrow keys to move the cursor position, using the backspace key to
// erase a letter, and using the delete key to delete a letter.
HudInput
	parent_type = /HudLabel

	__align = LEFT
	__valign = MIDDLE

	__background = "#fff"
	__border = "#000"
	__padding = 3

	__width = 64

	var
		value = ""
		__index = 1

		focus = 0

		list/__shift_versions = list("1" = "!", "2" = "@", "3" = "#", "4" = "$", "5" = "%", "6" = "^", "7" = "&", "8" = "*", "9" = "(", "0" = ")")
		list/__typed_characters = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"," ")

	// do nothing
	caption(c)

	Click()
		focus(1, usr.client)

	click(object, client/c)
		if(object != src)
			focus(0, c)

	key_down(k, client/c)
		__add_char(k, c)

	#ifndef NO_KEY_REPEAT
	key_repeat(k, client/c)
		__add_char(k, c)
	#endif

	proc
		focus(f, client/c)
			if(focus)
				if(f) return

				focus = 0
				c.focus = c

			else
				if(!f) return

				focus = 1
				c.focus = src

			__set_text()

		value(v)
			value = v
			__index = 1
			__set_text()

		backspace()
			if(__index > 1)
				value = copytext(value, 1, __index - 1) + copytext(value, __index)
				__index -= 1
				__set_text()

		delete()
			if(__index < length(value) + 1)
				value = copytext(value, 1, __index) + copytext(value, __index + 1)
				__set_text()

		escape(client/c)
			focus(0, c)

		left()
			if(__index > 1)
				__index -= 1
				__set_text()

		right()
			if(__index < length(value) + 1)
				__index += 1
				__set_text()

		__add_char(k, client/c)

			// handle keys with some special meaning
			if(k == "back")
				backspace()
			else if(k == "delete")
				delete()
			else if(k == "west")
				left()
			else if(k == "east")
				right()
			else if(k == "escape")
				escape(c)

			// handle all other keys
			else
				var/char

				if(k == "space")
					k = " "

				// if it's a typed character, figure out what character
				// will be added to the string
				if(k in __typed_characters)
					if(c.keys["shift"])
						if(k in __shift_versions)
							char = __shift_versions[k]
						else
							char = uppertext(k)
					else
						char = k

				if(char)
					// add this character to the proper position in the string
					value = copytext(value, 1, __index) + char + copytext(value, __index)

					// update the cursor index
					__index += 1

					// update the caption
					__set_text()


		__set_text()
			var/txt = value
			if(focus)
				txt = copytext(value, 1, __index) + "|" + copytext(value, __index)

			// world << "input text = '[txt]'"

			__caption = txt

			txt = font.cut_text(txt, __width - __padding * 2)
			caption.set_text(txt)
			__caption_width = font.text_width(txt)

			__set()
