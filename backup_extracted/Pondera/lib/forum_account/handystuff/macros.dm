
// File:    macros.dm
// Library: Forum_account.HandyStuff
// Author:  Forum_account
//
// Contents:
//   This file contains procs that let you add and remove
//   keyboard macros at runtime. Typically, you'd define
//   macros in an interface file (*.dmf). These files can
//   be annoying to edit. You can use DM code to define how
//   mouse events are handled but not keyboard events.
//
//   Macros are created like this:
//
//     client.add_macro("a", CTRL + ALT)
//
//   When the player presses ctrl + alt + A their mob's macro()
//   proc will be called. You can override this proc to implement
//   the behavior to handle this event.




var
	const
		ALT = 1
		CTRL = 2
		SHIFT = 4
		RELEASE = 8
		REPEAT = 16

mob
	proc
		// The first argument is the key that was pressed. It's called
		// "k" so it doesn't get confused with the mob's built-in key var.
		// The second argument is a number that specifies the modifiers.
		// See demo\demo.dm for an example of how to use macros.
		macro(k, modifiers)

client
	var
		windows
		list/macros
		__macros_initialized = 0

	New()
		. = ..()
		__init_macro_stuff()

	verb
		Macro(k as text, modifiers as num)
			set hidden = 1
			mob.macro(k, modifiers)

	proc
		add_macro(k, modifiers = 0)

			if(!__macros_initialized)
				__init_macro_stuff()

			var/macro = __macro_name(k, modifiers)

			for(var/m in macros)
				winset(src, "[macro]", "parent=[m];name=[macro];command=Macro+\"[k]\"+[modifiers]")

		remove_macro(k, modifiers = 0)
			var/macro = __macro_name(k, modifiers)

			for(var/m in macros)
				winset(src, "[macro]", "parent=")

		__macro_name(k, modifiers)
			. = "[k]"
			if(modifiers & ALT)
				. = "Alt+[.]"
			if(modifiers & CTRL)
				. = "Ctrl+[.]"
			if(modifiers & SHIFT)
				. = "Shift+[.]"
			if(modifiers & RELEASE)
				. = "[.]+UP"
			if(modifiers & REPEAT)
				. = "[.]+REP"

		__init_macro_stuff()
			windows = winget(src, null, "windows")
			macros = params2list(winget(src, windows, "macro"))
			__macros_initialized = 1

