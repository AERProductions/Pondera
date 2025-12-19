
mob
	var
		// We define these objects which we'll use to access
		// and manipulate the player's interface controls
		Button/button1
		Label/label2
		Output/output1
		Input/input1
		Grid/grid1
		Label/label1
		Tab/tab1
		Info/info1
		Window/window1

	Login()
		..()

		// we instantiate each control object:
		button1 = new("window1", "button1", src)
		label2 = new("window1", "label2", src)
		output1 = new("window1", "output1", src)
		input1 = new("window1", "input1", src)
		grid1 = new("window1", "grid1", src)
		label1 = new("window1", "label1", src)
		tab1 = new("window1", "tab1", src)
		info1 = new("window2", "info1", src)
		window1 = new("window1", src)

		// When you click on button1 it will trigger the work_once proc.
		button1.Command(/mob/proc/work_once)

		// When you press the enter key in the text box, the text you
		// have typed will be passed to your mob's entered_text proc.
		input1.Command(/mob/proc/entered_text)

		// Your mob's switched_tabs proc will be called when you switch
		// tabs in the tab control.
		tab1.OnTab(/mob/proc/switched_tabs)

		// Your mob's statpanel_tabs proc will be called when you switch
		// tabs in the statpanel (info) control.
		info1.OnTab(/mob/proc/statpanel_tabs)

		// Move the window to the top-left corner of the screen.
		window1.Pos(0, 0)

	proc
		work_once()
			world << "You clicked on the button!"

			button1.FontFamily("Courier New")
			label1.Text("BUTTON")
			label2.Text("CLICK!")

			// Change the proc that is called when you click the button
			button1.Command(/mob/proc/broken)

		broken()
			world << "You broke the button, it doesn't work anymore."

		entered_text(txt)
			world << "You typed '[txt]'."

		switched_tabs()
			world << "You switched tabs."

		statpanel_tabs()
			world << "You switched tabs in the stat panel."

	Stat()
		statpanel("panel1")
		stat("stats...")
		statpanel("panel2")
		stat("more stats...")
		statpanel("panel3")
		stat("even more stats...")
