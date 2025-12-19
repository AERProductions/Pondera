
// File:    colors.dm
// Library: Forum_account.HandyStuff
// Author:  Forum_account
//
// Contents:
//   This file creates a Color datum that can be used to represent
//   RGBA (red, green, blue, alpha) colors. DM has the rgb() proc
//   which is used to handle colors. It returns a string of the form
//   #RRGGBB, like HTML uses, but these can be annoying to work with.
//   If you want to increase the red by 10, you need to compute its
//   numerical value, change it, and convert back to the #RRGGBB format.
//   This datum handles that all for you.

Color
	var
		red = 0
		green = 0
		blue = 0
		alpha = 255

	// The constructor has three forms:
	//
	//     new /Color()
	//     new /Color(red, green, blue, [alpha])
	//     new /Color(color_string)
	//
	// For the first form, all RGBA components are initialized
	// to zero.
	// For the second form, the RGBA components are set as you
	// specify. If you leave out the alpha it is set to 255.
	// For the third form the string can be of the form "#RRGGBB"
	// or "#RRGGBBAA".
	New(a, b = 0, c = 0, d = 255)
		if(istext(a))
			red = Text.int(copytext(a,2,4),16)
			green = Text.int(copytext(a,4,6),16)
			blue = Text.int(copytext(a,6,8),16)
			if(length(a) > 7)
				alpha = Text.int(copytext(a,8,10),16)

		else if(isnum(a))
			red = a
			green = b
			blue = c
			alpha = d
		else if(isnull(a))
			alpha = 0

	proc
		RGB()
			if(alpha >= 0)
				return rgb(red, green, blue, alpha)
			return rgb(red, green, blue)