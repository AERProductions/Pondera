

debug
	var
		category
		message

	New(c)
		if(!(debuggers.Find(c)))

			category = c
			message = "START\n"

			world.log << "New [category] Debugger!"

			debuggers[category] = src

	proc
		Print()
			world.log << "[category] debugger: [message]"
			message = initial(message)

		AddLine(txt)
			message += "[txt]\n"

var
	debuggers[]

world
	New()
		debuggers = new
		new /debug ("debug")
		..()